# Stream Class

## using Stream Class

The `Stream Class` includes methods and events audio and video streams.

### Properties

| name     | type             | description               |
| -------- | ---------------- | ------------------------- |
| id       | String           | -                         |
| track    | Consumer         | `video or audio or share` |
| kind     | String           | -                         |
| renderer | RTCVideoRenderer | -                         |

### Methods

| name     | type |
| -------- | ---- |
| pause()  | void |
| resume() | void |

## Example

```js title="Play with Stream instance"
// pause stream
stream?.pause();

// resume stream
stream?.resume();
```
