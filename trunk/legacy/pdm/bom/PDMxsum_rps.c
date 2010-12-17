#include                <stdio.h>
#include                "SQLerrordef.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "NFMapi.h"
#include                "NFMschema.h"
#include                "MEMstruct.h"
#include                "NFMstruct.h"
#include                "PDMdbs_err.h"
#include                "PDUerror.h"
#include                "PDMmessage.h"
#include                "dbadev.h"
#include                "rMRPstr.h"
#include                "MRPmessage.h"
#include                "PDUstorage.h"
#include                "PDMproto.h"


#include                        "PDMbom_strct.h"
static long                     status;
static char                     s[1024];
extern int                      PDMdebug_on;
extern char                     PDM_DEBUG_FILE[];
/*char                     PDU_DEBUG_FILE[];*/
extern PDMexec_ptr              PDMexec;
extern struct   PDUstorage   *storage;
extern PDMpart_ptr              PDMpart;
extern struct NFMglobal_st      NFMglobal;
extern int dba_columns_per_page;


int PDMgen_explode_summary_bom (ret_bufr)
MEMptr          *ret_bufr;
{
   static   char    *fn = "PDMgen_explode_summary_bom";
   char            p_bomname[40], table_name[30], low_table_name[31];
   char            file_name[50];
   char            report_file[100], pathname[85];
   char            templib[21],output[51],temp_type[3];
   char            schema[100], passwd[100], sch_passwd[200];
   MEMptr          bufr = NULL;
   int             table_curr, setup_tbl, sts = PDM_S_SUCCESS;
   char            sql_str[200];
   char            *msg = NULL;
/*   char            *sql_str1;*/
   char            date1[20], date2[20], saname[20];
   struct PSUrpt   psurpt;

   PDMdebug("ENTER:PDMgen_explode_summary_bom\n");

   /* check if bom exists .. quit if it does not */

        status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                                         PDMexec->revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
                return (status);
        }


   status = PDMi_find_bominfo(PDMexec->catalog,
               PDMexec->part_num,
               PDMexec->revision,
               p_bomname, date1);
   if (status != PDM_S_SUCCESS && status != PDM_I_NO_ROWS_FOUND) {
        _PDMdebug(fn, "PDMi_find_bominfo failed status %d\n", status);
         return (status);
   }
           if(status == PDM_I_NO_ROWS_FOUND) {
           p_bomname[0] = '\0';
           status = PDMupdate_exist_bom(p_bomname);
      if (status != PDM_S_SUCCESS ) {
           _PDMdebug(fn, "PDMgenerate_bom failed status %d\n", status);
      return (status);
       }
        }
                

         strcpy(saname, PDMexec->drevision);
         _PDMdebug (fn, "saname[%s]\n", saname);
         PDMinit_psurpt(&psurpt);

   /* find if table exists */

   table_name[0] = '\0';
   status = PDMi_find_tableinfo(PDMexec->catalog,
                 PDMexec->part_num,
                 PDMexec->revision,
                 "B", table_name, date2);
   if (status != PDM_S_SUCCESS &&
       status != PDM_I_NO_ROWS_FOUND) {
      _PDMdebug(fn, "PDMi_find_tableinfo failed status %d\n",
         status);
      return (status);
   }
   table_curr = '\0';

   /* if table exists see if it is current */

   if (strlen(table_name)) {
      status = PDMi_compare_dates(date1,  date2);
      if (status == 1) {
         table_curr = 1;
      } else {
         table_curr = 0;
      }
   }
   /*
    * generate table only if it does not exist OR exists but not current
    */

   if (!strlen(table_name) ||
       (strlen(table_name) && (!table_curr))) {
      sprintf(sql_str, "DROP TABLE %s", table_name);
           status = SQLstmt(sql_str);
      setup_tbl = 1;
   } else {
      setup_tbl = 1;
      sprintf(sql_str, "DROP TABLE %s", table_name);
           status = SQLstmt(sql_str);
      if (status != SQL_S_SUCCESS) {
           _PDMdebug(fn, "Could not drop report table: status %d\n", status);
           _PDMdebug (fn, "Deleting the row from pdmtables..\n");
            status = PDMi_delete_from_pdmtables ( PDMexec->catalog,
                         PDMexec->part_num,
                         PDMexec->revision,
                         "B", table_name);
      if (status != PDM_S_SUCCESS) {
         _PDMdebug (fn, "PDMi_delete_from_pdmtables: status %d\n", sts);
         return (status);
            }
      /*return(PDM_E_SQL_STMT); if the table is not there, continue..*/
      }
   }

   if (setup_tbl) {
           status = PDMi_setup_explode_summ_table (p_bomname,
                  PDMexec->operation, table_name);
      if (status != PDM_S_SUCCESS) {
      _PDMdebug(fn, "PDMi_setup_explode_summ_table failed status %d\n", 
                                                                     status);
         return (status);
      }
   }
   if (setup_tbl) {
     status = PDMi_insert_pdmtables(PDMexec->catalog,
                      PDMexec->part_num,
                      PDMexec->revision,
                      "B", table_name);
     if (status != PDM_S_SUCCESS) {
          _PDMdebug(fn, " PDMi_insert_pdmtables falied status %d\n", status);
          status = PDM_E_OUTPUT_REPORT;
          goto wrapup;
     }
   }
       PDMconvert_to_lower(table_name,low_table_name);
      _PDMdebug(fn,"Encrypted schema name %s\n",NFMglobal.NFMsch_name);
       status = NFMdecrypt(NFMglobal.NFMsch_name, schema);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fn, "Decrypy Schema Name : status = <0x%.8x>\n",
                    status);
                goto wrapup;
      }
       status = NFMdecrypt(NFMglobal.NFMsch_passwd, passwd);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fn, "Decrypy Schema passwd : status = <0x%.8x>\n",
                    status);
                goto wrapup;
      }

       sch_passwd[0] = '\0';
       sprintf(sch_passwd,"%s.%s",schema,passwd);

        strcpy(psurpt.options.template_name, PDMexec->drawing);
        strcpy(psurpt.templatetype, "X");

      /* fix to pass the template type so that we get
         The template type may be ? or ?F, the following
         function retrieves the correct type when we pass
         "?" MaC 051193
         ...*/

        temp_type[0] = '\0';
        strcpy (temp_type, "X");


        status = PDMquery_report_type(PDMexec->drawing, temp_type, 
                                                        templib, output);
        if(status != PDM_S_SUCCESS) {
        _PDMdebug(fn , "PDMquery_report_type failed status %d", status);
        status = PDM_E_RPS_READ_FORMAT;
        return(status);
        }

        if(temp_type[1] == 'F') {
        if(!strcmp(output,"") 
            && !strcmp(PDMexec->dcatalog,"") 
            && PDMexec->dcatalog != NULL)
         {
          status = PDMgen_file_name(file_name);
          if(status != PDM_S_SUCCESS) strcpy(file_name,"WHERE_IMM");
         }
         else if( strlen(PDMexec->dcatalog))strcpy(file_name,PDMexec->dcatalog);
         else if (strlen(output)) strcpy(file_name,output);
         else {
           status = PDMgen_file_name(file_name);
           if(status != PDM_S_SUCCESS) strcpy(file_name,"EXP_SUM_BOM");
            }
      strcpy(pathname,storage->path_name);
       report_file[0] = '\0';
        _PDMdebug(fn, "1file_name = %s\n",file_name);
      if (strchr(file_name, '/'))
        sprintf(report_file,"%s",file_name);
      else
        sprintf(report_file,"%s/%s",pathname,file_name);

        _PDMdebug(fn, "report_file = %s\n",report_file);

          /* Generate the report from the ris template using DBaccess */

          status = PDMreport_from_tmpfile (sch_passwd, low_table_name,
                                           templib, PDMexec->drawing,
                                           saname, report_file);
          if(status != PDM_S_SUCCESS) {
           _PDMdebug(fn, "PDMreport_from_tmpfile failed status 0x%.8x", status);
            return(status);
           }
         } /* if it is a RIS template */
        else {
          PDMinit_psurpt(&psurpt);
          strcpy(psurpt.options.template_name, PDMexec->drawing);
          strcpy(psurpt.templatetype, temp_type);
          status = PSUrs_load_rpt(&psurpt);
          if (status != MRP_S_Success) {
            _PDMdebug(fn, "PSUrs_load_rpt failed status 0x%.8x\n", status);
            status = PDM_E_RPS_READ_FORMAT;
            goto wrapup;
            }

         if(!strcmp(PDMexec->dcatalog,"") 
                  && !strcmp(psurpt.options.output,"")) {
           status = PDMgen_file_name(file_name);
           if(status != PDM_S_SUCCESS)
           strcpy(file_name,"X_SUMMARY_BOM");
           }
         else if( strlen(PDMexec->dcatalog)) 
                    strcpy(file_name,PDMexec->dcatalog);
         else if ( strlen(psurpt.options.output)) 
                    strcpy(file_name,psurpt.options.output);
         else {
                status = PDMgen_file_name(file_name);
                      if(status != PDM_S_SUCCESS)
                  strcpy(file_name,"X_SUMMARY_BOM");
                     }

      pathname[0] = '\0';
      strcpy(pathname,storage->path_name);

       report_file[0] = '\0';
       _PDMdebug(fn, "2file_name = %s\n",file_name);
      if (strchr(file_name, '/'))
        sprintf(report_file,"%s",file_name);
      else
        sprintf(report_file,"%s/%s",pathname,file_name);
      _PDMdebug (fn, "report_file %s/%s",pathname,file_name);

      PDMconvert_to_lower(table_name,table_name);       
      strcpy(psurpt.options.table , table_name);
      strcpy(psurpt.options.output, report_file);
      msg = (char *)PDUtranslate_message(PDS_M_BOM_OF);
      sprintf(psurpt.options.title, "%s  %s-%s",
                            msg,PDMexec->part_num,PDMexec->revision );
       psurpt.where = (char *) malloc (5);
       strcpy(psurpt.where,"");
      strcpy(psurpt.options.output, report_file);


     if(psurpt.options.width == 0)
       {
        psurpt.options.width  = 80 ;
        dba_columns_per_page = psurpt.options.width;
       }
        else
        dba_columns_per_page = psurpt.options.width;


        status = PSUexe_rpt(&psurpt,sch_passwd);
        if (status != MRP_S_Success) {
                _PDMdebug (fn, "PSUexe_rpt failed status %d\n", status);
                status = PDM_E_OUTPUT_REPORT;
                goto wrapup;
        }
     }

       status = MEMopen(&bufr, 512);
        if (status != MEM_S_SUCCESS) {
           MEMclose(&bufr);
           _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
           return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(bufr, "n_cofilename", "char(51)");
        if (status != MEM_S_SUCCESS) {
           MEMclose(&bufr);
           _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
           return (PDM_E_OPEN_BUFFER);
        }
         s[0] = '\0';
        sprintf(s, "%s\1", file_name );
        _PDMdebug(fn, "moving file = %s\n",s);
        status = MEMwrite(bufr, s);
        if (status != MEM_S_SUCCESS) {
           MEMclose(&bufr);
           _PDMdebug (fn, "MEMwrite failed status %d\n", status);
           return (PDM_E_WRITE_ROW);
        }

        *ret_bufr = bufr;

         rMRPfree_psurpt(&psurpt);

   PDMdebug("EXIT:PDMgen_summary_bom\n");
   return (PDM_S_SUCCESS);

wrapup:
        _PDMdebug (fn, "wrapping up....\n");
   if (setup_tbl) {
           _PDMdebug (fn, "dropping table %s....\n", table_name);
            sts = PDMi_delete_from_pdmtables ( PDMexec->catalog,
                      PDMexec->part_num,
                      PDMexec->revision,
                      "B", table_name);
      if (sts != PDM_S_SUCCESS) {
         _PDMdebug (fn, "PDMi_delete_from_pdmtables: status %d\n", sts);
         return (sts);
      }
     }
   return (status);
}


int PDMi_setup_explode_summ_table (bom, req_level, table_name)
char           *bom;
int             req_level;
char           *table_name;
{
   char      *fn = "PDMi_setup_expl_summ_bom_table";
   MEMptr          bufr = NULL;
   MEMptr          AttrBufr = NULL;
   int             max_level;
/*   char            sql_str[512];*/
   char            val[512];
   char            table_num[20];
   char          **data, **columns, **format;
   char           **AttrPtr;
   int             col_index, cols, i, nxi, first_value;
   char           *CreateString;
   char           *InsertValStr;
   char           *InsertColStr;
   char           *sql_str1;

   _PDMdebug (fn, "ENTER\n");
   if (req_level == -1) {
      status = PDMi_maxrow_no(bom, "n_level", &max_level);
      if (status != PDM_S_SUCCESS) {
           _PDMdebug (fn, "PDMi_maxrow_no failed status %d\n", status);
                 if (status == SQL_E_UNKNOWN_RELATION) 
                                 status = PDM_E_BOM_NOT_CREATED;
                 else if (status == SQL_I_NO_ROWS_FOUND) 
                                 status = PDM_E_BOM_EMPTY;
       return (status);
      }
   } else {
      max_level = req_level;
   }

/* Support for all the report attributes */

/*
       status =  PDMget_exp_summ_bufr (bom, &bufr, max_level);
   if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMi_query_non_assemblies failed status %d\n",
         status);
           MEMclose (&bufr);
      return (status);
   }

   status =  PDMget_table_no  ("bom_template", "t_appltable", &templateno);
   if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMGetBomTemplateno failed status %d\n", status);
      return (status);
   }

  _PDMdebug (fn, "Bom Templateno = %d\n", templateno);
*/

   status =  PDMGetBomAttrBufr (bom, &AttrBufr);
   if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMGetBomAttrBufr  failed status %d\n", status);
      return (status);
   }


   status = MEMbuild_array(AttrBufr);
   if (status != MEM_S_SUCCESS) {
       MEMclose(&AttrBufr);
      _PDMdebug (fn, "MEMbuild_array failed AttrBufr %d\n", status);
      return (PDM_E_BUILD_ARRAY);
   }
 
  AttrPtr = (char **) AttrBufr->data_ptr;

/*
   status =  PDMget_exp_summ_bufr (bom, AttrBufr, &bufr, max_level);
   if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMi_query_non_assemblies failed status %d\n",
         status);
           MEMclose (&bufr);
      return (status);
   }
*/

    
   /*status =  PDMget_exp_summ_bufr (bom, AttrBufr, &bufr, max_level); */

   status = PDMGetAssyStrNUpdateBomBufr(PDMpart.n_catalogno, 
                                         PDMpart.n_itemno, 
                                         bom, AttrBufr, &bufr);
   if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMi_query_non_assemblies failed status %d\n",
         status);
           MEMclose (&bufr);
      return (status);
   }

   status = MEMbuild_array(bufr);
   if (status != MEM_S_SUCCESS) {
       MEMclose(&bufr);
      _PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
      return (PDM_E_BUILD_ARRAY);
   }
 
   _PDMdebug (fn, "calling NFMRtic_it...\n");

   NFMRtic_it (bufr);

   status = MEMbuild_array(AttrBufr);
   if (status != MEM_S_SUCCESS) {
       MEMclose(&AttrBufr);
      _PDMdebug (fn, "MEMbuild_array failed AttrBufr %d\n", status);
      return (PDM_E_BUILD_ARRAY);
   }
 
  AttrPtr = (char **) AttrBufr->data_ptr;

   if (PDMdebug_on)
   MEMprint_buffer("EXP SUMMARY BUFFER", bufr, PDM_DEBUG_FILE);

   status = PDMgen_table_name(table_num);
   if (status != PDM_S_SUCCESS) {
      MEMclose(&bufr);
      _PDMdebug (fn, "PDMgen_table_name failed status %d\n", status);
      return (status);
   }

   sprintf(table_name,"PDMB%s",table_num);

   _PDMdebug (fn, "TABLE NAME = %s\n", table_name);
  
  /* Creating the report table */

    _PDMdebug (fn, "Allocating space for CreateString\n");
    CreateString = (char *) malloc ((((AttrBufr->row_size * AttrBufr->rows) +1 )
                                                       * 10) + 512);
    if (! CreateString) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    CreateString[0] = '\0';

    _PDMdebug (fn, "Allocating space for sql_str1\n");
    sql_str1 = (char *) malloc (((bufr->row_size * bufr->rows + 1 )
                                                       * 100) + 1024);
    if (! sql_str1) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    sql_str1[0] = '\0';

    _PDMdebug (fn, "Creating CreateString...\n");

    for (cols = 0; cols < AttrBufr->rows; cols++) {
     col_index = cols * AttrBufr->columns;
     _PDMdebug ("col_index", "[%d]", col_index);
     val[0] = '\0';
     _PDMdebug ("attr", "[%s]\n", AttrPtr[col_index]);
     if (!strcmp (AttrPtr[col_index + 1], "char")) {
         sprintf (val, "%s(%s)", AttrPtr[col_index+1], 
                                        AttrPtr[col_index+2]);
      }
     else if (!strcmp (AttrPtr[col_index + 1], "int")) 
         sprintf (val, "%s", "integer");
     else 
         sprintf (val, "%s", AttrPtr[col_index+1]);

     _PDMdebug (fn, "column[%s]:datatype[%s]\n", 
                        AttrPtr[col_index], val); 

     if (cols > 0) strcat (CreateString, ", ");
     strcat (CreateString, AttrPtr[col_index]);
     strcat (CreateString, " ");
     strcat (CreateString, val);
     _PDMdebug ("CreateString", "%s\n", CreateString);
     }

   sprintf(sql_str1, "CREATE TABLE %s ( %s ) ", table_name, CreateString);

   _PDMdebug ("Create String", "%s\n", sql_str1);

  status = SQLstmt(sql_str1);
  if (status != SQL_S_SUCCESS) {
   _PDMdebug (fn, "Could not execute CREATE report stmt: status %d\n", status);
   status = PDM_E_SETUP_RPS_TAB;
   free (CreateString);
   free (sql_str1);
   MEMclose(&bufr);
   return (status);
    }

   free (CreateString);
   sql_str1[0] = '\0';

   /* Inserting values into the newly created table */

    InsertColStr = (char *) malloc (((AttrBufr->row_size * AttrBufr->rows+1)
                                                       * 10) + 512);
    if (! InsertColStr) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    InsertColStr[0] = '\0';

    InsertValStr = (char *) malloc (((bufr->row_size * bufr->rows + 1 )
                                                       * 10) + 1024);
    if (! InsertValStr) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    InsertValStr[0] = '\0';

   data = (char **) bufr->data_ptr;
   columns = (char **) bufr->column_ptr;
   format = (char **) bufr->format_ptr;

   for (i = 0; i < bufr->rows; i++) {
    nxi = i * bufr->columns;
    InsertValStr[0] = '\0';
    InsertColStr[0] = '\0';
    first_value = 0;
    for (cols = 0; cols < bufr->columns; cols++) {
     if (strcmp (data[nxi+cols], "")) {
      status = _PDMget_data_type (format[cols], data[nxi+cols], val);
      if (status != PDM_S_SUCCESS) {
       _PDMdebug ( fn, "_PDMget_data_type 0x%.8x\n", status );
       free (sql_str1);
       free (InsertValStr);
       free (InsertColStr);
       return (status);
     }
     if (first_value == 1) {
        strcat (InsertValStr, ", ");
        strcat (InsertColStr, ", ");
      }
     strcat ((InsertColStr), columns[cols]);
     strcat ((InsertValStr), val);
     first_value = 1;
/*
     _PDMdebug ("InsertValStr", "%s\n", InsertValStr);
     _PDMdebug ("(InsertColStr)", "%s\n", (InsertColStr));
*/
       }
      }

   sprintf(sql_str1, "INSERT INTO %s ( %s ) VALUES ( %s ) ",
      table_name, InsertColStr, InsertValStr);
   _PDMdebug ("sql_str1", "%s\n", sql_str1);
   status = SQLstmt(sql_str1);
   if (status != SQL_S_SUCCESS) {
       _PDMdebug (fn, "SQLstmt (insert into report) : %d\n", status);
       free (sql_str1);
       free (InsertValStr);
       free (InsertColStr);
      MEMclose(&bufr);
      return (PDM_E_ADDTO_RPS_TAB);
      }
   }


   free (InsertValStr);
   free (InsertColStr);
   free (sql_str1);

   MEMclose(&bufr);

   _PDMdebug(fn, "EXIT\n");
   return (PDM_S_SUCCESS);
}


int PDMOLDget_exp_summ_bufr (bom, bufr, max_level)
char           *bom;
MEMptr         *bufr;
int             max_level;
{
   char      *fn = "PDMget_exp_summ_bufr";
        int             i = 0;
   MEMptr         qry_bufr = NULL;
   MEMptr         exp_bufr = NULL;
        char            sql_str[512];

    _PDMdebug(fn, "ENTER:\n");

/* ANSI */
    max_level = 0;

    status = MEMopen (&exp_bufr, 512);
    if (status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMopen failed status %d\n", status);
       PDMdebug(s);
       return (PDM_E_OPEN_BUFFER);
    }

    status = MEMwrite_format (exp_bufr, "p_seqno", "integer");
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
    }

    status = MEMwrite_format (exp_bufr, "n_catalogname", "char(20)");
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
    }

    status = MEMwrite_format (exp_bufr, "n_itemname", "char(240)");
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
    }

    status = MEMwrite_format (exp_bufr, "n_itemrev", "char(40)");
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
    }

    status = MEMwrite_format (exp_bufr, "p_quantity", "double");
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
    }
    status = MEMwrite_format (exp_bufr, "n_itemdesc", "char(240)");
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
    }

    status = MEMwrite_format (exp_bufr, "n_pcatalogno", "integer");
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
    }

    status = MEMwrite_format (exp_bufr, "n_pitemno", "integer");
    if (status != MEM_S_SUCCESS) {
         _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
    }


    status = MEMbuild_array (exp_bufr);
    if (status != MEM_S_SUCCESS) {
      _PDMdebug ( fn, "MEMbuild_query (exp_bufr) 0x%.8x\n", status );
      return (status);
    }

/*
    for (i = 1; i <= max_level; i++) {
    sprintf(sql_str, "SELECT %s %s FROM %s %s %d ",
          "n_level, n_catalogno, n_itemno, p_tagno, n_catalogname,",
          "n_itemname, n_itemrev, p_quantity, n_itemdesc", bom,
          "WHERE n_level = ", i);
    status = SQLquery(sql_str, &qry_bufr, 1024);
    if (status != SQL_S_SUCCESS) {
        if (status == SQL_I_NO_ROWS_FOUND) continue;
     else {
        MEMclose(&qry_bufr);
        MEMclose(&exp_bufr);
        _PDMdebug(fn, "SQLquery failed status %d\n", status);
        return (PDM_E_SQL_QUERY);
             }
          }

    status = MEMbuild_array (qry_bufr);
    if (status != MEM_S_SUCCESS) {
        MEMclose (&exp_bufr);
        MEMclose (&qry_bufr);
      _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
      return (status);
       }
    if (PDMdebug_on) MEMprint_buffer("qry_bufr ", qry_bufr, PDM_DEBUG_FILE);
*/
    /* load the output buffer for report table */
/*
    status = _PDMload_exp_summ_bufr (qry_bufr, &exp_bufr, i);
    if (status != PDM_S_SUCCESS) {
        MEMclose (&qry_bufr);
        MEMclose (&exp_bufr);
   _PDMdebug (fn, " _PDMload_exp_summ_bufr failed status %d\n", status);
   return (status);
       }

    status = MEMbuild_array (exp_bufr);
    if (status != MEM_S_SUCCESS) {
        MEMclose (&exp_bufr);
        MEMclose (&qry_bufr);
      _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
      return (status);
       }
    MEMclose (&qry_bufr);
    }
*/
    sprintf(sql_str, "SELECT %s %s FROM %s ",
     "n_level, n_catalogno, n_itemno, p_tagno, n_catalogname,",
    "n_itemname, n_itemrev, p_quantity, n_itemdesc, n_pcatalogno, n_pitemno ",
       bom);
    status = SQLquery(sql_str, &qry_bufr, 1024);
    if (status != SQL_S_SUCCESS) {
/*
        if (status == SQL_I_NO_ROWS_FOUND) continue;
        else {
*/
        MEMclose(&qry_bufr);
        MEMclose(&exp_bufr);
        _PDMdebug(fn, "SQLquery failed status %d\n", status);
        return (PDM_E_SQL_QUERY);
/*
             }
*/
          }

    status = MEMbuild_array (qry_bufr);
    if (status != MEM_S_SUCCESS) {
        MEMclose (&exp_bufr);
        MEMclose (&qry_bufr);
      _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
      return (status);
       }
/*
    if (PDMdebug_on) MEMprint_buffer("qry_bufr ", qry_bufr, PDM_DEBUG_FILE);
*/
    /* load the output buffer for report table */
    status = _PDMload_exp_summ_bufr (qry_bufr, &exp_bufr, i);
    if (status != PDM_S_SUCCESS) {
        MEMclose (&qry_bufr);
        MEMclose (&exp_bufr);
   _PDMdebug (fn, " _PDMload_exp_summ_bufr failed status %d\n", status);
   return (status);
       }

    status = MEMbuild_array (exp_bufr);
    if (status != MEM_S_SUCCESS) {
        MEMclose (&exp_bufr);
        MEMclose (&qry_bufr);
      _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
      return (status);
       }

    *bufr = exp_bufr;
    if (PDMdebug_on) MEMprint_buffer("exp_summ buffer", *bufr, PDM_DEBUG_FILE);
    _PDMdebug(fn, "EXIT:\n");
    return (PDM_S_SUCCESS);
}


int PDMget_exp_summ_bufr (BomName, AttrBufr, bufr, max_level)
char           *BomName;
MEMptr         AttrBufr;
MEMptr         *bufr;
int             max_level;
{
   char           *fn = "PDMget_exp_summ_bufr";
   MEMptr         qry_bufr = NULL;
   MEMptr         exp_bufr = NULL;
   char           *spirit;
   char           **AttrPtr;
   int		  col, col_index;
   char           datatype[40];

  _PDMdebug(fn, "ENTER:\n");

  max_level = 0;

  status = MEMbuild_array (AttrBufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&AttrBufr);
    _PDMdebug ( fn, "MEMbuild_array (AttrBufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }
 

/*
  if (PDMdebug_on) MEMprint_buffer("AttrBufr ", AttrBufr, PDM_DEBUG_FILE);
*/

  AttrPtr = (char **) AttrBufr->data_ptr;


    status = MEMopen (&exp_bufr, 512);
    if (status != MEM_S_SUCCESS) {
       _PDMdebug (fn, "MEMopen exp_bufr failed status %d\n", status);
       PDMdebug(s);
       return (PDM_E_OPEN_BUFFER);
    }


    spirit = (char *) malloc ((AttrBufr->row_size * AttrBufr->columns) * 10 
 									+ 512);
    if (! spirit) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
        return (NFM_E_MALLOC);
        }

    spirit[0] = '\0';

    for (col = 0; col < AttrBufr->rows; col++) {
     col_index = col * AttrBufr->columns;
     datatype[0] = '\0';
     if (!strcmp (AttrPtr[col_index + 1], "char")) {
         sprintf (datatype, "%s(%s)", AttrPtr[col_index+1], 
                                        AttrPtr[col_index+2]);
      } 
     else if (!strcmp (AttrPtr[col_index + 1], "int")) 
         sprintf (datatype, "%s", "integer");
       else 
         sprintf (datatype, "%s", AttrPtr[col_index+1]);

     _PDMdebug (fn, "column[%s]:datatype[%s]\n", 
                        AttrPtr[col_index], datatype);

     status = MEMwrite_format (exp_bufr,
                                  AttrPtr[col_index + 0],
                                     datatype);
        if(status != MEM_S_SUCCESS) {
          _PDMdebug (fn, "MEMwrite_format failed status %d\n",status);
          MEMclose(&exp_bufr);
          free (spirit);
          return(PDM_E_WRITE_FORMAT);
        }
      if (col > 0) strcat (spirit, ", ");
      strcat (spirit, AttrPtr[col_index]);
     }

  _PDMdebug ("spirit", "%s\n", spirit);

  if (PDMdebug_on) MEMprint_buffer("exp_bufr ", exp_bufr, PDM_DEBUG_FILE);

  status = MEMbuild_array (exp_bufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&exp_bufr);
     free (spirit);
    _PDMdebug ( fn, "MEMbuild_query (attr_list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }


    /* load the output buffer for report table */

   _PDMdebug ("spirit", "%s\n", spirit);

    status = _PDMload_exp_summ_bufr (BomName, PDMpart.n_catalogno,
                                      PDMpart.n_itemno, 1,
                                      spirit, &exp_bufr);
    if (status != PDM_S_SUCCESS) {
        MEMclose (&qry_bufr);
        MEMclose (&exp_bufr);
        free (spirit);
        _PDMdebug (fn, " _PDMload_exp_summ_bufr failed status %d\n", status);
        return (status);
       }

    free (spirit);
    status = MEMbuild_array (exp_bufr);
    if (status != MEM_S_SUCCESS) {
        MEMclose (&exp_bufr);
        MEMclose (&qry_bufr);
        _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
        return (status);
       }

    *bufr = exp_bufr;
    if (PDMdebug_on) MEMprint_buffer("exp_summ buffer", *bufr, PDM_DEBUG_FILE);
    _PDMdebug(fn, "EXIT:\n");
    return (PDM_S_SUCCESS);
}

int _PDMload_exp_summ_bufr (BomName, pcatno, ppartno, curr_level, SelStr, 
                                   exp_bufr)
MEMptr          *exp_bufr;
char		*BomName, *SelStr;
int             curr_level, pcatno, ppartno;
{
   char        *fn = "_PDMload_exp_summ_bufr";
   int          i, x, x_index, colno;
   int          z, z_index, duplicate;
   MEMptr       qry_bufr = NULL;
   double       quantity = 0.0;
   double       new_quantity = 0.0;
   char		**data, **columns;
   char		**data1;
   char		*spirit;
   char		*sql_str;
   char         qty_val[30];
   int		i_level, i_catno, i_itemno, i_catname, i_item, i_rev;
   int		i_itemdesc, i_pcatno, i_pitemno, i_qty, i_rowno;

    _PDMdebug(fn, "ENTER:\n");
     
   _PDMdebug (fn, "curr_level[%d],catno[%d],ppartno[%d]\n", 
                           curr_level, pcatno, ppartno);
   _PDMdebug ("SelStr", "%s\n", SelStr);

  status = MEMbuild_array (*exp_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
    return (status);
  }

/* get the indices for attrs needed to sort and build select string */

    columns = (char **) (*exp_bufr)->column_ptr;

    i_level = -1; i_catno  = -1; i_itemno  = -1; i_catname = -1;
    i_item  = -1; i_rev  = -1; i_itemdesc  = -1; i_pcatno = -1;
    i_pitemno  = -1; i_qty = -1;
  
    for (i = 0; i < (*exp_bufr)->columns; i++) {
      if (!strcmp(columns[i], "n_level"))
         i_level = i;
      if (!strcmp(columns[i], "n_catalogno"))
         i_catno = i;
      if (!strcmp(columns[i], "n_itemno"))
         i_itemno = i;
      if (!strcmp(columns[i], "n_catalogname"))
         i_catname = i;
      if (!strcmp(columns[i], "n_itemname"))
         i_item = i;
      if (!strcmp(columns[i], "n_itemrev"))
         i_rev = i;
      if (!strcmp(columns[i], "p_quantity"))
         i_qty = i;
      if (!strcmp(columns[i], "n_pcatalogno"))
         i_pcatno = i;
      if (!strcmp(columns[i], "n_pitemno"))
         i_pitemno = i;
      if (!strcmp(columns[i], "p_rowno"))
         i_rowno = i;

      }

    if (i_level == -1 || i_catno  == -1 || i_itemno  == -1 || i_qty == -1
     || i_catname == -1 || i_item  == -1 || i_rev  == -1 
     || i_pcatno == -1 || i_pitemno  == -1 ) {
       _PDMdebug (fn, "Couldnot set offsets in bufr \n");
       return (PDM_E_BUFFER_FORMAT);
     }


    sql_str = (char *) malloc ( (strlen (SelStr)) + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
        return (NFM_E_MALLOC);
        }

    sql_str[0] = '\0';

   sprintf(sql_str, "SELECT %s FROM %s WHERE %s = %d %s = %d %s = %d ",
    SelStr, BomName,
    "n_pcatalogno ", pcatno,
    "AND n_pitemno ", ppartno,
    "AND n_level ", curr_level);

   _PDMdebug ("sql_str", "%s\n", sql_str);

    status = SQLquery(sql_str, &qry_bufr, 1024);
    if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND ) {
        MEMclose(&qry_bufr);
        free (sql_str);
        _PDMdebug(fn, "SQLquery failed status %d\n", status);
        return (PDM_E_SQL_QUERY);
          }

    free (sql_str);
    if (status == SQL_I_NO_ROWS_FOUND) {
       _PDMdebug (fn, "Reached the leaf of this branch..\n");
       return (PDM_S_SUCCESS);
        }

    status = MEMbuild_array (qry_bufr);
    if (status != MEM_S_SUCCESS) {
        MEMclose (&exp_bufr);
        MEMclose (&qry_bufr);
      _PDMdebug ( fn, "MEMbuild_query (qry_bufr) 0x%.8x\n", status );
      return (status);
       }

    if (PDMdebug_on) MEMprint_buffer("qry_bufr ", qry_bufr, PDM_DEBUG_FILE);

    spirit = (char *) malloc ((((qry_bufr->row_size * qry_bufr->rows) +1 ) * 10)
								 + 512);
    if (! spirit) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    spirit[0] = '\0';



    data = (char **) qry_bufr->data_ptr;
    data1 = (char **) (*exp_bufr)->data_ptr;
   for (x = 0; x < qry_bufr->rows; x++) {
    x_index = x * qry_bufr->columns;
    status = _PDMasc_to_doub (data[x_index + i_qty], &quantity);
    _PDMdebug ("quantity", "[%f]\n", quantity);
    for (z = x; z < qry_bufr->rows; z++) {
     if (z==x) continue;
       z_index = z * qry_bufr->columns;
       _PDMdebug (fn,  "catno    [%s] <=> [%s]\n",
                     data[x_index + i_catno], data[z_index +i_catno]);
       _PDMdebug (fn,  "itemno   [%s] <=> [%s]\n",
                     data[x_index + i_item], data[z_index + i_item]);
       _PDMdebug (fn,  "revision [%s] <=> [%s]\n",
                     data[x_index + i_rev], data[z_index + i_rev]);

      if (atol (data[x_index+i_level]) != -1) {
       if ( (!strcmp (data[x_index + i_catname], data[z_index +i_catname])) &&
            (!strcmp (data[x_index + i_item], data[z_index + i_item])) &&
            (!strcmp (data[x_index + i_rev], data[z_index + i_rev])) ) {
           _PDMdebug (fn, "Found a Duplicate!: cat[%s].item[%s]\n",
                                data[z_index+i_catname], data[z_index+i_item]);
            duplicate = 1;

         /* incrementing the duplicate..*/

             _PDMdebug (fn, "old_quantity [%f]\n", quantity);
              new_quantity = 0.0;
              status = _PDMasc_to_doub (data[z_index + i_qty], &new_quantity);

              _PDMdebug ("new_quantity", "[%f]\n", new_quantity);

              quantity = quantity + new_quantity;

              _PDMdebug (fn, "quantity [%f]\n", quantity);

              sprintf (qty_val, "%f", quantity);

              _PDMdebug (fn, "quantity [%s]\n", qty_val);

              status = MEMwrite_data(qry_bufr, qty_val, x + 1, i_qty + 1);
              if (status != MEM_S_SUCCESS) {
                 _PDMdebug (fn, "MEMwrite_data failed status %d\n", status);
                 return (PDM_E_WRITE_COLUMN);
                 }

            /* blanking the row */
              status = MEMwrite_data(qry_bufr, "-1", z + 1, i_level + 1);
              if (status != MEM_S_SUCCESS) {
                 _PDMdebug (fn, "MEMwrite_data failed status %d\n", status);
                 return (PDM_E_WRITE_COLUMN);
                 }
             }
           }
         }
        }


    for (x = 0; x < qry_bufr->rows; x++) {
      x_index = x * qry_bufr->columns;

          /* now we have the total no of same items at this level */

      if (atol (data[x_index+i_level]) != -1) {

       spirit[0] = '\0';

       for (colno = 0; colno < qry_bufr->columns; colno++) {
          strcat (spirit, data[x_index + colno]);
          strcat (spirit, "\1");
         }

        _PDMdebug ("spirit", "%s\n", spirit);

        status = MEMwrite (*exp_bufr, spirit);
        if (status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status %d\n", status);
           free (spirit);
           return (PDM_E_WRITE_COLUMN);
          }

        if (PDMdebug_on)
                MEMprint_buffer("QTY BUFF\n", *exp_bufr, PDM_DEBUG_FILE);


        status = _PDMload_exp_summ_bufr (BomName, atol (data[x_index+i_catno]),
                                          atol (data[x_index + i_itemno]), 
                                          curr_level+1,
                                          SelStr, exp_bufr);
        if (status != PDM_S_SUCCESS) {
              MEMclose (&qry_bufr);
              MEMclose (&exp_bufr);
              _PDMdebug (fn, "_PDMload_exp_summ_bufr failed status %d\n", 
                                         status);
              return (status);
           }
         }
        }

        status = MEMbuild_array (*exp_bufr);
        if (status != MEM_S_SUCCESS) {
          _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
          free (spirit);
          return (status);
              }

   free (spirit);

  status = MEMbuild_array (*exp_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
    return (status);
  }

_PDMdebug(fn, "EXIT:\n");
return (PDM_S_SUCCESS);
}


int _PDMnewold_load_exp_summ_bufr (bom_bufr, exp_bufr, curr_level)
MEMptr         *exp_bufr;
MEMptr         bom_bufr;
int      curr_level;
{
   char        *fn = "_PDMload_exp_summ_bufr";
   int          i, x, x_index, colno;
   int          z, z_index, duplicate;
   double       quantity = 0.0;
   double       new_quantity = 0.0;
   char		**data, **columns;
   char		**data1;
   char		*spirit;
   char         qty_val[30];
   int		i_level, i_catno, i_itemno, i_catname, i_item, i_rev;
   int		i_itemdesc, i_pcatno, i_pitemno, i_qty;

    _PDMdebug(fn, "ENTER:\n");
     
   _PDMdebug (fn, "curr_level = %d\n", curr_level);

  status = MEMbuild_array (*exp_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
    return (status);
  }

  status = MEMbuild_array (bom_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (bom_bufr) 0x%.8x\n", status );
    return (status);
  }

    spirit = (char *) malloc ((((bom_bufr->row_size * bom_bufr->rows) +1 ) * 10)
								 + 512);
    if (! spirit) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    spirit[0] = '\0';


/* get the indices for attrs needed to sort and build select string */

    columns = (char **) (bom_bufr)->column_ptr;

    i_level = -1; i_catno  = -1; i_itemno  = -1; i_catname = -1;
    i_item  = -1; i_rev  = -1; i_itemdesc  = -1; i_pcatno = -1;
    i_pitemno  = -1; i_qty = -1;
  
    for (i = 0; i < bom_bufr->columns; i++) {
      if (!strcmp(columns[i], "n_level"))
         i_level = i;
      if (!strcmp(columns[i], "n_catalogno"))
         i_catno = i;
      if (!strcmp(columns[i], "n_itemno"))
         i_itemno = i;
      if (!strcmp(columns[i], "n_catalogname"))
         i_catname = i;
      if (!strcmp(columns[i], "n_itemname"))
         i_item = i;
      if (!strcmp(columns[i], "n_itemrev"))
         i_rev = i;
      if (!strcmp(columns[i], "p_quantity"))
         i_qty = i;
      if (!strcmp(columns[i], "n_pcatalogno"))
         i_pcatno = i;
      if (!strcmp(columns[i], "n_pitemno"))
         i_pitemno = i;

      }

    if (i_level == -1 || i_catno  == -1 || i_itemno  == -1 || i_qty == -1
     || i_catname == -1 || i_item  == -1 || i_rev  == -1 
     || i_pcatno == -1 || i_pitemno  == -1 ) {
       MEMclose(&bom_bufr);
       sprintf(s, "Couldnot set offsets in bufr \n");
       PDMdebug(s);
       free (spirit);
       return (PDM_E_BUFFER_FORMAT);
     }

    data = (char **) (bom_bufr)->data_ptr;
    data1 = (char **) (*exp_bufr)->data_ptr;
    for (x = 0; x < bom_bufr->rows; x++) {
    x_index = x * bom_bufr->columns;
    status = _PDMasc_to_doub (data[x_index + i_qty], &quantity);
    _PDMdebug ("quantity", "[%f]\n", quantity);
    _PDMdebug (fn, "quantity [%f]\n", quantity);
     }
    

    for (x = 0; x < bom_bufr->rows; x++) {
    x_index = x * bom_bufr->columns;
    status = _PDMasc_to_doub (data[x_index + i_qty], &quantity);
    _PDMdebug ("quantity", "[%f]\n", quantity);
    _PDMdebug (fn, "quantity [%f]\n", quantity);
    
    /*checking for duplications in thus far created bufr...*/
    duplicate = 0;
    for (z = 0; z < (*exp_bufr)->rows; z++) {
       z_index = z * (*exp_bufr)->columns;
       _PDMdebug (fn,  "catno    [%s] <=> [%s]\n",
                     data[x_index + i_catno], data1[z_index +i_catno]);
       _PDMdebug (fn,  "itemno   [%s] <=> [%s]\n",
                     data[x_index + i_item], data1[z_index + i_item]);
       _PDMdebug (fn,  "revision [%s] <=> [%s]\n",
                     data[x_index + i_rev], data1[z_index + i_rev]);


       if ( (!strcmp (data[x_index + i_catname], data1[z_index +i_catname])) &&
            (!strcmp (data[x_index + i_item], data1[z_index + i_item])) &&
            (!strcmp (data[x_index + i_rev], data1[z_index + i_rev])) &&
            (!strcmp (data[x_index + i_pcatno], data1[z_index + i_pcatno])) &&
            (!strcmp (data[x_index + i_pitemno], data1[z_index + i_pitemno])) &&
       (atol (data[x_index + i_level]) == atol (data1[z_index + i_level]) ) ) {
           _PDMdebug (fn, "Found a Duplicate!: cat[%s].item[%s]\n",
                                data[z_index+i_catname], data[z_index+i_item]);
            duplicate = 1;

         /* incrementing the duplicate..*/

             _PDMdebug (fn, "old_quantity [%f]\n", quantity);
              new_quantity = 0.0;
              status = _PDMasc_to_doub (data1[z_index + i_qty], &new_quantity);

              _PDMdebug ("new_quantity", "[%f]\n", new_quantity);

              quantity = quantity + new_quantity;

              _PDMdebug (fn, "quantity [%f]\n", quantity);

              sprintf (qty_val, "%f", quantity);

              _PDMdebug (fn, "quantity [%s]\n", qty_val);

              status = MEMwrite_data(*exp_bufr, qty_val, z + 1, i_qty + 1);
              if (status != MEM_S_SUCCESS) {
                 _PDMdebug (fn, "MEMwrite_data failed status %d\n", status);
                 return (PDM_E_WRITE_COLUMN);
                 }
            break;
           }
         }
    _PDMdebug (fn, "qty[%f] of cat[%s].item[%s]\n",
                     quantity, data[x_index+i_catname], data[x_index+i_item]);
       if (duplicate == 0) {

          /* now we have the total no of same items at this level */

       spirit[0] = '\0';

       for (colno = 0; colno < (*exp_bufr)->columns; colno++) {
          strcat (spirit, data[x_index + colno]);
          strcat (spirit, "\1");
         }

        _PDMdebug ("spirit", "%s\n", spirit);

        status = MEMwrite (*exp_bufr, spirit);
        if (status != MEM_S_SUCCESS) {
           _PDMdebug (fn, "MEMwrite failed status %d\n", status);
           free (spirit);
           return (PDM_E_WRITE_COLUMN);
           }
/*
        if (PDMdebug_on)
                MEMprint_buffer("QTY BUFF\n", *exp_bufr, PDM_DEBUG_FILE);
*/
            }
        status = MEMbuild_array (*exp_bufr);
        if (status != MEM_S_SUCCESS) {
          _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
          free (spirit);
          return (status);
              }
        data1 = (char **) (*exp_bufr)->data_ptr;
       }

   free (spirit);

  status = MEMbuild_array (*exp_bufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_query (attr_bufr) 0x%.8x\n", status );
    return (status);
  }

_PDMdebug(fn, "EXIT:\n");
return (PDM_S_SUCCESS);
}


int PDMGetBomAttrBufr (bomname, AttrBufr)
char	*bomname;
MEMptr	*AttrBufr;
{
char	*fn = "PDMGetBomAttrBufr";
char    sql_str [512];
char    BomNameinLC [51];


  _PDMdebug(fn, "ENTER:\n");

  sql_str[0] = '\0';
  BomNameinLC[0] = '\0';

  PDMconvert_to_lower(bomname, BomNameinLC);

  _PDMdebug (fn, "Bomname [%s]\n", BomNameinLC);

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */
 
#if defined ( RISV4 )

  sprintf (sql_str, "%s %s %s '%s' ",
   "SELECT column_name, ris_type_string, char_max_length ",
   "FROM riscolumns ",
   "WHERE table_name = ", BomNameinLC);

#elif defined ( RISV5 )

  sprintf (sql_str, "%s %s %s '%s' ",
   "SELECT column_name, ris_type_string, char_max_length ",
   "FROM ris5columns ",
   "WHERE table_name = ", BomNameinLC);

#else
#error "RIS version must be defined"
#endif

  status = SQLquery (sql_str, AttrBufr, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (AttrBufr);
    _PDMdebug ( fn, "SQLquery 0x%.8x\n", status) ;
    return (PDM_E_BOMREQATTR_NOT_FOUND);
  }

  status = MEMbuild_array (*AttrBufr);
  if (status != MEM_S_SUCCESS) {
    MEMclose (AttrBufr);
    _PDMdebug ( fn, "MEMbuild_array (AttrBufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

_PDMdebug(fn, "EXIT:\n");
return (PDM_S_SUCCESS);
}


    
int   PDMGetAssyStrNUpdateBomBufr(catno, partno, 
                                     BomTable, AttrBufr, InsertBufr)
int          		catno, partno;
char          		*BomTable;
MEMptr			AttrBufr, *InsertBufr;
{
        char				*fn = "PDMGetAssyStrNUpdateBomBufr";
        int				level, nch;
        int				index, i_qty, i_citno, i_level;
        int				rowno, colno;
	int				status1;
        char				drop_str[1024];
        char				val[240];
        char				**BomData, **BomCol;
        char				**AttrData;
        char				**qty_data;
        char				*BomAttrStr, *BomStr, *MemStr;
        char				qty_str[1024];
	MEMptr          		cattr_bufr = NULL;
	MEMptr          		InBuf = NULL;
	MEMptr          		BomBufr = NULL;
	MEMptr          		qty_bufr = NULL;
	struct PDMbom_member		*head, *end;
	struct PDMbom_member		*cur_mem, *temp_mem;

  _PDMdebug (fn, "Enter\n");
  _PDMdebug (fn, "catno[%d] partno[%d] BomTable[%s]\n",
                            catno, partno, BomTable);

        index = i_qty = i_citno = i_level = 0;

  status = MEMbuild_array (AttrBufr);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug ( fn, "MEMbuild_array (AttrBufr) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  }

  AttrData = (char **) (AttrBufr)->data_ptr;

/*************************************************************************/
/* get assy children */

      level = 0;

/*
      status = PDMget_bom_members (catno, PDMpart.n_itemno, 
					level, &head, &end, &nch);
*/
      status = PDMGetAssyForEngBom (catno, PDMpart.n_itemno, 
					level, &head, &end, &nch);
      if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %s %d \n",
                        "PDMget_bom_members failed : status", status);
               goto cleanup;
                /*return (status);*/
        }

      _PDMdebug (fn, "Extracted the assy structure....\n");
      if (nch < 2) {

        sprintf(drop_str, 
          "SELECT * from nfmsetcit where n_pcatalogno = %d and n_pitemno = %d",
                                         catno, partno);

        status = SQLquery(drop_str, &cattr_bufr, 512);  
         if(status == SQL_I_NO_ROWS_FOUND) {
           MEMclose(&cattr_bufr);
           sprintf(drop_str, 
           "Update %s SET n_setindicator = 'N' where and n_itemno = %d", 
                                         catno, partno);
            SQLstmt(drop_str);  
            _PDMdebug (fn, 
             "no  children for this part- restting Assembly indicator\n");
              status = PDM_E_PART_NOT_ASSEMBLY;
          }
         else {
           MEMclose(&cattr_bufr);
       _PDMdebug (fn, "no assy children included in the BOM\n");
        status = PDM_E_BOM_NO_CHILD_LIST;
          }
        goto cleanup;
        }

   for (cur_mem = head; 
           cur_mem != NULL; cur_mem = cur_mem->next) {
      _PDMprint_bommember ("cur_mem", cur_mem);    
       }

/*************************************************************************/
   /* Get quantity summarised from PDMCIT */

   for (cur_mem = head->next; 
           cur_mem != NULL; cur_mem = cur_mem->next) {
     qty_str[0] = '\0';
     sprintf (qty_str, 
       "select sum (p_quantity) from pdmcit where p_citno = %d ",
      cur_mem->citno);
      
      _PDMdebug ("qty_str", "%s \n", qty_str);

     status = SQLquery(qty_str, &qty_bufr, 1024);
     if (status != SQL_S_SUCCESS) {
        _PDMdebug(fn, "SQLquery failed status %d\n", status);
        MEMclose (&qty_bufr);
        goto cleanup;
        }

     status = MEMbuild_array (qty_bufr);
     if (status != MEM_S_SUCCESS) {
        MEMclose (&qty_bufr);
      _PDMdebug ( fn, "MEMbuild_query (qty_bufr) 0x%.8x\n", status );
      goto cleanup;
       }
     qty_data = (char **) (qty_bufr)->data_ptr;
     strcpy (cur_mem->quantity, qty_data [0]);
     _PDMdebug (fn, "cur_mem->quantity = %s\n",  qty_data [0]);
     MEMclose (&qty_bufr);
     }

/*************************************************************************/
      /* Create BomStr string And create InsertBufr:
          using all the attributes from AttrBufr */

    BomStr = (char *) malloc ((AttrBufr->rows) * 
                                   (AttrBufr->row_size) + 1024);
    if (! BomStr) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
           goto cleanup;
          }

    BomStr[0] = '\0';

    status = MEMopen (&InBuf, 2096);
    if (status != MEM_S_SUCCESS) {
       MEMclose(&InBuf);
       _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
       goto cleanup;
    }

   for (rowno = 0; rowno < (AttrBufr)->rows; rowno++) {
     index = AttrBufr->columns * rowno;
     val[0] = '\0';

     _PDMdebug ("attr", "[%s]\n", AttrData[index]);
     if (!strcmp (AttrData[index], "p_citno")) 
                         i_citno = rowno;
     if (!strcmp (AttrData[index], "p_quantity")) 
                         i_qty = rowno;
     if (!strcmp (AttrData[index], "n_level")) 
                         i_level = rowno;

     if (!strcmp (AttrData[index + 1], "char")) {
         sprintf (val, "%s(%s)", AttrData[index+1], 
                                        AttrData[index+2]);
      }
     else if (!strcmp (AttrData[index + 1], "int")) 
         sprintf (val, "%s", "integer");
     else 
         sprintf (val, "%s", AttrData[index+1]);

     _PDMdebug (fn, "column[%s]:datatype[%s]\n", 
                        AttrData[index], val); 

      status = MEMwrite_format(InBuf, AttrData[index], val);
        if (status != MEM_S_SUCCESS) {
           MEMclose(&InBuf);
           _PDMdebug (fn, "MEMwrite_format failed status %d\n", status);
           goto cleanup;
        }
      if (rowno != 0) strcat (BomStr, ", ");
      strcat (BomStr, AttrData[index]);
      /*strcat (BomStr, ", ");*/
    }

    _PDMdebug ("BomStr", "%s\n", BomStr);
 

/*************************************************************************/
/* Get all the rows from the bom table.... */

    BomAttrStr = (char *) malloc ((AttrBufr->rows) * 
                                   (AttrBufr->row_size) + 512);
    if (! BomAttrStr) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
           goto cleanup;
          }

    BomAttrStr[0] = '\0';

    sprintf (BomAttrStr, "select %s from %s ",
          BomStr, BomTable);
      
    status = SQLquery(BomAttrStr, &BomBufr, 1024);
    if (status != SQL_S_SUCCESS) {
        _PDMdebug(fn, "SQLquery failed status %d\n", status);
        MEMclose (&BomBufr);
        goto cleanup;
        }

    status = MEMbuild_array (BomBufr);
    if (status != MEM_S_SUCCESS) {
        MEMclose (&BomBufr);
      _PDMdebug ( fn, "MEMbuild_query (BomBufr) 0x%.8x\n", status );
      goto cleanup;
       }
     free (BomAttrStr);
     free (BomStr);

     BomData = (char **) (BomBufr)->data_ptr;
     BomCol = (char **) (BomBufr)->column_ptr;

/*************************************************************************/
    

/* 
   for each entry in the linked list, get corresponding citno
    value row from the BomBufr and insert it into InBuf
   */

    MemStr = (char *) malloc ((BomBufr->rows) * 
                                   (BomBufr->row_size) + 1024);
    if (! MemStr) {
            _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n",
                        NFM_E_MALLOC);
           goto cleanup;
          }

    MemStr[0] = '\0';

    _PDMdebug (fn, "Creating Insert Buffer .... \n");
    _PDMdebug (fn, "i_level [%d] i_citno [%d] i_qty [%d]\n", i_level, i_citno,
                                                        i_qty);

    for (cur_mem = head->next; cur_mem != NULL; cur_mem = cur_mem->next) {
      _PDMdebug (fn, "Checking Citno [%d]\n", cur_mem->citno);
       for (rowno = 0; rowno < BomBufr->rows; rowno++) {
         index = rowno * BomBufr->columns;
         if ((cur_mem->citno == atol (BomData[index + i_citno]))
/* Added fix to check level also. MaC 071894 */
                && (cur_mem->level == atol (BomData[index + i_level]))) {

         _PDMdebug (fn, "Getting attrs for Citno [%d]\n", cur_mem->citno);
          for (colno = 0; colno < BomBufr->columns; colno++) {
            if (colno == i_qty) {
              strcat (MemStr, cur_mem->quantity);
              strcat (MemStr, "\1");
              continue;
              }
            strcat (MemStr, BomData[index + colno]);
            strcat (MemStr, "\1");
          }
/* Added fix to blank level also. MaC 071894 */
          status = MEMwrite_data(BomBufr, "-1", rowno + 1, i_level + 1);
          if (status != MEM_S_SUCCESS) {
                 _PDMdebug (fn, "MEMwrite_data failed status %d\n", status);
                 return (PDM_E_WRITE_COLUMN);
          }
         break;
         }
       }
       _PDMdebug ("MemStr", "%s\n", MemStr);
       status = MEMwrite(InBuf, MemStr);
       if (status != MEM_S_SUCCESS) {
          MEMclose(&InBuf);
          _PDMdebug (fn, "MEMwrite failed status %d\n", status);
          goto cleanup;
        }
       MemStr[0] = '\0';
    }

    MEMclose (&BomBufr);
    free (MemStr);
    status = MEMbuild_array (InBuf);
    if (status != MEM_S_SUCCESS) {
        MEMclose (&InBuf);
      _PDMdebug ( fn, "MEMbuild_query (BomBufr) 0x%.8x\n", status );
      goto cleanup;
       }

   if (PDMdebug_on) {
       MEMprint_buffer ("InBuf after Loading", InBuf, PDM_DEBUG_FILE);
       }

   *InsertBufr = InBuf;

   goto wrapup;
/*
   _PDMdebug (fn, "Exit\n");
   return (PDM_S_SUCCESS);
*/

cleanup:
  _PDMdebug (fn, "Cleaning up..\n");
  if (BomBufr) MEMclose (&BomBufr);
  if (InBuf) MEMclose (&InBuf);
  if (qty_bufr) MEMclose (&qty_bufr);
  status1 = PDMrollback_transaction(1200);
  if (status1 != PDM_S_SUCCESS) {
        _PDMdebug (fn,  "PDMrollback_transaction failed status %d\n", status1);
        }
  _PDMdebug (fn, "freeing PDMbom_member struct ...\n");
  for (cur_mem = head; cur_mem != (struct PDMbom_member *) NULL; ) {
      temp_mem = cur_mem;
      cur_mem = cur_mem->next;
      _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n",
                            temp_mem->cat_name, temp_mem->item_name);
      if (temp_mem->select_str) free (temp_mem->select_str);
      if (temp_mem->insert_str) free (temp_mem->insert_str);
      if (temp_mem->dyn_select_str) free (temp_mem->dyn_select_str);
      if (temp_mem->dyn_insert_str) free (temp_mem->dyn_insert_str);
      if (temp_mem) free ( temp_mem );
  }
  _PDMdebug (fn, "done freeing ...\n");
  _PDMdebug (fn, "failed: status: %d \n", status1);
  return (status);


wrapup:
  _PDMdebug (fn, "Wrapping up..\n");
  if (BomBufr) MEMclose (&BomBufr);
  if (qty_bufr) MEMclose (&qty_bufr);
  _PDMdebug (fn, "freeing PDMbom_member struct ...\n");
  for (cur_mem = head; cur_mem != (struct PDMbom_member *) NULL; ) {
       temp_mem = cur_mem;
       cur_mem = cur_mem->next;
       _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n",
                            temp_mem->cat_name, temp_mem->item_name);
      if (temp_mem->select_str) free (temp_mem->select_str);
      if (temp_mem->insert_str) free (temp_mem->insert_str);
      if (temp_mem->dyn_select_str) free (temp_mem->dyn_select_str);
      if (temp_mem->dyn_insert_str) free (temp_mem->dyn_insert_str);
      if (temp_mem) free ( temp_mem );
   }
  _PDMdebug (fn, "done freeing ...\n");
 _PDMdebug ("EXIT", "%s\n", fn);
 return (PDM_S_SUCCESS);
}

