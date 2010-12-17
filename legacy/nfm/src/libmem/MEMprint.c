#include "machine.h"
/********************************************************************
*********************************************************************
*                                                                   *
*                                                                   *
* Abstract         Allocate and open a section of memory.           *
*                                                                   *
* Arguements       void MEMprint_buffer (name, list, output_id)     *
*                       char    *name;                              *
*                       MEMptr  list;                               *
*                       char    *output_id;                         *
*                                                                   *
*                  void MEMprint_buffers (name, list, output_id)    *
*                       char    *name;                              *
*                       MEMptr  list;                               *
*                       char    *output_id;                         *
*                                                                   *
*                  void MEMprint_array (name, list, output_id)      *
*                       char    *name;                              *
*                       MEMptr  list;                               *
*                       char    *output_id;                         *
*                                                                   *
* Algorithm                                                         *
*                                                                   *
* Return Status    Void.                                            *
*                                                                   *
* Bugs             No known bugs.                                   *
*                                                                   *
* Notes            Also see the MEMstruct.h for MEMptr description. *
*                  If output_id is NULL the output is diverted to   *
*                  stdout else it is diverted to the file by the    *
*                  name of output_id.                               *
*                                                                   *
* Examples                                                          *
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

 MEMprint_buffer (name, list, file)
  char         *name;
  MEMptr       list;
  char         *file;
  {
     static char *fname = "MEMprint_buffer";
     long  count = NULL, atol ();
     char  temp [25];
     long  buf_size  = 0, alloc_size = 0, data_offset = 0;
     FILE  *out_file, *fopen ();
     long  x,  y = 0;
     long  size = 0;     

     _MEMdebug ((fname,"Name = <%s> : List Addr = <%d> : File Name = <%s>\n", 
		 name, list, file));

     if (file)  
      {
        if (strlen (file))
         {
           out_file = fopen (file, "a");
           if (! out_file)
            {
              return (MEM_S_SUCCESS);
            }
         }
       else out_file = stdout;
      }
     else out_file = stdout;

     fprintf (out_file, "\n %s \n", name);
     
     if (list)
      {
        temp [0] = 0;
        x = atol (list -> buffer_ptr + size + MEM_NO_BUFFER);
        fprintf (out_file, "no_buffers = <%d>\n", x);

        while (1)
         {
           size = size + buf_size;

           alloc_size = atol (list -> buffer_ptr + size + MEM_REALLOC_SIZE);

           buf_size = atol (list -> buffer_ptr + size + MEM_BUFFER_USED);
        
           data_offset = atol (list -> buffer_ptr + size + MEM_DATA_OFFSET);

           y++;
           if (x == 0) break;
           if (x <= y) break;
         }

        fprintf (out_file, "alloc size  = <%d>\n", alloc_size);
        fprintf (out_file, "buffer size = <%d>\n", buf_size);
        fprintf (out_file, "data offset = <%d>\n", data_offset);

        fprintf (out_file, "no rows     = <%d>\n", list -> rows    );
        fprintf (out_file, "no columns  = <%d>\n", list -> columns );
        fprintf (out_file, "row size    = <%d>\n", list -> row_size);
                	
        fprintf (out_file, "\n");

        count = size;
        while (count < size + buf_size)
         {
           if (list -> buffer_ptr [count] == '\0') 
             fprintf (out_file, "~");
           else if (list -> buffer_ptr [count] == '\1') 
             fprintf (out_file, "\n");
           else
             fprintf (out_file, "%c", list -> buffer_ptr [count]);
                                     
           count++;
         }
      }

     fprintf (out_file, "\n");      
     if (out_file != stdout) fclose (out_file);

     _MEMdebug ((fname,"SUCCESSFUL : %s\n", ""));
     return (MEM_S_SUCCESS);
  }
 
 MEMprint_buffers (name, list, file)
  char         *name;
  MEMptr       list;
  char         *file;
  {
     static char *fname = "MEMprint_buffers";
     long  count = NULL, x, atol ();
     char  temp [25];
     long  buf_size, buffer_offset = 0;
     FILE  *out_file, *fopen ();

     _MEMdebug ((fname,"Name = <%s> : List Addr = <%d> : File Name = <%s>\n",
		 name, list, file));

     if (file)  
      {
        if (strlen (file))
         {
           out_file = fopen (file, "a");
           if (! out_file)
            {
              return (MEM_S_SUCCESS);
            }
         }
       else out_file = stdout;
      }
     else out_file = stdout;

     fprintf (out_file, "\n %s \n", name);
     
     if (list)
      {
      	while (1)
      	 {
           temp [0] = 0;

           fprintf (out_file, "no buffers = <%s>\n", list -> buffer_ptr + buffer_offset + MEM_NO_BUFFER);

           x = atol (list -> buffer_ptr + buffer_offset + MEM_NO_BUFFER);
    
           fprintf (out_file, "alloc size = <%s>\n", list -> buffer_ptr + buffer_offset + MEM_REALLOC_SIZE);

           fprintf (out_file, "buffer size = <%s>\n", list -> buffer_ptr + buffer_offset + MEM_BUFFER_USED);
           buf_size = atol (list -> buffer_ptr + buffer_offset + MEM_BUFFER_USED);
        
           fprintf (out_file, "data offset = <%s>\n", list -> buffer_ptr + buffer_offset + MEM_DATA_OFFSET);
                   	
           count = 0;
           while (count < buf_size)
            {
              if (list -> buffer_ptr [count + buffer_offset] == '\0') 
                fprintf (out_file, "~");
              else if (list -> buffer_ptr [count + buffer_offset] == '\1') 
                fprintf (out_file, "\n");
              else
                fprintf (out_file, "%c", 
                              list -> buffer_ptr [count + buffer_offset]);
                                     
              count++;
            }

          if (! x) break;
          buffer_offset = buffer_offset + buf_size;
         }
     }

    fprintf (out_file, "\n");      
    if (out_file != stdout) fclose (out_file);

    _MEMdebug ((fname," SUCCESSFUL : %s\n", ""));
    return (MEM_S_SUCCESS);
  }

 MEMprint_array (name, list, file)
  char         *name;
  MEMptr        list;
  char         *file;  
  {
     static char *fname = "MEMprint_array";
     long  count = NULL, atol ();
     char  **format = NULL, **column = NULL; 
     char  **data;
     long  x, y = 1;
     long  size = 0,  buf_size = 0, data_offset = 0, alloc_size = 0;
     FILE  *out_file, *fopen ();

     _MEMdebug ((fname,"Name = <%s> : List Addr = <%d> : File Name = <%s>\n", 
		 name, list, file));

     if (file)  
      {
        if (strlen (file))
         {
           out_file = fopen (file, "a");
           if (! out_file)
            {
              return (MEM_S_SUCCESS);
            }
         }
       else out_file = stdout;
      }
     else out_file = stdout;

     fprintf (out_file, "\n %s \n", name);
     
     if (list)
      {
        x = atol (list -> buffer_ptr + size + MEM_NO_BUFFER);
        fprintf (out_file, "no buffers  = <%d>\n", x);

        y = 1;
        while (x >= y || x == 0)
         {
           size = size + buf_size;
           alloc_size = atol (list -> buffer_ptr + size + MEM_REALLOC_SIZE);

           buf_size = atol (list -> buffer_ptr + size + MEM_BUFFER_USED);
        
           data_offset = atol (list -> buffer_ptr + size + MEM_DATA_OFFSET);

           y++;
           if (x == 0) break;
         }

        fprintf (out_file, "alloc size  = <%d>\n", alloc_size);
        fprintf (out_file, "buffer size = <%d>\n", buf_size);
        fprintf (out_file, "data offset = <%d>\n", data_offset);
                	
        fprintf (out_file, "no rows     = <%d>\n", list -> rows    );
        fprintf (out_file, "no columns  = <%d>\n", list -> columns );
        fprintf (out_file, "row size    = <%d>\n", list -> row_size);

        fprintf (out_file, "\n");

        if ((list -> column_ptr) || (list -> format_ptr))
         {
          if (list -> column_ptr) column = (char **) list -> column_ptr;
          if (list -> format_ptr) format = (char **) list -> format_ptr;
          
          for (x = 0; x < list -> columns; ++x)
           {
             if (list -> column_ptr)
               fprintf (out_file, " column <%d> <%s> %*s ", x, column [x],
               30 - strlen (column [x]), "");
             if (list -> format_ptr)
               fprintf (out_file, " format <%d> <%s>", x, format [x]);
             fprintf (out_file, "\n");
           }
         }

        if (list -> data_ptr)
         {
           data = (char **) list -> data_ptr;
           for (x = 0; x < list -> rows; ++x)
            {
               count = x * list -> columns;
               for (y = 0; y < list -> columns; ++y)
                 fprintf (out_file, 
                          "[%d] [%d] <%s>\n", x, y, data [count + y]);
            }
         }
      }

    if (out_file != stdout) fclose (out_file);

    _MEMdebug ((fname," SUCCESSFUL : %s \n", ""));
    return (MEM_S_SUCCESS);
  }

 MEMprint_buffer_ptr (name, buffer_ptr, file)
  char         *name;
  char         *buffer_ptr;
  char         *file;
  {
     static char *fname="MEMprint_buffer_ptr";
     long  count = NULL, x, atol ();
     long  buf_size, buffer_offset = 0;
     FILE  *out_file, *fopen ();

     _MEMdebug ((fname," Name = <%s>  : File Name = <%s>\n", 
		 name, file));

     if (file)  
      {
        if (strlen (file))
         {
           out_file = fopen (file, "a");
           if (! out_file)
            {
              return (MEM_S_SUCCESS);
            }
         }
       else out_file = stdout;
      }
     else out_file = stdout;

     fprintf (out_file, "\n %s \n", name);
     
     if (buffer_ptr)
      {
      	while (1)
      	 {
           x = atol (buffer_ptr + buffer_offset + MEM_NO_BUFFER);
    
           buf_size = atol (buffer_ptr + buffer_offset + MEM_BUFFER_USED);
        

           count = 0;
           while (count < buf_size)
            {
              if (buffer_ptr [count + buffer_offset] == '\0') 
                fprintf (out_file, "~");
              else if (buffer_ptr [count + buffer_offset] == '\1') 
                fprintf (out_file, "\n");
              else
                fprintf (out_file, "%c", 
                              buffer_ptr [count + buffer_offset]);
                                     
              count++;
            }

          if (! x) break;
          buffer_offset = buffer_offset + buf_size;
         }
     }

    fprintf (out_file, "\n");      
    if (out_file != stdout) fclose (out_file);

    _MEMdebug ((fname,"SUCCESSFUL : %s\n", ""));
     return (MEM_S_SUCCESS);
  }
