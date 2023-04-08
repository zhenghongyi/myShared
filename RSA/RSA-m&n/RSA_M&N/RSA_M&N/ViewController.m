//
//  ViewController.m
//  RSA_M&N
//
//  Created by 郑洪益 on 2022/6/12.
//

#import "ViewController.h"
#import "RSA.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString* result = [RSA encryptString:@"123" mod:@"a8b9fe573e72e838e9de31d588acecf04cc15850006e0f090f99cf1b45175e769c8530172689e5beb7604d1baf3ba0dcf833a59df62aaa1fabdf79a6b2e3f429" exp:@"010001"];
    NSLog(@"result:%@", result);
}

@end
