#!/bin/bash

#variable=====================================
interface=$1
msg="歡迎使用 CAN 工具!"

bold="\e[1m"
green="\e[92m"
red="\e[31m"
blue="\e[36m"
redBG_whiteWord="\e[41m"
reset="\e[0m"
#=============================================

if [[ -z $1 ]] then
	echo "需要輸入介面名稱!"
	echo "舉例: ./command.sh vcan0"
	exit 1
else
	sudo modprobe can
	sudo modprobe vcan
	sudo ip link add dev $interface type vcan
	trap 'break' INT
fi
		
message(){
	clear
	echo "──────────────────────────────"
	echo -e "訊息: $bold$msg$reset"
	echo -e "介面名稱: $blue$bold$interface$reset"
	echo "──────────────────────────────"
}
menu(){
	message
	echo "[1] 啟動 can 介面"
	echo "[2] 關閉 can 介面"
	echo "[3] 監聽 can"
	echo "[4] 紀錄 can"
	echo "[5] 重播 can 紀錄"
	echo "[6] 寄送 can 封包"
	echo "[7] 隨機生成 can 封包"
	echo "[8] 嗅探 can"
	echo "[9] 注入 can 封包"
	echo "輸入其他數字離開"
	echo "──────────────────────────────"
	echo -e "[?] 輸入選擇 : \c"

	read option
	if [[ "$option" =~ ^[0-9]+$ ]] then
		option=$((10#$option))
	else
		msg="請輸入整數!"
		menu
	fi

	if [[ "$option" = 1 ]] then
		msg="$interface 已啟動!"
		sudo ip link set up $interface
		menu
	elif [[ "$option" = 2 ]] then
		msg="$interface 已關閉!"
		sudo ip link set $interface down
		menu
	elif [[ "$option" = 3 ]] then
		check
		dump
		menu
	elif [[ "$option" = 4 ]] then
		check
		record
		menu
	elif [[ "$option" = 5 ]] then
		player
		menu
	elif [[ "$option" = 6 ]] then
		check
		send
		menu
	elif [[ "$option" = 7 ]] then
		check
		generate
		menu
	elif [[ "$option" = 8 ]] then
		check
		sniffer
		menu
	elif [[ "$option" = 9 ]] then
		check
		injection
		menu
	else
		clear
		echo -e "$red已關閉 CAN 工具!"
		exit 0
	fi
}
check(){
	can_status=$(ip link show "$interface" | grep -o "state [A-Z]\+" | awk '{print $2}')

	if [[ "$can_status" = "DOWN" ]] then
		msg="$reset$redBG_whiteWord介面尚未啟動!"
		menu
	fi
}
dump(){
	msg="選擇監聽參數"
	message

	echo "選擇時間參數"
	echo "[1] UNIX時間戳"
	echo "[2] 封包時間間隔"
	echo "[3] 從監聽開始計算時間"
	echo "[4] 當前時間"
	echo "輸入其他數字離開"
	echo "──────────────────────────────"
	echo -e "[?] 輸入選擇 : \c"
	read option
	if [[ "$option" =~ ^[0-9]+$ ]] then
		option=$((10#$option))
	else
		msg="請輸入整數!"
		message
		dump
	fi

	msg="已開始監聽!(Ctrl-C 終止)"
	message
	
	if [[ "$option" = 1 ]] then
		candump -t a $interface
	elif [[ "$option" = 2 ]] then
		candump -t d $interface
	elif [[ "$option" = 3 ]] then
		candump -t z $interface
	elif [[ "$option" = 4 ]] then
		candump -t A $interface
	else
		msg="監聽已取消!"
		message
		menu
	fi
	msg="已結束監聽!"
}
record(){
	msg="選擇記錄參數"
	message

	echo "選擇時間參數"
	echo "[1] UNIX時間戳"
	echo "[2] 封包時間間隔"
	echo "[3] 從監聽開始計算時間"
	echo "[4] 當前時間"
	echo "輸入其他數字離開"
	echo "──────────────────────────────"
	echo -e "[?] 輸入選擇 : \c"
	read option
	if [[ "$option" =~ ^[0-9]+$ ]] then
		option=$((10#$option))
	else
		msg="請輸入整數!"
		message
		record
	fi

	date=""
	if [[ "$option" = 1 ]] then
		date="-t a"
	elif [[ "$option" = 2 ]] then
		date="-t d"
	elif [[ "$option" = 3 ]] then
	 	date="-t z"
	elif [[ "$option" = 4 ]] then
	 	date="-t A"
	else
		msg="紀錄已取消!"
		message
		menu
	fi

	echo "──────────────────────────────"
	echo "選擇格式參數"
	echo "[1] (000.000000) vcan0 001 [8] 00 01 02 03 04 05 06 07"
	echo "[2] (000.000000) vcan0 001#0001020304050607"
	echo -e "$green格式2只會輸出UNIX時間戳$reset"
	echo "輸入其他數字離開"
	echo "──────────────────────────────"
	echo -e "[?] 輸入選擇 : \c"
	read option
	if [[ "$option" =~ ^[0-9]+$ ]] then
		option=$((10#$option))
	else
		msg="請輸入整數!"
		message
		record
	fi

	form=""
	if [[ "$option" = 1 ]] then
		form=""
	elif [[ "$option" = 2 ]] then
		form="-L"
	else
		msg="紀錄已取消!"
		message
		menu
	fi

	echo "──────────────────────────────"
	echo "輸入檔案名稱"
	echo "舉例: 0826-01.log"
	echo "──────────────────────────────"
	echo -e "[?] 輸入名稱 : \c" 
	read -a filename

	msg="已開始紀錄!(Ctrl-C 終止)"
	message
	candump $date $form $interface > ${filename[0]}
	msg="已結束記錄!"
}
player(){
	msg="選擇播放檔案"
	message

	echo "輸入檔案名稱"
	echo "舉例: 0826-01.log"
	echo -e "$green輸入檔案不存在則跳回主選單$reset"
	echo "──────────────────────────────"
	echo -e "[?] 輸入名稱 : \c" 
	read -a filename

	if [[ ! -e "$filename" ]] then\
		msg="所選檔案不存在!"
		menu
	fi
	msg="正在播放紀錄!(Ctrl-C 終止)"
	message
	canplayer -I ${filename[0]}
	msg="播放已結束!"	
}
send(){
	msg="請輸入封包內容"
	message

	echo "數據幀: <can_id>#{data}"
	echo "遠程幀: <can_id>#R{len}"
	echo "can_id: 三位十六進制字元"
	echo "data: 長度0~8的十六進制值"
	echo "len: 0~8"
	echo "舉例: 5A1#1234ABCD / B23#R3"
	echo "──────────────────────────────"
	echo -e "[?] 輸入內容 : \c"
	read frame

	echo "──────────────────────────────"
	echo "選擇傳送方法"
	echo "[1] 傳送一次(適用於更改指示燈等)"
	echo "[2] 持續傳送(適用於速度儀等)"
	echo "輸入其他數字離開"
	echo "──────────────────────────────"
	echo -e "[?] 輸入選擇 : \c"
	read option
	if [[ "$option" =~ ^[0-9]+$ ]] then
		option=$((10#$option))
	else
		msg="請輸入整數!"
		message
		send
	fi

	if [[ "$option" = 1 ]] then
		cansend $interface "$frame"
	elif [[ "$option" = 2 ]] then
		msg="持續傳送中...(Ctrl-C 終止)"
		message
		while true
		do
			cansend $interface "$frame"
		done
	else
		msg="傳送已取消!"
		message
		menu
	fi

	msg="封包已傳送!"
}
generate(){
	msg="正在隨機生成封包!(Ctrl-C 終止)"
	message

	cangen $interface
	msg="隨機生成封包已結束!"
}
sniffer(){
	msg="準備開始嗅探封包!(Ctrl-C 終止)"
	message
	sleep 3

	cansniffer $interface
	msg="嗅探封包已結束!"
}
injection(){
	msg="請輸入注入內容"
	message

	echo "數據幀: <can_id>#{data}"
	echo "遠程幀: <can_id>#R{len}"
	echo "can_id: 三位十六進制字元"
	echo "data: 長度0~8的十六進制值"
	echo "len: 0~8"
	echo "舉例: 5A1#1234ABCD / B23#R3"
	echo "──────────────────────────────"
	echo -e "[?] 輸入內容 : \c"
	read frame

	msg="正在注入封包!(Ctrl-C 終止)"
	message
	
	while :
	do
		cansend $interface $frame
	done
	msg="注入已結束!"
}

menu