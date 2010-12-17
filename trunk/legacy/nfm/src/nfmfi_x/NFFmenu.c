
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global NFI structure  */

extern struct NFFglobal_st NFFglobal;

long _NFFinit_menus ()
  {
    auto    int  status;
    static  char *fname = "_NFFinit_menus";

    _NFIdebug ((fname, "entering ...\n"));

    /*  Load the menus into memory  */

    if ((status = MS_init_menus ()) != MS_SUCCESS)
      {
        _NFIdebug ((fname, "MS_init_menus = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_MENU, "%s%d", "MS_init_menus", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MENU);
      }

    /*  Display the menus  */

    if (NFFglobal.collapse_flag == FALSE)
      {
        if ((status = MS_display_menus ()) != MS_SUCCESS)
          {
            _NFIdebug ((fname, "MS_display_menus = <%d>\n", status));
            ERRload_struct (NFI,
                NFI_E_MENU, "%s%d", "MS_display_menus", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_MENU);
          }
      }
/*
    MS_save_locations ("menu.locations");
*/
    return (NFI_S_SUCCESS);
  }
