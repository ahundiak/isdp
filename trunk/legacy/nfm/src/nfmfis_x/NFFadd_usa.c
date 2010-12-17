
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFaddusa.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

 /*************************************************************************
  *                                                                       *
  *   Function:   NFFadd_util_storage_area                                * 
  *   Date:       Jan 17, 1991                                            *
  *                                                                       *
  *   The add_node command now requires that a utility storage area be    *
  *   added after the node is added.  This function performs this         *
  *   requirement.                                                        *  
  *                                                                       *
  *   After the node is successfully added to the database this function  *
  *   will be called to add a utility storage area for the node.          * 
  *                                                                       *
  *************************************************************************/


long NFFadd_util_storage_area (node)
  char   *node;
  {
    long    status;
    int     i, num_rows = 3;
    char    s[NFF_MAX_MESSAGE];
    char    attr_name[40];
    char    n_read[8];
    char    n_write[8];
    char    n_type[40];

    static  char *fname = "NFFadd_util_storage_area";

    /*  Pointer to the structure  */

    NFFaddusa    ptr;

    /* At this point node should have the node name of the newly added
           node.                                                            */

    _NFIdebug ((fname, "Node Name = <%s>\n", node));

    if (strcmp (node, "") == 0)
     {
        ERRload_struct (NFI, NFI_E_NO_NODE, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NO_NODE);
     }
        

    /*  Initialize the structure  */

    if ((ptr = (NFFaddusa) malloc
        (sizeof (struct NFFaddusa_st))) == NULL)
     {
        _NFIdebug ((fname,
          "malloc failed; size = <%d>\n", sizeof (struct NFFaddusa_st)));
        NFFglobal.status = NFI_E_MALLOC;
        ERRload_struct (NFI, NFI_E_MALLOC,
                        "%d", sizeof (struct NFFaddusa_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
     }

    ptr->type = 0;  
    ptr->done = FALSE;
    strcpy (ptr->st_area, ""); 
    strcpy (ptr->node_num, "");
    strcpy (ptr->user_name, "");
    ptr->u_loc = -1;
    ptr->u_width = 0;
    strcpy (ptr->passwd, "");
    ptr->pswd_loc = -1;
    ptr->pswd_width = 0;
    strcpy (ptr->pathname, "");
    ptr->path_loc = -1;
    ptr->path_width = 0;
    strcpy (ptr->dev_type, "HD");   /* always defaulted to hard disk */
    strcpy (ptr->dev_command, "");
    ptr->d_loc = -1;
    ptr->d_width = 0;
    ptr->attr_list = NULL;
    ptr->data_list = NULL;
    ptr->value_list = NULL;

    /* Put up a message */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL);  

    status = NFMRget_node_no ((long) 0, node, ptr->node_num);
    if (status != NFM_S_SUCCESS) 
     {
        _NFIdebug ((fname, "NFMRget_node_num = <0x%.8x>\n", status));
                NFFerase_message ();
        NFFfree_addusa (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    sprintf (ptr->st_area, "%s-UTIL", ptr->node_num);

    _NFIdebug ((fname, "Storagearea Name = <%s>\n", ptr->st_area));

    /* get the database storage area information*/

    status = NFMRquery_add_st_area_attributes ((long) 0,
                   &(ptr->attr_list), &(ptr->data_list), &(ptr->value_list));
    if (status != NFM_S_SUCCESS) 
     {
        _NFIdebug ((fname,
            "NFMRquery_add_st_area_attributes = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_addusa (NULL, ptr);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }
    _NFIdebug ((fname, "returned from NFMRquery_add_st_area_attributes\n"));

    /* Prepare the buffers for reading */

    status = MEMbuild_array (ptr->attr_list);
    if (status != MEM_S_SUCCESS) 
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_addusa (NULL, ptr);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
     }

     status = MEMbuild_array (ptr->data_list);
     if (status != MEM_S_SUCCESS) 
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_addusa (NULL, ptr);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
      }

     if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list", ptr->attr_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list", ptr->data_list, _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("value_list", ptr->value_list,_NFMdebug_st.NFIdebug_file);
      }

     strcpy (n_read, "");
     strcpy (n_write, "");
     strcpy (n_type, "");

     /* load the attr's location in the buffer and size (if char) */ 

     for (i = 0; i < num_rows; ++i)
      {
        status = NFI_S_SUCCESS;
        switch (i)
          {
            case 0:
                strcpy (attr_name, "n_username");
                status = _NFFget_attr_info (ptr->attr_list, attr_name,
                      &(ptr->u_loc), n_read, n_write, n_type, &(ptr->u_width));
             break;

             case 1:
                strcpy (attr_name, "n_passwd");
                status = _NFFget_attr_info (ptr->attr_list, attr_name,
                                   &(ptr->pswd_loc), n_read, n_write, n_type,
                                   &(ptr->pswd_width));
             break;

             case 2:
                strcpy (attr_name, "n_pathname");
                status = _NFFget_attr_info (ptr->attr_list, attr_name,
                                   &(ptr->path_loc), n_read, n_write, n_type,
                                   &(ptr->path_width));
             break;

             default:
                _NFIdebug ((fname, " *****  Internal Error  ****\n"));
             break;
          } 

       if (status != NFI_S_SUCCESS)
        {
          _NFIdebug ((fname, "_NFFget_attr_info = <0x%.8x>\n", status));
          NFFerase_message ();
          NFFfree_addusa (NULL, ptr);
          NFFglobal.status = status;
          ERRload_struct (NFI, status, NULL);
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (status);
        }
      } 

     /* Write the storage_area, node, dev_type to the data_list */ 

     status = _NFFwrite_sa_data (ptr);
     if (status != NFI_S_SUCCESS)
      {
          _NFIdebug ((fname, "_NFFwrite_sa_data = <0x%.8x>\n", status));
          NFFerase_message ();
          NFFfree_addusa (NULL, ptr);
          NFFglobal.status = status;
          _NFIdebug ((fname, " returning FAILURE\n"));
          return (status);
      }

    /*  Load in the form  */

    if ((status = (long) FIf_new (ADD_UTIL_SA_LABEL, ADD_UTIL_SA_FORM,
        _NFFnotify, &(NFFglobal.add_util_sa_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
        NFFfree_addusa (NULL, ptr);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.add_util_sa_form, (char *) ptr)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        NFFfree_addusa (&NFFglobal.add_util_sa_form, ptr);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIf_set_user_pointer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the storage area in the field  */

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    FIg_set_font( NFFglobal.add_util_sa_form, ST_AREA_FIELD, "7x13bold", 15 );
#endif
    if ((status = (long) FIfld_set_text (NFFglobal.add_util_sa_form,
        ST_AREA_FIELD, 0, 0, ptr->st_area, FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        NFFerase_message ();
        NFFfree_addusa (&NFFglobal.add_util_sa_form, ptr);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the node num in the field  */

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    FIg_set_font(NFFglobal.add_util_sa_form, NODE_NUMBER_FIELD, "7x13bold", 15);
#endif
    if ((status = (long) FIfld_set_text (NFFglobal.add_util_sa_form,
        NODE_NUMBER_FIELD, 0, 0, ptr->node_num, FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        NFFerase_message ();
        NFFfree_addusa (&NFFglobal.add_util_sa_form, ptr);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the device type in the field  */

    /* IGI Intel Solaris Port - CN 31/5/95       */ 
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL) 
    FIg_set_font(NFFglobal.add_util_sa_form, DEVICE_TYPE_FIELD, "7x13bold", 15);
#endif
    if ((status = (long) FIfld_set_text (NFFglobal.add_util_sa_form,
        DEVICE_TYPE_FIELD, 0, 0, ptr->dev_type, FALSE)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
        NFFerase_message ();
        NFFfree_addusa (&NFFglobal.add_util_sa_form, ptr);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the title  */

    status = (long) UMSGetByNum (s, NFI_P_ADD_SA, NULL);  
    if (status != UMS_S_SUCCESS)  
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "Add I/NFM Storage Area");
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.add_util_sa_form, TITLE1, s)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFerase_message ();
        NFFfree_addusa (&NFFglobal.add_util_sa_form, ptr);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /* Erase the message */

     NFFerase_message (); /* Erase "Retrieving data from server" msg */

    /*  Clear out the error message strip  */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    /*  Adjust and Center the form */

    if ((status = _NFFadjust_add_usa_form
        (NFFglobal.add_util_sa_form)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFadjust_add_usa_form = <0x%.8x>\n",
                           status));
        NFFfree_addusa (&NFFglobal.add_util_sa_form, ptr);
        NFFglobal.status = status;
        _NFIdebug ((fname, " returning <0x%.8x>\n", status));
        return (status);
      }

    /*  Display the form  */

    status = (long) FIf_display (NFFglobal.add_util_sa_form);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        NFFfree_addusa (&NFFglobal.add_util_sa_form, ptr);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Position the cursor into the user_name field  */

    status = FIfld_pos_cursor (NFFglobal.add_util_sa_form, USER_NAME_FIELD,
                                   0, 0, 0, 0, 0, 0);
    if (status != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
        NFFfree_addusa (&NFFglobal.add_util_sa_form, ptr);
        NFFglobal.status = NFI_E_FORM;
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_util_sa_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    long       status = NFI_S_SUCCESS;
    int        width = 0;  
    NFFaddusa  ptr;

    static     char *fname = "_NFFadd_util_sa_notify";
    static     char *command = NFI_M_ADD_SA;

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    /*  Pull out the pointer to all of the buffers  */

    if ((status = (long) FIf_get_user_pointer (*form,
                                               (char *) &ptr)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_get_user_pointer = <%d>\n", status));
        ERRload_struct  
            (NFI, NFI_E_FORM, "%s%d", "FIf_get_user_pointer", status);
        return (NFI_E_FORM);
     }

    /*  Clear out the error message strip  */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

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

           NFFglobal.status = NFI_W_COMMAND_CANCELLED;

           /*  Close all allocated buffers and delete the form  */

           NFFfree_addusa (form, ptr);

         break;


        case FI_ACCEPT:

            /*  Make sure the user keyed in all values  */

            if ((status = _NFFadd_usa_validate_accept (ptr)) != NFI_S_SUCCESS)
              {
                _NFIdebug ((fname,
                          "_NFFadd_usa_validate_accept = <0x%.8x>\n", status));
                FIg_reset (*form, FI_ACCEPT);
                break;
              }
            ptr->done = TRUE;

            /* Put up a message */
           
            NFFform_message (CURRENT_LABEL, NFI_I_ADD_SA, NULL); 

            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("attr_list", ptr->attr_list,
                                 _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("data_list", ptr->data_list,
                                 _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("value_list", ptr->value_list,
                                 _NFMdebug_st.NFIdebug_file);
              }

             /* call NFMR to add the storage area */

            _NFIdebug ((fname, "calling NFMRadd_storage_area ...\n"));
            status = NFMRadd_storage_area ((long) 0, 
                                           ptr->attr_list, ptr->data_list);
            _NFIdebug ((fname, "returned from NFMRadd_storage_area\n"));

            /* Erase the message */

            NFFerase_message ();

            /* save the return status */

            NFFglobal.status = status;
              
            if (status != NFM_S_SUCCESS)
                _NFIdebug ((fname,"NFMRadd_storage_area = <0x%.8x>\n",
                            status));

            /* copy the storage_area name into the global ptr */

/*
            if ((NFFglobal.status == NFM_S_SUCCESS) &&
                (status == NFI_S_SUCCESS)) 
                strcpy (NFFglobal.st_area, ptr->st_area);
*/

            NFFfree_addusa (form, ptr);

            /* display the storage_area name in the main form */

/*
            if ((NFFglobal.cmd_status == NFM_S_SUCCESS) &&
                (status == NFI_S_SUCCESS)) 
                _NFImain_set_sa (NFFglobal.st_area);
*/

            break;

        case USER_NAME_FIELD:
        case PASSWORD_FIELD:
        case PATHNAME_FIELD:
        case DEV_COMMAND_FIELD:

            /*  Copy the data into the structure  */

            status = _NFFadd_usa_get_text (*form, g_label, &width, ptr);
            if ((status) && (status != NFI_W_TRUNCATING))
                _NFIdebug ((fname,
                                 "_NFFadd_usa_get_text = <0x%.8x>\n", status));

            if (status == NFI_W_TRUNCATING)
              {
                /* send the truncation message to the user. */

                NFFform_message (CURRENT_LABEL, NFI_W_TRUNCATING,"%d", width);

                /* reset the status to NFI_S_SUCCESS */

                status = NFI_S_SUCCESS;
              }

            break;
     }

    _NFIdebug ((fname, " returning <0x%.8x>...\n", status));
    return (status);
  }


long _NFFadd_usa_get_text (form, label, width, ptr)
  Form       form;
  int        label;
  int        *width;
  NFFaddusa  ptr;
  {
    int      status;
    long     w_status = 0;
    int      length;
    int      selected;
    int      loc, pos;
    char     *text = NULL;

    static   char *fname = "_NFFadd_usa_get_text";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if ((status = FIfld_get_text_length
        (form, label, 0, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "length = <%d>\n", length));

    if (length <= 0)
      {
        _NFIdebug ((fname, "invalid length\n"));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "invalid text length", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
      }

    if ((status = FIfld_get_text (form, label,
        0, 0, length, text, &selected, &pos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        if (text) free (text);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text",
                                status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "text = <%s>\n", text));

    if ((status = FIfld_get_active_char
        (form, label, 0, &loc, &pos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_active_char = <%d>\n", status));
        if (text) free (text);
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_active_char",
                         status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "pos = <%d>\n", pos));

    switch (label)
      {
        case USER_NAME_FIELD:

           if (strlen (text) > ptr->u_width)
            {
                text[ptr->u_width] = 0;
                w_status = NFI_W_TRUNCATING;
            } 
           strcpy (ptr->user_name, text);
           *width = ptr->u_width;

          /* write the data to the data_list */

          status = MEMwrite_data (ptr->data_list, ptr->user_name, 1,
                                  ptr->u_loc + 1); 
          if (status != MEM_S_SUCCESS)
           {
              _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
              if (text) free (text);
              _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
              return (NFI_E_MEM);
           }

          if (pos != 0)
           {
               /*  Bump the cursor into the password field  */

               status = FIfld_pos_cursor (form, PASSWORD_FIELD,
                                                           0, 0, 0, 0, 0, 0);
               if (status != FI_SUCCESS)
                {
                   _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
                    if (text) free (text);
                    ERRload_struct (NFI, NFI_E_FORM, "%s%d",
                                    "FIfld_pos_cursor", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                }
           }

        break;

        case PASSWORD_FIELD:

          if (strlen (text) > ptr->pswd_width)
           {
              text[ptr->pswd_width] = 0;
              w_status = NFI_W_TRUNCATING;
           } 
          strcpy (ptr->passwd, text);
          *width = ptr->pswd_width;

          /* write the data to the data_list */

          status = MEMwrite_data (ptr->data_list, ptr->passwd,
                                     1, ptr->pswd_loc + 1); 
          if (status != MEM_S_SUCCESS)
           {
              _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
              if (text) free (text);
              _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
              return (NFI_E_MEM);
           }

          if (pos != 0)
           {
              /*  Bump the cursor into the pathname field  */

              status = FIfld_pos_cursor (form, PATHNAME_FIELD,
                                         0, 0, 0, 0, 0, 0);
              if (status != FI_SUCCESS)
               {
                  _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
                  if (text) free (text);
                  ERRload_struct
                      (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
                  _NFIdebug ((fname, " returning FAILURE\n"));
                  return (NFI_E_FORM);
                }
            }

            break;

        case PATHNAME_FIELD:

            if (strlen (text) > ptr->path_width)
             {
                text[ptr->path_width] = 0;
                w_status = NFI_W_TRUNCATING;
             } 
            strcpy (ptr->pathname, text);
            *width = ptr->path_width;

            /* write the data to the data_list */

            status = MEMwrite_data (ptr->data_list, ptr->pathname,
                                    1, ptr->path_loc + 1); 
            if (status != MEM_S_SUCCESS)
             {
                _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
                if (text) free (text);
                _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
                return (NFI_E_MEM);
             }

            if (pos != 0)
              {
                /*  Bump cursor into the user name field  */

                status = FIfld_pos_cursor (form,  
                      USER_NAME_FIELD, 0, 0, 0, 0, 0, 0);
                if (status != FI_SUCCESS)
                  {
                    _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
                    if (text) free (text);
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                  }
              }

            break;

        case DEV_COMMAND_FIELD:

            if (strlen (text) > ptr->d_width)
             {
                text[ptr->d_width] = 0;
                 w_status = NFI_W_TRUNCATING;
             } 
            strcpy (ptr->dev_command, text);
            *width = ptr->d_width;

            /* write the data to the data_list */

            status = MEMwrite_data (ptr->data_list,ptr->dev_command,
                                    1, ptr->d_loc + 1); 
            if (status != MEM_S_SUCCESS)
             {
                _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
                if (text) free (text);
                _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
                return (NFI_E_MEM);
             }

            if (pos != 0)
             {
                /*  Bump the cursor into the username field  */

                status = FIfld_pos_cursor (form,  
                      USER_NAME_FIELD, 0, 0, 0, 0, 0, 0);
                if (status != FI_SUCCESS)
                 {
                    _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
                    if (text) free (text);
                    ERRload_struct
                        (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
                    _NFIdebug ((fname, " returning FAILURE\n"));
                    return (NFI_E_FORM);
                 }
             }

            break;
      }

    if (text) free (text);

    if (w_status)
     {
       _NFIdebug ((fname, "Succesful : Warning = <0x%.8x>\n", w_status));
       return (w_status);
     }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFadd_usa_validate_accept (ptr)
  NFFaddusa   ptr;
  {
    long   status = NFI_S_SUCCESS;
    short  offset = -1;

    static    char *fname = "_NFFadd_usa_validate_accept";

    if (strcmp (ptr->user_name, "") == 0)
     {
        ERRload_struct (NFI, NFI_I_TEMP_USER, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_TEMP_USER);
     }
/*  Password no longer required  -  jm 1/28/1993 
    else if (strcmp (ptr->passwd, "") == 0)
     {
        ERRload_struct (NFI, NFI_I_TEMP_PASSWD, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_TEMP_PASSWD);
     }
*/
    else if (strcmp (ptr->pathname, "") == 0)
     {
        ERRload_struct (NFI, NFI_I_TEMP_PATHNAME, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_I_TEMP_PATHNAME);
     }

    /* put the storage area type into the data_list */

    status = _NFFfind_column_offset (ptr->data_list, "n_type", &offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     } 

    /* Write a storage area type of "S" (utility) to the data_list */

    status = MEMwrite_data (ptr->data_list, "S", 1, offset + 1); 
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
     } 
      
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFwrite_sa_data (ptr)
    NFFaddusa    ptr;
 {
    long  status;
    short offset = 0; 
        
    static    char *fname = "_NFFwrite_sa_data";

    _NFIdebug ((fname, " entered...\n"));

    /* Get the attribute offset and write it to the data_list. */ 

    status = _NFFfind_column_offset (ptr->data_list, "n_saname", &offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     } 

    status = MEMwrite_data (ptr->data_list, ptr->st_area, 1, offset + 1); 
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
     } 

    status = _NFFfind_column_offset (ptr->data_list, "n_nodeno", &offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     } 

    status = MEMwrite_data (ptr->data_list, ptr->node_num, 1, offset + 1); 
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
     } 

    status = _NFFfind_column_offset (ptr->data_list, "n_devicetype", &offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     } 

    status = MEMwrite_data (ptr->data_list, ptr->dev_type, 1, offset + 1); 
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
     } 

    status = _NFFfind_column_offset (ptr->data_list, "n_nfs", &offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     } 

    status = MEMwrite_data (ptr->data_list, "N", 1, offset + 1); 
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
     } 

    status = _NFFfind_column_offset (ptr->data_list, "n_compress", &offset);
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFfind_column_offset = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     } 

    status = MEMwrite_data (ptr->data_list, "N", 1, offset + 1); 
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
     } 

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
}


void NFFfree_addusa (form, ptr)
  Form      *form;
  NFFaddusa ptr;
{
    if (form != NULL)
    {
       FIf_delete (*form);
       NFFglobal.add_util_sa_form = *form = NULL;
    }

    if (ptr)
     {
        if (ptr->attr_list)
           MEMclose (&(ptr->attr_list));
        if (ptr->data_list)
           MEMclose (&(ptr->data_list));
        if (ptr->value_list)
           MEMclose (&(ptr->value_list));
       free (ptr);
     }
    ptr = NULL;
    return;
}

#define LEFT_MARGIN   20
#define RIGHT_MARGIN  20

long _NFFadjust_add_usa_form (form)
  Form    form;
  {
    long    status;

    static  char *fname = "_NFFadjust_add_usa_form";

    if ((status = _NFFcenter_gadget (form, TITLE1)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFcenter_gadget (form, ERROR_BEZEL)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = _NFFcenter_form (form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFcenter_form = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

