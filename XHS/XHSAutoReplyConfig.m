#import "XHSAutoReplyConfig.h"

@implementation XHSAutoReplyConfig

+ (instancetype)sharedConfig {
    static XHSAutoReplyConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance loadConfig];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _keywordReplies = @{
            @"推荐": @"感谢推荐",
            @"分享": @"谢谢分享",
            @"好看": @"确实不错",
            @"打卡": @"已打卡"
        };
        _isEnabled = YES;
        _replyDelay = 2.0;
    }
    return self;
}

- (void)loadConfig {
    NSString *configPath = @"/var/mobile/Library/Preferences/com.hyangu.xhsautoreply.plist";
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:configPath];
    
    if (config) {
        _keywordReplies = config[@"keywordReplies"] ?: _keywordReplies;
        _isEnabled = [config[@"isEnabled"] boolValue];
        _replyDelay = [config[@"replyDelay"] doubleValue];
    }
}

- (void)saveConfig {
    NSString *configPath = @"/var/mobile/Library/Preferences/com.hyangu.xhsautoreply.plist";
    NSDictionary *config = @{
        @"keywordReplies": self.keywordReplies,
        @"isEnabled": @(self.isEnabled),
        @"replyDelay": @(self.replyDelay)
    };
    [config writeToFile:configPath atomically:YES];
}

- (NSString *)replyForKeyword:(NSString *)content {
    if (!content || content.length == 0) return nil;
    
    for (NSString *keyword in self.keywordReplies.allKeys) {
        if ([content containsString:keyword]) {
            return self.keywordReplies[keyword];
        }
    }
    return nil;
}

@end 