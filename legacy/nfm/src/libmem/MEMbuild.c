#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Build the column array, format array and data    *
*                  array for the memory structure.                  *
*                                                                   *
* Arguements       long MEMbuild_array (list)                       *
*                       MEMptr  list;                               *
*                                                                   *
* Algorithm        Set the first byte to indicate the structure     *
*                  information is for the first buffer and call     *
*                  MEMload_structure with 0 offset.                 *
*                                                                   *
* Return Status    MEM_E_NULL_LIST    : Failure.                    *
*                  MEM_E_NULL_BUFFER  : Failure.                    *
*                  MEM_E_INVALID_SIZE : Failure.                    *
*                  MEM_S_SUCCESS      : Success.                    *
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
*                   Date         : January 9, 1992                  *
*                   Comments     : Removed calls to MEMerror().     *
*                                  Added calls to ERRload_struct(). * 
*                                                                   *
*********************************************************************
********************************************************************/

#include <stdio.h>
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"           
#include "ERR.h"

 long MEMbuild_array (list)
   MEMptr   list;
   {
      static char *fname = "MEMbuild_array";
      long  status;
      long  buffer_size, x, atol ();

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

      buffer_size = atol (list -> buffer_ptr + MEM_BUFFER_USED);

      x = atol (list -> buffer_ptr + MEM_NO_BUFFER);
      
      if (buffer_size)
       {
          status = (int) MEMload_structure (list, 0);
          if (status != MEM_S_SUCCESS)
           {
             _MEMdebug ((fname,"Load Struct : status = <0x%.8x>\n",
			 status));
             ERRload_struct(MEM,status,"",NULL);
             return (status);
           }

          if (x)
           {

             *(list -> buffer_ptr + MEM_NO_BUFFER) = (char) 0x31;
             for( x = 1; x < MEM_INT_SIZE; ++x)
               *(list -> buffer_ptr + MEM_NO_BUFFER + x) = (char) 0x00;
             *(list -> buffer_ptr + MEM_REALLOC_SIZE - 1) = (char) 0x00;
           }
       }
      else 
       {
          status = MEM_E_INVALID_SIZE;
          _MEMdebug ((fname,"Bad Buffer Size : status = <0x%.8x>\n", 
							MEM_E_INVALID_SIZE));
          ERRload_struct(MEM,status,"",NULL);
          return (status);
       }

      _MEMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",MEM_S_SUCCESS));
      return (MEM_S_SUCCESS);
   }
