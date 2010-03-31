/* ###################   APOGEE COMPILED   ################## */
/*
Name
        EFmake_comp_surf

Description
        This function creates an associative composite surface object.

History
        mrm     03/21/91    creation
                05/31/91    make sure the parents are all associative classes
        SM      05/15/92    Use local variables so as to preserve the 
                            informational message coming from the EMmake_comp
                            method, and let the command object behave 
                            appropriately. E.g EMS_I_Fail if stitching failed.
*/

class implementation EMSsfstitch;

#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"

#if DEBUG
#define ERRORs(sts,msg,error_message,label)      \
    if (EMSmsgReport(sts,error_message,FALSE) || \
        EMSmsgReport(msg,error_message,FALSE))   \
                goto label;
#else
#define ERRORs(sts,msg,error_message,label)   if (!(sts & msg & 1)) goto label;
#endif

extern OMuword OPP_EMSsfstitch_class_id, OPP_NDnodein_class_id;

IGRlong EFmake_comp_surf(msg, options, nsurfaces, surfaces, construct, compsurf)
IGRlong *msg;                       /* < return code */
IGRushort options;          /* > unused */
IGRint nsurfaces;                   /* > number of surfaces passed in */
OM_S_OBJID *surfaces;               /* > surfaces to make up the composite */
struct GRvg_construct *construct;   /* > construction information */
struct GRid *compsurf;              /* < resultant composite surface */
{
    OMuword os, classid;
    IGRint sts, i, j, locsts, locmsg;
    IGRdouble cht;
    struct GRmd_env *mod;
    struct EMSobject_info *parents = NULL;

    /* construct in the object space specified by the construction list */

    compsurf->osnum = os = construct->env_info->md_id.osnum;

    /* construct a stitch object */

    sts = om$construct(classid = OPP_EMSsfstitch_class_id,
                       osnum = compsurf->osnum,
                       p_objid = &compsurf->objid);

    ERRORs(sts, EMS_S_Success, "EFmake_comp_surf om$construct", wrapup);

    /* reformat the parent information for the init message */

    parents = (struct EMSobject_info *)
              alloca(sizeof(struct EMSobject_info) * nsurfaces);
    mod = construct->env_info;
    for (i = 0, j = 0; i < nsurfaces; i++)
    {
        /*
            make sure each parent object can participate in an
            associative relationship 
        */

        sts = om$get_classid(osnum = os,
                             objid = surfaces[i],
                             p_classid = &classid);
        if (!(sts & 1)) continue;   /* ignore unknown classes */

        sts = om$is_ancestry_valid(superclassid = OPP_NDnodein_class_id,
                                   subclassid = classid);

        if ((sts & 1) && (sts != OM_I_INVANCESTRY))
        {
            parents[j].grid.objid = surfaces[i];
        }
        else
        {
            sts = om$send(msg = message EMSsurface.EMtransform_to_associative
                               (msg, &parents[j].grid.objid),
                          senderid = NULL_OBJID,
                          targetid = surfaces[i],
                          targetos = os);

            if (!(sts & *msg & 1)) continue;    /* ignore this guy */
        }
        parents[j].env = *mod;
        parents[j++].grid.osnum = os;
    }

    if ((nsurfaces = j) == 0)  /* in case any objects were skipped */
    {
        sts = OM_E_ERROR;
        *msg = MSINARG;
        ERRORs(sts, *msg, "No valid parents (unknown classes)", wrapup);
        goto wrapup;
    }

    /* get the chord height tolerance to store in the object */

    BSEXTRACTPAR(msg, BSTOLCHRDHT, cht);

    /* initialize the associative composite surface object */

    {
      extern OM_S_OBJID current_creator;
      current_creator = compsurf->objid;
      sts = om$send(msg = message EMSassoc.EMinit_associative
                         (msg,                /* return code */
                          NULL,               /* options */
                          nsurfaces,          /* number of parents */
                          parents,            /* parent information */
                          EMS_ASno_type,      /*type not needed at this class*/
                          sizeof(IGRdouble),  /* size of info to store */
                          (IGRchar *)&cht,    /* store chord height tol */
                          construct),         /* construction parameters */
                    senderid = NULL_OBJID,
                    targetid = compsurf->objid,
                    targetos = compsurf->osnum);
      current_creator = NULL_OBJID;
      ERRORs(sts, *msg, "EFmake_comp_surf EMinit_associative", wrapup);
    }

   /* FROM THIS POINT ONWARDS IN THE CODE, DO NOT USE sts AND msg
      VARIABLES. UNLESS THERE IS AN ERROR PRESERVE THEM FOR THE COMMAND
      OBJECT.

      SM 05/15/92.
   */
    if (options & EMSasconst_notassociative)
    {
      locsts = om$send (msg = message NDnode.NDmove_to_root((IGRlong *)&locmsg,
                            compsurf, construct->env_info),
                     senderid = NULL_OBJID,
                     targetid = compsurf->objid,
                     targetos = compsurf->osnum);
     if (!(1 & locsts & locmsg)) {*msg = locmsg; goto wrapup;}
    }
wrapup:

    return(sts);
}

end implementation EMSsfstitch;
