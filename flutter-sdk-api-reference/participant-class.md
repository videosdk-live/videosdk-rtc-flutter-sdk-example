---
title: Participant class for IOS SDK.
hide_title: false
hide_table_of_contents: false
description: The `Participant Class` includes methods and events for participants and their associated audio and video streams, data channels and UI customisation.
sidebar_label: Participant Class
pagination_label: Participant Class
keywords:
  - RTC IOS
  - Participant Class
  - Video API
  - Video Conferencing
image: img/videosdklive-thumbnail.jpg
sidebar_position: 1
slug: participant-class
---

# Participant Class

## using Participant Class

The `Participant Class` includes methods and events for participants and their associated audio and video streams, data channels and UI customisation.

import MethodListGroup from '@theme/MethodListGroup';
import MethodListItemLabel from '@theme/MethodListItemLabel';
import MethodListHeading from '@theme/MethodListHeading';

### Properties

<MethodListGroup>
  <MethodListItemLabel name="__properties"  >
    <MethodListGroup>
      <MethodListHeading heading="Properties" />
      <MethodListItemLabel name="id"  type={"String"} />
      <MethodListItemLabel name="displayName"  type={"String"} />
      <MethodListItemLabel name="streams"  type={"Map<String, Stream>"} />
      <MethodListItemLabel name="renderer"  type={"RTCVideoRenderer?"} />
    </MethodListGroup>
  </MethodListItemLabel>
</MethodListGroup>

### Events

<MethodListGroup>
  <MethodListItemLabel name="__events" >
    <MethodListGroup>
      <MethodListHeading heading="Events" />
      <MethodListItemLabel name="stream-enabled"  type={"Stream"} />
      <MethodListItemLabel name="stream-disabled"  type={"Stream"} />
    </MethodListGroup>
  </MethodListItemLabel>
</MethodListGroup>

<!--

### Methods

<MethodListGroup>
  <MethodListItemLabel name="__methods" >
    <MethodListGroup>
      <MethodListHeading heading="Methods" />
      <MethodListGroup>
        <MethodListHeading heading="addStream(stream): void" />
        <MethodListItemLabel name="stream"  type={"MediaStream"} />
      </MethodListGroup>
      <MethodListGroup>
        <MethodListHeading heading="removeStream(streamId): void" />
        <MethodListItemLabel name="streamId"  type={"String"} />
      </MethodListGroup>
    </MethodListGroup>
  </MethodListItemLabel>
</MethodListGroup> -->

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
