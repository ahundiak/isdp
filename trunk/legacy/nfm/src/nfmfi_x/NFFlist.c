
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFconfirm.h"
#include "NFFtimestamp.h"

#define  MESSAGE_FIELD   13

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

void _NFFprocess_list (f_label, g_label)
  int    f_label;
  int    g_label;
  {
    auto    char    catalog[NFM_CATALOGNAME + 1];
    auto    char    item[NFM_ITEMNAME + 1];
    auto    char    revision[NFM_ITEMREV + 1];
    auto    char    set_indicator[NFM_SETINDICATOR + 1];
    auto    char    command[20], *ptr;
    auto    char    s[NFF_MAX_MESSAGE];
    auto    char    error_message[NFF_MAX_MESSAGE];
    auto    int     list, row, col, num_rows;
    auto    int     sel, r_pos, error_row = 0;
    auto    int     vis_rows, attr_mask;
    auto    char    text[20];
    auto    int     set_or_not = 0;
    auto    long    status;
    auto    Form    form = NULL;
    static  char    *fname = "_NFFprocess_list";

    _NFIdebug ((fname, "f_label = <%d>\n", f_label));

    if (g_label == CANCEL_BUTTON) return;

    /*  Figure out the command string  */

    switch (f_label)
      {
        case DELETE_CONFIRM_LABEL:
            strcpy (command, NFI_M_DELETE_ITEM);
            break;

        case CHECKIN_CONFIRM_LABEL:
            strcpy (command, NFI_M_CHECK_IN);
            break;

        case CHECKOUT_CONFIRM_LABEL:
            strcpy (command, NFI_M_CHECK_OUT);
            break;

        case COPY_FILES_CONFIRM_LABEL:
            strcpy (command, NFI_M_COPY_ITEM_FILES);
            break;

        case FLAG_ARCHIVE_LABEL:
            strcpy (command, NFI_M_FLAG_ARCHIVE);
            break;

        case FLAG_BACKUP_LABEL:
            strcpy (command, NFI_M_FLAG_BACKUP);
            break;

        case FLAG_RESTORE_LABEL:
            strcpy (command, NFI_M_FLAG_RESTORE);
            break;

        case FLAG_DELETE_LABEL:
            strcpy (command, NFI_M_FLAG_DELETE);
            break;

        case SAVE_ITEM_LABEL:
            strcpy (command, NFI_M_SAVE_ITEM);
            break;

        case PLOT_ITEM_LABEL:
            strcpy (command, NFI_M_PLOT_ITEM);
            break;

        default:
	    _NFIdebug(( fname, "Returning ...\n" ));
            return;
      }

    /*  Save current active data  */

    strcpy (catalog, NFFglobal.catalog);
    strcpy (item, NFFglobal.item);
    strcpy (revision, NFFglobal.revision);
    strcpy (set_indicator, NFFglobal.set_indicator);

    /*  Only load the error form if it's not already up  */

    if (NFFglobal.error_form == NULL)
      {
        /*  Load in the error form  */

        if ((status = (long) FIf_new (ERROR_FORM_LABEL,
            ERROR_FORM, _NFFnotify, &(NFFglobal.error_form))) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_new = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
            NFFerror_message (NFFglobal.forms[MAIN_LABEL]);
            _NFIdebug ((fname, " returning ...\n"));
            return;
          }
      }

    /*  Add the first error message to the error form  */

    ERRget_message (s);
    sprintf (error_message, "%s.%s.%s - %s",
        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision, s);
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* SSRS 23 Mar 94 */
    FIg_set_font( NFFglobal.error_form, MESSAGE_FIELD, "7x13bold", 15 );
#endif
    FIfld_set_text (NFFglobal.error_form,
        MESSAGE_FIELD, error_row++, 0, error_message, FALSE);

#ifndef XWINDOWS
    _NFFprocess_event (REFRESH_EVENT);
#endif

    /*  Go thru list_items, list_setm, list_prjm for active items  */

    for (list = 0; list < 3; ++list)
      {
        switch (list)
          {
            case 0:
                if (NFFglobal.forms[ITEMS_LABEL] != NULL)
		{
                    form = NFFglobal.forms[ITEMS_LABEL];
	    	}
                else
                    continue;
                break;

            case 1:
                if (NFFglobal.forms[SETM_LABEL] != NULL)
                    form = NFFglobal.forms[SETM_LABEL];
                else
                    continue;
                break;

            case 2:
                if (NFFglobal.forms[PROJM_LABEL] != NULL)
                    form = NFFglobal.forms[PROJM_LABEL];
                else
                    continue;
                break;
          }

        FIfld_get_num_rows (form, MCF, &num_rows);

        for (row = 0; row < num_rows; ++row)
          {
            /*  Get the next selected row  */

            FIfld_get_select (form, MCF, row, 0, &sel);
            if (sel == FALSE) continue;

            if (list == 0)
              {
                /*  Get the selected catalog name  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_catalogname", &col);
                if (col != -1)
                  {
                    /*  There might not be a catalog name in the MCF  */

                    FIfld_get_text (form, MCF, row, col,
                        NFM_CATALOGNAME + 1, NFFglobal.catalog, &sel, &r_pos);
                  }
                else
                  {
                    /*  Get the catalog name out the form  */

                    FIf_get_user_pointer (form, &ptr);
                    strcpy (NFFglobal.catalog, ptr);
                  }

                _NFIdebug ((fname,
                    "catalog name = <%s>\n", NFFglobal.catalog));

                /*  Get the selected item name  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_itemname", &col);
                if (col != -1)
                  {
                    FIfld_get_text (form, MCF, row, col,
                        NFM_ITEMNAME + 1, NFFglobal.item, &sel, &r_pos);
                    _NFIdebug ((fname, "item name = <%s>\n", NFFglobal.item));
                  }
                else
                  {
                    /*  This is bad; they made item name non-readable  */

                    _NFIdebug ((fname,
                        "couldn't find item name; continuing\n"));
                    continue;
                  }

                /*  Get the selected item revision  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_itemrev", &col);
                if (col != -1)
                  {
                    FIfld_get_text (form, MCF, row, col,
                        NFM_ITEMREV + 1, NFFglobal.revision, &sel, &r_pos);
                    _NFIdebug ((fname,
                        "revision = <%s>\n", NFFglobal.revision));
                  }
                else
                  {
                    /*  This is bad; they made revision non-readable  */

                    _NFIdebug ((fname,
                        "couldn't find revision; continuing\n"));
                    continue;
                  }

                /*  Find out if it is a set  */

                NFFfind_mcf_attribute (form, TOP_MCF, "n_setindicator", &col);
                if (col != -1)
                  {
                    FIfld_get_text (form, MCF, row, col, NFM_SETINDICATOR + 1,
                        NFFglobal.set_indicator, &sel, &r_pos);
                    _NFIdebug ((fname,
                        "set_indicator = <%s>\n", NFFglobal.set_indicator));
                  }
                else
                  {
                    /*  This is bad; they made set indicator non-readable  */

                    _NFIdebug ((fname,
                        "couldn't find set indicator; call NFFvalid_rev\n"));

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
              }
            else
              {
                /*  Get the selected catalog name  */

                FIfld_get_text (form, MCF, row, 0,
                    NFM_CATALOGNAME + 1, NFFglobal.catalog, &sel, &r_pos);
                _NFIdebug ((fname,
                    "catalog name = <%s>\n", NFFglobal.catalog));

                /*  Get the selected item name  */

                FIfld_get_text (form, MCF, row, 1,
                    NFM_ITEMNAME + 1, NFFglobal.item, &sel, &r_pos);
                _NFIdebug ((fname, "item name = <%s>\n", NFFglobal.item));

                /*  Get the selected item revision  */

                FIfld_get_text (form, MCF, row, 2,
                    NFM_ITEMREV + 1, NFFglobal.revision, &sel, &r_pos);
                _NFIdebug ((fname,
                    "revision = <%s>\n", NFFglobal.revision));

                if (list == 1)
                  {
                    /*  Find out if it is a set  */

                    FIfld_get_text (form, MCF, row, 3, NFM_SETINDICATOR + 1,
                        NFFglobal.set_indicator, &sel, &r_pos);
                  }
                else
                  {
                    /*  Assume all project members are NOT set members  */

                    strcpy (NFFglobal.set_indicator, "N");
                  }

                _NFIdebug ((fname,
                    "set_indicator = <%s>\n", NFFglobal.set_indicator));
              }

            /*  See if this is the one that has already been processed  */

            if (((strcmp (NFFglobal.catalog, catalog)) == 0) &&
               ((strcmp (NFFglobal.item, item)) == 0) &&
               ((strcmp (NFFglobal.revision, revision)) == 0) &&
               ((strcmp (NFFglobal.set_indicator, set_indicator)) == 0))
              {
                _NFIdebug ((fname,
                    "already processed this item; continuing ...\n"));
                continue;
              }

            /*  Timestamp the beginning of the command  */

            _NFFts_command_start ();

            ERRreset_struct ();

            /*  Call NFFvalidate_user_access ()  */

            if ((status = NFFvalidate_user_access (command)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "NFFvalidate_user_access = <0x%.8x>\n", status));
                NFFerror_message (NFFglobal.forms[MAIN_LABEL]);

                /*  Add the error message to the error form  */

                ERRget_message (s);
                sprintf (error_message, "%s.%s.%s - %s",
                    NFFglobal.catalog, NFFglobal.item, NFFglobal.revision, s);
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* SSRS 23 Mar 94 */
    FIg_set_font( NFFglobal.error_form, MESSAGE_FIELD, "7x13bold", 15 );
#endif
                FIfld_set_text (NFFglobal.error_form,
                    MESSAGE_FIELD, error_row++, 0, error_message, FALSE);

                _NFIdebug ((fname, " continuing ...\n\n"));
                continue;
              }

            /*  If successful, call appropriate command  */

            switch (f_label)
              {
                case SAVE_ITEM_LABEL:
                    if (strcmp (NFFglobal.set_indicator, "") == 0)
                      {
                        NFFsave_item (FALSE, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                        _NFFgeneric_confirm_notify (OK_BUTTON,
                            &NFFglobal.current_form);
                      }
                    else
                      {
                        NFFsave_set (FALSE, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                        _NFFgeneric_confirm_notify (OK_BUTTON,
                            &NFFglobal.current_form);
                      }

                    break;

                case PLOT_ITEM_LABEL:
                    if (strcmp (NFFglobal.set_indicator, "") == 0)
                      {
                        NFFplot_item (FALSE, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                        _NFFgeneric_confirm_notify (OK_BUTTON,
                            &NFFglobal.current_form);
                      }
                    else
                      {
                        NFFplot_set (FALSE, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                        _NFFgeneric_confirm_notify (OK_BUTTON,
                            &NFFglobal.current_form);
                      }

                    break;

                case DELETE_CONFIRM_LABEL:
                    NFFdelete_item (FALSE,
                        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
                    _NFFconfirm_notify (f_label,
                        OK_BUTTON, &NFFglobal.current_form);
                    break;

                case CHECKIN_CONFIRM_LABEL:
                    if (strcmp (NFFglobal.set_indicator, "") == 0)
                     {
                        NFFcheckin_item (FALSE,
                        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
                        _NFFfile_io_confirm_notify (OK_BUTTON,
                                                   &NFFglobal.current_form);
                     }
                    else
                     {
                        NFFcheckin_set (FALSE,
                        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
                        _NFFset_io_confirm_notify (OK_BUTTON,
                                                   &NFFglobal.current_form);
                     }
                    break;

                case CHECKOUT_CONFIRM_LABEL:
                    if (strcmp (NFFglobal.set_indicator, "") == 0)
                     {
                        NFFcheckout_item (FALSE,
                        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
                        _NFFfile_io_confirm_notify (OK_BUTTON,
                                                   &NFFglobal.current_form);
                     }
                    else
                     {
                        NFFcheckout_set (FALSE,
                        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
                        _NFFset_io_confirm_notify (OK_BUTTON,
                                                   &NFFglobal.current_form);
                     }
                    break;

                case COPY_FILES_CONFIRM_LABEL:
                    if (strcmp (NFFglobal.set_indicator, "") == 0)
                     {
                        NFFn_copy_item_files (FALSE,
                        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
                        _NFFfile_io_confirm_notify (OK_BUTTON,
                                                   &NFFglobal.current_form);
                     }
                    else
                     {
                        NFFn_copy_set_files (FALSE,
                        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
                        _NFFset_io_confirm_notify (OK_BUTTON,
                                                   &NFFglobal.current_form);
                     }
                    break;

                case FLAG_ARCHIVE_LABEL:
                    if (strcmp (NFFglobal.set_indicator, "") == 0)
                     {
                        NFFflag_item_files (FALSE,
                            FLAG_ARCHIVE, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                     }
                     else
                     {
                        NFFflag_set_files (FALSE,
                            FLAG_ARCHIVE, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                     }

                    _NFFconfirm_notify (f_label,
                        OK_BUTTON, &NFFglobal.current_form);

                    break;

                case FLAG_BACKUP_LABEL:
                    if (strcmp (NFFglobal.set_indicator, "") == 0)
                     {
                        NFFflag_item_files (FALSE,
                            FLAG_BACKUP, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                     }
                     else
                     {
                        NFFflag_set_files (FALSE,
                            FLAG_BACKUP, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                     }

                    _NFFconfirm_notify (f_label,
                        OK_BUTTON, &NFFglobal.current_form);

                    break;

                case FLAG_RESTORE_LABEL:
                    if (strcmp (NFFglobal.set_indicator, "") == 0)
                     {
                        NFFflag_item_files (FALSE,
                            FLAG_RESTORE, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                     }
                     else
                     {
                        NFFflag_set_files (FALSE,
                            FLAG_RESTORE, NFFglobal.catalog,
                            NFFglobal.item, NFFglobal.revision);
                     }

                    _NFFconfirm_notify (f_label,
                        OK_BUTTON, &NFFglobal.current_form);

                    break;

                case FLAG_DELETE_LABEL:
                    NFFflag_item_files (FALSE, FLAG_DELETE,
                        NFFglobal.catalog, NFFglobal.item, NFFglobal.revision);
                    _NFFconfirm_notify (f_label,
                        OK_BUTTON, &NFFglobal.current_form);
                    break;

              } 
            NFFerror_message (NFFglobal.forms[MAIN_LABEL]);

            /*  Add the error message to the error form  */

            ERRget_message (s);
            sprintf (error_message, "%s.%s.%s - %s",
                NFFglobal.catalog, NFFglobal.item, NFFglobal.revision, s);
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* SSRS 23 Mar 94 */
    FIg_set_font( NFFglobal.error_form, MESSAGE_FIELD, "7x13bold", 15 );
#endif
            FIfld_set_text (NFFglobal.error_form,
                MESSAGE_FIELD, error_row++, 0, error_message, FALSE);

            /*  Timestamp the end of the command  */

            _NFFts_data (("End of Command      -  %d\n", time ((long *) 0)));

            /*  Commit the data to the timestamp file  */

            _NFFts_commit ();
          }
      }

    /*  Restore previous active data  */

    if (f_label != DELETE_CONFIRM_LABEL)
      {
        strcpy (NFFglobal.catalog, catalog);
        strcpy (NFFglobal.item, item);
        strcpy (NFFglobal.revision, revision);
        strcpy (NFFglobal.set_indicator, set_indicator);
      }

    /*  Enable the scroll bar, if necessary  */

    FIfld_get_num_rows (NFFglobal.error_form, MESSAGE_FIELD, &num_rows);
    FIfld_get_num_vis_rows (NFFglobal.error_form, MESSAGE_FIELD, &vis_rows);
    FIfld_get_attr (NFFglobal.error_form, MESSAGE_FIELD, 0, &attr_mask);
    if (num_rows > vis_rows)
      {
        /*  OR in the vertical scroll bar attribute  */

        attr_mask |= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }
    else
      {
        /*  Take out the vertical scroll bar attribute  */

        /*for INTEL SOLARIS -- CN 24/5/95 */  
 
#if defined(OS_HPUX)/* || defined(OS_INTELSOL) */

        /* Only FI_DISPLAY_VSCROLL is disabled as the combination is
           giving blank  form. Could be some Xforms problem.
           Work around change IGI 29/06/94  */
        attr_mask &= ~FI_DISPLAY_VSCROLL;
#else
        if (attr_mask & (FI_VERT_SCROLL | FI_DISPLAY_VSCROLL))
            attr_mask ^= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
#endif
      }

    FIfld_set_attr (NFFglobal.error_form, MESSAGE_FIELD, 0, attr_mask);

    /*  Display the list of errors  */

    if (error_row > 1)
      {
        /*  Display the form  */

        _NFFcenter_form (NFFglobal.error_form, -1, Y_FORM_POS);
        FIf_display (NFFglobal.error_form);
      }
    else
      {
        /*  Delete the form  */

        FIf_delete (NFFglobal.error_form);
        NFFglobal.error_form = NULL;
      }

    return;
  }


long _NFFerror_notify (g_label, form)
  int    g_label;
  Form   *form;
  {
    static  char    *fname = "_NFFerror_notify";

    switch (g_label)
      {
        case FI_CANCEL:
            FIf_delete (*form);
            NFFglobal.error_form = *form = NULL;
            break;

        default:
            break;
      }

    _NFIdebug ((fname, "returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
