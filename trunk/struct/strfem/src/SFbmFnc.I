class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"
/*
#include "OMerrordef.h"
*/
#include "msdef.h"
#include "msmacros.h"
#include "ex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "growner.h"

#include "ACrg_collect.h"

/*
#include "parametric.h"
#include "EMSmsgdef.h"
*/

#include "vderrmacros.h"

#include "vs.h"
#include "FElimits.h"

#include "SFdef.h"
#include "SFmsg.h"
#include "SFconvDef.h"
#include "SFconvStruct.h"

from  NDmacro		import	ACreturn_foot;
from  NDmacro		import	ACgive_structure;
from  GRvg		import  GRputsymb;
from  GRgraphics	import  GRdisplay;
from  VSfeature		import  VSmodUsrAttributes;
from  GRnotify		import	GRntfyconn;
from  GRvg		import GRchglevel;
from  GRvg		import GRchgcolor;

long	SFConvertBeam (
  long			*msg,		/* O - return status */
  struct GRid		*VSbmId,	/* I - objid of the beam */
  struct SFConvOpt	*ConvOpt	/* I - conversion options */
)
{
long			sts;
char			BmExtractOpt[ATTR_NAME];
int			ElemType,
			NbFemElem,
			ConvAllEl;
char			reffile_writable;
struct GRmd_env		*VSbmEnv = NULL,
			mod_env;    /* current mod env */
struct GRsymbology	ActSymb;
struct GRvg_construct   cst;
enum GRdpmode		dpmode;
int			index = -1;  /* unused ASSOC flag */
struct ret_struct	attr;
struct ret_struct	rs;
struct GRid		BmCentAxisId,
			mesh_grid,
			*bmMeshList = NULL;
char			*name[1] = { SF_TXT_FEM_CONVERTED };
char			*value[1] = {"1"};  /* value can be anything */
char			MatType[80],
			MatGrade[80],
			MatName[FE_MAX_MPNAME_SIZE],
			PrpName[FE_MAX_MPNAME_SIZE];
char			MatCreateFlag,
			PrpCreateFlag;



  sts  = OM_S_SUCCESS;
  *msg = MSSUCC;

  /*
   * copy conversion options and other global parmeters
   */
  strcpy ( BmExtractOpt, ConvOpt->BmExtractOpt );
  ElemType = ConvOpt->ElemType;
  NbFemElem = ConvOpt->NbFemElem;
  ConvAllEl = ConvOpt->ConvAllEl;

  cst = ConvOpt->cst;
  reffile_writable = ConvOpt->reffile_writable;
  VSbmEnv = &(ConvOpt->RefEnv);
  mod_env = ConvOpt->MasterEnv;

  if ( !ConvAllEl )
  {
    /*
     * check if the beam has already been converted.
     * If yes, display message and return.
     */

     sts = om$send ( msg = message NDmacro.ACgive_structure (
					 (int *)msg,
					 &index,
					 SF_TXT_FEM_CONVERTED,
					 &attr,
					 VSbmEnv ),
		     senderid = NULL_OBJID,
		     targetid = VSbmId->objid,
		     targetos = VSbmId->osnum );

     if ( sts & *msg & 1 )
     {
	/*
	 * beam has been converted.
	 * get name of the beam and display message.
	 */
	sts = om$send(  msg       = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMbrNamAttr,
					&rs, VSbmEnv ),
			senderid = NULL_OBJID,
			targetid  = VSbmId->objid,
			targetos  = VSbmId->osnum );
	VDS_ERR_RPT ( "Getting name of beam", sts, *msg, VD_VERBOSE );

	ex$message (	field		= ERROR_FIELD,
			msgnumb		= SF_E_BmConved,
			justification	= CENTER_JUS,
			type		= "%s",
			var		= `rs.var.text_st.text_string` );

	sts = OM_S_SUCCESS;
	*msg = MSSUCC;
	goto wrapup;

     } /* if ( sts & *msg & 1 ) */
  } /* if ( !ConvAllEl ) */

  /*
   * get centroidal axis of the beam
   */
  sts = SFgetBeamCentroidalAxis ( msg,
				  *VSbmId,
				  VSbmEnv,
				  &mod_env,
				  &BmCentAxisId );
  VDS_ERR_HNDLR( "SFgetBeamCentroidalAxis", sts, *msg, VD_VERBOSE, wrapup );

  /*
   * reduntant, but needed in some cases
   */
  ActSymb.level = cst.level;
  if ( cst.display )
  {
    ActSymb.display_attr = *(cst.display);

    sts = om$send(	msg        = message GRvg.GRputsymb( msg, &ActSymb),
			senderid = NULL_OBJID,
			targetid   = BmCentAxisId.objid,
			targetos   = BmCentAxisId.osnum);
    VDS_ERR_RPT("Setting the symbology", sts, *msg, VD_VERBOSE );
  }

  dpmode = GRbd;
  sts = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&mod_env.md_env.matrix_type,
					mod_env.md_env.matrix,
					&dpmode,
					&mod_env.md_id ),
			senderid = NULL_OBJID,
			targetid = BmCentAxisId.objid,
			targetos = BmCentAxisId.osnum );

  sts = SFgenBeamProperty ( msg, *VSbmId, PrpName, &PrpCreateFlag );
  VDS_ERR_HNDLR("SFgenBeamProperty", sts, *msg, VD_VERBOSE, wrapup);


#if 0
{
OM_S_CHANSELECT notifyTOnotific;
IGRboolean	tag_connect = TRUE;
int		lis_index = OM_K_MAXINT;
om$make_chanselect ( channame      = "GRnotify.notification",
		     p_chanselect  = &notifyTOnotific );
  /*
   * Connect on notifyTOnotific channel so that we can verify
   * if there are changes to the VSstiffeners
   */

  sts = om$send ( msg = message GRnotify.GRntfyconn(
					msg,
					VSbmId,
					&notifyTOnotific,
					&lis_index,
					&tag_connect,
					&(VSbmId->osnum) ),
				senderid = NULL_OBJID,
				targetid = BmCentAxisId.objid,
				targetos = BmCentAxisId.osnum );
  VDS_ERR_HNDLR("GRnotify.GRntfyconn", sts, *msg, VD_VERBOSE, wrapup );
}
#endif

  if ( !strcmp( BmExtractOpt, SF_TXT_TRACE_CURVES ) )  
  {
     IGRshort		layer;
     short unsigned	color;

    /*
     * beam extraction option is trace curves only, skip the rest.
     */
    /*
     * add user attribute "__FEMconverted" attribute to the beam.
     * This would help us in knowing that the beam has been converted.
     */
    if ( reffile_writable )
    {
	sts = om$send ( msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
			       senderid = NULL_OBJID,
			       targetid = VSbmId->objid,
			       targetos = VSbmId->osnum );
	VDS_ERR_RPT (  "VSfeature.VSmodUSrAttributes", sts, *msg,
			VD_VERBOSE );
    }

    if ( PrpCreateFlag )
    {
	sts = SFgetNextLayerAndColor ( msg, &layer, &color );
	VDS_ERR_RPT( "SFgetNextlayerAndColor", sts, *msg, VD_VERBOSE);
	if ( !(sts&*msg&1) ) 
			{layer = ActSymb.level; color = 1; }

	sts = SFwriteToNBfile ( msg, PrpName, layer, color, SF_BEAM );
	VDS_ERR_RPT( "SFwriteToNBfile", sts, *msg, VD_VERBOSE );

    } /* if ( PrpCreateFlag ) */
    else
    {
	char found = FALSE;

	sts = SFgetLayerFromPrpName ( msg, PrpName, &layer,
				      &color, &found );
	VDS_ERR_RPT( "SFgetLayerFromPrpName", sts, *msg, VD_VERBOSE );
	if ( !(sts&*msg&1) )
	{ layer = ActSymb.level; color = 1; }

	if ( !found )
	    sts = SFwriteToNBfile ( msg, PrpName, layer, color, SF_BEAM );
	VDS_ERR_RPT( "SFwriteToNBfile", sts, *msg, VD_VERBOSE );
    }

    sts = om$send ( msg = message GRvg.GRchglevel(
							msg,
							&layer),
			    senderid = NULL_OBJID,
			    targetid = BmCentAxisId.objid,
			    targetos = BmCentAxisId.osnum );
    VDS_ERR_RPT( "GRvg.GRchglevel", sts, *msg, VD_VERBOSE );

    sts = om$send ( msg = message GRvg.GRchgcolor(
						msg,
						NULL,
						(IGRushort *) &color),
 			    senderid = NULL_OBJID,
			    targetid = BmCentAxisId.objid,
			    targetos = BmCentAxisId.osnum );
    VDS_ERR_RPT( "GRvg.GRchgcolor", sts, *msg, VD_VERBOSE );


    sts = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&mod_env.md_env.matrix_type,
					mod_env.md_env.matrix,
					&dpmode,
					&mod_env.md_id ),
		senderid = NULL_OBJID,
		targetid = BmCentAxisId.objid,
		targetos = BmCentAxisId.osnum );

    goto wrapup;
  }


  /*
   * get the material type of beam
   */
  sts = om$send( msg = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMatTypAttr,
					&rs, VSbmEnv ),
			senderid = NULL_OBJID,
			targetid = VSbmId->objid,
			targetos = VSbmId->osnum );
  VDS_ERR_HNDLR("Getting mat type", sts, *msg, VD_VERBOSE, wrapup );
  strcpy( MatType, rs.var.text_st.text_string );

  __DBGpr_str( "Mat Type", MatType );

  /*
   * get the material grade
   */
  sts = om$send( msg = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMatGrdAttr,
					&rs, VSbmEnv ),
			senderid = NULL_OBJID,
			targetid = VSbmId->objid,
			targetos = VSbmId->osnum );
  VDS_ERR_HNDLR("Getting mat grade", sts, *msg, VD_VERBOSE, wrapup );

  strcpy( MatGrade, rs.var.text_st.text_string );
  __DBGpr_str("Mat Grade", MatGrade );

  /*  check if a material already exists with the properties. If not
   *  generate a name and create a material with the name and properties.
   */

  sts = SFgetMatName( msg, MatType, MatGrade, MatName, &MatCreateFlag);
  VDS_ERR_HNDLR("SFgetMatName", sts, *msg, VD_VERBOSE, wrapup);

  if ( !strcmp( BmExtractOpt, SF_TXT_MESHING ) )  
  {
    /*
     *  check if a property already exists for the beam . If not
     *  generate a name and create a property for the beam.
     */


    sts = SFmeshAndPlaceMatPrp (  	msg,
					*VSbmId,
					VSbmEnv,
					BmCentAxisId,
					&mod_env,
					ElemType,
					NbFemElem,
					SF_FEM_MESH_WEIGHT,
					MatName,
					PrpName,
					&mesh_grid,
					&bmMeshList );
    VDS_ERR_HNDLR("SFmeshAndPlaceMatPrp", sts, *msg, VD_VERBOSE, wrapup);

    /*
     * add user attribute "__FEMconverted" attribute to the beam.
     * This would help us in knowing that the beam has been converted.
     */
    if ( reffile_writable )
    {
	sts = om$send ( msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
				senderid = NULL_OBJID,
				targetid = VSbmId->objid,
				targetos = VSbmId->osnum );
	VDS_ERR_RPT ( "VSfeature.VSmodUSrAttributes", sts, *msg, VD_VERBOSE );
    }
  } /* if ( !strcmp( BmExtractOpt, SF_TXT_MESHING ) ) */

  if ( !strcmp ( BmExtractOpt, SF_TXT_EQUI_PLATES ) )
  {
     struct GRobj_env  vsBeamEnv;

	vsBeamEnv.obj_id = *VSbmId;
	vsBeamEnv.mod_env = *VSbmEnv;

	sts = SFconvertBeamToPlate ( 	msg,
					&vsBeamEnv,
					MatName );
	VDS_ERR_HNDLR ( "SFconvertBeamToPlate", sts, *msg, VD_VERBOSE, wrapup );

	if ( reffile_writable )
	{
	   sts = om$send (  msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
				senderid = NULL_OBJID,
				targetid = vsBeamEnv.obj_id.objid,
				targetos = vsBeamEnv.obj_id.osnum );
	    VDS_ERR_RPT("VSfeature.VSmodUSrAttributes", sts, *msg, VD_VERBOSE );
	}
  } /* if ( !strcmp ( BmExtractOpt, SF_TXT_EQUI_PLATES ) ) */

wrapup:
  if ( bmMeshList )  {  free ( bmMeshList );  bmMeshList = NULL;  }
  return sts;

}

end implementation Root;

