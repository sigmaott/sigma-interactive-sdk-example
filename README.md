# SigmaInteractive SDK

## Requirement: IOS 11.0+

### I. Cài đặt

Thêm file [SigmaInteractiveSDK.framework](https://github.com/phamngochai123/sigma-interactive-sdk-example/tree/mobile-ios/SigmaInteractiveSDK.framework) vào project.

Project -> app target -> General -> Embedded Binaries

![Screen Shot 2022-04-22 at 16.27.50](https://i.ibb.co/YyLx4C8/Screen-Shot-2022-04-22-at-16-27-50.png)

![Screen Shot 2022-04-22 at 16.12.18](https://i.ibb.co/FgcCzQW/Screen-Shot-2022-04-22-at-16-12-18.png)

![Screen Shot 2022-04-22 at 16.15.41](https://i.ibb.co/CbhjSLh/Screen-Shot-2022-04-22-at-16-15-41.jpg)

![Screen Shot 2022-04-22 at 16.17.27](https://i.ibb.co/M9489JD/Screen-Shot-2022-04-22-at-16-17-27.jpg)

### II. Sử dụng

1. Thêm SigmaInteractive sdk vào project (mục **I**).

2. Import SigmaInteractiveSDK vào file: 

   ```swift
   import SigmaInteractiveSDK
   ```

3. Tạo biến sigmaInteractive type SigmaWebview thể hiện cho view tương tác.

   ```swift
   var sigmaInteractive: SigmaWebview?;
   ```

   

4. Thêm sự kiện lắng nghe khi id3 bắt đầu parse để gửi dữ liệu cho sdk tương tác

   ```swift
   //create function metadataOutput
   func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
           let items = groups.first?.items;
           for item in items! {
               let value: String = item.value as! String;
               let key: String = item.key! as! String;
               if(key == keyId3Interactive) {
                   sigmaInteractive?.sendID3TagInstant(value: value);
               }
           }
       }
   
   private func startPlayer() {
                 ...
           if let url = URL(string: videoUrl) {
               let asset = AVURLAsset(url: url, options: nil);
               playerItem = AVPlayerItem(asset: asset)
               let metadataOutput = AVPlayerItemMetadataOutput();
               metadataOutput.advanceIntervalForDelegateInvocation = TimeInterval(Int.max);
               metadataOutput.setDelegate(self, queue: DispatchQueue.main);
               playerItem!.add(metadataOutput);
               playerItem?.addObserver(self, forKeyPath: keyTimedMetadata, options: [], context: nil)
               ...
           }
       }
   ```

5. Mở view tương tác, set dữ liệu user, set callback để bắt sự kiện view tương tác khi player bắt đầu play.

   *Lưu ý: callback implement SigmaJSInterface

   ```swift
   override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
           if let player = object as? AVPlayer, player == videoPlayer, keyPath == "status" {
               if player.status == .readyToPlay {
                   videoPlayer?.play()
                   let heightVideo = self.widthDevice * (9/16);
                   let userData: [String: Any] = ["id": "386", "phone": "0143100004"];
                 //khởi tạo view tương tác
                   self.sigmaInteractive = SigmaWebview.init(interactiveLink);
                 //set dữ liệu user
                   self.sigmaInteractive?.setUserValue(value: userData);
                 //set vị trí hiển thị, kích thước của view tương tác và vị trí so với view tương tác, kích thước của view player 
                   self.sigmaInteractive!.setLayout(x: 0, y: 0, width: Int(self.widthDevice), height: Int(self.heightDevice), xPlayer: 0, yPlayer: 0, widthPlayer: Int(self.widthDevice), heightPlayer: Int(heightVideo))
                 // hiển thị view tương tác
                   playerView.addSubview(self.sigmaInteractive!)
                 //set callback để bắt các sự kiện view tương tác gọi
                   self.sigmaInteractive?.setCallBack(sigmaInteractiveCallback: self);
               } else if player.status == .failed {
                   stopBtnPressed(UIButton())
               }
           }
             ...
       }
   ```

   

6. Bắt sự kiện lắng nghe khi id3 trả ra đúng thời điểm hẹn giờ để gửi dữ liệu cho sdk tương tác

   ```swift
   override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
                 ...
           if(keyPath == keyTimedMetadata) {
               let data: AVPlayerItem = object as! AVPlayerItem
               if let timedMetadata = data.timedMetadata {
                   for item in timedMetadata as [AVMetadataItem] {
                       let key: String = item.key! as! String;
                       let value: String = item.value as! String;
                       if(key == keyId3Interactive) {
                           sigmaInteractive?.sendID3Tag(value: value);
                       }
                   }
               }
           }
                 ...
       }
   ```

- #### SigmaWebview

  #### - setUserValue - set dữ liệu user dạng json string
  
  ```swift
  self.sigmaInteractive?.setUserValue(value: userData);
  ```
  

#### - setCallBack - set callback để nhận sự kiện view tương tác gọi

```swift
self.sigmaInteractive?.setCallBack(sigmaInteractiveCallback: self);
```

#### - sendID3TagInstant - gửi id3 instant cho sdk tương tác

#### - sendID3Tag - gửi id3 cho sdk tương tác

#### - setLayout - thay đổi kích thước, vị trí đặt view tương tác và kích thước , vị trí player

```swift
self.sigmaInteractive!.setLayout(x: 0, y: 0, width: Int(self.widthDevice), height: Int(self.heightDevice), xPlayer: 0, yPlayer: 0, widthPlayer: Int(self.widthDevice), heightPlayer: Int(heightVideo))
```

- `x`: Vị trí muốn đặt view tương tác theo trục x.

- `y`: Vị trí muốn đặt view tương tác theo trục y.

- `width`: Chiều rộng của view tương tác.

- `height`: Chiều cao của view tương tác.

- `widthPlayer`: Chiều rộng của player.

- `heightPlayer`: Chiều caocủa player.

- `xPlayer`: Vị trí player theo trục x.

- `yPlayer`: Vị trí player theo trục y.

  ```swift
  ex:
  func goFullscreen() {
          UIView.animate(withDuration: fullScreenAnimationDuration) {
              print("widthDevice=>", self.widthDevice, self.heightDevice)
              let widthVideo = self.widthDevice * (16/9);
              self.layer.frame = CGRect(x: (self.heightDevice - widthVideo) / 2, y: 0, width: widthVideo, height: self.widthDevice)
              self.layer.videoGravity = .resizeAspectFill
              if(self.sigmaInteractive != nil) {
                  self.sigmaInteractive!.setLayout(x: 0, y: 0, width: Int(self.heightDevice), height: Int(self.widthDevice), xPlayer: 0, yPlayer: 0, widthPlayer: Int(self.heightDevice), heightPlayer: Int(self.widthDevice))
              }
          }
      }
  ```

