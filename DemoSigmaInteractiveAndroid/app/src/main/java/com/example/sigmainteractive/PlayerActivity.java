package com.example.sigmainteractive;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.exoplayer2.DefaultRenderersFactory;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.Format;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.analytics.AnalyticsListener;
import com.google.android.exoplayer2.metadata.Metadata;
import com.google.android.exoplayer2.metadata.id3.TextInformationFrame;
import com.google.android.exoplayer2.ui.StyledPlayerView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Calendar;
import java.util.HashMap;
import java.util.Set;

public class PlayerActivity extends Activity implements Player.Listener {
    View containerView;
    public static final String VERSION = "3.0.0";
    private static final String HTML_SDK = "https://dev-livestream.gviet.vn/ilp-statics/[SDK_VERSION]/android-mobile-interactive.html";
    private static String sourcePlay = "https://dev-livestream.gviet.vn/manifest/VTV2-PACKAGE/master.m3u8";
    ExoPlayer player;
    Boolean isPlaying;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_player);
        containerView = this.findViewById(android.R.id.content);
        isPlaying = false;
        DefaultRenderersFactory renderersFactory = new SigmaRendererFactory(getApplicationContext(), new SigmaRendererFactory.Id3ParsedListener() {
            @Override
            public void onId3Parsed(Metadata metadata) {
                if (metadata != null) {
                    for (int i = 0; i < metadata.length(); i++) {
                        Metadata.Entry entry = metadata.get(i);
                        if (entry instanceof TextInformationFrame) {
                            String des = ((TextInformationFrame) entry).description;
                            String value = ((TextInformationFrame) entry).value;
                            Log.d("DesString=>Instance", des);
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
                            Log.d("DesString=>", des);
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
        sourcePlay = getKeyParams(Constant.keyVideoLink);
        setupPlayer();
    }
    public String getKeyParams(String key) {
        Log.d("getKeyParams=>", key);
        Bundle params = getIntent().getExtras();
        if (params != null && params.getString(key).length() > 0) {
            return params.getString(key);
        }
        return "";
    }
    @Override
    public void onIsPlayingChanged(boolean isPlaying) {
        Player.Listener.super.onIsPlayingChanged(isPlaying);
    }

    @Override
    public void onPlayerStateChanged(boolean playWhenReady, int playbackState) {
        Player.Listener.super.onPlayerStateChanged(playWhenReady, playbackState);
        Log.d("onPlayerStateChanged=>", String.valueOf(playbackState));
        if(playbackState == Player.STATE_READY && SigmaInteractiveHelper.getInstance(PlayerActivity.this).interactiveView == null) {
            Log.d("onPlayerStateChanged=>", "ready");
            DisplayMetrics displayMetrics = new DisplayMetrics();
            getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
            int height = displayMetrics.heightPixels;
            int width = displayMetrics.widthPixels;
            StyledPlayerView playerView = (StyledPlayerView) findViewById(R.id.player_view);
            int widthPlayer = playerView.getWidth();
            int heightPlayer = playerView.getHeight();
            this.openInteractiveView(0, 0, width, height, widthPlayer, heightPlayer, 0, 0);
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        setLayoutInteractive(newConfig);
    }
    public void setLayoutInteractive(Configuration newConfig) {
        final View view = findViewById(android.R.id.content);
        ViewTreeObserver observer = view.getViewTreeObserver();
        observer.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                DisplayMetrics displayMetrics = new DisplayMetrics();
                getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
                int height = containerView.getHeight();
                int width = containerView.getWidth();
                StyledPlayerView playerView = (StyledPlayerView) findViewById(R.id.player_view);
                int widthPlayer = playerView.getWidth();
                int heightPlayer = playerView.getHeight();
                if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
                    SigmaInteractiveHelper.getInstance(PlayerActivity.this).setLayoutInteractiveView(0, 0, width, height, widthPlayer, heightPlayer, 0, 0);
                } else {
                    SigmaInteractiveHelper.getInstance(PlayerActivity.this).setLayoutInteractiveView(0, 0, width, height, widthPlayer, heightPlayer, 0, 0);
                }
                view.getViewTreeObserver().removeOnGlobalLayoutListener(this);
            }
        });
    }
    private void setupPlayer(){
        Uri videoUri = Uri.parse(sourcePlay);
        MediaItem mediaItem = MediaItem.fromUri(videoUri);
        // Set the media item to be played.
        player.setMediaItem(mediaItem);
        player.addListener(this);
        // Prepare the player.
        player.prepare();
        // Start the playback.
        player.play();
        player.setPlayWhenReady(true);
        isPlaying = true;
    }
    public String getNewToken() throws JSONException {
        try {
            String userRole = getKeyParams(Constant.keyUserRole);
            String userId = getKeyParams(Constant.keyUserId);
            String dataUserString = getKeyParams(Constant.keyUserData);
            return TokenManager.genToken(userId, userRole, System.currentTimeMillis() + 30*24*60*60*1000, new JSONArray(dataUserString), getApplicationContext());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return "";
    }
    public JSONObject getDataSend(boolean isRefreshToken) {
        JSONObject dataSend = null;
        try {
            dataSend = new JSONObject("{}");
            if(!getKeyParams(Constant.keyUserRole).equals(Constant.roleGuest)) {
                String tokenSend = isRefreshToken ? getNewToken() : TokenManager.getTokenCache(getApplicationContext());
                dataSend.put("token", tokenSend);
            }
            dataSend.put("channelId", getKeyParams(Constant.keyChannelId));
            dataSend.put("overlay", true);
            dataSend.put("panel", true);
        } catch (JSONException err){
            Log.d("Error", err.toString());
        }
        return dataSend;
    }
    private void openInteractiveView(int xInteractiveView, int yInteractiveView, int widthInteractiveView, int heightInteractiveView, int widthPlayer, int heightPlayer, int xPlayer, int yPlayer) {
        if (containerView == null) return;
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
                SigmaWebView interactiveView = SigmaInteractiveHelper.getInstance(PlayerActivity.this).getInteractiveView();
                if (interactiveView != null) {
                    JSONObject dataSend = getDataSend(false);
                    Runnable sendData = new Runnable() {
                        @Override
                        public void run() {
                            SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendOnReadyBack(dataSend);
                        }
                    };
                    Handler mHandler = new Handler();
                    mHandler.post(sendData);
//                    SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendOnReadyBack(dataSend);
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
            //Sự kiện khi hệ thống tương tác yêu cầu gửi lại data
            @Override
            public void fullReload() {
                //get datasend with new token
                JSONObject finalDataSend = getDataSend(true);
                Runnable sendData = new Runnable() {
                    @Override
                    public void run() {
                        SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendOnReadyBack(finalDataSend);
                    }
                };
                Handler mHandler = new Handler();
                mHandler.post(sendData);
            }

            @Override
            public void setSession(String session) {
                Log.d("setSession=>", session);
            }
        };
        SigmaInteractiveHelper.getInstance(PlayerActivity.this).openInteractiveView(xInteractiveView, yInteractiveView, widthInteractiveView, heightInteractiveView, url, sigmaWebviewCallback, widthPlayer, heightPlayer, xPlayer, yPlayer);
    }

    @Override
    protected void onDestroy() {
        Log.d("onPlayerStateChanged=>", "onDestroy");
        SigmaInteractiveHelper.getInstance(PlayerActivity.this).clearInterActiveView();
        player.release();
        isPlaying = false;
        super.onDestroy();
    }

    @Override
    protected void onPause() {
        isPlaying = false;
        super.onPause();
    }
    @Override
    protected void onStop() {
        isPlaying = false;
        super.onStop();
    }

}