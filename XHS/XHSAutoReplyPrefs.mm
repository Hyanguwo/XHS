#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "XHSAutoReplyConfig.h"

@interface XHSAutoReplyPrefsController : PSListController
@end

@implementation XHSAutoReplyPrefsController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"小函书";
    }
    return self;
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];
    
    NSString *key = [specifier propertyForKey:@"key"];
    if ([key isEqualToString:@"keywordReplies"]) {
        // 解析关键词回复设置
        NSArray *lines = [value componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSMutableDictionary *replies = [NSMutableDictionary dictionary];
        
        for (NSString *line in lines) {
            NSArray *parts = [line componentsSeparatedByString:@"="];
            if (parts.count == 2) {
                NSString *keyword = [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *reply = [parts[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if (keyword.length > 0 && reply.length > 0) {
                    replies[keyword] = reply;
                }
            }
        }
        
        [XHSAutoReplyConfig sharedConfig].keywordReplies = replies;
    } else if ([key isEqualToString:@"isEnabled"]) {
        [XHSAutoReplyConfig sharedConfig].isEnabled = [value boolValue];
    } else if ([key isEqualToString:@"replyDelay"]) {
        [XHSAutoReplyConfig sharedConfig].replyDelay = [value doubleValue];
    }
    
    [[XHSAutoReplyConfig sharedConfig] saveConfig];
}

@end 