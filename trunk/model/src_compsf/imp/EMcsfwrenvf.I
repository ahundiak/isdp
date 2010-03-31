/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#define MODEL_ITEM  200
#define ENTITY      200

/*
Description
   This method writes a surface composite owner to the Envelope file
   as a component provided it is the active state. And then it passes
   the message to its childern.

History
   RC    05/24/89     Creation Date

*/

method EMcreate_envelope_and_igds_files (
         IGRlong                *EMmsg; 
         struct GRmd_env        *md_env;
         IGRdouble              *scale_factor; 
         struct GUcvt_bufs      *cvt_buffers;
         IGRlong                *IGDS_filedesc; 
         IGRdouble              *max_abs_overflow;
         IGRint                 *cmpnt_tag; 
         IGRboolean             is_tag_good; 
         IGRdouble              *file_ige_range;
         IGRint                 *num_processed_ids, *processed_ids_arrsz;
         GRobjid                **processed_ids)
{
 OM_S_CHANSELECT to_cmpnt_chan;
 IGRlong         OM_stat;
 extern IGRlong  EMmake_chanselect();

 /* ************************************************************* */

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 /*
  * o Pass the message to my components.
  */

 EMmake_chanselect (GRcmpowner_to_components, &to_cmpnt_chan);

 OM_stat = om$send (msg = 
                     message EMSsurface.EMcreate_envelope_and_igds_files (
                      EMmsg, md_env, scale_factor, cvt_buffers,
                      IGDS_filedesc, max_abs_overflow, cmpnt_tag, 
                      is_tag_good, file_ige_range, num_processed_ids, 
                      processed_ids_arrsz, processed_ids),
                     p_chanselect = &to_cmpnt_chan);
 EMerr_hndlr (!(1&OM_stat& *EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);

 wrapup:
  EMWRAPUP(*EMmsg,OM_stat,"EMScompsurf.EMcreate_envelope_and_igds_files");
  return (OM_stat);

} /* EMcreate_envelope_and_igds_files () */

end implementation EMScompsurf;
