#include "machine.h"
#include <stdio.h>
#ifndef TRUE
#define TRUE	1
#endif

long NFMbzero(string,size)
	char *string;
	int size;
{
	int i=0;
	for(i=0;i < size ; i++) string[i]='\0';
	return(TRUE);
}
