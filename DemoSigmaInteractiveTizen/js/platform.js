function userAgentContains_(key) {
  const userAgent = window.navigator.userAgent || "";
  return userAgent.includes(key);
}

function getRealWidth() {
  return window.innerWidth;
}

function getRealHeight() {
  return window.innerHeight;
}

(function () {
  var TVPlatform = {
    isToshiba: function () {
      return userAgentContains_("Toshiba") || userAgentContains_("TSBNetTV");
    },
    isSony: function () {
      return userAgentContains_("Sony"); //CEBrowser
    },
    isWebOS: function () {
      return userAgentContains_("Web0S");
    },
    isEdge: function () {
      return userAgentContains_("Edge/");
    },
    isIE: function () {
      return userAgentContains_("Trident/");
    },
    isTizen: function () {
      return userAgentContains_("Tizen");
    },
    isVideoFutur: function () {
      return userAgentContains_("VITIS");
    },
    isTiVo: function () {
      return userAgentContains_("TiVo");
    },
    isChromecast: function () {
      return userAgentContains_("CrKey");
    },
    isChrome: function () {
      return userAgentContains_("Chrome") && !TVPlatform.isEdge();
    },
    isApple: function () {
      return (
        !!navigator.vendor &&
        navigator.vendor.includes("Apple") &&
        !TVPlatform.isTizen()
      );
    },
  };

  var scaleFont = function () {
    const RATIO_BASE = 1280 / 720;
    const RATIO = getRealWidth() / getRealHeight();
    const SCALE_RATIO =
      RATIO < RATIO_BASE
        ? (getRealWidth() * 100) / 1280
        : (getRealHeight() * 100) / 720;
    document
      .getElementsByTagName("html")[0]
      .setAttribute("style", `font-size: ${SCALE_RATIO}%;`);
    console.log(`ScaleRatio: ${~~SCALE_RATIO}%`);
  };

  var formatTime = function (seconds) {
    var hh = Math.floor(seconds / 3600),
      mm = Math.floor(seconds / 60) % 60,
      ss = Math.floor(seconds) % 60;

    return (
      (hh ? (hh < 10 ? "0" : "") + hh + ":" : "") +
      (mm < 10 ? "0" : "") +
      mm +
      ":" +
      (ss < 10 ? "0" : "") +
      ss
    );
  };
  var TVUtil = {
    formatTime: formatTime,
    scaleFont: scaleFont,
  };
  window.TVPlatform = TVPlatform;
  window.TVUtil = TVUtil;
})();
