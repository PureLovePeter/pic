//
// MBProgressHUD.m
// Version 0.5
// Created by Matej Bukovinski on 2.4.09.
//

#import "MBProgressHUD.h"


#if __has_feature(objc_arc)
#define MB_AUTORELEASE(exp) exp
#define MB_RELEASE(exp) exp
#define MB_RETAIN(exp) exp
#else
#define MB_AUTORELEASE(exp) [exp autorelease]
#define MB_RELEASE(exp) [exp release]
#define MB_RETAIN(exp) [exp retain]
#endif


static const CGFloat kPadding = 4.f;
static const CGFloat kLabelFontSize = 16.f;
static const CGFloat kDetailsLabelFontSize = 13.f;


@interface MBProgressHUD ()

- (void)setupLabels;
- (void)registerForKVO;
- (void)unregisterFromKVO;
- (NSArray *)observableKeypaths;
- (void)registerForNotifications;
- (void)unregisterFromNotifications;
- (void)updateUIForKeypath:(NSString *)keyPath;
- (void)hideUsingAnimation:(BOOL)animated;
- (void)showUsingAnimation:(BOOL)animated;
- (void)done;
- (void)updateIndicators;
- (void)handleGraceTimer:(NSTimer *)theTimer;
- (void)handleMinShowTimer:(NSTimer *)theTimer;
- (void)setTransformForCurrentOrientation:(BOOL)animated;
- (void)cleanUp;
- (void)launchExecution;
- (void)deviceOrientationDidChange:(NSNotification *)notification;
- (void)hideDelayed:(NSNumber *)animated;

@property (atomic, MB_STRONG) UIView *indicator;
@property (atomic, MB_STRONG) NSTimer *graceTimer;
@property (atomic, MB_STRONG) NSTimer *minShowTimer;
@property (atomic, MB_STRONG) NSDate *showStarted;
@property (atomic, assign) CGSize size;

@end


@implementation MBProgressHUD {
    BOOL useAnimation;
    SEL methodForExecution;
    id targetForExecution;
    id objectForExecution;
    UILabel *label;
    UILabel *detailsLabel;
    BOOL isFinished;
    CGAffineTransform rotationTransform;
    
}

#pragma mark - Properties

@synthesize animationType;
@synthesize delegate;
@synthesize opacity;
@synthesize color;
@synthesize labelFont;
@synthesize detailsLabelFont;
@synthesize indicator;
@synthesize xOffset;
@synthesize yOffset;
@synthesize minSize;
@synthesize square;
@synthesize margin;
@synthesize dimBackground;
@synthesize graceTime;
@synthesize minShowTime;
@synthesize graceTimer;
@synthesize minShowTimer;
@synthesize taskInProgress;
@synthesize removeFromSuperViewOnHide;
@synthesize customView;
@synthesize showStarted;
@synthesize mode;
@synthesize labelText;
@synthesize detailsLabelText;
@synthesize detailsLabelAttText;
@synthesize progress;
@synthesize size;
#if NS_BLOCKS_AVAILABLE
@synthesize completionBlock;
#endif

#pragma mark - Class methods

+ (MBProgressHUD *)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:hud];
    [hud show:animated];
    return MB_AUTORELEASE(hud);
}

+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud != nil) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:animated];
        return YES;
    }
    return NO;
}

+ (NSUInteger)hideAllHUDsForView:(UIView *)view animated:(BOOL)animated {
    NSArray *huds = [self allHUDsForView:view];
    for (MBProgressHUD *hud in huds) {
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:animated];
    }
    return [huds count];
}

+ (MBProgressHUD *)HUDForView:(UIView *)view {
    Class hudClass = [MBProgressHUD class];
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:hudClass]) {
            return (MBProgressHUD *)subview;
        }
    }
    return nil;
}

+ (NSArray *)allHUDsForView:(UIView *)view {
    NSMutableArray *huds = [NSMutableArray array];
    NSArray *subviews = view.subviews;
    Class hudClass = [MBProgressHUD class];
    for (UIView *aView in subviews) {
        if ([aView isKindOfClass:hudClass]) {
            [huds addObject:aView];
        }
    }
    return [NSArray arrayWithArray:huds];
}

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Set default values for properties
        self.animationType = MBProgressHUDAnimationFade;
        self.mode = MBProgressHUDModeIndeterminate;
        self.labelText = nil;
        self.detailsLabelText = nil;
        self.opacity = 0.8f;
        self.color = [RGB_COLOR(0x00, 0x00, 0x00) colorWithAlphaComponent:0.5];
        self.labelFont = [UIFont boldSystemFontOfSize:kLabelFontSize];
        self.detailsLabelFont = [UIFont boldSystemFontOfSize:kDetailsLabelFontSize];
        self.xOffset = 0.0f;
        self.yOffset = 0.0f;
        self.dimBackground = NO;
        self.margin = 20.0f;
        self.graceTime = 0.0f;
        self.minShowTime = 0.0f;
        self.removeFromSuperViewOnHide = NO;
        self.minSize = CGSizeZero;
        self.square = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
								| UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        // Transparent background
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        // Make it invisible for now
        self.alpha = 0.0f;
        
        taskInProgress = NO;
        rotationTransform = CGAffineTransformIdentity;
        
        [self setupLabels];
        [self updateIndicators];
        [self registerForKVO];
        [self registerForNotifications];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    NSAssert(view, @"View must not be nil.");
    return [self initWithFrame:view.bounds];
}

- (id)initWithWindow:(UIWindow *)window {
    return [self initWithView:window];
}

- (void)dealloc {
    [self unregisterFromNotifications];
    [self unregisterFromKVO];
#if !__has_feature(objc_arc)
    [color release];
    [indicator release];
    [label release];
    [detailsLabel release];
    [labelText release];
    [detailsLabelText release];
    [graceTimer release];
    [minShowTimer release];
    [showStarted release];
    [customView release];
#if NS_BLOCKS_AVAILABLE
    [completionBlock release];
#endif
    [super dealloc];
#endif
}

#pragma mark - Show & hide

- (void)show:(BOOL)animated {
    useAnimation = animated;
    // If the grace time is set postpone the HUD display
    if (self.graceTime > 0.0) {
        self.graceTimer = [NSTimer scheduledTimerWithTimeInterval:self.graceTime target:self
                                                         selector:@selector(handleGraceTimer:) userInfo:nil repeats:NO];
    }
    // ... otherwise show the HUD imediately
    else {
        [self setNeedsDisplay];
        [self showUsingAnimation:useAnimation];
    }
}

- (void)hide:(BOOL)animated {
    useAnimation = animated;
    // If the minShow time is set, calculate how long the hud was shown,
    // and pospone the hiding operation if necessary
    if (self.minShowTime > 0.0 && showStarted) {
        NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:showStarted];
        if (interv < self.minShowTime) {
            self.minShowTimer = [NSTimer scheduledTimerWithTimeInterval:(self.minShowTime - interv) target:self
                                                               selector:@selector(handleMinShowTimer:) userInfo:nil repeats:NO];
            return;
        }
    }
    // ... otherwise hide the HUD immediately
    [self hideUsingAnimation:useAnimation];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    detailsLabel.numberOfLines = 5;
    [self performSelector:@selector(hideDelayed:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

- (void)hideDelayed:(NSNumber *)animated {
    [self hide:[animated boolValue]];
}

#pragma mark over Method
//展现MBProgressHUD的快捷方式
+ (void)showHUDInView:(NSString *)text andView:(UIView *)view startY:(CGFloat)startY
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.yOffset = startY;
    hud.labelText = text;
    hud.square = YES;
    [hud show:YES];
}
+ (MBProgressHUD*) showHudInView:(UIView *) view image:(UIImage*) img text:(NSString *) text afterdelay:(float)delay
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.customView = [[UIImageView alloc] initWithImage:img];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = text;
    [hud hide:YES afterDelay:delay];
    [view addSubview:hud];
    [hud show:YES];
    return hud;
}
+ (void)showCustomHUDInView:(NSString *)text andView:(UIView *)view{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if ([text isEqualToString:@""]) {
        text=nil;
    }
    hud.labelText = text;
    hud.square = YES;
    [hud show:YES];
    
    //    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //    [hud start];
    //    hud.customView =hud.imageView;
    //    hud.mode = MBProgressHUDModeCustomView;
    //    hud.square = NO;
    //    hud.color = [[UIColor whiteColor]colorWithAlphaComponent:0];
    //    [hud show:YES];
}

+ (void)showHUDInView:(NSString *)text andView:(UIView *)view{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    hud.square = YES;
    [hud show:YES];
}


+ (void)showHUDForViewFrameNotContainNavBarText:(NSString *)textStr
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:hud];
    hud.labelText = textStr;
    hud.square = YES;
    [hud show:true];
}

+(void)showHUD:(NSString *)text{
    UIWindow *window = [[UIApplication sharedApplication ] keyWindow] ;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.labelText = text;
    hud.square = YES;
    [hud show:YES];
}

//隐藏MBProgressHUD的方法
+ (void)hideHUDInView:(UIView *)view{
    
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

+(void)hideHUD{
    UIWindow *window = [[UIApplication sharedApplication ] keyWindow] ;
    [MBProgressHUD hideAllHUDsForView:window animated:YES];
}

+ (MBProgressHUD*)showHudAutoDisappearInView:(UIView *) view image:(UIImage*) img text:(NSString *) text
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.customView = [[UIImageView alloc] initWithImage:img];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = 5;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:kDetailsLabelFontSize], NSParagraphStyleAttributeName:paraStyle};
    hud.detailsLabelText = text;
    hud.detailsLabelAttText = [[NSMutableAttributedString alloc] initWithString:text attributes:dic];
    [hud hide:YES afterDelay:2];
    [view addSubview:hud];
    [hud show:YES];
    return hud;
}
+ (MBProgressHUD*) showCustomHUDInView:(UIView *) view image:(UIImage*) img text:(NSString *) text afterdelay:(float)delay
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.customView = [[UIImageView alloc] initWithImage:img];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = text;
    [hud hide:YES afterDelay:delay];
    [view addSubview:hud];
    [hud show:YES];
    return hud;
}

+ (MBProgressHUD*) showHudAutoDisappear:(UIImage*) img text:(NSString *) text{
    UIWindow *window = [[UIApplication sharedApplication ] keyWindow];
    //修复重复添加问题
    UIView *view = [window viewWithTag:999911];
    if (view) {
        return nil;
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
    hud.customView = [[UIImageView alloc] initWithImage:img];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
//    hud.labelText = text;
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = 5;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:kDetailsLabelFontSize], NSParagraphStyleAttributeName:paraStyle};
    hud.detailsLabelText = text;
    hud.detailsLabelAttText = [[NSMutableAttributedString alloc] initWithString:text attributes:dic];
    
    
    [hud hide:YES afterDelay:2];
    hud.tag = 999911;
    [window addSubview:hud];
    [hud show:YES];
    return hud;
}
+ (MBProgressHUD*) showHud:(UIImage*) img text:(NSString *) text afterdelay:(float)delay{
    
    UIWindow *window = [[UIApplication sharedApplication ] keyWindow];
    //修复重复添加问题
    UIView *view = [window viewWithTag:999911];
    if (view) {
        return nil;
    }
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:window];
    hud.customView = [[UIImageView alloc] initWithImage:img];
    hud.removeFromSuperViewOnHide = YES;
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = text;
    hud.tag = 999911;
    [hud hide:YES afterDelay:delay];
    [window addSubview:hud];
    [hud show:YES];
    return hud;
}


#pragma mark- custom



#pragma mark - Timer callbacks

- (void)handleGraceTimer:(NSTimer *)theTimer {
    // Show the HUD only if the task is still running
    if (taskInProgress) {
        [self setNeedsDisplay];
        [self showUsingAnimation:useAnimation];
    }
}

- (void)handleMinShowTimer:(NSTimer *)theTimer {
    [self hideUsingAnimation:useAnimation];
}

#pragma mark - View Hierrarchy

- (void)didMoveToSuperview {
    // We need to take care of rotation ourselfs if we're adding the HUD to a window
    if ([self.superview isKindOfClass:[UIWindow class]]) {
        [self setTransformForCurrentOrientation:NO];
    }
}

#pragma mark - Internal show & hide operations

- (void)showUsingAnimation:(BOOL)animated {
    if (animated && animationType == MBProgressHUDAnimationZoomIn) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
    } else if (animated && animationType == MBProgressHUDAnimationZoomOut) {
        self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
    }
    self.showStarted = [NSDate date];
    // Fade in
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        self.alpha = 1.0f;
        if (animationType == MBProgressHUDAnimationZoomIn || animationType == MBProgressHUDAnimationZoomOut) {
            self.transform = rotationTransform;
        }
        [UIView commitAnimations];
    }
    else {
        self.alpha = 1.0f;
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    // Fade out
    if (animated && showStarted) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
        // 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
        // in the done method
        if (animationType == MBProgressHUDAnimationZoomIn) {
            self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
        } else if (animationType == MBProgressHUDAnimationZoomOut) {
            self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
        }
        
        self.alpha = 0.02f;
        [UIView commitAnimations];
    }
    else {
        self.alpha = 0.0f;
        [self done];
    }
    
    self.showStarted = nil;
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
    [self done];
}

- (void)done {
    isFinished = YES;
    self.alpha = 0.0f;
    if ([delegate respondsToSelector:@selector(hudWasHidden:)]) {
        [delegate performSelector:@selector(hudWasHidden:) withObject:self];
    }
#if NS_BLOCKS_AVAILABLE
    if (self.completionBlock) {
        self.completionBlock();
        self.completionBlock = NULL;
    }
#endif
    if (removeFromSuperViewOnHide) {
        [self removeFromSuperview];
    }
}

#pragma mark - Threading

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated {
    methodForExecution = method;
    targetForExecution = MB_RETAIN(target);
    objectForExecution = MB_RETAIN(object);
    // Launch execution in new thread
    self.taskInProgress = YES;
    [NSThread detachNewThreadSelector:@selector(launchExecution) toTarget:self withObject:nil];
    // Show HUD view
    [self show:animated];
}

#if NS_BLOCKS_AVAILABLE

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self showAnimated:animated whileExecutingBlock:block onQueue:queue completionBlock:NULL];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block completionBlock:(void (^)())completion {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [self showAnimated:animated whileExecutingBlock:block onQueue:queue completionBlock:completion];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue {
    [self showAnimated:animated whileExecutingBlock:block onQueue:queue	completionBlock:NULL];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue
     completionBlock:(MBProgressHUDCompletionBlock)completion {
    self.taskInProgress = YES;
    self.completionBlock = completion;
    dispatch_async(queue, ^(void) {
        block();
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self cleanUp];
        });
    });
    [self show:animated];
}

#endif

- (void)launchExecution {
    @autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // Start executing the requested task
        [targetForExecution performSelector:methodForExecution withObject:objectForExecution];
#pragma clang diagnostic pop
        // Task completed, update view in main thread (note: view operations should
        // be done only in the main thread)
        [self performSelectorOnMainThread:@selector(cleanUp) withObject:nil waitUntilDone:NO];
    }
}

- (void)cleanUp {
    taskInProgress = NO;
    self.indicator = nil;
#if !__has_feature(objc_arc)
    [targetForExecution release];
    [objectForExecution release];
#else
    targetForExecution = nil;
    objectForExecution = nil;
#endif
    [self hide:useAnimation];
}

#pragma mark - UI

- (void)setupLabels {
    label = [[UILabel alloc] initWithFrame:self.bounds];
    label.adjustsFontSizeToFitWidth = NO;
    label.textAlignment = MBLabelAlignmentCenter;
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = self.labelFont;
    label.text = self.labelText;
    [self addSubview:label];
    
    detailsLabel = [[UILabel alloc] initWithFrame:self.bounds];
    detailsLabel.font = self.detailsLabelFont;
    detailsLabel.adjustsFontSizeToFitWidth = NO;
    detailsLabel.textAlignment = MBLabelAlignmentCenter;
    detailsLabel.opaque = NO;
    detailsLabel.backgroundColor = [UIColor clearColor];
    detailsLabel.textColor = [UIColor whiteColor];
    detailsLabel.numberOfLines = 0;
    detailsLabel.font = self.detailsLabelFont;
    detailsLabel.text = self.detailsLabelText;
    [self addSubview:detailsLabel];
}

- (void)updateIndicators {
    
    BOOL isActivityIndicator = [indicator isKindOfClass:[UIActivityIndicatorView class]];
    BOOL isRoundIndicator = [indicator isKindOfClass:[MBRoundProgressView class]];
    
    if (mode == MBProgressHUDModeIndeterminate &&  !isActivityIndicator) {
        // Update to indeterminate indicator
        [indicator removeFromSuperview];
        self.indicator = MB_AUTORELEASE([[UIActivityIndicatorView alloc]
                                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]);
        [(UIActivityIndicatorView *)indicator startAnimating];
        [self addSubview:indicator];
    }
    else if (mode == MBProgressHUDModeDeterminate || mode == MBProgressHUDModeAnnularDeterminate) {
        if (!isRoundIndicator) {
            // Update to determinante indicator
            [indicator removeFromSuperview];
            self.indicator = MB_AUTORELEASE([[MBRoundProgressView alloc] init]);
            [self addSubview:indicator];
        }
        if (mode == MBProgressHUDModeAnnularDeterminate) {
            [(MBRoundProgressView *)indicator setAnnular:YES];
        }
    }
    else if (mode == MBProgressHUDModeCustomView && customView != indicator) {
        // Update custom view indicator
        [indicator removeFromSuperview];
        self.indicator = customView;
        [self addSubview:indicator];
    } else if (mode == MBProgressHUDModeText) {
        [indicator removeFromSuperview];
        self.indicator = nil;
    }
}

#pragma mark - Layout

- (void)layoutSubviews {
    
    // Entirely cover the parent view
    UIView *parent = self.superview;
    if (parent) {
        self.frame = parent.bounds;
    }
    CGRect bounds = self.bounds;
    
    // Determine the total widt and height needed
    CGFloat maxWidth = bounds.size.width - 4 * margin;
    CGSize totalSize = CGSizeZero;
    
    CGRect indicatorF = indicator.bounds;
    indicatorF.size.width = MIN(indicatorF.size.width, maxWidth);
    totalSize.width = MAX(totalSize.width, indicatorF.size.width);
    totalSize.height += indicatorF.size.height;
    
    //[label.text sizeWithFont:label.font];
    CGSize labelSize = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    labelSize.width = MIN(labelSize.width, maxWidth);
    totalSize.width = MAX(totalSize.width, labelSize.width);
    totalSize.height += labelSize.height;
    if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
        totalSize.height += kPadding;
    }
    
    CGFloat remainingHeight = bounds.size.height - totalSize.height - kPadding - 4 * margin;
    
    CGSize maxSize = CGSizeMake(maxWidth, remainingHeight);
    //	CGSize detailsLabelSize = [detailsLabel.text sizeWithFont:detailsLabel.font
    //								constrainedToSize:maxSize lineBreakMode:detailsLabel.lineBreakMode];
    
    //增加行高显示
    CGRect detailsLabelFrame = CGRectZero;
    if (detailsLabelAttText.length > 0) {
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = 5;
        NSDictionary *dic = @{NSFontAttributeName:detailsLabel.font, NSParagraphStyleAttributeName:paraStyle};
        detailsLabelFrame = [detailsLabel.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
    }
    else {
        detailsLabelFrame = [detailsLabel.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:detailsLabel.font, NSFontAttributeName, nil] context:nil];
    }
    

    CGSize detailsLabelSize = detailsLabelFrame.size;
    
    totalSize.width = MAX(totalSize.width, detailsLabelSize.width);
    totalSize.height += detailsLabelSize.height;
    if (detailsLabelSize.height > 0.f && (indicatorF.size.height > 0.f || labelSize.height > 0.f)) {
        totalSize.height += kPadding;
    }
    
    totalSize.width += 2 * margin;
    totalSize.height += 2 * margin;
    
    
    // Position elements
    CGFloat yPos = roundf(((bounds.size.height - totalSize.height) / 2)) + margin + yOffset;
    CGFloat xPos = xOffset;
    indicatorF.origin.y = yPos;
    indicatorF.origin.x = roundf((bounds.size.width - indicatorF.size.width) / 2) + xPos;
    indicator.frame = indicatorF;
    yPos += indicatorF.size.height;
    
    if (labelSize.height > 0.f && indicatorF.size.height > 0.f) {
        yPos += kPadding;
    }
    CGRect labelF;
    labelF.origin.y = yPos;
    labelF.origin.x = roundf((bounds.size.width - labelSize.width) / 2) + xPos;
    labelF.size = labelSize;
    label.frame = labelF;
    yPos += labelF.size.height;
    
    if (detailsLabelSize.height > 0.f && (indicatorF.size.height > 0.f || labelSize.height > 0.f)) {
        yPos += kPadding;
    }
    CGRect detailsLabelF;
    detailsLabelF.origin.y = yPos;
    detailsLabelF.origin.x = roundf((bounds.size.width - detailsLabelSize.width) / 2) + xPos;
    detailsLabelF.size = detailsLabelSize;
    detailsLabel.frame = detailsLabelF;
    
    // Enforce minsize and quare rules
    if (square) {
        CGFloat max = MAX(totalSize.width, totalSize.height);
        if (max <= bounds.size.width - 2 * margin) {
            totalSize.width = max;
        }
        if (max <= bounds.size.height - 2 * margin) {
            totalSize.height = max;
        }
    }
    if (totalSize.width < minSize.width) {
        totalSize.width = minSize.width;
    }
    if (totalSize.height < minSize.height) {
        totalSize.height = minSize.height;
    }
    
    self.size = totalSize;
}

#pragma mark BG Drawing

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    if (self.dimBackground) {
        //Gradient colours
        size_t gradLocationsNum = 2;
        CGFloat gradLocations[2] = {0.0f, 1.0f};
        CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
        CGColorSpaceRelease(colorSpace);
        //Gradient center
        CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        //Gradient radius
        //		float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
        float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
        //Gradient draw
        CGContextDrawRadialGradient (context, gradient, gradCenter,
                                     0, gradCenter, gradRadius,
                                     kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
    }
    
    // Set background rect color
    if (self.color) {
        CGContextSetFillColorWithColor(context, self.color.CGColor);
    } else {
        CGContextSetGrayFillColor(context, 0.0f, self.opacity);
    }
    
    
    // Center HUD
    CGRect allRect = self.bounds;
    // Draw rounded HUD backgroud rect
    CGRect boxRect = CGRectMake(roundf((allRect.size.width - size.width) / 2) + self.xOffset,
                                roundf((allRect.size.height - size.height) / 2) + self.yOffset, size.width, size.height);
    float radius = 4.0f;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    UIGraphicsPopContext();
}

#pragma mark - KVO

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"mode", @"customView", @"labelText", @"labelFont",
            @"detailsLabelText", @"detailsLabelFont", @"progress", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    } else {
        [self updateUIForKeypath:keyPath];
    }
}

- (void)updateUIForKeypath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"mode"] || [keyPath isEqualToString:@"customView"]) {
        [self updateIndicators];
    } else if ([keyPath isEqualToString:@"labelText"]) {
        label.text = self.labelText;
    } else if ([keyPath isEqualToString:@"labelFont"]) {
        label.font = self.labelFont;
    } else if ([keyPath isEqualToString:@"detailsLabelText"]) {
        detailsLabel.text = self.detailsLabelText;
    } else if ([keyPath isEqualToString:@"detailsLabelFont"]) {
        detailsLabel.font = self.detailsLabelFont;
    } else if ([keyPath isEqualToString:@"progress"]) {
        if ([indicator respondsToSelector:@selector(setProgress:)]) {
            [(id)indicator setProgress:progress];
        }
        return;
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark - Notifications

- (void)registerForNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(deviceOrientationDidChange:)
               name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterFromNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIView *superview = self.superview;
    if (!superview) {
        return;
    } else if ([superview isKindOfClass:[UIWindow class]]) {
        [self setTransformForCurrentOrientation:YES];
    } else {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
}

- (void)setTransformForCurrentOrientation:(BOOL)animated {
    // Stay in sync with the superview
    if (self.superview) {
        self.bounds = self.superview.bounds;
        [self setNeedsDisplay];
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat radians = 0;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
        else { radians = (CGFloat)M_PI_2; }
        // Window coordinates differ!
        self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
    } else {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
        else { radians = 0; }
    }
    rotationTransform = CGAffineTransformMakeRotation(radians);
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
    }
    [self setTransform:rotationTransform];
    if (animated) {
        [UIView commitAnimations];
    }
}


















@end


@implementation MBRoundProgressView {
    float _progress;
    BOOL _annular;
}

#pragma mark - Properties

@synthesize progressTintColor = _progressTintColor;
@synthesize backgroundTintColor = _backgroundTintColor;

#pragma mark - Accessors

- (float)progress {
    return _progress;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (BOOL)isAnnular {
    return _annular;
}

- (void)setAnnular:(BOOL)annular {
    _annular = annular;
    [self setNeedsDisplay];
}

#pragma mark - Lifecycle

- (id)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _progress = 0.f;
        _annular = NO;
        _progressTintColor = [[UIColor alloc] initWithWhite:1.f alpha:1.f];
        _backgroundTintColor = [[UIColor alloc] initWithWhite:1.f alpha:.1f];
        [self registerForKVO];
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromKVO];
#if !__has_feature(objc_arc)
    [_progressTintColor release];
    [_backgroundTintColor release];
    [super dealloc];
#endif
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    
    CGRect allRect = self.bounds;
    CGRect circleRect = CGRectInset(allRect, 2.0f, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_annular) {
        // Draw background
        CGFloat lineWidth = 5.f;
        UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
        processBackgroundPath.lineWidth = lineWidth;
        processBackgroundPath.lineCapStyle = kCGLineCapRound;
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        CGFloat radius = (self.bounds.size.width - lineWidth)/2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (2 * (float)M_PI) + startAngle;
        [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_backgroundTintColor set];
        [processBackgroundPath stroke];
        // Draw progress
        UIBezierPath *processPath = [UIBezierPath bezierPath];
        processPath.lineCapStyle = kCGLineCapRound;
        processPath.lineWidth = lineWidth;
        endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
        [_progressTintColor set];
        [processPath stroke];
    } else {
        // Draw background
        [_progressTintColor setStroke];
        [_backgroundTintColor setFill];
        CGContextSetLineWidth(context, 2.0f);
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
        // Draw progress
        CGPoint center = CGPointMake(allRect.size.width / 2, allRect.size.height / 2);
        CGFloat radius = (allRect.size.width - 4) / 2;
        CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
        CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f); // white
        CGContextMoveToPoint(context, center.x, center.y);
        CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    }
}

#pragma mark - KVO

- (void)registerForKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *keyPath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keyPath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"progressTintColor", @"backgroundTintColor", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay];
}














@end
