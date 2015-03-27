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

    SCTestShader *testShader = [(AppDelegate *)[NSApp delegate] testShaderProgram];

    glUseProgram(testShader.shaderProgram);
    glUniformMatrix4fv(testShader.mvpMatrixLocation, 1, GL_FALSE, _mvpMatrix.m);
    
    if (_warpVAO) {
        glBindVertexArray(_warpVAO);
        glDrawElements(GL_TRIANGLE_STRIP, _warpIndexCount, GL_FLOAT, 0);
    } else {
        glBindVertexArray(_testVAO);
        glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, 0);
    }

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

        _mvpMatrix = GLKMatrix4Multiply(
                                        GLKMatrix4MakeOrtho(0.0, self.bounds.size.width, 0.0, self.bounds.size.height, 0.0, 100.0),
                                        GLKMatrix4Identity);

        
        glViewport(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
        
        glClearColor( 0.0, 0.0, 0.0, 0.0 );
        glClear( GL_COLOR_BUFFER_BIT );
        // Switch between test cases
        int test = 0;
        switch (test) {
            case 0:
                [self genWarpVAO];
                break;
            case 1:
                [self genTestVao];
                break;
        }
        //[self genTestVao];
        //[self genWarpVAO];
        
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
    glDisableVertexAttribArray(kSCGLColorAttribPosition);
    glDisableVertexAttribArray(kSCGLVertexAttribPosition);
    NSLog(@"Generated New VAO");
}

- (void) genWarpVAO
{
    
    // Inputs that would normally come from application
    int centreOffset = 20;
    int outerOffset = 0;
    int sectorResolution = 64;
    int nStrips = 64;
    float arcAngle = 6.283185;
    
    // Vert variables
    int nearR = centreOffset;
    float nearRf = (float)centreOffset;
    float outerOffsetf = (float)outerOffset;
    int edgeSize = 50;
    //int edgeSize = self.inputRotationVertical ? self.inputChopArea0.textureBounds.size.width : self.inputChopArea0.textureBounds.size.height;
    // Rescale if input values larger than our bounds
    float edgeSizef = (float)edgeSize;
    if ((nearR + edgeSize + outerOffset)*2 > self.bounds.size.width) {
        float scale = self.bounds.size.width/(((float)nearR+(float)edgeSize + outerOffsetf)*2);
        nearRf = nearRf*scale;
        edgeSizef = edgeSizef*scale;
        outerOffsetf = outerOffsetf*scale;
    }
    float farf = nearRf + edgeSizef;
    int rows = 1;
    int cols = nStrips;
    int rowVs = rows + 1;
    int colVs = cols +1;
    float rowH = edgeSizef/rows;
    float radStep = (2*M_PI)/(float)(sectorResolution - 1);
    float minAngle = 0 - arcAngle;
    int totalVerts = rowVs*colVs;
    
    // index Variables
    int nDegen      = 2 * (rows -1);
    // Index Counter
    int iidx        = 0;
    _warpIndexCount = totalVerts + nDegen;
    
    // Vert, colour all vec 4
    GLfloat vertCoords[2 * totalVerts * 4];
    GLushort indices[_warpIndexCount];
    NSLog(@"Index size = %i", _warpIndexCount);
    NSLog(@"Vert count = %i", totalVerts);
    NSLog(@"nearRF = %f", nearRf);
    NSLog(@"farf = %f", farf);
    NSLog(@"outerOffsetf = %f", outerOffsetf);
    // Vert counter
    int idx = 0;
    
    // position in index
    int xyzidx = 0;
    for (int row = 0; row < rowVs; row++) {
        if (row > 0) {
            indices[iidx++] = (GLushort)(row * colVs);
        }
        
        float angle = 0;
        for (int col = 0; col < colVs; col++) {
            // Verts
            //NSLog(@"idx = %i", idx);
            angle = angle < minAngle ? minAngle : angle;
            vertCoords[idx++] = ((nearRf + (rowH * (float)row)) * cosf(angle)) + farf + outerOffsetf;
            vertCoords[idx++] = ((nearRf + (rowH * (float)row)) * sinf(angle)) + farf + outerOffsetf;
            vertCoords[idx++] = 0.0;
            vertCoords[idx++] = 1.0;
            if (idx < 62) {
                NSLog(@"Verts[%i] = ([%i]:%f, [%i]:%f, [%i]:%f, [%i]:%f)", xyzidx, idx-4, vertCoords[idx-4], idx-3, vertCoords[idx-3], idx-2, vertCoords[idx-2], idx -1, vertCoords[idx-1]);
            }
            //NSLog(@"[%i](%f)(%f, %f, %f)", xyzidx, angle*(180/M_PI), vertCoords[idx],vertCoords[idx+1],vertCoords[idx+2]);
            // Colours
            vertCoords[idx++] = 1.0;
            vertCoords[idx++] = 1.0;
            vertCoords[idx++] = 1.0;
            vertCoords[idx++] = 0.0;
            
            // Index
            indices[iidx++] = (GLushort) row*colVs + col;
            indices[iidx++] = (GLushort) (row+1)* colVs + col;
            
            xyzidx++;
            angle -= radStep;
        }
        if (rows != 1 && row < rows -1) {
            // Add a degenrate at end of row
            indices[iidx++] = (GLushort) (row+1)*colVs + cols;
            //NSLog(@"[%i] %i",offSet-1, indices[offSet-1]);
            
        }
    }
    NSLog(@"Why are the first 62 values 0.0????");
    for (int i = 0; i < 62; i++) {
        NSLog(@"Vert[%i] = %f", i, vertCoords[i]);
    }
    
    // Regen VBO
    if (_warpVBO) {
        glDeleteBuffers(1, &_warpVBO);
    }
    glGenBuffers(1, &_warpVBO);
    
    // Regen Index buffers
    if (_warpIndexBuffer) {
        glDeleteBuffers(1, &_warpIndexBuffer);
    }
    glGenBuffers(1, &_warpIndexBuffer);
    
    // regen VAO
    if (_warpVAO) {
        glDeleteVertexArrays(1, &_warpVAO);
    }
    glGenVertexArrays(1, &_warpVAO);
    // Fil VBO Buffer
    glBindVertexArray(_warpVAO);
    glBindBuffer(GL_ARRAY_BUFFER, _warpVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertCoords), vertCoords, GL_DYNAMIC_DRAW);
    
    // Load verts
    glVertexAttribPointer(kSCGLVertexAttribPosition, 4, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 8, 0);
    glEnableVertexAttribArray(kSCGLVertexAttribPosition);
    
    // Load colours
    glVertexAttribPointer(kSCGLColorAttribPosition, 4, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 8, (const void *)(sizeof(GL_FLOAT) * 4));
    glEnableVertexAttribArray(kSCGLColorAttribPosition);
    
    // load indices
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _warpIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);
    
    glBindVertexArray(0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
}




@end
