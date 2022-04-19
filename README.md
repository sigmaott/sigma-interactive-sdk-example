# SigmaInteractive SDK

### I. Cài đặt

Thêm file [SigmaInteractiveSDK.aar](https://github.com/phamngochai123/sigma-interactive-sdk-example/blob/mobile-android/libs/SigmaInteractiveSDK.aar) vào thư mục libs cùng cấp với thư mục app của project.

Thêm vào app/build.gradle: 

```java
dependencies {
   ...
   implementation files('../libs/SigmaInteractiveSDK.aar')

}
```

### II. Sử dụng

- #### SigmaInteractiveHelper

  #### - openInteractiveView - Mở view tương tác:

```java
SigmaInteractiveHelper.getInstance(PlayerActivity.this).openInteractiveView(xInteractive, yInteractive, widthInteractiveView, heightInteractiveView, url, sigmaWebviewCallback, widthPlayer, heightPlayer, xPlayer, yPlayer);
```

PlayerActivity: Activity muốn đặt view tương tác.

xInteractive: Vị trí muốn đặt view tương tác theo trục x.

yInteractive: Vị trí muốn đặt view tương tác theo trục y.

widthInteractiveView: Chiều rộng của view tương tác.

heightInteractiveView: Chiều cao của view tương tác.

url: Link tương tác.

widthPlayer: Chiều rộng của player.

heightPlayer: Chiều caocủa player.

xPlayer: Vị trí player theo trục x.

yPlayer: Vị trí player theo trục y.

sigmaWebviewCallback: Nghe các sự kiện bên tương tác gọi.



```java
SigmaWebViewCallback sigmaWebviewCallback = new SigmaWebViewCallback() {
    //Sự kiện khi sdk tương tác sẵn sàng
    @Override
    public void onReady() {
                JSONObject userDataSend = new JSONObject();
                if (userData != null) {
                    Set<String> keys = userData.keySet();
                    for (String key : keys) {
                        try {
                            userDataSend.put(key, JSONObject.wrap(userData.get(key)));
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }
                }
                SigmaWebView interactiveView = SigmaInteractiveHelper.getInstance(PlayerActivity.this).getInteractiveView();
                if (interactiveView != null) {
                    //gửi dữ liệu cho sdk tương tác
                    interactiveView.sendOnReadyBack(userData != null ? userDataSend.toString() : "{}");
                }
    }
    
    @Override
    public void onKeyDown(int code) {
    }
    
    //Sự kiện khi overlay hiển thị
    @Override
    public void onOverlayShow() {
    }
    
    //Sự kiện khi overlay tắt
    @Override
    public void onOverlayHide() {
    }

    //Sự kiện khi hệ thống tương tác yêu cầu player full màn hình
    @Override
    public void onForceFullScreen() {
    }

    //Sự kiện khi hệ thống tương tác yêu cầu player thoát full màn hình
    @Override
    public void onExitFullScreen() {
    }
};
```

#### - getInteractiveView - lấy view tương tác hiện tại

```java
SigmaInteractiveHelper.getInstance(PlayerActivity.this).getInteractiveView();
```

#### - sendID3InstantInteractive - gửi id3 instant cho sdk tương tác

```java
SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendID3InstantInteractive(value);
```

#### - sendID3Interactive - gửi id3 cho sdk tương tác

```java
SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendID3Interactive(value);
```

#### - setLayoutInteractiveView - thay đổi kích thước, vị trí đặt view tương tác và kích thước , vị trí player

```java
SigmaInteractiveHelper.getInstance(PlayerActivity.this).setLayoutInteractiveView(xInteractive, yInteractive, widthInteractiveView, heightInteractiveView, widthPlayer, heightPlayer, xPlayer, yPlayer);
```

xInteractive: Vị trí muốn đặt view tương tác theo trục x.

yInteractive: Vị trí muốn đặt view tương tác theo trục y.

widthInteractiveView: Chiều rộng của view tương tác.

heightInteractiveView: Chiều cao của view tương tác.

url: Link tương tác.

widthPlayer: Chiều rộng của player.

heightPlayer: Chiều caocủa player.

xPlayer: Vị trí player theo trục x.

yPlayer: Vị trí player theo trục y.

#### - clearInterActiveView - xóa view tương tác

```java
SigmaInteractiveHelper.getInstance(PlayerActivity.this).clearInterActiveView();
```