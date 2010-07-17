class implementation Root;

#include "math.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "ex.h"
#include "msmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"

#include "vderrmacros.h"


from  GRgraphics import  GRdisplay;
from  GRcurve	 import  GRendpts;
from  GRcurve	 import  GRdisextend;
from  EMSsurface import  EMcrvsrfint;
from  GRcurve	 import  GRptextend;

long   SFextOrTrimCvToSf (
  long			*msg,
  char			extflag,	/* = TRUE, extend
					   = FALSE, deextend */
  struct GRid		*cv,
  struct GRmd_env	*cv_env,
  struct GRid		*sf,
  struct GRmd_env	*sf_env
)
{

long			sts, size1, size2, pnt_slots, no_pnts;
BSrc			rc;
IGRboolean		ex1 = FALSE, ex2 = FALSE;
double			buff1[200], buff2[200];
struct IGRbsp_curve	*cv_geom = NULL;
struct IGRbsp_surface   *sf_geom = NULL;
struct GRprops		props1,	props2;
enum  GRdpmode		dpmode;
IGRpoint		start_pt, end_pt, stpt_basept, endpt_basept, new_end;
double			upar, vpar,
			dist1, dist2, dist,
			*extpt = NULL;
double			*inter_pnts_xyz = NULL;
int			sizbuf, BytesRet;
struct GRmd_env		mod_env;


   sts = OM_S_SUCCESS;
   *msg = MSSUCC;

   sizbuf = sizeof ( struct GRmd_env );
   sts = gr$get_module_env (	msg	= msg,
				sizbuf  = &sizbuf,
				buffer  = &mod_env,
				nret	= &BytesRet );

   size1 = sizeof ( buff1 );
   size2 = sizeof ( buff2 );
   sts = GRget2objgeom ( msg, cv, &(cv_env->md_env), &ex1,
			 sf, &(sf_env->md_env), &ex2,
			 buff1, buff2,
			 &size1, &size2,
			 &cv_geom,  &sf_geom,
			 &props1, &props2  );
   /*
    * return status of above function is of IGRboolean type
    */
   VDS_ERR_HNDLR ( "GRget2objgeom", sts, *msg, VD_VERBOSE, wrapup );

   sts = om$send ( msg = message GRcurve.GRendpts (
					msg,
					&(cv_env->md_env.matrix_type),
					cv_env->md_env.matrix,
					start_pt,
					end_pt ),
		  targetid = cv->objid,
		  targetos = cv->osnum,
		  senderid = NULL_OBJID );
   VDS_ERR_HNDLR( "GRcurve.GRendpts", sts, *msg, VD_VERBOSE, wrapup );
   
   __DBGpr_vec ( "Start point of curve", start_pt );
   __DBGpr_vec ( "End point of curve", end_pt );

   /* make sure they are not same */
   if (
	(fabs( start_pt[0] - end_pt[0] ) < 1e-06) &&
	(fabs( start_pt[1] - end_pt[1] ) < 1e-06) &&
	(fabs( start_pt[2] - end_pt[2] ) < 1e-06)
       )
   {
	*msg = MSFAIL;
	VDS_ERR_HNDLR( "startpt=endpt",OM_S_SUCCESS,*msg, VD_VERBOSE, wrapup );
   }

   /* find minimum distances from end points to the surface */
   BSmdistptsf( &rc, sf_geom, start_pt, &upar, &vpar, stpt_basept, &dist1 );
   if ( rc != BSSUCC )
   {
	*msg = MSFAIL;
	VDS_ERR_HNDLR( "BSmdistptsf", OM_S_SUCCESS, *msg, VD_VERBOSE, wrapup );
   }

   BSmdistptsf( &rc, sf_geom, end_pt, &upar, &vpar, endpt_basept, &dist2 );
   if ( rc != BSSUCC )
   {
	*msg = MSFAIL;
	VDS_ERR_HNDLR( "BSmdistptsf", OM_S_SUCCESS, *msg, VD_VERBOSE, wrapup );
   }

   /* make sure both points are not at the same distance from surface */
   if ( fabs( dist1 - dist2 ) < 1e-06 )
   {
	*msg = MSFAIL;
	VDS_ERR_HNDLR( "dist1=dist2", OM_S_SUCCESS, *msg, VD_VERBOSE, wrapup );
   }

   /* determine the point to be extended and surface point */
   if ( dist1 < dist2 )
   {
	dist = dist1;
	extpt  = start_pt;
   }
   else
   {
	dist = dist2;
	extpt = end_pt;
   }

   if ( extflag )
   {
      /* extend by 10 times minimum distance */
      dist = 10 * dist;
      sts = om$send ( msg = message GRcurve.GRdisextend(msg,
							cv_env,
							extpt,
							&dist,
							new_end ),
		  targetid = cv->objid,
		  targetos = cv->osnum,
		  senderid = NULL_OBJID );
   }
   else
   {
     dpmode = GRbe;
     sts = om$send ( msg = message GRgraphics.GRdisplay (
						msg,
						&(cv_env->md_env.matrix_type),
						cv_env->md_env.matrix,
						&dpmode,
						&mod_env.md_id ),
		   targetid = cv->objid,
		   targetos = cv->osnum,
		   senderid = NULL_OBJID  );

      new_end[0] = extpt[0];
      new_end[1] = extpt[1];
      new_end[2] = extpt[2];
   }

   pnt_slots = 0;
   no_pnts = 0;

   sts = om$send ( msg = message EMSsurface.EMcrvsrfint ( msg, NULL,
				&(sf_env->md_env), NULL, cv,
				&(cv_env->md_env), TRUE, &pnt_slots, &no_pnts,
				NULL, NULL, NULL, &inter_pnts_xyz, NULL ),
		    targetid = sf->objid,
		    targetos = sf->osnum,
		    senderid = NULL_OBJID );
   VDS_ERR_HNDLR ( "EMSsurface.EMcrvsrfint", sts, *msg, VD_VERBOSE, wrapup );

   if ( no_pnts == 0 )
   {
	ex$message (	field = ERROR_FIELD,
			justification = CENTER_JUS,
			in_buff = "Error extending curve" );
	printf("Error extending the curve [%d,%d]\n", cv->objid, cv->osnum );

	dpmode = GRbd;
	sts = om$send ( msg = message GRgraphics.GRdisplay (
						msg,
						&(cv_env->md_env.matrix_type),
						cv_env->md_env.matrix,
						&dpmode,
						&mod_env.md_id ),
		   targetid = cv->objid,
		   targetos = cv->osnum,
		   senderid = NULL_OBJID  );

	goto wrapup;
   }

   __DBGpr_int("no. of intersection points", no_pnts );
   __DBGpr_vec(" first inter_pnts_xyz ", inter_pnts_xyz );

   /* extend till the first intersection point */
   sts = om$send ( msg = message GRcurve.GRptextend (	msg,
							cv_env,
							new_end,
							inter_pnts_xyz,
							new_end ),
		  targetid = cv->objid,
		  targetos = cv->osnum,
		  senderid = NULL_OBJID );

   dpmode = GRbd;
   sts = om$send ( msg = message GRgraphics.GRdisplay (
						msg,
						&(cv_env->md_env.matrix_type),
						cv_env->md_env.matrix,
						&dpmode,
						&mod_env.md_id ),
		   targetid = cv->objid,
		   targetos = cv->osnum,
		   senderid = NULL_OBJID  );


wrapup:
    if ( (double *)cv_geom != buff1 )  free ( cv_geom );
    if ( (double *)sf_geom != buff2 )  free ( sf_geom );
    if ( inter_pnts_xyz ) free ( inter_pnts_xyz );
    return sts;

}

end implementation Root;
