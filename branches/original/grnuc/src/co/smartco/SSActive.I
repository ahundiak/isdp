/*

Name
  SSActive.I

Description
  These functions support the turning activating/deactivating Smart Sketch
  as well as querying its status.

Notes
  First implemented for 2.4.0 release of GRNUC.  Based on prototype by
  Henri Bequet.  Further development by Shelley Heard in summer of 1993.

 */
class implementation Root;

#include <math.h>
#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igrdef.h"
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


%safe
static int active = 0;
%endsafe

/*
 * NOTE: Smart Sketch is only active if the DBP ss_lock is ON (1).
 */

/*

Name
  SSActivate

Abstract
  This function will activate the Smart Sketch dynamics system.

Synopsis
  void SSActivate ()

Description
  no arguments

Return Value
  none

Notes
  There are three things required to "activate" the Smart Sketch:
    1) Note that it is active with static memory flag
    2) Clear the new element type 
    3) Establish the Rtree terminate function so that the rtree will 
       be searched only when the cursor has not moved.

Index

Keywords
  smart-sketch,dynamics,active

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added.

 */

void SSActivate ()
/*
 * Activates the Smart Sketch
 */
{
  extern void DB_set_term_func();
  extern int SSCursorHasMoved ();
  extern int SSGetActiveConstraints();

  active = 1;

  /*
   * Anytime we enter the Smart Sketch we want the Rtree search to be 
   * canceled if the cursor is moving.  This is accomplished the setting
   * the "Rtree terminate function" to SSCursorHasMoved. 
   */
  DB_set_term_func(SSCursorHasMoved);

  SSNewElementType = SSNONE;
}


/*

Name
  SSDeactivate

Abstract
  This function deactivate the Smart Sketch dynamics system.

Synopsis
  void SSDeactivate ()

Description
  no arguments

Return Value
  none 

Notes
  There are three things required to "deactivate" the Smart Sketch:
    1) Note that it is no longer active with static memory flag
    2) Clear the new element type  (as in activate)
    3) Clear the Rtree terminate function so that the rtree will
       searched unconditionally when requested to do so.


Index

Keywords
  smart-sketch,dynamics,active

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added.

 */
void SSDeactivate ()
/*
 * Deactivate the smart sketcher. The last element type is reset (no 
 * new element is being created).
 */
{
  extern void DB_set_term_func();

  active = 0;
  /* reset Rtree check function to NULL */
  DB_set_term_func( NULL );

  SSNewElementType = SSNONE;
  SSLastAvailable = 0;
}


/*

Name
  SSIsActive

Abstract
  This function returns 0 if the Smart Sketch is not active and
  retruns 1 if it is.

Synopsis
  int SSIsActive ()

Description
  no arguments

Return Value
  0 - active
  1 - inactive

Notes
  For this routine to return an "active" status (1):
    1) the DPB's Smart Sketch lock flag must be set ON.
    2) The static flag 'active' must be set to 1.

Index

Keywords
  smart-sketch,dynamics,active

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added.

 */
int SSIsActive ()
/*
 * Check if the smart sketcher is active or not
 */
{
  int         sts = 1;
  int         on_flag;
  int         rc;

  sts = gr$get_ss_lock ( buffer = &on_flag );
  if ((sts&1) & on_flag & active)
  {
    rc = active;
  }
  else
  {
    rc = 0; 
  }
  return rc;
}

end implementation Root;
