/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

method EMputGeom(
 IGRlong             *EMmsg; 
 struct GRmd_env     *md_env;
 struct GRpost_info  *info; 
 IGRchar             *absptr; 
 GRobjid             *newobjid;
 IGRboolean          validate_class)

/*
Abstract: 
        This method posts the internal geometric representation for 
        an objects instance data. The input to this routine includes 
        a transformation matrix that may be applied to the object
        before posting. Optionally, this method will validate the
        geometry for this class.

Arguments
     *md_info    struct GRmd_env     structure defining the transfor-
                                      mation and other information
                                      necessary for interfacing with
                                      the module.
     *post_info  struct GRpost_info  processing control information
     *absptr     IGRchar             pointer to buffer containing the
                                      geometry in internal format
     *msg          IGRlong         completion code
     *newobjid    GRobjid         differs from my-id only if the
                                     object changes classes
     validate_class                 if TRUE the geometry will be validated
                                    for the class of the surface.

History  
         RC    1/18/87    Creation Date
*/


{
  IGRlong         OM_stat;
IGRlong   mthd_stat;

  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

/*
 * Post the geometry
 */

OM_stat = om$send (msg = message GRvg.GRpostabsg (&mthd_stat,
                   md_env, info, absptr, newobjid),
                 targetid = my_id);
EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

/*
 * If the caller wishes to validate the class, do so.
 */

if (validate_class)
{
  OM_stat = om$send (msg = message EMSsubbs.EMvalidateClass (&mthd_stat,
                      md_env, newobjid, 
                      (struct IGRbsp_surface *)absptr),
                     targetid = *newobjid);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

} /* if (validate_class) */

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "In EMSsubbs.EMputGeom");

  return (OM_stat);

}

end implementation EMSsubbs;
