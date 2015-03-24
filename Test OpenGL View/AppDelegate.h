//
//  AppDelegate.h
//  Test OpenGL View
//
//  Created by George Brown on 24.03.15.
//  Copyright (c) 2015 Serious Cyrus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCTestShader.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain, readonly) NSOpenGLContext     *applicationOpenGLContext;
@property (nonatomic, retain, readonly) NSOpenGLPixelFormat *applicationPixelFormat;
@property (nonatomic, retain, readonly) SCTestShader        *testShaderProgram;

+ (NSOpenGLPixelFormat *) defaultPixelFormat;
- (NSOpenGLContext *) newSharedOpenGLContext;


@end

