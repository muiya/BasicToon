Shader "Universal Render Pipeline/BasicToon"
{
	Properties{
			_MainTex("Texture", 2D) = "white" {}
			_RampTex("Ramp Texture", 2D) = "white" {}
			_Brightness("Brightness", Range(0, 1)) = 1

			[Toggle] _EnableHighlight("Enable Highlight", Float) = 1
		    [Toggle] _EnableSecondaryHighlight("Enable Secondary Highlight", Float) = 1

			_HighlightColor("Highlight Color", Color) = (1, 1, 1, 1 )
			_HighlightThreshold("Highlight Threshold", Range(0, 1)) = 0.5
			_SecondaryHighlightColor("Secondary Highlight Color", Color) = (1, 1, 1, 1)
			_SecondaryHighlightThreshold("Secondary Highlight Threshold", Range(0, 2)) = 0.75
	}

		SubShader{
		Tags { "RenderType" = "Opaque" }

		Pass {
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 vertex : SV_POSITION;
				
			};

			sampler2D _MainTex;
			sampler2D _RampTex;
			float _Brightness;
			float4 _HighlightColor;
			float _HighlightThreshold;
			float4 _SecondaryHighlightColor;
			float _SecondaryHighlightThreshold;
			float _EnableHighlight;
			float _EnableSecondaryHighlight;


			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				fixed3 albedo = c.rgb;
				fixed alpha = c.a;

				// Calculate view direction
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.vertex.xyz));

				// Calculate dot product between world normal and view direction
				float dotProduct = dot(i.worldNormal, viewDir);

				// Map dot product to toon shading ramp
				fixed4 rampColor = tex2D(_RampTex, float2(dotProduct, 0));

				// Apply ramp color and brightness to the output
				albedo *= rampColor.rgb;
				albedo *= _Brightness ;

				// Calculate primary highlight
				float primaryHighlight = smoothstep(_HighlightThreshold, 1, dotProduct);
				albedo += _EnableHighlight * _HighlightColor.rgb * primaryHighlight;

				// Calculate secondary highlight on the opposite side
				float secondaryDotProduct = -dotProduct;
				float secondaryHighlight = smoothstep(_SecondaryHighlightThreshold, 1, secondaryDotProduct);
				albedo += _EnableSecondaryHighlight * _SecondaryHighlightColor.rgb * secondaryHighlight;


				return fixed4(albedo, alpha);
			}
			
				ENDHLSL
			}
		}

		

		FallBack "Diffuse"
}
