/* $Id: VDCmdDgnPrm.sl,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vddgninfo/cmd/VDCmdDrwVw.sl
 *
 * Description:
 *         Define design setup parameters
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdDgnPrm.sl,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1997/12/31  15:14:46  pinnacle
# Replaced: vddgninfo/cmd/VDCmdDgnPrm.sl for:  by yzhu for vds
#
# Revision 1.3  1997/08/05  15:51:06  pinnacle
# Replaced: vddgninfo/cmd/VDCmdDgnPrm.sl for:  by yzhu for vds
#
# Revision 1.1  1997/07/08  15:34:16  pinnacle
# Created: vddgninfo/cmd/VDCmdDgnPrm.sl by yzhu for vds
#
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/01/97        yzhu            creation date
 *
 * -------------------------------------------------------------------*/
/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	VDC_M_DgnStpPrm, 0, VDDgnStp 
/* command_string	"Design Setup Parameters", 0, VDDgnStp */
class		VDCmdDgnPrm
super_class	CEO_LOCATE
product_name	"$VDS"
command_table	"vds.cmd"

/* form used */
form		"VDDgnStpPrm",0,0,"-1","-1"

start_state     start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

#define  FP	me^^CEO.forms[0].form_ptr

#include	"grdpbdef.h"
#include	"dp.h"
#include	"nddef.h"
#include	"ACrg_collect.h"
#include	"acrepdef.h"

instance
{
	struct GRid		dgnCollId;	/* drawing collector. */
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
#include "vddgndef.h"
#include "vddgnmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "vdprdmacros.h"

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

    message		"Design Setup Parameter"
    display_form	0
    prompt_key		VD_P_FormOp
    filter		get_event

	on EX_FORM_FINISHED					state terminate

at init do myinit
at sleep  do save_form_pos


action  save_form_pos
{
	FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);

	status = OM_S_SUCCESS ;
	*sts = MSSUCC;
	goto quit ;
}

action  myinit
{
struct	GRid		collId ;
struct	ACrg_coll	*dgnColl = NULL;
long                    msg;
GRname                  lName;
int                     i, defNum, formNum, state, P_ROUTE;
VD_dgnInfoInternal      frmInfo ;
VD_dgnInfoDefault       defInfo ;
VD_dgnStInfo            dgnInfo ;

	SetProc(VDCmdDgnPrm.myint); Begin
   	
	status = OM_S_SUCCESS;
   	*sts = MSSUCC;

	/*
	 * get the form position.
	 */
	if(x_pos != -1 && y_pos != -1)
		FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );

        defNum = VD_K_dgnSt_MaxAttr; 
        formNum = VD_K_dgnSt_MaxAttr; 
	/*
	 * Get the design collector: need to free dgnColl .
	 */

	status =  VDsetDgnDefColl( sts, dgnColl , &collId);
        
	__CheckRC( status, *sts, "VDsetDgnDefColl", wrapup );


	/* check if product is I/ROUTE:  temprory out by zhu 
	status = vd$prd_get_product_info( logo    = VD_PROD_LOGO_ROUTE );
        if ( status )
		P_ROUTE = TRUE;
	else
		P_ROUTE = FALSE;

	__DBGpr_int( " P_ROUTE ",  P_ROUTE);
        */

	/*
	 * Set the instance.
	 */
	me->dgnCollId = collId ;


        /* 
	 * Set form 
	 */
        for( i=1 ; i<= formNum ; i++ ){
   	  msg = MSSUCC;

	  /*
	   * Get object form information.
	   */
	  if( ! (VD_dgnSt_GetInternStr( i, &frmInfo ))) continue ;

	  /*
	   * Get the current object value.
	   */

	  status =
	  vd$dgn_setup_info(	msg	= &msg,
				index	= i,
				info 	= &dgnInfo );
	  if ( status == VD_UNDEFINED )
	  {
	      FIfld_set_text(  FP, frmInfo.gadget, 0, 0, "", TRUE );
	      continue;
	  }

	  if( !(status&msg&1))	continue ;

          if( !strcmp ( frmInfo.text, "symbDrFile") ){ /* for symbDrFile */
	       VD_dgnSt_cvrtToString(	&dgnInfo, 0, lName );
               status =
	       FIfld_set_text(  FP, frmInfo.gadget, 0, 0, lName, TRUE );
          }
          else if( !strcmp ( frmInfo.text, "symbDrStatus") ){ 
               state = (int) dgnInfo.val.sValue;
	       status =
               FIg_set_state( FP, frmInfo.gadget, state);
          }
          else if( !strcmp ( frmInfo.text, "pidStatus") ){ 
               state = (int) dgnInfo.val.sValue;
	       status =
               FIg_set_state( FP, frmInfo.gadget, state);
               /* temprory out by zhu
               if( !P_ROUTE )
		 FIg_disable (FP, frmInfo.gadget);
               else 
		 FIg_enable (FP, frmInfo.gadget);
               */
          }
	}

	_FREE( dgnColl ); 
	*sts = MSSUCC;
        End
	goto quit ;

wrapup:
	_FREE( dgnColl ); 
        End
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
		_VD_SEND_MY( VDCmdDgnPrm.save_collection ( &msg ));
		__CheckRC( sts, msg, "VDCmdDgnPrm.save_collection", quit );

                /* yzhu set rep to diagram */
                sts =  VDsetRepToDiag( &msg  );

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

action save_collection
{
int			i, ii,
			collIndex = 0,
			sel_flag,
			r_pos, state;
GRname			lName;
struct ACrg_coll	dgnColl[40];
VD_dgnInfoInternal	frmInfo ;

   SetProc(VDCmdDgnPrm.save_collection); Begin
   *sts = MSSUCC;

   /*
    * check all the fields.
    */

   for( i=1 ; i<=VD_K_dgnSt_MaxAttr ; i++ ){

	/*
	 * Get object form information.
	 */

	if( ! (VD_dgnSt_GetInternStr( i, &frmInfo ))) continue ;

	/*
	 * Get the current object value.
	 */

	strcpy( dgnColl[0].name, frmInfo.text );

	if( !strcmp ( frmInfo.text, "symbDrFile") ){ /* for symbDrFile */
	  status =
	  FIfld_get_text( FP, frmInfo.gadget, 0, 0,
			DI_PATH_MAX, lName, &sel_flag, &r_pos);

	  dgnColl[0].desc.type = AC_ATTRIB_TEXT;

	  if ( strcmp ( lName, "" ) )
	    strcpy( dgnColl[0].desc.value.att_txt, lName );
	  else
	    strcpy( dgnColl[0].desc.value.att_txt, VD_UNDEFINED_STR );
	
	  collIndex = 1 ;
        }
	else if( !strcmp ( frmInfo.text, "symbDrStatus") ){ 
				/* for symbDrStatus */
	  status =
	  FIg_get_state( FP, frmInfo.gadget,&state);
	  dgnColl[0].desc.type = AC_ATTRIB_TEXT;

          if ( state == 1)
	    strcpy( dgnColl[0].desc.value.att_txt, "1" );
          else
	    strcpy( dgnColl[0].desc.value.att_txt, "0" );
        }
	else if( !strcmp ( frmInfo.text, "pidStatus") ){ 
		/* for pidStatus */
          status =
          FIg_get_state( FP, frmInfo.gadget, &state);
          dgnColl[0].desc.type = AC_ATTRIB_TEXT;

          if ( state == 1)
            strcpy( dgnColl[0].desc.value.att_txt, "1" );
          else
            strcpy( dgnColl[0].desc.value.att_txt, "0" );
	} 

	/*
	 * Modify the existing Collector.
	 */
	for( ii=0 ; ii<collIndex ; ii++ ){

	  __DBGpr_str(" attr_name " , dgnColl[ii].name );
	  __DBGpr_str(" attr_value" , dgnColl[ii].desc.value.att_txt );

	  status =
	  _VD_SEND_OBJN(me->dgnCollId,
		ACrg_collect.ACmod_list_attribute( sts, 1, dgnColl +ii ));

	  if( !(status&*sts&1)){
	    __DBGpr_str(" New_attr ", dgnColl[ii].name );
	    status =
	    _VD_SEND_OBJN(me->dgnCollId,
		  ACrg_collect.ACadd_list_attribute( sts, 1, dgnColl +ii ));
	    __CheckRC( status, *sts, "ACrg_collect.ACadd_list_attr", quit );
	  }
	} /* for ii */

    } /* for i  */
    End
}

