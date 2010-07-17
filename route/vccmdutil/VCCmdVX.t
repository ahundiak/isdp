
/* $Id: VCCmdVX.t,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdutil/VCCmdVX.t
 *
 * Description:
 *      Command object for operations on cable vertices/segments
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdVX.t,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/11/03  16:55:38  pinnacle
# Replaced: vccmdutil/VCCmdVX.t for:  by impd for route
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.8  1997/07/26  13:57:52  pinnacle
# Replaced: vccmdutil/VCCmdVX.t for:  by hverstee for cabling
#
# Revision 1.7  1997/07/22  15:18:14  pinnacle
# Replaced: vccmdutil/VCCmdVX.t for:  by hverstee for cabling
#
# Revision 1.6  1997/05/07  16:13:22  pinnacle
# Replaced: vccmdutil/VCCmdVX.t for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  22:21:36  pinnacle
# Replaced: vccmdutil/VCCmdVX.t for:  by hverstee for cabling
#
# Revision 1.4  1997/01/16  14:51:06  pinnacle
# Replaced: vccmdutil/VCCmdVX.t for:  by hverstee for cabling
#
# Revision 1.3  1996/10/08  21:48:08  pinnacle
# Replaced: vccmdutil/VCCmdVX.t for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  20:28:04  pinnacle
# Replaced: vccmdutil/VCCmdVX.t for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:02:56  pinnacle
# Created: vccmdutil/VCCmdVX.t by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Command object to modify (insert/move/delete vertex) the free linestring
    sections of a composite cable object

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

class             VCCmdVX
product_name     "$ROUTE"
command_table    "cable.cmd"
options          "isTC"
start_state       main
command_string    VCC_M_CbInsVert,0,VCCbIvtx
synonym           VCC_M_CbMovVert,1,VCCbMvtx
synonym           VCC_M_CbDelVert,2,VCCbDvtx
synonym           VCC_M_CbRecVert,3,VCCbRvtx
synonym           VCC_M_CbMovSeg,4,VCCbMseg
synonym           VCC_M_CbInsBrk,5,VCCbIbrk

/*****************************************************************************
  STATES AREA 
*****************************************************************************/

state_table

#include        "grmessage.h"
#include        "griodef.h"
#include        "msdef.h"
#include        "lcdef.h"
#include        "FI.h"
#include        "VCmsg.h"
#include        "VCCmdDef.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state main

  on ELSE
  state Cstart

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Cstart

  on CMD_TYPE = 0
  state INSget

  on CMD_TYPE = 1 
  state MOVget

  on CMD_TYPE = 2 
  state DELget

  on CMD_TYPE = 3 
  state MVSget

  on CMD_TYPE = 4 
  state RECget

  on CMD_TYPE = 5 
  state IBRget

  on ELSE
  state unimplemented

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state unimplemented

  message_key   VC_M_UnImplemented
  status_key    VC_S_Exiting

  on ELSE
  state terminate

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state Cleanup

  on ELSE
  state terminate

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state INSget

  message_key       VC_M_CbInsVert
  prompt_key        VC_P_SelCable
  accept_key        VC_P_AccSegment
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCGetItem
    state INSproc

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state INSproc

  message_key       VC_M_CbInsVert
  prompt_key        VC_P_SelLocation
  dynamics          VC_MLDYN_MVTX
  filter            get_event

  on EX_DATA
    do VCProcess
    state INSget

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state IBRget

  message_key       VC_M_CbInsBrk
  prompt_key        VC_P_SelCable
  accept_key        VC_P_AccSegment
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCGetItem
    state IBRproc

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state IBRproc

  message_key       VC_M_CbInsBrk

  on ELSE
    do VCProcess
    state IBRget

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state MOVget

  message_key       VC_M_CbMovVert
  prompt_key        VC_P_SelCable
  accept_key        VC_P_AccVertex
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCGetItem
    state MOVproc

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state MOVproc

  message_key       VC_M_CbMovVert
  prompt_key        VC_P_SelLocation
  dynamics          VC_MLDYN_MVTX
  filter            get_event

  on EX_DATA
    do VCProcess
    state MOVget

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state DELget

  message_key       VC_M_CbDelVert
  prompt_key        VC_P_SelCable
  accept_key        VC_P_AccVertex
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCGetItem
    state DELproc

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state DELproc

  message_key       VC_M_CbDelVert

  on ELSE
   do VCProcess
   state DELget

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state MVSget

  message_key       VC_M_CbMovSeg
  prompt_key        VC_P_SelCable
  accept_key        VC_P_AccSegment
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCGetItem
      on RETURN_CODE = VC_RTC_ALLOK
         state MVSproc

    state .

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state MVSproc

  message_key       VC_M_CbMovSeg
  prompt_key        VC_P_SelLocation
  dynamics          VC_MLDYN_MSEG
  filter            get_event

  on EX_DATA
    do VCProcess
    state MVSget

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

state RECget

  message_key       VC_M_CbRecVert
  prompt_key        VC_P_SelCable
  accept_key        VC_P_AccSegment
  locate_eligible   "+VCCable"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCGetItem
    state RECproc

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state RECproc

  on ELSE
    do VCProcess
    state RECget

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

