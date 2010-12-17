#include "machine.h"
#ifndef OS_SCO_UNIX
#include "NFMitems.h"
#endif

#include "NFMapi.h"
#include "NFMfto_buf.h"
#include "CMDTOOLS.h"

MEMptr NFMDropped_members=NULL; /* 8/19/94 */
extern long NFMCalled_DM;

  extern struct NFMglobal_st NFMglobal ;

long NFMundo_microstation_set (catalog_name, p_catalogno, p_itemno, 
			       promoted_to_set)
     char *catalog_name ;
     long p_catalogno ;
     long p_itemno ;
     long promoted_to_set ;
{
  char *fname = "NFMundo_microstation_set" ;
  long   status ;
  char tmp_str [512] ;
  
  _NFMdebug ((fname, "catalog name <%s> : catalog no <%d> : item no <%d> : promoted to set <%d>\n",
	      catalog_name, p_catalogno, p_itemno, promoted_to_set)) ;

  if (!promoted_to_set)
    {
      _NFMdebug ((fname, "This item was not promoted to set\n")) ;
      return (NFM_S_SUCCESS) ;
    }

  sprintf (tmp_str, 
	   "Delete from nfmsetcit where n_pcatalogno = %d and n_pitemno = %d",
	   p_catalogno, p_itemno) ;
  
  status = SQLexec_imm (tmp_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
    {
      _NFMdebug ((fname, "SQLexec_imm failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_STMT) ;
    }

  sprintf (tmp_str,
	   "Update %s set n_setindicator = '' where n_itemno = %d",
	   catalog_name, p_itemno) ;

  status = SQLexec_imm (tmp_str) ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLexec_imm failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_STMT) ;
    }


  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMfill_f_cat_info (list_members, file_info,
			  p_name, last_info, ms_p_catno, ms_p_itemno,
			  no_first_level)
     struct NFMset_member *list_members ;
     struct file_info_struct **file_info ;
     char *p_name ;
     struct file_info_struct **last_info ;
     long   ms_p_catno, ms_p_itemno ;
     long   *no_first_level ;
{
  static char *fname = "_NFMfill_f_cat_info" ;
  struct NFMset_member *member_ptr ;
  char *str, tmp_str [512], *sql_str ;
  long child, status, itemno, c_itemno, i, offset=0, found ;
  MEMptr sql_buffer = NULL ;
  struct file_info_struct *next_info ;
  char **data ;

/* tmpPS - to avoid a SEGV
  _NFMdebug ((fname, "parent cat no %ld : parent item no %ld\n",
              ms_p_catno, ms_p_itemno)) ;
*/

/*** initialize variables ******/
  *no_first_level = 1 ;   *last_info = NULL ;   p_name [0] = 0 ;

  /*** get first level members ****/

  /* 11/28/94 add n_ccatalogno, must match with item number AND 
                                catalog number */

  sprintf (tmp_str, "Select n_citemno, n_ccatalogno from nfmsetcit where  n_pcatalogno = %d and   n_pitemno = %d",
	   ms_p_catno, ms_p_itemno) ;

  status = SQLquery (tmp_str,  &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Set has no members\n")) ;
	}
      else
	{
	  _NFMdebug ((fname, "SQL query : status = <0x%.8x>\n",
		      status)) ;
	}
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;

  /* 11/29/94          *no_first_level = sql_buffer->rows +1;
     misleading.... if one or more children isi/are from another catalogs,
     this number and the number of entries in file_info will get out of sync 
     when this function return. */

  member_ptr = (struct NFMset_member *) list_members ;

  child = 0 ;
  str = (char *) malloc (*no_first_level * 200) ;
  if (str == NULL)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "Malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  str [0] = 0 ;
  while (member_ptr != NULL)
    {
      _NFMdebug ((fname, "member_ptr->item_no %d member_ptr->cat_no %d\n",
                          member_ptr->item_no, member_ptr->cat_no));
      for (i=0; i<sql_buffer ->rows; i++)
	{
          _NFMdebug ((fname, "data [0] = %s data[1] = %s\n",
                      data[i*sql_buffer->columns],
                      data[i*sql_buffer->columns +1]));
	  if (((member_ptr->item_no == atol (data [i*sql_buffer->columns])) &&
               (member_ptr->cat_no  == atol (data [i*sql_buffer->columns +1])) )
              ||
	      ((member_ptr->item_no == ms_p_itemno) && 
               (member_ptr->cat_no == ms_p_catno)      )) 
	    {
	      break ;
	    }
	}

      if (i==sql_buffer->rows || member_ptr->cat_no != ms_p_catno)
	{
	  _NFMdebug ((fname, "Do not get information for %d \n\
         it is not a first level memberi or it is located in another catalog\n",
		      member_ptr->item_no)) ;
	  member_ptr = member_ptr -> next ;
	  continue ;
	}

      sprintf (tmp_str, " (n_itemnum = %d) ",  member_ptr -> item_no);
      if (!child) 
	{
	  child = 1 ;
	  strcpy (p_name, member_ptr->cat_name) ;
	}
      else strcat (str, " OR ") ;
      strcat (str, tmp_str) ;
      member_ptr = member_ptr -> next ;
    }

  MEMclose (&sql_buffer) ;

  sql_str = (char *) malloc (strlen (str) + 500) ;
  if (sql_str == NULL)
    {
      free (str) ;
      _NFMdebug ((fname, "Malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }
/*and (n_filetype = 'M' or n_filetype = 'DWG')*/

  sprintf (sql_str,
	   "select n_itemnum, n_cofilename, n_filenum,  max(n_fileversion) from f_%s where (%s)  group by n_itemnum, n_filenum, n_cofilename",
	   p_name, str) ;
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;

  free (str) ;
  free (sql_str) ;

  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  data = (char **) sql_buffer->data_ptr ;

  *file_info = NULL ; 

  member_ptr = (struct NFMset_member *) list_members ;

  while (member_ptr != NULL)
    {
      itemno = member_ptr -> item_no ;
      c_itemno = 0 ;
      found = 0 ;
      for (i=0; (i<sql_buffer->rows) && (member_ptr->cat_no == ms_p_catno); i++)
	{
	  offset = i*sql_buffer->columns ;
/*	  _NFMdebug ((fname, "comparing %d with %s\n",
		      c_itemno, data [offset])) ; */
	  if (c_itemno == atol (data[offset]))
	    {
	      MEMclose (&sql_buffer) ;
	      _NFMdebug ((fname, "Failure : Multiple files per item - INVALID FOR MICROSTATION ITEMS/SETS\n")) ;
	      ERRload_struct (NFM, NFM_E_MS_MUL_FILES_PER_ITEM, "","") ;
	      return (NFM_E_MS_MUL_FILES_PER_ITEM);
	    }

	  if ((itemno == atol (data [offset])) && (!found))
	    {
	      found = 1 ;
	      c_itemno = itemno ;
	      next_info = (struct file_info_struct *) calloc (1, sizeof (struct file_info_struct)) ;
	      if (next_info == NULL)
		{
		  MEMclose (&sql_buffer) ;
		  _NFMdebug ((fname, "Calloc failed (next_info) \n")) ;
		  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
		  return (NFM_E_MALLOC) ;
		}
	      _NFMdebug ((fname, "itemno %s cofilename %s filenum %s fileversion %s\n",
			  data [offset], data [offset+1], data [offset+2],
			  data [offset+3]));
	      next_info->n_itemno = itemno ;
	      strcpy (next_info->n_cofilename, data [offset+1]) ;
	      next_info->n_filenum = atol (data [offset+2]) ;
	      next_info->n_fileversion = atol (data [offset+3]) ;
              /*strncpy (next_info->mem_type, member_ptr->type, NFM_TYPE);*/
	      if (*file_info == NULL) 
              {
                *file_info = next_info;
                *no_first_level = 1;
              }
	      else 
              {
                (*last_info)->ptr = next_info;
                ++(*no_first_level);
              }
	      *last_info = next_info ;
	      (*last_info)->member_ptr = member_ptr ;
	      (*last_info)->n_citno = (*last_info)->member_ptr->citno ;
	      break ;
	    }
	}

       if (!found)
	{
	  _NFMdebug ((fname, "NOT A FIRST LEVEL MEMBER\n")) ;
	}
      member_ptr = member_ptr -> next ;
    } /* while */
  
  MEMclose (&sql_buffer) ;
  _NFMdebug ((fname, "SUCCESSFUL, number of manipulable 1st level %d\n", 
              *no_first_level)) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMdelete_file_LFM (no_dropped, list_member, file_info, sa_struct,
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
  char *sql_str, *str, tmp_str [512], **data, upd_str[1024] ;
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
	  _NFMdebug ((fname, 
                 "no rows in nfmsafiles - Per document leave the file\n")) ;
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
		  
                  if (strcmp (file_ptr->member_ptr->type, "P") == 0)
                  {
                    _NFMdebug ((fname, "Primary member\n"));
                    /* change n_status from M to O */
                    if (strncmp(file_ptr->member_ptr->file_status, "M", 1) == 0)
                    /* this check should be unecessary, but I do it because
                       I am paranoid */
                    {
                      _NFMdebug ((fname, "the primary member\n"));
                      sprintf (upd_str, "%s %s %s %d",
                        "update", file_ptr->member_ptr->cat_name, 
                        "set n_status = 'O' where n_itemno = ", 
                        file_ptr->n_itemno); 
                    
                      status = SQLstmt (upd_str);
                      if (status != SQL_S_SUCCESS)
                      {
                        _NFMdebug ((fname, "SQLstmt 0x%.8x\n"));
                        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
                        return (status);
                      }
                    }
                    else
                    {
                      _NFMdebug ((fname, 
                          "something is terribly wrong with this database\n"));
                      ERRload_struct (NFM, NFM_E_CORRUPTED_CATALOG, "", NULL);
                      return (NFM_E_CORRUPTED_CATALOG);
                    }

                  }
		  else if (operation->delete == NFM_CONDITIONAL_DELETE)
		  {
		       if ((!strcmp (data[offset+5], "N")) &&
			  (!strcmp (data[offset+6], "N")) &&
			  (!strcmp (data[offset+7], "1")))
			{
			  _NFMdebug ((fname, "n_co = N n_copy = N n_ref =1 \n\
                                       delete file per local file manager\n")) ;
			  _NFMdebug ((fname, "Delete file per LFM\n")) ;
			  strcpy (file_ptr->file_action, "D") ;
			  delete_files = 1 ;
			  if (!move_buffer)				
			    {
			      status = _NFMget_sano_info_fto_buf 
                                       (sa_struct.sano, "", &file_buffer) ;
			      if (status != NFM_S_SUCCESS)
				{
				  MEMclose (&sql_buffer) ;
				  _NFMdebug ((fname, 
                                   "_NFMget_sano_info_fto_buf <0x%.8x>\n",
					      status)) ;
				  return (status) ;
				}
			      
			      status = NFMbuild_fto_buffer (&move_buffer, 
                                             MEM_SIZE) ;
			      if (status != NFM_S_SUCCESS)
				{
				  MEMclose (&sql_buffer) ;
				  MEMclose (&move_buffer) ;
				  _NFMdebug ((fname, "NFMbuild_fto_buffer\n\
                                               status = <0x%.8x>\n", status)) ;
				  return (status) ;
				}
			      
			      status = NFMload_fto_buf (&move_buffer, 
                                          &file_buffer) ;
			      if (status != NFM_S_SUCCESS)
				{
				  MEMclose (&sql_buffer) ;
				  MEMclose (&move_buffer) ;
				  _NFMdebug ((fname, 
                                              "NFMload_fto_buf <0x%.8x>\n",
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
			      _NFMdebug ((fname, "NFMload_fto_buf <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			  
			  if (_NFMdebug_st.NFMdebug_on)			    
			    MEMprint_buffer ("move buffer", move_buffer, 
                                              _NFMdebug_st.NFMdebug_file);
			  
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
      if (!NFMCalled_DM)
      {
        status = NFMrm_co_files (&move_buffer, -1) ;
        if (status != NFM_S_SUCCESS)
  	{
	  MEMclose (&sql_buffer) ;
	  MEMclose (&move_buffer) ;
	  _NFMdebug ((fname, "Rm co files status = <0x%.8x>\n", status)) ;
	  return (status) ;
	}
        MEMclose (&move_buffer) ;
      }
      else
      {
        if (NFMDropped_members != (MEMptr) NULL)
          MEMclose (&NFMDropped_members);
        else
          NFMDropped_members = move_buffer;
      }
    }

  MEMclose (&sql_buffer) ;
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMfree_file_info_struct (file_ptr)
  struct file_info_struct *file_ptr ;
  {
    char *fname = "_NFMfree_file_info_struct" ;
    struct file_info_struct *next_cell ;

    while (file_ptr != NULL)
      {
	_NFMdebug ((fname, "freeing %s\n", file_ptr->n_cofilename)) ;
	next_cell = file_ptr -> ptr ;
	free (file_ptr) ;
	file_ptr = next_cell ;
      }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS) ;
  }

long _NFMprint_file_info_struct (file_ptr_gold)
  struct file_info_struct *file_ptr_gold ;
  {
    char *fname = "_NFMprint_file_info" ;
    struct file_info_struct *file_ptr ;

    file_ptr = file_ptr_gold ;
    while (file_ptr != NULL)
      {
	_NFMdebug ((fname, "itemno %d : filenum %d : fileversion %d : cofilename %s\n",
		    file_ptr -> n_itemno, file_ptr -> n_filenum,
		    file_ptr->n_fileversion, file_ptr->n_cofilename)) ;
	_NFMdebug ((fname, "citno %d : ms action %s : lfm action %s : file action %s\n",
		    file_ptr -> n_citno, file_ptr ->ms_action,
		    file_ptr->lfm_action, file_ptr->file_action)) ;
	  file_ptr = file_ptr->ptr ;
      }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS) ;
  }

long _NFMprint_NFMset_member (no_members, ptr) 
  struct NFMset_member *ptr ;
  {
    char *fname = "_NFMprint_NFMset_member" ;
    long i ;

    for (i=0; i<no_members ; i++)
      {
	_NFMdebug ((fname, "level %d : citno %d : type %s : cat_no %d : cat_name %s\n",
		    ptr->level, ptr->citno, ptr->type, ptr->cat_no, 
		    ptr->cat_name)) ;
	_NFMdebug ((fname, "item_no %d : file_status %s : archive_state %s : item_name  %s : item_rev %s\n",
		    ptr->item_no, ptr->file_status, ptr->archive_state,
		    ptr->item_name, ptr->item_rev));
	_NFMdebug ((fname, "lock %s : version_limit %d : set_indicator %s : pendingflag %s\n",
		    ptr->lock, ptr->version_limit, ptr->set_indicator,
		    ptr->pending_flag)) ;
	ptr = ptr->next ;
      }

    _NFMdebug ((fname, "SUCCESSFUL\n")) ;
    return (NFM_S_SUCCESS) ;
  }

long _NFMrollback_microstation_operation (file_ptr_gold, p_catno, 
					  p_itemno, sa_struct) 
     struct file_info_struct *file_ptr_gold ;
     long p_catno, p_itemno ;
     struct sto_area_info sa_struct ;
{
  char *fname = "_NFMrollback_microstation_operation" ;
  long status, offset ;
  char sql_str [1024], tmp_str [500], **data ;
  char catalogname[NFM_CATALOGNAME+1] ;
  MEMptr sql_buffer = NULL ;
  struct file_info_struct *file_ptr ;

  _NFMdebug ((fname, "ENTER : parent catalog no %d : parent item no %d\n",
	      p_catno, p_itemno)) ;

  file_ptr = file_ptr_gold ;
  while (file_ptr != NULL)
    {
      _NFMdebug ((fname, "itemno <%d> : ms action <%s> : lfm action <%s>\n", 
		  file_ptr->n_itemno, file_ptr->ms_action,
		  file_ptr->lfm_action)) ;
      if (strcmp (file_ptr->ms_action, "A")==0)
	{
	  sprintf (sql_str, 
		   "delete from nfmsetcit where n_citno = %d and n_pcatalogno = %d and n_pitemno = %d and n_ccatalogno = %d and n_citemno = %d and n_type = 'S'",
		   file_ptr -> n_citno, p_catno, p_itemno, 
		   p_catno, file_ptr->n_itemno);
	  
	  status= SQLexec_imm (sql_str) ;
	  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	    {
	      _NFMdebug ((fname, "Sql exec imm failed : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	      return (NFM_E_SQL_STMT) ;
	    }
	  if (strcmp (file_ptr->lfm_action, "U") == 0)
	    {
	      sprintf (tmp_str, " (n_sano = %d and  n_filename = '%s' and n_catalogno = %d and n_itemno = %d and n_filenum = %d and n_fileversion = %d) ",
		       sa_struct.sano,
		       file_ptr->n_cofilename,
		       p_catno,
		       file_ptr->n_itemno,
		       file_ptr->n_filenum,
		       file_ptr->n_fileversion) ;
	      
	      sprintf (sql_str, "select n_co, n_copy, n_ref from nfmsafiles where %s",
		       tmp_str);
	      
		status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
		if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
		  {
		    MEMclose (&sql_buffer) ;
		    _NFMdebug ((fname, "SQLquery : status : <0x%.8x>\n",
				status)) ;
		    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
		    return (NFM_E_SQL_QUERY) ;
		  }
		
		if (status != SQL_I_NO_ROWS_FOUND)
		  {
		    status = MEMbuild_array (sql_buffer) ;
		    if (status != MEM_S_SUCCESS)
		      {
			MEMclose (&sql_buffer) ;
			_NFMdebug ((fname, "MEMbuild_array (sql_buffer) status = <0x%.8x>\n",
				    status)) ;
			ERRload_struct (NFM, NFM_E_MEM, "", "") ;
			return (NFM_E_MEM) ;
		      }

		    data = (char **) sql_buffer->data_ptr ;
		    strcpy (file_ptr->lfm_action, "U") ;
		    sprintf (sql_str, "update nfmsafiles set n_ref = %d where n_filename = '%s' and n_sano = %d and n_catalogno = %d and n_itemno = %d and n_filenum = %d and n_fileversion = %d",
			     atol (data[offset+2]) -1,
			     file_ptr -> n_cofilename, 
			     sa_struct.sano, 
			     p_catno,
			     file_ptr -> n_itemno,
			     file_ptr -> n_filenum,
			     file_ptr -> n_fileversion);

		    status = SQLexec_imm (sql_str) ;
		    if (status != SQL_S_SUCCESS)
		      {
			MEMclose (&sql_buffer) ;
			_NFMdebug ((fname, "SQL exec imm failed : status = <0x%.8x>\n",
				    status)) ;
			ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
			return (NFM_E_SQL_STMT) ;
		      }
		  }
	      MEMclose (&sql_buffer) ;
	    }
	  else
	    {
	      sprintf (sql_str, "delete from  nfmsafiles where n_filename = '%s' and n_sano = %d and n_catalogno = %d and n_itemno = %d and n_filenum = %d and n_fileversion = %d",
		       file_ptr -> n_cofilename, 
		       sa_struct.sano, 
		       p_catno,
		       file_ptr -> n_itemno,
		       file_ptr -> n_filenum,
		       file_ptr -> n_fileversion);
	      
	      status = SQLexec_imm (sql_str) ;
	      if (status != SQL_S_SUCCESS)
		{
		  _NFMdebug ((fname, "SQL exec imm failed : status = <0x%.8x>\n",
			      status)) ;
		  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		  return (NFM_E_SQL_STMT) ;
		}
	    }
	}
      else if (strcmp (file_ptr->ms_action, "D") == 0)
	{
	  sprintf (sql_str, 
		   "insert into nfmsetcit (n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno, n_type) values (%d, %d, %d, %d, %d, 'S')",
		     file_ptr->n_citno,
		     p_catno, p_itemno, 
		     p_catno, file_ptr->n_itemno) ;
	  status= SQLexec_imm (sql_str) ;
	  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	    {
	      _NFMdebug ((fname, "Sql exec imm failed : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	      return (NFM_E_SQL_STMT) ; 
	    }
	  
	  /* update set anyway */
	  sprintf (sql_str, "select n_catalogname from nfmcatalogs where n_catalogno = %d",
		   p_catno) ;
	  
	  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
	  if (status != SQL_S_SUCCESS)
	    {
	      MEMclose (&sql_buffer) ;
	      _NFMdebug ((fname, "SQLquery : status : <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	      return (NFM_E_SQL_QUERY) ;
	    }
	  
	  if (status != SQL_S_SUCCESS)
	    {
	      MEMclose (&sql_buffer) ;
	      _NFMdebug ((fname, "parent catalog does not exist in nfmcatalogs\n")) ;
	      ERRload_struct (NFM, NFM_E_SQL_QUERY, "","") ;
	      return (NFM_E_SQL_QUERY) ;
	    }

	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&sql_buffer) ;
	      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  
	  data = (char **) sql_buffer->data_ptr ;
	  strcpy (catalogname, data [0]) ;
	  MEMclose (&sql_buffer) ;

	  sprintf (sql_str, 
		   "update %s set n_setindicator = 'Y' where n_itemno = %d",
		   catalogname, p_itemno) ;

	  status= SQLexec_imm (sql_str) ;
	  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	    {
	      _NFMdebug ((fname, "Sql exec imm failed : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	      return (NFM_E_SQL_STMT) ; 
	    }

	  
	  /****** mms - no action *******
	    if (! strcmp (file_ptr -> lfm_action, "D")) 
	    {
	    strcpy (file_ptr->lfm_action, "I") ;
	    sprintf (sql_str, "insert into nfmsafiles (n_ref, n_filename, n_sano, n_catalogno, n_itemno, n_filenum, n_fileversion, n_co, n_copy) \
	    values (1, '%s', %d, %d, %d, %d, 'N', 'N')",
	    file_ptr->n_cofilename,
	    sa_struct.sano, 
	    p_catno,
	    file_ptr->n_itemno,
	    file_ptr->n_filenum,
	    file_ptr->n_fileversion) ;
	    
	    status = SQLexec_imm (sql_str) ;
	    if (status != SQL_S_SUCCESS)
	    {
	    _NFMdebug ((fname, "SQL exec_imm status = <0x%.8x>\n",
	    status)) ;
	    ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	    return (NFM_E_SQL_STMT) ;
	    }
	    if (!strcmp (file_ptr->file_action, "D")) 
	    {
	    }
	    }
	    ***********************/

	  if (!strcmp (file_ptr ->lfm_action, "U"))
	    {
	      sprintf (sql_str, "select n_co, n_copy, n_ref from nfmsafiles where %s",
		       tmp_str);
	      
	      status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
	      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
		{
		  MEMclose (&sql_buffer) ;
		  _NFMdebug ((fname, "SQLquery : status : <0x%.8x>\n",
			      status)) ;
		  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
		  return (NFM_E_SQL_QUERY) ;
		}
	      
	      if (status != SQL_I_NO_ROWS_FOUND)
		{
		  status = MEMbuild_array (sql_buffer) ;
		  if (status != MEM_S_SUCCESS)
		    {
		      MEMclose (&sql_buffer) ;
		      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		      return (NFM_E_MEM) ;
		    }
		  
		  data = (char **) sql_buffer->data_ptr ;
		  strcpy (file_ptr->lfm_action, "U") ;
		  sprintf (sql_str, "update nfmsafiles set n_ref = %d where n_filename = '%s' and n_sano = %d and n_catalogno = %d and n_itemno = %d and n_filenum = %d and n_fileversion = %d",
			   atol (data[offset+2]) +1,
			   file_ptr->n_cofilename,
			   sa_struct.sano, 
			   p_catno,
			   file_ptr->n_itemno,
			   file_ptr->n_filenum,
			   file_ptr->n_fileversion) ;
		  
		  status = SQLexec_imm (sql_str) ;
		  if (status != SQL_S_SUCCESS)
		    {
		      MEMclose (&sql_buffer) ;
		      _NFMdebug ((fname, "SQL exec_imm failed : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		      return (NFM_E_SQL_STMT) ;
		    }
		}
	      MEMclose (&sql_buffer) ;
	    }
	}
      file_ptr = file_ptr->ptr ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMappend_dropped_members (file_list)

MEMptr file_list;

{

  char *fname="_NFMappend_dropped_members";
  long status, i, j, index;
  char row_str[1024], **data;

  _NFMdebug ((fname, "ENTER:\n"));

  if (NFMDropped_members != (MEMptr) NULL)
  {
    if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("dropped member", NFMDropped_members, 
                        _NFMdebug_st.NFMdebug_file);
    }
    status = MEMbuild_array (file_list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
      MEMclose (&NFMDropped_members);
      return (status);
    }
    status = MEMbuild_array (NFMDropped_members);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
      MEMclose (&NFMDropped_members);
      return (status);
    }
    data = (char **) NFMDropped_members->data_ptr;
    for (i=1; i<NFMDropped_members->rows; i ++)
    {
      _NFMdebug ((fname, "row %d\n", i));
      index = i * NFMDropped_members->columns;
      strcpy (row_str, "\0");
      for (j=0; j<NFMDropped_members->columns; j++)
      {
        strcat (row_str, data[index+j]);
        strcat (row_str, "\1");
      } 
      for (j=NFMDropped_members->columns; j<file_list->columns; j ++)
      {
        strcat (row_str, "\1");
      }
      status = MEMwrite (file_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite: 0x%.8x\n", status));
        MEMclose (&NFMDropped_members);
        return (status);
      }
    } 
    if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("Appended buffer", file_list, 
       _NFMdebug_st.NFMdebug_file);
    }
  }

  MEMclose (&NFMDropped_members);
  _NFMdebug ((fname, "EXIT: successfully\n"));
  return (NFM_S_SUCCESS);
}








