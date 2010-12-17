
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFsetup_config ()
  {
    auto    int   status;
    auto    char  *p, path[256];
    auto    char  longer_path[512];
    auto    FILE  *language_file;
    static  char  language[20] = DEFAULT_LANGUAGE;
    static  char  *fname = "_NFFsetup_config";

    /*  Hardcode the product path  */

    strcpy (path, "/usr/ip32/nfm/config/language");

    /*  Open the "language" file to find the preferred language  */

    if ((language_file = fopen (path, "r")) == NULL)
      {
        _NFIdebug ((fname, "failed to open <%s>\n", path));
        _NFIdebug ((fname, "defaulting language to \"%s\"\n", language));
      }
    else
      {
        /*  Read the language out of the file  */

        if ((_NFFfgets (language,
            sizeof (language) - 1, language_file)) == NULL)
          {
            _NFIdebug ((fname, "failed to read <%s>\n", path));
            strncpy (language, DEFAULT_LANGUAGE, sizeof (language) - 1);
            _NFIdebug ((fname, "defaulting language to \"%s\"\n", language));
          }

        fclose (language_file);
      }

    /*  Remove "/language"  */

    p = strrchr (path, '/');
    *p = NULL;

    strcat (path, "/");
    strcat (path, language);
    strcat (path, "/icons");

    /*  Tell the forms software where to find our symbols  */

    _NFIdebug ((fname, "calling FI_set_symbol_path ...\n"));
    if ((status = FI_set_symbol_path (path)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FI_set_symbol_path = %d\n", status));
        _NFIdebug ((fname, "symbol path is <%s>\n", path));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_set_symbol_path", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
        _NFIdebug ((fname, "symbol path is <%s>\n", path));

    /*  Remove symbol path  */

    p = strrchr (path, '/');
    *p = NULL;

    /*  Add forms path  */

    strcat (path, "/forms");

    strcpy (longer_path, ".:");
    strcat (longer_path, path);
    strcat (longer_path, ":");
    strcat (longer_path, path);

    /*  Remove forms path  */

    p = strrchr (longer_path, '/');
    *p = NULL;

    /*  Add menus path  */

    strcat (longer_path, "/menus");

    /*  Use either the administrative menus or the user menus  */

    if (NFFglobal.admin_or_user == ADMIN)
        strcat (longer_path, "/admin");
    else
        strcat (longer_path, "/user");

    /*  Tell the forms software where to find our forms and menus  */

    _NFIdebug ((fname, "calling FI_set_form_path ...\n"));
    if (status = FI_set_form_path (longer_path))
      {
        _NFIdebug ((fname, "FI_set_form_path = <%d>\n", status));
        _NFIdebug ((fname, "forms path is <%s>\n", longer_path));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_set_form_path", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
        _NFIdebug ((fname, "forms path is <%s>\n", longer_path));

    /*  Remove forms path  */

    p = strrchr (path, '/');
    *p = NULL;

    strcat (path, "/messages");

    /*  Tell the message system where our message files are  */

    _NFIdebug ((fname, "calling ERRinit_messages ...\n"));
    if ((status = ERRinit_messages (path, UMS_INDEX)) != ERR_S_SUCCESS)
      {
        _NFIdebug ((fname, "ERRinit_messages = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }
        _NFIdebug ((fname, "ERRinit_messages path is <%s>\n", path));

    /*  Initialize the forms titles' message files  */

    strcat (path, "/NFMtitles.msg");
    UMSInitMsg (path, UMS_INDEX);

    /*  Remove titles' path  */

    p = strrchr (path, '/');
    *p = NULL;

    /*  Initialize the QUI message file  */

    strcat (path, "/QUImsg.msg");
    UMSInitMsg (path, UMS_INDEX);

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
