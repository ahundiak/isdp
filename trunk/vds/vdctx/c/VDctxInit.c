/* $Id: VDctxInit.c,v 1.8 2001/10/19 18:21:34 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxInit.c
 *
 * Description: Initialize the context class system
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxInit.c,v $
 *      Revision 1.8  2001/10/19 18:21:34  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/10/18 15:31:02  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/08/24 20:00:01  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/05/02 15:33:19  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/04/06 12:43:21  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/04/03 16:46:30  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/13 00:17:58  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/11 18:41:53  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/11/01  ah      Creation
 * 04/03/01  ah      Needs to be tweaked to reload service pack function pointers
 * 04/05/01  ah      Tewak again to allow the CP structures to be modified for sp
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctxPrivate.h"
#include "VDctx.h"
#include "VDgbl.h"
#include "VDobj2.h"
#include "VDos.h"

VDASSERT_FFN("vdctx/c/VDctxMgr.c");

typedef struct 
{
  IGRint    revFlag;

  TVDctxCP  baseCP;
  TVDctxCP   ct1CP;
  TVDctxCP    atCP;
  TVDctxCP    omCP;
  TVDctxCP  xdomCP;
} Tlist;

/* -----------------------------------------------
 * Get the nth class pointer
 * The system must have already been initialized
 */
TVDctxCP *VDctxGetNthCP(IGRint nth)
{
  VDASSERT_FN("VDctxGetNthCP");
  
  TVDctxCP *cp  = NULL;
  Tlist *s = vdGblStaticData02;

  // Be a bit careful
  switch(nth) {
    case VDCTX_CP_BASE : cp = &s->baseCP; goto wrapup;
    case VDCTX_CP_CT1  : cp = &s->ct1CP;  goto wrapup;
    case VDCTX_CP_AT   : cp = &s->atCP;   goto wrapup;
    case VDCTX_CP_OM   : cp = &s->omCP;   goto wrapup;
    case VDCTX_CP_XDOM : cp = &s->xdomCP; goto wrapup;
  }
  VDASSERTW(cp);

 wrapup:
  return cp;
}

/* -----------------------------------------------
 * Inits the system, call during startup
 * cnt is the number of times called during the session
 */
IGRstat VDctxInitSystem(IGRint cnt)
{
  VDASSERT_FN("VDctxInitSystem");
  IGRstat retFlag = 0;

  Tlist *s;
  
  /* ---------------------------------------------
   * Only process for 
   * cnt == 0, initial startup
   * cnt == 1, first drawing retrieval (for service packs)
   */
  switch(cnt) {
    case 0:
    case 1:

      // Free to allow for resizing
      s = vdGblStaticData02;
      if (s) {
	free(s);
	vdGblStaticData02 = NULL;
      }
      break;

    default:
      retFlag = 1;
      goto wrapup;
  }
  
  // Alloc room if needed
  s = vdGblStaticData02;
  if (s == NULL) {    
    s = calloc(1,sizeof(Tlist));
    if (s == NULL) {
      printf("*** Problem allocating memory for VDctxInitSystem\n");
      printf("    This is really really bad\n");
      goto wrapup;
    }
    vdGblStaticData02 = s;
  }
  
  // Init stuff, actually end up doing twice but oh well
  VDctxInitBaseCP(&s->baseCP);
  VDctxInitCt1CP (&s->baseCP,&s->ct1CP);
  VDctxInitAtCP  (&s->baseCP,&s->atCP );
  VDctxInitOmCP  (&s->baseCP,&s->omCP );
  VDctxInitXdomCP(&s->baseCP,&s->xdomCP);

  // printf(">>> %s %d\n",fn,cnt);
  
  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
  
}
