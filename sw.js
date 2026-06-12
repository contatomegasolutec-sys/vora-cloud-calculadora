const CACHE_NAME = 'vora-calc-v1';
const ASSETS = [
    './',
    './index.html',
    './gestor.html',
    './empresa.html',
    './manifest.json',
    './icon-192.png',
    './icon-512.png'
];

self.addEventListener('install', (e) => {
    e.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(ASSETS);
        })
    );
});

self.addEventListener('activate', (e) => {
    e.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(
                keys.map((key) => {
                    if (key !== CACHE_NAME) {
                        return caches.delete(key);
                    }
                })
            );
        })
    );
});

self.addEventListener('fetch', (e) => {
    // Only intercept local HTTP/S requests
    if (e.request.url.startsWith(self.location.origin)) {
        e.respondWith(
            caches.match(e.request).then((cachedResponse) => {
                if (cachedResponse) {
                    // Fetch in background to update cache
                    fetch(e.request).then((networkResponse) => {
                        if (networkResponse.status === 200) {
                            caches.open(CACHE_NAME).then((cache) => cache.put(e.request, networkResponse));
                        }
                    }).catch(() => {/* Ignore network errors */});
                    return cachedResponse;
                }
                return fetch(e.request);
            })
        );
    }
});
