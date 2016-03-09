//
//  LSColorHelper.h
//  Pods
//
//  Created by Polek, Marian on 09/03/16.
//
//

#import <UIKit/UIKit.h>

@interface LSColorHelper : NSObject

+(UIColor *)colorFromHexString:(NSString *)hexString;
+(NSString *)hexStringForColor:(UIColor *)color;

@end
