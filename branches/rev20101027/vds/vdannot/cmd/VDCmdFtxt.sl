/* $Id: VDCmdFtxt.sl,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdFtxt.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdFtxt.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/07/18  20:28:02  pinnacle
# Replaced vdannot/cmd/VDCmdFtxt.sl  by A.Gupta
#
# Revision 1.2  1997/07/18  20:02:10  pinnacle
# Replaced vdannot/cmd/VDCmdFtxt.sl for: TR 179603517 by A.Gupta for VDS
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/03/28  20:18:00  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt.sl for:  by yzhu for vds.240
#
# Revision 1.2  1995/09/08  21:18:12  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt.sl for:  by jwfrosch for vds.240
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
 *
 * -------------------------------------------------------------------*/

/****************************************************************************

	Filename:	VDCmdFtxt.sl
	Author:		AD Zuurhout 
	Type:		Slic File
	Process by:	$EXNUC/bin/slic VDCmdFtxt.sl
	Output:		VDCmdFtxt.S  and VDCmdFtxt.I
	makemake file	vdannot.m -> makefile -> ../lib/vdannot.o

	Description:

	  Slic file to produce methods, necessary for the user interface.

	History:
	ADZ 	01-03-1992	Creation date
 
		  
/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

class		VDCmdFtxt
super_class	VDS_LOCATE
product_name	"$VDS"
options		"SItc"

start_state	terminate

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification
/*
	Below is information for creating the spec file
*/

#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "DIdef.h"
#include "macro.h"
#include "parametric.h"
#include "AS_status.h"
#include "VDSannot.h"

instance
{
  IGRint		my_label;		/* form_not return value     */
  IGRchar		dir_name[TEXT_SIZE];	/* working directory         */
  struct GRid		formats_dir;
  struct GRmd_env	mod_env;
  struct GRid		macro_id;		/* selected macro            */	
  IGRchar		macro_name[TEXT_SIZE];  /* macor name		     */
  struct GRid		hdr;			/* macro header occurence    */	

  variable struct VDldline_expr ldexpr_list[0]; /* all formats in system     */
  struct VDldline_expr	form_expr;		/* current expression        */

  IGRboolean		Override_option;	/* read/write instances	     */
  IGRchar		Config_file[TEXT_SIZE];
  IGRchar		Macros_file[TEXT_SIZE];

  struct GRid		MACRO_OCC;		/* place macro occurence     */
}

/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include <string.h>

#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrdef.h"
#include "igrmacros.h"
#include "msdef.h"
#include "exdef.h"

#include "grdpbmacros.h"
#include "grerr.h"
#include "exmacros.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "nddef.h"
#include "ndmacros.h"
#include "macro.h"
#include "asbox.h"
#include "grownmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "vddrwattr.h"
#include "v_dbgmacros.h"

#include "FI.h"
#include "VDmsg.h"

#define VD_DEBUG

#include "VDdebug.h"

/* foreign methods */
from		ACcpx	     import find_macro;
from		GRvg	     import GRgetattr;

extern GRclassid	OPP_VDdrw2d_class_id,
			OPP_GRsmhdr_class_id,
                        OPP_VDrelat_hdr_class_id,
			OPP_GRclhdr_class_id;

#define AS_DEBUG 1

/************************************************************************/
/*	METHOD:	init							*/
/************************************************************************/

action init
{
GRspacenum	cur_os;

  SetProc( VDCmdFtxt.init ); Begin 
  me->ret = MSSUCC;

  status =
  om$send(msg = message CEO_LOCATE.init ( type, str_ptr),
	  mode = OM_e_wrt_message,
	  targetid = my_id );
  as$status( action = RET_STATUS );
  /*
   * KLUDGE : Copy the drawing macro definitions localy.
   * status = VDreadDrawingMacro( &me->ModuleInfo );
   */

  if( me->mytype == VD_CREATE_FORMAT ){
    /* set variables for form */
    me->macro_name[0]	= '\0';

    me->MACRO_OCC.objid	= NULL_OBJID;
    me->macro_id.objid	= NULL_OBJID;
    me->hdr.objid	= NULL_OBJID;

    VDSinit_ldexpr( &me->form_expr );

    /* clear message field */
    FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, "" ); 

    /* set maximum to text with embedded format gadget */
    FIfld_set_list_num_rows(me->forms[0].form_ptr, EXIST_FORMAT, 0, 0 );
    FIfld_set_list_num_rows(me->forms[0].form_ptr, PARAS_FIELD , 0, 0 );

    FIfld_set_max_num_rows( me->forms[0].form_ptr, FORMAT_OUTPUT,  ROW_MAX );
    FIfld_set_max_num_rows( me->forms[0].form_ptr, TXT_OUTPUT, ROW_MAX );
  }

  /* get working directory or create it */
  ex$get_cur_mod( osnum = &cur_os );
  di$give_pathname( osnum = cur_os, pathname = me->dir_name );
  /*" pathname is %s\n", me->dir_name */

  strcat( me->dir_name, VD_FTEXT_DIR );
  me->formats_dir.objid = NULL_OBJID;
  status =
  di$translate(	objname = me->dir_name,
		p_objid = &me->formats_dir.objid,
		p_osnum = &me->formats_dir.osnum );
  if(!(status&1) || me->formats_dir.objid == NULL_OBJID ){
    status =
    di$mkdir(	dirname = me->dir_name, 
		p_dirid = &me->formats_dir.objid,
		p_osnum = &me->formats_dir.osnum  );
    if( !(status&1 )||( me->formats_dir.objid == NULL_OBJID )){
      ex$message( msgnumb = VD_S_CanCrea, type = "%s", var = `me->dir_name` );
      me->ret = MSFAIL;
      return( OM_E_ABORT );
    }
  }

  End
  goto quit;

}

/************************************************************************/
/*	METHOD:	wakeup							*/
/************************************************************************/

action wakeup
{
long	sts;

  SetProc( VDCmdFtxt.wakeup ); Begin
  me->ret = MSSUCC;

  status =
  om$send(msg = message CEO_LOCATE.wakeup (pos),
	  mode = OM_e_wrt_message,
	  targetid = my_id );
  as$status( action = RET_STATUS );

  /*| update the expression list */
  if( me->mytype == VD_CREATE_FORMAT ){
    status =
    om$send(msg = message VDCmdFtxt.get_exist_formats( &sts ),
	    targetid = my_id );
    as$status( action = RET_STATUS );

    status =
    om$send(msg = message VDCmdFtxt.disp_exist_formats( &sts, TRUE ),
	    targetid = my_id );
    as$status( action = RET_STATUS );
  }

  End
  goto quit;

}

/************************************************************************/
/*	METHOD:	sleep							*/
/************************************************************************/

action sleep
{
long	sts;

  SetProc( VDCmdFtxt.sleep ); Begin
  status =
  om$send(msg = message CEO_LOCATE.sleep(pos),
	  mode = OM_e_wrt_message,
	  targetid = my_id );
  as$status( action = RET_STATUS );

  dp$erase_hilite( msg = &sts );
  UI_prompt("");
  UI_message("");
  UI_status("");

  End
  goto quit;

}

/************************************************************************/
/*	METHOD:	process_locate						*/
/************************************************************************/

action process_locate
{             
  long	msg;

  SetProc( VDCmdFtxt.process_locate ); Begin
//  __enterMethod ( name = "process_locate" );

  me->hdr.objid = me->event1.located_object[0].located_obj.objid;
  me->hdr.osnum = me->event1.located_object[0].located_obj.osnum;
  /*" located macro [%d,%d]\n", me->hdr.objid, me->hdr.osnum */

  me->mod_env = me->locate_ModuleInfo;

////////////////////////////////////////////

  __printf (">>>>> located macro [%d,%d]", `me->hdr.osnum, me->hdr.objid` );

  /*
   * Check if located object is in a Drawing View
   * If this is true, then replace it with the originating Model object
   */
  if( DMancestry_valid( me->event1.located_object[0].located_obj, OPP_VDdrw2d_class_id ) == OM_S_SUCCESS )
  {
    VDpartAttr		 attr;

    attr.Iwant	= VD_I_drwParentObj;

    status =
    om$send (	msg	 = message GRvg.GRgetattr( &msg, (char *)&attr ),
		targetid = me->event1.located_object[0].located_obj.objid,
		targetos = me->event1.located_object[0].located_obj.osnum );
    if ( status & msg & 1 )
    {
      me->event1.located_object[0].located_obj = attr.obj.obj_id;
      me->event1.located_object[0].module_info = attr.obj.mod_env;

      __printf (">>>>><<<<< attr.obj [%d,%d]", `attr.obj.obj_id.osnum, attr.obj.obj_id.objid` );

      if ( ! DMancestry_valid( attr.obj.obj_id, OPP_VDrelat_hdr_class_id ) == OM_S_SUCCESS )
      {
        if ( DMancestry_valid( attr.obj.obj_id, OPP_GRclhdr_class_id ) == OM_S_SUCCESS
       	  || DMancestry_valid( attr.obj.obj_id, OPP_GRsmhdr_class_id ) == OM_S_SUCCESS )
        {
          status  = 0;
	  *sts = MSFAIL;
	  goto quit;
        }
       }

      me->hdr	  = attr.obj.obj_id;
      me->mod_env = attr.obj.mod_env;

      __printf ("<<<<< located macro [%d,%d]", `me->hdr.osnum, me->hdr.objid` );
    }
  }

////////////////////////////////////////////

  status =
  om$send(msg = message ACcpx.find_macro(&me->macro_id),
	  targetid = me->hdr.objid,
	  targetos = me->hdr.osnum);
  as$status(action = RET_STATUS);

  status = dp$erase_hilite(msg = &msg );
  as$status(action = RET_STATUS);

  End
  goto quit;

//  __exitMethod ( name = "process_locate" );

}

/************************************************************************/
/*	METHOD:	translate_name						*/
/************************************************************************/

action translate_name
{

  SetProc( VDCmdFtxt.translate_name ); Begin
  /*" keyin is %s\n", me->event1.event.keyin */

  status =
  di$translate(	objname = me->event1.event.keyin,
		p_objid = &me->hdr.objid,
		p_osnum = &me->hdr.osnum);

  /*" hdr: %d,%d\n", me->hdr.objid,me->hdr.osnum */

  End
  goto quit;

}

/************************************************************************/
/*	METHOD	check_format						*/
/************************************************************************/

action check_format
{
/*
 * This method checks if the current formatted text string already exist.
 * A format exist in case the formatted text 'string' amd it's 'parameters'
 * are identical. 
 * The formatname is not checked. 
 * Return code:
 *	sts :	MSSUCC	Formatted text expression is new.
 *		MSFAIL	Formatted text expression exist.
 */
IGRint	i,ld_size;
 
  SetProc( VDCmdFtxt.check_format); Begin 
  *sts = MSSUCC;

  ld_size = 0;
  ld_size = om$dimension_of( varray = me->ldexpr_list );
  /*" ld_size : %d\n", ld_size */

  for(i=0;i<ld_size;i++){
    if( strcmp( me->ldexpr_list[i].string, me->form_expr.string ) == 0 ){
      if( strcmp( me->ldexpr_list[i].params, me->form_expr.params ) == 0 ){

        /*| FOUND THE SAME FORMAT */
	*sts = MSFAIL;
	break;
      }
    }
  }

  End
  goto quit;
}

/************************************************************************/
/*	METHOD	process_object						*/
/************************************************************************/

action process_object
{
char	*fm_ptr;

  SetProc( VDCmdFtxt.process_object ); Begin
  /*
   * clear the form from the previous information
   */
  fm_ptr = me->forms[0].form_ptr;
  if( fm_ptr ){
    status = FIf_display( fm_ptr );
    if( status != FI_SUCCESS ){
      printf(" process_object : fct FIf_display fails \n");
      return( OM_E_ABORT );
    }
  }
  else{
    printf(" Form not found \n");
    return( OM_E_ABORT );
  }

  /*
   * update the form with the new values( same as FI_RESET )
   */

  status =
  om$send(msg = message VDCmdFtxt.form_notification( 0, FI_RESET, 1.0, fm_ptr ),
	  targetid = my_id );
  as$status( action = RET_STATUS );

  *sts = MSSUCC;
 
  End 
  goto quit;
}


/************************************************************************/
/*	METHOD	VDS_FormReturn						*/
/************************************************************************/

action VDS_FormReturn
{

  /* states field in CEO_LOCATE get the return value of the     */
  /* routine form_notification; sts is used in state table      */

  SetProc( VDCmdFtxt.VDS_FormReturn ); Begin
  *sts = (long)me->my_label;
  End
  goto quit;
}

/************************************************************************/
/************************************************************************/
/************************************************************************/

action Get_text(	char * form_ptr;
			int gadget_label;
			int row;
			int col; 
			char **text;
			int *text_size )		extern

action process_format(	long * sts )			extern

action fill_in_params( 	long * sts )			extern

action format_output( 	long * sts )			extern

action txt_output( 	long * sts )			extern

action check_formatname(long * sts;
			char * def_name )		extern

action form_notification ( int form_label;
			int gadget_label;
			double value; 
			char * form_ptr )		extern

action set_ldexpr_active( long * sts;
			int index )			extern

action create_format( long * sts;
			struct VDldline_expr * expr )	extern

action get_exist_formats( long * sts )			extern

action disp_exist_formats( long * sts;
			int active )			extern

action disp_exist_macros( long * sts )			extern

/************************************************************************/
/*	METHODS for Write Formatted Text File				*/
/************************************************************************/

action formats_defined( long * sts )			extern

action write_file( long * sts )				extern

/************************************************************************/
/*	METHODS for Read Formatted Text File				*/
/************************************************************************/

action get_read_option( long * sts )			extern

action display_default( long * sts )			extern

action read_file( long * sts )				extern

