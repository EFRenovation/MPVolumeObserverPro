#import "MPVolumeObserverPro.h"

#define bg_dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface MPVolumeObserverPro()
{
    MPVolumeView   *_volumeView;
    BOOL            _isObservingVolumeButtons;
    BOOL            _suspended;
    int             Isfirst;
    NSString       *strNowVolume;
    
    NSInteger       secondsLastElapsed; //after second
    NSInteger       secondsElapsed;     //volume second
    
    float           fVolume;  //default volume
}

@end

@implementation MPVolumeObserverPro

+(MPVolumeObserverPro*) sharedInstance;
{
    static MPVolumeObserverPro *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MPVolumeObserverPro alloc] init];
    });
    return instance;
}


-(id)init
{
    self = [super init];
    if( self ){
        _isObservingVolumeButtons = NO;
        _suspended = NO;
        Isfirst = 0;
        secondsElapsed = 0;
        secondsLastElapsed = 2;
        CGRect frame = CGRectMake(0, -100, 0, 0);
        _volumeView = [[MPVolumeView alloc] initWithFrame:frame];
        [[UIApplication sharedApplication].windows[0] addSubview:_volumeView];
        
    }
    return self;
}


-(void)startObserveVolumeChangeEvents
{
    _suspended = NO;
    fVolume = [self volume];
    [self startObserve];
}


-(void)startObserve;
{
    Isfirst = 1;
    // NSLog(@"start add notification");
    if(_isObservingVolumeButtons)
    {
        return;
    }
    
    
    [[AVAudioSession sharedInstance] setActive:NO error: nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error: nil];
    
    _isObservingVolumeButtons = YES;
    strNowVolume = [[ NSString stringWithFormat:@"%f",[self volume] ] substringToIndex:4];
    strNowVolume = [strNowVolume  isEqualToString: @"0.00"] ? @"0.05" : strNowVolume;
    strNowVolume = [strNowVolume  isEqualToString: @"1.00"] ? @"0.95" : strNowVolume;
    if ([strNowVolume  isEqual: @"0.05"] || [strNowVolume isEqualToString:@"0.95"])
    {
        [self setVolume:[strNowVolume floatValue]];
    }
    if (!_suspended)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(suspendObserveVolumeChangeEvents:)
                                                     name:UIApplicationWillResignActiveNotification     // -> 离开前台
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeObserveVolumeButtonEvents:)
                                                     name:UIApplicationDidBecomeActiveNotification      // <- 进入前台
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChangeNotification:)
                                                     name:@"SystemVolumeDidChange" object:nil];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Isfirst = 0;
    });
}


//voice change
-(void)volumeChangeNotification:(NSNotification *) no
{
    // NSLog(@"%@", no);
    if (Isfirst == 1) {
        Isfirst = 0;
        return;
    }
    
    static id sender = nil;
    if (sender == nil && no.object) {
        sender = no.object;
    }
    NSString * NowChangeVolume = [[ NSString stringWithFormat:@"%f",[[no.userInfo objectForKey:@"AudioVolume"] floatValue] ] substringToIndex:4];
    if (no.object != sender || [NowChangeVolume isEqualToString: strNowVolume]) {
        return;
    }
    [self setVolume:[strNowVolume floatValue]];
    secondsElapsed++;

    if (secondsElapsed == 2) {
        //start video
        if ([self.delegate respondsToSelector:@selector(volumeButtonStarVideoClick:)]) {
            [self.delegate volumeButtonStarVideoClick:self];
        }
        //cancel doule click
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.11 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (2 == secondsElapsed) {
                if ([self.delegate respondsToSelector:@selector(volumeButtonEndVideoClick:)]) {
                    [self.delegate volumeButtonEndVideoClick:self];
                    secondsElapsed = 0;
                    secondsLastElapsed = 2;
                }
            }
        });
    }else{
        if (secondsElapsed>2) {
            // video ing
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.11 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                secondsLastElapsed++;

                if (secondsLastElapsed == secondsElapsed) {
                    if ([self.delegate respondsToSelector:@selector(volumeButtonEndVideoClick:)]) {
                        [self.delegate volumeButtonEndVideoClick:self];
                        secondsElapsed = 0;
                        secondsLastElapsed = 2;
                    }
                }
            });
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (secondsElapsed==2) {

                }else if(secondsElapsed==1){
                    //photo
                    secondsElapsed = 0;
                    [self tackPhoto];
                }else{
                }
            });

        }
    }
}


//tack photo
- (void)tackPhoto
{
    
//        NSLog(@"take Photo");
        if ([self.delegate respondsToSelector:@selector(volumeButtonCameraClick:)]) {
            [self.delegate volumeButtonCameraClick:self];
        }
    
}


- (void)suspendObserveVolumeChangeEvents:(NSNotification *)notification
{
    if(_isObservingVolumeButtons)
    {
        _suspended = YES; // Call first!
        [self stopObserveVolumeChangeEvents];
        Isfirst = 0;
    }
}



- (void)resumeObserveVolumeButtonEvents:(NSNotification *)notification
{
    if(_suspended)
    {
        Isfirst = 1;
        [self startObserveVolumeChangeEvents];
        _suspended = NO; // Call last!
        //fxxk first fake click
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            Isfirst = 0;
        });
    }
}



-(void)stopObserveVolumeChangeEvents
{
    // NSLog(@"stop notification");
    if(!_isObservingVolumeButtons){
        return;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SystemVolumeDidChange" object:nil];
    
    Isfirst = 0;
    secondsElapsed = 0;
    _isObservingVolumeButtons = NO;
    [[AVAudioSession sharedInstance] setActive:NO error: nil];
    
}

#pragma mark - voice change
- (float)volume
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat volume = audioSession.outputVolume;
    return volume;
}


- (void)setVolume:(float)newVolume
{
    bg_dispatch_main_async_safe(^{
        MPVolumeView* volumeView = [[MPVolumeView alloc] init];
        
        //find the volumeSlider
        UISlider* volumeViewSlider = nil;
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)view;
                break;
            }
        }
        
        [volumeViewSlider setValue:newVolume animated:YES];
        [volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
}


-(void)dealloc
{
    _suspended = NO;
    Isfirst = 0;
}

@end




