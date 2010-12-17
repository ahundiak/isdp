#include "machine.h"
#ifndef OS_SCO_UNIX
#include "NFMitems.h"
#endif

#include "NFMitemfiles.h"
#include "NFMapi.h"
#include "NFMfto_buf.h"
#include "CMDTOOLS.h"
#include "NETdef.h"
long NFMCalled_DM=0;

extern struct NFMglobal_st NFMglobal ;

#define NFM_MAX_MS_REFERENCE_FILES      255 /* as per Michele futch mail - PS */


long NFMupdate_microstation_file (num_of_members,
				  list_members, new_member_list,
				  sa_struct, operation,
				  no_dropped, no_added,
				  ms_p_catno, ms_p_itemno, 
				  file_info) 
     long   num_of_members ;             /* input : including parent */
     struct NFMset_member *list_members ; /* input  */
     struct NFMset_member **new_member_list ; /* output */
     struct NFMsto_info sa_struct ;         /* input */
     struct NFMoperation *operation ;       /* input */
     long   *no_dropped ;
     long   *no_added ;
     long   ms_p_catno ;                   
     long   ms_p_itemno ; 
     struct file_info_struct **file_info ;
{
  static char *fname = "NFMupdate_microstation_file" ;
  struct file_info_struct *file_ptr, *next_info, *ptr_to_last =NULL ;
  struct file_info_struct *file_info1 ;
  struct NFMset_member *member_ptr, *last_member = NULL ;
  long status, index_x, index_y, found ;
  long itemno, i, offset =0 , citno, offset1 = 0 ;
  char **data, **data1, mem_type[NFM_TYPE+1] ;
  short *att_files_flag ;
  char  *st, **attached_filename_list, tmp_str [512] ;
  char  *sql_str, sql_str1[1024] ;
  long filetype=0;
  long  num_att_files ;
  MEMptr att_files_list = NULL ;
  MEMptr sql_buffer = NULL, sql_buffer1=NULL ;
  char p_name [50] ;
  long no_first_level, no_attached ;
  long m_ind;
  /* Adde for Euroi */
  MEMptr buffer = NULL;
  char **att_ras_filelist;
  short euro_x, euro_y;
 
/* Added feature for promoting a drawing to Microstation Set while working
   from  DM/DBA on PC. Request from DM/DBA    -- Jujare, 13 Nov 95 */ 
/* Added Code to check for IBM PC also, as per the request by Michele/Statoil
                                              -- Jujare, 31 Jan 96 */ 
  struct NFMsto_info *sto_list1=NULL ;
  char src_file[256], dst_file[256], dst_path[256], file_type[2],
       dec_passwd[25];
  long file_size ;
  
  
  *new_member_list = NULL ;
  *file_info = NULL ;

  _NFMdebug ((fname, "Number of members <%d> : parent cat no <%d> : item no <%d>\n",
	      num_of_members, ms_p_catno, ms_p_itemno)) ;

  _NFMdebug ((fname, "filling file information in first level member...\n")) ;

  status = _NFMfill_f_cat_info (list_members, &file_info1,
				p_name, &ptr_to_last,
				ms_p_catno, ms_p_itemno,
				&no_first_level) ;
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "Fill f_cat information failed : status = <0x%.8x>\n",
	         status)) ;
    if (strcmp (sa_struct.machid, "PC") == 0)
    {
      _DMdo_nothing ();
    }
    return (status) ;
  }

  *file_info = file_info1 ;

  if (_NFMdebug_st.NFMdebug_on)
    _NFMprint_file_info_struct (*file_info) ;

  if (ms_p_itemno != (*file_info)->n_itemno)
    {
      /* no file information for parent */
      _NFMdebug ((fname, "Failure : No file information for parent\n"));
      ERRload_struct (NFM, NFM_E_MS_NO_FILE_INFO, "", "") ;
      if (sa_struct.option == DM_AUTOCAD ||
          sa_struct.option == DM_MICROSTATION)
        _DMdo_nothing ();
      return (NFM_E_MS_NO_FILE_INFO) ;
    }

  _NFMdebug ((fname, "Getting attached files for in node %s username %s path %s of design file %s\n",
	      sa_struct.nodename, sa_struct.username, sa_struct.passwd,
	      (*file_info)->n_cofilename)) ;

  _NFMdebug ((fname, "check if the n_machid = 'CLIX' or 'PC' or 'IBM PC' : machine id is <%s>\n",
	      sa_struct.machid)) ;

  if ((strcmp (sa_struct.machid, "UNIX") == 0) || 
      (strcmp (sa_struct.machid, "CLIX") == 0) || 
      (strcmp (sa_struct.machid, "PC") == 0)   ||
      (strcmp (sa_struct.machid, "IBM PC") == 0))
    {
      if (sa_struct.option == DM_AUTOCAD ||
          sa_struct.option == DM_MICROSTATION)
      {
        if (sa_struct.option == DM_AUTOCAD)
          filetype = NFM_GET_ACAD_FILES;
        else
          filetype = NFM_GET_MICRO_FILES;
        _NFMdebug ((fname, "filetype = %d\n", filetype));
        status = DMfs_get_list_attached_reference_files ( sa_struct.pathname,
                                                     (*file_info)->n_cofilename,
                                                         &att_files_list,
                                                         filetype) ;
        NFMCalled_DM = 1;
      }
      else
      {
        if (sa_struct.option == NFM_AUTOCAD)
        {
          MEMopen (&att_files_list, MEM_SIZE);
        } 
  
        if ((strcmp (sa_struct.machid, "UNIX") == 0) ||
            (strcmp (sa_struct.machid, "CLIX") == 0))
        {
           status = NFMfs_get_list_attached_reference_files (sa_struct.nodename,
							sa_struct.username, 
							sa_struct.passwd,
							sa_struct.pathname,
                 				(*file_info)->n_cofilename, 
      						&att_files_list) ;
        }

/* Added feature for promoting a drawing to Microstation Set while working
   from  DM/DBA on PC. Request from DM/DBA    -- Jujare, 13 Nov 95 */ 
/* Added Code to check for IBM PC also, as per the request by Michele/Statoil
                                              -- Jujare, 31 Jan 96 */ 
        else if ((strcmp (sa_struct.machid, "PC")     == 0) ||
                 (strcmp (sa_struct.machid, "IBM PC") == 0))
        {
           sto_list1 = (struct NFMsto_info *) malloc (sizeof (struct NFMsto_info));
           sto_list1->sano = 4;  strcpy(sto_list1->saname, "NFMFILES");

           status = NFMget_storage_info (sto_list1->saname, &(sto_list1->sano),
           sto_list1->nodename, sto_list1->username, sto_list1->passwd,
           sto_list1->pathname, sto_list1->devicetype, sto_list1->plattername,
           sto_list1->partition, sto_list1->nfs, sto_list1->compress,
           sto_list1->machid, sto_list1->opsys,sto_list1->tcpip, sto_list1->xns,
           sto_list1->decnet, sto_list1->netware);

           if (status != NFM_S_SUCCESS)
           {
            free (sto_list1);
            _NFMdebug ((fname, "NFMget_storage_info failed 0x%.8x\n", status));
            return (status);
           }
 
           sprintf(src_file,"%s/%s",sa_struct.pathname, 
                                    (*file_info)->n_cofilename);
           _NFMdebug ((fname, "src_file  %s\n", src_file));
           sprintf(dst_file,"/usr/tmp/%s",(*file_info)->n_cofilename);
           _NFMdebug ((fname, "dst_file  %s\n", dst_file));
           sprintf(dst_path,"/usr/tmp/");
           sprintf(file_type,"M");
              
           status = NFMdecrypt (sa_struct.passwd, dec_passwd);                      
           NFMftp_receive (sa_struct.nodename, sa_struct.username, 
                           dec_passwd, src_file, dst_file, 
                           file_type, &file_size);

           status = NFMfs_get_list_attached_reference_files(sto_list1->nodename,
						sto_list1->username, 
						sto_list1->passwd,
						dst_path,
                 				(*file_info)->n_cofilename, 
      						&att_files_list) ;
        }
        else 
        {
           _NFMdebug ((fname, "Not UNIX OR PC or IBM PC : ignored CASE! \n")) ;
           return (NFM_S_SUCCESS) ;
        }
/* End of Addition -- Jujare, 13 Nov 95 */
        NFMCalled_DM = 0;
      }
      if (status != NFM_S_SUCCESS)
      {
	  MEMclose (&att_files_list) ;
	  _NFMdebug ((fname, 
           "Getting Attached Reference List failed 0x%.8x\n", status)) ;
          if (status == NFM_E_OPEN_MICRO)
          {
            if (sa_struct.option == DM_AUTOCAD ||
                sa_struct.option == NFM_AUTOCAD  )
              ERRload_struct (NFM, NFM_E_OPEN_ACAD, "%s", 
                              (*file_info)->n_cofilename);
            else
              ERRload_struct (NFM, NFM_E_OPEN_MICRO, "%s", 
                              (*file_info)->n_cofilename);
          }
	  return (status) ;
      }
    }
  else
    {
      _NFMdebug ((fname, "Not clix or pc : ignore type M\n")) ;
      if (sa_struct.option == DM_AUTOCAD ||
          sa_struct.option == DM_MICROSTATION)
        _DMdo_nothing ();
      return (NFM_S_SUCCESS) ;
    }

  num_att_files = att_files_list->rows ;

  status = MEMbuild_array (att_files_list) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&att_files_list) ;
      _NFMdebug ((fname, "MEMbuild_array (att_files_list) failed : status = <0x%x.8>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  attached_filename_list = (char **) att_files_list -> data_ptr ;

  if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("attached files list", att_files_list, 
		       _NFMdebug_st.NFMdebug_file) ;
  
  /*****
    Drop members - update cit table and delete file
    Add members  - update cit table
    In any of above case update members list
    *****/
  
  _NFMdebug ((fname, "number of attached files is %d\n", num_att_files)) ;

  if (num_att_files > 0)
    {
      att_files_flag = (short *) calloc (num_att_files,sizeof (short)) ;
      if (att_files_flag == NULL)
	{
	  MEMclose (&att_files_list) ;
	  _NFMdebug ((fname, "Calloc (att_files_flag) failed\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}
    }

  
  st = (char *) malloc ((num_att_files+no_first_level+1)*200) ;
  if (st == NULL)
    {
      MEMclose (&att_files_list) ;
      free (att_files_flag) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }

  st[0] = 0 ;

  file_ptr = (struct file_info_struct *) (*file_info);

/** determine which members have been dropped or added **/
  *no_dropped = 0 ;

/*  for (index_x=0; index_x<num_of_members  ; index_x++) */
  for (index_x=0; index_x<no_first_level  ; index_x++) 
  {
      _NFMdebug ((fname, "index_x %d\n", index_x)) ; 
      /* skip if a match has found for this attached file */
      for (index_y=0; index_y<num_att_files;index_y++)
	{
	  if (!att_files_flag [index_y])
	    {
/***** debug ******
	      _NFMdebug ((fname, "comparing %s with %s\n",
			  file_ptr->n_cofilename, 
			  attached_filename_list [index_y])) ; 
******************/
	      /* compare members cofilename with attached filename */
	      if (!strcmp (file_ptr ->n_cofilename,
			   attached_filename_list[index_y]))
		{
		  /* if a file (parent) is attached to itself ingore it */
		  if (index_x == 0) att_files_flag [index_y] = -1 ;
		  else att_files_flag [index_y] = 1 ;
		  _NFMdebug ((fname, "att files flag is %d\n",
			      att_files_flag [index_y])) ; 
		  break ;
		}
	    }
	}

      if ((index_x) && (index_y == num_att_files))
	{
	  _NFMdebug ((fname, "member has been dropped\n")) ;
	  (*no_dropped)++ ;
	  /* member has been dropped */
	  if (!strlen(st)) 
	    {	
	      sprintf (tmp_str, "n_citemno = %d", 
		       file_ptr->member_ptr->item_no) ;
	    }
	  else
	    {
	      sprintf (tmp_str, " OR n_citemno = %d", 
		       file_ptr->member_ptr->item_no);
	    }
	  
	  strcat (st, tmp_str) ;
/*	  file_ptr->member_ptr->flag = NFM_DELETE_FLAG ; */
          _NFMdebug ((fname, "file_status [%s], member type [%s]\n",
                      file_ptr->member_ptr->file_status,
                      file_ptr->member_ptr->type));
	  file_ptr->member_ptr->flag = 1 ;
	  strcpy (file_ptr->ms_action,"D") ; 
	}
      else
	{
	  file_ptr->member_ptr->flag = 0 ;
	}
      file_ptr = file_ptr -> ptr ;
    } /* for */

  /*
  for (m_ind = 0; m_ind < num_att_files; m_ind ++)
  {
    _NFMdebug ((fname, "att_files_flag[%d] = %d",
                 m_ind, att_files_flag[m_ind]));
    if (m_ind % 2 == 0)
      _NFMdebug ((fname, "\n"));
  }
  */

  if (strlen (st))
    {
      _NFMdebug ((fname, "drop from setcit\n")) ;
      sql_str = (char *) malloc (strlen(st) + 512) ;
      if (sql_str == NULL)
	{
	  MEMclose (&att_files_list) ;
	  free (st) ;
	  free (att_files_flag) ;
	  _NFMdebug ((fname, "Malloc (sql_str) failed\n")) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  return (NFM_E_MALLOC) ;
	}
      
      sql_str[0] = 0 ;

      sprintf (sql_str, "delete from nfmsetcit where n_pcatalogno = n_ccatalogno \
and n_pitemno = %d and n_pcatalogno = %d and (%s)",
	       ms_p_itemno, ms_p_catno, st) ;
      status = SQLexec_imm (sql_str) ;
      free (sql_str) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  MEMclose (&att_files_list) ;
	  free (st) ;
	  free (att_files_flag) ;
	  _NFMdebug ((fname, "SQLexec_imm : status = <0x%x.8>\n", 
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	  return (NFM_E_SQL_STMT) ;
	}

      status = _NFMdelete_file_LFM (*no_dropped, list_members, *file_info, 
				    sa_struct, operation) ;
      if (status != NFM_S_SUCCESS)
	{
	  MEMclose (&att_files_list) ;
	  free (st) ;
	  free (att_files_flag) ;
	  _NFMdebug ((fname, "delete file failed\n")) ;
	  return (status) ;
	}
    }
  else
    {
      _NFMdebug ((fname, "NO MEMBERS DETTACHED\n")) ;
    }

  free (st);



  _NFMprint_file_info_struct (*file_info);

  for (m_ind = 0; m_ind < num_att_files; m_ind ++)
  {
    _NFMdebug ((fname, "att_files_flag[%d] = %d",
                 m_ind, att_files_flag[m_ind]));
    if (m_ind % 2 == 0)
      _NFMdebug ((fname, "\n"));
  }


/* ADDED By NAIDU for Euro-Disney -- Dt 24 Jul, 1995 */
   sprintf(sql_str1, "select n_cofilename from f_%s where n_itemnum = %d and n_filetype = 'R' and n_fileversion = (select max(n_fileversion) from f_%s where n_itemnum = %d)", p_name, ms_p_itemno, p_name, ms_p_itemno);
  status = SQLquery( sql_str1, &buffer, MEM_SIZE) ;
   if (status != SQL_S_SUCCESS)
    {
      MEMclose (&buffer) ;
      _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
                  status)) ;
    }
    else
    {
 
       status = MEMbuild_array (buffer) ;
       if (status != MEM_S_SUCCESS)
       {
        MEMclose (&buffer) ;
        _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
                  status)) ;
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
       }
 
       att_ras_filelist = (char **) buffer -> data_ptr ;
       _NFMdebug((fname, "Raster files in self Item = %d\n", buffer -> rows));
/*  End added for Euro-Disney *********/
            /* For Euro */
      for (index_y=0; index_y<num_att_files;index_y++)
        {
            for(euro_x = 0; euro_x < buffer -> rows ; euro_x++)
            {
                if(strcmp(att_ras_filelist[euro_x], attached_filename_list[index_y]) == 0){
                att_files_flag[index_y] = 1;
                _NFMdebug((fname, "flag is set for %s @ index_y = %d\n", att_ras_filelist[euro_x], index_y));
                }
            }
        }
     } /* If status != SQL_S_SUCCESS */
           /* End for Euro */
/*** resolved attached members ***/
  *no_added = 0 ; 
  no_attached = 0 ;
  if (num_att_files > 0)
    {
      st = (char *) malloc (num_att_files*200) ;
      if (st == NULL)
	{
	  MEMclose (&att_files_list) ;
	  free (st) ;
	  free (att_files_flag) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  _NFMdebug ((fname, "malloc failed\n")) ;
	  return (NFM_E_MALLOC) ;
	}
      st [0] = 0 ;

      for (index_y=0; index_y<num_att_files ; index_y++)
	{
	  if (att_files_flag[index_y] == 0)
	    {
	      _NFMdebug ((fname, "index_y is %d\n", index_y)) ;
	      _NFMdebug ((fname, "file is %s\n",
			  attached_filename_list[index_y])) ; 
	      if (strlen (st))
		{	
		  sprintf (tmp_str, " OR (n_fileversion in (select max(n_fileversion) from f_%s where n_cofilename = '%s') and n_cofilename = '%s')",
			   p_name, attached_filename_list [index_y],
			   attached_filename_list[index_y]) ;
		}
	      else
		{
		  sprintf (tmp_str, "(n_fileversion in (select max(n_fileversion) from f_%s where n_cofilename  = '%s') and n_cofilename = '%s')", 
			   p_name, attached_filename_list [index_y],
			   attached_filename_list [index_y]) ;
		}
	      strcat (st, tmp_str) ;
	      /*	  ++(*no_added) ; */
	      ++no_attached ;
	    }
	}
    }

  /*  if (*no_added) */
  if (no_attached > 0)
    {
      sql_str = (char *) malloc (strlen (st) +512) ;
      if (sql_str == NULL)
	{
	  MEMclose (&att_files_list) ;
	  free (att_files_flag) ;
	  free (st) ;
	  ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	  _NFMdebug ((fname, "malloc failed\n")) ;
	  return (NFM_E_MALLOC) ;
	}

      sql_str [0] = 0 ;

      sprintf (sql_str, "select b.n_itemnum, b.n_cofilename, b.n_fileversion, b.n_filenum, a.n_status, a.n_archivestate, a.n_itemname, a.n_itemrev, a.n_itemlock, a.n_versionlimit, a.n_setindicator, a.n_pendingflag, b.n_filetype from %s a, f_%s b where a.n_itemno = b.n_itemnum and (%s) order by b.n_itemnum, b.n_filenum, b.n_cofilename",
	       p_name, p_name, st) ;
      free (st) ;
      status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
      _NFMdebug((fname, "SQLstr = %s\n", sql_str));
      free (sql_str) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
	{
	  MEMclose (&att_files_list) ;
	  free (att_files_flag) ;
	  MEMclose (&sql_buffer) ;
	  _NFMdebug ((fname, "SQLquery failed : status = <0x%.8x>\n", status));
	  ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
	  return (NFM_E_SQL_QUERY) ;
	}
      
      if (status != SQL_I_NO_ROWS_FOUND)
	{
	  status = MEMbuild_array (sql_buffer) ;
	  if (status != MEM_S_SUCCESS)
	    {
	      MEMclose (&att_files_list) ;
	      free (att_files_flag) ;
	      MEMclose (&sql_buffer) ;
	      _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
			  status)) ;
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	      return (NFM_E_MEM) ;
	    }
	  
	  data = (char **) sql_buffer->data_ptr ;
          _NFMdebug((fname, "ROWS = %d\n", sql_buffer->rows));
	  
	  for (index_y=0; index_y<num_att_files;  index_y++)
	    {
	      _NFMdebug ((fname, "attached file %s\n", attached_filename_list [index_y])) ;
	      if (att_files_flag[index_y] == 0)
		{
		  found = 0 ;
		  itemno = 0 ;
		  for (i=0; i<sql_buffer->rows; i++)
		    {
		      _NFMdebug ((fname, "checking with %d\n", i)) ;
		      offset = i*sql_buffer->columns ;
		      if (itemno == atol (data [offset]))
			{
			  free (att_files_flag) ;
			  MEMclose (&sql_buffer) ;
			  _NFMdebug ((fname, "Failure : Multiple files per item - INVALID CONDITION FOR MICROSTATION"));
			  ERRload_struct (NFM, NFM_E_MS_MUL_FILES_PER_ITEM,"","");
			  return (NFM_E_MS_MUL_FILES_PER_ITEM) ;
			}
		      _NFMdebug ((fname, "comparing att files %s with %s\n",
				  attached_filename_list[index_y],
				  data [offset+1])) ;
		      if ((strcmp (attached_filename_list [index_y], data [offset+1])== 0) && (!found))
			{ 
			  found = 1 ;
			  ++(*no_added) ;
			  itemno =  atol (data [offset]) ;
			  member_ptr = (struct NFMset_member *) 
			    calloc (1, sizeof (struct NFMset_member)) ;
			  if (member_ptr == NULL)
			    {
			      MEMclose (&att_files_list) ;
			      free (att_files_flag) ;
			      MEMclose (&sql_buffer) ;
			      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
			      return (NFM_E_MALLOC) ;
			    }
			  _NFMdebug ((fname, "filling information...\n")) ;

			  member_ptr->item_no = atol (data [offset]) ;
			  member_ptr->cat_no = ms_p_catno ;
			  strcpy (member_ptr->cat_name, p_name);
			  strcpy (member_ptr->file_status, data[offset+4]);
			  strcpy (member_ptr->archive_state, data [offset+5]) ;
			  strcpy (member_ptr->item_name, data [offset+6]) ;
			  strcpy (member_ptr->item_rev, data [offset+7]) ;
			  strcpy (member_ptr->lock, data [offset+8]) ;
			  member_ptr->version_limit = atol (data [offset+9]) ;
			  strcpy (member_ptr->set_indicator, data [offset+10]) ;
			  strcpy (member_ptr->pending_flag, data [offset+11]) ;
			  strcpy (member_ptr->file_type, data [offset+12]) ;
                          member_ptr->flag = NFM_JUST_ADDED_RASTER;
			  member_ptr->next = NULL ;
			  if (*new_member_list == NULL) 
			    *new_member_list = member_ptr ;
			  else last_member->next = member_ptr ;
			  last_member = member_ptr ;
			  _NFMdebug ((fname, "filling file information..\n")) ;
			  /* build file info struct */
			  next_info = (struct file_info_struct *)
			    calloc (1, sizeof (struct file_info_struct)) ;
			  if (next_info == NULL)
			    {
			      MEMclose (&att_files_list) ;
			      free (att_files_flag) ;
			      MEMclose (&sql_buffer) ;
			      _NFMdebug ((fname, "malloc failed\n")) ;
			      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
			      return (NFM_E_MALLOC) ;
			    }
			  strcpy (next_info->ms_action, "A") ;
			  next_info->n_itemno = atol (data [offset]) ;
			  strcpy (next_info->n_cofilename, data [offset+1]) ;
			  next_info->n_fileversion = atol (data [offset+2]) ;
			  next_info->n_filenum = atol (data [offset+3]) ;
			  strcpy (next_info->filetype, data [offset+12]) ;
			  if (ptr_to_last == NULL) *file_info = next_info ;
			  else ptr_to_last ->ptr = next_info ;
			  ptr_to_last = next_info ;
			  ptr_to_last ->member_ptr = member_ptr ;
			  
			  status = NFMget_serial_slot (NFMglobal.NFMuserid, 
						       "nfmsetcit", "n_citno", &citno) ;
			  if (status != NFM_S_SUCCESS)
			    {
			      free (att_files_flag) ;
			      MEMclose (&sql_buffer) ;
			      MEMclose (&att_files_list) ;
			      _NFMdebug ((fname, "Get serial slot : status = <0x%.8x>\n",
					  status)) ;
			      return (status) ;
			    }
			  
                          if (strncmp (data[offset+12], "R", 1) == 0)
                          { 
                            _NFMdebug ((fname, "raster file, primary mem\n"));
                            strcpy (mem_type, "P");
                          }
                          else
                          {
                            _NFMdebug ((fname, "!raster, secondary mem\n"));
                            strcpy (mem_type, "S");
                          }
    
			  sprintf (sql_str1, "insert into nfmsetcit (n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno, n_type) values (%d, %d, %d, %d, %d, '%s')", 
				   citno, ms_p_catno, ms_p_itemno,
				   ms_p_catno, itemno, mem_type);

                          _NFMdebug ((fname, "sql_str1 %s\n", sql_str1));
			  
			  status = SQLexec_imm (sql_str1) ;
			  if (status != SQL_S_SUCCESS)
			    {
			      MEMclose (&att_files_list) ;
			      free (att_files_flag) ;
			      _NFMdebug ((fname, "SQLexec : status = <0x%x.8>\n",
					  status)) ;
			      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
			      return (NFM_E_SQL_STMT) ;
			    }
			  
			  ptr_to_last->n_citno = citno ;
			  ptr_to_last->member_ptr->citno = citno ;
			  strcpy (ptr_to_last->member_ptr->type, mem_type) ;
			  file_ptr = ptr_to_last ;     
			  /********/		      
			  _NFMdebug ((fname, "%d : %s : %d : %d : %d : %d\n",
				      sa_struct.sano, file_ptr->n_cofilename,
				      file_ptr->member_ptr->cat_no,
				      file_ptr->n_itemno,
				      file_ptr->n_filenum,
				      file_ptr->n_fileversion)) ;
                          if (strncmp (mem_type, "P", 1) == 0)
                          {
                            /* 6/2/94 only add the raster file to nfmsetcit 
                               table, do nothing else with additional raster 
                               file attached as a primary member. Since there 
                               are many possible
                               states this additional raster file could be in,
                               such as checked-out as an item in the 
                               same/different location, or checked out
                               as a primary member of another set in the
                               same/different locataion, etc... */
                               
                            _NFMdebug ((fname, "do not do ANYTHING\n"));
                            continue;
                          }
			  
			  sprintf (tmp_str, " (n_sano = %d and  n_filename = '%s' and n_catalogno = %d and n_itemno = %d and n_filenum = %d and n_fileversion = %d) ",
				   sa_struct.sano, 
				   file_ptr->n_cofilename, 
				   file_ptr->member_ptr->cat_no,
				   file_ptr->n_itemno,
				   file_ptr->n_filenum,
				   file_ptr->n_fileversion) ;
			  
			  sprintf (sql_str1, "select n_filename, n_catalogno, n_itemno, n_filenum, n_fileversion, n_co, n_copy, n_ref from nfmsafiles where %s",
				   tmp_str);
			  
                          status = NFMlock_table ("nfmsafiles");
                          if (status != NFM_S_SUCCESS)
                          {
			      MEMclose (&att_files_list) ;
			      MEMclose (&sql_buffer1) ;
			      MEMclose (&sql_buffer) ;
			      free (att_files_flag) ;
                              _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", 
                                          status ));
                              return (status);
                          }
			  status = SQLquery (sql_str1, &sql_buffer1, MEM_SIZE) ;
			  if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
			    {
			      MEMclose (&att_files_list) ;
			      MEMclose (&sql_buffer1) ;
			      MEMclose (&sql_buffer) ;
			      free (att_files_flag) ;
			      _NFMdebug ((fname, "SQLquery : status : <0x%.8x>\n",
					  status)) ;
			      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
			      return (NFM_E_SQL_QUERY) ;
			    }
                          SQLstmt ("COMMIT WORK");
			  
			  if (status != SQL_I_NO_ROWS_FOUND)
			    {
			      status = MEMbuild_array (sql_buffer1) ;
			      if (status != MEM_S_SUCCESS)
				{
				  MEMclose (&att_files_list) ;
				  MEMclose (&sql_buffer) ;
				  MEMclose (&sql_buffer1) ;
				  free (att_files_flag) ;
				  _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
					      status)) ;
				  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
				  return (NFM_E_MEM) ;
				}
			      
			      data1 = (char **) sql_buffer1->data_ptr ;
			      
			      sprintf (sql_str1, "update nfmsafiles set n_ref = %d where n_filename = '%s' and n_sano = %d and n_catalogno = %s and n_itemno = %s and n_filenum = %s and n_fileversion = %s",
				       atol (data1[offset1+7]) +1,
				       data1[offset1], 
				       sa_struct.sano, 
				       data1 [offset1+1], data1 [offset1+2],
				       data1[offset1+3], data1 [offset1+4]) ;
			      strcpy (file_ptr->lfm_action, "U") ;
			      MEMclose (&sql_buffer1) ;
			    }
			  else
			    {
			      sprintf (sql_str1, "insert into nfmsafiles (n_ref, n_filename, n_sano, n_catalogno, n_itemno, n_filenum, n_fileversion, n_co, n_copy) values (1, '%s', %d, %d, %d, %d, %d, 'N', 'N')",
				       file_ptr->n_cofilename,
				       sa_struct.sano, 
				       file_ptr->member_ptr->cat_no,
				       file_ptr->n_itemno,
				       file_ptr->n_filenum,
				       file_ptr->n_fileversion) ;
			      strcpy (file_ptr->lfm_action, "I") ;
			    }
                          status = NFMlock_table ("nfmsafiles");
                          if (status != NFM_S_SUCCESS)
                          {
			      MEMclose (&att_files_list) ;
			      free (att_files_flag) ;
			      MEMclose (&sql_buffer) ;
                              _NFMdebug ((fname, "NFMlock_table 0x%.8x\n",
                                          status));
                              return (status);
                          }
			  status = SQLexec_imm (sql_str1) ;
			  if ((status != SQL_S_SUCCESS) &&
			      (status != SQL_E_DUPLICATE_VALUE))
			    {
			      MEMclose (&att_files_list) ;
			      free (att_files_flag) ;
			      MEMclose (&sql_buffer) ;
			      _NFMdebug ((fname, "SQLexec_imm failed : status = <0x%.8x>\n",
					  status)) ;
			      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
			      return (NFM_E_SQL_STMT) ;
			    }
                          SQLstmt ("COMMIT WORK");
			}
		    } /* for */
		  if (! found) 
		    {
		      /* file x not in catalog x need to detach file */;
		      _NFMdebug ((fname, "Warning file not found for %s\n",
				  attached_filename_list [index_y])) ;
		      ERRload_struct (NFM, NFM_W_MS_FEWER_ATT_FILES, "","") ;
		    }
		} /* att_flag == 0 */
	    } /* for index_y */
	  MEMclose (&sql_buffer) ;
	}
      else
	{
	  /* if status == SQL_I_NO_ROWS_FOUND */
	  *no_added = 0 ;
	  _NFMdebug ((fname, "Warning : Reference files could not be found in database\n"));
	  ERRload_struct (NFM, NFM_W_MS_NO_ATT_FILES, "", "") ;
	}
    } /* if num_attached > 0 */
  else
    {
      _NFMdebug ((fname, "NO MEMBERS ADDED\n")) ;
    }

  free (att_files_flag) ;
  
  MEMclose (&att_files_list) ;

   if ((*no_added) && (_NFMdebug_st.NFMdebug_on == 1)) 
    {
      _NFMprint_NFMset_member (*no_added, *new_member_list)  ;
    }

  if (_NFMdebug_st.NFMdebug_on)
    _NFMprint_file_info_struct (*file_info) ;

  if (num_att_files == 0)
    {
      /* demote set parent to item */
      sprintf ( tmp_str, 
	       "update %s set n_setindicator = NULL where n_itemno = %d",
	       p_name, ms_p_itemno) ;

      status = SQLstmt (tmp_str) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	{
	  _NFMdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	  return (NFM_E_SQL_STMT) ;
	}
    }

  _NFMdebug ((fname, "SUCCESSFUL : Number Added %d : Number Dropped %d\n",
	      *no_added, *no_dropped)) ;
  return (NFM_S_SUCCESS) ;
}


long NFMbuild_microstation_set (p_catalogname, p_catalogno, p_itemno, 
				n_cofilename, promoted_to_set, sa_struct)
     char *p_catalogname ;
     long p_catalogno ;
     long p_itemno ;
     char *n_cofilename ;
     long *promoted_to_set ;
     struct NFMsto_info sa_struct ;     
{
  char *fname = "NFMbuild_microstation_set" ;
  long   status, x, comma,i, citno, num_att_files, offset=0,y, num_ras_files  = 0;
  long  warning_loaded, prev_itemno ;
  long filetype=0;
  MEMptr att_files_list = NULL, buffer = NULL ;
  char **data, **attached_filename_list, *st, **att_ras_filelist ;
  char tmp_str [512], mem_type[2] ;
  int ras_index[NFM_MAX_MS_REFERENCE_FILES]; /* PS */


/* Added feature for promoting a drawing to Microstation Set while working
   from  DM/DBA on PC. Request from DM/DBA    -- Jujare, 13 Nov 95 */ 
/* Added Code to check for IBM PC also, as per the request by Michele/Statoil
                                              -- Jujare, 31 Jan 96 */ 
  struct NFMsto_info *sto_list1=NULL ;
  char src_file[256], dst_file[256], dst_path[256], file_type[2],
       dec_passwd[25];
  long file_size ;
  
  _NFMdebug ((fname, "parent catalog name <%s> : parent catalog no <%d> : parent item no <%d> : cofilename <%s>\n",
	      p_catalogname, p_catalogno, p_itemno, n_cofilename)) ;
  warning_loaded = 0 ;
  *promoted_to_set = 0 ;     /* init to not promoted to set */
  sprintf (tmp_str, "Select n_setindicator from %s where n_itemno = %d",
	   p_catalogname, p_itemno) ;

  status = SQLquery (tmp_str, &buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&buffer) ;
    _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
	        status)) ;
    ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
    if (sa_struct.option == DM_AUTOCAD || 
        sa_struct.option == DM_MICROSTATION)
      _DMdo_nothing ();
    return (NFM_E_SQL_QUERY) ;
  }

  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&buffer) ;
    _NFMdebug ((fname, "MEMbuild_array (buffer) : status = <0x%.8x>\n",
	        status)) ;
    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
    if (sa_struct.option == DM_AUTOCAD || 
        sa_struct.option == DM_MICROSTATION)
      _DMdo_nothing ();
    return (NFM_E_MEM) ;
  }

  data = (char **) buffer->data_ptr ;
  /* if M type item is already a set return */
  /* 6/22/93, modify to check for length because of DM/Manager */
  /*if (strcmp (data [0], "Y") == 0)*/

  _NFMdebug ((fname, "n_setindicator == [%s] strlen (data[0]) = %d\n", 
                     data[0], strlen(data[0])));

  if (strlen (data [0]) )
  {
    MEMclose (&buffer) ;
    _NFMdebug ((fname, "M type item already a set - no attempt to rebuild\n")) ;
    if (sa_struct.option == DM_AUTOCAD || 
        sa_struct.option == DM_MICROSTATION)
      _DMdo_nothing ();
    return (NFM_S_SUCCESS) ;
  }

  MEMclose (&buffer) ;

  _NFMdebug ((fname, "Machine id must be CLIX or UNIX or PC or IBM PC is <%s>\n", 
              sa_struct.machid));
  if ((strcmp (sa_struct.machid, "UNIX") == 0) || 
      (strcmp (sa_struct.machid, "CLIX") == 0) ||
      (strcmp (sa_struct.machid, "PC") == 0)   || 
      (strcmp (sa_struct.machid, "IBM PC") == 0))
  {
    if (sa_struct.option == DM_AUTOCAD ||
        sa_struct.option == DM_MICROSTATION)
    {
      if (sa_struct.option == DM_AUTOCAD)
         filetype = NFM_GET_ACAD_FILES;
      else
         filetype = NFM_GET_MICRO_FILES;
        status = DMfs_get_list_attached_reference_files ( sa_struct.pathname,
							 n_cofilename,
							 &att_files_list,
     							 filetype) ;
        NFMCalled_DM = 1;
    }
    else
    {
      if (sa_struct.option == NFM_AUTOCAD)
      {
        MEMopen (&att_files_list, MEM_SIZE);
      }

 
      if ((strcmp (sa_struct.machid, "UNIX") == 0) ||
          (strcmp (sa_struct.machid, "CLIX") == 0))
      {
       status = NFMfs_get_list_attached_reference_files (sa_struct.nodename,
						sa_struct.username, 
						sa_struct.passwd,
						sa_struct.pathname,
               				        n_cofilename, 
      						&att_files_list) ;
      }

/* Added feature for promoting a drawing to Microstation Set while working
   from  DM/DBA on PC. Request from DM/DBA    -- Jujare, 13 Nov 95 */ 
/* Added Code to check for IBM PC also, as per the request by Michele/Statoil
                                              -- Jujare, 31 Jan 96 */ 
      else if ((strcmp (sa_struct.machid, "PC")     == 0) || 
               (strcmp (sa_struct.machid, "IBM PC") == 0)) 
       {

           sto_list1 = (struct NFMsto_info *) malloc (sizeof (struct NFMsto_info));
           sto_list1->sano = 4;  
           strcpy(sto_list1->saname, "NFMFILES");

           status = NFMget_storage_info (sto_list1->saname, &(sto_list1->sano),
           sto_list1->nodename, sto_list1->username, sto_list1->passwd,
           sto_list1->pathname, sto_list1->devicetype, sto_list1->plattername,
           sto_list1->partition, sto_list1->nfs, sto_list1->compress,
           sto_list1->machid, sto_list1->opsys,sto_list1->tcpip, sto_list1->xns,
           sto_list1->decnet, sto_list1->netware);

           if (status != NFM_S_SUCCESS)
           {
            free (sto_list1);
            _NFMdebug ((fname, "NFMget_storage_info failed 0x%.8x\n", status));
            return (status);
           }
           
           sprintf(src_file,"%s/%s",sa_struct.pathname,
                                    n_cofilename);
           _NFMdebug ((fname, "src_file  %s\n", src_file));
           sprintf(dst_file,"/usr/tmp/%s",n_cofilename);
           _NFMdebug ((fname, "dst_file  %s\n", dst_file));
           sprintf(dst_path,"/usr/tmp/");
           sprintf(file_type,"M");
              
           status = NFMdecrypt (sa_struct.passwd, dec_passwd);                      
           NFMftp_receive (sa_struct.nodename, sa_struct.username, 
                           dec_passwd, src_file, dst_file, 
                           file_type, &file_size);


           status = NFMfs_get_list_attached_reference_files(sto_list1->nodename,
						sto_list1->username, 
						sto_list1->passwd,
						dst_path,
                 				n_cofilename, 
      						&att_files_list) ;
       }
      else 
       {
           _NFMdebug ((fname, "Not UNIX OR PC OR IBM PC : ignored CASE! \n")) ;
           return (NFM_S_SUCCESS) ;
        }
/* End of Addition -- Jujare, 13 Nov 95 */ 
       NFMCalled_DM = 0;
    }
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, 
            "NFMfs_get_list_attached_refeerence_files 0x%.8x\n", status)) ;
	  return (status) ;
    }
  }
  else
  {
    _NFMdebug ((fname, "Ignore type M (not clix nor PC nor IBM PC)\n")) ;
    if (sa_struct.option == DM_AUTOCAD || 
        sa_struct.option == DM_MICROSTATION)
      _DMdo_nothing ();
    return (NFM_S_SUCCESS) ;
  }
  
  if (! att_files_list)
  {
    _NFMdebug ((fname, "No attached files exist\n")) ;
    return (NFM_S_SUCCESS) ;
  }

  status = MEMbuild_array (att_files_list) ;
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", "") ;
    MEMclose (&att_files_list) ;
    _NFMdebug ((fname, 
      "MEMbuild_array (att_files_list) failed : status = <0x%x.8>\n", status)) ;
    return (NFM_E_MEM) ;
  }
  
  attached_filename_list = (char **) att_files_list -> data_ptr ;
  _NFMdebug ((fname, "number of att files area %d\n",
	      att_files_list-> rows)) ;

  num_att_files = att_files_list -> rows ;
  if (att_files_list->rows == 0)
  {
    MEMclose (&att_files_list) ;
    _NFMdebug ((fname, "THIS MICROSTATION ITEM HAS NO ATTACHED FILES - CAN NOT BE PROMOTED TO A SET\n")) ;
    return (NFM_S_SUCCESS) ;
  }

  st = (char *) malloc (att_files_list->rows*512 + 512) ;
  if (st == NULL)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
    MEMclose (&att_files_list) ;
    return (NFM_E_MALLOC) ;
  }
/* ADDED By NAIDU for Euro-Disney -- Dt 24 Jul, 1995 */
   sprintf(st, "select n_cofilename from f_%s where n_itemnum = %d and n_filetype = 'R' and n_fileversion = (select max(n_fileversion) from f_%s where n_itemnum = %d)", p_catalogname, p_itemno, p_catalogname, p_itemno);
  status = SQLquery( st, &buffer, MEM_SIZE) ;
   if (status != SQL_S_SUCCESS)
    {
      _NFMdebug((fname, "SQL query for RAS files failed \n"));
    }
    else
    {
 
        status = MEMbuild_array (buffer) ;
        if (status != MEM_S_SUCCESS)
        {
        MEMclose (&buffer) ;
        _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
                  status)) ;
        ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
        }
 
        att_ras_filelist = (char **) buffer -> data_ptr ;
        num_ras_files = buffer -> rows;
        _NFMdebug((fname, "Raster files in self Item = %d\n", buffer -> rows));
        if(buffer -> rows == num_att_files)
                return (NFM_S_SUCCESS) ;
    }  /* If status != SQL_S_SUCCESS */
for (y=0; y < num_att_files; y++)
        ras_index[y] = 1;
 
for( x=0; x<num_ras_files; x++)
   {
        for (y=0; y<num_att_files; y++)
            {
                if(strcmp(att_ras_filelist [x], attached_filename_list [y]) == 0){
                        ras_index[y] = 0;
                        _NFMdebug((fname, "att_ras_file [%d] = %s # attached_filename [%d] = %s\n", x, att_ras_filelist[x], y, attached_filename_list[y]));
                        _NFMdebug((fname, "ras_index[%d] = %d\n", y, ras_index[y]));
                        break;
                        }
            }
   }
  MEMclose (&buffer) ;
/* End ADDED By NAIDU for Euro-Disney -- Dt 24 Jul, 1995 */

/* only the items that are checked in at least once */
/* take out n_fileco check because of TR#249301876 9/10/93 */

  sprintf (st, "Select DISTINCT n_itemnum, n_cofilename, n_filetype from f_%s where n_itemnum != %d and (",
	   p_catalogname,  p_itemno) ;

  comma = 0 ;
  for (x=0; x<att_files_list->rows;x++)
    {
      _NFMdebug ((fname, "attached file name <%s>\n", 
			  attached_filename_list [x])) ;
/* ADDED By NAIDU for Euro-Disney -- Dt 24 Jul, 1995 */
      if(ras_index[x] != 0){
/* End ADDED By NAIDU for Euro-Disney -- Dt 24 Jul, 1995 */
      if (comma) strcat (st, " or ") ;
      else comma = 1 ;
      sprintf (tmp_str, 
	       "(n_fileversion = (select max(n_fileversion) from f_%s where n_cofilename = '%s') and n_cofilename = '%s')",
	       p_catalogname, attached_filename_list [x],
	       attached_filename_list [x]) ;

/*      sprintf (tmp_str, "n_cofilename = '%s'", attached_filename_list [x]) ;*/
      strcat (st, tmp_str) ;
    }
  }

  strcat (st, ")") ;
  _NFMdebug((fname, "SQLstr = %s\n", st));
  status = SQLquery( st, &buffer, MEM_SIZE) ;
  free (st) ;
  if (status == SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&att_files_list) ;
      MEMclose (&buffer) ;
      _NFMdebug ((fname, 
	      "Warning : No attached files for this item (design file) have been added\n")) ;
      ERRload_struct (NFM, NFM_W_MS_NO_ATT_FILES, "", "") ;
      return (NFM_S_SUCCESS) ;
    }
  else if (buffer -> rows != (num_att_files - num_ras_files) )
    {
      status = MEMbuild_array (buffer) ;
      if (status != MEM_S_SUCCESS)
	{
	  MEMclose (&buffer) ;
	  MEMclose (&att_files_list) ;
	  _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
	  return (NFM_E_MEM) ;
	}
      
      data = (char **) buffer -> data_ptr ;

      _NFMdebug ((fname, "Some attached files for this item (design file) were not added to I/NFM")) ;
      ERRload_struct (NFM, NFM_W_MS_FEWER_ATT_FILES, "", "") ;
    }
  else if (status != SQL_S_SUCCESS) 
    {
      MEMclose (&att_files_list) ;
      MEMclose (&buffer) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      _NFMdebug ((fname, "SQL query failed : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  MEMclose (&att_files_list) ;

  status = MEMbuild_array (buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&buffer) ;
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  data = (char **) buffer -> data_ptr ;
  /* check for multiple type 'M' files per item */
  prev_itemno = -1 ;
  for (i=0; i<buffer->rows; i++)
    {
      offset = i*buffer->columns ;
      if ((prev_itemno == atol (data [offset])) ||
	  (atol(data[offset]) == p_itemno))
	{
	  MEMclose (&buffer) ;
	  _NFMdebug ((fname, "Item %d has multiple M type files per item\n",
		      prev_itemno)) ;
	  ERRload_struct (NFM, NFM_E_MS_MUL_FILES_PER_ITEM,"","");
	  return (NFM_E_MS_MUL_FILES_PER_ITEM) ;
	}
      prev_itemno = atol(data [offset]) ;
    }

  for (i=0; i<buffer->rows; i++)
    {
      offset = i * buffer->columns ;
      tmp_str [0] = 0 ;

      status = NFMget_serial_slot (NFMglobal.NFMuserid, 
				   "nfmsetcit", "n_citno", &citno) ;
      if (status != NFM_S_SUCCESS)
	{
	  MEMclose (&buffer) ;
	  _NFMdebug ((fname, "Get serial slot : status = <0x%.8x>\n",
		      status)) ;
	  return (status) ;
	}
      
      _NFMdebug ((fname, "data[offset+2] = %s\n", data[offset+2]));

      if (strncmp (data[offset+2], "R", 1))
        strcpy (mem_type, "S");
      else
        strcpy (mem_type, "P");

      sprintf (tmp_str, 
	       "Insert into nfmsetcit (n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno, n_type) values (%d, %d, %d, %d, %s, '%s')",
      citno, p_catalogno, p_itemno, p_catalogno, data [offset], mem_type) ;

      status = SQLexec_imm (tmp_str) ;
      if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
	{
	  /* undo all insert so far */
	  MEMclose (&buffer) ;
	  sprintf (tmp_str, "Delete from nfmsetcit where n_pcatalogno = %d and n_pitemno = %d",
		   p_catalogno, p_itemno) ;
	  SQLstmt(tmp_str) ;
	  _NFMdebug ((fname, "SQL exec_imm failed : status = <0x%.8x>\n",
		      status)) ;
	  ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	  return (NFM_E_SQL_STMT) ;
	}
    }

  MEMclose (&buffer) ;

  if (filetype == 0)
    sprintf (tmp_str, "update %s set n_setindicator = 'Y' where n_itemno = %d",
	   p_catalogname, p_itemno) ;
  else
    sprintf (tmp_str, "update %s set n_setindicator = 'D' where n_itemno = %d",
	   p_catalogname, p_itemno) ;

  status = SQLexec_imm (tmp_str) ;
  if ((status != SQL_S_SUCCESS) && (status != SQL_E_DUPLICATE_VALUE))
    {
      /* undo all insert so far */
      sprintf (tmp_str, "Delete from nfmsetcit where n_pcatalogno = %d and n_pitemno = %d",
	       p_catalogno, p_itemno) ;
      SQLstmt(tmp_str) ;
      _NFMdebug ((fname, "SQLexec_imm failed : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
      return (NFM_E_SQL_STMT) ;
    }
  
  *promoted_to_set = 1 ;
  _NFMdebug ((fname, "Item type M was succesfully promoted to Ms set\n")) ;
  ERRload_struct (NFM, NFM_I_ITEM_PROMOTED_TO_MS_SET, "", "") ;
  return (NFM_I_ITEM_PROMOTED_TO_MS_SET) ;
}
