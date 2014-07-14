//
//  ViewController.h
//  DMMosaicArt
//
//  Created by Master on 2014/06/27.
//  Copyright (c) 2014年 jp.co.mappy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController
{
    IBOutlet UILabel *labelX;
    IBOutlet UILabel *labelY;
    IBOutlet UIImageView *mainImageView;
    IBOutlet UIImageView *currentImageView;
    UIImage *resizedImage;//リサイズ後の画像
    
    NSMutableArray *averageRGBArray;
    
    //int checkX;
    //int checkY;
    
    NSTimer *timer;
    NSMutableArray *views;
}



@end

