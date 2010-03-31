/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgenbs;

/*
HISTORY:

Long Ago:  ??	Creation.
08/27/92:  NP	Modified for ANSI compliance.
07/06/93: Sudha Modified for BSprototypes ansification

*/

#include "EMS.h"
#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "bssfarrev0w.h"
#include "bssfarrev0.h"
#include "bsnodevals.h"

#define MAX_BUFF 100

EFget_sf_nod_pts(EMmsg,surf,u_insert,v_insert,unum, vnum, u_vals,
                 v_vals,num_pts,weights, node_pts)
IGRlong *EMmsg;
struct IGRbsp_surface *surf;
IGRint u_insert;
IGRint v_insert;
IGRint *unum;
IGRint *vnum;
IGRdouble *u_vals;
IGRdouble *v_vals;
IGRint *num_pts;
IGRdouble *weights;
IGRdouble *node_pts;
{
 BSrc   rc;
 IGRint i,j,temp;
 IGRdouble wtpts_buff[MAX_BUFF][4], *wtpts_ptr = NULL;

 *EMmsg = EMS_S_Success;

  BSnodevals(surf->u_order,surf->u_num_knots,surf->u_knots,u_insert,unum,
             u_vals,&rc);
  EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

  BSnodevals(surf->v_order,surf->v_num_knots,surf->v_knots,v_insert,vnum,
             v_vals,&rc);
  EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

  if (surf->u_periodic)
  {
   temp = 0;
   for ( i=0;i < *unum;i++)
    {
       if ((u_vals[i] >= surf->u_knots[surf->u_order - 1]) &&
           (u_vals[i] <= surf->u_knots[surf->u_num_poles]))
        {
           u_vals[temp] = u_vals[i];
           temp++;
        }
    }
   *unum = temp;

   if ((surf->u_order % 2) == 1)
    {
      for (i = (*unum - 1);i >= 0;i--)
       {
          u_vals[i+1] = u_vals[i];
       }
      u_vals[0] = surf->u_knots[surf->u_order - 1];
      *unum += 2;
      u_vals[*unum - 1] = surf->u_knots[surf->u_num_poles];
    }
  }

 if (surf->v_periodic)
 {
   temp = 0;
   for ( i=0;i < *vnum;i++)
    {
       if ((v_vals[i] >= surf->v_knots[surf->v_order - 1]) &&
           (v_vals[i] <= surf->v_knots[surf->v_num_poles]))
        {
           v_vals[temp] = v_vals[i];
           temp++;
        }
    }
   *vnum = temp;

   if ((surf->v_order % 2) == 1)
    {
      for (i = (*vnum - 1);i >= 0;i--)
       {
          v_vals[i+1] = v_vals[i];
       }
      v_vals[0] = surf->v_knots[surf->v_order - 1];
      *vnum += 2;
      v_vals[*vnum - 1] = surf->v_knots[surf->v_num_poles];
    }
  }

  *num_pts = *unum * *vnum;

 if (surf->rational)
 {
  if (*num_pts > MAX_BUFF)
  {
    wtpts_ptr = (IGRdouble *) om$malloc(size = 4 * sizeof(IGRdouble) *
                              (*num_pts));
    EMerr_hndlr(!wtpts_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated,wrapup);

  }
  else
   wtpts_ptr = (IGRdouble *)wtpts_buff;

  BSsfarrev0w(surf,*unum,u_vals, *vnum, v_vals,wtpts_ptr,&rc);
  EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

  for (i=0;i<(*num_pts);i++)
  {
   weights[i] = wtpts_ptr[4*i+3];
   for (j=0;j<3;j++)
    node_pts[3*i+j] = wtpts_ptr[4*i+j]/weights[i];
  }
 }
 else
  BSsfarrev0(&rc,surf,*unum,u_vals,*vnum,v_vals,node_pts);
  EMerr_hndlr((rc != 0), *EMmsg, EMS_E_BSerror, wrapup);

wrapup:
 if (wtpts_ptr && (wtpts_ptr != (IGRdouble *)wtpts_buff))
  om$dealloc(ptr = wtpts_ptr);
 return;
}
end implementation EMSgenbs;

