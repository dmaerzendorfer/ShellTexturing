Shader "Custom/MyBasicLit"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "ForwardPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #define _SPECULAR_COLOR

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ _FORWARD_PLUS
            #pragma shader_feature_fragment _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma shader_feature_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            CBUFFER_END

            struct Attributes
            {
                float3 positionLS : POSITION;
                float3 normalLS: NORMAL;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            v2f vert(Attributes input)
            {
                v2f output = (v2f)0;
                output.positionCS = TransformObjectToHClip(input.positionLS);
                output.normalWS = TransformObjectToWorldNormal(input.normalLS);
                output.positionWS = TransformObjectToWorld(input.positionLS);
                return output;
            }

            half4 frag(v2f input) : SV_TARGET
            {
                InputData lighting = (InputData)0;
                lighting.positionWS = input.positionWS;
                lighting.normalWS = normalize(input.normalWS);
                lighting.viewDirectionWS = GetWorldSpaceViewDir(input.positionWS);
                lighting.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                SurfaceData surface = (SurfaceData)0;
                surface.albedo = _Color;
                surface.alpha = 1;
                surface.smoothness = .9;
                surface.specular = .9;

                return UniversalFragmentBlinnPhong(lighting, surface) + unity_AmbientSky;
            }
            ENDHLSL
        }
        Pass
        {
            Name "SecondForwardPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            #define _SPECULAR_COLOR

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ _FORWARD_PLUS
            #pragma shader_feature_fragment _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma shader_feature_fragment _ _ADDITIONAL_LIGHT_SHADOWS

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            CBUFFER_END

            struct Attributes
            {
                float3 positionLS : POSITION;
                float3 normalLS: NORMAL;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            v2f vert(Attributes input)
            {
                v2f output = (v2f)0;
                output.positionCS = TransformObjectToHClip(input.positionLS);
                output.normalWS = TransformObjectToWorldNormal(input.normalLS);
                output.positionWS = TransformObjectToWorld(input.positionLS);
                return output;
            }

            half4 frag(v2f input) : SV_TARGET
            {
                InputData lighting = (InputData)0;
                lighting.positionWS = input.positionWS;
                lighting.normalWS = normalize(input.normalWS);
                lighting.viewDirectionWS = GetWorldSpaceViewDir(input.positionWS);
                lighting.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                SurfaceData surface = (SurfaceData)0;
                surface.albedo = _Color;
                surface.alpha = 1;
                surface.smoothness = .9;
                surface.specular = .9;

                return UniversalFragmentBlinnPhong(lighting, surface) + unity_AmbientSky;
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster" //for casting shadows
            }
            
            ColorMask 0 //since we dont do shit in fragment
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            float3 _LightDirection;

            struct Attributes
            {
                float3 positionLS : POSITION;
                float3 normalLS: NORMAL;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
            };

            float4 GetShadowPositionHClip(Attributes input)
            {
                float3 positionWS = TransformObjectToWorld(input.positionLS);
                float3 normalWS = TransformObjectToWorldNormal(input.normalLS);
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
                positionCS = ApplyShadowClamping(positionCS);
                return positionCS;
            }

            v2f vert(Attributes input)
            {
                v2f output = (v2f)0;
                output.positionCS = GetShadowPositionHClip(input);
                return output;
            }

            half4 frag(v2f input) : SV_TARGET
            {
                return 0;
            }
            ENDHLSL
        }
    }

}