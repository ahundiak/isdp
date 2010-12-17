#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMstruct.h"
#include "NFMerrordef.h"
#include "WFstruct.h"
#include "PDUstorage.h"
#include "ERR.h"
#include "PDMproto.h"



#define MAX_BUFFER_SIZE 16384
#define NOT !
#define TRUE    1
#define FALSE   0

extern long sqlstatus;
extern struct NFMglobal_st NFMglobal;
extern struct WFstruct WFinfo;
extern struct NFMglobal_st NFMglobal;
extern struct WFstruct WFinfo;
extern int      PDMdebug_on;
extern struct PDMpart_ptr PDMpart;
extern char PDM_DEBUG_FILE[];
static  long   status;
static  char   s[1024];
extern struct   PDUstorage   *storage;
extern PDMexec_ptr PDMexec;



int             PDMquery_catalog_type(catalog, type)
char *catalog, *type;
{
        char            *fname = "PDMquery_catalog_type";
        long            status;
        char            sql_str[512];
        MEMptr          bufr = NULL;
        char             **data;

        _PDMdebug(fname, "ENTER:\n");
        sprintf(sql_str,"SELECT n_type FROM nfmcatalogs WHERE n_catalogname = '%s' ",catalog);
        status = SQLquery(sql_str,&bufr,512);
        if (status != SQL_S_SUCCESS)
         {
         if(status == SQL_I_NO_ROWS_FOUND)
           {
            MEMclose(&bufr);
       sprintf(sql_str, "SELECT n_itemname FROM %s WHERE n_itemname = '100' ",
            catalog);
        status = SQLquery(sql_str,&bufr,512);
        if(status == SQL_I_NO_ROWS_FOUND)
         {
            MEMclose(&bufr);
            PDMconvert_to_lower(catalog,catalog);
        sprintf(sql_str,"SELECT n_type FROM nfmcatalogs WHERE n_catalogname = '%s' ",catalog);
        status = SQLquery(sql_str,&bufr,512);
          if (status == SQL_S_SUCCESS)
            {
             status  = MEMbuild_array(bufr);
                 if (status != MEM_S_SUCCESS)
                 {
                 MEMclose(&bufr);
                _PDMdebug(fname, "MEMbuild_array failed %d\n", status);
                return (status);
                 }
          data = (char **) bufr->data_ptr;
          strcpy(type,data[0]);
            MEMclose(&bufr);
              _PDMdebug(fname,"EXIT:CATALOG FOUND\n");
                return(PDM_S_SUCCESS);
             }
             else
              {
                MEMclose(&bufr);
                _PDMdebug(fname, "PDMquery_catalog_type failed %d\n", status);
                 return (PDM_E_CATALOG_NOT_FOUND);
              }
            }
            else
               {
                MEMclose(&bufr);
                _PDMdebug(fname, "PDMquery_catalog_type failed %d\n", status);
                 return (PDM_E_CATALOG_NOT_FOUND);
               }
            }
           }
        status  = MEMbuild_array(bufr);
        if (status != MEM_S_SUCCESS) {
                         MEMclose(&bufr);
                _PDMdebug(fname, "MEMbuild_array failed %d\n", status);
                return (status);
        }
          data = (char **) bufr->data_ptr;
          strcpy(type,data[0]);
          _PDMdebug(fname, "catalog type = ,%s>\n", type);
          MEMclose(&bufr);
        _PDMdebug(fname, "EXIT:\n");
        return(PDM_S_SUCCESS);
}

int             PDMcheck_for_view(catalog)
char *catalog;
{
        char            *fname = "PDMcheck_for_view";
        long            status;
        char            sql_str[512], low_catalog[256];
        MEMptr          bufr = NULL;

        _PDMdebug(fname, "ENTER:\n");

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */

#if defined ( RISV4 )

        sprintf(sql_str,"SELECT ris_view_def FROM ris_views WHERE view_name = '%s' ",catalog);

#elif defined ( RISV5 )

        sprintf(sql_str,"SELECT ris_view_def FROM ris5views WHERE view_name = '%s' ",catalog);

#else
#error "RIS version must be defined"
#endif

        status = SQLquery(sql_str,&bufr,512);
        if (status != SQL_S_SUCCESS) {
               if(status == SQL_I_NO_ROWS_FOUND)
                 {
            sql_str[0] = '\0';
            PDMconvert_to_lower(catalog,low_catalog);

/* RIS dictionary tables in V5 named different. 26/apr/95 - raj. */

#if defined ( RISV4 )

        sprintf(sql_str,"SELECT ris_view_def FROM ris_views WHERE view_name = '%s' ",low_catalog);

#elif defined ( RISV5 )

        sprintf(sql_str,"SELECT ris_view_def FROM ris5views WHERE view_name = '%s' ",low_catalog);

#else
#error "RIS version must be defined"
#endif

        status = SQLquery(sql_str,&bufr,512);
        if (status != SQL_S_SUCCESS) 
                      {
                _PDMdebug(fname, "PDMcheck_for_view failed %d\n", status);
                 return (PDM_E_VIEW_NOT_FOUND);
                      }
                 }
               else
                 {
                _PDMdebug(fname, "PDMcheck_for_view failed %d\n", status);
                return (status);
                 }
        }
        MEMclose(&bufr); 
        _PDMdebug(fname, "EXIT:\n");
         return(PDM_I_VIEW_FOUND); 
}



/* Kumar 
   Wriiten to support place parametric part
*/

int PDMplacement_attributes
(
MEMptr *attr_bufr
)
{
char *fname = "PDMplacement_attributes";
MEMptr bufr = NULL;
long   status;
char **data,sql_str[512];


          _PDMdebug(fname,"Enter\n");
        /* Making two queries is better than making a join of nfmattributes
           and nfmtables */ 
       sprintf(sql_str,"select n_tableno from nfmtables where n_tablename = 'pdmcit'");
        status = SQLquery(sql_str,&bufr,512);
        if(status != SQL_S_SUCCESS)
        {
          MEMclose(&bufr);
          _PDMdebug(fname,"SQLquery falied status %d\n",status);
          return(status);
         }
       status = MEMbuild_array(bufr);
        if(status != MEM_S_SUCCESS)
        {
          MEMclose(&bufr);
          _PDMdebug(fname,"SQLquery falied status %d\n",status);
          return(status);
         }
        data = (char **) bufr->data_ptr;
     /* Using IN is better than using OR */

sprintf(sql_str,"select n_name, n_synonym, n_datatype from nfmattributes where n_tableno = %s and n_name IN ('p_quantity','p_usageid','p_viewid','p_incbom','p_explode','p_alttagno')",data[0]);
          
       status = SQLquery(sql_str,attr_bufr,512);
        if(status != SQL_S_SUCCESS)
         {
          MEMclose(&bufr);
          _PDMdebug(fname,"SQLquery falied status %d\n",status);
          return(status);
         }
        MEMclose(&bufr);
        
          _PDMdebug(fname,"Exit\n");
  
      return(PDM_S_SUCCESS);
}

/* written to support ticking a attribute as 
   a replacement to NFMRtic_it funnction which ticks the
    whole buffer
    - Kumar Narayanan

*/

PDMparse_for_tic( in, out )
    char *in;
    char *out;
{
    while( *in )
    {
	if( *in == '\'' )
	{
	    *out = '\'';
	    ++out;
	}
	*out++ = *in++;
    }    
    *out = '\0';

    return( PDM_S_SUCCESS );
}


int PDMcr_para_ass_bufr
(
MEMptr *bufr
)
 {
   char *fname = "PDMcr_para_ass_bufr";
   long  status;

     _PDMdebug(fname,"ENTER:\n");
       status = MEMopen(bufr, 512);
       if(status != MEM_S_SUCCESS)
       {
              _PDMdebug (fname, "MEMopen (%d) 0x%.8x\n", status);
               return (status);
        }
       status = MEMwrite_format(*bufr,"p_structureno","integer");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_level","integer");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"pn_catalogname","char(20)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"pn_itemname","char(240)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"pn_itemrev","char(40)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"n_pcatalogno","integer");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"n_pitemno","integer");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"n_catalogname","char(20)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"n_itemname","char(240)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"n_itemrev","char(40)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"n_ccatalogno","integer");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"n_citemno","integer");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_quantity","double");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_history","char(25)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_childno","integer");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_tagno","integer");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_usageid","char(25)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_alttagno","char(40)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_incbom","char(2)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_explode","char(2)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_attached","char(2)");
        if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"n_cofilename","char(14)");
       if(status == MEM_S_SUCCESS)
       status = MEMwrite_format(*bufr,"p_dyndataindex","integer");
       if(status != MEM_S_SUCCESS)
       {
              _PDMdebug (fname, "MEMopen (%d) 0x%.8x\n", status);
               return (status);
        }
     _PDMdebug(fname,"EXIT:\n");
     return(PDM_S_SUCCESS);
}
