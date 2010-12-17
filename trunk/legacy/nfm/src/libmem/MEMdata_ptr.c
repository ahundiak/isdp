#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Builds the data array for the memory structure   *
*                                                                   *
* Arguements       long MEMdata_list (list, offset)                 *
*                       MEMptr  list;                               *
*                       long    offset;                             *
*                                                                   *
* Algorithm        Count the number of rows malloc space for the    *
*                  pointer to the data array and load the address   *
*                  of the column names of the buffer in the array.  *
*                                                                   *
* Return Status    MEM_E_MALLOC  : failure                          *
*                  MEM_S_SUCCESS : success                          *
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

 long  MEMdata_list (list, offset)
   MEMptr   list;
   long     offset;
   {
     long    status, atol ();
     char    **data;
     long    i, col_no, row_no, count;
     long    data_offset;
     static  char *fname = "MEMdata_list";

     _MEMdebug ((fname," List   Addr = <%d> : Offset = <%d>\n", 
		 list, offset));

     if (list -> data_ptr) free (list -> data_ptr);

     list -> data_ptr = NULL;

     if (! (list -> columns * list -> rows))
      {
        _MEMdebug ((fname,"NO COLUMNS : NO ROWS FOUND IN BUFFER :  status = <0x%.8x>\n", MEM_S_SUCCESS));
        return (MEM_S_SUCCESS);
      }       

     data = (char **) malloc (sizeof (char *) * 
                             (list -> columns * list -> rows));
     if (! data)
      {
        status = MEM_E_MALLOC;
        _MEMdebug ((fname," Malloc Failed : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     data_offset = atol (list -> buffer_ptr + MEM_DATA_OFFSET + offset);
     
     i = data_offset + offset;
     
     for (row_no = 0; row_no < list -> rows; ++row_no)
      {
        count = row_no * list -> columns;

        for (col_no = 0; col_no < list -> columns; ++col_no)
         {
           data [count + col_no] = list -> buffer_ptr + i;
           while (list -> buffer_ptr [i] != '\1') i++; i++; 
         }

        if (list -> buffer_ptr [i] != '\n')
         {
           status = MEM_E_CORRUPTED_BUFFER;
           _MEMdebug ((fname, " Corrupted Buffer : status = <0x%.8x>\n", 
		       status));
   	   ERRload_struct(MEM,status,"",NULL);
           return (status);
         }

        i++;
      }

     list -> data_ptr = (char *) data;

     _MEMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", MEM_S_SUCCESS));
     return (MEM_S_SUCCESS);
   }
