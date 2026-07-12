Shader "Unlit/LightingShader"
{
    Properties
    {
        _Gloss ("Gloss", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float _Gloss;

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                i.normal = normalize(i.normal); // Normalize all interpolated normals to smooth out specular light

                // Diffuse Lighting
                float3 lightVec = _WorldSpaceLightPos0.xyz;
                float3 lambert = clamp(dot(i.normal, lightVec), 0, 1);
                float3 diffuseLight = lambert * _LightColor0.xyz;

                // Specular Lighting
                float3 camVec = normalize(_WorldSpaceCameraPos - i.wPos);
                            // Used for Phong lighting
                            //float3 reflectionVec = reflect(-lightVec, i.normal);
                            //float specularLight = clamp(dot(camVec, reflectionVec), 0, 1);

                // Blinn-Phong lighting
                float3 halfVec = normalize(lightVec + camVec);
                float specularLight = clamp(dot(i.normal, halfVec), 0, 1) * (lambert > 0);

                float specularExponent = exp2(_Gloss * 6 + 1);
                specularLight = pow(specularLight, specularExponent);

                return float4(specularLight.xxx, 1);
            }
            ENDCG
        }
    }
}
