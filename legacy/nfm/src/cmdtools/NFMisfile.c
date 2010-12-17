#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "NFMerrordef.h"

long _NFMisfile(filename)
        char *filename;
{
	struct stat buf;
	if(stat(filename,&buf)== 0)return(NFM_S_SUCCESS);
	return(NFM_E_FAILURE);
}
