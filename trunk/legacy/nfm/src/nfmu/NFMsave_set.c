#include "machine.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "NFMschema.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMapi.h"
#include "NFMitems.h"
#include "WFstruct.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"
#include "NFTftr.h"
#include "UTIerrordef.h"

#define NFM_TEMP_SIZE1 23

extern struct NFMglobal_st NFMglobal;
extern long DM_MANAGER;
extern struct WFstruct WFinfo;
extern long DM_MANAGER;
extern long NFM_FTR_INITED;


long NFMsave_set_files (catalog_name, set_name, set_revision )

/*** 
 
***/

char *catalog_name; 
char *set_name, *set_revision;

{
  char *fname="NFMsave_set_files";
  char fcat_name[NFM_CATALOGNAME+3];
  char sql_str[1024], w_clause[2048];
  char row_str[2048], temp_str[20], ftr_row[2048];
  char move_str[10], move_move_str[10], move_first_str[10];
  char **data, **data1;
  char datetime_str[NFM_CODATE+1];
  char datetime[NFM_CODATE+1];
  char fileco_str[NFM_FILECO+1], filename[NFM_COFILENAME+1];
  char dumb_str[1], file_status[NFM_STATUS+1], itemdesc[NFM_ITEMDESC+1];
  long cat_no, set_no;
  long x, y, z, count;
  long index, index1, row, max_file_no;
  long q_couser=13, q_fileversion=3, q_cisano=7;
  long i_catno=0, i_itemnum=1, i_type=2, i_fileno=3, i_filenum=4, 
      i_filetype=5, i_fileversion=6, i_fileco=7, i_cifilesize=8,
      i_cifilename=9, i_cisano=10, i_cofilename=11, 
      i_cosano=12, i_fileclass=17, i_row=18, i_itemrev=19, 
      i_catname=20, i_itemname=21,i_itemdesc=22;
  long move=0;
  long sto_no;
  long cur_cat_no;
  long status;
  long file_version, purge_limit=0;
  long num_members, dumb_value;
  long fs_net_id, move_first_time=0, move_move=0;
  MEMptr list=NULL, file_list=NULL, files_info=NULL, ftr_file_list=NULL;
  MEMptr dumb_list=NULL;
  struct NFMset_member *set_members, *cur_set;
  struct NFMset_member *begin_process;
  struct NFMmembers members_list;
  struct NFMsto_info *sto_list;
  struct NFMbuf_format *format;

  _NFMdebug ( (fname, "ENTER: cat_name[%s] set_name[%s] set_rev[%s]\n",
                      catalog_name, set_name, set_revision));

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction: 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }
  
  status = NFMopen_message_buffer ();
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMdebug ((fname, "NFMopen_message_buffer: 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }

  /* get the children list of the set */

  if (strcmp (WFinfo.catalog_name, catalog_name) )
  {
    sprintf (w_clause, "n_catalogname = '%s'", catalog_name);
    status = NFMcommon_queries (catalog_name, w_clause, dumb_str,
               &cat_no, &dumb_list, NFM_CAT_QUERY, NFM_RETURN_VALUE, 
               NFM_NO_LOCK);
    if (status != NFM_S_SUCCESS)
    {
      NFMrollback_transaction (0);
      _NFMdebug ((fname, 
                  "NFMcommon_queries failed 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
      return (status);
    }
    sprintf (sql_str, "%s '%s' %s '%s'", "where n_itemname =",
               set_name, "and n_itemrev =", set_revision);
    status = NFMcommon_queries (catalog_name, w_clause, dumb_str,
               &set_no, &dumb_list, NFM_ITEM_QUERY, NFM_RETURN_VALUE, 
               NFM_NO_LOCK);
    if (status != NFM_S_SUCCESS)
    {
      NFMrollback_transaction (0);
      _NFMdebug ((fname, 
                  "NFMcommon_queries failed 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
      return (status);
    }
  }
  else
  {
    _NFMdebug ((fname, "get catalog number from WFinfo\n"));
    cat_no = WFinfo.catalog_no;
    if (strcmp (WFinfo.item_name, set_name) ||
        strcmp (WFinfo.item_rev, set_revision) )
    {
      sprintf (sql_str, "%s '%s' %s '%s'", "where n_itemname =",
               set_name, "and n_itemrev =", set_revision);
      status = NFMcommon_queries (catalog_name, w_clause, dumb_str,
                 &set_no, &dumb_list, NFM_ITEM_QUERY, NFM_RETURN_VALUE, 
               NFM_NO_LOCK);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_transaction (0);
        _NFMdebug ((fname, 
                    "NFMcommon_queries failed 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
    }
    else
    {
      _NFMdebug ((fname, "get set number from WFinfo\n"));
      set_no = WFinfo.item_no;
    }
  }

  cur_set = set_members = (struct NFMset_member *) calloc (1, 
                               sizeof (struct NFMset_member));

  if (set_members == (struct NFMset_member *) NULL )
  {
    NFMrollback_transaction (0);
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", sizeof (struct NFMset_member));
    _NFMdebug ((fname, "Allocating %d failed \n", 
                sizeof (struct NFMset_member)));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (NFM_E_MALLOC);
  }

  members_list.cat_no = cat_no;
  members_list.item_no = set_no;

  set_members->level = 0;
  set_members->flag = NFM_SET;
  set_members->cat_no = cat_no;
  set_members->item_no = set_no;
  strcpy (set_members->type, "P");
  strcpy (set_members->cat_name, catalog_name);

  num_members = 1;

  status = NFMretrieve_set_members (&members_list, 1, 1, set_members,
                                    cur_set, &num_members);
  if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    NFMrollback_transaction (0);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "NFMretrieve_set_members 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)

  {
    _NFMdebug ((fname, "at this point, children of all level are retrieved\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                            set_members);
  }

  /* retrieve all the catalog numbers from nfmcatalogs */

  status = NFMget_catalog_names (set_members, num_members);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "NFMget_catalog_names 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, 
               "at this point, children + catalog name are retrieved\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                            set_members);
  }

  /* retrieve the set and children information */

  _NFMdebug ((fname, "b4 for loop, cur_cat_no = %d, begin_process addr %ld\n", 
              set_members->cat_no, set_members));

  for (x = count = 0, cur_cat_no = set_members->cat_no, 
       cur_set = begin_process = set_members; x < num_members; 
       x++, cur_set = cur_set->next)
  {
    
    if (cur_set->cat_no == cur_cat_no)
    {
      count ++;
    }
    else
    {
      status = NFMget_members_info (begin_process, count, NFM_SAVE_FILES);
      if (status != NFM_S_SUCCESS)
      {
        _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
        NFMrollback_transaction (0);
        NFMrollback_set_status (NFM_CHECK_IN, set_members, (MEMptr) NULL, 
            x+1, 0, 0, 
            (struct NFMlfm_file *) NULL, (struct NFmlfm_file *)NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
      begin_process = cur_set;
      _NFMdebug ((fname, "cur_cat_no = %d begin_process addr %ld\n", 
                 set_members->cat_no, begin_process));
      count = 1;
    }
  }
  
  if ( count )
  {
    status = NFMget_members_info (begin_process, count, NFM_SAVE_FILES);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
      NFMrollback_transaction (0);
      NFMrollback_set_status (NFM_CHECK_IN, set_members, (MEMptr) NULL, 
           x+1, 0, 0, 
           (struct NFMlfm_file *) NULL, (struct NFmlfm_file *)NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    if (DM_MANAGER)
    _DMdo_nothing ();
      return (status);
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, 
               "at this point, children + catalog name + info from cat \n\
               are retrieved\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                            set_members);
  }

  /* get date & time */

  status = NFMget_datetime (datetime_str);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    NFMrollback_set_status (NFM_CHECK_IN, set_members, (MEMptr) NULL,
          num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "NFMget_datetime 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }
  status = NFMascii_to_timestamp_format (datetime_str, datetime);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_transaction (0);
    NFMrollback_set_status (NFM_CHECK_IN, set_members, (MEMptr) NULL,
                       num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "NFMget_datetime 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }

  for (x = 0, cur_set = set_members, cur_cat_no = 0;
       x < num_members; x ++)
  {
    if (strcmp (cur_set->type, "P"))
    {
      _NFMdebug ((fname, "It is a 2ndary member, no need to retrieve info\n"));
      cur_set = cur_set->next;
      /* Added NULL check condition - SSRS 21 Mar 94 */
      if ( cur_set == NULL || 
           ( cur_set != NULL && cur_cat_no != cur_set->cat_no))
      {
        /* It should never come in to this if for x = 0 */
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CHECK_IN, set_members, 
            (MEMptr) NULL, num_members, 0, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
          MEMclose (&files_info);
          _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n",
                      fcat_name,status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
          return (status);
        }
      }
      continue;
    }

    if (cur_set->cat_no != cur_cat_no)
    {
      sprintf (fcat_name, "f_%s", cur_set->cat_name);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
         (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        MEMclose (&files_info);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
    }

    _NFMdebug ((fname,
                "prepare to retrieve the information from f_<catalog>\n"));
    sprintf (w_clause, "%s %d %s %s %s %s %d %s",
           "where n_itemnum =", cur_set->item_no, "and n_fileversion =",
           "(select max(n_fileversion) from ", fcat_name, "where n_itemnum =",
           cur_set->item_no, ")");

    status = NFMcommon_queries (cur_set->cat_name, w_clause, dumb_str,
               dumb_value, &list, NFM_ITEM_FILE_QUERY, NFM_RETURN_MEMPTR, 
               NFM_NO_LOCK);
    if (status != NFM_S_SUCCESS)
    {
      NFMrollback_set_status (NFM_CHECK_IN, set_members, 
         (MEMptr) NULL,  num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      MEMclose (&files_info);
      NFMrollback_transaction (0);
      _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                      "Failed to retrieve file information");
    if (DM_MANAGER)
    _DMdo_nothing ();
      return (status);
    }

    if (_NFMdebug_st.NFMdebug_on)
    {
      MEMprint_buffer ("info from f_<catalog>", list, 
                        _NFMdebug_st.NFMdebug_file);
    }

    data = (char **) list->data_ptr;

    if (!x)
    {
      _NFMdebug ((fname, "set [%d], filetype [%s]\n",
                cur_set->item_no, data[i_filetype]));

      if (strcmp (data[q_couser], NFMglobal.NFMusername))
      {
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
           (MEMptr) NULL,  num_members, 0, 0,
           (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        MEMclose (&files_info);
        NFMrollback_transaction (0);
        _NFMdebug ((fname, "Not the checked out set user\n"));
        ERRload_struct (NFM, NFM_E_NOT_CO_USER, "%s%s",
          "save files of the folder/drawing/document group and its members", 
          "folder/drawing/document group");
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }

      status = MEMopen (&files_info, MEM_SIZE);
      if (status != MEM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
             (MEMptr) NULL, num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
      format = (struct NFMbuf_format *) calloc (NFM_TEMP_SIZE1,
                               sizeof (struct NFMbuf_format));

      if (!format)
      {
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
           (MEMptr) NULL, num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to allocate memory");
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }

      strcpy ((format+0)->attr_name, "n_catno");
      strcpy ((format+0)->data_type, "integer");
      strcpy ((format+1)->attr_name, "n_itemnum");
      strcpy ((format+1)->data_type, "integer");
      strcpy ((format+2)->attr_name, "n_type");
      sprintf ((format+2)->data_type, "char(%d)", NFM_TYPE);
      strcpy ((format+3)->attr_name, "n_fileno");
      strcpy ((format+3)->data_type, "integer");
      strcpy ((format+4)->attr_name, "n_filenum");
      strcpy ((format+4)->data_type, "integer");
      strcpy ((format+5)->attr_name, "n_filetype");
      strcpy ((format+5)->data_type, "integer");
      strcpy ((format+6)->attr_name, "n_fileversion");
      sprintf ((format+6)->data_type, "char(%d)", NFM_FILEVERSION);
      strcpy ((format+7)->attr_name, "n_fileco");
      sprintf ((format+7)->data_type, "char(%d)", NFM_FILECO);
      strcpy ((format+8)->attr_name, "n_cifilesize");
      strcpy ((format+8)->data_type, "integer");
      strcpy ((format+9)->attr_name, "n_cifilename");
      sprintf ((format+9)->data_type, "char(%d)", NFM_CIFILENAME);
      strcpy ((format+10)->attr_name, "n_cisano");
      strcpy ((format+10)->data_type, "integer");
      strcpy ((format+11)->attr_name, "n_cofilename");
      sprintf ((format+11)->data_type, "char(%d)", NFM_COFILENAME);
      strcpy ((format+12)->attr_name, "n_cosano");
      strcpy ((format+12)->data_type, "integer");
      strcpy ((format+13)->attr_name, "n_cidate");
      strcpy ((format+13)->data_type, "timestamp");
      strcpy ((format+14)->attr_name, "n_codate");
      strcpy ((format+14)->data_type, "timestamp");
      strcpy ((format+15)->attr_name, "n_ciuser");
      sprintf ((format+15)->data_type, "char(%d)", NFM_CIUSER);
      strcpy ((format+16)->attr_name, "n_couser");
      sprintf ((format+16)->data_type, "char(%d)", NFM_COUSER);
      strcpy ((format+17)->attr_name, "n_fileclass");
      sprintf ((format+17)->data_type, "char(%d)", NFM_FILECLASS);
      strcpy ((format+18)->attr_name, "n_status1");
      strcpy ((format+18)->data_type, "char(2)");
      strcpy ((format+19)->attr_name, "n_itemrev");
      sprintf ((format+19)->data_type, "char(%d)", NFM_ITEMREV);
      strcpy ((format+20)->attr_name, "n_catname");
      sprintf ((format+20)->data_type, "char(%d)", NFM_CATALOGNAME);
      strcpy ((format+21)->attr_name, "n_itemname");
      sprintf ((format+21)->data_type, "char(%d)", NFM_ITEMNAME);
      strcpy ((format+22)->attr_name, "n_itemdesc");
      sprintf ((format+22)->data_type, "char(%d)", NFM_ITEMDESC);

      status = _NFMbuild_working_buffer_format
                            (format, NFM_TEMP_SIZE1, files_info);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
             (MEMptr) NULL, num_members, 0, 0,
             (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        free (format);
        _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
      free (format) ;
    }

    _NFMdebug ((fname, 
               "write the files information of this item to files_info\n"));
    for (y = 0; y < list->rows; y ++)
    {
      index = list->columns * y;
      sprintf (row_str, "%d\1%d\1%s\1",
               cur_set->cat_no, cur_set->item_no, cur_set->type);
      for (z = 0; z < list->columns - 1 ; z ++)
      {
        strcat (row_str, data[index+z]);
        strcat (row_str, "\1");
      }
      strcat (row_str, "\1");
      strcat (row_str, cur_set->item_rev);
      strcat (row_str, "\1");
      strcat (row_str, cur_set->cat_name);
      strcat (row_str, "\1");
      strcat (row_str, cur_set->item_name);
      strcat (row_str, "\1");
      /*strcat (row_str, cur_set->item_desc);*/
      strncpy (itemdesc, cur_set->item_desc, NFM_ITEMDESC);
      itemdesc [NFM_ITEMDESC] = '\0';
      strcat (row_str, itemdesc);
      strcat (row_str, "\1");
      _NFMdebug ((fname, "row_str %s\n", row_str));
      status = MEMwrite (files_info, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
          (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        MEMclose (&files_info);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (0);
      }
    }
    cur_set->file_version = atol (data[q_fileversion]);
    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
      NFMrollback_set_status (NFM_CHECK_IN, set_members, 
         (MEMptr) NULL, num_members, 0, 0,
       (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      MEMclose (&files_info);
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
      return (status);
    }

    cur_set = cur_set->next;
    /* Added NULL check condition - SSRS 21 Mar 94 */
    if ( cur_set == NULL || ( cur_set != NULL && cur_cat_no != cur_set->cat_no))
    {
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN, set_members, 
         (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
        MEMclose (&files_info);
        _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n",
                    fcat_name,status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files_info", files_info, _NFMdebug_st.NFMdebug_file);
  }
  status = MEMbuild_array (files_info);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEM_S_SUCCESS 0x%.8x\n", status));
    NFMrollback_set_status (NFM_CHECK_IN, set_members, 
       (MEMptr) NULL, num_members, 0, 0,
     (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (&files_info);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (0);
  }

  data = (char **) files_info->data_ptr;

  sprintf (move_str, "%d", NFM_MOVE);
  sprintf (move_move_str, "%d", NFM_MOVE_MOVE);
  sprintf (move_first_str, "%d", NFM_MOVE_FIRST_TIME);

  status = _DMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_set_status (NFM_CHECK_IN,set_members,
      (MEMptr) NULL, num_members, 0, 0,
      (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (files_info);
    _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }

  status = _DMbuild_ftr_buffer (&ftr_file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_set_status (NFM_CHECK_IN,set_members,
      (MEMptr) NULL, num_members, 0, 0,
      (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (files_info);
    _NFMdebug ((fname, "_DMbuild_fto_buffer 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }

  
  sto_list = (struct NFMsto_info *) calloc (files_info->rows + 1,
                         sizeof (struct NFMsto_info));

  sto_list->sano = atol (data [i_cosano]);

  for (x = 0, sto_no = 1; x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
    _NFMdebug ((fname, "data[index+i_cisano] = %s\n",
                          data[index+i_cisano]));

    /* check to see if the cisano already on the list */

    for (y = 0; y < sto_no ; y++)
    {
      _NFMdebug ( (fname, "(sto_list+%d)->sano: %d\n", y,
                  (sto_list+y)->sano));
      if ( (sto_list+y)->sano  == atol (data[index + i_cisano]) )
      {
        _NFMdebug ( (fname, "storage_area_no found in sto_list \n") );
        break;
      }
    }
    if (y >= sto_no)
    {
      _NFMdebug ((fname, "n_cisano not found in the list, add to it \n"));
      (sto_list+sto_no)->sano  = atol (data[index+i_cisano]);
      sto_no++;
    }
  }

  status = NFMget_storages_information (sto_list, sto_no, 1);
  if (status != NFM_S_SUCCESS)
  {
    NFMrollback_set_status (NFM_CHECK_IN,set_members,
      (MEMptr) NULL, num_members, 0, 0,
      (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists (sto_list, set_members);
    MEMclose (&files_info);
    _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }

  if (!DM_MANAGER && (strcmp (sto_list->machid, "PC") == 0) &&
                     (strcmp (sto_list->opsys, "WINDOS") == 0) )
  {
    NFMrollback_set_status (NFM_CHECK_IN,set_members,
      (MEMptr) NULL, num_members, 0, 0,
      (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists (sto_list, set_members);
    MEMclose (&files_info);
    _NFMdebug ((fname, 
      "cannot save a set that is checked out to PC using NFM interface\n"));
    ERRload_struct (NFM, NFM_E_NFM_CLIENT_SAVE_PC, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (NFM_E_NFM_CLIENT_SAVE_PC);
  }

  sprintf (row_str, 
  "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
    sto_list->sano,
    sto_list->nodename, sto_list->username, sto_list->passwd, 
    sto_list->pathname, sto_list->devicetype, sto_list->plattername, 
    sto_list->partition,
    sto_list->nfs, sto_list->compress, sto_list->machid, sto_list->opsys, 
    sto_list->tcpip, sto_list->xns, sto_list->decnet, sto_list->netware,
    "\1\1\1\1\1\1\1\1\1\1\1\1\1\1");

  _NFMdebug ((fname, "MEMwrite %s\n", row_str));

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&file_list); MEMclose (&ftr_file_list);
    _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }
  strcpy (ftr_row, row_str);
  strcat (ftr_row, "\1");

  status = MEMwrite (ftr_file_list, ftr_row);
  if (status != MEM_S_SUCCESS)
  {
    NFMrollback_set_status (NFM_CHECK_IN,set_members,
             (MEMptr) NULL, num_members, 0, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&file_list); MEMclose (&ftr_file_list);
    _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
    return (status);
  }
   
  _NFMdebug ((fname, "prepare file transfer buffer\n"));
  for (x = cur_cat_no = 0, y = 1, cur_set = set_members, row = 1; 
       x < files_info->rows; x ++)
  { 
    index = files_info->columns * x;
    _NFMdebug ((fname, "cat [%s] item [%s] type [%s]\n",
            data[index+i_catno], data[index+i_itemnum], data[index+i_type]));

    if (cur_cat_no != atol (data[index+i_catno]))
    {
      for ( ; y < num_members; )
      {
        if (cur_set->cat_no == atol (data[index+i_catno]))
          break;
        else
          cur_set = cur_set->next;
      }

      /* lock the table */
      sprintf (fcat_name, "f_%s", cur_set->cat_name);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
          (MEMptr) NULL, num_members, x, 0,
          (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
 
      /* get max (n_fileno) */
      sprintf (sql_str, "select max(n_fileno) from %s", fcat_name);
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
               &max_file_no, &dumb_list);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     (MEMptr) NULL, num_members, x, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                          "Failed to retrieve file information");
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
    }

    if (strlen (data[index+i_cofilename])) 
    {
      file_version = atol(data[index+i_fileversion]);
      move = 1;

      /* insert the record */

      sprintf (sql_str, "%s %s %s %s %s values \
      (%d, %s, %s, %d, '%s', '%s', '%s', '%s', '%s', %s, '%s', timestamp '%s',\
       '%s', timestamp '%s', %d)",
      "insert into", fcat_name, "(n_fileno, n_itemnum, n_filenum,",
      "n_fileversion, n_fileclass, n_filetype, n_fileco, n_cofilename,",
   "n_cifilename, n_cisano, n_ciuser, n_cidate, n_couser, n_codate, n_cosano)",
      ++max_file_no, data[index+i_itemnum], data[index+i_filenum],
      file_version+1, data[index+i_fileclass],
      data[index+i_filetype], "Y", data[index+i_cofilename],
      data[index+i_cifilename],
      data[index+i_cisano], NFMglobal.NFMusername, datetime, 
      NFMglobal.NFMusername, datetime, sto_list->sano);

      status = SQLstmt (sql_str);
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
      if (strlen (data[index+i_fileco]))
      {
        sprintf (sql_str, "%s %s %s %s %s %s %d %s %s",
               "update", fcat_name, "set n_fileco = 'N'", 
               "where n_itemnum =", data[index+i_itemnum],
               "and n_fileversion =", file_version,
               "and n_filenum = ", data[index+i_filenum]);

        status = SQLstmt (sql_str);
        if (status != SQL_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
                files_info, num_members, num_members, 0,
                (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list); MEMclose (&ftr_file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "SQLstmt 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
          return (status);
        }               
      }
    }
    else
    {
      _NFMdebug ((fname, "no file associated with the set/member\n"));
      move = 0;
      strcpy (fileco_str, "");
      file_version = 0;
    }

    if (move)
    {
      _NFMdebug ((fname, "Try to find cisano [%d] in sto_list\n",
                data[index+i_cisano]));
      for (y = 0; y < sto_no; y ++)
      {
        _NFMdebug ((fname, "(sto_list+%d)->sano = %d\n",
                            y, (sto_list+y)->sano));
        if ((sto_list+y)->sano == atol (data[index+i_cisano]))
        {
          _NFMdebug ((fname, "found match in sto_list\n"));
          sprintf (row_str, 
           "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
           (sto_list+y)->sano,
           (sto_list+y)->nodename, (sto_list+y)->username, 
           (sto_list+y)->passwd,
           (sto_list+y)->pathname, (sto_list+y)->devicetype, 
           (sto_list+y)->plattername,
           (sto_list+y)->partition, (sto_list+y)->nfs,
           (sto_list+y)->compress, (sto_list+y)->machid, (sto_list+y)->opsys,
           (sto_list+y)->tcpip, (sto_list+y)->xns, (sto_list+y)->decnet,
           (sto_list+y)->netware);
          break;
        }
      } 
      if (y >= sto_no)
      {
        _NFMdebug ((fname, "check-in-to storage area incorrect\n"));
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
           files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        MEMclose (&files_info);
        ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Invalid storage area");
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
      sprintf (temp_str, "%d", max_file_no);
      strcat (row_str, temp_str); strcat (row_str, "\1");
      if (strlen (data[index+i_cifilename]))
      {
        status = NFMget_file_name (0, atol(data[index+i_catno]),
                                 atol(data[index+i_fileno]), filename);
        if (status != NFM_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CHECK_IN,set_members,
             files_info, num_members, num_members, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list); MEMclose (&ftr_file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
          return (status);
        }
        strcat (row_str, filename); strcat (row_str, "\1"); /* n_fileold */
        strcat (row_str, data[index+i_cifilename]); strcat (row_str, "\1");
        if (!strlen (data[index+i_fileco]))
          move_first_time = 1;
        else
          move_move = 1;
      }
      else 
      {
        strcat (row_str, "\1"); /* n_fileold */
        status = NFMget_file_name (0, atol(data[index+i_catno]),
                                 max_file_no, filename);
        if (status != NFM_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_CHECK_IN,set_members, 
             files_info,num_members, num_members, 0,
              (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list); MEMclose (&ftr_file_list);
          MEMclose (&files_info);
          _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
    if (DM_MANAGER)
    _DMdo_nothing ();
          return (status);
        }
        strcat (row_str, filename); strcat (row_str, "\1");
      } 
      strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1");
      if (move_first_time)
      {
        strcat (row_str, move_first_str); strcat (row_str, "\1\1\1");
      }
      if (move_move)
      {
        strcat (row_str, move_move_str); strcat (row_str, "\1\1\1");
      }
      else
      {
        strcat (row_str, move_str); strcat (row_str, "\1\1\1");
      }
      move_first_time = move_move = 0;
      if (DM_MANAGER)
      {
        strcat (row_str, data[index+i_catname]); strcat (row_str, "\1");
        strcat (row_str, data[index+i_itemnum]); strcat (row_str, "\1");
        strcat (row_str, data[index+i_itemrev]); strcat (row_str, "\1");
        strcat (row_str, data[index+i_itemname]); strcat (row_str, "\1");
        /*strcat (row_str, data[index+i_itemdesc]); strcat (row_str, "\1");*/
        strncpy (itemdesc, data[index+i_itemdesc], NFM_ITEMDESC);
        itemdesc[NFM_ITEMDESC] = '\0';
        strcat (row_str, itemdesc); strcat (row_str, "\1");
        /*strcat (row_str, data[index+i_catno]); strcat (row_str, "\1");*/
      }
      else
      {
        strcat (row_str, "\1\1\1\1\1");
      }

      _NFMdebug ((fname, "row_str %s\n", row_str));
      status = MEMwrite (file_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
            files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        if (DM_MANAGER) _DMdo_nothing ();
        return (status);
      }

      strcpy (ftr_row, row_str);
      strcat (ftr_row, data[index+i_catno]); strcat (ftr_row, "\1");

      status = MEMwrite (ftr_file_list, ftr_row);
      if (status != MEM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
            files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        if (DM_MANAGER) _DMdo_nothing ();
        return (status);
      }

      sprintf (temp_str, "%d", row++);
      status = MEMwrite_data (files_info, temp_str, x+1, i_row+1);
      if (status != MEM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
             files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        MEMclose (&files_info);
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
    }

    /* check to commit */

    if ( x == (files_info->rows - 1) || 
         cur_cat_no != atol (data[index+i_catno+files_info->columns]))
    {
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members, 
             files_info,num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list); MEMclose (&ftr_file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname, "SQLstmt (COMMIT WORK) 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
    if (DM_MANAGER)
    _DMdo_nothing ();
        return (status);
      }
    }
  } /* prepare file transfer buffer */

  if (_NFMdebug_st.NFMdebug_on)
  {
    MEMprint_buffer ("files_info", files_info, _NFMdebug_st.NFMdebug_file);
    MEMprint_buffer ("file list", file_list, _NFMdebug_st.NFMdebug_file);
  }

  if (DM_MANAGER)
    status = _DMfs_send_files (&file_list, &fs_net_id, 1);
  else
    status = _NFMfs_send_files (&file_list, &fs_net_id, 1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMstack_error_from_buffer (file_list, catalog_name, 
           set_name, set_revision, NFM_CHECK_IN, files_info);
    NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
         (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
    _NFMfree_linked_lists (sto_list, set_members);
      _NFMfs_undo_send_files (&file_list);
    MEMclose (&file_list); MEMclose (&ftr_file_list);
    MEMclose (&files_info);
    _NFMdebug ((fname, "_NFMfs_send_files 0x%.8x\n", status));
    return (status);
  }

  status = MEMbuild_array (file_list);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMbuild_array (file_list) 0x%.8x\n", status));
      _NFMfs_undo_send_files (&file_list);
    MEMclose (&file_list); MEMclose (&ftr_file_list);
    MEMclose (&files_info);
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
    return (NFM_E_MEM);
  }

  if (NFM_FTR_INITED && DM_MANAGER)
  {
    _NFMdebug ((fname, "FTR engine is enabled\n"));
    MEMbuild_array (ftr_file_list);
    status = _NFMmount_add_index (ftr_file_list, NFM_SET);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "_NFMmount_add_index 0x%.8x\n", status));
    }
    ERRreset_struct ();
  }
  else
  {
    _NFMdebug ((fname, "FTR engine is ! enabled or client != DM_MANAGER\n"));

  }
    MEMclose (&ftr_file_list);

  /* update n_cifilesize in f_<catalog> */

  data1 = (char **) file_list->data_ptr;
  for (x = cur_cat_no = 0, y =1, cur_set = set_members;
       x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
    _NFMdebug ((fname, "cat[%s] item[%s] type [%s]\n",
           data[index+i_catno], data[index+i_itemnum], data[index+i_type]));
    if ( !strlen (data[index+i_cofilename]))
    {
      _NFMdebug ((fname, "dont update n_cifilesize -- PM no file\n"));
      continue;
    }
    if (cur_cat_no != atol (data[index+i_catno]))
    {
      for (; y < num_members; y++)
      {
        if (cur_set->cat_no == atol (data[index+i_catno]))
          break;
        else
          cur_set = cur_set->next;
      }
      /* lock the table */
      sprintf (fcat_name, "f_%s", cur_set->cat_name);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
               files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
          _NFMfs_undo_send_files (&file_list);
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
                     fcat_name,status));
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
    }
    _NFMdebug ((fname, "corresponding row [%s]\n",
                          data[index+i_row]));
    for (; y < num_members; y++)
    {
      if (cur_set->item_no == atol (data[index+i_itemnum]))
      {
        if (!strcmp (cur_set->file_status, "SN") ||
            !strcmp (cur_set->file_status, "MN")    )
        /* temporary using cur_set->co_filename to indicate the necessary
           status update later in the code , "SN" -> "S" and "MN" -> "M" */
          strcpy (cur_set->co_filename, "YES");
        break;
      }
      else
        cur_set = cur_set->next;
    }

    index1 = file_list->columns * (atol(data[index+i_row]));
    sprintf (sql_str, "%s %s %s %s %s %s",
               "update", fcat_name, "set n_cifilesize = ",
               data1[index1+FTO_CIFILESIZE], "where n_fileno = ",
               data1[index1+FTO_FILENO]);
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      NFMrollback_set_status (NFM_CHECK_IN,set_members, 
	     files_info,num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      _NFMfree_linked_lists (sto_list, set_members);
      _NFMfs_undo_send_files (&file_list);
      MEMclose (&file_list);
      MEMclose (&files_info);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (status);
    }
    if ( x == (files_info->rows - 1) ||
         cur_cat_no != atol (data[index+i_catno+files_info->columns]))
    {
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
          _NFMfs_undo_send_files (&file_list);
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                      fcat_name,status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (status);
      }
    }
  }
     
  /* update the <catalog> */
  for (x = y = 0, cur_set = set_members, cur_cat_no = 0; 
       x < num_members; x++)
  {
    if (strcmp(cur_set->type, "P"))
    {
      _NFMdebug ((fname, "item %d is secondary member, don't update\n",
                  cur_set->item_no));
      cur_set = cur_set->next;
      continue;
    }
    if (cur_cat_no != cur_set->cat_no)
    {
      status = NFMlock_table (cur_set->cat_name);
      if (status != NFM_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
          _NFMfs_undo_send_files (&file_list);
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname,"NFMlock_table(%s) failed 0x%.8x\n", 
                     fcat_name,status));
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
      _NFMdebug ((fname, "Update the record(s) in %s\n", cur_set->cat_name));
    }

    /* 4/16/92, TEST THIS */

    if (!strcmp(cur_set->file_status, "SN") && strlen (cur_set->co_filename))
      strcpy (file_status, "S");
    else if (!strcmp(cur_set->file_status, "MN") && 
             strlen (cur_set->co_filename))
      strcpy (file_status, "M");
    else
      strcpy (file_status, cur_set->file_status);
 
    sprintf (sql_str, "%s %s %s '%s' %s %d", 
           "update", cur_set->cat_name, "set n_status =", file_status, 
           "where n_itemno = ", cur_set->item_no);

    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      NFMrollback_set_status (NFM_CHECK_IN,set_members, 
            files_info,num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
      _NFMfree_linked_lists (sto_list, set_members);
        _NFMfs_undo_send_files (&file_list);
      MEMclose (&file_list);
      MEMclose (&files_info);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (status);
    }
    cur_set = cur_set->next;
    if ( cur_set == (struct NFMset_member *) NULL ||
         cur_cat_no != cur_set->cat_no)
    {
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        NFMrollback_set_status (NFM_CHECK_IN,set_members,
	     files_info, num_members, num_members, 0,
            (struct NFMlfm_file *) NULL, (struct NFMlfm_file *)NULL);
        _NFMfree_linked_lists (sto_list, set_members);
          _NFMfs_undo_send_files (&file_list);
        MEMclose (&file_list);
        MEMclose (&files_info);
        _NFMdebug ((fname,"SQLstmt(COMMIT WORK %s) failed 0x%.8x\n", 
                      fcat_name,status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (status);
      }
    }
  }

  for (x = 0 ; x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
    _NFMdebug ((fname, "cat [%s] item [%s] type [%s]\n",
               data[index+i_catno], data[index+i_itemnum], 
               data[index+i_type]));

    if (! strlen (data[index+i_cofilename]))
    {
      _NFMdebug ((fname, "No file association\n"));
      continue;
    }
    else if (!strlen (data[index+i_fileco]))
    {
      _NFMdebug ((fname, "file is just added to the item, insert to LFM\n"));
      sprintf (sql_str, 
          "%s %s (%d, %d, '%s', %s, %s, %s, 'Y', 'N', 0)",
          "insert into nfmsafiles (n_fileversion, n_sano, n_filename, ",
          "n_catalogno, n_itemno, n_filenum, n_co, n_copy, n_ref) values ",
          atol (data[index+i_fileversion]) + 1,
          sto_list->sano, data[index+i_cofilename],  
          data[index+i_catno], data[index+i_itemnum],
          data[index+i_filenum] );
    }
    else
    {
      /* update the version of file in nfmsafiles */
      sprintf (sql_str, 
             "%s %d %s %d %s '%s' %s %s %s %s %s %s",
             "update nfmsafiles set n_fileversion = ",
              atol (data[index+i_fileversion]) + 1,
             "where n_sano =", sto_list->sano, "and n_filename =",
             data[index+i_cofilename], "and n_catalogno =", 
             data[index+i_catno], "and n_itemno =", data[index+i_itemnum],
             "and n_filenum =", data[index+i_filenum] );
    }
  
    status = NFMlock_table ("nfmsafiles");
    if (status != NFM_S_SUCCESS)
    {
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&file_list);
      MEMclose (&files_info);
      _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
      return (status);
    }
    status = SQLstmt (sql_str);
    if (status != SQL_S_SUCCESS)
    {
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&file_list);
      MEMclose (&files_info);
      _NFMdebug ((fname, "SQLstmt (%s) 0x%.8x\n", sql_str, status));
      ERRload_struct (NFM, NFM_W_SQL_STMT, "%s%s", "Save Files", 
                      "updating local file manager");
      return (status);
    }
    SQLstmt ("COMMIT WORK");
  }

  status = MEMclose (&file_list);
  if (status != MEM_S_SUCCESS)
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));

  status = MEMclose (&files_info);
  if (status != MEM_S_SUCCESS)
    _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));


  status = NFMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
    _NFMfree_linked_lists (sto_list, set_members);
    MEMclose (&file_list);
    return (status);
  }

  for (x = 0, cur_set = set_members, cur_cat_no = 0;
       x < num_members; x ++)
  {
    if (strcmp (cur_set->type, "P"))
    {
      _NFMdebug ((fname, "type %s , skip purging\n",
                  cur_set->type));
      cur_set = cur_set->next;
      continue;
    }

    if (cur_set->cat_no != cur_cat_no)
    {
      sprintf (fcat_name, "f_%s", cur_set->cat_name);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list);
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
    }

    if (cur_set->version_limit < 1)
      purge_limit = 1;
    else
      purge_limit = cur_set->version_limit;

    _NFMdebug ((fname,
                "prepare to retrieve the information from f_<catalog>\n"));
    sprintf (w_clause, "%s %d %s %d",
             "where n_itemnum =", cur_set->item_no, "and n_fileversion <=",
             cur_set->file_version + 1 - purge_limit);
    
    status = NFMcommon_queries (cur_set->cat_name, w_clause, &dumb_str, 
                &dumb_value,
                &list, NFM_ITEM_FILE_QUERY, NFM_RETURN_MEMPTR, 
               NFM_NO_LOCK);
    if (status == SQL_I_NO_ROWS_FOUND)
    {
      cur_set = cur_set->next;
      /* Added NULL check condition - SSRS 21 Mar 94 */
      if ( cur_set == NULL || 
           ( cur_set != NULL && cur_cat_no != cur_set->cat_no))
      {
        status = SQLstmt ("COMMIT WORK");
        if (status != SQL_S_SUCCESS)
        {
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&file_list);
          _NFMdebug ((fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          return (status);
        }
      }
      MEMclose (&list);
      continue;
    }
    else if (status != NFM_S_SUCCESS)
    {
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&file_list);
      _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
      return (status);
    }

    data = (char **) list->data_ptr;

    for (y = 0; y < list->rows; y++)
    {
      index = list->columns * y;

      if (atol(data[index+q_fileversion]) == 0)
      {
        continue;
      }
      /* purge  storage area information */
      for (z = 0; z < sto_no; z ++)
      {
        if ((sto_list+z)->sano == atol (data[index+q_cisano]))
        {
          sprintf (row_str,
          "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1",
          (sto_list+z)->sano,
          (sto_list+z)->nodename, (sto_list+z)->username, 
          (sto_list+z)->passwd,
          (sto_list+z)->pathname, (sto_list+z)->devicetype,
          (sto_list+z)->plattername,
          (sto_list+z)->partition, (sto_list+z)->nfs, (sto_list+z)->compress, 
          (sto_list+z)->machid,
          (sto_list+z)->opsys, (sto_list+z)->tcpip, (sto_list+z)->xns, 
          (sto_list+z)->decnet,
          (sto_list+z)->netware);
          break;
        }
      }

      _NFMdebug ((fname, "row_str[%s]\n", row_str));
      strcat (row_str, data[index]); strcat (row_str, "\1");
      strcat (row_str, "\1");
      status = NFMget_file_name (
               NFMglobal.NFMuserid, cur_set->cat_no, atol(data[index]), 
               filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list);
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
        return (status);
      }
      strcat (row_str, filename); strcat (row_str, "\1");
      strcat (row_str, "\1");
      strcat (row_str, "\1");
      strcat (row_str, "\1");
      sprintf (temp_str, "%d", NFM_PURGE_FILE);
      strcat (row_str, temp_str); strcat (row_str, "\1\1\1");

      _NFMdebug ((fname, "row_str [%s]\n", row_str));
      status = MEMwrite (file_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list);
        _NFMdebug ((fname, "MEMwrite (%s) 0x%.8x\n", row_str, status));
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
        return (status);
      }
      if (NFM_FTR_INITED)
      {
        status = NFT_delete_entry (cur_set->cat_no, cur_set->item_no,
                                 atol(data[index]));
        if (status != UTI_S_SUCCESS)
        {
          _NFMdebug ((fname, "NFT_delete_entry 0x%.8x\n", status));
        }
        ERRreset_struct ();
      }
    }

    MEMclose (&list);

    cur_set = cur_set->next;
    /* Added NULL check condition - SSRS 21 Mar 94 */
    if ( cur_set == NULL || ( cur_set != NULL && cur_cat_no != cur_set->cat_no))
    {
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&file_list);
        _NFMdebug ((fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
        return (status);
      }
    }
  }
  /* move the files */
  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

  status = NFMfs_purge (&file_list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMfs_send_files 0x%.8x\n", status));
    if (_NFMdebug_st.NFMdebug_on)
      MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);
    ERRload_struct (NFM, NFM_S_SUCCESS, "", NULL);
  }

  /* consider purging file status */
  for (x = 0, cur_set = set_members, cur_cat_no = 0;
       x < num_members; x ++)
  {
    if (strcmp (cur_set->type, "P"))
    {
      _NFMdebug ((fname, "type %s , skip purging\n",
                  cur_set->type));
      cur_set = cur_set->next;
      continue;
    }
    if (cur_set->cat_no != cur_cat_no)
    {
      sprintf (fcat_name, "f_%s", cur_set->cat_name);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
      cur_cat_no = cur_set->cat_no;
    }

    if (cur_set->version_limit < 1)
      purge_limit = 1;
    else
      purge_limit = cur_set->version_limit;

    sprintf (sql_str, "%s %s %s %d %s %d %s",
      "delete from", fcat_name, "where n_fileversion <=", 
      cur_set->file_version + 1 - purge_limit, "and n_itemnum =", 
      cur_set->item_no, "and n_filenum > 0 and n_archiveno is NULL"); 

    /* n_filenum > 0, because of PM no file */

    status = SQLstmt(sql_str);
    if (status != SQL_S_SUCCESS)
      _NFMdebug ((fname, "SQLquery(%s) 0x%.8x\n", sql_str, status));

    /* COME BACK and UPDATE n_fileco when n_archiveno > 0 */

    sprintf (sql_str, "%s %s %s %d %s %d %s",
      "update", fcat_name, "set n_fileco = 'O' where n_fileversion <=", 
      cur_set->file_version + 1 - purge_limit, "and n_itemnum =", 
      cur_set->item_no, "and n_filenum > 0 and n_archiveno > 0"); 

    cur_set = cur_set->next;
    /* Added NULL check condition - SSRS 21 Mar 94 */
    if ( cur_set == NULL || ( cur_set != NULL && cur_cat_no != cur_set->cat_no))
    {
      status = SQLstmt ("COMMIT WORK");
      if (status != SQL_S_SUCCESS)
        _NFMdebug ((fname, "SQLstmt(COMMIT WORK) 0x%.8x\n", status));
    }
  }
  
  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "NFMstart_transaction: 0x%.8x\n", status));

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
