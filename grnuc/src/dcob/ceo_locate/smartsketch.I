class implementation CEO_LOCATE;

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

method SSactivate ()
{
  ss$activate ();

  return OM_S_SUCCESS;
}

method SSdeactivate ()
{
  ss$deactivate ();
  return OM_S_SUCCESS;
}

method SSenter()
{
  ss$enter ();
  return OM_S_SUCCESS;
}

method SSexit()
{
  ss$exit ();
  return OM_S_SUCCESS;
}

method SSOptions(int *sts )
{
  *sts = ss$options(); /* uses default origin */
  return OM_S_SUCCESS;
}


/*

Name
  SSSmartSketchLock

Abstract
  Sets the value of the DPB's smart sketch lock

Synopsis
  method SSSmartSketchLock (int *sts; int flag)

Description
  sts   OUT return code that can be switched on in COB state tables
              OM_E_ABORT  - if method did not do the requested task
              if flag was set to 3 (query) then *sts will retutn as:
                0 if lock is currently set OFF
                1 if lock is currently set ON
              NOTE! be careful when checking the value of *sts in
              query mode.  A 0 does not mean failure!

  flag  IN  0 - sets the lock to OFF
            1 - sets the lock to ON
            2 - toggles the lock
            3 - query lock value (result returned in *sts)

Return Value
  OM_S_SUCCESS always

Notes

Index

Keywords
 command,smart-sketch,lock,change

History
  08/18/93 : Shelley R. Heard : created to support the Toggle Smart Sketch
                                command (GRTgSmSk)

 */

method SSSmartSketchLock (int *sts; int flag )
{
  int old_lock_val;
  int new_lock_val;
  long status;

  switch ( flag )
  {
    case 0  : /* set OFF */
    {
      new_lock_val = 0; 
      status = gr$put_ss_lock( buffer = &new_lock_val );
    }
    break;

    case 1  : /* set ON  */
    {
      new_lock_val = 1; 
      status = gr$put_ss_lock( buffer = &new_lock_val );
      if (!(status & 1)) 
      { 
        *sts = OM_E_ABORT;
      }
    }
    break;

    case 2  : /* toggle lock value */
    {
      status = gr$get_ss_lock( buffer = &old_lock_val );
      if (!(status & 1)) 
      { 
        *sts = OM_E_ABORT; 
      }
      else
      {
        new_lock_val = !old_lock_val;

        status = gr$put_ss_lock( buffer = &new_lock_val );
        if (!(status & 1)) *sts = OM_E_ABORT;
      }
    }
    break;

    case 3  : /* query lock value  */
    {
      status = gr$get_ss_lock( buffer = &old_lock_val );
      *sts = ( (!(status & 1)) ? OM_E_ABORT : old_lock_val );
    }
    break;

    default : /* bad input value */
    {
      *sts = OM_E_ABORT;
    }
  }

  return OM_S_SUCCESS;
}

end implementation CEO_LOCATE;
