shader_type canvas_item;

const float EDGE = 0.4;
const float STEP = 3.0;
//MEH
void vertex() {
}

void fragment() {
	vec2 dist = abs(UV-vec2(0.5));
	float darkness_factor = (max(dist.x,dist.y)-EDGE)*(STEP+1.0)/(0.5-EDGE);
	COLOR-=vec4(vec3(0),floor(darkness_factor)*1.0/(STEP+1.0));
	//COLOR=vec4(vec3(darkness_factor),1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
