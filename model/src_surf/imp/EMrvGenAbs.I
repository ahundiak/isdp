/* ###################   APOGEE COMPILED   ################## */
class implementation EMSrevol;


# include "EMS.h"
# include "msdef.h"         /* MSSUCC               */
# include "EMSssprops.h"    /* surface properties   */
# include "OMmacros.h"      /* OM_BLOCK_MOVE        */
# include "EMSommacros.h"   /* ems$get_memory       */
# include "bstypes.h"       /* BSrc                 */
# include "bserr.h"	    /* BSSUCC 		    */

# define BUFFER_SIZE    400
# define V_ORDER        3
# define V_NUM_POLES    7

method GRgenabsg(IGRlong *EMmsg; IGRshort *mx_type;
                 IGRmatrix mx; IGRchar **absgptr)
/*
Abstract

    GENerate ABStract Geometry: This method generates the abstract
    geometry for the class EMSrevol.

Arguments

    mx_type - input
        Type of matrix (idenetity, rotation, etc.)

    mx - input
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

History

    21 Aug 92   NP      Modified for ANSI compliance.
    02 May 88   AIC     Fixed the declaration of BSsf_rev. (was BSsf_rev2)
    25 Mar 88   AIC     Creation Date
*/
{
  IGRlong       sts = OM_S_SUCCESS;
  IGRdouble     *doubles_buffer;
  IGRdouble     static_doubles_buffer[BUFFER_SIZE];

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;

  doubles_buffer = static_doubles_buffer;

  switch(me^^EMSsubbs.ss_props & EMSformat)
  {
    case EMSbsplineFormat:
      sts = om$send(msg = message EMSsubbs.GRgenabsg(EMmsg, mx_type, mx,
                    absgptr), mode = OM_e_wrt_message, targetid = my_id);
      break;

    case EMSrevolvedFormat:
      {
 extern  IGRboolean  BSsf_rev();
        IGRboolean              is_360, pos_orient_flag;
        BSrc                    rc;
        IGRlong                 total_bytes;
        struct IGRbsp_surface   *surface;
        IGRdouble               start_angle, sweep_angle, axis[6];
        struct IGRbsp_curve     curve;
        struct GRabsg_hdr       absg_hdr;

        sts = om$send(msg = message EMSrevol.EMgetRevolvedFormat(EMmsg,
                      TRUE, mx_type, mx, &curve, NULL, NULL, NULL, NULL,
                      NULL), targetid = my_id);
        if(! (1 & sts)) goto wrapup;

        /*
         * Get the memory for the curve data.
         */
        ems$get_memory(rc = EMmsg, element_size = sizeof(IGRdouble),
                       num_elements = curve.num_poles *
                                      (curve.rational ? 4:3) +
                                        curve.num_knots,
                       buffer = (IGRchar *)static_doubles_buffer,
                       buffer_size=BUFFER_SIZE,
                       ptr = (IGRchar **)&doubles_buffer);

        /*
         * Partition the doubles buffer
         */
        curve.poles = doubles_buffer;
        curve.weights = curve.rational ?
                        doubles_buffer + curve.num_poles * 3 : NULL;
        curve.knots = doubles_buffer +
                      curve.num_poles * (curve.rational ? 4 : 3);

        /*
         * Get the curve data
         */
        sts = om$send(msg=message EMSrevol.EMgetRevolvedFormat(EMmsg,
                      FALSE, mx_type, mx, &curve, axis, &is_360,
                      &start_angle, &sweep_angle, &pos_orient_flag),
                      targetid = my_id);
        if(! (1 & *EMmsg & sts)) goto wrapup;

        /*
         * Get the size needed for the abstract buffer
         */
        EMSbs_size(curve.order, V_ORDER, curve.num_poles, V_NUM_POLES,
                   TRUE, 0, (IGRlong *) NULL, total_bytes)

        /*
         * Allocate the abstract buffer
         */
        absg_hdr.geometry_size = total_bytes;
        absg_hdr.id.objid = my_id;
        absg_hdr.id.osnum = OM_Gw_current_OS;
        absg_hdr.matrix_type = *mx_type;
        OM_BLOCK_MOVE(mx, absg_hdr.matrix, sizeof(IGRmatrix));
        surface = (struct IGRbsp_surface *) GRabsg_alloc(EMmsg,&absg_hdr);
        if (! (1 & *EMmsg)) goto wrapup;

        /*
         * Partition the abstract buffer
         */
        EMSbs_partition(curve.order,V_ORDER,curve.num_poles,V_NUM_POLES,
                        TRUE, 0, (IGRlong *)NULL, surface)

        /*
         * Generate the geometry
         */
        {
          IGRboolean    BS_sts = TRUE ;
          BS_sts = BSsf_rev( &rc, axis, &axis[3], &curve, &is_360,
                             &start_angle, &sweep_angle, surface);
          if( ! BS_sts || rc != BSSUCC )
          {
            /*
             * Possible invalid input argument, the axis are smaller
             * then given tolerance. No surface geometry created.
             */
            *EMmsg = MSFAIL ;
            goto wrapup ;
          }
        }

        surface->pos_orient = pos_orient_flag;
        *absgptr = (IGRchar *) surface;
      }
      break;

    default:
      *EMmsg = MSFAIL;
  }

wrapup:
  if(doubles_buffer && (doubles_buffer ISNT static_doubles_buffer))
    om$dealloc(ptr = doubles_buffer);
  EMWRAPUP(*EMmsg, sts, "EMSrevol.GRgenabsg")

  return(sts);
}

end implementation EMSrevol;
