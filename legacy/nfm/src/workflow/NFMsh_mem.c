#include "machine.h"
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <errno.h>
#include "MEMbuf_def.h"
#include "WF.h"

long NFMld_ctxt_shmem(buffer,no_procs,NFMshmid)
MEMptr	buffer;
int	no_procs;
char	*NFMshmid;
{
  static char *fname = "NFMld_ctxt_shmem" ;
	int     size;
        int	shmid;
        int     shmflg,status;
        char    *sh_bufr;
	long    NFMload_mem_buffer();

	_NFMdebug ((fname, "no_procs <%d>",no_procs));

        status = MEMbuffer_size(buffer,&size);
        if(status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "MEMbuffer_size status %d\n",
	  status));
	  status = NFM_E_MEM;
	  ERRload_struct(NFM,status,"",NULL);
	  return(status);
	}
        shmflg = 0777;
	size = size + 128;

        shmid = shmget(IPC_PRIVATE,size,shmflg);
        if(shmid == -1)
        {
	  _NFMdebug ((fname, "shmget errno <%d>\n", errno));
	  status = NFM_E_UNIX;
	  ERRload_struct(NFM,status,"%s","shmget");
	  return(status);
	}
        sh_bufr = (char *) shmat(shmid,0,0);
        status = (int) sh_bufr;
	if(status == -1)
	{
	  _NFMdebug ((fname, "shmat errno <%d>\n", errno));
	  status = NFM_E_UNIX;
 	  ERRload_struct(NFM,status,"%s","shmat");
	  return(status);
	}
        status = NFMload_mem_buffer(buffer,no_procs,sh_bufr);
	if(status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "NFMload_mem_buffer <%d>\n", status));
	  return(status);
	}
	sprintf(NFMshmid,"%d",shmid);
	_NFMdebug ((fname, "SUCCESSFUL : shmem : %s\n",NFMshmid));
	return(NFM_S_SUCCESS);
}

/*
	By. Reddy Velagala

	This function copies MEMbufr (list) to bufr.
        bufr is a pointer to an array of characters.
        bufr should be big enough for the copy to work.
	It is the responsibility of the caller to allocate enough memory.
        This is intended for loading a shared memory segment 
	created during Workflow Transitions.
	Note that the no of processes to read the segment 
        is also loaded to this shared segment.
*/

 long NFMload_mem_buffer(list,no_procs,bufr)
   MEMptr  list;
   int     no_procs;
   char    *bufr;
   {
     static char *fname = "NFMload_mem_buffer" ;
     long  status, atol ();
     char  temp [25];
     long  buffer_offset, buffer_size;
     long  x, y, z;
     long  alloc_size;
 
     _NFMdebug ((fname, "Src List Addr = <%d> : Number of process <%s> : Dst Bufr Addr = <%d>\n",
		 list, no_procs, bufr));

     if (! list)
      {
        status = MEM_E_NULL_LIST;
        _NFMdebug ((fname, "List Is Null : status = <%d>\n", status));
        return (status);
      }

     if (! list -> buffer_ptr)
      {
        status = MEM_E_NULL_BUFFER;
        _NFMdebug ((fname, "List -> Buffer Is Null : status = <%d>\n",
        status));
        return (status);
      }

     memcpy (temp, list -> buffer_ptr + MEM_NO_BUFFER, MEM_INT_SIZE);
     x = atol (temp);

     z = x; y = 1; buffer_offset = 0;

     while (1)
      {
      	memcpy (temp, list -> buffer_ptr + MEM_BUFFER_USED + buffer_offset,
                MEM_INT_SIZE);
        buffer_size = atol (temp);

      	memcpy (temp, list -> buffer_ptr + MEM_REALLOC_SIZE + buffer_offset,
                MEM_INT_SIZE);
        alloc_size = atol (temp);

      	memcpy (temp, list -> buffer_ptr + MEM_NO_BUFFER + buffer_offset,
                MEM_INT_SIZE);
        z = atol (temp);

        if (y >= x)  break;
        if (! z)     break;

        buffer_offset = buffer_offset + buffer_size;
        y++;
      }
      sprintf(bufr,"%d",no_procs);
      sprintf(bufr+16,"%d",0);
      sprintf(bufr+32,"%d",buffer_size);
      sprintf(bufr+42,"%d",list->row_size);
      sprintf(bufr+74,"%d",list->rows);
      sprintf(bufr+106,"%d",list->columns);

     memcpy (bufr+138, list -> buffer_ptr + buffer_offset,buffer_size);      
     
     sprintf (temp, "%d", 0);

     memcpy (bufr+138 + MEM_NO_BUFFER, temp, strlen (temp));

     for (y = strlen (temp); y < MEM_INT_SIZE; ++y)
        memcpy (bufr+138+ MEM_NO_BUFFER + y, "\0", 1);

     memcpy (bufr+138 + MEM_REALLOC_SIZE - 1, "\0", 1);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS);
   }
