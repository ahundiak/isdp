#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Build the buffer structure from the buffer.      *
*                                                                   *
* Arguements       long MEMbuild_struct (buffer, list)              *
*                       char    *buffer;                            *
*                       MEMptr  *list;                              *
*                                                                   *
* Algorithm        Malloc memory for the MEMptr structure and       *
*                  assign the pointer buffer_ptr of the structure   *
*                  to the buffer. Change the alloc size of the      *
*                  buffer to the size of the buffer. Load the       *
*                  structure information for the first buffer.      * 
*                                                                   *
* Return Status    MEM_S_SUCCESS  : Success.                        *
*                  MEM_E_MALLOC   : Failure.                        *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMload_structure ()                             *
*                                                                   *
* History                                                           *
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                                                                   *
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 9, 1992                  *
*                   Comments     : Added calls to ERRload_struct()  *
*                                  for non-success statuses.        *
*                                                                   *
*********************************************************************
********************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

  long MEMbuild_struct (buffer, list)
    char         *buffer;
    MEMptr       *list;
    {
       long      status, atol ();
       long      total_buffer_size, buffer_size, y;
       static    char *fname = "MEMbuild_struct";

       _MEMdebug ((fname," Buffer Str = <%d> : List Addr = <%d>\n",
		   buffer, *list));
       
       /* malloc the MEMptr strucure */

       if (! buffer)
        {
          status = MEM_E_NULL_BUFFER;
          _MEMdebug ((fname,"Buffer Is Null : status = <0x%.8x>\n", status));
	  ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       buffer_size = atol (buffer + MEM_REALLOC_SIZE);

       status = MEMopen (list, buffer_size);
       if (status != MEM_S_SUCCESS)
        {
          _MEMdebug((fname,"MEM Open : status = <0x%.8x>\n", status));
	  ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       y = 1;  total_buffer_size = 0; buffer_size = 0;

       while (y)
        {
           buffer_size = atol (buffer + total_buffer_size + MEM_BUFFER_USED);

           y = atol (buffer + total_buffer_size + MEM_NO_BUFFER);
       
           total_buffer_size = total_buffer_size + buffer_size;
        }

       status = MEMcheck_free_space (*list, total_buffer_size);
       if (status != MEM_S_SUCCESS)
        {
          MEMclose (list);
          _MEMdebug ((fname,"Check Free Space : status = <0x%.8x>\n",
          status));
	  ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       memcpy ((*list) -> buffer_ptr, buffer, total_buffer_size);

       status = (int) MEMbuild_array (*list);       	 
       if (status != MEM_S_SUCCESS)
        {
          MEMclose (list);
          _MEMdebug((fname," Build Array : status = <0x%.8x>\n",status));
	  ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       free (buffer);

       _MEMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", MEM_S_SUCCESS));
       return (MEM_S_SUCCESS); 
    }
