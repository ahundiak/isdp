/* $Id: VDCmdMvDrwV.t,v 1.4 2002/04/19 21:20:39 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vddrawing/cmd /VDCmdMvDrwV.t
 *
 * Description:
 * 	This file contains the transition table for the Move Drawing View
 *      commands.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdMvDrwV.t,v $
 *      Revision 1.4  2002/04/19 21:20:39  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/05/02 18:52:49  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/04/27 19:36:02  ylong
 *      TR5120, "Move Drawing View" is not in the pload
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/08/29  15:46:30  pinnacle
# Created: vddrawing/cmd/VDCmdMvDrwV.t by yzhu for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/28/97	YZHU		Create
 * -------------------------------------------------------------------*/

command_string	    "Move Drawing View",1,VDMvDrwV
command_table       "vds.cmd"
class               VDCmdMvDrwV
product_name        "$VDS_PATH"
options		    "siTC"

start_state         start

state_table

#include "comnindex.h"
#include "comndef.h"
#include "grmessage.h"

state start
    on CMD_TYPE = COmn_move     
        do message_key GRC_M_Move
        do locate_properties "MOVE_LC_PROPS | LC_RW"
        do locate_owner "MOVE_LC_OWNER | LC_MOVE_CMD"
        state locate_object
    on CMD_TYPE = COmn_copy
        do message_key GRC_M_Cp
        do locate_properties "COPY_LC_PROPS"
        do locate_owner "COPY_LC_OWNER"
        state locate_object

state locate_object
    prompt  	"Identify Drawing View"
/*    prompt_key GR_P_IdEle */
    accept_key GR_P_AccFrPt
    gslocate_spec_prompt1_key GR_P_EntFrPt
    relocate_key GR_E_EleNotFnd
    gslocate_num_inputs 1
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA | GRm_RESTART"
    gslocate_spec_mask1 "GRm_DATA | GRm_RESTART | GRm_RJT_MOVEON"
/*    locate_eligible "+GRgraphics" */
    locate_eligible "+GRdrawview"
    locate_display "MANIP_LC_DISFLAG"
    filter gs_locate_noauto
        on EX_DATA
            do store_event (1, 0)  /* store "from" point */
            state move_object

state from_point
    prompt_key GR_P_EntFrPt
    filter get_event
        on EX_DATA
            do store_event (1, 0)  /* store "from" point */
            state move_object
        on EX_BACK_UP or EX_RESTART or EX_RJT_MOVEON
            do erase_hilite_plane ()
            do disconnect_located 1
            state locate_object

state move_object
    execute SSenter()
    execute SSactivate() 
    prompt_key GR_P_EntDstPt
    dynamics COmn_move
    filter get_event
        on EX_DATA
            do store_event (1, 1)
            do get_matrix ()
                on SUCCESS
                    on CMD_TYPE = COmn_move
                        do VDsetDrwRecomputeOff ()
                        do transform ()
                            on SUCCESS or WARNING
                                do copy_events (1, 0) 
                                do VDsetDrwRecomputeOn ()
                                state . 
                            on ERROR
                                do status_key GR_E_ErrEncCmdRst
                                do erase_hilite_plane ()
                                do SSexit()
                                do disconnect_located 1
                                do VDsetDrwRecomputeOn ()
                                state start
                        do SSexit()
                        do VDsetDrwRecomputeOn ()
                        state terminate
                    on CMD_TYPE = COmn_copy
                        do transform_copy ()
                            on SUCCESS or WARNING
                                do copy_events (1, 0)
                                state .
                            on ERROR
                                do status_key GR_E_ErrEncCmdRst
                                do erase_hilite_plane ()
                                do disconnect_located 1
                                do SSexit()
                                state start
                        do SSexit()
                        state terminate
                    do SSexit()
                    state terminate
                on ELSE
                    do status_key GR_E_ErrEncCmdRst
                    do erase_hilite_plane ()
                    do disconnect_located 1
                    do SSexit()
                    state start
            do SSexit()
            state terminate
        on EX_RJT_MOVEON or EX_RESTART
            do erase_hilite_plane ()
            do disconnect_located 1
            do SSexit()
            state locate_object
        on EX_BACK_UP
            do SSexit()
            state from_point
