#include <stdio.h>
#include "SQLerrordef.h"
#include "PDMdbs_err.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUerror.h"
#include "NFMerrordef.h"
#include "PDMproto.h"
#include "PDUpdmrpro.h"

#define MAX_BUFFER_SIZE 16384
#define NOT !
#define	TRUE	1
#define FALSE	0

extern long sqlstatus;
extern int	PDMdebug_on;
extern char PDM_DEBUG_FILE[];
static	char   s[1024];
extern PDMexec_ptr PDMexec;

int PDMsquery_part_type(temp_bufr)
MEMptr		*temp_bufr;
{
	char		sql_str[1024];
	long		status;

   PDMdebug("ENTER:PDMsquery_part_type\n");

   *temp_bufr = NULL;

		/* get p_parttype from the catalog */

   sql_str[0] = '\0';
   sprintf(sql_str,"%s FROM %s %s '%s' %s '%s'",
   "SELECT p_parttype",PDMexec->catalog,
   "WHERE n_itemname = ",PDMexec->part_num,
   "AND n_itemrev = ",PDMexec->revision);
	
   status = SQLquery(sql_str,temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
		MEMclose(temp_bufr);
		switch(status)
		{
			case SQL_I_NO_ROWS_FOUND :
				 sprintf(s,"%s %s %s %s \n",
				 "PDMsquery_part_type : ",
				 "Could not find Part ",
				 PDMexec->part_num,PDMexec->revision);
				 PDMdebug(s);
		  		 return(PDM_E_PART_NOT_FOUND);
			case PDMS_NO_SUCH_ATTRIBUTE:
				 sprintf(s,"%s %s  \n",
				 "PDMsquery_part_type: Could not ",
				 "find a required column in catalog");
				 PDMdebug(s);
		  		 return(PDM_E_REQ_COLUMN_NOT_FOUND);
			case PDMS_NO_SUCH_TABLE:
				 sprintf(s,"%s %s \n",
				 "PDMsquery_part_type: Could not find Catalog ",
				 PDMexec->catalog);
				 PDMdebug(s);
		  		 return(PDM_E_CATALOG_NOT_FOUND);
			default:
				return(status);
		}			
   }
   status = MEMbuild_array(*temp_bufr);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(temp_bufr);
		sprintf(s,"%s %s %d\n",
		"PDMsquery_part_type: MEMbuild_array ",
		"failed status ",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   PDMdebug("EXIT:PDMsquery_part_type\n");
   return(PDM_S_SUCCESS);
}

int PDMfind_part_type(catalog,n_itemno,part_type)
char		*catalog;
int             n_itemno;
char            *part_type; 
{
	char		**data;
	char		sql_str[1024];
	MEMptr		temp_bufr = NULL;

	long		status;

   PDMdebug("ENTER:PDMfind_part_type\n");

		/* get p_parttype from the catalog */

   sql_str[0] = '\0';
   sprintf(sql_str,"%s FROM %s %s %d ",
   "SELECT p_parttype",catalog,
   "WHERE n_itemno = ",n_itemno);
	
   status = SQLquery(sql_str,&temp_bufr,512);
   if(status != SQL_S_SUCCESS)
   {
		MEMclose(&temp_bufr);
		switch(status)
		{
			case SQL_I_NO_ROWS_FOUND :
				 sprintf(s,"%s %s  \n",
				 "PDMsquery_part_type : ",
				 "Could not find Part ") ;
				 PDMdebug(s);
		  		 return(PDM_E_PART_NOT_FOUND);
			case PDMS_NO_SUCH_ATTRIBUTE:
				 sprintf(s,"%s %s  \n",
				 "PDMsquery_part_type: Could not ",
				 "find a required column in catalog");
				 PDMdebug(s);
		  		 return(PDM_E_REQ_COLUMN_NOT_FOUND);
			case PDMS_NO_SUCH_TABLE:
				 sprintf(s,"%s %s \n",
				 "PDMsquery_part_type: Could not find Catalog ",
				 catalog);
				 PDMdebug(s);
		  		 return(PDM_E_CATALOG_NOT_FOUND);
			default:
				return(status);
		}			
   }
   status = MEMbuild_array(temp_bufr);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&temp_bufr);
		sprintf(s,"%s %s %d\n",
		"PDMsquery_part_type: MEMbuild_array ",
		"failed status ",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   data = (char **)temp_bufr->data_ptr;
   strcpy(part_type,data[0]);
   PDMdebug("EXIT:PDMfind_part_type\n");
   return(PDM_S_SUCCESS);
}

int PDMschange_part_type(temp_bufr)
	MEMptr		temp_bufr;
{
	char		**temp_data;
	char		sql_str[1024];
        char            parttype[2];
	long		status;

   PDMdebug("ENTER:PDMschange_part_type\n");
   status = MEMbuild_array(temp_bufr);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&temp_bufr);
		sprintf(s,"%s %s %d\n",
		"PDMsquery_part_type: MEMbuild_array ",
		"failed status ",status);
		PDMdebug(s);
		return(PDM_E_BUILD_ARRAY);
   }
   temp_data = (char **) temp_bufr->data_ptr;
   strcpy(parttype,temp_data[0]);

		/* update p_parttype from the catalog */

   sql_str[0] = '\0';
   sprintf(sql_str,"%s %s SET %s %s %s '%s' %s '%s'",
   "UPDATE ",PDMexec->catalog,"p_parttype =",parttype,
   "WHERE n_itemname = ",PDMexec->part_num,
   "AND n_itemrev = ",PDMexec->revision);
	
   status = SQLstmt(sql_str);
   if(status != SQL_S_SUCCESS)
   {
		MEMclose(&temp_bufr);

		switch(status)
		{
			case SQL_I_NO_ROWS_FOUND :
				 sprintf(s,"%s %s %s %s \n",
				 "PDMsquery_part_type : ",
				 "Could not find Part ",
				 PDMexec->part_num,PDMexec->revision);
				 PDMdebug(s);
		  		 return(PDM_E_PART_NOT_FOUND);
			case PDMS_NO_SUCH_ATTRIBUTE:
				 sprintf(s,"%s %s  \n",
				 "PDMsquery_part_type: Could not ",
				 "find a required column in catalog");
				 PDMdebug(s);
		  		 return(PDM_E_REQ_COLUMN_NOT_FOUND);
			case PDMS_NO_SUCH_TABLE:
				 sprintf(s,"%s %s \n",
				 "PDMsquery_part_type: Could not find Catalog ",
				 PDMexec->catalog);
				 PDMdebug(s);
		  		 return(PDM_E_CATALOG_NOT_FOUND);
			default:
				return(status);
		}			
   }
   PDMdebug("EXIT:PDMschange_part_type\n");
   return(PDM_S_SUCCESS);
}

