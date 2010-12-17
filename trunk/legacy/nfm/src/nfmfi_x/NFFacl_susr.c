
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFload_acl_signoff_users (form, entity)
  Form    form;
  NFFmap  entity;
  {
    auto    int     i, j;
    auto    int     attr_mask, rows, vis_rows;
    auto    int     dfields, vfields;
    auto    char    *stateno;
    auto    char    **ddata, **vdata;
    auto    short   exists = FALSE;
    auto    short   user_offset, state_offset;
    static  char    *fname = "_NFFload_acl_signoff_users";

    stateno = entity->statenos[entity->active_data];
    user_offset = entity->user_offset;
    state_offset = entity->state_offset;

    /*  Load up the MCF with the list of users that don't
        already exist as signoff users for the first state  */

    ddata = (char **) entity->data_list->data_ptr;
    vdata = (char **) entity->value_list->data_ptr;
    dfields = entity->data_list->columns * entity->data_list->rows;
    vfields = entity->value_list->columns * entity->value_list->rows;

    /*  Check each user to see if he is mapped  */

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 3 Feb 94 */
    FIg_set_font( form, BOTTOM_MCF, "7x13bold", 15 );
    FIg_set_font( form, SIGNOFF_TOP_MCF, "7x13bold", 15 );
#endif

    for (i = 0, rows = 0; i < vfields; i += entity->value_list->columns)
      {
        /*  Check all rows in the data_list
            for this user/state combination  */

        exists = FALSE;
        for (j = 0; j < dfields; j += entity->data_list->columns)
          {
            /*  Userno is in the first column and username
                is in the second column (in the value_list)  */

            if (((strcmp (vdata[i], ddata[j + user_offset])) == 0) &&
                ((strcmp (ddata[j + state_offset], stateno)) == 0))
              {
                /*  This combination already exists  */

                exists = TRUE;
                break;
              }
          }

        if (exists == FALSE)
          {
            _NFIdebug ((fname,
                "setting <%s> in row %d\n", vdata[i + 1], rows));
            FIfld_set_text (form, BOTTOM_MCF, rows, 0, vdata[i + 1], FALSE);

            /*  Default override to "No"  */

            FIfld_set_text (form, BOTTOM_MCF, rows++, 1, "No", FALSE);
          }
      }

    /*  See if all combinations already exist for this state  */

    if (rows == 0)
      {
        /*  Tell the calling function that no rows were added  */

        _NFIdebug ((fname,
            "returning NFI_I_ALL_VALUES <0x%.8x>\n", NFI_I_ALL_VALUES));
        return (NFI_I_ALL_VALUES);
      }

    /*  Enable the scroll bar, if necessary  */

    FIfld_get_num_vis_rows (form, BOTTOM_MCF, &vis_rows);
    FImcf_get_attr (form, BOTTOM_MCF, &attr_mask);
    if (rows > vis_rows)
      {
        /*  OR in the vertical scroll bar attribute  */

        attr_mask |= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }
    else
      {
        /*  Take out the vertical scroll bar attribute  */

        if (attr_mask & (FI_VERT_SCROLL | FI_DISPLAY_VSCROLL))
            attr_mask ^= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }

    FImcf_set_attr (form, BOTTOM_MCF, attr_mask);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_acl_signoff_users (entity)
  NFFmap    entity;
  {
    auto    int     i;
    auto    long    status, return_status = NFI_S_SUCCESS;
    auto    char    **vdata;
    auto    char    title[NFF_MAX_MESSAGE];
    static  char    *fname = "_NFFadd_acl_signoff_users";

    /*  Load in the form  */

    if ((status = (long) FIf_new
        (ADD_ACL_SIGNOFF_USERS_LABEL, ADD_ACL_SIGNOFF_USERS_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        _NFFfree_map (entity, NULL);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Find the value list for "n_stateno"  */

    if ((status = _NFFfind_value_buffer (entity->attr_list,
        entity->value_list, "n_stateno", "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);

        /*  This is okay; there are no signoff users for this ACL  */

        ERRload_struct (NFI, NFI_I_NO_SIGNOFF_USERS_REQ, "%s", NFFglobal.acl);
        _NFIdebug ((fname, " returning NFI_I_NO_SIGNOFF_USERS_REQ\n"));
        return (NFI_I_NO_SIGNOFF_USERS_REQ);
      }

    entity->num_states = entity->value_list->rows;
    vdata = (char **) entity->value_list->data_ptr;

    /*  Allocate space to store the state names/numbers in  */

    if ((entity->statenames = (char **)
        calloc (entity->num_states * sizeof (char **), 1)) == NULL)
      {
        _NFIdebug ((fname, "calloc failed; size = <%d>\n",
            entity->num_states * sizeof (char **)));
        _NFFfree_map (entity, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((entity->statenos = (char **)
        calloc (entity->num_states * sizeof (char **), 1)) == NULL)
      {
        _NFIdebug ((fname, "calloc failed; size = <%d>\n",
            entity->num_states * sizeof (char **)));
        _NFFfree_map (entity, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    for (i = 0; i < entity->num_states; ++i)
      {
        if ((entity->statenames[i] = (char *)
            calloc (20 * sizeof (char), 1)) == NULL)
          {
            _NFIdebug ((fname,
                "calloc failed; size = <%d>\n", 20 * sizeof (char)));
            _NFFfree_map (entity, &NFFglobal.current_form);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        /*  Store the state names for use later  */

        strcpy (entity->statenames[i],
            vdata[(i * entity->value_list->columns) + 1]);

        if ((entity->statenos[i] = (char *)
            calloc (20 * sizeof (char), 1)) == NULL)
          {
            _NFIdebug ((fname,
                "calloc failed; size = <%d>\n", 20 * sizeof (char)));
            _NFFfree_map (entity, &NFFglobal.current_form);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        /*  Store the state numbers for use later  */

        strcpy (entity->statenos[i], vdata[i * entity->value_list->columns]);
      }

    if ((status = _NFFfind_column_offset (entity->data_list,
        "n_userno", &entity->user_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset (entity->data_list,
          "n_stateno", &entity->state_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Find the value list for "n_userno"  */

    if ((status = _NFFfind_value_buffer (entity->attr_list,
        entity->value_list, "n_userno", "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Find a state that all signoff users have not been already mapped  */

    for (i = 0; i < entity->num_states; ++i)
      {
        entity->active_data = i;

        /*  Load the first message with this state  */

        return_status = NFI_P_CHOOSE_STATE_USERS;
        ERRload_struct (NFI, return_status, "%s", entity->statenames[i]);

        /*  Load up the MCF with the appropriate usernames  */

        if ((status = _NFFload_acl_signoff_users
            (NFFglobal.current_form, entity)) != NFI_S_SUCCESS)
          {
            if (status != NFI_I_ALL_VALUES)
              {
                _NFIdebug ((fname,
                    "_NFFload_acl_signoff_users = <%d>\n", status));
                _NFFfree_map (entity, &NFFglobal.current_form);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
              }
            else
              {
                /*  All possible users have been mapped for this state  */

                ;
              }
          }
        else
          {
            /*  The possible signoff users were loaded  */

            break;
          }
      }

    /*  Make sure there is some data to display  */

    if (status == NFI_I_ALL_VALUES)
      {
        _NFIdebug ((fname, "All possible values are mapped\n"));
        _NFFfree_map (entity, &NFFglobal.current_form);

        ERRload_struct (NFI, NFI_I_ALL_VALUES, NULL);
/*
        ERRload_struct (NFI, NFI_I_ALL_SIGNOFF_USERS, NULL);
*/
/*
        _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_I_ALL_SIGNOFF_USERS));
*/
        return (NFI_I_ALL_VALUES);
/*
        return (NFI_I_ALL_SIGNOFF_USERS);
*/
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) entity)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
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
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = (long) UMSGetByNum
        (title, NFT_P_ADD_ACL_SIGN, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Add ACL Signoff Users");
      }

    FIg_set_text (NFFglobal.current_form, TITLE, title);

    /*  Display the form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_map (entity, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (return_status);
  }


long _NFFadd_acl_signoff_users_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    int     i, col, sel, rpos;
    auto    long    status = NFI_S_SUCCESS;
    auto    long    return_status = NFI_S_SUCCESS;
    auto    char    text[20];
    static  char    *command = NFI_M_ADD_ACL_SIGNOFF_USERS;
    static  char    *fname = "_NFFadd_acl_signoff_users_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFmap  entity;

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    FIf_get_user_pointer (*form, &entity);

    /*  Load the prompt so that it doesn't get overwritten  */

    status = NFI_P_CHOOSE_STATE_USERS;
    ERRload_struct (NFI,
        status, "%s", entity->statenames[entity->active_data]);

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_HELP, "%s%d", "_NFFhelp_topic", status);
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

        case FI_EXECUTE:

            /*  Prepare the data_list  */

            if ((status = _NFFacl_load_signoff_data_list (*form, entity,
                (int) entity->active_data, "ADD")) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFacl_load_signoff_data_list = <0x%.8x>\n", status));
                FIg_reset (*form, g_label);
                break;
              }

            /*  Find the value list for "n_userno"  */

            if ((status = _NFFfind_value_buffer (entity->attr_list,
                entity->value_list, "n_userno", "n_valueno")) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "_NFFfind_value_buffer = <%d>\n", status));
                FIg_reset (*form, g_label);
                break;
              }

            /*  There might be states that require no signoff users  */

            status = NFI_I_ALL_VALUES;
            for (i = entity->active_data + 1; i < entity->num_states; ++i)
              {
                entity->active_data = i;

                /*  Load the next message with this state  */

                return_status = NFI_P_CHOOSE_STATE_USERS;
                ERRload_struct (NFI,
                    return_status, "%s", entity->statenames[i]);

                /*  Load up the MCF with the appropriate usernames  */

                if ((status = _NFFload_acl_signoff_users
                    (NFFglobal.current_form, entity)) != NFI_S_SUCCESS)
                  {
                    if (status != NFI_I_ALL_VALUES)
                      {
                        _NFIdebug ((fname,
                            "_NFFload_acl_signoff_users = <%d>\n", status));
                        FIg_reset (*form, g_label);
                        break;
                      }
                    else
                      {
                        /*  All possible users have
                            been mapped for this state  */

                        ;
                      }
                  }
                else
                  {
                    /*  The possible signoff users were loaded  */

                    break;
                  }
              }

            /*  See if this was the last state to map signoff users to  */

            if (status == NFI_I_ALL_VALUES)
              {
                _NFIdebug ((fname, "All possible values are mapped\n"));
              }
            else
              {
                /*  We're not done yet  */

                status = return_status;
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

        case BOTTOM_MCF:

            FImcf_get_active_col (*form, g_label, &col, &rpos);
            _NFIdebug ((fname, "active column is %d\n", col));

            FIfld_get_select (*form, g_label, row, col, &sel);

            /*  Select/unselect both columns  */

            FImcf_set_select (*form, g_label, row, sel);

            if (col == 1)
              {
                /*  The override column was selected; if it is not
                    selected, toggle the text; if so, leave it alone  */

                if (sel == FALSE)
                  {
                    FIfld_get_text (*form, g_label,
                        row, col, sizeof (text), text, &sel, &rpos);
                    if ((strcmp (text, "No")) == 0)
                        strcpy (text, "Yes");
                    else
                        strcpy (text, "No");
    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
                    FIg_set_font( *form, g_label, "7x13bold", 15 );
#endif
                    FIfld_set_text (*form, g_label, row, col, text, sel);

                    /*  Select both columns  */

                    FImcf_set_select (*form, g_label, row, TRUE);
                  }
              }

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFdelete_acl_signoff_users (entity)
  NFFmap    entity;
  {
    auto    long    status;
    auto    char    title1[NFF_MAX_MESSAGE];
    auto    char    title2[NFF_MAX_MESSAGE];
    static  char    *fname = "_NFFdelete_acl_signoff_users";

    /*  Load in the form  */

    if ((status = (long) FIf_new (DELETE_ACL_SIGNOFF_USERS_LABEL,
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
        (NFFglobal.current_form, entity, "n_stateno", FALSE)) != NFI_S_SUCCESS)
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


long _NFFdelete_acl_signoff_users_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    long    status = NFI_S_SUCCESS;
    auto    char    title1[NFF_MAX_MESSAGE];
    auto    char    title2[NFF_MAX_MESSAGE];
    auto    short   done = FALSE;
    static  char    *command = NFI_M_DELETE_ACL_SIGNOFF_USERS;
    static  char    *fname = "_NFFdelete_acl_signoff_users_notify";

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
                status = NFI_E_HELP;
                ERRload_struct (NFI, status, "%s%d", "_NFFhelp_topic", status);
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

            if ((status = _NFFacl_load_signoff_data_list (*form, entity,
                (int) entity->active_data, "DROP")) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFacl_load_signoff_data_list = <0x%.8x>\n", status));
                FIg_reset (*form, g_label);
                break;
              }

            /*  There might be states that require no signoff users  */

            while (1)
              {
                /*  Map signoff users into the next state  */

                ++(entity->active_data);

                if ((status = _NFFacl_set_title
                    (entity, title1, title2, "delete")) != NFI_I_NO_SIGNOFF)
                  {
                    if (status == NFM_E_CANCEL)
                      {
                        _NFIdebug ((fname, "all states have been mapped\n"));
                        status = NFI_S_SUCCESS;
                        done = TRUE;
                        break;
                      }

                    _NFIdebug ((fname,
                        "found a state that needs signoff users\n"));
                    done = FALSE;
                    break;
                  }

                /*  See if this was the last state to map signoff users to  */

                if ((status = _NFFfind_value_buffer
                    (entity->attr_list, entity->value_list,
                    "n_stateno", "n_valueno")) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFfind_value_buffer = <0x%.8x>\n", status));
                    FIg_reset (*form, g_label);
                    done = FALSE;
                    break;
                  }

                if ((entity->active_data + 1) == (entity->value_list)->rows)
                  {
                    /*  This is the last state, call NFMR  */

                    done = TRUE;
                    break;
                  }
              }

            if (done == FALSE)
              {
                FIg_set_text (*form, TITLE1, title1);
                FIg_set_text (*form, TITLE2, title2);
                FIg_delete (*form, MAP_TOP_MCF);
                FIg_delete (*form, MAP_BOTTOM_MCF);

                if ((status = _NFFacl_load_value_list
                    (*form, entity, "n_stateno", FALSE)) != NFI_S_SUCCESS)
                    _NFIdebug ((fname,
                        "_NFFacl_load_value_list = <0x%.8x>\n", status));

                FIg_reset (*form, FI_ACCEPT);
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


long _NFFacl_load_signoff_data_list (form, entity, row, keyword)
  Form      form;
  NFFmap    entity;
  int       row;      /*  Current state in the value_buffer  */
  char      *keyword; /*  "ADD" or "DROP"                    */
  {
    auto    int     i, j;
    auto    int     selected;
    auto    int     r_pos;
    auto    int     num_rows;
    auto    int     total_data;
    auto    int     buffer_row;
    auto    int     no_signoffs;
    auto    int     no_selected;
    auto    long    status;
    auto    char    **data_ptr;
    auto    char    **ddata_ptr;
    auto    char    text[40], *userno;
    auto    short   signoffs;
    auto    short   data_userno;
    auto    short   value_userno;
    auto    short   value_username;
    auto    short   override_offset;
    auto    short   stateno_offset;
    auto    int     label = MAP_BOTTOM_MCF;
    static  char    *fname = "_NFFacl_load_signoff_data_list";

    _NFIdebug ((fname, "row = <%d>\n", row));
    _NFIdebug ((fname, "keyword = <%s>\n", keyword));

    if ((strcmp (keyword, "ADD")) == 0)
        label = BOTTOM_MCF;

    if ((status = _NFFfind_value_buffer (entity->attr_list,
        entity->value_list, "n_stateno", "n_valueno")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_value_buffer = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (entity->value_list, "n_signoffs", &signoffs)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (entity->data_list, "n_override", &override_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (entity->data_list, "n_stateno", &stateno_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (entity->value_list)->data_ptr;
    ddata_ptr = (char **) (entity->data_list)->data_ptr;

    no_signoffs = atoi
        (data_ptr[((row * ((entity->value_list)->columns)) + signoffs)]);
    _NFIdebug ((fname, "no_signoffs = <%d>\n", no_signoffs));

    if ((status = (long) FIfld_get_num_rows
        (form, label, &num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Verify the minimum number of signoff users for this state  */

    if ((strcmp (keyword, "ADD")) == 0)
      {
        no_selected = 0;
        for (i = 0; i < entity->data_list->rows; ++i)
          {
            /*  Check only this state  */

            if ((strcmp (entity->statenos[row],
                ddata_ptr[(i * entity->data_list->columns) + stateno_offset]))
                != 0)
                continue;

            ++no_selected;
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

            ++no_selected;
          }

        _NFIdebug ((fname, "no_selected = <%d>\n", no_selected));

        if (no_selected < no_signoffs)
          {
            ERRload_struct (NFI, NFI_I_SIGNOFF_USER, "%d", no_signoffs);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_I_SIGNOFF_USER);
          }
      }

    /*  Verify the minimum number of signoff users remain  */

    if ((strcmp (keyword, "DROP")) == 0)
      {
        no_selected = 0;

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

            ++no_selected;
          }

        _NFIdebug ((fname, "no_selected = <%d>\n", no_selected));

        if ((num_rows - no_selected) < no_signoffs)
          {
            ERRload_struct (NFI, NFI_I_LEAVE_SIGNOFF_USER, "%d", no_signoffs);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_I_LEAVE_SIGNOFF_USER);
          }
      }

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

        if ((status = (long) FIfld_get_text (form, label,
            i, 0, sizeof (text), text, &selected, &r_pos)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
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
                _NFIdebug ((fname, "buffer_row = <%d>\n", j));
                buffer_row = j;
                break;
              }
          }

        if (buffer_row == -1)
          {
            _NFIdebug ((fname, "buffer data was not found\n"));
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }

        userno = data_ptr[value_userno + buffer_row];

        if ((status = _NFFacl_write_data
            (entity, row, userno, "n_stateno", keyword)) != NFI_S_SUCCESS)
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

        /*  Get the text from the override column  */

        if ((status = (long) FIfld_get_text (form, label,
            i, 1, sizeof (text), text, &selected, &r_pos)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        _NFIdebug ((fname, "text = <%s>\n", text));

        if ((strcmp (text, "Yes")) == 0)
            strcpy (text, "Y");
        else
            strcpy (text, "N");

        if ((status = MEMwrite_data (entity->data_list, text,
            (entity->data_list)->rows, override_offset + 1)) != MEM_S_SUCCESS)
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
