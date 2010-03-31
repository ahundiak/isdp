/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloopset;

#include "EMS.h"
#define U 1
#define V 2

#include <stdio.h>
#include "emsmacros.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "EMSsplitdef.h"

from EMSsubbs import EMgetbsdef;
from EMSloop  import EMgetrange;

static void EFsortdouble(array,size)
IGRdouble *array;
IGRint size;
{
    IGRint i , j ;
    IGRdouble temp ;

    for ( i  = 0 ; i  +1  <size ; i ++ )
    {
        for ( j  = i  +1 ; j  <size ; j ++ )
        {
            if ( array [ i ]  >array [ j ] )
            {
                temp  = array [ i ] ;
                array [ i ]  = array [ j ] ;
                array [ j ]  = temp ;
            }
        }
    }
}

static IGRboolean EFget_u_v_range(U_V,num_loops,valid_ranges,loop_range,
								  range)
IGRushort U_V;
IGRint num_loops;
IGRboolean *valid_ranges;
IGRdouble *loop_range;
IGRdouble *range;
{
 IGRint i, j, next1, next2;
 IGRlong num_coal;
 IGRdouble  *u_v_min,  *u_v_max, min, max, least_span;

 u_v_min  = u_v_max  = 0 ;

 u_v_min  = (IGRdouble  *) om$malloc(size = num_loops*sizeof(IGRdouble));
 u_v_max  = (IGRdouble  *) om$malloc(size = num_loops*sizeof(IGRdouble));

 if(!u_v_min || !u_v_max ) return(FALSE);

 for(i = 0; i < num_loops-1; i++)
 {
  min = loop_range[4*i+U_V-1];
  max = loop_range[4*i+U_V+1];

  for(j = i+1; j < num_loops; j++)
  {
   next1 = 4*j+U_V-1;
   next2 = 4*j+U_V+1;
   if(loop_range[next1] <= min) /* */
   {
    if(loop_range[next2] >= max)
    {
     valid_ranges [ i ]  = FALSE;
     break ;
    }
    else 
    if((min <= loop_range[next2]) && (loop_range[next2] <= max))
    {
     valid_ranges[i] = FALSE;
     loop_range[next2] = max;
     break ;
    }
   } /* */
   else 
   { /* * */
    if(loop_range[next2] <= max)
    {
     valid_ranges[i] = FALSE;
     loop_range[next1] = min;
     loop_range[next2] = max;
     break ;
    }
    else 
    if((min <= loop_range[next1]) && (loop_range[next1] <= max))
    {
     valid_ranges[i] = FALSE;
     loop_range[next1] = min;
     break;
    }
   } /* * */
  } /* inner for loop */
 } /* outer for loop */

 num_coal  = 0 ;
 for(i = 0; i < num_loops; i++)
 {
  if(valid_ranges[i])
  {
   next1 = 4*i+U_V-1;
   next2 = 4*i+U_V+1;
   u_v_min[num_coal] = loop_range[next1];
   u_v_max[num_coal] = loop_range[next2];
   num_coal++;
  }
 }

 EFsortdouble(u_v_min,(IGRint)num_coal);
 EFsortdouble(u_v_max,(IGRint)num_coal);

 i = 0;
 min = u_v_min[0];
 max = u_v_max[num_coal-1];
 least_span = max-min;

 for(i = 1; i < num_coal; i++)
  if(1.0-u_v_min[i]+u_v_max[i-1] < least_span)
  {
   min = u_v_min[i];
   max = u_v_max[i-1];
   least_span = 1.0-min+max;
  }

 range[U_V-1] = min;
 range[U_V+1] = max;

 if(u_v_min) om$dealloc(ptr = u_v_min);
 if(u_v_max) om$dealloc(ptr = u_v_max);

 return (TRUE) ;
}




static void EFget_u_v_minmax(U_V,num_loops,loop_range,range)
IGRushort U_V;
IGRint num_loops;
IGRdouble *loop_range;
IGRdouble *range;
{
    IGRint i ;
    IGRdouble min , max ;

    range [ U_V  -1 ]  = MAXFLOAT;
    range [ U_V  +1 ]  = MINFLOAT;

    for ( i  = 0 ; i  <num_loops ; i ++ )
    {
        min  = loop_range [ 4  *i  +U_V  -1 ] ;
        max  = loop_range [ 4  *i  +U_V  +1 ] ;

        if ( min  <range [ U_V  -1 ] ) range [ U_V  -1 ]
             = min ;
        if ( max  >range [ U_V  +1 ] ) range [ U_V  +1 ]
             = max ;
    }
}




static IGRboolean EFmore_than_1half(U_V,num_loops,loop_range)
IGRushort U_V;
IGRint num_loops;
IGRdouble *loop_range;
{
    IGRint i ;

    for ( i  = 0 ; i  <num_loops ; i ++ )
    {
        if ( loop_range [ 4  *i  +U_V  +1 ]  >0.5 ) return (TRUE);
    }
    return (FALSE) ;
}



/* 
 NOTE : CALL THIS METHOD IFF YOU ARE SURE IT IS CONNECTED TO A SURFACE 
 ----
*/

method EMbounded_uv_range(
 IGRlong *EMmsg;
 IGRdouble *range;
 IGRdouble *area;
 IGRshort *across_seam;
 IGRint *split_ind;
 IGRdouble *mid_uv;
 IGRlong *loop_num;
  GRobjid **lp_ids;
 IGRdouble **lp_ranges)
{
 IGRlong OM_stat;
 IGRlong   mthd_stat;
 IGRint i, j;
 OMuint num_loops;
 IGRdouble  *loop_range, u_len, v_len;
 OMuword osnumaddr;
 OM_S_CHANSELECT ls_sf_chan, ls_lp_chan;

 struct IGRbsp_surface my_surf ;
 static IGRboolean *valid_u_range, *valid_v_range;

 OM_stat = OM_S_SUCCESS;
 *EMmsg  = EMS_S_Success;
  
 *across_seam   = NOT_ACROSS_SEAM;
 *split_ind     = SPLIT_BOTH;

 loop_range     = NULL;
 valid_u_range  = NULL;
 valid_v_range  = NULL;
 
 ls_lp_chan.type        = OM_e_addr ;
 ls_lp_chan.u_sel.addr  = &ME.EMSloopset->to_loops;

 OM_stat = om$get_channel_count(p_chanselect = &ls_lp_chan,
				objid 		 = my_id,
				count		 = &num_loops);
 EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
 EMerr_hndlr(!num_loops, *EMmsg, EMS_E_LoopError, wrapup);

 if(lp_ranges)
 {
  *loop_num  = num_loops;
  *lp_ranges =(IGRdouble *)om$malloc(size=num_loops*4*sizeof(IGRdouble));
  EMerr_hndlr(!*lp_ranges, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }

 if(lp_ids)
 {
  *lp_ids = (GRobjid *) om$malloc(size = num_loops*4*sizeof(GRobjid));
  EMerr_hndlr(!*lp_ids, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);
 }


 loop_range = (IGRdouble *) om$malloc(size=num_loops*4*sizeof(IGRdouble));
 valid_u_range=(IGRboolean *)om$malloc(size=num_loops*sizeof(IGRboolean));
 valid_v_range=(IGRboolean *)om$malloc(size=num_loops*sizeof(IGRboolean));
 EMerr_hndlr(!loop_range || !valid_u_range || !valid_v_range,
			 *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 for(i = 0; i < num_loops; i++)
 {
  valid_u_range[i] = TRUE;
  valid_v_range[i] = TRUE;
  OM_stat = om$send(msg = message EMSloop.EMgetrange(
							&mthd_stat,
							&loop_range[4*i]),
				    p_chanselect = &ls_lp_chan,
				    from 		= i,
				    to 			= i);
  EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_LoopError, wrapup);

  if(lp_ranges) OM_BLOCK_MOVE(&loop_range[4*i], &(*lp_ranges)[4*i],
							  4*sizeof(IGRdouble));
  if(lp_ids)
  {
   OM_stat = om$get_objid_at_index(objid = my_id,
								   p_chanselect = &ls_lp_chan,
                        		   index = i,
								   objidaddr = &(*lp_ids)[i],
								   osnumaddr = &osnumaddr);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
  }

  for(j = 0; j < 4; j++)
  {
   if(loop_range[4*i+j] < 0.0)loop_range[4*i+j] = 0.0;
   else 
   if(loop_range[4*i+j] > 1.0)loop_range[4*i+j] = 1.0;
  }
 }

  
 ls_sf_chan.type        = OM_e_addr ;
 ls_sf_chan.u_sel.addr  = &ME.EMSloopset->to_surface;

 OM_stat  = om$send(msg = message EMSsubbs.EMgetbsdef(
							&mthd_stat,
							&my_surf),
				    p_chanselect = &ls_sf_chan);
 EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);

 
 if(num_loops == 1)
 {
  range [ 0 ]  = loop_range [ 0 ] ;
  range [ 1 ]  = loop_range [ 1 ] ;
  range [ 2 ]  = loop_range [ 2 ] ;
  range [ 3 ]  = loop_range [ 3 ] ;
 }
 else 
 {
  if(!my_surf.u_phy_closed)
  {
   EFget_u_v_minmax(U,num_loops,loop_range,range);
  }
  else 
  {
   if(!EFmore_than_1half(U,num_loops,loop_range))
   {
    EFget_u_v_minmax(U,num_loops,loop_range,range);
   }
   else 
   {
    EMerr_hndlr(!EFget_u_v_range(U,num_loops,valid_u_range,loop_range,
 	              range),*EMmsg,EMS_E_DynamicMemoryAllocated,wrapup);
   } /* if loop's U max values are > 0.5 */
  } /* if surface closed in U */
  if(!my_surf.v_phy_closed)
  {
   EFget_u_v_minmax(V,num_loops,loop_range,range);
  }
  else 
  {
   if(!EFmore_than_1half(V,num_loops,loop_range))
   {
    EFget_u_v_minmax(V,num_loops,loop_range,range);
   }
   else 
   {
    EMerr_hndlr(!EFget_u_v_range(V,num_loops,valid_v_range,loop_range,
                  range),*EMmsg,EMS_E_DynamicMemoryAllocated, wrapup)
   } /* if loop's V max values are > 0.5 */
  } /* if surface closed in V */
 } /* if num_loops != 1 */


  u_len = range[2] - range[0];
  v_len = range[3] - range[1];

  if(range[0] > range[2])
  { 
    *across_seam |= ACROSS_SEAM_U;
	u_len = 1.0 - range[0] + range[2];
    mid_uv[0] = 0.0;
  }
  else
    mid_uv[0] = (  ( (range[2] - range[0]) /2.0) + range[0]  ); 

  if(range[1] > range[3])
  {
	*across_seam |= ACROSS_SEAM_V;
	v_len = 1.0 - range[1] + range[3];
    mid_uv[1] = 0.0;
  }
  else
    mid_uv[1] = (  ( (range[3] - range[1]) /2.0) + range[1]  );

  if((*across_seam & ACROSS_SEAM_U) && (*across_seam & ACROSS_SEAM_V))
  {
	*area = (1.0 - range[0]) * (1.0 - range[1])  +
				 (range[2] * range[3]);
  }
  else
  {
	*area = u_len * v_len;
  }

  if((range[0] == 0) && (range[2] == 1.0) )
   *split_ind = SPLIT_V;

  if((range[1] == 0) && (range[3] == 1.0) )
   *split_ind = SPLIT_U;

wrapup:

if ( loop_range )    om$dealloc(ptr = loop_range) ;
if ( valid_u_range ) om$dealloc(ptr = valid_u_range) ;
if ( valid_v_range ) om$dealloc(ptr =  valid_v_range) ;

EMWRAPUP(*EMmsg, OM_stat, "In EMSloopset.EMbounded_uv_range");
return (OM_stat) ;

}

end implementation EMSloopset;
