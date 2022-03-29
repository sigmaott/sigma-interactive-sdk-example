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
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.exoplayer2.DefaultRenderersFactory;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.Format;
import com.google.android.exoplayer2.MediaItem;
import com.google.android.exoplayer2.analytics.AnalyticsListener;
import com.google.android.exoplayer2.metadata.Metadata;
import com.google.android.exoplayer2.metadata.id3.TextInformationFrame;
import com.google.android.exoplayer2.ui.StyledPlayerView;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Set;

public class PlayerActivity extends Activity {
    private static boolean DEBUG = false;
    private static boolean DEBUG_URL = true;
    View containerView;
    //  private static boolean DEBUG = false;
    public static final String VERSION = "2.0.0";
    private static final String HTML_SDK = DEBUG_URL ? "https://dev-livestream.gviet.vn/ilp-statics/[SDK_VERSION]/android-mobile-interactive.html" : "https://resource-ott.gviet.vn/sdk/[SDK_VERSION]/android-mobile-interactive.html";
    private static final String sourcePlay = "https://dev-livestream.gviet.vn/manifest/VTV2-PACKAGE/master.m3u8";
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
                                if (SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).getInteractiveView() != null) {
                                    SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).sendID3InstantInteractive(value);
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
                                if (SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).getInteractiveView() != null) {
                                    SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).sendID3Interactive(value);
                                }
                            }
                        }
                    }
                }
            }
        });
        StyledPlayerView playerView = (StyledPlayerView) findViewById(R.id.player_view);
        playerView.setPlayer(player);
        setupPlayer();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        Log.d("onConfigurationChanged", String.valueOf(newConfig.orientation));
        super.onConfigurationChanged(newConfig);
        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).setLayoutInteractiveView(0, 0, containerView.getLayoutParams().width, containerView.getLayoutParams().height, containerView.getLayoutParams().width, containerView.getLayoutParams().height, 0, 0);
        } else {
            SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).setLayoutInteractiveView(0, 0, containerView.getLayoutParams().width, containerView.getLayoutParams().height, containerView.getLayoutParams().width, containerView.getLayoutParams().height, 0, 0);
        }
    }

    private void setupPlayer() {
        Uri videoUri = Uri.parse(sourcePlay);
        MediaItem mediaItem = MediaItem.fromUri(videoUri);
        // Set the media item to be played.
        player.setMediaItem(mediaItem);
        // Prepare the player.
        player.prepare();
        // Start the playback.
        player.play();
        isPlaying = true;
        DisplayMetrics displayMetrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);
        int height = displayMetrics.heightPixels;
        int width = displayMetrics.widthPixels;
        this.openInteractiveView(0, 0, width, height, width, height, 0, 0, null);
    }

    private void openInteractiveView(int xInteractiveView, int yInteractiveView, int widthInteractiveView, int heightInteractiveView, int widthPlayer, int heightPlayer, int xPlayer, int yPlayer, Bundle userData) {
        if (containerView == null) return;
        Bundle params = getIntent().getExtras();
        String interactiveLink = ""; // or other values
        if (params != null) {
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
                SigmaWebView interactiveView = SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).getInteractiveView();
                Log.d("onReady=>", userDataSend.toString());
                if (interactiveView != null) {
                    if (xInteractiveView != 0 || yInteractiveView != 0 || widthInteractiveView != FrameLayout.LayoutParams.MATCH_PARENT || heightInteractiveView != FrameLayout.LayoutParams.MATCH_PARENT) {
                        SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).setLayoutInteractiveView(xInteractiveView, yInteractiveView, widthInteractiveView, heightInteractiveView, widthPlayer, heightPlayer, xPlayer, yPlayer);
                    }
                    interactiveView.sendOnReadyBack(userData != null ? userDataSend.toString() : "{}");
                    double leftP = (double) xPlayer / widthInteractiveView, rightP = (double) (widthPlayer + xPlayer) / widthInteractiveView, topP = (double) yPlayer / heightInteractiveView, bottomP = (double) (yPlayer + heightPlayer) / heightInteractiveView;
                    interactiveView.sendRectPlayer(leftP, rightP, bottomP, topP);
                    interactiveView.requestFocus();
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
        SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).openInteractiveViewWithCallback(widthInteractiveView, heightInteractiveView, url, sigmaWebviewCallback);
    }

    @Override
    protected void onDestroy() {
        player.release();
        isPlaying = false;
        SigmaInteractiveHelper.getInstance(containerView, PlayerActivity.this).clearInterActiveView();
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