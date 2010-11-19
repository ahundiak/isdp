#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Write one piece of data for a column in a row of *
*                  of the buffer which already exists in the buffer.*
*                                                                   *
* Arguements       long MEMwrite_data (list, data, row_no, col_no)  *
*                       MEMptr  list;                               *
*                       char    *data;                              *
*                       long    row_no;                             *
*                       long    col_no;                             *
*                                                                   *
*                                                                   *
* Algorithm        For the column strip the information from the    *
*                  data and load it in the buffer. The max length of*
*                  the data is pre-defined in the format. The data  *
*                  padded with NULL if less than pre defined length *
*                  truncated to the length. The NULL and an ASCII-1.*
*                  is maintained the same.                          *
*                                                                   *
* Return Status    = 0                : Success                     *
*                                       (no of bytes written).      *
*                  MEM_E_NULL_LIST    : Failure (list is NULL).     *
*                  MEM_E_NULL_BUFFER  : Failure                     *
*                                       (list -> buffer_ptr is NULL)*
*                  MEM_E_NULL_ROWS    : Failure (no such row).      *
*                  MEM_E_NULL_COLUMNS : Failure (no such column).   *
*                  MEM_E_DATA_TYPE    : Bad Data Type               *
*                  MEM_E_MALLOC       : Malloc Failed               *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMbuild_array ()                                *
*                                                                   *
* History                                                           *
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                                                                   *
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 14, 1992                 *
*                   Comments     : If format is timestamp, set      *
*                                  length = 21. Previously set to   *
*                                  20.                              *
*                                                                   *
*********************************************************************
********************************************************************/

#include <stdio.h>
#include <ctype.h>
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

 long MEMwrite_data (list, buffer, row_no, col_no)
   MEMptr       list;
   char         *buffer;
   long         row_no, col_no;
   {
      register long x;
      long  length;
      long  status;
      char  **format, **data;
      char  temp [20], *temp1;
      static char *fname = "MEMwrite_data";


      _MEMdebug ((fname,"List Addr = <%d> : Buffer = <%d> : Row No = <%d> : Col No = <%d> \n", 
		  list, buffer, row_no, col_no));
      
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

      if (row_no < 1 || row_no > list -> rows)
       {
         status = MEM_E_NULL_ROWS;
         _MEMdebug ((fname,"Bad Row No : status = <0x%.8x>\n", status));
         ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      if (col_no < 1 || col_no > list -> columns)
       {
         status = MEM_E_NULL_COLUMNS;
         _MEMdebug ((fname,"Bad Column No : status = <0x%.8x>\n", status));
         ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      format = (char **) list -> format_ptr;
      data   = (char **) list -> data_ptr;
      
      if (! strncmp (format [col_no - 1], "integer", 7))
         length = 15;
      else if (! strncmp (format [col_no - 1], "smallint", 8))
         length = 15;
      else if (! strncmp (format [col_no - 1], "double", 6))
         length = 50;
      else if (! strncmp (format [col_no - 1], "real", 4))
         length = 50;
      else if (! strncmp (format [col_no - 1], "decimal", 7))
         length = 15;
      else if (! strncmp (format [col_no - 1], "timestamp", 9))
	 length = 21;
      else if (! strncmp (format [col_no - 1], "char", 4))  
       {
         sscanf (format [col_no - 1], "%5s%d", temp, &length);

         if (length <= 0)
          {
            status = MEM_E_DATA_TYPE;
            _MEMdebug ((fname,"Bad Data Type : status = <0x%.8x>\n",
            status));
            ERRload_struct(MEM,status,"",NULL);
            return (status);
          }

         length = length + 2;
       }
      else
       {
         status = MEM_E_DATA_TYPE;
         _MEMdebug ((fname,"Bad Data Type : status = <0x%.8x>\n", status));
         ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      temp1 = (char *) malloc (length + 1);
      if (! temp1)
       {
         status = MEM_E_MALLOC;
         _MEMdebug ((fname,"Malloc Failed : status = <0x%.8x>\n", status));
   	 ERRload_struct(MEM,status,"",NULL);
         return (status);
       }
      temp1 [0] = 0;

      if (buffer)
       {
         memset (temp1, 0, length);

         for (x = 0; x < length - 2; ++x)
          {
            if (x < strlen (buffer)) temp1 [x] = buffer [x];
          }
       }

      for (x = strlen (temp1); x > 0 && isspace (temp1 [x - 1]); --x)
        temp1 [x - 1] = 0;

/* KT - 10/7/91 Remove check for non-printable characters

      for (x = 0; x < strlen (temp1); ++x)
       {
          if (! isprint (temp1 [x]))
           {
            status = MEM_E_BAD_STRING;
            _MEMdebug ((fname,"Control Char : status = <0x%.8x>\n", status));
   	    ERRload_struct(MEM,status,"",NULL);
            return (status);
           }
       }
*/

      temp1 [length - 2] = '\0';
      temp1 [length - 1] = '\1';
         
      memcpy (data [((row_no - 1) * list -> columns) + col_no - 1],
              temp1, length);

      free (temp1);

      _MEMdebug ((fname,"SUCCESSFUL : status = <0x%.8x>\n", MEM_S_SUCCESS));
      return (MEM_S_SUCCESS);
   }      
