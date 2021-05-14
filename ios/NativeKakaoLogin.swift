import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@objc(NativeKakaoLogin)
class NativeKakaoLogin: NSObject {
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    func parseOAuthToken(oauthToken: OAuthToken) -> [String: Any] {
        var oauthTokenInfos: [String: Any] = [
            "success": true,
            "accessToken": oauthToken.accessToken,
            "expiredAt": oauthToken.expiredAt,
            "expiresIn": oauthToken.expiresIn,
            "refreshToken": oauthToken.refreshToken,
            "refreshTokenExpiredAt": oauthToken.refreshTokenExpiredAt,
            "refreshTokenExpiresIn": oauthToken.refreshTokenExpiresIn,
            "tokenType": oauthToken.tokenType
        ]
        if let scope = oauthToken.scope {
            oauthTokenInfos["scope"] = scope
        }
        if let scopes = oauthToken.scopes {
            oauthTokenInfos["scopes"] = scopes
        }
        return oauthTokenInfos
    }
    
    func parseError(error: Error) -> [String: Any?]? {
        if let error = error as? SdkError {
            if error.isClientFailed {
                let clientError = error.getClientError()
                let errorResult: [String: Any?] = ["success": false, "errorType": "ClientError", "errorMessage": clientError.message ?? nil]
                return errorResult
            }
            if error.isApiFailed {
                let apiError = error.getApiError()
                let errorResult: [String: Any?] = ["success": false, "errorType": "ApiError", "errorMessage": apiError.info?.msg ?? nil, "errorCode": apiError.info?.code ?? nil, "errorScopes": apiError.info?.requiredScopes ?? nil]
                return errorResult
            }
            if error.isAuthFailed {
                let authError = error.getAuthError()
                let errorResult: [String: Any?] = ["success": false, "errorType": "AuthError", "errorMessage": authError.info?.errorDescription ?? nil]
                return errorResult
            }
        }
        return nil
    }
    
    @objc
    func login(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        DispatchQueue.main.async {
            let isKakaoAppInstalled: Bool = UserApi.isKakaoTalkLoginAvailable()
            if isKakaoAppInstalled {
                UserApi.shared.loginWithKakaoTalk {(oauthToken: OAuthToken?, error: Error?) in
                    if let error = error as? SdkError {
                        resolve(self.parseError(error: error))
                        return
                    }
                    if let oauthToken = oauthToken {
                        let oauthTokenInfos = self.parseOAuthToken(oauthToken: oauthToken)
                        resolve(oauthTokenInfos)
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    if let error = error {
                        resolve(self.parseError(error: error))
                        return
                    }
                    if let oauthToken = oauthToken {
                        let oauthTokenInfos = self.parseOAuthToken(oauthToken: oauthToken)
                        resolve(oauthTokenInfos)
                    }
                }
            }
        }
    }
    
    func parseUser(user: User) -> [String: Any] {
        var userInfo: [String: Any] = [
            "id": user.id
        ]
        userInfo["success"] = true
        if let connectedAt = user.connectedAt {
            userInfo["connectedAt"] = connectedAt
        }
        if let groupUserToken = user.groupUserToken {
            userInfo["groupUserToken"] = groupUserToken
        }
        if let kakaoAccount = user.kakaoAccount {
            userInfo["kakaoAccount"] = kakaoAccount
        }
        if let properties = user.properties {
            userInfo["properties"] = properties
        }
        if let synchedAt = user.synchedAt {
            userInfo["synchedAt"] = synchedAt
        }
        return userInfo
    }
    
    func parseAccessTokenInfo(accessTokenInfo: AccessTokenInfo) -> [String: Any] {
        var accessTokenInfoResponse: [String: Any] = [:]
        accessTokenInfoResponse["id"] = accessTokenInfo.id
        accessTokenInfoResponse["expiresIn"] = accessTokenInfo.expiresIn
        
        return accessTokenInfoResponse
    }
    
    @objc
    func getProfile(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        UserApi.shared.me { (user: User?, error: Error?) in
            if let error = error {
                resolve(self.parseError(error: error))
                return
            }
            if let user = user {
                let userInfo = self.parseUser(user: user)
                resolve(userInfo)
            }
        }
    }
    
    @objc
    func getAccessTokenInfo(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        UserApi.shared.accessTokenInfo { (accessTokenInfo: AccessTokenInfo?, error: Error?) in
            if let error = error {
                resolve(self.parseError(error: error))
                return
            }
            if let accessTokenInfo = accessTokenInfo {
                let accessTokenInfoResponse = self.parseAccessTokenInfo(accessTokenInfo: accessTokenInfo)
                resolve(accessTokenInfoResponse)
            }
        }
    }
    
    @objc
    func checkTokenValidated(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        var tokenValidatedResult: [String: Any] = [:]
        if (AuthApi.hasToken()) {
            UserApi.shared.accessTokenInfo { (_, error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        //로그인 필요
                        tokenValidatedResult["validated"] = false
                        resolve(tokenValidatedResult)
                    }
                    else {
                        //기타 에러
                        tokenValidatedResult["validated"] = false
                        resolve(tokenValidatedResult)
                    }
                } else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                    tokenValidatedResult["validated"] = true
                    resolve(tokenValidatedResult)
                }
            }
        } else {
            //로그인 필요
            tokenValidatedResult["validated"] = false
            resolve(tokenValidatedResult)
        }
    }
    
    @objc
    func logout(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        UserApi.shared.logout { (error: Error?) in
            if let error = error {
                resolve(self.parseError(error: error))
                return
            }
            resolve(["success": true])
        }
    }
    
    @objc
    func unlink(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        UserApi.shared.unlink { (error: Error?) in
            if let error = error {
                resolve(self.parseError(error: error))
                return
            }
            resolve(["success": true])
        }
    }
}
