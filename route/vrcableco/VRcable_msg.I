/* $Id: VRcable_msg.I,v 1.2 2001/02/20 01:11:53 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcableco / VRcable_msg.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcable_msg.I,v $
 *	Revision 1.2  2001/02/20 01:11:53  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
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
# Revision 1.5  1996/02/02  18:50:02  pinnacle
# Replaced: ./vrcableco/VRcable_msg.I for:  by azuurhou for route240
#
# Revision 1.3  1996/02/01  22:49:36  pinnacle
# Replaced: ./vrcableco/VRcable_msg.I for:  by azuurhou for route240
#
# Revision 1.2  1996/01/16  20:16:12  pinnacle
# Replaced: vrcableco/VRcable_msg.I for:  by r240_int for route240
#
 *
 * History:
 *	04/03/96	AdZ	created
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *
 *************************************************************************/
class implementation VRcablecon;

/* 
 * include files
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "igrdef.h"
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

#include "exmacros.h"
#include "bserr.h"
#include "bstypes.h"
#include "asbox.h"
#include "asdef.h"
#include "nddef.h"
#include "asmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "parametric.h"
#include "v_miscmacros.h"
#include "vrdbgmacros.h"

#include "dpstruct.h"
#include "VRcabledef.h"
#include "AS_status.h"
#include "vrcablec_pto.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bspt_on_lne.h"

%safe
#include "VX_FIproto.h"
%endsafe

#define	AS_DEBUG	1

/* 
 * Available Gadgets 
 *
 * predefined are :
 *	FI_CANCEL	( 4 )
 *	FI_RESET	( 3 )
 *	FI_EXECUTE	( 2 )
 *	FI_ACCEPT	( 1 )
 *	FI_MSG_FIELD	( 10 )
 */
#define	MCF1		12	/* colomn table  */
#define	L_CBSK_LOC	15	/* locate botton */
#define	L_CBSK_TRA	16	/* trace botton  */
/*
 * calling external functions
 */

extern	GRclassid	OPP_GR3dlinestr_class_id;
extern	GRclassid	OPP_VRcable_class_id;
extern	GRclassid	OPP_VDequipment_class_id;
extern	GRclassid	OPP_Gexp_class_id;
/*
 * insert messages calls 
 */
from	VRcable		import	NDplace;
from	NDmacro		import	ACreturn_foot;
from	NDnode		import	NDgive_structure,
				NDchg_state;
from	expression	import	NDset_value;
from	GRgraphics	import	GRdisplay;
from	GRvg		import	GRputname;

/* --------------------------------------------------------------------- */
/* VR_CABLE_INIT */
/* --------------------------------------------------------------------- */

method VRCbInit ( int * sts )
{
  int		  status = OM_S_SUCCESS;

IGRchar			error_message[CABLE_MAX_TXT];
IGRchar			expression_dir[CABLE_MAX_TXT];
IGRchar			act_path[CABLE_MAX_TXT];
IGRchar			tmp_buf[CABLE_MAX_TXT];
IGRchar			path[CABLE_MAX_TXT];
IGRint			i, ii, len;
OM_S_OBJID		cur_id;
OMuword			cur_os;
IGRint			index[50];
IGRlong			msg;
struct	GRid		tmp_obj;
struct	ret_struct	ret_str;
/*
 * initialisation of instance variables
 */
  *sts = MSSUCC;

  /* here the three cable expression are tested on exitence 	*/
  /* on contents if possible before the connect cable form	*/
  /* is displayed on the screen					*/
  /* the three expression are predefined in the include file	*/
  /* called VRcabledef.h					*/

  /*| test expressions directory */
  status = ex$get_cur_mod( id = &cur_id, osnum = &cur_os );
  status = di$give_pathname( osnum    = cur_os, pathname = expression_dir );

  if( status != DIR_S_SUCCESS ){
	/*| give_pathname failed again !! */
	*sts  = MSFAIL;
	return( OM_S_SUCCESS );
  }

  /* :usr: is added to get to the home directory			*/
  strcat( expression_dir, ":usr:" );
  strcat( expression_dir, CABLE_EXP_DIR );
  /*" expression_dir : <%s> \n", expression_dir */

  status = di$translate(	objname = expression_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

  if( status != DIR_S_SUCCESS ){
	/*| expression dir failed */
	*sts = MSFAIL;
	return( OM_S_SUCCESS );
  }

  /*| first expression : CABLE_EQUIP_TABLE */
  tmp_obj.objid = NULL_OBJID;
  status = di$translate( 	objname = CABLE_EQUIP_TABLE,
				path	= expression_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

  if( status == DIR_S_SUCCESS ){
    /*| test if file exist */
    status = om$send( msg = message NDnode.NDgive_structure(
					&msg,
					&ret_str,
					&me->ModuleInfo ),
				targetid = tmp_obj.objid,
				targetos = tmp_obj.osnum,
				senderid = NULL_OBJID );
	
    /*" equip_table: <%s> \n", ret_str.var.text_st.text_string */

    if( access( ret_str.var.text_st.text_string, 04 ) != 0 ){
	/*| file does not exist */
	*sts = MSFAIL;
	return( OM_S_SUCCESS );
    }
  }
  else{
	/*| expression EQUIP_TABLE does not exist */
	*sts = MSFAIL;
	return( OM_S_SUCCESS );
  }
		
  /*| second expression: CABLE_OUTPUT_FILE */
  tmp_obj.objid = NULL_OBJID;
  status = di$translate( 	objname = CABLE_OUTPUT_FILE,
				path	= expression_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

  if( status != DIR_S_SUCCESS ){
	/*| expression OUTPUT_FILE does not exist */
	*sts = MSFAIL;
	return( OM_S_SUCCESS );
  }

  /*| third expression : CABLE_WORKING_DIR */
  tmp_obj.objid = NULL_OBJID;
  status = di$translate( 	objname = CABLE_WORKING_DIR,
				path	= expression_dir,
				p_objid = &tmp_obj.objid,
				p_osnum = &tmp_obj.osnum );

  if( status != DIR_S_SUCCESS ){
	/*| expression WORKING_DIR does not exist */
	*sts = MSFAIL;
	return( OM_S_SUCCESS );
  }

  /*| initialisation of the field values */	
  me->Sketch_Par = VRCAB_DIGID;
  me->my_label	 = VRCAB_UNDEF;

  /* the setting of the  cable working directory requires a 		*/
  /* sequential creation of the subdirectories for defining		*/
  /* the total path; First step is to see if the directory exist 	*/
  /* if not the path has to be checked starting from the root		*/
  /* directory until the user defined working directory			*/

  /* ----------------------------------------------------------------- */
  /* get current working directory */
  /* ----------------------------------------------------------------- */
  status = di$pwd( dirname = act_path );
  if( status != DIR_S_SUCCESS){
	printf(" ERROR: cannot get active working directory\n");
	me->state = _terminate;
	return( OM_I_STOP_SENDING );
  }
  /*" save active directory <%s>\n", act_path */

  tmp_obj.objid = NULL_OBJID;
  strcpy( tmp_buf, CABLE_WORKING_DIR );
  status = VRCb_Object_Active( tmp_buf, &tmp_obj );
  if( status ){
    /*" obj : (%d/%d) \n", tmp_obj.objid, tmp_obj.osnum */

    /* get the exp_syntax for the CABLE_WORKING_DIR */
    status = om$send( msg = message NDnode.NDgive_structure( 
					&msg,
					&ret_str,
					&me->ModuleInfo),
			targetid = tmp_obj.objid,
			targetos = tmp_obj.osnum,
			senderid = NULL_OBJID );
  }
  strcpy( me->work_dir, ret_str.var.text_st.text_string );
  /*" work_dir : <%s> \n", me->work_dir */

  /* ------------------------------------------------------------------- */
  /*|test if strings are equal  */
  /* ------------------------------------------------------------------- */
  tmp_obj.objid = NULL_OBJID;
  status = di$translate( 	objname = me->work_dir,
				p_objid = &(tmp_obj.objid),
				p_osnum = &(tmp_obj.osnum) );

  if( status == DIR_S_SUCCESS ){
    /*| directory exist; set current directory */
    status = di$cd( dirname = me->work_dir );
    if( status != DIR_S_SUCCESS ){
      strcpy( error_message, " Attention!! Can not change working directory" );
      FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, error_message );
    }
  }
  else{	
    /*| create new directory */
    strcpy( tmp_buf, me->work_dir );
    if(tmp_buf[0] != ':' ){
      /*| pathname is invalid */
      strcpy( error_message, " Attention!! Can not change working directory" );
      FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, error_message);
    }
    else{
      /* create a new working directory */
      ii = 0;
      len = strlen( me->work_dir );
      for(i=1;i<len || tmp_buf[i]=='\0';i++) 
	if( tmp_buf[i] == ':' ) index[ii++] = i;

      index[ii++] = len;
      /*" nb_sub : %d \n", ii */
      i=0;
      while(i<ii){
	/*| get path */
	strcpy( path, tmp_buf );
	path[index[i++]] = '\0';
	/*" path : <%s> \n", path */
	tmp_obj.objid = NULL_OBJID;
	status = di$translate(	objname = path,
				p_objid = &(tmp_obj.objid),
				p_osnum = &(tmp_obj.osnum) );
	if( status != DIR_S_SUCCESS ){
	  /*" create dir <%s> \n", path */
	  status = di$mkdir( dirname = path );
	  if( status != DIR_S_SUCCESS ){
    	    strcpy( error_message, " Attention!! Can not change working directory" );
    	    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, error_message);
	    break;
	  }
	}
	status = di$cd( dirname = path );
	if( status != DIR_S_SUCCESS ){
	    strcpy( error_message, " Attention!! Can not change working directory" );
   	    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, error_message);
	    break;
	}
      }
    }
  }

  /* ------------------------------------------------------------------- */
  /*| reset working directory */
  /* ------------------------------------------------------------------- */
  status = di$cd( dirname = act_path );
  if( status !=  DIR_S_SUCCESS ){
    printf(" ERROR: cannot change dir to [%s]\n", act_path);
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }

return OM_S_SUCCESS;
}


method VRCbDefElements ( int * sts )
{
int		status = OM_S_SUCCESS;
IGRint		i;
IGRlong		msg;
IGRchar		msg_fld[CABLE_MAX_TXT];
IGRchar		sel_equip[CABLE_MAX_TXT];
IGRchar		sel_connt[CABLE_MAX_TXT];

  /* The selected line in the form is tested on existance before the	*/
  /* form will erased. During the checking the connection point 	*/
  /* information is defined						*/

  *sts = MSSUCC;

  if( me->Cable_Data == NULL ){
    __DBGpr_com(" Invalid Selection ...");
    strcpy( msg_fld, "Not Object Selected" );
    UI_status( msg_fld );
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }
	
  /*^ printf(" <%s> | <%s> | <%s> | <%s> | %f | %f | %d \n", 
		me->Cable_Data->Equipment1Str,  me->Cable_Data->Equipment2Str,
		me->Cable_Data->ConnectPnt1Str, me->Cable_Data->ConnectPnt2Str,
		me->Cable_Data->BendRadius,     me->Cable_Data->SectRadius,
		me->Cable_Data->start_index );
   */

  /* initialisation (connection pnts and equipments)	*/
  for(i=0;i<2;i++){
	me->CONN_PNTS[i].objid	= NULL_OBJID;
	me->CONN_PNTS[i].osnum	= me->ModuleInfo.md_id.osnum;
	me->EQUIP[i].objid	= NULL_OBJID;
	me->EQUIP[i].osnum	= me->ModuleInfo.md_id.osnum;
  }

 /*
  * Get the starting objects and connect feet name.
  */
  if( me->Cable_Data->start_index ){
    strcpy( sel_equip, me->Cable_Data->Equipment2Str );
    strcpy( sel_connt, me->Cable_Data->ConnectPnt2Str );
  }
  else{
    strcpy( sel_equip, me->Cable_Data->Equipment1Str );
    strcpy( sel_connt, me->Cable_Data->ConnectPnt1Str );
  }

  /*" Equipement_1 <%s>\n", sel_equip */
  if( ! VRCb_Equip_Active( sel_equip, &(me->EQUIP[0]) )){

    /*" Equipment <%s> not defined \n", sel_equip */
    sprintf( msg_fld, "Equipment [ %s ] not found ", sel_equip );
    UI_status( msg_fld );
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }
  else{
    /*| call ACreturn_foot */
    if( vd_$is_ancestry_valid(	object  = &(me->EQUIP[0]),
				classid = OPP_VDequipment_class_id )){
	if( strncmp( sel_connt, "graphics:", 9 ) != 0 ){

	  IGRchar	grBuf[CABLE_MAX_TXT];
	  strcpy( grBuf, "graphics:");
	  strcat( grBuf, sel_connt );
	  strcpy( sel_connt , grBuf );
	  __DBGpr_str("Add graphics FeetName ", sel_connt );
	}
    }

    status = om$send( msg = message NDmacro.ACreturn_foot(
					&msg,
					sel_connt,
					&me->CONN_PNTS[0],
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix ),
			targetid = me->EQUIP[0].objid,
			targetos = me->EQUIP[0].osnum );

    if(! (status&msg&1) || (me->CONN_PNTS[0].objid == NULL_OBJID) ){

      me->CONN_PNTS[0].objid = NULL_OBJID;
      /*| Cable Connection: msg ACreturn_foot failed */
      sprintf( msg_fld, "Connect Point [ %s ] not found in [ %s ]", 
				sel_connt, sel_equip );
      UI_status( msg_fld );
      *sts = MSFAIL;
      return( OM_S_SUCCESS );
    } 		
    else{
      /*| call make_source */
      ASmake_source_from_env( &me->CONN_PNTS[0], &me->ModuleInfo, &me->CONN_PNTS[0]);
    }
  }

 /*
  * Get the ending object and connect feet name.
  */
  if( me->Cable_Data->start_index ){
    strcpy( sel_equip, me->Cable_Data->Equipment1Str );
    strcpy( sel_connt, me->Cable_Data->ConnectPnt1Str );
  }
  else{
    strcpy( sel_equip, me->Cable_Data->Equipment2Str );
    strcpy( sel_connt, me->Cable_Data->ConnectPnt2Str );
  }

  /* find end connection point */
  /*" Equipement_2 <%s>\n", sel_equip */
  if( ! VRCb_Equip_Active( sel_equip, &(me->EQUIP[1]) )){

    /*" Equipment <%s> not defined \n", sel_equip */
    sprintf( msg_fld, "Equipment [ %s ] not found ", sel_equip );
    UI_status( msg_fld );
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }
  else{
    /* get connection point location and create object */		  
    if( vd_$is_ancestry_valid(	object  = &(me->EQUIP[1]),
				classid = OPP_VDequipment_class_id )){
	if( strncmp( sel_connt, "graphics:", 9 ) != 0 ){

	  IGRchar	grBuf[CABLE_MAX_TXT];
	  strcpy( grBuf, "graphics:");
	  strcat( grBuf, sel_connt );
	  strcpy( sel_connt , grBuf );
	  __DBGpr_str("Add graphics FeetName ", sel_connt );
	}
    }

    status = om$send( msg = message NDmacro.ACreturn_foot(
					&msg,
					sel_connt,
					&me->CONN_PNTS[1],
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix ),
			targetid = me->EQUIP[1].objid,
			targetos = me->EQUIP[1].osnum );

    as$status( action = RET_STATUS );
    if( !(status&msg&1) || (me->CONN_PNTS[1].objid == NULL_OBJID) ){

      me->CONN_PNTS[1].objid = NULL_OBJID;
      /*| Cable Connection: msg ACreturn_foot failed */
      sprintf( msg_fld, "Connect Point [ %s ] not found in [ %s ]", 
				sel_connt, sel_equip );
      UI_status( msg_fld );
      *sts = MSFAIL;
      return( OM_S_SUCCESS );
    }
    else{
      /*| call make_source */
      ASmake_source_from_env( &me->CONN_PNTS[1], &me->ModuleInfo, &me->CONN_PNTS[1]);
    }
  }
  /*" sta_pnt(%d/%d) \n", me->CONN_PNTS[0].objid, me->CONN_PNTS[0].osnum */
  /*" end_pnt(%d/%d) \n", me->CONN_PNTS[1].objid, me->CONN_PNTS[1].osnum */

return( OM_S_SUCCESS );
}

method VRCbRetrieveFile ( int * sts )
{
int		  	status = OM_S_SUCCESS;
FILE			*file_ptr;
IGRlong			msg;
IGRint			i, r, row;
IGRchar			tmp_buf[CABLE_MAX_TXT];
IGRchar			buff[CABLE_MAX_BUF];
struct	GRid		tmp_obj;
struct ret_struct	ret_str;

  *sts = MSSUCC;
	
  /* each time this routine is called the connect cable form	*/
  /* will be reset according to the current situation in the	*/
  /* drawing file.						*/

  file_ptr	= NULL;
  tmp_obj.objid = NULL_OBJID;
  strcpy( tmp_buf, CABLE_EQUIP_TABLE );

  status = VRCb_Object_Active( tmp_buf, &tmp_obj );
  if( status ){
    /*| get the exp_syntax for the CABLE_EQUIP_TABLE */
    status = om$send( msg = message NDnode.NDgive_structure(
					&msg,
					&ret_str,
					&me->ModuleInfo ),
			targetid = tmp_obj.objid,
			targetos = tmp_obj.osnum,
			senderid = NULL_OBJID );
    as$status( action = RET_STATUS );
  }
  else {	/*| return( OM_I_STOP_SENDING ); */
		return( FALSE );
  }

  /*" file_name : <%s> \n", ret_str.var.text_st.text_string */
  if((file_ptr = (FILE *)fopen( ret_str.var.text_st.text_string , "r")) == NULL ){
    printf("Can't open file \n");
    return( FALSE );
  }

  /*| Count number cables from ASCII file */
  me->Max_List = 0;
  while( fgets( buff, sizeof(buff), file_ptr ) != NULL ) me->Max_List++;
  /*" Max_List : %d\n", me->Max_List */

  status = om$vla_set_dimension( 	varray = me->Cable_List,
					size = me->Max_List );
  as$status( action = RET_STATUS );

  /*| go to the beginnig of the file */
  rewind( file_ptr );

  /*| display the connect cable form */	
  status = FIf_display( me->forms[0].form_ptr );
  if( status != FI_SUCCESS ){
	printf("\nCable Connection: fct FIf_display() sts = %d\n", status);
	me->state = _terminate;
	return( OM_I_STOP_SENDING );
  }
  
  /*| get line in buffer */
  r = 0;
  row = 0;	/* display row index */
  while( fgets( buff, sizeof(buff), file_ptr ) != NULL ){
    if( sscanf( buff,"%s %s %s %s %s %s %s", 
		me->Cable_List[r].CableNameStr,
		me->Cable_List[r].Equipment1Str,
		me->Cable_List[r].ConnectPnt1Str,
		me->Cable_List[r].Equipment2Str,
		me->Cable_List[r].ConnectPnt2Str,
		me->Cable_List[r].BendRadiusStr,
		me->Cable_List[r].SectRadiusStr ) == 7 ){

      /*" Cable_Name = <%s> \n", me->Cable_List[r].CableNameStr */

      /*| test if cable exist in drawing system */
      if( ! VRCb_Object_Active( me->Cable_List[r].CableNameStr, &tmp_obj )){

	/*| new cable found */
	FIfld_set_text(me->forms[0].form_ptr,MCF1,row,0,me->Cable_List[r].CableNameStr  , FALSE );
	FIfld_set_text(me->forms[0].form_ptr,MCF1,row,1,me->Cable_List[r].Equipment1Str , FALSE );
	FIfld_set_text(me->forms[0].form_ptr,MCF1,row,2,me->Cable_List[r].ConnectPnt1Str, FALSE );
	FIfld_set_text(me->forms[0].form_ptr,MCF1,row,3,me->Cable_List[r].Equipment2Str , FALSE );
	FIfld_set_text(me->forms[0].form_ptr,MCF1,row,4,me->Cable_List[r].ConnectPnt2Str, FALSE );
	me->Cable_List[r].BendRadius = atof( me->Cable_List[r].BendRadiusStr );
	me->Cable_List[r].SectRadius = atof( me->Cable_List[r].SectRadiusStr );

	me->Cable_List[r].not_displayed = TRUE;
	r++;
	row++;
      }
      else{
	/*| cable exist */
	me->Cable_List[r].not_displayed = FALSE;
	r++;
      }
    }
  }

  tmp_buf[0] = '\0';
  for(i=0; i<5; i++)
	FIfld_set_text(me->forms[0].form_ptr,MCF1,row,i,tmp_buf, FALSE );
  
  for(i=r;i<me->Max_List;i++) me->Cable_List[r].not_displayed = FALSE;

  /*| close the input file */
  fclose( file_ptr );

  /*^ 
    for(r=0; r<me->Max_List; r++ ){
      printf(" %s %s %s %s %s %s %s | %f %f | %d\n", 
			me->Cable_List[r].CableNameStr,
			me->Cable_List[r].Equipment1Str,
			me->Cable_List[r].ConnectPnt1Str,
			me->Cable_List[r].Equipment2Str,
			me->Cable_List[r].ConnectPnt2Str,
			me->Cable_List[r].BendRadiusStr,
			me->Cable_List[r].SectRadiusStr,
			me->Cable_List[r].BendRadius,
			me->Cable_List[r].SectRadius,
			me->Cable_List[r].not_displayed );
    }
   */

return	OM_S_SUCCESS;
}

method VRCbInitLine ( int * sts )
{
int		  	status = OM_S_SUCCESS;
IGRint			i, j;
IGRlong			msg;
IGRchar			msg_fld[CABLE_MAX_TXT];
struct	ret_struct	ret_str;

  /* during the interactive drawing of the cable a temporary	*/
  /* buffer will be used to store the cable points		*/
  /* in this routine the connection points are get and the buffer	*/
  /* is stored with the startpoint of the cable			*/

  *sts = MSSUCC;
  /*| get start point */
  status = om$send( msg = message NDnode.NDgive_structure(
					&msg,
					&ret_str,
					&me->ModuleInfo ),
			targetid = me->CONN_PNTS[0].objid,
			targetos = me->CONN_PNTS[0].osnum,
			senderid = NULL_OBJID );
  if( ! (status&1) ){
    /*| Cable Class : msg NDgive_structure failed */
    if( me->Cable_Data->start_index )
      sprintf( msg_fld, "No reference matrix for [ %s ] defined ", me->Cable_Data->ConnectPnt2Str );
    else
      sprintf( msg_fld, "No reference matrix for [ %s ] defined ", me->Cable_Data->ConnectPnt1Str );
    UI_status( msg_fld );
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }

  j = 0;
  for(i=0;i<3;i++){	me->start_vec[i] = ret_str.var.ref_st.t[j];
			me->start_pnt[i] = ret_str.var.ref_st.t[j+3];
			j = j + 4;
  }
  /*"st_pnt: %f %f %f\n",me->start_pnt[0],me->start_pnt[1], me->start_pnt[2] */
  /*"st_vec: %f %f %f\n",me->start_vec[0],me->start_vec[1], me->start_vec[2] */

  /*| get end point */
  status = om$send( msg = message NDnode.NDgive_structure(
					&msg,
					&ret_str,
					&me->ModuleInfo),
			targetid = me->CONN_PNTS[1].objid,
			targetos = me->CONN_PNTS[1].osnum,
			senderid = NULL_OBJID );
  if( ! (status&1) ){
    /*| Cable Class : msg NDgive_structure failed */
    if( me->Cable_Data->start_index )
      sprintf( msg_fld, "No reference matrix for [ %s ] defined ", me->Cable_Data->ConnectPnt1Str );
    else
      sprintf( msg_fld, "No reference matrix for [ %s ] defined ", me->Cable_Data->ConnectPnt2Str );
    UI_status( msg_fld );
    *sts = MSFAIL;
    return( OM_S_SUCCESS );
  }

  j = 0;
  for(i=0;i<3;i++){	me->end_vec[i] = ret_str.var.ref_st.t[j];
			me->end_pnt[i] = ret_str.var.ref_st.t[j+3];
			j = j + 4;
  }
  /*" end_pnt : %f %f %f\n", me->end_pnt[0], me->end_pnt[1], me->end_pnt[2] */
  /*" end_vec : %f %f %f\n", me->end_vec[0], me->end_vec[1], me->end_vec[2] */

  /* initialisation for the line string and display */
  me->If_First_Point	= FALSE;
  me->If_Rway_Point	= FALSE;
  me->cur_elmt 		= 0;
  me->max_elmt		= VRCAB_MAXBUF;
  me->line.num_points	= 0;
  me->line.points	= me->my_pnts;

  /*| set start point */
  for(i=0;i<3;i++) me->my_pnts[i] = me->start_pnt[i];
  me->line.num_points 	= 1;
  me->cur_elmt 	    	= 3;
  me->If_First_Point	= TRUE;

return( OM_S_SUCCESS );
}

method VRCbEndLine ( int * sts )
{
int		  	status = OM_S_SUCCESS;
IGRint			i;
IGRdouble		delta, negpnt[3], pospnt[3];
BSrc			rc;
IGRshort		exp_msg;
IGRlong			msg, line_msg;
IGRuchar		prep;
IGRchar			msg_fld[CABLE_MAX_TXT];
IGRchar			act_path[CABLE_MAX_TXT];
IGRchar			exp_name[CABLE_MAX_TXT], exp_synt[CABLE_MAX_TXT];
struct	GRid		disp_info, cable, temp_obj[5];
struct	GRas		asso_lis;
struct	GRsymbology	esymb;
struct	GRvg_construct	line_cst;

  /* after all the intermediare cable points are given the		*/
  /* cable buffer is added with the end connection point of 		*/
  /* the final equipment.						*/
  /* Then the cable message is called to draw the final cable		*/
  /* with help of the cable data, bend radius, cable radius and		*/
  /* the two equipments and two connection points			*/

  *sts = MSSUCC;

  if( me->Cable_Data->BendRadius < me->Cable_Data->SectRadius)
		delta = 1.001 * me->Cable_Data->SectRadius;
  else 	delta = me->Cable_Data->BendRadius;
	
  for(i=0;i<3;i++){
    negpnt[i] = me->end_pnt[i] - ( delta * me->end_vec[i] );
    pospnt[i] = me->end_pnt[i] + ( delta * me->end_vec[i] );
  }
	
  /*^ printf(" neg : %f %f %f \n", negpnt[0], negpnt[1], negpnt[2]); 
      printf(" pos : %f %f %f \n", pospnt[0], pospnt[1], pospnt[2]); 
      printf(" last data : %f %f %f \n",me->my_pnts[me->cur_elmt-3],
					me->my_pnts[me->cur_elmt-2],
					me->my_pnts[me->cur_elmt-1] );
   */

  if( BSdistptpt( &rc, &(me->my_pnts[me->cur_elmt-3]), negpnt ) <
      BSdistptpt( &rc, &(me->my_pnts[me->cur_elmt-3]), pospnt ) ){

    /*| add negpnt */
    status = om$send( msg = message VRcablecon.VRCbAddPnt( sts, negpnt ),
			targetid = my_id );
    as$status( action = RET_STATUS );			

  }
  else{
    /*| add pospnt */
    status = om$send( msg = message VRcablecon.VRCbAddPnt( sts, pospnt ),
			targetid = my_id );
    as$status( action = RET_STATUS );			
  } 

  /*--------------------------------------------------------------*/
  /*	add end point in list					*/
  /*--------------------------------------------------------------*/
  status = om$send( msg = message VRcablecon.VRCbAddPnt( sts, me->end_pnt ),
			targetid = my_id );
  as$status( action = RET_STATUS );			

  /* | start and end object */
  temp_obj[0] = me->CONN_PNTS[0];
  temp_obj[1] = me->CONN_PNTS[1];

  /* init expression objects */
  for(i=2;i<5;i++){
    temp_obj[i].objid = NULL_OBJID;
    temp_obj[i].osnum = me->ModuleInfo.md_id.osnum;
  }

  /* ----------------------------------------------------------------- */
  /*| create expression for section radius */
  /* ----------------------------------------------------------------- */
  sprintf( exp_name, "%s_sect", me->Cable_Data->CableNameStr );
  status = om$construct( msg = message expression.NDset_value(
						NULL,
						me->Cable_Data->SectRadius,
						&me->ModuleInfo,
						&exp_msg ),
			classid = OPP_Gexp_class_id,
			osnum   = me->ModuleInfo.md_id.osnum,
			p_objid = &temp_obj[2].objid );
  as$status( action = RET_STATUS );

  /* ----------------------------------------------------------------- */
  /*| create expression for bend radius */
  /* ----------------------------------------------------------------- */
  sprintf( exp_name, "%s_bend", me->Cable_Data->CableNameStr );
  status = om$construct( msg = message expression.NDset_value(
						NULL,
						me->Cable_Data->BendRadius,
						&me->ModuleInfo,
						&exp_msg ),
			classid = OPP_Gexp_class_id,
			osnum   = me->ModuleInfo.md_id.osnum,
			p_objid = &temp_obj[3].objid );
  as$status( action = RET_STATUS );

  /* ----------------------------------------------------------------- */
  /*| save working directory */
  /* ----------------------------------------------------------------- */
  /* get current working directory */
  status = di$pwd( dirname = act_path );
  if( status != DIR_S_SUCCESS){
    printf(" ERROR: cannot get active working directory\n");
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }
  /*" act_path :<%s>\n", act_path */
	
  /*| goto working directory */
  status = di$cd( dirname = me->work_dir );
  if( status != DIR_S_SUCCESS ){
    strcpy( msg_fld, " ERROR: Cable env not defined in directory");
    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, msg_fld );
  }

  /* ----------------------------------------------------------------- */
  /*| create the envelope thickness */
  /* ----------------------------------------------------------------- */

  /* the envelope thickness will be initiated as the offset of		*/
  /* the cable radius (sect radius). The default setting is equal	*/
  /* to zero (delta)							*/

  sprintf( exp_name, "%s_env", me->Cable_Data->CableNameStr );
  delta = 0.0;
  /* ------------------------------------------------------------------ */
  /* printf(" exp_name :<%s>\n", exp_name );				*/
  /* printf(" dirname  :<%s>\n", me->work_dir );			*/
  /* ------------------------------------------------------------------ */
  status = di$translate( 	objname = exp_name,
				path	= me->work_dir,
				p_objid = &(temp_obj[4].objid),
				p_osnum = &(temp_obj[4].osnum) );
  if( status != DIR_S_SUCCESS ){
    /*| create CABLE_EQUIP_TABLE */

/* FIX TR # 179418177 		MALLIK		*/
/* exp$create was creating a problem with exp_value so changed to exp_syntax */

    sprintf( exp_synt, "%20.9lf", delta ); 
    if( exp$create(	exp_name  = exp_name, 
			exp_syntax= exp_synt,
			p_exp_id  = &(temp_obj[4].objid) ) != EXP_S_SUCCESS ){
	    
      UI_status(" Can not create expression ");
      me->state = _terminate;
      return( OM_I_STOP_SENDING );
    }
  }
  else{ 
    /*| Modify existing expression */
    sprintf( exp_synt, "%20.9lf", delta ); 
    if( exp$modify(	exp_id = temp_obj[4].objid,
			osnum  = temp_obj[4].osnum,
			exp_syntax = exp_synt ) != EXP_S_SUCCESS ){
      UI_status(" Can not modify expression ");
      me->state = _terminate;
      return( OM_I_STOP_SENDING );
    }
  }

  /* ----------------------------------------------------------------- */
  /*| reset working directory */
  /* ----------------------------------------------------------------- */
  status = di$cd( dirname = act_path );
  if( status !=  DIR_S_SUCCESS ){
    printf(" ERROR: cannot change dir to [%s]\n", act_path);
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }

  /* ----------------------------------------------------------------- */
  /*| set the delete/save state on */
  /* ----------------------------------------------------------------- */
  for( i=2; i<5; i++ ){
    status = om$send( msg = message NDnode.NDchg_state( ~0,
					(IGRchar) ND_DEL_NO_CH | ND_WAIT_DEL ),
			targetid = temp_obj[i].objid,
			targetos = temp_obj[i].osnum,
			senderid = NULL_OBJID );
    as$status( action = RET_STATUS );
  }

  /* ----------------------------------------------------------------- */
  /* | representation mode */
  /* ----------------------------------------------------------------- */
  ac$get_def_NVrep( prep = &prep, esymb = &esymb );
  if( !prep ) prep = AC_3D_REP;

  asso_lis.num_parents = 5;
  asso_lis.parents     = temp_obj;
  asso_lis.as_attr     = (IGRchar *)&prep;

  /*^
    printf(" sta_obj(%d/%d)\n",temp_obj[0].objid,temp_obj[0].osnum );
    printf(" end_obj(%d/%d)\n",temp_obj[1].objid,temp_obj[1].osnum );
    printf(" sec_rad(%d/%d)\n",temp_obj[2].objid,temp_obj[2].osnum );
    printf(" ben_rad(%d/%d)\n",temp_obj[3].objid,temp_obj[3].osnum );
    printf(" env_thi(%d/%d)\n",temp_obj[4].objid,temp_obj[4].osnum );
    printf(" LINE ( %d )\n", me->line.num_points );
    for(i=0; i< me->line.num_points; i++ )
	printf(" pnt[%d] : %f %f %f \n", i,me->my_pnts[3*i],
			me->my_pnts[3*i+1],me->my_pnts[3*i+2] );
    printf(" sect_rad : %f\n", me->Cable_Data->SectRadius );
    printf(" bend_rad : %f\n", me->Cable_Data->BendRadius );
  */

  /* ----------------------------------------------------------------- */
  /*| construct cable object */
  /* ----------------------------------------------------------------- */
  line_cst.msg		= &line_msg;
  line_cst.properties	= GRIS_LOCATABLE | GRIS_NEW | GRIS_DISPLAYABLE;
  line_cst.display 	= &me->ActiveDisplay;
  line_cst.env_info	= &me->ModuleInfo;
  line_cst.newflag	= FALSE;
  line_cst.level	= me->ActiveLevel;
  line_cst.class_attr	= NULL;
  line_cst.name		= NULL;
  line_cst.geometry	= (IGRchar *)&me->line;

  /* ----------------------------------------------------------------- */
  /* | place one cable object */
  /* ----------------------------------------------------------------- */
  cable.objid = NULL_OBJID;
  cable.osnum = me->ModuleInfo.md_id.osnum ;

  status = om$construct( msg = message VRcable.NDplace(
						&asso_lis, 
						&me->ModuleInfo, 
						(IGRchar *)&line_cst ),
			classid = OPP_VRcable_class_id,
			osnum   = me->ModuleInfo.md_id.osnum,
			p_objid = &cable.objid );

  as$status( action = RET_STATUS );
  as$status( action = GOTO_VALUE, value = wrapup );
  /*" cable obj : %d/%d \n", cable.objid, cable.osnum */

  /* ----------------------------------------------------------------- */
  /*| save working directory */
  /* ----------------------------------------------------------------- */
  status = di$pwd( dirname = act_path );
  if( status != DIR_S_SUCCESS){
    printf(" ERROR: cannot get active working directory\n");
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }
  /*" act_path :<%s>\n", act_path */
	
  /*| goto working directory */
  status = di$cd( dirname = me->work_dir );
  if( status != DIR_S_SUCCESS ){
    sprintf( msg_fld, " ERROR: Cable name <%s> not defined in directory ", me->Cable_Data->CableNameStr );
    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, msg_fld );
  }

  /* ----------------------------------------------------------------- */
  /*| put name in directory */	
  /* ----------------------------------------------------------------- */
  status = om$send(msg = message GRvg.GRputname(
					&msg,
					me->Cable_Data->CableNameStr),
		 targetid = cable.objid,
		 targetos = cable.osnum,
		 senderid = NULL_OBJID ); 
  as$status( action = RET_STATUS );
  as$status( action = GOTO_VALUE, value = wrapup );

  sprintf( exp_name, "%s_env", me->Cable_Data->CableNameStr );
  /* ----------------------------------------------------------------- */
  /*| reset working directory */
  /* ----------------------------------------------------------------- */
  status = di$cd( dirname = act_path );
  if( status !=  DIR_S_SUCCESS ){
    printf(" ERROR: cannot change dir to [%s]\n", act_path);
    me->state = _terminate;
    return( OM_I_STOP_SENDING );
  }

  GRfindmod(&disp_info);
  /*| display the object */
  status = om$send( msg = message GRgraphics.GRdisplay(
				&msg,
				&me->ModuleInfo.md_env.matrix_type,
				me->ModuleInfo.md_env.matrix,
				&me->DisplayMode,
				&disp_info ),
			targetid = cable.objid,
			targetos = cable.osnum,
			senderid = NULL_OBJID );
  as$status( action = RET_STATUS );

  /*| update the cable list */
  for( i=0; i<me->Max_List; i++){
    if( strcmp( me->Cable_List[i].CableNameStr, me->Cable_Data->CableNameStr) == 0 )
		     me->Cable_List[i].not_displayed = FALSE;
  }
 
  return( OM_S_SUCCESS );

wrapup:

  if( cable.objid != NULL_OBJID ){
    /*| delete cable object */
	  om$send( 	msg	 = message Root.delete(1),
			targetid = cable.objid,
			senderid = NULL_OBJID );
  }
  /* delete expressions */
  for( i=2; i<5; i++ ){
    if( temp_obj[i].objid != NULL_OBJID ){
      /*" delete expression[%d] object\n", i */
	    om$send( 	msg	 = message Root.delete(1),
			targetid = temp_obj[i].objid,
			senderid = NULL_OBJID );
    }
  }
  *sts = MSFAIL;
  return( OM_E_ABORT );
}


method VRCbHilightEquip( int * sts )
{
int		status = OM_S_SUCCESS;
IGRint		i;
IGRlong		msg;
enum	GRdpmode dpmode;
struct	GRid	disp_info;

  /* hilighting of the selected equipments during	*/
  /* the interactive drawing			*/

  *sts = MSSUCC;

  GRfindmod(&disp_info);
  dpmode = GRhdo;	/* hilight mode */

  /*| display the object */

  for(i=0;i<2;i++){
    status = om$send(	msg = message GRgraphics.GRdisplay(
				&msg,
				&me->ModuleInfo.md_env.matrix_type,
				me->ModuleInfo.md_env.matrix,
				&dpmode,
				&disp_info ),
			targetid = me->EQUIP[i].objid,
			targetos = me->EQUIP[i].osnum,
			senderid = NULL_OBJID );
    as$status( action = RET_STATUS );
  }

return( OM_S_SUCCESS );
}

method VRCbUnhilightEquip( int * sts )
{
int	status = OM_S_SUCCESS;
IGRint	i;
IGRlong	msg;
enum	GRdpmode dpmode;
struct	GRid	disp_info;

  /* unhilight the equipments; Necessary after the interactive	*/
  /* drawing and during special requestes			*/

  *sts = MSSUCC;

  GRfindmod(&disp_info);
  dpmode = GRheo;
  /*| display the object */

  for(i=0;i<2;i++){
    status = om$send( msg = message GRgraphics.GRdisplay(
				&msg,
				&me->ModuleInfo.md_env.matrix_type,
				me->ModuleInfo.md_env.matrix,
				&dpmode,
				&disp_info ),
			targetid = me->EQUIP[i].objid,
			targetos = me->EQUIP[i].osnum,
			senderid = NULL_OBJID );
    as$status( action = RET_STATUS );
  }

return( OM_S_SUCCESS );
}

method VRCbPushPnt ( int * sts )
{
int		status = OM_S_SUCCESS;
IGRint		i;
IGRlong		rc, retmsg;
IGRboolean	online;
IGRdouble	u_val, event_pnt[3], tmp_end[3], next_pnt[3];

  /* a point is accepted for the cable. Three kinds of points		*/
  /* are expected, namely an ordinaire data point, a R'way points	*/
  /* which has to be located on the centerline of the VR_PIPE 		*/
  /* component or the first data point, which has to be on the		*/
  /* x-as of the connection-point					*/

  *sts = MSSUCC;

  if( me->If_Rway_Point == TRUE ){
    /*| VRRWay component point */

    event_pnt[0] = me->event1.event.button.x;
    event_pnt[1] = me->event1.event.button.y;
    event_pnt[2] = me->event1.event.button.z;

    /*" event_pnt : %f %f %f \n",event_pnt[0],event_pnt[1],event_pnt[2] */

    status = VRCbGetProjectPnt(	me->Rway_start_pnt,	/* start_pnt */
				me->Rway_start_vec,
				event_pnt,
				me->Z_Window,
				next_pnt );	/* result pnt */
    if( ! status ){
      /*| function VRCbGetProjectPnt failed */
      *sts = MSFAIL;
      return( OM_S_SUCCESS );
    }

    BSpt_on_lne( &rc, me->Rway_start_pnt, me->Rway_end_pnt,
		 next_pnt, &u_val, &online );
    if( rc != BSSUCC ){
      /*| error in BSpt_on_line */ 
    }
    else{
      /*" test if online %d\n", online  */
      if( online == FALSE ){
	/*| find the external values */
	if( BSdistptpt( &rc, me->Rway_start_pnt, next_pnt ) <
	    BSdistptpt( &rc, me->Rway_end_pnt,   next_pnt ) ){
	  /*| cur_pt equal to start_pnt */
	  for(i=0;i<3;i++) next_pnt[i] = me->Rway_start_pnt[i];
	}
	else{
	  /*| cur_pt equal to end_pnt */
	  for(i=0;i<3;i++) next_pnt[i] = me->Rway_end_pnt[i];
    	}
      } /* if online */
    }	  
    me->If_Rway_Point = FALSE;
  }
  else if( me->If_First_Point ){

    /*| startpoint for cable */  
    event_pnt[0] = me->event1.event.button.x;
    event_pnt[1] = me->event1.event.button.y;
    event_pnt[2] = me->event1.event.button.z;

    /*" event_pnt : %f %f %f \n",event_pnt[0],event_pnt[1],event_pnt[2] */

    status = VRCbGetProjectPnt(	me->start_pnt,	/* start_pnt */
				me->start_vec,
				event_pnt,	/* next_pnt */
				me->Z_Window,
				next_pnt );	/* result pnt */
    if( ! status ){
      /*| function VRCbGetProjectPnt failed */
      *sts = MSFAIL;
      return( OM_S_SUCCESS );
    }

    for(i=0;i<3;i++) tmp_end[i] = me->start_pnt[i] + ( 200 * me->start_vec[i] );
    BSpt_on_lne( &rc, me->start_pnt, tmp_end, next_pnt, &u_val, &online );
    if( rc != BSSUCC ){
      /*| error in BSpt_on_line */ 
    }
    else{
	  /*| No Modif on start_point */
    }
  }
  else{
	IGRboolean VRVerifyBendRad ();

    /*| general point */					
    next_pnt[0] = me->event1.event.button.x;
    next_pnt[1] = me->event1.event.button.y;
    next_pnt[2] = me->event1.event.button.z;

    if ( !VRVerifyBendRad ( &retmsg, me->line.num_points, me->my_pnts, next_pnt,
		me->Cable_Data->BendRadius) ) 
    {
	/* Display failure message */
	if ( retmsg == 1 )
	{
		ex$message ( 	field = ERROR_FIELD,
/*			msgnumb = VR_BLOP_MSG); */
				in_buff = "Previous segment is too short");
	}
	else
	{
		ex$message ( 	field = ERROR_FIELD,
/*			msgnumb = VR_BLOP_MSG); */
				in_buff = "Current segment is too short");
	}
	/* Exit without taking the point */
	return OM_S_SUCCESS;
    }

    
  }

  status = om$send( msg = message VRcablecon.VRCbAddPnt( sts, next_pnt ),
		    targetid = my_id );
  as$status( action = RET_STATUS );			

return( OM_S_SUCCESS );
}

method VRCbPopPnt ( int * sts )
{
IGRint			prev;
IGRlong			msg;
struct  DPele_header    element;
struct	IGRdisplay	myDisplay;

  /* incase an point is not accepted the cable buffer 		*/
  /* is reduced with one point. To optimalise the user		*/
  /* interface, the line buffer is displayed in the 		*/
  /* backgroud color to erase the display from the screen	*/

  *sts = MSSUCC;
  myDisplay.color	= 0;	/* background color */
  myDisplay.weight	= me->ActiveDisplay.weight;
  myDisplay.style	= me->ActiveDisplay.style;

  dp$build_dis_buffer(	buffer      = &element,
			type        = IGRPY,
			display_att = &myDisplay,
			geometry    = &me->line );

  dp$erase_hilite(msg	= &msg);
  dp$display(	msg 	= &msg,
	   	buffer	= &element);

  if( me->line.num_points > 0 ){
    me->line.num_points--;
    me->cur_elmt -= 3;
    prev = me->cur_elmt - 3;
    /*" place prev pnt : %d \n", prev */

  }

  if( me->line.num_points == 1 ){
    /*| IF_FIRST_POINT set to TRUE */
    me->If_First_Point = TRUE;
  }

return( OM_S_SUCCESS );
}

method VRCbDisplayLine ( int * sts )
{
IGRlong			msg;
struct  DPele_header    element;

  /* display the buffer on the screen. In case all points	*/
  /* are removed by PopPnt, this routines MSFAIL to 		*/
  /* indicate the cable is refuced				*/

  *sts = MSSUCC;

  if( me->line.num_points < 1 ){
    *sts = MSFAIL;
    /*| no cable line */
    return( OM_S_SUCCESS );
  }

  if( me->line.num_points > 1 ){
    dp$build_dis_buffer(	buffer      = &element,
                                type        = IGRPY,
                                display_att = &me->ActiveDisplay,
                                geometry    = &me->line );

    dp$erase_hilite(msg	= &msg);
    dp$display(	msg 	= &msg,
	   	buffer	= &element);
  }

  /*^IGRint i;
    printf(" LINE ( %d )\n", me->line.num_points );
    for(i=0; i< me->line.num_points; i++ )
		printf(" pnt[%d] : %f %f %f \n", i, me->my_pnts[3*i],
				me->my_pnts[3*i+1], me->my_pnts[3*i+2] );
   */

return( OM_S_SUCCESS );
}

end implementation VRcablecon;
