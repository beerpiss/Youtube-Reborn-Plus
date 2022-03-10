#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Workaround for https://github.com/MiRO92/uYou-for-YouTube/issues/12
%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1 {
    %orig(nil);
}
%end

// YouRememberCaption: https://www.ios-repo-updates.com/repository/poomsmart/package/com.ps.youremembercaption/
%hook YTColdConfig
- (BOOL)respectDeviceCaptionSetting {
    return NO;
}
%end

// YTClassicVideoQuality: https://github.com/PoomSmart/YTClassicVideoQuality
@interface YTVideoQualitySwitchOriginalController : NSObject
- (instancetype)initWithParentResponder:(id)responder;
@end

%hook YTVideoQualitySwitchControllerFactory
- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
    Class originalClass = %c(YTVideoQualitySwitchOriginalController);
    return originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
}
%end

// YTNoCheckLocalNetwork: https://poomsmart.github.io/repo/depictions/ytnochecklocalnetwork.html
%hook YTHotConfig
- (BOOL)isPromptForLocalNetworkPermissionsEnabled {
    return NO;
}
%end

// YTSystemAppearance: https://poomsmart.github.io/repo/depictions/ytsystemappearance.html
%hook YTColdConfig
- (BOOL)shouldUseAppThemeSetting {
    return YES;
}
%end