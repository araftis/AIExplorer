//
//  AIEShape.m
//  AIExplorer
//
//  Created by AJ Raftis on 12/4/22.
//

#import "AIEShape.h"

AIEShape AIEShapeZero = (AIEShape){0, 0, 0};
AIEShape AIEShapeIdentity = (AIEShape){1, 1, 0};

AIEShape AIEShapeMake(NSInteger width, NSInteger height, NSInteger depth) {
    return (AIEShape){width=width, height=height, depth=depth};
}

BOOL AIEShapesEqual(AIEShape lhs, AIEShape rhs) {
    return lhs.width == rhs.width && lhs.height == rhs.height && lhs.depth == rhs.depth;
}

AIEShape AIEShapeFromString(NSString *string) {
    NSSize size = NSSizeFromString(string);
    return (AIEShape){size.width, size.height};
}

NSString *AIEStringFromShape(AIEShape sizeIn) {
    NSSize size = {sizeIn.width, sizeIn.height};
    return NSStringFromSize(size);
}

@implementation NSValue (AIEShapeExtensions)

+ (NSValue *)valueWithShape:(AIEShape)size {
    return [NSValue valueWithBytes:&size objCType:@encode(AIEShape)];
}

- (AIEShape)shapeValue {
    AIEShape size;
    [self getValue:&size size:sizeof(AIEShape)];
    return size;
}

@end
