//#include "../tty/tty.h"


void _kernel_main(void){
    *(char*)0xb8000 = 'S';
    while (1){

    }
    return;
}