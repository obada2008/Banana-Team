shader_type canvas_item;

uniform vec3 dash_color: source_color;  // ダッシュ時のカラー設定（RGB）

void fragment() {
	COLOR.rgb = dash_color;  // ピクセルの色をdash_colorに設定
}
