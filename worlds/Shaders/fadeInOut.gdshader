shader_type canvas_item;

void vertex() {
	float pulse = (sin(TIME * 2.0) + 1.0) * 0.5; // 0 ~ 1
	pulse = pulse / 8.0 * 6.0; // 0 ~ 0.75
	pulse = pulse + (1.0 / 8.0); // 0.125 ~ 0.875
	pulse += 0.125; // 0.25 ~ 1
	float scale = mix(0.25, 1.0, pulse);
    VERTEX *= scale;
}

//void fragment() {
	//COLOR.a *= (sin(TIME * 2.0) + 1.0) * 0.5;
//}