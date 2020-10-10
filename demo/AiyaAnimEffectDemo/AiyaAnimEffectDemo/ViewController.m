//
//  ViewController.m
//  AiyaAnimEffectDemo
//
//  Created by 汪洋 on 2017/12/27.
//  Copyright © 2017年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <AiyaEffectSDK/AiyaEffectSDK.h>

@interface ViewController () <GLKViewDelegate, AYAnimHandlerDelegate>{
    GLKView *glkView;
    CADisplayLink* displayLink;
    
    NSLock *lock;
    Boolean isAppActive;
}

@property (nonatomic, strong) AYAnimHandler *animHandler;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // license state notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(licenseMessage:) name:AiyaLicenseNotification object:nil];
    
    // init license . apply license please open http://www.lansear.cn/product/bbtx or +8618676907096
    [AYLicenseManager initLicense:@"3a8dff7c222644b7abbde10b22ad779d"];
    
    // add blue view
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"girl"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    //使用GLKit创建opengl渲染环境
    glkView = [[GLKView alloc]initWithFrame:self.view.bounds context:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]];
    glkView.backgroundColor = [UIColor clearColor];
    glkView.delegate = self;
    
    // add glkview
    [self.view addSubview:glkView];
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    displayLink.frameInterval = 2;// 帧率 = 60 / frameInterval
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    self->isAppActive = true;
    self->lock = [[NSLock alloc] init];
    
    // 监听进入后台前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)licenseMessage:(NSNotification *)notifi{
    
    AiyaLicenseResult result = [notifi.userInfo[AiyaLicenseNotificationUserInfoKey] integerValue];
    switch (result) {
        case AiyaLicenseSuccess:
            NSLog(@"License 验证成功");
            break;
        case AiyaLicenseFail:
            NSLog(@"License 验证失败");
            break;
    }
}

- (void)didEnterBackground {
    [lock lock];
    self->isAppActive = false;
    NSLog(@"didEnterBackground");
    [lock unlock];
}

- (void)willEnterForeground {
    [lock lock];
    self->isAppActive = true;
    NSLog(@"willEnterForeground");
    [lock unlock];
}

- (void)playEnd {
    NSLog(@"多次播放完成");
    [displayLink invalidate];
}

#pragma mark CADisplayLink selector
- (void)render:(CADisplayLink*)displayLink {
    [glkView display];
}

#pragma mark GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [lock lock];
    
    if (self->isAppActive == false) {
        [lock unlock];
        return;
    }
    
    if (!_animHandler) {
        //初始化AiyaAnimEffect
        _animHandler = [[AYAnimHandler alloc] init];
        self.animHandler.effectPath = [[NSBundle mainBundle] pathForResource:@"meta" ofType:@"json" inDirectory:@"shiwaitaoyuan"];
        self.animHandler.effectPlayCount = 2;
        self.animHandler.delegate = self;
    }
    
    //清空画布
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.animHandler processWithWidth:(int)glkView.drawableWidth height:(int)glkView.drawableHeight];
    
    [lock unlock];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
