# Participant Class

## using Participant Class

The `Participant Class` includes methods and events for participants and their associated audio and video streams, data channels and UI customisation.

### Properties

| name        | type                |
| ----------- | ------------------- |
| id          | String              |
| displayName | String              |
| streams     | Map<String, Stream> |
| renderer    | RTCVideoRenderer?   |

### Events

| name            | type   |
| --------------- | ------ |
| stream-enabled  | Stream |
| stream-disabled | Stream |

## Example

```js title="Play with Participant instance"
// get displayName
participant.displayName;

// Adding event listners in participant
participant.on("stream-enabled", (Stream stream) {
  // this stream is enabled
});

participant.on("stream-disabled", (Stream stream) {
  // this stream is disabled
});
```

---

# Next step

[Stream Class](stream-class.md)

# Complete API References

- [Setup](setup.md)
- [Meeting Builder Widget](meeting-builder-widget.md)
- [Meeting Class](meeting-class.md)
- [Participant Class](participant-class.md)
- [Stream Class](stream-class.md)
