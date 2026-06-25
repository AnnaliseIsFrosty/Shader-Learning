Shader "Unlit/Shader1"
{
    Properties // input data
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Scale ("UV Scale", Float) = 1.0
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

            #include "UnityCG.cginc"

            float4 _Color;
            float _Scale;
            
            struct appdata
            {
                float4 vertex : POSITION; // vertex position
                float3 normals : NORMAL;
                float4 tangent : TANGENT;
                float4 colour : COLOR;
                float2 uv0 : TEXCOORD0; // uv coordinates
            };
            
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION; // clip space position
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o; // output
                o.vertex = UnityObjectToClipPos(v.vertex); // converts local space to clip space
                o.uv = /* TRANSFORM_TEX( */v.uv0 * _Scale/* , _MainTex) */;
                o.normal = /* UnityObjectToWorldNormal( */v.normals /* ) */;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //float4 col = tex2D(_MainTex, i.uv);
                
                float4 col = _Color;
                float4 normal = float4(i.normal, 1);
                float4 rawUV = float4(i.uv, 0, 1);

                return rawUV;
            }
            ENDCG
        }
    }
}
