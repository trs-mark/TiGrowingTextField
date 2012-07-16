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
    [super dealloc];
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    CGRect textViewFrame = CGRectMake(0, 6, bounds.size.width, bounds.size.height - 3);
    CGRect entryImageFrame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);

    if (textView == nil) {
        // init
        textView = [[HPGrowingTextView alloc] initWithFrame:textViewFrame];
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

        id value = [[self proxy] valueForKey:@"value"];
        if (value) {
            [self setText:value];
        }
    }
    else {
        [TiUtils setView:textView positionRect:textViewFrame];
        [TiUtils setView:entryImageView positionRect:entryImageFrame];
    }

    [textView layoutSubviews];
}

#pragma mark HPGrowingTextView Delegate

-(void)growingTextView:(HPGrowingTextView*)growingTextView willChangeHeight:(float)height
{
    CGRect frame = self.frame;
    frame.size.height -= growingTextView.frame.size.height - height;
    
    viewHeight = frame.size.height < 40 ? 40 : frame.size.height;
    [(TiViewProxy*)[self proxy] setHeight:NUMFLOAT(viewHeight)];
}

-(void)growingTextViewDidChange:(HPGrowingTextView*)growingTextView
{
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
    return textView.text;
}

-(void)setText:(NSString*)pText
{
    ENSURE_UI_THREAD_1_ARG(pText);
    [textView setText:pText];
}

-(void)focus
{
    ENSURE_UI_THREAD_0_ARGS;
    [textView becomeFirstResponder];
}

-(void)blur
{
    ENSURE_UI_THREAD_0_ARGS;
    [textView resignFirstResponder];
}

@end
