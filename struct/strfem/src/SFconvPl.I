class implementation  SFCoConvPl;

/* -------------------------------------------------------------------------
   This file contains the following methods

   Doc : PlacePlateAtBot

   Description : This method places FEM plate at bottom of STRUCT plate.

   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
#include "stdio.h"
#include "msdef.h"
#include "msmacros.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "FI.h"

#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "go.h"
#include "grdpbmacros.h"

#include "vderrmacros.h"

#include "vsdef.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"

#include "FElimits.h"
#include "FEmacros.h"

#include "FDdef.h"
#include "FEfddef.h"
#include "FDstruct.h"
#include "FEfdstruct.h"

#include "SFmsg.h"
#include "ACrg_collect.h"
#include "SFconvDef.h"
#include "SFconvPlDef.h"

from GRgraphics import GRdisplay;
from NDmacro    import ACreturn_foot;
from NDmacro    import ACgive_structure;
from GRvg	import GRputsymb;
from GRgraphics import GRdelete;
from GRgraphics import GRcopy;
from GRgraphics import GRaddwrng;
from VSfeature  import VSmodUsrAttributes;
from GRnotify   import GRntfyconn;
from GRgraphics import GRchgprops;
from GRvg	import GRgetsymb;


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
long			msg, status;
int			ii;
enum   GRdpmode		dpmode;	
struct GRsymbology	ActSymb;
struct GRid		TmpObj,
			offSfId;
double			offset;
struct GRvg_construct   cst;


#ifdef SF_PLATE_DBG
  printf("Entered SFCoConvPl.PlacePlateAtBot\n");
#endif

  status = OM_S_SUCCESS;

  dp$erase_hilite( msg = &msg);

  ActSymb.display_attr = me->ActiveDisplay;
  ActSymb.level        = me->ActiveLevel;

  vs$fill_cnst_list (	Cnst_list	= cst,
			Msg		= &msg,
			Env_info	= &me->MyEnv,
			Level		= me->ActiveLevel,
			Display		= &me->ActiveDisplay );

  /* get the bottom surface of the plates  and display them in highlight mode */
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

  }

  return status;
}

/* -------------------------------------------------------------------------
   Doc : PlacePlateAtTop

   Description : This method places FEM plate at top of STRUCT plate.

   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
method  PlacePlateAtTop ()
{
long			msg, status;
int			ii;
enum   GRdpmode		dpmode;	
struct GRsymbology	ActSymb;
struct GRid		TmpObj,
			offSfId;
double			offset;
struct GRvg_construct   cst;

#ifdef SF_PLATE_DBG
  printf("Entered SFCoConvPl.PlacePlateAtTop\n");
#endif

  status = OM_S_SUCCESS;

  dp$erase_hilite( msg = &msg );

  ActSymb.display_attr = me->ActiveDisplay;
  ActSymb.level        = me->ActiveLevel;

  vs$fill_cnst_list (	Cnst_list	= cst,
			Msg		= &msg,
			Env_info	= &me->MyEnv,
			Level		= me->ActiveLevel,
			Display		= &me->ActiveDisplay );

  /* get the top surface of the plates  and display them in highlight mode */
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
	printf("PlacePlateAtTop : GRgraphics.GRcopy failure\n");
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

  }

  return status;
}

/* -------------------------------------------------------------------------
   Doc : PlacePlateAtMid

   Description : This method places FEM plate at middle of STRUCT plate.

   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
method  PlacePlateAtMid ()
{
long			msg, status;
int			ii, msg1;
enum   GRdpmode		dpmode;	
struct ret_struct	rs;
int			index = -1; /* unused ASSOC flag */
double			offset;
struct GRvg_construct   cst;
struct GRid		offSfId,
			TmpObj;
struct GRsymbology	ActSymb;


  status = OM_S_SUCCESS;

  dp$erase_hilite( msg = &msg );

  ActSymb.display_attr = me->ActiveDisplay;
  ActSymb.level        = me->ActiveLevel;

  vs$fill_cnst_list (	Cnst_list	= cst,
			Msg		= &msg,
			Env_info	= &me->MyEnv,
			Level		= me->ActiveLevel,
			Display		= &me->ActiveDisplay );
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
  }

  return status;

}

/* -------------------------------------------------------------------------
   Doc : PlacePlateAtKeyin

   Description : This method places FEM plate at a given offset from top
		 of STRUCT plate.
   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
method  PlacePlateAtKeyin ( double  offset )

{
long			msg, status;
int			ii;
enum   GRdpmode		dpmode;	
struct GRvg_construct   cst;
struct GRid		offSfId,
			TmpObj;
struct GRsymbology	ActSymb;

#ifdef SF_PLATE_DBG
  printf("Entered SFCoConvPl.PlacePlateAtKeyin\n");
  printf("\toffset : [%f]\n", offset);
#endif

  status = OM_S_SUCCESS;

  dp$erase_hilite( msg = &msg );

  ActSymb.display_attr = me->ActiveDisplay;
  ActSymb.level        = me->ActiveLevel;

  vs$fill_cnst_list (	Cnst_list	= cst,
			Msg		= &msg,
			Env_info	= &me->MyEnv,
			Level		= me->ActiveLevel,
			Display		= &me->ActiveDisplay );
  dpmode = GRhd;
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

  }

  return status;
}

/* -------------------------------------------------------------------------
   Doc : PerformAcceptOp

   Description : This method does necessary things when form is accepted.

   Return status :    SF_PLATE_CONVERTED  -  some of the plates have been
					     converted before.
		      1			  -  success
   History :
   05-30-1994	Raju	Creation
------------------------------------------------------------------------- */
method  PerformAcceptOp( long *msg )
{

  long		status;
  int		ii;
  char		PlateName[SF_MAX_PLATENAME_SIZE],
		MatName[FE_MAX_MPNAME_SIZE],
		PrpName[FE_MAX_MPNAME_SIZE],
		msg_buff[81];
  int		sel_flag, r_pos;
  enum GRdpmode dpmode;
  char		*name[1]  = { SF_TXT_FEM_CONVERTED };
  char		*value[1] = { "1" };  /* can be any thing */
  struct ret_struct  attr;
  int		index = -1;
  long		check_converted;


	*msg = 1;

	status = OM_S_SUCCESS;

	FIg_get_state( FP_PLATE, SF_PL_CHK_CONVERTED_FLD, &check_converted );

	if ( check_converted )     /* check if any of the plates
				      have already been converted.
				      If yes, set message and return */
	{
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
		   
		   FIfld_get_text( FP_PLATE, SF_PL_PLATE_LIST_FLD, ii, 0,
			      SF_MAX_PLATENAME_SIZE, PlateName, &sel_flag,
			      &r_pos );

		   ex$message (  field		= ERROR_FIELD,
				 msgnumb	= SF_E_PlConved,
				 justification	= CENTER_JUS,
				 type		= "%s",
				 var		= `PlateName`,
				 buff		=  msg_buff );
		   FIg_set_text ( FP_PLATE, FI_MSG_FIELD, msg_buff );
		   *msg = SF_PLATE_CONVERTED;
		   goto quit;
		}
	   }
	}
	dp$erase_hilite ( msg = msg );


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
	    if ( !( status & *msg & 1) )
		printf(" Error GRgraphics.GRdisplay\n");

	    FIfld_get_text( FP_PLATE, SF_PL_PLATE_LIST_FLD, ii, 1,
			    FE_MAX_MPNAME_SIZE, MatName, &sel_flag, &r_pos );

	    status = SFplaceMatOnGeom ( msg, MatName, me->FEplateList[ii]);
	    if ( ! ( status & *msg & 1 ) )
	    { 
	      printf("Warning : Couldn't place material on FEM plate [%d,%d]\n",
		      me->FEplateList[ii].objid, me->FEplateList[ii].osnum );
	      continue;
	    }

	    FIfld_get_text( FP_PLATE, SF_PL_PLATE_LIST_FLD, ii, 2,
			    FE_MAX_MPNAME_SIZE, PrpName, &sel_flag, &r_pos );

	    status = SFplacePrpOnGeom ( msg, PrpName, me->FEplateList[ii]);
	    if ( ! ( status & *msg & 1 ) )
	    { 
	      printf("Warning : Couldn't place property on FEM plate [%d,%d]\n",
		     me->FEplateList[ii].objid,	me->FEplateList[ii].osnum );
	      continue;
	    }

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
					&me->VSplateList[ii].obj_id.osnum ),
				senderid = NULL_OBJID,
				targetid = me->FEplateList[ii].objid,
				targetos = me->FEplateList[ii].osnum );
	   VDS_ERR_HNDLR("GRnotify.GRntfyconn",status,*msg,VD_VERBOSE,quit );
*/

	}  /*	for ( ii=0; ii<me->PlateCount; ii++ ) */

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

  long		msg, ii, status;
  char		MatName[FE_MAX_MPNAME_SIZE],
		PrpName[FE_MAX_MPNAME_SIZE];
  int		sel_flag, r_pos;


	status = OM_S_SUCCESS;

	dp$erase_hilite ( msg = &msg );

	for ( ii=0; ii<me->PlateCount; ii++ )
	{
	   status = om$send( msg = message GRgraphics.GRdelete
					   ( &msg, &me->MyEnv ),
			     targetid = me->FEplateList[ii].objid,
			     targetos = me->FEplateList[ii].osnum ) ;

	   if ( me->MatCreateFlag[ii] )
	   {
		FIfld_get_text( FP_PLATE, SF_PL_PLATE_LIST_FLD, ii, 1,
				FE_MAX_MPNAME_SIZE,MatName, &sel_flag, &r_pos );
		fe$delete_material( name = MatName );
	   }

	   if ( me->PrpCreateFlag[ii] )
	   {
		FIfld_get_text( FP_PLATE, SF_PL_PLATE_LIST_FLD, ii, 2,
				FE_MAX_MPNAME_SIZE,PrpName, &sel_flag, &r_pos );
		fe$delete_property( name = PrpName );
	   }

	}

  return status;

}
end implementation  SFCoConvPl;


