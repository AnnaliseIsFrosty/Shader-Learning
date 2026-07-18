Shader "Unlit/LightingShader"
{
    Properties
    {
        _Gloss ("Gloss", Range(0, 1)) = 0.5
        _RockAlbedo("Rock Albedo", 2D) = "white"{}
        _RockNormalMap("Rock Normal Map", 2D) = "bump"{}
        _RockNormalIntensity("Rock Normal Intensity", Range(0, 1)) = 0.5
        _RockHeightMap("Rock HeightMap", 2D) = "gray"{}
        _RockHeightIntensity("Rock Height Intensity", Range(0, 0.2)) = 0.1
        _AmbientLight("Ambient Light", Color) = (0, 0, 0, 0)
        _DiffuseIBL("Diffuse IBL", 2D) = "black"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        

        // Base
        Pass
        {       
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define IN_BASE
            #define TAU 6.2831853

            #include "FGLighting.cginc"

            ENDCG
        }

        // Add
        Pass
        {
            Tags { "LightMode"="ForwardAdd" }
            Blend One One // src * 1 + dest * 1

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd
            #define TAU 6.2831853

            #include "FGLighting.cginc"

            ENDCG
        }
    }
}
