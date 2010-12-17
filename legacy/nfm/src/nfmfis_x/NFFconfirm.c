
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFconfirm.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFconfirm
(f_label, display_flag, entity1, entity2, entity3, prompt1, prompt2)
  int    f_label;
  int    display_flag;
  char   *entity1;
  char   *entity2;
  char   *entity3;
  char   *prompt1;
  char   *prompt2;
  {
    auto    long              status;
    auto    NFFconfirm_ptr    ptr;
    static  char              *fname = "_NFFconfirm";

    _NFIdebug ((fname, "entity1 = <%s>\n", entity1));
    _NFIdebug ((fname, "entity2 = <%s>\n", entity2));
    _NFIdebug ((fname, "entity3 = <%s>\n", entity3));
    _NFIdebug ((fname, "prompt1 = <%s>\n", prompt1));
    _NFIdebug ((fname, "prompt2 = <%s>\n", prompt2));

    /*  Initialize the structure  */

    if ((ptr = (NFFconfirm_ptr) malloc
        (sizeof (struct NFFconfirm_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFconfirm_st)));
        ERRload_struct
            (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFconfirm_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    strncpy (ptr->entity1, entity1, sizeof (ptr->entity1) - 1);
    strncpy (ptr->entity2, entity2, sizeof (ptr->entity2) - 1);
    strncpy (ptr->entity3, entity3, sizeof (ptr->entity3) - 1);

    /*  Load in the Confirm form  */

    if ((status = (long) FIf_new (f_label, CONFIRM_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        _NFFfree_confirm (ptr, NULL);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        _NFFfree_confirm (ptr, &NFFglobal.current_form);
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
        _NFFfree_confirm (ptr, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning <0x%.8x>\n", status));
        return (status);
      }

    /*  Put the command information on the form  */

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, FIRST_LINE, prompt1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_confirm (ptr, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, COMMAND_INFO, prompt2)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_confirm (ptr, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFadjust_confirm_form
        (NFFglobal.current_form)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadjust_confirm_form = <0x%.8x>\n", status));
        _NFFfree_confirm (ptr, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Display the Confirm form  */

    if (display_flag == TRUE)
      {
        if ((status = (long) FIf_display
            (NFFglobal.current_form)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_display = <%d>\n", status));
            _NFFfree_confirm (ptr, &NFFglobal.current_form);
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFconfirm_notify (f_label, g_label, form)
  int       f_label;
  int       g_label;
  Form      *form;
  {
    auto    long              status = NFI_S_SUCCESS;
    auto    long              item_no;
    auto    NFFconfirm_ptr    ptr = NULL;
    static  char              *fname = "_NFFconfirm_notify";

    _NFIdebug ((fname, "f_label = <%d>\n", f_label));
    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    /*  Pull out the pointer to the data  */

    if ((status = (long) FIf_get_user_pointer
        (*form, (char *) &ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
        return (NFI_E_FORM);
      }

    switch (g_label)
      {
        case FI_CANCEL:
        case CANCEL_BUTTON:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            _NFFfree_confirm (ptr, form);

            break;

        case FI_ACCEPT:
        case OK_BUTTON:

            if (NFFglobal.NFMRfunction[0] == NULL)
              {
                _NFIdebug ((fname, "function pointer is NULL\n"));
                FIg_reset (*form, g_label);
                break;
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFFglobal.working_no, NULL);

            /*  Call NFMR to do the command  */

            _NFIdebug ((fname, "calling NFMR function ...\n"));
            status = NFFglobal.NFMRfunction[0] ((long) 0,
                ptr->entity1, ptr->entity2, ptr->entity3, &item_no);
            _NFIdebug ((fname, "NFMR function = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            _NFFfree_confirm (ptr, form);

            if (NFFglobal.status == NFM_S_SUCCESS)
              {
                /*  See if any fields need to be wiped out  */

                switch (f_label)
                  {
                    case DELETE_SA_LABEL:
                        if ((strcmp (NFFglobal.storage_area,
                            NFFglobal.working_area)) == 0)
                          {
                            strcpy (NFFglobal.working_area, "");
                            FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                                WA_FIELD, 0, 0, NFFglobal.working_area, FALSE);
                          }

                        strcpy (NFFglobal.storage_area, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SA_FIELD, 0, 0, NFFglobal.storage_area, FALSE);
                        break;

                    case DELETE_CAT_LABEL:
                        strcpy (NFFglobal.catalog, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            CATALOG_FIELD, 0, 0, NFFglobal.catalog, FALSE);
                        break;

                    case DELETE_NODE_LABEL:
                        strcpy (NFFglobal.node, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            NODE_FIELD, 0, 0, NFFglobal.node, FALSE);
                        break;

                    case DELETE_PROJECT_LABEL:
                        strcpy (NFFglobal.project, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            PROJECT_FIELD, 0, 0, NFFglobal.project, FALSE);
                        FIg_set_state_off
                            (NFFglobal.forms[MAIN_LABEL], PROJECT_TOGGLE);
                        break;

                    case DELETE_USER_LABEL:
                        strcpy (NFFglobal.user, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            USER_FIELD, 0, 0, NFFglobal.user, FALSE);
                        break;

                    case DELETE_CONFIRM_LABEL:

                        /*  This is for 'Delete Item'  */

/*
                        strcpy (NFFglobal.item, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ITEM_FIELD, 0, 0, NFFglobal.item, FALSE);

                        strcpy (NFFglobal.revision, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            REVISION_FIELD, 0, 0, NFFglobal.revision, FALSE);
*/
                        break;
                  }
              }

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


void _NFFfree_confirm (ptr, form)
  NFFconfirm_ptr    ptr;
  Form              *form;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (ptr) free (ptr);
    return;
  }
