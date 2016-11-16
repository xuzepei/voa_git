//
//  RCHintView.m
//  VOA
//
//  Created by xuzepei on 9/30/12.
//
//

#import "RCHintView.h"

#define BG_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]

#define TITLE_COLOR [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]

#define TITLE_FONT [UIFont boldSystemFontOfSize:18.0]

#define TEXT_COLOR [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]

#define TEXT_FONT [UIFont boldSystemFontOfSize:18.0]

@interface RCHintView(Private)

@end

@implementation RCHintView
@synthesize _title;
@synthesize _text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:7.0].CGPath;
    CGContextAddPath(ctx, clippath);
    CGContextClip(ctx);
    
    [BG_COLOR set];
    UIRectFill(rect);
    
    CGContextRestoreGState(ctx);
    
    if([_title length])
    {
        [TITLE_COLOR set];
        [_title drawInRect:CGRectMake(0, 6, self.bounds.size.width, 28) withFont:TITLE_FONT
            lineBreakMode:NSLineBreakByTruncatingTail
                alignment:NSTextAlignmentCenter];
    }
    
    if([_text length])
    {
        [TEXT_COLOR set];
        [_text drawInRect:CGRectMake(0, 30, self.bounds.size.width, self.bounds.size.height - 30) withFont:TEXT_FONT
         lineBreakMode:NSLineBreakByTruncatingTail
         alignment:NSTextAlignmentCenter];
    }
    
}

- (void)updateContent:(NSString*)title text:(NSString*)text
{
    self._title = title;
    self._text = text;
    
    [self setNeedsDisplay];
}


@end
