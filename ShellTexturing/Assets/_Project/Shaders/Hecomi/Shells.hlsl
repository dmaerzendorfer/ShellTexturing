//in order to not include this twice
#ifndef SHELLS_INCLUDED
#define SHELLS_INCLUDED

//include helper functions
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//vertex function input
struct Attributes
{
    float4 positionOS : POSITION; //vertex pos of object space
    float3 normalOS : NORMAL; //vertex normal vector in object space
    float4 tangentOS: TANGENT; //vertex tangent vector in object space (plus bitangent sign)
    float2 uv: TEXCOORD0; //vertex uv
};

//geometry function output and fragment function input, want to keep this rather small to maximize amount of layers
struct GeometryOutput
{
    float4 vertex : SV_POSITION; //pos in clip space
    float2 uv : TEXCOORD0; //uv of base map
    float2 uv2 : TEXCOORD1; //uv of fur map
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

// xyz: direction of movement w: degree of curvature
float4 _BaseMove;
// xyz: period of oscillation
float4 _WindFreq;
// xyz: magnitude of shaking w: phase shift in local coordinates
float4 _WindMove;

//vertex function
Attributes Vertex(Attributes input)
{
    return input;
}

//geometry functions

void AppendShellVertex(inout TriangleStream<GeometryOutput> stream, Attributes input, int index)
{
    GeometryOutput output = (GeometryOutput)0;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    //make the curve bigger the further the layer is
    float moveFactor = pow((float)index / _ShellAmount, _BaseMove.w);

    //periodic shaking expression
    float3 posOs = input.positionOS;
    float3 windAngle = _Time.w * _WindFreq.xyz;
    float3 windMove = moveFactor * _WindMove.xyz * sin(windAngle + posOs * _WindMove.w);
    //stationary movement
    float3 move = moveFactor * _BaseMove.xyz;

    //reorient the shell (normalize it to prevent stretching)
    float3 shellDir = normalize(normalInput.normalWS + move + windMove);

    float3 posWS = vertexInput.positionWS + shellDir * (_ShellStep * index);
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
//we output GeometryOutput -> which are 9 floats? -> 1024/9=113 layers
//-> every layer uses 3 vertices =>113/3 =37.6666666667 -> 37*3 = 111
//numbers are outdated, but principle is the same
//not super sure about this, cross check with https://tips.hecomi.com/entry/2021/06/27/185835#:~:text=The%20number%20of,layers._FurMap_FurScale
[maxvertexcount(111)]
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
}

//fragment functions

half4 Fragment(GeometryOutput input) : SV_Target
{
    float4 furColor = SAMPLE_TEXTURE2D(_FurMap, sampler_FurMap, input.uv2);

    //make the noise texture darker and thinner further ahead
    float4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
    float alpha = furColor.r * (1.0 - input.layer); //*baseColor.r; //would make darker areas shorter
    if (input.layer > 0.0 && alpha < _AlphaCutout) discard;

    //darken the roots
    float occlusion = lerp(1.0 - _Occlusion, 1.0, input.layer);
    float3 color = baseColor * occlusion;


    return float4(color, alpha);
}

void fragShadow(
    GeometryOutput input,
    out float4 outColor : SV_Target,
    out float outDepth : SV_Depth)
{
    float4 furColor = SAMPLE_TEXTURE2D(_FurMap, sampler_FurMap, input.uv2);
    float alpha = furColor.r * ( 1.0 - input.layer);
    if (input.layer > 0.0 && alpha < _AlphaCutout) discard;

    outColor = outDepth = input.vertex.z / input.vertex.w;
}

#endif
