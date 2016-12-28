//
//  ViewController.h
//  DWSPlayer
//
//  Created by DaiWangsheng on 16/11/7.
//  Copyright © 2016年 DaiWangsheng. All rights reserved.
//

#import <UIKit/UIKit.h>


#define ScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#define ScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define Width  (ScreenWidth>ScreenHeight?ScreenWidth:ScreenHeight)
#define Height (ScreenWidth<ScreenHeight?ScreenWidth:ScreenHeight)

@interface ViewController : UIViewController


@end

