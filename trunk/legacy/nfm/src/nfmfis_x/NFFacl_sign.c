
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFadd_acl_signoff_users (acl_name)
  char    *acl_name;
  {
    auto    long    status;
    auto    char    title[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFadd_acl_signoff_users";

    _NFIdebug ((fname, "entering ...\n"));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_ADD_ACL_SIGN, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Add ACL Signoff Users");
      }

    if ((status = _NFFget_mapping
        (acl_name, title, "", ADD_ACL_SIGNOFF_USERS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFget_mapping = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long NFFdelete_acl_signoff_users (acl_name)
  char    *acl_name;
  {
    auto    long    status;
    auto    char    title[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFdelete_acl_signoff_users";

    _NFIdebug ((fname, "entering ...\n"));

    if ((status = (long) UMSGetByNum
        (title, NFT_P_DEL_ACL_SIGN, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title, "Delete ACL Signoff Users");
      }

    if ((status = _NFFget_mapping
        (acl_name, title, "", DELETE_ACL_SIGNOFF_USERS)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFget_mapping = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
