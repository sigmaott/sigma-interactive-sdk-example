// Định nghĩa id, classname của 1 số element...
const ID_VIDEO = "video-player",
  ID_BUTTON_VIDEO = "btn-video",
  ID_BUTTON_PLAY = "btn-play",
  ID_BUTTON_PAUSE = "btn-pause",
  ID_CONTAINER_INTERACTIVE = "container-interactive",
  ID_CONTAINER_CONTROL = "container-control",
  ID_CONTROL_PROGRESS = "progress-amount",
  ID_CONTROL_TOTAL_TIME = "total-time",
  ID_CONTROL_CURRENT_TIME = "current-time";
const CLASSNAME_ACTIVE = "is-active",
  CLASSNAME_SHOW = "show";
//
var player,
  interactiveSdk,
  videoElement,
  interactiveElement,
  durationTime = 0,
  currentTime = 0;

var trapFocusVideo, trapFocusPlay, trapFocusPause;

const SOURCE_URL =
  // "http://live.quangkv.com/cabon/playlist.m3u8";
  "https://dev-livestream.gviet.vn/manifest/VTV1-PACKAGE/master.m3u8";

// Bắt đầu xử lý Interactive
// Khởi tạo SigmaInteractive
const initInteractive = function () {
  clearInteractive();
  if (!SigmaInteractive || !player) return;
  interactiveSdk = SigmaInteractive.createInteractiveApp({
    hls: player,
    userData: {},
    containerId: ID_CONTAINER_INTERACTIVE,
    iframeSrc:
      "https://dev-livestream.gviet.vn/ilp-statics/2.0.0/webos-interactive.html",
  });
  interactiveSdk.$on("INTERACTIVE_SHOW", function () {
    onShowInteractive();
  });
  interactiveSdk.$on("INTERACTIVE_HIDE", function () {
    onHideInteractive();
  });
  interactiveSdk.$on("INTERACTIVE_FOCUS", function () {
    onFocusInteractive();
  });
  interactiveSdk.$on("INTERACTIVE_UNFOCUS", function () {
    onUnfocusInteractive();
  });
  interactiveSdk.$on("INTERACTIVE_CONNECTION_ERROR", function () {
    onUnfocusInteractive();
    onHideInteractive();
  });
  interactiveSdk.$on("ON_KEY_DOWN", function (data) {
    // Xử lý sự kiện bấm phím theo tên
    const key = data.detail;
    console.log("ON_KEY_DOWN:", key);
    switch (key) {
      case "backspace":
        // Xử lý khi bấm back
        break;
      default:
        break;
    }
  });
};

const clearInteractive = function () {
  if (interactiveSdk) {
    interactiveSdk.$destroy();
    interactiveSdk = undefined;
  }
};

const onShowInteractive = function () {
  const containerInteractive = document.getElementById(
    ID_CONTAINER_INTERACTIVE
  );
  containerInteractive.classList.add(CLASSNAME_SHOW);
};

const onHideInteractive = function () {
  const containerInteractive = document.getElementById(
    ID_CONTAINER_INTERACTIVE
  );
  containerInteractive.classList.remove(CLASSNAME_SHOW);
};

const onFocusInteractive = function () {
  trapFocusVideo.deactivate();
  trapFocusPlay.deactivate();
  trapFocusPause.deactivate();
  hideControl();
};

const onUnfocusInteractive = function () {
  trapFocusPlay.deactivate();
  trapFocusPause.deactivate();
  trapFocusVideo.activate();
};

const showControl = function () {
  const controlElement = document.getElementById(ID_CONTAINER_CONTROL);
  controlElement.classList.add(CLASSNAME_SHOW);
};

const hideControl = function () {
  const controlElement = document.getElementById(ID_CONTAINER_CONTROL);
  controlElement.classList.remove(CLASSNAME_SHOW);
};
// Kết thúc xử lý Interactive

// Khởi tạo player
const initPlayer = function () {
  videoElement = document.getElementById(ID_VIDEO);
  if (!Hls || !Hls.isSupported() || !videoElement) return;
  if (player) {
    player.destroy();
    player = undefined;
  }
  player = new Hls({ enableWorker: true, debug: false });
  player.attachMedia(videoElement);
  player.on(Hls.Events.MEDIA_ATTACHED, function () {
    player.loadSource(SOURCE_URL);
    initInteractive();
  });

  videoElement.addEventListener("durationchange", function (e) {
    durationTime = videoElement.duration;
    document.getElementById(ID_CONTROL_TOTAL_TIME).innerHTML =
      TVUtil.formatTime(~~durationTime);
  });

  videoElement.addEventListener("timeupdate", function (e) {
    currentTime = videoElement.currentTime;
    if (durationTime <= 0) return;
    const percent = ~~((currentTime * 100) / durationTime);
    document.getElementById(ID_CONTROL_CURRENT_TIME).innerHTML =
      TVUtil.formatTime(~~currentTime);
    document.getElementById(ID_CONTROL_PROGRESS).style.width = percent + "%";
  });
};

// Khởi tạo 1 số UI control trong demo
const initFocusable = function () {
  const playVideo = document.getElementById(ID_BUTTON_VIDEO);
  trapFocusVideo = focusTrap.createFocusTrap(`#${ID_BUTTON_VIDEO}`, {
    onActivate: function () {
      playBtn.classList.add(CLASSNAME_ACTIVE);
      hideControl();
    },
    onDeactivate: function () {
      playBtn.classList.remove(CLASSNAME_ACTIVE);
    },
  });
  const playBtn = document.getElementById(ID_BUTTON_PLAY);
  trapFocusPlay = focusTrap.createFocusTrap(`#${ID_BUTTON_PLAY}`, {
    onActivate: function () {
      playBtn.classList.add(CLASSNAME_ACTIVE);
      showControl();
    },
    onDeactivate: function () {
      playBtn.classList.remove(CLASSNAME_ACTIVE);
    },
  });
  const pauseBtn = document.getElementById(ID_BUTTON_PAUSE);
  trapFocusPause = focusTrap.createFocusTrap(`#${ID_BUTTON_PAUSE}`, {
    onActivate: function () {
      pauseBtn.classList.add(CLASSNAME_ACTIVE);
      showControl();
    },
    onDeactivate: function () {
      pauseBtn.classList.remove(CLASSNAME_ACTIVE);
    },
  });
  trapFocusVideo.activate();
  playVideo.addEventListener("keydown", function (e) {
    switch (e.keyCode) {
      case TVKeyEvent.LEFT:
      case TVKeyEvent.RIGHT:
      case TVKeyEvent.UP:
      case TVKeyEvent.DOWN:
      case TVKeyEvent.ENTER:
        trapFocusVideo.deactivate();
        trapFocusPlay.activate();
        break;
    }
  });
  playBtn.addEventListener("keydown", function (e) {
    switch (e.keyCode) {
      case TVKeyEvent.RIGHT:
        trapFocusPlay.deactivate();
        trapFocusPause.activate();
        break;
      case TVKeyEvent.ENTER:
        videoElement.play();
        break;
      case TVKeyEvent.BACK:
      case TVKeyEvent.BACKTV:
      case TVKeyEvent.RETURN:
        trapFocusPlay.deactivate();
        trapFocusVideo.activate();
        break;
    }
  });
  pauseBtn.addEventListener("keydown", function (e) {
    switch (e.keyCode) {
      case TVKeyEvent.LEFT:
        trapFocusPause.deactivate();
        trapFocusPlay.activate();
        break;
      case TVKeyEvent.ENTER:
        videoElement.pause();
        break;
      case TVKeyEvent.BACK:
      case TVKeyEvent.BACKTV:
      case TVKeyEvent.RETURN:
        trapFocusPause.deactivate();
        trapFocusVideo.activate();
    }
  });
};

window.onload = function (ev) {
  TVUtil.scaleFont();
  initFocusable();
  initPlayer();
};

window.addEventListener("resize", function () {
  TVUtil.scaleFont();
});
