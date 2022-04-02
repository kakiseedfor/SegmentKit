//
//  EMLayer.h
//  EMSegmentKit
//
//  Created by HDB-JSKF-004 on 2020/10/30.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnimationLayer : CALayer

- (void)setHidden:(BOOL)hidden animation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
