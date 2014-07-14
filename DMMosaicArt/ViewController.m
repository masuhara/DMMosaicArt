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
    mainImageView.image = [UIImage imageNamed:@"reiji.jpeg"];
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


- (IBAction)nurupo
{
    UIImage *rawImage = mainImageView.image;
    
    //リサイズ
    resizedImage = [self resizeImage:rawImage toSize:100];
    mainImageView.image = resizedImage;
}



//画像のリサイズ
- (UIImage *)resizeImage:(UIImage *)sourceImage toSize:(CGFloat)newSize
{
    UIImage *destinationImage = [[UIImage alloc] init];
    CGFloat currentWidth = sourceImage.size.width;
    CGFloat currentHeight = sourceImage.size.height;
    CGFloat newWidth, newHeight;
    
    if (newSize == 0)
    {
        newWidth = newHeight = 0;
    } else if (currentHeight < currentWidth) {
        newHeight = floorf(currentHeight * newSize / currentWidth);
        newWidth = newSize;
    } else if (currentWidth <= currentHeight) {
        newWidth = floorf(currentWidth * newSize / currentHeight);
        newHeight = newSize;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    destinationImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destinationImage;
}



- (IBAction)makeMosaicArt
{
    //メインスレッドでインジケータを表示
    [SVProgressHUD showWithStatus:@"Analysing..." maskType:SVProgressHUDMaskTypeGradient];
    //    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBar) userInfo:nil repeats:YES];
    //    [timer fire];
    
    
    //解析
    if (!views) {
        [mainImageView removeFromSuperview];
        
        views = [[NSMutableArray alloc] init];
        
        NSArray *imageViews = [self divideImage:mainImageView.image];
        
        for (UIImageView *iv in imageViews) {
            //TODO: 平均値を取ってくる
            //float avarageRGB = [self checkRGB:iv];
            
            //TODO: 解析したImageViewを1つずつ貼っていく
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
            iv.frame = CGRectMake(iv.frame.origin.x, iv.frame.origin.y + 80, iv.frame.size.height, iv.frame.size.width);
            [views addObject:iv];
            [self.view addSubview:iv];
            
            [self checkRGB:iv];//RGB値のチェック
        }
    }
    
    
    //バックグラウンドスレッド
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    });
}



- (void)checkRGB:(UIImageView *)iv
{
    //現在解析中のImageViewをcurrentImageViewに表示させる
    currentImageView.image = iv.image;
    [currentImageView clipsToBounds];
    
    NSLog(@"iv is %@", iv);
    
    // CGImageを取得する
    CGImageRef  imageRef = iv.image.CGImage;
    
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
    
    if (!averageRGBArray) {
        averageRGBArray = [[NSMutableArray alloc] init];
    }
    
    // 画像全体を１ピクセルずつ走査する
    for (int checkX = 0; checkX < iv.image.size.width; checkX++) {
        for (int checkY=0; checkY < iv.image.size.height; checkY++) {
            // ピクセルのポインタを取得する
            pixelPtr = buffer + (int)(checkY) * bytesPerRow + (int)(checkX) * 4;
            
            // 色情報を取得する
            r = *(pixelPtr + 2);  // 赤
            g = *(pixelPtr + 1);  // 緑
            b = *(pixelPtr + 0);  // 青
            
            //NSLog(@"x:%d y:%d R:%d G:%d B:%d", checkX, checkY, r, g, b);
        }
        
        int averageRGB = (int)r + (int)g + (int)b;
        averageRGB = averageRGB / 3;
        [averageRGBArray addObject:[NSNumber numberWithInt:averageRGB]];
        
    }
    CFRelease(dataRef);
    
    //TODO: RGBの平均値を返す
    //    float averageRGB = [self getAverageColor];
    //
    //    return averageRGB;
    
    NSLog(@"array is %@", averageRGBArray);
}


- (NSArray *)divideImage:(UIImage *)image
{
    // イメージをバラバラに分割する
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int size = 20;
    
    // 20x20 point で切り取る
    for (int y = 0; y < 259; y += size) {
        for (int x = 0; x < 194; x += size) {
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


//- (void)updateProgressBar
//{
//    mcProgressBarView.progress = checkX / mainImageView.image.size.width;
//    if (mcProgressBarView.progress >= 1.0) {
//        [timer invalidate];
//
//        //SVProgressHUDを消す
//        [SVProgressHUD dismiss];
//    }
//}




@end
