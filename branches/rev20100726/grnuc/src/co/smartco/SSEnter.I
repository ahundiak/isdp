/*

Name
  SSEnter.I

Description

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
#include "dpezmac.h"
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
#include "msmacros.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"
#include "bserr.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "dimdef.h"
#include "dimmacros.h"
#include "grmsg.h"

/* prototypes */
#include "mainvmx.h"


%safe
static int SSVeryFirstTime = 1;
%endsafe


/*

Name
  SSEnter

Abstract
 Initialize the Smart Sketch. This routine should be called in the wakeup of
 a command that wants to use the smart sketcher. It will grab the current
 reference plane and resets the number of objects the mouse is working with.

Synopsis
 int SSEnter()

Description

Return Value
  OM_S_SUCCESS  always

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

int SSEnter ()
{
  long            sts;
  struct GRid     plane;
  int             i, Mode;
  static IGRpoint normal, point;

  /*
   * We start with no objects in the list
   */
  SSLastAvailable = 0;
  SSnb_objects = 0;
  
  /*
   * We don't know what window we are talking about
   */
  SSLastWindow.objid = 0;
  SSLastWindow.osnum = 0;
  
  /*
   * Check if the reference plane lock is ON _AND_ there exists an active
   * reference plane.  If so then we get the transformation matrix to 
   * compute some of the constraints with respect to the reference plane 
   * (horizontal, vertical, ...)
   */
  Mode = 0;
  ems$ref_plane_lock ( msg = &sts, 
		       options = EMS_REF_PLANE_LOCK_INQ,
                       mode = &Mode );
  SSRefLock = Mode & EMS_REF_PLANE_LOCK_ON;
  SSRefPlane.normal = normal;
  SSRefPlane.point = point;

  if (SSRefLock)
  {
    plane.objid = NULL_OBJID;
    ems$get_active_datum_plane ( msg = &sts, datpln = &plane );
    if (plane.objid != NULL_OBJID)
    {
      short Four = 4;
      sts = ems$get_pln_info( options = 0,
                              p_xdir = SSRefXaxis,
                              p_ydir = SSRefYaxis,
                              p_zdir = SSRefPlane.normal,
                              p_origin = SSRefPlane.point );
      /*
       *  This is where the SSRefMatrix and SSInvRefMatrix globals get set
       */
      SKgetmat ( &sts, 
		  SSRefPlane.point, 
		  SSRefPlane.normal, 
		  SSRefXaxis,
                 &SSRefMatTyp, 
		  SSRefMatrix );

      MAinvmx ( &sts, &Four, SSRefMatrix, SSInvRefMatrix );
    }
  }

  if (SSVeryFirstTime)
  {

    SSVeryFirstTime = FALSE;

    /*
     * Initialize some stuff for displaying dynamic text
     * SRH In stead of performing all the ex$message calls at once 
     * (which makes the cursor hesitate on c4's) we initialize them
     * to the NULL string.  Then, when displaying the text, we'll 
     * check to see if it's a NULL string and fill it in on first 
     * reference.
     */

    SStext[SSONELEMENT    ].string[0] = NULL;
    SStext[SSCENTER       ].string[0] = NULL;
    SStext[SSINTERSECT    ].string[0] = NULL;
    SStext[SSFIRSTPOINT   ].string[0] = NULL;
    SStext[SSLASTPOINT    ].string[0] = NULL;
    SStext[SSKEYPOINT     ].string[0] = NULL;
    SStext[SSHORIZONTAL   ].string[0] = NULL;
    SStext[SSVERTICAL     ].string[0] = NULL;
    SStext[SSPARALLEL     ].string[0] = NULL;
    SStext[SSPERPENDICULAR].string[0] = NULL;
    SStext[SSMIDPOINT     ].string[0] = NULL;
    SStext[SSTANGENT      ].string[0] = NULL;
    SStext[SSONXELEMENT   ].string[0] = NULL;
    SStext[SSXINTERSECT   ].string[0] = NULL;
    SStext[SSXTANGENT     ].string[0] = NULL;
    SStext[SSONHORIZONTAL ].string[0] = NULL;
    SStext[SSONVERTICAL   ].string[0] = NULL;
    SStext[SSONXHORIZONTAL].string[0] = NULL;
    SStext[SSONXVERTICAL  ].string[0] = NULL;
    SStext[SSCARDINAL90   ].string[0] = NULL;
    SStext[SSCARDINAL180  ].string[0] = NULL;
    SStext[SSCARDINAL270  ].string[0] = NULL;
    for (i = SSONELEMENT; i < SS_MAX_CONSTRAINT_TYPES; i++)
     SStext [i].offset [0] = SStext [i].offset [1] = 10;
    
    SSBoreLine.point1 = SSFirstBoreLinePoint;
    SSBoreLine.point2 = SSSecondBoreLinePoint;
  } 


  return OM_S_SUCCESS;
}

end implementation Root;
