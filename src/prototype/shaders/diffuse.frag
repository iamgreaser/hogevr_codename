in vec4 v_normal;
in vec4 v_world_pos;

const vec4 light_world_pos = vec4(0.0, 5.0, 0.0, 1.0);

vec4 lovrmain() {
   vec4 c = Color * getPixel(ColorTexture, UV);
   float diffuse = max(0.0, dot(normalize(v_normal), normalize(light_world_pos - v_world_pos)));
   diffuse = 0.1 + (1.0 - 0.1) * diffuse;
   return vec4(c.rgb * diffuse, c.a);
}
