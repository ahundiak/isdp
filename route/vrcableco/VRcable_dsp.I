/* $Id: VRcable_dsp.I,v 1.1.1.1 2001/01/04 21:12:41 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcableco / VRcable_dsp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcable_dsp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:41  cvs
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
# Revision 1.5  1996/02/06  08:36:02  pinnacle
# Replaced: vrcableco/VRcable_dsp.I for:  by ashankar for route240
#
# Revision 1.4  1996/02/01  22:49:16  pinnacle
# Replaced: ./vrcableco/VRcable_dsp.I for:  by azuurhou for route240
#
# Revision 1.3  1996/01/16  20:15:56  pinnacle
# Replaced: vrcableco/VRcable_dsp.I for:  by r240_int for route240
#
 *
 * History:
 *	04/03/96	AdZ	created
 *	01/15/96	tlb	Add VX_FIproto.h
 *				Comment out call to BSproj0
 *
 *************************************************************************/
class implementation VRcablecon;

/* 
 * include files
 */
#include <stdio.h>
#include <string.h>

#include "OMtypes.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "FI.h"
#include "CIforms.h"
#include "ODE.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "msdef.h"
#include "msmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "EC_S.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"

#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"

#include "grgs.h"		/* group set includes */
#include "grgsmacros.h"

#include "bstypes.h"
#include "bsparameters.h"
#include "growner.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "dpstruct.h"
#include "VRcabledef.h"
#include "AS_status.h"
#include "vrcablec_pto.h"
#include "bsdistptpt.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG	1
/* 
 * used gadget numbers
 */
#define	MCF1		12	/* colomn table  */
#define	L_CBSK_LOC	15	/* locate botton */
#define	L_CBSK_TRA	16	/* trace botton  */
/*
 * calling external functions
 */


extern	GRclassid	OPP_GRgrset_class_id;

/*
 * insert messages calls 
 */
from	VRGeneric	import	VRGetTopo;
from	VRGeneric	import	VRGetSysType;
from	GRgrset		import	GSget_object;


/* ---------------------------------------------------------------------- */
/* VR_CABLE_ERASE_SKETCH */
/* ---------------------------------------------------------------------- */

method VRCbEraseSketch ( int * sts )
{
int status = OM_S_SUCCESS;

  /* erase the sketch and reset the sketch parameter */
  /* label L_CBSK_LOC : Label Cable Sketch Location		*/

  *sts = MSSUCC;
	
  me->Sketch_Par = VRCAB_UNDEF ;
  FIg_set_state_off( me->forms[1].form_ptr, L_CBSK_LOC );
  FIf_erase( me->forms[1].form_ptr );

return( OM_S_SUCCESS );
}

/* ---------------------------------------------------------------------- */
/* VR_CABLE_DISPLAY_SKETCH */
/* ---------------------------------------------------------------------- */

method VRCbDisplaySketch ( int * sts )
{
int status = OM_S_SUCCESS;

  /* display the sketch on screen and reset the sketch parameter	*/
  /* label L_CBSK_LOC : Label Cable Sketch Location		*/

  *sts = MSSUCC;

  me->Sketch_Par = VRCAB_UNDEF;
  FIg_set_state_off( me->forms[1].form_ptr, L_CBSK_LOC );
  FIf_display( me->forms[1].form_ptr );

return( OM_S_SUCCESS );
}

/* ---------------------------------------------------------------------- */
/* VR_CABLE_SET_RETURN */
/* ---------------------------------------------------------------------- */

method VRCbSetReturn ( int * sts )
{
int status = OM_S_SUCCESS;

  /* states field in CEO_LOCATE get the return value of the 	*/
  /* routine form_notification; sts is used in state table	*/

   *sts = me->my_label;
  /*" sts = %d \n", *sts */

return( OM_S_SUCCESS );
}

/* ---------------------------------------------------------------------- */
/* VR_CABLE_EXIT_TABLE */
/* ---------------------------------------------------------------------- */

method VRCbExitTable ( int * sts )
{
int status = OM_S_SUCCESS;

  /* clear the exiting messages in menu and erase the form from	*/	
  /* screen and local memory					*/
	
  *sts = MSSUCC;

  ex$message( msgnumb = EMS_P_ClearPromptField );
  /*ex$message( msgnumb = EMS_M_ClearMessageField );*/
  ex$message( msgnumb = EMS_S_ClearStatusField );

  status = FIf_erase( me->forms[0].form_ptr );
  if( status != FI_SUCCESS ){
    printf("\nCable Connection: fct FIf_delete() sts = %d\n", status);
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }

return( OM_S_SUCCESS );
}

/* ---------------------------------------------------------------------- */
/* VR_CABLE_ERASE_TABLE */
/* ---------------------------------------------------------------------- */

method VRCbEraseTable ( int * sts )
{
int status = OM_S_SUCCESS;

IGRchar	err_msg[CABLE_MAX_TXT];

  /* the connect cable form will be erased from screen;		*/
  /* the cable_date will be checked before erasing the form; in	*/
  /* case of missing cable data an error message is displayed	*/

  *sts = MSSUCC;

  if( me->Cable_Data->CableNameStr[0]   == '\0' ||
      me->Cable_Data->Equipment1Str[0]  == '\0' ||
      me->Cable_Data->Equipment2Str[0]  == '\0' ||
      me->Cable_Data->ConnectPnt1Str[0] == '\0' ||
      me->Cable_Data->ConnectPnt2Str[0] == '\0' ){
		
    strcpy( err_msg, " No connection point selected !! " );
    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, err_msg);
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }

  /* |  erase the connect cable form */	
  status = FIf_erase( me->forms[0].form_ptr );
  if( status != FI_SUCCESS ){
    printf("\nCable Connection: fct FIf_erase() sts = %d\n", status);
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }

return( OM_S_SUCCESS );
}


/* ---------------------------------------------------------------------- */
/* VR_CABLE_DISPLAY_TABLE */
/* ---------------------------------------------------------------------- */

method VRCbDisplayTable ( int * sts )
{
int status = OM_S_SUCCESS;

IGRint	row, col, i;
IGRchar tmp_buf[CABLE_MAX_TXT];

  /* This method read the Cable_List, which contains the active situation */
  /* of all the cables from the input file. 				  */
  /* Cables which are not defined will be displayed on the screen. 	  */

  *sts = MSSUCC;

  /* delete all the previous values */
  status = FIfld_set_max_num_rows( me->forms[0].form_ptr, MCF1, 0);
  if( status != FI_SUCCESS ){
	printf("\nCable Connection: fct FLfld_set_max_num_rows sts = %d \n", status );
	*sts = MSFAIL;
	return( OM_E_ABORT );
  }
  /* init the form list */
  status = FIfld_set_max_num_rows( me->forms[0].form_ptr, MCF1, me->Max_List );
  if( status != FI_SUCCESS ){
	printf("\nCable Connection: fct FLfld_set_max_num_rows sts = %d \n", status );
	*sts = MSFAIL;
	return( OM_E_ABORT );
  }

  /*| cleanup the contents of the colomns */
  tmp_buf[0] = '\0';
  for( row=0; row<me->Max_List; row++ )
    for( col=0; col<5; col++)
      FIfld_set_text(me->forms[0].form_ptr,MCF1,row,col,tmp_buf,FALSE );

  /*| Fill in the form */

  me->Cable_Data = NULL ;
  row = 0;
  for( i=0; i<me->Max_List; i++){			

    if( me->Cable_List[i].not_displayed ){
      /*" set Cable_Name = <%s> \n", me->Cable_List[i].CableNameStr */


      FIfld_set_text(me->forms[0].form_ptr,MCF1,row,0,
				me->Cable_List[i].CableNameStr  ,FALSE );
      FIfld_set_text(me->forms[0].form_ptr,MCF1,row,1,
				me->Cable_List[i].Equipment1Str ,FALSE );
      FIfld_set_text(me->forms[0].form_ptr,MCF1,row,2,
				me->Cable_List[i].ConnectPnt1Str,FALSE );
      FIfld_set_text(me->forms[0].form_ptr,MCF1,row,3,
				me->Cable_List[i].Equipment2Str ,FALSE );
      FIfld_set_text(me->forms[0].form_ptr,MCF1,row,4,
				me->Cable_List[i].ConnectPnt2Str,FALSE );

      /* increment of row */
      row++;
    }
  }

  tmp_buf[0] = '\0';
  for(col=0; col<5; col++)
	FIfld_set_text(me->forms[0].form_ptr,MCF1,row,col,tmp_buf,FALSE );

  FIfld_set_select( me->forms[0].form_ptr, MCF1, 0, 2, FALSE );

  /*| set state of form */
  FIg_set_state_off( me->forms[0].form_ptr, FI_ACCEPT );
  FIg_set_state_off( me->forms[0].form_ptr, FI_CANCEL );

  /*|  display the connect cable form */	
  status = FIf_display( me->forms[0].form_ptr );
  if( status != FI_SUCCESS ){
	printf("\nCable Connection: fct FIf_display() sts = %d\n", status);
	me->state = _terminate;
	return( OM_I_STOP_SENDING );
  }

return( OM_S_SUCCESS );
}

/* ---------------------------------------------------------------------- */
/* VR_CABLE_GET_COMPONENT */
/* ---------------------------------------------------------------------- */

method VRCbGetComp ( int * sts )
{
int status = OM_S_SUCCESS;

IGRlong 	msg; 
IGRint 		cur_size, BufSize, NbCpts;
IGRint		set_count, i, ii;
IGRdouble	dCompOrig[3], LastPnt[3], EndPnt1[3], EndPnt2[3];
IGRdouble	dCpCoors[3*VR_MAX_CPTS], next_pnt[3];
IGRshort	sys_type;
GRclassid	sender_class;
IGRboolean	Reverse_Dir;
BSrc		rc;
struct	GRid	tmp_obj;

	*sts 		= MSSUCC;
	BufSize 	= VR_MAX_CPTS;
	Reverse_Dir	= FALSE;
	me->If_Rway_Point = FALSE;
	me->NumVRRCompObjects 	= 0;

	/* Get component has to handle three kinds of objects, namely 	*/
	/* two type of individual VRRComp's (VR_PIPE and VR_ELBOW) and	*/
	/* a set of VRRComp's given by a graphical set (class GRgrset)	*/

	/*" CompId: %d \n", me->event1.located_object[0].located_obj.objid */
	/*" CompOs: %d \n", me->event1.located_object[0].located_obj.osnum */

	/* to find out which type is used the object is checked by it's	*/
	/* class identifier						*/

	om$get_classid(	osnum	= me->event1.located_object[0].located_obj.osnum,
			objid	= me->event1.located_object[0].located_obj.objid,
			p_classid = &sender_class );
	/*" class_id  :  %d \n", sender_class */
	
	/* only the VRRComp are controlled of existing type */ 
	if( sender_class != OPP_GRgrset_class_id ){

	  status = om$send( msg = message VRGeneric.VRGetSysType(
					&msg,
					&sys_type ),
			
		targetid = me->event1.located_object[0].located_obj.objid,
		targetos = me->event1.located_object[0].located_obj.osnum,
		senderid = NULL_OBJID );
	  as$status( action = RET_STATUS );

	  /*" sys_type : %d \n", sys_type */
	  if( sys_type == VR_PIPE ){

	    /*| get connection points */
	    status = om$send( msg = message VRGeneric.VRGetTopo( 
					&msg,
					BufSize,
					&NbCpts,
					dCompOrig,
					dCpCoors,
					NULL, NULL,
					&me->ModuleInfo ),
			  targetid =  me->event1.located_object[0].located_obj.objid,
			  targetos =  me->event1.located_object[0].located_obj.osnum,
  			  senderid = NULL_OBJID );
	    as$status( action = RET_STATUS );
		
	    /*" Cor1: %f %f %f \n", dCpCoors[0], dCpCoors[1], dCpCoors[2] */
	    /*" Cor2: %f %f %f \n", dCpCoors[3], dCpCoors[4], dCpCoors[5] */

	    /* get start/end point and it's vector for dynamic drawing 	*/
	    /* to calculate the next cable point 			*/

	    for(i=0;i<3;i++){
	      me->Rway_start_pnt[i] = dCpCoors[i];
	      me->Rway_end_pnt[i]   = dCpCoors[3+i];
	      me->Rway_start_vec[i] = dCpCoors[3+i] - dCpCoors[i];
	    }  

	    /* set dynamics type on for drawing */
	    me->If_Rway_Point = TRUE;
	    *sts = VRCAB_RWAY_COMP;
	    return( OM_S_SUCCESS );
	  } /* if sys_type */
	} /* if sender_class */

	if( sender_class == OPP_GRgrset_class_id ){
	  /*| get grset elements */
	  set_count = 0;
	  status = gr$gsinqcount( msg	= &msg,
				  count	= &set_count,
				  senderid = NULL_OBJID,
				  object_id = &me->event1.located_object[0].located_obj );

	  if( msg != MSSUCC ) status = OM_W_ABORT;
	  as$status( action = RET_STATUS );
	  /*" count : %d \n", set_count */
	  
	  cur_size = om$dimension_of( varray = me->VRRCompObjects );
	  if( cur_size < set_count ){
	    /*| increment of VRRCompObjects */
	    status = om$vla_set_dimension( varray = me->VRRCompObjects,
					   size   = set_count + 1 );
	    as$status( action = RET_STATUS );
	  }
	  cur_size = om$dimension_of( varray = me->ResVRRCompObjects );
	  if( cur_size < set_count ){
	    /*| increment of ResVRRCompObjects */
	    status = om$vla_set_dimension( varray = me->ResVRRCompObjects,
					   size   = set_count + 1 );
	    as$status( action = RET_STATUS );
	  }
	  
	  cur_size = set_count * sizeof( struct GRobj_env );
	  /*" size : %d \n", cur_size */
	  
	  status = om$send( msg = message GRgrset.GSget_object(
					&msg,
					me->VRRCompObjects,
					cur_size,
					&me->NumVRRCompObjects,
					0,
					OM_K_MAXINT ),
			    targetid = me->event1.located_object[0].located_obj.objid,
			    targetos = me->event1.located_object[0].located_obj.osnum,
			    senderid = NULL_OBJID );
	  as$status( action = RET_STATUS );

	  /*" NumCable : %d \n", me->NumVRRCompObjects */
	  if( ! me->NumVRRCompObjects ){
		/*| me->NumVRRCompObjects is 0 */
		*sts = MSFAIL;
		goto wrapup;
	  }
/*^
	  for(i=0; i<me->NumVRRCompObjects; i++ ){	  
		printf("Set Objects[%d] : [%d,%d]\n", i,
				me->VRRCompObjects[i].obj_id.objid,
				me->VRRCompObjects[i].obj_id.osnum );
	  }
*/
	  if( ! VRCbGetSeqList(	&me->NumVRRCompObjects,
				me->VRRCompObjects,
				me->ResVRRCompObjects ) ){
		/*| error in VRCbGetSeqList */
		*sts = MSFAIL;
		goto wrapup;
	  }
	  /*" Num : %d\n", me->NumVRRCompObjects */
/*^
	  printf(" NumCable : %d \n", me->NumVRRCompObjects );
	  for(i=0; i<me->NumVRRCompObjects; i++ ){
		printf("Res Objects[%d] : [%d,%d]\n", i,
				me->ResVRRCompObjects[i].obj_id.objid,
				me->ResVRRCompObjects[i].obj_id.osnum );
	  }
*/
	  /* the object with the smallest distance between latest cable point	*/
	  /* and one of the end component will be the starting point for the	*/
	  /* group set 								*/

	  /* get first end point */
	  status = om$send( msg = message VRGeneric.VRGetTopo( 
					&msg,
					BufSize,
					&NbCpts,
					EndPnt1,
					NULL, NULL, NULL,
					&me->ModuleInfo ),
			  targetid = me->ResVRRCompObjects[0].obj_id.objid,
			  targetos = me->ResVRRCompObjects[0].obj_id.osnum,
			  senderid = NULL_OBJID );
	  as$status( action = RET_STATUS );
	  
	  /* get second end point */
	  status = om$send( msg = message VRGeneric.VRGetTopo( 
					&msg,
					BufSize,
					&NbCpts,
					EndPnt2,
					NULL, NULL, NULL,
					&me->ModuleInfo ),
			  targetid = me->ResVRRCompObjects[me->NumVRRCompObjects-1].obj_id.objid,
			  targetos = me->ResVRRCompObjects[me->NumVRRCompObjects-1].obj_id.osnum,
			  senderid = NULL_OBJID );
	  as$status( action = RET_STATUS );

	  /* get latest cable point */
	  for(i=0;i<3;i++) LastPnt[i] = me->my_pnts[(me->cur_elmt-3)+i];

	  /*" Lastpnt : %f %f %f \n", LastPnt[0], LastPnt[1], LastPnt[2] */
	  /*" Endpnt1 : %f %f %f \n", EndPnt1[0], EndPnt1[1], EndPnt1[2] */
	  /*" Endpnt2 : %f %f %f \n", EndPnt2[0], EndPnt2[1], EndPnt2[2] */
	  /*" distPnt1: %f \n", BSdistptpt( &rc, LastPnt, EndPnt1 ) */
	  /*" distPnt2: %f \n", BSdistptpt( &rc, LastPnt, EndPnt2 ) */

	  /* if second point is nearer to latest cable point, reverse the 	*/
	  /* direction of list treatment					*/

	  if( BSdistptpt( &rc, LastPnt, EndPnt1 ) > 
	      BSdistptpt( &rc, LastPnt, EndPnt2 ) ){
	    /*| the reverse direction */
	    Reverse_Dir = TRUE;
	  }
	}
	else {
		/*| one VRRComp object */
		me->NumVRRCompObjects = 1;
		me->ResVRRCompObjects[0].obj_id.objid = me->event1.located_object[0].located_obj.objid;
		me->ResVRRCompObjects[0].obj_id.osnum = me->event1.located_object[0].located_obj.osnum;
	}

	/*| evaluate the found objects */
	for( i=0; i<me->NumVRRCompObjects; i++ ){
	    
	    if( Reverse_Dir ){
		tmp_obj.objid = me->ResVRRCompObjects[(me->NumVRRCompObjects-1)-i].obj_id.objid;
		tmp_obj.osnum = me->ResVRRCompObjects[(me->NumVRRCompObjects-1)-i].obj_id.osnum;
	    }
	    else{
		tmp_obj.objid = me->ResVRRCompObjects[i].obj_id.objid;
		tmp_obj.osnum = me->ResVRRCompObjects[i].obj_id.osnum;
	    }
	    /* get the object sys_type */
	    status = om$send( msg = message VRGeneric.VRGetSysType(
					&msg,
					&sys_type ),		
	   		targetid = tmp_obj.objid,
			targetos = tmp_obj.osnum,
			senderid = NULL_OBJID );
	    as$status( action = RET_STATUS );

	    status = om$send( msg = message VRGeneric.VRGetTopo( 
					&msg,
					BufSize,
					&NbCpts,
					dCompOrig,
					dCpCoors,
					NULL, NULL,
					&me->ModuleInfo ),
			  targetid = tmp_obj.objid,
			  targetos = tmp_obj.osnum,
			  senderid = NULL_OBJID );
	    as$status( action = RET_STATUS );

	    /*" Orig : %f %f %f \n", dCompOrig[0], dCompOrig[1], dCompOrig[2] */


	    /* check if the object of type VR_PIPE; if type is VR_PIPE then	*/
	    /* calculate the point intermedian between the two end points	*/

	    if( sys_type == VR_PIPE ){
	      /*| get median point of the VR_PIPE */
	      for(ii=0; ii<3; ii++ )
		next_pnt[ii] = (dCpCoors[3+ii] + dCpCoors[ii]) / 2.0;
	    }
	    else {
	      /*| set point in buffer */
	      for(ii=0; ii<3; ii++ ) next_pnt[ii] = dCompOrig[ii];
	    }

	    status = om$send( msg = message VRcablecon.VRCbAddPnt(
							sts, next_pnt ),
				targetid = my_id );
	    as$status( action = RET_STATUS );			

	} /* for */

wrapup:

return( OM_S_SUCCESS );
}

/* ---------------------------------------------------------------------- */
/* VR_CABLE_ADD_PNT */
/* ---------------------------------------------------------------------- */

method VRCbAddPnt ( int *sts; double *pnt; )
{
int 	status = OM_S_SUCCESS;
IGRint	i,cur_size;
BSrc	rc;

  /* before a point is added the buffer is checked and	*/
  /* increased if necessary				*/

  *sts = MSSUCC;

  cur_size = om$dimension_of( varray = me->my_pnts );
  if( me->cur_elmt + 3 >= cur_size ){
    me->max_elmt = cur_size + VRCAB_INCRBUF;
    status = om$vla_set_dimension( varray = me->my_pnts,
				   size   = me->max_elmt );
    as$status( action = RET_STATUS );
  }

  /* " cur  : %f %f %f\n", me->my_pnts[me->cur_elmt-3],me->my_pnts[me->cur_elmt-2],me->my_pnts[me->cur_elmt-1] */
  /* " pnt  : %f %f %f\n", pnt[0], pnt[1], pnt[2] */

#ifdef POURQUOI_CA

  if( me->line.num_points == 1 ){

    IGRdouble pospnt[3], negpnt[3];
    IGRdouble delta;

    /*| add start support point in list */
    if( me->Cable_Data->BendRadius < me->Cable_Data->SectRadius)
		delta = 1.001 * me->Cable_Data->SectRadius;
    else 	delta = me->Cable_Data->BendRadius;
	
    for(i=0;i<3;i++){
      negpnt[i] = me->start_pnt[i] - ( delta * me->start_vec[i] );
      pospnt[i] = me->start_pnt[i] + ( delta * me->start_vec[i] );
    }
	
    /*^ printf(" neg : %f %f %f \n", negpnt[0], negpnt[1], negpnt[2]); 
        printf(" pos : %f %f %f \n", pospnt[0], pospnt[1], pospnt[2]); 
        printf(" last data : %f %f %f \n", me->my_pnts[me->cur_elmt-3],
  		me->my_pnts[me->cur_elmt-2], me->my_pnts[me->cur_elmt-1] );
     */

    if( BSdistptpt( &rc, pnt, negpnt ) < BSdistptpt( &rc, pnt, pospnt )){
      /*| add negpnt */
      for(i=0;i<3;i++) me->my_pnts[me->cur_elmt+i] = negpnt[i];
      me->line.num_points++;
      me->cur_elmt += 3;
    }
    else{
      /*| add pospnt */
      for(i=0;i<3;i++) me->my_pnts[me->cur_elmt+i] = pospnt[i];
      me->line.num_points++;
      me->cur_elmt += 3;
    }
  }
#endif

  if( BSBASISVAL <= BSdistptpt( &rc, &(me->my_pnts[me->cur_elmt-3]), pnt )){

    /*| add point in list */
    for(i=0;i<3;i++) me->my_pnts[me->cur_elmt+i]   = pnt[i];

    /* increment number of points */
    me->line.num_points++;
    me->cur_elmt += 3;
    /* " num_pnts : %d cur_elmt : %d \n", me->line.num_points, me->cur_elmt*/

    /* test first point */
    if( me->line.num_points >= 1 ){
      /* | IF_FIRST_POINT set to FALSE */
      me->If_First_Point = FALSE;
    }
  }

return( OM_S_SUCCESS );
}

end implementation VRcablecon;
