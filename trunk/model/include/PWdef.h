/*
  DESCRIPTION

  This file is the master header file, that can be included by the user
  so that all of Pathway typedefs, defined-constants, structures, etc.
  get defined and in the right order. This includes the definitions
  required to handle errors, including the Pathway supplied macros that
  deal with error codes.

  The definitions NOT included by this header files are --

  1) All Macro definitions other than those used for explictily handling
     completion or error codes. To use these macros, the user must
     include the file called PWmacros.h

  2) All Pathway function prototype definitions. To include the prototypes
     one must include the file, PWapi.h. 
*/

#ifndef _PWdef_include
#define _PWdef_include

#ifndef _PWminimum_include
#include "PWminimum.h
#endif

#ifndef _PWgmdata_include
#include "PWgmdata.h"
#endif

#ifndef _PWgmint_include
#include "PWgmint.h"
#endif

#ifndef _PWmodel_include
#include "PWmodel.h"
#endif

#ifndef _PWerror_include
#include "PWerror.h"
#endif

#ifndef _PWattrib_include
#include "PWattrib.h"
#endif

#ifndef _PWattribid_include
#include "PWattribid.h"
#endif

#endif
