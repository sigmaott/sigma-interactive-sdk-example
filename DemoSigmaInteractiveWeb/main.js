import './style.css'

// IDS
const ID_VIDEO = "VIDEO"
const ID_CONTAINER = "CONTAINER"

var hls,
  interactiveApp,
  videoElement;
// interactiveElement,

const SOURCE_URL = "https://dev-livestream.gviet.vn/manifest/VTV3-PACKAGE/master.m3u8";

// Khởi tạo tương tác
const initInteractive = async function () {
  interactiveApp = new SigmaInteractive({
    hls: hls,
    userData: {
      'id': '0966888666'
    },
    containerId: ID_CONTAINER,
  })


  interactiveApp.$on('INTERACTIVE_SHOW', () => {
    const containerElement = document.getElementById(ID_CONTAINER)
    containerElement.style['z-index'] = 111;
  });

  interactiveApp.$on('INTERACTIVE_HIDE', () => {
    const containerElement = document.getElementById(ID_CONTAINER)
    containerElement.style['z-index'] = 0;
  });
}

// Khởi tạo hls player
const initPlayer = function () {
  videoElement = document.getElementById(ID_VIDEO);
  if (!Hls || !Hls.isSupported() || !videoElement) return;
  if (hls) {
    hls.destroy();
    hls = undefined;
  }
  hls = new Hls({ enableWorker: true, debug: false });
  hls.attachMedia(videoElement);
  // MEDIA_ATTACHED event is fired by hls object once MediaSource is ready
  hls.on(Hls.Events.MEDIA_ATTACHED, function () {
    hls.loadSource(SOURCE_URL);

    hls.on(Hls.Events.MANIFEST_PARSED, function (event, data) {
      initInteractive();
    });
  });
};


window.onload = function (ev) {
  initPlayer();
};
