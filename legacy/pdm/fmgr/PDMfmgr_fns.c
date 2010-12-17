#include                <stdio.h>
#include                "SQLerrordef.h"
#include                "MEMerrordef.h"
#include                "NFMerrordef.h"
#include                "NFMapi.h"
#include                "NFMschema.h"
#include                "MEMstruct.h"
#include                "NFMitems.h"
#include                "NFMstruct.h"
#include                "PDMdbs_err.h"
#include                "PDUerror.h"
#include                "PDUstorage.h"
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
extern struct   PDUstorage *storage;

int PDMi_find_storageno (storage_buffer, n_sano)
MEMptr	storage_buffer;
int		*n_sano;
{
	char	*fn = "PDMi_find_storageno";
	char	**strg_data, **columns;
	char	**data;
	char	sql_str[512];
	MEMptr	bufr = NULL;
	int		p1, p2, p3, p4;
	int		j;
	int		n_nodeno;

	PDMdebug("ENTER:PDMi_find_storageno\n");

   /* find storage no */

   status = MEMbuild_array(storage_buffer);
   if(status != MEM_S_SUCCESS)
   {
	_PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
	return(PDM_E_BUILD_ARRAY);
   }
   strg_data = (char **) storage_buffer->data_ptr;
   columns = (char **) storage_buffer->column_ptr;
   p1 = -1; p2 = -1; p3 = -1; p4 = -1;
   for(j=0;j<storage_buffer->columns;j++)
   {
	   if(!strcmp(columns[j], "node_name"))     p1 = j;
       if(!strcmp(columns[j], "user_name"))     p2 = j;
       if(!strcmp(columns[j], "path_name"))	   p3 = j;
       if(!strcmp(columns[j], "storage_name"))  p4 = j;
   }
   if(PDMdebug_on)
    {
     MEMprint_buffer("storage_buffer", storage_buffer, PDM_DEBUG_FILE);
    }
   if(p1 == -1 || p2 == -1 || p3 == -1 || p4 == -1)
   {
		PDMdebug("Couldnot find cols in <storage_buffer>\n");
		return(PDM_E_BUFFER_FORMAT);
   }
   if(!strlen(strg_data[p4]))
   {
      	status = PDMi_find_nodeno(strg_data[p1], &n_nodeno);
   	  if(status != PDM_S_SUCCESS) {
	    _PDMdebug (fn, "PDMi_find_nodeno failed status %d\n", status);
  	    return(PDM_I_NO_SAREA_FOUND);				
  	  }
   	  status = PDMi_find_sano(n_nodeno, strg_data[p2], strg_data[p3], n_sano);
   	  if(status != PDM_S_SUCCESS)
   	  {
	  	_PDMdebug (fn, "PDMi_find_sano failed status %d\n", status);
	  		return(PDM_I_NO_SAREA_FOUND);				
	  }
   }
   else
   {
	  sprintf(sql_str, "%s '%s'", 
	  "SELECT n_sano from nfmstoragearea where n_saname = ", 
	  strg_data[p4]);
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
  	 _PDMdebug (fn, "MEMbuild_array failed status %d\n", status);
  	return(PDM_E_BUILD_ARRAY);
  	}
  	data = (char **) bufr->data_ptr;
  	*n_sano = atoi(data[0]);
  	MEMclose(&bufr);
   }
	PDMdebug("EXIT:PDMi_find_storageno\n");
	return(PDM_S_SUCCESS);
}


