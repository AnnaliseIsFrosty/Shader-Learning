Shader "Unlit/HealthbarShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0, 1)) = 1.0
        _StartColor ("Start Color", Color) = (1, 0, 0, 1)
        _EndColor ("End Color", Color) = (0, 1, 0, 1)
        _LowerThreshold ("Lower Threshold", Range(0, 1)) = 0.2
        _UpperThreshold ("Upper Threshold", Range(0, 1)) = 0.8

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

            float _Health;
            float4 _StartColor, _EndColor;
            float _LowerThreshold, _UpperThreshold;
            
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
                fixed4 col = tex2D(_MainTex, i.uv);

                float4 lerpedColor = lerp(_StartColor, _EndColor, _Health); // Creates a gradient
                
                lerpedColor += (_StartColor - lerpedColor) * (_Health <= _LowerThreshold); // Sets whole bar to start color if below threshold
                lerpedColor += (_EndColor - lerpedColor) * (_Health >= _UpperThreshold); // Sets whole bar to end color if above threshold
                
                lerpedColor *= i.uv.x < _Health; // Displays blackc if health is lower than the current uv.x
                return lerpedColor;
            }
            ENDCG
        }
    }
}
