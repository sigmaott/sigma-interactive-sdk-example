package com.example.sigmainteractive;

import android.content.Context;
import android.content.SharedPreferences;

public class SharePreferencesBase {
    private static SharePreferencesBase INSTANCE = null;
    public static SharedPreferences mSharedPreferences = null;
    public static String userId = "";
    public static String userRole = "";
    public static String userData = "";
    public static String accessToken = "";

    public static SharePreferencesBase getInstance(Context context) {
        if (INSTANCE == null) {
            INSTANCE = new SharePreferencesBase(context);
        }
        return INSTANCE;
    }

    public String getUserId() {
        return getValue(Constant.keyUserId);
    }

    public String getUserRole() {
        return getValue(Constant.keyUserRole);
    }

    public String getUserData() {
        return getValue(Constant.keyUserData);
    }

    public String getAccessToken() {
        return getValue(Constant.keyAccessToken);
    }

    public SharePreferencesBase(Context context) {
        mSharedPreferences = context.getSharedPreferences(Constant.keySharePreferences, Context.MODE_PRIVATE);
        userId = this.getValue(Constant.keyUserId);
        accessToken = this.getValue(Constant.keyAccessToken);
        userRole = this.getValue(Constant.keyUserRole);
        userData = this.getValue(Constant.keyUserData);
    }

    public String getValue(String name) {
        return mSharedPreferences.getString(name, null);
    }

    public void setValue(String name, String value) {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.putString(name, value).apply();
    }
    public void deleteKey(String key) {
        SharedPreferences.Editor editor = mSharedPreferences.edit();
        editor.remove(key).apply();
    }

}
