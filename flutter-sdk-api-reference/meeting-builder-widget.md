# Meeting Builder Widget

The entry point into real-time communication SDK.

## Using Meeting Builder Widget

The `Meeting Builder Widget` includes methods and events to initialize and configure the SDK. It is a factory class.

import MethodListGroup from '@theme/MethodListGroup';
import MethodListItemLabel from '@theme/MethodListItemLabel';
import MethodListHeading from '@theme/MethodListHeading';

### Properties

<MethodListGroup>
<MethodListHeading heading="Properties" />
  <MethodListGroup name="initMeeting()">
    <MethodListItemLabel name="meetingId" type={"String"} />
    <MethodListItemLabel name="displayName" type={"String"}   />
    <MethodListItemLabel name="token" type={"String"}   />
    <MethodListItemLabel name="micEnabled" type={"Bool"}   />
    <MethodListItemLabel name="webcamEnabled" type={"Bool"}   />
    <MethodListItemLabel name="builder" type={"Widget Function(Meeting)"}   />
  </MethodListGroup>
</MethodListGroup>

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
