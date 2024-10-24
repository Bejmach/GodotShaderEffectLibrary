vec3 rgbToHsv(vec3 rgb){
	float R = rgb.r;
	float G = rgb.g;
	float B = rgb.b;

	float Cmax = max(max(R, G), B);
	float Cmin = min(min(R, G), B);
	float delta = Cmax-Cmin;

	float H;
	if(abs(delta) < 0.0001){
		H = 0.0;
	}else if(abs(Cmax - R) < 0.0001){
		H = 60.0*(mod((G-B)/delta, 6));
	}else if(abs(Cmax - G) < 0.0001){
		H = 60.0*((B-R)/delta+2.0);
	}else if(abs(Cmax - B) < 0.0001){
		H = 60.0*((R-G)/delta+4.0);
	}
	float S;
	if(abs(Cmax) < 0.0001){
		S = 0.0;
	}else{
		S = delta/Cmax;
	}
	float V = Cmax;
	return vec3(H,S,V);
}
vec3 hsvToRgb(vec3 hsv){
	float C = hsv.z * hsv.y;
	float X = C*(1.0-abs(mod(hsv.x/60.0, 2) - 1.0));
	float m = hsv.z - C;
	vec3 rgbT;
	if(hsv.x >= 0.0 && hsv.x < 60.0){
		rgbT = vec3(C, X, 0);
	}else if(hsv.x >=60.0 && hsv.x < 120.0){
		rgbT = vec3(X, C, 0);
	}else if(hsv.x >=120.0 && hsv.x < 180.0){
		rgbT = vec3(0, C, X);
	}else if(hsv.x >= 180.0 && hsv.x < 240.0){
		rgbT = vec3(0, X, C);
	}else if(hsv.x >= 240.0 && hsv.x < 300.0){
		rgbT = vec3(X, 0, C);
	}else if(hsv.x >= 300.0 && hsv.x < 360.0){
		rgbT = vec3(C, 0, X);
	}
	return vec3((rgbT.r+m), (rgbT.g+m), (rgbT.b+m));
}
float linearDepth(float depth, vec2 screen_uv, float inv_prodection_matrix){
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 view = inv_prodection_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}
vec3 chromaticAberration(sampler2D screen_texture, vec2 uv, vec3 rgbDissplacement, float efectiveDistance, float screenTrim){
	float len = clamp(length(vec2(0.5)-uv), efectiveDistance, 1)-efectiveDistance;

	vec2 dirToMiddle = vec2(0.5)-uv;

	vec2 fixedUV = uv+dirToMiddle*screenTrim;

	float R = texture(screen_texture, fixedUV+((fixedUV-vec2(0.5))*rgbDissplacement.r*len)).r;
	float G = texture(screen_texture, fixedUV+((fixedUV-vec2(0.5))*rgbDissplacement.g*len)).g;
	float B = texture(screen_texture, fixedUV+((fixedUV-vec2(0.5))*rgbDissplacement.b*len)).b;

	return vec3(R, G, B);
}
vec3 quantization(vec3 rgb, float scale,bool hue, bool saturation, bool value){
	vec3 hsv = rgbToHsv(rgb);
	if(value){
		hsv.z = floor(hsv.z*scale)/scale;
	}
	if(saturation){
		hsv.y = floor(hsv.y*scale)/scale;
	}
	if(hue){
		hsv.x = floor(hsv.x/360.0*scale)*360.0/scale;
	}
	return hsvToRgb(hsv);
}
vec3 blur(vec2 viewport_size, sampler2D screen_texture, vec2 screen_uv, int scale, int precision){
	vec2 pixelSize = 1.0/viewport_size;
	vec3 averageColor = vec3(0);
	for(int y = -scale/precision; y<=scale/precision; y++){
		for(int x=-scale/precision;x<=scale/precision;x++){
			averageColor+=texture(screen_texture, screen_uv+pixelSize*vec2(float(x*precision), float(y*precision))).xyz;
		}
	}
	return averageColor/pow(1.0+float(scale/precision)*2.0, 2);
}
float grayscale(vec3 rgb){
	return (rgb.r+rgb.g+rgb.b)/3.0;
}

vec3 differenceOfGaussian(vec2 viewport_size, sampler2D screen_texture, vec2 screen_uv, int scale_less, int scale_more){
	vec3 color1 = vec3(grayscale(blur(viewport_size, screen_texture, screen_uv, scale_less, 1)));
	vec3 color2 = vec3(grayscale(blur(viewport_size, screen_texture, screen_uv, scale_more, 1)));
	return color1 - color2;
}

vec3 sobelFilter(vec2 viewport_size, sampler2D screen_texture, vec2 screen_uv, int size){
	vec2 pixelSize = 1.0/viewport_size;
	float matrix_horizontal[9] = float[9](-255.0, -510.0, -255.0, 0.0, 0.0, 0.0, 255.0, 510.0, 255.0);
	float matrix_vertical[9] = float[9](-255.0, 0.0, 255.0, -510.0, 0.0, 510.0, -255.0, 0.0, 255.0);
	
	float Gx = 0.0;
	float Gy = 0.0;
	for(int i=0; i<9; i++){
		int x = (i%3)-1;
		int y = (i/3)-1;
		float gray = grayscale(texture(screen_texture, screen_uv+pixelSize*vec2(float(x), float(y))*float(size)).rgb);
		Gx+= matrix_horizontal[i]*gray;
		Gy+= matrix_vertical[i]*gray;
	}
	float magnitude = sqrt((pow(Gx, 2)+pow(Gy, 2)));
	return vec3(magnitude/1020.0);
}