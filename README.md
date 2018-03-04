## 一、Why
* <font color=black size=4>不重复造轮子</font>

> 项目之间可以共享代码，减少不必要的重复劳动，提高开发效率。

* <font color=black size=4>技术沉淀</font>

> 让每一次的项目开发都有收获！养成经常思考、整理、优化代码的习惯，沉淀的不仅仅是代码量，更重要的是技术和经验！

* <font color=black size=4>终极目标</font>

> 让Control层的核心业务逻辑不被大量的“胶水代码”和其它各种小逻辑所淹没。
	
## 二、Structure

* 目录结构

		- YSCKit.h		存放YSCKit常用模块的引用
		- YSCConstants.h	存放YSCKit中用到的常量、Block、枚举等的定义
		- YSCMacros.h		存放YSCKit中常用的宏定义，最主要是代码段简写
		+ YSCAdapter		统一管理第三方代码的适配器
			- YSCAdapter.h      常用适配器的引用
			+ YSCHUD            封装对MBProgressHUD调用的适配器
			+ YSCModel          封装对MJExtension调用的适配器
			+ YSCNetworking     封装对AFNetworking调用的适配器
			+ YSCWebImage       封装对SDWebImage调用的适配器
		+ YSCBase			对系统类的扩展
			- YSCBase.h			常用系统类扩展的引用
			+ Category          分类方式扩展系统库
				+ Foundation         扩展Foundation.framework中的常用库
				+ UIKit              扩展UIKit.framework中的常用库
			+ Inherit           继承方式扩展系统库
		+ YSCSingleton		单例类
		+ YSCUtils			静态方法类
		+ YSCView           自定义view
		+ YSCViewController viewController基类

		+ Demo              对基础库进行单元测试、功能演示的demo项目

* 类名
		
		1. 自定义类命名规范：YSCXxxxx
		2. category类命名规范：SYSTEM_CLASS (YSCKit)
		3. 封装静态方法的类：YSCXxxxUtil、YSCXxxxHelper
		4. 单例类：YSCXxxxManager

* 方法名

		1. 创建单例的标准代码：
		+ (instancetype)sharedInstance {
			static dispatch_once_t pred = 0;
			__strong static id _sharedObject = nil;
			dispatch_once(&pred, ^{
				_sharedObject = [[self alloc] init];
			});
			return _sharedObject;
		}
		2. 私有方法前面加下划线’_’ 
		3. category方法前必须有前缀’psk_’

* 文件头注释

		必不可少的要素：类名、包名、作者、创建日期、版权信息。如:
		//
		//  YSCXxxx.m
		//  YSCKit
		//
		//  Created by AUTHOR on DATE.
		//  Copyright © 2016年 Builder. All rights reserved.
	
## 三、Comment

* 为了更好兼容工具appledoc或doxygen以自动生成文档，在书写注释时注意使用以下命令：

		/**
		 * @brief 带字符串参数的方法.
		 *
		 * 详细描述或其他.
		 * 
		 * @param  value1 值.
		 * @param  value2 值.
		 *
		 * @return 返回value.
		 *
		 * @exception NSException 可能抛出的异常.
		 * 
		 * @see someMethod
		 * @warning 警告: appledoc中显示为蓝色背景, Doxygen中显示为红色竖条.
		 * @bug 缺陷: appledoc中显示为黄色背景, Doxygen中显示为绿色竖条.
		 */ 
		 
* 注释中添加实例代码：

		/**
 		 * 示例代码:
		 *
		 *		int sum = 0;
		 * 		for(int i= 0; i < 10; i++) {
		 *          sum += i;
		 * 		}
		 */
		 
* 带参数的宏注释：

		/**
		 * @brief	最小值 （参数宏, 仅Doxygen）.
		 *			
		 * 详细描述或其他.
		 * 
		 * @param     a     值a.
		 * @param     b     值b.
		 *
		 * @return    返回两者中的最小值.
		 */
		#define min(a,b)    ( ((a)<(b)) ? (a) : (b) )
		
* 函数指针与块函数注释：

		/**
		 * @brief    动作块函数.
		 *
		 * 详细描述或其他.
		 * 
		 * @param     sender     发送者.
		 * @param     userdata     自定义数据.
		 */
		typedef void (^ActionHandler)(id sender, id userdata);

* 无序列表：

		/**
		 * 无序列表:
		 *
		 * - abc
		 * - xyz
		 * - rgb
		 */

* 有序列表：

		/**
		 * 有序列表:
		 *
		 * 1. first.
		 * 2. second.
		 * 3. third.
		 */


* 多级列表：

		/**
		 * 多级列表:
		 *
		 * - xyz
		 *    - x
		 *    - y
		 *    - z
		 * - rgb
		 *    - red
		 *        1. first.
		 *            1. alpha.
		 *            2. beta.
		 *        2. second.
		 *        3. third.
		 *    - green
		 *    - blue
		 */

* 添加链接：
	
		/**
 		 * [Doxygen](http://www.stack.nl/~dimitri/doxygen/)
 		 */
	
	
## 四、How 3rd lib added into YSCKit?

* 加入的第三方库随时可以替换但不能修改调用方的代码

* 通过Adapter模式解耦第三方库的调用方式
 
* 有两种适配方式：对象适配(封装实例化对象)、类适配(继承)
 
* YSCXxxAdapterManager负责创建Adapter;YSCXxxxAdapter负责调用第三方库的代码


## 五、TODO

* camera manager
* photo browser
* sqlite access
* pop over
* slide show
* segmented control
* location 
* scanner
* QR cde / Bar code
* badge view
* star rating
* video player / audio player
* downloader
* HUD
* data mapping
* open web url
* picker view
