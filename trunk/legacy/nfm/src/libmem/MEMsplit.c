#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Load the next buffer nformation.                 *
*                                                                   *
* Arguements       long MEMsplit_copy_buffer (src_list, dest_list,  *
*                                             type)                 *
*                       MEMptr  src_list;                           *
*                       MEMptr  *dest_list;                         *
*                       long    type;                               *
*                                                                   *
* Algorithm        Look up to which buffer the structure information*
*                  is pointing to, and copy the current buffer      *
*                  into the destination buffer.                     *
*                                                                   *
* Return Status     MEM_S_SUCCESS     : Success.                    *
*                   MEM_E_NULL_LIST   : Failure                     *
*                                       (list -> buffer is NULL).   *
*                   MEM_E_NULL_BUFFER : Failure                     *
*                                       (list -> buffer_ptr is NULL)*
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

 long MEMsplit_copy_buffer (list, list1, type)
   MEMptr  list;
   MEMptr  *list1;
   long    type;
   {
     long  status, atol ();
     char  temp [25];
     long  buffer_offset, buffer_size;
     long  x, y, z;
     long  buffer_offset1, alloc_size;
     static char *fname = "MEMsplit_copy_buffer";
     int   temp_len;

     _MEMdebug ((fname,"Src List Addr = <%d> : Dst List Addr = <%d> : Type = <%d>\n", 
		 list, *list1, type));

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

     z = x; y = 1; buffer_offset = 0;

     while (1)
      {
        buffer_size = atol (list -> buffer_ptr + MEM_BUFFER_USED + buffer_offset);

        alloc_size = atol (list -> buffer_ptr + MEM_REALLOC_SIZE + buffer_offset);

        z = atol (list -> buffer_ptr + MEM_NO_BUFFER + buffer_offset);

        if (y >= x)  break;
        if (! z)     break;

        buffer_offset = buffer_offset + buffer_size;

        y++;
      }

     buffer_offset1 = buffer_offset;

     while (type)
      {
        if (! z)    break;

        z = atol (list -> buffer_ptr + MEM_NO_BUFFER + buffer_offset1);

        buffer_size = atol (list -> buffer_ptr + MEM_BUFFER_USED + buffer_offset1);

        buffer_offset1 = buffer_offset1 + buffer_size;
        buffer_size    = buffer_offset1 - buffer_offset;
      }

     status = MEMopen (list1, alloc_size);
     if (status != MEM_S_SUCCESS)
      {
        _MEMdebug ((fname,"MEM Open : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     status = MEMcheck_free_space (*list1, buffer_size);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list1);
        _MEMdebug ((fname,"Check Free Space : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     memcpy ((*list1) -> buffer_ptr, list -> buffer_ptr + buffer_offset,
             buffer_size);      
     
     if (! type)  sprintf (temp, "%d", 0);
     else
      {
        if (buffer_offset == buffer_offset1) sprintf (temp, "%d", 0);
        else                                 sprintf (temp, "%d", 1);
      }

     temp_len = strlen (temp);
     memcpy ((*list1) -> buffer_ptr + MEM_NO_BUFFER, temp, temp_len);

     for (y = temp_len; y < MEM_INT_SIZE; ++y)
        *((*list1) -> buffer_ptr + MEM_NO_BUFFER + y) = (char) 0x00;

     *((*list1) -> buffer_ptr + MEM_REALLOC_SIZE - 1) = (char) 0x00;

     status = MEMload_structure (*list1, 0);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (list1);
        _MEMdebug ((fname,"Load Struct : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     _MEMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", MEM_S_SUCCESS));
     return (MEM_S_SUCCESS);
   }
