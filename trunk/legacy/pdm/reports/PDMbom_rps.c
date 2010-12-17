#include		<stdio.h>
#include		"PDUerror.h"
#include 		"PDMmessage.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include                "NFMschema.h"
#include                "NFMstruct.h"
#include        "dbadev.h"
#include        "rMRPstr.h"
#include        "MRPmessage.h"
#include                "PDUstorage.h"
#include		"PDMproto.h"
#include		"PDMbom_strct.h"


extern int dba_columns_per_page;
extern int      PDMdebug_on;
extern struct NFMglobal_st NFMglobal;
extern char     PDM_DEBUG_FILE[];
/* APOGEE START static long     RIScode; APOGEE END */
static int      status;
/*static int      curbuf_no;*/
static char     s[1024];
extern struct   PDUstorage   *storage;
extern PDMexec_ptr PDMexec;

/* Functionality to generate bom reports - Kumar 11/3/91 */

int 
PDMgen_bomparts_list(return_buffer)
MEMptr		*return_buffer;
{
        static  char    *fname ="PDMgen_bomparts_list";
        struct   PSUrpt psurpt;
	char            p_bomname[30], table_name[30], file_name[51];
	char            report_file[100], pathname[85];
	int              table_curr, setup_tbl;
	char            sql_str[200];
        char            templib[21], output[51], temp_type[3];
        char            schema[100], passwd[100], sch_passwd[200];
        MEMptr          bufr = NULL;
	char            date1[20], date2[20], saname[20];
        char            *msg = NULL;

	_PDMdebug(fname, "ENTER:\n");

	*return_buffer = NULL;

_PDMdebug (fname, "catalog = %s, n_itemname = %s & n_itemrev = %s\n", 
                PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
 

	/* check if bom exists .. quit if it does not */
	status = PDMi_find_bominfo(PDMexec->catalog, 
				   PDMexec->part_num, 
				   PDMexec->revision, 
				   p_bomname, date1);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fname, "PDMi_find_bominfo failed status 0x%.8x\n", status);
			return (status);
		}

         strcpy(saname, PDMexec->drevision);

	/* find if table exists */

	table_name[0] = '\0';
	status = PDMi_find_tableinfo(PDMexec->catalog, 
				     PDMexec->part_num, 
				     PDMexec->revision, "A", 
				     table_name, date2);
	if (status != PDM_S_SUCCESS &&
	    status != PDM_I_NO_ROWS_FOUND) {
	_PDMdebug(fname, "PDMi_find_tableinfo failed status 0x%.8x\n", status);
		return (status);
	}
	table_curr = 0;

	/* if table exists see if it is current */

	if (strlen(table_name)) {
		status = PDMi_compare_dates(date1, date2);
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
                if (status != SQL_S_SUCCESS)
		{
			sprintf(s, "SQLstmt failed status 0x%.8x\n", status);
			PDMdebug(s);
		}
	}
        PDMexec->operation = 1;
	if (setup_tbl) {
		status = PDMi_setup_table1(p_bomname, 
					   PDMexec->operation, table_name);
		if (status != PDM_S_SUCCESS) {
			sprintf(s, "PDMi_setup_table1 failed status 0x%.8x\n", 
				status);
			PDMdebug(s);
			return (status);
		}
	}
	if (setup_tbl) {
		status = PDMi_insert_pdmtables(PDMexec->catalog, 
					       PDMexec->part_num, 
					       PDMexec->revision, 
					       "A", table_name);
		if (status != PDM_S_SUCCESS) {
		}
	}
         SQLstmt("SET TRANSACTION AUTOCOMMIT ON");
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
        strcpy (temp_type, "O");

        status = PDMquery_report_type(PDMexec->drawing, temp_type, 
                                                          templib, output);
        if(status != PDM_S_SUCCESS)
        {
        _PDMdebug(s, "%s 0x%.8x\n", "PDMquery_report_type failed status ", status);
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
/*
          status = PDMreport_from_tmpfile(sch_passwd, table_name, PDMexec->drawing, "pdmloc_rpt", saname, file_name);
*/
          status = PDMreport_from_tmpfile(sch_passwd, table_name, templib,
                                        PDMexec->drawing, saname, file_name);
           if(status != PDM_S_SUCCESS)
           {
    _PDMdebug(fname, "%s %d\n", "PDMreport_from_tmpfile failed status", status);
            return(status);
           }
         }
          else
         {
         PDMinit_psurpt(&psurpt);
        /* read the report to find out the attributes  */
        strcpy(psurpt.options.template_name, PDMexec->drawing);
        strcpy(psurpt.templatetype, "O");
 
	status = PSUrs_load_rpt(&psurpt);
	if (status != MRP_S_Success) {
		sprintf(s, "RPSoutput_report failed status %d\n", status);
		PDMdebug(s);
		status = PDM_E_OUTPUT_REPORT;
		goto wrapup;
	}
      strcpy(psurpt.options.table , table_name);
      strcpy(psurpt.options.description , " LIST OF PARTS");
      msg = (char *)PDUtranslate_message(PDS_M_PARTS_LIST);
      sprintf(psurpt.options.title , "%s <%s-%s-%s>", msg, PDMexec->catalog, PDMexec->part_num, PDMexec->revision);
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

        if(!strcmp(PDMexec->dcatalog, "") || PDMexec->dcatalog == NULL)
         {
          status    = PDMgen_file_name(file_name);
          if(status != PDM_S_SUCCESS) strcpy(file_name, "PARTS_LIST");
         }
         else if(strlen(PDMexec->dcatalog))strcpy(file_name, PDMexec->dcatalog);
         else if(strlen(output)) strcpy(file_name, output);
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
      strcpy(psurpt.options.output, report_file);
	status = PSUexe_rpt(&psurpt, sch_passwd);
	if (status != MRP_S_Success) {
		sprintf(s, "RPSoutput_report failed status %d\n", status);
		PDMdebug(s);
		status = PDM_E_OUTPUT_REPORT;
		goto wrapup;
	}
       }
 status = MEMopen(&bufr, 512);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_OPEN_BUFFER);
        }
status = MEMwrite_format(bufr, "n_cofilename", "char(51)");
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
        /*  unlink(report_file);  */

         rMRPfree_psurpt(&psurpt);

	PDMdebug("EXIT:PDMgen_bomparts_list\n");
	return (PDM_S_SUCCESS);

wrapup:

	if (setup_tbl) {
                /*
		sprintf(sql_str, "DROP TABLE %s", table_name);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
		}
                 */
	}
	return (status);
}

int 
PDMi_setup_table1(bom, p_level, table_name)
char           *bom;
int             p_level;
char           *table_name;
{
	MEMptr          bufr = NULL;
	MEMptr          bufr1 = NULL;
	MEMptr          bufr2 = NULL;
	int             level;
        char            sql_str[512];
        char            table_num[20];

	PDMdebug("ENTER:PDMi_setup_table1\n");
	status = MEMopen(&bufr1, 1024);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMopen failed status %d\n", 
			status);
		PDMdebug(s);
		return (PDM_E_OPEN_BUFFER);
	}
		status = MEMwrite_format(bufr1, "p_tagno", "integer");
	if (status == MEM_S_SUCCESS)
		status = MEMwrite_format(bufr1, "p_quantity", "double");
	if (status == MEM_S_SUCCESS)
                status = MEMwrite_format(bufr1, "p_alttagno", "char(25)");  
	if (status == MEM_S_SUCCESS)
                status = MEMwrite_format(bufr1, "n_itemdesc", "char(40)");  
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr1);
		sprintf(s, "MEMwrite_format failed status %d\n", 
			status);
		PDMdebug(s);
		return (PDM_E_OPEN_BUFFER);
	}
	level = 0;
	sprintf(sql_str, "SELECT DISTINCT %s FROM %s %s %d %s %d", 
		"n_catalogname, n_itemname, n_itemrev, n_level ", bom, 
		"WHERE n_level > ", level, 
		"AND n_level <= ", p_level);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr1);
		sprintf(s, "SQLquery failed status %d\n", 
			status);
		PDMdebug(s);
		return (PDM_E_SQL_QUERY);
	}
	status = PDMexpand_copy_buffer(bufr, bufr1, &bufr2);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMexpand_copy_buffer failed status %d\n", 
			status);
		PDMdebug(s);
		return (status);
	}
	MEMclose(&bufr);
	MEMclose(&bufr1);
	status = PDMload_seq_tagnos(bom, bufr2);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&bufr2);
		sprintf(s, "PDMload_seq_tagnos failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	status = PDMgen_table_name(table_num);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&bufr2);
		sprintf(s, "PDMgen_table_name failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
        sprintf(table_name, "PDMA%s", table_num);
        sprintf(s, "TABLE NAME = %s\n", table_name); 
        PDMdebug(s);
	status = PDMcreate_ris_table(table_name, bufr2, NULL, NULL);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&bufr2);
		sprintf(s, "PDMcreate_ris_table failed status %d\n", status);
		PDMdebug(s);
		return (status);
	}
	PDMdebug("EXIT:PDMi_setup_table1\n");
	return (PDM_S_SUCCESS);
}

int 
PDMload_seq_tagnos(bom, bufr)
char           *bom;
MEMptr          bufr;
{
	int             n1, n2, n3, n4, n6, n7, n8, n9, i, nx;
	char          **data, **columns;
	char            p_tagno[50];
        char            p_alttagno[26], p_quantity[50];
        char            n_itemdesc[40];

	PDMdebug("ENTER:PDMload_seq_tagnos\n");
	if (PDMdebug_on) {
		MEMprint_buffer("bufr at ENTER", bufr, PDM_DEBUG_FILE);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	n1 = -1;
	n2 = -1;
	n3 = -1;
	n4 = -1;
	n6 = -1;
        n7 = -1;
        n8 = -1;
        n9 = -1;

	data = (char **) bufr->data_ptr;
	columns = (char **) bufr->column_ptr;
	for (i = 0; i < bufr->columns; i++) {
		if (!strcmp(columns[i], "n_catalogname"))
			n1 = i;
		if (!strcmp(columns[i], "n_itemname"))
			n2 = i;
		if (!strcmp(columns[i], "n_itemrev"))
			n3 = i;
		if (!strcmp(columns[i], "n_level"))
			n4 = i;
		if (!strcmp(columns[i], "p_tagno"))
			n6 = i;
		if (!strcmp(columns[i], "p_alttagno"))
			n7 = i;
		if (!strcmp(columns[i], "p_quantity"))
			n8 = i;
		if (!strcmp(columns[i], "n_itemdesc"))
			n9 = i;
	}
	if (n1 == -1 || n2 == -1 || n3 == -1 ||
	    n4 == -1 || n6 == -1 || n7 == -1 || n8 == -1 || n9 == -1           ) {
		sprintf(s, "Couldnot set offsets in bufr \n");
		PDMdebug(s);
		return (PDM_E_BUFFER_FORMAT);
	}
	for (i = 0; i < bufr->rows; i++) {
		nx = i * bufr->columns;
			status = PDMi_find_seqtagnos(bom, 
						     data[nx + n1], 
						     data[nx + n2], 
						     data[nx + n3], 
						     atoi(data[nx + n4]), 
						     p_tagno, 
                                                     p_alttagno, 
                                                     p_quantity, 
                                                     n_itemdesc);
			if (status != PDM_S_SUCCESS) {
				sprintf(s, "PDMi_find_seqtagnos failed status %d\n", 
					status);
				PDMdebug(s);
			}
                        sprintf(s, "P_TAGNO = %s", p_tagno);
                        PDMdebug(s);
                        sprintf(s, "P_ALTTAGNO = %s", p_alttagno);
                        PDMdebug(s);
                        sprintf(s, "P_QUANTITY = %s", p_quantity);
                        PDMdebug(s);
                        sprintf(s, "P_PARTDESC = %s", n_itemdesc);
                        PDMdebug(s);
			status = MEMwrite_data(bufr, p_tagno, i + 1, n6 + 1);
			if (status != MEM_S_SUCCESS) {
				sprintf(s, "MEMwrite_data failed status %d\n", 
					status);
				PDMdebug(s);
				return (PDM_E_WRITE_COLUMN);
			}
		        status = MEMwrite_data(bufr, p_alttagno, i + 1, n7 + 1);
			if (status != MEM_S_SUCCESS) {
				sprintf(s, "MEMwrite_data failed status %d\n", 
					status);
				PDMdebug(s);
				return (PDM_E_WRITE_COLUMN);
                        }
		        status = MEMwrite_data(bufr, p_quantity, i + 1, n8 + 1);
			if (status != MEM_S_SUCCESS) {
				sprintf(s, "MEMwrite_data failed status %d\n", 
					status);
				PDMdebug(s);
				return (PDM_E_WRITE_COLUMN);
                        }
		        status = MEMwrite_data(bufr, n_itemdesc, i + 1, n9 + 1);
			if (status != MEM_S_SUCCESS) {
				sprintf(s, "MEMwrite_data failed status %d\n", 
					status);
				PDMdebug(s);
				return (PDM_E_WRITE_COLUMN);
                        }
	}
	if (PDMdebug_on) {
		MEMprint_buffer("bufr at EXIT", bufr, PDM_DEBUG_FILE);
	}
	PDMdebug("EXIT:PDMload_seq_tagnos\n");
	return (PDM_S_SUCCESS);
}

int PDMi_find_seqtagnos(bom, cat, part, rev, level, 
                        tagno, alttagno, quantity, desc)
char           *bom;
char           *cat;
char           *part;
char           *rev;
int             level;
char           *tagno;
char           *alttagno;
char           *quantity;  
char           *desc;
{

	MEMptr          bufr = NULL;
	char            sql_str[200];
	char          **data;

	PDMdebug("ENTER:PDMi_find_seqtagnos \n");
	sprintf(sql_str, "%s %s %s '%s' %s '%s' %s '%s' %s %d", 
		"SELECT p_tagno, p_alttagno, n_itemdesc FROM ", bom, 
		"WHERE n_catalogname = ", cat, 
		"AND n_itemname = ", part, 
		"AND n_itemrev = ", rev, 
		"AND n_level = ", level);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			sprintf(s, "%s %s %s %s in %s\n", 
			"Could not find entry ", cat, part, rev, level, bom);
			PDMdebug(s);
			return (PDM_I_NO_ROWS_FOUND);
		}
		return (PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	if (strlen(data[0])) {
		strcpy(tagno, data[0]);
	} else {
		PDMdebug("p_tagno is not found\n");
	}
	if (strlen(data[1])) {
		strcpy(alttagno, data[1]);
	} else {
		strcpy(alttagno, "");
	}
	if (strlen(data[2])) {
		strcpy(desc, data[2]);
	} else {
		strcpy(desc, "");
	}
	MEMclose(&bufr);
        sql_str[0] = '\0';
        sprintf(sql_str, "%s %s %s '%s' %s '%s' %s '%s' %s %d", 
                "SELECT sum(p_quantity) FROM ", bom, 
		"WHERE n_catalogname = ", cat, 
		"AND n_itemname = ", part, 
		"AND n_itemrev = ", rev, 
		"AND n_level = ", level);
	status = SQLquery(sql_str, &bufr, 1024);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		if (status == SQL_I_NO_ROWS_FOUND) {
			sprintf(s, "%s '%s' '%s' '%s' %d in %s\n", 
			"Could not find entry ", cat, part, rev, level, bom);
			PDMdebug(s);
			return (PDM_I_NO_ROWS_FOUND);
		}
		return (PDM_E_SQL_QUERY);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS) {
		MEMclose(&bufr);
		sprintf(s, "MEMbuild_array failed status %d\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	}
	data = (char **) bufr->data_ptr;
	if (strlen(data[0])) {
		strcpy(quantity, data[0]);
	} else {
		PDMdebug("p_quantity is not found\n");
	}
        MEMclose(&bufr);
	PDMdebug("EXIT:PDMi_find_seqtagnos \n");
	return (PDM_S_SUCCESS);
}


int PDMgen_summary_bom(return_buffer)
MEMptr 		*return_buffer;
{
       static   char    *fname = "PDMgen_summary_bom";
	char            p_bomname[30], table_name[30], file_name[51];
        char            report_file[100], pathname[85];
        char            schema[100], passwd[100], sch_passwd[200];
        char            templib[21], output[51], temp_type[3];
        MEMptr          bufr = NULL;
	int              table_curr, setup_tbl;
	char            sql_str[200];
	char            date1[20], date2[20], saname[20];
        struct PSUrpt   psurpt;
        char            *msg = NULL;

	PDMdebug("ENTER:PDMgen_summary_bom\n");

	*return_buffer = NULL;
        saname[0] = '\0';
        strcpy (saname, PDMexec->drevision);
	/* check if bom exists .. quit if it does not */
	status = PDMi_find_bominfo(PDMexec->catalog, 
				   PDMexec->part_num, 
				   PDMexec->revision, 
				   p_bomname, date1);
	if (status != PDM_S_SUCCESS && status != PDM_I_NO_ROWS_FOUND) {
        _PDMdebug(fname, "PDMi_find_bominfo failed status %d\n", status);
			return (status);
	}
           if(status == PDM_I_NO_ROWS_FOUND)
             {
               status = PDMupdate_exist_bom(p_bomname);
	if (status != PDM_S_SUCCESS ) {
        _PDMdebug(fname, "PDMgenerate_bom failed status %d\n", status);
			return (status);
	                               }
	status = PDMi_find_bominfo(PDMexec->catalog, 
				   PDMexec->part_num, 
				   PDMexec->revision, 
				   p_bomname, date1);
	if (status != PDM_S_SUCCESS && status != PDM_I_NO_ROWS_FOUND) {
        _PDMdebug(fname, "PDMi_find_bominfo failed status %d\n", status);
			return (status);
	                                }
               }
	/* find if table exists */
	table_name[0] = '\0';
	status = PDMi_find_tableinfo(PDMexec->catalog, 
				     PDMexec->part_num, 
				     PDMexec->revision, 
				     "B", table_name, date2);
	if (status != PDM_S_SUCCESS &&
	    status != PDM_I_NO_ROWS_FOUND) {
		_PDMdebug(fname, "PDMi_find_tableinfo failed status %d\n", 
			status);
		return (status);
	}
	table_curr = 0;
	/* if table exists see if it is current */
	if (strlen(table_name)) {
		status = PDMi_compare_dates(date1,  date2);
		if (status == 1) {
			table_curr = 1;
		} else {
			table_curr = 0;
		}
	  }
	table_curr = 0;
         
	/*
	 * generate table only if it does not exist OR exists but not current
	 */

	if (!strlen(table_name) ||
	    (strlen(table_name) && (!table_curr)))
             {
		sprintf(sql_str, "DROP TABLE %s", table_name);
                status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS)
                _PDMdebug(fname, "SQLstmt failed status %d\n", status);
		setup_tbl = 1;
	} else setup_tbl = 0;

	if (setup_tbl) {
	status = PDMi_setup_table2(p_bomname, PDMexec->operation, table_name);
		if (status != PDM_S_SUCCESS) {
	_PDMdebug(s, "PDMi_setup_table2 failed status %d\n", status);
			return (status);
		}
	}
	if (setup_tbl) {
		status = PDMi_insert_pdmtables(PDMexec->catalog, 
					       PDMexec->part_num, 
					       PDMexec->revision, 
					       "B", table_name);
		if (status != PDM_S_SUCCESS) {
		}
	}
         SQLstmt("SET TRANSACTION AUTOCOMMIT ON");

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

      /* fix to pass the template type so that we get
         The template type may be ? or ?F, the following
         function retrieves the correct type when we pass
         "?" MaC 051193
         ...*/

        temp_type[0] = '\0';
        strcpy (temp_type, "S");


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
          if(status != PDM_S_SUCCESS) strcpy(file_name, "SUMMARY_BOM");
         }
         else if( strlen(PDMexec->dcatalog))strcpy(file_name, PDMexec->dcatalog);
         else if (strlen(output)) strcpy(file_name, output);
         else
           {
           status    = PDMgen_file_name(file_name);
 if(status != PDM_S_SUCCESS) strcpy(file_name, "SUMMARY_BOM");
           }
      strcpy(pathname, storage->path_name);
      report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);
        _PDMdebug(fname, "report_file = %s\n", report_file);
          /* Generate the report from the ris template using DBaccess */
/*
          status = PDMreport_from_tmpfile(sch_passwd, PDMexec->catalog, templib, PDMexec->drawing, saname, report_file);
*/
          status = PDMreport_from_tmpfile (sch_passwd, 
                                            table_name, 
                                            templib, 
                                            PDMexec->drawing, 
                                            saname, 
                                            report_file);
           if(status != PDM_S_SUCCESS)
           {
    _PDMdebug(fname, "%s %d\n", "PDMreport_from_tmpfile failed status", status);
            return(status);
           }
         }
          else
         {
        if((!strcmp(output, "") || output == NULL) && (!strcmp(PDMexec->dcatalog, "") || PDMexec->dcatalog == NULL))
         {
          status    = PDMgen_file_name(file_name);
          if(status != PDM_S_SUCCESS) strcpy(file_name, "SUMMARY_BOM");
         }
         else if( strlen(PDMexec->dcatalog))strcpy(file_name, PDMexec->dcatalog);
         else if (output != NULL && strcmp(output, "")) strcpy(file_name, output);
         else
           {
           status    = PDMgen_file_name(file_name);
 if(status != PDM_S_SUCCESS) strcpy(file_name, "SUMMARY_BOM");
           }
        /* read the report to find out the attributes */
         strcpy(saname, PDMexec->drevision);
         PDMinit_psurpt(&psurpt);
        strcpy(psurpt.options.template_name, PDMexec->drawing);
        strcpy(psurpt.templatetype, "S");
	status = PSUrs_load_rpt(&psurpt);
	if (status != MRP_S_Success) {
	_PDMdebug(s, "%s %d\n", "PSUrs_load_rpt failed status ", status);
		status = PDM_E_RPS_READ_FORMAT;
		goto wrapup;
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
    msg = (char *)PDUtranslate_message(PDS_M_SUMMARY_BOM);
    sprintf(psurpt.options.title, "%s <%s-%s-%s>", msg,PDMexec->catalog, PDMexec->part_num, PDMexec->revision );
    psurpt.where = (char *) malloc (5);
    strcpy(psurpt.where, "");
    strcpy(psurpt.options.output, report_file);
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
                sprintf(s, "PSUexe_rpt failed status %d\n", status);
                PDMdebug(s);
                status = PDM_E_OUTPUT_REPORT;
                goto wrapup;
        }
     }


 status = MEMopen(&bufr, 512);
        if (status != MEM_S_SUCCESS) {
                MEMclose(&bufr);
                sprintf(s, "MEMwrite_format failed status %d\n", status);
                PDMdebug(s);
                return (PDM_E_OPEN_BUFFER);
        }
status = MEMwrite_format(bufr, "n_cofilename", "char(51)");
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

         rMRPfree_psurpt(&psurpt);

	PDMdebug("EXIT:PDMgen_summary_bom\n");
	return (PDM_S_SUCCESS);

wrapup:

	if (setup_tbl) {
            /*
		sprintf(sql_str, "DROP TABLE %s", table_name);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			sprintf(s, "SQLstmt failed status %d\n", status);
			PDMdebug(s);
			return (PDM_E_SQL_STMT);
		}
               */
	}
	return (status);

}

int PDMi_setup_table2(bom, req_level, table_name)
char           *bom;
int             req_level;
char           *table_name;
{
	MEMptr          bufr = NULL;
        char            *fname = "PDMi_setup_table2";
	double           quantity;
	int             max_level;
	char            sql_str[512], s_s[50];
        char            table_num[20];
	char          **data, **columns, **format;
	int             i, j, nxi, nxj;
	int             n1, n2, n3, n4, n5, n7;

	_PDMdebug(fname, "ENTER:\n");
	if (req_level == -1) 
          {
	   status = PDMi_maxrow_no(bom, "n_level", &max_level);
	   if (status != PDM_S_SUCCESS) 
             {
	      _PDMdebug(fname, "PDMi_maxrow_no failed status %d\n", 
				status);
			return (status);
	      }
	   } else max_level = req_level;
	
	status = PDMi_query_non_assemblies(bom, &bufr, max_level);
	if (status != PDM_S_SUCCESS) 
        {
	_PDMdebug(fname, "PDMi_query_non_assemblies failed status %d\n", 
			status);
	return (status);
	}
	status = MEMbuild_array(bufr);
	if (status != MEM_S_SUCCESS)
         {
	MEMclose(&bufr);
	_PDMdebug(fname, "MEMbuild_array failed status %d\n", 
			status);
	return (PDM_E_BUILD_ARRAY);
	}

	if (PDMdebug_on)
	MEMprint_buffer("SUMMARY BUFFER", bufr, PDM_DEBUG_FILE);

         NFMRtic_it (bufr);

	n1 = -1;
	n2 = -1;
	n3 = -1;
	n4 = -1;
	n5 = -1;
        n7 = -1;
	data = (char **) bufr->data_ptr;
	columns = (char **) bufr->column_ptr;
	format = (char **) bufr->format_ptr;
	for (j = 0; j < bufr->columns; j++) {
		if (!strcmp(columns[j], "n_level"))
			n1 = j;
		if (!strcmp(columns[j], "n_catalogname"))
			n2 = j;
		if (!strcmp(columns[j], "n_itemname"))
			n3 = j;
		if (!strcmp(columns[j], "n_itemrev"))
			n4 = j;
		if (!strcmp(columns[j], "p_quantity"))
			n5 = j;
		if (!strcmp(columns[j], "n_itemdesc"))
			n7 = j;

	}
	if (n1 == -1 || n2 == -1 || n3 == -1 ||
	    n4 == -1 || n5 == -1 || n7 == -1) {
		MEMclose(&bufr);
		_PDMdebug(fname, "Couldnot set offsets in bufr \n");
		return (PDM_E_BUFFER_FORMAT);
	}

        for (j = 0; j < bufr->rows; j++) {
	  nxj = j * bufr->columns;

          /* Fix to save the decimal pt for quantity */
	  /*quantity = atol(data[nxj + n5]);*/
          status = _PDMasc_to_doub (data[nxj + 5], &quantity);
          _PDMdebug ("quantity", "[%f]\n", quantity);
       
	  sprintf(s_s, "%f" , quantity);
	  status = MEMwrite_data(bufr, s_s, j + 1, n5 + 1);
	  if (PDMdebug_on)
	      MEMprint_buffer("QTY BUFF\n", bufr, PDM_DEBUG_FILE);
	  if (status != MEM_S_SUCCESS) 
              {
	      MEMclose(&bufr);
	      _PDMdebug(fname, "MEMwrite_data failed status %d\n", 
					status);
	        return (PDM_E_WRITE_COLUMN);
	     	}
          }
	  status = PDMgen_table_name(table_num);
	  if (status != PDM_S_SUCCESS) {
	  	MEMclose(&bufr);
          	_PDMdebug(fname, "PDMgen_table_name failed status %d\n", status);
		return (status);
  	      }
          sprintf(table_name, "PDMB%s", table_num);
	  _PDMdebug(fname, "TABLE NAME = %s", table_name);
	  sprintf(sql_str, "CREATE TABLE %s (%s %s, %s %s, %s %s, %s, %s %s) ", 
		table_name, 
		"n_catalogname ", format[n2], 
		"n_itemname ", format[n3], 
		"n_itemrev ", format[n4], 
		"p_quantity double", 
                "n_itemdesc ", format[n7]);
	  status = SQLstmt(sql_str);
   
	  if (status != SQL_S_SUCCESS) {
		MEMclose(&bufr);
		return (PDM_E_SQL_STMT);
	    }
           PDMstop_transaction(1200);

	  sprintf(s, "INSERT INTO %s (%s) ", 
		table_name, 
		"n_catalogname, n_itemname, n_itemrev, p_quantity, n_itemdesc");
	         for (i = 0; i < bufr->rows; i++)
             {
	      nxi = i * bufr->columns;
	     sprintf(sql_str, "%s VALUES ('%s', '%s', '%s', %s, '%s')", s, 
				data[nxi + n2], data[nxi + n3], 
				data[nxi + n4], data[nxi + n5], data[nxi + n7]);
		status = SQLstmt(sql_str);
		if (status != SQL_S_SUCCESS) {
			MEMclose(&bufr);
                         PDMrollback_transaction(1200);
			return (PDM_E_SQL_STMT);
		}
	}
         PDMstart_transaction(1200);
	MEMclose(&bufr);
	_PDMdebug(fname, "EXIT:\n");
	return (PDM_S_SUCCESS);
}

int PDMi_query_non_assemblies(bom, bufr, max_level)
char           *bom;
MEMptr         *bufr;
int             max_level;
{
	int             i, k;
        char            *fn = "PDMi_query_non_assemblies";
	/*char            sql_str[512];*/
	char            qty_val[128];
	char            part_num[128];
	char            part_rev[128];
	char            description[240];
        char		**data, **columns;
        char		**assy_data, **assy_columns;
	MEMptr		n_assy_bufr = NULL;
        int		index, assy_index, duplicate;
        double          quantity = 0.0;
        double          new_quantity = 0.0;
	char		n_setindicator[10], mem_str[1024];


	_PDMdebug(fn, "ENTER:\n");

        _PDMdebug (fn, "bom[%s] max_level[%d]\n", bom, max_level);
        n_setindicator[0] = '\0';
        mem_str[0] = '\0';
        qty_val[0] = '\0';
        description[0] = '\0';
        index = 0;
        assy_index = 0;

   /* suppport added to fix getting non assys MaC 060693 */


     status = MEMopen(&n_assy_bufr, 512);
     if (status != MEM_S_SUCCESS) {
         MEMclose(&n_assy_bufr);
         _PDMdebug (fn, "MEMopen failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
         }

      status = MEMwrite_format(n_assy_bufr, "p_tagno", "integer");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&n_assy_bufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(n_assy_bufr, "n_catalogname", "char(51)");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&n_assy_bufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(n_assy_bufr, "n_itemname", "char(51)");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&n_assy_bufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(n_assy_bufr, "n_itemrev", "char(51)");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&n_assy_bufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(n_assy_bufr, "n_level", "integer");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&n_assy_bufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(n_assy_bufr, "p_quantity", "double");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&n_assy_bufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(n_assy_bufr, "n_itemdesc", "char(40)");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&n_assy_bufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }

       status =  PDMGetChildListBufr(bom, bufr, max_level);
	if (status != PDM_S_SUCCESS) {
          _PDMdebug (fn, "PDMGetChildListBufr failed status 0x%.8x\n", status);
          return (status);
	    }
       
	status = MEMbuild_array (*bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status 0x%.8x\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	    }
       
	data = (char **) (*bufr)->data_ptr;
	columns = (char **) (*bufr)->column_ptr;

	for (i = 0; i < (*bufr)->rows; i++) {
          index = (*bufr)->columns * i;
          
          n_setindicator [0] = '\0';
          description [0] = '\0';
/*  Changed this to a new function.
    Reason : External Catalogs (PXT, EXT and EID) have
             alternate partnums instead of regular.  This
             requires that we query using itemnos instead of itemnames.
    MaC 050194

          status = PDMquery_assembly_ind( data[index + 1], 
                                           data[index + 2], 
                                           data[index + 3], 
                                           n_setindicator);
  */

          status = PDMQueryAssyIndGivenPartno ( data[index + 1], 
                                                atol (data[index + 7]), 
                                                n_setindicator);
          if (status != PDM_S_SUCCESS) {
             MEMclose(&n_assy_bufr);
             _PDMdebug (fn, 
                "PDMQueryAssyIndGivenPartno failed status 0x%.8x\n", status);
             return (PDM_E_OPEN_BUFFER);
            }

         status = PDMi_get_partnum_rev_desc (data[index + 1], 
                                             atol (data[index + 7]),
                                             part_num, part_rev, description);
         if (status != PDM_S_SUCCESS) {
             MEMclose(&n_assy_bufr);
             _PDMdebug (fn, 
                "PDMi_get_partnum_rev_desc  failed status 0x%.8x\n", status);
             return (PDM_E_OPEN_BUFFER);
            }

          _PDMdebug (fn, "[%s].[%s].[%s] -> setind[%s]\n", data[index + 1], 
                                           data[index + 2], 
                                           data[index + 3], 
                                           n_setindicator);
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
           if ((strcmp (n_setindicator, "Y")) && 
                           (strcmp (n_setindicator, "y")))
*/
           if ((strcmp (n_setindicator, "Y")) && 
               (strcmp (n_setindicator, "y")) &&
               (strcmp (n_setindicator, "A")) &&
               (strcmp (n_setindicator, "a"))) {
           /* support added to get the unique atomic parts */

/**/
	   status = MEMbuild_array (n_assy_bufr);
           if (status != MEM_S_SUCCESS) {
              MEMclose(&n_assy_bufr);
              _PDMdebug (fn, "MEMbuild_array (n_assy_bufr failed 0x%.8x\n", 
                                                                      status);
              return (PDM_E_WRITE_ROW);
              }
/**/
          
	   assy_data = (char **) (n_assy_bufr)->data_ptr;
	   assy_columns = (char **) (n_assy_bufr)->column_ptr;
           duplicate = 0;
           for (k=0; k<n_assy_bufr->rows; k++) {
             assy_index = k * n_assy_bufr->columns;
             if ( (!strcmp (data[index + 1], assy_data[assy_index + 1])) &&
                  (!strcmp (data[index + 2], assy_data[assy_index + 2])) &&
                  (!strcmp (data[index + 3], assy_data[assy_index + 3])) ) {
                 _PDMdebug (fn, "Duplicate part: [%s].[%s].[%s]\n", 
                                               data[index + 1], 
                                               data[index + 2], 
                                               data[index + 3]);

                  /* Incrementing the quantity */
              duplicate = 1;
              quantity = 0.0;
              status = _PDMasc_to_doub (assy_data[assy_index + 5], &quantity);
              _PDMdebug ("quantity", "[%f]\n", quantity);
              new_quantity = 0.0;
              status = _PDMasc_to_doub (data[index + 5], &new_quantity);
              _PDMdebug ("new_quantity", "[%f]\n", new_quantity);
              quantity = quantity + new_quantity;
              _PDMdebug (fn, "quantity [%f]\n", quantity);
              sprintf (qty_val, "%f", quantity);
              status = MEMwrite_data(n_assy_bufr, qty_val, k + 1, 6);
              if (status != MEM_S_SUCCESS) {
                MEMclose (&n_assy_bufr);
                _PDMdebug (fn, "MEMwrite_data failed status 0x%.8x\n", status);
                return (PDM_E_WRITE_COLUMN);
                 }
               break;
               }
              }
                 

          if (duplicate == 0) {
        
            mem_str[0] = '\0';
            sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1", data[index + 0], 
                                                             data[index + 1], 
                                                             data[index + 2], 
                                                             data[index + 3], 
                                                             data[index + 4], 
                                                             data[index + 5], 
                                                             description);

             _PDMdebug ("mem_str", "%s\n", mem_str);
             status = MEMwrite (n_assy_bufr, mem_str);
             if (status != MEM_S_SUCCESS) {
                     MEMclose(&n_assy_bufr);
                     _PDMdebug (fn, "MEMwrite failed status 0x%.8x\n", status);
                     return (PDM_E_WRITE_ROW);
                  }
                }
               }
           }
   
         MEMclose (bufr);
         *bufr = n_assy_bufr;

        if (PDMdebug_on)
        MEMprint_buffer("NON-ASSEMBLY BUFFER", *bufr, PDM_DEBUG_FILE);
	_PDMdebug(fn, "EXIT:\n");
	return (PDM_S_SUCCESS);
}


int PDMGetChildListBufr(bom, bufr, max_level)
char           *bom;
MEMptr         *bufr;
int             max_level;
{
        char            *fn = "PDMGetChildListBufr";
	char            qty_val[128];
	MEMptr		ChildrenBufr = NULL;
        int		index, assy_index;
        int		nchildren;
        int		partno, catno;
	char		n_setindicator[10], mem_str[2096];
/* added for fix in qty problem */
        struct        PDMbom_member *temp_mem, *cur_mem, *head, *end;
        double          Qty = 1.0;
        long PDMRetrieveMembersWithModifiedQty ();


	_PDMdebug(fn, "ENTER:\n");

        _PDMdebug (fn, "bom[%s] max_level[%d]\n", bom, max_level);
        n_setindicator[0] = '\0';
        mem_str[0] = '\0';
        qty_val[0] = '\0';
        index = 0;
        assy_index = 0;

  /* load the struct with 1st level children_info */

  head = end = (struct PDMbom_member *) calloc (1,
                               sizeof (struct PDMbom_member));

  if (head == (struct PDMbom_member *) NULL ) {
    NFMrollback_transaction (0);
    _PDMdebug (fn, "Allocating %d failed \n", 
                sizeof (struct PDMbom_member));
    return (NFM_E_MALLOC);
  }


   status = PDMquery_catalog_partnos (PDMexec->catalog,
                                      PDMexec->part_num,
                                      PDMexec->revision,
                                      &catno, &partno);
   if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, 
        "PDMquery_catalog_partnos failed status 0x%.8x\n", status);
      return (status);
      }
  head->level = 0;
  head->flag = 1;
  head->cat_no = catno;
  head->item_no = partno;
  strcpy (head->type, "P");
  strcpy (head->cat_name, PDMexec->catalog);
  strcpy (head->item_name, PDMexec->part_num);
  strcpy (head->item_rev, PDMexec->revision);
  /*strcpy (head->cat_name, catalog_name);*/

  nchildren = 1;
     _PDMprint_bommember ("head", head);

    _PDMdebug (fn, "Loading Parent structure ...\n");

   status =  PDMRetrieveMembersWithModifiedQty (catno, partno, 0, 
                                                1, head, end, 
                                                &nchildren, Qty);
   if (status != PDM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
      _PDMdebug (fn, 
        "PDMRetrieveMembersWithModifiedQty failed status 0x%.8x\n", status);
      return (status);
      }

  for (cur_mem = head->next; 
              cur_mem != (struct PDMbom_member *) NULL;
                cur_mem = cur_mem->next)
                {
     _PDMprint_bommember ("cur_mem", cur_mem);
   }


     status = MEMopen(&ChildrenBufr, 512);
     if (status != MEM_S_SUCCESS) {
         MEMclose(&ChildrenBufr);
         _PDMdebug (fn, "MEMopen failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
         }

      status = MEMwrite_format(ChildrenBufr, "p_tagno", "integer");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&ChildrenBufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(ChildrenBufr, "n_catalogname", "char(51)");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&ChildrenBufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(ChildrenBufr, "n_itemname", "char(51)");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&ChildrenBufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(ChildrenBufr, "n_itemrev", "char(51)");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&ChildrenBufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(ChildrenBufr, "n_level", "integer");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&ChildrenBufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(ChildrenBufr, "p_quantity", "double");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&ChildrenBufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(ChildrenBufr, "n_itemdesc", "char(40)");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&ChildrenBufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }
      status = MEMwrite_format(ChildrenBufr, "n_itemno", "integer");
      if (status != MEM_S_SUCCESS) {
         MEMclose(&ChildrenBufr);
         _PDMdebug (fn, "MEMwrite_format failed status 0x%.8x\n", status);
         return (PDM_E_OPEN_BUFFER);
        }


/*
	status = MEMbuild_array (*bufr);
	if (status != MEM_S_SUCCESS) {
		sprintf(s, "MEMbuild_array failed status 0x%.8x\n", status);
		PDMdebug(s);
		return (PDM_E_BUILD_ARRAY);
	    }
       
	data = (char **) (*bufr)->data_ptr;
	columns = (char **) (*bufr)->column_ptr;
*/

  for (cur_mem = head->next; 
              cur_mem != (struct PDMbom_member *) NULL;
                cur_mem = cur_mem->next)
                {
_PDMdebug (fn, "itemno = %sX%d\n", cur_mem->quantity, cur_mem->item_no);
            mem_str[0] = '\0';
            sprintf (mem_str, "%d\1%s\1%s\1%s\1%d\1%s\1\1%d\1", 
                          cur_mem->tagno,
                          cur_mem->cat_name,
                          cur_mem->item_name,
                          cur_mem->item_rev,
                          cur_mem->level,
                          cur_mem->quantity,
                          cur_mem->item_no);

             _PDMdebug ("mem_str", "%s\n", mem_str);
             status = MEMwrite (ChildrenBufr, mem_str);
             if (status != MEM_S_SUCCESS) {
                     MEMclose(&ChildrenBufr);
                     _PDMdebug (fn, "MEMwrite failed status 0x%.8x\n", status);
                     return (PDM_E_WRITE_ROW);
                  }
                }
   
         *bufr = ChildrenBufr;

  _PDMdebug (fn, "freeing PDMbom_member struct ...\n");
  for (cur_mem = head; cur_mem != (struct PDMbom_member *) NULL; ) {
      temp_mem = cur_mem;
      cur_mem = cur_mem->next;
      _PDMdebug (fn, "freeing cat[%s] item[%s] ...\n",
                            temp_mem->cat_name, temp_mem->item_name);
      if (temp_mem) free ( temp_mem );
  }
  _PDMdebug (fn, "done freeing ...\n");


        if (PDMdebug_on)
        MEMprint_buffer("NON-ASSEMBLY BUFFER", *bufr, PDM_DEBUG_FILE);
	_PDMdebug(fn, "EXIT:\n");
	return (PDM_S_SUCCESS);
}


/* 
   This function should be in ../bom/PDMbom_assy.c. Since
   for release of PDM3.1 the deadline is past and this file is 
   going in the patch directory, this function was put in this
   file.
   MaC 
*/


long PDMRetrieveMembersWithModifiedQty (pcat_no, pitem_no, level, curr_level, 
                                          set_head, set_end, num_members, Qty)
int  level, curr_level, pcat_no, pitem_no;
struct PDMbom_member *set_head, *set_end;
int *num_members;
double	Qty;
{
  /***
    This recursive function retrieve the members of the given assembly
    for the purpose of creating BOM.
    The members retrieved will be checked for in PDMCIT table
    to see if they are attached or to be included in BOM or 
    need to be exploded.

    This function returns SQL_I_NO_ROWS_FOUND or PDM_S_SUCCESS
    for successful statii.

    Note: The caller does not have to make sure the passed in item_nos are sets

    CHANGE HISTORY:
      11/19/92 MaC creation.
      09/14/94  MaC modified to calculate the quantities such that
                if a subassy is placed with quantity of > 1, then
                all its children will have the quantity multiplied
                qty(parent) recursively.
  ***/


  char *fn="PDMRetrieveMembersWithModifiedQty";
  char *sql_str;
  char sql_str1[150];
  char **data;
  int x, index;
  int cat_no, item_no;
  int cyclic_attachment_in_bg_found;    
  MEMptr list=NULL;
  struct PDMbom_member *cat_head, *new_node, *cur_mem;
  extern long PDMdfs_retrieve_members_for_bom();
  long PDMbom_check_assy_cycle ();
  double  doub;

  _PDMdebug (fn, "ENTER\n");
  _PDMdebug (fn, "get children for cat[%d].item[%d] on level %d\n\
                  total members retrieved so far %d\n", 
                  pcat_no, pitem_no, level, *num_members);
  _PDMdebug (fn, "quantity to be multiplied with %f\n", Qty);

/* sql_str will be dynamically allocated MaC 012793 */

    sql_str = (char *) malloc ((*num_members * 100) + 512);
    if (! sql_str) {
       _PDMdebug (fn, "Malloc Failed : status = <0x%.8x>\n", NFM_E_MALLOC);
       return (NFM_E_MALLOC);
       }
    sql_str[0] = '\0';

  sprintf (sql_str, "%s %s %s %s %s %s", 
"SELECT nfmsetcit.n_citno, nfmsetcit.n_pcatalogno, nfmsetcit.n_pitemno, " , 
"nfmsetcit.n_ccatalogno, nfmsetcit.n_citemno, nfmsetcit.n_type, ", 
"pdmcit.p_attached, pdmcit.p_explode, p_orient, p_quantity, p_childno, ", 
"p_viewid, p_usageid, p_tagno, p_alttagno, p_incbom, n_catalogname, ", 
"n_itemname, n_itemrev, p_history, p_pdcno, n_cofilename FROM nfmsetcit, pdmcit ", 
"where pdmcit.p_citno = nfmsetcit.n_citno ");
 
 sprintf (sql_str1, 
    " and ( nfmsetcit.n_pcatalogno = %d and nfmsetcit.n_pitemno = %d ) ", 
                  pcat_no, pitem_no);

 strcat (sql_str, sql_str1);

  _PDMdebug ("exec qry", " %s\n", sql_str1);

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug (fn, "SQLquery 0x%.8x\n", status) ;
    _PDMdebug ("Could not find children", "[%s].[%s] on level %d\n", 
                  set_end->cat_name, set_end->item_name, level);
      _PDMdebug ("set_end", "[%lx]<>set_end->next[%lx]\n", 
                                       set_end, set_end->next);
    return (status);
    }
  free (sql_str); sql_str = NULL;

/*
        if (PDMdebug_on) {
                MEMprint_buffer("list from query", list, PDM_DEBUG_FILE);
        }
*/


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS) {
    MEMclose (&list);
    _PDMdebug ( fn, "MEMbuild_query (list) 0x%.8x\n", NFM_E_MEM );
    return (NFM_E_MEM);
  } 

  _PDMdebug (fn, "# of rows retrieved by query --> %d\n", list->rows);

  cyclic_attachment_in_bg_found = 0;     
  data = (char **) list->data_ptr;
  for (x = 0, cat_head = set_head; x < list->rows; x++) {
  index = x * list->columns;
  cat_no = atol (data[index+3]);
  item_no = atol (data[index+4]);
  _PDMdebug ( fn, "index %d, row %d: %s %s %s %s %s %s %s\n", 
               index, x, data[index],  data[index+1], data[index+2], 
                data[index+3], data[index+4], data[index+5], data[index+6]);
/* if p_attached is Y then add the member to the list */
/* added support for checking p_incbom flag...
    if set to Y or y then include it in the bomlist...*/
      if ( (!strcmp (data[index+15], "Y")) 
               || (!strcmp (data[index+15], "y"))
               || (!strcmp (data[index+15], "B")) 
               || (!strcmp (data[index+15], "b"))  ) {
/* fix added to check whether each child with incstr set to no
   contains a potential cycle. MaC 060193 */
      if ( (!strcmp (data[index+15], "B")) 
               || (!strcmp (data[index+15], "b")) ) {
        cyclic_attachment_in_bg_found = 0;    
        _PDMdebug (fn, "Incstr is set to N so we need to check cyclic att.\n");
          status =  PDMbom_check_assy_cycle (atol (data[index+1]), 
                                             atol (data[index+2]), 
                                             atol (data[index+3]), 
                                             atol (data[index+4]));
          if (status != PDM_S_SUCCESS && 
                 status != NFM_E_SET_IN_LOOP ) {
              _PDMdebug (fn, "PDMbom_check_assy_cycle : status = <0x%.8x>\n", 
                                                                      status);
              _PDMdebug (fn, "ERROR a cyclic placement \n ");
              return (status);
            }
           else {
               if (status == NFM_E_SET_IN_LOOP) { 
                   cyclic_attachment_in_bg_found = 1;    
                   _PDMdebug (fn, "Cyclic attachment in bg part found\n");}
                   }
         }
   
      new_node = (struct PDMbom_member *) NULL; 
      new_node = (struct PDMbom_member *)calloc (1, 
                         sizeof (struct PDMbom_member));
      if (new_node == (struct PDMbom_member *) NULL)
      {
        _PDMdebug (fn, "Allocate %d  failed\n", 
                        sizeof (struct PDMbom_member));
        return (NFM_E_MALLOC);
      }
      new_node->level = curr_level;
      new_node->flag = 4;
      new_node->citno = atol(data[index]);
      new_node->item_no = atol (data[index+4]);
      new_node->cat_no = atol (data[index+3]);
        strncpy (new_node->type, data[index+5], 2);
/* stuff to be added ...*/
      _PDMasc_to_doub (data[index+9], &doub);
      _PDMdebug (fn, "doub[%f]\n", doub);
/*
      _PDMget_double_from_buf_val (data[index+9], &doub);
      _PDMdebug (fn, "doub[%f]\n", doub);
*/
      doub = doub * Qty;
      _PDMdebug (fn, "Qty*doub[%f]\n", doub);
      sql_str1[0] = '\0';
      sprintf (sql_str1, "%f", doub);
      strcpy (new_node-> quantity, sql_str1);
      _PDMdebug (fn, "Quantity[%s]\n", sql_str1);

      /*new_node-> quantity = atol (data[index+9]) ;
      strcpy (new_node-> quantity, data[index+9]);*/

      new_node-> tagno  = atol (data[index+13]);
      new_node-> pdcno = atol (data[index+20]);
      new_node-> childno = atol (data[index+10]);
      strcpy (new_node->attached, data[index+6]);
      strcpy (new_node->history, data[index+19]);
      strcpy (new_node->orient, data[index+8]);
      strcpy (new_node->usageid, data[index+12]);
      strcpy (new_node->viewid , data[index+11]);
      strcpy (new_node->alttagno, data[index+14]);
      strcpy (new_node->incbom , data[index+15]);
      strcpy (new_node->explode, data[index+7]);;
      strcpy (new_node->cat_name, data[index+16]);
      strcpy (new_node->item_name, data[index+17]);
      strcpy (new_node->item_rev, data[index+18]);
      strcpy (new_node->co_filename , data[index+21]);
      new_node->pcat_no = atol (data[index+1]);
      new_node->pitem_no = atol (data[index+2]);
      _PDMdebug ("set_end", "[%lx]<>set_end->next[%lx]\n", 
                                       (set_end), (set_end)->next);
      _PDMdebug ("set_end", "[%lx]\n", set_end);
      for ( cur_mem = set_end; 
              cur_mem->next != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
/*
      _PDMdebug ("set_end", "[%lx]<>set_end->next[%lx]\n", 
                                       cur_mem, cur_mem->next);
*/
      }
/*
      _PDMdebug ("set_end", "[%lx]\n", set_end);
      _PDMdebug ("cur_mem", "[%lx]\n", cur_mem);
      _PDMdebug ("new_node", "[%lx]\n", new_node);
*/
      set_end = cur_mem;
      set_end->next = new_node;
      set_end = new_node;
      _PDMdebug ("set_end", "[%lx]\n", set_end);
      _PDMdebug ("printing addresses", "\n");
      for ( cur_mem = set_head; 
              cur_mem != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
/*      _PDMdebug ("cur_mem", "[%lx]<>cur_mem->next[%lx]\n", 
                                       cur_mem, cur_mem->next);*/
      }
      _PDMdebug ("printing values", "\n");
      for ( cur_mem = set_head; 
              cur_mem != (struct PDMbom_member * ) NULL; 
                       cur_mem = cur_mem->next){
      /*_PDMprint_bommember_info ("cur_mem", cur_mem);*/
      }
      (*num_members) ++; 
    /* added recursion for each member...*/
    if ((curr_level > level) && (curr_level < 50)){
     _PDMdebug (fn, "current level = %d level = %d\n", curr_level, level);
/* added support for checking p_explode flag...
    if set to N or n then do not look for its children...*/
   if ( (!((!strcmp (data[index+7], "N")) || (!strcmp (data[index+7], "n"))))
         && (cyclic_attachment_in_bg_found == 0)) {
    _PDMdebug (fn, "Entering Recursion...\n");
        cyclic_attachment_in_bg_found = 0;
        status = PDMRetrieveMembersWithModifiedQty ((int) new_node->cat_no, 
                                              (int) new_node->item_no, 
                                              level +1, 
                                              curr_level+1, 
                                              set_head, 
                                              set_end, 
                                              num_members, doub);
        if ( (status != PDM_S_SUCCESS) && 
               (status != SQL_I_NO_ROWS_FOUND) ) {
              _PDMdebug (fn, "PDMdfs_retrieve_bom_members 0x%.8x\n", status);
              return (status);
                }
        if (status == SQL_I_NO_ROWS_FOUND ) {
          _PDMdebug (fn, "*** Leaf found for this branch..\n");
           }
        }
      }
     }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS) {
    _PDMdebug (fn, "MEMclose (list of members from nfmsetcit) 0x%.8x\n", 
                status);
    return (status);
  }

  _PDMdebug ( fn, "EXIT: 0x%.8x\n", PDM_S_SUCCESS );
  return (PDM_S_SUCCESS);
}


