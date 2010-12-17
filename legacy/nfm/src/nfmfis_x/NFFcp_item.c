
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFcopy_item (ptr)
    NFFcopy_ptr    ptr;         /*  Pointer to the item structure  */
  {
    long    status;
    char    title[NFF_MAX_MESSAGE];

    static  char *fname = "_NFFcopy_item";

    _NFIdebug ((fname, "catalog = <%s>\n", ptr->catalog));
    _NFIdebug ((fname, "item = <%s>\n", ptr->item));
    _NFIdebug ((fname, "revision = <%s>\n", ptr->revision));

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Load in the add/change form  */

    if ((status = (long) FIf_new (COPY_ITEM_LABEL, ADD_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        NFFfree_copy (NULL, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Create the MCF's and load the data in the MCF fields  */

    if ((status = _NFFadd_load_attributes (NFFglobal.current_form, ptr->add_ptr,
                                           "n_write")) != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFadd_load_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_copy (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    /* disable the FI_EXECUTE button since this is not a roll-thru command */

    FIg_disable (NFFglobal.current_form, FI_EXECUTE);

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

    /*  Set the value field to have only one row  */

    if ((status = (long) FIfld_set_num_rows
        (NFFglobal.current_form, VALUE_FIELD, 1)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFfree_copy (&NFFglobal.current_form, ptr);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
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

    if ((status = (long) UMSGetByNum (title, NFI_P_COPY_ITEM, "%s%s",  
                                    ptr->item, ptr->revision)) != UMS_S_SUCCESS)
     {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title, "Copy Item \"%s\" Revision \"%s\"", ptr->item,
                 ptr->revision);
     }

    _NFIdebug ((fname, "title = <%s>\n", title));

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFfree_copy (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
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

    /*  Select the first row  */

    if ((status = (long) FImcf_set_select
        (NFFglobal.current_form, INFORMATION_MCF, 0, TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
        NFFfree_copy (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFadd_attributes_field
        (NFFglobal.current_form, 0, "n_write", ptr->add_ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_attributes_field = <0x%.8x>\n", status));
        NFFfree_copy (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcopy_item_notify (g_label, value, form)
  int       g_label;
  int       value;
  Form      *form;
  {
    int     rows = 0;
    int     working_message;
    int     error_message;
    long    status = NFI_S_SUCCESS;
    char    help_command[15];
    char    write_or_update[10];

    static    char *fname = "_NFFcopy_item_notify";

    /*  Pointer to structure to store the MEM pointers in  */

    NFFcopy_ptr    ptr;

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


    if ((ptr->file_ptr)->data_list)
       rows = (ptr->file_ptr->data_list)->rows;

     strcpy (help_command, NFI_M_COPY_ITEM);
     strcpy (write_or_update, "n_write");
     if (rows)
        working_message = NFI_I_FILES_FORM;  
     else
        working_message = NFI_I_COPY_ITEM;
     error_message = NFI_E_COPY_ITEM;
     NFFglobal.NFMRfunction[0] = NFMRcopy_item_n;

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

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            /*  Close all allocated buffers and delete the form  */

            NFFfree_copy (form, ptr);
            ptr = NULL; 


            break;

        case FI_ACCEPT:

            if ((status = _NFFadd_validate_accept
                (*form, write_or_update, ptr->add_ptr)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFadd_validate_accept = <0x%.8x>\n", status));
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            if (ptr->add_ptr->done == FALSE)
              {
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            if (rows)
             {
                /*  Put up a message  */

                 NFFform_message (CURRENT_LABEL, working_message, NULL);

               NFFerase_message ();

               /* delete the form */

               if (form != NULL)
                {
                   FIf_delete (*form);
                   *form = NULL;
                   NFFglobal.current_form = NULL;
                }

               /* Call the function to process the copy file form */

               _NFIdebug ((fname,
                           "calling _NFFprocess_item_files function ...\n"));

               status = _NFFprocess_item_files (ptr); 

               /*  Save the return status  */

/*
                NFFglobal.status = status;
*/
             }
            else
             {
                /*  Put up a message  */

                 NFFform_message (CURRENT_LABEL, working_message, NULL);

                /*  Call NFMR to add/change the entity  */

               _NFIdebug ((fname, "calling NFMRcopy_item_n  function ...\n"));

               status = (long) NFFglobal.NFMRfunction[0] (ptr->catalog,
                        (ptr->add_ptr)->attr_list,  (ptr->add_ptr)->data_list,
                        (ptr->file_ptr)->attr_list, (ptr->file_ptr)->data_list);

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
                    strcpy( NFFglobal.revision,NFFglobal.new_revision );
                    strcpy( NFFglobal.new_revision, "" );
               }

               /*  Erase the message  */
   
               NFFerase_message ();
   
               /*  Save the return status  */
   
               NFFglobal.status = status;
   
               /*  Set the next state  */
   
               if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                   _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

               /*  Close all allocated buffers and delete the form  */
   
               _NFIdebug ((fname, "free up the copy ptr\n"));
               NFFfree_copy (form, ptr);
               _NFIdebug ((fname, "finished freeing up ptr\n"));
               ptr = NULL; 
             }

            break;

        case INFORMATION_MCF:

            if ((status = _NFFadd_attributes_field (*form, value,
                              write_or_update, ptr->add_ptr)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_attributes_field = <0x%.8x>\n", status));

            break;

        case VALUE_FIELD:

            if ((status = _NFFadd_value_field
                (*form, write_or_update, ptr->add_ptr)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_value_field = <0x%.8x>\n", status));

            break;

        case VALIDATE_MCF:

            if ((status = _NFFadd_validate_field (*form, value,
                              write_or_update, ptr->add_ptr)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_validate_field = <0x%.8x>\n", status));

            break;
      
         default : 
                _NFIdebug ((fname, "unknown g_label = <%d>\n", g_label));
            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

