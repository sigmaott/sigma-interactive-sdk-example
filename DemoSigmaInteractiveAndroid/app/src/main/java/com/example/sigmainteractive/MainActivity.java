package com.example.sigmainteractive;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.google.android.material.textfield.TextInputEditText;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends AppCompatActivity {
    Button btnOpenPlayer;
    Button btnGetChannel;
    public String channelId = ListChannel.getId("vtv1");
    public String typeFiled = Constant.string;
    public JSONArray dataUser = new JSONArray();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        btnOpenPlayer = findViewById(R.id.openPlayer);
        btnGetChannel = findViewById(R.id.btnGetChannel);
        TextInputEditText txtVideo = findViewById(R.id.txtLinkVideo);
        txtVideo.setText(ListChannel.getSource(ListChannel.vtv1Key));
        checkAndShowBtnOpenWithOldConfig();
    }
    public void checkAndShowBtnOpenWithOldConfig() {
        TextInputEditText txtUid = findViewById(R.id.txtUid);
        String accessTokenCache = SharePreferencesBase.getInstance(getApplicationContext()).getValue(Constant.keyAccessToken);
        String userIdCache = SharePreferencesBase.getInstance(getApplicationContext()).getValue(Constant.keyUserId);
        String userRoleCache = SharePreferencesBase.getInstance(getApplicationContext()).getValue(Constant.keyUserRole);
        if(accessTokenCache != null && userIdCache != null && userRoleCache != null && accessTokenCache.length() > 0 && userIdCache.length() > 0 && userRoleCache.length() > 0) {
            Button btnOpenOldConfig = findViewById(R.id.btnOpenWithOldConfig);
            btnOpenOldConfig.setVisibility(View.VISIBLE);
            txtUid.setText(userIdCache);
            RadioGroup groupRoleUser = findViewById(R.id.groupRoleUser);
            switch (userRoleCache) {
                case Constant.roleAdmin:
                    groupRoleUser.check(R.id.roleAdmin);
                    break;
                case Constant.roleGuest:
                    groupRoleUser.check(R.id.roleGuest);
                    break;
                case Constant.roleUser:
                    groupRoleUser.check(R.id.roleUser);
                    break;
                default:break;
            }
        }
    }
    public void openPlayerActivity(View view) {
        TextInputEditText txtInput = findViewById(R.id.txtInputLink);
        TextInputEditText txtVideo = findViewById(R.id.txtLinkVideo);
        TextInputEditText txtUid = findViewById(R.id.txtUid);
        Log.d("input link", txtInput.getText().toString());
        String inputLinkInteractive = txtInput.getText().toString();
        String inputVideoUrl = txtVideo.getText().toString();
        Intent myIntent = new Intent(MainActivity.this, PlayerActivity.class);
        if (inputLinkInteractive.length() > 0) {
            myIntent.putExtra("interactiveLink", inputLinkInteractive); //Optional parameters
            myIntent.putExtra("videoLink", inputVideoUrl); //Optional parameters
        }
        RadioGroup groupRoleUser = findViewById(R.id.groupRoleUser);
        int idRole  = groupRoleUser.getCheckedRadioButtonId();
        String userRole = Constant.roleUser;
        switch (idRole) {
            case R.id.roleAdmin:
                userRole = Constant.roleAdmin;
                break;
            case R.id.roleGuest:
                userRole = Constant.roleGuest;
                break;
            default:break;
        }
        long exp = System.currentTimeMillis() + 30*24*60*60*1000;
        String token = TokenManager.genToken(String.valueOf(txtUid.getText()), userRole, exp, dataUser, getApplicationContext());
        myIntent.putExtra(Constant.keyUserRole, userRole);
        myIntent.putExtra(Constant.keyUserId, String.valueOf(txtUid.getText()));
        myIntent.putExtra(Constant.keyChannelId, channelId);
        myIntent.putExtra(Constant.keyUserData, dataUser.toString());
        MainActivity.this.startActivity(myIntent);
        checkAndShowBtnOpenWithOldConfig();
    }
    public void openPlayerWithOldConfig(View view) {
        TextInputEditText txtInput = findViewById(R.id.txtInputLink);
        TextInputEditText txtVideo = findViewById(R.id.txtLinkVideo);
        String inputLinkInteractive = txtInput.getText().toString();
        String inputVideoUrl = txtVideo.getText().toString();
        Intent myIntent = new Intent(MainActivity.this, PlayerActivity.class);
        if (inputLinkInteractive.length() > 0) {
            myIntent.putExtra("interactiveLink", inputLinkInteractive); //Optional parameters
            myIntent.putExtra("videoLink", inputVideoUrl); //Optional parameters
            myIntent.putExtra(Constant.keyChannelId, channelId);
            myIntent.putExtra(Constant.keyUserData, SharePreferencesBase.getInstance(getApplicationContext()).getUserData());
            myIntent.putExtra(Constant.keyUserRole, SharePreferencesBase.getInstance(getApplicationContext()).getUserRole());
            myIntent.putExtra(Constant.keyUserId, SharePreferencesBase.getInstance(getApplicationContext()).getUserId());
        }
        MainActivity.this.startActivity(myIntent);
    }
    @SuppressLint("ResourceAsColor")
    public void addFieldDataUser() {
        try {
            int idView = View.generateViewId();
            LinearLayout containerUserData = findViewById(R.id.containerUserData);
            LinearLayout containerUserField = new LinearLayout(this);
            containerUserField.setId(idView);
            containerUserField.setOrientation(LinearLayout.VERTICAL);
            containerUserField.setGravity(Gravity.CENTER_HORIZONTAL);
            //wrap input
            LinearLayout wrapUserField = new LinearLayout(this);
            wrapUserField.setOrientation(LinearLayout.HORIZONTAL);
            //left
            LinearLayout wrapUserFieldLeft = new LinearLayout(this);
            wrapUserFieldLeft.setOrientation(LinearLayout.VERTICAL);
            LinearLayout.LayoutParams paramField = new LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    1.0f
            );
            wrapUserFieldLeft.setLayoutParams(paramField);
            TextView titleLeft = new TextView(this);
            titleLeft.setText("Key");
            TextInputEditText txtInputKey = new TextInputEditText(this);
            txtInputKey.setWidth(ViewGroup.LayoutParams.MATCH_PARENT);
            wrapUserFieldLeft.addView(titleLeft);
            wrapUserFieldLeft.addView(txtInputKey);
            //right
            LinearLayout wrapUserFieldRight = new LinearLayout(this);
            wrapUserFieldRight.setOrientation(LinearLayout.VERTICAL);
            wrapUserFieldRight.setLayoutParams(paramField);
            TextView titleRight = new TextView(this);
            titleRight.setText("Value");
            wrapUserFieldRight.addView(titleRight);
            txtInputKey.addTextChangedListener(new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {

                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                    Log.d("onTextChanged=>", String.valueOf(s));
                    changeFieldUser(idView, Constant.keyField, String.valueOf(s), 0, false, true);
                }

                @Override
                public void afterTextChanged(Editable s) {

                }
            });
            switch (typeFiled) {
                case Constant.bool:
                    RadioGroup listValue = new RadioGroup(this);
                    listValue.setOrientation(LinearLayout.HORIZONTAL);
                    listValue.setLayoutParams(paramField);
                    listValue.setGravity(Gravity.CENTER_HORIZONTAL);
                    RadioButton itemTrue = new RadioButton(this);
                    RadioGroup.LayoutParams paramsItemTrue = new RadioGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                    paramsItemTrue.setMargins(0, 0, 15, 0);
                    itemTrue.setLayoutParams(paramsItemTrue);
                    itemTrue.setText("True");
                    int idItemTrue = View.generateViewId();
                    itemTrue.setId(idItemTrue);
                    itemTrue.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                        @Override
                        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                            Log.d("onCheckedChanged=>true", String.valueOf(isChecked));
//                            changeFieldUser(idView, Constant.valueField, "", 0, true, false);
                        }
                    });
                    //item false
                    RadioButton itemFalse = new RadioButton(this);
                    int idItemFalse = View.generateViewId();
                    itemFalse.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                        @Override
                        public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                            Log.d("onCheckedChanged=>false", String.valueOf(isChecked));
//                            changeFieldUser(idView, Constant.valueField, "", 0, false, false);
                        }
                    });
                    itemFalse.setText("False");
                    itemFalse.setId(idItemFalse);
                    listValue.addView(itemTrue);
                    listValue.addView(itemFalse);
                    listValue.check(idItemTrue);
                    wrapUserFieldRight.addView(listValue);
                    listValue.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
                        @Override
                        public void onCheckedChanged(RadioGroup group, int checkedId) {
                            Log.d("onCheckedChanged=>root", String.valueOf(checkedId));
                            changeFieldUser(idView, Constant.valueField, "", 0, checkedId != idItemFalse, false);
                        }
                    });
                    break;
                case Constant.string:
                case Constant.number:
                    TextInputEditText txtInputValue = new TextInputEditText(this);
                    txtInputValue.setWidth(ViewGroup.LayoutParams.MATCH_PARENT);
                    if(typeFiled.equals(Constant.number)) {
                        txtInputValue.setInputType(InputType.TYPE_CLASS_NUMBER);
                    }
                    txtInputValue.addTextChangedListener(new TextWatcher() {
                        @Override
                        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

                        }

                        @Override
                        public void onTextChanged(CharSequence s, int start, int before, int count) {
                            Log.d("onTextChanged=>", String.valueOf(s));
                            changeFieldUser(idView, Constant.valueField, typeFiled.equals(Constant.string) ? String.valueOf(s) : "", typeFiled.equals(Constant.number) ? Integer.parseInt(String.valueOf(s)) : 0, false, false);
                        }

                        @Override
                        public void afterTextChanged(Editable s) {

                        }
                    });
                    wrapUserFieldRight.addView(txtInputValue);
                    break;
                default:
                    break;
            }
            //button delete
            LinearLayout.LayoutParams paramsButton = new LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
            );
            paramsButton.setMargins(0, 10, 0, 20);
            Button buttonDelete = new Button(this);
            buttonDelete.setText("Delete");
            buttonDelete.setWidth(50);
            buttonDelete.setLayoutParams(paramsButton);
            buttonDelete.setBackgroundColor(getResources().getColor(R.color.red));
            GradientDrawable shape = new GradientDrawable();
            shape.setCornerRadius(8);
            shape.setColor(Color.RED);
            buttonDelete.setBackground(shape);
            buttonDelete.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    try {
                        int indexDelete = 0;
                        for(int i=0; i<dataUser.length(); i++) {
                            JSONObject itemDataUser = dataUser.getJSONObject(i);
                            if(itemDataUser.getInt("id") == idView) {
                                indexDelete = i;
                                break;
                            }
                        }
                        dataUser.remove(indexDelete);
                        removeViewUserData(idView);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            });

            wrapUserField.addView(wrapUserFieldLeft);
            wrapUserField.addView(wrapUserFieldRight);
            containerUserField.addView(wrapUserField);
            containerUserField.addView(buttonDelete);
            containerUserData.addView(containerUserField);
            JSONObject fieldUser = new JSONObject();
            fieldUser.put(Constant.keyField, "");
            fieldUser.put(Constant.valueField, "");
            fieldUser.put(Constant.typeField, typeFiled);
            fieldUser.put(Constant.idField, idView);
            dataUser.put(fieldUser);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    public void changeFieldUser(int id, String key, String valueS, Number valueN, Boolean valueB, Boolean isKey) {
        try {
            int indexChange = -1;
            for(int i=0; i<dataUser.length(); i++) {
                JSONObject itemDataUser = dataUser.getJSONObject(i);
                if(itemDataUser.getInt(Constant.idField) == id) {
                    indexChange = i;
                    break;
                }
            }
            if(indexChange != -1) {
                JSONObject itemChange = dataUser.getJSONObject(indexChange);
                if(isKey) {
                    itemChange.put(Constant.keyField, valueS);
                } else if(itemChange.get(Constant.typeField).equals(Constant.string)) {
                    itemChange.put(key, valueS);
                } else if(itemChange.get(Constant.typeField).equals(Constant.number)) {
                    itemChange.put(key, valueN);
                } else if(itemChange.get(Constant.typeField).equals(Constant.bool)) {
                    itemChange.put(key, valueB);
                }
                dataUser.put(indexChange, itemChange);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    public void removeViewUserData(int id) {
        LinearLayout containerUserData = findViewById(R.id.containerUserData);
        containerUserData.removeView(findViewById(id));
    }
    public void openSelectTypeField(View view) {
        // 1. Instantiate an <code><a href="/reference/android/app/AlertDialog.Builder.html">AlertDialog.Builder</a></code> with its constructor
        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);

// 2. Chain together various setter methods to set the dialog characteristics
        final CharSequence[] items = {Constant.string, Constant.bool, Constant.number};
        builder.setTitle("Select type").setItems(items, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                Log.d("onClick=>", String.valueOf(items[which]));
                typeFiled = String.valueOf(items[which]);
                addFieldDataUser();
            }
        });
// 3. Get the <code><a href="/reference/android/app/AlertDialog.html">AlertDialog</a></code> from <code><a href="/reference/android/app/AlertDialog.Builder.html#create()">create()</a></code>
        AlertDialog dialog = builder.create();
        dialog.show();
    }

    public void openListChannel(View view) {
        // 1. Instantiate an <code><a href="/reference/android/app/AlertDialog.Builder.html">AlertDialog.Builder</a></code> with its constructor
        AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this);

// 2. Chain together various setter methods to set the dialog characteristics
        final CharSequence[] items = {ListChannel.vtv1Key, ListChannel.vtv2Key, ListChannel.vtv3Key, ListChannel.vtv4Key};
        builder.setTitle("Select channel").setItems(items, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                Log.d("onClick=>", String.valueOf(items[which]));
                String source = ListChannel.getSource((String) items[which]);
                channelId = ListChannel.getId((String) items[which]);
                Log.d("source=>", source);
                TextInputEditText txtVideo = findViewById(R.id.txtLinkVideo);
                txtVideo.setText(source);
            }
        });
// 3. Get the <code><a href="/reference/android/app/AlertDialog.html">AlertDialog</a></code> from <code><a href="/reference/android/app/AlertDialog.Builder.html#create()">create()</a></code>
        AlertDialog dialog = builder.create();
        dialog.show();
    }
}
