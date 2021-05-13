import { NativeModules } from 'react-native';
interface LoginResult {
  accessToken: string;
  expiredAt?: Date;
  expiresIn?: number;
  refreshToken: string;
  refreshTokenExpiredAt?: Date;
  refreshTokenExpiresIn: number;
  tokenType?: string;
  success: boolean;
  errorType?: 'ClientError' | 'ApiError' | 'AuthError';
  errorMessage?: string;
  errorCode?: number;
  errorScopes?: string[];
}

interface GetProfileResult {
  id: number;
  connectedAt?: Date;
  groupUserToken?: string;
  kakaoAccount?: any;
  properties?: {
    nickname?: string;
    profile_image?: string;
    thumbnail_image?: string;
  };
  synchedAt?: Date;
  success: boolean;
  errorType?: 'ClientError' | 'ApiError' | 'AuthError';
  errorMessage?: string;
  errorCode?: number;
  errorScopes?: string[];
}

interface GetAccessTokenInfoResult {
  id: number;
  expiresIn: number;
}

interface LogoutResult {
  success: boolean;
  errorType?: 'ClientError' | 'ApiError' | 'AuthError';
  errorMessage?: string;
  errorCode?: number;
  errorScopes?: string[];
}

interface UnlinkResult {
  success: boolean;
  errorType?: 'ClientError' | 'ApiError' | 'AuthError';
  errorMessage?: string;
  errorCode?: number;
  errorScopes?: string[];
}

type NativeKakaoLoginType = {
  login: () => Promise<LoginResult>;
  getProfile: () => Promise<GetProfileResult>;
  getAccessTokenInfo: () => Promise<GetAccessTokenInfoResult>;
  logout: () => Promise<LogoutResult>;
  unlink: () => Promise<UnlinkResult>;
};

const { NativeKakaoLogin } = NativeModules;

export default NativeKakaoLogin as NativeKakaoLoginType;
