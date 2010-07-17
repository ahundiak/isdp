/* $Id: VSjncnstfeet.I,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjncnstfeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjncnstfeet.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.10  1998/03/04  14:56:12  pinnacle
# Replaced: vsjoint/VSjncnstfeet.I for:  by rchennup for struct
#
# Revision 1.8  1998/02/25  16:08:26  pinnacle
# Replaced: vsjoint/VSjncnstfeet.I for:  by rchennup for struct
#
# Revision 1.7  1998/01/14  22:32:26  pinnacle
# Replaced: vsjoint/VSjncnstfeet.I for:  by v250_int for struct
#
# Revision 1.6  1998/01/07  16:38:38  pinnacle
# ReCompute CoreDump
#
# Revision 1.4  1997/12/26  10:43:36  pinnacle
# Replaced: vsjoint/VSjncnstfeet.I for:  by rchennup for struct
#
# Revision 1.3  1997/11/19  08:11:56  pinnacle
# Replaced: vsjoint/VSjncnstfeet.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  13:24:32  pinnacle
# Replaced: vsjoint/VSjncnstfeet.I for:  by svkadamb for struct
#
 *
 *  History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *            suresh  modification
 *  01/06/98  ah      Fixed bad arguments to VSlinkGroup and added prototypes 
 *  01/07/98  ah      Check number of parents more carefully
 *  02/25/98  Suresh  checking if the output of strudel is jointGroup.
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class implementation VSjoint ;

#include "EMSmsgdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vsweld.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsjntmacros.h"
#include "vsjntproto.h"
#include "vsiomacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdrw.h"
#include "vsdrwdef.h"
#include "vsdrwapi.h"
#include "vsdrwproto.h"
#include "vsdrwmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"

from  ACrg_collect	import	ACadd_list_attribute;
from  ACcpx_defn	import	ACgive_name ;

extern VSdescribeJnFoot();
extern struct GRid	NULL_GRID ;

extern OMuword                  OPP_GRcurve_class_id, OPP_ACdyn_col_class_id ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*MyEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	struct GRvg_construct 	cst ;		/* My construction list	*/
	struct GRid		selList[4];
	struct GRobj_env	features[3] ;	/* Virtual parents	*/
	int			i,		/* Loop index		*/
                                indexMyId,
				jType ;
	VSdspRep		myRep ;		/* My representation	*/
	struct GRsymbology	mySymb ;	/* My symbology		*/
	VSpartAttr		part ;
	VSjointAttr		jnAttr ;

/*
	struct ret_struct       rs ;
	int			index = -1;
	int			ASrc ;
*/
	int			idx=0, weldSide ;
	struct GRid		col, tmp_obj;
	struct ACrg_coll        attr;
	IGRboolean		sdl_prc=FALSE;
	VSdrwUsrTokType         U[100];
	VSdrwAction             A[100];
	VSdrwOutputData		*output=NULL;
	char    		relPathName[MAXPATHLEN], file_path[MAXPATHLEN],
                		absPathName[MAXPATHLEN], *K[100];

#define FEATURE0	0
#define FEATURE1	1

  SetProc( VSjoint_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

  // First two parents are the features
  if( countOfInputs < 2) { 
    *msg = MSINARG ; 
    return OM_W_ABORT ; 
  }
  vs$dotsInStsFld() ;
  col.objid = NULL_OBJID;

  // Get the features
  for(i = 0; i < 2; i++) {

    sts = VSgetVirtualInfo( 
      msg, 
      &listOfInputs[i], 
      &features[i].mod_env,
      &features[i].obj_id
    );
    __CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;
    selList[i] = features[i].obj_id;
  }

  // Decide where my_id gets stored
  indexMyId = 2;

  // Do we have a graphical weld rep?
  if ((countOfInputs == 3) || (countOfInputs == 5)) {

    i = countOfInputs - 1;

    sts = VSgetVirtualInfo( 
      msg, 
      &listOfInputs[i], 
      &features[2].mod_env,
      &features[2].obj_id
    );
    __CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;
    selList[2] = features[2].obj_id;
    indexMyId = 3;
  }
  else {
    features[2].obj_id.objid = NULL_OBJID;
  }

  selList[indexMyId].objid = my_id;
  selList[indexMyId].osnum = OM_Gw_current_OS ;

  // Keep the rest of the code pretty much the same
  // Excpet for replaceing countOfInputs stuff
	sts = vs$getJunctionType(	msg		= msg,
					elToJoin1	= &features[0],
					elToJoin2	= &features[1],
					junctionType	= &jType ) ;
	__CheckRC( sts, *msg, "vs$getJunctionType", wrapup ) ;

     if( ! ( indexMyId == 3 )){
	
	vs$dotsInStsFld() ;

	sprintf( file_path, "%s/%s", VS_K_JNT_CONFIG_RELPATH, "joint_setup" );
        /*
         * Look for file in current working directory, then in product path.
         * (Beware that relative path may already have been prepended).
         */
        if( !strncmp(   file_path,
                        VS_K_JNT_CONFIG_RELPATH,
                        strlen( VS_K_JNT_CONFIG_RELPATH ) ) ) {
                strcpy( relPathName,
                        file_path + 1 + strlen( VS_K_JNT_CONFIG_RELPATH ) ) ;
        } else {
                strcpy( relPathName, file_path ) ;
        }
        VSfindFileInDirOrProductPaths(  msg,
                                        relPathName,
                                        ".",
                                        VS_K_JNT_CONFIG_RELPATH,
                                        absPathName ) ;

        if( *msg&1 )  sdl_prc = TRUE;

      }

	if( vs$is_ancestry_valid(object  = &features[2].obj_id,
                                 classid = OPP_GRcurve_class_id ) 
	    && ( countOfInputs == 3 ) )	sdl_prc = FALSE;

	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Env_info	= MyEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

        if( sdl_prc )  goto exec_strudel;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
			targetid= my_id ) ;

	part.Iwant = VS_m_All ;
	part.specific = ( void *) &jnAttr ;
	sts = om$send(  msg     = message GRvg.GRgetattr( msg,
							(char *) &part ),
			targetid= my_id );
	 __CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	weldSide = jnAttr.weldAttr.side ;

	/*
	 * Rep needs to be fixed if an expanded macro graph is being computed.
	 */
	sts = vs$fixIfNoRep( inRep = myRep, outRep = &myRep ) ;

	vs$dotsInStsFld() ;

	if( vs$is_ancestry_valid(object  = &features[2].obj_id,
                                 classid = OPP_GRcurve_class_id ) 
	    && ( countOfInputs == 3 ) ) 			{

		int			ovCount = 0 ;
                struct GRid     	grList ;
		struct IGRbsp_surface	*edGeoms  = NULL ;
		VSoverlapInfo		ovlInfo ;
		VSmatchingEdges		*ovList = NULL ;
		/*
		 * Joint geometry informatiion is available as an input 
		 * from the parent Copy support axis.
		 */
		sts = vs$grCopy(msg     = msg,
				frEnv   = &features[2].mod_env,
				frObj   = &features[2]._grid,
				toEnv   = MyEnv,
				toObj   = &grList ) ;
		__CheckRC( sts, *msg, "vs$grCopy", wrapup );
		/*
		 * Put the corrent symbology for the joint as in 
	 	 * the construction list
		 */
		sts = om$send( msg	= message GRvg.GRputsymb( msg, 
								  &mySymb ),
				targetid = grList.objid,
				targetos = grList.osnum );
		__CheckRC( sts, *msg, "GRvg.GRputsymm", wrapup );

		ovlInfo.code = VS_K_TOTAL_MATCH ;
		ovlInfo.t0start = NULL ;

		sts = vs$get_geometry(  msg     = msg,
					grobjId = &grList,
					grobjEnv= MyEnv,
					geometry= &edGeoms ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup );

		sts = VSinitMatchEntry( msg,
					&NULL_GRID,
					&NULL_GRID,
					edGeoms,
					NULL,
					&ovlInfo,
					&ovList ) ;
		_FREE( edGeoms );
		__CheckRC( sts, *msg, "VSinitMatchEntry", wrapup );

		ovCount = 1 ;

		sts = VSprocessJntMatches( msg, ovCount, ovList, &cst, 
						listOfOutputs );
		if( ovList ) VSfreeMatchList( ovList ) ;
		__CheckRC( sts, *msg, "VSprocessJntMatches", wrapup ) ;
/*
		moi.objid       = my_id ;
		moi.osnum       = OM_Gw_current_OS ;

		VSlinkGroup( msg, listOfOutputs, &moi ) ;
*/
		vs$bulk_delete( 	grids = &grList ,
					theEnv= MyEnv );
		goto wrapup ;
	}

	switch( jType ) {

	case VS_K_J_PL_PL :
		vs$dotsInStsFld() ;
		sts = om$send(	msg	= message VSjoint.VScstPlPlJoint(
								msg,
								features,
								myRep,
								&cst,
								weldSide,
								listOfOutputs ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSjoint.VScstPlPlJoint", wrapup ) ;
		break ;

	case VS_K_J_BM_PL : /* We handle here beam-plate, plate-beam,	*/
	case VS_K_J_PL_BM : /* stiffener on top of stiffened plate (and	*/
	case VS_K_J_ST_TP : /* the reverse), siffener on bottom of the	*/
	case VS_K_J_ST_BT : /* stiffened plate (and the reverse). "And	*/
	case VS_K_J_BT_ST : /* the reverse" means plate given first.	*/
	case VS_K_J_TP_ST : /*						*/
		vs$dotsInStsFld() ;
		sts = om$send(	msg	= message VSjoint.VScstPlBmJoint(
								msg,
								features,
								myRep,
								&cst,
								jType,
								weldSide,
								listOfOutputs ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSjoint.VScstPlBmJoint", wrapup ) ;

		break ;
	
	case VS_K_J_BM_BM :
		vs$dotsInStsFld() ;
		sts = om$send(	msg	= message VSjoint.VScstBmBmJoint(
								msg,
								features,
								myRep,
								&cst,
								weldSide,
								listOfOutputs ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSjoint.VScstBmBmJoint", wrapup ) ;
		break ;

	default		: vs$inv_arg() ;

	}

	*countOfOutputs = 1 ;
	__DBGpr_objlist( "Outputs", 1, listOfOutputs ) ;

	goto wrapup;

exec_strudel:
	
	vs$dotsInStsFld() ;

        K[idx]                  = "Joint-Plate-Plate";
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS( VS, userBlock );
        idx++;

        K[idx]                  = "Joint-Plate-Beam";
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS( VS, userBlock );
        idx++;

        K[idx]                  = "Joint-Beam-Beam";
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS( VS, userBlock );
        idx++;

	VSdrwAddFunctions( idx, K, U, A );

        strcpy( attr.name, "CUR_STATE" );
        attr.desc.type  = AC_ATTRIB_TEXT;

	switch( jType ) {

	case VS_K_J_PL_PL :
	        strcpy( attr.desc.value.att_txt, "Joint-Plate-Plate" );
		break;
	case VS_K_J_BM_PL :
	case VS_K_J_ST_TP :
	case VS_K_J_ST_BT :
			tmp_obj    = selList[0];
			selList[0] = selList[1];
			selList[1] = tmp_obj;
	case VS_K_J_PL_BM :
	case VS_K_J_BT_ST :
	case VS_K_J_TP_ST :
		strcpy( attr.desc.value.att_txt, "Joint-Plate-Beam");
		break;
	case VS_K_J_BM_BM :
                strcpy( attr.desc.value.att_txt, "Joint-Beam-Beam");
                break;
	default		: vs$inv_arg() ;
	}
        col.osnum       = MyEnv->md_id.osnum;
        col.objid       = NULL_OBJID;
        sts = om$construct(     classid = OPP_ACdyn_col_class_id,
                                osnum   = col.osnum,
                                p_objid = &col.objid );

        sts = om$send(  msg = message ACrg_collect.ACadd_list_attribute
                                                ( msg, 1, &attr ),
                                senderid = NULL_OBJID,
                                targetid = col.objid,
                                targetos = col.osnum );

        vs$drwExecConfig (      msg             = msg,
                                elmId           = &col,
                                elmEnv          = MyEnv,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = MyEnv,
                                drwLbsys        = NULL,
                                selCount        = indexMyId + 1,
                                selList         = selList,
                                filename        = absPathName,
				appData		= (void *)&purpose,
                                output          = &output       );

	if( output && output->set.count && output->set.list )
	{
		/*
		 * Check if the output is coming as a jointGroup macro, if so
		 * we need not construct another joint group.
		 */
		if( vs$is_ancestry_valid( object  = &output->set.list[0], 
					  classid = OPP_ACcpx_class_id )  )
		{
			struct GRid	MacroDefId ;
			char		*macName = NULL ;
			/*
			 * object might be a joint group.
			 */
			sts = om$send ( msg = message ACcpx.find_macro( 
							&MacroDefId ),
					targetid = output->set.list[0].objid,
					targetos = output->set.list[0].osnum );
			__CheckRC( sts, 1, "find_macro", wrapup );

			sts  = om$send ( msg = message ACcpx_defn.ACgive_name(
								&macName ),
					targetid = MacroDefId.objid,
					targetos = MacroDefId.osnum);
			__CheckRC( sts, 1, "ACgive_name", wrapup );

			if( strcmp ( macName , VS_K_jnJointGroup ) == 0 )
			{
				*countOfOutputs = 1 ;
				listOfOutputs[0] = output->set.list[0] ;

				goto wrapup;
			}
		}
        	sts = VSconstructGroup( msg,
                 	                &cst,
                        	        output->set.count,
                                	output->set.list,
                                	listOfOutputs ) ;
        	__CheckRC( sts, *msg, "VSconstructGroup", wrapup ) ;

		VSlinkGroup( msg, &listOfOutputs[0], &selList[indexMyId] ) ;
		*countOfOutputs = 1 ;
	}
	__DBGpr_objlist( "Outputs", 1, listOfOutputs ) ;

	wrapup :
		vs$dotsInStsFld( dots = clear ) ;
		if( sts & 1 & *msg ) {
			/*
			 * Update joint tag, don't check return code: will be
			 * OM_W_NOTTAGGED if object has no tag connection.
			 */
			om$change_tag_version() ;
		} else {
			/*
			 * Delete outputs.
			 */
			vs$bulk_delete(	count	= *countOfOutputs,
					grids	= listOfOutputs,
					theEnv	= MyEnv ) ;
			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    			sts = OM_S_SUCCESS ;
				__DBGpr_com( "I'm DEGRADED" ) ;
			}
		}

		vs$dotsInStsFld( dots = clear ) ;

		if( col.objid != NULL_OBJID )
		{
			vs$bulk_delete(	count	= 1,
					grids	= &col,
					theEnv	= MyEnv ) ;
			VSdrwRmFunctions ();
		}

		End
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSjoint ;
