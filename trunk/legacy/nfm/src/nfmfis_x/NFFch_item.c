
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFchange_item (catalog, item_name, revision)
  char    *catalog;
  char    *item_name;
  char    *revision;
  {
    auto    long    status;
    auto    char    title[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFchange_item";

    /*  Pointer to the item structure  */

    NFFadd_ptr    item;

    /*  Initialize the item structure  */

    if ((item = (NFFadd_ptr) malloc
        (sizeof (struct NFFadd_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFadd_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFadd_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    item->done = FALSE;
    item->rows = NULL;
    item->active_attribute = -1;
    item->validate_row = -1;
    item->attr_list = NULL;
    item->data_list = NULL;
    item->value_list = NULL;

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    _NFIdebug ((fname, "calling NFMRprepare_update_item ...\n"));
    if ((status = NFMRprepare_update_item ((long) 0,
        catalog, item_name, revision, &(item->attr_list),
        &(item->data_list), &(item->value_list))) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRprepare_update_item = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (item, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRprepare_update_item\n"));

    if ((status = MEMbuild_array (item->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (item->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list", item->attr_list,
            _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list", item->data_list,
            _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers("value_list", item->value_list,
            _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the add/change form  */

    if ((status = (long) FIf_new (CHANGE_ITEM_LABEL,
        ADD_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, NULL);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the data in the attributes field  */

    if ((status = _NFFadd_load_attributes
        (NFFglobal.current_form, item, "n_update")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_load_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) item)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, &NFFglobal.current_form);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Erase the message  */

    NFFerase_message ();

    /*  Set the value field to have only one row  */

    if ((status = (long) FIfld_set_num_rows
        (NFFglobal.current_form, VALUE_FIELD, 1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    if ((status = (long) UMSGetByNum (title,
        NFT_P_CHANGE_ITEM, "%s%s", item_name, revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title,
            "Change Item \"%s\" Revision \"%s\"", item_name, revision);
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Display the Add Item form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Select the first row  */

    if ((status = (long) FImcf_set_select
        (NFFglobal.current_form, INFORMATION_MCF, 0, TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFadd_attributes_field
        (NFFglobal.current_form, 0, "n_update", item)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_attributes_field = <0x%.8x>\n", status));
        NFMRcancel_update_item ((long) 0, item->attr_list, item->data_list);
        _NFFfree_add (item, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFchange_item_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    /*  Pointer to structure to store the MEM pointers in  */

    auto    NFFadd_ptr    item;
    auto    long    status = NFI_S_SUCCESS;
    auto    long    cmd_status = NFM_S_SUCCESS;
    static  char    *command = NFI_M_CHANGE_ITEM;
    static  char    *fname = "_NFIchange_item_notify";

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    if ((status = (long) FIf_get_user_pointer
        (*form, (char *) &item)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

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

            status = NFMRcancel_update_item
                ((long) 0, item->attr_list, item->data_list);

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_add (item, form);

            break;

        case FI_ACCEPT:
        case FI_EXECUTE:

            _NFFadd_validate_accept (*form, "n_update", item);

            if (item->done == FALSE)
              {
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer
                    ("attr_list", item->attr_list, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer
                    ("data_list", item->data_list, _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_CHANGE_ITEM, NULL);

            /*  Call NFMR to change the item  */

            _NFIdebug ((fname, "calling NFMRupdate_item ...\n"));
            status = NFMRupdate_item ((long) 0,
                NFFglobal.catalog, item->attr_list, item->data_list);
            _NFIdebug ((fname, "NFMRupdate_item = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            cmd_status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            if ((g_label != FI_EXECUTE) && (cmd_status == NFM_S_SUCCESS))
              {
                /*  Close all allocated buffers and delete the form  */

                _NFFfree_add (item, form);
              }
/*
            if ((g_label == FI_EXECUTE) || (cmd_status != NFM_S_SUCCESS))
              {
                _NFIdebug ((fname, "validating access for next one ...\n"));
                NFFvalidate_user_access (command);
                break;
              }
*/
            if (*form != NULL)
              {
                /*  Pop the button back up  */

                FIg_set_state_off (*form, g_label);
              }

            break;

        case INFORMATION_MCF:

            if ((status = _NFFadd_attributes_field
                (*form, row, "n_update", item)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_attributes_field = <0x%.8x>\n", status));

            break;

        case VALUE_FIELD:

            if ((status = _NFFadd_value_field
                (*form, "n_update", item)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_value_field = <0x%.8x>\n", status));

            break;

        case VALIDATE_MCF:

            if ((status = _NFFadd_validate_field
                (*form, row, "n_update", item)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_validate_field = <0x%.8x>\n", status));

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }
