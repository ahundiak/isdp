
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h" 
#include "NFFsignoff.h"

/*************************************************************************
 *                                                                       *
 *  Function : NFFsignoff_on_item                                        * 
 *                                                                       *
 *  The purpose of these functions is to allow a user to signoff on an   *
 *  item using the I/Forms utilities.  The information about the item    *
 *  will be extracted from the global structure NFFglobal.               *
 *                                                                       *
 *  Form          : NFsignoff                                            *
 *  Gadget labels : FI_ACCEPT         1   ( set by forms/selectable )    *
 *                : FI_CANCEL         4   ( set by forms/selectable )    *
 *                : FI_HELP           6   ( set by forms/selectable )    *
 *                : OVERRIDE_BUTTON  12   ( selectable if override perm. *
 *                : TITLE1           14   ( non selectable )             *
 *                : TITLE2           15   ( non selectable/has item info)*
 *                : REASON_FIELD     26   ( selectable )                 *
 *                : REASON_TEXT      17   ( non selectable )             *
 *                                                                       *
 *************************************************************************/ 
 

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFsignoff_on_item ()
  {
    long    status;
    int     offset = 0;
    int     length = 0;
    char    n_read[8];
    char    n_write[8];
    char    attr_name[40]; 
    char    type[40];
    char    s[NFF_MAX_MESSAGE];

    NFFsignoff    signoff;

    static  char *fname = "NFFsignoff_on_item";

    _NFIdebug ((fname, "catalog   = <%s>\n", NFFglobal.catalog));
    _NFIdebug ((fname, "item_name = <%s>\n", NFFglobal.item));
    _NFIdebug ((fname, "revision  = <%s>\n", NFFglobal.revision));

    if (strcmp (NFFglobal.catalog, "") == 0)
     {
        ERRload_struct (NFI, NFI_E_NO_CATALOG, NULL); 
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NO_CATALOG);
     }

    if (strcmp (NFFglobal.item, "") == 0)
     {
        ERRload_struct (NFI, NFI_E_NO_ITEM, NULL); 
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_NO_CATALOG);
     }

    /*  Initialize the signoff structure  */

    if ((signoff = (NFFsignoff) malloc
        (sizeof (struct NFFsignoff_st))) == NULL)
     {
        _NFIdebug ((fname, "malloc failed;  size = <%d>\n",  
                           sizeof (struct NFFsignoff_st)));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", sizeof (struct NFFsignoff_st));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MALLOC);
     }

    signoff->type = 0;
    signoff->done = FALSE;
    signoff->override_depressed = FALSE;
    signoff->reason = NULL;
    signoff->length = 0;
    signoff->r_offset = -1;
    signoff->s_offset = -1;
    signoff->attr_list = NULL;
    signoff->data_list = NULL;
    signoff->value_list = NULL;

    /*  Put up a message  */

    NFFform_message (CURRENT_LABEL, NFI_I_RETRIEVE, NULL); 

    /*  Get the database information  */

    _NFIdebug ((fname, "calling NFMRquery_signoff_attributes ...\n"));
    status = NFMRquery_signoff_attributes ((long) 0,
                            &(signoff->attr_list), &(signoff->data_list),
                            &(signoff->value_list));
    if (status != NFM_S_SUCCESS)
     {
        _NFIdebug ((fname, "NFMRquery_signoff_attributes = <0x%.8x>\n",
                           status));
        NFFerase_message ();
        NFFfree_signoff (NULL, signoff);
        return (status);
     }
    _NFIdebug ((fname, "returned from NFMRquery_signoff_attributes\n"));

    /*  Prepare the buffers for reading  */

    if ((status = MEMbuild_array (signoff->attr_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x%d>\n", status));
        NFFerase_message ();
        NFFfree_signoff (NULL, signoff);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
      }

    if ((status = MEMbuild_array (signoff->data_list)) != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_signoff (NULL, signoff);
        _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_MEM));
        return (NFI_E_MEM);
      }

    if (_NFMdebug_st.NFIdebug_on)
      {
        MEMprint_buffer ("attr_list", signoff->attr_list,
            _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("data_list", signoff->data_list,
            _NFMdebug_st.NFIdebug_file);
        MEMprint_buffer ("value_list", signoff->value_list,
            _NFMdebug_st.NFIdebug_file);
      }

    /*  Load in the Signoff form  */

    status = (long) FIf_new (SIGNOFF_ITEM_LABEL, SIGNOFF_FORM, _NFFnotify, 
                                 &(NFFglobal.current_form));
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        NFFerase_message ();
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        NFFfree_signoff (NULL, signoff);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /* Set the title of the form */

    if ((status = (long) UMSGetByNum
        (s, NFT_P_SIGNOFF_ON_ITEM, NULL)) != UMS_S_SUCCESS) 
     {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (s, "Signoff on");
     }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE1, s)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFerase_message ();
        NFFfree_signoff (&NFFglobal.current_form, signoff);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /*  Set the item information on the form  */

    if ((status = (long) UMSGetByNum (s, NFI_P_ITEM_REV, "%s%s",
                        NFFglobal.item, NFFglobal.revision)) != UMS_S_SUCCESS) 
     {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting item info\n"));
        sprintf (s, "Item \"%s\" Revision \"%s\" ?",
                 NFFglobal.item, NFFglobal.revision);
     }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, TITLE2, s)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        NFFerase_message ();
        NFFfree_signoff (&NFFglobal.current_form, signoff);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    /* get the n_reason attribute information */

    strcpy (attr_name, "n_reason");
    status = _NFFget_attr_info (signoff->attr_list, attr_name, &offset, 
                                n_read, n_write, type, &length); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFget_attr_info = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_signoff (&NFFglobal.current_form, signoff);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    signoff->r_offset = offset;  
    signoff->length = length;  

    /* get the n_signoff attribute information */

    strcpy (attr_name, "n_signoff");
    status = _NFFget_attr_info (signoff->attr_list, attr_name, &offset, 
                                n_read, n_write, type, &length); 
    if (status != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFget_attr_info = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_signoff (&NFFglobal.current_form, signoff);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }
    signoff->s_offset = offset;  


    /*  Find out if the user can override or not  */
    /*  The data_list column n_signoff will have a "Y" in it if a
        user has override permission.                               */

    if (strcmp (n_write, "Y") != 0)
     {
        /*  Disable the OVERRIDE button  */

        status = (long) FIg_disable (NFFglobal.current_form, OVERRIDE_BUTTON);
        if (status != FI_SUCCESS)
         {
           _NFIdebug ((fname, "FIg_disable = <%d>\n", status));
           NFFerase_message ();
           NFFfree_signoff (&NFFglobal.current_form, signoff);
           ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_disable", status);
           _NFIdebug ((fname, " returning FAILURE\n"));
           return (status);
         }
     }

    /* The n_signoff field will need to be cleared out to "" because
       it will be used to send the override value to the server. 
       If the user has override permision and chooses to override
       the assigned value will be put in according to the gadget state. */

    status = MEMwrite_data (signoff->data_list, "", 1,  signoff->s_offset + 1);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        NFFerase_message ();
        NFFfree_signoff (&NFFglobal.current_form, signoff);
        ERRload_struct (NFI, NFI_E_MEM, "%s%d", "MEMwrite_data", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MEM);
     }

    FIfld_set_max_num_chars (NFFglobal.current_form, REASON_FIELD, 0, 40); 

    /*  Store a pointer to the data in the form  */

    if ((status = (long) FIf_set_user_pointer
        (NFFglobal.current_form, (char *) signoff)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_set_user_pointer = <%d>\n", status));
        NFFerase_message ();
        NFFfree_signoff (&NFFglobal.current_form, signoff);
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

    if ((status = _NFFcenter_form (NFFglobal.current_form, -1,
                                   Y_FORM_POS)) != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname,"_NFFcenter_form = <0x%.8x>\n",status));
        NFFerase_message ();
        NFFfree_signoff (&NFFglobal.current_form, signoff);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

/*
    if ((status = _NFFadjust_signoff_form
        (NFFglobal.current_form)) != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname,"_NFFadjust_signoff_form = <0x%.8x>\n",status));
        NFFerase_message ();
        NFFfree_signoff (&NFFglobal.current_form, signoff);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }
*/

    /*  Display the Signoff form  */

    status = (long) FIf_display (NFFglobal.current_form);
    if (status != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_display = <%d>\n", status));
        NFFfree_signoff (&NFFglobal.current_form, signoff);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_display", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFsignoff_on_item_notify (g_label, value, form)
  int       g_label;
  int       value; 
  Form      *form;
  {
    long    status = NFI_S_SUCCESS;

    NFFsignoff    signoff;

    static  char *command = NFI_M_SIGNOFF_ITEM;
    static  char *fname = "_NFFsignoff_on_item_notify";

    _NFIdebug ((fname, "g_label = %d\n", g_label));

    /*  Pull out the pointer to the signoff buffer  */

    FIf_get_user_pointer (*form, (char *) &signoff);

    /*  Clear out the error message strip  */

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

            /*  Set the global command status  */

            ERRload_struct (NFI, NFI_W_COMMAND_CANCELLED, NULL);
            NFFglobal.status = NFI_W_COMMAND_CANCELLED;

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname,"NFFset_to_state = <0x%.8x>\n", status));

            /* Close all allocated buffers */
                        
            NFFfree_signoff (form, signoff);

        break;

        case FI_ACCEPT:

            /*  Put up a message  */

            NFFform_message (CURRENT_LABEL, NFI_I_SIGNOFF, NULL);
 
            if (_NFMdebug_st.NFIdebug_on)
              {
                MEMprint_buffer ("attr_list", signoff->attr_list,
                                 _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("data_list", signoff->data_list,
                                 _NFMdebug_st.NFIdebug_file);
                MEMprint_buffer ("value_list",signoff->value_list,
                                 _NFMdebug_st.NFIdebug_file);
              }
                
            /*  Call NFMR to signoff on the item  */

            _NFIdebug ((fname, "calling NFMRsignoff ...\n"));
            status = NFMRsignoff ((long) 0,
                                  signoff->attr_list, signoff->data_list);
            _NFIdebug ((fname, "returned from NFMRsignoff\n"));

            /*  Erase the message  */

            NFFerase_message ();
            /* FIf_display (*form); */

            /*  Save the return status  */

            NFFglobal.status = status;

            if (status != NFM_S_SUCCESS)
                _NFIdebug ((fname,"NFMRsignoff = <0x%.8x>\n",
                                           status));

            /*  Set the next state  */

            if ((status = NFFset_to_state ()) != NFI_S_SUCCESS)
                _NFIdebug ((fname,"NFFset_to_state = <0x%.8x>\n", status));

            NFFfree_signoff (form, signoff);

        break;

        case OVERRIDE_BUTTON:

            status = _NFFsignoff_override_button (g_label, value, signoff);
            if (status != NFI_S_SUCCESS)
                _NFIdebug ((fname,
                    "NFFsignoff_override_button = <0x%.8x>\n", status));
            break;

        case REASON_FIELD:

            status = _NFFsignoff_reason_field (*form, g_label, signoff);
            if (status != NFI_S_SUCCESS)
                _NFIdebug ((fname, "NFFsignoff_reason_field = <0x%.8x>\n",
                            status));

            break;
      }

    _NFIdebug ((fname, " returning ...\n\n"));
    return (status);
  }


long _NFFsignoff_override_button (label, state, signoff)
  int           label;
  int           state;
  NFFsignoff    signoff;
  {
    int     status;
    char    override_str[8];

    static  char *fname = "_NFFsignoff_override_button";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Save the state  */

    signoff->override_depressed = (short) state;

    if (signoff->override_depressed)   /* 1 or 0 */
       strcpy (override_str, "Y");     /* override button pushed in */
    else
       strcpy (override_str, "");      /* override button popped out */ 

    /*  Write the override_str into the data_list n_signoff field.  */

    status = MEMwrite_data (signoff->data_list, override_str, 1,
                                signoff->s_offset + 1);
    if (status != MEM_S_SUCCESS)
      {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
                ERRload_struct (NFI, NFI_E_MEM, "%s%d", "MEMwrite_data",
                                status);
        return (NFI_E_MEM);
      }

    _NFIdebug ((fname, " returning ...\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFsignoff_reason_field (form, label, signoff)
  Form          form;
  int           label;
  NFFsignoff    signoff;
  {
    int     length;
    int     status;
    int     selected;
    int     r_pos;

    static  char *fname = "_NFFsignoff_reason_field";

    _NFIdebug ((fname, "label = <%d>\n", label));

    /*  Get the length of the string  */

    if ((status = FIfld_get_text_length
        (form, label, 0, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d",  
                        "FIfld_get_text_length", status);
        return (NFI_E_FORM);
      }

    _NFIdebug ((fname, "length = <%d>\n", length));

    if (length <= 0)
     {
        if (length < 0)
         {
            _NFIdebug ((fname, "invalid length\n"));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "Invalid length", length);
            return (NFI_E_FORM);
         } 
        _NFIdebug ((fname, "length = 0 : No text given.\n"));
        return (NFI_S_SUCCESS);
     }

    /*  Allocate space for the string  */

    if (signoff->reason) free (signoff->reason);
    signoff->reason = NULL;

    if ((signoff->reason = (char *) malloc (length)) == NULL)
     {
        _NFIdebug ((fname, "malloc failed\n"));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        return (NFI_E_MALLOC);
     }

    /*  Get the string from the field  */

    if ((status = FIfld_get_text (form, label, 0, 0, length,
                            signoff->reason, &selected, &r_pos)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIfld_get_text = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        if (signoff->reason) free (signoff->reason);
        signoff->reason = NULL;
        return (NFI_E_FORM);
     }


    _NFIdebug ((fname, "signoff reason = <%s>\n", signoff->reason));
          
    /*  Write the reason field into the data_list  */

    status = MEMwrite_data (signoff->data_list, signoff->reason, 1,
                            signoff->r_offset + 1);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMwrite_data = <0x%.8x>\n", status));
        ERRload_struct (NFI, NFI_E_MEM, "%s%d", "MEMwrite_data", status);
        if (signoff->reason) free (signoff->reason);
        signoff->reason = NULL;
        return (NFI_E_MEM);
     }

    _NFIdebug ((fname, " returning ...\n"));
    return (NFI_S_SUCCESS);
  }


#define LEFT_MARGIN   20
#define RIGHT_MARGIN  20

long _NFFadjust_signoff_form (form)
  Form    form;
  {
    int     form_xsize;
    int     form_ysize;
    int     form_width;
    int     form_height;
    int     bezel_width;
    int     bezel_height;
    int     first_line_width;
    int     first_line_height;
    int     item_info_width;
    int     item_info_height;
    long    status;

    static  char *fname = "_NFFadjust_signoff_form";

    if ((status = (long) FIf_get_size
        (form, &form_xsize, &form_ysize)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIf_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    status = (long) FIg_get_size (form, REASON_FIELD, &first_line_width,
                                      &first_line_height);
    if (status != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = (long) FIg_get_size (form,
        TITLE2, &item_info_width, &item_info_height)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    form_height = form_ysize;

    form_width = LEFT_MARGIN + RIGHT_MARGIN;

    if (first_line_width > item_info_width)
        form_width += first_line_width;
    else
        form_width += item_info_width;

    /*  Set the form width based on the longest text line  */

/*
    if ((status = (long) FIf_set_size
        (form, form_width, form_height)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_size = <%d>\n", status));
                ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_set_size",
                                status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
*/

    /*  Set the ERROR_BEZEL width based on the form width  */

    if ((status = (long) FIg_get_size
        (form, ERROR_BEZEL, &bezel_width, &bezel_height)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    if ((status = (long) FIg_set_size (form, ERROR_BEZEL,
        form_width - (LEFT_MARGIN + RIGHT_MARGIN),
                bezel_height)) != FI_SUCCESS)
     {
        _NFIdebug ((fname, "FIg_set_size = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_size", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
     }

    status = _NFFcenter_gadget (form, OVERRIDE_BUTTON);
    if (status  != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    if ((status = _NFFcenter_gadget (form, TITLE1)) != NFI_S_SUCCESS)
     {
        _NFIdebug ((fname, "_NFFcenter_gadget = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
     }

    if ((status = _NFFcenter_gadget (form, TITLE2)) != NFI_S_SUCCESS)
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


void NFFfree_signoff (form, ptr)
  Form          *form;
  NFFsignoff    ptr;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (ptr)
     {
        if (ptr->reason) free (ptr->reason);

        MEMclose (&(ptr->attr_list));
        MEMclose (&(ptr->data_list));
        MEMclose (&(ptr->value_list));

        free (ptr);
     }

    ptr = NULL;

    return;
  }

