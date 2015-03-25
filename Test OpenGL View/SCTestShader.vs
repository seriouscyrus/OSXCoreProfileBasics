#version 150

in vec4 position;
in vec4 color;

uniform mat4 mvpMatrix;

out vec4 vertex_color;

void main()
{
    // perform standard transform on vertex
    gl_Position = mvpMatrix * position;
    vertex_color = color;
}