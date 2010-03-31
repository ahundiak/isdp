/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

#include "EMS.h"
/*
NAME

EFsolidRelationship -- determine the relationship between two solids

DESCRIPTION

Given two solids, solid1 and solid2, the surfaces of which do not
intersect, and solid2, try to determine whether solid2 is inside
(EMS_S_INSOLID) solid1, outside (EMS_S_OUTSOLID) solid1, or in an
unknown relationship with solid1.

ARGUMENTS

rc:  pointer to return code, one of the following

    EMS_S_Success       success;

    EMS_I_InvalidArg    object did not understand EMpoint_locate
                        message and probably was not a solid;
                        EMpoint_locate revealed a point on solid2
                        was on solid1, so solid1 and solid2 must
                        intersect;

    EMS_E_Fail          some kind of problem.

selfObjid:  id of invoking object.  Can be NULL_OBJID.

solidId1, solidId2:  the objids of the solids.

solidOs1, solidOs2:  the osnums of the solids.

envinfo1, envinfo2:  pointers to information about the modules of
the solids.

options:  currently unused.  Use 0 mask.

location:  one of the following

    EMS_S_INSOLID   solid2 is inside solid1;

    EMS_S_OUTSOLID  solid2 is outside solid1;

    EMS_S_UNKNOWN   relationship between solid1 and solid2 is
                    unknown; also returned in case of the rc
                    pointing to EMS_I_InvalidArg when
                    EMpoint_locate message is not understood;

    EMS_S_ONSOLID   when rc is EMS_I_InvalidArg because solids
                    appear to intersect.

RETURNED VALUES

OM_S_SUCCESS if all was predicatable.

OM_E_ABORT if there was a goof.

HISTORY

09-May-1988 jBk Genesis.
*/

/* EMSokay */
# ifndef EMSlogic_include
# include "EMSlogic.h"
# endif

/* EMS_S_INSOLID EMS_S_OUTSOLID EMS_S_ONSOLID EMS_S_UNKNOWN */
# ifndef EMSconstruct_include
# include "EMSconstruct.h"
# endif

from EMSsolid import EMpoint_locate;

EMSrc EFsolidRelationship (
    rc,
    selfObjid,
    solidId1, solidId2,
    solidOs1, solidOs2,
    envinfo1, envinfo2,
    options,
    location
)
    EMSrc *rc;
    OM_S_OBJID selfObjid, solidId1, solidId2;
    OMuword solidOs1, solidOs2;
    struct GRmd_env *envinfo1, *envinfo2;
    IGRushort options;
    IGRulong *location;
{
    EMSrc omrc;
    IGRpoint pointOn2;
    IGRuint attempt_no=0;
    IGRuint found=0;

/*
 * Made modifications to ensure that we do a thorough check for
 * coincident situations.
 * TR 119300220
 * end pp 12/27/93
 */


    while (!found)
    {
     found = 1;
     
     omrc = om$send (
        msg = message EMSsurface.EMget_point_on_surface (
            (IGRlong *)rc,      /* EMmsg */
            envinfo2,           /* md_env */
            attempt_no, /* attempt_no */
            (IGRint)1,          /* number_of_points */
            pointOn2,           /* points */
            NULL                /* params */
        ),
        targetid = solidId2,
        targetos = solidOs2,
        senderid = selfObjid
    );

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        IGRushort solidPtLocOptions = NULL;

        omrc = om$send (
            msg = message EMSsolid.EMpoint_locate (
                (IGRlong *)rc,      /* EMmsg */
                envinfo1,           /* env */
                solidPtLocOptions,  /* options */
                pointOn2,           /* inpoint */
                NULL,               /* range */
                location            /* location */
            ),            
            targetid = solidId1,
            targetos = solidOs1,
            senderid = selfObjid
        );
    }

    if (EMSokay (omrc) AND EMSokay (*rc))
    {
        omrc = OM_S_SUCCESS;

        if (*location IS EMS_S_ONSOLID)
        {
            if (attempt_no < 10)
            {
             ++attempt_no;
             found = 0;
            }
            else
             *rc = EMS_I_InvalidArg;

            
            
        }
        else
        {
            *rc = EMS_S_Success;
        }
    }
    else
    {
        if (omrc IS OM_W_UNKNOWN_MSG)
        {
            omrc = OM_S_SUCCESS;
            *rc = EMS_I_InvalidArg;
            *location = EMS_S_UNKNOWN;
        }
        else
        {
            omrc = OM_E_ABORT;
            *rc = EMS_E_Fail;
        }
    }
   }

    return omrc;
}

end implementation EMSsfboolean;
