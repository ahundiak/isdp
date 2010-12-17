#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"
#include "MEMstruct.h"
#include "NFMitemfiles.h"
#include "NFMitems.h"

long NFMget_members (catalog_name, catalog_no, set_name, set_revision, set_no,
                     operation, members)
char *catalog_name; 
long catalog_no;
char *set_name, *set_revision;
long set_no;
long operation;
MEMptr *members;

{
  char *fname="NFMget_members";
  char row_str[1024];
  long status, num_members;
  struct NFMset_member *set_members, *cur_set;
  struct NFMmembers *members_list;
  struct NFMbuf_format *format;

  _NFMdebug ( (fname, "ENTER: cat_name[%s] set_name[%s] set_rev[%s]\n\
                       cat_no [%d] set_no [%d] operation [%d]\n",
                       catalog_name, set_name,
                       set_revision, catalog_no, set_no, operation));
  if (operation != NFM_ALL_MEMBERS || catalog_no < 1 || set_no < 1)
  {
    _NFMdebug ((fname, "this function is called with insufficient input\n"));
    ERRload_struct (NFM, NFM_E_MESSAGE, "%s", 
                    "Insufficient information");
    return (NFM_E_MESSAGE);
  }

  cur_set = set_members = (struct NFMset_member *) calloc (1, 
                               sizeof (struct NFMset_member));

  members_list = (struct NFMmembers *) calloc (1,
                                  sizeof (struct NFMmembers));
  if (set_members == (struct NFMset_member *) NULL ||
      members_list == (struct NFMmembers *) NULL)
  {
    ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                      set_members? sizeof(struct NFMmembers ): 
                      sizeof (struct NFMset_member));
    free (set_members);
    free (members_list);
    _NFMdebug ((fname, "Allocating %d failed \n", set_members?
                sizeof(struct NFMmembers): 
                sizeof (struct NFMset_member)));
    return (NFM_E_MALLOC);
  }

  set_members->level = 0;
  set_members->flag = NFM_SET;
  set_members->cat_no = catalog_no;
  set_members->item_no = set_no;
  strcpy (set_members->type, "P");
  strcpy (set_members->cat_name, catalog_name);

  num_members = 1;

  members_list->cat_no = catalog_no;
  members_list->item_no = set_no;
  strcpy (members_list->type, "P");

  status = NFMretrieve_set_members (members_list, 1, 1, set_members,
                                    cur_set, &num_members);
  if (status != NFM_S_SUCCESS && status != SQL_I_NO_ROWS_FOUND)
  {
    free (members_list);
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    _NFMdebug ((fname, "NFMretrieve_set_members 0x%.8x\n", status));
    return (status);
  }

  if (_NFMdebug_st.NFMdebug_on)
  {
    _NFMprint_linked_lists ((struct NFMsto_info*) NULL,
                            set_members);
  }
  free (members_list);

  status = MEMopen (members, MEM_SIZE);
  if (status != MEM_S_SUCCESS)
  {
    _NFMdebug ((fname, "MEMopen 0x%.8x\n", status));
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    return (status);
  }

  format = (struct NFMbuf_format *) calloc (3, sizeof (struct NFMbuf_format));
  if (!format)
  {
    _NFMdebug ((fname, "failed to calloc format\n"));
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    return (NFM_E_MALLOC);
  }

  strcpy ((format+0)->attr_name, "n_catno");
  strcpy ((format+0)->data_type, "integer");
  strcpy ((format+1)->attr_name, "n_itemno");
  strcpy ((format+1)->data_type, "integer");
  strcpy ((format+2)->attr_name, "n_type");
  sprintf ((format+2)->data_type, "char(%d)", NFM_TYPE);

  status = _NFMbuild_working_buffer_format (format, 3, *members);
  if (status != NFM_S_SUCCESS)
  {
    _NFMdebug ((fname, "_NFMbuild_working_buffer_format 0x%.8x\n", status));
    _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
    return (status);
  }

  free (format);

  for (cur_set = set_members; cur_set != (struct NFMset_member *) NULL;
       cur_set = cur_set->next)
  {
    sprintf (row_str, "%d\1%d\1%s\1",
             cur_set->cat_no, cur_set->item_no, cur_set->type);  
    status = MEMwrite (*members, row_str);
    if (status != MEM_S_SUCCESS)
    {
      _NFMdebug ((fname, "MEMwrite 0x%.8x\n", status));
      _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);
      return (status);
    }
  }
  _NFMfree_linked_lists ((struct NFMsto_info *) NULL, set_members);

  if (_NFMdebug_st.NFMdebug_on)
    MEMprint_buffer ("members", *members, _NFMdebug_st.NFMdebug_file);

  _NFMdebug ((fname, "EXIT: successful\n"));
  return (NFM_S_SUCCESS);
}
