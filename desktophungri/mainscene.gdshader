shader_type canvas_item;

uniform float hihi = 1.0f;

void fragment() {
	COLOR = texture(TEXTURE,UV);
	COLOR.b += hihi;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
