//
//  AddressGeocoder.m
//  ContactMapper
//
//  Created by Steve Baker on 1/31/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//
//  Created by Bill Dudney on 5/15/09.
//  Copyright 2009 Gala Factory Software LLC. All rights reserved.
//
//
//  Licensed with the Apache 2.0 License
//  http://apache.org/licenses/LICENSE-2.0
//
// To use TouchXML and libxml2, in Project settings/Build header search paths add /usr/include/libxml2
// Also in Project settings/Linking/Other linker flags add -lxml2
// Ref http://dblog.com.au/general/iphone-sdk-tutorial-building-an-advanced-rss-reader-using-touchxml-part-1/

#import "AddressGeocoder.h"
#import "CXMLNode_XPathExtensions.h"
#import "CXMLDocument.h"

NSString *MAPS_API_KEY = 
  @"ABQIAAAATejoI1-rG9VOa4T5f3ppWRRYQtG-vnXKOEpkBE1rl0xG1xYLZBTYfFQvZDnVp0yQINRy-HPV5AeNaA";

@implementation AddressGeocoder

+ (BOOL)geocodeStreetAddress:(NSString *)street 
                        city:(NSString *)city
                       state:(NSString *)state
                         zip:(NSString *)zip
                     country:(NSString *)country
                intoLocation:(CLLocationCoordinate2D *)location {
    BOOL success = NO;
    NSString *wholeAddress = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", 
                              street, city, state, zip, country];
    NSString *firstHalf = @"http://maps.google.com/maps/geo?q=";
    NSString *secondHalf = @"&output=xml&sensor=false&key=";
    NSString *unEscapedURL = [NSString stringWithFormat:@"%@%@%@%@", 
                              firstHalf, wholeAddress, secondHalf, 
                              MAPS_API_KEY];
    NSString *urlString = [unEscapedURL 
                           stringByAddingPercentEscapesUsingEncoding:
                           NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *error = nil;
    CXMLDocument *doc = [[CXMLDocument alloc] 
                         initWithContentsOfURL:url 
                         options:CXMLDocumentTidyXML error:&error];
    CXMLElement *element = [doc rootElement];
    NSDictionary *namespaceMappings = 
    [NSDictionary dictionaryWithObject:@"http://earth.google.com/kml/2.0"
                                forKey:@"kml"];
    NSArray *status = [element nodesForXPath:@"//kml:Status/kml:code" 
                           namespaceMappings:namespaceMappings
                                       error:&error];
    if([@"200" isEqualToString:[[status objectAtIndex:0] stringValue]]) {
        NSArray *coordElements = [element nodesForXPath:@"//kml:coordinates"
                                      namespaceMappings:namespaceMappings
                                                  error:&error];
        NSString *coords = [[coordElements objectAtIndex:0] stringValue];
        NSArray *components = [coords componentsSeparatedByString:@","];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *longitude = 
        [formatter numberFromString:[components objectAtIndex:0]];
        NSNumber *latitude = 
        [formatter numberFromString:[components objectAtIndex:1]];
        location->longitude = [longitude floatValue];
        location->latitude = [latitude floatValue];
        [formatter release];
        success = YES;
    }
    return success;
}

+ (CLLocationCoordinate2D)locationOfAddress:(CFDictionaryRef)address {
    CLLocationCoordinate2D location = {0.0f, 0.0f};
    NSString *street = 
    (NSString *)CFDictionaryGetValue(address, kABPersonAddressStreetKey);
    if(nil == street || [street length] == 0) {
        street = @"";
    }
    NSString *city = 
    (NSString *)CFDictionaryGetValue(address, kABPersonAddressCityKey);
    if(nil == city || [city length] == 0) {
        city = @"";
    }
    NSString *state = 
    (NSString *)CFDictionaryGetValue(address, kABPersonAddressStateKey);
    if(nil == state || [state length] == 0) {
        state = @"";
    }
    NSString *zip =
    (NSString *)CFDictionaryGetValue(address, kABPersonAddressZIPKey);
    if(nil == zip || [zip length] == 0) {
        zip = @"";
    }
    NSString *country = 
    (NSString *)CFDictionaryGetValue(address, kABPersonAddressCountryKey);
    if(nil == country || [country length] == 0) {
        country = @"";
    }
    
    if(![self geocodeStreetAddress:street city:city
                             state:state zip:zip country:country
                      intoLocation:&location]) {
        [self geocodeStreetAddress:@"" city:city state:state zip:zip
                           country:country intoLocation:&location];
    }
    
    return location;
}

@end

