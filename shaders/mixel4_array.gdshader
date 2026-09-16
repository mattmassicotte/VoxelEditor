shader_type spatial;

uniform sampler2DArray u_albedo_array : source_color;

varying vec3 v_world_pos;
varying vec4 v_material_indices;
varying vec4 v_material_weights;

// From Voxel Tools API
uniform int u_transition_mask;

float get_transvoxel_secondary_factor(int idata) {
	int transition_mask = u_transition_mask & 0xff;

	int cell_border_mask = idata & 63; // Which sides the cell is touching
	int vertex_border_mask = (idata >> 8) & 63; // Which sides the vertex is touching
	// If the vertex is near a side where there is a low-resolution neighbor,
	// move it to secondary position
	int m = transition_mask & cell_border_mask;
	float t = float(m != 0);
	// If the vertex lies on one or more sides, and at least one side has no low-resolution neighbor,
	// don't move the vertex.
	t *= float((vertex_border_mask & ~transition_mask) == 0);
	
	// Debugging
	//t *= 0.5 + 0.5 * sin(TIME * 4.0);
	//t *= 2.0;

	return t;
}

vec3 get_transvoxel_position(vec3 vertex_pos, vec4 fdata) {
	int idata = floatBitsToInt(fdata.a);

	// Move vertices to smooth transitions
	float secondary_factor = get_transvoxel_secondary_factor(idata);
	vec3 secondary_position = fdata.xyz;
	vec3 pos = mix(vertex_pos, secondary_position, secondary_factor);

	// If the mesh combines transitions and the vertex belongs to a transition,
	// when that transition isn't active we change the position of the vertices so
	// all triangles will be degenerate and won't be visible.
	// This is an alternative to rendering them separately,
	// which has less draw calls and less mesh resources to create in Godot.
	// Ideally I would tweak the index buffer like LOD does but Godot does not
	// expose anything to use it that way.
	int itransition = (idata >> 16) & 0xff; // Is the vertex on a transition mesh?
	float transition_cull = float(itransition == 0 || (itransition & u_transition_mask) != 0);
	pos *= transition_cull;

	return pos;
}

vec4 decode_8bit_vec4(float v) {
    uint i = floatBitsToUint(v);
    return vec4(
        float(i & uint(0xff)),
        float((i >> uint(8)) & uint(0xff)),
        float((i >> uint(16)) & uint(0xff)),
        float((i >> uint(24)) & uint(0xff)));
}

vec3 get_triplanar_blend(vec3 world_normal, float sharpness) {
	// TODO `pow` is an expensive function, maybe there should be an alternative
	vec3 blending = pow(abs(world_normal), vec3(sharpness));
	return blending / (blending.x + blending.y + blending.z);
}

vec4 texture_triplanar(sampler2D tex, vec3 world_pos, vec3 blend) {
	vec4 xaxis = texture(tex, world_pos.yz);
	vec4 yaxis = texture(tex, world_pos.xz);
	vec4 zaxis = texture(tex, world_pos.xy);
	// blend the results of the 3 planar projections.
	return xaxis * blend.x + yaxis * blend.y + zaxis * blend.z;
}

vec4 texture_array_triplanar(sampler2DArray tex, vec3 world_pos, vec3 blend, float i) {
    vec4 xaxis = texture(tex, vec3(world_pos.yz, i));
    vec4 yaxis = texture(tex, vec3(world_pos.xz, i));
    vec4 zaxis = texture(tex, vec3(world_pos.xy, i));
    // blend the results of the 3 planar projections.
    return xaxis * blend.x + yaxis * blend.y + zaxis * blend.z;
}

void vertex() {
	VERTEX = get_transvoxel_position(VERTEX, CUSTOM0);

	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Indices are integer values so we can decode them as-is
    v_material_indices = decode_8bit_vec4(CUSTOM1.x);

    // Weights must be in [0..1] so we divide them
    v_material_weights = decode_8bit_vec4(CUSTOM1.y) / 255.0;
}

void fragment() {
	vec3 normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;

    // Define a texture scale for convenience.
    // We can use an array instead if different scales per index is needed.
    float uv_scale = 1.0;

	vec3 wpos = v_world_pos * uv_scale;

    // Sample the 4 blending textures, all with triplanar mapping.
    // We can re-use the same triplanar blending factors for all of them so separating that part
    // of the function improves performance a little.
    vec3 blending = get_triplanar_blend(normal, 1.0);
    vec3 col0 = texture_array_triplanar(u_albedo_array, wpos, blending, v_material_indices.x).rgb;
    vec3 col1 = texture_array_triplanar(u_albedo_array, wpos, blending, v_material_indices.y).rgb;
    vec3 col2 = texture_array_triplanar(u_albedo_array, wpos, blending, v_material_indices.z).rgb;
    vec3 col3 = texture_array_triplanar(u_albedo_array, wpos, blending, v_material_indices.w).rgb;

    // Get weights and make sure they are normalized.
    // We may add a tiny safety margin so we can afford some degree of error.
    vec4 weights = v_material_weights;
    weights /= (weights.x + weights.y + weights.z + weights.w + 0.00001);

    // Calculate albedo
    vec3 col =
        col0 * weights.r +
        col1 * weights.g +
        col2 * weights.b +
        col3 * weights.a;

    ALBEDO = col;
}
