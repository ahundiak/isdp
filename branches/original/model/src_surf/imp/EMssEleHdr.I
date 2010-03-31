/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

/*
Abstract

    This method generates the element header for a surface
    including the element specific attributes, but excluding
    the rule lines.

History

    20 Sep 1991 AIC Argument change to pass matrix and type in
                    GRmdenv_info structure; include this in the display
                    buffer.
    01 Dec 1988 SS  Changed the call to get abstract-geometry to the
                    method call EMSsubbs.EMgetabsgeom.
    12 Oct 1988 AIC Change alt_symb from IGRdisplay structure to
                    IGRaltdisplay structure.
    15 Jul 1987 AIC Creation Date.
*/

# include "OMminimum.h"     /* for gocmacros.h          */
# include "OMindex.h"
# include "igrtypedef.h"    /* gocmacros.h and dpstr.h  */
# include "gocmacros.h"     /* GRgetabsg macro          */
# include "msdef.h"         /* MS message codes         */
# include "madef.h"         /* MAIDMX                   */
# include "igrdp.h"         /* dpstruct.h               */
# include "dpstruct.h"      /* dpstr.h replacement      */
# include "igrdef.h"        /* dpmacros.h               */
# include "dpmacros.h"      /* dpmacros.h               */
# include "EMSlogic.h"      /* EMSmsgReport             */
# include "EMStypedef.h"    /* EMSmsgReport             */
# include "EMScmacros.h"    /* EMSmsgReport             */

method EMget_ele_header(IGRlong *EMmsg;
                        struct IGRbsp_surface *in_surface;
                        struct GRmdenv_info *mdenv_info;
                        struct IGRaltdisplay *alt_symb;
                        struct DPele_header *ele_header;
                        GRrange range_buffer;
                        struct IGRdisplay *dis_att_buffer;
                        union IGRele_attr ele_spec_buffer;
                        OM_p_KEY_DESC key)
{
  IGRchar                   *generic_pointer;
  extern IGRshort           BSbx2();
  IGRshort                  status;
  IGRint                    sts, total_poles;
  IGRdouble                 *weights;
  struct IGRbsp_surface     *surface = NULL;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = MSSUCC;

  /*
   * Generate my abstract data
   */
  if(! in_surface)
  {
    EMunlock_surf_absg_buffer();
    sts = om$send(msg = message EMSsubbs.EMgetabsgeom(EMmsg,
                    &mdenv_info->matrix_type, mdenv_info->matrix,
                    &generic_pointer),
                  targetid = my_id);
/*
    GRgetabsg(EMmsg, &mdenv_info->matrix_type, mdenv_info->matrix, &generic_pointer, i);
*/
    if (! (1 & *EMmsg)) goto wrapup;
    surface = (struct IGRbsp_surface *) generic_pointer;
  }
  else surface = in_surface;

  if(range_buffer)
  {
    /*
     * Fill in the correct range
     */
    if (key && (mdenv_info->matrix_type == MAIDMX))
    {
      if(!GRtransrange(EMmsg, key, range_buffer))
      { *EMmsg = MSFAIL; goto wrapup; }
    }
    else
    {
      total_poles = surface->u_num_poles * surface->v_num_poles;
      weights = surface->rational ? surface->weights : NULL;
      status = BSbx2(EMmsg, &total_poles, surface->poles, weights,
                     range_buffer, &range_buffer[3]);
    }
  }

  /*
   * Fill in the symbology and special display information.
   * (The object's symbology used to be accessed using a message,
   *  but for optimization purposes it is accessed directly in
   *  the instance data.)
   */
  if(alt_symb)
  {
/*    dis_att_buffer->rgb_value = alt_symb->rgb_value ?
        *(alt_symb->rgb_value) : me->display_attr.rgb_value; */
      dis_att_buffer->color = alt_symb->color ?
        *(alt_symb->color) : me->display_attr.color;
      dis_att_buffer->weight = alt_symb->weight ?
        *(alt_symb->weight) : me->display_attr.weight;
      dis_att_buffer->style = alt_symb->style ?
        *(alt_symb->style) : me->display_attr.style;
  }
  else
  {
    *dis_att_buffer = me->display_attr;
  }

  /*
   * Put my level in the element header
   */
  ele_header->level = &me->level;

  /*
   * Get the element specific attributes
   */
  sts = om$send(msg = message GRvg.GRgetattr(EMmsg,
                (IGRchar *)ele_spec_buffer.bspsurf), targetid = my_id);
  if(! (1 & *EMmsg & sts)) goto wrapup;

  /*
   * Fill in the element header
   */
  dp$build_dis_buffer(buffer = ele_header, tag = my_id, type = IGRQS,
                      range = range_buffer, display_att = dis_att_buffer,
                      ele_spec_att = ele_spec_buffer.bspsurf,
                      geometry = surface, mdenv_info = mdenv_info);

wrapup:
  EMSmsgReport(sts, "EMSsubbs.EMget_ele_header", FALSE);
  if EMSmsgReport(*EMmsg, "EMSsubbs.EMget_ele_header", FALSE)
    sts = OM_E_ABORT;
  return (sts);
}

end implementation EMSsubbs;
