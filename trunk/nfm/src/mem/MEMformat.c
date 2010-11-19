/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Write the column name and the format information.*
*                                                                   *
* Arguements       long MEMwrite_format (list, col_name, format)    *
*                       MEMptr  list;                               *
*                       char    *col_name;                          *
*                       char    *format;                            *
*                                                                   *
* Algorithm        Check for the free space in the buffer to write  *
*                  the column name and the format information. Copy *
*                  the column name and pad it with a NULL, and      *
*                  ASCII - 1. Next copy the format information in   *
*                  the next 12 bytes and pad it also with a NULL    *
*                  and an ASCII - 1. Increment the columns in the   *
*                  structure and also change the row size in the    *
*                  structure.                                       *
*                                                                   *
* Return Status    >= 0              : Success (No of bytes written)*
*                  MEM_E_NULL_LIST   : Failure (List is NULL).      *
*                  MEM_E_NULL_BUFFER : Failure                      *
*                                      (List -> buffer_ptr is NULL).*
*                  MEM_E_DATA_TYPE   : Failure (Invalid Data Type). *
*                  MEM_E_DATA_WRITTEN: Failure (Data Written Once). *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                                                                   *
* Examples                                                          *
*                                                                   *
* Also See         MEMcheck_free_space ()                           *
*                                                                   *
* History                                                           *
*                   Developed by : Choudhary A Yarlagadda           *
*                   Date         : December 01 1987                 *
*                                                                   *
*                                                                   *
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 9, 1992                  *
*                   Comments     : Added call to ERRload_struct()   *
*                                  for non-success status           *
*                                                                   *
*                   Modified by  : Dudley Thomas                    *
*                   Date         : January 14, 1992                 *
*                   Comments     : See inline notes below.          *
*                                  				    *
*********************************************************************
********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <glib.h>

#include "ERR.h"
#include "MEM.h"
#include "DEBUG.h"

long MEMwrite_format (MEMptr list, char *column_name, char *format)
   {
     register    long    buffer_size, data_offset;
     register    long    total_buffer_size;

    static char  *fname = "MEMwrite_format";
    long    status, atol ();
    char    temp [25];
    long    buffer_size_old;
    long    y, size;

    _MEMdebug ((fname,"List Addr = <%d> : Col Name = <%s> : Format = <%s>\n", 
		list, column_name, format ));

    if (! list)
     {
       status = MEM_E_NULL_LIST;
       _MEMdebug ((fname," List Is Null : status = <0x%.8x>\n", status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    if (! list -> buffer_ptr)
     {
       status = MEM_E_NULL_BUFFER;
       _MEMdebug ((fname,"List -> Buff Is Null : status = <0x%.8x>\n",
		   status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    size = 0;

    if (column_name)
     {
       for (y = strlen (column_name); 
            y > 0 && isspace (column_name [y - 1]); --y)
         column_name [y - 1] = 0;

/* KT - 10/7/91 Remove check for non-printable characters

       for (y = 0; y < strlen (column_name); ++y)
       if (! isprint (column_name [y]))
        {
          status = MEM_E_BAD_STRING;
          _MEMdebug ((fname, "Control Char : status = <0x%.8x>\n", status));
          ERRload_struct(MEM,status,"",NULL);
          return (status);
        }
*/
     }

/* DT - 1/14/92 isspace (column_name [y -1]) changed to isspace (format [y-1]
                for 3.0.  This was causing format string overwrite.  Would not
	        be evident until 3.0 schema. */
 
    if (format)
     {
       for (y = strlen (format);
            y > 0 && isspace (format [y - 1]); --y)
         format [y - 1] = 0;

/* KT - 10/7/91 Remove check for non-printable characters

       for (y = 0; y < strlen (format); ++y)
        if (! isprint (format [y]))
         {
           status = MEM_E_BAD_STRING;
           _MEMdebug ((fname,"Control Char : status = <0x%.8x>\n",
		       status));
	   ERRload_struct(MEM,status,"",NULL);
           return (status);
         }
*/
     }  

/* DT - 1/14/92 If format is timestamp, set size to 21. Previously set to
   20 */

         if (! strcmp  (format, "integer" ))   size = 15;
    else if (! strcmp  (format, "smallint"))   size = 15;
    else if (! strcmp  (format, "double"  ))   size = 50;
    else if (! strcmp  (format, "real"    ))   size = 50;
    else if (! strcmp  (format, "decimal" ))   size = 15;
    else if (! strcmp  (format, "date"    ))   size = 15;
    else if (! strcmp  (format, "timestamp"))  size = 21;
    else if (! strncmp (format, "char(", 5))
     {
       sscanf (format, "%5s%d", temp, &size);

       if (size <= 0)
        {
          status = MEM_E_DATA_TYPE;
          _MEMdebug ((fname,"Bad Data Type : status = <0x%.8x>\n",
		      status));
          ERRload_struct(MEM,status,"",NULL);
          return (status);
        }

       size = size + 2;
     }
    else 
     {
       status = MEM_E_DATA_TYPE;
       _MEMdebug ((fname, "Bad Data Type : status = <0x%.8x>\n",status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    y = 1;  total_buffer_size = 0; buffer_size = 0;

    while (y)
     {
       total_buffer_size = total_buffer_size + buffer_size;

       y = atol (list -> buffer_ptr + total_buffer_size + MEM_NO_BUFFER);

       buffer_size = atol (list -> buffer_ptr + total_buffer_size + MEM_BUFFER_USED);

       data_offset = atol (list -> buffer_ptr + total_buffer_size + MEM_DATA_OFFSET);
     }

    if (data_offset)
     {
       status = MEM_E_DATA_WRITTEN;
       _MEMdebug ((fname, "Data Is Written : status = <0x%.8x>\n",status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    buffer_size_old = buffer_size;

    status = MEMcheck_free_space (list, strlen (column_name) + 18);
    if (status != MEM_S_SUCCESS)
     {
       _MEMdebug ((fname,"Check Free Space : status = <0x%.8x>\n",
       status));
       ERRload_struct(MEM,status,"",NULL);
       return (status);
     }

    memcpy (list -> buffer_ptr + total_buffer_size + buffer_size - 1,
            column_name, strlen (column_name));

    buffer_size = strlen (column_name) + buffer_size;

    *(list -> buffer_ptr + total_buffer_size + buffer_size - 1) = (char) 0x00;

    buffer_size = buffer_size + 1;

    *(list -> buffer_ptr + total_buffer_size + buffer_size - 1) = (char) 0x01;

    buffer_size = buffer_size + 1;

    memcpy (list -> buffer_ptr + total_buffer_size + buffer_size - 1,
            format, strlen (format));
/*
    for (count = strlen (format);  count < 13; ++count)
      memcpy (list -> buffer_ptr + total_buffer_size + buffer_size +
              count - 1, "\0", 1);
*/
    buffer_size = buffer_size + 13;

    *(list -> buffer_ptr + total_buffer_size + buffer_size - 1) = (char) 0x00;

    buffer_size = buffer_size + 1;

    *(list -> buffer_ptr + total_buffer_size + buffer_size - 1) = (char) 0x01;

    buffer_size = buffer_size + 1;

    *(list -> buffer_ptr + total_buffer_size + buffer_size - 1) = (char) 0x0a;

    sprintf (temp, "%d", buffer_size);
      
    memcpy (list -> buffer_ptr + total_buffer_size + MEM_BUFFER_USED,
            temp, strlen (temp));

/*
    for (count = strlen (temp); count < MEM_INT_SIZE; ++count)
      memcpy (list -> buffer_ptr + total_buffer_size + MEM_BUFFER_USED +
              count, "\0", 1);
*/
    *(list -> buffer_ptr + total_buffer_size + MEM_DATA_OFFSET - 1) = (char) 0x00;

    list -> row_size = list -> row_size + size;
    list -> columns  = list -> columns + 1;

    status = buffer_size - buffer_size_old;

    _MEMdebug ((fname,"SUCCESSFUL : Bytes Written = <0x%.8x>\n", status));
    return (MEM_S_SUCCESS);
  }
