# Meeting Class

## Using Meeting Class

The `Meeting Class` includes methods and events for managing meetings, participants, audio and video streams, data channels and UI customisation.

### Properties

| name             | type                      |
| ---------------- | ------------------------- |
| id               | "String                   |
| localParticipant | "Participant              |
| participants     | "Map<String, Participant> |

### Events

| name               | type          |
| ------------------ | ------------- |
| meeting-joined     | void          |
| meeting-left       | void          |
| participant-joined | participant   |
| participant-left   | participantId |

### Methods

| name | type                               |
| ---- | ---------------------------------- |
| void | disableWebcam()                    |
| void | enableWebcam()                     |
| void | disableMic()                       |
| void | enableMic()                        |
| void | join()                             |
| void | leave()                            |
| void | on(String event, Function handler) |

## Example

```js title="Play with meeting instance"
// Join the meeting
meeting?.join();

// Get local participants
meeting?.localParticipant;

// Get remote participants
meeting?.participants;

// Adding event listner
meeting.on("participant-joined", (Participant participant) {
  print("new participant => $participant");
  },
);
```

---

# Next step

[Participant Class](participant-class.md)

# Complete API References

- [Setup](setup.md)
- [Meeting Builder Widget](meeting-builder-widget.md)
- [Meeting Class](meeting-class.md)
- [Participant Class](participant-class.md)
- [Stream Class](stream-class.md)
