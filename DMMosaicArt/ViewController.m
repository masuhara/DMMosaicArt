//
//  ViewController.m
//  DMMosaicArt
//
//  Created by Master on 2014/06/27.
//  Copyright (c) 2014年 jp.co.mappy. All rights reserved.
//

#import "ViewController.h"
#import "SVProgressHUD.h"
#import "MCProgressBarView.h"

@interface ViewController ()
            

@end

@implementation ViewController
{
    MCProgressBarView *mcProgressBarView;
}
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初期化
    mainImageView.image = [UIImage imageNamed:@"miku.jpg"];
    labelX.text = [NSString stringWithFormat:@"%d", (int)mainImageView.image.size.width];
    labelY.text = [NSString stringWithFormat:@"%d", (int)mainImageView.image.size.height];
    
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"progress-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage *foregroundImage = [[UIImage imageNamed:@"progress-fg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    mcProgressBarView = [[MCProgressBarView alloc] initWithFrame:CGRectMake(40, 55, 240, 20) backgroundImage:backgroundImage foregroundImage:foregroundImage];
    mcProgressBarView.progress = 0.0f;
    [self.view addSubview:mcProgressBarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma makr - Private 

- (IBAction)mosaicEffect
{
//    if (effected == NO) {
//        effected = YES;
//        
//        //ベクター画像をラスタライズする(ラスター化/ビットマップ化)
//        mainImageView.layer.shouldRasterize = YES;
//        //スケールを20%に縮小(元画像を小さくしてから再度拡大)
//        mainImageView.layer.rasterizationScale = 0.2;
//        mainImageView.layer.minificationFilter = kCAFilterTrilinear;
//        mainImageView.layer.magnificationFilter= kCAFilterNearest;
//        
//    }
    
    if (!views) {
        views = [[NSMutableArray alloc] init];
        
        //分割
        [mainImageView removeFromSuperview];
        mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, 320, 320)];
        mainImageView.image = [UIImage imageNamed:@"miku.jpg"];
        [mainImageView clipsToBounds];
        
        NSArray *imageViews = [self divideImage:mainImageView.image];
        
        for (UIImageView *iv in imageViews) {
            
            //TODO: make
            [self checkRGB];
            
            //[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
            iv.frame = CGRectMake(iv.frame.origin.x, iv.frame.origin.y + 80, iv.frame.size.height, iv.frame.size.width);
            iv.image = [UIImage imageNamed:@"nurupo.png"];
            [self.view addSubview:iv];
            [views addObject:iv];
        }
    }
}

- (IBAction)nurupo
{
//    int numberOfImages = (int)[views count];
//    int randNum = arc4random_uniform(numberOfImages);
//    [views[randNum] removeFromSuperview];
    UIImage *rawImage = [UIImage imageNamed:@"miku.jpg"];
    
    UIImage *resizedImage = [self resizeAspectFitWithSize:rawImage size:rawImage.size];
    mainImageView.image = resizedImage;
}

- (UIImage*)resizeAspectFitWithSize:(UIImage *)srcImg size:(CGSize)size {
    
    CGFloat widthRatio  = size.width  / srcImg.size.width;
    CGFloat heightRatio = size.height / srcImg.size.height;
    CGFloat ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio;
    
    CGSize resizedSize = CGSizeMake(srcImg.size.width*ratio, srcImg.size.height*ratio);
    
    UIGraphicsBeginImageContext(resizedSize);
    [srcImg drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}


- (IBAction)makeMosaicArt
{
    //メインスレッドでインジケータを表示
    [SVProgressHUD showWithStatus:@"Analysing..." maskType:SVProgressHUDMaskTypeGradient];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    [timer fire];
    
    
    
    //バックグラウンドスレッドでRGB解析
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkRGB];
    });
}


- (IBAction)reset
{
    views = nil;
    [mainImageView removeFromSuperview];
    mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, 320, 320)];
    mainImageView.image = [UIImage imageNamed:@"miku.jpg"];
//    mainImageView.layer.shouldRasterize = NO;
//    mainImageView.layer.rasterizationScale = 1.0;
//    mainImageView.layer.minificationFilter = nil;
//    mainImageView.layer.magnificationFilter= nil;
}


- (void)checkRGB
{
    // CGImageを取得する
    CGImageRef  imageRef = mainImageView.image.CGImage;
    // データプロバイダを取得する
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    
    // ビットマップデータを取得する
    CFDataRef dataRef = CGDataProviderCopyData(dataProvider);
    UInt8 *buffer = (UInt8*)CFDataGetBytePtr(dataRef);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    
    UInt8 *pixelPtr;
    UInt8 r;
    UInt8 g;
    UInt8 b;
    
    
    
    
    // 画像全体を１ピクセルずつ走査する
    for (checkX = 0; checkX < mainImageView.image.size.width; checkX++) {
        for (int y=0; y< mainImageView.image.size.height; y++) {
            // ピクセルのポインタを取得する
            pixelPtr = buffer + (int)(y) * bytesPerRow + (int)(checkX) * 4;
            
            // 色情報を取得する
            r = *(pixelPtr + 2);  // 赤
            g = *(pixelPtr + 1);  // 緑
            b = *(pixelPtr + 0);  // 青
            
            NSLog(@"x:%d y:%d R:%d G:%d B:%d", checkX, y, r, g, b);
        }
    }
    CFRelease(dataRef);
}


- (void)updateProgressBar
{
    mcProgressBarView.progress = checkX / mainImageView.image.size.width;
    if (mcProgressBarView.progress >= 1.0) {
        [timer invalidate];
        
        //SVProgressHUDを消す
        [SVProgressHUD dismiss];
    }
}


- (NSArray *)divideImage:(UIImage *)image
{
    // イメージをバラバラに分割する
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int size = 20;
    
    // 10x10 point で切り取る
    for (int y=0; y<320; y+=size) {
        for (int x=0; x<320; x+=size) {
            CGRect rect = CGRectMake(x, y, size, size);
            UIImage *croppedImage = [self imageByCropping:image toRect:rect];
            UIImageView *v = [[UIImageView alloc] initWithFrame:rect];
            v.image = croppedImage;
            v.layer.cornerRadius = 0.0;
            v.layer.borderWidth = 1.0;
            v.layer.borderColor = [UIColor whiteColor].CGColor;
            v.layer.zPosition = - (y * 100 + x); // 重なったとき上に来るように
            [result addObject:v];
        }
    }
    return result;
}


- (UIImage *)imageByCropping:(UIImage *)crop toRect:(CGRect)rect
{
    // 指定した四角でイメージを切り抜き
    CGImageRef imageRef = CGImageCreateWithImageInRect([crop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}




//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    // タッチしたら、画像をバラバラにくずす
//    for (int i=0; i<[views count]; i++) {
//        [UIView animateWithDuration:0.8 delay:i * 0.05 options:UIViewAnimationOptionCurveEaseIn animations:^{
//            UIView *v = [views objectAtIndex:i];
//            v.center = CGPointMake(v.center.x, 600);
//        } completion:^(BOOL finished) {}];
//    }
//}

//- (UIColor *)getAverageColor
//{
//    // Get an averaged color.
//    self.averagedColor = [UIColor colorWithRed:aveR green:aveG blue:aveB alpha:1.0];
//    
//    // Get a complementary color.
//    aveR = 1.0f - aveR;
//    aveG = 1.0f - aveG;
//    aveB = 1.0f - aveB;
//    self.complementaryColors = [UIColor colorWithRed:aveR green:aveG blue:aveB alpha:1.0];
//}




@end
