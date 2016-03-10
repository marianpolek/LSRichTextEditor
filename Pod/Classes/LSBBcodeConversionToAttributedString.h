//
//  LSBBcodeConversionToAttributedString.h
//  Pods
//
//  Created by Polek, Marian on 10/03/16.
//
//

#import <Foundation/Foundation.h>
#import "LSRichTextConfiguration.h"


@interface LSBBcodeConversionToAttributedString : NSObject

@property (nonatomic, strong, readonly) LSRichTextConfiguration *richTextConfiguration;

-(NSAttributedString*)attributedStringFromBbCodeString:(NSString*)bbCodeString;
-(instancetype)initWithLabel:(UILabel*)label;

@end
