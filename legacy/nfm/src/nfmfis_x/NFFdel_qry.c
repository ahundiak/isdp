
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFconfirm.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdelete_sort_criteria (sort_name)
  char    *sort_name;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFdelete_sort_criteria";

    _NFIdebug ((fname, "sort_name = <%s>\n", sort_name));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CONFIRM_DELETE, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to delete");
      }

    if ((status = (long) UMSGetByNum
        (prompt2, NFT_P_CONFIRM_SORT, "%s", sort_name)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt2, "Sort Criteria \"%s\" ?", sort_name);
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_DELETE_SORT;

    if ((status = _NFFconfirm (DELETE_SORT_LABEL, TRUE,
        sort_name, "", "", prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long NFFdelete_search_criteria (search_name)
  char    *search_name;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFdelete_search_criteria";

    _NFIdebug ((fname, "search_name = <%s>\n", search_name));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CONFIRM_DELETE, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to delete");
      }

    if ((status = (long) UMSGetByNum
        (prompt2, NFT_P_CONFIRM_SEARCH, "%s", search_name)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt2, "Search Criteria \"%s\" ?", search_name);
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_DELETE_SEARCH;

    if ((status = _NFFconfirm (DELETE_SEARCH_LABEL, TRUE,
        search_name, "", "", prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFdelete_query_notify (f_label, g_label, form)
  int       f_label;
  int       g_label;
  Form      *form;
  {
    auto    long              status = NFI_S_SUCCESS;
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

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFFglobal.working_no, NULL);

            /*  Delete the criteria  */

            _NFIdebug ((fname, "calling NFMRdelete_query ...\n"));
            status = NFMRdelete_query (ptr->entity1);
            _NFIdebug ((fname, "NFMRdelete_query = <0x%.8x>\n", status));

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
                /*  Wipe out the appropriate fields  */

                switch (f_label)
                  {
                    case DELETE_SORT_LABEL:
                        strcpy (NFFglobal.sort, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SORT_FIELD, 0, 0, NFFglobal.sort, FALSE);
                        FIg_set_state_off
                            (NFFglobal.forms[MAIN_LABEL], SORT_TOGGLE);
                        NFFglobal.sort_active = FALSE;
                        break;

                    case DELETE_SEARCH_LABEL:
                        strcpy (NFFglobal.search, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SEARCH_FIELD, 0, 0, NFFglobal.search, FALSE);
                        FIg_set_state_off
                            (NFFglobal.forms[MAIN_LABEL], SEARCH_TOGGLE);
                        NFFglobal.search_active = FALSE;
                        break;
                  }
              }

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }
