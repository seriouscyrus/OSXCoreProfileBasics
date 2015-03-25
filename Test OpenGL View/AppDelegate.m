//
//  AppDelegate.m
//  Test OpenGL View
//
//  Created by George Brown on 24.03.15.
//  Copyright (c) 2015 Serious Cyrus. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize applicationOpenGLContext    = _applicationOpenGLContext;
@synthesize applicationPixelFormat      = _applicationPixelFormat;

+ (NSOpenGLPixelFormat *) defaultPixelFormat
{
    NSOpenGLPixelFormatAttribute attrs[] =
    {
        kCGLPFAOpenGLProfile, kCGLOGLPVersion_3_2_Core,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFABackingStore,
        NSOpenGLPFAAllowOfflineRenderers,
        //NSOpenGLPFAStencilSize, 8,
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFADepthSize, 24,
        0
    };
    NSOpenGLPixelFormat* pixFmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    return pixFmt;
}

- (NSOpenGLPixelFormat *) applicationPixelFormat
{
    if (!_applicationPixelFormat) {
        _applicationPixelFormat = [AppDelegate defaultPixelFormat];
    }
    return _applicationPixelFormat;
}

- (NSOpenGLContext *) applicationOpenGLContext
{
    if (!_applicationOpenGLContext) {
        _applicationOpenGLContext = [[NSOpenGLContext alloc] initWithFormat:self.applicationPixelFormat shareContext:nil];
        [_applicationOpenGLContext makeCurrentContext];
        _testShaderProgram = [[SCTestShader alloc] initWithShaderName:@"SCTestShader" inCGLContext:_applicationOpenGLContext.CGLContextObj];
        
    }
    return _applicationOpenGLContext;
}

- (NSOpenGLContext *) newSharedOpenGLContext
{
    return [[NSOpenGLContext alloc] initWithFormat:self.applicationPixelFormat shareContext:self.applicationOpenGLContext];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void) loadShaders
{
    
}

@end
