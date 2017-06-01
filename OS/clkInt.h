/*
================================================
使用8号中断调用此函数
此函数在屏幕的边框绘制箭头
================================================
*/
int px,py,pcolor,pdir,pbegin;
int pdx[4];
int pdy[4];
char pch;

drawRect(){
	if(pbegin != 1){
		px = 0;
		py = 0;
		pcolor = 1;
		pdir = 0;
		pch = 7;
		pbegin = 1;
		pdx[0]=1,pdx[1]=0,pdx[2]=-1,pdx[3]=0;		/*pdx[4]和pdy[4]为四个方向的向量*/
		pdy[0]=0,pdy[1]=1,pdy[2]=0,pdy[3]=-1;
	}

	px += pdx[pdir];
	py += pdy[pdir];

	if(	px==24 && py==0  || px==24 && py==79 || px==0  && py==79 || px==0  && py==0){
		pdir=(pdir+1)%4;
	}
	if( py == 0){
		pch = 31;
	}
	else if(px == 24){
		pch = 16;
	}
	else if(py == 79){
		pch = 30;
	}
	else{
		pch = 17;
	}
	pcolor = ( pcolor + 2 ) % 15 + 1;
	putColorChar(pch,px,py,pcolor);
}
