
#include "tty/tty.h"

extern void print_();
extern void cls_();

void putchar(void){
    unsigned int buffer_z = BUFFER_ADDR;
    unsigned int * buffer_ptr = (unsigned int*)buffer_z;
    *buffer_ptr = 'H';
}

void Sys_main(){
    
    cls_();
    print_();
    putchar();
    while (1){

    }
}