/* ###################   APOGEE COMPILED   ################## */
/*
Name
        EMSsfstitch.EMconstruct_associative

Description
        This method [re]computes a composite surface/solid.

History
        DLB     10/12/92    Check for parent not on comps channel and adjust.
        DLB     06/25/91    During recompute, disconnect the components before
                            recomputing.  Then reconnect afterwards (if not 
                            not already connected.
        mrm     03/22/91    creation
	Sudha   06/01/93    modified to handle BSprototype headers
*/

class implementation EMSsfstitch;

#include "bserr.h"
#include "bsparameters.h"

#include "OMmacros.h"   /* kludge */
#include "bsparameters.h"
#include "bschangepar.h"

#if DEBUG
#define ERRORs(sts,msg,error_message,label)      \
    if (EMSmsgReport(sts,error_message,FALSE) || \
        EMSmsgReport(msg,error_message,FALSE))   \
                goto label;
#else
#define ERRORs(sts,msg,error_message,label)   if (!(sts & msg & 1)) goto label;
#endif

from EMSsolid import EMorient_yourself;

method EMconstruct_associative(IGRlong *msg;
                               IGRushort options;
                               OM_S_OBJID old_objid;
                               IGRint nroots;
                               IGRchar *parent_info;
                               IGRint type;
                               IGRchar *recomp_info;
                               struct GRvg_construct *construct)
{
    IGRint i, recompute;
    IGRlong sts, lmsg;
    IGRdouble active_cht, *cht;
    OM_S_OBJID *objids = NULL, *new_objids = NULL;
    struct GRid my_stupid_GRid;


    /*
        Get the parent info into the format necessary for EMmake_comp;
        i.e. an array of objids.  It is not necessary to use the
        EMget_parent_info message to unwind this info, since this class
        of object has only "internal" parents; that is, they are
        directly connected to this class with no intervening ASsource
        objects.  Therefore, simply typecast the input pointer to a
        pointer to struct GRid and away we go!
    */

    objids = (OM_S_OBJID *) stackalloc(nroots * sizeof(OM_S_OBJID));
    for (i = 0; i < nroots; i++)
    {
        objids[i] = ((struct GRid *)parent_info)[i].objid;
    }

    /* if recomputing, set the correct parameters */

    recompute = options & EMSasconst_recompute;
    cht = (IGRdouble *)recomp_info;
    if (recompute)
    {
        IGRboolean got_bad_one=FALSE;
        
        /* save the current tolerance */
        BSEXTRACTPAR(&lmsg, BSTOLCHRDHT, active_cht);

        /* set the proper tolerance for this operation */
        BSchangepar(&lmsg, BSTOLCHRDHT, *cht);

        my_stupid_GRid.objid = my_id;
        my_stupid_GRid.osnum = OM_Gw_current_OS;

        /*Disconnect the components so EMmake_comp wont complain*/
        for(i=0; i<nroots; i++)
        {
          sts = om$send(msg = message GRconnector.GRdisconn(msg,
                              &my_stupid_GRid),
                        targetid = objids[i]);
          if (!(1 & sts & *msg))
          {
            if (sts == OM_W_NOTONCHAN)
            {
              /*Case where parent is not on comps chan which should never
               * occur but has (TR119220125).
               */
              objids[i] = NULL_OBJID;
              got_bad_one = TRUE;
            }
          }
        }

        if (got_bad_one)
        {
          IGRuint new_nroot=0;

          for(i=0; i<nroots; i++)
          {
            if (objids[i] != NULL_OBJID) new_nroot++;
          }
                          
          new_objids = (OM_S_OBJID *) 
                       alloca(new_nroot * sizeof(OM_S_OBJID));

          new_nroot = 0;
          for(i=0; i<nroots; i++)
          {
            if (objids[i] != NULL_OBJID)
            {
              new_objids[new_nroot] = objids[i];
              new_nroot++;
            }
          }

          objids = new_objids;
          nroots = new_nroot;
        }
    }


    /* compute the composite */

    sts = om$send(msg = message EMSsfstitch.EMmake_comp
                       (msg,                 /* return code */
                        nroots,              /* number of surfaces */
                        objids,              /* surface ids */
                        construct->env_info, /* module information */
                        NULL,                /* no save info */
                        NULL,                /* no in_pairs */
                        0,                   /* no in_num_pairs */
                        NULL,                /* no geometry */
                        NULL),               /* make comp options */
                  targetid = my_id);

    if (recompute)
    {
        IGRlong max_index;
        /* restore active tolerance */
        BSchangepar(&lmsg, BSTOLCHRDHT, active_cht);

        /*Reconnect any components not already connected*/
        
        max_index = OM_K_MAXINT;
        for(i=0; i<nroots; i++)
        {
          om$send(msg = message GRconnector.GRrigidconn(msg,
                        &my_stupid_GRid, &max_index),
                  targetid = objids[i]);
          *msg = EMS_S_Success;                        
        }
/*
 * If the entity is a solid stitch, let us make sure that the normals are
 * oriented correctly. TR 11925430
 */ 

        if (EFisAncestryValid(msg, my_id, OM_Gw_current_OS, 
                          OPP_EMSsolid_class_id, FALSE))
        {
          sts = om$send(msg = message EMSsolid.EMorient_yourself(msg, NULL,
                         construct->env_info),
                   targetid = my_id);
        }
 /* end pp 08/01/93 */
    }

    ERRORs(sts, *msg, "EMSslstitch$EMconstruct_associative", wrapup);

wrapup:
    stackfree(objids);
    return(sts);
}

end implementation EMSsfstitch;
