#include "machine.h"
/*
	Author: Reddy 
	Purpose: Alternative function to MEMbuild_array
	
	(1) Avoids writing into the buffer->ptr of list
	(2) Consolidates all the functions into two functions

        Modified by : Dudley Thomas
	Date        : January 9, 1992
        Comments    : Removed calls to MEMerror() and added calls to 
		      ERRload_struct() for non-success statuses.

        Modified by : Dudley Thomas
	Date        : January 14, 1992
        Comments    : If format is timestamp, set j = 21. Previously set
		      to 20. 
*/

#include <stdio.h>
#include "MEMstruct.h"
#include "MEMbuf_def.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "ERR.h"

 long MEMqlu_build_array (list)
   MEMptr   list;
   {
      long  MEMqlu_load_structure();
      long  status;
      long  buffer_size, x, atol ();
      char  temp [25];
      static char *fname="MEMqlu_build_array";

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

      memcpy (temp, list -> buffer_ptr + MEM_BUFFER_USED, MEM_INT_SIZE);
      buffer_size = atol (temp);

      memcpy (temp, list -> buffer_ptr + MEM_NO_BUFFER, MEM_INT_SIZE);
      x = atol (temp);
      
      if (buffer_size)
       {
          status = (long) MEMqlu_load_structure (list, 0);
          if (status != MEM_S_SUCCESS)
           {
             _MEMdebug ((fname,"Qlu Load Struct : status = <0x%.8x>\n",
			 status));
             ERRload_struct(MEM,status,"",NULL);
             return (status);
           }
/*
          if (x)
           {
             sprintf (temp, "%d", 1);

             memcpy (list -> buffer_ptr + MEM_NO_BUFFER, temp, strlen (temp));

             for (x = strlen (temp); x < MEM_INT_SIZE; ++x)
               memcpy (list -> buffer_ptr + MEM_NO_BUFFER + x, "\0", 1);
          
             memcpy (list -> buffer_ptr + MEM_REALLOC_SIZE - 1, "\0", 1);
           }
*/
       }
      else 
       {
         status = MEM_E_INVALID_SIZE;
         _MEMdebug ((fname,"Bad Buffer Size : status = <0x%.8x>\n", status));
         ERRload_struct(MEM,status,"",NULL);
         return (status);
       }

      _MEMdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n",MEM_S_SUCCESS));
      return (MEM_S_SUCCESS);
   }

 long MEMqlu_load_structure (list, offset)
   MEMptr   list;
   long     offset;
   {
     long   status, atol ();
     long   data_offset, buffer_size;
     char   temp [25], **format, **column, **data;
     char   **formatx;
     char   t_str[40];
     long   col_no,row_no = 0;
     long   i, j, k = 0; 
     int    y,count;
     static char *fname = "MEMqlu_load_structure";

     _MEMdebug ((fname," List   Addr = <%d> : Offset = <%d>\n", 
		 list, offset  ));

     memcpy (temp, list -> buffer_ptr + MEM_BUFFER_USED + offset,
             MEM_INT_SIZE);
     buffer_size = atol (temp);

     memcpy (temp, list -> buffer_ptr + MEM_DATA_OFFSET + offset,
             MEM_INT_SIZE);
     data_offset = atol (temp);

	/* figure out the no of columns */

     j = 0;

     if (data_offset)  k = data_offset + offset;
     else              k = buffer_size + offset;

     for (i = MEM_HEADER_END + offset + 1;
          i < k && list -> buffer_ptr [i] != '\n'; ++i)
      {
        if (list -> buffer_ptr [i] == '\1')  j = j + 1;
      }

     if (j)
      {
         if (j % 2) 
          {
            status = MEM_E_CORRUPTED_BUFFER;
            _MEMdebug ((fname, "No Col != No For : status = <0x%.8x>\n",
			status));
            ERRload_struct(MEM,status,"",NULL);
            return (status);          
          }

         list -> columns = j / 2;
      }
     else
        list -> columns = 0;
     
     _MEMdebug ((fname," Columns = <%d>\n", list -> columns));

	/* set up the format vector. To find row size later */

     i = offset + MEM_HEADER_END + 1;
   
 	/* free the previous vector */

     if (list -> format_ptr)    free (list -> format_ptr);

     list -> format_ptr = NULL;

     if (! list -> columns)
      {
        _MEMdebug ((fname, "NO COLUMNS : status = <0x%.8x>\n", 
		    MEM_S_SUCCESS));
        return (MEM_S_SUCCESS);
      }

     format = (char **) malloc (sizeof (char *) * list -> columns);
     if (! format)
      {
        status = MEM_E_MALLOC;
        _MEMdebug ((fname,"Malloc Failed : status = <0x%.8x>\n", status));
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
        _MEMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     list -> format_ptr = (char *) format;

	/* end of format vector */

	/* figure out row size */

     formatx = (char **) list -> format_ptr;

     list -> row_size = 1;

     for (y = 0; y < list -> columns; ++y)
      {
             if (!strcmp  (formatx [y], "integer" ))   j = 15;
        else if (!strcmp  (formatx [y], "smallint"))   j = 15;
        else if (!strcmp  (formatx [y], "double"  ))   j = 50;
        else if (!strcmp  (formatx [y], "real"    ))   j = 50;
        else if (!strcmp  (formatx [y], "decimal" ))   j = 15;
        else if (!strcmp  (formatx [y], "date"    ))   j = 15;
        else if (!strcmp  (formatx [y], "timestamp"))  j = 21;
        else if (!strncmp (formatx [y], "char",  4))
         {
	    strcpy(t_str,formatx[y]);
            sscanf (t_str, "%5s%d", temp, &j);
   
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

      /* end of row size */

     if (data_offset)
        list -> rows = (buffer_size - data_offset) / list -> row_size;
     else
        list -> rows = 0;

     _MEMdebug ((fname,"Row Size = <%d> : Rows = <%d>\n", 
		 list->row_size, list -> rows));

     /* end of no of rows */

     /* load the column array address */

     i = offset + MEM_HEADER_END + 1; 
    
	/* free the previous vector */

     if (list -> column_ptr)     free (list -> column_ptr);
     
     list -> column_ptr = NULL;

     if (! list -> columns)
      {
        _MEMdebug((fname,"NO COLUMNS : status  = <0x%.8x>\n", MEM_S_SUCCESS));
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
        _MEMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

     list -> column_ptr = (char *) column;
  
      /* end of column vector */

     /* load the data array address */

     if (list -> data_ptr) free (list -> data_ptr);

     list -> data_ptr = NULL;

     if (! (list -> columns * list -> rows))
      {
        _MEMdebug ((fname,"NO DATA : status = <0x%.8x>\n", MEM_S_SUCCESS));
        return (MEM_S_SUCCESS);
      }       

     data = (char **) malloc (sizeof (char *) * 
                             (list -> columns * list -> rows));
     if (! data)
      {
        status = MEM_E_MALLOC;
        _MEMdebug ((fname,"Malloc Failed : status = <0x%.8x>\n", status));
	ERRload_struct(MEM,status,"",NULL);
        return (status);
      }

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
           _MEMdebug ((fname,"Corrupted Buffer : status = <0x%.8x>\n", 
		       status));
   	   ERRload_struct(MEM,status,"",NULL);
           return (status);
         }

        i++;
      }

     list -> data_ptr = (char *) data;
     _MEMdebug ((fname," SUCCESSFUL : status = <0x%.8x>\n", MEM_S_SUCCESS));
     return (MEM_S_SUCCESS);
   }



