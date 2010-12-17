#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"NFMstruct.h"
#include		"WFstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"
#include		"PDUforms.h"
#include		"PDUform_def.h"

extern	int 	PDMdebug_on;
extern	char	PDM_DEBUG_FILE[];
static int		status;
extern PDMexec_ptr PDMexec;
extern struct NFMglobal_st NFMglobal ;
extern struct WFstruct WFinfo ;
extern struct PDUforms forms;
extern Form   PDU_form_id;

/* 
   DESCRIPTION: adds a parametric part to the catalog
   INPUT:	PDMexec , 
 		attr_list, -> o/p from query add part
 		data_list, -> o/p from query add part
 		type       -> type of the catalog [P/CID]
	
*/
/* 
   If type is P then the part is regular parametric part;
      so we need to add rows to f_cat also
   If type is CID then the part is computed id parametric part;
      this means:
        catalog -> viewname
        catalog type -> VIEW
        The row is added to e_<viewname>
*/


int PDMget_list_for_modify (attr_list, data_list, type, modify_parts_list)
	MEMptr		*attr_list;
	MEMptr		*data_list;
	MEMptr		*modify_parts_list;
        char		*type;
{
	char		*fn = "PDMget_list_for_modify";
	char		**column_ptr;
	char		**data;
	char		**cit_data;
	char		**qry_data;
	char		**part_data;
	char		**attr;
	char		updater[30], date[40];
	char		val[129];
	int		i, j, k, match;
	int		attr_index, index;
	int		cat_no = -1;
	int		a1 = -1;
	int		a2 = -1;
	int		a3 = -1;
	MEMptr		data1_list = NULL;
	MEMptr		qry_bufr = NULL;
	MEMptr		cit_bufr = NULL;
	char		*sql_str, *mem_str;
	char		*sql_str2, *sql_str1, *sql_str3;
	MEMptr		fattr_list = NULL, fdata_list = NULL;
	int 		PDMinsert_rows_to_parm_cat ();
	/*int		size, size1, size2, size3;*/

	_PDMdebug("ENTER", "%s\n", fn);
	_PDMdebug(fn, "type [%s]\n", type);

 	/* may have to load some PDM data here */

        _PDMdebug (fn, "Membuilding data_list...\n");
	status = MEMbuild_array(*data_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

        _PDMdebug (fn, "Membuilding attr_list...\n");
	status = MEMbuild_array((*attr_list));
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

        _PDMdebug (fn, "Membuilding modify_parts_list...\n");
	status = MEMbuild_array((*modify_parts_list));
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

      if(PDMdebug_on) {
	MEMprint_buffer("attr_list",(*attr_list),PDM_DEBUG_FILE);
	MEMprint_buffer("data_list",*data_list,PDM_DEBUG_FILE);
	MEMprint_buffer("modify_parts_list",*modify_parts_list,PDM_DEBUG_FILE);
       }

      status = PDMquery_catalogno (PDMexec->catalog, &cat_no);
       if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, "%s %s %d \n",
                        "PDMquery_catalogno failed : status", status);
        return (status);
        }

      _PDMdebug (fn, "cat_no = %d\n", cat_no);

	column_ptr = (char **) (*data_list)->column_ptr;
	data = (char **) (*data_list)->data_ptr;
	attr = (char **) (*attr_list)->data_ptr;
	a1 = -1; a2 = -1; a3 = -1;
	for(i=0; i<(*data_list)->columns; i++) {
		if(!strcmp(column_ptr[i],"n_itemno")) a1 = i;
		if(!strcmp(column_ptr[i],"n_updater")) a2 = i;
		if(!strcmp(column_ptr[i],"n_updatedate")) a3 = i;
	}
	if( (a1 == -1 ) || (a2 == -1) || (a3 == -1) ) {
       _PDMdebug (fn, "failed to set offsets in data_list\n");
	return(PDM_E_BUFFER_FORMAT);
	}
        
          status = MEMopen(&data1_list, 1024);
           if(status != MEM_S_SUCCESS) {
             _PDMdebug (fn, "MEMopen failed status = %d",status);
             return(PDM_E_OPEN_BUFFER);
           }
	for(i=0; i<(*data_list)->columns; i++) {
          attr_index = i * ((*attr_list)->columns);
          _PDMdebug (fn, "attr[%s], type[%s]\n", attr[attr_index],
                             attr[attr_index + 1]);
          status = MEMwrite_format(data1_list, attr[attr_index],
                             attr[attr_index + 1]);
             if(status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
              MEMclose(&data1_list);
              return (status);
             }
	}

     _PDMdebug (fn,"MEMbuild_array data1_list \n");
	status = MEMbuild_array(data1_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

     sql_str = (char *) malloc ((((*modify_parts_list) -> rows) * 50) + 2096);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
       sql_str[0] ='\0';

     sql_str1 = (char *) malloc ((((*modify_parts_list) -> rows) * 50) + 2096);
        if (! sql_str1) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
       sql_str1[0] ='\0';
        

     sql_str3 = (char *) malloc ((((*modify_parts_list) -> rows) * 50) + 2096);
        if (! sql_str3) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
       sql_str3[0] ='\0';


      mem_str = (char *) malloc ((((*modify_parts_list) -> rows) * 50) + 2096);
      if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
       mem_str[0] ='\0';

       MEMclose (data_list);

       status = MEMopen (data_list, 1024);
       if(status != MEM_S_SUCCESS) {
             free (mem_str);
             _PDMdebug (fn, "MEMopen failed status = %d",status);
             return(PDM_E_OPEN_BUFFER);
           }

       (*data_list) = data1_list;

     _PDMdebug (fn,"MEMbuild_array *data_list \n");
	status = MEMbuild_array(*data_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

       column_ptr = (char **) (*data_list)->column_ptr;
       data = (char **) (*data_list)->data_ptr;

       mem_str[0] ='\0';
       sql_str[0] ='\0';
       sql_str1[0] ='\0';
       sql_str3[0] ='\0';

      strcat (sql_str1, column_ptr[0]);
      for(i=1; i<(*data_list)->columns; i++) {
        strcat (sql_str1, ", ");
        strcat (sql_str1, column_ptr[i]);
      }

     _PDMdebug ("sql_str1", "%s\n", sql_str1);
 
    /*if(!strcmp(type, "P")) */
   /* Added to support new parametric external catalog type MaC 010194*/
    if ( (!strcmp(type, "P")) || (!strcmp(type, "PXT")) ) {

    _PDMdebug ("PART TYPE", "P\n");

    part_data = (char **) (*modify_parts_list)->data_ptr;
    for(i = 0; i<(*modify_parts_list)->rows; i++) {
     index = i * (*modify_parts_list)->columns;
     sql_str3[0] = '\0';
     sprintf (sql_str3, " (n_itemname = '%s' AND n_itemrev = '%s' ) ",
                                part_data[index], part_data[index + 1]);         
/*
     sprintf (sql_str, "SELECT %s FROM %s WHERE (n_setindicator is NULL OR n_setindicator = '' ) AND %s",
             sql_str1, PDMexec->catalog, sql_str3);
*/
     sprintf (sql_str, "SELECT %s FROM %s WHERE %s",
             sql_str1, PDMexec->catalog, sql_str3);

     _PDMdebug ("sql_str", "%s\n", sql_str);

     /*status = SQLquery (sql_str,&qry_bufr,512); */
     status = PDMSQLquery (sql_str,&qry_bufr,512);
     if (status != SQL_S_SUCCESS) {
       if (status == SQL_I_NO_ROWS_FOUND) {
         _PDMdebug(fn, "This Part is not atomic : SQLstmt : status %d\n", 
                                                                        status);
         continue;     
           }
      else {
       free (mem_str);
       free (sql_str);
       free (sql_str1);
       free (sql_str3);
       MEMclose(&qry_bufr);
       return(PDM_E_SQL_STMT);
          }
        }
    }

	status = MEMbuild_array(qry_bufr);
	if(status != MEM_S_SUCCESS) {
           if (status == MEM_E_NULL_BUFFER) {
             _PDMdebug (fn, "No atomic parts to retrieve attributes\n");
             return (PDM_E_NO_CHANGEABLE_PARTS);
              /* should be no changeable parts found*/
             }    
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

        if (qry_bufr->rows < 1) {
             _PDMdebug (fn, "No atomic parts to retrieve attributes\n");
             return (PDM_E_NO_CHANGEABLE_PARTS);
              }

	qry_data = (char **) (qry_bufr)->data_ptr;
 
      if(PDMdebug_on) {
	   MEMprint_buffer("qry_bufr: parts_list", qry_bufr, PDM_DEBUG_FILE);
           }

        updater[0] = '\0';
        strcpy (updater, NFMglobal.NFMusername);
        status = NFMget_datetime (date) ;
          if (status != NFM_S_SUCCESS) {
            _PDMdebug (fn, "Get Date & Time : status = <0x%.8x>\n", status);
             return (status);
             }


     sql_str2 = (char *) malloc (((qry_bufr -> rows) * 60) + 1024);
        if (! sql_str2) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
       sql_str2[0] ='\0';

      val[0] ='\0';
      sql_str2[0] ='\0';
      sprintf (sql_str2, "( (n_citemno = %s AND n_ccatalogno = %d ) ", 
                                                qry_data[0], cat_no);
     _PDMdebug ("sql_str2", "%s\n", sql_str2);
      sprintf (val, " AND n_ccatalogno = %d ) ", cat_no);   
      for (i = 1 ; i < qry_bufr->rows; i++) {
        index = (qry_bufr)->columns * i;
        strcat (sql_str2, " OR ( n_citemno = ");
        strcat (sql_str2, qry_data[index]);
        strcat (sql_str2, val);
/*    _PDMdebug ("size of sql_str2", "%d\n", strlen (sql_str2));*/
        }
      strcat (sql_str2, " ) ");
     _PDMdebug ("sql_str2", "%s\n", sql_str2);

        /* checking in the NFMCIT table to see if this part is a child */
        _PDMdebug (fn, 
          "checking in the NFMCIT table to see if this part is a child\n");
	status = _PDMget_cit_childno (sql_str2, &cit_bufr);
	if ((status != PDM_S_SUCCESS)
	     && (status != SQL_I_NO_ROWS_FOUND)) { 
          _PDMdebug (fn,"_PDMget_cit_childno failed : status %d\n", status);
           free (mem_str);
           free (sql_str);
           free (sql_str1);
           free (sql_str2);
           free (sql_str3);
           MEMclose(&qry_bufr);
           MEMclose(&cit_bufr);
	   return(status);
	}
      
        if (sql_str2) free (sql_str2);

      
      _PDMdebug ("mem_str at the start of creating data_list", "%s\n", mem_str);

      if ((status == SQL_I_NO_ROWS_FOUND) ||
         ((status == PDM_S_SUCCESS) && (PDU_form_id == forms.rev_assy_form_id)))
        {
        if (status == SQL_I_NO_ROWS_FOUND)
           _PDMdebug (fn, "no rows found\n");
        else if (status == PDM_S_SUCCESS)
           _PDMdebug (fn, "at least one part is a member of an assembly\n");

        if (PDU_form_id == forms.rev_assy_form_id)
          _PDMdebug (fn, "allow retrieval for revise assembly\n");

      _PDMdebug (fn, "None of these parts is a member of an assy\n");
       for(i=0 ; i<qry_bufr->rows; i++) {
          index = (qry_bufr)->columns * i;
          mem_str[0] = '\0';
           for(k=0; k<(qry_bufr)->columns; k++) {
             if (k==a2)  strcat (mem_str, updater);
             else if (k==a3)  strcat (mem_str, date);
             else strcat (mem_str, qry_data[index + k]);
             strcat (mem_str, "\1");
/*             _PDMdebug ("mem_str", "%s\n", mem_str);*/
           }

        _PDMdebug ("mem_str", "%s\n", mem_str);
         status = MEMwrite((*data_list), mem_str);
         if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           free (mem_str);
           free (sql_str);
           free (sql_str1);
           free (sql_str3);
           MEMclose(&qry_bufr);
           return(status);
           }

      _PDMdebug ("mem_str after MEMwrite of data_list", "%s\n", mem_str);
         status = MEMbuild_array (*data_list);
         if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMbuild_array failed status = %d\n",status);
           free (mem_str);
           free (sql_str);
           free (sql_str1);
           free (sql_str3);
           MEMclose(&qry_bufr);
           return(status);
           }
      _PDMdebug ("mem_str after MEMbuild_array of data_list", "%s\n", mem_str);
          }
      }
      
      else /* status = PDM_S_SUCCESS */
        {
         _PDMdebug (fn, " There are some children...\n");
	status = MEMbuild_array(cit_bufr);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

	cit_data = (char **) (cit_bufr)->data_ptr;

	for(i=0 ; i<qry_bufr->rows; i++) {
          index = (qry_bufr)->columns * i;
          match = 0;
          for (j = 0; j < (cit_bufr)->rows; j++) {
            /*cit_index = (cit_bufr)->columns * j;
            if (!strcmp (qry_data[index], cit_data[cit_index+j])) */
            if (!strcmp (qry_data[index], cit_data[j])) {
               match = 1;
               break;
             }
          }
          if (match != 1) {
           mem_str[0] = '\0';
           for(k=0; k<(qry_bufr)->columns; k++) {
             strcat (mem_str, qry_data[index + k]);
             strcat (mem_str, "\1");
    /*         _PDMdebug ("mem_str", "%s\n", mem_str);*/
           }
           match = 0;

         status = MEMwrite((*data_list), mem_str);
         if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           free (mem_str);
           free (sql_str);
           free (sql_str1);
           free (sql_str3);
           MEMclose(&qry_bufr);
           MEMclose(&cit_bufr);
           return(status);
           }
          }
        }
     }


      status = MEMbuild_array ((*data_list), mem_str);
      if(status != MEM_S_SUCCESS) {
        if (status == MEM_E_NULL_BUFFER) {
           status = PDM_E_NO_CHANGEABLE_PARTS;
           _PDMdebug (fn, "All the selected parts belong to some Assy.\n");
        } else 
              _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           free (mem_str);
           free (sql_str);
           free (sql_str1);
           free (sql_str3);
           MEMclose(&qry_bufr);
           MEMclose(&cit_bufr);
           return(status);
           }
 
      if(PDMdebug_on) {
	   MEMprint_buffer("data_list", *data_list, PDM_DEBUG_FILE);
           }
    }

    else if(!strcmp(type, "CID")) {
    _PDMdebug ("PART TYPE", "CID\n");

    sprintf (sql_str, "SELECT %s FROM %s WHERE n_setindicator = '' AND %s",
             sql_str1, PDMexec->catalog, sql_str3);

     status = SQLquery (sql_str,&qry_bufr,512);
     if (status != SQL_S_SUCCESS) {
       MEMclose (&qry_bufr);
       _PDMdebug(fn, "SQLstmt : status %d\n", status);
       return(PDM_E_SQL_STMT);
         }
	qry_data = (char **) (qry_bufr)->data_ptr;
 
      if(PDMdebug_on) {
	   MEMprint_buffer("qry_bufr", qry_bufr, PDM_DEBUG_FILE);
           }


     sql_str2 = (char *) malloc (((qry_bufr -> rows) * 60) + 1024);
        if (! sql_str2) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
       sql_str2[0] ='\0';

/*    _PDMdebug ("Allocated size of sql_str2", 
                         "%d\n", (((qry_bufr -> rows) * 60) + 1024));*/

      sql_str2[0] ='\0';
      val[0] ='\0';
      sprintf (sql_str2, "( (n_citemno = %s AND n_ccatalogno = %d ) ", 
                                                qry_data[0], cat_no);
     _PDMdebug ("sql_str2", "%s\n", sql_str2);
      sprintf (val, " and n_ccatalogno = %d ) ", cat_no);   
      for (i = 1 ; i < qry_bufr->rows; i++) {
        index = (qry_bufr)->columns * i;
        strcat (sql_str2, " OR ( n_citemno = ");
        strcat (sql_str2, qry_data[index]);
        strcat (sql_str2, val);
/*    _PDMdebug ("size of sql_str2", "%d\n", strlen (sql_str2));*/
        }
      strcat (sql_str2, " ) ");
     _PDMdebug ("sql_str2", "%s\n", sql_str2);

      status = _PDMget_cit_childno (sql_str2, &cit_bufr);
      if(status != PDM_S_SUCCESS) {
           free (mem_str);
           free (sql_str);
           free (sql_str1);
           free (sql_str2);
           free (sql_str3);
           MEMclose(&qry_bufr);
           MEMclose(&cit_bufr);
          _PDMdebug (fn,"_PDMget_cit_childno failed : status %d\n", status);
	   return(status);
	}

	status = MEMbuild_array(cit_bufr);
	if(status != MEM_S_SUCCESS) {
           free (mem_str);
           free (sql_str);
           free (sql_str1);
           free (sql_str2);
           free (sql_str3);
           MEMclose(&qry_bufr);
           MEMclose(&cit_bufr);
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

	cit_data = (char **) (cit_bufr)->data_ptr;

	for(i=0 ; i<qry_bufr->rows; i++) {
          index = (qry_bufr)->columns * i;
          match = 0;
          for (j = 0; j < (cit_bufr)->rows; j++) {
              if (!strcmp (qry_data[index], cit_data[j])) {
               match = 1;
               break;
             }
          }
          if (match == 1) {
           mem_str[0] = '\0';
           strcat (mem_str, qry_data[index + 0]);
           for(k=1; k<(qry_bufr)->columns; k++) {
             strcat (sql_str1, ", ");
             strcat (sql_str1, qry_data[index + k]);
             _PDMdebug ("mem_str", "%s\n", mem_str);
           }
           match = 0;

         status = MEMwrite((*data_list), mem_str);
         if(status != MEM_S_SUCCESS) {
           free (mem_str);
           free (sql_str);
           free (sql_str1);
           free (sql_str3);
           _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           MEMclose(&qry_bufr);
           MEMclose(&cit_bufr);
           return(status);
           }
          }
        }
     if (sql_str2) free (sql_str2);
 
      if(PDMdebug_on) {
	   MEMprint_buffer("data_list", *data_list, PDM_DEBUG_FILE);
           }

         /* stopped here */ 
        

     } /* End of CID add_part support */

  _PDMdebug (fn, "Freeing memory....\n");
  _PDMdebug ("mem_str before freeing", "%s\n", mem_str);

    if (sql_str) free (sql_str);
  _PDMdebug (fn, "\n");
    if (sql_str1) free (sql_str1);
  _PDMdebug (fn, "\n");
    if (sql_str3) free (sql_str3);
  _PDMdebug (fn, "\n");
    if (qry_bufr) MEMclose(&qry_bufr);
  _PDMdebug (fn, "\n");
/* cit_bufr may not be allocated if no rows are returned */
    if (cit_bufr) MEMclose(&cit_bufr);
  _PDMdebug (fn, "\n");
    if (fattr_list) MEMclose(&fattr_list);
  _PDMdebug (fn, "\n");
    if (fdata_list) MEMclose(&fdata_list);
  _PDMdebug (fn, "\n");
    if (mem_str) free (mem_str);

    _PDMdebug("EXIT", "%s\n", fn);
    return(PDM_S_SUCCESS);	
}


int PDMupdate_parametric_parts (attr_list, data_list, type, ret_bufr)
	MEMptr		attr_list;
	MEMptr		data_list;
	MEMptr		*ret_bufr;
        char		*type;
{
	char		*fn = "PDMupdate_parametric_part";
	char		**column_ptr;
	char		**data;
	char		**attr = NULL;
	char		val[1024];
	int		i, item_no;
	int		index, columnno;
	char		*sql_str, *mem_str, *bak_sql_str;
	int 		PDMinsert_rows_to_parm_cat ();

	_PDMdebug("ENTER", "%s\n", fn);
	_PDMdebug(fn, "type [%s]\n", type);

 	/* may have to load some PDM data here */

	status = MEMbuild_array(data_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
           MEMclose (&data_list);
           MEMclose (&attr_list);
	   return(PDM_E_BUILD_ARRAY);
	}

	status = MEMbuild_array(attr_list);
	if(status != MEM_S_SUCCESS) {
           MEMclose (&data_list);
           MEMclose (&attr_list);
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}
        

     status = _PDMcreate_parm_ret_buffer (attr_list, data_list, ret_bufr);
     if(status != PDM_S_SUCCESS) {
       _PDMdebug (fn,"_PDMcreate_parm_ret_buffer failed : status %d\n", status);
        return (status);
        }

	status = MEMbuild_array(*ret_bufr);
	if ( (status != MEM_S_SUCCESS) && (status != MEM_E_NULL_LIST) ) {
          _PDMdebug (fn,"MEMbuild_array of ret_bufr failed : status %d\n",
								 status);
	   return(status);
	}

          if(PDMdebug_on) {
	     MEMprint_buffer("attr_list", attr_list, PDM_DEBUG_FILE);
	     MEMprint_buffer("data_list", data_list, PDM_DEBUG_FILE);
          }

	column_ptr = (char **) data_list->column_ptr;
	data = (char **) data_list->data_ptr;

    /*if(!strcmp(type, "P")) */
   /* Added to support new parametric external catalog type MaC 010194*/
    if ( (!strcmp(type, "P")) || (!strcmp(type, "PXT")) ) {

        mem_str = (char *) malloc (((data_list->rows) * 50) + 1024);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
       mem_str[0] ='\0';
       data = (char **) data_list->data_ptr;
       attr = (char **) attr_list->data_ptr;
       column_ptr = (char **) data_list->column_ptr;


        status = PDMupdate_rows_to_parm_cat (PDMexec->catalog,
				         attr_list, data_list, ret_bufr);
          if(status != PDM_S_SUCCESS) {
           _PDMdebug (fn,"PDMinsert_rows_to_parm_cat failed status -> %d \n",
	           status);
           free (mem_str);
             return(status);
           }
    free (mem_str);
    }

    else if(!strcmp(type, "CID")) {
/* the alg is:
    - For each row in the data buffer, insert a row into the
      catalog table
*/
        sql_str = (char *) malloc (((data_list->rows) * 50) + 1024);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

        bak_sql_str = (char *) malloc (((data_list->rows) * 50) + 1024);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }


    sql_str[0] = '\0';
    bak_sql_str[0] = '\0';
    sprintf (sql_str, "INSERT INTO e_%s (", PDMexec->catalog);
       data = (char **) data_list->data_ptr;
       column_ptr = (char **) data_list->column_ptr;
       strcat (sql_str, column_ptr[0]);
/*       strcat (sql_str, ", ");*/
	for(columnno=1; columnno < data_list->columns; columnno++) {
          strcat (sql_str, ", ");
          strcat (sql_str, column_ptr[columnno]);
     _PDMdebug ("sql_str", "%s\n", sql_str);
         }
     strcat (sql_str, ") VALUES (");
     strcpy (bak_sql_str, sql_str);
     
	for(i=0 ; i<data_list->rows; i++) {
          index = data_list->columns * i;
          _PDMdebug (fn, "inserting row # %d\n", i);
          status = NFMget_serial_slot (PDMexec->user_id, PDMexec->catalog,
                     column_ptr [0], &item_no);
          if (status != NFM_S_SUCCESS) {
               _PDMdebug (fn, "Get Serial No : status = <0x%.8x>\n",
               status);
               return (status);
                   }
          sprintf  (val, "%d", item_no); 
          _PDMdebug (fn, "item_no[%d], val [%s]\n", item_no, val);
          strcat (sql_str, val);
/*          strcat (sql_str, ", ");*/
          for(columnno=1; columnno < data_list->columns; columnno++) {
              strcat (sql_str, ", ");
             _PDMget_data_type (attr[(attr_list->columns * columnno) + 1],
                                        data[index + columnno], val); 
             _PDMdebug (fn, "val [%s]\n", val);
             strcat (sql_str, val);
             /* strcat (sql_str, data[index + columnno]);*/
     _PDMdebug ("sql_str", "%s\n", sql_str);
		}
          strcat (sql_str, ") ");
         _PDMdebug ("sql_str", "%s\n", sql_str);
          status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS) {
              free (sql_str);
              free (bak_sql_str);
             _PDMdebug (fn, "SQLstmt %d\n", status);
             return (status);
             }
          sql_str[0] = '\0';
          strcpy (sql_str, bak_sql_str);
       }
     free (sql_str);
     free (bak_sql_str);
     } /* End of CID add_part support */

     if(PDMdebug_on) {
             MEMprint_buffer("ret_bufr", *ret_bufr, PDM_DEBUG_FILE);
         }

    _PDMdebug("EXIT", "%s\n", fn);
    return(PDM_S_SUCCESS);	
}


int PDMupdate_rows_to_parm_cat (catalog, attr_list, data_list, ret_bufr)
char	*catalog;
MEMptr	attr_list, data_list;
MEMptr	*ret_bufr;
{
	char		*fn = "PDMupdate_rows_to_parm_cat";
	char		**column_ptr;
	char		**data;
	char		**attr;
	int		i;
	char		out_str[1024];
	int		f_cols, comma;
	int		attr_index, data_index, columnno;
	MEMptr		cattr_list = NULL, cdata_list = NULL;
	MEMptr		fattr_list = NULL, fdata_list = NULL;
	char		*sql_str, *bak_sql_str;
        int 		PDMupdate_f_cat_rows ();

	_PDMdebug("ENTER", "%s\n", fn);


     _PDMdebug (fn,"MEMbuild_array data_list \n");
	status = MEMbuild_array(data_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

     _PDMdebug (fn,"MEMbuild_array attr_list \n");
	status = MEMbuild_array(attr_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

        cdata_list = data_list;
        cattr_list = attr_list;
	column_ptr = (char **) cdata_list->column_ptr;
	data = (char **) cdata_list->data_ptr;
	attr = (char **) cattr_list->data_ptr;
/* preprocessing the buffer...*/

      
     _PDMdebug (fn,"Mallocing sql_str \n");
        sql_str = (char *) malloc (((cdata_list->row_size) * 5 ) + 1024);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

     _PDMdebug (fn,"Mallocing bak_sql_str \n");
        bak_sql_str = (char *) malloc (((cdata_list -> row_size) * 5) + 1024);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }


    sql_str[0] = '\0';
    bak_sql_str[0] = '\0';
    f_cols = -1;
    comma = -1;

/*  adding data values */
     
    /*sprintf (sql_str, "UPDATE %s SET ", catalog);*/
       sql_str[0] = '\0';
	for(i=0 ; i<cdata_list->rows; i++) {
       data_index = cdata_list->columns * i;
       comma = -1;
       _PDMdebug (fn, "updating row # %d\n", i);
       status =  _PDMconst_upd_str (attr[0], attr[1], data[data_index], out_str);
       if (status != PDM_S_SUCCESS) {
              free (sql_str);
              free (bak_sql_str);
             _PDMdebug (fn, "_PDMconst_upd_str failed  %d\n", status);
             return (status);
       }
       _PDMdebug (fn, "out_str [%s]\n", out_str);
       strcat (sql_str, out_str);
       for(columnno=1; columnno < cdata_list->columns; columnno++) {
         attr_index = cattr_list->columns * columnno;
         strcat (sql_str, ", ");
         status =  _PDMconst_upd_str (attr[attr_index], 
                                              attr[attr_index + 1], 
                                              data[data_index + columnno], 
                                              out_str);
         if (status != PDM_S_SUCCESS) {
           free (sql_str);
           free (bak_sql_str);
           _PDMdebug (fn, "_PDMconst_upd_str failed  %d\n", status);
           return (status);
           }
/*         _PDMdebug (fn, "out_str [%s]\n", out_str);*/
         strcat (sql_str, out_str);
	}
       _PDMdebug ("sql_str", "%s\n", sql_str);
       strcpy (bak_sql_str, sql_str);
       sprintf (sql_str, "UPDATE %s SET %s WHERE n_itemno = %s ", 
                                      catalog, bak_sql_str, data [data_index]);
         _PDMdebug ("sql_str", "%s\n", sql_str);
          status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS) {
              _PDMadd_errrow_to_retbufr ( data[data_index + 1],
                   data[data_index + 2], data[data_index + 3],
                   status, ret_bufr );
              free (sql_str);
              free (bak_sql_str);
             _PDMdebug (fn, "SQLstmt %d\n", status);
             return (status);
             }
          sql_str[0] = '\0';
       }
     free (sql_str);
     free (bak_sql_str);

 MEMclose (&fattr_list);
 MEMclose (&fdata_list);
_PDMdebug("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}


int PDMupdate_f_cat_rows (catalog, fattr_list, fdata_list)
char	*catalog;
MEMptr	fattr_list, fdata_list;
{
	char		*fn = "PDMupdate_f_cat_rows";
	char		**column_ptr;
	char		**data;
	char		**attr;
	int		i;
	char		val[1024], *username, *fcat;
	int		f_cols, comma;
	int		index, columnno;
	int		file_no = -1;
	char		*sql_str, *bak_sql_str;
        int 		PDMupdate_f_cat_rows ();

	_PDMdebug("ENTER", "%s\n", fn);


     _PDMdebug (fn,"MEMbuild_array data_list \n");
	status = MEMbuild_array(fdata_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
           MEMclose (&fdata_list);
           MEMclose (&fattr_list);
	   return(PDM_E_BUILD_ARRAY);
	}

     _PDMdebug (fn,"MEMbuild_array attr_list \n");
	status = MEMbuild_array(fattr_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
           MEMclose (&fdata_list);
           MEMclose (&fattr_list);
	   return(PDM_E_BUILD_ARRAY);
	}

	column_ptr = (char **) fdata_list->column_ptr;
	data = (char **) fdata_list->data_ptr;
	attr = (char **) fattr_list->data_ptr;
      
     _PDMdebug (fn,"Mallocing username \n");
        username = (char *) malloc (sizeof (NFMglobal.NFMusername) + 3);
        if (! username) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
      
     _PDMdebug (fn,"Mallocing fcat \n");
        fcat = (char *) malloc (sizeof (catalog) + 10);
        if (! fcat) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
      
     _PDMdebug (fn,"Mallocing sql_str \n");
        sql_str = (char *) malloc (((fdata_list->rows) * 50) + 1024);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

     _PDMdebug (fn,"Mallocing bak_sql_str \n");
        bak_sql_str = (char *) malloc (((fdata_list-> rows) * 50) + 1024);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }


    username[0] = '\0';
    fcat[0] = '\0';
    sql_str[0] = '\0';
    bak_sql_str[0] = '\0';
    strcpy (fcat, catalog);
    f_cols = -1;
    comma = -1;
    sprintf (sql_str, "INSERT INTO %s (", fcat);
       data = (char **) fdata_list->data_ptr;
       column_ptr = (char **) fdata_list->column_ptr;
       strcat (sql_str, column_ptr[0]);
       _PDMdebug ("sql_str", "%s\n", sql_str);
	for (columnno=1; columnno < fdata_list->columns; columnno++) {
/*        if (!strcmp (attr[(fattr_list->columns * columnno) + 5], "Y")) {*/
          strcat (sql_str, ", ");
          strcat (sql_str, column_ptr[columnno]);
          _PDMdebug ("sql_str", "%s\n", sql_str);
/*          }*/
          }
       strcat (sql_str, ") VALUES (");
       strcpy (bak_sql_str, sql_str);

/*  adding data values */
     
	for(i=0 ; i<fdata_list->rows; i++) {
          index = fdata_list->columns * i;
          comma = -1;
          _PDMdebug (fn, "inserting row # %d\n", i);
          status = NFMget_serial_slot (PDMexec->user_id, fcat,
                     column_ptr [0], &file_no);
          if (status != NFM_S_SUCCESS) {
               _PDMdebug (fn, "Get Serial No : status = <0x%.8x>\n",
               status);
               return (status);
                   }
          sprintf  (val, "%d", file_no); 
          _PDMdebug (fn, "file_no[%d], val [%s]\n", file_no, val);
          strcat (sql_str, val);
          for(columnno=1; columnno < fdata_list->columns; columnno++) {
/*            if (!strcmp (attr[(fattr_list->columns * columnno) + 5], "Y")){*/
             strcat (sql_str, ", ");
             _PDMget_data_type (attr[(fattr_list->columns * columnno) + 1],
                                        data[index + columnno], val); 
             _PDMdebug (fn, "val [%s]\n", val);
             strcat (sql_str, val);
             _PDMdebug ("sql_str", "%s\n", sql_str);
/*               }*/
	     }
          strcat (sql_str, ") ");
         _PDMdebug ("sql_str", "%s\n", sql_str);
          status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS) {
              free (sql_str);
              free (bak_sql_str);
             _PDMdebug (fn, "SQLstmt %d\n", status);
             return (status);
             }
          sql_str[0] = '\0';
          strcpy (sql_str, bak_sql_str);
       }
     free (sql_str);
     free (bak_sql_str);
     free (username);
     free (fcat);

_PDMdebug("EXIT", "%s\n", fn);

return (PDM_S_SUCCESS);
}


int _PDMget_cit_childno (citemno_str, cit_bufr)
char *citemno_str;
MEMptr	*cit_bufr;
{
char		*fn = "_PDMget_cit_childno";
char		*sql_str;
long		one, two;
MEMptr		qry_bufr = NULL;

     one = two = -1;
    _PDMdebug ("ENTER", "%s\n", fn);    
    _PDMdebug (fn, "citemno_str:\n%s\n", citemno_str);
    _PDMdebug (fn, "one[%d] two[%d]\n", strlen(citemno_str), 
				sizeof(*citemno_str));
     sql_str = (char *) malloc (strlen (citemno_str) + 512);
     if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
     sql_str[0] = '\0';   
     sprintf (sql_str, "SELECT n_citemno from nfmsetcit where %s", citemno_str);
     _PDMdebug(fn, "sql_str = <%s>\n", sql_str);
     status = SQLquery (sql_str,&qry_bufr,512);
     if (status != SQL_S_SUCCESS) {
       _PDMdebug(fn, "SQLquery : status %d\n", status);
       MEMclose (&qry_bufr);
       free (sql_str);
       return(status);
      }
     
      if(PDMdebug_on)
	MEMprint_buffer("qry_bufr",qry_bufr,PDM_DEBUG_FILE);

   status = MEMbuild_array (qry_bufr);
   if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       free (sql_str);
       return(status);
    }
  
 *cit_bufr = qry_bufr;

 free (sql_str);
 _PDMdebug ("EXIT", "%s\n", fn);    
  return (PDM_S_SUCCESS);
}


int _PDMconst_upd_str (attr_name, attr_type, data, out_str)
char	*attr_name, *data, *out_str;
char	*attr_type;
{
	char	*fn = "_PDMconst_upd_str";
	char	wazit[20], date[40];
	char	val[512];
	int	i;

   wazit[0] = 0;
   val[0] = 0;
   out_str[0] = 0;
   for (i=0;i<20;i++) wazit[i] = '\0';

  _PDMdebug ("ENTER", "%s: [%s], [%s]\n", fn, attr_name, data);
   val[0] = '\0';
   strcpy (wazit, attr_type);
   /*strcat (wazit, "\0");*/
   _PDMdebug (fn, "wazit [%s]\n", wazit);
   if (!strncmp (wazit, "char", 4)){
         sprintf (val, "'%s'", data);
         sprintf (out_str, "%s = %s", attr_name, val);
         _PDMdebug (fn, "val [%s], out_str[%s]\n", val, out_str);
         }
   else if (!strncmp (wazit, "int", 3)){
         sprintf (val, "%d", atol(data));
         sprintf (out_str, "%s = %s", attr_name, val);
         _PDMdebug (fn, "val [%s], out_str[%s]\n", val, out_str);
         }
   else if (!strcmp (wazit, "smallint")){
         sprintf (val, "%d", atoi(data));
         sprintf (out_str, "%s = %s", attr_name, val);
         _PDMdebug (fn, "val [%s], out_str[%s]\n", val, out_str);
         }
   else if ((!strncmp (wazit, "doub", 4)) 
                    || (!strncmp (wazit, "float", 5))
                    || (!strcmp (wazit, "decimal"))) {
         if (data[0] != NULL) {
         _PDMdebug (fn, "strlen[%s] = %d\n", data, strlen (data));
            for (i=0; i< (strlen (data)); i++)
            _PDMdebug (fn, " %c ", data[i]);
            _PDMdebug ("", "\n");
            sprintf (val, "%s", data);
            } 
          else {
            sprintf (val, "%f", 0);
            }
            sprintf (out_str, "%s = %s", attr_name, val);
            _PDMdebug (fn, "val [%s], out_str[%s]\n", val, out_str);
            _PDMdebug (fn, "double val [%s]\n", val);
         }
   else if (!strncmp (wazit, "real", 4)){
         if (data[0] != NULL) {
         _PDMdebug (fn, "strlen[%s] = %d\n", data, strlen (data));
            for (i=0; i< (strlen (data)); i++)
            _PDMdebug (fn, " %c ", data[i]);
            _PDMdebug ("", "\n");
            sprintf (val, "%s", data);
            } 
          else {
            sprintf (val, "%f", 0);
            }
            sprintf (out_str, "%s = %s", attr_name, val);
            _PDMdebug (fn, "val [%s], out_str[%s]\n", val, out_str);
            _PDMdebug (fn, "double val [%s]\n", val);
         }
   else if (!strncmp (wazit, "time", 4)){
        status = NFMascii_to_timestamp_format (data, date) ;
          if (status != NFM_S_SUCCESS) {
              _PDMdebug (fn, "ascii to timestamp:status = <0x%.8x>\n", status);
              return (status) ;
                  }
         sprintf (val, "TIMESTAMP '%s'", date);
         sprintf (out_str, "%s = %s", attr_name, val);
         _PDMdebug (fn, "val [%s], out_str[%s]\n", val, out_str);
         }
   else {
  _PDMdebug (fn, "unknown data type ...%s\n", attr_type);
   return (-1);
     }
  _PDMdebug ("EXIT", "%s\n", fn);
   return (PDM_S_SUCCESS);
 }

