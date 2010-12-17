
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFconfirm.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFflag_set_files (display_flag, command, catalog, set_name, revision)
  int     display_flag;
  int     command;       /* FLAG_ARCHIVE, FLAG_BACKUP, FLAG_RESTORE  */
  char    *catalog;     
  char    *set_name;
  char    *revision;
  {
    auto    long    status;
    auto    int     label;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFflag_set_files";

    _NFIdebug ((fname, "Flag Command   = <%d>\n", command));
    _NFIdebug ((fname, "Catalog Name   = <%s>\n", catalog));
    _NFIdebug ((fname, "Set Name       = <%s>\n", set_name));
    _NFIdebug ((fname, "Revision       = <%s>\n", revision));

    if ((command != FLAG_ARCHIVE) && (command != FLAG_BACKUP) &&
        (command != FLAG_RESTORE)) 
     {
         _NFIdebug ((fname, "unknown flag command <%d>\n", command));
         _NFIdebug ((fname, " returning <0x%.8x>\n", NFI_E_BAD_COMMAND));
         return (NFI_E_BAD_COMMAND);
     }

    /*  Get the command prompts from UMS  */

    if ((status = (long) UMSGetByNum (prompt1, NFT_P_CONFIRM_FLAG, 
                                      NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
        _NFIdebug ((fname, "defaulting prompt ...\n"));
        strcpy (prompt1, "Are you sure you want to flag");
      }

    switch (command)
     {
        case FLAG_ARCHIVE:
/*
           if ((status = (long) UMSGetByNum (prompt2,
                                        NFT_P_CONFIRM_SET_ARCHIVE, "%s%s",
                                        set_name, revision)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               sprintf (prompt2,
                        " Set \"%s\" Revision \"%s\" 's files for archive ?",
                        set_name, revision);
             }
*/
           if ((status = (long) UMSGetByNum
               (prompt2, NFT_P_CONFIRM_SET, NULL)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               sprintf (prompt2, " the indicated set(s) ?");
             }
           label = FLAG_ARCHIVE_LABEL;

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_FLAG_SET_ARCHIVE;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRflag_set_archive;
        break;

        case FLAG_BACKUP:
/*
           if ((status = (long) UMSGetByNum (prompt2, 
                                        NFT_P_CONFIRM_SET_BACKUP, "%s%s",
                                        set_name, revision)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               sprintf (prompt2,
                        " Set \"%s\" Revision \"%s\" 's files for backup ?",
                        set_name, revision);
             }
*/
           if ((status = (long) UMSGetByNum
               (prompt2, NFT_P_CONFIRM_SET, NULL)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               sprintf (prompt2, " the indicated set(s) ?");
             }
           label = FLAG_BACKUP_LABEL;

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_FLAG_SET_BACKUP;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRflag_set_backup;
        break;

        case FLAG_RESTORE:
/*
           if ((status = (long) UMSGetByNum (prompt2,
                                        NFT_P_CONFIRM_SET_RESTORE, "%s%s",
                                        set_name, revision)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               sprintf (prompt2,
                        " Set \"%s\" Revision \"%s\" 's files for restore ?",
                        set_name, revision);
             }
*/
           if ((status = (long) UMSGetByNum
               (prompt2, NFT_P_CONFIRM_SET, NULL)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               sprintf (prompt2, " the indicated set(s) ?");
             }
           label = FLAG_RESTORE_LABEL;

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_FLAG_SET_RESTORE;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRflag_set_restore;
        break;
     }

    if ((status = _NFFconfirm (label, display_flag, catalog, set_name,
                               revision, prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

