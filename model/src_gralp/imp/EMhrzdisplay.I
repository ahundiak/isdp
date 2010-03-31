/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

#include <stdio.h>
#include "bs.h"
#include "bsparameters.h"
#include "EMSfrtdef.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"


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
    17 Sep 91   Jack    Changed to get z_vector from the horizon loop's
                        reference plane.
    04 Dec 91   Jack    Removed call to inv_xform_vector for the z vector
                        since the z_vector returned from the reference plane
                        has already been transformed correctly.
    03 Oct 92   msm     ANSI-C conversion.
    07 Jul 93   WBC     Only displaying the horizon edges if the horizon edge
                        display on/off switch is on.

*/


/* 
 * Earlier defined at EMSloop 
 */
method EMdisplay( long                   *EMmsg;
                  IGRboolean              owner_origin;
                  enum GRdpmode          *mode;
                  struct DP_information  *sp_info;
                  struct IGResbs         *bs_attr;
                  struct DPele_header    *ele_header;
                  short                  *mx_type;
                  IGRmatrix               matrix;
                  char                   *buffer;
                  int                     buffer_size;
                  struct EMSpartolbasis  *partol;
                  IGRboolean             *display_done;
                  struct GRid            *window_id )

{
  long      sts = OM_S_SUCCESS;
  OM_S_CHANSELECT father;

  if( ME.EMShelper->props & EMGL_NO_DISPLAY ) goto wrapup;

  if(( EFhorizon_edge_display_on_off() ) &&
     ( EFhorizon_edges_on_off() || EFget_gra_edges() ))
  {
    double  z[3],
            z_vector[3],
            value;
    void    EMget_view_z();
    int     EMcompare_vectors();
    struct  GRmd_env md_env;
    struct GRid     ref_pln_id;
    IGRdouble       v_matrix[16];
    IGRlong         bytes_ret;
    IGRint          which_error;
    struct var_list list[2];

/*    EMget_view_z( sp_info, z ); */
      list[0].var = VW_ROT_NO_CON;
      list[0].var_ptr = (IGRchar *)v_matrix;
      list[0].num_bytes = sizeof(IGRdouble) * 16;
      list[0].bytes_returned = &bytes_ret;

      list[1].var = END_PARAM;
      list[1].var_ptr = NULL;
      list[1].num_bytes = 0;
      list[1].bytes_returned = NULL;
 
      sts = dp$inq_set_gragad(msg = EMmsg,
                              osnum = window_id->osnum,
                              gragad_objid = window_id->objid,
                              which_error = &which_error,
                              var_list = list);
     if(! (1 & sts & *EMmsg)) goto wrapup; 

     z[0] = v_matrix[8];
     z[1] = v_matrix[9];
     z[2] = v_matrix[10];          

/*    if(*mx_type != MAIDMX) EMinv_xform_vector( matrix, z ); */

    md_env.md_id.osnum = 0;
    md_env.md_id.osnum = 0;  
    md_env.md_env.matrix_type = *mx_type;
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


    if( EMcompare_vectors( z, z_vector, &value ))
    {
      sts = om$send( msg = message EMSgraloop.EMdisplay(
                                             EMmsg,
                                             owner_origin,
                                             mode,
                                             sp_info,
                                             bs_attr,
                                             ele_header,
                                             mx_type,
                                             matrix,
                                             buffer,
                                             buffer_size,
                                             partol,
                                             display_done,
                                             window_id ),
                    targetid = my_id, 
                    mode = OM_e_wrt_message );
    if(! (1 & sts & *EMmsg)) goto wrapup;
    }
  }

wrapup:

  EMWRAPUP( *EMmsg, sts, "EMShorizon.EMdisplay" )
  *EMmsg = EMS_S_Success;
  return OM_S_SUCCESS;
};


end implementation EMShorizon;
