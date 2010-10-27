/* $Id: VDfrm2.c,v 1.4 2001/01/14 16:33:27 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdah/VDfrm2.I
 *
 * Description: FI macros
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDfrm2.c,v $
 *      Revision 1.4  2001/01/14 16:33:27  art
 *      sp merge
 *
 *      Revision 1.3  2001/01/11 16:34:32  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 16:20:59  art
 *      s merge
 *
 * Revision 1.2  2000/12/07  13:36:08  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/06  14:54:16  pinnacle
 * ah
 *
 * Revision 1.1  2000/12/01  14:03:18  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/30/00  ah      Creation
 * 01/12/01  ah      sp17 merge, just tried to fix background
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDfrmc.h"

// This is what really requires a non-isdp file
#include "X11/Xlib.h"

static Display *display;

/* -----------------------------------------------
 * Open up the X11 display system
 * Basically gets the form system running
 *
 * Use the command line arguments to search for forms
 */
IGRstat VDfrmOpenDisplay(IGRint argc, IGRchar *argv[])
{
  IGRstat retFlag = 0;
  
  IGRstat sts;
  IGRchar *display_name = NULL;
  IGRchar formPath[1056];
  
  // Open it
  display = XOpenDisplay(display_name);
  if (display == NULL) {
    fprintf(stderr, "Cannot connect to X server %s\n", XDisplayName(display_name));
    goto wrapup;
  }

  // Hook to forms
  FSEnter (display, 0);

  /* ---------------------------------------------
   * When xforms and netscape 4.x are both running, get a white
   * background on text gadgets makeing it almost impossible to read.
   *
   * The default screen is what the examples under xformsdp use
   * The README says it's ok to just send NULL
   *
   * But in both cases, get the undesirable background color.
   *
   * Tried using FIg_set_color but no joy either
   */
  // FI_enter(display, DefaultColormap(display,DefaultScreen(display)),32);
  FI_enter(display, NULL,0);
  
  // Use args to set paths
  strcpy(formPath,".:/usr/tmp/forms");
  
  FI_set_form_path  (formPath);
  FI_set_symbol_path(formPath);

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Close down the display system
 */
IGRstat VDfrmCloseDisplay()
{
  if (display) XCloseDisplay(display);
  display = NULL;
  return 1;
}

IGRint VDnotify_box(IGRchar *buf)
{
  if (buf == NULL) return 0;
  printf("VDnotify_box %s\n",buf);
  return 1;
}

IGRint GRconfirm_box(IGRchar *buf)
{
  if (buf == NULL) return 0;
  printf("GRconfirm_box %s\n",buf);
  return 1;
}

