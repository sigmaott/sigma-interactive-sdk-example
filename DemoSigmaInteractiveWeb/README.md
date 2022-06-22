
# Introduction

The Sigma Interactive Demo for Web platform, which support latest HLS.js player. The demo use SDK version 2.0.0

# Installation

### 1. Add sdk script tag to your document head:
```html
  <script src="https://resource-ott.gviet.vn/sdk/2.0.0/sigma-interactive-js.js"></script>
```

### 2. Create interactive container element

Next, provide a container to display interactive app. Usually, we should make the container to match the video player's size.

```html
<div class="relative aspect-ratio-16/9 outline outline-purple-400">
  <video id="VIDEO" class="h-full w-full" autoplay muted />
  <div
    id="CONTAINER"
    class="h-full w-full inset-0 absolute"
  />
</div>
```

### 3. Initialize app:

The interactive app should be initiated on the HLS **MANIFEST_PARSED** event.
```js
 hls.on(Hls.Events.MEDIA_ATTACHED, function () {
    hls.loadSource(SOURCE_URL);

    hls.on(Hls.Events.MANIFEST_PARSED, function (event, data) {
      initInteractive();
    });
  });
```


```js
  const config = {
    hls: hls,
    userData: {
      'id': 'user-id'
    },
    containerId: ID_CONTAINER,
  }
  interactiveApp = new SigmaInteractive(config)
```

Alternative way, you can call interactive app singleton via `SigmaInteractive.getInstance()`

```js
interactiveApp= SigmaInteractive.getInstance(config)
```

### Configs:
- hls - **HLS**: the hls instance which attach to video player
```js
  hls = new Hls();
```
- userData - **object**: user information, that contain at least **id**: string
```js
  userData = {
    id: 'user-id-123',
    phone: '0966540957'
  }
```

- containerId - **string**: the id of container element, which use to draw interactive app


### 4. Listen on Interactive Events

```js
  interactiveApp.$on('INTERACTIVE_SHOW', () => {
    const containerElement = document.getElementById(ID_CONTAINER)
    containerElement.style['z-index'] = 111;
  });

  interactiveApp.$on('INTERACTIVE_HIDE', () => {
    const containerElement = document.getElementById(ID_CONTAINER)
    containerElement.style['z-index'] = 0;
  });

  interactiveApp.$on('INTERACTIVE_RECEIVE', () => {
    console.log('[LOG] ~ INTERACTIVE_RECEIVE')
  })

```


### 5. Destroy app
```js
  interactiveApp.$destroy()
  // or
  SigmaInteractive.clear()
```

Finally, Go to the Interactive CMS and publish an overlay

# Preview Demo

## 1. Install packages
```sh
npm install
```

## 2. Start Demo
```sh
npm run dev
```
