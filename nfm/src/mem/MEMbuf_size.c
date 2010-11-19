#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Get the buffer size.                             *
*                                                                   *
* Arguements       long MEMbuffer_size (list)                       *
*                       MEMptr  list;                               *
*                                                                   *
* Algorithm        See the first byte to get the information if the *
*                  buffer contains more buffers. Then get the sum   *
*                  of the buffer used size from the buffer.         *
*                                                                   *
* Return Status    MEM_E_NULL_LIST    : Failure (buffer is NULL).   *
*                  MEM_E_NULL_BUFFER  : Failure (buffer_ptr is NULL)*
*                  +ve number : Success (size of buffer_ptr).       *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See                                                          *
*                                                                   *
* History                                                           *
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                                                                   *
*********************************************************************
********************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

  long MEMbuffer_size (list, buf_size)
    MEMptr  list;
    int     *buf_size;
    {
       static  char *fname = "MEMbuffer_size";
       long    status;
       long    y, atol ();
       long    buffer_size, total_buffer_size;

       _MEMdebug ((fname,"List Addr = <%d>\n", list));

       /* check if the buffer or buffer_ptr points to NULL */

       if (! list)
        {
          status = MEM_E_NULL_LIST;
          _MEMdebug ((fname,"List Is Null : status <0x%.8x>\n",status));
	  ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       if (! list -> buffer_ptr)
        {
          status = MEM_E_NULL_BUFFER;
          _MEMdebug((fname, "List -> Buffer Is Null : status = <0x%.8x>\n",
		     status));
	  ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       /* get the size of the buffer */

       y = 1;  buffer_size = 0; total_buffer_size = 0;
       
       while (y)
        {
           buffer_size = atol (list -> buffer_ptr + total_buffer_size + MEM_BUFFER_USED);

           y = atol (list -> buffer_ptr + total_buffer_size + MEM_NO_BUFFER);
       
           total_buffer_size = total_buffer_size + buffer_size;
        }

       *buf_size = total_buffer_size;

       _MEMdebug ((fname," SUCCESSFUL : total buffer size = <%d>\n",
		   total_buffer_size));
       return  (MEM_S_SUCCESS);
    }
