shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.);
uniform float thickness : hint_range(0.1, 1.) = .4;
uniform float ratio : hint_range(0., 1.) = .5;
uniform vec4 segment_color : source_color = vec4(1., .886, .412, 1.);
uniform int segment_count : hint_range(1, 12, 1) = 1;
uniform int segment_selected : hint_range(0, 12, 1) = 0;

// "Ring - exact" signed distance function - https://iquilezles.org/articles/distfunctions2d/
float sdRing( in vec2 p, in vec2 n, in float r, float th )
{
    p.x = abs(p.x);
    p = mat2(vec2(n.x, n.y), vec2(-n.y, n.x)) * p;
    return max( abs(length(p)-r)-th*0.5,
                length(vec2(p.x,max(0.0,abs(r-p.y)-th*0.5)))*sign(p.x) );
}

// Fragment Rotation - https://gist.github.com/ayamflow/c06bc0c8a64f985dd431bd0ac5b557cd
vec2 rotateUV(vec2 uv, vec2 pivot, vec2 amount) {
	return vec2(
	    cos(amount.x) * (uv.x - pivot.x) + sin(amount.x) * (uv.y - pivot.y) + pivot.x,
	    cos(amount.y) * (uv.y - pivot.y) - sin(amount.y) * (uv.x - pivot.x) + pivot.y
	);
}

void fragment() {
	float t = PI * ratio;
	vec2 cs = vec2(cos(t), sin(t));
    const float outer_radius = 0.5;
	
	// Cut out everything not in our ring
	float ring_sdf = sdRing(vec2(UV.x, 1. - UV.y) * 2.0 - vec2(1.), cs, outer_radius, thickness);
	// Smoothstep to give rounded corners
	COLOR.a = smoothstep(0.035, 0.03, ring_sdf) * color.a;

	if (segment_selected == 0) {
		COLOR.rgb = color.rgb;
	} else {
		// Calculate how much to rotate our segment UV so the segment shows in the
		// correct spot on the circle
		float segment_rotation = 
			// ratio% counter clickwise from top
			PI * ratio                               
			// half a segment's worth clockwise
			- (PI * ratio / float(segment_count))
			// 'segment_count-1' x clockwise
			- (PI * ratio / float(segment_count) * 2. * float(segment_selected - 1));
		
		// Only highlight 1 segment's worth
		t /= float(segment_count);
		cs = vec2(cos(t), sin(t));
		vec2 uv = rotateUV(UV, vec2(.5), -vec2(segment_rotation));
		float segment_sdf = sdRing(vec2(uv.x, 1. - uv.y) * 2.0 - vec2(1.), cs, outer_radius, thickness);
		
		float mix_amount = smoothstep(0.045, 0.04, segment_sdf);
		
		COLOR.rgb = mix(color.rgb, segment_color.rgb, mix_amount);
		COLOR.a = mix(COLOR.a, segment_color.a, mix_amount);
	}
}