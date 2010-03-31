/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
/*
History
    06/22/89    DLB Made change to get the msgNumber based on the general type
                    if the DISJ_DUE_TO_RETRY bit is set.
    06/21/89    DLB The operation instance variable may have a bit set 
                    (DISJ_DUE_TO_RETRY).  This bit is set off before 
                    the type is processed.
    10-May-1988 SM  If the operation is save side and the object is not a
                    solid then return reverseOrientation flag as FALSE.
    14-Apr-1988 jBk Rewritten to accomodate new parameters and new
                    boolean operation types.  Meat of implementation
                    moved to function EFextractOperationInformation.
    03-Nov-1987 DLB Converted to version 1.1.0 class structure.
    13-May-1987 jBk Genesis.

Algorithm
    1) Decide to use either requested type (*request) or my type.

    2) Call EFextractOperationInformation.
*/

/* Boolean operation enumeration */
# ifndef emsbool_include
# include "emsbool.h"
# endif

/* message numbers for boolean types */
# ifndef EMS_I_include
# include "EMS_I.h"
# endif

extern OMuword OPP_EMSsolid_class_id;

method EMget_operation_type (
    IGRlong *EMmsg;
    enum EMSbooltype *request;
    enum EMSbooltype *exactOperation;
    enum EMSbooltype *generalOperation;
    IGRboolean *reverseOrientation;
    IGRboolean *emptySet;
    IGRboolean *disjointSurfaces;
    IGRboolean *firstOnly;
    IGRboolean *allButFirst;
    IGRboolean *lastOnly;
    IGRboolean *removedSolids;
    IGRlong *msgNumber
)
{
    extern EMSrc EFextractOperationInformation ();
    enum EMSbooltype operation, local_genop;
    EMSrc            omrc;
    IGRboolean       disj_due_to_retry;


    disj_due_to_retry = FALSE;

    if (request)
    {
        operation = *request;
    }
    else
    {
        operation = (enum EMSbooltype) me^^EMSsfboolean.operation;
        if (operation & DISJ_DUE_TO_RETRY)        /*Added by DLB.*/
        {
          disj_due_to_retry = TRUE;
          operation &= ~DISJ_DUE_TO_RETRY;

          /*Do following to force the return of the general operation type.*/
          if (!generalOperation) generalOperation = &local_genop; 
        }
    }

    if (exactOperation) *exactOperation = operation;

    /*Get the requested info...*/
    omrc = EFextractOperationInformation (
                    EMmsg, operation,
                    generalOperation, reverseOrientation,
                    emptySet, disjointSurfaces,
                    firstOnly, allButFirst,
                    lastOnly, removedSolids,
                    (disj_due_to_retry ? NULL : msgNumber));
    if (!(1 & omrc & *EMmsg)) goto wrapup;    

    if (disj_due_to_retry && msgNumber)
    {
      /*Get the proper message number.*/
      omrc = EFextractOperationInformation(EMmsg, *generalOperation, NULL, 
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, msgNumber);
      if (!(1 & omrc & *EMmsg)) goto wrapup;
    }

    if( (operation == EMSbool_saveside) && reverseOrientation)
    {
      /*Modified ancesry check to use function. - DLB*/
      if (!EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                             OPP_EMSsolid_class_id, FALSE))
      {
        *reverseOrientation = FALSE;
      }
    }

    wrapup:
      EMWRAPUP(*EMmsg, omrc, "EMSsfbool.EMget_operation_type")
      return omrc;
}
end implementation EMSsfboolean;
