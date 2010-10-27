/* $Id: VDCmdDfDwLo.sl,v 1.2 2002/05/20 15:18:35 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vddraw/cmd/VDCmdDfDwLo.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdDfDwLo.sl,v $
 *      Revision 1.2  2002/05/20 15:18:35  ylong
 *      *** empty log message ***
 *
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *	09/03/02	Raju		Creation
 *	05/20/02	ylong		TR6281
 ***************************************************************************/
/****************************************************************************

	Filename:	VDCmdDfDwLo.sl
	Author:		Raju MSB/ Ad Zuurhout
	Type:		Slic File
	Process by:	$EXNUC/bin/slic -C VDCmdDfDwLo.sl
	Output:		VDCmdDfDwLo.S  and VDCmdDfDwLoi.I

	Description:
	  Command Object to
	   o Define Drawing Layout Parameters

	History:
	Raju    Mar 9, 1995    Creation date

 ****************************************************************************/

/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	VDC_M_DfDrwLOPmi, 0, VDDfDwLo
class		VDCmdDfDwLo
super_class	CEO_LOCATE
product_name	"$VDS"
command_table	"vds.cmd"

/* form used */
form		"VDDfDwLo",0,0,"-1","-1"

start_state     start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

#define  FP		me^^CEO.forms[0].form_ptr

#define		VD_K_drwLO_MaxRep	30

#include	"grdpbdef.h"
#include	"dp.h"
#include	"nddef.h"
#include	"ACrg_collect.h"
#include	"acrepdef.h"

instance
{
	struct GRid		drwCollId;	/* drawing collector. */

	struct GRid		repCollId;	/* representation col */

	int			nbRep;		/* Number of represen */

	struct	ACrg_coll	Colls[VD_K_drwLO_MaxRep] ;
						/* Representation Types */
}


/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "FI.h"
#include "msdef.h"
#include "msmacros.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "acrepdef.h"
#include "acrepmacros.h"
#include "AS_status.h"

#include "vderrmacros.h"
#include "vdcolldef.h"
#include "vddlodef.h"
#include "vddlomacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#define  DEBUG  1

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

from  ACrg_collect  import  AClist_attribute;
from  ACrg_collect  import  ACget_attribute_at_index;
from  ACrg_collect  import  ACmod_list_attribute;
from  ACrg_collect  import  ACadd_list_attribute;

/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "VDmsg.h"

state start

    message_key		VD_M_DfDrwLOPm
    execute		set_instance_and_form

	on SUCCESS	state form_operations
	on ELSE
		do status_key	VD_S_ErrFormSetting		state terminate

state form_operations

    display_form	0
    prompt_key		VD_P_FormOp
    filter		get_event

	on EX_FORM_FINISHED					state terminate

at wakeup do set_form_pos
at sleep  do save_form_pos


action  save_form_pos
{
	FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

	status = OM_S_SUCCESS ;
	*sts = MSSUCC;
	goto quit ;
}

action  set_form_pos
{
IGRint			i,
			nbColls = 6,
			locNbRep ;
struct	GRid		collId ;
struct	ACrg_coll	drwColl[6], locColl;


	/*
	 * get the form position.
	 */
	if(x_pos != -1 && y_pos != -1)
		FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );

	/*
	 * Get the collector or make it.
	 */
	collId.objid = NULL_OBJID ;
	status =
	VDgetVdCollId( sts, VD_DRWLO_DIR_NAME, FALSE, FALSE, &collId );
	if( ! (status&*sts&1)){

		/*
		 * force to generate a collector with the field for
		 * the projection vector and point.
		 */
		status = 
		VDgetVdCollId( sts, VD_DRWLO_DIR_NAME, FALSE, TRUE, &collId );
		if( ! (status&*sts&1)){
			/*
			 * stop processing. There is something wrong.
			 */
			*sts = MSFAIL ;
			goto quit ;
		}

		/*
		 * Fill in the defaults for the collector.
		 */
		strcpy( drwColl[0].name, VD_S_drwLO_projPoint_X );
		strcpy( drwColl[1].name, VD_S_drwLO_projPoint_Y );
		strcpy( drwColl[2].name, VD_S_drwLO_projPoint_Z );

		strcpy( drwColl[3].name, VD_S_drwLO_projVector_X );
		strcpy( drwColl[4].name, VD_S_drwLO_projVector_Y );
		strcpy( drwColl[5].name, VD_S_drwLO_projVector_Z );

		for( i=0 ; i<6 ; i++ ){
		  /*
		   * Set all to string values.
		   */
		  drwColl[i].desc.type = AC_ATTRIB_TEXT;
		  strcpy( drwColl[i].desc.value.att_txt, "0.0" );
		}
		strcpy( drwColl[5].desc.value.att_txt, "1.0" );

		status =
		_VD_SEND_OBJN(	collId,
				ACrg_collect.ACadd_list_attribute( sts,
								   nbColls,
								   drwColl ));
		__CheckRC( status, *sts, "ACrg_collect.ACadd_list_attr", quit );
	}


	/*
	 * Set the instance.
	 */
	me->drwCollId = collId ;

	/*
	 * Get Representation Collector Information.
	 */
	status = ac$get_rep_col( col = &me->repCollId );
	as$status( action = RET_STATUS );

	me->nbRep = 0 ;
/*
	status =
	_VD_SEND_OBJN(	me->repCollId,
			ACrg_collect.AClist_attribute(	sts,
							VD_K_drwLO_MaxRep,
							me->Colls,
							&me->nbRep ));
	__CheckRC( status, *sts, "ACrg_collect.AClist_attribute", quit );
*/
	status =
	_VD_SEND_OBJN(	me->repCollId,
			ACrg_collect.AClist_attribute(	sts,
							VD_K_drwLO_MaxRep,
							NULL,
							&locNbRep ));
	__CheckRC( status, *sts, "ACrg_collect.AClist_attribute", quit );

	for ( i=0; i<locNbRep; i++ )
	{
	   status =
	   _VD_SEND_OBJN(me->repCollId,
			ACrg_collect.ACget_attribute_at_index(
							sts,
							i,
							&locColl )) ;
	   __CheckRC(status,*sts,"ACrg_collect.ACget_attribute_at_ndex",quit);

	   if ( strcmp(locColl.name, "Symbolic") &&
	        strcmp(locColl.name, "Detailed") &&
	        strcmp(locColl.name, "Envelope")    )
	   {
		me->Colls[me->nbRep] = locColl;
		(me->nbRep)++;
	   }
	}

}

action set_instance_and_form
{
long			msg;
GRname			lName;
int			i,
			ii;
int			sel_flag;
VD_drwInfoInternal	frmInfo ;
VD_drwLoInfo		drwInfo ;


   status = OM_S_SUCCESS;
   msg = MSSUCC;

   for( i=1 ; i<=VD_K_drwLO_MaxAttr ; i++ ){

	/*
	 * Get object form information.
	 */
	if( ! (VD_drwLO_GetInternStr( i, &frmInfo ))) continue ;

	/*
	 * Get the current object value.
	 */
	switch( i ){

	case VD_K_drwLO_tblUsrValue :
	case VD_K_drwLO_tblLinedOut :

		status =
		vd$drw_layout_info(	msg	= &msg ,
					type	= i ,
					info 	= &drwInfo );

		if( !(status&msg&1))	continue ;

		sel_flag =  drwInfo.val.iValue;
		FIg_set_state( FP, frmInfo.gadget, sel_flag );
		__DBGpr_int("drwInfo.val.iValue", drwInfo.val.iValue);
		__DBGpr_int("gadget to set: %d\n", frmInfo.gadget);
		__DBGpr_int("sel_flag", sel_flag);
		break ;

	case VD_K_drwLO_projVector :
	case VD_K_drwLO_projPoint  :

		status =
		vd$drw_layout_info(	msg	= &msg ,
					type	= i ,
					info 	= &drwInfo );

		if( !(status&msg&1))	continue ;

		for( ii=0 ; ii<3 ; ii++ ){
		  VD_drwLO_cvrtToString( &drwInfo, ii, lName );
		  FIfld_set_text(  FP, frmInfo.gadget+ii, 0, 0, lName, FALSE);
		}
		break ;

	case VD_K_drwLO_objRep :

                for( ii=0 ; ii<me->nbRep ; ii++ ){

                  FIfld_set_text(  FP, frmInfo.gadget, ii, 0,
                                   me->Colls[ii].name, FALSE );

                  status =
                  vd$drw_layout_info(
                        msg     = &msg ,
                        type    = i ,
                        rep     = me->Colls[ii].name ,
                        info    = &drwInfo );
		
		  if( !(status&msg&1))	continue ;

                  VD_drwLO_cvrtToString( &drwInfo, 0, lName );
                  FIfld_set_text(  FP, frmInfo.gadget, ii, 1, lName, TRUE );
                }

                FIfld_set_num_rows(FP, frmInfo.gadget, me->nbRep );

		break ;

	default :

		status =
		vd$drw_layout_info(	msg	= &msg,
					type	= i,
					info 	= &drwInfo );
		if ( status == VD_UNDEFINED )
		{
		   FIfld_set_text(  FP, frmInfo.gadget, 0, 0, "", TRUE );
		   continue;
		}

		if( !(status&msg&1))	continue ;

		VD_drwLO_cvrtToString(	&drwInfo, 0, lName );
		FIfld_set_text(  FP, frmInfo.gadget, 0, 0, lName, TRUE );
	}
	msg = MSSUCC ;
   }

	*sts = MSSUCC;
	goto quit ;
}

/****************************************************************************/
/*	ACTION  form_notification					*****/
/****************************************************************************/

action form_notification
{
long		sts, msg;

	/*
	 * Clean Up the message field.
	 */
	FIg_set_text ( FP, FI_MSG_FIELD, "" );


	switch ( gadget_label ){

	case FI_EXECUTE :
	case FI_ACCEPT:

		sts =
		_VD_SEND_MY( VDCmdDfDwLo.validate_data ( &msg ));
		__CheckRC( sts, msg, "VDCmdDfDwLo.validate_data", quit );

		sts =
		_VD_SEND_MY( VDCmdDfDwLo.save_collection ( &msg ));
		__CheckRC( sts, msg, "VDCmdDfDwLo.save_collection", quit );

		if ( gadget_label == FI_ACCEPT ){
		  _put_response ( resp = EX_FORM_FINISHED );
		}

		break;

	case FI_CANCEL:
		_put_response ( resp = EX_FORM_FINISHED );
	break;
	}

	goto quit ;
}

action validate_data
{
	*sts = MSSUCC;

	/*
	 * get attributes and validate them. (NOTHING FOR KNOW).
	 */
	status = OM_S_SUCCESS ;
	goto quit ;
}

action save_collection
{
int			i, ii,
			collIndex = 0,
			sel_flag,
			r_pos;
GRname			lName;
struct ACrg_coll	drwColl[40];
VD_drwInfoInternal	frmInfo ;

   *sts = MSSUCC;

   /*
    * check all the fields.
    */

   for( i=1 ; i<=VD_K_drwLO_MaxAttr ; i++ ){

	/*
	 * Get object form information.
	 */

	if( ! (VD_drwLO_GetInternStr( i, &frmInfo ))) continue ;

	/*
	 * Get the current object value.
	 */

	switch( i ){
	case VD_K_drwLO_projVector :

		strcpy( drwColl[collIndex].name,   VD_S_drwLO_projVector_X );
		strcpy( drwColl[collIndex+1].name, VD_S_drwLO_projVector_Y );
		strcpy( drwColl[collIndex+2].name, VD_S_drwLO_projVector_Z );

		for( ii=0 ; ii<3 ; ii++ ){
		  status =
		  FIfld_get_text( FP, frmInfo.gadget+ii, 0, 0,
				  DI_PATH_MAX, lName, &sel_flag, &r_pos);
		  drwColl[ii].desc.type = AC_ATTRIB_TEXT;
		  if( status == FI_SUCCESS )
		    strcpy( drwColl[ii].desc.value.att_txt, lName );
		  else
		    strcpy( drwColl[ii].desc.value.att_txt, VD_UNDEFINED_STR );
		}

		collIndex = 3 ;
		break ;

	case VD_K_drwLO_projPoint  :

		strcpy( drwColl[0].name, VD_S_drwLO_projPoint_X );
		strcpy( drwColl[1].name, VD_S_drwLO_projPoint_Y );
		strcpy( drwColl[2].name, VD_S_drwLO_projPoint_Z );

		for( ii=0 ; ii<3 ; ii++ ){
		  status =
		  FIfld_get_text( FP, frmInfo.gadget+ii, 0, 0,
				  DI_PATH_MAX, lName, &sel_flag, &r_pos);
		  drwColl[ii].desc.type = AC_ATTRIB_TEXT;
		  if( status == FI_SUCCESS )
		    strcpy( drwColl[ii].desc.value.att_txt, lName );
		  else
		    strcpy( drwColl[ii].desc.value.att_txt, VD_UNDEFINED_STR );
		}

		collIndex = 3 ;
		break ;

	case VD_K_drwLO_objRep :

                for( ii=0 ; ii<me->nbRep ; ii++ ){

		  sprintf( drwColl[ii].name , "%s_%s", 
				VD_S_drwLO_objRep, me->Colls[ii].name );
		  status =
		  FIfld_get_text( FP, frmInfo.gadget, ii, 1,
				  DI_PATH_MAX, lName, &sel_flag, &r_pos);

		  drwColl[ii].desc.type = AC_ATTRIB_TEXT;
		  if( status == FI_SUCCESS )
		    strcpy( drwColl[ii].desc.value.att_txt, lName );
		  else
		    strcpy( drwColl[ii].desc.value.att_txt, VD_UNDEFINED_STR );
		}

		collIndex = me->nbRep ;
		break ;

	case VD_K_drwLO_tblUsrValue :
	case VD_K_drwLO_tblLinedOut :

		strcpy( drwColl[0].name, frmInfo.text );
		status =
		FIg_get_state( FP, frmInfo.gadget, &sel_flag);
		drwColl[0].desc.type = AC_ATTRIB_TEXT;
		sprintf(drwColl[0].desc.value.att_txt, "%d", sel_flag);

		collIndex = 1 ;
		break;

	default :

		strcpy( drwColl[0].name, frmInfo.text );
		status =
		FIfld_get_text( FP, frmInfo.gadget, 0, 0,
				DI_PATH_MAX, lName, &sel_flag, &r_pos);
		drwColl[0].desc.type = AC_ATTRIB_TEXT;
		if ( strcmp ( lName, "" ) )
		  strcpy( drwColl[0].desc.value.att_txt, lName );
		else
		  strcpy( drwColl[0].desc.value.att_txt, VD_UNDEFINED_STR );

		collIndex = 1 ;
	}

	/*
	 * Modify the existing Collector.
	 */
	for( ii=0 ; ii<collIndex ; ii++ ){

	  __DBGpr_str(" attr_name " , drwColl[ii].name );
	  __DBGpr_str(" attr_value" , drwColl[ii].desc.value.att_txt );

	  status =
	  _VD_SEND_OBJN(me->drwCollId,
		ACrg_collect.ACmod_list_attribute( sts, 1, drwColl +ii ));
	  if( !(status&*sts&1)){

	    __DBGpr_str(" New_attr ", drwColl[ii].name );

	    status =
	    _VD_SEND_OBJN(me->drwCollId,
		  ACrg_collect.ACadd_list_attribute( sts, 1, drwColl +ii ));
	    __CheckRC( status, *sts, "ACrg_collect.ACadd_list_attr", quit );
	  }
	}

    } /* for ( ... ) */
}

