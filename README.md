# iOS demo for picture in picture

苹果在iOS14中开放了手机端对画中画的支持，方便在app退出前台时仍然可以播放视频。
画中画的开启，本质上还是需要依赖系统播放器，同时UI、动画等都是系统原生提供的，因此自定义空间很小。

### 官方文档
具体的使用，建议先阅读官方文档，官方提供了两个文档，分别如下

1. 使用系统的[AVPlayerViewController构建](https://developer.apple.com/documentation/avkit/adopting_picture_in_picture_in_a_standard_player?language=objc)
2. 使用系统的[AVPlayer+AVPictureInPictureController构建](https://developer.apple.com/documentation/avkit/adopting_picture_in_picture_in_a_custom_player?language=objc)

### demo
看完官方文档，来看一下完整实现，这里就不贴代码片段了，建议直接看完整实现。
[demo](https://github.com/XT-W/pip)

### 简单总结

使用方法很简单，系统高度定制，没啥技术含量

1. 创建系统播放器`AVPlayer`
2. 创建渲染目标`AVPlayerLayer`
3. 创建画中画控制器`AVPictureInPictureController`
4. 开启画中画

### 填坑

官方文档简单清晰，但实际使用中有时会出现画中画开启失败，但是又没有任何回调的情况，这时候你需要检查一下你的代码有没有满足以下几点

1. 判断`isPictureInPicturePossible`

`AVPictureInPictureController`并不是创建好就可以立即使用的，需要通过`isPictureInPicturePossible`属性判断一下状态。
如果`isPictureInPicturePossible==NO`时直接调用`startPictureInPicture`尝试开启画中画，不但没有效果，而且收不到任何回调

2. 播放器用于渲染的`view`、`layer`一定正确加入到层级中

如果业务使用系统播放器，那么这里一般不会有问题，因为播放器已经正确显示了。但是如果业务使用了自定义播放器，同时也希望具有画中画能力，那么通常会创建一个隐藏的系统播放器，作为画中画功能的承载。这时候就要注意保证用于渲染的`view`、`layer`正确地加入到了层级中，否则，再一次，没有任何感知的失败

3. 强持有`AVPictureInPictureController`

这一点官方文档也提到了，这里补充一点，当调用`stopPictureInPicture`关闭画中画时，不要立刻释放`AVPictureInPictureController`，否则你会看到一个画中画的异常现象。

4. 只有全屏的播放器才能在切后台时自动开启画中画

这里的“全屏”，经过测试发现，只要视频的宽或高撑满屏幕即可。比方说demo中的16:9的`playerView`并没有撑满整个屏幕，也可以自动开启画中画

