
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFconfirm.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFgeneric_confirm_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    auto    long              status = NFI_S_SUCCESS;
    auto    NFFconfirm_ptr    ptr = NULL;
    static  char              *fname = "_NFFgeneric_confirm_notify";

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
            status = NFFglobal.NFMRfunction[0] (ptr->entity1, ptr->entity2,
                                                ptr->entity3);
            _NFIdebug ((fname, "NFMR function = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            _NFFfree_confirm (ptr, form);

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

