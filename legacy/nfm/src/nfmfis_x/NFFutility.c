
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFutility.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFprocess_ab_items_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    int     working_message = 0;
    int     error_message;
    int     g_state = FALSE;
    long    status;
    char    help_command[15];
    char    sa_no[16];
    char    full_server_name[20];
    MEMptr  flist = NULL;
    MEMptr  msg_buffer = NULL;
    
    static    char *fname = "_NFFprocess_ab_items_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFutil_ptr    ptr;

    _NFIdebug ((fname, "g_label = %d\n", g_label));

     /***********************************************************************
       The msg_buffer is used by the archive, backup and restore functions.
       a message row with 3 columns will be returned if the user has choosen
       a storage area of type 'CT', or 'UT' or 'MT'.  This message tells
       where they must run 'Nfmutil'.  the columns will look as follows:
       ----------------------------------------------------------------------
       script               node_name           node_num
       char(50)             char(30)            char(10) 

       The messages from this buffer will be displayed on a separate message
       form.
     *************************************************************************/

    strcpy (sa_no, "");

    /*  Pull out the pointer to the structure  */

    if ((status = (long) FIf_get_user_pointer
        (*form, (char *) &ptr)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
        return (NFI_E_FORM);
     }

    /* Clear out the message strip */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    switch (ptr->type)
     {
         case ARCHIVE_FLAGGED_ITEMS:
             strcpy (help_command, NFI_M_ARCHIVE_FLAGGED_FILES);
         break;

         case BACKUP_FLAGGED_ITEMS:
             strcpy (help_command, NFI_M_BACKUP_FLAGGED_FILES);
         break;

         case RESTORE_FLAGGED_ITEMS:
             strcpy (help_command, NFI_M_RESTORE_FLAGGED_FILES);
         break;

         case DELETE_FLAGGED_ITEMS:
             strcpy (help_command, NFI_M_DELETE_FLAGGED_FILES);
         break;

         default:
             strcpy (help_command, NFI_M_PROCESS_FLAGGED_FILES);
         break;
     } 
    working_message = NFI_I_PROCESS_FLAGGED_ITEMS;
    error_message = NFI_E_PROCESS_FLAGGED_ITEMS;

    status = NFI_S_SUCCESS;

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (help_command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic",
                                status);
                status = NFI_E_HELP;
              }

        break;

        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);
            NFFglobal.status = NFI_W_COMMAND_CANCELLED;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_utility (form, ptr);
            ptr = NULL; 

        break;

        case FI_ACCEPT:

            if ((ptr->type == ARCHIVE_FLAGGED_ITEMS) ||
                (ptr->type == BACKUP_FLAGGED_ITEMS)) 
             {
                status = _NFFcheck_util_user_input (*form, ptr, sa_no, &flist);
                if (status != NFI_S_SUCCESS)
                 {
                    MEMclose (&flist); 
                    FIg_set_state_off (*form, FI_ACCEPT);
                    break;
                 }
             }
            else
             {
                status = _NFFget_util_user_input (*form, ptr, &flist);
                if (status != NFI_S_SUCCESS)
                 {
                    MEMclose (&flist); 
                    FIg_set_state_off (*form, FI_ACCEPT);
                    break;
                 }
             }

            /*  Make the full server name - Glenn 6/8/92  */

#ifndef COMBINED_CLIENT_SERVER
            sprintf (full_server_name, "nfms_%s", NFFglobal.server);
#else
            strcpy (full_server_name, "");
#endif

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, working_message, NULL);

            /*  Call NFMR to process the flagged items  */

            _NFIdebug ((fname, "calling NFMR function ...\n"));

            if ((ptr->type == ARCHIVE_FLAGGED_ITEMS) ||
                (ptr->type == BACKUP_FLAGGED_ITEMS)) 
             {
                status = (long) NFFglobal.NFMRfunction[0] (full_server_name,
                                NFFglobal.environment, NFFglobal.username,
                                NFFglobal.password, sa_no, ptr->label,
                                flist, &msg_buffer);
             }
            else if (ptr->type == DELETE_FLAGGED_ITEMS) 
                status = (long) NFFglobal.NFMRfunction[0] (full_server_name,
                                  NFFglobal.environment, NFFglobal.username,
                                  NFFglobal.password, flist);
            else
	    {
                status = (long) NFFglobal.NFMRfunction[0] (full_server_name,
                                  NFFglobal.environment, NFFglobal.username,
                                  NFFglobal.password, flist, &msg_buffer);
		/*  JM 7/28/94 - this is set here so that we can see a 
		    message buffer for restoring files 'OFF-Line'. We really
		    can't know this for RESTORE but the message buffer != NULL
		    is a sure sign. The same check is made further down for
		    all types of processing so I did not change it
		    there.
		 */
		ptr->utility = TRUE;
	    }

            if (status != NFM_S_SUCCESS)
                _NFIdebug ((fname, "NFMRfunction = <0x%.8x>\n", status));

            MEMclose (&flist); 

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /* removed freeing of form & ptr as
	       ptr->utility is used in the next line -- KMM 27.1.94 */

           if ((msg_buffer != NULL) && (ptr->utility) &&
             (NFFglobal.status == NFM_S_SUCCESS))
              {
                /* Put up the message on the UTI_MSG_FORM form */

                NFFprocess_utility_message (msg_buffer);
              }

            /* form & ptr are freed now.. KMM 27.01.94 */

            _NFFfree_utility (form, ptr);
            ptr = NULL; 

            if (msg_buffer)
               MEMclose (&msg_buffer);

        break;

        case UTI_ITEM_LIST:

            _NFIdebug ((fname, " Selecting or unselecting items.\n"));

        break;

        case UTI_LABEL_FIELD:

            status = _NFFprocess_label_field (*form, ptr->label);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFprocess_label_field <0x%.8x>\n",
                           status));
        break;


        case UTI_LABEL_LIST:

            status = _NFFprocess_label_list (*form, ptr->label);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFprocess_label_list <0x%.8x>\n",
                           status));
        break;

        case UTI_ITEM_TOGGLE:

            /* get the state of the toggle */
            
            status = (long) FIg_get_state (*form, g_label, &g_state);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
                _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
                return (NFI_E_FORM);
             }

            if (g_state)
             {
                status = _NFFgeneric_mcf_select_all_rows (*form, g_label,
                                   UTI_ITEM_LIST, (ptr->item_list)->rows);
                if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFgeneric_mcf_select_all_rows <0x%.8x>\n",
                           status));
             }

            /*  Without this, the "Successful completion" message
                will be displayed when the toggle is selected; we
                don't want that - 5/21/92 Glenn                    */

            else
              {
                status = NFI_S_SUCCESS;
              }

        break;

        case UTI_SA_LIST:

            status = _NFFprocess_util_sa_list (*form, ptr);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFprocess_util_sa_list <0x%.8x>\n",
                           status));

        break;


        case UTI_USER_LABEL_TOGGLE :
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	  FIg_set_font( *form, UTI_LABEL_FIELD, "7x13bold", 15 );
#endif
          if ((status = (long) FIfld_set_text (*form, UTI_LABEL_FIELD, 0, 0,
                                                "", FALSE)) != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
           }

  	 strcpy (ptr->label, "") ;

	    /* display UTI_LABEL_FIELD */
	  if ((status = (long) FIg_display (*form, UTI_LABEL_FIELD)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

         /* erase UTI_LABEL_LIST  */
	 status = _NFFerase_label_list (*form) ;
	 if (status != NFI_S_SUCCESS)
	 {
            _NFIdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	    return (status) ;
	 }

        break;

        case UTI_EXIS_LABEL_TOGGLE :
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	  FIg_set_font( *form, UTI_LABEL_FIELD, "7x13bold", 15 );
#endif
          if ((status = (long) FIfld_set_text (*form, UTI_LABEL_FIELD, 0, 0,
                                                "", FALSE)) != FI_SUCCESS)
           {
              _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
              ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
              _NFIdebug ((fname, " returning FAILURE\n"));
              return (NFI_E_FORM);
           }
	 strcpy (ptr->label, "") ;

	    /* display UTI_LABEL_FIELD  */
	  if ((status = (long) FIg_display (*form, UTI_LABEL_FIELD)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIg_display = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

	 /* make UTI_LABEL_LIST  visible */
	    status = _NFFdisplay_label_list (*form) ;
	    if (status != NFI_S_SUCCESS)
	      {
		_NFIdebug ((fname, "Failure : status = <0x%.8x>\n", status));
		return (status) ;
	      }

        break;

        case UTI_SYS_LABEL_TOGGLE :
	  /* erase UTI_LABEL_FIELD */
	  if ((status = (long) FIg_erase (*form, UTI_LABEL_FIELD)) != FI_SUCCESS)
	    {
	      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
	      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
	      _NFIdebug ((fname, " returning FAILURE\n"));
	      return (NFI_E_FORM);
	    }
	    
	    /* erase UTI_LABEL_LIST  */
	    status = _NFFerase_label_list (*form) ;
	    if (status != NFI_S_SUCCESS)
	    {
	      _NFIdebug ((fname, "Failure : status = <0x%.8x>\n", status));
	      return (status) ;
	    }
	    strcpy (ptr->label, "SYSLAB") ;
        break;

        default:
            _NFIdebug ((fname, " unknown gadget <%d>\n", g_label));
        break; 
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

long _NFFutil_load_item_data (form, label, data_list)
  Form      form;
  int       label;
  MEMptr    data_list;
  {
    auto    int     i, j;
    auto    int     count;
    auto    int     vis_rows;
    auto    int     attr_mask;
    auto    long    status;
    auto    char    **data_ptr;
    static  char    *fname = "_NFFutil_load_item_data";

    _NFIdebug ((fname, "label1 = <%d>\n", label));

    /*  Set the number of rows to 0 to clear out the field  */

    _NFIdebug ((fname,
        "Setting the number of rows to 0 to clear out the field\n"));

    if ((status = (long) FIfld_set_num_rows (form, label, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the number of rows  */

    _NFIdebug ((fname, "Setting the number of rows to %d\n", data_list->rows));

    if ((status = (long) FIfld_set_num_rows (form, label,
                                             data_list->rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif

    data_ptr = (char **) data_list->data_ptr;

    for (i = 0; i < data_list->rows; ++i)
     {
        count = data_list->columns * i;
        for (j = 0; j < data_list->columns; ++j)
         {
            /* if (j >= 4)  */
            if (j >= (data_list->columns - 1)) 
               continue;

            if ((status = (long) FIfld_set_text (form, label, i, j,
                                    data_ptr[count + j], FALSE)) != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                      (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
          }
      }

    /*  Added 5/21/92 - Glenn  */

    FIfld_get_num_vis_rows (form, label, &vis_rows);
    FImcf_get_attr (form, label, &attr_mask);
    if (data_list->rows > vis_rows)
      {
        /*  OR in the vertical scroll bar attribute  */

        attr_mask |= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }
    else
      {
        /*  Take out the vertical scroll bar attribute  */

        if (attr_mask & (FI_VERT_SCROLL | FI_DISPLAY_VSCROLL))
            attr_mask ^= FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
      }

    FImcf_set_attr (form, label, attr_mask);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFprocess_label_field (form, label)
  Form      form;
  char      *label;
  {
    short   found = FALSE;
    int     i, num_rows = -1;
    int     r_pos, sel_flag;
    long    status = NFI_S_SUCCESS;
    char    text[16], t_text[16];

    static  char *fname = "_NFFprocess_label_field";

    _NFIdebug ((fname, " Function entered.\n"));

    strcpy (text, "");

    /* get the text from the field */

    if ((status = (long) FIfld_get_text (form, UTI_LABEL_FIELD, 0, 0, 7, text,
                                         &sel_flag, &r_pos)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }
    
    if (strcmp (text, "") == 0)
     {
        if (strcmp (label, "") == 0)
         {
            _NFIdebug ((fname, "User has not selected a label.\n"));
            return (NFI_S_SUCCESS);
         }

        strcpy (text, label);
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	  FIg_set_font( form, UTI_LABEL_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text (form, UTI_LABEL_FIELD, 0, 0,
                                             text, FALSE)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
     }

    /*  Get the number of rows from the list  */

    if ((status = (long) FIfld_get_num_rows (form, UTI_LABEL_LIST,
                                             &num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "num_rows = <%d>\n", num_rows));

    /* if the label exists set it to selected otherwise add it to the list
       and set it to selected.                                              */

    strcpy (t_text, "");

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	  FIg_set_font( form, UTI_LABEL_FIELD, "7x13bold", 15 );
#endif

    for (i = 0; i < num_rows; ++i)
     {
        if ((status = (long) FIfld_get_text (form, UTI_LABEL_LIST, i, 0, 7, 
                                      t_text, &sel_flag, &r_pos)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
 
        if (strcmp (text, t_text) == 0)
         {
            found = TRUE;

            /* set this row to selected */

            FIfld_set_select (form, UTI_LABEL_LIST, i, 0, TRUE); 
            if ((status = (long) FIfld_set_text (form, UTI_LABEL_FIELD, 0, 0,
                                                 text, FALSE)) != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
            strcpy (label, t_text);
            break; 
         }
     }

    if (!found)
     {
        /* Add the row to the UTI_LABEL_LIST and set it to selected */

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	  FIg_set_font( form, UTI_LABEL_LIST, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text (form, UTI_LABEL_LIST, num_rows, 0,
                                             text, TRUE)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
          /* work around change - to set font for SCO - SSRS 4 Feb 94 */
	  FIg_set_font( form, UTI_LABEL_FIELD, "7x13bold", 15 );
#endif
        if ((status = (long) FIfld_set_text (form, UTI_LABEL_FIELD, 0, 0,
                                             text, FALSE)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
        
        strcpy (label, text);
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }



long _NFFprocess_util_sa_list (form, ptr)
  Form        form;
  NFFutil_ptr ptr;
  {
    short   found = FALSE;
    int     i, num_rows = -1;
    int     r_pos, sel_flag;
    int     offset = 2;      /* n_type offset */
    long    status = NFI_S_SUCCESS;
    char    text[8];

    static  char *fname = "_NFFprocess_util_sa_list";

    _NFIdebug ((fname, " Function entered.\n"));

    strcpy (text, "");

    /*  Get the number of rows from the list  */

    num_rows = (ptr->sa_list)->rows;

    _NFIdebug ((fname, "num_rows = <%d>\n", num_rows));

    for (i = 0; i < num_rows; ++i)
     {
        /* get the selected row and the selected text */

        if ((status = (long) FIfld_get_text (form, UTI_SA_LIST, i, offset,
                                   3, text, &sel_flag, &r_pos)) != FI_SUCCESS)

         {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
 
        if (sel_flag)
         {
            found = TRUE;

            /* if The Device Type is "MT, UT, CT, or FD the user will need to
               select a label or add one.  Enable the label section otherwise,
               disable the label section.                                  */

            /* modified to include FD... 01.02.94 KMM */

            if ((strcmp (text, "MT") != 0) && (strcmp (text, "UT") != 0) && 
                (strcmp (text, "CT") != 0) && (strcmp (text, "FD") != 0))
                found = FALSE;

            if (strcmp (text, "FD") == 0) 
                strcpy (ptr->label, "DISK_F");
            else if (strcmp (text, "HD") == 0) 
             { 
                if (ptr->type == ARCHIVE_FLAGGED_ITEMS)
                   strcpy (ptr->label, "DISK_A");
                else if (ptr->type == BACKUP_FLAGGED_ITEMS)
                   strcpy (ptr->label, "DISK_B");
             }
            else if (strcmp (text, "OD") == 0) 
                strcpy (ptr->label, "DISK_O");
            else if (strcmp (text, "MO") == 0) 
                strcpy (ptr->label, "DISK_J");
            else if (strcmp (text, "CA") == 0) 
                strcpy (ptr->label, "DISK_C");

            break; 
         }
     }

    if (!found)
     {
       status = _NFFerase_label_gadgets (form) ;
       if (status != NFI_S_SUCCESS)
	 {
            _NFIdebug ((fname, "Failure = <0x%.8x>\n", status));
            return (status) ;
	 }

        /* Disable the UTI_LABEL_LIST and the UTI_LABEL_FIELD  */
/*
        if ((status = (long) FIg_disable (form, UTI_LABEL_LIST)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if ((status = (long) FIg_disable (form, UTI_LABEL_FIELD)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
*/
        ptr->utility = FALSE;
     }
    else
     {
        /* Enable the UTI_LABEL_LIST and the UTI_LABEL_FIELD  */
       status = _NFFinit_label_gadgets (form) ;
       if (status != NFI_S_SUCCESS)
	 {
	   _NFIdebug ((fname, "Failure : status = <0x%.8x>\n", status)) ;
	   return (status) ;
	 }

       /*
	 if ((status = (long) FIg_enable (form, UTI_LABEL_LIST)) != FI_SUCCESS)
         {
	 _NFIdebug ((fname, "FIg_enable = <%d>\n", status));
	 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_enable", status);
	 _NFIdebug ((fname, " returning FAILURE\n"));
	 return (NFI_E_FORM);
         }
	 
	 if ((status = (long) FIg_enable (form, UTI_LABEL_FIELD)) != FI_SUCCESS)
         {
	 _NFIdebug ((fname, "FIg_enable = <%d>\n", status));
	 ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_enable", status);
	 _NFIdebug ((fname, " returning FAILURE\n"));
	 return (NFI_E_FORM);
         }
	 */

       /* modified to include FD .... KMM 01.02.94 */

       if ((strcmp (text, "MT") == 0) || (strcmp (text, "UT") == 0) || 
           (strcmp (text, "CT") == 0) || (strcmp (text, "FD") == 0))
           ptr->utility = TRUE;
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcheck_util_user_input (form, ptr, sa_no, flist)
  Form          form;
  NFFutil_ptr   ptr;
  char          *sa_no;
  MEMptr        *flist; 
  {
    short   found = FALSE;
    int     i, num_rows = -1, row = -1;
    int     r_pos, sel_flag;
    int     count;
    long    status = NFI_S_SUCCESS;
    char    sano[24];
    char    text[256];
    char    **data;
    int     link_offset = 4; 

    static  char *fname = "_NFFcheck_util_user_input";

    _NFIdebug ((fname, " Function entered.\n"));

    /*  Check to see if a storage area was selected from the sa_list  */

    num_rows = (ptr->sa_list)->rows;

    _NFIdebug ((fname, "number of storage areas = <%d>\n", num_rows));

    for (i = 0; i < num_rows; ++i)
     {
        /* get the selected row and the selected text */

        if ((status = (long) FIfld_get_text (form, UTI_SA_LIST, i, 0,
                                   16, sano, &sel_flag, &r_pos)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
 
        if (sel_flag)
         {
            found = TRUE;
            row = i;
            break; 
         }
     }

    if (!found)
     {
        /* Exit and send a warning message to the user  */

        status = NFI_I_CHOOSE_SA;
        _NFIdebug ((fname, "A storage area has not been chosen.\n"));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /* see if this is a device type that requires a label */

    if ((status = (long) FIfld_get_text (form, UTI_SA_LIST, i, 2,
                              3, text, &sel_flag, &r_pos)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /* if The Device Type is "MT, UT, CT, or FD the user must have selected
       a label otherwise return an error.                                  */

    if( (strcmp (text, "MT") == 0) || (strcmp (text, "UT") == 0) ||
        (strcmp (text, "CT") == 0))
     { 
        if (strcmp (ptr->label, "") == 0)
         {
            /* Exit and send a warning message to the user  */

/*
            FIg_enable (form, UTI_LABEL_LIST);
            FIg_enable (form, UTI_LABEL_FIELD);
            status = NFI_I_CHOOSE_LABEL;
            _NFIdebug ((fname, "A label has not been chosen.\n"));
            ERRload_struct (NFI, status, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
*/
            status = NFI_I_CHOOSE_LABEL;
            _NFIdebug ((fname, "A label has not been chosen.\n"));
            ERRload_struct (NFI, status, NULL);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
/****
            _NFIdebug ((fname, 
                  "A label has not been chosen; defaulting it to 'SYSLAB'.\n"));
            strcpy (ptr->label, "SYSLAB");
****/
         }
     }

    /* open the MEMbuffer */

    status = MEMopen (flist, 1024);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    /* write the "link_number" format info */

    status = MEMwrite_format (*flist, "link_number", "char(10)");
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    /* Check to see if any items where selected.  If any where selected
       put them in the flist.  If none where selected send an error
       message to the user and exit.                               */
 
    data = (char **) (ptr->item_list)->data_ptr;
    row = 0;
    for (i = 0; i < (ptr->item_list)->rows; ++i) 
     {
        if ((status = (long) FIfld_get_select (form, UTI_ITEM_LIST, i, 0,
                                               &sel_flag)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
 
        if (sel_flag)
         {
            ++row;

            /* Write the new link_num in the flist */

            count = ptr->item_list->columns * i + link_offset;
            text[0] = 0;
            strncat (text, data[count], 10);
            strcat (text, "\1");
            status = MEMwrite (*flist, text);
            if (status != MEM_S_SUCCESS)
             {
                _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
                ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
             }
         }
     }

    if (row == 0)
     {
        /* no items have been selected to archive/backup */

        status = NFI_I_NO_ITEMS_SELECTED;
        _NFIdebug ((fname, "No items have been selected to archive/backup.\n"));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }
    
    strcpy (sa_no, sano);
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

void _NFFfree_utility (form, ptr)
  Form         *form;
  NFFutil_ptr  ptr;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (ptr != NULL)
      {
          MEMclose (&(ptr->sa_list));
          MEMclose (&(ptr->item_list));
          MEMclose (&(ptr->label_list));
          free (ptr);
          ptr = NULL;
      }

    return;
  }

long _NFFget_util_user_input (form, ptr, flist)
  Form          form;
  NFFutil_ptr   ptr;
  MEMptr        *flist;  
  {
    /* short   found = FALSE; */
    int     i, row = -1;
    int     sel_flag;
    int     count;
    long    status = NFI_S_SUCCESS;
    int     link_offset; 
    char    **data;
    char    text[256];

    static  char *fname = "_NFFget_util_user_input";

    _NFIdebug ((fname, " Function entered.\n"));

    link_offset = ptr->item_list->columns - 1;

    /* open the MEMbuffer */

    status = MEMopen (flist, 1024);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    /* write the "link_number" format info */

    status = MEMwrite_format (*flist, "link_number", "char(10)");
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }


    /* Check to see if any items where selected.  If any where selected
       put them in the flist.  If none where selected send a error message
       to the user and exit.                               */
 
    data = (char **) (ptr->item_list)->data_ptr;
    row = 0;
    for (i = 0; i < (ptr->item_list)->rows; ++i) 
     {
        if ((status = (long) FIfld_get_select (form, UTI_ITEM_LIST, i, 0,
                                               &sel_flag)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
 
        if (sel_flag)
         {
            ++row;


            count = ptr->item_list->columns * i + link_offset;
            text[0] = 0;
            strncat (text, data[count], 10);
            strcat (text, "\1");
            status = MEMwrite (*flist, text);
            if (status != MEM_S_SUCCESS)
             {
                _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
                ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
             }
         }
     }

    if (row == 0)
     {
        /* no items have been selected to delete/restore */

        status = NFI_I_NO_ITEMS_SELECTED;
        _NFIdebug ((fname, "No items have been selected to delete/restore.\n"));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }
    
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFprocess_label_list (form, label)
  Form      form;
  char      *label;
  {
    /* short   found = FALSE; */
    int     i, num_rows = -1;
    int     r_pos, sel_flag;
    long    status = NFI_S_SUCCESS;
    char    text[16];

    static  char *fname = "_NFFprocess_label_list";

    _NFIdebug ((fname, " Function entered.\n"));

    strcpy (text, "");

    /*  Get the number of rows from the list  */

    if ((status = (long) FIfld_get_num_rows (form, UTI_LABEL_LIST,
                                             &num_rows)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "num_rows = <%d>\n", num_rows));

    /* if the label exists write the data out to the UTI_LABEL_FIELD */

/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, UTI_LABEL_FIELD, "7x13bold", 15 );
#endif

    for (i = 0; i < num_rows; ++i)
     {
        if ((status = (long) FIfld_get_text (form, UTI_LABEL_LIST, i, 0, 7, 
                                      text, &sel_flag, &r_pos)) != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
 
        if (sel_flag)
         {
            /* set this row to selected */

            FIfld_set_select (form, UTI_LABEL_LIST, i, 0, TRUE); 
            if ((status = (long) FIfld_set_text (form, UTI_LABEL_FIELD, 0, 0,
                                                 text, FALSE)) != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
            strcpy (label, text);
            break; 
         }
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFerase_label_gadgets (form)
     Form form ;
{
  char *fname = "_NFFerase_label_gadgets" ;
  long status ;

  _NFIdebug ((fname, "ENTER\n")) ;
  if ((status = FIg_erase (form, UTI_USER_LABEL_TOGGLE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_USER_LABEL_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_EXIS_LABEL_TOGGLE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_EXIS_LABEL_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_SYS_LABEL_TOGGLE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_SYS_LABEL_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_LABEL_LIST)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_LABEL_LIST_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_LABEL_LIST_BOX)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_LABEL_FIELD)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  _NFIdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFI_S_SUCCESS) ;
}


long _NFFinit_label_gadgets (form)
     Form form ;
{
  char *fname = "_NFFinit_label_gadgets" ;
  long status ;

  _NFIdebug ((fname, "ENTER\n")) ;
/* IGI Intel Solaris Port -CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
  /* work around change - to set font for SCO - SSRS 4 Feb 94 */
  FIg_set_font( form, UTI_LABEL_FIELD, "7x13bold", 15 );
#endif
  if ((status = (long) FIfld_set_text (form, UTI_LABEL_FIELD, 0, 0,
				       "", FALSE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }
  
  if ((status = FIg_set_state_on(form, UTI_USER_LABEL_TOGGLE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_set_state_on = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_state_on", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_display (form, UTI_USER_LABEL_TOGGLE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_display (form, UTI_USER_LABEL_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_display (form, UTI_EXIS_LABEL_TOGGLE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_display (form, UTI_EXIS_LABEL_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_display (form, UTI_SYS_LABEL_TOGGLE)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_display (form, UTI_SYS_LABEL_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_LABEL_LIST)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_LABEL_LIST_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_LABEL_LIST_BOX)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_display (form, UTI_LABEL_FIELD)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  _NFIdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFI_S_SUCCESS) ;
}


long _NFFerase_label_list (form)
     Form form ;
{
  char *fname = "_NFFerase_label_list" ;
  long status ;

  if ((status = FIg_erase (form, UTI_LABEL_LIST)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_LABEL_LIST_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_erase (form, UTI_LABEL_LIST_BOX)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  _NFIdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFI_S_SUCCESS) ;
}


long _NFFdisplay_label_list (form)
     Form form ;
{
  char *fname = "_NFFdisplay_label_list" ;
  long status ;

  if ((status = FIg_display (form, UTI_LABEL_LIST)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }


  if ((status = FIg_display (form, UTI_LABEL_LIST_BOX)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  if ((status = FIg_display (form, UTI_LABEL_LIST_LABEL)) != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_display = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

  _NFIdebug ((fname, "SUCCESSFUL\n")) ;
  return (NFI_S_SUCCESS) ;
}


