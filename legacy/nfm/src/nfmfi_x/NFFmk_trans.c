
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmk_trans.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFmake_transition ()
  {
    auto    long         status;
    auto    char         s[256];
    auto    NFFmk_trans  trans;
    static  char         *fname = "NFFmake_transition";

    /*  Initialize the trans structure  */

    if ((trans = (NFFmk_trans) malloc
        (sizeof (struct NFFmk_trans_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFmk_trans_st)));
        ERRload_struct
            (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFmk_trans_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    trans->done = FALSE;
    trans->attr_list = NULL;
    trans->data_list = NULL;

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    if ((status = (long) NFMRquery_make_transition
        ((long) 0, &(trans->attr_list),
        &(trans->data_list))) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRquery_make_transition = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_make_trans (trans, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array (trans->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_make_trans (trans, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (trans->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_make_trans (trans, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer
            ("attr_list", trans->attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer
            ("data_list", trans->data_list, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the form  */

    if ((status = (long) FIf_new (MK_TRANS_LABEL,
        MKTRANS_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_make_trans (trans, NULL);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the title of the form  */

    if ((status = (long) UMSGetByNum
        (s, NFT_P_MK_TRANS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "Make Transition for");
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE1, s)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_make_trans (trans, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = (long) UMSGetByNum (s, NFT_P_ITEM_REV,
        "%s%s", NFFglobal.item, NFFglobal.revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (s,
            "Item \"%s\" Revision \"%s\"", NFFglobal.item, NFFglobal.revision);
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE2, s)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_make_trans (trans, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the data in the attributes field  */

    if ((status = _NFFmk_trans_load_states
        (NFFglobal.current_form, trans)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFmk_trans_load_states = %d\n", status));
        NFFerase_message ();
        _NFFfree_make_trans (trans, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) trans)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_make_trans (trans, &NFFglobal.current_form);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Erase the message  */

    NFFerase_message ();

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_make_trans (trans, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Display the form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_make_trans (trans, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmk_trans_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    long    status = NFI_S_SUCCESS;

    /*  Pointer to structure to store the MEM pointers in  */

    auto    NFFmk_trans    trans;

    static  char    *command = NFI_M_MAKE_ITEM_TRANSITION;
    static  char    *fname = "_NFFmk_trans_notify";

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    FIf_get_user_pointer (*form, &trans);

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

            _NFFfree_make_trans (trans, form);

            break;

        case FI_ACCEPT:

            status = _NFFmk_trans_validate_accept (*form, trans);

            if (trans->done == FALSE)
              {
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("attr_list",
                    trans->attr_list, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("data_list",
                    trans->data_list, _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_MK_TRANS, NULL);

            /*  Call NFMR to make the transition  */

            _NFIdebug ((fname, "calling NFMRmake_transition ...\n"));
            status = NFMRmake_transition
                ((long) 0, trans->attr_list, trans->data_list);
            _NFIdebug ((fname, "NFMRmake_transition = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_make_trans (trans, form);

            break;

        case NEXT_STATE:

            if ((status = _NFFmk_trans_next_state
                (*form, trans)) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "_NFFmk_trans_next_state = <0x%.8x>\n"));

            break;

        case POSSIBLE_STATES:

            if ((status = _NFFmk_trans_possible_states
                (*form, row)) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "_NFFmk_trans_next_state = <0x%.8x>\n"));

            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFmk_trans_load_states (form, trans)
  Form           form;
  NFFmk_trans    trans;
  {
    auto    int     i, row;
    auto    int     fields;
    auto    int     second_row;
    auto    long    status;
    auto    char    **data_ptr;
    auto    short   name_offset;
    auto    short   status_offset;
    static  char    *fname = "_NFFmk_trans_load_states";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Find the state name offset in the buffer  */

    if ((status = _NFFfind_column_offset
        (trans->data_list, "n_statename", &name_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (trans->data_list, "n_status", &status_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (trans->data_list)->data_ptr;

    /*  Verify that the first row contains the current state  */

    if (((strncmp (data_ptr[status_offset], "current", 7)) != 0) &&
        ((strncmp (data_ptr[status_offset], "CURRENT", 7)) != 0))
      {
        _NFIdebug ((fname, "Current state is not in the first row\n"));
        ERRload_struct (NFI, NFI_E_BUFFER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_BUFFER);
      }

    /*  Put the current state in CURRENT_STATE  */
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX)/* || defined(OS_INTELSOL) */
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, CURRENT_STATE, "7x13bold", 15 );
    FIg_set_font( form, POSSIBLE_STATES, "7x13bold", 15 );
#endif

    FIfld_set_text (form, CURRENT_STATE, 0, 0, data_ptr[name_offset], FALSE);

    /*  Load the possible next states into POSSIBLE_STATES  */

    row = 0;
    second_row = (trans->data_list)->columns;
    fields = (trans->data_list)->rows * (trans->data_list)->columns;
    for (i = second_row; i < fields; i += (trans->data_list)->columns, ++row)
      {
        /*  Verify that the buffer contains the possible next states  */

        if (((strcmp (data_ptr[i + status_offset], "current")) == 0) ||
            ((strcmp (data_ptr[i + status_offset], "CURRENT")) == 0))
          {
            _NFIdebug ((fname, "Too many current states given\n"));
            ERRload_struct (NFI, NFI_E_BUFFER, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_BUFFER);
          }

        FIfld_set_text
            (form, POSSIBLE_STATES, row, 0, data_ptr[i + name_offset], FALSE);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmk_trans_next_state (form, trans)
  Form           form;
  NFFmk_trans    trans;
  {
    auto    int     i;
    auto    int     length;
    auto    int     selected;
    auto    int     pos;
    auto    int     fields;
    auto    long    status;
    auto    char    *text;
    auto    char    **data_ptr;
    auto    short   found = FALSE;
    auto    short   name_offset;
    auto    int     label = NEXT_STATE;
    static  char    *fname = "_NFFmk_trans_next_state";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Find the length of the text  */

    FIfld_get_text_length (form, label, 0, 0, &length);
    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    FIfld_get_text (form, label, 0, 0, length, text, &selected, &pos);

    /*  Validate what the user keyed in against the list  */

    if ((status = _NFFfind_column_offset
        (trans->data_list, "n_statename", &name_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (trans->data_list)->data_ptr;

    fields = (trans->data_list)->rows * (trans->data_list)->columns;
    for (i = 0; i < fields; i += (trans->data_list)->columns)
      {
        if ((strcmp (data_ptr[i + name_offset], text)) == 0)
          {
            found = TRUE;
            break;
          }
      }

    if (found == FALSE)
      {
        _NFIdebug ((fname,
            "State <%s> is not a valid possible next state\n", text));
        ERRload_struct (NFI, NFI_E_STATE, "%s", text);

        /*  Clear out NEXT_STATE  */

        FIfld_set_text (form, label, 0, 0, "", FALSE);
      }

    if (text) free (text);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmk_trans_possible_states (form, row)
  Form           form;
  int            row;
  {
    auto    int     length;
    auto    int     selected;
    auto    int     pos;
    auto    char    *text;
    auto    int     label = POSSIBLE_STATES;
    static  char    *fname = "_NFFmk_trans_possible_states";

    _NFIdebug ((fname, "row = %d\n", row));

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX)/* || defined(OS_INTELSOL) */
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, NEXT_STATE, "7x13bold", 15 );
#endif

    FIfld_get_select (form, label, row, 0, &selected);
    if (selected == FALSE)
      {
        _NFIdebug ((fname, "User unselected row %d\n", row));
        FIfld_set_text (form, NEXT_STATE, 0, 0, "", FALSE);
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    /*  Find the length of the text  */

    FIfld_get_text_length (form, label, row, 0, &length);
    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    FIfld_get_text (form, label, row, 0, length, text, &selected, &pos);

    /*  Put the selected row in NEXT_STATE  */

    FIfld_set_text (form, NEXT_STATE, 0, 0, text, FALSE);

    if (text) free (text);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFmk_trans_validate_accept (form, trans)
  Form           form;
  NFFmk_trans    trans;
  {
    auto    int     i;
    auto    int     row;
    auto    int     length;
    auto    int     selected;
    auto    int     pos;
    auto    int     fields;
    auto    long    status;
    auto    char    *text;
    auto    char    **data_ptr;
    auto    short   found = FALSE;
    auto    short   name_offset;
    auto    short   status_offset;
    auto    int     label = NEXT_STATE;
    static  char    *fname = "_NFFmk_trans_validate_accept";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Make sure there is something in NEXT_STATE  */

    /*  Find the length of the text  */

    FIfld_get_text_length (form, label, 0, 0, &length);

    if (length == 0)
      {
        _NFIdebug ((fname, "No next state given\n"));
        ERRload_struct (NFI, NFI_E_NULL_STATE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NULL_STATE);
      }

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    FIfld_get_text (form, label, 0, 0, length, text, &selected, &pos);

    if ((strcmp (text, "")) == 0)
      {
        _NFIdebug ((fname, "No next state given\n"));
        if (text) free (text);
        ERRload_struct (NFI, NFI_E_NULL_STATE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NULL_STATE);
      }

    /*  Put the next state in the data_list  */

    if ((status = _NFFfind_column_offset
        (trans->data_list, "n_statename", &name_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        if (text) free (text);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (trans->data_list, "n_status", &status_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        if (text) free (text);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    data_ptr = (char **) (trans->data_list)->data_ptr;

    row = 1;
    fields = (trans->data_list)->rows * (trans->data_list)->columns;
    for (i = 0; i < fields; i += (trans->data_list)->columns, ++row)
      {
        if ((strcmp (data_ptr[i + name_offset], text)) == 0)
          {
            if ((status = MEMwrite_data (trans->data_list,
                "NEXT", row, status_offset + 1)) != MEM_S_SUCCESS)
              {
                _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
                if (text) free (text);
                ERRload_struct
                    (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
              }

            found = TRUE;
            break;
          }
      }

    if (text) free (text);

    if (found == FALSE)
      {
        _NFIdebug ((fname, "No next state given\n"));
        ERRload_struct (NFI, NFI_E_NULL_STATE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NULL_STATE);
      }

    trans->done = TRUE;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _NFFfree_make_trans (trans, form)
  NFFmk_trans    trans;
  Form           *form;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    MEMclose (&(trans->attr_list));
    MEMclose (&(trans->data_list));

    if (trans) free (trans);

    return;
  }
