
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "WFF.h"
#include "WFFpersist.h"
#include "WFFlist.h"
#if (!defined(OS_SUNOS) && !defined(OS_SOLARIS) && !defined(OS_SCO_UNIX))
#include <varargs.h> /* Line commented for SUN/SCO - SSRS */
#endif

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;
extern int WFF_MAX_LISTING_COLS;

long _WFFinit_main ()
  {
	int		vs, status;
	int		attr_mask;
	int		xsize, ysize;
	struct	scr_info info[MAX_SCREENS];

	static	char *fname = "_WFFinit_main";

	/*  WFF functions  */

	long	_WFFmain_notify ();
	void	_WFFmain_set_server ();
	void	_WFFmain_set_env ();
	void	_WFFmain_set_username ();

	void _WFFnotify ();

	/*  Forms Interface functions  */

	int FIf_new ();
	int FIf_display ();

	_NFIdebug ((fname, "entering\n"));

	/*  Get information about the current virtual screen  */
#ifndef XWINDOWS
	if (status = Inq_screen_info (info))
	  {
		_NFIdebug ((fname, "Inq_screen_info = %d\n", status));
		ERRload_struct
			(NFI, NFI_E_GRAPHICS, "%s%d", "Inq_screen_info", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_GRAPHICS);
	  }

	if (status = Inq_displayed_vs (&vs))
	  {
		_NFIdebug ((fname, "Inq_displayed_vs = %d\n", status));
		ERRload_struct
			(NFI, NFI_E_GRAPHICS, "%s%d", "Inq_screen_info", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_GRAPHICS);
	  }

	if (info[vs].vsi_screen_num == -1)
	  {
	    _NFIdebug ((fname, "error getting screen info\n"));
	    ERRload_struct (NFI, NFI_E_GRAPHICS, "%s%d", "screen number", -1);
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_GRAPHICS);
	  }

	if ((info[vs].vsi_flags & VSI_VIRTUAL_SCREEN) == 0)
	  {
	    _NFIdebug ((fname, "virtual screen %d is not usable\n", vs));
  	    ERRload_struct (NFI,
		  NFI_E_GRAPHICS, "%s%d", "virtual screen is not usable", vs);
  	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_GRAPHICS);
	  }
#endif
	/*  Load the form into memory  */

	if ((status = FIf_new (MAIN_FORM_LABEL, MAIN_FORM,
		_WFFnotify, &(WFFglobal.main_form))) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_new = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Set the current server and environment on the form  */

	_WFFmain_set_server (WFFglobal.server);
	_WFFmain_set_env (WFFglobal.environment);
	_WFFmain_set_username (WFFglobal.username);

	/*  Position the form on the screen  */

	if ((status = FIf_get_size
		(WFFglobal.main_form, &xsize, &ysize)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_get_size = <%d>\n", status));
		FIf_delete (WFFglobal.main_form);
		WFFglobal.main_form = NULL;
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }
/* PS */
        _NFIdebug ((fname, "FIf_get_size  xsize= <%d>, ysize= <%d>\n", xsize, ysize));

#ifdef XWINDOWS
        /* In case of X this structure is uninitialized - IGI - 7 Jul 94 */
        vs = 0;
        info[vs].vsi_x = 0;
#endif
	if ((status = (int) _WFFcenter_form (WFFglobal.main_form,
		info[vs].vsi_x - (PANEL_MENU_WIDTH + 5) - xsize,
		WFFglobal.bar_menu_height + 5)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFcenter_form = %d\n", status));
		FIf_delete (WFFglobal.main_form);
		WFFglobal.main_form = NULL;
		_NFIdebug ((fname, " returning FAILURE\n"));
		return ((long) status);
	  }

	/*  Hide the scroll bars on the top mcfs  */

        FImcf_get_attr (WFFglobal.main_form, HIDDEN_TOP_LEFT_MCF, &attr_mask);
        attr_mask |= FI_DISABLE_VSCROLL | FI_DISABLE_HSCROLL;
        FImcf_set_attr (WFFglobal.main_form, HIDDEN_TOP_LEFT_MCF, attr_mask);

        FImcf_get_attr (WFFglobal.main_form, HIDDEN_TOP_RIGHT_MCF, &attr_mask);
        attr_mask |= FI_DISABLE_VSCROLL | FI_DISABLE_HSCROLL;
        FImcf_set_attr (WFFglobal.main_form, HIDDEN_TOP_RIGHT_MCF, attr_mask);


	/*  Blank out the message field  */

	_WFFclear_msg (WFFglobal.main_form);


	/*  Display the form  */

	if ((status = FIf_display (WFFglobal.main_form)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_display = <%d>\n", status));
		FIf_delete (WFFglobal.main_form);
		WFFglobal.main_form = NULL;
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _WFFmain_notify (g_label, value, form)
  int		g_label;
  double	value;
  Form		form;
  {
	int		status = NFI_S_SUCCESS;
	char	filename[120];
	short	display_message = TRUE;

	static	char *fname = "_WFFmain_notify";

	/*  Local functions  */

	void	_WFFmain_set_wf ();

	long	_WFFmain_get_text ();
	/* long	_WFFhidden_data_mcf (); */
        long    _WFFprocess_list_mcf (); 
	void	_WFFmain_message ();

	void _WFFexit ();
	void _WFFmain_error_button ();
	long _WFFmain_print_listing ();

	_NFIdebug ((fname, "g_label = <%d>\n", g_label));
	_NFIdebug ((fname, "value   = <%d>\n", value));

	/*  Find out if the global error structure needs to be cleared out  */

	switch (g_label)
	  {
		case FI_HELP:

		case WORKFLOW_BUTTON:
		case WORKFLOW_FIELD:
		case PRINT_REPORT:

			/*  Clear out the structure  */

			ERRreset_struct ();

			break;

		case FI_CANCEL:
		case ERROR_BUTTON:

                case TOP_LEFT_MCF:
                case TOP_RIGHT_MCF:
                case BOTTOM_LEFT_MCF:
                case BOTTOM_RIGHT_MCF:

			/*  Do NOT clear out the structure  */

			break;

		default:
			break;
	  }

	switch (g_label)
	  {
		case FI_HELP:

	  	    /*  Bring up the help form with the table of contents  */

  		    if (status = _WFFhelp_toc ())
		      {
			_NFIdebug ((fname, "_WFFhelp_toc = <%d>\n", status));
 		        status = NFI_E_HELP;
      		      }
		    else
		      {
			status = NFI_S_SUCCESS;
   		      }

  		    break;

		case FI_CANCEL:

			/*  Perform orderly exit  */

			_WFFexit (NFI_S_SUCCESS);

		case ERROR_BUTTON:

			/*  Bring up the error message form  */

			_WFFmain_error_button ();
			break;

                case WORKFLOW_BUTTON:
                        _WFFprocess_data (0, WFF_M_DISPLAY_WORKFLOWS_SHORT);

                        if (WFFglobal.cmd_status != NFI_S_SUCCESS)
                          {
                                /*  Pop the button back up  */

                                FIg_set_state_off (form, g_label);
                          }
                        else
                          {
                                /*  Do not display the message  */

                                display_message = FALSE;
                          }

                        break;

                case WORKFLOW_FIELD:
                   if ((status = _WFFmain_get_text
                                 (form, g_label)) != NFI_S_SUCCESS)
                    {
                       if (status == NFI_E_FAILURE)
                         {
                           /*  The field was cleared out  */
       
                           _WFFmain_set_wf ("");
                           display_message = FALSE;
                         }
                       else
                         {
                           /*  An error occurred  */
       
                           _WFFmain_set_wf ("");
                         }

                	break;
                    }

                  status = WFFvalidate_workflow (WFFglobal.workflow);
                  if (status != NFI_S_SUCCESS)
                     _WFFmain_set_wf ("");

                break;


		case PRINT_REPORT:
			status = _WFFmain_print_listing
				(form, TOP_LEFT_MCF, TOP_RIGHT_MCF, filename);
			FIg_set_state_off (form, g_label);
			break;

		case TOP_LEFT_MCF:
                        _NFIdebug ((fname, "label is TOP_LEFT_MCF\n"));
                        status = _WFFmain_top_left_mcf (form, (int) value);
                        if (status == NFI_S_SUCCESS)
                                display_message = FALSE;
			break;

                 case BOTTOM_LEFT_MCF:
                        _NFIdebug ((fname, "label is BOTTOM_LEFT_MCF\n"));
                        status = _WFFmain_bottom_left_or_right_mcf
                                (form, BOTTOM_LEFT_MCF, BOTTOM_RIGHT_MCF, (int) value);
                        if (status == NFI_S_SUCCESS)
                                display_message = FALSE;
                        break;

                case BOTTOM_RIGHT_MCF:
                        _NFIdebug ((fname, "label is BOTTOM_RIGHT_MCF\n"));
                        status = _WFFmain_bottom_left_or_right_mcf
                                (form, BOTTOM_RIGHT_MCF, BOTTOM_LEFT_MCF, (int) value);
                        if (status == NFI_S_SUCCESS)
                                display_message = FALSE;
                        break;

                 default:
                        display_message = FALSE;
                        break;
                 
	  }

	/*  Display any messages  */

	if (display_message == TRUE)
		_WFFmain_message ();

	_NFIdebug ((fname, " returning <0x%.8x>\n", status));
	return (status);
  }

void _WFFmain_message ()
  {
	_WFFerror_message (WFFglobal.main_form);
	return;
  }



long _WFFmain_top_left_mcf (form, row)
  Form  form;
  int   row;
  {
        int             selected;
        /* int             col, pos;
        int             position;
        */ 
        int             status;

        int             label1 = TOP_LEFT_MCF;
        int             label2 = TOP_RIGHT_MCF;

        static  char *fname = "_WFFmain_top_left_mcf";

        _NFIdebug ((fname, "row = <%d>\n", row));

        /*  See if the row select box was selected  */

        if (row == -1)
          {
                /*  Find out if the row is selected or not  */

                if ((status = FImcf_get_select
                        (form, label1, 0, &selected)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FImcf_get_select = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FImcf_get_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                 /*  Select or unselect this entire row on the bottom right mcf  */

                if ((status = FImcf_set_select
                        (form, label2, 0, selected)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }
          }

        _NFIdebug ((fname, "returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
  }



long _WFFmain_bottom_left_or_right_mcf (form, label1, label2, row)
  Form  form;
  int   label1;
  int   label2;
  int   row;
  {
        int             selected;
        int             col, pos;
        int             position;
        long            status;

        static  char *fname = "_WFFmain_bottom_left_or_right_mcf";

        /*  Local functions  */

        long    _WFFmain_bottom_mcf ();

        _NFIdebug ((fname, "label1 = <%d>\n", label1));
        _NFIdebug ((fname, "label2 = <%d>\n", label2));
        _NFIdebug ((fname, "row = <%d>\n", row));

        /*  See if the row select box was selected  */

        if (row == -1)
          {
                _NFIdebug ((fname, "row select box was selected\n"));

                /*  Find out which row was selected  */

                if ((status = (long) FIfld_get_active_row
                        (form, label1, &row, &pos)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                 /*  Find out if the row is selected or not  */

                if ((status = (long) FImcf_get_select
                        (form, label1, row, &selected)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FImcf_get_select = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FImcf_get_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                /*  Select or unselect this entire row on the bottom right mcf  */

                if ((status = (long) FImcf_set_select
                        (form, label2, row, selected)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                if (selected == FALSE)
                  {
                        _NFIdebug ((fname, "Row was unselected with the checkbox\n"));
                        _NFIdebug ((fname, " returning SUCCESS\n"));
                        return (NFI_S_SUCCESS);
                  }
          }
         else if (row == -2)
          {
                _NFIdebug ((fname, "columns are scrolling\n"));

                /*  Refresh the top and bottom left mcfs to clean up the display  */

                if ((status = (long) FIg_display (form, TOP_LEFT_MCF)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
                        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                if ((status = (long) FIg_display (form, BOTTOM_LEFT_MCF)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FIg_display = <%d>\n", status));
                        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                _NFIdebug ((fname, " returning SUCCESS\n"));
                return (NFI_S_SUCCESS);
          }
         else if (row == -3)
          {
                _NFIdebug ((fname, "rows are scrolling\n"));

                if ((status = (long) FIfld_get_active_row
                        (form, label1, &row, &position)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                _NFIdebug ((fname, "active row = <%d>\n", row));
                _NFIdebug ((fname, "position = <%d>\n", position));

                /*  Sync up the left and right mcfs  */

                if ((status = (long) FIfld_set_active_row
                        (form, label2, row, position)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FIfld_set_active_row = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_row", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                _NFIdebug ((fname, " returning SUCCESS\n"));
                return (NFI_S_SUCCESS);
          }
         else
          {
                /*  Find out if the row is selected or not  */

                _NFIdebug ((fname, "Calling FImcf_get_active_col\n"));
                if ((status = (long) FImcf_get_active_col
                        (form, label1, &col, &pos)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FImcf_get_active_col = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FImcf_get_active_col", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                if ((status = (long) FIfld_get_select
                        (form, label1, row, col, &selected)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                /*  Select or unselect this entire row  */

                _NFIdebug ((fname, " Select or unselect row <%d>, label1 <%d>\n",
                            row, label1));
                if ((status = (long) FImcf_set_select
                        (form, label1, row, selected)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                /*  Select or unselect this entire row on the bottom right mcf  */

                _NFIdebug ((fname, " Select or unselect row <%d>, label2 <%d>\n",
                            row, label2));
                if ((status = (long) FImcf_set_select
                        (form, label2, row, selected)) != FI_SUCCESS)
                  {
                        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
                        ERRload_struct
                                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
                        _NFIdebug ((fname, " returning FAILURE\n"));
                        return (NFI_E_FORM);
                  }

                if (selected == FALSE)
                  {
                        _NFIdebug ((fname, "Row was unselected\n"));
                        _NFIdebug ((fname, " returning SUCCESS\n"));
                        return (NFI_S_SUCCESS);
                  }
          }

        status = _WFFmain_bottom_mcf (form, row);
        _NFIdebug ((fname, "returning : status = <%d>\n", status));

        return (status);
  }



long _WFFmain_bottom_mcf (form, row)
  Form  form;
  int   row;
  {
        char    *name;
        long    status;

        static  char *fname = "_WFFmain_bottom_mcf";

        /*  Local functions  */

        long    _WFFmain_find_name ();
        long    _WFFmain_set_field ();

        _NFIdebug ((fname, "row = <%d>\n", row));

        /*  Find the selected "name" in the list_buffer  */

        if ((status = _WFFmain_find_name (&name, row)) != NFI_S_SUCCESS)
          {
                _NFIdebug ((fname, "_WFFmain_find_name = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
          }

        /*  Copy the selected info into the appropriate field  */

        if ((status = _WFFmain_set_field (name, WFF_MCF_LIST)) != NFI_S_SUCCESS)
          {
                _NFIdebug ((fname, "_WFFmain_set_field = <0x%.8x>\n", status));
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (status);
          }

        _NFIdebug ((fname, "returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
  }



long _WFFprocess_list_mcf (form, label, column, current_list)
  Form      form;
  int       label;
  int       column;
  int       current_list;
  {
        int   status;
        int   row = -1, rows = -1, i;
        int   num_chars = 256;
        int   r_pos = -1, sel_flag = -1;
        char  text [256];
        static char *fname = "_WFFprocess_list_mcf";

        void _WFFmain_set_wf ();

	_NFIdebug ((fname, " G_label      = <%d>\n", label));
	_NFIdebug ((fname, " Text Column  = <%d>\n", column));
	_NFIdebug ((fname, " Current List = <%d>\n", current_list));

        switch (current_list)
         {
             case WFF_LIST_WORKFLOWS:

	        _NFIdebug ((fname, " Attempting to update Field.\n"));

                /* find out which row was selected */

                status = FIfld_get_num_rows (form, label, &rows);
                if (status != FI_SUCCESS)
                 {
		     _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
		     ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                     "FIfld_get_num_rows", status);
		     _NFIdebug ((fname, " returning FAILURE\n"));
		     return (NFI_E_FORM);
                 }  

                if (rows <= 0)
                 {
                     status = NFI_E_BUFFER;
		     _NFIdebug ((fname, "No rows exist in the list = <%d>\n",
                                 status));
		     ERRload_struct (NFI, status, NULL);
		     _NFIdebug ((fname, " returning FAILURE\n"));
		     return ((long) status);
                 }

                for (i = 0; i < rows; ++i)
                 {
                    /* find out which row was selected (if any) */  
                    
                    status = FIfld_get_text (form, label, i, column, num_chars, 
                                             text, &sel_flag, &r_pos);
                    if (status != FI_SUCCESS)
                     {
		         _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
		         ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                         "FIfld_get_text", status);
		         _NFIdebug ((fname, " returning FAILURE\n"));
		         return (NFI_E_FORM);
                     }  

                    if (sel_flag)
                     {
                        row = i;
		        _NFIdebug ((fname, "text = <%d>\n", text));
                        break;
                     }
                 }  

                if (row == -1)  /* may want to handle this differently */
                 {
                    status = NFI_S_SUCCESS;
	            _NFIdebug ((fname, " : No row selected.\n"));
	            _NFIdebug ((fname, " : status = <0x%.8x>\n", status));
	            return ((long) status);
                 }

                /* call the appropriate wf_set function and update the 
                   global structure WFFglobal.                          */ 

                switch (current_list)  /* add additional cases here */
                 {
                     case WFF_LIST_WORKFLOWS:
                        _WFFmain_set_wf (text);
                     break;
                 } 

             break;

             case -1:
                status = NFI_S_SUCCESS;
	        _NFIdebug ((fname, " : No current list exist.\n"));
	        _NFIdebug ((fname, " : status = <0x%.8x>\n", status));
             break;

             default:
                status = NFI_E_INVALID_INPUT;
	        _NFIdebug ((fname, "Bad List : status = <%d>\n", status));
		ERRload_struct (NFI, status, "%d", current_list);
	        _NFIdebug ((fname, "returning failure\n"));
             break;
         }

	_NFIdebug ((fname, "returning : status = <%d>\n", status));

	return ((long) status);
  }


long _WFFmain_find_name (name, row)
  char	**name;
  int	row;
  {
	char	column[40];
	char	**data_ptr;
	long	status;
	short	nfm_offset;
	MEMptr	buffer = NULL;

	static	char *fname = "_WFFmain_find_name";

	_NFIdebug ((fname, "row = <%d>\n", row));

	switch (WFFglobal.current_list)
	  {
		case WFF_LIST_WORKFLOWS:
			strcpy (column, "n_workflowname");
			break;

/*
		case WFF_LIST_ACLS:
			strcpy (column, "n_aclname");
			break;
*/

		default:
			_NFIdebug ((fname,
				"invalid list type <%d>\n", WFFglobal.current_list));
			ERRload_struct (NFI, NFI_E_INVALID_INPUT, NULL);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_INVALID_INPUT);
	  }

	/*  Find the NFM attribute name in the data_list  */

	buffer = WFFglobal.list_buffer;

	if ((status = _WFFfind_column_offset
		(buffer, column, &nfm_offset)) != NFI_S_SUCCESS)
	  {
	      _NFIdebug ((fname, "_WFFfind_column_offset = <0x%.8x>\n", status));
	      _NFIdebug ((fname, " returning FAILURE\n"));
	      return (status);
	  }

	_NFIdebug ((fname, "Name Offset = <%d>\n", nfm_offset));

	/*  Find the selected "name" in the list_buffer  */

	/*  NOTE:  It is assumed that there is a 1:1
	    mapping between the buffer and the listing mcf  */

	data_ptr = (char **) buffer->data_ptr;
	*name = data_ptr[(row * buffer->columns) + nfm_offset];

	_NFIdebug ((fname, "returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _WFFmain_set_field (name, type)
  char	*name;  /*  i - text to put in the appropriate field  */
  int	type;   /*  i - WFF_POPUP_LIST or WFF_MCF_LIST        */
  {
	int		switch_type = -1;
	/* char	*revision; */

	static	char *fname = "_WFFmain_set_field";

	/*  Local functions  */

	void	_WFFmain_set_wf ();
	void	_WFFmain_set_acl ();

	if (name == NULL)
	  {
		_NFIdebug ((fname, " returning SUCCESS\n"));
		return (NFI_S_SUCCESS);
	  }

	_NFIdebug ((fname, "name = <%s>\n", name));
	_NFIdebug ((fname, "type = <%d>\n", type));

	switch (type)
	  {
		case WFF_POPUP_LIST:
			switch_type = WFFglobal.current_popup;
			break;

		case WFF_MCF_LIST:
			switch_type = WFFglobal.current_list;
			_NFIdebug ((fname,
				"unknown list type <%d>\n", type));
			break;

		default:
			_NFIdebug ((fname, "unknown list type <%d>\n", type));
			break;
	  }

	switch (switch_type)
	  {
		case WFF_LIST_WORKFLOWS:
			_WFFmain_set_wf (name);
			break;

/*
		case WFF_LIST_ACLS:
			_WFFmain_set_acl (name);
			break;
*/

		default:
			_NFIdebug ((fname,
				"invalid list type <%d>\n", WFFglobal.current_list));
			ERRload_struct (NFI, NFI_E_INVALID_INPUT, NULL);
			_NFIdebug ((fname, "returning FAILURE\n"));
			return (NFI_E_INVALID_INPUT);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


void _WFFmain_set_wf (workflow)
  char	*workflow;
  {
        static char *fname = "_WFFmain_set_wf";
	void	_WFFmain_set_acl ();

	strncpy (WFFglobal.workflow, workflow, sizeof (WFFglobal.workflow) - 1);
        _NFIdebug ((fname, "workflow = <%s>\n", WFFglobal.workflow));
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	_NFIdebug ((fname, "Setting font for SCO\n" ));
	FIg_set_font(WFFglobal.main_form, WORKFLOW_FIELD, "7x13bold", 15);
#endif
        FIfld_set_text (WFFglobal.main_form, WORKFLOW_FIELD, 0, 0, workflow,
                        FALSE); 
	/* _WFFmain_set_acl (""); */
        return;
  }


void _WFFmain_set_acl (acl_name)
  char	*acl_name;
  {
	strncpy (WFFglobal.acl, acl_name, sizeof (WFFglobal.acl) - 1);
        return;
  }


void _WFFmain_set_server (server)
  char	*server;
  {
	if (WFFglobal.main_form == NULL) return;

	FIg_erase (WFFglobal.main_form, SERVER_TEXT);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(WFFglobal.main_form, SERVER_TEXT, "7x13bold", 15);
#endif
	FIg_set_text (WFFglobal.main_form, SERVER_TEXT, server);
	FIg_display (WFFglobal.main_form, SERVER_TEXT);
        return;
  }


void _WFFmain_set_env (environment)
  char	*environment;
  {
	int		xpos, ypos;
	int		xsize, ysize;
	int		text_xpos, text_ypos;
	int		text_xsize, text_ysize;
	int		right_margin, distance;

	/*  Right justify the current environment on the main form  */

	if (WFFglobal.main_form == NULL) return;

	FIg_erase (WFFglobal.main_form, ENV_LABEL);
	FIg_erase (WFFglobal.main_form, ENV_TEXT);

	/*  Get the right margin from the current text in ENV_TEXT  */

	FIg_get_location (WFFglobal.main_form, ENV_TEXT, &text_xpos, &text_ypos);
	FIg_get_size (WFFglobal.main_form, ENV_TEXT, &text_xsize, &text_ysize);

	right_margin = text_xpos + text_xsize;

	/*  Calculate the distance between ENV_LABEL and ENV_TEXT  */

	FIg_get_location (WFFglobal.main_form, ENV_LABEL, &xpos, &ypos);
	FIg_get_size (WFFglobal.main_form, ENV_LABEL, &xsize, &ysize);

	distance = right_margin - text_xsize - xsize - xpos;

	/*  Put in the new text  */

	FIg_set_text (WFFglobal.main_form, ENV_TEXT, environment);

	/*  Right justify the ENV_TEXT (all y positions are the same)  */

	FIg_get_size (WFFglobal.main_form, ENV_TEXT, &text_xsize, &text_ysize);
	FIg_set_location
		(WFFglobal.main_form, ENV_TEXT, right_margin - text_xsize, ypos);

	/*  Position the ENV_LABEL the proper distance from the ENV_TEXT  */

	FIg_set_location (WFFglobal.main_form,
		ENV_LABEL, right_margin - text_xsize - distance - xsize, ypos);

	FIg_display (WFFglobal.main_form, ENV_LABEL);
	FIg_display (WFFglobal.main_form, ENV_TEXT);
        return;
  }


void _WFFmain_set_username (username)
  char	*username;
  {
	int		xpos, ypos;
	int		xsize, ysize;
	int		text_xpos, text_ypos;
	int		text_xsize, text_ysize;
	int		form_xsize, form_ysize;
	int		distance, center_x, total_length, new_xpos;

	if (WFFglobal.main_form == NULL) return;

	FIg_erase (WFFglobal.main_form, USER_LABEL);
	FIg_erase (WFFglobal.main_form, USER_TEXT);

	/*  Calculate the distance between USER_LABEL and USER_TEXT  */

	FIg_get_location (WFFglobal.main_form, USER_LABEL, &xpos, &ypos);
	FIg_get_size (WFFglobal.main_form, USER_LABEL, &xsize, &ysize);
	FIg_get_location (WFFglobal.main_form, USER_TEXT, &text_xpos, &text_ypos);

	distance = text_xpos - xsize - xpos;

	/*  Find the center of the form  */

	FIf_get_size (WFFglobal.main_form, &form_xsize, &form_ysize);

	center_x = form_xsize / 2;

	/*  Put in the new text  */

	FIg_set_text (WFFglobal.main_form, USER_TEXT, username);

	/*  Calculate the total length of all data to be centered  */

	FIg_get_size (WFFglobal.main_form, USER_TEXT, &text_xsize, &text_ysize);

	total_length = xsize + distance + text_xsize;

	/*  Center justify the USER_LABEL  */

	FIg_set_location (WFFglobal.main_form,
		USER_LABEL, center_x - (total_length / 2), ypos);

	/*  Center justify the USER_TEXT  */

	if ((total_length / 2) < text_xsize)
		new_xpos = center_x - (text_xsize - (total_length / 2));
	else
		new_xpos = center_x + ((total_length / 2) - text_xsize);

	FIg_set_location (WFFglobal.main_form, USER_TEXT, new_xpos, ypos);

	FIg_display (WFFglobal.main_form, USER_LABEL);
	FIg_display (WFFglobal.main_form, USER_TEXT);
        return;
  }


void _WFFmain_set_user (user)
  char  *user;
  {
        strncpy (WFFglobal.username, user, sizeof (WFFglobal.username) - 1);
  }


void _WFFmain_blank_listing (listing_type)
  int	listing_type;
  {
	int		i, j;
	int		status;
	int		rows, columns;

	static	char *fname = "_WFFmain_blank_listing";

	_NFIdebug ((fname, "listing_type = <%d>\n", listing_type));
	_NFIdebug ((fname, "current_list = <%d>\n", WFFglobal.current_list));

	if ((listing_type != WFF_ALL_LISTS) &&
		(WFFglobal.current_list != listing_type))
	  {
		_NFIdebug ((fname, "current list does not match; returning\n"));
		return;
	  }

	WFFglobal.current_list = -1;

	MEMclose (&(WFFglobal.attr_list));
	MEMclose (&(WFFglobal.list_buffer));

	if ((status = FIfld_get_num_rows
		(WFFglobal.main_form, BOTTOM_LEFT_MCF, &rows)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_get_num_rows = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning\n"));
		return;
	  }

	if ((status = FImcf_get_num_cols
		(WFFglobal.main_form, TOP_LEFT_MCF, &columns)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FImcf_get_num_cols = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning\n"));
		return;
	  }

	if ((rows < 0) || (columns < 0))
	  {
		_NFIdebug ((fname, "rows or columns < 0; returning\n"));
		return;
	  }

	if ((status = FIg_erase
		(WFFglobal.main_form, LISTING_TITLE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_display = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning\n"));
		return;
	  }

	if ((status = FIg_set_text
		(WFFglobal.main_form, LISTING_TITLE, "")) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_set_text = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning\n"));
		return;
	  }

	if ((status = FIg_display
		(WFFglobal.main_form, LISTING_TITLE)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_display = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning\n"));
		return;
	  }

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(WFFglobal.main_form, BOTTOM_LEFT_MCF, "7x13bold", 15);
	FIg_set_font(WFFglobal.main_form, TOP_LEFT_MCF, "7x13bold", 15);
#endif
	for (i = 0; i < columns; ++i)
	  {
		if ((status = FIfld_set_text (WFFglobal.main_form,
			TOP_LEFT_MCF, 0, i, "", FALSE)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_text = <0x%.8x>\n", status));
			_NFIdebug ((fname, " returning\n"));
			return;
		  }

		for (j = 0; j < rows; ++j)
		  {
			if ((status = FIfld_set_text (WFFglobal.main_form,
				BOTTOM_LEFT_MCF, j, i, "", FALSE)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIfld_set_text = <0x%.8x>\n", status));
				_NFIdebug ((fname, " returning\n"));
				return;
			  }
		  }
	  }

	if ((status = FIfld_get_num_rows
		(WFFglobal.main_form, BOTTOM_RIGHT_MCF, &rows)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_get_num_rows = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning\n"));
		return;
	  }

	if ((status = FImcf_get_num_cols
		(WFFglobal.main_form, TOP_RIGHT_MCF, &columns)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FImcf_get_num_cols = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning\n"));
		return;
	  }

	if ((rows < 0) || (columns < 0))
	  {
		_NFIdebug ((fname, "rows or columns < 0; returning\n"));
		return;
	  }

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(WFFglobal.main_form, BOTTOM_RIGHT_MCF, "7x13bold", 15);
	FIg_set_font(WFFglobal.main_form, TOP_RIGHT_MCF, "7x13bold", 15);
#endif
	for (i = 0; i < columns; ++i)
	  {
		if ((status = FIfld_set_text (WFFglobal.main_form,
			TOP_RIGHT_MCF, 0, i, "", FALSE)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_text = <0x%.8x>\n", status));
			_NFIdebug ((fname, " returning\n"));
			return;
		  }

		for (j = 0; j < rows; ++j)
		  {
			if ((status = FIfld_set_text (WFFglobal.main_form,
				BOTTOM_RIGHT_MCF, j, i, "", FALSE)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIfld_set_text = <0x%.8x>\n", status));
				_NFIdebug ((fname, " returning\n"));
				return;
			  }
		  }
	  }

	_NFIdebug ((fname, "returning\n"));
	return;
  }


long _WFFmain_get_text (form, label)
  Form    form;
  int    label;
  {
    int        length;
    int        selected;
    int        pos;
    int        status;
    char    *text;

    static    char *fname = "_WFFmain_get_text";

    _NFIdebug ((fname, "label = %d\n", label));

    /*  Allocate space for the data  */

    if ((status = FIfld_get_text_length
        (form, label, 0, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (length <= 0)
      {
        _NFIdebug ((fname, "no text was keyed in\n"));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FAILURE);
      }

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
    /* To set font for SCO - 2 Mar 94 */
    FIg_set_font( form, label, "7x13bold", 15);
#endif

    if ((status = FIfld_get_text
        (form, label, 0, 0, length, text, &selected, &pos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((strcmp (text, "")) == 0)
      {
        _NFIdebug ((fname, "no text was keyed in\n"));
        if (text) free (text);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FAILURE);
      }

    /*  Put the text into the global structure  */

    switch (label)
      {
        case WORKFLOW_FIELD:

            /*  Convert to lower-case  */

            /* for (i = 0; i < strlen (text); ++i)
                text[i] = tolower (text[i]); */

            strncpy (WFFglobal.workflow, text,
                (sizeof (WFFglobal.workflow)) - 1);

            /*  Put the workflow name back
                in the field on the main form  */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(WFFglobal.main_form, label, "7x13bold", 15);
#endif
            FIfld_set_text
                (WFFglobal.main_form, label, 0, 0, WFFglobal.workflow, FALSE);

            break;


/*
        case REPORT_FIELD:
            strncpy (WFFglobal.report, text,
                (sizeof (WFFglobal.report)) - 1);
             ;
            break;
*/
      }

    if (text) free (text);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

