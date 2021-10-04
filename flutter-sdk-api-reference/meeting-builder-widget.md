# Meeting Builder Widget

The entry point into real-time communication SDK.

## Using Meeting Builder Widget

The `Meeting Builder Widget` includes methods and events to initialize and configure the SDK. It is a factory class.

### Properties

| name          | type                     |
| ------------- | ------------------------ |
| meetingId     | String                   |
| displayName   | String                   |
| token         | String                   |
| micEnabled    | Bool                     |
| webcamEnabled | Bool                     |
| builder       | Widget Function(Meeting) |

## Example

```js title="Configure MeetingBuilder Example"
MeetingBuilder(
  meetingId: "<meeting-id>",
  displayName: "Chintan",
  token: "<token>",
  micEnabled: true,
  webcamEnabled: true,
  builder: (Meeting meeting) {
    return Text("Meeting screen");
  },
)
```

---

# Next step

[Meeting Class](meeting-class.md)

# Complete API References

- [Setup](setup.md)
- [Meeting Builder Widget](meeting-builder-widget.md)
- [Meeting Class](meeting-class.md)
- [Participant Class](participant-class.md)
- [Stream Class](stream-class.md)
