
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFdelete_mapping (title1, title2, entity)
  char      *title1;
  char      *title2;
  NFFmap    entity;
  {
    auto    long    status;
    static  char    *fname = "_NFFdelete_mapping";

    /*  Load in the form  */

    if ((status = (long) FIf_new (DELETE_MAPPING_LABEL, MAPPING_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        _NFFfree_map (entity, NULL);
        NFFset_to_state ();
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Create the mcf from the value_list  */

    if ((status = _NFFmap_load_value_list
        (NFFglobal.current_form, entity, FALSE)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFmap_load_value_list = <0x%.8x>\n", status));
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


long _NFFdelete_map_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    long    status = NFI_S_SUCCESS;
    auto    char    command[15];
    static  char    *fname = "_NFFdelete_map_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFmap    entity;

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    FIf_get_user_pointer (*form, &entity);

    switch (g_label)
      {
        case FI_HELP:

            switch (entity->command)
              {
                case DELETE_CATALOG_ACL_MAP:
                    strcpy (command, NFI_M_DELETE_CATALOG_ACL_MAPPING);
                    break;

                case DELETE_CATALOG_SA_MAP:
                    strcpy (command, NFI_M_DELETE_CATALOG_SA_MAPPING);
                    break;

                case DELETE_PROJECT_ACL_MAP:
                    strcpy (command, NFI_M_DELETE_PROJECT_ACL_MAPPING);
                    break;

                case DELETE_PROJECT_SA_MAP:
                    strcpy (command, NFI_M_DELETE_PROJECT_SA_MAPPING);
                    break;

                case DELETE_ACL_CLASS_USERS:
                    strcpy (command, NFI_M_DELETE_ACL_CLASS_USERS);
                    break;

                case DELETE_ACL_SIGNOFF_USERS:
                    strcpy (command, NFI_M_DELETE_ACL_SIGNOFF_USERS);
                    break;
              }

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

            if ((status = _NFFmap_load_data_list (*form, entity->data_list,
                (int) entity->validate_row, "DROP")) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFmap_load_data_list = <0x%.8x>\n", status));
                FIg_reset (*form, FI_ACCEPT);
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

            /*  Call NFMR to update the mapping  */

            status = (long) NFFglobal.NFMRfunction[1]
                ((long) 0, entity->attr_list, entity->data_list);

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            if (status != NFM_S_SUCCESS)
                _NFIdebug ((fname,
                    "NFMR update map function = <0x%.8x>\n", status));

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_map (entity, form);

            break;

        case BOTTOM_MCF:
            status = _NFFmap_bottom_mcf (*form, g_label, row);
            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }
