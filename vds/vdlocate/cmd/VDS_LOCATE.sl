/* $Id: VDS_LOCATE.sl,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	VDSlocate / VDS_LOCATE.sl
 *
 * Description:	
 *
 *	This command implements the filter in I/VDS. It will allow the
 *	user to use the path system when locate by name are performed.
 *
 *	It is a high level class, and all the commands in VDS should be
 *	under this command. Some general messages has been implemented
 *	in order to share the functionalities.
 *
 * Dependencies:
 *
 *	CEO_LOCATE
 *
 * Revision History:
 *	$Log: VDS_LOCATE.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/03/22  14:15:36  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.3  1995/11/29  13:53:12  pinnacle
# Replaced: ./vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.2  1995/08/07  23:06:04  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	12/01/92	Ad Zuurhout 	Creation Date.
 *	05/01/94	P. Lacroix 	Add New messages to make VDS_LOCATE
 *					a Super class of all the commands in
 *					VDS.
 *      08/25/94        R. Manem        Added a new filter :
 *                                         vds_get_event_with_dynamics
 *                                      Added messages to support dynamics in
 *                                      forms
 * -------------------------------------------------------------------------
 */

command_table        "vds.cmd"
class                VDS_LOCATE
super_class          CEO_LOCATE
product_name         "$VDS"
options              "SItc"

start_state          terminate


/*---------------------
 * specification area
 */


specification

/*+cmd
/* -------------------------------------------------------------------------

  Command Object Class VDS_LOCATE

  Superclass
	CEO_LOCATE

  Abstract
	Implements the I/VDS filter, and some general method that can be used
	by all the commands.	


  Methods

     VDSetSelectState	Public		Set the state of the form
     VDGetSelectState	Public		Get the state of the form
     VDDspGrpGadg	Public		display or erase a group of gadgets 
     VDVerifyLogin	Public		verify if the user is logged in the
					database and if he has defined a
					project number.
     VDReadFileAttr	Public		Read an ascii file and put all the
					attributes in the given gadget list.

     select_row		Public		perform the selection of a row in a 
					field. 
     insert_row		Public		perform the insertion of a row in a 
					field. 
     delete_row		Public		perform the delete of a row in a 
					field. 
     set_insert_mode	Public		Set a given field in INSERT mode
     set_single_select_mode Public	Set a given field in SINGLE_SELECT 
					mode.
     GadgOf 		Public		Erase or disable a list of gadgets.
     GadgOn 		Public		display or enable a list of gadgets.
     control_form_state	Public		display the form depending on its state.
     form_position	Public		display the forms in the right position.
     init_all		Public		initialize the instances.
     delete_all		Public		free the instances.
     reset_all		Public		called when FI_RESET in the form.
     save_all		Public		called when FI_EXECUTE or FI_ACCEPT.
     verify_input_row	Public		verify the user input in the a given
					field.
     erase_hilite	Public		erase all hilite in me->ModuleInfo.

     addLocatedObject	Public		stores a graphic object and its
					environment.
     getLocatedObjects	Public		Gets a list of located objects from
					the first one.
     getLocObjAtIndex	Public		Gets one located object.

     removeLastLocatedObjects Public	remove all the objects from the index.

     dpLocObjs		Public		displays the located objects from the
					given index.

     dpLocObjAtIndex	Public		displays the located object at the 
					given index.

     verifyObjs		Public		verifies if the located objects are     
					still valid (for wakeup)

     set_dynamics_in_form               Turns on the dynamic tracking of
                        Public          mouse position in the form

     stop_dynamics_in_form              Turns off the dynamic tracking of
                        Public          mouse position in the form

     get_event_with_dynamics            filter that gets event with dynamic
                        Public          tracking of mouse position
     
     mouse              Public          Explains the mouse position on 
                                        dynamic forms
  Overridden Methods

     form_notification	implements the main gadgets (EXIT, SAVE ...)
     filter		implements the I/VDS filter


 -------------------------------------------------------------------------

-cmd*/



#include "VDSFilter.h"
#include "VDSLocateDef.h"
#include "growner.h"
#include "vdgraphicenv.h"


/*+v
 -------------------------------------------------------------------------

  The following instances need to be filled by the subclasses in order
  to use the methods.(form pointer and gadget_label)


*/

instance 
{
  int 				form_state;  /* state of the form 	 */
  int 				old_form_state;
  int				del_flag;    /* delete_row flag		 */
  int				insert_flag; /* insert_row flag		 */
  int				select_flag; /* select_row flag		 */
  int				selected_row;/* selected row		 */
  variable struct GRobj_env	locObjs[0] ; /* located objects		 */
  int				g_list;      /* gadget label of 	 */
					     /* multicolumn field        */

  /*
   * Form pointers and their corresponding windows where dynamic-tracking
   * of mouse cursor has been turned on.
   */
  VDgrEnvWindow                    dynWno[VD_K_MAX_DYN_FORMS] ;
  char                            *dynFrm[VD_K_MAX_DYN_FORMS] ;
   
}

/*
 -------------------------------------------------------------------------
-v*/


/*---------------------
 * implementation area
 */



implementation

#include <stdio.h>
#include <lcmacros.h>
#include <math.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "go.h"
#include "igrdp.h"
#include "dp.h"
#include "dpmacros.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "FI.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "PDUerror.h"
#include "madef.h"
#include "AS_status.h"
#include "VDSFilter.h"
#include "VDSutil.h"

#include "vdsmacros.h"
#include "VDScheckdef.h"
#include "VDDbtbldef.h"
#include "VDmacdef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VDmsg.h"
#include "VDSLocateDef.h"
#include "vdgraphicenv.h"
#include "vdgrenvproto.h"

from	GRgraphics	import	GRdisplay;

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
 
	filter from CEO

  Abstract
	
	Overriden to allow the user to use the path system when locate
	by name.

  Algorithm
      <Optional>

  Arguments
     int	filter		I	constant defining the filter
     int	*response	I	wfi input type
     int	*response_data  I	wfi input data

  Notes/Remarks

    predefined filter are between 
   		_none			0
    		_gs_locate_noauto	9

   	see ode_export.h
   
    VDS filters are:
   		_vds_get_event		11	(1)
   		_vds_wfi		12	(2)
   		_vds_locate		13	(3)
   		_vds_locate_noauto	14	(4)
   		_vds_gs_locate		15	(5)
   		_vds_locate_event3	16	(6)
   		_vds_menu		17	(7)
   		_vds_locate_noauto_event3 18	(8)
   		_vds_gs_locate_noauto	19	(9)
   		_vds_get_event_with_dynamics  20

	see VDSFilter.h


 -------------------------------------------------------------------------
-mo*/

action filter
{
  struct GRevent		* p_event3 = NULL;
  struct CEO_instance		* p_CEO = ME.CEO;
  struct CEO_LOCATE_instance	* p_CEO_LOCATE = ME.CEO_LOCATE;

  p_CEO->ret = MSSUCC;
  status = OM_S_SUCCESS ;
 
  switch ( filter )
   {
      case _vds_locate_event3:
	/*" filter = _vds_locate_event3 = %d\n", filter */
	p_event3 = &p_CEO_LOCATE->event3;

	/* _no_break; */

      case _vds_locate:
	/*" filter = _vds_locate = %d\n", filter */

	p_CEO_LOCATE->DisplayMode = GRhe;

	status =
	om$send(msg = message CEO_LOCATE.display_located(
					 & p_CEO->ret ),
		targetid = my_id );
	as$status();

	status = lc$wild_disconnect ( p_chanselect =
				& p_CEO_LOCATE->located_chansel );
	/* 
	 * As in the CEO_LOCATE filter method.
	 * as$status();
	 */

	/* _no_break; */

      case _vds_locate_noauto_event3:

	if( filter == _vds_locate_noauto_event3 ){
	  /*" filter = _gr_locate_noauto_event3 = %d\n", filter */
	  p_event3 = &p_CEO_LOCATE->event3;
	}

	/* _no_break; */

      case _vds_locate_noauto :
	/*" filter = _vds_locate_noauto = %d\n", filter */

	if ( !p_CEO->prompt [0] )
	  strcpy ( p_CEO->prompt, "Enter locate point" );
	if ( !p_CEO_LOCATE->acc_prompt [0] )
	  strcpy ( p_CEO_LOCATE->acc_prompt,
				"Data point to accept; Reset to reject" );
	if ( !p_CEO_LOCATE->reloc_prompt [0] )
	  strcpy ( p_CEO_LOCATE->reloc_prompt,
				"No element located; Please retry" );

        /* Call locate filter to locate an object  */
        status =
        VDSlocate(   (IGRlong) & p_CEO->ret,
                     & p_CEO_LOCATE->event2,
                     & p_CEO_LOCATE->event1,
                       p_event3,
                       p_CEO_LOCATE->event_mask1,
                       p_CEO_LOCATE->event_mask2,
                     & p_CEO_LOCATE->event_size,
                       p_CEO_LOCATE->display_flag,
                       response,
                       response_data,
                       p_CEO->prompt,
                       p_CEO_LOCATE->acc_prompt,
                       p_CEO_LOCATE->reloc_prompt,
                     & p_CEO_LOCATE->attributes,
                     & p_CEO_LOCATE->stack,
                       p_CEO_LOCATE->dyn,
                       p_CEO_LOCATE->type,
                       p_CEO_LOCATE->action_handler,
                       p_CEO_LOCATE->action_args,
                       p_CEO_LOCATE->locate_rtree,
                       p_CEO_LOCATE->locate_eligible,
                       p_CEO_LOCATE->select,
                       p_CEO_LOCATE->select_args,
                       p_CEO_LOCATE->stack_size,
                       p_CEO_LOCATE->regex,
                       LC_NO_MSG,		/* locate_key */
                       LC_NO_MSG,               /* acc_key    */
                       LC_NO_MSG,               /* reloc key  */
                       (IGRint) p_CEO_LOCATE->HilightMode,
                       (IGRint) p_CEO_LOCATE->UnhilightMode,  
                     & p_CEO_LOCATE->nbytes2,
                     & p_CEO->nbytes1,
                       p_CEO_LOCATE->range_handler,
                       p_CEO_LOCATE->range_args,
                       p_CEO_LOCATE->value_type_locate,
                       p_CEO_LOCATE->value_type_accept,
                       p_CEO_LOCATE->scale_flag );

        if( status == 1){
          if( p_CEO->ret == LC_ONE_ELEM_ACCEPT || 
              p_CEO->ret == LC_OBJ_LOCATED     ){

            /*** if event 3 was not used, then the located	***/
            /***    object is in event1			        ***/

            if( p_event3 == NULL )
              p_event3 = & p_CEO_LOCATE->event1;

            p_CEO_LOCATE->locate_ModuleInfo = 
                              p_event3->located_object[0].module_info;

            status = lc$connect(
                    p_chanselect = & p_CEO_LOCATE->located_chansel,
                    go_objid = p_event3->located_object[0].located_obj.objid,
                    go_osnum = p_event3->located_object[0].located_obj.osnum );
            /* 
             * As in the CEO_LOCATE filter method.
             * as$status();
             */
          }
        }
        else{
          p_CEO->ret = COB_E_FILTER_FAIL;
        }

	break;

      case _vds_get_event_with_dynamics :
        status = om$send( msg     = message VDS_LOCATE.get_event_with_dynamics(
                                                      response, response_data ),
                       targetid= my_id ) ;
        break ;

      case _vds_get_event :
	/*" SM_LOCATE : _vds_get_event(%d) \n", filter */

      case _vds_wfi :
	/*" SM_LOCATE : _vds_wfi(%d)\n", filter */

      case _vds_gs_locate :
        /*" SM_LOCATE : _vds_gs_locate(%d)\n", filter */

      case _vds_menu :
        /*" SM_LOCATE : _vds_menu(%d)\n", filter */

      case _vds_gs_locate_noauto :
        /*" SM_LOCATE : _vds_gs_locate_noauto(%d)\n", filter */

	filter -= 10;

      case _gr_locate_event3:
      case _gr_locate:
      case _gr_locate_noauto_event3:
      case _gr_locate_noauto:

      default: 
	/*" SM_LOCATE : default (%d)\n", filter */

        status =
        om$send(msg = message CEO_LOCATE.filter( filter,
                                                 response,
                                                 response_data ),
                targetid = my_id,
                mode = OM_e_wrt_message );
        break;
   }
   goto quit;

}

/*+me
 -------------------------------------------------------------------------
  Public Message get_event_with_dynamics

  Abstract
        Get event with dynamic tracking of mouse position.

  Arguments
        int     *response       O    
        char    *response_data  O

  Status/Return Code
      status == OM_S_SUCCESS	always;

 -------------------------------------------------------------------------
-me*/

action get_event_with_dynamics( int   *response;
                                char  *response_data )
{

   long         msg ;
   VDgrEnvEvent events ;
   int          resp,
                wflag,
                isCollapsed,
                i,
                x,
                y,
                ox = -1,
                oy = -1 ;

   status = OM_S_SUCCESS ;
   ex$message( in_buff	        = me->prompt,
               justification    = RIGHT_JUS ) ;

   while( TRUE ) 
   {
      if( VD_InqEvents( &events ) ) 
      {
         if( VD_isBtnOrWnEvent( &events ) ) 
         {
            if( !VD_FI_process_event( &events ) ) 
            {
               if( VD_isWnEvent( &events ) ) 
               {
                  VD_DPhandle_event( &events ) ;
               } 
               else 
                  break ;
            }
         } 
         else if( VD_isKeyBoardEvent( &events ) ) 
         {
            break ;
         }
      } 
      else if( ex$peek_event_queue( resp = &resp ) ) 
      {
         break ;
      }

      for( i = 0 ; i < VD_K_MAX_DYN_FORMS ; i++ ) 
      {
         if( !me->dynFrm[i] ) 
            continue ;
         status = FIf_is_collapsed( me->dynFrm[i],
                                    &isCollapsed ) ;

         if( status != FI_SUCCESS || isCollapsed ) 
            continue ;

         if( VD_Mouseposition( &me->dynWno[i],
                               &x,
                               &y,
                               &wflag ) != 0 ) 
            goto ENDLOOP ;

         if( wflag && ( ox != x || oy != y ) ) 
         {
            ox = x ; 
            oy = y ;

            status = om$send( msg = message VDS_LOCATE.mouse( &msg, 
                                                              me->dynFrm[i],
                                                              x, y ),
                              targetid= my_id ) ;
            as$status( value = ENDLOOP );
            break ;
         }
      }
   }

ENDLOOP :

   status = om$send( msg = message CEO_LOCATE.filter( _get_event,
                                                   response,
                                                   response_data ),
                  targetid= my_id ) ;

   goto quit;
} 

/*+me
 -------------------------------------------------------------------------
  Public Message mouse

  Abstract
        Message sent to command when dynamic tracking of cursor is on and
        the mouse cursor has changed position over a form. 
        Does nothing at this level -> needs to be overriden by subclasses.

  Arguments
        long    *msg            O       Completion code.
        char    *form           I       Pointer to form over which cursor is.
        int     x               I       x of cursor on form.
        int     y               I       y of cursor on form.

  Status/Return Code
      status == OM_S_SUCCESS    always;

 -------------------------------------------------------------------------
-me*/

action mouse( long *msg ;
              char *form ;
              int  x;
              int  y )
{
   status = OM_S_SUCCESS ;
   *msg = MSSUCC ;
   goto quit;
}


/*+me
 -------------------------------------------------------------------------
  Public Message set_dynamics_in_form

  Abstract
        Turns on the dynamic tracking of mouse cursor. As cursor flies over the
        form, the message "mouse" is sent to the command object each time the
        position changes.
        Instead of filter "get_event", filter "VDget_event_with_dynamics"
        (#defined in vscmddef.h) must be used for the tracking to be performed.

  Arguments
        long    *msg            O       Completion code.
        char    *form           I       Pointer to form were tracking must be
                                        enabled.

  Status/Return Code
      status == OM_S_SUCCESS    always;

 -------------------------------------------------------------------------
-me*/

action set_dynamics_in_form( long  *msg;
                             char  *form )
{
   VDgrEnvWindow  wno ;

   status = OM_S_SUCCESS ;
   *msg    = MSSUCC ;
   me->ret = OM_S_SUCCESS ;

   if( form && VD_FIf_get_window( form, &wno ) == FI_SUCCESS ) 
   {
      int  i,
      slot = -1 ;

      for( i = 0 ; i < VD_K_MAX_DYN_FORMS ; i++ ) 
      {
         if( me->dynFrm[i] == form ) 
         {
            /*
             * Already listed !.
             */
             goto quit ;
          }
       }

       for( i = 0 ; i < VD_K_MAX_DYN_FORMS ; i++ ) 
       {
          if( !me->dynFrm[i] ) 
          { 
             slot = i ; 
             break ; 
          }
       }
       if( slot != -1 ) 
       {
          me->dynFrm[slot] = form ;
          me->dynWno[slot] = wno ;
       } 
       else 
       {
          /*
           * No more room.
           */
          *msg = MSFAIL ;
          me->ret = OM_W_ABORT ;
       }
   }

} /* method set_dynamics_in_form */


/*+me
 -------------------------------------------------------------------------
  Public Message stop_dynamics_in_form

  Abstract
        Turn off dynamic tracking of mouse cursor.

  Arguments
        long    *msg            O       Completion code.
        char    *form           I       Pointer to form were tracking must be
                                        disabled.

  Status/Return Code
      status == OM_S_SUCCESS    always;

 -------------------------------------------------------------------------
-me*/

action stop_dynamics_in_form( long *msg ;
                              char *form )
{
   int     i ;

   status = OM_S_SUCCESS ;
   *msg    = MSFAIL ;
   me->ret = OM_W_ABORT ;

   for( i = 0 ; i < VD_K_MAX_DYN_FORMS ; i++ ) 
   {
      if( me->dynFrm[i] == form ) 
      {
         me->dynFrm[i] = NULL ;
         *msg    = MSSUCC ;
         me->ret = OM_S_SUCCESS ;
         break ;
      }
   }
   goto quit;

} /* method stop_dynamics_in_form */


/*+me
 -------------------------------------------------------------------------
  Public Message erase_hilite

  Abstract
	Erase all the hilite in me->ModuleInfo

  Arguments
	long	*sts		O	completion code

  Status/Return Code
      status == OM_S_SUCCESS	always;

 -------------------------------------------------------------------------
-me*/

action erase_hilite
{
*sts = OM_S_SUCCESS;
  dp$erase_hilite (msg = &me->ret,
           objid = me->ModuleInfo.md_id.objid,
           osnum = me->ModuleInfo.md_id.osnum);

  status = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message verify_input_row

  Abstract
      Verify the user input in the label field.
      Does nothing at this level -> need to be overriden by subclasses.

  Arguments
	long	*sts		O	completion code
	char 	*form_ptr	I	form pointer
	int  	label 		I	gadget label where to verify

 -------------------------------------------------------------------------
-me*/

action verify_input_row(long *sts; char   *form_ptr; int label)
{
  *sts = OM_E_ABORT;
  status = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message save_all

  Abstract
      called when FI_EXECUTE or FI_ACCEPT.
      Does nothing at this level -> need to be overriden by subclasses.

  Arguments
	long	*sts		O	completion code

 -------------------------------------------------------------------------
-me*/

action save_all
{
  *sts = OM_E_ABORT;
  status = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message reset_all

  Abstract
      called when FI_RESET
      Does nothing at this level -> need to be overriden by subclasses.

  Arguments
	long	*sts		O	completion code

 -------------------------------------------------------------------------
-me*/

action reset_all
{
  *sts = OM_E_ABORT;
  status = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message delete_all

  Abstract
      free the instances. (called at delete time)
      Does nothing at this level -> need to be overriden by subclasses.

  Arguments
	long	*sts		O	completion code

 -------------------------------------------------------------------------
-me*/
action delete_all
{
  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message init_all

  Abstract
      init the instances. (called at init time)

  Arguments
	long	*sts		O	completion code


 -------------------------------------------------------------------------
-me*/
action init_all
{

  me->del_flag = 0;
  me->insert_flag = 0;
  me->select_flag = 0;
  me->selected_row = -1;

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message form_position

  Abstract
      display the forms in the right position.
      Does nothing at this level -> need to be overriden by subclasses.

  Arguments
	long	*sts		O	completion code

 -------------------------------------------------------------------------
-me*/
action form_position
{
  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message control_form_state

  Abstract
      display the form gadgets depending on the state of the form.
      Does nothing at this level -> need to be overriden by subclasses.

  Arguments
	long	*sts		O	completion code



 -------------------------------------------------------------------------
-me*/

action control_form_state
{
  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message GadgOn

  Abstract
      displays or enables a list of gadgets.
      Does nothing at this level -> need to be overriden by subclasses.

  Arguments
	long	*sts		O	completion code

 -------------------------------------------------------------------------
-me*/

action GadgOn
{

  /* use SMVA_display function with the list of gadgets */

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message GadgOf

  Abstract
      erases or disables a list of gadgets.
      Does nothing at this level -> need to be overriden by subclasses.

  Arguments
	long	*sts		O	completion code
 -------------------------------------------------------------------------
-me*/

action GadgOf
{
  /* use SMVA_erase function with the list of gadgets */

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message set_single_select_mode

  Abstract
      set the instance label field in FI_SINGLE_SELECT mode. 

  Arguments
	long 		*sts 		O	Completion code
	char 		*form_ptr	I	form pointer
	int  		label 		I	gadget label where to set mode
	int  		nb_col 		I	number of column in the gadget.


  Status/Return Code
      status == OM_S_SUCCESS	always


 -------------------------------------------------------------------------
-me*/


action set_single_select_mode(long *sts; char *form_ptr; int label; int nb_col)
{
 int            i, k, num_rows;
 long            mask;

   *sts = OM_S_SUCCESS;


   FImcf_get_attr(form_ptr,label,&mask);
   FImcf_set_attr(form_ptr,label,mask | FI_ROW_SELECT);
   for(i=0;i<nb_col;i++) 
		FIfld_set_mode(form_ptr,label,i,FI_SINGLE_SELECT);

   /* deselect all rows */

   FIfld_get_num_rows(form_ptr,label,&num_rows);
   for(i=0; i<num_rows;i++)
	for(k=0;k<nb_col;k++)
		FIfld_set_select(form_ptr,label,i, k, 0);

   FIg_display(form_ptr,label);

   status = OM_S_SUCCESS;
   goto quit;

}

/*+me
 -------------------------------------------------------------------------
  Public Message set_insert_mode

  Abstract
      set the instance label field in FI_INSERT mode. 

  Arguments
	long 		*sts 		O	Completion code
	char 		*form_ptr	I	form pointer
	int  		label 		I	gadget label where to set mode
	int  		nb_col 		I	number of column in the gadget.



  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

action set_insert_mode(long *sts; char *form_ptr; int label; int nb_col)
{
 int            i;
 long            mask;
   *sts = OM_S_SUCCESS;

   FImcf_get_attr(form_ptr,label,&mask);
   if(mask & FI_ROW_SELECT)
        FImcf_set_attr(form_ptr,label,mask ^ FI_ROW_SELECT);
   for(i=0;i<nb_col;i++)
		FIfld_set_mode(form_ptr,label,i,FI_INSERT);
   FIfld_pos_cursor(form_ptr,label, 0,0,0,0,0,0);
   FIg_display(form_ptr,label);

   status = OM_S_SUCCESS;
   goto quit;

}




/*+me
 -------------------------------------------------------------------------
  Public Message delete_row

  Abstract

      performs the delete of a row in the field label. 
      It is called when the button G_DELETE is pushed.

      delete row sequence:
		1/ me->delete_flag =0 indicate that the user wants to 
		   delete a row 


		2/ me->delete_flag =1 indicate that the user wants to store
 		   the selected row.


  Arguments
	long 		*sts 		O	Completion code
	char 		*form_ptr	I	form pointer
	int  		label 		I	gadget label where to delete

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

action delete_row(long *sts; char   *form_ptr; int label)
{
int  i;
int  nb_col, num_rows,sel_flag = FALSE;

*sts = OM_S_SUCCESS;

  FIfld_get_num_rows(form_ptr,label,&num_rows);
  if(num_rows == 0){
        FIg_set_text(form_ptr,FI_MSG_FIELD,"no row to delete");
        FIg_set_state_off(form_ptr,G_DELETE);
        *sts = OM_E_ABORT;
        goto quit;
  }
  FImcf_get_num_cols(form_ptr, label, &nb_col);

  if(! me->del_flag)
   {

     /* The user wants to select a row to delete it */

     me->del_flag = 1;
     om$send(msg = message VDS_LOCATE.set_single_select_mode
					(sts, form_ptr,label, nb_col),
                      targetid = my_id);
     FIg_set_state_on(form_ptr,G_DELETE);

     FIg_set_text(form_ptr,FI_MSG_FIELD,"select the row to be deleted");
   }
  else
   {

        /* The user wants to delete the selected row or go out of the */
        /* delete sequence.					      */

        FIfld_get_num_rows(form_ptr,label,&num_rows);
        for(i = 0; i < num_rows; i++)
         {
                FIfld_get_select(form_ptr,label,i,0,&sel_flag);
                if(sel_flag) break;
         }
        if(sel_flag)
                FIfld_delete_rows(form_ptr,label,i,1);

        om$send(msg = message VDS_LOCATE.set_insert_mode
				(sts, form_ptr, label, nb_col),
                      targetid = my_id);

     	me->del_flag = 0;
        FIg_set_state_off(form_ptr,G_DELETE);     

        FIg_set_text(form_ptr,FI_MSG_FIELD,"");
   }

   status = OM_S_SUCCESS;
   goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message insert_row

  Abstract

      performs the insertion of a row in the field label. 
      It is called when the button G_INSERT is pushed and it sets 
      me->inserted_row to the corresponding row.

      insert row sequence:
		1/ me->insert_flag =0 indicate that the user wants to 
		   insert a row 


		2/ me->insert_flag =1 indicate that the user wants to insert
 		   the selected row.


  Arguments
	long 		*sts 		O	Completion code
	char 		*form_ptr	I	form pointer
	int  		label 		I	gadget label where to insert


  Status/Return Code
      status == OM_S_SUCCESS	always

-------------------------------------------------------------------------
-me*/

action insert_row(long *sts; char   *form_ptr; int label)
{

int i;
int nb_col, num_rows,sel_flag = FALSE;

*sts = OM_S_SUCCESS;

  FIfld_get_num_rows(form_ptr,label,&num_rows);
  if(num_rows == 0){
        FIg_set_text(form_ptr,FI_MSG_FIELD,"no row to insert");
        FIg_set_state_off(form_ptr,G_INSERT);
        *sts = OM_E_ABORT;
        goto quit;
  }
  FImcf_get_num_cols(form_ptr, label, &nb_col);

  if( ! me->insert_flag)
   {
     /* The user wants to select a row to insert one */

     me->insert_flag = 1;
     om$send(msg = message VDS_LOCATE.set_single_select_mode
					(sts, form_ptr, label,nb_col),
                      targetid = my_id);

     FIg_set_state_on(form_ptr,G_INSERT);

     FIg_set_text(form_ptr,FI_MSG_FIELD,"select the row to insert");

   }
  else
   {
        /* The user wants to insert a row after the selected one or go out of */
	/* the insert sequence.					              */

        FIfld_get_num_rows(form_ptr,label,&num_rows);
        for(i = 0; i < num_rows; i++)
         {
                FIfld_get_select(form_ptr,label,i,0,&sel_flag);
                if(sel_flag) break;
         }
        if(sel_flag)
                FIfld_insert_blank_row(form_ptr,label,i);

        om$send(msg = message VDS_LOCATE.set_insert_mode
						(sts, form_ptr, label, nb_col),
                      targetid = my_id);

     	me->insert_flag = 0;
        FIg_set_state_off(form_ptr,G_INSERT);     

        FIg_set_text(form_ptr,FI_MSG_FIELD,"");

   }
   status = OM_S_SUCCESS;
   goto quit;

}
/*+me
 -------------------------------------------------------------------------
  Public Message select_row

  Abstract

      performs the selection of a row in the field label. 
      It is called when the button G_SELECT is pushed and it sets 
      me->selected_row to the corresponding row.

      Select row sequence:
		1/ me->select_flag =0 indicate that the user wants to 
		   select a row 


		2/ me->select_flag =1 indicate that the user wants to store
 		   the selected row.


  Arguments
	long 		*sts 		O	Completion code
	char 		*form_ptr	I	form pointer
	int  		label 		I	gadget label where to select

  Status/Return Code
      status == OM_S_SUCCESS	always


 -------------------------------------------------------------------------
-me*/


action select_row(long *sts; char   *form_ptr; int label)
{
int i;
int nb_col, num_rows,sel_flag = FALSE;

*sts = OM_S_SUCCESS;

  FIfld_get_num_rows(form_ptr,label,&num_rows);
  if(num_rows == 0){
        FIg_set_text(form_ptr,FI_MSG_FIELD,"no row to select");
        FIg_set_state_off(form_ptr,G_INSERT);
        *sts = OM_E_ABORT;
        goto quit;
  }
  FImcf_get_num_cols(form_ptr, label, &nb_col);

  if( ! me->select_flag)
   {
     /* The user wants to select a row */

     me->select_flag = 1;
     om$send(msg = message VDS_LOCATE.set_single_select_mode
						(sts, form_ptr, label, nb_col),
                      targetid = my_id);
     FIg_set_state_on(form_ptr,G_SELECT);

     FIg_set_text(form_ptr,FI_MSG_FIELD,"select the row");

   }
  else
   {
        /* The user wants to deselect a row or go out of */
	/* the select sequence.					              */

        FIfld_get_num_rows(form_ptr,label,&num_rows);
        for(i = 0; i < num_rows; i++)
         {
                FIfld_get_select(form_ptr,label,i,0,&sel_flag);
                if(sel_flag) break;
         }
        if(sel_flag)
		me->selected_row = i;

        om$send(msg = message VDS_LOCATE.set_insert_mode
						(sts, form_ptr, label, nb_col),
                      targetid = my_id);

     	me->select_flag = 0;
        FIg_set_state_off(form_ptr,G_SELECT);     

        FIg_set_text(form_ptr,FI_MSG_FIELD,"");

   }
   status = OM_S_SUCCESS;
   goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDReadFileAttr

  Abstract
      Read an ascii file and put all the attributes in the given gadget list.


  Algorithm

	- open the file (in the current or VDS/config directory)
	- read all the attributes 
	- set the attributes in the field list

  Arguments
	long 	*sts 		O 	completion code
	char 	*name_file      I	name of the ascii file to read
	char 	*form_ptr 	I	form pointer where gadget is in.
	int 	gadget_num	I	gadget label where to display the read
					attributes

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-me*/

action VDReadFileAttr(long *sts; char *name_file; char *form_ptr; int gadget_num)
{
  FILE  *fp;
  char  buffer[DI_PATH_MAX], *ptr;
  int   i,row;

  *sts = OM_S_SUCCESS;

  /* Read Tightness file */

  fp = NULL;

  /* Have to look inside the config */

  vd$openfile(file_name    = name_file,
          product_name = "Vds",
          sub_path     = "config",
          cur_dir      = TRUE,
          p_file       = &fp);
  if(fp == NULL)
   {printf("Error,cannot open the file: %s\n",name_file);
    goto wrapup;}
     
  row = 0;
  while(fgets(buffer,DI_PATH_MAX-1, fp) != NULL)
   {
     if(strlen(buffer) < 1) continue;  /* Take out the blank line */
     buffer[strlen(buffer)-1] = '\0'; /* To take into account the return */
     
     /* Skip blank characters */
     i = 0;
     while(isspace(buffer[i]) && buffer[i] != '\0') i++;
     ptr = &buffer[i];
     
     if(*ptr == '#') continue; /* A comment line (starting by #) */
     
     if(*ptr) /* Not blank line */
      {
    VDfld_set_list_text(form_ptr,gadget_num,
                row,0,ptr,0);
    FIfld_set_list_default_text(form_ptr,gadget_num,
                    row,0,ptr,0);
    row++;
      }
   }
  if(fp) { fclose(fp); fp = NULL; }

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;
  goto quit;

 wrapup:
  printf("Incorrect file format %s\n",name_file);
  if(fp) fclose(fp);
 
  *sts = OM_E_ABORT;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDVerifyLogin

  Abstract
	Verify if the user is logged into the database and if he has defined
	a project number.

  Algorithm
	VDSverify_login
	VDSverify_project

  Arguments
	long 		*sts 		O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always
      *sts = OM_E_ABORT if VDSverify_login or VDSverify_project fails.
	

 -------------------------------------------------------------------------
-me*/

action VDVerifyLogin
{
 *sts = OM_S_SUCCESS;

  if (VDSverify_login() != PDM_S_SUCCESS)
   {
     UI_status("User is not logged in to Database");
     *sts =  OM_E_ABORT;
     goto quit;
   }
  if (VDSverify_project() != OM_S_SUCCESS)
   {
     UI_status("User not Selected Project");
     *sts = OM_E_ABORT;
     goto quit;
   }
 status = OM_S_SUCCESS;
}



/*+mo
 -------------------------------------------------------------------------
  Overridden Message

	form_notification from CEO

  Abstract

 CEO.form_notification is called whenever a I/Forms form is given input     
 by the user.  It is analogous to super_cmd.form_input(); however, no input 
 is present in the "value" argument if the gadget type is a field.  See the 
 I/Forms Forms documentation about querying a form's gadgets to get their   
 values.                                                                    

 It has been overriden to provide some common behavior for subclasses
 (SAVE, EXIT ...) and to implement the gadget in the instance data.


  Arguments

  int    	form_label;  	label of form which received user  input 
  int    	gadget_label;   gadget label  which received user  input 
  double 	value;          value of gadget ( or field row # )       
  char 		* form_ptr ;    ptr to I/Forms form which received input 


 -------------------------------------------------------------------------
-mo*/


action form_notification (int form_label; int gadget_label ; double value ;
                          char * form_ptr)
{
  long  sts;

  if ( form_ptr == NULL ) return( OM_E_INVARG );

  if(gadget_label == me->g_list){

     if(me->del_flag)
      	FIg_set_text(form_ptr,FI_MSG_FIELD,"valid selection with delete button");

     else if(me->insert_flag)
      	FIg_set_text(form_ptr,FI_MSG_FIELD,"valid selection with insert button");

     else if(me->insert_flag)
      	FIg_set_text(form_ptr,FI_MSG_FIELD,"valid selection with select button");

     else 
    	status = om$send(msg = message VDS_LOCATE.verify_input_row
						(&sts, form_ptr, me->g_list), 
                      targetid = my_id);
     goto quit;
  }

  switch( gadget_label )
   {
   case FI_ACCEPT :
     status = om$send(msg = message VDS_LOCATE.save_all(&sts),
                      targetid = my_id);

     FIg_set_state_off(form_ptr,FI_ACCEPT);
     if(sts == OM_S_SUCCESS)
       _put_response(resp = TERMINATE);
     goto quit;

   case FI_EXECUTE :
     status = om$send(msg = message VDS_LOCATE.save_all(&sts),
             targetid = my_id);

     FIg_set_state_off(form_ptr,FI_EXECUTE);
     goto quit;

   case FI_CANCEL :
     _put_response(resp = TERMINATE);
     goto quit;

   case FI_RESET :
    status = om$send(msg = message VDS_LOCATE.reset_all(&sts),
                      targetid = my_id);
     if(!(status & sts & 1))
      {
        printf("Error reset\n");
	goto quit;
      }
     FIg_set_state_off(form_ptr,FI_RESET);
     goto quit;


    case G_DELETE:
     	status = om$send(msg = message VDS_LOCATE.delete_row
						(&sts, form_ptr, me->g_list),
                                targetid = my_id);
	break;

    case G_INSERT:
     	status = om$send(msg = message VDS_LOCATE.insert_row
						(&sts, form_ptr, me->g_list), 
                              targetid = my_id);
	break;

    case G_SELECT:
     	status = om$send(msg = message VDS_LOCATE.select_row
						(&sts, form_ptr, me->g_list), 
                                targetid = my_id);
	break;

  }
  

}

/*+me
 -------------------------------------------------------------------------
  Public Message VDDspGrpGadg

  Abstract
      display or erase a group of gadgets 

  Arguments
	long 		*sts 		O	Completion code
	char 		*form_ptr	I	form pointer
	int  		gadget_num	I	gadget_label of the group
	IGRboolean 	state		I	1 = display, 0 = erase


  Status/Return Code
      status == OM_S_SUCCESS	always


 -------------------------------------------------------------------------
-me*/


action VDDspGrpGadg(long *sts; char *form_ptr; int  gadget_num; IGRboolean state)
{

  *sts = OM_S_SUCCESS;

  FIgrp_set_pass_on(form_ptr,gadget_num);
  if(state)
    FIg_display(form_ptr,gadget_num);
  else
    FIg_erase(form_ptr,gadget_num);

  status = OM_S_SUCCESS;
  goto quit;

}
/*+me
 -------------------------------------------------------------------------
  Public Message VDGetSelectState

  Abstract
      Get the state of the form from the instance  me->form_state.


  Algorithm
      *form_state = me->form_state

  Arguments
	IGRlong *sts		O 	Completion code
	IGRint  *form_state	O	current state of the form

  Status/Return Code
      status == OM_S_SUCCESS	always
 -------------------------------------------------------------------------
-me*/


action VDGetSelectState(IGRlong *sts; IGRint *form_state)
{
  *sts = OM_S_SUCCESS;
  *form_state = me->form_state;

  status =  OM_S_SUCCESS;
  goto quit;

}
/*+me
 -------------------------------------------------------------------------
  Public Message VDSetSelectState

  Abstract
      Set the instance  me->form_state with the given state .


  Algorithm
      me->old_form_state = me->form_state
      me->form_state = state

  Arguments
	IGRlong *sts		O 	Completion code
	IGRint  form_state	I	state to set

  Status/Return Code
      status == OM_S_SUCCESS	always
 -------------------------------------------------------------------------
-me*/

action VDSetSelectState(IGRlong *sts; IGRint  form_state)
{
  *sts = OM_S_SUCCESS;
  me->old_form_state  = me->form_state;
  me->form_state = form_state;

  status =  OM_S_SUCCESS;
  goto quit;
}

/*+me
 -------------------------------------------------------------------------
  Public Message addLocatedObject

  Abstract
      Puts a graphic object in the locate list and stores its environment.

  Arguments
	IGRlong 	*sts		O 	Completion code
	struct GRid	objToAdd	I	Id of object to add.
	struct GRmd_env	envToAdd	I	Mod. env. of object to add.
	int		index		I	Index in list where object
						must be added.

  Notes/Remarks
	If `envToAdd' is NULL, the identity matrix will be used.

  Status/Return Code
      status == OM_S_SUCCESS	always
 -------------------------------------------------------------------------
-me*/

action addLocatedObject(	long		*sts;
				struct GRid	*objToAdd ;
				struct GRmd_env	*envToAdd ;
				int		index ) 
{

int	size, i ;

 *sts = OM_S_SUCCESS;

 size = om$dimension_of( varray = me->locObjs ) ;

	/*
	 * Is object already stored ?.
	 */

 for( i = 0 ; i < size ; i++ ) {
	if( objToAdd->objid == me->locObjs[i].obj_id.objid &&
	    objToAdd->osnum == me->locObjs[i].obj_id.osnum ) {
		*sts = ALREADY_LOC ; goto quit ;
	}
 }

 if( index >= size ) {
		/*
		 * Add.
		 */
	if( index == OM_K_MAXINT ) {
			/*
			 * Add at the end.
			 */
		index = size ;
	}
	if(! om$vla_set_dimension(	varray	= me->locObjs,
					size	= index + 1 ) ){
		printf("ERROR dynamic allocation\n");
		*sts = OM_E_ABORT;
		goto quit;
	}
	
 } 

 me->locObjs[index].obj_id = *objToAdd ;

 if( envToAdd ) {
	me->locObjs[index].mod_env	= *envToAdd ;
 } 
 else {
	ex$get_modid(	mod_osnum = objToAdd->osnum,
			mod_id	  = &me->locObjs[index].mod_env.md_id.objid ) ;

	me->locObjs[index].mod_env.md_id.osnum= objToAdd->osnum ;
	me->locObjs[index].mod_env.md_env.matrix_type = MAIDMX ;
	MAidmx( &sts, me->locObjs[index].mod_env.md_env.matrix ) ;
 }

 status = OM_S_SUCCESS;
 goto quit;

}

/*+me
 -------------------------------------------------------------------------
  Public Message getLocatedObjects

  Abstract
	Gets a list of located objects from the first one (at index 0) up.

  Arguments
	IGRlong 		*sts		O 	Completion code
	int			size		I	Size of output array.
	struct GRobj_env	*list		O 	Array where objects 
							will be put.

  Status/Return Code
      status == OM_S_SUCCESS	always
 -------------------------------------------------------------------------
-me*/

action getLocatedObjects( long *sts ; int size ; struct GRobj_env *list ) 
{

int	count,i ;
	
 *sts = OM_S_SUCCESS;

 count = om$dimension_of( varray = me->locObjs ) ;

 if( !count ) { *sts = NO_LOC_OBJ ; goto quit; }

 if( size < count ) count = size ;

 for( i = 0 ; i < count ; i++ ) {
		list[i] = me->locObjs[i] ;
 }

 status = OM_S_SUCCESS;
 goto quit;
	
}

/*+me
 -------------------------------------------------------------------------
  Public Message getLocObjAtIndex

  Abstract
	Gets one located object at the given index

  Arguments
	IGRlong 		*sts		O 	Completion code
	int			index		I	Index of wanted object.
	struct GRobj_env	*locObj 	O	Object at desired 
							index.	

  Status/Return Code
      status == OM_S_SUCCESS	always
 -------------------------------------------------------------------------
-me*/

action getLocObjAtIndex( long *sts ; int index ; struct GRobj_env *locObj ) 
{

int			size ;

 *sts	= OM_S_SUCCESS ;
 size = om$dimension_of( varray = me->locObjs ) ;

 if( index >= size ) {
		*sts = INVINDEX ; goto quit;
 }
 *locObj = me->locObjs[index] ;

 status = OM_S_SUCCESS;
 goto quit;
} 

/*+me
 -------------------------------------------------------------------------
  Public Message removeLastLocatedObjects

  Abstract
	Removes the last located objects (those from from_index to the end)
	from the locate list.

  Arguments
	IGRlong 	*sts		O 	Completion code
	int		from_index	I	Starting index from which 
						objects will be removed from 
						the locate list.
  Status/Return Code
      status == OM_S_SUCCESS	always
 -------------------------------------------------------------------------
-me*/

action removeLastLocatedObjects( long *sts; int from_index  ) 
{

int		size ;

 *sts = OM_S_SUCCESS;
 size = om$dimension_of( varray = me->locObjs ) ;

 if( from_index >= size ) { *sts = INVINDEX; goto quit; }

 om$vla_set_dimension( varray = me->locObjs, size = from_index ) ;

 status = OM_S_SUCCESS;
 goto quit;
}


/*+me
 -------------------------------------------------------------------------
  Public Message dpLocObjs

  Abstract
	Displays the located objects from the given index


  Arguments
	IGRlong 	*sts		O 	Completion code
	int		from_index	I	Start index of the objects to 
						be displayed.
	enum GRdpmode	dpmode		I	Display mode


  Status/Return Code
      status == OM_S_SUCCESS	always
 -------------------------------------------------------------------------
-me*/


action dpLocObjs( long *sts ; int from_index ; enum GRdpmode dpmode ) 
{

int			i, count ;
struct GRid		actMod;

 *sts = OM_S_SUCCESS ;
 count = om$dimension_of( varray = me->locObjs ) ;

 if( !count ) { *sts = NO_LOC_OBJ ; goto quit ; }
 if( from_index >= count ) { *sts = INVINDEX ; goto quit ; }

 ex$get_cur_mod( id = &actMod.objid, osnum = &actMod.osnum ) ;

 for (i = from_index; i< count; i++){
 	if( me->locObjs[i].obj_id.objid != NULL_OBJID ) {

        	om$send(msg     = message GRgraphics.GRdisplay(
                                        sts,
                                        &me->locObjs[i].mod_env.md_env.matrix_type,
                                        me->locObjs[i].mod_env.md_env.matrix,
                                        &dpmode,
                                        &actMod ),
                                senderid= me->locObjs[i].obj_id.objid,
                                targetid= me->locObjs[i].obj_id.objid,
                                targetos= me->locObjs[i].obj_id.osnum ) ;
 	}
 }


 status = OM_S_SUCCESS;
 goto quit;

}

/*+me
 -------------------------------------------------------------------------
  Public Message dpLocObjAtIndex

  Abstract
	Displays the located object at the given index


  Arguments
	IGRlong 	*sts		O 	Completion code
	int		index		I	index of the object to 
						be displayed.
	enum GRdpmode	dpmode		I	Display mode


  Status/Return Code
      status == OM_S_SUCCESS	always
 -------------------------------------------------------------------------
-me*/


action dpLocObjAtIndex( long *sts ; int index ; enum GRdpmode dpmode ) 
{

int			count ;
struct GRid		actMod;

 *sts = OM_S_SUCCESS ;
 count = om$dimension_of( varray = me->locObjs ) ;

 if( !count ) { *sts = NO_LOC_OBJ ; goto quit ; }
 if( index >= count ) { *sts = INVINDEX ; goto quit ; }

 ex$get_cur_mod( id = &actMod.objid, osnum = &actMod.osnum ) ;

 if( me->locObjs[index].obj_id.objid != NULL_OBJID ) {

        om$send(msg     = message GRgraphics.GRdisplay(
                                        sts,
                                        &me->locObjs[index].mod_env.md_env.matrix_type,
                                        me->locObjs[index].mod_env.md_env.matrix,
                                        &dpmode,
                                        &actMod ),
                                senderid= me->locObjs[index].obj_id.objid,
                                targetid= me->locObjs[index].obj_id.objid,
                                targetos= me->locObjs[index].obj_id.osnum ) ;
 }


 status = OM_S_SUCCESS;
 goto quit;

}

/*+me
 -------------------------------------------------------------------------
  Public Message verifyObjs	

  Abstract
 	verifies if the located objects are still valid

  Arguments
	IGRlong 	*sts		O 	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always
 -------------------------------------------------------------------------
-me*/

action verifyObjs
{
int		size,		/* Of a vla			*/
		i,		/* Loop-on-loc'd-objects index	*/
		objectLost ;	/* Did we lose an object ?	*/

 *sts = OM_S_SUCCESS;
 objectLost = FALSE ;
 size = om$dimension_of( varray = me->locObjs ) ;

 for( i = 0 ; i < size ; i++ ) {
	if( !( om$is_objid_valid(
				objid	= me->locObjs[i].obj_id.objid,
				osnum	= me->locObjs[i].obj_id.osnum ) & 1)) {
		ex$message(	field   = 2,
				msgnumb = VD_S_PreLocObjLost);
				
		objectLost = TRUE ;
		break ;
	}
 }
if( objectLost ) {
	/*
	 * Some of the located objects have disappeared when
	 * command was stacked: bad, abort command.
	 */

	*sts = LOST_OBJ;
}
 status = OM_S_SUCCESS;
 goto quit;

}
