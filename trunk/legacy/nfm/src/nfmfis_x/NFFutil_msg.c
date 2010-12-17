
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFutil_msg.h"

#ifndef NFF_UTIL_MSG_Y
#define NFF_UTIL_MSG_Y  250  /* Y axis to put the form on */
#define NFF_UTIL_MSG_X  150  /* X axis to put the form on */
#endif

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFprocess_utility_message (msg_buffer)
    MEMptr  msg_buffer;
  {
    auto    long              status;
    auto    char              prompt1[NFF_MAX_MESSAGE];
    auto    char              msg1[NFF_MAX_MESSAGE];
    /* auto    char              msg2[NFF_MAX_MESSAGE]; */
            char              **msg_ptr;
            char              *nfmutil = "Nfmutil"; 
    static  char              *fname = "NFFprocess_utility_message";

    _NFIdebug ((fname, "Function entered.\n"));

    /* build the array */

    status = MEMbuild_array (msg_buffer);
    if (status != MEM_S_SUCCESS)
     {
        _NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
        NFFform_message (CURRENT_LABEL, NFI_E_MEM, "%s%x",
                         "MEMbuild_array", status);
        ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
        return (NFI_E_MEM); 
     }

    msg_ptr = (char **) msg_buffer->data_ptr; 
    _NFIdebug ((fname, "msg_ptr[0] = <%s>\n", msg_ptr[0]));
    _NFIdebug ((fname, "msg_ptr[1] = <%s>\n", msg_ptr[1]));
    _NFIdebug ((fname, "msg_ptr[2] = <%s>\n", msg_ptr[2]));

    /*  Get the first message */

    if( strcmp( msg_ptr[2], "DISK_F" ) == 0 )
    {
      status = (long) UMSGetByNum (msg1, NFI_I_EXEC_SCRIPT_FLOPPY, "%s%s%s",
               nfmutil, msg_ptr[0], msg_ptr[1]);
      if( status != UMS_S_SUCCESS )
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting message1\n"));
        sprintf (msg1,
          "Invoke \"%s\" using script \"%s\" on Node \"%s\"",
                 nfmutil, msg_ptr[0],  msg_ptr[1]);
      }
    }
    else 
    {
      status = (long) UMSGetByNum (msg1, NFI_I_EXEC_SCRIPT, "%s%s%s%s",
               nfmutil, msg_ptr[0], msg_ptr[1], msg_ptr[2]);
      if( status != UMS_S_SUCCESS )
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting message1\n"));
        sprintf (msg1,
          "Invoke \"%s\" using script \"%s\" on Node \"%s\" using media label \"%s\"", nfmutil, msg_ptr[0],  msg_ptr[1], msg_ptr[2]);
      }
    }

    /*  Get the second message */

/*
    if ((status = (long) UMSGetByNum (msg2, NFI_I_UTI_NODE_INFO, "%s%s",
                                      msg_ptr[1], msg_ptr[2])) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting message2\n"));
        sprintf (msg2, "Node \"%s\" node_number \"%s\" on",
                 msg_ptr[1], msg_ptr[2]);
      }
*/

    _NFIdebug ((fname, "message1 = <%s>\n", msg1));
    /* _NFIdebug ((fname, "message2 = <%s>\n", msg2)); */

    /*  Load in the utility message form  */

    if ((status = (long) FIf_new (UTILITY_MSG_LABEL, UTILITY_MSG_FORM,
        _NFFnotify, &(NFFglobal.current_form))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_new = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_new", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the title on the form  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFI_P_UTILITY_MSG, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (prompt1, "Utility Message for Offline devices");
      }

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, UTI_MSG_TITLE, prompt1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_flag (NULL, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the first message string on the form  */

    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, UTI_MSG_STRING2, msg1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_flag (NULL, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Put the second message string on the form  */

/*
    if ((status = (long) FIg_set_text
        (NFFglobal.current_form, UTI_MSG_STRING2, msg2)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
        _NFFfree_flag (NULL, &NFFglobal.current_form);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
*/

    /*  Center the form  */

/*
    if ((status = (long) FIf_set_location
        (NFFglobal.current_form, NFF_UTIL_MSG_X, NFF_UTIL_MSG_Y)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIf_set_location = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_set_location", status);
        _NFFfree_flag (NULL, &NFFglobal.current_form);
        _NFIdebug ((fname, " returning <0x%.8x>\n", status));
        return (NFI_E_FORM);
      }
*/

    /*  Display the message form  */

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


long _NFFutility_message_notify (g_label, form)
  int       g_label;
  Form      *form;
  {
    auto    long              status = NFI_S_SUCCESS;
    static  char              *fname = "_NFFutility_message_notify";

    _NFIdebug ((fname, "g_label = <%d>\n", g_label));

    /* need to change the command value */

    NFFform_message (CURRENT_LABEL, NFI_S_CLEAR_MSG, NULL);

    switch (g_label)
      {

        case FI_ACCEPT:
        case FI_CANCEL:

            /*  Load the global error structure  */

            ERRload_struct (NFI, NFI_S_SUCCESS, NULL);
            NFFglobal.status = NFI_S_SUCCESS;

            FIf_delete (*form);
            NFFglobal.current_form = *form = NULL;

            break;

           default:
              _NFIdebug ((fname, "Unrecognized gadget label\n"));
           break;
      }

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

