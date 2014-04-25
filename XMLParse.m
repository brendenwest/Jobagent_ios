//
//  SearchJobs.m
//  jobagent
//
//  Created by mac on 3/12/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "XMLParse.h"

@implementation XMLParse

@synthesize dataURL, xmlParser;

@synthesize rssConnection;
@synthesize xmlData;

@synthesize rootDictionary, currentDictionary, dictionaryStack;

@synthesize elementIgnoreArray;
@synthesize elementAsPropertyArray;

- (id) initWithURL:(NSURL*) URL ignoring:(NSArray*)ignoreList treatAsProperty:(NSArray*) treatAsPropertyList
{
    self = [super init];
//    NSLog(@"init xml parser");
	if (self == [super init]) {
		
		self.dataURL = URL;
		self.elementIgnoreArray = ignoreList;
		self.elementAsPropertyArray = treatAsPropertyList;
		
		currentElementHierarchy = @"";
		
		return self;
	}
	
	return nil;
	
}

- (id) initWithData:(NSData*)data ignoring:(NSArray*)ignoreList treatAsProperty:(NSArray*)treatAsPropertyList {
    self = [super init];
	if (self == [super init]) {
		
		self.xmlParser = [[NSXMLParser alloc] initWithData:data];
		[self.xmlParser setDelegate:self];
		self.elementIgnoreArray = ignoreList;
		self.elementAsPropertyArray = treatAsPropertyList;
		
		currentElementHierarchy = @"";
		
		return self;
	}
	
	return nil;
}

- (NSDictionary*) parse
{
	xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:dataURL]; 
	[xmlParser setDelegate:self];
	
	[xmlParser parse];
	
	NSError* error = [xmlParser parserError];
	if (error) {
		NSLog(@"%@",[error description]);
	}
    
#ifdef DEBUG
//	[self printTreeStructure:rootDictionary];
#endif
	
    return rootDictionary;
}

- (NSDictionary *)parseData {
	[xmlParser parse];
	
	NSError* error = [xmlParser parserError];
	if (error) {
		NSLog(@"%@",[error description]);
	}
	
#ifdef DEBUG
//	[self printTreeStructure:rootDictionary];
#endif
	
	return rootDictionary;	
}

- (BOOL) array:(NSArray*) array containsElementHierarchy:(NSString*) elementHierarchy
{
    
	for(NSString* string in array)
	{
		NSRange range = [elementHierarchy rangeOfString:string];
		if(range.length > 0 && range.location == 0)
			return YES;
	}
	
	return NO;
	
}




#pragma mark Parsing support methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{	
	currentElementHierarchy = [currentElementHierarchy stringByAppendingFormat:@"/%@",elementName];
	
	if(!elementIgnoreArray || (elementIgnoreArray && ![self array:elementIgnoreArray containsElementHierarchy:currentElementHierarchy]) )
	{
		if (!rootDictionary) {
			rootDictionary = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
			currentDictionary = rootDictionary;
			dictionaryStack = [[NSMutableArray alloc] init];
			[dictionaryStack insertObject:rootDictionary atIndex:0];

		}
		else {
			
			if((!attributeDict || [attributeDict count] == 0) && elementAsPropertyArray && [elementAsPropertyArray containsObject:currentElementHierarchy])
			{
//                NSLog(@"hierarchy = = %@",currentElementHierarchy);                
//                NSLog(@"element = %@",elementName);
				currentElementAsProperty = elementName;
				
			}
			else
			{
				
				NSMutableArray* children = [currentDictionary objectForKey:CHILDREN_KEY];
				if(!children)
				{
					children = [NSMutableArray array];
					[currentDictionary setObject:children forKey:CHILDREN_KEY];
				}
				
				currentDictionary = [NSMutableDictionary dictionaryWithDictionary:attributeDict];

				[children addObject:currentDictionary];
				[dictionaryStack insertObject:currentDictionary atIndex:0];

			}
		}
		
		if(!currentElementAsProperty && elementName != nil)
			[currentDictionary setObject:elementName forKey:ELEMENT_KEY];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if((!elementIgnoreArray || (elementIgnoreArray && ![self array:elementIgnoreArray containsElementHierarchy:currentElementHierarchy])) && !currentElementAsProperty)
	{
		[dictionaryStack removeObjectAtIndex:0];
		if([dictionaryStack count] > 0)
			currentDictionary = [dictionaryStack objectAtIndex:0];
	}
    
	
	currentElementHierarchy = [currentElementHierarchy stringByDeletingLastPathComponent];
	currentElementAsProperty = nil;
	
	
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//    NSLog(@"element = %@",currentElementHierarchy);
//    NSLog(@"element = %@",currentElementValue);
	if(![string rangeOfString:@"\n"].location == 0)
	{
		if(!elementIgnoreArray || (elementIgnoreArray && ![self array:elementIgnoreArray containsElementHierarchy:currentElementHierarchy]) )
		{
			if(currentElementAsProperty)
			{
//                NSLog(@"string = %@",string);
                NSString* currentVal = nil;
				if  ((currentVal = [currentDictionary valueForKey:currentElementAsProperty])) 
					[currentDictionary setObject:[currentVal stringByAppendingString:string] forKey:currentElementAsProperty]; 
            
				else 
					[currentDictionary setObject:string forKey:currentElementAsProperty];
                
			}
			else
			{
                NSString* currentVal = nil;
				if((currentVal = [currentDictionary valueForKey:TEXT_KEY])) 
					[currentDictionary setObject:[currentVal stringByAppendingString:string] forKey:TEXT_KEY];

				else
					[currentDictionary setObject:string forKey:TEXT_KEY];
				
			}
		}
	}
	
}




@end

