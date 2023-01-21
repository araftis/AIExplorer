//
//  AIEShape.h
//  AIExplorer
//
//  Created by AJ Raftis on 12/4/22.
//

#import <AJRFoundation/AJRFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct _aieShape {
    NSInteger width;
    NSInteger height;
    NSInteger depth;
} AIEShape;

extern AIEShape AIEShapeMake(NSInteger width, NSInteger height, NSInteger depth);
extern BOOL AIEShapesEqual(AIEShape lhs, AIEShape rhs);

extern AIEShape AIEShapeZero;
extern AIEShape AIEShapeIdentity;

extern AIEShape AIEShapeFromString(NSString *string);
extern NSString *AIEStringFromShape(AIEShape size);

@interface NSValue (AIEShapeExtensions)

+ (NSValue *)valueWithShape:(AIEShape)size;
@property (nonatomic,readonly) AIEShape shapeValue;

@end

NS_ASSUME_NONNULL_END
