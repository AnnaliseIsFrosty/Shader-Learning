#define USE_LIGHTING

float _Gloss;
sampler2D _RockAlbedo;
float4 _RockAlbedo_ST;
sampler2D _RockNormalMap;
float4 _RockNormalMap_ST;
float _RockNormalIntensity;
sampler2D _RockHeightMap;
float4 _RockHeightMap_ST;
float _RockHeightIntensity;
float4 _AmbientLight;

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 normal : TEXCOORD1;
    float3 wPos : TEXCOORD2;
    float3 tangent : TEXCOORD3;
    float3 bitangent : TEXCOORD4;
    LIGHTING_COORDS(5, 6)
};


v2f vert(appdata v)
{
    v2f o;
    
    o.uv = TRANSFORM_TEX(v.uv, _RockAlbedo);

    float height = tex2Dlod(_RockHeightMap, float4(o.uv, 0, 0)).x * 2 - 1;
    v.vertex.xyz += v.normal * height * _RockHeightIntensity;

    o.vertex = UnityObjectToClipPos(v.vertex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
    o.bitangent = cross(o.normal, o.tangent) * (v.tangent.w * unity_WorldTransformParams.w);
    TRANSFER_VERTEX_TO_FRAGMENT(o); // populates interpolators with info it needs to calculate light info
    return o;
}

float4 frag(v2f i) : SV_Target
{
    float3 rock = tex2D(_RockAlbedo, i.uv).rgb;
    
    float3 tangentSpaceNormal = UnpackNormal(tex2D(_RockNormalMap, i.uv));
    tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _RockNormalIntensity));
    float3x3 matTangToWorld =
    {
        i.tangent.x, i.bitangent.x, i.normal.x,
        i.tangent.y, i.bitangent.y, i.normal.y,
        i.tangent.z, i.bitangent.z, i.normal.z
    };
    
    i.normal = mul(matTangToWorld, tangentSpaceNormal);
    
    //i.normal = normalize(i.normal); // Normalize all interpolated normals to smooth out specular light

                // Diffuse Lighting
    float3 lightVec = normalize(UnityWorldSpaceLightDir(i.wPos));
    float attenuation = LIGHT_ATTENUATION(i);
    float3 lambert = clamp(dot(i.normal, lightVec), 0, 1);
    float3 diffuseLight = lambert * attenuation * _LightColor0.xyz;

    #ifdef IN_BASE
        diffuseLight += _AmbientLight;
    #endif

                // Specular Lighting
    float3 camVec = normalize(_WorldSpaceCameraPos - i.wPos);
                            // Used for Phong lighting
                            //float3 reflectionVec = reflect(-lightVec, i.normal);
                            //float specularLight = clamp(dot(camVec, reflectionVec), 0, 1);

                // Blinn-Phong lighting
    float3 halfVec = normalize(lightVec + camVec);
    float3 specularLight = clamp(dot(i.normal, halfVec), 0, 1) * (lambert > 0);

    float specularExponent = exp2(_Gloss * 6) + 1;
    specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation; // multiply by gloss to keep an illusion of energy conservation
    specularLight *= _LightColor0.xyz;
    
    //return float4(attenuation.xxx, 1);
    return float4(diffuseLight * rock + specularLight, 1);
}