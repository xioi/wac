# Waffle & Cookie(WAC) Project 华夫饼配曲奇工程
## What's WAC? WAC是什么？
Waffle & Cookie is an unofficial animating software mainly written in Objective-C in order to create Walfas-like style Touhou(or other games and animes) animation and replacing the swf version of Walfas, due to Adobe deciding to unsupport Flash. It is extendable and customizable, which allows you to add your own character's content into it and share on the Internet. It supports using vector image as character's parts so that the images wouldn't be blured. Additionally, WAC provides animation making methods like the Flash software but not the original Walfas. It enables you to add keyframes and complex tween timing functions between keyframes so that you could make soomth Walfas-style animations.

Waffle & Cookie是一个非官方的动画软件，主要使用Objective-C编写，目的是制作Walfas画风的东方Project（或其他游戏和动漫的）动画并同时替换掉swf版本的Walfas软件，因为Adobe停止了对Flash的支持。它是可拓展并可个性化的，你可以往其中添加你自己的角色内容，并且还能够在网上分享这些内容。它渲染矢量图，并确保图像不会失真。还有，WAC提供偏向Flash的动画制作方法，而非原版Walfas的，你能够为动画添加关键帧，并在其中应用复杂的补间方法，以制作流畅的动画。

⚠️Warning⚠️: This project is still under developing, and its process' updating is not as quick as you think.

⚠️注意⚠️：这个项目还在开发中，而且进度并不如你想象的那么快。

## How to compile this project? 如何编译这个项目？
You needs vcpkg, and install following packages:
```
vcpkg install sdl2
vcpkg install freetype
vcpkg install libyaml
```
<!--Then if you're using MS Windows, you also have to install GNUStep.-->
then run in the project's root:
```
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=YOUR_PATH_TO_VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
make
```

你需要vcpkg，然后安装下面这些包：
```
vcpkg install sdl2
vcpkg install freetype
vcpkg install libyaml
```
<!--Then if you're using MS Windows, you also have to install GNUStep.-->
接着在项目根目录运行：
```
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=你到vcpkg根目录的路径/scripts/buildsystems/vcpkg.cmake
make
```