/*
  DESCRIPTION

    This file contains C macros developed for the associative system in
    EMS.
*/

#ifndef EMSasmacros_include_
#define EMSasmacros_include_

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


IGRlong EMgetevent __((IGRlong *ReturnMsg, IGRlong ScaleFlag, 
                       IGRlong EventMask, IGRlong EventSize, IGRchar *Prompt,
                       IGRlong MsgNumber, IGRchar *MsgName, IGRchar *ValueType,
                       IGRlong Mode, IGRint *nbytes, IGRlong *response, 
                       IGRchar *response_data, struct GRevent *Event));  

#if defined(__cplusplus)
}
#endif

#undef __

/*
 * The following is a getevent written on top og co$getevent. The only
 * difference here is that when a value is requested, an expression may
 * also be keyed in (name or name=relation). The value is returned
 * just as before, except that an object id of the expression is also
 * returned in the event->located_object[0].located_obj field. If no
 * expression was keyed in for this value the objid will be NULL_OBJID.
 * See griomacros.h for full description of the arguments.
 */

#omdef ems$getevent (msg,
                     scale_flag = GRIO_X_SCALE,
                     event_mask,
                     event_size=sizeof(struct GRevent),
                     prompt = NULL,
                     msgnum = GRIO_NO_MSG,
                     msgname = NULL,
                     value_type=NULL,
                     mode = EX_LINE_MODE,
                     nbytes=NULL,
                     response,
                     response_data,
                     event)
 
        EMgetevent ((msg),
                    (scale_flag),
                    (event_mask),
                    (event_size),
                    (prompt ),
                    (msgnum),
                    (msgname),
                    (value_type),
                    (mode),
                    (nbytes),
                    (response),
                    (response_data),
                    (event))
#endomdef

/* *******************************************************************
Description

 This macro can be used as the vehicle to create an associative
 wireframe/surface/solid element. The created element will recompute
 when one of its parents changes by calling the user defined function.
 This user defined function is written in C and can either be
 dynamically loaded or linked with the image.

Arguments

I: IGRlong *msg  completion code
   EMS_S_Success : If all goes well.
   EMS_E_InvalidArg: If any of the required arguments is not specified.
   EMS_E_Fail : If the exact cause of the failure could not be determined.

I: int associative Whether the created element is associative
I: IGRint num_parents Number of parents that the created element has
I: struct EMSobject_info *parents GRid and the environment of each
                   parent
I: IGRint info_size : Size of additional recomputation information that
                   needs to be stored in the created element
I: IGRchar *info : The recomputation information that needs to be stored.
                   It is strongly recommended that the above two fields be
                   not used since they pose a portability problem across
                   machines. 
         
                   In other words the user needs to interpret the 
                   character information taking byte swapping into 
                   account.
I: IGRchar *function_name: The name of the recomputation function that
                    is to be called when any of the parents gets modified.
                    This is the workhorse for the creation of modeling element.
                    This function will be called during initial creation of
                    the associative element and whenever any of the parents
                    gets modified.
I: struct GRvg_construct *construct_list : construction information
I: IGRchar *class_name : Class name of the entity that needs to be
                    constructed. If not specified an object of
                    class EMSassoc will be constructed. The caller needs
                    to pay careful attention to the class name that he
                    specifies. Eg: He should not try to post the geometry
                    of a line segment into an object of class EMSsolid etc.
O: OM_S_OBJID *created_id : Objid of the created element.

*********************************************************************** */
 
#omdef ems$associative_element_by_function(
                 msg,
                 associative = TRUE,
                 num_parents,
                 parents,
                 info_size = 0,
                 info = NULL,
                 function_name,
                 construct_list,
                 class_name = NULL,
                 created_id)

EFplace_associative_entity(msg,NULL,associative,num_parents, parents, 
                           info_size, info,
                           function_name, construct_list, class_name,
                           created_id)
#endomdef       

#endif
