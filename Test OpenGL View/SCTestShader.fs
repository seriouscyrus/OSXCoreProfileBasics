#version 150

in lowp vec4 vertex_color;

out vec4 colourout;

void main()
{
    colourout = vertex_color;
}