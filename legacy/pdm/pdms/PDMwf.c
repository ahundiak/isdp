#include		<stdio.h>
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MSGstruct.h"
#include		"PDMproto.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"WFexterns.h"
#include		"ERR.h"
#include		"NFMstruct.h"
#include		"PDUpdmrpro.h"
#include		"PDMmessage.h"

/*
extern char   WFitemno[];
extern char   WFitemname[]; 
extern char   WFitemrev[];
extern char   WFdtype1[];
extern char   WFdtype2[];
extern char   WFdtype3[];
*/

 /*char   WFitemname[NFM_ITEM_NAME_LENGTH]; */
/* these are added for the time stamp business */
/*
static          double          entertime;
static          double          exittime;
static          double          intertime;
static          double          call_time();
*/

extern          int             PDMdebug_on;
extern          PDMpart_ptr     PDMpart;
extern          char    PDM_DEBUG_FILE[];
extern struct NFMglobal_st NFMglobal;
extern          PDMexec_ptr	PDMexec;

char 			sql_str[1024];

/* added to support set_to_state->clobbering->wfinfo problem */
/*
struct BAKstruct
  {
    long    command, workflow, acl;
    long    transition, curr_state, next_state;
    long    proj_no, tab_no, item_no;

    char    entity[16]; 
    char    command_name[100], workflow_name[100], acls_name [100];
    char    logon_s[2], logon_f[2], notify[2];
    char    transition_name [100], current_name [100], next_name [100];
    char    wf_name [96], acl_name [96], proj_name [96];
    char    tab_name [96], item_name [96], item_rev [96];
  };
struct BAKstruct	bak;
*/




static long		status;
/*static int		curbuf_no;*/
static char		s[1024];


int PDMsvalidate_user_access(wf_buffer)
	MEMptr		wf_buffer;
{
	char		**data;
	MEMptr		wflow_buf1=NULL;
	MEMptr		wflow_buf3=NULL;
	char		**wflow_data1;
	char		**wflow_data3;
	long		command_no = -1;
	long		commandno = -1;
	long		nfmcommandno = -1;
	long		userno;
	long		user_id;
	long		entity_no;
	char		*wf_name;
	char		*proj_name;
	char		*part_num;
	char		*revision;
	char		*catalog_name;
        char            *fcat;
        int             catno, f_catno, proj_no, acl_no = 0;
	char		*commandname;
	char		entity[15];
        static char *fn = "PDMsvalidate_user_access";

	PDMdebug("ENTER PDMsvalidate_user_access:\n");

_PDMdebug (fn,"\
    PDMvalidate_access : user_id       = <%d>\n\
    PDMvalidate_access : operation = <%d>\n\
    PDMvalidate_access : entity  = <%d>\n\
    PDMvalidate_access : Project    Name = <%s>\n\
    PDMvalidate_access : Catalog    Name = <%s>\n\
    PDMvalidate_access : Part     Name = <%s>\n\
    PDMvalidate_access : Part     Rev  = <%s>\n", 
PDMexec->user_id, 
PDMexec->operation, 
PDMexec->entity, 
PDMexec->project, 
PDMexec->catalog, 
PDMexec->part_num, 
PDMexec->revision);

	status = MEMbuild_array(wf_buffer);
	if(status != MEM_S_SUCCESS) {
   	   MEMclose(&wf_buffer);
           _PDMdebug (fn, "MEMbuild_array failed : status %d\n",status);
	   return(PDM_E_BUILD_ARRAY);
	}
	data = (char **) wf_buffer->data_ptr;
 if(PDMdebug_on) {
       MEMprint_buffer("wf_buffer from PDU",
       wf_buffer,PDM_DEBUG_FILE);
   }

/* Here we have to initialise the global WFinfo structure
   Since this will be used by set_to_state also, we need to
   keep it till the completion of the command. We have to 
   intialise as we don't want values used in previous command
   for validation for this command.

*/

PDMdebug ("initialising WFinfo structure ...\n");

_WFinit_wfinfo ();

/* apparently, this function does not return status...
   Probably, all it does is reset the WFinfo structure,
   and not check for anything: the designer thought that
   this should not cause any error.. Oh well..
 */


/* We have also to initialise the global part structure;
   this struct will be used by command for which we are
   validating access. Else, as before, the values from previous
   command might still exist...
*/


PDMdebug ("initialising PDMpart structure ...\n");

 _PDMinit_part_struct (PDMpart);
 /* we _know_ that this does not return any value ;-) */

   if (strlen (PDMexec->project) ) proj_name = (char *) malloc (strlen(PDMexec->project ) +1);
   else if (strlen (data[2]) ) proj_name = (char *) malloc (strlen(data[2] ) +1);
    else proj_name = (char *) malloc(2);

    fcat = (char *) malloc (strlen(PDMexec->catalog ) +3);
        proj_name[0] = '\0';
        fcat[0] = '\0';
        sprintf(fcat,"f_%s",PDMexec->catalog);
        PDMris_get_catno(PDMexec->catalog,&catno);
        PDMris_get_catno(fcat,&f_catno);
        PDMpart.n_catalogno = catno;
        PDMpart.f_catalogno = f_catno;

_PDMdebug  (fn,  "catalogno = %d; f_catalogno = %d\n", catno, f_catno);

_PDMdebug  (fn,  "proj_name = %s\n", proj_name);
/*
PDMdebug (s);
PDMdebug (s);
*/

/* Sometimes the project name might not be in exec structure, so
  we need to check both buffer and exec structure 03/19/92 - MaC */

   if (strlen (PDMexec->project) ) strcpy (proj_name, PDMexec->project);
   else if (strlen (data[2]) ) strcpy (proj_name, data[2]);
   else  strcpy (proj_name, "");

  /* get project number... added 030292 -MaC */

    if(strlen(proj_name))
     {
    status =  PDMris_get_projectno (proj_name, &proj_no);
     if (status != SQL_S_SUCCESS) {
     _PDMdebug (fn, "PDMris_get_projectno: status %d\n", status);
       return(PDM_E_VALIDATE_ACCESS);
          }
      }
       else proj_no = -1;
     _PDMdebug (fn, "project number = %d\n", proj_no);

/* Hopefully the data_buffer structure is fixed...*/

    commandname = (char *) malloc (strlen(data[0] ) +1);
    wf_name = (char *) malloc (strlen(data[1] ) +1);
  /*    proj_name = (char *) malloc (strlen(data[2] ) +1); */
    catalog_name = (char *) malloc (strlen(data[3] ) +1);
    part_num = (char *) malloc (strlen(PDMexec->part_num ) +1);
    revision = (char *) malloc (strlen(PDMexec->revision ) +1);

  if (!commandname || !wf_name || !proj_name ||
      !catalog_name || !part_num || !revision) {
      _PDMdebug (fn, "malloc for local vars failed...");
       return (PDM_E_COULD_NOT_MALLOC);
     }

     strcpy(commandname, data[0]);
     strcpy(wf_name, data[1]);
     strcpy(catalog_name, data[3]);
     strcpy(part_num, PDMexec->part_num);
     strcpy(revision, PDMexec->revision);
     entity_no = PDMexec->entity;
     user_id = PDMexec->user_id;

/* another change for NFM3.0. PDU no longer passes the user_id;
   we query it during the login from NFMUSERS table and pass it
   back to PDU which passes it back for every command... */

  /* Note: we get the userno directly from the database so no
           need to shift it sixteen bits right .. */

    /*     userno = user_id >> 16; */
           userno = user_id;


_PDMdebug  (fn, 
"PDMvalidate_access for command : %s \nuserno = <%d>\noperation = <%d>\nentity  = <%d>\nCatalog    Name = <%s>\nPart     Name = <%s>\nPart     Rev  = <%s>\n",
 commandname, userno , PDMexec->operation, entity_no, 
catalog_name, part_num, revision);


sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = '%s'",
     "n_commandno, n_nfmcommandno, n_entity",
     "NFMCOMMANDS",
     "n_commandname", commandname);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf1,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

/* Modified for adding delete files for part support 052392 - MaC */

   if (status == SQL_S_SUCCESS) {
   status = MEMbuild_array(wflow_buf1);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf1);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on) {
       MEMprint_buffer("wflow_buf1 in PDMsvalidate_user_access",
       wflow_buf1,PDM_DEBUG_FILE);
   }
  
   wflow_data1 = (char **)wflow_buf1->data_ptr;
   commandno = atol(wflow_data1[0]);
   nfmcommandno = atol(wflow_data1[1]);
   strcpy (entity, wflow_data1[2]);
   }

   else if ( (status == SQL_I_NO_ROWS_FOUND ) && 
           (!strcmp (commandname, "PDMDelete Files For Part") ) ) {
       status = PDMadd_cmd (&commandno, entity);
        if(status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n", "PDMadd_cmd ",status);
                return(PDM_E_COULD_NOT_ADD_CMD);
          }
       nfmcommandno = 0;
       _PDMdebug (fn, "commandno = %d, entity [%s]\n",
                    commandno, entity);
        }

   else {
     MEMclose(&wflow_buf1);
     _PDMdebug (fn, 
     "PDMsvalidate_user_access: SQL statement: status %d\n", status);
     return(PDM_E_CMD_NOT_FOUND);
   }
MEMclose (&wflow_buf1);
 
 /*Here we face a  problem regarding n_commandno and n_nfmcommandno:
   the nfmtransitions table does not have any rows for some pdmcommands
   i.e. commands like review part attrs. these commands are mapped
   to corresponding nfmcommandnos and the table has entries 
   for them. Also, most of the PDM commands are not mapped to
   nfmcommands, what is to be done about them?

   Check if nfmcommandno is valid; if so then use it instead
   of commandno: Actually, some commandno (PDM) are mapped to
   corresponding nfmcommandno in the commands table and 
   nfmtransitions table has this value. 
   And we have to get entity based on the mapped commandno;
   viz nfmcommandno. So the following was added. To get the
   entity of the mapped commandno and not the mapee(?) commandno.
   1/26/92-MaC*/



   if (nfmcommandno) {
     sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = %d",
     "n_entity",
     "NFMCOMMANDS",
     "n_commandno", nfmcommandno);

     status = SQLquery(sql_str,&wflow_buf3,512);
     if (status != SQL_S_SUCCESS)
     {
       MEMclose(&wflow_buf3);
       _PDMdebug (fn, "PDMsvalidate_user_access: SQL statement: status %d\n", 
                status);
       return(PDM_E_SQL_STMT);
     }
  
     status = MEMbuild_array(wflow_buf3);
     if(status != MEM_S_SUCCESS)
     {
        MEMclose(&wflow_buf3);
        _PDMdebug (fn,"%s %d \n", "MEMbuild_array ",status);
        return(PDM_E_BUILD_ARRAY);
     }
     if(PDMdebug_on) {
         MEMprint_buffer("wflow_buf3 in PDMsvalidate_user_access",
           wflow_buf3,PDM_DEBUG_FILE);
     }
  
     wflow_data3 = (char **)wflow_buf3->data_ptr;
     strcpy (entity, wflow_data3[0]);
     MEMclose (&wflow_buf3);
     command_no = nfmcommandno;
     }
    else
       command_no = commandno;

 /* initialise the WFinfo structure with what is known */

   strcpy(WFinfo.entity, entity);
   strcpy(WFinfo.command_name, commandname);
   strcpy(WFinfo.item_name,part_num);
   strcpy(WFinfo.item_rev,revision);
   strcpy(WFinfo.catalog_name, catalog_name);
   strcpy(WFinfo.workflow_name,wf_name);
   strcpy(WFinfo.proj_name,proj_name);
   WFinfo.command = command_no;
   WFinfo.proj_no = proj_no;
   WFinfo.catalog_no = catno;
   WFinfo.acl = acl_no;

/* these are used in set_to_state */

/*
   strcpy (WFitemno, "n_itemno");
   strcpy (WFitemname, "n_itemname");
   strcpy (WFitemrev, "n_itemrev");
   strcpy (WFdtype1, "integer");
   strcpy (WFdtype2, "char(15)");
   strcpy (WFdtype3, "char(15)");
*/

   /* First check whether this command is one of the anamoulous
       like add_part, create_catalog etc. */

if (((strcmp(commandname, "PDMAdd Part")) != 0) 
    && ((strcmp (commandname, "Create Catalog")) != 0)
    && ((strcmp (commandname, "Add Project")) != 0))
 {
    /* Then check for the entity: */

/* MOD for NFM3.0 schema changes: the entities are no longer
   called NFMPROJECTS, NFMCATALOGS, etc. but are called 
     "P" for PROJECT
     "C" for CATALOG
     "I" for ITEM
     "N" for NOENTITY
     "D" for DON'T CHECK (new entity)
     "S" for SDP
     "A" for ADMIN

     */
    
 if (!strcmp (entity,"P"))
   {
status = PDMvalidate_project (userno, entity, wf_name, 
                              proj_name, catalog_name, part_num, 
                              revision, command_no);
    if (status != PDM_S_SUCCESS)
     {
        _PDMdebug (fn,  "PDMvalidate_project failed: status %d\n", 
                  status);
        return(status);
      }
    }

 else if (!strcmp (entity,"C"))
    {
status = PDMvalidate_catalog (userno, entity, wf_name, 
                              proj_name, catalog_name, part_num, 
                              revision, command_no);
    if (status != PDM_S_SUCCESS)
     {
        _PDMdebug (fn,  "PDMvalidate_catalog failed: status %d\n", 
                  status);
        return(status);
      }
    }

 else if (!strcmp (entity,"I"))
    {
status = PDMvalidate_item (userno, entity, wf_name, 
                              proj_name, catalog_name, part_num, 
                              revision, command_no);
    if (status != PDM_S_SUCCESS)
     {
        _PDMdebug (fn,  "PDMvalidate_item failed: status %d\n", 
                  status);
        return(status);
      }
    }
 else if (!strcmp (entity,"N"))
    {
status = PDMvalidate_noentity (userno, entity, wf_name, 
                              proj_name, catalog_name, part_num, 
                              revision, command_no);
    if (status != PDM_S_SUCCESS)
     {
        _PDMdebug (fn,  "PDMvalidate_noentity failed: status %d\n", 
                  status);
        return(status);
      }
    }
 
     } /* end of if "command is not anomalous" */

else /* command is strange like add part etc */
{
 if (!strcmp (entity,"P"))
   {
status = PDMsp_validate_project (userno, entity, wf_name, 
                              proj_name, catalog_name, part_num, 
                              revision, command_no);
    if (status != PDM_S_SUCCESS)
     {
        _PDMdebug (fn,  "PDMsp_validate_project failed: status %d\n", 
                  status);
        return(status);
      }
    }

 else if (!strcmp (entity,"C"))
    {
status = PDMsp_validate_catalog (userno, entity, wf_name, 
                              proj_name, catalog_name, part_num, 
                              revision, command_no);
    if (status != PDM_S_SUCCESS)
     {
        _PDMdebug (fn,  "PDMsp_validate_catalog failed: status %d\n", 
                  status);
        return(status);
      }
    }

 else if (!strcmp (entity,"I"))
    {
status = PDMsp_validate_item (userno, entity, wf_name, 
                              proj_name, catalog_name, part_num, 
                              revision, command_no);
    if (status != PDM_S_SUCCESS)
     {
        _PDMdebug (fn,  "PDMsp_validate_item failed: status %d\n", 
                  status);
        return(status);
      }
    }
 /* is the following needed? */

 else if (!strcmp (entity,"N"))
    {
status = PDMsp_validate_noentity (userno, entity, wf_name, 
                              proj_name, catalog_name, part_num, 
                              revision, command_no);
    if (status != PDM_S_SUCCESS)
     {
        _PDMdebug (fn,  "PDMsp_validate_noentity failed: status %d\n", 
                  status);
        return(status);
      }
    }
 
     } /* end of else "command is anomalous" */

 /* support for pre_executable processes added 052692 - MaC */

     if (WFinfo.transition > 0) {
        status = NFMpre_execute_process (WFinfo.transition);
        if (status != NFM_S_SUCCESS) {
           _PDMdebug (fn, "NFMpre_execute_process failed : status = <0x%.8x>\n",
           status);
           return (status);
         }
      }

     if (PDMdebug_on) {
             NFMprint_wfinfo () ;
        }


  PDMdebug("EXIT: PDMsvalidate_user_access:\n");
  PDMdebug("SUCCESSFUL VALIDATION:\n");
  return (PDM_S_SUCCESS);
}


int PDMsset_to_state(wf_buffer)
	MEMptr		wf_buffer;
{
	char		*fn = "PDMsset_to_state";
	char		**data;
	MSGptr		app_ptr;
        long		error_no;
        char		app_name [20];
	struct WFstruct	bak;
        char		error_msg[86];

	PDMdebug("ENTER:PDMsset_to_state\n");

	status = MEMbuild_array(wf_buffer);
	if(status != MEM_S_SUCCESS) {
   	   MEMclose(&wf_buffer);
       _PDMdebug (fn,"MEMbuild_array failed : status %d\n",status);
	   return(PDM_E_BUILD_ARRAY);
	}

 if(PDMdebug_on) {
       MEMprint_buffer("wf_buffer during set_to_state ",
       wf_buffer,PDM_DEBUG_FILE);
   }
	data = (char **) wf_buffer->data_ptr;
	app_ptr.error_no = atol(data[0]);
	if(app_ptr.error_no == PDM_S_SUCCESS) {
		app_ptr.error_no = NFM_S_SUCCESS;
		error_no = NFM_S_SUCCESS;
	}
    else {
		app_ptr.error_no = NFM_E_FAILURE;
		error_no = NFM_E_FAILURE;
	}
	strcpy(app_ptr.error_msg,data[2]);

/* backing up WFinfo structure ..*/

    PDMi_backup_wfinfo (&bak);


/* commented out as set_to_state  which is not working...
    status = WFset_to_state(PDMexec->user_id,data[1],app_ptr);
    if(status != NFM_S_SUCCESS) {
	MEMclose(&wf_buffer);
	_PDMdebug (fn,"WFset_to_state failed status -> %d \n",status);
        ERRget_specific_number (NFM, &status);
       _PDMdebug (fn, "status = %d\n", status);
	return(status);
    }    
....*/

    strcpy(app_name, data[1]);
    strcpy(error_msg, data[2]);
    status = NFMset_wf_state (app_name, error_no, error_msg);
    if(status != NFM_S_SUCCESS) {
	MEMclose(&wf_buffer);
	_PDMdebug (fn,"WFset_to_state failed status -> %d \n",status);
        ERRget_specific_number (NFM, &status);
       _PDMdebug (fn, "status = %d\n", status);
	return(status);
    }    
/* printing WFinfo structure afterwards ..*/

    PDMi_restore_wfinfo (bak);
/* proj_name in WFinfo structure needs to be cleared for
   next command. The scenario is like this:
    o user selects project and catalog to add part
    o user adds part.
    o user clears the project and catalog fields for adding part
      to another catalog _not_ mapped to the previous catalog
      during the same session.
    o NFM fails during retrieving attributes for the new catalog
      because, WFinfo struct still shows the old project name.
    So, as a temp fix, the project name is blanked out.
*/
_PDMdebug (fn, "blanking projname [%s] projno [%d] from WFinfo_struct\n",
       WFinfo.proj_name, WFinfo.proj_no);
    WFinfo.proj_name[0] = '\0';
    WFinfo.proj_no = -1;
_PDMdebug (fn, "after blanking projname [%s] projno [%d] \n",
       WFinfo.proj_name, WFinfo.proj_no);
	MEMclose(&wf_buffer);
    PDMdebug("EXIT:PDMsset_to_state\n");

    return(PDM_S_SUCCESS);	
}


int PDMmake_transition(attr_buffer, data_buffer)
	MEMptr		attr_buffer;
	MEMptr		data_buffer;
{
	char	*fn = "PDMmake_transition";
        int     itemno , catno;
	char		sql_str[512];

	PDMdebug("ENTER:PDMmake_transition\n");

/* added by kumar on 3/19/92 */

      sprintf (sql_str,
"UPDATE %s SET n_itemlock = 'N' WHERE n_itemname = '%s' AND n_itemrev = '%s'",
      PDMexec->catalog,PDMexec->part_num,PDMexec->revision);

     SQLstmt(sql_str);
        PDMris_get_catno(PDMexec->catalog,&catno);
        WFinfo.catalog_no = catno;
        PDMris_get_pitemno(&itemno, PDMexec->catalog, PDMexec->part_num, PDMexec->revision );
        WFinfo.item_no = itemno; 
        strcpy(WFinfo.entity , "I"); 
    status = WFmake_transition(PDMexec->user_id,attr_buffer,data_buffer);
    if(status != NFM_S_SUCCESS) {
	_PDMdebug (fn,"WFmake_transition failed status -> %d \n",status);
        ERRget_specific_number (NFM, &status);
       _PDMdebug (fn, "status = %d\n", status);
/*
	if(status == NFM_E_FROM_MAKE_TRANS) {
		return(PDM_E_FROM_MAKE_TRANS);
	} else if (status == NFM_E_TO_MAKE_TRANS) {
		return(PDM_E_TO_MAKE_TRANS);
	} else {
		return(PDM_E_MAKE_TRANSITION);
	}
*/
         return(status);
    }   
      sprintf (sql_str,
"UPDATE %s SET n_itemlock = 'U' WHERE n_itemname = '%s' AND n_itemrev = '%s'",
      PDMexec->catalog,PDMexec->part_num,PDMexec->revision);
      SQLstmt(sql_str);

    status = NFMset_wf_state ("PDM", NFM_S_SUCCESS, "Successful completion");
    if(status != NFM_S_SUCCESS) {
         _PDMdebug (fn, "WFset_to_state failed status - \n");
          ERRget_specific_number (NFM, &status);
         return(status);
         }
    PDMdebug("EXIT:PDMmake_transition\n");
    return(PDM_S_SUCCESS);	
}
  
/* case entity is NFMITEM */


int PDMvalidate_item (userno, entity, wf_name, proj_name, 
         catalog_name, part_num, revision, command_no)
char    *wf_name, *entity;
char    *proj_name, *catalog_name;
char    *part_num, *revision;
long     command_no;
long	 userno;
{
char	*fn = "PDMvalidate_item";
MEMptr	wflow_buf1=NULL;
MEMptr	wflow_buf2=NULL;
MEMptr	wflow_buf4=NULL;
MEMptr	wflow_buf5=NULL;
char	**wflow_data1;
char	**wflow_data2;
char	**wflow_data4;
char	**wflow_data5;
char	transitionname[80];
char	logonsuccess [5];
char	logonfailure [5];
char	notify [5];
char    *msg = NULL;
int	itemno = -1; 
int	aclno = -1; 
int     stateno = -1;
int	tostate = -1;
int	fromstate = -1;
int	transition_no = -1;
int	workflowno = -1;
int	i, matched = -1;
int	n_userno;
int	tmp_fromstate = -1;
int _PDMget_db_error();


    PDMdebug("ENTER:PDMvalidate_item\n");


_PDMdebug (fn, "PDMvalidate_item : Catalog       = <%s>\n\
PDMvalidate_item : Partno = <%s>\n\
PDMvalidate_item : Revision = <%s>\n\
PDMvalidate_item : Commandno = <%d>\n", 
catalog_name, part_num, revision, command_no);

 sprintf (sql_str,
       "SELECT  %s FROM %s WHERE %s = '%s' AND %s = '%s' ",
       "n_aclno, n_stateno, n_itemno",
       catalog_name,
       "n_itemname", part_num,
       "n_itemrev",revision);


  /*intertime = call_time ();*/
     status = SQLquery(sql_str,&wflow_buf1,512);
  /*exittime = call_time();
  sprintf(s,"SQLquery %f\n",(exittime - intertime));
  TIMEdebug(s);*/

     if (status != SQL_S_SUCCESS)
    {
      status = _PDMget_db_error(status);
      if(status == PDM_I_TABLE_LOCKED)
       {
        /*  selecting from the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDMupdate_dots ();
                 msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS_HOLD);
                 UI_status (msg);
                sleep (30);
                status = SQLquery(sql_str,&wflow_buf1,512);
                if (status != SQL_S_SUCCESS)
                 {
                 UI_status (msg);
                sleep (30);
                status = SQLquery(sql_str,&wflow_buf1,512);
                if (status != SQL_S_SUCCESS){
                msg = (char *)PDUtranslate_message(PDS_M_CONCURRENT_TAB_ACCESS);
           UI_status (msg);
          status = PDM_I_COULD_NOT_LOCK_TABLE;
                 return(status);
                 }
              }
          }
       else
       {
       MEMclose(&wflow_buf1);
    sprintf (sql_str,
       "SELECT  %s FROM e_%s WHERE %s = '%s' AND %s = '%s' ",
       "n_aclno, n_stateno, n_itemno",
       catalog_name,
       "n_itemname", part_num,
       "n_itemrev",revision);
     status = SQLquery(sql_str,&wflow_buf1,512);
     if (status != SQL_S_SUCCESS)
          {
       MEMclose (&wflow_buf1);
       _PDMdebug (fn, "PDMvalidate_item: SQLquery : status %d\n", status);
        status = _PDMget_db_error (status);
       return(status);
          }
       }
   }

   status = MEMbuild_array(wflow_buf1);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf1);
		_PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on) {
       MEMprint_buffer("wflow_buf1 after first query ",
       wflow_buf1,PDM_DEBUG_FILE);
   }
  
   wflow_data1 = (char **)wflow_buf1->data_ptr;
     aclno = atol (wflow_data1[0]);
     stateno = atol (wflow_data1[1]);
     fromstate = stateno;
     itemno = atol (wflow_data1[2]);
 MEMclose (&wflow_buf1);

 _PDMdebug (fn, "aclno = %d, stateno = %d\n", aclno, stateno);


/* Second query to get workflowno and workflowname from nfmacls 
     The data from this query, hopefully, will be cached */

sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = %d",
     "n_workflowno",
     "NFMACLS",
     "n_aclno",aclno);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf2,512);
/*exittime = call_time();
sprintf(fn, "SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf2);
     _PDMdebug (fn,  "PDMvalidate_item: SQLquery: status %d\n", status);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(wflow_buf2);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf2);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf2 after second query ",
       wflow_buf2,PDM_DEBUG_FILE);
   }
  
   wflow_data2 = (char **)wflow_buf2->data_ptr;
   workflowno = atol(wflow_data2[0]);
  _PDMdebug  (fn,  "workflowno=%d \n",
               workflowno);
 MEMclose (&wflow_buf2);


/* Now, get the tostate, transitionno from nfmtransitions
   where n_fromstate is 1 or 0 or fromstate: 
   if it is either 1 or 0 then no change of states will occur
   but the transition is valid. If there no rows found, only
   then the is transition invalid. Note that this logic assumes
   that for all commands causing state change, the fromstate is 
   NOT equal to either 1 or 0  else this query would return 
   multiple rows (we don't want *that* happening, do we ;)

 */

   sprintf (sql_str,
   "SELECT %s FROM %s WHERE %s = %d AND %s = %d AND ( %s  %d )",
        "n_tostate, n_transitionno, n_transitionname, n_fromstate, n_logonsuccess, n_logonfailure, n_notify",
        "NFMTRANSITIONS",
        "n_commandno", command_no,
        "n_workflowno", workflowno,
        "n_fromstate = 0 OR n_fromstate = 1 OR n_fromstate = ",fromstate);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf4,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf4);
     if (status == SQL_I_NO_ROWS_FOUND)
        {
        _PDMdebug (fn, "No transition possible \n");
        return (PDM_E_NO_TRANSITIONS);
         }
      else {
     _PDMdebug (fn,  "PDMvalidate_item: SQLquery: status %d\n", status);
        return(PDM_E_SQL_STMT);
           }
   }

   status = MEMbuild_array(wflow_buf4);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf4);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf4 after third query ",
       wflow_buf4,PDM_DEBUG_FILE);
   }
  
   wflow_data4 = (char **)wflow_buf4->data_ptr;


     tostate = atol(wflow_data4[0]);
     transition_no = atol(wflow_data4[1]);
     strcpy(transitionname ,wflow_data4[2]);
     tmp_fromstate = atol(wflow_data4[3]);
     strcpy (logonsuccess, wflow_data4[4]);
     strcpy (logonfailure, wflow_data4[5]);
     strcpy (notify, wflow_data4[6]);

      _PDMdebug (fn, "logonsuccess[%s], logonfailure[%s], notify[%s]\n",
                      logonsuccess, logonfailure, notify);
     _PDMdebug  (fn, 
"transition_no = %d, to_state = %d, transition_name = %s, tmp_fromstate = %d \n",
     transition_no, tostate, transitionname, tmp_fromstate);
 MEMclose (&wflow_buf4);

/*
      if ( tmp_fromstate == 0 || tmp_fromstate == 1 )
         {
        _PDMdebug (fn,  "PDMvalidate_item: No state change : From state is  : %d\n", 
                  tmp_fromstate);
        return(PDM_S_SUCCESS);
      }
*/
          

      
sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = %s AND %s = %d AND %s = %d ",
     "n_userno ",
     "NFMACLUSERS, NFMACCESS",
     "NFMACLUSERS.n_classno",
     "NFMACCESS.n_classno",
     "NFMACLUSERS.n_aclno",
     aclno,
     "NFMACCESS.n_transitionno",
     transition_no);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf5,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf5);
     if (status == SQL_I_NO_ROWS_FOUND)
        {
        _PDMdebug (fn, "No transition possible \n");
        return (PDM_E_NO_TRANSITIONS);
         }
      else {
        _PDMdebug (fn,  "PDMvalidate_item: SQLquery : status %d\n", 
                  status);
        return(PDM_E_SQL_STMT);
           }
   }
   status = MEMbuild_array(wflow_buf5);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf5);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
                MEMprint_buffer("wflow_buf5 after fourth query ",
                wflow_buf5,PDM_DEBUG_FILE);
   }
   wflow_data5 = (char **)wflow_buf5->data_ptr;
 
/* check to see whether the userno matches with any one 
   of the n_usernos from the query : But first of all
   check to see whether there are more than one rows.. */


  if (wflow_buf5->rows > 1) {
     _PDMdebug (fn, "more than one userno in buffer\n");
     for (i = 0; i < wflow_buf5->rows; ++i) {
      /* Here note that the buffer format is assumed to be fixed hence
         the column_no is hardcoded as 0 */
      n_userno = (atol (wflow_data5[(wflow_buf5->columns * i) + 0]));
      if (n_userno  == userno){
      matched = i;
          }
      if (matched >= 0)
      break;
        }
      MEMclose (&wflow_buf5);
     }
   else 
   {
    n_userno = (atol (wflow_data5[0]));
    if (n_userno  != userno){
    _PDMdebug (fn, 
       "PDMvalidate_item: user not authorised to perform this command\n");
    _PDMdebug  ( fn, "n_userno = %d and userno = %d, \n",n_userno, userno);
    return(PDM_E_NOT_ACL_USER);
          }
    matched = 1;
    MEMclose (&wflow_buf5);
    }

/* Update the WF structure for NFM commands.. */
   if (matched >= 0)
    {
     WFinfo.workflow = workflowno;
     WFinfo.transition = transition_no;
     WFinfo.acl = aclno;
     WFinfo.item_no = itemno;
     WFinfo.next_state = tostate;
     WFinfo.curr_state = fromstate;
     strcpy(WFinfo.transition_name,transitionname);
     strcpy (WFinfo.logon_s, logonsuccess);
     strcpy (WFinfo.logon_f, logonfailure);
     strcpy (WFinfo.notify, notify);
     }
    else
    { 
    _PDMdebug (fn, "user not authorised to perform this command\n");
    return(PDM_E_NOT_ACL_USER);
     }


_PDMdebug  (fn, "End of PDMvalidate_item  :\nWorkflow Name = <%s>\nProject  Name = <%s>\nTable    Name = <%s>\nItem     Name = <%s>\nItem     Rev  = <%s>\nentity : <%s>\ntransition_no : <%d> \nTransition_name : <%s>\n", 
 wf_name, proj_name, catalog_name, part_num, revision, 
  entity, transition_no, transitionname);


    PDMdebug("EXIT:PDMvalidate_item\n");
return (PDM_S_SUCCESS);
}



/* case entity is NFMCATALOG */


int PDMvalidate_catalog (userno, entity, wf_name, proj_name, 
         catalog_name, part_num, revision, command_no)
char    *entity, *wf_name;
char    *proj_name, *catalog_name;
char    *part_num, *revision;
long     command_no;
long	 userno;
{
MEMptr	wflow_buf1=NULL;
MEMptr	wflow_buf2=NULL;
MEMptr	wflow_buf4=NULL;
MEMptr	wflow_buf5=NULL;
char	**wflow_data1;
char	**wflow_data2;
char	*fn = "PDMvalidate_catalog";
char	**wflow_data4;
char	**wflow_data5;
char	transitionname[80];
int	aclno = -1; 
int     stateno = -1;
int	tostate = -1;
int	fromstate = -1;
int	transition_no = -1;
int	catalog_no;
int	workflowno = -1;
int	i, matched = -1;
int	n_userno;
int	tmp_fromstate = -1;
char	logonsuccess [5];
char	logonfailure [5];
char	notify [5];


    PDMdebug("ENTER:PDMvalidate_catalog\n");


_PDMdebug  (fn, "PDMvalidate_catalog : Catalog       = <%s>\nPDMvalidate_catalog : Partno = <%s>\nPDMvalidate_catalog : Revision = <%s>\nPDMvalidate_catalog : Commandno = <%d>\n", 
 catalog_name, part_num, revision, command_no);

/*first 3 queries inserted here */

 sprintf (sql_str,
       "SELECT  %s FROM %s WHERE %s = '%s' ",
       "n_aclno, n_stateno, n_catalogno",
       "NFMCATALOGS",
       "n_catalogname", 
       catalog_name);


  /*intertime = call_time ();*/
     status = SQLquery(sql_str,&wflow_buf1,512);
  /*exittime = call_time();
  _PDMdebug (s,"SQLquery %f\n",(exittime - intertime));
  TIMEdebug(s);*/

     if (status != SQL_S_SUCCESS)
     {
       MEMclose (&wflow_buf1);
       _PDMdebug (fn,  "PDMvalidate_catalog: SQL statement: status %d\n", status);
       return(PDM_E_SQL_STMT);
    }

   status = MEMbuild_array(wflow_buf1);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf1);
		_PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf1 after first query ",
       wflow_buf1,PDM_DEBUG_FILE);
   }
  
   wflow_data1 = (char **)wflow_buf1->data_ptr;
     aclno = atol (wflow_data1[0]);
     stateno = atol (wflow_data1[1]);
     catalog_no = atol (wflow_data1[2]);
     fromstate = stateno;

_PDMdebug  ( fn, "aclno = %d, stateno = %d\n", aclno, stateno);
 MEMclose (&wflow_buf1);


/* Second query to get workflowno and workflowname from nfmacls 
     The data from this query, hopefully, will be cached */

 sprintf  (sql_str, "SELECT  %s FROM %s WHERE %s = %d",
                    "n_workflowno",
                    "NFMACLS",
                    "n_aclno", aclno);
/*
_PDMdebug  (sql_str,
     "SELECT  %s FROM %s WHERE %s = %d",
     "n_workflowno",
     "NFMACLS",
     "n_aclno",aclno);
*/

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf2,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS) {
     MEMclose(&wflow_buf2);
     _PDMdebug (fn,  "PDMvalidate_catalog: SQL statement: status %d\n", status);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(wflow_buf2);
   if(status != MEM_S_SUCCESS) {
		MEMclose(&wflow_buf2);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }

 if(PDMdebug_on) {
       MEMprint_buffer("wflow_buf2 after second query ",
       wflow_buf2,PDM_DEBUG_FILE);
   }
  
   wflow_data2 = (char **)wflow_buf2->data_ptr;

   workflowno = atol(wflow_data2[0]);

  _PDMdebug  (fn,  "workflowno=%d \n", workflowno);
   MEMclose(&wflow_buf2);


   sprintf (sql_str,
   "SELECT %s FROM %s WHERE %s = %d AND %s = %d AND ( %s  %d )",
     "n_tostate, n_transitionno, n_transitionname, n_fromstate, n_logonsuccess, n_logonfailure, n_notify",
     "NFMTRANSITIONS",
     "n_commandno", command_no,
     "n_workflowno", workflowno,
     "n_fromstate = 0 OR n_fromstate = 1 OR n_fromstate = ",fromstate);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf4,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS) {
     MEMclose(&wflow_buf4);
     if (status == SQL_I_NO_ROWS_FOUND) {
        _PDMdebug (fn, "Validate access failed: No transition possible \n");
          return(PDM_E_NOT_ACL_USER);
         }
      else {
     _PDMdebug (fn,  "PDMvalidate_catalog: SQL statement: status %d\n", status);
        return (PDM_E_NO_TRANSITIONS);
           }
   }

   status = MEMbuild_array(wflow_buf4);
   if(status != MEM_S_SUCCESS) {
		MEMclose(&wflow_buf4);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf4 after third query ",
       wflow_buf4,PDM_DEBUG_FILE);
   }
  
   wflow_data4 = (char **)wflow_buf4->data_ptr;

     strcpy(transitionname ,wflow_data4[2]);
     tostate = atol(wflow_data4[0]);
     tmp_fromstate = atol(wflow_data4[3]);
     transition_no = atol(wflow_data4[1]);
     strcpy (logonsuccess, wflow_data4[4]);
     strcpy (logonfailure, wflow_data4[5]);
     strcpy (notify, wflow_data4[6]);
      _PDMdebug (fn, "logonsuccess[%s], logonfailure[%s], notify[%s]\n",
                      logonsuccess, logonfailure, notify);

     _PDMdebug  (fn, 
    "transition_no = %d, to_state = %d, transition_name = %s, tmp_fromstate = %d\n",
     transition_no, tostate, transitionname, tmp_fromstate);
     MEMclose(&wflow_buf4);


/*
      if ( tmp_fromstate == 0 || tmp_fromstate == 1 )
         {
        _PDMdebug (fn, 
                "PDMvalidate_catalog: No state change : From state is  : %d\n", 
                  tmp_fromstate);
        return(PDM_S_SUCCESS);
      }
*/
          
      
      
sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = %s AND %s = %d AND %s = %d ",
     "n_userno ",
     "NFMACLUSERS, NFMACCESS",
     "NFMACLUSERS.n_classno",
     "NFMACCESS.n_classno",
     "NFMACLUSERS.n_aclno",
     aclno,
     "NFMACCESS.n_transitionno",
     transition_no);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf5,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf5);
     if (status == SQL_I_NO_ROWS_FOUND)
        {
        _PDMdebug (fn, "Validate catalog access failed: No transition possible \n");
        return (PDM_E_NO_TRANSITIONS);
         }
      else {
        _PDMdebug (fn,  "PDMvalidate_catalog: SQLquery : status %d\n", 
                  status);
        return(PDM_E_SQL_STMT);
           }
   }
   status = MEMbuild_array(wflow_buf5);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf5);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
                MEMprint_buffer("wflow_buf5 after fourth query ",
                wflow_buf5,PDM_DEBUG_FILE);
   }
   wflow_data5 = (char **)wflow_buf5->data_ptr;

  if (wflow_buf5->rows > 1) {
     for (i = 0; i < wflow_buf5->rows; ++i) {
      /* Here note that the buffer format is assumed to be fixed hence
         the column_no is hardcoded as 0 */
      n_userno = (atol (wflow_data5[(wflow_buf5->columns * i) + 0]));
      if (n_userno  == userno){
      matched = i;
          }
      if (matched >= 0)
      break;
        }
      MEMclose (&wflow_buf5);
     }
   else 
   {
    n_userno = (atol (wflow_data5[0]));
    if (n_userno  != userno){
    _PDMdebug (fn, "user not authorised to perform this command\n");
    _PDMdebug  ( fn, "n_userno = %d and userno = %d, \n",n_userno, userno);
    return(PDM_E_NOT_ACL_USER);
          }
    matched = 1;
    MEMclose (&wflow_buf5);
    }

/* Update the WF structure for NFM commands.. */
   if (matched >= 0)
    {
     WFinfo.workflow = workflowno;
     WFinfo.transition = transition_no;
     WFinfo.acl = aclno;
     WFinfo.next_state = tostate;
     WFinfo.curr_state = fromstate;
     WFinfo.catalog_no = catalog_no;
     strcpy(WFinfo.transition_name,transitionname);
     strcpy (WFinfo.logon_s, logonsuccess);
     strcpy (WFinfo.logon_f, logonfailure);
     strcpy (WFinfo.notify, notify);
     }
    else
    { 
    _PDMdebug (fn, "user not authorised to perform this command\n");
    return(PDM_E_NOT_ACL_USER);
     }


_PDMdebug  (fn, "End of PDMvalidate_catalog  :\n\
Workflow Name = <%s>\n\
Project  Name = <%s>\n\
Table    Name = <%s>\n\
Item     Name = <%s>\n\
Item     Rev  = <%s>\n\
entity : <%s>\n\
transition_no : <%d> \n\
Transition_name : <%s>\n", 
 wf_name, proj_name, catalog_name, part_num, revision, 
  entity, transition_no, transitionname);


    PDMdebug("EXIT:PDMvalidate_catalog\n");
return (PDM_S_SUCCESS);
}

/* case entity is NFMPROJECT */

int PDMvalidate_project (userno, entity, wf_name, proj_name, 
         catalog_name, part_num, revision, command_no)
char    *entity, *wf_name;
char    *proj_name, *catalog_name;
char    *part_num, *revision;
long     command_no;
long	 userno;

{
/* APOGEE START */
/*
MEMptr	wflow_buf3=NULL;
MEMptr	temp_buf=NULL;
char	**wflow_data3;
char	transcommand[2];
*/
/* APOGEE END */

MEMptr	wflow_buf1=NULL;
MEMptr	wflow_buf2=NULL;
MEMptr	wflow_buf4=NULL;
MEMptr	wflow_buf5=NULL;
char	**wflow_data1;
char	**wflow_data2;
char	**wflow_data4;
char	**wflow_data5;
char	transitionname[80];
int	aclno = -1; 
int	n_userno, proj_no; 
int     stateno = -1;
int	tostate = -1;
int	fromstate = -1;
int	transition_no = -1;
int	workflowno = -1;
int	i, matched = -1;
int	tmp_fromstate = -1;
char	*fn = "PDMvalidate_project";
char	logonsuccess [5];
char	logonfailure [5];
char	notify [5];


    PDMdebug("ENTER:PDMvalidate_project\n");

_PDMdebug  (fn, "In PDMvalidate_Project \n\
transition_no : <%d>\n", transition_no);

_PDMdebug  (fn, "PDMvalidate_project : Catalog       = <%s>\n\
PDMvalidate_project : Partno = <%s>\n\
PDMvalidate_project : Revision = <%s>\n\
PDMvalidate_project : Commandno = <%d>\n", 
 catalog_name, part_num, revision, command_no);


 sprintf (sql_str,
       "SELECT  %s FROM %s WHERE %s = '%s' ",
       "n_aclno, n_stateno, n_projectno",
       "NFMPROJECTS",
       "n_projectname", 
       proj_name);


  /*intertime = call_time ();*/
     status = SQLquery(sql_str,&wflow_buf1,512);
  /*exittime = call_time();
  sprintf(s,"SQLquery %f\n",(exittime - intertime));
  TIMEdebug(s);*/

     if (status != SQL_S_SUCCESS)
     {
       MEMclose (&wflow_buf1);
       _PDMdebug (fn,  "PDMvalidate_project:SQL statement: status %d\n", status);
       return(PDM_E_SQL_STMT);
    }

   status = MEMbuild_array(wflow_buf1);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf1);
		_PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf1 after first query ",
       wflow_buf1,PDM_DEBUG_FILE);
   }
  
   wflow_data1 = (char **)wflow_buf1->data_ptr;
     aclno = atol (wflow_data1[0]);
     stateno = atol (wflow_data1[1]);
     proj_no = atol (wflow_data1[2]);
     fromstate = stateno;

_PDMdebug  ( fn, "aclno = %d, stateno = %d\n", aclno, stateno);
  MEMclose(&wflow_buf1);


/* Second query to get workflowno and workflowname from nfmacls 
     The data from this query, hopefully, will be cached */

sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = %d",
     "n_workflowno",
     "NFMACLS",
     "n_aclno",aclno);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf2,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf2);
     _PDMdebug (fn,  "PDMvalidate_project: SQL statement: status %d\n", status);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(wflow_buf2);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf2);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf2 after second query ",
       wflow_buf2,PDM_DEBUG_FILE);
   }
  
   wflow_data2 = (char **)wflow_buf2->data_ptr;
   workflowno = atol(wflow_data2[0]);
  _PDMdebug  (fn,  "workflowno=%d \n",
               workflowno);
  MEMclose(&wflow_buf2);


   sprintf (sql_str,
   "SELECT %s FROM %s WHERE %s = %d AND %s = %d AND ( %s  %d )",
        "n_tostate, n_transitionno, n_transitionname, n_fromstate, n_logonsuccess, n_logonfailure, n_notify",
        "NFMTRANSITIONS",
        "n_commandno", command_no,
        "n_workflowno", workflowno,
        "n_fromstate = 0 OR n_fromstate = 1 OR n_fromstate = ",fromstate);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf4,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf4);
     if (status == SQL_I_NO_ROWS_FOUND)
        {
        _PDMdebug (fn, "Validate access failed: No transition possible \n");
        return (PDM_E_NO_TRANSITIONS);
         }
      else {
     _PDMdebug (fn,  "PDMvalidate_project: SQL statement: status %d\n", status);
        return(PDM_E_SQL_STMT);
           }
   }

   status = MEMbuild_array(wflow_buf4);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf4);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf4 after third query ",
       wflow_buf4,PDM_DEBUG_FILE);
   }
  
   wflow_data4 = (char **)wflow_buf4->data_ptr;

     strcpy(transitionname ,wflow_data4[2]);
     tostate = atol(wflow_data4[0]);
     tmp_fromstate = atol(wflow_data4[3]);
     transition_no = atol(wflow_data4[1]);
     strcpy (logonsuccess, wflow_data4[4]);
     strcpy (logonfailure, wflow_data4[5]);
     strcpy (notify, wflow_data4[6]);
      _PDMdebug (fn, "logonsuccess[%s], logonfailure[%s], notify[%s]\n",
                      logonsuccess, logonfailure, notify);

     _PDMdebug  (fn, 
    "transition_no = %d, to_state = %d, transition_name = %s, tmp_fromstate = %d\n",
     transition_no, tostate, transitionname, tmp_fromstate);
     MEMclose(&wflow_buf4);


/*
      if ( tmp_fromstate == 0 || tmp_fromstate == 1 )
         {
        _PDMdebug (fn, 
                "PDMvalidate_project: No state change : From state is  : %d\n", 
                  tmp_fromstate);
        return(PDM_S_SUCCESS);
      }
*/
          
      
sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = %s AND %s = %d AND %s = %d ",
     "n_userno ",
     "NFMACLUSERS, NFMACCESS",
     "NFMACLUSERS.n_classno",
     "NFMACCESS.n_classno",
     "NFMACLUSERS.n_aclno",
     aclno,
     "NFMACCESS.n_transitionno",
     transition_no);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf5,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf5);
     if (status == SQL_I_NO_ROWS_FOUND)
        {
        _PDMdebug (fn, "Validate access failed: No transition possible \n");
        return (PDM_E_NO_TRANSITIONS);
         }
      else {
        _PDMdebug (fn,  "PDMvalidate_project: SQLquery : status %d\n", 
                  status);
        return(PDM_E_SQL_STMT);
           }
   }
   status = MEMbuild_array(wflow_buf5);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf5);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
                MEMprint_buffer("wflow_buf5 after fourth query: ",
                wflow_buf5,PDM_DEBUG_FILE);
   }
   wflow_data5 = (char **)wflow_buf5->data_ptr;


  if (wflow_buf5->rows > 1) {
     for (i = 0; i < wflow_buf5->rows; ++i) {
      /* Here note that the buffer format is assumed to be fixed hence
         the column_no is hardcoded as 0 */
      n_userno = (atol (wflow_data5[(wflow_buf5->columns * i) + 0]));
      if (n_userno  == userno){
      matched = i;
          }
      if (matched >= 0){
      break;
         }
        }
      MEMclose (&wflow_buf5);
     }
   else 
   {
    n_userno = (atol (wflow_data5[0]));
    if (n_userno  != userno){
    _PDMdebug (fn, "user not authorised to perform this command\n");
    _PDMdebug  ( fn, "n_userno = %d and userno = %d, \n",n_userno, userno);
    return(PDM_E_NOT_ACL_USER);
          }
    matched = 1;
    MEMclose (&wflow_buf5);
    }

/* Update the WF structure for NFM commands.. */
   if (matched >= 0)
    {
     WFinfo.workflow = workflowno;
     WFinfo.transition = transition_no;
     WFinfo.next_state = tostate;
     WFinfo.curr_state = fromstate;
     WFinfo.proj_no = proj_no;
     strcpy(WFinfo.transition_name,transitionname);
     strcpy (WFinfo.logon_s, logonsuccess);
     strcpy (WFinfo.logon_f, logonfailure);
     strcpy (WFinfo.notify, notify);
     }
    else
    { 
    _PDMdebug (fn, "user not authorised to perform this command\n");
    return(PDM_E_NOT_ACL_USER);
     }


_PDMdebug  (fn, "End of PDMvalidate_project  :\n\
Workflow Name = <%s>\n\
Project  Name = <%s>\n\
Table    Name = <%s>\n\
Item     Name = <%s>\n\
Item     Rev  = <%s>\n\
entity : <%s>\n\
transition_no : <%d> \n\
Transition_name : <%s>\n", 
 wf_name, proj_name, catalog_name, part_num, revision, 
  entity, transition_no, transitionname);


    PDMdebug("EXIT:PDMvalidate_project\n");
return (PDM_S_SUCCESS);
}


/* Validate noentitity */


int PDMvalidate_noentity (userno, entity, wf_name, proj_name, 
         catalog_name, part_num, revision, command_no)
char    *entity, *wf_name;
char    *proj_name, *catalog_name;
char    *part_num, *revision;
long     command_no;
long	 userno;
{
char	*fn = "PDMvalidate_noentity";
MEMptr	wflow_buf1=NULL;
char	**wflow_data1;
char	transitionname[80];
int	tostate = -1;
int	fromstate = -1;
int	transition_no = -1;
int	workflowno = -1;
int	matched = -1;
char	logonsuccess [5];
char	logonfailure [5];
char	notify [5];
    PDMdebug("ENTER:PDMvalidate_noentity \n");


sprintf (sql_str,
"SELECT %s FROM %s WHERE %s = %d AND %s = %d AND %s = %s AND %s = %s AND %s = %s AND %s = %s",
 "n_userno, NFMTRANSITIONS.n_transitionno, NFMTRANSITIONS.n_transitionname, NFMTRANSITIONS.n_workflowno, NFMTRANSITIONS.n_logonsuccess, NFMTRANSITIONS.n_logonfailure, NFMTRANSITIONS.n_notify",
 "NFMTRANSITIONS, NFMACLS, NFMACLUSERS, NFMACCESS",
 "n_userno",
  userno,
 "NFMTRANSITIONS.n_commandno",
  command_no,
 "NFMTRANSITIONS.n_transitionno",
 "NFMACCESS.n_transitionno",
 "NFMTRANSITIONS.n_workflowno",
 "NFMACLS.n_workflowno",
 "NFMACLUSERS.n_classno",
 "NFMACCESS.n_classno",
 "NFMACLS.n_aclno",
 "NFMACLUSERS.n_aclno");
     
/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf1,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
    if (status == SQL_I_NO_ROWS_FOUND) {
      MEMclose(&wflow_buf1);
      _PDMdebug (fn, " user not authorised to perform this command \n");
       return(PDM_E_NOT_ACL_USER);
       }
     else {
     MEMclose(&wflow_buf1);
     _PDMdebug (fn,  "PDMvalidate_noentity: SQL statement: status %d\n", status);
     return(PDM_E_SQL_STMT);
      }
   }
   if ( status == SQL_S_SUCCESS ) matched = 1;

   status = MEMbuild_array(wflow_buf1);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf1);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf1 after first query ",
       wflow_buf1,PDM_DEBUG_FILE);
   }
  
/*
   The following changes were made:
   1. userno clause was added to sql query
   2. checking for the userno was removed from this function
      and forced the db to do it
   3. if the query returned no_rows_found; return not_validated.
   
   This was done at the suggestion of a customer in U_rope
   who did not want the query return so many rows.
   
*/

   wflow_data1 = (char **)wflow_buf1->data_ptr;

      transition_no = (atol (wflow_data1[(wflow_buf1->columns * 0) + 1]));
      workflowno = (atol (wflow_data1[(wflow_buf1->columns * 0) + 3]));
      strcpy (transitionname, (wflow_data1[(wflow_buf1->columns * 0) + 2]));
     strcpy (logonsuccess, wflow_data1[4]);
     strcpy (logonfailure, wflow_data1[5]);
     strcpy (notify, wflow_data1[6]);
      _PDMdebug (fn, "logonsuccess[%s], logonfailure[%s], notify[%s]\n",
                      logonsuccess, logonfailure, notify);
/*
  if (wflow_buf1->rows > 1) {
     for (i = 0; i < wflow_buf1->rows; ++i) {
*/
      /* Here note that the buffer format is assumed to be fixed hence
         the column_no is hardcoded as 0 */
/*
      n_userno = (atol (wflow_data1[(wflow_buf1->columns * i) + 0]));
      if (n_userno  == userno){
      matched = i;
          }
      if (matched >= 0){
*/
      /* Here also the buffer format is assumed to be fixed hence
         the column_no is hardcoded as 1 and 2 for transno and name */
/*
      transition_no = (atol (wflow_data1[(wflow_buf1->columns * matched) + 1]));
      workflowno = (atol (wflow_data1[(wflow_buf1->columns * matched) + 3]));
      strcpy (transitionname, (wflow_data1[(wflow_buf1->columns * matched) + 2]));
      break;
         }
        }
      MEMclose (&wflow_buf1);
     }
   else 
   {
    n_userno = (atol (wflow_data1[0]));
    if (n_userno  != userno){
    _PDMdebug (fn, "user not authorised to perform this command\n");
    _PDMdebug  ( fn, "n_userno = %d and userno = %d, \n",n_userno, userno);
    return(PDM_E_NOT_ACL_USER);
          }
    matched = 1;
    transition_no = atol (wflow_data1[1]);
    strcpy (transitionname, (wflow_data1[2]));
    MEMclose (&wflow_buf1);
    }
*/

/* Update the WF structure for NFM commands.. */
   if (matched >= 0)
    {
     WFinfo.workflow = workflowno;
     WFinfo.transition = transition_no;
     WFinfo.next_state = tostate;
     WFinfo.curr_state = fromstate;
     strcpy(WFinfo.transition_name,transitionname);
     strcpy (WFinfo.logon_s, logonsuccess);
     strcpy (WFinfo.logon_f, logonfailure);
     strcpy (WFinfo.notify, notify);
     }
    else
    { 
    _PDMdebug (fn, "user not authorised to perform this command\n");
    return(PDM_E_NOT_ACL_USER);
     }


_PDMdebug  (fn, "End of PDMvalidate_noentity  :\n\
Workflow Name = <%s>\n\
Project  Name = <%s>\n\
Table    Name = <%s>\n\
Item     Name = <%s>\n\
Item     Rev  = <%s>\n\
entity : <%s>\n\
transition_no : <%d> \n\
Transition_name : <%s>\n\
Workflow no = <%d>", 
 wf_name, proj_name, catalog_name, part_num, revision, 
  entity, transition_no, transitionname, workflowno);

    PDMdebug("EXIT:PDMvalidate_noentity \n");
return (PDM_S_SUCCESS);
}



int PDMsp_validate_item (userno, entity, wf_name, proj_name, 
         catalog_name, part_num, revision, command_no)
char    *entity, *wf_name;
char    *proj_name, *catalog_name;
char    *part_num, *revision;
long     command_no;
long	 userno;
{
char	*fn = "PDMsp_validate_item";
/* MEMptr	wflow_buf0=NULL;*/
MEMptr	wflow_buf1=NULL;
MEMptr	wflow_buf2=NULL;
char	**wflow_data1;
char	**wflow_data2;
char	transitionname[80];
int	aclno = -1; 
/*int	classno1 = -1, classno2 = -1; 
int	stateno = -1;
int	fromstate = -1;
int	itemno = -1;
int	i, j, matched = -1;
*/
int	transition_no = -1;
int	x;
char	or_strg[1024];
char	logonsuccess [5];
char	logonfailure [5];
char	notify [5];

    PDMdebug("ENTER:PDMsp_validate_item \n");


_PDMdebug  (fn, "PDMsp_validate_item : Catalog       = <%s>\n\
PDMvalidate_item : Partno = <%s>\n\
PDMvalidate_item : Revision = <%s>\n\
PDMvalidate_item : Commandno = <%d>\n", 
 catalog_name, part_num, revision, command_no);

 sprintf (sql_str,
       "SELECT  %s FROM %s WHERE %s = %d ",
       "n_aclno",
       "NFMCATALOGACLMAP",
       "n_catalogno", WFinfo.catalog_no);


     status = SQLquery(sql_str,&wflow_buf1,512);
     if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND) {
       MEMclose (&wflow_buf1);
       _PDMdebug (fn, "SQLquery : status %d\n", status);
       return(PDM_E_SQL_STMT);
    }
    if (status == SQL_I_NO_ROWS_FOUND) {
        _PDMdebug (fn, "catalog is unmapped: regular special validation!!\n");
        status = PDMitem_val_in_unmapped_cat (userno, entity, wf_name, 
                     proj_name, catalog_name, part_num, revision, command_no);
         if (status != PDM_S_SUCCESS){
         _PDMdebug (fn, "PDMitem_val_in_unmapped_cat failed %d\n", status);
         return (status);
           }
         PDMdebug("EXIT:PDMsp_validate_item \n");
         return (PDM_S_SUCCESS);
         }
   status = MEMbuild_array(wflow_buf1);
   if(status != MEM_S_SUCCESS) {
		MEMclose(&wflow_buf1);
		_PDMdebug (fn,"%s %d \n", "MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on) {
       MEMprint_buffer("wflow_buf1 after first query ",
       wflow_buf1,PDM_DEBUG_FILE);
   }
  
   wflow_data1 = (char **)wflow_buf1->data_ptr;

/* If there are more than 1 rows in the buffer :i.e. if the catalog
   is mapped to more than one ACL, than the we need to check all the
   ACLs for existance of the user. 
   One way of doing it is to query for every row in the catalog. 
   Another is to build one query with all the ACLnos OR'd

    We will take the second approach...*/
    or_strg [0] = '\0';

    if (wflow_buf1->rows == 1){
     strcat (or_strg, "AND NFMACLUSERS.n_aclno = ");
        strcat (or_strg, wflow_data1 [0]);
     aclno = atol (wflow_data1 [0]);
       }
    else{
     strcat (or_strg, "AND ( NFMACLUSERS.n_aclno = ");
        strcat (or_strg, wflow_data1 [0]);
     for (x = 1; x < wflow_buf1->rows; ++x){
        strcat (or_strg, "OR NFMACLUSERS.n_aclno = ");
        strcat (or_strg, wflow_data1 [x]);
          }
     strcat (or_strg, " )");
       }

     _PDMdebug ("or_strg", "%s\n", or_strg);

 MEMclose (&wflow_buf1);

_PDMdebug (fn,"aclno = %d\n", aclno);


sprintf (sql_str,
"SELECT  %s FROM %s WHERE %s = %d %s = %s %s = %s %s = %d ",
 "NFMTRANSITIONS.n_transitionno, NFMTRANSITIONS.n_transitionname, NFMACCESS.n_classno, NFMTRANSITIONS.n_logonsuccess, NFMTRANSITIONS.n_logonfailure, NFMTRANSITIONS.n_notify ",
 "NFMTRANSITIONS, NFMACLUSERS, NFMACCESS",
 "NFMTRANSITIONS.n_commandno",
 command_no,
 "AND NFMTRANSITIONS.n_transitionno", 
 "NFMACCESS.n_transitionno",
 "AND NFMACCESS.n_classno",
 "NFMACLUSERS.n_classno",
 "AND NFMACLUSERS.n_userno",
 userno
  ); 
     
    strcat (sql_str, or_strg);
    _PDMdebug ("sql_str", "%s\n", sql_str);

   status = SQLquery(sql_str,&wflow_buf2,512);
   if (status != SQL_S_SUCCESS) {
     if (status == SQL_I_NO_ROWS_FOUND ) {
         _PDMdebug (fn, 
          "Validate Access Failed: User not allowed to perform this command\n");
           return(PDM_E_VALIDATE_ACCESS);
           }
     MEMclose(&wflow_buf2);
     _PDMdebug (fn, "SQLquery during PDMsp_validate_item: status %d\n", status);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(wflow_buf2);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf2);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf2 after first query ",
       wflow_buf2,PDM_DEBUG_FILE);
   }
  
   wflow_data2 = (char **)wflow_buf2->data_ptr;
   transition_no = (atol (wflow_data2[1]));
   strcpy (transitionname, (wflow_data2[2]));
     strcpy (logonsuccess, wflow_data2[3]);
     strcpy (logonfailure, wflow_data2[4]);
     strcpy (notify, wflow_data2[5]);
      _PDMdebug (fn, "logonsuccess[%s], logonfailure[%s], notify[%s]\n",
                      logonsuccess, logonfailure, notify);



  MEMclose (&wflow_buf2); 

/* Update the WF structure for NFM commands.. */
     WFinfo.transition = transition_no;
     WFinfo.item_no = PDMpart.n_itemno;
     strcpy(WFinfo.transition_name,transitionname);
     strcpy (WFinfo.logon_s, logonsuccess);
     strcpy (WFinfo.logon_f, logonfailure);
     strcpy (WFinfo.notify, notify);


_PDMdebug  (fn, "End of PDMsp_validate_item  :\n\
Workflow Name = <%s>\n\
Project  Name = <%s>\n\
Table    Name = <%s>\n\
Item     Name = <%s>\n\
Item     Rev  = <%s>\n\
entity : <%s>\n\
transition_no : <%d> \n\
Transition_name : <%s>\n", 
 wf_name, proj_name, catalog_name, part_num, revision, 
  entity, transition_no, transitionname);
    PDMdebug("EXIT:PDMsp_validate_item \n");
return (PDM_S_SUCCESS);
}


int PDMsp_validate_catalog (userno, entity, wf_name, proj_name, 
         catalog_name, part_num, revision, command_no)
char    *entity, *wf_name;
char    *proj_name, *catalog_name;
char    *part_num, *revision;
long     command_no;
long	 userno;
{
char	*fn = "PDMsp_validate_catalog";
MEMptr	wflow_buf1=NULL;
MEMptr	wflow_buf2=NULL;
char	**wflow_data1;
char	**wflow_data2;
char	transitionname[80];
int	aclno1 = -1; 
int	aclno2 = -1; 
int	transition_no = -1;
int	i, j, matched = -1;
char	logonsuccess [5];
char	logonfailure [5];
char	notify [5];
    PDMdebug("ENTER:PDMsp_validate_catalog \n");

sprintf (sql_str,
 "SELECT  %s FROM %s WHERE %s = %d AND %s = %s AND %s = %s ",
 "n_aclno, NFMTRANSITIONS.n_transitionno, NFMTRANSITIONS.n_transitionname, NFMTRANSITIONS.n_logonsuccess, NFMTRANSITIONS.n_logonfailure, NFMTRANSITIONS.n_notify",
 "NFMTRANSITIONS, NFMACLUSERS, NFMACCESS",
 "NFMTRANSITIONS.n_commandno",
 command_no,
 "NFMTRANSITIONS.n_transitionno", 
 "NFMACCESS.n_transitionno",
 "NFMACCESS.n_classno",
 "NFMACLUSERS.n_classno"); 


/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf1,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf1);
     _PDMdebug (fn,  "PDMsp_validate_catalog :SQL statement: status %d\n", status);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(wflow_buf1);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf1);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf1 after first query ",
       wflow_buf1,PDM_DEBUG_FILE);
   }
  
   wflow_data1 = (char **)wflow_buf1->data_ptr;
     strcpy (logonsuccess, wflow_data1[3]);
     strcpy (logonfailure, wflow_data1[4]);
     strcpy (notify, wflow_data1[5]);
      _PDMdebug (fn, "logonsuccess[%s], logonfailure[%s], notify[%s]\n",
                      logonsuccess, logonfailure, notify);

  /**
    Here is the first list of acls...
    **/


sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = %d",
     "n_aclno",
     "NFMACLUSERS",
     "n_userno",userno);

/*intertime = call_time ();*/ 
   status = SQLquery(sql_str,&wflow_buf2,512);
/*exittime = call_time();
sprintf(s,"SQLquery %f\n",(exittime - intertime));
TIMEdebug(s);*/

   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf2);
     _PDMdebug (fn,  "PDMsp_validate_catalog: SQL statement: status %d\n", status);
     return(PDM_E_ACL_USER);
   }

   status = MEMbuild_array(wflow_buf2);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf2);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf2 after first query ",
       wflow_buf2,PDM_DEBUG_FILE);
   }
  
   wflow_data2 = (char **)wflow_buf2->data_ptr;

  /**
    Here is the second list of acls...

    If there is one common acl between the two list
    return validated; else invalid user
  **/


     for (i = 0; i < wflow_buf1->rows; ++i) {
      aclno1 = (atol (wflow_data1[(wflow_buf1->columns * i) + 0]));
      for (j = 0; j < wflow_buf2->rows; ++j) {
      /* Here note that the buffer format is assumed to be fixed hence
         the column_no is hardcoded as 0 */
      aclno2 = (atol (wflow_data2[(wflow_buf2->columns * j) + 0]));
      if (aclno1  == aclno2 ){
      matched = i;
          }
      if (matched >= 0){
      /* Here also the buffer format is assumed to be fixed hence
         the column_no is hardcoded as 1 and 2 for transno and name */
      transition_no = (atol (wflow_data1[(wflow_buf1->columns * matched) + 1]));
      strcpy (transitionname, (wflow_data1[(wflow_buf1->columns * matched) + 2]));
      break;
         }
        }
      if (matched >= 0)
      break;
     }
  MEMclose (&wflow_buf1); 
  MEMclose (&wflow_buf2); 

/* Update the WF structure for NFM commands.. */
   if (matched >= 0)
    {
     WFinfo.transition = transition_no;
     strcpy(WFinfo.workflow_name,wf_name);
     strcpy(WFinfo.proj_name,proj_name);
     strcpy(WFinfo.transition_name,transitionname);
     strcpy (WFinfo.logon_s, logonsuccess);
     strcpy (WFinfo.logon_f, logonfailure);
     strcpy (WFinfo.notify, notify);
     }
    else
    { 
    _PDMdebug (fn, "user not authorised to perform this command\n");
    return(PDM_E_NOT_ACL_USER);
       }


_PDMdebug  (fn, "End of PDMsp_validate_catalog  :\n\
Workflow Name = <%s>\n\
Project  Name = <%s>\n\
Table    Name = <%s>\n\
Item     Name = <%s>\n\
Item     Rev  = <%s>\n\
entity : <%s>\n\
transition_no : <%d> \n\
Transition_name : <%s>\n", 
 wf_name, proj_name, catalog_name, part_num, revision, 
  entity, transition_no, transitionname);
    PDMdebug("EXIT:PDMsp_validate_catalog \n");
return (PDM_S_SUCCESS);
}


int PDMsp_validate_project (userno, entity, wf_name, proj_name, 
         catalog_name, part_num, revision, command_no)
char    *entity, *wf_name;
char    *proj_name, *catalog_name;
char    *part_num, *revision;
long     command_no;
long	 userno;
{
 char	*fn = "PDMsp_validate_project ";
/* APOGEE START */
/*
MEMptr	wflow_buf1=NULL;
MEMptr	wflow_buf2=NULL;
MEMptr	temp_buf=NULL;
char	**wflow_data1;
char	**wflow_data2;
char	transitionname[80];
char	transcommand[2];
int	aclno = -1; 
int     stateno = -1;
int	tostate = -1;
int	fromstate = -1;
int	transition_no = -1;
int	matched = -1;
char	logonsuccess [5];
char	logonfailure [5];
char	notify [5];
*/
/* APOGEE END */

    PDMdebug("ENTER:PDMsp_validate_project \n");
/* APOGEE START */
_PDMdebug  (fn, "PDMsp_validate_project  :\nWorkflow Name = <%s>\n\
Project  Name = <%s>\n\
Table    Name = <%s>\n\
Item     Name = <%s>\n\
Item     Rev  = <%s>\n\
entity : <%s>\n\
Command no : <%d>\n\
Userno = <%d>\n", 
 wf_name, proj_name, catalog_name, part_num, revision, 
  entity, command_no, userno);
	  /*
*/
/* APOGEE END */

  /*
  if (wflow_buf5->rows > 1) {
     for (i = 0; i < wflow_buf5->rows; ++i) {
       n_userno = (atol (wflow_data5[(wflow_buf5->columns * i) + 0]));
       if (n_userno  == userno){
       matched = 1;
       break;
          }
        }
       MEMclose (&wflow_buf5);
     }
   else 
   {
    n_userno = (atol (wflow_buf5[0]));
    if (n_userno  != userno){
    MEMclose (&wflow_buf5);
    _PDMdebug (fn, "user not authorised to perform this command\n");
    _PDMdebug  ( fn, "n_userno = %d and userno = %d, \n",n_userno, userno);
    return(PDM_E_NOT_ACL_USER);
          }
    }
    */

    PDMdebug("EXIT:PDMsp_validate_project \n");
return (PDM_S_SUCCESS);
}

int PDMsp_validate_noentity (userno, entity, wf_name, proj_name, 
         catalog_name, part_num, revision, command_no)
char    *entity, *wf_name;
char    *proj_name, *catalog_name;
char    *part_num, *revision;
long     command_no;
long	 userno;
{
 char	*fn = "PDMsp_validate_noentity ";
/* APOGEE START */
/*
MEMptr	wflow_buf1=NULL;
MEMptr	wflow_buf2=NULL;
MEMptr	temp_buf=NULL;
char	**wflow_data1;
char	**wflow_data2;
char	transitionname[80];
char	transcommand[2];
int	aclno = -1; 
int     stateno = -1;
int	tostate = -1;
int	fromstate = -1;
int	transition_no = -1;
int	matched = -1;
char	logonsuccess [5];
char	logonfailure [5];
char	notify [5];
*/
/* APOGEE END */
    PDMdebug("ENTER:PDMsp_validate_noentity \n");
/* APOGEE START */
_PDMdebug  (fn, "PDMsp_validate_noentity  :\nWorkflow Name = <%s>\n\
Project  Name = <%s>\n\
Table    Name = <%s>\n\
Item     Name = <%s>\n\
Item     Rev  = <%s>\n\
entity : <%s>\n\
Command no : <%d>\n\
Userno = <%d>\n", 
 wf_name, proj_name, catalog_name, part_num, revision, 
  entity, command_no, userno);
	  /*
*/
/* APOGEE END */

  /*
  if (wflow_buf5->rows > 1) {
     for (i = 0; i < wflow_buf5->rows; ++i) {
       n_userno = (atol (wflow_data5[(wflow_buf5->columns * i) + 0]));
       if (n_userno  == userno){
       matched = 1;
       break;
          }
        }
       MEMclose (&wflow_buf5);
     }
   else 
   {
    n_userno = (atol (wflow_buf5[0]));
    if (n_userno  != userno){
    MEMclose (&wflow_buf5);
    _PDMdebug (fn, "user not authorised to perform this command\n");
    _PDMdebug  ( fn, "n_userno = %d and userno = %d, \n",n_userno, userno);
    return(PDM_E_NOT_ACL_USER);
          }
    }
    */

    PDMdebug("EXIT:PDMsp_validate_noentity \n");
return (PDM_S_SUCCESS);
}


PDMi_backup_wfinfo (bak)
struct WFstruct	*bak;
{
 PDMdebug ("ENTER: PDMi_backup_wfinfo\n");
    bak->command = -1; bak->workflow = -1; bak->acl = -1;
    bak->transition = -1; bak->curr_state = -1; bak->next_state = -1;
    bak->proj_no = -1; bak->item_no = -1;
    bak->catalog_no = -1; 

    bak->entity [0] ='\0'; bak->command_name [0] ='\0';
    bak->workflow_name [0] ='\0';
    bak->logon_s [0] ='\0'; bak->logon_f [0] ='\0';
    bak->notify [0] ='\0'; bak->transition_name [0] ='\0';
    bak->current_statename [0] ='\0'; bak->next_statename [0] ='\0';
    bak->workflow_name [0] ='\0'; bak->acl_name [0] ='\0';
    bak->proj_name [0] ='\0';
    bak->item_name [0] ='\0'; bak->item_rev [0] ='\0';

    bak->command = WFinfo.command;
    bak->workflow = WFinfo.workflow;
    bak->acl = WFinfo.acl;
    bak->transition = WFinfo.transition;
    bak->curr_state = WFinfo.curr_state;
    bak->next_state = WFinfo.next_state;
    bak->proj_no = WFinfo.proj_no;
    bak->catalog_no = WFinfo.catalog_no;
    bak->item_no = WFinfo.item_no;

    strcpy (bak->entity, WFinfo.entity);
    strcpy (bak->command_name, WFinfo.command_name);
    strcpy (bak->workflow_name, WFinfo.workflow_name );
    strcpy (bak->logon_s, WFinfo.logon_s);
    strcpy (bak->logon_f, WFinfo.logon_f);
    strcpy (bak->notify, WFinfo.notify);
    strcpy (bak->transition_name, WFinfo.transition_name );
    strcpy (bak->current_statename, WFinfo.current_statename);
    strcpy (bak->next_statename, WFinfo.next_statename);
    strcpy (bak->workflow_name, WFinfo.workflow_name);
    strcpy (bak->acl_name, WFinfo.acl_name);
    strcpy (bak->proj_name, WFinfo.proj_name);
    strcpy (bak->catalog_name, WFinfo.catalog_name);
    strcpy (bak->item_name, WFinfo.item_name);
    strcpy (bak->item_rev, WFinfo.item_rev);
/*

sprintf (s, 
"   WFinfo.command = %d WFinfo.workflow = %d \n\
    WFinfo.acl = %d WFinfo.transition = %d \n\
    WFinfo.curr_state = %d WFinfo.next_state = %d \n\
    WFinfo.proj_no = %d WFinfo.catalog_no = %d \n\
    WFinfo.item_no = %d WFinfo.entity = %s \n\
    WFinfo.command_name = %s WFinfo.workflow_name = %s \n\
    WFinfo.acls_name = %s WFinfo.logon_s = %s \n\
    WFinfo.logon_f = %s WFinfo.notify = %s \n\
    WFinfo.transition_name = %s WFinfo.current_statename = %s \n\
    WFinfo.next_statename = %s WFinfo.workflow_name = %s \n\
    WFinfo.acl_name = %s WFinfo.proj_name = %s \n\
    WFinfo.catalog_name = %s WFinfo.item_name = %s \n\
    WFinfo.item_rev = %s\n ", WFinfo.command, WFinfo.workflow, WFinfo.acl,
    WFinfo.transition, WFinfo.curr_state, WFinfo.next_state, WFinfo.proj_no,
    WFinfo.catalog_no, WFinfo.item_no, WFinfo.entity, WFinfo.command_name,
    WFinfo.workflow_name, WFinfo.acl_name, WFinfo.logon_s, WFinfo.logon_f,
    WFinfo.notify, WFinfo.transition_name, WFinfo.current_statename,
    WFinfo.next_statename, WFinfo.workflow_name, WFinfo.acl_name, WFinfo.proj_name,
    WFinfo.catalog_name, WFinfo.item_name, WFinfo.item_rev);
   PDMdebug (s);
*/

sprintf (s, 
"   bak->command = %d bak->workflow = %d \n\
    bak->acl = %d bak->transition = %d \n\
    bak->curr_state = %d bak->next_state = %d \n\
    bak->proj_no = %d bak->catalog_no = %d \n\
    bak->item_no = %d bak->entity = %s \n\
    bak->command_name = %s bak->workflow_name = %s \n\
    bak->acl_name = %s bak->logon_s = %s \n\
    bak->logon_f = %s bak->notify = %s \n\
    bak->transition_name = %s bak->current_statename = %s \n\
    bak->next_statename = %s bak->workflow_name = %s \n\
    bak->acl_name = %s bak->proj_name = %s \n\
    bak->catalog_name = %s bak->item_name = %s \n\
    bak->item_rev = %s\n ", bak->command, bak->workflow, bak->acl,
    bak->transition, bak->curr_state, bak->next_state, bak->proj_no,
    bak->catalog_no, bak->item_no, bak->entity, bak->command_name,
    bak->workflow_name, bak->acl_name, bak->logon_s, bak->logon_f,
    bak->notify, bak->transition_name, bak->current_statename,
    bak->next_statename, bak->workflow_name, bak->acl_name, bak->proj_name,
    bak->catalog_name, bak->item_name, bak->item_rev);
   PDMdebug (s);

 PDMdebug ("EXIT: PDMi_backup_wfinfo\n");
}



PDMi_restore_wfinfo (bak)
struct WFstruct	bak;
{
 PDMdebug ("ENTER: PDMi_restore_wfinfo\n");

sprintf (s, 
"   bak.command = %d bak.workflow = %d \n\
    bak.acl = %d bak.transition = %d \n\
    bak.curr_state = %d bak.next_state = %d \n\
    bak.proj_no = %d bak.catalog_no = %d \n\
    bak.item_no = %d bak.entity = %s \n\
    bak.command_name = %s bak.workflow_name = %s \n\
    bak.acl_name = %s bak.logon_s = %s \n\
    bak.logon_f = %s bak.notify = %s \n\
    bak.transition_name = %s bak.current_statename = %s \n\
    bak.next_statename = %s bak.workflow_name = %s \n\
    bak.acl_name = %s bak.proj_name = %s \n\
    bak.catalog_name = %s bak.item_name = %s \n\
    bak.item_rev = %s\n ", bak.command, bak.workflow, bak.acl,
    bak.transition, bak.curr_state, bak.next_state, bak.proj_no,
    bak.catalog_no, bak.item_no, bak.entity, bak.command_name,
    bak.workflow_name, bak.acl_name, bak.logon_s, bak.logon_f,
    bak.notify, bak.transition_name, bak.current_statename,
    bak.next_statename, bak.workflow_name, bak.acl_name, bak.proj_name,
    bak.catalog_name, bak.item_name, bak.item_rev);
   PDMdebug (s);

    WFinfo.command = bak.command;
    WFinfo.workflow = bak.workflow;
    WFinfo.acl = bak.acl;
    WFinfo.transition = bak.transition;
    WFinfo.curr_state = bak.curr_state;
    WFinfo.next_state = bak.next_state;
    WFinfo.proj_no = bak.proj_no;
    WFinfo.catalog_no = bak.catalog_no;
    WFinfo.item_no = bak.item_no;

    strcpy (WFinfo.entity, bak.entity);
    strcpy (WFinfo.command_name, bak.command_name);
    strcpy (WFinfo.workflow_name, bak.workflow_name );
    strcpy (WFinfo.acl_name, bak.acl_name);
    strcpy (WFinfo.logon_s, bak.logon_s);
    strcpy (WFinfo.logon_f, bak.logon_f);
    strcpy (WFinfo.notify, bak.notify);
    strcpy (WFinfo.transition_name, bak.transition_name );
    strcpy (WFinfo.current_statename, bak.current_statename);
    strcpy (WFinfo.next_statename, bak.next_statename);
    strcpy (WFinfo.workflow_name, bak.workflow_name);
    strcpy (WFinfo.acl_name, bak.acl_name);
    strcpy (WFinfo.proj_name, bak.proj_name);
    strcpy (WFinfo.catalog_name, bak.catalog_name);
    strcpy (WFinfo.item_name, bak.item_name);
    strcpy (WFinfo.item_rev, bak.item_rev);

/*
sprintf (s, 
"   WFinfo.command = %d WFinfo.workflow = %d \n\
    WFinfo.acl = %d WFinfo.transition = %d \n\
    WFinfo.curr_state = %d WFinfo.next_state = %d \n\
    WFinfo.proj_no = %d WFinfo.catalog_no = %d \n\
    WFinfo.item_no = %d WFinfo.entity = %s \n\
    WFinfo.command_name = %s WFinfo.workflow_name = %s \n\
    WFinfo.acl_name = %s WFinfo.logon_s = %s \n\
    WFinfo.logon_f = %s WFinfo.notify = %s \n\
    WFinfo.transition_name = %s WFinfo.current_statename = %s \n\
    WFinfo.next_statename = %s WFinfo.workflow_name = %s \n\
    WFinfo.acl_name = %s WFinfo.proj_name = %s \n\
    WFinfo.catalog_name = %s WFinfo.item_name = %s \n\
    WFinfo.item_rev = %s\n ", WFinfo.command, WFinfo.workflow, WFinfo.acl,
    WFinfo.transition, WFinfo.curr_state, WFinfo.next_state, WFinfo.proj_no,
    WFinfo.catalog_no, WFinfo.item_no, WFinfo.entity, WFinfo.command_name,
    WFinfo.workflow_name, WFinfo.acl_name, WFinfo.logon_s, WFinfo.logon_f,
    WFinfo.notify, WFinfo.transition_name, WFinfo.current_statename,
    WFinfo.next_statename, WFinfo.workflow_name, WFinfo.acl_name, 
    WFinfo.proj_name,
    WFinfo.catalog_name, WFinfo.item_name, WFinfo.item_rev);
   PDMdebug (s);
*/
 PDMdebug ("EXIT: PDMi_restore_wfinfo\n");
}

int PDMitem_val_in_unmapped_cat (userno, entity, wf_name, 
                     proj_name, catalog_name, part_num, revision, command_no)
char    *entity, *wf_name;
char    *proj_name, *catalog_name;
char    *part_num, *revision;
long     command_no;
long	 userno;
{
char	*fn = "PDMitem_val_in_unmapped_cat";
/* MEMptr	wflow_buf0=NULL;*/
MEMptr	wflow_buf1=NULL;
MEMptr	wflow_buf2=NULL;
char	**wflow_data1;
char	**wflow_data2;
char	transitionname[80];
int	aclno1 = -1; 
int	aclno2 = -1; 
int	classno1 = -1; 
int	classno2 = -1; 
int	transition_no = -1;
int	i, j, matched = -1;
char	logonsuccess [5];
char	logonfailure [5];
char	notify [5];

    PDMdebug("ENTER:PDMitem_val_in_unmapped_cat \n");


_PDMdebug  (fn, "PDMitem_val_in_unmapped_cat : Catalog       = <%s>\n\
PDMitem_val_in_unmapped_cat : Partno = <%s>\n\
PDMitem_val_in_unmapped_cat : Revision = <%s>\n\
PDMitem_val_in_unmapped_cat : Commandno = <%d>\n", 
 catalog_name, part_num, revision, command_no);
/*modification for n_classno checking to make sure that a signoff user
  does not get permission/validation*/
sprintf (sql_str,
 "SELECT  %s FROM %s WHERE %s = %d AND %s = %s AND %s = %s ",
 "n_aclno, NFMTRANSITIONS.n_transitionno, NFMTRANSITIONS.n_transitionname, NFMACCESS.n_classno, NFMTRANSITIONS.n_logonsuccess, NFMTRANSITIONS.n_logonfailure, NFMTRANSITIONS.n_notify ",
 "NFMTRANSITIONS, NFMACLUSERS, NFMACCESS",
 "NFMTRANSITIONS.n_commandno",
 command_no,
 "NFMTRANSITIONS.n_transitionno", 
 "NFMACCESS.n_transitionno",
 "NFMACCESS.n_classno",
 "NFMACLUSERS.n_classno"); 
     

   status = SQLquery(sql_str,&wflow_buf1,512);
   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf1);
     _PDMdebug (fn,  "SQLquery during PDMitem_val_in_unmapped_cat: status %d\n", status);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(wflow_buf1);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf1);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf1 after first query ",
       wflow_buf1,PDM_DEBUG_FILE);
   }
  
   wflow_data1 = (char **)wflow_buf1->data_ptr;
     strcpy (logonsuccess, wflow_data1[4]);
     strcpy (logonfailure, wflow_data1[5]);
     strcpy (notify, wflow_data1[6]);
      _PDMdebug (fn, "logonsuccess[%s], logonfailure[%s], notify[%s]\n",
                      logonsuccess, logonfailure, notify);

  /**
    Here is the first list of acls...
    **/


sprintf (sql_str,
     "SELECT  %s FROM %s WHERE %s = %d",
     "n_aclno, n_classno",
     "NFMACLUSERS",
     "n_userno",userno);

   status = SQLquery(sql_str,&wflow_buf2,512);
   if (status != SQL_I_NO_ROWS_FOUND && status != SQL_S_SUCCESS) {
     MEMclose(&wflow_buf2);
     _PDMdebug (fn,  
      "SQLquery during PDMitem_val_in_unmapped_cat: status 0x%.8x\n", status);
     return(PDM_E_SQL_STMT);
   }
    /* Modified: User may not be mapped to any acl... MaC011694 */
    if (status == SQL_I_NO_ROWS_FOUND) {
      _PDMdebug (fn, "User is not mapped to any acl!!\n");
      return (PDM_E_NOT_ACL_USER);
      }

   status = MEMbuild_array(wflow_buf2);
   if(status != MEM_S_SUCCESS)
   {
		MEMclose(&wflow_buf2);
		_PDMdebug (fn, "%s %d \n",
		"MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on)
   {
       MEMprint_buffer("wflow_buf2 after second query ",
       wflow_buf2,PDM_DEBUG_FILE);
   }
  
   wflow_data2 = (char **)wflow_buf2->data_ptr;

  /**
    Here is the second list of acls...

    If there is one common acl between the two list
    return validated; else invalid user
  **/


     for (i = 0; i < wflow_buf1->rows; ++i) {
      aclno1 = (atol (wflow_data1[(wflow_buf1->columns * i) + 0]));
      classno1 = (atol (wflow_data1[(wflow_buf1->columns * i) + 3]));
      for (j = 0; j < wflow_buf2->rows; ++j) {
      /* Here note that the buffer format is assumed to be fixed hence
         the column_no is hardcoded as 0 */
      aclno2 = (atol (wflow_data2[(wflow_buf2->columns * j) + 0]));
      classno2 = (atol (wflow_data2[(wflow_buf2->columns * j) + 1]));
_PDMdebug ("checking acl/class", 
           "aclno1[%d] aclno2[%d] & classno1[%d] classno2[%d]\n", 
            aclno1, aclno2, classno1, classno2);
      if ( (aclno1  == aclno2 ) && (classno1 == classno2) ) {
      matched = i;
          }
      if (matched >= 0){
      /* Here also the buffer format is assumed to be fixed hence
         the column_no is hardcoded as 1 and 2 for transno and name */
      transition_no = (atol (wflow_data1[(wflow_buf1->columns * matched) + 1]));
      strcpy (transitionname, (wflow_data1[(wflow_buf1->columns * matched) + 2]));
/*
     WFinfo.acl = aclno1;
      break;
*/
         }
        }
      if (matched >= 0)
      break;
     }
  MEMclose (&wflow_buf1); 
  MEMclose (&wflow_buf2); 

/* Update the WF structure for NFM commands.. */
   if (matched >= 0)
    {
/*
     _PDMdebug (fn, "aclno1[%d], aclno2[%d], wfinfo.acl[%d]\n", 
                     aclno1, aclno2, WFinfo.acl);
*/
     WFinfo.transition = transition_no;
/*     WFinfo.item_no = itemno; */
     strcpy(WFinfo.transition_name,transitionname);
     strcpy (WFinfo.logon_s, logonsuccess);
     strcpy (WFinfo.logon_f, logonfailure);
     strcpy (WFinfo.notify, notify);
     }
    else
    { 
    _PDMdebug (fn, "user not authorised to perform this command\n");
    return(PDM_E_NOT_ACL_USER);
       }


_PDMdebug  (fn, "End of PDMitem_val_in_unmapped_cat  :\n\
Workflow Name = <%s>\n\
Project  Name = <%s>\n\
Table    Name = <%s>\n\
Item     Name = <%s>\n\
Item     Rev  = <%s>\n\
entity : <%s>\n\
transition_no : <%d> \n\
Transition_name : <%s>\n", 
 wf_name, proj_name, catalog_name, part_num, revision, 
  entity, transition_no, transitionname);
    PDMdebug("EXIT:PDMitem_val_in_unmapped_cat \n");
return (PDM_S_SUCCESS);
}


/* added to check NFM global variable */

_PDMprint_nfm_global ()
{
  char		s[2096];

s[0] = '\0';
  sprintf  (s,  "NFMuserid = %d, NFMuserno = %d, administrator = %d,\n\
  fs_debug_on= %d, default_wa_no = %d, load_item_file= %d \n",
  NFMglobal.NFMuserid, NFMglobal.NFMuserno, NFMglobal.administrator,
  NFMglobal.fs_debug_on, NFMglobal.default_wa_no, NFMglobal.load_item_file);

PDMdebug (s);

s[0] = '\0';
sprintf  (s,  "date_format [%s], time_format [%s], NFMversion [%s],\n\
  NFMusername [%s], NFMpasswd[%s], application [%s],\n\
  fs_debug_file[%s], NFMsch_name[%s], NFMsch_passwd[%s],\n\
  client_type [%s], environment_name [%s]\n",
  NFMglobal.date_format, NFMglobal.time_format, NFMglobal.NFMversion,
  NFMglobal.NFMusername, NFMglobal.NFMpasswd, NFMglobal.application,
  NFMglobal.fs_debug_file, NFMglobal.NFMsch_name, NFMglobal.NFMsch_passwd,
  NFMglobal.client_type, NFMglobal.environment_name);

PDMdebug (s);

}


int PDMadd_cmd (commandno, entity)
int		*commandno;
char		*entity;
{
  char		*fn = "PDMadd_cmd";
  MEMptr	wflow_buf1=NULL;
  MEMptr	wflow_buf2=NULL;
  char		**wflow_data1;
  char		**wflow_data2;
  int		max_cmd_no, max_trans_no;
  int		new_max_cmd_no, new_max_trans_no;
 
 _PDMdebug ("ENTER", "%s", fn);

 /* getting the last cmd no from command table */

   sprintf (sql_str,  "select max(n_commandno) from nfmcommands ");

   status = SQLquery(sql_str,&wflow_buf1,512);
   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf1);
     _PDMdebug (fn,  "SQLquery during PDMitem_val_in_unmapped_cat: status %d\n", status);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(wflow_buf1);
   if(status != MEM_S_SUCCESS) {
		MEMclose(&wflow_buf1);
		_PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on) {
       MEMprint_buffer("wflow_buf1 while getting max trans no ",
       wflow_buf1,PDM_DEBUG_FILE);
   }
  
   wflow_data1 = (char **)wflow_buf1->data_ptr;

   max_cmd_no = atol (wflow_data1[0]);
   new_max_cmd_no = ++max_cmd_no;
   MEMclose (&wflow_buf1); 

 /* getting the last trans  no from command table */

   sprintf (sql_str,  "select max(n_transitionno) from nfmtransitions");

   status = SQLquery(sql_str,&wflow_buf2,512);
   if (status != SQL_S_SUCCESS)
   {
     MEMclose(&wflow_buf2);
     _PDMdebug (fn,  
      "SQLquery during PDMitem_val_in_unmapped_cat: status %d\n", status);
     return(PDM_E_SQL_STMT);
   }

   status = MEMbuild_array(wflow_buf2);
   if(status != MEM_S_SUCCESS) {
		MEMclose(&wflow_buf2);
		_PDMdebug (fn, "%s %d \n", "MEMbuild_array ",status);
		return(PDM_E_BUILD_ARRAY);
   }
 if(PDMdebug_on) {
       MEMprint_buffer("wflow_buf2 getting max trans no ",
       wflow_buf2,PDM_DEBUG_FILE);
     }
  
   wflow_data2 = (char **)wflow_buf2->data_ptr;

   max_trans_no = atol (wflow_data2[0]);
   new_max_trans_no = ++max_trans_no;

   MEMclose(&wflow_buf2);
   
   /* Insert into NFMcommands */
   sprintf (sql_str,  
   "Insert into nfmcommands (n_commandno, n_commandname, n_application, n_transcommand, n_entity ) VALUES (%d,'PDMDelete Files For Part','PDM','N','I') ", 

   new_max_cmd_no);
   status = SQLstmt(sql_str);
   if (status != SQL_S_SUCCESS) {
   _PDMdebug (fn, "During nfmcmds insert: SQLstmt 0x%.8x\n");
   return (PDM_E_SQL_STMT);
    }

   
   /* Insert into NFMtransitions  */

   sprintf (sql_str,  "Insert into nfmtransitions \
(n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_workflowno, n_logonsuccess, n_logonfailure, n_notify ) \
VALUES (%d, 'Delete files from part', %d, 13, 1, 6, 'Y', 'Y', 'N') ",
   new_max_trans_no, new_max_cmd_no);
    status = SQLstmt(sql_str);
    if (status != SQL_S_SUCCESS) {
    _PDMdebug (fn, "During insert of delete in nfmtrans: SQLstmt 0x%.8x\n");
    return (PDM_E_SQL_STMT);
    }

   sprintf (sql_str,  
   "Insert into nfmtransitions (n_transitionno, n_transitionname, n_commandno, n_fromstate, n_tostate, n_workflowno, n_logonsuccess, n_logonfailure, n_notify ) VALUES (%d,'Delete files from part',%d,14,1,6, 'Y', 'Y', 'N')", 
   (new_max_trans_no +1), new_max_cmd_no);
    status = SQLstmt(sql_str);
    if (status != SQL_S_SUCCESS) {
    _PDMdebug (fn, "During insert of delete in nfmtrans: SQLstmt 0x%.8x\n");
    return (PDM_E_SQL_STMT);
    }

   /* Insert into NFMaccess  */

   sprintf (sql_str,  
   "Insert into nfmaccess (n_classno, n_transitionno ) VALUES (10, %d); ", 
   new_max_trans_no);
    status = SQLstmt(sql_str);
    if (status != SQL_S_SUCCESS) {
    _PDMdebug (fn, "During Insert #4: SQLstmt 0x%.8x\n");
    return (PDM_E_SQL_STMT);
    }

   sprintf (sql_str,  
   "Insert into nfmaccess (n_classno, n_transitionno ) VALUES (11, %d) ;", 
   new_max_trans_no);
    status = SQLstmt(sql_str);
    if (status != SQL_S_SUCCESS) {
    _PDMdebug (fn, "During Insert #5: SQLstmt 0x%.8x\n");
    return (PDM_E_SQL_STMT);
    }


   sprintf (sql_str,  
   "Insert into nfmaccess (n_classno, n_transitionno ) VALUES (10, %d); ", 
   (new_max_trans_no +1));
    status = SQLstmt(sql_str);
    if (status != SQL_S_SUCCESS) {
    _PDMdebug (fn, "During Insert #6: SQLstmt 0x%.8x\n");
    return (PDM_E_SQL_STMT);
    }


   sprintf (sql_str,  
   "Insert into nfmaccess (n_classno, n_transitionno ) VALUES (11, %d) ;", 
   (new_max_trans_no +1));
    status = SQLstmt(sql_str);
    if (status != SQL_S_SUCCESS) {
    _PDMdebug (fn, "During Insert #7: SQLstmt 0x%.8x\n");
    return (PDM_E_SQL_STMT);
    }

  *commandno = new_max_cmd_no;
  strcpy (entity, "I");
 _PDMdebug ("EXIT", "%s", fn);
 return (PDM_S_SUCCESS);
}



long PDMquery_make_transition (user_id, attr_list, data_list)
   long   user_id;
   MEMptr *attr_list, *data_list;
{
     char   *fn = "PDMquery_make_transition" ;
     long    status;
     MEMptr  list = NULL, list1 = NULL, list2 = NULL;
     char    **column, **format, **data;
     char    sql_str [2048], sql_str1 [2048];
     char    sql_str2 [2048], sql_str3 [2048];
     char    value [50];
     char    value1 [512];
     long    a, b, d, x, y, count, comma ;
     long    and1, and2;
     long _NFMcheck_item_condition_make_transition () ;
  
     _PDMdebug (fn, "ENTER\n") ;
     user_id = user_id ;
     strcpy (WFinfo.catalog_name, PDMexec->catalog);
     strcpy (WFinfo.item_name, PDMexec->part_num);
     strcpy (WFinfo.item_rev, PDMexec->revision);
     status = _NFMcheck_item_condition_make_transition (WFinfo.catalog_name,
							WFinfo.item_name, 
							WFinfo.item_rev) ;
     if (status != NFM_S_SUCCESS)
       {
	 _PDMdebug (fn, "Failure : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }

/* added to load WFinfo structure ... */
     status = _PDMload_wfinfo_for_make_transition (WFinfo.catalog_name,
							WFinfo.item_name, 
							WFinfo.item_rev) ;
     if (status != PDM_S_SUCCESS) {
        _PDMdebug (fn, 
          "PDMload_wfinfo_for_make_transition: Failure : status = <0x%.8x>\n",
		     status) ;
	 return (status) ;
       }

     status = NFMquery_table_definition (NFMglobal.NFMuserid,
					 "NFMSYSTEM", "NFMSTATES",
              &list);
     if (status != NFM_S_SUCCESS)
      {
        MEMclose (&list);
        _PDMdebug (fn, "Query Table Def : status = <0x%.8x>\n",
        status);
        return (status);
      }

     status = MEMbuild_array (list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
        status);
        return (NFM_E_MEM);
      }

     column = (char **) list -> column_ptr;
     format = (char **) list -> format_ptr;
     data   = (char **) list -> data_ptr;

     a = -1; b = -1; d = -1;

     for (y = 0; y < list -> columns; ++y)
      {
             if (! strcmp (column [y], "n_name"))        a = y;
        else if (! strcmp (column [y], "n_datatype"))    b = y;
        else if (! strcmp (column [y], "n_synonym"))     d = y;
      }

     sprintf (sql_str, "SELECT ");
     sprintf (sql_str1, " FROM %s, %s, %s, %s, %s WHERE ",
      "NFMSTATES", "NFMTRANSITIONS", "NFMACLUSERS", "NFMACCESS", "NFMCOMMANDS");
     sprintf (sql_str2, " FROM %s WHERE ", "NFMSTATES");

     comma = 0; and1 = 0; and2 = 0;

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        if (! strcmp (data [count + a], "n_stateno"))
         {
           if (comma) strcat (sql_str, ", ");
           comma = 1;

           if (and2) strcat (sql_str2, " AND ");
           and2 = 1;

           strcat (sql_str,  "DISTINCT (NFMSTATES.");

           strcat (sql_str,  data [count + a]);
           strcat (sql_str, ")");
           strcat (sql_str2, data [count + a]);
           strcat (sql_str2, " = ");
    
           sprintf (value, "%d", WFinfo.curr_state);

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str2, "'");
              strcat (sql_str2, value);
              strcat (sql_str2, "'");
            }
           else
              strcat (sql_str2, value);
         }
        else if (! strcmp (data [count + a], "n_statename"))
         {
           if (comma) strcat (sql_str, ", ");
           comma = 1;

           strcat (sql_str,  "NFMSTATES.");
           strcat (sql_str, data [count + a]);
         }
        else if (! strcmp (data [count + a], "n_transfrom"))
         {
           if (and2) strcat (sql_str2, " AND ");
           and2 = 1;

           strcat (sql_str2, data [count + a]);
           strcat (sql_str2, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str2, "'");
              strcat (sql_str2, "Y");
              strcat (sql_str2, "'");
            }
           else 
              strcat (sql_str2, "Y");
         }
        else if (! strcmp (data [count + a], "n_transto"))        
         {
           if (and1) strcat (sql_str1, " AND ");
           and1 = 1;

           strcat (sql_str1, "NFMSTATES.");
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, "Y");
              strcat (sql_str1, "'");
            }
           else 
              strcat (sql_str1, "Y");
         }
        else if (! strcmp (data [count + a], "n_workflowno"))        
         {
           if (and1) strcat (sql_str1, " AND ");
           and1 = 1;

           strcat (sql_str1, "NFMSTATES.");
           strcat (sql_str1, data [count + a]);
           strcat (sql_str1, " = ");

           sprintf (value, "%d", WFinfo.workflow);

           if (! strncmp (data [count + b], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, value);
              strcat (sql_str1, "'");
            }
           else 
              strcat (sql_str1, value);
         }
      }

     sprintf (sql_str3, "%s %s", sql_str, sql_str2);

     status = SQLquery (sql_str3, &list1, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (&list1);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
           status = NFM_E_USER_ACCESS_PRIV;
           ERRload_struct(NFM,status,"",NULL);
           _PDMdebug (fn, "Not Trans State : status = <0x%.8x>\n",
           status);
           return (status);           
         }

        _PDMdebug (fn, "SQL Query Syntax : status = <0x%.8x>\n",
        status);
        return (NFM_E_SQL_QUERY) ;
      }          

     if (comma) strcat (sql_str, ", ");
     strcat (sql_str,  "NFMTRANSITIONS.n_transitionname");
     _PDMdebug ("sql_str", "%s\n", sql_str);
     strcat (sql_str, sql_str1);
    
     _PDMdebug ("sql_str", "%s\n", sql_str);

     sprintf (sql_str1, " AND %s.%s = %d",
              "NFMACLUSERS", "n_userno", NFMglobal.NFMuserno);

     strcat (sql_str, sql_str1);
    
     sprintf (sql_str1, " AND %s.%s = %d",
              "NFMACLUSERS", "n_aclno", WFinfo.acl);

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, " AND %s.%s =", "NFMACCESS", "n_classno");

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, "%s.%s", "NFMACLUSERS", "n_classno");

     strcat (sql_str, sql_str1);
              
     sprintf (sql_str1, " AND %s.%s = %d",
              "NFMTRANSITIONS", "n_fromstate", WFinfo.curr_state);

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, " AND %s.%s =", "NFMTRANSITIONS", "n_transitionno");

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, "%s.%s", "NFMACCESS", "n_transitionno");

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, " AND %s.%s =", "NFMSTATES", "n_stateno");

     strcat (sql_str, sql_str1);

     sprintf (sql_str1, "%s.%s", "NFMTRANSITIONS", "n_tostate");

     strcat (sql_str, sql_str1);
/* added navair fix to get PDM related transitions only .. MaC 111792 */
     value1[0] = '\0';
     sprintf (value1,  " AND %s AND %s ",
     " NFMTRANSITIONS.n_commandno = NFMCOMMANDS.n_commandno ",
     " NFMCOMMANDS.n_application = 'PDM' ");

     strcat (sql_str, value1);

     _PDMdebug ("finally: sql_str", "%s\n", sql_str);
     status = SQLquery (sql_str, &list2, MEM_SIZE);
     if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);

        if ((status ) == SQL_I_NO_ROWS_FOUND)
         {
           status = NFM_E_USER_ACCESS_PRIV;
	   ERRload_struct (NFM, status, NULL) ;
           _PDMdebug (fn, "Not Trans State : status = <0x%.8x>\n",
           status);
           return (status);           
         }

        _PDMdebug (fn, "SQL Query Syntax : status = <0x%.8x>\n",
        status);
	   return(NFM_E_TO_MAKE_TRANS) ;
      }          


     status = MEMbuild_array (list2);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
        status);
        return (NFM_E_MEM);
      }


 if(PDMdebug_on) {
       MEMprint_buffer("list2 from sec qry", list2, PDM_DEBUG_FILE);
   }

     status = MEMopen (attr_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n",
		    status);
        return (NFM_E_MEM) ;
      }

 _PDMdebug (fn, "MEMopen attr_list returns <0x%.8x>\n", status);
     for (y = 0; y < list -> columns; ++y)
      {
        _PDMdebug (fn, "attr[%s], datatype[%s]\n", column [y], format [y]);
        status = MEMwrite_format (*attr_list, column [y], format [y]);
        if (status != MEM_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
           MEMclose (&list);
           MEMclose (&list1);
           MEMclose (&list2);
           MEMclose (attr_list);
           _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
           status);
           return (NFM_E_MEM);
         }
 _PDMdebug (fn, "MEMwrite_format attr_list returns <0x%.8x>\n", status);
      }

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        if ((! strcmp (data [count + a], "n_stateno"))   ||
            (! strcmp (data [count + a], "n_statename")))
         {
           sql_str [0] = '\0';

           for (y = 0; y < list -> columns; ++y)
            {
              strcat (sql_str, data [count + y]);
              strcat (sql_str, "\1");
            }

           status = MEMwrite (*attr_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              MEMclose (&list);
              MEMclose (&list1);
              MEMclose (&list2);
              MEMclose (attr_list);
              _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n",
              status);
              return (NFM_E_MEM);
            }
         }
      }
    _PDMdebug ("sql_str", "%s\n", sql_str);
sprintf (sql_str, "%s\1%s\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1", 
             "n_transitionname", "char(80)");

           status = MEMwrite (*attr_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              MEMclose (&list);
              MEMclose (&list1);
              MEMclose (&list2);
              MEMclose (attr_list);
              _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n",
              status);
              return (NFM_E_MEM);
            }

     for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;

        if (! strcmp (data [count + a], "n_stateno"))
         {
           sql_str [0] = '\0';

           for (y = 0; y < list -> columns; ++y)
            {
              if (y == a)
                strcat (sql_str, "n_status");
              else if (y == b)         
                strcat (sql_str, "char(15)");
              else if (y == d)         
                strcat (sql_str, "STATUS");
              else
                strcat (sql_str, data [count + y]);
              strcat (sql_str, "\1");
            }

           status = MEMwrite (*attr_list, sql_str);
           if (status != MEM_S_SUCCESS)
            {
	      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
              MEMclose (&list);
              MEMclose (&list1);
              MEMclose (&list2);
              MEMclose (attr_list);
              _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n",
              status);
              return (NFM_E_MEM);
            }
         }
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
        status);
        return (NFM_E_MEM);
      }

     status = MEMopen (data_list, MEM_SIZE);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n",
        status);
        return (NFM_E_MEM);
      }

     data = (char **) (*attr_list) -> data_ptr;

     for (x = 0; x < (*attr_list) -> rows; ++x) 
      {
        count = (*attr_list) -> columns * x;

        status = MEMwrite_format (*data_list, 
                 data [count + a], data [count + b]);
        if (status != MEM_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
           MEMclose (&list);
           MEMclose (&list1);
           MEMclose (&list2);
           MEMclose (attr_list);
           MEMclose (data_list);
           _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n",
           status);
           return (NFM_E_MEM);
         }
      }

     status = MEMbuild_array (list1);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
        status);
        return (NFM_E_MEM);
      }

     data = (char **) list1 -> data_ptr;

     sql_str [0] = '\0';

     for (y = 0; y < list1 -> columns; ++y) 
      {
        strcat (sql_str, data [y]);
        strcat (sql_str, "\1");
      }

     strcat (sql_str, "\1");
     strcat (sql_str, "CURRENT STATE");
     strcat (sql_str, "\1");

     status = MEMwrite (*data_list, sql_str);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n",
        status);
        return (NFM_E_MEM);
      }

     status = MEMbuild_array (*attr_list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
        status);
        return (NFM_E_MEM);
      }


 if(PDMdebug_on) {
       MEMprint_buffer("attr_list after cur_st", *attr_list, PDM_DEBUG_FILE);
       MEMprint_buffer("data_list after cur_st", *data_list, PDM_DEBUG_FILE);
   }

     status = MEMbuild_array (list2);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list);
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _PDMdebug (fn, "MEM Build Array : status = <0x%.8x>\n",
        status);
        return (NFM_E_MEM);
      }

     data = (char **) list2 -> data_ptr;

     for (x = 0; x < list2 -> rows; ++x)
      {
        count = list2 -> columns * x;
        sql_str [0] = '\0';

        for (y = 0; y < list2 -> columns; ++y) 
         {
           strcat (sql_str, data [count + y]);
           strcat (sql_str, "\1");
         }
        strcat (sql_str, "\1");

        status = MEMwrite (*data_list, sql_str);
        if (status != MEM_S_SUCCESS)
         {
	   ERRload_struct (NFM, NFM_E_MEM, "", "") ;
           MEMclose (&list);
           MEMclose (&list1);
           MEMclose (&list2);
           MEMclose (attr_list);
           MEMclose (data_list);
           _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n",
           status);
           return (NFM_E_MEM);
         }
      }

 if(PDMdebug_on) {
       MEMprint_buffer("data_list after cur_st", *data_list, PDM_DEBUG_FILE);
   }


     status = MEMclose (&list);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list1);
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _PDMdebug (fn, "MEM Close : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);
      }

     status = MEMclose (&list1);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (&list2);
        MEMclose (attr_list);
        MEMclose (data_list);
        _PDMdebug (fn, "MEM Close : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);
      }

     status = MEMclose (&list2);
     if (status != MEM_S_SUCCESS)
      {
	ERRload_struct (NFM, NFM_E_MEM, "", "") ;
        MEMclose (attr_list);
        MEMclose (data_list);
        _PDMdebug (fn, "MEM Close : status = <0x%.8x>\n", status);
        return (NFM_E_MEM);
      }

     _PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n", PDM_S_SUCCESS);
     return (PDM_S_SUCCESS);
}

int PDMsvalidate_user_access_cl (user_id,
                         command_name, wf_name, proj_name, catalog_name,
                         part_num, revision)
int	user_id;
char	*command_name, *wf_name, *proj_name;
char	*catalog_name, *part_num, *revision;
{
  char		*fn = "PDMsvalidate_user_access_cl";
  MEMptr	wf_buffer = NULL;
  char		sql_str[1023];
  long    buser_id;
  char    bproject[100];
  char    bcatalog[100];
  char    bpart_num[100];
  char    brevision[100];
  char    bdcatalog[100];
  char    bdrawing[100];
  char    bdrevision[100];
  _PDMdebug (fn, "ENTER\n");

  _PDMdebug (fn,"   user_id       = <%d>\n\
    Project    Name = <%s>\n\
    Workflow   Name = <%s>\n\
    Catalog    Name = <%s>\n\
    Part     Name = <%s>\n\
    Part     Rev  = <%s>\n", 
user_id, proj_name, wf_name, catalog_name, part_num, revision);
  
  /* backing up PDMexec struct */
     strcpy (bproject, PDMexec->project);
     strcpy (bcatalog, PDMexec->catalog);
     strcpy (bpart_num, PDMexec->part_num);
     strcpy (brevision, PDMexec->revision);
     strcpy (bdcatalog, PDMexec->dcatalog);
     strcpy (bdrawing, PDMexec->drawing);
     strcpy (bdrevision, PDMexec->drevision);
     buser_id = PDMexec->user_id;

  /* loading PDMexec struct */
     strcpy (PDMexec->project, proj_name);
     strcpy (PDMexec->catalog, catalog_name);
     strcpy (PDMexec->part_num, part_num);
     strcpy (PDMexec->revision, revision);
     PDMexec->user_id = user_id;

  status = MEMopen (&wf_buffer, MEM_SIZE);
  if (status != MEM_S_SUCCESS) {
     _PDMdebug (fn, "MEM Open : status = <0x%.8x>\n", status);
     return (NFM_E_MEM) ;
     }

  status = MEMwrite_format (wf_buffer, "command", "char(100)");
  if (status != MEM_S_SUCCESS) {
     MEMclose (&wf_buffer);
     _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
     return (NFM_E_MEM);
  }

  status = MEMwrite_format (wf_buffer, "workflow_name", "char(20)");
  if (status != MEM_S_SUCCESS) {
     MEMclose (&wf_buffer);
     _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
     return (NFM_E_MEM);
  }

  status = MEMwrite_format (wf_buffer, "project_name", "char(20)");
  if (status != MEM_S_SUCCESS) {
     MEMclose (&wf_buffer);
     _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
     return (NFM_E_MEM);
  }

  status = MEMwrite_format (wf_buffer, "table_name", "char(20)");
  if (status != MEM_S_SUCCESS) {
     MEMclose (&wf_buffer);
     _PDMdebug (fn, "MEM Wr Format : status = <0x%.8x>\n", status);
     return (NFM_E_MEM);
  }

  status = MEMbuild_array(wf_buffer);
  if(status != MEM_S_SUCCESS) {
    MEMclose(&wf_buffer);
    _PDMdebug (fn, "MEMbuild_array failed : status %d\n",status);
    return(PDM_E_BUILD_ARRAY);
    }
    
  sprintf (sql_str, "%s\1%s\1%s\1%s\1", command_name, wf_name, proj_name,
                                        catalog_name);
  status = MEMwrite (wf_buffer, sql_str);
  if (status != MEM_S_SUCCESS) {
      MEMclose (&wf_buffer);
      _PDMdebug (fn, "MEM Write : status = <0x%.8x>\n", status);
      return (NFM_E_MEM);
      }

  status = PDMsvalidate_user_access (wf_buffer);
  if (status != PDM_S_SUCCESS) {
      MEMclose (&wf_buffer);
      _PDMdebug (fn, "PDMsvalidate_user_access Failed : status = <0x%.8x>\n", 
                                                                    status);
      return (status);
      }

 MEMclose (&wf_buffer);

 /* restoring PDMexec struct */
     strcpy (PDMexec->project, bproject);
     strcpy (PDMexec->catalog, bcatalog);
     strcpy (PDMexec->part_num, bpart_num);
     strcpy (PDMexec->revision, brevision);
     PDMexec->user_id = user_id;
_PDMdebug (fn, "SUCCESSFUL : status = <0x%.8x>\n", PDM_S_SUCCESS);
return (PDM_S_SUCCESS);
}


int _PDMload_wfinfo_for_make_transition (catalog_name, part_num, revision) 
char	*catalog_name, *part_num, *revision;
{
  char		*fn = "_PDMload_wfinfo_for_make_transition";
  int    	workflowno;
  int    	aclno;
  int    	stateno;

  _PDMdebug (fn, "ENTER\n");

  _PDMdebug (fn," Catalog    Name = <%s>\n\
  Part     Name = <%s>\n\
  Part     Rev  = <%s>\n", 
  catalog_name, part_num, revision);

  status = PDMget_state_aclno (catalog_name, part_num, revision, 
                                                  &aclno, &stateno);
/*
  status = PDMload_part_info(catalog_name, part_num, revision);
*/
  if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
      return (status);
      }

  status = PDMget_workflowno (aclno, &workflowno);
  if (status != PDM_S_SUCCESS) {
      _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
      return (status);
      }

  WFinfo.curr_state = stateno;
  WFinfo.acl = aclno;
  WFinfo.workflow = workflowno;
/*
  strcpy (WFinfo.catalog_name, catalog_name);
  strcpy (WFinfo.item_name, part_num);
  strcpy (WFinfo.item_rev, revision);
*/
     
  _PDMdebug (fn, "stateno[%d], aclno[%d], workflowno[%d]\n\
 catalog[%s], itemname[%s], revision[%s]\n",
 WFinfo.curr_state, WFinfo.acl, WFinfo.workflow, WFinfo.catalog_name, 
 WFinfo.item_name, WFinfo.item_rev);

  _PDMdebug (fn, "EXIT\n");
 return (PDM_S_SUCCESS);
}
