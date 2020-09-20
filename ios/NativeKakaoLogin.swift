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
            let isKakaoAppInstalled: Bool = AuthApi.isKakaoTalkLoginAvailable()
            if isKakaoAppInstalled {
                AuthApi.shared.loginWithKakaoTalk {(oauthToken: OAuthToken?, error: Error?) in
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
                AuthApi.shared.loginWithKakaoAccount {(oauthToken, error) in
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
