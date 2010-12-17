#include                <stdio.h>
#include                "SQLerrordef.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "NFMapi.h"
#include                "NFMschema.h"
#include                "MEMstruct.h"
#include                "PDMdbs_err.h"
#include                "PDUerror.h"
#include                "PDMproto.h"

#include                "PDMbom_strct.h"
static long             status;
extern          int             PDMdebug_on;
extern          char    PDM_DEBUG_FILE[];
extern PDMexec_ptr PDMexec;

/*
         return the template definition "pdmbomcontent"
         attr_bufr is NFM modify buffer type
*/

int PDMget_bom_attrs (attr_bufr, data_bufr)
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
{
        char		*fn = "PDMget_bom_attrs";
        MEMptr          tmp_bufr = NULL;
        MEMptr          qry_bufr = NULL;
        /*char		**q_data, d_data;*/
        char		**q_attr, **d_attr;
        int		col, d, col_index;
	int		a_catno, seq_no;
        char		sql_str[1024];
        char		*mem_str;

        PDMdebug("ENTER PDMget_bom_attrs \n");
        sql_str[0] = '\0';
   sprintf (sql_str, "%s %s %s %s %s %s %s %s", 
"SELECT n_attrno, n_name, nfmattributes.n_tableno, n_synonym, ", 
"n_datatype, n_seqno, n_read, n_write, n_update, n_delete, ", 
"n_null, n_checkin, n_checkout, ", 
"n_application, n_lattrno, n_jointable, n_joinattrno ", 
"FROM nfmattributes, nfmtables ", 
"WHERE nfmtables.n_tablename = 'bom_template' ", 
"AND nfmtables.n_tabletype = 't_appltable' ", 
"AND nfmattributes.n_tableno = nfmtables.n_tableno ");

  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (PDM_E_BOMREQATTR_NOT_FOUND);
  }

  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  q_attr = (char **) qry_bufr->data_ptr;
  a_catno = atol (q_attr[2]);
  seq_no = qry_bufr->rows;
  _PDMdebug (fn, "acatno[%d]\n", a_catno);
    
    mem_str = (char *) malloc (((qry_bufr) -> rows * 10) *10 + 512);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str[0] ='\0';

    sprintf (mem_str, 
"0\1n_level\1%d\1Level Number\1integer\1%d\1Y\1N\1N\1N\1Y\1\1\1PDM\1\1\1\1", 
      a_catno, (seq_no + 1));
     
    status = MEMwrite(qry_bufr, mem_str);
    if(status != MEM_S_SUCCESS) {
       free (mem_str);
       _PDMdebug (fn, "MEMwrite (n_level) failed status = %d\n", status);
       return(status);
    }
      

    sprintf (mem_str, 
"0\1n_pcatalogno\1%d\1Parent Ctno\1integer\1%d\1Y\1N\1N\1N\1Y\1\1\1PDM\1\1\1\1", 
      a_catno, (seq_no + 2));
     
    status = MEMwrite(qry_bufr, mem_str);
    if(status != MEM_S_SUCCESS) {
      free (mem_str);
      _PDMdebug (fn, "MEMwrite (n_pcatalogno) failed status = %d\n", status);
      return(status);
    }
      

    sprintf (mem_str, 
 "0\1n_pitemno\1%d\1Parent Itemno\1integer\1%d\1Y\1N\1N\1N\1Y\1\1\1PDM\1\1\1\1", 
      a_catno, (seq_no + 3));
     
    status = MEMwrite(qry_bufr, mem_str);
    if(status != MEM_S_SUCCESS) {
       free (mem_str);
       _PDMdebug (fn, "MEMwrite (n_pitemno) failed status = %d\n", status);
       return(status);
    }
      

    sprintf (mem_str, 
 "0\1n_catalogno\1%d\1Catalogno\1integer\1%d\1Y\1N\1N\1N\1Y\1\1\1PDM\1\1\1\1", 
      a_catno, (seq_no + 4));
     
    status = MEMwrite(qry_bufr, mem_str);
    if(status != MEM_S_SUCCESS) {
       free (mem_str);
       _PDMdebug (fn, "MEMwrite (n_catalogno) failed status = %d\n", status);
       return(status);
    }
      

    sprintf (mem_str, 
 "0\1n_itemno\1%d\1Itemno\1integer\1%d\1Y\1N\1N\1N\1Y\1\1\1PDM\1\1\1\1", 
      a_catno, (seq_no + 5));
     
    status = MEMwrite(qry_bufr, mem_str);
    if(status != MEM_S_SUCCESS) {
       free (mem_str);
       _PDMdebug (fn, "MEMwrite (n_itemno) failed status = %d\n", status);
       return(status);
    }

    sprintf (mem_str, 
"0\1p_explode\1%d\1Explode Indicator\1char(5)\1%d\1Y\1N\1N\1N\1Y\1\1\1PDM\1\1\1\1", 
      a_catno, (seq_no + 6));
     
    status = MEMwrite(qry_bufr, mem_str);
    if(status != MEM_S_SUCCESS) {
       free (mem_str);
       _PDMdebug (fn, "MEMwrite (n_level) failed status = %d\n", status);
       return(status);
    }
      

    sprintf (mem_str, 
"0\1p_citno\1%d\1CIT no\1integer\1%d\1Y\1N\1N\1N\1Y\1\1\1PDM\1\1\1\1", 
      a_catno, (seq_no + 7));
     
    status = MEMwrite(qry_bufr, mem_str);
    if(status != MEM_S_SUCCESS) {
       free (mem_str);
       _PDMdebug (fn, "MEMwrite (n_level) failed status = %d\n", status);
       return(status);
    }
      

    sprintf (mem_str, 
"0\1p_rowno\1%d\1Row Number\1integer\1%d\1Y\1N\1N\1N\1Y\1\1\1PDM\1\1\1\1", 
      a_catno, (seq_no + 8));
     
    status = MEMwrite(qry_bufr, mem_str);
    if(status != MEM_S_SUCCESS) {
       free (mem_str);
       _PDMdebug (fn, "MEMwrite (n_level) failed status = %d\n", status);
       return(status);
    }
      
      

   status = MEMbuild_array (qry_bufr);
   if (status != MEM_S_SUCCESS) {
       free (mem_str);
     MEMclose (&qry_bufr);
     _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
     return (NFM_E_MEM);
   }
 
  if (PDMdebug_on) {
    MEMprint_buffer("qry_bufr from query", qry_bufr, PDM_DEBUG_FILE);
  }

  q_attr = (char **) qry_bufr->data_ptr;
  status = MEMopen(&tmp_bufr, 1024);
   if(status != MEM_S_SUCCESS) {
      free (mem_str);
      MEMclose(&qry_bufr);
      _PDMdebug (fn, "MEMopen failed status %d\n", status);
      return(PDM_E_OPEN_BUFFER);
   }
   
    for (col = 0; col < qry_bufr->rows; col++) {
    col_index = col * qry_bufr->columns;
    _PDMdebug (fn, "MEMwriting: attr[%s], type[%s]\n", 
                                  q_attr[col_index + 1], 
                                     q_attr[col_index + 4]);
     status = MEMwrite_format (tmp_bufr, 
                                  q_attr[col_index + 1], 
                                     q_attr[col_index + 4]);
        if(status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
           free (mem_str);
           MEMclose(&qry_bufr);
           MEMclose(&tmp_bufr);
           return(PDM_E_WRITE_FORMAT);
        }
     }
  status = MEMbuild_array (tmp_bufr);
  if (status != MEM_S_SUCCESS) {
    free (mem_str);
    MEMclose (&qry_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }
   

    mem_str[0] ='\0';

  d_attr = (char **) qry_bufr->data_ptr;
    for (d = 0; d < tmp_bufr->columns; d++) {
    /*d_index = d * tmp_bufr->columns;*/
    strcat (mem_str, "\1");
     }

   _PDMdebug ("mem_str", "%s\n", mem_str);
 
     
         status = MEMwrite(tmp_bufr, mem_str);
         if(status != MEM_S_SUCCESS) {
            free (mem_str);
            MEMclose(&qry_bufr);
            MEMclose(&tmp_bufr);
           _PDMdebug (fn, "MEMwrite failed status = %d\n", status);
           return(status);
           }
      
      *data_bufr = tmp_bufr;
      *attr_bufr = qry_bufr;

 free (mem_str);

_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}


/* alg:
- given a list of catalogs; get a list of mapped bom attrs sorted by catno
- given the list of mapped cat attrnos, get a list of attr_names
- create a linked list of structures which contain a catalogname, 
  dynamic_cat associated, and a constructed sql_qry string
    o the query string is constructed using the  attributes for whom
      we require values to insert into the bomtables
    o we query the values from catalog, f_cat and dyn cat(if it exists)
      for the list of mapped/unmapped attrs.
*/
int PDMget_bom_map_attrs (cat_list, attr_bufr, data_bufr, 
                                 link_head, link_end, map_bufr, cattr_bufr)
char		*cat_list;
MEMptr          *attr_bufr;
MEMptr          *cattr_bufr;
MEMptr          *data_bufr;
MEMptr          *map_bufr;
struct PDMbom_member		**link_head, **link_end;
{
        char				*fn = "PDMget_bom_map_attrs";
        MEMptr			        qry_bufr = NULL;
        MEMptr			        cat_bufr = NULL;
        MEMptr			        qry1_bufr = NULL;
        MEMptr			        tmp_bufr = NULL;
        char				**attr;
        char				**attr1;
        int				col, attr_index;
	int				x, y, duplicate;
	int				no_mapped_attrs;
	int				found_map;
	int				attr_index1, col1, comma;
        char				val[128];
        char				dyn_tabname[21];
        int				dyn_tabno = -1;
        char				*sql_str;
        char				*bom_attrs;
        char				*cat_attrs;
        char				*cat_attrs1;
        char				*dyn_cat_list;
	struct PDMbom_member		*cur_mem = NULL;
	struct PDMbom_member		*search_mem = NULL;
	struct PDMbom_member		*head = NULL, *end = NULL;

        PDMdebug("ENTER PDMget_bom_map_attrs  \n");

  status = MEMbuild_array (*attr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (*attr_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (*data_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (*data_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }
   
    _PDMdebug (fn, "head->cat_name[%s]\n", (*link_head)->cat_name);
    
        head = *link_head;
        end = *link_end;
    _PDMdebug (fn, "head->cat_name[%s]\n", head->cat_name);
 

    sql_str = (char *) malloc (((*attr_bufr)->rows) * 20 + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
          }
    sql_str[0] = '\0';

    dyn_cat_list = (char *) malloc (((*attr_bufr)->row_size) * 20 + 512);
    if (! dyn_cat_list) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    dyn_cat_list[0] = '\0';

    cat_list = (char *) malloc (((*attr_bufr)->row_size) * 20 + 512);
    if (! cat_list) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    cat_list[0] = '\0';


    bom_attrs = (char *) malloc (((*attr_bufr)->row_size) + 512);
        if (! bom_attrs) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    bom_attrs[0] = '\0';

    cat_attrs = (char *) malloc (((*attr_bufr)->row_size) + 512);
        if (! cat_attrs) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    cat_attrs[0] = '\0';


  attr = (char **) (*attr_bufr)->data_ptr;

     /* Preparing catalognos list...*/

 sprintf (cat_list, " %d", head->cat_no);

/* fix to remove the duplicate catnos */

 for (x=0, cur_mem = head->next; cur_mem != NULL; 
                     x++, cur_mem = cur_mem->next) {
   _PDMdebug ("Checking catno ", "%d: x = %d\n", cur_mem->cat_no, x);
   duplicate = 0;
   for (y=0, search_mem = head->next; y <  x;
             y++, search_mem = search_mem->next) {
       if (cur_mem->cat_no == search_mem->cat_no) {
            _PDMdebug ("catno already added", "%d\n", search_mem->cat_no);
            duplicate = 1;
            break;
          }
       }
   if ( (duplicate != 1) || (x == 0) ) {
   sprintf (val, ", %d ", cur_mem->cat_no);
   strcat (cat_list, val);
       }
   _PDMdebug ("cat_list", "%s\n", cat_list);
      }
   _PDMdebug ("cat_list", "%s\n", cat_list);

   status = _PDMbom_load_cattype_in_ll (cat_list, link_head);
   if (status != PDM_S_SUCCESS ) {
    if (sql_str) free (sql_str);
    if (bom_attrs) free (bom_attrs);
    if (cat_list) free (cat_list);
    if (cat_attrs) free (cat_attrs);
    if (dyn_cat_list) free (dyn_cat_list);
    _PDMdebug ( fn, "_PDMbom_load_cattype_in_ll 0x%.8x\n", status) ;
    return (status);
    }
    
   sprintf (bom_attrs, "%s", attr[0]);
   sprintf (cat_attrs, "  '%s'", attr[1]);
   for (col = 1; col < (*attr_bufr)->rows; col++) {
      attr_index = col * (*attr_bufr)->columns;
      strcat (bom_attrs, ", ");
      strcat (cat_attrs, ", '");
      strcat (bom_attrs, attr[attr_index + 0]);
      strcat (cat_attrs, attr[attr_index + 1]);
      strcat (cat_attrs, "' ");
        }
   _PDMdebug ("bom_attrs", "%s\n", bom_attrs);
   _PDMdebug ("cat_attrs", "%s\n", cat_attrs);
   

/* get a list of dynamic table names and nos */
/* modified to consider the fact that dyn tab names in
   nfmtables and pdmcatalogs can have different cases. MaC71293*/

/*
   sprintf (sql_str, "%s %s %s %s ( %s )" , 
              "SELECT p_dyntable, n_catalogno, n_tableno ", 
              "FROM  pdmcatalogs, nfmtables ", 
              "WHERE nfmtables.n_tablename = pdmcatalogs.p_dyntable AND ", 
              " n_catalogno in ", cat_list);
*/


   sprintf (sql_str, "%s %s ( %s )" , 
              "SELECT p_dyntable, n_catalogno FROM  pdmcatalogs ", 
              "WHERE n_catalogno in ", cat_list);

   status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
   if ( (status != SQL_S_SUCCESS ) &&
            (status != SQL_I_NO_ROWS_FOUND ) ) {
    free (sql_str);
    free (bom_attrs);
    free (cat_list);
    free (cat_attrs);
    free (dyn_cat_list);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
    }
    
    if (status == SQL_S_SUCCESS) {
    status = MEMbuild_array (qry_bufr);
    if (status != MEM_S_SUCCESS) {
      MEMclose (&qry_bufr);
      free (sql_str);
      free (bom_attrs);
      free (cat_attrs);
      free (dyn_cat_list);
      _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
      return (NFM_E_MEM);
      }

   if (PDMdebug_on) {
      MEMprint_buffer("list of dyn cats from query", qry_bufr, PDM_DEBUG_FILE);
       }

   attr = (char **) (qry_bufr)->data_ptr;

     /* Preparing dyn_catalognos list...*/

/*
   sprintf (dyn_cat_list, " %s ", attr[2]);
   for (col = 1; col < qry_bufr->rows; col++) {
      attr_index = col * qry_bufr->columns;
      strcat (dyn_cat_list, ", ");
      strcat (dyn_cat_list, attr[attr_index + 2]);
    }
   _PDMdebug ("dyn_cat_list", "%s\n", dyn_cat_list);
*/

/* loading dyn_catname and dyn_catno into the linked list */

   dyn_cat_list [0] = '\0';
   
   for (col = 0; col < qry_bufr->rows; col++) {
    attr_index = col * qry_bufr->columns;
    dyn_tabname [0] = '\0';
    PDMconvert_to_lower (attr[attr_index], dyn_tabname);
    status = PDMquery_table_no (dyn_tabname, &dyn_tabno);
    _PDMdebug (fn, "dyntab[%s] --> [%d]\n", dyn_tabname, dyn_tabno);
    if (col > 0) strcat (dyn_cat_list, ", ");       
    sprintf (val, "%d", dyn_tabno);
    strcat (dyn_cat_list, val);
    for (cur_mem = head; cur_mem != NULL; cur_mem = cur_mem->next) {
      if (atol (attr[attr_index + 1]) == cur_mem->cat_no) {
         cur_mem->dyn_cat_name[0] = '\0';
         strcpy (cur_mem->dyn_cat_name, attr[attr_index]);
         cur_mem->dyn_cat_no = dyn_tabno;
          }
        }
      }

    sprintf (sql_str, 
         "SELECT %s FROM %s WHERE %s ( %s ) AND %s ( %s, %s)", 
         " p_bomattrno, n_catalogno, p_mapattrno ", 
         " pdmbommap", 
         " p_bomattrno in ", 
         bom_attrs, 
         " n_catalogno in ", cat_list, dyn_cat_list);

   MEMclose (&qry_bufr);
   }
   else {
    /* No dynamic mapped */
   _PDMdebug (fn, "None of the catalogs have dynamic tables mapped \n");
   
/*
    sprintf (sql_str, 
"SELECT %s %s FROM %s WHERE %s AND ( %s ) AND ( %s )", 
" pdmbommap.p_bomattrno, pdmbommap.n_catalogno, pdmbommap.p_mapattrno, ", 
" nfmattributes.n_name ", 
" pdmbommap, nfmattributes ", 
" nfmattributes.n_attrno = pdmbommap.p_mapattrno", 
bom_attrs, cat_list);
*/

   
    sprintf (sql_str, 
         "SELECT %s FROM %s WHERE %s ( %s ) AND %s ( %s )", 
         " p_bomattrno, n_catalogno, p_mapattrno ", 
         " pdmbommap", 
         " p_bomattrno in ", 
         bom_attrs, 
         " n_catalogno in ", 
         cat_list);
   MEMclose (&qry_bufr);
       }

    /* Looking for BOMmapped attrs for catnos and dyncatnos */

   _PDMdebug ("sql_str", "%s\n", sql_str);
  

  status = SQLquery (sql_str, &qry_bufr, MEM_SIZE);
  if ( (status != SQL_S_SUCCESS ) &&
            (status != SQL_I_NO_ROWS_FOUND ) ) {
    free (sql_str);
    free (bom_attrs);
    free (cat_attrs);
    free (dyn_cat_list);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }

  if (status == SQL_S_SUCCESS ) {

   _PDMdebug (fn, "** Mapped attrs found **\n");

   no_mapped_attrs = 0;

  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    free (sql_str);
    free (bom_attrs);
    free (cat_attrs);
    free (dyn_cat_list);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

   if (PDMdebug_on) {
   MEMprint_buffer ("list of mapped attrs from query", 
                                         qry_bufr, PDM_DEBUG_FILE);
      }

    cat_attrs1 = (char *) malloc ((((*attr_bufr)->rows) * 10) + 512);
    if (! cat_attrs1) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    cat_attrs1[0] = '\0';


   attr1 = (char **) (*attr_bufr)->data_ptr;
   attr = (char **) (qry_bufr)->data_ptr;
   comma = 0; 
   for (col1 = 0; col1 < (*attr_bufr)->rows; col1++) {
      attr_index1 = col1 * (*attr_bufr)->columns;
      found_map = 0; 
      for (col = 0; col < qry_bufr->rows; col++) {
         attr_index = col * qry_bufr->columns;
         _PDMdebug (fn, "bom_attr[%d] <=> map_attr[%d]\n", 
                           atol (attr1[attr_index1 + 0]), 
                               atol (attr[attr_index + 0]));
         if (atol (attr1[attr_index1 + 0]) == 
                         atol (attr[attr_index + 0])) {
           if (comma == 1) strcat (cat_attrs1, " OR ");
             strcat (cat_attrs1, " n_attrno = ");
             strcat (cat_attrs1, attr[attr_index + 2]);
             comma = 1; 
             found_map = 1; 
           }
         }
         if (found_map == 0) {
          if (comma == 1) strcat (cat_attrs1, " OR ");
            strcat (cat_attrs1, " n_attrno = ");
            strcat (cat_attrs1, attr1[attr_index1 + 0]);
            comma = 1; 
            found_map = 0; 
          }
        }
      _PDMdebug ("cat_attrs1", "%s\n", cat_attrs1);

    sprintf (sql_str, "SELECT %s FROM %s WHERE ( %s ) ", 
            " n_attrno, n_tableno, n_name ", 
            " nfmattributes", 
            cat_attrs1);

     free (cat_attrs1);
     status = SQLquery (sql_str, &qry1_bufr, MEM_SIZE);
     if  (status != SQL_S_SUCCESS ) {
       free (sql_str);
       free (bom_attrs);
       free (cat_attrs);
       free (dyn_cat_list);
       _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
       return (status);
      }

  
      status = MEMbuild_array (qry1_bufr);
      if (status != MEM_S_SUCCESS) {
        MEMclose (&qry_bufr);
        free (sql_str);
        free (bom_attrs);
        free (cat_attrs);
        free (dyn_cat_list);
        _PDMdebug ( fn, "MEMbuild_query (qry1_bufr) 0x%.8x\n", NFM_E_MEM );
        return (NFM_E_MEM);
      }

     if (PDMdebug_on) {
        MEMprint_buffer("qry1_bufr from query", qry1_bufr, PDM_DEBUG_FILE);
       }

      cat_attrs[0] = '\0';
      attr = (char **) (qry1_bufr)->data_ptr;
      sprintf (cat_attrs, " '%s' ", attr[2]);
      for (col = 0; col < qry1_bufr->rows; col++) {
        attr_index = col * qry1_bufr->columns;
        strcat (cat_attrs, ", '");
        strcat (cat_attrs, attr[attr_index + 2]);
        strcat (cat_attrs, "' ");
        }
     _PDMdebug ("cat_attrs with mapped attrs", "\n%s\n", cat_attrs);
     _PDMdebug ("str_length of dyn_cat_list ", "%d\n", strlen (dyn_cat_list));

    if (strlen (dyn_cat_list) > 0 ) {
     sprintf (sql_str, "SELECT %s FROM %s WHERE %s ( %s ) AND %s ( %s, %s )", 
            " n_attrno, n_tableno, n_name, n_datatype ", 
            " nfmattributes", 
            "n_name in ", cat_attrs, 
            "n_tableno in ", 
             cat_list, dyn_cat_list);
            }
     else {
     sprintf (sql_str, "SELECT %s FROM %s WHERE %s ( %s ) AND %s ( %s )", 
            " n_attrno, n_tableno, n_name, n_datatype ", 
            " nfmattributes", 
            "n_name in ", cat_attrs, 
            "n_tableno in ", 
             cat_list);
      }
    }

  else {
   _PDMdebug (fn, "No mapped attrs found....\n");
   no_mapped_attrs = 1;

     _PDMdebug ("cat_attrs sans mapped attrs", "\n%s\n", cat_attrs);

    if (strlen (dyn_cat_list) > 0 ) {
    sprintf (sql_str, "SELECT %s FROM %s WHERE %s ( %s ) AND %s ( %s, %s  ) ", 
            " n_attrno, n_tableno, n_name, n_datatype ", 
            " nfmattributes", 
            " n_name in ", 
            cat_attrs, 
            "n_tableno in ", 
             cat_list, dyn_cat_list);
            }
     else {
    sprintf (sql_str, "SELECT %s FROM %s WHERE %s ( %s ) AND %s ( %s ) ", 
            " n_attrno, n_tableno, n_name, n_datatype ", 
            " nfmattributes", 
            " n_name in ", 
            cat_attrs, 
            "n_tableno in ", 
             cat_list);
            }

    }
   _PDMdebug ("sql_str", "%s\n", sql_str);

/* add a query which gets a buffer with attrs for different catalogs
   in the assembly...*/

  status = SQLquery (sql_str, &cat_bufr, MEM_SIZE);
  if  (status != SQL_S_SUCCESS ) {
    MEMclose (&qry_bufr);
    MEMclose (&cat_bufr);
    if (sql_str) free (sql_str);
    if (bom_attrs) free (bom_attrs);
    if (cat_attrs) free (cat_attrs);
    if (dyn_cat_list) free (dyn_cat_list);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (status);
  }

  status = MEMbuild_array (cat_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry_bufr);
    MEMclose (&cat_bufr);
    free (sql_str);
    free (bom_attrs);
    free (cat_attrs);
    free (dyn_cat_list);
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("cat attr bufr", cat_bufr, PDM_DEBUG_FILE);
 }

   if (no_mapped_attrs == 1) {
      MEMclose (&qry_bufr);
      free (sql_str);
      free (bom_attrs);
      free (cat_attrs);
      free (dyn_cat_list);
/* pass back the buffer containing the cat attrs */
      *cattr_bufr = cat_bufr;
     _PDMdebug ("EXIT", "%s\n", fn);
       return (PDM_I_NO_ROWS_FOUND);
     }
   *cattr_bufr = qry1_bufr;
   status = _PDMcreate_map_bufr (qry_bufr, qry1_bufr, &tmp_bufr);
   if  (status != PDM_S_SUCCESS ) {
    MEMclose (&qry_bufr);
    MEMclose (&cat_bufr);
    MEMclose (&qry1_bufr);
    free (sql_str);
    free (bom_attrs);
    free (cat_attrs);
    free (dyn_cat_list);
    _PDMdebug ( fn, "_PDMcreate_map_bufr 0x%.8x\n", status) ;
    return (status);
  }

  /* fix added to support mapping system attributes:
     the third column in the new map bufr (tmp_bufr) will
     now have the bom attr name instead of the cat attr name.
     This means, that when the bom attr bufr is loaded
     in PDMload_bom_map_attr_bufr, the bom attr name will be 
     loaded instead of the cat attr name in the fifth col. */
 
   

 *map_bufr = tmp_bufr;
 *cattr_bufr = cat_bufr;

 if (PDMdebug_on) {
    MEMprint_buffer("map_bufr in get_bom_map_attrs", 
					*map_bufr, PDM_DEBUG_FILE);
           }

 MEMclose (&qry_bufr);
 free (sql_str);
 free (bom_attrs);
 free (cat_attrs);
 free (dyn_cat_list);

_PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}

int PDMget_new_bom_attr_bufr (attr_bufr, data_bufr, cattr_bufr, 
                                 link_head, link_end, attr1_bufr)
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
MEMptr          *attr1_bufr;
MEMptr          cattr_bufr;
struct PDMbom_member		**link_head, **link_end;
{
        char				*fn = "PDMget_new_bom_attr_bufr";
        MEMptr			        new_bufr = NULL;
        char				**q_data;
        char				**data;
	struct PDMbom_member		*cur_mem = NULL;
	struct PDMbom_member		*head = NULL, *end = NULL;

        PDMdebug("ENTER PDMget_new_bom_attr_bufr  \n");

    
  status = MEMbuild_array (cattr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (cattr_bufr) 0x%.8x\n", status );
    return (status);
  }

    
  status = MEMbuild_array (*attr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (Xattr_bufr) 0x%.8x\n", status );
    return (status);
  }

  status = MEMbuild_array (*data_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (data_bufr) 0x%.8x\n", status );
    return (status);
  }
    

   head = *link_head;
   end = *link_end;
  _PDMdebug (fn, "head->cat_name[%s]\n", head->cat_name);
   
  status = _PDMcreate_bom_attr_bufr (&new_bufr);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug ( fn, "_PDMcreate_bom_attr 0x%.8x\n", status );
    return (status);
  }
   
  status = _PDMload_bom_attr_bufr (attr_bufr, data_bufr, cattr_bufr, 
                                                        head, &new_bufr);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug ( fn, "_PDMload_bom_attr_bufr 0x%.8x\n", status );
    return (status);
  }
   
  q_data = (char **) new_bufr->data_ptr;
  data = (char **) (*data_bufr)->data_ptr;


 for (cur_mem = (*link_head); cur_mem != NULL; cur_mem = cur_mem->next) {
  _PDMdebug (fn, "cur_mem->cat_name[%s]\n", cur_mem->cat_name);
   /* prepare the qry/insert string.. */
   _PDMdebug (fn, 
        "Preparing sel/insert strs for cat [%s]\n", cur_mem->cat_name); 
    status = _PDMget_sel_str (&cur_mem->select_str, 
                                   &cur_mem->insert_str, 
                                   &cur_mem->dyn_select_str, 
                                   &cur_mem->dyn_insert_str, 
                                    cur_mem->cat_name, 
                                    cur_mem->cat_no, 
                                    cur_mem->dyn_cat_no, 
                                    new_bufr, cattr_bufr);
     if (status != PDM_S_SUCCESS) {
       MEMclose (&new_bufr);
       _PDMdebug ( fn, "_PDMget_sel_str 0x%.8x\n", status );
       return (status);
        }
    _PDMdebug ("sel_str", "%s\n", cur_mem->select_str);
    _PDMdebug ("insert_str", "%s\n", cur_mem->insert_str);
    _PDMdebug ("dyn_sel_str", "%s\n", cur_mem->dyn_select_str);
    _PDMdebug ("dyn_insert_str", "%s\n", cur_mem->dyn_insert_str);
   }
    *attr1_bufr = new_bufr;

_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}

int _PDMcreate_bom_attr_bufr (attr1_bufr)
MEMptr          *attr1_bufr;
{
	char		*fn = "_PDMcreate_bom_attr_bufr";

 _PDMdebug ("ENTER", "%s\n", fn);

      status = MEMopen(attr1_bufr, 1024);
       if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn, "MEMopen failed status %d\n", status);
          return(PDM_E_OPEN_BUFFER);
           }
   

     status = MEMwrite_format ((*attr1_bufr), "n_battrno", "integer"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*attr1_bufr), "n_cattrno", "integer"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*attr1_bufr), "n_catno", "integer"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*attr1_bufr), "n_map", "char(4)"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*attr1_bufr), "n_catattrname", "char(40)"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*attr1_bufr), "n_bomattrname", "char(40)"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*attr1_bufr), "n_bomdatatype", "char(40)"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }


  status = MEMbuild_array (*attr1_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}

int _PDMload_bom_attr_bufr (attr_bufr, data_bufr, cattr_bufr, head, attr1_bufr)
MEMptr          cattr_bufr;
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
MEMptr          *attr1_bufr;
struct PDMbom_member		*head;
{
	char		                *fn = "_PDMload_bom_attr_bufr";
        char				**attr;
        char				**cattr;
        char				**format;
        int				i, a_index;
        int				j, c_index;
        char				*mem_str;
        char				*sql_str;
	struct PDMbom_member		*cur_mem = NULL;

 _PDMdebug ("ENTER", "%s\n", fn);

  cur_mem = head;
  status = MEMbuild_array (cattr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (cattr_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (*attr1_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr1_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  status = MEMbuild_array ((*attr_bufr));
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


  status = MEMbuild_array (*data_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query ((*data_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


    sql_str = (char *) malloc (((*attr_bufr)->rows) * 20 + 512);
    if (! sql_str) {
      _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
      return (NFM_E_MALLOC);
      }
    sql_str[0] = '\0';

    mem_str = (char *) malloc (((*attr_bufr)->rows) * 20 + 512);
    if (! mem_str) {
      _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
      return (NFM_E_MALLOC);
      }
    mem_str[0] = '\0';

    attr = (char **) (*attr_bufr)->data_ptr;
    format = (char **) (*attr_bufr)->format_ptr;
    cattr = (char **) (cattr_bufr)->data_ptr;

  for (j = 0; j < (cattr_bufr)->rows; j++) {
    c_index = j *  (cattr_bufr)->columns;
    for (i = 0; i < (*attr_bufr)->rows; i++) {
     a_index = i *  (*attr_bufr)->columns;
     _PDMdebug ("checking attrs", " cattr[%s] <=> attr[%s]\n", 
                            cattr[c_index + 2], attr[a_index + 1] );
     if (!strcmp (cattr[c_index + 2], attr[a_index + 1] ) ) {
       sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1", attr[a_index], 
                              cattr[c_index], cattr[c_index+1], "N", 
                              cattr[c_index + 2], attr[a_index + 1], 
                              attr[a_index + 4]);
       status = MEMwrite(*attr1_bufr, mem_str);
       if(status != MEM_S_SUCCESS) {
          free(mem_str);
         _PDMdebug (fn, "MEMwrite failed status = %d\n", status);
         return(status);
         }
        _PDMdebug ("mem_str", "%s\n", mem_str);
        }
       }
      }

       status = MEMbuild_array (*attr1_bufr);
       if (status != MEM_S_SUCCESS) {
          free(mem_str);
         _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
         return (NFM_E_MEM);
         }

    if (PDMdebug_on) {
          MEMprint_buffer("*attr1_bufr query", *attr1_bufr, PDM_DEBUG_FILE);
    }

/*
    attr1 = (char **) (*attr1_bufr)->data_ptr;

    
    attr_str = (char *) malloc ((((*attr_bufr)->rows * 10)) + 512);
        if (! attr_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    attr_str[0] = '\0';
    
   sprintf (attr_str, " ( n_attrno = %s", attr[0]);
   for (col = 0; col < (*attr1_bufr)->rows; col++) {
      attr_index = col * (*attr1_bufr)->columns;
      strcat (attr_str, "OR n_attrno = ");
      strcat (attr_str, attr[attr_index + 1]);
        }
      strcat (attr_str, " ) ");
   _PDMdebug ("attr_str", "%s\n", attr_str);
   
    sprintf (sql_str, "SELECT %s FROM %s WHERE %s ", 
                " n_attrno, n_attrname, "
                " nfmattributes", attr_str);

   _PDMdebug ("sql_str", "%s\n", sql_str);

     status = SQLquery (sql_str, &qry_bufr1, MEM_SIZE);
     if (status != SQL_S_SUCCESS) {
       MEMclose (&qry1_bufr);
       _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
       return (status);
        }


  status = MEMbuild_array (qry1_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&qry1_bufr);
    _PDMdebug ( fn, "MEMbuild_query (qry1_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

 if (PDMdebug_on) {
    MEMprint_buffer("qry1_bufr from query", qry1_bufr, PDM_DEBUG_FILE);
 }

    mem_str[0] = '\0';

    q1_data = (char **) qry1_bufr->data_ptr;

    for (k = 0; k < (*attr1_bufr)->rows; k++) {
    a_index = k *  (*attr1_bufr)->columns;
    
       for (i = 0; i < qry1_bufr->rows; i++) {
       q_index = i *  qry1_bufr->columns;
    
       if (atol (attr1[a_index + 1]) == atol (q1_data[q_index])) {
         _PDMdebug (fn, "attribute_name [%s]\n", q1_data[q_index + 1]);
         status = MEMwrite_data (*attr1_bufr, q1_data[q_index + 1], i+1, 4);
         if(status != MEM_S_SUCCESS) {
             _PDMdebug (fn, "MEMbuild_data failed status %d\n", status);
             MEMclose (&qry1_bufr);
             return(PDM_E_WRITE_COLUMN);
             }
          }
         }
       }
    }

          status = MEMbuild_array (*attr1_bufr);
          if (status != MEM_S_SUCCESS) {
            _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
            return (NFM_E_MEM);
          }

       if (PDMdebug_on) {
          MEMprint_buffer("*attr1_bufr query", *attr1_bufr, PDM_DEBUG_FILE);
       }
*/

  free(mem_str);

 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}
    
int _PDMload_sel_strs (attr_bufr, attr1_bufr, head, end)
MEMptr          *attr1_bufr;
MEMptr          *attr_bufr;
struct PDMbom_member		*head, *end;
{
        char				*fn = "_PDMload_sel_strs";
        char				*sel_str;
        char				*insert_str;
	struct PDMbom_member		*cur_mem;
	struct PDMbom_member		*cur_mem1;

        PDMdebug("ENTER _PDMload_sel_str \n");
    
    cur_mem1 = end;
    sel_str = (char *) malloc ((((*attr_bufr)->rows * 10)) + 512);
        if (! sel_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    sel_str[0] = '\0';
    
    insert_str = (char *) malloc ((((*attr_bufr)->rows * 10)) + 512);
        if (! insert_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    insert_str[0] = '\0';

   for (cur_mem = head; cur_mem != NULL; cur_mem = cur_mem->next) {
     _PDMdebug (fn, "getting strs for catno = %d\n", cur_mem->cat_no);
     status = _PDMget_sel_str (sel_str, insert_str, 
                            attr_bufr, attr1_bufr);
      if (status != MEM_S_SUCCESS) {
         _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
         return (NFM_E_MEM);
         }
   
    sprintf (sel_str, 
    "SELECT %s FROM %s WHERE n_itemno = %d ", 
      cur_mem->select_str, cur_mem->cat_name, cur_mem->item_no);
      _PDMdebug ("sel_str", "%s\n", cur_mem->select_str);
      _PDMdebug ("insert_str", "%s\n", cur_mem->insert_str);
     }

 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}


int _PDMget_sel_str (sel_str, insert_str, dyn_sel_str, dyn_insert_str, 
                                              catalog, cat_no, dyn_catno, 
                                                 attr_bufr, cattr_bufr)
char		**sel_str, **insert_str, *catalog;
char		**dyn_sel_str, **dyn_insert_str;
MEMptr		attr_bufr;
MEMptr		cattr_bufr;
int		cat_no, dyn_catno;
{
        char				*fn = "_PDMget_sel_str";
        char				**attr1;
        int				i, i_index;
        int				comma;
        int				comma1;
        char				*mem_str;
        char				*mem_str1;
        char				*dmem_str;
        char				*dmem_str1;

        PDMdebug("ENTER _PDMget_sel_str \n");
    
    mem_str = (char *) malloc (((attr_bufr)->rows) * 10 + 512);
    if (! mem_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    mem_str[0] = '\0';
    
    mem_str1 = (char *) malloc (((attr_bufr)->rows) * 10 + 512);
    if (! mem_str1) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    mem_str1[0] = '\0';

    dmem_str = (char *) malloc (((attr_bufr)->rows) * 10 + 512);
    if (! dmem_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    dmem_str[0] = '\0';
    
    dmem_str1 = (char *) malloc (((attr_bufr)->rows) * 10 + 512);
    if (! dmem_str1) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    dmem_str1[0] = '\0';

    _PDMdebug (fn, "catalog [%s]\n", catalog);
    _PDMdebug (fn, "catalog [%s]\n", catalog);

  status = MEMbuild_array (attr_bufr);
  if (status != MEM_S_SUCCESS) {
    free (mem_str);
    free (mem_str1);
    free (dmem_str);
    free (dmem_str1);
    _PDMdebug ( fn, "MEMbuild_array ((attr_bufr)) 0x%.8x\n", NFM_E_MEM );
    return (status);
  }

  status = MEMbuild_array (cattr_bufr);
  if (status != MEM_S_SUCCESS) {
    free (mem_str);
    free (mem_str1);
    free (dmem_str);
    free (dmem_str1);
    _PDMdebug ( fn, "MEMbuild_array ((cattr_bufr)) 0x%.8x\n", NFM_E_MEM );
    return (status);
  }

  _PDMdebug ( fn, "MEMbuild_query (attr_bufr) successful 0x%.8x\n", status);

  attr1 = (char **) (attr_bufr)->data_ptr;
  _PDMdebug (fn, "attr1[4][%s] attr1[5][%s]\n", attr1[4], attr1[5]);

  mem_str[0] = '\0';
  mem_str1[0] = '\0';
  sprintf (mem_str, "");
  sprintf (mem_str1, "");
  comma = -1;
  comma1 = -1;
  for (i = 0; i < (attr_bufr)->rows; i++) {
  i_index = i * (attr_bufr)->columns;
  /*_PDMdebug ("Checking attr", "[%s]\n", attr1[i_index + 4]);*/
  if (!strcmp (attr1[i_index+4], "p_tagno")) continue;
  else if (!strcmp (attr1[i_index+4], "p_alttagno")) continue;
  else if (!strcmp (attr1[i_index+4], "n_catalogname")) continue;
  else if (!strcmp (attr1[i_index+4], "n_itemname")) continue;
  else if (!strcmp (attr1[i_index+4], "n_itemrev")) continue;
  else if (!strcmp (attr1[i_index+4], "p_attached")) continue;
  else if (!strcmp (attr1[i_index+4], "p_history")) continue;
  else if (!strcmp (attr1[i_index+4], "p_quantity"))continue;
  else if (!strcmp (attr1[i_index+4], "p_childno")) continue;
  else if (!strcmp (attr1[i_index+4], "p_viewid")) continue;
  else if (!strcmp (attr1[i_index+4], "p_usageid")) continue;
  else if (!strcmp (attr1[i_index+4], "n_level")) continue;
  else if (!strcmp (attr1[i_index+4], "n_pcatalogno")) continue;
  else if (!strcmp (attr1[i_index+4], "n_pitemno")) continue;
  else if (!strcmp (attr1[i_index+4], "n_catalogno")) continue;
  else if (!strcmp (attr1[i_index+4], "n_itemno")) continue;
  else if (!strcmp (attr1[i_index+4], "p_explode")) continue;
  else {
  if ( (atol (attr1[i_index + 2])) == cat_no ) {
    if (comma ==1 ) {
    strcat (mem_str, ", ");
    strcat (mem_str1, ", ");
        }
    strcat (mem_str, attr1[i_index + 4]);
    strcat (mem_str1, attr1[i_index + 5]);
    comma = 1;
      } 
  else if ( (atol (attr1[i_index + 2])) == dyn_catno ) {
    if (comma1 ==1 ) {
    strcat (dmem_str, ", ");
    strcat (dmem_str1, ", ");
        }
    strcat (dmem_str, attr1[i_index + 4]);
    strcat (dmem_str1, attr1[i_index + 5]);
    comma1 = 1;
      } 
   }
 } 
    
/*
  _PDMdebug ("attr_name", "%s\n", attr1[i_index + 4]);
    _PDMdebug ("mem_str", "%s\n", mem_str);
    free (dmem_str);
    free (dmem_str1);
*/

    *sel_str = mem_str;
    *insert_str = mem_str1;
    *dyn_sel_str = dmem_str;
    *dyn_insert_str = dmem_str1;
      _PDMdebug ("sel_str", "%s\n", *sel_str);
      _PDMdebug ("insert_str", "%s\n", *insert_str);
      _PDMdebug ("dyn_sel_str", "%s\n", *dyn_sel_str);
      _PDMdebug ("dyn_insert_str", "%s\n", *dyn_insert_str);


 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}

int PDMget_new_map_bom_attr_bufr (map_bufr, attr_bufr, data_bufr, cattr_bufr, 
                                 link_head, link_end, attr1_bufr)
MEMptr          map_bufr;
MEMptr          cattr_bufr;
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
MEMptr          *attr1_bufr;
struct PDMbom_member		**link_head, **link_end;
{
        char				*fn = "PDMget_new_map_bom_attr_bufr";
        MEMptr			        new_bufr = NULL;
	struct PDMbom_member		*cur_mem = NULL;
	struct PDMbom_member		*cur_mem1 = NULL;
	struct PDMbom_member		*head = NULL;

        PDMdebug("ENTER PDMget_new_map_bom_attr_bufr  \n");

  cur_mem1 = *link_end;
  status = MEMbuild_array (cattr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (cattr_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (*attr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (*data_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (data_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

   head = *link_head;
   
  status = _PDMcreate_bom_attr_bufr (&new_bufr);
  if (status != PDM_S_SUCCESS) {
    _PDMdebug ( fn, "_PDMcreate_bom_attr 0x%.8x\n", status );
    return (status);
  }
   
  status = _PDMload_bom_map_attr_bufr (attr_bufr, data_bufr, cattr_bufr, 
                                        head, &new_bufr, map_bufr);
  if (status != PDM_S_SUCCESS) {
     MEMclose (&new_bufr);
    _PDMdebug ( fn, "_PDMload_bom_map_attr_bufr 0x%.8x\n", status );
    return (status);
      }
/*
  q_data = (char **) map_bufr->data_ptr;
  data = (char **) (*data_bufr)->data_ptr;
*/


 for (cur_mem = head; cur_mem != NULL; cur_mem = cur_mem->next) {
   /* prepare the qry/insert string.. */
    status = _PDMget_map_sel_str (&cur_mem->select_str, 
                                   &cur_mem->insert_str, 
                                   &cur_mem->dyn_select_str, 
                                   &cur_mem->dyn_insert_str, 
                                    cur_mem->cat_name, 
                                    cur_mem->cat_no, 
                                    cur_mem->dyn_cat_no, 
                                    new_bufr, cattr_bufr);
     if (status != PDM_S_SUCCESS) {
       _PDMdebug ( fn, "_PDMget_map_sel_str 0x%.8x\n", status );
       return (status);
        }
   }
/*
  MEMclose (&qry_bufr);
*/
 *attr1_bufr = new_bufr;
_PDMdebug ("EXIT", "%s\n", fn);
return (PDM_S_SUCCESS);
}

/*
    status = _PDMget_sel_str (&cur_mem->select_str, 
                                   &cur_mem->insert_str, 
                                   &cur_mem->dyn_select_str, 
                                   &cur_mem->dyn_insert_str, 
                                    cur_mem->cat_name, 
                                    cur_mem->cat_no, 
                                    cur_mem->dyn_cat_no, 
                                    new_bufr, cattr_bufr);
int _PDMget_sel_str (sel_str, insert_str, dyn_sel_str, dyn_insert_str, 
                                              catalog, cat_no, dyn_catno, 
                                                 attr_bufr, cattr_bufr)
*/

int _PDMget_map_sel_str (sel_str, insert_str, dyn_sel_str, dyn_insert_str, 
				catalog, cat_no, dyn_catno, attr1_bufr, 
                                              cattr_bufr)
char		**sel_str, **insert_str, *catalog;
char		**dyn_sel_str, **dyn_insert_str;
MEMptr		attr1_bufr, cattr_bufr;
int		cat_no, dyn_catno;
{
        char				*fn = "_PDMget_map_sel_str";
        char				**attr;
        char				**attr1;
        int				j, j_index;
	int				comma, comma1;
        char				*mem_str;
        char				*mem_str1;
        char				*dmem_str;
        char				*dmem_str1;

        PDMdebug("ENTER _PDMget_map_sel_str \n");
    
    mem_str = (char *) malloc (((cattr_bufr->rows *10)) + 512);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str[0] = '\0';
    
    mem_str1 = (char *) malloc (((cattr_bufr->rows *10)) + 512);
        if (! mem_str1) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str1[0] = '\0';

    dmem_str = (char *) malloc (((cattr_bufr)->rows) * 10 + 512);
    if (! dmem_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    dmem_str[0] = '\0';
    
    dmem_str1 = (char *) malloc (((cattr_bufr)->rows) * 10 + 512);
    if (! dmem_str1) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    dmem_str1[0] = '\0';


    _PDMdebug (fn, "catalog [%s]\n", catalog);

  status = MEMbuild_array (cattr_bufr);
  if (status != MEM_S_SUCCESS) {
     free (mem_str);
     free (mem_str1);
    _PDMdebug ( fn, "MEMbuild_query ((cattr_bufr)) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (attr1_bufr);
  if (status != MEM_S_SUCCESS) {
     free (mem_str);
     free (mem_str1);
    _PDMdebug ( fn, "MEMbuild_query ((attr1_bufr)) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


  attr = (char **) (cattr_bufr)->data_ptr;
  attr1 = (char **) (attr1_bufr)->data_ptr;
    mem_str[0] = '\0';
    mem_str1[0] = '\0';
    comma = 0;
    comma1 = 0;
    for (j = 0; j < (attr1_bufr)->rows; j++) {
     j_index = j * (attr1_bufr)->columns;
/*
     if (!strcmp (attr1[j_index+4], "p_tagno")) continue;
     else if (!strcmp (attr1[j_index+4], "p_alttagno")) continue;
     else if (!strcmp (attr1[j_index+4], "n_catalogname")) continue;
     else if (!strcmp (attr1[j_index+4], "n_itemname")) continue;
     else if (!strcmp (attr1[j_index+4], "n_itemrev")) continue;
     else if (!strcmp (attr1[j_index+4], "p_attached")) continue;
     else if (!strcmp (attr1[j_index+4], "p_history")) continue;
     else if (!strcmp (attr1[j_index+4], "p_quantity")) continue;
     else if (!strcmp (attr1[j_index+4], "p_childno")) continue;
     else if (!strcmp (attr1[j_index+4], "p_incpartrpt")) continue;
     else if (!strcmp (attr1[j_index+4], "p_viewid")) continue;
     else if (!strcmp (attr1[j_index+4], "p_usageid")) continue;
     else if (!strcmp (attr1[j_index+4], "n_level")) continue;
     else if (!strcmp (attr1[j_index+4], "n_pcatalogno")) continue;
     else if (!strcmp (attr1[j_index+4], "n_pitemno")) continue;
     else if (!strcmp (attr1[j_index+4], "n_catalogno")) continue;
     else if (!strcmp (attr1[j_index+4], "n_itemno")) continue;
     else if (!strcmp (attr1[j_index+4], "p_explode")) continue;
     else {
*/
    /* _PDMdebug (fn, "catno[%d]<=>[%s]\n", cat_no, attr1[j_index+2]);*/
     if ( cat_no == atol (attr1[j_index+2]) ) {
/*        _PDMdebug (fn, "found mapped attr ... \n");*/
       if (comma ==1 ) {
         strcat (mem_str, ", ");
         strcat (mem_str1, ", ");
          }
         strcat (mem_str, attr1[j_index + 4]);
         strcat (mem_str1, attr1[j_index + 5]);
         comma = 1; 
        } 
       else if ( ( atol (attr1[j_index + 2])) == dyn_catno ) {
   /*    _PDMdebug (fn, "dynamic attributes...\n");*/
       if (comma1 ==1 ) {
         strcat (dmem_str, ", ");
         strcat (dmem_str1, ", ");
          }
         strcat (dmem_str, attr1[j_index + 4]);
         strcat (dmem_str1, attr1[j_index + 5]);
         comma1 = 1; 
         }
/*
       }
*/
      }
   _PDMdebug ("mem_str", "%s\n", mem_str);
   _PDMdebug ("mem_str1", "%s\n", mem_str1);
   _PDMdebug ("dmem_str", "%s\n", dmem_str);
   _PDMdebug ("dmem_str1", "%s\n", dmem_str1);
/*
   strcat (mem_str, " FROM ");
   strcat (mem_str, catalog);
*/
    *sel_str = mem_str;
    *insert_str = mem_str1;
    *dyn_sel_str = dmem_str;
    *dyn_insert_str = dmem_str1;

/*
    *sel_str = mem_str;
    *insert_str = mem_str1;
        _PDMdebug ("mem_str", "%s\n", mem_str);
      _PDMdebug ("sel_str", "%s\n", sel_str);
      _PDMdebug ("insert_str", "%s\n", insert_str);
*/

 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}
    

int _PDMload_bom_map_attr_bufr (attr_bufr, data_bufr, cattr_bufr, head, 
                                                 attr1_bufr, map_bufr)
MEMptr          cattr_bufr;
MEMptr          *attr_bufr;
MEMptr          *data_bufr;
MEMptr          map_bufr;
MEMptr          *attr1_bufr;
struct PDMbom_member		*head;
{
	char		*fn = "_PDMload_bom_map_attr_bufr";
        MEMptr			        qry1_bufr = NULL;
        char				**map_data;
        char				**cattr;
        char				**attr;
        char				**attr1;
        char				**format;
        int				found_mapped;
        int				same_catalog;
        int				same_attr_name;
        int				AddAttr, k_index;
        int				map_index, i, j, k, a_index, i_index;
        char                            bom_attr_name[50];
        char				*mem_str;
	struct PDMbom_member		*cur_mem = NULL;

    
 _PDMdebug ("ENTER", "%s\n", fn);
     same_attr_name = 0;
     map_index = 0;
     if(PDMdebug_on)
      {
        MEMprint_buffer("cattr_bufr", cattr_bufr, PDM_DEBUG_FILE);
        MEMprint_buffer("map_bufr", map_bufr, PDM_DEBUG_FILE);
        MEMprint_buffer("attr_bufr", *attr_bufr, PDM_DEBUG_FILE);
        MEMprint_buffer("data_bufr", *data_bufr, PDM_DEBUG_FILE);
        MEMprint_buffer("attr1_bufr", *attr1_bufr, PDM_DEBUG_FILE);
      }

  cur_mem = head;
  data_bufr = NULL;

/* cattr format: n_attrno, n_tableno, n_name, n_datatype */
  status = MEMbuild_array (cattr_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (cattr_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


  status = MEMbuild_array (*attr1_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr1_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


/* map_bufr format: n_bomattrno, n_catalogno, n_mapattrno, n_name */
  status = MEMbuild_array (map_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (map_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  status = MEMbuild_array ((*attr_bufr));
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


    mem_str = (char *) malloc ((map_bufr->rows * 10) + 512);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
    mem_str[0] = '\0';

    map_data = (char **) map_bufr->data_ptr;
    cattr = (char **) (cattr_bufr)->data_ptr;
    attr = (char **) (*attr_bufr)->data_ptr;
    format = (char **) (*attr_bufr)->format_ptr;

/* for all the rows in cattr_bufr, load the new attr bufr with
   information; replacing battr with map cattr info */

    for (i = 0; i < (cattr_bufr)->rows; i++) {
    a_index = i *  (cattr_bufr)->columns;
    found_mapped = 0;
    same_catalog = 0;
      for (j = 0; j < map_bufr->rows; j++) {
      map_index = j *  map_bufr->columns;

  /* checking whether the attribute matches cat_attr or bom_attr */

      _PDMdebug (fn, "cattrno[%s]<=>battrno[%s]::ccatno[%s]<=>mcatno[%s]\n", 
            cattr[a_index], map_data[map_index + 2], 
                   cattr[a_index + 1], map_data[map_index + 1] );
          
         if (atol (cattr[a_index + 1]) == atol (map_data[map_index + 1]))  {
           same_catalog = 1;
           if ( !strcmp (cattr[a_index+2], map_data[map_index + 3])) 
               same_attr_name = 1;
/*           if ( !strcmp (map_data[map_index + 3], "n_itemname")) */
           if (atol (cattr[a_index]) == atol (map_data[map_index + 2])) {
           _PDMdebug (fn, "Found mapped attr...\n");
            found_mapped = 1;
            sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1%s\1", map_data[map_index], 
             map_data[map_index+2], map_data[map_index+1], "Y", 
                                  cattr[a_index+2], map_data[map_index + 3]);
            _PDMdebug ("mem_str", "%s\n", mem_str);
            status = MEMwrite(*attr1_bufr, mem_str);
            if(status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite failed status = %d\n", status);
              return(status);
              }
           break;
              }
          else { 
           _PDMdebug (fn, "attr is not mapped ...\n");
            found_mapped = 0;
            }
           }
           else
             {
           /* Added by kumar to take care of mapping dynamic attributes 
               4.3.93 */
           if ( !strcmp (cattr[a_index+2], map_data[map_index + 3])) 
               same_attr_name = 1;
           if (atol (cattr[a_index]) == atol (map_data[map_index + 2])) {
           _PDMdebug (fn, "Found mapped attr...\n");
            found_mapped = 1;
            bom_attr_name[0] = '\0';
      status = PDMget_bom_attr_name(atoi(map_data[map_index]), bom_attr_name);
        if(status != PDM_S_SUCCESS)
            strcpy(bom_attr_name, map_data[map_index + 3]); 
            strcpy(bom_attr_name, map_data[map_index + 3]); 
            sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1%s\1", map_data[map_index], 
             map_data[map_index+2], cattr[a_index+1], "Y", 
                                  cattr[a_index+2], bom_attr_name);
            _PDMdebug ("mem_str", "%s\n", mem_str);
            status = MEMwrite(*attr1_bufr, mem_str);
            if(status != MEM_S_SUCCESS) {
              _PDMdebug (fn, "MEMwrite failed status = %d\n", status);
              return(status);
                                     }
                  break;
                }
            }
           same_catalog = 0;
           same_attr_name = 0;
         }
       _PDMdebug (fn, "found_mapped[%d] same_catalog[%d]\n", 
                                         found_mapped, same_catalog);
       if  ((found_mapped == 0)   &&
                    (same_attr_name != 1 ) ) {
/*
       if  ((found_mapped == 0) || 
             ( (found_mapped == 1) && 
                    (same_attr_name == 1 ) && (same_catalog == 1) ) ) 
*/
/* Fix  to eliminate attributes which do not have same names
     as bom_attrs and are also not mapped... */

        AddAttr = 0;
        _PDMdebug (fn, "Attr in Question [%s]\n", cattr[a_index+2]);
        for (k = 0; k < (*attr_bufr)->rows; k++) {
         k_index = k *  (*attr_bufr)->columns;
         if (!strcmp (cattr[a_index + 2], attr[k_index +1])) {
            AddAttr = 1;
            break;
            }
          }

         if (AddAttr == 1)  {
           _PDMdebug (fn, "Attr not mapped...\n");
           _PDMdebug (fn, "memwriting attr [%s] \n", cattr[a_index + 2]);
            sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1%s\1", cattr[a_index], 
                              cattr[a_index], cattr[a_index+1], "N", 
                              cattr[a_index + 2], cattr[a_index + 2]);
            _PDMdebug ("mem_str", "%s\n", mem_str);
            status = MEMwrite(*attr1_bufr, mem_str);
            if(status != MEM_S_SUCCESS) {
              free(mem_str);
              _PDMdebug (fn, "MEMwrite failed status = %d\n", status);
              return(status);
              }
           }
      _PDMdebug ("Skipped Entry", 
           "cat[%s]<=>bom[%s]::ccat[%s]<=>mcat[%s]::cname[%s]<=>mname[%s]\n", 
            cattr[a_index], map_data[map_index + 2], 
                   cattr[a_index + 1], map_data[map_index + 1] , 
                   cattr[a_index + 2], map_data[map_index + 3] );
        }
       else {
       _PDMdebug ("skipped_entry", "found_mapped[%d] same_attr_name[%d]\n", 
                                         found_mapped, same_attr_name);
      _PDMdebug ("skipped entry", 
           "cat[%s]<=>bom[%s]::ccat[%s]<=>mcat[%s]::cname[%s]<=>mname[%s]\n", 
            cattr[a_index], map_data[map_index + 2], 
                   cattr[a_index + 1], map_data[map_index + 1] , 
                   cattr[a_index + 2], map_data[map_index + 3] );
       }
    }

    status = MEMbuild_array (*attr1_bufr);
    if (status != MEM_S_SUCCESS) {
       free(mem_str);
       _PDMdebug ( fn, "MEMbuild_query (attr1_bufr) 0x%.8x\n", NFM_E_MEM );
       return (NFM_E_MEM);
    }

    if (PDMdebug_on) {
          MEMprint_buffer("new *attr1_bufr query", *attr1_bufr, PDM_DEBUG_FILE);
       }

    attr = (char **) (*attr_bufr)->data_ptr;
    format = (char **) (*attr_bufr)->format_ptr;
    attr1 = (char **) (*attr1_bufr)->data_ptr;

    for (i = 0; i < (*attr1_bufr)->rows; i++) {
    i_index = i *  (*attr1_bufr)->columns;
      for (k = 0; k < (*attr_bufr)->rows; k++) {
      a_index = k *  (*attr_bufr)->columns;
 /*     _PDMdebug ("attribute", " [%s]:[%s]<=>[%s]:[%s]\n", 
         attr[a_index+1], attr[a_index], attr1[i_index+5], attr1[i_index] );*/
      if  (!strcmp (attr[a_index+1], attr1[i_index+5])) {
         status = MEMwrite_data (*attr1_bufr, attr[a_index], i+1, 1);
         if(status != MEM_S_SUCCESS) {
             _PDMdebug (fn, "MEMbuild_data failed status %d\n", status);
             MEMclose (&qry1_bufr);
             return(PDM_E_WRITE_COLUMN);
             }
         status = MEMwrite_data (*attr1_bufr, attr[a_index + 4], i+1, 7);
         if(status != MEM_S_SUCCESS) {
             _PDMdebug (fn, "MEMbuild_data failed status %d\n", status);
             MEMclose (&qry1_bufr);
             return(PDM_E_WRITE_COLUMN);
             }
        }
         
/*      _PDMdebug ("attribute_nos", "[%s] => [%s] \n",  
                                       attr[a_index], attr1[i_index]) ;*/
      /*if (atol (attr[a_index]) == atol (attr1[i_index])) */
      if ((atol (attr[a_index]) == atol (attr1[i_index])) && 
                  (!strcmp (attr1[i_index + 3], "Y"))) {
/*         _PDMdebug (fn, "attribute_name [%s]: row[%d]:format[%s]\n", 
                               attr[a_index + 1], i, attr[a_index+4]);*/
         status = MEMwrite_data (*attr1_bufr, attr[a_index + 1], i+1, 6);
         if(status != MEM_S_SUCCESS) {
             _PDMdebug (fn, "MEMbuild_data failed status %d\n", status);
             MEMclose (&qry1_bufr);
             return(PDM_E_WRITE_COLUMN);
             }
         status = MEMwrite_data (*attr1_bufr, attr[a_index + 4], i+1, 7);
         if(status != MEM_S_SUCCESS) {
             _PDMdebug (fn, "MEMbuild_data failed status %d\n", status);
             MEMclose (&qry1_bufr);
             return(PDM_E_WRITE_COLUMN);
             }
          }
       }
     }

          status = MEMbuild_array (*attr1_bufr);
          if (status != MEM_S_SUCCESS) {
            _PDMdebug ( fn, "MEMbuild_query (attr1_bufr) 0x%.8x\n", NFM_E_MEM );
            return (NFM_E_MEM);
          }

       if (PDMdebug_on) {
          MEMprint_buffer("*attr1_bufr query", *attr1_bufr, PDM_DEBUG_FILE);
       }


 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}
    
int  _PDMXcreate_map_bufr (qry_bufr, qry_bufr1, tmp_bufr)
MEMptr	qry_bufr, qry_bufr1;
MEMptr	*tmp_bufr;
{
	char		*fn = "_PDMcreate_map_bufr";
        char				**attr;
        char				**attr1;
        char				*mem_str;
        int				col, attr_index;
        int				attr_index1;

  _PDMdebug ("ENTER", "%s\n", fn);
   

  status = MEMbuild_array (qry_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
     }


  status = MEMbuild_array (qry_bufr1);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (qry_bufr1) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
     }


/*
  status = MEMbuild_array (*tmp_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (tmp_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
     }
*/

      status = MEMopen(tmp_bufr, 1024);
       if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn, "MEMopen failed status %d\n", status);
          return(PDM_E_OPEN_BUFFER);
           }

     status = MEMwrite_format ((*tmp_bufr), "p_bomattrno", "integer"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*tmp_bufr), "n_catalogno", "integer"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*tmp_bufr), "p_mapattrno", "integer"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*tmp_bufr), "n_name", "char(40)"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

    mem_str = (char *) malloc (((qry_bufr)->rows * 10) + 512);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

   mem_str[0] = '\0';

   attr = (char **) (qry_bufr)->data_ptr;
   attr1 = (char **) (qry_bufr1)->data_ptr;
   for (col = 0; col < qry_bufr->rows; col++) {
      attr_index = col * qry_bufr->columns;
      attr_index1 = col * qry_bufr1->columns;
      _PDMdebug ("mapattrno", "[%s]<=>attrno:[%s], name[%s]\n", 
                                            attr[attr_index+2], 
                                            attr1[attr_index1+0], 
                                            attr1[attr_index1+2]);
      sprintf (mem_str, "%s\1%s\1%s\1%s\1", attr[attr_index+0], 
                                            attr[attr_index+1], 
                                            attr[attr_index+2], 
                                            attr1[attr_index1+2]);

     _PDMdebug ("mem_str", "%s\n", mem_str);
     status = MEMwrite(*tmp_bufr, mem_str);
     if(status != MEM_S_SUCCESS) {
           free (mem_str);
           _PDMdebug (fn, "MEMwrite failed status = %d\n", status);
           return(status);
        }

       status = MEMbuild_array (*tmp_bufr);
       if (status != MEM_S_SUCCESS) {
         free (mem_str);
         _PDMdebug ( fn, "MEMbuild_query (*tmp_bufr) 0x%.8x\n", NFM_E_MEM );
         return (NFM_E_MEM);
          }
      mem_str[0] = '\0';
      }

 free (mem_str);

  _PDMdebug ("EXIT", "%s\n", fn);
  return (PDM_S_SUCCESS);
}

    
int  _PDMcreate_map_bufr (pdm_bom_bufr, attrnames_bufr, tmp_bufr)
MEMptr	pdm_bom_bufr, attrnames_bufr;
MEMptr	*tmp_bufr;
{
	char		*fn = "_PDMcreate_map_bufr";
        char				**pdm_bom_attr;
        char				**attr_names;
        char				*mem_str;
        int				col1, col, attr_index;
        int				attr_index1;

  _PDMdebug ("ENTER", "%s\n", fn);
   

  status = MEMbuild_array (pdm_bom_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (pdm_bom_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
     }


  status = MEMbuild_array (attrnames_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attrnames_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
     }


/*
  status = MEMbuild_array (*tmp_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (tmp_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
     }
*/

      status = MEMopen(tmp_bufr, 1024);
       if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn, "MEMopen failed status %d\n", status);
          return(PDM_E_OPEN_BUFFER);
           }

     status = MEMwrite_format ((*tmp_bufr), "p_bomattrno", "integer"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*tmp_bufr), "n_catalogno", "integer"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*tmp_bufr), "p_mapattrno", "integer"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

     status = MEMwrite_format ((*tmp_bufr), "n_name", "char(40)"); 
        if(status != MEM_S_SUCCESS) {
                _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
                return(PDM_E_WRITE_FORMAT);
        }

    mem_str = (char *) malloc (((pdm_bom_bufr)->rows * 10) + 512);
        if (! mem_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", 
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }

   mem_str[0] = '\0';

   pdm_bom_attr = (char **) (pdm_bom_bufr)->data_ptr;
   attr_names = (char **) (attrnames_bufr)->data_ptr;
   for (col = 0; col < pdm_bom_bufr->rows; col++) {
      attr_index = col * pdm_bom_bufr->columns;
     for (col1 = 0 ; col1 < attrnames_bufr->rows; col1++) {
      attr_index1 = col1 * attrnames_bufr->columns;
      if (atol (attr_names[attr_index1]) == 
                        atol (pdm_bom_attr[attr_index+2]) ) {
      _PDMdebug ("mapattrno", "[%s]<=>attrno:[%s], cat[%s], name[%s]\n", 
                                            pdm_bom_attr[attr_index+2], 
                                            attr_names[attr_index1+0], 
                                            attr_names[attr_index1+1], 
                                            attr_names[attr_index1+2]);
      sprintf (mem_str, "%s\1%s\1%s\1%s\1", pdm_bom_attr[attr_index+0], 
                                            attr_names[attr_index1+1], 
                                            pdm_bom_attr[attr_index+2], 
                                            attr_names[attr_index1+2]);

     _PDMdebug ("mem_str", "%s\n", mem_str);
     status = MEMwrite(*tmp_bufr, mem_str);
     if(status != MEM_S_SUCCESS) {
           free (mem_str);
           _PDMdebug (fn, "MEMwrite failed status = %d\n", status);
           return(status);
        }
       break;
       }
      }
      mem_str[0] = '\0';
     }

 status = MEMbuild_array (*tmp_bufr);
 if (status != MEM_S_SUCCESS) {
    free (mem_str);
    _PDMdebug ( fn, "MEMbuild_query (*tmp_bufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
 }

 free (mem_str);

  _PDMdebug ("EXIT", "%s\n", fn);
  return (PDM_S_SUCCESS);
}


/* fix to remove the duplicate catnos */


int _PDMupdate_catnos_in_llist ( set_head, set_end, nch)
struct PDMbom_member		**set_head, **set_end;
int				nch;
{
        char				*fn = "_PDMupdate_catnos_in_llist";
        char				cat_names [2096];
        char				val [2096];
	char				*sql_str;
        char				**data;
	MEMptr				catno_bufr = NULL;
        int				duplicate, index, x, y, col;
	struct PDMbom_member		*cur_mem = NULL;
	struct PDMbom_member		*search_mem = NULL;
	struct PDMbom_member		*head = NULL, *end = NULL;

 PDMdebug("ENTER PDMget_bom_map_attrs  \n");

 _PDMdebug (fn, "Nch [%d]\n", nch);
  head = *set_head;
  end = *set_end;

 cat_names[0] ='\0';
 val[0] ='\0';

 sprintf (cat_names, " '%s'", head->cat_name);
 for (x=0, cur_mem = head->next; cur_mem != NULL; 
                     x++, cur_mem = cur_mem->next) {
   _PDMdebug ("Checking catnames ", "%s: x = %d\n", cur_mem->cat_name, x);
   duplicate = 0;
   for (y=0, search_mem = head->next; y <  x;
             y++, search_mem = search_mem->next) {
/*       _PDMdebug ("Testing ", "%d against %d \n", search_mem->cat_no, 
							cur_mem->cat_no);*/
       if ( !strcmp (cur_mem->cat_name, search_mem->cat_name) ) {
            _PDMdebug ("catname already added", "%s\n", search_mem->cat_name);
            duplicate = 1;
            break;
          }
       }
   if ( (duplicate != 1) || (x == 0) ) {
   sprintf (val, ", '%s'", cur_mem->cat_name);
   strcat (cat_names, val);
       }
   _PDMdebug ("cat_names", "%s\n", cat_names);
      }
   _PDMdebug ("cat_names", "%s\n", cat_names);
    
   _PDMdebug (fn, "strlen = %d\n", strlen (cat_names)); 
    sql_str = (char *) malloc ((strlen (cat_names) * 20) + 2096);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
          }
    sql_str[0] ='\0';

   sprintf (sql_str, 
"SELECT %s FROM nfmtables WHERE n_tablename in ( %s ) ", 
     "n_tablename, n_tableno ", 
     cat_names);

  status = SQLquery (sql_str, &catno_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    MEMclose (&catno_bufr);
    free (sql_str);
    return (status);
  }

  status = MEMbuild_array (catno_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&catno_bufr);
    _PDMdebug ( fn, "MEMbuild_query (catno_bufr) 0x%.8x\n", NFM_E_MEM );
    free (sql_str);
    return (NFM_E_MEM);
  }
 
  if (PDMdebug_on) {
    MEMprint_buffer("catno_bufr from query", catno_bufr, PDM_DEBUG_FILE);
  }


  data = (char **) catno_bufr->data_ptr;

   for (y=0, cur_mem = head; ((y <=  x) || (cur_mem != NULL));
             y++, cur_mem = cur_mem->next) {
   _PDMdebug ("Checking catname", "%s and item [%s]\n", 
                      cur_mem->cat_name, cur_mem->item_name);
    for (col = 0; col < catno_bufr->rows; col++) {
    index = col * catno_bufr->columns;
    if (!strcmp (data[index], cur_mem->cat_name) ) {
       _PDMdebug ("Fixing catname", "%s catno [%d]: newcatno [%s]\n", 
                      data[index], cur_mem->cat_no, data[index + 1]);
       cur_mem->cat_no = atol (data [index + 1]);
       break;
        } 
      }
    }
 

  MEMclose (&catno_bufr);
  free (sql_str);
 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}

int  _PDMbom_load_cattype_in_ll (cat_list, set_head)
char	*cat_list;
struct PDMbom_member		**set_head;
{
        char				*fn = "_PDMbom_load_cattype_in_ll";
	char				*sql_str;
        char				**data;
	MEMptr				catno_bufr = NULL;
        int				index, x, y, col;
	struct PDMbom_member		*cur_mem = NULL;
	struct PDMbom_member		*head = NULL;

 _PDMdebug(fn, "ENTER   \n");
  x = index = y = col = 0;

 _PDMdebug (fn, "catlist[%s]\n", cat_list);

  head = *set_head;

 sql_str = (char *) malloc ((strlen (cat_list) * 2) + 2096);
 if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
          }
 sql_str[0] ='\0';

   
  sprintf (sql_str, "SELECT %s FROM nfmcatalogs WHERE n_catalogno in ( %s ) ", 
     "n_catalogname, n_type ", 
     cat_list);

  status = SQLquery (sql_str, &catno_bufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    if (catno_bufr) MEMclose (&catno_bufr);
    if (sql_str) free (sql_str);
    return (status);
  }

  status = MEMbuild_array (catno_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&catno_bufr);
    _PDMdebug ( fn, "MEMbuild_query (catno_bufr) 0x%.8x\n", NFM_E_MEM );
    free (sql_str);
    return (NFM_E_MEM);
  }
 
  if (PDMdebug_on) {
    MEMprint_buffer("catno_bufr from query", catno_bufr, PDM_DEBUG_FILE);
  }


  data = (char **) catno_bufr->data_ptr;

   _PDMdebug (fn, "head->catname[%s]\n", head->cat_name);
   for (cur_mem = head; cur_mem != NULL; cur_mem = cur_mem->next) {
   _PDMdebug ("Checking catname", "%s and item [%s]\n", 
                      cur_mem->cat_name, cur_mem->item_name);
    for (col = 0; col < catno_bufr->rows; col++) {
    index = col * catno_bufr->columns;
    if (!strcmp (data[index], cur_mem->cat_name) ) {
       _PDMdebug ("Adding cat type", "%s catno [%d]: type [%s]\n", 
                      data[index], cur_mem->cat_no, data[index + 1]);
       cur_mem->file_class[0] = '\0';
       strcpy (cur_mem->file_class, data [index + 1]);
       _PDMdebug (fn, "cat[%s]->cattype[%s]\n", cur_mem->cat_name, 
                                         cur_mem->file_class);
       break;
        } 
      }
    }
 

  MEMclose (&catno_bufr);
  free (sql_str);
 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}

