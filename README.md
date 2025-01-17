

## 一. 下载工具
`verilator v5.008` 
``

## 一. 设置环境变量

我们首要先设置三个环境变量`CPU_HOME`, `AM_HOME`, `SIM_HOME`, `TEST_HOME`

export CPU_HOME=cpu-single-cycle目录的绝对路径
export SIM_HOME=$CPU_HOME/simulator
export AM_HOME=$CPU_HOME/abstract-machine
export TEST_HOME=$CPU_HOME/software-test
## 二. 运行模拟器和测试程序

1.运行menuconfig配置文件

在保证终端屏幕大小合适的情况下，运行下面的命令，执行成功后，会出现一个GUI窗口，使用左右方向键移动到< save >图标上, 然后一路回车退出
```
cd $SIM_HOME
make menuconfig 
```

2.运行模拟器——执行`make run`命令，运行模拟器

3.运行测试程序
(1)运行`cpu-test`测试程序, 复制下面的示例命令并执行
```
示例1
    cd $TEST_HOME/cpu-tests
    make run ARCH=riscv32-npc ALL=dummy

示例2
    cd $TEST_HOME/cpu-tests
    make run ARCH=riscv32-npc ALL=string

示例3
    cd $TEST_HOME/cpu-tests
    make run ARCH=riscv32-npc
```

(2)运行benchmarck测试程序
```
示例1——运行microbench的test测试集
    cd $TEST_HOME/benchmarks/microbench
    make run ARCH=riscv32-npc mainargs=test

示例2——运行microbench的train测试集
    cd $TEST_HOME/benchmarks/microbench
    make run ARCH=riscv32-npc mainargs=train

示例3——运行coremark
    cd $TEST_HOME/benchmarks/coremark
    make run ARCH=riscv32-npc
    #这个测试的分数可能不准

示例4——运行dhrystone测试
    cd $TEST_HOME/benchmarks/dhrystone
    make run ARCH=riscv32-npc
    #这个测试的分数也可能不准
```
## 三. 将你的处理器接入仿真环境并测试

### 仿真环境介绍
为了大家测试自己的单周期处理器实现是否正确，我们开发了一个用于测试单周期处理器的仿真框架。
我们只需要将自己的单周期处理器进行稍微改动，就可以接入仿真框架，进行一些测试。

### 1. **将你的处理器代码移动直`IP/mycpu目录`**:

    `IP/mycpu目录`是存放我们single-cycle-cpu的`verilog`代码的目录，将所有的处理器代码全部放入到mycpu目录里面

### 2. 将你的处理器代码接入仿真环境

mycpu目录内置了一个CPU.v, 其为内置的最顶层仿真模块, **我们的处理器要在该模块中进行实例化**

`CPU.v`模块内置以下四个信号

(1)输入信号`clk`——仿真环境提供的时钟信号

(2)输入信号`rst`——仿真环境提供的高电平复位信号

(3)输出信号`cpu_pc_for_simulator`——需要和你处理器的pc值绑定

(4)输出信号`regfile_for_simulator[31:0]`——需要和你处理器的寄存器信号绑定

对于输出信号来说，你需要从你的处理器代码里面引出对应的信号线，和对应的输出信号绑定
    以下是一些代码示例

    //CPU模块
    module CPU(
        input wire clk,
        input wire rst,

        output wire [31:0] cur_pc_for_simulator,
        output wire [31:0] regfile_for_simulator[31:0]
    );
        
    endmodule

    //clk的使用方法————我们只检测posedge clk
    always @(posedge clk) begin

    end


    //rst的使用方法
    //在rst为高位的时候，复位信号
    always @(posedge clk) begin
        if(rst) begin
            regfile[0] <= 32'd0;
        end
    end

    //绑定cpu_pc_for_simulator信号
    assign cpu_pc_for_simulator = 处理器当前的pc值

    //绑定regfile_for_simulator[31:0]信号
    你需要从寄存器文件引出几个额外的信号线，从而将寄存器信号和regfile_for_simulator信号绑定

3.修改取指模块
    
    你的处理器的取指模块要按照下面的逻辑进行取指，如果你的处理器有其他额外的信号，不会影响该逻辑过程。
    ```
    module fetch(

    );
    import "DPI-C" function int  dpi_mem_read 	(input int addr  , input int len);
    import "DPI-C" function void dpi_ebreak		(input int pc);

    assign 处理器取出的的指令 = dpi_mem_read(处理器取指的pc，, 4);

    always @(*) begin
        if(处理器取出的的指令 == 32'h00100073) begin
            dpi_ebreak(处理器取指的pc，);
        end
    end
    ```
4.修改访存模块

    你的处理器的访存模块需要按照下列的逻辑进行访存，如果你的处理器有其他额外的信号，不会影响该逻辑过程。

    ```
    module memory (
        input  wire                 clk,
        input  wire                 rst,
        input  wire                 xxx
    );
    import "DPI-C" function void dpi_mem_write(input int addr, input int data, int len);
    import "DPI-C" function int  dpi_mem_read (input int addr  , input int len);

    //从内存中读出数据
    wire [31:0] 读出来的数据;
    读出来的数据= dpi_mem_read(你要读取的内存地址, 4);

    //往内存中写入数据
    always @(posedge clk) begin
        if(如果需要写一个字节) begin
            dpi_mem_write(要写入的地址, 要写入的数据, 1);
        end
        else if(如果需要写两个字节) begin
            dpi_mem_write(要写入的地址, 要写入的数据, 2);		
        end
        else if(如果需要写4个字节) begin
            dpi_mem_write(要写入的地址, 要写入的数据, 4);				
        end
    end

    endmodule //moduleName
5.修改pc值

    `pc`初始值需要设置为0x80000000
    ```
    always @(posedge clk) begin
    if(rst) begin
        pc <= 32'h80000000;
    end

    ```


### 3. 使用我们自己的处理器

将`mycpu`目录的名字修改为`single-cycle-cpu`

### 4. 启动difftest

执行下面的命令，启动difftest，用于检测我们的处理器是否正确。

```
cd $SIM_HOME
make menuconfig
执行完后出现一个界面框，上下移动方向键，在[]Open Difftest这一栏里面，选中，然后选择save并退出。
```

### 3. 测试你的处理器
    运行cpu-tests目录下的测试程序

### 4. 对你的处理器进行benchmark跑分
    ！！！！！！一定要关闭Difftest之后，再进行benchmark跑分！！！！！！
    运行benchmark下面的测试集程序
    



### 其它事项
更多测试集程序正在添加中