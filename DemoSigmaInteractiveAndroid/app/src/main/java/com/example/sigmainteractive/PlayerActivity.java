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

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Set;

public class PlayerActivity extends Activity implements Player.Listener {
    View containerView;
    //  private static boolean DEBUG = false;
    int estimatedKeyboardHeight = 0;
    final String demoToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjA5NzI5NTIyNzIiLCJleHAiOjE2NTQ2NzMzNzQsInJvbGUiOiJ1c2VyIiwiYXBwSWQiOiJkZWZhdWx0LWFwcCIsInVzZXJEYXRhIjp7fX0.-WuVJ5C84j1NOYF1CHYXJr-ZB6hj3uAhyqb_7Ox7hwY";
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
        //
        setContentView(R.layout.activity_player);
        containerView = this.findViewById(android.R.id.content);
//        setKeyboardVisibilityListener(this);
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
        Bundle params = getIntent().getExtras();
        if (params != null && params.getString("videoLink").length() > 0) {
            sourcePlay = params.getString("videoLink");
        }
        setupPlayer();
    }

    @Override
    public void onIsPlayingChanged(boolean isPlaying) {
        Player.Listener.super.onIsPlayingChanged(isPlaying);
    }

    @Override
    public void onPlayerStateChanged(boolean playWhenReady, int playbackState) {
        Player.Listener.super.onPlayerStateChanged(playWhenReady, playbackState);
        if(playbackState == Player.STATE_READY) {
            Log.d("onPlayerStateChanged=>", "ready");
            DisplayMetrics displayMetrics = new DisplayMetrics();
            getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
            int height = displayMetrics.heightPixels;
            int width = displayMetrics.widthPixels;
            StyledPlayerView playerView = (StyledPlayerView) findViewById(R.id.player_view);
            int widthPlayer = playerView.getWidth();
            int heightPlayer = playerView.getHeight();
            this.openInteractiveView(0, 0, width, height, widthPlayer, heightPlayer, 0, 0, null);
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        SigmaInteractiveHelper.getInstance(PlayerActivity.this).hideInterActiveView();
        super.onConfigurationChanged(newConfig);
        setLayoutInteractive(newConfig);
    }
    public void setLayoutInteractive(Configuration newConfig) {
        final View view = findViewById(android.R.id.content);
        ViewTreeObserver observer = view.getViewTreeObserver();
        observer.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                Log.d("onGlobalLayout",
                        String.format("new width=%d; new height=%d", view.getWidth(),
                                view.getHeight()));
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
                SigmaInteractiveHelper.getInstance(PlayerActivity.this).showInterActiveView();
                view.getViewTreeObserver().removeOnGlobalLayoutListener(this);
            }
        });
//        Handler mHandler = new Handler();
//        Runnable runnableSetLayout = new Runnable() {
//            @Override
//            public void run() {
//            }
//        };
//        mHandler.postDelayed(runnableSetLayout, 100);
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
        isPlaying = true;
    }
    public String getNewToken() {
        return demoToken;
    }
    public JSONObject getDataSend(boolean isRefreshToken) {
        JSONObject dataSend = null;
        try {
            dataSend = new JSONObject("{}");
            if(!isRefreshToken) {
                dataSend.put("token", demoToken);
            } else {
                dataSend.put("token", getNewToken());
            }
            dataSend.put("channelId", "c9c2ebfb-2887-4de6-aec4-0a30aa848915");
            dataSend.put("overlay", true);
            dataSend.put("panel", true);
        } catch (JSONException err){
            Log.d("Error", err.toString());
        }
        return dataSend;
    }
    private void openInteractiveView(int xInteractiveView, int yInteractiveView, int widthInteractiveView, int heightInteractiveView, int widthPlayer, int heightPlayer, int xPlayer, int yPlayer, Bundle userData) {
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
                Log.d("onReady=>", userDataSend.toString());
                if (interactiveView != null) {
                    JSONObject dataSend = getDataSend(false);
                    Runnable sendData = new Runnable() {
                        @Override
                        public void run() {
                            SigmaInteractiveHelper.getInstance(PlayerActivity.this).sendOnReadyBack(dataSend);
                        }
                    };
                    Handler mHandler = new Handler();
                    mHandler.postDelayed(sendData, 1000);
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
                mHandler.postDelayed(sendData, 0);
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
        // simpleExoPlayer.setPlayWhenReady(false);
        player.release();
        isPlaying = false;
        super.onPause();
    }
}