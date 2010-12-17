
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmain_form.h"
#include "NFFvalidate.h"

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdisplay_tape_labels ()
  {
    auto    int     f_label = TAPE_LABELS_LABEL;
    auto    int     t_label = NFT_P_LIST_TAPE_LABELS;
    auto    int     columns = TAPE_LABELS_COLUMNS;
    auto    char    *form_name = TAPE_LABELS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_tape_labels";

    /*  Need to use this hard-coded search criteria  */

    static  char    *search = "n_label NOT IN \
('DISK_A','DISK_B','DISK_C','DISK_O','DISK_F','DISK_J')";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_labels ...\n"));
    if ((status = NFMRdisplay_labels
        (search, "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_labels = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_labels = <0x%.8x>\n", status));

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
        strcpy (title, "List of Tape Labels");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display
        (f_label, form_name, columns, title, data, -1)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        FIf_delete (NFFglobal.current_form);
        NFFglobal.current_form = NULL;
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Display the form  */

    FIf_display (NFFglobal.current_form);

    /*  Tell the user what to do  */

    status = NFI_P_CHOOSE_LABELS;
    ERRload_struct (NFI, status, NULL);

    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
    return (status);
  }


long NFFdisplay_items_on_tape (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = ITEMS_TAPE_LABEL;
    auto    int     t_label = NFT_P_LIST_ITEMS_ON_TAPE;
    auto    int     columns = ITEMS_TAPE_COLUMNS;
    auto    char    *form_name = ITEMS_TAPE_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_items_on_tape";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_items_on_tape ...\n"));
    if ((status = NFMRdisplay_items_on_tape
        ("", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_items_on_tape = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_items_on_tape = <0x%.8x>\n", status));

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
        strcpy (title, "List of Items on Tape");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_savesets (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = SAVESETS_LABEL;
    auto    int     t_label = NFT_P_LIST_SAVESETS;
    auto    int     columns = SAVESETS_COLUMNS;
    auto    char    *form_name = SAVESETS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_savesets";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_savesets ...\n"));
    if ((status = NFMRdisplay_savesets
        ("", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_savesets = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_savesets = <0x%.8x>\n", status));

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

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_archives (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = LIST_ARCHIVES_LABEL;
    auto    int     t_label = NFT_P_LIST_ARCHIVES;
    auto    int     columns = LIST_ARCHIVES_COLUMNS;
    auto    char    *form_name = LIST_ARCHIVES_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_archives";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_archives ...\n"));
    if ((status = NFMRdisplay_archives
        ("", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_archives = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_archives = <0x%.8x>\n", status));

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
        strcpy (title, "List of I/NFM Archives");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFwhere_used_project (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = WHERE_PROJECT_LABEL;
    auto    int     t_label = NFT_P_LIST_WHERE_PRJ;
    auto    int     columns = WHERE_PROJECT_COLUMNS;
    auto    char    *form_name = WHERE_PROJECT_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFwhere_used_project";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_where_used_project ...\n"));
    if ((status = NFMRdisplay_where_used_project
        (NFFglobal.catalog, NFFglobal.item,
        NFFglobal.revision, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "NFMRdisplay_where_used_project = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_where_used_project = <0x%.8x>\n", status));

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
        strcpy (title, "Where Item Used in Projects");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFwhere_used_set (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = WHERE_SET_LABEL;
    auto    int     t_label = NFT_P_LIST_WHERE_SET;
    auto    int     columns = WHERE_SET_COLUMNS;
    auto    char    *form_name = WHERE_SET_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFwhere_used_set";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_where_used_set ...\n"));
    if ((status = NFMRdisplay_where_used_set
        (NFFglobal.catalog, NFFglobal.item,
        NFFglobal.revision, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "NFMRdisplay_where_used_set = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_where_used_set = <0x%.8x>\n", status));

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
        strcpy (title, "Where Item Used in Sets");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_item_signoffs (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = ITEM_SIGNOFF_LABEL;
    auto    int     t_label = NFT_P_LIST_SO_ON_ITEM;
    auto    int     columns = ITEM_SIGNOFF_COLUMNS;
    auto    char    *form_name = ITEM_SIGNOFF_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_item_signoffs";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_so_on_item ...\n"));
    if ((status = NFMRdisplay_so_on_item (NFFglobal.catalog, NFFglobal.item,
        NFFglobal.revision, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_so_on_item = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_so_on_item = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum (title, t_label,
        "%s%s", NFFglobal.item, NFFglobal.revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "List of Item Signoffs");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_signoff_history (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = SIGNOFF_HISTORY_LABEL;
    auto    int     t_label = NFT_P_LIST_SO_HISTORY;
    auto    int     columns = SIGNOFF_HISTORY_COLUMNS;
    auto    char    *form_name = SIGNOFF_HISTORY_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_signoff_history";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_so_history ...\n"));
    if ((status = NFMRdisplay_so_history (NFFglobal.catalog, NFFglobal.item,
        NFFglobal.revision, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_so_history = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_so_history = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum (title, t_label,
        "%s%s", NFFglobal.item, NFFglobal.revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Signoff History");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_local_files (locate_flag)
  int       locate_flag;
  {
    auto    int     mode;
    auto    long    status;
    auto    char    title[256];
    auto    char    owner[NFM_USERNAME + 1];
    auto    char    sort[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_local_files";

    /*  Sort the data for "Delete Copied Files"  */

    strcpy (sort, "nfmsafiles.n_catalogno, nfmsafiles.n_itemno, \
nfmsafiles.n_filename, nfmsafiles.n_fileversion");

    /*  Get the data from the database  */

    NFFform_message (LOCAL_FILES_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_local_files ...\n"));
    if ((status = NFMRdisplay_local_files
        (NFFglobal.working_area, "", sort, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_local_files = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);

        /*  Cleanup the display since this command's output is
            used primarily as the input for "Delete Copied Files"  */

        if (NFFglobal.forms[LOCAL_FILES_LABEL] != NULL)
            FIfld_set_num_rows (NFFglobal.forms[LOCAL_FILES_LABEL], MCF, 0);

        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_local_files = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load the form (if it's not already loaded)  */

    if (NFFglobal.forms[LOCAL_FILES_LABEL] == NULL)
      {
        if ((status = FIf_new (LOCAL_FILES_LABEL, LOCAL_FILES_FORM,
            &_NFFnotify, &NFFglobal.forms[LOCAL_FILES_LABEL])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Erase any existing data  */

        FIfld_set_num_rows (NFFglobal.forms[LOCAL_FILES_LABEL], MCF, 0);
      }

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum
        (title, NFT_P_LIST_FILES, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "List of Local Files");
      }

    FIg_set_text (NFFglobal.forms[LOCAL_FILES_LABEL], LISTING_TITLE, title);

    /*  Set the mode based upon ownership (admin has all privilege)  */

    mode = FI_MULTI_SELECT;

    if (NFMRglobal.administrator == FALSE)
      {
        /*  Find out who owns this working area  */

        if ((status = _NFFvalid_wa
            (NFFglobal.working_area, owner)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFvalid_wa = <0x%.8x>\n", status));
            _NFIdebug ((fname,
                "cannot validate the owner of this working area\n"));
            _NFIdebug ((fname, "assuming PUBLIC (it was already active)\n"));
            strcpy (owner, "PUBLIC");
          }

        /*  It's okay if it's a public working area  */

        if (((strcmp (owner, "PUBLIC")) != 0) &&
           ((strcmp (NFFglobal.username, owner)) != 0))
          {
            _NFIdebug ((fname, "owner of working area is %s; user is %s\n",
                owner, NFFglobal.username));
            _NFIdebug ((fname, "setting mode to FI_REVIEW\n"));
            mode = FI_REVIEW;
          }
      }

    if ((status = _NFFlist_load_mcf
        (NFFglobal.forms[LOCAL_FILES_LABEL],
        mode, synonyms, data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_load_mcf = <0x%.8x>\n", status));
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (NFFglobal.forms[LOCAL_FILES_LABEL], MCF, FALSE);

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (LOCAL_FILES_LABEL);

    /*  Display the form  */

    FIf_display (NFFglobal.forms[LOCAL_FILES_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_nodes (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = NODES_LABEL;
    auto    int     t_label = NFT_P_LIST_NODES;
    auto    int     columns = NODES_COLUMNS;
    auto    char    *form_name = NODES_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_nodes";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_nodes ...\n"));
    if ((status = NFMRdisplay_nodes
        ("", "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_nodes = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_nodes = <0x%.8x>\n", status));

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
        strcpy (title, "List of I/NFM Nodes");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_storage_areas (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = STORAGE_AREAS_LABEL;
    auto    int     t_label = NFT_P_LIST_SA;
    auto    int     columns = STORAGE_AREAS_COLUMNS;
    auto    char    *form_name = STORAGE_AREAS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_storage_areas";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_storage_areas ...\n"));
    if ((status = NFMRdisplay_storage_areas
        ("", "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_storage_areas = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_storage_areas = <0x%.8x>\n", status));

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
        strcpy (title, "List of I/NFM Storage Areas");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_working_areas_admin (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = WORKING_AREAS_LABEL_ADMIN;
    auto    int     t_label = NFT_P_LIST_WA;
    auto    int     columns = WORKING_AREAS_COLUMNS;
    auto    char    *form_name = WORKING_AREAS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_working_areas_admin";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_working_areas ...\n"));
    if ((status = NFMRdisplay_working_areas
        ("", "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_working_areas = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_working_areas = <0x%.8x>\n", status));

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
        strcpy (title, "List of I/NFM Working Areas");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_working_areas_user (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = WORKING_AREAS_LABEL_USER;
    auto    int     t_label = NFT_P_LIST_WA;
    auto    int     columns = WORKING_AREAS_COLUMNS;
    auto    char    *form_name = WORKING_AREAS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    char    search[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_working_areas_user";

    /*  Make sure the user only sees working areas
        that either he owns or that are owned by PUBLIC  */

    sprintf (search, "n_owner IN (SELECT n_userno FROM nfmusers\
        WHERE n_username = '%s' OR n_username = 'PUBLIC')",
        NFFglobal.username);

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_working_areas ...\n"));
    if ((status = NFMRdisplay_working_areas
        (search, "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_working_areas = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_working_areas = <0x%.8x>\n", status));

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
        strcpy (title, "List of I/NFM Working Areas");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_users (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = USERS_LABEL;
    auto    int     t_label = NFT_P_LIST_USERS;
    auto    int     columns = USERS_COLUMNS;
    auto    char    *form_name = USERS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_users";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_users ...\n"));
    if ((status = NFMRdisplay_users
        ("", "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_users = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_users = <0x%.8x>\n", status));

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
        strcpy (title, "List of I/NFM Users");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_catalogs (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = CATALOGS_LABEL;
    auto    int     t_label = NFT_P_LIST_CATALOGS;
    auto    int     columns = CATALOGS_COLUMNS;
    auto    char    *form_name = CATALOGS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_catalogs";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_catalogs ...\n"));
    if ((status = NFMRdisplay_catalogs
        ("nfmcatalogs.n_catalogname NOT LIKE '%_rl'", "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_catalogs = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_catalogs = <0x%.8x>\n", status));

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
        strcpy (title, "List of I/NFM Catalogs");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_workflows (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = WORKFLOWS_LABEL;
    auto    int     t_label = NFT_P_LIST_WF;
    auto    int     columns = WORKFLOWS_COLUMNS;
    auto    char    *form_name = WORKFLOWS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_workflows";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_workflows ...\n"));
    if ((status = NFMRdisplay_workflows
        ("", "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_workflows = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_workflows = <0x%.8x>\n", status));

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
        strcpy (title, "List of I/NFM Workflows");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_acls (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = ACLS_LABEL;
    auto    int     t_label = NFT_P_LIST_ACL;
    auto    int     columns = ACLS_COLUMNS;
    auto    char    *form_name = ACLS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_acls";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_acls ...\n"));
    if ((status = NFMRdisplay_acls
        (NFFglobal.workflow, "", "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_acls = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_acls = <0x%.8x>\n", status));
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
        strcpy (title, "List of ACLs");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_aclusers (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = ACLUSERS_LABEL;
    auto    int     t_label = NFT_P_LIST_ACL_CLASS_USERS;
    auto    int     columns = ACLUSERS_COLUMNS;
    auto    char    *form_name = ACLUSERS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_aclusers";

    /*  Make sure there is active data  */

    if ((status = _NFFvalidate_active_data
	(NFF_WORKFLOW | NFF_ACL)) != NFI_S_SUCCESS)
       {
	 _NFIdebug ((fname,
	     "_NFFvalidate_active_data = <0x%.8x>\n", status));
         return (status);
       }

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_aclusers ...\n"));
    if ((status = NFMRdisplay_aclusers
        (NFFglobal.acl, "", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_aclusers = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_aclusers = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum
        (title, t_label, "%s", NFFglobal.acl)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title, "List of Class Users in ACL \"%s\"", NFFglobal.acl);
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_signoff_users (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = SIGNOFFUSERS_LABEL;
    auto    int     t_label = NFT_P_LIST_ACL_SO_USERS;
    auto    int     columns = SIGNOFFUSERS_COLUMNS;
    auto    char    *form_name = SIGNOFFUSERS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_signoff_users";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_signoff_users ...\n"));
    if ((status = NFMRdisplay_signoff_users
        (NFFglobal.acl, "", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_signoff_users = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_signoff_users = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum
        (title, t_label, "%s", NFFglobal.acl)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title, "List of Signoff Users\nin ACL \"%s\"", NFFglobal.acl);
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_projects (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = PROJECTS_LABEL;
    auto    int     t_label = NFT_P_LIST_PROJECTS;
    auto    int     columns = PROJECTS_COLUMNS;
    auto    char    *form_name = PROJECTS_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_projects";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_projects ...\n"));
    if ((status = NFMRdisplay_projects
        ("", "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_projects = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_projects = <0x%.8x>\n", status));

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
        strcpy (title, "List of I/NFM Projects");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_catalog_acl_mapping (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = CATALOGACL_LABEL;
    auto    int     t_label = NFT_P_LIST_CAT_ACL_MAP;
    auto    int     columns = CATALOGACL_COLUMNS;
    auto    char    *form_name = CATALOGACL_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_catalog_acl_mapping";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_catalog_acl_mapping ...\n"));
    if ((status = NFMRdisplay_catalog_acl_mapping
        (NFFglobal.catalog, "", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
             "NFMRdisplay_catalog_acl_mapping = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname,
        "NFMRdisplay_catalog_acl_mapping = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum
        (title, t_label, "%s", NFFglobal.catalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "List of Catalog ACL Mappings");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_catalog_sa_mapping (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = CATALOGSA_LABEL;
    auto    int     t_label = NFT_P_LIST_CAT_SA_MAP;
    auto    int     columns = CATALOGSA_COLUMNS;
    auto    char    *form_name = CATALOGSA_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_catalog_sa_mapping";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_catalog_sa_mapping ...\n"));
    if ((status = NFMRdisplay_catalog_sa_mapping
        (NFFglobal.catalog, "", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
             "NFMRdisplay_catalog_sa_mapping = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname,
        "NFMRdisplay_catalog_sa_mapping = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum
        (title, t_label, "%s", NFFglobal.catalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "List of Catalog Storage Area Mappings");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_project_acl_mapping (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = PROJECTACL_LABEL;
    auto    int     t_label = NFT_P_LIST_PRJ_ACL_MAP;
    auto    int     columns = PROJECTACL_COLUMNS;
    auto    char    *form_name = PROJECTACL_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_project_acl_mapping";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_project_acl_mapping ...\n"));
    if ((status = NFMRdisplay_project_acl_mapping
        (NFFglobal.project, "", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
             "NFMRdisplay_project_acl_mapping = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname,
        "NFMRdisplay_project_acl_mapping = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Put the title on the form  */

    if ((status = (long) UMSGetByNum
        (title, t_label, "%s", NFFglobal.project)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "List of Project ACL Mappings");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_project_sa_mapping (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = PROJECTSA_LABEL;
    auto    int     t_label = NFT_P_LIST_PRJ_SA_MAP;
    auto    int     columns = PROJECTSA_COLUMNS;
    auto    char    *form_name = PROJECTSA_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_project_sa_mapping";

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_project_sa_mapping ...\n"));
    if ((status = NFMRdisplay_project_sa_mapping
        (NFFglobal.project, "", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname,
             "NFMRdisplay_project_sa_mapping = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname,
        "NFMRdisplay_project_sa_mapping = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum
        (title, t_label, "%s", NFFglobal.project)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "List of Project Storage Area Mappings");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_search_criteria (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = SEARCH_LABEL;
    auto    int     t_label = NFT_P_LIST_SEARCH;
    auto    int     columns = CRITERIA_COLUMNS;
    auto    char    *form_name = CRITERIA_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    char    search[256] = "";
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_search_criteria";

    /*  Make sure the user only sees search criteria
        that either he owns or that are owned by PUBLIC  */

    if (NFMRglobal.administrator == FALSE)
      {
        sprintf (search, "n_owner IN (SELECT n_userno FROM nfmusers\
            WHERE n_username = '%s' OR n_username = 'PUBLIC')",
            NFFglobal.username);
      }

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_querys ...\n"));
    if ((status = NFMRdisplay_querys
        ("W", search, "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_querys = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_querys = <0x%.8x>\n", status));

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
        strcpy (title, "List of Search Criteria Names");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_sort_criteria (locate_flag)
  int       locate_flag;
  {
    auto    int     f_label = SORT_LABEL;
    auto    int     t_label = NFT_P_LIST_SORT;
    auto    int     columns = CRITERIA_COLUMNS;
    auto    char    *form_name = CRITERIA_FORM;
    auto    long    status;
    auto    char    title[256];
    auto    char    search[256] = "";
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_sort_criteria";

    /*  Make sure the user only sees sort criteria
        that either he owns or that are owned by PUBLIC  */

    if (NFMRglobal.administrator == FALSE)
      {
        sprintf (search, "n_owner IN (SELECT n_userno FROM nfmusers\
            WHERE n_username = '%s' OR n_username = 'PUBLIC')",
            NFFglobal.username);
      }

    /*  Get the data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_querys ...\n"));
    if ((status = NFMRdisplay_querys
        ("O", search, "", 0, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_querys = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_querys = <0x%.8x>\n", status));

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
        strcpy (title, "List of Sort Criteria Names");
      }

    /*  Load the form with data  */

    if ((status = _NFFload_display (f_label, form_name,
        columns, title, data, locate_flag)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFload_display = <0x%.8x>\n", status));
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_archive_flags (locate_flag)
  int       locate_flag;
  {
    auto    long    status;
    auto    char    s[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_archive_flags";

    /*  Get the data from the database  */

    NFFform_message (ARCHIVES_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_archive_flags ...\n"));
    if ((status = NFMRdisplay_archive_flags
        ("", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_archive_flags = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_archive_flags = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load the form (if it's not already loaded)  */

    if (NFFglobal.forms[ARCHIVES_LABEL] == NULL)
      {
        if ((status = FIf_new (ARCHIVES_LABEL, ARCHIVES_FORM,
            &_NFFnotify, &NFFglobal.forms[ARCHIVES_LABEL])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Erase any existing data  */

        FIfld_set_num_rows (NFFglobal.forms[ARCHIVES_LABEL], MCF, 0);
      }

    /*  Put the title on the form  */

    if ((status = (long) UMSGetByNum
        (s, NFT_P_LIST_ARCHIVE_FLAGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "List of Items Flagged for Archive");
      }

    FIg_set_text (NFFglobal.forms[ARCHIVES_LABEL], LISTING_TITLE, s);

    if ((status = _NFFlist_load_mcf (NFFglobal.forms[ARCHIVES_LABEL],
        FI_SINGLE_SELECT, synonyms, data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_load_mcf = <0x%.8x>\n", status));
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (NFFglobal.forms[ARCHIVES_LABEL], MCF, FALSE);

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (ARCHIVES_LABEL);

    /*  Display the form  */

    FIf_display (NFFglobal.forms[ARCHIVES_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_backup_flags (locate_flag)
  int       locate_flag;
  {
    auto    long    status;
    auto    char    s[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_backup_flags";

    /*  Get the data from the database  */

    NFFform_message (BACKUPS_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_backup_flags ...\n"));
    if ((status = NFMRdisplay_backup_flags
        ("", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_backup_flags = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_backup_flags = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load the form (if it's not already loaded)  */

    if (NFFglobal.forms[BACKUPS_LABEL] == NULL)
      {
        if ((status = FIf_new (BACKUPS_LABEL, BACKUPS_FORM,
            &_NFFnotify, &NFFglobal.forms[BACKUPS_LABEL])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Erase any existing data  */

        FIfld_set_num_rows (NFFglobal.forms[BACKUPS_LABEL], MCF, 0);
      }

    /*  Put the title on the form  */

    if ((status = (long) UMSGetByNum
        (s, NFT_P_LIST_BACKUP_FLAGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "List of Items Flagged for Backup");
      }

    FIg_set_text (NFFglobal.forms[BACKUPS_LABEL], LISTING_TITLE, s);

    if ((status = _NFFlist_load_mcf (NFFglobal.forms[BACKUPS_LABEL],
        FI_SINGLE_SELECT, synonyms, data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_load_mcf = <0x%.8x>\n", status));
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (NFFglobal.forms[BACKUPS_LABEL], MCF, FALSE);

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (BACKUPS_LABEL);

    /*  Display the form  */

    FIf_display (NFFglobal.forms[BACKUPS_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_restore_flags (locate_flag)
  int       locate_flag;
  {
    auto    long    status;
    auto    char    s[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_restore_flags";

    /*  Get the data from the database  */

    NFFform_message (RESTORE_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_restore_flags ...\n"));
    if ((status = NFMRdisplay_restore_flags
        ("", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_restore_flags = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_restore_flags = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load the form (if it's not already loaded)  */

    if (NFFglobal.forms[RESTORE_LABEL] == NULL)
      {
        if ((status = FIf_new (RESTORE_LABEL, RESTORE_FORM,
            &_NFFnotify, &NFFglobal.forms[RESTORE_LABEL])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Erase any existing data  */

        FIfld_set_num_rows (NFFglobal.forms[RESTORE_LABEL], MCF, 0);
      }

    /*  Put the title on the form  */

    if ((status = (long) UMSGetByNum
        (s, NFT_P_LIST_RESTORE_FLAGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "List of Items Flagged for Restore");
      }

    FIg_set_text (NFFglobal.forms[RESTORE_LABEL], LISTING_TITLE, s);

    if ((status = _NFFlist_load_mcf (NFFglobal.forms[RESTORE_LABEL],
        FI_SINGLE_SELECT, synonyms, data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_load_mcf = <0x%.8x>\n", status));
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (NFFglobal.forms[RESTORE_LABEL], MCF, FALSE);

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (RESTORE_LABEL);

    /*  Display the form  */

    FIf_display (NFFglobal.forms[RESTORE_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_delete_flags (locate_flag)
  int       locate_flag;
  {
    auto    long    status;
    auto    char    s[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_delete_flags";

    /*  Get the data from the database  */

    NFFform_message (DELETE_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_delete_flags ...\n"));
    if ((status = NFMRdisplay_delete_flags
        ("", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_delete_flags = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_delete_flags = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load the form (if it's not already loaded)  */

    if (NFFglobal.forms[DELETE_LABEL] == NULL)
      {
        if ((status = FIf_new (DELETE_LABEL, DELETE_FORM,
            &_NFFnotify, &NFFglobal.forms[DELETE_LABEL])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Erase any existing data  */

        FIfld_set_num_rows (NFFglobal.forms[DELETE_LABEL], MCF, 0);
      }

    /*  Put the title on the form  */

    if ((status = (long) UMSGetByNum
        (s, NFT_P_LIST_DELETE_FLAGS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "List of Items Flagged for Delete");
      }

    FIg_set_text (NFFglobal.forms[DELETE_LABEL], LISTING_TITLE, s);

    if ((status = _NFFlist_load_mcf (NFFglobal.forms[DELETE_LABEL],
        FI_SINGLE_SELECT, synonyms, data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_load_mcf = <0x%.8x>\n", status));
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (NFFglobal.forms[DELETE_LABEL], MCF, FALSE);

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (DELETE_LABEL);

    /*  Display the form  */

    FIf_display (NFFglobal.forms[DELETE_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFdisplay_notify (f_label, g_label, row, form)
  int     f_label;
  int     g_label;
  int     row;
  Form    *form;
  {
    auto    int   i, sel, r_pos;
    auto    int   num_rows = 0;
    auto    int   set_or_not = 0;
    auto    char  text[20];
    auto    char  command[15];
    auto    long  status = NFI_S_SUCCESS;
    static  char  *fname = "_NFFdisplay_notify";

    _NFIdebug ((fname, "f_label = %d\n", f_label));
    _NFIdebug ((fname, "g_label = %d\n", g_label));
    _NFIdebug ((fname, "row = %d\n", row));

    switch (g_label)
      {
        case MCF:

            /*  See if any rows or columns are scrolling  */

            if (row < 0) return (status);

            switch (f_label)
              {
                case NODES_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_NODENAME + 1, NFFglobal.node, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
			    NODE_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            NODE_FIELD, 0, 0, NFFglobal.node, FALSE);
                        _NFIdebug ((fname,
                            "nodename = <%s>\n", NFFglobal.node));
                      }

                    break;

                case STORAGE_AREAS_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_SANAME + 1, NFFglobal.storage_area,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
			    SA_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SA_FIELD, 0, 0, NFFglobal.storage_area, FALSE);
                        _NFIdebug ((fname, "storage area name = <%s>\n",
                            NFFglobal.storage_area));
                      }

                    break;

                case WORKING_AREAS_LABEL_ADMIN:
                case WORKING_AREAS_LABEL_USER:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_SANAME + 1, NFFglobal.working_area,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
			    WA_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            WA_FIELD, 0, 0, NFFglobal.working_area, FALSE);
                        _NFIdebug ((fname, "working area name = <%s>\n",
                            NFFglobal.working_area));
                      }

                    break;

                case USERS_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_USERNAME + 1, NFFglobal.user, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
			    USER_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            USER_FIELD, 0, 0, NFFglobal.user, FALSE);
                        _NFIdebug ((fname,
                            "username = <%s>\n", NFFglobal.user));
                      }

                    break;

                case CATALOGS_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_CATALOGNAME + 1, NFFglobal.catalog,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
			    CATALOG_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            CATALOG_FIELD, 0, 0, NFFglobal.catalog, FALSE);
                        _NFIdebug ((fname,
                            "catalog name = <%s>\n", NFFglobal.catalog));

                        /*  Wipe out the active item and revision  */

                        strcpy (NFFglobal.item, "");
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
			    ITEM_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ITEM_FIELD, 0, 0, NFFglobal.item, FALSE);
			_NFFalter_item_text_label ("Item Name");
			strcpy (NFFglobal.set_indicator, "" );
                        strcpy (NFFglobal.revision, "");
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
			    REVISION_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            REVISION_FIELD, 0, 0, NFFglobal.revision, FALSE);
                      }
                    break;

                case LOCAL_FILES_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 5,
                            sizeof (text) - 1, text, &sel, &r_pos);
                        if ((strcmp (text, "Y")) == 0)
                          {
                            _NFIdebug ((fname,
                                "a checked out file was selected\n"));
                            FImcf_set_select (*form, g_label, row, FALSE);
                            status = NFI_W_COPIED_FILES_ONLY;
                            ERRload_struct (NFI, status, NULL);
                          }
                      }

                    break;

                case WORKFLOWS_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text
                            (*form, g_label, row, 0, NFM_WORKFLOWNAME + 1,
                            NFFglobal.workflow, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
			    WF_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            WF_FIELD, 0, 0, NFFglobal.workflow, FALSE);
                        _NFIdebug ((fname,
                            "workflow name = <%s>\n", NFFglobal.workflow));
                      }

                    break;

                case ACLS_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_ACLNAME + 1, NFFglobal.acl, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
			    ACL_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ACL_FIELD, 0, 0, NFFglobal.acl, FALSE);
                        _NFIdebug ((fname,
                            "acl name = <%s>\n", NFFglobal.acl));
                      }

                    break;

                case ACLUSERS_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_CLASSNAME + 1, NFFglobal.class, &sel, &r_pos);
                        _NFIdebug ((fname,
                            "class name = <%s>\n", NFFglobal.class));

                        FIfld_get_text (*form, g_label, row,
                            1, NFM_USERNAME + 1, NFFglobal.user, &sel, &r_pos);
                        _NFIdebug ((fname,
                            "username = <%s>\n", NFFglobal.user));
                      }

                    break;

                case SIGNOFFUSERS_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 1,
                            NFM_USERNAME + 1, NFFglobal.user, &sel, &r_pos);
                        _NFIdebug ((fname,
                            "username = <%s>\n", NFFglobal.user));
                      }

                    break;

                case PROJECTS_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_PROJECTNAME + 1, NFFglobal.project,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], PROJECT_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            PROJECT_FIELD, 0, 0, NFFglobal.project, FALSE);
                        _NFIdebug ((fname,
                            "project name = <%s>\n", NFFglobal.project));
                      }

                    break;

                case WHERE_PROJECT_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_PROJECTNAME + 1, NFFglobal.project,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            PROJECT_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            PROJECT_FIELD, 0, 0, NFFglobal.project, FALSE);
                        _NFIdebug ((fname,
                            "project name = <%s>\n", NFFglobal.project));
                      }

                    break;

                case WHERE_SET_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        /*  Get the selected catalog name  */

                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_CATALOGNAME + 1, NFFglobal.catalog,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            CATALOG_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                             CATALOG_FIELD, 0, 0, NFFglobal.catalog, FALSE);
                        _NFIdebug ((fname,
                            "catalog name = <%s>\n", NFFglobal.catalog));

                        /*  Get the selected item name  */

                        FIfld_get_text (*form, g_label, row, 1,
                            NFM_ITEMNAME + 1, NFFglobal.item, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            ITEM_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ITEM_FIELD, 0, 0, NFFglobal.item, FALSE);
                        _NFIdebug ((fname,
                            "item name = <%s>\n", NFFglobal.item));

                        /*  Get the selected item revision  */

                        FIfld_get_text (*form, g_label, row, 2,
                            NFM_ITEMREV + 1, NFFglobal.revision, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            REVISION_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            REVISION_FIELD, 0, 0, NFFglobal.revision, FALSE);
                        _NFIdebug ((fname,
                            "revision = <%s>\n", NFFglobal.revision));
			
			/*  See if the selected item is really a set */

		        _NFIdebug ((fname, "calling NFMRvalidate_revision ...\n"));
		        status = NFMRvalidate_revision
			        (NFFglobal.catalog, NFFglobal.item,
				 NFFglobal.revision, &set_or_not);
                        _NFIdebug ((fname,"NFMRvalidate_revision = <0x%.8x>\n",
				   status));
			if( status != NFM_S_SUCCESS )
			{
			    set_or_not = 0;
			}		  
			else
			{
		            _NFIdebug(( fname, "Item is a set\n" ));
			    _NFFalter_item_text_label ("Set Name");
			    strcpy (NFFglobal.set_indicator, "Y");
			}

                      }

                    break;

                case ITEM_SIGNOFF_LABEL:
                    break;

                case SIGNOFF_HISTORY_LABEL:
                    break;

                case SEARCH_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_REPORTNAME + 1, NFFglobal.search,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            SEARCH_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SEARCH_FIELD, 0, 0, NFFglobal.search, FALSE);
                        _NFIdebug ((fname,
                            "search name = <%s>\n", NFFglobal.search));
                      }

                    break;

                case SORT_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_REPORTNAME + 1, NFFglobal.sort, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            SORT_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SORT_FIELD, 0, 0, NFFglobal.sort, FALSE);
                        _NFIdebug ((fname,
                            "sort name = <%s>\n", NFFglobal.sort));
                      }

                    break;

                case CATALOGACL_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text
                            (*form, g_label, row, 0, NFM_WORKFLOWNAME + 1,
                            NFFglobal.workflow, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            WF_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            WF_FIELD, 0, 0, NFFglobal.workflow, FALSE);
                        _NFIdebug ((fname,
                            "workflow name = <%s>\n", NFFglobal.workflow));

                        FIfld_get_text (*form, g_label, row,
                            1, NFM_ACLNAME + 1, NFFglobal.acl, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            ACL_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ACL_FIELD, 0, 0, NFFglobal.acl, FALSE);
                        _NFIdebug ((fname,
                            "acl name = <%s>\n", NFFglobal.acl));
                      }

                    break;

                case CATALOGSA_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_SANAME + 1, NFFglobal.storage_area,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            SA_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SA_FIELD, 0, 0, NFFglobal.storage_area, FALSE);
                        _NFIdebug ((fname, "storage area name = <%s>\n",
                            NFFglobal.storage_area));
                      }

                    break;

                case PROJECTACL_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_CATALOGNAME + 1, NFFglobal.catalog,
                            &sel, &r_pos);
                        _NFIdebug ((fname,
                            "catalog name = <%s>\n", NFFglobal.catalog));

                        FIfld_get_text
                            (*form, g_label, row, 0, NFM_WORKFLOWNAME + 1,
                            NFFglobal.workflow, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            WF_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            WF_FIELD, 0, 0, NFFglobal.workflow, FALSE);
                        _NFIdebug ((fname,
                            "workflow name = <%s>\n", NFFglobal.workflow));

                        FIfld_get_text (*form, g_label, row, 1,
                            NFM_ACLNAME + 1, NFFglobal.acl, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            ACL_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ACL_FIELD, 0, 0, NFFglobal.acl, FALSE);
                        _NFIdebug ((fname,
                            "acl name = <%s>\n", NFFglobal.acl));
                      }

                    break;

                case PROJECTSA_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_CATALOGNAME + 1, NFFglobal.catalog,
                            &sel, &r_pos);
                        _NFIdebug ((fname,
                            "catalog name = <%s>\n", NFFglobal.catalog));

                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_SANAME + 1, NFFglobal.storage_area,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            SA_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SA_FIELD, 0, 0, NFFglobal.storage_area, FALSE);
                        _NFIdebug ((fname, "storage area name = <%s>\n",
                            NFFglobal.storage_area));
                      }

                    break;

                case ARCHIVES_LABEL:
                case BACKUPS_LABEL:
                case RESTORE_LABEL:
                case DELETE_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == TRUE)
                      {
                        /*  Get the selected catalog name  */

                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_CATALOGNAME + 1, NFFglobal.catalog,
                            &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            CATALOG_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            CATALOG_FIELD, 0, 0, NFFglobal.catalog, FALSE);
                        _NFIdebug ((fname,
                            "catalog name = <%s>\n", NFFglobal.catalog));

                        /*  Get the selected item name  */

                        FIfld_get_text (*form, g_label, row, 1,
                            NFM_ITEMNAME + 1, NFFglobal.item, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            ITEM_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ITEM_FIELD, 0, 0, NFFglobal.item, FALSE);
                        _NFIdebug ((fname,
                            "item name = <%s>\n", NFFglobal.item));

                        /*  Get the selected item revision  */

                        FIfld_get_text (*form, g_label, row, 2,
                            NFM_ITEMREV + 1, NFFglobal.revision, &sel, &r_pos);
#ifdef OS_SCO_UNIX
                        /* work around change - to set font for SCO - SSRS 3 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], 
		            REVISION_FIELD, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            REVISION_FIELD, 0, 0, NFFglobal.revision, FALSE);
                        _NFIdebug ((fname,
                            "revision = <%s>\n", NFFglobal.revision));

			/*  See if the selected item is really a set */

		        _NFIdebug ((fname, "calling NFMRvalidate_revision ...\n"));
		        status = NFMRvalidate_revision
			        (NFFglobal.catalog, NFFglobal.item,
				 NFFglobal.revision, &set_or_not);
                        _NFIdebug ((fname,"NFMRvalidate_revision = <0x%.8x>\n",
				   status));
			if( status != NFM_S_SUCCESS )
			{
			    set_or_not = 0;
			}		  
			else if( set_or_not == TRUE )
			{
		            _NFIdebug(( fname, "Item is a set\n" ));
			    _NFFalter_item_text_label ("Set Name");
			    strcpy (NFFglobal.set_indicator, "Y");
			}
			else
			    _NFFalter_item_text_label ("Item Name");

                      } /* end sel_flag */

                    break;

                case LIST_ARCHIVES_LABEL:
                case SAVESETS_LABEL:
                case ITEMS_TAPE_LABEL:
                    break;
              }

            break;

        case NFF_EXECUTE:

            switch (f_label)
              {
                case NODES_LABEL:
                    status = NFFdisplay_nodes (FALSE);
                    break;

                case STORAGE_AREAS_LABEL:
                    status = NFFdisplay_storage_areas (FALSE);
                    break;

                case WORKING_AREAS_LABEL_ADMIN:
                    status = NFFdisplay_working_areas_admin (FALSE);
                    break;

                case WORKING_AREAS_LABEL_USER:
                    status = NFFdisplay_working_areas_user (FALSE);
                    break;

                case USERS_LABEL:
                    status = NFFdisplay_users (FALSE);
                    break;

                case CATALOGS_LABEL:
                    status = NFFdisplay_catalogs (FALSE);
                    break;

                case LOCAL_FILES_LABEL:
                    status = NFFdisplay_local_files (FALSE);
                    break;

                case WORKFLOWS_LABEL:
                    status = NFFdisplay_workflows (FALSE);
                    break;

                case ACLS_LABEL:
                    status = NFFdisplay_acls (FALSE);

		    /* If no acls are found,then delete the display-acls form
			and give an  appropriate message on the main-form. 
				IGI CN 8/10/95   */ 

		    if (status == NFM_E_DISPLAY_ACLS)
		    {
	   		ERRload_struct(NFM,NFM_E_DISPLAY_ACLS,"%s",
						NFFglobal.workflow); 
			NFFerror_message(NULL);
		
			FIf_delete (*form);
            		NFFglobal.forms[f_label] = *form = NULL;
            		--NFFglobal.locations[NFFglobal.positions[f_label]];
            		NFFglobal.positions[f_label] = -1;
	  	    }	
/* end of modification */	
                    break;

                case ACLUSERS_LABEL:
                    status = NFFdisplay_aclusers (FALSE);
                    break;

                case SIGNOFFUSERS_LABEL:
                    status = NFFdisplay_signoff_users (FALSE);
                    break;

                case PROJECTS_LABEL:
                    status = NFFdisplay_projects (FALSE);
                    break;

                case SEARCH_LABEL:
                    status = NFFdisplay_search_criteria (FALSE);
                    break;

                case SORT_LABEL:
                    status = NFFdisplay_sort_criteria (FALSE);
                    break;

                case CATALOGACL_LABEL:
                    status = NFFdisplay_catalog_acl_mapping (FALSE);
                    break;

                case CATALOGSA_LABEL:
                    status = NFFdisplay_catalog_sa_mapping (FALSE);
                    break;

                case PROJECTACL_LABEL:
                    status = NFFdisplay_project_acl_mapping (FALSE);
                    break;

                case PROJECTSA_LABEL:
                    status = NFFdisplay_project_sa_mapping (FALSE);
                    break;

                case ARCHIVES_LABEL:
                    status = NFFdisplay_archive_flags (FALSE);
                    break;

                case BACKUPS_LABEL:
                    status = NFFdisplay_backup_flags (FALSE);
                    break;

                case RESTORE_LABEL:
                    status = NFFdisplay_restore_flags (FALSE);
                    break;

                case DELETE_LABEL:
                    status = NFFdisplay_delete_flags (FALSE);
                    break;

                case ITEM_SIGNOFF_LABEL:
                    status = NFFdisplay_item_signoffs (FALSE);
                    break;

                case SIGNOFF_HISTORY_LABEL:
                    status = NFFdisplay_signoff_history (FALSE);
                    break;

                case WHERE_PROJECT_LABEL:
                    status = NFFwhere_used_project (FALSE);
                    break;

                case WHERE_SET_LABEL:
                    status = NFFwhere_used_set (FALSE);
                    break;

                case LIST_ARCHIVES_LABEL:
                    status = NFFdisplay_archives (FALSE);
                    break;

                case SAVESETS_LABEL:
                    status = NFFdisplay_savesets (FALSE);
                    break;

                case ITEMS_TAPE_LABEL:
                    status = NFFdisplay_items_on_tape (FALSE);
                    break;
              }

            break;

        case NFF_HELP:

            switch (f_label)
              {
                case NODES_LABEL:
                    strcpy (command, NFI_M_DISPLAY_NODES);
                    break;

                case STORAGE_AREAS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_SA);
                    break;

                case WORKING_AREAS_LABEL_ADMIN:
                    strcpy (command, NFI_M_DISPLAY_WA_ADMIN);
                    break;

                case WORKING_AREAS_LABEL_USER:
                    strcpy (command, NFI_M_DISPLAY_WA_USER);
                    break;

                case USERS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_USERS);
                    break;

                case CATALOGS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_CATALOGS);
                    break;

                case LOCAL_FILES_LABEL:
                    strcpy (command, NFI_M_DISPLAY_LOCAL_FILES);
                    break;

                case WORKFLOWS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_WFS);
                    break;

                case ACLS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_ACLS);
                    break;

                case ACLUSERS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_ACL_CLASS_USERS);
                    break;

                case SIGNOFFUSERS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_ACL_SO_USERS);
                    break;

                case PROJECTS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_PROJECTS);
                    break;

                case SEARCH_LABEL:
                    strcpy (command, NFI_M_DISPLAY_SEARCH_CRITERIA);
                    break;

                case SORT_LABEL:
                    strcpy (command, NFI_M_DISPLAY_SORT_CRITERIA);
                    break;

                case CATALOGACL_LABEL:
                    strcpy (command, NFI_M_DISPLAY_CATALOG_ACL_MAPPING);
                    break;

                case CATALOGSA_LABEL:
                    strcpy (command, NFI_M_DISPLAY_CATALOG_SA_MAPPING);
                    break;

                case PROJECTACL_LABEL:
                    strcpy (command, NFI_M_DISPLAY_PROJECT_ACL_MAPPING);
                    break;

                case PROJECTSA_LABEL:
                    strcpy (command, NFI_M_DISPLAY_PROJECT_SA_MAPPING);
                    break;

                case ARCHIVES_LABEL:
                    strcpy (command, NFI_M_DISPLAY_FILES_FLAGGED_ARCHIVE);
                    break;

                case BACKUPS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_FILES_FLAGGED_BACKUP);
                    break;

                case RESTORE_LABEL:
                    strcpy (command, NFI_M_DISPLAY_FILES_FLAGGED_RESTORE);
                    break;

                case DELETE_LABEL:
                    strcpy (command, NFI_M_DISPLAY_FILES_FLAGGED_DELETE);
                    break;

                case ITEM_SIGNOFF_LABEL:
                    strcpy (command, NFI_M_LIST_SIGNOFF_ITEM);
                    break;

                case SIGNOFF_HISTORY_LABEL:
                    strcpy (command, NFI_M_LIST_SIGNOFF_HISTORY);
                    break;

                case LIST_ARCHIVES_LABEL:
                    strcpy (command, NFI_M_DISPLAY_ARCHIVES);
                    break;

                case SAVESETS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_SAVESETS);
                    break;

                case ITEMS_TAPE_LABEL:
                    strcpy (command, NFI_M_DISPLAY_ITEMS_ON_TAPE);
                    break;
              }

            if (status = _NFFhelp_topic (command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                status = NFI_E_HELP;
                ERRload_struct (NFI, status, "%s%d", "_NFFhelp_topic", status);
              }

            break;

        case NFF_CANCEL:
            FIf_delete (*form);
            NFFglobal.forms[f_label] = *form = NULL;
            --NFFglobal.locations[NFFglobal.positions[f_label]];
            NFFglobal.positions[f_label] = -1;
            break;

        case NFF_SELECT_ALL:

            FImcf_get_select (*form, MCF, 0, &sel);
            FIfld_get_num_rows (*form, MCF, &num_rows);

            /*  If the first row is selected,
                deselect all rows; if not, select all rows  */

            for (i = 0; i < num_rows; ++i)
              {
                if (sel == TRUE)
                    FImcf_set_select (*form, MCF, i, FALSE);
                else
                    FImcf_set_select (*form, MCF, i, TRUE);
              }

            break;

        case NFF_PRINT:
            status = _NFFprint_listing (f_label);
            break;
      }

    _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
    return (status);
  }


long _NFFload_display (f_label, form_name, num_cols, title, data, locate_flag)
  int       f_label;
  char      *form_name;
  int       num_cols;
  char      *title;
  MEMptr    data;
  int       locate_flag;  /*  i - TRUE = call _NFFplace_form ();
                                  FALSE = don't call _NFFplace_form ();
                                  -1 = don't display the form            */
  {
    auto    int     row, col;
    auto    long    status;
    auto    char    **data_ptr;
    auto    Form    form = NULL;
    static  char    *fname = "_NFFload_display";

    if ((status = MEMbuild_array (data)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
      }

    data_ptr = (char **) data->data_ptr;

    /*  Figure out which form pointer to use  */

    if (f_label < CURRENT_LABEL)
        form = NFFglobal.forms[f_label];
    else
        form = NFFglobal.current_form;

    /*  Load the form (if it's not already loaded)  */

    if (form == NULL)
      {
        if (f_label < CURRENT_LABEL)
          {
            if ((status = FIf_new (f_label, form_name,
                &_NFFnotify, &NFFglobal.forms[f_label])) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIf_new = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
                _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
                return (NFI_E_FORM);
              }

            form = NFFglobal.forms[f_label];
          }
        else
          {
            if ((status = FIf_new (f_label, form_name,
                &_NFFnotify, &NFFglobal.current_form)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIf_new = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
                _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
                return (NFI_E_FORM);
              }

            form = NFFglobal.current_form;
          }

        FIg_set_text (form, LISTING_TITLE, title);
      }
    else
      {
        /*  Erase any existing data  */

        FIfld_set_num_rows (form, MCF, 0);
      }

    /*  Put the data into the form  */

#ifdef OS_SCO_UNIX
    /* It is observerd that the column headings gadget in display forms 
       (for catalogs, nodes, projects etc) has a gadget number 14.
       SSRS 5 Feb 94
    */
    FIg_set_font( form, 14, "7x13bold", 15 );
    FIg_set_font( form, MCF, "7x13bold", 15 );
#endif

    for (row = 0; row < data->rows; ++row)
      {
        for (col = 0; col < num_cols; ++col)
          {
            FIfld_set_text (form, MCF,
                row, col, data_ptr[(row * data->columns) + col], FALSE);

            /*  Change the mode, if necessary  */

            if (f_label >= CURRENT_LABEL)
                FIfld_set_mode (form, MCF, col, FI_MULTI_SELECT);
          }
      }

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (form, MCF, FALSE);

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (f_label);

    /*  Display the form  */

    if (locate_flag != -1)
        FIf_display (form);

    _NFIdebug ((fname, "returning <0x%.8x> ...\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


void _NFFplace_form (f_label)
  int     f_label;
  {
    auto    int   i;
    auto    int   x, y;
    auto    int   fewest, max_slot;
    auto    int   position = 0;
    auto    int   is_collapsed = 0;
    static  char  *fname = "_NFFplace_form";

    /*  If the form has already been displayed, get ready to move it  */

    if (NFFglobal.positions[f_label] != -1)
        --NFFglobal.locations[NFFglobal.positions[f_label]];

    /*  Find out which slot has the fewest forms in it  */

    if (NFFglobal.admin_or_user == ADMIN)
        max_slot = 2;
    else
        max_slot = 3;

    for (i = 1, fewest = NFFglobal.locations[0]; i < max_slot; ++i)
      {
        if (NFFglobal.locations[i] < fewest)
          {
            fewest = NFFglobal.locations[i];
            position = i;
          }
      }

    /*  Increment the smallest slot for this form  */

    ++NFFglobal.locations[position];

    switch (position)
      {
        case LOWER_LEFT:
            x = LOWER_LEFT_X * NFFglobal.scale_factor_x;
            y = LOWER_LEFT_Y * NFFglobal.scale_factor_y;
            break;

        case LOWER_RIGHT:
            x = LOWER_RIGHT_X * NFFglobal.scale_factor_x;
            y = LOWER_RIGHT_Y * NFFglobal.scale_factor_y;
            break;

        case UPPER_LEFT:
        default:
            x = UPPER_LEFT_X * NFFglobal.scale_factor_x;
            y = UPPER_LEFT_Y * NFFglobal.scale_factor_y;
            break;
      }

    FIf_set_location (NFFglobal.forms[f_label], x, y);

    _NFIdebug ((fname, "positions[%d] = %d\n", f_label, position));
    NFFglobal.positions[f_label] = position;

    /*  Find out if the form is collapsed of not  */

    FIf_is_displayed (NFFglobal.forms[f_label], &is_collapsed);
    if (is_collapsed)
        FIf_uncollapse (NFFglobal.forms[f_label]);

    return;
  }


void NFFfind_mcf_attribute (form, label, attrname, col)
  Form    form;
  int     label;
  char    *attrname;
  int     *col;
  {
    auto    int   i;
    auto    int   num_cols;
    auto    int   sel, rpos;
    /* Size of arrary increased to 30, as this is giving problem
       with SCO Xforms - IGI 11 Jul 94 */
    auto    char  text[30];
    static  char  *fname = "NFFfind_mcf_attribute";

    _NFIdebug ((fname, "attrname = <%s>\n", attrname));

    *col = -1;

    FImcf_get_num_cols (form, label, &num_cols);

    for (i = 0; i < num_cols; ++i)
      {
        FIfld_get_text (form, label, 1, i, sizeof (text), text, &sel, &rpos);
        _NFIdebug ((fname, "text = <%s>\n", text));
        if ((strcmp (text, attrname)) == 0)
          {
            *col = i;
            break;
          }
      }

    _NFIdebug ((fname, "col = <%d>\n", *col));

    return;
  }


void _NFFalter_item_text_label (new_text)
  char    *new_text;
  {
    auto    int   xpos, ypos;
    auto    int   xsize, ysize;
    auto    int   old_xsize, old_ysize;
    static  char  *fname = "_NFFalter_item_text_label";

    _NFIdebug ((fname, "new_text = <%s>\n", new_text));

    FIg_erase (NFFglobal.forms[MAIN_LABEL], ITEM_TEXT);
    FIg_get_location (NFFglobal.forms[MAIN_LABEL], ITEM_TEXT, &xpos, &ypos);
    FIg_get_size (NFFglobal.forms[MAIN_LABEL],
        ITEM_TEXT, &old_xsize, &old_ysize);
    FIg_set_text (NFFglobal.forms[MAIN_LABEL], ITEM_TEXT, new_text);
    FIg_get_size (NFFglobal.forms[MAIN_LABEL], ITEM_TEXT, &xsize, &ysize);
    FIg_set_location (NFFglobal.forms[MAIN_LABEL],
        ITEM_TEXT, xpos + old_xsize - xsize, ypos);
    FIg_display (NFFglobal.forms[MAIN_LABEL], ITEM_TEXT);

    _NFIdebug ((fname, "returning ...\n"));
    return;
  }
