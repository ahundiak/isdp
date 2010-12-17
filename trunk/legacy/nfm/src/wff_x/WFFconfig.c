#include "machine.h"
#include "WFF.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long _WFFsetup_config (program_name)
  char	*program_name;
  {
	int		status;
	char	*p, path[256];
	char	longer_path[512];
	char	*ch[3];
	FILE	*language_file, *fopen ();

	static	char language[20] = DEFAULT_LANGUAGE;
	static	char *fname = "_WFFsetup_config";

	/*  External functions  */

	char *strrchr ();
	long ERRinit_messages ();

	/*  User Message System functions  */

	int UMSInitMsg ();

	/*  Forms Interface functions  */

	int FI_set_symbol_path ();
	int FI_set_form_path ();

	_NFIdebug ((fname, "program name = <%s>\n", program_name));

	strcpy (path, (char *) whence (program_name, NULL));

	/*  Remove executable name  */

	p = strrchr (path, '/');
	*p = NULL;

	/*  Remove "/bin"  */

	p = strrchr (path, '/');
	*p = NULL;

	strcat (path, "/config/language");

	/*  Open the "language" file to find the preferred language  */

	if ((language_file = fopen (path, "r")) == NULL)
	  {
		_NFIdebug ((fname, "failed to open <%s>\n", path));
		_NFIdebug ((fname, "defaulting language to \"%s\"\n", language));
	  }
	else
	  {
		/*  Read the language out of the file  */

		if ((_WFFfgets (language,
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

	if ((status = FI_set_symbol_path (path)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FI_set_symbol_path = %d\n", status));
		_NFIdebug ((fname, "symbol path is <%s>\n", path));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_set_symbol_path", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Remove symbol path  */

	p = strrchr (path, '/');
	*p = NULL;
	strcat (path, "/admin_help");
	strcat (path, "/help_source");
	p = strrchr (path, '/');
	*p = NULL;
	strcat (path, "/help_graphics");

	/*  Remove help path  */

	p = strrchr (path, '/');
	*p = NULL;
	p = strrchr (path, '/');
	*p = NULL;
	p = strrchr (path, '/');
	*p = NULL;

	/*  Add forms path  */

        /* This change is necessary because Glenn changed the forms path */
        /* July 30, 1992 : B.W. */

	strcat (path, "/english/forms"); 
	strcpy (longer_path, ".:");
	strcat (longer_path, path);
	strcat (longer_path, ":");
	strcat (longer_path, path);

	/*  Remove forms path  */

	p = strrchr (longer_path, '/');
	*p = NULL;
	p = strrchr (longer_path, '/');
	*p = NULL;

	/*  Add menus path  */

	strcat (longer_path, "/");
	strcat (longer_path, language);

	/*  the workflow menus will be in /menus/workflow  */

	strcat (longer_path, "/menus/workflow");

	/*  Tell the forms software where to find our forms and menus  */

	if (status = FI_set_form_path (longer_path))
	  {
		_NFIdebug ((fname, "FI_set_form_path = <%d>\n", status));
		_NFIdebug ((fname, "forms path is <%s>\n", longer_path));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_set_form_path", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Remove forms path  */

	p = strrchr (path, '/');
	*p = NULL;

	strcat (path, "/");
	strcat (path, language);
	strcat (path, "/messages");

	/*  Tell the message system where our message files are  */

	if ((status = ERRinit_messages (path, UMS_INDEX)) != ERR_S_SUCCESS)
	  {
                _NFIdebug ((fname, "Message path = <%s>\n", path));
		_NFIdebug ((fname, "ERRinit_messages = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }
