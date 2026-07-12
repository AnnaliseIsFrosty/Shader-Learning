Shader "Unlit/LightingShader"
{
    Properties
    {
        _Gloss ("Gloss", Float) = 1
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
                float3 lightVector = _WorldSpaceLightPos0.xyz;
                float3 diffuseLight = clamp(dot(i.normal, lightVector), 0, 1) * _LightColor0.xyz;

                // Specular Lighting
                float3 camVec = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 reflectionVec = reflect(-lightVector, i.normal);
                float specularLight = clamp(dot(camVec, reflectionVec), 0, 1);

                specularLight = pow(specularLight, _Gloss);

                return float4(specularLight.xxx, 1);
            }
            ENDCG
        }
    }
}
