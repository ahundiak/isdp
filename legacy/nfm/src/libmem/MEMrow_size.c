#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Load the structure information of the buffer.    *
*                                                                   *
* Arguments        long MEMrow_size (list, offset)                  *
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
*                   Comments     : Added call to ERRload_struct()   *
*                                  for non-success status.          *
*                                                                   *
*                                                                   *
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 14, 1992                 *
*                   Comments     : If format is timestamp, set j =  *
*                                  21. Previously set to 20.        *
*                                                                   *
*********************************************************************
********************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

 long MEMrow_size (list, offset)
   MEMptr   list;
   long     offset;
   {
     long   status, atol ();
     long   j, y;
     char   temp [25];
     char   **format;
     static char *fname = "MEMrow_size";

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

     status = MEMno_columns (list, offset);
     if (status != MEM_S_SUCCESS)
      {
        _MEMdebug ((fname,"No Columns : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);          
      }

     status = MEMformat_list (list, offset);
     if (status != MEM_S_SUCCESS)
      {
        _MEMdebug ((fname,"Format List : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);          
      }

     format = (char **) list -> format_ptr;

     list -> row_size = 1;

     for (y = 0; y < list -> columns; ++y)
      {
             if (!strcmp  (format [y], "integer" ))   j = 15;
        else if (!strcmp  (format [y], "smallint"))   j = 15;
        else if (!strcmp  (format [y], "double"  ))   j = 50;
        else if (!strcmp  (format [y], "real"    ))   j = 50;
        else if (!strcmp  (format [y], "decimal" ))   j = 15;
        else if (!strcmp  (format [y], "date"    ))   j = 15;
	else if (!strcmp  (format [y], "timestamp"))  j = 21;
        else if (!strncmp (format [y], "char",  4))
         {
            sscanf (format [y], "%5s%d", temp, &j);
   
            if (j <= 0)
             {
               status = MEM_E_DATA_TYPE;
               _MEMdebug ((fname,"Bad Data Type : status = <0x%.8x>\n",
               status));
   	       ERRload_struct(MEM,status,"",NULL);
               return (status);
             }

            j = j + 2;
         }
        else 
         {
           status = MEM_E_DATA_TYPE;
           _MEMdebug ((fname," Bad Data Type : status = <0x%.8x>\n",
           status));
           ERRload_struct(MEM,status,"",NULL);
           return (status);
         }
        list -> row_size = list -> row_size + j;
      }

     _MEMdebug ((fname,"SUCCESSFUL : Row Size = <%d>\n", list -> row_size));
     return (MEM_S_SUCCESS);
   }
