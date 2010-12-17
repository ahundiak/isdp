
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFpasswd.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFold_passwd_field (form, label, entity)
  Form       form;
  int        label;
  NFFpasswd  entity;
  {
    int     length;
    int     selected;
    int     r_pos;
    long    status;
    char    *text;

    static  char *fname = "_NFFold_passwd_field";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if ((status = (long) FIfld_get_text_length
        (form, label, 0, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Comment out this call before delivery  */
/*
    _NFIdebug ((fname, "length of text = <%d>\n", length));
*/
    if (length == 0)
      {
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "length", length);
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

    if ((status = (long) FIfld_get_text (form, label,
        0, 0, length, text, &selected, &r_pos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <0x%.8x>\n", status));
        if (text) free (text);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Comment out this call before delivery  */
/*
    _NFIdebug ((fname, "text = <%s>\n", text));
*/
    strncpy (entity->old_password, text, sizeof (entity->old_password) - 1);

    if (text) free (text);
/*
    if ((status = (long) FIfld_pos_cursor
        (form, label, 0, 0, 0, 0, 0, 0)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
*/
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long _NFFnew_passwd_field (form, label, entity)
  Form       form;
  int        label;
  NFFpasswd  entity;
  {
    int     length;
    int     selected;
    int     r_pos;
    long    status;
    char    *text;

    static  char *fname = "_NFFnew_passwd_field";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if ((status = (long) FIfld_get_text_length
        (form, label, 0, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Comment out this call before delivery  */
/*
    _NFIdebug ((fname, "length of text = <%d>\n", length));
*/
    if (length == 0)
      {
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "length", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFM_E_MALLOC);
      }

    if ((status = (long) FIfld_get_text (form, label,
        0, 0, length, text, &selected, &r_pos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <0x%.8x>\n", status));
        if (text) free (text);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
/*
    else
        status = NFI_S_SUCCESS;
 */

    /*  Comment out this call before delivery  */
/*
    _NFIdebug ((fname, "text = <%s>\n", text));
*/
    /*  See if this is first time for the new password  */

    strncpy (entity->new_password, text,
	     sizeof (entity->new_password) - 1);
    
    ERRload_struct (NFI, NFI_I_VERIFY, NULL); 

    if (text) free (text);
    
    /*  Put the cursor back to verify the new password  */
/*    
    if ((status = (long) FIfld_pos_cursor
	 (form, label, 0, 0, 0, 0, 0, 0)) != FI_SUCCESS)
      {
	_NFIdebug ((fname, "FIfld_pos_cursor = <%d>\n", status));
	ERRload_struct
	  (NFI, NFI_E_FORM, "%s%d", "FIfld_pos_cursor", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
      }
*/    

    _NFIdebug ((fname, " returning <0x%.8x>\n", status));
    return (status);
  }

long _NFFverify_passwd_field (form, label, entity)
  Form       form;
  int        label;
  NFFpasswd  entity;
  {
    int     length;
    int     selected;
    int     r_pos;
    long    status;
    char    *text;

    static  char *fname = "_NFFverify_passwd_field";

    _NFIdebug ((fname, "label = <%d>\n", label));

    if ((status = (long) FIfld_get_text_length
        (form, label, 0, 0, &length)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text_length = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text_length", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if (length == 0)
      {
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "length", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    if ((text = (char *) malloc (length)) == NULL)
      {
        _NFIdebug ((fname, "malloc failed; size = <%d>\n", length));
        ERRload_struct (NFI, NFI_E_MALLOC, "%d", length);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFM_E_MALLOC);
      }

    if ((status = (long) FIfld_get_text (form, label,
        0, 0, length, text, &selected, &r_pos)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FIfld_get_text = <0x%.8x>\n", status));
        if (text) free (text);
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_get_text", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  This is to verify the new password  */
    strncpy(entity->verify_password, text, sizeof(entity->verify_password)- 1);

    if (text) free (text);
    
    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }



long _NFFpasswd_validate_accept (entity)
  NFFpasswd   entity;
  {
    static    char *fname = "_NFFpasswd_validate_accept";

    if ((strcmp (entity->verify_password, entity->new_password)) != 0)
      {
        _NFIdebug ((fname, "new password was not correctly verified\n"));
        ERRload_struct (NFI, NFI_E_VERIFY, NULL);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_VERIFY);
      }

    entity->done = TRUE;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


void NFFfree_passwd (form, entity)
  Form         *form;
  NFFpasswd    entity;
  {
    if (form != NULL)
      {
        FIf_delete (*form);
        NFFglobal.current_form = *form = NULL;
      }

    if (entity) free (entity);
    entity = NULL;

    return;
  }
