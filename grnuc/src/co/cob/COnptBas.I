/*

Name
  COnptBas.I

Description
  Fundamental methods used my most COnpt based commands.
  
Notes
  ALL COnpt methods should return OM_S_SUCCESS, otherwise the state
  could iterate.  A 'sts' argument should be used to return status
  values that can be referenced in state trasition files (.t. files).

 */
class implementation COnpt;



#include "coimport.h"
#include "codebug.h"
#include "grerr.h"
#include "grmessage.h"
#include "codef.h"
#include "godef.h"
#include "msdef.h"
#include "madef.h"
#include "dpdef.h"
#include "griodef.h"
#include "grio.h"
#include "comisc.h"
#include "comiscmac.h"
#include "coniarray.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "msmacros.h"
#include "grdpbmacros.h"
#include "igr.h"
#include "go.h"
#include "griomacros.h"
#include "igrmacros.h"
#include "lcmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "maerr.h"
#include <stdio.h>
#include "bserr.h"
#include "bsdmod.h"

/*
 * imported messages
 */
from GRcurve import GRendpts;

/*

Name
  get_construct_env_from_dpb

Abstract
  loads the module environment (from DPB) into instance data for
  future reference.
  
Synopsis
  get_construct_env_from_dpb ( long * sts )
  
Description
  sts - same as returned in sts argument of gr$get_construct_env()
  
Return Value
  OM_S_SUCCESS always!
  
Notes

Index

Keywords
  get

History
  05/28/93 : Shelley R. Heard : header added

 */
method get_construct_env_from_dpb ( long * sts )
{
  /*
   *  This method gets the construct environment from the dpb
   */
  IGRlong      NumberOfBytes, BytesReceived;

  /*
   *  get the construct environment from the DPB
   */
  NumberOfBytes = sizeof( struct GRmd_env );
  gr$get_construct_env(msg = sts,
                       point = &me->event1.event.button,
                       sizbuf = &NumberOfBytes,
                       buffer = &me->ConstructInfo,
                       nret = &BytesReceived );
  _m_checkq( *sts );

  /* KLUDGE - testing for now */
  me->ModuleInfo = me->ConstructInfo;

quit:
  return OM_S_SUCCESS;
}


/*

Name
   store_locate_context

Abstract
  saves the module environment of a located element (from me->event1) into
  instance data for future reference and sets the  me->ObjectWasLocated flag
  to TRUE to indicate that an elements has been located.
  
Synopsis
   store_locate_context ( long * sts )
  
Description
  sts - MSSUCC always.
  
Return Value
  OM_S_SUCCESS always!
  
Notes

Index

Keywords
  get

History
  05/28/93 : Shelley R. Heard : header added

 */
method store_locate_context ( long * sts )
{
  *sts = MSSUCC;
  me->ModuleInfo = me->event1.located_object[0].module_info;
  me->ObjectWasLocated = TRUE;

  return OM_S_SUCCESS;
}


method copy_event ( long           *sts; 
                   struct GRevent *to_event;
                   struct GRevent *from_event )
{
  *to_event = *from_event;

  return OM_S_SUCCESS;
}

method copy_event_by_index ( long *sts; int to_index; int from_index )
{
  struct GRevent *p_to_event, *p_from_event;

  switch( to_index )
  {
    case 0:   p_to_event = &me->first_event; break;
    case 1:   p_to_event = &me->second_event; break;
    case 2:   p_to_event = &me->third_event; break;
    case 3:   p_to_event = &me->fourth_event; break;
    case 4:   p_to_event = &me->fifth_event; break;
    case 5:   p_to_event = &me->sixth_event; break;
    case 6:   p_to_event = &me->seventh_event; break;
    default:  *sts = MSINARG; goto quit;
  }
  switch( from_index )
  {
    case 0:   p_from_event = &me->first_event; break;
    case 1:   p_from_event = &me->second_event; break;
    case 2:   p_from_event = &me->third_event; break;
    case 3:   p_from_event = &me->fourth_event; break;
    case 4:   p_from_event = &me->fifth_event; break;
    case 5:   p_from_event = &me->sixth_event; break;
    case 6:   p_from_event = &me->seventh_event; break;
    default:  *sts = MSINARG; goto quit;
  }
  *p_to_event = *p_from_event;

quit:
  return OM_S_SUCCESS;
}

method store_event_by_index ( long *sts; int index )
{
  *sts = MSSUCC;

  switch( index )
  {
    case 0:   me->first_event   = me->event1; break;
    case 1:   me->second_event  = me->event1; break;
    case 2:   me->third_event   = me->event1; break;
    case 3:   me->fourth_event  = me->event1; break;
    case 4:   me->fifth_event   = me->event1; break;
    case 5:   me->sixth_event   = me->event1; break;
    case 6:   me->seventh_event = me->event1; break;
    default:  *sts = MSINARG;
  }

  return OM_S_SUCCESS;
}

method verify_active_angle ( IGRlong *sts;
                             IGRshort geom )
{
  IGRlong    msg;
  IGRlong    localsize;
  IGRdouble  active_angle;
  IGRdouble  basis_tol;
  IGRlong    mynret;
  IGRdouble  mymod; 
  IGRdouble  mypi; 
  IGRlong    rc;

  localsize = sizeof( active_angle );
  gr$get_active_angle ( msg    = &msg,
                        sizbuf = &localsize,
                        buffer = &active_angle,
                        nret   = &mynret );
  _m_checkq(msg);   

  mypi  = PI;
  mymod = BSdmod( active_angle,
                  mypi,
                  &rc );
  if( rc != 0 ) goto quit;  


  gr$get_basis_tolerance ( msg    = &msg,
                           sizbuf = &localsize,
                           buffer = &basis_tol,
                           nret   = &mynret );
  _m_checkq(msg);   
          

  if (( active_angle == 0.0 ) || ( mymod <= basis_tol ))
  {
    if( geom == 0 ) 
    {
      ex$message( msgnumb       = GR_E_InAnAr,
                  field         = ERROR_FIELD,
                  justification = LEFT_JUS );
    }
    else
    {
      ex$message( msgnumb       = GR_E_InAnCr,
                  field         = ERROR_FIELD,
                  justification = LEFT_JUS );
    }
    *sts = MSFAIL;
  }
  else
  {
    *sts = MSSUCC;
  }

quit:
  return OM_S_SUCCESS;
}

method push_accept_event_on_queue ( long * sts )
{
  IGRlong size;

  *sts = MSSUCC;

  size = sizeof( struct GRevent ) - sizeof( IGRlong ) - sizeof( IGRlong );
  me->event1.num_id = 0;
  ex$putque( msg = (IGRlong *)sts,
             response = &me->event1.response,
             byte = &size,
             buffer = (IGRchar *)&me->event1.event );

  return OM_S_SUCCESS;
}

method push_first_event_on_queue ( long * sts )
{
  IGRlong size;

  *sts = MSSUCC;

  size = sizeof( struct GRevent ) - sizeof( IGRlong ) - sizeof( IGRlong );

  ex$putque( msg = (IGRlong *)sts,
             response = &me->first_event.response,
             byte = &size,
             buffer = (IGRchar *)&me->first_event.event );

  return OM_S_SUCCESS;
}

method reload_last_point ( long * sts )
{
  int status = OM_S_SUCCESS;

  IGRint Size = sizeof( struct EX_button ),
         ReturnSize;

  IGRpoint point,   /* last point in a linear element  */
           dummy_pt;/* first point in a linear element */

  struct EX_button LastPoint;  /* from DPB */

  OMuint   ret_count = 0;

  *sts = MSSUCC;

  /* check if channel is empty */
  status = om$get_channel_count(object = me,
                                p_chanselect = &me->const_chansel,
                                count = &ret_count);
 
  if ( ret_count ) {
 

  /*
   *  get the last point of the curve back
   */
  status = om$send( msg = message GRcurve.GRendpts(
                       (IGRlong *)sts,
                       &me->ModuleInfo.md_env.matrix_type,
                       me->ModuleInfo.md_env.matrix,
                       dummy_pt,
                       point ),

                    p_chanselect = &me->const_chansel );

  _m_check2( status,
             *sts,
             ex$message( msgnumb = GR_E_CouNoRecLasPt,
                         field   = ERROR_FIELD,
                         justification = LEFT_JUS ) );

  /* 
   * We need reliable window information from the last point;  there is
   * no guarentee that event1 was an EX_DATA event
   */
  gr$get_last_point(  msg    =  sts,
                      sizbuf = &Size,
                      buffer = &LastPoint,
                      nret   = &ReturnSize );

  /* 
   *  Override the subtype and stuff the last end point coordinates
   *  into event1
   */

  Size = ( sizeof( struct GRevent ) - ( 2 * sizeof( IGRint ) ) );
  status = co$build_event( msg          =  sts,
                           event_nbytes =  Size,
                           event        = &me->event1,
                           button       = &LastPoint  );

  me->event1.event.button.x = point[0];
  me->event1.event.button.y = point[1];
  me->event1.event.button.z = point[2];

 }

  return OM_S_SUCCESS;
}

method save_first_element ( long * sts )
{
  int status = OM_S_SUCCESS;

  /*
   *  this action copies all the data pertaining to the current
   *  element located, and saves the object itself on another
   *  channel, and the locate context in another module info
   *  structure
   */
  IGRlong              NumberObjectsFound;
  OM_S_OBJECT_LINKAGE  ChannelLinkage[1];/* linkage to objects on channel */
  OM_S_CHANSELECT      MyChannelStruct;


  /*
   *  initialize the channel structure
   */
  status = om$make_chanselect(chanaddr     = &me->ToFirstLocated,
                              p_chanselect = &MyChannelStruct );

  status = lc$wild_disconnect(p_chanselect = &MyChannelStruct );
  _m_checkq( status );

  status = lc$get_channel_objects( objid = my_id,
                                   p_chanselect = &me->located_chansel,
                                   list = ChannelLinkage,
                                   size = 1,
                                   count = &NumberObjectsFound );
  _m_checkq( status );

  lc$connect(p_chanselect = &MyChannelStruct,
             go_objid =  ChannelLinkage[0].S_objid,
             go_osnum =  ChannelLinkage[0].osnum);

  /*
   *  now, copy the locate context information into a safe place
   */
  me->FirstContext = me->event1.located_object[0].module_info;

  /*
   *  record the fact that an object is on this channel (for wakeup)
   */
  me->ObjectOnFirstLocated = TRUE;
  me->ObjectWasLocated = FALSE;

quit:
  return OM_S_SUCCESS;
}

method save_second_element ( long * sts )
{
  int status = OM_S_SUCCESS;

  /*
   *  this action copies all the data pertaining to the current
   *  element located, and saves the object itself on another
   *  channel, and the locate context in another module info
   *  structure
   */
  IGRlong              NumberObjectsFound;
  OM_S_OBJECT_LINKAGE  ChannelLinkage[1];/* linkage to objects on channel */
  OM_S_CHANSELECT      MyChannelStruct;


  /*
   *  initialize the channel structure
   */
  status = om$make_chanselect(chanaddr     = &me->ToSecondLocated,
                              p_chanselect = &MyChannelStruct );

  /*
   *  see that my first located channel is clean
   */
  status = lc$wild_disconnect(p_chanselect = &MyChannelStruct );
  _m_checkq( status );

  status = lc$get_channel_objects( objid = my_id,
                                   p_chanselect = &me->located_chansel,
                                   list = ChannelLinkage,
                                   size = 1,
                                   count = &NumberObjectsFound );
  _m_checkq( status );

  lc$connect(p_chanselect = &MyChannelStruct,
             go_objid =  ChannelLinkage[0].S_objid,
             go_osnum =  ChannelLinkage[0].osnum);

  /*
   *  now, copy the locate context information into a safe place
   */
  me->SecondContext = me->event1.located_object[0].module_info;

  /*
   *  record the fact that an object is on this channel (for wakeup)
   */
  me->ObjectOnSecondLocated = TRUE;
  me->ObjectWasLocated = FALSE;

quit:
  return OM_S_SUCCESS;
}

method disconnect_channel ( long            *sts;
                           OM_S_CHANSELECT *p_chansel )
{
  lc$wild_disconnect( p_chanselect = p_chansel );

  return OM_S_SUCCESS;
}

method clear_channels ( long * sts )
{
  int status = OM_S_SUCCESS;
  OM_S_CHANSELECT  MyChannelStruct;

  status = om$make_chanselect( chanaddr     = &me->ToFirstLocated,
                               p_chanselect = &MyChannelStruct );

  status = lc$wild_disconnect( p_chanselect = &MyChannelStruct );
            
  status = om$make_chanselect( chanaddr     = &me->ToSecondLocated,
                               p_chanselect = &MyChannelStruct );

  status = lc$wild_disconnect( p_chanselect = &MyChannelStruct );

  status = lc$wild_disconnect( p_chanselect = &me->located_chansel );

  me->ObjectWasLocated      = FALSE;
  me->ObjectOnFirstLocated  = FALSE;
  me->ObjectOnSecondLocated = FALSE;

  return OM_S_SUCCESS;
}

method set_trim_flag_neither ( long * sts )
{
  *sts = MSSUCC;
  me->trim_flag = 0;
  me->event1.event.value = (IGRdouble)me->trim_flag;

  return OM_S_SUCCESS;
}

method set_trim_flag_man_1 ( long * sts )
{
  *sts = MSSUCC;
  me->trim_flag = me->trim_flag | 1;
  me->event1.event.value = (IGRdouble)me->trim_flag;

  return OM_S_SUCCESS;
}

method set_trim_flag_man_2 ( long * sts )
{
  *sts = MSSUCC;
  me->trim_flag = me->trim_flag | 2;
  me->event1.event.value = (IGRdouble)me->trim_flag;

  return OM_S_SUCCESS;
}

method set_trim_flag_auto_both ( long * sts )
{
  *sts = MSSUCC;

  me->trim_flag = 4;
  me->event1.event.value = (IGRdouble)me->trim_flag;

  return OM_S_SUCCESS;
}


method set_misc_flag ( long *sts; int flag_val )
{
  me->misc_flag = ( short ) flag_val;

  return OM_S_SUCCESS;
}

method get_misc_flag ( long * sts )
{
  *sts = ( int ) me->misc_flag;

  return OM_S_SUCCESS;
}


method make_data_event_tangent_to ( long * sts )
{
  /*
   *  this action assumes that the accept event was
   *  projected onto the element by locate.
   */
  me->event1.subtype = GRst_TANGENT_TO;
  me->event1.num_id = 1;
  me->event1.nbytes = sizeof( struct GRevent ) - (2 * sizeof( IGRlong ) );
  me->event1.event.button.x = me->event1.located_object[0].proj_pnt[0];
  me->event1.event.button.y = me->event1.located_object[0].proj_pnt[1];
  me->event1.event.button.z = me->event1.located_object[0].proj_pnt[2];

  return OM_S_SUCCESS;
}


/*
Name  get_channel_count( sts, chansel )

Abstract
    Returns in 'sts' the number of object connected to the 
    specified channel selector 'chansel'.

History
    04/12/89  srh   Created for support of constructed element being placed
                    on the construct channel insted of the locate channel.
                    This change is for the 1.2.1 "fixes" release.

Notes
    If lc$get_channel_count fails for any reason, the action will fail
    causing COB to restart the current state.
 */

method get_channel_count ( long *sts; OM_S_CHANSELECT *chansel )
{
  int status = OM_S_SUCCESS;

  /*
   * return in sts the channel count
   * if chansel is NULL, use construct channel as default
   * (this is a KLUDGE until CEO's arg_to_value supports const_chansel)
   */
  status = lc$get_channel_count( 
              osnum        = OM_Gw_current_OS,
              objid        = my_id,
              p_chanselect = chansel ? chansel : &me->const_chansel,
              count        = sts );

  return OM_S_SUCCESS;
}

/* 
 *  Added for TR 89N3047 fix to fillet commands.  We were corrupting 
 *  me->event1's matrix info used for displays. SRH 08/16/89
 */ 
method store_locate_event_by_index ( long *sts; int index )
{
  *sts = MSSUCC;

  switch( index )
  {
    case 0:   me->first_event   = me->event2; break;
    case 1:   me->second_event  = me->event2; break;
    case 2:   me->third_event   = me->event2; break;
    case 3:   me->fourth_event  = me->event2; break;
    case 4:   me->fifth_event   = me->event2; break;
    case 5:   me->sixth_event   = me->event2; break;
    case 6:   me->seventh_event = me->event2; break;
    default:  *sts = MSINARG;
  }

  return OM_S_SUCCESS;
}


end implementation COnpt;
