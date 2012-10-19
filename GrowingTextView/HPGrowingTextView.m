//
//  HPTextView.m
//
//  Created by Hans Pinckaers on 29-06-10.
//
//	MIT License
//
//	Copyright (c) 2011 Hans Pinckaers
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

#import "HPGrowingTextView.h"

@interface HPGrowingTextView(private)
-(void)resizeTextView:(CGFloat)newSizeH;
@end

@implementation HPGrowingTextView
@synthesize internalTextView;
@synthesize delegate;

@synthesize font;
@synthesize textColor;
@synthesize textAlignment; 
@synthesize selectedRange;
@synthesize editable;
@synthesize dataDetectorTypes; 
@synthesize animateHeightChange;
@synthesize returnKeyType;

-(id)initWidthText:(NSString*)text
{
    if (self = [super init]) {
        // Initialization code
        CGRect r = self.frame;
        r.origin.y = 0;
        r.origin.x = 0;
        internalTextView = [[UITextView alloc] init];
        internalTextView.delegate = self;
        internalTextView.scrollEnabled = NO;
        internalTextView.showsVerticalScrollIndicator = NO;
        internalTextView.showsHorizontalScrollIndicator = NO;
        internalTextView.text = text;
        
        UIEdgeInsets insets = internalTextView.contentInset;
        insets.bottom = 10.0f;
        internalTextView.contentInset = insets;

        [self addSubview:internalTextView];
        
        minHeight = internalTextView.frame.size.height;
        minNumberOfLines = 1;
        animateHeightChange = NO;
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
	CGRect r = self.bounds;
	r.origin.y = 0;
	r.origin.x = 0;    
    internalTextView.frame = r;
}

-(void)setMaxNumberOfLines:(int)n
{
    NSString *newText = @"-";
    for (int i = 0; i < n; i++)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    UILabel* label = [[UILabel alloc] init];
    label.adjustsFontSizeToFitWidth = NO;
    label.numberOfLines = 0;
    label.text = newText;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.font = internalTextView.font;
    CGRect labelFrame = label.frame;
    labelFrame.size.width = 100;
    label.frame = labelFrame;
    [label sizeToFit];
    maxHeight = label.frame.size.height;
    maxNumberOfLines = n;
}

-(int)maxNumberOfLines
{
    return maxNumberOfLines;
}

-(void)setMinNumberOfLines:(int)m
{
    NSString *newText = @"-";
    for (int i = 1; i < m; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    UILabel* label = [[UILabel alloc] init];
    label.adjustsFontSizeToFitWidth = NO;
    label.numberOfLines = 0;
    label.text = newText;
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.font = internalTextView.font;
    CGRect labelFrame = label.frame;
    labelFrame.size.width = 100;
    label.frame = labelFrame;
    [label sizeToFit];
    minHeight = label.frame.size.height;
    
    minNumberOfLines = m;
}

-(int)minNumberOfLines
{
    return minNumberOfLines;
}


- (void)textViewDidChange:(UITextView *)textView
{	
	//size of content, so we can set the frame of self
	CGFloat newSizeH = internalTextView.contentSize.height;    
    
    /*if(newSizeH < minHeight || !internalTextView.hasText) {
        newSizeH = minHeight; //not smalles than minHeight
    }*/
    if (newSizeH > maxHeight) {
        newSizeH = maxHeight;
    }

    [self resizeTextView:newSizeH];
    if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
        [delegate growingTextView:self didChangeHeight:newSizeH];
    }
    
    
    // if our new height is greater than the maxHeight
    // sets not set the height or move things
    // around and enable scrolling
    if (newSizeH >= maxHeight)
    {
        if(!internalTextView.scrollEnabled){
            internalTextView.scrollEnabled = YES;
            [internalTextView flashScrollIndicators];
        }
        
    }
    else {
        internalTextView.scrollEnabled = NO;
    }
	
	if ([delegate respondsToSelector:@selector(growingTextViewDidChange:)]) {
		[delegate growingTextViewDidChange:self];
	}
	
}

-(void)resizeTextView:(CGFloat)newSizeH
{
    if ([delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
        [delegate growingTextView:self willChangeHeight:newSizeH];
    }
    
    CGRect internalTextViewFrame = self.frame;
    internalTextViewFrame.size.height = newSizeH;
    self.frame = internalTextViewFrame;
    
    internalTextViewFrame.origin.y = 0;
    internalTextViewFrame.origin.x = 0;
    internalTextViewFrame.size.width = internalTextView.contentSize.width;
    
    internalTextView.frame = internalTextViewFrame;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [internalTextView becomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    return [self.internalTextView becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	return [internalTextView resignFirstResponder];
}

-(BOOL)isFirstResponder
{
  return [self.internalTextView isFirstResponder];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextView properties
///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setText:(NSString *)newText
{
    internalTextView.text = newText;
    
    // include this line to analyze the height of the textview.
    // fix from Ankit Thakur
    [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

-(NSString*) text
{
    return internalTextView.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setFont:(UIFont *)afont
{
	internalTextView.font= afont;
	
	[self setMaxNumberOfLines:maxNumberOfLines];
	[self setMinNumberOfLines:minNumberOfLines];
}

-(UIFont *)font
{
	return internalTextView.font;
}	

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setTextColor:(UIColor *)color
{
	internalTextView.textColor = color;
}

-(UIColor*)textColor{
	return internalTextView.textColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
  [super setBackgroundColor:backgroundColor];
	internalTextView.backgroundColor = backgroundColor;
}

-(UIColor*)backgroundColor
{
  return internalTextView.backgroundColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setTextAlignment:(UITextAlignment)aligment
{
	internalTextView.textAlignment = aligment;
}

-(UITextAlignment)textAlignment
{
	return internalTextView.textAlignment;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setSelectedRange:(NSRange)range
{
	internalTextView.selectedRange = range;
}

-(NSRange)selectedRange
{
	return internalTextView.selectedRange;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setEditable:(BOOL)beditable
{
	internalTextView.editable = beditable;
}

-(BOOL)isEditable
{
	return internalTextView.editable;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setReturnKeyType:(UIReturnKeyType)keyType
{
	internalTextView.returnKeyType = keyType;
}

-(UIReturnKeyType)returnKeyType
{
	return internalTextView.returnKeyType;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically
{
  internalTextView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
}

- (BOOL)enablesReturnKeyAutomatically
{
  return internalTextView.enablesReturnKeyAutomatically;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector
{
	internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes
{
	return internalTextView.dataDetectorTypes;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)hasText{
	return [internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range
{
	[internalTextView scrollRangeToVisible:range];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)]) {
		return [delegate growingTextViewShouldBeginEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)]) {
		return [delegate growingTextViewShouldEndEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
		[delegate growingTextViewDidBeginEditing:self];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView {		
	if ([delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
		[delegate growingTextViewDidEndEditing:self];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext {
	
	//weird 1 pixel bug when clicking backspace when textView is empty
	if(![textView hasText] && [atext isEqualToString:@""]) return NO;
	
	//Added by bretdabaker: sometimes we want to handle this ourselves
    	if ([delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
        	return [delegate growingTextView:self shouldChangeTextInRange:range replacementText:atext];
	
	if ([atext isEqualToString:@"\n"]) {
		if ([delegate respondsToSelector:@selector(growingTextViewShouldReturn:)]) {
			if (![delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self]) {
				return YES;
			} else {
				[textView resignFirstResponder];
				return NO;
			}
		}
	}
	
	return YES;
	
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewDidChangeSelection:)]) {
		[delegate growingTextViewDidChangeSelection:self];
	}
}



@end
