#include "NFF.h"
#include "NFFcatalog.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFcreate_catalog ()
  {
    auto    long    status;
    auto    char    title[NFF_MAX_MESSAGE];
    auto    char    loc_name[40];
    static  char    *fname = "NFFcreate_catalog";

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
        ERRload_struct
            (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFadd_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    catalog->type = 0;
    catalog->done = FALSE;
    catalog->command = CREATE;
    catalog->advice_exists = FALSE;
    catalog->range_exists = FALSE;
    catalog->list_exists = FALSE;
    catalog->user_defined = FALSE;
    catalog->active_attribute = 0;
    catalog->cat_attr = NULL;
    catalog->cat_data = NULL;
    catalog->cat_value = NULL;
    catalog->cat_appl = NULL;

    catalog->loc->type = 0;
    catalog->loc->done = FALSE;
    catalog->loc->command = CREATE_CATALOG;
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

    _NFIdebug ((fname, "calling NFMRquery_addto_loc_attributes ...\n"));
    if ((status = NFMRquery_addto_loc_attributes ((long) 0, loc_name,
        &(catalog->loc->attr_list),
        &(catalog->loc->data_list),
        &(catalog->loc->value_list))) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "NFMRquery_addto_loc_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_catalog (catalog, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRquery_addto_loc_attributes\n"));

    MEMbuild_array (catalog->loc->attr_list);
    MEMbuild_array (catalog->loc->data_list);
    MEMbuild_array (catalog->loc->value_list);

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("NFFcreate_catalog: loc_attr",
            catalog->loc->attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("NFFcreate_catalog: loc_data",
            catalog->loc->data_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("NFFcreate_catalog: loc_value",
            catalog->loc->value_list, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the Create Catalog form  */

    if ((status = (long) FIf_new (CREATE_CAT_LABEL,
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
        (NFFglobal.current_form, catalog->loc, "n_write")) != NFI_S_SUCCESS)
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
        (title, NFT_P_CR_CAT, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Create Catalog");
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE1, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_catalog (catalog, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Select the first row  */

    _NFFnotify
        (CREATE_CAT_LABEL, INFORMATION_BUTTON, 0.0, NFFglobal.current_form);

    /*  Display the Create Catalog form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_catalog (catalog, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFadd_attributes_field
        (NFFglobal.current_form, 0, "n_write", catalog->loc)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_attributes_field = <0x%.8x>\n", status));
        _NFFfree_catalog (catalog, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = (long)FIg_start_seq (NFFglobal.current_form, VALUE_FIELD))
               != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_start_seq = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_start_seq", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcrcat_notify (g_label, row, form)
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
    auto    short   offset;
    auto    char    col_name[20];
    auto    char    **data_ptr;
    auto    char    buffer_string[NFM_IDENTIFIER + NFM_TABLETYPE + 2];
    auto    char    catalog_name[NFM_CATALOGNAME + 1];
    static  char    *command = NFI_M_CREATE_CATALOG;
    static  char    *fname = "_NFFcrcat_notify";

    /*  Current template name selected by the user  */

    static  char    user_template[NFM_IDENTIFIER + 1] = "";

    /*  Current template buffer queried from the database  */

    static  char    buffer_template[NFM_IDENTIFIER + 1] = "";

    /*  Pointer to the catalog structure  */

    NFFcatalog    catalog;

    /*  Flag to tell which mode the form
        is in (for display purposes only)  */

    static    short information_mode = FALSE;

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
                ERRload_struct (NFI,
                    NFI_E_HELP, "%s%d", "_NFFhelp_topic", status);
                status = NFI_E_HELP;
              }

            break;

        case FI_CANCEL:

            /*  Reinitialize the display mode variable  */

            information_mode = FALSE;

            /*  Reinitialize the catalog template variables  */

            strcpy (user_template, "");
            strcpy (buffer_template, "");

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

            if ((status = _NFFcat_validate_accept (catalog)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFcat_validate_accept = <0x%.8x>\n", status));
                FIg_set_state_off (*form, g_label);
                break;
              }

            if (catalog->done == FALSE)
              {
                FIg_set_state_off (*form, g_label);
                break;
              }

            /*  Get the "t_basic" value from the loc_data buffer;
                If the user didn't pick a template, it will use
                the default value loaded from the server - Glenn  */

            if ((status = _NFFfind_column_offset
                (catalog->loc->data_list,
                "t_basic", &offset)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_column_offset = <0x%.8x>\n", status));
                _NFIdebug ((fname, "defaulting to NFM template\n"));
                strcpy (user_template, "NFM");
                status = NFI_S_SUCCESS;
              }
            else
              {
                data_ptr = (char **) catalog->loc->data_list->data_ptr;

                /*  Data is on the first row in the data buffer  */

                if ((strcmp (data_ptr[offset], "")) == 0)
                  {
                    _NFIdebug ((fname, "defaulting to NFM template\n"));
                    strcpy (user_template, "NFM");
                  }
                else
                  {
                    _NFIdebug ((fname,
                        "using template <%s>\n", data_ptr[offset]));
                    strcpy (user_template, data_ptr[offset]);
                  }
              }

            /*  Check catalog name for "REDLINE" template  */

            if ((strcmp (user_template, "REDLINE")) == 0)
              {
                if ((status = _NFFfind_column_offset
                    (catalog->loc->data_list,
                    "n_catalogname", &offset)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFfind_column_offset = <0x%.8x>\n", status));
                    break;
                  }

                data_ptr = (char **) catalog->loc->data_list->data_ptr;
                strncpy (catalog_name, data_ptr[offset], NFM_CATALOGNAME);

                if ((strcmp
                    (&(catalog_name[strlen (catalog_name) - 3]), "_rl")) != 0)
                  {
                    _NFIdebug ((fname, "catalog name doesn't end in _rl\n"));
                    status = NFI_W_REDLINE_CATNAME;
                    ERRload_struct (NFI, status, NULL);
                    break;
                  }
              }

            /*  See if the query needs to be done  */

            if ((strcmp (user_template, buffer_template)) != 0)
              {
                /*  Free up any existing buffers  */

                MEMclose (&(catalog->cat_attr));
                MEMclose (&(catalog->cat_data));
                MEMclose (&(catalog->cat_value));
                MEMclose (&(catalog->cat_appl));

                /*  Build the "application template" buffer  */

                MEMopen (&(catalog->cat_appl), MEM_SIZE);
                MEMwrite_format (catalog->cat_appl, "type", "char(20)");
                MEMwrite_format (catalog->cat_appl, "value", "char(20)");

                /*  Put the template type in the buffer string  */

                strcpy (buffer_string, "t_basic\1");
                strcat (buffer_string, user_template);
                MEMwrite (catalog->cat_appl, buffer_string);

                /*  Put up a message  */

                NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

                _NFIdebug ((fname,
                    "calling NFMRquery_catalog_template_n ...\n"));
                if ((status = NFMRquery_catalog_template_n
                    (&(catalog->cat_attr), &(catalog->cat_data),
                    &(catalog->cat_value), catalog->cat_appl))
                    != NFM_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "NFMRquery_catalog_template_n = <0x%.8x>\n", status));
                    NFFerase_message ();
                    break;
                  }
                _NFIdebug ((fname,
                    "returned from NFMRquery_catalog_template_n\n"));

                MEMbuild_array (catalog->cat_attr);
                MEMbuild_array (catalog->cat_data);
                MEMbuild_array (catalog->cat_value);

                /*  Save the name of the buffer template  */

                strcpy (buffer_template, user_template);
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("loc_data",
                    catalog->loc->data_list, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("cat_attr",
                    catalog->cat_attr, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("cat_data",
                    catalog->cat_data, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffers("cat_value",
                    catalog->cat_value, _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_CR_CAT, NULL);

            /*  Call NFMR to create the catalog  */

            _NFIdebug ((fname, "calling NFMRcreate_catalog ...\n"));
            status = NFMRcreate_catalog ((long) 0,
                catalog->loc->attr_list, catalog->loc->data_list,
                catalog->cat_attr, catalog->cat_data, catalog->cat_value);
            _NFIdebug ((fname, "NFMRcreate_catalog = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            cmd_status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Don't set the active catalog name if it's
                a catalog created with the "REDLINE" template  */

            if ((cmd_status == NFM_S_SUCCESS) &&
                ((strcmp (user_template, "REDLINE")) != 0))
              {
                /*  Find the new active catalog name  */

                _NFFfind_active_data (catalog->loc->data_list,
                    "n_catalogname", NFFglobal.catalog);
                FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                    CATALOG_FIELD, 0, 0, NFFglobal.catalog, FALSE);

                /*  Wipe out the active item and revision  */

                strcpy (NFFglobal.item, "");
                FIg_set_text (NFFglobal.forms[MAIN_LABEL], ITEM_FIELD, "");
                _NFFalter_item_text_label ("Item Name");
                strcpy( NFFglobal.set_indicator, "" );
                strcpy (NFFglobal.revision, "");
                FIg_set_text (NFFglobal.forms[MAIN_LABEL], REVISION_FIELD, "");
              }

            if ((g_label != FI_EXECUTE) && (cmd_status == NFM_S_SUCCESS))
              {
                /*  Close all allocated buffers and delete the form  */

                _NFFfree_catalog (catalog, form);

                /*  Reinitialize the display mode variable  */

                information_mode = FALSE;

                /*  Reinitialize the catalog template variables  */

                strcpy (user_template, "");
                strcpy (buffer_template, "");
              }

/*  No need to call validate again - Glenn

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

        case INFORMATION_BUTTON:

            /*  See if any displays have to be done  */

            if (information_mode == TRUE)
                break;
            else
                information_mode = TRUE;

            /*  Set the button on  */

            if ((status = FIg_set_state_on (*form, g_label)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIg_set_state_on = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_on", status);
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
                (*form, 0, "n_write", catalog->loc);

            break;

        case ATTRIBUTES_BUTTON:

            /*  See if any displays have to be done  */

            if (information_mode == FALSE)
                break;
            else
                information_mode = FALSE;

            /*  Get the "t_basic" value from the loc_data buffer;
                If the user didn't pick a template, it will use
                the default value loaded from the server - Glenn  */

            if ((status = _NFFfind_column_offset
                (catalog->loc->data_list,
                "t_basic", &offset)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFfind_column_offset = <0x%.8x>\n", status));
                _NFIdebug ((fname, "defaulting to NFM template\n"));
                strcpy (user_template, "NFM");
                status = NFI_S_SUCCESS;
              }
            else
              {
                data_ptr = (char **) catalog->loc->data_list->data_ptr;

                /*  Data is on the first row in the data buffer  */

                if ((strcmp (data_ptr[offset], "")) == 0)
                  {
                    _NFIdebug ((fname, "defaulting to NFM template\n"));
                    strcpy (user_template, "NFM");
                  }
                else
                  {
                    _NFIdebug ((fname,
                        "using template <%s>\n", data_ptr[offset]));
                    strcpy (user_template, data_ptr[offset]);
                  }
              }

            /*  See if the query has to be done  */

            if ((strcmp (user_template, buffer_template)) != 0)
              {
                /*  Free up any existing buffers  */

                MEMclose (&(catalog->cat_attr));
                MEMclose (&(catalog->cat_data));
                MEMclose (&(catalog->cat_value));
                MEMclose (&(catalog->cat_appl));

                /*  Build the "application template" buffer  */

                MEMopen (&(catalog->cat_appl), MEM_SIZE);
                MEMwrite_format (catalog->cat_appl, "type", "char(20)");
                MEMwrite_format (catalog->cat_appl, "value", "char(20)");

                /*  Put the template type in the buffer string  */

                strcpy (buffer_string, "t_basic\1");
                strcat (buffer_string, user_template);
                MEMwrite (catalog->cat_appl, buffer_string);

                /*  Put up a message  */

                NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

                _NFIdebug ((fname,
                    "calling NFMRquery_catalog_template_n ...\n"));
                if ((status = NFMRquery_catalog_template_n
                    (&(catalog->cat_attr), &(catalog->cat_data),
                    &(catalog->cat_value), catalog->cat_appl))
                    != NFM_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "NFMRquery_catalog_template_n = <0x%.8x>\n", status));
                    NFFerase_message ();
                    break;
                  }
                _NFIdebug ((fname,
                    "returned from NFMRquery_catalog_template_n\n"));

                MEMbuild_array (catalog->cat_attr);
                MEMbuild_array (catalog->cat_data);
                MEMbuild_array (catalog->cat_value);

                if (_NFMdebug_st.NFIdebug_on)
                  {
                    MEMprint_buffer ("NFFcreate_catalog: cat_attr",
                        catalog->cat_attr, _NFMdebug_st.NFIdebug_file);
                    MEMprint_buffer ("NFFcreate_catalog: cat_data",
                        catalog->cat_data, _NFMdebug_st.NFIdebug_file);
                    MEMprint_buffers ("NFFcreate_catalog: cat_value",
                        catalog->cat_value, _NFMdebug_st.NFIdebug_file);
                  }

                /*  Erase the message  */

                NFFerase_message ();

                /*  Save the name of the buffer template  */

                strcpy (buffer_template, user_template);
              }

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
                (*form, row, "n_write", catalog->loc)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_attributes_field = <0x%.8x>\n", status));

            break;

        case VALUE_FIELD:

            if ((status = _NFFadd_value_field
                (*form, "n_write", catalog->loc)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_value_field = <0x%.8x>\n", status));

            break;

        case VALIDATE_MCF:

            if ((status = _NFFadd_validate_field
                (*form, row, "n_write", catalog->loc)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_validate_field = <0x%.8x>\n", status));

            break;

        case ATTRIBUTES_MCF:

            _NFIdebug ((fname, "Event on attributes_mcf\n"));
            if ((status = _NFFcat_attributes_mcf
                (*form, g_label, catalog, row)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_attributes_mcf = <0x%.8x>\n", status));

            break;

        case ADD_USER_DEFINED:

            _NFIdebug ((fname, "Event on add_user_defined Button\n"));
            if ((status = _NFFcat_add_user_defined
                (*form, g_label, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_add_user_defined = <0x%.8x>\n", status));

            /*  Pop the button back up  */

            FIg_set_state_off (*form, g_label);

            break;

        case DELETE_USER_DEFINED:

            _NFIdebug ((fname, "Event on delete_user_defined Button\n"));
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

            _NFIdebug ((fname, "position = <%d>\n", position));

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

            switch (g_label)
              {
                case READ_TOGGLE:
                    strcpy (col_name, "n_read");
                    break;

                case WRITE_TOGGLE:
                    strcpy (col_name, "n_write");
                    break;

                case UPDATE_TOGGLE:
                    strcpy (col_name, "n_update");
                    break;

                case DELETE_TOGGLE:
                    strcpy (col_name, "n_delete");
                    break;

                case NULLS_TOGGLE:
                    strcpy (col_name, "n_null");
                    break;
              }

            if ((status = _NFFcat_get_characteristics
                (*form, g_label, col_name, catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_get_characteristics = <0x%.8x>\n", status));

            break;

        case CHECKIN_ROLLTHRU:
            if ((status = _NFFcat_rollthru_fields (*form,
                g_label, row, "n_checkin", catalog)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFcat_rollthru_fields = <0x%.8x>\n", status));
            break;

        case CHECKOUT_ROLLTHRU:
            if ((status = _NFFcat_rollthru_fields (*form,
                g_label, row, "n_checkout", catalog)) != NFI_S_SUCCESS)
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
