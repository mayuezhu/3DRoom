#version 120


uniform sampler2D color_tex;
varying float NdotL;

void main()
{
	vec2 scale = vec2(30.0, 30.0);
	vec2 threshold = vec2(0.58, 0.35);
		
	float ss = fract(gl_TexCoord[0].s * scale.s);
	float tt = fract(gl_TexCoord[0].t * scale.t);
	
	if ((ss>threshold.s) && (tt>threshold.t)) discard;
    
    vec3 tex_color = texture2D(color_tex, gl_TexCoord[0].st).rgb;
		
	vec3 final_color = 1.2*NdotL*tex_color;
	
	gl_FragColor = vec4(final_color, 1.0);
}