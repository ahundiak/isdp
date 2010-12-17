
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFget_mapping (entity_name, title1, title2, command)
  char   *entity_name;  /*  i - either catalog, project, or acl  */
  char   *title1;
  char   *title2;
  int    command;
  {
    auto    int     no_attributes;
    auto    int     attr_row_offset;
    auto    long    status;
    static  char    *fname = "_NFFget_mapping";

    /*  Pointer to the mapping structure  */

    NFFmap    entity;

    _NFIdebug ((fname, "entity_name = <%s>\n", entity_name));

    /*  Initialize the mapping structure  */

    if ((entity = (NFFmap) malloc (sizeof (struct NFFmap_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFmap_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFmap_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    entity->done = FALSE;
    entity->rows = NULL;
    entity->columns = NULL;
    entity->command = command;
    entity->active_data = 0;
    entity->active_attribute = 0;
    entity->validate_row = -1;
    entity->attr_list = NULL;
    entity->data_list = NULL;
    entity->value_list = NULL;

    /*  Set up the NFMR function pointers  */

    switch (command)
      {
        case ADD_CATALOG_ACL_MAP:
            NFFglobal.NFMRfunction[0] = NFMRquery_catalog_acl_map;
            NFFglobal.NFMRfunction[1] = NFMRupdate_catalog_acl_map;
            strcpy (entity->entity_attr, "n_catalogno");
            NFFglobal.working_no = NFI_I_ADD_CAT_ACL_MAP;
            entity->type = NFI_MAP_TYPE;
            break;

        case DELETE_CATALOG_ACL_MAP:
            NFFglobal.NFMRfunction[0] = NFMRquery_catalog_acl_map;
            NFFglobal.NFMRfunction[1] = NFMRupdate_catalog_acl_map;
            strcpy (entity->entity_attr, "n_catalogno");
            NFFglobal.working_no = NFI_I_DELETE_CAT_ACL_MAP;
            entity->type = NFI_MAP_TYPE;
            break;

        case ADD_CATALOG_SA_MAP:
            NFFglobal.NFMRfunction[0] = NFMRquery_catalog_sa_map;
            NFFglobal.NFMRfunction[1] = NFMRupdate_catalog_sa_map;
            strcpy (entity->entity_attr, "n_catalogno");
            NFFglobal.working_no = NFI_I_ADD_CAT_SA_MAP;
            entity->type = NFI_MAP_TYPE;
            break;

        case DELETE_CATALOG_SA_MAP:
            NFFglobal.NFMRfunction[0] = NFMRquery_catalog_sa_map;
            NFFglobal.NFMRfunction[1] = NFMRupdate_catalog_sa_map;
            strcpy (entity->entity_attr, "n_catalogno");
            NFFglobal.working_no = NFI_I_DELETE_CAT_SA_MAP;
            entity->type = NFI_MAP_TYPE;
            break;

        case ADD_PROJECT_ACL_MAP:
            NFFglobal.NFMRfunction[0] = NFMRquery_project_acl_map;
            NFFglobal.NFMRfunction[1] = NFMRupdate_project_acl_map;
            strcpy (entity->entity_attr, "n_projectno");
            NFFglobal.working_no = NFI_I_ADD_PROJ_ACL_MAP;
            entity->type = NFI_MAP_TYPE;
            break;

        case DELETE_PROJECT_ACL_MAP:
            NFFglobal.NFMRfunction[0] = NFMRquery_project_acl_map;
            NFFglobal.NFMRfunction[1] = NFMRupdate_project_acl_map;
            strcpy (entity->entity_attr, "n_projectno");
            NFFglobal.working_no = NFI_I_DELETE_PROJ_ACL_MAP;
            entity->type = NFI_MAP_TYPE;
            break;

        case ADD_PROJECT_SA_MAP:
            NFFglobal.NFMRfunction[0] = NFMRquery_project_sa_map;
            NFFglobal.NFMRfunction[1] = NFMRupdate_project_sa_map;
            strcpy (entity->entity_attr, "n_projectno");
            NFFglobal.working_no = NFI_I_ADD_PROJ_SA_MAP;
            entity->type = NFI_MAP_TYPE;
            break;

        case DELETE_PROJECT_SA_MAP:
            NFFglobal.NFMRfunction[0] = NFMRquery_project_sa_map;
            NFFglobal.NFMRfunction[1] = NFMRupdate_project_sa_map;
            strcpy (entity->entity_attr, "n_projectno");
            NFFglobal.working_no = NFI_I_DELETE_PROJ_SA_MAP;
            entity->type = NFI_MAP_TYPE;
            break;

        case ADD_ACL_CLASS_USERS:
            NFFglobal.NFMRfunction[0] = NFMRquery_acl_class_users;
            NFFglobal.NFMRfunction[1] = NFMRupdate_acl_class_users;
            strcpy (entity->entity_attr, "n_aclno");
            NFFglobal.working_no = NFI_I_ADD_ACL_CLASS_USERS;
            entity->type = NFI_ACL_CLASS_TYPE;
            break;

        case DELETE_ACL_CLASS_USERS:
            NFFglobal.NFMRfunction[0] = NFMRquery_acl_class_users;
            NFFglobal.NFMRfunction[1] = NFMRupdate_acl_class_users;
            strcpy (entity->entity_attr, "n_aclno");
            NFFglobal.working_no = NFI_I_DELETE_ACL_CLASS_USERS;
            entity->type = NFI_ACL_CLASS_TYPE;
            break;

        case ADD_ACL_SIGNOFF_USERS:
            NFFglobal.NFMRfunction[0] = NFMRquery_acl_signoff_users;
            NFFglobal.NFMRfunction[1] = NFMRupdate_acl_signoff_users;
            strcpy (entity->entity_attr, "n_aclno");
            NFFglobal.working_no = NFI_I_ADD_ACL_SIGNOFF_USERS;
            entity->type = NFI_ACL_SIGNOFF_TYPE;
            break;

        case DELETE_ACL_SIGNOFF_USERS:
            NFFglobal.NFMRfunction[0] = NFMRquery_acl_signoff_users;
            NFFglobal.NFMRfunction[1] = NFMRupdate_acl_signoff_users;
            strcpy (entity->entity_attr, "n_aclno");
            NFFglobal.working_no = NFI_I_DELETE_ACL_SIGNOFF_USERS;
            entity->type = NFI_ACL_SIGNOFF_TYPE;
            break;

        default:
            _NFIdebug ((fname, "invalid command <%d>", command));
            _NFFfree_map (entity, NULL);
            ERRload_struct (NFI, NFI_E_FAILURE, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FAILURE);
      }

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    _NFIdebug ((fname, "calling NFMR query mapping function ...\n"));
    if ((status = (long) NFFglobal.NFMRfunction[0]
        ((long) 0, entity_name, &(entity->attr_list),
        &(entity->data_list), &(entity->value_list))) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "NFMR query mapping function = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_map (entity, NULL);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMR query mapping function\n"));

    /*  Erase the message  */

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list",
            entity->attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list",
            entity->data_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("value_list",
            entity->value_list, _NFMdebug_st.NFIdebug_file);
      }

    if ((status = MEMbuild_array (entity->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        _NFFfree_map (entity, NULL);
        NFFset_to_state ();
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (entity->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        _NFFfree_map (entity, NULL);
        NFFset_to_state ();
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Scan the attr_list for all readable and updatable attributes  */

    if ((command != ADD_ACL_CLASS_USERS) &&
        (command != DELETE_ACL_CLASS_USERS) &&
        (command != ADD_ACL_SIGNOFF_USERS) &&
        (command != DELETE_ACL_SIGNOFF_USERS))
      {
        if ((status = _NFFmap_scan_attributes (entity->attr_list,
            &no_attributes, &attr_row_offset)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFmap_scan_attributes = <0x%.8x>\n", status));
            _NFFfree_map (entity, NULL);
            NFFset_to_state ();
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        _NFIdebug ((fname, "no_attributes = <%d>\n", no_attributes));

        if (no_attributes == 0)
          {
            /*  User just needs to confirm  */

            _NFFfree_map (entity, NULL);
            NFFset_to_state ();
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }

        if (no_attributes > 1)
          {
            /*  Use multi-attribute mapping form and code  */

            _NFFfree_map (entity, NULL);
            NFFset_to_state ();
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }

        /*  Store the attribute row offset  */

        entity->validate_row = attr_row_offset;
      }
    else
      {
        /*  Initialize the class/state row offset  */

        entity->active_data = 0;
      }

    switch (command)
      {
        case ADD_CATALOG_ACL_MAP:
        case ADD_CATALOG_SA_MAP:
        case ADD_PROJECT_ACL_MAP:
        case ADD_PROJECT_SA_MAP:
            status = _NFFadd_mapping (title1, title2, entity);
            break;

        case DELETE_CATALOG_ACL_MAP:
            if ((status = _NFFdelete_mapping
                (title1, title2, entity)) == NFI_I_ALL_VALUES)
              {
                status = NFM_E_DISPLAY_CAT_ACL_MAP;
                ERRload_struct (NFI, status, "%s", entity_name);
              }
            break;

        case DELETE_CATALOG_SA_MAP:
            if ((status = _NFFdelete_mapping
                (title1, title2, entity)) == NFI_I_ALL_VALUES)
              {
                status = NFM_E_DISPLAY_CAT_SA_MAP;
                ERRload_struct (NFI, status, "%s", entity_name);
              }
            break;

        case DELETE_PROJECT_ACL_MAP:
            if ((status = _NFFdelete_mapping
                (title1, title2, entity)) == NFI_I_ALL_VALUES)
              {
                status = NFM_E_DISPLAY_PROJ_ACL_MAP;
                ERRload_struct (NFI, status, "%s", entity_name);
              }
            break;

        case DELETE_PROJECT_SA_MAP:
            if ((status = _NFFdelete_mapping
                (title1, title2, entity)) == NFI_I_ALL_VALUES)
              {
                status = NFM_E_DISPLAY_PROJ_SA_MAP;
                ERRload_struct (NFI, status, "%s", entity_name);
              }
            break;

        case ADD_ACL_CLASS_USERS:
            status = _NFFadd_acl_class_users (entity);
            break;

        case DELETE_ACL_CLASS_USERS:
            status = _NFFdelete_acl_class_users (entity);
            break;

        case ADD_ACL_SIGNOFF_USERS:
            status = _NFFadd_acl_signoff_users (entity);
            break;

        case DELETE_ACL_SIGNOFF_USERS:
            status = _NFFdelete_acl_signoff_users (entity);
            break;
      }

    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFF mapping function failed\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmap_scan_attributes (attr_list, no_attributes, attr_row_offset)
  MEMptr    attr_list;         /*  i - standard NFM attribute buffer       */
  int       *no_attributes;    /*  o - total number of readable
                                       and updatable attributes            */
  int       *attr_row_offset;  /*  o - if *no_attributes = 1, this will
                                       contain the row offset;
                                       otherwise, this will be undefined   */
  {
    auto    int     i, fields;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   r_offset;
    auto    short   w_offset;
    static  char    *fname = "_NFFmap_scan_attributes";

    if ((status = _NFFfind_column_offset
        (attr_list, "n_read", &r_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (attr_list, "n_update", &w_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array (attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    data_ptr = (char **) attr_list->data_ptr;

    *no_attributes = 0;
    *attr_row_offset = 0;

    fields = attr_list->columns * attr_list->rows;
    for (i = 0; i < fields; i += attr_list->columns)
      {
        if (((strcmp (data_ptr[i + r_offset], "Y")) == 0) ||
            ((strcmp (data_ptr[i + w_offset], "Y")) == 0))
          {
            /*  This attribute is to be shown to the user  */

            ++(*no_attributes);
          }

        if ((strcmp (data_ptr[i + w_offset], "Y")) == 0)
          {
            /*  This attribute can be updated by the user  */

            *attr_row_offset = i / attr_list->columns;
          }
      }

    /*  Check the total number of readable and writable attributes  */

    if (*no_attributes != 1)
      {
        /*  Set the row offset to be unusable  */

        *attr_row_offset = -1;
      }

    _NFIdebug ((fname, "no_attributes = <%d>\n", *no_attributes));
    _NFIdebug ((fname, "attr_row_offset = <%d>\n", *attr_row_offset));

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _NFFfree_map (entity, form)
  NFFmap    entity;
  Form      *form;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (entity->columns) free (entity->columns);
    MEMclose (&(entity->attr_list));
    MEMclose (&(entity->data_list));
    MEMclose (&(entity->value_list));

    if (entity) free (entity);

    return;
  }
