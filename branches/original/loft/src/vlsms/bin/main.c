/* --------------------------------------------
 * This actually works pretty good
 * Still need details on freeing up memory
 */

/* example-start tree tree.c */
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctx.h"
#include "VDgeomc.h"
#include "VDxdom.h"

#include "VLsmsXml.h"
#include "VDcvgXml.h"

#include "VDcvg2.h"
#include "VDpdf2.h"

#include "glib.h"
#include "xdom.h"

#include "bsparameters.h"
#include "bschangepar.h"
#include "bschgdeppar.h"

VDASSERT_FFN("main.c");

#define TRACE_FLAG 0
#define TRACE_PCMK ""

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
 * Main routine
 */
int main( int   argc,
          char *argv[] )
{
  int i;
  
  // Init system
  VDgblInitStaticData(0);
  VDdomInitSystem(0,0,0);
  VDctxInitSystem(0);
  setTolerances();

  VLsmsInitLogFiles();

  VLsmsLog1(0,1,"-----------------------------------\n");
  VLsmsLog1(0,1,"Beginning conversion to spades file\n");

  VLsms2GenerateDxfPdf("SmsData.xml","3372",NULL,0);

  VLsmsCloseLogFiles();

  // Diff
  VDpdf2DiffSpadesFiles("spades.xml","spades2.xml");
  
  //system("dtpad extract.log &");
  
  return 0;
}
