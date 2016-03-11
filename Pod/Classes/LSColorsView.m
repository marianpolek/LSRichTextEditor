//
//  LSColorsView.m
//  Pods
//
//  Created by Polek, Marian on 09/03/16.
//
//

#import "LSColorsView.h"
#import "LSColorHelper.h"
#import "LSCloseButton.h"

#define BUTTON_TOP_AND_BOTTOM_BORDER 5

@implementation LSColorsView

@dynamic delegate;

-  (id)initWithFrame:(CGRect)aRect toolbarHeight:(NSInteger)toolbarHeight
{
    self = [super initWithFrame:aRect];
    
    if (self)
    {
        [self myInitializationWithToolbarHeight:toolbarHeight];
    }
    
    return self;
}

-(void)myInitializationWithToolbarHeight:(NSInteger)toolbarHeight{
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:4.0f];
    [self.layer setBorderWidth:1.0f];
    [self.layer setBorderColor:[[UIColor colorWithRed:205.0f / 255.0f green:205.0f / 255.0f blue:205.0f / 255.0f alpha:1.0f] CGColor]];
    
    NSInteger buttonsHeight = toolbarHeight - (2*BUTTON_TOP_AND_BOTTOM_BORDER);
    NSInteger buttonsWidth = [LSColorsView buttonWidth];
    
    
    LSCloseButton *closeButton = [LSCloseButton buttonWithType:UIButtonTypeCustom];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton setFrame:CGRectMake(0, 0, buttonsWidth, buttonsHeight)];
    [closeButton addTarget:self action:@selector(backgroundColorSelected:withColor:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    for(int i=1; i < [[LSColorsView listOfColors] count]; i++){
        
        UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [colorButton setBackgroundColor:[LSColorsView listOfColors][i]];
        [colorButton setFrame:CGRectMake(i*buttonsWidth, 0, buttonsWidth, buttonsHeight)];
        [colorButton addTarget:self action:@selector(backgroundColorSelected:withColor:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:colorButton];
        
        [self setContentSize:CGSizeMake(i*buttonsWidth+buttonsWidth, buttonsHeight)];
    }

}

- (void)backgroundColorSelected:(UIButton *)sender withColor:(UIColor*)color
{
    if(self.delegate){
        [self.delegate backgroundColorSelected:sender withColor:color];
    }
}

#pragma configurations

+(NSInteger)buttonWidth{
    return 40;
}

+(NSArray*)listOfColors{
    
    return @[[UIColor clearColor],
             [LSColorHelper colorFromHexString:@"#ABFFF7"],
             [LSColorHelper colorFromHexString:@"#ABFFCB"],
             [LSColorHelper colorFromHexString:@"#E7FFAB"],
             [LSColorHelper colorFromHexString:@"#FFD5AB"],
             [UIColor redColor],
             [UIColor greenColor],
             [UIColor blueColor],
             [UIColor orangeColor],
             [LSColorHelper colorFromHexString:@"#DDABFF"]];
}

@end
