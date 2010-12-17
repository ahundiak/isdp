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
#include "WFstruct.h"
#include "NFMstruct.h"
#include "NFMattr_def.h"
#include "ERR.h"
#include "DEBUG.h"
#include "MSGstruct.h"

extern struct NFMglobal_st NFMglobal;
extern struct sto_area_info STO_info;
extern MSGptr NFMmsg_ptr;
struct NFMitem_info *NFMitem_ptr = NULL;
extern struct WFstruct WFinfo;
MEMptr CAT_list=NULL;

long NFMprepare_item_checkin (user_id, cat_name, item_name, item_rev,
                              attr_list, data_list)
long    user_id;
char    *cat_name, *item_name, *item_rev;
MEMptr  *attr_list, *data_list;
{
  long     status, coout_status;
  long     item_no;
  struct   tms tmp_tms;
  long     elp_time;
  char     sql_str[1024];
  char     value[50];
  char     temp_flag[2];
  char *fname="NFMprepare_item_checkin";

  _NFMdebug ((fname, "ENTER: cat [%s] item [%s] item_rev [%s]\n",
              cat_name, item_name, item_rev));

  status = NFMcheck_process_locks (user_id);
  if (status != NFM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    _NFMdebug ((fname, "NFMcheck_process_locks 0x%.8x\n",
                NFM_E_BAD_COMMAND_ORDER));
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  /* malloc the NFMitem_ptr, so the item information can be saved in this */
  /* global pointer, and the information can be accessed quickly */ 

  NFMitem_ptr = (struct NFMitem_info *) calloc 
                   (1, sizeof (struct NFMitem_info));
  if (! NFMitem_ptr )
  {
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname, "Failed to malloc global NFMitem_ptr\n"));
    return (NFM_E_MEM);
  }

  /* retrieve the <catalog> and f_<catalog> number, and put them in the global*/
  /* pointer. */

  strcpy (NFMitem_ptr->cat_name, cat_name);

  status = _NFMget_cat_fcat_no (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    _NFMdebug ((fname, "_NFMget_cat_fcat_no: 0x%.8x\n",
                NFM_E_BAD_ATTR_VALUE));
    return (NFM_E_BAD_ATTR_VALUE);
  }

  /* retrieve the n_name and n_dtype of attributes which will be needed for */
  /* the check_in operation. (from <catalog> and f_<catalog>) */

  status = _NFMprepare_item_info (item_name, item_rev);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    _NFMdebug ((fname, "_NFMprepare_item_info: 0x%.8x\n", NFM_E_BAD_ATTR_VALUE));
    return (NFM_E_BAD_ATTR_VALUE);
  }

  /* retrieve the values of attributes which will be needed for */
  /* the check_in operation. (from <catalog>)*/

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    _NFM_num ("NFMprepare_item_checkin: Stop Transaction : status = <0x%.8x>\n",
    status);
    return (status);
  }
  status = NFMlock_table (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    NFMrollback_transaction (0);
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    _NFM_num ("NFMprepare_item_checkin: Set Co Out -> Temp In: <0x%.8x>\n",
    status);
    return (status);
  }

  status = _NFMprepare_item_values (cat_name, item_name, item_rev);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    NFMrollback_transaction (0);
    _NFM_num ("NFMprepare_item_checkin: _NFMprepare_item_values  <0x%.8x>", 
    NFM_E_BAD_ATTR_VALUE);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  if ( (strcmp(NFMitem_ptr->cat_item.n_coout.data_value, "O")) &&
       ((NFMitem_ptr->cat_item.n_coout.data_count))
     )
  {
    _NFMload_message (item_name, item_rev, 0, 
                      NFMitem_ptr->cat_item.n_coout.data_value);
    NFMrollback_transaction (0);
    free (NFMitem_ptr);
    _NFM_num ("NFMprepare_item_checkin : Item Not ready In: <0x%.8x>\n",
    NFM_E_COOUT);
    return (NFM_E_COOUT);
  }

  /* because of table locking logic, rollback will not work. */
  /* so item's n_coout value need to be stored in the        */
  /* global pointer and local variable, if the rollback is   */
  /* necessary. */

  if (NFMitem_ptr->cat_item.n_coout.data_count)
    strcpy (temp_flag, NFMitem_ptr->cat_item.n_coout.data_value);
  else
    temp_flag[0] = '\0'; /* in the case of that item is newly created */
                         /* it would not have value for n_coout when  */
                         /* it is checked in for the first time. */

  status = _NFMs_temp_flag ( cat_name, "TI", 0);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    NFMrollback_transaction (0);
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    _NFM_num ("NFMprepare_item_checkin: Set Co Out -> Temp In: <0x%.8x>\n",
    status);
    return (status);
  }
  
  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    _NFM_num ("COMP ITEM IN : Start Transaction: <0x%.8x>\n",
    status);
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    return (status);
  }

  item_no = atol (NFMitem_ptr->cat_item.n_itemno.data_value);

  /* if the item is locked, stop the user/application to check_in this item */

  if (! strcmp (NFMitem_ptr->cat_item.n_itemlock.data_value, "Y"))
  {
    free (NFMitem_ptr);
    _NFMs_temp_flag ( cat_name, temp_flag, 1);
    ERRload_struct (NFM, NFM_E_ITEM_LOCKED, "", NULL);
    _NFM_num ("NFMprepare_item_checkin item locked: status = <0x%.8x>",
                                                           NFM_E_ITEM_LOCKED);
    return (NFM_E_ITEM_LOCKED);
  }

  /* check the archive and n_coout */

  status = _NFMchk_item (cat_name, item_name, item_rev, NFM_ITEM_IN);
  if (status != NFM_S_SUCCESS)
  {
    _NFMs_temp_flag ( cat_name, temp_flag, 1);
    free (NFMitem_ptr);
    _NFM_num ("NFMprepare_item_checkin: NFMchk_item: <0x%.8x>\n",
    status);
    return (status);
  }

  /* retrieve the fileversion information for the check_in command */

  status = _NFMg_fileversion (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    _NFMs_temp_flag ( cat_name, temp_flag, 1);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, "", NULL);
    _NFM_num ("NFMprepare_item_checkin: _NFMg_pending_flag: <0x%.8x> \n",
    NFM_E_BAD_ATTR_VALUE);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  /* set-up the attr_list (column and data) and data_list (column) */
 
  status = _NFMq_ci_attr (user_id, attr_list, data_list);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    _NFMs_temp_flag ( cat_name, temp_flag, 1);
    MEMclose (attr_list);
    MEMclose (data_list);
    _NFM_num ("NFMprepare_item_checkin: Get Ci Attr: <0x%.8x>\n", status);
    return (status);
  }

  /* set-up data_list (data), retrieve the <catalog> attribute and save in */
  /* CAT_list, so it can be used latter. */

  status = NFMg_item_ci_info (user_id, cat_name, *attr_list, *data_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    _NFMs_temp_flag ( cat_name, temp_flag, 1);
    MEMclose (&CAT_list);
    MEMclose (attr_list);
    MEMclose (data_list);
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    _NFM_num ("NFMprepare_item_checkin: Get Ci Attr: <0x%.8x>\n", status);
    return (status);
  }

  /* make sure the check_out user = check_in user */

  status = _NFMchk_in_user ( *attr_list, *data_list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMs_temp_flag (cat_name, temp_flag, 1);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    MEMclose (attr_list);
    MEMclose (data_list);
    ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s", "check in the item",
       "item");
    _NFM_num ("NFMprepare_item_checkin: Check CI User : status = <0x%.8x>\n",
    NFM_E_NOT_CO_USER);
    return (NFM_E_NOT_CO_USER);   
  }

  /* By setting the process lock, it ensures that either the            */ 
  /* NFMcancel_item_checkin or NFMcomplete_item_checkin is called after */
  /* NFMprepare_item_checkin */

  status = NFMset_process_lock (user_id, NFM_I_PL_CI_ITEM);
  if (status != NFM_S_SUCCESS)
  {
    _NFMs_temp_flag ( cat_name, temp_flag, 1);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    MEMclose (attr_list);
    MEMclose (data_list);
    _NFM_num ("NFMprepare_item_checkin: In Item Process Lock:<0x%.8x>\n",
    status);
    return (status);
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("NFMprepare_item_checkin: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);

  /*
  mb_time2 = times (&mb_tms2);
  mb_total = mb_time2 - mb_time1;

  if ( !NFMmsg_ptr.debug_on )
  {
    NFMmsg_ptr.debug_on = 1;
    strcpy (NFMmsg_ptr.debug_file, "/usr2/nfmadmin/time_ci.new");
    _NFM_num ("after prepare_item_check_in, mb_total = %d", mb_total);
    _NFM_num ("utime = %d", mb_tms2.tms_utime - mb_tms1.tms_utime);
    _NFM_num ("stime = %d", mb_tms2.tms_stime - mb_tms1.tms_stime);
    NFMmsg_ptr.debug_on = 0;
  }
  */

  return (NFM_S_SUCCESS);
}

long NFMcancel_item_checkin (user_id, attr_list, data_list)
long    user_id;
MEMptr  attr_list, data_list;
{
  long     status;
  char     temp_flag[2];

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("NFMcancel_item_checkin: enter ");


  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CI_ITEM))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    _NFM_num ("NFMcancel_item_checkin: NFMcheck_process_locks: sta =<0x%.8x>\n",
    NFM_E_BAD_COMMAND_ORDER);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CI_ITEM)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CI_ITEM);
    if (status != NFM_S_SUCCESS)
    {
      if (NFMitem_ptr->cat_item.n_coout.data_count)
        strcpy (temp_flag, NFMitem_ptr->cat_item.n_coout.data_value);
      else
        temp_flag[0] = '\0'; 

      _NFMs_temp_flag (WFinfo.catalog_name,  temp_flag, 1);
      ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      _NFM_num ("CAN ITEM IN : Reset Process Lock : status = <0x%.8x>\n",
      NFM_E_FAILURE);
      return (NFM_E_FAILURE);
    }
  }


  if (NFMitem_ptr->cat_item.n_coout.data_count)
    strcpy (temp_flag, NFMitem_ptr->cat_item.n_coout.data_value);
  else
    temp_flag[0] = '\0';

  status = _NFMs_temp_flag (NFMitem_ptr->cat_name, temp_flag, 1);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    _NFM_num ("CAN ITEM IN : _NFMs_temp_flag: status = <0x%.8x>\n",
    status);
    return (status);
  }

  free (NFMitem_ptr);
  MEMclose (&CAT_list);

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("CAN ITEM IN : SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);     
}

long NFMcomplete_item_checkin (user_id, storage_name, node_name, 
                               user_name, passwd, path_name,
                               attr_list, data_list)
long    user_id;
char    *storage_name;
char    *node_name, *user_name, *passwd, *path_name;
MEMptr  attr_list, data_list;
{
  long       status, del_status, pur_status;
  char       datetime_str[50];
  char       datetime [50];
  MEMptr     list = NULL;
  char       **column, **data, **data1;
  long       i, j, k, l, m, x, y, count;
  long       row_init, row_final, item_no;
  char       temp_cat [100], file_cat[100];
  struct     tms tmp_tms;
  long       elp_time;
  char       sql_str [1024];  /*** DUR 11/19/90 ***/
  char       temp_flag[2];
  char       cat_name[100];


  /*
  mb_time1 = times (&mb_tms1); 
  */
  if (NFMmsg_ptr.debug_on)
  {
  _NFM_num ("COMP ITEM IN : User Id   = <%d>  ", user_id     );
  _NFM_str ("COMP ITEM IN : St   Name = <%s>  ", storage_name);
  _NFM_str ("COMP ITEM IN : Node Name = <%s>  ", node_name   );
  _NFM_str ("COMP ITEM IN : User Name = <%s>  ", user_name   );
  _NFM_str ("COMP ITEM IN : Passwd    = <%s>  ", passwd      );
  _NFM_str ("COMP ITEM IN : Path Name = <%s>\n", path_name   );
  }


  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CI_ITEM))
  {
    status = ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, "", NULL);
    _NFM_num ("COMP ITEM IN : Check Process Lock : status = <0x%.8x>\n",
    NFM_E_BAD_COMMAND_ORDER);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

     /* because of table locking logic, rollback will not work. */
     /* so item's n_coout value need to be stored in the        */
     /* global pointer and local variable, if the rollback is   */
     /* necessary. */

  if (NFMitem_ptr->cat_item.n_coout.data_count)
    strcpy (temp_flag, NFMitem_ptr->cat_item.n_coout.data_value);
  else
    temp_flag[0] = '\0'; /* in the case of that item is newly created */
                         /* it would not have value for n_coout when  */
                         /* it is checked in for the first time. */

  if (status == NFM_I_PL_CI_ITEM)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CI_ITEM);
    if (status != NFM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
      _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
      _NFM_num ("COMP ITEM IN : Reset Proc Locks : status = <0x%.8x>\n", 
      NFM_E_FAILURE);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      return (NFM_E_FAILURE);
    }
  }


  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    ERRload_struct (NFM, NFM_E_SYS_TIME, "", NULL);
    _NFM_num ("COMP ITEM IN : Get Date & Time : status = <0x%.8x>\n",
    NFM_E_SYS_TIME);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SYS_TIME);     
  }

  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    ERRload_struct (NFM, NFM_E_SYS_TIME, "", NULL);
    _NFM_num ("COMP ITEM IN : Get Date & Time : status = <0x%.8x>\n",
    NFM_E_SYS_TIME);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SYS_TIME);     
  }
 
  /* If check_in FROM storage_name is passed in, get the information from */
  /* database and put in the global variable. If the storage_name is not */
  /* passed in, check to see if the temporary storage area has been      */
  /* created in the storage table with the passed in node name, user_name*/
  /* and path, and store the information in the global variable. */

  if (strlen (storage_name))
  {
    status = _NFMsa_info (storage_name);
    if (status != NFM_S_SUCCESS)
    {
       _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
       ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
       _NFM_num ("COMP ITEM IN : Get Sa Info : status = <0x%.8x>\n",
       NFM_E_BAD_ST_AREA);
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
      _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
      ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
      _NFM_num ("COMP ITEM IN : Add Temp SA : status = <0x%.8x>\n",
      NFM_E_BAD_ST_AREA);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      return (NFM_E_BAD_ST_AREA);     
    }
  }
  else
  {
    ERRload_struct (NFM, NFM_E_BAD_ST_AREA, "", NULL);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    _NFM_num ("COMP ITEM IN : Bad Storage : status = <0x%.8x>\n",
    NFM_E_BAD_ST_AREA);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_BAD_ST_AREA);     
  }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("COMP ITEM IN : MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_MEM);     
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("COMP ITEM IN : MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_MEM);     
  }

  /* set-up list (column) */

  status = NFMget_move_files_list (user_id, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, "", NULL);
    _NFM_num ("COMP ITEM IN : Move Buffer : status = <0x%.8x>\n", 
    NFM_E_BAD_TEMPLATE);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_BAD_TEMPLATE);     
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  data1  = (char **) data_list -> data_ptr;
  i = -1; j = -1; k = -1; l = -1; m = -1;

  for (x = 0; x < attr_list -> rows; ++x)
  {
    count = attr_list -> columns * x;

    if (! strcmp (data [count + INDEX_N_NAME], "n_catalogname"))
      i = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_itemno"))
      j = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_type"))
      k = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_status"))
      l = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileversion"))
      m = x;
  }

  row_init = 0;  row_final = data_list -> rows;
  strcpy (cat_name, data1 [i]);

  sprintf (temp_cat,  "%s", data1 [i]);

  item_no = atol (NFMitem_ptr->cat_item.n_itemno.data_value);


  /******************* DUR  11/29/90 *******************/
  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    _NFM_num ("NFMcomplete_item_checkin: Stop Transaction:<0x%.8x>\n",
    NFM_E_FAILURE);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_FAILURE);
  }

  /******************* DUR  12/6/90 *******************
  sprintf (sql_str, "LOCK TABLES f_%s IN EXCLUSIVE MODE", temp_cat);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    status = NFMlock_table_retry (sql_str);
    if (status != NFM_S_SUCCESS)
    {
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFM_num ("NFMcomplete_item_checkin: SQLstmt: <0x%.8x>\n",
    NFM_E_SQL_STMT);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SQL_STMT);
    }
  }
  ******************* end of code added  *******************/

  sprintf (file_cat, "f_%s", temp_cat);
  status = NFMlock_table (file_cat);
  if (status != NFM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    _NFM_num ("NFMcomplete_item_checkin: NFMlock_table: <0x%.8x>\n",
    NFM_E_FAILURE);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_FAILURE);
  }

  /*
  if (NFMmsg_ptr.debug_on)
  MEMprint_buffers ("data_list, in comp_it_ch b4 enter NFMget_ci_files_list", 
                     data_list, "/usr2/nfmadmin/buffers");
  */

  /* set-up list (data), and insert one row to f_<catalog> for each file  */
  /* that is associated with the item, if the operation fails after this  */
  /* call, the record(s) need to be DELETED. */

  status = _NFMget_ci_files (user_id, row_init, row_final,
               attr_list, data_list, list, 0); 
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    NFMrollback_transaction (0);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    ERRload_struct (NFM, NFM_E_BAD_FILE, "", NULL);
    _NFM_num ("NFMcomplete_item_checkin: _NFMget_ci_files = <0x%.8x>\n",
    NFM_E_BAD_FILE);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_BAD_FILE);               
  }
  /******************* DUR  12/6/90 *******************/
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFM_num ("START TRANS : Commit Work : status = <%d>\n",
    status);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (status);
  }
  /******************* end of code added  *******************/

  status = _NFMmv_files_out (user_id, STO_info.sano, passwd, &list);
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_out (user_id, &list);
    MEMclose (&list);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    _NFMdel_fcat_fileno (data_list->rows, cat_name); 
    _NFM_num ("COMP ITEM IN : Move Ci Files : status = <0x%.8x>\n",
    NFM_E_ITEM_IN_TRANS);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_ITEM_IN_TRANS);               
  }


  /*
  mb_time1 = times (&mb_tms1); 
  */

  status = NFMcopy_in_files (user_id, &list);
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_out (user_id, &list);
    MEMclose (&list);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    _NFMdel_fcat_fileno (data_list->rows, cat_name); 
    _NFM_num ("COMP ITEM IN : Copy Ci Files : status = <0x%.8x>\n",
    NFM_E_ITEM_IN_TRANS);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_ITEM_IN_TRANS);               
  }
  /******************* DUR  12/6/90 *******************/
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFM_num ("START TRANS : Commit Work : status = <%d>\n",
    NFM_E_SQL_STMT);
    NFMundo_move_files_out (user_id, &list);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    _NFMdel_fcat_fileno (data_list->rows, cat_name); 
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SQL_STMT);
  }
  /*
  sprintf (sql_str, "LOCK TABLES f_%s IN EXCLUSIVE MODE", temp_cat);
  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    status = NFMlock_table_retry (sql_str);
    if (status != NFM_S_SUCCESS)
    {
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFM_num ("START TRANS : LOCK FILE CATALOG TABLE (3) : status = <%d>\n",
    NFM_E_SQL_STMT);
    NFMundo_move_files_out (user_id, &list);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    _NFMdel_fcat_fileno (data_list->rows, cat_name); 
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_SQL_STMT);
    }
  }
  */
  /******************* end of code added  *******************/
  status = NFMlock_table (file_cat);
  if (status != NFM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    NFMundo_move_files_out (user_id, &list);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    _NFMdel_fcat_fileno (data_list->rows, cat_name); 
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_FAILURE);
  }

  /* this will update the records in <catalog> and f_<catalog> */

  status = _NFMupd_ci_cat_fcat (user_id,
           NFMglobal.NFMusername, datetime, STO_info.sano, row_init, row_final,
           temp_cat, item_no, attr_list, data_list, list); 
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_out (user_id, &list);
    MEMclose (&list);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    _NFMdel_fcat_fileno (data_list->rows, cat_name); 
    ERRload_struct (NFM, NFM_E_CORRUPTED_CATALOG, "", NULL);
    _NFM_num ("COMP ITEM IN : Get Ci Files List : status = <0x%.8x>\n",
    NFM_E_CORRUPTED_CATALOG);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_CORRUPTED_CATALOG);               
  }

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_out (user_id, &list);
    _NFMs_temp_flag (WFinfo.catalog_name, temp_flag, 1);
    _NFMdel_fcat_fileno (data_list->rows, cat_name); 
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
    _NFM_num ("COMP ITEM IN : Start Transaction : status = <0x%.8x>\n",
    NFM_E_FAILURE);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_FAILURE);
  }

  del_status = _NFMdel_in_files (user_id, STO_info.sano, passwd, &list);
  if (del_status != NFM_S_SUCCESS)
  {
    _NFM_num ("COMP ITEM IN : Del Ci Files : status = <0x%.8x>\n",
    del_status);
  }

  /*
  mb_time1 = times (&mb_tms1); 
  */

  pur_status = _NFMpur_item_files (user_id, temp_cat, item_no);
  if (pur_status != NFM_S_SUCCESS)
  {
    _NFM_num ("COMP ITEM IN : Purge Files : status = <0x%.8x>\n",
    pur_status);
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("COMP ITEM IN : MEM Close : status = <0x%.8x>\n", NFM_E_MEM);
  }

  /*
  mb_time2 = times (&mb_tms2);
  mb_total = mb_time2 - mb_time1;

  if ( !NFMmsg_ptr.debug_on)
  {
    NFMmsg_ptr.debug_on = 1;
    strcpy (NFMmsg_ptr.debug_file, "/usr2/nfmadmin/time_ci.new");
    _NFM_num ("after complete_item_check_in, mb_total = %d", mb_total);
    _NFM_num ("utime = %d", mb_tms2.tms_utime - mb_tms1.tms_utime);
    _NFM_num ("stime = %d", mb_tms2.tms_stime - mb_tms1.tms_stime);
    NFMmsg_ptr.debug_on = 0;
  }
  */


  if (NFMmsg_ptr.debug_on)
  _NFM_num ("COMP ITEM IN : SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  free (NFMitem_ptr);
  MEMclose (&CAT_list);
  return (NFM_S_SUCCESS);     
}
