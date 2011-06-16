//
//  ocJSON.m
//  ocJSON
//
//  Created by derand on 11/30/10.
//  Copyright 2010 projectslice. All rights reserved.
//

#import "ocJSON.h"
#import "cJSON.h"
//#import "GTMNSString+HTML.h"


@interface ocJSON ()

+ (id<NSObject, NSCopying>) convertJSONitem:(cJSON *) item;

@end


@implementation ocJSON

#pragma mark -

+ (NSNumber *) numberItem:(cJSON *) item
{
	NSNumber *rv = nil;
	
	double d = item->valuedouble;
	if (fabs(((double)item->valueint)-d)<=DBL_EPSILON && d<=INT_MAX && d>=INT_MIN)
	{
		rv = [NSNumber numberWithInt:item->valueint];
	}
	else
	{
		rv = [NSNumber numberWithDouble:d];
	}
	
	return rv;
}

+ (NSArray *) arrayItem:(cJSON *) item
{
	NSMutableArray *tmp = [[NSMutableArray alloc] init];
	
	id<NSObject> i;
	cJSON *child=item->child;
	while (child)
	{
		i = [self convertJSONitem:child];
		[tmp addObject:i];
		[i release];
		child=child->next;
	}
	
	NSArray *rv = [[NSArray alloc] initWithArray:tmp];
	[tmp release];
	return [rv autorelease];
}

+ (NSDictionary *) objectItem:(cJSON *) item
{
	NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
	
	id<NSObject> i;
	cJSON *child=item->child;
	while (child)
	{
		i = [self convertJSONitem:child];
		[tmp setObject:i forKey:[NSString stringWithCString:child->string encoding:NSUTF8StringEncoding]];
		[i release];
		child=child->next;
	}
	
	NSDictionary *rv = [[NSDictionary alloc] initWithDictionary:tmp];
	[tmp release];
	return [rv autorelease];
}

+ (id<NSObject, NSCopying>) convertJSONitem:(cJSON *) item
{
	id<NSObject, NSCopying> rv = nil;
	if (!item)
	{
		return rv;
	}
	
	switch ((item->type)&255)
	{
		case cJSON_NULL:
			rv = [[NSNull null] retain];
			break;
		case cJSON_False:
			rv = [[NSNumber numberWithBool:NO] retain];
			break;
		case cJSON_True:
			rv = [[NSNumber numberWithBool:YES] retain];
			break;
		case cJSON_Number:
			rv = [[self numberItem:item] retain];
			break;
		case cJSON_String:
            rv = [[NSString stringWithCString:item->valuestring encoding:NSUTF8StringEncoding] retain];
//			rv = [[[NSString stringWithCString:item->valuestring encoding:NSUTF8StringEncoding] gtm_stringByUnescapingFromHTML] retain];
			break;
		case cJSON_Array:
			rv = [[self arrayItem:item] retain];
			break;
		case cJSON_Object:
			rv = [[self objectItem:item] retain];
			break;
	}
	
	return rv;
}

#pragma mark -

+ (id<NSObject, NSCopying>) parseString:(NSString *) data encoding:(NSStringEncoding) enc
{
	if (!data || [data length]==0)
	{
		return nil;
	}

	cJSON *json;
	
	json=cJSON_Parse([data cStringUsingEncoding:enc]);
//	out=cJSON_Print(json);
	id<NSObject, NSCopying> rv = [self convertJSONitem:json];
	cJSON_Delete(json);

	return rv;
}


+ (id<NSObject, NSCopying>) parseData:(NSData *) data
{
	if (!data || [data length]==0)
	{
		return nil;
	}
	cJSON *json;
	
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	json=cJSON_Parse([str cStringUsingEncoding:NSUTF8StringEncoding]);
	id<NSObject, NSCopying> rv = [self convertJSONitem:json];
	cJSON_Delete(json);
	[str release];
	
	return rv;
}



@end
