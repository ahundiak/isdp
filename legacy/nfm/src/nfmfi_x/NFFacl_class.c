/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFadd_acl_class_users (type, acl_name)
  int    type;
  char   *acl_name;
  {
    auto    long    status;
    auto    char    title[NFF_MAX_MESSAGE];
    auto    NFFmap  entity;
    static  char    *fname = "NFFadd_acl_class_users";

    _NFIdebug ((fname, "entering ...\n"));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_ADD_ACL_USERS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Add ACL Class Users");
      }

    if ((status = _NFFget_mapping
        (acl_name, title, "", ADD_ACL_CLASS_USERS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFget_mapping = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  This is to determine whether the command was called
        from the PANEL_MENU or from the "Define ACL" command  */

    FIf_get_user_pointer (NFFglobal.current_form, &entity);
    entity->command_type = (short) type;

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long NFFdelete_acl_class_users (acl_name)
  char    *acl_name;
  {
    auto    long    status;
    auto    char    title[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFdelete_acl_class_users";

    _NFIdebug ((fname, "entering ...\n"));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_DEL_ACL_USERS, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Delete ACL Class Users");
      }

    if ((status = _NFFget_mapping
        (acl_name, title, "", DELETE_ACL_CLASS_USERS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFget_mapping = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
