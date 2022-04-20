# SigmaInteractive SDK

## Requirement: Android 5.0+, Exoplayer 2.9.+

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

1. Thêm SigmaInteractive sdk vào project (mục **I**).

2. Thêm sự kiện lắng nghe khi id3 bắt đầu parse để gửi dữ liệu cho sdk tương tác

   `SigmaRendererFactory` xem trong demo

   ```java
   DefaultRenderersFactory renderersFactory = new SigmaRendererFactory(getApplicationContext(), new SigmaRendererFactory.Id3ParsedListener() {
       @Override
       public void onId3Parsed(Metadata metadata) {
           if (metadata != null) {
               for (int i = 0; i < metadata.length(); i++) {
                   Metadata.Entry entry = metadata.get(i);
                   if (entry instanceof TextInformationFrame) {
                       String des = ((TextInformationFrame) entry).description;
                       String value = ((TextInformationFrame) entry).value;
                       if (des.toUpperCase().equals("TXXX")) {
                           if(SigmaInteractiveHelper.getInstance(PlayerActivity.this).getInteractiveView() != null) {
                               SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendID3InstantInteractive(value);
                           }
                       }
                   }
               }
           }
       }
   });
   player = new ExoPlayer.Builder(this, renderersFactory).build();
   ```

3. Thêm sự kiện lắng nghe khi id3 trả ra đúng thời điểm hẹn giờ để gửi dữ liệu cho sdk tương tác

   ```java
   player.addAnalyticsListener(new AnalyticsListener() {
       @Override
       public void onMetadata(AnalyticsListener.EventTime eventTime, Metadata metadata) {
           if (metadata != null) {
               for (int i = 0; i < metadata.length(); i++) {
                   Metadata.Entry entry = metadata.get(i);
                   if (entry instanceof TextInformationFrame) {
                       String des = ((TextInformationFrame) entry).description;
                       String value = ((TextInformationFrame) entry).value;
                       if (des.toUpperCase().equals("TXXX")) {
                           if(SigmaInteractiveHelper.getInstance(PlayerActivity.this).getInteractiveView() != null) {
                               SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendID3Interactive(value);
                           }
                       }
                   }
               }
           }
       }
   });
   ```

4. Tạo SigmaWebViewCallback để lắng nghe các sự kiện từ sdk tương tác.

   4.1 Trong hàm onReady gửi dữ liệu dạng json string cho sdk tương tác (bắt buộc)

   ```java
   SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendOnReadyBack(userData != null ? userDataSend.toString() : "{}");
   ```

5. Mở view tương tác với vị trí (vị trí (x: 0, y: 0) ở góc trên bên trái màn hình), kích thước. Kích thước player, vị trí player so với view tương tác để sdk tương tác tính toán hiển thị.

   ```java
   SigmaInteractiveHelper.getInstance(PlayerActivity.this).openInteractiveView(xInteractiveView, yInteractiveView, widthInteractiveView, heightInteractiveView, url, sigmaWebviewCallback, widthPlayer, heightPlayer, xPlayer, yPlayer);
   ```

- #### SigmaInteractiveHelper

  #### - openInteractiveView - Mở view tương tác:
  
  ```java
  SigmaInteractiveHelper.getInstance(PlayerActivity.this).openInteractiveView(xInteractive, yInteractive, widthInteractiveView, heightInteractiveView, url, sigmaWebviewCallback, widthPlayer, heightPlayer, xPlayer, yPlayer);
  ```
  
  
  
  - `PlayerActivity`: Activity muốn đặt view tương tác.
  
  - `xInteractive`: Vị trí muốn đặt view tương tác theo trục x.
  
  - `yInteractive`: Vị trí muốn đặt view tương tác theo trục y.
  
  - `widthInteractiveView`: Chiều rộng của view tương tác.
  
  - `heightInteractiveView`: Chiều cao của view tương tác.
  
  - `url`: Link tương tác.
  
  - `widthPlayer`: Chiều rộng của player.
  
  - `heightPlayer`: Chiều caocủa player.
  
  - `xPlayer`: Vị trí player theo trục x.
  
  - `yPlayer`: Vị trí player theo trục y.
  
  - `sigmaWebviewCallback`: Nghe các sự kiện bên tương tác gọi.
  
    #### Note: Khi nhận được sự kiện onReady của sdk tương tác cần gửi dữ liệu user cho sdk qua hàm `sendOnReadyBack` 

```java
ex:
private void openInteractiveView(int xInteractiveView, int yInteractiveView, int widthInteractiveView, int heightInteractiveView, int widthPlayer, int heightPlayer, int xPlayer, int yPlayer, Bundle userData) {
        Bundle params = getIntent().getExtras();
        String interactiveLink = ""; // or other values
        if(params != null){
            interactiveLink = params.getString("interactiveLink");
        }
        String url = interactiveLink.length() > 0 ? interactiveLink : HTML_SDK.replace("[SDK_VERSION]", VERSION);

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
                Log.d("PlayerActivity=>", "onOverlayShow");
            }
            //Sự kiện khi overlay tắt
            @Override
            public void onOverlayHide() {
                Log.d("PlayerActivity=>", "onOverlayHide");
            }

            //Sự kiện khi hệ thống tương tác yêu cầu player full màn hình
            @Override
            public void onForceFullScreen() {
                Log.d("PlayerActivity=>", "onForceFullScreen");
                PlayerActivity.this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            }

            //Sự kiện khi hệ thống tương tác yêu cầu player thoát full màn hình
            @Override
            public void onExitFullScreen() {
                Log.d("PlayerActivity=>", "onExitFullScreen");
                PlayerActivity.this.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            }
        };
        SigmaInteractiveHelper.getInstance(PlayerActivity.this).openInteractiveView(xInteractiveView, yInteractiveView, widthInteractiveView, heightInteractiveView, url, sigmaWebviewCallback, widthPlayer, heightPlayer, xPlayer, yPlayer);
    }
```

#### - getInteractiveView - lấy view tương tác hiện tại

```java
SigmaInteractiveHelper.getInstance(PlayerActivity.this).getInteractiveView();
```

#### - sendID3InstantInteractive - gửi id3 instant cho sdk tương tác

#### - sendID3Interactive - gửi id3 cho sdk tương tác

```java
ex:
protected void onCreate(Bundle savedInstanceState) {
        ...
        DefaultRenderersFactory renderersFactory = new SigmaRendererFactory(getApplicationContext(), new SigmaRendererFactory.Id3ParsedListener() {
            @Override
            public void onId3Parsed(Metadata metadata) {
                if (metadata != null) {
                    for (int i = 0; i < metadata.length(); i++) {
                        Metadata.Entry entry = metadata.get(i);
                        if (entry instanceof TextInformationFrame) {
                            String des = ((TextInformationFrame) entry).description;
                            String value = ((TextInformationFrame) entry).value;
                            if (des.toUpperCase().equals("TXXX")) {
                                if(SigmaInteractiveHelper.getInstance(PlayerActivity.this).getInteractiveView() != null) {
                                    SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendID3InstantInteractive(value);
                                }
                            }
                        }
                    }
                }
            }
        });
        player = new ExoPlayer.Builder(this, renderersFactory).build();
        player.addAnalyticsListener(new AnalyticsListener() {
            @Override
            public void onMetadata(AnalyticsListener.EventTime eventTime, Metadata metadata) {
                if (metadata != null) {
                    for (int i = 0; i < metadata.length(); i++) {
                        Metadata.Entry entry = metadata.get(i);
                        if (entry instanceof TextInformationFrame) {
                            String des = ((TextInformationFrame) entry).description;
                            String value = ((TextInformationFrame) entry).value;
                            if (des.toUpperCase().equals("TXXX")) {
                                if(SigmaInteractiveHelper.getInstance(PlayerActivity.this).getInteractiveView() != null) {
                                    SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendID3Interactive(value);
                                }
                            }
                        }
                    }
                }
            }
        });
        StyledPlayerView playerView = (StyledPlayerView) findViewById(R.id.player_view);
        playerView.setPlayer(player);
    	...
    }
```

#### - setLayoutInteractiveView - thay đổi kích thước, vị trí đặt view tương tác và kích thước , vị trí player

```java
SigmaInteractiveHelper.getInstance(PlayerActivity.this).setLayoutInteractiveView(xInteractive, yInteractive, widthInteractiveView, heightInteractiveView, widthPlayer, heightPlayer, xPlayer, yPlayer);
```

- `xInteractive`: Vị trí muốn đặt view tương tác theo trục x.

- `yInteractive`: Vị trí muốn đặt view tương tác theo trục y.

- `widthInteractiveView`: Chiều rộng của view tương tác.

- `heightInteractiveView`: Chiều cao của view tương tác.

- `widthPlayer`: Chiều rộng của player.

- `heightPlayer`: Chiều caocủa player.

- `xPlayer`: Vị trí player theo trục x.

- `yPlayer`: Vị trí player theo trục y.

  ```java
  ex:
  @Override
  public void onConfigurationChanged(Configuration newConfig) {
      Log.d("onConfigurationChanged", String.valueOf(newConfig.orientation));
      super.onConfigurationChanged(newConfig);
      if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
          SigmaInteractiveHelper.getInstance(PlayerActivity.this).setLayoutInteractiveView(0, 0, containerView.getLayoutParams().width, containerView.getLayoutParams().height, containerView.getLayoutParams().width, containerView.getLayoutParams().height, 0, 0);
      } else {
          SigmaInteractiveHelper.getInstance(PlayerActivity.this).setLayoutInteractiveView(0, 0, containerView.getLayoutParams().width, containerView.getLayoutParams().height, containerView.getLayoutParams().width, containerView.getLayoutParams().height, 0, 0);
      }
  }
  ```

#### - clearInterActiveView - xóa view tương tác

```java
SigmaInteractiveHelper.getInstance(PlayerActivity.this).clearInterActiveView();
```

```java
ex:
@Override
protected void onDestroy() {
    ...
    player.release();
    SigmaInteractiveHelper.getInstance(PlayerActivity.this).clearInterActiveView();
    super.onDestroy();
    ...
}
```