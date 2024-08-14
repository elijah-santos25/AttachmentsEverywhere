#  AttachmentsEverywhere
Backports `RealityView`'s `init(make:update:attachments)` to non-visionOS platforms.

## Basic Usage
- Use as a standard SPM dependency
- Import `AttachmentsEverywhere` in your code
- Replace any `RealityView` that uses `init(make:update:attachments:)` with `AttachableRealityView`
- Your code will probably (hopefully) compile, though it may not function properly without tweaking

## Advanced Usage
In order to approach the usability of attachments on visionOS, `AttachmentsEverywhere` provides some
extensions on top of the `RealityKit` API. These extensions are not available on visionOS, and 
therefore must be wrapped inside `#if !os(visionOS)`.

### Glass Background Customization
By default, `AttachmentsEverywhere` adds a glass background (rather, a crude facsimile of it) to 
attachments. Use the `.glassBackgroundStyle(_:)` modifier on `Attachment` with a 
`GlassBackgroundType` in order to customize this behavior:
- `.capsule`: The view's glass background will be a capsule 
   (corner radius equal to half the height of the attachment).
- `.roundedRectangle(cornerRadius:)`: The view's glass background will be a rounded rectangle, 
   with a corner radius defined in points.
- `.none`: The view will not have a glass background.

### Gestures
Use `.onTapGesture(_:)` on `Attachment` in order to respond to tap gestures. At this time, this is 
the only supported gesture. Your closure will be passed a `CGPoint` which is the location of the tap
in your view's coordinate space.

### Attachment Scale
By default, attachment view entities are scaled such that 300 points is equivalent to one 
(RealityView) meter. In order to customize this scaling, apply the 
`.attachmentScale(pointsPerMeter:)` view modifier outside your `AttachableRealityView`.

## Important Considerations / Quirks
`AttachmentsEverywhere` relies on `SwiftUI`'s current behavior regarding `RealityView` view updates.
This behavior could change in future OS releases (i.e., past iOS 18.0 and macOS 15.0) and some 
features of this library may cease functioning. This library is intended as a stopgap solution until
Apple (hopefully) adds attachments to non-visionOS platforms. As such, this library has some quirks 
regarding its functionality that should be taken into account.

### Automatic Re-Rendering of Attachment Views
`Attachment`s will be re-rendered when `ImageRenderer` determines their state to have changed. 
Crucially, this only seems to take into account `State`s, `Binding`s, etc. held *inside* the 
attachment views. State held outside of `AttachableRealityView` *will not* automatically re-render 
attachment views. Such state *must* be passed into `Attachment`s with `Binding` (and similar).

### Automatic Insertion / Deletion / Modification of Attachments
Every time `RealityView` would call the `update` closure, `AttachmentsEverywhere` reevaluates the 
`attachments` closure. This means that `Attachment`s can be dynamically added or removed (with 
result builder control flow) in response to state changes, though your surrounding view must depend
on these state variables. Just like with `RealityView`, any attachments must be added to the scene 
manually. Any attachments that are removed due to a state change will be automatically removed from 
the scene. 

**At this time (until I find a clean way to make it function), `ForEach` is not supported
in the `attachments` closure.** Instead, use a for-in loop, as it is supported.

## Library To-Do
- [ ] Support `ForEach` (if possible) in order to bolster code compatibility
- [ ] Support other gestures
- [ ] Create better glass material
