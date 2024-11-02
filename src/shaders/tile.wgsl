struct VertexInput {
    @location(0) vertex_pos: vec2<u32>,
    @location(1) instance_pos: vec2<u32>,
    @location(2) kind: u32,
}

struct Screen {
    size: vec2<u32>, // [width, height]
}

@group(0) @binding(0)
var<uniform> screen: Screen;

struct Camera {
    position: vec2<u32>,
}

@group(1) @binding(0)
var<uniform> camera: Camera;

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) kind: u32,
    @location(1) instance_pos: vec2<u32>,
}

fn to_ndc(pixels: u32, physical_size: u32) -> f32 {
    return f32(pixels) / f32(physical_size) * 2.0 - 1.0;
}

@vertex
fn vs_main(in: VertexInput) -> VertexOutput {
    var out: VertexOutput;

    let pos = in.vertex_pos + in.instance_pos;
    let x = to_ndc(pos.x, screen.size.x);
    let y = to_ndc(pos.y, screen.size.y);
    out.position = vec4<f32>(x, y, 0.0, 1.0);

    out.kind = in.kind;
    out.instance_pos = in.instance_pos;

    return out;
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    let USER_COLOR = vec4<f32>(0.74, 0.21, 0.33, 1.0);

    var COLORS: array<vec4<f32>, 2> = array<vec4<f32>, 2>(
        vec4<f32>(0.0, 0.8, 0.0, 1.0), // Grass
        vec4<f32>(0.0, 0.4, 0.58, 1.0), // Water 
    );

    var color = COLORS[in.kind];

    let is_camera_x = (camera.position.x * 16) == in.instance_pos.x;
    let is_camera_y = (camera.position.y * 16) == in.instance_pos.y;
    let is_camera = is_camera_x && is_camera_y;

    if is_camera {
        color = USER_COLOR;
    }

    return color;
}
