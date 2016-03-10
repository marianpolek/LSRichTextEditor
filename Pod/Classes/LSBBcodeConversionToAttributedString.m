//
//  LSBBcodeConversionToAttributedString.m
//  Pods
//
//  Created by Polek, Marian on 10/03/16.
//
//

#import "LSBBcodeConversionToAttributedString.h"
#import "LSParser.h"
#import "LSColorHelper.h"

@implementation LSBBcodeConversionToAttributedString


-(instancetype)init{
    
    if(self = [super init]){
        
        _richTextConfiguration = [[LSRichTextConfiguration alloc] initWithTextFeatures:LSRichTextFeaturesAll];
        [self.richTextConfiguration setInitialAttributes];

    }
    
    return self;
}

-(NSAttributedString*)attributedStringFromBbCodeString:(NSString*)bbCodeString{
    
    NSLog(@"1- %@",bbCodeString);
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:bbCodeString];
    
    LSParser *parser = [LSParser new];
    LSNode *rootNode = [parser parseString:attributedText.string error:nil];
    
    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] init];
    
    [self processParsedString:rootNode resultString:&resultString fromSourceText:attributedText];
    
    NSLog(@"2-- %@",resultString);
    return resultString;
}

- (void)processParsedString:(LSNode *)currentNode resultString:(NSMutableAttributedString **)outString
             fromSourceText:(NSAttributedString *)attributedText
{
    __block NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] init];
    
    if (currentNode.tagName) {
        [currentNode.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self processParsedString:(LSNode *)obj resultString:&resultString fromSourceText:attributedText];
        }];
    } else {
        NSRange originRange = [attributedText.string rangeOfString:currentNode.content];
        NSAttributedString *preservedAttributedString = [attributedText attributedSubstringFromRange:originRange];
        
        [resultString appendAttributedString:preservedAttributedString];
        
        [currentNode.tagNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *searchingTag = obj;
            if([obj containsString:@"="]){
                NSArray *myArray = [obj componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
                searchingTag = myArray[0];
            }
            if ([@[@"b", @"i", @"u", @"s", @"color"] containsObject:searchingTag]) {
                NSRange currentRange = NSMakeRange(0, resultString.length);
                NSDictionary *newAttributes = [self createActualAttributeStyle:currentRange
                                                                    forTagName:obj
                                                                      withText:resultString];
                [resultString addAttributes:newAttributes range:currentRange];
            }
        }];
    }
    
    [*outString appendAttributedString:resultString];
}

- (NSDictionary *)createActualAttributeStyle:(NSRange)inRange forTagName:(NSString *)tagName withText:(NSAttributedString *)attributedText
{
    UIFont *currentFont = [self fontAtIndex:inRange.location withinText:attributedText];
    NSDictionary* currentAttributes = @{};
    
    NSString *colorHexString = @"";
    if([tagName containsString:@"="]){
        NSArray *myArray = [tagName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
        tagName = myArray[0];
        colorHexString = myArray[1];
    }
    
    
    if ([tagName isEqualToString:@"b"]) {
        currentAttributes = [self createAttributesForFontStyle:currentFont
                                                     withTrait:UIFontDescriptorTraitBold];
    } else if ([tagName isEqualToString:@"i"]) {
        currentAttributes = [self createAttributesForFontStyle:currentFont
                                                     withTrait:UIFontDescriptorTraitItalic];
    } else if ([tagName isEqualToString:@"u"]) {
        currentAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                                        forKey:NSUnderlineStyleAttributeName];
    } else if ([tagName isEqualToString:@"s"]) {
        currentAttributes = @{ NSStrikethroughStyleAttributeName : [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        
    } else if ([tagName isEqualToString:@"color"]) {
        currentAttributes = @{ NSBackgroundColorAttributeName : [LSColorHelper colorFromHexString:colorHexString]};
    }
    
    return currentAttributes;
}

- (NSDictionary*)createAttributesForFontStyle:(UIFont*)currentFont
                                    withTrait:(uint32_t)traitValue
{
    UIFontDescriptor *fontDescriptor = [currentFont fontDescriptor];
    
    if (!fontDescriptor) {
        fontDescriptor = [self.richTextConfiguration.initialTextAttributes[NSFontAttributeName] fontDescriptor];
    }
    
    UIFontDescriptorSymbolicTraits existingTraitsWithNewTrait = [fontDescriptor symbolicTraits] | traitValue;
    
    UIFontDescriptor *descriptorWithTrait = [fontDescriptor fontDescriptorWithSymbolicTraits:existingTraitsWithNewTrait];
    
    UIFont* font =  [UIFont fontWithDescriptor:descriptorWithTrait size: 0.0];
    
    if (!font) {
        // in this case the default system font is found and can't set new
        // descriptors, so we use the textview initial one.
        font = self.richTextConfiguration.initialTextAttributes[NSFontAttributeName];
    }
    
    return @{ NSFontAttributeName : font };
}



- (UIFont *)fontAtIndex:(NSInteger)index withinText:(NSAttributedString *)attributedText
{
    // If no text exists get font from typing attributes
    NSDictionary *dictionary = [attributedText attributesAtIndex:index effectiveRange:nil];
    
    return [dictionary objectForKey:NSFontAttributeName];
}



@end
