//in order to not include this twice
#ifndef SHELLS_INCLUDED
#define SHELLS_INCLUDED

//include helper functions
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "NMGGrassLayersHelpers.hlsl"

//vertex function input
struct Attributes
{
    float4 positionOS : POSITION; //vertex pos of object space
    float3 normalOS : NORMAL; //vertex normal vector in object space
    float4 tangentOS: TANGENT; //vertex tangent vector in object space (plus bitangent sign)
    float2 uv: TEXCOORD0; //vertex uv
};

//vertex function output and geometry function input
// struct VertexOutput
// {
//     float3 positionWS: TEXCOORD0; //pos in world space
//     float3 normalWS: TEXCOORD1; //normal vector in world space
//     float2 uv: TEXCOORD2; //uv, no scaling applied
// };

//geometry function output and fragment function input, want to keep this rather small to maximize amount of layers
struct GeometryOutput
{
    // float3 uv : TEXCOORD0; //uv, no scaling appllied, also has the height in z
    // float3 positionWS : TEXCOORD1; //pos in world space
    // float3 normalWS : TEXCOORD2; //normal vector in world space 
    // float4 positionCS : SV_POSITION; //pos in clip space
    float4 vertex : SV_POSITION; //pos in clip space
    float2 uv : TEXCOORD0; //uv of base map
    float2 uv2 : TEXCOORD1;
    float layer: TEXCOORD2;
};

//properties
TEXTURE2D(_FurMap);
SAMPLER(sampler_FurMap);
TEXTURE2D(_BaseMap);
SAMPLER(sampler_BaseMap);
float4 _FurMap_ST;
float4 _BaseMap_ST;

float _ShellAmount;
float _ShellStep;
float _AlphaCutout;
float _Occlusion;


//vertex function
Attributes Vertex(Attributes input)
{
    return input;
    //init output struct
    // VertexOutput output = (VertexOutput)0;
    //
    // //calc pos and normal in WS
    // VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionsOS.xyz);
    // VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    // output.positionWS = vertexInput.positionWS;
    // output.normalWS = normalInput.normalWS;
    //
    // //pass through the uv
    // output.uv = input.uv;
    // return output;
}

//geometry functions

//this funciton sets values in output after calculating position
// void SetupVertex(in VertexOutput input, inout GeometryOutput output, in float offset)
// {
//     float3 positionWS = input.positionWS + input.normalWS * offset;
//
//     output.positionWS = positionWS;
//     output.normalWS = input.normalWS;
//     output.uv = float3(input.uv, offset); //maybe i should normalize the offset
//     output.positionCS = TransformWorldToHClip(positionWS);
// }

void AppendShellVertex(inout TriangleStream<GeometryOutput> stream, Attributes input, int index)
{
    GeometryOutput output = (GeometryOutput)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float3 posWS = vertexInput.positionWS + normalInput.normalWS * (_ShellStep * index);
    float4 posCS = TransformWorldToHClip(posWS);

    output.vertex = posCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.uv2 = TRANSFORM_TEX(input.uv, _FurMap);
    output.layer = (float)index / _ShellAmount;

    stream.Append(output);
}

//we currently support 100 layers max
//1 triangle with 3 vertices
//ok as i understand it: commonly the max vertexcount is 1024 (floats?)
//we output GeometryOutput -> which are 12 floats? -> 1024/12=85.3 layers
//-> every layer uses 3 vertices =>85/3 =28 
//not super sure about this, cross check with https://tips.hecomi.com/entry/2021/06/27/185835#:~:text=The%20number%20of,layers._FurMap_FurScale
[maxvertexcount(96)]
void Geometry(triangle Attributes input[3], inout TriangleStream<GeometryOutput> outputStream)
{
    [loop] for (float i = 0; i < _ShellAmount; ++i)
    {
        [unroll] for (float j = 0; j < 3; ++j)
        {
            AppendShellVertex(outputStream, input[j], i);
        }
        outputStream.RestartStrip();
    }

    // //init output struct
    // GeometryOutput output = (GeometryOutput)0;
    //
    // //for each layer
    // for (int l = 0; l < _ShellAmount; l++)
    // {
    //     //calc offset
    //     float offset = _ShellStep * l;
    //     //for each point in the triangle...
    //     for (int t = 0; t < 3; t++)
    //     {
    //         //calc the output data and add the vertex to the output tream
    //         SetupVertex(inputs[t], output, offset);
    //         outputStream.Append(output);
    //     }
    //     //each triangle is disconnected, so we need to call theis to restart the triangle strip
    //     outputStream.RestartStrip();
    // }
}

//fragment functions

half4 Fragment(GeometryOutput input) : SV_Target
{
    // //gather some data for the lighting algo
    // InputData lightingInput = (InputData)0;
    // lightingInput.positionWS = input.positionWS;
    // lightingInput.normalWS = NormalizeNormalPerPixel(input.normalWS);
    // //renormalize the normal to reduce interpolation errors
    // lightingInput.viewDirectionWS = GetViewDirectionFromPosition(input.positionWS); //calc the view direction
    // lightingInput.shadowCoord = CalculateShadowCoord(input.positionWS, input.positionCS); //calc the shadow map coord
    //
    // //calc the color based on the normalized offset(uv.z)
    // float t = input.uv.z / (_ShellAmount * _ShellStep);
    // float3 albedo = lerp(_BaseColor, _TopColor, t).rgb;
    //
    // //the urp simple lit algo
    // SurfaceData surfaceInput = (SurfaceData)0;
    // surfaceInput.albedo = albedo;
    // surfaceInput.alpha = 1;
    // surfaceInput.specular = 1;
    // surfaceInput.smoothness = 0;
    // surfaceInput.emission = 0;
    //
    // return UniversalFragmentBlinnPhong(lightingInput, surfaceInput);

    //screw blinnphong for now


    float4 furColor = SAMPLE_TEXTURE2D(_FurMap, sampler_FurMap, input.uv2);

    //make the noise texture darker and thinner further ahead
    float alpha = furColor.r * (1.0 - input.layer);
    if (input.layer > 0.0 && alpha < _AlphaCutout) discard;

    float4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);

    //darken the roots
    float occlusion = lerp(1.0 - _Occlusion, 1.0, input.layer);
    float3 color = baseColor * occlusion;

    return float4(color, alpha);
}

#endif
