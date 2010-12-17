#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMlocks.h"
#include "NFMfile.h"
#include <errno.h>
#include <sys/types.h>
#include <sys/times.h>
#include <sys/param.h>
#include "MSGstruct.h"
#include "ERR.h"
#include "NFMstruct.h"
#include "WFstruct.h"
#include "DEBUG.h"

extern struct NFMglobal_st NFMglobal;
extern MSGptr NFMmsg_ptr;
extern struct NFMitem_info *NFMitem_ptr; /* contains the item information */
                                         /* during check-out command */
extern MEMptr CAT_list;
extern struct WFstruct WFinfo;
extern struct sto_area_info STO_info;  /* it contains the check_out TO sto */

/*
extern long     mb_time1, mb_time2, mb_total;
extern struct   tms mb_tms1, mb_tms2;
*/

                             

long NFMprepare_item_checkout (user_id, cat_name, item_name, item_rev,
                                attr_list, data_list)
long    user_id;
char    *cat_name, *item_name, *item_rev;
MEMptr  *attr_list, *data_list;
{
  long     status;
  long     item_no;
  struct   tms tmp_tms;
  long     elp_time;
  char     sql_str [1024];  /*** DUR 11/13/90 ***/
  char     cond_str [300];
  char     *fname="NFMprepare_item_checkout";

  /*
  mb_time1 = times (&mb_tms1);
  */

  if (NFMmsg_ptr.debug_on)
  {
  _NFM_str ("NFMprepare_item_checkout: enter ...");
  _NFM_str ("NFMprepare_item_checkout : Cat  Name = <%s>  ", cat_name );
  _NFM_str ("NFMprepare_item_checkout : Item Name = <%s>  ", item_name);
  _NFM_str ("NFMprepare_item_checkout : Item Rev  = <%s>\n", item_rev );
  }


  status = NFMcheck_process_locks (user_id);
  if (status != NFM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, NULL);
    _NFM_num ("NFMprepare_item_checkout : Check Process Lock:<0x%.8x>\n",
    NFM_E_BAD_COMMAND_ORDER);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  /* malloc NFMitem_ptr, so the item information can be stored and retrieved */
  /* during the check-out command quickly */

  NFMitem_ptr = (struct NFMitem_info *) calloc 
                             (1, sizeof (struct NFMitem_info));
  if (! NFMitem_ptr )
  {
    status = ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_str ("NFMprepare_item_checkout: Failed to malloc global NFMitem_ptr");
    return (NFM_E_MEM);
  }


  /* retrieve the <catalog> and f_<catalog> number, and put them in the global*/
  /* pointer. */

  status = _NFMget_cat_fcat_no (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, NULL);
    _NFM_num ("NFMprepare_item_checkout: NFMget_cat_fcat_no: <0x%.8x>\n",
    NFM_E_BAD_ATTR_VALUE);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  /* retrieve the n_name and n_dtype of attributes which will be needed for */
  /* the check_out operation. (from <catalog> and f_<catalog>) */

  status = _NFMprepare_item_info (item_name, item_rev);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, NULL);
    _NFM_num ("NFMprepare_item_checkout: NFMprepare_item_info: <0x%.8x>\n",
    NFM_E_BAD_ATTR_VALUE);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  /* retrieve the values of attributes which will be needed for */
  /* the check_out operation. (from <catalog>)*/

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    _NFM_num ("NFMprepare_item_checkout: NFMstop_transaction = <0x%.8x>\n",
    status);
    return (status);
  }

  /* need to lock table, select, check the value, update, and commit */
  /* to make sure multiuser cannot CI the same file */

  status = NFMlock_table (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    NFMrollback_transaction (0);
    ERRload_struct (NFM, NFM_E_FAILURE, NULL);
    _NFM_num ("NFMprepare_item_checkin: Set Co Out -> Temp In: <0x%.8x>\n",
    status);
    return (status);
  }

  status = _NFMprepare_item_values (cat_name, item_name, item_rev);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, NULL);
    NFMrollback_transaction (0);
    _NFM_num ("NFMprepare_item_checkout: _NFMprepare_item_values  <0x%.8x>",
    NFM_E_BAD_ATTR_VALUE);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  if ( strcmp(NFMitem_ptr->cat_item.n_coout.data_value, "I") ||
         (! NFMitem_ptr->cat_item.n_coout.data_count) )
  {
    _NFMload_message (item_name, item_rev, 1, 
     (NFMitem_ptr->cat_item.n_coout.data_count)? 
     NFMitem_ptr->cat_item.n_coout.data_value : "");
    NFMrollback_transaction (0);
    free (NFMitem_ptr);
    _NFM_num ("NFMprepare_item_checkout : Item Not ready out: <0x%.8x>\n",
    NFM_E_COOUT);
    return (NFM_E_COOUT);
  }

  status = _NFMs_temp_flag ( cat_name, "TO", 0);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    free (NFMitem_ptr);
    _NFM_num ("NFMprepare_item_checkout : _NFMs_temp_flag = <0x%.8x>\n",
    status);
    return (status);
  }

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMs_temp_flag (cat_name,
                      NFMitem_ptr->cat_item.n_coout.data_value, 1);
    free (NFMitem_ptr);
    _NFM_num ("NFMprepare_item_checkout: NFMstart_transaction = <0x%.8x>\n",
    status);
    return (status);
  }

  item_no = atol (NFMitem_ptr->cat_item.n_itemno.data_value);

  /* if the item is locked, stop the user/application to check_out this item */

  if (! strcmp (NFMitem_ptr->cat_item.n_itemlock.data_value, "Y"))
  {
    free (NFMitem_ptr);
    _NFMs_temp_flag (cat_name, NFMitem_ptr->cat_item.n_coout.data_value, 1);
    ERRload_struct (NFM, NFM_E_ITEM_LOCKED, NULL);
    _NFM_num ("NFMprepare_item_checkout item locked: status = <0x%.8x>",
                                                           NFM_E_ITEM_LOCKED);
    return (NFM_E_ITEM_LOCKED);
  }

  status = _NFMg_fileversion (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    _NFMs_temp_flag (cat_name, NFMitem_ptr->cat_item.n_coout.data_value, 1);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, NULL);
    _NFM_num ("NFMprepare_item_checkout: _NFMg_pending_flag: <0x%.8x> \n",
    NFM_E_BAD_ATTR_VALUE);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  status = _NFMchk_item (cat_name, item_name, item_rev, NFM_ITEM_OUT);
  if (status != NFM_S_SUCCESS)
  {
    _NFMs_temp_flag (cat_name, NFMitem_ptr->cat_item.n_coout.data_value, 1);
    free (NFMitem_ptr);
    _NFM_num ("NFMprepare_item_checkout: _NFMchk_item: <0x%.8x>\n", status);
    return (status);
  }

  /* set-up the attr_list (column and data) and data_list (column) */
  status = _NFMq_co_attr (user_id, cat_name, attr_list, data_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    MEMclose (data_list);
    _NFMs_temp_flag (cat_name, NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMprepare_item_checkout: _NFMq_co_attr: <0x%.8x>\n", status);
    return (status);
  }

  status = _NFMg_item_co_info (user_id, cat_name, *attr_list, *data_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    MEMclose (data_list);
    MEMclose (&CAT_list);
    _NFMs_temp_flag (cat_name, NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMprepare_item_checkout: _NFMg_itme_co_info <0x%.8x>\n", 
    status);
    return (status);        
  }

  status = NFMset_process_lock (user_id, NFM_I_PL_CO_ITEM);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    MEMclose (data_list);
    _NFMs_temp_flag (cat_name, NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMprepare_item_checkout : NFMset_process_lock= <0x%.8x>\n",
    status);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (status);
  }

  _NFM_num ("NFMprepare_item_checkout : SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);

  /*
  mb_time2 = times (&mb_tms2);
  mb_total = mb_time2 - mb_time1;
  if ( !NFMmsg_ptr.debug_on )
  {
    NFMmsg_ptr.debug_on = 1;
    strcpy (NFMmsg_ptr.debug_file, "/usr2/nfmadmin/time_ci.new");
    _NFM_num ("after prepare_item_check_out, mb_total = %d", mb_total);
    _NFM_num ("utime = %d", mb_tms2.tms_utime - mb_tms1.tms_utime);
    _NFM_num ("stime = %d", mb_tms2.tms_stime - mb_tms1.tms_stime);
    NFMmsg_ptr.debug_on = 0;
  }
  */

  return (NFM_S_SUCCESS);
}

long NFMcancel_item_checkout (user_id, attr_list, data_list)
long    user_id;
MEMptr  attr_list;
MEMptr  data_list;
{
  long     status;

  if (NFMmsg_ptr.debug_on)
  _NFM_str ("NFMcancel_item_checkout: enter...");

  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CO_ITEM))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, NULL);
    _NFM_num ("NFMcancel_item_checkout: Check Process Lock: <0x%.8x>\n",
    NFM_E_BAD_COMMAND_ORDER);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CO_ITEM)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CO_ITEM);
    if (status != NFM_S_SUCCESS)
    {
      _NFMs_temp_flag (WFinfo.catalog_name,
                                NFMitem_ptr->cat_item.n_coout.data_value, 1);
      _NFM_num ("NFMcancel_item_checkout: Reset Proc Lock: <0x%.8x>\n", 
      status);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      return (status);
    }
  }

  status = _NFMs_temp_flag (WFinfo.catalog_name,
                            NFMitem_ptr->cat_item.n_coout.data_value, 1);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    ERRload_struct (NFM, NFM_E_FAILURE, NULL);
    _NFM_num ("NFMcancel_item_checkout: _NFMs_temp_flag: <0x%.8x>\n",
    status);
    return (status);
  }

  free (NFMitem_ptr);
  MEMclose (&CAT_list);
  if (NFMmsg_ptr.debug_on)
  _NFM_num ("NFMcancel_item_checkout: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);     
}

long NFMcomplete_item_checkout (user_id, storage_name,
                                 node_name, user_name, passwd, path_name,
                                 attr_list, data_list)
long    user_id;
char    *storage_name;
char    *node_name, *user_name, *passwd, *path_name;
MEMptr  attr_list, data_list;
{
  long       status;
  char       datetime_str [20];
  char       datetime [20];
  long       row_init, row_final;
  long       item_no, item_ver;
  char       temp_cat [100], file_cat[100];
  MEMptr     list = NULL;
  char       **column, **data, **data1;
  long       x, y, count;
  long       NFMget_co_files_list ();
  long       NFMupdate_co_file_cat ();
  struct     tms tmp_tms;
  long       elp_time;
  char       sql_str [1024];  /*** DUR 11/19/90 ***/
  char       *fname="NFMcomplete_item_checkout";

  /*
  mb_time1 = times (&mb_tms1);
  */

  if (NFMmsg_ptr.debug_on)
  {
  _NFM_str ("NFMcomplete_item_checkout: enter ...");
  _NFM_str ("NFMcomplete_item_checkout: ST   Name = <%s>  ", storage_name);
  _NFM_str ("NFMcomplete_item_checkout: Node Name = <%s>  ", node_name   );
  _NFM_str ("NFMcomplete_item_checkout: User Name = <%s>  ", user_name   );
  _NFM_str ("NFMcomplete_item_checkout: Passwd    = <%s>  ", passwd      );
  _NFM_str ("NFMcomplete_item_checkout: Path Name = <%s>\n", path_name   );
  }

  
  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CO_ITEM))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, NULL);
    _NFM_num ("NFMcomplete_item_checkout: Check Process Lock: <0x%.8x>\n",
	       NFM_E_BAD_COMMAND_ORDER);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CO_ITEM)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CO_ITEM);
    if (status != NFM_S_SUCCESS)
    {
      _NFM_num ("NFMcomplete_item_checkout: Reset Proc Lock: <0x%.8x>\n",
      status);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      return (status);
    }
  }

  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    _NFMs_temp_flag (WFinfo.catalog_name,
                               NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMcomplete_item_checkout: Get Date & Time: <0x%.8x>\n",
              NFM_E_SYS_TIME);
    ERRload_struct (NFM, NFM_E_SYS_TIME, NULL);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SYS_TIME);
  }

  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    _NFMs_temp_flag (WFinfo.catalog_name,
                               NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMcomplete_item_checkout: Get Date & Time: <0x%.8x>\n",
              NFM_E_SYS_TIME);
    ERRload_struct (NFM, NFM_E_SYS_TIME, NULL);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SYS_TIME);
  }

  if (strlen (storage_name))
  {
    status = _NFMsa_info (storage_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMs_temp_flag (WFinfo.catalog_name,
                NFMitem_ptr->cat_item.n_coout.data_value, 1);
      _NFM_num ("NFMcomplete_item_checkout: Get Sa Info : status = <0x%.8x>\n",
      NFM_E_BAD_ST_AREA);
      ERRload_struct (NFM, NFM_E_BAD_ST_AREA, NULL);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      return (NFM_E_BAD_ST_AREA);     
    }

    passwd [0] = 0;
  }
  else if ((strlen (node_name)) || (strlen (user_name)) || 
           (strlen (path_name)))
  {
/* PUT IN PASSWORD SO THAT TEMP SA HAS PASSWD MRG 07/18/91 */

    status = _NFMadd_temp_sa (user_id, node_name, user_name,
                              path_name,passwd);
    if (status != NFM_S_SUCCESS)
    {
      _NFMs_temp_flag (WFinfo.catalog_name,
                               NFMitem_ptr->cat_item.n_coout.data_value, 1);
      _NFM_num ("NFMcomplete_item_checkout: Add Temp SA : status = <0x%.8x>\n",
      NFM_E_BAD_ST_AREA);
      ERRload_struct (NFM, NFM_E_BAD_ST_AREA, NULL);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      return (NFM_E_BAD_ST_AREA);     
    }
  }
  else
  {
    ERRload_struct (NFM, NFM_E_BAD_ST_AREA, NULL);
    _NFMs_temp_flag (WFinfo.catalog_name,
                              NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMcomplete_item_checkout: Bad Storage : status = <0x%.8x>\n",
    NFM_E_BAD_ST_AREA);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_BAD_ST_AREA);     
  }
  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMs_temp_flag (WFinfo.catalog_name,
                              NFMitem_ptr->cat_item.n_coout.data_value, 1);
    ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("NFMcomplete_item_checkout: MEM Build Array <0x%.8x>\n",
    NFM_E_MEM);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMs_temp_flag (WFinfo.catalog_name,
                              NFMitem_ptr->cat_item.n_coout.data_value, 1);
    ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("NFMcomplete_item_checkout: MEM Build Array: <0x%.8x>\n",
    NFM_E_MEM);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_MEM);
  }
  status = NFMget_move_files_list (user_id, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMs_temp_flag (WFinfo.catalog_name,
                               NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMcomplete_item_checkout: Move Buffer : status = <0x%.8x>\n",
    NFM_E_BAD_TEMPLATE);
    ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, NULL);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_BAD_TEMPLATE);
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  data1  = (char **) data_list -> data_ptr;

  row_init = 0;  row_final = data_list -> rows;

  sprintf (temp_cat,  "%s", WFinfo.catalog_name);

  item_no = atol (NFMitem_ptr->cat_item.n_itemno.data_value),

  /****************************  DUR  11/13/90  ***************************/
  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFM_num ("NFMcomplete_item_checkout: NFMstop_transaction <0x%.8x> ",
    NFM_E_FAILURE);
    ERRload_struct (NFM, NFM_E_FAILURE, NULL);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_FAILURE);
  }
  /******************* DUR  12/6/90 *******************
  sprintf (sql_str, "LOCK TABLES %s IN EXCLUSIVE MODE", temp_cat);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, NULL);
    _NFM_num ("NFMcomplete_item_checkout: SQLstmt (LOCK TABLES ...) <0x%.8x>",
    NFM_E_SQL_STMT);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SQL_STMT);
  }
  **************************** end of code added   ***************************/
  status = NFMlock_table (temp_cat);
  if (status != NFM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_FAILURE, NULL);
    _NFM_num ("NFMcomplete_item_checkout: NFMlock_table  <0x%.8x>",
    NFM_E_FAILURE);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_FAILURE);
  }

  status = _NFMget_co_files (user_id, row_init, row_final,
             		        attr_list, data_list, list, 0);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    NFMrollback_transaction (0);
    _NFMs_temp_flag (WFinfo.catalog_name,
                      NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMcomplete_item_checkout: <0x%.8x>\n",
    status);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (status);               
  }

  /******************* DUR  11/30/90 *******************/
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, NULL);
    _NFM_num ("START TRANS : Commit Work : status = <0x%.8x>\n",
    NFM_E_SQL_STMT);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SQL_STMT);
  }
  /******************* DUR  12/6/90 *******************
  sprintf (sql_str, "LOCK TABLES f_%s IN EXCLUSIVE MODE", temp_cat);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, NULL);
    _NFM_num ("START TRANS : LOCK FILE CATALOG TABLE (3) : status = <0x%.8x>\n",
    NFM_E_SQL_STMT);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SQL_STMT);
  }
  ******************* end of code added  *******************/
  sprintf (file_cat, "f_%s", temp_cat);
  status = NFMlock_table (file_cat);
  if (status != NFM_S_SUCCESS)
  { 
    ERRload_struct (NFM, NFM_E_FAILURE, NULL);
    _NFMdebug ( (fname, "NFMlock_table: 0x%.8x", status) );
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_FAILURE);
  }
  status = _NFMmv_files_in (user_id, STO_info.sano, passwd, &list);
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_in (user_id, STO_info.sano, passwd, &list);
    MEMclose (&list);
    NFMrollback_transaction (0);
    _NFMs_temp_flag (WFinfo.catalog_name,
                          NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMcomplete_item_checkout: Move Co Files : status = <0x%.8x>\n",
    NFM_E_ITEM_OUT_TRANS);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_ITEM_OUT_TRANS);               
  }

  /*
  mb_time1 = times (&mb_tms1);
  */

  status = _NFMupd_co_cat_fcat (user_id, NFMglobal.NFMusername, datetime, 
           STO_info.sano, row_init, row_final, "", 
           temp_cat, item_no, attr_list, data_list, list); 
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_in (user_id, STO_info.sano, passwd, &list);
    MEMclose (&list);
    NFMrollback_transaction (0);
    ERRload_struct (NFM, NFM_E_CORRUPTED_CATALOG, NULL);
    _NFMs_temp_flag (WFinfo.catalog_name,
                     NFMitem_ptr->cat_item.n_coout.data_value, 1);
    _NFM_num ("NFMcomplete_item_checkout: Upd Ci Files List: <0x%.8x>\n",
    status);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (status);               
  }
  /****************************  DUR  11/16/90  ***************************/

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_in (user_id, STO_info.sano, passwd, &list);
    MEMclose (&list);
    _NFM_num ("NFMcomplete_item_checkout: Start Transaction: <0x%.8x>\n",
    status);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (status);               
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("NFMcomplete_item_checkout: MEM Close: <0x%.8x>\n", NFM_E_MEM);
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("NFMcomplete_item_checkout: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  free (NFMitem_ptr);
  MEMclose (&CAT_list);

  /*
  mb_time2 = times (&mb_tms2);
  mb_total = mb_time2 - mb_time1;

  if ( !NFMmsg_ptr.debug_on )
  {
    NFMmsg_ptr.debug_on = 1;
    strcpy (NFMmsg_ptr.debug_file, "/usr2/nfmadmin/time_ci.new");
    _NFM_num ("after complete_item_check_out, mb_total = %d", mb_total);
    _NFM_num ("utime = %d", mb_tms2.tms_utime - mb_tms1.tms_utime);
    _NFM_num ("stime = %d\n", mb_tms2.tms_stime - mb_tms1.tms_stime);
    NFMmsg_ptr.debug_on = 0;
  }
  */

  return (NFM_S_SUCCESS);     
}

