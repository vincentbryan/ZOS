char messageOuch[80] = "Ouch!\n";
char msg1[80]        = "\n\n                         Welcome to ZOS\n";
char msg2[100]       = "\n    You can execute some functions by inputing some command. Input \'h\' for help.\n";
char msg3[80]        = "If you want to run the program by Batching,input \'batch\'\n\n";
char msg11[80]       = "If you want to continue,input \'yes\'\n";
char msg12[80]       = "OS will run instructions \'batch 1 2 3 4\' and \'time 1 2 3 4\'\n";
char msgCmd[80]      = ">>> ";
char msgError[80]    = "ERROR INPUT!!\n";
char endline[5]      = "\n";
char default1[80]    = "batch 1 2 3 4";

const int offset1 = 0xa500;		/*9900h*/
const int offset2 = 0xa900;		/*9d00h*/
const int offset3 = 0xad00;		/*a100h*/
const int offset4 = 0xb100;		/*a500h*/
int offsetUser  = 0xa500;		/*用户程序偏移量*/
int offsetBegin = 0xa500;		/*读到内存的偏移量*/
int sectorNum = 8;				/*扇区数*/
int sectorPos = 2;				/*起始扇区数*/