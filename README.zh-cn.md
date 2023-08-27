
语言:  [English](https://github.com/yangfanyu/shelf_easy/blob/main/README.md) | 中文 

本库是一个综合性的轻量级框架，每个模块都可以单独使用。 示例代码目录 [example](https://github.com/yangfanyu/shelf_easy/tree/main/example) 阅读导航：

- [1、用于Json序列化的数据模型生成模块](#1用于json序列化的数据模型生成模块)
  - [模型的生成](#模型的生成)
  - [序列化演示](#序列化演示)
- [2、用于Database的统一数据操作模块](#2用于database的统一数据操作模块)
- [3、Web服务模块、Websocket服务模块、配套客户端模块](#3web服务模块websocket服务模块配套客户端模块)
  - [Web服务器](#web服务器)
  - [Web客户端](#web客户端)
  - [Websocket服务器](#websocket服务器)
  - [Websocket客户端](#websocket客户端)
- [4、Dart子集虚拟机模块，可用于Flutter的AOT环境](#4dart子集虚拟机模块可用于flutter的aot环境)
  - [生成虚拟机桥接类型](#生成虚拟机桥接类型)
  - [Dart子集虚拟机用法](#dart子集虚拟机用法)
  - [Flutter环境下的Dart代码推送方案](#flutter环境下的dart代码推送方案)
- [5、日志模块](#5日志模块)
- [6、集群环境下的服务器与客户端](#6集群环境下的服务器与客户端)
  - [集群服务器](#集群服务器)
  - [集群客户端](#集群客户端)
  - [测试的流程](#测试的流程)

# 1、用于Json序列化的数据模型生成模块

## 模型的生成

生成Json序列化的数据模型的代码在 example 目录下的 [generator.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/generator.dart) 文件中。

可以在 example 目录中执行 `dart generator.dart` 来生成模型，生成的文件在 [model](https://github.com/yangfanyu/shelf_easy/tree/main/example/model) 目录中。

## 序列化演示

演示Json序列化与反序列化的代码在 example 目录下的 [test/test_model.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/test/test_model.dart) 文件中。

可以在 example 目录中执行 `dart test/test_model.dart` 来查看控制台的输出信息。

# 2、用于Database的统一数据操作模块

演示数据库统一操作的代码在 example 目录下的 [test/test_database.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/test/test_database.dart) 文件。

可以在 example 目录中执行 `dart test/test_database.dart` 来查看控制台的输出信息。

注意：

1. 序列化代码生成器生成的数据库辅助类如 `UserQuery` 结合统一数据库操作类 `EasyUniDb`，可以发挥 `dart强类型` 语言优点， 尽可能的避免 `Map<String, dynamic>` 或 `sql语句` 相关的`字符串key`操作。

2. `EasyUniDb` 接口风格与 `mongo shell` 基本保持一致，当前仅支持Mongodb，计划支持postgre。

3. 示例代码仅仅是个演示，`EasyUniDb` 的每个接口返回的结果都为 `DbResult<T>` 类型的对象，真实场景下可以根据 `DbResult<T>` 的字段来判断数据库操作结果状态。具体请查看相关类的注释。

# 3、Web服务模块、Websocket服务模块、配套客户端模块

## Web服务器

Web服务器的示例代码在 example 目录下的 [test/test_webserver.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/test/test_webserver.dart) 文件中。

可以在 example 目录中执行 `dart test/test_webserver.dart` 来启动Web服务器。

## Web客户端

Web客户端的示例代码在 example 目录下的 [test/test_webclient.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/test/test_webclient.dart) 文件中。

可以在 example 目录中执行 `dart test/test_webclient.dart` 来发起Web客户端调用。

## Websocket服务器

Websocket服务器的示例代码在 example 目录下的 [test/test_wssserver.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/test/test_wssserver.dart) 文件中。

可以在 example 目录中执行 `dart test/test_wssserver.dart` 来启动Websocket服务器。

## Websocket客户端

示例Websocket客户端的示例代码在 example 目录下的 [test/test_wssclient.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/test/test_wssclient.dart) 文件中。

可以在 example 目录中执行 `dart test/test_wssclient.dart` 来发起Websocket客户端调用。

# 4、Dart子集虚拟机模块，可用于Flutter的AOT环境

flutter环境由于不能在AOT环境推送代码，热更新成了个难题。幸运的是dart官方提供了 `dart:analyzer` 代码分析包，本模块基于这个包开发。

## 生成虚拟机桥接类型

生成虚拟机桥接类型的代码在 example 目录下的 [test/test_vmgen.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/test/test_vmgen.dart) 文件中。

可以在 example 目录中执行 `dart test/test_vmgen.dart` 来生成桥接类型。生成的文件在 [bridge](https://github.com/yangfanyu/shelf_easy/tree/main/example/bridge) 目录中。


## Dart子集虚拟机用法

Dart子集虚拟机用法的代码在 example 目录下的 [test/test_vmware.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/test/test_vmware.dart) 文件中。

可以在 example 目录中执行 `dart test/test_vmware.dart` 来查看控制台的输出信息。

## Flutter环境下的Dart代码推送方案

ZyCloud服务的Dart网络客户端库 [zycloud_client](https://github.com/yangfanyu/zycloud_client)

ZyCloud服务的Flutter小部件库 [zycloud_widget](https://github.com/yangfanyu/zycloud_widget)

注意：

1. 当前虚拟机有部分语法尚未兼容，但已兼容的语法足以完成大多数需求。 
   
2. 作者已使用本方案进行了生产环境下的项目实践，此实践项目在AOT环境下实现了99%的 `dart` 代码推送。

# 5、日志模块

日志模块的代码在 example 目录下的 [test/test_logger.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/test/test_logger.dart) 文件中。

可以在 example 目录中执行 `dart test/test_logger.dart` 来查看控制台的输出信息。

# 6、集群环境下的服务器与客户端

## 集群服务器

集群服务器的代码在 example 目录下的 [app/app_server.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/app/app_server.dart) 文件中。

注意：

1. 示例的服务器包含两种环境配置，分别为： `develop` 、`release`，可以根据实际需求自定义很多种环境配置。

2. 示例的服务器包含三种服务节点，分别为： 
公开的Web服务节点 [http](https://github.com/yangfanyu/shelf_easy/tree/main/example/app/http_route.dart) 、 
公开的Websocket服务节点 [outer](https://github.com/yangfanyu/shelf_easy/tree/main/example/app/outer_route.dart) 、
内部的业务服务节点[inner](https://github.com/yangfanyu/shelf_easy/tree/main/example/app/inner_route.dart) 。

## 集群客户端

集群客户端的代码在 example 目录下的 [app/app_client.dart](https://github.com/yangfanyu/shelf_easy/tree/main/example/app/app_client.dart) 文件中。

## 测试的流程

1. 打开新控制台窗口，在 example 目录中执行 `dart app/app_server.dart` 启动服务器

2. 打开新控制台窗口，在 example 目录中执行 `dart app/app_client.dart 8001` 启动 `cat` 分组的用户 `aaa` 的长连接客户端

3. 打开新控制台窗口，在 example 目录中执行 `dart app/app_client.dart 8002` 启动 `cat` 分组的用户 `bbb` 的长连接客户端

4. 打开新控制台窗口，在 example 目录中执行 `dart app/app_client.dart 8003` 启动 `dog` 分组的用户 `ccc` 的长连接客户端。

5. 此时可观察每个控制台窗口输出情况。

5. 打开新控制台窗口，在 example 目录中在 example 目录中执行 `dart app/app_client.dart 8080` 启动 `http` 客户端来推送数据。

6. 此时可观察每个控制台窗口输出情况。