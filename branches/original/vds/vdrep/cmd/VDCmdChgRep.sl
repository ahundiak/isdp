/* $Id: VDCmdChgRep.sl,v 1.3 2001/10/24 21:12:21 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrep/cmd / VDCmdChgRep.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdChgRep.sl,v $
 *	Revision 1.3  2001/10/24 21:12:21  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/19 23:01:14  jayadev
 *	*** empty log message ***
 *	
# Revision 1.2  2000/06/06  00:06:40  pinnacle
# Replaced: vds/vdrep/cmd/VDCmdChgRep.sl for:  by lawaddel for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/02/10  19:44:24  pinnacle
# Replaced: vdrep/cmd/VDCmdChgRep.sl for:  by yzhu for vds
#
# Revision 1.3  1997/07/17  14:14:36  pinnacle
# Replaced: vdrep/cmd/VDCmdChgRep.sl for:  by yzhu for vds
#
# Revision 1.2  1997/07/08  15:22:50  pinnacle
# Replaced: vdrep/cmd/VDCmdChgRep.sl for:  by yzhu for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/02/05  18:38:14  pinnacle
# Replaced: ./vdrep/cmd/VDCmdChgRep.sl for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/05/96	adz		TR 179600312.
 *	07/05/97	yzh		add check_diag state.
 *					    check_diag_ctl
 *      06/05/00        law             TR179901586-take pid out of coll_list
 * -------------------------------------------------------------------*/

command_string	VDC_M_ChElemRep, 0, VDChElRp
class		VDCmdChgRep
super_class	VDS_LOCATE
product_name	"$VDS_PATH"
command_table	"vds.cmd"
/* start_state	start */ 
start_state	check_diag 
form		"VDChangeRep", 0, 0, "-1", "-1"

specification
/*
        Below is information for creating the spec file
*/

#include "grdpbdef.h"
#include "dp.h"
#include "nddef.h"
#include "ACrg_collect.h"
#include "acrepdef.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define VD_NB_REP       30    /* Maximum representations in VD                */

instance
{
 unsigned char	repres;			/* Active Setting Representation     */
 unsigned char  app_rep;		/* Appliable representation for Obj  */
 int            nb_object;		/* Number of objects located (fence) */
 variable struct GRid  l_object[100];	/* List of objects llocated (fence)  */

 struct ACrg_coll coll_list[VD_NB_REP];	/* Representations type              */
 int		num_rep;		/* Number of total representations   */

 int		rep_label;		/* Form return status                */
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* 			implementation area				      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
implementation

#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "OMlimits.h"
#include "OMprimindex.h"
#include "grdpbdef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepmacros.h"
#include "coparadef.h"
#include "coparamac.h"

#include "ASmessages.h"
#include "VDmsg.h"
#include "VDmem.h"

#include "AS_status.h"
#include "AS_debug.h"
#include "v_dbgmacros.h"
#include "exdef.h"

#define  AS_DEBUG 1

from	ACrg_collect    import AClist_attribute;
from	ACncpx		import ACget_rep, ACget_NV_rep, ACset_NV_rep;

extern  DB_debug();           /* Function to print debug		      */
extern	ASstart_fence(), ASend_fence();
extern  NDexec_batch();       /* Function to execute the batch queue          */
extern  ACcreate_possible_rep_col(); /* Fn to find/create representation      */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                               forms definitions                            */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
#define		VD_SELECT		12
#define		VD_REP_FORM_INFO	255
#define		VD_REP_FORM_ACCEPT	1
#define		VD_REP_FORM_EXECUTE	2
#define		VD_DIAG_COLL_NO	        201
#define		VD_DIAG_ON	        202
#define		VD_DIAG_OFF	        203
#define		VD_OBJ_REP_DIAG	        204
#define		VD_DGN_PID_REP    6     /* internal value for pid tr179901586 */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*			state_table area				      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
state_table

#include	"VDmsg.h"
#include	"exdef.h"
#define		VD_REP_FORM_INFO	255
#define		VD_REP_FORM_ACCEPT	1
#define		VD_REP_FORM_EXECUTE	2
#define		VD_DIAG_COLL_NO	        201
#define		VD_DIAG_ON	        202
#define		VD_DIAG_OFF	        203
#define		VD_OBJ_REP_DIAG	        204


at init do my_init

/*-----------------------------------*/
state check_diag
        on ELSE 
          do check_diag_ctl
	    on RETURN_CODE = VD_DIAG_OFF	state start
          state terminate

/*-----------------------------------*/
state start
/*
        Ask the user to locate something, if a reject is the first input,
        assume it was a mistake.
*/
   message_key		VD_M_ChElemRep
   prompt_key           VD_P_SelObjChg
   locate_class         "ACcpx"
   locate_owner         " LC_FLEX_COMP | LC_REF_OBJECTS "
   locate_properties    "LC_LC_ONLY |  LC_RW " 
   accept_key           VD_P_AccRej
   relocate_key         VD_P_SelObjChg
   filter               locate

   on GR_UNKNOWN_TYPE.VD_REP_FORM_INFO
	do return_form( &me->ret )
	    on RETURN_CODE = VD_REP_FORM_EXECUTE	state start
	    on RETURN_CODE = VD_REP_FORM_ACCEPT
		do erase_form 0				state terminate
							state .
   on EX_DATA
	do process_locate
	    on ERROR					state .
	    on RETURN_CODE = VD_OBJ_REP_DIAG		state .
	do display_form 0				state form_info

   on EX_OBJID
	do process_locate
	    on ERROR					state .
	    on RETURN_CODE = VD_OBJ_REP_DIAG		state .
	do display_form 0				state form_info

   on EX_RJT_MOVEON					state terminate

/*-----------------------------------*/
state form_info

   message_key          VD_M_ChElemRep
   prompt_key           VD_P_EntNewRep
   dynamics             off
   filter               get_event

   on EX_BACK_UP
	do erase_form 0					state start

   on EX_RJT_MOVEON					state .

   on GR_UNKNOWN_TYPE.VD_REP_FORM_INFO
	do return_form( &me->ret )
	    on RETURN_CODE = VD_REP_FORM_EXECUTE	state start
	    on RETURN_CODE = VD_REP_FORM_ACCEPT
		do erase_form 0				state terminate
							state .

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              init function                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action my_init
{
IGRint		row;			/* row of field on form */
struct GRid	coll;			/* The collection object */
IGRint		ii;
IGRint act_repres;                      /* added for tr179901586 */

  SetProc( VDCmdChgRep.sl--my_init); Begin 


  /*
   * Get id of the collection of representations
   */

  status = ac$get_rep_col( col = &coll );
  as$status( action = RET_STATUS );

  /*
   * Find all possible representations
   */
  status =
  om$send( msg = message ACrg_collect.AClist_attribute( sts,
							VD_NB_REP,
							me->coll_list,
							&me->num_rep ),
	   senderid = NULL_OBJID,
	   targetid = coll.objid,
	   targetos = coll.osnum );
  as$status( action = RET_STATUS );

  /* Added for TR179901586- take PID out of coll_list */
  /* get temp list which do not include pid */
  ii = 0;
  for( row=0; row<me->num_rep; row=row+1 ) {
        act_repres = me->coll_list[row].desc.value.att_exp ;
        if ( act_repres == VD_DGN_PID_REP ) continue;
        me->coll_list[ii] = me->coll_list[row];
        ii = ii + 1;
  }
  me->num_rep = ii;


  /* Modified for tr179901586
   * Show all the available representations.
   */
  if ( me->forms[0].form_ptr )
  {
    FIfld_set_num_rows( me->forms[0].form_ptr, VD_SELECT, me->num_rep );
    for( row=0; row<me->num_rep; row++ ) {
        __DBGpr_str ( "coll_list", me->coll_list[row].name);
	FIfld_set_text( me->forms[0].form_ptr, VD_SELECT, row, 0,
			me->coll_list[row].name, FALSE );
    } 
  }
wrapup:
  End
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              process_locate function                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action process_locate
{
int i, row;			/* Row selected in the form	*/
struct GRid	*buffer;	/* Temp buffer of objects	*/
GRspacenum	osnum;
int		ii;
char    	mess[80];
  /* Get the fence contents */
  osnum = 0;
  status =
  ASstart_fence(	me->event1.located_object[0].located_obj,
			osnum,
			&me->nb_object,
			&buffer,
			me->response,
			me->response_data );
   
  /*
   * ADZ : Jun-18-1993
   * Using as$start_fence gives the following problem in the command object:
   * Used osnum = 0 to cross reference files.
   * Signal SIGEMT (7)
   * Stopped at
   * 0x00cd8cac (EXgetq+0x9c):
   *
   * status =
   * as$start_fence(  set             = &loc_obj,
   *                  nb_obj          = &me->nb_object,
   *                  p_obj           = &buffer,
   *                  response        = &me->response,
   *                  response_data   = me->response_data );
   */

  as$status();

  /*
   * If any object found.
   */
  ii = 0;
  if( me->nb_object ){

    /*
     * Increment of dynamic memory space.
     */
    if( me->nb_object > om$dimension_of(varray = me->l_object) ){

      status = om$vla_set_dimension(varray = me->l_object,
                                    size = 50*(1+me->nb_object/50));
      as$status( action = RET_STATUS );
    }

    /*
     * Save the objects in the instances. 
     */
    for(i=0;i<me->nb_object;i++) {
         /* filter out the objects with pid representation */
         status = om$send(msg = message ACncpx.ACget_NV_rep(&me->repres),
                targetid = buffer[i].objid,
                targetos = buffer[i].osnum ) ;
         if ( me->repres == 6) { 
             sprintf( mess, "Can't locate object with Diagram Representation");
             UI_status( mess);
             continue;
         }
         me->l_object[ii] = buffer[i];
         ii = ii + 1;
    }
    me->nb_object = ii;

    if( !ii ) {
	*sts = VD_OBJ_REP_DIAG;
        goto wrapup;
    }
    /*
     * Set the current representation in the form
     */
    status = om$send(msg = message ACncpx.ACget_NV_rep(&me->repres),
	  	targetid = me->l_object[0].objid,
	  	targetos = me->l_object[0].osnum ) ;
    as$status( action = RET_STATUS );

    me->app_rep = me->repres;
    for( row=0; row < me->num_rep; row++ ){

      if( me->repres == me->coll_list[row].desc.value.att_exp ){
      	FIfld_set_select(me->forms[0].form_ptr,VD_SELECT,row,0,TRUE);
	break;
      }
    }
  }
wrapup: 
  if ( ii ) me->nb_object = ii;  
  ASend_fence();
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        form_notification function                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

action form_notification
{
int  row, col;
long sts;

  switch ( gadget_label )      /* which gadget */
  {
  case FI_CANCEL:

    dp$erase_hilite( msg = &sts );

    me->rep_label = VD_REP_FORM_ACCEPT;
    _put_response( resp = VD_REP_FORM_INFO );

    break;
   
  case FI_EXECUTE:
  case FI_ACCEPT:
     
    status =
    om$send(msg      = message VDCmdChgRep.process_representation( &sts ),
	    targetid = my_id );
    as$status();

    dp$erase_hilite( msg = &sts );

    me->rep_label = ( gadget_label == FI_ACCEPT ) ? VD_REP_FORM_ACCEPT 
						  : VD_REP_FORM_EXECUTE ; 
    _put_response( resp = VD_REP_FORM_INFO );

    break;

  case VD_SELECT:

    FIfld_get_active_row(me->forms[0].form_ptr,VD_SELECT,&row,&col);
    me->app_rep = me->coll_list[row].desc.value.att_exp ; 

    break;
  }
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        process_representation function                     */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action process_representation
{
int index, row;           /* Index for a loop                          */
int rep, ii;
unsigned char nv_rep;

  /*| Change the representation of the elements */
  ex$message( msgnumb = VD_I_Process);

  for(index=0; index < me->nb_object; index++)
  {
    status = om$send(msg = message ACncpx.ACget_rep(&rep),
		targetid = me->l_object[index].objid,
		targetos = me->l_object[index].osnum ) ;
    if(!(status&1) || (rep&AC_DEP_REP) || !rep) continue;

    status = om$send(msg = message ACncpx.ACget_NV_rep(&nv_rep),
		targetid = me->l_object[index].objid,
		targetos = me->l_object[index].osnum ) ;
    if(!(status&1)) continue;


    if( nv_rep != me->app_rep ){
      status = om$send(msg = message ACncpx.ACset_NV_rep
                                        (me->app_rep,&me->ModuleInfo),
 			targetid = me->l_object[index].objid,
			targetos = me->l_object[index].osnum ) ;
    }

  }/* end for(index)*/

  nd$exec_batch(); 
  ex$message( msgnumb = AS_S_ToutBon);

  /*
   * Delete the selected option from the list.
   */
  ii = 0;
  if ( me->forms[0].form_ptr )
  {
    FIfld_set_num_rows( me->forms[0].form_ptr, VD_SELECT, me->num_rep );
    for( row=0; row<me->num_rep; row++ ){
        __DBGpr_str ( "coll_list", me->coll_list[row].name);
        if (!strcmp(me->coll_list[row].name, "Pid")) continue;
	FIfld_set_text( me->forms[0].form_ptr, VD_SELECT, ii, 0,
			me->coll_list[row].name, FALSE );
        ii = ii + 1;
    }
    FIfld_set_num_rows( me->forms[0].form_ptr, VD_SELECT, ii );
  }
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                              return_form function                          */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action return_form
{
  /*
   * status field in CEO_LOCATE to get return value of the
   * routine form_notification; sts is used in state table
   */

  *sts = me->rep_label;
}
action check_diag_ctl
{
long            	msg;
int             	diagCtl;
struct   ACrg_coll  	*dgnColl;
struct   GRid       	collId;

  SetProc( VDCmdChgRep.sl--check_diag_ctl); Begin
  /* yzhu check for diagram control par */
  diagCtl = -1;

  dgnColl = NULL;

  msg = MSFAIL;
  *sts = VD_DIAG_OFF;

  /*
   * check or make  the design collector: need to free dgnColl .
   * default diagCtl == 0.
   */
  status =  VDsetDgnDefColl( &msg, dgnColl, &collId );
  if ( !(status&msg&1) )  {
            UI_status( "Can't find design setup collector");
            *sts = VD_DIAG_COLL_NO;
            goto wrapup;
  }

  status = VDgetDiagCtlPar( &msg, &diagCtl);
  if ( !(status&msg&1) || diagCtl == -1) {
        UI_status(" Can't find design setup collector" );
        *sts = VD_DIAG_COLL_NO;
        goto wrapup;
  }
  if ( diagCtl == 1) {
          UI_status("Can't activate command: Diagram = ON" );
          *sts = VD_DIAG_ON;
          goto wrapup;
  }
wrapup:
  _FREE ( dgnColl ); 
  End
}
