//
//  ViewController.m
//  RSA-m&n
//
//  Created by 郑洪益 on 2021/9/10.
//

#import "ViewController.h"
#import "RSA.h"

@interface ViewController ()

@property (nonatomic, copy) NSString* encrypted;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 1024bit
    self.encrypted = [RSA encryptString:@"123" mod:@"813048F76BB00F0765AD3EA7F89296D3F267C08A7B2F74594F21BD44FA48192D9E235EF371A425BCDBA3D6B894EA2EE9B2E70E123BD9B733086388F8821CEEECDA5C38F5FDF9AA3BD7C4A1FDE5C78860AE0EDD5305BC00D2AF73C3E19260A1B62E5DDD0214BDB161509E02AF7BECC5EA94B7F5106C48CFF19F5E6677C247BDFF" exp:@"010001"];
    // 1024bit
    self.encrypted = [RSA encryptString:@"123" mod:@"957fafdf6cf2ddacf2b1d6fa00aabee988c2b6d56f5762d59eb90043564da0739a17efa9ac4066369424bb7d0b1d7f59553e399385544e0d0d18fc3051198e73d87af3366e373bf0642f653911684f26fc9f4459c75d4b32e4e990379737e91a64f90c03fa82ada8824052ca00cde8b666ba575bcfa61038fbd3bb7c048273f1" exp:@"010001"];
    // 512bit
    self.encrypted = [RSA encryptString:@"123" mod:@"a8b9fe573e72e838e9de31d588acecf04cc15850006e0f090f99cf1b45175e769c8530172689e5beb7604d1baf3ba0dcf833a59df62aaa1fabdf79a6b2e3f429" exp:@"010001"];
}

- (void)setEncrypted:(NSString *)encrypted {
    _encrypted = encrypted;
    NSLog(@"encrypted:%@", encrypted);
}


@end
