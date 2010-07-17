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

from  GRgraphics  import  GRdisplay;
from  NMnonmanigm import  NMperform_boolean;


long  SFconvertBeamToPlate (
 long			*msg,
 struct GRobj_env	*vsBeam,
 char			matName[]
)
{
long			sts;
struct GRid		feWebSurf, feFlgSurf;
double			flgThk, webThk;
char			sectionType, PrpCreateFlag,PrpName[FE_MAX_MPNAME_SIZE];
int			numberOfBytes, BytesReceived;
struct GRmd_env		ModEnv;

   __DBGpr_com ( "Entered SFconvertStfnrToPlate" );

   if ( !msg || !vsBeam || !matName )
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

   sts = SFplaceMatOnGeom ( msg, matName, feFlgSurf );
   VDS_ERR_HNDLR ( "SFplaceMatOnGeom", sts, *msg, VD_VERBOSE, wrapup );

   sts = SFplaceMatOnGeom ( msg, matName, feWebSurf );
   VDS_ERR_HNDLR ( "SFplaceMatOnGeom", sts, *msg, VD_VERBOSE, wrapup );

   sts = SFgenPlatePropFromThk ( msg, webThk, "beam_web", 
				 PrpName, &PrpCreateFlag );
   VDS_ERR_HNDLR ( "SFgenPlatePropFromThk", sts, *msg, VD_VERBOSE, wrapup );

   sts = SFplacePrpOnGeom ( msg, PrpName, feWebSurf );
   VDS_ERR_HNDLR ( "SFplacePrpOnGeom", sts, *msg, VD_VERBOSE, wrapup );

   sts = SFgenPlatePropFromThk ( msg, flgThk, "beam_flange",
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
                 feFlgSurf, 			/* vol_op */
                 &ModEnv, 			/* volenv */
                 1,				/* num_nmop */
                 &feWebSurf,			/* nm_op */
                 &ModEnv, 			/* nmop_env -- use volenv */
                 bool_type,			/* bool_type */
                 boolopt, 			/* options */
                 "Creating NM..", 
                 NULL,
                 NULL), 
	targetid = nmid.objid,
	targetos = nmid.osnum,
        senderid = NULL_OBJID  );
   VDS_ERR_HNDLR("NMnonmanigm.NMperform_boolean", sts, *msg, VD_VERBOSE, wrapup );

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
   return sts;

}

end implementation Root;
