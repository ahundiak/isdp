#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h" 
#include "NFMitemfiles.h"
#include "NFMapi.h" 
#include "NFMitems.h"
#include "NFMstruct.h"


extern struct NFMglobal_st NFMglobal;

long NFMdefine_set_information (catalog_name, catalog_no, set_name, 
                                set_revision, file_status_check,
                                members_to_define, members_info)

char *catalog_name;
long catalog_no;
char *set_name, *set_revision;
long file_status_check;
long members_to_define;
struct NFMmember_info *members_info;

{

  char *fname="NFMdefine_set_information";
  char *sql_str=NULL, sub_str[200], *cit_str=NULL, *del_str=NULL;
  char **data, err_str[256];
  char file_status[NFM_STATUS+1];
  char set_indicator[NFM_SETINDICATOR+1];
  char pre_str[100], *post_str=NULL, dumb_str[2];
  char temp_str[10];
  int or, x, y, z, index, list_no, slot;
  int added, changed;
  long status, item_no, *list_cit;
  long _NFMprint_members_info();
  MEMptr list=NULL, dumb_list=NULL;

  _NFMdebug ((fname, "ENTER: catalog[%s %d] set[%s.%s]\n\
                      status check [%d]\n\
                      define [%d] members members addr[%ld], userno = %d\n", 
                      catalog_name, catalog_no,
                      set_name, set_revision, file_status_check,
                      members_to_define, members_info, NFMglobal.NFMuserno));
  if (file_status_check == NFM_FILE_STATUS_CHECK)
  {
    _NFMdebug ((fname, 
       "validate the user against each selected member-to-be\n"));
    status = NFMvalid_user_and_members_to_be
             (NFMglobal.NFMuserno, members_to_define, members_info);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "Fetal error\n"));
      return (status);
    }
  }

  sql_str = (char *) calloc (members_to_define * 100 + 300,
                               sizeof (char));
  cit_str = (char *) calloc (members_to_define * 120 + 60,
                               sizeof (char));
  del_str = (char *) calloc (members_to_define * 120 + 50,
                               sizeof (char));
  post_str = (char *) calloc (members_to_define * 100 + 170,
                               sizeof (char));

  if (sql_str == (char *) NULL || post_str == (char *) NULL ||
      cit_str == (char *) NULL || del_str == (char *) NULL   )
  {
    _NFMdebug ((fname, "failed to allocate the memory, %d, %d, %d, %d\n",
                (members_to_define * 100 + 300 ) * sizeof (char),
                (members_to_define * 120 + 60  ) * sizeof (char),
                (members_to_define * 120 + 50  ) * sizeof (char),
                (members_to_define * 100 + 170 ) * sizeof (char) ));

    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                    (members_to_define * 100 + 300) );
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
    _NFMprint_members_info (members_info, members_to_define);

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction 0x%.8x\n", status));
    return (status);
  }

  status = NFMlock_table (catalog_name);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMlock_table (%s) 0x%.8x\n", catalog_name, status));
    return (status);
  }

  /* retrieve the information of the set (item number, file status,
     archive state, pending flag */

  sprintf (sql_str, "%s %s %s %s '%s' %s '%s'",
           "select n_itemno, n_status, n_archivestate, n_pendingflag,",
           "n_itemlock, n_setindicator from", catalog_name, 
           "where n_itemname =",
           set_name, "and n_itemrev =", set_revision);

  _NFMdebug ((fname, "exec qry: %s\n", sql_str));

  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                    "Failed to retrieve item's information");
    return (NFM_E_MESSAGE);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    MEMclose (&list);
    NFMrollback_transaction (0);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
    return (NFM_E_MEM);
  }

  data = (char **) list->data_ptr;

  /* check the values of archive state, pending flag, file status, and
     lock */

  if (strlen (data[3]))
  {
    _NFMload_error_message (set_name, set_revision, NFM_DEFINE_MEMBER,
                            NFM_SET, data[3], "");
    MEMclose (&list);
    NFMrollback_transaction (0);
    return (NFM_E_BAD_PENDING_FLAG);
  }

  if (strlen (data[2]) && strcmp (data[2], "B"))
  {
    _NFMload_error_message (set_name, set_revision, NFM_DEFINE_MEMBER,
                            NFM_SET, data[2], "");
    MEMclose (&list);
    NFMrollback_transaction (0);
    return (NFM_E_BAD_ARCHIVE_STATE);
  }

  if (strcmp (data[4], "N"))
  {
    _NFMload_error_message (set_name, set_revision, NFM_DEFINE_MEMBER,
                            NFM_SET, data[4], "");
    MEMclose (&list);
    NFMrollback_transaction (0);
    return (NFM_E_BAD_ITEM_LOCK);
  }

  strcpy (file_status, data[1]);
  item_no = atol(data[0]);

  if (file_status_check == NFM_NO_FILE_STATUS_CHECK)
  {
    if (!strncmp (file_status, "T", 1)) 
    {
      _NFMload_error_message (set_name, set_revision, NFM_DEFINE_MEMBER,
                              NFM_SET, file_status, "");
      NFMrollback_transaction (0);
      MEMclose (&list);
      return (NFM_E_BAD_FILE_STATUS);
    }
  }
  else if (file_status_check == NFM_FILE_STATUS_CHECK)
  {
    if (strlen(file_status) && strcmp (file_status, "I")) 
    {
      _NFMload_error_message (set_name, set_revision, NFM_DEFINE_MEMBER,
                              NFM_SET, file_status, "");
      MEMclose (&list);
      NFMrollback_transaction (0);
      return (NFM_E_BAD_FILE_STATUS);
    }
  }

  strcpy (set_indicator, data[5]);

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
    return (status);
  }

  /* passed the check, set file status == TM */

  status = NFMset_item_status (catalog_name, "", "", item_no, "TM", 
           NFM_NO_LOCK, "");
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMset_item_status 0x%.8x\n", status));
    return (status);
  }

  status = SQLstmt ("COMMIT WORK");
  if (status != SQL_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
           NFM_NO_LOCK, "");
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", "COMMIT WORK", status));
    ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    return (NFM_E_SQL_STMT);
  }

  /* go down the list and retrieve catalog numbers for new members, if they 
     are not given. */

  strcpy (sql_str, "select n_catalogname, n_catalogno from nfmcatalogs where ");

  or = 0;

  if (catalog_no < 1)
  {
    strcat (sql_str, "n_catalogname = '");
    strcat (sql_str, catalog_name);
    strcat (sql_str, "'");
    or = 1;
  }

  for (x = 0; x < members_to_define; x ++)
  {
    if ( (members_info+x)->catalog_no < 1 )
    {
      if (or)
        strcat (sql_str, " or ");
      else
        or = 1;
      strcat (sql_str, "n_catalogname = '");
      strcat (sql_str, (members_info+x)->catalog_name);
      strcat (sql_str, "'");
    } 
  }

  if (or)
  {
  status = SQLquery (sql_str, &list, MEM_SIZE);
  if (status != SQL_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
           NFM_NO_LOCK, "");
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", sql_str, status));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve catalog's information");
    return (NFM_E_MESSAGE);
  }

  status = MEMbuild_array (list);
  if (status != MEM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
           NFM_NO_LOCK, "");
    NFMrollback_transaction (0);
    MEMclose (&list);
    _NFMdebug ((fname, "MEMbuild_array  0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }

  data = (char **) list->data_ptr;

  for (x = 0; x < list->rows; x ++)
  {
    index = list->columns * x;
    _NFMdebug ((fname, "catalog_name [%s] catalog_no [%s]\n",
                        data[index], data[index+1]));
    for (y = 0; y < members_to_define; y ++)
    {
      _NFMdebug ((fname, "(members_info+%d)->catalog_name = %s\n",
                  y, (members_info+y)->catalog_name));
      if (!strcmp(data[index],(members_info+y)->catalog_name))
      {
        (members_info+y)->catalog_no = atol (data[index+1]);
        _NFMdebug ((fname, "Found match, cat_name [%s] cat_no [%d]\n",
                   (members_info+y)->catalog_name,
                   (members_info+y)->catalog_no));
      }
    }
    if ((catalog_no < 1)  && (!strcmp(data[index], catalog_name)) )
    {
      catalog_no = atol (data[index+1]);
      _NFMdebug ((fname, "catalog number for [%s] = %d\n",
                          catalog_name, catalog_no));
    }
  }

  status = MEMclose (&list);
  if (status != MEM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
         NFM_LOCK_COMMIT, "");
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }
  }

  /* go down the structure, retrieve the item number for the new members */

  _NFMdebug ((fname, "after loop, catalog number for [%s] = %d\n",
                          catalog_name, catalog_no));
  sprintf (pre_str, "select n_itemname, n_itemrev, n_itemno, n_pendingflag from");
  for (x = 0; x < members_to_define; x++)
  {
    _NFMdebug ((fname, "operation [%d] item_no [%d] cat_no [%d]\n",
               (members_info+x)->operation, (members_info+x)->item_no,
               (members_info+x)->catalog_no));
    if ( (members_info+x)->item_no < 1)
    {

      sprintf (post_str, "(%s '%s' and %s '%s')", 
               "n_itemname =", (members_info+x)->item_name,
               "n_itemrev =", (members_info+x)->item_rev);
      for (y = x + 1; y < members_to_define; y ++)
      {
        _NFMdebug ((fname,
                   "Try to group, operation [%d] item_name [%d] cat_no [%d]\n",
                   (members_info+x)->operation, (members_info+x)->item_name,
                   (members_info+x)->catalog_no));
        if ((members_info+y)->item_no < 1 &&
            (members_info+y)->catalog_no == (members_info+x)->catalog_no ) 
        {
          strcat (post_str, " or (");
          strcat (post_str, "n_itemname = '");
          strcat (post_str, (members_info+y)->item_name);
          strcat (post_str, "' and ");
          strcat (post_str, "n_itemrev = '");
          strcat (post_str, (members_info+y)->item_rev);
          strcat (post_str, "')");
        }
      }
      sprintf (sql_str,  "%s %s %s %s",
             pre_str, (members_info+x)->catalog_name, "where", post_str);

      _NFMdebug ((fname, "exec qry: %s\n", sql_str));

      status = SQLquery (sql_str, &list, MEM_SIZE);
      if (status != SQL_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
         NFM_LOCK_COMMIT, "");
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLquery (%s) 0x%.8x\n", sql_str, status));
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                        "Failed to retrieve items' information");
        return (NFM_E_MESSAGE);
      }
/* Tic the buffer */
      status = NFMtic_it(list);
      if(status != NFM_S_SUCCESS)
      {
        MEMclose (&list);
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
         NFM_LOCK_COMMIT, "");
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
/*
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
*/
        return (NFM_E_MEM);
      }

      status = MEMbuild_array (list);
      if (status != MEM_S_SUCCESS)
      {
        MEMclose (&list);
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
         NFM_LOCK_COMMIT, "");
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (NFM_E_MEM);
      }
      data = (char **) list->data_ptr;
      for (z = 0; z < list->rows; z ++)
      {
        index = list->columns * z;
        for (y = x; y < members_to_define; y ++)
        {
          if ((members_info+y)->item_no < 1 &&
              (members_info+y)->catalog_no == (members_info+x)->catalog_no &&
              !strcmp ((members_info+y)->item_name, data[index]) &&
              !strcmp ((members_info+y)->item_rev, data[index+1]) ) 
          {
            (members_info+y)->item_no = atol (data[index+2]);
            if (strlen (data[index+3]) &&
                (members_info+x)->operation == NFM_DROP_MEMBER)
            {
              _NFMdebug ((fname, 
                "Cannot drop this member, this member is flagged\n"));
              NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                NFM_LOCK_COMMIT, "");
              NFMstart_transaction (0);
              /* ERRload_struct (NFM, NFM_E_PF_VALUE, "%s%s", 
                 (members_info+y)->item_name,
                 (members_info+y)->item_rev); */
              sprintf (err_str, "Cannot drop member <%s.%s>, it is flagged",
                 (members_info+y)->item_name,
                 (members_info+y)->item_rev);
              ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                err_str);
              return (NFM_E_MEM);
            }
          }
        }
      }
      status = MEMclose (&list);
      if (status != MEM_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
         NFM_LOCK_COMMIT, "");
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (NFM_E_MEM);
      }
    }
  }  

  status = NFMlock_table ("nfmsetcit");
  if (status != NFM_S_SUCCESS)
  {
    NFMset_item_status (catalog_name, "", "", item_no, file_status, 
         NFM_LOCK_COMMIT, "");
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMlock_table (nfmsetcit) 0x%.8x\n", status));
    return (status);
  }
 
  for (x = added = or = changed = list_no = 0; x < members_to_define; x ++)
  {
    if ((members_info+x)->operation == NFM_ADD_MEMBER)
    {
      sprintf (sql_str, "%s '%s'",
               "select min(n_indexslot) from nfmindex where n_tablename =",
               "nfmsetcit");
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
               &slot, &dumb_list);
      if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
      {
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
         NFM_LOCK_COMMIT, "");
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
        return (NFM_E_SQL_QUERY); 
      }
   
      if (slot < 1)
      {
        strcpy (sql_str, "select max(n_citno) from nfmsetcit");
        status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                   &slot, &list);
        if (status != NFM_S_SUCCESS)
        {
          NFMset_item_status (catalog_name, "", "", item_no, 
                              file_status, 
                              NFM_LOCK_COMMIT, "");
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));
          ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
          return (NFM_E_SQL_QUERY);
        }
        slot++;
      }
      else
      {
        sprintf (sql_str, "%s %d",
                 "delete from nfmindex where n_indexslot =", slot);
        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          NFMset_item_status (catalog_name, "", "", item_no, 
                              file_status, NFM_LOCK_COMMIT, "");
          NFMrollback_transaction (0);
          _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          return (NFM_E_SQL_STMT);
        }
      }
      sprintf (sql_str, "%s %s %d, %d, %d, %d, %d, '%s' %s",
               "insert into nfmsetcit (n_citno, n_pcatalogno, n_pitemno,",
               "n_ccatalogno, n_citemno, n_type) values (",
               slot, catalog_no, item_no, (members_info+x)->catalog_no,
               (members_info+x)->item_no, (members_info+x)->type, ")");
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
        NFMstart_transaction (0);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
        if (status == SQL_E_DUPLICATE_VALUE)
        {
          ERRload_struct (NFM, NFM_E_ADD_MEM_DUP, "%s%s",
                           (members_info+x)->item_name,
                           (members_info+x)->item_rev     );
        }
        else
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (NFM_E_SQL_STMT);
      }
      added = 1;
    }
    else if ((members_info+x)->operation == NFM_DROP_MEMBER)
    {
      if (or)
      {
        strcat (del_str, " or ");
        strcat (cit_str, " or ");
      }
      else
      {
        strcpy (del_str, "delete from nfmsetcit where");
        strcpy (cit_str, "select n_citno from nfmsetcit where");
        or = 1;
      }
      if ((members_info+x)->citno < 1)
      {
        sprintf (sub_str, "%s %d %s %d %s %d %s %d %s",
                 "(n_pcatalogno =", catalog_no, "and n_pitemno =",
                 item_no, "and n_ccatalogno =", (members_info+x)->catalog_no,
                 "and n_citemno =", (members_info+x)->item_no, ")");
        strcat (del_str, sub_str);
        strcat (cit_str, sub_str); /* query unknown citno */
      }
      else
      {
        strcat (del_str, "(n_citno =");
        strcat (del_str, (members_info+x)->citno);
        strcat (del_str, ")");
                                             /* store the given citno */
        *(list_cit+list_no) = (members_info+x)->citno;
        list_no ++;
      }
    }
    else if ((members_info+x)->operation == NFM_CHANGE_MEMBER)
    {
      sprintf (sql_str, "%s '%s' %s", "update nfmsetcit set n_type =", 
               (members_info+x)->type, "where");
      if ((members_info+x)->citno < 1)
      {
        strcat (sql_str, "(n_pcatalog =");
        strcat (sql_str, catalog_no);
        strcat (sql_str, " and ");
        strcat (sql_str, "n_pitemno =");
        strcat (sql_str, item_no);
        strcat (sql_str, " and ");
        strcat (sql_str, "n_ccatalogno =");
        strcat (sql_str, (members_info+x)->catalog_no);
        strcat (sql_str, " and ");
        strcat (sql_str, "n_citemno =");
        strcat (sql_str, (members_info+x)->item_no);
        strcat (sql_str, ")");
      }
      else
      {
        strcat (del_str, "(n_citno =");
        strcat (del_str, (members_info+x)->citno);
        strcat (del_str, ")");
      }
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            
                            NFM_LOCK_COMMIT, "");
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (NFM_E_SQL_STMT);
      }
      changed = 1;
    }
  }

  if (or)
  {
    status = SQLquery (cit_str, &list, MEM_SIZE);
    if (status != SQL_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", cit_str, status));
      ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
      return (NFM_E_SQL_QUERY);
    }
   
    status = SQLstmt (del_str);
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", del_str, status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (NFM_E_SQL_STMT);
    }
  
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      MEMclose (&list);
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", del_str, status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (NFM_E_SQL_STMT);
    }

    strcpy (sub_str, 
            "insert into nfmindex (n_tablename, n_indexslot) values (");

    status = NFMlock_table ("nfmindex");
    if (status != NFM_S_SUCCESS)
    {
      MEMclose (&list);
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", del_str, status));
      return (status);
    }

    for (x = 0; x < list_no; x ++)
    {
      sprintf (sql_str, "%s '%s', %d %s",
               sub_str, "nfmsetcit", *(list_cit+x), ")");
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", del_str, status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (NFM_E_SQL_STMT);
      }
    }

    status = MEMbuild_array (list);
    if (status != MEM_S_SUCCESS)
    {
      MEMclose (&list);
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
      return (NFM_E_MEM);
    }

    data = (char **) list->data_ptr;

    for (x = 0; x < list->rows; x ++)
    {
      index = list->columns * x;
      sprintf (sql_str, "%s '%s', %s %s",
               sub_str, "nfmsetcit", data[index], ")");
      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        MEMclose (&list);
        NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", del_str, status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (NFM_E_SQL_STMT);
      }
    }
  }
  else
  {
    status = SQLstmt ("COMMIT WORK");
    if (status != SQL_S_SUCCESS)
    {
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", del_str, status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (NFM_E_SQL_STMT);
    }
  }

  if (added && !strlen (set_indicator))
  {
    _NFMdebug ((fname, "update file status and set n_setindicator\n"));
    strcpy (post_str, ", n_setindicator = 'Y'");
  }
  else if (or && !added && !changed)
  {
    _NFMdebug ((fname, "Is any member left to this set?\n"));
    sprintf (sql_str, "%s %d %s %d",
             "select n_citno from nfmsetcit where n_pcatalogno =",
             catalog_no, "and n_pitemno =", item_no);
    status = SQLquery (sql_str, &list, MEM_SIZE);
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      MEMclose (&list);
      strcpy (post_str, ", n_setindicator = ''");
    }
    else if (status == SQL_S_SUCCESS)
    {
      MEMclose (&list);
      strcpy (post_str, "");
    }
    else
    {
      MEMclose (&list);
      NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT, "");
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (NFM_E_SQL_STMT);
    }
  }
  else
    strcpy (post_str, "");

  status = NFMset_item_status (catalog_name, "", "", item_no, file_status, 
                            NFM_LOCK_COMMIT,
                               post_str);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMset_item_status 0x%.8x\n", status));
  }


  free (sql_str); free (post_str); free (cit_str); free (del_str);
  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}


long _NFMprint_members_info (members_info, num_members)

struct NFMmember_info *members_info;
long num_members;

{
  char *fname="_NFMprint_members_info";
  int x;

  _NFMdebug ((fname, "ENTER: %d members to print out\n", num_members));

  for (x = 0; x < num_members; x ++)
  {
    _NFMdebug ((fname, "operation [%d], citno [%d], type [%s]\n\
                cat_name [%s] cat_no[%d] item [%s.%s]\n\
                item_no [%d]\n",
                (members_info+x)->operation, (members_info+x)->citno,
                (members_info+x)->type, (members_info+x)->catalog_name,
                (members_info+x)->catalog_no, (members_info+x)->item_name,
                (members_info+x)->item_rev, (members_info+x)->item_no));
  }
  _NFMdebug ((fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
