/* $Id: VDCmdtxldri.I,v 1.3 2001/01/21 16:18:47 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdtxldri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdtxldri.I,v $
 *	Revision 1.3  2001/01/21 16:18:47  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/19 23:10:24  jayadev
 *	*** empty log message ***
 *	
# Revision 1.3  2000/05/04  14:49:10  pinnacle
# Replaced: vds/vdannot/cmd/VDCmdtxldri.I for:  by impd252 for Service Pack
#
# Revision 1.2  2000/05/04  00:33:12  pinnacle
# Replaced: vds/vdannot/cmd/VDCmdtxldri.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/03  21:10:04  pinnacle
# Created: vds/vdannot/cmd/VDCmdtxldri.I by apazhani for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/09/18  03:07:16  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldri.I for:  by mdong for vds
#
# Revision 1.2  1997/08/26  22:06:36  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldri.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.21  1996/05/09  22:36:18  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldri.I for:  by yzhu for vds.240
#
# Revision 1.20  1996/05/04  16:47:44  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldri.I for:  by yzhu for vds.240
#
# Revision 1.19  1996/05/02  12:07:16  pinnacle
# Replaced: ./vdannot/cmd/VDCmdtxldri.I for:  by azuurhou for vds.240
#
# Revision 1.18  1996/04/18  15:10:26  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldri.I for:  by yzhu for vds.240
#
# Revision 1.17  1996/04/12  03:01:52  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldri.I for:  by yzhu for vds.240
#
# Revision 1.12  1996/02/16  23:54:32  pinnacle
# Replaced: ./vdannot/cmd/VDCmdtxldri.I for:  by azuurhou for vds.240
#
# Revision 1.11  1996/02/06  07:00:52  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldri.I for:  by rchennup for vds.240
#
# Revision 1.10  1995/09/08  21:28:00  pinnacle
# Replaced: vdannot/cmd/*.I for:  by jwfrosch for vds.240
#
# Revision 1.9  1995/07/25  22:49:18  pinnacle
# Replaced: vdannot/cmd/* for:  by jwfrosch for vds.240
#
# Revision 1.8  1995/07/13  15:29:22  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldri.I for:  by jwfrosch for vds.240
#
# Revision 1.7  1995/06/27  23:16:26  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldri.I for:  by azuurhou for vds.240
#
# Revision 1.5  1995/02/06  16:20:36  pinnacle
# Replaced:  vdannot/cmd/VDCmdtxldri.I r#
#
# Revision 1.4  1995/01/26  16:44:22  pinnacle
# Replaced:  vdannot/cmd/VDCmdtxldri.I tr# 179524547
#
# Revision 1.3  1995/01/19  19:44:04  pinnacle
# Replaced:  vdannot/cmd/VDCmdtxldri.I r#
#
# Revision 1.2  1995/01/13  20:29:54  pinnacle
# Replaced:  vdannot/cmd/VDCmdtxldri.I r#
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
 *      05/07/96        yzhu            change all VDtxbox to VDfrmtxt 
 *      05/03/2000      Alwin			Modified the display_form and 
 *										notify_form method to implement the
 *										Box Ratio. CR179901299
 * -------------------------------------------------------------------*/

class implementation VDCmdtxldr;

#include <stdio.h>
#include <string.h>

#include "OMerrordef.h"
#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrdef.h"
#include "igrmacros.h"
#include "msdef.h"
#include "exdef.h"
#include "AS_status.h"
#include "AS_debug.h"

#include "grdpbmacros.h"
#include "grerr.h"
#include "exmacros.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

#include "ACattrib.h"
#include "nddef.h"
#include "ndmacros.h"
#include "macro.h"
#include "asbox.h"
#include "grownmacros.h"
#include "acdef.h"
#include "acmacros.h"

#include "parametric.h"
#include "expression.h"
#include "expmacros.h"

#include "FI.h"
#include "VDSannot.h"
#include "VDmsg.h"

#include "form_env.h"
#include "dimformdef.h"
#include "dimform.h"
#include "dimgraph.h"
#include "vddrwattr.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#include "AS_debug.h"
#include "AS_status.h"

/* foreign methods */
from	ACcpx		import	find_macro, ACfind_exp_temp_obj;
from	ACcpx_defn	import	ACgive_name;
from	NDnode		import	NDdelete, NDconnect, NDgive_structure,
				NDchg_state, NDcompute_node;
from	VDfrmtxt	import	set_box_type;
from    VDfrmtxt        import  VDsetAttribute;
from	IGRdir		import	dump;
from 	DMroot		import  replace_text;
from	text_exp	import	create;
from	ci_macro	import	init;
from    GRvg            import  GRgetattr;
from    NDmacro         import  ACreturn_foot;

extern GRclassid	OPP_text_exp_class_id,
			OPP_nci_macro_class_id,
			OPP_VDfrmtxt_class_id,
			OPP_VDdrw2d_class_id,
			OPP_VDitbln_class_id,
			OPP_ACcpx_class_id;

extern			VDSinit_ldexpr();

#define			DEF_FORMAT 12
#define			AS_DEBUG 1

/*****
 * global constant to get track of latest box_type.
 */

//%safe
  unsigned char VDannot_box_type;
//%endsafe

/**
extern	unsigned char VDannot_box_type;
 */

extern IGRdouble VDCmdtxldr_text_angle;
extern unsigned char VDCmdtxldr_flag;
extern VDCmdtxldr_text_flag;

/************************************************************************/
/* METHOD wakeup							*/
/************************************************************************/

method wakeup ( int pos )
{
  long sts, status = OM_S_SUCCESS;
  int label;

  SetProc( VDCmdtxldri.wakeup) ; Begin 
  status =
  om$send(msg = message COanplace.wakeup (pos),
	  mode = OM_e_wrt_message,
	  targetid = my_id );
  as$status(action = RET_STATUS);

  VDCmdtxldr_flag = 1;

  /*| update the expression list */
  status =
  om$send(msg = message VDCmdtxldr.get_exist_formats( &sts ),
  	  targetid = my_id );
  as$status();
  
  status =
  om$send(msg = message VDCmdtxldr.get_parent_formats( &sts ),
  	  targetid = my_id );
  as$status();
  
  status =
  om$send(msg = message VDCmdtxldr.get_global_formats( &sts ),
  	  targetid = my_id );
  as$status();
  
  status =
  om$send(msg = message VDCmdtxldr.disp_exist_formats( &sts, TRUE ),
  	  targetid = my_id );
  as$status();

  /*
   * display according the selected object box layout
   */
  me->an_box_type = ( VDannot_box_type == 0 ) ? VD_box_NO_DISPLAY :
						VDannot_box_type ;
  VDannot_box_type = me->an_box_type;

  label = VD_BOX_NO;
  if( me->an_box_type & VD_box_DISPLAY )   label = VD_BOX_YES;

  /* get rid off VD_BOX_AUTO 
   if( me->an_box_type & VD_box_AUTOMATIC ) label = VD_BOX_AUTO; 
  */

  if( me->an_box_type & VD_box_ELLIPSE )   label = VD_BOX_ELLIPSE;

  status =
  om$send(msg = message VDCmdAnnot.notify_form( 0, label, 0.0, me->form ),
	  targetid = my_id );
  as$status();

  End
  return OM_S_SUCCESS;
}

/************************************************************************/
/* METHOD place_dimension						*/
/************************************************************************/

method place_dimension()
{
long sts, status = OM_S_SUCCESS;
int  i, size, global;
struct GRid null_grid;

  SetProc( VDCmdtxldri.place_dimension) ; Begin  
  status = om$send(msg = message COanplace.delete_dimension(),
                     targetid = my_id);
  as$status(action = RET_STATUS);

  /*
   * test if a global directory is defined
   */
  global = FALSE;
  size = om$dimension_of( varray = me->macro_list );
  for( i=0; i<size; i++){
    if( strcmp( VD_FTEXT_GLOBAL, me->macro_list[i].macro ) == 0 ){
      global = TRUE;
      break;
    }
  }

  /* test if macro has defined formatted text expressions */
  size = om$dimension_of( varray = me->macro_list );
  for( i=0; i<size; i++){
    if( strcmp( me->macro_name, me->macro_list[i].macro ) == 0 ){
      /*| found exist macro occurence */
      break;
    }
  }

  if( i == size && ! global ){
    /*| macro has no definitions */
    status = om$send(msg = message COanplace.delete_dimension(),
                     targetid = my_id);
    as$status(action = RET_STATUS);

    ex$message(msgnumb = VD_S_NoForMacro, type = "%s", var = `me->macro_name` );
    me->macro_name[0] = '\0';
    return( OM_S_SUCCESS );
  }

  /* place the text with leader */
  status =
  om$send(msg = message VDCmdAnnot.place_dimension(),
	  targetid = my_id,
	  mode = OM_e_wrt_message);
  as$status(action = RET_STATUS);
  if(me->an_grid.objid == NULL_OBJID) return OM_S_SUCCESS;

  /*
   * set the box_type option.
   */
  status =
  om$send(msg = message VDfrmtxt.set_box_type( &sts, me->an_box_type ),
	  targetid = me->an_grid.objid,
	  targetos = me->an_grid.osnum,
	  senderid = NULL_OBJID );
  as$status(action=RET_STATUS);

  /* create a new ci_macro format */
  status =
  om$send(msg = message VDCmdtxldr.txt_output( &sts ),
	  targetid = my_id );
  as$status(action = RET_STATUS );

  End
  return OM_S_SUCCESS;
}

/************************************************************************/
/* METHOD LC_selection							*/
/************************************************************************/

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
long 		sts, status = OM_S_SUCCESS;
int             msg1;
struct GRid 	macro, obj_to_test, Format_Text, Params_Text;
char 		*c;

  SetProc( VDCmdtxldri.LC_selection) ; Begin

  *msg = OM_S_SUCCESS;

  /*
   * reset the ci_macro occurence to null, to recreate a
   * ci_macro object.
   * Distroy the nci_macro object to avoid recompution before
   * saving the file.
   */
  if( me->MACRO_OCC.objid != NULL_OBJID ){
    /* tr 179601491 delete objects for Format_Text and Params_Text*/
    Format_Text.objid = NULL_OBJID; 
    status =
    om$send(msg = message  ACcpx.ACfind_exp_temp_obj(&msg1, 1, &Format_Text ),
	    targetid = me->MACRO_OCC.objid,
	    targetos = me->MACRO_OCC.osnum,
	    senderid = NULL_OBJID );
    as$status(action = RET_STATUS);

    __DBGpr_obj( "Format_Text", Format_Text);
 
    Params_Text.objid = NULL_OBJID; 
    status =
    om$send(msg = message  ACcpx.ACfind_exp_temp_obj(&msg1, 2, &Params_Text),
	    targetid = me->MACRO_OCC.objid,
	    targetos = me->MACRO_OCC.osnum,
	    senderid = NULL_OBJID );
    as$status(action = RET_STATUS);

    __DBGpr_obj( "Params_Text", Params_Text);

    if( Format_Text.objid != NULL_OBJID ) {
        status =
        om$send(msg = message NDnode.NDdelete(&me->md_env),
            targetid = Format_Text.objid,
            targetos = Format_Text.osnum,
            senderid = NULL_OBJID );
        as$status(action = RET_STATUS);
    }

    if( Params_Text.objid != NULL_OBJID ) { 
    	status =
    	om$send(msg = message NDnode.NDdelete(&me->md_env),
            targetid = Params_Text.objid,
            targetos = Params_Text.osnum,
	    senderid = NULL_OBJID );
    	as$status(action = RET_STATUS);
    }


    status =
    om$send(msg = message NDnode.NDdelete(&me->md_env),
            targetid = me->MACRO_OCC.objid,
            targetos = me->MACRO_OCC.osnum,
            senderid = NULL_OBJID );
    as$status(action = RET_STATUS);
  }
  me->MACRO_OCC.objid = NULL_OBJID;

  if(me->state != WAIT_MAC){
    __DBGpr_com(" VDCmdAnnot.LC_selection --0 ");
    status =
    om$send(msg = message VDCmdAnnot.LC_selection(msg,lc_info),
	    targetid = my_id,
	    mode = OM_e_wrt_message);
    as$status( action = RET_STATUS );
    __DBGpr_com(" VDCmdAnnot.LC_selection --1 ");
  }
  else
  {
    obj_to_test.objid = NULL_OBJID;
    if( DMancestry_valid(lc_info->located_obj, OPP_ACcpx_class_id )){
      obj_to_test = lc_info->located_obj;}
    else if( DMancestry_valid(lc_info->located_obj, OPP_VDitbln_class_id )){
      /* find macro of VDitbln object */
      VDget_macro_from_item(	&lc_info->located_obj,&obj_to_test,
				&lc_info->module_info);
    }

    if( obj_to_test.objid != NULL_OBJID)
    {
      me->HDR_OCC.mod_env = lc_info->module_info;

      /*
       * Check if located object is in a Drawing View
       * If this is true, then replace it with the originating Model object
       */
      {
	VDpartAttr	attr;
	IGRlong		rc;

	attr.Iwant	= VD_I_drwParentObj;

	if( DMancestry_valid( obj_to_test, OPP_VDdrw2d_class_id ) == OM_S_SUCCESS )
	{
	  status =
	  om$send (	msg	 = message GRvg.GRgetattr( &rc, (char *)&attr ),
			targetid = obj_to_test.objid,
			targetos = obj_to_test.osnum );
	  if ( status & rc & 1 )
	  {
	    obj_to_test		= attr.obj.obj_id;
	    me->HDR_OCC.mod_env = attr.obj.mod_env;
	  }
	}
      }

      /* get name of macro definition */
      status =
      om$send(msg = message ACcpx.find_macro(&macro),
	      targetid = obj_to_test.objid,
	      targetos = obj_to_test.osnum);
      if( !(status&1)) return( OM_S_SUCCESS );

      status =
      om$send(msg = message ACcpx_defn.ACgive_name( &c ),
	      targetid = macro.objid,
	      targetos = macro.osnum);
      if( !(status&1)) return( OM_S_SUCCESS );

      strcpy( me->macro_name, c );
      me->HDR_OCC.obj_id = obj_to_test;

      /*
       *   control if format have been defined
       */
      status =
      om$send(msg = message VDCmdtxldr.place_form( &sts ),
	     targetid = my_id );
      if(!(sts&1)) *msg = 0;
      as$status( action = RET_STATUS );
    }
  }

  End
  return OM_S_SUCCESS;
}

/************************************************************************/
/* METHOD init_type							*/
/************************************************************************/

method init_type()
{
long status = OM_S_SUCCESS;
GRspacenum cur_os;
struct GRid formats_dir; 

  SetProc( VDCmdtxldri.init_type) ; Begin

  status =
  om$send(msg = message VDCmdAnnot.init_type(),
	  targetid = my_id,
	  mode = OM_e_wrt_message);
  as$status(action = RET_STATUS);

  me->msgnumb = VD_M_PlFrLdLn;
  me->loc_key = VD_P_IdElLd;
  me->an_classid = OPP_VDfrmtxt_class_id;
  me->prev_macro_name[0] = '\0';
  me->MACRO_OCC.objid = NULL_OBJID;
  VDSinit_ldexpr( &me->form_expr );
		
  /* get working directory or create it */
  ex$get_cur_mod( osnum = &cur_os);
  di$give_pathname( osnum = cur_os, pathname = me->dir_name );
  /*" pathname is %s\n", me->dir_name */

  strcat( me->dir_name, VD_FTEXT_DIR );
  formats_dir.objid = NULL_OBJID;
  status = di$translate(objname = me->dir_name,
			p_objid = &formats_dir.objid,
			p_osnum = &formats_dir.osnum );
  if(!(status&1) || formats_dir.objid == NULL_OBJID){
  	formats_dir.objid = NULL_OBJID;
  	status = di$mkdir(	dirname = me->dir_name, 
				p_dirid = &formats_dir.objid,
				p_osnum = &formats_dir.osnum  );

	if( !(status&1 )||( formats_dir.objid == NULL_OBJID )){
      		ex$message(msgnumb = VD_S_CanCrea,
		 	   type = "%s", var = `me->dir_name`);
      		return( OM_E_ABORT );
	}
  }

  status =
  om$send(msg = message COdim.create_form(0, "VDPlFrmTxt", &me->form),
	  targetid = my_id);
  as$status(action = RET_STATUS);

  End
  return OM_S_SUCCESS;
}

/************************************************************************/
/*      METHOD  get_default_ldexpr                                      */
/************************************************************************/

method get_default_ldexpr(      long * sts;
                                int  * index )
{
int     status = OM_S_SUCCESS;
IGRint  i,size;
IGRchar macro_dir[TEXT_SIZE], def_name[TEXT_SIZE];
struct  GRid		obj;
struct  ret_struct      def_str;

 SetProc( VDCmdtxldri.get_default_ldexpr) ; Begin

/*
 * This method looks in the sub directory system to see if for the selected
 * macro type a default setting active is from previous use. If active then 
 * find the corresponding index value in ldexpr_list, otherwise return index
 * equal -1.
 */

  *index = -1;
  *sts = MSSUCC;

  size =  om$dimension_of( varray = me->ldexpr_list );
  if( ! size ) goto wrapup ;

  /*
   * check if the macro directory exist.
   */
  sprintf( macro_dir, "%s:%s", me->dir_name, me->macro_name );
  obj.objid = NULL_OBJID;
  status = di$translate(objname = macro_dir,
                        p_objid = &obj.objid,
                        p_osnum = &obj.osnum );
  if( status != DIR_S_SUCCESS ){
    __DBGpr_str(" Not Fnd ", macro_dir );
    goto wrapup;
  }

  *index = 0 ;
  sprintf( def_name, "%s:%s", macro_dir, VD_FOR_DEFAULT ); 
  obj.objid = NULL_OBJID;
  status = di$translate(objname = def_name,
                        p_objid = &obj.objid,
                        p_osnum = &obj.osnum );
  if( status != DIR_S_SUCCESS ){
    __DBGpr_str(" Not Fnd ", def_name );
    goto wrapup;
  }

  status =
  om$send(msg = message NDnode.NDgive_structure(sts, &def_str, &me->md_env ),
	  targetid = obj.objid,
	  targetos = obj.osnum,
	  senderid = NULL_OBJID );
  if( !(status&*sts&1)){
    __DBGpr_com(" No default value ");
    goto wrapup;
  }

  __DBGpr_str(" Default string", def_str.var.text_st.text_string );

  for( i=0; i<size; i++ ){
    if(	strcmp(	me->ldexpr_list[i].formatname,
		def_str.var.text_st.text_string ) == 0 ) {
      *index = i;
      break;
    }
  }

wrapup:

	__DBGpr_int(" Index ", *index );
	End
	return( OM_S_SUCCESS );
}

/************************************************************************/
/*      METHOD  set_default_ldexpr                                      */
/************************************************************************/

method set_default_ldexpr(      long * sts;
                                int  index )
{
int			status = OM_S_SUCCESS;
IGRint			size;
IGRchar			macro_dir[TEXT_SIZE],
			def_name[TEXT_SIZE],
			pwd_dir[TEXT_SIZE];
struct  GRid		obj;
GRspacenum		cur_os;

 SetProc( VDCmdtxldri.set_default_ldexpr) ; Begin
/*
 * This method looks in the sub direcotry system to set the active macro
 * expression. The formatname is stored in a expression.
 */

  *sts = MSSUCC;
  pwd_dir[0] = '\0';

  /*
   * test if index value is possible.
   */
  size = om$dimension_of( varray = me->ldexpr_list );
  if( index < 0 || size < index ){
    /*| error in index value. */
    goto wrapup;
  }

  /*
   * check if the macro directory exist.
   */
  sprintf( macro_dir, "%s:%s", me->dir_name, me->macro_name );
  obj.objid = NULL_OBJID;
  status = di$translate(objname = macro_dir,
                        p_objid = &obj.objid,
                        p_osnum = &obj.osnum );

  if( status != DIR_S_SUCCESS ){
    /*| No expression for this macro */
    goto wrapup;
  }

  /* get current directory */
  status = di$pwd( dirname = pwd_dir );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't get current directory name \n");
    goto wrapup;
  }

  status = di$cd( dirname = macro_dir );
  if( status != DIR_S_SUCCESS ){
    printf(" Can't go to directory: %s \n", macro_dir );
    goto wrapup;
  }

  sprintf( def_name, "%s:%s", macro_dir, VD_FOR_DEFAULT ); 
  obj.objid = NULL_OBJID;
  status = di$translate(objname = def_name,
                        p_objid = &obj.objid,
			p_osnum = &obj.osnum );
  if( status != DIR_S_SUCCESS ){

    __DBGpr_com(" Create default expression ");

    ex$get_cur_mod( osnum = &cur_os );
    status =
    exp$create(	exp_name = VD_FOR_DEFAULT,
		type_rq = EXP_TEXT,
		osnum = cur_os,
		exp_syntax = me->ldexpr_list[index].formatname,
		p_exp_id = &(obj.objid) );
    __CheckRC( status, 1, "exp$create", wrapup );
  }
  else{
    __DBGpr_com(" Modify the expression macro ");
    status =
    exp$modify(	exp_name = VD_FOR_DEFAULT,
		exp_syntax = me->ldexpr_list[index].formatname );
    __CheckRC( status, 1, "exp$create", wrapup );
  }

wrapup:

  /* goto the current directory */
  if( pwd_dir[0] != '\0' ){
    status = di$cd( dirname = pwd_dir );
    if( status != DIR_S_SUCCESS ){
      printf(" Can't change working directory to : %s\n", pwd_dir );
    }
  }

  End
  return OM_S_SUCCESS ;
}

/************************************************************************/
/* METHOD notify_form							*/
/************************************************************************/

method notify_form(
	int form_label;
	int label;
	double value;
	Form form)
{
IGRint    status,row,i;
IGRint    flag, nb_formats;
IGRint    map[11], mapbox[11];
IGRlong   sts;
IGRdouble val[11];
IGRchar   string[80],*an_posn;
IGRuchar  box_type;
IGRlong	  text_flag;
IGRint	  attr_flag = 0;

        SetProc( VDCmdtxldri.notify_form) ; Begin
	map[ANNOT_JUST_ABOVE ] = VD_TL_TOP;
	map[ANNOT_JUST_CENTER] = VD_TL_CENTER;
	map[ANNOT_JUST_BOTTOM] = VD_TL_BOTTOM;
	map[ANNOT_JUST_UNDER ] = VD_TL_UNDER;

	mapbox[VD_BOX_NO_I   ] = VD_BOX_NO;
        /* get rid off VD_BOX_AUTO
	mapbox[VD_BOX_AUTO_I ] = VD_BOX_AUTO; 
        */
	mapbox[VD_BOX_YES_I  ] = VD_BOX_YES;
	mapbox[VD_BOX_ELLIPSE_I  ] = VD_BOX_ELLIPSE;

	for(i=0; i<11; i++) val[i] = 0.0;

	box_type = 0;
	an_posn = NULL;

	switch(label)
	{
	  case VD_BOX_NO:

		box_type = VD_box_NO_DISPLAY;

		val[VD_BOX_NO_I] = 1.0;

		status = FIg_erase(form, VD_ADISP_BOX );
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }
		status = FIg_erase(form, VD_DISP_BOX );
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }
                FIg_display( form, WRITE_FORMATS);

		FIg_enable ( form, VD_TL_TOP );
                FIg_enable ( form, VD_TL_BOTTOM );
                FIg_enable ( form, VD_TL_UNDER );

		FIg_erase( form, VD_BOX_RAT_TEXT ); // Remove these gadgets
		FIg_erase( form, VD_BOX_RAT_VAL );
		break;

/* get rid off VD_BOX_AUTO

	  case VD_BOX_AUTO:

		box_type = VD_box_AUTOMATIC;

		val[VD_BOX_AUTO_I] = 1.0;

		status = FIg_erase(form, VD_DISP_BOX );
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }
		status = FIg_display(form, VD_ADISP_BOX );
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }

		break;
*/
	  case VD_BOX_YES:

		box_type = VD_box_DISPLAY;
		FIg_display( form, VD_BOX_RAT_TEXT ); // Display these gadgets
		FIg_display( form, VD_BOX_RAT_VAL );

		val[VD_BOX_YES_I] = 1.0;

		status = FIg_erase(form, VD_ADISP_BOX );
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }
		status = FIg_display(form, VD_DISP_BOX );
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }
                FIg_display( form, WRITE_FORMATS);

                FIg_enable ( form, VD_TL_TOP );
                FIg_enable ( form, VD_TL_BOTTOM );
                FIg_enable ( form, VD_TL_UNDER );

		break;

          case VD_BOX_ELLIPSE:

                box_type = VD_box_ELLIPSE;

                val[VD_BOX_ELLIPSE_I] = 1.0;

                status = FIg_erase(form, VD_ADISP_BOX );
                if (status != FI_SUCCESS) { return(OM_E_ABORT); }
                status = FIg_erase(form, VD_DISP_BOX );
                if (status != FI_SUCCESS) { return(OM_E_ABORT); }
                FIg_display( form, WRITE_FORMATS);

		an_posn = "Center";
                val[ANNOT_JUST_CENTER] = 1.0;

		FIg_disable ( form, VD_TL_TOP );
		FIg_disable ( form, VD_TL_BOTTOM );
		FIg_disable ( form, VD_TL_UNDER );

		FIg_erase( form, VD_BOX_RAT_TEXT ); // Remove these gadgets
		FIg_erase( form, VD_BOX_RAT_VAL );
                break;

 	  case VD_TEXT_ANGLE:

		FIg_get_value( form, VD_TEXT_ANGLE, &VDCmdtxldr_text_angle );

		break;

          case VD_TEXT_CAPS:

		attr_flag = 1;

		if(VDCmdtxldr_text_flag & VD_text_CAPS)
		{
		  VDCmdtxldr_text_flag &= ~VD_text_CAPS;
		  FIg_set_value( me->form, VD_TEXT_CAPS, 0.0 );
		}
		else
		{
		  VDCmdtxldr_text_flag |= VD_text_CAPS;
		  FIg_set_value( me->form, VD_TEXT_CAPS, 1.0 );
		}

                break;

          case VD_TEXT_MIRROR:

		attr_flag = 1;

                if(VDCmdtxldr_text_flag & VD_text_MIRROR)
                {
                  VDCmdtxldr_text_flag &= ~VD_text_MIRROR;
                  FIg_set_value( me->form, VD_TEXT_MIRROR, 0.0 );
                }
                else
                {
                  VDCmdtxldr_text_flag |= VD_text_MIRROR;
                  FIg_set_value( me->form, VD_TEXT_MIRROR, 1.0 );
                }

                break;

          case VD_TEXT_REVERSE:

		attr_flag = 1;

                if(VDCmdtxldr_text_flag & VD_text_REVERSE)
                {
                  VDCmdtxldr_text_flag &= ~VD_text_REVERSE;
                  FIg_set_value( me->form, VD_TEXT_REVERSE, 0.0 );
                }
                else
                {
                  VDCmdtxldr_text_flag |= VD_text_REVERSE;
                  FIg_set_value( me->form, VD_TEXT_REVERSE, 1.0 );
                }

                break;
		
	  case EXIST_FORMAT:

		flag = FALSE;
		nb_formats = 0;
		status = FIfld_get_list_num_rows( form, label, 0, &nb_formats);
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }
		__DBGpr_int("# Formats ", nb_formats );

		row = 0;
		do{
		  status = FIfld_get_list_select( form, label, row, 0, &flag );
		  if (status != FI_SUCCESS) { return(OM_E_ABORT); }
		  row++;
		}
		while( flag != TRUE && row <= nb_formats );

		if( row <= nb_formats ){

		  VDSinit_ldexpr( &me->form_expr );
		  row--;

		  __DBGpr_int(" ActiveRow", row );
		  status =
		  om$send(msg = message VDCmdtxldr.set_ldexpr_active(&sts,row ),
			  targetid = my_id );
		  as$status();
		}

	    break;

	  case MACRO_LIST:

		/* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **
		/*
		/* The gadget MACRO_LIST is only used as review to
		/* show the macros definitions which have formattted 
		/* text expressions.
		/*
		/* FIg_get_text( form, label, me->macro_name );
		/* 
		/* status =
		/* om$send(msg = message VDCmdtxldr.get_exist_formats( &sts ),
		/*	targetid = my_id );
		/* as$status();
		/*
		/* status =
		/* om$send(msg = message VDCmdtxldr.get_parent_formats( &sts ),
		/*	targetid = my_id );
		/* as$status();
		/*
		/* status =
		/* om$send(msg = message VDCmdtxldr.get_global_formats( &sts ),
		/*	targetid = my_id );
		/* as$status();
		/*
		/* status =
		/* om$send(msg=message VDCmdtxldr.disp_exist_formats(&sts,TRUE),
		/*	targetid = my_id );
		/* as$status();
		/*
		/* ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** */

	    break;

	  case VD_TL_TOP:	an_posn = "Above";
				val[ANNOT_JUST_ABOVE] = 1.0;
	    break;
	  case VD_TL_CENTER:	an_posn = "Center";
				val[ANNOT_JUST_CENTER] = 1.0;
	    break;
	  case VD_TL_BOTTOM:	an_posn = "Bottom";
				val[ANNOT_JUST_BOTTOM] = 1.0;
	    break;
	  case VD_TL_UNDER:	an_posn = "Underline";
				val[ANNOT_JUST_UNDER] = 1.0;
	    break;
	  case FI_CANCEL:
	  case FI_ACCEPT:

		FIg_get_value( form, VD_TEXT_ANGLE, &VDCmdtxldr_text_angle );

		status = FIf_erase(form);
		if(status != FI_SUCCESS) { return(OM_E_ABORT); }

		status = FIg_set_value(form,label,0.0);
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }
		me->form_display = FALSE;

		/* If the BOX is displayed, then fetch the Box Ratio and fill
		the DIM Params, for later use. Alwin */
		if( me->an_box_type & VD_box_DISPLAY )
		{
			IGRdouble			dValue;
			struct DMsenv_param par_senv;

			// Get the DIM Params first and reset the Box Ratio fetched from
			// form
			dm$get_dim_param(type = DM_SENV_PARAM, p_data = &par_senv);

			FIg_get_value( form, VD_BOX_RAT_VAL, &dValue );

			par_senv.bln_size = dValue;

			dm$put_dim_param(type = DM_SENV_PARAM, p_data = &par_senv);
		}

		return(OM_S_SUCCESS);

	  default:
		return(OM_S_SUCCESS);
	}

	if( box_type ){

/*---------
  AUTO IS NOT USED.
	    for(i=0; i<3; i++){
		status = FIg_set_value(form,mapbox[i],val[i]);
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }
	    }
*/
            status = FIg_set_value( form, mapbox[VD_BOX_NO_I],
                                    val[VD_BOX_NO_I]);
            if (status != FI_SUCCESS)  return(OM_E_ABORT);
            status = FIg_set_value( form, mapbox[VD_BOX_YES_I],
                                    val[VD_BOX_YES_I]);
            if (status != FI_SUCCESS)  return(OM_E_ABORT);
            status = FIg_set_value( form, mapbox[VD_BOX_ELLIPSE_I],
                                    val[VD_BOX_ELLIPSE_I]);
            if (status != FI_SUCCESS)  return(OM_E_ABORT);

	    VDannot_box_type = box_type; /* external copy */
	    me->an_box_type = box_type ;

	    if( me->an_grid.objid != NULL_OBJID ) {
		status =
		om$send(msg = message VDfrmtxt.set_box_type(
						&sts,
						box_type ),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum,
			senderid = NULL_OBJID );
		CheckRC( status, sts );
	    }
	}

	if( me->an_grid.objid != NULL_OBJID )
	{
	  text_flag = TEXTANGLE;
	  status=
          om$send( msg = message VDfrmtxt.VDsetAttribute(
			  		  &sts,
					  text_flag,
                                          (IGRchar *) &VDCmdtxldr_text_angle),
                   targetid = me->an_grid.objid,
	    	   targetos = me->an_grid.osnum,
                   senderid = NULL_OBJID);
          as$status(action = RET_STATUS);
 	}

	if( me->an_grid.objid != NULL_OBJID )
	{
	  if(VDCmdtxldr_text_flag & VD_text_CAPS)
	  {
            text_flag = TEXTCAPS;
            status=
            om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &sts,
                                          text_flag,
                                          NULL),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum,
                     senderid = NULL_OBJID);
            as$status(action = RET_STATUS);
          }
	  else
	  {
	    text_flag = TEXTCAPS_NO;
            status=
            om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &sts,
                                          text_flag,
                                          NULL),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum,
                     senderid = NULL_OBJID);
            as$status(action = RET_STATUS);
	  }

	  if(VDCmdtxldr_text_flag & VD_text_MIRROR)
          {
            text_flag = TEXTMIRROR;
            status=
            om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &sts,
                                          text_flag,
                                          NULL),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum,
                     senderid = NULL_OBJID);
            as$status(action = RET_STATUS);
          }
	  else
	  {
	    text_flag = TEXTMIRROR_NO;
            status=
            om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &sts,
                                          text_flag,
                                          NULL),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum,
                     senderid = NULL_OBJID);
            as$status(action = RET_STATUS);
          }

	  if(VDCmdtxldr_text_flag & VD_text_REVERSE)
          {
            text_flag = TEXTREVERSE;
            status=
            om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &sts,
                                          text_flag,
                                          NULL),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum,
                     senderid = NULL_OBJID);
            as$status(action = RET_STATUS);
          }
	  else
	  {
	    text_flag = TEXTREVERSE_NO;
            status=
            om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &sts,
                                          text_flag,
                                          NULL),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum,
                     senderid = NULL_OBJID);
            as$status(action = RET_STATUS);
          }

        }
		
	if(attr_flag == 1)
	{
	  status =
  	  om$send(msg = message VDCmdtxldr.get_exist_formats( &sts ),
	  	  targetid = my_id);
  	  as$status();
 
  	  status =
  	  om$send(msg = message VDCmdtxldr.get_parent_formats( &sts ),
	  	  targetid = my_id);
  	  as$status();
 
  	  status =
  	  om$send(msg = message VDCmdtxldr.get_global_formats( &sts ),
	  	  targetid = my_id);
  	  as$status();
 
  	  status =
  	  om$send(msg = message VDCmdtxldr.disp_exist_formats( &sts, TRUE ),
		  targetid = my_id);
  	  as$status();
	}

	if( an_posn ){
	  for(i=0; i<4; i++)
	  {
		status = FIg_set_value(form,map[i],val[i]);
		if (status != FI_SUCCESS) { return(OM_E_ABORT); }
	  }

	  sprintf(string, "annotation position=%s", an_posn);
	  status=
	  om$send( msg = message COanplace.get_keybrd_input(string),
			targetid = my_id);
	  CheckRC( status, 1 );
	}

        End
	return(OM_S_SUCCESS);
}

/************************************************************************/
/* METHOD display_form							*/
/************************************************************************/

method display_form()
{
IGRint status;
IGRlong sts;
int label;
struct DMsenv_param par_senv;

        SetProc( VDCmdtxldri.display_form) ; Begin
	/*
	 * display the expression of the macro.
	 */
	status =
	om$send(msg = message VDCmdtxldr.place_form( &sts ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	/*
	 * check the justification value
	 */
	dm$get_dim_param(type = DM_SENV_PARAM, p_data = &par_senv);

	if (par_senv.an_posn == ANNOT_JUST_ABOVE)
		label = VD_TL_TOP;
	else if (par_senv.an_posn == ANNOT_JUST_CENTER)
		label = VD_TL_CENTER;
	else if (par_senv.an_posn == ANNOT_JUST_BOTTOM)
		label = VD_TL_BOTTOM;
	else    label = VD_TL_UNDER;

	status =
	om$send(msg = message COdim.notify_form(0, label, 1, me->form),
		targetid = my_id);
	as$status( action = RET_STATUS );

	/*
	 * set the previous angle of text
	 */
	status =
  	FIg_set_value( me->form, VD_TEXT_ANGLE, VDCmdtxldr_text_angle );
  	as$status();

	if(VDCmdtxldr_text_flag & VD_text_CAPS)
	FIg_set_value( me->form, VD_TEXT_CAPS, 1.0 );
	else
	FIg_set_value( me->form, VD_TEXT_CAPS, 0.0 );

	if(VDCmdtxldr_text_flag & VD_text_MIRROR)
	FIg_set_value( me->form, VD_TEXT_MIRROR, 1.0 );
	else
	FIg_set_value( me->form, VD_TEXT_MIRROR, 0.0 );

	if(VDCmdtxldr_text_flag & VD_text_REVERSE)
	FIg_set_value( me->form, VD_TEXT_REVERSE, 1.0 );
	else
	FIg_set_value( me->form, VD_TEXT_REVERSE, 0.0 );

	/*
	 * check the box type for leader line.
	 */
	/* Whether its BOX type or not, we need to set the "Box Ratio"  in the
	 * relevant gadget and make sure they're filled up correctly. 
	 * Whether its displayed or not depends upon the following condition.
	 * CR179901299 Alwin 
	 */

	__DBGpr_dbl( " Box Ratio ", par_senv.bln_size );
	FIg_set_value( me->form, VD_BOX_RAT_VAL, par_senv.bln_size );

	label = VD_BOX_NO;
	if( me->an_box_type & VD_box_DISPLAY ) label = VD_BOX_YES;
	if( me->an_box_type & VD_box_ELLIPSE )   label = VD_BOX_ELLIPSE;

        /*  
	 * Commented out VD_BOX_AUTO
	 * if( me->an_box_type & VD_box_AUTOMATIC ) label = VD_BOX_AUTO;
         */
	status =
	om$send(msg = message COdim.notify_form(0, label, 1, me->form),
		targetid = my_id);
	as$status( action = RET_STATUS );

        if(!me->form_display)
        {
                status = FIf_display(me->form);
                if(status != FI_SUCCESS) { return(OM_E_ABORT); }
        }

        End
	return OM_S_SUCCESS;
}

/************************************************************************/
/* METHOD place_form                                                    */
/************************************************************************/

method place_form( long * sts )
{
int     status = OM_S_SUCCESS;
int     i, n_rows;

  SetProc( VDCmdtxldri.place_form) ; Begin
/*
 * This method initialize/displays the gadgets of the active form:
 */

  
  status =
  om$send(msg = message VDCmdtxldr.disp_exist_macros( sts ),
          targetid = my_id );
  as$status();

  if( me->macro_name[0] == '\0' ){

    /*
     * clear EXIST_FORMAT gadget
     */
    FIfld_get_num_rows( me->form, EXIST_FORMAT, &n_rows );
    for( i=0;i<n_rows;i++ ) FIfld_set_text( me->form, EXIST_FORMAT, i, 0, "" );
    FIg_set_text( me->form, EXIST_FORMAT, "" );

    /*
     * clear TXT_OUTPUT
     */
    FIfld_get_num_rows( me->form, TXT_OUTPUT, &n_rows );
    for( i=0;i<n_rows;i++ ) FIfld_set_text( me->form,   TXT_OUTPUT, i, 0, "" );

    *sts = MSSUCC;
    goto wrapup;
  }

  status =
  om$send(msg = message VDCmdtxldr.get_exist_formats( sts ),
          targetid = my_id );
  CheckRC( *sts, status );

  status =
  om$send(msg = message VDCmdtxldr.get_parent_formats( sts ),
          targetid = my_id );
  CheckRC( *sts, status );

  status =
  om$send(msg = message VDCmdtxldr.get_global_formats( sts ),
          targetid = my_id );
  CheckRC( *sts, status );

  status =
  om$send(msg = message VDCmdtxldr.disp_exist_formats( sts, TRUE ),
          targetid = my_id );
  CheckRC( *sts, status );
 
wrapup:

  *sts = MSSUCC;

  End
  return( OM_S_SUCCESS );
  
}

/************************************************************************/
/*      METHOD  disp_exist_formats                                      */
/************************************************************************/

method  disp_exist_formats(     long * sts;
                                int active )
{
int     status = OM_S_SUCCESS;
IGRint  i,size;
IGRchar full_str[2*TEXT_SIZE];
char    *fm_ptr;

  SetProc( VDCmdtxldri.disp_exist_formats) ; Begin

/*
 * This method displays the formatted expression, stored in the list
 * ldexpr_list, in the gadget EXIST_FORMAT.
 * The parameter active can have the following options:
 *      TRUE:   The formatted text expression is set to active.
 *      FALSE:  No formatted text expression is displayed.
 */

  fm_ptr = me->form;
  size   = om$dimension_of( varray = me->ldexpr_list );

  __DBGpr_int(" LdExpr Size ", size );

  FIfld_set_list_num_rows( fm_ptr, EXIST_FORMAT, 0, 0 );

  for( i=0; i<size; i++ ){

    sprintf( full_str,"%s: \"%s\", %s", me->ldexpr_list[i].formatname,
                                        me->ldexpr_list[i].string,
                                        me->ldexpr_list[i].params );
    FIfld_set_list_default_text( fm_ptr, EXIST_FORMAT, i, 0, full_str, FALSE);
    __DBGpr_str("Format ", full_str );
  }

  /*
   * see if a default settting exist in the directory.
   * Display only on case the me->macro_name is defined.
   */

  __DBGpr_str(" Macro ", me->macro_name );

  if( me->macro_name[0] == '\0' || size == 0 ) goto wrapup;

  status =
  om$send(msg = message VDCmdtxldr.get_default_ldexpr( sts, &i ),
          targetid = my_id );
  __CheckRC( *sts, status, "get_default_ldexpr", wrapup );

  if( i == -1 || i>size ){
    /*
     * Invalid processing index for the active format;
     * Do not display information.
     */
    goto wrapup;
  }

  /*
   * set the found text expression active
   */

  sprintf( full_str,"%s: \"%s\", %s", me->ldexpr_list[i].formatname,
                                      me->ldexpr_list[i].string,
                                      me->ldexpr_list[i].params );
  FIfld_set_text( fm_ptr, DEF_FORMAT, 0, 0, full_str, FALSE);

  __DBGpr_str("DEFAULT ", full_str );

  /* set the first one active */
  FIg_set_text( fm_ptr, MACRO_LIST, me->macro_name );
  FIfld_set_text( fm_ptr, EXIST_FORMAT, 0, 0, full_str, FALSE);
  if( active ){

    __DBGpr_int(" create active form expression ", i );

    status =
    om$send(msg = message VDCmdtxldr.set_ldexpr_active( sts, i ),
            targetid = my_id );
    __CheckRC( *sts, status, "set_ldexpr_active", wrapup );
  }

wrapup:

  *sts = MSSUCC;

  End
  return( status );
}

/************************************************************************/
/*      METHOD  disp_exist_macros                                       */
/************************************************************************/

method  disp_exist_macros( long * sts )
{
int     status = OM_S_SUCCESS;
struct  GRid    format_obj;
IGRint  i,ii,ii_st,nb_macros;
IGRchar classname[TEXT_SIZE];
DIchar  **macros = NULL;
DIgrid  *macro_ids = NULL;
DIint   dsts;
char    *fm_ptr;

  SetProc( VDCmdtxldri.disp_exist_macros) ; Begin
/*
 * This method display all macronames of macros which has formatted text
 * expression defined in the directory system <filename>:formats:macroname.
 */

  *sts = MSSUCC;
  nb_macros = 0;

  fm_ptr = me->form;

  status =
  om$vla_set_dimension( varray = me->macro_list, size = 0 );
  FIfld_set_list_num_rows( fm_ptr, MACRO_LIST, 0, 0 );

  format_obj.objid = NULL_OBJID;
  if( me->dir_name[0] != '\0' ){
    status = di$translate(objname = me->dir_name,
                          p_objid = &format_obj.objid,
                          p_osnum = &format_obj.osnum );
    if( !(status & 1) ){
      status =
      di$mkdir( dirname = me->dir_name,
                p_dirid = &format_obj.objid,
                p_osnum = &format_obj.osnum );
    }
  }

  if( format_obj.objid == NULL_OBJID ){
    /* no directory available */
    return( OM_S_SUCCESS );
  }

  /* find all defined macro groups */
  status =
  om$send(msg = message IGRdir.dump(    &dsts,
                                        "*",
                                        NULL,
                                        &macros,
                                        &macro_ids,
                                        &nb_macros,
                                        0 ),
          targetid = format_obj.objid,
          targetos = format_obj.osnum,
          senderid = NULL_OBJID );
  __CheckRC( dsts, status, "IGRdir.dump", wrapup );

  if( nb_macros == 0 ){
    goto wrapup;
  }

  status =
  om$vla_set_dimension( varray = me->macro_list, size = nb_macros );

  ii = 0;
  ii_st = -1;

  for( i=0; i<nb_macros; i++){
    /* test object class */
    om$get_classname(   osnum   = macro_ids[i].osnum,
                        objid   = macro_ids[i].objid,
                        classname = classname );

    if( strcmp( classname, "ACrg_collect" ) == 0 ){
      /*| class equal to ACrg_collect */
      continue;
    }
    ii_st = i;

    strcpy( me->macro_list[ii].macro, macros[i] );
    me->macro_list[ii].nb_exprs = 0;    /* maybe for later use */

    FIfld_set_list_default_text( fm_ptr, MACRO_LIST, ii++, 0, macros[i], FALSE);
  }

  if( ii < nb_macros ){
    status = om$vla_set_dimension( varray = me->macro_list, size = ii );
  }

  /*
   * display the first macro type in form.
   */
  if( me->macro_name[0] != '\0' ){
	FIg_set_text( fm_ptr, MACRO_LIST, me->macro_name );
  }
  else{
    if( ii_st != -1 )
	FIg_set_text( fm_ptr, MACRO_LIST, macros[ii_st] );
  }

wrapup:

  /* free memory */
  di$free( lines = macros, count = nb_macros );
  if( nb_macros ) DIfree( macro_ids );

  End
  return( OM_S_SUCCESS );
}

/************************************************************************/
/*	METHOD	get_exist_formats					*/
/************************************************************************/

method	get_exist_formats( long * sts )
{
int	status = OM_S_SUCCESS;
IGRlong	msg;
IGRchar	macro_dir[TEXT_SIZE];
IGRchar	for_exp[TEXT_SIZE], par_exp[TEXT_SIZE];
struct	GRid		macro_obj, for_obj, par_obj;
struct	ret_struct	for_str, par_str;

IGRchar	**exprs = NULL;
DIgrid	*expr_ids = NULL;
IGRint	i,ii,nb_exprs;
DIint	dsts;

  SetProc( VDCmdtxldri.get_exist_formats) ; Begin
/*
 * This method read all exist formatted text expression of a defined
 * macro, which is given by it's name (macro_name).
 */
  
  *sts = MSSUCC;
  nb_exprs = 0;

  /* create dynamic memory */
  status = om$vla_set_dimension( varray = me->ldexpr_list, size = 0 );

  sprintf( macro_dir, "%s:%s", me->dir_name, me->macro_name );
  __DBGpr_str(" MacroDir ", macro_dir );
  macro_obj.objid = NULL_OBJID;
  status = di$translate(objname = macro_dir,
			p_objid = &macro_obj.objid,
			p_osnum = &macro_obj.osnum );
  if( status != DIR_S_SUCCESS ){
    __DBGpr_com(" No expression for this macro ");
    goto wrapup;
  }

  /* find all defined expressions */
  status = 
  om$send(msg = message IGRdir.dump(	&dsts,
					"*",
					NULL,
					&exprs,
					&expr_ids,
					&nb_exprs,
					0 ),
	  targetid = macro_obj.objid,
	  targetos = macro_obj.osnum,
	  senderid = NULL_OBJID );
  __CheckRC( dsts, status, "IGRdir.dump", wrapup );

  __DBGpr_int(" NbExprs ", nb_exprs );
  if( nb_exprs == 0 ) { goto wrapup; }

  status =
  om$vla_set_dimension( varray = me->ldexpr_list,  size = nb_exprs );

  ii = 0;
  for( i=0; i<nb_exprs; i++){

    if( strcmp( exprs[i], VD_FOR_DEFAULT ) == 0 ) continue;

    sprintf( for_exp, "%s:%s:%s", macro_dir, exprs[i], VD_FTEXT_STRING );
    sprintf( par_exp, "%s:%s:%s", macro_dir, exprs[i], VD_FTEXT_PARAMS );

    /* get format text string */
    for_obj.objid = NULL_OBJID;
    status = di$translate(	objname = for_exp,
				p_objid = &for_obj.objid,
				p_osnum = &for_obj.osnum );
    if( status != DIR_S_SUCCESS ){
      /*" expression %s:%s not found\n", exprs[i], VD_FTEXT_STRING  */
      continue;
    }

    status =
    om$send(msg = message NDnode.NDgive_structure(	&msg,
							&for_str,
							&me->md_env ),
	    targetid = for_obj.objid,
	    targetos = for_obj.osnum,
	    senderid = NULL_OBJID );
    if( !(status&msg&1)){ continue; }

    /* get parameters string */
    par_obj.objid = NULL_OBJID;
    status = di$translate(	objname = par_exp,
				p_objid = &par_obj.objid,
				p_osnum = &par_obj.osnum );
    if( status != DIR_S_SUCCESS ){
      /*" expression %s: %s not found\n", exprs[i], VD_FTEXT_STRING  */
      continue;
    }

    status =
    om$send(msg = message NDnode.NDgive_structure(	&msg,
							&par_str,
							&me->md_env ),
	    targetid = par_obj.objid,
	    targetos = par_obj.osnum,
	    senderid = NULL_OBJID );
    if( !(status&msg&1) ){ continue; }

    /* get format expression name */
    {
      IGRchar	*ptr;

      ptr = strrchr( exprs[i], ':' );
      ptr = ptr ? ptr+1 : exprs[i] ; 
      strcpy( me->ldexpr_list[ii].formatname, ptr );
    }

    strcpy( me->ldexpr_list[ii].string, for_str.var.text_st.text_string );
    strcpy( me->ldexpr_list[ii].params, par_str.var.text_st.text_string );
    me->ldexpr_list[ii].expr_id.objid = expr_ids[i].objid;
    me->ldexpr_list[ii].expr_id.osnum = expr_ids[i].osnum;

    ii++;
  }

  if( ii < nb_exprs ){
    status = om$vla_set_dimension( varray = me->ldexpr_list, size = ii );
  }

  __DBGpr_int(" Found Expresssions", ii );

wrapup:

	di$free( lines = exprs, count = nb_exprs );
	if( nb_exprs ) DIfree( expr_ids );

	*sts = MSSUCC;
	End
	return( OM_S_SUCCESS );
}

/************************************************************************/
/*	METHOD	get_parent_formats					*/
/************************************************************************/

method	get_parent_formats( long * sts )
{
	int			status = OM_S_SUCCESS;
	IGRlong			msg;
	IGRchar			macro_dir[TEXT_SIZE];
	IGRchar			for_exp[TEXT_SIZE], par_exp[TEXT_SIZE];
	struct	GRid		macro_obj, macDef, for_obj, par_obj;
	struct	ret_struct	for_str, par_str;
	IGRchar			*c;
	GRname			macro_name;
	VDpartAttr		Attr ;
	IGRchar			**exprs = NULL;
	DIgrid			*expr_ids = NULL;
	IGRint			i,ii,
				nb_exprs, tot_exprs,
       				ld_size;
	DIint			dsts;

 SetProc( VDCmdtxldri.get_parent_formats) ; Begin
/*
 * This method read all exist formatted text expression of a defined
 * macro, which is given by it's name (macro_name).
 */
  
  *sts = MSSUCC;
  nb_exprs = 0;
  ld_size  = 0;
  tot_exprs = 0;

  /*
   * check if parent object is defined.
   */
  if( me->HDR_OCC.obj_id.objid == NULL_OBJID ) goto wrapup;

  if( ! vd_$is_ancestry_valid(
		object	= &me->HDR_OCC.obj_id,
		classid	= OPP_VDdrw2d_class_id )) goto wrapup ;

  Attr.Iwant	= VD_I_drwParentObj ;
  status =
  om$send(msg = message GRvg.GRgetattr( sts, (char * )&Attr ),
	  targetid = me->HDR_OCC.obj_id.objid,
	  targetos = me->HDR_OCC.obj_id.osnum,
	  senderid = me->HDR_OCC.obj_id.objid );
  __CheckRC( *sts, status, "GRvg.GRgetattr", wrapup );

  status =
  om$send(msg = message ACcpx.find_macro(&macDef),
          targetid = Attr.obj._objid,
          targetos = Attr.obj._osnum );
  __CheckRC( 1, status, "ACcpx.find_macro", wrapup );

  status =
  om$send(msg = message ACcpx_defn.ACgive_name( &c ),
	 targetid = macDef.objid,
	 targetos = macDef.osnum );
  __CheckRC( 1, status, "ACcpx_defn.ACgive_name", wrapup );

  strcpy( macro_name, c );
  strcpy( me->macro_name , c );
  /* find the size of dynamic memory */
  status =
  ld_size = om$dimension_of( varray = me->ldexpr_list );

  sprintf( macro_dir, "%s:%s", me->dir_name, macro_name );

  macro_obj.objid = NULL_OBJID;
  status = di$translate(objname = macro_dir,
			p_objid = &macro_obj.objid,
			p_osnum = &macro_obj.osnum );
  if( status != DIR_S_SUCCESS ){
    /*| No expression for this macro */
    goto wrapup;
  }

  /* find all defined expressions */
  status = 
  om$send(msg = message IGRdir.dump(	&dsts,
					"*",
					NULL,
					&exprs,
					&expr_ids,
					&nb_exprs,
					0 ),
	  targetid = macro_obj.objid,
	  targetos = macro_obj.osnum,
	  senderid = NULL_OBJID );
  __CheckRC( dsts, status, "IGRdir.dump", wrapup );

  if( nb_exprs == 0 ) { goto wrapup; }

  /* resize the dynamic memory list */
  tot_exprs = ld_size + nb_exprs ;
  status = om$vla_set_dimension( varray = me->ldexpr_list,  size = tot_exprs );

  ii = ld_size;
  for( i=0; i<nb_exprs; i++){

    if( strcmp( exprs[i], VD_FOR_DEFAULT ) == 0 ) continue;

    sprintf( for_exp, "%s:%s:%s", macro_dir, exprs[i], VD_FTEXT_STRING );
    sprintf( par_exp, "%s:%s:%s", macro_dir, exprs[i], VD_FTEXT_PARAMS );

    /* get format text string */
    for_obj.objid = NULL_OBJID;
    status = di$translate(	objname = for_exp,
				p_objid = &for_obj.objid,
				p_osnum = &for_obj.osnum );
    if( status != DIR_S_SUCCESS ){ continue; }

    status =
    om$send(msg = message NDnode.NDgive_structure(	&msg,
							&for_str,
							&me->md_env ),
	    targetid = for_obj.objid,
	    targetos = for_obj.osnum,
	    senderid = NULL_OBJID );
    if( !(status&msg&1)){ continue; }

    /* get parameters string */
    par_obj.objid = NULL_OBJID;
    status = di$translate(	objname = par_exp,
				p_objid = &par_obj.objid,
				p_osnum = &par_obj.osnum );
    if( status != DIR_S_SUCCESS ){ continue; }

    status =
    om$send(msg = message NDnode.NDgive_structure(	&msg,
							&par_str,
							&me->md_env ),
	    targetid = par_obj.objid,
	    targetos = par_obj.osnum,
	    senderid = NULL_OBJID );
    if( !(status&msg&1) ){ continue; }

    /* get format expression name */
    {
      IGRchar	*ptr;
      ptr = strrchr( exprs[i], ':' );
      ptr = ptr ? ptr+1 : exprs[i] ; 
      strcpy( me->ldexpr_list[ii].formatname, ptr );
    }

    strcpy( me->ldexpr_list[ii].string, for_str.var.text_st.text_string );
    strcpy( me->ldexpr_list[ii].params, par_str.var.text_st.text_string );
    me->ldexpr_list[ii].expr_id.objid = expr_ids[i].objid;
    me->ldexpr_list[ii].expr_id.osnum = expr_ids[i].osnum;

    ii++;
  }

  if( ii < tot_exprs ){
    /*" found express: %d\n", ii */
    status = om$vla_set_dimension( varray = me->ldexpr_list, size = ii );
  }

wrapup:
  /* free the memory of dump */
  di$free( lines = exprs, count = nb_exprs );
  if( nb_exprs ) DIfree( expr_ids );

  *sts = MSSUCC;

  End
  return( OM_S_SUCCESS );
}

/************************************************************************/
/*	METHOD	get_global_formats					*/
/************************************************************************/

method	get_global_formats( long * sts )
{
int	status = OM_S_SUCCESS;
IGRlong	msg;
IGRint	ld_size;
IGRchar	macro_dir[TEXT_SIZE];
IGRchar	for_exp[TEXT_SIZE], par_exp[TEXT_SIZE];
struct	GRid		macro_obj, for_obj, par_obj;
struct	ret_struct	for_str, par_str;

IGRchar	**exprs = NULL;
DIgrid	*expr_ids = NULL;
IGRint	i,ii,nb_exprs, tot_exprs;
DIint	dsts;

  SetProc( VDCmdtxldri.get_global_formats) ; Begin
/*
 * This method read all global formatted text expression
 */
  
  *sts = MSSUCC;
  nb_exprs = 0;
  ld_size  = 0;
  tot_exprs = 0;

  /* find the size of dynamic memory */
  ld_size = om$dimension_of( varray = me->ldexpr_list );

  sprintf( macro_dir, "%s:%s", me->dir_name, VD_FTEXT_GLOBAL );

  macro_obj.objid = NULL_OBJID;
  status = di$translate(objname = macro_dir,
			p_objid = &macro_obj.objid,
			p_osnum = &macro_obj.osnum );
  if( status != DIR_S_SUCCESS ){ goto wrapup; }

  /* find all defined expressions */
  status = 
  om$send(msg = message IGRdir.dump(	&dsts,
					"*",
					NULL,
					&exprs,
					&expr_ids,
					&nb_exprs,
					0 ),
	  targetid = macro_obj.objid,
	  targetos = macro_obj.osnum,
	  senderid = NULL_OBJID );
  __CheckRC( dsts, status, "IGRdir.dump", wrapup );

  if( nb_exprs == 0 ) { goto wrapup; }

  /* resize the dynamic memory list */
  tot_exprs = ld_size + nb_exprs ;
  status = om$vla_set_dimension( varray = me->ldexpr_list,  size = tot_exprs );

  ii = ld_size;
  for( i=0; i<nb_exprs; i++){

    if( strcmp( exprs[i], VD_FOR_DEFAULT ) == 0 ) continue;

    sprintf( for_exp, "%s:%s:%s", macro_dir, exprs[i], VD_FTEXT_STRING );
    sprintf( par_exp, "%s:%s:%s", macro_dir, exprs[i], VD_FTEXT_PARAMS );

    /* get format text string */
    for_obj.objid = NULL_OBJID;
    status = di$translate(	objname = for_exp,
				p_objid = &for_obj.objid,
				p_osnum = &for_obj.osnum );
    if( status != DIR_S_SUCCESS ){ continue; }

    status =
    om$send(msg = message NDnode.NDgive_structure(	&msg,
							&for_str,
							&me->md_env ),
	    targetid = for_obj.objid,
	    targetos = for_obj.osnum,
	    senderid = NULL_OBJID );
    if( !(status&msg&1)){ continue; }

    /* get parameters string */
    par_obj.objid = NULL_OBJID;
    status = di$translate(	objname = par_exp,
				p_objid = &par_obj.objid,
				p_osnum = &par_obj.osnum );
    if( status != DIR_S_SUCCESS ){ continue; }

    status =
    om$send(msg = message NDnode.NDgive_structure(	&msg,
							&par_str,
							&me->md_env ),
	    targetid = par_obj.objid,
	    targetos = par_obj.osnum,
	    senderid = NULL_OBJID );
    if( !(status&msg&1) ){ continue; }

    /* get format expression name */
    {
      IGRchar	*ptr;
      ptr = strrchr( exprs[i], ':' );
      ptr = ptr ? ptr+1 : exprs[i] ; 
      strcpy( me->ldexpr_list[ii].formatname, ptr );
    }

    strcpy( me->ldexpr_list[ii].string, for_str.var.text_st.text_string );
    strcpy( me->ldexpr_list[ii].params, par_str.var.text_st.text_string );
    me->ldexpr_list[ii].expr_id.objid = expr_ids[i].objid;
    me->ldexpr_list[ii].expr_id.osnum = expr_ids[i].osnum;

    ii++;
  }

  if( ii < tot_exprs ){
    status = om$vla_set_dimension( varray = me->ldexpr_list, size = ii );
  }

wrapup:
  /* free the memory of dump */
  di$free( lines = exprs, count = nb_exprs );
  if( nb_exprs ) DIfree( expr_ids );

  *sts = MSSUCC;

  End
  return( OM_S_SUCCESS );
}

/************************************************************************/
/* 	METHOD	set_ldexpr_active					*/
/************************************************************************/

method set_ldexpr_active(	long * sts;
				int index )
{
int	status = OM_S_SUCCESS;
IGRint	ld_size;

 SetProc( VDCmdtxldri.set_ldexpr_active) ; Begin
/*
 * This method creates a active formatted text from the ldexpr_list.
 * The active formatted text is equal to the array index "index".
 * The following actions are taken place:
 *	Set the valus to the form expression structure,
 *	Clear form gadgets,
 *	Create formatted text in predefined gadgets.
 */

  *sts  = MSSUCC;

  ld_size = om$dimension_of( varray = me->ldexpr_list );
  index = (index<0 || ld_size<index) ? 0 : index ;

  if(  (( strcmp( me->prev_macro_name, me->macro_name ) != 0 )	||
	( me->form_expr.string[0] == '\0' ))
	&&
	( index < ld_size )) {

    __DBGpr_str(" Found ", me->ldexpr_list[index].formatname );

    strcpy( me->prev_macro_name, me->macro_name );
    strcpy( me->form_expr.formatname, me->ldexpr_list[index].formatname );
    strcpy( me->form_expr.string, me->ldexpr_list[index].string ); 
    strcpy( me->form_expr.params, me->ldexpr_list[index].params ); 

    me->form_expr.expr_id.objid = me->ldexpr_list[index].expr_id.objid;
    me->form_expr.expr_id.osnum = me->ldexpr_list[index].expr_id.osnum;
  }
  
  status = 
  om$send(msg = message VDCmdtxldr.txt_output( sts ),
	  targetid = my_id );
  __CheckRC( *sts, status, "VDCmdtxldr.txt_output", wrapup );

  status = 
  om$send(msg = message VDCmdtxldr.set_default_ldexpr( sts, index ),
	  targetid = my_id );
  __CheckRC( *sts, status, "VDCmdtxldr.set_default_ldexpr", wrapup );

wrapup:

  *sts = MSSUCC;

  End
  return( status );  
}

/************************************************************************/
/*	METHOD	txt_output						*/
/************************************************************************/

method txt_output ( long * sts )
{
int	status = OM_S_SUCCESS;
IGRint	i,n_rows;
IGRint	msg;
IGRchar	tmp[TEXT_SIZE*2];
char	*fm_ptr;
struct	ret_struct ret_struct;
struct  GRid  null_grid;

 SetProc( VDCmdtxldr_txt_output_MTD ) ; Begin

/*
 * This method clears ans displays the latest layout for the formatted
 * text in full format.
 */

  *sts = MSSUCC;
  fm_ptr = me->form;
  ret_struct.var.text_st.text_string[0] = '\0';

  __DBGpr_str(" string ", me->form_expr.string );
  __DBGpr_str(" params ", me->form_expr.params );

  sprintf( tmp,"%s: \"%s\", %s", me->form_expr.formatname,
                                 me->form_expr.string,
                                 me->form_expr.params );

  /* set the first one active */
  FIfld_set_text( fm_ptr, EXIST_FORMAT, 0, 0, tmp, FALSE);

  /* clear TXT_OUTPUT gadget */
  FIfld_get_num_rows( me->form, TXT_OUTPUT, &n_rows );
  for( i=0; i<n_rows; i++ ) FIfld_set_text( me->form, TXT_OUTPUT, i, 0, "" );

  if(!me->dyn_info.info.text_string)
	me->dyn_info.info.text_string =(unsigned char *) om$malloc(size = 2048);
  if(!me->dyn_info.info.text_string) return OM_W_ABORT;
  me->dyn_info.info.text_buff_size = 2048;
  me->dyn_info.info.text_length = 0;
  me->dyn_info.info.text_string[0] = '\0';

  status =
  om$send(msg = message VDCmdtxldr.create_macro( sts ),
	  targetid = my_id );
  __CheckRC( *sts, status, "VDCmdtxldr.create_macro", wrapup );

  if( me->MACRO_OCC.objid != NULL_OBJID ){
 
    /*| get structure */
    status =
    om$send(msg = message NDnode.NDgive_structure(sts,&ret_struct,&me->md_env),
	    targetid = me->MACRO_OCC.objid,
	    targetos = me->MACRO_OCC.osnum,
	    senderid = my_id );
    __CheckRC( *sts, status, "NDnode.NDgive_structure", wrapup );
    {
      IGRchar	*token;
      IGRchar	newline[3];
      IGRint	row, col;

      col=0; row=0;
      newline[0] = 27; newline[1] = 10; newline[2] = '\0';

      /*" output: <%s>\n", ret_struct.var.text_st.text_string */

      strcpy( tmp, ret_struct.var.text_st.text_string );
      token = strtok( tmp, newline );  
      while ( token != (char *)NULL && row < ROW_MAX ){
	/*" token: <%s>\n", token */
	FIfld_set_text( fm_ptr, TXT_OUTPUT, row, col, token );
	token  = strtok( NULL, newline );
	row++;
      }
    }

    if( me->an_grid.objid != NULL_OBJID ){

      struct GRid	text_grid ;

      /*| replace_text */
/* CH => AD */
/* Are you sure you don't override some memory !!! */
/* I would add.
/* if(me->dyn_info.info.text_buff_size < 80)
/*   ret_struct.var.text_st.text_string[me->dyn_info.info.text_buff_size - 1] = '\0';
/* And what about the bad warning ...
/* */

      strcpy( (char *) me->dyn_info.info.text_string,ret_struct.var.text_st.text_string);
      me->dyn_info.info.text_length = strlen( (char *) me->dyn_info.info.text_string );

	status =
	om$send(msg = message DMroot.replace_text(
			&msg,
			DIM_TEXT,
			&text_grid, 
			&me->dyn_env,
			me->dyn_info.info.text_length,
			me->dyn_info.info.text_string),
	targetid = me->an_grid.objid,
	targetos = me->an_grid.osnum );
	__CheckRC( msg, status, "DMroot.replace_text", wrapup );

        /* tr179601491 */
        null_grid.objid = NULL_OBJID;
        status =
        om$send(msg = message NDnode.NDconnect( 
                               1, &me->MACRO_OCC, null_grid, ND_NEW),
        	targetid = me->an_grid.objid,
        	targetos = me->an_grid.osnum);
	__CheckRC( status, 1, "NDnode.NDconnect", wrapup );
     }
  }

wrapup:

  End
  return( status );
}

/************************************************************************/
/*	METHOD	create_macro						*/
/************************************************************************/

method create_macro( long * sts )
{
int	status = OM_S_SUCCESS;
IGRint	msg;
IGRint	i;
IGRshort	rc;
struct GRid CI_TEMP[3];

 SetProc( VDCmdtxldri.create_macro) ; Begin
/*
 * This method executes the active formatted text expression, by checking
 *	- duplication of the string + parameters
 *	- duplication of format name (expression name in subdirectory)
 * It creates or updates the macro occurence.
 */

  *sts = MSSUCC;

  /*| placing template expression in current os */
  if( me->HDR_OCC.obj_id.objid == NULL_OBJID )
    return( OM_S_SUCCESS );

  as$make_source(go_grid = me->HDR_OCC.obj_id,
		 mod_env  = &me->HDR_OCC.mod_env,
		 as_os = me->md_env.md_id.osnum,
		 as_grid = CI_TEMP );

  /* create text string expression */
  CI_TEMP[1].osnum = me->md_env.md_id.osnum;
  status = om$construct(msg = message text_exp.create(
					NULL,
					me->form_expr.string,
					&rc ),
		classid = OPP_text_exp_class_id,
		p_objid = &CI_TEMP[1].objid,
		osnum   = CI_TEMP[1].osnum );
  __CheckRC( 1, status, "text_exp.create", wrapup );

  /* create parameters expression */
  CI_TEMP[2].osnum = me->md_env.md_id.osnum;
  status = om$construct(msg = message text_exp.create(
					NULL,
					me->form_expr.params,
					&rc ),
		classid = OPP_text_exp_class_id,
		p_objid = &CI_TEMP[2].objid,
		osnum   = CI_TEMP[2].osnum );
  __CheckRC( 1, status, "text_exp.create", wrapup );

  /* make them support only */
 
  for(i=1;i<3;i++)
 	om$send( msg = message NDnode.NDchg_state (ND_DEL_NO_CH,ND_DEL_NO_CH),
	         targetid = CI_TEMP[i].objid,
	         targetos = CI_TEMP[i].osnum);

  me->MACRO_OCC.osnum = me->md_env.md_id.osnum;

  __DBGpr_obj( " me->MACRO_OCC ", me->MACRO_OCC );

  if( me->MACRO_OCC.objid == NULL_OBJID ){
    /*| create the ci_macro */
    status =
    om$construct( classid	= OPP_nci_macro_class_id,
		  p_objid	= &me->MACRO_OCC.objid,
		  osnum		= me->md_env.md_id.osnum,
		  msg		= message NDnode.NDchg_state(	ND_DEL_NO_CH,
								ND_DEL_NO_CH));
    __CheckRC( 1, status, "om$construct", wrapup );

    /*" ci_macro: %d,%d\n", me->MACRO_OCC.objid, me->MACRO_OCC.osnum */
    status =
    om$send(msg = message ci_macro.init(&msg,
					0,
					"format_text",
					3,
					CI_TEMP,
					NULL,
					&me->md_env ),
	    targetid = me->MACRO_OCC.objid,
	    targetos = me->MACRO_OCC.osnum);
    __CheckRC( msg, status, "ci_macro.init", wrapup );
  }
  else{
    struct GRid null_grid;
    null_grid.objid = NULL_OBJID;

    status =
    om$send(msg      = message NDnode.NDconnect(3,CI_TEMP,null_grid,ND_FULL),
	    targetid = me->MACRO_OCC.objid,
	    targetos = me->MACRO_OCC.osnum);
    __CheckRC( 1, status, "NDnode.NDconnect", wrapup );

    status =
    om$send(msg = message NDnode.NDcompute_node(sts,0,3,CI_TEMP,&me->md_env),
	    targetid = me->MACRO_OCC.objid,
	    targetos = me->MACRO_OCC.osnum);
    __CheckRC( 1, status, "NDnode.NDcompute_node", wrapup );
  }

wrapup:
  End
  return( status );
}  

end implementation VDCmdtxldr;
