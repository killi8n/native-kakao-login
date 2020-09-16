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
  errorType: 'ClientError' | 'ApiError' | 'AuthError';
  errorMessage: string | null;
  errorCode: number | null;
  errorScopes: string[] | null;
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
}

interface LogoutResult {
  success: boolean;
}

interface UnlinkResult {
  success: boolean;
}

type NativeKakaoLoginType = {
  login: () => Promise<LoginResult>;
  getProfile: () => Promise<GetProfileResult>;
  logout: () => Promise<LogoutResult>;
  unlink: () => Promise<UnlinkResult>;
};

const { NativeKakaoLogin } = NativeModules;

export default NativeKakaoLogin as NativeKakaoLoginType;
