#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDxml.h"
#include "VDgeomc.h"
#include "VDctx.h"

#include "bsparameters.h"
#include "bschangepar.h"
#include "bschgdeppar.h"

VDASSERT_FFN("main.c");

static void setTolerances()
{
  BSrc rc;

  // Basis actually changed dependent
  BSchgdeppar(.0001,&rc);

  // Adjust the rest
  BSchangepar(&rc, BSTOLCHRDHT, .1);
  BSchangepar(&rc, BSTOLOFFSET, .5);
  BSchangepar(&rc, BSTOLARCLEN, .5);

  return;
}

/* -----------------------------------------------
 * Main traffic director
 */
main(IGRint argc, IGRchar *argv[])
{

  IGRint i;
  
  // Init system
  VDgblInitStaticData(0);
  VDctxInitSystem(0);
  setTolerances();
  
  // Cycle through
  if (argc == 1) VDvalValidateSpadesFile("spades.xml",0,0);
  else {
    for(i = 1; i < argc; i++) {

      // Make the report
      VDvalValidateSpadesFile(argv[i],0,0);
    }
  }
  
  // Done
 wrapup:
  return 0;
  
}
