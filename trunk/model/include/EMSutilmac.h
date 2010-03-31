/*
  DESCRIPTION

  This file contains utility macros for use within EMS. 
*/

#ifndef EMSutilmacros_include_
#define EMSutilmacros_include_

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "exdef.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"

/* *******************************************************************
Description

This macro can be used to toggle, turn on  or turn off the ability to
locate curves that bound the solid. 

Arguments

I: IGRlong *msg  completion code
   EMS_S_Success : If all goes well.
   EMS_E_InvalidArg: If any of the required arguments is not specified.
   EMS_E_Fail : If the exact cause of the failure could not be determined.

I :IGRint mode : If set to 2, then it toggles the current mode. This is the
                 default value of the mode.
                 If set to 0, then it sets the current mode to be non-locatable.
                 If set to 1, then it sets the current mode to be locatable.

*********************************************************************** */
 
#omdef ems$locate_solid_curve_boundary(
                 msg,
                 mode = 2,
                 element = "EMSedge");
EFset_locate_eligibility(msg, (mode), (element));

#endomdef       

/* *******************************************************************
Description

This macro can be used to toggle, turn on  or turn off the ability to
locate composite curves that bound the solid. 

Arguments

I: IGRlong *msg  completion code
   EMS_S_Success : If all goes well.
   EMS_E_InvalidArg: If any of the required arguments is not specified.
   EMS_E_Fail : If the exact cause of the failure could not be determined.

I :IGRint mode : If set to 2, then it toggles the current mode. This is the
                 default value of the mode.
                 If set to 0, then it sets the current mode to be non-locatable.
                 If set to 1, then it sets the current mode to be locatable.

*********************************************************************** */
 
#omdef ems$locate_solid_composite_boundary(
                 msg,
                 mode = 2,
                 element = "EMSloop");
EFset_locate_eligibility(msg, (mode), (element));
#endomdef       

#endif
