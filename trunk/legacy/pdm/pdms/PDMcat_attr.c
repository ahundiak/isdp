#include 		<stdio.h>
#include 		"MEMstruct.h"
#include 		"NFMdb.h"
#include 		"NFMerrordef.h"
#include 		"ERR.h"
#include 		"DEBUG.h"
#include 		"NFMstruct.h"
#include                "PDUerror.h"
#include                "WFstruct.h"
#include                "SQLerrordef.h"
#include                "PDUris_incl.h"
#include                "PDMproto.h"
#include                "PDUpdmrpro.h"

extern  int     PDMdebug_on;
extern  char    PDM_DEBUG_FILE[];
static int              status;
extern PDMexec_ptr PDMexec;
extern PDMpart_ptr PDMpart;
extern struct NFMglobal_st NFMglobal ;
extern struct WFstruct WFinfo ;





int PDMqry_catalog_attributes (mode, return_bufr)
char		*mode;
MEMptr          *return_bufr;
{
        char		*fn = "PDMqry_catalog_attributes";
        MEMptr          attr_bufr = NULL;
        MEMptr          data_bufr = NULL;
        MEMptr          list_bufr = NULL;
	char		sql_str[256];

  PDMdebug("ENTER PDMqry_catalog_attributes \n");
  _PDMdebug (fn, "Mode = %s\n", mode);

  /* since this function is not called for adding
     new part; we can load the part_struct */


    status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                                 PDMexec->revision);
     if (status != PDM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) { 
        _PDMdebug (fn, "PDMload_part_info failed status %d\n", status); 
        return (status);
         }

   /* fix for better error message returns ...*/

/* if the part is in review mode, we need not check for
   any of these flags as they are supposed to review the
   part whether it is flagged or not. Also, they are not
   supposed to be able to change any thing. Just look,
   don't touch anything!            MaC 052793 */
   
   if (strcmp (mode, "R")) {
        if (!strncmp(PDMpart.n_archivestate, "A", 1)
               || !strncmp(PDMpart.n_archivestate, "B", 1)) {
            _PDMdebug (fn,  "Part is archived or backedup\n");
            return(PDM_E_PART_ARCHIVED);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IA", 2))
               || (!strncmp(PDMpart.n_pendingflag, "SA", 2))) {
            _PDMdebug (fn,  "Part is flagged for achive\n");
            return (PDM_E_PART_FLAGGED_FOR_ARCHIVE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IB", 2))
               || (!strncmp(PDMpart.n_pendingflag, "SB", 2))) {
            _PDMdebug (fn,  "Part is flagged for backup\n");
            return (PDM_E_PART_FLAGGED_FOR_BACKUP);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "ID", 2))
               || (!strncmp(PDMpart.n_pendingflag, "SD", 2))) {
            _PDMdebug (fn,  "Part is flagged for delete\n");
            return (PDM_E_PART_FLAGGED_FOR_DELETE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IR", 2))
               || (!strncmp(PDMpart.n_pendingflag, "SR", 2))) {
            _PDMdebug (fn,  "Part is flagged for delete\n");
            return (PDM_E_PART_FLAGGED_FOR_RESTORE);
           }
        else if (!strncmp(PDMpart.n_archivestate, "A", 1)
               || !strncmp(PDMpart.n_archivestate, "B", 1)) {
            _PDMdebug (fn,  "Part is archived or backedup\n");
            return(PDM_E_PART_ARCHIVED);
           }
     } /* if mode is not R */

/* The part has to be locked before querying for attrs...MaC :120892  */

  sprintf (sql_str,
     "UPDATE %s SET n_itemlock = 'Y' WHERE %s = '%s' AND %s = '%s'",
      PDMexec->catalog, 
      "n_itemname", PDMexec->part_num, 
      "n_itemrev", PDMexec->revision);

  status = SQLstmt(sql_str);
  if (status != SQL_S_SUCCESS) {
    _PDMdebug ( fn, "Locking Item: SQLstmt failed: %d\n", status );
    MEMclose (&attr_bufr);
    MEMclose (&data_bufr);
    MEMclose (&list_bufr);
    return (status);
  }


  
  status = PDMi_qry_catalog_attributes (mode, &attr_bufr, 
                                         &data_bufr, &list_bufr);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug ( fn, "PDMi_qry_catalog_attributes %d\n", status );
    MEMclose (&attr_bufr);
    MEMclose (&data_bufr);
    MEMclose (&list_bufr);
/* fix for Murrray ohio to unlock the part - Kumar 08.25.93 */
  sprintf (sql_str,
     "UPDATE %s SET n_itemlock = 'N' WHERE %s = '%s' AND %s = '%s'",
      PDMexec->catalog,
      "n_itemname", PDMexec->part_num,
      "n_itemrev", PDMexec->revision);
     SQLstmt(sql_str);
    return (status);
  }


 if (PDMdebug_on) {
    MEMprint_buffer ("new attr_bufr", attr_bufr, PDM_DEBUG_FILE);
    MEMprint_buffer ("new data_bufr", data_bufr, PDM_DEBUG_FILE);
    MEMprint_buffers ("new list_bufr", list_bufr, PDM_DEBUG_FILE);
    }
   
   *return_bufr = attr_bufr;

   status = MEMappend (data_bufr, *return_bufr);
   if (status  != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMappend data_bufr status = <%d>\n", status);
        return (PDM_E_APPEND_BUFFER);
      }

   status = MEMappend (list_bufr, *return_bufr);
   if (status  != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMappend list_bufr status = <%d>\n", status);
        return (PDM_E_APPEND_BUFFER);
      }
 
   MEMclose (&data_bufr);
   MEMclose (&list_bufr);

  PDMdebug("EXIT PDMqry_catalog_attributes \n");
  return (PDM_S_SUCCESS);
}



int PDMi_qry_catalog_attributes (mode, attr_bufr, data_bufr, list_bufr)
char		*mode;
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
MEMptr          *list_bufr;
{
        char		*fn = "PDMi_qry_catalog_attributes";
        MEMptr          def_bufr = NULL;
        MEMptr          val_bufr = NULL;
        MEMptr          qry_bufr = NULL;
        MEMptr          qry_buf1 = NULL;
        MEMptr          attr_list = NULL;
	MEMptr          list1_bufr = NULL;
        char		*gift;
        char		**q_data;
        char		**q_attr;
        char		**def_data;
        char		**def_col;
        int		col, col_index;
        int		x, index;
        int		catalog_no = 0, commandno = 0;
        int		f_catalog_no = 0;
        char		sql_str[1024];
        char		*mem_str;

  PDMdebug("ENTER PDMi_qry_catalog_attributes \n");
  _PDMdebug (fn, "Mode = %s\n", mode);
  sql_str[0] = '\0';
  sprintf (sql_str, 
       "SELECT %s FROM %s WHERE (%s = '%s' AND %s) OR (%s = 'f_%s' AND %s)",
       " n_tablename, n_tableno", "NFMTABLES", 
       " n_tablename ", PDMexec->catalog, 
       " n_tabletype = 'catalog'",
       " n_tablename ", PDMexec->catalog, 
       " n_tabletype = 'f_catalog'");
  status = SQLquery (sql_str, &qry_buf1, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_buf1);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "MEMbuild_query (qry_buf1) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("qry_buf1 from query", qry_buf1, PDM_DEBUG_FILE);
 }

  q_data = (char **) qry_buf1->data_ptr;
  for (x = 0; x < qry_buf1->rows; x++) {
  index = x * qry_buf1->columns;
  if (!strcmp (PDMexec->catalog, q_data[index+0]) ) {
     catalog_no = atol (q_data[index + 1]);
     }
  else {
     f_catalog_no = atol (q_data[index + 1]);
     }
   }

  _PDMdebug (fn, "catno = %d, f_catno = %d\n", catalog_no, f_catalog_no);
  if (WFinfo.catalog_no != catalog_no) WFinfo.catalog_no = catalog_no;
  MEMclose (&qry_buf1);

   /* NFM requires the commandno in the WFinfo structure
       in NFM3.2 */

   status = PDMget_commandno ("Add Item", &commandno);
   if(status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "PDMget_command_no failed status %d\n", status);
     return(PDM_E_GET_DATA);
   }

   WFinfo.command = commandno;

/*, "ORDER BY n_tableno,n_seqno");*/

/* getting the attributes ...*/

    if (!strcmp (mode, "R")) {
     sprintf (sql_str, 
   "SELECT %s%s%s FROM %s WHERE (%s = %d OR %s = %d) AND (%s = '%s' %s ) %s",
              " n_name, n_datatype, n_synonym, ",
              " n_application, n_read, n_write, n_update, n_delete, n_null, ",
              " n_checkin, n_checkout, n_seqno, n_attrno,n_tableno",
              " NFMATTRIBUTES", 
              " n_tableno", catalog_no,
              " n_tableno", f_catalog_no,
              " n_read", "Y",
" OR n_name in ('n_itemnum','n_filenum','n_creator', 'n_creationdate', 'n_itemlock','n_status','n_cocomment','n_stateno','n_aclno','n_itemno','n_fileno', 'p_parttype', 'p_maxlevel', 'p_explode', 'n_cofilename', 'n_cifilename' ) ",
              " ORDER BY n_seqno");
      }
    else if (!strcmp (mode, "W")) {
     sprintf (sql_str, 
   "SELECT %s%s%s FROM %s WHERE (%s = %d OR %s = %d) AND (%s = '%s' %s ) %s",
              " n_name, n_datatype, n_synonym, ",
              " n_application, n_read, n_write, n_update, n_delete, n_null, ",
              " n_checkin, n_checkout, n_seqno, n_attrno,n_tableno",
              " NFMATTRIBUTES", 
              " n_tableno", catalog_no,
              " n_tableno", f_catalog_no,
              " n_write", "Y",
" OR n_name in ('n_fileversion','n_itemnum','n_filenum','n_creator', 'n_creationdate', 'n_itemlock','n_status','n_cocomment', 'n_updater','n_updatedate','n_stateno','n_aclno','n_itemno','n_fileno', 'p_parttype', 'p_maxlevel', 'p_explode', 'n_cofilename', 'n_cifilename' ) ",
              "ORDER BY n_seqno");
      }
    else if (!strcmp (mode, "U")) {
     sprintf (sql_str, 
   "SELECT %s%s%s FROM %s WHERE (%s = %d OR %s = %d) AND (%s = '%s' %s ) %s",
              " n_name, n_datatype, n_synonym, ",
              " n_application, n_read, n_write, n_update, n_delete, n_null, ",
              " n_checkin, n_checkout, n_seqno, n_attrno,n_tableno",
              " NFMATTRIBUTES", 
              " n_tableno", catalog_no,
              " n_tableno", f_catalog_no,
              " n_update", "Y",
" OR n_name in ('n_fileversion','n_itemnum','n_filenum','n_creator', 'n_creationdate', 'n_itemlock', 'n_updater','n_updatedate','n_status','n_cocomment','n_stateno','n_aclno','n_itemno','n_fileno', 'p_parttype', 'p_maxlevel', 'p_explode', 'n_cofilename', 'n_cifilename' )",
              " ORDER BY n_seqno");
      }
     else {
        _PDMdebug (fn, "Mode unknown [%s]\n", mode);
        return (PDM_E_GET_ATTRIBUTES);
       }

  _PDMdebug ("sql_str", "%s\n", sql_str);
  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("attr bufr from query", qry_bufr, PDM_DEBUG_FILE);
 }


/***********************************************************/
/* add n_valueno and n_adviceno to the list */
   status = _PDMadd_cols_to_attr_bufr (qry_bufr, &attr_list);
  if (status != PDM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "_PDMadd_cols_to_attr_bufr (qry_bufr) 0x%.8x\n", status);
    return (status);
  }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

MEMclose (&qry_bufr);

/***********************************************************/
  q_attr = (char **) attr_list->data_ptr;

/*
  if (!strcmp (mode, "W")) {
*/
  status = MEMopen(&def_bufr,1024);
   if(status != MEM_S_SUCCESS) {
      MEMclose(&attr_list);
      _PDMdebug (fn, "MEMopen failed status %d\n",status);
      return(PDM_E_OPEN_BUFFER);
   }
    
    mem_str = (char *) malloc (((attr_list) -> rows) *10);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str[0] ='\0';

   
    for (col = 0; col < attr_list->rows; col++) {
    col_index = col * attr_list->columns;
     status = MEMwrite_format (def_bufr, 
                                  q_attr[col_index + 0], 
                                     q_attr[col_index + 1]);
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n",status);
                MEMclose(&attr_list);
                MEMclose(&def_bufr);
                return(PDM_E_WRITE_FORMAT);
        }
/* build the empty string at the same time */
    strcat (mem_str, "\1");
     }
  status = MEMbuild_array (def_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&attr_list);
    MEMclose (&def_bufr);
    _PDMdebug ( fn, "MEMbuild_query (attr_list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }
   
 _PDMdebug ("mem_str", "%s\n", mem_str);
     
  status = MEMwrite(def_bufr, mem_str);
  if(status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
    MEMclose (&attr_list);
    MEMclose (&def_bufr);
    return(status);
  }
      
  /**data_bufr = def_bufr;*/
  free (mem_str);
/* add n_valueno and n_adviceno to the list */
   status = _PDMload_datalist_bufr (attr_list, &def_bufr, &list1_bufr);
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_datalist_bufr 0x%.8x\n", status);
    MEMclose (&attr_list);
    MEMclose (&def_bufr);
    MEMclose (&list1_bufr);
    return (status);
      }
/*
    }
  else if (!strcmp (mode, "U")) 
*/
 
  if ( (!strcmp (mode, "U")) || (!strcmp (mode, "R")) ) {

  /* this is only for CHANGE_PART; the values for the part
     will be loaded into the databufr. MaC 120392 */

   status = _PDMload_values_in_data_bufr (attr_list, &val_bufr);
    if  (status != PDM_S_SUCCESS)  {
    _PDMdebug ( fn, "_PDMload_values_in_data_bufr  0x%.8x\n", status);
    MEMclose (&attr_list);
    MEMclose (&val_bufr);
    MEMclose (&def_bufr);
    MEMclose (&list1_bufr);
    return (status);
    }

/* fix for loading data bufr from existing and defaults buffer */

   status = _PDMload_default_vals_in_data_bufr (val_bufr, &def_bufr);
    if  (status != PDM_S_SUCCESS)  {
    _PDMdebug ( fn, "_PDMload_default_vals_in_data_bufr  0x%.8x\n", status);
    MEMclose (&attr_list);
    MEMclose (&def_bufr);
    MEMclose (&val_bufr);
    MEMclose (&list1_bufr);
    return (status);
    }
  MEMclose (&val_bufr);

/* loads statename in n_cocomment; should not do so but....*/
    status = PDMload_state_name (def_bufr);
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_state_name  0x%.8x\n", status);
    MEMclose (&attr_list);
    MEMclose (&def_bufr);
    MEMclose (&list1_bufr);
    return (status);
    }
  }


   status = _PDMload_defaults (&attr_list, &def_bufr, &list1_bufr, mode);
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_defaults  0x%.8x\n", status);
    MEMclose (&attr_list);
    MEMclose (&def_bufr);
    MEMclose (&list1_bufr);
    return (status);
    }

/* following duplicates the data_bufr rows for NFMupdate_item */

  gift = (char *) malloc (((def_bufr -> rows) * 30) + 512);
  if (! gift) {
     _PDMdebug (fn, "Malloc gift Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
     return (NFM_E_MALLOC);
     }
  gift[0] ='\0';
  
  status = MEMbuild_array (def_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (def_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  def_data = (char **) def_bufr->data_ptr;
  def_col = (char **) def_bufr->column_ptr;

  for(col = 0; col < (def_bufr)->columns; col++) {
  strcat (gift, def_data[col]);
  strcat (gift, "\1");
  _PDMdebug ("attr", "%s->[%s]\n", def_col[col], def_data[col]);
      }
  _PDMdebug ("gift", "%s\n", gift);
     
  status = MEMwrite((def_bufr), gift);
  if(status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMwrite failed status = %d\n", status);
    free (gift);
    return(status);
  }
  
  free (gift);


   if (PDMdebug_on) {
    MEMprint_buffer ("in qry_fn data_bufr", def_bufr, PDM_DEBUG_FILE);
    MEMprint_buffer ("in qry_fn attr_bufr", attr_list, PDM_DEBUG_FILE);
    MEMprint_buffers ("in qry_fn list_bufr", list1_bufr, PDM_DEBUG_FILE);
 }

  *attr_bufr = attr_list;
  *data_bufr = def_bufr;
  *list_bufr = list1_bufr;


_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}



int PDMquery_catalog_writable_attributes (attr_bufr, data_bufr, list_bufr)
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
MEMptr          *list_bufr;
{
        char		*fn = "PDMquery_catalog_writable_attributes";
        MEMptr          tmp_bufr = NULL;
        MEMptr          qry_bufr = NULL;
        MEMptr          qry_buf1 = NULL;
        MEMptr          attr_list = NULL;
        char		**q_data;
        char		**q_attr;
        int		col, col_index;
        int		x, index;
        int		catalog_no = 0, commandno = 0;
        int		f_catalog_no = 0;
        char		sql_str[1024];
        char		*mem_str;

  PDMdebug("ENTER PDMquery_catalog_writable_attributes \n");
  sql_str[0] = '\0';
  sprintf (sql_str, 
       "SELECT %s FROM %s WHERE (%s = '%s' AND %s) OR (%s = 'f_%s' AND %s)",
       " n_tablename, n_tableno", "NFMTABLES", 
       " n_tablename ", PDMexec->catalog, 
       " n_tabletype = 'catalog'",
       " n_tablename ", PDMexec->catalog, 
       " n_tabletype = 'f_catalog'");
  status = SQLquery (sql_str, &qry_buf1, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_buf1);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "MEMbuild_query (qry_buf1) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("qry_buf1 from query", qry_buf1, PDM_DEBUG_FILE);
 }

  q_data = (char **) qry_buf1->data_ptr;
  for (x = 0; x < qry_buf1->rows; x++) {
  index = x * qry_buf1->columns;
  if (!strcmp (PDMexec->catalog, q_data[index+0]) ) {
     catalog_no = atol (q_data[index + 1]);
     }
  else {
     f_catalog_no = atol (q_data[index + 1]);
     }
   }

  _PDMdebug (fn, "catno = %d, f_catno = %d\n", catalog_no, f_catalog_no);
  if (WFinfo.catalog_no != catalog_no) WFinfo.catalog_no = catalog_no;
  MEMclose (&qry_buf1);

   /* NFM requires the commandno in the WFinfo structure
       in NFM3.2 */
   status = PDMget_commandno ("Add Item", &commandno);
   if(status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "PDMget_command_no failed status %d\n", status);
     return(PDM_E_GET_DATA);
   }

   WFinfo.command = commandno;

/*, "ORDER BY n_tableno,n_seqno");*/

/*
   sprintf (sql_str, "%s %s %s %s %s %s %s ",
"SELECT n_attrno, n_name, n_tableno, n_synonym, n_datatype, n_seqno, n_read, "
"n_write, n_update, n_delete, n_null, n_checkin, n_checkout, "
"n_application, n_lattrno, n_jointable, n_joinattrno "
"FROM nfmattributes, nfmtables "
"WHERE nfmtables.n_tablename = "
"AND nfmtables.n_tabletype = 't_appltable' "
"AND nfmattributes.tableno = nfmtables.tableno ");
*/
     sprintf (sql_str, 
        "SELECT %s%s%s FROM %s WHERE (%s = %d OR %s = %d) AND %s = '%s' %s",
              "n_name, n_datatype, n_synonym, ",
              "n_application, n_read, n_write, n_update, n_delete, n_null, ",
              "n_checkin, n_checkout, n_seqno, n_attrno,n_tableno",
              "NFMATTRIBUTES", 
              "n_tableno", catalog_no,
              "n_tableno", f_catalog_no,
              "n_write", "Y",
              "ORDER BY n_seqno");

  _PDMdebug ("sql_str", "%s\n", sql_str);
  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("attr bufr from query", qry_bufr, PDM_DEBUG_FILE);
 }


/***********************************************************/
/* add n_valueno and n_adviceno to the list */
   status = _PDMadd_cols_to_attr_bufr (qry_bufr, &attr_list);
  if (status != PDM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "_PDMadd_cols_to_attr_bufr (qry_bufr) 0x%.8x\n", status);
    return (status);
  }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

MEMclose (&qry_bufr);

/***********************************************************/
  q_attr = (char **) attr_list->data_ptr;

  status = MEMopen(&tmp_bufr,1024);
   if(status != MEM_S_SUCCESS) {
      MEMclose(&attr_list);
      _PDMdebug (fn, "MEMopen failed status %d\n",status);
      return(PDM_E_OPEN_BUFFER);
   }
    
    mem_str = (char *) malloc (((attr_list) -> rows) *10);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str[0] ='\0';

   
    for (col = 0; col < attr_list->rows; col++) {
    col_index = col * attr_list->columns;
     status = MEMwrite_format (tmp_bufr, 
                                  q_attr[col_index + 0], 
                                     q_attr[col_index + 1]);
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n",status);
                MEMclose(&attr_list);
                MEMclose(&tmp_bufr);
                return(PDM_E_WRITE_FORMAT);
        }
/* build the empty string at the same time */
    strcat (mem_str, "\1");
     }
  status = MEMbuild_array (tmp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&attr_list);
    MEMclose (&tmp_bufr);
    _PDMdebug ( fn, "MEMbuild_query (attr_list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }
   
 _PDMdebug ("mem_str", "%s\n", mem_str);
     
  status = MEMwrite(tmp_bufr, mem_str);
  if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           return(status);
  }
      
  *data_bufr = tmp_bufr;
  free (mem_str);
/* add n_valueno and n_adviceno to the list */
   status = _PDMload_datalist_bufr (attr_list, data_bufr, list_bufr);
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_datalist_bufr 0x%.8x\n", status);
    return (status);
  }

   status = _PDMload_defaults (&attr_list, data_bufr, list_bufr, "W");
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_defaults  0x%.8x\n", status);
    return (status);
  }
  *attr_bufr = attr_list;

 if (PDMdebug_on) {
    MEMprint_buffer ("new data_bufr", *data_bufr, PDM_DEBUG_FILE);
    MEMprint_buffer ("new attr_bufr", *attr_bufr, PDM_DEBUG_FILE);
    MEMprint_buffers ("new list_bufr", *list_bufr, PDM_DEBUG_FILE);
 }


_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}



int PDMquery_catalog_readable_attributes (attr_bufr, data_bufr, list_bufr)
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
MEMptr          *list_bufr;
{
        char		*fn = "PDMquery_catalog_readable_attributes";
        MEMptr          tmp_bufr = NULL;
        MEMptr          qry_bufr = NULL;
        MEMptr          qry_buf1 = NULL;
        MEMptr          attr_list = NULL;
        char		**q_data;
        char		**q_attr;
        int		col, col_index;
        int		x, index;
        int		catalog_no = 0, commandno = 0;
        int		f_catalog_no = 0;
        char		sql_str[1024];
        char		*mem_str;

  PDMdebug("ENTER PDMquery_catalog_readable_attributes \n");
  sql_str[0] = '\0';
  sprintf (sql_str, 
       "SELECT %s FROM %s WHERE %s = '%s' AND %s AND %s = 'f_%s' AND %s",
       " n_tableno", "NFMTABLES", 
       " n_tablename ", PDMexec->catalog, 
       " n_tabletype = 'catalog'",
       " n_tablename ", PDMexec->catalog, 
       " n_tabletype = 'f_catalog'");
  status = SQLquery (sql_str, &qry_buf1, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_buf1);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "MEMbuild_query (qry_buf1) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("qry_buf1 from query", qry_buf1, PDM_DEBUG_FILE);
 }

  q_data = (char **) qry_buf1->data_ptr;

  for (x = 0; x < qry_buf1->rows; x++) {
  index = x * qry_buf1->columns;
  if (!strcmp (PDMexec->catalog, q_data[index+0]) ) {
     catalog_no = atol (q_data[index + 1]);
     }
  else {
     f_catalog_no = atol (q_data[index + 1]);
     }
   }

  _PDMdebug (fn, "catno = %d, f_catno = %d\n", catalog_no, f_catalog_no);

  if (WFinfo.catalog_no != catalog_no) WFinfo.catalog_no = catalog_no;
  MEMclose (&qry_buf1);
  _PDMdebug (fn, "catalog_no = %d\n", catalog_no);

   /* NFM requires the commandno in the WFinfo structure
       in NFM3.2 */
   status = PDMget_commandno ("Add Item", &commandno);
   if(status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "PDMget_command_no failed status %d\n", status);
     return(PDM_E_GET_DATA);
   }

   WFinfo.command = commandno;

/*, "ORDER BY n_tableno,n_seqno");*/

/*
   sprintf (sql_str, "%s %s %s %s %s %s %s ",
"SELECT n_attrno, n_name, n_tableno, n_synonym, n_datatype, n_seqno, n_read, "
"n_write, n_update, n_delete, n_null, n_checkin, n_checkout, "
"n_application, n_lattrno, n_jointable, n_joinattrno "
"FROM nfmattributes, nfmtables "
"WHERE nfmtables.n_tablename = "
"AND nfmtables.n_tabletype = 't_appltable' "
"AND nfmattributes.tableno = nfmtables.tableno ");
*/
     sprintf (sql_str, 
        "SELECT %s%s%s FROM %s WHERE (%s = %d OR %s = %d) AND %s = '%s' %s",
              "n_name, n_datatype, n_synonym, ",
              "n_application, n_read, n_write, n_update, n_delete, n_null, ",
              "n_checkin, n_checkout, n_seqno, n_attrno,n_tableno",
              "NFMATTRIBUTES", 
              "n_tableno", catalog_no,
              "n_tableno", f_catalog_no,
              "n_write", "Y",
              "ORDER BY n_seqno");

  _PDMdebug ("sql_str", "%s\n", sql_str);
  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("attr bufr from query", qry_bufr, PDM_DEBUG_FILE);
 }


/***********************************************************/
/* add n_valueno and n_adviceno to the list */
   status = _PDMadd_cols_to_attr_bufr (qry_bufr, &attr_list);
  if (status != PDM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "_PDMadd_cols_to_attr_bufr (qry_bufr) 0x%.8x\n", status);
    return (status);
  }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

MEMclose (&qry_bufr);

/***********************************************************/
  q_attr = (char **) attr_list->data_ptr;

  status = MEMopen(&tmp_bufr,1024);
   if(status != MEM_S_SUCCESS) {
      MEMclose(&attr_list);
      _PDMdebug (fn, "MEMopen failed status %d\n",status);
      return(PDM_E_OPEN_BUFFER);
   }
    
    mem_str = (char *) malloc (((attr_list) -> rows) *10);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str[0] ='\0';

   
    for (col = 0; col < attr_list->rows; col++) {
    col_index = col * attr_list->columns;
     status = MEMwrite_format (tmp_bufr, 
                                  q_attr[col_index + 0], 
                                     q_attr[col_index + 1]);
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n",status);
                MEMclose(&attr_list);
                MEMclose(&tmp_bufr);
                return(PDM_E_WRITE_FORMAT);
        }
/* build the empty string at the same time */
    strcat (mem_str, "\1");
     }
  status = MEMbuild_array (tmp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&attr_list);
    MEMclose (&tmp_bufr);
    _PDMdebug ( fn, "MEMbuild_query (attr_list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }
   
 _PDMdebug ("mem_str", "%s\n", mem_str);
     
  status = MEMwrite(tmp_bufr, mem_str);
  if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           return(status);
  }
      
  *data_bufr = tmp_bufr;
  free (mem_str);
/* add n_valueno and n_adviceno to the list */
   status = _PDMload_datalist_bufr (attr_list, data_bufr, list_bufr);
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_datalist_bufr 0x%.8x\n", status);
    return (status);
  }

   status = _PDMload_defaults (&attr_list, data_bufr, list_bufr, "R");
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_defaults  0x%.8x\n", status);
    return (status);
  }
  *attr_bufr = attr_list;

 if (PDMdebug_on) {
    MEMprint_buffer ("new data_bufr", *data_bufr, PDM_DEBUG_FILE);
    MEMprint_buffer ("new attr_bufr", *attr_bufr, PDM_DEBUG_FILE);
    MEMprint_buffers ("new list_bufr", *list_bufr, PDM_DEBUG_FILE);
 }


_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}


int PDMquery_catalog_updatable_attributes (attr_bufr, data_bufr, list_bufr)
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
MEMptr          *list_bufr;
{
        char		*fn = "PDMquery_catalog_updatable_attributes";
        MEMptr          tmp_bufr = NULL;
        MEMptr          qry_bufr = NULL;
        MEMptr          qry_buf1 = NULL;
        MEMptr          attr_list = NULL;
        char		**q_data;
        char		**q_attr;
        int		col, col_index;
        int		x, index;
        int		catalog_no = 0, commandno = 0;
        int		f_catalog_no = 0;
        char		sql_str[1024];
        char		*mem_str;

  PDMdebug("ENTER PDMquery_catalog_updatable_attributes \n");
  sql_str[0] = '\0';
  sprintf (sql_str, 
       "SELECT %s FROM %s WHERE %s = '%s' AND %s AND %s = 'f_%s' AND %s",
       " n_tableno", "NFMTABLES", 
       " n_tablename ", PDMexec->catalog, 
       " n_tabletype = 'catalog'",
       " n_tablename ", PDMexec->catalog, 
       " n_tabletype = 'f_catalog'");
  status = SQLquery (sql_str, &qry_buf1, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_buf1);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_buf1);
    _PDMdebug ( fn, "MEMbuild_query (qry_buf1) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("qry_buf1 from query", qry_buf1, PDM_DEBUG_FILE);
 }

  q_data = (char **) qry_buf1->data_ptr;

  for (x = 0; x < qry_buf1->rows; x++) {
  index = x * qry_buf1->columns;
  if (!strcmp (PDMexec->catalog, q_data[index+0]) ) {
     catalog_no = atol (q_data[index + 1]);
     }
  else {
     f_catalog_no = atol (q_data[index + 1]);
     }
   }

  _PDMdebug (fn, "catno = %d, f_catno = %d\n", catalog_no, f_catalog_no);

  if (WFinfo.catalog_no != catalog_no) WFinfo.catalog_no = catalog_no;
  MEMclose (&qry_buf1);
  _PDMdebug (fn, "catalog_no = %d\n", catalog_no);

   /* NFM requires the commandno in the WFinfo structure
       in NFM3.2 */
   status = PDMget_commandno ("Add Item", &commandno);
   if(status != PDM_S_SUCCESS) {
     _PDMdebug (fn, "PDMget_command_no failed status %d\n", status);
     return(PDM_E_GET_DATA);
   }

   WFinfo.command = commandno;

/*, "ORDER BY n_tableno,n_seqno");*/

/*
   sprintf (sql_str, "%s %s %s %s %s %s %s ",
"SELECT n_attrno, n_name, n_tableno, n_synonym, n_datatype, n_seqno, n_read, "
"n_write, n_update, n_delete, n_null, n_checkin, n_checkout, "
"n_application, n_lattrno, n_jointable, n_joinattrno "
"FROM nfmattributes, nfmtables "
"WHERE nfmtables.n_tablename = "
"AND nfmtables.n_tabletype = 't_appltable' "
"AND nfmattributes.tableno = nfmtables.tableno ");
*/
     sprintf (sql_str, 
        "SELECT %s%s%s FROM %s WHERE (%s = %d OR %s = %d) AND %s = '%s' %s",
              "n_name, n_datatype, n_synonym, ",
              "n_application, n_read, n_write, n_update, n_delete, n_null, ",
              "n_checkin, n_checkout, n_seqno, n_attrno,n_tableno",
              "NFMATTRIBUTES", 
              "n_tableno", catalog_no,
              "n_tableno", f_catalog_no,
              "n_write", "Y",
              "ORDER BY n_seqno");


  _PDMdebug ("sql_str", "%s\n", sql_str);
  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("attr bufr from query", qry_bufr, PDM_DEBUG_FILE);
 }


/***********************************************************/
/* add n_valueno and n_adviceno to the list */
   status = _PDMadd_cols_to_attr_bufr (qry_bufr, &attr_list);
  if (status != PDM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "_PDMadd_cols_to_attr_bufr (qry_bufr) 0x%.8x\n", status);
    return (status);
  }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

MEMclose (&qry_bufr);

/***********************************************************/
  q_attr = (char **) attr_list->data_ptr;

  status = MEMopen(&tmp_bufr,1024);
   if(status != MEM_S_SUCCESS) {
      MEMclose(&attr_list);
      _PDMdebug (fn, "MEMopen failed status %d\n",status);
      return(PDM_E_OPEN_BUFFER);
   }
    
    mem_str = (char *) malloc (((attr_list) -> rows) *10);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str[0] ='\0';

   
    for (col = 0; col < attr_list->rows; col++) {
    col_index = col * attr_list->columns;
     status = MEMwrite_format (tmp_bufr, 
                                  q_attr[col_index + 0], 
                                     q_attr[col_index + 1]);
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n",status);
                MEMclose(&attr_list);
                MEMclose(&tmp_bufr);
                return(PDM_E_WRITE_FORMAT);
        }
/* build the empty string at the same time */
    strcat (mem_str, "\1");
     }
  status = MEMbuild_array (tmp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&attr_list);
    MEMclose (&tmp_bufr);
    _PDMdebug ( fn, "MEMbuild_query (attr_list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }
   
 _PDMdebug ("mem_str", "%s\n", mem_str);
     
  status = MEMwrite(tmp_bufr, mem_str);
  if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           return(status);
  }
      
  *data_bufr = tmp_bufr;
  free (mem_str);
/* add n_valueno and n_adviceno to the list */
   status = _PDMload_datalist_bufr (attr_list, data_bufr, list_bufr);
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_datalist_bufr 0x%.8x\n", status);
    return (status);
  }

   status = _PDMload_defaults (&attr_list, data_bufr, list_bufr, "U");
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_defaults  0x%.8x\n", status);
    return (status);
  }
  *attr_bufr = attr_list;

 if (PDMdebug_on) {
    MEMprint_buffer ("new data_bufr", *data_bufr, PDM_DEBUG_FILE);
    MEMprint_buffer ("new attr_bufr", *attr_bufr, PDM_DEBUG_FILE);
    MEMprint_buffers ("new list_bufr", *list_bufr, PDM_DEBUG_FILE);
 }


_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}

/* This function gets the existing values for the part
   during CHANGE_PART. */

int _PDMload_values_in_data_bufr (attr_bufr, data_bufr)
MEMptr		attr_bufr;
MEMptr		*data_bufr;
{
	char		*fn = "_PDMload_values_in_data_bufr";
        MEMptr		tmp_bufr = NULL;
        char		*gift, *sql_str;
        char		**column;
        char		**data;
	int		col, col_index;
	int		max_fileversion;

   _PDMdebug ("ENTER", "%s\n", fn);

  sql_str = (char *) malloc (((attr_bufr -> rows) * 30) + 512);
  if (! sql_str) {
     _PDMdebug (fn, "Malloc gift Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
     return (NFM_E_MALLOC);
     }
  sql_str[0] ='\0';


  gift = (char *) malloc (((attr_bufr -> rows) * 30) + 512);
  if (! gift) {
     _PDMdebug (fn, "Malloc gift Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
     return (NFM_E_MALLOC);
     }
  gift[0] ='\0';


    status = MEMbuild_array (attr_bufr);
    if (status != MEM_S_SUCCESS) {
      free (sql_str);
      free (gift);
      _PDMdebug ( fn, "MEMbuild_array (attr_bufr) 0x%.8x\n", NFM_E_MEM );
      return (NFM_E_MEM);
      }
  
    column = (char **) attr_bufr->data_ptr;
   
    strcat (gift, column[0]);
    for (col = 1; col < attr_bufr->rows; col++) {
     col_index = col * attr_bufr->columns;
     strcat (gift, ", ");
     strcat (gift, column[col_index]);
     }
    _PDMdebug ("list of attrs", "%s\n", gift);

/**********************************************************
    Added fix so that it gets max fileversion of the part..
      ***************************************************************/
    
   sprintf (sql_str, 
     " %s %s, f_%s WHERE %s = '%s' AND %s = '%s' AND f_%s.%s = %s.%s ",
     "SELECT MAX (n_fileversion) FROM ", 
      PDMexec->catalog, PDMexec->catalog,
     "n_itemname", PDMexec->part_num,
     "n_itemrev", PDMexec->revision,
      PDMexec->catalog, "n_itemnum",
      PDMexec->catalog, "n_itemno");

    _PDMdebug ("sql_str", "%s\n", sql_str);

  status = SQLquery (sql_str, &tmp_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&tmp_bufr);
    free (sql_str);
    free (gift);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }

  status = MEMbuild_array (tmp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&tmp_bufr);
    free (sql_str);
    free (gift);
    _PDMdebug ( fn, "MEMbuild_query (qry_buf1) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


  data = (char **) tmp_bufr->data_ptr;
  max_fileversion = atol (data [0]);
  _PDMdebug (fn, "Max File Version [%d]\n", max_fileversion);

  MEMclose (&tmp_bufr);
/********************************************************************/
     sprintf (sql_str, 
 "SELECT %s FROM %s, f_%s %s = '%s' %s = '%s' %s = %d AND f_%s.%s = %s.%s ",
     gift, PDMexec->catalog, PDMexec->catalog,
     " WHERE n_itemname", PDMexec->part_num,
     " AND n_itemrev", PDMexec->revision,
     " AND n_fileversion", max_fileversion,
      PDMexec->catalog, "n_itemnum",
      PDMexec->catalog, "n_itemno");

    _PDMdebug ("sql_str", "%s\n", sql_str);

  status = PDMSQLquery (sql_str, &tmp_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&tmp_bufr);
    free (sql_str);
    free (gift);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }


  status = MEMbuild_array (tmp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&tmp_bufr);
    free (sql_str);
    free (gift);
    _PDMdebug ( fn, "MEMbuild_query (qry_buf1) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


  data = (char **) tmp_bufr->data_ptr;
  column = (char **) tmp_bufr->column_ptr;
  gift[0] = '\0';
  for(col = 0; col < tmp_bufr->columns; col++) {
  strcat (gift, data[col]);
  strcat (gift, "\1");
  _PDMdebug ("attr", "%s->[%s]\n", column[col], data[col]);
      }
  _PDMdebug ("gift", "%s\n", gift);
     
  status = MEMwrite(tmp_bufr, gift);
  if(status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
    free (gift);
    MEMclose (&tmp_bufr);
    return(status);
  }
      
  *data_bufr = tmp_bufr;
    free (sql_str);
    free (gift);

 if (PDMdebug_on) {
    MEMprint_buffer("data_bufr from load_values query", *data_bufr,  
                                                         PDM_DEBUG_FILE);
     }

_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}



int PDMOLDqry_catalog_attributes (mode, return_bufr)
char		*mode;
MEMptr          *return_bufr;
{
        char		*fn = "PDMqry_catalog_attributes";
        MEMptr          attr_bufr = NULL;
        MEMptr          data_bufr = NULL;
        MEMptr          list_bufr = NULL;
	char		**data, **col;
        int		i_stateno, i_status, i;
	int		comma = -1;
        char		*spirit;
	char		stat_val[5];

  PDMdebug("ENTER PDMqry_catalog_attributes \n");
  _PDMdebug (fn, "Mode = %s\n", mode);

  /* since this function is not called for adding
     new part; we can load the part_struct */


    status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                                 PDMexec->revision);
     if (status != PDM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) { 
        _PDMdebug (fn, "PDMload_part_info failed status %d\n", status); 
        return (status);
         }

   /* fix for better error message returns ...*/

        if ((!strncmp(PDMpart.n_pendingflag, "IA", 2))
               || (!strncmp(PDMpart.n_pendingflag, "SA", 2))) {
            _PDMdebug (fn,  "Part is flagged for achive\n");
            return (PDM_E_PART_FLAGGED_FOR_ARCHIVE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IB", 2))
               || (!strncmp(PDMpart.n_pendingflag, "SB", 2))) {
            _PDMdebug (fn,  "Part is flagged for backup\n");
            return (PDM_E_PART_FLAGGED_FOR_BACKUP);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "ID", 2))
               || (!strncmp(PDMpart.n_pendingflag, "SD", 2))) {
            _PDMdebug (fn,  "Part is flagged for delete\n");
            return (PDM_E_PART_FLAGGED_FOR_DELETE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IR", 2))
               || (!strncmp(PDMpart.n_pendingflag, "SR", 2))) {
            _PDMdebug (fn,  "Part is flagged for delete\n");
            return (PDM_E_PART_FLAGGED_FOR_RESTORE);
           }
        else if (!strncmp(PDMpart.n_archivestate, "A", 1)
               || !strncmp(PDMpart.n_archivestate, "B", 1)) {
            _PDMdebug (fn,  "Part is archived or backedup\n");
            return(PDM_E_PART_ARCHIVED);
           }

  status = PDMi_qry_catalog_attributes (mode, &attr_bufr, 
                                         &data_bufr, &list_bufr);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug ( fn, "PDMi_qry_catalog_attributes %d\n", status );
    MEMclose (&attr_bufr);
    MEMclose (&data_bufr);
    MEMclose (&list_bufr);
    return (status);
  }


 if (PDMdebug_on) {
    MEMprint_buffer ("new attr_bufr", attr_bufr, PDM_DEBUG_FILE);
    MEMprint_buffer ("new data_bufr", data_bufr, PDM_DEBUG_FILE);
    MEMprint_buffers ("new list_bufr", list_bufr, PDM_DEBUG_FILE);
    }
   
 if (PDMpart.n_stateno > 0) {
   status = MEMbuild_array (data_bufr);
   if (status  != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMbuild_array status = <%d>\n", status);
    MEMclose (&attr_bufr);
    MEMclose (&data_bufr);
    MEMclose (&list_bufr);
        return (status);
      }

  spirit = (char *) malloc ((attr_bufr -> rows) * 30);
  if (! spirit) {
     _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
     return (NFM_E_MALLOC);
     }
  spirit[0] ='\0';

  i_status = -1;
  i_stateno = -1;
    
  data = (char **) data_bufr->data_ptr;
  col = (char **) data_bufr->column_ptr;
  comma = -1;
  for(i = 0; i < data_bufr->columns; i++) {
         if(!strcmp (col[i], "n_status"))  {
         i_status = i;
         status = MEMwrite_data (data_bufr, PDMpart.n_status, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

         else if(!strcmp (col[i], "n_stateno")) {
         i_stateno = i;
         sprintf (stat_val, "%d", PDMpart.n_stateno);
         status = MEMwrite_data (data_bufr, stat_val, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }
/*
         else if(!strcmp (col[i], "p_filedesc")) {
         status = MEMwrite_data (data_bufr, PDMpart.p_filedesc, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }
*/
         else if(!strcmp (col[i], "n_cifilename")) {
         status = MEMwrite_data (data_bufr, PDMpart.n_cifilename, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

         else if(!strcmp (col[i], "n_cisano")) {
         sprintf (stat_val, "%d", PDMpart.n_cisano);
         status = MEMwrite_data (data_bufr, stat_val, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

/*
         else if(!strcmp (col[i], "n_filetype")) {
         status = MEMwrite_data (data_bufr, PDMpart.n_filetype, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }
*/

         else if(!strcmp (col[i], "n_fileversion")) {
         sprintf (stat_val, "%d", PDMpart.n_fileversion);
         status = MEMwrite_data (data_bufr, stat_val, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

         else if(!strcmp (col[i], "n_cofilename")) {
         status = MEMwrite_data (data_bufr, PDMpart.n_cofilename, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

         else if(!strcmp (col[i], "n_itemno")) {
         sprintf (stat_val, "%d", PDMpart.n_itemno);
         status = MEMwrite_data (data_bufr, stat_val, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

         else if(!strcmp (col[i], "n_itemnum")) {
         sprintf (stat_val, "%d", PDMpart.n_itemno);
         status = MEMwrite_data (data_bufr, stat_val, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

/*
         else if(!strcmp (col[i], "n_filenum")) {
         sprintf (stat_val, "%d", PDMpart.n_filenum);
         status = MEMwrite_data (data_bufr, stat_val, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

         else if(!strcmp (col[i], "aclno")) {
         sprintf (stat_val, "%d", PDMpart.n_aclno);
         status = MEMwrite_data (data_bufr, stat_val, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

         else if(!strcmp (col[i], "aclno")) {
         sprintf (stat_val, "%d", PDMpart.n_aclno);
         status = MEMwrite_data (data_bufr, stat_val, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }
*/


         else if(!strcmp (col[i], "p_parttype")) {
         status = MEMwrite_data (data_bufr, PDMpart.p_parttype, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }

         else if(!strcmp (col[i], "n_fileno")) {
         sprintf (stat_val, "%d", PDMpart.n_fileno);
         status = MEMwrite_data (data_bufr, stat_val, 1, i + 1);
         if (status  != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
               MEMclose (&attr_bufr);
               MEMclose (&data_bufr);
               MEMclose (&list_bufr);
               return (status);
               }
            }
   strcat (spirit, data[i]);
   strcat (spirit, "\1");
  _PDMdebug ("attr", "%s->[%s]\n", col[i], data[i]);

   } /* end of for loop*/

  _PDMdebug ("spirit", "%s\n", spirit);
  spirit[0] = '\0';
  for(i = 0; i < data_bufr->columns; i++) {
  strcat (spirit, data[i]);
  strcat (spirit, "\1");
  _PDMdebug ("attr", "%s->[%s]\n", col[i], data[i]);
      }
  _PDMdebug ("spirit", "%s\n", spirit);
     
  status = MEMwrite(data_bufr, spirit);
  if(status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
    free (spirit);
    MEMclose (&attr_bufr);
    MEMclose (&data_bufr);
    MEMclose (&list_bufr);
    return(status);
  }
      
    free (spirit);
   
/*
   if( i_status == -1 || i_stateno == -1) {
        _PDMdebug(fn,"\t %s \n \t %s \n",
                "The data buffer does not ",
                "contain the expected attributes");
        status = PDM_E_BUFFER_FORMAT;
        MEMclose (&attr_bufr);
        MEMclose (&data_bufr);
        MEMclose (&list_bufr);
        return(status);
   }

   status = MEMwrite_data (data_bufr, PDMpart.n_status, 1, i_status + 1);
   if (status  != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
         MEMclose (&attr_bufr);
         MEMclose (&data_bufr);
         MEMclose (&list_bufr);
         return (status);
      }

   status = MEMwrite_data (data_bufr, stat_val, 1, i_stateno + 1);
   if (status  != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
         MEMclose (&attr_bufr);
         MEMclose (&data_bufr);
         MEMclose (&list_bufr);
         return (status);
      }
*/
     }

    status = PDMload_state_name (data_bufr);
    if ( (status != PDM_S_SUCCESS) && (status != NFM_S_SUCCESS) ) {
    _PDMdebug ( fn, "_PDMload_state_name  0x%.8x\n", status);
    MEMclose (&attr_bufr);
    MEMclose (&data_bufr);
    MEMclose (&list_bufr);
    return (status);
    }
 if (PDMdebug_on) {
    MEMprint_buffer ("new data_bufr", data_bufr, PDM_DEBUG_FILE);
           }

/*
   status = MEMappend (attr_bufr, *return_bufr);
   if (status  != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMappend attr_bufr status = <%d>\n", status);
        return (PDM_E_APPEND_BUFFER);
      }
   MEMclose (&attr_bufr);
*/
   
   *return_bufr = attr_bufr;

   status = MEMappend (data_bufr, *return_bufr);
   if (status  != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMappend data_bufr status = <%d>\n", status);
        return (PDM_E_APPEND_BUFFER);
      }

   status = MEMappend (list_bufr, *return_bufr);
   if (status  != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMappend list_bufr status = <%d>\n", status);
        return (PDM_E_APPEND_BUFFER);
      }
 
   MEMclose (&data_bufr);
   MEMclose (&list_bufr);

  PDMdebug("EXIT PDMqry_catalog_attributes \n");
  return (PDM_S_SUCCESS);
}


/* this function checks to see if val bufr has any values for the
   attribute, if so, loads it into the def_bufr. */

int _PDMload_default_vals_in_data_bufr (val_bufr, def_bufr)
MEMptr		val_bufr, *def_bufr;
{
	char		*fn = "_PDMload_default_vals_in_data_bufr";
        char		**def_data;
        char		**val_col;
        char		**val_data;
        char		**def_col;
	int		column_no;
 

_PDMdebug ("ENTER", "%s\n", fn);

  status = MEMbuild_array (val_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (val_bufr) 0x%.8x\n", status );
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (*def_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (*def_bufr) 0x%.8x\n", status );
    return (NFM_E_MEM);
  }


  def_data = (char **) (*def_bufr)->data_ptr;
  val_data = (char **) val_bufr->data_ptr;
  def_col = (char **) (*def_bufr)->column_ptr;
  val_col = (char **) val_bufr->column_ptr;

  for (column_no = 0; column_no < val_bufr->columns; ++column_no)  {
   _PDMdebug ("val_col", "%s<=>def_col:%s\n", 
                              val_col[column_no], def_col[column_no]);
   if ( (strlen (val_data[column_no]) > 0) ||
                    strcmp (val_data[column_no], "") ) {
     _PDMdebug (fn, "column_val[%s]\n", val_data[column_no]);
     status = MEMwrite_data (*def_bufr, val_data[column_no], 1, column_no + 1);
     if (status  != MEM_S_SUCCESS) {
            _PDMdebug (fn, "MEMwrite_data status = <%d>\n", status);
            return (status);
            }
          }
      else {
          _PDMdebug (fn, "default val [%s]\n", def_data[column_no]);
         }
        }
        
    if (PDMdebug_on) {
       MEMprint_buffer ("existing_val_bufr ", val_bufr, PDM_DEBUG_FILE);
       MEMprint_buffer ("defaults_data_bufr ", *def_bufr, PDM_DEBUG_FILE);
            }

/*
  gift = (char *) malloc (((val_bufr -> rows) * 30) + 512);
  if (! gift) {
     _PDMdebug (fn, "Malloc gift Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
     return (NFM_E_MALLOC);
     }
  gift[0] ='\0';

  for(column_no = 0; column_no < (*def_bufr)->columns; column_no++) {
  strcat (gift, def_data[column_no]);
  strcat (gift, "\1");
  _PDMdebug ("attr", "%s->[%s]\n", def_col[column_no], def_data[column_no]);
      }
  _PDMdebug ("gift", "%s\n", gift);
     
  status = MEMwrite((*def_bufr), gift);
  if(status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMwrite failed status = %d\n", status);
    free (gift);
    return(status);
  }
  
  free (gift);
*/


_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}
