#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Builds the format array for the memory structure *
*                                                                   *
* Arguements       long MEMformat_list (list, offset)               *
*                       MEMptr  list;                               *
*                       long    offset;                             *
*                                                                   *
* Algorithm        Count the number of columns malloc space for the *
*                  pointer to these format array and load the       *
*                  address of the format of the buffer in the       *
*                  array.                                           *
*                                                                   *
* Return Status    MEM_E_MALLOC  : Failure                          *
*                  MEM_S_SUCCESS : SUCCESS                          *
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
           
 long MEMformat_list (list, offset)
   MEMptr   list;
   long     offset;
   {
     static char *fname= "MEMformat_list";
     long    status;
     char    **format;
     long    i, col_no;
     
     _MEMdebug ((fname," List   Addr = <%d> : Offset = <%d>\n", 
		 list, offset));

     i = offset + MEM_HEADER_END + 1;
   
     if (list -> format_ptr)    free (list -> format_ptr);

     list -> format_ptr = NULL;

     if (! list -> columns)
      {
        _MEMdebug ((fname, "NO COLUMNS : status = <0x%.8x>\n", MEM_S_SUCCESS));
        return (MEM_S_SUCCESS);
      }

     format = (char **) malloc (sizeof (char *) * list -> columns);
     if (! format)
      {
        status = MEM_E_MALLOC;
        _MEMdebug ((fname, "Malloc Failed : status = <0x%.8x>\n", status));
        ERRload_struct(MEM,status,"",NULL);
        return (status);
      }
     
     for (col_no = 0; col_no < list -> columns; ++col_no)
      {
       	while (list -> buffer_ptr [i] != '\1') i++; i++;        

        format [col_no] = list -> buffer_ptr + i;

      	while (list -> buffer_ptr [i] != '\1') i++; i++;      	
      }

     if (list -> buffer_ptr [i] != '\n') 
      {
        status = MEM_E_CORRUPTED_BUFFER;
        _MEMdebug ((fname, "Corrupted Buffer : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     list -> format_ptr = (char *) format;

     _MEMdebug ((fname,"SUCCESSFUL :status = <0x%.8x>\n", MEM_S_SUCCESS));
     return (MEM_S_SUCCESS);
   }
