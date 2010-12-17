
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFconfirm.h"

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdelete_copied_files ()
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFdelete_copied_files";

    /*  Load in the Confirm form  */

    if ((status = (long) FIf_new (DELETE_COPIED_FILES_LABEL,
        CONFIRM_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning <0x%.8x>\n", status));
        return (status);
      }

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CONFIRM_DELETE, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to delete");
      }

    if ((status = (long) UMSGetByNum
        (prompt2, NFT_P_CONFIRM_FILES, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt2, "the indicated file(s) ?");
      }

    FIg_set_text (NFFglobal.current_form, FIRST_LINE, prompt1);
    FIg_set_text (NFFglobal.current_form, COMMAND_INFO, prompt2);

    if ((status = _NFFadjust_confirm_form
        (NFFglobal.current_form)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadjust_confirm_form = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = (long) FIf_display
        (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFdelete_copied_files_notify (g_label, form)
  int    g_label;
  Form   *form;
  {
    auto    long    status = NFI_S_SUCCESS;
    auto    MEMptr  buffer = NULL;
    static  char    *fname = "_NFFdelete_copied_files_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    switch (g_label)
      {
        case FI_CANCEL:
        case CANCEL_BUTTON:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            FIf_delete (*form);
            NFFglobal.current_form = *form = NULL;

            break;

        case FI_ACCEPT:
        case OK_BUTTON:

            /*  Build the data buffer  */

            if ((status = _NFFdelete_copied_files (&buffer)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFdelete_copied_files = <0x%.8x>\n", status));
                FIf_delete (*form);
                NFFglobal.current_form = *form = NULL;
                break;
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_DELETE_CP_FILES, NULL);

            /*  Delete the selected files  */

            _NFIdebug ((fname, "calling NFMRdelete_copied_files ...\n"));
            status = NFMRdelete_copied_files
                (NFFglobal.working_area, buffer);
            MEMclose (&buffer);
            _NFIdebug ((fname,
                "NFMRdelete_copied_files = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            FIf_delete (*form);
            NFFglobal.current_form = *form = NULL;

            break;
      }

    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFdelete_copied_files (buffer)
  MEMptr    *buffer;
  {
    auto    int     i, pos;
    auto    int     sel, rpos;
    auto    int     row, num_rows;
    auto    long    status;
    auto    char    datatype[20];
    auto    Form    form = NULL;
    auto    char    *row_of_data = NULL;
    static  char    *fname = "_NFFdelete_copied_files";

    /*  Columns to get data from in the MCF  */

    static  int     cols[5] = { 1, 2, 3, 0, 4 };

    /*  The size of those columns  */

    static  int     chars[5] = { NFM_CATALOGNAME,
                                 NFM_ITEMNAME,
                                 NFM_ITEMREV,
                                 NFM_FILENAME,
                                 NFM_FILEVERSION };

    _NFIdebug ((fname, "entering ...\n"));

    /*  Build the data buffer  */

    if ((status = MEMopen (buffer, MEM_SIZE)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    sprintf (datatype, "char(%d)", NFM_CATALOGNAME);
    if ((status = MEMwrite_format
        (*buffer, "n_catalogname", datatype)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (buffer);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    sprintf (datatype, "char(%d)", NFM_ITEMNAME);
    if ((status = MEMwrite_format
        (*buffer, "n_itemname", datatype)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (buffer);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    sprintf (datatype, "char(%d)", NFM_ITEMREV);
    if ((status = MEMwrite_format
        (*buffer, "n_itemrev", datatype)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (buffer);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    sprintf (datatype, "char(%d)", NFM_FILENAME);
    if ((status = MEMwrite_format
        (*buffer, "n_filename", datatype)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (buffer);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMwrite_format
        (*buffer, "n_fileversion", "integer")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (buffer);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Allocate space for a row of data in the buffer  */

    if ((row_of_data = (char *) malloc ((*buffer)->row_size + 6)) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", (*buffer)->row_size + 6));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", (*buffer)->row_size + 6);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    strcpy (row_of_data, "");

    /*  Loop thru the local files list, building the buffer  */

    form = NFFglobal.forms[LOCAL_FILES_LABEL];

    FIfld_get_num_rows (form, MCF, &num_rows);
    for (row = 0; row < num_rows; ++row)
      {
        FImcf_get_select (form, MCF, row, &sel);
        if (sel == TRUE)
          {
            /*  Write the data into the buffer  */

            for (i = 0; i < 5; ++i)
              {
                pos = strlen (row_of_data);
                FIfld_get_text (form, MCF, row, cols[i],
                    chars[i], &row_of_data[pos], &sel, &rpos);
                strcat (row_of_data, "\1");
                _NFIdebug ((fname, "row_of_data = <%s>\n", row_of_data));
              }

            if ((status = MEMwrite (*buffer, row_of_data)) != MEM_S_SUCCESS)
              {
                _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
                MEMclose (buffer);
                if (row_of_data) free (row_of_data);
                ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
                _NFIdebug ((fname, "returning FAILURE\n"));
                return (NFI_E_MEM);
              }

            strcpy (row_of_data, "");
          }
      }

    if (row_of_data) free (row_of_data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }
