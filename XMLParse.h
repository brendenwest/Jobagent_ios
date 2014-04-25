//
//  JobSearch2.h
//  jobagent
//
//  Created by mac on 3/12/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CHILDREN_KEY  @"_children_"
#define TEXT_KEY  @"_text_"
#define ELEMENT_KEY  @"_Element_"


@interface XMLParse : NSObject<NSXMLParserDelegate> {
	
    NSURLConnection *rssConnection;
    NSMutableData *xmlData;
    BOOL done;
		
    NSURL* dataURL;
	NSXMLParser * xmlParser;
	NSMutableString *currentElementValue;
	NSMutableString *prevElementName;

	NSArray* elementIgnoreArray;
	NSArray* elementAsPropertyArray;
	NSString* currentElementAsProperty; 
	NSString* currentElementHierarchy;

		
	NSMutableDictionary* rootDictionary;
	NSMutableDictionary* currentDictionary;
	NSMutableArray* dictionaryStack;


}

@property (nonatomic, strong) NSURL *dataURL;
@property(nonatomic, strong) NSArray* elementIgnoreArray;
@property(nonatomic, strong) NSArray* elementAsPropertyArray;

@property (nonatomic, strong) NSURLConnection *rssConnection;
@property (nonatomic, strong) NSMutableData *xmlData;

@property (nonatomic, strong) NSMutableArray *dictionaryStack;
@property (nonatomic, strong) NSMutableDictionary *rootDictionary;
@property (nonatomic, strong) NSMutableDictionary *currentDictionary;

@property (nonatomic, strong) NSXMLParser *xmlParser;


- (id) initWithURL:(NSURL*) URL ignoring:(NSArray*)ignoreList treatAsProperty:(NSArray*) treatAsPropertyList;
- (id) initWithData:(NSData*)data ignoring:(NSArray*)ignoreList treatAsProperty:(NSArray*)treatAsPropertyList;
- (NSDictionary*) parse;
- (NSDictionary *)parseData;


@end
