#ifndef EMSptr_macros
#define EMSptr_macros

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

IGRlong EMreturn_indirection __((IGRlong *EMmsg, unsigned int options,
                                 struct GRid *component_GRid, 
                                 struct GRid *ptr_GRid, IGRboolean create)); 
#if defined(__cplusplus)
}
#endif

#undef __

/* *********************************************************************

  Description
   This macro will return an indirection object for an entity if one
   exists. This indirection entity returned is applicable only for
   components of surfaces/solids and EMSagrp entities. The class of the
   returned object is EMSpointer.

   If an indirection object does not exist, then one will be created 
   in the same object space as the component by default. 
   If the create option is set to FALSE, then no indirection
   object will be created.
 
  Arguments
   IGRlong *msg :  I/O : Completion code.
               EMS_S_Success : If all goes well
               EMS_E_InvalidArg: If there can never be an indirection object
                                 for the component being passed. In other 
                                 words if it does not make sense.
               EMS_I_Found     : This is applicable when there already
                                 exists an indirection object.

   struct GRid *component : I : Component object for which an indirection
                                object is being sought.
   struct GRid *pointer   : O : Indirection object.
   IGRint create          : I : If this field is set to FALSE, then an
                                indirection object will not be created
                                if one does not exist. The default option
                                is to create if one does not exist.

*********************************************************************** */
   
 
#omdef ems$return_indirection(
                 msg,
                 component,
                 pointer,
                 create = TRUE)
EMreturn_indirection(msg, NULL, component, pointer, create)
#endomdef       

#endif
