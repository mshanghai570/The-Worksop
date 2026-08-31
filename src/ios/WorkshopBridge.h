//
//  WorkshopBridge.h
//  Bridging Header connecting Objective-C / Logos Tweak runtime with Swift
//

#ifndef WorkshopBridge_h
#define WorkshopBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT void WorkshopLogSystemMessage(NSString *message);
FOUNDATION_EXPORT void WorkshopSwizzleInstanceMethod(Class targetClass, SEL originalSelector, SEL swizzledSelector);

#endif /* WorkshopBridge_h */
