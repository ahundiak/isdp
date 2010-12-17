
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFversions.h"

/*****************************************************************************
 *                                                                           *
 *                                                                           *
 *****************************************************************************/

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFroll_version_forward (catalog, item_name, revision)
    char    *catalog;
    char    *item_name;
    char    *revision;
  {
    long    status;
    char    title[NFF_MAX_MESSAGE];
    NFFversion_ptr ptr;

    static  char *fname = "_NFFroll_version_forward";

    _NFIdebug ((fname, "catalog  = <%s>\n", catalog));
    _NFIdebug ((fname, "item     = <%s>\n", item_name));
    _NFIdebug ((fname, "revision = <%s>\n", revision));

    if (strcmp (catalog, "") == 0)
     {
        status = NFI_E_NO_CATALOG;
        _NFIdebug ((fname, "Null catalog name : status = <0x%.8x>\n", status));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    if (strcmp (item_name, "") == 0)
     {
        status = NFI_E_NO_ITEM;
        _NFIdebug ((fname, "Null item name : status = <0x%.8x>\n", status));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    if (strcmp (revision, "") == 0)
     {
        status = NFI_E_NO_REV;
        _NFIdebug ((fname, "Null item revision : status = <0x%.8x>\n", status));
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /* Malloc Memory for the version structure */

    if ((ptr = (NFFversion_ptr) malloc
        (sizeof (struct NFFversion_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFversion_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFversion_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    ptr->type = FALSE;
    ptr->command = -1;
    strcpy (ptr->catalog, catalog);
    strcpy (ptr->item, item_name);
    strcpy (ptr->revision, revision);
    ptr->attr_list = NULL;
    ptr->data_list = NULL;

    /* Put up retrieving data message */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    _NFIdebug ((fname, "calling NFMRget_item_versions function ...\n"));

    status = NFMRget_item_versions (catalog, item_name, revision, 
                                    &(ptr->attr_list),  &(ptr->data_list));

    _NFIdebug ((fname, "returned from NFMRget_item_versions function\n"));

    if (status != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRget_item_versions function = <0x%.8x>\n",
                    status));
        NFFerase_message ();
        _NFFfree_version (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, "NFMRget_item_versions function successful\n"))

    /*  Load in the version form  */

    if ((status = (long) FIf_new (ROLL_VERSION_LABEL, VERSION_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_version (NULL, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        _NFFfree_version (&NFFglobal.current_form, ptr);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Create the SYNONYM_LIST and DATA_LIST MCF's and Load the data from 
        the attr_list and data_list into the multicolumn fields  */

    if ((status = _NFFfcreate_list_mcfs (NFFglobal.current_form, 
                   NFI_SYNONYM_MCF, NFI_DATA_MCF, FI_MULTI_SELECT, "n_read",  
                            ptr->attr_list, ptr->data_list)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfcreate_list_mcfs = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_version (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_version (&NFFglobal.current_form, ptr);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Erase the message  */

    NFFerase_message ();

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_version (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

/* caught typo FOWARD, it is this way in NFMtitles.h, did not change it because
   I did not want to recompile everything.  should be FORWARD */ 
    if ((status = (long) UMSGetByNum (title, NFT_P_ROLL_VERSION_FOWARD, "%s%s",
                                      item_name, revision)) != UMS_S_SUCCESS)
     {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title, "Roll version of Item \"%s\" Revision \"%s\" forward",
                 item_name, revision);
     }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, NFI_VERSIONS_TITLE, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_version (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the text on the button */

    /*  Display the form  */

    if ((status = (long) FIf_display
        (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_version (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFroll_versions_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    int     working_message = 0;
    long    status;
    char    help_command[15];
    MEMptr  data_list = NULL;
    NFFversion_ptr    ptr;


    static    char *fname = "_NFFroll_versions_notify";

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    if ((status = (long) FIf_get_user_pointer
        (*form, (char *) &ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_FORM));
        return (NFI_E_FORM);
      }

    strcpy (help_command, NFI_M_ROLL_VERSION_FORWARD);
    working_message = NFI_I_ROLL_VERSION_FORWARD;
    NFFglobal.NFMRfunction[0] = NFMRroll_version_forward;

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    status = NFI_S_SUCCESS;

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (help_command))
              {
                _NFIdebug ((fname, "_NFFhelp_topic = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_HELP, "%s%d", "_NFFhelp_topic", status);
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

            _NFFfree_version (form, ptr);
            ptr = NULL; 

            break;

        case FI_ACCEPT:

            status = _NFFget_file_versions (NFI_DATA_MCF, *form, ptr,
                                            &data_list);
            if (ptr->type == FALSE)
              {
                MEMclose (&data_list);
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, working_message, NULL);

            /*  Call NFMR to add/change the entity  */

            _NFIdebug ((fname, "calling NFMR function ...\n"));

            status = (long) NFFglobal.NFMRfunction[0] (ptr->catalog,
                                 ptr->item, ptr->revision, data_list);

            _NFIdebug ((fname, "NFMR function = <0x%.8x>\n", status));

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;
            MEMclose (&data_list);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_version (form, ptr);
            ptr = NULL; 

            break;

        case NFI_DATA_MCF:

            /* get the selected field information and set its defaults */

            status = _NFFcheck_selected_versions (NFI_DATA_MCF, *form,
                                                  ptr->data_list);
            break;

        case NFI_VERSION_TOGGLE:

            status = _NFFtoggle_unselect_rows  (NFI_DATA_MCF, *form,
                                                ptr->data_list->rows);
            break;

        default:
            _NFIdebug ((fname, " unknown gadget <%d>\n", g_label));
        break; 
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

void _NFFfree_version (form, ptr)
  Form              *form;
  NFFversion_ptr    ptr;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (ptr != NULL)
      {
          MEMclose (&(ptr->attr_list));
          MEMclose (&(ptr->data_list));
          free (ptr);
          ptr = NULL;
      }

    return;
  }

long _NFFtoggle_unselect_rows  (g_label, form, num_rows)
  int       g_label;
  Form      form;
  int       num_rows;
  {
    long    status = NFI_S_SUCCESS;
    int     i = 0, j;
    int     sel_flag;
    int     num_cols = 6; /* may want to make this an argument to this funct */
    static  char *fname = "_NFFtoggle_unselect_rows";

    _NFIdebug ((fname, " g_label =  <%d>\n", g_label));

    NFFform_message (CURRENT_LABEL, NFI_I_RESET_TOGGLE_SELECT, NULL);

    /* If any rows in the MCF where selected; unselect them */

    for (i = 0; i < num_rows; ++i)
     {
        status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
        if (sel_flag)
         {
            for (j = 0; j < num_cols; ++j)
             {
                status = (long) FIfld_set_select (form, g_label, i, j, FALSE);
                if (status != FI_SUCCESS)
                 {
                    _NFIdebug ((fname, "FIfld_set_select = <%d>\n", status));
                    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_select",
                                    status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                 }
             }
         }
     }

    status = NFI_S_SUCCESS; 
    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

  
long _NFFcheck_selected_versions (g_label, form, data_list)
  int       g_label;
  Form      form;
  MEMptr    data_list;
  {
    long    status = NFI_S_SUCCESS;
    int     i = 0, j, k;
    int     g_state = FALSE;
    int     sel_flag, r_pos;
    int     v_offset = 0;
    int     f_offset = 4;
    int     count, num_cols = 6;
    char    version[NFM_COFILENAME + 1];
    char    **data_ptr;
    static  char *fname = "_NFFcheck_selected_versions";

    _NFIdebug ((fname, " g_label =  <%d>\n", g_label));

    /* Get the gadget state */

    status = (long) FIg_get_state (form, NFI_VERSION_TOGGLE, &g_state);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_get_state = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_state",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    data_ptr = (char **) data_list->data_ptr;
    if (!g_state)
     {
        /* Select All Files of Requested Version :  State == OFF */

        /* find the selected version */

        for (i = 0; i < data_list->rows; ++i)
         {
            status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }

            if (sel_flag)
             {
                /* get the version text from the mcf */

                status = (long) FIfld_get_text (form, g_label, i, v_offset,
                                             20, version, &sel_flag, &r_pos);
                if (status != FI_SUCCESS)
                 {
                    _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text",
                                    status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                 }

                /* select all the files in the list that match this version */
               
                for (j = 0; j < data_list->rows; ++j)
                 {
                    count = data_list->columns * j + v_offset;
                    if (j != i)
                     {
                        if (strcmp (version, data_ptr[count]) == 0)
                         {
                            for (k = 0; k < num_cols; ++k)
                             {
                                status = (long) FIfld_set_select (form,
                                                       g_label, j, k, TRUE);
                                if (status != FI_SUCCESS)
                                 {
                                    _NFIdebug ((fname,
                                         "FIfld_set_select = <%d>\n", status));
                                    ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                                    "FIfld_set_select", status);
                                    _NFIdebug ((fname, " returning FAILURE\n"));
                                    return (NFI_E_FORM);
                                 }
                             }
                         }
                        else
                         {
                            /* unselect the version */

                            for (k = 0; k < num_cols; ++k)
                             {
                                status = (long) FIfld_set_select (form,
                                                       g_label, j, k, FALSE);
                                if (status != FI_SUCCESS)
                                 {
                                    _NFIdebug ((fname,
                                         "FIfld_set_select = <%d>\n", status));
                                    ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                                    "FIfld_set_select", status);
                                    _NFIdebug ((fname, " returning FAILURE\n"));
                                    return (NFI_E_FORM);
                                 }
                             }
                         }
                     }
                 }
                break;
            } 
         } 
     }
    else
     {
        /* Select the version files individually : state = ON */
        
        /* find the selected version */

        for (i = 0; i < data_list->rows; ++i)
         {
            status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }

            if (sel_flag)
             {
                /* get the version co_filename text from the mcf */

                status = (long) FIfld_get_text (form, g_label, i, f_offset,
                                 NFM_COFILENAME, version, &sel_flag, &r_pos);
                if (status != FI_SUCCESS)
                 {
                    _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
                    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text",
                                    status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                 }

                /* unselect all files in the list that match this filename */
               
                for (j = 0; j < data_list->rows; ++j)
                 {
                    count = data_list->columns * j + f_offset;
                    if (j != i)
                     {
                        if (strcmp (version, data_ptr[count]) == 0)
                         {
                            for (k = 0; k < num_cols; ++k)
                             {
                                status = (long) FIfld_set_select (form,
                                                       g_label, j, k, FALSE);
                                if (status != FI_SUCCESS)
                                 {
                                    _NFIdebug ((fname,
                                         "FIfld_set_select = <%d>\n", status));
                                    ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                                    "FIfld_set_select", status);
                                    _NFIdebug ((fname, " returning FAILURE\n"));
                                    return (NFI_E_FORM);
                                 }
                             }
                         }
                     }
                 }
                /* break; Need to go through all files */
            } 
         } 
     } 

    status = NFI_S_SUCCESS; 
    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }
  

long _NFFget_file_versions (g_label, form, ptr, data_list)
  int           g_label;
  Form          form;
  NFFversion_ptr ptr;
  MEMptr        *data_list;
  {
    long    status = NFI_S_SUCCESS;
    int     i = 0, j, count;
    int     sel_flag;
    int     rows = 0;
    char    str [512];
    char    **data_ptr, **format_ptr, **column_ptr;
    static  char *fname = "_NFFget_file_versions";

    _NFIdebug ((fname, " g_label =  <%d>\n", g_label));

    /* find out if any rows in the MCF where selected */

    for (i = 0; i < (ptr->data_list)->rows; ++i)
     {
        status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }
        if (sel_flag)
         {
             ++rows;
         }
     }

    if (!rows)
     {
        /* no files have been selected send informational message to user */

        NFFform_message (CURRENT_LABEL, NFI_I_NO_ITEMS_SELECTED, NULL);
        ptr->type = FALSE;
        status = NFI_S_SUCCESS; 
        _NFIdebug ((fname, " returning <0x%.8x>\n", status));
        return (status);
     }

    data_ptr   = (char **) (ptr->data_list)->data_ptr;
    format_ptr = (char **) (ptr->data_list)->format_ptr;
    column_ptr = (char **) (ptr->data_list)->column_ptr;

    /* Open the data_list */ 

    status = MEMopen (data_list, ptr->data_list->row_size * rows);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMopen = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMopen", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    /* write the attrbutes to the data_list */

    for (i = 0; i < ptr->data_list->columns; ++i)
     { 
        status = MEMwrite_format (*data_list, column_ptr[i], format_ptr[i]);
        if (status != MEM_S_SUCCESS)
         {
            _NFIdebug ((fname, "MEMwrite_format = <0x%.8x>\n", status));
            ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_format", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
         }
     }

    /* put the selected data into the data_list */
    for (i = 0; i < ptr->data_list->rows; ++i)
     {
        status = (long) FIfld_get_select (form, g_label, i, 0, &sel_flag);
        if (status != FI_SUCCESS)
         {
            _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_select",
                            status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
         }

        if (sel_flag)
         {
            str[0] = 0;
            for (j = 0; j < ptr->data_list->columns; ++j)
             {
                 count = ptr->data_list->columns * i + j;
                 strcat (str, data_ptr[count]);
                 strcat (str, "\1");
             }

            status = MEMwrite (*data_list, str);
            if (status != MEM_S_SUCCESS)
             {
                _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
                ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_MEM);
             }
         }
     }

    ptr->type = TRUE;

    status = NFI_S_SUCCESS; 
    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


