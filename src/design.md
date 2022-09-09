WAC分为几个相互尽量解藕的部分：

1. WAC(Waffle & Cookie) WAC主程序，将各个部分整合到一起
2. WFC(WaFfle Core) 与窗口和gui相关
3. CKC(CooKie Core) 与WAC的动画计算有关
4. PK(PanKu) 底层功能库(报错输出、图像字体加载、数学)

其中WAC依赖WFC、CKC与PK；
CKC依赖WFC和PK；
WFC依赖PK。