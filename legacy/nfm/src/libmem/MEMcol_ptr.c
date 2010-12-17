#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Builds the column array for the memory structure *
*                                                                   *
* Arguements       long MEMcolumn_list (list, offset)               *
*                       MEMptr  list;                               *
*                       long    offset;                             *
*                                                                   *
* Algorithm        Count the number of columns malloc space for the *
*                  pointer to these column array and load the       *
*                  address of the column names of the buffer in the *
*                  array.                                           *
*                                                                   *
* Return Status    MEM_E_MALLOC  : failure                          *
*                  MEM_S_SUCCESS : Success.                         *
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
           
 long MEMcolumn_list (list, offset)
   MEMptr   list;
   long     offset;
   {
     long    status;
     char    **column;
     long    i, col_no;
     static  char *fname = "MEMcolumn_list";

     _MEMdebug ((fname,"List   Addr = <%d> : Offset = <%d>\n", 
		 list, offset));

     i = offset + MEM_HEADER_END + 1; 
    
     if (list -> column_ptr)     free (list -> column_ptr);
     
     list -> column_ptr = NULL;

     if (! list -> columns)
      {
        _MEMdebug ((fname,"Column Ptr is NULL : status = <0x%.8x>\n", 
		    MEM_S_SUCCESS));
        return (MEM_S_SUCCESS);      
      }          
  
     column = (char **) malloc (sizeof (char *) * list -> columns);
     if (! column)
      {
        status = MEM_E_MALLOC;
        _MEMdebug ((fname,"Malloc Failed : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     for (col_no = 0; col_no < list -> columns; ++col_no)
      {
        column [col_no] = list -> buffer_ptr + i;

      	while (list -> buffer_ptr [i] != '\1') i++; i++;        
      	while (list -> buffer_ptr [i] != '\1') i++; i++;      	
      }

     if (list -> buffer_ptr [i] != '\n')
      {
        status = MEM_E_CORRUPTED_BUFFER;
        _MEMdebug ((fname, "Corrupted Buffer : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     list -> column_ptr = (char *) column;

     _MEMdebug ((fname, "SUCCESSFUL :status = <0x%.8x>\n", MEM_S_SUCCESS));
     return (MEM_S_SUCCESS);
   }
