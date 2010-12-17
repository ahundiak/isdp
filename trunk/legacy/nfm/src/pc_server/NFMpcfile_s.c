#include "machine.h"
#include "NFMpc.h"

extern int IN_PIPE ;
extern int OUT_PIPE ;

char message [512] ;

long _NFMpcfs_commands(type_of_transfer, move_list)
     long type_of_transfer ;
     MEMptr *move_list ;
{
  char *fname = "_NFMpcfs_commands" ;
  long status, transfer_status ;
  char *pc_list = NULL ;
  struct NETbuffer_info *list_ptr ;

  _NFMdebug ((fname, "ENTER\n")) ;

  status = _NFMconvert_buf_to_pcbuf (*move_list, &pc_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"convert status = 0x%.8x\n", status));
      return (status) ;
    }

  list_ptr = (struct NETbuffer_info *) pc_list ;

  list_ptr -> request = type_of_transfer ;

  if (_NFMdebug_st.NFMdebug_on)
   _NFMpc_print_mem_buffer ("file server buffer", pc_list,
			    _NFMdebug_st.NFMdebug_file) ;

  status =  _NFMsend_buf_pc_fs_by_row (pc_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "send buf pc fs by row failed : status = <0x%.8x>\n",
		  status)) ;
      return (status);               
    }

  if (_NFMdebug_st.NFMdebug_on)
    _NFMpc_print_mem_buffer ("file server buffer", pc_list,
			     _NFMdebug_st.NFMdebug_file) ;

  /* write filesize and status back to original buffer */
  /* get rows in pcbuffer */

  status = _NFMwrite_status_to_buffer (type_of_transfer, pc_list, &move_list, 
				       &transfer_status) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure :write status to buffer : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  if (pc_list) 
    {
      free(pc_list) ;
    }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("move list", *move_list, _NFMdebug_st.NFMdebug_file) ; 

  _NFMdebug ((fname, "Transfer status : <0x%.8x>\n", transfer_status)) ;
  return (transfer_status) ;
}


long  _NFMsend_buf_pc_fs_by_row (list)
     char *list ;
{
  static char *fname = "_NFMsend_buf_pc_fs_by_row" ;
  long status, size, size_to_send, size_rcd ;
  short *block_size_ptr ;
  char *buffer, *new_ptr, s_status [20], s_filesize [20] ;
  char s12_filesize [20] ;
  long  type_of_transfer ;
  struct NETbuffer_info *struct_ptr ;
  long row_no, *long_ptr, rows, *long_ptr1, no_rows, no_columns ;
  long client_status ;
  long _NFMhandshake_abort()  ;

  _NFMdebug ((fname, "ENTER\n")) ;

  buffer = (char *) malloc (PC_ALLOCATION_SIZE) ;
  if (buffer == NULL)
    {
      _NFMdebug ((fname, "Failure : Malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  if (!list)
    {
      free (buffer) ;
      return (NFM_S_SUCCESS) ;
    }

  long_ptr1 = (long *) (list + sizeof (struct NETbuffer_info)) ;

  status =  PCmem_no_rows_columns ((char *)long_ptr1, &no_rows, &no_columns) ;
  if (status != NFM_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "Failure : PCmem_no_rows_columns failed\n")) ;
      return (status) ;
    }

  _NFMdebug ((fname, "Rows to send %d with columns %d\n",
	      no_rows, no_columns)) ;

/* send NETbuffer_info + row-columns info */  
  size = (long) (sizeof (struct NETbuffer_info) + (2*sizeof (long))) ;

  struct_ptr = (struct NETbuffer_info *) list ;
  size_to_send = struct_ptr -> size - size ;
  type_of_transfer = struct_ptr -> request ;
  _NFMdebug ((fname, "type of transfer is %d\n", type_of_transfer)) ;
  new_ptr = (char *) list + size ;

  _NFMdebug ((fname, "Sending to client ...<%d> size <%d>\n",
	      list, size)) ; 

  status = NETbuffer_send (&OUT_PIPE, (char *) list, &size) ;
  if (status != NET_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }

  _NFMdebug ((fname, "receiving ..\n")) ;
  status = NETbuffer_receive (&IN_PIPE, (char *) buffer, &size) ; 
  if (status != NET_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "buffer receive failed : status = <0x%.8x>\n",
	  status)) ;
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }  
  
  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  if (status != NFM_S_SUCCESS)
    {
      _NFMhandshake_abort() ;
      free (buffer) ;
      _NFMdebug ((fname,"First Row of File Server buffer:status : <0x%.8x>\n",
		  status));
      ERRload_struct (NFM, NFM_E_FAILURE, "", "") ;
      return (NFM_E_FAILURE) ;
    }


  /* send all rows one row at a time */
  row_no = 1 ;
  while ((size_to_send > 0) && (row_no <= no_rows))
    {

      block_size_ptr = (short *) new_ptr ;
      _NFMdebug ((fname, "SENDING ROW %d (block %d : %d)\n", 
		  row_no, block_size_ptr, *block_size_ptr)) ;

      size = (long) *block_size_ptr ;
      size_to_send = size_to_send - size ;
/*      _NFMdebug ((fname, "block size <%d> : left to send <%d>\n",
		  size, size_to_send)) ;   */

      status = NETbuffer_send (&OUT_PIPE, (char *) new_ptr, &size) ;
      if (status != NET_S_SUCCESS)
	{
	  free (buffer) ;
	  _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_NET, "", "") ;
	  return (NFM_E_NET) ;
	}
      
      _NFMdebug ((fname, "Waiting for client response...\n")) ;
      status = NETbuffer_receive (&IN_PIPE, (char *) buffer, &size_rcd) ; 
      if (status != NET_S_SUCCESS)
	{
	  free (buffer) ;
	  _NFMdebug ((fname, "buffer receive failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_NET, "", "") ;
	  return (NFM_E_NET) ;
	}  
      struct_ptr = (struct NETbuffer_info *) buffer ;
      client_status = struct_ptr -> request ; 

      sprintf (s_status, "%012d", client_status) ;

      _NFMdebug ((fname, "Writing %s (transfer status 0x%.8x (hex) %.8ld (long)) into buffer into row no %d column %d\n", 
		  s_status, client_status, client_status, 
		  row_no, STATUS_POSITION)) ;
      
      status = PCmem_write_data (list, row_no, 
				 STATUS_POSITION, s_status);
      if (status != NFM_S_SUCCESS)
	{
	  free (buffer) ;
	  _NFMdebug ((fname, "failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      switch (type_of_transfer)
	{
	case FS_SEND_FILES :
	case FS_UNDO_SEND_FILES :
	  if (row_no > 1)
	    {
	      /* if a row exists, the content is the filesize */
	      long_ptr = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
	      rows = *long_ptr ;
	      
	      _NFMdebug ((fname, "buffer received from client has %ld rows\n",
			  rows)) ;
	      
	      if (rows == 1)
		{
		  status = PCmem_read_data ((char *) long_ptr,1,1,s_filesize) ;
		  if (status != NFM_S_SUCCESS)
		    {
		      _NFMdebug ((fname, "MEMread data : status = <0x%.8x>\n",status));
		      return (status) ;
		    }
		  
		  sprintf (s12_filesize, "%012s", s_filesize) ;
		  _NFMdebug ((fname, "filesize received is %s -> writing %s into row %d column %d\n", 
			      s_filesize, s12_filesize,
			      row_no, FILESIZE_POSITION)) ;
		  
		  status = PCmem_write_data (list, row_no, 
					     FILESIZE_POSITION, s12_filesize);
		  if (status != NFM_S_SUCCESS)
		    {
		      free (buffer) ;
		      _NFMdebug ((fname, "failed : status = <0x%.8x>\n",
				  status)) ;
		      return (status) ;
		    }
		}
	      else
		{
		  /* abort */
		  _NFMhandshake_abort () ;
		  free (buffer) ;
		  return (NFM_E_FAILURE) ;
		}
	    }
/* stop if a bad status is found */
	  if (type_of_transfer == FS_SEND_FILES)
	    {
	      switch (client_status)
		{
		case NFM_TRANSFERED :
		  break ;
		  
		case NFM_MOVE_TRANSFERED :
		  break ;
		  
		case NFM_MOVE_MOVE_WARNING :
		  break ;
		  
		  default :
		    _NFMhandshake_abort () ;
		  free (buffer) ;
		  return (NFM_E_FAILURE) ;
		  /*	        break ; */
		}
	    }
	  break ;

	case FS_PURGE :
	  break ;

	case FS_RECV_FILES :
	  break ;

	case FS_UNDO_RECV_FILES :
	  break ;

	case RM_CO_FILES :
	  break ;
	}

/*      _NFMdebug ((fname, "reseting new_ptr (%d) : old %d : ", 
		  size, new_ptr)) ; */
      new_ptr = (char *) (new_ptr + size) ;
/*      _NFMdebug ((fname, "new %d\n", new_ptr)) ; */
      ++row_no ;
    }

  free (buffer) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}





long _NFMhandshake_abort() 
{
  char *fname = "_NFMhandshake_abort" ;
  struct NETbuffer_info *struct_ptr, buf ;
  char   *list ;
  long   status, size ;

  size = (long) (sizeof (struct NETbuffer_info)) ;

  struct_ptr = (struct NETbuffer_info *) &buf ;
  struct_ptr -> request = ABORT_OPERATION ;
  list = (char *) &buf ;

  _NFMdebug ((fname, "sending buffer at %d size %d\n",
	      list, size)) ; 

  status = NETbuffer_send (&OUT_PIPE, (char *) list, &size) ;
  if (status != NET_S_SUCCESS)
    {
      _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }
  _NFMdebug ((fname, "receiving\n")) ;
  status = NETbuffer_receive (&IN_PIPE, (char *) list, &size) ; 
  if (status != NET_S_SUCCESS)
    {
      _NFMdebug ((fname, "buffer receive failed : status = <0x%.8x>\n",
	  status)) ;
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }  

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}



/* can not user a MEMptr but I have to give column name and datatype */
long  _NFMreceive_buf_pc_fs_by_row (list)
     char **list ;
{
  static char *fname = "_NFMreceive_buf_pc_fs_by_row" ;
  long status, size, i ;
  short *size_array_ptr ;
  char *buffer, *data, *str ;
  struct NETbuffer_info *struct_ptr ;
  long rows, cols, *long_ptr, y ;


  _NFMdebug ((fname, "ENTER\n")) ;

  buffer = (char *) malloc (PC_ALLOCATION_SIZE) ;
  if (buffer == NULL)
    {
      _NFMdebug ((fname, "Malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

/******* receive header ********/
  _NFMdebug ((fname, "receiving\n")) ;
  status = NETbuffer_receive (&IN_PIPE, (char *) buffer, &size) ; 
  if (status != NET_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "buffer receive failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }  
/****** get rows and columns *******/
  struct_ptr  = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ;
  long_ptr = (long *) (buffer + sizeof (struct NETbuffer_info)) ;
  rows = *long_ptr ; ++long_ptr ;
  cols = *long_ptr ;
  _NFMdebug ((fname, "rows sent %d : cols sent %d\n",
	      rows, cols)) ;
  
/******* send response *************/
  size = sizeof (struct NETbuffer_info) ;
  struct_ptr = (struct NETbuffer_info *) buffer ;
  struct_ptr->size = size ;
  struct_ptr -> request = NFM_S_SUCCESS ;

  _NFMdebug ((fname, "send response from header\n")) ;
  status = NETbuffer_send (&OUT_PIPE, (char *) buffer, &size) ;
  if (status != NET_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }

/****** build buffer ***************/
  status = _NFMpc_build_buffer (list,  cols);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "UNABLE TO BUILD BUFFER : status = <0x%.8x>\n",
		   status)) ;
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Unabled to build buffer") ;
      return (NFM_E_MESSAGE) ;
    }
  
  str = (char *) malloc (cols * 100) ;
  if (str == NULL)
    {
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      _NFMdebug ((fname, "malloc failed\n")) ;
      return (NFM_E_MALLOC) ;
    }

  /* receive all rows one row at a time */
  for (i=0; i<rows; i++)
    {
      _NFMdebug ((fname, "RECEIVING ROW %d. Waiting for client ...\n", 
		  i+1)) ;
      status = NETbuffer_receive (&IN_PIPE, (char *) buffer, &size);
      if (status != NET_S_SUCCESS)
	{
	  free (buffer) ;
	  free (str) ;
	  _NFMdebug ((fname, "buffer receive failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_NET, "", "") ;
	  return (NFM_E_NET) ;
	} 

      size_array_ptr = (short *) (buffer+sizeof(short)) ;
      data = ((char *) size_array_ptr +  (cols * sizeof (short))) ;
      str [0] = 0 ;
      for (y=0; y<cols; y++)
	{
	  strcat (str, data) ;
	  strcat (str, "\001") ;
	  data += *size_array_ptr ;
	  ++size_array_ptr ;
	}
      /**** write row *******/
      status = _NFMpc_write_row (list, str) ;
      if (status != NFM_S_SUCCESS)
        {
          free (str) ;
	  free (buffer) ;
          _NFMdebug ((fname, "PC write failed : status = <0x%.8x>\n",
                      status)) ;
          return (status) ;
        }
      
      struct_ptr = (struct NETbuffer_info *) buffer ;
      struct_ptr -> request  = NFM_S_SUCCESS ;
      size = struct_ptr -> size = sizeof (struct NETbuffer_info *) ;
      _NFMdebug ((fname, "sending to client..\n")) ;
      status = NETbuffer_send (&OUT_PIPE, (char *) buffer, &size) ;
      if (status != NET_S_SUCCESS)
	{
	  free (str) ;
	  free (buffer) ;
	  _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_NET, "", "") ;
	  return (NFM_E_NET) ;
	}
    }  /* for */

  free (buffer) ;
  free (str) ;
  if (_NFMdebug_st.NFMdebug_on)
    status = _NFMpc_print_mem_buffer ("file server buffer", *list,
				    _NFMdebug_st.NFMdebug_file) ;  

  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMconvert_buf_to_pcbuf (list, pc_list) 
     MEMptr list ;
     char   **pc_list ;
{
  char *fname = "_NFMconvert_buf_to_pcbuf" ;
  long status ;
  long x, y, offset, insert ;
  char **data, *str, tmp_str [512], **column, *temp_list = NULL ;
  char d_passwd [50], value [50], message [512], *c_status;
  char internet_address [NFM_NODENAME+1] ;
  _NFMdebug ((fname, "ENTER\n")) ;

  status = MEMbuild_array (list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array list : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  data = (char **) list->data_ptr ;
  column = (char **) list->column_ptr ;

  status = _NFMpc_build_buffer (&temp_list, NO_COLUMNS_TRANSFER) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PC build buffer : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  if (_NFMdebug_st.NFMdebug_on)
    status = _NFMpc_print_mem_buffer ("file server buffer", temp_list,
				      _NFMdebug_st.NFMdebug_file) ;
  str = (char *) malloc (list->row_size + 100) ;
  if (str == NULL)
    {
      _NFMdebug ((fname, "Malloc : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  for (x=0; x<list->rows; x++)
    {
      str [0] = 0 ;

      offset = x*list->columns ;
      for (y=0; y<list->columns; y++)
	{
	  insert = 0 ;
/*	  _NFMdebug ((fname, "column %s : data %s\n",
		      column [y], data [offset+y])) ;	   */
	  if (strcmp (column [y], "n_nodename") == 0) 
	    {
/* send the internet address here */
	      c_status = (char *) clh_vbyop (data [offset+y],
					     "tcp_address",
					     internet_address,
					     NFM_NODENAME+1) ;
	      if (c_status)
		{
/*
		  sprintf (message, "node %s has no internel address",
			   data [offset+y]) ;
		  _NFMdebug ((fname, "error : %s\n", message)) ;
		  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
		  return (NFM_E_MESSAGE) ;
*/
		  sprintf (tmp_str, "%s", data [offset+y]) ;
		}
	      else
		{
		  sprintf (tmp_str, "%s", internet_address) ;
		}
	      insert = 1 ;
	    }
	  else if (strcmp (column [y], "n_username") == 0) 
	    {
	      sprintf (tmp_str, "%s", data [offset+y]) ;
	      insert = 1;
	    }
	  else if (strcmp (column [y], "n_passwd") == 0) 
	    {
	      sprintf (value, "%-25.25s", data [offset+y]);
	      status = NFMdecrypt (value, d_passwd);
	      if (status != NFM_S_SUCCESS)
		{
		  _NFMdebug ((fname, "Decryption failed : status = <0x%.8x>\n",
			      status)) ;
		  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
				  "Decryption failed") ;
		  return (NFM_E_MESSAGE) ;
		}
	      sprintf (tmp_str, "%s", d_passwd) ;
	      insert = 1 ;
	    }
	  else if (strcmp (column [y], "n_pathname") == 0) 
	    {
	      sprintf (tmp_str, "%s", data [offset+y]) ;
	      insert = 1;
	    }
	  else if (strcmp (column [y], "n_nfs") == 0) 
	    {
	      sprintf (tmp_str, "%s", data [offset+y]) ;
	      insert = 1 ;
	    }
	  else if (strcmp (column [y], "n_mountpoint") == 0) 
	    {
	      sprintf (tmp_str, "%s", data [offset+y]) ;
	      insert = 1 ;
	    }
	  else if (strcmp (column [y], "n_fileold") == 0) 
	    {
	      sprintf (tmp_str, "%s", data [offset+y]) ;
	      insert = 1 ;
	    }
	  else if (strcmp (column [y], "n_cifilename") == 0) 
	    {
	      sprintf (tmp_str, "%s", data [offset+y]) ;
	      insert = 1 ;
	    }
	  else if (strcmp (column [y], "n_cofilename") == 0) 
	    {
	      status = NFMvalidate_pc_filename (data [offset+y]) ;
	      if (status != NFM_S_SUCCESS)
		{
		  sprintf (message, "Invalid pc filename %s",
			      data [offset+y]) ;
		  _NFMdebug ((fname, "%s\n", message));
		  ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
		  return (NFM_E_MESSAGE) ;
		}
	      sprintf (tmp_str, "%s", data [offset+y]) ;
	      insert = 1 ;
	    }
	  else if (strcmp (column [y], "n_filesize") == 0) 
	    {
	      if (strlen (data [offset+y]))
		{
		  sprintf (tmp_str, "%012s", data [offset+y]) ;
		}
	      else
		{
		  sprintf (tmp_str, "%012ld", 0) ;
		}
	      _NFMdebug ((fname, "filesize is %s\n", tmp_str)) ;
	      insert = 1 ;
	    }
	  else if (strcmp (column [y], "n_status1") == 0) 
	    {
	      if (strlen (data [offset+y]))
		sprintf (tmp_str, "%012s", data [offset+y]) ;
	      else
		sprintf (tmp_str, "%012ld", NFM_S_SUCCESS) ;
	      insert = 1 ;
	    }
	  else insert = 0 ;
	  if (insert)
	    {
	      strcat (str, tmp_str) ;
	      strcat (str, "\001") ;
	    }
	}
      
      status = _NFMpc_write_row (&temp_list, str) ;
      if (status != NFM_S_SUCCESS)
	{
	  free (str) ;
	  _NFMdebug ((fname, "PC write failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}


    }

  free (str) ;
  
  *pc_list = temp_list ;
  if (_NFMdebug_st.NFMdebug_on)
    _NFMpc_print_mem_buffer ("PC TRANSFER BUFFER", temp_list,
			     _NFMdebug_st.NFMdebug_file) ;
  
  _NFMdebug ((fname, "SUCCESSFUL : pointer is %ld\n", *pc_list)) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMconvert_pcbuf_to_buf (list, pc_list) 
     MEMptr list ;
     char   **pc_list ;
{
  char *fname = "_NFMconvert_pcbuf_to_buf" ;
  long status ;
  long x, rows, columns, *long_ptr ;
  char **data, *str, **column ;

  _NFMdebug ((fname, "ENTER\n")) ;

  status = MEMbuild_array (list) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array list : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }
  data = (char **) list->data_ptr ;
  column = (char **) list->column_ptr ;

  _NFMdebug ((fname, "POINTER TO LIST IS %d\n", *pc_list)) ;
  if (_NFMdebug_st.NFMdebug_on)
    status = _NFMpc_print_mem_buffer ("file server buffer", *pc_list,
				      _NFMdebug_st.NFMdebug_file) ;

  str = (char *) malloc (list->row_size + 100) ;
  if (str == NULL)
    {
      _NFMdebug ((fname, "Malloc : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }
/*  get rows, columns of pc buffer */

  long_ptr = (long *) (*pc_list + sizeof (struct NETbuffer_info)) ;
  _NFMdebug ((fname, "POINTER TO LONG POINTER %d\n", long_ptr)) ;
  status =  PCmem_no_rows_columns ((char *)long_ptr, &rows, &columns) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PCmem_no_rows_columns failed\n")) ;
      return (NFM_E_MEM) ;
    }
  _NFMdebug ((fname, "rows are %d : columns are %d\n",
	      rows, columns)) ;

/*  if columns do not match return */
  if (list->columns != columns)
    {
      _NFMdebug ((fname, "columns mismatch : %d : %d\n",
		  list->columns, columns)) ;
      return (NFM_E_MESSAGE) ;
    }


  for (x=0; x<rows; x++)
    {
      str [0] = 0 ;

      status = PCmem_read_row ((char *) long_ptr, x+1, str) ;
      if (status != NFM_S_SUCCESS)
	{
	  free (str) ;
	  _NFMdebug ((fname, "PC write failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      status = MEMwrite (list, str) ;
      if (status != MEM_S_SUCCESS)
	{
	  free (str) ;
	  _NFMdebug ((fname, "MEMwrite row : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
    }

  free (str) ;
  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("transfer buffer", list, _NFMdebug_st.NFMdebug_file) ;
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMpc_file_server (move_list)
     MEMptr move_list ;
{
  char *fname = "_NFMpc_file_server" ;
  long status,num_rows, num_cols, i;
  char *pc_list = NULL, s_status [20], s_filesize [20], *buf ;
  struct NETbuffer_info *list_ptr ;
  long _NFMconvert_buf_to_pcbuf () ;

  _NFMdebug ((fname, "ENTER\n")) ;

  status = _NFMconvert_buf_to_pcbuf (move_list, &pc_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname,"convert status = 0x%.8x\n", status));
      return (status) ;
    }

  list_ptr = (struct NETbuffer_info *) pc_list ;
  list_ptr -> request = -1 ;
  if (_NFMdebug_st.NFMdebug_on)
    {
      status = _NFMpc_print_mem_buffer ("file server buffer", pc_list,
					_NFMdebug_st.NFMdebug_file) ;
    }

  status =  _NFMsend_buf_pc_fs_by_row (pc_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "send buf pc fs by row failed : status = <0x%.8x>\n",
		  status)) ;
      return (status);               
    }
  if (_NFMdebug_st.NFMdebug_on)
    status = _NFMpc_print_mem_buffer ("file server buffer", pc_list,
				      _NFMdebug_st.NFMdebug_file) ;

  /* write filesize and status back to original buffer */
  /* get rows in pcbuffer */

  buf = (char *) (pc_list + sizeof (struct NETbuffer_info));
  status = PCmem_no_rows_columns (buf, &num_rows, &num_cols) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PC mem no rows failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  for (i=0; i<num_rows; i++)
    {
      status = PCmem_read_data (buf, i+1, FILESIZE_POSITION, s_filesize) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "PCmem_read_data : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      status = PCmem_read_data (buf, i+1,  STATUS_POSITION, s_status) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "PCmem_read_data : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      _NFMdebug ((fname, "row %d column %d has filesize %s status %s\n",
		  i+1, STATUS_POSITION, s_filesize, s_status)) ;
    }

  if (pc_list) 
    {
      free(pc_list) ;
    }
  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("move list", *move_list, _NFMdebug_st.NFMdebug_file) ; 

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMpcfs_send_files (move_list, NETid, close_flag)
     MEMptr *move_list ;
     long   *NETid ;
     long   close_flag ;
{
  char *fname = "_NFMpcfs_send_files";
  long status ;

  _NFMdebug ((fname, "ENTER\n")) ;
  *NETid = *NETid ;
  close_flag = close_flag ;

  status = _NFMpcfs_commands (FS_SEND_FILES, move_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Pc Fs commands : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMpcfs_undo_send_files (move_list)
     MEMptr *move_list ;
{
  char *fname = "_NFMpcfs_undo_send_files" ;
  long status ;

  _NFMdebug ((fname, "ENTER\n")) ;

  status = _NFMpcfs_commands (FS_UNDO_SEND_FILES, move_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Pc Fs commands : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long NFMpcfs_purge (move_list)
     MEMptr *move_list ;
{
  char *fname = "NFMpcfs_purge" ;
  long status ;

  _NFMdebug ((fname, "ENTER\n")) ;

  if ((*move_list) -> rows == 0)
    {
      _NFMdebug ((fname, "No files to purge\n")) ;
      return (NFM_S_SUCCESS) ;
    }

  status = _NFMpcfs_commands (FS_PURGE, move_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Pc Fs commands : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMpcfs_undo_recv_files (move_list)
     MEMptr *move_list ;
{
  char *fname = "_NFMpcfs_undo_recv_files"; 
  long status ;

  _NFMdebug ((fname, "ENTER\n")) ;

  status = _NFMpcfs_commands (FS_UNDO_RECV_FILES, move_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Pc Fs commands : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMpcfs_recv_files (move_list)
     MEMptr *move_list ;
{
  char *fname = "_NFMpcfs_recv_files";
  long status ;

  _NFMdebug ((fname, "ENTER\n")) ;

  status = _NFMpcfs_commands (FS_RECV_FILES, move_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Pc Fs commands : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}



long NFMpcrm_co_files (move_list, net_id)
     MEMptr *move_list ;
     long   net_id ; /* not used */
{
  char *fname = "NFMpcrm_co_files";
  long status ;

  net_id = net_id ;
  _NFMdebug ((fname, "ENTER\n")) ;

  status = _NFMpcfs_commands (RM_CO_FILES, move_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : Pc Fs commands : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long NFMpcfs_get_list_attached_reference_files (nodename,
						username,
						passwd,
						path, cofilename, 
						att_files_list)
     char *nodename ;
     char *username ;
     char *passwd ;
     char *path ;
     char *cofilename ;
     MEMptr *att_files_list ;
{
  char *fname = "NFMpcfs_get_list_attached_reference_files";
  long status, size, *long_ptr, rows, columns ;
  char *list, str [100], *att_list ;
  struct NETbuffer_info *ptr_struct ;

  _NFMdebug ((fname, "ENTER path %s : cofilename %s\n",
	      path, cofilename)) ;
  *passwd = *passwd ;
  *username = *username ;
  *nodename = *nodename ;
  
  status = NFMvalidate_pc_filename (cofilename) ;
  if (status != NFM_S_SUCCESS)
    {
      sprintf (message, "Invalid pc filename %s",
	       cofilename) ;
      _NFMdebug ((fname, "%s\n", message));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s", message) ;
      return (NFM_E_MESSAGE) ;
    }


  status = _NFMpc_build_buffer (&list,  2);
  if (status != NFM_S_SUCCESS)
    {
      _NFMSdebug ((fname, "UNABLE TO BUILD BUFFER : status = <0x%.8x>\n",
		   status)) ;
      return (NFM_E_MESSAGE) ;
    }
  
  sprintf (str, "%s\001%s\001", path, cofilename) ;

  status = _NFMpc_write_row (&list, str) ;
  if (status != NFM_S_SUCCESS)
    {
      free (str) ;
      free (list) ;
      _NFMdebug ((fname, "PC write failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  ptr_struct = (struct NETbuffer_info *) list ;
  ptr_struct -> request = FS_LIST_ATTACHED_FILES ;
  size = ptr_struct ->size ;
  _NFMdebug ((fname, "size sent is %d\n", size)) ;

  status = NETbuffer_send (&OUT_PIPE, (char *) list, &size) ;
  if (status != NET_S_SUCCESS)
    {
      free (list) ;
      _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }

  if (list) free (list) ;

  status =  _NFMreceive_buf_pc_fs_by_row (&att_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "receive buf pc fs by row failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  long_ptr = (long *) (att_list + sizeof (struct NETbuffer_info)) ;

  status =  PCmem_no_rows_columns ((char *) long_ptr, &rows, &columns) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PCmem_no_rows_columns failed : status : <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
/*
  if (rows == 0)
    {
      _NFMdebug ((fname, "NO ATTACHED FILES\n")) ;
      return (NFM_S_SUCCESS) ;
    }
*/

  _NFMdebug ((fname, "POINTER IS %d\n", att_list)) ;
  if (_NFMdebug_st.NFMdebug_on)
    _NFMpc_print_mem_buffer ("file server buffer", att_list,
			     _NFMdebug_st.NFMdebug_file) ;

  status = MEMopen (att_files_list) ;
  if (status != MEM_S_SUCCESS)
    {
      free (att_list) ;
      _NFMdebug ((fname, "MEMopen failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "");
      return (NFM_E_MEM) ;
    }

  status = MEMwrite_format (*att_files_list, "n_cofilename", "char(50)") ;
  if (status != MEM_S_SUCCESS)
    {
      free (att_list) ;
      _NFMdebug ((fname, "MEMopen failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  if (rows == 0)
  {
	free (att_list) ;
	_NFMdebug ((fname,  "NO FILES ATTACHED\n"))
	return (NFM_S_SUCCESS) ;
  }
  status = _NFMconvert_pcbuf_to_buf (*att_files_list, &att_list) ;
  if (status != NFM_S_SUCCESS)
    {
      free (att_list) ;
      _NFMdebug ((fname, "convert pc to mem failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  
  if (att_list) free(att_list) ;
  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("att list", *att_files_list, _NFMdebug_st.NFMdebug_file) ; 

  _NFMdebug ((fname, "Return Status = <0x%.8x>\n", status)) ;
  return (status) ;
}

long _NFMwrite_status_to_buffer (type_of_transfer, pc_list, move_list,
				 transfer_status)
     long type_of_transfer ;
     char *pc_list ;
     MEMptr **move_list ;
     long *transfer_status ;
{
  char *fname = "_NFMwrite_status_to_buffer" ;
  char s_status [20], s_filesize [20] ;
  long i, status, num_rows, num_cols ;
  char *buf ;

  *transfer_status = NFM_S_SUCCESS ;
  buf = (char *) (pc_list + sizeof (struct NETbuffer_info));
  status = PCmem_no_rows_columns (buf, &num_rows, &num_cols) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PC mem no rows failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  /* write filesize and status back to original buffer */
  /* get rows in pcbuffer */

  for (i=0; i<num_rows; i++)
    {
      if ((type_of_transfer == FS_SEND_FILES) ||
	  (type_of_transfer == FS_UNDO_SEND_FILES))
	{
	  status = PCmem_read_data (buf, i+1, FILESIZE_POSITION, s_filesize) ;
	  if (status != NFM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "PCmem_read_data : status = <0x%.8x>\n",
			  status)) ;
	      return (status) ;
	    }
	  _NFMdebug ((fname, "writing %s into row %d col %d\n",
		      s_filesize, i+1, FTO_CIFILESIZE+1)) ;
	  status = MEMwrite_data (**move_list, s_filesize, i+1, FTO_CIFILESIZE+1);
	  if (status != MEM_S_SUCCESS)
	    {
	      _NFMdebug ((fname, "Failure : MEMwrite_data : status = <0x%.8x>\n",
			  status));
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (status) ;
	    }
	}

      
      status = PCmem_read_data (buf, i+1,  STATUS_POSITION, s_status) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "PCmem_read_data : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}

      _NFMdebug ((fname, "writing %s into row %d col %d\n",
		  s_status, i+1, FTO_STATUS1+1)) ;

      status = MEMwrite_data (**move_list, s_status, i+1, FTO_STATUS1+1);
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "MEMwrite_data : status = <0x%.8x>\n", status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}

      _NFMdebug ((fname, "row %d column %d has status %s\n",
		  i+1, STATUS_POSITION, s_status)) ;

      status = atol (s_status) ;
      if (*transfer_status == NFM_S_SUCCESS)
	{
	  switch (type_of_transfer)
	    {
	    case FS_RECV_FILES :
	      if (( i != 0) && (status != NFM_TRANSFERED) &&
		  (status != NFM_NFSED))
		*transfer_status = status ;
	      break ;
	      
	    case FS_UNDO_RECV_FILES :
	      if ((i != 0) && (status != NFM_UNDONE) &&
		  (status != NFM_NFS_UNDONE) &&
		  (status != NFM_READ_DONE))
		*transfer_status = status ;
	      break ;

	    case FS_PURGE :
	      if (status != NFM_PURGED)
		*transfer_status = status ;
	      break ;

	    case RM_CO_FILES:
	      if ((i != 0) && (status != NFM_REMOVED))
		*transfer_status = status ;
	      break ;
	    }
	}

    }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("move list", **move_list, _NFMdebug_st.NFMdebug_file) ; 

  _NFMdebug ((fname, "transfer status <%0x%.8x>\n", *transfer_status)) ;
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMconvert_buf_to_list (list, pc_list) 
     MEMptr list ;
     char   **pc_list ;
{
  char *fname = "_NFMconvert_buf_to_list" ;
  long status ;
  long x, y, offset ;
  char **data, *str, tmp_str [512], **column, *temp_list = NULL ;
  _NFMdebug ((fname, "ENTER\n")) ;

  status = MEMbuild_array (list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array list : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  data = (char **) list->data_ptr ;
  column = (char **) list->column_ptr ;

  status = _NFMpc_build_buffer (&temp_list, list->columns);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PC build buffer : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }
  if (_NFMdebug_st.NFMdebug_on)
    status = _NFMpc_print_mem_buffer ("file server buffer", temp_list,
				      _NFMdebug_st.NFMdebug_file) ;
  str = (char *) malloc (list->row_size + 100) ;
  if (str == NULL)
    {
      _NFMdebug ((fname, "Malloc : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  for (x=0; x<list->rows; x++)
    {
      str [0] = 0 ;

      offset = x*list->columns ;
      for (y=0; y<list->columns; y++)
	{
	  sprintf (tmp_str, "%s", data [offset+y]) ;
	  strcat (str, tmp_str) ;
	  strcat (str, "\001") ;
	}
      
      status = _NFMpc_write_row (&temp_list, str) ;
      if (status != NFM_S_SUCCESS)
	{
	  free (str) ;
	  _NFMdebug ((fname, "PC write failed : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
    }

  free (str) ;
  
  *pc_list = temp_list ;
  if (_NFMdebug_st.NFMdebug_on)
    _NFMpc_print_mem_buffer ("PC TRANSFER BUFFER", temp_list,
			     _NFMdebug_st.NFMdebug_file) ;
  
  _NFMdebug ((fname, "SUCCESSFUL : pointer is %ld\n", *pc_list)) ;
  return (NFM_S_SUCCESS) ;
}


long _NFMconvert_format_to_list (list, pc_list) 
     MEMptr list ;
     char   **pc_list ;
{
  char *fname = "_NFMconvert_format_to_list" ;
  long status ;
  long x, y, offset ;
  char **data, *str, tmp_str [512], **column, *temp_list = NULL ;
  char **format ;
  _NFMdebug ((fname, "ENTER\n")) ;

  status = MEMbuild_array (list) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array list : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  format = (char **) list->format_ptr ;

  status = _NFMpc_build_buffer (&temp_list, list->columns);
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "PC build buffer : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  str = (char *) malloc (list->row_size + 100) ;
  if (str == NULL)
    {
      _NFMdebug ((fname, "Malloc : status = <0x%.8x>\n", status)) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  str [0] = 0 ;
  for (y=0; y<list->columns; y++)
    {
      strcat (str, format [y]) ;
      strcat (str, "\001") ;
    }
  
  status = _NFMpc_write_row (&temp_list, str) ;
  if (status != NFM_S_SUCCESS)
    {
      free (str) ;
      _NFMdebug ((fname, "PC write failed : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  free (str) ;
  
  *pc_list = temp_list ;
  if (_NFMdebug_st.NFMdebug_on)
    _NFMpc_print_mem_buffer ("PC TRANSFER BUFFER", temp_list,
			     _NFMdebug_st.NFMdebug_file) ;
  
  _NFMdebug ((fname, "SUCCESSFUL : pointer is %ld\n", *pc_list)) ;
  return (NFM_S_SUCCESS) ;
}

long  _NFMsend_by_row_for_display (list)
     char *list ;
{
  static char *fname = "_NFMsend_by_row_for_display" ;
  long status, size, size_to_send, size_rcd ;
  short *block_size_ptr ;
  char *buffer, *new_ptr ;
  long  type_of_transfer ;
  struct NETbuffer_info *struct_ptr ;
  long row_no, *long_ptr1, no_rows, no_columns ;
  long client_status ;
  long _NFMhandshake_abort()  ;

  _NFMdebug ((fname, "ENTER\n")) ;

  buffer = (char *) malloc (PC_ALLOCATION_SIZE) ;
  if (buffer == NULL)
    {
      _NFMdebug ((fname, "Failure : Malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  if (!list)
    {
      free (buffer) ;
      return (NFM_S_SUCCESS) ;
    }

  long_ptr1 = (long *) (list + sizeof (struct NETbuffer_info)) ;

  status =  PCmem_no_rows_columns ((char *)long_ptr1, &no_rows, &no_columns) ;
  if (status != NFM_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "Failure : PCmem_no_rows_columns failed\n")) ;
      return (status) ;
    }

  _NFMdebug ((fname, "Rows to send %d rows  with columns %d\n",
	      no_rows, no_columns)) ;

/* send NETbuffer_info + row-columns info */  
  size = (long) (sizeof (struct NETbuffer_info) + (2*sizeof (long))) ;

  struct_ptr = (struct NETbuffer_info *) list ;
  size_to_send = struct_ptr -> size - size ;
  type_of_transfer = struct_ptr -> request ;
  _NFMdebug ((fname, "type of transfer is %d\n", type_of_transfer)) ;
  new_ptr = (char *) list + size ;

  _NFMdebug ((fname, "Sending HEADER to client ...<%d> size <%d>\n",
	      list, size)) ; 

  status = NETbuffer_send (&OUT_PIPE, (char *) list, &size) ;
  if (status != NET_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }

  _NFMdebug ((fname, "receiving ..\n")) ;
  status = NETbuffer_receive (&IN_PIPE, (char *) buffer, &size) ; 
  if (status != NET_S_SUCCESS)
    {
      free (buffer) ;
      _NFMdebug ((fname, "buffer receive failed : status = <0x%.8x>\n",
	  status)) ;
      ERRload_struct (NFM, NFM_E_NET, "", "") ;
      return (NFM_E_NET) ;
    }  

  struct_ptr = (struct NETbuffer_info *) buffer ;
  status = struct_ptr -> request ; 
  _NFMdebug ((fname, "STATUS received from client was 0x%.8x\n", status)) ;
/******* for now ******
  if (status != NFM_S_SUCCESS)
    {
      _NFMhandshake_abort() ;
      free (buffer) ;
      _NFMdebug ((fname,"First Row of File Server buffer:status : <0x%.8x>\n",
		  status));
      ERRload_struct (NFM, NFM_E_FAILURE, "", "") ;
      return (NFM_E_FAILURE) ;
    }
************************/
  /* send all rows one row at a time */
  row_no = 1 ;
  while ((size_to_send > 0) && (row_no <= no_rows))
    {

      block_size_ptr = (short *) new_ptr ;
      _NFMdebug ((fname, "SENDING ROW %d (block %d : %d)\n", 
		  row_no, block_size_ptr, *block_size_ptr)) ;

      size = (long) *block_size_ptr ;
      size_to_send = size_to_send - size ;
/*      _NFMdebug ((fname, "block size <%d> : left to send <%d>\n",
		  size, size_to_send)) ;   */

      status = NETbuffer_send (&OUT_PIPE, (char *) new_ptr, &size) ;
      if (status != NET_S_SUCCESS)
	{
	  free (buffer) ;
	  _NFMdebug ((fname, "buffer send failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_NET, "", "") ;
	  return (NFM_E_NET) ;
	}
      
      _NFMdebug ((fname, "Waiting for client response...\n")) ;
      status = NETbuffer_receive (&IN_PIPE, (char *) buffer, &size_rcd) ; 
      if (status != NET_S_SUCCESS)
	{
	  free (buffer) ;
	  _NFMdebug ((fname, "buffer receive failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_NET, "", "") ;
	  return (NFM_E_NET) ;
	}  

      struct_ptr = (struct NETbuffer_info *) buffer ;
      client_status = struct_ptr -> request ; 
      _NFMdebug ((fname, "client status is 0x%.8x>\n", client_status)) ;
/***** for now - 
      if (client_status != NFM_S_SUCCESS)
	{
	}
********/
      new_ptr = (char *) (new_ptr + size) ;
      ++row_no ;
    }

  free (buffer) ;

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}



