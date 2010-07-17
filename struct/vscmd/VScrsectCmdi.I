/*
	I/STRUCT
*/
class implementation VScrsectCmd ;

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include "madef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "COBmacros.h"
#include "msmacros.h"
#include "growner.h"
#include "dp.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acmacros.h"
#include "acdef.h"
#include "macro.h"
#include "parametric.h"
#include "vs.h"
#include "vspart.h"
#include "vsglobalmsg.h"
#include "vsformmacros.h"
#include "vscmdmacros.h"
#include "vsdpb.h"
#include "vsprofmacros.h"
#include "vscmddef.h"
#include "vscsformdef.h"
#include "vssectiondef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "maidmx.h"
#include "bsdistptpts.h"
#include "bsdotp.h"
#include "vsexpvalue.h"
#include "vsformproto.h"
#include "vsioproto.h"


#define FORM		 0
#define NB_SECTIONS	 4
#define NB_PARMS	 5
#define CURRENT_SECTION (-1)
#define STR_SIZE	80
#define PRINT_ERROR( msgkey ) \
		VSfi_msgkeySts( me->forms[FORM].form_ptr, (msgkey) )

extern GRclassid	OPP_GRgencs_class_id,
			OPP_expression_class_id ;
static 	int	x_pos,
		y_pos,
		s_pos ;

from NDnode		import	ASreturn_go,
				NDget_objects ;
from GRgencs		import	GRgetmatrix ;
from GRvg		import	GRdetplane,
				GRgeomprops ;
from ACcreate		import	ACplace ;
from ACmacro_defn	import	ACgive_upscan ;
/*----------------------------------------------------------------------------*/
method window_notification( int form_label, event ; char *form ) {

	if( event == FI_REFRESH ) {

		/*
		 * Repaint profile that was drawn on the form. 
		 */
		om$send(msg	= message VScrsectCmd.dspProfile(
							CURRENT_SECTION ),
			targetid= my_id ) ;
	}
	return OM_S_SUCCESS ;

} /* method window_notification */
/*----------------------------------------------------------------------------*/
method initCmd() {

	me->expCount	= 0 ;
	me->last_value	= -1 ;

	if( x_pos != 0 || y_pos != 0 || s_pos != 0 ) {
		FIf_set_location( me->forms[FORM].form_ptr, x_pos, y_pos ) ;
		FIf_set_screen  ( me->forms[FORM].form_ptr, s_pos ) ;
	}
	return OM_S_SUCCESS ;

} /* method initCmd */
/*----------------------------------------------------------------------------*/
method chain_locate( int *sts ) {

	long	size = sizeof( struct GRevent ) - sizeof( IGRlong ) * 2 ; 
	long	sts1 ;
	int	response ;

	*sts = MSSUCC;

	response = me->event1.response;
	me->event1.num_id = 0 ;

	sts1 = ex$putque(	msg	= &sts1,
				byte	= &size,
				response= &response,
				buffer	= (char *) &me->event1.event ) ;
	return OM_S_SUCCESS ;

} /* method chain_locate */
/*----------------------------------------------------------------------------*/
method resetCmd( int *sts ) {

	char	library[STR_SIZE],
		*form = me->forms[FORM].form_ptr ;

	me->nbLcXs 	= 0 ;
	me->last_value	= -1 ;

	PRINT_ERROR( VS_gI_EmptyMessage ) ;

	vs$repaint_gadget( form		= form,
			   gadget	= VS_K_cs_Rectangle ) ;
	/*
	 * Set curve names.
	 */
	me->curve_type[0] = VS_K_EnvelopeCv ;
	FIfld_set_text(	form, VS_K_cs_Side_Name,
			0, 0, VSmsgkey2string( VS_gI_Interference ), FALSE ) ;

	me->curve_type[1] = VS_K_SchematicCv ;
	FIfld_set_text(	form, VS_K_cs_Side_Name,
			1, 0, VSmsgkey2string( VS_gI_Schematic ), FALSE ) ;

	me->curve_type[2] = VS_K_WoFilletCv ;
	FIfld_set_text(	form, VS_K_cs_Side_Name,
			2, 0, VSmsgkey2string( VS_gI_WithoutFillet ), FALSE ) ;

	me->curve_type[3] = VS_K_WFilletCv ;
	FIfld_set_text(	form, VS_K_cs_Side_Name,
			3, 0, VSmsgkey2string( VS_gI_WithFillet ), FALSE ) ;

	/*
	 * Set expression names.
	 */
	me->pmName[0] = VS_K_scHeight ;
	FIfld_set_text(	form, VS_K_cs_Para_Name,
			0, 0, VSmsgkey2string( VS_gI_Height ), FALSE ) ;

	me->pmName[1] = VS_K_scWidth ;
	FIfld_set_text(	form, VS_K_cs_Para_Name,
			1, 0, VSmsgkey2string( VS_gI_Width ), FALSE ) ;

	me->pmName[2] = VS_K_scFlgThk ;
	FIfld_set_text(	form, VS_K_cs_Para_Name,
			2, 0, VSmsgkey2string( VS_gI_FlgThickness ), FALSE ) ;

	me->pmName[3] = VS_K_scWebThk ;
	FIfld_set_text(	form, VS_K_cs_Para_Name,
			3, 0, VSmsgkey2string( VS_gI_WebThickness ), FALSE ) ;

	me->pmName[4] = VS_K_scFltRad ;
	FIfld_set_text(	form, VS_K_cs_Para_Name,
			4, 0, VSmsgkey2string( VS_gI_FilletRad ), FALSE ) ;

	/*
	 * Set library name.
	 */
	ac$construct_wd(mode		= AC_INQ,
			name		= library,
			name_size	= STR_SIZE ) ;
	if( !*library ) {
		ex$message( msgnumb = VS_gW_NoWkngMacLib ) ;
		library[0] = '?' ; library[1] = '\0' ;
	}

	FIfld_set_text(	form, VS_K_cs_Macro_Lib, 0, 0, library, FALSE ) ;

	/*
	 * Disable unusable gadgets.
	 */
	vs$g_disable_gadgets(	form	= form,
				list	= `FI_ACCEPT,
					   FI_EXECUTE,
					   VS_K_cs_Revert` ) ;

	VSg_replace( form, VS_K_cs_Para_Group, VS_K_cs_Crv_Group ) ; 

	FIfld_set_mode( form, VS_K_cs_Side_Name, 0, FI_REVIEW ) ;

	return OM_S_SUCCESS ;

} /* method resetCmd */
/*----------------------------------------------------------------------------*/
method refresh_form( int* sts ) {

	int	i ;
	char	*form = me->forms[FORM].form_ptr ;

	me->nbDspXs = 0 ;

	/*
	 * Enable list of profile names and revert button.
	 */
	FIfld_set_mode( form, VS_K_cs_Side_Name, 0, FI_SINGLE_SELECT ) ;

	for( i = 0 ; i < NB_SECTIONS ; i++ ) me->isXsDsp[i] = TRUE ;

	FIg_enable( form, VS_K_cs_Revert ) ;
 
	return OM_S_SUCCESS ;

} /* method refresh_form */
/*----------------------------------------------------------------------------*/
method dspPmGadgets( int *sts ) {

	int	i ;
	char	info[50],
		*form = me->forms[FORM].form_ptr ;

	me->last_value	= -1 ;

	/*
	 * Erase gadgets used to name curve sections.
	 */
	vs$repaint_gadget( form		= form,
  			   gadget	= VS_K_cs_Rectangle ) ;

	FIg_erase( form, VS_K_cs_Crv_Group ) ;

	FIfld_set_mode( form, VS_K_cs_Side_Name, 0, FI_REVIEW ) ;

	/*
	 * Init the array to know already-named expressions.
	 */
	for( i = 0 ; i < NB_PARMS ; i++ ) me->isPmDsp[i] = TRUE ;

	/*
	 * Display the first expression.
	 */
	me->nbNmExp = 1 ;

	sprintf( info, "%s=%5.2f", me->tempNm[me->nbNmExp],
				   me->expVal[me->nbNmExp] ) ;

	FIfld_set_text( form, VS_K_cs_Exp_Name, 0, 0, info, FALSE ) ;

	/*
	 * Display gadgets for expression naming.
	 */
	FIg_display( form, VS_K_cs_Para_Group ) ;

	FIfld_set_mode( form, VS_K_cs_Para_Name, 0, FI_SINGLE_SELECT ) ;

	return  OM_S_SUCCESS ;

} /* method dspPmGadgets */
/*----------------------------------------------------------------------------*/
method dspProfile( int xsNo ) {

#define weight 1
	char		 *form = me->forms[FORM].form_ptr ;
	long		 msg ;
	IGRpoint	 center ;
	struct GRobj_env located_list[NB_SECTIONS] ;

	/*
	 * If -1 is given the current profile is to be redisplayed.
	 */
	if( xsNo == CURRENT_SECTION ) {
		xsNo = me->nbDspXs ;
	}

	/*
	 * Get profiles and draw one on the form.
	 */
	om$send(msg	=  message VSlocateCmd.getLocObjs(
					&msg, NB_SECTIONS, located_list ),
		targetid= my_id ) ;
	{
		IGRboolean 	cardOpt = FALSE ;
		VScardpoint_to_vector(	&msg,
					&located_list[xsNo].mod_env,
					&located_list[xsNo]._grid,
					&cardOpt,
					VS_e_GEO_CENT,
					center );
	}

	vs$repaint_gadget( form		= form,
			   gadget	= VS_K_cs_Rectangle ) ;

	vs$draw_curve_on_form(	msg 		= &msg,
				form		= form,
				gadget		= VS_K_cs_Area,
				weight 		= weight,
				refPoint	= center,
				curveEnv	= &located_list[xsNo].mod_env,
				curveId		= &located_list[xsNo]._grid ) ;

	FIg_display( form, VS_K_cs_Area ) ;

#undef weight
	return OM_S_SUCCESS ;

} /* method dspProfile */
/*----------------------------------------------------------------------------*/
method process_fence( int *sts ) {

	int			nb_curve,
				i ;
	struct 	GRobj_env	fence,
				*Curves ;
	struct	GRlc_info	*section = me->event1.located_object ;

	fence._grid	= section->located_obj ;
	fence.mod_env	= section->module_info ;

	vs$process_fence(	msg		= &me->ret,
				fence		= &fence,
				classList	= me->locate_eligible,
				p_count		= &nb_curve,
				p_content	= &Curves,
				response	= me->response,
				response_data	= me->response_data ) ;

	if( nb_curve == NB_SECTIONS ) {

		for( i = 0 ; i < NB_SECTIONS ; i++ ) {

			om$send(msg	= message VSlocateCmd.addLocObj(
							&Curves[i]._grid,
							&Curves[i].mod_env,
							i ),
				targetid= my_id  ) ;
		}
		me->ret = VS_K_ACT_SUCCESS ;
	} else {
		/*
		 * Unhighlight if fence rejected.
		 */
		vs$bulk_display(	grids	= &section->located_obj,
					theEnv	= &section->module_info,
					dpmode	= GRhe ) ;

		PRINT_ERROR( VS_gI_InvNbCc ) ;

		me->ret = VS_K_RESTART_CMD ;
	}
	_FREE( Curves ) ;

	return OM_S_SUCCESS ;

} /* method process_fence */
/*----------------------------------------------------------------------------*/
method storeProfiles( int *sts ) {

	struct GRlc_info	*section = me->event1.located_object ;
	struct GRobj_env	located_list[NB_SECTIONS] ;
	int			i ;
	long			msg ;

	me->ret = VS_K_ACT_SUCCESS ;

	/*
	 * Redo the state until 4 different curves have been selected.
	 */
	om$send(msg	=  message VSlocateCmd.getLocObjs(
					&msg, me->nbLcXs, located_list ),
		targetid= my_id ) ;

	for( i = 0 ; i < me->nbLcXs ; i++ ) {
		if( section->located_obj.objid == located_list[i]._objid ) {
			PRINT_ERROR( VS_gI_CvAlrSel ) ;
			me->ret = VS_K_RESTART_CMD ;
		}
	}
	if( me->ret == VS_K_ACT_SUCCESS ) {
 			
		om$send(msg	= message VSlocateCmd.addLocObj(
						&section->located_obj,
						&section->module_info,
						me->nbLcXs ),
			targetid= my_id ) ;

		me->nbLcXs++ ;

		if( me->nbLcXs == NB_SECTIONS ) {
			me->nbLcXs = 0 ;
			me->ret = VS_K_ACT_SUCCESS ;
		} else 	me->ret = VS_K_RESTART_CMD ;
	}

	return OM_S_SUCCESS ;

} /* method storeProfiles */
/*----------------------------------------------------------------------------*/
method getCsAndExps( int *sts ) {

	int		rc ;
	long		msg ;
 	struct 	GRobj_env
 			section_list[NB_SECTIONS] ;
	struct 	GRid	curve_list[NB_SECTIONS],
			*buffer,
			*body_list = NULL,
			gr_obj,
			cs_id ;
	int		nb_body, 
			i,
			nb_root,
			nb_cs = 0 ;
	double		val ;
	GRclassid	obj_classid ;
	IGRmatrix 	cs_matrix ;
	GRname		path_name,
			par_name ;

	PRINT_ERROR( VS_gI_EmptyMessage ) ;

	me->expCount = 0 ;

	/*
	 * Get all the parents of the composite curves in the graph.
	 */
	rc = om$send(	msg	=  message VSlocateCmd.getLocObjs(
					&msg, NB_SECTIONS, section_list ),
			targetid= my_id ) ;
	__CheckRC( rc, msg, "getLocObjs", wrapup ) ;

	for( i = 0 ; i < NB_SECTIONS ; i++ ) {
		curve_list[i]	= section_list[i]._grid ;
		me->feet[i]	= section_list[i]._objid ;
	}

	nd$get_graph( p_tip  = curve_list, nb_tip = NB_SECTIONS );

	nd$get_list_in_graph(	acc_type = ND_BODY | ND_ROOT | ND_EXTERN,
				p_count  = &nb_body,
				buf_addr = &buffer ) ; 

	if( !nb_body ) { rc = MSFAIL ; goto wrapup ; }

	body_list = (struct GRid *) VSmemdup( buffer, nb_body * sizeof *buffer ) ;
	if( !body_list ) { rc = MSFAIL ; goto wrapup ; }

	/*
	 * Search for a coordinate system and expressions.
	 */
	for( i = 0 ; i < nb_body ; i++ ) {

		/*
		 * Find graphic object relative to associative graph.
		 */
		rc = om$send(	msg	=  message NDnode.ASreturn_go(
							&gr_obj, NULL, NULL ),
				targetid= body_list[i].objid,
				targetos= body_list[i].osnum ) ;
		__CheckRC( rc, 1, "NDnode.ASreturn_go", wrapup ) ;

		om$get_classid( osnum	  = gr_obj.osnum,
				objid	  = gr_obj.objid,
				p_classid = &obj_classid ) ;

		/*
		 * Is the element a coordinate system ?
		 */
		if( om$is_ancestry_valid(
					subclassid   = obj_classid,
					superclassid = OPP_GRgencs_class_id )
			 == OM_S_SUCCESS ) {

			nb_cs++ ;
			cs_id = body_list[i] ;

			/*
			 * Store name and objid of the coordinate system.
			 */
			me->tempNm[0] = me->tempBuf ;
			strcpy( me->tempNm[0], "cs" ) ;

			me->tmps[0] = body_list[i].objid ;

			rc = om$send(	msg	=  message GRgencs.GRgetmatrix(
							&msg, cs_matrix ),
					targetid= gr_obj.objid,
					targetos= gr_obj.osnum ) ;
			__CheckRC( rc, msg, "GRgencs.GRgetmatrix", wrapup ) ;
		}

		/*
		 * Select only root expressions -> do not use om$is_ancestry...
		 */
		if( obj_classid == OPP_expression_class_id ) {

			rc = om$send(
				msg	=  message NDnode.NDget_objects(
							ND_ROOT,
							NULL,
							NULL,
							NULL, 
							0,
							OM_K_MAXINT,
							&nb_root ),
				targetid= gr_obj.objid,
				targetos= gr_obj.osnum ) ; 
			__CheckRC( rc, 1, "NDnode.NDget_objects", wrapup ) ;

			if( nb_root == 0 ) {

				/*
				 * Find name of expression.
				 */
				msg = di$untranslate(	objname = path_name,
							objid	= gr_obj.objid,
							osnum	= gr_obj.osnum);

				if( msg == DIR_S_SUCCESS ) {
					di$split( pathname = path_name,
						  name	   = par_name ) ;
				} else {
					/*
					 * Unnamed exprssion: ignore it.
					 */
					continue ;
				}

				me->expCount++ ;

				/*
				 * Store expression name and objid.
				 */
				me->tempNm[me->expCount] = me->tempBuf + me->expCount*STR_SIZE ;
				strcpy( me->tempNm[me->expCount], par_name ) ;

				me->tmps[me->expCount] = body_list[i].objid ;

				/*
				 * Store template value.
				 */
				rc = VSexpValue( gr_obj.objid, gr_obj.osnum,
						 &val ) ;
				__CheckRC( rc, 1, "VSexpValue", wrapup ) ;

				me->expVal[me->expCount] = val ;
			}
		}
	}
	/*
	 * Check all components.
	 */
	rc = om$send(	msg	= message VScrsectCmd.chkNumCmps( nb_cs ),
			targetid = my_id ) ;
	__CheckRC( rc, 1, "chkNumCmps", wrapup ) ;

	rc = om$send(	msg	= message VScrsectCmd.areCrvsAttchdToCs( cs_id),
			targetid= my_id ) ;
	__CheckRC( rc, 1, "areCrvsAttchdToCs", wrapup ) ;

	rc = om$send(	msg	= message VScrsectCmd.isCsAtOriOfXYplane(
								 cs_matrix ),
			targetid= my_id ) ;
	__CheckRC( rc, 1, "isCsAtOriOfXYplane", wrapup ) ;

	rc = om$send(	msg	= message VScrsectCmd.areCrvsClosedInXYplane(
								 &rc ),
			targetid= my_id ) ;
	__CheckRC( rc, 1, "isCsAtOriOfXYplane", wrapup ) ;

	msg = MSSUCC ;

	wrapup :
		if( !( rc & 1 & msg ) ) {
		  me->ret = VS_K_RESTART_CMD ;

		  me->nbLcXs = 0 ;

		  om$send( msg      = message VSlocateCmd.rmLastLocObjs( 0 ),
			   targetid = my_id ) ;
		}
		_FREE( body_list ) ;

		return OM_S_SUCCESS ;

} /* method getCsAndExps */
/*----------------------------------------------------------------------------*/
method chkNumCmps( int nb_cs ) {

	long	sts ;

	sts = OM_S_SUCCESS ;

	if( nb_cs != 1 ) {
		sts = VS_K_RESTART_CMD ;
		if( nb_cs == 0 ) {
			PRINT_ERROR( VS_gI_NoCvAttToCS ) ;
		} else {
			PRINT_ERROR( VS_gI_CvAttToSevCS ) ;
		}
	}
	if( me->expCount == 0 ) {
		sts = VS_K_RESTART_CMD ;

		PRINT_ERROR( VS_gI_NoPmAttToCv ) ;
	}
			
	return sts ;

} /* method chkNumCmps */
/*----------------------------------------------------------------------------*/
method areCrvsAttchdToCs( struct GRid cs_id ) {

	long		sts,
			msg ;
	struct GRobj_env
			section_list[NB_SECTIONS] ;
	struct GRid	curve_list[NB_SECTIONS],
			curve[1],
			*body_list ;
	int		i,
			j,
			nb_body,
			cs_found ;

	sts	 = OM_S_SUCCESS ;
	cs_found = 0 ;

	/*
	 * Test if all construction curves have the same cs as parent.
	 */
	om$send(msg	=  message VSlocateCmd.getLocObjs(
					&msg, NB_SECTIONS, section_list ),
		targetid= my_id ) ;

	for( i = 0 ; i < NB_SECTIONS ; i++) {
		curve_list[i] = section_list[i]._grid ;
	}
	for( i = 0 ; i < NB_SECTIONS ; i++ ) {

		curve[0] = curve_list[i] ;

		nd$get_graph( p_tip = curve, nb_tip = 1 ) ;

		nd$get_list_in_graph(
				acc_type = ND_BODY | ND_ROOT | ND_EXTERN,
				p_count  = &nb_body,
				buf_addr = &body_list ) ; 

		for( j = 0; j < nb_body; j++ ) {

			if(   body_list[j].objid == cs_id.objid
			   && body_list[j].osnum == cs_id.osnum ) {

				cs_found++ ;
			}
		}
	}

	if( cs_found != NB_SECTIONS ) {
		sts = VS_K_RESTART_CMD ;

		PRINT_ERROR( VS_gI_NotAllCvAttToCS  ) ;
	}
	return sts ;

} /* method areCrvsAttchdToCs */
/*----------------------------------------------------------------------------*/
method isCsAtOriOfXYplane( IGRdouble *cs_matrix ) {

	long		sts,
			msg ;
	int 		i ;
	IGRmatrix	id_matrix ;

	sts = OM_S_SUCCESS ;

	/*
	 * Check if cs is at origin of xy-plane.
	 */
	MAidmx( &msg, id_matrix ) ;

	i = 0 ;
	while( i < 16 ) {

		if( id_matrix[i] != cs_matrix[i] ) {

			sts = VS_K_RESTART_CMD ;
			i = 16 ;

			PRINT_ERROR( VS_gI_CSNotAtOrig ) ;
		}
		i++ ;
	}		
	return sts ;

} /* method isCsAtOriOfXYplane */
/*----------------------------------------------------------------------------*/
method areCrvsClosedInXYplane( int *sts ) {

	struct 	GRobj_env	section_list[NB_SECTIONS] ;
	struct 	GRid		curve_list[NB_SECTIONS],
				gr_obj ;
	int			i ;
	long			rc,
				msg ;
	IGRshort		mat_type ;
	IGRmatrix		gr_matrix ;
	IGRpoint		Pt ;
	IGRvector		vector ;
	double			epsilon1,
				epsilon2 ;
	struct IGRplane 	plane ;
	struct GRprops		props ;

	rc = OM_S_SUCCESS ;

	om$send(msg	= message VSlocateCmd.getLocObjs(
					&msg, NB_SECTIONS, section_list ),
		targetid= my_id ) ;

	for( i = 0 ; i < NB_SECTIONS ; i++ ) {
		curve_list[i] = section_list[i]._grid ;
	}

	plane.point = Pt ;
	plane.normal = vector ;

	for( i = 0 ; i < NB_SECTIONS ; i++ ) {

		om$send(msg = message NDnode.ASreturn_go(
						&gr_obj, &mat_type, gr_matrix ),
			targetid = curve_list[i].objid,
			targetos = curve_list[i].osnum ) ;
		/*
	 	 * Test if all curves are planar and in xy-plane of world CS.
	 	 */

		om$send(msg	= message GRvg.GRdetplane(
					&msg, &mat_type, gr_matrix, &plane ),
			targetid = gr_obj.objid,
			targetos = gr_obj.osnum ) ;

		if( msg != MSSUCC ) {

			rc = VS_K_RESTART_CMD ;

			PRINT_ERROR( VS_gI_LocCcNotPlanar ) ;
		} else {
			IGRvector	xvect ;
			IGRpoint	origin ;

			BSEXTRACTPAR( &msg, BSTOLORTHOVEC, epsilon1 ) ;
			BSEXTRACTPAR( &msg, BSTOLSQLENVEC, epsilon2 ) ;

			xvect[0] = 1 ; xvect[1] = xvect[2] = 0 ;
			origin[0] = Pt[0] ; origin[1] = Pt[1] ; origin[2] = 0 ;

			if(    BSdotp( &msg, vector, xvect )   >= epsilon1
			    || BSdistptpts( &msg, origin, Pt ) >= epsilon2 ) {
			
				rc = VS_K_RESTART_CMD ;

				PRINT_ERROR( VS_gI_LocCcNotInXY ) ;
			}
		}
		/*
		 * Test if all curves are closed.
		 */

		om$send(msg	= message GRvg.GRgeomprops(
					&msg, &mat_type, gr_matrix, &props ),
			targetid = gr_obj.objid,
			targetos = gr_obj.osnum ) ;

		if( ! props.phy_closed ) {

			rc = VS_K_RESTART_CMD ;

			PRINT_ERROR( VS_gI_LocCcNotClosed ) ;
		}			
	}		

	return rc ;

} /* areCrvsClosedInXYplane */
/*----------------------------------------------------------------------------*/
method unhiliteCrvs( int *sts ) {

	long			msg ;
	struct 	GRobj_env	section_list[ NB_SECTIONS ] ;

	/*
	 * Get and unhighlight the selected composite curves.
	 */
	om$send(msg	= message VSlocateCmd.getLocObjs(
					&msg, NB_SECTIONS, section_list ),
		targetid = my_id ) ;

	vs$bulk_display(	objenvs	= section_list,
				count	= NB_SECTIONS,
				dpmode	= GRhe ) ;


	return OM_S_SUCCESS ;

} /* method unhiliteCrvs */
/*----------------------------------------------------------------------------*/
method dspNextPmName( int *sts ) {

	char	info[STR_SIZE],
		*form = me->forms[FORM].form_ptr ;

	/*
	 * On reject do not give name to the expression.
	 */
	if( me->nbNmExp < me->expCount+1 ) {

		me->nbNmExp++ ;

		if( me->nbNmExp < me->expCount+1 ) {

			/*
			 * Give next expression name.
			 */

			sprintf( info, "%s=%5.2f",
				 me->tempNm[me->nbNmExp],
				 me->expVal[me->nbNmExp] ) ;

			FIfld_set_text( form, VS_K_cs_Exp_Name, 0, 0, info,
					 FALSE ) ;
		} else {
			/*
		 	 * All names have been displayed.
		 	 */
			vs$g_enable_gadgets(	form	= form,
						list	= `FI_ACCEPT,
							   FI_EXECUTE` ) ;

			FIfld_set_mode( form, VS_K_cs_Para_Name, 0, FI_REVIEW );

			PRINT_ERROR( VS_gI_AllNamesSel ) ;

			me->ret = VS_K_RESTART_CMD ;
		}
	}

	return OM_S_SUCCESS ;

} /* method dspNextPmName */
/*----------------------------------------------------------------------------*/
method createMacDef( int response ) {

	long		msg ;
	int		rc ;
	int		macDefExists ;
	char		*form = me->forms[FORM].form_ptr ;
	struct GRid	macro,
			macro_def ;
	extern OMuword	OPP_ACcreate_class_id ;

	/*
	 * Create macro definition if none with the same name already exists.
	 */
	macDefExists = ac$find_macro_defn(	
				action		= ACfind_no_load,
				macro_name	= me->macro_name,
				p_macro_defn_id	= &macro_def ) ;

	if( me->macro_name[0] != '\0' && macDefExists == 0 ) {

		ex$putque( msg = &msg, response = &response ) ;

		PRINT_ERROR( VS_gI_SavingLib ) ;

		/*
	 	 * Create the macro definition.
	 	 */
		macro.osnum = me->ModuleInfo.md_id.osnum ;

		om$construct(	classid	= OPP_ACcreate_class_id,
				p_objid = &macro.objid,
				osnum 	= macro.osnum ) ;

		om$send(msg	=  message ACcreate.ACplace(
					&rc,
					ACcant_place_sym | ACminimal_graph, 
	 	 	        	me->macro_name,
					me->expCount + 1,
			        	me->tmps,
					me->tempNm,
					NB_SECTIONS,
					me->feet,
					me->feetNm),
			targetid= macro.objid,
			targetos= macro.osnum ) ;

		om$send(msg	= message Root.delete(1),
			targetid= macro.objid,
			targetos= macro.osnum ) ;

		/*
	 	 * Save the macro library.
	 	 */
		ac$save_wd() ;

		if( response == EX_BACK_UP ) {

			FIfld_set_text( form, VS_K_cs_Macro_Name, 0, 0, "",
					FALSE ) ;

			strcpy( me->macro_name, "" ) ;
		} else {
			/*
			 * Save last location of the form.
			 */
			FIf_get_location( form, &x_pos, &y_pos ) ;
			FIf_get_screen( form, &s_pos ) ;
		}
	} else if( macDefExists == 1 ) {

		PRINT_ERROR( VS_gI_MacNameAlrUsed ) ;

		FIg_reset( form, FI_ACCEPT ) ;
	} else {
		PRINT_ERROR( VS_gI_MacNameNotDef ) ;

		FIg_reset( form, FI_ACCEPT ) ;
	}

	return OM_S_SUCCESS ;

} /* method createMacDef */
/*----------------------------------------------------------------------------*/
/* ARGSUSED */
#argsused
method form_notification(	int	form_label ;
				int	gadget_label ;
				double	value ;
				char	*form_ptr ) {
	
	int		rc,
			sel_flag,
			r_pos,
			rsp ;
	long		msg ;
	char		info[STR_SIZE] ;

	PRINT_ERROR( VS_gI_EmptyMessage ) ;

	switch( gadget_label ) {

	case FI_ACCEPT			:
		ac$construct_wd(mode		= AC_INQ,
				name		= info,
				name_size	= STR_SIZE ) ;
		if( !*info ) {
			ex$message( msgnumb = VS_gW_NoWkngMacLib ) ;
			FIg_set_state_off( form_ptr, gadget_label ) ;
			break ;
		}

		om$send(msg	= message VScrsectCmd.createMacDef( TERMINATE ),
			targetid= my_id ) ;
		break ;

	case FI_EXECUTE			:
		om$send(msg	= message VScrsectCmd.createMacDef( EX_BACK_UP),
			targetid = my_id ) ;
		break ;
		
	case VS_K_cs_Revert		:
		rsp = EX_BACK_UP ;
		ex$putque( msg = &msg, response = &rsp ) ;
		break ;

	case FI_CANCEL			:
		rsp = TERMINATE ;
		ex$putque( msg = &msg, response = &rsp ) ;

		/*
		 * Save last location of the form.
		 */
		FIf_get_location( form_ptr, &x_pos, &y_pos ) ;
		FIf_get_screen( form_ptr, &s_pos ) ;
		break ;

	case VS_K_cs_Side_Name		:
	/*
	 * Naming curves by two selections.
	 */
	if(    me->isXsDsp[(int) value]
	    && value       < NB_SECTIONS
	    && me->nbDspXs < NB_SECTIONS ) {

		if( me->last_value == -1 ) {

			/* Goto AccRejName state */
			rsp = VS_K_CH_STATE ;
			ex$putque( msg = &msg, response = &rsp ) ;

			me->last_value = value ;
		} else if( me->last_value == value ) {

			me->isXsDsp[(int)value] = FALSE ;

			me->feetNm[me->nbDspXs] = me->curve_type[(int)value] ;

			me->nbDspXs++ ;

			if( me->nbDspXs < NB_SECTIONS ) {

				om$send(msg	= message VScrsectCmd.dspProfile(
								me->nbDspXs ),
				 	targetid= my_id ) ;

				/* Goto NamingCurve state */
				rsp = VS_K_LOAD_ATTR ;
				ex$putque( msg = &msg, response = &rsp ) ;
				me->last_value = -1 ;
			} else {
				/*
	 		 	 * Go to naming-expressions state.
	 		 	 */
				om$send(msg	= message VScrsectCmd.dspPmGadgets( &rc ),
					targetid = my_id ) ;
				rsp = VS_K_CH_STATE ;
				ex$putque( msg = &msg, response = &rsp ) ;
			}
		} else {
			/* Stay in the same state */
			me->last_value = value ;
		}
	} else {
		PRINT_ERROR( VS_gI_NameAlrSel ) ;
	}

	break ;

	case VS_K_cs_Para_Name		:
	/*
	 * Naming expressions (index begins at 1, 0 is for cs) by two selections
	 * on field.
	 */
	if(    me->isPmDsp[(int)value]
	    && value < NB_PARMS
	    && me->nbNmExp < me->expCount + 1 ) {

		if( me->last_value == -1 ) {

			/* Goto AccRejName state */
			rsp = VS_K_CH_STATE ;
			ex$putque( msg = &msg, response = &rsp ) ;

			me->last_value = value ;
		} else if( me->last_value == value ) {

			me->isPmDsp[(int)value] = FALSE ;

			sprintf( info, "%-13s= %s",
				 me->pmName[(int)value],
				 me->tempNm[me->nbNmExp] ) ;

			FIfld_set_text(	form_ptr, gadget_label,
					(int)value, 0, info, FALSE ) ;

			me->tempNm[me->nbNmExp] = me->pmName[(int)value] ;

			/*
		 	 * Display next expression name.
		 	 */
			om$send( msg = message VScrsectCmd.dspNextPmName( &rc ),
				targetid = my_id ) ;

			/* Goto NamingPara state */
			rsp = VS_K_CH_STATE ;
			ex$putque( msg = &msg, response = &rsp ) ;

			me->last_value = -1 ;

			if( me->nbNmExp == me->expCount + 1 ) {

				/* Goto AccRej state */
				rsp = VS_K_END_STATE ;
				ex$putque( msg = &msg, response = &rsp ) ;
			}
		} else {
			/* Stay in the same state */
			me->last_value = value ;
		}
	} else {
		PRINT_ERROR( VS_gI_PmAlrSel ) ;
	}

	break ;

	case VS_K_cs_Macro_Name	:

		FIfld_get_text( form_ptr, gadget_label, 0, 0, STR_SIZE,
				(unsigned char *) &me->macro_name[0],
				&sel_flag, &r_pos ) ;

		if( me->macro_name[0] == '\0' ) {

			PRINT_ERROR( VS_gI_MacNameNotDef ) ;
		}

		break ;

	default			: break ;

	}

	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/

end implementation VScrsectCmd;
