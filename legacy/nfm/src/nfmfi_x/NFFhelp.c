
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

int _NFFhelp_toc ()
  {
    auto    long  status;
    static  char  *fname = "_NFFhelp_toc";

#if defined(OS_SUNOS) || defined(OS_SOLARIS) || \
    defined(OS_SCO_UNIX) || defined(OS_HPUX)

    /* Help is not available on these platforms */
    NFFform_message(CURRENT_LABEL, NFI_E_HELP, NULL);

#else

    if (NFFglobal.Help_initialized == FALSE)
      {
        _NFIdebug ((fname, "Help is not initialized\n"));
        if ((status = _NFFinit_help ()) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFinit_help = <0x%.8x>\n", status));

            /*  This is for compatibility with existing notify routines  */

            _NFIdebug ((fname, "returning <-1>\n"));
            return (-1);
          }

        NFFglobal.Help_initialized = TRUE;
      }
    if (status = Help_toc ())
      {
        _NFIdebug ((fname, "Help_toc = <%d>\n", status));

        /*  This is for compatibility with existing notify routines  */

        _NFIdebug ((fname, "returning <-1>\n"));
        return (-1);
      }

    /*  This is for compatibility with existing notify routines  */

    _NFIdebug ((fname, "returning SUCCESS\n"));

#endif

    return (0);
  }


int _NFFhelp_topic (command)
  char    *command;
  {
    auto    long  status;
    static  char  *fname = "_NFFhelp_toc";

#if defined(OS_SUNOS) || defined(OS_SOLARIS) || \
    defined(OS_SCO_UNIX) || defined(OS_HPUX)

    /* Help is not available on these platforms */
    NFFform_message(CURRENT_LABEL, NFI_E_HELP, NULL);
    return(-1);

#else
    if (NFFglobal.Help_initialized == FALSE)
      {
        _NFIdebug ((fname, "Help is not initialized\n"));
        if ((status = _NFFinit_help ()) != NFI_S_SUCCESS)
          {
            _NFIdebug ((fname, "_NFFinit_help = <0x%.8x>\n", status));

            /*  This is for compatibility with existing notify routines  */

            _NFIdebug ((fname, "returning <-1>\n"));
            return (-1);
          }

        NFFglobal.Help_initialized = TRUE;
      }

    if (status = Help_topic (command))
      {
        _NFIdebug ((fname, "Help_topic = <%d>\n", status));

        /*  This is for compatibility with existing notify routines  */

        _NFIdebug ((fname, "returning <-1>\n"));
        return (-1);
      }

    /*  This is for compatibility with existing notify routines  */

    _NFIdebug ((fname, "returning SUCCESS\n"));
#endif
    return (0);
  }


long _NFFinit_help ()
  {
    auto    int   status;
    auto    char  *p, path[256];
    auto    char  helpinfo[80];
    auto    char  help_doc_name[20];
    auto    char  help_language[20];
    auto    char  help_version[20];
    auto    FILE  *language_file;
    auto    FILE  *helpinfo_file;
    struct  HP_doc_id_struct help_doc;
    static  char  language[20] = DEFAULT_LANGUAGE;
    static  char  *fname = "_NFFinit_help";

#ifdef XWINDOWS
    status = Help_set_Xdisplay( NFFglobal.display_name );
    if( status )
    {
	_NFIdebug(( fname, "Help_set_Xdisplay <%d>\n", status ));
	ERRload_struct( NFI, NFI_E_HELP, "%s%d", "Help_set_Xdisplay", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
	return( NFI_E_HELP );
    }
#endif

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

    /*  Set the Help file path for the user or administrator  */

    if (NFFglobal.admin_or_user == ADMIN)
        strcat (path, "/admin_help/HELPINFO");
    else
        strcat (path, "/user_help/HELPINFO");

    /*  Now read the HELPINFO file to get information to build Help 
     *  structure.
     */

    _NFIdebug(( fname, "Reading <%s> for Help information\n", path ));

    if ((helpinfo_file = fopen (path, "r")) == NULL)
      {
        _NFIdebug ((fname, "failed to open <%s>\n", path));
      }
    else
      {
        /*  Read the Help information out of the file  */

        if ((_NFFfgets (helpinfo,sizeof(helpinfo) - 1, helpinfo_file)) == NULL)
          {
            _NFIdebug ((fname, "failed to read <%s>\n", path));
          }

        fclose (helpinfo_file);
      }
    _NFIdebug(( fname, "Helpinfo <%s>\n", helpinfo ));

    /*  Pick out individual pieces of Help information from a format
     *  of  <document_name:document_language:document_version>
     */

    p = strrchr( helpinfo, ':' );
    strcpy( help_version, ++p );
    --p;
    *p=NULL;

    p = strrchr( helpinfo, ':' );
    strcpy( help_language, ++p );
    --p;
    *p = NULL;

    strcpy( help_doc_name, helpinfo );

    _NFIdebug(( fname, "Help document name <%s>\n", help_doc_name ));
    _NFIdebug(( fname, "Help language <%s>\n", help_language ));
    _NFIdebug(( fname, "Help version <%s>\n", help_version ));

    help_doc.logical_name = (char*)malloc( strlen(help_doc_name) + 1 );
    help_doc.language     = (char*)malloc( strlen(help_language) + 1 );
    help_doc.version      = (char*)malloc( strlen(help_version)  + 1 );
    strcpy( help_doc.logical_name, help_doc_name );
    strcpy( help_doc.language, help_language );
    strcpy( help_doc.version, help_version );

    _NFIdebug(( fname, "Calling Help_document ...\n" ));
    status = Help_document( &help_doc );
    if( status )
    {
	_NFIdebug(( fname, "Could not locate document <%s>\n", help_doc_name));
	_NFIdebug(( fname, "Help_document <%d>\n", status ));
	ERRload_struct( NFI, NFI_E_HELP, "%s%d", "Help_document", status);
	free( help_doc.logical_name );
	free( help_doc.language );
	free( help_doc.version );
        _NFIdebug ((fname, "returning FAILURE\n"));
	return( NFI_E_HELP );
    }

    free( help_doc.logical_name );
    free( help_doc.language );
    free( help_doc.version );

    _NFIdebug ((fname, "calling Help_origin ...\n"));
    if (status = Help_origin
	(UPPER_LEFT_X * NFFglobal.scale_factor_x,
	UPPER_LEFT_Y * NFFglobal.scale_factor_y))
      {
        _NFIdebug ((fname, "Help_origin = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_HELP, "%s%d", "Help_origin", status);
        _NFIdebug ((fname, "returning FAILURE\n"));
        return (NFI_E_HELP);
      }

    _NFIdebug ((fname, "returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }

