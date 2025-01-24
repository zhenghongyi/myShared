# S/MIME 

S/MIME 安全/多用途互联网邮件扩展协议，英文全称 Secure/Multipurpose Internet Mail Extensions，是一种对电子邮件进行数字签名和加密的安全协议，可确保电子邮件在接收时的完整性。如 Microsoft Outlook、Thunderbird 和 Apple Mail 等大多数电子邮件服务和客户端都支持该协议。

#### S/MIME 如何进行加密和签名保护邮件安全？

S/MIME 一般在电子邮件通过互联网发送之前对其内容及其附件进行加密和签名，其利用遵循 S/MIME 协议的数字证书（即 S/MIME 证书）进行数字签名来验证真实性和发送加密电子邮件。

* 数字签名：使用数字证书进行数字签名来验证发件人真实身份和信息内容的真实性以及不可否认性。
* 内容加密：基于非对称加密方法，使用私钥与收件人的公开密钥一起发送加密邮件，再使用私钥对收到的邮件进行解密，确保电子邮件在传输过程中不会被窃听和篡改，除授权收件人外，任何人都无法读取电子邮件内容。

总结：即在 MIME 的基础上，对其进行加密或数字签名，以达到被防止窃取和篡改的效果。
> 本文不对 MIME 协议进行展开，默认是了解 MIME 协议

#### S/MIME 相关技术

通常S/MIME都会用到OpenSSL，其中密钥对会用到PKCS#12，加密或签名会以PKCS#7进行填充。

## 证书

S/MIME 的签名信或者加密信，都是需要用到对应的证书进行加密/签名。常见的有 PEM、P12、PFX 等格式的证书。

* .p12/.pfx
	* PKCS#12 标准格式的文件。包含私钥、证书和证书链
	* 可用命令`openssl pkcs12 -info -in certificate.pfx`输出其中内容，增加`-nokeys`则省略私钥
* .cer/.crt
	* 通常用于存储 X509 格式的公钥证书。只包含 DER 格式或 PEM 格式的公钥证书。
* .pem
	* 通用的 ASCII 编码的密钥和证书格式文件。包含公钥、私钥或者证书。
* .key
	* 私钥内容，通常以 PEM 格式存储的二进制数据。通常是`-----BEGIN PRIVATE KEY-----xxx-----END PRIVATE KEY-----`格式，如果是加密的私钥，则是`-----BEGIN ENCRYPTED PRIVATE KEY-----xxx-----END ENCRYPTED PRIVATE KEY-----`，加密私钥需要配合密码一起使用。

其中 P12 和 PFX 都是采用 PKCS#12 标准格式的文件，可以通过 OpenSSL 进行解析，但需要注意的是，OpenSSL 3.x 版本默认不支持 OpenSSL 1.x 的旧的算法生成的 p12，如果3.x要启用旧算法，需要在编译OpenSSL库时进行指定，或者如果自身系统平台支持，也可以通过自身平台系统能力进行解析。

用命令`
openssl pkcs12 -in a@smime.cn.p12 -nodes -provider legacy -provider default -out temp | openssl pkcs12 -in temp -export -out new.p12 | openssl pkcs12 -info -in new.p12`可让3.x版本OpenSSL采用低版本方式解析 p12 文件，输出为 temp 文件，并再次转换为当前版本的 p12 文件，最终再输出 p12 文件内容。

```
* PEM 格式：是一种基于 Base64 编码的，可查看的文本格式，以"-----BEGIN"开头“-----END”结尾。查看 PEM 格式证书的信息可通过命令：openssl x509 -in cer.pem -text -noout
* DER 格式：ASN.1 的序列化格式，无法直接查看。可以通过 OpenSSL 命令转换为 PEM 格式。
```
X509 公钥证书结构如下：

* 公钥算法
* 主体公钥
* 此日期前无效
* 此日期后无效
* 版本号
* 序列号
* 签名算法
* 颁发者
* 使用者
* 证书有效期
* ...

其中颁发者 issuer 结构：

```
"C=CN/O=xx/CN=xxx/OU=xx/L=xx/ST=xx"
 - "C=" 代表国家
 - "O=" 代表组织
 - "OU=" 代表组织单位
 - "CN=" 代表通用名字
 - "L=" 代表地点
 - "ST=" 代表州或省份
```

使用者 subject 结构：

```
- "C=" 代表国家
- "O=" 代表组织
- "OU=" 代表组织单位
- "CN=" 代表通用名字/主机名
- "L=" 代表地点
- "ST=" 代表州或省份
- "EMAIL="/"emailAddress=" 代表电子邮件地址
```

### <a name="提取公钥私钥"></a>提取公钥私钥

p12/pfx 证书，通过传入路径或者二进制数据的方式，

1. 通过`int PKCS12_parse(PKCS12 *p12, const char *pass, EVP_PKEY **pkey, X509 **cert,  STACK_OF(X509) **ca);`函数进行解析，提取证书X509结构`cert `，私钥`pkey `，
2. X509结构`cert `可通过`ASN1_INTEGER *X509_get_serialNumber(X509 *x);`、`X509_NAME *X509_get_issuer_name(const X509 *a);`等X509函数提取到证书信息内容；通过`EVP_PKEY *X509_get_pubkey(X509 *x);`获取到公钥，用`int PEM_write_bio_PUBKEY(BIO *bp, EVP_PKEY *x)`将公钥转换到`BIO`对象中；
3. 私钥`pkey `通过`int PEM_write_bio_PrivateKey(BIO *bp, const EVP_PKEY *x, const EVP_CIPHER *enc, unsigned char *kstr, int klen, pem_password_cb *cb, void *u);`转换到`BIO`对象中；
4. 最终将`BIO`对象转为`char`对象

最终保存公钥私钥字符串和密码

```
-----BEGIN CERTIFICATE-----
xxx
-----END CERTIFICATE-----

-----BEGIN ENCRYPTED PRIVATE KEY-----
xxx
-----END ENCRYPTED PRIVATE KEY-----

password
```
## 签名验签与加密解密

我们以一封简单的信为例子

```
Date: Thu, 23 Jan 2025 16:24:03 +0800 (GMT+8:00)
Message-ID: <AC2B6D81E8494F0B80D3FBF694AC518E_1737620643.0700278>
From: aaa@6010.com
To: bbb@6010.com
Subject: S
MIME-Version: 1.0
Content-Type: multipart/alternative; 
	boundary="C5A3EAC0C2E741EB9513A33275BC9741"

--C5A3EAC0C2E741EB9513A33275BC9741
Content-Type: text/html; charset=UTF-8

Fdsa
--C5A3EAC0C2E741EB9513A33275BC9741--
```
以上是一封只有一点简单的纯文本内容的信，我们要对这封信进行加密或签名等操作

### <a name="提取"></a>提取

我们只对主体内容进行操作，即从`Content-Type`开始到结束的部分，要单独提取出来

```
Content-Type: multipart/alternative; 
	boundary="C5A3EAC0C2E741EB9513A33275BC9741"

--C5A3EAC0C2E741EB9513A33275BC9741
Content-Type: text/html; charset=UTF-8

Fdsa
--C5A3EAC0C2E741EB9513A33275BC9741--
```

### 签名

#### 签名

对提取出来的内容转为`BIO`对象，调用`CMS_ContentInfo *CMS_sign(X509 *signcert, EVP_PKEY *pkey, STACK_OF(X509) *certs, BIO *data, unsigned int flags);`函数，传入所用的证书公钥、私钥，对`BIO`进行签名。

需要注意的是最后一个参数`flags`，有两种值`PKCS7_DETACHED`和`PKCS7_BINARY`，对应两种签名方式：Detach 和 Attach。区别在于 Detach 签名后的内容，不会带入原内容，所以验签时，需要将签名内容与原内容进行验证看是否匹配；Attach 方式则会带入原内容，验签时，验证成功后，可以从签名内容中提取出原内容。Attach 方式在后面再阐述。

以上签名后获取到的内容格式为`-----BEGIN CMS-----xxx-----END CMS-----`，需要去除掉前后的tag，即`-----BEGIN CMS-----`和`-----END CMS-----`。

#### 构造

对原信件改造较为麻烦，所以我们重新构造一封信，`Content-Type`为`multipart/signed`，信件内容分为两部分，第一部分为我们 [**提取**](#提取) 步骤中的原信件内容，第二部分是我们的签名内容，整体结构为：

```
Date: Thu, 23 Jan 2025 16:24:03 +0800 (GMT+8:00)
Message-ID: <AC2B6D81E8494F0B80D3FBF694AC518E_1737620643.0700278>
From: aaa@6010.com
To: bbb@6010.com
Subject: S
MIME-Version: 1.0
Content-Type: multipart/signed; 
	boundary=part_1

--part_1
Content-Type: multipart/alternative; 
	boundary="C5A3EAC0C2E741EB9513A33275BC9741"

--C5A3EAC0C2E741EB9513A33275BC9741
Content-Type: text/html; charset=UTF-8

Fdsa
--C5A3EAC0C2E741EB9513A33275BC9741--
--part_1
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

签名内容

--part_1--
```

注意点：

1. 这里示例只是一封简单的内容，有带附件或者内联图的信件也是一样，提取信件的主体内容进行签名；
2. 构建信件的方式各有不同，经常会有多一个换行或者少一个换行的情况，但，最后构建签名信时，一定要确保第一部分的内容恰好是当时用来生成签名的内容，否则会导致验签失败。

### 验签

签名信的识别特征，就是`Content-Type: multipart/signed;`，表示这封信是一封 detach 方式签名的信件。通过以上的签名过程，我们知道签名信是由两部分组成，原内容和签名内容，验签就是将这两部分内容提取出来后，进行校验。

通过`CMS_ContentInfo *d2i_CMS_bio(BIO *bp, CMS_ContentInfo **cms);`函数，将签名内容转换为`CMS_ContentInfo`对象，将原文内容转换为`BIO`对象，调用`int CMS_verify(CMS_ContentInfo *cms, STACK_OF(X509) *certs, X509_STORE *store, BIO *dcont, BIO *out, unsigned int flags);`进行验签。

验签成功后，`STACK_OF(X509) *CMS_get0_signers(CMS_ContentInfo *cms);`提取出 X509 结构，参考上面的 [**提取公钥私钥**](#提取公钥私钥) 步骤，再从 X509 结构中获取签名者的公钥证书信息。

### 加密

#### 公钥

加密用到的是所有收件人的公钥去做加密，同时也要加入当前发件人的公钥，以确保发件人也能解密查看此信件。

`sk_X509_new_null()`新建一个空白的 X509 结构堆栈，通过遍历将每张证书转为`BIO`对象，再由`X509 *PEM_read_bio_X509_AUX(BIO *bp, X509 **x, pem_password_cb *cb, void *u);`转为 X509 对象，而`sk_X509_push(sk, ptr)`函数支持将多个 X509 结构添加到同一个堆栈中。

#### 加密

同样将提取到的主体部分转为`BIO`对象，`CMS_ContentInfo *CMS_encrypt(STACK_OF(X509) *certs, BIO *in, const EVP_CIPHER *cipher, unsigned int flags);`函数将信件用公钥进行加密，`certs`就是上面所创建的所有 X509 证书的堆栈，`in`是待加密的信件主体部分，`cipher`用于指定加密算法，这里我们指定为`EVP_des_ede3_cbc`。

最后将获取到的`CMS_ContentInfo`转为`BIO`再转为字符串输出。输出的字符串格式是`-----BEGIN CMS-----xxx-----END CMS-----`，同样需要去掉前后的 tag。

#### 构造

同样需要再重新构造信件。新的信件中只有一个附件，这个附件内容就是加密后的密文。`Content-Type`要改为`application/pkcs7-mime`，同时增加`smime-type="enveloped-data"`，表示数据被封装在 PKCS#7 格式的 MIME 结构中，并指明数据被经过加密。

示例

```
Date: Fri, 24 Jan 2025 09:48:59 +0800
From: aaa@6010.com
To: bbb@6010.com
Message-ID: <dcf27f6d-5fe0-4666-96cf-beb31d4edeb2@localhost>
Subject: ABCD
Content-Type: application/pkcs7-mime; smime-type="enveloped-data"; 
 name="smime.p7m"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7m"

密文内容
```

### 解密

以上可知，加密信的特征是`Content-Type: application/pkcs7-mime`和`smime-type="enveloped-data"`。加密信只有一个部分，就是密文内容。我们提取出密文内容，再利用对应的私钥进行解密。

密文内容提取出来后，要补上前后的 tag，即`"-----BEGIN CMS-----\n密文内容\n-----END CMS-----\n"`，记得带上换行符。

`EVP_PKEY *PEM_read_bio_PrivateKey(BIO *bp, EVP_PKEY **x, pem_password_cb *cb, void *u);`函数将私钥的`BIO`对象和私钥的密码传入，获取到对应的私钥对象；

`int CMS_decrypt(CMS_ContentInfo *cms, EVP_PKEY *pkey, X509 *cert, BIO *dcont, BIO *out, unsigned int flags);`函数进行解密，密文转为`CMS_ContentInfo`对象，解密后的内容存储在`out`变量。

### 签名并加密

加密可以对任何内容进行加密，就意味着已签名过的信件也是可以再次进行加密的。通常这里的签名会使用 Attach 方式签名，然后再进行加密，但也不是说一定是 Attach 方式，有的客户端也会选择用 Detach 方式签名，都是需要考虑的。

Attach 方式与 Detach 方式使用的函数是相同的，只有在`CMS_sign`函数的`flags`变量要指定为`PKCS7_BINARY`，获取到的签名同样要去掉前后的 tag。然后构建

```
Content-Type: application/x-pkcs7-mime;
	name=smime.p7m;
	smime-type=signed-data
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="smime.p7m"
	
签名内容
```
Attach 方式的标识是`Content-Type: application/x-pkcs7-mime`和`smime-type=signed-data`。

如果是 Detach 方式，加密是对签名和原内容进行加密，即

```
Content-Type: multipart/signed; 
	boundary=part_1

--part_1
Content-Type: multipart/alternative; 
	boundary="C5A3EAC0C2E741EB9513A33275BC9741"

--C5A3EAC0C2E741EB9513A33275BC9741
Content-Type: text/html; charset=UTF-8

Fdsa
--C5A3EAC0C2E741EB9513A33275BC9741--
--part_1
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

签名内容

--part_1--
```

然后是加密，加密流程与上面的纯加密信一致。

### 解密并验签

解密过程和上面一致，验签也是调用`int CMS_verify(CMS_ContentInfo *cms, STACK_OF(X509) *certs, X509_STORE *store, BIO *dcont, BIO *out, unsigned int flags);`函数进行验签，不同的是，Detach 方式下使用是`CMS_verify(cms, NULL, NULL, bio_in, NULL, CMS_NO_SIGNER_CERT_VERIFY)`，Attach 方式是`CMS_verify(cms, NULL, NULL, NULL, bio_out, CMS_NO_SIGNER_CERT_VERIFY)`，前者传入签名和原文内容做校验，后者对签名做校验后通过`bio_out`输出原文内容。

## 后记

以上是对 S/MIME 发信和解信过程的一些简单介绍，实际操作中会更为复杂，涉及到 OpenSSL 的编译和使用，Eml 的解析等。iOS 上的实现，可以考虑借助[SMIMECrypt](https://github.com/zhenghongyi/SMIMECrypt)和[EmlKit](https://github.com/zhenghongyi/EmlKit)，其中 SMIMECrypt 已经对加密、解密、签名和验签等部分做了封装，EmlKit 可以用来做组信和解信，提取对应的内容。

