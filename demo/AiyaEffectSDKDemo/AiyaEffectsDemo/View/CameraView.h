//
//  CameraView.h
//  AiyaEffectsDemo
//
//  Created by 汪洋 on 2017/3/9.
//  Copyright © 2016年 深圳哎吖科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol CameraViewDelegate <NSObject>

- (void)onSwitchCamera;

- (void)onEffectClick:(NSString *)path;

- (void)onStyleClick:(UIImage *)image;

- (void)onSmoothChange:(float)intensity;

- (void)onRuddyChange:(float)intensity;

- (void)onWhiteChange:(float)intensity;

- (void)onBigEyesScaleChange:(float)scale;

- (void)onSlimFaceScaleChange:(float)scale;

- (void)onStyleChange:(float)style;

@end

@interface CameraView : UIView

//data step 3 UIImage|Text|Path
@property (nonatomic, strong) NSArray *effectData;

//data step 3 UIImage|Text|UIImage
@property (nonatomic, strong) NSArray *styleData;

@property (nonatomic, weak) id<CameraViewDelegate> delegate;

@end
