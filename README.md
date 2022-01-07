# RxMoyaTool

[![CI Status](https://img.shields.io/travis/kled/RxMoyaTool.svg?style=flat)](https://travis-ci.org/kled/RxMoyaTool)
[![Version](https://img.shields.io/cocoapods/v/RxMoyaTool.svg?style=flat)](https://cocoapods.org/pods/RxMoyaTool)
[![License](https://img.shields.io/cocoapods/l/RxMoyaTool.svg?style=flat)](https://cocoapods.org/pods/RxMoyaTool)
[![Platform](https://img.shields.io/cocoapods/p/RxMoyaTool.svg?style=flat)](https://cocoapods.org/pods/RxMoyaTool)

## 简介
RxMoyaTool 是在您使用 ``RxSwift`` 的时候帮助你快速的实现网络请求，即开即用。

您只需要关心请求路径、参数、返回模型.

一行代码即可发起网络请求，拿到需要的模型，支持对象或者数组形式，也可以是一个字典。


<!--## Example-->

<!--To run the example project, clone the repo, and run `pod install` from the Example directory first.-->
## 安装

RxMoyaTool 可以通过 [CocoaPods](https://cocoapods.org). 来进行安装, 只需将以下行添加到您的 ``Podfile``:

```ruby
pod 'RxMoyaTool'
```

## 使用步骤

step1: 让 ``AppDelegate`` 遵守代理协议 ``MTMoyaConfProtocol``, 并在入口处进行注册。可根据需要实现对应的方法。

```Swift
MTMoyaConfig.shared.startWith(self)
```

step2: 定义自己的 ``Provider``, 如果有多个模块，可以定义多个 ``Provider``, 自行根据业务进行拆分即可。

step3: 在需要的地方定义返回模型(遵守 ``Decodable``协议)，选择 ``Provider`` 中的 case 发起网络请求，在 ``Closures`` 中即可拿到所需要的模型对象。
如果您的数据结构符合 ``{status: 200, message:"",data: [xxx,xxx]}`` 这种结构，那么可以在 ``MTMoyaConfProtocol`` 的方法中处理*状态码*和*提示信息*，并且设置 ``keyPath`` (默认是 ``data``)，之后您只需要关心 data 里面的对象即可（）。

## 许可证

RxMoyaTool 在 MIT 许可下可用。 有关更多信息，请参阅许可证文件。
