Shader "Lit/Shells"
{
    Properties
    {
        [MainColor] _BaseColor( "Color" , Color) = ( 0.5 , 0.5 , 0.5 , 1 )
        _BaseMap( "Base Map" , 2D) = "white" {}
        [Gamma] _Metallic( "Metallic" , Range( 0.0 , 1.0 )) = 0.5
        _Smoothness( "Smoothness" , Range( 0.0 , 1.0 )) = 0.5
        _FurMap( "Fur Map" , 2D) = "white" {}
        [IntRange] _ShellAmount( "Shell Amount" , Range( 1 , 42 )) = 14
        _ShellStep( "Shell Step" , Range( 0.0 , 0.01 )) = 0.001
        _AlphaCutout( "Alpha Cutout" , Range( 0.0 , 1.0 )) = 0.2
        _Occlusion( "Occlusion" , Range( 0.0 , 2.0 )) = 0.5
        _BaseMove( "Base Move" , Vector) = ( 0.0 , 0.0 , 0.0 , 3.0 )
        _WindFreq( "Wind Freq" , Vector) = ( 0.5 , 0.7 , 0.9 , 1.0 )
        _WindMove( "Wind Move" , Vector) = ( 0.2 , 0.3 , 0.2 , 1.0 )
//        [Header(Emission)][Space]
//        [HDR]
//        _Emission ("Emission", Color) = (1,1,1,1)
//        _UseEmission ("Use Emission", Float) = 1
//        _EmissionStart("Emission Start Layer", Range( 0.0 , 1.0 )) = 0
//        _EmissionEnd("Emission End Layer", Range( 0.0 , 1.0 )) = 0
        [Header(Lighting)][Space]
        _RimLightPower("Rim Light Power", Range(1.0, 20.0)) = 6.0
        _RimLightIntensity("Rim Light Intensity", Range(0.0, 1.0)) = 0.5
        _ShadowExtraBias("Shadow Extra Bias", Range(-1.0, 1.0)) = 0.0

        [Header(Blending)][Space]
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Blend Operation", Float) = 0

    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }

        LOD 100
        ZWrite On
        Cull Off

        //blend sourceFator destinationFactor
        //src = what my frag returns
        //dest = what is already in the frameBuffer
        //blendOp how they blend
        // so basically => color = src*srcFactor blendOp(eG -, *, min,max,reverseSubstract etc) dst*dstFactor

        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

        Pass
        {
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            
            HLSLPROGRAM
            #define _SPECULARHIGHLIGHTS_OFF

            
            #pragma shader_feature _ _FORWARD_PLUS
            #pragma shader_feature_fragment _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma shader_feature_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // Material keywords 
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _OCCLUSIONMAP

            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            // URP keywords 
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            // Unity keywords 
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            // #pragma multi_compile_fog

            #include "./LitShells.hlsl"
            #pragma vertex vert
            #pragma require geometry
            #pragma geometry geom
            #pragma fragment frag
            ENDHLSL
        }
        /*Pass
        {
            Name "SecondForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #define _SPECULARHIGHLIGHTS_OFF
            #define _MAIN_LIGHT_SHADOWS //wether we calc shadowcoords or not

            float _PassShellOffset=14;

            #pragma shader_feature _ _FORWARD_PLUS
            #pragma shader_feature_fragment _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma shader_feature_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // Material keywords 
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _OCCLUSIONMAP

            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            // URP keywords 
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            // Unity keywords 
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            // #pragma multi_compile_fog

            #include "./LitShells.hlsl"
            #pragma vertex vert
            #pragma require geometry
            #pragma geometry geom
            #pragma fragment frag
            ENDHLSL
        }
        Pass
        {
            Name "ThirdForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #define _SPECULARHIGHLIGHTS_OFF

            float _PassShellOffset= 0;
            
            #pragma shader_feature _ _FORWARD_PLUS
            #pragma shader_feature_fragment _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma shader_feature_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // Material keywords 
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICSPECGLOSSMAP
            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _OCCLUSIONMAP

            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature _SPECULAR_SETUP
            #pragma shader_feature _RECEIVE_SHADOWS_OFF

            // URP keywords 
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

            // Unity keywords 
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            // #pragma multi_compile_fog

            #include "./LitShells.hlsl"
            #pragma vertex vert
            #pragma require geometry
            #pragma geometry geom
            #pragma fragment frag
            ENDHLSL
        }*/
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
        //        Pass
        //        {
        //            Name "ShadowCaster"
        //            Tags
        //            {
        //                "LightMode" = "ShadowCaster"
        //            }
        //
        //            ZWrite On
        //            ZTest LEqual
        //            ColorMask 0
        //
        //            HLSLPROGRAM
        //            //#pragma exclude_renderers gles gles3 glcore 
        //            #pragma target 4.5
        //            #pragma vertex ShadowPassVertex
        //            #pragma fragment ShadowPassFragment
        //            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
        //            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
        //            ENDHLSL
        //
        //            //nicer shadow, bit more computation heavy, but doesnt seem to work...
        //            //                HLSLPROGRAM
        //            //                //#pragma exclude_renderers gles gles3 glcore 
        //            //                #include "./Fur.hlsl" 
        //            //                #pragma vertex Vertex 
        //            //                #pragma require geometry 
        //            //                #pragma geometry Geometry 
        //            //                #pragma fragment fragShadow
        //            //                ENDHLSL
        //        }
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
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // Universal Pipeline keywords
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

    }
}