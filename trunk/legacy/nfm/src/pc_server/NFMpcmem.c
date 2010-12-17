#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h" 
#include "NETstruct.h"
#include "SQLerrordef.h"
#include "DEBUG.h"
#include <errno.h>
#include "ERR.h" 
#include "MEMstruct.h"
#include "NFMpcproto.h" 


/******************************************************************************
This function takes the serverbuf and determines the number of rows and columns
(no Header)
******************************************************************************/

long    PCmem_no_rows_columns (serverbuf, num_rows,num_cols)
     char	*serverbuf;
     long    *num_rows, *num_cols;
{
  static char *fname = "PCmem_no_rows_columns" ;
  long    *src;

  src = (long *)serverbuf; 
  *num_rows = (*src);  src++;
  *num_cols = (*src);  
/****
  if ((*num_cols * *num_rows) < 1)
    {
      _MEMdebug ((fname, "cols %d rows %d\n", *num_rows, *num_cols)) ;
      return(SQL_I_NO_ROWS_FOUND) ;
    }
*****/
  _MEMdebug ((fname, "SUCCESSFUL : rows %d : columns %d\n",
	      *num_rows, *num_cols)) ;
  return (NFM_S_SUCCESS) ;
}
/******************************************************************************
This function takes the serverbuf and determines the number of rows and columns
(No header)
******************************************************************************/

long    PCmem_get_row_size (serverbuf, row_number, row_size)
     char	*serverbuf;
     long       row_number ;
     long       *row_size ;
{
  static char *fname = "PCmem_get_row_size" ;
  long    rows,cols, *src, size_of_row ,i ;
  short   *block_ptr, *sizes_array ;

  src = (long *)serverbuf; 
  rows = (*src);  src++;
  cols = (*src);  src++;

  _MEMdebug ((fname, "Rows is %d : Columns is %d\n", rows, cols)) ;

  block_ptr = (short *) src ;

  if ((row_number > rows) || (row_number < 1)) 
    {
      _MEMdebug ((fname, "Bad row number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }


  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)*block_ptr) ;
    }
      
/*  _MEMdebug ((fname, "Size of block is %d\n", (long) *block_ptr)) ; */

  sizes_array = (short *) ((long) block_ptr + (long) sizeof (short)) ;

  size_of_row = 0 ;
  for (i=0; i<cols; i++)
    {
      size_of_row = size_of_row + (long) sizes_array [i] ;
    }

  *row_size = size_of_row ;

  _MEMdebug ((fname, "SUCCESSFUL : size of row is %d\n",
	      *row_size)) ;
  return (NFM_S_SUCCESS) ;
}


/******************************************************************************
This function takes the serverbuf and determines the number of rows and columns
(No header)
******************************************************************************/

long    PCmem_get_buffer_size (serverbuf, buffer_size)
     char	*serverbuf;
     long       *buffer_size ;
{
  static char *fname = "PCmem_get_row_size" ;
  long    rows,cols, *src, i ;
  short   *block_ptr ;

  src = (long *) (serverbuf + sizeof (struct NETbuffer_info)) ;
  rows = (*src);  src++;
  cols = (*src);  src++;

  *buffer_size = sizeof (struct NETbuffer_info) + 2*sizeof(long) ;

  _MEMdebug ((fname, "Rows is %d : Columns is %d\n", rows, cols)) ;

  block_ptr = (short *) src ;

  for (i=0; i< rows; i++)
    {
      *buffer_size += *block_ptr ;
      block_ptr =  (short *) ((long)block_ptr + (long)*block_ptr) ;
    }
      
  _MEMdebug ((fname, "SUCCESSFUL : size of buffer is %d\n",
	      *buffer_size)) ;
  return (NFM_S_SUCCESS) ;
}



/******************************************************************************
Given a serverbuf, this function returns the data found for the particular
row number and column number given.
(No header)
******************************************************************************/
long    PCmem_read_data (serverbuf, row_number,column_number,value)
     char	*serverbuf;
     long    row_number, column_number;
     char    *value;
{
  static char *fname = "PCmem_read_data" ;
  long    rows,cols,*src,i ;
  short   *block_ptr, *sizes_array ;
  char    *data;
  
/*  _MEMdebug ((fname, "row %d : column %d\n", row_number, column_number)) ; */

  src = (long *)serverbuf;
  
  rows = (*src);  src++;
  cols = (*src);  src++;

/*  _MEMdebug ((fname, "Rows is %d : Columns is %d\n", rows, cols)) ;  */

  block_ptr = (short *) src ;
/*  _MEMdebug ((fname, "Address of src is %ld : block ptr %ld\n", 
	      src, block_ptr)) ; */

  if ((row_number > rows) || (row_number < 1))
    {
      _MEMdebug ((fname, "Bad row number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  if ((column_number > cols) || (column_number < 0))
    {
      _MEMdebug ((fname, "Bad column number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad column number") ;
      return (NFM_E_MESSAGE) ;
    }

  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)(*block_ptr)) ;
    }
      
/*  _MEMdebug ((fname, "Size of block is %d\n", (long) *block_ptr)) ; */

  sizes_array = (short *) ((long) block_ptr + (long) (sizeof (short))) ;

/*   _MEMdebug ((fname, "Address of src is %ld : block ptr %ld\n", 
	      src, block_ptr)) ; */

  data = (char *) ((long)sizes_array + ((long) cols * (long) sizeof (short))) ;

/*  _MEMdebug ((fname, "block ptr %d : sizes_array addr %d : data is %d\n",
	      block_ptr, sizes_array, data)) ; */

  for (i=0; i<column_number-1; i++)
    {
/*      _MEMdebug ((fname, "i is %d : size is %d : address %d\n", 
		  i, (long) sizes_array [i], sizes_array)) ; */
      data = (char *) ((long)data + (long)sizes_array [i]) ;
    }

  if (i== column_number)
    {
      _MEMdebug ((fname, "Bad column\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad column") ;
      return (NFM_E_MESSAGE) ;
    }

  strcpy(value,data);

  _MEMdebug ((fname, "SUCCESSFUL : value is %s\n", value)) ;
  return (NFM_S_SUCCESS) ;
}

/******************************************************************************
Given a serverbuf, this function returns the data found for the particular
row number and column number given.
(No header)
******************************************************************************/
long    PCmem_read_row (serverbuf, row_number, str)
     char    *serverbuf;
     long    row_number ;
     char    *str ;
{
  static char *fname = "PCmem_read_row" ;
  long    rows,cols,*src,i ;
  short   *block_ptr, *sizes_array ;
  char    *data;
  
/*  _MEMdebug ((fname, "row %d : column %d\n", row_number, column_number)) ; */

  src = (long *)serverbuf;
  
  rows = (*src);  src++;
  cols = (*src);  src++;

/*  _MEMdebug ((fname, "Rows is %d : Columns is %d\n", rows, cols)) ;  */

  block_ptr = (short *) src ;
/*  _MEMdebug ((fname, "Address of src is %ld : block ptr %ld\n", 
	      src, block_ptr)) ; */

  if ((row_number > rows) || (row_number < 1))
    {
      _MEMdebug ((fname, "Bad row number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)(*block_ptr)) ;
    }
      
/*  _MEMdebug ((fname, "Size of block is %d\n", (long) *block_ptr)) ; */

  sizes_array = (short *) ((long) block_ptr + (long) (sizeof (short))) ;

/*   _MEMdebug ((fname, "Address of src is %ld : block ptr %ld\n", 
	      src, block_ptr)) ; */

  data = (char *) ((long)sizes_array + ((long) cols * (long) sizeof (short))) ;

/*  _MEMdebug ((fname, "block ptr %d : sizes_array addr %d : data is %d\n",
	      block_ptr, sizes_array, data)) ; */

  str [0] = 0 ;
  for (i=0; i<cols; i++)
    {
/*      _MEMdebug ((fname, "i is %d : size is %d : address %d\n", 
		  i, (long) sizes_array [i], sizes_array)) ; */
      strcat (str, data) ;
      strcat (str, "\001") ;
      data = (char *) ((long)data + (long)sizes_array [i]) ;
    }

  _MEMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}



/******************************************************************************
Given a serverbuf, this function returns the data found for the particular
row number and column number given.
(No header)
******************************************************************************/
long    PCmem_get_address_of_read_data (serverbuf, row_number,column_number,
					address)
     char	*serverbuf;
     long    row_number, column_number;
     long    *address ;
{
  static char *fname = "PCmem_read_data" ;
  long    rows,cols,*src,i ;
  short   *block_ptr, *sizes_array ;
  char    *data, value [20];
  
/*  _MEMdebug ((fname, "row %d : column %d\n", row_number, column_number)) ; */

  src = (long *)serverbuf;
  
  rows = (*src);  src++;
  cols = (*src);  src++;

/*  _MEMdebug ((fname, "Rows is %d : Columns is %d\n", rows, cols)) ;  */

  block_ptr = (short *) src ;
/*  _MEMdebug ((fname, "Address of src is %ld : block ptr %ld\n", 
	      src, block_ptr)) ; */

  if ((row_number > rows) || (row_number < 1))
    {
      _MEMdebug ((fname, "Bad row number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  if ((column_number > cols) || (column_number < 0))
    {
      _MEMdebug ((fname, "Bad column number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)(*block_ptr)) ;
    }
      
/*  _MEMdebug ((fname, "Size of block is %d\n", (long) *block_ptr)) ; */

  sizes_array = (short *) ((long) block_ptr + (long) (sizeof (short))) ;

/*   _MEMdebug ((fname, "Address of src is %ld : block ptr %ld\n", 
	      src, block_ptr)) ; */

  data = (char *) ((long)sizes_array + ((long) cols * (long) sizeof (short))) ;

/*  _MEMdebug ((fname, "block ptr %d : sizes_array addr %d : data is %d\n",
	      block_ptr, sizes_array, data)) ; */

  for (i=0; i<column_number-1; i++)
    {
/*      _MEMdebug ((fname, "i is %d : size is %d : address %d\n", 
		  i, (long) sizes_array [i], sizes_array)) ; */
      data = (char *) ((long)data + (long)sizes_array [i]) ;
    }

  if (i== column_number)
    {
      _MEMdebug ((fname, "Bad column\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  strcpy(value,data);
  *address = (long) data ;

  _MEMdebug ((fname, "SUCCESSFUL : address is %d\n", *address)) ;
  return (NFM_S_SUCCESS) ;
}


/******************************************************************************
Given a serverbuf, this function writes the data found for the particular
row number and column number given if the size is allocated
(needs header)
******************************************************************************/
long    PCmem_write_data (serverbuf, row_number,column_number,new_data)
     char    *serverbuf;
     long    row_number, column_number;
     char    *new_data;
{
  static char *fname = "PCmem_write_data" ;
  long    rows,cols,*src,i ;
  short   *block_ptr, *sizes_array ;
  char    *data, message [50], *list ;
  
  _MEMdebug ((fname, "Address %d : row %d : column %d : data %s\n", 
	      serverbuf, row_number, column_number, new_data)) ;  

  list = (char *) (serverbuf + sizeof (struct NETbuffer_info)) ;
  src = (long *)list;
  
  rows = (*src);  src++;
  cols = (*src);  src++;

/*   _MEMdebug ((fname, "Rows is %d : Columns is %d\n", rows, cols)) ;  */

  block_ptr = (short *) src ;

  if ((row_number > rows) || (row_number < 1)) 
    {
      _MEMdebug ((fname, "Bad row number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  if ((column_number > cols) || (column_number < 0))
    {
      _MEMdebug ((fname, "Bad column number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)*block_ptr) ;
    }
      
/*  _MEMdebug ((fname, "Size of block is %d\n", (long) *block_ptr)) ; */

  sizes_array = (short *) ((long) block_ptr + (long) sizeof (short)) ;

  data = (char *) ((long)sizes_array + ((long) cols * (long) sizeof (short))) ;

/*  _MEMdebug ((fname, "block ptr %d : sizes_array addr %d : data is %d\n",
	      block_ptr, sizes_array, data)) ; */

  for (i=0; i<column_number-1; i++)
    {
/*      _MEMdebug ((fname, "i is %d : size is %d : address %d\n", 
		  i, (long) sizes_array [i], sizes_array)) ; */
      data = (char *) ((long)data + (long)sizes_array [i]) ;
    }

  if (i== column_number)
    {
      _MEMdebug ((fname, "Bad column\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  if ((strlen (new_data) - 1) > ((long) sizes_array[i]))
    {
      sprintf (message, "Could not write value %s into size %d\n", 
	       new_data, (long) sizes_array [i]) ;
      _MEMdebug ((fname, "%s", message)) ;
      return (NFM_E_MESSAGE) ;
    }

  strcpy(data, new_data) ;
  _MEMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

/******************************************************************************
Given a serverbuf, this function returns the data found for the particular
row number and column number given.
(No header)
******************************************************************************/
long    PCmem_read_data_non_string (serverbuf, row_number,column_number,value)
     char	*serverbuf;
     long    row_number, column_number;
     char    *value;
{
  static char *fname = "PCmem_read_data_non_string" ;
  long    rows,cols,*src,i ;
  short   *block_ptr, *sizes_array ;
  char    *data;
  
/*  _MEMdebug ((fname, "row %d : column %d\n", row_number, column_number)) ; */

  src = (long *)serverbuf;
  
  rows = (*src);  src++;
  cols = (*src);  src++;

/*  _MEMdebug ((fname, "Rows is %d : Columns is %d\n", rows, cols)) ; */

  block_ptr = (short *) src ;

  if ((row_number > rows) || (row_number < 1)) 
    {
      _MEMdebug ((fname, "Bad row number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  if ((column_number > cols) || (column_number < 0))
    {
      _MEMdebug ((fname, "Bad column number\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
      return (NFM_E_MESSAGE) ;
    }

  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)*block_ptr) ;
    }
      
/*  _MEMdebug ((fname, "Size of block is %d\n", (long) *block_ptr)) ; */

  sizes_array = (short *) ((long) block_ptr + (long) sizeof (short)) ;
/*
  for (i=0; i<cols; i++)
    {
      _MEMdebug ((fname, "i is %d : size is %d : address %d\n", 
		  i, (long) sizes_array [i], sizes_array)) ;
    }
*/
  data = (char *) ((long)sizes_array + ((long) cols * (long) sizeof (short))) ;

/*  _MEMdebug ((fname, "block ptr %d : sizes_array addr %d : data is %d\n",
	      block_ptr, sizes_array, data)) ; */

  for (i=0; i<column_number-1; i++)
    {
      data = (char *) ((long)data + (long)sizes_array [i]) ;
    }

  if (i== column_number)
    {
      _MEMdebug ((fname, "Bad column\n")) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad column") ;
      return (NFM_E_MESSAGE) ;
    }

/*  strcpy(value,data); */
/*  _MEMdebug ((fname, "copying %d bytes from data into value\n")) ; */

  memcpy (value,data,sizes_array[i]) ;

  _MEMdebug ((fname, "SUCCESSFUL : value is %s\n", value)) ;
  return (NFM_S_SUCCESS) ;
}

/********  header needed ***********/
long  _NFMpc_write_row (list_ptr, str)
     char **list_ptr ;
     char *str ;
{
  static char *fname = "_NFMpc_write_row" ;
  long i, no_attr, original_size, columns, new_size ;
  short len, *block_size_loc, *sizes_array, block_size ;
  char *ptr, *start_string, *data, *src ;
  long *long_ptr, *original_ptr, no_attributes ;
  struct NETbuffer_info *struct_ptr ;

  _MEMdebug ((fname, "address is %d\n", *list_ptr)) ;   
  struct_ptr = (struct NETbuffer_info *) (*list_ptr) ;
  original_ptr = (long *) ((long) (*list_ptr) + 
		       (long) sizeof (struct NETbuffer_info)) ;

  _MEMdebug ((fname, "address of after NETbuffer_info %d\n", 
	      original_ptr)) ;  
  original_ptr++ ; 
  no_attributes = *original_ptr ;
  original_size = struct_ptr->size ; 

  _MEMdebug ((fname, "no of attributes is %d : size of string %d  : original size %d\n", 
	      no_attributes, strlen (str), original_size));

  /* add new block of data */
  block_size = (short) ((long) strlen (str) + 
			((long) (no_attributes+1)*sizeof(short)));
  if ((block_size % 2) != 0)
    {
      ++block_size ;
    }

  new_size = original_size + (long) block_size;


  _MEMdebug ((fname, "original size %d : added block size is %d : total new buffer size is %d\n",
	      original_size, (long) block_size, new_size)) ;  
/*******
  ptr = (char *) realloc ((*list_ptr), new_size) ;
  if (ptr == NULL)
    {
      _MEMdebug ((fname, "reallocation failed\n")) ;
      return (NFM_E_MALLOC) ;
    }	
*******/
  ptr = (char *) malloc (new_size) ;
  if (ptr == NULL)
    {
      _MEMdebug ((fname, "malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  memcpy (ptr, *list_ptr, original_size) ;

  free (*list_ptr) ;
  *list_ptr = ptr ;
  struct_ptr = (struct NETbuffer_info *) ptr ;
  struct_ptr -> size = new_size ; 
/*   _MEMdebug ((fname, "ptr's address is %d\n", ptr)) ; */
  long_ptr = (long *) ((long) ptr + 
		       (long) sizeof (struct NETbuffer_info)) ;
  _MEMdebug ((fname, "ptr's address is %d\n", ptr)) ; 
  _MEMdebug ((fname, "address of after NETbuffer_info %d : size of NETbuffer_info is %d\n", 
	      long_ptr, sizeof (struct NETbuffer_info))) ;  

 /* increment row count */
  _MEMdebug ((fname, "old No of rows is %d\n", *long_ptr)) ;  
  *long_ptr =  (long) ((*long_ptr) + 1) ;
   _MEMdebug ((fname, "new No of rows is %d\n", *long_ptr)) ;   
  long_ptr++ ; 
  columns = *long_ptr ;
  _MEMdebug ((fname, "no of columns is %d\n", columns)) ;  

  src = (char *) ((long)ptr + (long)original_size) ;
/*  _MEMdebug ((fname, "src is %d\n", src)) ; */
  block_size_loc = (short *) src ;
  sizes_array = (short *) ((long) src + (long) sizeof (short));
/*  _MEMdebug ((fname, "address of sizes array is %d\n", sizes_array)) ; */
  data = (char *) ((long) sizes_array + 
		   ((long) columns * (long) sizeof (short))) ;
  _MEMdebug ((fname, "address sizes array %d : address data %d\n",
	      sizes_array, data)) ;  
  *block_size_loc = block_size ;
/*  _MEMdebug ((fname, "block size %d into %d\n",
	      block_size, block_size_loc)) ; */

  len = 0 ;
  no_attr = 0 ;
  start_string = str ;
  for (i=0; i<strlen (str); i++)
    {
      if (str [i] == '\001')
	{
/*	  _MEMdebug ((fname, "len is %d\n", len)) ;   */
	  sizes_array [no_attr] = len + 1;
	  strncpy (data, start_string, len) ;
	  data [len] = 0 ;
/*	  _MEMdebug ((fname, "data is %s\n", data)) ;   */
	  start_string = (char *) &str [i+1] ;
	  data = data + (len + 1) ;
	  len = 0 ;
	  no_attr++ ;
	  if (no_attr > no_attributes)
	    {
	      _NFMdebug ((fname, "no_attr %d > no_attributes %d\n",
			  no_attr, no_attributes)) ;
	      ERRload_struct (NFM, NFM_E_MESSAGE, "attributes mismatch") ;
	      return (NFM_E_MESSAGE) ;
	    }
/*	  _MEMdebug ((fname, "\n")) ;  */
	}
      else
	{
/*	  _MEMdebug ((fname, "%c ", str[i])) ;  */
	  ++len ;
	}
    }

  if (no_attr != no_attributes)
    {
      _MEMdebug ((fname, "no attrs (%d) != no_attributes (%d)\n",
		  no_attr, no_attributes)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Attributes Mismatch") ;
      return (NFM_E_MESSAGE) ;
    }

  _MEMdebug ((fname, "SUCCESSFUL\n")) ;
  return( NFM_S_SUCCESS );
}

/* header needed */
long _NFMpc_print_mem_buffer (title, list, filename) 
     char *title ;
     char *list ;
     char *filename ;
{
  static char *fname = "_NFMpc_print_mem_buffer" ;
  char *serverbuf, value [500] ;
  long i, y, num_rows, num_cols, status, *src1, i1, rows1, cols1 ;
  short *block_ptr1, *sizes_array1 ;
  char  *data1 ;
  FILE *file_ptr ;
  struct NETbuffer_info *struct_ptr ;

  _MEMdebug ((fname, "ENTER : Address %d\n", list)) ;
  file_ptr = fopen (filename, "a") ;
  if (file_ptr == NULL)
    {
      _MEMdebug ((fname, "Filename ptr for %s failed with errno %d\n",
		  errno)) ;
      return (NFM_E_MESSAGE) ;
    }

  if (strlen (title))
    fprintf (file_ptr, "%s\n", title) ;

  struct_ptr = (struct NETbuffer_info *) list ;
  fprintf (file_ptr, "request field : 0x%.8x(hex) : %ld (long)\n", 
	   struct_ptr -> request, struct_ptr -> request) ;
  fprintf (file_ptr, "size field : %ld\n", struct_ptr -> size) ;

  serverbuf = (char *) (list + sizeof (struct NETbuffer_info)) ;

  status = PCmem_no_rows_columns (serverbuf, &num_rows, &num_cols) ;
  if (status != NFM_S_SUCCESS)
    {
      _MEMdebug ((fname, "Failure : No rows : status = <0x%x.8>\n",
		  status)) ;
      return (status) ;
    }

  fprintf (file_ptr, "row %d cols %d\n", num_rows, num_cols) ;

  for (i=1; i<num_rows+1; i++) 
    {

      src1 = (long *)serverbuf;
      
      rows1 = (*src1);  src1++;
      cols1 = (*src1);  src1++;
      
      block_ptr1 = (short *) src1 ;
      
      if ((i > rows1) || (i < 1))
	{
	  _MEMdebug ((fname, "Bad row number\n")) ;
	  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad row number") ;
	  return (NFM_E_MESSAGE) ;
	}
      
      for (i1=0; i1< i-1; i1++)
	{
	  block_ptr1 =  (short *) ((long)block_ptr1 + 
				   (long)(*block_ptr1)) ;
	}
      
      fprintf (file_ptr, "\nrow %d : block (%d) size -> %d\n", 
	       i, block_ptr1, *block_ptr1) ;
      
      sizes_array1 = (short *) ((long) block_ptr1 +
				(long) (sizeof (short))) ;
      
      for (y=1; y<num_cols+1; y++)
	{
	  
	  if ((y > cols1) || (y < 0))
	    {
	      _MEMdebug ((fname, "Bad column number\n")) ;
	      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad column number") ;
	      return (NFM_E_MESSAGE) ;
	    }
	  
	  data1 = (char *) ((long)sizes_array1 + ((long) cols1 * 
						  (long) sizeof (short))) ;

	  for (i1=0; i1<y-1; i1++)
	    {
	      data1 = (char *) ((long)data1 + (long)sizes_array1 [i1]) ;
	    }
	  
	  if (i1== y)
	    {
	      _MEMdebug ((fname, "Bad column\n")) ;
	      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Bad column") ;
	      return (NFM_E_MESSAGE) ;
	    }
	  
	  strcpy(value,data1);

/*******
	  status = PCmem_read_data (serverbuf, i, y, value) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : MEM read : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }
*******/
/*
	  status = PCmem_get_address_of_read_data (serverbuf, i, y, &address) ;
 	  fprintf (file_ptr, "%s~ (%ld)\n", value, address) ;
*/
 	  fprintf (file_ptr, "%s~\n", value);
	}
    }	  
  fclose (file_ptr) ;
  _MEMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMpc_build_buffer (list_ptr, no_columns)
     char **list_ptr ;
     long no_columns ;
{
  static char *fname = "_NFMpc_build_buffer" ;
  long buffer_size, *src ;
  char *list ;
  struct NETbuffer_info *ptr ;

  buffer_size = (long) (sizeof (struct NETbuffer_info) +
			(2 * (long) sizeof (long))) ;

  _MEMdebug ((fname, "creating buffer of size %d\n", buffer_size)) ;

  list = (char *) malloc (buffer_size) ;
  if (list == NULL)
    {
      _MEMdebug ((fname, "Malloc (buffer_size)\n")) ;
      return (NFM_E_MALLOC) ;
    }

  _MEMdebug ((fname, "MALLOC -> %ld : size %ld\n", list, buffer_size)) ;

  ptr = (struct NETbuffer_info *) list ;

  ptr -> size = buffer_size ;

/*  _MEMdebug ((fname, "address of buffer %d\n", list)) ; */

  src = (long *) (list + sizeof (struct NETbuffer_info)) ;

/*  _MEMdebug ((fname, "address after NETbuffer_info is is %d\n", src)) ; */

  *src = 0 ; src++ ;   /* row */
  *src = no_columns;   /* columns */

  *list_ptr = list ;

  _MEMdebug ((fname, "SUCCESSFUL : address of buffer is %d\n", *list_ptr)) ;

  return( NFM_S_SUCCESS );
}


long _NFMfind_value_pc_buf (in_list, column_name, row_number, value)
     char	*in_list ;
     char *column_name ;
     long row_number ;    /* first row is the column info, second and
                             above is data */
     char *value ;
{
  char *fname = "_NFMfind_value_pc_buf" ;
  long num_cols, num_rows, status, i ;
  char tmp_str [200] ;

  _NFMdebug ((fname, "Column Name <%s>\n", column_name)) ;

  PCmem_no_rows_columns (in_list, &num_rows, &num_cols) ;

  for (i=0; i<num_cols; i++)
    {
      status = PCmem_read_data (in_list, 1, i+1, tmp_str) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
		       status)) ;
	  return (status) ;
	}

      if (strcmp (tmp_str, column_name) == 0)
	{
	  status = PCmem_read_data (in_list, row_number+1, i+1, tmp_str) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMSdebug ((fname, "PCmem_read_data (username) : status = <0x%.8x>\n",
			   status)) ;
	      return (status) ;
	    }
	  strcpy (value, tmp_str) ;
	  break ;
	}
    }
  if (i == num_cols)
    {
      _NFMdebug ((fname, "column <%s> not found\n", column_name)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "column not found") ;
      return (NFM_E_MESSAGE) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL : value <%s>\n", value)) ;
  return (NFM_S_SUCCESS) ;
}




