#include "machine.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMtypes.h"
#include "UTIstruct.h"
#include "ERR.h"
#include "DEBUG.h"

#include "NETstruct.h"

long NFMswitch_command (in_command, in_list)
    long   in_command;
    MEMptr in_list;
{
long    status = 0;
static  char *fname = "NFMSswitch";

_NFMSdebug((fname, "command : %ld\n", in_command));
 
switch (in_command)
    {
    case NFM_ALL_DEBUG :
        _NFMSdebug((fname, "NFM_ALL_DEBUG = <%ld>\n", in_command));
        status = NFMSall_debug (in_list);
        _NFMSdebug((fname, "NFM_ALL_DEBUG DONE : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_DEBUG :
        _NFMSdebug((fname, "NFM_DEBUG = <%ld>\n", in_command));
        status = NFMSdebug (in_list);
        _NFMSdebug((fname, "NFM_DEBUG DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_LOGIN :
        _NFMSdebug((fname, "NFM_QUERY_LOGIN = <%ld>\n", in_command));
        status = NFMSquery_login_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_LOGIN DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_LOGIN :
        _NFMSdebug((fname, "NFM_LOGIN = <%ld>\n", in_command));
        status = NFMSlogin (in_list);
        _NFMSdebug((fname, "NFM_LOGIN DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_LOGOUT :
        _NFMSdebug((fname, "NFM_LOGOUT = <%ld>\n", in_command));
        status = NFMSlogout (in_list);
        _NFMSdebug((fname, "NFM_LOGOUT DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_ADD_NODE :
        _NFMSdebug((fname, "NFM_QUERY_ADD_NODE = <%ld>\n", in_command));
        status = NFMSquery_add_node_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ADD_NODE DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_ADD_NODE :
        _NFMSdebug((fname, "NFM_ADD_NODE = <%ld>\n", in_command));
        status = NFMSadd_node (in_list);
        _NFMSdebug((fname, "NFM_ADD_NODE DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_DELETE_NODE :
        _NFMSdebug((fname, "NFM_DELETE_NODE = <%ld>\n", in_command));
        status = NFMSdelete_node (in_list);
        _NFMSdebug((fname, "NFM_DELETE_NODE DONE : status = <0x%.8x>\n", status));
        break;
    
    case NFM_QUERY_CHANGE_NODE_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_NODE_ATTR = <%ld>\n", 
		    in_command));
        status = NFMSquery_change_node_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_NODE_ATTR : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_CHANGE_NODE :
        _NFMSdebug((fname, "NFM_CHANGE_NODE = <%ld>\n", in_command));
        status = NFMSchange_node (in_list);
        _NFMSdebug((fname, "NFM_CHANGE_NODE : status = <%ld>\n", status));
        break;
	
    case NFM_QUERY_ADD_SA :
        _NFMSdebug((fname, "NFM_QUERY_ADD_SA = <%ld>\n", in_command));
        status = NFMSquery_add_st_area_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ADD_SA DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_ADD_SA :
        _NFMSdebug((fname, "NFM_ADD_SA = <%ld>\n", in_command));
        status = NFMSadd_storage_area (in_list);
        _NFMSdebug((fname, "NFM_ADD_SA DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_DELETE_SA :
        _NFMSdebug((fname, "NFM_DELETE_SA = <%ld>\n", in_command));
        status = NFMSdelete_storage_area (in_list);
        _NFMSdebug((fname, "NFM_DELETE_SA DONE : status = <0x%.8x>\n", status));
        break;
    
    case NFM_QUERY_CHANGE_SA_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_SA_ATTR = <%ld>\n", 
		    in_command));
        status = NFMSquery_change_sa_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_SA_ATTR : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_CHANGE_SA :
        _NFMSdebug((fname, "NFM_CHANGE_SA = <%ld>\n", in_command));
        status = NFMSchange_storage_area (in_list);
        _NFMSdebug((fname, "NFM_CHANGE_SA : status = <0x%.8x>\n", status));
        break;

    case NFM_CHANGE_SA_PASSWD :
        _NFMSdebug((fname, "NFM_CHANGE_SA_PASSWD = <%ld>\n", in_command));
        status = NFMSchange_storage_area_passwd (in_list);
        _NFMSdebug((fname, "NFM_CHANGE_SA_PASSWD DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_CHANGE_WA_PASSWD :
        _NFMSdebug((fname, "NFM_CHANGE_WA_PASSWD = <%ld>\n", in_command));
        status = NFMSchange_working_area_passwd (in_list);
        _NFMSdebug((fname, "NFM_CHANGE_WA_PASSWD DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_ADD_USER :
        _NFMSdebug((fname, "NFM_QUERY_ADD_USER = <%ld>\n", in_command));
        status = NFMSquery_add_user_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ADD_USER DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_ADD_USER :
        _NFMSdebug((fname, "NFM_ADD_USER = <%ld>\n", in_command));
        status = NFMSadd_user (in_list);
        _NFMSdebug((fname, "NFM_ADD_USER DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_DELETE_USER :
        _NFMSdebug((fname, "NFM_DELETE_USER = <%ld>\n", in_command));
        status = NFMSdelete_user (in_list);
        _NFMSdebug((fname, "NFM_DELETE_USER DONE : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_CHANGE_USER_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_USER_ATTR = <%ld>\n", 
		    in_command));
        status = NFMSquery_change_user_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_USER_ATTR : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_CHANGE_USER :
        _NFMSdebug((fname, "NFM_CHANGE_USER = <%ld>\n", in_command));
        status = NFMSchange_user (in_list);
        _NFMSdebug((fname, "NFM_CHANGE_USER : status = <0x%.8x>\n", status));
        break;

    case NFM_CHANGE_USER_PASSWD :
        _NFMSdebug((fname, "NFM_CHANGE_USER_PASSWD = <%ld>\n", in_command));
        status = NFMSchange_user_passwd (in_list);
        _NFMSdebug((fname, "NFM_CHANGE_USER_PASSWD DONE : status = <0x%.8x>\n", status));
        break;


    case NFM_QUERY_USER_DEFAULTS :
        _NFMSdebug((fname, "NFM_QUERY_USER_DEFAULTS = <%ld>\n", in_command));
        status = NFMSquery_user_defaults (in_list);
        _NFMSdebug((fname, "NFM_QUERY_USER_DEFAULTS : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_ADDTO_LOC_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_ADDTO_LOC_ATTR = <%ld>\n", in_command));
        status = NFMSquery_addto_loc_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ADDTO_LOC_ATTR : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_CATALOG_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_CATALOG_ATTR = <%ld>\n", in_command));
        status = NFMSquery_catalog_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CATALOG_ATTR : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_CATALOG_TEMP :
        _NFMSdebug((fname, "NFM_QUERY_CATALOG_TEMP = <%ld>\n", in_command));
        status = NFMSquery_catalog_template (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CATALOG_TEMP : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_CATALOG_TEMP_N :
        _NFMSdebug((fname, "NFM_QUERY_CATALOG_TEMP_N = <%ld>\n", in_command));
        status = NFMSquery_catalog_template_n (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CATALOG_TEMP_N : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_CATALOG_DEF :
        _NFMSdebug((fname, "NFM_QUERY_CATALOG_DEF = <%ld>\n", in_command));
        status = NFMSquery_catalog_definition (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CATALOG_DEF : status = <0x%.8x>\n", status));
        break;

    case NFM_CREATE_CATALOG :
        _NFMSdebug((fname, "NFM_CREATE_CATALOG = <%ld>\n", in_command));
        status = NFMScreate_catalog (in_list);
        _NFMSdebug((fname, "NFM_CREATE_CATALOG : status = <0x%.8x>\n", status));
        break;

    case NFM_DELETE_CATALOG :
        _NFMSdebug((fname, "NFM_DELETE_CATALOG = <%ld>\n", in_command));
        status = NFMSdelete_catalog (in_list);
        _NFMSdebug((fname, "NFM_DELETE_CATALOG : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_ADD_ITEM :
        _NFMSdebug((fname, "NFM_QUERY_ADD_ITEM = <%ld>\n", in_command));
        status = NFMSquery_add_item_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ADD_ITEM : status = <0x%.8x>\n", status));
        break;

    case NFM_ADD_ITEM :
        _NFMSdebug((fname, "NFM_ADD_ITEM = <%ld>\n", in_command));
        status = NFMSadd_item (in_list);
        _NFMSdebug((fname, "NFM_ADD_ITEM : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_ITEM_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_ITEM_ATTR = <%ld>\n", in_command));
        status = NFMSquery_item_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ITEM_ATTR : status = <0x%.8x>\n", status));
        break;

    case NFM_REVIEW_ITEM_STATE :
        _NFMSdebug((fname, "NFM_REVIEW_ITEM_STATE = <%ld>\n", in_command));
        status = NFMSreview_state (in_list);
        _NFMSdebug((fname, "NFM_REVIEW_ITEM_STATE : status = <0x%.8x>\n", status));
        break;

    case NFM_DELETE_ITEM :
        _NFMSdebug((fname, "NFM_DELETE_ITEM = <%ld>\n", in_command));
        status = NFMSdelete_item (in_list);
        _NFMSdebug((fname, "NFM_DELETE_ITEM : status = <0x%.8x>\n", status));
        break;

    case NFM_LOCK_ITEM :
        _NFMSdebug((fname, "NFM_LOCK_ITEM = <%ld>\n", in_command));
        status = NFMSlock_item (in_list);
        _NFMSdebug((fname, "NFM_LOCK_ITEM : status = <0x%.8x>\n", status));
        break;

    case NFM_UNLOCK_ITEM :
        _NFMSdebug((fname, "NFM_UNLOCK_ITEM = <%ld>\n", in_command));
        status = NFMSunlock_item (in_list);
        _NFMSdebug((fname, "NFM_UNLOCK_ITEM : status = <0x%.8x>\n", status));
        break;

    case NFM_CHANGE_WF_ITEM :
        _NFMSdebug((fname, "NFM_CHANGE_WF_ITEM = <%ld>\n", in_command));
        status = NFMSchange_wf_item (in_list);
        _NFMSdebug((fname,"NFM_CHANGE_WF_ITEM : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_ADD_SET :
        _NFMSdebug((fname, "NFM_QUERY_ADD_SET = <%ld>\n", in_command));
        status = NFMSquery_add_set_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ADD_SET : status = <0x%.8x>\n", status));
        break;


    case NFM_QUERY_SET_MEMBERS :
        _NFMSdebug((fname, "NFM_QUERY_SET_MEMBERS = <%ld>\n", in_command));
        status = NFMSquery_set_members (in_list);
        _NFMSdebug((fname, "NFM_QUERY_SET_MEMBERS : status = <0x%.8x>\n", status));
        break;

    case NFM_QRY_SET_MEMBERS :
        _NFMSdebug((fname, "NFM_QRY_SET_MEMBERS = <%ld>\n", in_command));
        status = NFMSqry_set_members (in_list);
        _NFMSdebug((fname, "NFM_QRY_SET_MEMBERS : status = <0x%.8x>\n", status));
        break;
    case NFM_UPDATE_SET_MEMBERS :
        _NFMSdebug((fname, "NFM_UPDATE_SET_MEMBERS= <%ld>\n", in_command));
        status = NFMSupdate_set_members (in_list);
        _NFMSdebug((fname, "NFM_UPDATE_SET_MEMBERS : status = <0x%.8x>\n", status));
        break;

    case NFM_PREPARE_ITEM_CHECKIN :
        _NFMSdebug((fname, "NFM_PREPARE_ITEM_CHECKIN = <%ld>\n", in_command));
        status = NFMSprepare_item_checkin (in_list);
        _NFMSdebug((fname, "NFM_PREPARE_ITEM_CHECKIN : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_ITEM_CHECKIN :
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_CHECKIN = <%ld>\n", in_command));
        status = NFMScancel_item_checkin (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_CHECKIN : status = <0x%.8x>\n", status));
        break;

    case NFM_COMPLETE_ITEM_CHECKIN :
        _NFMSdebug((fname, "NFM_COMPLETE_ITEM_CHECKIN = <%ld>\n", in_command));
        status = NFMScomplete_item_checkin (in_list);
        _NFMSdebug((fname, "NFM_COMPLETE_ITEM_CHECKIN : status = <0x%.8x>\n", status));
        break;

    case NFM_PREPARE_ITEM_CHECKOUT :
        _NFMSdebug((fname, "NFM_PREPARE_ITEM_CHECKOUT = <%ld>\n", in_command));
        status = NFMSprepare_item_checkout (in_list);
        _NFMSdebug((fname, "NFM_PREPARE_ITEM_CHECKOUT : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_CHECKOUT_ITEM :
        _NFMSdebug((fname, "NFM_CANCEL_CHECKOUT_ITEM = <%ld>\n", 
		    in_command));
        status = NFMScancel_co_item (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_CHECKOUT_ITEM : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_CANCEL_CHECK_OUT_ITEM :
        _NFMSdebug((fname, "NFM_CANCEL_CHECK_OUT_ITEM = <%ld>\n", 
		    in_command));
        status = NFMScancel_check_out_item (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_CHECK_OUT_ITEM : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_CANCEL_ITEM_CHECKOUT :
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_CHECKOUT = <%ld>\n", 
		    in_command));
        status = NFMScancel_item_checkout (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_CHECKOUT : status = <0x%.8x>\n", status));
        break;

    case NFM_COMPLETE_ITEM_CHECKOUT :
        _NFMSdebug((fname, "NFM_COMPLETE_ITEM_CHECKOUT = <%ld>\n", in_command));
        status = NFMScomplete_item_checkout (in_list);
        _NFMSdebug((fname, "NFM_COMPLETE_ITEM_CHECKOUT : status = <0x%.8x>\n", status));
        break;

    case NFM_PREPARE_ITEM_COPY :
        _NFMSdebug((fname, "NFM_PREPARE_ITEM_COPY = <%ld>\n", in_command));
        status = NFMSprepare_item_copy (in_list);
        _NFMSdebug((fname, "NFM_PREPARE_ITEM_COPY : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_ITEM_COPY :
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_COPY = <%ld>\n", in_command));
        status = NFMScancel_item_copy (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_COPY : status = <0x%.8x>\n", status));
        break;

    case NFM_COMPLETE_ITEM_COPY :
        _NFMSdebug((fname, "NFM_COMPLETE_ITEM_COPY = <%ld>\n", in_command));
        status = NFMScomplete_item_copy (in_list);
        _NFMSdebug((fname, "NFM_COMPLETE_ITEM_COPY : status = <0x%.8x>\n", status));
        break;

    case NFM_PREPARE_UPDATE_ITEM :
        _NFMSdebug((fname, "NFM_PREPARE_UPDATE_ITEM = <%ld>\n", in_command));
        status = NFMSprepare_update_item (in_list);
        _NFMSdebug((fname, "NFM_PREPARE_UPDATE_ITEM : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_UPDATE_ITEM :
        _NFMSdebug((fname, "NFM_CANCEL_UPDATE_ITEM = <%ld>\n", in_command));
        status = NFMScancel_update_item (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_UPDATE_ITEM : status = <0x%.8x>\n", status));
        break;

    case NFM_UPDATE_ITEM :
        _NFMSdebug((fname, "NFM_UPDATE_ITEM = <%ld>\n", in_command));
        status = NFMSupdate_item (in_list);
        _NFMSdebug((fname, "NFM_UPDATE_ITEM : status = <0x%.8x>\n", status));
        break;

    case NFM_PREPARE_SET_CHECKIN :
        _NFMSdebug((fname, "NFM_PREPARE_SET_CHECKIN = <%ld>\n", in_command));
        status = NFMSprepare_set_checkin (in_list);
        _NFMSdebug((fname, "NFM_PREPARE_SET_CHECKIN : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_SET_CHECKIN :
        _NFMSdebug((fname, "NFM_CANCEL_SET_CHECKIN = <%ld>\n", in_command));
        status = NFMScancel_set_checkin (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_SET_CHECKIN : status = <0x%.8x>\n", status));
        break;

    case NFM_COMPLETE_SET_CHECKIN :
        _NFMSdebug((fname, "NFM_COMPLETE_SET_CHECKIN = <%ld>\n", in_command));
        status = NFMScomplete_set_checkin (in_list);
        _NFMSdebug((fname, "NFM_COMPLETE_SET_CHECKIN : status = <0x%.8x>\n", status));
        break;

    case NFM_PREPARE_SET_CHECKOUT :
        _NFMSdebug((fname, "NFM_PREPARE_SET_CHECKOUT = <%ld>\n", in_command));
        status = NFMSprepare_set_checkout (in_list);
        _NFMSdebug((fname, "NFM_PREPARE_SET_CHECKOUT : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_SET_CHECKOUT :
        _NFMSdebug((fname, "NFM_CANCEL_SET_CHECKOUT = <%ld>\n", in_command));
        status = NFMScancel_set_checkout (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_SET_CHECKOUT : status = <0x%.8x>\n", status));
        break;

    case NFM_COMPLETE_SET_CHECKOUT :
        _NFMSdebug((fname, "NFM_COMPLETE_SET_CHECKOUT = <%ld>\n", in_command));
        status = NFMScomplete_set_checkout (in_list);
        _NFMSdebug((fname, "NFM_COMPLETE_SET_CHECKOUT : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_CHECKOUT_SET :
        _NFMSdebug((fname, "NFM_CANCEL_CHECKOUT_SET= <%ld>\n", in_command));
        status = NFMScancel_co_set (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_CHECKOUT_SET : status = <0x%.8x>\n", 
		    status));
        break;

    case NFM_CANCEL_CHECK_OUT_SET :
        _NFMSdebug((fname, "NFM_CANCEL_CHECK_OUT_SET= <%ld>\n", in_command));
        status = NFMScancel_check_out_set (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_CHECK_OUT_SET : status = <0x%.8x>\n", 
		    status));
        break;

    case NFM_PREPARE_SET_COPY :
        _NFMSdebug((fname, "NFM_PREPARE_SET_COPY = <%ld>\n", in_command));
        status = NFMSprepare_set_copy (in_list);
        _NFMSdebug((fname, "NFM_PREPARE_SET_COPY : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_SET_COPY :
        _NFMSdebug((fname, "NFM_CANCEL_SET_COPY = <%ld>\n", in_command));
        status = NFMScancel_set_copy (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_SET_COPY : status = <0x%.8x>\n", status));
        break;

    case NFM_COMPLETE_SET_COPY :
        _NFMSdebug((fname, "NFM_COMPLETE_SET_COPY = <%ld>\n", in_command));
        status = NFMScomplete_set_copy (in_list);
        _NFMSdebug((fname, "NFM_COMPLETE_SET_COPY : status = <0x%.8x>\n", status));
        break;

    case NFM_FLAG_ITEM_ARCHIVE :
        _NFMSdebug((fname, "NFM_FLAG_ITEM_ARCHIVE = <%ld>\n", in_command));
        status = NFMSflag_item_archive (in_list);
        _NFMSdebug((fname, "NFM_FLAG_ITEM_ARCHIVE : status = <0x%.8x>\n", status));
        break;

    case NFM_FLAG_ITEM_BACKUP :
        _NFMSdebug((fname, "NFM_FLAG_ITEM_BACKUP = <%ld>\n", in_command));
        status = NFMSflag_item_backup (in_list);
        _NFMSdebug((fname, "NFM_FLAG_ITEM_BACKUP : status = <0x%.8x>\n", status));
        break;

    case NFM_FLAG_ITEM_RESTORE :
        _NFMSdebug((fname, "NFM_FLAG_ITEM_RESTORE = <%ld>\n", in_command));
        status = NFMSflag_item_restore (in_list);
        _NFMSdebug((fname, "NFM_FLAG_ITEM_RESTORE : status = <0x%.8x>\n", status));
        break;

    case NFM_FLAG_ITEM_DELETE :
        _NFMSdebug((fname, "NFM_FLAG_ITEM_DELETE = <%ld>\n", in_command));
        status = NFMSflag_item_delete (in_list);
        _NFMSdebug((fname, "NFM_FLAG_ITEM_DELETE : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_ITEM_ARCHIVE_FLAG :
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_ARCHIVE_FLAG = <%ld>\n", 
			in_command));
        status = NFMScancel_item_archive_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_ARCHIVE_FLAG : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_ITEM_BACKUP_FLAG :
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_BACKUP_FLAG = <%ld>\n", 
			in_command));
        status = NFMScancel_item_backup_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_BACKUP_FLAG : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_ITEM_RESTORE_FLAG :
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_RESTORE_FLAG = <%ld>\n", in_command));
        status = NFMScancel_item_restore_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_RESTORE_FLAG : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_ITEM_DELETE_FLAG :
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_DELETE_FLAG = <%ld>\n", in_command));
        status = NFMScancel_item_delete_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_ITEM_DELETE_FLAG : status = <0x%.8x>\n", status));
        break;

    case NFM_FLAG_SET_ARCHIVE :
        _NFMSdebug((fname, "NFM_FLAG_SET_ARCHIVE = <%ld>\n", in_command));
        status = NFMSflag_set_archive (in_list);
        _NFMSdebug((fname, "NFM_FLAG_SET_ARCHIVE : status = <0x%.8x>\n", status));
        break;

    case NFM_FLAG_SET_BACKUP :
        _NFMSdebug((fname, "NFM_FLAG_SET_BACKUP = <%ld>\n", in_command));
        status = NFMSflag_set_backup (in_list);
        _NFMSdebug((fname, "NFM_FLAG_SET_BACKUP : status = <0x%.8x>\n", status));
        break;

    case NFM_FLAG_SET_RESTORE :
        _NFMSdebug((fname, "NFM_FLAG_SET_RESTORE = <%ld>\n", in_command));
        status = NFMSflag_set_restore (in_list);
        _NFMSdebug((fname, "NFM_FLAG_SET_RESTORE : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_SET_ARCHIVE_FLAG :
        _NFMSdebug((fname, "NFM_CANCEL_SET_ARCHIVE_FLAG = <%ld>\n", in_command));
        status = NFMScancel_set_archive_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_SET_ARCHIVE_FLAG : status = <0x%.8x>\n",
		status));
        break;

    case NFM_CANCEL_SET_BACKUP_FLAG :
        _NFMSdebug((fname, "NFM_CANCEL_SET_BACKUP_FLAG = <%ld>\n", 
		in_command));
        status = NFMScancel_set_backup_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_SET_BACKUP_FLAG : status = <0x%.8x>\n",
		status));
        break;

    case NFM_CANCEL_SET_RESTORE_FLAG :
        _NFMSdebug((fname,"NFM_CANCEL_SET_RESTORE_FLAG = <%ld>\n",in_command));
        status = NFMScancel_set_restore_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_SET_RESTORE_FLAG : status = <0x%.8x>\n",
		status));
        break;

    case NFM_QUERY_FLAG_ARCHIVE :
        _NFMSdebug((fname, "NFM_QUERY_FLAG_ARCHIVE = <%ld>\n",
		    in_command));
        status = NFMSquery_flag_archive (in_list );
        _NFMSdebug((fname, "NFM_QUERY_FLAG_ARCHIVE : status = <0x%.8x>",
		    status));
        break;

    case NFM_QUERY_FLAG_BACKUP :
        _NFMSdebug((fname, "NFM_QUERY_FLAG_BACKUP = <%ld>\n", 
		    in_command));
        status = NFMSquery_flag_backup (in_list );
        _NFMSdebug((fname, "NFM_QUERY_FLAG_BACKUP : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_QUERY_FLAG_RESTORE :
        _NFMSdebug((fname, "NFM_QUERY_FLAG_RESTORE = <%ld>\n",
		    in_command));
        status = NFMSquery_flag_restore (in_list );
        _NFMSdebug((fname, "NFM_QUERY_FLAG_RESTORE : status = <0x%.8x>",
		    status));
        break;

    case NFM_QRY_FLAG_RESTORE :
        _NFMSdebug((fname, "NFM_QRY_FLAG_RESTORE = <%ld>\n", in_command));
        status = NFMSnew_query_flag_restore (in_list );
        _NFMSdebug((fname, "NFM_QRY_FLAG_RESTORE : status = <0x%.8x>",
		    status));
        break;

    case NFM_QUERY_FLAG_DELETE :
        _NFMSdebug((fname, "NFM_QUERY_FLAG_DELETE = <%ld>\n", in_command));
        status = NFMSquery_flag_delete (in_list );
        _NFMSdebug((fname, "NFM_QUERY_FLAG_DELETE : status = <0x%.8x>",
		    status));
        break;

    case NFM_ARCHIVE :
        _NFMSdebug((fname, "NFM_ARCHIVE = <%ld>\n", in_command));
        status = NFMSquery_archive (in_list);
        _NFMSdebug((fname, "NFM_ARCHIVE : status = <0x%.8x>\n", status));
        break;

    case NFM_BACKUP :
        _NFMSdebug((fname, "NFM_BACKUP = <%ld>\n", in_command));
        status = NFMSquery_backup (in_list);
        _NFMSdebug((fname, "NFM_BACKUP : status = <0x%.8x>\n", status));
        break;

    case NFM_RESTORE :
        _NFMSdebug((fname, "NFM_RESTORE = <%ld>\n", in_command));
        status = NFMSquery_restore (in_list);
        _NFMSdebug((fname, "NFM_RESTORE : status = <0x%.8x>\n", status));
        break;

    case NFM_UTIL_DELETE :
        _NFMSdebug((fname, "NFM_DELETE = <%ld>\n", in_command));
        status = NFMSquery_delete (in_list);
        _NFMSdebug((fname, "NFM_DELETE : status = <0x%.8x>\n", status));
        break;

    case NFM_ARCHIVE_FILE :
        _NFMSdebug((fname, "NFM_ARCHIVE_FILE = <%ld>\n", in_command));
        status = NFMSarchive_files (in_list );
        _NFMSdebug((fname, "NFM_ARCHIVE_FILE : status = <0x%.8x>\n", status));
        break;

    case NFM_BACKUP_FILE :
        _NFMSdebug((fname, "NFM_BACKUP_FILE = <%ld>\n", in_command));
        status = NFMSbackup_files (in_list);
        _NFMSdebug((fname, "NFM_BACKUP_FILE : status = <0x%.8x>\n", status));
        break;

    case NFM_RESTORE_FILE :
        _NFMSdebug((fname, "NFM_RESTORE_FILE = <%ld>\n", in_command));
        status = NFMSrestore_files (in_list);
        _NFMSdebug((fname, "NFM_RESTORE_FILE : status = <0x%.8x>\n", status));
        break;

    case NFM_DEL_FILES :
        _NFMSdebug((fname, "NFM_DELETE_FILES = <%ld>\n", in_command));
        status = NFMSdelete_files (in_list);
        _NFMSdebug((fname, "NFM_DELETE_FILES : status = <0x%.8x>\n", status));
        break;

    case NFM_UTILITIES_UPDATE :
        _NFMSdebug((fname, "NFM_UTILITIES_UPDATE = <%ld>\n", in_command));
        status = NFMSutilities_update (in_list);
        _NFMSdebug((fname, "NFM_UTILITIES_UPDATE : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_SAVESETS :
        _NFMSdebug((fname, "NFM_QUERY_SAVESETS = <%ld>\n", in_command));
        status = NFMSquery_savesets_to_delete (in_list);
        _NFMSdebug((fname, "NFM_QUERY_SAVESETS : status = <0x%.8x>\n",status));
        break;

    case NFM_QUERY_ARCHIVES :
        _NFMSdebug((fname, "NFM_QUERY_ARCHIVES = <%ld>\n", in_command));
        status = NFMSquery_archives_to_delete (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ARCHIVES : status = <0x%.8x>\n",status));
        break;

    case NFM_QUERY_CHANGE_LOC_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_LOC_ATTR = <%ld>\n", in_command));
        status = NFMSquery_changeto_loc_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_LOC_ATTR : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_CHANGE_CATALOG_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_CATALOG_ATTR = <%ld>\n", in_command));
        status = NFMSquery_change_catalog_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_CATALOG_ATTR : status = <0x%.8x>\n", status));
        break;

    case NFM_CHANGE_CATALOG :
        _NFMSdebug((fname, "NFM_CHANGE_CATALOG = <%ld>\n", in_command));
        status = NFMSchange_catalog (in_list);
        _NFMSdebug((fname, "NFM_CHANGE_CATALOG : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_CHANGE_TABLE_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_TABLE_ATTR = <%ld>\n", in_command));
        status = NFMSquery_change_table_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_CATALOG_ATTR : status = <0x%.8x>\n", status));
        break;

    case NFM_CHANGE_TABLE :
        _NFMSdebug((fname, "NFM_CHANGE_TABLE = <%ld>\n", in_command));
        status = NFMSchange_table (in_list);
        _NFMSdebug((fname, "NFM_CHANGE_TABLE : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_TABLE_TEMP :
        _NFMSdebug((fname, "NFM_QUERY_TABLE_TEMP = <%ld>\n", in_command));
        status = NFMSquery_table_template (in_list);
        _NFMSdebug((fname, "NFM_QUERY_TABLE_TEMP : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_TABLE_DEF :
        _NFMSdebug((fname, "NFM_QUERY_TABLE_DEF = <%ld>\n", in_command));
        status = NFMSquery_table_definition (in_list);
        _NFMSdebug((fname, "NFM_QUERY_TABLE_DEF : status = <0x%.8x>\n", status));
        break;
 
    case NFM_QUERY_ADDTO_LOP_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_ADDTO_LOP_ATTR = <%ld>\n", in_command));
        status = NFMSquery_addto_lop_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ADDTO_LOP_ATTR : status = <0x%.8x>\n", status));
        break;

    case NFM_ADD_PROJECT :
        _NFMSdebug((fname, "NFM_ADD_PROJECT = <%ld>\n", in_command));
        status = NFMSadd_project (in_list);
        _NFMSdebug((fname, "NFM_ADD_PROJECT : status = <0x%.8x>\n", status));
        break;

    case NFM_DELETE_PROJECT :
        _NFMSdebug((fname, "NFM_DELETE_PROJECT = <%ld>\n", in_command));
        status = NFMSdelete_project (in_list);
        _NFMSdebug((fname, "NFM_DELETE_PROJECT : status = <0x%.8x>\n", status));
        break;

    case NFM_FLAG_PROJECT_ARCHIVE :
        _NFMSdebug((fname, "NFM_FLAG_PROJECT_ARCHIVE = <%ld>\n", in_command));
        status = NFMSflag_project_archive (in_list);
        _NFMSdebug((fname, "NFM_FLAG_PROJECT_ARCHIVE : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_FLAG_PROJECT_BACKUP :
        _NFMSdebug((fname, "NFM_FLAG_PROJECT_BACKUP = <%ld>\n", in_command));
        status = NFMSflag_project_backup (in_list);
        _NFMSdebug((fname, "NFM_FLAG_PROJECT_BACKUP : status = <0x%.8x>\n", 
		    status));
        break;

    case NFM_FLAG_PROJECT_RESTORE :
        _NFMSdebug((fname, "NFM_FLAG_PROJECT_RESTORE = <%ld>\n", in_command));
        status = NFMSflag_project_restore (in_list);
        _NFMSdebug((fname, "NFM_FLAG_PROJECT_RESTORE : status = <0x%.8x>\n", 
		    status));
        break;

    case NFM_CANCEL_PROJECT_ARCHIVE :
        _NFMSdebug((fname, "NFM_CANCEL_PROJECT_ARCHIVE_FLAG = <%ld>\n", in_command));
        status = NFMScancel_project_archive_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_PROJECT_ARCHIVE_FLAG : status = <0x%.8x>\n", status));
        break;

    case NFM_CANCEL_PROJECT_BACKUP :
        _NFMSdebug((fname, "NFM_CANCEL_PROJECT_BACKUP_FLAG = <%ld>\n", 
		in_command));
        status = NFMScancel_project_backup_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_PROJECT_BACKUP_FLAG : status = <0x%.8x>\n",status));
        break;

    case NFM_CANCEL_PROJECT_RESTORE :
        _NFMSdebug((fname, "NFM_CANCEL_PROJECT_RESTORE_FLAG = <%ld>\n", in_command));
        status = NFMScancel_project_restore_flag (in_list);
        _NFMSdebug((fname, "NFM_CANCEL_PROJECT_RESTORE_FLAG : status = <0x%.8x>\n",status));
        break;

    case NFM_QUERY_CHANGE_LOP_ATTR :
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_LOP_ATTR = <%ld>\n", in_command));
        status = NFMSquery_changeto_lop_attributes (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CHANGE_LOP_ATTR : status = <0x%.8x>\n", status));
        break;

    case NFM_CHANGE_PROJECT :
        _NFMSdebug((fname, "NFM_CHANGE_PROJECT = <%ld>\n", in_command));
        status = NFMSchange_project (in_list);
        _NFMSdebug((fname, "NFM_CHANGE_PROJECT : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_PROJ_ACL_MAP :
        _NFMSdebug((fname, "NFM_QUERY_PROJ_ACL_MAP = <%ld>\n", in_command));
        status = NFMSquery_project_acl_map (in_list);
        _NFMSdebug((fname, "NFM_QUERY_PROJ_ACL_MAP : status = <0x%.8x>\n", status));
        break;

    case NFM_UPDATE_PROJ_ACL_MAP :
        _NFMSdebug((fname, "NFM_UPDATE_PROJ_ACL_MAP = <%ld>\n", in_command));
        status = NFMSupdate_project_acl_map (in_list);
        _NFMSdebug((fname, "NFM_UPDATE_PROJ_ACL_MAP : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_PROJ_SA_MAP :
        _NFMSdebug((fname, "NFM_QUERY_PROJ_SA_MAP = <%ld>\n", in_command));
        status = NFMSquery_project_sa_map (in_list);
        _NFMSdebug((fname, "NFM_QUERY_PROJ_SA_MAP : status = <0x%.8x>\n", status));
        break;

    case NFM_UPDATE_PROJ_SA_MAP :
        _NFMSdebug((fname, "NFM_UPDATE_PROJ_SA_MAP = <%ld>\n", in_command));
        status = NFMSupdate_project_sa_map (in_list);
        _NFMSdebug((fname, "NFM_UPDATE_PROJ_SA_MAP : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_PROJ_MEM :
        _NFMSdebug((fname, "NFM_QUERY_PROJ_MEM = <%ld>\n", in_command));
        status = NFMSquery_project_members (in_list);
        _NFMSdebug((fname, "NFM_QUERY_PROJ_MEM : status = <0x%.8x>\n", status));
        break;

    case NFM_QRY_PROJ_MEM :
        _NFMSdebug((fname, "NFM_QRY_PROJ_MEM = <%ld>\n", in_command));
        status = NFMSqry_project_members (in_list);
        _NFMSdebug((fname, "NFM_QRY_PROJ_MEM : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_ITEMS_FOR_PROJ :
        _NFMSdebug((fname, "NFM_QUERY_ITEMS_FOR_PROJ = <%ld>\n", in_command));
        status = NFMSqry_items_in_cat_for_project (in_list);
        _NFMSdebug((fname, "NFM_QUERY_ITEMS_FOR_PROJ : status = <0x%.8x>\n", status));
        break;

    case NFM_UPDATE_PROJ_MEM :
        _NFMSdebug((fname, "NFM_UPDATE_PROJ_MEM = <%ld>\n", in_command));
        status = NFMSupdate_project_members (in_list);
        _NFMSdebug((fname, "NFM_UPDATE_PROJ_MEM : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_CAT_ACL_MAP :
        _NFMSdebug((fname, "NFM_QUERY_CAT_ACL_MAP = <%ld>\n", in_command));
        status = NFMSquery_catalog_acl_map (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CAT_ACL_MAP : status = <0x%.8x>\n", status));
        break;

    case NFM_UPDATE_CAT_ACL_MAP :
        _NFMSdebug((fname, "NFM_UPDATE_CAT_ACL_MAP = <%ld>\n", in_command));
        status = NFMSupdate_catalog_acl_map (in_list);
        _NFMSdebug((fname, "NFM_UPDATE_CAT_ACL_MAP : status = <0x%.8x>\n", status));
        break;

    case NFM_QUERY_CAT_SA_MAP :
        _NFMSdebug((fname, "NFM_QUERY_CAT_SA_MAP = <%ld>\n", in_command));
        status = NFMSquery_catalog_sa_map (in_list);
        _NFMSdebug((fname, "NFM_QUERY_CAT_SA_MAP : status = <0x%.8x>\n", status));
        break;

    case NFM_UPDATE_CAT_SA_MAP :
        _NFMSdebug((fname, "NFM_UPDATE_CAT_SA_MAP = <%ld>\n", in_command));
        status = NFMSupdate_catalog_sa_map (in_list);
        _NFMSdebug((fname, "NFM_UPDATE_CAT_SA_MAP : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_TABLE_NO :
        _NFMSdebug((fname, "NFM_GET_TABLE_NO = <%ld>\n", in_command));
        status = NFMSget_table_no (in_list);
        _NFMSdebug((fname, "NFM_GET_TABLE_NO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_TABLE_NAME :
        _NFMSdebug((fname, "NFM_GET_TABLE_NAME = <%ld>\n", in_command));
        status = NFMSget_table_name (in_list);
        _NFMSdebug((fname, "NFM_GET_TABLE_NAME : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_PROGRAM_NO :
        _NFMSdebug((fname, "NFM_GET_PROGRAM_NO = <%ld>\n", in_command));
        status = NFMSget_program_no (in_list);
        _NFMSdebug((fname, "NFM_GET_PROGRAM_NO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_PROGRAM_NAME :
        _NFMSdebug((fname, "NFM_GET_PROGRAM_NAME = <%ld>\n", in_command));
        status = NFMSget_program_name (in_list);
        _NFMSdebug((fname, "NFM_GET_PROGRAM_NAME : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_NODE_NO :
        _NFMSdebug((fname, "NFM_GET_NODE_NO = <%ld>\n", in_command));
        status = NFMSget_node_no (in_list);
        _NFMSdebug((fname, "NFM_GET_NODE_NO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_NODE_NAME :
        _NFMSdebug((fname, "NFM_GET_NODE_NAME = <%ld>\n", in_command));
        status = NFMSget_node_name (in_list);
        _NFMSdebug((fname, "NFM_GET_NODE_NAME : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_SA_NO :
        _NFMSdebug((fname, "NFM_GET_SA_NO = <%ld>\n", in_command));
        status = NFMSget_sa_no (in_list);
        _NFMSdebug((fname, "NFM_GET_SA_NO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_SA_NAME :
        _NFMSdebug((fname, "NFM_GET_SA_NAME = <%ld>\n", in_command));
        status = NFMSget_sa_name (in_list);
        _NFMSdebug((fname, "NFM_GET_SA_NAME : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_SA_NO_INFO :
        _NFMSdebug((fname, "NFM_GET_SA_NO_INFO = <%ld>\n", in_command));
        status = NFMSget_sa_no_info (in_list);
        _NFMSdebug((fname, "NFM_GET_SA_NO_INFO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_USER_NO :
        _NFMSdebug((fname, "NFM_GET_USER_NO = <%ld>\n", in_command));
        status = NFMSget_user_no (in_list);
        _NFMSdebug((fname, "NFM_GET_USER_NO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_USER_NAME :
        _NFMSdebug((fname, "NFM_GET_USER_NAME = <%ld>\n", in_command));
        status = NFMSget_user_name (in_list);
        _NFMSdebug((fname, "NFM_GET_USER_NAME : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_CATALOG_NO :
        _NFMSdebug((fname, "NFM_GET_CATALOG_NO = <%ld>\n", in_command));
        status = NFMSget_catalog_no (in_list);
        _NFMSdebug((fname, "NFM_GET_CATALOG_NO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_CATALOG_NAME :
        _NFMSdebug((fname, "NFM_GET_CATALOG_NAME = <%ld>\n", in_command));
        status = NFMSget_catalog_name (in_list);
        _NFMSdebug((fname, "NFM_GET_CATALOG_NAME : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_PROJECT_NO :
        _NFMSdebug((fname, "NFM_GET_PROJECT_NO = <%ld>\n", in_command));
        status = NFMSget_project_no (in_list);
        _NFMSdebug((fname, "NFM_GET_PROJECT_NO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_PROJECT_NAME :
        _NFMSdebug((fname, "NFM_GET_PROJECT_NAME = <%ld>\n", in_command));
        status = NFMSget_project_name (in_list);
        _NFMSdebug((fname, "NFM_GET_PROJECT_NAME : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_ITEM_NO :
        _NFMSdebug((fname, "NFM_GET_ITEM_NO = <%ld>\n", in_command));
        status = NFMSget_item_no (in_list);
        _NFMSdebug((fname, "NFM_GET_ITEM_NO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_ITEM_NAME :
        _NFMSdebug((fname, "NFM_GET_ITEM_NAME = <%ld>\n", in_command));
        status = NFMSget_item_name (in_list);
        _NFMSdebug((fname, "NFM_GET_ITEM_NAME : status = <0x%.8x>\n", status));
        break;

     case NFM_GET_KEYWORDS_FOR_FILES :
         _NFMSdebug((fname,   "NFM_GET_KEYWORDS_FOR_FILES = <%ld>\n", 
                  in_command));
         status = NFMSget_keywords_for_files (in_list);
         _NFMSdebug((fname, "NFM_GET_KEYWORDS_FOR_FILES : status = <0x%.8x>\n",
                  status))
         break;

    case NFM_CHECK_CO_STATUS :
        _NFMSdebug((fname, "NFM_CHECK_CO_STATUS = <%ld>\n", in_command));
        status = NFMScheck_co_status (in_list);
        _NFMSdebug((fname, "NFM_CHECK_CO_STATUS : status = <0x%.8x>\n", status));
        break;

    case NFM_VALIDATE_INFO :
        _NFMSdebug((fname, "NFM_VALIDATE_INFO = <%ld>\n", in_command));
        status = NFMSvalidate_info (in_list);
        _NFMSdebug((fname, "NFM_VALIDATE_INFO : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_USER_DEFAULTS :
        _NFMSdebug((fname, "NFM_GET_USER_DEFAULTS = <%ld>\n", in_command));
        status = NFMSget_user_defaults (in_list);
        _NFMSdebug((fname, "NFM_GET_USER_DEFAULTS : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_READ_USER_DEFAULTS :
        _NFMSdebug((fname, "NFM_READ_USER_DEFAULTS = <%ld>\n", in_command));
        status = NFMSread_user_defaults (in_list);
        _NFMSdebug((fname, "NFM_READ_USER_DEFAULTS : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_WRITE_USER_DEFAULTS : 
	_NFMSdebug((fname, "NFM_WRITE_USER_DEFAULTS = <%ld>\n", in_command));
        status = NFMSwrite_user_defaults (in_list);
        _NFMSdebug((fname, "NFM_WRITE_USER_DEFAULTS : status = <0x%.8x>\n",
		    status));
        break;

    case NFM_SET_USER_DEFAULTS :
        _NFMSdebug((fname, "NFM_SET_USER_DEFAULTS = <%ld>\n", in_command));
        status = NFMSset_user_defaults (in_list);
        _NFMSdebug((fname, "NFM_SET_USER_DEFAULTS : status = <0x%.8x>\n", 
		    status));
        break;

    case NFM_GET_BULK_DATA :
        _NFMSdebug((fname, "NFM_GET_BULK_DATA = <%ld>\n", in_command));
        status = NFMSget_bulk_data (in_list);
        _NFMSdebug((fname, "NFM_GET_BULK_DATA : status = <0x%.8x>\n",  status));
        break;

    case NFM_GET_RIS_ATTRIBUTES :
        _NFMSdebug((fname, "NFM_RIS_ATTRIBUTES = <%ld>\n", in_command));
        status = NFMSget_ris_attributes (in_list);
        _NFMSdebug((fname, "NFM_GET_RIS_ATTRIBUTES : status = <0x%.8x>\n",  status));
        break;

    case NFM_SQL_QUERY :
        _NFMSdebug((fname, "NFM_SQL_QUERY = <%ld>\n", in_command));
        status = NFMSsqlquery (in_list);
        _NFMSdebug((fname, "NFM_SQL_QUERY : status = <0x%.8x>\n", status));
        break;

    case NFM_SQL_QUERY_PARTIAL :
        _NFMSdebug((fname, "NFM_SQL_QUERY_CURSOR = <%ld>\n", in_command));
        status = NFMSsqlquery_cursor (in_list);
        _NFMSdebug((fname, "NFM_SQL_QUERY_CURSOR : status = <0x%.8x>\n", 
			status));
        break;

    case NFM_SQL_STMT :
        _NFMSdebug((fname, "NFM_SQL_STMT = <%ld>\n", in_command));
        status = NFMSsqlstmt (in_list);
        _NFMSdebug((fname, "NFM_SQL_STMT : status = <0x%.8x>\n", status));
        break;

      case NFM_CLIENT_INFO :
        _NFMSdebug((fname, "NFM_CLIENT_INFO = <%ld>\n", in_command));
        status = NFMSclient_info (in_list ) ;
        _NFMSdebug((fname, "NFM_CLIENT_INFO : status = <0x%.8x>\n",
		    status));
        break ;

    case NFM_SET_WF_STATE :
        _NFMSdebug((fname, "NFM_SET_WF_STATE = <%ld>\n", in_command));
        status = NFMSset_wf_state (in_list);
        _NFMSdebug((fname, "NFM_SET_WF_STATE : status = <0x%.8x>\n", status));
        break;

    case NFM_VALID_DATE :
        _NFMSdebug((fname, "NFM_VALID_DATE = <%ld>\n", in_command));
        status = NFMSvalidate_and_format_date (in_list);
        _NFMSdebug((fname, "NFM_VALID_DATE : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_DATE_INFO :
        _NFMSdebug((fname, "NFM_VALID_DATE = <%ld>\n", in_command));
        status = NFMSget_date_info (in_list);
        _NFMSdebug((fname, "NFM_VALID_DATE : status = <0x%.8x>\n", status));
        break;

    case NFM_GET_SET_MESSAGES :
        _NFMSdebug((fname, "NFM_GET_SET_MESSAGES = <%ld>\n", in_command));
        status = NFMSget_set_messages (in_list);
        _NFMSdebug((fname, "NFM_GET_SET_MESSAGES : status = <0x%.8x>\n",
			status));
        break;

    case WF_GET_COMMAND_NO :
        _NFMSdebug((fname, "WF_GET_COMMAND_NO = <%ld>\n", in_command));
        status = NFMSget_command_no (in_list);
        _NFMSdebug((fname, "NFM_GET_COMMAND_NO : status = <0x%.8x>\n", status));
        break;

    case WF_GET_COMMAND_NAME :
        _NFMSdebug((fname, "WF_GET_COMMAND_NAME = <%ld>\n", in_command));
        status = NFMSget_command_name (in_list);
        _NFMSdebug((fname, "WF_GET_COMMAND_NAME : status = <0x%.8x>\n", status));
        break;

    case WF_GET_WORKFLOW_NO :
        _NFMSdebug((fname, "WF_GET_WORKFLOW_NO = <%ld>\n", in_command));
        status = NFMSget_workflow_no (in_list);
        _NFMSdebug((fname, "WF_GET_WORKFLOW_NO : status = <0x%.8x>\n", status));
        break;

    case WF_GET_WORKFLOW_NAME :
        _NFMSdebug((fname, "WF_GET_WORKFLOW_NAME = <%ld>\n", in_command));
        status = NFMSget_workflow_name (in_list);
        _NFMSdebug((fname, "WF_GET_WORKFLOW_NAME : status = <0x%.8x>\n", status));
        break;

    case WF_GET_ACL_NO :
        _NFMSdebug((fname, "WF_GET_ACL_NO = <%ld>\n", in_command));
        status = NFMSget_acl_no (in_list);
        _NFMSdebug((fname, "WF_GET_ACL_NO : status = <0x%.8x>\n", status));
        break;

    case WF_GET_ACL_NAME :
        _NFMSdebug((fname, "WF_GET_ACL_NAME = <%ld>\n", in_command));
        status = NFMSget_acl_name (in_list);
        _NFMSdebug((fname, "WF_GET_ACL_NAME : status = <0x%.8x>\n", status));
        break;

    case WF_GET_STATE_NO :
        _NFMSdebug((fname, "WF_GET_STATE_NO = <%ld>\n", in_command));
        status = NFMSget_state_no (in_list);
        _NFMSdebug((fname, "WF_GET_STATE_NO : status = <0x%.8x>\n", status));
        break;

    case WF_GET_STATE_NAME :
        _NFMSdebug((fname, "WF_GET_STATE_NAME = <%ld>\n", in_command));
        status = NFMSget_state_name (in_list);
        _NFMSdebug((fname, "WF_GET_STATE_NAME : status = <0x%.8x>\n", status));
        break;

    case WF_GET_CLASS_NO :
        _NFMSdebug((fname, "WF_GET_CLASS_NO = <%ld>\n", in_command));
        status = NFMSget_class_no (in_list);
        _NFMSdebug((fname, "WF_GET_CLASS_NO : status = <0x%.8x>\n", status));
        break;

    case WF_GET_CLASS_NAME :
        _NFMSdebug((fname, "WF_GET_CLASS_NAME = <%ld>\n", in_command));
        status = NFMSget_class_name (in_list);
        _NFMSdebug((fname, "WF_GET_CLASS_NAME : status = <0x%.8x>\n", status));
        break;

    case WF_VALIDATE_USER :
        _NFMSdebug((fname, "WF_VALIDATE_USER = <%ld>\n", in_command));
        status = NFMSvalidate_user_access (in_list);
        _NFMSdebug((fname, "WF_VALIDATE_USER : status = <0x%.8x>\n", status));
        break;

    case WF_SET_TO_STATE :
        _NFMSdebug((fname, "WF_SET_TO_STATE = <%ld>\n", in_command));
        status = NFMSset_to_state (in_list);
        _NFMSdebug((fname, "WF_SET_TO_STATE : status = <0x%.8x>\n", status));
        break;

    case WF_OVERRIDE_STATE :
        _NFMSdebug((fname, "WF_OVERRIDE_STATE = <%ld>\n", in_command));
        status = NFMSupdate_state (in_list);
        _NFMSdebug((fname, "WF_OVERRIDE_STATE : status = <0x%.8x>\n", status));
        break;

    case WF_REVIEW_WORK_FLOW : /* for querying states */
        _NFMSdebug((fname, "WF_QUERY_STATES = <%ld>\n", in_command));
        status = NFMSquery_states (in_list);
        _NFMSdebug((fname, "WF_QUERY_STATES : status = <0x%.8x>\n", status));
        break;

    case WF_QUERY_MAKE_TRANSITION :
        _NFMSdebug((fname, "WF_QUERY_MAKE_TRANSITION = <%ld>\n", in_command));
        status = NFMSquery_make_transition (in_list);
        _NFMSdebug((fname, "WF_QUERY_MAKE_TRANSITION : status = <0x%.8x>\n", status));
        break;

    case WF_MAKE_TRANSITION :
        _NFMSdebug((fname, "WF_MAKE_TRANSITION = <%ld>\n", in_command));
        status = NFMSmake_transition (in_list);
        _NFMSdebug((fname, "WF_MAKE_TRANSITION : status = <0x%.8x>\n", status));
        break;

    case WF_QUERY_ADD_ACL :
        _NFMSdebug((fname, "WF_QUERY_ADD_ACL = <%ld>\n", in_command));
        status = NFMSquery_acl_attributes (in_list);
        _NFMSdebug((fname, "WF_QUERY_ADD_ACL : status = <0x%.8x>\n", status));
        break;

    case WF_ADD_ACL :
        _NFMSdebug((fname, "WF_ADD_ACL = <%ld>\n", in_command));
        status = NFMSadd_acl (in_list);
        _NFMSdebug((fname, "WF_ADD_ACL : status = <0x%.8x>\n", status));
        break;

    case WF_DELETE_ACL :
        _NFMSdebug((fname, "WF_DELETE_ACL = <%ld>\n", in_command));
        status = NFMSdelete_acl (in_list);
        _NFMSdebug((fname, "WF_DELETE_ACL : status = <0x%.8x>\n", status));
        break;

    case WF_QUERY_ADD_ACL_USER :
        _NFMSdebug((fname, "WF_QUERY_ADD_ACL_USER = <%ld>\n", in_command));
        status = NFMSquery_acl_class_users (in_list);
        _NFMSdebug((fname, "WF_QUERY_ADD_ACL_USER : status = <0x%.8x>\n", status));
        break;

    case WF_ADD_ACL_USER :
        _NFMSdebug((fname, "WF_ADD_ACL_USER = <%ld>\n", in_command));
        status = NFMSupdate_acl_class_users (in_list);
        _NFMSdebug((fname, "WF_ADD_ACL_USER : status = <0x%.8x>\n", status));
        break;

    case WF_QUERY_ADD_SIGNOFF_USER :
        _NFMSdebug((fname, "WF_QUERY_ADD_SIGNOFF_USER = <%ld>\n", in_command));
        status = NFMSquery_acl_signoff_users (in_list);
        _NFMSdebug((fname, "WF_QUERY_ADD_SIGNOFF_USER : status = <0x%.8x>\n", status));
        break;

    case WF_ADD_SIGNOFF_USER :
        _NFMSdebug((fname, "WF_ADD_SIGNOFF_USER = <%ld>\n", in_command));
        status = NFMSupdate_acl_signoff_users (in_list);
        _NFMSdebug((fname, "WF_ADD_SIGNOFF_USER : status = <0x%.8x>\n", status));
        break;

    case WF_QUERY_SIGNOFF_ATTR :
        _NFMSdebug((fname, "WF_QUERY_SIGNOFF_ATTR = <%ld>\n", in_command));
        status = NFMSquery_signoff_attributes (in_list);
        _NFMSdebug((fname, "WF_QUERY_SIGNOFF_ATTR : status = <0x%.8x>\n", status));
        break;

    case WF_SIGNOFF :
        _NFMSdebug((fname, "WF_SIGNOFF = <%ld>\n", in_command));
        status = NFMSsignoff (in_list);
        _NFMSdebug((fname, "WF_SIGNOFF : status = <0x%.8x>\n", status));
        break;

    case WF_PURGE_SIGNOFF :
        _NFMSdebug((fname, "PURGE_SIGNOFF = <%ld>\n", in_command));
        status = NFMSpurge_signoff (in_list);
        _NFMSdebug((fname, "PURGE_SIGNOFF : status = <0x%.8x>\n", status));
        break;

    case WF_LOAD_WORKFLOW :
        _NFMSdebug((fname, "WF_LOAD_WORKFLOW = <%ld>\n", in_command));
        status = NFMSload_workflow (in_list);
        _NFMSdebug((fname, "WF_LOAD_WORKFLOW : status = <0x%.8x>\n", status));
        break;

    case NFM_MULTI_BUFFER_MASTER :
        _NFMSdebug(( fname, "NFM_DISPLAY_MASTER = <%ld>\n", in_command));
        status = NFMSdisplay_master( in_list );
        _NFMSdebug(( fname, "NFM_DISPLAY_MASTER DONE status = <0x%.8x>\n",
		status));
	break;
  
    case NFM_DEFINE_QUERY : 
	_NFMSdebug(( fname, "NFM_DEFINE_QUERY = <%ld>\n", in_command ));
	status = NFMSdefine_query( in_list );
	_NFMSdebug(( fname, "NFM_DEFINE_QUERY DONE status = <0x%.8x>\n",
		status ));
	break;

    case NFM_DEFINE_FTR_QUERY : 
	_NFMSdebug(( fname, "NFM_DEFINE_FTR_QUERY = <%ld>\n", in_command ));
	status = NFMSdefine_ftr_query( in_list );
	_NFMSdebug(( fname, "NFM_DEFINE_FTR_QUERY DONE status = <0x%.8x>\n",
		status ));
	break;

    case NFM_RETRIEVE_QUERY : 
	_NFMSdebug(( fname, "NFM_RETRIEVE_QUERY = <%ld>\n", in_command ));
	status = NFMSretrieve_query( in_list );
	_NFMSdebug(( fname, "NFM_RETRIEVE_QUERY DONE status = <0x%.8x>\n",
		status ));
	break;

    case NFM_RETRIEVE_FTR_QUERY : 
	_NFMSdebug(( fname, "NFM_RETRIEVE_FTR_QUERY = <%ld>\n", in_command ));
	status = NFMSretrieve_ftr_query( in_list );
	_NFMSdebug(( fname, "NFM_RETRIEVE_FTR_QUERY DONE status = <0x%.8x>\n",
		status ));
	break;

    case NFM_DELETE_QUERY : 
	_NFMSdebug(( fname, "NFM_DELETE_QUERY = <%ld>\n", in_command ));
	status = NFMSdelete_query( in_list );
	_NFMSdebug(( fname, "NFM_DELETE_QUERY DONE status = <0x%.8x>\n",
		status ));
	break;

    case NFM_DELETE_FTR_QUERY : 
	_NFMSdebug(( fname, "NFM_DELETE_FTR_QUERY = <%ld>\n", in_command ));
	status = NFMSdelete_ftr_query( in_list );
	_NFMSdebug(( fname, "NFM_DELETE_FTR_QUERY DONE status = <0x%.8x>\n",
		status ));
	break;

     case NFM_RETRIEVE_QUERY_INFO :
        _NFMSdebug(( fname, "NFM_RETRIEVE_QUERY_INFO = <%ld>\n",
			in_command ));
        status = NFMSretrieve_query_info( in_list );
        _NFMSdebug(( fname, "NFM_RETRIEVE_QUERY_INFO DONE status = <0x%.8x>\n",
			status ));
	break;

     case NFM_RETRIEVE_FTR_QUERY_INFO :
        _NFMSdebug(( fname, "NFM_RETRIEVE_FTR_QUERY_INFO = <%ld>\n",
			in_command ));
        status = NFMSretrieve_ftr_query_info( in_list );
        _NFMSdebug(( fname, "NFM_RETRIEVE_FTR_QUERY_INFO DONE status = <0x%.8x>\n",status ));
	break;

    case NFM_GET_ITEM_VERSIONS :
	_NFMSdebug(( fname, "NFM_GET_ITEM_VERSIONS = <%ld>\n", in_command ));
	status = NFMSget_item_versions( in_list );
	_NFMSdebug(( fname, "NFM_GET_ITEM_VERSIONS DONE status = <0x%.8x>\n",
		status ));
   	break;

    case  NFM_DEFINE_SET_INFO :
        _NFMSdebug(( fname, "NFM_DEFINE_SET_INFO = <%ld>\n", in_command ));
	status = NFMSdefine_set_information( in_list );
        _NFMSdebug(( fname, "NFM_DEFINE_SET_INFO DONE status = <0x%.8x>\n",
                status ));
        break;

    case  NFM_SEARCH_ACROSS_CATALOGS :
        _NFMSdebug(( fname, "NFM_SEARCH_ACROSS_CATALOGS = <%ld>\n", 
		     in_command ));
	status = NFMSmultiple_catalog_search( in_list );
        _NFMSdebug(( fname, "NFM_SEARCH_ACROSS_CATALOGS DONE status = <0x%.8x>\n", status ));
        break;

    case  NFM_BLOCK_SEARCH_ACROSS_CATALOGS :
        _NFMSdebug(( fname, "NFM_BLOCK_SEARCH_ACROSS_CATALOGS = <%ld>\n", 
		     in_command ));
	status = NFMSblock_multiple_catalog_search( in_list );
        _NFMSdebug(( fname, "NFM_BLOCK_SEARCH_ACROSS_CATALOGS DONE status = <0x%.8x>\n", status ));
        break;

    case  NFM_BLOCK_MULTI_CAT_SRCH_M_CRSR :
        _NFMSdebug(( fname, "NFM_BLOCK_MULTI_CAT_SRCH_M_CRSR = <%ld>\n", 
		     in_command ))
	status = NFMSblock_multi_cat_srch_m_crsr( in_list );
        _NFMSdebug(( fname, "NFM_BLOCK_MULTI_CAT_SRCH_M_CRSR DONE status = <0x%.8x>\n", status ));
        break;

    case  NFM_FTR_SEARCH:
        _NFMSdebug(( fname, "NFM_FTR_SEARCH = <%ld>\n", 
		     in_command ))
	status = NFMSftr_search( in_list );
        _NFMSdebug(( fname, "NFM_FTR_SEARCH status = <0x%.8x>\n", status ));
        break;    

    case  NFM_GET_FTR_HIGHLIGHT:
        _NFMSdebug(( fname, "NFM_GET_FTR_HIGHLIGHT = <%ld>\n", in_command ))
	status = NFMSget_highlighting_for_files( in_list );
        _NFMSdebug(( fname, "NFM_GET_FTR_HIGHLIGHT status = <0x%.8x>\n", status ));
        break;    

    case  NFM_GET_THESAURUS:
        _NFMSdebug(( fname, "NFM_GET_THESAURUS = <%ld>\n", in_command ))
	status = NFMSget_thesaurus( in_list );
        _NFMSdebug(( fname, "NFM_GET_THESAURUS status = <0x%.8x>\n", status ));
        break;    

    case  NFM_GET_MEMBERS:
        _NFMSdebug(( fname, "NFM_GET_MEMBERS = <%ld>\n", in_command ))
	status = NFMSget_members( in_list );
        _NFMSdebug(( fname, "NFM_GET_MEMBERS status = <0x%.8x>\n", status ));
        break;    

    case  NFM_GET_VERDVEAL:
        _NFMSdebug(( fname, "NFM_GET_VERDVEAL = <%ld>\n", in_command ))
	status = NFMSget_verdveal( in_list );
        _NFMSdebug(( fname, "NFM_GET_VERDVEAL status = <0x%.8x>\n", status ));
        break;    

    case  NFM_GET_PREVIEW:
        _NFMSdebug(( fname, "NFM_GET_PREVIEW = <%ld>\n", in_command ))
	status = NFMSget_preview( in_list );
        _NFMSdebug(( fname, "NFM_GET_PREVIEW status = <0x%.8x>\n", status ));
        break;    

    case  NFM_DEFINE_FILE_INFO :
        _NFMSdebug(( fname, "NFM_DEFINE_FILE_INFO = <%ld>\n", in_command ));
	status = NFMSdefine_file_information( in_list );
        _NFMSdebug(( fname, "NFM_DEFINE_FILE_INFO DONE status = <0x%.8x>\n",
                status ));
        break;

    case  NFM_GET_FILE_INFO :
        _NFMSdebug(( fname, "NFM_GET_FILE_INFO = <%ld>\n", in_command ));
	status = NFMSget_file_information( in_list );
        _NFMSdebug(( fname, "NFM_GET_FILE_INFO DONE status = <0x%.8x>\n",
                status ));
        break;

    case  NFM_LFM_INFORMATION :
        _NFMSdebug(( fname, "NFM_LFM_INFORMATION = <%ld>\n", in_command ));
	status = NFMSlfm_information( in_list );
        _NFMSdebug(( fname, "NFM_LFM_INFORMATION DONE status = <0x%.8x>\n",
                status ));
        break;

    case  NFM_LFM_UPDATE :
        _NFMSdebug(( fname, "NFM_LFM_UPDATE = <%ld>\n", in_command ));
	status = NFMSlfm_update( in_list );
        _NFMSdebug(( fname, "NFM_LFM_UPDATE DONE status = <0x%.8x>\n",
                status ));
        break;

    case  NFM_LOG_IN :
        _NFMSdebug(( fname, "NFM_LOG_IN = <%ld>\n", in_command ));
	status = NFMSlog_in( in_list );
        _NFMSdebug(( fname, "NFM_LOG_IN DONE status = <0x%.8x>\n",
                status ));
        break;

     case  NFM_CHECKIN_ITEM :
        _NFMSdebug(( fname, "NFM_CHECKIN_ITEM = <%ld>\n", in_command ));
	status = NFMScheckin_item( in_list );
        _NFMSdebug(( fname, "NFM_CHECKIN_ITEM DONE status = <0x%.8x>\n",
                status ));
        break;

     case  NFM_CHECKIN_ITEM_FTR :
        _NFMSdebug(( fname, "NFM_CHECKIN_ITEM_FTR = <%ld>\n", in_command ));
	status = NFMSftr_checkin_item( in_list );
        _NFMSdebug(( fname, "NFM_CHECKIN_ITEM_FTR DONE status = <0x%.8x>\n",
                status ));
        break;

     case  NFM_CHECKOUT_ITEM :
        _NFMSdebug(( fname, "NFM_CHECKOUT_ITEM = <%ld>\n", in_command ));
	status = NFMScheckout_item( in_list );
        _NFMSdebug(( fname, "NFM_CHECKOUT_ITEM DONE status = <0x%.8x>\n",
                status ));
        break;

     case  NFM_CHECKIN_SET :
        _NFMSdebug(( fname, "NFM_CHECKIN_SET = <%ld>\n", in_command ));
	status = NFMScheckin_set( in_list );
        _NFMSdebug(( fname, "NFM_CHECKIN_SET DONE status = <0x%.8x>\n",
                status ));
        break;

     case  NFM_CHECKIN_SET_FTR :
        _NFMSdebug(( fname,   "NFM_CHECKIN_SET_FTR = <%ld>\n", in_command ));
        status = NFMSftr_checkin_set( in_list );
        _NFMSdebug(( fname,   "NFM_CHECKIN_SET_FTR DONE status = <0x%.8x>\n", 
                status ));
        break;

     case  NFM_CHECKOUT_SET :
        _NFMSdebug(( fname, "NFM_CHECKOUT_SET = <%ld>\n", in_command ));
	status = NFMScheckout_set( in_list );
        _NFMSdebug(( fname, "NFM_CHECKOUT_SET DONE status = <0x%.8x>\n",
                status ));
        break;
   
      case  NFM_RESET_FILE_INFO :
	_NFMSdebug(( fname, "NFM_RESET_FILE_INFO = <%ld>\n", in_command ));
	status = NFMSreset_file_information( in_list );
	_NFMSdebug(( fname, "NFM_RESET_FILE DONE status = <0x%.8x>\n",
		status ));
	break;
   
      case  NFM_COPY_ITEM_N :
	_NFMSdebug(( fname, "NFM_COPY_ITEM_N = <%ld>\n", in_command ));
	status = NFMScopy_item_n( in_list );
	_NFMSdebug(( fname, "NFM_COPY_ITEM_N status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_FTR_COPY_ITEM_N :
	_NFMSdebug(( fname, "NFM_FTR_COPY_ITEM_N = <%ld>\n", in_command ));
	status = NFMSftr_copy_item_n( in_list );
	_NFMSdebug(( fname, "NFM_FTR_COPY_ITEM_N status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_COPY_ITEM_FILES :
	_NFMSdebug(( fname, "NFM_COPY_ITEM_FILES = <%ld>\n", in_command ));
	status = NFMScopy_item_files( in_list );
	_NFMSdebug(( fname, "NFM_COPY_ITEM_FILES status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_SAVE_ITEM_FILES :
	_NFMSdebug(( fname, "NFM_SAVE_ITEM_FILES = <%ld>\n", in_command ));
	status = NFMSsave_item_files( in_list );
	_NFMSdebug(( fname, "NFM_SAVE_ITEM_FILES status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_SAVE_SET_FILES :
	_NFMSdebug(( fname, "NFM_SAVE_SET_FILES = <%ld>\n", in_command ));
	status = NFMSsave_set_files( in_list );
	_NFMSdebug(( fname, "NFM_SAVE_SET_FILES status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_FTR_SAVE_ITEM_FILES :
	_NFMSdebug(( fname, "NFM_FTR_SAVE_ITEM_FILES = <%ld>\n", in_command ));
	status = NFMSftr_save_item_files( in_list );
	_NFMSdebug(( fname, "NFM_FTR_SAVE_ITEM_FILES status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_FTR_SAVE_SET_FILES :
	_NFMSdebug(( fname, "NFM_FTR_SAVE_SET_FILES = <%ld>\n", in_command ));
	status = NFMSftr_save_set_files( in_list );
	_NFMSdebug(( fname, "NFM_FTR_SAVE_SET_FILES status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_COPY_SET :
	_NFMSdebug(( fname, "NFM_COPY_SET_FILES = <%ld>\n", in_command ));
	status = NFMScopy_set_files( in_list );
	_NFMSdebug(( fname, "NFM_COPY_SET_FILES status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_ADD_DEFAULT_WA :
	_NFMSdebug(( fname, "NFM_ADD_DEFAULT_WA = <%ld>\n", in_command ));
	status = NFMSadd_default_working_area( in_list );
	_NFMSdebug(( fname, "NFM_ADD_DEFAULT_WA status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_DELETE_COPIED_FILES :
	_NFMSdebug(( fname, "NFM_DELETE_COPIED_FILES = <%ld>\n", in_command ));
	status = NFMSdelete_copied_files( in_list );
	_NFMSdebug(( fname, "NFM_DELETE_COPIED_FILES status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_ROLL_VERSION_FORWARD :
	_NFMSdebug(( fname, "NFM_ROLL_VERSION_FORWARD =<%ld>\n", in_command ));
	status = NFMSroll_version_forward( in_list );
	_NFMSdebug(( fname, "NFM_ROLL_VERSION_FORWARD status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_PURGE_VERSIONS :
	_NFMSdebug(( fname, "NFM_PURGE_VERSIONS = <%ld>\n", in_command ));
	status = NFMSpurge_versions( in_list );
	_NFMSdebug(( fname, "NFM_PURGE_VERSIONS status = <0x%.8x>\n",
		status ));
	break;

      case  NFM_ADD_RETURN_SA_NAME :
	_NFMSdebug(( fname, "NFM_ADD_RETURN_SA_NAME = <%ld>\n", in_command ));
	status = NFMSadd_return_sa_name( in_list );
	_NFMSdebug(( fname, "NFM_ADD_RETURN_SA_NAME status = <0x%.8x>\n",
		status ));
	break;


      case NFM_GET_WF_AND_COMPLETED_ACL_LIST :
	_NFMSdebug(( fname,"NFM_GET_WF_AND_COMPLETED_ACL_LIST = <%d>\n",
		 in_command ));
	status = NFMSget_wf_and_completed_acl_list( in_list );
	_NFMSdebug(( fname,"NFM_GET_WF_AND_COMPLETED_ACL_LIST : status = <0x%.8x>\n",  status ));
	break;

      case NFM_GET_STATE_LIST_FOR_WORKFLOW :
	_NFMSdebug(( fname,"NFM_GET_STATE_LIST_FOR_WORKFLOW = <%d>\n",
		 in_command ));
	status = NFMSget_state_list_for_workflow( in_list );
	_NFMSdebug(( fname,"NFM_GET_STATE_LIST_FOR_WORKFLOW : status = <0x%.8x>\n",  status ));
	break;

      case NFM_GET_ITEM_ATTR_FOR_COPY :
	_NFMSdebug(( fname,"NFM_GET_ITEM_ATTR_FOR_COPY = <%d>\n",
		 in_command ));
	status = NFMSget_item_attr_for_copy( in_list );
	_NFMSdebug(( fname,"NFM_GET_ITEM_ATTR_FOR_COPY : status = <0x%.8x>\n",
		   status ));
	break;

      case NFM_PLOT_ITEM :
	_NFMSdebug(( fname,"NFM_PLOT_ITEM = <%d>\n", in_command ));
	status = NFMSplot_item( in_list );
	_NFMSdebug(( fname,"NFM_PLOT_ITEM : status = <0x%.8x>\n",
		   status ));
	break;

      case NFM_PLOT_SET :
	_NFMSdebug(( fname,"NFM_PLOT_SET = <%d>\n", in_command ));
	status = NFMSplot_set( in_list );
	_NFMSdebug(( fname,"NFM_PLOT_SET : status = <0x%.8x>\n", status ));
	break;

   case NFM_DELETE_SAVESETS :
        _NFMSdebug((fname, "NFM_DELETE_SAVESETS = <%ld>\n", in_command));
        status = NFMSdelete_savesets (in_list);
        _NFMSdebug((fname, "NFM_DELETE_SAVESETS : status = <0x%.8x>\n",
			status));
        break;

   case NFM_DELETE_ARCHIVES :
        _NFMSdebug((fname, "NFM_DELETE_ARCHIVES = <%ld>\n", in_command));
        status = NFMSdelete_archives (in_list);
        _NFMSdebug((fname, "NFM_DELETE_ARCHIVES : status = <0x%.8x>\n",
			status));
        break;

   case NFM_DELETE_LABEL :
        _NFMSdebug((fname, "NFM_DELETE_LABEL = <%ld>\n", in_command));
        status = NFMSdelete_label (in_list);
        _NFMSdebug((fname, "NFM_DELETE_LABEL : status = <0x%.8x>\n",
			status));
        break;

   case WF_QUERY_ACL_ATTR_COND:
        _NFMSdebug((fname, "WF_QUERY_ACL_ATTR_COND = <%ld>\n", in_command));
        status = NFMSquery_acl_attributes_condition (in_list);
        _NFMSdebug((fname, "WF_QUERY_ACL_ATTR_COND : status = <0x%.8x>\n",
                         status));
        break;

   case WF_GET_COPY_ACL:
        _NFMSdebug((fname, "WF_GET_COPY_ACL = <%ld>\n", in_command));
        status = NFMSget_acl_classes_for_copy (in_list);
        _NFMSdebug((fname, "WF_GET_COPY_ACL : status = <0x%.8x>\n",
                         status));
        break;

   case WF_COPY_ACL:
        _NFMSdebug((fname, "WF_COPY_ACL = <%ld>\n", in_command));
        status = NFMScopy_acl_users (in_list);
        _NFMSdebug((fname, "WF_COPY_ACL : status = <0x%.8x>\n",
                         status));
        break;

   case NFM_SET_CLIENT_INFO:
        _NFMSdebug((fname, "NFM_SET_CLIENT_INFO = <%ld>\n", in_command));
        status = NFMSset_client_info ();
        _NFMSdebug((fname, "NFM_SET_CLIENT_INFO : status = <0x%.8x>\n",
                         status));
        break;

    default :
        _NFMSdebug((fname, "Default = <%ld>\n", in_command));
        _NFMSdebug((fname, "Bad Command : status = <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_BAD_COMMAND, NULL, NULL );
	status = NFMSsend_error_buffers( NFM_E_BAD_COMMAND, NFM_E_BAD_COMMAND);
        _NFMSdebug((fname, "NFMSsend_error_buffers <0x%.8x>\n", status));
        break;
    }
if (status != NFM_S_SUCCESS )
    {
    _NFMSdebug((fname, "Command Status = <0x%.8x>\n", status));
    return (status);
    }

_NFMSdebug((fname, "SUCCESS : Command Status = <0x%.8x>\n", status));
return (NFM_S_SUCCESS);
}
 
