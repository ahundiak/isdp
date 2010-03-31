/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

# include "emssfdef.h"
# include "msdef.h"
# include "gocmacros.h"

extern OMuword OPP_EMSgenbs_class_id;

method EMmodifiedClass(IGRlong *EMmsg; IGRint modif; GRobjid *newobjid)
/*
Abstract

    This method changes the class of the surface such that the
    specified type of modification can be performed.

Arguments

    modif - input
        Modification type. One of the following:
                                EMSuniformTransformation
                                EMSnonuniformTransformation
                                EMSdistortion

    newobjid - the object id of the new object.

Notes

    This message is not actually doing anything yet.

History

    10 Mar 88   AIC     Creation Date.
*/
{
  IGRlong   sts = OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;
  *newobjid = my_id;

  switch(modif)
  {
    case EMSuniformTransformation:
    case EMSscale_of_1:
      /*
       * Class change is not neccessary
       */
      break;

    case EMSnonuniformTransformation:
    case EMSdistortion:
      /*
       * Change class to EMSgenbs
       */
      if(! EFisAncestryValid(EMmsg, my_id, OM_Gw_current_OS,
                             OPP_EMSgenbs_class_id, FALSE))
      {
        int i;
        struct GRmd_env md_env;
        struct GRpost_info  post_info;
        char            *geom;

        MAidmx(&sts, md_env.md_env.matrix);
        md_env.md_env.matrix_type = MAIDMX;
        md_env.md_id.objid = NULL_OBJID;
        md_env.md_id.osnum = OM_Gw_current_OS;

        post_info.construct_flag = FALSE;

        GRgetabsg(&sts, &md_env.md_env.matrix_type, md_env.md_env.matrix,
                  &geom, i);
        if(! (1 & sts)) goto wrapup;

        sts = om$change_class(objid = my_id, classname = "EMSgenbs",
                             sd_override = OM_K_change_class_sd_override);
        if(! (1 & sts)) goto wrapup;

        sts = om$send(msg = message GRvg.GRpostabsg(EMmsg, &md_env, &post_info,
                        geom, newobjid),
                      targetid = my_id);
      }
      break;

    default:
      *EMmsg = EMS_E_InvalidCase;
      goto wrapup;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSsubbs.EMmodifiedClass")
  return(sts);
}

end implementation EMSsubbs;
