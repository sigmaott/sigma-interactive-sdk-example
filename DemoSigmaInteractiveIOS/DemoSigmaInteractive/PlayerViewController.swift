//
//  PlayerViewController.swift
//  DemoSigmaInteractive
//
//  Created by PhamHai on 31/03/2022.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import SigmaInteractiveSDK


let redirectScheme = "cplp";
let customPlaylistScheme = "cplp";
let customKeyScheme = "ckey";
let httpScheme = "http";
let badRequestErrorCode = 400;
let redirectErrorCode = 302;

class PlayerViewController: UIViewController, SigmaJSInterface, AVPlayerItemMetadataOutputPushDelegate, AVAssetResourceLoaderDelegate, AVPlayerItemMetadataCollectorPushDelegate {
    
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector, didCollect metadataGroups: [AVDateRangeMetadataGroup], indexesOfNewGroups: IndexSet, indexesOfModifiedGroups: IndexSet) {
        //
    }
    
    func onReady() {
        print("SigmaJSInterface=>onReady")
    }
    
    func onShowOverlay() {
        print("SigmaJSInterface=>onShowOverlay")
    }
    
    func onHideOverlay() {
        print("SigmaJSInterface=>onHideOverlay")
    }
    
    func onForceFullScreen() {
        print("SigmaJSInterface=>onForceFullScreen")
    }
    
    func onExitFullScreen() {
        print("SigmaJSInterface=>onExitFullScreen")
    }
    
    var interactiveLink: String = "";
    var videoUrl: String = "";
    var fullScreenAnimationDuration: TimeInterval {
        return 0.15
    }
    let widthDevice = UIScreen.main.bounds.width;
    let heightDevice = UIScreen.main.bounds.height;
    let keyId3Interactive = "TXXX";
    let keyTimedMetadata = "timedMetadata";
    let readyForDisplayKeyPath = "readyForDisplay";
    var playerItem: AVPlayerItem?;
    var topSafeArea = 0.0
    var bottomSafeArea = 0.0
    var layer: AVPlayerLayer = AVPlayerLayer();
    private var videoPlayer: AVPlayer?
    
    var sigmaInteractive: SigmaWebview?;
    
    @IBOutlet weak var playerView: UIView!
    
    override func viewDidLoad() {
        print("interactiveLink=>", interactiveLink);
        print("videoUrl=>", videoUrl);
        super.viewDidLoad()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: []);
        startPlayer();
    }
    override func viewWillDisappear(_ animated: Bool) {
        print("Player viewWillDisappear", animated);
        stopBtnPressed(UIButton())
        super.viewWillDisappear(animated);
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        AppUtility.lockOrientation(.portrait)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator);
        if UIDevice.current.orientation.isLandscape {
            if #available(iOS 11.0, *) {
                topSafeArea = view.safeAreaInsets.top
                bottomSafeArea = view.safeAreaInsets.bottom
            } else {
                topSafeArea = topLayoutGuide.length
                bottomSafeArea = bottomLayoutGuide.length
            }
            print("Landscape=>",topSafeArea, bottomSafeArea);
            goFullscreen()
        } else {
            print("Portrait")
            minimizeToFrame()
        }
    }
    func minimizeToFrame() {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            let heightVideo = self.widthDevice * (9/16);
            self.layer.frame = CGRect(x: 0, y: (self.heightDevice - heightVideo)/2, width: self.widthDevice, height: heightVideo)
            self.layer.videoGravity = .resizeAspectFill;
            if(self.sigmaInteractive != nil) {
                self.sigmaInteractive!.setLayout(x: 0, y: 0, width: Int(self.widthDevice), height: Int(self.heightDevice), xPlayer: 0, yPlayer: 0, widthPlayer: Int(self.widthDevice), heightPlayer: Int(heightVideo))
            }
        }
    }

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
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer, player == videoPlayer, keyPath == "status" {
            if player.status == .readyToPlay {
                videoPlayer?.play()
                let heightVideo = self.widthDevice * (9/16);
                let userData: [String: Any] = ["id": "386", "phone": "0143100004"];
                self.sigmaInteractive = SigmaWebview.init(interactiveLink);
                self.sigmaInteractive?.setUserValue(value: userData);
                self.sigmaInteractive!.setLayout(x: 0, y: 0, width: Int(self.widthDevice), height: Int(self.heightDevice), xPlayer: 0, yPlayer: 0, widthPlayer: Int(self.widthDevice), heightPlayer: Int(heightVideo))
                playerView.addSubview(self.sigmaInteractive!)
                self.sigmaInteractive?.setCallBack(sigmaInteractiveCallback: self);
            } else if player.status == .failed {
                stopBtnPressed(UIButton())
            }
        }
        if(keyPath == keyTimedMetadata) {
            let data: AVPlayerItem = object as! AVPlayerItem
            if let timedMetadata = data.timedMetadata {
                for item in timedMetadata as [AVMetadataItem] {
                    let key: String = item.key! as! String;
                    let value: String = item.value as! String;
                    print("metadataObserver=>id:", key);
                    if(key == keyId3Interactive) {
                        sigmaInteractive?.sendID3Tag(value: value);
                    }
                }
            }
        }
    }
    
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        let items = groups.first?.items;
        for item in items! {
            let value: String = item.value as! String;
            let key: String = item.key! as! String;
            print("metadataOutput=>id:", key);
            if(key == keyId3Interactive) {
                sigmaInteractive?.sendID3TagInstant(value: value);
            }
        }
    }
    
    private func assetWithUrl(url source: URL) -> AVURLAsset
    {
        let replaceUrl = source.absoluteString.replacingOccurrences(of: httpScheme, with: customPlaylistScheme);
        
        let asset = AVURLAsset(url: URL(string: replaceUrl)!, options: nil);
        let resourceLoader = asset.resourceLoader;
        resourceLoader.setDelegate(self, queue: DispatchQueue.main);
        return asset;
    }
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        print("resourceLoader=>", loadingRequest.request.url?.absoluteString);
        if(isRedirectRequest(loadingRequest.request.url!.absoluteString)) {
            return handleRedirectRequest(loadingRequest);
        }
        if((loadingRequest.request.url?.scheme?.starts(with: customPlaylistScheme)) != nil) {
            handleCustomPlaylistRequest(loadingRequest);
            return true;
        }
        return false;
    }
    func generateRedirectURL(_ url: URLRequest) -> URLRequest
    {
        let redirect = URLRequest(url: URL(string: url.url!.absoluteString.replacingOccurrences(of: redirectScheme, with: httpScheme))!);
        return redirect;
    }
    func handleRedirectRequest(_ loadingRequest: AVAssetResourceLoadingRequest) -> Bool
    {
        let api = loadingRequest.request;
        let redirect = generateRedirectURL(api);
        loadingRequest.redirect = redirect;
        let response = HTTPURLResponse(url: redirect.url!, statusCode: redirectErrorCode, httpVersion: nil, headerFields: nil);
        loadingRequest.response = response;
        loadingRequest.finishLoading();
        return true;
    }
    func getDataPlaylist(_ url: URL) -> NSData
    {
        let newURL = url.absoluteString.replacingOccurrences(of: customPlaylistScheme, with: httpScheme);
        let dataReturn = NSData(contentsOf: URL(string: newURL)!);
        return dataReturn!;
    }
    func handleCustomPlaylistRequest(_ loadingRequest: AVAssetResourceLoadingRequest) {
        let data = getDataPlaylist(loadingRequest.request.url!);
        loadingRequest.dataRequest?.respond(with: data as Data);
        loadingRequest.finishLoading();
    }
    func isRedirectRequest(_ url: String) -> Bool
    {
        return (url.range(of: ".ts") != nil);
    }
    private func startPlayer() {
        if let url = URL(string: videoUrl) {
            let asset = AVURLAsset(url: url, options: nil);
            playerItem = AVPlayerItem(asset: asset)
            videoPlayer = AVPlayer(playerItem: playerItem)
            videoPlayer?.addObserver(self, forKeyPath: "status", options: [], context: nil)
            // listen the current time of playing video
            videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: Double(1), preferredTimescale: 2), queue: DispatchQueue.main) { [weak self] (sec) in
                guard let self = self else { return }
                let seconds = CMTimeGetSeconds(sec)
            }
            videoPlayer?.volume = 1.0
            
            layer = AVPlayerLayer(player: videoPlayer);
            layer.backgroundColor = UIColor.white.cgColor
            let heightVideo = widthDevice * (9/16);
            layer.frame = CGRect(x: 0, y: (self.heightDevice - heightVideo)/2, width: widthDevice, height: heightVideo)
            layer.videoGravity = .resizeAspectFill
            playerView.layer.sublayers?
                .filter { $0 is AVPlayerLayer }
                .forEach { $0.removeFromSuperlayer() }
            playerView.layer.addSublayer(layer)
            let metadataOutput = AVPlayerItemMetadataOutput();
            metadataOutput.advanceIntervalForDelegateInvocation = TimeInterval(Int.max);
            metadataOutput.setDelegate(self, queue: DispatchQueue.main);
            playerItem!.add(metadataOutput);
            playerItem?.addObserver(self, forKeyPath: keyTimedMetadata, options: [], context: nil)
        }
    }
    
    func stopBtnPressed(_ sender: Any) {
        videoPlayer?.pause()
        videoPlayer = nil
        playerView.layer.sublayers?
            .filter { $0 is AVPlayerLayer }
            .forEach { $0.removeFromSuperlayer() }
        playerView.backgroundColor = .black
        self.title = ""
    }
}
