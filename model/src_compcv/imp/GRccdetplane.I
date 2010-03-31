class implementation GRcompcurve;

#include "EMScc.h"
#include "bs.h"
#include "msdef.h"
#include "maerr.h"
#include "OMmacros.h"
#include "bsunwght_p.h"
#include "bsptlnplan.h"
#include "bsortcvnorm.h"
#define  MAX_STATIC_POLES 250

/*

Name
  GRdetplane

Abstract
   This method determines the plane formed by a composite curve, if any.
  
Synopsis
   msg       completion code
      - MSSUCC if successful
      - MANOMEMORY if no dynamic memory available
      - MANONPLANAR if no unique plane possible
        - MSFAIL (severe) if failure
   plane    The plane, the plane

Description

Return Value

Notes

Index

Keywords
  composite,curve,normal,plane

History
  
   05/13/87 : rlw : creation date
   09/23/87 : rlw : Discontinued using MAdetplane() due to a bug.  I changed
                    to use BStst_plan().  This is probably better anyway since
                    we will be more consistent.
   10/28/87 : DLB : modified channel for version 1.1.0
   02/12/88 : rlw : Fixed a bug where I had when static buffer size was
                    exceeded.
   09/26/88 : rlw : Modified to call a different math routine to determine
                    planarity.  Colinear poles where not being properly
                    flagged as planar.
   03/22/93 : Carlos M. Diaz : Modified to check for closeness before calling
                    genabsg on the composite. This fixes TR119222872 for which
                    computation time had gone from 40 seconds to 20 minutes.

   Sudha   06/21/93        modified for BSprototype ansification

*/
method GRdetplane(
IGRlong  *msg; 
IGRshort  *matrix_type; 
IGRmatrix  matrix;
struct  IGRplane *plane)
{
  IGRchar    *generic_pointer;
  IGRboolean    status;
  IGRuint    object_count;
  IGRlong    sts, i, loc_msg, current_buffer_size;
  IGRint     planar_code;
  IGRlong    new_total_poles, total_poles;
  IGRpoint    *poles, static_poles[MAX_STATIC_POLES];
  struct      IGRbsp_curve *curve;
  OM_S_CHANSELECT  my_chanselect;

  /*
 * Initialize
 */

  *msg = MSSUCC;
  total_poles = 0;
  poles = &static_poles[0];
  current_buffer_size = MAX_STATIC_POLES;

  /*
 * Find out how many curves I own
 */

  my_chanselect.type = OM_e_addr;
  my_chanselect.u_sel.addr = &ME.GRcmpowner->to_components;
  sts = om$get_channel_count(object = me,
      p_chanselect = &my_chanselect,
      count = &object_count);
  if (! (1 & sts))
  {
    *msg = MSFAIL;
    return(OM_E_ABORT);
  }
  /*
 * For each curve get the geometry and merge it in with the rest
 */
  for (i = 0; i < object_count; i++)
  {
    /*
 * Get the abstract buffer of the curve
 */
    sts = om$send(msg = message GRcurve.GRgenabsg(
        msg,
        matrix_type,
        matrix,
        &generic_pointer),
        p_chanselect = &my_chanselect,
        from = i,
        to = i);
    if (! (1 & sts))
    {
      *msg = MSFAIL;
      goto wrapup;
    }
    curve = (struct  IGRbsp_curve *) generic_pointer;
    /*
 * Get enough memory
 */
    new_total_poles = curve->num_poles + total_poles;
    if (new_total_poles > current_buffer_size)
    {
      if (poles != &static_poles[0])
      {
        poles = (IGRpoint *) realloc(poles, sizeof(IGRpoint) * 
            new_total_poles);
        if (!poles)
        {
          *msg = MANOMEMORY;
          goto wrapup;
        }
      }
      else
      {
        poles = (IGRpoint *) malloc(sizeof(IGRpoint) * new_total_poles);
        if (!poles)
        {
          *msg = MANOMEMORY;
          goto wrapup;
        }
        OM_BLOCK_MOVE(
            static_poles,
            poles,
            sizeof(IGRpoint) * total_poles);
      }
      current_buffer_size = new_total_poles;
    }
    /*
 * Move the poles together
 */
    if (!curve->rational)
      OM_BLOCK_MOVE(
          curve->poles,
          &poles[total_poles][0],
          sizeof(IGRpoint) * curve->num_poles);
    else
      status = BSunwght_p(
          &loc_msg,
          curve->poles,
          curve->weights,
          &curve->num_poles,
          &poles[total_poles][0]);
    total_poles = new_total_poles;
  } /* for (i = 0; i < object_count; i++) */
  /*
  * Determine planarity
  */
  BSptlnplan(
      total_poles,
      FALSE,
      poles,
      NULL,
      &planar_code,  /* 1 point, 2 line, 3 plane, 4 non-planar */
  plane->normal,
      &loc_msg);
  if (loc_msg == BSSUCC)
  {
    if (planar_code == 4)
      *msg = MANONPLANAR;
    else
      if (planar_code == 3)
      {
        /*
          * check if it is closed, before calling genabsg
          */
        struct GRprops properties;
        sts = om$send(msg = message GRcurve.GRgeomprops(
            msg,
            matrix_type,
            matrix,
            &properties),
            targetid = my_id);
        if (! (1 & sts)) goto wrapup;

        if (properties.phy_closed)
        {
          struct IGRbsp_curve *cv1;

          *msg = MSSUCC;
          sts = om$send(msg = message GRcurve.GRgenabsg(
              msg,
              matrix_type,
              matrix,
              &generic_pointer),
              targetid = my_id);
          if (! (1 & sts)) goto wrapup;

          cv1 = (struct IGRbsp_curve *) generic_pointer;

          if (cv1->phy_closed)
          {
            IGRvector temp_normal;
            BSortcvnorm(cv1,temp_normal, &loc_msg);
            if (loc_msg == BSSUCC)
              OM_BLOCK_MOVE(temp_normal, plane->normal, sizeof(IGRvector));
          }
        }
      }
      else
        *msg = MASDGENRAT;

    OM_BLOCK_MOVE(
        poles,
        plane->point,
        sizeof(IGRpoint));
  }
  else 
    if (loc_msg == BSNOSTKMEMORY)
      *msg = MANOMEMORY;
    else
      *msg = MSFAIL;
  /*
 * Eof
 */
wrapup:
  if (poles && (poles != &static_poles[0])) free(poles);
  if ((*msg == MANONPLANAR) ||
      (*msg == MASDGENRAT) ||
      (1 & *msg))
    return(OM_S_SUCCESS);
  else
    return(OM_E_ABORT);
}

end implementation GRcompcurve;
