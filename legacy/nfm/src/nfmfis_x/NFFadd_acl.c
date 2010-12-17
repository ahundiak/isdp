
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFadd_acl ()
  {
    auto    long    status;
    auto    char    s[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFadd_acl";

    /*  Pointer to the acl structure  */

    NFFadd_ptr    acl;

    /*  Initialize the acl structure  */

    if ((acl = (NFFadd_ptr) malloc
        (sizeof (struct NFFadd_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFadd_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFadd_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    acl->done = FALSE;
    acl->active_attribute = -1;
    acl->validate_row = -1;
    acl->attr_list = NULL;
    acl->data_list = NULL;
    acl->value_list = NULL;

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    _NFIdebug ((fname, "calling NFMRquery_acl_attributes ...\n"));
    if ((status = NFMRquery_acl_attributes
        ((long) 0, &(acl->attr_list),
        &(acl->data_list), &(acl->value_list))) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRquery_acl_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRquery_acl_attributes\n"));

    if ((status = MEMbuild_array (acl->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array (acl->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array (acl->value_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list",
            acl->attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list",
            acl->data_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("value_list",
            acl->value_list, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the Add form  */

    if ((status = (long) FIf_new (ADD_ACL_LABEL,
        ADD_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the data in the attributes field  */

    if ((status = _NFFadd_load_attributes
        (NFFglobal.current_form, acl, "n_write")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_load_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) acl)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, &NFFglobal.current_form);
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
        _NFFfree_add (acl, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Center the validate mcf and text on the form  */

    if ((status = _NFFcenter_gadget
        (NFFglobal.current_form, VALIDATE_TEXT)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    if ((status = (long) UMSGetByNum
        (s, NFT_P_ADD_ACL, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "Add Access Control List");
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE, s)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /* disable the FI_EXECUTE button due to the additional forms for the
       Add Class Users, and Add signof users will be chained together.  */

    FIg_disable (NFFglobal.current_form, FI_EXECUTE); 

    /*  Select the first row  */

    if ((status = (long) FImcf_set_select
        (NFFglobal.current_form, INFORMATION_MCF, 0, TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFFadd_attributes_field (NFFglobal.current_form, 0, "n_write", acl);

    /*  Display the Add form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
/*
    if ((status = (long)FIg_start_seq (NFFglobal.current_form, VALUE_FIELD))
	       != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_start_seq = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_start_seq", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
*/
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_acl_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    long    status = NFI_S_SUCCESS;
    static  char    *command = NFI_M_DEFINE_ACL;
    static  char    *fname = "_NFFadd_acl_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFadd_ptr    acl;

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    FIf_get_user_pointer (*form, &acl);

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

            _NFFfree_add (acl, form);

            break;

        case FI_ACCEPT:

            status = _NFFadd_validate_accept (*form, "n_write", acl);

            if (acl->done == FALSE)
              {
                /*  Reset the accept button  */

                FIg_reset (*form, FI_ACCEPT);
                break;
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("attr_list",
                    acl->attr_list, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("data_list",
                    acl->data_list, _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_ADD_ACL, NULL);

            /*  Call NFMR to add the acl  */

            _NFIdebug ((fname, "calling NFMRadd_acl ...\n"));
            status = NFMRadd_acl ((long) 0, acl->attr_list, acl->data_list);
            _NFIdebug ((fname, "NFMRadd_acl = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_add (acl, form);

            if (NFFglobal.status == NFM_S_SUCCESS)
              {
                /*  Add users to the newly created ACL  */

                if ((status = NFFadd_acl_class_users
                    (1, NFFglobal.acl)) != NFI_S_SUCCESS)
                    _NFIdebug ((fname,
                        "NFFadd_acl_class_users = <0x%.8x>\n", status));
              }

            break;

        case INFORMATION_MCF:

            if ((status = _NFFadd_attributes_field
                (*form, row, "n_write", acl)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_attributes_field = <0x%.8x>\n", status));
            break;

        case VALUE_FIELD:

            if ((status = _NFFadd_value_field
                (*form, "n_write", acl)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                   "_NFFadd_value_field = <0x%.8x>\n", status));
            break;

        case VALIDATE_MCF:

            if ((status = _NFFadd_validate_field
                (*form, row, "n_write", acl)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_validate_field = <0x%.8x>\n", status));
            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }
