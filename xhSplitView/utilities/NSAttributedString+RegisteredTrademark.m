//
//  RegisteredTrademark.m
//  utc
//
//  Created by Evan Buxton on 1/12/15.
//  Copyright (c) 2015 Neoscape. All rights reserved.
//

#import "NSAttributedString+RegisteredTrademark.h"

#define kshowNSLogBOOL NO

@implementation NSAttributedString (RegisteredTrademark)


- (NSAttributedString *)addRegisteredTrademarkTo:(NSString*)text withColor:(UIColor*)clr fnt:(UIFont*)fnt
{
    NSRange range = NSMakeRange(0,text.length);

    // text into astring
    NSMutableAttributedString *rawAttString=[[NSMutableAttributedString alloc] initWithString:text];
    [rawAttString addAttribute:NSFontAttributeName
              value:fnt
              range:range];
    [rawAttString addAttribute:NSForegroundColorAttributeName
                         value:clr
                         range:range];

    // format r symbol
    UIFont *boldFont = [UIFont fontWithName:@"Helvetica" size:12];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"®"
                                                                                         attributes:@{NSFontAttributeName:boldFont,
                                                                                                      NSForegroundColorAttributeName:clr,
                                                                                                      NSBaselineOffsetAttributeName : @4,
                                                                                                      }];
    // look for this match
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@":" options:kNilOptions error:nil];
    
    // array to hold nsranges
    NSMutableArray *symbolRanges = [[NSMutableArray alloc] init];
    
    // replace
    [regex enumerateMatchesInString:text options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSRange subStringRange = [result range];
        
        [symbolRanges addObject:[NSNumber numberWithInteger:subStringRange.location]];
        
        if (kshowNSLogBOOL) NSLog(@"my range is %@", NSStringFromRange(subStringRange));
        //Then sub in your your replacement:
        [rawAttString replaceCharactersInRange:subStringRange withAttributedString:attributedString];
        
    }];
    
    
    // resize to proper font weight
    NSMutableAttributedString *t = [[NSMutableAttributedString alloc] initWithAttributedString:rawAttString];

    return [t copy];
}

@end
