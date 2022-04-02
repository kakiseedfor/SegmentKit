//
//  EMLayer.m
//  EMSegmentKit
//
//  Created by HDB-JSKF-004 on 2020/10/30.
//

#import "AnimationLayer.h"

@interface AnimationLayer ()<CAAnimationDelegate>
@property (nonatomic) CGFloat displayAlpha;
@property (nonatomic) BOOL removeKeyPath;

@end

@implementation AnimationLayer
@dynamic displayAlpha;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.displayAlpha = 1.f;
        self.removeKeyPath = YES;
    }
    return self;
}

- (void)setHidden:(BOOL)hidden animation:(BOOL)animation{
    if (animation) {
        if (self.isHidden) {
            self.hidden = hidden;
        }
        
        self.displayAlpha = hidden ? 0.f : 1.f;
        return;
    }
    self.hidden = hidden;
}

- (id<CAAction>)actionForKey:(NSString *)event{
    if ([event isEqualToString:@"displayAlpha"]) {
        if (!self.removeKeyPath) {
            return [super actionForKey:event];
        }
        
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"displayAlpha"];
        basicAnimation.fromValue = @(self.presentationLayer.displayAlpha);
        basicAnimation.delegate = self;
        return basicAnimation;
    }
    
    return [super actionForKey:event];
}

+ (BOOL)needsDisplayForKey:(NSString *)key{
    if ([key isEqualToString:@"displayAlpha"]) {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (void)display{
    if ([self animationForKey:@"displayAlpha"]) {
        self.opacity = self.presentationLayer.displayAlpha;
        return;
    }
    
    [super display];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([anim isKindOfClass:CABasicAnimation.class]) {
        CABasicAnimation *basicAnimation = (CABasicAnimation *)anim;
        if ([basicAnimation.keyPath isEqualToString:@"displayAlpha"]) {
            self.hidden = !(self.displayAlpha > 0.f);
            return;
        }
    }
}

@end
