//
//  XIBObjCClassBuilder.m
//  xib2coder
//
//  Created by Gregory John Casamento on 4/4/24.
//

#import <Foundation/NSDictionary.h>
#import <Foundation/NSString.h>

#import "XIBObjCClassBuilder.h"
#import "XIBObjCAccessorBuilder.h"
#import "NSString+Additions.h"

@implementation XIBObjCClassBuilder

- (instancetype) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary: dictionary];
    if (self != nil)
    {
        self.header = @"";
        self.source = @"";
        self.coding = @"";
        self.attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *) buildClassMap
{
    NSDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                // @"XIBCustomObject", @"NSCustomObject",
                                @"NSNibOutletConnector", @"NSOutlet",
                                @"NSNibControlConnector", @"NSAction",
                                @"NSString", @"NSTaggedPointerString",
                                @"NSString", @"__NSCFConstantString",
                                @"NSString", @"__NSCFString",
                                nil];
    return dictionary;
}

// Class specific
- (NSString *) entityNameForElementName: (NSString *)elementName
{
    NSString *prefix = nil;
    NSString *result = nil;
    
    if ([self.runtime isEqualToString: @"MacOSX.Cocoa"])
    {
        prefix = @"NS";
    }
    else
    {
        prefix = @"UI";
    }
    
    result = [NSString stringWithFormat: @"%@%@", prefix, [elementName stringByCapitalizingFirstCharacter]];
    NSString *replacement = [self.classMapping objectForKey: result];
    
    if (replacement != nil)
    {
        result = replacement;
    }
    
    return result;
}

- (NSString *) typeForEntityValue: (id)o
{
    NSString *typeName = nil;

    if ([o isNumeric])
    {
        if ([o containsString: @"-"])
        {
            typeName = @"NSInteger";
        }
        else if ([o containsString: @"."])
        {
            typeName = @"CGFloat";
        }
        else
        {
            typeName =  @"NSUInteger";
        }
    }
    else
    {
        typeName = NSStringFromClass([o class]);
    }
    
    NSString *newType = [self.classMapping objectForKey: typeName];
    if (newType != nil)
    {
        typeName = newType;
    }
    
    
    return typeName;
}

// build method...
- (BOOL) build
{
    NSString *elementName = [self.dictionary objectForKey: @"elementName"];
    NSEnumerator *en = [self.dictionary keyEnumerator];
    id k = nil;
    
    self.className = [self entityNameForElementName: elementName];
    while ((k = [en nextObject]) != nil)
    {
        if ([self.skippedKeys containsObject: k])
        {
            continue;
        }
        
        id o = [self.dictionary objectForKey: k];
        if ([o isKindOfClass: [NSDictionary class]] == NO)
        {
            NSString *otype = [self typeForEntityValue: o];
            if (otype != nil)
            {
                [self.attributes setObject: otype forKey: k];
            }
            else
            {
                NSLog(@"OType is nil");
            }
        }
    }
    
    NSLog(@"className = %@, attributes = %@", self.className, self.attributes);
    
    return YES;
}

@end
