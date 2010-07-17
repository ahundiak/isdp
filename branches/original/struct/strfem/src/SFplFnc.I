class implementation Root;

/**************************************************************************
 Doc : SFConvertPlateAndStfnrs

 Desrciption :  This function converts plate along with its stiffeners,
		if any.

 History :

 Date	   Who       Revision	Why
 -----     ---       --------   ---
 08-30-94  raju	     2.3.1	Creation

************************************************************************/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "msmacros.h"
#include "ex.h"
#include "bserr.h"
#include "bsparameters.h"
#include "igrtypedef.h"
#include "igetypedef.h"
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

#include "ACrg_collect.h"
#include "parametric.h"

#include "vs.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "FElimits.h"

#include "EMSmsgdef.h"

#include "EMSopt.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"

#include "vderrmacros.h"

#include "SFdef.h"
#include "SFmsg.h"
#include "SFconvDef.h"
#include "SFconvStruct.h"

from  NDmacro		import	ACreturn_foot;
from  NDmacro		import	ACgive_structure;
from  GRvg		import  GRputsymb;
from  GRgraphics	import  GRdisplay;
from  VSfeature		import  VSgetSupportedElements;
from  VSfeature		import  VSgetSupports;
from  EMSsubbs		import  EMproject_curve_along_surface_normals;
from  VSfeature		import  VSmodUsrAttributes;
from  GRnotify		import	GRntfyconn;
from  GRvg		import  GRchgcolor;
from  GRvg		import  GRchglevel;
from  EMSsubbs		import	EMextend_by_dist;
from  GRgraphics	import  GRcopy;
from  GRgraphics	import  GRdelete;


long	SFConvertPlateAndStfnrs (
  long			*msg,		/* O - return status */
  struct GRid		*VSplId,	/* I - objid of the plate */
  struct SFConvOpt	*ConvOpt	/* I - conversion optins  */
)
{

long			sts;
double			offset;
char			PlateSurfOpt[ATTR_NAME],
			BmExtractOpt[ATTR_NAME];
int			ElemType,
			NbFemElem,
			ConvAllEl;
char			reffile_writable;
struct GRmd_env		*VSplEnv = NULL,
			mod_env;    /* current mod env */
struct GRsymbology	ActSymb;
struct GRvg_construct   cst;
enum GRdpmode		dpmode;
struct GRid		TmpObj,
			FEplId,
			*StfnrList = NULL,
			BeamCrv,
			mesh_grid,
			*bmMeshList = NULL;
int			index = -1,  /* unused ASSOC flag */
			ii;
struct ret_struct	rs;
char			MatType[80],
			MatGrade[80],
			MatName[FE_MAX_MPNAME_SIZE],
			PrpName[FE_MAX_MPNAME_SIZE];
char			MatCreateFlag,
			PrpCreateFlag;
int			NbStfnr,
			nb_nodes, i1;
double			*coords = NULL;
struct GRid		*PtObjs = NULL;
int			num_cvs_persf;
struct ret_struct	attr;
char			*name[1] = { SF_TXT_FEM_CONVERTED };
char			*value[1] = {"1"};  /* value can be anything */
GRobjid			proj_obj1;


  sts  = OM_S_SUCCESS;
  *msg = MSSUCC;

  __DBGpr_obj("Begin convert plate", *VSplId);

  /*
   * copy conversion options and other global parmeters
   */

  strcpy ( PlateSurfOpt, ConvOpt->PlateSurfOpt );
  offset = ConvOpt->offset;
  strcpy ( BmExtractOpt, ConvOpt->BmExtractOpt );
  ElemType = ConvOpt->ElemType;
  NbFemElem = ConvOpt->NbFemElem;
  ConvAllEl = ConvOpt->ConvAllEl;

  cst = ConvOpt->cst;
  reffile_writable = ConvOpt->reffile_writable;
  VSplEnv = &(ConvOpt->RefEnv);
  mod_env = ConvOpt->MasterEnv;
/*
  TmpModEnv = mod_env;
  TmpModEnv.md_id.objid = NULL_OBJID;
*/
  if ( !ConvAllEl )
  {
    /*
     * check if the plate has already been converted.
     * If yes, display message and return.
     */

     sts = om$send ( msg = message NDmacro.ACgive_structure (
					 (int *)msg,
					 &index,
					 SF_TXT_FEM_CONVERTED,
					 &attr,
					 VSplEnv ),
		     senderid = NULL_OBJID,
		     targetid = VSplId->objid,
		     targetos = VSplId->osnum );

     if ( sts & *msg & 1 )
     {
	/*
	 * plate has been converted.
	 * get name of the plate and display message.
	 */
	sts = om$send(  msg       = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMbrNamAttr,
					&rs, VSplEnv ),
			senderid = NULL_OBJID,
			targetid  = VSplId->objid,
			targetos  = VSplId->osnum );
	VDS_ERR_RPT ( "Getting name of plate", sts, *msg, VD_VERBOSE );

	ex$message (	field		= ERROR_FIELD,
			msgnumb		= SF_E_PlConved,
			justification	= CENTER_JUS,
			type		= "%s",
			var		= `rs.var.text_st.text_string` );

	sts = OM_S_SUCCESS;
	*msg = MSSUCC;
	goto wrapup;

     } /* if ( sts & *msg & 1 ) */
  } /* if ( !ConvAllEl ) */


  if ( !strcmp( PlateSurfOpt, SF_TXT_TOP_SURF ) )
  {
      sts = om$send( msg = message NDmacro.ACreturn_foot(
						msg,
						VS_K_plTopSfPath,
						&TmpObj,
						NULL, NULL ),
		   senderid = NULL_OBJID,
		   targetid = VSplId->objid,
		   targetos = VSplId->osnum );

      VDS_ERR_HNDLR("Getting top surface of plate",sts,*msg,VD_VERBOSE,wrapup);

      offset = 0.0;
  }
  else if ( !strcmp( PlateSurfOpt, SF_TXT_BOT_SURF) )
  {
      sts = om$send( msg = message NDmacro.ACreturn_foot(
						msg,
						VS_K_plBotSfPath,
						&TmpObj,
						NULL, NULL ),
		   senderid = NULL_OBJID,
		   targetid = VSplId->objid,
		   targetos = VSplId->osnum );

      VDS_ERR_HNDLR("Getting bot surface of plate",sts,*msg,VD_VERBOSE,wrapup);

      offset = 0.0;
  }
  else if ( !strcmp( PlateSurfOpt, SF_TXT_MID_SURF ) )
  {
      sts = om$send( msg = message NDmacro.ACreturn_foot(
						msg,
						VS_K_plTopSfPath,
						&TmpObj,
						NULL, NULL ),
		   senderid = NULL_OBJID,
		   targetid = VSplId->objid,
		   targetos = VSplId->osnum );

      VDS_ERR_HNDLR("Getting top surface of plate",sts,*msg,VD_VERBOSE,wrapup);

      /*
       * get the thickness of the plate
       */
      sts = om$send( msg = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_plThcknsAttr,
					&rs, VSplEnv ),
			senderid = NULL_OBJID,
			targetid = VSplId->objid,
			targetos = VSplId->osnum );

      VDS_ERR_HNDLR("Getting thickness of plate",sts,*msg,VD_VERBOSE,wrapup);

      offset = rs.var.root_pm_st.value * 0.5;
  }
  else if ( !strcmp( PlateSurfOpt, SF_TXT_KEYIN ) )
  {
      sts = om$send( msg = message NDmacro.ACreturn_foot(
						msg,
						VS_K_plTopSfPath,
						&TmpObj,
						NULL, NULL ),
		   senderid = NULL_OBJID,
		   targetid = VSplId->objid,
		   targetos = VSplId->osnum );

      VDS_ERR_HNDLR("Getting top surface of plate",sts,*msg,VD_VERBOSE,wrapup);
  }
  else
  {
      printf("Wrong conversion option in SFConvertPlate\n");
      goto wrapup;
  }

  vs$make_offset_surface(	msg       = msg,
				surfEnv   = VSplEnv,
				surfId    = &TmpObj,
				offset    = offset,
				isPlanar  = DONT_KNOW,
				isNatNorm = TRUE,
				cst       = &cst,
				offSurfId = &FEplId );
  VDS_ERR_HNDLR("vs$make_offset_surface",OM_S_SUCCESS,*msg,VD_VERBOSE,wrapup);

  /*
   * reduntant, but needed in some cases
   */
  ActSymb.level = cst.level;
  if ( cst.display )
  {
     ActSymb.display_attr = *(cst.display);
     sts = om$send(	msg        = message GRvg.GRputsymb( msg, &ActSymb),
			senderid = NULL_OBJID,
			targetid   = FEplId.objid,
			targetos   = FEplId.osnum);
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
			targetid = FEplId.objid,
			targetos = FEplId.osnum );

  /*
   * get the material type
   */
  sts = om$send( msg = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMatTypAttr,
					&rs, VSplEnv ),
			senderid = NULL_OBJID,
			targetid = VSplId->objid,
			targetos = VSplId->osnum );
  VDS_ERR_HNDLR("Getting mat type",sts,*msg,VD_VERBOSE,wrapup);

  strcpy( MatType, rs.var.text_st.text_string );

  __DBGpr_str("Mat type", MatType );

  /*
   * get the material grade
   */
  sts = om$send( msg = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMatGrdAttr,
					&rs, VSplEnv ),
			senderid = NULL_OBJID,
			targetid = VSplId->objid,
			targetos = VSplId->osnum );
  VDS_ERR_HNDLR("Getting mat grade",sts,*msg,VD_VERBOSE,wrapup);

  strcpy( MatGrade, rs.var.text_st.text_string );

  __DBGpr_str("Mat grade", MatGrade );

  /*  check if a material already exists with the properties. If not
   *  generate a name and create a material with the name and properties.
   */

   sts = SFgetMatName( msg, MatType, MatGrade, MatName, &MatCreateFlag);
   VDS_ERR_HNDLR("SFgetMatName", sts, *msg, VD_VERBOSE, wrapup);


   /*  check if a property already exists with the thickness. If not
    *  generate a name and create a property with the name and thickness.
    */

   sts = SFgenPlateProperty ( msg,
			      *VSplId,
			      VSplEnv,
			      PrpName,
			      &PrpCreateFlag );
   VDS_ERR_HNDLR("SFgenPlateProperty", sts, *msg, VD_VERBOSE, wrapup);

   sts = SFplaceMatOnGeom ( msg, MatName, FEplId );
   VDS_ERR_RPT("SFplaceMatOnGeom", sts, *msg, VD_VERBOSE);

   sts = SFplacePrpOnGeom ( msg, PrpName, FEplId );
   VDS_ERR_RPT("SFplacePrpOnGeom", sts, *msg, VD_VERBOSE);

   /*
    * add user attribute "__FEMconverted" attribute to the plate. This would
    * help in knowing that the plate has been converted.
    */

   if ( reffile_writable )
   {
     sts = om$send ( msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
				
		     senderid = NULL_OBJID,
		     targetid = VSplId->objid,
		     targetos = VSplId->osnum );
     VDS_ERR_RPT ( "VSfeature.VSmodUSrAttributes", sts, *msg, VD_VERBOSE );
   }


#if 0
{
OM_S_CHANSELECT notifyTOnotific;
IGRboolean	tag_connect = TRUE;
int		lis_index = OM_K_MAXINT;
om$make_chanselect ( channame      = "GRnotify.notification",
		     p_chanselect  = &notifyTOnotific );

   /*
    * Connect on notifyTOnotific channel so that we can verify
    * if there are changes to the VSplate
    */
   sts = om$send ( msg = message GRnotify.GRntfyconn(
					msg,
					VSplId,
					&notifyTOnotific,
					&lis_index,
					&tag_connect,
					&(VSplId->osnum) ),
				senderid = NULL_OBJID,
				targetid = FEplId.objid,
				targetos = FEplId.osnum );
   VDS_ERR_HNDLR( "GRnotify.GRntfyconn", sts, *msg, VD_VERBOSE, wrapup );
}
#endif

   /*
    *  Extract stiffeners if ConvOpt->ExtractStiffs is TRUE.
    */
   if ( ConvOpt->ExtractStiffs == FALSE ) goto wrapup;

   /*
    * See if there are any stiffeners attached to the plate. If yes,
    * convert them also.
    *
    * get stiffeners attached to the plate
    */
   sts = om$send ( msg = message VSfeature.VSgetSupportedElements (
			msg,
			TRUE,
			&NbStfnr,
			&StfnrList ),
		   targetid = VSplId->objid,
		   targetos = VSplId->osnum,
		   senderid = NULL_OBJID );
   VDS_ERR_HNDLR("Getting stiffners on plate", sts, *msg, VD_VERBOSE, wrapup);

   if ( NbStfnr == 0 ) /* No stiffeners */
	goto wrapup;

   __DBGpr_int( "No. of stiffeners", NbStfnr );

   for ( ii=0; ii<NbStfnr; ii++)
   {
	__DBGpr_obj ( "Stiffener object", StfnrList[ii] );

#if 0

Calling SFprojStfnrAxisOntoSurf instead of following code.

long			nb_proj;
int			count;
VSsuppList		supports;
struct GRlc_info	curve_info,
			side_info;
OM_S_OBJID		*proj_obj = NULL;

	/*
	 * get support axis of the beam
	 */
	sts = om$send ( msg = message VSfeature.VSgetSupports (
					msg,
					VSplEnv,
					&count,
					supports ),
		   targetid = StfnrList[ii].objid,
		   targetos = StfnrList[ii].osnum,
		   senderid = NULL_OBJID );
	VDS_ERR_CONTINUE("VSfeature.VSgetSupports", sts, *msg, VD_VERBOSE );

	/*
	 * get centroidal axis of the beam
	 */
/*
struct GRid		BmCentAxisId;
			TmpModEnv;  /* for constructing outside range tree * /
	sts = SFgetBeamCentroidalAxis (  msg,
					 StfnrList[ii],
					 VSplEnv,
					 &TmpModEnv,
					 &BmCentAxisId );
	VDS_ERR_CONTINUE( "SFgetBeamCentroidalAxis", sts, *msg, VD_VERBOSE );
*/
	/* project support axis onto FEplate
	 *
	 * Initialize struct curve_info and side_info for message
	 * EMSsubbs.EMproject_curve_along_surface_normals.
	 */

	curve_info.located_obj	= supports[1].obj_id;
	curve_info.module_info	= *VSplEnv;
	side_info.located_obj	= FEplId;
	side_info.module_info	= mod_env;


	/*
	 * Project curve.
	 */
	sts = om$send(
		msg = message EMSsubbs.EMproject_curve_along_surface_normals(
							&curve_info,
							&side_info,
							&cst,
							TRUE,
							TRUE,
							&nb_proj,
							&proj_obj,
							msg ),
			senderid = NULL_OBJID,
			targetid = FEplId.objid,
			targetos = FEplId.osnum );

	__DBGpr_int( "number of projections", nb_proj ) ;

	if( nb_proj < 1 )
	{
	   IGRdouble  dists_in[4], dists_out[4];
	   int	      xtend_opt;
	   GRobjid    sf_copy, extended_obj;
	   IGRdouble  chtol_db;

	   sts = om$send ( msg       = message GRgraphics.GRcopy ( 
						msg,
						&mod_env,
                                   		&mod_env,
						&sf_copy ),
			   senderid = NULL_OBJID,
			   targetid  = FEplId.objid,
			   targetos  = FEplId.osnum );
	   if(!(sts & *msg & 1))
	   {
		printf("SFConvertPlateAndStfnrs : GRgraphics.GRcopy failure\n");
		continue;
	   }

	   BSEXTRACTPAR ( msg, BSTOLCHRDHT, chtol_db );

	   dists_in[0] = dists_in[1] = dists_in[2] = dists_in[3] = 2*chtol_db;

	   xtend_opt = 	EMS_opt_extendS_deextend_if_needed |
			EMS_opt_extendS_reparametrize_surface ;

	   sts = om$send ( msg = message EMSsubbs.EMextend_by_dist (
					msg,
					&mod_env,
					dists_in,
					dists_out,
					xtend_opt,
					&extended_obj ),
			   senderid = NULL_OBJID,
			   targetid = sf_copy,
			   targetos = mod_env.md_id.osnum );
	   VDS_ERR_HNDLR("EMSsubbs.EMextend_by_disp", sts, *msg, VD_VERBOSE,
			 wrapup );

	   printf("sf_copy=[%d,], new_objid=[%d]\n",
			sf_copy, extended_obj );

	   side_info.located_obj.objid	= extended_obj;
	   side_info.located_obj.osnum	= mod_env.md_id.osnum;
	   side_info.module_info	= mod_env;

	   sts = om$send(
		msg = message EMSsubbs.EMproject_curve_along_surface_normals(
							&curve_info,
							&side_info,
							&cst,
							TRUE,
							TRUE,
							&nb_proj,
							&proj_obj,
							msg ),
			senderid = NULL_OBJID,
			targetid = extended_obj,
			targetos = mod_env.md_id.osnum );

	   sts = om$send( msg = message GRgraphics.GRdelete( msg, &mod_env),
			  senderid = NULL_OBJID,
			  targetid= extended_obj,
			  targetos= mod_env.md_id.osnum ) ;


	   if ( nb_proj < 1 )
	   {
	      printf("Stiffener name = [%s]\n", rs.var.text_st.text_string );
	      printf("Stiffener id = [%d,%d]\n", StfnrList[ii].objid,
					      StfnrList[ii].osnum  );
	      printf("SFConvertPlate : projection of curve failed\n");

	      continue ;
	   }

/*
	   sts = om$send(  msg       = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMbrNamAttr,
					&rs, VSplEnv ),
			   senderid = NULL_OBJID,
			   targetid  = StfnrList[ii].objid,
			   targetos  = StfnrList[ii].osnum );
	   VDS_ERR_RPT ( "Getting name of stiffener", sts, *msg, VD_VERBOSE );

	   sts = SFwriteToLogFile( msg, rs.var.text_st.text_string, 
				   SF_STIFFENER, StfnrList[ii] ); 

	   printf("Stiffener name = [%s]\n", rs.var.text_st.text_string );
	   printf("Stiffener id = [%d,%d]\n", StfnrList[ii].objid,
					      StfnrList[ii].osnum  );
	   printf("SFConvertPlate : projection of curve failed\n");

	   continue ;
*/

/*		if( msg == MANOMEMORY ) {
			/*
			 * No dynamic memory.
			 *
			 msg = EMS_E_NoDynamicMemory ;
			 status = OM_E_NODYNMEM ;
		} else {
			/*
			 * No solution found.
			 *
			 msg = EMS_W_NoSolution ;
			 status = OM_W_ABORT ;
		}
*/
	} /* if( nb_proj < 1 ) */

   if ( proj_obj ) free ( proj_obj );

#endif

	sts = SFprojStfnrAxisOntoSurf ( msg, 
					&FEplId,
					&mod_env,
					&StfnrList[ii],
					VSplEnv,
					&cst,
					&proj_obj1 );
	if ( !(sts & *msg & 1) ) continue;

	/*
	 * take first projection
	 */
/*
	BeamCrv.objid = proj_obj[0];
*/
	BeamCrv.objid = proj_obj1;
	BeamCrv.osnum = mod_env.md_id.osnum;

	sts = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&mod_env.md_env.matrix_type,
					mod_env.md_env.matrix,
					&dpmode,
					&mod_env.md_id ),
			senderid = NULL_OBJID,
			targetid = BeamCrv.objid,
			targetos = BeamCrv.osnum );

	/*
	 * Connect on notifyTOnotific channel so that we can verify
	 * if there are changes to the VSstiffeners
	 */
/*
	sts = om$send ( msg = message GRnotify.GRntfyconn(
					msg,
					&StfnrList[ii],
					&notifyTOnotific,
					&lis_index,
					&tag_connect,
					&(StfnrList[ii].osnum) ),
				senderid = NULL_OBJID,
				targetid = BeamCrv.objid,
				targetos = BeamCrv.osnum );
	VDS_ERR_HNDLR( "GRnotify.GRntfyconn", sts, *msg, VD_VERBOSE, wrapup );
*/

	sts = SFgenBeamProperty ( msg, StfnrList[ii],
				  PrpName, &PrpCreateFlag );
	VDS_ERR_CONTINUE("SFgenBeamProperty", sts, *msg, VD_VERBOSE);

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
			       targetid = StfnrList[ii].objid,
			       targetos = StfnrList[ii].osnum );
		VDS_ERR_RPT ( "VSfeature.VSmodUSrAttributes", sts, *msg,
			       VD_VERBOSE );
	   }

	   if ( PrpCreateFlag )
	   {
		sts = SFgetNextLayerAndColor ( msg, &layer, &color );
		VDS_ERR_RPT( "SFgetNextlayerAndColor", sts, *msg, VD_VERBOSE);
		if ( !(sts&*msg&1) ) 
			{layer = ActSymb.level; color = 1; }

		sts = SFwriteToNBfile( msg,PrpName,layer, color, SF_STIFFENER );
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
		    sts = SFwriteToNBfile(msg,PrpName,layer,color,SF_STIFFENER);
		VDS_ERR_RPT( "SFwriteToNBfile", sts, *msg, VD_VERBOSE );
	    }

	    sts = om$send ( msg = message GRvg.GRchglevel(
							msg,
							&layer),
			    senderid = NULL_OBJID,
			    targetid = BeamCrv.objid,
			    targetos = BeamCrv.osnum );
	    VDS_ERR_RPT( "GRvg.GRchglevel", sts, *msg, VD_VERBOSE );

	    sts = om$send ( msg = message GRvg.GRchgcolor(
						msg,
						NULL,
						(IGRushort *) &color),
 			    senderid = NULL_OBJID,
			    targetid = BeamCrv.objid,
			    targetos = BeamCrv.osnum );
	    VDS_ERR_RPT( "GRvg.GRchgcolor", sts, *msg, VD_VERBOSE );


	    sts = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&mod_env.md_env.matrix_type,
					mod_env.md_env.matrix,
					&dpmode,
					&mod_env.md_id ),
			senderid = NULL_OBJID,
			targetid = BeamCrv.objid,
			targetos = BeamCrv.osnum );

	   continue;
	}

	/*
	 * get the material type of beam
	 */
	sts = om$send( msg = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMatTypAttr,
					&rs, VSplEnv ),
			senderid = NULL_OBJID,
			targetid = StfnrList[ii].objid,
			targetos = StfnrList[ii].osnum );
	VDS_ERR_CONTINUE("Getting mat type", sts, *msg, VD_VERBOSE );
	strcpy( MatType, rs.var.text_st.text_string );

	__DBGpr_str( "Mat Type", MatType );

	/*
	 * get the material grade
	 */
	sts = om$send( msg = message NDmacro.ACgive_structure(
					(int *)msg, &index, VS_K_prMatGrdAttr,
					&rs, VSplEnv ),
			senderid = NULL_OBJID,
			targetid = StfnrList[ii].objid,
			targetos = StfnrList[ii].osnum );
	VDS_ERR_CONTINUE("Getting mat grade", sts, *msg, VD_VERBOSE );

	strcpy( MatGrade, rs.var.text_st.text_string );
	__DBGpr_str("Mat Grade", MatGrade );

	/*  check if a material already exists with the properties. If not
	 *  generate a name and create a material with the name and properties.
	 */

	sts = SFgetMatName( msg, MatType, MatGrade, MatName, &MatCreateFlag);
	VDS_ERR_CONTINUE("SFgetMatName", sts, *msg, VD_VERBOSE);


	if ( !strcmp( BmExtractOpt, SF_TXT_MESHING ) )
	{
	  /*
	   *  check if a property already exists for the beam . If not
	   *  generate a name and create a property for the beam.
	   */


	  sts = SFmeshAndPlaceMatPrp (  msg,
					StfnrList[ii],
					VSplEnv,
					BeamCrv,
					&mod_env,
					ElemType,
					NbFemElem,
					SF_FEM_MESH_WEIGHT,
					MatName,
					PrpName,
					&mesh_grid,
					&bmMeshList );
	  if ( !( sts & *msg & 1) )
	  {
	    if ( bmMeshList )  free ( bmMeshList );
	    bmMeshList = NULL;
	  }

	  VDS_ERR_CONTINUE("SFmeshAndPlaceMatPrp", sts, *msg, VD_VERBOSE);

	  sts = SFbmEndOffsets (    msg,
				    &BeamCrv,
				    &mod_env,
				    &mod_env,
				    &StfnrList[ii],
				    VSplEnv,
				    bmMeshList,
				    ElemType,
				    NbFemElem,
				    1.0,
				    TRUE,
				    NULL );
	  if ( bmMeshList )  free ( bmMeshList );
	  bmMeshList = NULL;

	  VDS_ERR_CONTINUE("SFbmEndOffsets", sts, *msg, VD_VERBOSE);

	  sts = SFgetNodalCoords ( msg, &mesh_grid, &nb_nodes, &coords );
	  VDS_ERR_RPT("SFgetNodalCoords", sts, *msg, VD_VERBOSE);
	  if ( !( sts & *msg & 1 ) )
	  {
	    if ( coords ) { free ( coords ); coords = NULL; }
	    continue;
	  }

	  /*
	   * Allocate memory for point objects
	   */
	  PtObjs = (struct GRid *) malloc ( sizeof( struct GRid)* nb_nodes );
	  if ( !PtObjs )
	  {
	    *msg = EMS_E_NoDynamicMemory ;
	    goto wrapup;
	  }

	  for ( i1=0; i1< nb_nodes; i1++)
	  {
	    sts = SFplacePoint ( msg, &coords[i1*3], &mod_env, &PtObjs[i1] );
	    VDS_ERR_CONTINUE("SFplacePoint", sts, *msg, VD_VERBOSE);
	  }

	  if ( coords ) { free ( coords ); coords = NULL; }

	  num_cvs_persf = nb_nodes;
	  sts = SFplaceNMedges( msg,
				1,
				&FEplId,
				&num_cvs_persf,
				PtObjs,
				&mod_env );
	  if ( PtObjs ) { free ( PtObjs ); PtObjs = NULL; }

	  VDS_ERR_CONTINUE("SFplaceNMedges", sts, *msg, VD_VERBOSE);

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
				targetid = StfnrList[ii].objid,
				targetos = StfnrList[ii].osnum );
		VDS_ERR_RPT ( "VSfeature.VSmodUSrAttributes", sts, *msg,
			       VD_VERBOSE );
	  }
	} /* if ( !strcmp( BmExtractOpt, SF_TXT_MESHING ) ) */

	if ( !strcmp(BmExtractOpt, SF_TXT_EQUI_PLATES) )
	{
	   struct GRobj_env  vsStfnrEnv;

	   vsStfnrEnv.obj_id  = StfnrList[ii];
	   vsStfnrEnv.mod_env = *VSplEnv;

	   sts = SFconvertStfnrToPlate (	msg,
						&vsStfnrEnv,
						MatName,
						&FEplId,
						&mod_env );
	   VDS_ERR_CONTINUE("SFconvertBeamToPlate",sts,*msg,VD_VERBOSE);

	   /*  add user attribute "__FEMconverted" to the feature so that
		in future we can know that the feature has been converted */
	   if ( reffile_writable )
	   {
		sts = om$send ( msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
				senderid = NULL_OBJID,
				targetid = StfnrList[ii].objid,
				targetos = StfnrList[ii].osnum );
		VDS_ERR_RPT ( "VSfeature.VSmodUSrAttributes", sts, *msg,
			       VD_VERBOSE );
	   }
	} /* ( !strcmp(BmExtractOpt, SF_TXT_EQUI_PLATES) ) */
   } /*   for ( ii=0; ii<NbStfnr, ii++) */

wrapup :
   if ( StfnrList ) free ( StfnrList );
   if ( coords ) free ( coords );
   if ( PtObjs ) free ( PtObjs );
   if ( bmMeshList )  free ( bmMeshList );

   __DBGpr_com( "End convert plate");
   return sts;
}

end implementation Root;
