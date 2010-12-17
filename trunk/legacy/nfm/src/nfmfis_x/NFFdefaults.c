
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmain_form.h"

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

long NFFread_user_defaults ()
  {
    auto    int     i;
    auto    long    status;
    auto    char    **data_ptr;
    auto    MEMptr  data = NULL;
    static  char    *fname = "NFFread_user_defaults";

    static  char    *fields[15] = { NFFglobal.storage_area,
                                    NFFglobal.catalog,
                                    NFFglobal.item,
                                    NFFglobal.revision,
                                    NFFglobal.catalog,
                                    NFFglobal.item,
                                    NFFglobal.revision,
                                    NFFglobal.project,
                                    NFFglobal.search,
                                    NFFglobal.sort,
                                    NFFglobal.workflow,
                                    NFFglobal.acl,
                                    NFFglobal.node,
                                    NFFglobal.working_area,
                                    NFFglobal.user };

    static  int     labels[15] = { SA_FIELD, CATALOG_FIELD,
                                   ITEM_FIELD, REVISION_FIELD,
                                   CATALOG_FIELD, ITEM_FIELD,
                                   REVISION_FIELD, PROJECT_FIELD,
                                   SEARCH_FIELD, SORT_FIELD, WF_FIELD,
                                   ACL_FIELD, NODE_FIELD, WA_FIELD,
                                   USER_FIELD };

    NFFform_message (MAIN_LABEL, NFI_I_RETRIEVE, NULL);

    if ((status = NFMRread_user_defaults (&data)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRread_user_defaults = <0x%.8x>\n", status));
        MEMclose (&data);
        NFFerase_message ();
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    if (_NFMdebug_st.NFIdebug_on)
        MEMprint_buffer (fname, data, _NFMdebug_st.NFIdebug_file);

    if ((status = MEMbuild_array (data)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        MEMclose (&data);
        NFFerase_message ();
        _NFIdebug ((fname, "returning <0x%.8x>\n", status));
        return (status);
      }

    data_ptr = (char **) data->data_ptr;

    /*  Load the global structure  */

    for (i = 0; i < 15; ++i)
      {
        /*  Find out if it's a set  */

        switch (i)
          {
            case 4:    /*  Set Catalog Name  */
            case 5:    /*  Set Name          */
            case 6:    /*  Set Revision      */

                /*  See if there is something there  */

                if ((strcmp (data_ptr[i], "")) != 0)
                  {
                    /*  It IS a set  */

                    strcpy (NFFglobal.set_indicator, "Y");
                    _NFFalter_item_text_label ("Set Name");
                  }
                else
                  {
                    /*  Don't copy the data  */

                    continue;
                  }

                break;

            default:
                break;
          }

        switch (i)
          {
            /*  Check for fields only on the admin main form  */

            case 0:     /*  Storage Area  */
            case 10:    /*  Workflow      */
            case 11:    /*  ACL           */
            case 12:    /*  Node          */
            case 14:    /*  User          */

                if (NFFglobal.admin_or_user == ADMIN)
                  {

#ifdef OS_SCO_UNIX
                    /* work around change - added 1 line to set font SSRS 1 Feb 94 */
                    FIg_set_font(NFFglobal.forms[MAIN_LABEL], labels[i], "7x13bold", 15 );
#endif

                    FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                        labels[i], 0, 0, data_ptr[i], FALSE);
                  }

                break;

            default:

#ifdef OS_SCO_UNIX
                /* work around change - added 1 line to set font SSRS 1 Feb 94 */
                FIg_set_font(NFFglobal.forms[MAIN_LABEL], labels[i], "7x13bold", 15 );
#endif
                FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                    labels[i], 0, 0, data_ptr[i], FALSE);

                break;
          }

        /*  Go ahead and save previous admin data
            even if they're not using the admin main form  */

        strcpy (fields[i], data_ptr[i]);
      }

    MEMclose (&data);
    NFFerase_message ();

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x> ...\n", NFI_S_SUCCESS));
/* PS */
    NFFform_message (MAIN_LABEL, NFI_S_SUCCESS, NULL);
    return (NFI_S_SUCCESS);
  }


long NFFwrite_user_defaults ()
  {
    auto    int     i;
    auto    long    status;
    auto    MEMptr  buffer = NULL;
    static  char    *fname = "NFFwrite_user_defaults";

    static  char    *fields[15] = { NFFglobal.storage_area,
                                    NFFglobal.catalog,
                                    NFFglobal.item,
                                    NFFglobal.revision,
                                    NFFglobal.catalog,
                                    NFFglobal.item,
                                    NFFglobal.revision,
                                    NFFglobal.project,
                                    NFFglobal.search,
                                    NFFglobal.sort,
                                    NFFglobal.workflow,
                                    NFFglobal.acl,
                                    NFFglobal.node,
                                    NFFglobal.working_area,
                                    NFFglobal.user };

    if ((status = MEMopen (&buffer, MEM_SIZE)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        MEMclose (&buffer);
        _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
        return (status);
      }

    if ((status = MEMwrite_format
        (buffer, "n_name", "char(60)")) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        MEMclose (&buffer);
        _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
        return (status);
      }

    for (i = 0; i < 15; ++i)
      {
        /*  Find out if it's a set  */

        switch (i)
          {
            case 4:    /*  Set Catalog Name  */
            case 5:    /*  Set Name          */
            case 6:    /*  Set Revision      */

                if ((strcmp (NFFglobal.set_indicator, "")) != 0)
                  {
                    if ((status = MEMbuild_array (buffer)) != MEM_S_SUCCESS)
                      {
                        _NFIdebug ((fname,
                            "MEMbuild_array = <0x%.8x>\n", status));
                        MEMclose (&buffer);
                        _NFIdebug ((fname,
                            "returning <0x%.8x> ...\n", status));
                        return (status);
                      }

                    /*  Overwrite the previous item data  */

                    if ((status = MEMwrite_data
                        (buffer, "", (i - 3) + 1, 1)) != MEM_S_SUCCESS)
                      {
                        _NFIdebug ((fname,
                            "MEMwrite_data = <0x%.8x>\n", status));
                        MEMclose (&buffer);
                        _NFIdebug ((fname,
                            "returning <0x%.8x> ...\n", status));
                        return (status);
                      }
                  }
                else
                  {
                    /*  Don't put this data into the database  */

                    strcpy (fields[i], "");
                  }

                break;

            default:
                break;
          }

        if ((status = MEMwrite (buffer, fields[i])) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
            MEMclose (&buffer);
            _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
            return (status);
          }
      }

    if ((status = NFMRwrite_user_defaults (buffer)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRwrite_user_defaults = <0x%.8x>\n", status));
        MEMclose (&buffer);
        _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
        return (status);
      }

    MEMclose (&buffer);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x> ...\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }
