/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include <stdio.h>
#include "bs.h"
#include "bsparameters.h"
#include "EMSfrtdef.h"       /* EMGL_NO_DISPLAY */
#include "emssfcvs.h"
#include "OMmacros.h"

extern int EFhorizon_edges_on_off();
extern int EFget_gra_edges();
extern int EFhorizon_edge_display_on_off();

from EMSdatpln  import EMget_pln_info;

/*
History

    10 Jul 90   AIC     Creation Date
    03 Oct 90   AIC     Added support for "best hit" display.
    11 Nov 90   AIC     Removed "best hit" display, added edge-based
                        rule lines.
    26 Nov 90   AIC     Support horizon edge display on/off switch.
    01 May 91   Jack    Modified for 2.0.1 Horizon Loops.
    29 Jul 91   SCW     Added check for no_display flag
    30 Aug 91   Jack    The view vector is now passed in via args.
    17 Sep 91   Jack    Changed to get z_vector from the horizon loop's
                        reference plane.
    04 Dec 91   Jack    Removed call to inv_xform_vector for the z vector
                        since the z_vector returned from the reference plane
                        has already been transformed correctly.
    26 Feb 92   Jack    Determine which function is coming in since the
                        args will be different and this will affect how
                        we get the z vector.                                
    23 Sep 92   Jack    Exit if the view_vector in the args is NULL.
    26 Jul 93   WBC     Only processing the horizon edges if the horizon edge
                        display on/off switch is on.

*/


method EMexecuteCurveFunction(IGRlong *EMmsg; 
                              struct IGRbsp_surface *surf;
                              IGRshort *mx_type; 
                              IGRmatrix mx;
                              GRobjid surf_id; 
                              IGRint (*f)();
                              IGRchar *args;
                              IGRushort eligible_edge_type)

{
  IGRlong   sts = OM_S_SUCCESS;
  IGRvector z, 
            z_vector;
  struct  GRmd_env     md_env;
  OM_S_CHANSELECT      father;
  struct GRid          ref_pln_id;

  *EMmsg = EMS_S_Success;

  if( ME.EMShelper->props & EMGL_NO_DISPLAY ) goto wrapup;

  if(( EFhorizon_edge_display_on_off() ) &&
     EFhorizon_edges_on_off() || EFget_gra_edges())
  {
    extern int EMmake_surface_curves(), EMcpmscs20();
    struct EMScurveinfo *cv_struct;
    
    if(f == EMcpmscs20)
    {
      cv_struct = ((struct EMSwireframe_mscinfo *)args)->curve_info;
    }
    else
    {
      cv_struct = (struct EMScurveinfo *)args;
    }

    /*
     * this routine requires the view_vector be set.
     */
    if(cv_struct->view_vector == NULL)
      goto wrapup;      

    z[0] = cv_struct->view_vector[0];
    z[1] = cv_struct->view_vector[1];
    z[2] = cv_struct->view_vector[2];
/*     if(*mx_type != MAIDMX) EMinv_xform_vector(mx, z); */


    md_env.md_id.osnum = 0;
    md_env.md_id.osnum = 0;  
    md_env.md_env.matrix_type = *mx_type;
    OM_BLOCK_MOVE(mx,md_env.md_env.matrix,(16* sizeof(IGRdouble)));


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
                           ( EMmsg,
                             NULL,
                            &md_env,  
                             NULL,
                             NULL,
                             z_vector,
                             NULL,
                             NULL), 
                  senderid = my_id,
                  targetid = ref_pln_id.objid,
                  targetos = ref_pln_id.osnum );                  
    if(! (1 & sts & *EMmsg)) goto wrapup;



    if(EMcompare_vectors(z, z_vector, NULL))
    {
      sts = om$send(msg = message EMSloop.EMexecuteCurveFunction(
                                           EMmsg,
                                           surf,
                                           mx_type,
                                           mx,
                                           surf_id, 
                                           f,
                                           args,
                                           eligible_edge_type),
                  targetid = my_id, 
                  mode = OM_e_wrt_message);
    if(! (1 & sts & *EMmsg)) goto wrapup;
    }
  }

wrapup:

  EMWRAPUP(*EMmsg, sts, "EMShorizon.EMexecuteCurveFunction")
  return sts;
}

end implementation EMShorizon;
