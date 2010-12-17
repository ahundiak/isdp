
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFdelete_tape_labels_notify (g_label, form)
  int    g_label;
  Form   *form;
  {
    auto    long    cmd_status = NFM_S_SUCCESS;
    auto    long    status = NFI_S_SUCCESS;
    auto    MEMptr  data = NULL;
    static  char    *fname = "_NFFdelete_tape_labels_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    switch (g_label)
      {
        case NFF_HELP:

            if (status = _NFFhelp_topic (NFI_M_DELETE_TAPE_LABELS))
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));

            break;

        case NFF_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            FIf_delete (*form);
            NFFglobal.current_form = *form = NULL;

            break;

        case NFF_ACCEPT:

            /*  Build data buffer  */

            if ((status = _NFFbuild_tape_labels_buffer
                (*form, &data)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFbuild_tape_labels_buffer = <0x%.8x>\n", status));
                MEMclose (&data);

                /*  Pop the button back up  */

                FIg_set_state_off (*form, g_label);

                break;
              }

            _NFIdebug ((fname, "calling NFMRdelete_label ...\n"));
            cmd_status = NFMRdelete_label (data);
            _NFIdebug ((fname, "NFMRdelete_label = <0x%.8x>\n", cmd_status));

            MEMclose (&data);

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            if (cmd_status == NFM_S_SUCCESS)
              {
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

        case NFF_PRINT:
            status = _NFFprint_listing (TAPE_LABELS_LABEL);
            break;
      }

    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFbuild_tape_labels_buffer (form, data)
  Form    form;
  MEMptr  *data;
  {
    auto    int     i;
    auto    int     num_rows;
    auto    int     sel, rpos;
    auto    char    s[20];
    static  char    *fname = "_NFFbuild_tape_labels_buffer";

    MEMopen (data, MEM_SIZE);
    MEMwrite_format (*data, "n_label", "char(10)");

    /*  See which rows the user selected  */

    FIfld_get_num_rows (form, MCF, &num_rows);
    for (i = 0; i < num_rows; ++i)
      {
        FIfld_get_select (form, MCF, i, 0, &sel);
        if (sel == TRUE)
          {
            /*  Write the selected label name into the buffer  */

            FIfld_get_text (form, MCF, i, 0, sizeof (s), s, &sel, &rpos);
            MEMwrite (*data, s);
          }
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }

