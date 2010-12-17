
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFconfirm.h"
#include "WFcommands.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

struct  NFMwf_info NFFwf_info;
struct  NFMoperation NFFoperation;

long NFFcancel_set_checkout (display_flag, catalog, item_name, revision)
  int     display_flag;
  char    *catalog;
  char    *item_name;
  char    *revision;
  {
    auto    long    status;
    char    command [NFM_COMMANDNAME + 1];
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFcancel_set_checkout";

    _NFIdebug ((fname, "catalog   = <%s>\n", catalog));
    _NFIdebug ((fname, "item_name = <%s>\n", item_name));
    _NFIdebug ((fname, "revision  = <%s>\n", revision));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CANCEL_CHECK_OUT, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want cancel check out on");
      }

    if ((status = (long) UMSGetByNum (prompt2, NFT_P_CONFIRM_SET_REV, "%s%s",
                                      item_name, revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt2, "Set \"%s\" Revision \"%s\" ?", item_name, revision);
      }

    /*  Set the working message and the NFMR function */

    NFFglobal.working_no = NFI_I_CANCEL_SET_CHECK_OUT;
    NFFglobal.NFMRfunction[0] = NFMRcancel_check_out_set;
    strcpy (command, CANCEL_SET_CHECKOUT);

    if ((status = _NFFcancel_set_checkout (CANCEL_CO_CONFIRM_LABEL,
                                 display_flag, command, catalog, item_name, 
                                 revision, prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcancel_set_checkout = <0x%.8x>\n",
                    status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcancel_set_checkout
(f_label, display_flag, command, entity1, entity2, entity3, prompt1, prompt2)
  int    f_label;
  int    display_flag;
  char   *command;
  char   *entity1;
  char   *entity2;
  char   *entity3;
  char   *prompt1;
  char   *prompt2;
  {
    auto    long              status;
    auto    NFFconfirm_ptr    ptr;
    static  char              *fname = "_NFFcancel_set_checkout";

    _NFIdebug ((fname, "command = <%s>\n", command));
    _NFIdebug ((fname, "entity1 = <%s>\n", entity1));
    _NFIdebug ((fname, "entity2 = <%s>\n", entity2));
    _NFIdebug ((fname, "entity3 = <%s>\n", entity3));
    _NFIdebug ((fname, "prompt1 = <%s>\n", prompt1));
    _NFIdebug ((fname, "prompt2 = <%s>\n", prompt2));

    /* set up the NFFwf_info structure */

    NFFwf_info.workflow = NFM_WORKFLOW;
    strcpy (NFFwf_info.command, command);
    strcpy (NFFwf_info.workflow_name, "");
    strcpy (NFFwf_info.project_name, "");
    strcpy (NFFwf_info.app_name, "");

    /* set up the NFFoperation structure */

    NFFoperation.transfer = NFM_CONDITIONAL_TRANSFER;
    NFFoperation.delete   = NFM_CONDITIONAL_DELETE;
    NFFoperation.purge    = NFM_PURGE;
    strcpy (NFFoperation.catalog, entity1);
    NFFoperation.catalog_no  = (long) 0;
    strcpy (NFFoperation.item_name, entity2);
    strcpy (NFFoperation.item_rev, entity3);

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


long _NFFcancel_set_checkout_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    auto    long              status = NFI_S_SUCCESS;
    auto    NFFconfirm_ptr    ptr = NULL;
    static  char              *fname = "_NFFcancel_set_checkout_notify";

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

            _NFFfree_confirm (ptr, form);

            break;

        case FI_ACCEPT:
        case OK_BUTTON:

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFFglobal.working_no, NULL);

            /*  Call NFMR to do the command  */

            _NFIdebug ((fname, "calling NFMR function ...\n"));
            status = NFFglobal.NFMRfunction[0] (ptr->entity1, (long) 0,
                            ptr->entity2, ptr->entity3, (long) 0, NFFwf_info,
                            NFM_SAME_OPERATION, &NFFoperation, (long) 0);
            _NFIdebug ((fname, "NFMR function = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            _NFFfree_confirm (ptr, form);

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

