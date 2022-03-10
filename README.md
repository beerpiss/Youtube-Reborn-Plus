# Youtube Reborn Jailed
A mostly-perfect sideloadable YouTube app, using [Lillie's](https://github.com/lillieweeb001) YouTube Reborn v3. 

# Tweaks
- [YouTube Reborn](https://github.com/LillieWeeb001/iOS-Tweaks/tree/main/YouTube%20Reborn)
- [iSponsorBlock](https://github.com/Galactic-Dev/iSponsorBlock/) with patches from [qnblackcat](https://github.com/qnblackcat/iSponsorBlock)
- [Return YouTube Dislikes](https://github.com/PoomSmart/Return-YouTube-Dislikes)
- [YouPiP](https://github.com/PoomSmart/YouPiP)
- [YouRememberCaption](https://poomsmart.github.io/repo/depictions/youremembercaption.html)
- [YTClassicVideoQuality](https://github.com/PoomSmart/YTClassicVideoQuality)
- [YTNoCheckLocalNetwork](https://poomsmart.github.io/repo/depictions/ytnochecklocalnetwork.html)
- [YTSystemAppearance](https://poomsmart.github.io/repo/depictions/ytsystemappearance.html)

# Download
Lillie provides official builds (including IPAs) of YouTube Reborn on her Patreon. Consider supporting her [here](https://patreon.com/lillieweeb).

# Building
This repo uses theos-jailed. 

## Requirements
- Xcode 13+
- [theos](https://theos.dev/docs/installation) and [theos-jailed](https://github.com/kabiroberai/theos-jailed/wiki/Installation)
- iOS 15 SDKs (should be provided by Xcode 13, but if it isn't available then you need to put one in `$THEOS/sdks`.)

## Instructions
1. Clone this repo
```bash
git clone --recursive --depth 1 https://github.com/beerpiss/Youtube-Reborn-Jailed
```

2. `cd` to the repository directory, run:
```bash
make download-youtube-reborn
make do-patch
```

3. Edit the main `Makefile` with the path to your decrypted YouTube IPA.

4. In `Tweaks/Youtube-Reborn/Makefile`, at the `TARGET` line, change `14.4` to match the iOS 14 SDK in `$THEOS/sdks`.

5. Build the IPA:
```
make package FINALPACKAGE=1 2>&1 | grep -Ev 'getcwd|descriptor'
```
The `2>&1 | grep -Ev 'getcwd|descriptor'` part is not strictly necessary, though it supresses some unneeded spam in some termninals.

6. And.. you're done. Once it finishes, your IPA will be in the `packages` directory.
