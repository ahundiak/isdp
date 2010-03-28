/*

Name
  COmeas2.I

Description
  Implementation of measurement command methods.
  
Notes
  For the 2.4 release, this file and COmeasure.S were created from the
  state language file COmeasure.sl) and headers were added to some
  methods.  The methods are usually called from the CEO/CEO_LOCATE execute 
  code commands are usually designed from state transition (.t) files.

  For all methods below:  if *sts is the first (or only) argument, it
  returns the status of the method.  If this argument is not described 
  in the method header, it should be checked only for TRUE (*sts & 1) or 
  FALSE (! (*sts & 1)).

  Methods for COmeasure are in several files (COmeas1.I, COmeas2.I, ...).
 */

class implementation COmeasure;

#include "grownmacros.h"
#include "codebug.h"
#include "igrmacros.h"
#include "coplcmac.h"
#include "FI.h"
#include "coniarray.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "exmacros.h"
#include "comiscmac.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"
#include "comeasure.h"
#include "grmessage.h"
#include "coreadout.h"
#include "codef.h"
#include "msmacros.h"
#include "madef.h"
%safe
#include <math.h>
%endsafe
#include <stdio.h>
#include "csdef.h"
#include "grcoordsys.h"
#include "csmacros.h"
#include "codynmeas.h"

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xos.h>
#include <ctype.h>
#endif

#define TOL_VAL 1.0e-12

extern    IGRboolean    COproj_pt_to_view_pl();
from GRdrawview  import GRget_drawview_scale;


/*
Name
  store_base_event

Abstract
  Saves the base data point for future reference

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method store_base_event ( long *sts )
{
  IGRlong               status;

  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  me->disp_flag = FALSE;
  /*
   * copy the base point into fourth event to save its original value;
   * then "normalize" the base point, which means if the apparent flag is
   * set ON, then project the base point onto the view plane.
   */
  me->fourth_event= me->event1;
  /* 
   *  DO NOT NORMALIZE.  THIS CAUSES PROBLEMS IN DYNAMICS TRIAD SISPLAY.
   *  (SRH) 10/9/92
   */
  /*
   status = om$send ( msg = message COmeasure.normalize_event( &msg,
                                                               &me->event1),
                    targetid = my_id);
   */ 
  /*
   * save the "normalized" point in both the first and third events.
   */
  me->first_event = me->event1;
  me->third_event = me->event1;

  me->form_fields[BASE_POINT_X_IND] = me->event1.event.button.x;
  me->form_fields[BASE_POINT_Y_IND] = me->event1.event.button.y;
  me->form_fields[BASE_POINT_Z_IND] = me->event1.event.button.z;
  me->display_field = me->display_field | GR_COMEAS_DISPLAY_BASE_EVENT;

  return OM_S_SUCCESS;
}

/*
Name
  store_current_event

Abstract
  Saves the current data point for future reference

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method store_current_event ( long *sts )
{
  IGRlong status;
    long msg;
    *sts = MSSUCC;
    status = OM_S_SUCCESS;

    me->disp_flag = TRUE;
    me->fifth_event = me->event1;
    status = om$send ( msg = message COmeasure.normalize_event( &msg,
                                                               &me->event1),
                       targetid = my_id);
    
    me->second_event = me->event1;

    me->form_fields[CURR_POINT_X_IND] = me->event1.event.button.x;
    me->form_fields[CURR_POINT_Y_IND] = me->event1.event.button.y;
    me->form_fields[CURR_POINT_Z_IND] = me->event1.event.button.z;
    me->display_field = me->display_field | GR_COMEAS_DISPLAY_CURRENT_EVENT;

  return OM_S_SUCCESS;
}

/*
Name
  calc_delta_prev_current

Abstract
  calculates the delta X, Y, and Z  coordinate distances for the last two pts

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method calc_delta_prev_current ( long *sts )
{
  IGRlong               status;

  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  me->form_fields[DELTA_PREV_TO_CURR_X_IND] =
                               (me->second_event.event.button.x -
                                me->first_event.event.button.x);

  me->form_fields[DELTA_PREV_TO_CURR_Y_IND] =
                               (me->second_event.event.button.y-
                                me->first_event.event.button.y);

  me->form_fields[DELTA_PREV_TO_CURR_Z_IND] =
                               (me->second_event.event.button.z -
                                me->first_event.event.button.z);
  me->display_field = me->display_field | GR_COMEAS_DISPLAY_DELTA_PREV_CURRENT;

  return OM_S_SUCCESS;
}

/*
Name
  calc_delta_base_current

Abstract
  calculates the delta X, Y, and Z  coordinate distances for the last pts and
  the base (first) point

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method calc_delta_base_current ( long *sts )
{
  IGRlong               status;

    *sts = MSSUCC;
    status = OM_S_SUCCESS;

    me->form_fields[DELTA_BASE_TO_CURR_X_IND] =
                               (me->second_event.event.button.x -
                                me->third_event.event.button.x);

    me->form_fields[DELTA_BASE_TO_CURR_Y_IND] =
                               (me->second_event.event.button.y -
                                me->third_event.event.button.y);

    me->form_fields[DELTA_BASE_TO_CURR_Z_IND] =
                               (me->second_event.event.button.z -
                                me->third_event.event.button.z);
    me->display_field = me->display_field | GR_COMEAS_DISPLAY_DELTA_BASE_CURRENT;

  return OM_S_SUCCESS;

}

/*
Name
  store_dis_base_current ( long *sts )

Abstract
  Saves the distance between the base pt and the last entered pt.

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method store_dis_base_current ( long *sts )
{
    IGRlong               status;
    struct GRevent   *events[NUMBER_OF_EVENTS];
    IGRdouble         current_measurement;

    *sts = MSSUCC;
    status = OM_S_SUCCESS;

    set_up_event_array;

    events[0] = &me->third_event;
    events[1] = &me->second_event;

    if ( !CO_ni_index_in_range( ME.super_cmd->mytype ) )
     {
        return( status );
     }

    status = CO_GA_ni_funcs[ ME.super_cmd->mytype ](sts,
                                                    events,
                                                   &current_measurement,
                                                    me->Units );

    if ( COERROR( status ) || COERROR( *sts ) )
     {
        *sts = MSFAIL;
         ex$message( msgnumb = GR_E_ErrInCalc,
                     field   = ERROR_FIELD,
                     justification = LEFT_JUS );
     }

    me->form_fields[DIST_BASE_TO_CURR_IND] = current_measurement + TOL_VAL;
    me->display_field = me->display_field | GR_COMEAS_DISPLAY_BASE_CURRENT_DISTANCE;

  return OM_S_SUCCESS;
}


/*
Name
  measure 

Abstract
  One of the notorious NI (non-interactive) function switching stations.
  The function pointed to by CO_GA_ni_funcs[ ME.super_cmd->mytype ] is
  executed with a standard argument list:  

    int *sts 
      same *sts argument used in this method

    struct GRevent *events
      array of GRevent structures - each function defines the meaning of these

    double *current_measurement
      the value measured within the function

    char *units
      the type of measurement returned (i.e. GRIO_DISTANCE, GRIO_ANGLE, etc.)

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method measure ( long *sts )
{
    IGRlong               status;
    struct GRevent   *events[NUMBER_OF_EVENTS];
    IGRdouble         current_measurement;
    double            scale;

    *sts = MSSUCC;
    status = OM_S_SUCCESS;

    /*
     *  make sure that the function index is in the range allowable
     */
    if ( !CO_ni_index_in_range( ME.super_cmd->mytype ) )
     {
        return( status );
     }

    /*
     *  03/13/89 - SRH - KLUDGE; save last measurement for cursor
     *                   "prev dist" field
     */
    me->seventh_event.event.value = me->form_fields[CURRENT_MEAS_IND];

    /*
     *  set up the array of events so that the function that we
     *  called will know all the data points an values that the user
     *  has entered.
     */
    set_up_event_array;

    /*
     *  now, call the measurement routine.
     */
    status = om$send( msg = message COmeasure.COdetail_model(sts),
                        targetid = my_id);

    status = CO_GA_ni_funcs[ ME.super_cmd->mytype ](sts,
                                                    events,
                                                   &current_measurement,
                                                    me->Units );

    if ( COERROR( status ) || COERROR( *sts ) )
     {
        *sts = MSFAIL;
        ex$message( msgnumb = GR_E_ErrInCalc,
                    field   = ERROR_FIELD,
                    justification = LEFT_JUS );


    }
   else
    {
     me->form_fields[CUMULATIVE_MEAS_IND] += current_measurement + TOL_VAL;
     me->form_fields[CURRENT_MEAS_IND] = current_measurement + TOL_VAL;
     me->display_field = me->display_field | GR_COMEAS_DISPLAY_CURRENT_DISTANCE;
    }

    
    if (me->adv_flag && (!me->ref_att_flag)) {
          scale = me->scale_fac;
     me->form_fields[CURRENT_MEAS_IND]*=scale;
     me->form_fields[CUMULATIVE_MEAS_IND]*=scale;
     me->form_fields[DELTA_PREV_TO_CURR_X_IND] = me->cur_fields[3] *scale;

      me->form_fields[DELTA_PREV_TO_CURR_Y_IND] = me->cur_fields[4] *scale;

      me->form_fields[DELTA_PREV_TO_CURR_Z_IND] = me->cur_fields[5] *scale;
     }
     if ((!me->adv_flag) && me->ref_att_flag){
          scale = me->scale_fac;
     me->form_fields[CURRENT_MEAS_IND]/=scale;
     me->form_fields[CUMULATIVE_MEAS_IND]/=scale;
     me->form_fields[DELTA_PREV_TO_CURR_X_IND] = me->cur_fields[3] ;
     me->form_fields[DELTA_PREV_TO_CURR_Y_IND] = me->cur_fields[4];
     me->form_fields[DELTA_PREV_TO_CURR_Z_IND] = me->cur_fields[5];
      }

  return OM_S_SUCCESS;

} /* measure */


/*
Name
  measure_by_object

Abstract
  Yet another notorious NI (non-interactive) function switching stations.
  The function pointed to by CO_GA_ni_funcs[ ME.super_cmd->mytype ] is
  executed with a standard argument list:  

    int *sts 
      same *sts argument used in this method

    struct GRevent *events[]
      array of GRevent structures - each function defines the meaning of these

    struct GRmd_env *ModuleInfo
      the modlue in which the measurement is scoped to

    double *current_measurement
      the value measured within the function

    char *units
      the type of measurement returned (i.e. GRIO_DISTANCE, GRIO_ANGLE, etc.)

    GRobjid               my_id
      the objid of the command object

    OM_S_CHANSELECT      *p_chanselect
      channel to which the object is connected

    struct GRid          *object_grids
      if channel selector not used (NULL) then grid of element measured
  
Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method measure_by_object ( long *sts )
{
  struct GRevent   *events[NUMBER_OF_EVENTS];
  IGRdouble         current_measurement;
  IGRlong           status = OM_S_SUCCESS;

  *sts = MSSUCC;

  /*
   *  make sure that the function index is in the range allowable.
   */
  if ( !CO_ni_index_in_range( ME.super_cmd->mytype ) )
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
   *  now, call the measurement routine.
   */
  status = CO_GA_ni_funcs[ ME.super_cmd->mytype ](sts,
                                                  events,
                                                 &me->ModuleInfo,
                                                 &current_measurement,
                                                  me->Units,
                                                  my_id,
                                                 &me->located_chansel,
                                                  NULL );
  if ( COERROR( status ) || COERROR( *sts ) )
  {
    *sts = MSFAIL;
    ex$message( msgnumb = GR_E_ErrInCalc,
                field   = ERROR_FIELD,
                justification = LEFT_JUS );


  }
  else
  {
    me->form_fields[CUMULATIVE_MEAS_IND] += current_measurement;
    me->form_fields[CURRENT_MEAS_IND] = current_measurement;
    me->display_field = me->display_field | GR_COMEAS_DISPLAY_CURRENT_DISTANCE;
  }

  return OM_S_SUCCESS;

}

/*
Name
  measure_two_elements
  

Abstract
  Yet another notorious NI (non-interactive) function switching stations.
  The function pointed to by CO_GA_ni_funcs[ ME.super_cmd->mytype ] is
  executed with a standard argument list:  

    int *sts 
      same *sts argument used in this method

    struct GRevent *events[]
      array of GRevent structures - each function defines the meaning of these

    struct GRmd_env *ModuleInfo
      array of modules of the measured elements

    double *current_measurement
      the value measured within the function

    char *units
      the type of measurement returned (i.e. GRIO_DISTANCE, GRIO_ANGLE, etc.)

    GRobjid               my_id
      the objid of the command object

    OM_S_CHANSELECT      *p_chanselect
      channel to which the object is connected

    struct GRid          *object_grids
      if channel selector not used (NULL) then grid of element measured
  
Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */

method measure_two_elements ( long *sts )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRevent     *events[NUMBER_OF_EVENTS];
    IGRdouble           current_measurement;

    declare_multi;

    *sts = MSSUCC;

    /*
     *  get myself to set up some data structures
     */
    set_up_multi;
    set_up_event_array;
    status = om$send(msg = message COnpt.set_up_n_elements(grids ),
                     targetid = my_id );
    _m_checkq( status );

    /*
     *  now, call the measurement routine.
     */
    status = CO_GA_ni_funcs[ ME.super_cmd->mytype ](sts,
                                                    events,
                                                    modules,
                                                   &current_measurement,
                                                    me->Units,
                                                    my_id,
                                                    NULL,
                                                    grids );
    if ( COERROR( status ) || COERROR( *sts ) )
    {
        *sts = MSFAIL;
         ex$message( msgnumb = GR_E_ErrInCalc,
                   field   = ERROR_FIELD,
                   justification = LEFT_JUS );
    }
    else
    {
      me->form_fields[CUMULATIVE_MEAS_IND] += current_measurement;
      me->form_fields[CURRENT_MEAS_IND] = current_measurement;
      me->first_event = *events[0];
      me->second_event = *events[1];
      me->form_fields[BASE_POINT_X_IND] = events[0]->event.button.x;
      me->form_fields[BASE_POINT_Y_IND] = events[0]->event.button.y;
      me->form_fields[BASE_POINT_Z_IND] = events[0]->event.button.z;
      me->form_fields[CURR_POINT_X_IND] = events[1]->event.button.x;
      me->form_fields[CURR_POINT_Y_IND] = events[1]->event.button.y;
      me->form_fields[CURR_POINT_Z_IND] = events[1]->event.button.z;
      me->display_field = me->display_field | GR_COMEAS_DISPLAY_CURRENT_DISTANCE;
    }

quit:
  return OM_S_SUCCESS;

}

/*
Name
  normalize_event

Abstract
  "Normalizing" just means that the point stored in the event is 
  projected onto the view plane in which is is entered.  The value
  of the points coordinates are only adjusted if the DPB's "apparent"
  flag is set.

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method normalize_event( IGRlong *sts;
                        struct GRevent *event)
{
    IGRlong                status = OM_S_SUCCESS;
    IGRdouble              return_point[3];
    IGRboolean             b_status;
    IGRlong                size;
    IGRlong                ret_size;
    IGRboolean             apparent_flag;

    *sts = MSSUCC;

#ifndef IDRAW
    size = sizeof(apparent_flag);
    status = gr$get_apparent_flag(msg = sts,
                                   sizbuf = &size,
                                   buffer = &apparent_flag,
                                   nret= &ret_size);

    if(apparent_flag)
     {
       b_status = COproj_pt_to_view_pl( sts,
                                        event,
                                        return_point);

       event->event.button.x = return_point[0];
       event->event.button.y = return_point[1];
       event->event.button.z = return_point[2];
     }
#endif /* IDRAW */
  return OM_S_SUCCESS;
}

/*
Name
  project_accept_on_element 

Abstract
  copies the projected point (put in event by locate filter) into the
  button coordinates.

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method project_accept_on_element ( long *sts )
{
     me->event1.event.button.x = me->event1.located_object[0].proj_pnt[0];
     me->event1.event.button.y = me->event1.located_object[0].proj_pnt[1];
     me->event1.event.button.z = me->event1.located_object[0].proj_pnt[2];
  return OM_S_SUCCESS;
}

end implementation COmeasure;
