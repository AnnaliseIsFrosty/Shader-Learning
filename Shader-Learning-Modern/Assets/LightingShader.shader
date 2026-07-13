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

        // Base
        Pass
        {       
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            #include "FGLighting.cginc"

            ENDCG
        }
    }
}
