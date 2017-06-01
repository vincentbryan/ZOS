extern void clear();
extern void inputchar();
extern void printchar();
extern void printstring();
extern void setCursor();
extern void load();
extern void jmp();
extern int  putColorChar();
extern void setInt();
extern void set21Int();
extern void setClock();
#include "CONST.h"
#include "clkInt.h"
#include "proc.h"

char string[80];
int len=0;
int pos=0;
char ch;
int x=0;
int y=0;
int i=0;
int a=0;
int u=0;
int d=0;/*data*/


int input()
{
	inputchar();		/*输入字符*/
	if(ch=='\b'){		/*是删除键Backspace*/
		if(y>8&&y<79){
			y--;
			cal_pos();	/*在前一位置显示空格，并显示后回退一个位置*/
			printchar(' ');
			y--;
			cal_pos();
		}
		return 0;
	}
	else if(ch==13);	/*是回车*/
	else printchar(ch);	/*显示字符*/
	return 1;
}

getCmd(){
	printstring(msgCmd);
	i=0;				/*初始字符串下标*/
	while(1)
	{
		if(input()){	/*不是删除键*/
			if(ch==13) break;/*是回车*/
			string[i++]=ch;
		}
		else if(i>0) i--; /*是删除键，则删除*/
	}
	/*去掉字符串前面的空格*/
	for(a=0;a<i;++a)
		if(string[0]==' '){
			for(u=1;u<i;++u) string[u-1]=string[u];
			i--;
		}
		else break;
	string[i]='\0';		/*末尾加空字符*/
	len=i;				/*记录字符串长度*/
	printstring("\n");
}

cal_pos(){	
	if(y>79){
		y=0;
		x++;
	}
	if(x>24) clear();
	pos=(x*80+y)*2;
	setCursor();
}

batch(){
	clear();					/*清屏*/
	for(i=0;i<len;++i)			/*遍历字符串*/
	{
		if(string[i]=='1')		/*跳转到用户程序1*/
		{
			offsetUser=offset1;
			jmp();
			clear();
		}
		else if(string[i]=='2')	/*跳转到用户程序2*/
		{
			offsetUser=offset2;
			jmp();
			clear();
		}
		else if(string[i]=='3')	/*跳转到用户程序3*/
		{
			offsetUser = offset3;
			jmp();
			clear();
		}
		else if(string[i]=='4')	/*跳转到用户程序4*/
		{
			offsetUser=offset4;
			jmp();
			clear();
		}
		else if(string[i] == '5'){
			setInt();
		}
		else if(string[i] == '6'){
			set21Int();
		}
	}
}


main(){
	while(1){
		clear();
		printstring(msg1);
		printstring(msg2);
		printstring(msg3);
		offsetBegin = offset1;					/*内存偏移量*/
		sectorNum=8;							/*扇区数目*/
		sectorPos=2;							/*起始扇区号*/
		load(offsetBegin, sectorNum, sectorPos);/*装载用户程序到内存*/
		getCmd();

		procNum = 0;
		curPCBid = 0;
		setClock();

		if(string[0]=='b'){
			batch();
			printstring(msg11);
			getCmd();
			if(string[0]=='y') continue;
		}
		else if(string[0] == 'c'){
			/*cal_val();*/
			printstring(msg11);
			getCmd();		
			if(string[0] == 'y');	
		}
		else if(string[0] == 't'){
			/*setClock();*/
			
			clear();
			init_Pro();
			procNum = 4;
			procCnt = 0;
			clear();
			printstring(msg11);
			clear();
			getCmd();
		}
		else{
			printstring(msgError);
			printstring(msg11);
			getCmd();
			if(string[0]=='y') continue;
		}
	}
}

