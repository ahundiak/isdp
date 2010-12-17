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


extern MSGptr NFMmsg_ptr;
extern struct NFMitem_info *NFMitem_ptr;
extern MEMptr CAT_list;
extern struct WFstruct WFinfo;
extern struct sto_area_info STO_info;

/*
extern long     mb_time1, mb_time2, mb_total;
extern struct   tms mb_tms1, mb_tms2;
*/


long NFMprepare_item_copy (user_id, cat_name, item_name, item_rev,
                           attr_list, data_list)
long    user_id;
char    *cat_name, *item_name, *item_rev;
MEMptr  *attr_list, *data_list;
{
  long     status;
  long     item_no;
  long     NFMcheck_member_online ();
  struct   tms tmp_tms;
  long     elp_time;

  /*
  mb_time1 = times (&mb_tms1);
  */
  if (NFMmsg_ptr.debug_on)
  {
  _NFM_str ("NFMprepare_item_copy : Cat  Name = <%s>  ", cat_name );
  _NFM_str ("NFMprepare_item_copy : Item Name = <%s>  ", item_name);
  _NFM_str ("NFMprepare_item_copy : Item Rev  = <%s>\n", item_rev );
  }

  status = NFMcheck_process_locks (user_id);
  if (status != NFM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, NULL);
    _NFM_num ("NFMprepare_item_copy : Check Process Lock: <0x%.8x>\n",
    NFM_E_BAD_COMMAND_ORDER);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  NFMitem_ptr = (struct NFMitem_info *) calloc 
                                        (1, sizeof (struct NFMitem_info));
  if (! NFMitem_ptr )
  {
    ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_str ("NFMprepare_item_copy: Failed to malloc global NFMitem_ptr");
    return (NFM_E_MEM);
  }


  status = _NFMget_cat_fcat_no (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, NULL);
    _NFM_num ("NFMprepare_item_copy: NFMget_cat_fcat_no: <0x%.8x>\n",
    NFM_E_BAD_ATTR_VALUE);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  status = _NFMprepare_item_info (item_name, item_rev);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, NULL);
    _NFM_num ("NFMprepare_item_copy: NFMprepare_item_info: <0x%.8x>\n",
    NFM_E_BAD_ATTR_VALUE);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  status = _NFMprepare_item_values (cat_name, item_name, item_rev);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    _NFM_num ("NFMprepare_item_copy: _NFMprepare_item_values  <0x%.8x>",
    NFM_E_BAD_ATTR_VALUE);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, NULL);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  item_no = atol (NFMitem_ptr->cat_item.n_itemno.data_value);

  if (! strcmp (NFMitem_ptr->cat_item.n_itemlock.data_value, "Y"))
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_ITEM_LOCKED, NULL);
    _NFM_num ("NFMprepare_item_copy item locked: status = <0x%.8x>",
                                                           NFM_E_ITEM_LOCKED);
    return (NFM_E_ITEM_LOCKED);
  }

  status = _NFMg_fileversion (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (NFMitem_ptr);
    ERRload_struct (NFM, NFM_E_BAD_ATTR_VALUE, NULL);
    _NFM_num ("NFMprepare_item_checkout: _NFMg_pending_flag: <0x%.8x> \n",
    NFM_E_BAD_ATTR_VALUE);
    return (NFM_E_BAD_ATTR_VALUE);
  }

  status = _NFMchk_item (cat_name, item_name, item_rev, NFM_ITEM_COPY);
  if (status != NFM_S_SUCCESS)
  {
    _NFM_num ("NFMprepare_item_copy : Check Co Flag: <0x%.8x>\n", status);
    free (NFMitem_ptr);
    return (status);
  }

  status = _NFMq_co_attr (user_id, cat_name, attr_list, data_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    MEMclose (data_list);
    free (NFMitem_ptr);
    _NFM_num ("NFMprepare_item_copy : Get Co Attr: <0x%.8x>\n", status);
    return (status);
  }

  status = _NFMg_item_co_info (user_id, cat_name, *attr_list, *data_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    MEMclose (data_list);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    _NFM_num ("NFMprepare_item_copy : Get Ci Attr: <0x%.8x>\n", status);
    return (status);        
  }

  status = NFMset_process_lock (user_id, NFM_I_PL_CP_ITEM);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (attr_list);
    MEMclose (data_list);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    _NFM_num ("NFMprepare_item_copy : Item Out Process Lock:  <0x%.8x>\n",
    status);
    return (status);
  }


  if (NFMmsg_ptr.debug_on)
  _NFM_num ("NFMprepare_item_copy : SUCCESSFUL:  <0x%.8x>\n", NFM_S_SUCCESS);

  /*
  mb_time2 = times (&mb_tms2);
  mb_total = mb_time2 - mb_time1;
  if ( !NFMmsg_ptr.debug_on )
  {
    NFMmsg_ptr.debug_on = 1;
    strcpy (NFMmsg_ptr.debug_file, "/usr2/nfmadmin/time_ci.new");
    _NFM_num ("after prepare_item_copy, mb_total = %d", mb_total);
    _NFM_num ("utime = %d", mb_tms2.tms_utime - mb_tms1.tms_utime);
    _NFM_num ("stime = %d", mb_tms2.tms_stime - mb_tms1.tms_stime);
    NFMmsg_ptr.debug_on = 0;
  }
  */

  return (NFM_S_SUCCESS);
}

long NFMcancel_item_copy (user_id, attr_list, data_list)
long    user_id;
MEMptr  attr_list;
MEMptr  data_list;
{
  long     status;

  if (NFMmsg_ptr.debug_on)
  _NFM_str ("NFMcancel_item_copy: enter");

  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CP_ITEM))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, NULL);
    _NFM_num ("CAN ITEM CPY : Check Process Lock : status = <0x%.8x>\n",
    NFM_E_BAD_COMMAND_ORDER);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CP_ITEM)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CP_ITEM);
    if (status != NFM_S_SUCCESS)
    {
      _NFM_num ("CAN ITEM CPY : Reset Process Lock : status = <0x%.8x>\n", 
      status);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      return (status);
    }
  }

  free (NFMitem_ptr);
  MEMclose (&CAT_list);
  _NFM_num ("CAN ITEM CPY : SUCCESSFUL : status = <0x%.8x>\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);     
}

long NFMcomplete_item_copy (user_id, storage_name,
                            node_name, user_name, passwd, path_name,
                            attr_list, data_list)
long    user_id;
char    *storage_name;
char    *node_name, *user_name, *passwd, *path_name;
MEMptr  attr_list, data_list;
{
  long       status;
  char       c_user [50];
  long       item_no, sa_no, row_init, row_final;
  long       x, y, count;
  MEMptr     list = NULL;
  char       **data, **column, **data1;
  char       temp_cat [100], temp_item [100], temp_rev [100];
  struct     tms tmp_tms;
  long       elp_time;

  /*
  mb_time1 = times (&mb_tms1);
  */
  if (NFMmsg_ptr.debug_on)
  {
  _NFM_str ("NFMcomplete_item_copy : ST   Name = <%s>  ", storage_name);
  _NFM_str ("NFMcomplete_item_copy : Node Name = <%s>  ", node_name   );
  _NFM_str ("NFMcomplete_item_copy : User Name = <%s>  ", user_name   );
  _NFM_str ("NFMcomplete_item_copy : Passwd    = <%s>  ", passwd      );
  _NFM_str ("NFMcomplete_item_copy : Path Name = <%s>\n", path_name   );
  }

  status = NFMcheck_process_locks (user_id);
  if ((status != NFM_S_SUCCESS) && (status != NFM_I_PL_CP_ITEM))
  {
    ERRload_struct (NFM, NFM_E_BAD_COMMAND_ORDER, NULL);
    _NFM_num ("NFMcomplete_item_copy : Check Process Lock: <0x%.8x>\n",
    NFM_E_BAD_COMMAND_ORDER);
    return (NFM_E_BAD_COMMAND_ORDER);
  }

  if (status == NFM_I_PL_CP_ITEM)
  {
    status = NFMreset_process_lock (user_id, NFM_I_PL_CP_ITEM);
    if (status != NFM_S_SUCCESS)
    {
      _NFM_num ("NFMcomplete_item_copy : Reset Process Lock: <0x%.8x>\n",
      status);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      return (status);
    }
  } 

  /***
  status = NFMget_datetime (datetime);
  if (status != NFM_S_SUCCESS)
  {
    _NFM_num ("NFMcomplete_item_copy : Get Date & Time : status = <0x%.8x>\n",
    status);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (status);
  }
  ***/

  if (strlen (storage_name))
  {
    status = _NFMsa_info (storage_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFM_num ("NFMcomplete_item_copy : Get Sa Info: <0x%.8x>\n", status);
      free (NFMitem_ptr);
      MEMclose (&CAT_list);
      ERRload_struct (NFM, NFM_E_BAD_ST_AREA, NULL);
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
      _NFM_num ("NFMcomplete_item_copy : Add Temp SA: <0x%.8x>\n", 
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
    _NFM_num ("NFMcomplete_item_copy : Bad Storage: <0x%.8x>\n", 
    NFM_E_BAD_ST_AREA);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_BAD_ST_AREA);     
  }

  status = MEMbuild_array (attr_list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("NFMcomplete_item_copy : MEM Build Array: <0x%.8x>\n",
    NFM_E_MEM);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_MEM);
  }

  status = MEMbuild_array (data_list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("NFMcomplete_item_copy : MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (NFM_E_MEM);
  }

  status = NFMget_move_files_list (user_id, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFM_num ("NFMcomplete_item_copy : Move Buffer: <0x%.8x>\n", 
    NFM_E_BAD_TEMPLATE);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    ERRload_struct (NFM, NFM_E_BAD_TEMPLATE, NULL);
    return (NFM_E_BAD_TEMPLATE);
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  data1  = (char **) data_list -> data_ptr;

  row_init = 0;  row_final = data_list -> rows;

  sprintf (temp_cat,  "%s", WFinfo.catalog_name );
   
  item_no = atol (NFMitem_ptr->cat_item.n_itemno.data_value);

  status = _NFMget_co_files (user_id, row_init, row_final,
              attr_list, data_list, list, 0);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFM_num ("NFMcomplete_item_copy : Get Ci Files List : status = <0x%.8x>\n",
    status);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (status);               
  }

  status = _NFMmv_files_in (user_id, STO_info.sano, passwd, &list);
  if (status != NFM_S_SUCCESS)
  {
    NFMundo_move_files_in (user_id, sa_no, passwd, &list);
    MEMclose (&list);
    _NFM_num ("NFMcomplete_item_copy : Move Co Files : status = <0x%.8x>\n",
    status);
    free (NFMitem_ptr);
    MEMclose (&CAT_list);
    return (status);               
  }

  /*
  mb_time1 = times (&mb_tms1);
  */

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, NULL);
    _NFM_num ("COMP ITEM OUT : MEM Close : status = <0x%.8x>\n", NFM_E_MEM);
  }

  free (NFMitem_ptr);
  MEMclose (&CAT_list);
  _NFM_num ("NFMcomplete_item_copy : SUCCESSFUL: <0x%.8x>\n", NFM_S_SUCCESS);

  /*
  mb_time2 = times (&mb_tms2);
  mb_total = mb_time2 - mb_time1;
  if ( !NFMmsg_ptr.debug_on )
  {
    NFMmsg_ptr.debug_on = 1;
    strcpy (NFMmsg_ptr.debug_file, "/usr2/nfmadmin/time_ci.new");
    _NFM_num ("after complete_item_copy, mb_total = %d", mb_total);
    _NFM_num ("utime = %d", mb_tms2.tms_utime - mb_tms1.tms_utime);
    _NFM_num ("stime = %d", mb_tms2.tms_stime - mb_tms1.tms_stime);
    NFMmsg_ptr.debug_on = 0;
  }
  */

  return (NFM_S_SUCCESS);     
}

long _NFMs_temp_flag (cat_name, temp_state, lock_flag)
char    *cat_name;
char    *temp_state;
int     lock_flag; /* 1 - lock the table */
                   /* 0 - don't lock the table */
{
  long    status;
  char    sql_str [1024], value [50];
  char    n_attr [50], n_dtype [50];
  char    n_attr1 [50], n_dtype1 [50];
  long   item_no;
  char    *fname="_NFMs_temp_flag";

  if (NFMmsg_ptr.debug_on)
  {
  _NFM_str ("_NFMs_temp_flag: enter...");
  _NFM_str ("_NFMs_temp_flag: Cat  Name  = <%s>  ", cat_name  );
  _NFM_str ("_NFMs_temp_flag: Temp State = <%s>\n", temp_state);
  }

  if (! strncmp (NFMitem_ptr->cat_item.n_itemno.attr_dtype, "char", 4))
    sprintf (value, "'%s'", NFMitem_ptr->cat_item.n_itemno.data_value);
  else
    sprintf (value, "%s", NFMitem_ptr->cat_item.n_itemno.data_value);
 

  /* n_coout is not allowed to be changed by the applications. */

  sprintf (sql_str,  "UPDATE %s SET n_status = '%s' WHERE %s = %s ",
           cat_name, temp_state, NFMitem_ptr->cat_item.n_itemno.attr_name, 
           value);

  if (lock_flag)
  {
    status = NFMlock_table (cat_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n", status) );
      return (status);
    }
  }

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_SQL_STMT, NULL);
    _NFM_num ("_NFMs_temp_flag: SQL Stmt Syntax : status = <0x%.8x>\n", 
    NFM_E_SQL_STMT);
    return (NFM_E_SQL_STMT);
  }

  if (lock_flag)
  {
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ( (fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status) );
      return (status);
    }
  }
  _NFM_num ("_NFMs_temp_flag: SUCCESSFUL:  <0x%.8x>\n", NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}  
