/* $Id: VCCmdGdVX.t,v 1.2 2001/01/11 20:34:06 anand Exp $ */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vccmdutil/VCCmdGdVX.t
 *
 * Description:
 *      Command object for operations on Guide vertices/segments
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdGdVX.t,v $
 *        Revision 1.2  2001/01/11 20:34:06  anand
 *        SP merge
 *
# Revision 1.2  2000/04/28  21:44:58  pinnacle
# Replaced: route/vccmdutil/VCCmdGdVX.t for:  by lawaddel for Service Pack
#
# Revision 1.1  2000/04/28  21:39:38  pinnacle
# Created: route/vccmdutil/VCCmdGdVX.t by lawaddel for Service Pack
#
# Revision 1.1  2000/03/24  14:16:18  pinnacle
# Created for Guide Vertex Move/Delete/Insert command.
#
 *
 * History:
 *        03/24/2000		Alwin		Creation
 *
 *************************************************************************/

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Command object to modify (insert/move/delete vertex) the free linestring
    sections of a Guide object

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

class             VCCmdGdVX
/* product_name     "$SPXR" */
product_name     "$ROUTE"
command_table    "cable.cmd"
options          "isTC"
start_state       main
command_string    VCC_M_GdInsVert,0,VCGdIvtx
synonym           VCC_M_GdMovVert,1,VCGdMvtx
synonym           VCC_M_GdDelVert,2,VCGdDvtx

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

#define			NO_DELETE 1
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

  message_key       VC_M_GdInsVert
  prompt_key        VC_P_SelGuide
  accept_key        VC_P_AccSegment
  locate_eligible   "VCGuide"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCGetItem
	do VCGdLocateSegment
    state INSproc

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state INSproc

  message_key       VC_M_GdInsVert
  prompt_key        VC_P_SelLocation
  dynamics          VC_MLDYN_MVTX
  filter            get_event

  on EX_DATA
    do VCGdModify
    state INSget

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state MOVget

  message_key       VC_M_GdMovVert
  prompt_key        VC_P_SelGuide
  accept_key        VC_P_AccVertex
  locate_eligible   "VCGuide"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCGetItem
	do VCGdLocateVertex
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
    do VCGdModify
    state MOVget

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state DELget

  message_key       VC_M_GdDelVert
  prompt_key        VC_P_SelGuide
  accept_key        VC_P_AccVertex
  locate_eligible   "VCGuide"
  locate_owner      "VC_LOCATE_LOCAL"
  dynamics          off
  filter            locate

  on EX_DATA
    do VCGetItem
	do VCGdLocateVertex( &me->ret )
	on RETURN_CODE = NO_DELETE 		state .
    state DELproc

  on ELSE
    state Cleanup

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
state DELproc

  message_key       VC_M_CbDelVert

  on ELSE
   do VCGdModify
   state DELget

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
