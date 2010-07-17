class implementation  SFCoConvBm;

/* -------------------------------------------------------------------------
   This file contains the following methods.

   Doc : PerformAcceptOp

   Description : This method performs necessary things when
		 form is accepted.

   Return status :    SF_BEAM_CONVERTED  -   some of the beams have been
					     converted before.
		      1			  -  success
   History :
   05-30-1994	Raju	Creation
-----------------------------------------------------------------------------*/

#include "stdio.h"
#include "msdef.h"
#include "msmacros.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "FI.h"

#include "grdpbmacros.h"
#include "ACrg_collect.h"

#include "vderrmacros.h"

#include "vsdef.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"

#include "APdef.h"
#include "FElimits.h"
#include "FEmacros.h"

#include "FDdef.h"
#include "FEfddef.h"
#include "FDstruct.h"
#include "FEfdstruct.h"

#include "SFdef.h"
#include "SFmsg.h"
#include "SFconvDef.h"
#include "SFconvBmDef.h"

#include "vderrmacros.h"


from GRgraphics import GRdisplay;
from NDmacro    import ACreturn_foot;
from NDmacro    import ACgive_structure;
from GRvg	import GRputsymb;
from GRgraphics import GRdelete;
from GRgraphics import GRcopy;
from GRgraphics import GRaddwrng;
from VSfeature  import VSmodUsrAttributes;
/*
from GRnotify   import GRntfyconn;
*/
from GRvg	import GRchglevel;
from GRvg	import GRchgcolor;


extern  struct  GRid		FE_struct_grid,
				FE_mpman_grid;
extern	OM_S_CHANSELECT		FEstructure_to_fd_CS,
				FEmpman_to_mat_CS,
				FEmpman_to_prop_CS;
from	FEfd	import	match_fd;
from	FEgenmp import	xpose_name;
from	FEmpman	import	match_name;

method  PerformAcceptOp( long *msg )
{

  long		status = OM_S_SUCCESS;
  int		ii;
  char		BeamName[SF_MAX_BEAMNAME_SIZE],
		MatName[FE_MAX_MPNAME_SIZE],
		PrpName[FE_MAX_MPNAME_SIZE],
		msg_buff[81];
  int		sel_flag, r_pos;
  enum GRdpmode dpmode;
  char		*name[1]  = { SF_TXT_FEM_CONVERTED };
  char		*value[1] = { "1" };    /*  can be any thing */
  struct ret_struct  attr;
  int		index = -1;
  long		check_converted,
		eltype_state;
  double	tmp;
  int		nb_elems,
  		elem_type;
  double	fem_mesh_weight = 1.0;
  struct GRid	mesh_grid; 	/* unused */
  char		BmExtractOpt[ATTR_TXT];
  short		actLvl;
  struct IGRdisplay actDisp;


	*msg = 1;

	FIg_get_state( FP_BEAM, SF_BM_CHK_CONVERTED_FLD, &check_converted );

	if ( check_converted )     /* check if any of the beams
				      have already been converted.
				      If yes, set message and return */
	{
	   for ( ii=0; ii<me->BeamCount; ii++ )
	   {
		status = om$send ( msg = message NDmacro.ACgive_structure (
					 (int *) msg,
					 &index,
					 SF_TXT_FEM_CONVERTED,
					 &attr,
					 &me->VSbeamList[ii].mod_env ),
			      targetid = me->VSbeamList[ii].obj_id.objid,
			      targetos = me->VSbeamList[ii].obj_id.osnum );

		if ( status & *msg & 1 )
		{
		   *msg = SF_BM_CONVERTED;

		   FIfld_get_text( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 0,
			      SF_MAX_BEAMNAME_SIZE, BeamName, &sel_flag,
			      &r_pos );

		   ex$message (  field		= ERROR_FIELD,
				 msgnumb	= SF_E_BmConved,
				 justification	= CENTER_JUS,
				 type		= "%s",
				 var		= `BeamName`,
				 buff		=  msg_buff );
		   FIg_set_text ( FP_BEAM, FI_MSG_FIELD, msg_buff );
		   goto quit;
		}
	   }
	}

	dp$erase_hilite ( msg = msg );

	/* get active color and display */
	{
	  int numberOfBytes, BytesReceived;

	  numberOfBytes = sizeof ( IGRshort );
	  gr$get_active_layer(	msg     = msg,
				sizbuf  = &numberOfBytes,
				buffer  = &actLvl,
				nret    = &BytesReceived );

	  numberOfBytes = sizeof ( struct IGRdisplay );
	  gr$get_active_display(msg     = msg,
				sizbuf  = &numberOfBytes,
				buffer  = &actDisp,
				nret    = &BytesReceived );
	}

	FIg_get_state( FP_BEAM, SF_BM_ELTYPE_FLD, &eltype_state );

	if ( eltype_state )
	   elem_type = LINE2;
	else
	   elem_type = LINE3;

	FIg_get_text ( FP_BEAM, SF_BM_EXTRACT_FLD, BmExtractOpt );

	dpmode = GRbd;
	for ( ii=0; ii<me->BeamCount; ii++ )
	{
            /*
             *  Something would have gone wrong while extracting
             *  centroidal axis of beam.
             *  In that case FEbeamAxisList will be NULL_OBJID.
             *  Continue if FEbeamAxisList is NULL_OBJID.
	     *  In future this info should be written to a log file.
             */
            if ( me->FEbeamAxisList[ii].objid == NULL_OBJID ) continue;

	    status = om$send( msg = message GRgraphics.GRaddwrng(
					     msg, &me->ModuleInfo ),
			      targetid = me->FEbeamAxisList[ii].objid,
			      targetos = me->FEbeamAxisList[ii].osnum);
	    if( !(status &1 ) )
	    {
		printf("Warning : adding to rtree failed, object [%d,%d]\n",
			me->FEbeamAxisList[ii].objid,
			me->FEbeamAxisList[ii].osnum );
	    }

	    status = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
				targetid = me->FEbeamAxisList[ii].objid,
				targetos = me->FEbeamAxisList[ii].osnum );

/*
OM_S_CHANSELECT notifyTOnotific;
IGRboolean	tag_connect = TRUE;
int		lis_index = OM_K_MAXINT;
om$make_chanselect ( channame      = "GRnotify.notification",
		     p_chanselect  = &notifyTOnotific );

	    status = om$send ( msg = message GRnotify.GRntfyconn(
					msg,
					&me->VSbeamList[ii].obj_id,
					&notifyTOnotific,
					&lis_index,
					&tag_connect,
					&me->VSbeamList[ii].obj_id.osnum ),
				senderid = NULL_OBJID,
				targetid = me->FEbeamAxisList[ii].objid,
				targetos = me->FEbeamAxisList[ii].osnum );
	    VDS_ERR_HNDLR("GRnotify.GRntfyconn",status,*msg,VD_VERBOSE,quit );
*/

	    /*
	     * Conitnue if Beam extraction option is "trace curves"
	     */
	    if ( !strcmp ( BmExtractOpt, SF_TXT_TRACE_CURVES ) )
	    {
	       IGRshort		layer;
	       short unsigned	color;

		/*  add user attribute "__FEMconverted" to the feature so that
		 *  in future we can know that the feature has been converted
		 */
		status = om$send (  msg = message VSfeature.VSmodUsrAttributes(
							msg,
							1,
							name,
							value ),
				targetid = me->VSbeamList[ii].obj_id.objid,
				targetos = me->VSbeamList[ii].obj_id.osnum );
		VDS_ERR_RPT("VSfeature.VSmodUsrAttributes", status, *msg,
			     VD_VERBOSE);

	       /* get layer and color for the stiffener from file and
		* change those of stifener curve
		*/

	       FIfld_get_text( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 2,
			    FE_MAX_MPNAME_SIZE, PrpName, &sel_flag, &r_pos );

	       if ( me->PrpCreateFlag[ii] )
	       {
		    status = SFgetNextLayerAndColor ( msg, &layer, &color );
		    VDS_ERR_RPT( "SFgetNextLayerAndColor", status, *msg,
								VD_VERBOSE );
		    if ( !(status&*msg&1) )
		    { layer = actLvl; color = actDisp.color; }

		    status = SFwriteToNBfile(msg,PrpName,layer,color,SF_BEAM );
		    VDS_ERR_RPT( "SFwriteToNBfile", status, *msg, VD_VERBOSE );

		} /* if ( me->BmPrpCreateFlag[ii] ) */
		else
		{
		    char found = FALSE;

		    status = SFgetLayerFromPrpName ( msg, PrpName, &layer,
						     &color, &found );
		    VDS_ERR_RPT( "SFgetLayerFromPrpName", status, *msg,
				 VD_VERBOSE );
		    if ( !(status&*msg&1) )
		    { layer = actLvl; color = actDisp.color; }

		    if ( !found )
		     status = SFwriteToNBfile(msg,PrpName,layer,color,SF_BEAM );
		    VDS_ERR_RPT( "SFwriteToNBfile", status, *msg, VD_VERBOSE );
	        }

		status = om$send ( msg = message GRvg.GRchglevel(
							msg,
							&layer),
			      targetid = me->FEbeamAxisList[ii].objid,
			      targetos = me->FEbeamAxisList[ii].osnum );
		VDS_ERR_RPT( "GRvg.GRchglevel", status, *msg, VD_VERBOSE );

		status = om$send ( msg = message GRvg.GRchgcolor(
						msg,
						NULL,
						(IGRushort *) &color),
			      targetid = me->FEbeamAxisList[ii].objid,
			      targetos = me->FEbeamAxisList[ii].osnum );
		VDS_ERR_RPT( "GRvg.GRchgcolor", status, *msg, VD_VERBOSE );

		status = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
			      targetid = me->FEbeamAxisList[ii].objid,
			      targetos = me->FEbeamAxisList[ii].osnum );
		continue;
	    }

 	    if ( !strcmp ( BmExtractOpt, SF_TXT_MESHING ) )
	    {
	       FIfld_get_text( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 1,
			    FE_MAX_MPNAME_SIZE, MatName, &sel_flag, &r_pos );

	       FIfld_get_text( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 2,
			    FE_MAX_MPNAME_SIZE, PrpName, &sel_flag, &r_pos );

	       FIfld_get_value( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 3, &tmp,
			     &sel_flag, &r_pos );
	       nb_elems = tmp;

	       status = SFmeshAndPlaceMatPrp (  msg,
						me->VSbeamList[ii].obj_id,
						&me->VSbeamList[ii].mod_env,
						me->FEbeamAxisList[ii],
						&me->ModuleInfo,
						elem_type,
						nb_elems,
						fem_mesh_weight,
						MatName,
						PrpName,
						&mesh_grid,
						NULL );
	       if ( ! (status & *msg & 1) )
	       {
		 printf("PerformAcceptOp : SFmeshAndPalceMatPrp failure\n");
		 continue;
	       }


	       /*  add user attribute "__FEMconverted" to the feature so that
		   in future we can know that the feature has been converted */

	       status = om$send (  msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
				targetid = me->VSbeamList[ii].obj_id.objid,
				targetos = me->VSbeamList[ii].obj_id.osnum );

	       if ( ! (status & *msg & 1) )
	       {
		  printf(
		    "PerformAcceptOp : VSfeature.VSmodUsrAttributes failure\n");
		  continue;
	       }

	    } /* if ( !strcmp ( BmExtractOpt, SF_TXT_MESHING ) ) */

 	    if ( !strcmp ( BmExtractOpt, SF_TXT_EQUI_PLATES ) )
	    {
	       FIfld_get_text( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 1,
			    FE_MAX_MPNAME_SIZE, MatName, &sel_flag, &r_pos );

	       status = SFconvertBeamToPlate (	msg,
						&me->VSbeamList[ii],
						MatName );
	       VDS_ERR_HNDLR ( "SFconvertBeamToPlate", status, *msg,
			       VD_VERBOSE, quit );

	       status = om$send (  msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
				targetid = me->VSbeamList[ii].obj_id.objid,
				targetos = me->VSbeamList[ii].obj_id.osnum );
	       if ( ! (status & *msg & 1) )
	       {
		  printf(
		    "PerformAcceptOp : VSfeature.VSmodUsrAttributes failure\n");
		  continue;
	       }
	    } /* if ( !strcmp ( BmExtractOpt, SF_TXT_EQUI_PLATES ) ) */
	} /* for ( ii=0; ii<me->BeamCount; ii++ ) */

quit:
   return status;

}

/* -------------------------------------------------------------------------
   Doc : PerformDeleteOp

   Description : This method performs necessary things when
		 form is cancelled.
   History :
   05-30-1994	Raju	Creation
-----------------------------------------------------------------------------*/

method  PerformDeleteOp()
{

  long		msg, ii, status = OM_S_SUCCESS;
  char		MatName[FE_MAX_MPNAME_SIZE],
		PrpName[FE_MAX_MPNAME_SIZE];
  int		sel_flag, r_pos;


	dp$erase_hilite ( msg = &msg );

	for ( ii=0; ii<me->BeamCount; ii++ )
	{
	   status = om$send( msg = message GRgraphics.GRdelete
					   ( &msg, &me->MyEnv ),
			     targetid = me->FEbeamAxisList[ii].objid,
			     targetos = me->FEbeamAxisList[ii].osnum ) ;

	   if ( me->MatCreateFlag[ii] )
	   {
		FIfld_get_text( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 1,
				FE_MAX_MPNAME_SIZE,MatName, &sel_flag, &r_pos );
		fe$delete_material( name = MatName );
	   }

	   if ( me->PrpCreateFlag[ii] )
	   {
		FIfld_get_text( FP_BEAM, SF_BM_BEAM_LIST_FLD, ii, 2,
				FE_MAX_MPNAME_SIZE,PrpName, &sel_flag, &r_pos );
		fe$delete_property( name = PrpName );
	   }

	}

  return status;

}
end implementation  SFCoConvBm;


