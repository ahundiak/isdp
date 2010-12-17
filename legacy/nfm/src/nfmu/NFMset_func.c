#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMattr_def.h"
#include "ERR.h"
#include "NFMfile.h"

extern struct child_info *NFMchildren_list;
extern struct set_info1 *NFMset_list1;
extern struct attr_info1 *NFMcat_list;
struct sto_area_info STO_info;
struct sto_info *NFMsto_list=NULL;
struct sto_info *NFMend_sto_list=NULL;

extern int NFMset_members;
int NFMmax_fileno;
int ind_cat, ind_sta, ind_type, ind_itemno, ind_coout, ind_fileco;
int ind_cisa, ind_cifile, ind_cofile, ind_filetype, ind_set, ind_filever;
int ind_fileno, ind_level;

long NFMget_children_info ()

{
  /***
    This function will query the catalog names and f_catalog numbers of the 
    members.

  ***/

  char *sql_str, cur_cat_name[61], temp_name[61];
  char *fname="NFMget_children_info";
  char **data;
  char value[50];
  long  cur_cat;
  int  x, index;
  long status;
  struct child_info  *head;
  MEMptr list=NULL;
 
  _NFMdebug ( (fname, "ENTER:\n "));

  /* skip the 1st one, because the information is obtained. */
  head = NFMchildren_list->next;
  cur_cat = head->ccatalogno;
  sql_str = (char *) malloc ((NFMset_members * 50 + 300) * sizeof (char));
  if (sql_str == (char *) NULL)
  {
    _NFMdebug ((fname, "malloc %d failed\n",
                (NFMset_members*50+300)*sizeof(char)));
    return (NFM_E_MALLOC);
  }

  sprintf (sql_str, "%s %s %d",
           "SELECT n_catalogno, n_catalogname FROM NFMCATALOGS WHERE ",
           "n_catalogno = ", cur_cat);

  head = head->next;
  for (; head != (struct child_info *) NULL; head = head->next)
  {
    if ( head->ccatalogno != cur_cat)
    {
      strcat (sql_str, "OR n_catalogno = ");
      sprintf (value, " %d ", head->ccatalogno);
      strcat (sql_str, value);
      cur_cat = head->ccatalogno;
    }
  } 
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery 0x%.8x\n", status) );
    free (sql_str);
    return (status);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMbuild_array (list) 0x%.8x\n", status));
    free (sql_str);
    return (status);
  }

  data = (char **) list->data_ptr;
  for (x = 0; x < list->rows; x ++)
  {
    index = x * list->columns;
    head = NFMchildren_list->next;
    for (; head != (struct child_info *) NULL; head = head->next)
    {
      if (head->ccatalogno == atoi (data[index]) )
        strcpy (head->cat_name, data[index+1]);
    }
  }
  
  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMclose: 0x%.8x\n", status) );
    free (sql_str);
    return (status);
  }

  head = NFMchildren_list->next;
  strcpy (cur_cat_name, head->cat_name);

  sprintf (sql_str, "%s %s 'f_%s'",
           "SELECT n_tablename, n_tableno FROM nfmtables WHERE ",
           "n_tablename = ", head->cat_name);

  head = head->next;
  for (; head != (struct child_info *) NULL; head = head->next)
  {
    if ( strcmp (head->cat_name, cur_cat_name) ) 
    {
      strcat (sql_str, "OR n_tablename = 'f_");
      strcat (sql_str, head->cat_name);
      strcat (sql_str, "'");
      strcpy (cur_cat_name, head->cat_name);
    }
  }
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "SQLquery 0x%.8x\n", status) );
    free (sql_str);
    return (status);
  }


  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    _NFMdebug ( (fname, "MEMbuild_array (list) 0x%.8x\n", status));
    free (sql_str);
    return (status);
  }

  data = (char **) list->data_ptr;
  for (x = 0; x < list->rows; x ++)
  {
    index = x * list->columns;
    head = NFMchildren_list->next;
    for (; head != (struct child_info *) NULL; head = head->next)
    {
      sprintf (temp_name, "f_%s", head->cat_name);
      if (!strcmp (temp_name, data[index]))
        head->fcat_no = atoi(data[index+1]);
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "MEMclose 0x%.8x\n", status) );
    free (sql_str);
    return (status);
  }

  free (sql_str);

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}

long NFMget_ci_set_files (user_id, attr_list, data_list, file_list)

long    user_id;
MEMptr  attr_list, data_list, file_list;

{

  char row_str[1024], ins_str[1024];
  char **data, **data1;
  char fcat_name[61], cur_cat_name[61];
  char *fname="NFMget_ci_set_files";
  char    node_name [50], user_name [50], passwd [50];
  char    path_name [50], device_type [10];
  char    mach_id [20], op_sys [20];
  char    net_xns [10], net_tcp [10], net_dec [10];
  char file_type[3], file_name[20];   
  char value[50];
  int x, count, found;
  long status;
  struct attr_info1 *cur_cat;
  struct sto_info *cur_sto, *new_sto;

  _NFMdebug ( (fname, "ENTER:\n"));

  data   = (char **) attr_list -> data_ptr;
  data1  = (char **) data_list -> data_ptr;

  for (x = 0; x < attr_list -> rows; ++x)
  { 
    count = attr_list -> columns * x;

    if (! strcmp (data [count + INDEX_N_NAME], "n_catalogname")) 
      ind_cat = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_status1")) 
      ind_sta = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_type")) 
      ind_type = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_itemno"))
      ind_itemno = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_status"))
      ind_coout = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileno"))
      ind_fileno = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileco"))
      ind_fileco = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_fileversion"))
      ind_filever = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cisano"))
      ind_cisa = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cifilename"))
      ind_cifile = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_cofilename"))
      ind_cofile = x;
    else if (! strcmp (data [count + INDEX_N_NAME], "n_filetype"))
      ind_filetype = x;
    else if (! strcmp (data [count + INDEX_N_NAME],"n_setindicator"))
      ind_set = x;
  }

  strcpy (cur_cat_name, data1[ind_cat]);

  sprintf (fcat_name, "f_%s", data1[ind_cat]);
  status = NFMlock_table (fcat_name);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n", status) );
    return (status);
  }
  status = NFMget_attr_value (user_id, fcat_name, "MAX(n_fileno)", "", value);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ( (fname, "NFMget_attr_value (max(n_fileno)) 0x%.8x\n", status) );
    return (status);
  }
  
  NFMmax_fileno = atol (value);

  _NFMdebug ((fname, "MAX(n_fileno) = %d from cat_name = %s\n",
                      NFMmax_fileno, cur_cat_name) );

  /* the 1st entry of storage area linked list */

  NFMsto_list = (struct sto_info *) calloc (1, sizeof (struct sto_info));
  NFMend_sto_list = NFMsto_list;
  memcpy (&(NFMsto_list->info), &(STO_info), sizeof (STO_info));
  /*
  NFMprint_linked_list ();
  */

  for (cur_cat=NFMcat_list; cur_cat != (struct attr_info1 *) NULL;
       cur_cat=cur_cat->next)
    if ( !strcmp (cur_cat->table_name, data1[ind_cat]))
      break;

  for (x = 0; x < data_list->rows; ++x)
  {
    count = data_list -> columns * x;

    /*
    if (strcmp (data1[count+ind_type], "P")) 
    {
      _NFMdebug ( (fname, "item no = %d, ! primary member OR no files \n",
                   data1[count+ind_itemno]) );
      continue;
    }
    */

    if (strcmp (cur_cat_name, data1[count+ind_cat]))
    {
      strcpy (cur_cat_name, data1[count+ind_cat]);

      sprintf (fcat_name, "f_%s", data1[count+ind_cat]);
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
        return (status);
      }
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n", status) );
        return (status);
      }
      status = NFMget_attr_value (user_id, fcat_name, 
                                  "MAX(n_fileno)", "", value);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ( (fname, "NFMget_attr_value (max(n_fileno)) 0x%.8x\n", 
                      status) );
        return (status);
      }
  
      NFMmax_fileno = atoi (value);

      _NFMdebug ((fname, "MAX(n_fileno) = %d from cat_name = %s\n",
                      NFMmax_fileno, cur_cat_name) );
      for (cur_cat=NFMcat_list; cur_cat != (struct attr_info1 *) NULL;
           cur_cat=cur_cat->next)
        if ( !strcmp (cur_cat->table_name, cur_cat_name))
          break;

    }
      
    found = 0;
    if ( !strcmp (data1[count+ind_set],"Y") &&
        (!strcmp (data1[count+ind_coout],"SN") ||
         !strcmp (data1[count+ind_coout], "MN") ) )
    {
      found = 1;
      strcpy (node_name, "");
      strcpy (user_name, "");
      strcpy (passwd, "");
      strcpy (path_name, "");
      strcpy (device_type, "");
      strcpy (mach_id, "");
      strcpy (op_sys, "");
      strcpy (net_tcp, "");
      strcpy (net_xns, "");
      strcpy (net_dec, "");
    }

    for (cur_sto=NFMsto_list; (cur_sto != (struct sto_info *) NULL) && !found;
         cur_sto=cur_sto->next)
    {
      _NFMdebug ( (fname, "sano [%d] of linked list, item's cisano  %s\n",
                   cur_sto->info.sano, data1[count+ind_cisa]) );
      if (cur_sto->info.sano == atol (data1[count+ind_cisa]))
      {
        found = 1;
        strcpy (node_name, cur_sto->info.nodename);
        strcpy (user_name, cur_sto->info.username);
        strcpy (passwd, cur_sto->info.passwd);
        strcpy (path_name, cur_sto->info.pathname);
        strcpy (device_type, cur_sto->info.devicetype);
        strcpy (mach_id, cur_sto->info.machid);
        strcpy (op_sys, cur_sto->info.opsys);
        strcpy (net_tcp, cur_sto->info.tcpip);
        strcpy (net_xns, cur_sto->info.xns);
        strcpy (net_dec, cur_sto->info.decnet);
      }
    }

    if (! found)
    {
      status = NFMget_sa_no_info (user_id,
                atol (data1 [count + ind_cisa]),
                node_name, user_name, passwd, path_name, device_type,
                mach_id, op_sys, net_tcp, net_xns, net_dec);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ( (fname, "NFMget_sa_no_info 0x%.8x\n", status) );
        return (status);        
      }
      /***  add an entry to NFMsto_list  ***/

      new_sto = (struct sto_info *) calloc (1, sizeof (struct sto_info));
      new_sto->info.sano = atol (data1[count+ind_cisa]);
      strcpy (new_sto->info.nodename, node_name);
      strcpy (new_sto->info.username, user_name);
      strcpy (new_sto->info.passwd, passwd);
      strcpy (new_sto->info.pathname, path_name);
      strcpy (new_sto->info.devicetype, device_type);
      strcpy (new_sto->info.machid, mach_id);
      strcpy (new_sto->info.opsys, op_sys);
      strcpy (new_sto->info.tcpip, net_tcp);
      strcpy (new_sto->info.xns, net_xns);
      strcpy (new_sto->info.decnet, net_dec);
    
      NFMend_sto_list->next = new_sto;
      NFMend_sto_list = new_sto;
    }

    strcpy (file_type, data1[count + ind_filetype]);
        
    NFMchange_case (data1 [count + ind_sta], 0);

    if ( (!strcmp (data1[count+ind_coout], "SN")) ||
         (!strcmp (data1[count+ind_coout], "MN")) ||
         strcmp (data1[count+ind_type], "P")     ) 
    {
      sprintf (row_str, "%s\1", data1[count+ind_fileno]);
      strcpy (file_name, "\0");
    }
    else
    {
    sprintf (ins_str, "INSERT INTO f_%s (%s, n_fileno, %s) VALUES ( ", 
                    cur_cat_name, cur_cat->itemnum_n,
                    cur_cat->fileversion_n);

    if (!strncmp (cur_cat->itemnum_d, "char", 4))
    {
      strcat (ins_str, "'");
      strcat (ins_str, data1[count+ind_itemno]);
      strcat (ins_str, "'");
    }
    else
      strcat (ins_str, data1[count+ind_itemno]);

    sprintf (value, "%d", ++NFMmax_fileno);
    strcat (ins_str, ",");
    strcat (ins_str, value);

    sprintf (value, "%d", atol (data1[count+ind_filever]) + 1);
    strcat (ins_str, ",");
    if (!strncmp (cur_cat->fileversion_d, "char", 4))
    {
      strcat (ins_str, "'");
      strcat (ins_str, value);
      strcat (ins_str, "'");
    }
    else
      strcat (ins_str, value);
    
    strcat (ins_str, ")");

    status = SQLstmt (ins_str);
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
      return(status);
    } 


    status = NFMget_file_name (user_id, cur_cat->table_no, 
                               NFMmax_fileno, file_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ( (fname, "NFMget_file_name 0x%.8x\n", status));
      return (status);      
    }
    sprintf (row_str, "%d\1", NFMmax_fileno);
    }


    strcat (row_str, data1 [count + ind_cisa]); strcat (row_str, "\1");
    strcat (row_str, node_name); strcat (row_str, "\1");
    strcat (row_str, user_name); strcat (row_str, "\1");
    strcat (row_str, passwd); strcat (row_str, "\1");
    strcat (row_str, path_name); strcat (row_str, "\1");
    strcat (row_str, device_type); strcat (row_str, "\1");
    strcat (row_str, mach_id); strcat (row_str, "\1");
    strcat (row_str, op_sys); strcat (row_str, "\1");
    strcat (row_str, net_tcp); strcat (row_str, "\1");
    strcat (row_str, net_xns); strcat (row_str, "\1");
    strcat (row_str, net_dec); strcat (row_str, "\1");
    if (strlen (data1 [count + ind_cifile]))
      strcat (row_str, data1 [count + ind_cifile]);
    else 
      strcat (row_str, file_name);
    strcat (row_str, "\1");
    if ( !strncmp (data1 [count + ind_fileco], "Y", 1) &&
         !strlen (data1 [count + ind_cofile]) )
      return (NFM_E_BAD_FILE_NAME);      
    else
      strcat (row_str, data1 [count + ind_cofile]);
    strcat (row_str, "\1");
    strcat (row_str, file_type); strcat (row_str, "\1");
    strcat (row_str, "-1"); strcat (row_str, "\1");
    if ( !strcmp (data1[count+ind_coout], "SN") ||
           !strcmp (data1[count+ind_coout], "MN")  )
    {
      strcat (row_str, "none");
    }
    else if (strcmp (data1[count+ind_type], "P") )
    {
      strcat (row_str, "none");
    }
    else if ((! strcmp (data1 [count + ind_fileco], "Y")) ||
        (! strcmp (data1 [count + ind_coout], ""))  ||
        (! strcmp (data1 [count + ind_filever], "0")))
      strcat (row_str, "move");
    else
      strcat (row_str, "copy");
    strcat (row_str, "\1");

    _NFMdebug ( (fname, "row_str = %s \n", row_str) );
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ( (fname, "MEMwrite 0x%.8x\n", NFM_E_MEM) );
      return (NFM_E_MEM);      
    }           
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
    return (status);
  }
     
  _NFMdebug ( (fname, "EXIT: 0x%.8x \n",NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);    
}

long NFMupd_ci_set_cat_fcat   ( user_id, c_user, c_datetime, sa_no,
                             attr_list, data_list, file_list)
long      user_id;
char      *c_user, *c_datetime;
long      sa_no;
MEMptr    attr_list, data_list, file_list;
{
  long     status;
  char *fname="NFMupd_ci_set_cat_fcat";
  char     fcat_name [61], cur_cat_name[61];
  char     **column, **data, **data1;
  char     **column2, **data2;
  long ftable_no, cur_itemno, table_no;
  long     x, y;
  long     count, count1, count2;
  long     i=0, j=0, k=0;
  char     sql_str[1024], sql_str1 [1024], value [50];
  char     sql_str2 [1024], sql_str3 [1024];
  long     update, update1, comma;
  struct attr_info1 *cur_cat;

  _NFMdebug ( (fname, "ENTER: user_id = %ld\n", user_id) );
  ftable_no = -1;

  status = MEMbuild_array (file_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
    return (NFM_E_MEM);
  }

  column = (char **) attr_list -> column_ptr;
  data   = (char **) attr_list -> data_ptr;

  data1   = (char **) data_list -> data_ptr;

  column2 = (char **) file_list -> column_ptr;
  data2   = (char **) file_list -> data_ptr;


  for (y = 0; y < file_list -> columns; ++y)
  {
     if (! strcmp (column2 [y], "n_fileno"))           i = y;
     else if (! strcmp (column2 [y], "n_cifilesize"))  j = y;
     else if (! strcmp (column2 [y], "n_status"))      k = y;
  }

  strcpy (cur_cat_name, "\0");

  for (x = 0; x < data_list->rows; ++x)
  {
    count1 = data_list -> columns * x;
    count2 = file_list -> columns * x;

    _NFMdebug ( (fname, "cat [%s] \n", cur_cat_name) );

    if (strcmp (data1[count1+ind_type], "P"))
    {
      if ( !strlen(data1[count1+ind_fileco]) ||
           !strcmp(data1[count1+ind_fileco], "Y") )
      {
        _NFMdebug ( (fname, "x =%d, k= %d\n", x, k) );
        status = MEMwrite_data (file_list, "delete", x+1 , k+1);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ( (fname, "MEMwrite_data 0x%.8x\n", status) );
          return (status);
        }
        status = MEMwrite_data (file_list, "0", x+1 , j+1);
        if (status != MEM_S_SUCCESS)
        {
          _NFMdebug ( (fname, "MEMwrite_data 0x%.8x\n", status) );
          return (status);
        }
      }
      _NFMdebug ( (fname, "It is not a primary member\n") );
      continue;
    }

    if ( strcmp (data1[count1+ind_cat], cur_cat_name) )
    {
      _NFMdebug ( (fname, "a different catalog \n") );
      for (cur_cat=NFMcat_list; cur_cat != (struct attr_info1 *) NULL;
           cur_cat=cur_cat->next)
        if (! strcmp (cur_cat->table_name, data1[count1+ind_cat]))
        {
          ftable_no = cur_cat->ftable_no;
          break;
        }

      _NFMdebug ( (fname, "ftable_no = %d\n", ftable_no) );

      strcpy (cur_cat_name, data1[count1+ind_cat]);
      sprintf (fcat_name, "f_%s", data1[count1+ind_cat]);
    }

   
    _NFMdebug ( (fname, "UPDATE item [%s]\n", data1[count1+ind_itemno]) );
    update1 = 0; comma = 0;

    sql_str  [0] = 0; sql_str1 [0] = 0;
    sql_str2 [0] = 0; sql_str3 [0] = 0;

    sprintf (sql_str,  "UPDATE %s SET ", fcat_name);
    sprintf (sql_str1, " WHERE ");
    sprintf (sql_str2,  "UPDATE %s SET ", fcat_name);
    sprintf (sql_str3, " WHERE ");

    if ((! strcmp (data2 [count2 + k], "move"))   ||
        (! strcmp (data2 [count2 + k], "copy"))   ||
        (! strcmp (data2 [count2 + k], "delete")) ||
        (! strcmp (data2 [count2 + k], "none")))
    {
      for (y = 0; y < attr_list -> rows; ++y)
      {
        count = attr_list -> columns * y;
        update = 0; 

        if (! strcmp (data [count + INDEX_N_NAME], "n_fileno"))
        {
          strcat (sql_str1, data [count+INDEX_N_NAME]);
          strcat (sql_str1, " = ");

          if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
          {
            strcat (sql_str1, "'");
            strcat (sql_str1, data2 [count2 + i]);
            strcat (sql_str1, "'");
          }
          else
            strcat (sql_str1, data2 [count2 + i]);

          strcat (sql_str3, data [count + INDEX_N_NAME]);
          strcat (sql_str3, " = ");

          if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
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
          sprintf (value, "timestamp '%s'", c_datetime);
          update = 1;
        }
        /*
        else if (! strcmp (data [count + INDEX_N_NAME], "n_citime"))
        {
          sprintf (value, "%s", c_time);
          update = 1;
        }
        */
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
            strcat (sql_str2, data [count+INDEX_N_NAME]);
            strcat (sql_str2, " = ");
  
            if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
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

        if (update)
        {
          if (comma) strcat (sql_str, ", ");
          comma = 1;

          strcat (sql_str, data [count + INDEX_N_NAME]);
          strcat (sql_str, " = ");

          if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
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

      if ( (!strcmp (data2[count2+k],"move")) ||
           (!strcmp (data2[count2+k], "copy")) ||
           update1 )
      {
        status = NFMlock_table (fcat_name);
        if (status != NFM_S_SUCCESS)
        {
          _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n") );
          return (status);
        }
      }
      if ((! strcmp (data2 [count2 + k], "move")) ||
          (! strcmp (data2 [count2 + k], "copy")))
      {
        strcat (sql_str, sql_str1);
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMdebug ((fname, "SQLstmt 0x%.8x\n", NFM_E_SQL_STMT));
          return (NFM_E_SQL_STMT);
        }
      }

      if (update1)
      {
        strcat (sql_str2, sql_str3);
  
        status = SQLstmt (sql_str2);
        if (status != SQL_S_SUCCESS)
        {
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", NFM_E_SQL_STMT));
          return (NFM_E_SQL_STMT);
        }
      }
      if ( (!strcmp (data2[count2+k],"move")) ||
           (!strcmp (data2[count2+k], "copy")) ||
           update1 )
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          _NFMdebug ( (fname, "SQLstmt 0x%.8x\n") );
          return (status);
        }
      }
    }
  }
  /* Need to clean up some of the code */


  strcpy (cur_cat_name, "\0");
  cur_itemno = -1;
  for (x = 0; x < data_list->rows; x++)
  {
    count1 = data_list -> columns * x;
    count2 = file_list -> columns * x;

    if (strcmp (data1[count1+ind_type], "P"))
      continue;

    if ( strcmp (data1[count1+ind_cat], cur_cat_name) )
    {
      for (cur_cat=NFMcat_list; cur_cat != (struct attr_info1 *) NULL;
           cur_cat=cur_cat->next)
        if (! strcmp (cur_cat->table_name, data1[count1+ind_cat]))
        {
          table_no = cur_cat->table_no;
          break;
        }

      strcpy (cur_cat_name, data1[count1+ind_cat]);
    }
 
    update1 = 0; comma = 0;
  
    sql_str[0] = 0; sql_str1 [0] = 0;

    sprintf (sql_str,  "UPDATE %s SET ", cur_cat_name);
    sprintf (sql_str1, " WHERE ");

    for (y = 0; y < attr_list -> rows; ++y)
    {
      count = attr_list -> columns * y;

      if (! strcmp (data [count + INDEX_N_NAME], "n_itemno"))
      {
        strcat (sql_str1, data [count+INDEX_N_NAME]);
        strcat (sql_str1, " = ");
    
        if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
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
     
        strcat (sql_str, data [count+INDEX_N_NAME]);
        strcat (sql_str, " = ");
    
        if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
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
   
        strcat (sql_str, data [count+INDEX_N_NAME]);
        strcat (sql_str, " = ");
 
        if (! strncmp (data [count + INDEX_N_DATATYPE], "char", 4))
        {
          strcat (sql_str, "'");
          strcat (sql_str, "");
          strcat (sql_str, "'");
        }
        else
          strcat (sql_str, "null");
      }
    }
  
    strcat (sql_str, sql_str1);

    status = NFMlock_table (cur_cat_name);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n", status) );
      return (status);
    }

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ( (fname, " SQLstmt 0x%.8x\n", NFM_E_SQL_STMT));
      return (NFM_E_SQL_STMT);
    }

    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
      return (status);
    }

  }

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}


long NFMpurge_ci_set_item_files (user_id)
long     user_id;
{
  long    status;
  char    *fname="NFMpurge_ci_set_item_files";
  char    sql_str [1024], sql_str1 [2048], sql_str2[2048];
  long cur_cat_no;
  long    x,  z, count;
  char    fcat_name [100], file_name [100];
  MEMptr  list = NULL, move_list = NULL;
  char    **data;
  long    max_ver, curr_ver;
  char    node_name [50], user_name [50], passwd [50];
  char    path_name [50], device_type [10];
  char    mach_id [20], op_sys [20];
  char    net_xns [10], net_tcp [10], net_dec [10];
  int     or, found;
  struct set_info1 *head;
  struct sto_info *cur_sto;
  struct attr_info1 *cur_cat=NULL;
     

  _NFMdebug ( (fname, "ENTER:\n") );

  status = NFMget_move_files_list (user_id, &move_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&move_list);
    _NFMdebug ( (fname, "NFMget_move_files_list 0x%.8x\n", status));
    return (status);
  }

  _NFMdebug ( (fname, " %d members\n", NFMset_members) );
  cur_cat_no = -1;
  for (z = 0, head=NFMset_list1; z < NFMset_members + 1; head=head->next, ++z)
  {
    if (strcmp (head->type, "P"))
      continue;

    if (cur_cat_no != head->table_no)
    {
      for (cur_cat=NFMcat_list; cur_cat != (struct attr_info1 *) NULL;
           cur_cat=cur_cat->next)
      {
        _NFMdebug ( (fname, "cur_cat->table_no [%d] cur_cat->table_name [%s]\n\
                             head->table_no [%d]\n", 
                             cur_cat->table_no, cur_cat->table_name,
                             head->table_no) );

        if (cur_cat->table_no == head->table_no)
        {
          cur_cat_no = cur_cat->table_no;
          break;
        }
      }
    }

    max_ver = atol (head->versionlimit_v);
    if (max_ver < 1)
      return (NFM_E_UNLIMITED_VERSIONS);

    curr_ver = atol (head->fileversion_v) + 1;

    if (! strncmp (cur_cat->itemnum_d, "char", 4))
      sprintf (sql_str, " WHERE %s = '%s'",
                        cur_cat->itemnum_n,
                        head->itemno_v);
    else
      sprintf (sql_str, " WHERE %s = %s",
                        cur_cat->itemnum_n,
                        head->itemno_v);

    if (curr_ver > max_ver)
    {
      if (! strncmp (cur_cat->fileversion_d, 
                   "char", 4))
                         /* n_fileno, n_cisano are expected not to be changed */
                         /* by other applications. */
      sprintf (sql_str1,
                   "SELECT %s, %s, %s, %s FROM f_%s %s AND %s <= '%d'",
                   "n_fileno", "n_cisano", 
                   cur_cat->cifilename_n,
                   cur_cat->fileversion_n, 
                   cur_cat->table_name, 
                   sql_str, 
                   cur_cat->fileversion_n, 
                   curr_ver - max_ver);
      else
        sprintf (sql_str1,
                   "SELECT %s, %s, %s, %s FROM f_%s %s AND %s <= %d",
                   "n_fileno", "n_cisano", 
                   cur_cat->cifilename_n,
                   cur_cat->fileversion_n, 
                   cur_cat->table_name, 
                   sql_str, 
                   cur_cat->fileversion_n, 
                   curr_ver - max_ver);

      sprintf (fcat_name, "f_%s", cur_cat->table_name);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ( (fname, "NFMlock_table 0x%.8x\n", status) );
        return (status);
      } 
      status = SQLquery (sql_str1, &list, MEM_SIZE);
      if (status != SQL_S_SUCCESS && (status != SQL_I_NO_ROWS_FOUND))
      {
        MEMclose (&list);
        _NFMdebug ( (fname, "SQLquery 0x%.8x", NFM_E_SQL_QUERY));
        return ( NFM_E_SQL_QUERY);
      }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        _NFMdebug ( (fname, "MEMbuild_arra 0x%.8x\n", NFM_E_MEM));
        return (NFM_E_MEM);
      }

      data = (char **) list -> data_ptr;

      for (x = 0; x < list -> rows; ++x)
      {
        count = list -> columns * x;
        sql_str2[0] = 0; 

        status = NFMget_file_name (user_id, cur_cat->table_no,
                    atol (data [count]), file_name);
        if (status != NFM_S_SUCCESS)
        {
          MEMclose (&list);
          MEMclose (&move_list);
          _NFMdebug ( (fname, "NFMget_file_name 0x%.8x\n",status));
          return (status);
        }           

        found = 0;
        for (cur_sto=NFMsto_list; 
             (cur_sto != (struct sto_info *) NULL) && !found;
             cur_sto=cur_sto->next)
        if (cur_sto->info.sano == atoi (data[count+1]))
        {
          found = 1;
          strcpy (node_name, cur_sto->info.nodename);
          strcpy (user_name, cur_sto->info.username);
          strcpy (passwd, cur_sto->info.passwd);
          strcpy (path_name, cur_sto->info.pathname);
          strcpy (device_type, cur_sto->info.devicetype);
          strcpy (mach_id, cur_sto->info.machid);
          strcpy (op_sys, cur_sto->info.opsys);
          strcpy (net_tcp, cur_sto->info.tcpip);
          strcpy (net_xns, cur_sto->info.xns);
          strcpy (net_dec, cur_sto->info.decnet);
        }

        if (! found)
        {

          status = NFMget_sa_no_info (user_id, atol (data [count + 1]),
                  node_name, user_name, passwd, path_name, device_type,
                  mach_id, op_sys, net_tcp, net_xns, net_dec);
          if (status != NFM_S_SUCCESS)
          {
            MEMclose (&list);
            MEMclose (&move_list);
            _NFMdebug ( (fname, "NFMget_sa_no_info 0x%.8x\n",status));
            return (status);
          }
        }

        strcat (sql_str2, data [count]); strcat (sql_str2, "\1");
        strcat (sql_str2, data [count + 1]);strcat (sql_str2, "\1");
        strcat (sql_str2, node_name); strcat (sql_str2, "\1");
        strcat (sql_str2, user_name);strcat (sql_str2, "\1");
        strcat (sql_str2, passwd);strcat (sql_str2, "\1");
        strcat (sql_str2, path_name);strcat (sql_str2, "\1");
        strcat (sql_str2, device_type);strcat (sql_str2, "\1");
        strcat (sql_str2, mach_id);strcat (sql_str2, "\1");
        strcat (sql_str2, op_sys);strcat (sql_str2, "\1");
        strcat (sql_str2, net_tcp);strcat (sql_str2, "\1");
        strcat (sql_str2, net_xns);strcat (sql_str2, "\1");
        strcat (sql_str2, net_dec);strcat (sql_str2, "\1");
        strcat (sql_str2, file_name);strcat (sql_str2, "\1");
        strcat (sql_str2, "");strcat (sql_str2, "\1");
        strcat (sql_str2, "");strcat (sql_str2, "\1");
        strcat (sql_str2, "0");strcat (sql_str2, "\1");
        if ( atol(data[count+3]) ==  0)
        {
          strcat (sql_str2, "none");strcat (sql_str2, "\1");
        }
        else
        {
          strcat (sql_str2, "delete");strcat (sql_str2, "\1");
        }
        
        status = MEMwrite (move_list, sql_str2);
        if (status != MEM_S_SUCCESS)
        {
          MEMclose (&list);
          MEMclose (&move_list);
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
          _NFMdebug ((fname, "MEMwrite 0x%.8x\n", NFM_E_MEM));
          return (NFM_E_MEM);
        }
      }


      sprintf (sql_str, "DELETE FROM f_%s WHERE (", 
                            cur_cat->table_name);
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
        _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", NFM_E_SQL_STMT));
        return (NFM_E_SQL_STMT);
      }

      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        _NFMdebug ( (fname, "SQLstmt 0x%.8x\n", status) );
        return (status);
      }

      _NFMdebug ((fname, "be4 MEMclose (list)\n"));
      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ( (fname, "MEMclose 0x%.8x\n", NFM_E_MEM));
        return (NFM_E_MEM);
      }
    }
  }

  _NFMdebug ( (fname, "purge ALL the files\n"));
  status = NFMundo_move_files_out (user_id, &move_list);
  if (status != NFM_S_SUCCESS)
  {
    MEMclose (&move_list);
    _NFMdebug ( (fname, "NFMundo_move_files_out 0x%.8x\n", status));
    return (status);
  }

  status = MEMclose (&move_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", NFM_E_MEM)); 
    return (NFM_E_MEM);
  }

  _NFMdebug ( (fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS) );
  return (NFM_S_SUCCESS);
}
