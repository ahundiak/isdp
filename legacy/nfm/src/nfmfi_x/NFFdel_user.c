
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFdelete_user (user)
  char    *user;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFdelete_user";

    _NFIdebug ((fname, "user = <%s>\n", user));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CONFIRM_DELETE, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to delete");
      }

    if ((status = (long) UMSGetByNum
        (prompt2, NFT_P_CONFIRM_USER, "%s", user)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt2, "User \"%s\" ?", user);
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_DELETE_USER;

    /*  Set the NFMR function  */

    NFFglobal.NFMRfunction[0] = NFMRdelete_user;

    if ((status = _NFFconfirm (DELETE_USER_LABEL, TRUE,
        user, "", "", prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
