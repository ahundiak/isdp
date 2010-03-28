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
#include "griomacros.h"
#include "igrmacros.h"
#include "lcmacros.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "maerr.h"
#include <stdio.h>

/*
  override init;
  override wakeup;
  override delete;
  override sleep;
  override filter;
  override dynamics;
*/

method init ( int type ; char * str_ptr )
{
  int status = OM_S_SUCCESS;

  /*
   *  send to our parent to its stuff done
   */
  status = om$send(mode = OM_e_wrt_message,
                   msg = message CEO_LOCATE.init( type, str_ptr ),
                   targetid = my_id );

  me->ObjectWasLocated = FALSE;
  me->ObjectOnFirstLocated = FALSE;
  me->ObjectOnSecondLocated = FALSE;
  return OM_S_SUCCESS;
}

method wakeup ( int pos )
{
  int status = OM_S_SUCCESS;

  IGRlong           SecondObjectCount = 0;
  IGRlong           FirstObjectCount = 0;
  IGRlong           LocatedObjectCount = 0;
  IGRlong           msg = MSSUCC;
  IGRboolean        LocatedLost;
  IGRboolean        FirstLost;
  IGRboolean        SecondLost;
  OM_S_CHANSELECT   MyChannelStruct;

  /*
   *  send to my parent
   */
  status = om$send(mode = OM_e_wrt_message,
                   msg = message CEO_LOCATE.wakeup( pos ),
                   targetid = my_id );
  _m_checkq( status );

  /*
   *  get a count of the number of objects on the other side of the
   *  channel
   */
  status = lc$get_channel_count(osnum = OM_Gw_current_OS,
                                objid = my_id,
                                p_chanselect = &me->located_chansel,
                                count = &LocatedObjectCount );

  /*
   *  initialize the channel structure
   */
  status = om$make_chanselect( chanaddr     = &me->ToFirstLocated,
                               p_chanselect = &MyChannelStruct );

  /*
   *  get a count of the number of objects on the other side of the
   *  channel
   */
  status = lc$get_channel_count(osnum = OM_Gw_current_OS,
                                objid = my_id,
                                p_chanselect = &MyChannelStruct,
                                count = &FirstObjectCount );
  _m_checkq( status );


  /*
   *  initialize the channel structure
   */
  status = om$make_chanselect(chanaddr     = &me->ToSecondLocated,
                              p_chanselect = &MyChannelStruct );
    
    
  /*
   *  get a count of the number of objects on the other side of the channel
   */
  status = lc$get_channel_count(osnum = OM_Gw_current_OS,
                                objid = my_id,
                                p_chanselect = &MyChannelStruct,
                                count = &SecondObjectCount );
  _m_checkq( status );

  /*
   *  if an object has been located, and there is not one object on
   *  the other side of the channel, then SOMETHING'S WRONG!!!!!!!
   */
  LocatedLost = (LocatedObjectCount!=1)&&(me->ObjectWasLocated);
  FirstLost = (FirstObjectCount!=1)&&(me->ObjectOnFirstLocated);
  SecondLost = (SecondObjectCount!=1)&&(me->ObjectOnSecondLocated);
  if ( FirstLost   ||   SecondLost   ||  LocatedLost )
  {
    ex$message( msgnumb = GR_E_PreLocObjLost,
                field   = ERROR_FIELD,
                justification = LEFT_JUS );

    me->ObjectWasLocated = FALSE;
    me->ObjectOnFirstLocated = FALSE;
    me->ObjectOnSecondLocated = FALSE;

    /*
     *  get this command to start over
     */
    me->state = 0;        /* start state */
    me->next_state = 0;   /* start state */
    status = om$send( msg = message CEO_LOCATE.action( _go_next_state,
                                                       NULL,
                                                       (IGRint *)&msg ),
                      targetid = my_id );
    } /* if ( no objects when there should be ) */

quit:
  return OM_S_SUCCESS;
}

method delete ( int f_defer_flag )
{
  int     status = OM_S_SUCCESS;
  IGRlong msg = MSSUCC;

  status = om$send(mode = OM_e_wrt_message,
                   msg = message CEO_LOCATE.delete( f_defer_flag ),
                   targetid = my_id );


  status = om$send(msg = message COnpt.clear_channels( &msg ),
                   targetid = my_id );
  return OM_S_SUCCESS;
}

method sleep ( int pos )
{
  int status = OM_S_SUCCESS;

  status = om$send(mode = OM_e_wrt_message,
                   msg = message CEO_LOCATE.sleep ( pos ),
                   targetid = my_id );

  return OM_S_SUCCESS;
}

method filter ( int filter ; int * response ; char * response_data )
{
  int status = OM_S_SUCCESS;

  if ( filter == _gr_locate  || filter == _gr_locate_noauto )
  {
    me->ObjectWasLocated = FALSE;
  }

  /*
   *  send to parent
   */
  status = om$send(mode = OM_e_wrt_message,
                   msg = message CEO_LOCATE.filter(filter,
                                                   response,
                                                   response_data ),
                   targetid = my_id );

  return OM_S_SUCCESS;
}

method dynamics ( int dynamics ; int * sts )
{
  int             status = OM_S_SUCCESS;
  struct GRevent *events[NUMBER_OF_EVENTS];
  IGRboolean      BufferDynamics = TRUE;


  status = OM_S_SUCCESS;
  *sts = MSSUCC;

  /*
   *  for now, a KLUDGE.
   *  if the dynamics index is negative, then make it positive,
   *  and use object dynamics.  This is mainly for shelley
   *  for polygon
   */
  if ( dynamics < 0 )
  {
    BufferDynamics = FALSE;
    dynamics *= -1;
  }


  /*
   *  make sure that the function index is in the range allowable,
   *  make sure that there is that many functions, and that the
   *  index is greater than zero
   */
  if ( !CO_ni_index_in_range( dynamics ) )
  {
    return( status );
  }

  /*
   *  set up the array of events so that the function that we
   *  called will know all the data points an values that the user
   *  has entered.
   */
  set_up_event_array;


  /*
   *  now, call the dynamics routine.
   */
  if ( BufferDynamics )
  {
    struct IGRdisplay ActiveDisplay;
    IGRlong           NumberOfBytes,
                      BytesReceived;

    /*
     *  get the default display symbology data from the DPB
     */
    NumberOfBytes = sizeof( ActiveDisplay );
    gr$get_active_display( msg = sts,
                           sizbuf = &NumberOfBytes,
                           buffer = &ActiveDisplay,
                           nret = &BytesReceived );
    _m_checkq( *sts );


    /*
     *  now, call the buffer dynamics routine.
     */
    CO_GA_ni_funcs[ dynamics ]( events, &ActiveDisplay );
  }
  else /* do object dynamics */
  {
    if ( !CO_ni_index_in_range( me->mytype ) )
    {
      return( status );
    }

    /*
     *  now, call the object dynamics routine
     */
    CO_GA_ni_funcs[ dynamics ]( me->mytype, 
                                events, 
                               &me->ModuleInfo,
                                my_id,
                                OM_Gw_current_OS,
                               &me->located_chansel,
                                NULL );
  }

quit:
  return OM_S_SUCCESS;
}


end implementation COnpt;
