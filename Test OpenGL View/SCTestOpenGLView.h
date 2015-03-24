//
//  SCTestOpenGLView.h
//  Test OpenGL View
//
//  Created by George Brown on 24.03.15.
//  Copyright (c) 2015 Serious Cyrus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GLKit/GLKit.h>

@interface SCTestOpenGLView : NSOpenGLView
{
    GLuint      _testVBuffer;
    GLuint      _testCBuffer;
    GLuint      _testIBuffer;
    GLuint      _testVAO;
    GLKMatrix4  _mvpMatrix;
}

@end
