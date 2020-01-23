#version 330
#extension GL_ARB_separate_shader_objects : enable

layout(location=1) in vec2 texVp;
layout(location=0) out vec4 target;

uniform ivec2 screenCenter;
// x = bar time
// y = off-sync but smooth bpm based timing
// z = real time since song start
uniform vec3 timing;
uniform ivec2 viewport;
uniform float objectGlow;
// bg_texture.png
uniform sampler2D bgTex;
uniform sampler2D centerClearTex;
uniform sampler2D centerFailTex;
uniform sampler2D fgTex;
uniform sampler2D particlesTex;
uniform sampler2D ringTex;
uniform sampler2D sidesClearTex;
uniform sampler2D sidesFailTex;

uniform vec2 tilt;
uniform float clearTransition;

#define HALF_PI 1.570796326794
#define PI 3.14159265359
#define TWO_PI 6.28318530718

//STRUCTS
struct particleSprite{
	float offset;
	vec4 color;
	float size;
	float angle;
};



vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 rotate_point(vec2 cen,float angle,vec2 p)
{
  float s = sin(angle);
  float c = cos(angle);

  // translate point back to origin:
  p.x -= cen.x;
  p.y -= cen.y;

  // rotate point
  float xnew = p.x * c - p.y * s;
  float ynew = p.x * s + p.y * c;

  // translate point back:
  p.x = xnew + cen.x;
  p.y = ynew + cen.y;
  return p;
}


// Reference to
// https://github.com/Ikeiwa/USC-SDVX-IV-Skin  (ikeiwa)
// http://thndl.com/square-shaped-shaders.html
// https://thebookofshaders.com/07/

float portrait(float a, float b)
{
	float resu;
	if (viewport.y > viewport.x)
	{
	 resu = a;
	}
	else{
	 resu = b;
	}
	
	return resu;
}

float GetDistanceShape(vec2 st, int N){
    vec3 color = vec3(0.0);
    float d = 0.0;

    // Angle and radius from the current pixel
    float a = atan(st.x,st.y)+PI;
    float r = TWO_PI/float(N);

    // Shaping function that modulate the distance
    d = cos(floor(.5+a/r)*r-a)*length(st);

    return d;

}

float mirrored(float v) {
    float m = mod(v, 2.0);
    return mix(m, 2.0 - m, step(1.0, m));
}

vec2 ScaleUV(vec2 uv,float scale,vec2 pivot){
	return (uv - pivot) * scale + pivot;
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec2 rotate2d(vec2 uv,float _angle, vec2 pivot){
    return (uv - pivot) * mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle)) + pivot;
}


// Number of sides of your shape
int N = 4;

// "Stretch" | lower = "Stretchier"
float Stretch = .15;

// Speed
float speed = 1;

// Default rotation in radians
float BaseRotation = 0.0;

// Rotation of texture for alignment, in radians
float BaseTexRotation = 0.0;

// Scale
vec2 Scale = vec2(portrait(0.5,0.625), 0.75);

float nbParticles = 3;

particleSprite partSprites[5] = particleSprite[5](
	particleSprite(0,vec4(0.611,1,0.46,1),1,0),
	particleSprite(0,vec4(0.95,1,0.48,1),1,0),
	particleSprite(0,vec4(1,0.48,0.75,1),1,0),
	particleSprite(0.3333,vec4(1,1,1,1),1,0),
	particleSprite(0.6666,vec4(1,1,1,1),1,0)
);

void main()
{
    float ar = float(viewport.x) / float(viewport.y);
	float var = float(viewport.y) / float(viewport.x);

	vec2 screenUV = vec2(texVp.x / viewport.x, texVp.y / viewport.y);

	vec2 uv = screenUV;
    uv.x *= ar;

    vec2 center = vec2(screenCenter) / vec2(viewport);
    center.x *= ar;

    vec2 point = uv;
	float bgrot = dot(tilt, vec2(0.5, 1.0));
    point = rotate_point(center, BaseRotation + (bgrot * TWO_PI), point);
    vec2 point_diff = center - point;
    point_diff /= Scale;
    float diff = GetDistanceShape(point_diff,N);
    float thing2 = Stretch / diff;
	float fog = -1. / (diff * 10. * Scale.x) + 1.;
    fog = clamp(fog, 0, 1);
    float texY = thing2;
    texY += timing.y * speed;


	//CENTERED UV CALCULATION
	
	vec2 trackEndCenter = center;
	trackEndCenter.x *= var;

	vec2 centerUV = trackEndCenter - screenUV;
	centerUV *= -1.0;
	centerUV.x *= ar;
	centerUV += 0.5;

	//END TRACK END TEXTURE

	centerUV = ScaleUV(centerUV,4,vec2(0.5));
	
	centerUV = ScaleUV(centerUV,1/ (1-sin(clearTransition*PI)),vec2(0.5));
	
	centerUV = clamp(centerUV,0,1);

	vec2 centerTexUV = rotate_point(vec2(0.5), BaseRotation + (bgrot * TWO_PI) + (clearTransition*TWO_PI) , centerUV);
	centerTexUV = clamp(centerTexUV,0,1);
	vec4 centerCol = texture(centerFailTex, centerTexUV);
	vec4 centerColClear = texture(centerClearTex, centerTexUV);
	
	centerCol = mix(centerCol,centerColClear,clearTransition);

	//PARTICLES UV PRE-CALCULATION
	vec2 particlesUV = point;
	particlesUV.x = center.x - particlesUV.x;
	
	particlesUV.x = mirrored(clamp(particlesUV.x,-1.0,1.0));

	//PARTICLES
	vec4 particles = vec4(0.0,0.0,0.0,0.0);
    float particlesTime = timing.z * 2.0;
	
	float spriteOffset = 1 /nbParticles;
	vec2 spriteScale = vec2(spriteOffset,1);

	for(int i=0;i<3;++i){
        float timeOffset = 1.0 / float(i);
		float particleSpawnTime = floor(particlesTime - timeOffset);
		float particleTime = (particlesTime - timeOffset) - particleSpawnTime;

        float rnd = rand(vec2(i,particleSpawnTime));
        float rnd2 = rand(vec2(particleSpawnTime,i));

        vec2 offset = vec2(rnd2*-0.4,rnd*0.4 + portrait(0.125,0.345));

        int spriteIndex = int(floor(rnd*(partSprites.length()-1)));

        vec2 particleUV = ScaleUV(particlesUV,(1.0-particleTime)*10.0,vec2(0.0,center.y));
        particleUV += offset;
		particleUV = ScaleUV(particleUV,2 * partSprites[spriteIndex].size,vec2(0.5));
    	particleUV = clamp(particleUV,0.0,1.0);

		vec4 particle = texture(particlesTex, (particleUV * spriteScale) + vec2(partSprites[spriteIndex].offset,0)) * partSprites[spriteIndex].color;
		particle.a *= min(particleTime*2.0,1.0);
		//vec4 particle1 = texture(particlesTex, particleUV+particleOffset + vec2(spriteIndex+0.3333*2,0.0)).rgba * min(particleTime*2.0,1.0);
		particles = mix(particles,particle,particle.a);
	}

	//END PARTICLES

    float rot = (atan(point_diff.x,point_diff.y) + BaseTexRotation) / TWO_PI;

	vec2 sidesUV = vec2((rot*-1)-0.375,mod(texY,1));

    vec4 col = texture(sidesFailTex, sidesUV);
    vec4 clear_col = texture(sidesClearTex, sidesUV);

    col.rgb = mix(col,clear_col,clearTransition).rgb;
    target.rgb = col.rgb * 2.0;
    target.a = col.a * fog;
	
	
	//BACKGROUND1
	centerUV = screenUV;
	centerUV.x -= 0.5;
	centerUV.y -= portrait(0.1,-0.67);
	centerUV.x *= ar;
	centerUV /= 1.2;
	centerUV /= ar;
	centerUV.x += 0.5;
	centerUV = clamp(centerUV,0.0,1.0);
	
	centerTexUV = rotate_point(vec2(0.5), clamp(BaseRotation + (bgrot * PI),-360,360) , centerUV);
	
	vec3 bgcol = texture(bgTex, centerTexUV).rgb;
	
	//BACKGROUND2
	centerUV = screenUV;
	centerUV.x -= 0.5;
	centerUV.y -= portrait(0.1,-0.67)+sin(timing.z) * 0.006;
	centerUV.x *= ar;
	centerUV /= 1.2;
	centerUV /= ar;
	centerUV.x += 0.5;
	centerUV = clamp(centerUV,0.0,1.0);
	
	centerTexUV = rotate_point(vec2(0.5), clamp(BaseRotation + (bgrot * TWO_PI),-360,360) , centerUV);
	
	float clear_bright = 0.9 + timing.y * 0.14;
	
	vec4 bgcolClear = texture(fgTex, centerTexUV);
	
	
	target.rgb = bgcol + target.rgb * target.a;
	target.rgb = mix(target.rgb,bgcolClear.rgb,bgcolClear.a * clear_bright);
	target.rgb = mix(target.rgb,centerCol.rgb,centerCol.a);
	target.rgb = mix(target.rgb,particles.rgb,particles.a);

	target.a = 1.0;
}

//Edited by Halo ID