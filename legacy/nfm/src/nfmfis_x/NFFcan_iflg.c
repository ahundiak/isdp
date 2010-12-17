
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFconfirm.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFcancel_item_flag (display_flag, command, catalog, item_name, revision)
  int     display_flag;
  int     command;       /* CANCEL_ARCHIVE, CANCEL_BACKUP, CANCEL_RESTORE,  */
  char    *catalog;      /* CANCEL_DELETE :  as defined in NFFadd.h    */
  char    *item_name;
  char    *revision;
  {
    auto    long    status;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFcancel_item_flag";

    _NFIdebug ((fname, "Cancel Command = <%d>\n", command));
    _NFIdebug ((fname, "Catalog Name   = <%s>\n", catalog));
    _NFIdebug ((fname, "Item Name      = <%s>\n", item_name));
    _NFIdebug ((fname, "Revision       = <%s>\n", revision));

    if ((command != CANCEL_ARCHIVE) && (command != CANCEL_BACKUP) &&
        (command != CANCEL_RESTORE) && (command != CANCEL_DELETE)) 
     {
         _NFIdebug ((fname, "unknown cancel_flag command <%d>\n", command));
         _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_BAD_COMMAND));
         return (NFI_E_BAD_COMMAND);
     }

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum (prompt2, NFT_P_CONFIRM_ITEM_FILES, "%s%s",
                                      item_name, revision)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        sprintf (prompt2, " Item \"%s\" Revision \"%s\" files ?",
                 item_name, revision);
      }

    switch (command)
     {
        case CANCEL_ARCHIVE:
           if ((status = (long) UMSGetByNum
               (prompt1, NFT_P_CONFIRM_CANCEL_ARCHIVE, NULL)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               strcpy (prompt1, 
                       "Are you sure you want to cancel archive flags on");
             }

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_CANCEL_ITEM_ARCHIVE;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRcancel_item_archive_flag;
        break;

        case CANCEL_BACKUP:
           if ((status = (long) UMSGetByNum
               (prompt1, NFT_P_CONFIRM_CANCEL_BACKUP, NULL)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               strcpy (prompt1, 
                       "Are you sure you want to cancel backup flags on");
             }

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_CANCEL_ITEM_BACKUP;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRcancel_item_backup_flag;
        break;

        case CANCEL_RESTORE:
           if ((status = (long) UMSGetByNum
               (prompt1, NFT_P_CONFIRM_CANCEL_RESTORE, NULL)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               strcpy (prompt1, 
                       "Are you sure you want to cancel restore flags on");
             }

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_CANCEL_ITEM_RESTORE;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRcancel_item_restore_flag;
        break;

        case CANCEL_DELETE:
           if ((status = (long) UMSGetByNum
               (prompt1, NFT_P_CONFIRM_CANCEL_DELETE, NULL)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               strcpy (prompt1, 
                       "Are you sure you want to cancel delete flags on");
             }

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_CANCEL_ITEM_DELETE;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRcancel_item_delete_flag;
        break;
     }

    if ((status = _NFFconfirm (CONFIRM_LABEL, display_flag, catalog, item_name,
                               revision, prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

