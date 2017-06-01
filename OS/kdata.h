
int NEW = 0;
int READY = 1;
int RUNNING = 2;
int EXIT = 3;

typedef struct RegImg{
	int SS;/*PCB+0*/
	int GS;/*PCB+2*/
	int FS;/*PCB+4*/
	int ES;/*PCB+6*/
	int DS;/*PCB+8*/
	int DI;/*PCB+10*/
	int SI;/*PCB+12*/
	int BP;/*PCB+14*/
	int SP;/*PCB+16*/
	int BX;/*PCB+18*/
	int DX;/*PCB+20*/
	int CX;/*PCB+22*/
	int AX;/*PCB+24*/
	int IP;/*PCB+26*/
	int CS;/*PCB+28*/
	int FLAGS;/*PCB+30*/
}RegImg;

typedef struct PCB{
	RegImg regImg;
	int Process_Status;
}PCB;


PCB pcb_list[8];
struct PCB* procPtr;
procPtr = pcb_list;
int CurrentPCBno = 0; 
int Program_Num = 0;


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
	pcb_list[CurrentPCBno].regImg.AX = ax;
	pcb_list[CurrentPCBno].regImg.BX = bx;
	pcb_list[CurrentPCBno].regImg.CX = cx;
	pcb_list[CurrentPCBno].regImg.DX = dx;

	pcb_list[CurrentPCBno].regImg.DS = ds;
	pcb_list[CurrentPCBno].regImg.ES = es;
	pcb_list[CurrentPCBno].regImg.FS = fs;
	pcb_list[CurrentPCBno].regImg.GS = gs;
	pcb_list[CurrentPCBno].regImg.SS = ss;

	pcb_list[CurrentPCBno].regImg.IP = ip;
	pcb_list[CurrentPCBno].regImg.CS = cs;
	pcb_list[CurrentPCBno].regImg.FLAGS = flags;
	
	pcb_list[CurrentPCBno].regImg.DI = di;
	pcb_list[CurrentPCBno].regImg.SI = si;
	pcb_list[CurrentPCBno].regImg.SP = sp;
	pcb_list[CurrentPCBno].regImg.BP = bp;
}
int procCnt = 0;
void Schedule(){

	pcb_list[CurrentPCBno].Process_Status = READY;

	if(Program_Num > 0){
		CurrentPCBno++;
		if( CurrentPCBno > Program_Num ){
			CurrentPCBno = 1;
		}
	}

	if( pcb_list[CurrentPCBno].Process_Status != NEW )
		pcb_list[CurrentPCBno].Process_Status = RUNNING;
	
	if(procCnt >= 120){
		CurrentPCBno = 0;
		procCnt = 0;
	}
	return;
}
PCB* curProc(){
	procCnt++;
	if(procCnt >= 120){
		/*printstring("F**k\n");*/
		CurrentPCBno = 0;
		procCnt = 0;
		Program_Num = 0;
		return &pcb_list[0];
	}
	return &pcb_list[CurrentPCBno];
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
	if(pcb_list[CurrentPCBno].Process_Status==NEW)
		pcb_list[CurrentPCBno].Process_Status=RUNNING;
}

