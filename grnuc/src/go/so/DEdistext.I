/*----

     CLASS  NAME:        GRtext

     METHOD NAME:        DEdisyourself

     Abstract:           This implementation file displays the text 
                         differently if it has symbology override.

HISTORY :

     01/11/93   msm      Creation date.
     12/19/94   Sudha	 Fix TR# 119423451 - send the argument to GRtransrange
			 properly ( detected by Purify )

*/

class implementation GRtext;

#include <alloca.h>
#include <stdio.h>
#include <sys/types.h>
#include "msdef.h"
#include "codef.h"
#include "dpmacros.h"
#include "igrmacros.h"
#include "igrdef.h"
#include "gocmacros.h"
#include "godef.h"
#include "ma.h"
#include "dpmacros.h"
#include "dperr.h"
#include "dpdef.h"
#include "DEso.h"
#include "exmacros.h"
#include "OMmacros.h"

extern int DEboth_auto_man;
extern GRobjid LocalPlotviewid;
extern int DEdisplay_soo;

from DEso import DEget;
/* This method is used to display symbology overrtides on text elements.
*/
method DEdisyourself ( long *msg; short *type; IGRmatrix matrix;
                       enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
                       struct DP_information *sp_info; OM_p_KEY_DESC *key )
{
  long                   status;
  GRrange                range;
  IGRboolean             world;
  struct DPele_header    ele_header;    /* structure for display function       */
  struct IGRdisplay      dis_attr;
  struct IGRdisplay      *display_attributes;
  int                    num_bounds;
  double                 *boundary_parms;
  struct GRid            soo;
  IGRlong                msg2;
  struct IGRlbsys        lbs_geom;       /* text's lbs geometry            */
  struct IGResintx       text_info;      /* text information               */
  struct IGRestx         tx_attr;        /* text specific attributes       */

  /* first make sure that we have an override */
  DEget_soo ( &soo.objid, &soo.osnum, OM_Gw_current_OS  );
  *msg = MSFAIL;
  if (soo.objid != NULL_OBJID)
   {
     if(LocalPlotviewid)
    om$send ( msg = message DEso.DEget ( msg, NULL, &boundary_parms, 
                                         &num_bounds, 
                                         &display_attributes,
					 &me->display_attr,
                                         my_id, LocalPlotviewid,
                                         type, matrix, DEboth_auto_man,
					 0 ),
              targetid = soo.objid,
              targetos = soo.osnum );
     else
    om$send ( msg = message DEso.DEget ( msg, NULL, &boundary_parms, 
                                         &num_bounds, 
                                         &display_attributes,
					 &me->display_attr,
                                         my_id, sp_info->view_objid,
                                         type, matrix, DEboth_auto_man,
					 0 ),
              targetid = soo.objid,
              targetos = soo.osnum );
   }
  if (*msg != MSSUCC)
  {
    return OM_S_SUCCESS;
  }

  status = OM_S_SUCCESS;

  /* Purify fix - *key is the argument for GRtransrange */     

  if ((key) && (*key) && (*type == MAIDMX)) {
            if (!GRtransrange(&msg2,*key,range))
            {
                *msg = MSFAIL;
                status = OM_W_ABORT;
                return (status);
            }
  }
  else {
            world = TRUE;
            status = om$send(mode = OM_e_wrt_object,
                               msg = message GRvg.GRgetrang(&msg2,type,matrix,
                                                            &world,range),
                               senderid = my_id,
                               targetid = my_id);
            if (!(1 & status))                /* get range failed       */
            {
                *msg = MSFAIL;
                status = OM_W_ABORT;
                return (status);
            }
  }
  status = om$send(mode = OM_e_wrt_object,
                           msg = message GRvg.GRgetgeom(&msg2,type,
                                 matrix, (IGRchar *) &lbs_geom),
                           senderid = my_id,
                           targetid = my_id);

        if (! (1 & msg2) || ! (1 & status))        /* method failed */
        {
            *msg = MSFAIL;
            status = OM_W_ABORT;
            return (status);
        }

  if (alt_symb)
  {
    dis_attr.color = (alt_symb->color ?
        *alt_symb->color : me->display_attr.color);
    dis_attr.weight = (alt_symb->weight ?
        *alt_symb->weight : me->display_attr.weight);
    dis_attr.style = (alt_symb->style ?
        *alt_symb->style : me->display_attr.style);
  }
  else
  {
    dis_attr = me->display_attr;
  }

  text_info.estx = &tx_attr;

  text_info.estx->font        = me^^GRtext.attr.font;
  text_info.estx->just        = me^^GRtext.attr.just;
  text_info.estx->width       = me^^GRtext.attr.width;
  text_info.estx->height      = me^^GRtext.attr.height;
  text_info.estx->flag        = me^^GRtext.attr.flag;
  text_info.estx->num_char    = me^^GRtext.attr.num_char;
  text_info.estx->line_spac   = me^^GRtext.attr.line_spac;
  text_info.estx->char_spac   = me^^GRtext.attr.char_spac;
  text_info.estx->text_length = me^^GRtext.attr.text_length;

  text_info.font_id           = OM_Gw_current_OS;
  text_info.flags             = 0;
  text_info.prev_font         = me^^GRtext.attr.font;
  text_info.text_string       = (IGRchar *)me^^GRtext.text_string;

  dp$build_dis_buffer(buffer = &ele_header,
                          tag = my_id,
                          type = IGRLB,
                          range = range,
                          level = NULL,
                          display_att = &dis_attr,
                          ele_spec_att = &text_info,
                          geometry = &lbs_geom);

  if (DEdisplay_soo) {
     status = dp$dispelem ( msg = msg,
                           buffer = &ele_header,
                           mode = *mode,
                           dp_info = sp_info);
  }
  else  if (! ( (num_bounds == 1) &&
                (boundary_parms [0] == 0.0) &&
                (boundary_parms [1] == 1.0) &&
                (display_attributes [0].color == 0xffff) ) ) {

    /* this is not a total override => display text normally */
    status = dp$dispelem ( msg = msg,
                           buffer = &ele_header,
                           mode = *mode,
                           dp_info = sp_info);

  }

  return status;
}

end implementation GRtext;
