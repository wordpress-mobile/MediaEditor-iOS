**`validate_podspec` was bypassed!**

As of Xcode 14.3, libraries with deployment target below iOS 11 (iOS 12 in Xcode 15) fail to build out of the box.
The reason is a missing file, `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/arc/libarclite_iphonesimulator.a`, more info [here](https://stackoverflow.com/questions/75574268/missing-file-libarclite-iphoneos-a-xcode-14-3).

Client apps can work around this with a post install hook that updates the dependency deployment target, but libraries do not have this option.

Our old Alamofire dependency targets iOS 8.0, making the validation build fail.

In the interest of using up to date CI (i.e. not waste time downloading old images) we bypass validation until either we are able to drop or upgraed Alamofire, or find a workaround.
