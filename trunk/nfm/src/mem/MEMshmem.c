#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <errno.h>
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "NFMerrordef.h"
#include "ERR.h"

MEMread_shm_buffer(NFMshmid,bufr)
char	*NFMshmid;
MEMptr  *bufr;
{
	int     shmid, bufr_size;
	int     status;
	int     no_procs_done, no_procs;
        char    *shm_seg;
        MEMptr  temp = NULL;
        char    s1[50];
	static char *fname = "MEMread_shm_buffer";

	_MEMdebug((fname," NFMshmid %s\n",NFMshmid));

        shmid = atol(NFMshmid);

        shm_seg = (char *) shmat(shmid,0,0);
        status = (int) shm_seg;
	if(status == -1)
	{
	   _MEMdebug((fname, "shmat failed status %d\n",status));;
	   _MEMdebug((fname, "shmat failed errno %d\n",errno));
	   status = MEM_E_UNIX;
	   ERRload_struct(MEM,status,"%s","shmat");
	   return(status);
	}
        temp = (MEMptr) malloc(sizeof(struct MEMbuffer_struct));
        if(!temp)
        {
	   status = MEM_E_MALLOC;
	   _MEMdebug((fname," malloc failed errno <%d>\n",errno));
	   ERRload_struct(MEM,status,"%s","malloc");
	   return(status);
        }
	temp->format_ptr = NULL;
	temp->column_ptr = NULL;
	temp->data_ptr = NULL;
	temp->buffer_ptr = NULL;

        strncpy(s1,shm_seg,16);     no_procs = atol(s1);
        strncpy(s1,shm_seg+16,16);  no_procs_done = atol(s1);
        strncpy(s1,shm_seg+32,10);  bufr_size = atol(s1);
        strncpy(s1,shm_seg+42,32);    temp->row_size = atol(s1);
        strncpy(s1,shm_seg+74,32);    temp->rows = atol(s1);
        strncpy(s1,shm_seg+106,32);   temp->columns = atol(s1);
        temp->buffer_ptr = (char *) malloc(bufr_size);
        if(!temp->buffer_ptr)
        {
	   MEMclose(&temp);
	   status = MEM_E_MALLOC;
	   _MEMdebug((fname, "malloc failed errno <%d>\n",errno));
	   ERRload_struct(MEM,status,"%s","malloc");
	   return(status);
        }
        memcpy(temp->buffer_ptr,shm_seg+138,bufr_size);

        *bufr = temp;
        no_procs_done = no_procs_done + 1;
	if(no_procs == no_procs_done)
	{
		/* remove the shared memory segment */

           status = shmctl(shmid,IPC_RMID,NULL);
	   if(status == -1)
	   {
	     _MEMdebug((fname, "shmctl failed status %d\n",status));
	     _MEMdebug((fname, "shmctl failed errno %d\n",errno));
	     status = MEM_E_UNIX;
	     ERRload_struct(MEM,status,"%s","shmat");
	     return(status);
	   }	    
	}
	else
        {
		sprintf(s1,"%d",no_procs_done);
		strncpy(shm_seg+16,s1,16);
        }
	_MEMdebug((fname,"SUCCESSFUL : returning <0x%.8x>\n",MEM_S_SUCCESS));
	return(MEM_S_SUCCESS);
}


