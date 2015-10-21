# EasyAPI

一个超级简单的，用XML列表来调用Web API。暂时使用Swift 1.2。

---

# 快速入门

1. 准备好API列表的XML文档，命名为EasyAPI.plist，放在Supporting Files目录下

2. 在任何地方加入这些代码

```swift
EasyAPI.send("foo")
EasyAPI.send("bar", body: "Test" param: "hello")

func getResult(tag: String, result: AnyObject) {
	println(results)//result的类型将根据API请求结果而定，有字典、数组和字符串
}

func getError(tag: String, error: NSError, statusCode: Int)
	println(statusCode)//打印出错误情况下的HTTP状态码
```

搞定！无需考虑任何网络请求，线程，类型转换的冗余代码，只考虑数据本身

-
# 特点
>
1. **轻量级**    
	整个库不使用其他外部框架，精简代码，使用GCD处理线程，对于简单的CS应用告别AFNetworking或者Alamofire
2. **无需编码**    
	传统iOS网络请求会在每个视图控制器中写入很多对网络请求的调用和处理，整个视图控制器的本质，代码冗余。现在新的API只需要编辑XML文档即可，其他皆不需要考虑
3. **热更新**    
	无须依赖内嵌脚本，实现服务端API变动的热更新。对于变动URL或者参数名称可以轻松搞定，如果旧的API不使用，直接XML文档中删除即可。只有变动API参数个数和新增API需要手动重新编码。
4. **面向快速开发**    
	适用于轻量iOS网络应用，如即时通讯，社交平台，创业产品，上手简单，快速迭代，而不需要繁重的编码考虑

-
# 导入项目
双击.xcworkspace即可，引用Alamofire作为动态链接库

-
# XML列表格式

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>API List</key>
	<dict>
		<key>foo</key>
		<dict>
			<key>URL</key>
			<string>http://dreampiggy.com/foo</string>
			<key>Method</key>
			<string>GET</string>
		</dict>
	</dict>
	<dict>
		<key>bar</key>
		<dict>
			<key>URL</key>
			<string>http://dreampiggy.com/bar</string>
			<key>Method</key>
			<string>POST</string>
			<key>Param</key>
			<array>
				<string>msg</string>
			</array>
			<key>Body</key>
			<string>Test Body</string>
		</dict>
	</dict>
	<key>UpdateURL</key>
	<string>http://dreampiggy.com/update</string>
</dict>
</plist>
```

-
# 方法说明

+ `EasyAPI.send(tag: String, param:String...) -> Bool`

发送一个网络请求，tag为EasyAPI.plist中的API List的键一一对应。如果指定tag的请求已经存在且未完成，前一个请求会被取消。参数列表也与EasyAPI.plist中的列表顺序一一对应。如果参数列表不匹配，该请求将不会被发送，方法返回`false`，且`getError()`会被调用。

+ `EasyAPI.send(tag: String, path:String, param:String...) -> Bool`

可以定义URL的模版，用String的模版，比如`"http://www.%@.com",path = "baidu"`可以生成`"http://www.baidu.com"`的URL，使用URLEncode，path默认为空

+ `EasyAPI.send(tag: String, body:String param:String...) -> Bool`

允许自定义Body，使用URLEncode，仅限POST请求，注意此时如果还有`param`参数，将把`param`加入`URL Query`而并非Alamofire自带的放入Body内

+ `EasyAPI.cancel(tag: String) -> void`

取消指定tag的网络请求，在子视图被销毁前可调用来取消后台网络请求

+ `EasyAPI.cancelAll() -> void`

取消当前已经发送但未完成的**所有网络请求**，在一些视图被销毁前使用来进行扫尾的时候非常有用，也可以在进行大量异步请求的时候一次性取消

+ `EasyAPI.update() -> Bool`

更新`EasyAPI.plist`，通过指定XML文档中`UpdateURL`键的值作为更新服务器的地址，返回的合法XML文档将会替换当前`EasyAPI.plist`。注意：在更新期间所有请求将会被加入等待队列而不会被执行，更新完成（或者失败）后才会被执行。

-
# 贡献者

[DreamPiggy](https://github.com/lizhuoli1126)

-
# 许可证

通过MIT license发布。详细请查阅项目下的LICENCE