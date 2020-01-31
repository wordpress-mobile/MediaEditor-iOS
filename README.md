# MediaEditor

[![CircleCI](https://circleci.com/gh/wordpress-mobile/MediaEditor-iOS.svg?style=svg)](https://circleci.com/gh/wordpress-mobile/MediaEditor-iOS) [![Version](https://img.shields.io/cocoapods/v/MediaEditor.svg?style=flat)](http://cocoadocs.org/docsets/MediaEditor) [![License](https://img.shields.io/cocoapods/l/MediaEditor.svg?style=flat)](http://cocoadocs.org/docsets/MediaEditor) [![Platform](https://img.shields.io/cocoapods/p/MediaEditor.svg?style=flat)](http://cocoadocs.org/docsets/MediaEditor) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

MediaEditor is an extendable library for iOS that allows you to quickly and easily add image editing features to your app. You can edit single or multiple images, from the device's library or any other source. It has been designed to feel natural and part of the OS.

<p align="center">
<img src="https://user-images.githubusercontent.com/7040243/73460209-dd767d80-4356-11ea-9a04-dcc6b0b5e233.PNG" width="340">
</p>

# Features

- [x] [`PHAsset`](https://developer.apple.com/documentation/photokit/phasset) support
- [x] Editing of Plain `UIImage`
- [x] Editing of remote images
- [x] Single media support
- [x] Multiple media support
- [x] Editing in both portrait and landscape modes
- [x] Crop, zoom and rotate capability (thanks to [`TOCropViewController`](https://github.com/TimOliver/TOCropViewController))
- [x] Easily extendable
- [x] Customizable

## Usage

Using `MediaEditor` is very simple, just give it the media and present from a `ViewController`:

```swift
let assets: [PHAsset] = [asset1, asset2, asset3]
let mediaEditor = MediaEditor(assets)
mediaEditor.edit(from: self, onFinishEditing: { images, actions in
    // images contains the returned images, edited or not
    // actions contains the actions made during this session
}, onCancel: {
    // User canceled
})
```

This will present the MediaEditor and when the user finished it will return all the images. You can easily check if the image was changed by checking the `isEdited` property.

Also, `assets` can be a single or an array of: `PHAsset`, `UIImage` or any other entity that conforms to `AsyncImage`.

## More Examples

Check the Example app for even more ways to use the MediaEditor:

* Device Library: how to edit media from the device library and output them in a `UICollectionView`
* Remote Image: how to edit media that is remote, by conforming to the `AsyncImage` protocol and download high-quality images only when needed.
* Plain UIImage: how to edit plain UIImage
* Extending the `MediaEditor` capability by adding your own brightness extension

# Requirements

* iOS 11.0+
* Swift 5

# Installation

### Cocoapods

Add the following to your Podfile:

```ruby
pod 'MediaEditor'
```

### Carthage

1. Add the following to your Cartfile:
```
github "wordpress-mobile/MediaEditor-iOS"
```

2. Run `carthage update`

3. From the `Carthage/Build` folder, import `MediaEditor.framework` and `TOCropViewController.framework` into your Xcode project.

4. Follow the remaining steps on [Getting Started with Carthage](https://github.com/Carthage/Carthage#getting-started) to finish integrating the framework.

### Manual Installation


To install manually copy the `Sources/` folder to your project and follow the steps to [manual install `TOCropViewController`](https://github.com/TimOliver/TOCropViewController/blob/master/README.md#installation) too.

## Contributing

Read our [Contributing Guide](CONTRIBUTING.md) to learn about reporting issues, contributing code, and more ways to contribute.

## Getting in Touch

If you have questions about getting setup or just want to say hi, join the [WordPress Slack](https://chat.wordpress.org) and drop a message on the `#mobile` channel.

## Author

WordPress, mobile@automattic.com

## License

MediaEditor is available under the GPL license. See the [LICENSE file](./LICENSE) for more info.
