
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFadd.h"
#include "NFFconfirm.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFflag_project_files (display_flag, command, project)
  int     display_flag;
  int     command;       /* FLAG_ARCHIVE, FLAG_BACKUP, FLAG_RESTORE,  */
  char    *project;
  {
    auto    long    status;
    auto    int     label;
    auto    char    prompt1[NFF_MAX_MESSAGE];
    auto    char    prompt2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFflag_project_files";

    _NFIdebug ((fname, "Flag Command   = <%d>\n", command));
    _NFIdebug ((fname, "Project Name   = <%s>\n", project));

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
           if ((status = (long) UMSGetByNum (prompt2,
                                        NFT_P_CONFIRM_PROJECT_ARCHIVE, "%s",
                                        project)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               sprintf (prompt2,
                        " Project \"%s\" 's files for archive ?", project);
             }
           label = FLAG_PROJECT_ARCHIVE_LABEL;

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_FLAG_PROJECT_ARCHIVE;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRflag_project_archive;
        break;

        case FLAG_BACKUP:
           if ((status = (long) UMSGetByNum (prompt2, 
                                        NFT_P_CONFIRM_PROJECT_BACKUP, "%s",
                                        project)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               sprintf (prompt2,
                        " Project \"%s\" 's files for backup ?", project);
             }
           label = FLAG_PROJECT_BACKUP_LABEL;

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_FLAG_PROJECT_BACKUP;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRflag_project_backup;
        break;

        case FLAG_RESTORE:
           if ((status = (long) UMSGetByNum (prompt2,
                                        NFT_P_CONFIRM_PROJECT_RESTORE, "%s",
                                        project)) != UMS_S_SUCCESS)
             {
               _NFIdebug ((fname, "UMSGetByNum = <%d>\n", status));
               _NFIdebug ((fname, "defaulting prompt ...\n"));
               sprintf (prompt2,
                        " Project \"%s\" 's files for restore ?", project);
             }
           label = FLAG_PROJECT_RESTORE_LABEL;

           /*  Set the working message  */

           NFFglobal.working_no = NFI_I_FLAG_PROJECT_RESTORE;

           /*  Set the NFMR function  */

           NFFglobal.NFMRfunction[0] = NFMRflag_project_restore;
        break;
     }

    if ((status = _NFFconfirm (label, display_flag, project, "", "",
                               prompt1, prompt2)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFconfirm = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

