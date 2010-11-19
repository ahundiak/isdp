#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Allocate and open a section of memory.           *
*                                                                   *
* Arguements       long MEMopen (list, size)                        *
*                       MEMptr  *list;                              *
*                       long    size;                               *
*                                                                   *
* Algorithm        This routine allocates the memory to the pointer *
*                  passed to the routine, and allocates memory equal*
*                  to the size to the buffer_ptr of the structure.  *
*                  Initializes all the fields of the structure.     *
*                  Loads the realloc size, used buffer size and data*
*                  offset in the first 42 bytes of the buffer_ptr to*
*                  size, 42, and 0 respectively. The first byte of  *
*                  the buffer_ptr is set to zero.                   *
*                                                                   *
* Return Status     MEM_S_SUCCESS : Success.                        *
*                   MEM_E_MALLOC  : Failure.                        *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples         status = MEMopen (&list, 512);                   *
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
#include "MSGstruct.h"  /* Added by B.W. due to MEMmsg_ptr */
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

/* the following global declaration put in by B.W. 1/15/92 to get 
   images to link.  MEMmsg_ptr was defined in MEMerror.c but the file has
   been removed.  Until all references to MEMmsg_ptr are iliminated This will
   need to be here.                            */

MSGptr   MEMmsg_ptr = {0, "/dev/console", 0, ""};

   long MEMopen (list, size)
     MEMptr       *list;
     long          size;
     {
       long      status;
       MEMptr    temp;
       char      str [25];
       static    char *fname = "MEMopen";

       _MEMdebug ((fname,"List Addr = <%d> : Size = <%d>\n", 
		   *list, size));
       
       /* malloc the MEMptr */

       temp = (MEMptr) malloc (sizeof (struct MEMbuffer_struct));
       if (! temp) 
        {
          status = MEM_E_MALLOC;
          _MEMdebug ((fname,"Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       /* malloc the buffer_ptr of size bytes, minimum of 42 bytes */

       if (size < 44) size = MEM_SIZE;

       temp -> buffer_ptr = (char *) malloc (size);
       if (! temp -> buffer_ptr)
        {
          status = MEM_E_MALLOC;
          _MEMdebug ((fname,"Malloc Failed : status = <0x%.8x>\n", status));
          ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       memset (temp -> buffer_ptr, '\0', size);

       /* Initialize all the other fields of the structure */
       
       temp -> row_size    = 1;
       temp -> rows        = NULL;
       temp -> columns     = NULL;
       temp -> format_ptr  = NULL;
       temp -> column_ptr  = NULL;
       temp -> data_ptr    = NULL;

       /* set the bytes 0 - 9 in buffer_ptr to zero. */
        *(temp->buffer_ptr + MEM_NO_BUFFER) = (char ) 0x30;

       /* load 0 in the 30-39 bytes for data offset */
        *(temp->buffer_ptr + MEM_DATA_OFFSET) =      0x30;

       /* load size in the 10 - 19 bytes for realloc size */
       sprintf (str, "%d", size);
       memcpy (temp -> buffer_ptr + MEM_REALLOC_SIZE, str, strlen (str));
 
       /* load 41 in the 20-29 bytes for buffer used size */
       sprintf (str, "%d", MEM_HEADER_END + 2);
       memcpy (temp -> buffer_ptr + MEM_BUFFER_USED, str, strlen (str));

       /* load 'ASCII 1' and new line in the 40, 41 bytes  */
         *(temp->buffer_ptr + MEM_HEADER_TERM) = (char ) 0x01;
         *(temp->buffer_ptr + MEM_HEADER_END) = (char) 0x0a;
         *(temp->buffer_ptr + MEM_HEADER_END + 1) = (char) 0x0a;

       *list = temp;

       _MEMdebug ((fname,"SUCCESSFUL : MEM Addr = <%d>\n", *list));
       return (MEM_S_SUCCESS); 
     }
