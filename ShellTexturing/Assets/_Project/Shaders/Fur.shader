Shader "Unlit/Fur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FurMap ("Fur Map", 2D) = "white" {}
        [IntRange] _ShellAmount ("Shell Amount", Range (1, 100)) = 16 //how many shells
        _ShellStep("Shell Step", Range(0.0,0.01)) = 0.001 //distance between shells
        _AlphaCutout("Alpha Cuutout", Range(0.0, 1.0)) = 0.1 //when shell strands start to taper?
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100 //vertex lit shader according to https://docs.unity3d.com/6000.1/Documentation/Manual/SL-ShaderLOD.html
        ZWrite On //allows us to write into the depth buffer
        Cull Back //cull back faces of polygons

        Pass
        {
            //technically i could just include this hlsl snippet with the pragma for the geometry pass in a shadergraph and do the rest in the graph!
            Name "Unlit"
            HLSLPROGRAM //we write a HLSLPROGRAM. alternative would be CGPROGRAM, CGPROGRAM inncludes unities built-in shader files, CG seems to be outdated and no longer state of the art?
            #pragma exclude_renderers gles gles3 glcore //shader does not compile for gles gles3 and glcore
            #pragma multi_compile_fog //allows different types of fog (off/linear/exp/exp2)
            #include "./Fur.hlsl" //code is in fur.hlsl file
            #pragma vertex vert //vertex function is called vert
            #pragma require geometry //include the geometry stage in our shader
            #pragma geometry geom //the geometry function is called geo
            #pragma fragment frag // the fragmetn function is called frag
            ENDHLSL
        }
        
        Pass 
        {
            Name "DepthOnly"
            Tags {"LightMode" = "DepthOnly"} //means: the pass renders only depth information from the perspective of a camera into a depth texture
            ZWrite On //enables writing to the depth buffer
            ColorMask 0 // disables color writes to the r, g, b and a channels of the render target
            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl" //use the default unity shaders
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl" 
            ENDHLSL 
        }
        
        Pass
        {
            Name "ShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}
            ZWrite On
            ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5 //the shader compilation target level, 2.5 is default, higher target means more shader function
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl" 
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl" 
            ENDHLSL 
        }
    }
}
