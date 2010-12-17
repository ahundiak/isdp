
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFmain_form.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFadd_init (entity, command)
  char   *entity;  /*  i - item, project, storage area, user, etc.  */
  int    command;
  {
    auto    int     title_no = NULL;
    auto    long    status;
    auto    char    title[NFF_MAX_MESSAGE];
    auto    char    default_title[NFF_MAX_MESSAGE];
    auto    char    write_or_update[10];
                                 /*  "n_write" or "n_update" for displaying  */
    auto    char    lop_name[40]; /*  List of Projects name for Add Project  */
    auto    char    *title_fmt = "%s";
    static  char    *fname = "NFFadd_init";

    /*  Pointer to the item structure  */

    NFFadd_ptr    ptr;

    _NFIdebug ((fname, "entity = <%s>\n", entity));
    _NFIdebug ((fname, "command = <0x%.8x>\n", command));

    /*  Initialize the structure  */

    if ((ptr = (NFFadd_ptr) malloc
        (sizeof (struct NFFadd_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFadd_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFadd_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    ptr->done = FALSE;
    ptr->command = command;
    ptr->rows = NULL;
    ptr->active_attribute = -1;
    ptr->validate_row = -1;
    ptr->attr_list = NULL;
    ptr->data_list = NULL;
    ptr->value_list = NULL;
    strcpy (ptr->entity, entity);
    strcpy (lop_name, "");

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    _NFIdebug ((fname, "calling NFMRquery function ...\n"));

    switch (command)
      {
        case ADD_ITEM:
            title_no = NFT_P_ADD_ITEM;
            strcpy (write_or_update, "n_write");
            sprintf (default_title, "Add Item to Catalog \"%s\"", entity);
            status = NFMRquery_add_item_attributes
                ((long) 0, entity, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        case ADD_SET:
            title_no = NFT_P_ADD_SET;
            strcpy (write_or_update, "n_write");
            sprintf (default_title, "Add Set to Catalog \"%s\"", entity);
            status = NFMRquery_add_set_attributes
                ((long) 0, entity, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        case ADD_PROJECT:
            title_no = NFT_P_ADD_PROJECT;
            title_fmt = NULL;
            strcpy (write_or_update, "n_write");
            strcpy (default_title, "Add Project");
            status = NFMRquery_addto_lop_attributes
                ((long) 0, lop_name, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        case CHANGE_PROJECT:
            title_no = NFT_P_CHANGE_PROJECT;
            strcpy (write_or_update, "n_update");
            sprintf (default_title, "Change Project \"%s\"", entity);
            status = NFMRquery_changeto_lop_attributes
                ((long) 0, entity, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        case ADD_SA:
            title_no = NFT_P_ADD_SA;
            title_fmt = NULL;
            strcpy (write_or_update, "n_write");
            strcpy (default_title, "Add I/NFM Storage Area");
            status = NFMRquery_add_st_area_attributes
                ((long) 0, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        case CHANGE_SA:
            title_no = NFT_P_CHANGE_SA;
            strcpy (write_or_update, "n_update");
            sprintf (default_title, "Change Storage Area \"%s\"", entity);
            status = NFMRquery_change_sa_attributes
                ((long) 0, entity, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        case ADD_NODE:
            title_no = NFT_P_ADD_NODE;
            title_fmt = NULL;
            strcpy (write_or_update, "n_write");
            strcpy (default_title, "Add I/NFM Node");
            status = NFMRquery_add_node_attributes
                ((long) 0, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        case CHANGE_NODE:
            title_no = NFT_P_CHANGE_NODE;
            strcpy (write_or_update, "n_update");
            sprintf (default_title, "Change Node \"%s\"", entity);
            status = NFMRquery_change_node_attributes
                ((long) 0, entity, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        case ADD_USER:
            title_no = NFT_P_ADD_USER;
            title_fmt = NULL;
            strcpy (write_or_update, "n_write");
            strcpy (default_title, "Add I/NFM User");
            status = NFMRquery_add_user_attributes
                ((long) 0, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        case CHANGE_USER:
            title_no = NFT_P_CHANGE_USER;
            strcpy (write_or_update, "n_update");
            sprintf (default_title, "Change User \"%s\"", entity);
            status = NFMRquery_change_user_attributes
                ((long) 0, entity, &(ptr->attr_list),
                &(ptr->data_list), &(ptr->value_list));
            break;

        default:
            _NFIdebug ((fname, "unknown add/change command <%d>\n", command));
            status = NFI_E_INVALID_INPUT;
            break;
      }

    _NFIdebug ((fname, "returned from NFMRquery function\n"));

    if (status != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRquery function = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array (ptr->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (ptr->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, NULL);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list", ptr->attr_list,
            _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list", ptr->data_list,
            _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers("value_list", ptr->value_list,
            _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the add/change form  */

    if ((status = (long) FIf_new (ADD_LABEL, ADD_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, NULL);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the data in the attributes field  */

    if ((status = _NFFadd_load_attributes
        (NFFglobal.current_form, ptr, write_or_update)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_load_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if (command == ADD_NODE)
     {
         /* disable the FI_EXECUTE button due to the adding of the utility-
            storage area.                                                  */
/*
         FIg_disable (NFFglobal.current_form, FI_EXECUTE);*/
     }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, &NFFglobal.current_form);
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
        _NFFfree_add (ptr, &NFFglobal.current_form);
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
        _NFFfree_add (ptr, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    _NFIdebug ((fname, "title_no = <0x%.8x>\n", title_no));
    if(title_fmt != NULL)
	{
    	_NFIdebug ((fname, "title_fmt = <%s>\n", title_fmt));
	}
    else
    	_NFIdebug ((fname, "title_fmt = <>\n"));
    _NFIdebug ((fname, "entity = <%s>\n", entity));

    if ((status = (long) UMSGetByNum
        (title, title_no, title_fmt, entity)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, default_title);
      }

    _NFIdebug ((fname, "title = <%s>\n", title));

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_add (ptr, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Display the form  */

    if ((status = (long) FIf_display
        (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_add (ptr, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Select the first row  */

    if ((status = (long) FImcf_set_select
        (NFFglobal.current_form, INFORMATION_MCF, 0, TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
        _NFFfree_add (ptr, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFadd_attributes_field
        (NFFglobal.current_form, 0, write_or_update, ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_attributes_field = <0x%.8x>\n", status));
        _NFFfree_add (ptr, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    int     working_message;
    auto    int     main_label1 = NULL;
    auto    int     main_label2 = NULL;
    auto    int     main_label3 = NULL;
    auto    long    status = NFI_S_SUCCESS;
    auto    long    cmd_status = NFM_S_SUCCESS;
    auto    short   add_node = FALSE;
    auto    short   item_or_project = FALSE;
    auto    char    *global_location1 = NULL;
    auto    char    *global_location2 = NULL;
    auto    char    *global_location3 = NULL;
    auto    char    command[15];
    auto    char    write_or_update[10];
    auto    char    attribute1[20];
    auto    char    attribute2[20];
    auto    char    old_sa[30];
    auto    char    sa_type[3];
    auto    short   entity_flag;
    static  char    *fname = "_NFFadd_notify";
    auto    char    temp_str1[50]; /* PS */
    auto    char    temp_str2[50];

    /*  Pointer to structure to store the MEM pointers in  */

    NFFadd_ptr    ptr;

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

    switch (ptr->command)
      {
        case ADD_ITEM:
            strcpy (command, NFI_M_ADD_ITEM);
            strcpy (write_or_update, "n_write");
            strcpy (attribute1, "n_itemname");
            strcpy (attribute2, "n_itemrev");
            global_location1 = NFFglobal.item;
            global_location2 = NFFglobal.revision;
            main_label1 = ITEM_FIELD;
            main_label2 = REVISION_FIELD;
            working_message = NFI_I_ADD_ITEM;
            NFFglobal.NFMRfunction[0] = NFMRadd_item;
            entity_flag = TRUE;
            break;

        case ADD_PROJECT:
            strcpy (command, NFI_M_ADD_PROJECT);
            strcpy (write_or_update, "n_write");
            strcpy (attribute1, "n_projectname");
            strcpy (attribute2, "");
            global_location1 = NFFglobal.project;
            main_label1 = PROJECT_FIELD;
            working_message = NFI_I_ADD_PROJECT;
            NFFglobal.NFMRfunction[0] = NFMRadd_project;
            item_or_project = TRUE;
            entity_flag = FALSE;
            break;

        case CHANGE_PROJECT:
            strcpy (command, NFI_M_CHANGE_PROJECT);
            strcpy (write_or_update, "n_update");
            strcpy (attribute1, "n_projectname");
            strcpy (attribute2, "");
            global_location1 = NFFglobal.project;
            main_label1 = PROJECT_FIELD;
            working_message = NFI_I_CHANGE_PROJECT;
            NFFglobal.NFMRfunction[0] = NFMRchange_project;
            entity_flag = FALSE;
            break;

        case ADD_SA:
            strcpy (command, NFI_M_ADD_SA);
            strcpy (write_or_update, "n_write");
            strcpy (attribute1, "n_saname");
            strcpy (attribute2, "");
            global_location1 = NFFglobal.storage_area;
            main_label1 = SA_FIELD;
            working_message = NFI_I_ADD_SA;
            NFFglobal.NFMRfunction[0] = NFMRadd_storage_area;
            entity_flag = FALSE;
            break;

        case CHANGE_SA:
            strcpy (command, NFI_M_CHANGE_SA);
            strcpy (write_or_update, "n_update");
            strcpy (attribute1, "n_saname");
            strcpy (attribute2, "n_type");
            global_location1 = NFFglobal.storage_area;
            global_location3 = NFFglobal.working_area;
            main_label1 = SA_FIELD;
            main_label3 = WA_FIELD;
            strcpy( old_sa, NFFglobal.storage_area );
            working_message = NFI_I_CHANGE_SA;
            NFFglobal.NFMRfunction[0] = NFMRchange_sa;
            entity_flag = FALSE;
            break;

        case ADD_NODE:
            strcpy (command, NFI_M_ADD_NODE);
            strcpy (write_or_update, "n_write");
            strcpy (attribute1, "n_nodename");
            strcpy (attribute2, "");
            global_location1 = NFFglobal.node;
            main_label1 = NODE_FIELD;
            working_message = NFI_I_ADD_NODE;
            NFFglobal.NFMRfunction[0] = NFMRadd_node;
            add_node = TRUE;
            entity_flag = FALSE;
            break;

        case CHANGE_NODE:
            strcpy (command, NFI_M_CHANGE_NODE);
            strcpy (write_or_update, "n_update");
            strcpy (attribute1, "n_nodename");
            strcpy (attribute2, "");
            global_location1 = NFFglobal.node;
            main_label1 = NODE_FIELD;
            working_message = NFI_I_CHANGE_NODE;
            NFFglobal.NFMRfunction[0] = NFMRchange_node;
            entity_flag = FALSE;
            break;

        case ADD_USER:
            strcpy (command, NFI_M_ADD_USER);
            strcpy (write_or_update, "n_write");
            strcpy (attribute1, "n_username");
            strcpy (attribute2, "");
            global_location1 = NFFglobal.user;
            main_label1 = USER_FIELD;
            working_message = NFI_I_ADD_USER;
            NFFglobal.NFMRfunction[0] = NFMRadd_user;
            entity_flag = FALSE;
            break;

        case CHANGE_USER:
            strcpy (command, NFI_M_CHANGE_USER);
            strcpy (write_or_update, "n_update");
            strcpy (attribute1, "n_username");
            strcpy (attribute2, "");
            global_location1 = NFFglobal.user;
            main_label1 = USER_FIELD;
            working_message = NFI_I_CHANGE_USER;
            NFFglobal.NFMRfunction[0] = NFMRchange_user;
            entity_flag = FALSE;
            break;

        default:
            _NFIdebug ((fname,
                "unknown add/change command <%d>\n", ptr->command));
            _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_BAD_COMMAND));
            return (NFI_E_BAD_COMMAND);
      }

    switch (g_label)
      {
        case FI_HELP:

            if (status = _NFFhelp_topic (command))
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

            _NFFfree_add (ptr, form);

            break;

        case FI_ACCEPT:
        case FI_EXECUTE:

            if ((status = _NFFadd_validate_accept
                (*form, write_or_update, ptr)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFadd_validate_accept = <0x%.8x>\n", status));
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            if (ptr->done == FALSE)
              {
                FIg_set_state_off (*form, FI_ACCEPT);
                break;
              }

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer
                    ("attr_list", ptr->attr_list, _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer
                    ("data_list", ptr->data_list, _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, working_message, NULL);

            /*  Call NFMR to add/change the entity  */

            _NFIdebug ((fname, "calling NFMR add/change function ...\n"));

            if (entity_flag == TRUE)
              {
                status = (long) NFFglobal.NFMRfunction[0]
                    ((long) 0, ptr->entity,
                    ptr->attr_list, ptr->data_list);
              }
            else
              {
                status = (long) NFFglobal.NFMRfunction[0]
                    ((long) 0, ptr->attr_list, ptr->data_list);
              }

            _NFIdebug ((fname,
                "NFMRadd/change function = <0x%.8x>\n", status));

            /*  Save the command status  */

            cmd_status = status;

            /*  Erase the message  */

            NFFerase_message ();

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            if (cmd_status == NFM_S_SUCCESS)
              {
                /*  Find the new active data  */

                _NFFfind_active_data
                    (ptr->data_list, attribute1, global_location1);
    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
                /* work around change - to set font for SCO - SSRS 2 Feb 94 */
                FIg_set_font( NFFglobal.forms[MAIN_LABEL], main_label1, "7x13bold", 15 );
#endif
/* replaced this statement with the following statements - PS 

                FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                    main_label1, 0, 0, global_location1, FALSE);
*/
                _NFFcheck_two_tics(global_location1, temp_str1);
                FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                    main_label1, 0, 0, temp_str1, FALSE);
/* PS 12 Dec 95 */
                if (main_label1 == ITEM_FIELD)
                        strcpy(NFFglobal.item, temp_str1);

                if (global_location2 != NULL)
                  {
                    /*  This is only for revision  */

                    _NFFfind_active_data
                        (ptr->data_list, attribute2, global_location2);
    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
                   /* work around change - to set font for SCO - SSRS 2 Feb 94 */
                    FIg_set_font( NFFglobal.forms[MAIN_LABEL], main_label2, "7x13bold", 15 );
#endif
/* this statement is replaced with the following two statements - PS
                    FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                        main_label2, 0, 0, global_location2, FALSE);
*/
                    _NFFcheck_two_tics(global_location2, temp_str2);

                    FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                        main_label2, 0, 0, temp_str2, FALSE);
 
/* to store the unticked revision - PS 12 Dec 95*/
                if (main_label2 == REVISION_FIELD)
                        strcpy(NFFglobal.revision, temp_str2);

                    /*  Change the item label (might be a set)  */

                    _NFFalter_item_text_label ("Item Name");
                    strcpy (NFFglobal.set_indicator, "");
                  }

                if (global_location3 != NULL)
                  {
                    /*  This is only for the case where
		     *  the user changed the storage area while the
		     *  working area and storage area are the same. Also
		     *  make sure the new storage area type was not changed
		     *  to something other than "W" or "B". If it was,
		     *  the working area name should be cleared. */

                    _NFFfind_active_data
                        (ptr->data_list, attribute2, sa_type);

		    if((strcmp( old_sa, NFFglobal.working_area ) == 0) &&
		      ((strcmp( sa_type, "B" ) == 0 ) ||
		       (strcmp( sa_type, "W" ) == 0 ) ))
		      {
    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
                        /* work around change - to set font for SCO - SSRS 2 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], main_label3, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            main_label3, 0, 0, global_location1, FALSE);
			strcpy( NFFglobal.working_area, global_location1 );
		      }
		    else if((strcmp( old_sa, NFFglobal.working_area ) == 0) &&
		       ((strcmp( sa_type, "B" ) != 0 ) &&
		        (strcmp( sa_type, "W" ) != 0 ) ))
		      {
    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
                        /* work around change - to set font for SCO - SSRS 2 Feb 94 */
                        FIg_set_font( NFFglobal.forms[MAIN_LABEL], main_label3, "7x13bold", 15 );
#endif
                        FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
                            main_label3, 0, 0, "", FALSE);
			strcpy( NFFglobal.working_area, "" );
		      }
                  }
              }

            if ((g_label != FI_EXECUTE) && (cmd_status == NFM_S_SUCCESS))
              {
                /*  Close all allocated buffers and delete the form  */

                _NFFfree_add (ptr, form);
              }

            if ((status == NFI_S_SUCCESS) && (cmd_status == NFM_S_SUCCESS))
              {
                if (add_node == TRUE)
                  {
                    _NFIdebug ((fname, "adding utility storage area ...\n"));
                    _NFFprocess_data (0, NFI_M_ADD_UTIL_SA); 
                    break;
                  }
              }
/*
            if ((g_label == FI_EXECUTE) || (cmd_status != NFM_S_SUCCESS))
              {
                _NFIdebug ((fname, "validating access for next one ...\n"));
                NFFvalidate_user_access (command);
                break;
              }
*/
            if (*form != NULL)
              {
                /*  Pop the button back up  */

                FIg_set_state_off (*form, g_label);
              }

            break;

        case INFORMATION_MCF:

            if ((status = _NFFadd_attributes_field
                (*form, row, write_or_update, ptr)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_attributes_field = <0x%.8x>\n", status));

            break;

        case VALUE_FIELD:

            if ((status = _NFFadd_value_field
                (*form, write_or_update, ptr)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_value_field = <0x%.8x>\n", status));

            break;

        case VALIDATE_MCF:

            if ((status = _NFFadd_validate_field
                (*form, row, write_or_update, ptr)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_validate_field = <0x%.8x>\n", status));

            break;
      }

/* returned cmd_status instead of status for Intel/Solaris - MVVMK 8th Feb 96 */
#ifdef OS_INTELSOL
    _NFIdebug ((fname, " returning <0x%.8x>\n", cmd_status));
    return (cmd_status);
#else
    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
#endif
  }
