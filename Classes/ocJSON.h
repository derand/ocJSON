//
//  ocJSON.h
//  ocJSON
//
//  Created by derand on 11/30/10.
//

#import <Foundation/Foundation.h>


@interface ocJSON : NSObject
{
}

+ (id<NSObject, NSCopying>) parseString:(NSString *) data encoding:(NSStringEncoding) enc;
+ (id<NSObject, NSCopying>) parseData:(NSData *) data;

+ (NSString *) printToString:(id<NSObject, NSCopying>) data;

@end
