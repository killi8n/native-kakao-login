import { NativeModules } from 'react-native';

type NativeKakaoLoginType = {
  multiply(a: number, b: number): Promise<number>;
};

const { NativeKakaoLogin } = NativeModules;

export default NativeKakaoLogin as NativeKakaoLoginType;
