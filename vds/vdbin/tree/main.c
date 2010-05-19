/* --------------------------------------------
 * This actually works pretty good
 * Still need details on freeing up memory
 */

/* example-start tree tree.c */
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctx.h"

#include "glib.h"

#include <gtk/gtk.h>

VDASSERT_FFN("vdbin/main.c");

/* -----------------------------------------------
 * Main routine
 */
int main( int   argc,
          char *argv[] )
{
  int i;
  
  // Init system
  VDgblInitStaticData(0);
  VDctxInitSystem(0);

  for(i = 1; i < argc; i++) {
    VDgtkShowTreeFile(argv[i]);
  }
  return 0;
}

