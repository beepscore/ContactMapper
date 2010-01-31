//
//  ContactAnnotation.h
//  ContactMapper
//
//  Created by Steve Baker on 1/30/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>

@interface ContactAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D _coordinate;
    NSString *_title;
    NSString *_subtitle;
    ABRecordRef _person;
}

#pragma mark -
#pragma mark properties
@property(nonatomic,assign)CLLocationCoordinate2D coordinate;
@property(nonatomic,assign)ABRecordRef person;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subtitle;

+ (id)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
