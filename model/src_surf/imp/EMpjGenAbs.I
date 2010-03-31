/* ###################   APOGEE COMPILED   ################## */
class implementation EMSproject;

#include "EMS.h"
# include "OMmacros.h"
# include "EMSssprops.h"
# include "EMSsfdef.h"
# include "EMSproject.h"
# include "emserr.h"
# include "msdef.h"

# define V_ORDER        2
# define V_NUM_POLES    2

method GRgenabsg(IGRlong *EMmsg; IGRshort *matrix_type;
                 IGRmatrix matrix; IGRchar **absgptr)
/*
Abstract

    GENerate ABStract Geometry: This method generates the abstract
    geometry for the class EMSproject.

Arguments

    matrix_type - input
        Type of matrix (idenetity, rotation, etc.)

    matrix - input
        Local to world matrix.

    absgptr - output
        The address of the generated abstract geometry.

Algorithm

    If the surface is stored in the bspline format, send invoke the
    EMSsubbs method. Otherwise determine the subformat and retrive the
    geometry.

Return Status

    MSSUCC - Successful completion
    MSFAIL - Failure

Bugs

Notes

Examples

    sts = om$send(msg = message EMSsubbs.GRgenabsg(&return_code,
                  matrix_type, matrix, &abstract_buffer),
                  mode = OM_e_wrt_message, target_id = surface_id);

History

    01 Jun 88   AIC     EMgetBaseCurve and EMgetProjection were
                        merged into EMgetProjection.
    02 May 88   AIC     Get planarity from GRgraphics properties.
    06 Apr 88   AIC     Set the pos_orient flag.
    10 Mar 88   AIC     Creation Date
*/
{
  IGRlong   sts = OM_S_SUCCESS;

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;

  switch(me^^EMSsubbs.ss_props & EMSformat)
  {
    case EMSbsplineFormat:
      sts = om$send(msg = message EMSsubbs.GRgenabsg(EMmsg, matrix_type,
                    matrix, absgptr), mode = OM_e_wrt_message,
                    targetid = my_id);
      break;

    case EMSprojectedFormat:
      {
  extern         IGRchar                             *GRabsg_alloc();
        IGRboolean                          rational;
        IGRlong                             total_bytes;
        struct IGRbsp_surface               *surface;
        struct GRabsg_hdr                   absg_hdr;
        struct EMSprojectedSurfaceHeader    *instance_data;

        /*
         * Calculate the abstract buffer size
         */
        instance_data = (struct EMSprojectedSurfaceHeader *)
                        me^^EMSsubbs.packed_data;
        rational = instance_data->pj_props & EMSIS_PJ_RATIONAL ?
                   TRUE : FALSE;
        EMSbs_size(instance_data->order, V_ORDER,
                   instance_data->num_poles, V_NUM_POLES,
                   rational, 0, (IGRlong *)NULL, total_bytes)

        /*
         * Allocate the abstract buffer
         */
        absg_hdr.geometry_size = total_bytes;
        absg_hdr.id.objid = my_id;
        absg_hdr.id.osnum = OM_Gw_current_OS;
        absg_hdr.matrix_type = *matrix_type;
        OM_BLOCK_MOVE(matrix, absg_hdr.matrix, sizeof(IGRmatrix));
        surface = (struct IGRbsp_surface *) GRabsg_alloc(EMmsg,&absg_hdr);
        if (! (1 & *EMmsg)) goto wrapup;

        /*
         * Partition the abstract buffer
         */
        EMSbs_partition(instance_data->order, V_ORDER,
                        instance_data->num_poles, V_NUM_POLES,
                        rational, 0, (IGRlong *)NULL, surface)

        /*
         * Generate the projected surface geometry
         */
        {
          IGRuchar              projection_format;
          union EMSprojectionFormat     projection;
          struct IGRbsp_curve           base_curve;

          base_curve.poles = surface->poles;
          base_curve.weights = surface->weights;
          base_curve.knots = surface->u_knots;

          /*
           * Get the curve and projection data
           */
          sts = om$send(msg = message EMSproject.EMgetProjection(EMmsg,
                        matrix_type, matrix, FALSE, &projection_format,
                        &projection, &base_curve), targetid = my_id);
          if(! (1 & *EMmsg & sts)) goto wrapup;

          /*
           * Project the curve data
           */
          {
            void        EFproject();
            IGRshort    planarity;

            planarity = me^^GRgraphics.properties & GRIS_PLANAR ?
                        EMS_O_ISPLANAR : EMS_O_NOTPLANAR;
            EFproject(EMmsg, &base_curve, projection_format, &projection,
                      planarity, surface);
            if(! (1 & *EMmsg)) goto wrapup;
          }

          surface->pos_orient = me^^EMSsubbs.ss_props &
                                EMSIS_NRML_REVERSED ? FALSE : TRUE;
          *absgptr = (IGRchar *)surface;
        }
      }
      break;

    default:
      *EMmsg = MSFAIL;
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSproject.GRgenabsg")
  return(sts);
}

end implementation EMSproject;
