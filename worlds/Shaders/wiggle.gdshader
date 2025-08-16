shader_type canvas_item;
uniform float amplitude = 10.0;
uniform float prog = 1.0;

void vertex() {
	float secondaryProg = sin(TIME) * 2.0;
	vec2 displacement = vec2(sin(prog + TIME * 2.0) * amplitude / 2.0, cos(prog + secondaryProg) * amplitude * 2.0) * secondaryProg;
	VERTEX += displacement;
}