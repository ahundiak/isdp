#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Free the memory previously allocated.            *
*                                                                   *
* Arguements       long MEMclose (list)                             *
*                       MEMptr  *list;                              *
*                                                                   *
* Algorithm        Check if the pointers are not NULL and free them *
*                  up. And set the list to NULL.                    *
*                                                                   *
* Return Status     MEM_S_SUCCESS   : Success.                      *
*                   MEM_E_NULL_LIST : Failure (list points to NULL).*
*                                    (This was changed. See history *
(                                     below.)                       * 
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
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 9, 1992                  *
*                   Comments     : Modified to return MEM_S_SUCCESS *
*                                  if list points to null.          *
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

 long MEMclose (list)
   MEMptr  *list;
   {
     static char *fname = "MEMclose";
     long     status;
            
     _MEMdebug ((fname," List Addr = <%d>\n", *list));

     if (! (*list)) 
      {
        status = MEM_E_NULL_LIST;
        _MEMdebug ((fname,"List Is Null : status = <0x%.8x>\n", status));
        return (MEM_S_SUCCESS);
      }

     _MEMdebug ((fname,"Column Ptr = <%d> : Format Ptr = <%d> : Data Ptr = <%d> : Buffer Ptr = <%d> : List Ptr = <%d>\n", 
		 (*list) -> column_ptr,
		 (*list) -> format_ptr,
		 (*list) -> data_ptr,
		 (*list) -> buffer_ptr,
		 *list));

     if ((*list) -> column_ptr)  free ((*list) -> column_ptr);
     (*list) -> column_ptr = NULL;

     if ((*list) -> format_ptr)  free ((*list) -> format_ptr);
     (*list) -> format_ptr = NULL;

     if ((*list) -> data_ptr)    free ((*list) -> data_ptr);
     (*list) -> data_ptr = NULL;

     if ((*list) -> buffer_ptr)  free ((*list) -> buffer_ptr);
     (*list) -> buffer_ptr = NULL;

     if ((*list))                free (*list);
     *list = NULL;
            
     _MEMdebug((fname,"SUCCESSFUL : status = <0x%.8x>\n", MEM_S_SUCCESS));
     return (MEM_S_SUCCESS); 
  }



