/*

Name
  SSCheckEvent.I

Description
  This file contains the GEevent retrieval mechanism used to get constaint
  information from Smart Sketch.

Notes


 */

class implementation Root;

#include <math.h>
#include <memory.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dp.h"
#include "dpmacros.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "EMdtmacros.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"
#include "SSmacros.h"
#include "bserr.h"

from GRgraphics import GRptproject;

/*

Name
  SSCheckEvent

Abstract
  This function returns modifies an event structure when Smart Sketch has found
  a constraint.  Otherwise, the event is not modified.

Synopsis
  int SSCheckEvent ( PEvent )
  struct GRevent *PEvent (IN/OUT) The event we want to check and possibly
				  overwrite with Smart Sketch data if in fact
				  a constraint was found by Smart Sketch.

Description
  This routine was designed specifically for co$getevent (and possibly other
  input filters) to call AFTER getting a data point from the user.  It examines 
  the event entered by the user and if it is a data point (EX_DATA), then it
  looks to see if Smart Sketch had found a constraint.  If so, it overwrites
  the event with info gatherd by Smart Sketch.  Else, it leaves the event
  alone.  This mimics the behaviour of the event generator commands (which 
  Smart Sketch is designed to replace.

Return Value

Notes

Index

Keywords
  smart-sketch,dynamics,event,constraints

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added.

 */
int SSCheckEvent ( PEvent )
struct GRevent *PEvent;
/*
 * This routine checks if the passed event is the same we locked onto
 * time. If yes then we modify the value of the data point (to the
 * locked/constrained) position and we fill out the sub-event to simulate
 * the old event generator information for compatability.
 */
{
  if ( SSLastAvailable && ss$is_active () )
  {
    long             msg;
    long             sts;
    struct GRmd_env  module_env;

    /* 
     * "smart" events are the same size as event generator events since they
     * are likely to contain locate info; remember, the event.nbytes field 
     * is the size of the GRevent MINUS the size of the response and nbytes
     * fields.  This may seem weird but it is the way the the software event 
     * queue software was designed.
     */
    PEvent->nbytes = sizeof(struct GRevent) - (2 * sizeof(IGRlong));

    if (PEvent->response & EX_DATA)
    {
      gr$get_module_env( buffer = &module_env );

      /*
       * We override the coords to those of the constraint point
       */
      PEvent->event.button.x = SSLastConstraintPoint [0];
      PEvent->event.button.y = SSLastConstraintPoint [1];
      PEvent->event.button.z = SSLastConstraintPoint [2];
      if (SSLastObject1 && SSLastObject1->grid.objid != NULL_OBJID )
      { 
        sts = om$send (
                  msg = message GRgraphics.GRptproject( 
			   &msg,
                           &module_env.md_env.matrix_type,
                            module_env.md_env.matrix,
                            SSLastConstraintPoint,
                            PEvent->located_object[0].proj_pnt, 
                           &PEvent->located_object[0].geom_parms ),
                  targetid = SSLastObject1->grid.objid,
                  targetos = SSLastObject1->grid.osnum,
                  senderid = NULL_OBJID );

        PEvent->num_id  = 1;
        PEvent->num_val = 0;
        PEvent->located_object[0].located_obj = SSLastObject1->grid;
        PEvent->located_object[0].module_info = module_env;
      }

   
      switch (SSLastConstraintType)
      {
        default:
        {
          PEvent->nbytes = sizeof(struct EX_button);
          PEvent->subtype = GRst_REGULAR;
          PEvent->num_id  = 0;
          PEvent->num_val = 0;
	  break;
        }

        case SSONELEMENT:
        {
          PEvent->subtype = GRst_PROJECT;
          break;
        }
        case SSCENTER:
        {
          PEvent->subtype = GRst_CENTER;
          break;
        }
        case SSINTERSECT:
        {
          PEvent->subtype = GRst_INTER;
  
          if (SSLastObject2)
          {
            sts = om$send (
                    msg = message GRgraphics.GRptproject( 
			     &msg,
                             &module_env.md_env.matrix_type,
                              module_env.md_env.matrix,
                              SSLastConstraintPoint,
                              PEvent->located_object[1].proj_pnt, 
                             &PEvent->located_object[1].geom_parms),
                    targetid = SSLastObject2->grid.objid,
                    targetos = SSLastObject2->grid.osnum,
                    senderid = NULL_OBJID );
                      
            PEvent->num_id = 2;
            PEvent->num_val = 0;
            PEvent->located_object[1].located_obj = SSLastObject2->grid;
            PEvent->located_object[1].module_info = module_env;
          }
          break;
        }
        case SSFIRSTPOINT:
        {
          PEvent->subtype = GRst_ENDPOINT;
          break;
        }
        case SSLASTPOINT:
        {
          PEvent->subtype = GRst_ENDPOINT;
          break;
        }
        case SSKEYPOINT:
        {
          PEvent->subtype = GRst_KEYPOINT;
          break;
        }
        case SSMIDPOINT:
        {
          PEvent->subtype = GRst_MIDPOINT;
          break;
        }
        /* 
	 * can't support these with the current system so we generate
	 * regular data points (i.e. with no inbtelligence 
	 */
        case SSPERPENDICULAR:
        case SSXINTERSECT:
        case SSHORIZONTAL:
        case SSVERTICAL:
        case SSPARALLEL:
        case SSONXELEMENT:
        case SSHVERTICAL:
        case SSVHORIZONTAL:
        case SSONHORIZONTAL:
        case SSONVERTICAL:
        case SSONXHORIZONTAL:
        case SSONXVERTICAL:
        case SSTANGENT:
        case SSXTANGENT:
        {
          PEvent->nbytes = sizeof(struct EX_button);
          PEvent->subtype = GRst_REGULAR;
          PEvent->num_id  = 0;
          PEvent->num_val = 0;
	  break;
        }
      }

      SSLastAvailable = FALSE;
      SSNewElementType = SSNONE;
    }
  }

  return OM_S_SUCCESS;
}

end implementation Root;
