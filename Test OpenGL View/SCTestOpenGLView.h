//
//  SCTestOpenGLView.h
//  Test OpenGL View
//
//  Created by George Brown on 24.03.15.
//  Copyright (c) 2015 Serious Cyrus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>
#import <GLKit/GLKit.h>

@interface SCTestOpenGLView : NSOpenGLView
{
    GLuint      _testVBuffer;
    GLuint      _testCBuffer;
    GLuint      _testIBuffer;
    GLuint      _testVAO;
    GLuint      _warpVBO;
    GLuint      _warpVAO;
    GLuint      _warpIndexBuffer;
    GLuint      _warpIndexCount;
    GLKMatrix4  _mvpMatrix;
}

@end
