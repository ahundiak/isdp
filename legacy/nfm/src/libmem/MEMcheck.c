#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Check to see the free space in buffer.           *
*                                                                   *
* Arguements       long MEMcheck_free_space (list, delta)           *
*                       MEMptr  list;                               *
*                       long    delta;                              *
*                                                                   *
* Algorithm        Check for the free space of size delta in the    *
*                  buffer. If present just return else realloc the  *
*                  buffer to accomodate the new data with each      *
*                  realloc with alloc size added to the buffer size *
*                  if realloc was done set the format array pointer *
*                                                                   *
* Return Status     MEM_S_SUCCESS     : Success.                    *
*                   MEM_E_NULL_LIST   : Failure.                    *
*                   MEM_E_NULL_BUFFER : Failure.                    *
*                   MEM_E_MALLOC      : Failure.                    *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMformat_list ()                                *
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
       	       
 long MEMcheck_free_space (list, delta)
   MEMptr   list;
   long     delta;
   {
      long      status, atol ();
      long      total_buffer_size, total_allocated;
      long      buffer_size, size, temp_size;
      long      x, y;
      char      *temp_ptr;
      static    char *fname="MEMcheck_free_space";

      _MEMdebug ((fname,"List Addr = <%d>  : Delta = <%d>", 
		  list, delta ));
      
      if (! list)
       {
         status = MEM_E_NULL_LIST;
         _MEMdebug ((fname,"List Is Null : status = <0x%.8x>\n", status));
	 ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      if (! list -> buffer_ptr)
       {
         _MEMdebug ((fname,"List -> Buffer Is Null : status = <0x%.8x>\n",
		     status));
	 ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      size = atol (list -> buffer_ptr + MEM_REALLOC_SIZE);

      y = 1; total_buffer_size = 0; buffer_size = 0;

      while (y)
       {
          buffer_size = atol (list -> buffer_ptr + total_buffer_size + MEM_BUFFER_USED);

          y = atol (list -> buffer_ptr + total_buffer_size + MEM_NO_BUFFER);

          total_buffer_size = total_buffer_size + buffer_size;
       }

      x = total_buffer_size % size;

      if (x)   total_allocated = (total_buffer_size - x) + size;
      else     total_allocated = total_buffer_size;

      _MEMdebug((fname,"total buf size %d : total allocated size %d\n",
		 total_buffer_size, total_allocated));

      if (delta + total_buffer_size > total_allocated)
       {
         temp_size = 0;

         while ((delta + total_buffer_size) > (total_allocated + temp_size))
           temp_size = temp_size + size;

         _MEMdebug((fname,"temp_size %d\n",temp_size));

         temp_ptr = (char *) malloc (total_allocated + temp_size);
/*  
         list -> buffer_ptr = (char *) realloc (list -> buffer_ptr, 
       	                      total_allocated + temp_size);
*/
         if (! temp_ptr) 
          {
            status = MEM_E_MALLOC;
            _MEMdebug ((fname,"Malloc Failed : status = <0x%.8x>\n",
			status));
	    ERRload_struct(MEM,status,"",NULL);
            return (status);
          }

         memset (temp_ptr, 0, total_allocated + temp_size);

         memcpy (temp_ptr, list -> buffer_ptr, total_allocated);

         free (list -> buffer_ptr);

         list -> buffer_ptr = temp_ptr;

         if (list -> column_ptr) free (list -> column_ptr);
         if (list -> format_ptr) free (list -> format_ptr);
         if (list -> data_ptr  ) free (list -> data_ptr);

         list -> column_ptr = NULL;
         list -> format_ptr = NULL;
         list -> data_ptr   = NULL;
       }

      _MEMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n",MEM_S_SUCCESS));
      return (MEM_S_SUCCESS);
   }
