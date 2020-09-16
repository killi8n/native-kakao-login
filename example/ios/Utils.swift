//
//  Utils.swift
//  NativeKakaoLoginExample
//
//  Created by Dongho Choi on 2020/09/16.
//  Copyright © 2020 Facebook. All rights reserved.
//

import KakaoSDKCommon
import KakaoSDKAuth

@objc
class Utils: NSObject {
  @objc
  static func initKakaoSDK(appKey: String) -> Void {
    KakaoSDKCommon.initSDK(appKey: appKey)
  }
  
  @objc
  static func handleOpenUrl(url: URL) -> Bool {
    if (AuthApi.isKakaoTalkLoginUrl(url)) {
        return AuthController.handleOpenUrl(url: url)
    }
    return false
  }
}
