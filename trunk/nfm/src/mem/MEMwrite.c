#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Write one row of data in the buffer.             *
*                                                                   *
* Arguements       long MEMwrite (list, data)                       *
*                       MEMptr  list;                               *
*                       char    *data;                              *
*                                                                   *
* Algorithm        For each column strip the information from the   *
*                  data and load it in the buffer. The max length of*
*                  the data is pre-defined in the format. The data  *
*                  padded with NULL if less than pre defined length *
*                  truncated to the length. Now the data is padded  *
*                  with a NULL and an ASCII - 1. The end of each row*
*                  is marked with a new line. Same is done if the   *
*                  data offset is zero to mark the begining of the  *
*                  data zone and the data offset is loaded. Each    *
*                  time the row of data is written into the buffer  *
*                  the buffer size is incremented to represent the  *
*                  correct used buffer size.                        *
*                                                                   *
* Return Status     > 0               : Success.                    *
*                   MEM_E_NULL_LIST   : Failure (list is NULL).     *
*                   MEM_E_NULL_BUFFER : Failure                     *
*                                       (list -> buffer_ptr is NULL)*
*                   MEM_E_LESS_DATA   : Failure (insufficient data).*
*                   MEM_E_DATA_TYPE   : Failure (Bad Data Type).    *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMformat_list ()                                *
*                  MEMcheck_free_space ()                           *
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
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 14, 1992                 *
*                   Comments     : Removed unecessary calls to      *
*                                  strlen(). Added variables        *
*                                  temp_len, temp_str_len, and      *
*                                  buffer_len to support this.      *
*                                  Also, if format is timestamp,    *
*                                  set length to 21. Previously set *
*                                  to 20.                           *
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

 long MEMwrite (list, buffer)
   MEMptr        list;
   char         *buffer;
   {
      long  status, atol ();
      long  count, x, y, b_count, b_count_old;
      char  **format, *temp_str, temp [25];
      long  length;      
      long  buffer_size, data_offset, total_buffer_size;
      long  buffer_size_old, temp_mark;
      static char *fname = "MEMwrite";
      int   temp_len, temp_str_len, buffer_len;

      _MEMdebug ((fname,"List Addr = <%d>  : Buffer = <%d>\n", 
		  list, buffer));
      
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

      y = 1; total_buffer_size = 0; buffer_size = 0;

      while (y)
       {
         total_buffer_size = total_buffer_size + buffer_size;

         y = atol (list -> buffer_ptr + total_buffer_size + MEM_NO_BUFFER);

         buffer_size = atol (list -> buffer_ptr + total_buffer_size + MEM_BUFFER_USED);

         data_offset = atol (list -> buffer_ptr + total_buffer_size + MEM_DATA_OFFSET);
       }

      if (! data_offset)
       {
          status = MEMcheck_free_space (list, 2);
          if (status != MEM_S_SUCCESS)
           {
             _MEMdebug ((fname,"Check Free Space : status = <0x%.8x>\n",
             status));
             ERRload_struct(MEM,status,"",NULL);
             return (status);
           }
      
         sprintf (temp, "%d", buffer_size);

         temp_len = strlen (temp);
         memcpy (list -> buffer_ptr + total_buffer_size + MEM_DATA_OFFSET,
                 temp, temp_len);

         for (y = temp_len; y < MEM_INT_SIZE; ++y)
           *(list -> buffer_ptr + total_buffer_size + MEM_DATA_OFFSET + y ) = (char) 0x00;

         *(list -> buffer_ptr + total_buffer_size + MEM_HEADER_TERM - 1) = (char) 0x00;
       }       	         

      status = MEMcheck_free_space (list, list -> row_size + 1);
      if (status != MEM_S_SUCCESS)
       {
         _MEMdebug ((fname,"Check Free Space : status = <0x%.8x>\n", status));
         ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      if (list -> data_ptr)    free (list -> data_ptr);
      if (list -> column_ptr)  free (list -> column_ptr);
      if (list -> format_ptr)  free (list -> format_ptr);
      
      list -> data_ptr   = NULL;
      list -> column_ptr = NULL;
      list -> format_ptr = NULL;

      status = MEMno_rows (list, total_buffer_size);
      if (status != MEM_S_SUCCESS)
       {
         _MEMdebug ((fname,"No Rows : status = <0x%.8x>\n", status));
         ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      buffer_size_old = buffer_size;

      format = (char **) list -> format_ptr;

      b_count = 0; b_count_old = 0;

      for (x = 0; x < list -> columns; ++x)
       {
          if (x && (b_count_old == b_count))
           {
              status = MEM_E_LESS_DATA;
              _MEMdebug ((fname,"Too Little Data : status = <0x%.8x>\n",
              status));
              ERRload_struct(MEM,status,"",NULL);
              return (status);
           }

          b_count_old = b_count;

               if (! strncmp (format [x], "integer",  7))  length = 15;
          else if (! strncmp (format [x], "smallint", 8))  length = 15;
       	  else if (! strncmp (format [x], "double",   6))  length = 50;
       	  else if (! strncmp (format [x], "real",     4))  length = 50;
       	  else if (! strncmp (format [x], "decimal",  7))  length = 15;
	  else if (! strncmp (format [x], "timestamp", 9)) length = 21;
      	  else if (! strncmp (format [x], "char",     4))  
           {
	          sscanf (format [x], "%5s%d", temp, &length);

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
              _MEMdebug ((fname,"Bad Data Type : status = <0x%.8x>\n",
              status));
              ERRload_struct(MEM,status,"",NULL);
              return (status);
           }

          temp_str = (char *) malloc (length + 1);
          if (! temp_str)
           {
              status = MEM_E_MALLOC;
              _MEMdebug ((fname,"Malloc Failed : status = <0x%.8x>\n",
              status));
              ERRload_struct(MEM,status,"",NULL);
              return (status);
           }
          temp_str [0] = 0;

          count = 0;

          memset (temp_str, 0, length);

          temp_mark = 0;

          buffer_len = strlen (buffer);
          while (b_count < buffer_len)
           {
             if (buffer [b_count] == '\1')
              {
                temp_mark = 1;
                break;
              }
             else if (buffer [b_count] == '\0')
              {
                break;
              }

             if (count < length - 2)
              {
                temp_str [count] = buffer [b_count];
                count++; 
              }
             b_count++;
           }

          temp_str [count] = '\0';

          for (count = strlen (temp_str);
               count > 0 && isspace (temp_str [count - 1]);
               --count)
            temp_str [count - 1] = 0;

/* KT - 10/7/91 Remove check for non-printable characters

          for (count = 0; count < strlen (temp_str); ++count)
            if (! isprint (temp_str [count]))
             {
               status = MEM_E_BAD_STRING;
               _MEMdebug ((fname,"Control Char : status = <0x%.8x>\n",
               status));
              ERRload_struct(MEM,status,"",NULL);
               return (status);
             }
*/

          temp_str_len = strlen (temp_str);
          memcpy (list -> buffer_ptr + total_buffer_size + buffer_size,
                  temp_str, temp_str_len);
       	 
          for (count = temp_str_len; count < length - 2; ++count)
            *(list -> buffer_ptr + total_buffer_size + buffer_size +
                    count) = (char) 0x00;
       	  
          *(list -> buffer_ptr + total_buffer_size + buffer_size +
                  length - 2) = (char) 0x00;
          *(list -> buffer_ptr + total_buffer_size + buffer_size +
                  length - 1) = (char) 0x01;

          buffer_size = buffer_size + length;
       	 
          free (temp_str);

          if (temp_mark) b_count++;      
       }

      if (b_count < strlen (buffer))
       {
         status = MEM_E_EXTRA_DATA;
         _MEMdebug ((fname,"Too Much Data : status = <0x%.8x>\n", status));
         ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      *(list -> buffer_ptr + total_buffer_size + buffer_size) = (char) 0x0a;
      buffer_size = buffer_size + 1;

      list -> rows = list -> rows + 1;

      sprintf (temp, "%d", buffer_size);

      temp_len = strlen (temp);
      memcpy (list -> buffer_ptr + total_buffer_size + MEM_BUFFER_USED,
              temp, temp_len);

      for (count = temp_len; count < MEM_INT_SIZE; ++count)
        * (list -> buffer_ptr + total_buffer_size + 
                MEM_BUFFER_USED + count) = (char) 0x00;

      *(list -> buffer_ptr + total_buffer_size + 
              MEM_DATA_OFFSET - 1) = (char ) 0x00;

      status = buffer_size - buffer_size_old;

      if (status != list -> row_size)
       {
         status = MEM_E_BAD_DATA_WRITTEN;
         _MEMdebug ((fname,"Bad Data Written : status = <0x%.8x>\n", status));
         ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      _MEMdebug ((fname,"SUCCESSFUL : Bytes Written = <%d> : Row Size = <%d>\n", 
		  status, list->row_size));

      return (MEM_S_SUCCESS);
   }      
