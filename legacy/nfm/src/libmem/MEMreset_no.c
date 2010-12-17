#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Load the next buffer nformation.                 *
*                                                                   *
* Arguements       long MEMreset_buffer_no (list, no)               *
*                       MEMptr  list;                               *
*                       long    no;                                 *
*                                                                   *
* Algorithm        Set the buffer the structure information for the *
*                  buffer no 'no'. If there are not that many       *
*                  buffers it is an error.                          *
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
*                   Modified by  : Dudley Thomas                    *
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

 long MEMreset_buffer_no (list, no)
   MEMptr  list;
   long    no;
   {
     long  status, atol ();
     char  temp [25];
     long  buffer_offset, buffer_size;
     long  x, y, z;
     static char *fname="MEMreset_buffer_no";
     int   temp_len;

     _MEMdebug ((fname,"List Addr = <%d> : no = <%d>\n", 
		 list, no));

     if (no < 1)
      {
        status = MEM_E_BAD_BUFFER_NO;
        _MEMdebug ((fname, "Bad Buffer No : status = <0x%.8x>\n", status));
        ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

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
      
     x = atol (list -> buffer_ptr + MEM_NO_BUFFER);

     z = x;

     if ((! z) && (no > 1))
      {
        status = MEM_E_BAD_BUFFER_NO;
        _MEMdebug ((fname,"Bad Buffer No : status = <0x%.8x>\n", status));
        ERRload_struct(MEM,status,"",NULL);	
        return (status);
      }

     y = 1;  buffer_offset = 0;

     while (z && no > 1)
      {
        buffer_size = atol (list -> buffer_ptr + MEM_BUFFER_USED + buffer_offset);

        buffer_offset = buffer_offset + buffer_size;

        z = atol (list -> buffer_ptr + MEM_NO_BUFFER + buffer_offset);

        y++;

        if (y >= no)  break;
        if (! z) 
         {
           status = MEM_E_BAD_BUFFER_NO;
           _MEMdebug ((fname,"Bad Buffer No : status = <0x%.8x>\n",
           status));
           ERRload_struct(MEM,status,"",NULL);
           return (status);
         }
      }

     status = MEMload_structure (list, buffer_offset);
     if (status != MEM_S_SUCCESS)
      {
        _MEMdebug ((fname,"Load Struct : status = <0x%.8x>\n", status));
        return (status);
      }

     if (x) 
      {
         sprintf (temp, "%d", no);

         temp_len = strlen (temp);
         memcpy (list -> buffer_ptr + MEM_NO_BUFFER, temp, temp_len);

         for (z = temp_len; z < MEM_INT_SIZE; ++z)
           *(list -> buffer_ptr + MEM_NO_BUFFER + z) = (char) 0x00;

         *(list -> buffer_ptr + MEM_REALLOC_SIZE - 1) = (char) 0x00;
      }

     _MEMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", MEM_S_SUCCESS));
     return (MEM_S_SUCCESS);
   }
