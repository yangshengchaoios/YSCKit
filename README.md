# YSCKit

## Contents
- 封装了APP开发过程中常用的功能，包括：网络请求、模型映射、本地缓存策略、宏定义、枚举类型、emoji表情符号等。
- 自定义了几个非常有用的view：
  1. YSCInfiniteLoopView: 无限循环浏览，如banner展示
  2. YSCTipsView：显示空列表/页面的提示信息
  3. YSCPickerView：时间、日期、多维数组选择器
  4. YSCTitleBarView：自定义导航条
  5. YSCZoomScrollView：可缩放的图片浏览页，用于图片浏览器
  6. YSCTextField：可在xib上设置数据的格式，自动检测键盘的类型、长度、以及合法性
  7. YSCTextView：除了基本功能和YSCTextField类似以外，还能动态显示剩余字符数
  8. YSCTableView：封装了列表的常用操作，支持
    (1). 多section的上拉加载更多、下拉刷新
    (2). GET、POST
    (3). 列表为空的提示信息
    (4). cell左右边界设置
    (5). 对数据进行缓存
    (6). 自定义任意单一确定的数据源
    (7). 动态设置header、cell、footer的高度
    (8). 支持多种header、cell、footer的注册
    (9). 兼容外部数据源(前提是必须和列表数据源类型一致)
    
## 如何安装
  git submodule add https://github.com/yangshengchaoios/YSCKit.git YOURPROJECT/YSCKit

## 如何使用
见 [YSCKitDemo](https://github.com/yangshengchaoios/YSCKitDemo)

## TODO

