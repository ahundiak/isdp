/* $Revision: 1.1 $ */
#include "dba.ext"
#include "script.def"

#define VF (void (*)())

/*
    Function:	dba_register_nfm
    Author:	Tim A. Thompson
    Date:	09-DEC-92
*/

int dba_register_nfm()
{
  static int first_flag;
  int istat;

  if (first_flag)
    return SCRERR_SUCCESS;
  else
    first_flag = 1;

  dba_reg_default_verbose_on (VERB_NFM_FUNCTIONS, 0L);
  dba_reg_default_argnum_enforce_on ();

  /**********************/
  /*  Registered Function:  DBA_NFM_GET_MESSAGE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_get_message", VF dba_nfm_get_message);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("message");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_buffered_expand (1000);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_LOGIN  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_login", VF dba_nfm_login);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("server");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("environment");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("debug");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_SHORT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_LOGOUT  */
  /**********************/
  istat = dba_register_function ("dba_nfm_logout", VF dba_nfm_logout);
  if (istat)
    return istat;

  /**********************/
  /*  Registered Function:  DBA_NFM_GET_SCHEMA_NAME  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_get_schema_name", VF dba_nfm_get_schema_name);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("schema");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_buffered_expand (33);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_set_arg_buffered_expand (33);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /*====================================================================*/
      /* Turn on initial environment checking */
  /*====================================================================*/
  dba_reg_default_init_env_check (dba_check_nfm_active);

  /**********************/
  /*  Registered Function:  DBA_NFM_DEFAULT_SCHEMA  */
  /**********************/
  istat = dba_register_function ("dba_nfm_default_schema", VF dba_nfm_default_schema);
  if (istat)
    return istat;

  /**********************/
  /*  Registered Function:  DBA_NFM_DELETE_CATALOG  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_delete_catalog", VF dba_nfm_delete_catalog);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_DELETE_STORAGE_AREA  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_delete_storage_area", VF dba_nfm_delete_storage_area);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("storage_area");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_DELETE_USER  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_delete_user", VF dba_nfm_delete_user);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_MULTI  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_multi", VF dba_nfm_add_multi);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_LOAD_WORKFLOW  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_load_workflow", VF dba_nfm_load_workflow);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("application");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("wf_filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_ACL  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_acl", VF dba_nfm_add_acl);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("wfname");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("aclname");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_USER_DATA  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_user_data", VF dba_nfm_add_user_data);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("user_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("data");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_DELETE_ITEM  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_delete_item", VF dba_nfm_delete_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_FLAG_ITEM_DELETE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_flag_item_delete", VF dba_nfm_flag_item_delete);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_FLAG_ITEM_BACKUP  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_flag_item_backup", VF dba_nfm_flag_item_backup);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CANCEL_ITEM*/
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_cancel_item", VF dba_nfm_cancel_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CANCEL_SET  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_cancel_set", VF dba_nfm_cancel_set);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CHANGE_USER_PASSWD  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_change_user_passwd", VF dba_nfm_change_user_passwd);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("user_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("old_passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_FLAG_ITEM_ARCHIVE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_flag_item_archive", VF dba_nfm_flag_item_archive);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_FLAG_ITEM_RESTORE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_flag_item_restore", VF dba_nfm_flag_item_restore);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CANCEL_ITEM_ARCHIVE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_cancel_item_archive", VF dba_nfm_cancel_item_archive);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CANCEL_ITEM_RESTORE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_cancel_item_restore", VF dba_nfm_cancel_item_restore);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("calalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CANCEL_ITEM_DELETE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_cancel_item_delete", VF dba_nfm_cancel_item_delete);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CANCEL_ITEM_BACKUP  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_cancel_item_backup", VF dba_nfm_cancel_item_backup);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CHANGE_SA_PASSWD  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_change_sa_passwd", VF dba_nfm_change_sa_passwd);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("storage_area");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("old_passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_USER_CATALOG  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_user_catalog", VF dba_nfm_add_user_catalog);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("type");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("synonym");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_BUILD_SET_LIST  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_build_set_list", VF dba_nfm_build_set_list);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_type");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_LIST_TO_SET  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_list_to_set", VF dba_nfm_add_list_to_set);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_DROP_SET  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_drop_set", VF dba_nfm_drop_set);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_SIGNOFF  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_signoff", VF dba_nfm_signoff);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CHANGE_USER  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_change_user", VF dba_nfm_change_user);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("user_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("column_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("column_value");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_LOCK_ITEM  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_lock_item", VF dba_nfm_lock_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_UNLOCK_ITEM  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_unlock_item", VF dba_nfm_unlock_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_ACL_USER  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_acl_user", VF dba_nfm_add_acl_user);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("aclname");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("class");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("wfname");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_MAKE_TRANSITION  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_make_transition", VF dba_nfm_make_transition);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("state");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_USER  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_user", VF dba_nfm_add_user);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("user_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("mailpath");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_DELETE_ACL_USER  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_delete_acl_user", VF dba_nfm_delete_acl_user);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("aclname");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("class");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("wfname");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_DELETE_FILE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_delete_file", VF dba_nfm_delete_file);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_BUILD_SET_LIST2  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_build_set_list2", VF dba_nfm_build_set_list2);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("member_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("member_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("type");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_STORAGE_AREA  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_storage_area", VF dba_util_nfm_add_storage_area);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("sa_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("type");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_set_func_option (VF dba_nfm_add_storage_area);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("sa_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("type");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("sa_type");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("owner");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_TO_SET  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_to_set", VF dba_nfm_add_to_set);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("type");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CHANGE_FILE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_change_file", VF dba_nfm_change_file);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("c_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("c_value");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_COPY_NEW_ITEM  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_copy_new_item", VF dba_util_nfm_copy_new_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_set_func_option (VF dba_nfm_copy_new_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_cofilename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_cifilename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("new_storage");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_DROP_FROM_SET2  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_drop_from_set2", VF dba_nfm_drop_from_set2);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("set_catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_SET_CHECKIN  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_set_checkin", VF dba_nfm_set_checkin);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CHECKIN_MULTI  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_checkin_multi", VF dba_nfm_checkin_multi);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_COPY  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_copy", VF dba_nfm_copy);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CHECKIN  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_checkin", VF dba_nfm_checkin);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CHECKOUT  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_checkout", VF dba_nfm_checkout);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CREATE_CATALOG  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_create_catalog", VF dba_nfm_create_catalog);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("aclno");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CREATE_USER_CATALOG  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_create_user_catalog", VF dba_nfm_create_user_catalog);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("aclno");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_FILE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_file", VF dba_util_nfm_add_file);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_set_func_option (VF dba_nfm_add_file);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("ci_filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("filetype");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_DROP_FROM_SET  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_drop_from_set", VF dba_nfm_drop_from_set);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_CHANGE_ITEM  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_change_item", VF dba_nfm_change_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("c_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("c_value");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_SET  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_set", VF dba_nfm_add_set);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("aclno");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("versionlimit");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("cisano");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_ITEM  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_item", VF dba_util_nfm_add_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("aclno");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("versionlimit");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("cisano");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_set_func_option (VF dba_nfm_add_item);
  if (istat)
    return istat;

  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("aclno");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("versionlimit");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("cisano");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("ci_filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("filetype");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_USER_ITEM  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_user_item", 
                             VF dba_util_nfm_add_user_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("aclno");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("versionlimit");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("cisano");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_set_func_option (VF dba_nfm_add_user_item);
  if (istat)
    return istat;

  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("aclno");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("versionlimit");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("cisano");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("ci_filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  istat = dba_reg_arg_start ("filetype");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_SET_COPY  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_set_copy", VF dba_nfm_set_copy);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("level");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_SET_CHECKOUT  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_set_checkout", VF dba_nfm_set_checkout);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("level");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_TO_SET2  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_to_set2", VF dba_nfm_add_to_set2);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("set_catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("set_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_revision");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("type");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();

  /**********************/
  /*  Registered Function:  DBA_NFM_DELETE_COPIED_FILE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_delete_copied_file", VF dba_nfm_delete_copied_file);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("item_rev");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("storage_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("user");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("passwd");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("path");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("filename");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("version");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_SET_LOCAL_FILE_MANAGER  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_set_local_file_manager", VF dba_nfm_set_local_file_manager);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("state");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_SET_WORKFLOW  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_set_workflow", VF dba_nfm_set_workflow);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("state");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_ADD_NODE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_add_node", VF dba_nfm_add_node);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("description");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("xns");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("tcp");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("nfs");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_CHANGE_NODE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_change_node", VF dba_nfm_change_node);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("c_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("c_value");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_DELETE_NODE  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_delete_node", VF dba_nfm_delete_node);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("node");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_CHANGE_STORAGE_AREA  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_change_storage_area", VF dba_nfm_change_storage_area);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("storage");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("c_name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("c_value");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_PLOT_ITEM  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_plot_item", VF dba_nfm_plot_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("rev");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_PLOT_SET  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_plot_set", VF dba_nfm_plot_set);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("rev");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_SAVE_ITEM  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_save_item", VF dba_nfm_save_item);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("rev");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  DBA_NFM_SAVE_SET  */
  /**********************/
  istat = dba_reg_func_start ("dba_nfm_save_set", VF dba_nfm_save_set);
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("catalog");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("name");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("rev");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_func_end ();


  /**********************/
  /*  Registered Function:  */
  /**********************/
/*
  istat = dba_reg_func_start ("", VF );
  if (istat)
    return istat;
  istat = dba_reg_arg_start ("");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_INT, 0, 0, 0, 0);
  istat = dba_reg_set_arg_indir (0, 1, 0);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
  istat = dba_reg_arg_start ("");
  if (istat)
    return istat;
  istat = dba_reg_set_arg_type (SCR_CHAR, 1, 0, 0, 0);
  istat = dba_reg_set_arg_indir (1, 1, 1);
  istat = dba_reg_arg_end ();
*/

  dba_reg_default_verbose_off ();
  dba_reg_default_argnum_enforce_off ();
  dba_reg_default_init_env_check ((long (*)()) 0);

  return SCRERR_SUCCESS;
}
