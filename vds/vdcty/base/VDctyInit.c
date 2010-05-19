/* $Id: VDctyInit.c,v 1.1 2001/03/11 18:38:03 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctyMgr.c
 *
 * Description: Initialize new tree classes
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctyInit.c,v $
 *      Revision 1.1  2001/03/11 18:38:03  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/11/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDgbl.h"
#include "VDassert.h"
#include "VDctx.h"
#include "VDcty.h"

VDASSERT_FFN("vdcty/base/VDctyMgr.c");

/* -----------------------------------------------
 * Predefined tree classes
 */
typedef struct
{
  IGRint   revFlag;
  TVDctyTP tps[32];
} Tlist;

/* -----------------------------------------------
 * Get the nth tree class
 */
TVDctyTP *VDctyGetNthTP(IGRint nth)
{
  
  VDASSERT_FN("VDctxGetNthTP");
  
  TVDctyTP *tp  = NULL;
  Tlist *s = vdGblStaticData03;
  
  // Be careful
  VDASSERTW((nth >= 0) && (nth <= 32));
  tp = &s->tps[nth];
  
  // Done
wrapup:
  return tp;
}

/* -----------------------------------------------
 * Called during startup to initialize the system
 */
IGRstat VDctyInitSystem(IGRint flag)
{  
  VDASSERT_FN("VDctyInitSystem");
  IGRstat retFlag = 1;
  
  TVDctyTP *baseTP;
  TVDctyTP *prodTP;
  TVDctyTP *partTP;
  TVDctyTP *plotTP;

  Tlist *s;

  // Only during initial startup
  if (flag != 0) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Alloc
  s = calloc(1,sizeof(Tlist));
  if (s == NULL) {
    printf("*** Problem initializing VDcty system\n");
    goto wrapup;
  }
  vdGblStaticData03 = s;

  // Init the classes
  baseTP = &s->tps[VDCTY_CLASSI_BASE_TREE];
  VDctyInitBaseTP(baseTP);

  prodTP = &s->tps[VDCTY_CLASSI_PROD_TREE];
  VDctyInitProdTP(baseTP,prodTP);

  partTP = &s->tps[VDCTY_CLASSI_STD_PARTS_TREE];
  VDctyInitStdPartsTP(prodTP,partTP);

  plotTP =  &s->tps[VDCTY_CLASSI_PLOT_TREE];
  VDctyInitPlotTP(baseTP,plotTP);
  

  // Done
  retFlag = 1;
      
wrapup:
  return retFlag;
}
