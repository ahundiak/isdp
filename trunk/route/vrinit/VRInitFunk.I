/* $Id: VRInitFunk.I,v 1.2 2001/02/20 01:14:24 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinit / VRInitFunk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRInitFunk.I,v $
 *	Revision 1.2  2001/02/20 01:14:24  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:57  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/12/19  10:51:48  pinnacle
# Replaced: vrinit/VRInitFunk.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/30  03:50:06  pinnacle
# Replaced: vrinit/VRInitFunk.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/17  00:06:38  pinnacle
# Replaced: vrinit/VRInitFunk.I for:  by r240_int for route240
#
 *
 * History:
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *      12/19/97        Alwin   Modified VRinit_products, to specify the macro
 *                              depending upon the seed-file used.
 *
 *************************************************************************/
/******************************************************************************
/*
/*      Author  :       Bruno
/*
/*      Creation:       1992
/*
/*      CHANGE HISTORY:
/*
/*                date  |  name |       modification's description
/*              --------+-------+-----------------------------------
/*              10/13/94 | Lori | Add function VRInitNozPid to 
/*                              | initialize the pid scale for a
/*                              | nozzle (TR 179309027)
/*              10/27/94 | Lori | Initialize HVAC spec which was
/*                              | added in this CR (CR 179422038)
/*
/*
/******************************************************************************/

class implementation VRinit;

/* --	VROUTE
	Initialization program.
   -- */

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gr.h"
#include "godef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "VRcompdef.h"
#include "VRDbParamDef.h"
#include "vrparameters.h"
#include "VRdef.h"
#include "VRPid.h"
#include "AS_status.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "acdef.h"
#include "acmacros.h"

/* collection creation */
#include "nddef.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRattr_def.h"

#include "vrpdu_pto.h"
#include "vrdbgmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe


from ACrg_collect	import	ACadd_list_attribute,
                                ACget_named_attribute,
                                ACmod_list_attribute;

from NDnode	        import	NDchg_state;

/* for units management */
#include "VRDbStruct.h"

#define AS_DEBUG	1

from GRvg		import	GRputname;

/************************************************************************/
/*
/*	Bruno : 01-Dec-92
/*
/*	This function returns TRUE if the active representation is PID.
/*	
/************************************************************************/
#include "VDSsymb_def.h"
#include "VDSsymb_mac.h"
#include "VRact_params.h"

IGRboolean bVRTestPidAct ()

/*.bVRTestPidAct */
{
	IGRlong		retmsg;
	struct VDSsymb	Symb;
	struct GRid	DumbGrid;

	/* Get VDS representation */

	vd$symbology(	msg         = &retmsg,
			operation   = RETRIEVE,
			symb_id	    = &DumbGrid,
			symb	    = &Symb  );

	return (Symb.representation == VR_V_PID_REP);

}/* end bVRTestPidAct */

/*----------------------------------------------------------------------------*/
IGRint VRinit_products()

/*.VRinit_products */
{

	IGRint 			status;
	IGRchar			path[180] ;
	struct 			GRid wkmac;
	struct ACrg_coll 	Params[10];
	IGRlong	 		retmsg;
	IGRlong			size_of_env,num_ret;
	struct GRmd_env		md_env;

        SetProc( VRinit_products ); Begin

	/*A Test the active representation */

	if ( bVR_IS_PID_ACTIVE ) 
        {
                __DBGpr_com( " Load the Schematics library " );
                VRInitPid();
        }
	else
	{	/*A Else load the 3D libraries */

		/*C Piping macro-definitions */

                __DBGpr_com( " Load the 3D-library " );
		ac$construct_path(	mode = AC_ADD_PATH | AC_INQ,
					name = "VRmacro") ;

		/*C HVAC macro-definitions */

		ac$construct_path(	mode = AC_ADD_PATH | AC_INQ,
					name = "HVmacro") ;

	}/* end of loading the macro-definitions */

	/*C Get current module environment */

	size_of_env = sizeof(struct  GRmd_env);
	status = 
	gr$get_module_env( 	msg 	= &retmsg,
				sizbuf	= &size_of_env,
				buffer	= &md_env,
				nret 	= &num_ret);
	as$status(action = RET_STATUS);

	di$give_pathname ( osnum = md_env.md_id.osnum, pathname = path );

	strcat ( path, DIR_NAME_HVAC );
	strcat ( path, ":" );
	strcat ( path, "hsystem" );

        __DBGpr_str( " Full hvac pathname ", path );

	status=
	di$translate ( 	objname = path,
			p_objid = &wkmac.objid,
			p_osnum = &wkmac.osnum );

	if ( status == DIR_S_SUCCESS )
	  {
	    strcpy( Params[0].name, VR_N_CLASS_AN );
	    Params[0].desc.type = AC_ATTRIB_TEXT;
	    strcpy( Params[0].desc.value.att_txt, "SERV1" );
	    om$send ( msg = message ACrg_collect.ACadd_list_attribute
		     ( &retmsg, 1, Params ),
		     senderid = NULL_OBJID,
		     targetid = wkmac.objid,
		     targetos = wkmac.osnum );
	  }
	
	/*| +-------------------------------------+ */
	/*| | Construct ROUTE internal components | */
	/*| +-------------------------------------+ */

	/*| DANGLING */

	di$give_pathname ( osnum = md_env.md_id.osnum, pathname = path );

	strcat ( path, ":" );
	strcat ( path, VR_MISC_DIR );
	strcat ( path, ":" );
	strcat ( path, VR_DANGLING_NAME );

        __DBGpr_str( " Full dangling pathname ", path );

	status=
	di$translate ( 	objname = path,
			p_objid = &wkmac.objid,
			p_osnum = &wkmac.osnum );

	if ( status != DIR_S_SUCCESS )
	{
		/*| Build Dangling's cache */

		strcpy(Params[0].name,VR_N_MACRO_NAME_AN);
		Params[0].desc.type = AC_ATTRIB_TEXT;

                /* added by alwin, to specify the Macro name for dangle when
                working in Metric Seed file */
 
                switch( VRenq_proj_units() )
                {
                   case VR_IMPERIAL_UNITS:
                        __DBGpr_com( " Imperial units, Macro Name is 'dang'" );
                        strcpy(Params[0].desc.value.att_txt,"dang");
                        break;
 
                   case VR_MIXED_UNITS:
                   case VR_METRIC_UNITS:
                        __DBGpr_com("Non-Imperial units, Macro Name is dangm" );
                        strcpy(Params[0].desc.value.att_txt,"dangm");
                        break;
 
                   default :
                        printf ( "Unknown project units : %d\n",
                                                         VRenq_proj_units() );
                        break;
                }

		strcpy(Params[1].name,VR_N_COMP_TOPO_IN);
		Params[1].desc.type = AC_ATTRIB_DOUBLE;
		Params[1].desc.value.att_exp= VRP_V_CLOSURE_TOPO;

		strcpy(Params[2].name,VR_N_COMP_TYPE_IN);
		Params[2].desc.type = AC_ATTRIB_DOUBLE;
		Params[2].desc.value.att_exp= VR_V_DANGLING_TYPE;

		wkmac.objid = NULL_OBJID;
		wkmac.osnum = md_env.md_id.osnum;

		status =
		VR$ModifyCollection (
			p_msg 			= &retmsg,
			Operation 		= VR_MERGE_COLL,
			p_ParamsListToModify 	= Params,
			NbParamsToModify 	= 3,
			p_OutputCollectionId 	= &wkmac );

		status =
		om$send( msg = message NDnode.NDchg_state(
					( (IGRchar)  ND_DEL_NO_CH ),
					( (IGRchar) ~ND_DEL_NO_CH ) ),
			senderid = NULL_OBJID,
			targetid = wkmac.objid,
			targetos = wkmac.osnum ) ;
		as$status ( action = RET_STATUS );

		status=
	   	om$send(msg      = message GRvg.GRputname( &retmsg, path),
			senderid = NULL_OBJID,
			targetid = wkmac.objid ,
			targetos = wkmac.osnum );
		as$status ();

	}/* end build Dangling cache */

	/*| SUPPORT */

	di$give_pathname ( osnum = md_env.md_id.osnum, pathname = path );

	strcat ( path, ":" );
	strcat ( path, VR_MISC_DIR );
	strcat ( path, ":" );
	strcat ( path, VR_SUPPORT_NAME );

        __DBGpr_str( " Full support pathname ", path );

	status=
	di$translate ( 	objname = path,
			p_objid = &wkmac.objid,
			p_osnum = &wkmac.osnum );

	if ( status != DIR_S_SUCCESS )
	{
		/*| Build Support's cache */
		strcpy(Params[0].name,VR_N_MACRO_NAME_AN);
		Params[0].desc.type = AC_ATTRIB_TEXT;
		strcpy(Params[0].desc.value.att_txt,"ps3imp");

		strcpy(Params[1].name,VR_N_COMP_TOPO_IN);
		Params[1].desc.type = AC_ATTRIB_DOUBLE;
		Params[1].desc.value.att_exp= VRP_V_UNDEFINED_TOPO;

		strcpy(Params[2].name,VR_N_COMP_TYPE_IN);
		Params[2].desc.type = AC_ATTRIB_DOUBLE;
		Params[2].desc.value.att_exp= VRP_V_SUPPORT_TYPE;

		wkmac.objid = NULL_OBJID;
		wkmac.osnum = md_env.md_id.osnum;

		status =
		VR$ModifyCollection (
			p_msg 			= &retmsg,
			Operation 		= VR_MERGE_COLL,
			p_ParamsListToModify 	= Params,
			NbParamsToModify 	= 3,
			p_OutputCollectionId 	= &wkmac );

		status =
		om$send( msg = message NDnode.NDchg_state(
					( (IGRchar)  ND_DEL_NO_CH ),
					( (IGRchar) ~ND_DEL_NO_CH ) ),
			senderid = NULL_OBJID,
			targetid = wkmac.objid,
			targetos = wkmac.osnum ) ;
		as$status ( action = RET_STATUS );

		status=
	   	om$send(msg      = message GRvg.GRputname( &retmsg, path),
			senderid = NULL_OBJID,
			targetid = wkmac.objid ,
			targetos = wkmac.osnum );
		as$status ();

	}/* end build Support cache */

End
return ( OM_S_SUCCESS );

}/* end of VRinit_products */


/************************************************************************/
/*
/*	Bruno : 26-Nov-92
/*
/*	This function attaches the PID macro library ( metric or imperial)
/*	
/************************************************************************/


IGRint VRInitPid()

/*.VRInitPid */
{
	IGRchar *LibName=NULL;

        switch (VRenq_proj_units())
        {
        case VR_METRIC_UNITS :
        case VR_MIXED_UNITS :
                /*| Display Metric/Mixed */
		LibName = VRPID_N_METRIC_LIB;
                break;

        case VR_IMPERIAL_UNITS :
                /*| Display Imperial */
		LibName = VRPID_N_IMPERIAL_LIB;
                break;

        default :
                printf ( "Unknown project units : %d\n", VRenq_proj_units() );
                break;

        }/* end switch on unit */


	/*| mount the object space containing the Piping macros definition */

	if (LibName)
	{
		ac$construct_path(	mode	= AC_ADD_PATH | AC_INQ,
					name	= LibName) ;
	}

	{
		struct ACrg_coll	PidScale;
		struct GRid		ActSysId;
		IGRlong			retmsg;
		IGRint			status;

	/*| -- Add the scale factor in the attributes if it does not exist */

	/* Retrieve active attributes' collection */
	ex$get_cur_mod(id = &ActSysId.objid, osnum = &ActSysId.osnum);

	ActSysId.objid = NULL_OBJID;

	VR$active_params(	operation 	= VR_RETRIEVE,
				mode	  	= VR_SYSTEM_MODE,
				update_flag	= VR_NOUPDATE,
				VRproduct	= VR_PIPING,
				act_param_id	= &ActSysId,
				status 		= status 	);
	as$status ( action = RET_STATUS );

	strcpy ( PidScale.name, VR_N_PID_SCALE_DB );
	PidScale.desc.type = AC_ATTRIB_DOUBLE;
	PidScale.desc.value.att_exp = 1.0;

	om$send ( msg = message ACrg_collect.ACadd_list_attribute
					( &retmsg, 1, &PidScale ),
		senderid = NULL_OBJID,
		targetid = ActSysId.objid,
		targetos = ActSysId.osnum );

	}

return OM_S_SUCCESS;


}/* end of VRInitPid */



/************************************************************************/
/*
/*	Lori : 13-Oct-94
/*
/*	This function gets the PID scale from the active system
/*      collection and adds it to the current active nozzle collection
/*	
/************************************************************************/

IGRint VRInitNozPid(CollectId, Product, md_env)

struct       GRid        *CollectId;
IGRshort                 Product;
struct       GRmd_env    *md_env;
{
  struct    GRid       SysParamId;
  IGRlong              status, msg;
  struct    ACrg_coll  PidScale;


  /* get active system collection */
  VRInitPid();
  SysParamId.objid = NULL_OBJID;
  SysParamId.osnum = md_env->md_id.osnum;
  VR$active_params(VRproduct         = Product, 
                   act_param_id      = &SysParamId,
                   status            = status);
  
  strcpy( PidScale.name, VR_N_PID_SCALE_DB);
  
  /* get Pid scale from active system collection */
  status = om$send( msg = 
		   message ACrg_collect.ACget_named_attribute
		   ( &msg, &PidScale ),
		   senderid = NULL_OBJID,
		   targetid = SysParamId.objid,
		   targetos = SysParamId.osnum);
  
  as$status();
  if ( ! ( msg & 1) )
    {
      strcpy ( PidScale.name, VR_N_PID_SCALE_DB );
      PidScale.desc.type = AC_ATTRIB_DOUBLE;
      PidScale.desc.value.att_exp = 1.0;
    }



  /* add PID scale to nozzle collection */
  status = 
  VR$ModifyCollection(p_msg                   = &msg,
		      Operation               = VR_MERGE_COLL,
		      Type                    = VR_DYN_COLL,
		      p_ParamsListToModify    = &PidScale,
		      NbParamsToModify        = 1,
		      p_OutputCollectionId    = CollectId);
  as$status();

      
return OM_S_SUCCESS;
}




end implementation VRinit;
