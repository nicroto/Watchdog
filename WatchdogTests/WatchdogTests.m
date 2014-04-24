//
//  WatchdogTests.m
//  WatchdogTests
//
//  Created by Konstantin Pavlikhin on 6/5/13.
//  Copyright (c) 2013 Konstantin Pavlikhin. All rights reserved.
//

#import <Specta/Specta.h>

#define EXP_SHORTHAND

#import <Expecta/Expecta.h>

#import "WDRegistrationController+Private.h"

SpecBegin(WDRegistrationController)

describe(@"WDRegistrationController", ^
{
  WDRegistrationController* SRC = [WDRegistrationController sharedRegistrationController];
  
  it(@"should accept only valid serials", ^
  {
    // Test against two EC keys and two DSAs.
    NSArray* prefixes = @[@"secp384r1", @"secp521r1", @"1024", @"2048"];
    
    [prefixes enumerateObjectsUsingBlock: ^(NSString* prefix, NSUInteger idx, BOOL* stop)
    {
      NSString* publicPEMName = [prefix stringByAppendingString: @"-public"];
      
      NSString* publicPEMPath = [[NSBundle bundleForClass: [self class]] pathForResource: publicPEMName ofType: @"pem" inDirectory: nil];
      
      SRC.publicKeyPEM = [NSString stringWithContentsOfFile: publicPEMPath encoding: NSUTF8StringEncoding error: NULL];
      
      NSString* dataName = [prefix stringByAppendingString: @"-data"];
      
      NSString* dataPath = [[NSBundle bundleForClass: [self class]] pathForResource: dataName ofType: @"plist" inDirectory: nil];
      
      NSArray* dataArray = [NSPropertyListSerialization propertyListWithData: [NSData dataWithContentsOfFile: dataPath] options: 0 format: 0 error: NULL];
      
      [dataArray enumerateObjectsUsingBlock: ^(NSDictionary* customer, NSUInteger idx, BOOL* stop)
      {
        NSArray* customerData = @[
          @{
            @"Name": @"name",
            @"Value": customer[@"Name"]
          }
        ];
        expect([SRC isSerial: customer[@"Serial"] conformsToCustomerData:customerData error: NULL]).to.equal(YES);
        
        // * * *.
        NSArray* invalidCustomerData = @[
          @{
            @"Name": @"name",
            @"Value": @"Invalid Customer Name"
          }
        ];
        expect([SRC isSerial: customer[@"Serial"] conformsToCustomerData:invalidCustomerData error: NULL]).to.equal(NO);
        
        expect([SRC isSerial: @"" conformsToCustomerData:customerData error: NULL]).to.equal(NO);
        
        expect([SRC isSerial: @" " conformsToCustomerData:customerData error: NULL]).to.equal(NO);
        
        expect([SRC isSerial: @"0123456789" conformsToCustomerData:customerData error: NULL]).to.equal(NO);
        
        expect([SRC isSerial: @"FUNNYSERIALNUMBER" conformsToCustomerData:customerData error: NULL]).to.equal(NO);
        
        expect([SRC isSerial: @"SERIAL\nNUMBER\nWITH\nNEWLINES\n" conformsToCustomerData:customerData error: NULL]).to.equal(NO);
        
        expect([SRC isSerial: @"U2FtcGxlIHRleHQgdG8gYmUgZW5jb2RlZCBhcyBiYXNlNjQ" conformsToCustomerData:customerData error: NULL]).to.equal(NO);

        expect([SRC isSerial: customer[@"Name"] conformsToCustomerData:customerData error: NULL]).to.equal(NO);
      }];
    }];
  });
  
  it(@"should decompose Quick-Apply Links", ^
  {
    // "{\"customerData\":[{\"Name\":\"name\",\"Value\":\"John Appleseed\"}]}" as JSON
    NSArray* customerData = @[
      @{
        @"Name": @"name",
        @"Value": @"John Appleseed"
      }
    ];
    NSString* serialBase64 = @"FUNNYSERIALNUMBER==";

    // customerDataJson -> base64 -> urlEncoded
    NSString* customerDataString = @"eyJjdXN0b21lckRhdGEiOlt7Ik5hbWUiOiJuYW1lIiwiVmFsdWUiOiJKb2huIEFwcGxlc2VlZCJ9XX0%3D";
    
    // serial -> base64 -> urlEncoded
    NSString* serialString = @"FUNNYSERIALNUMBER%3D%3D";
    
    NSString* link = [NSString stringWithFormat: @"application-wd://%@:%@", customerDataString, serialString];
    
    NSDictionary* dict = [SRC decomposeQuickApplyLink: link];

    expect(dict[@"customerData"]).to.equal(customerData);

    expect(dict[@"serial"]).to.equal(serialBase64);
  });

  it(@"should url decode strings", ^
  {
    NSString* source = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%2B%2F%3D";
    NSString* result = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    expect([SRC urlDecodeString: source]).to.equal(result);
  });

  it(@"should successfully remove protocol from url", ^
  {
    NSString* source = @"watchdog-wd://ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%2B%2F%3D:ASDasd%3D";
    NSString* result = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%2B%2F%3D:ASDasd%3D";
    expect([SRC getUrlWithoutProtocol: source]).to.equal(result);
  });

  it(@"should parse json strings", ^
  {
    NSString* source = @"{\"customerData\":[{\"Name\":\"name\",\"Value\":\"John Appleseed\"}]}";
    NSDictionary* result = @{
      @"customerData": @[
        @{
          @"Name": @"name",
          @"Value": @"John Appleseed"
        }
      ]
    };
    expect([SRC parseJson: source]).to.equal(result);
  });

  it(@"should transition from the unknown state to the registered state", ^AsyncBlock
  {
    // Before any checks are made we can't make any assumptions about app' state.
    expect(SRC.applicationState).to.equal(WDUnknownApplicationState);
    
    NSString* publicPEMPath = [[NSBundle bundleForClass: [self class]] pathForResource: @"1024-public" ofType: @"pem" inDirectory: nil];
    
    SRC.publicKeyPEM = [NSString stringWithContentsOfFile: publicPEMPath encoding: NSUTF8StringEncoding error: NULL];
    
    // Valid credentials from the "1024 DSA" sample.
    NSString* name = @"John Appleseed";
    
    NSString* serial = @"MCwCFANaWbsbaPQG5w49wKnET/18mae6AhQtjQNkCi31Qx/rCb7ZNcHrx7Rn+A==";

    NSArray* customerData = @[
      @{
        @"Name": @"name",
        @"Value": name
      }
    ];

    [SRC registerWithCustomerData: customerData serial: serial handler: ^(enum WDSerialVerdict verdict)
    {
      expect(verdict).to.equal(WDValidSerialVerdict);
      
      expect(SRC.applicationState).to.equal(WDRegisteredApplicationState);
      
      expect([SRC registeredCustomerName]).to.equal(name);
      
      done();
    }];
  });

  it(@"should reconstruct signature's data-string", ^
  {
    NSArray* customerData = @[
      @{
        @"Name": @"name",
        @"Value": @"Nikolay Tsenkov"
      },
      @{
        @"Name": @"email",
        @"Value": @"some@email.com"
      }
    ];
    expect([SRC signatureReconstructHandler: customerData]).to.equal(@"Nikolay Tsenkovsome@email.com");
  });

  it(@"should transition to the unregistered state", ^
  {
    expect(SRC.applicationState).to.equal(WDRegisteredApplicationState);

    [SRC deauthorizeAccount];
    dispatch_async(dispatch_get_main_queue(), ^()
    {
      expect(SRC.applicationState).to.equal(WDUnregisteredApplicationState);
    });
  });

  it(@"should register through Quick-apply link", ^AsyncBlock
  {
    [SRC deauthorizeAccount];
    dispatch_async(dispatch_get_main_queue(), ^()
    {
      // Before any checks are made we can't make any assumptions about app' state.
      expect(SRC.applicationState).to.equal(WDUnregisteredApplicationState);

      NSString* publicPEMPath = [[NSBundle bundleForClass: [self class]] pathForResource: @"1024-public" ofType: @"pem" inDirectory: nil];

      SRC.publicKeyPEM = [NSString stringWithContentsOfFile: publicPEMPath encoding: NSUTF8StringEncoding error: NULL];

      // customerDataJson -> base64 -> urlEncoded
      // in JSON: "{\"customerData\":[{\"Name\":\"name\",\"Value\":\"John Appleseed\"}]}"
      NSString* customerDataString = @"eyJjdXN0b21lckRhdGEiOlt7Ik5hbWUiOiJuYW1lIiwiVmFsdWUiOiJKb2huIEFwcGxlc2VlZCJ9XX0%3D";

      // serial -> base64 -> urlEncoded
      // in base64 it is: "MCwCFANaWbsbaPQG5w49wKnET/18mae6AhQtjQNkCi31Qx/rCb7ZNcHrx7Rn+A=="
      NSString* serialString = @"MCwCFANaWbsbaPQG5w49wKnET%2F18mae6AhQtjQNkCi31Qx%2FrCb7ZNcHrx7Rn%2BA%3D%3D";

      NSString* link = [NSString stringWithFormat: @"application-wd://%@:%@", customerDataString, serialString];

      [SRC registerWithQuickApplyLink:link handler:^(enum WDSerialVerdict verdict)
      {
        expect(verdict).to.equal(WDValidSerialVerdict);
        expect(SRC.applicationState).to.equal(WDRegisteredApplicationState);

        NSString* customerName = [SRC registeredCustomerName];

        expect([customerName isEqualToString: @"John Appleseed"]);

        done();
      }];
    });
  });

});

SpecEnd
