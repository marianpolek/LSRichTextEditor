//
//  LSColorsView.h
//  Pods
//
//  Created by Polek, Marian on 09/03/16.
//
//

#import <UIKit/UIKit.h>

@protocol LSColorsViewDelegate <UIScrollViewDelegate>

- (void)backgroundColorSelected:(UIButton *)sender withColor:(UIColor*)color;

@end

@interface LSColorsView : UIScrollView

@property (nonatomic, assign) id<LSColorsViewDelegate> delegate;

-  (id)initWithFrame:(CGRect)aRect toolbarHeight:(NSInteger)toolbarHeight;
+(NSInteger)buttonWidth;
+(NSArray*)listOfColors;

@end
