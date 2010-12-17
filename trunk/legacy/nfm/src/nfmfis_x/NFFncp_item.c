
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "WFcommands.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFn_copy_item_files (display_flag, catalog, item_name, revision)
  int     display_flag;
  char    *catalog;
  char    *item_name;
  char    *revision;
  {
    auto    long    status;
    char    command [NFM_COMMANDNAME + 1];
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFn_copy_item_files";

    _NFIdebug ((fname, "catalog = <%s>\n", catalog));
    _NFIdebug ((fname, "item_name = <%s>\n", item_name));
    _NFIdebug ((fname, "revision = <%s>\n", revision));

    /*  Get the command prompts from UMS  */

  /* prompt needs to change for confirm */
    if ((status = (long) UMSGetByNum (prompt1, NFT_P_CONFIRM_COPY_FILES,
                                      NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to copy the files of");
      }

    if ((status = (long) UMSGetByNum (prompt2,
                                   NFT_P_CONFIRM_ITEM, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt2, "the indicated item(s) ?");
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_COPY_ITEM_FILES;

    strcpy (command, COPY_ITEM_FILES);

    /*  Set the NFMR function  */

    NFFglobal.NFMRfunction[0] = NFMRcopy_item_files;

    if (strcmp (NFFglobal.set_indicator, "") == 0)
       status = _NFFfile_io (COPY_FILES_CONFIRM_LABEL, display_flag, command,
                             catalog, item_name, revision, prompt1, prompt2);
    else
       status = _NFFfile_io (CP_SET_ITEM_FILES_LABEL, display_flag, command,
                             catalog, item_name, revision, prompt1, prompt2);
    if (status != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFfile_io = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
