//
//  Tweak.x
//  The Workshop - Logos / Objective-C Dynamic Library Source
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    NSLog(@"[TheWorkshop Logos] Hooked UIViewController viewDidAppear executed.");
}

%end

%ctor {
    NSLog(@"[TheWorkshop Logos] Tweak Dynamic Library Initialized (%s)", getprogname());
}
