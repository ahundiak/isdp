#include		<stdio.h>
#include 		<sys/types.h>
#include 		<sys/times.h>
#include 		"NFMstruct.h"
#include 		"MSGstruct.h"
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"PDUris_incl.h"
#include		"PDUstorage.h"
#include		"NFMschema.h"
#include		"NFMapi.h"
#include		"WFexterns.h"
#include		"PDMproto.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern PDMpart_ptr PDMpart;
extern PDMchild_ptr PDMchild;
extern char   glob_var[100];
extern PDMexec_ptr PDMexec;
static long     status;
static char     s[1024];
struct NFMwf_info  PDMwf_info;
extern struct PDUstorage *storage;
struct NFMoperation  *PDMoperation, *PDMlast_oper;
MEMptr	NFMmessage_buffer;
extern MSGptr NFMmsg_ptr;
extern struct NFMitem_info *NFMitem_ptr;
extern struct sto_area_info STO_info;
extern struct NFMglobal_st NFMglobal;



                                               

/*
 *       POST CHANGES TO DATABASE - Kumar 10/18/92
 * DESCRIPTION: save the changes of a checked out part
 * 
 * INPUT:
 * 
 * 
 * (2) child_bufr (4) sv_bufr (5) storage_buffer
 * (6) parm_buffer (7) data_buffers
 * 
 * file_bufr   (n_cofilename   char(40))
 * 
 * This buffer can be empty implying that, filename was given during creation.
 * 
 * child_bufr	 may/may not be empty
 * 
 * The format is as follows
 * 
 * p_catalogname		char(18) 
 * p_partnum			char(40)
 * p_revision			char(40)
 * p_orient                     char(240)
 * p_quantity			double 
 * p_history                    char(10)
 * p_childno			integer
 * p_usageid                    char(25)
 * p_viewid			char(25)
 * 
 * 
 * sv_bufr  may/may not be empty
 * 
 * p_origin     char(100) 
 * p_rotation   char(240) 
 * p_viewname	char(40)
 * 
 * OUTPUT:
 * 
 * RETURN CODES:
 * 
 * PDM_S_SUCCESS    on success
 * 
 * A. if child_bufr is empty
 * 
 * (a) either the part is being checked in first time without first level
 * children  or 
 * (b)	the part is reduced to an atomic part from an assembly
 * 
 * 
 * B. if child_bufr is not empty
 * 
 * (a) part was an atomic part and is now an assembly
 * (b) part was an assembly before In both the cases add the children 
 *     as secondary members
 */

int PDMpost_to_database
(
MEMptr          child_bufr,
MEMptr          sv_bufr,
MEMptr          parm_buffer,
MEMptr          data_buffers,
MEMptr          para_ass
)
{
        char		*fn= "PDMpost_to_database";
       long PDMload_lfm_for_updatedb ();
       char *msg = NULL;

	_PDMdebug(fn,"ENTER:\n");
       msg = (char *)PDUtranslate_message(PDM_E_UPDATING_MSG);
       strcpy(glob_var,msg);

	if (PDMdebug_on) {
		MEMprint_buffer("child_bufr", child_bufr, PDM_DEBUG_FILE);
		MEMprint_buffer("sv_bufr", sv_bufr, PDM_DEBUG_FILE);
		MEMprint_buffer("parm_buffer", parm_buffer, PDM_DEBUG_FILE);
	  	MEMprint_buffers("data_buffers", data_buffers, PDM_DEBUG_FILE);
	  	MEMprint_buffer("parametric assembly",para_ass, PDM_DEBUG_FILE);
		PDMprint_storage_area();
	}
        status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num,
                                PDMexec->revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
                return (status);
        }
        PDMupdate_dots ();
        if(!strcmp(PDMpart.n_status,""))
       {
        /* check if part exists */
        status = PDMload_catno(PDMexec->catalog);
        if (status != SQL_S_SUCCESS) {
                _PDMdebug (fn, "PDMload_catno failed status %d\n", status);
                return (status);
        }
/* NFM does this during NFMsave files MaC
 status = PDMload_lfm_for_updatedb (PDMexec->catalog, storage->storage_no, PDMpart.n_catalogno, PDMpart.n_itemno);
         if (status != PDM_S_SUCCESS)
         {
     _PDMdebug (fn, "PDMload_lfm_for_updatedb : status = <0x%.8x>\n", status);
           return (status);
         }
*/

       }
    PDMupdate_dots ();
     _PDMdebug(fn, "catno = %d, partno = %d, parttype = %s, n_status = %s\n",
                   PDMpart.n_catalogno, PDMpart.n_itemno, PDMpart.p_parttype,
                   PDMpart.n_status);
        if (PDMpart.n_cisano <= 0) {
        _PDMdebug (fn, "NO CHECKIN STORAGE AREA\n");
                return (PDM_E_NO_STO_LOC);
        }
      if(!strcmp(PDMpart.n_status, "I"))
         {
        _PDMdebug(fn, "PART IN: n_status is status -> %s\n", PDMpart.n_status);
                return(PDM_E_PART_CHECKEDIN);
         }
      if(!strcmp(PDMpart.n_status, "TI"))
         {
      _PDMdebug(fn, "IN TRANSFER:n_status is status -> %s\n", PDMpart.n_status);
                return(PDM_I_ON_TRANSFER);
         }
      if(!strcmp(PDMpart.n_status, "TO"))
         {
     _PDMdebug(fn, "OUT TRANSFER:n_status is status -> %s\n", PDMpart.n_status);
                return(PDM_I_ON_TRANSFER);
          }
      if (!strncmp(PDMpart.p_parttype, "N", 1) || !strncmp(PDMpart.p_parttype,
 "n", 1)) {
           _PDMdebug(fn, "p_parttype is set to non-graphic\n");
                        return (PDM_E_PART_NONGRAPHIC);
           }
      if (!strncmp(PDMpart.p_parttype, "P", 1) || !strncmp(PDMpart.p_parttype,
 "p", 1)) {
           _PDMdebug(fn, "p_parttype is set to non-graphic\n");
        return(PDM_E_CAN_NOT_CHECKIN_PARAMETRIC_PART);
           }
      if (!strncmp(PDMpart.n_archivestate, "A", 1))

          {
_PDMdebug(fn, "PART is ARCHIVED\n");
          return(PDM_E_PART_ARCHIVED);
           }
       if (!strncmp(PDMpart.n_itemlock, "Y", 1) || !strncmp(PDMpart.n_itemlock,
 "y", 1) ) {
             _PDMdebug(fn, "Part is locked\n");
              return (PDM_E_ITEM_LOCKED);
            }
        if ((!strncmp(PDMpart.n_pendingflag, "IA", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SA", 2)))
           {
                _PDMdebug (fn,  "Part is flagged for achive\n");
                return (PDM_E_PART_FLAGGED_FOR_ARCHIVE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IB", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SB", 2)))
           {
                _PDMdebug (fn,  "Part is flagged for backup\n");
                return (PDM_E_PART_FLAGGED_FOR_BACKUP);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "ID", 2))
         || (!strncmp(PDMpart.n_pendingflag, "SD", 2)))
           {
                _PDMdebug (fn,  "Part is flagged for delete\n");
                return (PDM_E_PART_FLAGGED_FOR_DELETE);
           }
        else if ((!strncmp(PDMpart.n_pendingflag, "IR", 2))
               || (!strncmp(PDMpart.n_pendingflag, "SR", 2)))
           {
                _PDMdebug (fn,  "Part is flagged for delete\n");
                return (PDM_E_PART_FLAGGED_FOR_RESTORE);
           }
        PDMupdate_dots ();
        if(sv_bufr != NULL)
       {
	status = MEMbuild_array(sv_bufr);
	if (status != MEM_S_SUCCESS) {
	_PDMdebug(fn, " %s %s %d \n", "PDMpost_to_database : MEMbuild_array ", 
			" failed status -> ", status);
		return (PDM_E_BUILD_ARRAY);
	 }
        }
	if (child_bufr != NULL)
        {
	  status = MEMbuild_array(child_bufr);
	  if (status != MEM_S_SUCCESS) {
		  _PDMdebug(fn, " %s %s %d", 
			  " \n PDM_checkin_part : MEMbuild_array ", 
			  " failed status -> ", status);
		  return (PDM_E_BUILD_ARRAY);
	  }
        }

        PDMupdate_dots ();
	/* being checked in as atomic part */
         if ((child_bufr == NULL) || (child_bufr->rows == 0))
          {
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
           if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
                    !strncmp(PDMpart.n_setindicator, "y", 1))
*/
           if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
               !strncmp(PDMpart.n_setindicator, "y", 1) ||
               !strncmp(PDMpart.n_setindicator, "A", 1) ||
               !strncmp(PDMpart.n_setindicator, "a", 1))
                  { /* was assembly before */
                       status = PDMdelete_bom();
                        if (status != PDM_S_SUCCESS &&
                            status != PDM_E_BOM_NOT_FOUND) {
                                sprintf(s, "%s %d\n",
                                    "PDMdelete_bom failed status ", status);
                                PDMdebug(s);
                        }
			
	status = PDMsave_part_case1( PDMexec->user_id, PDMexec->catalog, 
                        PDMexec->part_num, PDMexec->revision,                                           PDMpart.n_itemno,  parm_buffer, sv_bufr);
			if (status != PDM_S_SUCCESS) 
                        {
		_PDMdebug(fn, "PDMsave_part_case1 failed status %d\n", status);
				return (status);
			}
		} else {	/* was atomic before */
		status = PDMsave_part_case2( PDMexec->user_id, 
					   PDMexec->catalog, 
					   PDMexec->part_num, 
					   PDMexec->revision, 
					   PDMpart.n_itemno, 
		   			   sv_bufr);
			if (status != PDM_S_SUCCESS) {
			_PDMdebug(fn, "PDMsave_part_case2 failed status %d\n", 
					status);
				return (status);
			}
		}

	}
	/* being checked in as assembly */
	else if (child_bufr->rows > 0) 
         {
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
	if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
            !strncmp(PDMpart.n_setindicator, "y", 1))
*/
	if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
            !strncmp(PDMpart.n_setindicator, "y", 1) ||
            !strncmp(PDMpart.n_setindicator, "A", 1) ||
            !strncmp(PDMpart.n_setindicator, "a", 1))
            {	/* part was an assembly before */
			status = PDMsave_part_case3( PDMexec->user_id, 
						   PDMexec->catalog, 
						   PDMexec->part_num, 
						   PDMexec->revision, 
						   PDMpart.n_itemno, 
						   child_bufr, 
						   sv_bufr, 
                       parm_buffer, data_buffers, para_ass);
			if (status != PDM_S_SUCCESS) {
			_PDMdebug(fn, "PDMsave_part_case3 failed status %d\n", 
					status);
				return (status);
			}
		} else 
                  {	/* part was atomic before */
		status = PDMsave_part_case4(PDMexec->user_id, 
					  PDMexec->catalog, 
					  PDMexec->part_num, 
					  PDMexec->revision, 
					  PDMpart.n_itemno, 
					  child_bufr, 
					  sv_bufr, 
	                      parm_buffer, data_buffers, para_ass);
			if (status != PDM_S_SUCCESS) {
			_PDMdebug(fn, "PDMsave_part_case4 failed status %d\n", 
					status);
				return (status);
			}
		}

	}

	/* set the p_parttype to "G" */

	if (status == PDM_S_SUCCESS) {
          if(strcmp(PDMpart.p_parttype,"M"))
               {
	status = PDMset_parttype(PDMexec->catalog, PDMexec->part_num, 
				 PDMexec->revision, "G");
	if (status != PDM_S_SUCCESS) 
		_PDMdebug(fn, "PDMset_parttype failed status = %d \n", status);
               }
	}
	_PDMdebug(fn,"EXIT:\n");
      PDMupdate_dots();
      PDMreset_dots();
        return(PDM_S_SUCCESS);
}

/*
 * Handles the case where the part is being checked in for the first time
 * without children or the case where an assembly has been reduced to an
 * atomic part.
 * 
 * In case 1 the saved views need to be stored.
 * 
 * In the 2 nd case :
 * 
 * (a) There is a possibility of having attachments from BOM since it could have
 * been generated when the part was an assembly. (b) saved views may exist
 * (c) Old cit info needs to be deleted
 */


/*
 * Part was assembly and is being checked in as atomic part
 */

PDMsave_part_case1
(
	long            uid,
	char           *cat,
	char           *part,
	char           *rev,
	int             pno,
	MEMptr          parm_buffer,
	MEMptr          sv_bufr
)
{
char		*fn= "PDMsave_part_case1";
char          **parm_data;
char            pdmsv_table[100];
int             sts, n_sano;


	_PDMdebug(fn,"ENTER:\n");
	parm_data = (char **) parm_buffer->data_ptr;
	sprintf(pdmsv_table, "v_%s", cat);

        n_sano = storage->storage_no;

	/* Turn off AUTO-COMMIT */

	status = PDMstop_transaction(0);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug(fn, "PDMstop_transaction failed status %d\n", status);
                status = PDM_E_BUILD_ARRAY;
                goto wrapup;
	}
	/*
	 * Since it is an assembly delete all the set members. Delete the
	 * attrbs both in nfmcit and pdmcit and entries in pdc_xxx. Also
	 * delete pdmswsfiles and pdmfmgr entries
	 */

/* Is this necessary? .. MaC 011994...
	status = SQLstmt("LOCK TABLES pdmcit IN EXCLUSIVE MODE");
        if (status != SQL_S_SUCCESS) {
              _PDMdebug(fn,  "LOCK pdmcit SQLstmt failed status %d\n",  status);
                status = PDM_E_LOCK_CIT;
                goto wrapup;
        }
*/
	
	status = PDMdron_setindicator(PDMpart.n_catalogno,PDMpart.n_itemno);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug(fn, " %s %d \n", 
			"PDMdelete_set_members failed status -> = %d ", status);
		goto wrapup;

	}
        PDMupdate_dots();
	status = PDMstart_transaction(0);
	if (status != PDM_S_SUCCESS) {
          _PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
		goto wrapup;
	}
        /*  Needed in NFM3.0.0  */
	status = NFMconvert_to_item(uid, cat, part, rev);
	if (status != NFM_S_SUCCESS) {
        _PDMdebug(fn, "NFMconvert_to_item failed status %d\n", status);
      		goto wrapup;
	}
	/* if there are any views delete old views and add the new ones
	 */

	if (sv_bufr != NULL && sv_bufr->rows > 0) {
	status = PDMinsert_views(pdmsv_table, pno, sv_bufr);
	if(status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMinsert_views failed status %d\n", status);
			goto wrapup;
		}
	}
	/* New 3.0 NFMcheckin */
       
        PDMupdate_dots();
	status = NFMsave_item_files (cat, part, rev );
	if (status != NFM_S_SUCCESS)
         {
	_PDMdebug (fn, " %s %s %d", "NFMsave_item_files ", 
			" failed status -> ", status);
     if(status == NFM_E_CI_FILENAME_EXISTS) status = PDM_E_CI_FILENAME_EXISTS;
		goto wrapup;
	  }
        PDMupdate_dots();
	status = PDMstop_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
		goto wrapup;
	}
	status = PDMstart_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
	goto wrapup;
	}
	_PDMdebug(fn,"EXIT:PDMsave_part_case1\n");
	return (PDM_S_SUCCESS);

wrapup:

	sts = PDMrollback_transaction(0);
	if (sts != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMrollback_transaction failed status %d\n", status);
	}
	return (status);
}

/* Part was atomic and is being checked in as atomic part */

PDMsave_part_case2
(
long            uid,
char           *cat,
char           *part,
char           *rev,
int             pno,
MEMptr          sv_bufr
)
{
        char		*fn= "PDMsave_part_case2";
	char            pdmsv_table[100], sql_str[100];
	int             sts, n_sano;

	_PDMdebug(fn,"ENTER:\n");

/* ANSI */
uid = 0;

	sprintf(pdmsv_table, "v_%s", cat);

        n_sano = storage->storage_no;

	/* Turn off AUTO-COMMIT */

	status = PDMstop_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstop_transaction failed status %d\n", status);
	goto wrapup;
	}

	/*
	 * if there are any views delete old views and add the new ones
	 */

	if (sv_bufr != NULL && sv_bufr->rows > 0 )
        {
	status = PDMinsert_views(pdmsv_table, pno, sv_bufr);
	if (status != PDM_S_SUCCESS) 
          {
	_PDMdebug(fn, "PDMinsert_views failed status %d\n", status);
	goto wrapup;
	   }
	}
            PDMupdate_dots();
	status = PDMstart_transaction(0);
	if (status != PDM_S_SUCCESS) 
        {
	_PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
	goto wrapup;
	}
  
	/* New 3.0 NFMcheckin */
sprintf (s, "cat = %s, catno = %d, part = %s, rev = %s, storage->storage_name = %s \n",cat, PDMpart.n_catalogno, part, rev, storage->storage_name);
PDMdebug (s);
       
     sprintf(sql_str, "UPDATE %s set n_status = 'O' WHERE n_itemname = '%s' and n_itemrev = '%s' ", cat,  part, rev);
        status = SQLstmt(sql_str);
        if (status != SQL_S_SUCCESS) {
                _PDMdebug(fn, "SQLstmt failed status %d\n", status);
        }
        sprintf(sql_str, "UPDATE f_%s set n_couser = '%s', n_cosano = %d WHERE n_itemnum = %d ",cat, NFMglobal.NFMusername,n_sano,PDMpart.n_itemno);
        status = SQLstmt(sql_str);
        if (status != SQL_S_SUCCESS) {
                _PDMdebug(fn, "SQLstmt failed status %d\n", status);
        }
            PDMupdate_dots();
	status = NFMsave_item_files (cat, part, rev );
	if (status != NFM_S_SUCCESS) 
         {
	_PDMdebug(fn, " %s %s %d", "NFMsave_item_files ", 
			" failed status -> ", status);
		goto wrapup;
	}
            PDMupdate_dots();
        /*
     sprintf(sql_str, "UPDATE %s set n_status = '%s' WHERE n_itemname = '%s' and n_itemrev = '%s' ", cat, PDMpart.n_status, part, rev);
        status = SQLstmt(sql_str);
        if (status != SQL_S_SUCCESS) {
                _PDMdebug(fn, "SQLstmt failed status %d\n", status);
        }
        */
	status = PDMstop_transaction(0);
	if (status != PDM_S_SUCCESS) 
        {
	_PDMdebug(fn, "PDMstop_transaction failed status %d\n", status);
	goto wrapup;
        }
	/* commit work */

	status = PDMstart_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
          goto wrapup;
	}
	_PDMdebug(fn,"EXIT:\n");
	return (PDM_S_SUCCESS);

wrapup:

	sts = PDMrollback_transaction(0);
	if (sts != PDM_S_SUCCESS) 
	_PDMdebug(fn, "PDMrollback_transaction failed status %d\n", status);
	return (status);
}

/*
 * assembly -> assembly
 * 
 * find catalog and part nos find assembly indicator find saved views table name
 * Update set members with child buffer old_set contains old set set_data
 * contains new p_citnos need these bufrs to restore in case of error Prepare
 * and complete set checkin load n_cofilename if given insert cit info
 * (delete old info and add new ones) insert saved views info
 */

int PDMsave_part_case3
(
long            user_id,
char           *catalog,
char           *p_partnum,
char           *p_revision,
int             p_partno,
MEMptr          child_bufr,
MEMptr          sv_bufr,
MEMptr          parm_buffer,
MEMptr          data_buffers,
MEMptr          para_ass
)
{
	char           *fn= "PDMsave_part_case3";
	int             n1, sts, n_sano;
	char            pdmsv_table[40];
        char            sql_str[250];
	MEMptr          old_set = NULL;
	MEMptr          new_set = NULL;
/*
	MEMptr          attr_bufr = NULL;
	MEMptr          data_bufr = NULL;
*/
	MEMptr          param_ass_data = NULL;
	MEMptr          citno = NULL;


	_PDMdebug(fn,"ENTER: PDMsave_part_case3:\n");

/* ANSI */
user_id = 0;

	n1 = -1;
        n_sano = storage->storage_no;
	/* find saved views table name */
	pdmsv_table[0] = '\0';
	sprintf(pdmsv_table, "v_%s", catalog);
	/* Turn off AUTO COMMIT */
	status = PDMstop_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstop_transaction failed status %d\n", status);
		return (status);
	}
/* Is this necessary? MaC 11/29/93 ...
        status = SQLstmt("LOCK TABLES pdmcit IN EXCLUSIVE MODE");
        if (status != SQL_S_SUCCESS) {
         _PDMdebug(fn,  "LOCK pdmcit SQLstmt failed status %d\n",  status);
         return (PDM_E_LOCK_CIT);
        }
*/

            PDMupdate_dots();
        /* Changed call parameters... MaC 112993
        status = PDMupdate_set_members(user_id, catalog, p_partnum, 
                          p_revision, child_bufr, &old_set,&new_set, &citno,
                          PDMpart.n_catalogno,PDMpart.n_itemno);
         */
        status = PDMupdate_set_members(catalog, p_partnum, p_revision,
                          PDMpart.n_catalogno,PDMpart.n_itemno,
                        child_bufr, &citno, &new_set);

	if (status != PDM_S_SUCCESS) 
         {
	_PDMdebug(fn, "%s %d \n", "PDMupdate_set_members ", status);
	goto wrapup;
	}

            PDMupdate_dots();
	/* insert cit info. delete old entries and add new entries */

     /* changed data_bufr to data_buffers MaC 112993 ...
	status = PDMXXinsert_citinfo( PDMpart.n_catalogno,PDMpart.n_itemno, child_bufr, parm_buffer, data_bufr, new_set,citno,"Y"); */

	status = PDMinsert_citinfo ( PDMpart.n_catalogno,
                                       PDMpart.n_itemno, 
                                       new_set,
                                       parm_buffer, 
                                       data_buffers, 
                                       citno,"Y");
	if (status != PDM_S_SUCCESS) {
	MEMclose(&old_set);
	MEMclose(&new_set);
	_PDMdebug(fn, " %s %s %d\n", 
			"PDMinsert_citinfo ", " failed status -> ", status);
	goto wrapup;
	}
            PDMupdate_dots();
         if( para_ass != NULL && para_ass->rows > 0)
        {
        /* Parameters mismatch
          status = PDMdefine_parametric_assembly(para_ass); */
        status = PDMdefine_parametric_assembly(para_ass, param_ass_data); 
	if (status != PDM_S_SUCCESS && status == SQL_I_NO_ROWS_FOUND) 
         {
	_PDMdebug(fn, "%s %d \n", "PDMdefine_parametric_assembly", status);
	goto wrapup;
	}
         }
	/* insert views */

            PDMupdate_dots();
        if(sv_bufr != NULL && sv_bufr->rows > 0)
        {
	status = PDMinsert_views(pdmsv_table, p_partno, sv_bufr);
	if (status != PDM_S_SUCCESS) {
	MEMclose(&new_set);
	MEMclose(&old_set);
	_PDMdebug(fn, " %s %s %d\n", 
			" PDMinsert_views ", "failed status -> ", status);
	goto wrapup;
	}
        }
            PDMupdate_dots();
	sprintf(sql_str, "UPDATE %s set n_status = 'O' WHERE n_itemname = '%s' and n_itemrev = '%s' ", catalog,  p_partnum, p_revision);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
	}
	sprintf(sql_str, "UPDATE f_%s set n_couser = '%s',n_cosano = %d WHERE n_itemnum = %d ",catalog, NFMglobal.NFMusername,n_sano,p_partno);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
	}
	status = PDMstart_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
	MEMclose(&old_set);
	MEMclose(&new_set);
	goto wrapup;
	}
	MEMclose(&old_set);
	MEMclose(&new_set);

            PDMupdate_dots();
	status = NFMsave_item_files (catalog, p_partnum, p_revision );
	if (status != NFM_S_SUCCESS) {
	MEMclose(&old_set);
	MEMclose(&new_set);
	_PDMdebug(fn, " %s %s %d\n", 
		   " NFMsave_item_files", "failed status -> ", status);
	if (status == NFM_E_ITEM_IN)
         {
         status = PDM_E_PART_CHECKEDIN;
	 PDMdebug("Part in checked-in status\n");
	  }
	else if (status == NFM_E_ITEM_OUT) {
	status = PDM_E_NOTCHECK_OUT;
	PDMdebug("Part not checked out\n");
          } else if (status == NFM_E_NOT_CO_USER) {
          status = PDM_E_NOT_CO_USER;
            PDMdebug("User not checked-out user\n");
	     }
            else if (status == NFM_E_ITEM_OUT) {
		status = PDM_E_ITEM_TOBE_CHECK;
		PDMdebug("Parts have to checked in before assembly\n");
		}
                 else if (status == NFM_E_SET_OUT) {
		status = PDM_E_SUB_TOBE_CHECK;
		PDMdebug("Subassembly to be checked first\n");
		} 
                 else {
		PDMdebug("NFMerror\n");
		  }
		goto wrapup;
	}
	sprintf(sql_str, "UPDATE %s set n_status = 'S' WHERE n_itemname = '%s' and n_itemrev = '%s' ", catalog,  p_partnum, p_revision);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
	}
	status = PDMstop_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstop_transaction failed status %d\n", status);
		goto wrapup;
	}
            PDMupdate_dots();
        /* commit work */
	status = PDMstart_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
	goto wrapup;
	}
/*
	MEMclose(&attr_bufr);
	MEMclose(&data_bufr);
*/
	_PDMdebug(fn,"EXIT: PDMsave_part_case3:\n");
	return (PDM_S_SUCCESS);

wrapup:

	sts = PDMrollback_transaction(0);
	if (sts != PDM_S_SUCCESS) 
	_PDMdebug(fn, "PDMrollback_transaction failed status %d\n", status);
	sprintf(sql_str, "UPDATE %s set n_status = 'S' WHERE n_itemname = '%s' and n_itemrev = '%s' ", catalog,  p_partnum, p_revision);
	sts = SQLstmt(sql_str);
	if (sts != SQL_S_SUCCESS)
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
      /*
	sprintf(sql_str, "UPDATE f_%s set n_couser = '', n_cosano = '' WHERE n_itemnum = %d ",catalog,PDMpart.n_itemno);
	sts = SQLstmt(sql_str);
	if (sts != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
	}
        */
	return (status);
}

/* atom -> assembly  */

int PDMsave_part_case4
(
long            user_id,
char           *catalog,
char           *p_partnum,
char           *p_revision,
int             p_partno,
MEMptr          child_bufr,
MEMptr          sv_bufr,
MEMptr          parm_buffer,
MEMptr          data_buffers,
MEMptr          para_ass
)
{
char		*fn= "PDMsave_part_case4";
int             n1, n2, n3;
int             sts,n_sano;
char            pdmsv_table[40];
char          **level_data;
MEMptr          old_set = NULL;
MEMptr          new_set = NULL;
MEMptr          level_bufr = NULL;
MEMptr          citno = NULL;
MEMptr          param_ass_data = NULL;
char            sql_str[1024];
int             level;

_PDMdebug(fn,"ENTER: PDMsave_part_case4:\n");

/* ANSI */

	n1 = -1; n2 = -1; n3 = -1;
        n_sano = storage->storage_no;

	/* find saved views table name */

	pdmsv_table[0] = '\0';
	sprintf(pdmsv_table, "v_%s", catalog);

	status = NFMconvert_to_set(user_id, catalog, 
				   p_partnum, p_revision);
	if (status != NFM_S_SUCCESS) {
	_PDMdebug(fn, " %s %s %d \n", 
		" NFMconvert_to_set ", " failed status -> ", status);
		goto wrapup;
	}
            PDMupdate_dots();
	status = PDMstop_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstop_transaction failed status %d\n", status);
	return (status);
	}
	
/* Is this necessary ? MaC 112993 ..
        status = SQLstmt("LOCK TABLES pdmcit IN EXCLUSIVE MODE");
        if (status != SQL_S_SUCCESS) {
         _PDMdebug(fn,  "LOCK pdmcit SQLstmt failed status %d\n",  status);
        return (PDM_E_LOCK_CIT);
	}	
 */
         if( para_ass != NULL && para_ass->rows > 0)
        {
        /* Parameters mismatch
          status = PDMdefine_parametric_assembly(para_ass); */
        status = PDMdefine_parametric_assembly(para_ass, param_ass_data); 
	if (status != PDM_S_SUCCESS && status == SQL_I_NO_ROWS_FOUND) 
         {
	_PDMdebug(fn, "%s %d \n", "PDMdefine_parametric_assembly", status);
	goto wrapup;
	}
         }

            PDMupdate_dots();
        /* Changed call parameters... MaC 112993
       status = PDMupdate_set_members(user_id, catalog, p_partnum,
                          p_revision, child_bufr, &old_set, &new_set,&citno,
                                PDMpart.n_catalogno,PDMpart.n_itemno);
         */
        status = PDMupdate_set_members(catalog, p_partnum, p_revision,
                          PDMpart.n_catalogno,PDMpart.n_itemno,
                        child_bufr, &citno, &new_set);

        if (status != PDM_S_SUCCESS) {
        _PDMdebug(fn, "%s %d \n", "PDMupdate_set_members ", status);
        goto wrapup;
        }
            PDMupdate_dots();
 status = PDMinsert_citinfo ( PDMpart.n_catalogno,
                                       PDMpart.n_itemno,
                                       new_set,
                                       parm_buffer,
                                       data_buffers,
                                       citno,"Y");
    
  /*        status = PDMXXinsert_citinfo( PDMpart.n_catalogno,PDMpart.n_itemno,child_bufr, parm_buffer, data_buffers, new_set,citno,"Y"); */
        if (status != PDM_S_SUCCESS) {
        MEMclose(&old_set);
        MEMclose(&new_set);
        _PDMdebug(fn, " %s %s %d\n", "  PDMinsert_citinfo ",
                        " failed status -> ", status);
        goto wrapup;
        }
        
            PDMupdate_dots();
	/* insert views */

        if(sv_bufr != NULL && sv_bufr->rows > 0)
        {
	status = PDMinsert_views(pdmsv_table, p_partno, sv_bufr);
	if (status != PDM_S_SUCCESS) {
	MEMclose(&new_set);
	MEMclose(&old_set);
	_PDMdebug(fn, " %s %s %d\n", 
		" PDMinsert_views ", " failed status -> ", status);
		goto wrapup;
	}
        }

            PDMupdate_dots();
	sprintf(sql_str, "UPDATE %s set n_status = 'O' WHERE n_itemname = '%s' and n_itemrev = '%s' ", catalog,  p_partnum, p_revision);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
	}
	sprintf(sql_str, "UPDATE f_%s set n_couser = '%s', n_cosano = %d WHERE n_itemnum = %d ",catalog, NFMglobal.NFMusername,n_sano,PDMpart.n_itemno);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
	}
	status = PDMstart_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
		return (status);
	}
	
	sprintf(sql_str, "%s %s  %s '%s' %s '%s'", 
		"SELECT p_maxlevel FROM ", catalog, 
		"WHERE n_itemname = ", p_partnum, 
		"AND n_itemrev = ", p_revision);
	status = SQLquery(sql_str, &level_bufr, 512);
	if (status != SQL_S_SUCCESS) {
		MEMclose(&level_bufr);
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
		
	}
	if (status == SQL_I_NO_ROWS_FOUND)
		level = 50;
	else {
		status = MEMbuild_array(level_bufr);
		if (status != MEM_S_SUCCESS) {
		MEMclose(&level_bufr);
		_PDMdebug(fn, "%s %d \n", "MEMbuild_array ", status);
		status = PDM_E_BUILD_ARRAY;
		goto wrapup;
		}
		level_data = (char **) level_bufr->data_ptr;
		level = atol(level_data[0]);
		if (level == 0)
			level = 50;
	}
            PDMupdate_dots();
		MEMclose(&level_bufr);
	sprintf(sql_str, "%s %s %s %d %s '%s' %s '%s'", 
		"UPDATE ", catalog, "SET n_colevel = ", level, 
		"WHERE n_itemname = ", p_partnum, 
		"AND n_itemrev = ", p_revision);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
		return (PDM_E_SQL_STMT);
	}

	sprintf(sql_str, "UPDATE %s set n_status = 'O' WHERE n_itemname = '%s' and n_itemrev = '%s' ", catalog,  p_partnum, p_revision);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
	}

	status = PDMstop_transaction(0);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
	goto wrapup;
	}
            PDMupdate_dots();
	status = NFMsave_item_files (catalog, p_partnum, p_revision );
	if (status != NFM_S_SUCCESS) {
          _PDMdebug(fn, "NFMsave_item_files failed status -> 0x%.8x\n", status);
	  if (status == NFM_E_ITEM_IN) {
	    status = PDM_E_PART_CHECKEDIN;
	    PDMdebug("Part in checked-in status\n");
             }
         else if (status == NFM_E_ITEM_OUT) {
	    status = PDM_E_NOTCHECK_OUT;
            PDMdebug("Part not checked out\n");
	    } 
         else if (status == NFM_E_NOT_CO_USER) {
	      status = PDM_E_NOT_CO_USER;
	      PDMdebug("User not checked-out user\n");
              } 
          else {
	      PDMdebug("NFMerror\n");
	        }
		goto wrapup;
	}

/*
	sprintf(sql_str, 
  "UPDATE %s set n_status = 'S' WHERE n_itemname = '%s' and n_itemrev = '%s' ", 
              catalog,  p_partnum, p_revision);
*/

	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
	}

        /* commit work */

        status = PDMstart_transaction(0);
        if (status != PDM_S_SUCCESS) {
         _PDMdebug(fn, "PDMstart_transaction failed status %d\n", status);
         goto wrapup;
        }
            PDMupdate_dots();
	status = PDMset_n_setindicator (catalog, p_partnum, p_revision, "Y");
	if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMset_n_setindicator  failed status %d\n", status);
        goto wrapup;
	}
            PDMupdate_dots();
	_PDMdebug(fn,"EXIT: PDMsave_part_case4:\n");
	return (PDM_S_SUCCESS);

wrapup:

	sts = PDMrollback_transaction(0);
	if (sts != PDM_S_SUCCESS) 
	_PDMdebug(fn, "PDMrollback_transaction failed status %d\n", status);
	sprintf(sql_str, "UPDATE %s set n_status = 'O' WHERE n_itemname = '%s' and n_itemrev = '%s' ", catalog,  p_partnum, p_revision);
	status = SQLstmt(sql_str);
	if (sts != SQL_S_SUCCESS)
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
        /*
	sprintf(sql_str, "UPDATE f_%s set n_couser = '', n_cosano = '' WHERE n_itemnum = %d ",catalog,PDMpart.n_itemno);
	status = SQLstmt(sql_str);
	if (sts != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SQLstmt failed status %d\n", status);
	}
        */
	status = NFMconvert_to_item(user_id, catalog, p_partnum, p_revision);
	return (status);
}

long PDMload_lfm_for_updatedb (n_catalogname, n_sano, n_catalogno, n_itemno)
char *n_catalogname;
int n_sano;
int n_catalogno;
int n_itemno;
{
  char  sql_str[1024];
  static char    *fn="PDMload_lfm_for_updatedb";
 char    **data;
 MEMptr bufr = NULL;

   _PDMdebug(fn, "ENTER ..\n");
   sql_str[0] = '\0';

sprintf(sql_str, "select n_co, n_copy, n_fileversion, n_ref, n_filename, n_filenum from nfmsafiles where n_sano = %d  and n_catalogno = %d and n_itemno = %d ", n_sano, n_catalogno, n_itemno );

        status = SQLquery(sql_str, &bufr, 512);
           if(status == SQL_S_SUCCESS)
            {
               MEMclose(&bufr);
              _PDMdebug(fn, " No need to update local filemanager\n");
              _PDMdebug(fn, "EXIT ..\n");
               return(PDM_S_SUCCESS);
            }
         if(status != SQL_I_NO_ROWS_FOUND) {
           MEMclose(&bufr);
            status = _PDMget_db_error (status);
            return (status);
              }
           MEMclose(&bufr);

  sql_str[0] = '\0';
  sprintf (sql_str,
  "SELECT n_cosano, n_cofilename, n_filenum, n_fileversion, n_cisano\
       FROM f_%s WHERE n_itemnum = %d AND n_fileversion = \
       ( SELECT MAX(n_fileversion) FROM f_%s WHERE n_itemnum = %d )",
       n_catalogname, n_itemno, n_catalogname, n_itemno);

    _PDMdebug ("sql_qry", "\n%s\n",sql_str);

       status = SQLquery (sql_str, &bufr, 512);
         if ( status != SQL_S_SUCCESS ) {
              MEMclose (&bufr);
              _PDMdebug  (fn, "SQLquery Failed %d\n", status) ;
    status = _PDMget_db_error (status);
              return (status);
             }
             status = MEMbuild_array(bufr);
             if(status != MEM_S_SUCCESS) {
                 MEMclose (&bufr);
                _PDMdebug(fn,"MEMbuild_array failed status %d\n",status);
                return(PDM_E_BUILD_ARRAY);
             }
         data = (char **) bufr->data_ptr;
  sql_str[0] = '\0';
sprintf(sql_str, "DELETE FROM NFMSAFILES WHERE n_sano = %d and n_catalogno = %d and n_itemno = %d and n_filenum = %s and  n_fileversion = 0", n_sano,n_catalogno,n_itemno, data[2]);
     status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS 
/* Added to support first time update MaC 041594 */
           && status != SQL_I_NO_ROWS_FOUND) {
        _PDMdebug (fn, "SQLstmt %d\n", status);
          status = _PDMget_db_error (status);
          return (status);
         }
  sql_str[0] = '\0';
sprintf(sql_str, "INSERT INTO NFMSAFILES (n_sano,n_filename,n_catalogno, n_itemno,n_filenum, n_fileversion,n_ref,n_co, n_copy, n_cisano)  VALUES(%d,'%s',%d,%d,%s,%s,0,'Y', 'N', %d)", n_sano,data[1],n_catalogno,n_itemno, data[2], data[3],data[4]);
     status = SQLstmt (sql_str);
       if (status != SQL_S_SUCCESS) {
        _PDMdebug (fn, "SQLstmt %d\n", status);
          status = _PDMget_db_error (status);
          return (status);
         }

       MEMclose(&bufr);
       _PDMdebug(fn, "Exit\n");
      return(PDM_S_SUCCESS);
}
