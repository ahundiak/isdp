#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDMdbs_err.h"
#include		"PDMproto.h"
#include		"PDMmessage.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern PDMpart_ptr PDMpart;
static long     status;
extern PDMexec_ptr PDMexec;


/* 
		Creates a temporary table to hold the assembly strcut info
		at all levels. This is used for a later loading the pdmcit. 

                - Kumar 11/5/91
		
*/

int		PDMcreate_temp_pdmcit(temp_table)
char	*temp_table;
{
	char		sql_str[1024];
        static char     *fname = "PDMcreate_temp_pdmcit";

	PDMdebug("ENTER:PDMcreate_temp_table\n");
/*
	status = PDMgen_cittable_name(temp_table);
	if(status != PDM_S_SUCCESS)
	{
	_PDMdebug(fname,"%s %d\n","PDMgen_cittable_name failed status ",status);
	return(status);
	}
*/
        sql_str[0] = '\0';
	sprintf(sql_str,"CREATE TABLE %s( ",temp_table);	
	strcat(sql_str,"p_citno integer,");
	strcat(sql_str,"n_catalogname char(20),");
	strcat(sql_str,"n_itemname char(40),");
	strcat(sql_str,"n_itemrev char(40),");
	strcat(sql_str,"n_itemdesc char(40),");
	strcat(sql_str,"n_setindicator char(1),");
	strcat(sql_str,"p_level integer,");
	strcat(sql_str,"p_childno char(20),");
	strcat(sql_str,"p_pchildno char(20),");
	strcat(sql_str,"p_impattached char(1),");
	strcat(sql_str,"p_expattached char(1),");
	strcat(sql_str,"p_history char(10),");
	strcat(sql_str,"p_orient char(256),");
	strcat(sql_str,"p_quantity double,");
	strcat(sql_str,"p_usageid char(25),");
	strcat(sql_str,"p_viewid char(25),");
	strcat(sql_str,"p_tagno integer,");
	strcat(sql_str,"p_altagno char(25),");
	strcat(sql_str,"p_incbom char(1),");
	strcat(sql_str,"p_explode char(1),");
	strcat(sql_str,"p_pdcno integer,");
	strcat(sql_str,"n_acatalogno integer,");
	strcat(sql_str,"n_aitemno integer,");
	strcat(sql_str,"p_updated char(1)");
	strcat(sql_str,")");
	status = SQLstmt(sql_str);
	if(status != SQL_S_SUCCESS)
	{
		_PDMdebug(fname,"SQLstmt failed status %d\n",status);
		return(PDM_E_SQL_STMT);
	}
	PDMdebug("EXIT:PDMcreate_temp_pdmcit\n");
	return(PDM_S_SUCCESS);
}


/* 
	returns the assembly structure of the part
        Kumar 1/6/92
*/

int	PDMsget_assembly_structure(attr_bufr, PlaceFlag)
MEMptr		*attr_bufr;
long		PlaceFlag;
{
       static char      *fname = "PDMsget_assembly_structure";
        char     sql_str[512] = "";
        char   *msg = NULL;
        long             status1   = PDM_E_FAILURE;

	PDMdebug("ENTER:PDMsget_assembly_structure\n");

        _PDMdebug (fname, "PlaceFlag [%d]\n", PlaceFlag);

	*attr_bufr = NULL;

	/* check if part is assembly or not  */
        status = PDMload_catno(PDMexec->catalog);
         if(status != SQL_S_SUCCESS)
	{
	_PDMdebug(fname,"PDMload_catno failed status %d\n", status);
		return(status);
        }
/* Start transaction should be before LOCK stmt
       status = PDMstart_transaction (0);
         if (status != PDM_S_SUCCESS)
        {
         _PDMdebug (fname, "PDMstop_transaction: 0x%.8x\n", status);
          PDMrollback_transaction (0);
         return (status);
         }
*/
       status = PDMstop_transaction (1200);
         if (status != PDM_S_SUCCESS)
        {
         _PDMdebug (fname, "PDMstop_transaction: 0x%.8x\n", status);
          PDMrollback_transaction (1200);
         return (status);
         }

       status = PDMstart_transaction (1200);
         if (status != PDM_S_SUCCESS)
        {
         _PDMdebug (fname, "PDMstop_transaction: 0x%.8x\n", status);
          PDMrollback_transaction (1200);
         return (status);
         }

      /* Make sure the assembly structure doesn't get changed 
         while generating the structure */

       sprintf(sql_str,"LOCK TABLES %s IN EXCLUSIVE MODE", PDMexec->catalog);
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDMupdate_dots ();
             msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_CAT_ACCESS);
             UI_status (msg);
                sleep (30);
                status = SQLstmt(sql_str);
               if (status != SQL_S_SUCCESS) {
             msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_CAT_ACCESS);
             UI_status (msg);
                sleep (30);
                status = SQLstmt(sql_str);
               if (status != SQL_S_SUCCESS) {
                   msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS);
                   UI_status (msg);
               status = PDM_E_LOCK_CIT;
    _PDMdebug(fname,  "LOCK %s SQLstmt failed status %d\n",  PDMexec->catalog, status);
                 return(status);
                     }
             }
        }
	status = PDMload_part_info(PDMexec->catalog,
			 PDMexec->part_num,PDMexec->revision);
	if(status != PDM_S_SUCCESS)
	{
	_PDMdebug(fname,"PDMquery_assembly_ind failed status %d\n", status);
		return(status);
	}
/*
        if(!strcmp(PDMpart.p_incpartrpt,"M"))
         {
           status = PDMstart_transaction (1200);
           _PDMdebug(fname, "Part is undergoing structure change\n"); 	
           _PDMdebug(fname, "Please place the part later\n"); 	
            return(PDM_E_LOCK_CIT);
         }
*/
       status = PDMstart_transaction (1200);
         if (status != PDM_S_SUCCESS)
        {
         _PDMdebug (fname, "PDMstart_transaction: 0x%.8x\n", status);
          PDMrollback_transaction (1200);
         return (status);
         }

	/* query set members */

   _PDMdebug (fname, "PDMpart.n_setindicator = <%s>\n", PDMpart.n_setindicator);
	status1 = PDMquery_ass_struc ( PDMexec->catalog,
                                       PDMexec->part_num,
                                       PDMexec->revision,
                                       PDMexec->entity,
                                       PDMpart.n_setindicator,
                                       PlaceFlag,
                                       attr_bufr);
	if( (status1 != PDM_S_SUCCESS ) && 
              (status1 != PDM_E_PART_NOT_ASSEMBLY)) {
	   _PDMdebug(fname,"PDMquery_ass_struc failed status %d\n", status);
           PDMrollback_transaction (1200);
	   return(PDM_E_QUERY_SET_MEMBERS);
	  }

       status = PDMstart_transaction (1200);
       if (status != PDM_S_SUCCESS) {
         _PDMdebug (fname, "PDMstart_transaction 0x%.8x\n", status);
         PDMrollback_transaction (1200);
         return (status);
         }


	PDMdebug("EXIT:PDMsget_assembly_structure\n");
	return(status1);
}
