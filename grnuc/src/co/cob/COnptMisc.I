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

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include <stdio.h>

/* COnpt4.I - misc stuff */
/*
  gen_pts_by_spacing_along_element 
  gen_pts_along_element 
  set_default_event_by_index 
  gen_matrix_of_pts_by_row_col_deltas 
  gen_polar_pts 
  is_active_cell_defined 
  form_init 
  show_assoc_mode 
  wakeup_form 
 */

method gen_pts_by_spacing_along_element ( long * sts )
{
  int status = OM_S_SUCCESS;
  struct GRevent *events[NUMBER_OF_EVENTS];
  extern int      CO_ni_generate_pts_along_element_by_spacing();

  *sts = MSSUCC;

  set_up_event_array;

  /*
   *  generate points
   */
  status = CO_ni_generate_pts_along_element_by_spacing( sts, events );

  return OM_S_SUCCESS;
}

method gen_pts_along_element ( long * sts )
{
  int status = OM_S_SUCCESS;
  struct GRevent *events[NUMBER_OF_EVENTS];
  extern int      CO_ni_generate_equal_spaced_pts();

  *sts = MSSUCC;

  set_up_event_array;

  /*
   *  generate points
   */
  status = CO_ni_generate_equal_spaced_pts( sts, events );

  return OM_S_SUCCESS;
}

method gen_matrix_of_pts_by_row_col_deltas ( long * sts )
{
  int status = OM_S_SUCCESS;
  struct GRevent *events[NUMBER_OF_EVENTS];
  extern int      CO_ni_matrix_of_pts_by_row_col_delta();

  *sts = MSSUCC;

  set_up_event_array;

  /*
   *  call the non-interactive function
   */
  status = CO_ni_matrix_of_pts_by_row_col_delta( sts, events );

  return OM_S_SUCCESS;
}

method gen_polar_pts ( long * sts )
{
  int status = OM_S_SUCCESS;
  struct GRevent *events[NUMBER_OF_EVENTS];
  extern int      CO_ni_generate_arc_pt_pattern();

  *sts = MSSUCC;


  set_up_event_array;

  /*
   *  call the non-interactive function
   */
  status = CO_ni_generate_arc_pt_pattern( sts, events );

  return OM_S_SUCCESS;
}

method is_active_cell_defined ( long * sts )
{
  int status;

  IGRint        rc;
  struct GRactive_symbol_def   active_cell;
 
  *sts = MSSUCC;
  status = gr$symget_active_symbol (msg = &rc,
                                    act_symbol_def  = &active_cell);
  if ( rc != MSSUCC )
  {
    *sts = MSFAIL;
    ex$message(msgnumb = GR_F_NoActCelDfn);
    me->state = _terminate;
  }
  return OM_S_SUCCESS;
}

method set_default_event_by_index ( long *sts; int index )
{
  *sts = MSSUCC;

  switch( index )
  {
    case -1 :   me->event1.subtype        = GRst_DEFAULT; break;
    case 0  :   me->first_event.subtype   = GRst_DEFAULT; break;
    case 1  :   me->second_event.subtype  = GRst_DEFAULT; break;
    case 2  :   me->third_event.subtype   = GRst_DEFAULT; break;
    case 3  :   me->fourth_event.subtype  = GRst_DEFAULT; break;
    case 4  :   me->fifth_event.subtype   = GRst_DEFAULT; break;
    case 5  :   me->sixth_event.subtype   = GRst_DEFAULT; break;
    case 6  :   me->seventh_event.subtype = GRst_DEFAULT; break;
    default :  *sts = MSINARG;
  }
  return OM_S_SUCCESS;
}


method form_init ( int form_index )
{

  /*
   * form_index is an arg from the state transition file:
   *    1 = Generate Matrix of Points
   *    2 = Generate Polar Array of Points
   *    N>2 - for EMS override support; see comisc.h (srh 01/11/92)
   */
  extern void 
      GRMtrxDpt_init(),
      GRPolarDpt_init(),
      GRMtrxDpt_notification(),
      GRPolarDpt_notification();

  extern int
      FIf_set_notification_routine();


  switch ( form_index )
  {
    case GR_GenMtrxPts :
      FIf_set_notification_routine( me->status_display_form_ptr,
                                    GRMtrxDpt_notification );
      GRMtrxDpt_init( me->status_display_form_ptr );
      break;

    case GR_GenPolarPts :
      FIf_set_notification_routine( me->status_display_form_ptr,
                                    GRPolarDpt_notification );
      GRPolarDpt_init( me->status_display_form_ptr );
      break;
  }
  return OM_S_SUCCESS;
}

/* does nothing in GRNUC but has special purpose in MODEL */
#argsused
method show_assoc_mode ( int flag )
{
  return OM_S_SUCCESS;
}

/* does nothing in GRNUC but has special purpose in MODEL */
#argsused
method wakeup_form (long *sts; int suppress_flag )
{
  return OM_S_SUCCESS;
}

end implementation COnpt;
