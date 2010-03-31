/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

/*
HISTORY
10/06/89    SS  Added the post-processing call. Absorbed cross-section
		update into this post-processor.
05/30/89    DLB Added DAVES_CHANGE define in order to allow the all disjoint 
                elements to work.  If surfaces are involved the op type will
                be disjoint union.
                Since this appears to be working well I do not anticipate 
                removing the define but I will leave it just in case.
02/23/89    DLB Reset return codes after send across notification channel.
                The send would result in unknown msg error if any other
                listener was on the channel.  P.S. If you change the way I
                list my dates, I will break both of your legs...
19 Dec 1988 jBk Added code to take care of EMSbool_delDisjArea
                case.
                Added some minor debugging aids.
18-Nov-1988 RC  Added code to update the associated cross_section.
09-May-1988 jBk Removed much of point location logic for disjoint
                retries and substituted invocations of function
                EFsolidRelationship.
04-May-1988 jBk Fixed oversight:  previously did not return an
                indication of empty set if requested boolean
                produced an empty set when it had at least one
                operand which was an empty set.
14-Apr-1988 jBk Genesis.
*/

%safe
#include <math.h>
%endsafe


#define DAVES_CHANGE 1
# ifndef DEBUG
#   define DEBUG 0
# endif

# if DEBUG
#   include "EMScmacros.h"

extern int EFfprints ();

#include "EMS.h"

#   define EMSdbgMR(rc, string) EMSmsgReport ((rc), (string), TRUE)
#   define EMSdbgEPS(string)    EFfprints (NULL, string)
# else
#   define EMSdbgMR(rc, string)
#   define EMSdbgEPS(string)
# endif

/* EMS_I_DisjointElements EMS_I_EmptySet */
# ifndef EMS_I_include
# include "EMS_I.h"
# endif

/* EMSokay */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

/* EMS_S_INSOLID EMS_S_OUTSOLID EMS_S_ONSOLID EMS_S_UNKNOWN */
# ifndef EMSconstruct_include
# include "EMSconstruct.h"
# endif

/* EMSsfbool_opt_retryDisjoint EMSsfbool_opt_retryingDisjoint */
# ifndef emssfintdef_include
# include "emssfintdef.h"
# endif

#define FIRST 0

from EMSsolid import EMpoint_locate;
from EMSxsection import EMupdate;

method EMboolean (
    IGRlong *rc;
    IGRshort mattyp[1]; IGRmatrix matrix;
    GRobjid element;
    IGRint num_elements_in_set; GRobjid set[];
    struct GRvg_construct construct_list[1];
    enum EMSbooltype request;
    IGRushort options;
    IGRchar status_str[];
    GRobjid intgrp[], auxgrp[];
    GRobjid *display_ids[];
    IGRint *display_count
)
{
    EMSrc omrc, changedRequestSuccessRc = EMS_E_Fail;
    IGRboolean disjointSurfaces, attachNullSymbol, notify;
    IGRboolean requestChanged = FALSE;
    enum EMSbooltype generalOperation, inputRequest;

    notify = EMcheck_inhibit_postproc();

    inputRequest = request;

    omrc = om$send (
        msg = message EMSsfboolean.EMget_operation_type (
            /* IGRlong *EMmsg = */                      rc,
            /* enum EMSbooltype *request = */           &request,
            /* enum EMSbooltype *exactOperation = */    NULL,
            /* enum EMSbooltype *generalOperation = */  &generalOperation,
            /* IGRboolean *reverseOrientation = */      NULL,
            /* IGRboolean *emptySet = */                &attachNullSymbol,
            /* IGRboolean *disjointSurfaces = */        &disjointSurfaces,
            /* IGRboolean *firstOnly = */               NULL,
            /* IGRboolean *allButFirst = */             NULL,
            /* IGRboolean *lastOnly = */                NULL,
            /* IGRboolean *removedSolids = */           NULL,
            /* IGRlong *msgNumber = */                  NULL
        ),
        targetid = my_id
    );

    if (EMSerror (omrc))
    {
        if (*rc ISNT EMS_E_InvalidArg)
        {
            omrc = OM_E_ABORT;
            *rc = EMS_E_Fail;
        }
    }
    else if (request ISNT EMSbool_saveside)
        /* AND (EMSokay (omrc)) from EMget_operation_type */
    {
        /* check for empty sets */

        EMSrc EFemptySet ();
        IGRboolean emptySet, elementIsEmptySet, setIsEmptySet;
        OM_S_MESSAGE nullSetMsg;
        struct EMSsfboolean_EMget_operation_type_Msg    arglist;

/*
        nullSetMsg = message EMSsfboolean.EMget_operation_type (
            rc,
            NULL,
            NULL,
            NULL,
            NULL,
            &emptySet,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
        );
*/

        arglist.EMmsg = rc;
        arglist.request = NULL;
        arglist.exactOperation = NULL;
        arglist.generalOperation = NULL;
        arglist.reverseOrientation = NULL;
        arglist.emptySet = &emptySet;
        arglist.disjointSurfaces = NULL;
        arglist.firstOnly = NULL;
        arglist.allButFirst = NULL;
        arglist.lastOnly = NULL;
        arglist.removedSolids = NULL;
        arglist.msgNumber = NULL;
        om$make_message(classname = "EMSsfboolean",
                        methodname = "EMget_operation_type",
                        size = sizeof(arglist),
                        p_arglist = &arglist,
                        p_msg = &nullSetMsg);

        omrc = om$send (
            msg = &nullSetMsg,
            targetid = element
        );

        if (omrc IS OM_W_UNKNOWN_MSG)
        {
            omrc = OM_S_SUCCESS;
            emptySet = FALSE;
        }

        if (EMSokay (omrc) AND EMSokay (*rc))
        {
            elementIsEmptySet = emptySet;

            omrc = om$send (
                msg = &nullSetMsg,
                targetid = set[0]
            );

            if (omrc IS OM_W_UNKNOWN_MSG)
            {
                omrc = OM_S_SUCCESS;
                emptySet = FALSE;
            }
        }

        if (EMSokay (omrc) AND EMSokay (*rc))
        {
            setIsEmptySet = emptySet;

            if (elementIsEmptySet)
            {
                if (setIsEmptySet)
                {
                    switch (generalOperation)
                    {
                    case EMSbool_union:
                        request = EMSbool_nullNullU;
                        break;
                    case EMSbool_intersect:
                        request = EMSbool_nullNullI;
                        break;
                    case EMSbool_difference:
                        request = EMSbool_nullNullD;
                        /* no break; no default */
                    }
                }
                else /* set is not empty set */
                {
                    switch (generalOperation)
                    {
                    case EMSbool_union:
                        request = EMSbool_nullSolidU;
                        break;
                    case EMSbool_intersect:
                        request = EMSbool_nullSolidI;
                        break;
                    case EMSbool_difference:
                        request = EMSbool_nullSolidD;
                        /* no break; no default */
                    }
                } /* end set is not empty set */
            }
            else /* element is not empty set */
            {
                if (setIsEmptySet)
                {
                    switch (generalOperation)
                    {
                    case EMSbool_union:
                        request = EMSbool_solidNullU;
                        break;
                    case EMSbool_intersect:
                        request = EMSbool_solidNullI;
                        break;
                    case EMSbool_difference:
                        request = EMSbool_solidNullD;
                        /* no break; no default */
                    }
                } /* end set is empty set */
                /* else leave request be! */

            } /* end element is not empty set */
        } /* end both empty-set tests went all right */
        else /* at least one of the empty-set tests hurt */
        {
            omrc = OM_E_ABORT;
            *rc = EMS_E_Fail;
        }
    } /* end "got operation type okay and request is not saveside" */

    /* see if empty set checks changed request */
    requestChanged = request ISNT inputRequest;

    if (EMSokay (omrc) AND requestChanged)
    {
        omrc = om$send (
            msg = message EMSsfboolean.EMget_operation_type (
                /* *EMmsg = */              rc,
                /* *request = */            &request,
                /* *exactOperation = */     NULL,
                /* *generalOperation = */   &generalOperation,
                /* *reverseOrientation = */ NULL,
                /* *emptySet = */           &attachNullSymbol,
                /* *disjointSurfaces = */   &disjointSurfaces,
                /* *firstOnly = */          NULL,
                /* *allButFirst = */        NULL,
                /* *lastOnly = */           NULL,
                /* *removedSolids = */      NULL,
                /* *msgNumber = */          NULL
            ),
            targetid = my_id
        );

        if (EMSokay (omrc) AND EMSokay (*rc))
        {
            omrc = OM_S_SUCCESS;
            *rc = EMS_S_Success;

            if (attachNullSymbol)
            {
                changedRequestSuccessRc = EMS_I_EmptySet;
            }
            else
            {
                changedRequestSuccessRc = EMS_S_Success;
            }
        }
        else if (*rc ISNT EMS_E_InvalidArg)
        {
            omrc = OM_E_ABORT;
            *rc = EMS_E_Fail;
        }
    }

    if (EMSokay (omrc)) /* after perhaps second get_op_type */
    {
        if (disjointSurfaces)
        {
            omrc = om$send (
                msg = message EMSsfboolean.EMdisjointBoolean (
                    rc,
                    request,
                    options,
                    construct_list,
                    element,
                    num_elements_in_set,
                    set
                ),
                targetid = my_id
            );

            if (EMSerror (omrc) OR EMSerror (*rc))
            {
                omrc = OM_E_ABORT;
                *rc = EMS_E_Fail;
            }
            else 
            {
                omrc = OM_S_SUCCESS;

                if (options & EMSsfbool_opt_retryingDisjoint)
                {
                    if (attachNullSymbol)
                    {
                        *rc = EMS_I_EmptySet;
                    }
                    else
                    {
                        *rc = EMS_I_DisjointElements;
                    }
                }
                else if (requestChanged)
                {
                    *rc = changedRequestSuccessRc;
                }
                else
                {
                    *rc = EMS_S_Success;
                }
            }
        }
        else /* not disjointSurfaces -- do effective "elif" */
        if (request IS EMSbool_delDisjArea)
        {
            omrc = om$send (
                msg = message EMSsfboolean.EMdelDisjAreas (
                    rc,
                    construct_list,
                    NULL,
                    element
                ),
                targetid = my_id
            );

            if (EMSerror (omrc) OR EMSerror (*rc))
            {
                omrc = OM_E_ABORT;
                *rc = EMS_E_Fail;
            }
            else 
            {
                omrc = OM_S_SUCCESS;
                *rc = EMS_S_Success;
            }
        }
        else
        /* neither disjointSurfaces nor request IS EMSbool_delDisjArea */
        {
            omrc = om$send (
                msg = message EMSsfboolean.EMjoiningBoolean (
                    rc,
                    mattyp, matrix,
                    element,
                    num_elements_in_set, set,
                    construct_list,
                    request,
                    options,
                    status_str,
                    intgrp, auxgrp,
                    display_ids,
                    display_count
                ),
                targetid = my_id
            );

            EMSdbgMR (omrc, "EMboolean omrc from EMjoiningBoolean");
            EMSdbgMR (*rc, "EMboolean rc from EMjoiningBoolean");

            if (
                (EMSokay (omrc)) AND
                (*rc IS EMS_I_NoIntersection) AND
                (options & EMSsfbool_opt_retryDisjoint) AND
                request ISNT EMSbool_saveside
            )
            /* retry this boolean in a disjoint manner */
            {
                int elementInSet0 = FALSE, set0InElement = FALSE;
                int elementLocated = FALSE;
                int set0Located = FALSE;
                IGRulong locationOfElement;
                IGRushort solidRelationshipOptions = NULL;

                EMSdbgEPS ("retrying boolean in a disjoint manner\n");

                omrc = EFsolidRelationship (
                    rc,
                    my_id,
                    set[0], element,
                    OM_Gw_current_OS, OM_Gw_current_OS,
                    construct_list->env_info, construct_list->env_info,
                    solidRelationshipOptions,
                    &locationOfElement
                );

                if (EMSerror (omrc) OR EMSerror (*rc))
                {
                    omrc = OM_E_ABORT;
                    *rc = EMS_E_Fail;
                }
                else /* okay point location with set[0] */
                {
                    switch (locationOfElement)
                    {
                    case EMS_S_INSOLID:
                        elementLocated = TRUE;
                        elementInSet0 = TRUE;
                        break;
                    case EMS_S_OUTSOLID:
                        elementLocated = TRUE;
                        elementInSet0 = FALSE;
                        break;
                    case EMS_S_UNKNOWN:
                    case EMS_S_ONSOLID:
                        elementLocated = FALSE;
                        elementInSet0 = FALSE;

                        /* no break; no default: */
                    } /* end switch on locationOfElement */
                } /* end else okay point location with set[0] */

                if (EMSokay (omrc) AND NOT elementInSet0)
                /* find if set[0] is inside element */
                {
                    IGRulong locationOfSet0;

                    omrc = EFsolidRelationship (
                        rc,
                        my_id,
                        element, set[0],
                        OM_Gw_current_OS, OM_Gw_current_OS,
                        construct_list->env_info,
                        construct_list->env_info,
                        solidRelationshipOptions,
                        &locationOfSet0
                    );

                    if (EMSerror (omrc) OR EMSerror (*rc))
                    {
                        omrc = OM_E_ABORT;
                        *rc = EMS_E_Fail;
                    }
                    else /* okay point location with element */
                    {
                        switch (locationOfSet0)
                        {
                        case EMS_S_INSOLID:
                            set0Located = TRUE;
                            set0InElement = TRUE;
                            break;
                        case EMS_S_OUTSOLID:
                            set0Located = TRUE;
                            set0InElement = FALSE;
                            break;
                        case EMS_S_UNKNOWN:
                        case EMS_S_ONSOLID:
                            set0Located = FALSE;
                            set0InElement = FALSE;

                            /* no break; no default: */
                        } /* end switch on locationOfSet0 */
                    } /* end else okay point location with element */
                } /* end find if set0 is inside element */

                if (EMSokay (omrc))
                /* if locations did not have huge problems */
                {
                    int retryOperation = TRUE;

                    if (elementInSet0 AND NOT set0InElement)
                    /* element is encompassed by set[0] */
                    {
                        switch (generalOperation)
                        {
                        case EMSbool_union:
                            request = EMSbool_surroundU;
                            break;
                        case EMSbool_difference:
                            request = EMSbool_surroundD;
                            break;
                        case EMSbool_intersect:
                            request = EMSbool_surroundI;
                            /* no break; no default: */
                        }
                    }
                    else if (set0InElement) /* AND NOT elementInSet0 */
                    /* set[0] is inside element */
                    {
                        switch (generalOperation)
                        {
                        case EMSbool_union:
                            request = EMSbool_interiorU;
                            break;
                        case EMSbool_difference:
                            request = EMSbool_interiorD;
                            break;
                        case EMSbool_intersect:
                            request = EMSbool_interiorI;
                            /* no break; no default: */
                        }
                    }
                    else if (elementLocated AND set0Located AND
                        NOT (elementInSet0 OR set0InElement))
                    /* element and set[0] are disjoint */
                    {
                        switch (generalOperation)
                        {
                        case EMSbool_union:
                            request = EMSbool_disjointU;
                            break;
                        case EMSbool_difference:
                            request = EMSbool_disjointD;
                            break;
                        case EMSbool_intersect:
                            request = EMSbool_disjointI;
                            /* no break; no default: */
                        }
                    }

                    else
                    /* could not locate points relative to either item */
                    {
#                     if DAVES_CHANGE
                        /*Use default of disjoint union.*/
                        request = EMSbool_disjointU;
#                     else   
                        omrc = OM_S_SUCCESS;
                        *rc = EMS_I_NoIntersection;
                        retryOperation = FALSE;
#                     endif

                    }


                    if (retryOperation)
                    {
                        IGRushort recursiveOptions;

                        recursiveOptions = options | 
                            EMSsfbool_opt_retryingDisjoint;

                         if (notify)
                           {
                           EMrestore_postproc();
                           notify = FALSE;
                           }

                        omrc = om$send (
                            msg = message EMSsfboolean.EMboolean (
                                rc,
                                mattyp, matrix,
                                element,
                                num_elements_in_set, set,
                                construct_list,
                                request,
                                recursiveOptions,
                                status_str,
                                intgrp, auxgrp,
                                display_ids,
                                display_count
                            ),
                            targetid = my_id
                        );
                    } /* end if retry operation */
                } /* end if locations did not have huge problems */
            } /* end retry in a disjoint manner */
        } /* end else not disjoint */
    } /* end (EMSokay (omrc)) after empty set checks */

  /*
   * Perform the post-processing (update cross section, mass/area designator,
   * MSCs other listeners).
   */
 
  if (notify)
    {
    if (!EMSerror (*rc & omrc))
      {
      OMuint i, num_comps;
      IGRlong local_rc;
      OM_S_CHANSELECT chan_to_comps;

      EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);  

      num_comps = 0;
      om$get_channel_count (object = me, p_chanselect = &chan_to_comps,
       count = &num_comps);

      for (i=0; i<num_comps; i++)
        om$send (msg = message EMSsurface.EMpostgeomod (&local_rc,
         EMS_POST_SAVEDSTATE | (i == FIRST ? NULL : EMS_POST_NOCOMPONENTS), 
         construct_list->env_info, OPPmargs, NULL), from = i, to = i,
         p_chanselect = &chan_to_comps);
      }
    EMrestore_postproc();
    }

  return omrc;
}

end implementation EMSsfboolean;
