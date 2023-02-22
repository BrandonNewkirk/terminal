// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

#include "dwrite.hlsl"
#include "shader_common.hlsl"

cbuffer ConstBuffer : register(b0)
{
    float4 positionScale;
    float4 gammaRatios;
    float enhancedContrast;
    float dashedLineLength;
}

Texture2D<float4> glyphAtlas : register(t0);

// clang-format off
float4 main(PSData data) : SV_Target
// clang-format on
{
    switch (data.shadingType)
    {
    case SHADING_TYPE_TEXT:
    {
        float4 foreground = premultiplyColor(data.color);
        float4 glyphColor = glyphAtlas[data.texcoord];
        float blendEnhancedContrast = DWrite_ApplyLightOnDarkContrastAdjustment(enhancedContrast, data.color.rgb);
        float intensity = DWrite_CalcColorIntensity(data.color.rgb);
        float contrasted = DWrite_EnhanceContrast(glyphColor.a, blendEnhancedContrast);
        float alphaCorrected = DWrite_ApplyAlphaCorrection(contrasted, intensity, gammaRatios);
        return alphaCorrected * foreground;
    }
    case SHADING_TYPE_TEXT_PASSTHROUGH:
    {
        return glyphAtlas[data.texcoord];
    }
    case SHADING_TYPE_DASHED_LINE:
    {
        bool on = frac(data.position.x / dashedLineLength) < 0.333333333f;
        return on * premultiplyColor(data.color);
    }
    case SHADING_TYPE_SOLID_FILL:
    default:
    {
        return premultiplyColor(data.color);
    }
    }
}
