/*

Name
  COmeas3.I

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

History
  Shelley Heard:  5/24/93 : In all calls to co$cvt_imp_to_alias(), 
                            left justification is enforced (set locally)

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
#ifdef ENABLE_MATH_H
%safe
#include <math.h>
%endsafe
#else
#include <math.h>
#endif
#include <ctype.h>
#include <stdio.h>
#include <errno.h>
#include "csdef.h"
#include "grcoordsys.h"
#include "csmacros.h"
#include "codynmeas.h"

#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xos.h>
#endif

extern    IGRboolean    COproj_pt_to_view_pl();
from GRdrawview  import GRget_drawview_scale;

/*

Name
  post_strip()

Abstract
  Truncates the input string at the first ascii character - leaving
  any blanks that preceed the first ascii character.  If no ascii
  characters are found, the string is unchanged.

Synopsis
  void post_strip(char *string;)

  string - NULL terminated charcater string that will be stripped of
           any ascii characters.

Description
  The string is modified only if ascii characters are found.  It will
  be truncated at the FIRST instance of an ascii character.

Notes
  It is REAL important that the string is NULL terminated

Index

Keywords
 string,truncate

History
  05/20/93 : Shelley R. Heard : created

 */

static void post_strip(string)
  char *string;
{
  char *pString = string;
  while ( ! (isalpha(*pString) && *pString) ) pString++;
  *pString = NULL;
}


static void post_to_vterm_buffer(string)
  char *string;
{
  int nbytes;
#ifdef X11
  int bnum = 0;
  extern Display *EXdisplay;
  Display *display;
#else
  char *scrap_type = "TEXT";
  extern int Put_scrap();
#endif

  nbytes = strlen(string);

#ifdef X11
  display = EXdisplay;
  XStoreBuffer(display, string, nbytes, bnum);
#else
  Put_scrap(scrap_type, string, nbytes);
#endif
}

  
/*
Name
  calc_complement_angle

Abstract
  calculates the complement angle to be displayed in the Measure Angle form.

Keywords
  measure,method,angle

History
  04/07/93 : Shelley R. Heard : added header

 */
method calc_complement_angle ( long *sts )
{
  IGRlong               status;
  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  me->form_fields[COMPLEMENT_ANGLE_IND] = fabs(PI -
                         me->form_fields[CURRENT_MEAS_IND]);
  me->display_field = me->display_field | GR_COMEAS_DISPLAY_BASE_CURRENT_DISTANCE;

  return OM_S_SUCCESS;
}


/*
Name
  display_point(int *sts; int Index)

Abstract
  if (Index == 0)
    displays the point stored in me->first_event
  if (Index == 1)
    displays the point stored in me->second_event
  else
    invalid argument

Synopsis
  int *sts    can be checked from state table
               MSSUCC : all is well
               MSINARG: index out of range
               other  : just check for *sts&1 for success or failure
              
  int Index   index of the graphic point (not an object) being displayed

Keywords
  measure,method,display

History
  04/07/93 : Shelley R. Heard : added header

 */
method display_point(int *sts; int Index)
{
  IGRlong status = OM_S_SUCCESS;
  struct GRid           display_grid;
  struct DPele_header   ele_header;
  struct IGRpointset    pnt;
  struct IGRdisplay     active_display;
  IGRdouble             points[3];
  IGRlong               NumberOfBytes;
  IGRlong               BytesReceived;
     

  *sts = MSSUCC;
  if (me->draw_mode ==  NO_DRAW)
       return(OM_S_SUCCESS);

  status = ex$get_cur_mod(id = &display_grid.objid,
                          osnum = &display_grid.osnum);
  switch(Index)
  {
    case 0: 
      points[0] = me->first_event.event.button.x;
      points[1] = me->first_event.event.button.y;
      points[2] = me->first_event.event.button.z;
      break;

    case 1:
      points[0] = me->second_event.event.button.x;
      points[1] = me->second_event.event.button.y;
      points[2] = me->second_event.event.button.z;
      break;

    default : 
      *sts = MSINARG;
      goto quit;
  }
     
  pnt.num_points = 1;
  pnt.points = points;
    
  NumberOfBytes = sizeof( struct IGRdisplay );

  gr$get_active_display( msg = sts,
                         sizbuf = &NumberOfBytes,
                         buffer = &active_display,
                         nret = &BytesReceived );
  active_display.weight = 2;

  dp$build_dis_buffer( buffer      = &ele_header,
                       type        =  IGRPS,
                       display_att = &active_display,
                       geometry    = (struct IGRpointset *) &pnt  );

  status = dp$display(msg = sts,
                      osnum = display_grid.osnum,
                      buffer = &ele_header);

quit:
  return OM_S_SUCCESS;
}

/*
Name
  display_line

Abstract
  
    displays a line between the points stored in me->first_event and 
    me->second_event.

Keywords
  measure,method,display

History
  04/07/93 : Shelley R. Heard : added header

 */
method display_line ( long *sts )
{
  IGRlong               status;
  struct GRevent       *EventArray[2];
  struct GRid           line_grid;
  struct GRid           display_grid;
  IGRlong               NumberOfBytes;
  IGRlong               BytesReceived;
  struct GRevent        first_event;
  struct GRevent        second_event;

  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  status = ex$get_cur_mod( id = &display_grid.objid,
                           osnum = &display_grid.osnum );
  switch( me->draw_mode)
  {
    case DRAW_LINE:
    {
/*
      struct IGRpolyline    line;
      IGRdouble             points[6];
      struct IGRdisplay     active_display;

      points[0] = me->first_event.event.button.x;
      points[1] = me->first_event.event.button.y;
      points[2] = me->first_event.event.button.z;
      points[3] = me->second_event.event.button.x;
      points[4] = me->second_event.event.button.y;
      points[5] = me->second_event.event.button.z;

      line.num_points = 2;
      line.points = points;

      NumberOfBytes = sizeof( struct IGRdisplay );

      gr$get_active_display( msg = sts,
                             sizbuf = &NumberOfBytes,
                             buffer = &active_display,
                             nret = &BytesReceived );

      dp$build_dis_buffer( buffer      = &ele_header,
                           type        =  IGRPY,
                           display_att = &active_display,
                           geometry    = (struct IGRpolyline *) &line  );

      status = dp$display(msg = sts,
                          osnum = display_grid.osnum,
                          buffer = &ele_header);
 */
      break;
    }

    case PLACE_LINE:
    {
      first_event = me->first_event;
      second_event = me->second_event;
      EventArray[0] = &first_event;
      EventArray[1] = &second_event;

      NumberOfBytes = sizeof( struct GRmd_env );
      gr$get_construct_env(msg = sts,
                           point = &second_event.event.button,
                           sizbuf = &NumberOfBytes,
                           buffer = &me->ConstructInfo,
                           nret = &BytesReceived );

      status = co$place_linear(msg= sts,
                               events = EventArray,
                               module = &me->ConstructInfo,
                               mode = GRbd,
                               newflag = FALSE,
                               symbology = NULL,
                               level = NULL,
                               attr = NULL,
                               name = NULL,
                               grid = &line_grid,
                               neighbor = OM_GS_NULL_NEIGHBOR,
                               cob_id = my_id,
                               cob_os = display_grid.osnum,
                               p_co_chansel = NULL,
                               co_index = NULL,
                               display_obj = &display_grid,
                               classname = "GR3dlineseg" );
      break;
    }

    case NO_DRAW:
    {
       break;
    }

    default:
    {
      break;
    }
  }

  return OM_S_SUCCESS;
}


/*
Name
  COdetail_model

Abstract
  <TBD>

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method COdetail_model ( long *sts )
{
  IGRpoint         point_to_proj1,point_to_proj2; 
  IGRdouble        delta[3],loc_delta[3];
  struct GRevent   *events[NUMBER_OF_EVENTS];
  IGRdouble        scale;
  struct  GRid     act_own_id;
  IGRlong          msg,long_rc;
  Form             fp;
  IGRlong          status = OM_S_SUCCESS;
  *sts = MSSUCC;
  


  set_up_event_array;

  point_to_proj1[0] = events[3]->event.button.x;
  point_to_proj1[1] = events[3]->event.button.y;
  point_to_proj1[2] = events[3]->event.button.z;

  point_to_proj2[0] = events[4]->event.button.x;
  point_to_proj2[1] = events[4]->event.button.y;
  point_to_proj2[2] = events[4]->event.button.z;


  if (FI_get_form_by_name("BAR_MENU", &fp) == FI_SUCCESS)
  {
    FIf_is_displayed(fp, &sts);
    if (sts)
    {
      /*
       * Then the BAR_MENU is displayed and that means that
       * we're in MODEL MODE
       */
      me->model_flag = TRUE;
    }
    else me->model_flag = FALSE;

    status = COmeasure_detail_fun(&msg,
                  delta,
                  &me->adv_flag,
                  &me->ref_att_flag,
                  &me->dat_pt_flag,
                  &me->ref_lock_flag,
                  &me->scale_fac,
                  events,
                  &me->mod_env);
    status = COmeasure_delta_2pts(&msg,
                                  loc_delta,
                                  point_to_proj1,
                                  point_to_proj2);
    if (me->adv_flag) 
    {
      status = gr$get_active_owner ( msg = &long_rc,
                                     mod_id = &me->mod_env.md_id,
                                     active_owner = &act_own_id);

      status = om$send(msg = message GRdrawview.GRget_drawview_scale(
                                          &msg,
                                          &me->mod_env,
                                           NULL,
                                          &scale),
                        targetid = act_own_id.objid,
                        targetos = act_own_id.osnum); 

       me->cur_fields[6] = delta[0];
       me->cur_fields[7] = delta[1];
       me->cur_fields[8] = delta[2];

       if(me->ref_att_flag ) 
       {
         me->cur_fields[3] = loc_delta[0]/me->scale_fac;
         me->cur_fields[4] = loc_delta[1]/me->scale_fac;
         me->cur_fields[5] = loc_delta[2]/me->scale_fac;
       }
       else 
       {
         me->scale_fac = scale;
         me->cur_fields[3] = loc_delta[0];
         me->cur_fields[4] = loc_delta[1];
         me->cur_fields[5] = loc_delta[2];
            
         me->cur_fields[6] = delta[0]*me->scale_fac;
         me->cur_fields[7] = delta[1]*me->scale_fac;
         me->cur_fields[8] = delta[2]*me->scale_fac;
       }

     } /* if act_flag */
     else 
     {
       /* no act_flag */
       me->cur_fields[6] = delta[0];
       me->cur_fields[7] = delta[1];
       me->cur_fields[8] = delta[2];

       if (me->ref_att_flag)
       {
         me->cur_fields[6] = delta[0];
         me->cur_fields[7] = delta[1];
         me->cur_fields[8] = delta[2];
         me->cur_fields[3] = loc_delta[0]/me->scale_fac;
         me->cur_fields[4] = loc_delta[1]/me->scale_fac;
         me->cur_fields[5] = loc_delta[2]/me->scale_fac;
       }
       else 
       {  
         COmeasure_act_proj_delta(&msg,delta,events);
         me->cur_fields[3] = delta[0];
         me->cur_fields[4] = delta[1];
         me->cur_fields[5] = delta[2];
       }
           
     } /* no act flag */
  } /* of BAr MENU SUCCESS */
  return OM_S_SUCCESS;
}
     

/*
Name
  
method display_a_value

Abstract
  
Synopsis

  int *sts    
     can be checked from state table; just check for *sts&1 for success 
     or failure
              
  double *Value
    value to be displayed in the ERROR (status) field; this value (as an
    ascii string) is also put in the yank buffer for pasting into other
    applications (like the calculator).

Keywords
  measure,method,display

History
  04/07/93 : Shelley R. Heard : added header

 */
method display_a_value(IGRlong   *sts;
                       IGRdouble *Value )
{
  IGRlong         status;
  struct GRid     ModuleGrid;
  IGRchar         string[56];
  IGRshort        NumberOfAliases = 3;
  IGRshort        field_size = sizeof(IGRchar) * 56;
  struct GRIOreadout_spec readout_spec;

  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  status = ex$get_cur_mod(id = &ModuleGrid.objid,
                          osnum = &ModuleGrid.osnum );

  /*
   * TR 119304151: in this situation, we force justification of output to be 
   * LEFT since it makes no sence to do anything else.  SRH 5/25/93
   */ 
  status = co$update_readout_spec(msg = sts,
                                  unit_type = me->Units,
                                  osnum = ModuleGrid.osnum,
                                  update_flag = FALSE,
                                  readout_spec = &readout_spec);
  readout_spec.justification = GRIO_LEFT_JUSTIFY;
                                  
  status = co$cvt_imp_to_alias(msg = sts,
                               unit_type = me->Units,
                               working_units = Value,
                               inverse_scale_flag = GRIO_NO_SCALE,
                               osnum = ModuleGrid.osnum,
                               field_size = &field_size,
                               readout_spec = &readout_spec,
                               num_alias = &NumberOfAliases,
                               cvt_list = string );
  /*
   *  if there was no error, put the formatted string
   *  into the status field and post it to the yank buffer.
   */
  if ( !COERROR( status ) && !COERROR( *sts ) )
  {
    extern void post_strip();

    ex$message ( in_buff = string, field = ERROR_FIELD );
    /*
     * Per TR # 119221219; we strip off the units alias text if it exists
     * before putting it in the scrap buffer.  This prevents the calculator
     * (or other applications) from having to interpret non-numeric characters.
     * SRH 5/19/93
     */
    post_strip( string );
    post_to_vterm_buffer( string );
  }
  else
  {
    ex$message( msgnumb = GR_E_ErrEnc,
                field   = ERROR_FIELD,
                justification = LEFT_JUS );
  }

  return OM_S_SUCCESS;
}


/*
Name
  clear_sum

Abstract
  clear accumulated sum of measurements 

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */

method clear_sum ( long *sts )
{
  me->form_fields[CUMULATIVE_MEAS_IND] = 0;
  return OM_S_SUCCESS;
}


/*
Name
  display_measurement

Abstract
  This method does nothing but send a display_a_value message to itself
  specifying me->form_fields[CURRENT_MEAS_IND] as the value to display.

Keywords
  measure,method

Notes
  This is a redundant method!

History
  04/07/93 : Shelley R. Heard : added header

 */
method display_measurement ( long *sts )
{
  IGRlong     status = OM_S_SUCCESS;
  long msg;
  *sts = MSSUCC;

  status = om$send(
            msg = message COmeasure.display_a_value(
                             &msg,
                             &me->form_fields[CURRENT_MEAS_IND]),
            targetid = my_id );
  return OM_S_SUCCESS;
} /* display_measurement */


/*
Name
 diplay_sum

Abstract
  This method does nothing but send a display_a_value message to itself
  specifying me->form_fields[CUMULATIVE_MEAS_IND] as the value to display.

Keywords
  measure,method

Notes
  This is a redundant method!

History
  04/07/93 : Shelley R. Heard : added header

 */
method display_sum ( long *sts )
{
    long msg, status;
    *sts = MSSUCC;
    status = OM_S_SUCCESS;

    status = om$send(msg = message COmeasure.display_a_value(&msg,
                              &me->form_fields[CUMULATIVE_MEAS_IND]),
                     targetid = my_id );
  return OM_S_SUCCESS;
} /* display_sum */



/*
Name
  cvt_pt_to_act_coord_sys

Abstract
  transforms a point in the event buffer into the coordinates of the
  active coordinate system.

Keywords
  measure,method

History
  04/07/93 : Shelley R. Heard : added header

 */
method cvt_pt_to_act_coord_sys ( long *sts )
{
  IGRlong         status;
  IGRpoint        point1;
  IGRpoint        point2;
  IGRint          num_pts = 1;


  *sts = MSSUCC;
  status = OM_S_SUCCESS;

  point1[0] = me->event1.event.button.x;
  point1[1] = me->event1.event.button.y;
  point1[2] = me->event1.event.button.z;

  status = COcvt_pts_to_lcl_coord(sts,
                                  num_pts,
                                  point1,
                                  point2);

  me->event1.event.button.x = point2[0];
  me->event1.event.button.y = point2[1];
  me->event1.event.button.z = point2[2];

  return OM_S_SUCCESS;
}


end implementation COmeasure;
