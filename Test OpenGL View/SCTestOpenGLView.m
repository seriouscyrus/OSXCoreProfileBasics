//
//  SCTestOpenGLView.m
//  Test OpenGL View
//
//  Created by George Brown on 24.03.15.
//  Copyright (c) 2015 Serious Cyrus. All rights reserved.
//

#import "SCTestOpenGLView.h"
#import "AppDelegate.h"

@implementation SCTestOpenGLView

+ (NSOpenGLPixelFormat *) defaultPixelFormat
{
    return [AppDelegate defaultPixelFormat];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setPixelFormat:[AppDelegate defaultPixelFormat]];
    [self setOpenGLContext:[(AppDelegate *)[NSApp delegate] newSharedOpenGLContext]];
    [self.openGLContext setView:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    NSLog(@"Called");
    SCTestShader *testShader = [(AppDelegate *)[NSApp delegate] testShaderProgram];
    NSLog(@"Shader program = %i", testShader.shaderProgram);

    glUseProgram(testShader.shaderProgram);
    glUniformMatrix4fv(testShader.mvpMatrixLocation, 1, GL_FALSE, _mvpMatrix.m);
    
    glBindVertexArray(_testVAO);
    glEnableVertexAttribArray(kSCGLVertexAttribPosition);
    glEnableVertexAttribArray(kSCGLColorAttribPosition);

    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _testIBuffer);
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, 0);

    
    //glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glDisableVertexAttribArray(kSCGLColorAttribPosition);
    glDisableVertexAttribArray(kSCGLVertexAttribPosition);
    glBindVertexArray(0);
        
    glUseProgram(0);
    CGLFlushDrawable(self.openGLContext.CGLContextObj);
    // Drawing code here.
}

- (void) reshape
{
    if (self.openGLContext) {
        CGLContextObj cgl_ctx = CGLRetainContext(self.openGLContext.CGLContextObj);
        CGLSetCurrentContext(cgl_ctx);
//        _mvpMatrix = GLKMatrix4Identity;
//        _mvpMatrix = GLKMatrix4MakeOrtho(0.0, self.bounds.size.width, 0.0, self.bounds.size.height, 0.0, 100.0);
        _mvpMatrix = GLKMatrix4Multiply(
                                        GLKMatrix4MakeOrtho(0.0, self.bounds.size.width, 0.0, self.bounds.size.height, 0.0, 100.0),
                                        GLKMatrix4Identity);
//        NSLog(@"Self.bounds = (%f, %f, %f, %f)", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
        //        _mvpMatrix = GLKMatrix4MakeOrtho(0.0, self.bounds.size.width, 0.0, self.bounds.size.height, -1.0, 1.0);
        
        //        NSLog(@"Matrix");
        //        NSLog(@"%f, %f, %f, %f", _mvpMatrix.m00, _mvpMatrix.m01, _mvpMatrix.m02, _mvpMatrix.m03);
        //        NSLog(@"%f, %f, %f, %f", _mvpMatrix.m10, _mvpMatrix.m11, _mvpMatrix.m12, _mvpMatrix.m13);
        //        NSLog(@"%f, %f, %f, %f", _mvpMatrix.m20, _mvpMatrix.m21, _mvpMatrix.m22, _mvpMatrix.m23);
        //        NSLog(@"%f, %f, %f, %f", _mvpMatrix.m30, _mvpMatrix.m31, _mvpMatrix.m32, _mvpMatrix.m33);
        
        glViewport(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
        
        glClearColor( 0.0, 0.0, 0.0, 0.0 );
        glClear( GL_COLOR_BUFFER_BIT );
        [self genTestVao];
        
        CGLReleaseContext(cgl_ctx);
        [self.openGLContext update];
        self.needsDisplay = YES;
    }
}

- (void) genTestVao
{
    // Generate buffers first to simulate app environment
    GLfloat verts[] = {
        0.0,                    0.0,                        0.0, 1.0,
        self.bounds.size.width, 0.0,                        0.0, 1.0,
        0.0,                    self.bounds.size.height,    0.0, 1.0,
        self.bounds.size.width, self.bounds.size.height,    0.0, 1.0
        
//        0.0, 0.0, 0.0, 1.0,
//        1.0, 0.0, 0.0, 1.0,
//        0.0, 1.0, 0.0, 1.0,
//        1.0, 1.0, 0.0, 1.0
    };
    GLfloat colors[] = {
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        1.0, 1.0, 0.0, 0.0
    };
    
    GLushort indices[] = {0,1,2,3};
    if (_testVBuffer) {
        glDeleteBuffers(1, &_testVBuffer);
    }
    if (_testCBuffer) {
        glDeleteBuffers(1, &_testCBuffer);
    }
    if (_testIBuffer) {
        glDeleteBuffers(1, &_testIBuffer);
    }
    glGenBuffers(1, &_testVBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _testVBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts), verts, GL_DYNAMIC_DRAW);
    
    glGenBuffers(1, &_testCBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _testCBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(colors), colors, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    // vert and colors buffers done
    
    glGenBuffers(1, &_testIBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _testIBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    // Index buffer done
    
    // Generate VAO with pre stored buffers
    if (_testVAO) {
        glDeleteVertexArrays(1, &_testVAO);
    }
    glGenVertexArrays(1, &_testVAO);
    glBindVertexArray(_testVAO);
    // Vertex
    glBindBuffer(GL_ARRAY_BUFFER, _testVBuffer);
    glEnableVertexAttribArray(kSCGLVertexAttribPosition);
    glVertexAttribPointer(kSCGLVertexAttribPosition, 4, GL_FLOAT, GL_FALSE, 0, 0);
    // Colors
    glBindBuffer(GL_ARRAY_BUFFER, _testCBuffer);
    glEnableVertexAttribArray(kSCGLColorAttribPosition);
    glVertexAttribPointer(kSCGLColorAttribPosition, 4, GL_FLOAT, GL_FALSE, 0, 0);
    
    // Indices
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _testIBuffer);
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    NSLog(@"Generated New VAO");
}


@end
