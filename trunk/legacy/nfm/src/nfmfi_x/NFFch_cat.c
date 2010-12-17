
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFcatalog.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFchange_catalog (catalog_name)
  char    *catalog_name;
  {
    auto    long    status;
    auto    char    title[NFF_MAX_MESSAGE];
    auto    char    loc_name[40];
    static  char    *fname = "NFFchange_catalog";

    /*  Pointer to the catalog structure  */

    auto    NFFcatalog    catalog;

    /*  Initialize the catalog structure  */

    if ((catalog = (NFFcatalog) malloc
        (sizeof (struct NFFcatalog_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFcatalog_st)));
        ERRload_struct
            (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFcatalog_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if ((catalog->loc = (NFFadd_ptr) malloc
        (sizeof (struct NFFadd_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFadd_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFadd_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    catalog->done = FALSE;
    catalog->command = CHANGE;
    catalog->advice_exists = FALSE;
    catalog->range_exists = FALSE;
    catalog->list_exists = FALSE;
    catalog->user_defined = FALSE;
    catalog->active_attribute = 0;
    catalog->cat_attr = NULL;
    catalog->cat_data = NULL;
    catalog->cat_value = NULL;
    catalog->cat_appl = NULL;

    catalog->loc->done = FALSE;
    catalog->loc->command = CHANGE_CATALOG;
    catalog->loc->rows = NULL;
    catalog->loc->active_attribute = -1;
    catalog->loc->validate_row = -1;
    catalog->loc->attr_list = NULL;
    catalog->loc->data_list = NULL;
    catalog->loc->value_list = NULL;
    strcpy (catalog->loc->entity, "");

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    strcpy (loc_name, "");

    _NFIdebug ((fname, "calling NFMRquery_changeto_loc_attributes ...\n"));
    if ((status = NFMRquery_changeto_loc_attributes
        ((long) 0, loc_name, catalog_name,
        &(catalog->loc->attr_list), &(catalog->loc->data_list),
        &(catalog->loc->value_list))) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "NFMRquery_changeto_loc_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, NULL);
        _NFIdebug ((fname, " returning <%d>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRquery_changeto_loc_attributes\n"));

    /*  Prepare the buffers for reading  */

    if ((status = MEMbuild_array (catalog->loc->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning <%d>\n", NFI_E_MEM));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (catalog->loc->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning <%d>\n", NFI_E_MEM));
        return (NFI_E_MEM);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("NFFchange_catalog: loc_attr",
            catalog->loc->attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("NFFchange_catalog: loc_data",
            catalog->loc->data_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("NFFchange_catalog: loc_value",
            catalog->loc->value_list, _NFMdebug_st.NFIdebug_file);
      }

    _NFIdebug ((fname, "calling NFMRquery_change_catalog_attributes ...\n"));
    if ((status = NFMRquery_change_catalog_attributes
        ((long) 0, catalog_name, &(catalog->cat_attr),
        &(catalog->cat_data), &(catalog->cat_value))) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "NFMRquery_change_catalog_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRquery_change_catalog_attributes\n"));

    /*  Prepare the buffers for reading  */

    if ((status = MEMbuild_array (catalog->cat_attr)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (catalog->cat_data)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("NFFchange_catalog: cat_attr",
            catalog->cat_attr, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("NFFchange_catalog: cat_data",
            catalog->cat_data, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("NFFchange_catalog: cat_value",
            catalog->cat_value, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the Create Catalog form  */

    if ((status = (long) FIf_new (CHANGE_CAT_LABEL,
        CATALOG_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, NULL);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load in the LOC attributes into the INFORMATION_MCF  */

    if ((status = _NFFadd_load_attributes
        (NFFglobal.current_form, catalog->loc, "n_update")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_load_attributes = %d\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) catalog)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, &NFFglobal.current_form);
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
        _NFFfree_catalog (catalog, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_catalog (catalog, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    if ((status = (long) UMSGetByNum
        (title, NFT_P_CHANGE_CAT, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Change Catalog");
      }

    FIg_set_text (NFFglobal.current_form, TITLE1, title);
    sprintf (title, "\"%s\"", catalog_name);
    FIg_set_text (NFFglobal.current_form, TITLE2, title);
    FIg_display (NFFglobal.current_form, TITLE2);

    /*  Select the first row  */

    _NFFnotify
        (CHANGE_CAT_LABEL, INFORMATION_BUTTON, 0.0, NFFglobal.current_form);

    /*  Display the Change Catalog form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_catalog (catalog, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Make sure the cursor is positioned  */

    if ((status = _NFFadd_attributes_field (NFFglobal.current_form,
        0, "n_update", catalog->loc)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_attributes_field = <0x%.8x>\n", status));
        _NFFfree_catalog (catalog, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFchcat_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
/*
    auto    int     next_row;
    auto    int     position;
    auto    int     num_vis_rows;
*/
    auto    long    status = NFI_S_SUCCESS;
    auto    long    cmd_status = NFM_S_SUCCESS;
    auto    char    col_name[20];
    auto    short   new_attr;
    static  char    *command = NFI_M_CHANGE_CATALOG;
    static  char    *fname = "_NFFchcat_notify";

    /*  Pointer to the catalog structure  */

    NFFcatalog    catalog;

    /*  Flag to tell which mode the form
        is in (for display purposes only)  */

    static  short   information_mode = FALSE;

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    if ((status = (long) FIf_get_user_pointer (*form, &catalog)) != FI_SUCCESS)
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

            /*  Reinitialize the display mode variable  */

            information_mode = FALSE;

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_catalog (catalog, form);

            break;

        case FI_ACCEPT:
        case FI_EXECUTE:

            status = _NFFcat_validate_accept (catalog);

            if (catalog->done == FALSE)
              {
                /*  Reset the button  */

                FIg_reset (*form, g_label);

                break;
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("loc_data", catalog->loc->data_list,
                    _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("cat_attr", catalog->cat_attr,
                    _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("cat_data", catalog->cat_data,
                    _NFMdebug_st.NFIdebug_file);
                MEMprint_buffers("cat_value", catalog->cat_value,
                    _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_CHANGE_CAT, NULL);

            /*  Call NFMR to change the catalog  */

            _NFIdebug ((fname, "calling NFMRchange_catalog ...\n"));
            status = NFMRchange_catalog ((long) 0,
                catalog->loc->attr_list, catalog->loc->data_list,
                catalog->cat_attr, catalog->cat_data, catalog->cat_value);
            _NFIdebug ((fname, "NFMRchange_catalog = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            if (cmd_status == NFM_S_SUCCESS)
              {
                /*  Find the new active catalog name  */

                _NFFfind_active_data (catalog->loc->data_list,
                    "n_catalogname", NFFglobal.catalog);
                FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                    CATALOG_FIELD, 0, 0, NFFglobal.catalog, FALSE);
              }

            if ((g_label != FI_EXECUTE) && (cmd_status == NFM_S_SUCCESS))
              {
                /*  Close all allocated buffers and delete the form  */

                _NFFfree_catalog (catalog, form);

                /*  Reinitialize the display mode variable  */

                information_mode = FALSE;
              }
/*
            if ((g_label == FI_EXECUTE) || (cmd_status != NFM_S_SUCCESS))
              {
                _NFIdebug ((fname, "validating access for next one ...\n"));
                NFFvalidate_user_access (command);
                break;
              }
*/                        
/*
            if ((g_label == FI_EXECUTE) && (cmd_status == NFM_S_SUCCESS))
              {
                _NFIdebug ((fname, "fixing data for another change...\n"));
                _NFFcat_update_buffer (catalog);
              }
*/
            if (*form != NULL)
              {
                /*  Pop the button back up  */

                FIg_set_state_off (*form, g_label);
              }

            break;

        case INFORMATION_BUTTON:

            /*  See if any displays have to be done  */

            if (information_mode == TRUE)
                break;
            else
                information_mode = TRUE;

            /*  Set the button on  */

            if ((status = FIg_set_state_on (*form, g_label)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_set_state_on = <0x%.8x>\n", status));
                status = NFI_E_FORM;
                break;
              }

            /*  Erase the "attributes" button's gadgets  */

            if ((status = _NFFcat_attributes_gadgets
                (*form, ERASE)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_attributes_gadgets = <0x%.8x>\n", status));
                break;
              }

            /*  Display the "information" button's gadgets  */

            if ((status = _NFFcat_information_gadgets
                (*form, DISPLAY)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_information_gadgets = <0x%.8x>\n", status));
                break;
              }

            /*  Select the first row  */

            status = _NFFadd_attributes_field
                (*form, 0, "n_update", catalog->loc);

            break;

        case ATTRIBUTES_BUTTON:

            /*  See if any displays have to be done  */

            if (information_mode == FALSE)
                break;
            else
                information_mode = FALSE;

            /*  Set the button on  */

            if ((status = FIg_set_state_on (*form, g_label)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_set_state_on = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_on", status);
                status = NFI_E_FORM;
                break;
              }

            if ((status = _NFFcat_load_catalog_attributes
                (*form, ATTRIBUTES_MCF, catalog)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_load_catalog_attributes = <0x%.8x>\n", status));
                break;
              }

            /*  Erase the "information" button's gadgets  */

            if ((status = _NFFcat_information_gadgets
                (*form, ERASE)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_information_gadgets = <0x%.8x>\n", status));
                break;
              }

            /*  Display the "attributes" button's gadgets  */

            if ((status = _NFFcat_attributes_gadgets
                (*form, DISPLAY)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_attributes_gadgets = <0x%.8x>\n", status));
                break;
              }

            /*  Select the first row  */

            if ((status = (long) FImcf_set_select
                (*form, ATTRIBUTES_MCF, 0, TRUE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                status = NFI_E_FORM;
                break;
              }

            if ((status = _NFFcat_attributes_mcf
                (*form, ATTRIBUTES_MCF, catalog, 0)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_attributes_mcf = <0x%.8x>\n", status));

            break;

        case INFORMATION_MCF:

            if ((status = _NFFadd_attributes_field
                (*form, row, "n_update", catalog->loc)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_attributes_field = <0x%.8x>\n", status));

            break;

        case VALUE_FIELD:

            if ((status = _NFFadd_value_field
                (*form, "n_update", catalog->loc)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_value_field = <0x%.8x>\n", status));

            break;

        case VALIDATE_MCF:

            if ((status = _NFFadd_validate_field (*form,
                row, "n_update", catalog->loc)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_validate_field = <0x%.8x>\n", status));

            break;

        case ATTRIBUTES_MCF:

            if ((status = _NFFcat_attributes_mcf
                (*form, g_label, catalog, row)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_attributes_mcf = <0x%.8x>\n", status));

            break;

        case ADD_USER_DEFINED:

            if ((status = _NFFcat_add_user_defined
                (*form, g_label, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_add_user_defined = <0x%.8x>\n", status));

            /*  Pop the button back up  */

            FIg_set_state_off (*form, g_label);

            break;

        case DELETE_USER_DEFINED:

            if ((status = _NFFcat_delete_user_defined
                (*form, g_label, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_delete_user_defined = <0x%.8x>\n", status));

            /*  Pop the button back up  */

            FIg_set_state_off (*form, g_label);

            break;

        case ORDER_FIELD:

            if ((status = _NFFcat_keyin_field
                (*form, g_label, catalog, 0)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_keyin_field = <0x%.8x>\n", status));

            break;

        case ATTRIBUTE_FIELD:

            if ((status = _NFFcat_keyin_field
                (*form, g_label, catalog, 1)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_keyin_field = <0x%.8x>\n", status));

            break;

        case DATATYPE_FIELD:

            if ((status = _NFFcat_keyin_field
                (*form, g_label, catalog, 2)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_keyin_field = <0x%.8x>\n", status));

            break;

        case SYNONYM_FIELD:

            if ((status = _NFFcat_keyin_field
                (*form, g_label, catalog, 3)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_keyin_field = <0x%.8x>\n", status));

            break;

        case DEFAULT_FIELD:

            if ((status = _NFFcat_default_field
                (*form, g_label, catalog)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_default_field = <0x%.8x>\n", status));
                break;
              }

            /*  Auto select the next attribute  */

/*  Disabled - Glenn Scott 3/2/92

            if (catalog->active_attribute + 1 > (catalog->cat_attr)->rows - 1)
                next_row = 0;
            else
                next_row = catalog->active_attribute + 1;

            if ((status = (long) FImcf_set_select
                (*form, ATTRIBUTES_MCF, next_row, TRUE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                status = NFI_E_FORM;
                break;
              }

            if ((status = (long) FIfld_get_num_vis_rows
                (*form, ATTRIBUTES_MCF, &num_vis_rows)) != FI_SUCCESS)
              {
                _NFIdebug ((fname,
                    "FIfld_get_num_vis_rows = <%d>\n", status));
                ERRload_struct (NFI,
                    NFI_E_FORM, "%s%d", "FIfld_get_num_vis_rows", status);
                status = NFI_E_FORM;
                break;
              }
*/
            /*  If the next row is out of the viewing area,
                set it to be at the bottom of the viewing area  */

/*  Disabled - Glenn Scott 3/2/92

            if (next_row >= num_vis_rows)
                position = num_vis_rows - 1;
            else
                position = next_row;

            _NFIdebug ((fname, "position = <0x%.8x>\n", position));

            if ((status = (long) FIfld_set_active_row
                (*form, ATTRIBUTES_MCF, next_row, position)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_active_row = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_row", status);
                status = NFI_E_FORM;
                break;
              }

            if ((status = (long) FImcf_set_select
                (*form, ATTRIBUTES_MCF, next_row, TRUE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                status = NFI_E_FORM;
                break;
              }

            if ((status = _NFFcat_attributes_mcf
                (*form, ATTRIBUTES_MCF, catalog, next_row)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_attributes_mcf = <0x%.8x>\n", status));
*/
            break;

        case READ_TOGGLE:
        case WRITE_TOGGLE:
        case UPDATE_TOGGLE:
        case DELETE_TOGGLE:
        case NULLS_TOGGLE:

            /*  Find out if this is a new attribute or not  */

            if ((status = _NFFcat_attr_new_or_old (catalog,
                catalog->active_attribute, &new_attr)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_attr_new_or_old = <0x%.8x>\n", status));
                break;
              }

            switch (g_label)
              {
                case READ_TOGGLE:

                    if (new_attr == TRUE)
                        strcpy (col_name, "n_read");
                    else
                        strcpy (col_name, "new_n_read");

                    break;

                case WRITE_TOGGLE:

                    if (new_attr == TRUE)
                        strcpy (col_name, "n_write");
                    else
                        strcpy (col_name, "new_n_write");

                    break;

                case UPDATE_TOGGLE:

                    if (new_attr == TRUE)
                        strcpy (col_name, "n_update");
                    else
                        strcpy (col_name, "new_n_update");

                    break;

                case DELETE_TOGGLE:

                    if (new_attr == TRUE)
                        strcpy (col_name, "n_delete");
                    else
                        strcpy (col_name, "new_n_delete");

                    break;

                case NULLS_TOGGLE:

                    if (new_attr == TRUE)
                        strcpy (col_name, "n_null");
                    else
                        strcpy (col_name, "new_n_null");

                    break;
              }

            if ((status = _NFFcat_get_characteristics
                (*form, g_label, col_name, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_get_characteristics = <0x%.8x>\n", status));

            break;

        case CHECKIN_ROLLTHRU:

            /*  Find out if this is a new attribute or not  */

            if ((status = _NFFcat_attr_new_or_old (catalog,
                catalog->active_attribute, &new_attr)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_attr_new_or_old = <0x%.8x>\n", status));
                break;
              }

            if (new_attr == TRUE)
                strcpy (col_name, "n_checkin");
            else
                strcpy (col_name, "new_n_checkin");

            if ((status = _NFFcat_rollthru_fields (*form,
                g_label, row, col_name, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_rollthru_fields = <0x%.8x>\n", status));

            break;

        case CHECKOUT_ROLLTHRU:

            /*  Find out if this is a new attribute or not  */

            if ((status = _NFFcat_attr_new_or_old (catalog,
                catalog->active_attribute, &new_attr)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_attr_new_or_old = <0x%.8x>\n", status));
                break;
              }

            if (new_attr == TRUE)
                strcpy (col_name, "n_checkout");
            else
                strcpy (col_name, "new_n_checkout");

            if ((status = _NFFcat_rollthru_fields (*form,
                g_label, row, col_name, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_rollthru_fields = <0x%.8x>\n", status));

            break;

        case ADVISE_BUTTON:

            if ((status = _NFFcat_advice_button (*form)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_advice_button = <0x%.8x>\n", status));

            break;

        case ADVISORY_FIELD:

            if ((status = _NFFcat_advice_field
                (*form, g_label, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_advice_field = <0x%.8x>\n", status));

            break;

        case VALIDATE_BUTTON:

            if ((status = _NFFcat_validate_button
                (*form, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_validate_button = <0x%.8x>\n", status));

            break;

        case VALIDATE_TOGGLE:

            if ((status = _NFFcat_validate_toggle
                (*form, row)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_validate_toggle = <0x%.8x>\n", status));

            break;

        case INFO_MIN_FIELD:

            if ((status = _NFFcat_min_field
                (*form, g_label, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "_NFFcat_min_field = <0x%.8x>\n", status));

            break;

        case INFO_MAX_FIELD:

            if ((status = _NFFcat_max_field
                (*form, g_label, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "_NFFcat_max_field = <0x%.8x>\n", status));

            break;

        case VALIDATE_LIST_FIELD:

            if ((status = _NFFcat_list_field
                (*form, g_label, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "_NFFcat_list_field = <0x%.8x>\n", status));

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


void _NFFcat_update_buffer (catalog)
  NFFcatalog    catalog;
  {
    auto    int     row, col;
    auto    int     num_cols;
    auto    int     num_rows;
    auto    long    status;
    auto    char    **data;
    auto    char    new_col[40];

    static  char    cols[12][40] = {
        "n_seqno", "n_name", "n_datatype", "n_read",
        "n_write", "n_update", "n_delete", "n_null",
        "n_checkin", "n_checkout", "n_valueno", "n_advice" };

    static  short   offset[12] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    static  short   new_offset[12] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    static  char    *fname = "_NFFcat_update_buffer";

    /*  This function will fix the catalog attribute buffer by
        copying the data that was just added (for user-defined
        attributes) into the "new_" parts of the buffer.  This
        is so that the server will not think that the attribute
        is a new attribute anymore, and will not try to add it
        into the catalog and nfmattributes table.  5/21/92 Glenn.  */

    data = (char **) catalog->cat_attr->data_ptr;
    num_cols = catalog->cat_attr->columns;
    num_rows = catalog->cat_attr->rows;

    /*  Get all of the buffer offsets first  */

    for (col = 0; col < 12; ++col)
      {
        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, cols[col], &(offset[col]))) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning ...\n"));
            return;
          }

        sprintf (new_col, "new_%s", cols[col]);

        if ((status = _NFFfind_column_offset
            (catalog->cat_attr, new_col, &(new_offset[col]))) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFfind_column_offset = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning ...\n"));
            return;
          }
      }

    for (row = 0; row < num_rows; ++row)
      {
        /*  Find a row that has a new attribute in it (use "new_n_name")  */

        if ((strcmp (data[(row * num_cols) + new_offset[1]], "")) != 0)
            continue;

        for (col = 0; col < 12; ++col)
          {
            _NFIdebug ((fname,
                "writing <%s> into row %d, col %d in attribute buffer\n",
                data[(row * num_cols) + offset[col]],
                row + 1, new_offset[col] + 1));

            if ((status = MEMwrite_data
                (catalog->cat_attr, data[(row * num_cols) + offset[col]],
                row + 1, new_offset[col] + 1)) != MEM_S_SUCCESS)
              {
                _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
                ERRload_struct (NFI,
                    NFI_E_MEM, "%s%x", "MEMwrite_data", status);
                _NFIdebug ((fname, " returning ...\n"));
                return;
              }
          }
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("cat_attr after updating",
            catalog->cat_attr, _NFMdebug_st.NFIdebug_file);
      }

    _NFIdebug ((fname, "returning ...\n"));
    return;
  }
