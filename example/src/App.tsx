import * as React from 'react';
import { StyleSheet, View, Button } from 'react-native';
import NativeKakaoLogin from 'native-kakao-login';

export default function App() {
  return (
    <View style={styles.container}>
      <Button
        title="Kakao Login"
        onPress={async () => {
          try {
            const loginResult = await NativeKakaoLogin.login();
            console.log(loginResult);
            const profile = await NativeKakaoLogin.getProfile();
            console.log(profile);
          } catch (e) {
            console.error(e);
          }
        }}
      />
      <Button
        title="Kakao Logout"
        onPress={async () => {
          try {
            const result = await NativeKakaoLogin.logout();
            console.log(result);
          } catch (e) {
            console.error(e);
          }
        }}
      />
      <Button
        title="Kakao Unlink"
        onPress={async () => {
          try {
            const unlinkedResult = await NativeKakaoLogin.unlink();
            console.log(unlinkedResult);
          } catch (e) {
            console.error(e);
          }
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
