#include <stdio.h>
#include <errno.h>
#include <io.h>
#include <string.h>
#include <malloc.h>
#include "CLIerrordef.h"
#include "CLIstruct.h"
#include "CLIextern.h"
#include "NFMerrordef.h" 
#include "NETstruct.h"
#include "proto.h"
#include "pc.h"
#include <memcheck.h>

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
  if (((*num_cols) * (*num_rows)) < 1)
    {
      return(NFM_E_FAILURE) ;
    }

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

  block_ptr = (short *) src ;

  if (row_number > rows || row_number < 1) 
    {
      return (NFM_E_FAILURE) ;
    }

  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)(*block_ptr)) ;
    }

  sizes_array = (short *) ((long)block_ptr + (long)sizeof(short)) ;

  size_of_row = 0 ;
  for (i=0; i<cols; i++)
    {
      size_of_row = size_of_row + (long) sizes_array [i] ;
    }

  *row_size = size_of_row ;

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
  

  src = (long *)serverbuf;
  
  rows = (*src);  src++;
  cols = (*src);  src++;


  block_ptr = (short *) src ;

  if (row_number > rows || row_number < 1) 
    {
      return (NFM_E_FAILURE) ;
    }
  if (column_number > cols || column_number < 0) 
    {
      return (NFM_E_FAILURE) ;
    }
 
  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)*block_ptr) ;
    }

  sizes_array = (short *) ((long) block_ptr + (long) sizeof (short)) ;

  data = (char *) ((long)sizes_array + ((long) cols * (long) sizeof (short))) ;


  for (i=0; i<column_number-1; i++)
    {
      data = (char *) ((long)data + (long)sizes_array [i]) ;
    }

  if (i== column_number)
    {
      return (NFM_E_FAILURE) ;
    }

  strcpy(value,data);

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
  

  list = (char *) (serverbuf + sizeof (struct NETbuffer_info)) ;
  src = (long *)list;
  
  rows = (*src);  src++;
  cols = (*src);  src++;


  block_ptr = (short *) src ;

  if (row_number > rows || row_number < 1) 
    {
      return (NFM_E_FAILURE) ;
    }

  if (column_number > cols || column_number < 0) 
    {
      return (NFM_E_FAILURE) ;
    }

  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)*block_ptr) ;
    }
      

  sizes_array = (short *) ((long) block_ptr + (long) sizeof (short)) ;

  data = (char *) ((long)sizes_array + ((long) cols * (long) sizeof (short))) ;


  for (i=0; i<column_number-1; i++)
    {
      data = (char *) ((long)data + (long)sizes_array [i]) ;
    }

  if (i== column_number)
    {
      return (NFM_E_FAILURE) ;
    }

  if (((long)(strlen (new_data) - 1)) > ((long) sizes_array[i]))
    {
      sprintf (message, "Could not write value %s into size %d\n", 
	       new_data, (long) sizes_array [i]) ;
      return (NFM_E_MESSAGE) ;
    }

  strcpy(data, new_data) ;
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
  

  src = (long *)serverbuf;
  
  rows = (*src);  src++;
  cols = (*src);  src++;


  block_ptr = (short *) src ;

  if (row_number > rows || row_number < 1) 
    {
      return (NFM_E_FAILURE) ;
    }

  if (column_number > cols || column_number < 0) 
    {
      return (NFM_E_FAILURE) ;
    }

  for (i=0; i< row_number-1; i++)
    {
      block_ptr =  (short *) ((long)block_ptr + (long)*block_ptr) ;
    }
      

  sizes_array = (short *) ((long) block_ptr + (long) sizeof (short)) ;
  data = (char *) ((long)sizes_array + ((long) cols * (long) sizeof (short))) ;


  for (i=0; i<column_number-1; i++)
    {
      data = (char *) ((long)data + (long)sizes_array [i]) ;
    }

  if (i== column_number)
    {
      return (NFM_E_FAILURE) ;
    }

/*  strcpy(value,data); */

  memcpy (value,data,sizes_array[i]) ;

  return (NFM_S_SUCCESS) ;
}

/********  header needed ***********/
long  _NFMpc_write_row (list_ptr, str)
     char **list_ptr ;
     char *str ;
{
  static char *fname = "_NFMpc_write_row" ;
  long i, no_attr, original_size, block_size, columns, new_size ;
  short len, *block_size_loc, *sizes_array ;
  char *ptr, *start_string, *data, *src, *list ;
  long *long_ptr, *original_ptr, no_attributes ;
  struct NETbuffer_info *struct_ptr ;


  struct_ptr = (struct NETbuffer_info *) (*list_ptr) ;

  original_ptr = (long *) ((long) (*list_ptr) + 
		       (long) sizeof (struct NETbuffer_info)) ;


  original_ptr++ ; 
  no_attributes = *original_ptr ;

  original_size = struct_ptr->size ; 

  
  /* add new block of data */
  block_size = strlen (str) + ((no_attributes+1)*sizeof(short)) ;
  new_size = original_size + block_size;

  ptr = (char *) realloc ((*list_ptr), (short) new_size) ;
  if (ptr == NULL)
    {
      return (NFM_E_MALLOC) ;
    }	

  *list_ptr = (char *) ptr ;
  list = (char *)ptr ;
  struct_ptr = (struct NETbuffer_info *) ptr ;
  struct_ptr -> size = (long) new_size ; 

  long_ptr = (long *) ((long) list + 
		       (long) sizeof (struct NETbuffer_info)) ;


 /* increment row count */
  *long_ptr =  (long) ((*long_ptr) + 1) ;
  long_ptr++ ; 
  columns = *long_ptr ;

  src = list + original_size ;
  block_size_loc = (short *) src ;
  *block_size_loc = (short) block_size ; 
  sizes_array = (short *) (src + (long) sizeof (short));
  data = (char *) ((long) sizes_array + 
		   ((long) columns * (long) sizeof (short))) ;
  len = 0 ;
  no_attr = 0 ;
  start_string = str ;
  for (i=0; i< ((long) strlen (str)); i++)
    {
      if (str [i] == '\001')
	{
	  sizes_array [no_attr] = len + 1;
	  strncpy (data, start_string, len) ;
	  data [len] = 0 ;
	  start_string = (char *) &str [i+1] ;
	  data = data + (len + 1) ;
	  len = 0 ;
	  no_attr++ ;
	  if (no_attr > no_attributes)
	    {
	      return (NFM_E_FAILURE) ;
	    }
	}
      else
	{
	  ++len ;
	}
    }

  if (no_attr != no_attributes)
    {
      return (NFM_E_FAILURE) ;
    }

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
  long i, y, num_rows, num_cols, status, row_size ;
  FILE *file_ptr ;


  serverbuf = (char *) (list + sizeof (struct NETbuffer_info)) ;

  file_ptr = fopen (filename, "a") ;
  if (file_ptr == NULL)
    {
      return (NFM_E_MESSAGE) ;
    }

  if (strlen (title))
    fprintf (file_ptr, "%s\n", title) ;

  status = PCmem_no_rows_columns (serverbuf, &num_rows, &num_cols) ;
  if (status != NFM_S_SUCCESS)
    {
      return (status) ;
    }

  fprintf (file_ptr, "row %ld cols %ld\n", num_rows, num_cols) ;

  for (i=1; i<num_rows+1; i++) 
    {
      fprintf (file_ptr, "\nrow %ld\n", i) ;

      status = PCmem_get_row_size (serverbuf, i, &row_size) ;
      if (status != NFM_S_SUCCESS)
	{
	  return (status) ;
	}
      
      for (y=1; y<num_cols+1; y++)
	{
	  status = PCmem_read_data (serverbuf, i, y, value) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      return (status) ;
	    }
	  fprintf (file_ptr, "%s~\n", value) ;
	}
    }	  

  fclose (file_ptr) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMpc_build_buffer (list_ptr, no_columns)
     char **list_ptr ;
     long no_columns ;
{
  static char *fname = "_NFMpc_get_transfer_files_list" ;
  long buffer_size, *src ;
  char *list ;
  struct NETbuffer_info *ptr ;

  buffer_size = (long) (sizeof (struct NETbuffer_info) +
			(2 * (long) sizeof (long))) ;


  list = (char *) malloc ((short)buffer_size) ;
  if (list == NULL)
    {
      return (NFM_E_MALLOC) ;
    }

  ptr = (struct NETbuffer_info *) list ;

  ptr -> size = buffer_size ;


  src = (long *) (list + sizeof (struct NETbuffer_info)) ;


  *src = 0 ; src++ ;   /* row */
  *src = no_columns;   /* columns */

  *list_ptr = list ;


  return( NFM_S_SUCCESS );
}



