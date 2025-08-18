shader_type canvas_item;

uniform float progress;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (UV.y < progress) {
		COLOR.rgb *= 0.5;
	}
}