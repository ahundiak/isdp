#include		<stdio.h>
#include		"SQLerrordef.h"
#include 		"MEMerrordef.h"
#include 		"NFMerrordef.h"
#include		"PDMdbs_err.h"
#include		"MEMstruct.h"
#include		"NFMstruct.h"
#include		"PDUerror.h"
#include                "PDMmessage.h"
#include                "NFMschema.h"
#include                "dbadev.h"
#include        "rMRPstr.h"
#include        "MRPmessage.h"
#include                "PDUstorage.h"
#include                "PDUris_incl.h"
#include		"PDMproto.h"


static long            status;
char            s[1024];
extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern struct NFMglobal_st NFMglobal;
extern struct   PDUstorage   *storage;
extern int dba_columns_per_page;
extern PDMexec_ptr PDMexec;


/*
 * Generates BOM for the specified part The assembly structure is from CITs
 * If BOM exists attachments are set from the old bom
 * 
 * if max_level is -1 it will be ignored else the BOM will be only exploded to
 * max_level
 * 
 * Also note that p_explode in catalogs will determine if a part is to be
 * exploded or not
 */

int PDMgenerate_review_bom(bufr)
MEMptr		*bufr;
{

        char            templib[21], output[15], temp_type[3];
        char     exist_bom[41];
	char            bom_table[40];
        static char     *fname = "PDMgenerate_review_bom";
       char             file_name[51], pathname[85];
        char            report_file[100], saname[20];
        char            schema[100], passwd[100], sch_passwd[200];
        struct   PSUrpt psurpt;
        char             *msg = NULL;

	_PDMdebug(fname, "ENTER\n");

	/*
	 * find  bom name if it does not exist generate it  
	 */

        exist_bom[0] = '\0';
        strcpy(bom_table, "");
	status = PDMquery_bom_name(PDMexec->catalog, 
				   PDMexec->part_num, PDMexec->revision, 
				   exist_bom);
	if (status != PDM_S_SUCCESS &&
	    status != PDM_E_BOM_NOT_FOUND) {
		_PDMdebug(fname, "%s %d \n", 
			"PDMquery_bom_name failed : status", status);
		return (status);
	}


        if(status != PDM_S_SUCCESS)
         {
	_PDMdebug(fname, "Old bom not found - Hence generate BOM\n");
	/* verify part exists */
	status = PDMverify_part(PDMexec->catalog, 
				PDMexec->part_num, PDMexec->revision);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug(fname, "%s %s %d \n", 
			"PDMverify_part failed : status", status);
		return (status);
	}
	status = PDMupdate_exist_bom(exist_bom);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug(fname, "%s %s %d \n", 
			"PDMupdate_exist_bom failed : status", status);
		return (status);
	}
        if (strcmp(bom_table, "") != 0) 
            _PDMdebug (fname, "bom_table[%s]\n", bom_table);
/*
            strcpy(exist_bom, bom_table);
*/
            strcpy(bom_table, exist_bom);
            _PDMdebug (fname, "exist_bom[%s]\n", exist_bom);
 
        }
    
         strcpy(saname, PDMexec->drevision);
        _PDMdebug(fname, "saname = %s\n", saname);
      _PDMdebug(fname, "Encrypted schema name %s\n", NFMglobal.NFMsch_name);
       status = NFMdecrypt(NFMglobal.NFMsch_name, schema);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Decrypy Schema Name : status = <0x%.8x>\n", 
                    status);
                goto wrap_up;
      }
       status = NFMdecrypt(NFMglobal.NFMsch_passwd, passwd);
     if (status != NFM_S_SUCCESS)
      {
        _PDMdebug (fname, "Decrypy Schema passwd : status = <0x%.8x>\n", 
                    status);
                goto wrap_up;
      }

       sch_passwd[0] = '\0';
       sprintf(sch_passwd, "%s.%s", schema, passwd);

      PDMconvert_to_lower(exist_bom, exist_bom);
      /* Kumar - 9.7.92 to support RIS template - start*/

      /* fix to pass the template type so that we get 
         The template type may be ? or ?F, the following
         function retrieves the correct type when we pass
         "?" MaC 051193
         ...*/

        temp_type[0] = '\0';
        strcpy (temp_type, "P");

   status = PDMquery_report_type(PDMexec->drawing, temp_type, templib, output);
           if(status != PDM_S_SUCCESS)
            {
        _PDMdebug(fname, "%s %d\n", "PDMquery_report_type failed status ", status);
                status = PDM_E_RPS_READ_FORMAT;
                goto wrap_up;
            }
/*
       _PDMdebug (fn, "type[%s], templit[%s], output[%s]\n", 
                                      temp_type, templib, output);
*/

         if(temp_type[1] == 'F')
         {

        if(!strcmp(PDMexec->dcatalog, "") && !strcmp(output, ""))
             {
           status    = PDMgen_file_name(file_name);
             if(status != PDM_S_SUCCESS) strcpy(file_name, "BOM");
             }
         else if( strlen(PDMexec->dcatalog))strcpy(file_name, PDMexec->dcatalog);
         else if (strlen(output)) strcpy(file_name, output);
          else
           {
           status    = PDMgen_file_name(file_name);
               if(status != PDM_S_SUCCESS) strcpy(file_name, "BOM");
           }

          /* Generate the report from the ris template using DBaccess */
      pathname[0] = '\0';
strcpy(pathname, storage->path_name);
       report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);

      _PDMdebug(fname, "report_file = %s\n", report_file);

/*
      status = PDMreport_from_tmpfile (sch_passwd, exist_bom, 
                                        templib, PDMexec->drawing, 
                                        "pdmbom_rpt", saname, report_file);
*/
      status = PDMreport_from_tmpfile (sch_passwd, exist_bom, 
                                        templib, PDMexec->drawing, 
                                        saname, report_file);
      if(status != PDM_S_SUCCESS) {
          _PDMdebug(fname, 
            "%s %d\n", "PDMreport_from_tmpfile failed status", status);
          goto wrap_up;
          }
         }
          else {

        /* read the report to find out the attributes */
 
        _PDMdebug (fname, "bom_name [%s]\n", exist_bom);

        PDMinit_psurpt(&psurpt);
        strcpy(psurpt.options.template_name, PDMexec->drawing);
        strcpy(psurpt.options.table, exist_bom);
        strcpy(psurpt.templatetype, "P");

        status = PSUrs_load_rpt(&psurpt);
        if (status != MRP_S_Success)   {
           _PDMdebug(s, "%s %d\n", "PSUrs_load_rpt failed status ", status);
           status = PDM_E_RPS_READ_FORMAT;
           goto wrap_up;
          }

        if (!strcmp(PDMexec->dcatalog, "") 
            && !strcmp(psurpt.options.output, "")) {
            status = PDMgen_file_name(file_name);
            if(status != PDM_S_SUCCESS)
                   strcpy(file_name, "BOM");
         }
        else if(strlen(PDMexec->dcatalog)) 
            strcpy(file_name, PDMexec->dcatalog);
        else if (strlen(psurpt.options.output)) 
            strcpy(file_name, psurpt.options.output);
        else
         {
            status    = PDMgen_file_name(file_name);
            if(status != PDM_S_SUCCESS)
            strcpy(file_name, "BOM");
          }

      pathname[0] = '\0';
strcpy(pathname, storage->path_name);
       report_file[0] = '\0';
      if (strchr(file_name, '/'))
        sprintf(report_file, "%s", file_name);
      else
        sprintf(report_file, "%s/%s", pathname, file_name);
        _PDMdebug(fname, "report_file = %s\n", report_file);

strcpy(psurpt.options.table , exist_bom);
 strcpy(psurpt.options.template_name, "");
strcpy(psurpt.options.template_name , PDMexec->drawing);
 strcpy(psurpt.templatetype, "");
strcpy(psurpt.templatetype, "P") ;
 strcpy(psurpt.options.title, "");
msg = (char *)PDUtranslate_message(PDS_M_EXPLODED_BOM);
sprintf(psurpt.options.title , "%s %s %s ", msg,PDMexec->part_num, PDMexec->revision);
strcpy(psurpt.options.description , " BILL OF MATERIAL");
psurpt.options.subtotals = 0;
psurpt.options.totals = 0;
 psurpt.where = (char *) malloc (5);
 strcpy(psurpt.where, "");
 strcpy(psurpt.options.output, "");
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
                sprintf(s, "PSUrs_cre_rpt failed status %d\n", status);
                PDMdebug(s);
                status = PDM_E_OUTPUT_REPORT;
                goto wrap_up;
        }

         rMRPfree_psurpt(&psurpt);
     } /* if it' not a template, but a RIStemplate file */

 status = MEMopen(bufr, 512);
        if (status != MEM_S_SUCCESS) {
                MEMclose(bufr);
                _PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
                return (PDM_E_OPEN_BUFFER);
        }
status = MEMwrite_format(*bufr, "n_cofilename", "char(51)");
        if (status != MEM_S_SUCCESS) {
                MEMclose(bufr);
                _PDMdebug(fname, "MEMwrite_format failed status %d\n", status);
                return (PDM_E_OPEN_BUFFER);
        }
         s[0] = '\0';
        sprintf(s, "%s\1", file_name );
        _PDMdebug(fname, "moving file = %s\n", s);
        status = MEMwrite(*bufr, s);
        if (status != MEM_S_SUCCESS) {
                MEMclose(bufr);
                _PDMdebug(fname, "MEMwrite failed status %d\n", status);
                return (PDM_E_WRITE_ROW);
        }
     if(PDMdebug_on)
     MEMprint_buffer("file_bufr", *bufr, PDM_DEBUG_FILE);
        _PDMdebug(fname, "Exit = %d\n", status);
        return (PDM_S_SUCCESS);

wrap_up:
        _PDMdebug(fname, "Failure %d\n", status);
        return (status);
}

