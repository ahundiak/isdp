class implementation Root;

#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "bsmdistsfsf.h"
#include "bsmdistptsf.h"
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
#include "growner.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "vderrmacros.h"
#include "FElimits.h"

#include "emssfintdef.h"
#include "nm.h"

/*
#include "gocmacros.h"
#include "dp.h"
#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
*/

extern  OMuword  OPP_NMnonmanigm_class_id;

from  EMSsurface  import  EMputLsIfNotThere;
from  GRgraphics  import  GRxform;
from  NMnonmanigm import  NMperform_boolean;
from  GRgraphics  import  GRdisplay;


long  SFconvertStfnrToPlate (
 long			*msg,
 struct GRobj_env	*vsBeam,
 char			matName[],
 struct GRid		*fePlate,
 struct GRmd_env	*fePlateEnv
)
{
long			sts, size1, size2;
struct GRid		feWebSurf, feFlgSurf;
double			flgThk, webThk;
char			sectionType, PrpCreateFlag,PrpName[FE_MAX_MPNAME_SIZE];
int			numberOfBytes, BytesReceived;
struct GRmd_env		ModEnv;
double			buff1[200],buff2[200];
struct IGRbsp_surface   *geom1 = NULL, *geom2 = NULL;
struct GRprops		props1,	props2;
IGRboolean		ex1 = FALSE, ex2 = FALSE;
int			num_dists;
IGRdouble		*paruv1 = NULL,	*paruv2 = NULL,	dist[10];
IGRpoint		*sfpt1 = NULL, *sfpt2 = NULL;
double			transmx[16];
short			mxtype;
GRobjid			newobjid;
BSrc			rc;


   __DBGpr_com ( "Entered SFconvertStfnrToPlate" );

   if ( !msg || !vsBeam || !matName || !fePlate || !fePlateEnv )
   {
	*msg = MSINARG;
	sts = OM_E_INVARG;
	goto wrapup;
   }

   *msg = MSSUCC;
   sts = OM_S_SUCCESS;

   sts = SFgenPlateGeomFromBm ( msg, &vsBeam->obj_id, &vsBeam->mod_env, 
			 	&sectionType, &feWebSurf,
			 	&feFlgSurf, &flgThk, &webThk );
   VDS_ERR_HNDLR( "SFgenPlateGeomFromBm", sts, *msg, VD_VERBOSE, wrapup );

   numberOfBytes = sizeof ( struct GRmd_env );
   gr$get_module_env  ( msg     = msg,
			sizbuf  = &numberOfBytes,
			buffer  = &ModEnv,
			nret    = &BytesReceived );

   sts = om$send( msg = message EMSsurface.EMputLsIfNotThere(
					msg, &fePlateEnv->md_env, NULL, NULL,
					NULL, NULL),
			senderid = NULL_OBJID,
			targetid = fePlate->objid,
			targetos = fePlate->osnum);
   VDS_ERR_HNDLR("EMSsurface.EMputLsIfNotThere",sts,*msg,VD_VERBOSE,wrapup );

   sts = om$send( msg = message EMSsurface.EMputLsIfNotThere(
					msg, &ModEnv.md_env, NULL, NULL,
					NULL, NULL),
			senderid = NULL_OBJID,
			targetid = feWebSurf.objid,
			targetos = feWebSurf.osnum);
   VDS_ERR_HNDLR("EMSsurface.EMputLsIfNotThere",sts,*msg,VD_VERBOSE,wrapup );

   size1 = sizeof ( buff1 );
   size2 = sizeof ( buff2 );
   sts = GRget2objgeom ( msg, fePlate, &fePlateEnv->md_env, &ex1,
			   &feWebSurf, &ModEnv.md_env, &ex2,
			   buff1, buff2,
			   &size1, &size2,
			   &geom1,  &geom2,
			   &props1, &props2  );
   /*
    * return status of above function is of IGRboolean type
    */
   if ( !( sts & *msg & 1 ) )
   {
	printf("GRget2objgeom failure\n");
	if ( sts )
	   sts = OM_S_SUCCESS;
	else
	   sts = OM_E_ABORT;
	goto wrapup;
   }

   BSmdistsfsf ( geom1, geom2, &num_dists, &paruv1, &paruv2, &sfpt1, &sfpt2,
		 dist, &rc );
   if ( rc != BSSUCC )
   {
	printf("SFconvertStfnrToPlate : BSmdistsfsf failure\n");
	*msg = MSFAIL;
	goto wrapup;
   }

   __DBGpr_int ( "no. of min. distances from BSmdistsfsf", num_dists );
   __DBGpr_dbl ( "first min. distance", dist[0] );

   if ( num_dists != 1 )
   {
	ex$message (	field   =  ERROR_FIELD,
			justification = CENTER_JUS,
			in_buff = "Error converting stiffener" );
	goto wrapup;
   }

   MAidmx( msg, transmx );

   transmx[3] = (sfpt1[0][0] - sfpt2[0][0]);
   transmx[7] = (sfpt1[0][1] - sfpt2[0][1]);
   transmx[11] = (sfpt1[0][2] - sfpt2[0][2]);

   MAtypemx( msg, transmx, &mxtype );

   sts = om$send ( msg = message GRgraphics.GRxform(
					msg,
					&ModEnv,
					&mxtype,
					transmx,
					&newobjid ),
		    senderid = NULL_OBJID,
		    targetid = feFlgSurf.objid,
		    targetos = feFlgSurf.osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRxform", sts, *msg, VD_VERBOSE, wrapup );
   feFlgSurf.objid = newobjid;

   sts = om$send ( msg = message GRgraphics.GRxform(
					msg,
					&ModEnv,
					&mxtype,
					transmx,
					&newobjid ),
		    senderid = NULL_OBJID,
		    targetid = feWebSurf.objid,
		    targetos = feWebSurf.osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRxform", sts, *msg, VD_VERBOSE, wrapup );
   feWebSurf.objid = newobjid;

   sts = SFplaceMatOnGeom ( msg, matName, feFlgSurf );
   VDS_ERR_HNDLR ( "SFplaceMatOnGeom", sts, *msg, VD_VERBOSE, wrapup );

   sts = SFplaceMatOnGeom ( msg, matName, feWebSurf );
   VDS_ERR_HNDLR ( "SFplaceMatOnGeom", sts, *msg, VD_VERBOSE, wrapup );

   sts = SFgenPlatePropFromThk ( msg, webThk, "stfnr_web",
				 PrpName, &PrpCreateFlag );
   VDS_ERR_HNDLR ( "SFgenPlatePropFromThk", sts, *msg, VD_VERBOSE, wrapup );

   sts = SFplacePrpOnGeom ( msg, PrpName, feWebSurf );
   VDS_ERR_HNDLR ( "SFplacePrpOnGeom", sts, *msg, VD_VERBOSE, wrapup );

   sts = SFgenPlatePropFromThk ( msg, flgThk, "stfnr_flg",
				 PrpName, &PrpCreateFlag );
   VDS_ERR_HNDLR ( "SFgenPlatePropFromThk", sts, *msg, VD_VERBOSE, wrapup );

   sts = SFplacePrpOnGeom ( msg, PrpName, feFlgSurf );
   VDS_ERR_HNDLR ( "SFplacePrpOnGeom", sts, *msg, VD_VERBOSE, wrapup );

 {
   IGRlong			error_codes[10];
   struct GRvg_construct	cst;
   struct GRid			nmid;
   IGRushort			boolopt;
   enum NMbooltype		bool_type;
   IGRshort			level;
   struct IGRdisplay		disp;
   enum GRdpmode		dpmode = GRbd;


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
   cst.msg      = msg;
   cst.env_info = &ModEnv;
   cst.display  = &disp;
   cst.geometry = NULL;
   cst.newflag  = FALSE;
   cst.level    = level;
   cst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
   cst.class_attr = NULL;
   cst.name       = NULL;

   nmid.osnum = ModEnv.md_id.osnum;
   sts = om$construct(  classid = OPP_NMnonmanigm_class_id,
			p_objid = &nmid.objid,
			osnum = nmid.osnum);
   VDS_ERR_HNDLR ( "om$construct", sts, MSSUCC, VD_VERBOSE, wrapup );

   boolopt = EMSsfbool_opt_display | EMSsfbool_opt_HandleStop;

   bool_type =  NMbool_split;

   sts = om$send(msg = message NMnonmanigm.NMperform_boolean(
		 msg,
	         error_codes,
                 &cst,
                 *fePlate, 			/* vol_op */
                 fePlateEnv, 			/* volenv */
                 1,				/* num_nmop */
                 &feWebSurf,			/* nm_op */
                 &ModEnv, 			/* nmop_env -- use volenv */
                 bool_type,			/* bool_type */
                 boolopt, 			/* options */
                 "Creating NM boolean..", 
                 NULL,
                 NULL), 
	targetid = nmid.objid,
	targetos = nmid.osnum,
	senderid = NULL_OBJID  );
   VDS_ERR_HNDLR("NMnonmanigm.NMperform_boolean",sts,*msg,VD_VERBOSE,wrapup);

   nmid.osnum = ModEnv.md_id.osnum;
   sts = om$construct(  classid = OPP_NMnonmanigm_class_id,
			p_objid = &nmid.objid,
			osnum = nmid.osnum);
   VDS_ERR_HNDLR ( "om$construct", sts, MSSUCC, VD_VERBOSE, wrapup );

   sts = om$send(msg = message NMnonmanigm.NMperform_boolean(
		 msg,
	         error_codes,
                 &cst,
                 feWebSurf, 			/* vol_op */
                 &ModEnv, 			/* volenv */
                 1,				/* num_nmop */
                 &feFlgSurf,			/* nm_op */
                 &ModEnv, 			/* nmop_env -- use volenv */
                 bool_type,			/* bool_type */
                 boolopt, 			/* options */
                 "Creating NM boolean..", 
                 NULL,
                 NULL), 
	targetid = nmid.objid,
	targetos = nmid.osnum,
        senderid = NULL_OBJID  );
   VDS_ERR_HNDLR("NMnonmanigm.NMperform_boolean",sts,*msg,VD_VERBOSE,wrapup);

   sts = om$send ( msg = message GRgraphics.GRdisplay (
						msg,
						&ModEnv.md_env.matrix_type,
						ModEnv.md_env.matrix,
						&dpmode,
						&ModEnv.md_id ),
		   targetid = feWebSurf.objid,
		   targetos = feWebSurf.osnum,
		   senderid = NULL_OBJID  );

   sts = om$send ( msg = message GRgraphics.GRdisplay (
						msg,
						&ModEnv.md_env.matrix_type,
						ModEnv.md_env.matrix,
						&dpmode,
						&ModEnv.md_id ),
		   targetid = feFlgSurf.objid,
		   targetos = feFlgSurf.osnum,
		   senderid = NULL_OBJID  );
 }

wrapup:
   if ( (double *)geom1 != buff1 )  free ( geom1 );
   if ( (double *)geom2 != buff2 )  free ( geom2 );
   if ( paruv1 ) free ( paruv1 );
   if ( paruv2 ) free ( paruv2 );
   if ( sfpt1 ) free ( sfpt1 );
   if ( sfpt2 ) free ( sfpt2 );
   return sts;

}

end implementation Root;
