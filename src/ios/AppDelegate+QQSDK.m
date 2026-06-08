//
//  AppDelegate+QQSDK.m
//  QQ
//

#import "AppDelegate+QQSDK.h"
#import "CDVQQSDK.h"

#import <objc/runtime.h>

@implementation AppDelegate (QQSDK)

static BOOL qqSwizzled = NO;

+ (void)load {
    Method swizzlee = class_getInstanceMethod(self, @selector(application:continueUserActivity:restorationHandler:));
    Method swizzler = class_getInstanceMethod(self, @selector(qqsdkApplication:continueUserActivity:restorationHandler:));

    if (swizzlee) {
        method_exchangeImplementations(swizzlee, swizzler);
        qqSwizzled = YES;
    } else {
        const char *typeEncoding = method_getTypeEncoding(swizzler);
        class_addMethod(self, @selector(application:continueUserActivity:restorationHandler:), method_getImplementation(swizzler), typeEncoding);
    }
}

- (BOOL)qqsdkApplication:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    CDVQQSDK *qqsdk = [self.viewController getCommandInstance:@"QQSDK"];
    if ([qqsdk handleUserActivity:userActivity]) {
        return YES;
    }

    if (qqSwizzled) {
        return [self qqsdkApplication:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }

    return NO;
}

@end
