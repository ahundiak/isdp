#include "FImin.h"

#include <stdio.h>

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

static char nullc = 0;

/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

char *_FI_s_new (char *string)
{
   int length = 0;
   char *temp_string;

   if (string)
	  length = strlen ( (char *) string);

   if (! length)
	  return (&nullc);

   temp_string = (char *) calloc (1, length + 1);

   strcpy ( (char *) temp_string, (char *) string);

   return (temp_string);
}

/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

void _FI_s_free (char *sp)
{
   if (sp && (sp != &nullc))
	  free ( (char *) sp);
}


/* CHUNN -- changed for 7/16 bit fonts. 12-14-89 */

void _FI_s_rep (char  **sp,
                char   *string)
{
   _FI_s_free (*sp);

   *sp = _FI_s_new (string);
}


void _FI_g_free_symbols (struct FIgadget_obj *gadget)
{

   if (gadget->FIgadget.symbol_ptr.pixmap)
	  XFreePixmap (_FI_display, gadget->FIgadget.symbol_ptr.pixmap);
   gadget->FIgadget.symbol_ptr.pixmap = (Pixmap) NULL;

   if (gadget->FIgadget.on_symbol_ptr.pixmap)
	  XFreePixmap (_FI_display, gadget->FIgadget.on_symbol_ptr.pixmap);
   gadget->FIgadget.on_symbol_ptr.pixmap = (Pixmap) NULL;

}

