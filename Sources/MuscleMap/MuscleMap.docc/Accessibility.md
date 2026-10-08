# Accessibility

Make the body map usable with VoiceOver.

## Overview

``BodyView`` exposes each visible muscle as an accessibility element. No setup is needed.

Each element has:

- **Label:** the localized muscle name. A muscle drawn on both sides gets one element per side, labeled for example "Biceps, Left" and "Biceps, Right".
- **Value:** "Selected" or "Not selected".
- **Hints and actions:** double-tap selects the muscle, and a "Long press for details" action calls ``BodyView/onMuscleLongPressed(duration:action:)``.

Elements are ordered from top to bottom, and the two sides of a muscle are read one after the other. Activating an element calls ``BodyView/onMuscleSelected(_:)`` with the same muscle and ``MuscleSide`` that a touch on that spot would report.

## Localization

Muscle names, sides and accessibility strings are localized in 11 languages: Arabic, Chinese (Simplified), English, French, German, Japanese, Korean, Portuguese (Brazil), Russian, Spanish and Turkish. Use ``Muscle/displayName`` and ``MuscleSide/displayName`` to show the same names in your own UI.
