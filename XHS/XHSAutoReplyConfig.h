#ifndef XHSAutoReplyConfig_h
#define XHSAutoReplyConfig_h

#import <Foundation/Foundation.h>

/**
 * 小函书配置管理类
 * 用于管理关键词自动回复的配置信息
 */
@interface XHSAutoReplyConfig : NSObject

/**
 * 获取共享配置实例
 * @return 配置单例对象
 */
+ (instancetype)sharedConfig;

/**
 * 关键词和对应回复的字典
 * key: 关键词
 * value: 对应的回复内容
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *keywordReplies;

/**
 * 是否启用自动回复
 */
@property (nonatomic, assign) BOOL isEnabled;

/**
 * 回复延迟时间（秒）
 */
@property (nonatomic, assign) NSTimeInterval replyDelay;

/**
 * 加载配置
 */
- (void)loadConfig;

/**
 * 保存配置
 */
- (void)saveConfig;

/**
 * 根据内容匹配关键词并返回对应的回复
 * @param content 需要匹配的内容
 * @return 匹配到的回复内容，如果没有匹配则返回nil
 */
- (NSString *)replyForKeyword:(NSString *)content;

@end

#endif /* XHSAutoReplyConfig_h */ 