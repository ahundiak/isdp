
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFfiles.h"
#include "NFFmain_form.h"

/*****************************************************************************
 *                                                                           *
 * If This is "NFI_F_COPY" - 'Copy Item' command and there are no files,     *
 * the server will return a null (ptr->file_ptr)->data_list.                 *
 *                                                                           *
 * If This is "NFI_F_ADD" - 'Add Files to Item' command, The server will     *
 * return one row in the (ptr->file_ptr)->data_list containing the default   *
 * values.  This row cannot be deleted or changed by the user.               *
 *                                                                           *
 * If this is NFI_F_CHANGE or NFI_F_DELETE the server will return the        *
 * n_status attribute to be used to determine the action on the file.        *
 *                                                                           *
 *****************************************************************************/

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFprocess_item_files (ptr)
    NFFcopy_ptr    ptr;         /*  Pointer to the item structure  */
  {
    long    status;
    int     attr_mask;
    char    title[NFF_MAX_MESSAGE];
    Form    form = COPY_FILE_FORM;
    int     vscroll_mask = FI_VERT_SCROLL | FI_DISPLAY_VSCROLL;
    MEMptr  nattr_list = NULL;
    MEMptr  ndata_list = NULL;

    static  char *fname = "_NFFprocess_item_files";

    _NFIdebug ((fname, "catalog  = <%s>\n", ptr->catalog));
    _NFIdebug ((fname, "item     = <%s>\n", ptr->item));
    _NFIdebug ((fname, "revision = <%s>\n", ptr->revision));
    _NFIdebug ((fname, "command  = <%d>\n", ptr->command));
    _NFIdebug ((fname, "label    = <%d>\n", ptr->label));

    if ((ptr->command != NFI_F_ADD) && (ptr->command != NFI_F_COPY) && 
        (ptr->command != NFI_F_CHANGE) && (ptr->command != NFI_F_DELETE))
     {
        status = NFI_E_BAD_COMMAND;
        _NFIdebug ((fname, "Bad command type : status = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, status, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    switch (ptr->command)
     {
         case NFI_F_COPY:
         case NFI_F_ADD:
             form = COPY_FILE_FORM;
         break;

         case NFI_F_CHANGE:
             form = CHANGE_FILES_FORM;
         break;

         case NFI_F_DELETE:
             form = DELETE_FILES_FORM;
         break;
     }

    /*  Load in the process file form  */

    if ((status = (long) FIf_new (ADD_FILE_LABEL, form,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (ptr->command == NFI_F_COPY)
     {
        /* Set all the n_status row/fields to "ADD" */

        status = _NFFset_data_row_status ((ptr->file_ptr)->data_list); 
        if (status != NFI_S_SUCCESS) 
         {
            _NFIdebug ((fname, "_NFFset_data_row = <0x%.8x>\n", status));
            NFFerase_message ();
            NFFfree_copy (&NFFglobal.current_form, ptr);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
         }
     }

    /*  Create the NFI_SYNONYM_LIST and NFI_DATA_LIST and Load the data from 
        the file_ptr->attr_list and file_ptr->data_list into the multicolumn
        fields  */

     if (ptr->command == NFI_F_DELETE)
        status = _NFFcopy_list_mcf (NFFglobal.current_form, FI_MULTI_SELECT,
                 "n_write", (ptr->file_ptr)->rows, (ptr->file_ptr)->attr_list,
                                (ptr->file_ptr)->data_list);
     else
        status = _NFFcopy_list_mcf (NFFglobal.current_form, FI_SINGLE_SELECT,
                 "n_write", (ptr->file_ptr)->rows, (ptr->file_ptr)->attr_list,
                                (ptr->file_ptr)->data_list);
    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcopy_list_mcf = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((ptr->command == NFI_F_COPY) || (ptr->command == NFI_F_ADD))
     { 
	/*  Create two new buffers with only readable and writable attributes
         */

        if ((status = _NFFcreate_new_buffer ( (ptr->file_ptr)->rows,"n_write",
		 (ptr->file_ptr)->attr_list, (ptr->file_ptr)->data_list,
		 &nattr_list, &ndata_list )) != NFI_S_SUCCESS )
         {
            _NFIdebug ((fname, "_NFFcreate_new_buffer = <0x%.8x>\n", status));
            NFFerase_message ();
            NFFfree_copy (&NFFglobal.current_form, ptr);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
         }

        /*  Create the NFI_DEL_SYNONYM_LIST and NFI_DEL_DATA_LIST and Load the
            data from the nattr_list and ndata_list into the multicolumn 
            fields  */

        if ((status = _NFFfcreate_list_mcfs (NFFglobal.current_form, 
                     NFI_DEL_SYNONYM_LIST, NFI_DEL_DATA_LIST, FI_MULTI_SELECT,
                     "n_write", nattr_list, ndata_list)) != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "_NFFfcreate_list_mcfs = <0x%.8x>\n", status));
	    MEMclose( &nattr_list );
	    MEMclose( &ndata_list );
            NFFerase_message ();
            NFFfree_copy (&NFFglobal.current_form, ptr);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
         }
        MEMclose( &nattr_list );
        MEMclose( &ndata_list );
     }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        NFFfree_copy (&NFFglobal.current_form, ptr);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Erase the message  */

    NFFerase_message ();

    if (ptr->command != NFI_F_DELETE)
     {
        /*  Set the value field to have only one row  */

        if ((status = (long) FIfld_set_num_rows
            (NFFglobal.current_form, NFI_VALUE_FIELD, 1)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIf_set_num_rows = <%d>\n", status));
            NFFfree_copy (&NFFglobal.current_form, ptr);
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIf_set_num_rows", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
    
        FIfld_set_num_rows (NFFglobal.current_form, NFI_VALUE_FIELD, 1);
        FIfld_set_num_rows (NFFglobal.current_form, NFI_MIN_FIELD, 1);
        FIfld_set_num_rows (NFFglobal.current_form, NFI_MAX_FIELD, 1);
        FIfld_set_num_rows (NFFglobal.current_form, NFI_ADVISORY_FIELD, 1);
     }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        NFFfree_copy (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    switch (ptr->command)
     {
        case NFI_F_COPY:

          if ((status = (long) UMSGetByNum (title, NFI_P_COPY_ITEM, "%s%s",
                                   ptr->item, ptr->revision)) != UMS_S_SUCCESS)
           {
              _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
              _NFIdebug ((fname, "defaulting title\n"));
              sprintf (title, "Copy Item \"%s\" Revision \"%s\"", ptr->item,
                       ptr->revision);
           }
        break;

        case NFI_F_ADD:

          if ((status = (long) UMSGetByNum (title, NFI_P_ADD_FILES, "%s%s",
                                   ptr->item, ptr->revision)) != UMS_S_SUCCESS)
           {
              _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
              _NFIdebug ((fname, "defaulting title\n"));
              sprintf (title, "Add files to Item \"%s\" Revision \"%s\"",
                       ptr->item, ptr->revision);
           }
        break;

        case NFI_F_DELETE:  

          if ((status = (long) UMSGetByNum (title, NFT_P_DELETE_ITEM_FILES,
                          "%s%s", ptr->item, ptr->revision)) != UMS_S_SUCCESS)
           {
              _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
              _NFIdebug ((fname, "defaulting title\n"));
              sprintf (title, "Delete files from Item \"%s\" Revision \"%s\"",
                       ptr->item, ptr->revision);
           }
        break;

        case NFI_F_CHANGE: 

          if ((status = (long) UMSGetByNum (title, NFT_P_CHANGE_ITEM_ATTR,
                          "%s%s", ptr->item, ptr->revision)) != UMS_S_SUCCESS)
           {
              _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
              _NFIdebug ((fname, "defaulting title\n"));
              sprintf (title, 
                       "Change attributes for Item \"%s\" Revision \"%s\"",
                       ptr->item, ptr->revision);
           }
        break;
     }

    _NFIdebug ((fname, "title = <%s>\n", title));

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, FILES_TITLE, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFfree_copy (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (ptr->command == NFI_F_ADD)
     {
        /* Alter the MCF attr_mask to display the vertical scroll bars */

        status = FImcf_get_attr (NFFglobal.current_form, NFI_DATA_LIST,
                 &attr_mask);
        _NFIdebug ((fname, "FImcf_get_attr : status = <%d>\n", status));
        attr_mask |= vscroll_mask; 
        status = FImcf_set_attr (NFFglobal.current_form, NFI_DATA_LIST,
                                 attr_mask);
        _NFIdebug ((fname, "FImcf_set_attr : status = <%d>\n", status));
     }


    /*  Display the form  */

    if ((status = (long) FIf_display
        (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        NFFfree_copy (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (ptr->command != NFI_F_DELETE)
     {
        status = _NFFdisable_value_info (NFFglobal.current_form, ptr->file_ptr);
        if (status != NFI_S_SUCCESS)
         {
            _NFIdebug ((fname, "Nffdisable_value_info = <0x%.8x>\n", status));
            _NFIdebug ((fname, " This is not a fatal error.\n"));
         }
     }

    if (ptr->command == NFI_F_COPY)
     {
        FIg_erase (NFFglobal.current_form, NFI_ADD_FILE_BUTTON);
        FIg_disable (NFFglobal.current_form, NFI_ADD_FILE_BUTTON);
     }

    if (ptr->command == NFI_F_ADD)
     {
        ptr->act_row = -1;
        ptr->act_col = 0;
        _NFFnotify (ADD_FILE_LABEL, NFI_ADD_FILE_BUTTON, (double) 0,
                    NFFglobal.current_form);
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFprocess_files_notify (g_label, value, form)
  int       g_label;
  int       value;
  Form      *form;
  {
    int     working_message = 0;
    int     error_message;
    int     i, j, count;
    short   offset = -1;
    long    status;
    char    help_command[15];
    char    write_or_update[10];
    char    str[2048];
    char    **data_ptr; 
    MEMptr  data_list = NULL;

    static    char *fname = "_NFFprocess_files_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFcopy_ptr    ptr;

    _NFIdebug ((fname, "g_label = %d\n", g_label));
    _NFIdebug ((fname, "value   = %d\n", value));

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

     strcpy (write_or_update, "n_write");

    /* Clear out the message strip */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    switch (ptr->command)
     {
          case NFI_F_ADD:
	       ptr->file_ptr->command = NFI_F_ADD;
               strcpy (help_command, NFI_M_ADD_ITEM_FILES);
               working_message = NFI_I_ADD_FILES;
               error_message = NFI_E_COPY_ITEM;
               NFFglobal.NFMRfunction[0] = NFMRdefine_file_information;
          break; 

          case NFI_F_DELETE:
               strcpy (help_command, NFI_M_DELETE_ITEM_FILES);
               working_message = NFI_I_DELETE_FILES;
               error_message = NFI_E_COPY_ITEM;
               NFFglobal.NFMRfunction[0] = NFMRdefine_file_information;
          break; 

          case NFI_F_CHANGE:
               ptr->file_ptr->command = NFI_F_CHANGE;
               strcpy (help_command, NFI_M_CHANGE_FILE_ATTRIBUTES);
               working_message = NFI_I_CHANGE_FILE_ATTR;
               error_message = NFI_E_CHANGE_FILE_ATTR;
               NFFglobal.NFMRfunction[0] = NFMRdefine_file_information;
          break; 

          case NFI_F_COPY:
               ptr->file_ptr->command = NFI_F_COPY;
               strcpy (help_command, NFI_M_COPY_ITEM);
               working_message = NFI_I_COPY_ITEM;
               error_message = NFI_E_COPY_ITEM;
               NFFglobal.NFMRfunction[0] = NFMRcopy_item_n;
          break; 
     }

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

            if (ptr->command != NFI_F_COPY) 
             {
                /* Must call this function to restore db to previous cond */ 

                NFMRreset_file_information (ptr->catalog, ptr->item,
                                            ptr->revision);
             } 

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            NFFfree_copy (form, ptr);
            ptr = NULL; 

            break;

        case FI_ACCEPT:

            if (ptr->command == NFI_F_DELETE)
             {
                 status = _NFFset_delete_data_rows (*form, NFI_DATA_LIST,
                                                    (ptr->file_ptr)->data_list);
                 if (status != NFI_S_SUCCESS)
                  {
                     FIg_set_state_off (*form, FI_ACCEPT);
                     break;
                  }
             }

            if (ptr->command != NFI_F_DELETE)
             {
                 if (ptr->command == NFI_F_COPY)
                   status = _NFFprocess_validate_accept (*form, write_or_update,
                            &(ptr->act_row), &(ptr->act_col), ptr->file_ptr, 0);
                 else
                   status = _NFFprocess_validate_accept (*form, write_or_update,
                            &(ptr->act_row), &(ptr->act_col), ptr->file_ptr, 1);
                 if (status != NFI_S_SUCCESS)
                  {
                     _NFIdebug ((fname,
                          "_NFFprocess_validate_accept = <0x%.8x>\n", status));
                     FIg_set_state_off (*form, FI_ACCEPT);
                     break;
                  }
             }

            /* NULL check added by SSRS - 25/11/93 */
            if(ptr->add_ptr != NULL)
            {
            if (ptr->add_ptr->done == FALSE)
              {
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }
            }

            if (ptr->command == NFI_F_ADD)
             {
                 data_ptr = (char **) (ptr->file_ptr->data_list)->data_ptr; 

                 /* put the 0 row back in the list */

                 for (i = 0; i < (ptr->file_ptr->data_list)->rows; ++i)
                  {
                     str[0] = 0;
                     for (j = 0; j < (ptr->file_ptr->data_list)->columns; ++j)
                      {
                         count = (ptr->file_ptr->data_list)->columns * i + j; 
                         strcat (str, data_ptr[count]);
                         strcat (str, "\1");
                      }

                     if ((status = MEMwrite (ptr->temp_list,  
                                                  str)) != MEM_S_SUCCESS)
                      {
                         _NFIdebug ((fname, "MEMwrite = <0x%.8x>\n", status));
                         FIg_set_state_off (*form, FI_ACCEPT);
                         ERRload_struct (NFI, NFI_E_MEM, "%s%x", 
                                         "MEMwrite", status);
                         _NFIdebug ((fname, " returning FAILURE\n"));
                         return (NFI_E_MEM);
                       }
                  }
                      
                 if ((status = MEMbuild_array (ptr->temp_list)) != MEM_S_SUCCESS)
                  {
                     _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
                     FIg_set_state_off (*form, FI_ACCEPT);
                     ERRload_struct (NFI, NFI_E_MEM, "%s%x",   
                                     "MEMbuild_array", status);
                     _NFIdebug ((fname, " returning FAILURE\n"));
                     return (NFI_E_MEM);
                  }
             }

            if (ptr->command == NFI_F_CHANGE)
             {
                /* put "Y" in for all changed rows.  for now put "Y" for all */ 
                
                if ((status = _NFFfind_column_offset((ptr->file_ptr)->data_list,
                                        "n_status", &offset)) != NFI_S_SUCCESS)
                 {
                    _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n",
                                status));
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (status);
                 }

                for (i = 0; i < (ptr->file_ptr->data_list)->rows; ++i)
                 {
                    if ((status = MEMwrite_data ((ptr->file_ptr)->data_list,
                                     "Y", i + 1, offset + 1)) != MEM_S_SUCCESS)
                    {
                       _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n",
                                   status));
                       FIg_set_state_off (*form, FI_ACCEPT);
                       ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data",
                                       status);
                       _NFIdebug ((fname, " returning FAILURE\n"));
                       return (NFI_E_MEM);
                    }
                 }
                      
                status = MEMbuild_array ((ptr->file_ptr)->data_list);
                if (status != MEM_S_SUCCESS)
                 {
                    _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
                    FIg_set_state_off (*form, FI_ACCEPT);
                    ERRload_struct (NFI, NFI_E_MEM, "%s%x",   
                                    "MEMbuild_array", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_MEM);
                 }
             }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, working_message, NULL);

            /*  Call NFMR to add/change the entity  */

            _NFIdebug ((fname, "calling NFMR function ...\n"));

            switch (ptr->command)
             {
                case NFI_F_ADD :
                   status = (long) NFFglobal.NFMRfunction[0] (ptr->catalog,
                            ptr->item, ptr->revision, NFM_ADD_FILE_TO_ITEM,
                            ptr->temp_list);

                   _NFIdebug ((fname,
                       "NFMRdefine_file_information = <0x%.8x>\n", status));
                break;

                case NFI_F_COPY :
		   if( _NFMdebug_st.NFIdebug_on )
		    MEMprint_buffers( "F_DATA_LIST", ptr->file_ptr->data_list,
				      _NFMdebug_st.NFIdebug_file);
                   status = (long) NFFglobal.NFMRfunction[0] (ptr->catalog,
                            ptr->add_ptr->attr_list,  ptr->add_ptr->data_list,
                            ptr->file_ptr->attr_list, ptr->file_ptr->data_list);

                   _NFIdebug ((fname,
                       "NFMRcopy_item_n function = <0x%.8x>\n", status));
		   if(  (status == NFM_S_SUCCESS) &&
			(NFFglobal.forms[MAIN_LABEL] != NULL) )
		   {
		        FIfld_set_text(NFFglobal.forms[MAIN_LABEL], ITEM_FIELD,
				 0, 0, NFFglobal.new_item, FALSE);
		        strcpy( NFFglobal.item, NFFglobal.new_item );
			strcpy( NFFglobal.new_item, "" );

		        FIfld_set_text (NFFglobal.forms[MAIN_LABEL], 
				REVISION_FIELD, 0, 0, NFFglobal.new_revision,
				FALSE);
		        strcpy( NFFglobal.revision, NFFglobal.new_revision );
			strcpy( NFFglobal.new_revision, "" );
		   }
                   else NFFerror_message(NULL);
                break;

                case NFI_F_DELETE :
                   status = (long) NFFglobal.NFMRfunction[0] (ptr->catalog,
                            ptr->item, ptr->revision, NFM_DELETE_FILE_FROM_ITEM,
                            ptr->file_ptr->data_list);

                   _NFIdebug ((fname,
                       "NFMRdefine_file_information = <0x%.8x>\n", status));
                break;

                case NFI_F_CHANGE :
                   status = (long) NFFglobal.NFMRfunction[0] (ptr->catalog,
                          ptr->item, ptr->revision, NFM_CHANGE_FILE_INFORMATION,
                            ptr->file_ptr->data_list);

                   _NFIdebug ((fname,
                       "NFMRdefine_file_information = <0x%.8x>\n", status));
                break;
             }

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Set the next state  */

/* Bypassing this error to avoid SEGV in Nfmfisx (cc) while changing chkout 
   item file. Mahesh 12/03/96. 
   This change may not apply to Nfmfix Traditional, but working fine for both. 
   Defferred to add #ifdef COMBINED_FLAG for the time being - PS
*/
            if(status != NFM_E_DFI_NO_COFILE_CHG)
            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            NFFfree_copy (form, ptr);
            ptr = NULL; 

            break;

        case NFI_DATA_LIST:

            if (ptr->command == NFI_F_DELETE)
                break;

            /* get the selected field information and set its defaults */

            status = _NFFset_select_attr_data (*form, 0, &(ptr->act_row),
                                               &(ptr->act_col), ptr->file_ptr);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFset_select_attr_data <0x%.8x>\n",
                           status));
            break;

        case NFI_VALUE_FIELD:

            if (ptr->command == NFI_F_DELETE)
                break;

            if (ptr->command == NFI_F_COPY)
               status = _NFFprocess_value_field (*form, ptr->act_row,
                                              ptr->act_col, ptr->file_ptr, 0);
            else
               status = _NFFprocess_value_field (*form, ptr->act_row,
                                              ptr->act_col, ptr->file_ptr, 1);
            if (status != NFI_S_SUCCESS)
             {
               _NFIdebug ((fname, " _NFFprocess_value_field <0x%.8x>\n",
                           status));
               break;
             }

            /* Position the cursor in the next column */

/*
            status = _NFFgeneric_fld_pos_cur (*form, NFI_DATA_LIST,
                              &(ptr->act_row), &(ptr->act_col), ptr->file_ptr);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFgeneric_fld_pos_cur <0x%.8x>\n",
                           status));
*/
              
            break;

        case NFI_ADD_FILE_BUTTON:

            if (ptr->command == NFI_F_DELETE)
                break;

            status = _NFFadd_data_row (*form, NFI_DATA_LIST, &(ptr->act_row),
                                       &(ptr->act_col), ptr->file_ptr->rows,
                                     ptr->file_ptr->data_list, ptr->temp_list);
            if (status != NFI_S_SUCCESS)
             { 
               _NFIdebug ((fname, " _NFFadd_data_row <0x%.8x>\n",
                           status));
               break;
             }

            /* Position the cursor in the next column */

            status = _NFFadd_fld_pos_cur (*form, NFI_DATA_LIST,
                                  ptr->act_row, ptr->act_col, &(ptr->act_row),
                                  &(ptr->act_col), ptr->file_ptr);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFadd_fld_pos_cur <0x%.8x>\n",
                           status));
            break;

        case NFI_DEL_FILE_BUTTON:

            if (ptr->command == NFI_F_DELETE)
                break;

            if (!(ptr->file_ptr)->data_list)
               break;

            if (ptr->command == NFI_F_ADD)
             {
                status = _NFFdelete_add_rows (*form, NFI_DEL_DATA_LIST, 
                                           &(ptr->act_row), &(ptr->act_col),
                                       (ptr->file_ptr)->data_list, &data_list);
                if (status != NFI_S_SUCCESS)
                 {
                   MEMclose (&data_list);
                   if ((status == NFI_W_NO_FILES_EXIST_IN_MCF) || 
                       (status == NFI_W_NO_FILES_TO_DELETE) ||
                       (status == NFI_W_CANNOT_DELETE_FIRST_ROW))
                       status = NFI_S_SUCCESS;   
                   _NFIdebug ((fname, " _NFFdelete_add_rows <0x%.8x>\n",
                               status));
                   break;
                 }
             }
            else
             {
                status = _NFFdelete_data_row (*form, NFI_DEL_DATA_LIST, 
                                       (ptr->file_ptr)->data_list, &data_list);
                if (status != NFI_S_SUCCESS)
                 {
                   MEMclose (&data_list);
                   if ((status == NFI_W_NO_FILES_EXIST_IN_MCF) || 
                       (status == NFI_W_NO_FILES_TO_DELETE) ||
                       (status == NFI_W_CANNOT_DELETE_FIRST_ROW))
                      status = NFI_S_SUCCESS;   
                   _NFIdebug ((fname, " _NFFdelete_data_row <0x%.8x>\n",
                               status));
                   break;
                 }
             }
           
            /* close the ptr->file_ptr->data_list */

            MEMclose (&((ptr->file_ptr)->data_list));
            (ptr->file_ptr)->data_list = NULL;

            /* Copy the data_list into the ptr->file_ptr->data_list */

            _NFIdebug ((fname,
                        "Copying the buffer into ptr->file_ptr->data_list\n"));

            if ((status = MEMsplit_copy_buffer (data_list,
                         &((ptr->file_ptr)->data_list), 0)) != MEM_S_SUCCESS)
              {
                MEMclose (&data_list);
                _NFIdebug ((fname, "MEMsplit_copy_buffer = <0x%.8x>\n",
                            status));
                ERRload_struct  
                    (NFI, NFI_E_MEM, "%s%x", "MEMsplit_copy_buffer", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                status = NFI_E_MEM;
              }
             MEMclose (&data_list);

            break;

        case NFI_VALIDATION_LIST:

            if (ptr->command == NFI_F_DELETE)
                break;

            if (ptr->command == NFI_F_COPY)
               status = _NFFprocess_validate_field (*form, -1, ptr->act_row,
                                            ptr->act_col, ptr->file_ptr, 0);
            else
               status = _NFFprocess_validate_field (*form, -1, ptr->act_row,
                                            ptr->act_col, ptr->file_ptr, 1);
            if (status != NFI_S_SUCCESS)
             {
               _NFIdebug ((fname, " _NFFprocess_validate_field <0x%.8x>\n",
                       status));
               break;
             }

            /* Position the cursor in the next column */

/*
            status = _NFFgeneric_fld_pos_cur (*form, NFI_DATA_LIST,
                               &(ptr->act_row), &(ptr->act_col), ptr->file_ptr);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFgeneric_fld_pos_cur <0x%.8x>\n",
                           status));
*/

            break;

        case NFI_DELETE_FILE_TOGGLE:

            if (ptr->command != NFI_F_DELETE)
                break;

            status = _NFFselect_all_rows (*form, NFI_DATA_LIST,
                               ptr->file_ptr->rows, ptr->file_ptr->data_list);
            if (status != NFI_S_SUCCESS)
               _NFIdebug ((fname, " _NFFselect_all_rows <0x%.8x>\n",
                           status));
            break;

        default:
            _NFIdebug ((fname, " unknown gadget <%d>\n", g_label));
        break; 
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

