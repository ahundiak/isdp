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
#include                "dbadev.h"
#include                "rMRPstr.h"
#include                "MRPmessage.h"
#include                "PDMproto.h"


#include                        "PDMbom_strct.h"
static long                     status;
/*static char                   s[1024];*/
extern int                      PDMdebug_on;
extern char                     PDM_DEBUG_FILE[];
extern PDMexec_ptr              PDMexec;
extern PDMpart_ptr              PDMpart;
extern struct NFMglobal_st      NFMglobal;

int PDMfind_system_path(pathname, sano)
char *pathname;
int *sano;
{

char    sql_str[512], s[300], **data;
long    status;
MEMptr  bufr = NULL;

        PDMdebug("ENTER:PDMfind_system_path\n");
sprintf(sql_str, "%s '%s'", 
        "SELECT n_sano, n_pathname from nfmstoragearea where n_saname = ", 
                "SYSTEM");
                status = SQLquery(sql_str, &bufr, 512);
                if(status != SQL_S_SUCCESS)
                {
                        MEMclose(&bufr);
                        if(status == SQL_I_NO_ROWS_FOUND)
                        {
                                return(PDM_I_NO_SAREA_FOUND);

                        }
                }
                status = MEMbuild_array(bufr);
                if(status != MEM_S_SUCCESS)
                {
                        MEMclose(&bufr);
                        sprintf(s, "MEMbuild_array failed status %d\n", status);
                        PDMdebug(s);
                        return(PDM_E_BUILD_ARRAY);
                }
                data = (char **) bufr->data_ptr;
                *sano = atoi(data[0]);
                strcpy(pathname, data[1]); 
                MEMclose(&bufr);

        PDMdebug("EXIT:PDMfind_system_path\n");
        return(PDM_S_SUCCESS);

}


int PDMquery_report_type(report, type, lib, out_file)
char *report, *type, *lib, *out_file;
{
 char *fname = "PDMquery_report_type";
 char sql_str[512];
 char ftype[10];
 char **data = NULL;
 MEMptr bufr = NULL;
 

/* ANSI */
lib[0] = '\0';
out_file[0] = '\0';
sql_str[0] = '\0';

       _PDMdebug(fname, "Enter: \n");

       if (strcmp (type, "") ) {
        sprintf(sql_str, 
         "SELECT p_templatetype, p_templib, p_output FROM psurptopts WHERE  p_templatename = '%s' ", 
         report);
      }
      else {
        ftype[0] = '\0';
        sprintf (ftype, "%sF", type);
       _PDMdebug (fname, "report[%s] type[%s] ftype[%s]\n", 
                                          report, type, ftype);

        sprintf(sql_str, " %s %s = '%s' AND ( %s = '%s' OR %s = '%s') ", 
        "SELECT p_templatetype, p_templib, p_output FROM psurptopts WHERE  ", 
        "p_templatename ", report, "p_templatetype ", type, 
         "p_templatetype ", ftype);
       }

        status = SQLquery(sql_str, &bufr, 1024);
        if (status != SQL_S_SUCCESS) {
           MEMclose(&bufr);
           if (status == SQL_I_NO_ROWS_FOUND) {
	      _PDMdebug("EXIT", "%s\n", fname);
              return(PDM_I_NO_REPORT);
              }
           _PDMdebug (fname, "SQLquery failed status %d\n", status);
           return (PDM_E_SQL_QUERY);
        }

        status = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) {
	   PDMdebug("EXIT:PDMquery_report_type\n");
           return(status);
           }

        data = (char **) bufr->data_ptr;
        type[0] = '\0';
        lib[0] = '\0';
        out_file[0] = '\0';
        strcpy(type, data[0]);
        strcpy(lib, data[1]);
        strcpy(out_file, data[2]);
        _PDMdebug (fname, "type[%s]\n", type);

       MEMclose(&bufr);

  _PDMdebug(fname, "Exit: \n");
  return(PDM_S_SUCCESS);
}
