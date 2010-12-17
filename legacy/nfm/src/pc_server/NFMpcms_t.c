#include "machine.h"
#include "NFMitems.h"
#include "NFMapi.h"
#include "NFMfto_buf.h"
#include "CMDTOOLS.h"

  extern struct NFMglobal_st NFMglobal ;


long _NFMpcdelete_file_LFM (no_dropped, list_member, file_info, sa_struct,
			  operation) 
     long   no_dropped ;
     struct NFMset_member *list_member ;
     struct file_info_struct *file_info ;
     struct NFMsto_info sa_struct ;
     struct NFMoperation *operation ;
{
  static char *fname = "_NFMdelete_file_LFM" ;
  struct file_info_struct *file_ptr ;
  long or_clause, delete_files, status, i, offset, ref_no ;
  char *sql_str, *str, tmp_str [512], **data ;
  MEMptr sql_buffer = NULL, move_buffer = NULL ;
  struct fto_buf file_buffer ;
  long _NFMload_first_row_fto_buf ();
  long _NFMload_data_rows_fto_buf () ;
  /* check LFM */
  
  _NFMdebug ((fname, "ENTER : number dropped %d\n", no_dropped)) ;

  *list_member = *list_member ;
  
  or_clause = 0 ;

  sql_str = (char *) malloc (no_dropped*200) ;
  if (sql_str == NULL)
    {
      _NFMdebug ((fname, "malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }
  sql_str [0] = 0 ;
  str = (char *) malloc (no_dropped*200+512) ;
  if (str == NULL)
    {
      free (sql_str) ;
      _NFMdebug ((fname, "Malloc failed (str)\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }
  str [0] = 0 ;
  delete_files = 0 ;
  file_ptr = (struct file_info_struct *) file_info ;

  while (file_ptr != NULL)
    {
      if (file_ptr->member_ptr->flag == 1)
	{
	  _NFMdebug ((fname, "flagged\n")) ;
	  if (or_clause)
	    {
	      strcat (sql_str, " OR ") ;
	    }
	  else or_clause = 1 ;
	  
	  _NFMdebug ((fname, "sano %d cofilename %s cat no %d itemno %d\n",
		      sa_struct.sano, file_ptr->n_cofilename,
		      file_ptr->member_ptr->cat_no, file_ptr->n_itemno)) ;
	  
	  sprintf (tmp_str, " (n_sano = %d and  n_filename = '%s' and n_catalogno = %d and n_itemno = %d and n_filenum = %d and n_fileversion = %d) ",
		   sa_struct.sano, 
		   file_ptr->n_cofilename, 
		   file_ptr->member_ptr->cat_no,
		   file_ptr->n_itemno,
		   file_ptr->n_filenum,
		   file_ptr->n_fileversion) ;
	  strcat (sql_str, tmp_str) ;
	}
      file_ptr = file_ptr -> ptr ;
   }

  sprintf (str, "select n_filename, n_catalogno, n_itemno, n_filenum, n_fileversion, n_co, n_copy, n_ref from nfmsafiles where %s",
	   sql_str) ;

  free (sql_str) ;
  status = SQLquery (str, &sql_buffer, MEM_SIZE) ;
  free (str) ;
  if (status != SQL_S_SUCCESS) 
    {
      MEMclose (&sql_buffer) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
/******* QUESTION  ************/
	  _NFMdebug ((fname, "no rows in nfmsafiles - Per document leave the file\n")) ;
	  return (NFM_S_SUCCESS) ;
	}
      _NFMdebug ((fname, "SQLquery : status : <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer->data_ptr ;

  file_ptr = (struct file_info_struct *) file_info ;

  if (operation -> delete != NFM_NO_DELETE)
  while (file_ptr != NULL)
    {
      strcpy (file_ptr->file_action,"N") ;
      if (file_ptr->member_ptr->flag == 1)
	{
	  for (i=0; i<sql_buffer->rows; i++)
	    {
	      offset = sql_buffer->columns*i;
	      _NFMdebug ((fname, "%s : %s\n", file_ptr->n_cofilename,
			  data [offset])) ;
	      _NFMdebug ((fname, "%d : %d\n", file_ptr->member_ptr->cat_no,
			  atol (data [offset+1]))) ;
	      _NFMdebug ((fname, "%d : %d\n", file_ptr->n_filenum,
			  atol (data [offset+3])));
	      _NFMdebug ((fname, "%d : %d\n", file_ptr->n_fileversion,
			  atol (data [offset+4]))) ;
	      _NFMdebug ((fname, "%s : %s : %s\n",
			  data [offset+5], data [offset+6], data [offset+7])) ;
	      _NFMdebug ((fname, "operation delete %d\n", operation->delete)) ;
	      if (!strcmp (file_ptr->n_cofilename, data [offset]) &&
		  (file_ptr->member_ptr->cat_no == atol (data [offset+1])) &&
		  (file_ptr->member_ptr->item_no == atol (data [offset+2])) &&
		  (file_ptr->n_filenum == atol (data [offset+3])) &&
		  (file_ptr->n_fileversion == atol (data [offset+4])))
		
		{
		  _NFMdebug ((fname, "match..\n")) ;
		  strcpy (file_ptr->ms_action, "D") ;
		  
		  if (operation->delete == NFM_CONDITIONAL_DELETE)
		    {
		      if ((!strcmp (data[offset+5], "N")) &&
			  (!strcmp (data[offset+6], "N")) &&
			  (!strcmp (data[offset+7], "1")))
			{
			  _NFMdebug ((fname, "n_co = N n_copy = N n_ref =1 delete file per local file manager\n")) ;
			  _NFMdebug ((fname, "Delete file per LFM\n")) ;
			  strcpy (file_ptr->file_action, "D") ;
			  delete_files = 1 ;
			  if (!move_buffer)				
			    {
			      status = _NFMget_sano_info_fto_buf (sa_struct.sano, "", 
								  &file_buffer) ;
			      if (status != NFM_S_SUCCESS)
				{
				  MEMclose (&sql_buffer) ;
				  _NFMdebug ((fname, "Get sano info failed : status = <0x%.8x>\n",
					      status)) ;
				  return (status) ;
				}
			      
			      status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
			      if (status != NFM_S_SUCCESS)
				{
				  MEMclose (&sql_buffer) ;
				  MEMclose (&move_buffer) ;
				  _NFMdebug ((fname, "build file transfer buffer failed : status = <0x%.8x>\n",
					      status)) ;
				  return (status) ;
				}
			      
			      status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
			      if (status != NFM_S_SUCCESS)
				{
				  MEMclose (&sql_buffer) ;
				  MEMclose (&move_buffer) ;
				  _NFMdebug ((fname, "load fto buf failed : status = <0x%.8x>\n",
					      status)) ;
				  return (status) ;
				}
			    }
			  
			  strcpy (file_buffer.n_cofilename, data [offset]) ;
			  file_buffer.n_status1 = NFM_DELETE_FILE ;
			  status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
			  if (status != NFM_S_SUCCESS)
			    {
			      MEMclose (&move_buffer) ;
			      MEMclose (&sql_buffer) ;
			      _NFMdebug ((fname, "load fto buf failed : status = <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			  
			  if (_NFMdebug_st.NFMdebug_on)			    
			    MEMprint_buffer ("move buffer", move_buffer, _NFMdebug_st.NFMdebug_file);
			  
			  strcpy (file_ptr->lfm_action, "D") ;
			  sprintf (tmp_str,
				   "delete from nfmsafiles where n_filename = '%s' and n_sano = %d and n_catalogno = %s and n_itemno = %s and n_filenum = %s and n_fileversion = %s",
				   data[offset], 
				   sa_struct.sano, 
				   data [offset+1], data [offset+2],
				   data[offset+3], data [offset+4]) ;
			  
			  status = SQLexec_imm (tmp_str) ;
			  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
			    {
			      MEMclose (&sql_buffer) ;
			      MEMclose (&move_buffer) ;
			      _NFMdebug ((fname, "SQL failed : status = <0x%.8x>\n",
					  status)) ;
			      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
			      return (NFM_E_SQL_STMT) ;
			    }
			  
			} 
		      else
			{
			  strcpy (file_ptr->lfm_action, "U") ;
			  ref_no = (long) atol (data [offset+7]) - 1 ;
			  sprintf (tmp_str, "update nfmsafiles set n_ref = %d where n_filename = '%s' and n_sano = %d and n_catalogno = %s and n_itemno = %s and n_filenum = %s and n_fileversion = %s",
				   ref_no,
				   data[offset], 
				   sa_struct.sano, 
				   data [offset+1], data [offset+2],
				   data[offset+3], data [offset+4]) ;
			  
			  
			  status = SQLexec_imm (tmp_str) ;
			  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
			    {
			      MEMclose (&sql_buffer) ;
			      MEMclose (&move_buffer) ;
			      _NFMdebug ((fname, "SQL exec_imm failed : status = <0x%.8x>\n",
					  status)) ;
			      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
			      return (NFM_E_SQL_STMT) ;
			    }
			}  /* LFM check */
		      
		    } /* NFM_CONDITIONAL_DELETE */
		  else
		    {
		      _NFMdebug ((fname, "Delete file\n")) ;
		      strcpy (file_ptr->file_action, "D") ;
		      delete_files = 1 ;
		      if (!move_buffer)				
			{
			  status = _NFMget_sano_info_fto_buf (sa_struct.sano, "", 
							      &file_buffer) ;
			  if (status != NFM_S_SUCCESS)
			    {
			      MEMclose (&sql_buffer) ;
			      _NFMdebug ((fname, "Get sano info failed : status = <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			  
			  status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
			  if (status != NFM_S_SUCCESS)
			    {
			      MEMclose (&sql_buffer) ;
			      MEMclose (&move_buffer) ;
			      _NFMdebug ((fname, "build file transfer buffer failed : status = <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			  
			  status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
			  if (status != NFM_S_SUCCESS)
			    {
			      MEMclose (&sql_buffer) ;
			      MEMclose (&move_buffer) ;
			      _NFMdebug ((fname, "load fto buf failed : status = <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			}
		      
		      strcpy (file_buffer.n_cofilename, data [offset]) ;
		      file_buffer.n_status1 = NFM_DELETE_FILE ;
		      status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
		      if (status != NFM_S_SUCCESS)
			{
			  MEMclose (&move_buffer) ;
			  MEMclose (&sql_buffer) ;
			  _NFMdebug ((fname, "load fto buf failed : status = <0x%.8x>\n",
				      status)) ;
			  return (status) ;
			}
		      
		      if (_NFMdebug_st.NFMdebug_on)			    
			MEMprint_buffer ("move buffer", move_buffer, _NFMdebug_st.NFMdebug_file);
		      
		    } /* non conditional delete */
		} /* match of file */
	    }
	}
      file_ptr = file_ptr -> ptr ;
    }

  if (delete_files)
    {
      status = NFMpcrm_co_files (&move_buffer, -1) ;
      if (status != NFM_S_SUCCESS)
	{
	  MEMclose (&sql_buffer) ;
	  MEMclose (&move_buffer) ;
	  _NFMdebug ((fname, "Rm co files failed : status = <0x%.8x>\n", status)) ;
	  return (status) ;
	}
    }

  MEMclose (&sql_buffer) ;
  MEMclose (&move_buffer) ;
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}






