/* $Id: VDCmdExDri.I,v 1.5 2002/01/07 22:29:52 ylong Exp $ */

/*************************************************************************
 * I/VDS
 *
 * File:	vddraw/cmd / VDCmdExDri.I
 *
 * Description:
 *	Associative Visualization Process command object implementation
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdExDri.I,v $
 *	Revision 1.5  2002/01/07 22:29:52  ylong
 *	*** empty log message ***
 *	
 *	Revision 1.4  2002/01/04 21:58:29  ylong
 *	TR5637
 *	
 *	Revision 1.3  2001/10/19 16:49:35  ramarao
 *	Fixed TR# 5594.
 *	
 *	Revision 1.2  2001/10/08 21:53:32  ylong
 *	fix for CR# MP5631
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1998/04/18  18:32:40  pinnacle
# Replaced: vddraw/cmd/VDCmdExDri.I for:  by azuurhou for vds
#
# Revision 1.2  1997/12/05  19:10:40  pinnacle
# Replaced: vddraw/cmd/VDCmdExDri.I for:  by v250_int for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.24  1996/03/01  05:17:26  pinnacle
# Replaced: vddraw/cmd/VDCmdExDri.I for:  by rgade for vds.240
#
# Revision 1.23  1995/09/29  19:49:34  pinnacle
# Replaced: ./vddraw/cmd/VDCmdExDri.I for:  by azuurhou for vds.240
#
# Revision 1.22  1995/08/31  21:44:50  pinnacle
# Replaced: ./vddraw/cmd/VDCmdExDri.I for:  by azuurhou for vds.240
#
# Revision 1.21  1995/08/07  22:34:06  pinnacle
# Replaced: vddraw/cmd/VDCmdExDri.I for:  by azuurhou for vds.240
#
# Revision 1.20  1995/07/25  21:00:12  pinnacle
# Replaced: vddraw/cmd/VDCmdExDri.I for:  by azuurhou for vds.240
#
# Revision 1.17  1995/06/27  20:53:34  pinnacle
# Replaced: vddraw/cmd/VDCmdExDri.I for:  by azuurhou for vds.240
#
# Revision 1.16  1995/06/27  19:19:18  pinnacle
# Replaced: vddraw/cmd/VDCmdExDri.I for:  by azuurhou for vds.240
#
# Revision 1.14  1995/05/09  11:32:12  pinnacle
# Replace: vddraw/cmd/VDCmdExDri.I by azuurhou for OPE
#
# Revision 1.13  1995/05/01  17:20:52  pinnacle
# Replace: vddraw/cmd/VDCmdExDri.I by azuurhou for OPE
#
# Revision 1.12  1995/04/03  16:10:02  pinnacle
# Replaced: vddraw/cmd/VDCmdExDri.I by azuurhou r#
#
# Revision 1.9  1995/03/21  21:09:36  pinnacle
# Replace: by tlbriggs for OPE
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	3/15/95		tlb		Add error messages for syntax
 *					  errors, setup file not found
 *					Add stop request processing
 *
 *	3/20/95		tlb		Change % complete to reflect total
 *						number processed.
 *	3/20/95		adz		Modify process_locate to accept cells
 *	3/29/95		adz		Split the drawing preprocessing.
 *	04/29/95	adz		Transparentcy problem.
 *	05/04/95	adz		Transparentcy will be changed principle.
 *					The process method will be changed.
 *	06/05/95	adz		Add GRgrset checking list.
 *	06/06/95	adz		Split the method extract in functions.
 *	08/31/95	adz		TR 179527386. setup_file length.
 *	03/01/96        Ravi		TR#179600771
 *      10/08/01        Jayadev         CR# MP5631 - warn the user for change
 *                                      in setupFile; apply to all drawings
 *                                      in the view
 *************************************************************************/

class implementation VDCmdExDr;

#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "AS_status.h"
#include "msmacros.h"
#include "msdef.h"
#include "ASmessages.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "coparadef.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "coparamac.h"
#include "macro.h"
#include "madef.h"
#include "go.h"
#include "exdef.h"
#include "exmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "FI.h"
#include "vddrwattr.h"
#include "v_drwdef.h"
#include "v_drw.h"
#include "v_miscmacros.h"
#include "vdsetmacros.h"
#include "v_dbgmacros.h"
#include "vds.h"
#include "VDmsg.h"
#include "VDobj.h"

from    NDnode      import	NDs_compute_node;
from    NDmacro     import	ACreturn_foot;
from    GRgraphics  import	GRremwrng,
				GRaddwrng,
				GRdelete;
from    GRvg        import	GRputattr, GRgetattr;
from    IGEgragad   import	DPinrot, DPinquire;
from    GRreffile   import	GRgetlevels, GRinquireref;
from	VDcontext   import	VDget_osname;
from	GRcontext   import	GRgetmodule_env;

/*
 * the locate structure.
 */
struct ctl_par_arg           /* Arguments for the act. handler(parents,param) */
{
  IGRint type_generic;       /* Type for the selection criteria               */
  struct GRlc_stack *stack;  /* Contains the information of the stack         */
  IGRint num_eligible;       /* Number of eligible elements if any            */
                             /* If 0, all elements are eligible               */
  struct GRid *eligible;     /* Array of eligible elements                    */
  IGRint num_non_eligible;   /* Number of non eligible elements if any        */
  struct GRid *non_eligible; /* Array of non eligible                         */
  char *macro_name;          /* macro name                                    */
  GRclassid classid;         /* eligible class                                */};

#define AS_DEBUG

extern	int VDlocal_change;


method myinit ( long * sts )
{

	/*
	 * initialization of instance.
	 */
	*sts = MSSUCC ;

	/*
	 * parameter list of selectable objects.
	 */

	me->drwMacInfo = NULL ;

	/*
	 * locate filter.
	 */
	me->locate_type[0] = '\0';

	/*
	 * number of located objects.
	 */
	me->MaxObjList = 0;

	/*
	 * disp window
	 */
	me->dispWindow.objid = NULL_OBJID;

	/*
	 * the selected setup file.
	 */
	me->setup_file[0] = '\0';

	/*
	 * the created setname.
	 */
	me->set_name[0] = '\0';

	/*
	 * locate Group
	 */
	me->locGroup	= FALSE ; 	/* VD_K_LOC_SELECT */

	/*
	 * the display locate list.
	 */
	om$vla_set_dimension( varray = me->locObjs, size = 0 );

        VDS_set_ExtDrwRefOnly();

	return OM_S_SUCCESS;
}

method mywakeup ( long * sts )
{

	SetProc( mywakeup ); Begin

	if(      VDlocal_change == 0 ) { ex$message(msgnumb = VD_S_ModNScal); }
	else if( VDlocal_change == 1 ) { ex$message(msgnumb = VD_S_LocScal ); }
	else if( VDlocal_change == 2 ) { ex$message(msgnumb = VD_S_ModScal ); }

        if( me->drwMacInfo ){
                /*
                 * Free the current structure before calling the values
                 * inside the setup file.
                 */
                VD_drwFreeExtractMacInfo( me->drwMacInfo ) ;
                me->drwMacInfo = NULL ;
        }

	if( me->status_display_form_ptr ){
		/*
		 * Set state of the Three gadgets.
		 */
		FIg_set_state(	me->status_display_form_ptr, VD_K_LOC_SELECT,
				 ( me->locGroup ));

		ex$message(	field	= ERROR_FIELD,
				msgnumb	= EMS_I_InvkStatusFrm );
	}

	End ;
	return OM_S_SUCCESS;
}

method mysleep ( long * sts )
{
IGRlong		msg = OM_S_SUCCESS ;

	SetProc( mysleep ); Begin

	*sts =
	dp$erase_hilite( msg = &msg );

	ex$message( msgnumb	= EM_M_ClearMessageField );
	ex$message( msgnumb	= EMS_I_ClearStatusField );
	ex$message( msgnumb	= EMS_P_ClearPromptField );

	if( me->status_display_form_ptr ){
		FIf_erase( me->status_display_form_ptr );
	}

	me->form_requested = 0 ;

	End ;
	return OM_S_SUCCESS ;
}

method mydelete ( long * sts )
{

	SetProc( mydelete ); Begin 

        if( me->drwMacInfo ){
                /*
                 * Free the current structure before calling the values
                 * inside the setup file.
                 */
                VD_drwFreeExtractMacInfo( me->drwMacInfo ) ;
                me->drwMacInfo = NULL ;
        }

	/*
	 * erase hiliteable objects.
	 */
	dp$erase_hilite( msg = sts ) ;

	if( me->status_display_form_ptr ){
		FIf_erase( me->status_display_form_ptr );
	}

	VDS_reset_ExtDrwRefOnly();

	/*
	 * set the list to null.
	 */
	om$vla_set_dimension( varray = me->locObjs, size = 0 );

	End ;
	return OM_S_SUCCESS;
}

method process_locate ( long * sts )
{

	/*
	 * Locate the objects and validate the objects against the 
	 * selection rules or the visualization support file.
	 */
	IGRint			status = OM_S_SUCCESS ,
				max_obj = OM_K_MAXINT,
				event_size,
				option = VD_K_set_Chk_Default,
				nb_obj,
				i_obj,
				obj_generic;
	IGRlong			msg ;
	struct  GRobj_env	*obj_to_print ;
	struct	GRid		context,
				setId,
				Roots;
	struct	GRmd_env	setEnv ;
	IGRchar			cmdBuffer[1024];
	IGRchar			infoBuffer[1024];


	SetProc( process_locate ); Begin
	obj_to_print = NULL ;
	/*
	 * initialization of set.
	 *	macro_generic :	Macros.
	 *	set_generic   : Input Sets
	 *	other_generic : Cell objects.
	 */
	obj_generic = macro_generic | set_generic | other_generic ;
	event_size = sizeof( struct GRevent );

	if( me->event1.response != SPECIFIED_OBJ ){
          status = EXputq_front( &msg,
                                 me->response,
                                 ( IGRlong * ) &event_size,
                                 ( IGRchar * ) &( me->event1.event) );

          if(me->dispWindow.objid == NULL_OBJID)
          {
               me->dispWindow.objid = me->event1.event.button.objid;
               me->dispWindow.osnum = me->event1.event.button.osnum;
          }
	}

	/*
	 * expand fence contents if necessary
	 */
	if( ! ASmatchRE( me->locate_type, "Cell" ) ){
		__DBGpr_com(" Filter Out Cell Objects.");
		option |= VD_K_set_Chk_Cell ;
	}

	if( ! ASmatchRE( me->locate_type, "Symbol" ) ){
		__DBGpr_com(" Filter Out Symbol Objects.");
		option |= VD_K_set_Chk_Symbol ;
	}

	status =
	VD_MakeGRsetOfObject(	&msg,
				&me->ModuleInfo,
				&me->event1.located_object[0].located_obj,
				&me->event1.located_object[0].module_info,
				&setId,
				&setEnv,
				option );
	status =
	vd$filter_objects(	msg	= &msg,
				setId	= &setId,
				option	= option );
	CheckRC( status, msg );

	ACset_disthruref();
	status = 
	as$start_fence(
		set           = &setId,
                set_env       = &setEnv,
                nb_obj        = &nb_obj,
                p_obj_env     = &obj_to_print,
                response      = me->response,
                response_data = me->response_data,
                type_generic  = obj_generic,
                macro_name    = me->locate_type);
	__CheckRC( status, 1, "as$start_fence", wrapup );

	ACreset_disthruref();

	__DBGpr_int(" Number object in Fence ", nb_obj );


	if( nb_obj == 0 ){
		strcpy( cmdBuffer, "Associate Visialization Process ");
		strcpy( infoBuffer, "Invalid Objects selection, please retry");
		EX_error_box( FI_CURRENT_SCREEN, infoBuffer, cmdBuffer );
		goto wrapup;
	}

	context.objid	= NULL_OBJID ;

	for(i_obj=0 ; i_obj<nb_obj ; i_obj++ ){
          /*
	   * find context(s) and make sources
	   */
	  
	  __DBGpr_obj(" Object in fence ", obj_to_print[i_obj].obj_id );
	  
          status = 
	    GRfindcontext( &msg,
			   &obj_to_print[i_obj]._matrix_type,
			   obj_to_print[i_obj]._matrix,
			   &obj_to_print[i_obj]._osnum,
			   &context );
	  if( status != OM_S_SUCCESS || msg != MSSUCC )
			context.objid = NULL_OBJID ;

	  __DBGpr_obj(" context  object", context  );

          status =
	  as$make_source(go_grid      = obj_to_print[i_obj].obj_id,
                         context_grid = context,
                         as_os        = me->ModuleInfo.md_id.osnum,
                         as_grid      = &Roots );
          if(status&1){
		status =
		_VD_SEND_MY( VDS_LOCATE.addLocatedObject( 
						sts,
						&Roots, 
						&obj_to_print[i_obj].mod_env,
						max_obj ));
		__CheckRC( status, *sts, "addLocatedObject", wrapup );
							
          }
	}

        /*
         * changes for CR# MP5631 begin
         * The user's consent will be taken before applying the new 
         * setupfile for all the drawings in the view; The user will not
         * be allowed to  have different setupfiles for different drawings 
         * in the same view
         */ 
 	if( om$dimension_of( varray = me->ObjList ) != 0 )
	{
	  IGRlong          sts1;
	  IGRint           ii, otherCount, retSts;
	  IGRint           jj, oType;
	  struct GRobj_env objToPrint;
	  struct GRid      childId, viewId, modObj;
	  IGRchar          buffer[256], setupName[256];
	  VDpartAttr       attr ;
	  IGRboolean       model_match;
 
	  oType         = VD_O_drw2dObj;
	  otherCount    = 0;
	  childId.objid = NULL_OBJID;
	  modObj.objid  = NULL_OBJID;
	  viewId.objid  = NULL_OBJID;
	  setupName[0]  = '\0';
	  buffer[0]     = '\0';

	  __DBGpr_obj("pretend VDdrw2d ",me->ObjList[0] );
	  
	  VDchnGetChildrenByClass(&me->ObjList[0], NULL,0,"VDdrw2d", &childId, NULL);
	  __DBGpr_obj("childID VDdrw2d ",childId);
	  
	  if(childId.objid == NULL_OBJID) goto wrapup;
	  VDdrw_GetChannelOwner( &msg, &childId, VD_O_drw2d, &viewId );
	  if(viewId.objid == NULL_OBJID) goto wrapup;

	  __DBGpr_obj("viewId ",viewId);
	  attr.Iwant = VD_I_drwVisual ;
	  sts1 =  om$send( msg = message GRvg.GRgetattr( &msg, (char *)&attr ),
			   targetid = viewId.objid,
			   targetos = viewId.osnum  );
	  if(!(sts1&msg&1)) goto wrapup;
	  
	  strcpy( setupName, attr.aString );
	  
	  if(!strcmp(setupName, me->setup_file)) goto wrapup;
	  
	  strcpy( cmdBuffer, "Associate Visialization Process ");
	  sprintf( infoBuffer, "Setup file [%s] can not be replaced by [%s].", 
				setupName, me->setup_file);
	  strcat( infoBuffer, "\n\n");
	  strcat( infoBuffer, 
	     "COz_drwSetup can be used to update drawing view with new setup file");
	  EX_error_box( FI_CURRENT_SCREEN, infoBuffer, cmdBuffer );
	}
        /* changes for CR# MP 5631 end */

wrapup:
	End;
	ASend_fence();
	return OM_S_SUCCESS;
}


method extract_drw ( long * sts )
{
IGRint		status = OM_S_SUCCESS ;

	/*
	 * Test if there are amy objects selected to extract.
	 */
	dp$erase_hilite( msg = sts);

	if( me->MaxObjList ){ 

          /* extract geometry */
          ex$message( msgnumb = VD_S_ChaSca );

          status =
	  _VD_SEND_MY( VDCmdExDr.change_scale( sts ) );
	  __CheckRC( status, *sts, "VDCmdExDr.change_scale", wrapup );

          ex$message( msgnumb = VD_S_ExtPro );

          status =
	  _VD_SEND_MY( VDCmdExDr.extract( sts ) );
	  __CheckRC( status, *sts, "VDCmdExDr.extract", wrapup );

          as$status();
          ex$message( msgnumb = VD_S_Done );
	}

wrapup:

	/*
	 * reinitialization of all the list.
	 */
	if(! om$vla_set_dimension( varray  = me->ObjList, size = 0 ) ){
		printf("ERROR dynamic allocation\n");
                *sts = OM_E_ABORT;
        }
 
	me->MaxObjList = 0 ;
	UI_echo( "" );
	UI_status( "" );
 
	return OM_S_SUCCESS;
}

method extract( long *sts )
{

	IGRint			status = OM_S_SUCCESS,
				i, inCount,
				index = -1,	/* No batch process	*/
				outCount,
				dbPosting = FALSE ;
        IGRdouble               vec[3], pnt[3];
	IGRint			levels[32];
	struct	GRid		*outList ;

	SetProc( VDCmdExDr_Extract ); Begin

	*sts		= OM_S_SUCCESS ;
	outList		= NULL ;
	outCount	= 0 ;
	
	if(( inCount = om$dimension_of( varray = me->ObjList ) ) == 0 )
		return( OM_S_SUCCESS );

	/*
	 * Get window information.
	 *	- projection vector.
	 *	- projection point.
	 *	- active window levels.
	 */
	vec[0] = 0 ;	vec[1] = 0 ;	vec[2] = 1 ;
	pnt[0] = 0 ;	pnt[1] = 0 ;	pnt[2] = 0 ;

	if( me->dispWindow.objid != NULL_OBJID ){

		IGRlong		error,
                                bytes_returned;

		struct var_list	w_info[2];

		w_info[0].var            = LEVELS;
		w_info[0].num_bytes      = 32*sizeof(int);
		w_info[0].bytes_returned = &bytes_returned;
		w_info[0].var_ptr        = (char *) levels;
		w_info[1].var            = END_PARAM; 

		status =
		_VD_SEND_OBJN(	me->dispWindow,
				IGEgragad.DPinquire( sts, &error, w_info));
		__CheckRC( status, *sts, "IGEgragad.DPinquire", wrapup );
	}
	else {	for( i=0 ; i<32 ; i++ ) levels[i] = ~0; }

	status =
	VDdrw_Create2dObjects(	sts,			/* Return code	*/
				index,			/* Batch contr  */
				&me->ModuleInfo,	/* Environment	*/
				inCount,		/* Number objs	*/
				me->ObjList,		/* List of objs	*/
				pnt,			/* Project pnt  */
				vec,			/* Project vec  */
				levels,			/* PRoject Lev  */
				me->setup_file,		/* visualizatio */
				NULL,			/* Trans Setup	*/
				me->locGroup,		/* Select/Trans */
				dbPosting,		/* Like To Post */
				&outCount,		/* Nb found	*/
				&outList );		/* new VDdrw2d 	*/
	__CheckRC( status, *sts, "VDdrw_Create2dObjects", wrapup );

	__DBGpr_int("outCount", outCount );

	UI_echo( "" );
	status = VDdrw_SetVDdrwSelectMode( sts, &me->ModuleInfo,
					   VD_O_drw2d,
					   outCount, outList );
	/* check for this additional process */

	UI_echo( "" );
	status =
	VDdrw_ProcessVDdrw_Objects(	sts,
					&me->ModuleInfo,
					VD_O_drw2d,
					VD_P_drw_INTERACTIVE,
					outCount,
					outList );
	__CheckRC( status, *sts, "VDdrw_ProcessVDdrw_Objects", wrapup );

	wrapup:

		_FREE( outList );
		End ;
		return OM_S_SUCCESS;
}

method restart_cmd ( long * sts )
{
	SetProc( restacrt_cmd ); Begin

        if( me->drwMacInfo ){
                /*
                 * Free the current structure before calling the values
                 * inside the setup file.
                 */
                VD_drwFreeExtractMacInfo( me->drwMacInfo ) ;
                me->drwMacInfo = NULL ;
        }

	me->dispWindow.objid = NULL_OBJID;

	if(! om$vla_set_dimension( varray  = me->ObjList, size = 0 ) ){
		printf("ERROR dynamic allocation\n");
                *sts = OM_E_ABORT;
        }
 
	me->MaxObjList = 0;

	End ;
	return OM_S_SUCCESS;
}

method set_locate_filter ( long * sts )
{
IGRint			status = OM_S_SUCCESS ;

	SetProc( set_locate_filter ); Begin

	*sts = MSSUCC ;
        if( me->drwMacInfo ){
                /*
                 * Free the current structure before calling the values
                 * inside the setup file.
                 */
                VD_drwFreeExtractMacInfo( me->drwMacInfo ) ;
                me->drwMacInfo = NULL ;
        }

	status =
	_VD_SEND_MY( VDCmdExDr.read_drawing_macro( sts ));
	if( !( status & *sts & 1 ) ) *sts = MSFAIL ;

	*sts = ( *sts & 1 ) ? VD_K_VIS_OKE : VD_K_VIS_ERROR ;

	End ;
	return OM_S_SUCCESS;
}

method filter(	int	filter ;
		int	*response ;
		char	*response_data )
{
IGRint			sts = OM_S_SUCCESS ;

	SetProc( filter ); Begin

/**
 {
	IGRlong	msg ;
	sts = 
	_VD_SEND_MY( VDCmdExDr.setup_act_handler ( &msg ));
	__CheckRC( sts, msg, "VDCmdExDr.setup_act_handler", wrapup );
 }
 **/
	sts =
	_VD_SEND_WRT_M(	my_id,
			VDS_LOCATE.filter( filter, response, response_data ));
	__CheckRC( sts, 1, "VDS_LOCATE.filter", wrapup );
	
	wrapup:

		End ;
		return sts;
}


method setup_act_handler ( long * sts )
{
IGRint			status = OM_S_SUCCESS ;
struct	ctl_par_arg	act_parms;
extern			ASctl_parent_type();

	SetProc( setup_act_handler ); Begin

	*sts = OM_S_SUCCESS ;

	__DBGpr_str( "locate_type ", me->locate_type );

	act_parms.type_generic     = macro_generic | set_generic;
	act_parms.stack            = &me->stack;
	act_parms.macro_name       = me->locate_type;
	act_parms.num_eligible     = 0;
	act_parms.eligible         = NULL;
	act_parms.num_non_eligible = 0;
	act_parms.non_eligible     = NULL;

	me->action_handler = (char (*)())ASctl_parent_type;
	me->action_args    = (char *)&act_parms;

	End ;
	return status;
}

method change_scale( long *sts )
{
IGRint			status = OM_S_SUCCESS,
			MaxObj = 0,
			nlist1,
			nlist2,
			nlist_os,
			i_obj,
			j_obj,
			j,
			some_change = 0 ;
IGRlong			msg,
			rt_status;
IGRshort		matrix_type;
IGRdouble		scaleVal,
			matrix[16],
			sqrt();
OM_S_OBJID		model_md;
struct GRid		*list1,
			*list2,
			*ptr_list,
			model,
			scaleId;
struct GRmd_env		model_info;
struct	GRobj_env	*pList ;

	SetProc( change_scale ); Begin 
     
	/*
	 * if no change in scale quick process.
	 */
	*sts = OM_S_SUCCESS ;

	if(( MaxObj = om$dimension_of( varray = me->ObjList ) ) == 0 )
		return( OM_S_SUCCESS );
	pList	= me->ObjList ;

	/*
	 * Get displayable level and view definition
	 */
	scaleVal	= 1.0 ;

	if( ( ! VDlocal_change ))	return( OM_S_SUCCESS );

	/*
	 * Initialization values.
	 */
	ptr_list = NULL;
	ptr_list = _MALLOC( MaxObj , struct GRid );
	list1    = (struct GRid *) ptr_list;
	if( ! list1 ){ 
		return OM_W_ABORT;
	}

	nlist1   = 0;

	for( i_obj=0 ; i_obj<MaxObj ; i_obj++ )
	{
		/*
		 * get model object.
		 */
		status =
		_VD_SEND_OBJ(	pList[i_obj]._grid,
				NDmacro.ACreturn_foot(	&msg,
							"",
                                                        &model,
                                                        &matrix_type,
                                                        matrix ));
		if( !( status&msg&1 ) ) continue;

		/*
		 * get object scale factor.
		 */
		scaleVal =	matrix[0]*matrix[0] +
				matrix[1]*matrix[1] + 
				matrix[2]*matrix[2];

		scaleVal = ( scaleVal > 1.e-10 ) ? 1/sqrt(scaleVal) : 1 ;

		for( j = 0 ; j < nlist1 ; j++ ){
			if( model.objid == list1[j].objid && 
                            model.osnum == list1[j].osnum ) 
				break;
		} 
		if( j >= nlist1 ) 
			list1[nlist1++] = model;

	} /* get all model objects. */

	/*
	 * change scale per given objects space.
	 */

	model_info = me->ModuleInfo;
	while( nlist1 > 0 ){

		VD_drw_SortPerObjSpace( nlist1, list1, &nlist_os );

		model_info.md_id.osnum = list1[0].osnum;
		status =
		ex$get_modid(	mod_osnum = list1[0].osnum,
				mod_id    = &model_md );

		/*
		 * Search which one of these elements needs to change scale
		 */
		some_change = 0;

		status = 
		exp$create(	exp_value       = scaleVal,
				exp_name        = NULL,
				osnum           = list1[0].osnum,
				p_exp_id        = &scaleId.objid );

		scaleId.osnum = list1[0].osnum;

		if( VDlocal_change == 1 ){

		  /*
		   * Only rescale elements depending
		   * directly from scale
		   */

		  for( i_obj=0 ; i_obj<nlist_os ; i_obj++ ){

                    if( VD_drw_ChangeScale(	list1+i_obj,
						scaleVal,
						&scaleId,
                       		              	&me->ModuleInfo) ){

			/* 
			 * The element is scale dependent and
			 * needs to be recomputed
			 */
                        some_change = TRUE;
                        model_info.md_id.objid = model_md;

			rt_status =
			VDdrw_ProcessRangeObject(	&msg,
							&model_info,
							1,
							list1 +i_obj );

                    }  /* VD_drw_ChangeScale */
		  }
		}
		else{

		  /*
		   * search if parents are scale dependent
		   */
		  for( i_obj=0 ; i_obj < nlist_os; i_obj++ ){

                    nd$get_graph( p_tip = list1+i_obj, nb_tip = 1);

                    status = 
                    nd$get_list_in_graph( acc_type = ND_BODY | ND_EXTERN | 
                                                       ND_ROOT | ND_TIP,
                                          p_count  = &nlist2,
                                          buf_addr = &list2);
                    for( j_obj = 0 ; j_obj < nlist2 ; j_obj++ )
                    {
                      if( VD_drw_ChangeScale(	list2+j_obj,
						scaleVal,
						&scaleId,
                       	                 	&me->ModuleInfo) ){

			__DBGpr_obj(" scale dependent ", list2[j_obj] );
                         some_change = TRUE;
                       }
                    }
		  }

		  if( some_change ){

                    nd$get_graph( p_root = &scaleId , nb_root = 1 );

                    status =
		    nd$get_list_in_graph( p_count  = &nlist2,
                                          acc_type = ND_BODY,
                                          buf_addr = &list2);

                    for( j_obj=0 ; j_obj<nlist2 ; j_obj++ ){

                      if( nd$dep_exist(	l_root	= list2 +j_obj,
					nb_root = 1,
                                        l_tip	= list1,
					nb_tip	= nlist_os)){

		  	 __DBGpr_obj(" recomputed ", list2[j_obj] );

                         model_info.md_id.objid = model_md;
 
			 rt_status =
			 VDdrw_ProcessRangeObject(	&msg,
							&model_info,
							1,
							list2 +j_obj );

                         ACset_disthruref();
                         status = 
			 vd_$bulk_display(	dpmode	= GRbd,
						count	= 1,
						grids	= list2 +j_obj,
						theEnv	= &me->ModuleInfo );
                         ACreset_disthruref();
                      } /* nd$dep_exist */
                    } /* for .. */
		  } /* if (some_change ) */
		}

		list1 += nlist_os; 
		nlist1 -= nlist_os;

	} /* end while on different OSs */

	if( ptr_list ) 
		om$dealloc( ptr = ptr_list );
      
	End;
	return OM_S_SUCCESS;
}

method read_drawing_macro ( long * sts )
{

/* 
 * This method initializes the drawing macro and the name of locatable parts.
 * A predefined ASCII file is read to define the macro definitions to create.
 * The file is called DrawingTable and is found in <product>/config/.
 * The macro definitions are created in the default working directory "."
 */

#define			MAX_FEET	200

IGRint			status = OM_S_SUCCESS ;
IGRchar			stsMessBuf[DI_PATH_MAX];
FILE			*file;
     
	SetProc( read_drawing_macro ); Begin

	/*
	 * Try to read the macro to extract from struct set up file , and if
	 * it doesn't work, take them from file DrawingTable
  	 * Check for I/STRUCT keyword inside the I/VDS body.
	 * The individual call will be done later.
	 */

	/*
	 * See if a setup file is defined and start scanning for the objects
	 * to be scanned in the design file.
	 */

	*sts = OM_S_SUCCESS ;
	file = NULL;

	if( me->drwMacInfo ){
		/*
		 * Free the current structure before calling the values
		 * inside the setup file.
		 */
		VD_drwFreeExtractMacInfo( me->drwMacInfo ) ;
		me->drwMacInfo = NULL ;
	}

	if( strlen( me->setup_file )){
		*sts = VD_drwExecConfigAddFunctions();
		if ( !(1 & *sts)) {
			VD_drwExecConfigRmFunctions();
			goto wrapup;
			}

		if( ! VD_drw_init_from_drawing_setup(	me->setup_file,
							&me->drwMacInfo )){
			/*
			 * The setup file is not found.
			 */
			sprintf( stsMessBuf, "Syntax error in setup file: '%s'",
					me->setup_file );
			UI_error (stsMessBuf);
			VD_drwExecConfigRmFunctions();
			*sts = OM_E_ABORT;
			goto wrapup;
		}
		VD_drwExecConfigRmFunctions();
	}

	/*
	 * To continue with the old DrawingTable, the drwMacName,
	 * macDefName and the feetNames are also added in the list.
	 * First check if the DrawingTable is defined and then read line by
	 * line to store.
	 */

#ifdef	NO_DRAWING_TABLE_FILE

        if( VD_drw_GetDrawingTableFile( &file ) ){

		IGRint			i,
					feetCount,
					feetMax = MAX_FEET ;
		IGRchar			*feetNames[MAX_FEET],
					feetBuffer[MAX_FEET*macro_MAX_CHAR],
					drwMacName[macro_MAX_CHAR],
					macDefName[macro_MAX_CHAR];

		/*
		 * Create feetlist buffer.
		 */
		VD_drw_CrtFeetBuf(	feetBuffer,
					feetNames,
					feetMax );
		/*
		 * To avoid any problem in the ASCII file, the function
		 * VD_drw_read_from_DrawingTable() scanns the ASCII file
		 * and return the values.
		 */

		while( VD_drw_ReadDrawingTable(	file,
						drwMacName,
						macDefName,
						feetNames,
						&feetCount,
						feetMax ) != EOF ){

			/*
			 * add information in structure.
			 */
			if( ! VD_drwAddMacInfo(		&me->drwMacInfo,
							macDefName )){
				continue;
			}
						 
			if( ! VD_drwAddMacDrwName(	me->drwMacInfo,
							drwMacName )){
				continue;
			}

			for( i=0 ; i< feetCount ; i++ ){

			  if( ! VD_drwAddAttrToMacInfo( me->drwMacInfo,
							feetNames[i] )){
				continue;
			  }
			}
		}
	}

#endif

#ifdef vdsDEBUG
	if( me->drwMacInfo ){

                VD_drwMacInfo   *m ;
                VD_drwAttrList  *a ;

                printf( "START DUMP\n" ) ;
                for( m = me->drwMacInfo ; m ; m = m->next ) {
                        printf( "Mac <%s> drawing <%s>\n",
                                m->macDefName ? m->macDefName : "NULL",
                                m->drwMacName ? m->drwMacName : "NULL" ) ;
                        for( a = m->attrList ; a ; a = a->next ) {
                                printf( "\t\t<%s>\n",
                                a->attrName ? a->attrName : "NULL" ) ;
                        }
                }
                printf( "END DUMP\n" ) ;
	}
#endif

	/*
	 * setup the search criteria for locatable objects.
	 */
	if( me->drwMacInfo ){

                VD_drwMacInfo   *m ;
		IGRint		len = 0,
				space = 0 ;

                for( m = me->drwMacInfo ; m ; m = m->next ) {
			if( m->macDefName ){
				len += strlen( m->macDefName ) ;
				space += 3 ;
			}
		}

		me->locate_type[0] = '\0';

		if( len ){
			len += space;

			status =
			om$vla_set_dimension(	varray	= me->locate_type,
						size	= len );
			if( ! (status & 1 )){
				goto wrapup;
			}

			me->locate_type[0] = '\0';

			/*
			 * Copy the section-cut object first.
			 */
			for( m = me->drwMacInfo ; m ; m = m->next ) {
				if( m->macDefName ){
					strcat(	me->locate_type,
						m->macDefName ) ;
					strcat( me->locate_type, "|" );
				}
			}
		}
				
	}
	__DBGpr_str("LOCATE ", me->locate_type );

wrapup:

	if( file )	fclose( file );

	End ;
	return OM_S_SUCCESS;
}

method display_default( long *sts )
{
	SetProc( display_default ); Begin

	ex$message(	msgnumb = VD_S_DefFl,
			type="%s",
			var = VD_Ks_DEFAULT_NAME );

	End;
	return OM_S_SUCCESS ;
}

method display_setup( long *sts )
{
GRname		name;

	SetProc( display_setup ); Begin

	sprintf( name, "Active File: %s ", me->setup_file );
	UI_status( name );

	End;
	return OM_S_SUCCESS ;
}

method get_setup_file( long *sts )
{
	VD_drwInputData		inp;
	GRname			filepath;
	GRname			err;
	SetProc( get_setup_file ); Begin

	*sts = MSSUCC ;

        VD_drwInitStackOfInputFiles( &inp.inputFiles ) ;
	if( me->event1.subtype == GRst_DEFAULT 
			|| me->event1.response == EX_RJT_MOVEON )
		strcpy( me->setup_file, VD_Ks_DEFAULT_NAME );
	else{
		int	len = strlen( me->event1.event.keyin ) ;

		__DBGpr_int(" STRING len ", len );

		if(( !len )||( len > 30 )){
			*sts = OM_E_ABORT ;
			strcpy (err, "Setup file invalid : ");
			strncat (err, me->event1.event.keyin, 80);
			UI_error (err);
			goto wrapup ;
		}
		strncpy( me->setup_file, me->event1.event.keyin, 30 );
	}

	sprintf( filepath, "%s/%s", VD_K_DRW_CONFIG_RELPATH, me->setup_file );

        /*
         * Look for Drawing Extraction config file.
         */
	*sts = VD_drwExecConfigAddFunctions();
	if ( !(1 & *sts)) goto wrapup;

        if( ! VD_drwPushInputFile(	filepath,
					TRUE,	/* verbose mode */
					&inp.inputFiles ) ) {
		*sts = OM_E_ABORT ;
		strcpy (err, "Setup file not found: ");
		strncat (err, me->setup_file, 80);
		UI_error (err);
        }
	wrapup:

		VD_drwExecConfigRmFunctions();
		VD_drwCloseInputFiles( &inp.inputFiles ) ;

		*sts = ( *sts & 1 ) ? VD_K_VIS_OKE : VD_K_VIS_ERROR ;
		End ;
		return OM_S_SUCCESS ;
}

end implementation VDCmdExDr;
