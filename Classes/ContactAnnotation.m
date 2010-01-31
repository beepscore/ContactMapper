//
//  ContactAnnotation.m
//  ContactMapper
//
//  Created by Steve Baker on 1/30/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import "ContactAnnotation.h"


@implementation ContactAnnotation

#pragma mark -
#pragma mark properties

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize person = _person;


- (void)dealloc {
    [_title release], _title = nil;
    [_subtitle release], _subtitle = nil;
    
    [super dealloc];
}

+ (id)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [[[[self class] alloc] initWithCoordinate:coordinate] autorelease];
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (nil != self) {
        self.coordinate = coordinate;
    }
    return self;
}


@end
