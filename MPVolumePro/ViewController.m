
#import "ViewController.h"
#import "MPVolumeObserverPro.h"

@interface ViewController ()<MPVolumeObserverProtocol>

    

@end
@class AVSystemController;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    
    [MPVolumeObserverPro sharedInstance].delegate = self;
    


    /*
     [[MPVolumeObserverPro sharedInstance]stopObserveVolumeChangeEvents];
     */
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[MPVolumeObserverPro sharedInstance]startObserveVolumeChangeEvents];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[MPVolumeObserverPro sharedInstance]stopObserveVolumeChangeEvents];
}


-(void) volumeButtonCameraClick:(MPVolumeObserverPro *) button
{
    NSLog(@"+take Photo+");
}

-(void) volumeButtonStarVideoClick:(MPVolumeObserverPro *) button
{
    NSLog(@"+start video+");
}

-(void) volumeButtonEndVideoClick:(MPVolumeObserverPro *) button
{
    NSLog(@"+end video+");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
