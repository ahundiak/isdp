
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdelete_saveset_entries ()
  {
    auto    int     f_label = SAVESET_ENTRIES_LABEL;
    auto    int     t_label = NFT_P_LIST_SAVESETS;
    auto    int     columns = SAVESET_ENTRIES_COLUMNS;
    auto    char    *form_name = SAVESET_ENTRIES_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdelete_saveset_entries";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRquery_savesets_to_delete ...\n"));
    if ((status = NFMRquery_savesets_to_delete
        (&synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "NFMRquery_savesets_to_delete = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRquery_savesets_to_delete = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum (title, t_label, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "List of I/NFM Savesets");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display
        (f_label, form_name, columns, title, data, FALSE)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    _NFFcenter_form (NFFglobal.current_form, -1, Y_FORM_POS);

    /*  Put a pointer to this buffer in the form  */

    FIf_set_user_pointer (NFFglobal.current_form, (char *) data);

    /*  Put a prompt on the form  */

    status = NFI_P_CHOOSE_SAVESETS;
    ERRload_struct (NFI, status, NULL);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", status));
    return (status);
  }


long _NFFdelete_saveset_entries_notify (g_label, form)
  int    g_label;
  Form   *form;
  {
    auto    long    cmd_status = NFM_S_SUCCESS;
    auto    long    status = NFI_S_SUCCESS;
    auto    MEMptr  old_buffer = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "_NFFdelete_saveset_entries_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    FIf_get_user_pointer (*form, &old_buffer);

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (NFI_M_CLEAR_SAVESET))
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));

            break;

        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            MEMclose (&old_buffer);
            FIf_delete (*form);
            NFFglobal.current_form = *form = NULL;

            break;

        case FI_ACCEPT:

            /*  Build data buffer  */

            if ((status = _NFFbuild_savesets_buffer
                (*form, old_buffer, &data)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFbuild_savesets_buffer = <0x%.8x>\n", status));
                MEMclose (&data);

                /*  Pop the button back up  */

                FIg_set_state_off (*form, g_label);

                break;
              }

            _NFIdebug ((fname, "calling NFMRdelete_savesets ...\n"));
            cmd_status = NFMRdelete_savesets (data);
            _NFIdebug ((fname,
                "NFMRdelete_savesets = <0x%.8x>\n", cmd_status));

            MEMclose (&data);

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            if (cmd_status == NFM_S_SUCCESS)
              {
                MEMclose (&old_buffer);
                FIf_delete (*form);
                NFFglobal.current_form = *form = NULL;
              }
            else
              {
                /*  Pop the button back up  */

                FIg_set_state_off (*form, g_label);
                status = cmd_status;
              }

            break;
      }

    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFbuild_savesets_buffer (form, old_buffer, new_buffer)
  Form    form;
  MEMptr  old_buffer;
  MEMptr  *new_buffer;
  {
    auto    int     row, col, sel;
    auto    long    status;
    auto    char    s[80];
    auto    char    **column, **format, **data;
    static  char    *fname = "_NFFbuild_savesets_buffer";

    MEMopen (new_buffer, MEM_SIZE);

    MEMbuild_array (old_buffer);
    column = (char **) old_buffer->column_ptr;
    format = (char **) old_buffer->format_ptr;
    data = (char **) old_buffer->data_ptr;

    /*  Copy the old_buffer's columns  */

    strcpy (s, "");
    for (col = 0; col < old_buffer->columns; ++col)
      {
        MEMwrite_format (*new_buffer, column[col], format[col]);

        /*  Build an empty string for the new buffer  */

        strcat (s, "\1");
      }

    for (row = 0; row < old_buffer->rows; ++row)
      {
        FIfld_get_select (form, MCF, row, 0, &sel);
        if (sel == TRUE)
          {
            /*  Write an empty string into the buffer  */

            MEMwrite (*new_buffer, s);
            MEMbuild_array (*new_buffer);

            /*  Copy the data from the old buffer into the new one  */

            for (col = 0; col < (*new_buffer)->columns; ++col)
              {
                MEMwrite_data (*new_buffer,
                    data[(row * old_buffer->columns) + col],
                    (*new_buffer)->rows, col + 1);
              }
          }
      }

    if ((*new_buffer)->rows == 0)
      {
        _NFIdebug ((fname, "no rows were selected\n"));
        status = NFI_W_NO_ENTRIES_TO_DELETE;
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, "returning FAILURE <0x%.8x>\n", status));
        return (status);
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }
