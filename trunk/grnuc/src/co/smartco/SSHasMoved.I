/*

Name
  SSHasMoved.I

Description

Notes


 */
class implementation Root;

#include <math.h>
#include <memory.h>
#include <malloc.h>
#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMindex.h"
#include "igrtypedef.h"
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
#include "wl.h"
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
static int LastWindow = -1, LastX = -1, LastY = -1, active = 0;
%endsafe

/*

Name
  SSGetXCoordinate
  SSGetYCoordinate

Abstract
  These functions return the last X and Y coordinates saved by Smart Sketch

Synopsis
  int SSGetXCoordinate ()
  int SSGetYCoordinate ()

Description

Return Value

Notes
  KLUDGE: Should come as input from dynamics/Needs review

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.

 */

int SSGetXCoordinate ()
/*
 * KLUDGE: Should come as input from dynamics
 */
{
  return LastX;
}


int SSGetYCoordinate ()
/*
 * KLUDGE: Should come as input from dynamics
 */
{
  return LastY;
}


/*

Name
  SSHasMoved

Abstract
  Used for recording the cursor position and later detecting if the cursor 
  has moved.

Synopsis

  int SSHasMoved ( int action )

  int action   IN   SSON     - makes active and sets current cursor coords
                    SSCHECK  - for inquiring if the cursor moved or not
                    SSOFF    - deactivate 

Description
  Used to save the current cursor postion and to check later to see
  if the cursor has moved.  This is used to abort the Rtree search
  when it is in progress and the cursor is not still.


Return Value
  The ONLY time this routine returns TRUE (not 0) is when the action is
  SSCHECK and the cursor position HAS been moved since the last time it
  was recorded (i.e. with action == SSON).

Notes
  Perhaps these should be three seperate functions.  Pehaps later.

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henry G. Bequet  : prototype developed
  08/31/93 : Shelley R. Heard : added header/implemented for 2.4. Release.
 */

int SSHasMoved ( action )
int action;
{
  int NewWindow; 
  int NewX, NewY;
  int status;
  int flag;

  extern int WLmouse_win_position();


  status = 0; 

  switch (action)
  {
    case SSON: 
    {
      WLmouse_win_position( (WLuint32 *) &LastWindow, 
                        &LastX, 
                        &LastY, 
                        &flag );
      status = 0;
      active = 1;

      /*
       * Nothing is available
       */
      SSLastAvailable = FALSE;
      break;
    }
    case SSCHECK:
    {
      if (active)
      {
        WLmouse_win_position( (WLuint32 *) &NewWindow,
                              &NewX,
                              &NewY,
                              &flag );

        status = LastWindow != NewWindow || LastX != NewX || LastY != NewY;
      }
      else
      {
        status = 0;
      }

      break;
    }

    case SSOFF: 
    {
      active = 0;
      status = 0;
      break; 
    }
  }
  
  return status;
}

/*

Name
  SSCursorHasMoved

Abstract
  Equivalent to SSHasMoved(SSCHECK).

Synopsis
  int SSCursorHasMoved ()

Description
  We use this as the Rtree conditional (see call to DB_set_term_func())
  in SSFindObject() ).  We only want to thrash the Rtree when the cursor 
  has not moved since we started the Rtree pass.

Return Value
  TRUE  : if cursor HAS moved
  FALSE : if cursor has NOT moved

Notes

Index

Keywords
  smart-sketch,dynamics

History
  ??/??/92 : Henri Bequet     : prototype written
  08/05/93 : Shelley R. Heard : header added; implementation for 2.4 GRNUC.
  09/01/93 : Shelley R. Heard : Reversed logic (was SSCursorHasMoved()).

 */

int SSCursorHasMoved ()
{
  return SSHasMoved(SSCHECK);
}

end implementation Root;
