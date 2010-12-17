
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFlock_item (catalog, item_name, revision)
  char    *catalog;
  char    *item_name;
  char    *revision;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFlock_item";

    _NFIdebug ((fname, "catalog = <%s>\n", catalog));
    _NFIdebug ((fname, "item_name = <%s>\n", item_name));
    _NFIdebug ((fname, "revision = <%s>\n", revision));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CONFIRM_LOCK, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to lock");
      }

    if ((status = (long) UMSGetByNum (prompt2,
        NFT_P_CONFIRM_ITEM, "%s%s", item_name, revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt2,
            "Item \"%s\" Revision \"%s\" ?", item_name, revision);
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_LOCK_ITEM;

    /*  Set the NFMR function  */

    NFFglobal.NFMRfunction[0] = NFMRlock_item;

    if ((status = _NFFconfirm (CONFIRM_LABEL, TRUE,
        catalog, item_name, revision, prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
