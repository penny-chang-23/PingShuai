const CACHE = "pingshuai-v2";
const FILES = ["./", "index.html", "manifest.webmanifest"];

self.addEventListener("install", e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)));
});
self.addEventListener("activate", e => e.waitUntil(
  caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k))))));
// 網路優先，離線時用快取；音檔（Range 請求）交給瀏覽器處理
self.addEventListener("fetch", e => {
  if (e.request.url.endsWith(".mp4") || e.request.headers.has("range")) return;
  e.respondWith(fetch(e.request).catch(() => caches.match(e.request)));
});
