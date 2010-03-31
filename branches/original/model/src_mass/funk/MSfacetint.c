/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
	This function computes integrals needed for mass/area properties
	evaluation based on incoming surf_data structure

	option = 0	mass properties
	       = 1	all area properties
	       = 2	surface area only
*/

#include 	<stdio.h>
#include	"igrtypedef.h"
#include	"igr.h"
#include 	"emsmass.h"
#include	"wanginc.h"
#include 	"EMSlogic.h"


void MSfacetint(rc, surf_data, option, density, prop)

IGRlong			*rc;
struct BNsf_data	*surf_data;
IGRlong			option;
IGRdouble		*density;
IGRdouble		*prop;

{
  IGRlong		i, j, a_id, c_id, facet_id, patch_cnt;
  IGRdouble		loc_prop[NUMB_PROPS];
  IGRshort		*facet_map;
  struct BNpatch	*patch_data;
  struct Facetloop 	*loop_data;
  void			MSquadint(), MSloopint();

#define SOLID	1
#define	HOLE	0
#define BOUND	-1

  for(i = 0; i < NUMB_PROPS; i++)loc_prop[i] = 0.0;

  for(patch_cnt=0; patch_cnt < surf_data->n_pat; patch_cnt++)
   {
     patch_data = (struct BNpatch *)(surf_data->pat_ary[patch_cnt]);

     if(patch_data -> solid IS HOLE)	continue;	/* next patch */

/*   What's left are:
 *    wholly solids
 *    partial facets with loops in them
 */

     facet_map = patch_data->bit_map;

     facet_id = 0;
     a_id     = 0;
     c_id     = patch_data->nu;

     for(i = 0; i < patch_data->nv - 1; i ++)
      {
	for(j = 0; j < patch_data->nu - 1; j ++)
	 {
	   if( (patch_data->solid IS SOLID) OR
	       (facet_map[facet_id] IS SOLID) )
	    {
	      MSquadint(option, &patch_data->xyz_tp[a_id][0],   /* A */
				  &patch_data->xyz_tp[a_id+1][0], /* B */
				  &patch_data->xyz_tp[c_id][0],   /* C */
			  	  &patch_data->xyz_tp[c_id+1][0], /* D */
			  loc_prop);
	    }
	   facet_id ++;
	   a_id ++;
	   c_id ++;
	 }		/* for along_u */

/*	   a_id and c_id point to the last point of the row i
	   so make them point to the first point of the row i +1
*/
	a_id ++;	/* points to u=0 point */
	c_id ++;	/* points to u=0 point */

      }			/* for along_v */

/*
 *   All quad elements have been considered. Now consider
 *   the cases  with loops in them
 */

     if( NOT patch_data->n_loop) continue;	/* retrieve next patch */

     for(i = 0; i < patch_data->n_loop; i ++)
      {
	loop_data = (struct Facetloop *)&patch_data->fct_lp[i];
	
	MSloopint(option, loop_data->np, loop_data->xyz, loc_prop);

      }		/* for loop count */
   }		/* patch_cnt */

  if(option IS 0)	/* mass prop */
   {
     for(i = 1; i < 11; i ++) loc_prop[i] *= (*density);
   }

  for(i = 0; i < NUMB_PROPS; i++)prop[i] += loc_prop[i];

  return;

}
