
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFsave_item (display_flag, catalog, item, revision)
  int     display_flag;
  char    *catalog;
  char    *item;
  char    *revision;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFsave_item";

    _NFIdebug ((fname, "display_flag = <%d>\n", display_flag));
    _NFIdebug ((fname, "catalog = <%s>\n", catalog));
    _NFIdebug ((fname, "item = <%s>\n", item));
    _NFIdebug ((fname, "revision = <%s>\n", revision));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CONFIRM_SAVE, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to save the files of ");
      }

    if ((status = (long) UMSGetByNum (prompt2,
        NFT_P_CONFIRM_ITEM, "%s%s", item, revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt2, "the indicated item(s) ?");
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_SAVE_ITEM;

    /*  Set the NFMR function  */

    NFFglobal.NFMRfunction[0] = NFMRsave_item_files;
/*
    NFFglobal.NFMRfunction[0] = NULL;
*/
    if ((status = _NFFconfirm (SAVE_ITEM_LABEL, display_flag,
        catalog, item, revision, prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long NFFsave_set (display_flag, catalog, set, revision)
  int     display_flag;
  char    *catalog;
  char    *set;
  char    *revision;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFsave_set";

    _NFIdebug ((fname, "display_flag = <%d>\n", display_flag));
    _NFIdebug ((fname, "catalog = <%s>\n", catalog));
    _NFIdebug ((fname, "set = <%s>\n", set));
    _NFIdebug ((fname, "revision = <%s>\n", revision));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CONFIRM_SAVE, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to save");
      }

    if ((status = (long) UMSGetByNum (prompt2,
        NFT_P_CONFIRM_ITEM, "%s%s", set, revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt2, "the indicated item(s) ?");
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_SAVE_ITEM;

    /*  Set the NFMR function  */

    NFFglobal.NFMRfunction[0] = NFMRsave_set_files;
/*
    NFFglobal.NFMRfunction[0] = NULL;
*/
    if ((status = _NFFconfirm (SAVE_ITEM_LABEL, display_flag,
        catalog, set, revision, prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long NFFsave_set_parent (catalog, set, revision)
  char    *catalog;
  char    *set;
  char    *revision;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFsave_set_parent";

    _NFIdebug ((fname, "catalog = <%s>\n", catalog));
    _NFIdebug ((fname, "set = <%s>\n", set));
    _NFIdebug ((fname, "revision = <%s>\n", revision));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum
        (prompt1, NFT_P_CONFIRM_SAVE, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to save");
      }

    if ((status = (long) UMSGetByNum (prompt2,
        NFT_P_CONFIRM_PARENT_ONLY, "%s%s", set, revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt2,
            "Set \"%s\" Revision \"%s\", but no children ?", set, revision);
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_SAVE_ITEM;

    /*  Set the NFMR function  */

    NFFglobal.NFMRfunction[0] = NFMRsave_item_files;
/*
    NFFglobal.NFMRfunction[0] = NULL;
*/
    if ((status = _NFFconfirm (GENERIC_CONFIRM_LABEL, TRUE,
        catalog, set, revision, prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
