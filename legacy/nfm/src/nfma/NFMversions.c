#include "machine.h"
#include "NFMA.h"
#include "NFMfto_buf.h"
#include "WFstruct.h"
#include "NFMitemfiles.h"
#include "NFTftr.h"
#include "UTIerrordef.h"

extern struct NFMglobal_st NFMglobal ;
extern struct WFstruct WFinfo ;

extern long freeNFMitem_files;
extern struct NFMitem_entry *NFMitem_files;
extern long NFM_FTR_INITED;

 long NFMpurge_versions (catalog_name, item_name, item_rev) 
   char *catalog_name, *item_name, *item_rev ;
   {
     static char *fname = "NFMpurge_versions";
     MEMptr move_buffer = NULL, sql_buffer = NULL, error_ptr = NULL ;
     long status ;
     long item_no, cat_no ;
     long  i, offset, first =1, status1, comma ;
     char sql_str [1024], *str, tmp_str [200], *str2 ;
     char **data ;
     struct fto_buf file_buffer ;

     _NFMdebug ((fname, "Purge %s %s from catalog %s\n",
		 item_name, item_rev, catalog_name)) ;
     error_ptr = error_ptr ;

     if (WFinfo.catalog_no > 0)
       {
	 cat_no = WFinfo.catalog_no ;
       }
     else
       {
	 status = NFMget_catalog_no (NFMglobal.NFMuserid, catalog_name, &cat_no) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "BAD CATALOG %s : status = <0x%.8x>\n",
			 catalog_name, status)) ;
	     ERRload_struct (NFM, NFM_E_BAD_CATALOG, "", NULL) ;
	     return (NFM_E_BAD_CATALOG) ;
	   }
       }

     if (WFinfo.item_no > 1)
       {
	 item_no = WFinfo.item_no ;
       }
     else
       {
	 status = NFMget_item_no (NFMglobal.NFMuserid, catalog_name, item_name, 
				  item_rev, &item_no) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Bad Item %s %s in cat %s\n",
			 item_name, item_rev, catalog_name)) ;
	     ERRload_struct (NFM, NFM_E_BAD_ITEM, "", NULL) ;
	     return (NFM_E_BAD_ITEM) ;
	   }
       }

/** get cifilename for last versions ***/

     status = NFMset_autocommit_off (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : Set autocommit off : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     sprintf (sql_str,
	      "SELECT n_fileversion, n_cisano, n_cifilename, n_fileno, n_cifilesize, n_fileco, n_archiveno \
FROM f_%s WHERE n_itemnum = %d and n_fileversion != (select max(n_fileversion) from f_%s where n_itemnum = %d) and n_fileversion != 0 order by n_fileversion",
	      catalog_name, item_no, catalog_name, item_no) ;

     status = SQLquery (sql_str, &sql_buffer, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
       {
	 MEMclose (&sql_buffer);
	 NFMrollback_transaction (0) ;
	 if (status == SQL_I_NO_ROWS_FOUND)
	   {
	     _NFMdebug ((fname, "No versions to purge\n")) ;
	     ERRload_struct (NFM, NFM_I_ONLY_LAST_VERSION_EXISTS, "", "") ;
	     return (NFM_I_ONLY_LAST_VERSION_EXISTS) ;
	   }

	 _NFMdebug ((fname, "SQL Query: status = <0x%.8x>\n",status));
	 ERRload_struct (NFM, NFM_E_SQL_QUERY, "") ;
	 return (NFM_E_SQL_QUERY) ;
      }

     status = MEMbuild_array (sql_buffer);
     if (status != MEM_S_SUCCESS)
      {
        MEMclose (&sql_buffer);
	 NFMrollback_transaction (0) ;
        _NFMdebug ((fname, "MEMbuild_array: status = <0x%.8x>\n",status));
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        return (NFM_E_MEM) ;
      }

     data = (char **) sql_buffer -> data_ptr;
     str = (char *) malloc (sql_buffer->rows * 50) ;
     if (str == NULL)
       {
	 NFMrollback_transaction (0) ;
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }

     str [0] = 0 ;
     str2 = (char *) malloc (sql_buffer->rows * 50+200) ;
     if (str2 == NULL)
       {
	 NFMrollback_transaction (0) ;
	 _NFMdebug ((fname, "Malloc failed\n")) ;
	 ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
	 return (NFM_E_MALLOC) ;
       }
     str2 [0] = 0 ;
     comma = 0 ;
     for (i=0; i<sql_buffer->rows; i++)
       {
	 offset = i*sql_buffer->columns ;
	 if (strcmp (data [offset+ 5], "O") == 0) continue ;
	 if ((strcmp (data [offset+ 5], "N") == 0) &&
	     (atol (data[offset+ 6]) > 0))
	   {
	     sprintf (tmp_str, "Update f_%s set n_fileco = 'O' where n_fileno = %s",
		      catalog_name, data [offset+3]) ;
	     status = SQLstmt (tmp_str) ;
	     if (status != SQL_S_SUCCESS)
	       {
		 _NFMdebug ((fname, "Failure : SQL stmt : status = <0x%.8x>\n",
			     status)) ;
		 ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		 return (NFM_E_SQL_STMT) ;
	       }
	     continue ;
	   }

	 if (comma) strcat (str, " OR ")  ;
	 else comma = 1 ;
	 sprintf (tmp_str, "n_fileversion = %s", data [offset]) ;
	 strcat (str, tmp_str) ;
       }

     sprintf (str2,
     "delete FROM f_%s WHERE n_itemnum = %d and (%s)",
	      catalog_name, item_no, str) ;

     free (str) ;

     status = SQLstmt (str2) ;
     if ((status != SQL_S_SUCCESS) && (status != SQL_I_NO_ROWS_FOUND))
       {
	 NFMrollback_transaction (0) ;
	 _NFMdebug ((fname, "SQLexec imm : status = <0x%.8x>\n",
		     status)) ;
	 ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
	 return (NFM_E_SQL_STMT) ;
       }

     status1 = status ;

     free (str2) ;

     status = NFMset_autocommit_on (0) ;
     if (status != NFM_S_SUCCESS)
       {
	 _NFMdebug ((fname, "Failure : set autocommit on : status = <0x%.8x>\n",
		     status)) ;
	 return (status) ;
       }

     if (status1 == SQL_I_NO_ROWS_FOUND)
       {
	 _NFMdebug ((fname, "No Versions Exist\n")) ;
	 ERRload_struct (NFM, NFM_I_ONLY_LAST_VERSION_EXISTS, "", "") ;
	 return (NFM_S_SUCCESS) ;
       }

     first = 1 ; 

     for (i=0; i<sql_buffer->rows; i++)
       {
	 offset = i*sql_buffer->columns ;
	 if (strcmp (data [offset+5], "O") == 0) continue ;

	 status = _NFMget_sano_info_fto_buf (atol (data [offset+1]), "",
					     &file_buffer) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, " Bad Storage Area : status = <0x%.8x>\n\
",
			 status)) ;
	     continue ;
	   }
	 file_buffer.n_status1 = NFM_DELETE_FILE ;
	 if (first)
	   {
	     first = 0 ;
	     status = NFMbuild_fto_buffer (&move_buffer, MEM_SIZE) ;
	     if (status != NFM_S_SUCCESS)
	       {
		 _NFMdebug ((fname, "Build fto buffer failed : status = <0x%.8x>\n",
			     status)) ;
		 continue ;
	       }
	   }
/*****	 
	 if (strcmp (data [offset +2], "") == 0) 
	 {
****/
            status = NFMget_file_name (NFMglobal.NFMuserid,
                                       cat_no, atol (data [offset+3]),
                                       file_buffer.n_cifilename) ;
            if (status != NFM_S_SUCCESS)
              {
                _NFMdebug ((fname, "Get file name : status = <0x%.8x>\n",
                            status)) ;
                return (status) ;
              }
/************
          }
        else
          {
            strcpy (file_buffer.n_cifilename, data[offset+2]) ;
          }
**********/
	 status = NFMload_fto_buf (&move_buffer, &file_buffer) ;
	 if (status != NFM_S_SUCCESS)
	   {
	     _NFMdebug ((fname, "Loading first row failed : status = <0x%.8x>\n",
			 status)) ;
	     return (status) ;
	   }
       
       }
     if (_NFMdebug_st.NFMdebug_on)
       {
	 MEMprint_buffer ("move buffer", move_buffer, 
			  _NFMdebug_st.NFMdebug_file) ;
       }
     status = NFMfs_chg_files (&move_buffer) ;
     if (status != NFM_S_SUCCESS)
       {
	 MEMclose (&move_buffer) ;
	 _NFMdebug ((fname, "Delete Move File : status = <0x%.8x>\n",
		     status));
	 ERRload_struct (NFM, NFM_W_DELETE_FILES_FAILED, "", "") ;
       }
	 
     MEMclose (&move_buffer) ;
     MEMclose (&sql_buffer);

     _NFMdebug ((fname, "SUCCESSFUL\n")) ;
     return (NFM_S_SUCCESS) ;
   }


long NFMget_item_versions (catalog_name, item_name, item_rev,
			   synonym_list, data_list)
     char     *catalog_name;         /*i - catalog */
     char     *item_name ;           /*i - item name */
     char     *item_rev ;            /*i - item rev */
     MEMptr   *synonym_list ;            /*o - synonym list */
     MEMptr   *data_list;            /*o  - buffer */
{
  static char *fname = "NFMget_item_versions" ;
  long status, max_version ;
  char sql_str [1024] ;
  char **data, cat_str [500], datatype [50] ;
  int  i, j ;
  MEMptr sql_buffer = NULL ;
  MEMptr oldest_version_info = NULL ;
  long   _NFMinsert_synonym () ;
  long _NFMcheck_item_condition_roll_version () ;

  _NFMdebug ((fname, "ENTER\n")) ;

  /* item must not be flagged, archived, backed up or locked */
  /* item must be checked in */

  status = _NFMcheck_item_condition_roll_version (catalog_name,
						  item_name, item_rev,
						  &max_version,
						  &oldest_version_info) ;
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&oldest_version_info) ;
      _NFMdebug ((fname, "Item in Inappropiate state for rollback version\n"));
      return (status) ; 
    }

  status = MEMclose (&oldest_version_info) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose : oldest_version_info : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  sprintf (sql_str, "Select n_synonym, n_seqno, n_name from nfmattributes \
where n_tableno in (select n_tableno from nfmtables where n_tablename = 'f_%s')\
and (n_name = 'n_fileversion' or n_name = 'n_filenum' or n_name = 'n_ciuser' or n_name = 'n_cidate' or n_name = 'n_cofilename' or n_name = 'n_cifilesize' or n_name = 'n_fileno' or n_name = 'n_cifilename' or n_name = 'n_cisano' \
or n_name = 'n_archiveno') \
order by n_seqno",
	   catalog_name) ;

  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;

  if (status != SQL_S_SUCCESS)
    {
      MEMclose (&sql_buffer) ;
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Only one version exist\n")) ;
	  ERRload_struct (NFM, NFM_I_ONLY_LAST_VERSION_EXISTS, "", "") ;
	  return (NFM_I_ONLY_LAST_VERSION_EXISTS) ;
	}

      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array (sql_buffer) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;

  /* open buffer */
  status = MEMopen (synonym_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Open : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  sprintf (datatype, "char(%d)", NFM_SYNONYM) ;
  status = MEMwrite_format (*synonym_list, "n_synonym", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  sprintf (datatype, "char(%d)", NFM_READ) ;
  status = MEMwrite_format (*synonym_list, "n_read", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = _NFMinsert_synonym (sql_buffer, "n_fileversion", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_filenum", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_ciuser", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_cidate", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_cofilename", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  
  status = _NFMinsert_synonym (sql_buffer, "n_cifilesize", data,
			       "Y", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_fileno", data,
			       "N", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMinsert_synonym (sql_buffer, "n_cifilename", data,
			       "N", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }
  status = _NFMinsert_synonym (sql_buffer, "n_cisano", data,
			       "N", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = _NFMinsert_synonym (sql_buffer, "n_archiveno", data,
			       "N", synonym_list) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Insert failed : status = <0x%.8x>\n", status)) ;
      return (status) ;
    }

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose sql_buffer : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  sprintf (cat_str, "select n_itemno from %s where n_itemname = '%s' and n_itemrev = '%s'", 
	   catalog_name, item_name, item_rev) ;


  sprintf (sql_str, "Select n_fileversion, n_filenum, n_ciuser, n_cidate, n_cofilename, n_cifilesize, n_fileno, n_cifilename, n_cisano, n_archiveno \
from f_%s \
where n_itemnum in (%s) and n_fileversion != 0 and n_fileversion != (select max(n_fileversion) from f_%s where n_itemnum in (%s))  \
and n_fileco != 'O' \
order by n_fileversion, n_cofilename",
	   catalog_name, cat_str, catalog_name, cat_str) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      if (status == SQL_I_NO_ROWS_FOUND)
	{
	  _NFMdebug ((fname, "Only one version exist\n")) ;
	  ERRload_struct (NFM, NFM_I_ONLY_LAST_VERSION_EXISTS, "", "") ;
	  return (NFM_I_ONLY_LAST_VERSION_EXISTS) ;
	}
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
      return (NFM_E_SQL_QUERY) ;
    }
  
  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMbuild_array : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer->data_ptr ;

  status = MEMopen (data_list, 2 * MEM_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Open : status = <0x%.8x>", status));
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*data_list, "n_fileversion", "integer");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*data_list, "n_filenum", "integer");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  sprintf (datatype, "char(%d)", NFM_CIUSER) ;
  status = MEMwrite_format (*data_list, "n_ciuser", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*data_list, "n_cidate", "timestamp") ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  sprintf (datatype, "char(%d)", NFM_COFILENAME) ;
  status = MEMwrite_format (*data_list, "n_cofilename", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  status = MEMwrite_format (*data_list, "n_cifilesize", "integer");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*data_list, "n_fileno", "integer");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  sprintf (datatype, "char(%d)", NFM_CIFILENAME) ;
  status = MEMwrite_format (*data_list, "n_cifilename", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*data_list, "n_cisano", "integer");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }

  status = MEMwrite_format (*data_list, "n_archiveno", "integer");
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", NULL) ;
      _NFMdebug ((fname, "MEM Wr Format : status = <0x%.8x>", status));
      return (NFM_E_MEM);          
    }
  
  for (i=0; i<sql_buffer->rows; i++)
    {
      sql_str [0]=0 ;
      for (j=0; j<sql_buffer->columns; j++)
	{
/*	  _NFMdebug ((fname, "%s\n", data [i*sql_buffer->columns+j])) ; */
	  strcat (sql_str, data [i*sql_buffer->columns+j]);
	  strcat (sql_str, "\1");
	}

      status = MEMwrite (*data_list, sql_str);
      if (status != MEM_S_SUCCESS)
	{
	  ERRload_struct (NFM, NFM_E_MEM, "", NULL);
	  _NFMdebug ((fname, "MEMwrite : <0x%.8x>", status));
	  return (NFM_E_MEM);
	}
    }

  status = MEMclose (&sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose sql_buffer : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

 long NFMroll_version_forward (catalog_name, item_name, item_rev, data_list)
   char     *catalog_name ;        /* i - catalog name */
   char     *item_name ;           /* i - item name */
   char     *item_rev ;            /* i - item rev */
   MEMptr   data_list ;            /* i - File Level Information */
{
  static char *fname = "NFMroll_version_forward" ;
  long status, item_no, max_version, i, catalog_no ;
  int  a, b, c, d, e, f, g, fileno_pos, cifilename_pos, cisano_pos ;
  int  filenum_pos, y ;
  long fw_cisano, fw_fileno, cisano, fileno, o_fileno ;
  char *sql_str, f_cat [NFM_CATALOGNAME+1] ;
  long  comma, offsety, offseti, user_filename ;
  char **data, **column, **oldest_version_data, **oldest_version_column ;
  char **datax, **columnx, **formatx ;
  char tmp_str [1024], cifilename [50], *str, *str1 ;
  MEMptr oldest_version_info = NULL, rename_buffer = NULL, sql_buffer = NULL;
  MEMptr invert_buffer = NULL ;
  long  _NFMcheck_item_condition_roll_version () ;
  MEMptr files=NULL, keywords=NULL;
  long no_keywords=0;
  MEMptr file_list=NULL;

  /* item must NOT be flagged, archived, backed up or locked */
  /* item must be checked in */

  _NFMdebug ((fname, "ENTER\n")) ;
  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("data_list", data_list, _NFMdebug_st.NFMdebug_file);
  }

  if (WFinfo.catalog_no > 0)
    {
      catalog_no = WFinfo.catalog_no ;
    }
  else
    {
      status = NFMget_catalog_no (NFMglobal.NFMuserid, catalog_name, &catalog_no) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Bad Catalog %s : status = <0x%.8x>\n",
		      catalog_name, status)) ;
	  return (status) ;
	}
    }

  if (WFinfo.item_no > 0)
    {
      item_no = WFinfo.item_no ;
    }
  else
    {
      status = NFMget_item_no (NFMglobal.NFMuserid, catalog_name, 
			       item_name, item_rev,
			       &item_no) ;
      if (status != NFM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Bad Item %s %s : status = <0x%.8x>\n",
		      item_name, item_rev, status)) ;
	  return (status) ;
	}
    }


  _NFMdebug ((fname, "catalog_no %d, item_no %d\n", catalog_no, item_no));

  status = NFMset_autocommit_off (0) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : set autocommit off : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  sprintf (f_cat, "f_%s", catalog_name) ;
  status = NFMlock_table (f_cat) ;
  if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failure : set autocommit off : status = <0x%.8x>\n",
		  status)) ;
      return (status) ;
    }

  status = _NFMcheck_item_condition_roll_version (catalog_name, item_name,
						  item_rev, &max_version,
						  &oldest_version_info) ;

  if (status != NFM_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
      _NFMdebug ((fname, "Failure : Item in Bad State\n")) ;
      return (status) ; 
    }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("oldes_version_info", oldest_version_info,
                      _NFMdebug_st.NFMdebug_file);
  }


  status = MEMbuild_array (data_list) ;
  if (status != MEM_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
      _NFMdebug ((fname, "MEMbuild_array (data_list) : status = <0x%.8x>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  data = (char **) data_list ->data_ptr ;
  column = (char **) data_list -> column_ptr ;
  
  status = MEMbuild_array (oldest_version_info) ;
  if (status != MEM_S_SUCCESS)
    {
      NFMrollback_transaction (0) ;
      _NFMdebug ((fname, "MEMbuild_array (oldest_version_info) : status = <0x%.8>\n",
		  status)) ;
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      return (NFM_E_MEM) ;
    }

  oldest_version_data = (char **) oldest_version_info -> data_ptr ;
  oldest_version_column = (char **) oldest_version_info -> column_ptr ;

  a = -1 ; b = -1 ; c =-1 ; d = -1; e = -1, f= -1;
  for (i=0; i<data_list->columns; i++)
    {
      if (strcmp (column [i], "n_filenum") == 0)          a = i ;
      else if (strcmp (column [i], "n_fileversion") == 0) b = i ;
      else if (strcmp (column [i], "n_fileno") == 0)      c = i ;
      else if (strcmp (column [i], "n_cifilename") == 0)  d = i ;
      else if (strcmp (column [i], "n_cisano") == 0)      e = i ;
      else if (strcmp (column [i], "n_archiveno") == 0)   f = i ;
      else if (strcmp (column [i], "n_filetype") == 0)    g = i ;
    }

  _NFMdebug ((fname, "a %d : b %d : c %d : d %d : e %d : f %d\n",
	      a,b,c,d,e,f)) ;

  fileno_pos = -1; cifilename_pos = -1; cisano_pos = -1; filenum_pos = -1 ;
  for (i=0; i<oldest_version_info->columns; i++)
    {
      if (strcmp (oldest_version_column [i], 
		  "n_fileno") == 0) fileno_pos = i ;
      else if (strcmp (oldest_version_column [i], 
		       "n_cifilename") == 0) cifilename_pos = i ;
      else if (strcmp (oldest_version_column [i], 
		       "n_cisano") == 0) cisano_pos = i ;
      else if (strcmp (oldest_version_column [i], 
		       "n_filenum") == 0) filenum_pos = i ;
    }

  _NFMdebug ((fname, "fileno_pos %d : cifilename_pos %d : cisano_pos %d : filenum_pos %d\n",
	      fileno_pos, cifilename_pos, cisano_pos, filenum_pos)) ;

  if (NFM_FTR_INITED)
  {
    _NFMdebug ((fname, "FTR engine available, get keywords\n"));

    /* don't free NFMitem_files information yet */
    freeNFMitem_files = 0;

    status = NFMget_keywords_for_files (catalog_name, item_name,
             item_rev,  NFM_ITEM, &files, &keywords);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMget_keywords_for_files 0x%.8x\n", status));
    }
    else
    {
      _NFMdebug ((fname, "retrieved keywords [%s]\n", keywords));
      no_keywords = 1;
      status = _NFMprepare_files_buffer (catalog_name, catalog_no, item_name,
               item_rev, item_no, data_list, &file_list);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "_NFMprepare_files_buffer 0x%.8x\n", status));
      }
      if (_NFMdebug_st.NFMdebug_on)
      {
        MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
      }
      MEMbuild_array (file_list);
    }
  }

  sql_str = (char *) malloc (data_list->rows*100+200);
  if (sql_str == NULL)
    {
      NFMrollback_transaction (0) ;
      _NFMdebug ((fname, "malloc failed\n")) ;
      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
      return (NFM_E_MALLOC) ;
    }


  sprintf (sql_str, "Update f_%s set n_fileversion = %d where n_itemnum = %d and ", 
	   catalog_name, max_version+1, item_no) ;

  comma = 0 ;
  for (y=0; y<oldest_version_info->rows; y++)
    {
      _NFMdebug ((fname, "Comparing file %d\n", y+1)) ;
      offsety = y*oldest_version_info->columns ;
      for (i=0; i<data_list->rows; i++)
	{
	  offseti = i*data_list->columns ;
	  _NFMdebug ((fname, "comparing old filenum %s with forw filenum %s\n",
		      oldest_version_data [offsety+filenum_pos], 
		      data [offseti+a])) ;
	  if (strcmp (oldest_version_data [offsety+filenum_pos],
		      data [offseti+a]) == 0)
	    {
	      fw_fileno = atol (data [offseti+c]) ;
	      fw_cisano = atol (data [offseti+e]) ;
              _NFMdebug ((fname, "fw_fileno = %d, fw_cisano = %d\n",
                          fw_fileno, fw_cisano));
	      user_filename = 0 ;
              if (NFM_FTR_INITED)
              {
                status = NFT_delete_entry (catalog_no, item_no, 
                            atol(oldest_version_data[offsety+fileno_pos]));
                if (status != UTI_S_SUCCESS)
                {
                  _NFMdebug ((fname, "NFT_delete_entry: 0x%.8x\n", status));
                  ERRload_struct (UTI, UTI_S_SUCCESS, "", NULL);
                }

                if (file_list != NULL)
                {
                  status = MEMwrite_data (file_list, 
                                   oldest_version_data[offsety+fileno_pos],
                                   2 + i,
                                   FTO_ITEMDESC+1);
                }
              }
              /* if oldest version cifilename is not blank */
	      _NFMdebug ((fname,"is latest verion of cifilename <%s>  blank\n",
			  oldest_version_data [offsety+cifilename_pos]));
	      
	      if ((strcmp (oldest_version_data [offsety+cifilename_pos], "") != 0))
		{
		  user_filename = 1 ;
		  strcpy (cifilename,
			  oldest_version_data [offsety+cifilename_pos]) ;
                  _NFMdebug ((fname, "Handle user defined file name %s\n",
                              cifilename));
             
		  fileno = (long) atol 
                                  (oldest_version_data [offsety+fileno_pos]) ;
		  cisano = (long) atol 
                                  (oldest_version_data [offsety+cisano_pos]) ;

		  status = _NFMrename_ud_to_NFMencrypted (cisano, 
							  catalog_no, 
							  fileno, 
							  cifilename,
							  &rename_buffer) ;
		  if (status != NFM_S_SUCCESS)
		    {
		      MEMclose (&rename_buffer) ;
		      NFMrollback_transaction (0) ;
		      _NFMdebug ((fname, 
                        "_NFMrename_ud_to_NFMencrypted <0x%.8x>\n",
				  status)) ;
		      free (sql_str) ;
		      return (status) ;
		    }

		  status = _NFMrename_NFMencrypted_to_ud (fw_cisano, 
							  catalog_no, 
							  fw_fileno, 
							  cifilename,
							  &rename_buffer) ;
		  if (status != NFM_S_SUCCESS)
		    {
		      MEMclose (&rename_buffer) ;
		      NFMrollback_transaction (0) ;
		      _NFMdebug ((fname, 
                         "_NFMrename_NFMencrypted_to_ud <0x%.8x>\n",
				  status)) ;
		      free (sql_str) ;
		      return (status) ;
		    }
		}

              /* n_archiveno > 0 */
	      if (atol (data [offseti+f]) > 0) 
		{
		  o_fileno = fw_fileno ;
		  sprintf (tmp_str, "Select * from f_%s where n_fileno = %d",
			   catalog_name, o_fileno) ;
		  status = SQLquery (tmp_str, &sql_buffer, MEM_SIZE) ;
		  if (status != SQL_S_SUCCESS)
		    {
		      MEMclose (&rename_buffer) ;
		      MEMclose (&sql_buffer) ;
		      NFMrollback_transaction (0) ;
		      free (sql_str) ;
		      _NFMdebug ((fname, "Failure : SQL query : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", "") ;
		      return (NFM_E_SQL_QUERY) ;
		    }
		  status = MEMbuild_array (sql_buffer) ;
		  if (status != MEM_S_SUCCESS)
		    {
		      MEMclose (&rename_buffer) ;
		      MEMclose (&sql_buffer) ;
		      NFMrollback_transaction (0) ;
		      free (sql_str) ;
		      _NFMdebug ((fname, "Failure : MEMbuild_array : status = <0x%.8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
		      return (NFM_E_MEM) ;
		    }
		  datax = (char **) sql_buffer -> data_ptr ;
		  columnx = (char **) sql_buffer-> column_ptr ;
		  formatx = (char **) sql_buffer -> format_ptr ;
		  status = NFMget_attr_value (NFMglobal.NFMuserid,
					      f_cat, "MAX(n_fileno)","",
					      tmp_str) ;
		  if (status != NFM_S_SUCCESS)
		    {
		      MEMclose (&rename_buffer) ;
		      MEMclose (&sql_buffer) ;
		      NFMrollback_transaction (0) ;
		      free (sql_str) ;
		      _NFMdebug ((fname, "Failure : Get Attr value : status = <0x%.8x>\n",
				  status)) ;
		      return (status) ;
		    }
		  fw_fileno = atol (tmp_str) + 1 ;

		  str = (char *) malloc (2*sql_buffer->row_size + 512) ;
		  if (str == NULL)
		    {
		      MEMclose (&rename_buffer) ;
		      MEMclose (&sql_buffer) ;
		      NFMrollback_transaction (0) ;
		      free (sql_str) ;
		      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
		      _NFMdebug ((fname, "Failure : malloc\n")) ;
		      return (NFM_E_MALLOC) ;
		    }
		  str1 = (char *) malloc (2*sql_buffer->row_size + 512) ;
		  if (str1 == NULL)
		    {
		      MEMclose (&rename_buffer) ;
		      MEMclose (&sql_buffer) ;
		      NFMrollback_transaction (0) ;
		      free (sql_str) ;
		      free (str) ;
		      ERRload_struct (NFM, NFM_E_MALLOC, "", "") ;
		      _NFMdebug ((fname, "Failure : malloc\n")) ;
		      return (NFM_E_MALLOC) ;
		    }


		  sprintf (str, "Insert into f_%s (n_fileno, n_fileversion ",
			   catalog_name) ;

		  sprintf (str1, ") values (%d, %d ",
			   fw_fileno, max_version+1) ;

		  for (i=0; i<sql_buffer->columns; i++)
		    {
		      if ((strcmp (columnx[i], "n_fileno")) &&
			  (strcmp (columnx[i], "n_archiveno")) &&
			  (strcmp (columnx[i], "n_fileversion")))
			{
			  strcat (str, ",") ;
			  strcat (str, columnx [i]) ;
			  strcat (str1, ",") ;

			  if (! strncmp (formatx [i], "char", 4))
			    {
			      strcat (str1, "'");
			      strcat (str1, datax [i]);
			      strcat (str1, "'");
			    }
			  else if (! strcmp (formatx [i], "timestamp"))
			    {
			      status = NFMascii_to_timestamp_format (datax [i],
								     tmp_str);
			      if (status != NFM_S_SUCCESS)
				{
				  MEMclose (&rename_buffer) ;
				  MEMclose (&sql_buffer) ;
				  NFMrollback_transaction (0) ;
				  free (sql_str) ;
				  free (str) ;
				  free (str1) ;
				  _NFMdebug ((fname,"ascii to timestamp:status = <0x%.8x>\n",
					      status)) ;
				  return (status) ;
				}
			      strcat (str1, "TIMESTAMP '") ;
			      strcat (str1, tmp_str) ;
			      strcat (str1, "'") ;
			    }
			  else
			    {
			      if (strlen (datax [i])) 
				strcat (str1, datax [i]);
			      else  strcat (str1, "null");   
			    }
			}
		    }
		  strcat (str1, ")") ;
		  strcat (str, str1) ;
		  status = SQLstmt (str) ;
		  free (str) ;
		  free (str1) ;
		  if (status != SQL_S_SUCCESS) 
		    {
		      MEMclose (&rename_buffer) ;
		      MEMclose (&sql_buffer) ;
		      NFMrollback_transaction (0) ;
		      _NFMdebug ((fname, "Failure sqlstmt : status=<0x%.8x>\n",
				  status)) ;
		      free (sql_str) ;
		      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		      return (NFM_E_SQL_STMT) ;
		    }
		  sprintf (tmp_str, "Update f_%s set n_fileco = 'O' where n_fileno = %d",
			   catalog_name, o_fileno) ;
		  status = SQLstmt (tmp_str) ;
		  if (status != SQL_S_SUCCESS)
		    {
		      MEMclose (&rename_buffer) ;
		      MEMclose (&sql_buffer) ;
		      NFMrollback_transaction (0) ;
		      free (sql_str) ;
		      _NFMdebug ((fname, "Failure : Sql stmt : status = <0x%..8x>\n",
				  status)) ;
		      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		      return (NFM_E_SQL_STMT) ;
		    }

		  /* insert */
		  /* if not cifilename then move file to this fileno */
		  if (! user_filename)
		    {
		      status = _NFMrename_NFMencrypted_to_NFMencrypted
			(fw_cisano, catalog_no, o_fileno, fw_fileno, 
			 &rename_buffer) ;
		      if (status != NFM_S_SUCCESS)
			{
			  MEMclose (&rename_buffer) ;
			  MEMclose (&sql_buffer) ;
			  NFMrollback_transaction (0) ;
			  _NFMdebug ((fname, "rename NFMencrypted to encrypted failed : status = <0x%.8x>\n",
				      status)) ;
			  free (sql_str) ;
			  return (status) ;
			}
		    }
		  MEMclose (&sql_buffer) ;
		}
	      else 
		{
		  if (comma)
		    {
		      sprintf (tmp_str, "or (n_filenum = %s and n_fileversion = %s)",
			       data [i*data_list->columns+a], 
			       data [i*data_list->columns+b]) ;
		    }
		  else
		    {
		      sprintf (tmp_str, "(n_filenum = %s and n_fileversion = %s)",
			       data [i*data_list->columns+a], 
			       data [i*data_list->columns+b]) ;
		      comma = 1 ;
		    }
		  strcat (sql_str, tmp_str)  ;
		}

	      if (user_filename)
		{
		  sprintf (tmp_str, "UPDATE f_%s set n_cifilename = '%s' \
where n_fileno = %d",
			   catalog_name, cifilename, fw_fileno) ;
		  status = SQLstmt (tmp_str) ;
		  if (status != SQL_S_SUCCESS) 
		    {
		      MEMclose (&rename_buffer) ;
		      NFMrollback_transaction (0) ;
		      _NFMdebug ((fname, "Failure sqlstmt : status=<0x%.8x>\n",
				  status)) ;
		      free (sql_str) ;
		      ERRload_struct (NFM, NFM_E_SQL_STMT, "", "") ;
		      return (NFM_E_SQL_STMT) ;
		    }
		}
	      break ;
	    }
	} /* for i */
      if (i==data_list->rows)
	/* use latest version */
	{
	  _NFMdebug ((fname, "No version given for filenum %s use latest version of it (%d)\n",
		      oldest_version_data [offsety+filenum_pos], max_version));
	  if (comma)
	    {
	      sprintf (tmp_str, "or (n_filenum = %s and n_fileversion = %d)",
		       oldest_version_data [offsety+filenum_pos], 
		       max_version) ;
	    }
	  else
	    {
	      sprintf (tmp_str, "(n_filenum = %s and n_fileversion = %d)",
		       oldest_version_data [offsety+filenum_pos], 
		       max_version) ;
	      comma = 1 ;
	    }
	  strcat (sql_str, tmp_str)  ;
	}
    } /* for y */
  
  if (comma)
    {
      status = SQLstmt (sql_str) ;
      free (sql_str) ;
      if (status != SQL_S_SUCCESS)
	{
	  MEMclose (&rename_buffer) ;
	  NFMrollback_transaction (0) ; 
	  _NFMdebug ((fname, "SQL stmt : status = <0x%x.8x>\n",
		      status)) ;
	  return (NFM_E_SQL_STMT) ;
	}
    }
  else
    {
      _NFMdebug ((fname, "no update done\n")) ;
    }

  if (rename_buffer)
    {
      if (_NFMdebug_st.NFMdebug_on)
	{
	  MEMprint_buffer ("rename buffer", rename_buffer,
			   _NFMdebug_st.NFMdebug_file) ;
	}
      
      status = NFMfs_chg_files (&rename_buffer) ;
      if (status != NFM_S_SUCCESS)
	{
	  NFMrollback_transaction (0) ;
	  /* invert the buffer */
	  status = _NFMinvert_buffer (rename_buffer, &invert_buffer) ;
	  if (status == NFM_S_SUCCESS)
	    {
	      NFMfs_undo_chg_files (&invert_buffer) ;
	    }
	  MEMclose (&invert_buffer) ;
	  MEMclose (&rename_buffer) ;
	  _NFMdebug ((fname, "Rename files File : status = <0x%.8x>\n",
		      status));
	  ERRload_struct (NFM, NFM_E_RENAME_FILES_FAILED, "", "") ;
	  return(NFM_E_RENAME_FILES_FAILED) ;
	}
    }
  else
    {
      _NFMdebug ((fname, "No files to rename\n")) ;
    }

  if (NFM_FTR_INITED)
  {
    _NFMdebug ((fname, "mount, add, and index\n"));
    status = _NFMmount_add_index (file_list, NFM_ITEM_NO_KEYWORDS);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Failed to mount/add/index\n"));
      ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);
      ERRload_struct (UTI, UTI_S_SUCCESS, "", NULL);
    }
    else
    {
      _NFMdebug ((fname, "Successful mount/add/index\n"));
      ERRload_struct (UTI, UTI_S_SUCCESS, "", NULL);
    }
  }

  status = NFMstart_transaction (0) ;
  if (status != NFM_S_SUCCESS)
  {
    /* invert the buffer */
    status = _NFMinvert_buffer (rename_buffer, &invert_buffer) ;
    if (status == NFM_S_SUCCESS)
      {
	NFMfs_undo_chg_files (&invert_buffer) ;
      }
    MEMclose (&invert_buffer) ;
    MEMclose (&rename_buffer) ;
    _NFMdebug ((fname, "Failure : set autocommit on : status = <0x%.8x>\n",
		status)) ;
    return (status) ;
  }
      
  free (sql_str) ;
  MEMclose (&oldest_version_info) ;

  MEMclose (&rename_buffer) ;
  
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  ERRreset_struct ();
  return (NFM_S_SUCCESS) ;
}



long _NFMcheck_item_condition_roll_version (catalog_name,
					    item_name, item_rev,
					    max_version,
					    item_condition) 
     char *catalog_name ;
     char *item_name ;
     char *item_rev ;
     long *max_version ;
     MEMptr *item_condition ;
{
  static char *fname = "_NFMcheck_item_conditon_roll_version" ;
  MEMptr sql_buffer = NULL ;
  long status, i, offset, y ;
  char **data, **column ;
  char sql_str [1024];

  sprintf (sql_str, "select max(n_fileversion) from f_%s where n_itemnum in (select n_itemno from %s where n_itemname = '%s' and n_itemrev = '%s')",
	   catalog_name, catalog_name, item_name, item_rev) ;
  
  status = SQLquery (sql_str, &sql_buffer, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (sql_buffer) ;
  if (status != MEM_S_SUCCESS)
    {
      return (NFM_E_MEM) ;
    }

  data = (char **) sql_buffer -> data_ptr ;

  *max_version = atol (data [0]) ;
  _NFMdebug ((fname, "max_version is %d\n", *max_version)) ;

  status = MEMclose (&sql_buffer) ;

/* order by n_filenum */
  sprintf (sql_str, "select a.n_itemno,b.n_cifilename, b.n_cisano, b.n_fileno, a.n_status, a.n_pendingflag, a.n_archivestate, a.n_itemlock, b.n_fileversion, b.n_filenum from %s a, f_%s b where a.n_itemname = '%s' and a.n_itemrev = '%s' and a.n_itemno = b.n_itemnum and b.n_fileversion = %d order by n_filenum",
	   catalog_name, catalog_name, item_name, item_rev, *max_version) ;

  status = SQLquery (sql_str, item_condition, MEM_SIZE) ;
  if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ((fname, "SQLquery : status = <0x%.8x>\n", status)) ;
      return (NFM_E_SQL_QUERY) ;
    }

  status = MEMbuild_array (*item_condition) ;
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMdebug ((fname, "MEMbuild_array (*item_condition) : status = <0x%.8x>\n",
		  status)) ;
      return (NFM_E_MEM) ;
    }

  data = (char **) (*item_condition) -> data_ptr ;
  column = (char **) (*item_condition) -> column_ptr ;


  for (y=0; y<(*item_condition)->rows; y++)
    {
      offset = y*(*item_condition)->columns ;
      for (i=0; i<(*item_condition)->columns; i++)
	{
	  if (strcmp (column[i], "n_status") == 0)
	    {
	      /* item must be in */
	      if (strcmp (data [offset+i], "I") != 0)
		{
		  _NFMdebug ((fname, "Item is not checked in\n")) ;
		  ERRload_struct (NFM, NFM_E_ITEM_OUT, "%s", item_name) ;
		  return (NFM_E_ITEM_OUT) ;
		}
	    }
	  else if (strcmp (column[i], "n_pendingflag") == 0)
	    {
	      /* item must be not be flagged */
	      if (strcmp (data [offset+i], "") != 0)
		{
		  _NFMdebug ((fname, "Item is flagged\n")) ;
		  ERRload_struct (NFM, NFM_E_ITEM_FLAGGED, "%s", item_name) ;
		  return (NFM_E_ITEM_FLAGGED) ;
		}
	    }
	  else if (strcmp (column[i], "n_archivestate") == 0)
	    {
	      if (strcmp (data [offset+i], "") != 0)
		{
		  if (strcmp (data [offset+i], "A") == 0)
		    {
		      ERRload_struct (NFM, NFM_E_ITEM_ARCHIVED, "%s", item_name) ;
		      return (NFM_E_ITEM_ARCHIVED);
		    }
/*******
		  else if (strcmp (data[offset+i], "B") == 0)
		    {
		      ERRload_struct (NFM, NFM_E_ITEM_BACKED_UP, "%s", item_name) ;
		      return (NFM_E_ITEM_BACKED_UP) ;
		    }
*********/
		}
	    }
	  else if (strcmp (column[i], "n_itemlock") == 0)
	    {
	      if (strcmp (data [offset+i], "N") != 0)
		{
		  _NFMdebug ((fname, "Item is locked\n")) ;
		  ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "%s", item_name) ;
		  return (NFM_E_ITEM_LOCKED) ;
		}
	    }
	}
    }

  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}

long _NFMinvert_buffer (list1, list2)
     MEMptr list1 ;
     MEMptr *list2 ;
{
  char *fname = "_NFMinvert_buffer" ;
  long i, status ;

  _NFMdebug ((fname, "ENTER\n")) ;
  for (i=list1->rows; i>0; i--)
    {
      status = MEMcopy_row (list1, list2, i) ;
      if (status != MEM_S_SUCCESS)
	{
	  _NFMdebug ((fname, "Failure : MEMcopy_row row <%d> : status = <0x%.8x>\n",
		      i, status)) ;
/* mms - this rollback do not load structure 
	  ERRload_struct (NFM, NFM_E_MEM, "", "") ;
*/
	  return (NFM_E_MEM) ;
	}
    }

  if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("inverted buffer", *list2,
		       _NFMdebug_st.NFMdebug_file) ;
    }
  _NFMdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFM_S_SUCCESS) ;
}




