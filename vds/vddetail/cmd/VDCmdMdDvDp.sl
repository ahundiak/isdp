/* $Id: VDCmdMdDvDp.sl,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdMdDvDp.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdMdDvDp.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
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
# Revision 1.2  1995/08/07  22:32:02  pinnacle
# Replaced: vddetail/cmd/VDCmdMdDvDp.sl for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/11  22:42:50  pinnacle
# updated files
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/************************************************************************
 *
 *   File name     :          VDCmdMdDvDp.sl
 *   Creation date :          22 June '94
 *   Author        :          Radhai Manem
 *   Product       :          I/VDS - VDSdetail
 *
 *          Set Display Depths from Drawing View
 *
 *   Description : 
 *   -----------
 *   The command object gets the z depths of the clipping polygon 
 *   associated with a drawing view and activates these depths in the 
 *   specified window.
 *
 *   The command object was created as a workaround for the locate 
 *   problem - location of objects (using fence) outside the range of the
 *   drawing view.
 *
 *   The command object does the following :
 *            - gets the drawing view
 *            - gets the window in which to set the depths
 *            - activates the display depths in the window
 *
 *   History :
 *
 *        06/22/93     rmn     Creation
 *
 ************************************************************************/


/*
 *       class specification area
 */

command_string     VDC_M_StDpDrVw, 0, VDStDpDrVw
class              "VDCmdMdDvDp"
super_class        "VDCmdMdDet"
product_name       "$VDS"
command_table      "vds.cmd"
options            "SITC"

/*
 *       specification area
 */

specification


instance
{
     struct GRid wind_id;    /* window id */
}


/*
 *       implementation area
 */

implementation

#include "dpmacros.h"
#include "dpdef.h"

/*
 *            state table area
 */


state_table

#include "VDmsg.h"

state start

     message_key          VD_M_StDpDrVw     
     prompt_key           VD_P_IdDrVw
     accept_key           VD_P_AccRej
     relocate_key         VD_P_ObjNtFnd
     locate_eligible      "GRdrawview"
     locate_properties    "LC_DP_ONLY | LC_LC_ONLY"
     locate_owner         "LC_RIGID_OWNER | LC_FLEX_OWNER | LC_FLEX_COMP"
     locate_display       "ELEM_HILIGHT"
     dynamics             0
     mask                 "GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP"
     filter               locate     

     on EX_RJT_MOVEON     state terminate

     on EX_DATA
          do erase_highlight
          do get_drawview        /* Get drawview, reffile and clippoly */
              on ERROR
                  do status_key VD_E_UnableCP           state terminate
          state St_Window


state St_Window

     message_key          VD_M_StDpDrVw     

/* prompt message key defined in VDvisual.mb */
     prompt_key           VD_P_VsIdWin

     dynamics             0
     mask                 "EX_DATA | RESET"
     filter               get_event     

     on RESET
          state start

     on EX_DATA
          do store_window
          do set_new_depths
          state terminate

/*
     ------------------------------------------------------------------
               Actions definition
     ------------------------------------------------------------------
 */

action store_window
{

     status = OM_S_SUCCESS ;

     me->wind_id.objid = me->event1.event.button.objid;
     me->wind_id.osnum = me->event1.event.button.osnum;

     goto quit ;
}


action set_new_depths
{
     IGRdouble    depths[6] = {0,0,0,0,0,0};
     IGRlong      msg;

/* Get the z depths of the clipping polygon - results in me->z1 and me->z2 */

     status = om$send( mode     = OM_e_wrt_message,
                       msg      = message VDCmdMdDet.display_Zdepths( sts ),
                       targetid = my_id );
     as$status();

     if (!(status & 1)) 
     {
          *sts = ERRO ; 
          goto quit ;
     }

/* set up the new depths */

     depths[2] = me->z1 ;
     depths[5] = me->z2 ;

/* activate the depths in the window */

     status = dp$view_vol( msg            = &msg,
                           gg_id          = &(me->wind_id),
                           display_depths = depths,
                           update         = TRUE);

     if( !(status & 1) )
     {
          as$status();
          *sts = status;
          goto quit;
     }

     *sts = SUCC ;
}
