//
//  Crypto.m
//  RSATest
//
//  Created by Marek Spalek on 10/20/12.
//  Copyright (c) 2012 Marek Spalek. All rights reserved.
//

#import "Crypto.h"
#import "CryptoUtil.h"
#import "KeychainItemWrapper.h"
#import <Security/Security.h>

#define CIPHER_LENGTH 2048
#define CIPHER_LENGTH_EC 256

#define kPasscodeIdentifier @"passcodeIdentifier"
#define kPasscodeExistsKey  @"passcodeExists"

#define kCommunicationKey   @"sk.uniza.fri.MobilSign.communicationkey"
#define kPublicKey          @"sk.uniza.fri.MobilSign.publickey"
#define kPrivateKey         @"sk.uniza.fri.MobilSign.privatekey"

@implementation Crypto

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
    
    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to load key '%d'.", (int)status);
    
    return key;
}

#pragma mark - Passcode verification

+ (BOOL)checkValidPasscode:(NSString *)passcode
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kPasscodeIdentifier accessGroup:nil];
    
    return [[wrapper objectForKey:(__bridge id)kSecValueData] isEqualToString:[passcode SHA1]];
}

+ (void)createPasscode:(NSString *)passcode
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kPasscodeIdentifier accessGroup:nil];
    [wrapper setObject:@"sk.uniza.fri.spalekm.MobilSign" forKey:(__bridge id)kSecAttrService];
    [wrapper setObject:[passcode SHA1] forKey:(__bridge id)kSecValueData];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kPasscodeExistsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)passcodeExist
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kPasscodeExistsKey] boolValue];
}

#pragma mark - Mobile key pair

static const UInt8 publicKeyIdentifier[] = "sk.uniza.fri.MobilSign.publickey\0";
static const UInt8 privateKeyIdentifier[] = "sk.uniza.fri.MobilSign.privatekey\0";

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
    
//    NSData * publicTag = [NSData dataWithBytes:publicKeyIdentifier
//                                        length:strlen((const char *)publicKeyIdentifier)];
//    
//    NSMutableDictionary *queryPublicKey = [[NSMutableDictionary alloc] init];
//    [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
//    [queryPublicKey setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
//    [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
//    [queryPublicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
//    
//    status = SecItemCopyMatching((__bridge CFDictionaryRef)queryPublicKey, (CFTypeRef *)&publicKey);
//    
//    NSLog(@"%d", (int)status);
//    
//    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to load public key '%d'.", (int)status);
    
    publicKey = [self getKeyWithTag:kPublicKey];
    
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
    
    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to load public key '%d'.", (int)status);
    
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

+ (void)saveCommunicationKey:(NSData *)modulus
{
    NSData *publicKey = [CryptoUtil generateRSAPublicKeyWithModulus:modulus exponent:nil];
    
    BOOL done = [CryptoUtil saveRSAPublicKey:publicKey appTag:kCommunicationKey overwrite:YES];
    
    NSLog(@"Saving communication key done: %@", done ? @"YES" : @"NO");
}

+ (void)deleteCommunicationKey
{
    [CryptoUtil deleteRSAPublicKeyWithAppTag:kCommunicationKey];
}

+ (NSData *)encryptWithCommunicationKey:(NSData *)data
{
    OSStatus status = noErr;
	size_t cipherBufferSize = 0;
	size_t keyBufferSize = 0;
	
	NSData * encrypted = nil;
	uint8_t * cipherBuffer = NULL;
	
    SecKeyRef communicationKey = [Crypto getKeyWithTag:kCommunicationKey];
    
	cipherBufferSize = SecKeyGetBlockSize(communicationKey);
	keyBufferSize = [data length];
	
	cipherBuffer = malloc( cipherBufferSize * sizeof(uint8_t) );
	memset((void *)cipherBuffer, 0x0, cipherBufferSize);
	
	status = SecKeyEncrypt( communicationKey,
                            kSecPaddingNone,
                            (const uint8_t *)[data bytes],
                            keyBufferSize,
                            cipherBuffer,
                           &cipherBufferSize );
	
	if(status != errSecSuccess) NSAssert1(0, @"Error: failed to encrypt data '%d'.", (int)status);
    
	encrypted = [NSData dataWithBytes:(const void *)cipherBuffer length:(NSUInteger)cipherBufferSize];
	
	if (cipherBuffer) free(cipherBuffer);
	
	return encrypted;
}

+ (NSData *)decryptWithCommunicationKey:(NSData *)data
{
    OSStatus status = noErr;
	size_t cipherBufferSize = 0;
	size_t keyBufferSize = 0;
	
	NSData * decrypted = nil;
	uint8_t * keyBuffer = NULL;
	
	SecKeyRef communicationKey = NULL;
	
	communicationKey = [self getKeyWithTag:kCommunicationKey];

	cipherBufferSize = SecKeyGetBlockSize(communicationKey);
	keyBufferSize = [data length];

	keyBuffer = malloc( keyBufferSize * sizeof(uint8_t) );
	memset((void *)keyBuffer, 0x0, keyBufferSize);

	status = SecKeyDecrypt( communicationKey,
                            kSecPaddingNone,
                            (const uint8_t *) [data bytes],
                            cipherBufferSize,
                            keyBuffer,
                            &keyBufferSize );
    
    if(status != errSecSuccess) NSAssert1(0, @"Error: failed to decrypt data '%d'.", (int)status);

	decrypted = [NSData dataWithBytes:(const void *)keyBuffer length:(NSUInteger)keyBufferSize];
	
	if (keyBuffer) free(keyBuffer);
	
	return decrypted;
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

@end
