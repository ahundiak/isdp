class implementation  SFCoStfndPl;

/* -------------------------------------------------------------------------
   This file contains the following methods

   Doc : PlacePlateAtBot

   Description : This method places FEM plate and beam axes at bottom of
		 STRUCT plate.
   History :
   06-16-1994	Raju	Creation
------------------------------------------------------------------------- */
#include "stdio.h"
#include "ex.h"
#include "msdef.h"
#include "msmacros.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "FI.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"

#include "grdpbmacros.h"
#include "ACrg_collect.h"

#include "vderrmacros.h"

#include "vsdef.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vs.h"

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
#include "SFstfndPlDef.h"


from GRgraphics import GRdisplay;
from GRvg	import GRchglevel;
from GRvg	import GRchgcolor;
from NDmacro    import ACreturn_foot;
from NDmacro    import ACgive_structure;
from GRvg	import GRputsymb;
from GRgraphics import GRdelete;
from GRgraphics import GRcopy;
from GRgraphics import GRaddwrng;
from VSfeature  import VSmodUsrAttributes;
from GRnotify   import GRntfyconn;
from EMSsubbs	import EMproject_curve_along_surface_normals;
from VSfeature  import VSgetSupports;


extern  struct  GRid		FE_struct_grid,
				FE_mpman_grid;
extern	OM_S_CHANSELECT		FEstructure_to_fd_CS,
				FEmpman_to_mat_CS,
				FEmpman_to_prop_CS;
from	FEfd	import	match_fd;
from	FEgenmp import	xpose_name;
from	FEmpman	import	match_name;

method  PlacePlateAtBot ()
{
long			msg, status = OM_S_SUCCESS, nb_proj;
int			ii, jj, BeamNb, count;
enum   GRdpmode		dpmode;
struct GRsymbology	ActSymb;
struct GRid		TmpObj,
			offSfId;
struct GRvg_construct	cst;
VSsuppList		supports;
struct GRlc_info	curve_info,
			side_info;
OM_S_OBJID		*proj_obj = NULL;
double			offset;
GRobjid			proj_obj1;



#ifdef SF_PLATE_DBG
  printf("Entered SFCoStfndPl.PlacePlateAtBot\n");
#endif

  dp$erase_hilite( msg = &msg);

  ActSymb.display_attr = me->ActiveDisplay;
  ActSymb.level        = me->ActiveLevel;

  cst.msg	 = &msg;
  cst.env_info	 = &me->MyEnv;
  cst.level	 = me->ActiveLevel;
  cst.display	 = &me->ActiveDisplay;
  cst.newflag    = FALSE;
  cst.geometry   = NULL;
  cst.class_attr = NULL;
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cst.name       = NULL;

  /* get the bottom surface of the plates  and display them in highlight mode */
  BeamNb = -1;
  dpmode = GRhd;
  for( ii=0; ii < me->PlateCount; ii++ )
  {
      if ( me->FEplateList[ii].objid != NULL_OBJID )
      {
	 status = om$send( msg = message GRgraphics.GRdelete(&msg, &me->MyEnv),
			    targetid= me->FEplateList[ii].objid,
			    targetos= me->FEplateList[ii].osnum ) ;

	 me->FEplateList[ii].objid = NULL_OBJID;
      }

      status = om$send( msg = message NDmacro.ACreturn_foot(
						&msg,
						VS_K_plBotSfPath,
						&TmpObj,
						NULL, NULL ),
		targetid = me->VSplateList[ii].obj_id.objid,
		targetos = me->VSplateList[ii].obj_id.osnum );

      if ( !(status & msg & 1) )
      {
	printf
	("PlacePlateAtBot : Can not get bottom surface for plate [%d,%d]\n",
			me->VSplateList[ii].obj_id.objid,
			me->VSplateList[ii].obj_id.osnum );
	continue;
      }

#ifdef SF_PLATE_DBG
      printf("\tBottom surface : [%d,%d]\n", TmpObj.objid, TmpObj.osnum );
#endif

      offset = 0.0;
      vs$make_offset_surface(   msg       = &msg,
				surfEnv   = &me->VSplateList[ii].mod_env,
				surfId    = &TmpObj,
				offset    = offset,
				isPlanar  = DONT_KNOW,
				isNatNorm = TRUE,
				cst       = &cst,
				offSurfId = &offSfId );
      if ( ! ( 1 & msg ) )
      {
	printf("PlacePlateAtBot : vs$make_offset_surface failure\n");
	continue;
      }

#ifdef SF_PLATE_DBG
      printf("OffSfId : [%d,%d]\n", offSfId.objid, offSfId.osnum );
#endif
      me->FEplateList[ii] = offSfId;

      /* reduntant, but needed in some cases */
      status = om$send( msg        = message GRvg.GRputsymb( &msg, &ActSymb),
			targetid   = me->FEplateList[ii].objid,
			targetos   = me->FEplateList[ii].osnum);
      if(!(status & msg & 1)) printf("Warning : Setting the symbology\n");


/*
      status = om$send ( msg = message GRgraphics.GRcopy ( &msg, 
				&me->VSplateList[ii].mod_env,
				&me->MyEnv, &me->FEplateList[ii].objid ),
			targetid = TmpObj.objid,
			targetos = TmpObj.osnum );
      if ( ! ( status & msg & 1 ) )
      {
	printf("PlacePlateAtBot : GRgraphics.GRcopy failure\n");
	continue;
      }
      me->FEplateList[ii].osnum = me->MyEnv.md_id.osnum;

      status = om$send( msg = message GRvg.GRputsymb( &msg, &ActSymb),
				targetid = me->FEplateList[ii].objid,
				targetos = me->FEplateList[ii].osnum);
      if(!(status & msg & 1)) printf("Warning when setting the symbology\n");
*/
      status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->ModuleInfo.md_env.matrix_type,
			me->ModuleInfo.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->FEplateList[ii].objid,
		     targetos = me->FEplateList[ii].osnum );

      /* extract beam support axes and project them onto fem plates */
      for ( jj=0; jj<me->BeamsOnPl[ii]; jj++ )
      {
	BeamNb++;
	if ( me->FEbeamAxisList[BeamNb].objid != NULL_OBJID )
	{
	   status = om$send( msg = message GRgraphics.GRdelete(
							&msg, &me->MyEnv),
			    targetid= me->FEbeamAxisList[BeamNb].objid,
			    targetos= me->FEbeamAxisList[BeamNb].osnum ) ;
	}

#if 0
New calling SFprojStfnrAxisOntoSurf
	/* get support axis of the beam */
	status = om$send ( msg = message VSfeature.VSgetSupports (
					&msg,
					&me->VSbeamList[BeamNb].mod_env,
					&count,
					supports ),
		   targetid = me->VSbeamList[BeamNb].obj_id.objid
		   targetos = me->VSbeamList[BeamNb].obj_id.osnum,
		   senderid = NULL_OBJID );
	if ( !( status & msg & 1 ) )
	{
	  printf("??? : Error VSfeature.VSgetSupports\n");
	  goto wrapup;
	}

	/* project support axis onto FEplate */
	/*
	 * Initialize struct curve_info and side_info for message
	 * EMSsubbs.EMproject_curve_along_surface_normals.
	 */

	curve_info.located_obj	= supports[1].obj_id ;
	curve_info.module_info	= me->VSplateList[ii].mod_env;
	side_info.located_obj	= me->FEplateList[ii];
	side_info.module_info	= me->MyEnv ;

	/*
	 * Project curve.
	 */
	status = om$send(
		msg = message EMSsubbs.EMproject_curve_along_surface_normals(
							&curve_info,
							&side_info,
							&cst,
							TRUE,
							TRUE,
							&nb_proj,
							&proj_obj,
							&msg ),
			targetid = me->FEplateList[ii].objid,
			targetos = me->FEplateList[ii].osnum );

#ifdef  SF_PLATE_DBG
	printf( "number of projections : [%d]\n", nb_proj ) ;
#endif

	if( nb_proj < 1 ) {
		me->FEbeamAxisList[BeamNb].objid = NULL_OBJID ;
/*		if( msg == MANOMEMORY ) {
*/			/*
			 * No dynamic memory.
			 */
/*			 msg = EMS_E_NoDynamicMemory ;
			 status = OM_E_NODYNMEM ;
		} else {
*/			/*
			 * No solution found.
			 */
/*			 msg = EMS_W_NoSolution ;
			 status = OM_W_ABORT ;
		}
*/		continue ;
	}
	/* take first projection */
	me->FEbeamAxisList[BeamNb].objid = proj_obj[0];
#endif
	status = SFprojStfnrAxisOntoSurf(  
					&msg,
					&me->FEplateList[ii],
					&me->MyEnv,
					&me->VSbeamList[BeamNb].obj_id,
					&me->VSbeamList[BeamNb].mod_env,
					&cst,
					&proj_obj1 );
	if ( !(status & msg &1) )  continue;

	me->FEbeamAxisList[BeamNb].objid = proj_obj1;
	me->FEbeamAxisList[BeamNb].osnum = me->MyEnv.md_id.osnum;

	if ( proj_obj ) free ( proj_obj );

	status = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&me->MyEnv.md_env.matrix_type,
					me->MyEnv.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
		     targetid = me->FEbeamAxisList[BeamNb].objid,
		     targetos = me->FEbeamAxisList[BeamNb].osnum );
      }

  }

wrapup:
  return status;
}

/* -------------------------------------------------------------------------
   Doc : PlacePlateAtTop

   Description : This method places FEM plate and beam axes at top of
		 STRUCT plate.
   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
method  PlacePlateAtTop ()
{
long			msg, status = OM_S_SUCCESS, nb_proj;
int			ii, jj, BeamNb, count;
enum   GRdpmode		dpmode;	
struct GRsymbology	ActSymb;
struct GRid		TmpObj,
			offSfId;
struct GRvg_construct	cst;
VSsuppList		supports;
struct GRlc_info	curve_info,
			side_info;
OM_S_OBJID		*proj_obj = NULL;
double			offset;



#ifdef SF_PLATE_DBG
  printf("Entered SFCoConvPl.PlacePlateAtTop\n");
#endif

  dp$erase_hilite( msg = &msg );

  ActSymb.display_attr = me->ActiveDisplay;
  ActSymb.level        = me->ActiveLevel;

  cst.msg	 = &msg;
  cst.env_info	 = &me->MyEnv;
  cst.level	 = me->ActiveLevel;
  cst.display	 = &me->ActiveDisplay;
  cst.newflag    = FALSE;
  cst.geometry   = NULL;
  cst.class_attr = NULL;
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cst.name       = NULL;

  /* get the top surface of the plates  and display them in highlight mode */
  BeamNb = -1;
  dpmode = GRhd;
  for( ii=0; ii < me->PlateCount; ii++ )
  {
      if ( me->FEplateList[ii].objid != NULL_OBJID )
      {   
	 status = om$send( msg = message GRgraphics.GRdelete(&msg, &me->MyEnv),
			    targetid= me->FEplateList[ii].objid,
			    targetos= me->FEplateList[ii].osnum ) ;

	 me->FEplateList[ii].objid = NULL_OBJID;
      }

      status = om$send( msg = message NDmacro.ACreturn_foot(
						&msg,
						VS_K_plTopSfPath,
						&TmpObj,
						NULL, NULL ),
		   targetid = me->VSplateList[ii].obj_id.objid,
		   targetos = me->VSplateList[ii].obj_id.osnum );

      if ( !(status & msg & 1) )
      {
	printf("PlacePlateAtTop :Error getting top surface for plate [%d,%d]\n",
			me->VSplateList[ii].obj_id.objid,
			me->VSplateList[ii].obj_id.osnum );
	continue;
      }

#ifdef SF_PLATE_DBG
      printf("\tTop surface : [%d,%d]\n", TmpObj.objid, TmpObj.osnum );
#endif

      offset = 0.0;
      vs$make_offset_surface(   msg       = &msg,
				surfEnv   = &me->VSplateList[ii].mod_env,
				surfId    = &TmpObj,
				offset    = offset,
				isPlanar  = DONT_KNOW,
				isNatNorm = TRUE,
				cst       = &cst,
				offSurfId = &offSfId );
      if ( ! ( 1 & msg ) )
      {
	printf("PlacePlateAtTop : vs$make_offset_surface failure\n");
	continue;
      }

#ifdef SF_PLATE_DBG
      printf("OffSfId : [%d,%d]\n", offSfId.objid, offSfId.osnum );
#endif
      me->FEplateList[ii] = offSfId;
/*
      status = om$send ( msg = message GRgraphics.GRcopy ( &msg, 
				&me->VSplateList[ii].mod_env,
				&me->MyEnv, &me->FEplateList[ii].objid ),
			targetid = TmpObj.objid,
			targetos = TmpObj.osnum );
      if ( ! ( status & msg & 1 ) )
      {
	printf("PlacePlateAtTop : GRgraphics.GRcopy failure\n");
	continue;
      }
      me->FEplateList[ii].osnum = me->MyEnv.md_id.osnum;
*/
      status = om$send( msg = message GRvg.GRputsymb( &msg, &ActSymb),
				targetid = me->FEplateList[ii].objid,
				targetos = me->FEplateList[ii].osnum);
      if(!(status & msg & 1)) printf("Warning when setting the symbology\n");


      status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->ModuleInfo.md_env.matrix_type,
			me->ModuleInfo.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->FEplateList[ii].objid,
		     targetos = me->FEplateList[ii].osnum );
      /* extract beam support axes and project them onto fem plates */
      for ( jj=0; jj<me->BeamsOnPl[ii]; jj++ )
      {
	BeamNb++;
	if ( me->FEbeamAxisList[BeamNb].objid != NULL_OBJID )
	{
	   status = om$send( msg = message GRgraphics.GRdelete(
							&msg, &me->MyEnv),
			    targetid= me->FEbeamAxisList[BeamNb].objid,
			    targetos= me->FEbeamAxisList[BeamNb].osnum ) ;
	}

	/* get support axis of the beam */
	status = om$send ( msg = message VSfeature.VSgetSupports (
					&msg,
					&me->VSbeamList[BeamNb].mod_env,
					&count,
					supports ),
		   targetid = me->VSbeamList[BeamNb].obj_id.objid,
		   targetos = me->VSbeamList[BeamNb].obj_id.osnum,
		   senderid = NULL_OBJID );
	if ( !( status & msg & 1 ) )
	{
	  printf("??? : Error VSfeature.VSgetSupports\n");
	  goto wrapup;
	}

	/* project support axis onto FEplate */
	/*
	 * Initialize struct curve_info and side_info for message
	 * EMSsubbs.EMproject_curve_along_surface_normals.
	 */

	curve_info.located_obj	= supports[1].obj_id ;
	curve_info.module_info	= me->VSplateList[ii].mod_env;
	side_info.located_obj	= me->FEplateList[ii];
	side_info.module_info	= me->MyEnv ;

	/*
	 * Project curve.
	 */
	status = om$send(
		msg = message EMSsubbs.EMproject_curve_along_surface_normals(
							&curve_info,
							&side_info,
							&cst,
							TRUE,
							TRUE,
							&nb_proj,
							&proj_obj,
							&msg ),
			targetid = me->FEplateList[ii].objid,
			targetos = me->FEplateList[ii].osnum );

#ifdef  SF_PLATE_DBG
	printf( "number of projections : [%d]\n", nb_proj ) ;
#endif

	if( nb_proj < 1 ) {
		me->FEbeamAxisList[BeamNb].objid = NULL_OBJID ;
/*		if( msg == MANOMEMORY ) {
*/			/*
			 * No dynamic memory.
			 */
/*			 msg = EMS_E_NoDynamicMemory ;
			 status = OM_E_NODYNMEM ;
		} else {
*/			/*
			 * No solution found.
			 */
/*			 msg = EMS_W_NoSolution ;
			 status = OM_W_ABORT ;
		}
*/		continue ;
	}
	/* take first projection */
	me->FEbeamAxisList[BeamNb].objid = proj_obj[0];
	me->FEbeamAxisList[BeamNb].osnum = me->MyEnv.md_id.osnum;

	if ( proj_obj ) free ( proj_obj );

	status = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&me->MyEnv.md_env.matrix_type,
					me->MyEnv.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
		     targetid = me->FEbeamAxisList[BeamNb].objid,
		     targetos = me->FEbeamAxisList[BeamNb].osnum );
      }

  }

wrapup:
  return status;
}

/* -------------------------------------------------------------------------
   Doc : PlacePlateAtMid

   Description : This method places FEM plate and beam axes at middle of
		 STRUCT plate.
   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
method  PlacePlateAtMid ()
{
long			msg, status = OM_S_SUCCESS, nb_proj;
int			ii, msg1, jj, BeamNb, count;
enum   GRdpmode		dpmode;	
struct ret_struct	rs;
int			index = -1; /* unused ASSOC flag */
double			offset;
struct GRvg_construct   cst;
struct GRid		offSfId,
			TmpObj;
struct GRsymbology	ActSymb;
VSsuppList		supports;
struct GRlc_info	curve_info,
			side_info;
OM_S_OBJID		*proj_obj = NULL;


  dp$erase_hilite( msg = &msg );

  ActSymb.display_attr = me->ActiveDisplay;
  ActSymb.level        = me->ActiveLevel;

  vs$fill_cnst_list (	Cnst_list	= cst,
			Msg		= &msg,
			Env_info	= &me->MyEnv,
			Level		= me->ActiveLevel,
			Display		= &me->ActiveDisplay );
  dpmode = GRhd;
  BeamNb = -1;
  for( ii=0; ii < me->PlateCount; ii++ )
  {
      if ( me->FEplateList[ii].objid != NULL_OBJID )
      {  
	 status = om$send( msg = message GRgraphics.GRdelete(&msg, &me->MyEnv),
			    targetid= me->FEplateList[ii].objid,
			    targetos= me->FEplateList[ii].osnum ) ;

	 me->FEplateList[ii].objid = NULL_OBJID;
      }

      status = om$send( msg = message NDmacro.ACreturn_foot(
						&msg,
						VS_K_plTopSfPath,
						&TmpObj,
						NULL, NULL ),
		   targetid = me->VSplateList[ii].obj_id.objid,
		   targetos = me->VSplateList[ii].obj_id.osnum );

      if ( !(status & msg & 1) )
      { 
	printf("PlacePlateAtMid :Error getting top surface for plate [%d,%d]\n",
		me->VSplateList[ii].obj_id.objid,
		me->VSplateList[ii].obj_id.osnum );
	continue;
      }

      /* get the thickness of the plate */
      status = om$send( msg = message NDmacro.ACgive_structure(
					&msg1, &index, VS_K_plThcknsAttr, &rs,
					&me->VSplateList[ii].mod_env ),
			targetid = me->VSplateList[ii].obj_id.objid,
			targetos = me->VSplateList[ii].obj_id.osnum );

      if ( ! ( status & msg1 & 1 ) )
      {
	printf("PlacePlateAtMid: Can not get thickness for the plate [%d,%d]\n",
		 me->VSplateList[ii].obj_id.objid,
		 me->VSplateList[ii].obj_id.osnum );
	continue;
      }

      offset = rs.var.root_pm_st.value * 0.5;
      vs$make_offset_surface(   msg       = &msg,
				surfEnv   = &me->VSplateList[ii].mod_env,
				surfId    = &TmpObj,
				offset    = offset,
				isPlanar  = DONT_KNOW,
				isNatNorm = TRUE,
				cst       = &cst,
				offSurfId = &offSfId );
      if ( ! ( 1 & msg ) )
      {
	printf("PlacePlateAtMid : vs$make_offset_surface failure\n");
	continue;
      }

      me->FEplateList[ii] = offSfId;

      /* reduntant, but needed in some cases */
      status = om$send( msg        = message GRvg.GRputsymb( &msg, &ActSymb),
			targetid   = me->FEplateList[ii].objid,
			targetos   = me->FEplateList[ii].osnum);
      if(!(status & msg & 1)) printf("Warning : Setting the symbology\n");

      status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->ModuleInfo.md_env.matrix_type,
			me->ModuleInfo.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->FEplateList[ii].objid,
		     targetos = me->FEplateList[ii].osnum );
      /* extract beam support axes and project them onto fem plates */
      for ( jj=0; jj<me->BeamsOnPl[ii]; jj++ )
      {
	BeamNb++;
	if ( me->FEbeamAxisList[BeamNb].objid != NULL_OBJID )
	{
	   status = om$send( msg = message GRgraphics.GRdelete(
							&msg, &me->MyEnv),
			    targetid= me->FEbeamAxisList[BeamNb].objid,
			    targetos= me->FEbeamAxisList[BeamNb].osnum ) ;
	}

	/* get support axis of the beam */
	status = om$send ( msg = message VSfeature.VSgetSupports (
					&msg,
					&me->VSbeamList[BeamNb].mod_env,
					&count,
					supports ),
		   targetid = me->VSbeamList[BeamNb].obj_id.objid,
		   targetos = me->VSbeamList[BeamNb].obj_id.osnum,
		   senderid = NULL_OBJID );
	if ( !( status & msg & 1 ) )
	{
	  printf("??? : Error VSfeature.VSgetSupports\n");
	  goto wrapup;
	}

	/* project support axis onto FEplate */
	/*
	 * Initialize struct curve_info and side_info for message
	 * EMSsubbs.EMproject_curve_along_surface_normals.
	 */

	curve_info.located_obj	= supports[1].obj_id ;
	curve_info.module_info	= me->VSplateList[ii].mod_env;
	side_info.located_obj	= me->FEplateList[ii];
	side_info.module_info	= me->MyEnv ;

	/*
	 * Project curve.
	 */
	status = om$send(
		msg = message EMSsubbs.EMproject_curve_along_surface_normals(
							&curve_info,
							&side_info,
							&cst,
							TRUE,
							TRUE,
							&nb_proj,
							&proj_obj,
							&msg ),
			targetid = me->FEplateList[ii].objid,
			targetos = me->FEplateList[ii].osnum );

#ifdef  SF_PLATE_DBG
	printf( "number of projections : [%d]\n", nb_proj ) ;
#endif

	if( nb_proj < 1 ) {
		me->FEbeamAxisList[BeamNb].objid = NULL_OBJID ;
/*		if( msg == MANOMEMORY ) {
*/			/*
			 * No dynamic memory.
			 */
/*			 msg = EMS_E_NoDynamicMemory ;
			 status = OM_E_NODYNMEM ;
		} else {
*/			/*
			 * No solution found.
			 */
/*			 msg = EMS_W_NoSolution ;
			 status = OM_W_ABORT ;
		}
*/		continue ;
	}
	/* take first projection */
	me->FEbeamAxisList[BeamNb].objid = proj_obj[0];
	me->FEbeamAxisList[BeamNb].osnum = me->MyEnv.md_id.osnum;

	if ( proj_obj ) free ( proj_obj );

	status = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&me->MyEnv.md_env.matrix_type,
					me->MyEnv.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
		     targetid = me->FEbeamAxisList[BeamNb].objid,
		     targetos = me->FEbeamAxisList[BeamNb].osnum );
      }
  }

wrapup:
  return status;

}

/* -------------------------------------------------------------------------
   Doc : PlacePlateAtKeyin

   Description : This method places FEM plate and beam axes at a given offset
		 from top of STRUCT plate.
   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
method  PlacePlateAtKeyin ( double  offset )
{
long			msg, status = OM_S_SUCCESS, nb_proj;
int			ii, jj, BeamNb, count;
enum   GRdpmode		dpmode;	
struct GRvg_construct   cst;
struct GRid		offSfId,
			TmpObj;
struct GRsymbology	ActSymb;
VSsuppList		supports;
struct GRlc_info	curve_info,
			side_info;
OM_S_OBJID		*proj_obj = NULL;

#ifdef SF_PLATE_DBG
  printf("Entered SFCoConvPl.PlacePlateAtKeyin\n");
  printf("\toffset : [%f]\n", offset);
#endif

  dp$erase_hilite( msg = &msg );

  ActSymb.display_attr = me->ActiveDisplay;
  ActSymb.level        = me->ActiveLevel;

  vs$fill_cnst_list (	Cnst_list	= cst,
			Msg		= &msg,
			Env_info	= &me->MyEnv,
			Level		= me->ActiveLevel,
			Display		= &me->ActiveDisplay );

  dpmode = GRhd;
  BeamNb = -1;
  for( ii=0; ii < me->PlateCount; ii++ )
  {
      if ( me->FEplateList[ii].objid != NULL_OBJID )
      {
	status = om$send( msg = message GRgraphics.GRdelete(&msg, &me->MyEnv ),
			   targetid = me->FEplateList[ii].objid,
			   targetos = me->FEplateList[ii].osnum  ) ;
	me->FEplateList[ii].objid = NULL_OBJID;
      }
      status = om$send( msg = message NDmacro.ACreturn_foot(
						&msg,
						VS_K_plTopSfPath,
						&TmpObj,
						NULL, NULL ),
		   targetid = me->VSplateList[ii].obj_id.objid,
		   targetos = me->VSplateList[ii].obj_id.osnum );

      if ( !(status & msg & 1) )
      {  
	printf(
	  "PlacePlateAtKeyin : Error getting top surface for plate [%d,%d]\n",
			me->VSplateList[ii].obj_id.objid,
			me->VSplateList[ii].obj_id.osnum );
	continue;
      }

      vs$make_offset_surface(   msg       = &msg,
				surfEnv   = &me->VSplateList[ii].mod_env,
				surfId    = &TmpObj,
				offset    = offset,
				isPlanar  = DONT_KNOW,
				isNatNorm = TRUE,
				cst       = &cst,
				offSurfId = &offSfId );
      if ( ! ( 1 & msg ) )
      {  
	printf("PlacePlateAtKeyin : vs$make_offset_surface failure\n");
	continue;
      }

#ifdef SF_PLATE_DBG
      printf("OffSfId : [%d,%d]\n", offSfId.objid, offSfId.osnum );
#endif

      me->FEplateList[ii] = offSfId;

      /* reduntant, but needed in some cases */
      status = om$send( msg        = message GRvg.GRputsymb( &msg, &ActSymb),
			targetid   = me->FEplateList[ii].objid,
			targetos   = me->FEplateList[ii].osnum);
      if(!(status & msg & 1)) printf("Warning : Setting the symbology\n");

      status = om$send ( msg = message GRgraphics.GRdisplay (
			&msg,
			&me->ModuleInfo.md_env.matrix_type,
			me->ModuleInfo.md_env.matrix,
			&dpmode,
			&me->ModuleInfo.md_id ),
		     targetid = me->FEplateList[ii].objid,
		     targetos = me->FEplateList[ii].osnum );

      /* extract beam support axes and project them onto fem plates */
      for ( jj=0; jj<me->BeamsOnPl[ii]; jj++ )
      {
	BeamNb++;
	if ( me->FEbeamAxisList[BeamNb].objid != NULL_OBJID )
	{
	   status = om$send( msg = message GRgraphics.GRdelete(
							&msg, &me->MyEnv),
			    targetid= me->FEbeamAxisList[BeamNb].objid,
			    targetos= me->FEbeamAxisList[BeamNb].osnum ) ;
	}

	/* get support axis of the beam */
	status = om$send ( msg = message VSfeature.VSgetSupports (
					&msg,
					&me->VSbeamList[BeamNb].mod_env,
					&count,
					supports ),
		   targetid = me->VSbeamList[BeamNb].obj_id.objid,
		   targetos = me->VSbeamList[BeamNb].obj_id.osnum,
		   senderid = NULL_OBJID );
	if ( !( status & msg & 1 ) )
	{
	  printf("??? : Error VSfeature.VSgetSupports\n");
	  goto wrapup;
	}

	/* project support axis onto FEplate */
	/*
	 * Initialize struct curve_info and side_info for message
	 * EMSsubbs.EMproject_curve_along_surface_normals.
	 */

	curve_info.located_obj	= supports[1].obj_id ;
	curve_info.module_info	= me->VSplateList[ii].mod_env;
	side_info.located_obj	= me->FEplateList[ii];
	side_info.module_info	= me->MyEnv ;

	/*
	 * Project curve.
	 */
	status = om$send(
		msg = message EMSsubbs.EMproject_curve_along_surface_normals(
							&curve_info,
							&side_info,
							&cst,
							TRUE,
							TRUE,
							&nb_proj,
							&proj_obj,
							&msg ),
			targetid = me->FEplateList[ii].objid,
			targetos = me->FEplateList[ii].osnum );

#ifdef  SF_PLATE_DBG
	printf( "number of projections : [%d]\n", nb_proj ) ;
#endif

	if( nb_proj < 1 ) {
		me->FEbeamAxisList[BeamNb].objid = NULL_OBJID ;
/*		if( msg == MANOMEMORY ) {
*/			/*
			 * No dynamic memory.
			 */
/*			 msg = EMS_E_NoDynamicMemory ;
			 status = OM_E_NODYNMEM ;
		} else {
*/			/*
			 * No solution found.
			 */
/*			 msg = EMS_W_NoSolution ;
			 status = OM_W_ABORT ;
		}
*/		continue ;
	}
	/* take first projection */
	me->FEbeamAxisList[BeamNb].objid = proj_obj[0];
	me->FEbeamAxisList[BeamNb].osnum = me->MyEnv.md_id.osnum;

	if ( proj_obj ) free ( proj_obj );

	status = om$send ( msg = message GRgraphics.GRdisplay (
					&msg,
					&me->MyEnv.md_env.matrix_type,
					me->MyEnv.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
		     targetid = me->FEbeamAxisList[BeamNb].objid,
		     targetos = me->FEbeamAxisList[BeamNb].osnum );
      }

  }

wrapup:
  return status;
}

/* -------------------------------------------------------------------------
   Doc : PerformAcceptOp

   Description : This method does necessary things when form is accepted.

   Return status :    SF_CONVERTED  -  some of the plates/beams have been
					     converted before.
		      1			  -  success
   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
method  PerformAcceptOp( long *msg )
{

  long		status = OM_S_SUCCESS;
  int		ii, jj;
  char		PlateName[SF_MAX_PLATENAME_SIZE],
		MatName[FE_MAX_MPNAME_SIZE],
		PrpName[FE_MAX_MPNAME_SIZE],
		msg_buff[81];
  int		sel_flag, r_pos;
  enum GRdpmode dpmode;
  char		*name[1]  = { SF_TXT_FEM_CONVERTED };
  char		*value[1] = { "1" };   /* can be anything */
  struct ret_struct  attr;
  int		index = -1;
  long		check_converted,
		eltype_state;
  double	tmp;
  int		nb_elems,
		elem_type,
		BeamNb;
  double	fem_mesh_weight = 1.0;
  char		BeamName[SF_MAX_BEAMNAME_SIZE];
  struct GRid	mesh_grid,
		*bmMeshList;
  int		nb_nodes, i1;
  double	*coords;
  struct GRid	*PtObjs;
  int		num_cvs_persf;
  char		BmExtractOpt[ATTR_TXT];
  short		actLvl;
  struct IGRdisplay actDisp;


	*msg = 1;

	FIg_get_state( FP_STFND_PL, SF_CHK_CONVERTED_FLD, &check_converted );

	if ( check_converted )     /* check if any of the plates
				      have already been converted.
				      If yes, set message and return */
	{
	   BeamNb = -1;
	   for ( ii=0; ii<me->PlateCount; ii++ )
	   {
		status = om$send ( msg = message NDmacro.ACgive_structure (
					 (int *) msg,
					 &index,
					 SF_TXT_FEM_CONVERTED,
					 &attr,
					 &me->VSplateList[ii].mod_env ),
			      targetid = me->VSplateList[ii].obj_id.objid,
			      targetos = me->VSplateList[ii].obj_id.osnum );

		if ( status & *msg & 1 )
		{
		   FIfld_get_text( FP_STFND_PL, SF_PLATE_LIST_FLD, ii, 0,
			      SF_MAX_PLATENAME_SIZE, PlateName, &sel_flag,
			      &r_pos );

		   ex$message (  field		= ERROR_FIELD,
				 msgnumb	= SF_E_PlConved,
				 justification	= CENTER_JUS,
				 type		= "%s",
				 var		= `PlateName`,
				 buff		=  msg_buff );
		   FIg_set_text ( FP_STFND_PL, FI_MSG_FIELD, msg_buff );
		   *msg = SF_CONVERTED;
		   goto quit;
		}

		for( jj=0; jj<me->BeamsOnPl[ii]; jj++)
		{
		  BeamNb++;
		  status = om$send ( msg = message NDmacro.ACgive_structure (
					 (int *) msg,
					 &index,
					 SF_TXT_FEM_CONVERTED,
					 &attr,
					 &me->VSbeamList[BeamNb].mod_env ),
			      targetid = me->VSbeamList[BeamNb].obj_id.objid,
			      targetos = me->VSbeamList[BeamNb].obj_id.osnum );
		  
		  if ( status & *msg & 1 )
		  {
		     FIfld_get_text( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 0,
			      SF_MAX_BEAMNAME_SIZE, BeamName, &sel_flag, &r_pos );

		      ex$message(field		= ERROR_FIELD,
				 msgnumb	= SF_E_BmConved,
				 justification	= CENTER_JUS,
				 type		= "%s",
				 var		= `BeamName`,
				 buff		=  msg_buff );
		      FIg_set_text ( FP_STFND_PL, FI_MSG_FIELD, msg_buff );
		      *msg = SF_CONVERTED;
		      goto quit;
		  }
		} /* for( jj=0; jj<me->BeamsOnPl[ii]; jj++) */
	   } /* for ( ii=0; ii<me->PlateCount; ii++ ) */
	} /* if ( check_converted ) */

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


	FIg_get_text ( FP_STFND_PL, SF_BM_EXTRACT_FLD, BmExtractOpt );
	FIg_get_state( FP_STFND_PL, SF_ELTYPE_FLD, &eltype_state );

	if ( eltype_state ) 
	   elem_type = LINE2;
	else
	   elem_type = LINE3;

	BeamNb = -1;
	dpmode = GRbd;
	for ( ii=0; ii<me->PlateCount; ii++ )
	{
            /*
             *  Something would have gone wrong while extracting
             *  a side of plate or offsetting.
             *  In that case FEplateList will be NULL_OBJID.
             *  Continue if FEplateList is NULL_OBJID.
             *  In future this info should be written to a log file.
             */
	    if ( me->FEplateList[ii].objid == NULL_OBJID ) continue;

	    status = om$send( msg = message GRgraphics.GRaddwrng(
					     msg, &me->ModuleInfo ),
			      targetid = me->FEplateList[ii].objid,
			      targetos = me->FEplateList[ii].osnum);
	    if( !(status &1 ) )
	    {
		printf("Warning : adding to rtree failed, object [%d,%d]\n",
			me->FEplateList[ii].objid, me->FEplateList[ii].osnum );
	    }

	    status = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
				targetid = me->FEplateList[ii].objid,
				targetos = me->FEplateList[ii].osnum );


	    FIfld_get_text( FP_STFND_PL, SF_PLATE_LIST_FLD, ii, 1,
			    FE_MAX_MPNAME_SIZE, MatName, &sel_flag, &r_pos );

	    status = SFplaceMatOnGeom ( msg, MatName, me->FEplateList[ii]);
	    if ( ! ( status & *msg & 1 ) )
	    { 
	      printf("Warning : Couldn't place material on FEM plate [%d,%d]\n",
		      me->FEplateList[ii].objid, me->FEplateList[ii].osnum );
	      continue;
	    }

	    FIfld_get_text( FP_STFND_PL, SF_PLATE_LIST_FLD, ii, 2,
			    FE_MAX_MPNAME_SIZE, PrpName, &sel_flag, &r_pos );

	    status = SFplacePrpOnGeom ( msg, PrpName, me->FEplateList[ii]);
	    if ( ! ( status & *msg & 1 ) )
	    { 
	      printf("Warning : Couldn't place property on FEM plate [%d,%d]\n",
		     me->FEplateList[ii].objid,	me->FEplateList[ii].osnum );
	      continue;
	    }

	    /*
	     * Connect on notifyTOnotific channel so that we can verify
	     * if there are changes to the VSplate
	     */
/*
OM_S_CHANSELECT notifyTOnotific;
IGRboolean	tag_connect = TRUE;
int		lis_index = OM_K_MAXINT;
om$make_chanselect ( channame      = "GRnotify.notification",
		     p_chanselect  = &notifyTOnotific );

	    status = om$send ( msg = message GRnotify.GRntfyconn(
					msg,
					&me->VSplateList[ii].obj_id,
					&notifyTOnotific,
					&lis_index,
					&tag_connect,
					&(me->VSplateList[ii].obj_id.osnum) ),
				senderid = NULL_OBJID,
				targetid = me->FEplateList[ii].objid,
				targetos = me->FEplateList[ii].osnum );
	    VDS_ERR_HNDLR("GRnotify.GRntfyconn",status,*msg, VD_VERBOSE, quit );
*/

	    /*  add user attribute "__FEMconverted" to the feature so that
	        in future we can know that the feature has been converted */
	    status = om$send ( msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
			       targetid = me->VSplateList[ii].obj_id.objid,
			       targetos = me->VSplateList[ii].obj_id.osnum );
	   if ( !(status & *msg & 1))
	   {
	     printf("PerformAcceptOp : VSfeature.VSmodUSrAttributes failed\n");
	     continue;
	   }

	   for ( jj=0; jj<me->BeamsOnPl[ii]; jj++ )
	   {
	    BeamNb++;
	    /*
	     * It has been found that projection of centroidal axis onto
	     * FEplate is failing sometimes. In that case FEbeamAxisList
	     * will have NULL_OBJID.
	     * Skip in case FEbeamAxisList[BeamNb] == NULL_OBJID.
	     * In future this info should be added to a log file.
	     */
	    if ( me->FEbeamAxisList[BeamNb].objid == NULL_OBJID ) continue;
	    status = om$send( msg = message GRgraphics.GRaddwrng(
					     msg, &me->ModuleInfo ),
			      targetid = me->FEbeamAxisList[BeamNb].objid,
			      targetos = me->FEbeamAxisList[BeamNb].osnum);
	    if( !(status &1 ) )
	    {
		printf("Warning : adding to rtree failed, object [%d,%d]\n",
			me->FEbeamAxisList[BeamNb].objid,
			me->FEbeamAxisList[BeamNb].osnum );
	    }

	    status = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
				targetid = me->FEbeamAxisList[BeamNb].objid,
				targetos = me->FEbeamAxisList[BeamNb].osnum );


	    /*
	     * Connect on notifyTOnotific channel so that we can verify
	     * if there are changes to the VSbeam
	     */
/*
	    status = om$send ( msg = message GRnotify.GRntfyconn(
					msg,
					&me->VSbeamList[BeamNb].obj_id,
					&notifyTOnotific,
					&lis_index,
					&tag_connect,
					&(me->VSbeamList[BeamNb].obj_id.osnum)),
				senderid = NULL_OBJID,
				targetid = me->FEbeamAxisList[BeamNb].objid,
				targetos = me->FEbeamAxisList[BeamNb].osnum );
	    VDS_ERR_HNDLR("GRnotify.GRntfyconn",status,*msg,VD_VERBOSE, quit );
*/

	    if ( !strcmp(BmExtractOpt, SF_TXT_TRACE_CURVES) )
	    {
	       IGRshort		layer;
	       short unsigned	color;

	       /*  add user attribute "__FEMconverted" to the feature so that
		   in future we can know that the feature has been converted */

	       status = om$send (  msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
				targetid = me->VSbeamList[BeamNb].obj_id.objid,
				targetos = me->VSbeamList[BeamNb].obj_id.osnum);
	       VDS_ERR_RPT( "VSfeature.VSmodUsrAttributes failure",
			     status, *msg, VD_VERBOSE );

	       /* get layer and color for the stiffener from file and
		* change those of stifener curve
		*/

	       FIfld_get_text( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 2,
			    FE_MAX_MPNAME_SIZE, PrpName, &sel_flag, &r_pos );

	       if ( me->BmPrpCreateFlag[BeamNb] )
	       {
		    status = SFgetNextLayerAndColor ( msg, &layer, &color );
		    VDS_ERR_RPT( "SFgetNextlayerAndColor", status, *msg,
								VD_VERBOSE );
		    if ( !(status&*msg&1) )
		    { layer = actLvl; color = actDisp.color; }

		    status = SFwriteToNBfile( msg, PrpName, layer, color, 
					      SF_STIFFENER );
		    VDS_ERR_RPT( "SFwriteToNBfile", status, *msg, VD_VERBOSE );

		} /* if ( me->BmPrpCreateFlag[BeamNb] ) */
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
		     status = SFwriteToNBfile ( msg, PrpName, layer, color,
						SF_STIFFENER );
		    VDS_ERR_RPT( "SFwriteToNBfile", status, *msg, VD_VERBOSE );
	        }

		status = om$send ( msg = message GRvg.GRchglevel(
							msg,
							&layer),
			      targetid = me->FEbeamAxisList[BeamNb].objid,
			      targetos = me->FEbeamAxisList[BeamNb].osnum );
		VDS_ERR_RPT( "GRvg.GRchglevel", status, *msg, VD_VERBOSE );

		status = om$send ( msg = message GRvg.GRchgcolor(
						msg,
						NULL,
						(IGRushort *) &color),
			      targetid = me->FEbeamAxisList[BeamNb].objid,
			      targetos = me->FEbeamAxisList[BeamNb].osnum );
		VDS_ERR_RPT( "GRvg.GRchgcolor", status, *msg, VD_VERBOSE );


		status = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&dpmode,
					&me->ModuleInfo.md_id ),
			      targetid = me->FEbeamAxisList[BeamNb].objid,
			      targetos = me->FEbeamAxisList[BeamNb].osnum );
	       continue;
	    } /* if ( !strcmp(BmExtractOpt, SF_TXT_TRACE_CURVES) ) */

	    if ( !strcmp(BmExtractOpt, SF_TXT_MESHING) )
	    {
	      FIfld_get_text( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 1,
			    FE_MAX_MPNAME_SIZE, MatName, &sel_flag, &r_pos );

	      FIfld_get_text( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 2,
			    FE_MAX_MPNAME_SIZE, PrpName, &sel_flag, &r_pos );

	      FIfld_get_value( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 3, &tmp,
			     &sel_flag, &r_pos );
	      nb_elems = tmp;

	      status = SFmeshAndPlaceMatPrp (  	msg,
						me->VSbeamList[BeamNb].obj_id,
						&me->VSbeamList[BeamNb].mod_env,
						me->FEbeamAxisList[BeamNb],
						&me->ModuleInfo,
						elem_type,
						nb_elems,
						fem_mesh_weight,
						MatName,
						PrpName,
						&mesh_grid,
						&bmMeshList );
	      if ( !( status & *msg & 1) )
	      {
		if ( bmMeshList )  free ( bmMeshList );
		bmMeshList = NULL;
	      }

	      VDS_ERR_CONTINUE("SFmeshAndPlaceMatPrp", status, *msg,
				VD_VERBOSE);

	      status = SFbmEndOffsets ( msg,
				    &(me->FEbeamAxisList[BeamNb]),
				    &(me->ModuleInfo),
				    &(me->ModuleInfo),
				    &(me->VSbeamList[BeamNb].obj_id),
				    &(me->VSbeamList[BeamNb].mod_env),
				    bmMeshList,
				    elem_type,
				    nb_elems,
				    1.0,
				    TRUE,
				    NULL  );
	      if ( bmMeshList )  free ( bmMeshList );
	      bmMeshList = NULL;

	      VDS_ERR_CONTINUE("SFbmEndOffsets", status, *msg, VD_VERBOSE);

	      status = SFgetNodalCoords ( msg, &mesh_grid, &nb_nodes, &coords );
	      if ( !( status & *msg & 1 ) )
	      {
		printf("PerformAcceptOp : SFgetNodalCoords failure\n");
		continue;
	      }

	      /* allocate memory for point objects */
	      PtObjs = (struct GRid *) malloc ( sizeof( struct GRid)* nb_nodes);
	      if ( !PtObjs )
	      {
		printf("PerformAcceptOp : Can not allocate memory\n");
		*msg = 0;
		goto quit;
	      }

	      for ( i1=0; i1< nb_nodes; i1++)
	      {
		status = SFplacePoint ( msg, &coords[i1*3], &me->ModuleInfo,
					&PtObjs[i1] );
		if ( !( status & *msg & 1 ) )
		{
		  printf("PerformAcceptOp : SFplacePoint failure\n");
		  continue;
		}
	      }

	      if ( coords ) free ( coords );

	      num_cvs_persf = nb_nodes;
	      status = SFplaceNMedges (	msg,
					1,
					&me->FEplateList[ii],
					&num_cvs_persf,
					PtObjs,
					&me->ModuleInfo	);

	      if ( !( status & *msg & 1 ) )
	      {
		printf("PerformAcceptOp : SFplaceNMedges failure\n");
		continue;
	      }

	      if ( PtObjs ) free ( PtObjs );

	      /*  add user attribute "__FEMconverted" to the feature so that
		in future we can know that the feature has been converted */

	      status = om$send (  msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
				targetid = me->VSbeamList[BeamNb].obj_id.objid,
				targetos = me->VSbeamList[BeamNb].obj_id.osnum);
	      if ( ! (status & *msg & 1) )
	      {
	        printf(
		  "PerformAcceptOp : VSfeature.VSmodUsrAttributes failure\n");
	        continue;
	      }
	    } /* if ( !strcmp(BmExtractOpt, SF_TXT_MESHING) ) */

	    if ( !strcmp(BmExtractOpt, SF_TXT_EQUI_PLATES) )
	    {
	      FIfld_get_text( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 1,
			    FE_MAX_MPNAME_SIZE, MatName, &sel_flag, &r_pos );

	      status = SFconvertStfnrToPlate (	msg,
						&me->VSbeamList[BeamNb],
						MatName,
						&me->FEplateList[ii],
						&me->ModuleInfo     );
	      VDS_ERR_CONTINUE("SFconvertBeamToPlate",status,*msg,VD_VERBOSE);

	      /*  add user attribute "__FEMconverted" to the feature so that
		in future we can know that the feature has been converted */
	      status = om$send (  msg = message VSfeature.VSmodUsrAttributes (
							msg,
							1,
							name,
							value ),
				targetid = me->VSbeamList[BeamNb].obj_id.objid,
				targetos = me->VSbeamList[BeamNb].obj_id.osnum);
	      if ( ! (status & *msg & 1) )
	      {
	        printf(
		  "PerformAcceptOp : VSfeature.VSmodUsrAttributes failure\n");
	        continue;
	      }
	    } /* ( !strcmp(BmExtractOpt, SF_TXT_EQUI_PLATES) ) */

	   } /* end for ( jj=0; jj<me->BeamsOnPl[ii]; jj++ ) */
	}/* end for ( ii=0; ii<me->PlateCount; ii++ ) */

quit:
   return status;

}

/* -------------------------------------------------------------------------
   Doc : PerformDeleteOp

   Description : This method does necessary things when form is cancelled.

   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
method  PerformDeleteOp()
{

  long		msg, ii, jj, BeamNb, status = OM_S_SUCCESS;
  char		MatName[FE_MAX_MPNAME_SIZE],
		PrpName[FE_MAX_MPNAME_SIZE];
  int		sel_flag, r_pos;


	dp$erase_hilite ( msg = &msg );

	BeamNb = -1;
	for ( ii=0; ii<me->PlateCount; ii++ )
	{
	   status = om$send( msg = message GRgraphics.GRdelete
					   ( &msg, &me->MyEnv ),
			     targetid = me->FEplateList[ii].objid,
			     targetos = me->FEplateList[ii].osnum ) ;

	   if ( me->PlMatCreateFlag[ii] )
	   {
		FIfld_get_text( FP_STFND_PL, SF_PLATE_LIST_FLD, ii, 1,
				FE_MAX_MPNAME_SIZE,MatName, &sel_flag, &r_pos );
		fe$delete_material( name = MatName );
	   }

	   if ( me->PlPrpCreateFlag[ii] )
	   {
		FIfld_get_text( FP_STFND_PL, SF_PLATE_LIST_FLD, ii, 2,
				FE_MAX_MPNAME_SIZE,PrpName, &sel_flag, &r_pos );
		fe$delete_property( name = PrpName );
	   }

	   for ( jj=0; jj<me->BeamsOnPl[ii]; jj++)
	   {
		BeamNb++;
		status = om$send( msg = message GRgraphics.GRdelete
					   ( &msg, &me->MyEnv ),
			     targetid = me->FEbeamAxisList[BeamNb].objid,
			     targetos = me->FEbeamAxisList[BeamNb].osnum ) ;

		if ( me->BmMatCreateFlag[BeamNb] )
		{
		    FIfld_get_text( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 1,
				FE_MAX_MPNAME_SIZE,MatName, &sel_flag, &r_pos );
		    fe$delete_material( name = MatName );
		}

		if ( me->BmPrpCreateFlag[BeamNb] )
		{
		    FIfld_get_text( FP_STFND_PL, SF_BEAM_LIST_FLD, BeamNb, 2,
				FE_MAX_MPNAME_SIZE,PrpName, &sel_flag, &r_pos );
		    fe$delete_property( name = PrpName );
		}

	   }

	}

  return status;

}
end implementation  SFCoStfndPl;
