
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmain_form.h"

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdisplay_items (locate_flag)
  int       locate_flag;
  {
    auto    int     row;
    auto    int     sel, r_pos;
    auto    int     num_rows;
    auto    long    status, sts;
    auto    char    s[256];
    auto    char    type[5];
    auto    char    datatype[40];
    auto    char    form_name[20];
    auto    char    catalog[NFM_CATALOGNAME + 1];
    auto    char    search[NFM_REPORTNAME + 1];
    auto    char    sort[NFM_REPORTNAME + 1];
    auto    short   multiple_catalogs = FALSE;
    auto    MEMptr  catalogs = NULL;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    save_catalog[NFM_CATALOGNAME + 1];
    static  char    *fname = "NFFdisplay_items";

    /*  Load the active search and sort criteria  */

    if (NFFglobal.search_active == TRUE)
        strcpy (search, NFFglobal.search);
    else
        strcpy (search, "");

    if (NFFglobal.sort_active == TRUE)
        strcpy (sort, NFFglobal.sort);
    else
        strcpy (sort, "");

    /*  See if there is an active catalog list  */

    if (NFFglobal.forms[CATALOGS_LABEL] != NULL)
      {
        FIfld_get_num_rows (NFFglobal.forms[CATALOGS_LABEL], MCF, &num_rows);

        for (row = 0; row < num_rows; ++row)
          {
            /*  Get the next selected row  */

            FImcf_get_select (NFFglobal.forms[CATALOGS_LABEL], MCF, row, &sel);
            if (sel == FALSE) continue;

            FIfld_get_text (NFFglobal.forms[CATALOGS_LABEL],
                MCF, row, 0, NFM_CATALOGNAME + 1, catalog, &sel, &r_pos);

            /*  See if the buffer is open  */

            if (catalogs == NULL)
              {
                MEMopen (&catalogs, MEM_SIZE);
                sprintf (datatype, "char(%d)", NFM_CATALOGNAME);
                MEMwrite_format (catalogs, "n_catalogname", datatype);
              }

            /*  Write the catalog name into the buffer  */

            MEMwrite (catalogs, catalog);
          }
      }

    /*  Get the data from the database  */

    NFFform_message (ITEMS_LABEL, NFI_I_RETRIEVE, NULL);

    if (catalogs != NULL)
      {
        /*  See if blocking is enabled  */

        if (NFMRglobal.query_rows > 0)
          {
            if (NFFglobal.forms[ITEMS_LABEL] != NULL)
              {
                /*  End the current list first  */

                if ((status = _NFFend_block_listing
                    (ITEMS_LABEL, FALSE)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFend_block_listing = <0x%.8x>\n", status));
                    NFFerase_message ();
                    MEMclose (&catalogs);
                    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                    return (status);
                  }
              }

            _NFIdebug ((fname,
                "Calling NFMRblock_multiple_catalog_search ...\n"));

            status = NFMRblock_multiple_catalog_search (catalogs,
                search, sort, &data, &synonyms, NFMRglobal.query_rows);
            UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                NULL, NULL, NULL);
            if ((strcmp (type, "E")) == 0)
              {
                _NFIdebug ((fname,
                    "NFMRblock_multiple_catalog_search = <0x%.8x>\n", status));
                NFFerase_message ();
                MEMclose (&synonyms);
                MEMclose (&data);
                MEMclose (&catalogs);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname,
                "NFMRblock_multiple_catalog_search = <0x%.8x>\n", status));

            strcpy (form_name, BLOCK_ITEMS_FORM);
          }
        else
          {
            _NFIdebug ((fname, "Calling NFMRmultiple_catalog_search ...\n"));

            if ((status = NFMRmultiple_catalog_search
                (catalogs, search, sort, &data, &synonyms)) != NFM_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "NFMRmultiple_catalog_search = <0x%.8x>\n", status));
                NFFerase_message ();
                MEMclose (&synonyms);
                MEMclose (&data);
                MEMclose (&catalogs);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname,
                "NFMRmultiple_catalog_search = <0x%.8x>\n", status));

            strcpy (form_name, ITEMS_FORM);
          }

        MEMclose (&catalogs);
        multiple_catalogs = TRUE;
      }
    else
      {
        /*  See if blocking is enabled  */

        if (NFMRglobal.query_rows > 0)
          {
            if (NFFglobal.forms[ITEMS_LABEL] != NULL)
              {
                /*  End the current list first  */

                if ((status = _NFFend_block_listing
                    (ITEMS_LABEL, FALSE)) != NFI_S_SUCCESS)
                  {
                    _NFIdebug ((fname,
                        "_NFFend_block_listing = <0x%.8x>\n", status));
                    NFFerase_message ();
                    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                    return (status);
                  }
              }

            _NFIdebug ((fname, "Calling NFMRdisplay_items_partial ...\n"));

            status = NFMRdisplay_items_partial
                (NFFglobal.catalog, search, sort, 0,
                NFMRglobal.query_rows, &synonyms, &data);
            UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                NULL, NULL, NULL);
            if ((strcmp (type, "E")) == 0)
              {
                _NFIdebug ((fname,
                    "NFMRdisplay_items_partial = <0x%.8x>\n", status));
                NFFerase_message ();
                MEMclose (&synonyms);
                MEMclose (&data);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname,
                "NFMRdisplay_items_partial = <0x%.8x>\n", status));

            strcpy (form_name, BLOCK_ITEMS_FORM);
          }
        else
          {
            _NFIdebug ((fname, "Calling NFMRdisplay_items ...\n"));

            if ((status = NFMRdisplay_items (NFFglobal.catalog,
                search, sort, 0, &synonyms, &data)) != NFM_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFMRdisplay_items = <0x%.8x>\n", status));
                NFFerase_message ();
                MEMclose (&synonyms);
                MEMclose (&data);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname, "NFMRdisplay_items = <0x%.8x>\n", status));

            strcpy (form_name, ITEMS_FORM);
          }
      }

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load the form (if it's not already loaded)  */

    if (NFFglobal.forms[ITEMS_LABEL] == NULL)
      {
        if ((sts = FIf_new (ITEMS_LABEL, form_name,
            &_NFFnotify, &NFFglobal.forms[ITEMS_LABEL])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", sts));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", sts);
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Erase any existing data  */

        FIfld_set_num_rows (NFFglobal.forms[ITEMS_LABEL], MCF, 0);
      }

    /*  Store the catalog name in the form  */

    if (multiple_catalogs == FALSE)
      {
        strcpy (save_catalog, NFFglobal.catalog);
        _NFIdebug ((fname,
            "storing catalog name in form <%s>\n", save_catalog));
        FIf_set_user_pointer (NFFglobal.forms[ITEMS_LABEL], save_catalog);
      }

    /*  Put the title on the form  */

    if ((sts = (long) UMSGetByNum
        (s, NFT_P_LIST_ITEMS, "%s", NFFglobal.catalog)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", sts));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "List of Items");
      }

    FIg_set_text (NFFglobal.forms[ITEMS_LABEL], LISTING_TITLE, s);

    if ((sts = _NFFlist_load_mcf (NFFglobal.forms[ITEMS_LABEL],
        FI_MULTI_SELECT, synonyms, data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_load_mcf = <0x%.8x>\n", sts));
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", sts));
        return (sts);
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (NFFglobal.forms[ITEMS_LABEL], MCF, FALSE);

    /*  Disable the "More" button, if necessary  */

    if (status == NFM_I_NO_MORE_BUFFERS)
      {
        /*  This status is only returned for block listings  */

        FIg_disable (NFFglobal.forms[ITEMS_LABEL], NFF_MORE);
      }
    else if ((strcmp (form_name, BLOCK_ITEMS_FORM)) == 0)
      {
        /*  Enable the "More" button  */

        FIg_enable (NFFglobal.forms[ITEMS_LABEL], NFF_MORE);
      }

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (ITEMS_LABEL);

    /*  Display the form  */

    FIf_display (NFFglobal.forms[ITEMS_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_project_members (locate_flag)
  int       locate_flag;
  {
    auto    long    status, sts;
    auto    char    s[256];
    auto    char    type[5];
    auto    char    form_name[20];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_project_members";

    /*  Get the data from the database  */

    NFFform_message (PROJM_LABEL, NFI_I_RETRIEVE, NULL);

    /*  See if blocking is enabled  */

    if (NFMRglobal.query_rows > 0)
      {
        if (NFFglobal.forms[PROJM_LABEL] != NULL)
          {
            /*  End the current list first  */

            if ((status = _NFFend_block_listing
                (PROJM_LABEL, FALSE)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFend_block_listing = <0x%.8x>\n", status));
                NFFerase_message ();
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
          }

        _NFIdebug ((fname,
            "Calling NFMRdisplay_project_members_partial ...\n"));

        status = NFMRdisplay_project_members_partial (NFFglobal.project,
            "", "", NFMRglobal.query_rows, &synonyms, &data);
        UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
            NULL, NULL, NULL);
        if ((strcmp (type, "E")) == 0)
          {
            _NFIdebug ((fname,
                "NFMRdisplay_project_members_partial = <0x%.8x>\n", status));
            NFFerase_message ();
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
        _NFIdebug ((fname,
            "NFMRdisplay_project_members_partial = <0x%.8x>\n", status));

        strcpy (form_name, BLOCK_PROJM_FORM);
      }
    else
      {
        _NFIdebug ((fname, "Calling NFMRdisplay_project_members ...\n"));
        if ((status = NFMRdisplay_project_members
            (NFFglobal.project, "", "", &synonyms, &data)) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "NFMRdisplay_project_members = <0x%.8x>\n", status));
            NFFerase_message ();
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
        _NFIdebug ((fname,
            "NFMRdisplay_project_members = <0x%.8x>\n", status));

        strcpy (form_name, PROJM_FORM);
      }

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load the form (if it's not already loaded)  */

    if (NFFglobal.forms[PROJM_LABEL] == NULL)
      {
        if ((sts = FIf_new (PROJM_LABEL, form_name,
            &_NFFnotify, &NFFglobal.forms[PROJM_LABEL])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", sts));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", sts);
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Erase any existing data  */

        FIfld_set_num_rows (NFFglobal.forms[PROJM_LABEL], MCF, 0);
      }

    /*  Put the title on the form  */

    if ((sts = (long) UMSGetByNum
        (s, NFT_P_LIST_ITEMS_IN_PRJ, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", sts));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "List of Project Members");
      }

    FIg_set_text (NFFglobal.forms[PROJM_LABEL], LISTING_TITLE, s);

    if ((sts = _NFFlist_load_mcf (NFFglobal.forms[PROJM_LABEL],
        FI_MULTI_SELECT, synonyms, data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_load_mcf = <0x%.8x>\n", sts));
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", sts));
        return (sts);
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (NFFglobal.forms[PROJM_LABEL], MCF, FALSE);

    /*  Disable the "More" button, if necessary  */

    if (status == NFM_I_NO_MORE_BUFFERS)
      {
        /*  This status is only returned for block listings  */

        FIg_disable (NFFglobal.forms[PROJM_LABEL], NFF_MORE);
      }
    else if ((strcmp (form_name, BLOCK_PROJM_FORM)) == 0)
      {
        /*  Enable the "More" button  */

        FIg_enable (NFFglobal.forms[PROJM_LABEL], NFF_MORE);
      }

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (PROJM_LABEL);

    /*  Display the form  */

    FIf_display (NFFglobal.forms[PROJM_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFdisplay_set_members (locate_flag)
  int       locate_flag;
  {
    auto    long    status, sts;
    auto    char    s[256];
    auto    char    type[5];
    auto    char    form_name[40];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFdisplay_set_members";

    /*  Get the data from the database  */

    NFFform_message (SETM_LABEL, NFI_I_RETRIEVE, NULL);

    /*  See if blocking is enabled  */

    if (NFMRglobal.query_rows > 0)
      {
        if (NFFglobal.forms[SETM_LABEL] != NULL)
          {
            /*  End the current list first  */

            if ((status = _NFFend_block_listing
                (SETM_LABEL, FALSE)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFend_block_listing = <0x%.8x>\n", status));
                NFFerase_message ();
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
          }

        _NFIdebug ((fname, "Calling NFMRdisplay_set_members_partial ...\n"));

        status = NFMRdisplay_set_members_partial
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision,
            "", "", NFMRglobal.query_rows, &synonyms, &data);
        UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
            NULL, NULL, NULL);
        if ((strcmp (type, "E")) == 0)
          {
            _NFIdebug ((fname,
                "NFMRdisplay_set_members_partial = <0x%.8x>\n", status));
            NFFerase_message ();
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
        _NFIdebug ((fname,
            "NFMRdisplay_set_members_partial = <0x%.8x>\n", status));

        strcpy (form_name, BLOCK_SETM_FORM);
      }
    else
      {
        _NFIdebug ((fname, "Calling NFMRdisplay_set_members ...\n"));
        if ((status = NFMRdisplay_set_members
            (NFFglobal.catalog, NFFglobal.item, NFFglobal.revision,
            "", "", &synonyms, &data)) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "NFMRdisplay_set_members = <0x%.8x>\n", status));
            NFFerase_message ();
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
        _NFIdebug ((fname, "NFMRdisplay_set_members = <0x%.8x>\n", status));

        strcpy (form_name, SETM_FORM);
      }

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load the form (if it's not already loaded)  */

    if (NFFglobal.forms[SETM_LABEL] == NULL)
      {
        if ((sts = FIf_new (SETM_LABEL, form_name,
            &_NFFnotify, &NFFglobal.forms[SETM_LABEL])) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", sts));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", sts);
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
            return (NFI_E_FORM);
          }
      }
    else
      {
        /*  Erase any existing data  */

        FIfld_set_num_rows (NFFglobal.forms[SETM_LABEL], MCF, 0);
      }

    /*  Put the title on the form  */

    if ((sts = (long) UMSGetByNum
        (s, NFT_P_LIST_ITEMS_IN_SET, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", sts));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "List of Set Members");
      }

    FIg_set_text (NFFglobal.forms[SETM_LABEL], LISTING_TITLE, s);

    if ((sts = _NFFlist_load_mcf (NFFglobal.forms[SETM_LABEL],
        FI_MULTI_SELECT, synonyms, data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFlist_load_mcf = <0x%.8x>\n", sts));
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", sts));
        return (sts);
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (NFFglobal.forms[SETM_LABEL], MCF, FALSE);

    /*  Disable the "More" button, if necessary  */

    if (status == NFM_I_NO_MORE_BUFFERS)
      {
        /*  This status is only returned for block listings  */

        FIg_disable (NFFglobal.forms[SETM_LABEL], NFF_MORE);
      }
    else if ((strcmp (form_name, BLOCK_SETM_FORM)) == 0)
      {
        /*  Enable the "More" button  */

        FIg_enable (NFFglobal.forms[SETM_LABEL], NFF_MORE);
      }

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (SETM_LABEL);

    /*  Display the form  */

    FIf_display (NFFglobal.forms[SETM_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFreview_item (locate_flag)
  int       locate_flag;
  {
    auto    long    status;
    auto    char    s[256];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFreview_item";

    /*  Get the data from the database  */

    NFFform_message (REVIEW_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_item_files ...\n"));
    if ((status = NFMRdisplay_item_files (NFFglobal.catalog, NFFglobal.item,
        NFFglobal.revision, "", "", &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_item_files = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_item_files = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load the form (if it's not already loaded)  */

    if (NFFglobal.forms[REVIEW_LABEL] == NULL)
      {
        if ((status = FIf_new (REVIEW_LABEL, REVIEW_FORM,
            &_NFFnotify, &NFFglobal.forms[REVIEW_LABEL])) != FI_SUCCESS)
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

        FIfld_set_num_rows (NFFglobal.forms[REVIEW_LABEL], MCF, 0);
      }

    /*  Put the title on the form  */

    if ((status = (long) UMSGetByNum (s, NFT_P_REVIEW, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "Review of");
      }

    FIg_set_text (NFFglobal.forms[REVIEW_LABEL], LISTING_TITLE, s);

    if ((status = (long) UMSGetByNum (s, NFT_P_ITEM_REV,
        "%s%s", NFFglobal.item, NFFglobal.revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (s, "Item \"%s\" Revision \"%s\"",
            NFFglobal.item, NFFglobal.revision);
      }

    FIg_erase (NFFglobal.forms[REVIEW_LABEL], LISTING_TITLE2);
    FIg_set_text (NFFglobal.forms[REVIEW_LABEL], LISTING_TITLE2, s);
    FIg_display (NFFglobal.forms[REVIEW_LABEL], LISTING_TITLE2);

    if ((status = _NFFreview_load_mcf
        (NFFglobal.forms[REVIEW_LABEL], synonyms, data)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFreview_load_mcf = <0x%.8x>\n", status));
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the vertical scroll bar, if necessary  */

    _NFFenable_scrollbar (NFFglobal.forms[REVIEW_LABEL], MCF, FALSE);

    /*  Figure out where to place the form  */

    if (locate_flag == TRUE)
        _NFFplace_form (REVIEW_LABEL);

    /*  Display the form  */

    FIf_display (NFFglobal.forms[REVIEW_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFdisplay_items_notify (f_label, g_label, row, form)
  int     f_label;
  int     g_label;
  int     row;
  Form    *form;
  {
    auto    XEvent theEvent;
    auto    int   i, sel, r_pos;
    auto    int   set_or_not = 0;
    auto    int   col = 0;
    auto    int   num_rows = 0;
    auto    char  text[20], *ptr;
    auto    char  command[15];
    auto    long  status = NFI_S_SUCCESS;
    static  char  *fname = "_NFFdisplay_items_notify";

    _NFIdebug ((fname, "f_label = %d\n", f_label));
    _NFIdebug ((fname, "g_label = %d\n", g_label));
    _NFIdebug ((fname, "row = %d\n", row));

/* PS */
    XNextEvent( NFFglobal.display, &theEvent );
    _NFIdebug(( fname, "X_Event type <%d>\n", theEvent.type ));

    switch (g_label)
      {
        case MCF:

            /*  See if any rows or columns are scrolling  */

            if (row < 0) return (status);

            switch (f_label)
              {
                case ITEMS_LABEL:
                case PROJM_LABEL:
                case SETM_LABEL:
                    FImcf_get_select (*form, g_label, row, &sel);
                    if (sel == FALSE) break;

                    /*  Get the selected catalog name (if it exists)  */

                    NFFfind_mcf_attribute (*form,
                        TOP_MCF, "n_catalogname", &col);
                    if (col != -1)
                      {
                        /*  Get the catalog name out of the MCF  */

                        FIfld_get_text (*form, g_label,
                            row, col, NFM_CATALOGNAME + 1,
                            NFFglobal.catalog, &sel, &r_pos);
                      }
                    else
                      {
                        /*  Get the catalog name out the form  */

                        _NFIdebug ((fname,
                            "getting catalog name from the form ...\n"));
                        FIf_get_user_pointer (*form, &ptr);
                        strcpy (NFFglobal.catalog, ptr);
                      }

                    FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                        CATALOG_FIELD, 0, 0, NFFglobal.catalog, FALSE);
                    _NFIdebug ((fname,
                        "catalog name = <%s>\n", NFFglobal.catalog));

                    /*  Get the selected item name  */

                    NFFfind_mcf_attribute (*form, TOP_MCF, "n_itemname", &col);
                    if (col != -1)
                      {
                        FIfld_get_text (*form, g_label,
                            row, col, NFM_ITEMNAME + 1,
                            NFFglobal.item, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ITEM_FIELD, 0, 0, NFFglobal.item, FALSE);
                        _NFIdebug ((fname,
                            "item name = <%s>\n", NFFglobal.item));
                      }
                    else
                      {
                        /*  This is bad; they made
                            item name non-readable  */

                        _NFIdebug ((fname, "couldn't find item name\n"));
                        break;
                      }

                    /*  Get the selected item revision  */

                    NFFfind_mcf_attribute (*form, TOP_MCF, "n_itemrev", &col);
                    if (col != -1)
                      {
                        FIfld_get_text (*form, g_label,
                            row, col, NFM_ITEMREV + 1,
                            NFFglobal.revision, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            REVISION_FIELD, 0, 0,
                            NFFglobal.revision, FALSE);
                        _NFIdebug ((fname,
                            "revision = <%s>\n", NFFglobal.revision));
                      }
                    else
                      {
                        /*  This is bad; they
                            made revision non-readable  */

                        _NFIdebug ((fname, "couldn't find revision\n"));
                        break;
                      }

                    /*  Find out if it is a set  */

                    NFFfind_mcf_attribute (*form,
                        TOP_MCF, "n_setindicator", &col);
                    if (col != -1)
                      {
                        FIfld_get_text (*form, g_label,
                            row, col, NFM_SETINDICATOR + 1,
                            NFFglobal.set_indicator, &sel, &r_pos);
                        _NFIdebug ((fname, "set_indicator = <%s>\n",
                            NFFglobal.set_indicator));
                        if ((strcmp (NFFglobal.set_indicator, "")) != 0)
                          {
                            strcpy (text, "Set Name");
                            status = NFI_I_SET_SELECTED;
                            ERRload_struct (NFI, status, NULL);
                          }
                        else
                          {
                            /*  Make sure the
                                previous item was not a set  */

                            strcpy (text, "Item Name");
                          }

                        (void) _NFFalter_item_text_label (text);
                      }
                    else
                      {
                        /*  This is bad; they made
                            set indicator non-readable  */

                        _NFIdebug ((fname,
                            "couldn't find set indicator\n"));
                        _NFIdebug ((fname,
                            "call NFFvalid_revision\n"));

                        strcpy (NFFglobal.set_indicator, "");
                        _NFFvalid_revision (NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision, &set_or_not);
                        if (set_or_not == TRUE)
                          {
                            strcpy (NFFglobal.set_indicator, "Y");
                            strcpy (text, "Set Name");
                            status = NFI_I_SET_SELECTED;
                            ERRload_struct (NFI, status, NULL);
                          }
                        else
                          {
                            /*  Make sure the previous item was not a set  */

                            strcpy (text, "Item Name");
                          }

                        (void) _NFFalter_item_text_label (text);
                      }

                    break;

                case REVIEW_LABEL:
                    _NFIdebug ((fname, "On Review Form\n"));
                    break;
              }

            break;

        case NFF_EXECUTE:

            switch (f_label)
              {
                case ITEMS_LABEL:
                    status = NFFdisplay_items (FALSE);
                    break;

                case REVIEW_LABEL:
                    status = NFFreview_item (FALSE);
                    break;

                case PROJM_LABEL:
                    status = NFFdisplay_project_members (FALSE);
                    break;

                case SETM_LABEL:
                    status = NFFdisplay_set_members (FALSE);
                    break;
              }

            break;

        case NFF_HELP:

            switch (f_label)
              {
                case ITEMS_LABEL:
                    strcpy (command, NFI_M_DISPLAY_ITEMS);
                    break;

                case REVIEW_LABEL:
                    strcpy (command, NFI_M_REVIEW_ITEM_ATTRIBUTES);
                    break;

                case PROJM_LABEL:
                    strcpy (command, NFI_M_DISPLAY_ITEMS_IN_PROJECT);
                    break;

                case SETM_LABEL:
                    strcpy (command, NFI_M_DISPLAY_SET_MEMBERS);
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
            status = _NFFend_block_listing (f_label, FALSE);
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

        case NFF_MORE:
            status = _NFFmore_data (f_label, NFMRglobal.query_rows);
            break;
      }

    _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
    return (status);
  }


long _NFFmore_data (f_label, rows)
  int     f_label;
  int     rows;
  {
    auto    int     col = -1;
    auto    int     num_rows = 0;
    auto    long    sts, status = NFI_S_SUCCESS;
    auto    char    type[5];
    auto    Form    form = NULL;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "_NFFmore_data";

    _NFIdebug ((fname, "f_label = %d\n", f_label));

    form = NFFglobal.forms[f_label];

    /*  Get more data from the database  */

    NFFform_message (f_label, NFI_I_RETRIEVE, NULL);

    switch (f_label)
      {
        case BLOCK_ITEMS_POPUP_LABEL:

            /*  This is the popup form  */

            form = NFFglobal.popup_form;

            _NFIdebug ((fname, "Calling NFMRdisplay_items_partial ...\n"));

            status = NFMRdisplay_items_partial
                (NFFglobal.catalog, "", "", 1, rows, &synonyms, &data);
            UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                NULL, NULL, NULL);
            if ((strcmp (type, "E")) == 0)
              {
                _NFIdebug ((fname,
                    "NFMRdisplay_items_partial = <0x%.8x>\n", status));
                NFFerase_message ();
                MEMclose (&synonyms);
                MEMclose (&data);
                FIg_disable (form, NFF_MORE);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname,
                "NFMRdisplay_items_partial = <0x%.8x>\n", status));

            break;

        case ITEMS_LABEL:
            NFFfind_mcf_attribute (form, TOP_MCF, "n_catalogname", &col);
            if (col == -1)
              {
                /*  This is a single catalog listing  */

                _NFIdebug ((fname, "Calling NFMRdisplay_items_partial ...\n"));

                status = NFMRdisplay_items_partial
                    (NFFglobal.catalog, "", "", 0, rows, &synonyms, &data);
                UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                    NULL, NULL, NULL);
                if ((strcmp (type, "E")) == 0)
                  {
                    _NFIdebug ((fname,
                        "NFMRdisplay_items_partial = <0x%.8x>\n", status));
                    NFFerase_message ();
                    MEMclose (&synonyms);
                    MEMclose (&data);
                    FIg_disable (form, NFF_MORE);
                    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                    return (status);
                  }
                _NFIdebug ((fname,
                    "NFMRdisplay_items_partial = <0x%.8x>\n", status));
              }
            else
              {
                /*  This is a multi-catalog listing  */

                _NFIdebug ((fname,
                    "Calling NFMRblock_multiple_catalog_search ...\n"));

                status = NFMRblock_multiple_catalog_search
                    (NULL, "", "", &data, &synonyms, rows);
                UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                    NULL, NULL, NULL);
                if ((strcmp (type, "E")) == 0)
                  {
                    _NFIdebug ((fname,
                        "NFMRblock_multiple_catalog_search = <0x%.8x>\n",
                        status));
                    NFFerase_message ();
                    MEMclose (&synonyms);
                    MEMclose (&data);
                    FIg_disable (form, NFF_MORE);
                    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                    return (status);
                  }
                _NFIdebug ((fname,
                    "NFMRblock_multiple_catalog_search = <0x%.8x>\n", status));
              }

            break;

        case PROJM_LABEL:

            _NFIdebug ((fname,
                "Calling NFMRdisplay_project_members_partial ...\n"));

            status = NFMRdisplay_project_members_partial
                (NFFglobal.project, "", "", rows, &synonyms, &data);
            UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                NULL, NULL, NULL);
            if ((strcmp (type, "E")) == 0)
              {
                _NFIdebug ((fname,
                    "NFMRdisplay_project_members_partial = <0x%.8x>\n",
                    status));
                NFFerase_message ();
                MEMclose (&synonyms);
                MEMclose (&data);
                FIg_disable (form, NFF_MORE);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname,
                "NFMRdisplay_project_members_partial = <0x%.8x>\n", status));

            break;

        case SETM_LABEL:

            _NFIdebug ((fname,
                "Calling NFMRdisplay_set_members_partial ...\n"));

            status = NFMRdisplay_set_members_partial
                (NFFglobal.catalog, NFFglobal.item,
                NFFglobal.revision, "", "", rows, &synonyms, &data);
            UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                NULL, NULL, NULL);
            if ((strcmp (type, "E")) == 0)
              {
                _NFIdebug ((fname,
                    "NFMRdisplay_set_members_partial = <0x%.8x>\n", status));
                NFFerase_message ();
                MEMclose (&synonyms);
                MEMclose (&data);
                FIg_disable (form, NFF_MORE);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname,
                "NFMRdisplay_set_members_partial = <0x%.8x>\n", status));

            break;
      }

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("", synonyms, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);
      }

    if (data != NULL)
      {
        if ((sts = MEMbuild_array (data)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", sts));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", sts);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }

        /*  Append the new data to the old in the MCF  */

        FIfld_get_num_rows (form, MCF, &num_rows);
        if ((sts = _NFFlist_load_mcf_data
            (form, num_rows, synonyms, data)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFlist_load_mcf_data = <0x%.8x>\n", sts));
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (sts);
          }
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Enable the scroll bar, if necessary  */

    _NFFenable_scrollbar (form, MCF, TRUE);

    /*  Disable the "More" button, if necessary  */

    if (status == NFM_I_NO_MORE_BUFFERS)
      {
        /*  This status is only returned for block listings  */

        FIg_disable (form, NFF_MORE);
      }

    _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
    return (status);
  }


long _NFFend_block_listing (f_label, load_message)
  int     f_label;
  int     load_message;  /*  i - load warning message (TRUE or FALSE)  */
  {
    auto    int     col = -1;
    auto    int     attr_mask = 0;
    auto    long    status = NFI_S_SUCCESS;
    auto    char    type[5];
    auto    Form    form = NULL;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *fname = "_NFFend_block_listing";

    _NFIdebug ((fname, "f_label = %d\n", f_label));

    form = NFFglobal.forms[f_label];

    switch (f_label)
      {
        case BLOCK_ITEMS_POPUP_LABEL:

            /*  This is the popup form  */

            form = NFFglobal.popup_form;

            _NFIdebug ((fname, "Calling NFMRdisplay_items_partial ...\n"));

            status = NFMRdisplay_items_partial
                (NFFglobal.catalog, "", "", 1, 0, &synonyms, &data);
            UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                NULL, NULL, NULL);
            if ((strcmp (type, "E")) == 0)
              {
                _NFIdebug ((fname,
                    "NFMRdisplay_items_partial = <0x%.8x>\n", status));
                MEMclose (&synonyms);
                MEMclose (&data);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname,
                "NFMRdisplay_items_partial = <0x%.8x>\n", status));

            break;

        case ITEMS_LABEL:
            NFFfind_mcf_attribute (form, TOP_MCF, "n_catalogname", &col);
            if (col == -1)
              {
                /*  This is a single catalog listing  */

                _NFIdebug ((fname, "Calling NFMRdisplay_items_partial ...\n"));

                status = NFMRdisplay_items_partial
                    (NFFglobal.catalog, "", "", 0, 0, &synonyms, &data);
                UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                    NULL, NULL, NULL);
                if ((strcmp (type, "E")) == 0)
                  {
                    _NFIdebug ((fname,
                        "NFMRdisplay_items_partial = <0x%.8x>\n", status));
                    MEMclose (&synonyms);
                    MEMclose (&data);
                    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                    return (status);
                  }
                _NFIdebug ((fname,
                    "NFMRdisplay_items_partial = <0x%.8x>\n", status));
              }
            else
              {
                /*  This is a multi-catalog listing  */

                _NFIdebug ((fname,
                    "Calling NFMRblock_multiple_catalog_search ...\n"));

                status = NFMRblock_multiple_catalog_search
                    (NULL, "", "", &data, &synonyms, 0);
                UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                    NULL, NULL, NULL);
                if ((strcmp (type, "E")) == 0)
                  {
                    _NFIdebug ((fname,
                        "NFMRblock_multiple_catalog_search = <0x%.8x>\n",
                        status));
                    MEMclose (&synonyms);
                    MEMclose (&data);
                    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                    return (status);
                  }
                _NFIdebug ((fname,
                    "NFMRblock_multiple_catalog_search = <0x%.8x>\n", status));
              }

            break;

        case PROJM_LABEL:

            _NFIdebug ((fname,
                "Calling NFMRdisplay_project_members_partial ...\n"));

            status = NFMRdisplay_project_members_partial
                (NFFglobal.project, "", "", 0, &synonyms, &data);
            UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                NULL, NULL, NULL);
            if ((strcmp (type, "E")) == 0)
              {
                _NFIdebug ((fname,
                    "NFMRdisplay_project_members_partial = <0x%.8x>\n",
                    status));
                MEMclose (&synonyms);
                MEMclose (&data);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname,
                "NFMRdisplay_project_members_partial = <0x%.8x>\n", status));

            break;

        case SETM_LABEL:

            _NFIdebug ((fname,
                "Calling NFMRdisplay_set_members_partial ...\n"));

            status = NFMRdisplay_set_members_partial
                (NFFglobal.catalog, NFFglobal.item,
                NFFglobal.revision, "", "", 0, &synonyms, &data);
            UMSMsgCode (type, status, UMS_SUPPRESS_COMP | UMS_SUPPRESS_EXT,
                NULL, NULL, NULL);
            if ((strcmp (type, "E")) == 0)
              {
                _NFIdebug ((fname,
                    "NFMRdisplay_set_members_partial = <0x%.8x>\n", status));
                MEMclose (&synonyms);
                MEMclose (&data);
                _NFIdebug ((fname, "returning <0x%.8x>\n", status));
                return (status);
              }
            _NFIdebug ((fname,
                "NFMRdisplay_set_members_partial = <0x%.8x>\n", status));

            break;
      }

    MEMclose (&synonyms);
    MEMclose (&data);

    /*  Disable the "More" button  */

    status = NFI_S_SUCCESS;
    FIg_get_attr (form, NFF_MORE, &attr_mask);
    if ((attr_mask & FI_NOT_ENABLED) == 0)
      {
        FIg_disable (form, NFF_MORE);

        if (load_message == TRUE)
          {
            status = NFI_W_END_LISTING;
            ERRload_struct (NFI, status, NULL);
          }
      }

    _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
    return (status);
  }


void _NFFenable_scrollbar (form, label, scroll_at_bottom)
  Form    form;
  int     label;
  int     scroll_at_bottom;  /*  i - position scrollbar at bottom
                                     of viewing area (TRUE or FALSE)  */
  {
    auto    int    num_rows = 0;
    auto    int    vis_rows = 0;
    auto    int    attr_mask = 0;
    static  char   *fname = "_NFFenable_scrollbar";

    _NFIdebug ((fname, "label = <%d>\n", label));

    FIfld_get_num_rows (form, label, &num_rows);
    FIfld_get_num_vis_rows (form, label, &vis_rows);
    FImcf_get_attr (form, label, &attr_mask);
    if (num_rows > vis_rows)
      {
        /*  OR in the vertical scroll bar attribute  */

        attr_mask |= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
        _NFIdebug ((fname, "enabling scrollbar ...\n"));

        /*  Check the position flag  */

        if (scroll_at_bottom == TRUE)
          {
            /*  Put the last row at the bottom of the visible area  */

            FIfld_set_active_row (form, label, num_rows - 1, vis_rows - 1);
          }
      }
    else
      {
        /*  Take out the vertical scroll bar attribute  */

        if (attr_mask & (FI_VERT_SCROLL | FI_DISPLAY_VSCROLL))
            attr_mask ^= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
        _NFIdebug ((fname, "disabling scrollbar ...\n"));
      }

    FImcf_set_attr (form, label, attr_mask);
    FIg_display (form, label);

    _NFIdebug ((fname, "returning ...\n"));
  }
