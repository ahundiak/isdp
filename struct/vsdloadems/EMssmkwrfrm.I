/* ###################   APOGEE COMPILED   ################## */
/*
Description

        This method creates a wire frame representation of a surface.

Arguments

    md_env - input
        Module environmt information.

    curve_info - input/ouput
        Information abount wireframe objects.

    eligible_edge_type - input
        The types of edges that are eligible.
        
History
    WBC 12-Apr-93   |'d in EMSeligible_NonSubEdge to the eligible_edge_type.
                    This fix was put in version 201.6 but did not get added
                    in version 220 at that time.
    NP  26-Aug-92   Modified for ANSI compliance.
    SM  06-Sep-89   Create shell loopset if there is no loopset. This is
		    to generate correct edge types.
    AIC 02-Jun-88   Added supress_common_edges argument.
    SM  20-Jan-88   Creation.
*/
class implementation EMSsubbs;

#ifndef emssfcvs_include
#include "emssfcvs.h"
#endif

#include "OMmacros.h"
#include "emseligible.h"
#include "EMSstruct.h"
#include "EMSobjmgrdef.h"

extern IGRboolean  VS_STRUDL_process;
/*
  External variable;  Set to TRUE during drawing extraction. Defaults to
FALSE. If it is TRUE, the downloaded EMS methods understand that they
are being called for drawing extraction and behave accordingly. When FALSE
their behavior is that of EMS' behavior.
*/

extern GRclassid OPP_EMSloopset_class_id;

method EMmake_wire_frame(IGRlong *EMmsg; struct GRmd_env *md_env;
                         struct EMScurveinfo *curve_info; 
                         IGRushort eligible_edge_type)
{
  IGRlong           sts = OM_S_SUCCESS;
  extern IGRint     EMmake_surface_curves(), EMcpmscs20();
  OM_S_CHANSELECT   to_ls;
  extern IGRboolean EMlsconstructor(), EMlsvalidator();
  extern IGRlong    EMgetshobj();
  struct EMSgrobj sf_objinfo;
  GRobjid	    lsobj;
  IGRushort loc_elig;
  struct EMSwireframe_mscinfo local_info;
  IGRboolean	    use_msc = FALSE;
  IGRuint	    count = 0;

  /*
   * Initialize
   */

  *EMmsg = EMS_S_Success;
  EMmake_chanselect(EMSsubbs_to_loopset, &to_ls);
  sts = om$get_channel_count(object = me, p_chanselect = &to_ls, 
			     count = &count);
  if(!(1&sts)) goto wrapup;
  use_msc = eligible_edge_type & EMSeligible_UseMsc ? TRUE : FALSE;

 if ( VS_STRUDL_process )
 {
  /*
   * for both plotting and create wireframe model, we don't want
   * to return geometry for subordinate edges.  the nonsubordinate
   * will be enough.
   */
 /* ALAIN FALASSE 13 April 94 : must disable this since it break the
    hidden lines of I/STRUCT drawing...
  eligible_edge_type |= EMSeligible_NonSubEdge;
    END ALAIN FALASSE */
 }
 else
 {
  eligible_edge_type |= EMSeligible_NonSubEdge;
 }

  if(!count)
   {
    /*
     * A loopset does not exist for this surface. Attach a shell loopset.
     */

    sf_objinfo.grid.objid = my_id;
    sf_objinfo.grid.osnum = OM_Gw_current_OS;
    sf_objinfo.envptr = TRUE;
    sf_objinfo.grenv.ptr = &md_env->md_env;
    sts = EMgetshobj (EMmsg, NULL, OPP_EMSloopset_class_id, 
                 EMSshobj_sfbdry, OM_Gw_current_OS, &sf_objinfo,
                 EMlsconstructor, &sf_objinfo, EMlsvalidator, &lsobj);
    if(!(1&*EMmsg&sts)) goto wrapup;
   }

  /*
   * Send message to the surface to execute the given function
   * for all its displayed curves.
   *
   * if option indicates using mscs if possible -
   * Make surface curves for all edges that do not have a MSC. If an
   * edge has a MSC, return MSC's copy as the wire frame for that edge.
   * This will carry the symbology override if any on the edge.
   * SM 3/21/90.
   */

   loc_elig = use_msc ? (eligible_edge_type | EMSeligible_NonMscEdge)
		      : eligible_edge_type;

   
   sts = om$send(msg = message EMSsubbs.EMexecuteCurveFunction(EMmsg,NULL,
                 &md_env->md_env.matrix_type, md_env->md_env.matrix,
                 EMmake_surface_curves, (IGRchar *)curve_info, loc_elig), 
                 targetid = my_id);

   if(use_msc)
    {
     /* Execute different function only for those edges which have MSC.
        This function will return copy of the MSC.
     */
     loc_elig = eligible_edge_type | EMSeligible_MscEdge 
				   | EMSeligible_NoGradata;

     loc_elig = loc_elig & ~EMSeligible_NonMscEdge;

     local_info.old_env = md_env;
     local_info.curve_info = curve_info;

     sts = om$send(msg = message EMSsubbs.EMexecuteCurveFunction(EMmsg,NULL,
                 &md_env->md_env.matrix_type, md_env->md_env.matrix,
                 EMcpmscs20, (IGRchar *)&local_info, loc_elig), 
                 targetid = my_id);
    }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMSsubbs.EMmake_wire_frame")
  return(sts);
}



end implementation EMSsubbs;
