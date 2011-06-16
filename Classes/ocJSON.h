//
//  ocJSON.h
//  ocJSON
//
//  Created by derand on 11/30/10.
//  Copyright 2010 projectslice. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ocJSON : NSObject
{
}

+ (id<NSObject, NSCopying>) parseString:(NSString *) data encoding:(NSStringEncoding) enc;
+ (id<NSObject, NSCopying>) parseData:(NSData *) data;

@end
