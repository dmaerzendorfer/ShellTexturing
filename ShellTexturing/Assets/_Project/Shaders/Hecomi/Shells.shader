Shader "UnLit/Shells"
{
    Properties
    {
        _BaseMap("BaseMap", 2D) ="white"{} //texture of the mat
        _FurMap("FurMap", 2D) = "white"{} //height map of the fur, todo: later replace with a hashing function, see acerola solution
        [IntRange]_ShellAmount ("Shell Amount", Range(1,100)) = 16 //how many shells there will be
        _ShellStep("Shell Step", Range (0.0,0.01)) = 0.001 //distance between shells
        _AlphaCutout( "Alpha Cutout" , Range( 0.0 , 1.0 )) = 0.1 //when the strands start to taper
        _Occlusion( "Occlusion" , Range( 0.0 , 2.0 )) = 0.1 //how dark the roots get

        _BaseMove ("Base Movement", Vector) = ( 0.0 , 0.0 , 0.0 , 3.0 )
        _WindFreq ("Wind frequency oscillation", Vector) = ( 0.5 , 0.7 , 0.9 , 1.0 )
        _WindMove ("Wind Movement (shakiness), w = phase shift in local coords", Vector) = ( 0.2 , 0.3 , 0.2 , 1.0 )

    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "RenderPipeLine"="UniversalPipeline"
        }
        LOD 100

        Pass
        {
            Name "Unlit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Cull Back

            HLSLPROGRAM
            //signals this shader requires geometry function support
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma require geometry

            //lighting and shadow keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _FORWARD_PLUS //requried for blingPhong lighting in unity6

            //register our functions
            #pragma vertex Vertex
            #pragma geometry Geometry
            #pragma fragment Fragment

            //include our logic file
            #include "Shells.hlsl"
            ENDHLSL

        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore 
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        //shadow pass
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore 
            #pragma target 4.5
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL

            //nicer shadow, bit more computation heavy, but doesnt seem to work...
            //                HLSLPROGRAM
            //                //#pragma exclude_renderers gles gles3 glcore 
            //                #include "./Fur.hlsl" 
            //                #pragma vertex Vertex 
            //                #pragma require geometry 
            //                #pragma geometry Geometry 
            //                #pragma fragment fragShadow
            //                ENDHLSL
        }
    }
}