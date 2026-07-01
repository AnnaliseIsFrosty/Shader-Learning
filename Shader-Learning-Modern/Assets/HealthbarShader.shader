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
        _FlashColor ("Flash Color", Color) = (1, 1, 1, 1)
        _FlashLength ("Flash Length", Range(0, 1)) = 0.4
        _FlashStrength ("Flash Strength", Range(0, 1)) = 0.5

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
            float4 _FlashColor;
            float _FlashLength, _FlashStrength;
            
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

            float InverseLerp(float floor, float ceiling, float input) 
            {
                return (input - floor) / (ceiling - floor);
            }

            // Code sourced from Inigo Quilez
            // https://iquilezles.org/articles/functions/
            float CubicPulse(float x, float flashLocation, float flashLength) 
            {
                x = abs(x - flashLocation); // distance from current x to the flash location
                float output = x / flashLength;
                output = 1 - output * output * (3 - 2 * output);
                return output * (x <= flashLength);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                // Code for the healthbar without the texture
                float t = saturate(InverseLerp(_LowerThreshold, _UpperThreshold, _Health)); // Creates gradient range as between both thresholds
                float4 lerpedColor = lerp(_StartColor, _EndColor, t); // Creates a gradient
                lerpedColor += (_StartColor - lerpedColor) * (_Health <= _LowerThreshold); // Sets whole bar to start color if below lower threshold
                lerpedColor += (_EndColor - lerpedColor) * (_Health >= _UpperThreshold); // Same with end color if above upper threshold
                lerpedColor *= i.uv.x < _Health; // Displays black if health is lower than the current uv.x
                clip((i.uv.x > _Health) * -1); // Clips out the empty healthbar (effectively renders the previous line pointless)
                
                // Code for the textured healthbar
                float4 texturedOutput; // the final output
                float4 col = tex2D(_MainTex, float2(_Health, i.uv.y)); // Samples the texture at the x position corresponding to current health
                float4 texturedStartColor = tex2D(_MainTex, float2(0, i.uv.y)); // Color for below lower threshold
                float4 texturedEndColor = tex2D(_MainTex, float2(1, i.uv.y)); // Color for above upper threshold
                
                // Code for the thresholds (I prefer how it looks without thresholds)
                //col += (texturedStartColor - col) * (_Health <= _LowerThreshold) + (texturedEndColor - col) * (_Health >= _UpperThreshold);
                
                // Flashing code
                float4 flash = lerp(col, _FlashColor, CubicPulse(frac(_Time.y), 0.5, _FlashLength) * _FlashStrength); // Blends to flash color based off current intensity of the flash
                texturedOutput = col * (_Health > _LowerThreshold) + flash * (_Health <= _LowerThreshold);

                return texturedOutput;
            }
            ENDCG
        }
    }
}
