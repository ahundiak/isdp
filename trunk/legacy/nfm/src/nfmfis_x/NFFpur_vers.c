
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFconfirm.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFpurge_file_versions (display_flag, catalog, item_name, revision)
  int     display_flag;
  char    *catalog;
  char    *item_name;
  char    *revision;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFpurge_file_versions";

    _NFIdebug ((fname, "Catalog Name   = <%s>\n", catalog));
    _NFIdebug ((fname, "Item Name      = <%s>\n", item_name));
    _NFIdebug ((fname, "Revision       = <%s>\n", revision));

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum (prompt1, NFT_P_CONFIRM_PURGE_VERS, 
                                      NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to purge version(s) of");
      }

     if ((status = (long) UMSGetByNum (prompt2, NFT_P_CONFIRM_ITEM_FILES,
                                "%s%s", item_name, revision)) != UMS_S_SUCCESS)
      {
         _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
         _NFIdebug ((fname, "defaulting prompt ...\n"));
         sprintf (prompt2, " Item \"%s\" Revision \"%s\" 's files ?",  
                  item_name, revision);
      }

    /*  Set the working message  */

    NFFglobal.working_no = NFI_I_PURGE_FILE_VERSIONS;

    /*  Set the NFMR function  */

    NFFglobal.NFMRfunction[0] = NFMRpurge_versions;

    if ((status = _NFFconfirm (GENERIC_CONFIRM_LABEL, display_flag, catalog,
                       item_name, revision, prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

