# SigmaInteractive SDK

### I. Cài đặt

Thêm Script:

```html
<script src="https://dev-livestream.gviet.vn/ilp-statics/2.0.0/sigma-interactive-js.js"></script>
```

### II. Sử dụng

1. ##### Khởi tạo:

   Example (main.js):

   ```javascript
   const SOURCE_URL = "https://dev-livestream.gviet.vn/manifest/VTV1-PACKAGE/master.m3u8";
   var videoElement = document.getDocumentById("video-id-tag");
   var player = new Hls({ enableWorker: true, debug: false });
   
   player.attachMedia(videoElement);
   player.on(Hls.Events.MEDIA_ATTACHED, function () {
       player.loadSource(SOURCE_URL);
       // Khởi tạo SigmaInteractive SDK 
       var interactiveSdk = SigmaInteractive.createInteractiveApp({
           hls: player,//require
           userData: {},//require
           containerId: "div-id-container",//require
           iframeSrc:
           "https://dev-livestream.gviet.vn/ilp-statics/2.0.0/webos-interactive.html",//option
       });
       // Đăng ký lắng nghe sự kiện...
   });
   ```

2. ##### Sử dụng:

   Lắng nghe sự kiện (main.js)::

   Example:

   ```javascript
   interactiveSdk.$on("INTERACTIVE_SHOW", function () {
       // Sự kiện xin hiển thị overlay
   });
   interactiveSdk.$on("INTERACTIVE_HIDE", function () {
       // Sự kiện xin ẩn overlay
   });
   interactiveSdk.$on("INTERACTIVE_FOCUS", function () {
       // Sự kiện xin focus
   });
   interactiveSdk.$on("INTERACTIVE_UNFOCUS", function () {
       // Sự kiện trả lại focus
   });
   interactiveSdk.$on("INTERACTIVE_CONNECTION_ERROR", function () {
       // Sự kiện khi gặp lỗi
   });
   interactiveSdk.$on("ON_KEY_DOWN", function (data) {
       // Xử lý sự kiện bấm phím theo tên
       const key = data.detail;
       console.log("ON_KEY_DOWN:", key);
       switch (key) {
           case "backspace":
               // Xử lý khi bấm back
               break;
           default:
               break;
       }
   });
   ```
