Shader "Unlit/Shader1"
{
    Properties // input data
    {
        _MainTex ("Texture", 2D) = "white" {}
       
        // For Gradient Shader
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (1, 1, 1, 1)
        _GradientFloor("Gradient Floor", Range(0, 1)) = 0
        _GradientCeiling("Gradient Ceiling", Range(0, 1)) = 1
        _Scale ("UV Scale", Float) = 1.0
        _Offset ("UV Offset", Float) = 1.0
        
        // For Wavy Shader
        _xOffsetMult("Wave xOffset", Float) = 1.0
        _WaveHeight("Wave Height", Range(0, 0.5)) = 0.01
        _WaveMult("Wave Mult", Float) = 1.0
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent" 
            "Queue"="Transparent"
            }
        LOD 100

        Pass
        {
            ZWrite Off
            Blend One One // Additive
            //Blend DstColor Zero // Multiplicative

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define TAU 6.28318531

            #include "UnityCG.cginc"

            float4 _ColorA;
            float4 _ColorB;
            float _GradientFloor;
            float _GradientCeiling;
            float _Scale;
            float _Offset;
            float _xOffsetMult;
            float _WaveHeight;
            float _WaveMult;
            
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

            v2f vert (appdata v)
            {
                v2f o; // output
                o.vertex = UnityObjectToClipPos(v.vertex); // converts local space to clip space
                o.uv = (_Offset + v.uv0) * _Scale;
                o.normal = /* UnityObjectToWorldNormal( */v.normals /* ) */;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //float4 col = tex2D(_MainTex, i.uv);
                
                float4 col = _ColorA;
               
                float4 normal = float4(i.normal, 1);
                float4 rawUV = float4(i.uv, 0, 1);
                
                // GRADIENT SHADER
                // finds the gradient range based off the chosen floor and ceiling
                // saturate clamps the values
                float t = saturate(InverseLerp(_GradientFloor, _GradientCeiling, i.uv.x)); 
                float4 lerpedColor = lerp(_ColorA, _ColorB, t); // blend between two colours based off x uv coordinate
                

                // WAVY SHADER
                float xOffset = cos(i.uv.x * TAU * _xOffsetMult) * _WaveHeight; // xOffset creates the wave pattern
                float wave = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * _WaveMult) * 0.5 + 0.5; // passes uv.x into cos function and clamps between 0 and 1 instead of -1 and 1
                wave *= 1 - i.uv.y; // fades to black as it goes up

                return wave;
            }
            ENDCG
        }
    }
}
