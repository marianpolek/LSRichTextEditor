/*!
 * This file is part of LSTextEditor.
 *
 * Copyright © 2015 LShift Services GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Authors:
 * - Peter Lieder <peter@lshift.de>
 *
 */

#import "LSRichTextToolbar.h"
#import "LSToggleButton.h"
#import "LSCloseButton.h"
#import "LSColorHelper.h"
#import "LSColorsView.h"

#define BUTTON_WITH 40
#define BUTTON_TOP_AND_BOTTOM_BORDER 5
#define BUTTON_SEPARATOR_SPACE 5

@interface LSRichTextToolbar () <LSColorsViewDelegate>

@property (nonatomic, strong) LSToggleButton *buttonBold;
@property (nonatomic, strong) LSToggleButton *buttonItalic;
@property (nonatomic, strong) LSToggleButton *buttonUnderlined;
@property (nonatomic, strong) LSToggleButton *buttonStrikeThrough;
@property (nonatomic, strong) LSColorsView *buttonsWithColorButtons;

@end

@implementation LSRichTextToolbar

- (instancetype)initWithFrame:(CGRect)frame withDelegate:(id <LSRichTextToolbarDelegate>)delegate andConfiguration:(LSRichTextConfiguration *)configuration
{
    if (self = [super initWithFrame:frame])
    {
        self.delegate = delegate;
        self.richTextConfiguration = configuration;

        self.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1];
        self.layer.borderWidth = .7;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        [self setupButtons];
        [self setupToolbar];
    }
    
    return self;
}

- (void)setupButtons
{
    LSRichTextFeatures features = self.richTextConfiguration.configurationFeatures;

    self.hidden = (features & LSRichTextFeaturesNone) ? YES : NO;

    if (features & LSRichTextFeaturesBold || features & LSRichTextFeaturesAll) {
        self.buttonBold = [self createButtonWithTitle:@"B" andWidth:BUTTON_WITH andSelector:@selector(boldSelected:)];
    }

    if (features & LSRichTextFeaturesItalic || features & LSRichTextFeaturesAll) {
        self.buttonItalic = [self createButtonWithTitle:@"I" andWidth:BUTTON_WITH andSelector:@selector(italicSelected:)];
    }
    
    if (features & LSRichTextFeaturesUnderlined || features & LSRichTextFeaturesAll) {
        self.buttonUnderlined = [self createButtonWithTitle:@"U" andWidth:BUTTON_WITH andSelector:@selector(underlinedSelected:)];
    }
    
    if (features & LSRichTextFeaturesStrikeThrough || features & LSRichTextFeaturesAll) {
        self.buttonStrikeThrough = [self createButtonWithTitle:@"S" andWidth:BUTTON_WITH andSelector:@selector(strikeThroughSelected:)];
    }
    
    if (features & LSRichTextFeaturesBackgroundColor || features & LSRichTextFeaturesAll) {
        self.buttonsWithColorButtons = [self createButtonsWithColorsWithWidth:130];
    }
}

- (void)setupToolbar
{
    LSRichTextFeatures features = self.richTextConfiguration.configurationFeatures;

    if (features & LSRichTextFeaturesNone || features & LSRichTextFeaturesReadonly) {
        return;
    }

    UIView *previousView = nil;

    if (features & LSRichTextFeaturesBold || features & LSRichTextFeaturesAll) {
        [self addView:self.buttonBold afterView:previousView withSpacing:YES];
        previousView = self.buttonBold;
    }

    if (features & LSRichTextFeaturesItalic || features & LSRichTextFeaturesAll) {
        [self addView:self.buttonItalic afterView:previousView withSpacing:YES];
        previousView = self.buttonItalic;
    }
    
    if (features & LSRichTextFeaturesUnderlined || features & LSRichTextFeaturesAll) {
        [self addView:self.buttonUnderlined afterView:previousView withSpacing:YES];
        previousView = self.buttonUnderlined;
    }
    
    if (features & LSRichTextFeaturesStrikeThrough || features & LSRichTextFeaturesAll) {
        [self addView:self.buttonStrikeThrough afterView:previousView withSpacing:YES];
        previousView = self.buttonStrikeThrough;
    }
    
    if (features & LSRichTextFeaturesBackgroundColor || features & LSRichTextFeaturesAll) {
        [self addView:self.buttonsWithColorButtons afterView:previousView withSpacing:YES];
        previousView = self.buttonsWithColorButtons;
    }
}

- (LSToggleButton *)createButtonWithTitle:(NSString *)title andWidth:(NSInteger)width andSelector:(SEL)selector
{
    LSToggleButton *button = [[LSToggleButton alloc]initWithFrame:CGRectMake(0, 0, width, 0) andTitle:title];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(LSColorsView*)createButtonsWithColorsWithWidth:(NSInteger)width{
    
    LSColorsView *colorsView = [[LSColorsView alloc] initWithFrame:CGRectMake(0, 0, width, 0) toolbarHeight:self.frame.size.height];
    [colorsView setDelegate:self];
    return colorsView;
}

- (void)addView:(UIView *)view afterView:(UIView *)otherView withSpacing:(BOOL)space
{
    CGRect otherViewRect = (otherView) ? otherView.frame : CGRectZero;
    CGRect rect = view.frame;
    rect.origin.x = otherViewRect.size.width + otherViewRect.origin.x;
    if (space) {
        rect.origin.x += BUTTON_SEPARATOR_SPACE;
    }
    
    rect.origin.y = BUTTON_TOP_AND_BOTTOM_BORDER;
    rect.size.height = self.frame.size.height - (2*BUTTON_TOP_AND_BOTTOM_BORDER);
    view.frame = rect;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:view];
}

- (void)updateStateWithAttributes:(NSDictionary *)attributes
{
    UIFontDescriptor *fontDescriptor = [[attributes objectForKey:NSFontAttributeName] fontDescriptor];
    UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits = fontDescriptor.symbolicTraits;

    self.buttonBold.isActive = (fontDescriptorSymbolicTraits & UIFontDescriptorTraitBold);
    self.buttonItalic.isActive = (fontDescriptorSymbolicTraits & UIFontDescriptorTraitItalic);
    
    self.buttonUnderlined.isActive = [[attributes objectForKey:NSUnderlineStyleAttributeName] intValue] == 1;
    self.buttonStrikeThrough.isActive = [[attributes objectForKey:NSStrikethroughStyleAttributeName] intValue] == 1;
}

#pragma selectors

- (void)boldSelected:(LSToggleButton *)sender
{
    [self.delegate richTextToolbarDidSelectBold:sender.isActive];
}

- (void)italicSelected:(LSToggleButton *)sender
{
    [self.delegate richTextToolbarDidSelectItalic:sender.isActive];
}

- (void)underlinedSelected:(LSToggleButton *)sender
{
    [self.delegate richTextToolbarDidSelectUnderlined:sender.isActive];
}

- (void)strikeThroughSelected:(LSToggleButton *)sender
{
    [self.delegate richTextToolbarDidSelectStrikeThrough:sender.isActive];
}

- (void)backgroundColorSelected:(UIButton *)sender withColor:(UIColor*)color
{
    [self.delegate richTextToolbarDidSelectBackgroundColor:YES andColor:sender.backgroundColor];
}

#pragma layoutSubviews

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    NSInteger colorsViewWidth = self.frame.size.width - (2*BUTTON_SEPARATOR_SPACE) - self.buttonStrikeThrough.frame.origin.x - self.buttonStrikeThrough.frame.size.width;
    if(colorsViewWidth > ([LSColorsView listOfColors].count * [LSColorsView buttonWidth])){
        colorsViewWidth = [LSColorsView listOfColors].count * [LSColorsView buttonWidth];
    }
    [self.buttonsWithColorButtons setFrame:CGRectMake(self.buttonsWithColorButtons.frame.origin.x, self.buttonsWithColorButtons.frame.origin.y,colorsViewWidth , self.buttonsWithColorButtons.frame.size.height)];

}

@end
