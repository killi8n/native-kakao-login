package com.killi8nreactnativekakaologin

import android.content.ContentValues.TAG
import android.util.Log
import com.facebook.react.bridge.*
import com.kakao.sdk.auth.AuthApiClient
import com.kakao.sdk.auth.model.OAuthToken
import com.kakao.sdk.common.model.ApiError
import com.kakao.sdk.common.model.AuthError
import com.kakao.sdk.common.model.ClientError
import com.kakao.sdk.common.model.KakaoSdkError
import com.kakao.sdk.user.UserApi
import com.kakao.sdk.user.UserApiClient

class NativeKakaoLoginModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    override fun getName(): String {
        return "NativeKakaoLogin"
    }

    fun parseToken(token: OAuthToken): WritableMap {
      var tokenInfos = Arguments.createMap();
      tokenInfos.putBoolean("success", true);
      tokenInfos.putString("accessToken", token.accessToken);
      tokenInfos.putString("expiredAt", token.accessTokenExpiresAt.toString());
      tokenInfos.putString("refreshToken", token.refreshToken);
      token.refreshTokenExpiresAt?.let {
        tokenInfos.putString("refreshTokenExpiresAt", it.toString());
      }
      return tokenInfos
    }

    fun parseError(error: Throwable): WritableMap? {
      var errorInfos = Arguments.createMap();
      var clientError = (error as? ClientError)
      if (clientError != null) {
        errorInfos.putBoolean("success", false);
        errorInfos.putString("errorType", "ClientError");
        errorInfos.putString("errorMessage", clientError.msg);
        return errorInfos
      }
      var authError = (error as? AuthError)
      if (authError != null) {
        errorInfos.putBoolean("success", false);
        errorInfos.putString("errorType", "AuthError");
        errorInfos.putString("errorMessage", authError.msg);
        return errorInfos
      }
      var apiError = (error as? ApiError)
      if (apiError != null) {
        errorInfos.putBoolean("success", false);
        errorInfos.putString("errorType", "ApiError");
        errorInfos.putString("errorMessage", apiError.msg);
        errorInfos.putInt("errorCode", apiError.statusCode);
        return errorInfos
      }
      return null
    }

    @ReactMethod
    fun login(promise: Promise) {
      var isKakaoAppInstalled: Boolean = UserApiClient.instance.isKakaoTalkLoginAvailable(this.reactApplicationContext);
      if (isKakaoAppInstalled) {
        // 카카오톡으로 로그인
        UserApiClient.instance.loginWithKakaoTalk(this.reactApplicationContext) { token, error ->
          if (error != null) {
            promise.resolve(this.parseError(error));
          } else if (token != null) {
            promise.resolve(this.parseToken(token));
          }
        }
      } else {
        // 카카오계정으로 로그인
        UserApiClient.instance.loginWithKakaoAccount(this.reactApplicationContext) { token, error ->
          if (error != null) {
            promise.resolve(this.parseError(error));
          } else if (token != null) {
            promise.resolve(this.parseToken(token));
          }
        }
      }
    }

    @ReactMethod
    fun getProfile(promise: Promise) {
      UserApiClient.instance.me { user, error ->
        if (error != null) {
          promise.resolve(this.parseError(error))
        } else if (user != null) {
          var userInfos = Arguments.createMap();
          userInfos.putBoolean("success", true)
          userInfos.putInt("id", user.id.toInt());
          var propertyInfos = Arguments.createMap()
          user.properties?.let { it
            if (it.getValue("nickname") != null) {
              propertyInfos.putString("nickname", it.getValue("nickname"));
            }
            if (it.getValue("profile_image") != null) {
              propertyInfos.putString("profile_image", it.getValue("profile_image"));
            }
            if (it.getValue("thumbnail_image") != null) {
              propertyInfos.putString("thumbnail_image", it.getValue("thumbnail_image"));
            }
          }
          userInfos.putMap("properties", propertyInfos);
          promise.resolve(userInfos);
        }
      }
    }

    @ReactMethod
    fun getAccessTokenInfo(promise: Promise) {
      UserApiClient.instance.accessTokenInfo{ tokenInfo, error ->
        if (error != null) {
          promise.resolve(this.parseError(error))
        } else if (tokenInfo != null) {
          tokenInfo.let { it ->
            val accessTokenInfoResponse = Arguments.createMap()
            accessTokenInfoResponse.putDouble("expiresIn", it.expiresIn.toDouble())
            accessTokenInfoResponse.putDouble("id", it.id.toDouble())
            promise.resolve(accessTokenInfoResponse)
          }
        }
      }
    }

    @ReactMethod
    fun logout(promise: Promise) {
      UserApiClient.instance.logout { error ->
        if (error != null) {
          promise.resolve(this.parseError(error))
        } else {
          var result = Arguments.createMap();
          result.putBoolean("success", true);
          promise.resolve(result);
        }
      }
    }

    @ReactMethod
    fun unlink(promise: Promise) {
      UserApiClient.instance.unlink { error ->
        if (error != null) {
          promise.resolve(this.parseError(error))
        } else {
          var result = Arguments.createMap();
          result.putBoolean("success", true);
          promise.resolve(result);
        }
      }
    }

    @ReactMethod
    fun checkTokenValidated(promise: Promise) {
      val tokenValidatedResult = Arguments.createMap()
      if (AuthApiClient.instance.hasToken()) {
        UserApiClient.instance.accessTokenInfo { _, error ->
          if (error != null) {
            if (error is KakaoSdkError && error.isInvalidTokenError() == true) {
              //로그인 필요
              tokenValidatedResult.putBoolean("validated", false)
              promise.resolve(tokenValidatedResult)
            }
            else {
              //기타 에러
              tokenValidatedResult.putBoolean("validated", false)
              promise.resolve(tokenValidatedResult)
            }
          }
          else {
            //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
            tokenValidatedResult.putBoolean("validated", true)
            promise.resolve(tokenValidatedResult)
          }
        }
      }
      else {
        //로그인 필요
        tokenValidatedResult.putBoolean("validated", false)
        promise.resolve(tokenValidatedResult)
      }
    }
}
