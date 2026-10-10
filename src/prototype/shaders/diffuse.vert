out vec4 v_normal;
out vec4 v_world_pos;

vec4 lovrmain() {
   v_normal = vec4(NormalMatrix * VertexNormal, 0.0);
   v_world_pos = Transform * VertexPosition;
   return Projection * View * Transform * VertexPosition;
}
