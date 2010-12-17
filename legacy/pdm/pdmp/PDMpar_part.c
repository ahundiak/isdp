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

extern	int 	PDMdebug_on;
extern	char	PDM_DEBUG_FILE[];
static int		status;
static char		s[1024];
extern PDMexec_ptr PDMexec;
extern struct NFMglobal_st NFMglobal ;
extern struct WFstruct WFinfo ;

/* 
   DESCRIPTION: adds a parametric part to the catalog
   INPUT:	PDMexec , 
 		attr_list, -> o/p from query add part
 		data_list, -> o/p from query add part
 		type       -> type of the catalog [P/CID]
	
static int		curbuf_no;
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


int PDMadd_parametric_part(attr_list, data_list, type, ret_bufr)
	MEMptr		attr_list;
	MEMptr		data_list;
        char		*type;
	MEMptr		*ret_bufr;
{
	char		*fn = "PDMadd_parametric_part";
	char		**column_ptr;
	char		**data;
	char		**attr;
/*	char		u[10];*/
	char		stateno[10];
	int		i;
	int		index, columnno;
	int		a1 = -1;
	int		a2 = -1;
	int		a3 = -1;
	int		a4 = -1;
	char		*sql_str, *mem_str, *bak_sql_str;
	int 		PDMinsert_rows_to_parm_cat ();

	_PDMdebug("ENTER", "%s\n", fn);
	_PDMdebug(fn, "type [%s]\n", type);

 	/* may have to load some PDM data here */

	status = MEMbuild_array(data_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

	status = MEMbuild_array(attr_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

/*......attr list no longer needed ..
         status = _PDMcreate_parm_ret_buffer (attr_list, ret_bufr);
         if(status != PDM_S_SUCCESS) {
           _PDMdebug (fn,"_PDMcreate_parm_ret_buffer failed : status %d\n", 
						status);
            return(status);
	    }
 ..........MaC 11/22/93*/

         status = _PDMcreate_parm_ret_buffer (ret_bufr);
         if(status != PDM_S_SUCCESS) {
           _PDMdebug (fn,"_PDMcreate_parm_ret_buffer failed : status %d\n", 
						status);
            return(status);
	    }

	status = MEMbuild_array(*ret_bufr);
        if ( (status != MEM_S_SUCCESS) && (status != MEM_E_NULL_LIST) ) {
          _PDMdebug (fn,"MEMbuild_array of ret_bufr failed : status %d\n",
                                                                 status);
           return(status);
        }

	column_ptr = (char **) data_list->column_ptr;
	data = (char **) data_list->data_ptr;
	a1 = -1; a2 = -1;
	a3 = -1;
	for(i=0; i<data_list->columns; i++) {
		if(!strcmp(column_ptr[i],"p_maxlevel")) a1 = i;
		if(!strcmp(column_ptr[i],"p_explode"))  a2 = i;
		if(!strcmp(column_ptr[i],"n_stateno"))  a3 = i;
		if(!strcmp(column_ptr[i],"n_aclno"))    a4 = i;
	}
	if (a1 == -1 || a2 == -1 || a3 == -1 || a4 == -1 ) {
       _PDMdebug (fn, "failed to set offsets in data_list\n");
	return(PDM_E_BUFFER_FORMAT);
	}

    /* hardcoding the  start state
        u[0] = '\0';
        sprintf (u, "%d", 13);
        status = MEMwrite_data(data_list, u, i+1, a3+1);
    ...... NOT! */

	for(i=0 ; i<data_list->rows; i++) {
          index = data_list->columns * i;

         WFinfo.acl = atol (data[index + a4]);
         _PDMdebug (fn, "aclno[%d] commandno[%d]\n", 
				WFinfo.acl, WFinfo.command);

         status = WFload_wf_struct_for_sts () ;
         if (status != NFM_S_SUCCESS) {
          _PDMdebug (fn, 
          "WFload sts: load transition for acl failed : status = <0x%.8x>\n",
                                                                      status) ;
         return (status) ;
         }

        sprintf (stateno, "%d", WFinfo.next_state);
        _PDMdebug (fn, "state_no[%s]\n", stateno);

          if(!strcmp(data[index + a3],"") || !strlen(data[index + a3])) {
          /* default n_stateno is 13 */
             status = MEMwrite_data(data_list, stateno, i+1, a3+1);
             if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_data failed : status %d\n", status);
                return(PDM_E_WRITE_COLUMN);
                }
          }
          if(!strcmp(data[index + a1],"") || !strlen(data[index + a1])) {
          /* default p_maxlevel is 0 */
             s[0] = '\0';
             sprintf(s,"%d",0);
             status = MEMwrite_data(data_list,s, i+1, a1+1);
             if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_data failed : status %d\n", status);
                return(PDM_E_WRITE_COLUMN);
                }
          }

          /* if p_explode is not set default to Y */
          
          if(!strcmp(data[index + a2],"") || !strlen(data[index + a2])) {
          status = MEMwrite_data(data_list,"Y", i+1,a2+1);
          if(status != MEM_S_SUCCESS) {
             sprintf(s,"MEMwrite_data failed : status %d\n",
                                     status);
             PDMdebug(s);
             return(PDM_E_WRITE_COLUMN);
             }
          }
         }

          if(PDMdebug_on) {
	     MEMprint_buffer("attr_list",attr_list,PDM_DEBUG_FILE);
	     MEMprint_buffer("data_list",data_list,PDM_DEBUG_FILE);
          }



    /*if(!strcmp(type, "P")) */
   /* Added to support new parametric external catalog type MaC 010194*/
    if ( (!strcmp(type, "P")) || (!strcmp(type, "PXT")) ) {


        mem_str = (char *) malloc (((data_list) -> row_size) *10);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
       mem_str[0] ='\0';
       data = (char **) data_list->data_ptr;
       attr = (char **) attr_list->data_ptr;
       column_ptr = (char **) data_list->column_ptr;

        status = PDMinsert_rows_to_parm_cat (PDMexec->catalog,
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
        sql_str = (char *) malloc (((data_list) -> row_size) *10);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

        bak_sql_str = (char *) malloc (((data_list) -> row_size) *10);
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
          strcat (sql_str, data[index]);
/*          strcat (sql_str, ", ");*/
          for(columnno=1; columnno < data_list->columns; columnno++) {
              strcat (sql_str, ", ");
              strcat (sql_str, data[index + columnno]);
     _PDMdebug ("sql_str", "%s\n", sql_str);
		}
          strcat (sql_str, ") ");
         _PDMdebug ("sql_str", "%s\n", sql_str);
          status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS) {
           _PDMadd_errrow_to_retbufr ( data[index + 1], 
                   data[index + 2], data[index + 3],
                   status, ret_bufr );
              free (sql_str);
              free (bak_sql_str);
             _PDMdebug (fn, "SQLstmt %d\n", status);
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


int PDMsadd_parametric_part_to_project(attr_list, data_list)
	MEMptr		attr_list;
	MEMptr		data_list;
{

	PDMdebug("ENTER PDMsadd_part_to_project:\n");
/*
    status = MEMreset_buffer(PDMexec->ws_buffer,&curbuf_no);
    if(status != MEM_S_SUCCESS)
    {
		sprintf(s,"MEMreset_buffer failed : status %d\n",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
    }
    
    status = MEMsplit_copy_buffer(PDMexec->ws_buffer,&attr_list,0);
    if(status != MEM_S_SUCCESS)
    {
		sprintf(s,"MEMcopy_split_buffer failed : status %d\n",
			status);
		PDMdebug(s);
		return(PDM_E_COPY_BUFFER);
    }
    status = MEMreset_buffer(PDMexec->ws_buffer,&curbuf_no);
    if(status != MEM_S_SUCCESS)
    {
		MEMclose(&attr_list);
		sprintf(s,"MEMreset_buffer failed : status %d\n",status);
		PDMdebug(s);
		return(PDM_E_RESET_BUFFER);
    }
    status = MEMsplit_copy_buffer(PDMexec->ws_buffer,&data_list,0);
    if(status != MEM_S_SUCCESS)
    {
       MEMclose(&attr_list);
       sprintf(s,"MEMcopy_split_buffer failed : status %d\n",
			status);
       PDMdebug(s);
	   return(PDM_E_COPY_BUFFER);
    }
*/

    if (PDMdebug_on)
      {
        MEMprint_buffer("attr_list", attr_list, PDM_DEBUG_FILE);
        MEMprint_buffer("data_list", data_list, PDM_DEBUG_FILE);
      }

    status = NFMupdate_project_members(
							PDMexec->user_id,
							attr_list,data_list);
    if(status != NFM_S_SUCCESS)
    {
		MEMclose(&attr_list);
		MEMclose(&data_list);
		sprintf(s,"NFMupdate_project_members failed status -> %d \n",
			status);
		PDMdebug(s);
	    if(status == NFM_E_DUP_ITEM)
			return(PDM_E_PART_EXISTS);
        else
			return(PDM_E_ADD_ITEM);
    }    
/*
    MEMclose(&attr_list);
    MEMclose(&data_list);
*/
    PDMdebug("EXIT:PDMsadd_part_to_project\n");
    return(PDM_S_SUCCESS);	
}


/* This function adds data_list->rows rows into parametric catalog.
   Basically, it adds multiple parts to the catalog/f_catalog */

int PDMinsert_rows_to_parm_cat (catalog, attr_list, data_list, ret_bufr)
char	*catalog;
MEMptr	attr_list, data_list, *ret_bufr;
{
	char		*fn = "PDMinsert_rows_to_parm_cat";
	char		**column_ptr;
	char		**data;
	char		**attr;
	int		i, i_updatedate;
	char		val[1024];
	int		f_cols, comma;
	int		index, columnno;
	int		item_no = -1;
	MEMptr		cattr_list = NULL, cdata_list = NULL;
/*	MEMptr		fattr_list = NULL, fdata_list = NULL;*/
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

/*
     status = NFMsplit_catalog_attributes (PDMexec->user_id,
                                           attr_list, data_list,
                                           &cattr_list, &cdata_list,
                                           &fattr_list, &fdata_list);
     if (status != NFM_S_SUCCESS) {
        MEMclose (&cattr_list);
        MEMclose (&fattr_list);
        MEMclose (&cdata_list);
        MEMclose (&fdata_list);
        _PDMdebug (fn, "Split Cat List : status = <0x%.8x>\n", status);
        return (status);
      }

     _PDMdebug (fn,"MEMbuild_array data_list \n");
	status = MEMbuild_array(cdata_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

     _PDMdebug (fn,"MEMbuild_array attr_list \n");
	status = MEMbuild_array(cattr_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

     _PDMdebug (fn,"MEMbuild_array data_list \n");
	status = MEMbuild_array(fdata_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

     _PDMdebug (fn,"MEMbuild_array attr_list \n");
	status = MEMbuild_array(fattr_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

    if(PDMdebug_on) {
	MEMprint_buffer("cattr_list", cattr_list,PDM_DEBUG_FILE);
	MEMprint_buffer("cdata_list", cdata_list,PDM_DEBUG_FILE);
	MEMprint_buffer("fattr_list", fattr_list,PDM_DEBUG_FILE);
	MEMprint_buffer("fdata_list", fdata_list,PDM_DEBUG_FILE);
        }

*/
        cdata_list = data_list;
        cattr_list = attr_list;
    if(PDMdebug_on) {
	MEMprint_buffer("cdata_list", cdata_list,PDM_DEBUG_FILE);
                }

	column_ptr = (char **) cdata_list->column_ptr;
	data = (char **) cdata_list->data_ptr;
	attr = (char **) cattr_list->data_ptr;

/* Fix to get offset for n_updatedate. MaC 071994 */

     for (columnno=0; columnno < cdata_list->columns; columnno++) {
      if (!strcmp (column_ptr[columnno], "n_updatedate")) {
                    i_updatedate = columnno;
                    break;
                    }
     }
     
     _PDMdebug (fn, "Offset for n_updatedate [%d]\n", i_updatedate);


     _PDMdebug (fn,"Mallocing sql_str \n");
        sql_str = (char *) malloc (((cdata_list) -> row_size) *10);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

     _PDMdebug (fn,"Mallocing bak_sql_str \n");
        bak_sql_str = (char *) malloc (((cdata_list) -> row_size) *10);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }


    sql_str[0] = '\0';
    bak_sql_str[0] = '\0';
    f_cols = -1;
    comma = -1;
    sprintf (sql_str, "INSERT INTO %s (", catalog);
       data = (char **) cdata_list->data_ptr;
       column_ptr = (char **) cdata_list->column_ptr;
       strcat (sql_str, column_ptr[0]);
       _PDMdebug ("sql_str", "%s\n", sql_str);
	for (columnno=1; columnno < cdata_list->columns; columnno++) {
/* Fix to make sure that updatedate does not get initialised
     during create time : column # for n_updatedate=i_updatedate*/
         if (columnno != i_updatedate) {
          strcat (sql_str, ", ");
          strcat (sql_str, column_ptr[columnno]);
           }
          }
          _PDMdebug ("sql_str", "%s\n", sql_str);
       strcat (sql_str, ") VALUES (");
       strcpy (bak_sql_str, sql_str);

/*  adding data values */
     
	for(i=0 ; i<cdata_list->rows; i++) {
          index = cdata_list->columns * i;
          comma = -1;
          _PDMdebug (fn, "inserting row # %d\n", i);
/*
 * TR #:139526003. 01/sep/95 - raj. 'n_itemno' is not always the first column
 * (column_ptr[0]). User could have reordered the attributes. The code to get
 * the next available itemno is moved 'into' the loop. Changed to start loop
 * from 0 instead of 1.
 */
#if 0
      /* getting next available itemno */
          status = NFMget_serial_slot (PDMexec->user_id, catalog,
                     column_ptr [0], &item_no);
          if (status != NFM_S_SUCCESS) {
               _PDMdebug (fn, "Get Serial No : status = <0x%.8x>\n",
               status);
               return (status);
                   }
          sprintf  (val, "%d", item_no); 
          _PDMdebug (fn, "item_no[%d], val [%s]\n", item_no, val);
          strcat (sql_str, val);
          for(columnno=1; columnno < cdata_list->columns; columnno++) {
#endif
          for(columnno=0; columnno < cdata_list->columns; columnno++) {
/* Fix to make sure that updatedate does not get initialised
     during create time: column # for n_updatedate=i_updatedate */
            if (columnno != i_updatedate) {   
              /* TR #:139526003. 01/sep/95 - raj. Inserted code to process n_itemno. */
              if (!strcmp (column_ptr[columnno], "n_itemno"))
              {
                /* getting next available itemno */
                status = NFMget_serial_slot (PDMexec->user_id, catalog, column_ptr [columnno], &item_no);
                if (status != NFM_S_SUCCESS)
                {
                  _PDMdebug (fn, "Get Serial No : status = <0x%.8x>\n", status);
                  return (status);
                }
                sprintf  (val, "%d", item_no); 
                _PDMdebug (fn, "item_no[%d], val [%s]\n", item_no, val);
                if (columnno != 0)
                  strcat (sql_str, ", ");
                strcat (sql_str, val);
              }
              else
              {
/*             if (strcmp (data[index + columnno], "") {*/
           if (columnno != 0)
             strcat (sql_str, ", ");
        /* prepares the string depending upon datatype */
             _PDMget_data_type (attr[(attr_list->columns * columnno) + 1],
                                        data[index + columnno], val); 
             _PDMdebug (fn, "val [%s]\n", val);
             strcat (sql_str, val);
/*                }*/
                
              }
            }
	  }
          strcat (sql_str, ") ");
         _PDMdebug ("sql_str", "%s\n", sql_str);
          status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS) {
        /* adds a row to the return buffer saying that this part failed */
            _PDMadd_errrow_to_retbufr ( data[index + 1], 
                   data[index + 2], data[index + 3],
                   status, ret_bufr );
              /*
              free (sql_str);
              free (bak_sql_str);
               */
             _PDMdebug (fn, "SQLstmt %d\n", status);
             }
          sql_str[0] = '\0';
          strcpy (sql_str, bak_sql_str);
       }
     if (sql_str) free (sql_str);
     if (bak_sql_str) free (bak_sql_str);


/*

        status = PDMinsert_f_cat_rows  (PDMexec->catalog,
  				         fattr_list, fdata_list, ret_bufr);
                if(status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "PDMinsert_f_cat_rows failed : status %d\n",
                        status);
                return(status);
*/
	status = MEMbuild_array(*ret_bufr);
	if ( (status != MEM_S_SUCCESS) &&
	              (status != MEM_E_NULL_LIST) ) {
          _PDMdebug (fn,"MEMbuild_array ret_bufr failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}


        if ((*ret_bufr)->rows > 1)
           status = PDM_E_ADD_ITEM;
        else
           status = PDM_S_SUCCESS;
            


_PDMdebug("EXIT", "%s\n", fn);
return (status);
}


int PDMinsert_f_cat_rows (catalog, fattr_list, fdata_list, ret_bufr)
char	*catalog;
MEMptr	fattr_list, fdata_list;
MEMptr	*ret_bufr;
{
	char		*fn = "PDMinsert_f_cat_rows";
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
        sql_str = (char *) malloc (((fdata_list) -> row_size) *10);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

     _PDMdebug (fn,"Mallocing bak_sql_str \n");
        bak_sql_str = (char *) malloc (((fdata_list) -> row_size) *10);
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }


    username[0] = '\0';
    fcat[0] = '\0';
    sql_str[0] = '\0';
    bak_sql_str[0] = '\0';
    sprintf (fcat, "f_%s", catalog);
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
/*               }*/
	     }
          strcat (sql_str, ") ");
         _PDMdebug ("sql_str", "%s\n", sql_str);
          status = SQLstmt (sql_str);
           if (status != SQL_S_SUCCESS) {
            _PDMadd_errrow_to_retbufr ( data[index + 1], 
                   data[index + 2], data[index + 3],
                   status, ret_bufr );
             _PDMdebug (fn, "SQLstmt %d\n", status);
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

int _PDMget_data_type (attr, data, val)
char	*attr, *data, *val;
{
	char	*fn = "_PDMget_data_type";
	char	wazit[20], date[40];
	int	i;

   wazit[0] = '\0';
   for (i=0;i<20;i++) wazit[i] = '\0';

  _PDMdebug ("ENTER", "%s: [%s], [%s]\n", fn, attr, data);
   val[0] = '\0';
   /*strncpy (wazit, attr, 4);*/
   strcpy (wazit, attr);
   /*strcat (wazit, "\0");*/
   _PDMdebug (fn, "wazit [%s]\n", wazit);
   if (!strncmp (wazit, "char", 4)){
         sprintf (val, "'%s'", data);
         _PDMdebug (fn, "val [%s]\n", val);
         return (PDM_S_SUCCESS);
         }
   else if (!strcmp (wazit, "smallint")){
         sprintf (val, "%d", atoi(data));
         _PDMdebug (fn, "val [%s]\n", val);
         return (PDM_S_SUCCESS);
         }
   else if (!strncmp (wazit, "inte", 4)){
         sprintf (val, "%d", atol(data));
         _PDMdebug (fn, "val [%s]\n", val);
         return (PDM_S_SUCCESS);
         }
   else if (!strncmp (wazit, "real", 4)){
         if (data[0] != NULL) {
            for (i=0; i< (strlen (data)); i++) 
            _PDMdebug (fn, " %c ", data[i]);
            _PDMdebug ("", "\n");
            sprintf (val, "%s", data);
            _PDMdebug (fn, "double val [%s]\n", val);
         } else {
            sprintf (val, "%f", 0);
            _PDMdebug (fn, "double val [%s]\n", val);
         }
         return (PDM_S_SUCCESS);
        }
   else if (!strncmp (wazit, "doub", 4)){
/*
         sprintf (val, "%f", atof(data));
         _PDMdebug (fn, "double val [%s]\n", val);
*/
         if (data[0] != NULL) {
            for (i=0; i< (strlen (data)); i++) 
            _PDMdebug (fn, " %c ", data[i]);
            _PDMdebug ("", "\n");
            sprintf (val, "%s", data);
            _PDMdebug (fn, "double val [%s]\n", val);
         } else {
            sprintf (val, "%d", 0);
            _PDMdebug (fn, "double val [%s]\n", val);
         }
          
         return (PDM_S_SUCCESS);
         }
   else if (!strncmp (wazit, "time", 4)){
        status = NFMascii_to_timestamp_format (data, date) ;
          if (status != NFM_S_SUCCESS) {
              _PDMdebug (fn, "ascii to timestamp:status = <0x%.8x>\n", status);
              return (status) ;
                  }
         sprintf (val, "TIMESTAMP '%s'", date);
         _PDMdebug (fn, "val [%s]\n", val);
         return (PDM_S_SUCCESS);
         }
   else {
  _PDMdebug (fn, "unknown data type ...%s\n", attr);
   return (-1);
     }
/*
  _PDMdebug ("EXIT", "%s\n", fn);
   return (PDM_S_SUCCESS);
*/
 } 



int PDMdelete_parametric_parts (attr_list, data_list, type, ret_bufr)
MEMptr		attr_list;
MEMptr		data_list;
MEMptr		*ret_bufr;
char		*type;
{
	char		*fn = "PDMdelete_parametric_parts";
	char		**column_ptr;
	char		**data;
	char		**ret_data;
	int		i, nxi;
        char		setindicator[5];
	int		cat_no = -1;
	int		i_itemno = -1;
	int		i_fileno = -1;
	int		i_revision = -1;
	int		i_itemname = -1;
	int		i_itemdesc = -1;
	int		i_setindicator = -1;
	char		*sql_str;
	int 		PDMinsert_rows_to_parm_cat ();
        int		_PDMcreate_parm_ret_buffer ();

	_PDMdebug("ENTER", "%s\n", fn);
	_PDMdebug(fn, "type [%s]\n", type);


     status = MEMbuild_array(data_list);
     if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

/* Modifications to eliminate need for attr bufr ... MaC 111293..
     status = MEMbuild_array(attr_list);
     if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
        return(PDM_E_BUILD_ARRAY);
	}
     status = _PDMcreate_parm_ret_buffer (attr_list, ret_bufr);
     if(status != PDM_S_SUCCESS) {
       _PDMdebug (fn,"_PDMcreate_parm_ret_buffer failed : status %d\n", status);
        return (status);
	}
...*/


     status = _PDMcreate_parm_ret_buffer (ret_bufr);
     if(status != PDM_S_SUCCESS) {
       _PDMdebug (fn,"_PDMcreate_parm_ret_buffer failed : status %d\n", status);
        return (status);
	}

     status = PDMquery_catalogno(PDMexec->catalog, &cat_no);
     if(status != PDM_S_SUCCESS) {
       _PDMdebug (fn,"PDMquery_catalogno failed : status %d\n", status);
        return (status);
	}

     _PDMdebug (fn, "catalogno[%d]\n", cat_no);

     status = MEMbuild_array(*ret_bufr);
     if ( (status != MEM_S_SUCCESS) && (status != MEM_E_NULL_LIST) ) {
          _PDMdebug (fn,"MEMbuild_array of ret_bufr failed : status %d\n",
                                                                 status);
           return(status);
        }

     if(PDMdebug_on) {
        MEMprint_buffer("data_list",data_list,PDM_DEBUG_FILE);
     }

     column_ptr = (char **) data_list->column_ptr;
     data = (char **) data_list->data_ptr;
     ret_data = (char **) (*ret_bufr)->data_ptr;
     i_itemno = -1; i_fileno = -1;
     i_itemname = -1; i_revision = -1;  i_itemdesc = -1;
     for(i=0; i<data_list->columns; i++) {
       	if(!strcmp(column_ptr[i],"n_itemno")) i_itemno = i;
/*        else if(!strcmp(column_ptr[i],"n_fileno"))  i_fileno = i;*/
        else if(!strcmp(column_ptr[i],"n_itemrev"))  i_revision = i;
        else if(!strcmp(column_ptr[i],"n_itemname"))  i_itemname = i;
        else if(!strcmp(column_ptr[i],"n_itemdesc"))  i_itemdesc = i;
        else if(!strcmp(column_ptr[i],"n_setindicator"))  i_setindicator = i;
     }

    if(i_itemno == -1 /*|| i_fileno == -1 */
      || i_revision == -1 || i_itemname == -1 || i_itemdesc == -1 ){
       _PDMdebug (fn, "failed to set offsets in data_list\n");
	return(PDM_E_BUFFER_FORMAT);
	}

     sql_str = (char *) malloc ((data_list -> rows) *10 + 512);
     if (! sql_str) {
        _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
        return (NFM_E_MALLOC);
        }
     sql_str[0] = '\0';

    /*if(!strcmp(type, "P")) */
   /* Added to support new parametric external catalog type MaC 010194*/
    if ( (!strcmp(type, "P")) || (!strcmp(type, "PXT")) ) {

      for (i = 0; i < data_list->rows; i++) {
      nxi = i * data_list->columns;
      _PDMdebug (fn, "Deleting [%s].[%s]...\n",
                      PDMexec->catalog, data[nxi + i_itemname]);
/* Fix to delete parametric assy. First to check if it is an assy,
   if it is, then to delete entries in the cit and then delete. MaC 070293*/

/*******************/

       setindicator[0] = '\0';
/* Assembly indicator is there already in the data buffer...
       status = PDMquery_assembly_ind(PDMexec->catalog, 
                                         data[nxi + i_itemname], 
                                         data[nxi + i_revision],
                                         setindicator);
        if(status != PDM_S_SUCCESS) {
          _PDMdebug (fn,"PDMquery_assembly_ind failed : 0x%.8x\n", status);
           return (status);
	   }
*/
         strcpy (setindicator, data[nxi + i_setindicator]);
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
         if ((!strcmp (setindicator, "Y")) || (!strcmp (setindicator, "y")))
*/
         if ((!strcmp (setindicator, "Y")) || 
             (!strcmp (setindicator, "y")) ||
             (!strcmp (setindicator, "A")) ||
             (!strcmp (setindicator, "a")) ) {

          _PDMdebug (fn, "[%s].[%s] is a set, deleting entries in pdmcit....\n",
                      PDMexec->catalog, data[nxi + i_itemname]);
          status = PDMdelete_parm_assy_entries_from_CIT (cat_no, 
                                                 atol(data[nxi + i_itemno]));
          if(status != PDM_S_SUCCESS) {
              _PDMdebug (fn,"PDMdelete_cit_entries failed : 0x%.8x\n", status);
              return (status);
	      }
           }


/*******************/

      sprintf(sql_str, "%s %s %s %d",
      "DELETE FROM ", PDMexec->catalog, " WHERE n_itemno = ", 
             atol(data[nxi + i_itemno]));
      _PDMdebug ("delete_str", "%s\n", sql_str);
      status = SQLstmt(sql_str);
      if (status != SQL_S_SUCCESS) {
        _PDMdebug (fn, "SQLstmt failed for %s status %d\n", 
                             data[nxi + i_itemno], status);
        free (sql_str);
       _PDMadd_errrow_to_retbufr ( data[nxi + i_itemname], 
                   data[nxi + i_revision], data[nxi + i_itemdesc],
                   status, ret_bufr );
            }
         }
     if(PDMdebug_on) {
	     MEMprint_buffer("ret_bufr", *ret_bufr, PDM_DEBUG_FILE);
         }
       }
    else if(!strcmp(type, "CID")) {
        for (i = 0; i < data_list->rows; i++) {
         nxi = i * data_list->columns;
         sprintf(sql_str, "%s %s %s %d",
            "DELETE FROM ", PDMexec->catalog,
            " WHERE n_itemno = ", atol(data[nxi + i_itemno]));
         status = SQLstmt(sql_str);
         if (status != SQL_S_SUCCESS) {
        _PDMdebug (fn, "SQLstmt failed for %s status %d\n", 
                   data[nxi + i_itemno], status);
       _PDMadd_errrow_to_retbufr ( data[nxi + i_itemname], 
                   data[nxi + i_revision], data[nxi + i_itemdesc],
                   status, ret_bufr );
                }
              }
           }
 free (sql_str);
_PDMdebug("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}


int	_PDMcreate_parm_ret_buffer (ret_bufr)
MEMptr	*ret_bufr;
{
char		*fn = "_PDMcreate_parm_ret_buffer";

_PDMdebug("ENTER", "%s\n", fn);
   
          status = MEMopen(ret_bufr, 1024);
           if(status != MEM_S_SUCCESS) {
             _PDMdebug (fn, "MEMopen failed status = %d",status);
             return(PDM_E_OPEN_BUFFER);
           }

/* Eliminating need for attr_bufr...

	status = MEMbuild_array(attr_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed for attr_list: status %d\n", 
									status);
	   return(PDM_E_BUILD_ARRAY);
	}

	attr = (char **) attr_list->data_ptr;

         status = MEMwrite_format((*ret_bufr), 
                               attr[(attr_list->columns *1) + 0], 
                               attr[(attr_list->columns *1) + 1]);
             if(status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
              return (status);
             }
          
          status = MEMwrite_format((*ret_bufr), 
                               attr[(attr_list->columns * 2) + 0], 
                               attr[(attr_list->columns * 2) + 1]);
             if(status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
              return (status);
             }
...MaC 111293 */
          
          status = MEMwrite_format((*ret_bufr), "n_itemname", "char(240)");
             if(status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
              return (status);
             }
          
          
          status = MEMwrite_format((*ret_bufr), "n_itemrev", "char(240)");
             if(status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
              return (status);
             }
          
          
          status = MEMwrite_format((*ret_bufr), "n_itemdesc", "char(240)");
             if(status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
              return (status);
             }
          
          status = MEMwrite_format((*ret_bufr), "status", "integer"); 
             if(status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
              return (status);
             }
_PDMdebug("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}


int       _PDMadd_errrow_to_retbufr (itemname, itemrev, itemdesc,
                                                          status, ret_bufr )
char	*itemname, *itemrev, *itemdesc;
long	 status;
MEMptr	 *ret_bufr;
{
char	*fn = "_PDMadd_errrow_to_retbufr";
char	mem_str[1024];

_PDMdebug("ENTER", "%s\n", fn);
        _PDMdebug (fn, "%s.%s.%s : status %d", itemname, itemrev, itemdesc,
                                  status);
        mem_str[0] = '\0';
        sprintf (mem_str, "%s\1%s\1%s\1%d\1", itemname, itemrev, itemdesc,
                                  status);
        _PDMdebug ("mem_str", "%s\n", mem_str);

         status = MEMwrite(*ret_bufr, mem_str);
         if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
           return(status);
           }

	status = MEMbuild_array(*ret_bufr);
        if ( (status != MEM_S_SUCCESS) && (status != MEM_E_NULL_LIST) ) {
          _PDMdebug (fn,"MEMbuild_array of ret_bufr failed : status %d\n",
                                                                 status);
           return(status);
        }

       if(PDMdebug_on) {
	     MEMprint_buffer("ret_bufr", *ret_bufr, PDM_DEBUG_FILE);
            }

_PDMdebug("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}

int PDMmove_parametric_parts_to_next_state (attr_list, data_list, 
                                                        type, ret_bufr)
MEMptr		attr_list;
MEMptr		data_list;
char		*type;
MEMptr		*ret_bufr;
{
   static char *fn = "PDMmove_parametric_parts_to_next_state";
    char      sql_str[1024];
    char      **data, **st_qry_data;
    char      **column_ptr;
    int	      i_stateno = 0, i_aclno = 0, i_itemno = 0, index = 0, i = 0;
    char      *out_str = NULL, prev_state[20];
    MEMptr    st_qry_buf = NULL;
    long      status = PDM_S_SUCCESS;
/*
    MEMptr    wflow_buf1 = NULL;
    MEMptr    wflow_buf4 = NULL;
*/


	_PDMdebug("ENTER", "%s\n", fn);
	_PDMdebug(fn, "type [%s]\n", type);

 	/* may have to load some PDM data here */

	status = MEMbuild_array(data_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

	status = MEMbuild_array(attr_list);
	if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
	   return(PDM_E_BUILD_ARRAY);
	}

/*
          if(PDMdebug_on) {
	     MEMprint_buffer("attr_list",attr_list,PDM_DEBUG_FILE);
	     MEMprint_buffer("data_list",data_list,PDM_DEBUG_FILE);
          }
*/


/* Eliminating the need for attr bufr from this fn...
         status = _PDMcreate_parm_ret_buffer (attr_list, ret_bufr);
         if(status != PDM_S_SUCCESS) {
           _PDMdebug (fn,"_PDMcreate_parm_ret_buffer failed : status %d\n", 
						status);
            return(status);
	    }
.......MaC 111293*/

         status = _PDMcreate_parm_ret_buffer (ret_bufr);
         if(status != PDM_S_SUCCESS) {
           _PDMdebug (fn,"_PDMcreate_parm_ret_buffer failed : status %d\n", 
						status);
            return(status);
	    }

	status = MEMbuild_array(*ret_bufr);
        if ( (status != MEM_S_SUCCESS) && (status != MEM_E_NULL_LIST) ) {
          _PDMdebug (fn,"MEMbuild_array of ret_bufr failed : status %d\n",
                                                                 status);
           return(status);
        }

	column_ptr = (char **) data_list->column_ptr;
	data = (char **) data_list->data_ptr;
	i_itemno = -1; i_stateno = -1; i_aclno = -1;
	for(i=0; i<data_list->columns; i++) {
		if(!strcmp(column_ptr[i],"n_itemno")) i_itemno = i;
		if(!strcmp(column_ptr[i],"n_stateno")) i_stateno = i;
		if(!strcmp(column_ptr[i],"n_aclno"))  i_aclno = i;
	}
	if(i_itemno == -1 || i_stateno == -1 || i_aclno == -1) {
       _PDMdebug (fn, "failed to set offsets in data_list\n");
	return(PDM_E_BUFFER_FORMAT);
	}
        sprintf (sql_str,
             "SELECT  %s FROM %s WHERE n_itemno = %s ",
             "n_stateno",
             PDMexec->catalog,
             data[i_itemno]);
        
           _PDMdebug ("sql_str", "%s\n", sql_str);

           status = SQLquery(sql_str,&st_qry_buf,512);
           if (status != SQL_S_SUCCESS) {
             MEMclose(&st_qry_buf);
               _PDMdebug(fn, "SQLstmt : status %d\n", status);
               free (out_str);
               return(PDM_E_SQL_STMT);
           }
        
           status = MEMbuild_array(st_qry_buf);
           if(status != MEM_S_SUCCESS) {
              MEMclose(&st_qry_buf);
              _PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
               free (out_str);
              return(PDM_E_BUILD_ARRAY);
           }

           if(PDMdebug_on) {
	         MEMprint_buffer("st_qry_buf", st_qry_buf,PDM_DEBUG_FILE);
             }

           st_qry_data = (char **)st_qry_buf->data_ptr;
           strcpy (prev_state, st_qry_data[0]);
          _PDMdebug(fn, "prev_state = %s \n", prev_state);
        
/*

        out_str = (char *) malloc (((data_list) -> row_size) *10);
        if (! out_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

   status = _PDMget_uniq_no_list (data_list, i_aclno, out_str);
   if(status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n", "_PDMget_uniq_no_list ", status);
                free (out_str);
                return(status);
                }
     
   _PDMdebug (fn, "out_str[%s]\n", out_str);
*/

/* Second query to get workflowno and workflowname from nfmacls
     The data from this query, hopefully, will be cached */

/*
sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s ",
     "n_workflowno",
     "NFMACLS",
     out_str);

   _PDMdebug ("sql_str", "%s\n", sql_str);
   status = SQLquery(sql_str,&st_qry_buf,512);
   if (status != SQL_S_SUCCESS) {
     MEMclose(&st_qry_buf);
       _PDMdebug(fn, "SQLstmt : status %d\n", status);
       free (out_str);
       return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(st_qry_buf);
   if(status != MEM_S_SUCCESS) {
      MEMclose(&st_qry_buf);
      _PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
       free (out_str);
      return(PDM_E_BUILD_ARRAY);
   }
   if(PDMdebug_on) {
	 MEMprint_buffer("st_qry_buf", st_qry_buf,PDM_DEBUG_FILE);
     }
   st_qry_data = (char **)st_qry_buf->data_ptr;
   workflowno = atol(st_qry_data[0]);
  _PDMdebug(fn, "workflowno=%d \n", workflowno);
   MEMclose (&st_qry_buf);
   free (out_str);

   for (col = 0; col < data_list->rows; ++col) {
    index = data_list->columns * col;
    status = _PDMget_to_state (workflowno, data[index + i_stateno], tostate);
     if(status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "%s %d \n", "_PDMget_to_state", status);
      return(status);
     }
     
     status = MEMwrite_data(data_list, tostate, col+1, i_stateno + 1);
     if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMwrite_data failed : status %d\n", status);
        return(PDM_E_WRITE_COLUMN);
        }
*/

     /* insert statement */ 
/*

    sprintf (sql_str, 
      "UPDATE %s SET n_stateno = %s, n_prevstateno = %s WHERE n_itemno = %s",
         PDMexec->catalog, tostate, data[index + i_stateno], data[index]);
     _PDMdebug ("sql_str", "%s\n", sql_str);
     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS) {
        _PDMadd_errrow_to_retbufr ( data[index + 1], 
                   data[index + 2], data[index + 3],
                   status, ret_bufr );
        _PDMdebug (fn, "SQLstmt %d\n", status);
        }
      }
*/

    sprintf (sql_str, 
      "UPDATE %s SET n_stateno = %s, n_prevstateno = %s WHERE n_itemno = %s",
         PDMexec->catalog, data[i_stateno], prev_state, data[i_itemno]);
     _PDMdebug ("sql_str", "%s\n", sql_str);
     status = SQLstmt (sql_str);
     if (status != SQL_S_SUCCESS) {
        _PDMadd_errrow_to_retbufr ( data[index + 1], 
                   data[index + 2], data[index + 3],
                   status, ret_bufr );
        _PDMdebug (fn, "SQLstmt %d\n", status);
        }

_PDMdebug ("ENTER", "%s\n", fn);
return (PDM_S_SUCCESS);
}

int	_PDMget_to_state (workflowno, fromstate, tostate)
int	workflowno;
char	*fromstate, *tostate;
{
  char		*fn = "_PDMget_to_state";
  MEMptr	wflow_buf4 = NULL;
  char		**wflow_data4;
  char		sql_str[1024];

  _PDMdebug ("ENTER", "%s\n", fn);
  _PDMdebug(fn, "workflowno[%d], fromstate[%s]\n", workflowno, fromstate);

   sprintf (sql_str,
   "SELECT %s FROM %s WHERE  %s = %d AND ( %s  %s )",
        "n_transitionno, n_transitionname, n_tostate",
        "NFMTRANSITIONS",
        "n_workflowno", workflowno,
        "n_fromstate = 0 OR n_fromstate = 1 OR n_fromstate = ", fromstate);

   status = SQLquery(sql_str,&wflow_buf4,512);
   if (status != SQL_S_SUCCESS) {
        MEMclose(&wflow_buf4);
     if (status == SQL_I_NO_ROWS_FOUND) {
        _PDMdebug (fn," No transition possible \n");
        return (PDM_E_NO_TRANSITIONS);
         }
      else {
     _PDMdebug(fn,"SQLstmt: status %d\n", status);
        return(PDM_E_SQL_STMT);
           }
         }

      status = MEMbuild_array(wflow_buf4);
      if(status != MEM_S_SUCCESS) {
         MEMclose(&wflow_buf4);
         _PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
         return(PDM_E_BUILD_ARRAY);
         }
   if(PDMdebug_on) {
	 MEMprint_buffer("wflow_buf4", wflow_buf4, PDM_DEBUG_FILE);
     }
     wflow_data4 = (char **)wflow_buf4->data_ptr;
     strcpy (tostate, wflow_data4[0]);

     _PDMdebug(fn, "tostate[%s]\n", tostate);
       return(PDM_S_SUCCESS);
}

int _PDMget_uniq_no_list (data_list, x, out_list)
int	x; /* offset to n_aclno in the data_list */
MEMptr	data_list;
char	*out_list;
{
	char		*fn = "_PDMget_uniq_no_list";
	int		i, j, index, sec_index, found_match;
	char		**data;
	char		col[100];
	
    _PDMdebug ("ENTER", "%s\n", fn);


    status = MEMbuild_array(data_list);
    if(status != MEM_S_SUCCESS) {
     _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
      return(PDM_E_BUILD_ARRAY);
	}
    data = (char **) data_list->data_ptr;
    sprintf (col, " or n_aclno = ");
    out_list[0] = '\0';
    sprintf (out_list, "( n_aclno = ");
    strcat (out_list, data[x]);
    for (i = 1; i < data_list->rows; ++i) {
    index = data_list->columns * i;
    found_match = -1;
     _PDMdebug (fn, "Checking ACL # %s...\n", data[index + x]);
     for (j = 0; j < i; ++j) {
     sec_index = data_list->columns * j;
      if ( (atol (data[index + x]) ) == (atol (data[sec_index + x]) ) ) {
           found_match = 1;
           break;
               }
             }
      if (found_match != 1){
           strcat (out_list, col);
           strcat (out_list, data[index + x]);
           found_match = -1;
            }
       }
     strcat (out_list, " )");
     _PDMdebug ("out_list", "%s\n", out_list);

_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}

int PDMvalidate_parametric_part ()
{
	char		*fn = "PDMvalidate_parametric_part";
	MEMptr		buf = NULL;
	char		sql_str[1024];

 _PDMdebug("ENTER", "%s\n", fn);

_PDMdebug (fn, "verifying part[%s.%s] in catalog[%s]\n", 
                    PDMexec->part_num, PDMexec->revision, PDMexec->catalog);

 sprintf (sql_str, 
    "SELECT n_itemno FROM %s WHERE n_itemname = '%s' AND n_itemrev = '%s'",
                       PDMexec->catalog, PDMexec->part_num, PDMexec->revision);

 status = SQLquery(sql_str, &buf, 512);
 if (status == SQL_S_SUCCESS) {
    MEMclose (&buf);
    _PDMdebug(fn, "SQLstmt : status %d\n", status);
    _PDMdebug(fn, "the part [%s.%s] is not unique....\n", 
                                PDMexec->part_num, PDMexec->revision);
    return(PDM_E_PART_EXISTS);
      }

 if (status != SQL_I_NO_ROWS_FOUND) {
    MEMclose (&buf);
    _PDMdebug(fn, "SQLstmt : status %d\n", status);
    return(PDM_E_SQL_STMT);
      }

 MEMclose (&buf);
 _PDMdebug(fn, "the part [%s.%s] *is* unique....\n",
                                PDMexec->part_num, PDMexec->revision);
 _PDMdebug("EXIT", "%s\n", fn);
 return(PDM_S_SUCCESS);
}



int PDMdelete_parm_assy_entries_from_CIT (cat_no, item_no)
int	cat_no, item_no;
{
	char		*fn = "PDMdelete_parm_assy_entries_from_CIT";
	MEMptr		cit_bufr = NULL;
	char		sql_str[1024];
	char		y_cat[21];
        char		**data, **column;
        int		i, index;
        

 _PDMdebug("ENTER", "%s\n", fn);

_PDMdebug (fn, "deleting cit entries for part[%d.%d] in cit tables\n", 
                    cat_no, item_no);

  y_cat[0] = '\0';
  status =  PDMget_dyntable_for_catalog(PDMexec->catalog, y_cat);
  if(status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "%s %d \n", "PDMget_dyntable_for_catalog ", status);
      return(status);
      }

  _PDMdebug (fn, "dyn_cat[%s]\n", y_cat);

  status = PDMdelete_pdm_entries(cat_no, item_no, &cit_bufr);
  if(status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "%s %d \n", "PDMdelete_pdm_entries ", status);
      return(status);
      }


  status = MEMbuild_array (cit_bufr);
  if(status != MEM_S_SUCCESS) {
     _PDMdebug (fn,"MEMbuild_array failed : status %d\n", status);
      return(PDM_E_BUILD_ARRAY);
     }


   if(PDMdebug_on) 
	     MEMprint_buffer("list of pdc nos", cit_bufr, PDM_DEBUG_FILE);
    
   column = (char **) cit_bufr->column_ptr;
   data = (char **) cit_bufr->data_ptr;
   for(i=0; i<cit_bufr->rows; i++) {
     index = i * cit_bufr->columns;
     sprintf (sql_str, "DELETE FROM %s WHERE p_pdcno = %s ",
                                           y_cat, data[index + 1]);
     status = SQLstmt(sql_str);
     if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
        _PDMdebug (fn, "Delete from %s failed 0x%.8x\n", y_cat, status);
        return(PDM_E_SQL_STMT);
        }
     }
     
    sprintf(sql_str,
       "DELETE FROM NFMSETCIT WHERE n_pcatalogno = %d AND n_pitemno = %d ",
          cat_no, item_no);
    status = SQLstmt(sql_str);
    if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
        _PDMdebug (fn, "Delete from nfmsetcit failed 0x%.8x\n", status);
            return(PDM_E_SQL_STMT);
          }


  MEMclose (&cit_bufr);

 _PDMdebug("EXIT", "%s\n", fn);
 return(PDM_S_SUCCESS);
}

