 /* $Id: VDct1Init.c,v 1.7 2002/01/07 18:53:32 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1Init.c
 *
 * Description: Tree Initialization
 *              Moved it to it's own routine to reduce service pack dependencies
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Init.c,v $
 *      Revision 1.7  2002/01/07 18:53:32  jdsauby
 *      JTSMP CRs 4045,4048,4053,4054
 *
 *      Revision 1.6  2001/05/25 14:56:49  jdsauby
 *      ETL 2235, Add HVAC tree to OTM
 *
 *      Revision 1.5  2001/05/14 18:07:08  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/04/03 17:08:57  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/04/03 12:58:53  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/04/03 12:57:20  ahundiak
 *      makefile
 *
 *      Revision 1.1  2001/03/11 18:37:01  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/17 14:48:13  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/14 16:29:17  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/12 15:14:11  art
 *      sp merge
 *
 * Revision 1.1  2000/12/08  15:49:42  pinnacle
 * ah
 *
 * Revision 1.7  2000/11/16  20:14:40  pinnacle
 * pn
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 * 03/11/01  ah      Change to use VDgbl
 * 03/04/01  ah      Accidental checkin while setting up sp262
 * 03/04/01  ah      Need to reset function pointers during service pack startup
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDgbl.h"
#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDassert.h"
#include "VDctx.h"

typedef struct 
{
  IGRint revFlag;
  
  TVDct1RootTreeClass     rootTree;
  TVDct1PlotTreeClass     plotTree;

  TVDct1ProdTreeClass     prodTree;
  TVDct1StdPartsTreeClass stdPartsTree;
  TVDct1StdAssysTreeClass stdAssysTree;
  TVDct1PalAssysTreeClass palAssysTree;
  TVDct1DeltaTreeClass    deltaTree;

  TVDct1EngTreeClass      engTree;
  TVDct1OutfitTreeClass   outfitTree;
  TVDct1CableTreeClass    cableTree;
  TVDct1WWayTreeClass     wwayTree;
  TVDct1HvacTreeClass     hvacTree;

} Ttrees;


VDASSERT_FFN("vdct1/tree/VDct1Init.c");

/* ---------------------------------------------
 * Maybe times (during startup) want to 
 * get a default tree class just to get going
 */
TVDct1RootTreeClass *VDct1GetRootTreeClass()
{
  Ttrees *s = vdGblStaticData04;
  return &s->rootTree;
}

/* -----------------------------------------------
 * Get the nth tree
 * Only return instantiable classes
 */
void *VDct1GetTreeClassForNth(IGRint nth)
{
  Ttrees *s = vdGblStaticData04;

  // Just a switch for now
  switch(nth) {
    case 0: return &s->outfitTree;
    case 1: return &s->stdPartsTree;
    case 2: return &s->stdAssysTree;
    case 3: return &s->palAssysTree;
    case 4: return &s->plotTree;
    case 5: return &s->cableTree;
    case 6: return &s->wwayTree;
    case 7: return &s->hvacTree;
    case 8: return &s->deltaTree;
  }
  
  // None left
 wrapup:
  return NULL;
}

/* -----------------------------------------------
 * Get the tree by the set type
 */
void *VDct1GetTreeClassForSetType(IGRchar *setType)
{
  VDASSERT_FN("VDct1GetTreeClassForSetType");

  Ttrees *s = vdGblStaticData04;
  
  // Arg check
  VDASSERTW(setType);

  // Allow accessing abstract classes
  if (!strcmp(setType,VDCT1_TREE_TYPE_ROOT_TREE)) return &s->rootTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_PROD_TREE)) return &s->prodTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_ENG_TREE))  return &s->engTree;

  // Just check
  if (!strcmp(setType,VDCT1_TREE_TYPE_OUTFIT_TREE)) return &s->outfitTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_STD_PARTS))   return &s->stdPartsTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_STD_ASSYS))   return &s->stdAssysTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_PAL_ASSYS))   return &s->palAssysTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_PLOT_TREE))   return &s->plotTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_CABLE_TREE))  return &s->cableTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_WWAY_TREE))   return &s->wwayTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_HVAC_TREE))   return &s->hvacTree;
  if (!strcmp(setType,VDCT1_TREE_TYPE_DELTA_TREE))  return &s->deltaTree;
  
  VDASSERTW(NULL);
  
  // None
 wrapup:
  return NULL;
}

/* -----------------------------------------------
 *
 * 11 March 2001 - Called whenever vds is started up
 *
 */
IGRstat VDct1InitSystem(IGRint cnt)
{
  VDASSERT_FN("VDct1InitSystem");
  
  IGRstat retFlag = 0;

  Ttrees *s;
  
  // Only process for initial startup and first drawing
  switch(cnt) {
    case 0:
    case 1:
      break;
    default:
      retFlag = 1;
      goto wrapup;
  }

  // Alloc room if required
  s = vdGblStaticData04;
  if (s) free(s);
  
  s = calloc(1,sizeof(Ttrees));
  if (s == NULL) {
    printf("*** Problem initializing VDct1 tree system\n");
    goto wrapup;
  }
  vdGblStaticData04 = s;
  
  // Init each tree
  VDct1InitRootTreeClass(&s->rootTree);
  VDct1InitPlotTreeClass(&s->rootTree,&s->plotTree);
  VDct1InitProdTreeClass(&s->rootTree,&s->prodTree);

  VDct1InitStdPartsTreeClass(&s->prodTree,&s->stdPartsTree);
  VDct1InitStdAssysTreeClass(&s->prodTree,&s->stdAssysTree);
  VDct1InitPalAssysTreeClass(&s->prodTree,&s->palAssysTree);
  VDct1InitDeltaTreeClass   (&s->prodTree,&s->deltaTree);

  VDct1InitEngTreeClass(&s->prodTree,&s->engTree);

  VDct1InitOutfitTreeClass(&s->engTree,&s->outfitTree);
  VDct1InitCableTreeClass (&s->engTree,&s->cableTree);
  VDct1InitWWayTreeClass  (&s->engTree,&s->wwayTree);
  VDct1InitHvacTreeClass  (&s->engTree,&s->hvacTree);

  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}
