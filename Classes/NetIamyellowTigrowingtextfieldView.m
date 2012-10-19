//
//   Copyright 2012 jordi domenech <jordi@iamyellow.net>
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "NetIamyellowTigrowingtextfieldView.h"
#import "TiHost.h"

@implementation NetIamyellowTigrowingtextfieldView

-(void)dealloc
{
    RELEASE_TO_NIL(textView);
    RELEASE_TO_NIL(entryImageView);
    RELEASE_TO_NIL(text);
    [super dealloc];
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    CGRect textViewFrame = CGRectMake(0, 4, frame.size.width, frame.size.height);
    CGRect entryImageFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
 
    if (textView == nil) {
        // init
        textView = [[HPGrowingTextView alloc] initWidthText:text ? text : @""];
        textView.delegate = self;

        // become first responder
        if ([TiUtils boolValue:[[self proxy] valueForKey:@"showKeyboardImmediately"] def:NO]) {
            [textView becomeFirstResponder];
        }
        
        // lines
        int minNumberOfLines = [TiUtils intValue:[[self proxy] valueForKey:@"minNumberOfLines"] def:1];
        int maxNumberOfLines = [TiUtils intValue:[[self proxy] valueForKey:@"maxNumberOfLines"] def:3];
        textView.minNumberOfLines = minNumberOfLines;
        textView.maxNumberOfLines = maxNumberOfLines;

        // return key type
        int returnKeyType = [TiUtils intValue:[[self proxy] valueForKey:@"returnKeyType"] def:UIReturnKeyDefault];
        textView.returnKeyType = returnKeyType;
        
        // appearance
        int appearance = [TiUtils intValue:[[self proxy] valueForKey:@"appearance"] def:UIKeyboardAppearanceDefault];
        textView.internalTextView.keyboardAppearance = appearance;
        
        // font
        UIFont* font = [[TiUtils fontValue:[[self proxy] valueForKey:@"font"] def:[WebFont defaultFont]] font];
        textView.font = font;
        
        // autocorrect
        BOOL autocorrect = [TiUtils boolValue:[[self proxy] valueForKey:@"autocorrect"] def:NO];
        textView.internalTextView.autocorrectionType = autocorrect ? UITextAutocorrectionTypeYes : UITextAutocorrectionTypeNo;

        // colors
        id pBackgroundColor = [[self proxy] valueForKey:@"backgroundColor"];
        if (pBackgroundColor) {
            textView.backgroundColor = [[TiUtils colorValue:pBackgroundColor] _color];
            self.backgroundColor = [[TiUtils colorValue:pBackgroundColor] _color];
        }
        else {
            textView.backgroundColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor whiteColor];
        }
        id pTextColor = [[self proxy] valueForKey:@"color"];
        if (pTextColor) {
            textView.textColor = [[TiUtils colorValue:pTextColor] _color];
        }
        
        // text alignment
        id pTextAlignment = [[self proxy] valueForKey:@"textAlign"];
        if (pTextAlignment) {
            textView.textAlignment = [TiUtils textAlignmentValue:pTextAlignment];
        }
        
        // add the text view
        [self addSubview: textView];

        // entry background image
        id pEntryImage = [[self proxy] valueForKey:@"backgroundImage"];
        if (pEntryImage) {
            int backgroundLeftCap = [TiUtils intValue:[[self proxy] valueForKey:@"backgroundLeftCap"] def:0],
            backgroundTopCap = [TiUtils intValue:[[self proxy] valueForKey:@"backgroundTopCap"] def:0];
            
            entryImageView = [[UIImageView alloc] init];
            entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            NSString* imgName = [[TiHost resourcePath] 
                                 stringByAppendingPathComponent:pEntryImage];
            [entryImageView setImage:[[UIImage imageWithContentsOfFile:imgName] stretchableImageWithLeftCapWidth:backgroundLeftCap topCapHeight:backgroundTopCap]];
            [TiUtils setView:entryImageView positionRect:entryImageFrame];
            [self addSubview: entryImageView];
        }
    }
    else {
        [TiUtils setView:textView positionRect:textViewFrame];
        [TiUtils setView:entryImageView positionRect:entryImageFrame];
    }
}

#pragma mark HPGrowingTextView Delegate

-(void)growingTextView:(HPGrowingTextView*)growingTextView willChangeHeight:(float)height
{
    viewHeight = height + 4;
    viewHeight = viewHeight > 40 ? viewHeight : 40;
    CGRect frame = textView.frame;
    frame.size.height = viewHeight;
    [(TiViewProxy*)[self proxy] setHeight:NUMFLOAT(viewHeight)];
}

-(void)growingTextViewDidChange:(HPGrowingTextView*)growingTextView
{
    RELEASE_TO_NIL(text);
    text = [growingTextView.text retain];
    
    TiProxy* proxy = [self proxy];
    if ([proxy _hasListeners:@"change"]) {
        NSMutableDictionary* event = [NSMutableDictionary dictionary];
        [event setObject:growingTextView.text forKey:@"value"];
        [event setObject:NUMFLOAT(viewHeight) forKey:@"height"];
        [proxy fireEvent:@"change" withObject:event];
    }
}

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    TiProxy* proxy = [self proxy];
    if ([proxy _hasListeners:@"focus"]) {
        [proxy fireEvent:@"focus" withObject:nil];
    }
}

-(void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    TiProxy* proxy = [self proxy];
    if ([proxy _hasListeners:@"blur"]) {
        [proxy fireEvent:@"blur" withObject:nil];
    }    
}

#pragma mark public API

-(NSString*)text
{
    if (text) {
        return text;
    }
    return NULL;
}

-(void)setText:(NSString*)pText
{
    if (textView == nil) {
        text = [pText retain];
    }
    else {
        ENSURE_UI_THREAD_1_ARG(pText);
        [textView setText:pText];
    }
}

-(void)focus
{
    if (textView) {
        ENSURE_UI_THREAD_0_ARGS;
        [textView becomeFirstResponder];
    }
}

-(void)blur
{
    if (textView) {
        ENSURE_UI_THREAD_0_ARGS;
        [textView resignFirstResponder];
    }
}

@end
