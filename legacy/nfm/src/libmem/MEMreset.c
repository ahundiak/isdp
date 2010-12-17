#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Load the next buffer nformation.                 *
*                                                                   *
* Arguements       long MEMreset_buffer (list)                      *
*                       MEMptr  list;                               *
*                                                                   *
* Algorithm        Look up to which buffer the structure information*
*                  is pointing to, if there are any more buffers    *
*                  load the structure with the next buffer info.    *
*                                                                   *
* Return Status    > 0               : Success.                     *
*                  MEM_E_NULL_LIST   : Failure                      *
*                                      (list -> buffer is NULL).    *
*                  MEM_E_NULL_BUFFER : Failure                      *
*                                      (list -> buffer_ptr is NULL).*
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
*                   Modified  by : Dudley Thomas                    *
*                   Date         : January 9, 1992                  *
*                   Comments     : Added call to ERRload_struct()   *
*                                  for non-success status.          *
*                                                                   *
*                   Modified  by : Dudley Thomas                    *
*                   Date         : January 14, 1992                 *
*                   Comments     : Removed unecessary call to       *
*                                  strlen(). Added variable         *
*                                  "temp_len" to support this.      *
*                                                                   *
*********************************************************************
********************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

 long MEMreset_buffer (list, current_mem_buf)
   MEMptr  list;
   int     *current_mem_buf;
   {
     static char *fname="MEMreset_buffer";
     long  status, atol ();
     char  temp [25];
     long  buffer_offset, buffer_size;
     long  x, y, z;
     int   temp_len;

     _MEMdebug ((fname,"List Addr = <%d>\n", list));
     
     if (! list)
      {
        status = MEM_E_NULL_LIST;
        _MEMdebug ((fname,"List Is Null : status = <0x%.8x>\n", status));
        ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     if (! list -> buffer_ptr)
      {
        status = MEM_E_NULL_BUFFER;
        _MEMdebug ((fname,"List -> Buffer Is Null : status = <0x%.8x>\n",
        status));
        ERRload_struct(MEM,status,"",NULL);
        return (status);
      }
      
     x = atol (list -> buffer_ptr + MEM_NO_BUFFER, MEM_INT_SIZE);

     z = x; y = 1; buffer_offset = 0;  

     while (1)
      {
        if (y > x)  break;
        if (! z)    break;

        buffer_size = atol (list -> buffer_ptr + MEM_BUFFER_USED + buffer_offset);

        buffer_offset = buffer_offset + buffer_size;

        z = atol (list -> buffer_ptr + MEM_NO_BUFFER + buffer_offset);

        y++;
      }

     status = MEMload_structure (list, buffer_offset);
     if (status != MEM_S_SUCCESS)
      {
        _MEMdebug ((fname,"Load Struct : status = <0x%.8x>\n", status));
        ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     if (x) 
      {
         sprintf (temp, "%d", y);

         temp_len = strlen (temp);
         memcpy (list -> buffer_ptr + MEM_NO_BUFFER, temp, temp_len);

         for (z = temp_len; z < MEM_INT_SIZE; ++z)
           *(list -> buffer_ptr + MEM_NO_BUFFER + z) = (char) 0x00;

         *(list -> buffer_ptr + MEM_REALLOC_SIZE - 1) = (char) 0x00;
      }

     *current_mem_buf = y;

     _MEMdebug ((fname,"SUCCESSFUL : Buffer No = <%d>\n", y));
     return (MEM_S_SUCCESS);
   }
