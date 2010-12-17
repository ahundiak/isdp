
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFadd_acl_class_users (entity)
  NFFmap    entity;
  {
    auto    long    status;
    auto    char    title1[NFF_MAX_MESSAGE];
    auto    char    title2[NFF_MAX_MESSAGE];
    static  char    *fname = "_NFFadd_acl_class_users";

    /*  Load in the form  */

    if ((status = (long) FIf_new (ADD_ACL_CLASS_USERS_LABEL,
        WORKFLOW_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        _NFFfree_map (entity, NULL);
        NFFset_to_state ();
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Create the mcf from the users in the value_list  */

    if ((status = _NFFacl_load_value_list
        (NFFglobal.current_form, entity, "n_classno", TRUE)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFacl_load_value_list = <0x%.8x>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) entity)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Set the title  */

    if ((status = _NFFacl_set_title
        (entity, title1, title2, "add")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFacl_set_title = <0x%.8x>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    FIg_set_text (NFFglobal.current_form, TITLE1, title1);
    FIg_set_text (NFFglobal.current_form, TITLE2, title2);

    /*  Display the form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_acl_class_users_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    long    status = NFI_S_SUCCESS;
    auto    char    title1[NFF_MAX_MESSAGE];
    auto    char    title2[NFF_MAX_MESSAGE];
    auto    short   call_process_data = FALSE;
    static  char    *command = NFI_M_ADD_ACL_CLASS_USERS;
    static  char    *fname = "_NFFadd_acl_class_users_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFmap  entity;

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    FIf_get_user_pointer (*form, &entity);

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic", status);
                status = NFI_E_HELP;
              }

            break;

        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_map (entity, form);

            break;

        case FI_ACCEPT:

            /*  Prepare the data_list  */

            if ((status = _NFFacl_load_class_data_list (*form, entity,
                (int) entity->active_data, "ADD")) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "_NFFacl_load_class_data_list = <0x%.8x>\n",
                    status));
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            if ((status = _NFFfind_value_buffer (entity->attr_list,
                entity->value_list, "n_classno", "n_valueno")) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_value_buffer = <0x%.8x>\n", status));
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            /*  See if this was the last class to put users in  */

            if ((entity->active_data + 1) != (entity->value_list)->rows)
              {
                /*  Put users in the next class  */

                ++(entity->active_data);

                if ((status = _NFFacl_set_title
                    (entity, title1, title2, "add")) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFacl_set_title = <0x%.8x>\n", status));
                    FIg_set_state_off (*form, FI_ACCEPT);
                    break;
                  }
                FIg_erase (*form, TITLE1);
                FIg_erase (*form, TITLE2);
                FIg_set_text (*form, TITLE1, title1);
                FIg_set_text (*form, TITLE2, title2);
                FIg_display (*form, TITLE1);
                FIg_display (*form, TITLE2);
                FIg_delete (*form, MAP_TOP_MCF);
                FIg_delete (*form, MAP_BOTTOM_MCF);
                _NFFacl_load_value_list (*form, entity, "n_classno", TRUE);
                FIg_set_state_off (*form, FI_ACCEPT);
                FIf_display (*form);
                break;
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("attr_list",
                    entity->attr_list, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("data_list",
                    entity->data_list, _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFFglobal.working_no, NULL);

            /*  Call NFMR to update the ACL  */

            status = (long) NFFglobal.NFMRfunction[1]
                ((long) 0, entity->attr_list, entity->data_list);
            _NFIdebug ((fname,
                "NFMR update ACL function = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            if (entity->command_type == 1)
                call_process_data = TRUE;

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_map (entity, form);

            if (NFFglobal.status == NFM_S_SUCCESS)
              {
                /*  See if the command was called from "Define ACL"  */

                if (call_process_data == TRUE)
                  {
                    /*  Add signoff users to the ACL  */

                    if ((status = NFFadd_acl_signoff_users
                        (NFFglobal.acl)) != NFI_S_SUCCESS)
                        _NFIdebug ((fname,
                            "NFFadd_acl_signoff_users = <0x%.8x>\n", status));

                    /*  Reset the form pointer passed in so that any
                        messages will show up in the right place - Glenn  */

                    *form = NFFglobal.current_form;
                  }
              }

            break;

        case MAP_BOTTOM_MCF:
            status = _NFFmap_bottom_mcf (*form, g_label, row);
            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFdelete_acl_class_users (entity)
  NFFmap    entity;
  {
    auto    long    status;
    auto    char    title1[NFF_MAX_MESSAGE];
    auto    char    title2[NFF_MAX_MESSAGE];
    static  char    *fname = "_NFFdelete_acl_class_users";

    /*  Load in the form  */

    if ((status = (long) FIf_new (DELETE_ACL_CLASS_USERS_LABEL,
        WORKFLOW_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        _NFFfree_map (entity, NULL);
        NFFset_to_state ();
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Create the mcf from the users in the value_list  */

    if ((status = _NFFacl_load_value_list
        (NFFglobal.current_form, entity, "n_classno", FALSE)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFacl_load_value_list = <0x%.8x>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) entity)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Set the title  */

    if ((status = _NFFacl_set_title
        (entity, title1, title2, "delete")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFacl_set_title = <0x%.8x>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    FIg_set_text (NFFglobal.current_form, TITLE1, title1);
    FIg_set_text (NFFglobal.current_form, TITLE2, title2);

    /*  Display the form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        NFFset_to_state ();
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFdelete_acl_class_users_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    long    status = NFI_S_SUCCESS;
    auto    char    title1[NFF_MAX_MESSAGE];
    auto    char    title2[NFF_MAX_MESSAGE];
    static  char    *command = NFI_M_DELETE_ACL_CLASS_USERS;
    static  char    *fname = "_NFFdelete_acl_class_users_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFmap  entity;

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    FIf_get_user_pointer (*form, &entity);

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic", status);
                status = NFI_E_HELP;
              }

            break;

        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_map (entity, form);

            break;

        case FI_ACCEPT:

            /*  Prepare the data_list  */

            if ((status = _NFFacl_load_class_data_list (*form, entity,
                (int) entity->active_data, "DROP")) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "_NFFacl_load_class_data_list = <0x%.8x>\n",
                    status));
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            if ((status = _NFFfind_value_buffer (entity->attr_list,
                entity->value_list, "n_classno", "n_valueno")) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_value_buffer = <0x%.8x>\n", status));
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            /*  See if this was the last class to delete users from  */

            if ((entity->active_data + 1) != (entity->value_list)->rows)
              {
                /*  Delete users from the next class  */

                ++(entity->active_data);

                if ((status = _NFFacl_set_title
                    (entity, title1, title2, "delete")) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFacl_set_title = <0x%.8x>\n", status));
                    FIg_set_state_off (*form, FI_ACCEPT);
                    break;
                  }

                FIg_erase (*form, TITLE1);
                FIg_erase (*form, TITLE2);
                FIg_set_text (*form, TITLE1, title1);
                FIg_set_text (*form, TITLE2, title2);
                FIg_display (*form, TITLE1);
                FIg_display (*form, TITLE2);
                FIg_delete (*form, MAP_TOP_MCF);
                FIg_delete (*form, MAP_BOTTOM_MCF);
                status = _NFFacl_load_value_list
                    (*form, entity, "n_classno", FALSE);
                FIg_set_state_off (*form, FI_ACCEPT);
                FIf_display (*form);
                break;
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("attr_list",
                    entity->attr_list, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("data_list",
                    entity->data_list, _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFFglobal.working_no, NULL);

            /*  Call NFMR to update the ACL  */

            status = (long) NFFglobal.NFMRfunction[1]
                ((long) 0, entity->attr_list, entity->data_list);
            _NFIdebug ((fname,
                "NFMR update ACL function = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_map (entity, form);

            break;

        case MAP_BOTTOM_MCF:
            status = _NFFmap_bottom_mcf (*form, g_label, row);
            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFacl_load_class_data_list (form, entity, row, keyword)
  Form     form;
  NFFmap   entity;
  int      row;      /*  Current class in the value_buffer  */
  char     *keyword; /*  "ADD" or "DROP"                    */
  {
    auto    int     i, j;
    auto    int     length;
    auto    int     selected;
    auto    int     r_pos;
    auto    int     num_rows;
    auto    int     total_data;
    auto    int     buffer_row;
    auto    long    status;
    auto    char    **data_ptr;
    auto    char    *text, *userno;
    auto    short   data_userno;
    auto    short   value_userno;
    auto    short   value_username;
    auto    int     label = MAP_BOTTOM_MCF;
    static  char    *fname = "_NFFacl_load_class_data_list";

    /*  Find the user number column in the data_list and the value_list  */

    if ((status = _NFFfind_column_offset
        (entity->data_list, "n_userno", &data_userno)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_value_buffer (entity->attr_list,
        entity->value_list, "n_userno", "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (entity->value_list, "n_userno", &value_userno)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (entity->value_list, "n_username", &value_username)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    total_data = (entity->value_list)->rows * (entity->value_list)->columns;

    /*  Find all selected rows and write them into the buffer  */

    if ((status = (long) FIfld_get_num_rows
        (form, label, &num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    for (i = 0; i < num_rows; ++i)
      {
        if ((status = (long) FIfld_get_select
            (form, label, i, 0, &selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (selected == FALSE) continue;

        /*  Reset the value_list to point to the user numbers  */

        if ((status = _NFFfind_value_buffer (entity->attr_list,
            entity->value_list, "n_userno", "n_valueno")) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        data_ptr = (char **) (entity->value_list)->data_ptr;

        /*  Pull the selected text out of the first column in the mcf  */

        if ((status = (long) FIfld_get_text_length
            (form, label, i, 0, &length)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        _NFIdebug ((fname, "length of text = <%d>\n", length));

        if (length == 0)
          {
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }

        if ((text = (char *) malloc (length)) == NULL)
          {
            _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
            ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MALLOC);
          }

        if ((status = (long) FIfld_get_text (form, label,
            i, 0, length, text, &selected, &r_pos)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            if (text) free (text);
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        _NFIdebug ((fname, "text = <%s>\n", text));

        /*  Find which row in the value_list this data is in  */

        buffer_row = -1;
        for (j = 0; j < total_data; j += (entity->value_list)->columns)
          {
            if ((strcmp (data_ptr[j + value_username], text)) == 0)
              {
                _NFIdebug ((fname, "buffer_row = <0x%.8x>\n", j));
                buffer_row = j;
                break;
              }
          }

        if (text) free (text);

        if (buffer_row == -1)
          {
            _NFIdebug ((fname, "buffer data was not found\n"));
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }

        userno = data_ptr[value_userno + buffer_row];

        if ((status = _NFFacl_write_data
            (entity, row, userno, "n_classno", keyword)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFacl_write_data = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        /*  If this is a delete command, we're done with this user  */

        if ((strcmp (keyword, "DROP")) == 0) continue;

        _NFIdebug ((fname, "Writing <%s> into row %d, col %d in data_list\n",
            userno, (entity->data_list)->rows, data_userno + 1));

        if ((status = MEMwrite_data (entity->data_list, userno,
            (entity->data_list)->rows, data_userno + 1)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
