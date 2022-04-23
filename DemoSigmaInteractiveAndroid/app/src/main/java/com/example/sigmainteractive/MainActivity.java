package com.example.sigmainteractive;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import com.google.android.material.textfield.TextInputEditText;

public class MainActivity extends AppCompatActivity {
    Button btnOpenPlayer;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        btnOpenPlayer = findViewById(R.id.openPlayer);
    }

    public void openPlayerActivity(View view) {
        TextInputEditText txtInput = findViewById(R.id.txtInputLink);
        TextInputEditText txtVideo = findViewById(R.id.txtLinkVideo);
        Log.d("input link", txtInput.getText().toString());
        String inputLinkInteractive = txtInput.getText().toString();
        String inputVideoUrl = txtVideo.getText().toString();
        Intent myIntent = new Intent(MainActivity.this, PlayerActivity.class);
        if(inputLinkInteractive.length() > 0) {
            myIntent.putExtra("interactiveLink", inputLinkInteractive); //Optional parameters
            myIntent.putExtra("videoLink", inputVideoUrl); //Optional parameters
        }
        MainActivity.this.startActivity(myIntent);
    }
}
