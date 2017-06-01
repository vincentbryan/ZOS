int is_ouch;
int ouch_color;
char msgOuch[10] = "Ouch!\n";
/*键盘中断显示程序*/
c_ouch()
{
	if(is_ouch==0) {
		is_ouch=1;
		px = 1;
		py = 1;
	}
	if(py>=75){
		py = 0;
		px++;
	}
	printstring(msgOuch);  
}