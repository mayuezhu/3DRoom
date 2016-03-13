#version 120

varying float  NdotL;
	
void main()
{
	// Vertex position in eye coords
	vec3 ec_position = vec3(gl_ModelViewMatrix * gl_Vertex);

	// Transform normal into eye space
	vec3 tnorm = normalize(gl_NormalMatrix * gl_Normal);
	vec3 light_dir = normalize(gl_LightSource[0].position.xyz - ec_position);
		
    // want to show back-facing too so NdotL always positive
    NdotL = abs(dot(tnorm, light_dir));
    
    // add an ambient component to NdotL (don't let it go to 0)
    NdotL = max(NdotL, 0.3);

	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_Position = ftransform(); 
} 


