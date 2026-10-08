# Sub-Groups and Regions

Highlight parts of a muscle, and check which muscles a view can draw.

## Overview

Several muscles are divided into sub-groups, such as the upper and lower chest or the inner and outer quadriceps. Each sub-group is cut from its parent muscle's artwork, so it lines up exactly with the parent's outline.

Sub-groups are hidden by default. Call ``BodyView/showSubGroups()`` to draw them and to make taps return the sub-group instead of its parent:

```swift
BodyView(gender: .male, side: .front)
    .showSubGroups()
    .highlight(.upperChest, color: .red)
    .highlight(.lowerChest, color: .orange)
    .highlight(.innerQuad, color: .blue)
```

A sub-group without a highlight of its own shows its parent's highlight, so you can highlight a parent and emphasize one part of it:

```swift
BodyView(gender: .male, side: .front)
    .showSubGroups()
    .highlight(.chest, color: .red, opacity: 0.4)
    .highlight(.upperChest, color: .red)
```

Use ``Muscle/subGroups`` and ``Muscle/parentGroup`` to navigate the hierarchy.

## Always-Visible Sub-Groups

``Muscle/ankles``, ``Muscle/adductors`` and ``Muscle/neck`` are drawn even when sub-groups are hidden. In that mode a tap on them returns the parent muscle. See ``Muscle/isAlwaysVisibleSubGroup``.

## Back Regions

The back views have a few extra regions:

- ``Muscle/upperTrapezius`` and ``Muscle/lowerTrapezius``: the trapezius above and below the rhomboids. On the front views, the visible trapezius is its upper part.
- ``Muscle/rearDeltoid``: the deltoid as seen from behind.
- ``Muscle/rhomboids``: inside the trapezius. They are painted only while highlighted or selected, so an unhighlighted body and a ``Muscle/trapezius`` highlight look the same as without them.
- ``Muscle/rotatorCuff``: the infraspinatus area above the shoulder blade. Without a highlight of its own, it shows the ``Muscle/upperBack`` highlight.

With sub-groups hidden, a tap on the rhomboids or the rotator cuff returns ``Muscle/trapezius`` or ``Muscle/upperBack``.

## Checking What a View Can Draw

Every muscle is drawn in at least one view, but many only on the front or on the back. Check a muscle mapping with ``Muscle/isDrawable(gender:side:)``, for example in a unit test:

```swift
func testEveryMappedMuscleIsVisible() {
    for muscle in myBackDayMuscles {
        XCTAssertTrue(muscle.isDrawable(gender: .male, side: .back), "\(muscle)")
    }
}
```

The female back view has no ``Muscle/head`` path, because the hair covers the head completely.
