
int NEW = 0;
int READY = 1;
int RUNNING = 2;
int EXIT = 3;

typedef struct RegImg{
	int SS;/*PCB+0   1*/
	int GS;/*PCB+2   0*/
	int FS;/*PCB+4   0*/
	int ES;/*PCB+6   0*/
	int DS;/*PCB+8   0*/
	int DI;/*PCB+10  0*/
	int SI;/*PCB+12  0*/
	int BP;/*PCB+14  0*/
	int SP;/*PCB+16  1*/
	int BX;/*PCB+18  0*/
	int DX;/*PCB+20  0*/
	int CX;/*PCB+22  0*/
	int AX;/*PCB+24  0*/
	int IP;/*PCB+26  1*/
	int CS;/*PCB+28  1*/
	int FLAGS;/*PCB+30 1 */
}RegImg;
typedef struct PCB{
	RegImg regImg;
	int Process_Status;
}PCB;


PCB pcbList[8];
struct PCB* procPtr = pcbList;
int curPCBid = 0; 
int procNum = 0;
int procCnt = 0;

extern void printChar();

PCB* curProc();
void saveProc(int,int, int, int, int, int, int, int,
		  int,int,int,int, int,int, int,int );
void init(PCB*, int, int);
void Schedule();
void special();



void saveProc(int gs,int fs,int es,int ds,int di,int si,int bp,
		int sp,int dx,int cx,int bx,int ax,int ss,int ip,int cs,int flags)
{
	pcbList[curPCBid].regImg.AX = ax;
	pcbList[curPCBid].regImg.BX = bx;
	pcbList[curPCBid].regImg.CX = cx;
	pcbList[curPCBid].regImg.DX = dx;

	pcbList[curPCBid].regImg.DS = ds;
	pcbList[curPCBid].regImg.ES = es;
	pcbList[curPCBid].regImg.FS = fs;
	pcbList[curPCBid].regImg.GS = gs;
	pcbList[curPCBid].regImg.SS = ss;

	pcbList[curPCBid].regImg.IP = ip;
	pcbList[curPCBid].regImg.CS = cs;
	pcbList[curPCBid].regImg.FLAGS = flags;
	
	pcbList[curPCBid].regImg.DI = di;
	pcbList[curPCBid].regImg.SI = si;
	pcbList[curPCBid].regImg.SP = sp;
	pcbList[curPCBid].regImg.BP = bp;
}

void Schedule(){

	pcbList[curPCBid].Process_Status = READY;

	if(procNum > 0){
		curPCBid++;
		if( curPCBid > procNum ){
			curPCBid = 1;
		}
	}

	if( pcbList[curPCBid].Process_Status != NEW )
		pcbList[curPCBid].Process_Status = RUNNING;
	
	if(procCnt >= 720){
		curPCBid = 0;
		procCnt = 0;
	}
	return;
}
PCB* curProc(){
	procCnt++;
	if(procCnt >= 720){
		curPCBid = 0;
		procCnt = 0;
		procNum = 0;
		return &pcbList[0];
	}
	return &pcbList[curPCBid];
}

void init(PCB* pcb,int segement, int offset)
{
	pcb->regImg.GS = 0xb800;
	pcb->regImg.SS = segement;
	pcb->regImg.ES = segement;
	pcb->regImg.DS = segement;
	pcb->regImg.CS = segement;
	pcb->regImg.FS = segement;
	pcb->regImg.IP = offset;
	pcb->regImg.SP = offset - 4;
	pcb->regImg.AX = 0;
	pcb->regImg.BX = 0;
	pcb->regImg.CX = 0;
	pcb->regImg.DX = 0;
	pcb->regImg.DI = 0;
	pcb->regImg.SI = 0;
	pcb->regImg.BP = 0;
	pcb->regImg.FLAGS = 512;
	pcb->Process_Status = NEW;
}

void special()
{
	if(pcbList[curPCBid].Process_Status==NEW)
		pcbList[curPCBid].Process_Status=RUNNING;
}

void init_Pro()
{
	init(&pcbList[0],0x0800,0x100); /*偏移地址是多少？*/
	init(&pcbList[1],0x0a50,0x000);
	init(&pcbList[2],0x0a90,0x000);
	init(&pcbList[3],0x0ad0,0x000);
	init(&pcbList[4],0x0b10,0x000);
	/* init(&pcbList[5],0x6000,0x100);*/
}
