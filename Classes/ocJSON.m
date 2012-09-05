//
//  ocJSON.m
//
//  Created by derand on 11/30/10.
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

+ (cJSON *)objectTocJSON:(id<NSObject, NSCopying>) data
{
    cJSON *rv = nil;
    if ([data isKindOfClass:[NSNull class]])
    {
        rv = cJSON_CreateNull();
    }
    else if ([data isKindOfClass:[NSNumber class]])
    {
        NSNumber *n = (NSNumber *)data;
        if (strcmp([n objCType], @encode(BOOL)) == 0)
        {
            rv = [n boolValue]?cJSON_CreateTrue():cJSON_CreateFalse();
        }
        else
        {
            rv = cJSON_CreateNumber([n doubleValue]);
        }
    }
    else if ([data isKindOfClass:[NSString class]])
    {
        NSString *str = (NSString *)data;
        rv = cJSON_CreateString([str cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    else if ([data isKindOfClass:[NSArray class]])
    {
        NSArray *arr = (NSArray *)data;
        rv = cJSON_CreateArray();
        for (id<NSObject, NSCopying> counter in arr)
        {
            cJSON *tmp = [self objectTocJSON:counter];
            if (counter)
            {
                cJSON_AddItemToArray(rv, tmp);
            }
            else
            {
                NSLog(@"error: try add empty object to array");
            }
        }
    }
    else if ([data isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dict = (NSDictionary *)data;
        rv = cJSON_CreateArray();
        for (id key in [dict allKeys])
        {
            if ([key isKindOfClass:[NSString class]])
            {
                id<NSObject, NSCopying> value = [dict objectForKey:key];
                NSString *key_str = (NSString *)key;
                cJSON *tmp = [self objectTocJSON:value];
                if (tmp)
                {
                    cJSON_AddItemToObject(rv, [key_str cStringUsingEncoding:NSUTF8StringEncoding], tmp);
                }
                else
                    NSLog(@"error: try add empty object to dict");
                {
                }
            }
            else
            {
                NSLog(@"error: key not string");
            }
        }
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

+ (NSString *) printToString:(id<NSObject, NSCopying>) data
{
    NSString *rv = nil;
    
    cJSON *json = [self objectTocJSON:data];
    char *ch_str = cJSON_Print(json);
    rv = [NSString stringWithCString:ch_str encoding:NSUTF8StringEncoding];
    free(ch_str);
    cJSON_Delete(json);
    
    return rv;
}


@end
