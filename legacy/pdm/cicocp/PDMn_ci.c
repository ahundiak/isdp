#include		<stdio.h>
#include 		<sys/types.h>
#include 		<sys/times.h>
#include 		"NFMstruct.h"
#include 		"MSGstruct.h"
#include 		"ERR.h"
#include		"PDUerror.h"
#include		"MEMstruct.h"
#include		"MEMerrordef.h"
#include		"NFMerrordef.h"
#include		"SQLerrordef.h"
#include		"NFMfile.h"
#include		"PDUstorage.h"
#include		"ERR.h"
#include		"PDMproto.h"
#include		"PDUpdmrpro.h"
#include		"PDUnode.h"
#include		"PDMmessage.h"

extern int      PDMdebug_on;
extern char     PDM_DEBUG_FILE[];
extern PDMpart_ptr PDMpart;
extern PDMexec_ptr PDMexec;
static long     status;
static char     s[1024];
extern char   glob_var[100];
extern struct PDUstorage *storage;
extern struct NFMglobal_st NFMglobal;

/* additional declarations for NFM3.0 */
#include		"NFMschema.h"
#include		"NFMapi.h"
#include		"WFexterns.h"
struct NFMwf_info  PDMwf_info;
struct NFMoperation  *PDMoperation, *PDMlast_oper;

/*

Kumar Narayanan
August 21 1993 
checkin    - improved design


{*HIDE .!}
-BEGIN

- Check whether the user has logged in.
Initialize PDU_dyn_index = 1.
Query for the part info and load it in the refresh.
Get Catalog nos and Load it in PDMpart.n_catalogno SUCCESS?
      (Yes)
      (No) return error!
   ?end
Get Part Info and Load it in PDMpart SUCCESS?
      (Yes)
      (No) return error!
   ?end
Is PDMpart.n_cisano < 0 ?
      (Yes) return PDM_E_NO_STO_LOC!
      (No)
   ?end
Is PDMpart.n_status = 'I" ?
      (Yes) return PDM_E_PART_CHECKIN!
      (No)
   ?end
Is PDMpart.n_status = 'TI" ?
      (Yes) return PDM_I_ON_TRANSFER!
      (No)
   ?end
Is PDMpart.n_status = 'TO" ?
      (Yes) return PDM_I_ON_TRANSFER!
      (No)
   ?end
Is PDMpart.n_status = 'O" or 'S'?
      (Yes) Get the new files which got added after checkout - SUCCESS?
            (Yes)
            (No)  print no files got added!
           ?end
      (No)
   ?end
Is PDMpart.p_parttype = 'N' or 'n' ?
      (Yes) return PDM_E_PART_NONGRAPHIC!
      (No)
   ?end
Is PDMpart.p_parttype = 'P' or 'p' ?
      (Yes) return PDM_E_CAN_NOT_CHECKIN_PARAMETRIC_PART!
      (No)
   ?end
Is PDMpart.n_arichivestate = 'N' or 'n' ?
      (Yes) return PDM_E_PART_ARHCIVED!
      (No)
   ?end
Is PDMpart.n_itemlock = 'N' or 'n' ?
      (Yes) return PDM_E_ITEM_LOCKED!
      (No)
   ?end
Is PDMpart.n_pendingflag = 'IA' or 'SA' ?
      (Yes) return PDM_E_PART_FLAGGED_FOR_ARCHIVE!
      (No)
?end
Is PDMpart.n_pendingflag = 'IA' or 'SA' ?
      (Yes) return PDM_E_PART_FLAGGED_FOR_ARCHIVE!
      (No)
   ?end
Is PDMpart.n_pendingflag = 'IB' or 'SB' ?
      (Yes) return PDM_E_PART_FLAGGED_FOR_BACKUP!
      (No)
   ?end
Is PDMpart.n_pendingflag = 'ID' or 'SD' ?
      (Yes) return PDM_E_PART_FLAGGED_FOR_DELETE!
      (No)
   ?end
Is PDMpart.n_pendingflag = 'IR' or 'SR' ?
      (Yes) return PDM_E_PART_FLAGGED_FOR_RESTORE!
      (No)
   ?end
 Validate User access on "PDMCheck In Part"?
 (Access given)
 (Access denied) return PDM_E_VALIDATE_USER_ACCESS!
?end
Check to see if the part is checked out. PDUget_file_status?
  (O,S,NULL)
  (ANY THING ELSE) return PDM_E_NOTCHECK_OUT!
?end
Call PDMget_filenames to get the list of filenames?
 (No files found) return PDM_I_NO_FILES_FOUND!
 (Files found)
?end
Call gr$get_module_env.
Verify that all the files in the file bufr exists locally?
 (Yes) 
 (No) return PDM_E_FILE_NOT_FOUND!
?end
If it's a macro library?
 (Yes)
 (No) Checking in a macro library!
?end
Do this if the part has multiple files .      
 Do this for the files which are EMS and user says that this is not
 going to be a structure definition file.
 Check to see if it's a OM file by calling ex$is_om_file?
 (Yes)
 (No) Skip this file
 ?end
 If it's a OM file construct a file mount name.
 Get the osnum of invis Object space.
 Call ex$retrieve_module - Success?
 (Yes) 
 (No) skip that file!
  ?end
  Open the object space invisbly, call ex$get_invis_info_by_index -SUCCESS?
 (Yes)
 (NO) skip that file!
 ?end
 Check to see if file is a PDU file by calling PDUis_PDU_file- SUCCESS?
 (Yes)
 (No) PDUremove_PDU_design_file_stamp
  ?end
 Close and save object space by calling ex$close_module.
Check the entry in the variable car_filename. If it's null, take the
first OM file. Otherwise use the filename given by the user.
Construct the osnum of invis space by calling ex$retrieve_module - Success?
(Yes)
(No)  return PDM_E_OPEN_FILE
?end
Open the object space of the assembly by calling ex$get_invis_info_by_index
-SUCCESS?
(Yes)
 (No) return PDM_E_OPEN_FILE!
?end
 If spr_mod_env not NULL, get current module environment.

  Stamp PDU design file with PDU_DESIGN_FILE.
    PDUstamp_design_file(*spr_mod_env);

  Check to see if parametric parts exist.
    PDUget_all_parametric_ids(osnum, &parametric_ids, &count).

  If count is greater than 0

    Free parametric_ids.

    Load list of parametric catalogs.
      PDUprepare_param_cats_list(spr_mod_env, &PDU_param_cat_list). If not
      successful (status != PDM_S_SUCCESS), return PDM_E_COMPLETE_PART_CHECKIN.
      This function will query only the catalogs of parametric parts
      which are placed after checkout. There is no need to manage the
      macro libraries of the nth level children.

    Load parametric checkin information.
      status = PALchekin(spr_mod_env). If not successful
      (status != PDM_S_SUCCESS), return PDM_E_COMPLETE_PART_CHECKIN.
      

  Extract part pointer information.
    status = PDUload_child_buffer(&PDU_child_buffer, spr_mod_env). If not
    successful (status != PDM_S_SUCCESS), return PDM_E_COMPLETE_CHECKIN.
    {     
    Check to see if part exists in obj space?
     (Yes)
     (No) return PDM_S_SUCCES!
    Extract all PDU GRparts from object space.
    Intialize the part ids list.
    Intialize the total count.
    Check if need to get active design module info.
    If osnum = 0 , get active module info by calling ex$get_cur_mod.
    Check to see if parts directory exists, by calling di$give_pathname, and di$ls.
    If count <=0 then return PDM_S_SUCCESS.
    Extract part types from object space by calling di$find - SUCCESS?
    (Yes)
    (No)  return status!
    ?end
    If  part count < 0, then say no parts found in object space, return PDM_S_SUCCESS.
    Get the class id of the GRpart.
    Loop thru part types extracting part ids.
    Calling di$dump.
    Add part ids to part ids list.
    Load the variable "total_count".
    If count == 0 return PDM_S_SUCCESS.
    If child_buffer is not fromatted, format it.
    Construct path tofile directory by calling di$give_pathname. 
    Loop thru extracting part checkin info, write info to child buffer.
    Extract p_childno by calling co$part_get_attr.
    Extract p_catalogname  by calling co$part_get_attr.
    Extract n_itemname  by calling co$part_get_attr.
    Extract n_itemrev  by calling co$part_get_attr.
    Extract p_quantity  by calling co$part_get_attr.
    Extract p_usageid  by calling co$part_get_attr.
    Extract p_tagno  by calling co$part_get_attr.
    Extract p_alttagno  by calling co$part_get_attr.
    Extract p_incbom  by calling co$part_get_attr.
    Extract p_incstr  by calling co$part_get_attr.
    Extract p_history  by calling co$part_get_attr.
    Extarct catalogno from expressions by calling PDUevaluate_exp.
    Extract filename from expressions by calling PDIevaluate_exp.
    Write this information into the child buffer.

  Extract part attachment information.
    status = PDUload_attach_buffer(&PDU_attach_buffer, *spr_mod_env). If not
    successful (status != PDM_S_SUCCESS), return PDM_E_COMPLETE_CHECKIN.
    Contstruct path to object space file.
    Construct path to the assembly structure.
    Build a list of attached parts of all levels by calling di$find.
    Create and format the attached buffer.
    For all the parts
     Strip the directory entry in the parts list
     Extract the catalogno and itemno from obj space by calling PDUevaluate_exp.
      Load the attach buffer.

  Load dynamic attributes and values.
    status = PDUload_dynamic_attrs(spr_mod_env, &PDU_dyn_attr_bufr,
                                   &PDU_dyn_data_bufr). If not successful
    (status != PDM_S_SUCCESS), return PDM_E_COMPLETE_PART_CHECKIN. Note:
    This function needs to be modified so as not to query the dynamic attributes
    from the db for non-parametric parts.
    Get all the GRpart_ids by calling PDUget_all_GRpart_ids.
    Get all the parametric part ids by calling PDUget_all_parametric_ids.
    Process all parametric parts by calling PDUprocess_part_dyn_attrs.
    Process all regular dynamic part attributes
    Extract catalog name from the parts by calling get_parameter_values.
    Check to see if part dyn attrs have already been processed.
    Load dynamic attrs to data buffer.
    Extract part child no by calling get_parameter_values.
    Extract dyn attr values by calling get_parameter_values.
    Extract part usage id by calling get_parameter_values.
    Get the path to external dyn. attrs by calling di$give_pathname.
    Append :PDU:macro_parts:parameter
    Extract the value by calling PDUevaluate_exp.  

  Extract view information.
    status = PDUload_view_info(spr_mod_env->md_id.objid,
                               spr_mod_env->md_id.osnum, &PDU_view_buffer). If
    not successful (status != PDM_S_SUCCESS and status !=
    PDM_I_ORIGIN_NOT_FOUND), return (PDM_E_COMPLETE_PART_CHECKIN).
    This is going to be done only if new views are defined.
SUCCESS?
      (Yes)
      (No) return PDM_E_BUILD_ARRAY!
   ?end
MEMprint all the buffers.
MEMopen and MEMwrite_format delete_list buffer which needs to sent back to PDU
- SUCCESS?
      (Yes)
      (No) return NFM_E_MEM!
   ?end
Analyze child bufr and PDMpart.n_setindicator:
(If child_bufr->rows = 0 and PDMpart.n_setindicator is 'Y' or 'y' - case1)
     > CASE1
(If child_bufr->rows = 0 and PDMpart.n_setindicator is 'n' or 'N' - case2)
     > CASE2
(If child_bufr->rows > 0 and PDMpart.n_setindicator is 'Y' or 'y' - case3)
     > CASE3
(If child_bufr->rows > 0 and PDMpart.n_setindicator is 'n' or 'N' - nsertcase4)
     > CASE4
If the parttype is not set set the p_parttype = 'G'?
      (Yes)
      (No) print out the debug information
   ?end
If the PDMpart.n_status is null:
     (i.e Never checked in before)
      then get the multiple files of the item to be deleted - SUCCESS?
      (Yes) Add to the delete list to PDU
      (No) print out the debug information
       ?end
      :end
     (i.e Checked in before atleast once)
       Add to the delete list to PDU.
   :end
Macro library management - Call PDMdelete_local_macros - SUCCESS?
      (Yes)
      (No) print the debug info
   ?end
Update the permission of the files that needs to be changed - Call _PDMup-
date_permission_change_bufr -  SUCCESS?
      (Yes)
      (No) print the debug info
   ?end
Update p_incpartrpt to null.
Return delete file list to PDU with successful status.

-CASE1
(If child_bufr->rows = 0 and PDMpart.n_setindicator is 'Y' or 'y' - case1)
SET AUTOCOMMIT OFF?
      (Yes)
      (No)  return error!
   ?end
If the structure update flag is set to 'Y'?
 (Yes) LOCK catalog attribute with a value for update. - SUCCESS?
      (Yes)
      (No) > return error!
   ?end
    If assembly indicator is set to "Y" ?
      (Yes)
          Drop all its first level children - SUCCESS?
           (Yes)
           (No) > WRAPUP
            ?end
      (No)
   ?end
  (No) Loop for 2 minutes.
?end
SET AUTOCOMMIT ON?
      (Yes)
      (No) > return error!
   ?end
Call NFMconvert_to_item to convert assembly to item - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Check the view change flag and then Insert the saved views 
   information - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Load NFMoperation struct.
Create fmgr buffer - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Check the local file manager and load the bufr for cleanup - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Call NFMcheckin_item - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT OFF?
      (Yes)
      (No) > WRAPUP
   ?end
LOCK NFMSAFILES Loop for 2 minutes - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Update the local file manager  - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Check the fmgr buffer manager and load the delete file list  for cleanup to
PDU- SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT ON?
      (Yes)
      (No) > WRAPUP
   ?end
:end


-CASE2

(If child_bufr->rows = 0 and PDMpart.n_setindicator is 'n' or 'N' - case2)
SET AUTOCOMMIT OFF?
      (Yes)
      (No) > return error!
   ?end
Insert the saved views information if the saved views flag is set- SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT ON?
      (Yes)
      (No) > return error!
   ?end
Load NFMoperation struct.
Create fmgr buffer - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Check the local file manager and load the bufr for cleanup - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Call NFMcheckin_item - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT OFF?
      (Yes)
      (No) > WRAPUP
   ?end
LOCK NFMSAFILES Loop for 2 minutes - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Update the local file manager  - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Check the fmgr buffer manager and load the delete file list  for cleanup to
PDU- SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT ON?
      (Yes)
      (No) > WRAPUP
   ?end
:end

-CASE3
(If child_bufr->rows > 0 and PDMpart.n_setindicator is 'Y' or 'y' - case3)
SET AUTOCOMMIT OFF?
      (Yes)
      (No) > return error!
   ?end
If the update structure flag is set, then do the followin
LOCK catalog table to update the structure flag update  - SUCCESS?
  (Yes)
      (Yes)
      (No) > return error!
   ?end
Call to PDMupdate_set_members - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Call to PDMXXinsert_citinfo - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
If, there are nthlevel parametric info Call to PDMdefine_parametric_assembly -
SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
 (No) return error!
?end
Insert the saved views information if the flag is set- SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT ON?
      (Yes)
      (No) > WRAPUP
   ?end
Create fmgr buffer - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Check the local file manager and load the bufr for cleanup - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
If, n_status is null, then set n_couser to the current username - SUCCESS?
      (Yes)
      (No) print out the debug information
   ?end
Set n_status = 'O' to enable item checkin - SUCCESS?
      (Yes)
      (No)  return PDM_E_SQL_STMT!
   ?end
Load NFMoperation struct - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Call NFMcheckin_item - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT OFF?
      (Yes)
      (No) > WRAPUP
   ?end
LOCK NFMSAFILES Loop for 2 minutes - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Update the local file manager  - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Check the fmgr buffer manager and load the delete file list  for cleanup to
PDU- SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT ON?
      (Yes)
      (No) > WRAPUP
   ?end
:end

-CASE4
(If child_bufr->rows > 0 and PDMpart.n_setindicator is 'n' or 'N' - case4)

Call to NFMconvert_to_set - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT OFF?
      (Yes)
      (No) > return error!
   ?end
If the update structure flag is set, then do the following.
 
LOCK catalog table for the structure update flag  - SUCCESS?
      (Yes)
      (No) > return error!
   ?end
Call to PDMupdate_set_members - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Call to PDMXXinsert_citinfo - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
If, there are nthlevel parametric info Call to PDMdefine_parametric_assembly -
SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Insert the saved views information if the flag is set- SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT ON?
      (Yes)
      (No) > WRAPUP
   ?end
Select and load the max level - default is 50.
Update n_colevel = max level - SUCCESS?
      (Yes)
      (No) return PDM_E_SQL_STMT!
   ?end
Create fmgr buffer - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Check the local file manager and load the bufr for cleanup - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Load NFMoperation struct - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Call NFMcheckin_item - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT OFF?
      (Yes)
      (No) > WRAPUP
   ?end
LOCK NFMSAFILES Loop for 2 minutes - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Update the local file manager  - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
Check the fmgr buffer manager and load the delete file list  for cleanup to
PDU- SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
SET AUTOCOMMIT ON?
      (Yes)
      (No) > WRAPUP
   ?end
Set n_indicator = Y to make it as an assembly  - SUCCESS?
      (Yes)
      (No) > WRAPUP
   ?end
:end

-WRAPUP
ROLLBACK TRANSACTION.
RETURN status!

Intialize the gloabal variables PDU_child_buffer, PDU_attach_buffer,
PDU_view_buffer,
PDU_param_buffer, PDUchild_dyn_buffer, reformatted buffer.

Free up the PDU_param_cat_list global variable.

Reset the PDY_dyn_index =1.

return status.
 * DESCRIPTION: checkin a pdm part
 *  Kumar Narayanan - 10.5.91 
 * PARAMETERS:  PDMexecptr       PDMexec;
 * 
 * INPUT:	PDMexec
 * 
 * The following fields of PDMexec are REQUIRED.
 * 
 * PDMexec->ws_buffer contains the following buffers
 * 
 * (2) child_bufr (3) attach_bufr (4) sv_bufr (5) storage_buffer
 * (6) parm_buffer (7) data_buffers
 * 
 * This buffer can be empty implying that the filename was given during
 * creation.
 * 
 * child_bufr	 may/may not be empty
 * 
 * The format is as follows
 * 
 * p_catalogname		char(14) p_partnum			char(14)
 * p_revision			char(14) p_orient
 * 28) p_quantity			double p_history
 * har(10) p_childno			char(25) p_usageid
 * har(25) p_viewid			char(25)
 * 
 * attach_bufr  may/may not be empty
 * 
 * foramt is as follows
 * 
 * p_seqno			> 0 indicates BOM attachment = 0 pdmcit attachment
 * 
 * p_catalogname	char(14) p_partnum		char(14) p_revision
 * har(14)
 * 
 * sv_bufr  may/may not be empty
 * 
 * p_origin			char(100) p_rotation
 * 28) p_viewname			char(40)
 * 
 * OUTPUT:
 * 
 * 
 * RETURN CODES:
 * 
 * PDM_S_SUCCESS    on success
 * 
 * A. if child_bufr is empty
 * 
 * (a) either the part is being checked in first time without first level
 * children  or (b)	the part is reduced to an atomic part from an
 * assembly
 * 
 * If (b) delete the previous children from the nfmcit and pdmcit.
 * 
 * Do NFM prepare and complete checkin Update saved views if any Delete active &
 * review boms if found Note that the attach_bufr is of no use
 * 
 * B. if child_bufr is not empty
 * 
 * (a) part was an atomic part and is now an assembly (b) part was an assembly
 * before In both the cases add the children as secondary members
 */

int PDMcheckin_part
        (
        MEMptr file_bufr, 
        MEMptr child_bufr, 
        MEMptr attach_bufr, 
        MEMptr sv_bufr,
        MEMptr parm_buffer, 
        MEMptr data_buffers,
        MEMptr para_ass, 
        MEMptr para_ass_dynamic, 
        struct PDUcat_node *para_cats, 
        MEMptr *delete_list, 
        MEMptr *mul_files
        )

{
/*  if (file_bufr) MEMclose(&file_bufr);*/

 status = PDMcheckin_part1 (1, 1, child_bufr, attach_bufr, sv_bufr, parm_buffer,  data_buffers, para_ass, para_ass_dynamic, para_cats, delete_list, mul_files);
    if(status != PDM_S_SUCCESS) 
      return(status);
else return (PDM_S_SUCCESS);
} 

int PDMcheckin_part1
        (
        int    update_structure,
        int    view_update, 
        MEMptr child_bufr, 
        MEMptr attach_bufr, 
        MEMptr sv_bufr,
        MEMptr parm_buffer, 
        MEMptr data_buffers,
        MEMptr para_ass, 
        MEMptr para_ass_dynamic, 
        struct PDUcat_node *para_cats, 
        MEMptr *delete_list, 
        MEMptr *mul_files
        )
{
        char		*fn = "PDMcheckin_part";
        char            a_row[100],**mul_data = NULL;
        char            *msg = NULL;
        MEMptr          new_files = NULL;
        int             mul = 0;

	_PDMdebug(fn,"ENTER:\n");

	*delete_list = NULL;
       
        msg = (char *)PDUtranslate_message(PDS_M_CHECKIN_PART); 
        strcpy(glob_var,msg);
        PDMupdate_dots();
	/* check if part exists */
	status = PDMload_catno(PDMexec->catalog);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug (fn, "PDMload_catno failed status %d\n", status);
		return (status);
	}

        PDMupdate_dots ();
	status = PDMload_part_info(PDMexec->catalog, PDMexec->part_num, 
				PDMexec->revision);
	if (status != PDM_S_SUCCESS) {
		_PDMdebug (fn, "PDMload_part_info failed status %d\n", status);
		return (status);
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
   if(!strcmp(PDMpart.n_status,"O") || !strcmp(PDMpart.n_status,"S"))
      {
/* Put in a fix to see whether the checkout_user=current_user. MaC 060194*/

       _PDMdebug (fn, "cousr[%s] : curusr[%s]\n",
                        PDMpart.n_couser, NFMglobal.NFMusername);
       if (strcmp (PDMpart.n_couser, NFMglobal.NFMusername)) {
              _PDMdebug ("PART is", "NOT CHECKED OUT BY YOU\n");
              return (PDM_I_CHECKED_OUT_BY_ANOTHER_USER);
            }

       status = PDMget_new_files(PDMexec->catalog,PDMpart.n_itemno,&new_files);
            if(status != PDM_S_SUCCESS) 
           _PDMdebug (fn, "PDMget_new_files failed status %d\n", status);
      }
      if(PDMdebug_on){
         MEMprint_buffer("new_files for the part", new_files, PDM_DEBUG_FILE);
        }

	status = PDM_S_SUCCESS;

	if (PDMdebug_on) {
		MEMprint_buffer("child_bufr", child_bufr, PDM_DEBUG_FILE);
		MEMprint_buffer("attach_bufr", attach_bufr, PDM_DEBUG_FILE);
		MEMprint_buffer("sv_bufr", sv_bufr, PDM_DEBUG_FILE);
		MEMprint_buffer("parm_buffer", parm_buffer, PDM_DEBUG_FILE);
	  	MEMprint_buffers("data_buffers", data_buffers, PDM_DEBUG_FILE);
	  	MEMprint_buffers("para_ass_dynamic", para_ass_dynamic, PDM_DEBUG_FILE);
		PDMprint_storage_area();
	}
        
     status = MEMopen (delete_list, 512);
      if (status != MEM_S_SUCCESS)
       {
                 _PDMdebug (fn,"MEM open : failed status \n");
                return (NFM_E_MEM);
       }
      status = MEMwrite_format (*delete_list, "n_cofilename", "char(128)");
      if (status != MEM_S_SUCCESS)
       {
           _PDMdebug (fn,"MEM Wr For : failed status \n");
           return (NFM_E_MEM);
       }

        PDMupdate_dots ();
	/* being checked in as atomic part */

	if ((child_bufr == NULL) || (child_bufr->rows == 0)) {
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
		if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
		    !strncmp(PDMpart.n_setindicator, "y", 1)) 
*/
		if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
		    !strncmp(PDMpart.n_setindicator, "y", 1) ||
                    !strncmp(PDMpart.n_setindicator, "A", 1) ||
                    !strncmp(PDMpart.n_setindicator, "a", 1)) {
			/* was assembly before */
                       status = PDMdelete_bom();
                        if (status != PDM_S_SUCCESS &&
                            status != PDM_E_BOM_NOT_FOUND) {
           _PDMdebug(fn, "%s %d\n", "PDMdelete_bom failed status ", status);
                        }
			
     status = PDMcheckin_case1(  PDMexec->catalog, PDMexec->part_num, 
    		   PDMexec->revision, PDMpart.n_itemno, 
        parm_buffer, sv_bufr, delete_list, update_structure,view_update) ;
			if (status != PDM_S_SUCCESS) {
		_PDMdebug(fn, "PDMcheckin_case1 failed status %d\n", status);
         PDMreset_ncoout(PDMexec->catalog, PDMpart.n_itemno, PDMpart.n_status);
				return (status);
			}
		} else {	/* was atomic before */
		status = PDMcheckin_case2(  PDMexec->catalog, 
					   PDMexec->part_num, 
					   PDMexec->revision, 
					   PDMpart.n_itemno,  
		   			   sv_bufr, delete_list, view_update);
			if (status != PDM_S_SUCCESS) {
		_PDMdebug(fn, "PDMcheckin_case2 failed status %d\n", status);
          PDMreset_ncoout(PDMexec->catalog, PDMpart.n_itemno, PDMpart.n_status);
				return (status);
			}
		}

	}
	/* being checked in as assembly */

	else if (child_bufr->rows > 0) {
/* 10/23/95 - MJG - TR 139424087 DM Manager */
/*
		if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
		    !strncmp(PDMpart.n_setindicator, "y", 1)) 
*/
/* part was an assembly * before */
		if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
		    !strncmp(PDMpart.n_setindicator, "y", 1) ||
                    !strncmp(PDMpart.n_setindicator, "A", 1) ||
                    !strncmp(PDMpart.n_setindicator, "a", 1)) {	

			status = PDMcheckin_case3(  PDMexec->catalog, 
						   PDMexec->part_num, 
						   PDMexec->revision, 
						   PDMpart.n_itemno, 
						   child_bufr, 
						   attach_bufr, 
						   sv_bufr, 
                       parm_buffer, data_buffers,para_ass, para_ass_dynamic,delete_list, update_structure, view_update);
			if (status != PDM_S_SUCCESS) {
	_PDMdebug(fn, "PDMcheckin_case3 failed status %d\n", status);
          PDMreset_ncoout(PDMexec->catalog, PDMpart.n_itemno, PDMpart.n_status);
				return (status);
			}
		} else {	/* part was atomic before */

		status = PDMcheckin_case4( PDMexec->catalog, 
					  PDMexec->part_num, 
					  PDMexec->revision, 
					  PDMpart.n_itemno, 
					  child_bufr, 
					  attach_bufr, 
					  sv_bufr, 
	                      parm_buffer, data_buffers,para_ass, para_ass_dynamic, delete_list, view_update);
			if (status != PDM_S_SUCCESS) {
/*
				MEMclose(&child_bufr);
				MEMclose(&attach_bufr);
				MEMclose(&sv_bufr);
				MEMclose(&parm_buffer);
				MEMclose(&data_buffers);
				MEMclose(delete_list);
*/
			_PDMdebug(fn, "PDMcheckin_case4 failed status %d\n", 
					status);
         PDMreset_ncoout(PDMexec->catalog, PDMpart.n_itemno, PDMpart.n_status);
				return (status);
			}
		}

	}

        PDMupdate_dots ();
	/* set the p_parttype to "G" */

	if (status == PDM_S_SUCCESS)
        {
        if(!strcmp(PDMpart.p_parttype,""))
               {
        PDMupdate_dots();
        status = PDMset_parttype(PDMexec->catalog, PDMexec->part_num, 
			 PDMexec->revision, "G");
         if (status != PDM_S_SUCCESS) 
        _PDMdebug(fn, "PDMset_parttype failed status = %d \n", status);
               }
        if(!strcmp(PDMpart.n_status,""))
               {
              PDMupdate_dots();
    status = PDMget_mul_file(PDMexec->catalog,PDMpart.n_itemno,&new_files);
            if(status != PDM_S_SUCCESS) 
            _PDMdebug (fn, "PDMget_mul_file failed status %d\n", status);
            else
                { 
                 status = MEMbuild_array(new_files);
                  if(status != MEM_S_SUCCESS) {
                  _PDMdebug (fn, "MEMbuild_array: 0x%.8x\n", status);
                  return (status);
                   }
                   mul_data = (char **)new_files->data_ptr;
                    for(mul=0; mul < new_files->rows; mul++)
                    {
                     if(strcmp(mul_data[mul],PDMpart.n_cofilename))
                     {
                    a_row[0] = '\0';
                    sprintf(a_row,"%s\1", mul_data[mul]);
                    _PDMdebug  (fn, "a_row-> %s\n", a_row) ;
                     status = MEMwrite(*delete_list,a_row);
                    if(status != MEM_S_SUCCESS)
                  _PDMdebug (fn, "MEMwrite: 0x%.8x\n", status);
                     }
                    }
                    MEMclose(&new_files);
                 }
	      }
        else 
             {
              status = MEMbuild_array(new_files);
              if(status == MEM_S_SUCCESS)
              {
                   mul_data = (char **)new_files->data_ptr;
                    for(mul=0; mul < new_files->rows; mul++)
                    {
                    a_row[0] = '\0';
                    sprintf(a_row,"%s\1", mul_data[mul]);
                    _PDMdebug  (fn, "a_row-> %s\n", a_row) ;
                     status = MEMwrite(*delete_list,a_row);
                    if(status != MEM_S_SUCCESS)
                  _PDMdebug (fn, "MEMwrite: 0x%.8x\n", status);
                     }
                    MEMclose(&new_files);
               }
	      }
           }
      status = PDMdelete_local_macros(para_cats, delete_list);
      if(status != PDM_S_SUCCESS) {
         _PDMdebug (fn, "Cleanup of macro libraries failed: 0x%.8x\n", status);
            }

      if(PDMdebug_on){
         MEMprint_buffer("delete_list to pdu",*delete_list,PDM_DEBUG_FILE);
        }
      PDMupdate_dots();
 
/* Getting the list of files whose permissions need to be changed */
      status = _PDMupdate_permission_change_bufr (PDMexec->catalog,
                                                  PDMpart.n_itemno,
                                                  mul_files, delete_list);
      if(status != PDM_S_SUCCESS) {
         _PDMdebug (fn, "Updating permission files failed: 0x%.8x\n", status);
            }

      if(PDMdebug_on){
         MEMprint_buffer("delete_list to pdu",*delete_list,PDM_DEBUG_FILE);
         MEMprint_buffer("mul_files to pdu", *mul_files, PDM_DEBUG_FILE);
        }

      PDMupdate_dots();
      PDMreset_dots();
   _PDMdebug(fn,"EXIT: - SUCCESS\n");
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
 a) There is a possibility of having attachments from BOM since it could have
 * been generated when the part was an assembly. (b) saved views may exist
 * (c) Old cit info needs to be deleted
 */


/*
 * Part was assembly and is being checked in as atomic part
 */

PDMcheckin_case1(cat, part, rev, pno, 
		 parm_buffer, sv_bufr, file_list, update_structure, view_update)
	char           *cat;
	char           *part;
	char           *rev;
	int             pno;
	MEMptr          parm_buffer;
	MEMptr          sv_bufr;
	MEMptr          *file_list;
        int             update_structure;
        int             view_update;
{
        char		*fn = "PDMcheckin_case1";
	char            pdmsv_table[100] = "", sql_str[250] = "" ;
        MEMptr          attach_bufr = NULL;
        MEMptr          fmgr_bufr = NULL;
        MEMptr          citno = NULL;
        MEMptr          new_set = NULL;
	int             n_sano = 0, subsystem = 0;
        long            sts = PDM_S_SUCCESS;


	_PDMdebug(fn,"Enter\n");
MEMbuild_array(parm_buffer);
        pdmsv_table[0] = '\0';
        sql_str[0] = '\0';
	sprintf(pdmsv_table, "v_%s", cat);

        n_sano = storage->storage_no;

	status = PDMstop_transaction(1200);
	if (status != PDM_S_SUCCESS) {
    _PDMdebug(fn, "PDMstart_transction failed status -> = %d \n", status);
		goto wrapup;
	}
        sprintf(sql_str,"LOCK TABLES %s IN EXCLUSIVE MODE", cat);
        status = SQLstmt(sql_str);
        if(status != SQL_S_SUCCESS)
        {
      /*   locking the catalog tables during update
            to keep spinning for 30+30+30+30 seconds. The right fix is row
            level locking supported by informix and oracle */
                PDMupdate_dots ();
                PDUmessage (PDM_E_CON_ACCESS, 's');
                sleep (30);
                status = SQLstmt(sql_str);
               if (status != SQL_S_SUCCESS) {
                PDUmessage (PDM_E_CON_ACCESS1, 's');
                sleep (30);
                status = SQLstmt(sql_str);
               if (status != SQL_S_SUCCESS) {
                PDUmessage (PDM_E_CON_TRY_LATER, 's');
               status = PDM_I_TABLE_LOCKED;
         _PDMdebug(fn,  "LOCK %s SQLstmt failed status %d\n",  cat, status);
                goto wrapup;
                     }
             }
        }

/*
        sprintf(sql_str,"UPDATE %s SET p_incpartrpt = 'M', n_setindicator = 'N' , n_status = 'TI' where n_itemno = %d\n", cat, PDMpart.n_itemno);
*/
        _PDMdebug(fn, "update_structure %d \n", update_structure);
       if(!strcmp(PDMpart.p_incpartrpt,"") && !update_structure)
        {
        sprintf(sql_str,"UPDATE %s SET n_setindicator = 'N' , n_status = 'TI' where n_itemno = %d\n", cat, PDMpart.n_itemno);
        status = SQLstmt(sql_str); 
        if(status != SQL_S_SUCCESS)
        {
        _PDMdebug(fn, "SQLstmt failed status -> = %d \n", status);
         return(status);
        }	
        }
	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
    _PDMdebug(fn, "PDMstart_transction failed status -> = %d \n", status);
		goto wrapup;
	}
        PDMupdate_dots ();

       if(!strcmp(PDMpart.p_incpartrpt,"") && !update_structure)
        {
	status = PDMdron_setindicator(PDMpart.n_catalogno,PDMpart.n_itemno);
	if (status != PDM_S_SUCCESS) {
     _PDMdebug(fn, "PDMdron_setindicator failed status -> = %d \n", status);
		goto wrapup;

	   }
        }
/***********************************
      Added support of updating CITs for making an assy
      into atomic part MaC 050794 */

      if (update_structure)
      {
      status = PDMConvertToAtomic (cat, part, rev, 
                                   PDMpart.n_catalogno,PDMpart.n_itemno,
                                    &citno, &new_set);

      if (status != PDM_S_SUCCESS) {
     _PDMdebug(fn, "PDMConvertToAtomic failed status -> 0x%.8x \n", status);
		goto wrapup;

	   }
      }
      if (PDMdebug_on) {
          MEMprint_buffer("citno_bufr in PDUcheckin_case1", citno,
                          PDM_DEBUG_FILE);
          MEMprint_buffer("new_set in PDUcheckin_case1", new_set,
                          PDM_DEBUG_FILE);
             }
/***************************************************************/

        PDMupdate_dots ();
	/* if there are any views delete old views and add the new ones */

	if (sv_bufr != NULL && sv_bufr->rows && view_update) {
		status = PDMinsert_views(pdmsv_table, pno, sv_bufr);
		if (status != PDM_S_SUCCESS) {
		_PDMdebug(fn, "PDMinsert_views failed status %d\n", status);
                          status = PDM_E_SAVED_VIEWS_TABLE_NOT_CREATED; 
			goto wrapup;
		}
	}
/* additional changes made to accomodate NFM3.0 */

        status =  PDMset_info_oper_struct (cat, part, rev);
        if (status != PDM_S_SUCCESS) {
         _PDMdebug (fn, "PDMset_info_oper_struct failed status %d \n", status);
                goto wrapup;
           }
   status = PDMcr_chkin_fmgrbufr(&fmgr_bufr);
   if(status != PDM_S_SUCCESS)
   {
                MEMclose(fmgr_bufr);
          _PDMdebug(fn,"PDMi_create_fmgr_bufr failed status %d\n",status);
                goto wrapup;
   }
   

        PDMupdate_dots ();
        status = PDMchkin_file_transfers(PDMpart.n_catalogno,
        PDMpart.n_itemno,PDMpart.n_cofilename,attach_bufr,fmgr_bufr);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n", 
                        "PDMchkin_file_tranfers failed", status);
                goto wrapup;
           }
  
        PDMupdate_dots ();
        ERRreset_struct ();

	/* New 3.0 NFMcheckin */
       _PDMdebug (fn, "Calling PDMcheckin....\n");
	status = PDMcheckin_item (cat, 
                                 PDMpart.n_catalogno, 
                                 part, 
                                 rev, 
				 storage->storage_name, 
				 PDMwf_info, 
				 *PDMoperation);

	if (status != NFM_S_SUCCESS) {
		MEMclose(file_list);
		_PDMdebug (fn, " %s %s %d", 
			"NFMcomplete_item_checkin ", 
			" failed status -> ", status);
     ERRget_number (&status, &subsystem);
    _PDMdebug (fn, "status = %d\n", status);
     if(status == NFM_E_CI_FILENAME_EXISTS) status = PDM_E_CI_FILENAME_EXISTS;
     else if (status == NFM_E_LOCK_TABLE_FAILED) status = PDM_I_TABLE_LOCKED;

		goto wrapup;
	}
        PDMupdate_dots ();
	status = PDMupdate_fmgr_chkin(n_sano, fmgr_bufr);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n", 
			status);
		PDMdebug(s);
		goto wrapup;
	}
        PDMupdate_dots();
	/* commit work */
	status = PDMpdu_delete_filelist(fmgr_bufr,file_list);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n", 
			status);
		PDMdebug(s);
		goto wrapup;
	}
        PDMupdate_dots ();

	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMstart_transaction failed status %d\n", status);
		PDMdebug(s);
	}
	MEMclose(&fmgr_bufr);
	PDMdebug("EXIT:PDMcheckin_case1\n");
	return (PDM_S_SUCCESS);

wrapup:

	sts = PDMrollback_transaction(1200);
	if (sts != PDM_S_SUCCESS) {
		sprintf(s, "PDMrollback_transaction failed status %d\n", status);
		PDMdebug(s);
	}
	return (status);
}

/* Part was atomic and is being checked in as atomic part */

PDMcheckin_case2( cat, 
		 part, 
		 rev, 
		 pno, 
		 sv_bufr, file_list, view_update)
	char           *cat;
	char           *part;
	char           *rev;
	int             pno;
	MEMptr          sv_bufr;
	MEMptr          *file_list;
        int              view_update;
{
        char		*fn = "PDMcheckin_case2";
	char            pdmsv_table[100] = "";
	int             n_sano = 0;
        MEMptr          attach_bufr=NULL;
        MEMptr          fmgr_bufr=NULL;
        long            sts = PDM_S_SUCCESS;

	PDMdebug("ENTER:PDMcheckin_case2\n");
/* ANSI */

        _PDMdebug (fn, "cat = %s, part = %s, rev = %s, pno = %d\n", cat, part, rev, pno);

	sprintf(pdmsv_table, "v_%s", cat);

        n_sano = storage->storage_no;

	/*
	 * if there are any views delete old views and add the new ones
	 */

	if (sv_bufr != NULL && sv_bufr->rows && view_update) {
		status = PDMinsert_views(pdmsv_table, pno, sv_bufr);
		if (status != PDM_S_SUCCESS) {
			sprintf(s, 
			      "PDMinsert_views failed status %d\n", status);
			PDMdebug(s);
                          status = PDM_E_SAVED_VIEWS_TABLE_NOT_CREATED; 
			goto wrapup;
		}
	}
              PDMupdate_dots();
        /* additional changes made to accomodate NFM3.0 */
        status =  PDMset_info_oper_struct (cat, part, rev);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n", 
                        "PDMset_info_oper_struct", status);
                goto wrapup;
           }
        status = PDMcr_chkin_fmgrbufr(&fmgr_bufr);
        if(status != PDM_S_SUCCESS)
            {
                MEMclose(fmgr_bufr);
                sprintf(s,"PDMi_create_fmgr_bufr failed status %d\n",status);
                PDMdebug(s);
                return(status);
             }
        status = PDMchkin_file_transfers(PDMpart.n_catalogno,
        PDMpart.n_itemno,PDMpart.n_cofilename,attach_bufr,fmgr_bufr);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n",
                        "PDMchkin_file_tranfers failed", status);
                goto wrapup;
           }
              PDMupdate_dots();
  
	/* New 3.0 NFMcheckin */
sprintf (s, "cat = %s, catno = %d, part = %s, rev = %s, storage->storage_name = %s \n",cat, PDMpart.n_catalogno, part, rev, storage->storage_name);
PDMdebug (s);
       _PDMdebug (fn, "Calling NFMcheckin....\n");
       
	status = PDMcheckin_item (cat, 
                                 PDMpart.n_catalogno, 
                                 part, 
                                 rev, 
				 storage->storage_name, 
				 PDMwf_info, 
				 *PDMoperation);
	if (status != NFM_S_SUCCESS) {
		MEMclose(file_list);
		sprintf(s, " %s %s %d", 
			"NFMcomplete_item_checkin ", 
			" failed status -> ", status);
		PDMdebug(s);
                ERRget_specific_number (NFM, &status);
               _PDMdebug (fn, "status = %d\n", status);
                if (status == NFM_E_LOCK_TABLE_FAILED) 
                                    status = PDM_I_TABLE_LOCKED;
		goto wrapup;
	}
              PDMupdate_dots();

        status = PDMupdate_fmgr_chkin(n_sano, fmgr_bufr);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n",
                        status);
                PDMdebug(s);
                goto wrapup;
        }
              PDMupdate_dots();
status = PDMpdu_delete_filelist(fmgr_bufr,file_list);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n",
                        status);
                PDMdebug(s);
                goto wrapup;
        }
        if (PDMdebug_on)
          MEMprint_buffer("file_list in PDUcheckin_case2", *file_list,
                          PDM_DEBUG_FILE);
	/* commit work */

	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMstart_transaction failed status %d\n", status);
		PDMdebug(s);
	}
        MEMclose(&fmgr_bufr);
	PDMdebug("EXIT:PDMcheckin_case2\n");
	return (PDM_S_SUCCESS);

wrapup:

	sts = PDMrollback_transaction(1200);
	if (sts != PDM_S_SUCCESS) {
	sprintf(s, "PDMrollback_transaction failed status %d\n", status);
		PDMdebug(s);
	}
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

int PDMcheckin_case3( catalog, p_partnum, 
		      p_revision, p_partno, child_bufr, attach_bufr, sv_bufr, 
		      parm_buffer, data_buffers,para_ass, 
                      para_ass_dynamic, file_list,
                      update_structure, view_update)
	char           *catalog;
	char           *p_partnum;
	char           *p_revision;
	int             p_partno;
	MEMptr          child_bufr;
	MEMptr          attach_bufr;
	MEMptr          sv_bufr;
	MEMptr          parm_buffer;
	MEMptr          data_buffers;
	MEMptr          para_ass;
	MEMptr          para_ass_dynamic;
	MEMptr          *file_list;
        int             update_structure;
        int             view_update;
{
	char           *fn = "PDMcheckin_case3";
	int             n1 = 0, n_sano = 0;
	int             child_opt = 0;
	long             sts = PDM_S_SUCCESS;
	char            pdmsv_table[40] = "";
	MEMptr          new_set = NULL;
	MEMptr          fmgr_bufr = NULL;
	MEMptr          attr_bufr = NULL;
	MEMptr          data_bufr = NULL;
	MEMptr          citno = NULL;
        char            sql_str[300] = ""; 


	PDMdebug("ENTER: PDMcheckin_case3:\n");

/* ANSI */

	n1 = -1;

        n_sano = storage->storage_no;

	/* find saved views table name */

	pdmsv_table[0] = '\0';
	sprintf(pdmsv_table, "v_%s", catalog);
        PDMupdate_dots();
        if(update_structure)
        {
        /*
        status = PDMupdate_set_members(user_id, catalog, p_partnum, 
                          p_revision, child_bufr, &old_set,&new_set,&citno,
                          PDMpart.n_catalogno,PDMpart.n_itemno);
         */
        status = PDMupdate_set_members(catalog, p_partnum, p_revision, 
                          PDMpart.n_catalogno,PDMpart.n_itemno,
                        child_bufr, &citno, &new_set);
	if (status != PDM_S_SUCCESS) {
          _PDMdebug(fn, "%s  <0x%.8x>\n", "PDMupdate_set_members ", status);
		goto wrapup;
	}
        PDMupdate_dots();

	/* insert cit info. delete old entries and add new entries */

	status = PDMinsert_citinfo(PDMpart.n_catalogno,PDMpart.n_itemno, new_set, parm_buffer, data_buffers,citno,"Y");
	if (status != PDM_S_SUCCESS) {
		MEMclose(&new_set);
		sprintf(s, " %s %s %d\n", 
			"PDMinsert_citinfo ", " failed status -> ", status);
		PDMdebug(s);
		goto wrapup;
	}
	/* insert views */
              PDMupdate_dots();

if( para_ass != NULL && para_ass->rows > 0)
        {
        MEMprint_buffer("para_ass", para_ass, PDM_DEBUG_FILE); 
        MEMprint_buffers("para_ass", para_ass_dynamic, PDM_DEBUG_FILE); 
        status = PDMdefine_parametric_assembly(para_ass, para_ass_dynamic);
        if (status != PDM_S_SUCCESS && status == SQL_I_NO_ROWS_FOUND)
         {
        _PDMdebug(fn, "%s %d \n", "PDMdefine_parametric_assembly", status);
        goto wrapup;
        }
              PDMupdate_dots();
         }

      }
	/* insert cit info. delete old entries and add new entries */
	if (sv_bufr != NULL && sv_bufr->rows && view_update) {
	status = PDMinsert_views(pdmsv_table, p_partno, sv_bufr);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&new_set);
		sprintf(s, " %s %s %d\n", 
			" PDMinsert_views ", "failed status -> ", status);
		PDMdebug(s);
                          status = PDM_E_SAVED_VIEWS_TABLE_NOT_CREATED; 
		goto wrapup;
	    }
         }
              PDMupdate_dots();
	MEMclose(&new_set);
        status = PDMcr_chkin_fmgrbufr(&fmgr_bufr);
        if(status != PDM_S_SUCCESS)
         {
                MEMclose(fmgr_bufr);
                sprintf(s,"PDMi_create_fmgr_bufr failed status %d\n",status);
                PDMdebug(s);
                return(status);
           }
   

	/* Check file manager stuff */
	status = PDMchkin_file_transfers( PDMpart.n_catalogno, PDMpart.n_itemno,
                    PDMpart.n_cofilename,attach_bufr, fmgr_bufr);
	if (status != PDM_S_SUCCESS) {
	_PDMdebug (fn, "%s %d \n", 
			"PDMchkin_file_transfers failed status ", status);
		goto wrapup;
        	}
        PDMupdate_dots();
         if(!strcmp(PDMpart.n_status,""))
         {
	sprintf(sql_str, "UPDATE  f_%s SET n_couser = '%s', n_cosano = %d WHERE n_itemnum = %d",catalog, NFMglobal.NFMusername, n_sano,PDMpart.n_itemno);
	status = SQLstmt(sql_str);
	if (status != SQL_S_SUCCESS) {
		_PDMdebug(fn, "SETTING co_user failed status %d\n", status);
	  }
         }
        status =  PDMset_info_oper_struct (catalog, p_partnum, p_revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n", 
                        "PDMset_info_oper_struct", status);
                goto wrapup;
           }
  
        child_opt = NFM_SAME_OPERATION;

              PDMupdate_dots();
       _PDMdebug (fn, "Calling NFMcheckin....\n");
	status = PDMcheckin_item (catalog, 
                                 PDMpart.n_catalogno, 
                                 p_partnum, 
                                 p_revision, 
				 storage->storage_name, 
				 PDMwf_info, 
				 *PDMoperation);

	if (status != NFM_S_SUCCESS) {
		MEMclose(&new_set);
		sprintf(s, " %s %s %d\n", 
		   " NFMprepare_set_checkin ", "failed status -> ", status);
		PDMdebug(s);
                ERRget_specific_number (NFM, &sts);
                if (sts == NFM_E_LOCK_TABLE_FAILED) 
                                    sts = PDM_I_TABLE_LOCKED;
               _PDMdebug (fn, "sts = %d\n", sts);
		goto wrapup;
	}
        status = PDMupdate_fmgr_chkin(n_sano, fmgr_bufr);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n",
                        status);
                PDMdebug(s);
                goto wrapup;
        }
        /* commit work */
        status = PDMpdu_delete_filelist(fmgr_bufr,file_list);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n",
                        status);
                PDMdebug(s);
                goto wrapup;
        }
        PDMupdate_dots();
	status = PDMstart_transaction(1200);
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMstart_transaction failed status %d\n", status);
		PDMdebug(s);
		goto wrapup;
	}
	MEMclose(&attr_bufr);
	MEMclose(&data_bufr);

	PDMdebug("EXIT: PDMcheckin_case3:\n");
	return (PDM_S_SUCCESS);

wrapup:

	sts = PDMrollback_transaction(1200);
	if (sts != PDM_S_SUCCESS) {
		sprintf(s, 
		      "PDMrollback_transaction failed status %d\n", status);
	}
	return (status);
}

/* atom -> assembly  */

int PDMcheckin_case4( catalog, p_partnum, 
		      p_revision, p_partno, child_bufr, attach_bufr, sv_bufr, 
		      parm_buffer, data_buffers,para_ass,
                      para_ass_dynamic, file_list, view_update)
	char           *catalog;
	char           *p_partnum;
	char           *p_revision;
	int             p_partno;
	MEMptr          child_bufr;
	MEMptr          attach_bufr;
	MEMptr          sv_bufr;
	MEMptr          parm_buffer;
	MEMptr          data_buffers;
	MEMptr          para_ass;
	MEMptr          para_ass_dynamic;
	MEMptr          *file_list;
        int               view_update;
{
        char		*fn = "PDMcheckin_case4";
	int             n1 = 0, n2 = 0, n3 = 0;
	int             n_sano = 0;
	char            pdmsv_table[40] = "";
	MEMptr          new_set = NULL;
	MEMptr          fmgr_bufr = NULL;
	MEMptr          citno = NULL;
	int             child_opt = 0;
        long            sts = PDM_S_SUCCESS;

	_PDMdebug(fn, "ENTER: \n");

/* ANSI */

	n1 = -1; n2 = -1; n3 = -1;

         n_sano = storage->storage_no;


	/* find saved views table name */

	pdmsv_table[0] = '\0';
	sprintf(pdmsv_table, "v_%s", catalog);

        /* Needed for NFM 3.0.0 - Kumar 1/18/92  
	status = NFMconvert_to_set(user_id, catalog, 
				   p_partnum, p_revision);
	if (status != NFM_S_SUCCESS) {
		sprintf(s, " %s %s %d \n", 
			" NFMconvert_to_set ", " failed status -> ", status);
		PDMdebug(s);
		goto wrapup;
	}
        */
              PDMupdate_dots();
     /* 
      status = PDMupdate_set_members(user_id, catalog, p_partnum,
                             p_revision, child_bufr, &old_set, &new_set,&citno,
                                PDMpart.n_catalogno,PDMpart.n_itemno);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "%s %d \n",
                        "PDMupdate_set_members ", status);
                PDMdebug(s);
                goto wrapup;
        }
              PDMupdate_dots();
       status = PDMXXinsert_citinfo( PDMpart.n_catalogno,PDMpart.n_itemno,child_bufr, parm_buffer, new_set,data_buffers,citno,"Y");
        if (status != PDM_S_SUCCESS) {
                MEMclose(&old_set);
                MEMclose(&new_set);
                sprintf(s, " %s %s %d\n",
                        "  PDMinsert_citinfo ",
                        " failed status -> ", status);
                PDMdebug(s);
                goto wrapup;
          }
         PDMupdate_dots();
         */
        status = PDMupdate_set_members(catalog, p_partnum, p_revision,
                          PDMpart.n_catalogno,PDMpart.n_itemno,
                        child_bufr, &citno, &new_set);
        if (status != PDM_S_SUCCESS) {
          _PDMdebug(fn, "%s  <0x%.8x>\n", "PDMupdate_set_members ", status);
                goto wrapup;
        }
        PDMupdate_dots();

        /* insert cit info. delete old entries and add new entries */

        status = PDMinsert_citinfo(PDMpart.n_catalogno,PDMpart.n_itemno, new_set
, parm_buffer, data_buffers,citno,"Y");
        if (status != PDM_S_SUCCESS) {
                MEMclose(&new_set);
                sprintf(s, " %s %s %d\n",
                        "PDMinsert_citinfo ", " failed status -> ", status);
                PDMdebug(s);
                goto wrapup;
        }

        
      if( para_ass != NULL && para_ass->rows > 0)
        {
        status = PDMdefine_parametric_assembly(para_ass, para_ass_dynamic);
        if (status != PDM_S_SUCCESS && status == SQL_I_NO_ROWS_FOUND)
         {
        _PDMdebug(fn, "%s %d \n", "PDMdefine_parametric_assembly", status);
        goto wrapup;
        }
              PDMupdate_dots();
         }
	/* insert views */

	if (sv_bufr != NULL && sv_bufr->rows && view_update) {
	status = PDMinsert_views(pdmsv_table, p_partno, sv_bufr);
	if (status != PDM_S_SUCCESS) {
		MEMclose(&new_set);
		sprintf(s, " %s %s %d\n", 
			" PDMinsert_views ", " failed status -> ", status);
		PDMdebug(s);
                          status = PDM_E_SAVED_VIEWS_TABLE_NOT_CREATED; 
		goto wrapup;
	   }
         }

        PDMupdate_dots();
        status = PDMcr_chkin_fmgrbufr(&fmgr_bufr);
        if(status != PDM_S_SUCCESS)
            {
                MEMclose(fmgr_bufr);
                sprintf(s,"PDMi_create_fmgr_bufr failed status %d\n",status);
                PDMdebug(s);
                return(status);
             }
           status = PDMchkin_file_transfers(PDMpart.n_catalogno,
           PDMpart.n_itemno, PDMpart.n_cofilename, attach_bufr,fmgr_bufr);
               if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n",
                        "PDMchkin_file_tranfers failed", status);
                goto wrapup;
           }
           PDMupdate_dots();
        status =  PDMset_info_oper_struct (catalog, p_partnum, p_revision);
        if (status != PDM_S_SUCCESS) {
                _PDMdebug (fn, "%s %d \n", 
                        "PDMset_info_oper_struct", status);
                goto wrapup;
           }
  
        child_opt = NFM_SAME_OPERATION;

	/* New 3.0 NFMcheckin */
       _PDMdebug (fn, "Calling NFMcheckin....\n");
	status = PDMcheckin_item (catalog, 
                                 PDMpart.n_catalogno, 
                                 p_partnum, 
                                 p_revision, 
				 storage->storage_name, 
				 PDMwf_info, 
				 *PDMoperation);

	if (status != NFM_S_SUCCESS) {
		sprintf(s, " %s %s %d", 
			" \n NFMprepare_set_checkin ", 
			" failed status -> ", status);
		PDMdebug(s);
               ERRget_specific_number (NFM, &status);
               if (status == NFM_E_LOCK_TABLE_FAILED) 
                                    status = PDM_I_TABLE_LOCKED;
               _PDMdebug (fn, "status = %d\n", status);
		goto wrapup;
	}
        PDMupdate_dots();
        status = PDMupdate_fmgr_chkin(n_sano, fmgr_bufr);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n",
                        status);
                PDMdebug(s);
                goto wrapup;
        }
        /* commit work */
        status = PDMpdu_delete_filelist(fmgr_bufr,file_list);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMupdate_fmgr_chkin failed status %d\n",
                        status);
                PDMdebug(s);
                goto wrapup;
        }

        status = PDMstart_transaction(1200);
        if (status != PDM_S_SUCCESS) {
                sprintf(s, "PDMstart_transaction failed status %d\n", status);
                PDMdebug(s);
                goto wrapup;
        }
	status = PDMset_n_setindicator (catalog, p_partnum, p_revision, "Y");
	if (status != PDM_S_SUCCESS) {
		sprintf(s, "PDMset_n_setindicator  failed status %d\n", status);
		PDMdebug(s);
                goto wrapup;
	}
	MEMclose(&fmgr_bufr);
        PDMupdate_dots();
	PDMdebug("EXIT: PDMcheckin_case4:\n");
	return (PDM_S_SUCCESS);

wrapup:

	sts = PDMrollback_transaction(1200);
	if (sts != PDM_S_SUCCESS) {
		sprintf(s, 
		      "PDMrollback_transaction failed status %d\n", status);
	}
	MEMclose(&fmgr_bufr);
	return (status);
}

/*
 * INPUT:
 * 
 * (a).   para_cats containing the parametric catalog information of the
 * requester
 * INPUT/OUTPUT
 *
 * (b).   file_bufr buffer containing the file information to be deleted
 *  - Kumar 3.29.93
 */

int  PDMdelete_local_macros(para_cats1, delete_list)
struct PDUcat_node     *para_cats1;
MEMptr          *delete_list;
{
	char            **data = NULL, **sa_data = NULL; 
	char            sql_str[1024], mem_str[512];
	int             ref_count = 0;
	int             n_itemno = 0, n_catalogno = 0;
	MEMptr          sa_bufr = NULL;
	MEMptr          bufr = NULL;
	struct PDUcat_node     *para_cats;
        char            *fname = "PDMdelete_local_macros";
/* added for support libraries support MaC */
        int             MacIndex, AssyIndex, M, y, Added, partno_sav;
        MEMptr          AssyBufr = NULL, MacLib = NULL;
        char            **AssyData;
        char            **MacData;
        char            setindicator[3], parttype[3];


    _PDMdebug(fname, "ENTER:\n");

    para_cats = para_cats1;

    if(para_cats != NULL) {


/****************************************************************************
   Adding support for support libraries to macro libraries.
   The support libraries are in nfmcit as children to the macro
   libraries.
   Alg:
     - For each catalog in linked list,  get the associated
       macro cat & part;
     - For each of these parts, get the assy structure;
     - add the catno and itemno of the assy structure 
       to the MacLibList bufr; only if this part does not
       already exist.
     - For each part in MacLibList; get the file info
     - Add the file info into the file_list bufr 
     - Go by the lfm and add files to delete list
****************************************************************************/

  /* Create the MacLib buffer */

      status = MEMopen (&MacLib, 1024);
      if (status != MEM_S_SUCCESS) {
         _PDMdebug (fname, "MEM Open : status = <0x%.8x>\n", status);
         return (NFM_E_MEM);
       }
      status = MEMwrite_format (MacLib, "n_catalogname", "char(40)");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }
      status = MEMwrite_format (MacLib, "n_itemname", "char(80)");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }
      status = MEMwrite_format (MacLib, "n_itemrev", "char(80)");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }
      status = MEMwrite_format (MacLib, "n_catalogno", "integer");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }
      status = MEMwrite_format (MacLib, "n_itemno", "integer");
      if (status != MEM_S_SUCCESS) {
            MEMclose (&MacLib);
            _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
            return (NFM_E_MEM);
      }

      status = MEMbuild_array(MacLib);
      if(status != MEM_S_SUCCESS)
                      {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

  MacData = (char **) MacLib->data_ptr;

  partno_sav = PDMpart.n_itemno;

  for (; para_cats != NULL; para_cats = para_cats->next ) {
      _PDMdebug (fname, "para_cats->catalog[%s]\n", para_cats->catalog);
      _PDMdebug(fname,"linked list %x and next <%x>\n",
                                             para_cats, para_cats->next);
      _PDMdebug(fname,"Checking the macro lib for <%s>\n",
                                             para_cats->catalog);
      sql_str[0] = '\0';
      sprintf(sql_str,
               "SELECT %s FROM  pdmparamloc WHERE n_catalogname = '%s'", 
                        " p_macrocat,p_macropartno,p_macrorev ",
                        para_cats->catalog);
      status = SQLquery(sql_str,&bufr,512);
      if(status != SQL_S_SUCCESS) {
                  if(status == SQL_I_NO_ROWS_FOUND) continue;
                  _PDMdebug(fname, "SQLquery failed status %d\n", status);
                   return (status);
                  }
      status = MEMbuild_array(bufr);
      if(status != MEM_S_SUCCESS)
                      {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

      data = (char **) bufr->data_ptr;

     /* Need to add parent to the list also. The AssyBufr
        returned will not have this information */


      status = PDMquery_catalog_partnos(data[0],
                                              data[1],
                                              data[2],
                                              &n_catalogno, &n_itemno);
      if(status != PDM_S_SUCCESS) {
         _PDMdebug (fname, "PDMquery_catalog_partnos: 0x%.8x\n", status);
         MEMclose(&bufr);
         continue;
       }
/* Check to see whether it is already added ... 
   If it is added, we do not need to check for its assy struct etc..*/

       Added = 0;
       for (M = 0; M < MacLib->rows; M++) {
	 MacIndex = M * MacLib->columns;
        if ((atol (MacData[MacIndex + 3]) == n_catalogno ) &&
             (atol (MacData[MacIndex + 4]) == n_itemno) ){
           _PDMdebug (fname, "cat[%s]:item[%s] already added \n",
                                MacData[MacIndex + 3],
                                MacData[MacIndex + 4]);
            Added = 1;
            break;
            }
         }

     if (Added == 0) {
       sprintf (mem_str, "%s\1%s\1%s\1%d\1%d\1",
                       data[0], data[1],
                       data[2], n_catalogno, n_itemno);

       _PDMdebug (fname, "mem_str[%s]\n", mem_str);
       status = MEMwrite(MacLib, mem_str);
       if (status != MEM_S_SUCCESS) {
                _PDMdebug(fname, "MEMwrite Failed 0x%.8x\n", status);
                }

       status = MEMbuild_array(MacLib);
       if(status != MEM_S_SUCCESS) {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

       MacData = (char **) MacLib->data_ptr;

     /* Get the assy struct for this part */

      status =  PDMquery_assyind_parttype ( data[0],
                                       data[1],
                                       data[2],
                                       setindicator,
                                       parttype);
        if(status != PDM_S_SUCCESS) {
              _PDMdebug (fname, "PDMquery_assyind_parttype:failed: 0x%.8x\n", 
                                                               status);
              setindicator[0] = '\0';
              strcpy (setindicator, "Y");
              }

     if (!strcmp (setindicator, "Y") || !strcmp (setindicator, "y")) {
       /* This function needs to access PDMpart structure:
          we have stored the value in this member. we now load
          value of this itemno into this */
     
        PDMpart.n_itemno = n_itemno; 

        AssyBufr = NULL;
        status = PDMquery_ass_struc ( data[0],
                                       data[1],
                                       data[2],
                                       50,
                                       setindicator,
                                       0,
                                       &AssyBufr);
        if( (status != PDM_S_SUCCESS ) &&
              (status != PDM_E_PART_NOT_ASSEMBLY)) {
           _PDMdebug(fname,"PDMquery_ass_struc failed status %d\n", status);
           PDMrollback_transaction (1200);
           return(PDM_E_QUERY_SET_MEMBERS);
          }

	if (PDMdebug_on) 
             MEMprint_buffer ("AssyBufr", AssyBufr, PDM_DEBUG_FILE);


      status = MEMbuild_array(MacLib);
      if(status != MEM_S_SUCCESS)
                      {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

      MacData = (char **) MacLib->data_ptr;

      status = MEMbuild_array (AssyBufr);
      if(status != MEM_S_SUCCESS) {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

      AssyData = (char **) AssyBufr->data_ptr;

      for (y = 1; y < AssyBufr->rows; y++) {
       AssyIndex = y * AssyBufr->columns;
       _PDMdebug ("Checking Library", "%s:%s:%s:%s:%s\n",
                       AssyData[AssyIndex + 10],
                       AssyData[AssyIndex + 11],
                       AssyData[AssyIndex + 12],
                       AssyData[AssyIndex + 3],
                       AssyData[AssyIndex + 4]);
       Added = 0;
       for (M = 0; M < MacLib->rows; M++) {
	 MacIndex = M * MacLib->columns;
        if ((atol (MacData[MacIndex + 3]) == atol (AssyData[AssyIndex + 3])) &&
           (atol (MacData[MacIndex + 4]) == atol (AssyData[AssyIndex + 4]) ) ){
           _PDMdebug (fname, "cat[%s]:item[%s] already added \n",
                              AssyData[AssyIndex + 10],
                                AssyData[AssyIndex + 11]);
            Added = 1;
            break;
            }

         }
        if (Added != 1) {
           sprintf (mem_str, "%s\1%s\1%s\1%s\1%s\1",
                       AssyData[AssyIndex + 10],
                       AssyData[AssyIndex + 11],
                       AssyData[AssyIndex + 12],
                       AssyData[AssyIndex + 3],
                       AssyData[AssyIndex + 4]);

           _PDMdebug (fname, "mem_str[%s]\n", mem_str);
           status = MEMwrite(MacLib, mem_str);
           if (status != MEM_S_SUCCESS) {
                _PDMdebug(fname, "MEMwrite Failed 0x%.8x\n", status);
                /*return (status);*/
		}

           status = MEMbuild_array(MacLib);
           if(status != MEM_S_SUCCESS) {
              _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
              return(status);
              }

           MacData = (char **) MacLib->data_ptr;
         }
        }
       MEMclose (&AssyBufr);
       }
      } /* This lib was already added */
      MEMclose (&bufr);
/*
      if (PDMdebug_on) 
             MEMprint_buffer ("MacLib in Loop", MacLib, PDM_DEBUG_FILE);
*/
      }
 
  PDMpart.n_itemno = partno_sav;

	if (PDMdebug_on) 
             MEMprint_buffer ("MacLib", MacLib, PDM_DEBUG_FILE);

/****************************************************************************
   End of additions
****************************************************************************/

/*
      for (; para_cats != NULL; para_cats = para_cats->next ) 
        _PDMdebug(fname,
            "linked list %x and next <%x>\n",para_cats, para_cats->next);
         _PDMdebug(fname,
            "Checking the macro lib for <%s>\n",para_cats->catalog);
         sql_str[0] = '\0';
         mem_str[0] = '\0';
         sprintf(sql_str,"SELECT p_macrocat,p_macropartno,p_macrorev FROM pdmparamloc WHERE n_catalogname = '%s'", para_cats->catalog);
         status = SQLquery(sql_str,&bufr,512);
         if(status != SQL_S_SUCCESS) {
            if(status == SQL_I_NO_ROWS_FOUND) continue; 
               status = _PDMget_db_error (status);    
               _PDMdebug(fname, "SQLquery failed status %d\n", status);
               return (status);
               }
         status = MEMbuild_array(bufr);
         if(status != MEM_S_SUCCESS) {
           _PDMdebug (fname, "MEMbuild_array: 0x%.8x\n", status);
           return(status);
           }

         data = (char **) bufr->data_ptr;

         status = PDMquery_catalog_partnos (data[0],
                                            data[1],
                                            data[2],
                                            &n_catalogno, 
                                            &n_itemno);
         if(status != PDM_S_SUCCESS) {
           _PDMdebug (fname, "PDMquery_catalog_partnos: 0x%.8x\n", status);
           MEMclose(&bufr);
           continue;
           }
*/

       MacData = (char **) MacLib->data_ptr;
       data = (char **) MacLib->data_ptr;
       /*bufr = MacLib;*/
       for (M = 0; M < MacLib->rows; M++) {
	 MacIndex = M * MacLib->columns;
         _PDMdebug (fname, "M=%d\n", M);
         n_catalogno = atol (MacData[MacIndex+3]);
         n_itemno = atol (MacData[MacIndex+4]);
         sql_str[0] = '\0';
         sprintf(sql_str, "%s %s  %d  and n_catalogno = %d and n_itemno = %d " ,
          "select n_co,n_copy, n_fileversion,n_ref,n_filename,n_filenum ",
           " from nfmsafiles where n_sano = ",
             storage->storage_no, n_catalogno, n_itemno );

         _PDMdebug ("sql_str", "%s\n", sql_str);

         status = SQLquery(sql_str, &sa_bufr,512);
         if(status != SQL_S_SUCCESS) {
           MEMclose(&sa_bufr);
           MEMclose(&bufr);
           if (status == SQL_I_NO_ROWS_FOUND) {
              /* report that the files to be moved */
              _PDMdebug("","No filemgr update is needed for this item\n");
              continue;
              }
            else  {
              status = _PDMget_db_error (status);    
              return(status);
              }
            }
           status = MEMbuild_array(sa_bufr);
           if (status != MEM_S_SUCCESS) {
             _PDMdebug (fname, "MEM error  0x%.8x\n", status);
             MEMclose(&sa_bufr);
             MEMclose(&bufr);
             continue;
             }
           sa_data = (char **) sa_bufr->data_ptr;
           if(PDMdebug_on)
              _PDMdebug(fname,"n_co %s, n_copy %s n_ref %s n_filename %s \n",
                     sa_data[0],sa_data[1], sa_data[3], sa_data[4]);

           if((!strcmp(sa_data[0],"Y") || !strcmp(sa_data[0],"y"))
           && (!strcmp(sa_data[1],"Y") || !strcmp(sa_data[1],"y"))
           && (!strcmp(sa_data[3],"")))
               {
                 /* fmgr-case 2 */
                   /* Checked out and  copied  - DO_NOTHING*/
                 _PDMdebug ("case 2 DO NOTHING", "for <%s>  \n", sa_data[4]);
                    MEMclose(&bufr);
                  MEMclose(&sa_bufr); continue;
                  }
           else if ((!strcmp(sa_data[0],"Y") || !strcmp(sa_data[0],"y"))
           && (!strcmp(sa_data[1],"") || !strcmp(sa_data[1],"N"))
           && (!strcmp(sa_data[3],"")))
               {
                 /* fmgr-case 1 */
                    /* Just Checked out  - DO_NOTHING*/
                 _PDMdebug ("case 1 DO NOTHING", "for <%s>  \n", sa_data[4]);
                    MEMclose(&bufr);
                  MEMclose(&sa_bufr); continue;
                  }
         else  if((!strcmp(sa_data[0],"Y") || !strcmp(sa_data[0],"y"))
           && (!strcmp(sa_data[1],"") || !strcmp(sa_data[1],"N"))
           && (atoi(sa_data[3]) > 0))
               {
                 /* fmgr-case 3 */
                    /* Checked out and   referenced  - UPDATE_REF*/
                      ref_count = atoi(sa_data[3]);
                      if(ref_count != 0) ref_count = ref_count - 1;
                       sprintf(sql_str,"UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count,sa_data[1],sa_data[0], storage->storage_no, n_catalogno,n_itemno,sa_data[5],sa_data[2],sa_data[4]);
                 _PDMdebug ("case 3 UPDATE REF ", "for <%s>  \n", sa_data[4]);
               }
           else if((!strcmp(sa_data[0],"") || !strcmp(sa_data[0],"N"))
           && (!strcmp(sa_data[1],"") || !strcmp(sa_data[1],"N"))
           && (atoi(sa_data[3]) > 0 ))
               {
                /* fmgr case-7 */
                /* Just  referenced - UPDATE_CO*/
                    if(atoi(sa_data[3]) == 1)
                   {

        sprintf(sql_str,"DELETE FROM  NFMSAFILES  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", storage->storage_no, n_catalogno, n_itemno,sa_data[5],sa_data[2],sa_data[4]);
                 _PDMdebug ("case 7 DELETE  ", "file <%s>  \n", sa_data[4]);
                    mem_str[0] = '\0';
                    sprintf(mem_str,"%s\1", sa_data[4]);
                     status = MEMwrite(*delete_list,mem_str);
                    if(status != MEM_S_SUCCESS)
                     {
                    MEMclose(&bufr);
                    MEMclose(&sa_bufr);
                  _PDMdebug (fname, "MEM Wr For : status = <0x%.8x>\n", status);
                     return (NFM_E_MEM);
                      }
                   }
                   else 
                     {
                      ref_count = atoi(sa_data[3]);
                      if(ref_count != 0) ref_count = ref_count - 1;
                       sprintf(sql_str,"UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count,sa_data[1],sa_data[0], storage->storage_no, n_catalogno,n_itemno,sa_data[5],sa_data[2],sa_data[4]);
                 _PDMdebug ("case 7 UPDATE REF ", "for <%s>  \n", sa_data[4]);
                     }
               }
           else if((!strcmp(sa_data[0],"") || !strcmp(sa_data[0],"N"))
           && (!strcmp(sa_data[1],"Y") || !strcmp(sa_data[1],"y"))
           && (atoi(sa_data[3]) > 0 ))
               {
                /* fmgr case-9 */
          /* Referenced and copied - UPDATE_REF*/
                      if(ref_count != 0) ref_count = ref_count - 1;
                       sprintf(sql_str,"UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count,sa_data[1],sa_data[0], storage->storage_no, n_catalogno,n_itemno,sa_data[5],sa_data[2],sa_data[4]);
                 _PDMdebug ("case 9 UPDATE REF ", "for <%s>  \n", sa_data[4]);
               }
              else if((!strcmp(sa_data[0],"N") || !strcmp(sa_data[0],"") ) && (!strcmp (sa_data[1],"y") || !strcmp(sa_data[1],"Y")) && (!strcmp(sa_data[3],"") ))
               {
                 /* fmgr case-4 */
          /* Just copy - DO_NOTHING */
                 _PDMdebug ("case 4 DO NOTHING", "for <%s>  \n", sa_data[4]);
                    MEMclose(&bufr);
                  MEMclose(&sa_bufr); continue;
               }
    else if((!strcmp(sa_data[0],"Y") || !strcmp(sa_data[0],"y") ) && (!strcmp(sa_data[1],"y") || !strcmp(sa_data[1],"Y")) && (!strcmp(sa_data[3],"") )
)
               {
                 /* fmgr case-5  DO_NOTHING*/
                 _PDMdebug ("case 5 DO NOTHING", "for <%s>  \n", sa_data[4]);
                    MEMclose(&bufr);
                  MEMclose(&sa_bufr); continue;
               }
    else if((!strcmp(sa_data[0],"") || !strcmp(sa_data[0],"N") ) && (!strcmp (sa_data[1],"y") || !strcmp(sa_data[1],"Y")) && (atoi(sa_data[3]) > 0))
               {
                 /* fmgr case-6 UPDATE_REF*/
          /* Copy and referenced */
                      if(ref_count != 0) ref_count = ref_count - 1;
                       sprintf(sql_str,"UPDATE NFMSAFILES SET n_ref = %d, n_copy= '%s', n_co = '%s'  WHERE n_sano = %d AND n_catalogno = %d AND n_itemno = %d AND n_filenum = %s AND n_fileversion = %s AND n_filename = '%s'", ref_count,sa_data[1],sa_data[0], storage->storage_no, n_catalogno,n_itemno,sa_data[5],sa_data[2],sa_data[4]);
                 _PDMdebug ("case 6 UPDATE REF ", "for <%s>  \n", sa_data[4]);
               }

      status = SQLstmt(sql_str);    
      if (status != SQL_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
                  {
             _PDMdebug (fname, "SQLstmt failed  : status = <0x%.8x>\n", status);
                     return (status);
                  }
      _PDMdebug (fname, "Update successful\n");
      MEMclose(&sa_bufr);
      MEMclose(&bufr);
      _PDMdebug (fname,"Next macro lib \n");
      }
   }
  else {
   _PDMdebug (fname, "No parametric libraries associated\n");
    }

  _PDMdebug(fname,"EXIT ..\n");
  return(PDM_S_SUCCESS);
}


   /*
    mul_files is set to NULL. This function was added so that
   a child file's permissions can be reset back to read only
   after it (child) is checked in while the parent is checked out.
                                                     MaC 051293
  */

int _PDMupdate_permission_change_bufr (catalog, itemnum, 
                                              mul_files, delete_list)
MEMptr	*mul_files;
MEMptr	*delete_list;
{
  char	*fn = "_PDMupdate_permission_change_bufr";
  int	m_index, d_index, mul, del;
  char		**mul_data, **del_data;
  int		common;
  char		sql_str [1024];
  _PDMdebug("ENTER", "%s\n", fn);

  sql_str[0] = '\0';

  sprintf (sql_str, 
   "SELECT n_cofilename FROM f_%s WHERE n_itemnum = %d ORDER BY n_cofilename",
    catalog, itemnum);

  status = SQLquery(sql_str, mul_files, 512);
  if (status != SQL_S_SUCCESS) {
     MEMclose(mul_files);
     _PDMdebug(fn, "Could not find files for %s %d ", catalog, itemnum);
     status = _PDMget_db_error (status);    
     return (status);
     }

  status = MEMbuild_array(*delete_list);
  if (status != MEM_S_SUCCESS) {
     MEMclose(mul_files);
     _PDMdebug(fn, "MEMbuild_array failed status %d \n", status);
     return (PDM_E_BUILD_ARRAY);
     }


  status = MEMbuild_array(*mul_files);
  if (status != MEM_S_SUCCESS) {
     MEMclose(mul_files);
     _PDMdebug(fn, "MEMbuild_array failed status %d \n", status);
     return (PDM_E_BUILD_ARRAY);
     }

  if(PDMdebug_on)
         MEMprint_buffer("mul_files in perm fn", *mul_files, PDM_DEBUG_FILE);

   del = mul = d_index = m_index = 0;

   common = 0;

   mul_data = (char **) (*mul_files)->data_ptr;
   del_data = (char **) (*delete_list)->data_ptr;

   for(mul=0; mul < (*mul_files)->rows; mul++) {
     m_index = mul * (*mul_files)->columns;
     for(del=0; del < (*delete_list)->rows; del++) {
     d_index = del * (*delete_list)->columns;
     if ( !(strcmp (mul_data[m_index], del_data[d_index]))){
        common++;
        _PDMdebug ("mul", "[%s], common[%d]\n", mul_data[m_index], common);
        break;
        }
      }
   }

   _PDMdebug (fn, "common[%d] rows[%d]\n", common, (*mul_files)->rows);
   if (common > 0) {
      _PDMdebug (fn, "MEMclosing mul_files\n");
      MEMclose (mul_files);
      *mul_files = NULL;
     }

  _PDMdebug("EXIT", "%s\n", fn);
   return(PDM_S_SUCCESS);
}

