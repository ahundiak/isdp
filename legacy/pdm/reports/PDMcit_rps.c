#include		<stdio.h>
#include         <string.h>
#include         <errno.h>
#include		"PDUerror.h"
#include		"PDMmessage.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"NFMschema.h" 
#include		"NFMstruct.h" 
#include        "dbadev.h"
#include        "rMRPstr.h"
#include        "MRPmessage.h"
#include                "PDUstorage.h"
#include		"PDMproto.h"


extern struct NFMglobal_st NFMglobal;
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
static int      status;
static int      sts;
static char     s[1024];
extern struct   PDUstorage   *storage;
extern PDMexec_ptr PDMexec;
extern int dba_columns_per_page;

/* Functionality to generate where used BOM report, given a bom name
      
    -  Kumar   */
 
int PDMsgen_where_used_imm(return_buffer)
MEMptr 		*return_buffer;
{
        static char     *fname = "PDMsgen_where_used_imm";
	int             p_catno, n_itemno;
        char            templib[21], output[51], temp_type[3];
	char            table_name[30], file_name[51], pathname[85];
	char            sql_str[200], report_file[100], saname[20];
        char            schema[100], passwd[100], sch_passwd[200];
        MEMptr          bufr = NULL;
        char            *msg = NULL;
        
        struct   PSUrpt psurpt;
        

	PDMdebug("ENTER:PDMsgen_where_used_imm\n");

	*return_buffer = NULL;
	status = PDMquery_catalog_partnos(PDMexec->catalog, 
					  PDMexec->part_num, 
					  PDMexec->revision, 
					  &p_catno, &n_itemno);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMquery_catalog_partnos failed status %d\n", 
			status);
		PDMdebug(s);
		return (status);
	}
	/* set up temporary table */

	status = PDMi_setup_table3(p_catno, n_itemno, table_name);

	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMi_setup_table3 failed status %d\n", 
			status);
		PDMdebug(s);
                   if(status == PDM_I_NOT_ANYWHERE)
                  return(PDM_I_NOT_USED_WHERE);
                if(status == SQL_I_NO_ROWS_FOUND)
                  return(PDM_I_NOT_USED_HIGH);
                else
                return (status);
	}

        SQLstmt ("SET TRANSACTION AUTOCOMMIT ON");
         PDMconvert_to_lower(table_name, table_name);
        strcpy(saname, PDMexec->drevision);

        _PDMdebug(fname, "P_CATNO = %d\n", p_catno);
         _PDMdebug(fname, "P_PARTNO = %d\n", n_itemno);
       status = NFMdecrypt(NFMglobal.NFMsch_name, schema);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Decrypy Schema Name : status = <0x%.8x>\n", 
                    status);
                goto wrapup;
      }
       status = NFMdecrypt(NFMglobal.NFMsch_passwd, passwd);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Decrypy Schema passwd : status = <0x%.8x>\n", 
                    status);
                goto wrapup;
      }

       sch_passwd[0] = '\0';
       sprintf(sch_passwd, "%s.%s", schema, passwd);
      /* fix to pass the template type so that we get
         The template type may be ? or ?F, the following
         function retrieves the correct type when we pass
         "?" MaC 051193
         ...*/

        temp_type[0] = '\0';
        strcpy (temp_type, "U");
        strcpy(psurpt.templatetype, "U");


status = PDMquery_report_type(PDMexec->drawing, temp_type, templib, output);
        if(status != PDM_S_SUCCESS)
        {
        _PDMdebug(s, "%s %d\n", "PDMquery_report_type failed status ", status);
        status = PDM_E_RPS_READ_FORMAT;
        return(status);
        }
        if(temp_type[1] == 'F')
        {
        if(!strcmp(output, "") && !strcmp(PDMexec->dcatalog, "") && PDMexec->dcatalog != NULL)
         {
          status    = PDMgen_file_name(file_name);
          if(status != PDM_S_SUCCESS) strcpy(file_name, "WHERE_IMM");
         }
         else if( strlen(PDMexec->dcatalog))strcpy(file_name, PDMexec->dcatalog);
         else if (strlen(output)) strcpy(file_name, output);
         else
           {
           status    = PDMgen_file_name(file_name);
 if(status != PDM_S_SUCCESS) strcpy(file_name, "WHERE_IMM");
           }
      strcpy(pathname, storage->path_name);
       report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);
        _PDMdebug(fname, "report_file = %s\n", report_file);
          /* Generate the report from the ris template using DBaccess */
          status = PDMreport_from_tmpfile(sch_passwd, table_name, templib, PDMexec->drawing, saname, report_file);
           if(status != PDM_S_SUCCESS)
           {
    _PDMdebug(fname, "%s %d\n", "PDMreport_from_tmpfile failed status", status);
            return(status);
           }
         }
          else
         {
	/* read the report to find out the attributes */
	/* this is a report defined using the BOM content */

        PDMinit_psurpt(&psurpt);
        strcpy(psurpt.options.template_name, PDMexec->drawing);
        strcpy(psurpt.templatetype, "U");

        status = PSUrs_load_rpt(&psurpt);
        if (status != MRP_S_Success) {
        _PDMdebug(s, "%s %d\n", "PSUrs_load_rpt failed status ", status);
                status = PDM_E_RPS_READ_FORMAT;
                goto wrapup;
        }

if(!strcmp(PDMexec->dcatalog, "") && !strcmp(psurpt.options.output, ""))
    {
status    = PDMgen_file_name(file_name);
      if(status != PDM_S_SUCCESS)
          strcpy(file_name, "WHERE_IMM");
     }
     else if( strlen(PDMexec->dcatalog)) strcpy(file_name, PDMexec->dcatalog);
     else if ( strlen(psurpt.options.output)) strcpy(file_name, psurpt.options.output);
      else
         {
status    = PDMgen_file_name(file_name);
      if(status != PDM_S_SUCCESS)
          strcpy(file_name, "WHERE_IMM");
     }
      pathname[0] = '\0';
      strcpy(pathname, storage->path_name);
       report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);
strcpy(psurpt.options.table , table_name);
strcpy(psurpt.options.output, report_file);
msg = (char *)PDUtranslate_message(PDS_M_WHERE_IMMEDIATE_USAGE);
sprintf(psurpt.options.title, "<%s-%s-%s> %s", PDMexec->catalog, PDMexec->part_num, PDMexec->revision, msg );
psurpt.where = (char *) malloc (5);
 strcpy(psurpt.where, "");

 _PDMdebug(fname, "report width  = %d\n", psurpt.options.width);

     if(psurpt.options.width == 0)
       {
        psurpt.options.width  = 80 ;
        dba_columns_per_page = psurpt.options.width;
       }
        else
        dba_columns_per_page = psurpt.options.width;

        status = PSUexe_rpt(&psurpt, sch_passwd);
        if (status != MRP_S_Success) {
                sprintf(s, "RPSoutput_report failed status %d\n", status);
                PDMdebug(s);
                status = PDM_E_OUTPUT_REPORT;
                goto wrapup;
        }
         }

	sprintf(sql_str, "DROP TABLE %s", table_name);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		sprintf(s, "SQLstmt failed status %d\n", status);
		PDMdebug(s);
	}
        status = MEMopen(&bufr, 512);
           if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_OPEN_BUFFER);
        }
status = MEMwrite_format(bufr, "n_cofilename", "char(50)");
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);

                return (PDM_E_OPEN_BUFFER);
        }
         s[0] = '\0';
        sprintf(s, "%s\1", file_name );
        _PDMdebug(fname, "moving file = %s\n", s);
        status = MEMwrite(bufr, s);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMwrite failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_WRITE_ROW);
        }
        *return_buffer = bufr;

        /*  unlink(report_file); */

         rMRPfree_psurpt(&psurpt);

	PDMdebug("EXIT:PDMsgen_where_used_imm\n");
	return (PDM_S_SUCCESS);

wrapup:

	sprintf(sql_str, "DROP TABLE %s", table_name);
	sts = SQLstmt(sql_str);
	if (sts != SQL_S_SUCCESS) {
		sprintf(s, "SQLstmt failed status %d\n", status);
		PDMdebug(s);
	}
	return (status);
}

/* Set up the temporal data in PDMC_ table - Kumar */

int PDMi_setup_table3 (catno, partno, table_name)

int             partno;
int             catno;
char           *table_name;
{
	MEMptr          bufr = NULL;
	MEMptr          bufr1 = NULL;
        char            *fname = "PDMi_setup_table3";
	int             i, nx, size;
	char            d_type[50];
	char            n_catalogname[50];
	char           *n_itemname = NULL;
	char           *n_itemrev = NULL;
	char            sql_str[1024];
        char            table_num[20];
	char	      **data = NULL;

	_PDMdebug("ENTER:\n");

	sprintf(sql_str, 
	   "SELECT DISTINCT %s, %s FROM nfmsetcit WHERE %s = %d AND %s = %d", 
	    "n_pcatalogno", "n_pitemno", "n_ccatalogno", catno, "n_citemno", partno);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		_PDMdebug(fname, "SQLquery failed status %d\n", 
			status);
                 if(status == SQL_I_NO_ROWS_FOUND)
                   return(PDM_I_NOT_ANYWHERE);
		return (PDM_E_SQL_QUERY);
	}
	status = MEMopen(&bufr1, 1024);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
	       _PDMdebug(fname, "MEMopen failed status %d\n", 
			status);
		return (PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(bufr1, "n_catalogname", "char(30)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		MEMclose(&bufr1);
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", 
			status);
		return (PDM_E_WRITE_FORMAT);
	}
	status = PDMi_find_maxtype(bufr, 0, "n_itemname", &size);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&bufr);
		MEMclose(&bufr1);
		_PDMdebug(fname, "PDMi_find_maxtype failed status %d\n", 
			status);
		return (status);
	}
	sprintf(d_type, "char(%d)", size);
	status = MEMwrite_format(bufr1, "n_itemname", d_type);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		MEMclose(&bufr1);
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", 
			status);
		return (PDM_E_WRITE_FORMAT);
	}
	status = PDMi_find_maxtype(bufr, 0, "n_itemrev", &size);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&bufr);
		MEMclose(&bufr1);
		_PDMdebug(fname, "PDMi_find_maxtype failed status %d\n", 
			status);
		return (status);
	}
	sprintf(d_type, "char(%d)", size);
	status = MEMwrite_format(bufr1, "n_itemrev", d_type);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		MEMclose(&bufr1);
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", 
			status);
		return (PDM_E_WRITE_FORMAT);
	}
        if (PDMdebug_on)
            	MEMprint_buffer("BUFR", bufr, PDM_DEBUG_FILE);
        if (PDMdebug_on)
            	MEMprint_buffer("BUFR1", bufr1, PDM_DEBUG_FILE);

        status = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) 
          {
                MEMclose(&bufr);
                _PDMdebug(s, "%s %d\n", 
                        "MEMbuild_array failed status ", status);
                return (PDM_E_BUILD_ARRAY);
          }
        data = (char **)bufr->data_ptr;
	for (i = 0; i < bufr->rows; i++) 
         {
		nx = i * bufr->columns;
		n_catalogname[0] = '\0';
	        _PDMdebug(fname, "DATA[NX] = %s\n", data[nx]);
		status = PDMi_query_catalogname(data[nx], n_catalogname);
		if (status != PDM_S_SUCCESS) 
                {
		MEMclose(&bufr);
		MEMclose(&bufr1);
		_PDMdebug(fname, "PDMi_query_catalogname failed status %d\n", 
				status);
		return (status);
		}
		status = PDMi_query_partnumrev(data[nx], 
					       n_catalogname, 
					       data[nx + 1], 
					       &n_itemname, 
					       &n_itemrev);
		if (status != PDM_S_SUCCESS)
                {
		MEMclose(&bufr);
		MEMclose(&bufr1);
		_PDMdebug(fname, "PDMi_query_partnumrev failed status %d\n", 
				status);
		return (status);
		}
                s[0] = '\0';
                _PDMdebug(fname, "P_CATALOGNAME = %s, P_PARTNUM = %s, P_REVISION = %s\n", n_catalogname, n_itemname, n_itemrev);
               sprintf(s, "%s\1%s\1%s\1", n_catalogname, n_itemname, n_itemrev);
		status = MEMwrite(bufr1, s);
		if (status != MEM_S_SUCCESS)
                {
		free(n_itemname);
		free(n_itemrev);
		MEMclose(&bufr);
		MEMclose(&bufr1);
		_PDMdebug(fname, "MEMwrite failed status %d\n", status);
		return (PDM_E_WRITE_ROW);
		}
		free(n_itemname);
		free(n_itemrev);
	}
	if (PDMdebug_on)
		MEMprint_buffer("BUFR", bufr, PDM_DEBUG_FILE);
	if (PDMdebug_on)
		MEMprint_buffer("BUFR1", bufr1, PDM_DEBUG_FILE);

	MEMclose(&bufr);
	status = PDMgen_table_name(table_num);
	if (status != PDM_S_SUCCESS) 
        {
		MEMclose(&bufr1);
	_PDMdebug(fname, "PDMgen_table_name failed status %d\n", status);
		return (status);
	}

	sprintf(table_name, "PDMC%s", table_num);
	_PDMdebug(fname, "TABLE NAME = %s\n", table_name);
	status = PDMcreate_ris_table(table_name, bufr1, NULL, NULL);
	if (status != PDM_S_SUCCESS) 
        {
	MEMclose(&bufr1);
	_PDMdebug(fname, "PDMcreate_ris_table failed status %d\n", status);
	return (status);
	}
	MEMclose(&bufr1);
	_PDMdebug(fname, "EXIT:\n");
	return (PDM_S_SUCCESS);
}

/* Written to support where used in highest level - Kumar */

int PDMsgen_where_used_top(return_buffer)
MEMptr 		*return_buffer;
{
	int             p_catno, n_itemno;
        static char     *fname = "PDMsgen_where_used_top";
	char            table_name[30];
	char            sql_str[200];
        struct PSUrpt   psurpt;
        char            templib[21], output[51], temp_type[3];
        char            pathname[85], file_name[51];
        char	        report_file[100], saname[20];
        char            schema[100], passwd[100], sch_passwd[200];
        MEMptr          bufr = NULL;
        char            *msg = NULL;

	_PDMdebug(fname, "ENTER:\n");

	*return_buffer = NULL;

	status = PDMquery_catalog_partnos(PDMexec->catalog, 
					  PDMexec->part_num, 
					  PDMexec->revision, 
					  &p_catno, &n_itemno);
	if (status != PDM_S_SUCCESS) {
          _PDMdebug(fname, 
              "PDMquery_catalog_partnos failed status %d\n", status);
	  return (status);
	}
	/* set up temporary table	 */

	status = PDMi_setup_table4(p_catno, n_itemno, table_name);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug(fname, "PDMi_setup_table4 failed status %d\n", 
			status);
                if(status == SQL_I_NO_ROWS_FOUND)
                  return(PDM_I_NOT_USED_HIGH);
		return (status);
	}

        SQLstmt ("SET TRANSACTION AUTOCOMMIT ON");
         strcpy(saname, PDMexec->drevision);
         PDMconvert_to_lower(table_name, table_name);

    _PDMdebug(fname, "Encrypted schema name %s\n", NFMglobal.NFMsch_name);
       status = NFMdecrypt(NFMglobal.NFMsch_name, schema);
        if (status != NFM_S_SUCCESS)
        {
        _PDMdebug (fname, "Decrypy Schema Name : status = <0x%.8x>\n", 
                    status);
                goto wrapup;
         }
       status = NFMdecrypt(NFMglobal.NFMsch_passwd, passwd);
       if (status != NFM_S_SUCCESS)
        {
        _PDMdebug (fname, "Decrypy Schema passwd : status = <0x%.8x>\n", 
                    status);
                goto wrapup;
         }
       sch_passwd[0] = '\0';
       sprintf(sch_passwd, "%s.%s", schema, passwd);

        /* Kumar - 9.7.92 to support RIS template - start*/


      /* fix to pass the template type so that we get
         The template type may be ? or ?F, the following
         function retrieves the correct type when we pass
         "?" MaC 051193
         ...*/

        temp_type[0] = '\0';
        strcpy (temp_type, "W");
        strcpy(psurpt.templatetype, "W");


   status = PDMquery_report_type(PDMexec->drawing, temp_type, templib, output);
   if(status != PDM_S_SUCCESS) {
     _PDMdebug(fname, "%s %d\n", "PDMquery_report_type failed status ", status);
     status = PDM_E_RPS_READ_FORMAT;
     return(status);
     }

   if(temp_type[1] == 'F') {
    if(!strcmp(PDMexec->dcatalog, "") && !strcmp(output, "")) {
      status    = PDMgen_file_name(file_name);
      if(status != PDM_S_SUCCESS)
         strcpy(file_name, "WHERE_USED_TOP");
         }
           
    else if (strlen(PDMexec->dcatalog)) 
                strcpy(file_name, PDMexec->dcatalog);
    else if ( strlen(output)) 
                strcpy(file_name, output);
    else {
      status = PDMgen_file_name(file_name);
      if(status != PDM_S_SUCCESS)
          strcpy(file_name, "WHERE_USED_TOP");
          }

    strcpy(pathname, storage->path_name);

    report_file[0] = '\0';

    if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
    else
      sprintf(report_file, "%s/%s", pathname, file_name);

    /* Generate the report from the ris template using DBaccess */
    status = PDMreport_from_tmpfile (sch_passwd, table_name, templib, 
                                     PDMexec->drawing, saname, file_name);
    if(status != PDM_S_SUCCESS) {
      _PDMdebug(fname, "%s %d\n", 
                  "PDMreport_from_tmpfile failed status", status);
      return(status);
           }
      }
   else
         {
     PDMinit_psurpt(&psurpt);
     strcpy(psurpt.options.template_name, PDMexec->drawing);
     strcpy(psurpt.templatetype, "W");

     status = PSUrs_load_rpt(&psurpt);
     if (status != MRP_S_Success) {
         _PDMdebug(s, "%s %d\n", "PSUrs_load_rpt failed status ", status);
                status = PDM_E_RPS_READ_FORMAT;
                goto wrapup;
            }
     if(!strcmp(PDMexec->dcatalog, "") && !strcmp(psurpt.options.output, ""))
           {
         status    = PDMgen_file_name(file_name);
            if(status != PDM_S_SUCCESS)
          strcpy(file_name, "WHERE_USED_TOP");
            }
     else if( strlen(PDMexec->dcatalog)) strcpy(file_name, PDMexec->dcatalog);
     else if ( strlen(psurpt.options.output)) strcpy(file_name, psurpt.options.output);
     else
         {
      status    = PDMgen_file_name(file_name);
      if(status != PDM_S_SUCCESS)
          strcpy(file_name, "WHERE_USED_TOP");
          }
      strcpy(pathname, storage->path_name);
      report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);

      PDMconvert_to_lower(table_name, table_name);

      strcpy(psurpt.options.table , table_name);

      msg = (char *)PDUtranslate_message(PDS_M_HIGHEST_LEVEL_USAGE);

      sprintf(psurpt.options.title , "<%s-%s-%s> %s", 
             PDMexec->catalog, PDMexec->part_num, PDMexec->revision,msg );

      strcpy(psurpt.options.output, report_file);

      psurpt.where = (char *) malloc (5);

      strcpy(psurpt.where, "");
      
      _PDMdebug(fname, "report width  = %d\n", psurpt.options.width);

       if(psurpt.options.width == 0) {
         psurpt.options.width  = 80 ;
         dba_columns_per_page = psurpt.options.width;
         }
       else
        dba_columns_per_page = psurpt.options.width;

      status = PSUexe_rpt(&psurpt, sch_passwd);
      if (status != MRP_S_Success) {
                sprintf(s, "PSUrs_cre_rpt failed status %d\n", status);
                PDMdebug(s);
                status = PDM_E_OUTPUT_REPORT;
                goto wrapup;
        }

      }

    status = MEMopen(&bufr, 512);
    if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
              _PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
                return (PDM_E_OPEN_BUFFER);
        }
    status = MEMwrite_format(bufr, "n_cofilename", "char(50)");
    if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                _PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
                return (PDM_E_OPEN_BUFFER);
        }
    s[0] = '\0';
    sprintf(s, "%s\1", file_name );
    _PDMdebug(fname, "moving file = %s\n", s);
    status = MEMwrite(bufr, s);
    if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                _PDMdebug(fname, "MEMwrite failed status %d\n", status);
                return (PDM_E_WRITE_ROW);
        }
    *return_buffer = bufr;

    sprintf(sql_str, "DROP TABLE %s", table_name);
    status = SQLstmt(sql_str);
    if (status != SQL_S_SUCCESS) {
		_PDMdebug(fname, "SQLstmt failed status %d\n", status);
	}
    PDMdebug("EXIT:PDMsgen_where_used_top\n");
    return (PDM_S_SUCCESS);

wrapup:

	sprintf(sql_str, "DROP TABLE %s", table_name);
	sts = SQLstmt(sql_str);
	if (sts != SQL_S_SUCCESS)
        {
		_PDMdebug(fname, "SQLstmt failed status %d\n", status);
		return (PDM_E_SQL_STMT);
	}
        return (status);	
}

/* Written to support the temporal data in PDMD_ table - Kumar */

int PDMi_setup_table4(catno, partno, table_name)

int             partno;
int             catno;
char           *table_name;
{
	MEMptr          bufr = NULL;
	MEMptr          bufr1 = NULL;
	MEMptr          bufr3 = NULL;
        char            *fname = "PDMi_setup_table4";
	int             i, nx, size;
	char            n_catalogname[50];
	char           *n_itemname = NULL;
	char           *n_itemrev = NULL;
	char          **data;
	char            sql_str[1024];
        char            table_num[20];

	_PDMdebug(fname, "ENTER:\n");

	sprintf(sql_str, 
	       "SELECT %s, %s FROM nfmsetcit WHERE %s = %d AND %s = %d", 
	    "n_pcatalogno", "n_pitemno", "n_ccatalogno", catno, "n_citemno", partno);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
                               return(PDM_I_NOT_USED_HIGH);
		}
		sprintf(s, "SQLquery failed status %d\n", 
			status);
		PDMdebug(s);
		return (PDM_E_SQL_QUERY);
	}
	status = MEMopen(&bufr3, 1024);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMopen failed status %d\n", 
			status);
		PDMdebug(s);
		return (PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(bufr3, "n_catalogno", "integer");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(bufr3, "n_itemno", "integer");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		MEMclose(&bufr3);
		sprintf(s, "MEMwrite_format failed status %d\n", 
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
        if (PDMdebug_on)
		MEMprint_buffer("BUFR before I_RECURSE", bufr, PDM_DEBUG_FILE);
        if (PDMdebug_on)
		MEMprint_buffer("BUFR3 before I_RECURSE", bufr3, PDM_DEBUG_FILE);
	status = PDMi_recurse_to_highest("n_pcatalogno", "n_pitemno", 
                                         "n_ccatalogno", "n_citemno", 
					  bufr, &bufr3);
	MEMclose(&bufr);
	if (status != PDM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
		MEMclose(&bufr3);
		sprintf(s, "PDMi_recurse_to_highest failed status %d\n", 
			status);
		PDMdebug(s);
		return (status);
	}
	status = MEMopen(&bufr1, 1024);
	if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr1);
		MEMclose(&bufr3);
		MEMclose(&bufr3);
		sprintf(s, "MEMopen failed status %d\n", 
			status);
		PDMdebug(s);
		return (PDM_E_OPEN_BUFFER);
	}
	status = MEMwrite_format(bufr1, "n_catalogname", "char(30)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr1);
		MEMclose(&bufr3);
		sprintf(s, "MEMwrite_format failed status %d\n", 
			status);
		PDMdebug(s);
		return (PDM_E_WRITE_FORMAT);
	}
	size = 0;
       status = MEMwrite_format(bufr1, "n_itemname", "char(40)");
      if (status != MEM_S_SUCCESS) {
        MEMclose(&bufr1);
        MEMclose(&bufr3);
        _PDMdebug(fname, "MEMwrite_format failed status %d\n", 
                status);
		return (PDM_E_WRITE_FORMAT);
	}

	status = MEMwrite_format(bufr1, "n_itemrev", "char(15)");
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr1);
		MEMclose(&bufr3);
		_PDMdebug(fname, "MEMwrite_format failed status %d\n", 
			status);
		return (PDM_E_WRITE_FORMAT);
	}
	if (PDMdebug_on)
		MEMprint_buffer("BUFR1", bufr1, PDM_DEBUG_FILE);
	if (PDMdebug_on)
		MEMprint_buffer("BUFR3", bufr3, PDM_DEBUG_FILE);
        status = MEMbuild_array(bufr3);
	if (status != MEM_S_SUCCESS){
		MEMclose(bufr3);
		_PDMdebug(fname, "%s %d\n", "MEMbuild_array failed status ", status);
		return(PDM_E_BUILD_ARRAY);
	}  
        data = (char **)bufr3->data_ptr;
	for (i = 0; i < bufr3->rows; i++) {
		nx = i * bufr3->columns;
		n_catalogname[0] = '\0';
		status = PDMi_query_catalogname(data[nx], n_catalogname);
		if (status != PDM_S_SUCCESS) {
			MEMclose(&bufr3);
			MEMclose(&bufr1);
		_PDMdebug(fname, "PDMi_query_catalogname failed status %d\n", 
				status);
			return (status);
		}
		status = PDMi_query_partnumrev(data[nx], 
					       n_catalogname, 
					       data[nx + 1], 
					       &n_itemname, 
					       &n_itemrev);
		if (status != PDM_S_SUCCESS) {
			MEMclose(&bufr3);
			MEMclose(&bufr1);
		_PDMdebug(fname, "PDMi_query_partnumrev failed status %d\n", 
				status);
			return (status);
		}
		s[0] = '\0';
	    sprintf(s, "P_CATALOGNAME = %s, P_PARTNUM = %s, P_REVISION = %s\n", 
                    n_catalogname, n_itemname, n_itemrev);
		sprintf(s, "%s\1%s\1%s\1", n_catalogname, n_itemname, n_itemrev);
		status = MEMwrite(bufr1, s);
		if (status != MEM_S_SUCCESS) {
			free(n_itemname);
			free(n_itemrev);
			MEMclose(&bufr3);
			MEMclose(&bufr1);
			_PDMdebug(fname, "MEMwrite failed status %d\n", 
				status);
			return (PDM_E_WRITE_ROW);
		}
		free(n_itemname);
		free(n_itemrev);
	}
	if (PDMdebug_on)
		MEMprint_buffer("BUFR1", bufr1, PDM_DEBUG_FILE);

	if (PDMdebug_on)
		MEMprint_buffer("BUFR3", bufr3, PDM_DEBUG_FILE);

	MEMclose(&bufr3);
	status = PDMgen_table_name(table_num);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&bufr1);
	_PDMdebug(fname, "PDMgen_table_name failed status %d\n", status);
		return (status);
	}

	sprintf(table_name, "PDMD%s", table_num);
        _PDMdebug(fname, "TABLE NAME = %s\n", table_name);
	status = PDMcreate_ris_table(table_name, bufr1, NULL, NULL);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&bufr1);
	_PDMdebug(fname, "PDMcreate_ris_table failed status %d\n", status);
		return (status);
	}
	MEMclose(&bufr1);
	_PDMdebug(fname, "EXIT:\n");
	return (PDM_S_SUCCESS);
}

/*
 * if(bufr1 is empty or NULL) return. For all rows in bufr1 { Select a1, a2 from
 * nfmsetcit where a3, a4 are from bufr1 Result is accumulated in bufr2 If no
 * rows found a row is entered into bufr3 } Calls itself with bufr2 and bufr3
 * - Kumar
 */

int PDMi_recurse_to_highest(a1, a2, a3, a4, bufr1, bufr3)
char           *a1;
char           *a2;
char           *a3;
char           *a4;
MEMptr          bufr1;
MEMptr         *bufr3;
{
  MEMptr          bufr2 = NULL;
  char           *fname = "PDMi_recurse_to_highest";
  char          **data;
  char          **data3;
  int             nx, mx, i, j;
  int             found;
  char            sql_str[1024];

  _PDMdebug(fname, "ENTER:\n");

  if (bufr1 == NULL) {
    return (PDM_S_SUCCESS);
  }

  status = MEMbuild_array(bufr1);
  if (status != MEM_S_SUCCESS) {
    return (PDM_E_BUILD_ARRAY);
  }

  if (PDMdebug_on) {
    MEMprint_buffer("BUFR1 inside I_RECURSE", bufr1, PDM_DEBUG_FILE);
    MEMprint_buffer("BUFR3 inside I_RECURSE", *bufr3, PDM_DEBUG_FILE);
   }

  data = (char **) bufr1->data_ptr;

  if (bufr1->rows == 0) {
    return (PDM_S_SUCCESS);
    }

  for (i = 0; i < bufr1->rows; i++) {
    nx = i * bufr1->columns;
    sql_str[0] = '\0';

/* Modified to check for background attachment (p_incstr/p_incbom = N) 
   MaC
    sprintf(sql_str, 
        "SELECT %s, %s FROM nfmsetcit WHERE %s = %s AND %s = %s", 
      a1, a2, a3, data[nx], a4, data[nx + 1]);
*/
    sprintf(sql_str, 
        "SELECT %s, %s FROM nfmsetcit, pdmcit WHERE %s = %s AND %s = %s %s ", 
         a1, a2, a3, data[nx], a4, data[nx + 1],
     " AND nfmsetcit.n_citno = pdmcit.p_citno AND p_incbom = 'Y'");
    status = SQLquery(sql_str, &bufr2, 1024);
    if (status != SQL_S_SUCCESS) {
      if (status == SQL_I_NO_ROWS_FOUND) {
       _PDMdebug(fname, "NO ROWS IN BUFR1 FOUND\n");
       found = 0;
       status = MEMbuild_array(*bufr3);
       if (status != MEM_S_SUCCESS) {
          return (PDM_E_BUILD_ARRAY);
        }
       data3 = (char **)(*bufr3)->data_ptr;
       for (j = 0; j < (*bufr3)->rows; j++)
        {
          mx = j * (*bufr3)->columns;
          if ((!strcmp(data3[mx], data[nx])) &&                                              (!strcmp(data3[mx + 1], data[nx + 1])))
             {
            found = 1;
                                                break;
          }
          else
          {
            found = 0;
          }
        }
       if (found == 0) {
         sql_str[0] = '\0';
         sprintf(sql_str, "%d\1%d\1", atoi(data[nx]), atoi(data[nx + 1]));
         status = MEMwrite(*bufr3, sql_str);
         if (status != MEM_S_SUCCESS) {
            MEMclose(&bufr2);
            return (PDM_E_WRITE_ROW);
            }
         if (PDMdebug_on)
            MEMprint_buffer("BUFR3 AFTER NO ROWS\n", *bufr3, PDM_DEBUG_FILE);
        }
      } else {
        MEMclose(&bufr2);
        bufr2 = NULL;
        return (PDM_E_SQL_QUERY);
      }
    }
    if (PDMdebug_on)
      MEMprint_buffer("BUFR2 inside I_RECURSE", bufr2, PDM_DEBUG_FILE);
  }
  status = PDMi_recurse_to_highest(a1, a2, a3, a4, bufr2, bufr3);
  if (status != PDM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
    MEMclose(&bufr2);
    return (status);
  }
        _PDMdebug(fname, "EXIT:\n");
  return (PDM_S_SUCCESS);
}
 
/* Written to support the report of list of catalogs report. Classification
   reporting is also supported - Kumar */

int PDMreport_of_loc(return_buffer)
MEMptr		*return_buffer;
{
        static char     *fname = "PDMreport_of_loc";
	char            file_name[51];
        char            pathname[100];
        char            templib[21], output[51], temp_type[3];
	char            sql_str[200], report_file[100], saname[20];
        char            schema[100], passwd[100], sch_passwd[200];
        MEMptr          check_bufr = NULL, bufr = NULL;
        struct   PSUrpt psurpt;
        char            *msg = NULL;
        

	PDMdebug("ENTER:PDMreport_of_loc\n");
        templib[0] = '\0';
        output[0] = '\0';
        temp_type[0] = '\0';
        sql_str[0] = '\0';
        report_file[0] = '\0';
        saname[0] = '\0';
        schema[0] = '\0';
        passwd[0] = '\0';
        sch_passwd[0] = '\0';
        pathname[0] = '\0';
        file_name[0] = '\0';

        strcpy(saname, PDMexec->drevision);

       _PDMdebug(fname, "saname = %s\n", saname);
       _PDMdebug(fname, "template = %s\n", PDMexec->drawing);
       PDMinit_psurpt(&psurpt);
      _PDMdebug(fname, "Encrypted schema name %s\n", NFMglobal.NFMsch_name);
       status = NFMdecrypt(NFMglobal.NFMsch_name, schema);
        if (status != NFM_S_SUCCESS) {
        _PDMdebug (fname, "Decrypy Schema Name : status = <0x%.8x>\n", 
                    status);
                goto wrapup;
         }
       status = NFMdecrypt(NFMglobal.NFMsch_passwd, passwd);
       if (status != NFM_S_SUCCESS) {
        _PDMdebug (fname, "Decrypy Schema passwd : status = <0x%.8x>\n", 
                    status);
                goto wrapup;
         }
       sch_passwd[0] = '\0';
       sprintf(sch_passwd, "%s.%s", schema, passwd);

        /* Kumar - 9.7.92 to support RIS template - start*/
      /* fix to pass the template type so that we get
         The template type may be ? or ?F, the following
         function retrieves the correct type when we pass
         "?" MaC 051193
         ...*/

        temp_type[0] = '\0';
        strcpy (temp_type, "L");
        strcpy(psurpt.templatetype, "L");


        status = PDMquery_report_type (PDMexec->drawing, temp_type, 
                                                          templib, output);
        if(status != PDM_S_SUCCESS) {
        _PDMdebug(s, "%s %d\n", "PDMquery_report_type failed status ", status);
        status = PDM_E_RPS_READ_FORMAT;
        return(status);
        }
        if(temp_type[1] == 'F') {
        if(!strcmp(PDMexec->dcatalog, "") && PDMexec->dcatalog != NULL) {
          status    = PDMgen_file_name(file_name);
          if(status != PDM_S_SUCCESS) strcpy(file_name, "BOM");
         }
         else if( strlen(PDMexec->dcatalog))
                                   strcpy (file_name, PDMexec->dcatalog);
         else if (strlen(output)) 
                                    strcpy(file_name, output);
         else {
           status    = PDMgen_file_name(file_name);
           if(status != PDM_S_SUCCESS) strcpy(file_name, "BOM");
           }
        strcpy(pathname, storage->path_name);
        report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);
        _PDMdebug(fname, "report_file = %s\n", report_file);

          /* Generate the report from the ris template using DBaccess */
          status = PDMreport_from_tmpfile (sch_passwd, 
                                                  "nfmpdmcat", templib, 
                                                  PDMexec->drawing, 
                                                  saname, 
                                                  file_name);
           if(status != PDM_S_SUCCESS) {
             _PDMdebug(fname, "%s %d\n", 
                       "PDMreport_from_tmpfile failed status", status);
            return(status);
           }
         }
          else {
        /* read the report to find out the attributes */
        PDMinit_psurpt(&psurpt);
        strcpy(psurpt.options.template_name, PDMexec->drawing); 
        strcpy(psurpt.templatetype, "L"); 
        status = PSUrs_load_rpt(&psurpt);
        if (status != MRP_S_Success) {
        _PDMdebug(s, "%s %d\n", "PSUrs_load_rpt failed status ", status);
           status = PDM_E_RPS_READ_FORMAT;
           goto wrapup;
          }

         if(!strcmp(PDMexec->dcatalog, "") &&  
                 !strcmp(psurpt.options.output, "")) {
          status    = PDMgen_file_name(file_name);
          if(status != PDM_S_SUCCESS)
                strcpy(file_name, "LOC");
          }
         else if ( strlen(PDMexec->dcatalog)) 
                                   strcpy(file_name, PDMexec->dcatalog);
         else if (strlen(psurpt.options.output)) 
                                   strcpy(file_name, psurpt.options.output);
         else {
            status    = PDMgen_file_name(file_name);
            if(status != PDM_S_SUCCESS)
                             strcpy(file_name, "LOC");
             }

        sql_str[0] = '\0';
        strcpy(pathname, storage->path_name);

       report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);
        _PDMdebug(fname, "report_file = %s\n", report_file);

        strcpy(psurpt.options.table , "nfmpdmcat");
        strcpy(psurpt.options.template_name, "");
        strcpy(psurpt.options.template_name , PDMexec->drawing);
        strcpy(psurpt.templatetype, "");
        strcpy(psurpt.templatetype, "L") ;
        strcpy(psurpt.options.title, "");
        msg = (char *)PDUtranslate_message(PDS_M_LIST_OF_CATALOGS);
        sprintf(psurpt.options.title , "%s\0",msg );
        strcpy(psurpt.options.description , " Catalogs in database");
        psurpt.options.subtotals = 0;
        psurpt.options.totals = 0;
        psurpt.where = (char *) malloc (5);
        strcpy(psurpt.where, "");
        strcpy(psurpt.options.output, "");
        strcpy(psurpt.options.output, report_file);

      sql_str[0] = '\0';
      sprintf(sql_str, "select p_level10 from nfmpdmcat where n_catalogname = 'pdmlibraries' ");

       status = SQLquery(sql_str, &check_bufr, 512);
       if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
         {
          status =  PDMcreate_nfmpdmcat_view();
          if (status != PDM_S_SUCCESS)
             {
     _PDMdebug(s, "%s %d\n", "PDMcreate_nfmpdmcat_view failed status ", status);
             return (PDM_E_RPS_READ_FORMAT);
             }
         }
        status = PSUexe_rpt(&psurpt, sch_passwd);
        if (status != MRP_S_Success) {
                _PDMdebug(fname, "PSUrs_cre_rpt failed status %d\n", status);
                status = PDM_E_OUTPUT_REPORT;
                goto wrapup;
        }
     } /* if it' not a template, but a RIStemplate file */
 
       /*
       status = dba_display_report(file_name);
        unlink(report_file); 
        */

     status = MEMopen(&bufr, 512);
     if (status != MEM_S_SUCCESS) {
         MEMclose(&bufr);
         _PDMdebug (fname, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
     status = MEMwrite_format(bufr, "n_cofilename", "char(50)");
     if (status != MEM_S_SUCCESS) {
         MEMclose(&bufr);
         _PDMdebug (fname, "MEMwrite_format failed status %d\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
     s[0]='\0';
     sprintf(s, "%s\1", file_name );
     _PDMdebug(fname, "moving file = %s\n", s);
     status = MEMwrite(bufr, s);
     if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMwrite failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_WRITE_ROW);
     }
     *return_buffer = bufr;
         /* rMRPfree_psurpt(&psurpt); */
     PDMdebug("EXIT:PDMreport_of_loc\n");
     return (PDM_S_SUCCESS);

wrapup:

        *return_buffer = NULL;
	PDMdebug("EXIT:PDMreport_of_loc - Error\n");
	return (status);
}
 
int PDMreport_of_catalog(return_buffer)
MEMptr		*return_buffer;
{
        static char     *fname = "PDMreport_of_catalog";
        char            e_cat[21], templib[21], output[51], temp_type[3];
	char            file_name[51], pathname[85], type[6];
	char            sql_str[200], report_file[120], saname[20];
        char            schema[100], passwd[100], sch_passwd[200];
        MEMptr          bufr = NULL, check_bufr = NULL;
        struct   PSUrpt psurpt;
        long         status1 = PDM_S_SUCCESS;
        int             catno;
        char            *msg = NULL;
        

	PDMdebug("ENTER:PDMreport_of_catalog\n");
 status =  PDMquery_catalogno_type(PDMexec->catalog, &catno, type);
         if(status != PDM_S_SUCCESS)
          {
        _PDMdebug (fname, "PDMquery_catalogno_type : status = <0x%.8x>\n", 
                    status);
                goto wrapup;
           }
         e_cat[0] = '\0';

         PDMconvert_to_lower(PDMexec->catalog, PDMexec->catalog);
         sprintf(e_cat, "e_%s", PDMexec->catalog);

        strcpy(saname, PDMexec->drevision);

        _PDMdebug(fname, "saname = %s\n", saname);
      _PDMdebug(fname, "Encrypted schema name %s\n", NFMglobal.NFMsch_name);
       status = NFMdecrypt(NFMglobal.NFMsch_name, schema);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Decrypy Schema Name : status = <0x%.8x>\n", 
                    status);
                goto wrapup;
      }
       status = NFMdecrypt(NFMglobal.NFMsch_passwd, passwd);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Decrypy Schema passwd : status = <0x%.8x>\n", 
                    status);
                goto wrapup;
      }

       sch_passwd[0] = '\0';
       sprintf(sch_passwd, "%s.%s", schema, passwd);

      sql_str[0] = '\0';
      sprintf(sql_str, "select p_level10 from nfmpdmcat where n_catalogname = 'pdmlibraries' ");

       status = SQLquery(sql_str, &check_bufr, 512);
       if(status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
         {
          status =  PDMcreate_nfmpdmcat_view();
          if (status != PDM_S_SUCCESS)
             {
     _PDMdebug(s, "%s %d\n", "PDMcreate_nfmpdmcat_view failed status ", status);
             return (PDM_E_RPS_READ_FORMAT);
             }
         }
           
               MEMclose(&check_bufr);

	/* read the report to find out the attributes */
       PDMconvert_to_lower(PDMexec->catalog, PDMexec->catalog); 
        /* Kumar - 9.7.92 to support RIS template - start*/

        temp_type[0] = '\0';
        strcpy (temp_type, "C");
        strcpy(psurpt.templatetype, "C");
        status = PDMquery_report_type(PDMexec->drawing, temp_type, templib, output);
        if(status != PDM_S_SUCCESS)
        {
        _PDMdebug(s, "%s %d\n", "PDMquery_report_type failed status ", status);
        status = PDM_E_RPS_READ_FORMAT;
        return(status);
        }
        if(temp_type[1] == 'F')
        {
        if(!strcmp(PDMexec->dcatalog, "") && PDMexec->dcatalog != NULL)
         {
          status    = PDMgen_file_name(file_name);
          if(status != PDM_S_SUCCESS) strcpy(file_name, "PARTS_LIST");
         }
         else if( strlen(PDMexec->dcatalog))strcpy(file_name, PDMexec->dcatalog);
         else if (strlen(output)) strcpy(file_name, output);
         else
           {
           status    = PDMgen_file_name(file_name);
           if(status != PDM_S_SUCCESS) strcpy(file_name, "PARTS_LIST");
           }
      strcpy(pathname, storage->path_name);
       report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);
        _PDMdebug(fname, "report_file = %s\n", report_file);
          /* Generate the report from the ris template using DBaccess */
         if(!strcmp(type, "EID") || !strcmp(type, "CID"))
          status = PDMreport_from_tmpfile(sch_passwd, e_cat, templib, PDMexec->drawing, saname, report_file);
          else
          status = PDMreport_from_tmpfile(sch_passwd, PDMexec->catalog, templib, PDMexec->drawing, saname, report_file);
           if(status != PDM_S_SUCCESS)
           {
             sprintf(sql_str, " select * from %s", PDMexec->catalog);
            status1 = SQLquery(sql_str , &check_bufr, 512);
             if(status1 == SQL_I_NO_ROWS_FOUND)
              {
    _PDMdebug(fname, "%s %d\n", "PDMreport_from_tmpfile failed status", status);
               MEMclose(&check_bufr);
               return(PDM_E_NO_PARTS_FOUND);
               }
             else
              {
               MEMclose(&check_bufr);
    _PDMdebug(fname, "%s %d\n", "PDMreport_from_tmpfile failed status", status);
            return(status);
               }
            }
           }
          else
         {
        PDMinit_psurpt(&psurpt);
       strcpy(psurpt.options.template_name, PDMexec->drawing);
         if(!strcmp(type, "EID") || !strcmp(type, "CID"))
       strcpy(psurpt.options.table , e_cat);
         else
       strcpy(psurpt.options.table , PDMexec->catalog);
        strcpy(psurpt.templatetype, "C"); 
        status = PSUrs_load_rpt(&psurpt);
        if (status != MRP_S_Success) {
        _PDMdebug(s, "%s %d\n", "PSUrs_load_rpt failed status ", status);
                status = PDM_E_RPS_READ_FORMAT;
                goto wrapup;
             }

          if(!strcmp(PDMexec->dcatalog, "") && !strcmp(psurpt.options.output, ""))
           {
            status    = PDMgen_file_name(file_name);
              if(status != PDM_S_SUCCESS)
            strcpy(file_name, "PARTS_LIST");
             }
        else if( strlen(PDMexec->dcatalog)) strcpy(file_name, PDMexec->dcatalog);
        else if ( strlen(psurpt.options.output)) strcpy(file_name, psurpt.options.output);
        else
         {
        status    = PDMgen_file_name(file_name);
      if(status != PDM_S_SUCCESS)
          strcpy(file_name, "PARTS_LIST");
         }
      sql_str[0] = '\0';
      strcpy(pathname, storage->path_name);
       report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);
        _PDMdebug(fname, "report_file = %s\n", report_file);
         if(!strcmp(type, "EID") || !strcmp(type, "CID"))
strcpy(psurpt.options.table , e_cat);
         else
         strcpy(psurpt.options.table , PDMexec->catalog);
strcpy(psurpt.options.template_name , PDMexec->drawing);
strcpy(psurpt.options.description , " LIST OF PARTS");
msg = (char *)PDUtranslate_message(PDS_M_LIST_OF_PARTS_RPT);
sprintf(psurpt.options.title , "%s of %s" , msg, PDMexec->catalog);
psurpt.options.totals = 0; 
 psurpt.where = (char *) malloc (50);
 strcpy(psurpt.where, "where n_itemno > 0");
strcpy(psurpt.options.output, report_file);
       sch_passwd[0] = '\0';
       sprintf(sch_passwd, "%s.%s", schema, passwd);

        status = PSUexe_rpt(&psurpt, sch_passwd);
        if (status != MRP_S_Success) {
             sprintf(sql_str, " select * from %s", PDMexec->catalog);
            status1 = SQLquery(sql_str , &check_bufr, 512);
             if(status1 == SQL_I_NO_ROWS_FOUND)
              {
    _PDMdebug(fname, "%s %d\n", "PDMreport_from_tmpfile failed status", status);
               MEMclose(&check_bufr);
               return(PDM_E_NO_PARTS_FOUND);
               }
                sprintf(s, "PSUrs_cre_rpt failed status %d\n", status);
                PDMdebug(s);
                status = PDM_E_OUTPUT_REPORT;
                goto wrapup;
        }
         rMRPfree_psurpt(&psurpt);
      }

 status = MEMopen(&bufr, 512);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_OPEN_BUFFER);
        }
status = MEMwrite_format(bufr, "n_cofilename", "char(50)");
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_OPEN_BUFFER);
        }
         s[0] = '\0';
        sprintf(s, "%s\1", file_name );
        _PDMdebug(fname, "moving file = %s\n", s);
        status = MEMwrite(bufr, s);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMwrite failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_WRITE_ROW);
        }
        *return_buffer = bufr;

       /*   unlink(report_file); */

	PDMdebug("EXIT:PDMreport_of_catalog\n");
	return (PDM_S_SUCCESS);

wrapup:

	PDMdebug("EXIT:PDMreport_of_catalog\n");
	return (status);
}


/* Written to support classification in reporting - Kumar */

int  PDMcreate_nfmpdmcat_view()
{
        char *fname = "PDMcreate_nfmpdmcat_view";
	char	sql_str[1024];

	_PDMdebug(fname, "ENTER:\n");
         sql_str[0]= '\0';
	sprintf(sql_str, "create view nfmpdmcat as select t1.n_catalogno, t1.n_catalogname, t1.n_catalogdesc , t1.n_creator, t1.n_creationdate, t1.n_updater, t1.n_updatedate, t1.n_identifier, t1.n_stateno, t1.n_aclno, t1.n_type, t1.n_archiveno, t1.n_archivestate, t1.n_pendingflag, t2.p_autofilename, t2.p_dyntable, t2.p_defname, t2.p_level1, t2.p_level2, t2.p_level3, t2.p_level4, t2.p_level5, t2.p_level6, t2.p_level7, t2.p_level8, t2.p_level9, t2.p_level10, t2.p_depth from nfmcatalogs t1 , pdmcatalogs t2 where t1.n_catalogno = t2. n_catalogno");
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		_PDMdebug(fname, "SQLstmt failed status %d\n", status);
		return(PDM_E_SQL_STMT);
	}
	_PDMdebug(fname, "EXIT:\n");
	return(PDM_S_SUCCESS);
 
}
