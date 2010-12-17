#include                <stdio.h>
#include                "PDUerror.h"
#include                "MEMstruct.h"
#include                "NFMstruct.h"
#include                "WFstruct.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "SQLerrordef.h"
#include                "PDUris_incl.h"
#include                "PDMproto.h"
#include                "PDUpdmrpro.h"

extern  int     PDMdebug_on;
extern  char    PDM_DEBUG_FILE[];
static int              status;
extern PDMexec_ptr PDMexec;
extern struct NFMglobal_st NFMglobal ;
extern struct WFstruct WFinfo ;

int PDMget_cit_parents (cit_bufr)
MEMptr	*cit_bufr;
{
char		*fn = "PDMget_cit_parents";
char		sql_str[1024];
long		one, two;
MEMptr		qry_bufr = NULL, out_bufr = NULL;
int		catalog_no, item_no;
char		e_catalog[24];
char		type[24];

     one = two = -1;
    _PDMdebug ("ENTER", "%s\n", fn);    
/*    _PDMdebug (fn, "citemno_str:\n%s\n", citemno_str);*/

   status = PDMris_get_catno(PDMexec->catalog,&catalog_no);
   if (status != SQL_S_SUCCESS) {
       _PDMdebug(fn, "PDMris_get_catno : status %d\n", status);
       return(status);
      }
   type [0] = '\0';
/*
   status = PDMquery_catalogtype_no (PDMexec->catalog, type, &catalog_no);
   if (status != PDM_S_SUCCESS) {
           _PDMdebug (fn, "MEMbuild_array failed status 0x%.8x\n", status);
           return (PDM_E_CATALOG_NOT_FOUND);
   }

   _PDMdebug (fn, "catalog[%s] type[%s] catno[%d]\n", 
                               PDMexec->catalog, type, catalog_no);

   e_catalog [0] = '\0';

   if (!strcmp (type, "CID") || !strcmp(type, "EID")) {
       sprintf (e_catalog, "e_%s", PDMexec->catalog);
       status = PDMris_get_catno(PDMexec->catalog, &catalog_no);
       if (status != SQL_S_SUCCESS) {
           _PDMdebug(fn, "PDMris_get_catno : status %d\n", status);
           return(status);
         }
      }
   else {
       strcpy (e_catalog, PDMexec->catalog);
              }


   status = PDMquery_partno (e_catalog, 
				PDMexec->part_num, 
				PDMexec->revision, &item_no);
*/

   status = PDMquery_partno (PDMexec->catalog, 
				PDMexec->part_num, 
				PDMexec->revision, &item_no);
   if (status != PDM_S_SUCCESS) {
       _PDMdebug(fn, "PDMquery_partno : status %d\n", status);
       if(status == SQL_I_NO_ROWS_FOUND) return(PDM_I_NOT_USED_WHERE);
       else
       return(status);
      }

   _PDMdebug (fn, "cat_no[%d], itemno[%d]\n", catalog_no, item_no);
     
  sprintf (sql_str, 
"SELECT DISTINCT %s FROM %s where %s = %d AND %s = %d", 
"n_pcatalogno, n_pitemno", 
"NFMSETCIT",
"n_ccatalogno ",
catalog_no,
"n_citemno ",
item_no);
     status = SQLquery (sql_str,&qry_bufr,512);
     if (status != SQL_S_SUCCESS) {
       _PDMdebug(fn, "SQLquery : status %d\n", status);
       MEMclose (&qry_bufr);
       return(status);
      }
     

   status = MEMbuild_array (qry_bufr);
   if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       return(status);
    }

  if(PDMdebug_on) {
             MEMprint_buffer("qry returned buffer", qry_bufr, PDM_DEBUG_FILE);
          }

  
   status = PDMget_list_partinfo (qry_bufr, &out_bufr);
   if(status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       return(status);
    }
  
   
 *cit_bufr = out_bufr;

  if(PDMdebug_on) {
             MEMprint_buffer("pdm returned buffer", *cit_bufr, PDM_DEBUG_FILE);
          }

 MEMclose (&qry_bufr);
/*
 MEMclose (&out_bufr);
*/
 _PDMdebug ("EXIT", "%s\n", fn);    
  return (PDM_S_SUCCESS);
}


int PDMget_cit_children (cit_bufr)
MEMptr	*cit_bufr;
{
char		*fn = "PDMget_cit_children";
char		sql_str[1024];
long		one, two;
MEMptr		qry_bufr = NULL, out_bufr = NULL;
int		catalog_no, item_no;
char		e_catalog[24];
char		type[24];

     one = two = -1;
    _PDMdebug ("ENTER", "%s\n", fn);    

   status = PDMris_get_catno(PDMexec->catalog,&catalog_no);
   if (status != SQL_S_SUCCESS) {
       _PDMdebug(fn, "PDMris_get_catno : status %d\n", status);
       return(status);
      }

   type [0] = '\0';
   e_catalog [0] = '\0';
/*
   status = PDMquery_catalogtype_no (PDMexec->catalog, type, &catalog_no);
   if (status != PDM_S_SUCCESS) {
           _PDMdebug (fn, "MEMbuild_array failed status 0x%.8x\n", status);
           return (PDM_E_CATALOG_NOT_FOUND);
   }

   _PDMdebug (fn, "catalog[%s] type[%s] catno[%d]\n", 
                               PDMexec->catalog, type, catalog_no);

   e_catalog [0] = '\0';

   if (!strcmp (type, "CID") || !strcmp(type, "EID")) {
       sprintf (e_catalog, "e_%s", PDMexec->catalog);
       status = PDMris_get_catno(PDMexec->catalog, &catalog_no);
       if (status != SQL_S_SUCCESS) {
           _PDMdebug(fn, "PDMris_get_catno : status %d\n", status);
           return(status);
         }
      }
   else {
       strcpy (e_catalog, PDMexec->catalog);
              }



   status = PDMquery_partno (e_catalog, 
				PDMexec->part_num, 
				PDMexec->revision, &item_no);
*/
   status = PDMquery_partno (PDMexec->catalog, 
				PDMexec->part_num, 
				PDMexec->revision, &item_no);
   if (status != PDM_S_SUCCESS) {
       _PDMdebug(fn, "PDMquery_partno : status %d\n", status);
       return(status);
      }
   _PDMdebug (fn, "cat_no[%d], itemno[%d]\n", catalog_no, item_no);
     
    sprintf (sql_str, 
       "SELECT DISTINCT %s FROM %s where %s = %d AND %s = %d", 
            "n_ccatalogno, n_citemno", 
            "NFMSETCIT",
            "n_pcatalogno ",
            catalog_no,
            "n_pitemno ",
            item_no);

     status = SQLquery (sql_str,&qry_bufr,512);
     if (status != SQL_S_SUCCESS) {
       _PDMdebug(fn, "SQLquery : status %d\n", status);
       MEMclose (&qry_bufr);
       return(status);
      }
     

   status = MEMbuild_array (qry_bufr);
   if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       return(status);
    }

  if(PDMdebug_on) {
             MEMprint_buffer("qry returned buffer", qry_bufr, PDM_DEBUG_FILE);
          }

  
   status = PDMget_list_partinfo (qry_bufr, &out_bufr);
   if(status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       return(status);
    }
  
   
 *cit_bufr = out_bufr;

  if(PDMdebug_on) {
             MEMprint_buffer("pdm returned buffer", *cit_bufr, PDM_DEBUG_FILE);
          }

 MEMclose (&qry_bufr);
/*
 MEMclose (&out_bufr);
*/
 _PDMdebug ("EXIT", "%s\n", fn);    
  return (PDM_S_SUCCESS);
}



int   PDMget_list_partinfo (in_bufr, out_bufr)
MEMptr		in_bufr, *out_bufr;
{
	char		*fn = "PDMget_list_partinfo";
	char		*sql_str, *sql_str1, *sql_str2;
	MEMptr		qry_bufr = NULL;
        int		i, j, k, in_index, q_index = 0;
        char		**in_data, **q_data;
        char		cat_name[40], part_num[40];
	char		part_rev[40], part_desc[128];

 _PDMdebug ("ENTER", "%s\n", fn);

   status = MEMbuild_array (in_bufr);
   if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       return(status);
    }

   in_data = (char **) in_bufr->data_ptr;

     
_PDMdebug (fn, "mallocing sql_str\n");
     sql_str = (char *) malloc (1024 + (strlen (in_bufr->rows) * 10));
        if (! sql_str) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
        
     
_PDMdebug (fn, "mallocing sql_str1\n");
     sql_str1 = (char *) malloc (1024 + (strlen (in_bufr->rows) * 10));
        if (! sql_str1) {
            free (sql_str);
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
        
     
_PDMdebug (fn, "mallocing sql_str2\n");
     sql_str2 = (char *) malloc (1024 + (strlen (in_bufr->rows) * 10));
        if (! sql_str2) {
            free (sql_str);
            free (sql_str1);
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
            return (NFM_E_MALLOC);
          }
        

    sql_str[0] = '\0';
    sql_str1[0] = '\0';
    sql_str2[0] = '\0';

_PDMdebug (fn, "memopening out_bufr\n");
   status = MEMopen((out_bufr), 1024);
       if(status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMopen failed status = %d",status);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
         return(PDM_E_OPEN_BUFFER);
   }

_PDMdebug (fn, "membuildarray out_bufr\n");
   status = MEMbuild_array (*out_bufr);
   if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
       return(status);
    }
  

_PDMdebug (fn, "memwrite_formatting out_bufr\n");
   status = MEMwrite_format((*out_bufr),
                               "n_catalogname", "char(40)");
        if (status != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
        return (status);
    }


   status = MEMwrite_format((*out_bufr),
                               "n_itemnum", "char(40)");
        if(status != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
        return (status);
    }


   status = MEMwrite_format((*out_bufr),
                               "n_itemrev", "char(40)");
        if(status != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
        return (status);
    }

   status = MEMwrite_format((*out_bufr),
                               "n_itemdesc", "char(80)");
        if(status != MEM_S_SUCCESS) {
        _PDMdebug (fn, "MEMwrite_format failed status = %d",status);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
        return (status);
    }


_PDMdebug (fn, "building sql_qry\n");

   strcat (sql_str1, " n_catalogno = ");
   strcat (sql_str1, in_data[0]);
   for (i = 1; i < in_bufr->rows; i++) {
      in_index = in_bufr->columns * i;
      strcat (sql_str1, " OR n_catalogno = ");
      strcat (sql_str1, in_data[in_index]);
     }
   _PDMdebug ("sql_str1", "%s\n", sql_str1);
   
    sprintf (sql_str, "SELECT %s FROM NFMCATALOGS WHERE ( %s ) ",
    "n_catalogname, n_catalogno",
    sql_str1);

     status = SQLquery (sql_str,&qry_bufr,512);
     if (status != SQL_S_SUCCESS) {
       _PDMdebug(fn, "SQLquery : status %d\n", status);
       MEMclose (&qry_bufr);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
       return(status);
      }

   status = MEMbuild_array (qry_bufr);
   if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
       return(status);
    }


   q_data = (char **) qry_bufr->data_ptr;

   cat_name[0] = '\0';
   for (j = 0; j < in_bufr->rows; j++) {
   in_index = in_bufr->columns * j;
   cat_name[0] = '\0';
   for (k = 0; k < qry_bufr->rows; k++ ) {
      q_index = qry_bufr->columns * k;
      if ((atol (in_data[in_index])) == (atol (q_data[q_index + 1])) ) { 
        strcpy (cat_name, q_data[q_index]);
        break;
        }
      }
   
   _PDMdebug (fn, "cat_no[%s], catalog_name [%s]\n", q_data[q_index+1],
                                                 q_data[q_index]);
   status = PDMi_get_partnum_rev_desc (cat_name, 
                                       atol (in_data[in_index +1]),
                                        part_num, part_rev, part_desc);
   if(status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "PDMi_get_partnum_rev_desc  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
       return(status);
    }
    sprintf (sql_str, "%s\1%s\1%s\1%s\1",
             q_data[q_index], part_num, part_rev, part_desc);

    status = MEMwrite(*out_bufr, sql_str);
    if(status != MEM_S_SUCCESS) {
      _PDMdebug (fn, "MEMwrite failed status = %d\n",status);
       MEMclose (&qry_bufr);
       free (sql_str);
       free (sql_str1);
       free (sql_str2);
      return(status);
       }
      }

  if(PDMdebug_on) {
             MEMprint_buffer("out_bufr", *out_bufr, PDM_DEBUG_FILE);
          }

  free (sql_str);
  free (sql_str1);
  free (sql_str2);
  MEMclose (&qry_bufr);

 _PDMdebug ("EXIT", "%s\n", fn);    
  return (PDM_S_SUCCESS);
}


int PDMget_imm_parents (cit_bufr)
MEMptr	*cit_bufr;
{
char		*fn = "PDMget_imm_parents";
char		sql_str[1024];
char		e_catalog[24];
char		type[24];
long		one, two;
MEMptr		qry_bufr = NULL, out_bufr = NULL;
int		catalog_no, item_no;

     one = two = -1;
    _PDMdebug ("ENTER", "%s\n", fn);    

/*
   status = PDMris_get_catno(PDMexec->catalog,&catalog_no);
   if (status != SQL_S_SUCCESS) {
       _PDMdebug(fn, "PDMris_get_catno : status %d\n", status);
       return(status);
      }
*/
   type [0] = '\0';
   status = PDMquery_catalogtype_no (PDMexec->catalog, type, &catalog_no);
   if (status != PDM_S_SUCCESS) {
           _PDMdebug (fn, "MEMbuild_array failed status 0x%.8x\n", status);
           return (PDM_E_CATALOG_NOT_FOUND);
   }

   _PDMdebug (fn, "catalog[%s] type[%s] catno[%d]\n", 
                               PDMexec->catalog, type, catalog_no);

   e_catalog [0] = '\0';

   if (!strcmp (type, "CID") || !strcmp(type, "EID")) {
       sprintf (e_catalog, "e_%s", PDMexec->catalog);
       status = PDMris_get_catno(PDMexec->catalog, &catalog_no);
       if (status != SQL_S_SUCCESS) {
           _PDMdebug(fn, "PDMris_get_catno : status %d\n", status);
           return(status);
         }
      }
   else {
       strcpy (e_catalog, PDMexec->catalog);
              }


   status = PDMquery_partno (e_catalog, 
				PDMexec->part_num, 
				PDMexec->revision, &item_no);
   if (status != PDM_S_SUCCESS) {
       _PDMdebug(fn, "PDMquery_partno : status %d\n", status);
       return(status);
      }

   _PDMdebug (fn, "cat_no[%d], itemno[%d]\n", catalog_no, item_no);
     
  sprintf (sql_str, 
         "SELECT DISTINCT %s FROM %s where %s = %d AND %s = %d", 
         "n_pcatalogno, n_pitemno", 
         "NFMSETCIT",
         "n_ccatalogno ",
         catalog_no,
         "n_citemno ",
         item_no);
     status = SQLquery (sql_str,&qry_bufr,512);
     if (status != SQL_S_SUCCESS) {
       _PDMdebug(fn, "SQLquery : status %d\n", status);
       MEMclose (&qry_bufr);
       return(status);
      }
     

   status = MEMbuild_array (qry_bufr);
   if(status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       return(status);
    }

  if(PDMdebug_on) {
             MEMprint_buffer("qry returned buffer", qry_bufr, PDM_DEBUG_FILE);
          }

  
   status = PDMexpand_parts_list (NULL, qry_bufr, &out_bufr);
   if(status != PDM_S_SUCCESS) {
       _PDMdebug (fn, "MEMbuild_array  failed status = %d\n",status);
       MEMclose (&qry_bufr);
       return(status);
    }
  
   
 *cit_bufr = out_bufr;

  if(PDMdebug_on) {
         MEMprint_buffer("pdm returned buffer", *cit_bufr, PDM_DEBUG_FILE);
          }

 MEMclose (&qry_bufr);
 _PDMdebug ("EXIT", "%s\n", fn);    
  return (PDM_S_SUCCESS);
}

/* tmp func to avoid undef sympbols*/
/*
int PDUlist_agn_bufr ()
{
return (PDM_S_SUCCESS);
}
*/
