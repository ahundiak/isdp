#include "machine.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/times.h>
#include "NFMfile.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "NFMattr_def.h"
#include "NFMstruct.h"
#include "MSGstruct.h"
#include "ERR.h"

extern MSGptr NFMmsg_ptr;
extern struct NFMitem_info *NFMitem_ptr;
extern MEMptr CAT_list;
int MAX_fcat_number;
/*
extern long     mb_time1, mb_time2, mb_total;
extern struct   tms mb_tms1, mb_tms2;
*/



long _NFMget_ci_files (user_id, i_row, f_row, attr_list, 
                               data_list, file_list, type)
long    user_id;
long    i_row, f_row;
MEMptr  attr_list, data_list, file_list;
long    type;
{
  long    status;
  char    **column, **data, **data1, **column2;
  long    y, x, count;
  long    i1, j1, k1, l1, m1;
  long    i2, j2, k2, l2;
  long    i3, j3, k3, l3, m3, n3, o3, p3, q3, r3, s3;
  char    cat_name [100];
  char    file_cat[100];
  long    item_no, item_ver, new_ver, file_no;
  char    *sql_str;
  char    node_name [50], user_name [50], passwd [50];
  char    path_name [50], device_type [10];
  char    mach_id [20], op_sys [20];
  char    net_xns [10], net_tcp [10], net_dec [10];
  char    filename [50], filename1 [50], value [50];
  char    file_type [20];
  long    _NFMmake_fcat_entry ();

  if (NFMmsg_ptr.debug_on)
  {
  _NFM_num ("_NFMget_ci_files: enter ...");
  _NFM_num ("_NFMget_ci_files: Init  Row  = <%d>  ", i_row   );
  _NFM_num ("_NFMget_ci_files: Final Row  = <%d>  ", f_row   );
  _NFM_num ("_NFMget_ci_files: Type       = <%d>\n", type    );
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  data1  = (char **) data_list -> data_ptr;


  i1 = -1; j1 = -1; k1 = -1; l1 = -1; m1 = -1;
  i2 = -1; j2 = -1; k2 = -1; l2 = -1;
  i3 = -1; j3 = -1; k3 = -1; l3 = -1; m3 = -1;
  n3 = -1; o3 = -1; p3 = -1; q3 = -1; r3 = -1;

  for (x = 0; x < attr_list -> rows; ++x)
  { 
    count = attr_list -> columns * x;

    if (! strcmp (data [count + INDEX_N_NAME], "n_catalogname")) 
      i1 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_status1")) 
      j1 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_type"))   
      k1 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_level"))
      l1 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_citno"))
      m1 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_itemno"))
      i2 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_itemname"))
      j2 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_itemrev"))
      k2 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_status"))
      l2 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_itemnum"))
      i3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileno"))
      j3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileco"))
      k3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileversion"))
      l3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cisano"))
      m3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cifilename"))
      n3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cofilename"))
      o3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cifilesize"))
      p3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileclass"))
      q3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_filetype"))
      r3 = x;
    else if (! strcmp (data [count + INDEX_N_NAME],"n_setindicator"))
      s3 = x;
  }

  sprintf (cat_name, "%s", 
           data1 [(data_list -> columns * i_row) + i1]);

  item_no  = atol (data1 [(data_list -> columns * i_row) + i2]);
  item_ver = atol (data1 [(data_list -> columns * i_row) + l3]);
  new_ver  = item_ver + 1;


  sql_str = (char *) malloc (2 * MEM_SIZE + file_list -> row_size);
  if (! sql_str)
  {
    status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
    _NFM_num ("_NFMget_ci_files: Malloc Failed : status = <0x%.8x>\n",
    NFM_E_MALLOC);
    return (NFM_E_MALLOC);        
  }

  sprintf (file_cat, "f_%s", cat_name);
  status = NFMget_attr_value (user_id, file_cat, "MAX(n_fileno)",
           "", value);
          
  if (status != NFM_S_SUCCESS)
  {
    _NFM_num ("_NFMget_ci_files: Get Ser Slot : status = <0x%.8x>\n",
    status);
    return (status);
  }
  MAX_fcat_number = atol (value);

  for (x = i_row; x < f_row; ++x)
  {
    count = data_list -> columns * x;
    status = MEMbuild_array (file_list);
    if (status != MEM_S_SUCCESS)
    {
      free (sql_str);
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMget_ci_files: MEMBuil_Array = <0x%.8x>\n",
      NFM_E_MEM);
      return (NFM_E_MEM);        
    }
    column2 = (char **) file_list -> column_ptr;

    if (strcmp (data1 [count + i1], cat_name))
    {
      free (sql_str);
      status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
      _NFM_num ("_NFMget_ci_files: Bad Cat In Buff = <0x%.8x>\n",
      NFM_E_CORRUPTED_BUFFERS);
      return (NFM_E_CORRUPTED_BUFFERS);        
    }

    if (atol (data1 [count + i2]) != item_no)
    {
      free (sql_str);
      status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
      _NFM_num ("_NFMget_ci_files: Bad Num In Buff = <0x%.8x>\n",
      NFM_E_CORRUPTED_BUFFERS);
      return (NFM_E_CORRUPTED_BUFFERS);        
    }

    if (atol (data1 [count + l3]) != item_ver)
    {
      free (sql_str);
      status = ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
      _NFM_num ("_NFMget_ci_files: Bad Ver In Buff = <0x%.8x>\n",
      NFM_E_CORRUPTED_BUFFERS);
      return (NFM_E_CORRUPTED_BUFFERS);        
    }

    status = NFMget_sa_no_info (user_id,
                atol (data1 [count + m3]),
                node_name, user_name, passwd, path_name, device_type,
                mach_id, op_sys, net_tcp, net_xns, net_dec);
    if (status != NFM_S_SUCCESS)
    {
      free (sql_str);
      _NFM_num ("_NFMget_ci_files: St No Info = <0x%.8x>\n",
      status);
      return (status);        
    }

    strcpy (file_type, data1[count + r3]);
        
    NFMchange_case (data1 [count + j1], 0);

    _NFM_num ("_NFMget_ci_files: Type = <%s>\n", data1 [count + j1]);

    status = _NFMmake_fcat_entry (cat_name, item_no,
                                     new_ver, &file_no);
    if (status != NFM_S_SUCCESS)
    {

      free (sql_str);
      _NFM_num ("_NFMget_ci_files: _NFMmake_fcat_entry = <0x%.8x>\n",
      status);
      return (status);      
    }

    status = NFMget_file_name (user_id, NFMitem_ptr->table_no, 
                               file_no, filename);
    if (status != NFM_S_SUCCESS)
    {
      free (sql_str);
      _NFM_num ("_NFMget_ci_files: NFMget_file_name = <0x%.8x>\n",
      status);
      return (status);      
    }

    sprintf (value, "%d", file_no);

    _NFM_str ("_NFMget_ci_files : File Name = <%s>", filename);

    sql_str [0] = 0;

    for (y = 0; y < file_list -> columns; ++y)
    {
      _NFM_str ("_NFMget_ci_files : Col Name = <%s>", column2 [y]);

      if (! strcmp (column2 [y], "n_status"))
      {
        if ((! strcmp (data1 [count + k3], "Y")) ||
            (! strcmp (data1 [count + l2], ""))  ||
            (! strcmp (data1 [count + l3], "0")))
          strcat (sql_str, "move");
        else
          strcat (sql_str, "copy");
      }
      else if (! strcmp (column2 [y], "n_fileno"))
        strcat (sql_str, value);
      else if (! strcmp (column2 [y], "n_sano"))
        strcat (sql_str, data1 [count + m3]);
      else if (! strcmp (column2 [y], "n_nodename"))
        strcat (sql_str, node_name);
      else if (! strcmp (column2 [y], "n_username"))
        strcat (sql_str, user_name);
      else if (! strcmp (column2 [y], "n_passwd"))
        strcat (sql_str, passwd);
      else if (! strcmp (column2 [y], "n_pathname"))
        strcat (sql_str, path_name);
      else if (! strcmp (column2 [y], "n_devicetype"))
        strcat (sql_str, device_type);
      else if (! strcmp (column2 [y], "n_machid"))
        strcat (sql_str, mach_id);
      else if (! strcmp (column2 [y], "n_opsys"))
        strcat (sql_str, op_sys);
      else if (! strcmp (column2 [y], "n_tcpip"))
        strcat (sql_str, net_tcp);
      else if (! strcmp (column2 [y], "n_xns"))
        strcat (sql_str, net_xns);
      else if (! strcmp (column2 [y], "n_decnet"))
        strcat (sql_str, net_dec);
      else if (! strcmp (column2 [y], "n_cifilename"))
      {
        if (strlen (data1 [count + n3]))
          strcat (sql_str, data1 [count + n3]);
        else 
          strcat (sql_str, filename);
      }
      else if (! strcmp (column2 [y], "n_cofilename"))
      {
        if (! strlen (data1 [count + o3]))
        {
          free (sql_str);
          status = ERRload_struct (NFM, NFM_E_BAD_FILE_NAME, "", NULL);
          _NFM_num ("_NFMget_ci_files: No COF Name = <0x%.8x>\n",
          NFM_E_BAD_FILE_NAME);
          return (NFM_E_BAD_FILE_NAME);      
        }
        else
          strcat (sql_str, data1 [count + o3]);
      }
      else if (! strcmp (column2 [y], "n_cifilesize"))
        strcat (sql_str, "-1");
      else if (! strcmp (column2 [y], "n_filetype"))
        strcat (sql_str, file_type);
 
      strcat (sql_str, "\1");
    }

    _NFM_str ("NFMget_ci_files_list: sql_str = %s \n", sql_str);
    status = MEMwrite (file_list, sql_str);
    if (status != MEM_S_SUCCESS)
    {
      free (sql_str);
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("CI FILE LST : MEM Write : status = <0x%.8x>\n",
      NFM_E_MEM);
      return (NFM_E_MEM);      
    }           
  }

  free (sql_str);
     
  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMget_ci_files: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);    
}

long _NFMmake_fcat_entry ( cat_name, item_no,
                           item_ver, file_no)
char      *cat_name;
long      item_no, item_ver;
long      *file_no;
{
  long     status;
  char     file_cat [100];
  MEMptr   attr_list = NULL;
  char     **column, **data;
  long     x, y, count, comma;
  char     sql_str[1024], sql_str1[1024], value [50];

  *file_no = 0;

  if (NFMmsg_ptr.debug_on)
  {
  _NFM_num ("_NFMmake_fcat_entry: enter");
  _NFM_str ("_NFMmake_fcat_entry: Cat  Name = <%s>  ", cat_name);
  _NFM_num ("_NFMmake_fcat_entry: Item No   = <%d>  ", item_no );
  _NFM_num ("_NFMmake_fcat_entry: Item Ver  = <%d>  ", item_ver);
  _NFM_num ("_NFMmake_fcat_entry: File No   = <%d>\n", *file_no);
  }

  sprintf (sql_str, "INSERT INTO f_%s (", cat_name);
  sprintf (sql_str1, ") VALUES (");

  strcat (sql_str, NFMitem_ptr->fcat_item.n_itemnum.attr_name);
  if (! strncmp (NFMitem_ptr->fcat_item.n_itemnum.attr_dtype, "char",4))
  {
    strcat (sql_str1, "'");
    strcat (sql_str1, NFMitem_ptr->cat_item.n_itemno.data_value);
    strcat (sql_str1, "'");
  }
  else 
    strcat (sql_str1, NFMitem_ptr->cat_item.n_itemno.data_value);

  strcat (sql_str, ", ");
  strcat (sql_str1, ", ");
  strcat (sql_str, NFMitem_ptr->fcat_item.n_fileversion.attr_name);
  sprintf (value, "%d", item_ver);

  if (! strncmp (NFMitem_ptr->fcat_item.n_fileversion.attr_dtype, 
                 "char",4))
  {
    strcat (sql_str1, "'");
    strcat (sql_str1, value);
    strcat (sql_str1, "'");
  }
  else
    strcat (sql_str1, value); 

  *file_no = ++MAX_fcat_number;
  sprintf (value, "%d", *file_no);

  /* n_fileno and it's type is not expected to change by applications */
  strcat (sql_str, ", ");
  strcat (sql_str1, ", ");
  strcat (sql_str, "n_fileno");
  strcat (sql_str1, value);

  strcat (sql_str, sql_str1);
  strcat (sql_str, ")");

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&attr_list);
    status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFM_num ("CI F CAT ENT : SQL Query Failed : status = <0x%.8x>\n",
    NFM_E_SQL_STMT);
    return (NFM_E_SQL_STMT);       
  }


  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMmake_fcat_entry: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);    
}

long _NFMupd_ci_cat_fcat   ( user_id, c_user, datetime, sa_no,
                             i_row, f_row, cat_name, item_no,
                             attr_list, data_list, file_list)
long      user_id;
char      *c_user, *datetime;
long      sa_no, i_row, f_row;
char      *cat_name;
long      item_no;
MEMptr    attr_list, data_list, file_list;
{
  long     status;
  char     file_cat [100];
  char     **column, **data, **data1;
  char     **column2, **data2;
  char     **column3, **data3;
  long     x, y, z;
  long     count, count1, count2, count3;
  long     i, j, k, l;
  char     *sql_str, sql_str1 [1024], value [129];
  char     sql_str2 [1024], sql_str3 [1024];
  long     update, update1, comma, found;
  MEMptr   list=NULL;

   
  if (NFMmsg_ptr.debug_on)
  {
  _NFM_str ("_NFMupd_ci_cat_fcat: enter ...");
  _NFM_str ("_NFMupd_ci_cat_fcat: User       = <%s>  ", c_user   );
  _NFM_str ("_NFMupd_ci_cat_fcat: Date       = <%s>  ", datetime   );
  _NFM_num ("_NFMupd_ci_cat_fcat: Sa    No   = <%d>  ", sa_no    );
  _NFM_num ("_NFMupd_ci_cat_fcat: Init  Row  = <%d>  ", i_row    );
  _NFM_num ("_NFMupd_ci_cat_fcat: final Row  = <%d>  ", f_row    );
  _NFM_str ("_NFMupd_ci_cat_fcat: Cat   Name = <%s>  ", cat_name );
  _NFM_num ("_NFMupd_ci_cat_fcat: Item  No   = <%d>\n", item_no  );
  }

  sprintf (file_cat, "f_%s", cat_name);

  status = MEMbuild_array (file_list);
  if (status != MEM_S_SUCCESS)
  {
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMupd_ci_cat_fcat: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  data1   = (char **) data_list -> data_ptr;

  column2 = (char **) file_list -> column_ptr;
  data2   = (char **) file_list -> data_ptr;

  i = -1; j = -1; k = -1;

  for (y = 0; y < file_list -> columns; ++y)
  {
     if (! strcmp (column2 [y], "n_fileno"))           i = y;
     else if (! strcmp (column2 [y], "n_cifilesize"))  j = y;
     else if (! strcmp (column2 [y], "n_status"))      k = y;
  }

  status = NFMquery_attributes_definition (user_id, "F_CATALOG",
           file_cat, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFM_num ("_NFMupd_ci_cat_fcat: Qry Cat Attr : status = <0x%.8x>\n", 
    status);
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMupd_ci_cat_fcat: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  column3 = (char **) list -> column_ptr;
  data3   = (char **) list -> data_ptr;

  sql_str = (char *) malloc (data_list -> row_size +
                                attr_list -> rows * 50 + MEM_SIZE);     
  if (! sql_str)
  {
    status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
    _NFM_num ("_NFMupd_ci_cat_fcat: Malloc Failed : status = <0x%.8x>\n", 
    NFM_E_MALLOC);
    return (NFM_E_MALLOC);
  }

  for (x = i_row; x < f_row; ++x)
  {
    count1 = data_list -> columns * x;
    count2 = file_list -> columns * x;
    update1 = 0; comma = 0;

    sql_str  [0] = 0; sql_str1 [0] = 0;
    sql_str2 [0] = 0; sql_str3 [0] = 0;

    sprintf (sql_str,  "UPDATE %s SET ", file_cat);
    sprintf (sql_str1, " WHERE ");

    sprintf (sql_str2,  "UPDATE %s SET ", file_cat);
    sprintf (sql_str3, " WHERE ");

    if ((! strcmp (data2 [count2 + k], "move"))   ||
        (! strcmp (data2 [count2 + k], "copy"))   ||
        (! strcmp (data2 [count2 + k], "delete")) ||
        (! strcmp (data2 [count2 + k], "none")))
    {
      for (y = 0; y < attr_list -> rows; ++y)
      {
        count = attr_list -> columns * y;
        update = 0; found = 0;

        _NFM_str ("Attr Name : <%s>", data [count + INDEX_N_NAME]);

        for (z = 0; ((z < list -> rows) && (! found)); ++z)
        {
          count3 = list -> columns * z;
          found = 0;
 
                                                     /* 2 == n_name */
          if ((! strcmp (data [count + INDEX_N_NAME], data3 [count3])) &&
              (! strcmp (data [count + 3], "NFM")))
                              /* 4 == n_application */
          {
            found = 1;

            if (! strcmp (data [count + INDEX_N_NAME], "n_fileno"))
            {
              strcat (sql_str1, data3 [count3]);
              strcat (sql_str1, " = ");

              if (! strncmp (data3 [count3 + 1], "char", 4))
              {
                strcat (sql_str1, "'");
                strcat (sql_str1, data2 [count2 + i]);
                strcat (sql_str1, "'");
              }
              else
                strcat (sql_str1, data2 [count2 + i]);

              strcat (sql_str3, data3 [count3]);
              strcat (sql_str3, " = ");

              if (! strncmp (data3 [count3 + 1], "char", 4))
              {
                strcat (sql_str3, "'");
                strcat (sql_str3, data1 [count1 + y]);
                strcat (sql_str3, "'");
              }
              else
                strcat (sql_str3, data1 [count1 + y]);
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_ciuser"))
            {
              sprintf (value, "%s", c_user);
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cidate"))
            {
              sprintf (value, "timestamp '%s'", datetime);
              update = 1;
            }
            /*** 3.0 Schema
            else if (! strcmp (data [count + INDEX_N_NAME], "n_citime"))
            {
              sprintf (value, "%s", c_time);
              update = 1;
            }
            ***/
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cisano"))
            {
              sprintf (value, "%s", data1 [count1 + y]);
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cosano"))
            {
              sprintf (value, "%d", sa_no);                      
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cifilename"))
            {
              sprintf (value, "%s", data1 [count1 + y]);
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cofilename"))
            {
              sprintf (value, "%s", data1 [count1 + y]);
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cifilesize"))
            {
              sprintf (value, "%s", data2 [count2 + j]);
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_fileco"))
            {
              sprintf (value, "%s", "");
              update = 1;

              if (! strcmp (data1 [count1 + y], "Y"))
              {
                update1 = 1;

                strcat (sql_str2, data3 [count3]);
                strcat (sql_str2, " = ");
  
                if (! strncmp (data3 [count3 + 1], "char", 4))
                {
                  strcat (sql_str2, "'");
                  strcat (sql_str2, "'");
                }
                else
                  strcat (sql_str2, "null");
              }
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_filetype"))
            {
              sprintf (value, "%s", data1 [count1 + y]);
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_fileclass"))
            {
              sprintf (value, "%s", "C");
              update = 1;
            }
          }
        }

        if (update)
        {
          if (comma) strcat (sql_str, ", ");
          comma = 1;

          strcat (sql_str, data3 [count3]);
          strcat (sql_str, " = ");

          if (! strncmp (data3 [count3 + 1], "char", 4))
          {
            strcat (sql_str, "'");
            strcat (sql_str, value);
            strcat (sql_str, "'");
          }
          else
          {
            if (! strlen (value)) strcat (sql_str, "null");
            else                  strcat (sql_str, value);
          }
        }
      }

      if ((! strcmp (data2 [count2 + k], "move")) ||
          (! strcmp (data2 [count2 + k], "copy")))
      {
        strcat (sql_str, sql_str1);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          free (sql_str);
          status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFM_num ("UPD CI ENT : Stmt Failed : status = <0x%.8x>\n",
          NFM_E_SQL_STMT);
          return (NFM_E_SQL_STMT);
        }
      }

      if (update1)
      {
        strcat (sql_str2, sql_str3);

        status = SQLstmt (sql_str2);
        if (status != SQL_S_SUCCESS)
        {
          free (sql_str);
          status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFM_num ("UPD CI ENT : SQL Stmt : status = <0x%.8x>\n",
          NFM_E_SQL_STMT);
          return (NFM_E_SQL_STMT);
        }
      }
    }
  }
  /* Need to clean up some of the code */

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    free (sql_str);
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFM_num ("UPD CI ENT : SQL Stmt : status = <0x%.8x>\n",
    NFM_E_SQL_STMT);
    return (NFM_E_SQL_STMT);
  }

  status = NFMlock_table (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (sql_str);
    ERRload_struct (NFM, status, "", NULL);
    _NFM_num ("UPD CI ENT : SQL Stmt : status = <0x%.8x>\n",
    status);
    return (status);
  }

  column3 = (char **) CAT_list -> column_ptr;
  data3   = (char **) CAT_list -> data_ptr;

  count1 = data_list -> columns * i_row;
  count2 = file_list -> columns * i_row;
 
  update1 = 0; comma = 0;
  
  sql_str[0] = 0; sql_str1 [0] = 0;

  sprintf (sql_str,  "UPDATE %s SET ", cat_name);
  sprintf (sql_str1, " WHERE ");

  for (y = 0; y < attr_list -> rows; ++y)
  {
    count = attr_list -> columns * y;

    found = 0;

    for (z = 0; ((z < CAT_list -> rows) && (! found)); ++z)

    {
      count3 = CAT_list -> columns * z;

      if (! strcmp (data [count + INDEX_N_NFMAPPLICATION], "NFM"))
      {
        if (! strcmp (data [count + INDEX_N_NAME], data3 [count3 + 2]))
        {
          found = 1;

          if (! strcmp (data [count + INDEX_N_NAME], "n_itemno"))
          {
            strcat (sql_str1, data3 [count3]);
            strcat (sql_str1, " = ");
    
            if (! strncmp (data3 [count3 + 1], "char", 4))
            {
              strcat (sql_str1, "'");
              strcat (sql_str1, data1 [count1 + y]);
              strcat (sql_str1, "'");
            }
            else
              strcat (sql_str1, data1 [count1 + y]);
          }
          else if (! strcmp (data [count + INDEX_N_NAME], "n_status"))
          {
            if (comma) strcat (sql_str, ", ");
            comma = 1;
   
            strcat (sql_str, data3 [count3]);
            strcat (sql_str, " = ");
  
            if (! strncmp (data3 [count3 + 1], "char", 4))
            {
              strcat (sql_str, "'");

              if ((! strcmp (data1 [count1 + y], "SN")) ||
                  (! strcmp (data1 [count1 + y], "MN")))
                strcat (sql_str, "");
              else
                strcat (sql_str, "I");

              strcat (sql_str, "'");
            }
            else
            {
              if ((! strcmp (data1 [count1 + y], "SN")) ||
                  (! strcmp (data1 [count1 + y], "MN")))
                strcat (sql_str, "%s", "");
              else
                strcat (sql_str, "%s", "I");
            }
          }
          else if (! strcmp (data [count + INDEX_N_NAME], "n_colevel"))
          {
            if (comma) strcat (sql_str, ", ");
            comma = 1;
 
            strcat (sql_str, data3 [count3]);
            strcat (sql_str, " = ");

            if (! strncmp (data3 [count3 + 1], "char", 4))
            {
              strcat (sql_str, "'");
              strcat (sql_str, "");
              strcat (sql_str, "'");
            }
            else
              strcat (sql_str, "null");
          }
        }
      }
      else
      {
        if (! strcmp (data3 [count3], data [count + INDEX_N_NAME]))
        {
          found = 1;

          if (comma) strcat (sql_str, ", ");
          comma = 1;

          strcat (sql_str, data3 [count3]);
          strcat (sql_str, " = ");
   
          if (! strncmp (data3 [count3 + 1], "char", 4))
          {
            strcat (sql_str, "'");
            strcat (sql_str, data1 [count1 + y]);
            strcat (sql_str, "'");
          }
          else
          {
            if (! strlen (data1 [count1 + y]))
              strcat (sql_str, "null");
            else
              strcat (sql_str, data1 [count1 + y]);
          }
        }
      }
    }
  }

  strcat (sql_str, sql_str1);

  status = SQLstmt (sql_str);
  if (status != SQL_S_SUCCESS)
  {
    free (sql_str);
    status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFM_num ("UPD CI ENT : SQL Stmt Failed : status = <0x%.8x>\n",
    NFM_E_SQL_STMT);
    return (NFM_E_SQL_STMT);
  }

  free (sql_str);

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMupd_ci_cat_fcat: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMupd_ci_cat_fcat: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}

long _NFMdel_fcat_fileno (rows, cat_name)
int rows;
char *cat_name;

{
  char sql_str[1024];
  long status;
  int  i, j;
  int  or;
  char value[50];

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMdel_fcat_fileno: enter...");
  sprintf (sql_str, "DELETE FROM f_%s WHERE %s = ",
           cat_name, NFMitem_ptr->fcat_item.n_itemnum.attr_name);

  if (! strncmp (NFMitem_ptr->fcat_item.n_itemnum.attr_dtype, "char",4))
  {
    strcat (sql_str, "'");
    strcat (sql_str, NFMitem_ptr->cat_item.n_itemno.data_value);
    strcat (sql_str, "'");
  }
  else
    strcat (sql_str, NFMitem_ptr->cat_item.n_itemno.data_value);

  strcat (sql_str, " AND ( ");

  or = 0;

  for (i = MAX_fcat_number, j = 0; j < rows; --i, ++j)
  {
    if (or)
      strcat (sql_str, " OR ");
    else 
      or = 1;
    
    strcat (sql_str, "n_fileno = ");
    sprintf (value, "%d", i);
    strcat (sql_str, value);
  }
  
  strcat (sql_str, " ) ");

  status = SQLstmt (sql_str);
  /* if (status = SQL_S_SUCCESS)  changed by B.W. June 5, 1991 */
  if (status != SQL_S_SUCCESS)
  {
    _NFM_num ("_NFMdel_fcat_fileno: SQLstmt = <0x%.8x>", status);
    return (status);
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMdel_fcat_fileno: exit successful");
  return (NFM_S_SUCCESS);
} 

long _NFMpur_item_files (user_id, cat_name, item_no)
long     user_id;
char     *cat_name;
long     item_no;
{
  long    status;
  char    sql_str [1024], sql_str1 [2048], *sql_str2;
  char    n_attr  [50], n_dtype  [50];
  char    n_attr1 [50], n_dtype1 [50];
  char    n_attr2 [50], n_dtype2 [50];
  char    n_attr3 [50], n_dtype3 [50];
  long    x, y,count;
  char    value [50], file_cat [100], file_name [100];
  MEMptr  list = NULL, move_list = NULL;
  char    **data, **column1, **data1;
  long    max_ver, curr_ver;
  char    node_name [50], user_name [50], passwd [50];
  char    path_name [50], device_type [10], temp[80];
  char    mach_id [20], op_sys [20];
  char    net_xns [10], net_tcp [10], net_dec [10];
  int     or;
     
  if (NFMmsg_ptr.debug_on)
  {
  _NFM_num ("_NFMpur_item_files: enter...");
  _NFM_str ("_NFMpur_item_files: Cat  Name = <%s>  ", cat_name);
  _NFM_num ("_NFMpur_item_files: Item No   = <%d>  ", item_no );
  }

  max_ver = atol (NFMitem_ptr->cat_item.n_versionlimit.data_value);

  if (max_ver < 1)
  {
    status = ERRload_struct (NFM, NFM_E_UNLIMITED_VERSIONS, "", NULL);
    _NFM_num ("_NFMpur_item_files: No Limit On Versions : status = <0x%.8x>\n",
    NFM_E_UNLIMITED_VERSIONS);
    return (NFM_E_UNLIMITED_VERSIONS);
  }

  sprintf (file_cat, "f_%s", cat_name);

  curr_ver = atol (NFMitem_ptr->fcat_item.n_fileversion.data_value) + 1;

  if (! strncmp (NFMitem_ptr->fcat_item.n_itemnum.attr_dtype, "char", 4))
    sprintf (sql_str, " WHERE %s = '%d'",
                        NFMitem_ptr->fcat_item.n_itemnum.attr_name,
                        item_no);
  else
    sprintf (sql_str, " WHERE %s = %d",
                        NFMitem_ptr->fcat_item.n_itemnum.attr_name,
                        item_no);

  if (curr_ver > max_ver)
  {
    if (! strncmp (NFMitem_ptr->fcat_item.n_fileversion.attr_dtype, 
                   "char", 4))
                         /* n_fileno, n_cisano are expected not to be changed */
                         /* by other applications. */
      sprintf (sql_str1,
                   "SELECT %s, %s, %s, %s %s FROM %s %s AND %s <= '%d'",
                   "n_fileno", "n_cisano", 
                   NFMitem_ptr->fcat_item.n_cifilename.attr_name,
                   NFMitem_ptr->fcat_item.n_fileversion.attr_name, 
                   "n_cifilesize",
                   file_cat, 
                   sql_str, 
                   NFMitem_ptr->fcat_item.n_fileversion.attr_name, 
                   curr_ver - max_ver);
    else
      sprintf (sql_str1,
                   "SELECT %s, %s, %s, %s, %s FROM %s %s AND %s <= %d",
                   "n_fileno", "n_cisano", 
                   NFMitem_ptr->fcat_item.n_cifilename.attr_name,
                   NFMitem_ptr->fcat_item.n_fileversion.attr_name, 
                   "n_cifilesize",
                   file_cat, 
                   sql_str, 
                   NFMitem_ptr->fcat_item.n_fileversion.attr_name, 
                   curr_ver - max_ver);

    status = SQLquery (sql_str1, &list, MEM_SIZE);
    if (status != SQL_S_SUCCESS && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&list);
      status = ERRload_struct (NFM,  NFM_E_SQL_QUERY, "", NULL);
      _NFM_num ("_NFMpur_item_files: SQL Query Syntax : status = <0x%.8x>\n",
      NFM_E_SQL_QUERY);
      return ( NFM_E_SQL_QUERY);
    }

    status = MEMbuild_array (list);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMpur_item_files: MEM Build Array : status = <0x%.8x>\n",
      NFM_E_MEM);
      return (NFM_E_MEM);
    }

    data = (char **) list -> data_ptr;

    status = NFMget_move_files_list (user_id, &move_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      MEMclose (&move_list);
      _NFM_num ("_NFMpur_item_files: Move List : status = <0x%.8x>\n",
      status);
      return (status);
    }

    sql_str2 = (char *) malloc (move_list -> row_size + MEM_SIZE);
    if (! sql_str2)
    {
      MEMclose (&list);
      MEMclose (&move_list);
      status = ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
      _NFM_num ("_NFMpur_item_files: Malloc Failed : status = <0x%.8x>\n",
      NFM_E_MALLOC);
      return (NFM_E_MALLOC);
    }

    for (x = 0; x < list -> rows; ++x)
    {
      count = list -> columns * x;
      sql_str2[0] = 0; 

      if (atol (data[count+3]) && strlen (data[count+1]) 
                               && strlen (data[count+4]) )
      {
      status = NFMget_file_name (user_id, NFMitem_ptr->table_no,
                  atol (data [count]), file_name);
      if (status != NFM_S_SUCCESS)
      {
        free (sql_str2);
        MEMclose (&list);
        MEMclose (&move_list);
        _NFM_num ("_NFMpur_item_files: Get File Name : status = <0x%.8x>\n",
        status);
        return (status);
      }

      status = NFMget_sa_no_info (user_id, atol (data [count + 1]),
                node_name, user_name, passwd, path_name, device_type,
                mach_id, op_sys, net_tcp, net_xns, net_dec);
      if (status != NFM_S_SUCCESS)
      {
        free (sql_str2);
        MEMclose (&list);
        MEMclose (&move_list);
        _NFM_num ("_NFMpur_item_files: Get Sa no Info : status = <0x%.8x>\n",
        status);
        return (status);
      }
      }
      else
      {
        strcpy (file_name, "\0");
        strcpy (node_name, "\0"); strcpy (user_name, "\0");
        strcpy (passwd, "\0"); strcpy (path_name, "\0");
        strcpy (device_type, "\0"); strcpy (mach_id, "\0");
        strcpy (op_sys, "\0"); strcpy (net_tcp, "\0");
        strcpy (net_xns, "\0"); strcpy (net_dec, "\0");
      }

      status = MEMbuild_array (move_list);
      if (status != MEM_S_SUCCESS)
      {
        free (sql_str2);
        MEMclose (&list);
        MEMclose (&move_list);
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFM_num ("_NFMpur_item_files: MEM Build Array : status = <0x%.8x>\n",
        NFM_E_MEM);
        return (NFM_E_MEM);
      }

      column1 = (char **) move_list -> column_ptr;
      data1   = (char **) move_list -> data_ptr;
                   
      for (y = 0; y < move_list -> columns; ++y)
      {
        if (! strcmp (column1 [y], "n_status") )
          if (atol (data[count+3]) && strlen(data[count+1])
                                   && strlen(data[count+4]))
            strcat (sql_str2, "delete");
          else 
            strcat (sql_str2, "none");
        else if (! strcmp (column1 [y], "n_fileno"))
          strcat (sql_str2, data [count]);
        else if (! strcmp (column1 [y], "n_sano"))
          strcat (sql_str2, data [count + 1]);
        else if (! strcmp (column1 [y], "n_nodename"))
          strcat (sql_str2, node_name);
        else if (! strcmp (column1 [y], "n_username"))
          strcat (sql_str2, user_name);
        else if (! strcmp (column1 [y], "n_passwd"))
          strcat (sql_str2, passwd);
        else if (! strcmp (column1 [y], "n_pathname"))
          strcat (sql_str2, path_name);
        else if (! strcmp (column1 [y], "n_devicetype"))
          strcat (sql_str2, device_type);
        else if (! strcmp (column1 [y], "n_machid"))
          strcat (sql_str2, mach_id);
        else if (! strcmp (column1 [y], "n_opsys"))
          strcat (sql_str2, op_sys);
        else if (! strcmp (column1 [y], "n_tcpip"))
          strcat (sql_str2, net_tcp);
        else if (! strcmp (column1 [y], "n_xns"))
          strcat (sql_str2, net_xns);
        else if (! strcmp (column1 [y], "n_decnet"))
          strcat (sql_str2, net_dec);
        else if (! strcmp (column1 [y], "n_cifilename"))
          strcat (sql_str2, file_name);
        else if (! strcmp (column1 [y], "n_cofilename"))
          strcat (sql_str2, "");
        else if (! strcmp (column1 [y], "n_cifilesize"))
          strcat (sql_str2, "0");
        else if (! strcmp (column1 [y], "n_filetype"))
          strcat (sql_str2, "");

        strcat (sql_str2, "\1");
      }
 
      status = MEMwrite (move_list, sql_str2);
      if (status != MEM_S_SUCCESS)
      {
        free (sql_str2);
        MEMclose (&list);
        MEMclose (&move_list);
        status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        _NFM_num ("_NFMpur_item_files: MEM Write : status = <0x%.8x>\n",
        NFM_E_MEM);
        return (NFM_E_MEM);
      }
    }
    free (sql_str2);

    /*
     mb_time2 = times (&mb_tms2);
     mb_total = mb_time2 - mb_time1;

     if ( !NFMmsg_ptr.debug_on)
     {
       NFMmsg_ptr.debug_on = 1;
       strcpy (NFMmsg_ptr.debug_file, "/usr2/nfmadmin/time_ci.new");
       _NFM_num ("before purge files in sto, mb_total = %d", mb_total);
       _NFM_num ("utime = %d", mb_tms2.tms_utime - mb_tms1.tms_utime);
       _NFM_num ("stime = %d", mb_tms2.tms_stime - mb_tms1.tms_stime);
       NFMmsg_ptr.debug_on = 0;
     }
    */



    status = NFMundo_move_files_out (user_id, &move_list);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      MEMclose (&move_list);
      _NFM_num ("_NFMpur_item_files: Undo Delete : status = <0x%.8x>\n",
      status);
    }

    status = MEMclose (&move_list);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMpur_item_files: MEM Close : status = <0x%.8x>\n", NFM_E_MEM);
      return (NFM_E_MEM);
    }

    /*
    mb_time1 = times (&mb_tms1);
    */

    status = NFMstop_transaction (0);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      ERRload_struct (NFM, status, "", NULL);
      _NFM_num ("_NFMpur_item_files: NFMstop_transaction = <0x%.8x>\n",
      status);
      return (status);
    }

    status = NFMlock_table (file_cat);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      ERRload_struct (NFM, NFM_E_FAILURE, "", NULL);
      _NFM_num ("_NFMpur_item_files: NFMlock_table : status = <0x%.8x>\n",
      NFM_E_FAILURE);
      return (NFM_E_FAILURE);
    }

    sprintf (sql_str, "DELETE FROM %s WHERE (", file_cat);
    or = 0;

    for (x = 0; x < list -> rows; ++x)
    {
      count = list -> columns * x;
      if (or)
        strcat (sql_str, " OR ");
      else
        or = 1;
      strcat (sql_str, "n_fileno");
      strcat (sql_str, " = ");
      strcat (sql_str, data [count]);
    }

    strcat (sql_str, ") AND n_archiveno is null ");
    

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS && (status != SQL_I_NO_ROWS_FOUND))
    {
      MEMclose (&list);
      status = ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      _NFM_num ("_NFMpur_item_files: SQL Stmt Syntax : status = <0x%.8x>\n",
      NFM_E_SQL_STMT);
      return (NFM_E_SQL_STMT);
    }
    status = NFMstart_transaction (0);
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      ERRload_struct (NFM, status, "", NULL);
      _NFM_num ("_NFMpur_item_files: NFMstart_transaction = <0x%.8x>\n",
      status);
      return (status);
    }

    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
    {
      status = ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMpur_item_files: MEM Close : status = <0x%.8x>\n", NFM_E_MEM);
      return (NFM_E_MEM);
    }
  }

  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMpur_item_files: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);     
}

long _NFMchk_item (cat_name, item_name, item_rev, command )
char *cat_name;
char *item_name;
int  command;
{
  long status;
  int operation=-1;
  /* long _NFMchk_pendingflag ();  3.0 Schema */

  if (NFMmsg_ptr.debug_on)
  _NFM_str ("_NFMchk_item: enter ...");

  /* check the archive state */
  if (command == NFM_ITEM_IN)
    operation = 0;
  else if (command == NFM_ITEM_OUT)
    operation = 1; 
  else if (command == NFM_ITEM_COPY)
    operation = 2;

  if ( (! (NFMitem_ptr->cat_item.n_archivestate.data_count)) ||
       (! strcmp (NFMitem_ptr->cat_item.n_archivestate.data_value, "B"))
     )
  ;
  else if (! strcmp (NFMitem_ptr->cat_item.n_archivestate.data_value, "A"))
  {
    _NFMload_message (item_name, item_rev, operation, 
            NFMitem_ptr->cat_item.n_archivestate.data_value);
    _NFM_num ("NFMchk_item: status = <0x%.8x>",NFM_E_ITEM_ARCHIVED);
    return (NFM_E_ITEM_ARCHIVED);
  }
  else
  {
    _NFMload_message (item_name, item_rev, operation, 
            NFMitem_ptr->cat_item.n_archivestate.data_value);
    _NFM_num ("NFMchk_item: status = <0x%.8x>",NFM_E_UNKNOWN_ARCH_FLAG);
    return (NFM_E_UNKNOWN_ARCH_FLAG);
  }
  /* check CO status */
  if (command == NFM_ITEM_IN)
  {
    /* this check is don in NFMprepare_item_checkin because of multi user
    if ( (strcmp(NFMitem_ptr->cat_item.n_coout.data_value, "O")) &&
         ((NFMitem_ptr->cat_item.n_coout.data_count))
       )
    {
      ERRload_struct (NFM, NFM_E_ITEM_NOT_READY_IN, "", NULL);
      _NFM_num ("NFMchk_item : Item Not ready In : status = <0x%.8x>\n",
      NFM_E_ITEM_NOT_READY_IN);
      return (NFM_E_ITEM_NOT_READY_IN);
    }
    */
  }
  else if (command == NFM_ITEM_OUT)
  {
    /* this check is done in prepare_item_checkout because of multi user 
    if ( strcmp(NFMitem_ptr->cat_item.n_coout.data_value, "I") ||
         (! NFMitem_ptr->cat_item.n_coout.data_count) )
    {
      ERRload_struct (NFM, NFM_E_ITEM_NOT_READY_OUT, "", NULL);
      _NFM_num ("NFMchk_item : Item Not ready out: <0x%.8x>\n",
      NFM_E_ITEM_NOT_READY_OUT);
      return (NFM_E_ITEM_NOT_READY_OUT);
    }
    */

    /* if item's pendingflag, stop the user/application from check-out */

    if (NFMitem_ptr->cat_item.n_pendingflag.data_count)
    {
      _NFM_num ("_NFMchk_item: pendingflag: %s\n",
                 NFMitem_ptr->cat_item.n_pendingflag.data_value);
      return (NFM_E_PENDINGFLAG);
    }
    /*** 3.0 Schema
    status = _NFMchk_pendingflag (cat_name, item_name, item_rev, operation);
    if (status != NFM_S_SUCCESS)
    {
      _NFM_num ("_NFMchk_item: NFMchk_pendingflag: <0x%.8x>",
      status);
      return (status);
    }
    ***/

  }
  else if (command == NFM_ITEM_COPY)
  {
    if ( ( strcmp(NFMitem_ptr->cat_item.n_coout.data_value, "I")) &&
         ( strcmp(NFMitem_ptr->cat_item.n_coout.data_value, "O")) &&
         ( strcmp(NFMitem_ptr->cat_item.n_coout.data_value, "S")) &&
         ( strcmp(NFMitem_ptr->cat_item.n_coout.data_value, "M")) &&
         ( strcmp(NFMitem_ptr->cat_item.n_coout.data_value, "TO"))  )

    {
      _NFMload_message (item_name, item_rev, operation, 
                        (NFMitem_ptr->cat_item.n_coout.data_count)?
                        NFMitem_ptr->cat_item.n_coout.data_value : "");
      _NFM_num ("NFMchk_item : Item Not ready copy: <0x%.8x>\n",
      NFM_E_ITEM_NOT_READY_COPY);
      return (NFM_E_ITEM_NOT_READY_COPY);
    }
    /* if item's pendingflag, stop the user/application from check-out */

    if (NFMitem_ptr->cat_item.n_pendingflag.data_count)
    {
      _NFM_num ("_NFMchk_item: pendingflag: %s\n",
                 NFMitem_ptr->cat_item.n_pendingflag.data_value);
      return (NFM_E_PENDINGFLAG);
    }

    /*** 3.0 Schema
    status = _NFMchk_pendingflag (cat_name, item_name, item_rev, operation);
    if (status != NFM_S_SUCCESS)
    {
      _NFM_num ("_NFMchk_item: NFMchk_pendingflag: <0x%.8x>",
      status);
      return (status);
    }
    ***/

  }

  if (NFMmsg_ptr.debug_on)
  _NFM_str ("_NFMchk_item: exit successful ...");
  return (NFM_S_SUCCESS);
}

