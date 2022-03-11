#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>

// Workaround for https://github.com/MiRO92/uYou-for-YouTube/issues/12
%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1 {
    %orig(nil);
}
%end

// YouRememberCaption: https://www.ios-repo-updates.com/repository/poomsmart/package/com.ps.youremembercaption/
// YTSystemAppearance: https://poomsmart.github.io/repo/depictions/ytsystemappearance.html
// YouAreThere: https://github.com/PoomSmart/YouAreThere
%hook YTColdConfig
- (BOOL)respectDeviceCaptionSetting {
    return NO;
}
- (BOOL)shouldUseAppThemeSetting {
    return YES;
}
- (BOOL)enableYouthereCommandsOnIos {
    return NO;
}
%end

%hook YTYouThereController
- (BOOL)shouldShowYouTherePrompt {
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

// YTSilentVote: https://github.com/PoomSmart/YTSilentVote
%hook YTInnerTubeResponseWrapper
- (id)initWithResponse:(id)response cacheContext:(id)arg2 requestStatistics:(id)arg3 mutableSharedData:(id)arg4 {
	if ([response isKindOfClass:%c(YTILikeResponse)]
		|| [response isKindOfClass:%c(YTIDislikeResponse)]
		|| [response isKindOfClass:%c(YTIRemoveLikeResponse)]) return nil;
	return %orig;
}
%end

// NoYTPremium: https://github.com/PoomSmart/NoYTPremium {{{
// Alert
%hook YTCommerceEventGroupHandler
- (void)addEventHandlers {}
%end

// Full-screen
%hook YTInterstitialPromoEventGroupHandler
- (void)addEventHandlers {}
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial { return YES; }
%end

// "Try new features" in settings
%hook YTSettingsSectionItemManager
- (void)updatePremiumEarlyAccessSectionWithEntry:(id)arg1 {}
%end

// Whatever these are for
%hook YTPromoThrottleController
- (BOOL)canShowThrottledPromo { return NO; }
- (BOOL)canShowThrottledPromoWithFrequencyCap:(id)frequencyCap { return NO; }
%end

%hook YTSurveyController
- (void)showSurveyWithRenderer:(id)arg1 surveyParentResponder:(id)arg2 {}
%end
// }}}

// IAmYouTube: https://github.com/PoomSmart/IAmYouTube {{{
#define YT_BUNDLE_ID @"com.google.ios.youtube"
#define YT_NAME @"YouTube"

@interface SSOConfiguration : NSObject
@end

%hook YTVersionUtils
+ (NSString *)appName {
    return YT_NAME;
}

+ (NSString *)appID {
    return YT_BUNDLE_ID;
}
%end

%hook GCKBUtils
+ (NSString *)appIdentifier {
    return YT_BUNDLE_ID;
}
%end

%hook GPCDeviceInfo
+ (NSString *)bundleId {
    return YT_BUNDLE_ID;
}
%end

%hook OGLBundle
+ (NSString *)shortAppName {
    return YT_NAME;
}
%end

%hook GVROverlayView
+ (NSString *)appName {
    return YT_NAME;
}
%end

%hook OGLPhenotypeFlagServiceImpl
- (NSString *)bundleId {
    return YT_BUNDLE_ID;
}
%end

%hook SSOConfiguration
- (id)initWithClientID:(id)clientID supportedAccountServices:(id)supportedAccountServices {
    self = %orig;
    [self setValue:YT_NAME forKey:@"_shortAppName"];
    [self setValue:YT_BUNDLE_ID forKey:@"_applicationIdentifier"];
    return self;
}
%end

%hook NSBundle
- (NSString *)bundleIdentifier {
    NSArray *address = [NSThread callStackReturnAddresses];
    Dl_info info = {0};
    if (dladdr((void *)[address[2] longLongValue], &info) == 0)
        return %orig;
    NSString *path = [NSString stringWithUTF8String:info.dli_fname];
    if ([path hasPrefix:NSBundle.mainBundle.bundlePath])
        return YT_BUNDLE_ID;
    return %orig;
}

- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return YT_BUNDLE_ID;
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return YT_NAME;
    return %orig;
}
%end

#undef YT_BUNDLE_ID
#undef YT_NAME 
// }}}

