
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFlogin.h"
#include "NFFmain_form.h"

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

long NFFserver_popup ()
  {
    auto    int     f_label = SERVERS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_SERVERS;
    auto    char    title[256];
    auto    long    status;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of I/NFM Servers";
    static  char    *fname = "NFFserver_popup";

    /*  Get the data from the clearinghouse  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMls_nodes ...\n"));
    if ((status = NFMls_nodes ("nfms_", &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMls_nodes = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMls_nodes = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum (title, t_label, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFenv_popup ()
  {
    auto    int     f_label = ENVS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_ENVS;
    auto    char    title[256];
    auto    long    status;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of I/NFM Environments";
    static  char    *fname = "NFFenv_popup";

    /*  Get the data from the clearinghouse  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMls_nodes ...\n"));
    if ((status = NFMls_nodes ("nfme_", &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMls_nodes = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMls_nodes = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum (title, t_label, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFproject_popup ()
  {
    auto    int     f_label = PROJECTS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_PROJECTS;
    auto    char    title[256];
    auto    long    status;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of I/NFM Projects";
    static  char    *fname = "NFFproject_popup";

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_projects ...\n"));
    if ((status = NFMRdisplay_projects
        ("", "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFcatalog_popup ()
  {
    auto    int     f_label = CATALOGS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_CATALOGS;
    auto    char    title[256];
    auto    long    status;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of I/NFM Catalogs";
    static  char    *fname = "NFFcatalog_popup";

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_catalogs ...\n"));
    if ((status = NFMRdisplay_catalogs
        ("nfmcatalogs.n_catalogname NOT LIKE '%_rl'", "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFitem_popup ()
  {
    auto    int     f_label = ITEMS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_ITEMS;
    auto    char    title[256];
    auto    char    type[5];
    auto    long    status, sts;
    auto    char    search[NFM_REPORTNAME + 1];
    auto    char    sort[NFM_REPORTNAME + 1];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of Items";
    static  char    *fname = "NFFitem_popup";

    if ((strcmp (NFFglobal.catalog, "")) == 0)
      {
        ERRload_struct (NFI, NFI_E_NO_CATALOG, NULL);
        return (NFI_E_NO_CATALOG);
      }

    /*  Load the active search and sort criteria  */

    if (NFFglobal.search_active == TRUE)
        strcpy (search, NFFglobal.search);
    else
        strcpy (search, "");

    if (NFFglobal.sort_active == TRUE)
        strcpy (sort, NFFglobal.sort);
    else
        strcpy (sort, "");

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    /*  See if blocking is enabled  */

    if (NFMRglobal.query_rows > 0)
      {
        _NFIdebug ((fname, "Calling NFMRdisplay_items_partial ...\n"));
        status = NFMRdisplay_items_partial
            (NFFglobal.catalog, search, sort, 1,
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
        _NFIdebug ((fname, "NFMRdisplay_items_partial = <0x%.8x>\n", status));

        f_label = BLOCK_ITEMS_POPUP_LABEL;
      }
    else
      {
        _NFIdebug ((fname, "Calling NFMRdisplay_items ...\n"));
        if ((status = NFMRdisplay_items (NFFglobal.catalog,
            search, sort, 1, &synonyms, &data)) != NFM_S_SUCCESS)
          {
            _NFIdebug ((fname, "NFMRdisplay_items = <0x%.8x>\n", status));
            NFFerase_message ();
            MEMclose (&synonyms);
            MEMclose (&data);
            _NFIdebug ((fname, "returning <0x%.8x>\n", status));
            return (status);
          }
        _NFIdebug ((fname, "NFMRdisplay_items = <0x%.8x>\n", status));
      }

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((sts = (long) UMSGetByNum (title, t_label, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", sts));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((sts = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", sts));

    MEMclose (&data);

    /*  Disable the "More" button, if necessary  */

    if (status == NFM_I_NO_MORE_BUFFERS)
      {
        /*  This status is only returned for block listings  */

        FIg_disable (NFFglobal.popup_form, NFF_MORE);
        FIg_display (NFFglobal.popup_form, NFF_MORE);
      }

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFrevision_popup ()
  {
    auto    int     f_label = REVISIONS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_REV;
    auto    char    title[256];
    auto    long    status;
    auto    char    search[NFF_MAX_MESSAGE];
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of Item Revisions";
    static  char    *fname = "NFFrevision_popup";

    if ((strcmp (NFFglobal.catalog, "")) == 0)
      {
        ERRload_struct (NFI, NFI_E_NO_CATALOG, NULL);
        return (NFI_E_NO_CATALOG);
      }
    else if ((strcmp (NFFglobal.item, "")) == 0)
      {
        ERRload_struct (NFI, NFI_E_NO_ITEM, NULL);
        return (NFI_E_NO_ITEM);
      }

    /*  Only get the revisions of the active item  */

    sprintf (search, "n_itemname = '%s'", NFFglobal.item);

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_items ...\n"));
    if ((status = NFMRdisplay_items (NFFglobal.catalog,
        search, "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRdisplay_items = <0x%.8x>\n", status));
        NFFerase_message ();
        MEMclose (&synonyms);
        MEMclose (&data);
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }
    _NFIdebug ((fname, "NFMRdisplay_items = <0x%.8x>\n", status));

    NFFerase_message ();

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer ("", data, _NFMdebug_st.NFIdebug_file);

    /*  We're not using this buffer  */

    MEMclose (&synonyms);

    /*  Get the form title  */

    if ((status = (long) UMSGetByNum
		(title, t_label, "%s", NFFglobal.item)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFsearch_popup ()
  {
    auto    int     f_label = SEARCH_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_SEARCH;
    auto    char    title[256];
    auto    long    status;
    auto    char    search[256] = "";
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of Search Criteria Names";
    static  char    *fname = "NFFsearch_popup";

    /*  Make sure the user only sees search criteria
        that either he owns or that are owned by PUBLIC  */

    if (NFMRglobal.administrator == FALSE)
      {
        sprintf (search, "n_owner IN (SELECT n_userno FROM nfmusers\
            WHERE n_username = '%s' OR n_username = 'PUBLIC')",
            NFFglobal.username);
      }

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_querys ...\n"));
    if ((status = NFMRdisplay_querys
        ("W", search, "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFsort_popup ()
  {
    auto    int     f_label = SORT_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_SORT;
    auto    char    title[256];
    auto    long    status;
    auto    char    search[256] = "";
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of Sort Criteria Names";
    static  char    *fname = "NFFsort_popup";

    /*  Make sure the user only sees search criteria
        that either he owns or that are owned by PUBLIC  */

    if (NFMRglobal.administrator == FALSE)
      {
        sprintf (search, "n_owner IN (SELECT n_userno FROM nfmusers\
            WHERE n_username = '%s' OR n_username = 'PUBLIC')",
            NFFglobal.username);
      }

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_querys ...\n"));
    if ((status = NFMRdisplay_querys
        ("O", search, "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFwa_popup ()
  {
    auto    int     f_label = WORKING_AREAS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_WA;
    auto    char    title[256];
    auto    long    status;
    auto    char    search[256] = "";
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of I/NFM Working Areas";
    static  char    *fname = "NFFwa_popup";

    /*  Make sure the user only sees search criteria
        that either he owns or that are owned by PUBLIC  */

    _NFIdebug(( fname, "Administrator <%d>\n", NFMRglobal.administrator ));
    if (NFMRglobal.administrator == FALSE)
      {
        sprintf (search, "n_owner IN (SELECT n_userno FROM nfmusers\
            WHERE n_username = '%s' OR n_username = 'PUBLIC')",
            NFFglobal.username);
      }

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_working_areas ...\n"));
    if ((status = NFMRdisplay_working_areas
        (search, "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFsa_popup ()
  {
    auto    int     f_label = STORAGE_AREAS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_SA;
    auto    char    title[256];
    auto    long    status;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of I/NFM Storage Areas";
    static  char    *fname = "NFFsa_popup";

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_storage_areas ...\n"));
    if ((status = NFMRdisplay_storage_areas
        ("", "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFnode_popup ()
  {
    auto    int     f_label = NODES_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_NODES;
    auto    char    title[256];
    auto    long    status;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of I/NFM Nodes";
    static  char    *fname = "NFFnode_popup";

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_nodes ...\n"));
    if ((status = NFMRdisplay_nodes
        ("", "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFuser_popup ()
  {
    auto    int     f_label = USERS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_USERS;
    auto    char    title[256];
    auto    long    status;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of I/NFM Users";
    static  char    *fname = "NFFuser_popup";

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_users ...\n"));
    if ((status = NFMRdisplay_users
        ("", "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFwf_popup ()
  {
    auto    int     f_label = WORKFLOWS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_WF;
    auto    char    title[256];
    auto    long    status;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of I/NFM Workflows";
    static  char    *fname = "NFFwf_popup";

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_workflows ...\n"));
    if ((status = NFMRdisplay_workflows
        ("", "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long NFFacl_popup ()
  {
    auto    int     f_label = ACLS_POPUP_LABEL;
    auto    int     t_label = NFT_P_LIST_ACL;
    auto    char    title[256];
    auto    long    status;
    auto    MEMptr  synonyms = NULL;
    auto    MEMptr  data = NULL;
    static  char    *default_title = "List of ACLs";
    static  char    *fname = "NFFacl_popup";

    if ((strcmp (NFFglobal.workflow, "")) == 0)
      {
        ERRload_struct (NFI, NFI_E_NO_WF, NULL);
        return (NFI_E_NO_WF);
      }

    /*  Get the data from the database  */

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "Calling NFMRdisplay_acls ...\n"));
    if ((status = NFMRdisplay_acls (NFFglobal.workflow,
        "", "", 1, &synonyms, &data)) != NFM_S_SUCCESS)
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
        strcpy (title, default_title);
      }

    /*  Load the popup form  */

    if ((status = _NFFload_popup
        (f_label, title, data)) != NFI_S_SUCCESS)
        _NFIdebug ((fname, "_NFFload_popup = <0x%.8x>\n", status));

    MEMclose (&data);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFload_popup (f_label, title, data)
  int     f_label;
  char    *title;
  MEMptr  data;
  {
    auto    int     row;
    auto    int     num_cols;
    auto    int     num_rows;
    auto    int     vis_rows;
    auto    int     attr_mask;
    auto    int     vis_chars1 = 0;
    auto    int     vis_chars2 = 0;
    auto    long    status;
    auto    short   enable_col1 = FALSE;
    auto    short   enable_col2 = FALSE;
    auto    char    form_name[20];
    auto    char    **data_ptr;
    static  char    *fname = "_NFFload_popup";

    _NFIdebug ((fname, "f_label = <%d>\n", f_label));

    if ((status = MEMbuild_array (data)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
      }

    data_ptr = (char **) data->data_ptr;

    /*  Load the form  */

    switch (f_label)
      {
        case BLOCK_ITEMS_POPUP_LABEL:
            strcpy (form_name, BLOCK_POPUP_ITEMS_FORM);
            num_cols = 3;
            break;

        case ITEMS_POPUP_LABEL:
            strcpy (form_name, POPUP_ITEMS_FORM);
            num_cols = 3;
            break;

        case REVISIONS_POPUP_LABEL:
            strcpy (form_name, POPUP_FORM);
            num_cols = 3;
            break;

        case SERVERS_POPUP_LABEL:
        case ENVS_POPUP_LABEL:
            strcpy (form_name, POPUP_FORM);
            num_cols = 1;
            break;

        default:
            strcpy (form_name, POPUP_FORM);
            num_cols = 2;
            break;
      }

    if ((status = FIf_new (f_label, form_name,
        &_NFFnotify, &NFFglobal.popup_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
        return (NFI_E_FORM);
      }

    FIfld_get_num_vis_chars (NFFglobal.popup_form, FIELD, 0, &vis_chars1);
    _NFIdebug ((fname, "vis_chars1 = <%d>\n", vis_chars1));

    if ((f_label == ITEMS_POPUP_LABEL) || (f_label == BLOCK_ITEMS_POPUP_LABEL))
      {
        FIfld_get_num_vis_chars
            (NFFglobal.popup_form, FIELD, 1, &vis_chars2);
        _NFIdebug ((fname, "vis_chars2 = <%d>\n", vis_chars2));
      }

    /*  Put the data into the form  */
#ifdef OS_SCO_UNIX
    /* work around change added 1 line SSRS 1 Feb 94 */
    FIg_set_font( NFFglobal.popup_form, FIELD, "7x13bold", 15 );
#endif

    for (row = 0; row < data->rows; ++row)
      {
        switch (f_label)
          {
            case SERVERS_POPUP_LABEL:
            case ENVS_POPUP_LABEL:
                _NFIdebug ((fname, "Setting <%s> in row %d\n",
                    data_ptr[row * num_cols], row));


                FIfld_set_text (NFFglobal.popup_form,
                    FIELD, row, 0, data_ptr[row * num_cols], FALSE);

                if (strlen (data_ptr[row * num_cols]) > vis_chars1)
                    enable_col1 = TRUE;

                break;

            case REVISIONS_POPUP_LABEL:
                _NFIdebug ((fname, "Setting <%s> in row %d\n",
                    data_ptr[(row * num_cols) + 2], row));

                FIfld_set_text (NFFglobal.popup_form,
                    FIELD, row, 0, data_ptr[(row * num_cols) + 2], FALSE);

                if (strlen (data_ptr[(row * num_cols) + 2]) > vis_chars1)
                    enable_col1 = TRUE;

                break;

            case BLOCK_ITEMS_POPUP_LABEL:
            case ITEMS_POPUP_LABEL:
                _NFIdebug ((fname, "Setting <%s> in row %d\n",
                    data_ptr[(row * num_cols) + 2], row));

                FIfld_set_text (NFFglobal.popup_form,
                    FIELD, row, 1, data_ptr[(row * num_cols) + 2], FALSE);

                if (strlen (data_ptr[(row * num_cols) + 2]) > vis_chars2)
                    enable_col2 = TRUE;

                /*  Drop thru here  */

            default:
                _NFIdebug ((fname, "Setting <%s> in row %d\n",
                    data_ptr[(row * num_cols) + 1], row));

                FIfld_set_text (NFFglobal.popup_form,
                    FIELD, row, 0, data_ptr[(row * num_cols) + 1], FALSE);

                if (strlen (data_ptr[(row * num_cols) + 1]) > vis_chars1)
                    enable_col1 = TRUE;

                break;
          }
      }

    /*  Put the title on the form  */

    FIg_set_text (NFFglobal.popup_form, POPUP_TITLE, title);

    /*  Enable the scroll bar, if necessary  */

    FIfld_get_num_rows (NFFglobal.popup_form, FIELD, &num_rows);
    FIfld_get_num_vis_rows (NFFglobal.popup_form, FIELD, &vis_rows);

    if ((f_label == ITEMS_POPUP_LABEL) || (f_label == BLOCK_ITEMS_POPUP_LABEL))
        FImcf_get_attr (NFFglobal.popup_form, FIELD, &attr_mask);
    else
        FIfld_get_attr (NFFglobal.popup_form, FIELD, 0, &attr_mask);

    if (num_rows > vis_rows)
      {
        /*  OR in the vertical scroll bar attribute  */

        attr_mask |= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }
    else
      {
        /*  Take out the vertical scroll bar attribute  */

#ifdef OS_HPUX
	    /* Only FI_DISPLAY_VSCROLL is disabled as the combination is
               giving blank popup form. Could be some Xforms problem.
	       Work around change IGI 29/06/94  */
            attr_mask &= ~FI_DISPLAY_VSCROLL;
#else
        if (attr_mask & (FI_VERT_SCROLL | FI_DISPLAY_VSCROLL))
            attr_mask ^= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
#endif

      }

    if ((f_label == ITEMS_POPUP_LABEL) || (f_label == BLOCK_ITEMS_POPUP_LABEL))
        FImcf_set_attr (NFFglobal.popup_form, FIELD, attr_mask);
    else
        FIfld_set_attr (NFFglobal.popup_form, FIELD, 0, attr_mask);

    /*  Enable the character scroll bars, if necessary  */

    FIfld_get_attr (NFFglobal.popup_form, FIELD, 0, &attr_mask);

    if (enable_col1 == TRUE)
      {
        /*  OR in the character scroll bars attribute  */

        _NFIdebug ((fname, "enabling character scrolling for col1\n"));
        attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
      }
    else
      {
        /*  Take out the character scroll bars attribute  */

        _NFIdebug ((fname, "disabling character scrolling for col1\n"));
        if (attr_mask & (FI_HORT_SCROLL | FI_DISPLAY_HSCROLL))
            attr_mask ^= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
      }

    FIfld_set_attr (NFFglobal.popup_form, FIELD, 0, attr_mask);

    if ((f_label == ITEMS_POPUP_LABEL) || (f_label == BLOCK_ITEMS_POPUP_LABEL))
      {
        FIfld_get_attr (NFFglobal.popup_form, FIELD, 1, &attr_mask);

        if (enable_col2 == TRUE)
          {
            /*  OR in the character scroll bars attribute  */

            _NFIdebug ((fname, "enabling character scrolling for col2\n"));
            attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
          }
        else
          {
            /*  Take out the character scroll bars attribute  */

            _NFIdebug ((fname, "disabling character scrolling for col1\n"));
            if (attr_mask & (FI_HORT_SCROLL | FI_DISPLAY_HSCROLL))
                attr_mask ^= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;
          }

        FIfld_set_attr (NFFglobal.popup_form, FIELD, 1, attr_mask);
      }

    /*  Center the field on the form  */

    _NFFcenter_gadget (NFFglobal.popup_form, FIELD);

    /*  Display the form  */

    FIf_display (NFFglobal.popup_form);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFpopup_notify (f_label, g_label, row, form)
  int     f_label;
  int     g_label;
  int     row;
  Form    *form;
  {
    auto    int   sel, r_pos;
    auto    int   set_or_not = FALSE;
    auto    long  status = NFI_S_SUCCESS;
    auto    Form  button_form = NULL;
    auto    char  s[40], text[20];
    static  char  *fname = "_NFFpopup_notify";

    _NFIdebug ((fname, "f_label = %d\n", f_label));
    _NFIdebug ((fname, "g_label = %d\n", g_label));
    _NFIdebug ((fname, "row = %d\n", row));

    switch (g_label)
      {
        case FIELD:

            /*  See if any rows are scrolling  */

            if (row < 0) return (status);

            switch (f_label)
              {
                case SERVERS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            sizeof (s), s, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.current_form,
                            SERVER_FIELD, 0, 0, s, FALSE);
                        _NFIdebug ((fname, "server name = <%s>\n", s));
                      }

                    break;

                case ENVS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            sizeof (s), s, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.current_form,
                            ENV_FIELD, 0, 0, s, FALSE);
                        _NFIdebug ((fname, "environment name = <%s>\n", s));
                      }

                    break;

                case PROJECTS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_PROJECTNAME + 1, NFFglobal.project,
                            &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            PROJECT_FIELD, 0, 0, NFFglobal.project, FALSE);
                        _NFIdebug ((fname,
                            "project name = <%s>\n", NFFglobal.project));
                      }

                    break;

                case CATALOGS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_CATALOGNAME + 1, NFFglobal.catalog,
                            &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            CATALOG_FIELD, 0, 0, NFFglobal.catalog, FALSE);
                        _NFIdebug ((fname,
                            "catalog name = <%s>\n", NFFglobal.catalog));

                        /*  Clear out the itemname and revision  */

                        strcpy (NFFglobal.item, "");
                        strcpy (NFFglobal.revision, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ITEM_FIELD, 0, 0, NFFglobal.item, FALSE);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            REVISION_FIELD, 0, 0, NFFglobal.revision, FALSE);
			_NFFalter_item_text_label ("Item Name");
			strcpy (NFFglobal.set_indicator, "" );
                      }
                    break;

                case BLOCK_ITEMS_POPUP_LABEL:
                case ITEMS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == FALSE) break;

                    /*  Get the selected item name  */

                    FIfld_get_text (*form, g_label, row, 0,
                        NFM_ITEMNAME + 1, NFFglobal.item, &sel, &r_pos);
                    FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                        ITEM_FIELD, 0, 0, NFFglobal.item, FALSE);
                    _NFIdebug ((fname, "item name = <%s>\n", NFFglobal.item));

                    /*  Get the selected item revision  */

                    FIfld_get_text (*form, g_label, row, 1,
                        NFM_ITEMREV + 1, NFFglobal.revision, &sel, &r_pos);
                    FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                        REVISION_FIELD, 0, 0, NFFglobal.revision, FALSE);
                    _NFIdebug ((fname,
                        "revision = <%s>\n", NFFglobal.revision));

                    /*  Find out if it is a set  */

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

                    if (f_label == BLOCK_ITEMS_POPUP_LABEL)
                      {
                        /*  Cleanup the block listing  */

                        status = _NFFend_block_listing (f_label, FALSE);
                      }

                    break;

                case REVISIONS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_ITEMREV + 1, NFFglobal.revision, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            REVISION_FIELD, 0, 0, NFFglobal.revision, FALSE);
                        _NFIdebug ((fname,
                            "revision = <%s>\n", NFFglobal.revision));

                        /*  Find out if it is a set  */

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

                case SEARCH_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_REPORTNAME + 1, NFFglobal.search,
                            &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SEARCH_FIELD, 0, 0, NFFglobal.search, FALSE);
                        _NFIdebug ((fname,
                            "search name = <%s>\n", NFFglobal.search));
                      }

                    break;

                case SORT_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_REPORTNAME + 1, NFFglobal.sort, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SORT_FIELD, 0, 0, NFFglobal.sort, FALSE);
                        _NFIdebug ((fname,
                            "sort name = <%s>\n", NFFglobal.sort));
                      }

                    break;

                case WORKING_AREAS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_SANAME + 1, NFFglobal.working_area,
                            &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            WA_FIELD, 0, 0, NFFglobal.working_area, FALSE);
                        _NFIdebug ((fname, "working area name = <%s>\n",
                            NFFglobal.working_area));
                      }

                    break;

                case NODES_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_NODENAME + 1, NFFglobal.node, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            NODE_FIELD, 0, 0, NFFglobal.node, FALSE);
                        _NFIdebug ((fname,
                            "nodename = <%s>\n", NFFglobal.node));
                      }

                    break;

                case STORAGE_AREAS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_SANAME + 1, NFFglobal.storage_area,
                            &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            SA_FIELD, 0, 0, NFFglobal.storage_area, FALSE);
                        _NFIdebug ((fname, "storage area name = <%s>\n",
                            NFFglobal.storage_area));
                      }

                    break;

                case USERS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_USERNAME + 1, NFFglobal.user, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            USER_FIELD, 0, 0, NFFglobal.user, FALSE);
                        _NFIdebug ((fname,
                            "username = <%s>\n", NFFglobal.user));
                      }

                    break;

                case WORKFLOWS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text
                            (*form, g_label, row, 0, NFM_WORKFLOWNAME + 1,
                            NFFglobal.workflow, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            WF_FIELD, 0, 0, NFFglobal.workflow, FALSE);
                        _NFIdebug ((fname,
                            "workflow name = <%s>\n", NFFglobal.workflow));

                        /*  Clear out the acl name  */

                        strcpy (NFFglobal.acl, "");
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ACL_FIELD, 0, 0, NFFglobal.acl, FALSE);
                      }

                    break;

                case ACLS_POPUP_LABEL:
                    FIfld_get_select (*form, g_label, row, 0, &sel);
                    if (sel == TRUE)
                      {
                        FIfld_get_text (*form, g_label, row, 0,
                            NFM_ACLNAME + 1, NFFglobal.acl, &sel, &r_pos);
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            ACL_FIELD, 0, 0, NFFglobal.acl, FALSE);
                        _NFIdebug ((fname,
                            "acl name = <%s>\n", NFFglobal.acl));
                      }

                    break;
              }

        /*  No break here; after the field is selected,
            it will drop thru to here and delete the form  */

        case NFF_CANCEL:
        case FI_CANCEL:

            if (f_label == BLOCK_ITEMS_POPUP_LABEL)
              {
                /*  Cleanup the block listing  */

                status = _NFFend_block_listing (f_label, FALSE);
              }

            FIf_delete (*form);
            NFFglobal.popup_form = *form = NULL;

            /*  Find out which button to pop back up  */

            switch (f_label)
              {
                case SERVERS_POPUP_LABEL:
                    button_form = NFFglobal.current_form;
                    g_label = SERVER_BUTTON;
                    break;

                case ENVS_POPUP_LABEL:
                    button_form = NFFglobal.current_form;
                    g_label = ENV_BUTTON;
                    break;

                case PROJECTS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = PROJECT_POPUP;
                    break;

                case CATALOGS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = CATALOG_POPUP;
                    break;

                case BLOCK_ITEMS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = ITEM_POPUP;
                    break;

                case ITEMS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = ITEM_POPUP;
                    break;

                case REVISIONS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = REVISION_POPUP;
                    break;

                case SEARCH_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = SEARCH_POPUP;
                    break;

                case SORT_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = SORT_POPUP;
                    break;

                case WORKING_AREAS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = WA_POPUP;
                    break;

                case NODES_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = NODE_POPUP;
                    break;

                case STORAGE_AREAS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = SA_POPUP;
                    break;

                case USERS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = USER_POPUP;
                    break;

                case WORKFLOWS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = WF_POPUP;
                    break;

                case ACLS_POPUP_LABEL:
                    button_form = NFFglobal.forms[MAIN_LABEL];
                    g_label = ACL_POPUP;
                    break;
              }

            FIg_set_state_off (button_form, g_label);
            break;

        case NFF_MORE:
            status = _NFFmore_data (f_label, NFMRglobal.query_rows);
            _NFFcenter_gadget (*form, FIELD);
            FIf_display (*form);
            break;

      }

    _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
    return (status);
  }
