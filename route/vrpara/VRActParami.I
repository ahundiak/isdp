/* $Id: VRActParami.I,v 1.1.1.1 2001/01/04 21:13:00 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrpara / VRActParami.I
 *
 * Description:
	Implementation file for command object
        that display and manage the PIPING, HVAC, RWAY
	active parameters.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRActParami.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:00  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/03/05  20:47:28  pinnacle
# Replaced: vrpara/VRActParami.I for:  by hverstee for route240
#
# Revision 1.5  1996/03/01  23:08:54  pinnacle
# Replaced: vrpara/VRActParami.I for:  by hverstee for route240
#
# Revision 1.4  1996/01/18  23:29:14  pinnacle
# Replaced: vrpara/VRActParami.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/17  14:47:16  pinnacle
# Replaced: vrpara/VRActParami.I for:  by r240_int for route240
#
 *
 * History:
 *	11/5/92		Demars	creation
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *	01/17/96	tlb	Use VDfld_set_list_text
 *
 *************************************************************************/
class implementation VRActParam;


#include "OMparameters.h"
#include "igrmacros.h"
#include "msdef.h"
#include "exdef.h"
#include <stdio.h>
#include "igrtypedef.h"
#include "igr.h"
#include "exmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "FI.h"
#include "FEI.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "VRdef.h"
#include "VRutildef.h"
#include "VRMcForm.h"
#include "VRutilmacros.h"
#include "VRact_params.h"
#include "VRchgattrdef.h"
#include "VRPid.h"
#include "vrparameters.h"
#include "VDSutil.h"
#include "VDDfEntCode.h"

#include "vrtools_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define  AS_DEBUG 1

#define MAIN 0
#define SUB 1

from	ACncpx	import	ACgive_structure;

/**********************************************************/

method VRInitForm ( int mode )
{
  IGRint 		Index,status;
  extern int            COB_FI_form_notification();
  extern int            COB_FI_initial_form_notification ();

  if ( mode & VR_SYSTEM_ATTR )
	Index = MAIN;
  else if ( mode & VR_USER_ATTR )
	Index = SUB;
  else return OM_E_INVARG;

  if ( !me->form_ptr[Index] )
  {
	/* Initialize Main form */
	status =
	FIf_new (Index, me->form_name[Index], COB_FI_form_notification,
							&me->form_ptr[Index] );
	if ( status )
	{	me->form_ptr[Index] = NULL;
		return OM_E_ABORT;
	}

	status =
	FIf_set_cmd_oid_os (  me->form_ptr[Index],
				my_id, OM_Gw_current_OS );
	if ( status )	return OM_E_ABORT;
	status =
	FIf_set_initial_notification_routine( me->form_ptr[Index],
					  COB_FI_initial_form_notification );
	if ( status )	return OM_E_ABORT;

  }/* end initialize form */

  return OM_S_SUCCESS;

}/* end VRInitForm */

/**********************************************************/

method VRDispForm ( int mode )
{
  IGRint	VStatus;

  if ( me->delete_flag ) return OM_S_SUCCESS;

  /* Initialize forms if necessary */

  if ( (mode & VR_SYSTEM_ATTR) )
  {

	/* -- Display main form -- */
	FIf_is_displayed ( me->form_ptr[MAIN], &VStatus );

	if ( !VStatus )
		FIf_display( me->form_ptr[MAIN] );

	/* -- Display units based on the project unit -- */
	VR$DispFormUnits ( pForm = me->form_ptr[MAIN] );

  }/* end System form display */

  if ( mode & VR_USER_ATTR )
  {
	/* -- Display user form -- */
	FIf_is_displayed ( me->form_ptr[SUB], &VStatus );
	if ( !VStatus )
		FIf_display( me->form_ptr[SUB] );
  }


   return OM_S_SUCCESS;

}/* end VRDispForm */

/**********************************************************/

method delete ( int f_defer_flag )
{
  int		  status = OM_S_SUCCESS;

  if ( !me->delete_flag ) return OM_S_SUCCESS;

  /* -- Get deleted -- */

  if (!(me->VDB_terminated))
  {
    /* erase main form */
    if ( me->form_ptr[MAIN] ) FIf_delete( me->form_ptr[MAIN] );

    /* erase sub form */
    if ( me->form_ptr[SUB] )  FIf_delete( me->form_ptr[SUB] );

    /* If I still have collections :delete them */
    status =
    om$send(	msg = message VRActParam.VRDeleteAttr
				( VR_USER_ATTR|VR_SYSTEM_ATTR  ) ,
		targetid = my_id);
  }

  status =
  om$send(	msg = message VDB_LOCATE.delete ( 0 ) ,
			mode = OM_e_wrt_message,
		targetid = my_id);

  return status;

}/* end delete */

/**********************************************************/

method VRDeleteAttr ( IGRint flag )
{

  if(	(flag & VR_SYSTEM_ATTR) &&
	1&(om$is_objid_valid(	objid = me->SysId.objid,
				osnum = me->SysId.osnum)))
  {
	/*| Delete System collection */
	nd$wait_batch( 	type       = GR_DELETED,
			l_object   = &me->SysId,
			nb_obj     = 1 );

	me->SysId.objid = NULL_OBJID;
  }

  if(	(flag & VR_USER_ATTR) &&
	1&(om$is_objid_valid(	objid = me->UsrId.objid,
				osnum = me->UsrId.osnum)))
  {
	/*| Delete User collection */
	nd$wait_batch( 	type       = GR_DELETED,
			l_object   = &me->UsrId,
			nb_obj     = 1 );

	me->UsrId.objid = NULL_OBJID;
  }

  return OM_S_SUCCESS;

}/* end VRDeleteAttr */

/**********************************************************/

method init ( int type ; char * str_ptr )
{
  int		  status = OM_S_SUCCESS;

  struct GRid		VRap_co;
  char			path_name[DI_PATH_MAX];
  int			rc;

  /*---------------------------------------*/
  /* If anything goes wrong, I get deleted */
  me->delete_flag  	= 1;
  /*---------------------------------------*/

  status =
  om$send( msg    = message VDB_LOCATE.init ( type, str_ptr ),
	   mode   = OM_e_wrt_message,
	   targetid = my_id);
  as$status( action = RET_STATUS );
  if (me->VDB_terminated) return (status);

  /* Set product dependant instances (forms etc) */
  status = om$send( msg = message VRActParam.VRSetProduct ( &rc ) ,
		targetid = my_id);
  as$status( action = RET_STATUS );

  /*A initialize my instance */
  me->PrevLineNum  = -1;
  me->bLineNumUsed = FALSE;

  /* -- Try to find an already active command -- */

  status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     pathname = path_name );

  if ( status != DIR_S_SUCCESS )
  {
     di$report_error( sts = status,  comment = "error in give pathname" );	
     return ( OM_E_ABORT );
  }

  strcat( path_name, me->CommandName );

  /*"path name is %s \n", path_name */

  status = di$translate ( objname = path_name,
			  osnum	  = OM_Gw_TransOSnum_0,
			  p_objid = &VRap_co.objid,
			  p_osnum = &VRap_co.osnum );

  if ( status != DIR_S_SUCCESS )
  {
    if ( status == DIR_W_NAME_NOT_FOUND )
    {

     /*"Couldn't find it, so trying to create my dir entry\n\n" */

      status = di$add_name( objname = path_name,
			    objid   = my_id,
			    osnum   = OM_Gw_TransOSnum_0 );
	
	if ( status != DIR_S_SUCCESS )
  	{
         di$report_error( sts     = status,
                          comment = "Error : di$add_name" );
	}
	/*| added my_id to dir system */
    }
    else
    {
      /*^di$report_error( sts     = status,
                          comment = "VRPppara: Unable to find my entry\n" );
      */
    }
  }
 else if ( VRap_co.objid != my_id )
  {
	/*|CO id and my id not the same\n */
	status =
	om$send( msg = message VRActParam.delete ( 0 ),
		targetid = my_id);
	return OM_S_SUCCESS ;

  }

  /* Initialise the form pointer */
  status = om$send( msg = message VRActParam.VRInitForm
			( VR_SYSTEM_ATTR ),
		targetid = my_id);
  as$status( action = RET_STATUS );

  /* Initialise the form pointer */
  status = om$send( msg = message VRActParam.VRInitForm
			( VR_USER_ATTR ),
		targetid = my_id);
  as$status( );

  /*--------------------------------------------------*/
  /* -- Everything worked well. I am going to live -- */ 
  me->delete_flag = 0;
  /*--------------------------------------------------*/

  return OM_S_SUCCESS;
}

/**********************************************************/

from 	ACrg_collect	import	ACset_list_attribute;
extern	GRclassid	OPP_ACrg_collect_class_id; 

method VRInitAttr ( int flag )
{

  IGRlong		retmsg;
  IGRint		status, NbAttr;
  struct GRid		TmpId;
  struct ACrg_coll	AttrList[VR_MAX_ATTR];

  /* ----------------------------------------------- */
  /* -- Works on a copy of the active collections -- */
  /* ----------------------------------------------- */

  /* -- Copy active collections */
  ex$get_cur_mod( osnum = &TmpId.osnum );

  /* -- Get Active collection -- */
  if ( (flag & VR_SYSTEM_ATTR) )
  {
	TmpId.objid = NULL_OBJID;
	VR$active_params( operation	= VR_RETRIEVE,
			  mode		= VR_SYSTEM_MODE,
			  update_flag	= VR_NOUPDATE,
			  VRproduct	= me->Product,
			  act_param_id	= &TmpId,
			  status	= status );
	as$status( action = RET_STATUS );

	/* -- Initialize a new Sys collection (in case new parameters
		have been added -- */
	me->SysId.objid = NULL_OBJID;
	me->SysId.osnum = TmpId.osnum;

	status = 
	VRinit_attributes( me->Product, AttrList, &NbAttr );
	as$status( action = RET_STATUS );

	status = 
	om$construct( 	classid = OPP_ACrg_collect_class_id,
       			p_objid = &me->SysId.objid,
       			osnum   = me->SysId.osnum,
			msg     = message ACrg_collect.ACset_list_attribute
					( &retmsg, NbAttr, AttrList));
	as$status( action = RET_STATUS ); 

	/* -- Update the values with the active System collection -- */
	status =
	VR$ModifyCollection (	p_msg			= &retmsg,
				Operation		= VR_UPDATE_COLL,
				p_InputCollectionId	= &TmpId,
				p_OutputCollectionId	= &me->SysId);
	as$status( action = RET_STATUS );

  }/* end init system attributes */

  /* -- Get Active User collection -- */
  if ((flag & VR_USER_ATTR))
  {
	TmpId.objid = NULL_OBJID;

	VR$active_params( operation	= VR_RETRIEVE,
			  mode		= VR_USER_MODE,
			  update_flag	= VR_NOUPDATE,
			  VRproduct	= me->Product,
			  act_param_id	= &TmpId,
			  status	= status );
	as$status( action = RET_STATUS );

	/* -- Copy the active User collection -- */

	me->UsrId.objid = NULL_OBJID;
	me->UsrId.osnum = TmpId.osnum;

	status =
	VR$ModifyCollection (	p_msg			= &retmsg,
				Operation		= VR_MERGE_COLL,
				p_InputCollectionId	= &TmpId,
				p_OutputCollectionId	= &me->UsrId);
	as$status( action = RET_STATUS );

  }/* end init user attributes */

return OM_S_SUCCESS;

}/* end VRInitAttr */

method VRUpdUsrForm ()
{

	IGRint		status;

	if ( !me->form_ptr[SUB] )
	{
		printf ("Error in form managment\n");
		return OM_S_SUCCESS;
	}

	/*A display the collection data in the subform	*/
	status = VR$DispCollAttr(pForm   = me->form_ptr[SUB],
				Gadget  = USER_ATTR_FLD,
		 		pCollId = &me->UsrId );
	as$status( action = RET_STATUS );

	return OM_S_SUCCESS;

}/* end VRUpdUsrForm */

method initial_form_notification ( int    form_label ;
                                   int    gadget_label ;
                                   double value ;
                                   char * form_ptr )
{
#ifdef	MANAGE_IDS
	int		  status = OM_S_SUCCESS, i;

	if ( form_ptr == NULL )	return( OM_E_INVARG );

	if( form_ptr == me->form_ptr[MAIN] && bVR_IS_PID_ACTIVE )
	  switch( gadget_label )
	  {
		case LINE_SEQ_NO:
		case LINE_NUMBER:
		{
			struct ret_struct	ParamAttr;
			IGRint 			FootIndex = -1, retstatus;
			IGRint			IdList[VDS_LIST_OF_IDS];
			IGRchar			LineIdStr[10];
			
			/*C Get system name */
			status = 
			om$send( msg      = message ACncpx.ACgive_structure
						   ( &retstatus, 
						     &FootIndex, 
					       	     VR_N_SYST_NAME_AN,
		     			       	     &ParamAttr, 
						     &me->ModuleInfo),
			targetid = me->SysId.objid,
			targetos = me->SysId.osnum );

			/*printf( " initial_form : system name = %s \n", 
				ParamAttr.var.text_st.text_string );	*/

			/*C unlock the previous unused id */
			if ( !me->bLineNumUsed && me->PrevLineNum != -1 )
			{
				status =
				VDUnLockID ( ParamAttr.var.text_st.text_string,
					(int)VD_C_PIPES, me->PrevLineNum );
			}/* end of unlock */

			/*C get the list of available line Ids */
			status = 
			VDGetListOfIDs( ParamAttr.var.text_st.text_string,
				(int)VD_C_PIPES, IdList );

			/*C set the associated list */
			for( i=0; i<VDS_LIST_OF_IDS; i++ )
			{
				sprintf( LineIdStr, "%05d", IdList[i] );
				VDfld_set_list_text( form_ptr, gadget_label, 
					i, 0, LineIdStr, FALSE);
			}
		}
		break;
		
		default:
			break;

	  }/*C end switch */
#endif
	
	return (OM_S_SUCCESS);
}

method VRUnLockId()
{

#ifdef	MANAGE_IDS

	int		  	status = OM_S_SUCCESS, i;
	struct ret_struct	ParamAttr;
	IGRint 			FootIndex = -1, retstatus;

     if( bVR_IS_PID_ACTIVE ) 
     {
	/*C Get system name */
	status = 
	om$send( msg      = message ACncpx.ACgive_structure
				   ( &retstatus, 
				     &FootIndex, 
			       	     VR_N_SYST_NAME_AN,
     			       	     &ParamAttr, 
				     &me->ModuleInfo),
		targetid = me->SysId.objid,
		targetos = me->SysId.osnum );
	as$status();

	/*printf( " initial_form : system name = %s \n", 
		ParamAttr.var.text_st.text_string );	*/

	/*C unlock the previous unused id */
	if ( !me->bLineNumUsed && me->PrevLineNum != -1 )
	{
		status =
		VDUnLockID ( ParamAttr.var.text_st.text_string,
			(int)VD_C_PIPES, me->PrevLineNum );
	}/* end of unlock */
      }
#endif

      return (OM_S_SUCCESS);
}

end implementation VRActParam;
