
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h" 
#include "NFFflag_item.h"

/*
   NFMporttypes.h defines macros for OS specific typedefs.
   -- modified by KMM on 10.12.93.
*/
#include "NFMporttypes.h"

/*************************************************************************
 *                                                                       *
 *  Function : NFFnflag_item_files                                       *
 *             The function name was NFIflag_item_files in I/NFM 2.3     *
 *                                                                       *
 *  The purpose of these functions is to flag items for backup, archive, *
 *  restore, or delete.                                                  *
 *                                                                       *
 *  This is the same code to process the "Flag Restore" command that     *
 *  was used in I/NFM 2.3.0.8.  I am only modifying it due to function   *
 *  changes in 3.1.                                                      *
 *                                                                       *
 *  Note the type argument is being left in just in case product planning*
 *  decides that they want all commands to display the version info.     *
 *  mms-08/11/92 - New API for query_flag_restore                        *
 *************************************************************************/ 
 

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFnflag_item_files (catalog, item, revision, type)
    char    *catalog;
    char    *item;
    char    *revision;
    short   type;      /* in case all flagging changes in future. */
  {
    long    status = NFI_S_SUCCESS;
    char    str[1024];
    char    **data_ptr, **format_ptr, **column_ptr;
    MEMptr  data_list = NULL;

    NFFflag_ptr  ptr;

    static  char *fname = "NFFnflag_item_files";

    _NFIdebug ((fname, "catalog   = <%s>\n", catalog));
    _NFIdebug ((fname, "item_name = <%s>\n", item));
    _NFIdebug ((fname, "revision  = <%s>\n", revision));
    _NFIdebug ((fname, "type      = <%d>\n", type));

    if (strcmp (catalog, "") == 0)
     {
        ERRload_struct (NFI, NFI_E_NO_CATALOG, NULL); 
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NO_CATALOG);
     }

    if (strcmp (item, "") == 0)
     {
        ERRload_struct (NFI, NFI_E_NO_ITEM, NULL); 
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NO_CATALOG);
     }

    /*  Initialize the flag ptr structure  */

    if ((ptr = (NFFflag_ptr) malloc
        (sizeof (struct NFFflag_st))) == NULL)
      {
        _NFIdebug ((fname, "malloc failed;  size = <%d>\n",
                           sizeof (struct NFFflag_st)));
                ERRload_struct (NFI, NFI_E_MALLOC, "%d",
                                sizeof (struct NFFflag_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    ptr->type        = 0;   /* Not used in 3.1 */
    ptr->flag_type   = type;
    ptr->item_offset = -1;
    ptr->rev_offset  = -1;
    ptr->ver_offset  = -1;
    ptr->file_offset = -1;
    ptr->num_rows    = 0;
    ptr->vers_ptr    = NULL;
    ptr->data_list   = NULL;

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL); 

    /*  Get the database information  */

    switch (type)
     {
         case FLAG_ARCHIVE :
         case FLAG_BACKUP :
	 case FLAG_DELETE :
         break;

         case FLAG_RESTORE :
             _NFIdebug ((fname, "calling NFMRquery_flag_restore ...\n"));
/*             status = NFMRquery_flag_restore (0, catalog, &data_list); */
	     status = NFMRnew_query_flag_restore (catalog, item, revision,
						  &data_list) ;
             if (status != NFM_S_SUCCESS)
             {
               _NFIdebug ((fname, "NFMRquery_flag_... = <0x%.8x>\n", status));
               NFFerase_message ();
               MEMclose (&data_list);
              _NFFfree_flag_ptr (NULL, ptr);
	       if (status == NFM_E_NO_FILES_TO_FLAG)
		 {
		   status = NFM_E_NO_FILES_TO_FLAG;
		   ERRload_struct (NFI, status, NULL); 
		 }
	       _NFIdebug ((fname, " returning <0x%.8x>\n", status));
	       return (status);
	     }
	     _NFIdebug ((fname, "returned from NFMR_query_flag_... \n"));

	 /*  Prepare the buffer for reading  */

	 if (_NFMdebug_st.NFIdebug_on)
	   {
	     MEMprint_buffer ("data_list", data_list, _NFMdebug_st.NFIdebug_file);
	   }
	 if (data_list->rows == 0)
	   {
	     status = NFI_E_NO_FILES_TO_FLAG;
	     _NFIdebug ((fname, "No files to flag: status = <0x%.8x>\n", status));
	     ERRload_struct (NFI, status, NULL); 
	     _NFFfree_flag_ptr (NULL, ptr);
	     NFFerase_message ();
	     _NFIdebug ((fname, " returning FAILURE\n"));
	     return (status);
	   }

	 ptr->data_list = data_list ;
	 if ((status = MEMbuild_array (ptr->data_list)) != MEM_S_SUCCESS)
	   {
	     _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
	     NFFerase_message ();
	     MEMclose (&data_list);
	     _NFFfree_flag_ptr (NULL, ptr);
	     _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
	     return (NFI_E_MEM);
	   }

	 data_ptr   = (char **) (ptr->data_list)->data_ptr;
	 format_ptr = (char **) (ptr->data_list)->format_ptr;
	 column_ptr = (char **) (ptr->data_list)->column_ptr;

	 ptr->item_offset = 0 ; ptr->rev_offset = 1; ptr->ver_offset = 2;

	 _NFIdebug ((fname, " Offset for n_itemname <%d> : n_itemrev <%d> : n_fileversion <%d>\n", 
		     ptr->item_offset, 
		     ptr->rev_offset,
		     ptr->ver_offset)) ;
         break;

         default:
            status = NFI_E_INVALID_FLAG_TYPE;
            _NFIdebug ((fname, "Invalid flag type : status = <0x%.8x>\n",
                        status));
            NFFerase_message ();
            MEMclose (&data_list);
            _NFFfree_flag_ptr (NULL, ptr);
            ERRload_struct (NFI, status, "%d", type); 
            _NFIdebug ((fname, "returning FAILURE\n"));
         break;
     }

    /*  Load in the Flag form  */

    status = (long) FIf_new (FLAG_ITEM_LABEL, FLAG_ITEM_FORM, _NFFnotify, 
                             &(NFFglobal.current_form));
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFFfree_flag_ptr (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

      strcpy (str, "");

        /* Set the title of the form */

        switch (type)
         {
             case FLAG_ARCHIVE:
                status = (long) UMSGetByNum (str, NFI_P_FLAG_ARCHIVE,
                                             NULL); 
                if (status != UMS_S_SUCCESS) 
                {
                   _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                   _NFIdebug ((fname, "defaulting title\n"));
                   strcpy (str, "Select item files to flag for archive...");
                }
             break;

             case FLAG_BACKUP:
                status = (long) UMSGetByNum (str, NFI_P_FLAG_BACKUP, NULL);
                if (status != UMS_S_SUCCESS) 
                {
                   _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                   _NFIdebug ((fname, "defaulting title\n"));
                   strcpy (str, "Select item files to flag for backup...");
                }
             break;

             case FLAG_RESTORE:
                status = (long) UMSGetByNum (str, NFI_P_FLAG_RESTORE, NULL);
                if (status != UMS_S_SUCCESS) 
                {
                   _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                   _NFIdebug ((fname, "defaulting title\n"));
                   strcpy (str, "Select item files to flag for restore...");
                }
		if ((status = _NFFset_mcf_flag_data
		     (NFFglobal.current_form, ptr)) != NFI_S_SUCCESS)
		  {
		    _NFIdebug ((fname, "_NFFset_mcf_flag_data = <%d>\n", status));
		    NFFerase_message ();
		    _NFFfree_flag_ptr (&NFFglobal.current_form, ptr);
		    _NFIdebug ((fname, " returning FAILURE\n"));
		    return (status);
		  }
             break;

             case FLAG_DELETE:
                status = (long) UMSGetByNum (str, NFI_P_FLAG_DELETE, NULL);
                if (status != UMS_S_SUCCESS) 
                {
                   _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
                   _NFIdebug ((fname, "defaulting title\n"));
                   strcpy (str, "Select item files to flag for delete...");
                }
             break;
         }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, UTILITY_TITLE, str)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_flag_ptr (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }


    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_flag_ptr (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer",
                        status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Erase the message  */

    NFFerase_message ();

    /* Clear out the error message strip */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    /*  Adjust and Center the form  */

    if ((status = _NFFadjust_flag_form  
        (NFFglobal.current_form)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname,"_NFFadjust_signoff_form = <0x%.8x>\n",status));
        NFFerase_message ();
        _NFFfree_flag_ptr (&NFFglobal.current_form, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Display the flag form  */

    status = (long) FIf_display (NFFglobal.current_form);
    if (status != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_flag_ptr (&NFFglobal.current_form, ptr);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFflag_item_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    long    status = NFI_S_SUCCESS;

    NFFflag_ptr    ptr;

    char command[20];
    int  i, i_loc, r_loc, v_loc;
    char **data;
    long msg = NULL;
    static  char *fname = "_NFFflag_item_notify";

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to the flag buffer  */

    FIf_get_user_pointer (*form, &ptr);

    strcpy (command, "");

    switch (ptr->flag_type)
     {
        case FLAG_ARCHIVE:
            strcpy (command, NFI_M_FLAG_ARCHIVE);
            msg = NFI_I_FLAG_ITEM_ARCHIVE;
        break;

        case FLAG_BACKUP:
            strcpy (command, NFI_M_FLAG_BACKUP);
            msg = NFI_I_FLAG_ITEM_BACKUP;
        break;

        case FLAG_RESTORE:
            strcpy (command, NFI_M_FLAG_RESTORE);
            msg = NFI_I_FLAG_ITEM_RESTORE;
        break;

        case FLAG_DELETE:
            strcpy (command, NFI_M_FLAG_DELETE);
            msg = NFI_I_FLAG_ITEM_DELETE;
        break;
     }

    /*  Clear out the error message strip  */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL); 


    switch (g_label)
     {
        case FI_HELP:

           if (status = _NFFhelp_topic (command))
            {
               _NFIdebug ((fname,"_NFFhelp_topic = <%d>\n", status));
               ERRload_struct (NFI, NFI_E_HELP, "%s%d", "Help_topic", status);
               status = NFI_E_HELP;
            }                
           break;

        case FI_CANCEL:

            /*  Set the global command status  */

            NFFglobal.status = NFI_W_COMMAND_CANCELLED;
    
            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname,"NFFset_to_state = <0x%.8x>\n", status));

            /* Close all allocated buffers */
                        
            _NFFfree_flag_ptr (form, ptr);

            break;

        case FI_ACCEPT:

            status = _NFFvalidate_flag_accept (*form, ptr);
            if (status != NFI_S_SUCCESS)
              {
                /*  Reset the accept button  */

                if (status == NFI_I_NO_ITEMS_SELECTED)
                 {
                   NFFform_message (CURRENT_LABEL, NFI_I_NO_ITEMS_SELECTED,
                                    NULL);
                   status = NFI_S_SUCCESS;
                 }

                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }       

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, msg, NULL);
 
            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("data_list", ptr->data_list,
                                 _NFMdebug_st.NFIdebug_file);
              }

            data = (char **) ptr->data_list->data_ptr; 

            _NFIdebug ((fname, "num_rows = <%d>\n", ptr->num_rows));

            for (i = 0; i < ptr->num_rows; ++i)
             { 
                /*  Call NFMR to flag the item version */
                i_loc = ptr->data_list->columns * ptr->vers_ptr[i] + 
                                                  ptr->item_offset;
                r_loc = ptr->data_list->columns * ptr->vers_ptr[i] +
                                                  ptr->rev_offset;
                v_loc = ptr->data_list->columns * ptr->vers_ptr[i] +
                                                  ptr->ver_offset;

                _NFIdebug ((fname, "i_loc  = <%d>\n", i_loc));
                _NFIdebug ((fname, "r_loc  = <%d>\n", r_loc));
                _NFIdebug ((fname, "v_loc  = <%d>\n", v_loc));

                switch (ptr->flag_type)
                 {
                    case FLAG_ARCHIVE:
                       _NFIdebug((fname,"calling NFMRflag_item_archive ...\n"));
                       status = NFMRflag_item_archive (0,
                                NFFglobal.catalog, data[i_loc], data[r_loc]);
                    break;
    
                    case FLAG_BACKUP:
                       _NFIdebug((fname,"calling NFMRflag_item_backup ...\n"));
                       status = NFMRflag_item_backup (0,
                                NFFglobal.catalog, data[i_loc], data[r_loc]);
                    break;
    
                    case FLAG_RESTORE:
                       _NFIdebug ((fname,
                                 "calling NFMRalpha_flag_item_restore ...\n"));
                       status = NFMRalpha_flag_item_restore (0,
                                NFFglobal.catalog, data[i_loc], data[r_loc],
                                data[v_loc]); 
                    break;
    
                    case FLAG_DELETE:
                       _NFIdebug((fname,"calling NFMRflag_item_delete ...\n"));
                       status = NFMRflag_item_delete (0,
                                NFFglobal.catalog, data[i_loc], data[r_loc]);
                    break;
                 }
             }
            _NFIdebug ((fname, "returned from NFMRflag... function\n"));

            /*  Erase the message  */

            NFFerase_message ();
            /* FIf_display (*form); */  /* ???????????????????? */

            /*  Save the return status  */

            NFFglobal.status = status;

            if (status != NFM_S_SUCCESS)
                _NFIdebug ((fname,"NFMRflag_item... = <0x%.8x>\n", status));

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname,"NFFset_to_state = <0x%.8x>\n", status));

            _NFFfree_flag_ptr (form, ptr);

            break;

        case VERSION_MCF:  /* don't care */
               _NFIdebug ((fname, " VERSION_MCF ...\n\n"));
            break;
          
        default:
               _NFIdebug ((fname, " unrecognized gadget ...\n\n"));
           break;
      }

    _NFIdebug ((fname, " returning ...\n\n"));
    return (status);
  }


long _NFFset_mcf_flag_data (form, ptr)
  Form           form;
  NFFflag_ptr    ptr;
  {
    long    status = NFI_S_SUCCESS;
    int     i, j, count;
    char    **data;
    static  char *fname = "_NFFset_mcf_flag_data";

    _NFIdebug ((fname, "entering ...\n"));

    /* clear out the mcf and set num_rows to 0 */

    status = (long) FIfld_set_num_rows (form, VERSION_MCF, 0);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    data = (char **) ptr->data_list->data_ptr; 

    /* put the data into the mcf (this needs to check fields in future) */
#ifdef OS_SCO_UNIX
    FIg_set_font(form, VERSION_MCF, "7x13bold", 15);
#endif

    for (i = 0; i < ptr->data_list->rows; ++i)
     {
        for (j = 0; j < 3; ++j)
         {
            count = ptr->data_list->columns * i + j;
            status = (long) FIfld_set_text (form, VERSION_MCF, i, j,
                                            data[count], FALSE);
            if (status != FI_SUCCESS)
             {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text",
                                status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
             }
         } 
     }

    _NFIdebug ((fname, " returning SUCCESS...\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFvalidate_flag_accept (form, ptr)
  Form           form;
  NFFflag_ptr    ptr;
  {
    long status;
    int  i, sel_flag;
    static  char *fname = "_NFFvalidate_flag_accept";

    _NFIdebug ((fname, "entering ...\n"));

    if (ptr->vers_ptr)
     {
        free ((int *) ptr->vers_ptr);
        ptr->vers_ptr = NULL;
        ptr->num_rows = 0;
     }

    /* get the selected rows if any */

    for (i = 0; i < ptr->data_list->rows; ++i)
     {
         status = (long) FIfld_get_select (form, VERSION_MCF, i, 0, &sel_flag);
         if (status != FI_SUCCESS)
          {
             _NFIdebug ((fname, "FIfld_get_select = <%d>\n", status));
             ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                             "FIfld_get_select", status);
             _NFIdebug ((fname, " returning FAILURE\n"));
             return (NFI_E_FORM);
          }

         if (sel_flag)
          { 
             ++ptr->num_rows;
             if (ptr->num_rows > 1)  /* realloc */

              /* the arguments & the return value of realloc are different  */
              /* on solaris.  -- modified by KMM on 10.12.93.               */

                ptr->vers_ptr = (int *) realloc (ptr->vers_ptr, 
                                        (NFM_SIZE_T) ptr->num_rows); 
             else                    /* malloc */
                ptr->vers_ptr = (int *) malloc (ptr->num_rows); 

             if (ptr->vers_ptr == NULL)
              {
                 _NFIdebug ((fname, "malloc failed;  size = <%d>\n",
                             ptr->num_rows));
                 ERRload_struct (NFI, NFI_E_MALLOC, "%d", ptr->num_rows);
                 _NFIdebug ((fname, " returning FAILURE\n"));
                 return (NFI_E_MALLOC);
              }

             ptr->vers_ptr[ptr->num_rows -1] = i;  /* put index in int array */ 
         }
     }

    if (ptr->num_rows == 0)
     {
         /* no rows have been selected, send informational message to user. */
         status = NFI_I_NO_ITEMS_SELECTED;
         _NFIdebug ((fname, " returning INFORMATIONAL\n"));
         return (status);
     }

    /* put the data into the data_list */

    _NFIdebug ((fname, " returning SUCCESS...\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadjust_flag_form (form)
  Form    form;
  {
    long    status;

    static  char *fname = "_NFFadjust_flag_form";

    if ((status = _NFFcenter_gadget (form, UTILITY_TITLE)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFIcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFcenter_form (form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFIcenter_form = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void _NFFfree_flag_ptr (form, ptr)
  Form           *form;
  NFFflag_ptr    ptr;
  {
    char *fname = "_NFFfree_flag_ptr" ;

    _NFIdebug ((fname, "ENTER\n")) ;
    if (form != NULL)
      {
	_NFIdebug ((fname, "form != NULL\n")) ;
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (ptr)
     {
       _NFIdebug ((fname, "ptr != NULL\n")) ;
        if (ptr->vers_ptr)
            free ((int *) ptr->vers_ptr);
       MEMclose (&(ptr->data_list));
       free (ptr);
     }
    ptr = NULL;

    return;
  }

