#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDtest.h"
#include "VDxml.h"
#include "VDgeomc.h"
#include "VDctx.h"
#include "VDxdom.h"
#include "VDval.h"
#include "VDvalLike.h"

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
  IGRstat sts;
  
  IGRint i;

  TGRid pieceID;
  TGRid pieceIDs;
  
  IGRint errCnt = 0;
  IGRdouble tol = 2.0;
  
  // Init system
  VDgblInitStaticData(0);
  VDctxInitSystem(0);
  setTolerances();
  
  // Make a tree
  VDxdomCreateTreeFromXmlFile("std_pcmks.xml",&pieceIDs);
  if (pieceIDs.objid == NULL_OBJID) goto wrapup;

  // Validate standard piece marks
  VDvalValidateStdPieces(&pieceIDs,2,tol,&errCnt);

  // Clean up
  VDctxDeleteNode(&pieceIDs);
  
  // Done
 wrapup:
  return 0;
  
}
