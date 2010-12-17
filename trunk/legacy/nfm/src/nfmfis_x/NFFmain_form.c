
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFMversion.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFinit_main_form ()
  {
    auto    long    status;
    auto    long    title_no;
    auto    char    form_name[30];
    auto    char    title[80];
    static  char    *fname = "NFFinit_main_form";

    if (NFFglobal.admin_or_user == ADMIN)
        strcpy (form_name, ADMIN_MAIN_FORM);
    else
        strcpy (form_name, USER_MAIN_FORM);

    if ((status = FIf_new (MAIN_LABEL, form_name,
        &_NFFnotify, &NFFglobal.forms[MAIN_LABEL])) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, "returning <0x%.8x>\n", NFI_E_FORM));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "scale_factor_x = %f\n", NFFglobal.scale_factor_x));
    _NFIdebug ((fname, "scale_factor_y = %f\n", NFFglobal.scale_factor_y));

    FIf_set_location (NFFglobal.forms[MAIN_LABEL],
        (int) (UPPER_RIGHT_X * NFFglobal.scale_factor_x),
        (int) (UPPER_RIGHT_Y * NFFglobal.scale_factor_y));

    _NFIdebug ((fname, "main form location is (%d, %d)\n",
        (int) (UPPER_RIGHT_X * NFFglobal.scale_factor_x),
        (int) (UPPER_RIGHT_Y * NFFglobal.scale_factor_y)));

    NFFglobal.positions[MAIN_LABEL] = UPPER_RIGHT;
    ++NFFglobal.locations[UPPER_RIGHT];

    /*  Put the title on the form  */
/* PS - IGI 15 Sep 1995 */
#if defined ( OS_INTELSOL )
	if (NFFglobal.admin_or_user == ADMIN)
            sprintf (title, "I/NFM Administrator Version %s", NFMversion);
        else
            sprintf (title, "I/NFM Version %s", NFMversion);
#else
    if (NFFglobal.admin_or_user == ADMIN)
        title_no = NFT_P_ADMIN_TITLE;
    else
        title_no = NFT_P_USER_TITLE;

    if ((status = (long) UMSGetByNum
        (title, title_no, "%s", NFMversion)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));

        if (NFFglobal.admin_or_user == ADMIN)
            sprintf (title, "I/NFM Administrator Version %s", NFMversion);
        else
            sprintf (title, "I/NFM Version %s", NFMversion);
      }
#endif      

    _NFIdebug ((fname, "Main title <%s>\n", title));

    FIg_set_text (NFFglobal.forms[MAIN_LABEL], MAIN_TITLE, title);

    /*  Trap the window event (for collapsing)  */

    FIf_set_window_event_routine
        (NFFglobal.forms[MAIN_LABEL], _NFFmain_window_event_routine);

    /*  Display the form  */

    if (NFFglobal.collapse_flag == TRUE)
        FIf_collapse (NFFglobal.forms[MAIN_LABEL]);

    FIf_display (NFFglobal.forms[MAIN_LABEL]);

    _NFIdebug ((fname, "returning SUCCESS <0x%.8x>\n", NFI_S_SUCCESS));
    return (NFI_S_SUCCESS);
  }


long _NFFmain_notify (g_label, value, form)
  int     g_label;
  int     value;
  Form    form;
  {
    auto    int   i;
    auto    int   sel;
    auto    int   pos;
    auto    int   flag;
    auto    char  text[20];
    auto    char  owner[NFM_USERNAME + 1];
    auto    long  status = NFI_S_SUCCESS;
    static  char  *fname = "_NFFmain_notify";

    switch (g_label)
      {
        case PROJECT_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_PROJECTNAME + 1, NFFglobal.project, &sel, &pos);
            if ((status = _NFFvalid_project
                (NFFglobal.project)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.project, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
              }

            break;

        case PROJECT_TOGGLE:

            if (value == TRUE)
              {
                if ((strcmp (NFFglobal.project, "")) == 0)
                  {
                    FIg_set_state (form, g_label, FALSE);
                    status = NFI_E_NO_PROJECT;
                    ERRload_struct (NFI, status, NULL);
                    break;
                  }
              }

            NFFglobal.project_active = value;

            break;

        case PROJECT_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFproject_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFproject_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case CATALOG_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_CATALOGNAME + 1, NFFglobal.catalog, &sel, &pos);
            if ((status = _NFFvalid_catalog
                (NFFglobal.catalog)) != NFI_S_SUCCESS)
              {
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
                strcpy (NFFglobal.catalog, "");
              }

            FIfld_set_text (form, ITEM_FIELD, 0, 0, "", FALSE);
            strcpy (NFFglobal.item, "");
	    _NFFalter_item_text_label ("Item Name");
	    strcpy( NFFglobal.set_indicator, "" );
            FIfld_set_text (form, REVISION_FIELD, 0, 0, "", FALSE);
            strcpy (NFFglobal.revision, "");

            break;

        case CATALOG_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFcatalog_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFcatalog_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
                break;
              }

            FIfld_set_text (form, ITEM_FIELD, 0, 0, "", FALSE);
            strcpy (NFFglobal.item, "");
	    _NFFalter_item_text_label ("Item Name");
	    strcpy( NFFglobal.set_indicator, "" );
            FIfld_set_text (form, REVISION_FIELD, 0, 0, "", FALSE);
            strcpy (NFFglobal.revision, "");

            break;

        case ITEM_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_ITEMNAME + 1, NFFglobal.item, &sel, &pos);
            if ((status =_NFFvalid_item
                (NFFglobal.catalog, NFFglobal.item)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.item, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
		_NFFalter_item_text_label ("Item Name");
		strcpy( NFFglobal.set_indicator, "" );
              }

            /*  Wipe out the current revision  */

            strcpy (NFFglobal.revision, "");
            FIfld_set_text (form, REVISION_FIELD, 0, 0, "", FALSE);

            break;

        case ITEM_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFitem_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFitem_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case REVISION_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_ITEMREV + 1, NFFglobal.revision, &sel, &pos);
            if ((status = _NFFvalid_revision (NFFglobal.catalog,
                NFFglobal.item, NFFglobal.revision, &flag)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.revision, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
              }
            else
              {
                if (flag == TRUE)
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

        case REVISION_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFrevision_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFrevision_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case SEARCH_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_REPORTNAME + 1, NFFglobal.search, &sel, &pos);
            if ((status = _NFFvalid_search
                (NFFglobal.search, owner)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.search, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
              }

            /*  Make sure access of okay  */

            if ((strcmp (owner, "PUBLIC")) != 0)
              {
                if ((strcmp (NFFglobal.username, owner)) != 0)
                  {
                    _NFIdebug ((fname,
                        "owner of search criteria is %s; user is %s\n",
                        owner, NFFglobal.username));
                    strcpy (NFFglobal.search, "");
                    FIfld_set_text (form, g_label, 0, 0, "", FALSE);
                  }
              }

            break;

        case SEARCH_TOGGLE:

            if (value == TRUE)
              {
                if ((strcmp (NFFglobal.search, "")) == 0)
                  {
                    FIg_set_state (form, g_label, FALSE);
                    status = NFI_E_NO_SEARCH;
                    ERRload_struct (NFI, status, NULL);
                    break;
                  }
              }

            NFFglobal.search_active = value;

            break;

        case SEARCH_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFsearch_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFsearch_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case SORT_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_REPORTNAME + 1, NFFglobal.sort, &sel, &pos);
            if ((status = _NFFvalid_sort
                (NFFglobal.sort, owner)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.sort, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
              }

            /*  Make sure access of okay  */

            if ((strcmp (owner, "PUBLIC")) != 0)
              {
                if ((strcmp (NFFglobal.username, owner)) != 0)
                  {
                    _NFIdebug ((fname,
                        "owner of search criteria is %s; user is %s\n",
                        owner, NFFglobal.username));
                    strcpy (NFFglobal.sort, "");
                    FIfld_set_text (form, g_label, 0, 0, "", FALSE);
                  }
              }

            break;

        case SORT_TOGGLE:

            if (value == TRUE)
              {
                if ((strcmp (NFFglobal.sort, "")) == 0)
                  {
                    FIg_set_state (form, g_label, FALSE);
                    status = NFI_E_NO_SORT;
                    ERRload_struct (NFI, status, NULL);
                    break;
                  }
              }

            NFFglobal.sort_active = value;

            break;

        case SORT_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFsort_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFsort_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case WA_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_SANAME + 1, NFFglobal.working_area, &sel, &pos);
            if ((status = _NFFvalid_wa
                (NFFglobal.working_area, owner)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.working_area, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
              }

            /*  Make sure access of okay  */

            if ((NFMRglobal.administrator == FALSE) &&
                ((strcmp (owner, "PUBLIC")) != 0))
              {
                if ((strcmp (NFFglobal.username, owner)) != 0)
                  {
                    _NFIdebug ((fname,
                        "owner of working area is %s; user is %s\n",
                        owner, NFFglobal.username));
                    strcpy (NFFglobal.working_area, "");
                    FIfld_set_text (form, g_label, 0, 0, "", FALSE);
                  }
              }

            break;

        case WA_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFwa_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFwa_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case SA_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_SANAME + 1, NFFglobal.storage_area, &sel, &pos);
            if ((status = _NFFvalid_sa
                (NFFglobal.storage_area)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.storage_area, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
              }

            break;

        case SA_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFsa_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFsa_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case NODE_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_NODENAME + 1, NFFglobal.node, &sel, &pos);
            if ((status = _NFFvalid_node
                (NFFglobal.node)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.node, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
              }

            break;

        case NODE_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFnode_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFnode_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case USER_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_USERNAME + 1, NFFglobal.user, &sel, &pos);
            if ((status = _NFFvalid_user
                (NFFglobal.user)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.user, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
              }

            break;

        case USER_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFuser_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFuser_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case WF_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_WORKFLOWNAME + 1, NFFglobal.workflow, &sel, &pos);
            if ((status = _NFFvalid_wf
                (NFFglobal.workflow)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.workflow, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
                strcpy (NFFglobal.acl, "");
                FIfld_set_text (form, ACL_FIELD, 0, 0, "", FALSE);
              }

            break;

        case WF_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFwf_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFwf_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
                break;
              }

            FIfld_set_text (form, ACL_FIELD, 0, 0, "", FALSE);
            strcpy (NFFglobal.acl, "");

            break;

        case ACL_FIELD:

            FIfld_get_text (form, g_label, 0, 0,
                NFM_ACLNAME + 1, NFFglobal.acl, &sel, &pos);
            if ((status = _NFFvalid_acl
                (NFFglobal.workflow, NFFglobal.acl)) != NFI_S_SUCCESS)
              {
                strcpy (NFFglobal.acl, "");
                FIfld_set_text (form, g_label, 0, 0, "", FALSE);
              }

            break;

        case ACL_POPUP:

            if (NFFglobal.popup_form != NULL)
              {
                status = NFI_W_COMMAND_COMPLETE;
                ERRload_struct (NFI, status, NULL);
                FIg_set_state_off (form, g_label);
                break;
              }

            if ((status = NFFacl_popup ()) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname, "NFFacl_popup = <0x%.8x>\n", status));
                FIg_set_state_off (form, g_label);
              }

            break;

        case FI_CANCEL:

            FIf_erase (form);

            break;

        case COLLAPSE_BUTTON:

            /*  This will cause all forms (and menus) to collapse
                with only the collapse symbol for the main form remaining  */

            FIf_collapse (form);

            /*  Get the pointers to the menus  */

            FI_get_form_by_name ("BAR_MENU", &form);
            FIf_erase (form);
            FI_get_form_by_name ("PANEL_MENU", &form);
            FIf_erase (form);

            for (i = 1; i < NUMBER_OF_FORMS; ++i)
              {
                if (NFFglobal.forms[i] != NULL)
                   FIf_erase (NFFglobal.forms[i]);
              }

            if (NFFglobal.current_form != NULL)
                FIf_erase (NFFglobal.current_form);

            if (NFFglobal.debug_form != NULL)
                FIf_erase (NFFglobal.debug_form);

            if (NFFglobal.popup_form != NULL)
                FIf_erase (NFFglobal.popup_form);

            if (NFFglobal.error_form != NULL)
                FIf_erase (NFFglobal.error_form);

            if (NFFglobal.add_util_sa_form != NULL)
                FIf_erase (NFFglobal.add_util_sa_form);

	    /*  If Help is active, remove the help window */

	    if (NFFglobal.Help_initialized == TRUE)
	      {
	          Help_active (&NFFglobal.Help_was_displayed);

                if( !NFFglobal.Help_was_displayed )
                  {
                  _NFIdebug ((fname, "Help was NOT displayed\n" ));
                  }
		else
		  {	
		    Help_remove();
		  }
	      }
	
            /*  Set a flag to let the next function
                know that everything has been erased  */

            NFFglobal.collapse_flag = TRUE;

            break;
      }

    _NFIdebug ((fname, "returning <0x%.8x> ...\n", status));
    return (status);
  }


void _NFFmain_window_event_routine (f_label, event, form)
  int     f_label;
  int     event;
  Form    form;
  {
    auto    int   i;
    static  char  *fname = "_NFFmain_window_event_routine";

    f_label = f_label;


    if ((event != FI_DISPLAY) || (NFFglobal.collapse_flag == FALSE)) return;

    _NFIdebug ((fname, "event = <%d>\n", event));

    _NFIdebug ((fname, "NFFglobal.Help_was_displayed <%d>\n",
                           NFFglobal.Help_was_displayed ));

    /*  Get the pointers to the menus  */
    
    _NFIdebug ((fname, "getting BAR_MENU pointer ...\n"));
    FI_get_form_by_name ("BAR_MENU", &form);
    FIf_display (form);
    _NFIdebug ((fname, "getting PANEL_MENU pointer ...\n"));
    FI_get_form_by_name ("PANEL_MENU", &form);
    FIf_display (form);

    for (i = 1; i < NUMBER_OF_FORMS; ++i)
       {
         if (NFFglobal.forms[i] != NULL)
             {
             _NFIdebug(( fname, "Displaying NFFglobal.form[%d]\n", i ));
             FIf_display (NFFglobal.forms[i]);
             }
       }

    if (NFFglobal.current_form != NULL)
        {
        _NFIdebug(( fname, "Displaying NFFglobal.current_form\n" ));
        FIf_display (NFFglobal.current_form);
        }

    if (NFFglobal.debug_form != NULL)
        {
        _NFIdebug(( fname, "Displaying NFFglobal.debug_form\n" ));
        FIf_display (NFFglobal.debug_form);
        }


    if (NFFglobal.popup_form != NULL)
        {
        _NFIdebug(( fname, "Displaying NFFglobal.popup_form\n" ));
        FIf_display (NFFglobal.popup_form);
        }

    if (NFFglobal.error_form != NULL)
        {
        _NFIdebug(( fname, "Displaying NFFglobal.error_form\n" ));
        FIf_display (NFFglobal.error_form);
        }

    if (NFFglobal.add_util_sa_form != NULL)
        {
        _NFIdebug(( fname, "Displaying NFFglobal.add_util_sa_form\n" ));
        FIf_display (NFFglobal.add_util_sa_form);
        }

    /*  If Help was displayed at collapse time, put it back */

    if( NFFglobal.Help_was_displayed && NFFglobal.Help_initialized )
    {
        Help_display();
        NFFglobal.Help_was_displayed = FALSE;
    }

    /*  Set the flag back  */

    NFFglobal.collapse_flag = FALSE;

    _NFIdebug ((fname, "returning ...\n"));
    return;
  }
