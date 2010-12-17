#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Get the buffer size.                             *
*                                                                   *
* Arguements       long MEMno_buffers (list)                       *
*                       MEMptr  list;                               *
*                                                                   *
* Algorithm        See the first byte to get the information if the *
*                  buffer contains more buffers. Then get the       *
*                  total number of buffers appended.                *
*                                                                   *
* Return Status    MEM_E_NULL_LIST   : Failure (buffer is NULL).    *
*                  MEM_E_NULL_BUFFER : Failure (buffer_ptr is NULL).*
*                  +ve number : Success (no of buffer_ptr).         *
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
*                     						    *
*                   Modified by  : Dudley Thomas		    *
*                   Date         : January 07 1992                  *
*                   Comments     : Removed call to MEMerror()       *           *                                                                   *
*                                                                   *
*********************************************************************
********************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

  long MEMno_buffers (list, no_buffers)
    MEMptr  list;
    int	    *no_buffers;
    {
       static char    *fname = "MEMno_buffers";
       long    status, atol ();
       long    buffer_size, total_buffer_size;
       long    buff_no, y;

       _MEMdebug ((fname,"List Addr = <%d>\n", list));

       /* check if the buffer or buffer_ptr points to NULL */

       if (! list) 
        {
          status = MEM_E_NULL_LIST;
          _MEMdebug ((fname,"List Is Null : status = <0x%.8x>\n", status));
          ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       if (! list -> buffer_ptr)
        {
          _MEMdebug ((fname, "List -> Buffer Is Null : status = <0x%.8x>\n",
		      status));
          ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       /* get the size of the buffer */

       y = 1;   buff_no = 0;  total_buffer_size = 0; buffer_size = 0;

       while (y)
        {
           total_buffer_size = total_buffer_size + buffer_size;           

           y = atol (list -> buffer_ptr + total_buffer_size + MEM_NO_BUFFER);

           buffer_size = atol (list -> buffer_ptr + total_buffer_size + MEM_BUFFER_USED);

           buff_no++;
        }

       *no_buffers = buff_no;

       _MEMdebug ((fname,"SUCCESSFUL : No Buffers = <%d>\n", buff_no));
       return  (MEM_S_SUCCESS);
    }
