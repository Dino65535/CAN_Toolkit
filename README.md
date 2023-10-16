# CanToolkit
由於專題的題目牽涉到汽車電子元件(ECU)與車載系統之間的溝通(CAN protocol)，需要常常操作 CAN 工具，因此編寫了一個 shell script 來自動化命令輸入。
***
![toolkit img](https://github.com/Dino65535/CAN_Toolkit/blob/e61dd21ed8aff8376daf992e30a5b84d22983d26/img/toolkit.png)
***

### 環境
* linux 版本 : kali-rolling 2023.2  
(一些顏色代碼如 `\e[1m` 在其他 linux 系統上可會沒有效果)

### 工具
* [can-utils](https://github.com/linux-can/can-utils)

      sudo apt update
      sudo apt install can-utils

### 使用說明
* 需要先輸入指令添加腳本的執行權限
  
      chmod +x cantool.sh

* 使用時選擇 can 介面名稱

      ./cantool.sh vcan0
    
* 腳本功能涉及到開啟和關閉 virtual can 介面，因此有使用 sudo 語法，若不需要開啟和關閉的功能或是不需要以管理員的權限開啟，可以將腳本以下語法註解(加#)或刪除
  ``` Bash
  21 sudo modprobe can
  22 sudo modprobe vcan
  23 sudo ip link add dev $interface type vcan
  58 sudo ip link set up $interface
  62 sudo ip link set $interface down
  ```
  
### 感謝&參考
* [@souravbaghz](https://github.com/souravbaghz) for [Carpunk](https://github.com/souravbaghz/Carpunk#-carpunk-v2)
