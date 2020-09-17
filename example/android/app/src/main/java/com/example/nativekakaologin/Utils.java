package com.example.nativekakaologin;

import android.content.Context;

import com.kakao.sdk.common.KakaoSdk;

public class Utils {
  public static void initKakaoSDK(Context context, String appKey) {
    KakaoSdk.init(context, appKey);
  }
}
