/*

Name
  COnptSM.I

Description
  Methods for COnpt based commands that interact with the Smart Sketch.
  Other Smart Sketch support is inherited from the CEO_LOCATE class.

Notes

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
#include "SSdef.h"
#include "SS.h"
#include "SSmacros.h"

#include <stdio.h>

from GRcurve import GRendpts;

/*
 * -------------------   SMART SKETCH ACTIONS -------------------
 */
/*

Name
  SSSetNewElement

Abstract
  Sets up smart sketch functionality for new elements being constructed.

Synopsis
  method SSSetNewElement (int *sts; int ele_type; int index )

Description
  sts       return code that can be switched on in COB state tables

  ele_type  type of element being constructed (see SSdef.h); currently
            only SSLINE, SSPOINT, and SSARC are supported.  For some
            commands (such as MODIFY ELEMENT), the ele_type is dependent 
            upon which element was located by the command.  In these case
            setting ele_type to SSINQUIRE will cause the method to inquire
            the element type of the object on the me->located_chansel.

  indes     index of event containing start point of line (for SSLINE mode
            only!)

Return Value

Notes

Index

Keywords

History
  07/20/93 : Shelley R. Heard : created

 */
method SSSetNewElement (int *sts; int ele_type ; int index )
{
  double          points[6];
  long            status = OM_S_SUCCESS;
  struct GRevent *pevent;

  switch (ele_type)
  {
    case SSLINE:
    case SSPOINT:
    {

      switch( index )
      {
        case 0:   pevent = &me->first_event;   break;
        case 1:   pevent = &me->second_event;  break;
        case 2:   pevent = &me->third_event;   break;
        case 3:   pevent = &me->fourth_event;  break;
        case 4:   pevent = &me->fifth_event;   break;
        case 5:   pevent = &me->sixth_event;   break;
        case 6:   pevent = &me->seventh_event; break;
        default:  *sts = MSINARG; goto quit;
      }

      points [0] = pevent->event.button.x;
      points [1] = pevent->event.button.y;
      points [2] = pevent->event.button.z;
      ss$set_new_element ( type = ele_type, points = points );
      break;
    }

    case SSARC:
    {
      points [0] = me->first_event.event.button.x;
      points [1] = me->first_event.event.button.y;
      points [2] = me->first_event.event.button.z;
      points [3] = me->second_event.event.button.x;
      points [4] = me->second_event.event.button.y;
      points [5] = me->second_event.event.button.z;
      ss$set_new_element ( type = ele_type, points = points );
      break;
    }

    case SSINQUIRE :
    {
      double first_point[3];
      double last_point[3];
      double event_point[3];
      double delta1;
      double delta2;

      /*
       * We make an assumption here that the command has located an
       * element and that it is of a type we can deal with.  We access
       * this element via the me->located_chansel.
       */

      /*
       * Get the element and check it's class id.  Set the key points and
       * ele type for SS accordingly.
       */

      status = om$send( msg = message GRcurve.GRendpts(
                          (IGRlong *)sts,
                          &me->ModuleInfo.md_env.matrix_type,
                          me->ModuleInfo.md_env.matrix,
                          first_point,
                          last_point ),
                        p_chanselect = &me->located_chansel );

      if (status&*sts&1)
      {
        event_point[0] = me->first_event.event.button.x;
        event_point[1] = me->first_event.event.button.y;
        event_point[2] = me->first_event.event.button.z;

        status = MA2ptdis(  sts,
                            event_point,
                            first_point,
                           &delta1 );

        status = MA2ptdis(  sts,
                            event_point,
                            last_point,
                           &delta2 );

        if (delta1 > delta2 )
        {
          memcpy( points, first_point, (3*sizeof(double)) );
        }
        else
        {
          memcpy( points, last_point, (3*sizeof( double)) );
        }
        ss$set_new_element ( type = SSLINE, points = points );
      }
      else
      {
        /* deactivate the new element mode */
        ss$set_new_element( );
      }
      break;
    }
    default:
    {
      /* deactivate the new element mode */
      ss$set_new_element( );
      break;
    }
  }

  *sts = (*sts&1) ? MSSUCC : MSFAIL;

quit:

  return OM_S_SUCCESS;
}

end implementation COnpt;
