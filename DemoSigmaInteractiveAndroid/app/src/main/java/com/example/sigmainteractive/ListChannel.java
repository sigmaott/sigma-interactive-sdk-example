package com.example.sigmainteractive;

public class ListChannel {
    static final String baseUrlChannel = "https://dev-livestream.gviet.vn/manifest/";
    static final String vtv1Key = "vtv1";
    static final String vtv2Key = "vtv2";
    static final String vtv3Key = "vtv3";
    static final String vtv4Key = "vtv4";
    static public String getSource(String channelId) {
        switch (channelId) {
            case vtv1Key:
                return baseUrlChannel + "VTV1-PACKAGE/master.m3u8";
            case vtv2Key:
                return baseUrlChannel + "VTV2-PACKAGE/master.m3u8";
            case vtv3Key:
                return baseUrlChannel + "VTV3-PACKAGE/master.m3u8";
            case vtv4Key:
                return baseUrlChannel + "VTV4/master.m3u8";
            default: return "";
        }
    }
    static public String getId(String channelKey) {
        switch (channelKey) {
            case vtv1Key:
                return "c9c2ebfb-2887-4de6-aec4-0a30aa848915";
            case vtv2Key:
                return "32a55ed3-4ee1-42f8-819a-407b54a39923";
            case vtv3Key:
                return "60346597-8ed9-48de-bd4d-8546d0070c7c";
            case vtv4Key:
                return "22e1fdb6-8d10-4193-8411-562c7104aa2b";
            default: return "c9c2ebfb-2887-4de6-aec4-0a30aa848915";
        }
    }
}
