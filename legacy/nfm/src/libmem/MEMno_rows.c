#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Load the structure information of the buffer.    *
*                                                                   *
* Arguements       long MEMno_rows (list, offset)                   *
*                       MEMptr  list;                               *
*                       long    offset;                             *
*                                                                   *
* Algorithm        Calculate the number of columns for the buffer.  *
*                  Load the format and column information for the   *
*                  buffer and get the row size. Next calculate the  *
*                  number of rows and load the data information.    *
*                                                                   *
* Return Status    MEM_S_SUCCESS     : SUCCESS.                     *
*                  MEM_E_NULL_LIST   : FAILURE.                     *
*                  MEM_E_NULL_BUFFER : FAILURE.                     *
*                  MEM_E_DAT_TYPE    : FAILURE.                     *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMformat_list ()                                *
*                  MEMcolumn_list ()                                *
*                  MEMdata_list ()                                  *
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

 long MEMno_rows (list, offset)
   MEMptr   list;
   long     offset;
   {
     long   status, atol ();
     long   data_offset, buffer_size;
     static char *fname = "MEMno_rows";

     _MEMdebug ((fname,"List   Addr = <%d> : Offset = <%d>\n", 
		 list, offset));

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

     buffer_size = atol (list -> buffer_ptr + MEM_BUFFER_USED + offset);

     data_offset = atol (list -> buffer_ptr + MEM_DATA_OFFSET + offset);
     
     status = MEMrow_size (list, offset);
     if (status != MEM_S_SUCCESS)
      {
        _MEMdebug ((fname,"Row Size : status = <0x%.8x>\n", status));
        ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     if (data_offset)
        list -> rows = (buffer_size - data_offset) / list -> row_size;
     else
        list -> rows = 0;

     _MEMdebug ((fname,"SUCCESSFUL : Rows = <%d>\n", list -> rows));

     return  (MEM_S_SUCCESS);
   }




