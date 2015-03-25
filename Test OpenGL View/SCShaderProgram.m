//
//  SCShaderProgram.m
//  Reality Augmenter
//
//  Created by George Brown on 12.10.13.
//  Copyright (c) 2013 Serious Cyrus. All rights reserved.
//

#import "SCShaderProgram.h"
#import <GLKit/GLKit.h>

GLuint const kSCGLVertexAttribPosition  = 0;
GLuint const kSCGLColorAttribPosition   = 1;
GLuint const kSCGLNormalAttribPosition  = 2;
GLuint const kSCGLTexCoordPosition      = 3;

@implementation SCShaderProgram

@synthesize shaderName                  = _shaderName;
@synthesize shaderProgram               = _shaderProgram;
@synthesize mvpMatrixLocation           = _mvpMatrixLocation;

#if !TARGET_OS_IPHONE
- (id) initWithShaderName:(NSString *) shaderName inCGLContext:(CGLContextObj) context
{
    cgl_ctx = CGLRetainContext(context);
    self = [self initWithShaderName:shaderName];
    CGLReleaseContext(cgl_ctx);
    return self;
}
#endif

- (id) initWithShaderName:(NSString *) shaderName
{
     return [self initWithVertShaderName:shaderName withFragShaderName:shaderName];
}

- (id) initWithVertShaderName:(NSString *) vertShaderName withFragShaderName:(NSString *) fragShaderName
{
    self = [super init];
    if (self) {
        _shaderName = vertShaderName;
        GLuint vertShader = [self getShaderWithName:vertShaderName ofType:GL_VERTEX_SHADER];
        if (!vertShader) {
            NSLog(@"Vert shader failed");
            self = NULL;
            return NULL;
        }
        GLuint fragShader = [self getShaderWithName:fragShaderName ofType:GL_FRAGMENT_SHADER];
        if (!fragShader) {
            NSLog(@"Frag shader failed");
            glDeleteShader(vertShader);
            self = NULL;
            return NULL;
        }
        if (![self createProgramObjectWithVertexShader:vertShader withFragShader:fragShader]) {
            NSLog(@"Program create failed");
            self = NULL;
            return NULL;
        }

    }
    return self;
}

- (GLuint) getShaderWithName:(NSString *) shaderName ofType:(GLenum) shaderType
{
    NSString *ext;
    if (shaderType == GL_VERTEX_SHADER) {
        ext = @"vs";
    } else {
        ext = @"fs";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:shaderName ofType:ext];
    NSError *fileLoadError;
    NSString *shaderContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&fileLoadError];
    if (fileLoadError) {
        NSLog(@"Error loading %@ i n shader %@",shaderName, path);
        NSLog(@"%@", fileLoadError);
    }
    GLint result = GL_FALSE;
    GLint infoLogLength;
    GLuint shader = glCreateShader(shaderType);
    const char *shaderSourcePointer = shaderContents.UTF8String;
    
    glShaderSource(shader, 1, &shaderSourcePointer, NULL);
    glCompileShader(shader);
    glGetShaderiv(shader, GL_COMPILE_STATUS, &result);
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLogLength);
    if (result == GL_FALSE) {
        char errorMsg[infoLogLength];
        glGetShaderInfoLog(shader, infoLogLength, NULL, errorMsg);
        NSLog(@"Compile failed with error %@", [NSString stringWithUTF8String:errorMsg]);
        glDeleteShader(shader);
    }
    return shader;
}

- (BOOL) createProgramObjectWithVertexShader:(GLuint) vertShader withFragShader:(GLuint) fragShader
{
    _shaderProgram = glCreateProgram();
    glAttachShader(_shaderProgram, vertShader);
    
    
    glBindAttribLocation(_shaderProgram, kSCGLVertexAttribPosition, "position");
    GLenum error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"Error generated getting position!");
        
        if (error == GL_INVALID_VALUE) {
            NSLog(@"Invalid value");
        } else if (error == GL_INVALID_OPERATION) {
            NSLog(@"Invalid operation");
        } else {
            NSLog(@"unexpected error");
        }
    }
    glBindAttribLocation(_shaderProgram, kSCGLColorAttribPosition,  "color");
    error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"Error generated getting color!");
        
        if (error == GL_INVALID_VALUE) {
            NSLog(@"Invalid value");
        } else if (error == GL_INVALID_OPERATION) {
            NSLog(@"Invalid operation");
        } else {
            NSLog(@"unexpected error");
        }
    }
    
    //glBindAttribLocation(_shaderProgram, kSCGLNormalAttribPosition, "normal");
    //glBindAttribLocation(_shaderProgram, kSCGLTexCoordPosition,     "texcoord");
//    error = glGetError();
//    if (error != GL_NO_ERROR) {
//        NSLog(@"Error generated getting texcoord!");
//        
//        if (error == GL_INVALID_VALUE) {
//            NSLog(@"Invalid value");
//        } else if (error == GL_INVALID_OPERATION) {
//            NSLog(@"Invalid operation");
//        } else {
//            NSLog(@"unexpected error");
//        }
//    }

    glAttachShader(_shaderProgram, fragShader);

    glLinkProgram(_shaderProgram);
    
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    GLint result = GL_FALSE;
    GLint infoLogLength = 0;
    
    glGetProgramiv(_shaderProgram, GL_INFO_LOG_LENGTH, &infoLogLength);
    if (infoLogLength > 0) {
        char errMsg[infoLogLength];
        glGetProgramInfoLog(_shaderProgram, infoLogLength, &infoLogLength, errMsg);
        NSString *msg = [NSString stringWithUTF8String:errMsg];
        NSLog(@"Self = %@", self);
        NSLog(@"Validate program failed with %@", msg);
        if (![msg hasPrefix:@"WARNING:"]) {
            NSLog(@"Fatal");
            glDeleteProgram(_shaderProgram);
            return NO;
        }

    }
    if (![self getUniformLocations]) {
        NSLog(@"Failed getting uniform variables for %@", self.shaderName);
        glDeleteProgram(_shaderProgram);
        return NO;
    }

    return YES;
}

- (BOOL) getUniformLocations
{
    BOOL ok = YES;
    _mvpMatrixLocation = glGetUniformLocation(self.shaderProgram, "mvpMatrix");
    if (_mvpMatrixLocation == -1) {
        NSLog(@"self = %@", self);
        GLint uniforms;
        glGetProgramiv(_shaderProgram, GL_ACTIVE_UNIFORMS, &uniforms);
        NSLog(@"Shader program = %i", _shaderProgram);
        NSLog(@"Failed to set mvp location, uniforms found = %i", uniforms);
        for(int i=0; i<uniforms; ++i)  {
            int name_len=-1, num=-1;
            GLenum type = GL_ZERO;
            char name[100];
            glGetActiveUniform(_shaderProgram, (GLuint)i, sizeof(name)-1,
                               &name_len, &num, &type, name );
            name[name_len] = 0;
            //GLuint location = glGetUniformLocation( self.shaderProgram, name );
            NSLog(@"Name = %s", name);
            NSLog(@"Second attempt = %i", glGetUniformLocation(_shaderProgram, name));
            
        }
        ok = NO;
    } else {
        NSLog(@"Found MVP Location");
    }
    return ok;
}

@end
