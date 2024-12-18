#import "XHSAutoReplyConfig.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// 声明评论管理器接口
@interface XHSCommentManager : NSObject
- (void)sendReply:(NSString *)text 
      toCommentId:(NSString *)commentId 
       completion:(void(^)(BOOL success, NSError *error))completion;
@end

// 声明评论视图控制器接口
@interface XHSCommentViewController : UIViewController
@property (nonatomic, strong) XHSCommentManager *commentManager;
@property (nonatomic, strong) UIButton *settingsButton;

// 添加方法声明
- (void)setupAutoReply;
- (void)handleNewComment:(NSNotification *)notification;
- (void)sendAutoReply:(NSString *)replyText toComment:(NSDictionary *)commentInfo;
- (void)showSettings;
- (void)closeSettings:(UIButton *)sender;
- (void)switchChanged:(UISwitch *)sender;
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture;
- (void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change 
                      context:(void *)context;
@end

%hook XHSCommentViewController

- (void)viewDidLoad {
    %orig;
    
    // 创建并配置设置按钮
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingsButton.frame = CGRectMake(
        self.view.bounds.size.width - 60,  // 距离右边20点
        self.view.bounds.size.height - 100, // 距离底部100点
        50,  // 宽度50点
        30   // 高度30点
    );
    
    // 设置按钮样式
    self.settingsButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3]; // 半透明黑色背景
    self.settingsButton.layer.cornerRadius = 15; // 圆角
    self.settingsButton.clipsToBounds = YES;
    [self.settingsButton setTitle:@"设置" forState:UIControlStateNormal];
    [self.settingsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // 白色文字
    self.settingsButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.settingsButton.alpha = 0.0; // 初始时隐藏
    
    // 确保按钮始终在正确位置
    [self.view addObserver:self 
               forKeyPath:@"bounds" 
                  options:NSKeyValueObservingOptionNew 
                  context:nil];
    
    // 添加到视图
    [self.view addSubview:self.settingsButton];
    
    // 添加自动回复功能
    [self setupAutoReply];
    
    // 添加两指长按手势
    UILongPressGestureRecognizer *twoFingerLongPress = [[UILongPressGestureRecognizer alloc] 
                                                        initWithTarget:self 
                                                        action:@selector(handleLongPress:)];
    twoFingerLongPress.minimumPressDuration = 0.5; // 0.5秒长按
    twoFingerLongPress.numberOfTouchesRequired = 2; // 需要两个手指
    [self.view addGestureRecognizer:twoFingerLongPress];
    
    // 添加提示标签
    UILabel *hintLabel = [[UILabel alloc] init];
    hintLabel.text = @"两指长按显示设置";
    hintLabel.font = [UIFont systemFontOfSize:10];
    hintLabel.textColor = [UIColor lightGrayColor];
    hintLabel.alpha = 0.5;
    hintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hintLabel];
    
    // 设置提示标签约束
    [NSLayoutConstraint activateConstraints:@[
        [hintLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-10],
        [hintLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];
    
    // 3秒后隐藏提示
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), 
                  dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            hintLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [hintLabel removeFromSuperview];
        }];
    });
}

%new
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // 震动反馈
        UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [generator prepare];
        [generator impactOccurred];
        
        // 显示设置按钮
        [UIView animateWithDuration:0.3 animations:^{
            self.settingsButton.alpha = 1.0;
        }];
        
        // 5秒后自动隐藏
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), 
                      dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                self.settingsButton.alpha = 0.0;
            }];
        });
    }
}

%new
- (void)showSettings {
    // 创建设置视图
    UIView *settingsView = [[UIView alloc] init];
    settingsView.backgroundColor = [UIColor whiteColor];
    settingsView.layer.cornerRadius = 10;
    settingsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 添加阴影效果
    settingsView.layer.shadowColor = [UIColor blackColor].CGColor;
    settingsView.layer.shadowOffset = CGSizeMake(0, 2);
    settingsView.layer.shadowRadius = 4;
    settingsView.layer.shadowOpacity = 0.2;
    
    // 添加标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"小函书设置";
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [settingsView addSubview:titleLabel];
    
    // 添加开关
    UISwitch *enableSwitch = [[UISwitch alloc] init];
    enableSwitch.on = [XHSAutoReplyConfig sharedConfig].isEnabled;
    [enableSwitch addTarget:self 
                    action:@selector(switchChanged:) 
          forControlEvents:UIControlEventValueChanged];
    enableSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [settingsView addSubview:enableSwitch];
    
    // 添加关键词输入框
    UITextView *keywordsTextView = [[UITextView alloc] init];
    keywordsTextView.text = [[XHSAutoReplyConfig sharedConfig].keywordReplies.allKeys 
                            componentsJoinedByString:@"\n"];
    keywordsTextView.layer.borderWidth = 1;
    keywordsTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    keywordsTextView.font = [UIFont systemFontOfSize:14];
    keywordsTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [settingsView addSubview:keywordsTextView];
    
    // 添加关闭按钮
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton addTarget:self 
                   action:@selector(closeSettings:) 
         forControlEvents:UIControlEventTouchUpInside];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [settingsView addSubview:closeButton];
    
    // 添加到当前视图
    [self.view addSubview:settingsView];
    
    // 设置约束
    [NSLayoutConstraint activateConstraints:@[
        [settingsView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [settingsView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [settingsView.widthAnchor constraintEqualToConstant:300],
        [settingsView.heightAnchor constraintEqualToConstant:400],
        
        [titleLabel.topAnchor constraintEqualToAnchor:settingsView.topAnchor constant:20],
        [titleLabel.centerXAnchor constraintEqualToAnchor:settingsView.centerXAnchor],
        
        [enableSwitch.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:20],
        [enableSwitch.leadingAnchor constraintEqualToAnchor:settingsView.leadingAnchor constant:20],
        
        [keywordsTextView.topAnchor constraintEqualToAnchor:enableSwitch.bottomAnchor constant:20],
        [keywordsTextView.leadingAnchor constraintEqualToAnchor:settingsView.leadingAnchor constant:20],
        [keywordsTextView.trailingAnchor constraintEqualToAnchor:settingsView.trailingAnchor constant:-20],
        [keywordsTextView.heightAnchor constraintEqualToConstant:200],
        
        [closeButton.bottomAnchor constraintEqualToAnchor:settingsView.bottomAnchor constant:-20],
        [closeButton.centerXAnchor constraintEqualToAnchor:settingsView.centerXAnchor]
    ]];
}

%new
- (void)closeSettings:(UIButton *)sender {
    [sender.superview removeFromSuperview];
}

%new
- (void)setupAutoReply {
    // 监听新评论通知
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                           selector:@selector(handleNewComment:) 
                                               name:@"XHSNewCommentNotification" 
                                             object:nil];
}

%new
- (void)handleNewComment:(NSNotification *)notification {
    if (![XHSAutoReplyConfig sharedConfig].isEnabled) {
        return;
    }
    
    // 获取评论内容
    NSDictionary *commentInfo = notification.userInfo;
    NSString *commentText = commentInfo[@"content"];
    
    // 获取匹配的回复
    NSString *replyText = [[XHSAutoReplyConfig sharedConfig] replyForKeyword:commentText];
    if (replyText) {
        [self sendAutoReply:replyText toComment:commentInfo];
    }
}

%new
- (void)sendAutoReply:(NSString *)replyText toComment:(NSDictionary *)commentInfo {
    if (!self.commentManager) {
        NSLog(@"[小函书] 错误：commentManager 为空");
        return;
    }
    
    NSString *commentId = commentInfo[@"commentId"];
    if (!commentId) {
        NSLog(@"[小函书] 错误：评论ID为空");
        return;
    }
    
    // 调用小红书原生的回复方法
    [self.commentManager sendReply:replyText 
                      toCommentId:commentId 
                       completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"[小函书] 自动回复成功：%@", replyText);
        } else {
            NSLog(@"[小函书] 自动回复失败：%@", error);
        }
    }];
}

%new
- (void)switchChanged:(UISwitch *)sender {
    [XHSAutoReplyConfig sharedConfig].isEnabled = sender.isOn;
    [[XHSAutoReplyConfig sharedConfig] saveConfig];
}

%end 