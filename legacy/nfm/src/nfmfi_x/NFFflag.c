
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFvalidate.h"
#include "NFFflag.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFprocess_flagged_files ()
  {
    auto    long              status;
    auto    char              prompt1[NFF_MAX_MESSAGE]; 
    static  char              *fname = "NFFprocess_flagged_files";

    /*  Load in the process_menu form  */

    if ((status = (long) FIf_new (FLAG_LABEL, FLAG_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_flag (NULL, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning <0x%.8x>\n", status));
        return (status);
      }

    /*  Put the title on the form  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_SELECT_FLAG_COMMAND, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (prompt1, "Select a utility option");
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, UTILITY_TITLE, prompt1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_flag (NULL, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Display the Flag form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_flag (NULL, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFflagged_files_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    auto    long              status = NFI_S_SUCCESS;
            int               g_state = FALSE;
            short             flag_type = FLAG_BACKUP;
            /* NFFnflag_ptr      ptr = NULL; */
            char              command[15];
    static  char              *fname = "_NFFflagged_files_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    /* need to change the command value */

    strcpy (command, NFI_M_PROCESS_FLAGGED_FILES);

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    switch (g_label)
      {

        case FI_HELP:

            if (status = _NFFhelp_topic (command))
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

            _NFFfree_flag (NULL, form);

            break;

        case FI_ACCEPT:

            /* determine which command to pass to process.     */
            /* The default is backup                           */

            status = (long) FIg_get_state (*form, FLAG_ARCHIVE, &g_state); 
            if (status != FI_SUCCESS)
             {
               _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
               ERRload_struct
                   (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
               _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
               return (NFI_E_FORM);
             }
            else
             {
                if (g_state)
                    flag_type = FLAG_ARCHIVE;
                else
                 {
                   status = (long) FIg_get_state (*form, FLAG_RESTORE,  
                                                  &g_state); 
                   if (status != FI_SUCCESS)
                    {
                      _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
                      ERRload_struct
                          (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
                      _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
                      return (NFI_E_FORM);
                    }
                   if (g_state)
                       flag_type = FLAG_RESTORE;
                   else
                    {
                      status = (long) FIg_get_state (*form, FLAG_DELETE,  
                                                     &g_state); 
                      if (status != FI_SUCCESS)
                       {
                         _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
                         ERRload_struct
                             (NFI, NFI_E_FORM, "%s%d", "FIg_get_state", status);
                         _NFIdebug ((fname, " returning <0x%.8x>\n",
                                     NFI_E_FORM));
                         return (NFI_E_FORM);
                       }
                      if (g_state)
                          flag_type = FLAG_DELETE;
                    }
                 }
             }

            status = NFI_S_SUCCESS;
       
            /* call Validate User Access to validate */

            switch (flag_type)
             {
                case  FLAG_BACKUP:
                  status = NFFvalidate_user_access (NFI_M_BACKUP_FLAGGED_FILES);
                break; 

                case  FLAG_ARCHIVE:
                  status = NFFvalidate_user_access (NFI_M_ARCHIVE_FLAGGED_FILES);
                break; 

                case  FLAG_RESTORE:
                  status = NFFvalidate_user_access (NFI_M_RESTORE_FLAGGED_FILES);
                break; 

                case  FLAG_DELETE:
                  status = NFFvalidate_user_access (NFI_M_DELETE_FLAGGED_FILES);
                break; 
            }

           if (status != NFI_S_SUCCESS)
            {
              _NFIdebug ((fname,"NFFvalidate_user_access : status = <0x%.8x>\n",
                          status));
              _NFFfree_flag (NULL, form);
              break; 
            }

           /* Erase the Utility form */

           _NFFfree_flag (NULL, form);

           /*  Force a refresh event to clean
               up the display - 5/21/92 Glenn  */

#ifndef XWINDOWS
           _NFFprocess_event (REFRESH_EVENT);
#endif
            /* Call NFF function to bring up the next form to process 
               the chosen utility command                              */

            switch (flag_type)
             {
                case  FLAG_BACKUP:

                   status = _NFFbackup_flagged_items ();
                break; 

                case  FLAG_ARCHIVE:

                   status = _NFFarchive_flagged_items ();
                break; 

                case  FLAG_RESTORE:

                   status = _NFFrestore_flagged_items ();
                break; 

                case  FLAG_DELETE:

                   status = _NFFdelete_flagged_items ();
                break; 
            }

           _NFIdebug ((fname,"NFFfunction : status = <0x%.8x>\n", status));

            /*  Save the return status  */

            NFFglobal.status = status;

           break;
  
           case  FLAG_ARCHIVE :
           case  FLAG_BACKUP :
           case  FLAG_DELETE :
           case  FLAG_RESTORE :
              _NFIdebug ((fname,"I/Forms will handle this case\n"));

/*  This will cause the "Successful completion" message
    to be displayed whenever a checkbox is selected; we
    don't want that - 5/21/92 Glenn

              status = NFI_S_CLEAR_MSG; 
*/
           break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


void _NFFfree_flag (ptr, form)
  NFFnflag_ptr      ptr;
  Form              *form;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (ptr != NULL)
      {
          free (ptr);
          ptr = NULL;
      }

    return;
  }
