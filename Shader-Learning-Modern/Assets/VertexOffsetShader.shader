Shader "Unlit/VertexOffsetShader"
{
    Properties // input data
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveAmplitude("Wave Amplitude", Range(0, 0.5)) = 0.1
        _WaveDensity("Wave Density", Float) = 5
       
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" // Tag to inform the render pipeline (useful for post-processing)
            "Queue"="Geometry" // Default render order
            }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define TAU 6.28318531

            #include "UnityCG.cginc"

            float _WaveAmplitude;
            float _WaveDensity;
            
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

            float InverseLerp(float floor, float ceiling, float input) 
            {
                return (input - floor) / (ceiling - floor);
            }

            float GetWave(float2 uv) 
            {
                float radialDistance = length(uv * 2 - 1); // Distance from the centre (-1 to 1)
                radialDistance = cos(radialDistance * TAU * 5 - _Time.y) * 0.5 + 0.5; // Creates wave
                radialDistance *= 1 - length(uv * 2 - 1); // Fades to black outwards from the centre
                return radialDistance;
            }

            v2f vert (appdata v)
            {
                v2f o; // output

                // old code for testing
                //float wave = cos((v.uv0.x + _Time.y * 0.1) * TAU * _WaveDensity) * 0.5 + 0.5;
                //float wave2 = cos((v.uv0.y + _Time.y * 0.1) * TAU * _WaveDensity) * 0.5 + 0.5;
                //v.vertex.y = wave * wave2 * _WaveAmplitude;

           
                v.vertex.y = GetWave(v.uv0) * _WaveAmplitude;

                o.vertex = UnityObjectToClipPos(v.vertex); // converts local space to clip space
                o.uv = v.uv0;
                o.normal = /* UnityObjectToWorldNormal( */v.normals /* ) */;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {               
                float4 normal = float4(i.normal, 1);
                float4 rawUV = float4(i.uv, 0, 1);

                return float4(GetWave(i.uv).xxx, 1);
            }
            ENDCG
        }
    }
}
