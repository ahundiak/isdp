
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFacl_write_data (entity, value_row, userno, attribute, keyword)
  NFFmap    entity;
  int       value_row;   /*  Current class/state in the value_buffer  */
  char      *userno;
  char      *attribute;  /*  "n_classno" or "n_stateno"               */
  char      *keyword;    /*  "ADD" or "DROP"                          */
  {
    auto    long    status;
    static  char    *fname = "_NFFacl_write_data";

    _NFIdebug ((fname, "value_row = <%d>\n", value_row));
    _NFIdebug ((fname, "userno = <%s>\n", userno));
    _NFIdebug ((fname, "attribute = <%s>\n", attribute));
    _NFIdebug ((fname, "keyword = <%s>\n", keyword));

    if ((strcmp (keyword, "ADD")) == 0)
      {
        if ((status = _NFFacl_add_write_data
            (entity, value_row, attribute)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFacl_add_write_data = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }
    else
      {
        if ((status = _NFFacl_delete_write_data
            (entity->attr_list, entity->data_list, entity->value_list,
            value_row, userno, attribute)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFacl_delete_write_data = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFacl_add_write_data (entity, value_row, attribute)
  NFFmap    entity;
  int       value_row;   /*  Current class/state in the value_buffer  */
  char      *attribute;  /*  "n_classno" or "n_stateno"               */
  {
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   data_offset;
    auto    short   value_offset;
    static  char    *fname = "_NFFacl_add_write_data";

    /*  Write a blank row into the data buffer  */

    if ((status = _NFFmap_write_blank_row
        (entity->data_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFmap_write_blank_row = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Find the acl_no in the value_list  */

    if ((status = _NFFfind_value_buffer (entity->attr_list,
        entity->value_list, "n_aclno", "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (entity->value_list, "n_aclno", &value_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (entity->value_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (entity->data_list, "n_aclno", &data_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Write the acl_no into the buffer  */

    _NFIdebug ((fname, "n_aclno = <%s>\n", data_ptr[value_offset]));

    if ((status = MEMwrite_data
        (entity->data_list, data_ptr[value_offset],
        (entity->data_list)->rows, data_offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Find the class_no in the value_list  */

    if ((status = _NFFfind_value_buffer (entity->attr_list,
        entity->value_list, attribute, "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (entity->value_list, attribute, &value_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (entity->value_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (entity->data_list, attribute, &data_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Write the current class or state number into the buffer  */

    _NFIdebug ((fname, "class/state = <%s>\n",
        data_ptr[value_offset + (value_row * (entity->value_list)->columns)]));

    if ((status = MEMwrite_data (entity->data_list,
        data_ptr[value_offset + (value_row * (entity->value_list)->columns)],
        (entity->data_list)->rows, data_offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Write "ADD" into the buffer  */

    if ((status = _NFFfind_column_offset
        (entity->data_list, "n_status", &data_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, "Writing \"ADD\" in row %d, col %d in data_list\n",
        (entity->data_list)->rows, data_offset + 1));

    if ((status = MEMwrite_data (entity->data_list, "ADD",
        (entity->data_list)->rows, data_offset + 1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFacl_delete_write_data
(attr_list, data_list, value_list, value_row, userno, attribute)
  MEMptr    attr_list;
  MEMptr    data_list;
  MEMptr    value_list;
  int       value_row;   /*  Current class/state in the value_buffer  */
  char      *userno;
  char      *attribute;  /*  "n_classno" or "n_stateno"               */
  {
    auto    int     i, row;
    auto    int     total_data;
    auto    long    status;
    auto    char    **data_ptr;
    auto    char    *current_no;
    auto    short   found = FALSE;
    auto    short   data_attribute;
    auto    short   data_userno;
    auto    short   value_attribute;
    auto    short   data_status;
    static  char    *fname = "_NFFacl_delete_write_data";

    _NFIdebug ((fname, "value_row = <%d>\n", value_row));
    _NFIdebug ((fname, "userno = <%s>\n", userno));
    _NFIdebug ((fname, "attribute = <%s>\n", attribute));

    /*  Get the offsets for this class/state
        in the value_list and in the data_list  */

    if ((status = _NFFfind_value_buffer
        (attr_list, value_list, attribute, "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (value_list, attribute, &value_attribute)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) value_list->data_ptr;

    /*  Pull out the current class/state number  */

    current_no = data_ptr[value_attribute + (value_row * value_list->columns)];
    _NFIdebug ((fname, "current_no = <%s>\n", current_no));

    if ((status = _NFFfind_column_offset
        (data_list, attribute, &data_attribute)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Get the offset for the user number  */

    if ((status = _NFFfind_column_offset
        (data_list, "n_userno", &data_userno)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (data_list, "n_status", &data_status)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) data_list->data_ptr;
    total_data = data_list->rows * data_list->columns;

    /*  Find the row in the data_list with
        this user/class|state combination  */

    for (i = 0, row = 1; i < total_data; i += data_list->columns, ++row)
      {
        /*  Check the user number first  */

        if ((strcmp (data_ptr[i + data_userno], userno)) != 0) continue;

        /*  Check the class/state  */

        if ((strcmp (data_ptr[i + data_attribute], current_no)) == 0)
          {
            /*  Write "DROP" into the data_list  */

            _NFIdebug ((fname,
                "Writing \"DROP\" in row %d, col %d in data_list\n",
                row, data_status + 1));

            if ((status = MEMwrite_data (data_list,
                "DROP", row, data_status + 1)) != MEM_S_SUCCESS)
              {
                _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
                ERRload_struct
                    (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
              }

            found = TRUE;
            break;
          }
      }

    if (found == FALSE)
      {
        _NFIdebug ((fname, "buffer data was not found\n"));
        ERRload_struct (NFI, NFI_E_BUFFER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_BUFFER);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFacl_set_title (entity, title1, title2, add_or_delete)
  NFFmap    entity;
  char      *title1;
  char      *title2;
  char      *add_or_delete;
  {
    auto    int     value_row;
    auto    int     total_data;
    auto    int     current_no;
    auto    long    status;
    auto    char    **data_ptr;
    auto    char    attribute[40];
    auto    char    column[40];
    auto    char    *current_name;
    auto    short   column_offset;
    auto    short   attribute_offset;
    static  char    *fname = "_NFFacl_set_title";

    _NFIdebug ((fname, "entity->type = <%d>\n", entity->type));

    switch (entity->type)
      {
        case NFI_ACL_CLASS_TYPE:
            strcpy (attribute, "n_classno");
            strcpy (column, "n_classname");
            break;

        case NFI_ACL_SIGNOFF_TYPE:
            strcpy (attribute, "n_stateno");
            strcpy (column, "n_statename");
            break;

        default:
            _NFIdebug ((fname, "unknown type = <%d>\n", entity->type));
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
      }

    if ((status = _NFFfind_value_buffer (entity->attr_list,
        entity->value_list, attribute, "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (entity->value_list, attribute, &attribute_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (entity->value_list, column, &column_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    value_row = entity->active_data * (entity->value_list)->columns;
    _NFIdebug ((fname, "value_row = <%d>\n", value_row));

    total_data = (entity->value_list)->columns * (entity->value_list)->rows;
    if (value_row >= total_data)
      {
        _NFIdebug ((fname, "last class/state has been mapped\n"));
        _NFIdebug ((fname, " returning NFM_E_CANCEL\n"));
        return (NFM_E_CANCEL);
      }

    data_ptr = (char **) (entity->value_list)->data_ptr;
    current_no = atoi (data_ptr[value_row + attribute_offset]);
    current_name = data_ptr[value_row + column_offset];

    _NFIdebug ((fname, "current_no = <%d>\n", current_no));
    _NFIdebug ((fname, "current_name = <%s>\n", current_name));

    switch (entity->type)
      {
        case NFI_ACL_CLASS_TYPE:

            if ((strcmp (add_or_delete, "add")) == 0)
              {
                if ((status = (long) UMSGetByNum
                    (title1, NFT_P_ADD_USERS, NULL)) != UMS_S_SUCCESS)
                  {
                    _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                    _NFIdebug ((fname, "defaulting title\n"));
                    strcpy (title1, "Add Users");
                  }

                if ((status = (long) UMSGetByNum (title2,
                    NFT_P_TO_CLASS, "%s", current_name)) != UMS_S_SUCCESS)
                  {
                    _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                    _NFIdebug ((fname, "defaulting title\n"));
                    sprintf (title2, "to Class \"%s\"", current_name);
                  }
              }
            else
              {
                if ((status = (long) UMSGetByNum
                    (title1, NFT_P_DEL_USERS, NULL)) != UMS_S_SUCCESS)
                  {
                    _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                    _NFIdebug ((fname, "defaulting title\n"));
                    strcpy (title1, "Delete Users");
                  }

                if ((status = (long) UMSGetByNum (title2,
                    NFT_P_FROM_CLASS, "%s", current_name)) != UMS_S_SUCCESS)
                  {
                    _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                    _NFIdebug ((fname, "defaulting title\n"));
                    sprintf (title2, "from Class \"%s\"", current_name);
                  }
              }

            break;

        case NFI_ACL_SIGNOFF_TYPE:

            if ((strcmp (add_or_delete, "add")) == 0)
              {
                if ((status = _NFFacl_set_title_add
                    (entity, title1, title2, value_row,
                    current_no, current_name)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFfind_column_offset = <0x%.8x>\n", status));
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (status);
                  }
              }
            else
              {
                if ((status = _NFFacl_set_title_delete
                    (entity, title1, title2, value_row,
                    current_no, current_name)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFfind_column_offset = <0x%.8x>\n", status));
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (status);
                  }
              }

            break;

        default:
            _NFIdebug ((fname, "unknown type = <%d>\n", entity->type));
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFacl_set_title_add
(entity, title1, title2, value_row, current_no, current_name)
  NFFmap    entity;
  char      *title1;
  char      *title2;
  int       value_row;
  int       current_no;
  char      *current_name;
  {
    auto    int     i;
    auto    int     users;
    auto    int     mapped_states;
    auto    int     total_data;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   signoffs;
    auto    short   state_no;
    static  char    *fname = "_NFFacl_set_title_add";

    _NFIdebug ((fname, "value_row = <%d>\n", value_row));
    _NFIdebug ((fname, "current_no = <%d>\n", current_no));
    _NFIdebug ((fname, "current_name = <%s>\n", current_name));

    if ((status = _NFFfind_column_offset
        (entity->value_list, "n_signoffs", &signoffs)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (entity->value_list)->data_ptr;
    users = atoi (data_ptr[value_row + signoffs]);
    _NFIdebug ((fname, "users = <%d>\n", users));

    if (users == 0)
      {
        _NFIdebug ((fname,
            "no signoff users are required for state <%s>\n", current_name));
        ERRload_struct (NFI, NFI_I_NO_SIGNOFF, "%s", current_name);
        _NFIdebug ((fname, " returning NFI_I_NO_SIGNOFF\n"));
        return (NFI_I_NO_SIGNOFF);
      }

    if ((status = _NFFfind_column_offset
        (entity->data_list, "n_stateno", &state_no)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  See how many signoff users are already mapped to this state  */

    total_data = (entity->data_list)->rows * (entity->data_list)->columns;
    data_ptr = (char **) (entity->data_list)->data_ptr;

    mapped_states = 0;
    for (i = 0; i < total_data; i += (entity->data_list)->columns)
      {
        if ((atoi (data_ptr[i + state_no])) == current_no)
            ++mapped_states;
      }

    _NFIdebug ((fname, "mapped_states = <0x%.8x>\n", mapped_states));

    if (mapped_states >= users)
      {
        if ((status = (long) UMSGetByNum
            (title1, NFT_P_CHOOSE_USERS, NULL)) != UMS_S_SUCCESS)
          {
            _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
            _NFIdebug ((fname, "defaulting title\n"));
            strcpy (title1, "Choose Signoff Users");
          }
      }
    else
      {
        if ((users - mapped_states) == 1)
          {
            if ((status = (long) UMSGetByNum
                (title1, NFT_P_CHOOSE_1_USER, NULL)) != UMS_S_SUCCESS)
              {
                _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                _NFIdebug ((fname, "defaulting title\n"));
                strcpy (title1, "Choose At Least 1 Signoff User");
              }
          }
        else
          {
            if ((status = (long) UMSGetByNum (title1, NFT_P_CHOOSE_N_USERS,
                "%d", users - mapped_states)) != UMS_S_SUCCESS)
              {
                _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                _NFIdebug ((fname, "defaulting title\n"));
                sprintf (title1,
                    "Choose At Least %d Signoff Users", users - mapped_states);
              }
          }
      }

    if ((status = (long) UMSGetByNum
        (title2, NFT_P_FOR_STATE, "%s", current_name)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title2, "for State \"%s\"", current_name);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFacl_set_title_delete
(entity, title1, title2, value_row, current_no, current_name)
  NFFmap    entity;
  char      *title1;
  char      *title2;
  int       value_row;
  int       current_no;
  char      *current_name;
  {
    auto    int     users;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   signoffs;
    static  char    *fname = "_NFFacl_set_title_delete";

    _NFIdebug ((fname, "value_row = <%d>\n", value_row));
    _NFIdebug ((fname, "current_no = <%d>\n", current_no));
    _NFIdebug ((fname, "current_name = <%s>\n", current_name));

    if ((status = _NFFfind_column_offset
        (entity->value_list, "n_signoffs", &signoffs)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (entity->value_list)->data_ptr;
    users = atoi (data_ptr[value_row + signoffs]);
    _NFIdebug ((fname, "users = <%d>\n", users));

    if (users == 0)
      {
        if ((status = (long) UMSGetByNum
            (title1, NFT_P_DEL_ALL_USERS, NULL)) != UMS_S_SUCCESS)
          {
            _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
            _NFIdebug ((fname, "defaulting title\n"));
            strcpy (title1, "All Signoff Users Can Be Deleted");
          }
      }
    else if (users == 1)
      {
        if ((status = (long) UMSGetByNum
            (title1, NFT_P_DEL_ALL_1_USER, NULL)) != UMS_S_SUCCESS)
          {
            _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
            _NFIdebug ((fname, "defaulting title\n"));
            strcpy (title1, "All But 1 Signoff User Can Be Deleted");
          }
      }
    else
      {
        if ((status = (long) UMSGetByNum
            (title1, NFT_P_DEL_ALL_N_USER, "%d", users)) != UMS_S_SUCCESS)
          {
            _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
            _NFIdebug ((fname, "defaulting title\n"));
            sprintf (title1, "All But %d Signoff Users Can Be Deleted", users);
          }
      }

    if ((status = (long) UMSGetByNum
        (title2, NFT_P_FROM_STATE, "%s", current_name)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title2, "from State \"%s\"", current_name);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
