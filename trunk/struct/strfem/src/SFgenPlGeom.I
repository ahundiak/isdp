class implementation Root;

#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "bstypes.h"
#include "bserr.h"
#include "bsdistptpt.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

#include "igr.h"
#include "igrdp.h"
#include "parametric.h"
#include "godef.h"
#include "go.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "acrepdef.h"
#include "vderrmacros.h"

#include "vsoptdef.h"
#include "vsattr.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"

#define  SF_MSG_NOT_T_OR_L   -100
#define  SF_ANGLE_SEC		0
#define  SF_TEE_SEC		1

extern long SFxformWebLineToCenter();
extern long SFxformFlgLineToCenter();


from  GRvg     import  GRgetattr;
from  NDmacro  import  ACgive_structure;
from  VSbeam   import  VSgetSupportAxis;
from  VSbeam   import  VSgetSupportSf;
from  VSbeam   import  VSextractProfile;
from  VSxscurve import  VStransUsrNmToCmp;
from  GRcurve  import  GRendpts;
from  GRgraphics import  GRxform;
from  GRvg     import  GRprojpt;
from  GRgraphics import  GRdisplay;

long  SFgenPlateGeomFromBm (
  long 			*msg,
  struct GRid		*vsBmId,
  struct GRmd_env	*vsBmEnv,
  char			*sectType,
  struct GRid		*feWebSurf,
  struct GRid		*feFlgSurf,
  double		*flgThk,
  double		*webThk
)
{
long			sts;
int			ACrc,
			index = -1;  /* unused ASSOC flag */
struct ret_struct	rs;
VSpartInfo		info;
VSpartAttr		attr;
struct GRvg_construct	cst;
int			numberOfBytes, BytesReceived;
IGRshort		level;
struct IGRdisplay	disp;
struct GRmd_env		ModEnv, TmpEnv;
struct GRobj_env	VSbmAxis, VSbmSurf,
			FlgTop, WebRight, WebLeft ;
struct GRid		xsId;
char			name[81];
double			wrStPt[3], wrEndPt[3],
			wlStPt[3], wlEndPt[3], centerPt[3],
			dist1, dist2, dist3, dist4;
BSrc			rc;


   __DBGpr_com ( "Entered SFbeamToPlate" );

   if ( !msg || !vsBmId || !vsBmEnv || !sectType || !feWebSurf || !feFlgSurf
	|| !flgThk || !webThk )
   {
	*msg = MSINARG;
	sts = OM_E_INVARG;
	goto wrapup;
   }

   *msg = MSSUCC;
   sts = OM_S_SUCCESS;

   __DBGpr_obj("Beam Id", *vsBmId );

   attr.Iwant		= VS_m_PartNum;
   attr.specific	= (void *) &info;
   sts  = om$send(  msg	      = message GRvg.GRgetattr( msg, (char *) &attr ),
		    targetid  = vsBmId->objid,
		    targetos  = vsBmId->osnum,
		    senderid  = vsBmId->objid ) ;
   VDS_ERR_HNDLR( "GRvg.GRgetattr", sts, *msg, VD_VERBOSE, wrapup );

   if ( attr.info.partNum[0] != 'L' && attr.info.partNum[0] != 'T' )
   {
	*msg = MSFAIL;
	goto wrapup;
   }

   *sectType = ( attr.info.partNum[0] == 'L' ) ? SF_ANGLE_SEC : SF_TEE_SEC;

   /*
    * get flange thickness of beam
    */
   sts = om$send(  msg       = message NDmacro.ACgive_structure(
					&ACrc, &index, VS_K_bmFlgThkAttr,
					&rs, vsBmEnv ),
			senderid  = vsBmId->objid,
			targetid  = vsBmId->objid,
			targetos  = vsBmId->osnum );
   VDS_ERR_HNDLR ( "NDmacro.ACgive_structure", sts, ACrc, VD_VERBOSE, wrapup);
   __DBGpr_dbl("flange thickness", rs.var.root_pm_st.value );
   *flgThk = rs.var.root_pm_st.value;

   /*
    * get web thickness of beam
    */
   sts = om$send(  msg       = message NDmacro.ACgive_structure(
					&ACrc, &index, VS_K_bmWebThkAttr,
					&rs, vsBmEnv ),
			senderid = NULL_OBJID,
			targetid  = vsBmId->objid,
			targetos  = vsBmId->osnum );
   VDS_ERR_HNDLR ( "NDmacro.ACgive_structure", sts, ACrc, VD_VERBOSE, wrapup);

   __DBGpr_dbl("web thickness", rs.var.root_pm_st.value );
   *webThk = rs.var.root_pm_st.value;

   /* it is found that for some sections *flgThk == 0.0. That is why
	the following check is being done
   */
   if ( *flgThk == 0.0 && *webThk == 0.0 )
	{ sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }
   if ( *flgThk == 0.0 ) *flgThk = *webThk;
   if ( *webThk == 0.0 ) *webThk = *flgThk;

   sts = om$send ( msg = message VSbeam.VSgetSupportAxis (
						msg,
						vsBmEnv,
						&VSbmAxis ),
			senderid  = vsBmId->objid,
			targetid  = vsBmId->objid,
			targetos  = vsBmId->osnum );
   VDS_ERR_HNDLR ( "VSbeam.VSgetSupportAxis", sts, *msg, VD_VERBOSE, wrapup);
   __DBGpr_obj("VSbmAxis", VSbmAxis.obj_id );

   sts = om$send ( msg = message VSbeam.VSgetSupportSf (
						msg,
						vsBmEnv,
						&VSbmSurf ),
			senderid  = vsBmId->objid,
			targetid  = vsBmId->objid,
			targetos  = vsBmId->osnum );
   VDS_ERR_HNDLR ( "VSbeam.VSgetSupportSf", sts, *msg, VD_VERBOSE, wrapup);
   __DBGpr_obj("VSbmSurf", VSbmSurf.obj_id );

   numberOfBytes = sizeof ( struct GRmd_env );
   gr$get_module_env  ( msg     = msg,
			sizbuf  = &numberOfBytes,
			buffer  = &ModEnv,
			nret    = &BytesReceived );

   numberOfBytes = sizeof ( IGRshort );
   gr$get_active_layer( msg     = msg,
			sizbuf  = &numberOfBytes,
			buffer  = &level,
			nret    = &BytesReceived );

   numberOfBytes = sizeof ( struct IGRdisplay );
   gr$get_active_display( msg     = msg,
			  sizbuf  = &numberOfBytes,
			  buffer  = &disp,
			  nret    = &BytesReceived );

   TmpEnv = ModEnv;
   TmpEnv.md_id.objid = NULL_OBJID;

   cst.msg      = msg;
   cst.env_info = &TmpEnv;
   cst.display  = &disp;
   cst.geometry = NULL;
   cst.newflag  = FALSE;
   cst.level    = level;
   cst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
   cst.class_attr = NULL;
   cst.name       = NULL;

   /*
    *  get flange and web objects
    */
   sts = om$send ( msg = message VSbeam.VSextractProfile (
						msg,
						vsBmEnv,
						&VSbmSurf,
						&VSbmAxis,
						0.0,
						&cst,
						AC_3D_REP,
						&xsId ),
		      targetid = vsBmId->objid,
		      targetos = vsBmId->osnum,
		      senderid = vsBmId->objid );
   VDS_ERR_HNDLR("VSbeam.VSextractProfile", sts, *msg, VD_VERBOSE, wrapup);
   __DBGpr_obj( "xs id", xsId );


   if ( *sectType == SF_TEE_SEC )
   {

     /* get top line of flange */
     strcpy ( name, VS_K_nmFlgSupE );
     sts = om$send ( msg = message VSxscurve.VStransUsrNmToCmp (
							msg,
							name,
							NULL,      
							&(FlgTop.obj_id) ),
		      targetid = xsId.objid,
		      targetos = xsId.osnum,
		      senderid = NULL_OBJID );
     VDS_ERR_HNDLR("VSxscurve.VStransUsrNmToCmp",sts,*msg, VD_VERBOSE, wrapup);
     __DBGpr_obj( "FlgTop.obj_id", FlgTop.obj_id );
     FlgTop.mod_env = TmpEnv;

     /* get right line of web */
     strcpy ( name, VS_K_nmWebR );
     sts = om$send ( msg = message VSxscurve.VStransUsrNmToCmp (
							msg,
							name,
							NULL,   
							&(WebRight.obj_id) ),
		      targetid = xsId.objid,
		      targetos = xsId.osnum,
		      senderid = NULL_OBJID );
     VDS_ERR_HNDLR("VSxscurve.VStransUsrNmToCmp",sts,*msg, VD_VERBOSE, wrapup);
     __DBGpr_obj( "WebRight.obj_id", WebRight.obj_id );
     WebRight.mod_env = TmpEnv;

     /* get left line of web */
     strcpy ( name, VS_K_nmWebL );
     sts = om$send ( msg = message VSxscurve.VStransUsrNmToCmp (
							msg,
							name,
							NULL,   
							&(WebLeft.obj_id) ),
		      targetid = xsId.objid,
		      targetos = xsId.osnum,
		      senderid = NULL_OBJID );
     VDS_ERR_HNDLR("VSxscurve.VStransUsrNmToCmp",sts,*msg, VD_VERBOSE, wrapup);
     __DBGpr_obj( "WebLeft.obj_id", WebLeft.obj_id );
     WebLeft.mod_env = TmpEnv;

     /* get end points of Web Right */
     sts = om$send ( msg = message GRcurve.GRendpts (
				msg,
				&WebRight.mod_env.md_env.matrix_type,
				WebRight.mod_env.md_env.matrix,
				wrStPt,
				wrEndPt ),
		   senderid = NULL_OBJID,
		   targetid = WebRight.obj_id.objid,
		   targetos = WebRight.obj_id.osnum );
     VDS_ERR_HNDLR ( "GRcurve.GRendpts", sts, *msg, VD_VERBOSE, wrapup );

     /* get end points of Web Left */
     sts = om$send ( msg = message GRcurve.GRendpts (
				msg,
				&WebLeft.mod_env.md_env.matrix_type,
				WebLeft.mod_env.md_env.matrix,
				wlStPt,
				wlEndPt ),
		   senderid = NULL_OBJID,
		   targetid = WebLeft.obj_id.objid,
		   targetos = WebLeft.obj_id.osnum );
     VDS_ERR_HNDLR ( "GRcurve.GRendpts", sts, *msg, VD_VERBOSE, wrapup );

     dist1 = BSdistptpt ( &rc, wrStPt, wlStPt );
     if ( rc != BSSUCC ) { sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }

     dist2 = BSdistptpt ( &rc, wrStPt, wlEndPt );
     if ( rc != BSSUCC ) { sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }

     if ( dist1 < dist2 )
     {
	centerPt[0] = (wlStPt[0] + wrStPt[0]) * 0.5;
	centerPt[1] = (wlStPt[1] + wrStPt[1]) * 0.5;
	centerPt[2] = (wlStPt[2] + wrStPt[2]) * 0.5;
     }
     else
     {
	centerPt[0] = (wlEndPt[0] + wrStPt[0]) * 0.5;
	centerPt[1] = (wlEndPt[1] + wrStPt[1]) * 0.5;
	centerPt[2] = (wlEndPt[2] + wrStPt[2]) * 0.5;
     }

     /*
      * get detailed profile of the beam
      */
     sts = SFxformWebLineToCenter ( msg, &WebRight.obj_id, &WebRight.mod_env,
				     centerPt );
     VDS_ERR_HNDLR("SFxformWebLineToCenter", sts, *msg, VD_VERBOSE, wrapup );

     sts = SFxformFlgLineToCenter ( msg, &FlgTop.obj_id, &FlgTop.mod_env,
				     centerPt, *flgThk );
     VDS_ERR_HNDLR("SFxformFlgLineToCenter", sts, *msg, VD_VERBOSE, wrapup );

     TmpEnv.md_id.objid = ModEnv.md_id.objid;

     feFlgSurf->objid = NULL_OBJID;
     feFlgSurf->osnum = ModEnv.md_id.osnum;
     sts=SFmake_plane_segment( msg, &FlgTop, &VSbmSurf, &VSbmAxis, &cst,
				feFlgSurf);
     VDS_ERR_HNDLR("SFmake_plane_segment", sts, *msg, VD_VERBOSE, wrapup );

     feWebSurf->objid = NULL_OBJID;
     feWebSurf->osnum = ModEnv.md_id.osnum;
     sts=SFmake_plane_segment(msg, &WebRight, &VSbmSurf, &VSbmAxis, &cst,
			       feWebSurf);
     VDS_ERR_HNDLR("SFmake_plane_segment", sts, *msg, VD_VERBOSE, wrapup );

     sts = SFextendSfToSf ( msg, feWebSurf, &ModEnv, feFlgSurf, &ModEnv );
     VDS_ERR_HNDLR("SFextendSfToSf", sts, *msg, VD_VERBOSE, wrapup );
   }
   else		/* it is an angle */
   {
     OM_S_CHANSELECT	  to_components;
     OM_S_OBJECT_LINKAGE  compLinkage[6];
     int		  cnt, ii, next, nextnext;
     double		  stPt[3], endPt[3], dists[6];
     char		  found;



     /* get top line of flange. By experimenting, it is found that
	VS_K_nmFlgInfE is the top flange of beam xsect */
#if 0
     strcpy ( name, VS_K_nmFlgInfE );
     sts = om$send ( msg = message VSxscurve.VStransUsrNmToCmp (
							msg,
							name,
							NULL,
							&(FlgTop.obj_id) ),
		      targetid = xsId.objid,
		      targetos = xsId.osnum,
		      senderid = NULL_OBJID );
     VDS_ERR_HNDLR("VSxscurve.VStransUsrNmToCmp",sts,*msg, VD_VERBOSE, wrapup);
     __DBGpr_obj( "FlgTop.obj_id(InfE)", FlgTop.obj_id );
     FlgTop.mod_env = TmpEnv;

/*
enum GRdpmode		dpmode = GRhd;
     sts = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&FlgTop.mod_env.md_env.matrix_type,
					FlgTop.mod_env.md_env.matrix,
					&dpmode,
					&ModEnv.md_id ),
		      targetid = FlgTop.obj_id.objid,
		      targetos = FlgTop.obj_id.osnum,
		      senderid = NULL_OBJID );
*/

     /* get superior left of flange ( it is larger web line, calling it 
	web left ) */
     strcpy ( name, VS_K_nmFlgSupL );
     sts = om$send ( msg = message VSxscurve.VStransUsrNmToCmp (
							msg,
							name,
							NULL,
							&(WebLeft.obj_id) ),
		      targetid = xsId.objid,
		      targetos = xsId.osnum,
		      senderid = NULL_OBJID );
     VDS_ERR_HNDLR("VSxscurve.VStransUsrNmToCmp",sts,*msg, VD_VERBOSE, wrapup);
     __DBGpr_obj( "WebLeft.obj_id", WebLeft.obj_id );
     WebLeft.mod_env = TmpEnv;

     /* get superior right of flange ( it is smaller web line, calling it 
	web right ) */
     strcpy ( name, VS_K_nmFlgSupR );
     sts = om$send ( msg = message VSxscurve.VStransUsrNmToCmp (
							msg,
							name,
							NULL,
							&(WebRight.obj_id) ),
		      targetid = xsId.objid,
		      targetos = xsId.osnum,
		      senderid = NULL_OBJID );
     VDS_ERR_HNDLR("VSxscurve.VStransUsrNmToCmp",sts,*msg, VD_VERBOSE, wrapup );
     __DBGpr_obj( "FlgInfR", WebRight.obj_id );
     WebRight.mod_env = TmpEnv;
*/
#endif

     sts = om$make_chanselect(	channame     = "GRcmpowner.to_components",
				p_chanselect = &to_components);

     cnt = 6;
     sts = om$get_channel_objects ( osnum         = xsId.osnum,
				    objid         = xsId.objid,
				    p_chanselect  = &to_components,
				    list          = compLinkage,
				    size          = cnt,
				    count         = (OMuint *) &cnt );
     VDS_ERR_HNDLR( "om$get_channel_objects", sts, MSSUCC, VD_VERBOSE, wrapup );
     if ( cnt != 6 ) { sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }

     for(ii=0; ii<6; ii++)
     {
	/* get end points of Web Right */
	sts = om$send ( msg = message GRcurve.GRendpts (
				msg,
				&TmpEnv.md_env.matrix_type,
				TmpEnv.md_env.matrix,
				stPt,
				endPt ),
		   senderid = NULL_OBJID,
		   targetid = compLinkage[ii].S_objid,
		   targetos = compLinkage[ii].osnum );
	VDS_ERR_HNDLR ( "GRcurve.GRendpts", sts, *msg, VD_VERBOSE, wrapup );

	dists[ii] = BSdistptpt ( &rc, stPt, endPt );
	if ( rc != BSSUCC ) { sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }
     }

     found = FALSE;
     for( ii=0; ii<6; ii++)
     {
	next = (ii+1) % 6;
	nextnext = (next+1) % 6;
	if ( dists[ii] > dists[nextnext] &&
	     fabs ( dists[next] - *webThk ) < 1.0E-06 )
	{
	   found = TRUE;
	   break;
	}
     }

     if ( !found ) { sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }
     WebLeft.obj_id.objid = compLinkage[ii].S_objid;
     WebLeft.obj_id.osnum = compLinkage[ii].osnum;
     WebLeft.mod_env = TmpEnv;

     WebRight.obj_id.objid = compLinkage[nextnext].S_objid;
     WebRight.obj_id.osnum = compLinkage[nextnext].osnum;
     WebRight.mod_env = TmpEnv;

     FlgTop.obj_id.objid = compLinkage[(nextnext+3)%6].S_objid;
     FlgTop.obj_id.osnum = compLinkage[(nextnext+3)%6].osnum;
     FlgTop.mod_env = TmpEnv;

     /* get end points of Web Right */
     sts = om$send ( msg = message GRcurve.GRendpts (
				msg,
				&WebRight.mod_env.md_env.matrix_type,
				WebRight.mod_env.md_env.matrix,
				wrStPt,
				wrEndPt ),
		   senderid = NULL_OBJID,
		   targetid = WebRight.obj_id.objid,
		   targetos = WebRight.obj_id.osnum );
     VDS_ERR_HNDLR ( "GRcurve.GRendpts", sts, *msg, VD_VERBOSE, wrapup );

     /* get end points of Web Left */
     sts = om$send ( msg = message GRcurve.GRendpts (
				msg,
				&WebLeft.mod_env.md_env.matrix_type,
				WebLeft.mod_env.md_env.matrix,
				wlStPt,
				wlEndPt ),
		   senderid = NULL_OBJID,
		   targetid = WebLeft.obj_id.objid,
		   targetos = WebLeft.obj_id.osnum );
     VDS_ERR_HNDLR ( "GRcurve.GRendpts", sts, *msg, VD_VERBOSE, wrapup );

     dist1 = BSdistptpt ( &rc, wrStPt, wlStPt );
     if ( rc != BSSUCC ) { sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }

     dist2 = BSdistptpt ( &rc, wrStPt, wlEndPt );
     if ( rc != BSSUCC ) { sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }

     dist3 = BSdistptpt ( &rc, wrEndPt, wlStPt );
     if ( rc != BSSUCC ) { sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }

     dist4 = BSdistptpt ( &rc, wrEndPt, wlEndPt );
     if ( rc != BSSUCC ) { sts = OM_E_ABORT; *msg = MSFAIL; goto wrapup; }

     if ( fabs ( dist1 - *webThk ) < 1.0e-06 )
     {
	centerPt[0] = (wrStPt[0] + wlStPt[0]) * 0.5;
	centerPt[1] = (wrStPt[1] + wlStPt[1]) * 0.5;
	centerPt[2] = (wrStPt[2] + wlStPt[2]) * 0.5;
     }
     else if ( fabs ( dist2 - *webThk ) < 1.0e-06 )
     {
	centerPt[0] = (wrStPt[0] + wlEndPt[0]) * 0.5;
	centerPt[1] = (wrStPt[1] + wlEndPt[1]) * 0.5;
	centerPt[2] = (wrStPt[2] + wlEndPt[2]) * 0.5;
     }
     else if ( fabs ( dist3 - *webThk ) < 1.0e-06 )
     {
	centerPt[0] = (wrEndPt[0] + wlStPt[0]) * 0.5;
	centerPt[1] = (wrEndPt[1] + wlStPt[1]) * 0.5;
	centerPt[2] = (wrEndPt[2] + wlStPt[2]) * 0.5;
     }
     else if ( fabs ( dist4 - *webThk ) < 1.0e-06 )
     {
	centerPt[0] = (wrEndPt[0] + wlEndPt[0]) * 0.5;
	centerPt[1] = (wrEndPt[1] + wlEndPt[1]) * 0.5;
	centerPt[2] = (wrEndPt[2] + wlEndPt[2]) * 0.5;
     }
     else
     {
	*msg = MSFAIL;
	printf("SFbeamToPlate[%d] : Error finding center point\n", __LINE__);
	goto wrapup;
     }

     sts = SFxformWebLineToCenter ( msg, &WebRight.obj_id, &WebRight.mod_env,
				    centerPt );
     VDS_ERR_HNDLR("SFxformWebLineToCenter", sts, *msg, VD_VERBOSE, wrapup );

     sts = SFxformFlgLineToCenter ( msg, &FlgTop.obj_id, &FlgTop.mod_env,
				    centerPt, *flgThk );
     VDS_ERR_HNDLR("SFxformFlgLineToCenter", sts, *msg, VD_VERBOSE, wrapup );

     TmpEnv.md_id.objid = ModEnv.md_id.objid;

     feFlgSurf->objid = NULL_OBJID;
     feFlgSurf->osnum = ModEnv.md_id.osnum;
     sts=SFmake_plane_segment( msg, &FlgTop, &VSbmSurf, &VSbmAxis, &cst,
				feFlgSurf);
     VDS_ERR_HNDLR("SFmake_plane_segment", sts, *msg, VD_VERBOSE, wrapup );

     feWebSurf->objid = NULL_OBJID;
     feWebSurf->osnum = ModEnv.md_id.osnum;
     sts=SFmake_plane_segment(msg, &WebRight, &VSbmSurf, &VSbmAxis, &cst,
			       feWebSurf);
     VDS_ERR_HNDLR("SFmake_plane_segment", sts, *msg, VD_VERBOSE, wrapup );

     sts = SFextendSfToSf ( msg, feWebSurf, &ModEnv, feFlgSurf, &ModEnv );
     VDS_ERR_HNDLR("SFextendSfToSf", sts, *msg, VD_VERBOSE, wrapup );

     sts = SFtrimSfToSf ( msg, feFlgSurf, &ModEnv, feWebSurf, &ModEnv );
     VDS_ERR_HNDLR("SFtrimSfToSf", sts, *msg, VD_VERBOSE, wrapup );

   }

wrapup:
   return sts;
}


long  SFxformWebLineToCenter (
 long			*msg,
 struct GRid		*WebLine,
 struct GRmd_env	*WebEnv,
 double			*CenterPt
)
{
long			sts;
BSrc			rc;
double			WebStartPt[3], WebEndPt[3],
			dist1, dist2,
			*transPt = NULL, transmx[16];
IGRshort		mxtype;
GRobjid			newobjid;

   *msg = MSSUCC;
   sts = OM_S_SUCCESS;

   sts = om$send ( msg = message GRcurve.GRendpts (
				msg,
				&WebEnv->md_env.matrix_type,
				WebEnv->md_env.matrix,
				WebStartPt,
				WebEndPt ),
		   senderid = NULL_OBJID,
		   targetid = WebLine->objid,
		   targetos = WebLine->osnum );
   VDS_ERR_HNDLR ( "GRcurve.GRendpts", sts, *msg, VD_VERBOSE, wrapup );

   /* form the transformation matrix */
   dist1 = BSdistptpt( &rc, WebStartPt, CenterPt );
   if ( rc != BSSUCC ) goto wrapup;

   dist2 = BSdistptpt( &rc, WebEndPt, CenterPt );
   if ( rc != BSSUCC ) goto wrapup;

   if ( dist1 < dist2 )
	transPt =  WebStartPt;
   else
	transPt =  WebEndPt;

   MAidmx( msg, transmx );
   transmx[3] = CenterPt[0] - transPt[0];
   transmx[7] = CenterPt[1] - transPt[1];
   transmx[11] = CenterPt[2] - transPt[2];

   MAtypemx( msg, transmx, &mxtype );

   sts = om$send ( msg = message GRgraphics.GRxform(
					msg,
					WebEnv,
					&mxtype,
					transmx,
					&newobjid ),
		    senderid = NULL_OBJID,
		    targetid = WebLine->objid,
		    targetos = WebLine->osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRxform", sts, *msg, VD_VERBOSE, wrapup );

   WebLine->objid = newobjid;

wrapup:
   return sts;
}

long SFxformFlgLineToCenter (
 long			*msg,
 struct GRid		*FlgLine,
 struct GRmd_env	*FlgLineEnv,
 IGRpoint		CenterPt,
 double			FlgThckness
)
{
long			sts;
BSrc			rc;
IGRpoint		ProjPt;
double			transmx[16], dist;
IGRshort		mxtype;
GRobjid			newobjid;
struct GRparms		loc_parms, proj_parms;

  *msg = MSSUCC;
  sts = OM_S_SUCCESS;

/*
message GRprojpt(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
        struct GRparms *locate_parms; IGRpoint point,proj_pt;
        struct GRparms *proj_parms);
*/

   loc_parms.u = 0;
   loc_parms.v = 0;
   loc_parms.polygon_inx = 0;
   loc_parms.leaf_id.objid = NULL_OBJID;
   sts = om$send ( msg = message GRvg.GRprojpt(
					msg,
					&(FlgLineEnv->md_env.matrix_type),
					FlgLineEnv->md_env.matrix,
					&loc_parms,
					CenterPt,
					ProjPt,
					&proj_parms ),
		   targetid = FlgLine->objid,
		   targetos = FlgLine->osnum,
		   senderid = NULL_OBJID );

   MAidmx( msg, transmx );

   dist = BSdistptpt( &rc, CenterPt, ProjPt );

   if ( rc != BSSUCC || dist == 0.0 )
   {
	*msg = MSFAIL;
	sts = OM_E_ABORT;
	goto wrapup;
   }

   transmx[3] = (CenterPt[0] - ProjPt[0]) * ( 0.5 * FlgThckness ) / dist;
   transmx[7] = (CenterPt[1] - ProjPt[1]) * ( 0.5 * FlgThckness ) / dist;
   transmx[11] = (CenterPt[2] - ProjPt[2]) * ( 0.5 * FlgThckness ) / dist;

   MAtypemx( msg, transmx, &mxtype );

   sts = om$send ( msg = message GRgraphics.GRxform(
					msg,
					FlgLineEnv,
					&mxtype,
					transmx,
					&newobjid ),
		    senderid = NULL_OBJID,
		    targetid = FlgLine->objid,
		    targetos = FlgLine->osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRxform", sts, *msg, VD_VERBOSE, wrapup );

   FlgLine->objid = newobjid;

wrapup:
   return sts;
}

end implementation Root;


