Shader "Unlit/DottedTrailSegment"
{
    Properties
    {
        _DotColor("Dot Color", Color) = (1, 1, 1, 1)
        _BetweenDotsDistance("Between Dots Distance", Float) = 2.0
        _DotSpeed("Dot Speed", Float) = 1.0
        // Expected to be set by script with the local width/height of the current quad
        [HideInInspector]_AspectRatio("Aspect Ratio", Float) = 10.0
    }

    HLSLINCLUDE

    struct Attributes
    {
        float4 positionOS : POSITION;
        float2 uv         : TEXCOORD0;
    };

    struct Varyings
    {
        float4 positionHCS : SV_POSITION;
        float2 uv          : TEXCOORD1;
    };

    float circle(float2 uv, float radius)
    {
        float2 uvToCenter = uv - float2(0.5, 0.5);
        float distanceFromCenter = length(uvToCenter);
        // Subtracting 0.4999 instead of 0.5 resolves issues on values close to 0 along the
        // center of the trail between circles.
        return saturate(radius - radius * sign(distanceFromCenter - 0.4999));
    }

    float computeAlpha(float2 uv, float aspectRatio, float time, float speed, float betweenDotDistance)
    {
        float2 circleUV = uv;
        // This is needed to keep the circle aspect ratio
        circleUV.x *= aspectRatio;
        // Displace UV.x by time * speep to animate.
        // The Modulo operator repeats the UV.x to create multiple dots every desired distance.
        // Saturate to keep the space between the dots empty.
        circleUV.x = saturate((circleUV.x + time * speed) % betweenDotDistance);

        return circle(circleUV, 0.5);
    }

    ENDHLSL

    SubShader
    {
        PackageRequirements
        {
            "com.unity.render-pipelines.universal": "7.0"
        }

        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            // Basic transparent setup
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // SRP Batcher compatibility
            CBUFFER_START(UnityPerMaterial)
                half4 _DotColor;
                float _BetweenDotsDistance;
                float _DotSpeed;
                float _AspectRatio;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float alpha = computeAlpha(IN.uv, _AspectRatio, _Time.y, _DotSpeed, _BetweenDotsDistance);
                half4 resultColor = _DotColor;
                resultColor.a *= alpha;
                return resultColor;
            }
            
            ENDHLSL
        }
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            // Basic transparent setup
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            half4 _DotColor;
            float _BetweenDotsDistance;
            float _DotSpeed;
            float _AspectRatio;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = UnityObjectToClipPos(IN.positionOS);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float alpha = computeAlpha(IN.uv, _AspectRatio, _Time.y, _DotSpeed, _BetweenDotsDistance);
                half4 resultColor = _DotColor;
                resultColor.a *= alpha;
                return resultColor;
            }
            
            ENDHLSL
        }
    }
}
