//
//  SCShaderProgram.h
//  Reality Augmenter
//
//  Created by George Brown on 12.10.13.
//  Copyright (c) 2013 Serious Cyrus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGL/OpenGL.h>

extern GLuint const kSCGLVertexAttribPosition;
extern GLuint const kSCGLColorAttribPosition;
extern GLuint const kSCGLNormalAttribPosition;
extern GLuint const kSCGLTexCoordPosition;


@interface SCShaderProgram : NSObject
{
#if !TARGET_OS_IPHONE

    CGLContextObj   cgl_ctx;
#endif
    GLint          _mvpMatrixLocation;
}


@property (nonatomic, readonly)         GLuint      shaderProgram;
@property (nonatomic, retain, readonly) NSString    *shaderName;
@property (nonatomic, readonly)         GLint       mvpMatrixLocation;

- (id) initWithShaderName:(NSString *) shaderName;
#if !TARGET_OS_IPHONE
- (id) initWithShaderName:(NSString *) shaderName inCGLContext:(CGLContextObj) context;
#endif

- (BOOL) getUniformLocations;

@end
