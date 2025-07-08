Shader "Fur/Shells"
{
    Properties
    {
//        _BaseColor ("Base Color", Color) = (0,0.5,0,1) //color of the lowest layer
//        _TopColor ("Top Color", Color) = (0,1,0,1) //color of the highest layer
        _BaseMap("BaseMap", 2D) ="white"{} //texture of the mat
        _FurMap("FurMap", 2d) = "white"{} //height map of the fur, todo: later replace with a hashing function, see acerola solution
        [IntRange]_ShellAmount ("Shell Amount", Range(1,100)) = 16 //how many shells there will be
        _ShellStep("Shell Step", Range (0.0,0.01)) = 0.001 //distance between shells
        _AlphaCutout( "Alpha Cutout" , Range( 0.0 , 1.0 )) = 0.1 //when the strands start to taper
        _Occlusion( "Occlusion" , Range( 0.0 , 2.0 )) = 0.1 //how dark the roots get

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeLine"="UniversalPipeline" }
        LOD 100

        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}
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
    }
}
