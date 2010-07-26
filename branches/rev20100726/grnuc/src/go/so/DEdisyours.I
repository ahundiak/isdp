class implementation GRvg;

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

%safe
int DEboth_auto_man = 0;
GRobjid LocalPlotviewid = 0;
%endsafe

from DEso import DEget;


IGRint DEinq_localplot(viewid,flag)
GRobjid *viewid;
int flag;
{
   if(flag)
     LocalPlotviewid = *viewid;
   else
     LocalPlotviewid = 0;
    
   return OM_S_SUCCESS;
}

DEshow_only_man_soo ()
/*
   This function is used when the manual soo's need to be highlighted.
*/
{
  DEboth_auto_man = 2;

  return OM_S_SUCCESS;
}


DEshow_all_soo ()
/*
   This function is used when all soo's need to be highlighted.
*/
{
  DEboth_auto_man = 0;

  return OM_S_SUCCESS;
}


method DEdisyourself ( long *msg; short *type; IGRmatrix matrix;
                       enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
                       struct DP_information *sp_info; OM_p_KEY_DESC *key )
{
  char                   *ptr;          /* pointer to the abstact geometry      */
  long                   status;
  GRrange                range;
  struct DPele_header    ele_header;    /* structure for display function       */
  struct IGResbc         bc_attr;       /* B-spline element specific attributes */
  struct DEcv_soo_info   bounds;        /* structure used to display the soo's  */
  struct IGRdisplay      dis_attr;
  struct IGRdisplay      *display_attributes;
  int                    num_bounds;
  double                 *boundary_parms;
  struct GRid            soo;
  struct GRmdenv_info    mdenv_info;

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
    /* if override not found for this hindx return. */
    return OM_S_SUCCESS;
  }

  status = OM_S_SUCCESS;

  /* get and assign abstract geometry */
  status = om$send( msg = message GRvg.GRgenabsg ( msg, type, matrix, &ptr ),
                    targetid = my_id );
  if (!(status & 1))
    return status;

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
    dis_attr = me->display_attr;

  /* get and assign Attributes */
  om$send ( msg = message GRvg.GRgetattr ( msg, (char *)&bc_attr ),
            targetid = my_id );
  if (!(status & 1))
    return status;

  mdenv_info.matrix_type = *type;
  OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRmatrix));

  dp$build_dis_buffer ( buffer = &ele_header,
                        tag = my_id,
                        range = range,
                        level = NULL,
                        ele_spec_att = (struct IGResbc *)&bc_attr,
                        display_att = &dis_attr,
                        geometry = (struct IGRbsp_curve *) ptr,
			mdenv_info = &mdenv_info );

  /* clip with respect to the window range */
  MAcubepy ( msg, (struct IGRbsp_curve *) ptr, ele_header.range, &ele_header.range [3] );

  bounds.bounds = &(boundary_parms [0]);
  bounds.attr = &(display_attributes [0]);
  bounds.num_bounds = num_bounds;

  /* Display the element with the soo boundary information */
  if (!DEcvdiselem ( msg, &ele_header, mode, sp_info, &bounds, type, matrix ))
    status = OM_E_ERROR;

  return status;
}

end implementation GRvg;
