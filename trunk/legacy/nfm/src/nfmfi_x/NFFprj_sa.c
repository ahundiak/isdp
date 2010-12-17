
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFmap.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

long NFFadd_project_sa_mapping (project)
  char    *project;
  {
    auto    long    status;
    auto    char    title1[NFF_MAX_MESSAGE];
    auto    char    title2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFadd_project_sa_mapping";

    _NFIdebug ((fname, "project = <%s>\n", project));

    if ((status = (long) UMSGetByNum
        (title1, NFT_P_ADD_PRJ_SA_MAP, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title1, "Add Project Storage Area Mapping");
      }

    if ((status = (long) UMSGetByNum
        (title2, NFT_P_PRJ_MAP, "%s", project)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title2, "for Project \"%s\"", project);
      }

    if ((status = _NFFget_mapping
        (project, title1, title2, ADD_PROJECT_SA_MAP)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFget_mapping = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }


long NFFdelete_project_sa_mapping (project)
  char    *project;
  {
    auto    long    status;
    auto    char    title1[NFF_MAX_MESSAGE];
    auto    char    title2[NFF_MAX_MESSAGE];
    static  char    *fname = "NFFdelete_project_sa_mapping";

    _NFIdebug ((fname, "project = <%s>\n", project));

    if ((status = (long) UMSGetByNum
        (title1, NFT_P_DEL_PRJ_SA_MAP, NULL)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        strcpy (title1, "Delete Project Storage Area Mapping");
      }

    if ((status = (long) UMSGetByNum
        (title2, NFT_P_PRJ_MAP, "%s", project)) != UMS_S_SUCCESS)
      {
        _NFIdebug ((fname, "UMSGetByNum = <0x%.8x>\n", status));
        _NFIdebug ((fname, "defaulting title\n"));
        sprintf (title2, "for Project \"%s\"", project);
      }

    if ((status = _NFFget_mapping
        (project, title1, title2, DELETE_PROJECT_SA_MAP)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFget_mapping = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
