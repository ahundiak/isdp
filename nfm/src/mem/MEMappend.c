#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Append a buffer to another buffer.               *
*                                                                   *
* Arguements       long MEMappend (src_list, dest_list)             *
*                       MEMptr  src_list;                           *
*                       MEMptr  dest_list;                          *
*                                                                   *
* Algorithm        This function adds the buffer_ptr of the souce   *
*                  buffer to the end of the destination buffer's    *
*                  buffer_ptr. It also sets the first byte of the   *
*                  destination buffer to 1 if the first byte is 0.  *
*                                                                   *
* Return Status    MEM_E_NULL_SRC_LIST   : src list = NULL          *
*                  MEM_E_NULL_SRC_BUFFER : src list -> buffer_ptr   *
*                                          is NULL                  *    
*                  MEM_E_NULL_LIST       : dest list = NULL         *
*                  MEM_E_NULL_BUFFER     : dest list -> buffer_ptr  *
*                                          is NULL                  *
*                                                                   *
*                  Greater Than 0  : Success (No of bytes copied).  *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMcheck_free_space ()                           *
*                                                                   *
* History                                                           *
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                                                                   *
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 9, 1992                  *
*                   Comments     : Added call to ERRload_struct for *
*                                  all non-success statuses.        *
*                                                                   *
*********************************************************************
********************************************************************/
#include <stdio.h>
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

 long MEMappend (list1, list2)
  MEMptr list1, list2;
  {
    long   status, atol ();
    long   buffer_size1, buffer_size2;
    char   temp [25];
    long   y, x, cont;
    static char *fname = "MEMappend";

    _MEMdebug((fname,"Src  List Addr = <%d> : Dest List Addr = <%d>\n", 
	       list1, list2));

    /* check if buffers or the buffer's -> buffer_ptr are NULL */
       
    if (! list1)
     {
       status = MEM_E_NULL_SRC_LIST;
       _MEMdebug ((fname,"SRC List Is Null : status = <0x%.8x>\n", status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    if (! list1 -> buffer_ptr)
     {
       _MEMdebug ((fname,"SRC List -> Buffer Is Null : status = <0x%.8x>\n",
       status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    if (! list2)
     {
       status = MEM_E_NULL_LIST;
       _MEMdebug((fname,"List Is Null : status = <0x%.8x>\n", status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    if (! list2 -> buffer_ptr)
     {
       status = MEM_E_NULL_BUFFER;
       _MEMdebug ((fname,"List -> Buffer Is Null : status = <0x%.8x>\n", 
		   status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    /* get the size of souce buffer */

    buffer_size1 = 0;
      
    while (1)
     {
        cont = atol (list1 -> buffer_ptr + MEM_NO_BUFFER + buffer_size1);

        y = atol (list1 -> buffer_ptr + MEM_BUFFER_USED + buffer_size1);

        buffer_size1 = buffer_size1 + y;

        if (! cont) break;
     }

    /* get the size of destination buffer */

    buffer_size2 = 0;

    while (1)
     {
        cont = atol (list2 -> buffer_ptr + MEM_NO_BUFFER + buffer_size2);

        y = atol (list2 -> buffer_ptr + MEM_BUFFER_USED + buffer_size2);

        x = buffer_size2;
        buffer_size2 = buffer_size2 + y;

        if (! cont) break;
     }

    /* check if there is memory malloced enough to accomodate the
       source buffer in the destination buffer */

    status = MEMcheck_free_space (list2, buffer_size1 + 1);
    if (status != MEM_S_SUCCESS)
     {
       _MEMdebug ((fname,"Check Free Space : status = <0x%.8x>\n", 
		   status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    /* memcpy the source buffer at the end of destination buffer */

    memcpy (list2 -> buffer_ptr + buffer_size2, list1 -> buffer_ptr,
            buffer_size1);

    /* set the first byte of the destination buffer's last buffer
       to 1 to indicate addition of new buffer */
/*  do not need ?     
    memcpy (temp, list2 -> buffer_ptr + x + MEM_NO_BUFFER, MEM_INT_SIZE);
    y = atol (temp);
*/
    sprintf (temp, "1");
    *(list2 -> buffer_ptr + x + MEM_NO_BUFFER) = (char) 0x31;
    for(y=1;y < MEM_INT_SIZE; ++y)
       *(list2 -> buffer_ptr + x + MEM_NO_BUFFER+y) = (char) 0x00;    

    *(list2 -> buffer_ptr + x + MEM_REALLOC_SIZE - 1) = (char) 0x00;

    /* set the first byte of the copied buffer in the destination 
       buffer to indicate if multiple buffers exist in it */

    y = atol (list2 -> buffer_ptr + buffer_size2 + MEM_NO_BUFFER);

    if (y) 
     {
        *(list2 -> buffer_ptr + buffer_size2 + MEM_NO_BUFFER) = (char) 0x31;
        *(list2 -> buffer_ptr + buffer_size2 + MEM_NO_BUFFER + 1) = (char) 0x00;
        *(list2 -> buffer_ptr + buffer_size2 + MEM_REALLOC_SIZE - 1) = (char) 0x00;
     }

   _MEMdebug((fname,"SUCCESSFUL : Bytes Written = <%d>\n", buffer_size1));
    return (MEM_S_SUCCESS);
  }
