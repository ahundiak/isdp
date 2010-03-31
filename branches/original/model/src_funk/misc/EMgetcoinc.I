/*
NAME:
   EMgetcoincsurfs

DESCRIPTION
    This function takes in a Profile/Composite curve and a solid 
    and output all such surfaces of the solid which in the plane of
    (coincident) the profile/composite curve. 

    input:
          compcvid      : Grid of the Profile/Composite curve.
          solidid       : Grid of the solid under consideration.
    output:
          num_coincsrfs : Number of coincident surfaces output.
          coincsrfs     : Coincident surface objid's.

    The memory for coincsrfs is allocated within this function and is to be
    freed by the caller.

Author  Apr'94  KNAP    : Initial writing.
*/
class implementation EMSsurface;

%safe
#include "math.h"
%endsafe
#include "EMS.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMSdprquery.h"
#include "emserr.h"
#include "emsedgedef.h"
#include "bserr.h"
#include "maerr.h"
#include "bssfarrevn.h"
#include "bsparameters.h"
#include "bsparameters.h"
#include "bstypes.h"
#include "bsdotp.h"
#include "bschgdeppar.h"
#include "bschangepar.h"
#include "bspl_of_cv.h"

#define  UV_SAMPLE_POINT  0.485

void EMgetcoincsurfs ( msg, md_env, compcvid, solidid, num_coincsrfs,
                       coincsrfs )
IGRlong               *msg;
struct GRmd_env       *md_env;
struct GRid           *compcvid;
struct GRid           *solidid;
IGRint                *num_coincsrfs;
GRobjid               **coincsrfs;
{
  IGRboolean                are_planar, are_normal1, are_normal2;
  IGRint                    i, j, num_surfs;
  IGRshort                  *mattyp;
  IGRdouble                 *mat, dottol, dotp;
  IGRlong                   msg_loc, stat;
  IGRpoint                  sf_pt, prof_pt;
  IGRvector                 prof_normal, sf_normal, p_vec;
  GRobjid                   *surfid, *sfids;
  struct GRid               sf_grid;
  struct EMScomponent_info  *comp_info;

  struct IGRplane      	    profile_plane, surf_plane;

  BSEXTRACTPAR( &msg_loc, BSTOLORTHOVEC, dottol );

  *msg = EMS_S_Success;
  

  comp_info  = NULL;
  mattyp = &md_env->md_env.matrix_type;
  mat = md_env->md_env.matrix;
  surfid = sfids = NULL;

  /* 
   *  Construct a plane encompassing the input closed composite
   *  curve/profile.
   */

  profile_plane.normal = prof_normal; profile_plane.point = prof_pt;
  stat = om$send(msg = message GRvg.GRdetplane(&msg_loc,
			mattyp, mat, &profile_plane),
		 senderid = compcvid->objid,
		 targetid = compcvid->objid,
		 targetos = compcvid->osnum);
  EMerr_hndlr (EMSerror (stat & msg_loc), *msg, EMS_E_Fail, wrapup);

  /*  
   *  Get the component information of the solid under consideration.
   */
  stat = om$send( msg = message EMSsurface.EMgetInfoAboutComponents
                        ( &msg_loc, &num_surfs, &comp_info ),
               senderid = NULL_OBJID,
               targetid = solidid->objid,
               targetos = solidid->osnum );
  EMerr_hndlr (EMSerror (stat & msg_loc), *msg, EMS_E_Fail, wrapup);

  surfid = ( GRobjid *) om$malloc( size = sizeof(GRobjid) * num_surfs);

  /*
   *  Process only planar surfaces
   */
  j = 0;
  for ( i = 0; i < num_surfs; i++ )
  {
    are_planar = are_normal1 = are_normal2 = FALSE;
    sf_grid.objid = comp_info[i].surf_id;
    sf_grid.osnum = solidid->osnum;

    /*
     * Get the surface normal.
     */

    surf_plane.point = sf_pt; surf_plane.normal = sf_normal;
    stat = om$send(msg = message GRvg.GRdetplane(&msg_loc,
			    mattyp, mat, &surf_plane),
		         senderid = sf_grid.objid,
		         targetid = sf_grid.objid,
		         targetos = sf_grid.osnum );
    EMerr_hndlr (EMSerror (stat), *msg, EMS_E_Fail, wrapup);
    
    if(msg_loc == MANONPLANAR) continue;
    
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, wrapup);
    
    dotp = BSdotp ( &msg_loc, prof_normal, sf_normal );
    EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );

    if ( (1.0 - fabs(dotp)) >  dottol )
      are_planar = FALSE; 
    else
      are_planar = TRUE; 

    if ( !EMis_geomequal_3dpt ( prof_pt, sf_pt, dottol ) )
    {
      BSmkvec ( &msg_loc, p_vec, sf_pt, prof_pt );
      EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );
      BSnorvec ( &msg_loc, p_vec );
      EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );
      dotp = BSdotp ( &msg_loc, prof_normal, p_vec );
      EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );
      if ( fabs(dotp) < dottol )
        are_normal1 = TRUE; 
      else
        are_normal1 = FALSE; 
      dotp = BSdotp ( &msg_loc, sf_normal, p_vec );
      EMerr_hndlr( msg_loc != BSSUCC, *msg, EMS_E_BSerror, wrapup );
      if ( fabs(dotp) < dottol )
        are_normal2 = TRUE; 
      else
        are_normal2 = FALSE; 
    }
    else if ( are_planar )
    {
      are_normal1 = TRUE;
      are_normal2 = TRUE;
    }
    if ( are_planar && are_normal1 && are_normal2 ) 
    {
      surfid[j] = comp_info[i].surf_id;
      j++;
    }
  }

  sfids = ( GRobjid *) om$malloc( size = sizeof(GRobjid)*j);
  OM_BLOCK_MOVE( &surfid[0], sfids, sizeof(GRobjid)*j);
  *num_coincsrfs = j;
  *coincsrfs = sfids;

wrapup:
       if ( comp_info )
         EFfreeComponentInfoMem( num_surfs, comp_info );
       if ( surfid )
         free ( surfid );
}
end implementation EMSsurface;
