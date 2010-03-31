/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include <stdio.h>
#include "bs.h"
#include "bsparameters.h"
#include "EMSfrtdef.h"    /* EMGL_NO_DISPLAY */
#include "OMmacros.h"

extern int EFhorizon_edges_on_off();
extern int EFget_gra_edges();

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
    17 Sep 91   Jack    Changed to get z_vector from the horizon loop's
                        reference plane.
    04 Dec 91   Jack    Removed call to inv_xform_vector for the z vector
                        since the z_vector returned from the reference plane
                        has already been transformed correctly.
                            
*/


/* 
 *  Earlier defined at EMSloop
 */
method EMkeypoint( IGRlong               *EMmsg;
                   struct IGRbsp_surface *surf;
                   IGRshort              *matrix_type;
                   IGRmatrix              matrix; 
                   struct IGRline        *boreline;
                   IGRdouble             *dist;
                   IGRpoint               keypoint;
                   struct GRparms        *key_parm;
                   struct GRid           *window_id )

{
  long  sts = OM_S_SUCCESS;
  struct  GRmd_env     md_env;
  OM_S_CHANSELECT      father;
  IGRdouble            z_vector[3];


  *EMmsg = EMS_S_Success;

  if( ME.EMShelper->props & EMGL_NO_DISPLAY ) goto wrapup;

  if( EFhorizon_edges_on_off() || EFget_gra_edges() )
  {
    double    z[3];
    void      EMget_boreline_z();
    struct GRid    ref_pln_id;

    EMget_boreline_z( boreline, z );
/*     if(*matrix_type != MAIDMX) EMinv_xform_vector(matrix, z); */

    md_env.md_id.osnum = 0;
    md_env.md_id.osnum = 0;  
    md_env.md_env.matrix_type = *matrix_type;
    OM_BLOCK_MOVE(matrix,md_env.md_env.matrix,(16* sizeof(IGRdouble)));


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

    if( EMcompare_vectors( z, z_vector, NULL ))
    {
      sts = om$send( msg = message EMSgraloop.EMkeypoint(
                                     EMmsg, 
                                     surf, 
                                     matrix_type,
                                     matrix,
                                     boreline,
                                     dist,
                                     keypoint, 
                                     key_parm,
                                     window_id ),
                     targetid = my_id, 
                     mode = OM_e_wrt_message );
    if(! (1 & sts & *EMmsg)) goto wrapup;
    }
  }
  
wrapup:

  EMWRAPUP( *EMmsg, sts, "EMShorizon.EMkeypoint" )
  return( sts );
};

end implementation EMShorizon;
