//
//  Crypto.m
//  RSATest
//
//  Created by Marek Spalek on 10/20/12.
//  Copyright (c) 2012 Marek Spalek. All rights reserved.
//

#import "Crypto.h"
#import "CryptoUtil.h"
#import <Security/Security.h>

#define CIPHER_LENGTH 2048
#define CIPHER_LENGTH_EC 256

@implementation Crypto

static const UInt8 publicKeyIdentifier[] = "sk.uniza.fri.MobilSign.publickey\0";
static const UInt8 privateKeyIdentifier[] = "sk.uniza.fri.MobilSign.privatekey\0";
static const UInt8 communicationKeyIdentifier[] = "sk.uniza.fri.MobilSign.communicationkey\0";
// Defines unique strings to be added as attributes to the private and public key keychain items to make them easier to find later.

+ (void)generateKeyPair
{
    NSDate *start = [NSDate date];
    
    OSStatus status = noErr;
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    // Allocates dictionaries to be used for attributes in the SecKeyGeneratePair function.
    
    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *)privateKeyIdentifier)];
    // Creates NSData objects that contain the identifier strings defined in step 1.
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    // Allocates SecKeyRef objects for the public and private keys
    
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    // Sets the key-type attribute for the key pair to RSA
    [keyPairAttr setObject:[NSNumber numberWithInt:CIPHER_LENGTH] forKey:(__bridge id)kSecAttrKeySizeInBits];
    // Sets the key-size attribute for the key pair to 1024 bits
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    // Sets an attribute specifying that the private key is to be stored permanently (that is, put into the keychain)
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    // Adds the identifier string defined in steps 1 and 3 to the dictionary for the private key
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    // Sets an attribute specifying that the public key is to be stored permanently (that is, put into the keychain)
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    // Adds the identifier string defined in steps 1 and 3 to the dictionary for the public key
    
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    // Adds the dictionary of private key attributes to the key-pair dictionary
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    // Adds the dictionary of public key attributes to the key-pair dictionary
    
    status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey); // Generates the key pair
    //    error handling...
    
    double generatingTime = fabs([start timeIntervalSinceNow]);
    NSLog(@"Generating last: %f sec", generatingTime);
    
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
}

+ (BOOL)keyPairExists
{
    OSStatus status = noErr;
    
    SecKeyRef publicKey = NULL;
    
    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier
                                        length:strlen((const char *)publicKeyIdentifier)];
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
    
    NSLog(@"Status: %d", (int)status);
    NSLog(@"Public key: %@", publicKey);
    
    if (publicKey) return YES;
    else return NO;
}

+ (void)deleteKeyPair
{
    OSStatus status = noErr;
    
    NSData *publicTag = [NSData dataWithBytes:publicKeyIdentifier
                                       length:strlen((const char *)publicKeyIdentifier)];
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    
    NSLog(@"Delete public key status: %d", (int)status);
    
    NSData *privateTag = [NSData dataWithBytes:privateKeyIdentifier
                                        length:strlen((const char *)privateKeyIdentifier)];
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    
    NSLog(@"Delete private key status: %d", (int)status);
}

+ (NSData *)encryptWithPublicKey:(NSString *)text
{
    OSStatus status = noErr;
    
    SecKeyRef publicKey = NULL;
    
    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier
                                        length:strlen((const char *)publicKeyIdentifier)];
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
    
    NSLog(@"%d", (int)status);
    
    uint8_t *pPlainText = (uint8_t*)[text cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t aCipherText[CIPHER_LENGTH];
    size_t iCipherLength = CIPHER_LENGTH;
    status = SecKeyEncrypt(publicKey,
                           kSecPaddingNone,
                           pPlainText,
                           strlen( (char*)pPlainText ) + 1,
                           aCipherText,
                           &iCipherLength);

    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to encrypt data '%d'.", (int)status);

    if(publicKey) CFRelease(publicKey);
    
    return [NSData dataWithBytes:aCipherText length:CIPHER_LENGTH];
}

+ (NSString *)decryptWithPrivateKey:(NSData *)data
{
    OSStatus status = noErr;

    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *)privateKeyIdentifier)];

    SecKeyRef privateKey = NULL;
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);
    
    const uint8_t *bytes = (const uint8_t*)[data bytes];

    uint8_t aPlainText[CIPHER_LENGTH_EC];
    size_t iPlainLength = CIPHER_LENGTH_EC;
    status = SecKeyDecrypt(privateKey,
                           kSecPaddingNone,
                           &bytes[0],
                           iPlainLength,
                           &aPlainText[0],
                           &iPlainLength );
    
    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to encrypt data '%d'.", (int)status);

    if(privateKey) CFRelease(privateKey);
    
    return  [NSString stringWithUTF8String:(char *)aPlainText];
}

#pragma mark - Communication

+ (NSData *)encryptWithCommunicationKey:(NSString *)text
{
    OSStatus status = noErr;
    
    SecKeyRef publicKey = NULL;
    
    NSData * publicTag = [NSData dataWithBytes:communicationKeyIdentifier
                                        length:strlen((const char *)communicationKeyIdentifier)];
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
    
    NSLog(@"%d", (int)status);
    
    uint8_t *pPlainText = (uint8_t*)[text cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t aCipherText[CIPHER_LENGTH];
    size_t iCipherLength = CIPHER_LENGTH;
    status = SecKeyEncrypt(publicKey,
                           kSecPaddingNone,
                           pPlainText,
                           strlen( (char*)pPlainText ) + 1,
                           aCipherText,
                           &iCipherLength);
    
    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to encrypt data '%d'.", (int)status);
    
    if(publicKey) CFRelease(publicKey);
    
    return [NSData dataWithBytes:aCipherText length:CIPHER_LENGTH];
}

+ (NSString *)decryptWithCommunicationKey:(NSData *)data
{
    OSStatus status = noErr;
    
    NSData * privateTag = [NSData dataWithBytes:communicationKeyIdentifier
                                         length:strlen((const char *)communicationKeyIdentifier)];
    
    SecKeyRef privateKey = NULL;
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);
    
    const uint8_t *bytes = (const uint8_t*)[data bytes];
    
    uint8_t aPlainText[CIPHER_LENGTH_EC];
    size_t iPlainLength = CIPHER_LENGTH_EC;
    status = SecKeyDecrypt(privateKey,
                           kSecPaddingNone,
                           &bytes[0],
                           iPlainLength,
                           &aPlainText[0],
                           &iPlainLength );
    
    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to encrypt data '%d'.", (int)status);
    
    if(privateKey) CFRelease(privateKey);
    
    return  [NSString stringWithUTF8String:(char *)aPlainText];
}

+ (void)saveCommunicationKey:(NSData *)modulus
{
    NSData *publicKey = [CryptoUtil generateRSAPublicKeyWithModulus:modulus exponent:nil];
    BOOL done = [CryptoUtil saveRSAPublicKey:publicKey appTag:@"sk.uniza.fri.MobilSign.communicationkey" overwrite:YES];
    
    NSLog(@"Saving communication key done: %@", done ? @"YES" : @"NO");
}

+ (SecKeyRef)getKeyWithTag:(NSString *)tag
{
    OSStatus status = noErr;
    
    SecKeyRef key = NULL;
    
    UInt8 keyIdentifier[[tag length]+1];
    memcpy(keyIdentifier, [tag UTF8String], [tag length]+1);
    
    NSData * keyTag = [NSData dataWithBytes:keyIdentifier
                                     length:strlen((const char *)keyIdentifier)];
    
    NSMutableDictionary *queryKey = [[NSMutableDictionary alloc] init];
    [queryKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryKey setObject:keyTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&key);
    
    NSLog(@"%d", (int)status);
    
    return key;
}

#pragma mark - Elyptic curves

+ (SecKeyRef)generatePublicKeyEC
{
    NSDate *start = [NSDate date];
    
    OSStatus status = noErr;
    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    // Allocates dictionaries to be used for attributes in the SecKeyGeneratePair function.
    
    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *)privateKeyIdentifier)];
    // Creates NSData objects that contain the identifier strings defined in step 1.
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    // Allocates SecKeyRef objects for the public and private keys
    
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeEC forKey:(__bridge id)kSecAttrKeyType];
    // Sets the key-type attribute for the key pair to RSA
    [keyPairAttr setObject:[NSNumber numberWithInt:CIPHER_LENGTH_EC] forKey:(__bridge id)kSecAttrKeySizeInBits];
    // Sets the key-size attribute for the key pair to 1024 bits
    
    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    // Sets an attribute specifying that the private key is to be stored permanently (that is, put into the keychain)
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    // Adds the identifier string defined in steps 1 and 3 to the dictionary for the private key
    
    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
    // Sets an attribute specifying that the public key is to be stored permanently (that is, put into the keychain)
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    // Adds the identifier string defined in steps 1 and 3 to the dictionary for the public key
    
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    // Adds the dictionary of private key attributes to the key-pair dictionary
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    // Adds the dictionary of public key attributes to the key-pair dictionary
    
    status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey); // Generates the key pair
    //    error handling...
    NSLog(@"Status: %d", (int)status);
    
    double generatingTime = fabs([start timeIntervalSinceNow]);
    NSLog(@"Generating last: %f sec", generatingTime);
    
    if (privateKey && publicKey) NSLog(@"Exists");
    
    NSLog(@"%zd", SecKeyGetBlockSize(privateKey));
    NSLog(@"%zd", SecKeyGetBlockSize(publicKey));
    
    return publicKey;
}

#pragma mark - Test
// Some testing methods

+ (NSDictionary *)test
{
    NSMutableDictionary *resultsDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    NSDate *start = [NSDate date];
    
    // GENERATING
    
    OSStatus status = noErr;
//    NSMutableDictionary *privateKeyAttr = [[NSMutableDictionary alloc] init];
//    NSMutableDictionary *publicKeyAttr = [[NSMutableDictionary alloc] init];
//    NSMutableDictionary *keyPairAttr = [[NSMutableDictionary alloc] init];
    // Allocates dictionaries to be used for attributes in the SecKeyGeneratePair function.
    
    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier length:strlen((const char *)publicKeyIdentifier)];
    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier length:strlen((const char *)privateKeyIdentifier)];
    // Creates NSData objects that contain the identifier strings defined in step 1.
    
    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;
    // Allocates SecKeyRef objects for the public and private keys
    
//    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
//    // Sets the key-type attribute for the key pair to RSA
//    [keyPairAttr setObject:[NSNumber numberWithInt:CIPHER_LENGTH] forKey:(__bridge id)kSecAttrKeySizeInBits];
//    // Sets the key-size attribute for the key pair to 1024 bits
//    
//    [privateKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
//    // Sets an attribute specifying that the private key is to be stored permanently (that is, put into the keychain)
//    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
//    // Adds the identifier string defined in steps 1 and 3 to the dictionary for the private key
//    
//    [publicKeyAttr setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecAttrIsPermanent];
//    // Sets an attribute specifying that the public key is to be stored permanently (that is, put into the keychain)
//    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
//    // Adds the identifier string defined in steps 1 and 3 to the dictionary for the public key
//    
//    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
//    // Adds the dictionary of private key attributes to the key-pair dictionary
//    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
//    // Adds the dictionary of public key attributes to the key-pair dictionary
//    
//    status = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, &publicKey, &privateKey); // Generates the key pair
//    //    error handling...
//    
//    double generatingTime = fabs([start timeIntervalSinceNow]);
//    NSLog(@"Generating last: %f sec", generatingTime);
//    start = [NSDate date];
//    
//    [resultsDictionary setValue:[NSNumber numberWithDouble:generatingTime] forKey:@"generating"];
    
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching
    ((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching
    ((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
    
    // ENCRYPTING
    
    NSString *string = @"You are mistaken. RSA is not a block cipher, so you cannot really talk about the block size of it.The output of a RSA asdfghjkl";
    
    uint8_t *pPlainText = (uint8_t*)[string cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t aCipherText[CIPHER_LENGTH];
    size_t iCipherLength = CIPHER_LENGTH;
    status = SecKeyEncrypt(publicKey,
                           kSecPaddingNone,
                           pPlainText,
                           strlen( (char*)pPlainText ) + 1,
                           aCipherText,
                           &iCipherLength);
    
    NSData *decryptedData = [NSData dataWithBytes:aCipherText length:CIPHER_LENGTH];
    NSString *encodedString = [decryptedData base64EncodedString];
    NSLog(@"Encrypted: %@", encodedString);
    
    
    const uint8_t *bytes = (const uint8_t*)[[NSData dataFromBase64String:encodedString] bytes];
    
    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to encrypt data '%d'.", (int)status);
    
    double encryptingTime = fabs([start timeIntervalSinceNow]);
    NSLog(@"Encrypting last: %f sec", encryptingTime);
    start = [NSDate date];
    
    [resultsDictionary setValue:[NSNumber numberWithDouble:encryptingTime] forKey:@"encrypting"];
    
    
    // DECRYPTING
    
    uint8_t aPlainText[CIPHER_LENGTH];
    size_t iPlainLength = CIPHER_LENGTH;
    status = SecKeyDecrypt(privateKey,
                           kSecPaddingNone,
                           &bytes[0],
                           iCipherLength,
                           &aPlainText[0],
                           &iPlainLength );
    
    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to encrypt data '%d'.", (int)status);
    
    NSString *s = [NSString stringWithUTF8String:(char *)aPlainText];
    
    NSLog(@"%@", s);
    
    double decryptingTime = fabs([start timeIntervalSinceNow]);
    NSLog(@"Decrypting last: %f sec", decryptingTime);
    
    [resultsDictionary setValue:[NSNumber numberWithDouble:decryptingTime] forKey:@"decrypting"];
    
    if(publicKey) CFRelease(publicKey);
    if(privateKey) CFRelease(privateKey);
    
    return  resultsDictionary;
}

#pragma mark - Crap
// Methods that im not using anymore, but sometimes may become handy

+ (NSString *)encryptString:(NSString *)text withKey:(SecKeyRef)key
{
    NSDate *start = [NSDate date];
    
    uint8_t *plainText = (uint8_t*)[text cStringUsingEncoding:NSUTF8StringEncoding];
    //const uint8_t *pPlainText = (unsigned char *)[@"This is a test" UTF8String];
    uint8_t cipherText[CIPHER_LENGTH];
    size_t cipherLength = CIPHER_LENGTH;
    OSStatus status = SecKeyEncrypt(key,
                                    kSecPaddingNone,
                                    plainText,
                                    strlen( (char*)plainText ) + 1,
                                    cipherText,
                                    &cipherLength);
    
    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to encrypt data '%d'.", (int)status);
    
    NSLog(@"Encrypting last: %f", fabs([start timeIntervalSinceNow]));
    
    
    return nil;
}

+ (NSData *)encryptData:(NSData *)data withKey:(SecKeyRef)key
{
    NSDate *start = [NSDate date];
    
    NSUInteger length = [data length];
    NSUInteger blockSize = SecKeyGetBlockSize(key) - 1;
    NSMutableData *encryptedData = [NSMutableData dataWithCapacity:length];
    NSLog(@"Data size: %d", length);
    NSLog(@"Block size: %d", blockSize);
    
    NSUInteger errCount = 0;
    
    for (int i = 0; i < length / blockSize; i++) {
        NSData *subdata = [data subdataWithRange:NSMakeRange(i * blockSize, blockSize)];
        
        NSData *blockData = [Crypto wrapSymmetricKey:subdata keyRef:key];
        if (!blockData) {
            errCount++;
            NSLog(@"Error");
        } else {
            [encryptedData appendData:blockData];
        }
        
        //NSLog(@"Block: %d, encypted data size: %d", i+1, [encryptedData length]);
    }
    
    NSLog(@"Encrypting last: %f, errors: %d", fabs([start timeIntervalSinceNow]), errCount);
    
    return encryptedData;
}

+ (NSData *)doCipher:(NSData *)dataIn
                  iv:(NSData *)iv
                 key:(NSData *)symmetricKey
             context:(CCOperation)encryptOrDecrypt
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;    // Number of bytes moved to buffer.
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:dataIn.length + kCCBlockSizeAES128];
    
    ccStatus = CCCrypt( encryptOrDecrypt,
                       kCCAlgorithmAES128,
                       kCCOptionPKCS7Padding,
                       symmetricKey.bytes,
                       kCCKeySizeAES128,
                       iv.bytes,
                       dataIn.bytes,
                       dataIn.length,
                       dataOut.mutableBytes,
                       dataOut.length,
                       &cryptBytes);
    
    if (ccStatus != kCCSuccess) {
        NSLog(@"CCCrypt status: %d", ccStatus);
    }
    
    dataOut.length = cryptBytes;
    
    return dataOut;
}

+ (NSData *)wrapSymmetricKey:(NSData *)symmetricKey keyRef:(SecKeyRef)publicKey {
	OSStatus sanityCheck = noErr;
	size_t cipherBufferSize = 0;
	size_t keyBufferSize = 0;
	
    //	LOGGING_FACILITY( symmetricKey != nil, @"Symmetric key parameter is nil." );
    //	LOGGING_FACILITY( publicKey != nil, @"Key parameter is nil." );
	
	NSData * cipher = nil;
	uint8_t * cipherBuffer = NULL;
	
	// Calculate the buffer sizes.
	cipherBufferSize = SecKeyGetBlockSize(publicKey);
	keyBufferSize = [symmetricKey length];
	
    //	if (kTypeOfWrapPadding == kSecPaddingNone) {
    //		LOGGING_FACILITY( keyBufferSize <= cipherBufferSize, @"Nonce integer is too large and falls outside multiplicative group." );
    //	} else {
    //		LOGGING_FACILITY( keyBufferSize <= (cipherBufferSize - 11), @"Nonce integer is too large and falls outside multiplicative group." );
    //	}
	
	// Allocate some buffer space. I don't trust calloc.
	cipherBuffer = malloc( cipherBufferSize * sizeof(uint8_t) );
	memset((void *)cipherBuffer, 0x0, cipherBufferSize);
	
	// Encrypt using the public key.
	sanityCheck = SecKeyEncrypt(	publicKey,
                                kSecPaddingNone,
                                (const uint8_t *)[symmetricKey bytes],
                                keyBufferSize,
                                cipherBuffer,
                                &cipherBufferSize
								);
	
    //	LOGGING_FACILITY1( sanityCheck == noErr, @"Error encrypting, OSStatus == %d.", sanityCheck );
    //if(sanityCheck != errSecSuccess) NSAssert1(0, @"Error: failed to encrypt data '%d'.", (int)sanityCheck);
	if(sanityCheck != errSecSuccess) {
        NSLog(@"Error: %d", (int)sanityCheck);
        return nil;
    }
    
	// Build up cipher text blob.
	cipher = [NSData dataWithBytes:(const void *)cipherBuffer length:(NSUInteger)cipherBufferSize];
	
	if (cipherBuffer) free(cipherBuffer);
	
	return cipher;
}

+ (NSString *)decryptWithPrivateKey2:(NSData *)data
{
    OSStatus status = noErr;
    
    size_t cipherBufferSize = [data length];
    uint8_t *cipherBuffer = (uint8_t *)[data bytes];
    
    size_t plainBufferSize;
    uint8_t *plainBuffer;
    
    SecKeyRef privateKey = NULL;
    
    NSData * privateTag = [NSData dataWithBytes:privateKeyIdentifier
                                         length:strlen((const char *)privateKeyIdentifier)];
    
    NSMutableDictionary *queryPrivateKey = [[NSMutableDictionary alloc] init];
    
    // Set the private key query dictionary.
    [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPrivateKey setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPrivateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching
    ((__bridge CFDictionaryRef)queryPrivateKey, (CFTypeRef *)&privateKey);
    
    NSLog(@"%d", (int)status);
    
    //  Allocate the buffer
    plainBufferSize = CIPHER_LENGTH_EC;
    plainBuffer = malloc(plainBufferSize);
    
    if (plainBufferSize < cipherBufferSize) {
        // Ordinarily, you would split the data up into blocks
        // equal to plainBufferSize, with the last block being
        // shorter. For simplicity, this example assumes that
        // the data is short enough to fit.
        printf("Could not decrypt.  Packet too large.\n");
        return nil;
    }
    
    //  Error handling
    
    status = SecKeyDecrypt(privateKey,
                           kSecPaddingPKCS1,
                           cipherBuffer,
                           cipherBufferSize,
                           plainBuffer,
                           &plainBufferSize
                           );
    
    //  Error handling
    //  Store or display the decrypted text
    
    NSString *s = [NSString stringWithUTF8String:(char *)plainBuffer];
    NSLog(@"Decrypted: %@", s);
    
    if(privateKey) CFRelease(privateKey);
    
    return s;
}

+ (NSData *)encryptWithPublicKey2:(NSString *)text
{
    OSStatus status = noErr;
    
    size_t cipherBufferSize;
    uint8_t *cipherBuffer;
    
    const uint8_t *dataToEncrypt = (uint8_t *)[text cStringUsingEncoding:NSUTF8StringEncoding];
    size_t dataLength = sizeof(dataToEncrypt)/sizeof(dataToEncrypt[0]);
    
    SecKeyRef publicKey = NULL;
    
    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier
                                        length:strlen((const char *)publicKeyIdentifier)];
    
    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    status = SecItemCopyMatching
    ((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
    
    NSLog(@"%d", (int)status);
    
    //  Allocate a buffer
    
    cipherBufferSize = SecKeyGetBlockSize(publicKey);
    cipherBuffer = malloc(cipherBufferSize);
    
    //  Error handling
    
    if (cipherBufferSize < sizeof(dataToEncrypt)) {
        // Ordinarily, you would split the data up into blocks
        // equal to cipherBufferSize, with the last block being
        // shorter. For simplicity, this example assumes that
        // the data is short enough to fit.
        printf("Could not encrypt.  Packet too large.\n");
        return NULL;
    }
    
    // Encrypt using the public.
    status = SecKeyEncrypt(publicKey,
                           kSecPaddingPKCS1,
                           dataToEncrypt,
                           (size_t) dataLength,
                           cipherBuffer,
                           &cipherBufferSize
                           );
    
    //  Error handling
    //  Store or transmit the encrypted text
    
    NSLog(@"%d", (int)status);
    
    if (publicKey) CFRelease(publicKey);
    
    NSData *encryptedData = [NSData dataWithBytes:cipherBuffer length:cipherBufferSize];
    
    free(cipherBuffer);
    
    return encryptedData;
}

@end
