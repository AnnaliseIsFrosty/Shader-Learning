Shader "Unlit/TextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PatternTex ("Texture", 2D) = "white" {}
        _WaveDensity ("Wave Density", Range(0, 50)) = 1.0
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

            #define TAU 6.28318531

            #include "UnityCG.cginc"

            float _WaveDensity;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _PatternTex;
            float4 _PatternTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 moss = tex2D(_MainTex, i.uv);
                fixed4 pattern = tex2D(_PatternTex, i.uv);

                pattern = (cos((pattern - _Time.y * 0.2) * TAU * _WaveDensity) * 0.5 + 0.5) * (1 - pattern);
                //pattern *= 1 - float4(i.uv, 1, 1);

                return pattern;
            }
            ENDCG
        }
    }
}
