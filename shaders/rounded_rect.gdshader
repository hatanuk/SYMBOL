shader_type canvas_item;
render_mode unshaded;

uniform vec2 size; //rect_size of panel passed on_ready
uniform sampler2D TEXTURE2 : hint_normal; //Image texture to use as background
uniform vec2 texture_size; //rect size of texture (to scale texture)
uniform vec2 transform; // x,y transform to clip to areas of texture
uniform float radius : hint_range(0.0,0.5); // corner radius to apply to panel, will apply as percentage of shortest x/y length

void fragment()
{
    float yx_ratio = size.y/size.x;
    float xy_ratio = size.x/size.y;
    float grow = max(yx_ratio,xy_ratio);
    float shrink = min(yx_ratio,xy_ratio);
    ivec2 img_size = textureSize(TEXTURE2,0);
    float img_xratio = texture_size.x/size.x;
    float img_yratio = texture_size.y/size.y;
    float tfm_xratio = transform.x/size.x;
    float tfm_yratio = transform.y/size.y;
    COLOR.rgb = texture(TEXTURE2,vec2((UV.x/img_xratio)+tfm_xratio,(UV.y/img_yratio)+tfm_yratio)).rgb;
    vec2 top_left = vec2(radius,radius*shrink);
    vec2 top_right = vec2(1.0-radius,radius*shrink);
    vec2 bottom_left = vec2(radius,1.0-(radius*shrink));
    vec2 bottom_right = vec2(1.0-radius,1.0-(radius*shrink));

    if (UV.x <= top_left.x && UV.y <= top_left.y){
         if (!(distance(vec2(UV.x,UV.y*grow),vec2(top_left.x,top_left.y*grow))<radius)){
            COLOR.a = 0.0;
        }
    }
    if (UV.x>=top_right.x &&  UV.y <= top_right.y){
         if (!(distance(vec2(UV.x,UV.y*grow),vec2(top_right.x,top_right.y*grow))<radius)){
            COLOR.a = 0.0;
        }
    }
    if (UV.x<=bottom_left.x && UV.y>=bottom_left.y){
         if (!(distance(vec2(UV.x,UV.y*grow),vec2(bottom_left.x,bottom_left.y*grow))<radius)){
        COLOR.a = 0.0;
        }
    }
    if (UV.x>=bottom_right.x && UV.y>=bottom_right.y){
         if (!(distance(vec2(UV.x,UV.y*grow),vec2(bottom_right.x,bottom_right.y*grow))<radius)){
        COLOR.a = 0.0;
        }
    }
}