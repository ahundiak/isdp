
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFvalidate.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFvalid_catalog (catalog_name)
  char    *catalog_name;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_catalog";

    if ((strcmp (catalog_name, "")) == 0)
      {
        _NFIdebug ((fname, "no catalog was specified\n"));
        return (NFI_E_NO_CATALOG);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_catalog ...\n"));
    if ((status = NFMRvalidate_catalog (catalog_name)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_catalog = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_catalog\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_item (catalog, item_name)
  char   *catalog;
  char   *item_name;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_item";

    if ((strcmp (catalog, "")) == 0)
      {
        _NFIdebug ((fname, "catalog name is NULL\n"));
        ERRload_struct (NFI, NFI_I_CHOOSE_CATALOG, NULL);
        _NFIdebug ((fname, " returning NFI_I_CHOOSE_CATALOG <0x%.8x>\n",
            NFI_I_CHOOSE_CATALOG));
        return (NFI_I_CHOOSE_CATALOG);
      }
    else if ((strcmp (item_name, "")) == 0)
      {
        _NFIdebug ((fname, "no item was specified\n"));
        return (NFI_E_NO_ITEM);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_item ...\n"));
    if ((status = NFMRvalidate_item (catalog, item_name)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_item = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_item\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_revision (catalog, item, revision, set_or_not)
  char    *catalog;
  char    *item;
  char    *revision;
  int     *set_or_not;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_revision";

    if ((strcmp (catalog, "")) == 0)
      {
        _NFIdebug ((fname, "catalog name is NULL\n"));
        ERRload_struct (NFI, NFI_I_CHOOSE_CATALOG, NULL);
        _NFIdebug ((fname, " returning NFI_I_CHOOSE_CATALOG <0x%.8x>\n",
            NFI_I_CHOOSE_CATALOG));
        return (NFI_I_CHOOSE_CATALOG);
      }
    else if ((strcmp (item, "")) == 0)
      {
        _NFIdebug ((fname, "item name is NULL\n"));
        ERRload_struct (NFI, NFI_I_CHOOSE_ITEM, NULL);
        _NFIdebug ((fname, " returning NFI_I_CHOOSE_ITEM <0x%.8x>\n",
            NFI_I_CHOOSE_ITEM));
        return (NFI_I_CHOOSE_ITEM);
      }
    else if ((strcmp (revision, "")) == 0)
      {
        _NFIdebug ((fname, "no revision was specified\n"));
        return (NFI_E_NO_REV);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_revision ...\n"));
    if ((status = NFMRvalidate_revision
        (catalog, item, revision, set_or_not)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_revision = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_revision\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_sa (saname)
  char    *saname;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_sa";

    if ((strcmp (saname, "")) == 0)
      {
        _NFIdebug ((fname, "no storage area was specified\n"));
        return (NFI_E_NO_ST_AREA);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_st_area ...\n"));
    if ((status = NFMRvalidate_st_area (saname)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_st_area = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_st_area\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_project (project)
  char    *project;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_project";

    if ((strcmp (project, "")) == 0)
      {
        _NFIdebug ((fname, "no project was specified\n"));
        return (NFI_E_NO_PROJECT);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_project ...\n"));
    if ((status = NFMRvalidate_project (project)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_project = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_project\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_search (search, owner)
  char    *search;
  char    *owner;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_search";

    if ((strcmp (search, "")) == 0)
      {
        _NFIdebug ((fname, "no search name was specified\n"));
        return (NFI_E_NO_SEARCH);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_search ...\n"));
    if ((status = NFMRvalidate_search (search, owner)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_search = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_search\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_sort (sort, owner)
  char    *sort;
  char    *owner;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_sort";

    if ((strcmp (sort, "")) == 0)
      {
        _NFIdebug ((fname, "no sort name was specified\n"));
        return (NFI_E_NO_SORT);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_sort ...\n"));
    if ((status = NFMRvalidate_sort (sort, owner)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_sort = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_sort\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_wa (waname, owner)
  char    *waname;
  char    *owner;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_wa";

    if ((strcmp (waname, "")) == 0)
      {
        _NFIdebug ((fname, "no working area was specified\n"));
        return (NFI_E_NO_ST_AREA);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_working_area ...\n"));
    if ((status = NFMRvalidate_working_area (waname, owner)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_working_area = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_working_area\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_user (user)
  char    *user;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_user";

    if ((strcmp (user, "")) == 0)
      {
        _NFIdebug ((fname, "no user was specified\n"));
        return (NFI_E_NO_USER);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_user ...\n"));
    if ((status = NFMRvalidate_user (user)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_user = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_user\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_node (node)
  char    *node;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_node";

    if ((strcmp (node, "")) == 0)
      {
        _NFIdebug ((fname, "no node was specified\n"));
        return (NFI_E_NO_NODE);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_node ...\n"));
    if ((status = NFMRvalidate_node (node)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_node = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_node\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_wf (workflow)
  char    *workflow;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_workflow";

    if ((strcmp (workflow, "")) == 0)
      {
        _NFIdebug ((fname, "no workflow was specified\n"));
        return (NFI_E_NO_WF);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_workflow ...\n"));
    if ((status = NFMRvalidate_workflow (workflow)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_workflow = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_workflow\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalid_acl (workflow, acl)
  char    *workflow;
  char    *acl;
  {
    auto    long status;
    static  char *fname = "_NFFvalid_workflow";

    if ((strcmp (workflow, "")) == 0)
      {
        _NFIdebug ((fname, "workflow name is NULL\n"));
        ERRload_struct (NFI, NFI_I_CHOOSE_WORKFLOW, NULL);
        _NFIdebug ((fname, " returning NFI_I_CHOOSE_WORKFLOW <0x%.8x>\n",
            NFI_I_CHOOSE_WORKFLOW));
        return (NFI_I_CHOOSE_WORKFLOW);
      }
    else if ((strcmp (acl, "")) == 0)
      {
        _NFIdebug ((fname, "no acl was specified\n"));
        return (NFI_E_NO_ACL);
      }

    NFFform_message (MAIN_LABEL, NFI_I_VALIDATE, NULL);

    _NFIdebug ((fname, "calling NFMRvalidate_acl ...\n"));
    if ((status = NFMRvalidate_acl (workflow, acl)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRvalidate_acl = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, "returned from NFMRvalidate_acl\n"));

    NFFerase_message ();

    _NFIdebug ((fname, " returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFvalidate_active_data (mask)
  long    mask;
  {
    auto    int   i, row, col;
    auto    int   sel, r_pos;
    auto    int   num_rows;
    auto    int   found = FALSE;
    auto    long  status;
    auto    Form  form = NULL;
    auto    char  text[20];
    auto    char  owner[NFM_USERNAME + 1];
    static  char  *fname = "_NFFvalidate_active_data";

    /*  Check first to see if the user is connected and logged in  */

    if (mask & NFF_CONNECT)
      {
        if ((strcmp (NFFglobal.server, "")) == 0)
          {
            ERRload_struct (NFI, NFI_E_MUST_CONNECT, NULL);
            return (NFI_E_MUST_CONNECT);
          }
      }
    else if (mask & NFF_DISCONNECT)
      {
        if ((strcmp (NFFglobal.server, "")) != 0)
          {
            ERRload_struct (NFI, NFI_E_MUST_DISCONNECT, NULL);
            return (NFI_E_MUST_DISCONNECT);
          }
      }

    if (mask & NFF_LOGIN)
      {
        if ((strcmp (NFFglobal.environment, "")) == 0)
          {
            ERRload_struct (NFI, NFI_E_MUST_LOGIN, NULL);
            return (NFI_E_MUST_LOGIN);
          }
      }
    else if (mask & NFF_LOGOUT)
      {
        if ((strcmp (NFFglobal.environment, "")) != 0)
          {
            ERRload_struct (NFI, NFI_E_MUST_LOGOUT, NULL);
            return (NFI_E_MUST_LOGOUT);
          }
      }

    if (mask & NFF_SET)
      {
        if ((strcmp (NFFglobal.set_indicator, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_SET, NULL);
            return (NFI_I_CHOOSE_SET);
          }
      }

    if (mask & NFF_WORKING_AREA)
      {
        if ((strcmp (NFFglobal.working_area, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_WA, NULL);
            return (NFI_I_CHOOSE_WA);
          }
      }

    if (mask & NFF_ST_AREA)
      {
        if ((strcmp (NFFglobal.storage_area, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_SA, NULL);
            return (NFI_I_CHOOSE_SA);
          }
      }

    if (mask & NFF_PROJECT)
      {
        if ((strcmp (NFFglobal.project, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_PROJECT, NULL);
            return (NFI_I_CHOOSE_PROJECT);
          }
      }

    if (mask & NFF_SEARCH)
      {
        if ((strcmp (NFFglobal.search, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_SEARCH, NULL);
            return (NFI_I_CHOOSE_SEARCH);
          }
      }

    if (mask & NFF_SORT)
      {
        if ((strcmp (NFFglobal.sort, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_SORT, NULL);
            return (NFI_I_CHOOSE_SORT);
          }
      }

    if (mask & NFF_WORKFLOW)
      {
        if ((strcmp (NFFglobal.workflow, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_WORKFLOW, NULL);
            return (NFI_I_CHOOSE_WORKFLOW);
          }
      }

    if (mask & NFF_ACL)
      {
        if ((strcmp (NFFglobal.acl, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_ACL, NULL);
            return (NFI_I_CHOOSE_ACL);
          }
      }

    if (mask & NFF_NODE)
      {
        if ((strcmp (NFFglobal.node, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_NODE, NULL);
            return (NFI_I_CHOOSE_NODE);
          }
      }

    if (mask & NFF_USER)
      {
        if ((strcmp (NFFglobal.user, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_USER, NULL);
            return (NFI_I_CHOOSE_USER);
          }
      }

    if (mask & NFF_LOCAL_FILES)
      {
        if (NFFglobal.forms[LOCAL_FILES_LABEL] == NULL)
          {
            /*  Make sure they have an active working area  */

            if ((strcmp (NFFglobal.working_area, "")) == 0)
              {
                ERRload_struct (NFI, NFI_I_CHOOSE_WA, NULL);
                return (NFI_I_CHOOSE_WA);
              }
            else if (NFMRglobal.administrator == FALSE)
              {
                /*  Validate that this user owns the working area  */

                if ((status = _NFFvalid_wa
                    (NFFglobal.working_area, owner)) != NFI_S_SUCCESS)
                  {
                    /*  This should not happen  */

                    _NFIdebug ((fname, "_NFFvalid_wa = <0x%.8x>\n", status));
                    return (status);
                  }

                /*  It's okay if it's a public working area  */

                if (((strcmp (owner, "PUBLIC")) != 0) &&
                   ((strcmp (NFFglobal.username, owner)) != 0))
                  {
                    ERRload_struct (NFI, NFI_I_CHOOSE_OWNED_WA, NULL);
                    return (NFI_I_CHOOSE_OWNED_WA);
                  }
              }

            /*  Display list of local files for them  */

            if ((status = NFFdisplay_local_files (TRUE)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "NFFdisplay_local_files = <0x%.8x>\n", status));
                return (status);
              }

            ERRload_struct (NFI, NFI_I_CHOOSE_LOCAL_FILES, NULL);
            return (NFI_I_CHOOSE_LOCAL_FILES);
          }
        else
          {
            /*  Make sure they have selected at least 1 row  */

            found = FALSE;
            FIfld_get_num_rows
                (NFFglobal.forms[LOCAL_FILES_LABEL], MCF, &num_rows);
            for (row = 0; row < num_rows; ++row)
              {
                FImcf_get_select
                    (NFFglobal.forms[LOCAL_FILES_LABEL], MCF, row, &sel);
                if (sel == TRUE)
                  {
                    found = TRUE;
                    break;
                  }
              }

            if (found == FALSE)
              {
                _NFIdebug ((fname, "no local files are selected\n"));
                ERRload_struct (NFI, NFI_I_CHOOSE_LOCAL_FILES, NULL);
                return (NFI_I_CHOOSE_LOCAL_FILES);
              }
          }
      }

    /*  Check this last  */

    if (mask & NFF_LIST)
      {
        /*  See if any of the item list forms are up  */

        for (i = 0; i < 3; ++i)
          {
            switch (i)
              {
                case 0:
                    form = NFFglobal.forms[ITEMS_LABEL];
                    break;
                case 1:
                    form = NFFglobal.forms[SETM_LABEL];
                    break;
                case 2:
                    form = NFFglobal.forms[PROJM_LABEL];
                    break;
              }

            if (form == NULL) continue;

            /*  Make sure they have selected at least 1 row  */

            FIfld_get_num_rows (form, MCF, &num_rows);
            for (row = 0; row < num_rows; ++row)
              {
                FImcf_get_select (form, MCF, row, &sel);
                if (sel == FALSE) continue;

                /*  See if there is active data already  */

                if ((strcmp (NFFglobal.revision, "")) != 0)
                  {
                    /*  Can do this only because this is last  */

                    _NFIdebug ((fname, " returning SUCCESS\n"));
                    return (NFI_S_SUCCESS);
                  }

                /*  There is no active data; make the first
                    selected row in the list the active data  */

                /*  Get the selected catalog name  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_catalogname", &col);
                if (col != -1)
                  {
                    /*  There might not be a catalog name in the form  */

                    FIfld_get_text (form, MCF, row, col,
                        NFM_CATALOGNAME + 1, NFFglobal.catalog, &sel, &r_pos);
                    FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                        CATALOG_FIELD, 0, 0, NFFglobal.catalog, FALSE);
                  }

                _NFIdebug ((fname,
                    "catalog name = <%s>\n", NFFglobal.catalog));

                /*  Get the selected item name  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_itemname", &col);
                FIfld_get_text (form, MCF, row, col,
                    NFM_ITEMNAME + 1, NFFglobal.item, &sel, &r_pos);
                FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                    ITEM_FIELD, 0, 0, NFFglobal.item, FALSE);
                _NFIdebug ((fname, "item name = <%s>\n", NFFglobal.item));

                /*  Get the selected item revision  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_itemrev", &col);
                FIfld_get_text (form, MCF, row, col,
                    NFM_ITEMREV + 1, NFFglobal.revision, &sel, &r_pos);
                FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                    REVISION_FIELD, 0, 0, NFFglobal.revision, FALSE);
                _NFIdebug ((fname, "revision = <%s>\n", NFFglobal.revision));

                /*  Find out if it is a set  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_setindicator", &col);
                FIfld_get_text (form, MCF, row, col, NFM_SETINDICATOR + 1,
                    NFFglobal.set_indicator, &sel, &r_pos);

                if ((strcmp (NFFglobal.set_indicator, "Y")) == 0)
                    strcpy (text, "Set Name");
                else
                    strcpy (text, "Item Name");

                _NFFalter_item_text_label (text);

                _NFIdebug ((fname,
                    "set_indicator = <%s>\n", NFFglobal.set_indicator));

                /*  Can do this only because this is last  */

                _NFIdebug ((fname, " returning SUCCESS\n"));
                return (NFI_S_SUCCESS);
              }
          }

        /*  Drop thru and check the regular way  */
      }

    if (mask & NFF_CATALOG)
      {
        if ((strcmp (NFFglobal.catalog, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_CATALOG, NULL);
            return (NFI_I_CHOOSE_CATALOG);
          }
      }

    if (mask & NFF_ITEM)
      {
        if ((strcmp (NFFglobal.item, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_ITEM, NULL);
            return (NFI_I_CHOOSE_ITEM);
          }
      }

    if (mask & NFF_REVISION)
      {
        if ((strcmp (NFFglobal.revision, "")) == 0)
          {
            ERRload_struct (NFI, NFI_I_CHOOSE_REVISION, NULL);
            return (NFI_I_CHOOSE_REVISION);
          }
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
