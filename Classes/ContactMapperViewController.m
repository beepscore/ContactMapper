//
//  ContactMapperViewController.m
//  ContactMapper
//
//  Created by Steve Baker on 1/30/10.
//  Copyright Beepscore LLC 2010. All rights reserved.
//

#import "ContactMapperViewController.h"
#import "ContactAnnotation.h"
#import "AddressGeocoder.h"

@implementation ContactMapperViewController

#pragma mark -
#pragma mark properties

@synthesize mapView;
@synthesize newAnnotation;

#pragma mark -
#pragma mark initializers
/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)recenterMap {
    NSArray *coordinates = [self.mapView valueForKeyPath:@"annotations.coordinate"];
    CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
    CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
    for (NSValue *value in coordinates) {
        CLLocationCoordinate2D coord = {0.0f, 0.0f};
        [value getValue:&coord];
        if (coord.longitude > maxCoord.longitude) {
            maxCoord.longitude = coord.longitude;
        }
        if (coord.latitude > maxCoord.latitude) {
            maxCoord.latitude = coord.latitude;
        }
        if (coord.longitude < minCoord.longitude) {
            minCoord.longitude = coord.longitude;
        }
        if (coord.latitude < minCoord.latitude) {
            minCoord.latitude = coord.latitude;
        }        
    }
    MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    region.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.0;
    region.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.0;
    region.span.longitudeDelta = maxCoord.longitude - minCoord.longitude;
    region.span.latitudeDelta = maxCoord.latitude - minCoord.latitude;
    [self.mapView setRegion:region animated:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (nil != self.newAnnotation) {
        [self.mapView addAnnotation:self.newAnnotation];
        self.newAnnotation = nil;
    }
    if (self.mapView.annotations.count > 1) {
        [self recenterMap];
    }
}



/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark destructors and memory cleanUp
// use cleanUp method to avoid repeating code in setView, viewDidUnload, and dealloc
- (void)cleanUp {
    [mapView release], mapView = nil;
    [newAnnotation release], newAnnotation = nil;
}


// Release IBOutlets in setView.  
// Ref http://developer.apple.com/iPhone/library/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmNibObjects.html
//
// http://moodle.extn.washington.edu/mod/forum/discuss.php?d=3162
- (void)setView:(UIView *)aView {
    
    if (!aView) { // view is being set to nil        
        // set outlets to nil, e.g. 
        // self.anOutlet = nil;
        [self cleanUp];
    }    
    // Invoke super's implementation last    
    [super setView:aView];    
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	[self cleanUp];
}


- (void)dealloc {
    [self cleanUp];
    [super dealloc];
}


#pragma mark -
- (void)setCurrentLocation:(CLLocation *)location {
    // region is a C structure with a center and a span
    MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    region.center = location.coordinate;
    region.span.longitudeDelta = 0.15f;
    region.span.latitudeDelta = 0.15f;
    [self.mapView setRegion:region animated:YES];
}


- (IBAction)choose {
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker
                            animated:YES];
    [picker release];
}

#pragma mark People Picker Delegate Methods

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    if (kABPersonAddressProperty == property) {
        NSString *fullName = (NSString *)ABRecordCopyCompositeName(person);
        CLLocationCoordinate2D coordinate = {0.0f, 0.0f};
        self.newAnnotation = [ContactAnnotation annotationWithCoordinate:coordinate];
        self.newAnnotation.title = fullName;
        self.newAnnotation.person = person;
        [fullName release];
        ABMultiValueRef addresses = ABRecordCopyValue(person, kABPersonAddressProperty);
        CFIndex selectedAddressIndex = ABMultiValueGetIndexForIdentifier(addresses, identifier);
        CFDictionaryRef address = ABMultiValueCopyValueAtIndex(addresses, selectedAddressIndex);
        self.newAnnotation.coordinate = [AddressGeocoder locationOfAddress:address];
        [self dismissModalViewControllerAnimated:YES];
    }
    return NO;
}


#pragma mark MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)aMapView
            viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *view = nil;
    if (annotation != aMapView.userLocation) {
        view = (MKPinAnnotationView *)
        [aMapView dequeueReusableAnnotationViewWithIdentifier:@"identifier"];
        if (nil == view) {
            view = [[[MKPinAnnotationView alloc]
                     initWithAnnotation:annotation
                     reuseIdentifier:@"identifier"]
                    autorelease];
        }
        [view setPinColor:MKPinAnnotationColorPurple];
        [view setCanShowCallout:YES];
        [view setAnimatesDrop:YES];
    } else {
        CLLocation *location = [[CLLocation alloc]
                                initWithLatitude:annotation.coordinate.latitude
                                longitude:annotation.coordinate.longitude];
        [self setCurrentLocation:location];
    }
    return view;
}

@end
