大部分情况下，iOS需要用到RSA加密，都是拿服务器下发的公钥进行加密，采用的[Objective-C-RSA](https://github.com/ideawu/Objective-C-RSA)库。但某些情况下，服务器不直接下发公钥，而是返回模数(mod)和指数(exp)，让客户端自己生成公钥进行加密。

相对来说，iOS没有提供直接可用的api，并且相关的资料比较少，在网上翻找了资料，这里做个踩坑记录。

先观察mod和exp，获取到的字符串，一般是一个表示十六进制的字符串，但也有时候这个字符串会经过base64。例如：

```
未经过base64
813048F76BB00F0765AD3EA7F89296D3F267C08A7B2F74594F21BD44FA48192D9E235EF371A425BCDBA3D6B894EA2EE9B2E70E123BD9B733086388F8821CEEECDA5C38F5FDF9AA3BD7C4A1FDE5C78860AE0EDD5305BC00D2AF73C3E19260A1B62E5DDD0214BDB161509E02AF7BECC5EA94B7F5106C48CFF19F5E6677C247BDFF

经过base64后
0E8fPw5rw/t1xobyTbXtZgLNYuBlX3RQy4re0SZerVGNW/LkN92Ycw+aLT0/9bxy/WuY63JOJFmZFVsIAnKhdfZLCoFQPq5nNJ1rUNfJ4J7FWvJoaM69IM/VA3GTdIRGQHgQJIXlXbiGOk+lJfo51Ncb67w2miqucsoS/YcgL0=
```
如果有base64，就需要做一次base64encode，然后再将字符串转成十六进制的data

```
+ (NSData *)bytesFromHexString:(NSString *)aString {
    NSString *theString = [[aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];

    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= theString.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [theString substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        if ([scanner scanHexInt:&intValue])
            [data appendBytes:&intValue length:1];
    }
    return data;
}
```
mod和exp的data经过处理，合并成公钥的data，这一步是最关键的，网上不同的资料，有时会导致生成不同的错误的data，最终导致公钥错误。（[iOS RSA密钥的生成与转换](https://www.jianshu.com/p/5ba276c6cd87)里的方法对1024bit的密钥的生成就是错误的）

iOS生成公钥，是利用钥匙串去生成的，根据mod和exp，还有相关的信息来生成。密钥的长度有分几种，512、1024、2048等等长度的，一般来说，系统会自动根据密钥长度去生成，不需要指定，但有些特殊情况也可以自己指定长度。

```
NSMutableDictionary *options = [NSMutableDictionary dictionary];
options[(__bridge id)kSecAttrKeyType] = (__bridge id) kSecAttrKeyTypeRSA;
options[(__bridge id)kSecAttrKeyClass] = (__bridge id) kSecAttrKeyClassPublic;
options[(id)kSecAttrKeySizeInBits] = @(1024);
```

