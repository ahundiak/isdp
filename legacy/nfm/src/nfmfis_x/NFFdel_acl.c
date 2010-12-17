
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmain_form.h"
#include "NFFconfirm.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdelete_acl (workflow, acl_name)
  char    *workflow;
  char    *acl_name;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFdelete_acl";

    _NFIdebug ((fname, "workflow = <%s>\n", workflow));
    _NFIdebug ((fname, "acl_name = <%s>\n", acl_name));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CONFIRM_DELETE, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to delete");
      }

    if ((status = (long) UMSGetByNum
        (prompt2, NFT_P_CONFIRM_ACL, "%s", acl_name)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt2, "Access Control List \"%s\" ?", acl_name);
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_DELETE_ACL;

    /*  Set the NFMR function  */

    NFFglobal.NFMRfunction[0] = NFMRdelete_acl;

    if ((status = _NFFconfirm (DELETE_ACL_CONFIRM_LABEL, TRUE,
        workflow, acl_name, "", prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFconfirm_acl_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    auto    long              status = NFI_S_SUCCESS;
    auto    NFFconfirm_ptr    ptr = NULL;
    static  char              *fname = "_NFFconfirm_acl_notify";

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

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFFglobal.working_no, NULL);

            /*  Call NFMR to do the command  */

            _NFIdebug ((fname, "calling NFMR function ...\n"));
            status = NFFglobal.NFMRfunction[0] (ptr->entity1, ptr->entity2);
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
                 /* erase the deleted acl_name from the main form and global
                    structure.                                              */

                 FIfld_set_text (NFFglobal.forms[MAIN_LABEL], ACL_FIELD, 0, 0,
                                 "", FALSE);
                 strcpy (NFFglobal.acl, "");
             }

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

