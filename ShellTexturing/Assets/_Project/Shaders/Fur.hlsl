#ifndef FUR_HLSL
#define FUR_HLSL

#include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"

int _ShellAmount;
float _ShellStep;
float _AlphaCutout;

Texture2D _FurMap;
SAMPLER(sampler_FurMap);
float4 _FurMap_ST;

struct Attributes
{
    float4 positionOS : POSITION;
    //the colon position syntax just tells the shader to fill my float4 positionOS with the position data of the shader
    float3 normalOS : NORMAL; //same for normal etc
    float4 tangentOS: TANGENT;
    //https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-writing-shaders-9#varying-shader-inputs-and-semantics
    float2 uv: TEXCOORD0; //see the direct3d 9 documentation above for an explaination
};

struct Varyings
{
    float4 vertex: SV_POSITION;
    //sv= system value -> system value position -> is the pixels screen space coordinates! or is it clip space? ought to be CS, its SS in a pixel shader
    float2 uv : TEXCOORD0; //base uv
    float2 uv2 : TEXCOORD1; //fur uv
    float fogCoord : TEXCOORD2;
    float layer : TEXCOORD3; //the fourth set of texture coordinates of a vertex
};

Attributes vert(Attributes input)
{
    return input;
}

void AppendShellVertex(inout TriangleStream<Varyings> stream, Attributes input, int index)
{
    Varyings output = (Varyings)0;
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    float posWS = vertexInput.positionWS + normalInput.normalWS * (_ShellStep * index);
    //calculate the shells vertex worldpos
    float4 posCS = TransformWorldToHClip(posWS);
    //clip-space -> middle part between view space and screen space
    //view space -> clip-space = its like looking out of a window. can see things depending on my perspective, some things are clipped
    // clip-space -> screen-space = the clipped space is translated to pixels on the screen
    output.vertex = posCS;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.uv2 = TRANSFORM_TEX(input.uv, _FurMap);
    output.fogCoord = ComputeFogFactor(posCS.z);
    output.layer = (float)index / _ShellAmount;
    stream.Append(output);
}

[maxvertexcount(96)] //how many vertices this shader will end with
void geom(triangle Attributes input[3], inout TriangleStream<Varyings> stream)
{
    //[loop] and [unroll] tell the hlsl compiler to either keep the for a loop or to unroll it and make x statements out of it
    [loop] for (float i = 0; i < _ShellAmount; ++i)
    {
        [unroll] for (float j = 0; j < 3; ++j)
        {
            AppendShellVertex(stream, input[j], i);
        }
        stream.RestartStrip();
    }
}

float4 frag(Varyings input) : SV_Target
{
    float4 furColor = SAMPLE_TEXTURE2D(_FurMap, sampler_FurMap, input.uv2);
    if (input.layer > 0.0 && furColor.r > _AlphaCutout) discard; //discard stops the operation of the fragment
    float4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    float3 color = baseColor;
    color = MixFog(color, input.fogCoord);
    return float4(color, 1.0);
}
#endif
