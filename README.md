# native-kakao-login

## installation

### 1. iOS

first, add package and install pods

```bash
$ yarn add native-kakao-login
$ cd ios
$ pod install
```
and open .xcworkspace file

go to `info.plist`

add this two lines

```
<key>LSApplicationQueriesSchemes</key>
<array>
    <!-- 카카오톡으로 로그인 -->
    <string>kakaokompassauth</string>
    <!-- 카카오링크 -->
    <string>kakaolink</string>
</array>
```

go to URL Schemes in xcode (target -> info -> URL Types)
add URL Schemes like this

> kakao{KAKAO_APP_KEY} // ex) kakao12345678

and go to developer kakao site, add iOS platform with bundle ID

make this file `KakaoLoginUtil.swift`

```swift
import KakaoSDKAuth
import KakaoSDKCommon

@objc
class KakaoLoginUtil: NSObject {
  @objc
  static func initKakaoSDK() -> Void {
    KakaoSDKCommon.initSDK(appKey: "{YOUR_KAKAO_APP_KEY}")
  }
  @objc
  static func handleOpenUrl(url: URL) -> Bool {
    if (AuthApi.isKakaoTalkLoginUrl(url)) {
        return AuthController.handleOpenUrl(url: url)
    }

    return false
  }
}
```

`AppDelegate.m`
```c
#import "{PLATFORM_NAME}-Swift.h"

...
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
  return [KakaoLoginUtil handleOpenUrlWithUrl:url];
}
...
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef FB_SONARKIT_ENABLED
  InitializeFlipper(application);
#endif

  ...
  // add this line
  [KakaoLoginUtil initKakaoSDK];
  return YES;
}
```

### 2. android

open `build.gradle(.)`

```gradle
// add this line 
maven { url 'https://devrepo.kakao.com/nexus/content/groups/public/' }
```

open `build.gradle(app)`

```gradle
// add this line
implementation "com.kakao.sdk:v2-user:2.0.2" // 카카오 로그인, 사용자 관리
```

make `KakaoLoginUtil.java`

```java
package com.morearttopeople;

import android.content.Context;

import com.kakao.sdk.common.KakaoSdk;

public class KakaoLoginUtil {
    public static void initKakaoSDK(Context context) {
        KakaoSdk.init(context, "{NATIVE_APP_KEY}");
    }
}

```

go to `MainApplication.java`

```java
@Override
  public void onCreate() {
    super.onCreate();
    // add this line
    KakaoLoginUtil.initKakaoSDK(this);
  }
```

open `AndroidManifest.xml` and add this xml codes inside application xml

```xml
<activity android:name=“com.kakao.sdk.auth.AuthCodeHandlerActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />

        <!-- Redirect URI: "kakao{NATIVE_APP_KEY}://oauth“ -->
        <data android:host="oauth"
                android:scheme="kakao{NATIVE_APP_KEY}" />
    </intent-filter>
</activity>
```

in kakao developer site, set android platform

## how to use

1. login
```js
import KakaoLogin from "native-kakao-login";

const login = async () => {
    try {
        const result = await KakaoLogin.login();
    } catch (e) {
        console.error(e)
    }
}
```

2. getProfile
```js
import KakaoLogin from "native-kakao-login";

const login = async () => {
    try {
        const result = await KakaoLogin.getProfile();
    } catch (e) {
        console.error(e)
    }
}
```

3. logout
```js
import KakaoLogin from "native-kakao-login";

const login = async () => {
    try {
        const result = await KakaoLogin.logout();
    } catch (e) {
        console.error(e)
    }
}
```

4. unlink
```js
import KakaoLogin from "native-kakao-login";

const login = async () => {
    try {
        const result = await KakaoLogin.unlink();
    } catch (e) {
        console.error(e)
    }
}
```