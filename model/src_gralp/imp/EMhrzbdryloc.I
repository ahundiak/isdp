/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include <stdio.h>
#include "bs.h"
#include "bsparameters.h"


extern int  EFhorizon_edges_on_off();
extern int  EFget_gra_edges();
extern int EFhorizon_edge_display_on_off();

from EMSdatpln  import EMget_pln_info;

/*
History

    10 Jul 90   AIC     Creation Date
    03 Oct 90   AIC     Added support for "best hit" display.
    11 Nov 90   AIC     Removed "best hit" display, added edge-based
                        ruleMSSUCC lines.
    26 Nov 90   AIC     Support horizon edge display on/off switch.
    01 May 91   Jack    Modified for 2.0.1 Horizon Loops.
    16 Sep 91   Jack    Changed to get z_vector from the horizon loop's
                        reference plane.
    04 Dec 91   Jack    Removed call to inv_xform_vector for the z vector
                        since the z_vector returned from the reference plane
                        has already been transformed correctly.
    08 Jul 93   WBC     Only locating the horizon edges if the horizon edge
                        display on/off switch is on.
*/



/* 
 * Earlier defined at EMSboundary.
 */
method EMbdrylocate(IGRlong             *EMmsg;
                     struct EMSsfinfo   *sfinfo;
                     struct EMSlcinput  *lcin;
                     struct GRlc_cvl    *cvl;
                     OM_p_KEY_DESC       range_key;
                     struct EMSlcoutput *lcout)
{
  long  sts = OM_S_SUCCESS,
        msg = MSSUCC;
  


  if((EFhorizon_edge_display_on_off() ) &&
     (EFhorizon_edges_on_off() || EFget_gra_edges()))
  {
    double    z[3];
    void      EMget_locate_z();
    IGRdouble       z_vector[3];
    OM_S_CHANSELECT father;
    struct GRid     ref_pln_id;

    EMget_locate_z(&cvl->attributes, z);
/*     if((cvl->module.md_env.matrix_type) != MAIDMX)
      EMinv_xform_vector(cvl->module.md_env.matrix, z);
*/

    sts = EMmake_chanselect( NDfather_father, &father );
    if(! (1 & sts)) goto wrapup;

    /* Get the GRid of the reference plane.  It will always be the
       first object on the father channel.
     */
    om$get_objid_at_index( object = me,
                           p_chanselect = &father,
                           index = 0,
                           objidaddr = &ref_pln_id.objid,
                           osnumaddr = &ref_pln_id.osnum );
     

   /* get the z_vector from the reference plane connected to my father channel*/
    sts = om$send(msg = message EMSdatpln.EMget_pln_info
                           (&msg,
                             NULL,
                            &cvl->module, 
                             NULL,
                             NULL,
                             z_vector,
                             NULL,
                             NULL), 
                  senderid = my_id,
                  targetid = ref_pln_id.objid,
                  targetos = ref_pln_id.osnum );                  
    if(! (1 & sts & msg)) goto wrapup;



    if(EMcompare_vectors(z, z_vector, NULL))
    {

      /* EMSgraloop inherits EMbdrylocate from EMSloop */
      sts = om$send(msg = message EMSgraloop.EMbdrylocate(
                                            &msg, 
                                             sfinfo, 
                                             lcin, 
                                             cvl,
                                             range_key, 
                                             lcout),
                    targetid = my_id, 
                    mode = OM_e_wrt_message);
      if(! (1 & sts & msg)) goto wrapup;
    }
  }

wrapup:
  EMWRAPUP(msg, sts, "EMShorizon.EMbdrylocate")
  return sts;
}

end implementation EMShorizon;
