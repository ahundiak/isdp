#include "machine.h"
#include "WFF.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long _WFFinit_menus ()
  {
	int		status;
	/* int		xpos, ypos; */
	/* int		xsize, ysize; */

	static	char *fname = "_WFFinit_menus";

	/*  Menus Subsystem functions  */

	int MS_init_menus ();
	int MS_display_menus ();

	/*  Forms Interface functions  */

	int FIf_get_size ();
	int FIf_get_location ();
	int FIf_set_location ();

	/*  Rename the user's menu(s) to "PANEL_MENU" and "BAR_MENU"  */

	/*  Load the menus into memory  */

	if ((status = MS_init_menus ()) != MS_SUCCESS)
	  {
		_NFIdebug ((fname, "MS_init_menus = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_MENU, "%s%d", "MS_init_menus", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MENU);
	  }

	/*  Display the menus  */

	if ((status = MS_display_menus ()) != MS_SUCCESS)
	  {
		_NFIdebug ((fname, "MS_display_menus = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_MENU, "%s%d", "MS_display_menus", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MENU);
	  }
/*
	MS_save_locations ("menu.locations");
*/
	return (NFI_S_SUCCESS);
  }
