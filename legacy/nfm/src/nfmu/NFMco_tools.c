#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "NFMattr_def.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "MSGstruct.h"


extern MSGptr NFMmsg_ptr;
extern struct NFMitem_info *NFMitem_ptr;
extern MEMptr CAT_list;

long _NFMget_co_files (user_id, i_row, f_row,
                     attr_list, data_list, file_list, type)
long    user_id;
long    i_row, f_row;
MEMptr  attr_list, data_list, file_list;
long    type;
{
  long    status;

  char    **column, **data, **data1, **column2;
  long    x, y, count;
  long    i1, j1, k1, l1, m1;
  long    i2, j2, k2, l2;
  long    i3, j3, k3, l3, m3, n3, o3, p3, q3, r3, s3;
  char    cat_name [100];
  long    item_no, item_ver;
  char    *sql_str;
  char    node_name [50], user_name [50], passwd [50];
  char    path_name [50], device_type [10];
  char    mach_id [20], op_sys [20];
  char    net_xns [10], net_tcp [10], net_dec [10];
  char    filename [50], file_type [20];

  if (NFMmsg_ptr.debug_on)
  {
  _NFM_str ("_NFMget_co_files: enter ...");
  _NFM_num ("_NFMget_co_files: Init  Row  = <%d>  ", i_row  );
  _NFM_num ("_NFMget_co_files: Final Row  = <%d>\n", f_row  );
  _NFM_num ("_NFMget_co_files: Type       = <%d>\n", type  );
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  data1  = (char **) data_list -> data_ptr;


  i1 = -1;  j1 = -1; k1 = -1; l1 = -1; m1 = -1;
  i2 = -1;  j2 = -1; k2 = -1; l2 = -1;
  i3 = -1;  j3 = -1; k3 = -1; l3 = -1; m3 = -1;
  n3 = -1;  o3 = -1; p3 = -1; q3 = -1; r3 = -1;

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
    else if (! strcmp (data [count + INDEX_N_NAME], "n_setindicator"))
      s3 = x;
  }

  sprintf (cat_name,  "%s",
              data1 [(data_list -> columns * i_row) + i1]);

  item_no  = atol (data1 [(data_list -> columns * i_row) + i2]);
  item_ver = atol (data1 [(data_list -> columns * i_row) + l3]);

  sql_str = (char *) malloc (2 * MEM_SIZE + file_list -> row_size);
  if (! sql_str)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
    _NFM_num ("_NFMget_co_files: Malloc Failed : status = <0x%.8x>\n",
    NFM_E_MALLOC);
    return (NFM_E_MALLOC);        
  }

  for  (x = i_row; x < f_row; ++x)
  {
    count = data_list -> columns * x;

    status = MEMbuild_array (file_list);
    if (status != MEM_S_SUCCESS)
    {
      free (sql_str);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMget_co_files: MEM Build Array : status = <0x%.8x>\n",
      NFM_E_MEM);
      return (NFM_E_MEM);        
    }

    column2 = (char **) file_list -> column_ptr;

    if (strcmp (data1 [count + i1], cat_name))
    {
      free (sql_str);
      ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
      _NFM_num ("_NFMget_co_files: Cat Is Bad In Buf : status = <0x%.8x>\n",
      NFM_E_CORRUPTED_BUFFERS);
      return (NFM_E_CORRUPTED_BUFFERS);        
    }

    if (atol (data1 [count + i2]) != item_no)
    {
      free (sql_str);
      ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
      _NFM_num ("_NFMget_co_files: No Is Bad In Buf : status = <0x%.8x>\n",
      NFM_E_CORRUPTED_BUFFERS);
      return (NFM_E_CORRUPTED_BUFFERS);        
    }

    if (atol (data1 [count + l3]) != item_ver)
    {
      free (sql_str);
      ERRload_struct (NFM, NFM_E_CORRUPTED_BUFFERS, "", NULL);
      _NFM_num ("_NFMget_co_files: Ver Is Bad In Buf : status = <0x%.8x>\n",
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
      _NFM_num ("_NFMget_co_files: St No Info : status = <0x%.8x>\n",
      status);
      return (status);        
    }

    strcpy (file_type, data1[count + r3]);

    status = NFMget_file_name (user_id, NFMitem_ptr->table_no,
                    atol (data1 [count + j3]), filename);
    if (status != NFM_S_SUCCESS)
    {
      free (sql_str);
      _NFM_num ("_NFMget_co_files: Get File Name : status = <0x%.8x>\n",
      status);
      return (status);      
    }

    sql_str [0] = 0;

    for (y = 0; y < file_list -> columns; ++y)
    {
      if (! strcmp (column2 [y], "n_status"))
        strcat (sql_str, "move");
      else if (! strcmp (column2 [y], "n_fileno"))
        strcat (sql_str, data1 [count + j3]);
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
          ERRload_struct (NFM, NFM_E_BAD_FILE_NAME, "", NULL);
          _NFM_num ("_NFMget_co_files: No FName : status = <0x%.8x>\n",
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

    status = MEMwrite (file_list, sql_str);
    if (status != MEM_S_SUCCESS)
    {
      free (sql_str);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      _NFM_num ("_NFMget_co_files: MEM Write : status = <0x%.8x>\n",
      NFM_E_MEM);
      return (NFM_E_MEM);      
    }           
  }

  free (sql_str);
   
  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMget_co_files: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);    
}

long _NFMupd_co_cat_fcat (user_id, c_user, datetime, sa_no,
                             i_row, f_row, level, 
                             cat_name, item_no, 
                             attr_list, data_list, file_list)
long      user_id;
char      *c_user, *datetime;
long      sa_no, i_row, f_row;
char      *level;
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
  long     comma, found, update;
  long     i, j, k;
  MEMptr   list = NULL;
  char     *sql_str, sql_str1 [1024], value [129];

  if (NFMmsg_ptr.debug_on)
  {
  _NFM_str ("_NFMupd_co_cat_fcat: enter ...");
  _NFM_str ("_NFMupd_co_cat_fcat: User       = <%s>  ", c_user  );
  _NFM_str ("_NFMupd_co_cat_fcat: Date       = <%s>  ", datetime  );
  _NFM_num ("_NFMupd_co_cat_fcat: Sa    No   = <%d>  ", sa_no   );
  _NFM_num ("_NFMupd_co_cat_fcat: Init  Row  = <%d>  ", i_row   );
  _NFM_num ("_NFMupd_co_cat_fcat: final Row  = <%d>  ", f_row   );
  _NFM_str ("_NFMupd_co_cat_fcat: Level      = <%s>  ", level   );
  _NFM_str ("_NFMupd_co_cat_fcat: Cat   Name = <%s>  ", cat_name);
  _NFM_num ("_NFMupd_co_cat_fcat: Item  No   = <%d>\n", item_no );
  }

  /*
  MEMprint_buffer ("just entered _NFMupd_co_cat_fcat: attr_list", attr_list,
                       "/usr2/nfmadmin/buffers");

  MEMprint_buffer ("just entered _NFMupd_co_cat_fcat: data_list", data_list,
                       "/usr2/nfmadmin/buffers");

  MEMprint_buffer ("just entered _NFMupd_co_cat_fcat: file_list", file_list,
                       "/usr2/nfmadmin/buffers");
  */


  sprintf (file_cat, "f_%s", cat_name);

  status = MEMbuild_array (file_list);
  if (status != MEM_S_SUCCESS)
  {
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMupd_co_cat_fcat: MEM Build Array : status = <0x%.8x>\n",
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
    if (! strcmp (column2 [y], "n_fileno"))      i = y;
    else if (! strcmp (column2 [y], "n_cifilesize"))  j = y;
    else if (! strcmp (column2 [y], "n_status"))      k = y;
  }

  status = NFMquery_attributes_definition (user_id, "F_CATALOG",
           file_cat, &list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFM_num ("_NFMupd_co_cat_fcat: Qry Cat Attr:  <0x%.8x>\n", status);
    return (status);
  }
 
  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMupd_co_cat_fcat: MEM Build Array : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }

  column3 = (char **) list -> column_ptr;
  data3   = (char **) list -> data_ptr;

  sql_str = (char *) malloc (data_list -> row_size +
                             attr_list -> rows * 50 + MEM_SIZE);     
  if (! sql_str)
  {
    MEMclose (&list);
    ERRload_struct (NFM, NFM_E_MALLOC, "", NULL);
    _NFM_num ("_NFMupd_co_cat_fcat: Malloc Failed: <0x%.8x>\n", NFM_E_MALLOC);
    return (NFM_E_MALLOC);
  }

  for (x = i_row; x < f_row; ++x)
  {
    count1 = data_list -> columns * x;
    count2 = file_list -> columns * x;

    comma = 0;
    sql_str  [0] = 0; sql_str1 [0] = 0;

    sprintf (sql_str,  "UPDATE %s SET ", file_cat);
    sprintf (sql_str1, " WHERE ");

    if (strcmp (data2 [count2 + k], "none"))
    {
      for (y = 0; y < attr_list -> rows; ++y)
      {
        count = attr_list -> columns * y;
        update = 0; found = 0;

        for (z = 0; ((z < list -> rows) && (! found)); ++z)
        {
          count3 = list -> columns * z;

          if (! strcmp (data3 [count3 + 2], data [count + INDEX_N_NAME]))
          {
            found = 1;

            if (! strcmp (data [count + INDEX_N_NAME], "n_fileno"))
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
            else if (! strcmp (data [count + INDEX_N_NAME], "n_couser"))
            {
              sprintf (value, "%s", c_user);
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_codate"))
            {
              sprintf (value, "timestamp '%s'", datetime);
              update = 1;
            }
            /*** 3.0 Schema
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cotime"))
            {
              sprintf (value, "%s", c_time);
              update = 1;
            }
            ***/
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cosano"))
            {
              sprintf (value, "%d", sa_no);
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cofilename"))
            {
              sprintf (value, "%s", data1 [count1 + y]);
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_fileco"))
            {
              sprintf (value, "%s", "Y");
              update = 1;
            }
            else if (! strcmp (data [count + INDEX_N_NAME], "n_cocomment"))
            {
              sprintf (value, "%s", data1 [count1 + y]);
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
            if (! strlen (value))
              strcat (sql_str, "null");
            else
              strcat (sql_str, value);
          }
        }
      }

      strcat (sql_str, sql_str1);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        free (sql_str);
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        _NFM_num ("_NFMupd_co_cat_fcat: SQL Stmt Failed : status = <0x%.8x>\n",
        NFM_E_SQL_STMT);
        return (NFM_E_SQL_STMT);
      }
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    free (sql_str);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFM_num ("_NFMupd_co_cat_fcat: MEM Close : status = <0x%.8x>\n",
    NFM_E_MEM);
    return (NFM_E_MEM);
  }
  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    free (sql_str);
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFM_num ("_NFMupd_co_cat_fcat: SQLstmt (COMMIT WORK) <0x%.8x>\n",
    NFM_E_SQL_STMT);
    return (NFM_E_SQL_STMT);
  }
  status = NFMlock_table (cat_name);
  if (status != NFM_S_SUCCESS)
  {
    free (sql_str);
    ERRload_struct (NFM, status, "", NULL);
    _NFM_num ("_NFMupd_co_cat_fcat: NFMlock_table <0x%.8x>\n",
    status);
    return (status);
  }

  data3 = (char **) CAT_list -> data_ptr;

  count1 = data_list -> columns * i_row;
  count2 = file_list -> columns * i_row;
 
  comma = 0; update = 0;

  sql_str  [0] = 0; sql_str1 [0] = 0;

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

            _NFM_str ("_NFMupd_co_cat_fcat: y = %d", y);
            _NFM_str ("_NFMupd_co_cat_fcat: n_itemno = %s ", 
                                                           data1 [count1 + y]);
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
            else comma = 1;
   
            strcat (sql_str, data3 [count3]);
            strcat (sql_str, " = ");
    
            strcat (sql_str, "'");
            strcat (sql_str, "O");
            strcat (sql_str, "'");
          }
          else if (! strcmp (data [count + INDEX_N_NAME], "n_colevel"))
          {
            if (comma) strcat (sql_str, ", ");
            else comma = 1;
   
            strcat (sql_str, data3 [count3]);
            strcat (sql_str, " = ");
   
            if (! strncmp (data3 [count3 + 1], "char", 4))
            {
              strcat (sql_str, "'");
              strcat (sql_str, level);
              strcat (sql_str, "'");
            }
            else
            {
              if (! strlen (level))
                strcat (sql_str, "null");
              else   
                strcat (sql_str, level);
            }
          }
        }
      }
      else
      {
        if (! strcmp (data [count + INDEX_N_NAME], data3 [count3]))
        {
          found = 1;

          if (comma) strcat (sql_str, ", ");
          else   comma = 1;
          /* fix for TR90W2524 (sql_str was mistyped as sql_str1 )*/
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
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    _NFM_num ("_NFMupd_co_cat_fcat: SQL Stmt Failed : status = <0x%.8x>\n",
    NFM_E_SQL_STMT);
    return (NFM_E_SQL_STMT);
  }
     
  free (sql_str);

 
  if (NFMmsg_ptr.debug_on)
  _NFM_num ("_NFMupd_co_cat_fcat: SUCCESSFUL : status = <0x%.8x>\n",
  NFM_S_SUCCESS);
  return (NFM_S_SUCCESS);
}
