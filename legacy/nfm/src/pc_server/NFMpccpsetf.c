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
#include "MSGstruct.h"
#include "NFMfto_buf.h"
#include "NFMstruct.h"


#define NFM_TEMP_SIZE1 17

extern struct NFMglobal_st NFMglobal;
extern long DM_MANAGER;
extern struct WFstruct WFinfo;

long NFMpccopy_set_files (catalog_name, catalog_no, set_name, set_revision, 
                        set_no, working_area, wf_info, member_operations, 
                        operation, level)
/*** 
 
  This function will copy a set and its members files.

  Note: operation.delete and operation.transfer will be ignored.
        input "level" is not used. (10/9/91)

  CHANGE HISTORY:
    10/14/91 mfb Creation.
***/

char *catalog_name; 
long catalog_no;
char *set_name, *set_revision;
long set_no;
char *working_area;
struct NFMwf_info wf_info;
long member_operations;
struct NFMoperation *operation;
long level;

{
  char *fname="NFMpccopy_set_files";
  char fcat_name[NFM_CATALOGNAME+3];
  char sql_str[1024], upd_str[2048];
  char row_str[2048];
  char nfs_str[10], lfm_nfs_str[10], dumb_str[1];
  char **data, **temp_data, **data1;
  char filename[NFM_COFILENAME+1];
  char error_msg[100];
  long error_no;
  int subsystem;
  long degree;
  long x, y, z, count, or;
  long index, lfm_count, index1;
  long i_catno=0, i_itemnum=0, i_type=0, i_fileno=0, i_filenum=0, 
      i_fileversion=0,
      i_filetype=0, i_fileco=0, i_cifilename=0, i_cofilename=0, 
      i_cisano=0, i_cifilesize=0, i_status1=0, i_itemrev, i_catname, i_itemname,
      i_itemdesc;
  long i_co, i_cp, i_ref;
  long sto_no;
  long cur_cat_no;
  long status, dumb_value, status1;
  long num_members;
  MEMptr list=NULL, file_list=NULL, 
         files_info=NULL, files_info1=NULL;
  MEMptr temp_list=NULL, which_list=NULL;
  struct NFMlfm_file *lfm_files=NULL;
  struct NFMset_member *set_members=NULL, *cur_set, *new_node;
  struct NFMset_member *begin_process;
  struct NFMmembers *members_list;
  struct NFMsto_info *sto_list;
  struct NFMbuf_format *format;


  _NFMdebug ( (fname, "ENTER: cat_name[%s] set_name[%s] set_rev[%s]\n\
                       cat_no [%d] set_no [%d]\n\
                       working_area[%s] wf_info.workflow[%d]\n\
                       wf_info.command[%s] wf_info.workflow_name[%s]\n\
                       wf_info.project_name[%s] wf_info.app_name[%s]\n\
                       operation.transfer[%d] operation.delete[%d]\n\
                       operation.purge[%d] member_operations[%d]\n", 
                       catalog_name, set_name,
                       set_revision, catalog_no, set_no, working_area,
                       wf_info.workflow, wf_info.command, wf_info.workflow_name,
                       wf_info.project_name, wf_info.app_name,
                       operation->transfer, operation->delete, operation->purge,
                       member_operations));

  if (member_operations == NFM_MEMBER_OPERATIONS)
  {
    _NFMdebug ((fname, "Copy_set_files using NEM_MEMBER_OPERATIONS\n"));
    status = NFMprocess_selected_set_members (
             catalog_name, catalog_no, set_name, set_revision, set_no,
             working_area, wf_info, member_operations, operation, level,
             NFM_COPYFILES);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMcheckout_set_selecting_members: 0x%.8x\n",
                  status));
      return (status);
    }
    _NFMdebug ((fname, "EXIT: 0x%.8x\n", NFM_S_SUCCESS));
    return (NFM_S_SUCCESS);
  }

  if (operation->transfer == NFM_NO_TRANSFER)
  {
    _NFMdebug ((fname, 
               "Copy set files without transfer? No work needs to be done!\n"));
    ERRload_struct (NFM, NFM_E_CP_SET_NO_TRANSFER, "%s",
                         "file transfer mode is set to NFM_NO_TRANSFER");
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (NFM_E_CP_SET_NO_TRANSFER);
  }

  sprintf (fcat_name, "f_%s", catalog_name);


  /* check for wf_info, if validate, call validate */
  if (wf_info.workflow)
  {
    /* call validate */
    _NFMdebug ((fname,
              "wf_info.workflow is set, but only the set item is validated\n"));
    status = WFvalidate_user_access (NFMglobal.NFMuserid, wf_info.command,
             wf_info.workflow_name, wf_info.project_name,
             catalog_name, set_name, set_revision);
    if (status != NFM_S_SUCCESS)
    {
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "WFvalidate_user_access 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (status);
    }
  }

  status = NFMstop_transaction (0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMstop_transaction: 0x%.8x\n", status));
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  status = NFMopen_message_buffer ();
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMopen_message_buffer: 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  /* get the children list of the set */

  if (catalog_no < 1)
  {
    _NFMdebug ((fname, "catalog no not given, retrieve it \n"));
    if (wf_info.workflow)
    {
      catalog_no = WFinfo.catalog_no;
    }
    else
    {
      sprintf (sql_str, "%s '%s'",
               "select n_catalogno from nfmcatalogs where n_catalogname =",
               catalog_name);
      _NFMdebug ((fname, "exec qry: %s\n", sql_str));
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE, dumb_str,
                                 &catalog_no, &list);
      if (status != NFM_S_SUCCESS)
      {
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMdebug ((fname, "NFMretrieve_values (catalog no)0x%.8x\n",status));
        if (DM_MANAGER)
        {
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to retrieve cabinet's information");
          _DMcall_do_nothing (2);
        }
        else
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to retrieve catalog's information");
        return (status);
      }
    }
  }
     

  if (set_no < 1)
  {
    if (wf_info.workflow)
    {
      set_no = WFinfo.item_no;
    }
    else
    {
      sprintf (sql_str, "%s %s %s '%s' %s '%s'",
               "select n_itemno from", catalog_name, "where n_itemname =",
               set_name, "and n_itemrev =", set_revision);
      _NFMdebug ((fname, "exec qry: %s\n", sql_str));
      status = NFMretrieve_values (sql_str, NFM_RETURN_VALUE,
                                   dumb_str, &set_no, &list);
      if (status != NFM_S_SUCCESS)
      {
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMdebug ((fname, "NFMretrieve_values (set_no )0x%.8x\n",status));
        if (DM_MANAGER)
        {
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to retrieve document's information");
          _DMcall_do_nothing (2);
        } 
        else
          ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                        "Failed to retrieve item's information");
        return (status);
      }
    }
  }

  sprintf (sql_str, "%s %s %s %d %s %d %s",
           "select n_citno, n_pcatalogno, n_pitemno, n_ccatalogno, n_citemno,",
           "n_type from nfmsetcit", "where n_pcatalogno = ", catalog_no,
           "and n_pitemno = ", set_no,
           "order by n_ccatalogno");

  _NFMdebug ((fname, "exec qry: %s\n", sql_str));
  
  status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                               dumb_value, &list);

  if (status != NFM_S_SUCCESS)
  {
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, 
                "NFMretrieve_values (%s) failed 0x%.8x\n", sql_str, status));
    if (DM_MANAGER)
    {
      _DMcall_do_nothing (2);
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
        "Failed to retrieve folder/drawing/document group members");
    }
    else
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
                    "Failed to retrieve set members");
    return (status);
  }

  data = (char **) list->data_ptr;

  set_members = (struct NFMset_member *) calloc (1, 
                               sizeof (struct NFMset_member));

  members_list = (struct NFMmembers *) calloc (list->rows, 
                                  sizeof (struct NFMmembers));
  if (set_members == (struct NFMset_member *) NULL ||
      members_list == (struct NFMmembers *) NULL)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                      set_members? (list->rows * sizeof(struct NFMmembers )): 
                      sizeof (struct NFMset_member));
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    MEMclose (&list);
    free (set_members);
    free (members_list);
    _NFMdebug ((fname, "Allocating %d failed \n", set_members?
                (list->rows *sizeof(struct NFMmembers)): 
                sizeof (struct NFMset_member)));
    if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (NFM_E_MALLOC);
  }

  set_members->level = 0;
  set_members->flag = NFM_SET;
  set_members->cat_no = catalog_no;
  set_members->item_no = set_no;
  strcpy (set_members->type, "P");
  strcpy (set_members->cat_name, catalog_name);

  num_members = 1;
  for (x = 0, cur_set = set_members; x < list->rows; x++)
  {
    index = x * list->columns;
    _NFMdebug ((fname, "row %d: %s %s %s %s %s %s\n",
                        x, data[index], data[index+1], data[index+2],
                        data[index+3], data[index+4], data[index+5]));
    new_node = (struct NFMset_member *) calloc (1,
                         sizeof (struct NFMset_member));
    new_node->level = 1;
    new_node->citno = atol (data[index]);
    strcpy (new_node->type, data[index+5]);
    strcpy ((members_list+x)->type, data[index+5]);
    new_node->cat_no = (members_list+x)->cat_no = atol (data[index+3]);
    new_node->item_no = (members_list+x)->item_no = atol (data[index+4]);
    num_members++;
    if (new_node->cat_no == catalog_no)
    {
      new_node->next = set_members->next;
      set_members->next = new_node;
      if (cur_set == set_members)
        cur_set = set_members->next;
    }
    else
    {
      cur_set->next = new_node;
      cur_set = new_node;
    }
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, "at this point, children of level 1 is retrieved\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                            set_members);
  }

  status = NFMretrieve_set_members (members_list, list->rows, 2, set_members,
                                    cur_set, &num_members);
  if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    free (members_list);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    MEMclose (&list);
    _NFMdebug ((fname, "NFMretrieve_set_members 0x%.8x\n", status));
    if (DM_MANAGER)
      _DMcall_do_nothing (2);
    return (status);
  }
 
  MEMclose (&list);

  /*
  cur_set = set_members = (struct NFMset_member *) calloc (1, 
                               sizeof (struct NFMset_member));

  if (set_members == (struct NFMset_member *) NULL)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", sizeof (struct NFMset_member));
    free (set_members);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "Allocating %d failed \n", 
                        sizeof (struct NFMset_member)));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (NFM_E_MALLOC);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname, "set_members [%ld]\n", set_members));
    for (; cur_set != (struct NFMset_member *) NULL; cur_set = cur_set->next)
    {
      _NFMdebug ((fname, "cur_set [%ld]\n", cur_set));
    }     
    cur_set = set_members;
  }

  set_members->level = 0;
  set_members->flag = NFM_SET;
  set_members->cat_no = catalog_no;
  set_members->item_no = set_no;
  strcpy (set_members->type, "P");
  strcpy (set_members->cat_name, catalog_name);

  num_members = 1;

  members_list.cat_no = catalog_no;
  members_list.item_no = set_no;

  status = NFMretrieve_set_members (&members_list, 1, 1, set_members,
                                    cur_set, &num_members);
  if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "NFMretrieve_set_members 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }
  */

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname,
                "At this point, I have all the children\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                             set_members);
  }

  /* retrieve all the catalog numbers from nfmcatalogs */

  status = NFMget_catalog_names (set_members, num_members);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "NFMget_catalog_names 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
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
      status = NFMget_members_info (begin_process, count, NFM_COPYFILES);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
      begin_process = cur_set;
      _NFMdebug ((fname, "cur_cat_no = %d begin_process addr %ld\n", 
                 set_members->cat_no, begin_process));
      count = 1;
    }
  }

  status = NFMget_members_info (begin_process, count, NFM_COPYFILES);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "NFMget_members_info 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMdebug ((fname,
                "At this point, I have ALL info\n"));
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                             set_members);
  }

  status = MEMopen (&files_info, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  status = MEMopen (&files_info1, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  format = (struct NFMbuf_format *) calloc (NFM_TEMP_SIZE1,
                               sizeof (struct NFMbuf_format));

  if (!format)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s", "Failed to allocate memory");
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  strcpy ((format+0)->attr_name, "n_catno");
  strcpy ((format+0)->data_type, "integer");
  strcpy ((format+1)->attr_name, "n_itemnum");
  strcpy ((format+1)->data_type, "integer");
  strcpy ((format+2)->attr_name, "n_type");
  strcpy ((format+2)->data_type, "char(1)");
  strcpy ((format+3)->attr_name, "n_fileno");
  strcpy ((format+3)->data_type, "integer");
  strcpy ((format+4)->attr_name, "n_filenum");
  strcpy ((format+4)->data_type, "integer");
  strcpy ((format+5)->attr_name, "n_fileversion");
  strcpy ((format+5)->data_type, "integer");
  strcpy ((format+6)->attr_name, "n_filetype");
  strcpy ((format+6)->data_type, "char(5)");
  strcpy ((format+7)->attr_name, "n_fileco");
  strcpy ((format+7)->data_type, "char(1)");
  strcpy ((format+8)->attr_name, "n_cisano");
  strcpy ((format+8)->data_type, "integer");
  strcpy ((format+9)->attr_name, "n_cifilename");
  strcpy ((format+9)->data_type, "char(14)");
  strcpy ((format+10)->attr_name, "n_cofilename");
  strcpy ((format+10)->data_type, "char(14)");
  strcpy ((format+11)->attr_name, "n_cifilesize");
  strcpy ((format+11)->data_type, "integer");
  strcpy ((format+12)->attr_name, "n_status1");
  strcpy ((format+12)->data_type, "char(2)");
  strcpy ((format+13)->attr_name, "n_itemrev");
  strcpy ((format+13)->data_type, "char(60)");
  strcpy ((format+14)->attr_name, "n_catname");
  strcpy ((format+14)->data_type, "char(60)");
  strcpy ((format+15)->attr_name, "n_itemname");
  strcpy ((format+15)->data_type, "char(60)");
  strcpy ((format+16)->attr_name, "n_itemdesc");
  strcpy ((format+16)->data_type, "char(40)");

  status = _NFMbuild_working_buffer_format
                            (format, NFM_TEMP_SIZE1, files_info);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    free (format);
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  status = _NFMbuild_working_buffer_format
                            (format, NFM_TEMP_SIZE1, files_info1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    free (format);
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  free (format);

  i_catno = 0; i_itemnum = 1; i_type = 2; i_fileno = 3; i_filenum = 4;
  i_fileversion = 5; i_filetype = 6; i_fileco = 7; i_cisano = 8;
  i_cifilename = 9; i_cofilename = 10; i_cifilesize= 11; i_status1 = 12;
  i_itemrev = 13; i_catname = 14; i_itemname=15, i_itemdesc=16;

    
  for (x = 0, cur_set = set_members, cur_cat_no = 0;
       x < num_members; x ++, cur_set = cur_set->next)
  {
    /* prepare buffer for file transfer */

    if (cur_set->move == NFM_NO_MOVE)
    {
      which_list = files_info1;
    }
    else
      which_list = files_info;

      /* Is this catalog same as the previous one?
         yes: table is already locked, don't do anything.
         no: lock the f_<catalog> */

    if (cur_set->cat_no != cur_cat_no)
    {
      sprintf (fcat_name, "f_%s", cur_set->cat_name);
      status = NFMlock_table (fcat_name);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMdebug ((fname, "NFMlock_table 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
        return (status);
      }
      cur_cat_no = cur_set->cat_no;
    }

    _NFMdebug ((fname,
               "prepare to retrieve the information from f_<catalog>\n"));
    sprintf (sql_str, "%s %s %s %s %d %s %s %s %s %d %s",
             "select n_fileno, n_filenum, n_fileversion, n_filetype, n_fileco,",
             "n_cisano, n_cifilename, n_cofilename, n_cifilesize from", 
             fcat_name, 
             "where n_itemnum =", cur_set->item_no, "and n_fileversion =",
             "(select max(n_fileversion) from ", fcat_name, "where n_itemnum =",
             cur_set->item_no, ")");
    
    status = NFMretrieve_values (sql_str, NFM_RETURN_MEMPTR, dumb_str,
                                 dumb_value, &list);
    if (status != NFM_S_SUCCESS)
    {
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MESSAGE, 
                  "Failed to retrieve file information");
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (status);
    }
    data = (char **) list->data_ptr;
    _NFMdebug ((fname, 
                "write the files information of this item to files_info\n"));
    for (y = 0; y < list->rows; y ++)
    {
      index = list->columns * y;
      sprintf (row_str, "%d\1%d\1%s\1",
               cur_set->cat_no, cur_set->item_no, cur_set->type);
      for (z = 0; z < list->columns; z ++)
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
      strcat (row_str, cur_set->item_desc);
      strcat (row_str, "\1");
      _NFMdebug ((fname, "row_str %s\n", row_str));

      if (!strlen (data[index+7]))
      {
        which_list = files_info1;
        cur_set->move = NFM_NO_MOVE;
      }

      if (!strlen (data[index+4]))
      {
        which_list = files_info1;
      }

      status = MEMwrite (which_list, row_str);
      if (status != MEM_S_SUCCESS)
      {
        _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
        _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
        return (NFM_E_MEM);
      }
    }
    status = MEMclose (&list);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMclose 0x%.8x\n", status));
      _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (NFM_E_MEM);
    }
  }
  status = MEMbuild_array (files_info);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEM_S_SUCCESS 0x%.8x\n", status));
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);  
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (NFM_E_MEM);
  }

  if (files_info->rows == 0)
  {
    _NFMdebug ((fname, "No files to move\n"));
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    ERRload_struct (NFM, NFM_E_CP_SET_NO_TRANSFER, "%s", 
                    "no files are available for copy");
    if (DM_MANAGER)
    _DMcall_do_nothing (2);
    return (NFM_E_CP_SET_NO_TRANSFER);
  }   

  status = _DMbuild_fto_buffer (&file_list, 0);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "NFMbuild_fto_buffer 0x%.8x\n", status));
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  /* get storage area information */

  sto_list = (struct NFMsto_info *) calloc (1 + files_info->rows,
                       sizeof(struct NFMsto_info));

  if (!sto_list)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                    files_info->rows * sizeof (struct NFMsto_info) );
    _NFMfree_linked_lists (sto_list, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    MEMclose (&file_list);
    _NFMdebug ( (fname, "calloc sto_list failed\n") );
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (NFM_E_MALLOC);
  }

  strcpy (sto_list->saname, working_area);

  status = NFMget_storage_info (sto_list->saname, &(sto_list->sano), 
             sto_list->nodename, sto_list->username, sto_list->passwd,
             sto_list->pathname, sto_list->devicetype, 
             sto_list->plattername, sto_list->partition,
             sto_list->nfs, sto_list->compress, sto_list->machid, 
             sto_list->opsys, sto_list->tcpip,
             sto_list->xns, sto_list->decnet, sto_list->netware);

  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "NFMget_storage_info %s 0x%.8x\n", working_area,
                status));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }
  if (!DM_MANAGER && (strcmp (sto_list->machid, "PC") == 0) &&
       (strcmp (sto_list->opsys, "WINDOS") == 0)                )
  {
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "cannot copy to DMM node\n"));
    ERRload_struct (NFM, NFM_E_CO_DMM_NODE, "", NULL);
    return (NFM_E_CO_DMM_NODE);
  }

  
  sprintf (row_str, 
  "%d\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s",
  sto_list->sano, sto_list->nodename, sto_list->username, sto_list->passwd, 
  sto_list->pathname, sto_list->devicetype, sto_list->plattername, 
  sto_list->partition,
  sto_list->nfs, sto_list->compress, sto_list->machid, sto_list->opsys, 
  sto_list->tcpip, sto_list->xns, sto_list->decnet, sto_list->netware,
  "\1\1\1\1\1\1\1\1\1\1\1\1\1");

  _NFMdebug ((fname, "MEMwrite %s\n", row_str));

  status = MEMwrite (file_list, row_str);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
    _NFMfree_linked_lists ((struct NFMsto_info *)NULL, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    MEMclose (&file_list);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }
  
  data = (char **) files_info->data_ptr;

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

  /* at this point, I have a list of storage nos, so retrieve all the
     information from nfmstoragearea and nfmnodes table. */

  status = NFMget_storages_information (sto_list+1, sto_no-1, 1);
  if (status != NFM_S_SUCCESS)
  {
    _NFMfree_linked_lists (sto_list, set_members);
    MEMclose (&files_info);
    MEMclose (&files_info1);
    MEMclose (&file_list);
    degree = 1;
    _NFMcleanup (&degree, wf_info, "", "", "");
    _NFMdebug ((fname, "NFMget_storages_information 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
    return (status);
  }

  if (operation->transfer == NFM_CONDITIONAL_TRANSFER)
  {
    lfm_files = (struct NFMlfm_file *)calloc (files_info->rows,
                  sizeof (struct NFMlfm_file) );
    if (!lfm_files)
    {
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      MEMclose (&file_list);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "malloc %d for lfm_files failed\n", 
                  files_info->rows * sizeof (struct NFMlfm_file)));
      ERRload_struct (NFM, NFM_E_MALLOC, "%d",
                      files_info->rows * sizeof (struct NFMlfm_file));
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (NFM_E_MALLOC);
    }
  }
 
  _NFMdebug ((fname, "prepare file transfer buffer\n"));

  sprintf (lfm_nfs_str, "%d", NFM_LFM_NFS_MOVE);
  sprintf (nfs_str, "%d", NFM_NFS_MOVE);
  i_co = 0; i_cp = 1; i_ref = 2;
  for (x = lfm_count = 0; x < files_info->rows; x ++)
  {
    index = files_info->columns * x;
    if (operation->transfer == NFM_CONDITIONAL_TRANSFER)
    {
      sprintf (sql_str, 
                 "%s %s %d %s '%s' %s %s %s %s %s %s",
                 "select n_co, n_copy, n_ref, n_nfs, n_cisano, n_mountpoint,",
                 "n_fileversion from nfmsafiles where n_sano =", sto_list->sano, 
                 "and n_filename =",
                 data[index+i_cofilename], "and n_catalogno =", 
                 data[index+i_catno], "and n_itemno =", data[index+i_itemnum],
                 "and n_filenum =", data[index+i_filenum]);

      /* COME BACK AND FIX: save the n_co, and n_ref value */
      status = SQLquery (sql_str, &temp_list, MEM_SIZE);
      if (status == SQL_S_SUCCESS)
      {
        status = MEMbuild_array (temp_list);
        if (status != MEM_S_SUCCESS)
        {
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&files_info);
          MEMclose (&files_info1);
          MEMclose (&file_list);
          MEMclose (&temp_list);
          free (lfm_files);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMdebug ((fname, "MEMbuild_array 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
          return (status);
        }

        temp_data = (char **) temp_list->data_ptr;
        _NFMdebug ((fname, "retrieved a row from LFM, co[%s] cp[%s] ref[%s]\n",
                    temp_data[i_co], temp_data[i_cp], temp_data[i_ref]));

        (lfm_files+x)->action = NFM_UPDATE_COPY;

        strcpy((lfm_files+x)->item_no, data[index+i_itemnum]);
        strcpy((lfm_files+x)->cat_no, data[index+i_catno]);
        sprintf((lfm_files+x)->sano, "%d", sto_list->sano);
        strcpy ((lfm_files+x)->filename, data[index+i_cofilename]);
        strcpy((lfm_files+x)->filenum, data[index+i_filenum]);
        strcpy((lfm_files+x)->fileversion, temp_data[6]);
        strcpy((lfm_files+x)->copy, temp_data[i_cp]);
        if (!strcmp(temp_data[3], "Y"))
        {
          strcpy ((lfm_files+x)->nfs, temp_data[3]);
          strcpy ((lfm_files+x)->cisano, temp_data[4]);
          strcpy ((lfm_files+x)->mountpoint, temp_data[5]);
        }
        MEMclose (&temp_list);
      }
      else if (status == SQL_I_NO_ROWS_FOUND)
      {
        (lfm_files+x)->action = NFM_ADD_COPY; /* add to the table */
        strcpy((lfm_files+x)->item_no, data[index+i_itemnum]);
        strcpy((lfm_files+x)->cat_no, data[index+i_catno]);
        sprintf((lfm_files+x)->sano, "%d", sto_list->sano);
        strcpy ((lfm_files+x)->filename, data[index+i_cofilename]);
        strcpy((lfm_files+x)->filenum, data[index+i_filenum]);
        MEMclose (&temp_list);
      }
      else  
      {
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        MEMclose (&file_list);
        free (lfm_files);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMdebug ((fname, "SQLquery 0x%.8x\n", status));
        ERRload_struct (NFM, NFM_E_SQL_QUERY, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
        return (status);
      }
      _NFMdebug ((fname, "LFM information:\n\
                  action [%d] item [%s] cat [%s] sano [%s]\n\
                  filename [%s] filenum [%s] fileversion [%s]\n",
                  (lfm_files+x)->action, (lfm_files+x)->item_no, 
                  (lfm_files+x)->cat_no, (lfm_files+x)->sano,
                  (lfm_files+x)->filename, (lfm_files+x)->filenum,
                  (lfm_files+x)->fileversion));
    }

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
        (sto_list+y)->nodename, (sto_list+y)->username, (sto_list+y)->passwd,
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
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      MEMclose (&file_list);
      MEMclose (&temp_list);
      free (lfm_files);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "check-in-to storage area incorrect\n"));
      ERRload_struct (NFM, NFM_E_MESSAGE, "%s",
           "Invalid storage area");
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (status);
    }
    strcat (row_str, data[index+i_fileno]); strcat (row_str, "\1");
    strcat (row_str, "\1"); /* n_fileold */
    if (strlen (data[index+i_cifilename]))
    {
      strcat (row_str, data[index+i_cifilename]); strcat (row_str, "\1");
    }
    else 
    {
      status = NFMget_file_name (0, atol(data[index+i_catno]),
                                 atol(data[index+i_fileno]), filename);
      if (status != NFM_S_SUCCESS)
      {
        _NFMfree_linked_lists (sto_list, set_members);
        MEMclose (&files_info);
        MEMclose (&files_info1);
        MEMclose (&file_list);
        MEMclose (&temp_list);
        free (lfm_files);
        degree = 1;
        _NFMcleanup (&degree, wf_info, "", "", "");
        _NFMdebug ((fname, "NFMget_file_name 0x%.8x\n", status));
if (DM_MANAGER) _DMcall_do_nothing (2);
        return (status);
      }
      strcat (row_str, filename); strcat (row_str, "\1");
    } 
    strcat (row_str, data[index+i_cofilename]); strcat (row_str, "\1");
    strcat (row_str, data[index+i_filetype]); strcat (row_str, "\1");
    strcat (row_str, data[index+i_cifilesize]); strcat (row_str, "\1");
    if (operation->transfer == NFM_CONDITIONAL_TRANSFER)
    {
      if ((lfm_files+x)->action == NFM_UPDATE_COPY)
      {
        if ( atol ((lfm_files+x)->fileversion) != 
              atol (data[index+i_fileversion])    )
        {
          strcat (row_str, nfs_str); strcat (row_str, "\1\1\1");
        } 
        else
        {
          strcat (row_str, lfm_nfs_str); strcat (row_str, "\1\1\1");
        }
      }
      else
      {
        strcat (row_str, lfm_nfs_str); strcat (row_str, "\1\1\1");
      }
    }
    else if (operation->transfer == NFM_TRANSFER)
    {
      strcat (row_str, nfs_str); strcat (row_str, "\1\1\1");
    }

    if (DM_MANAGER)
    {
      strcat (row_str, data[index+i_catname]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_itemnum]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_itemrev]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_itemname]); strcat (row_str, "\1");
      strcat (row_str, data[index+i_itemdesc]); strcat (row_str, "\1");
      NFMparse_local_filename (data[index+i_cofilename]);
    }
    else
    {
      strcat (row_str, "\1\1\1\1\1");
    }
    _NFMdebug ((fname, "row_str %s\n", row_str));
    status = MEMwrite (file_list, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMfree_linked_lists (sto_list, set_members);
      MEMclose (&files_info);
      MEMclose (&files_info1);
      MEMclose (&file_list);
      free (lfm_files);
      degree = 1;
      _NFMcleanup (&degree, wf_info, "", "", "");
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      ERRload_struct (NFM, NFM_E_MEM, "", NULL);
if (DM_MANAGER) _DMcall_do_nothing (2);
      return (status);
    }
  } /* prepare file transfer buffer */

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

  if (DM_MANAGER)
    status = _DMfs_recv_files (&file_list);
  else
    status = _NFMpcfs_recv_files (&file_list);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, 
           "File movement for file(s) faied, but cmd can continue\n"));
  }

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("file_list", file_list, _NFMdebug_st.NFMdebug_file);

  if (operation->transfer == NFM_TRANSFER)
  {
    _NFMdebug ((fname, "no need to update nfmsafiles\n"));
    if (status != NFM_S_SUCCESS)
    {
      MEMbuild_array (file_list);
      _NFMstack_error_from_buffer (file_list, catalog_name,
               set_name, set_revision, NFM_COPYFILES, files_info);
    }
  }
  else
  {

    MEMbuild_array (file_list);

    data1 = (char **) file_list->data_ptr;
    for (x = y = z = or = 0, cur_set = set_members; x < num_members; 
         x++, cur_set = cur_set->next)
    {
      _NFMdebug ((fname, "Processing item [%d] type [%s]\n",
                          cur_set->item_no, cur_set->type));

      if (cur_set->move == NFM_NO_MOVE)
      {
        _NFMdebug ((fname, 
          "file was not moved because of <catalog> attr or\n\
           no files associated or file was never checked in...\n"));
        continue;
      }

      for ( ; y < files_info->rows; y++)
      {
        index = files_info->columns * y;
        index1 = file_list ->columns * (y + 1);
        if (atol (data[index+i_catno]) != cur_set->cat_no ||
            atol (data[index+i_itemnum]) != cur_set->item_no )
          break;

        _NFMdebug ((fname, "Processing filenum [%s]\n",
                    data[index+i_filenum]));
        
        if ((atol (data1[index1+FTO_STATUS1]) ==  NFM_E_LFM_EXISTS_LOCALLY ||
             atol (data1[index1+FTO_STATUS1]) == NFM_E_LFM_NFS_EXISTS_LOCALLY)
           )
        {
          if ((lfm_files+y)->action == NFM_UPDATE_COPY)
          {
            _NFMdebug ((fname, "[%s] was pulled down previously\n",
                        data[index+i_cofilename]));
            sprintf (upd_str,
              "%s %s %d %s %d %s %d %s %s %s '%s'",
              "update nfmsafiles set n_copy = 'Y'", 
              "where n_sano =", sto_list->sano, "and n_catalogno =",
              cur_set->cat_no, "and n_itemno =", cur_set->item_no,
              "and n_filenum =", data[index+i_filenum],
              "and n_filename =", data[index+i_cofilename]);
            ERRload_struct (NFM, NFM_W_KNOWN_FILE_LOCAL, "%s", 
                              "primary member's/secondary member's");
            NFMlog_message ();
          }
          else
          {
            if (strcmp(cur_set->type, "P"))
            {
              _NFMdebug ((fname, 
                "SM: [%s] WASN'T pulled down previously, unknown file EXISTS\n",
                data[index+i_cofilename]));
              ERRload_struct (NFM, NFM_W_UNKNOWN_FILE_LOCAL, "%s",
                              data[index+i_cofilename]);
              NFMlog_message ();
              continue;
            }
            else
            {
              _NFMdebug ((fname,
                "PM: [%s] was not pull down previously, unknown file\n", 
                data[index+i_cofilename]));
              /*if ((atol (data1[index1+FTO_STATUS1]) */
              ERRload_struct (NFM, NFM_E_UNKNOWN_FILE_LOCAL, "%s%s%s", 
                              data1[index1+FTO_COFILENAME], cur_set->item_name,
                              cur_set->item_rev);
              NFMlog_message ();
              NFMrollback_set_status (NFM_COPYFILES,(MEMptr) NULL,
                (MEMptr) NULL, 0, 0, x + 1, lfm_files, NULL);
              if (DM_MANAGER)
                _DMfs_undo_recv_files (&file_list);
              else
                _NFMpcfs_undo_recv_files (&file_list);
              _NFMfree_linked_lists (sto_list, set_members);
              MEMclose (&files_info);
              MEMclose (&files_info1);
              MEMclose (&file_list);
              free (lfm_files);
              degree = 1;
              _NFMcleanup (&degree, wf_info, "", "", "");
              return (NFM_E_UNKNOWN_FILE_LOCAL);
            }
          }
        }
        else if (atol (data1[index1+FTO_STATUS1]) == NFM_NFSED)
        {
          if ((lfm_files+y)->action == NFM_UPDATE_COPY)
          {
            _NFMdebug ((fname, 
              "entry exists in nfmsafiles table, [%s] nfsed\n",
              data[index+i_cofilename]));
            sprintf (upd_str, 
                "%s, %s '%s', %s %s, %s %s %s %d %s %d %s %d %s %s %s '%s'",
                "update nfmsafiles set n_copy = 'Y', n_nfs = 'Y'", 
                "n_mountpoint =", data1[index1+FTO_MOUNTPOINT],
                "n_cisano =", data[index+i_cisano], 
                "n_fileversion =", data[index+i_fileversion],
                "where n_sano =", sto_list->sano, "and n_catalogno =",
                cur_set->cat_no, "and n_itemno =", cur_set->item_no,
                "and n_filenum =", data[index+i_filenum],
                "and n_filename =", data[index+i_cofilename]);
          }
          else
          {
            _NFMdebug ((fname, 
              "entry ! exist in nfmsafiles, [%s] nfsed\n",
              data[index+i_cofilename]));
            sprintf (upd_str, 
              "%s %s %s %d, '%s', %d, %d, %s, %s, %s, %s, '%s', %s %s",
              "insert into nfmsafiles (n_sano, n_filename, n_catalogno,",
              "n_itemno, n_filenum, n_fileversion, n_copy, n_co, n_ref,",
              "n_nfs, n_mountpoint, n_cisano) values (",
              sto_list->sano, data[index+i_cofilename], cur_set->cat_no,
              cur_set->item_no, data[index+i_filenum], 
              data[index+i_fileversion],
              "'Y', 'N', 0", "'Y'", data1[index1+FTO_MOUNTPOINT],
              data[index+i_cisano], ")");
          }
        }
        else if (atol (data1[index1+FTO_STATUS1]) == NFM_TRANSFERED )
        {
          if ( (lfm_files+y)->action == NFM_UPDATE_COPY)
          {
            _NFMdebug ((fname, 
              "entry exists in lfm, [%s] transfered\n",
              data[index+i_cofilename]));
            sprintf (upd_str,
              "%s, %s, %s %s %s %d %s %d %s %d %s %s %s '%s'",
              "update nfmsafiles set n_copy = 'Y', n_nfs = 'N'", 
              "n_mountpoint = NULL, n_cisano = NULL",
              "n_fileversion =", data[index+i_fileversion],
              "where n_sano =", sto_list->sano, "and n_catalogno =",
              cur_set->cat_no, "and n_itemno =", cur_set->item_no,
              "and n_filenum =", data[index+i_filenum],
              "and n_filename =", data[index+i_cofilename]);
          }
          else
          {
            _NFMdebug ((fname, 
              "entry !exist in lfm, [%s] transfered\n",
              data[index+i_cofilename]));
            sprintf (upd_str, 
              "%s %s %s %d, '%s', %d, %d, %s, %s, %s, %s %s",
              "insert into nfmsafiles (n_sano, n_filename, n_catalogno,",
              "n_itemno, n_filenum, n_fileversion, n_copy, n_co, n_ref,",
              "n_nfs) values (",
              sto_list->sano, data[index+i_cofilename], cur_set->cat_no,
              cur_set->item_no, data[index+i_filenum], 
              data[index+i_fileversion],
              "'Y', 'N', 0", "'N'", ")");
          }
        }
        else 
        {
          if (strcmp(cur_set->type, "P"))
          {
            _NFMdebug ((fname,
              "file movement for SM failed, not because of file local\n"));
            ERRload_struct (NFM, NFM_W_MESSAGE, "%s",
              "Failed to copy file(s) of secondary member(s)");
            NFMlog_message ();
            continue;
          }
          else
          {
            _NFMdebug ((fname,
               "file movement for PM failed, don't continue\n"));
            ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
              "Failed to copy file(s) of primary member(s)");
            NFMlog_message ();
            NFMrollback_set_status (NFM_COPYFILES,(MEMptr) NULL,
              (MEMptr) NULL, 0, 0, x + 1, lfm_files, NULL);
            if (DM_MANAGER)
              _DMfs_undo_recv_files (&file_list);
            else
              _NFMpcfs_undo_recv_files (&file_list);
            _NFMfree_linked_lists (sto_list, set_members);
            MEMclose (&files_info);
            MEMclose (&files_info1);
            MEMclose (&file_list);
            free (lfm_files);
            degree = 1;
            _NFMcleanup (&degree, wf_info, "", "", "");
            return (NFM_E_MESSAGE);
          }
        }
        
        status = SQLstmt (upd_str);
        if (status != SQL_S_SUCCESS)
        {
          NFMrollback_set_status (NFM_COPYFILES,(MEMptr) NULL, 
            (MEMptr) NULL, 0, 0,
            x + 1, lfm_files, NULL);
          if (DM_MANAGER)
            _DMfs_undo_recv_files (&file_list);
          else
            _NFMpcfs_undo_recv_files (&file_list);
          _NFMfree_linked_lists (sto_list, set_members);
          MEMclose (&files_info);
          MEMclose (&files_info1);
          MEMclose (&file_list);
          free (lfm_files);
          degree = 1;
          _NFMcleanup (&degree, wf_info, "", "", "");
          _NFMdebug ((fname,"SQLstmt failed 0x%.8x\n", status));
          ERRload_struct (NFM, NFM_E_SQL_STMT, "", NULL);
          return (status);
        }
      }
    }
  }

  _NFMfree_linked_lists (sto_list, set_members);
  MEMclose (&files_info);
  MEMclose (&files_info1);
  if (DM_MANAGER)
  {
    _DMdo_nothing ();
  }
  MEMclose (&file_list);
  free (lfm_files);

  status = NFMstart_transaction (0);
  if (status != NFM_S_SUCCESS)
    _NFMdebug ((fname, "NFMstart_transaction 0x%.8x\n", status));

  if (wf_info.workflow)
  {
    ERRget_message (error_msg);
    ERRget_number (&error_no, &subsystem);
    status = NFMset_wf_state (wf_info.app_name, error_no, error_msg);
    if (status != NFM_S_SUCCESS)
    {
      _NFMdebug ((fname, "NFMset_wf_state 0x%.8x\n", status));
    }
  }

  _NFMdebug ((fname, "EXIT: successful 0x%.8x\n", NFM_S_SUCCESS));
  return (NFM_S_SUCCESS);
}
