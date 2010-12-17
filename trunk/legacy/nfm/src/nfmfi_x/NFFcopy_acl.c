
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFcopy_acl.h"
#include "NFFmain_form.h"
/* #include <FIdyn.h> */

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFcopy_acl_users ()
  {
    auto    long    status;
    auto    char    s[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFcopy_acl_users";
    char            condition[512] ;

    /*  Pointer to the acl structure  */

    NFFadd_ptr    acl;

    /*  Initialize the acl structure  */

    if ((acl = (NFFadd_ptr) malloc
        (sizeof (struct NFFadd_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFadd_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFadd_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    acl->done = FALSE;
    acl->active_attribute = -1;
    acl->validate_row = -1;
    acl->attr_list = NULL;
    acl->data_list = NULL;
    acl->value_list = NULL;

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    _NFIdebug ((fname, "calling NFMRquery_acl_attributes ...\n"));

    strcpy (condition, "n_workflowtype = 'I'") ;
    if ((status = NFMRquery_acl_attributes_condition
        (condition, &(acl->attr_list),
        &(acl->data_list), &(acl->value_list))) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRquery_acl_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, "returned from NFMRquery_acl_attributes_condition\n"));

    if ((status = MEMbuild_array (acl->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array (acl->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array (acl->value_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list",
            acl->attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list",
            acl->data_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffers ("value_list",
            acl->value_list, _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the Add form  */

    if ((status = (long) FIf_new (COPY_ACL_LABEL,
        ADD_FORM, _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, NULL);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the data in the attributes field  */

    if ((status = _NFFadd_load_attributes
        (NFFglobal.current_form, acl, "n_write")) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_load_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) acl)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_add (acl, &NFFglobal.current_form);
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
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Center the validate mcf and text on the form  */

    if ((status = _NFFcenter_gadget
        (NFFglobal.current_form, VALIDATE_TEXT)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    if ((status = (long) UMSGetByNum
        (s, NFT_P_COPY_ACL_USERS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "Add Access Control List");
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE, s)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /* disable the FI_EXECUTE button due to the additional forms */

    FIg_disable (NFFglobal.current_form, FI_EXECUTE); 

    /*  Select the first row  */

    if ((status = (long) FImcf_set_select
        (NFFglobal.current_form, INFORMATION_MCF, 0, TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFFadd_attributes_field (NFFglobal.current_form, 0, "n_write", acl);

    /*  Display the Add form  */

    if ((status = (long) FIf_display (NFFglobal.current_form)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        _NFFfree_add (acl, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcopy_acl_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    long    status = NFI_S_SUCCESS;
    static  char    *command = NFI_M_COPY_ACL_USERS ;
    static  char    *fname = "_NFFcopy_acl_notify";
    char    aclname[NFM_ACLNAME+1], workflow [NFM_WORKFLOWNAME+1] ;
    long    wfno ;
    long    _NFFget_acl_wf () ;
    long    _NFFcopy_acl_users () ;


    /*  Pointer to structure to store the MEM pointers in  */

    NFFadd_ptr    acl;

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    FIf_get_user_pointer (*form, &acl);

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

            _NFFfree_add (acl, form);

            break;

        case FI_ACCEPT:
	    status = _NFFget_acl_wf (acl, aclname, &wfno, workflow);

	    _NFIdebug ((fname, "Acl Name  <%s> : Workflow No <%d>\n",
			aclname, wfno)) ;

            if (acl->done == FALSE)
              {
                /*  Reset the accept button  */

                FIg_reset (*form, FI_ACCEPT);
                break;
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_COPY_ACL_USERS, NULL);

            /*  Erase the message  */

            NFFerase_message ();

            /*  Save the return status  */

            NFFglobal.status = status;

            /*  Close all allocated buffers and delete the form  */

            _NFFfree_add (acl, form);

            if (NFFglobal.status == NFI_S_SUCCESS)
              {
                /*  Copy users to the new ACL  */
                if ((status = _NFFcopy_acl_users
                    (aclname,wfno, workflow)) != NFI_S_SUCCESS)
                    _NFIdebug ((fname,
                        "_NFFcopy_acl_users = <0x%.8x>\n", status));
              }

            break;

        case INFORMATION_MCF:

            if ((status = _NFFadd_attributes_field
                (*form, row, "n_write", acl)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_attributes_field = <0x%.8x>\n", status));
            break;

        case VALUE_FIELD:

            if ((status = _NFFadd_value_field
                (*form, "n_write", acl)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                   "_NFFadd_value_field = <0x%.8x>\n", status));
            break;

        case VALIDATE_MCF:

            if ((status = _NFFadd_validate_field
                (*form, row, "n_write", acl)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_validate_field = <0x%.8x>\n", status));
            break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFcopy_acl_users (aclname, wfno, workflow)
     char *aclname ;
     long   wfno ;
     char *workflow ;
  {
    auto    long    status;
    auto    char    title[NFF_MAX_MESSAGE];
    auto    char    default_title[NFF_MAX_MESSAGE];
    static  char    *fname = "_NFFcopy_acl_users" ;
    long    _NFFcopy_acl_load_attributes() ;
    long     _NFFcopy_acl_attributes_field () ;

    /*  Pointer to the item structure  */

    NFFadd_ptr    ptr;
    struct NFFcopy_acl_users_st *copy_acl_ptr ;


    _NFIdebug ((fname, "New aclname <%s> : New Wfno <%d>\n", aclname, wfno)) ;

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

    if ((copy_acl_ptr = (struct NFFcopy_acl_users_st *) malloc
        (sizeof (struct NFFcopy_acl_users_st))) == NULL)
      {
        _NFIdebug ((fname,
            "malloc failed; size = <%d>\n", sizeof (struct NFFadd_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFadd_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    copy_acl_ptr -> acl_ptr = ptr ;

    ptr->done = FALSE;
    ptr->rows = NULL;
    ptr->active_attribute = -1;
    ptr->validate_row = -1;
    ptr->attr_list = NULL;
    ptr->data_list = NULL;
    ptr->value_list = NULL;

    strcpy (copy_acl_ptr->new_aclname, aclname) ;
    copy_acl_ptr -> existing_wfno = wfno ;
    strcpy (copy_acl_ptr -> new_wfname, workflow) ;

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);

    /*  Get the database information  */

    _NFIdebug ((fname, "calling NFMRquery function ...\n"));

    sprintf (default_title, "Copy ACL Users \"%s\" To New ACL \"%s\"",
	     NFFglobal.acl, aclname) ;

    status = NFMRget_acl_classes_for_copy
      (NFFglobal.acl, wfno, &(ptr->attr_list),
       &(ptr->value_list)) ;

    _NFIdebug ((fname, "returned from NFMRget_acl_classes_for_copy\n")) ;

    if (status != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMRquery function = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, NULL);
	free (copy_acl_ptr) ;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MEMbuild_array (ptr->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, NULL);
	free (copy_acl_ptr) ;
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (ptr->value_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, NULL);
	free (copy_acl_ptr) ;
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list", ptr->attr_list,
            _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("value_list", ptr->value_list,
            _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the add/change form  */

    if ((status = (long) FIf_new (COPY_ACL_USERS_LABEL, COPY_ACL_USERS_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, NULL);
	free (copy_acl_ptr) ;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) copy_acl_ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        _NFFfree_add (ptr, &NFFglobal.current_form);
	free (copy_acl_ptr) ;
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Load the data in the attributes field  */

    if ((status = _NFFcopy_acl_load_attributes
        (NFFglobal.current_form, ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcopy_acl_load_attributes = <0x%.8x>\n",
		    status));
        NFFerase_message ();
        _NFFfree_add (ptr, &NFFglobal.current_form);
	free (copy_acl_ptr) ;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Erase the message  */

    NFFerase_message ();

    /*  Center the form  */

    if ((status = _NFFcenter_form
        (NFFglobal.current_form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFFfree_add (ptr, &NFFglobal.current_form);
	free (copy_acl_ptr) ;
        _NFIdebug ((fname, " returning %d\n", status));
        return (status);
      }

    /*  Set the title  */

    if ((status = (long) UMSGetByNum
        (title, NFT_P_COPY_ACL_USERS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, default_title);
      }

    _NFIdebug ((fname, "title = <%s>\n", title));

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, CP_ACL_TITLE, title)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_add (ptr, &NFFglobal.current_form);
	free (copy_acl_ptr) ;
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
	free (copy_acl_ptr) ;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Select the first row  */

    if ((status = (long) FImcf_set_select
        (NFFglobal.current_form, CP_ACL_INFO_MCF, 0, TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
        _NFFfree_add (ptr, &NFFglobal.current_form);
	free (copy_acl_ptr) ;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((status = _NFFcopy_acl_attributes_field
        (NFFglobal.current_form, 0, ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcopy_acl_attributes_field = <0x%.8x>\n", status));
        _NFFfree_add (ptr, &NFFglobal.current_form);
	free (copy_acl_ptr) ;
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFcopy_acl_users_notify (g_label, row, form)
  int       g_label;
  int       row;
  Form      *form;
  {
    auto    int     working_message;
    auto    long    status = NFI_S_SUCCESS;
    auto    long    cmd_status = NFM_S_SUCCESS;
    auto    char    command[15];
    static  char    *fname = "_NFFcopy_acl_users_notify" ;
    long _NFFcopy_acl_attributes_field () ;
    long _NFFcopy_acl_validate_field () ;
    long _NFFblank_entry () ;

    /*  Pointer to structure to store the MEM pointers in  */

    NFFadd_ptr    ptr;
    struct NFFcopy_acl_users_st *copy_acl_ptr ;


    /*  Pull out the pointer to all of the buffers  */

    if ((status = (long) FIf_get_user_pointer
        (*form, (char *) &copy_acl_ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        _NFIdebug ((fname, " returning <%d>\n", status));
        return (NFI_E_FORM);
      }


    ptr = copy_acl_ptr->acl_ptr ;

    strcpy (command, NFI_M_COPY_ACL_USERS) ;

    working_message = NFI_I_COPY_ACL_USERS;  

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
/***********************
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
*******************/

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer
                    ("attr_list", ptr->attr_list, _NFMdebug_st.NFIdebug_file);
              }

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, working_message, NULL);

            /*  Call NFMR to add/change the entity  */

            _NFIdebug ((fname, "calling NFMR copy function ...\n"));

	    status = NFMRcopy_acl_users (copy_acl_ptr->new_aclname,
					 copy_acl_ptr->existing_wfno,
					 NFFglobal.acl,
					 ptr->attr_list) ;
	    
            /*  Save the command status  */

            cmd_status = status;
	    _NFIdebug ((fname, "Status of NFMRcopy_acl_users is <0x%.8x>\n",
			cmd_status)) ;

            /*  Erase the message  */

            NFFerase_message ();

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFset_to_state = <0x%.8x>\n", status));

            if (cmd_status == NFM_S_SUCCESS)
              {
                /*  Close all allocated buffers and delete the form  */
		/*  Set the NFFglobal  ***/
		strcpy (NFFglobal.acl, copy_acl_ptr->new_aclname) ;
		strcpy (NFFglobal.workflow, copy_acl_ptr->new_wfname) ;
		_NFIdebug ((fname, "Set the global structure acl <%s> : workflowname <%s>\n",
			    NFFglobal.acl, NFFglobal.workflow)) ;

		FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
				ACL_FIELD, 0, 0,
				NFFglobal.acl, FALSE) ;
		FIfld_set_text (NFFglobal.forms[MAIN_LABEL],
				WF_FIELD, 0, 0,
				NFFglobal.workflow, FALSE) ;
	      }

	    _NFIdebug ((fname, "freeing all dynamic variables\n")) ;
	    _NFFfree_add (ptr, form);
	    free (copy_acl_ptr) ;


            if (*form != NULL)
              {
                /*  Pop the button back up  */

                FIg_set_state_off (*form, g_label);
              }

            break;
/******* click on multiple column field ******/
        case CP_ACL_INFO_MCF :

            if ((status = _NFFcopy_acl_attributes_field
                (*form, row,  ptr)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_attributes_field = <0x%.8x>\n", status));

            break;

/****** click on validation list **********/
        case CP_ACL_VALIDATE_MCF:

            if ((status = _NFFcopy_acl_validate_field
                (*form, row, ptr)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_validate_field = <0x%.8x>\n", status));

            break;

/****** blank entry  **********/
        case CP_ACL_BLANK_ENTRY:
            if ((status = _NFFblank_entry
                (*form, ptr)) != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "_NFFadd_validate_field = <0x%.8x>\n", status));

            break;

      }

    _NFIdebug ((fname, "returning <0x%.8x>\n", status));
    return (status);
  }


long _NFFget_acl_wf (ptr, acl, workflowno, workflow)
  NFFadd_ptr    ptr;
  char          *acl ;
  long          *workflowno;
     char       *workflow ;
  {
    int     i, offset ;
    int     column;
    long    status, list_no, z, offset_z ;
    char    **attr_ptr;
    char    **data_ptr, **value_ptr ;
    short   name_offset;
    short   write_offset;
    short   null_offset;
    short   valueno_offset ;

    static  char *fname = "_NFFget_acl_wf" ;

    _NFIdebug ((fname, "data_list->rows = <%d>\n", (ptr->data_list)->rows));

    /*  See if there is any data at all  */

    if ((ptr->data_list)->rows == 0)
      {
        ptr->done = FALSE;
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }

    if ((status = MEMbuild_array (ptr->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    attr_ptr = (char **) (ptr->attr_list)->data_ptr;

    if ((status = MEMbuild_array (ptr->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    data_ptr = (char **) (ptr->data_list)->data_ptr;

    /*  Make sure that there is data for all non-NULL attributes  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_name", &name_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_write", &write_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_valueno", &valueno_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }


    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_null", &null_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Assume that we are finished  */

    ptr->done = TRUE;

    column = 0;
    for (i = 0; i < (ptr->attr_list)->rows; i++) 
      {
	offset = i*(ptr->attr_list)->columns ;
        /*  Pull out any values for active data  */

        if ((strcmp (attr_ptr[offset + name_offset], "n_aclname")) == 0)
          {
            _NFIdebug ((fname, "acl = <%s>\n", data_ptr[column]));
	    strcpy (acl, data_ptr [i]) ;
/*          strcpy (NFFglobal.acl, data_ptr[i]);  
            FIg_set_text (NFFglobal.forms[MAIN_LABEL],
                ACL_FIELD, data_ptr[column]);
 */
          }
        else if ((strcmp (attr_ptr[offset + name_offset], "n_workflowno")) == 0)
          {
            _NFIdebug ((fname, "workflow = <%s>\n", data_ptr[i]));
	    *workflowno = atol (data_ptr [i]) ;
	    list_no = atol (attr_ptr [offset + valueno_offset]) ;
	    _NFIdebug ((fname, "reset workflow to <%d>\n", list_no)) ;
	    if ((status = MEMreset_buffer_no
		 (ptr->value_list, list_no)) != MEM_S_SUCCESS)
	      {
		_NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
		ERRload_struct
		  (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MEM);
	      }

	    _NFIdebug ((fname, "value list has %d rows\n", ptr->value_list->rows)) ;
/****** mms - reset_buffer_no does a build_array to the buffer no ****
	    if ((status = MEMbuild_array
		 (ptr->value_list)) != MEM_S_SUCCESS)
	      {
		_NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
		ERRload_struct
		  (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MEM);
	      }
**************************************************/

	    value_ptr = (char **) ptr->value_list->data_ptr ;

	    for (z=0; z<ptr->value_list->rows;z++)
	      {
		offset_z = z*(ptr->value_list->columns) ;
		_NFIdebug ((fname, "Comparing <%s> with <%s>\n",
			    data_ptr[i], value_ptr[offset_z])) ;
		
		if (strcmp (data_ptr[i], value_ptr[offset_z]) == 0)
		  {
		    strcpy (workflow, value_ptr[offset_z+1]) ;
		    _NFIdebug ((fname, "workflow is <%s>\n", workflow)) ;
		    break ;
		  }
	      }

	    /* for all match the workflow no */
/*            _NFFmain_set_wf (data_ptr[column]);*/
          }

        /*  See if this attribute can be written to  */

        if ((strcmp (attr_ptr[offset + write_offset], "Y")) != 0)
          {
            /*  Don't validate  */
            continue;
          }

	/** must add null validation here (later) **/
      }

    /*  Scan for any single tics (') in the data buffer  */

    if ((status = NFMtic_it (ptr->data_list)) != NFM_S_SUCCESS)
      {
        _NFIdebug ((fname, "NFMtic_it = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


/********** utility routines ****************/
long _NFFcopy_acl_attributes_field (form, row_no, ptr)
  Form         form;
  int          row_no;
  NFFadd_ptr   ptr;
  {
    auto    int     status;
    auto    int     row;
    auto    int     position;
    auto    int     selected;
    auto    int     label = CP_ACL_INFO_MCF ;
    static  char    *fname = "_NFFcopy_acl_attributes_field";
    long _NFFadd_set_lower_half_for_copy_acl () ;

    _NFIdebug ((fname, "row_no = %d\n", row_no));

    /*  See if the checkbox was selected  */

    if (row_no == -1)
      {
        /*  Find out which row was selected  */

        if ((status = FIfld_get_active_row
            (form, label, &row, &position)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Find out if the row is selected or not  */

        if ((status = FImcf_get_select
            (form, label, row, &selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_get_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_get_select", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (selected == FALSE)
          {
            _NFIdebug ((fname, "Row was unselected with the checkbox\n"));

            if ((status = (int) _NFFadd_disable_lower_half
                (form, ptr)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                    "_NFFadd_disable_lower_half = <0x%.8x>\n", status));
                _NFIdebug ((fname, "returning FAILURE\n"));
                return (status);
              }

            _NFIdebug ((fname, " returning SUCCESS\n"));
            return (NFI_S_SUCCESS);
          }
      }
    else if (row_no < 0)
      {
        _NFIdebug ((fname, "rows or columns are scrolling\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }
    else
      {
        row = row_no;

        /*  Select this entire row  */

        if ((status = FImcf_set_select
            (form, label, row, TRUE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    ptr->active_attribute = row_no ;

    _NFIdebug ((fname, "row active in main MCF is %d\n", ptr->active_attribute));

    if ((status = _NFFadd_set_lower_half_for_copy_acl
        (form, ptr, row)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadd_set_lower_half_for_copy_acl = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

long _NFFblank_entry (form, ptr)
  Form         form;
  NFFadd_ptr   ptr;
  {
    auto    int     status;
    auto    int     row;
    auto    int     position;
    auto    int     label = CP_ACL_INFO_MCF ;
    char            **data_ptr, **value_ptr ;
    short           type_offset, new_number_offset ;    
    long            row_no ;
    static  char    *fname = "_NFFblank_entry" ;
    
    _NFIdebug ((fname, "ENTER\n")) ;

    /*  Find out which row was selected  */
    
    if ((status = FIfld_get_active_row
	 (form, label, &row, &position)) != FI_SUCCESS)
      {
	_NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
	ERRload_struct
	  (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
	_NFIdebug ((fname, "returning FAILURE\n"));
	return (NFI_E_FORM);
      }
    

    _NFIdebug ((fname, "Setting <BLANK> in FORM\n")) ;
    _NFIdebug ((fname, " in row %d col %d\n", row, 2));

/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif
    if ((status = FIfld_set_text (form, label,
				  row, 2, "", FALSE)) != FI_SUCCESS)
      {
	_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
      }

    data_ptr = (char **) (ptr->attr_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "type", &type_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "new_number", &new_number_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, "Writing <BLANK> in buffer row <%d> col <%d>\n",
		ptr->active_attribute+1, new_number_offset+1)) ;

    if ((status = MEMwrite_data (ptr->attr_list, "", 
        ptr->active_attribute + 1, new_number_offset+1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }


    row_no = row * (ptr->attr_list)->columns;
    _NFIdebug ((fname, "type offset <%s>\n", data_ptr[row_no+type_offset])) ;
    if (strcmp (data_ptr[row_no + type_offset], "class") == 0)
      {
	_NFIdebug ((fname, "FIg_display class button\n")) ;
	status = FIg_set_text (form, CP_ACL_BLANK_ENTRY, 
			       "Clear\nCopied\nClass") ;
	if (status != FI_SUCCESS)
	{
	  _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
	  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
	  _NFIdebug ((fname, " returning FAILURE\n"));
	  return (NFI_E_FORM);
	}
      }
    else
      {
	_NFIdebug ((fname, "FIg_display state button\n")) ;
	status = FIg_set_text (form, CP_ACL_BLANK_ENTRY, 
			       "Clear\nCopied\nState") ;
	if (status != FI_SUCCESS)
	{
	  _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
	  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
	  _NFIdebug ((fname, " returning FAILURE\n"));
	  return (NFI_E_FORM);
	}
      }

    status = FIg_display (form, CP_ACL_BLANK_ENTRY) ;
    if (status != FI_SUCCESS)
      {
	_NFIdebug ((fname, "FIg_display = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }



long _NFFcopy_acl_validate_field (form, row, ptr)
  Form          form;
  int           row;
  NFFadd_ptr    ptr;
  {
    int     row_no;
    int     list_no;
    int     position;
    int     selected;
    long    status;
    short    new_number_offset ;
    char    **data_ptr;
    short   offset;
    MEMptr  buffer = NULL;

    int     label = CP_ACL_VALIDATE_MCF;

    static  char *fname = "_NFFcopy_acl_validate_field";

    _NFIdebug ((fname, "row = <%d>\n", row));

    /*  See if the checkbox was selected  */
    /* row of validation list */
    if (row == -1)
      {
        /*  Find out which row was selected  */

        if ((status = (long) FIfld_get_active_row
            (form, label, &row, &position)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_get_active_row = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_row", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        /*  Find out if the row is selected or not  */

        if ((status = (long) FImcf_get_select
            (form, label, row, &selected)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_get_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_get_select", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }

        if (selected == FALSE)
          {
            _NFIdebug ((fname, "Row was unselected with the checkbox\n"));

            ptr->validate_row = -1;

            _NFIdebug ((fname, " returning SUCCESS\n"));
            return (NFI_S_SUCCESS);
          }
      }
    else if (row < 0)
      {
        _NFIdebug ((fname, "rows or columns are scrolling\n"));
        _NFIdebug ((fname, " returning SUCCESS\n"));
        return (NFI_S_SUCCESS);
      }
    else
      {
        /*  Set this entire row to be selected  */

        if ((status = (long) FImcf_set_select
            (form, label, row, TRUE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FImcf_set_select = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_FORM, "%s%d", "FImcf_set_select", status);
            _NFIdebug ((fname, "returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }

    /*  Remember that this row is selected  */

    ptr->validate_row = row;

    /*  For now, put what's in the first column of
        the MCF in the attributes field and in the buffer  */

    buffer = ptr->value_list;
    data_ptr = (char **) (ptr->attr_list)->data_ptr;

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_valueno", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    row_no = ptr->active_attribute * (ptr->attr_list)->columns;
    _NFIdebug ((fname, "row active in MAIN MCF -> %d\n",
		ptr->active_attribute)) ;
    list_no = atoi (data_ptr[row_no + offset]);
    _NFIdebug ((fname, "list_no = <%d> : row_no <%d> : offset <%d>\n", list_no, row_no, offset));

    if (list_no > 0)
      {
        /*  Reset to the values buffer  */

        if ((status = MEMreset_buffer_no
            (buffer, list_no)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
            ERRload_struct
                (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
      }
    else
      {
        /*  There is no value list for this attribute  */

        _NFIdebug ((fname, "There is no value list for this attribute\n"));

        if ((status = _NFFadd_disable_lower_half (form, ptr)) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname,
                "_NFFadd_disable_lower_half = <0x%.8x>\n", status));
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (status);
          }

        ptr->validate_row = -1;

        ERRload_struct (NFI, NFI_E_BUFFER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_BUFFER);
      }

    /*  Put the data (probably the index) in the
        attributes field and in the data_list buffer  */

    /* buffer = value_list */
    data_ptr = (char **) buffer->data_ptr;
/*************
    _NFIdebug ((fname,
        "Setting <%s> in the value field\n", data_ptr[row * buffer->columns]));
    if ((status = (long) FIfld_set_text (form, VALUE_FIELD,
        0, 0, data_ptr[row * buffer->columns], FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }
*********************/
    /*  Write ALL data in the FIRST row (GS 8/13/90)  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "new_number", &new_number_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, "Writing <%s>\n", data_ptr[row * buffer->columns+1]));
    _NFIdebug ((fname, " in row %d, col %d in attr_list\n",
        ptr->active_attribute + 1, new_number_offset+1));

    if ((status = MEMwrite_data (ptr->attr_list,
        data_ptr[row * buffer->columns+1], 
        ptr->active_attribute + 1, new_number_offset+1)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMwrite_data", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_MEM);
      }

    /*  Put the value in the attributes field  */

/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL ) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, CP_ACL_INFO_MCF, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text
        (form, CP_ACL_INFO_MCF, ptr->active_attribute,
        2, data_ptr[row * buffer->columns], TRUE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_FORM);
      }

/*******  Select the next attribute  

    if ((status = _NFFadd_select_next_attribute
        (form, write_or_update, ptr)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname,
            "_NFFadd_select_next_attribute = <0x%.8x>\n", status));
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (status);
      }
***********************************/
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

long _NFFcopy_acl_load_attributes (form, ptr)
  Form          form;
  NFFadd_ptr    ptr;
  {
    int     i ;
    int     fields;
    long    status;
    char    **attr_data;
    char    **data_data;
    short   type_offset, name_offset, offset ;

    int     label = CP_ACL_INFO_MCF ;

    static  char *fname = "_NFFcopy_acl_load_attributes";

    _NFIdebug ((fname, "label = <%d>\n", CP_ACL_INFO_MCF)) ;

    /*  Find the offsets in the buffer  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "type", &type_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "name", &name_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL)
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif

    attr_data = (char **) (ptr->attr_list)->data_ptr;

/*  2 Mar 94. MSSP. The code relating to data_data (third column */
/* has already  been commented. */
/*   data_data = (char **) (ptr->data_list)->data_ptr; */


    fields = (ptr->attr_list)->rows * (ptr->attr_list)->columns;
    for (i = 0; i < (ptr->attr_list)->rows; i++) 
      {
	offset = i*(ptr->attr_list)->columns ;

        /*  Only load in attributes that have read or write permission  */

        /*  Load in the attribute name  */

/*********** first column (type) *******************************************/
	
        _NFIdebug ((fname, "Setting <%s>\n", attr_data[offset+type_offset])) ;
        _NFIdebug ((fname, " in row %d col %d\n", i, 0));

        if ((status = FIfld_set_text
            (form, label, i, 0, attr_data[offset+type_offset], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

/*********** second column ************************************/
        _NFIdebug ((fname, "Setting <%s>\n", attr_data[offset + name_offset]));
        _NFIdebug ((fname, " in row %d col %d\n", i, 1));

        if ((status = FIfld_set_text (form, label, i,
            1, attr_data[offset + name_offset], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }

/************** third column **********************************/
/*******
        _NFIdebug ((fname, "Setting <%s>\n", data_data[row]));
        _NFIdebug ((fname, " in row %d col %d\n", (ptr->rows)[row], 2));

        if ((status = FIfld_set_text (form, label,
            (ptr->rows)[row], 2, data_data[row], FALSE)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
**********************/
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

long _NFFadd_set_lower_half_for_copy_acl (form, ptr, row)
  Form          form;
  NFFadd_ptr    ptr;
  long          row;
  {
    auto    int     row_no;
    auto    int     list_no, button_list, val_list ;
    auto    char    format[5];
    auto    char    **format_ptr;
    auto    char    **data_ptr;
    auto    long    status;
    auto    short   offset, type_offset ;
    static  char    *fname = "_NFFadd_set_lower_half_for_copy";

    /*  Put any existing value in the value field  */

/* 2 Mar 94. MSSP. Commented the assignment to data_ptr as  */
/* it is being assigned with the attribute list */
/*    data_ptr = (char **) (ptr->data_list)->data_ptr; */

    /*  Find the datatype for data validation - Glenn 4/1/92  */

    format_ptr = (char **) (ptr->attr_list)->format_ptr;

    strcpy (format,"%s");

    button_list = -1; val_list = -1;


    data_ptr = (char **) (ptr->attr_list)->data_ptr;

    row_no = row * (ptr->attr_list)->columns;

    /*  Find the value list for this attribute  */

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "n_valueno", &offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFfind_column_offset
        (ptr->attr_list, "type", &type_offset)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    list_no = atoi (data_ptr[row_no + offset]);

    /* put title in blank button - find out if state of class */

    if (strcmp (data_ptr[row_no + type_offset], "class") == 0)
      {
	status = FIg_erase (form, CP_ACL_TEXT_VAL_S) ;
	if (status != FI_SUCCESS)
	{
	  _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
	  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
	  _NFIdebug ((fname, " returning FAILURE\n"));
	  return (NFI_E_FORM);
	}
	
	status = FIg_display (form, CP_ACL_TEXT_VAL_C) ;
	if (status != FI_SUCCESS)
	  {
	    _NFIdebug ((fname, "FIg_delete = <%d>\n", status));
	    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_FORM);
	  }

	status = FIg_set_text (form, CP_ACL_BLANK_ENTRY, 
			       "Clear\nCopied\nClass") ;
	if (status != FI_SUCCESS)
	{
	  _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
	  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
	  _NFIdebug ((fname, " returning FAILURE\n"));
	  return (NFI_E_FORM);
	}
	
      }
    else
      {
	status = FIg_erase (form, CP_ACL_TEXT_VAL_C) ;
	if (status != FI_SUCCESS)
	{
	  _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
	  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
	  _NFIdebug ((fname, " returning FAILURE\n"));
	  return (NFI_E_FORM);
	}
	
	status = FIg_display (form, CP_ACL_TEXT_VAL_S) ;
	if (status != FI_SUCCESS)
	  {
	    _NFIdebug ((fname, "FIg_delete = <%d>\n", status));
	    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_FORM);
	  }
	status = FIg_set_text (form, CP_ACL_BLANK_ENTRY, 
			       "Clear\nCopied\nState") ;
	if (status != FI_SUCCESS)
	{
	  _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
	  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
	  _NFIdebug ((fname, " returning FAILURE\n"));
	  return (NFI_E_FORM);
	}
      }

    status = FIg_display (form, CP_ACL_BLANK_ENTRY) ;
    if (status != FI_SUCCESS)
      {
	_NFIdebug ((fname, "FIg_display = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "list_no = <%d> : row_no <%d> : offset <%d>\n",
		list_no, row_no, offset));

    if (list_no > 0)
      {
        /*  Reset to the values buffer  */

        if ((status = MEMreset_buffer_no
            (ptr->value_list, list_no)) != MEM_S_SUCCESS)
          {
            _NFIdebug ((fname, "MEMreset_buffer_no = <0x%.8x>\n", status));
            ERRload_struct
	      (NFI, NFI_E_MEM, "%s%x", "MEMreset_buffer_no", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MEM);
          }
	
        data_ptr = (char **) (ptr->value_list)->data_ptr;
      }

/*  Create the validate mcf to reflect the list  */
    
    if ((status = (long) FIg_delete (form, CP_ACL_VALIDATE_MCF)) != FI_SUCCESS)
      {
	if (status != FI_NO_SUCH_GADGET)
	  {
	    _NFIdebug ((fname, "FIg_delete = <%d>\n", status));
	    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
	    _NFIdebug ((fname, "returning FAILURE\n"));
	    return (NFI_E_FORM);
	  }
      }
    
    if ((status = _NFFadd_create_mcf
	 (form, CP_ACL_VALIDATE_MCF, ptr->value_list)) != NFI_S_SUCCESS)
      {
	_NFIdebug ((fname, "_NFFadd_create_mcf = <0x%.8x>\n", status));
	_NFIdebug ((fname, "returning FAILURE\n"));
	return (status);
      }
    
    if ((status = FImcf_set_num_vis_cols
            (form, CP_ACL_VALIDATE_MCF, 1)) != FI_SUCCESS)
      {
	_NFIdebug ((fname, "_NFmcf_set_num_vis_cols = <0x%.8x>\n", status));
	_NFIdebug ((fname, "returning FAILURE\n"));
	return (status);
      }

    /*  Load the list into the mcf  */
    
    if ((status = _NFFcopy_acl_load_mcf
            (form, CP_ACL_VALIDATE_MCF, ptr->value_list)) != NFI_S_SUCCESS)
      {
	_NFIdebug ((fname, "_NFFadd_load_mcf = <0x%.8x>\n", status));
	_NFIdebug ((fname, "returning FAILURE\n"));
	return (status);
      }
    
    /*  Make the first row the active row  */
    
    if ((status = (long) FIfld_set_active_row
	 (form, CP_ACL_VALIDATE_MCF, 0, 0)) != FI_SUCCESS)
      {
	_NFIdebug ((fname, "FIfld_set_active_row = <%d>\n", status));
	ERRload_struct
	  (NFI, NFI_E_FORM, "%s%d", "FIfld_set_active_row", status);
	_NFIdebug ((fname, "returning FAILURE\n"));
	return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

long _NFFcopy_acl_load_mcf (form, label, value_list)
  Form      form;
  int       label;
  MEMptr    value_list;
  {
    auto    int     status;
    auto    int     i, j, k;
    auto    int     num_rows, vis_rows, attr_mask;
    auto    char    **data_ptr;
    static  char    *fname = "_NFFcopy_acl_load_mcf";

    _NFIdebug ((fname, "label = <%d>\n", label));

    data_ptr = (char **) value_list->data_ptr;

    /*  Set the number of rows to 0 to clear out the field  */

    _NFIdebug ((fname, "Setting number of rows to 0\n"));

    if ((status = FIfld_set_num_rows (form, label, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the values in the mcf  */
/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL) 
    /* work around change - to set font for SCO - SSRS 4 Feb 94 */
    FIg_set_font( form, label, "7x13bold", 15 );
#endif

    for (i = 0, k = 0; i < value_list->rows; ++i)
      {
        for (j = 0; j < value_list->columns; ++j)
          {
            _NFIdebug ((fname, "Setting <%s>\n", data_ptr[k]));
            _NFIdebug ((fname, " in row %d, col %d in the mcf\n", i, j));

            if ((status = FIfld_set_text
                (form, label, i, j, data_ptr[k], FALSE)) != FI_SUCCESS)
              {
                _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
                ERRload_struct
                    (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
                _NFIdebug ((fname, " returning FAILURE\n"));
                return (NFI_E_FORM);
              }

            ++k;
          }
      }

    /*  Enable the scroll bar, if necessary  */

    FIfld_get_num_rows (form, label, &num_rows);
    FIfld_get_num_vis_rows (form, label, &vis_rows);
    FImcf_get_attr (form, label, &attr_mask);
    if (num_rows > vis_rows)
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

    /*  Center the mcf and text on the form  */

    if ((status = _NFFcenter_gadget
	 (form, CP_ACL_VALIDATE_MCF)) != NFI_S_SUCCESS)
      {
	_NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
	_NFIdebug ((fname, "returning FAILURE\n"));
	return (status);
      }

    if ((status = (long) FIg_display (form, CP_ACL_VALIDATE_MCF)) != FI_SUCCESS)
      {
	_NFIdebug ((fname, "FIg_display = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
	_NFIdebug ((fname, "returning FAILURE\n"));
	return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

/* mms - aug 25 - forms has a problem it will not erase the previous text */
long _NFFcreate_text_dyn (form, label, x, y, title)
     Form form ;
     int  *label ;
     int x,y ;
     char *title ;
{
  char *fname = "_NFFcreate_text_dyn" ;
  long status ;
  struct  standard_st std_var ;

  _NFIdebug ((fname, "label <%d> : x <%d>: y <%d>: title <%s>\n",
	      *label, x,y,title)) ;

  if (*label != -1)
    {
      _NFIdebug ((fname, "Erasing and deleting label <%d>\n", *label)) ;
      /* erase gadget */
      status = FIg_erase (form, *label) ;
      if (status != FI_SUCCESS)
	{
	  _NFIdebug ((fname, "FIg_erase = <%d>\n", status));
	  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
	  _NFIdebug ((fname, " returning FAILURE\n"));
	  return (NFI_E_FORM);
	}
      /* erase delete */
      status = FIg_delete (form, *label) ;
      if (status != FI_SUCCESS)
	{
	  _NFIdebug ((fname, "FIg_delete = <%d>\n", status));
	  ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
	  _NFIdebug ((fname, " returning FAILURE\n"));
	  return (NFI_E_FORM);
	}
    }

/* get next available label */
    if ((status = (long) FIf_get_next_label
        (form, label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_get_next_label = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_next_label", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

  /* create new gadget */
  _NFIdebug ((fname, "Creating label <%d>\n", *label)) ;
    if ((status = (long) FIg_new
        (form, FI_TEXT, *label)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
/*
 *  Set up the standard variables structure with the needed
 *  values and call FIg_set_standard_variables.
 */

  std_var.xlo = x;
  std_var.ylo = y;
  std_var.xhi = x;
  std_var.yhi = y;
  std_var.bodysize = 24;
  std_var.text = (char *) malloc (strlen(title)+1) ;
  if (std_var.text == NULL)
    {
      _NFIdebug ((fname, "Malloc failed\n")) ;
      ERRload_struct (NFI, NFI_E_MALLOC, "", "") ;
      return (NFI_E_MALLOC) ;
    }
  strcpy (std_var.text, title) ;
  std_var.fontname = (char *) malloc (strlen ("swiss742b")+1) ;
  if (std_var.fontname == NULL)
    {
      _NFIdebug ((fname, "Malloc failed\n")) ;
      ERRload_struct (NFI, NFI_E_MALLOC, "", "") ;
      return (NFI_E_MALLOC) ;
    }
  /* fonts SSRS 28 Jan 94 */
/* Intel Solaris Port -IGI CN 31/5/95   */ 
#if defined(OS_SCO_UNIX)|| defined(OS_INTELSOL) 
  strcpy (std_var.fontname, "7x13bold");
#else
  strcpy (std_var.fontname, "swiss742b");
#endif
  std_var.on_color = FI_BLACK;
  std_var.off_color = FI_BLACK;

  status = FIg_set_standard_variables( form, *label,
                                      &std_var );
  if (status != FI_SUCCESS)
    {
      _NFIdebug ((fname, "FIg_set_standard_variables = <%d>\n", status));
      ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_standard_variables", status);
      _NFIdebug ((fname, " returning FAILURE\n"));
      return (NFI_E_FORM);
    }

    if ((status = (long) FIg_display (form, *label)) != FI_SUCCESS)
      {
	_NFIdebug ((fname, "FIg_display = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
	_NFIdebug ((fname, "returning FAILURE\n"));
	return (NFI_E_FORM);
      }
  
  return (NFI_S_SUCCESS) ;
}




