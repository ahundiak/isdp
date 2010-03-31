class implementation Root;

from EMSassoc import EMget_parent_info;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"
#include "EMSmsgdef.h"            /* EMS_I_NotFound */
#include "EC_M.h"            /* Command strings */
#include "EC_P.h"      /* Prompt strings */
#include "EC_I.h"      /* Informational strings */
#include "EC_F.h"      /* Fatal strings */
#include "FI.h"
#include "EMSdpb.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmass.h"
#include "igr.h"

/*

Name
  EFSplitSurface

Abstract
 This function splits a surface into patches, as dictated by
 the set of u and v parameters sent in patch_list. The output
 geometries are returned also in patch_list in the u-v order.

Synopsis
 OUT:		IGRlong *msg;
 IN:		struct IGRbsp_surface *p_surface;
 IN/OUT:	struct EMpatch_list patch_list;

Description
 
Return Value

Notes

Index

Keywords
 split,surface,skinning,patch
History
 06/22/93 : Carlos M. Diaz : created

*/
IGRlong EFSplitSurface (EMmsg, p_surface, patch_list)
IGRlong *EMmsg;
struct IGRbsp_surface *p_surface;
struct EMpatch_list patch_list;
{
  int     i, j, k = 0;
  IGRlong msg_loc;
  double  par1[2], par2[2], par3[2];

  for (i = 0; i < patch_list.params.numu - 1; i++) {
    for (j = 0; j < patch_list.params.numv - 1; j++) {

      patch_list.geometries[k] = NULL;

      BSallocsf (p_surface->u_order, 
          p_surface->v_order, 
          (p_surface->u_num_poles + (2 * p_surface->u_order) - 1),
          (p_surface->v_num_poles + (2 * p_surface->v_order) - 1), 
          p_surface->rational,
          2*(p_surface->num_boundaries), 
          &patch_list.geometries[k], 
          &msg_loc);

      if( msg_loc != BSSUCC ) 
          patch_list.geometries[k] = NULL;

      EMerr_hndlr( (msg_loc != BSSUCC) || !(patch_list.geometries[k]), *EMmsg, 
                   EMS_E_NoDynamicMemory, wrapup );

      patch_list.geometries[k]->rational = p_surface->rational;
      patch_list.geometries[k]->num_boundaries = p_surface->num_boundaries;

      par1[0] = patch_list.params.u_pars[i]; /* begin cut on u */
      par1[1] = patch_list.params.v_pars[j]; /* begin cut on v */

      par3[0] = patch_list.params.u_pars[i+1]; /* end cut on u */
      par3[1] = patch_list.params.v_pars[j+1]; /* end cut on v */

      par2[0] = par1[0] + ((par3[0] - par1[0]) * 0.5); /* intermediate point on u */
      par2[1] = par1[1] + ((par3[1] - par1[1]) * 0.5); /* intermediate point on v */

#ifdef DEBUG
      printf ("Now extracting Udelta:%f %f ; Vdelta:%f %f\n", 
               par1[0],
               par3[0],
               par1[1],
               par3[1]);
#endif

      BSpartofsf (p_surface,
          par1,
          par2,
          par3,
          2,
          patch_list.geometries[k],
          &msg_loc);

      /* 
      * since the knot vectors (u, v) of the partial surface 
      * returned by the math function are not normalized, they 
      * are normalized before constructing the object.
      */
      if( msg_loc != BSSUCC )
      {
          BSfreesf( &msg_loc, patch_list.geometries[k] );
          patch_list.geometries[k] = NULL;
#ifdef DEBUG
       printf("EFSpltSrf: Surface Splitting failed for parameters : \n");
       printf("           par1 : (%lf, %lf) , par2 : (%lf, %lf) , par3 : (%lf, %lf)\n", par1[0], par1[1], par2[0], par2[1], par3[0], par3[1] );
       printf("           i, j, k = %d, %d, %d\n", i, j, k );
#endif
      }
      EMerr_hndlr ((msg_loc != BSSUCC), *EMmsg, EMS_E_BSerror, wrapup);
      BSnrsfkntvc(patch_list.geometries[k]);
      patch_list.geometries[k]->pos_orient = p_surface->pos_orient;
      k++;
    }
  }
wrapup:
return msg_loc;
}

end implementation Root;
