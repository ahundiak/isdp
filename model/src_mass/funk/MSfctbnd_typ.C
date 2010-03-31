/* ###################   APOGEE COMPILED   ################## */
/*
	This function determines the boundary condition of a facet when it
    shares a natural boundary of the surface and/or shares the boundary of
    a patch and fills in the appro. data for facet_data.

    gupta   : 12/27/88   creation
 
*/

#include    "EMS.h"
#include	"igrtypedef.h"
#include 	"emsmass.h"
#include    "wanginc.h"

MSfacet_boundary_type(boundary_type, i_inx, j_inx, num_v, num_u,
                      patch_data, fct_data, quad_pnts, bastol, f_type)

IGRlong               boundary_type;
IGRint                *i_inx, *j_inx;
IGRint                num_v, num_u;
struct BNpatch        *patch_data;
struct EMfacet_data   *fct_data;
IGRdouble             quad_pnts[];
IGRdouble             bastol;
IGRint                *f_type;
{

IGRboolean            store_int_data;
extern IGRdouble      BSdistptpt();

/*-----------------------------------------------------------------*/

*f_type = ON_FACET_BND;

store_int_data = FALSE;

fct_data->num_bdrys = 0;
fct_data->num_int_bdry = 0;
fct_data->num_in_points = 0;
 
switch (boundary_type)
 {
 case  BND_V_ZERO_ONLY:

       if ((*i_inx == 0) && (*j_inx == 0))
        {
         if (num_u == 2)
          {
           fct_data->num_bdrys = 3;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->bdry_inx[2] = 0; fct_data->bdry_inx[3] = 1;
           fct_data->bdry_inx[4] = 1; fct_data->bdry_inx[5] = 2;
           fct_data->num_in_points = 0;
          }
         else
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->bdry_inx[2] = 0; fct_data->bdry_inx[3] = 1;
           fct_data->num_in_points = 1;
           fct_data->points_inx = 2;
          }
         if (num_v == 2) store_int_data = TRUE;
        }
       else if ((*i_inx == 0) && (*j_inx == num_u-2))
        {
         fct_data->num_bdrys = 2;
         fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
         fct_data->bdry_inx[2] = 1; fct_data->bdry_inx[3] = 2;
         fct_data->num_in_points = 1;
         fct_data->points_inx = 3;
        }
       else if ((*i_inx == 0) && (*j_inx > 0) && (*j_inx < num_u-2))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 2;
        }
       else if ((*i_inx > 0) && (*j_inx == 0))
        {
         if (num_u == 2)
          {
           fct_data->num_in_points = 0;
           fct_data->num_bdrys = 2;
           if (*i_inx == num_v-2)
            {
             fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
             fct_data->bdry_inx[2] = 1; fct_data->bdry_inx[3] = 2;
            }
           else
            {
             fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
             fct_data->bdry_inx[2] = 3; fct_data->bdry_inx[3] = 4;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 1;
          }
         if (*i_inx == num_v-2) store_int_data = TRUE;
        }
       else if ((*i_inx > 0) && (*j_inx == num_u-2))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         if (*i_inx == num_v-2) store_int_data = TRUE;
        }
       else if (*i_inx == num_v-2)
        {
         store_int_data = TRUE;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
        }
       else *f_type = NOT_ON_FACET_BND;
       if (store_int_data)
        {
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 2;
         fct_data->int_bdry_inx[1] = 3;
         fct_data->u_dir[0] = FALSE;
         fct_data->param[0] = patch_data->vd;
        }
       break;
 
 case  BND_V_ONE_ONLY:
 
       if ((*i_inx == num_v-2) && (*j_inx == 0))
        {
         if (num_u == 2)
          {
           fct_data->num_bdrys = 3;
           fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
           fct_data->bdry_inx[2] = 2; fct_data->bdry_inx[3] = 3;
           fct_data->bdry_inx[4] = 3; fct_data->bdry_inx[5] = 4;
           fct_data->num_in_points = 0;
          }
         else
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
           fct_data->bdry_inx[2] = 3; fct_data->bdry_inx[3] = 4;
           fct_data->num_in_points = 1;
           fct_data->points_inx = 1;
          }
         if (num_v == 2) store_int_data = TRUE;
        }
       else if ((*i_inx == num_v-2) && (*j_inx == num_u-2))
        {
         fct_data->num_bdrys = 2;
         fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
         fct_data->bdry_inx[2] = 2; fct_data->bdry_inx[3] = 3;
         fct_data->num_in_points = 1;
         fct_data->points_inx = 0;
        }
       else if ((*i_inx < num_v-2) && (*j_inx == 0))
        {
         if (num_u == 2)
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
           fct_data->bdry_inx[2] = 3; fct_data->bdry_inx[3] = 4;
           fct_data->num_in_points = 0;
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 1;
          }
         if (*i_inx == 0) store_int_data = TRUE;
        }
       else if ((*i_inx == num_v-2) && (*j_inx > 0) && (*j_inx < num_u-2))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
        }
       else if ((*i_inx < num_v-2) && (*j_inx == num_u-2))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         if (*i_inx == 0) store_int_data = TRUE;
        }
       else if (*i_inx == 0)
        {
         store_int_data = TRUE;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 2;
        }
       else *f_type = NOT_ON_FACET_BND;
       if (store_int_data)
        {
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 0;
         fct_data->int_bdry_inx[1] = 1;
         fct_data->u_dir[0] = FALSE;
         fct_data->param[0] = patch_data->vs;
        }
       break;

 case  BND_U_ZERO_ONLY:
 
       if ((*i_inx == 0) && (*j_inx == 0))
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 3;
           fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
           fct_data->bdry_inx[2] = 3; fct_data->bdry_inx[3] = 4;
           fct_data->bdry_inx[4] = 0; fct_data->bdry_inx[5] = 1;
           fct_data->num_in_points = 0;
          }
         else
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->bdry_inx[2] = 0; fct_data->bdry_inx[3] = 1;
           fct_data->num_in_points = 1;
           fct_data->points_inx = 2;
          }
         if (num_u == 2) store_int_data = TRUE;
        }
       else if ((*i_inx == 0) && (*j_inx > 0))
        {
         if (num_v == 2)
          {
           fct_data->num_in_points = 0;
           fct_data->num_bdrys = 2;
           if (*j_inx == num_u-2)
            {
             fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
             fct_data->bdry_inx[2] = 0; fct_data->bdry_inx[3] = 1;
            }
           else
            {
             fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
             fct_data->bdry_inx[2] = 2; fct_data->bdry_inx[3] = 3;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
          }
         if (*j_inx == num_u-2) store_int_data = TRUE;
        }
       else if ((*j_inx == 0) && (*i_inx > 0) && (*i_inx < num_v-2))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 1;
        }
       else if ((*i_inx == num_v-2) && (*j_inx > 0))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
         if (*j_inx == num_u-2) store_int_data = TRUE;
        }
       else if ((*i_inx == num_v-2) && (*j_inx == 0))
        {
         fct_data->num_bdrys = 2;
         fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
         fct_data->bdry_inx[2] = 3; fct_data->bdry_inx[3] = 4;
         fct_data->num_in_points = 1;
         fct_data->points_inx = 1;
        }
       else if (*j_inx == num_u-2)
        {
         store_int_data = TRUE;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
        }
       else *f_type = NOT_ON_FACET_BND;
       if (store_int_data)
        {
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 1;
         fct_data->int_bdry_inx[1] = 2;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->ud;
        }
       break;
 
 case  BND_U_ONE_ONLY:

       if ((*i_inx == 0) && (*j_inx == num_u-2))
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 3;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->bdry_inx[2] = 1; fct_data->bdry_inx[3] = 2;
           fct_data->bdry_inx[4] = 2; fct_data->bdry_inx[5] = 3;
           fct_data->num_in_points = 0;
          }
         else
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->bdry_inx[2] = 1; fct_data->bdry_inx[3] = 2;
           fct_data->num_in_points = 1;
           fct_data->points_inx = 3;
          }
         if (num_u == 2) store_int_data = TRUE;
        }
       else if ((*i_inx == num_v-2) && (*j_inx == num_u-2))
        {
         fct_data->num_bdrys = 2;
         fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
         fct_data->bdry_inx[2] = 2; fct_data->bdry_inx[3] = 3;
         fct_data->num_in_points = 1;
         fct_data->points_inx = 0;
        }
       else if ((*i_inx == 0) && (*j_inx < num_u-2))
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->bdry_inx[2] = 2; fct_data->bdry_inx[3] = 3;
           fct_data->num_in_points = 0;
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
          }
         if (*j_inx == 0) store_int_data = TRUE;
        }
       else if ((*i_inx == num_v-2) && (*j_inx < num_u-2))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
         if (*j_inx == 0) store_int_data = TRUE;
        }
       else if ((*i_inx > 0) && (*i_inx < num_v-2) && (*j_inx == num_u-2))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
        }
       else if (*j_inx == 0)
        {
         store_int_data = TRUE;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 1;
        }
       else *f_type = NOT_ON_FACET_BND;
       if (store_int_data)
        {
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 3;
         fct_data->int_bdry_inx[1] = 4;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->us;
        }
       break;

 case  BND_U_ZERO_U_ONE:

       if (*j_inx == 0)
        {
         if (num_u == 2)
          {
           fct_data->num_in_points = 0;
           fct_data->num_bdrys = 2;
           if (*i_inx == num_v-2)
            {
             fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
             fct_data->bdry_inx[2] = 1; fct_data->bdry_inx[3] = 2;
            }
           else
            {
             fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
             fct_data->bdry_inx[2] = 3; fct_data->bdry_inx[3] = 4;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 1;
          }
         if ((*i_inx == 0) || (*i_inx == num_v-2))store_int_data = TRUE;
        }
       else if (*j_inx == num_u-2)
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         if ((*i_inx == 0) || (*i_inx == num_v-2)) store_int_data = TRUE;
        }
       else if ((*i_inx == 0) || (*i_inx == num_v-2))
        {
         store_int_data = TRUE;
         fct_data->num_in_points = 2;
         if (*i_inx == 0)
             fct_data->points_inx = 2;
         else
             fct_data->points_inx = 0;
        }
       else *f_type = NOT_ON_FACET_BND;
       if (store_int_data)
        {
         if (*i_inx == 0)
          {
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 0;
           fct_data->int_bdry_inx[1] = 1;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vs;
          }
         else
          {
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 2;
           fct_data->int_bdry_inx[1] = 3;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vd;
          }
        }
       break;

 case  BND_V_ZERO_V_ONE:

       if (*i_inx == 0)
        {
         if (num_v == 2)
          {
           fct_data->num_in_points = 0;
           fct_data->num_bdrys = 2;
           if (*j_inx == num_u-2)
            {
             fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
             fct_data->bdry_inx[2] = 0; fct_data->bdry_inx[3] = 1;
            }
           else
            {
             fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
             fct_data->bdry_inx[2] = 2; fct_data->bdry_inx[3] = 3;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
          }
         if ((*j_inx == 0) || (*j_inx == num_u-2))store_int_data = TRUE;
        }
       else if (*i_inx == num_v-2)
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
         if ((*j_inx == 0) || (*j_inx == num_u-2)) store_int_data = TRUE;
        }
       else if ((*j_inx == 0) || (*j_inx == num_u-2))
        {
         store_int_data = TRUE;
         fct_data->num_in_points = 2;
         if (*j_inx == 0)
             fct_data->points_inx = 1;
         else
             fct_data->points_inx = 3;
        }
       else *f_type = NOT_ON_FACET_BND;
       if (store_int_data)
        {
         if (*j_inx == 0)
          {
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 3;
           fct_data->int_bdry_inx[1] = 4;
           fct_data->u_dir[0] = TRUE;
           fct_data->param[0] = patch_data->us;
          }
         else
          {
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 1;
           fct_data->int_bdry_inx[1] = 2;
           fct_data->u_dir[0] = TRUE;
           fct_data->param[0] = patch_data->ud;
          }
        }
       break;

 case  BND_ZERO_ZERO:

       if ((*i_inx == 0) && (*j_inx == 0))
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->bdry_inx[2] = 0; fct_data->bdry_inx[3] = 1;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 2;
           fct_data->int_bdry_inx[1] = 3;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vd;
          }
         else
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->bdry_inx[2] = 0; fct_data->bdry_inx[3] = 1;
           fct_data->num_in_points = 1;
           fct_data->points_inx = 2;
          }
        }
       else if ((*i_inx == 0) && (*j_inx > 0))
        {
         if (num_v == 2)
          {
           if (*j_inx == num_u-2)
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 1; fct_data->int_bdry_inx[1] = 2;
             fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
             fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
             fct_data->param[0] = patch_data->ud;
             fct_data->param[1] = patch_data->vd;
            }
           else
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 2;
             fct_data->int_bdry_inx[1] = 3;
             fct_data->u_dir[0] = FALSE;
             fct_data->param[0] = patch_data->vd;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
           if (*j_inx == num_u-2)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 3;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 1;
             fct_data->int_bdry_inx[1] = 2;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->ud;
            }
          }
        }
       else if ((*i_inx > 0) && (*j_inx == 0))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 1;
         if (*i_inx == num_v-2)
          {
           fct_data->num_in_points = 1;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 2;
           fct_data->int_bdry_inx[1] = 3;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vd;
          }
        }
       else if ((*i_inx == num_v-2) && (*j_inx == num_u-2))
        {
         fct_data->num_in_points = 1;
         fct_data->points_inx = 0;
         fct_data->num_int_bdry = 2;
         fct_data->int_bdry_inx[0] = 1; fct_data->int_bdry_inx[1] = 2;
         fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
         fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
         fct_data->param[0] = patch_data->ud;
         fct_data->param[1] = patch_data->vd;
        }
       else if ((*i_inx == num_v-2) && (*j_inx != num_u-2))
        { 
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 2;
         fct_data->int_bdry_inx[1] = 3;
         fct_data->u_dir[0] = FALSE;
         fct_data->param[0] = patch_data->vd;
        }
       else if (*j_inx == num_u-2)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 1;
         fct_data->int_bdry_inx[1] = 2;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->ud;
        }
       else *f_type = NOT_ON_FACET_BND;
       break;

 case  BND_ZERO_ONE:

       if ((*i_inx == num_v-2) && (*j_inx == 0))
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
           fct_data->bdry_inx[2] = 3; fct_data->bdry_inx[3] = 4;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 0;
           fct_data->int_bdry_inx[1] = 1;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vs;
          }
         else
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
           fct_data->bdry_inx[2] = 3; fct_data->bdry_inx[3] = 4;
           fct_data->num_in_points = 1;
           fct_data->points_inx = 1;
          }
        }
       else if ((*i_inx < num_v-2) && (*j_inx == 0))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 1;
         if (*i_inx == 0)
          {
           fct_data->num_in_points = 1;
           fct_data->points_inx = 2;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 0;
           fct_data->int_bdry_inx[1] = 1;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vs;
          }
        }
       else if ((*i_inx == num_v-2) && (*j_inx > 0))
        {
         if (num_v == 2)
          {
           if (*j_inx == num_u-2)
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
             fct_data->int_bdry_inx[2] = 1; fct_data->int_bdry_inx[3] = 2;
             fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
             fct_data->param[0] = patch_data->vs;
             fct_data->param[1] = patch_data->ud;
            }
           else
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 0;
             fct_data->int_bdry_inx[1] = 1;
             fct_data->u_dir[0] = FALSE;
             fct_data->param[0] = patch_data->vs;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 0;
           if (*j_inx == num_u-2)
            {
             fct_data->num_in_points = 1;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 1;
             fct_data->int_bdry_inx[1] = 2;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->ud;
            }
          }
        }
       else if ((*i_inx == 0) && (*j_inx == num_u-2))
        {
         fct_data->num_in_points = 1;
         fct_data->points_inx = 3;
         fct_data->num_int_bdry = 2;
         fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
         fct_data->int_bdry_inx[2] = 1; fct_data->int_bdry_inx[3] = 2;
         fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
         fct_data->param[0] = patch_data->vs;
         fct_data->param[1] = patch_data->ud;
        }
       else if ((*i_inx == 0) && (*j_inx != num_u-2))
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 2;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 0;
         fct_data->int_bdry_inx[1] = 1;
         fct_data->u_dir[0] = FALSE;
         fct_data->param[0] = patch_data->vs;
        }
       else if (*j_inx == num_u-2)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 1;
         fct_data->int_bdry_inx[1] = 2;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->ud;
        }
       else *f_type = NOT_ON_FACET_BND;
       break;

 case  BND_ONE_ONE:

       if ((*i_inx == num_v-2) && (*j_inx == num_u-2))
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
           fct_data->bdry_inx[2] = 2; fct_data->bdry_inx[3] = 3;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 0;
           fct_data->int_bdry_inx[1] = 1;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vs;
          }
         else
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
           fct_data->bdry_inx[2] = 2; fct_data->bdry_inx[3] = 3;
           fct_data->num_in_points = 1;
           fct_data->points_inx = 0;
          }
        }
       else if ((*i_inx == num_v-2) && (*j_inx < num_u-2))
        {
         if (num_v == 2)
          {
           if (*j_inx == 0)
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 3; fct_data->int_bdry_inx[1] = 4;
             fct_data->int_bdry_inx[2] = 0; fct_data->int_bdry_inx[3] = 1;
             fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
             fct_data->param[0] = patch_data->us;
             fct_data->param[1] = patch_data->vs;
            }
           else
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 0;
             fct_data->int_bdry_inx[1] = 1;
             fct_data->u_dir[0] = FALSE;
             fct_data->param[0] = patch_data->vs;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 0;
           if (*j_inx == 0)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 1;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 3;
             fct_data->int_bdry_inx[1] = 4;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->us;
            }
          }
        }
       else if ((*i_inx < num_v-2) && (*j_inx == num_u-2))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         if (*i_inx == 0)
          {
           fct_data->num_in_points = 1;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 0;
           fct_data->int_bdry_inx[1] = 1;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vs;
          }
        }
       else if ((*i_inx == 0) && (*j_inx == 0))
        {
         fct_data->num_in_points = 1;
         fct_data->points_inx = 2;
         fct_data->num_int_bdry = 2;
         fct_data->int_bdry_inx[0] = 3; fct_data->int_bdry_inx[1] = 4;
         fct_data->int_bdry_inx[2] = 0; fct_data->int_bdry_inx[3] = 1;
         fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
         fct_data->param[0] = patch_data->us;
         fct_data->param[1] = patch_data->vs;
        }
       else if ((*i_inx == 0) && (*j_inx != 0))
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 2;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 0;
         fct_data->int_bdry_inx[1] = 1;
         fct_data->u_dir[0] = FALSE;
         fct_data->param[0] = patch_data->vs;
        }
       else if (*j_inx == 0)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 1;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 3;
         fct_data->int_bdry_inx[1] = 4;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->us;
        }
       else *f_type = NOT_ON_FACET_BND;
       break;

 case  BND_ONE_ZERO:

       if ((*i_inx == 0) && (*j_inx == num_u-2))
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->bdry_inx[2] = 1; fct_data->bdry_inx[3] = 2;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 2;
           fct_data->int_bdry_inx[1] = 3;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vd;
          }
         else
          {
           fct_data->num_bdrys = 2;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->bdry_inx[2] = 1; fct_data->bdry_inx[3] = 2;
           fct_data->num_in_points = 1;
           fct_data->points_inx = 3;
          }
        }
       else if ((*i_inx == 0) && (*j_inx < num_u-2))
        {
         if (num_v == 2)
          {
           if (*j_inx == 0)
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
             fct_data->int_bdry_inx[2] = 3; fct_data->int_bdry_inx[3] = 4;
             fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
             fct_data->param[0] = patch_data->vd;
             fct_data->param[1] = patch_data->us;
            }
           else
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 2;
             fct_data->int_bdry_inx[1] = 3;
             fct_data->u_dir[0] = FALSE;
             fct_data->param[0] = patch_data->vd;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
           if (*j_inx == 0)
            {
             fct_data->num_in_points = 1;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 3;
             fct_data->int_bdry_inx[1] = 4;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->us;
            }
          }
        }
       else if ((*i_inx > 0) && (*j_inx == num_u-2))
        {
         fct_data->num_bdrys = 1;
         fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         if (*i_inx == num_v-2)
          {
           fct_data->num_in_points = 1;
           fct_data->points_inx = 0;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 2;
           fct_data->int_bdry_inx[1] = 3;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vd;
          }
        }
       else if ((*i_inx == num_v-2) && (*j_inx == 0))
        {
         fct_data->num_in_points = 1;
         fct_data->points_inx = 1;
         fct_data->num_int_bdry = 2;
         fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
         fct_data->int_bdry_inx[2] = 3; fct_data->int_bdry_inx[3] = 4;
         fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
         fct_data->param[0] = patch_data->vd;
         fct_data->param[1] = patch_data->us;
        } 
       else if ((*i_inx == num_v-2) && (*j_inx != 0))
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 2;
         fct_data->int_bdry_inx[1] = 3;
         fct_data->u_dir[0] = FALSE;
         fct_data->param[0] = patch_data->vd;
        }
       else if (*j_inx == 0)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 1;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 3;
         fct_data->int_bdry_inx[1] = 4;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->us;
        } 
       else *f_type = NOT_ON_FACET_BND;
       break;

 case  BND_U_ZERO:

       if (*j_inx == 0)
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = FALSE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->vd;
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 3; fct_data->bdry_inx[1] = 4;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 1;
           if (*i_inx == 0)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 2;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 0;
             fct_data->int_bdry_inx[1] = 1;
             fct_data->u_dir[0] = FALSE;
             fct_data->param[0] = patch_data->vs;
            }   
           else if (*i_inx == num_v-2)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 1;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 2;
             fct_data->int_bdry_inx[1] = 3;
             fct_data->u_dir[0] = FALSE;
             fct_data->param[0] = patch_data->vd;
            }
          }
        }
       else if (*j_inx == num_u-2)
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 0;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 3;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 1; fct_data->int_bdry_inx[3] = 2;
           fct_data->int_bdry_inx[4] = 2; fct_data->int_bdry_inx[5] = 3;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
           fct_data->u_dir[2] = FALSE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->ud;
           fct_data->param[2] = patch_data->vd;
          }
         else
          {
           if (*i_inx == 0)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 3;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
             fct_data->int_bdry_inx[2] = 1; fct_data->int_bdry_inx[3] = 2;
             fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
             fct_data->param[0] = patch_data->vs;
             fct_data->param[1] = patch_data->ud;
            } 
           else if (*i_inx == num_v-2)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 0;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 1; fct_data->int_bdry_inx[1] = 2;
             fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
             fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
             fct_data->param[0] = patch_data->ud;
             fct_data->param[1] = patch_data->vd;
            }
           else
            {
             fct_data->num_in_points = 2;
             fct_data->points_inx = 3;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 1; fct_data->int_bdry_inx[1] = 2;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->ud;
            }
          }
        }
       else if (*i_inx == 0)
        {
         if ((num_v == 2) && (*j_inx > 0))
          {
           fct_data->num_bdrys = 0;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = FALSE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->vd;
          }
         else
          {
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vs;
          }
        }
       else if (*i_inx == num_v-2)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
         fct_data->u_dir[0] = FALSE;
         fct_data->param[0] = patch_data->vd;
        }
       else *f_type = NOT_ON_FACET_BND;
       break;

 case  BND_U_ONE:

       if (*j_inx == num_u-2)
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
           fct_data->int_bdry_inx[2] = 0; fct_data->int_bdry_inx[3] = 1;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = FALSE;
           fct_data->param[0] = patch_data->vd;
           fct_data->param[1] = patch_data->vs;
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 1; fct_data->bdry_inx[1] = 2;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 3;
          if (*i_inx == 0)
           {
            fct_data->num_in_points = 1;
            fct_data->num_int_bdry = 1;
            fct_data->int_bdry_inx[0] = 0;
            fct_data->int_bdry_inx[1] = 1; 
            fct_data->u_dir[0] = FALSE;
            fct_data->param[0] = patch_data->vs;
           } 
          else if (*i_inx == num_v-2)
           {
            fct_data->num_in_points = 1;
            fct_data->points_inx = 0;
            fct_data->num_int_bdry = 1;
            fct_data->int_bdry_inx[0] = 2;
            fct_data->int_bdry_inx[1] = 3;
            fct_data->u_dir[0] = FALSE;
            fct_data->param[0] = patch_data->vd;
           }
         }
        }
       else if (*j_inx == 0)
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 0;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 3;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
           fct_data->int_bdry_inx[4] = 3; fct_data->int_bdry_inx[5] = 4;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = FALSE;
           fct_data->u_dir[2] = TRUE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->vd;
           fct_data->param[2] = patch_data->us;
          }
         else
          {
           if (*i_inx == 0)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 2;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 3; fct_data->int_bdry_inx[1] = 4;
             fct_data->int_bdry_inx[2] = 0; fct_data->int_bdry_inx[3] = 1;
             fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
             fct_data->param[0] = patch_data->us;
             fct_data->param[1] = patch_data->vs;
            } 
           else if (*i_inx == num_v-2)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 1;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
             fct_data->int_bdry_inx[2] = 3; fct_data->int_bdry_inx[3] = 4;
             fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
             fct_data->param[0] = patch_data->vd;
             fct_data->param[1] = patch_data->us;
            }
           else
            {
             fct_data->num_in_points = 2;
             fct_data->points_inx = 1;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 3; fct_data->int_bdry_inx[1] = 4;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->us;
            }
          }
        }
       else if (*i_inx == 0)
        {
         if ((num_v == 2) && (*j_inx > 0))
          {
           fct_data->num_bdrys = 0;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = FALSE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->vd;
          }
         else
          {
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vs;
          }
        }
       else if (*i_inx == num_v-2)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
         fct_data->u_dir[0] = FALSE;
         fct_data->param[0] = patch_data->vd;
        }
       else *f_type = NOT_ON_FACET_BND;
       break;

 case  BND_V_ZERO:

       if (*i_inx == 0)
        {
         if (num_v == 2)
          {
           if (*j_inx == 0)
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
             fct_data->int_bdry_inx[2] = 3; fct_data->int_bdry_inx[3] = 4;
             fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
             fct_data->param[0] = patch_data->vd;
             fct_data->param[1] = patch_data->us;
            }
           else if (*j_inx == num_u-2)
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 1; fct_data->int_bdry_inx[1] = 2;
             fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
             fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
             fct_data->param[0] = patch_data->ud;
             fct_data->param[1] = patch_data->vd;
            }
           else
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
             fct_data->u_dir[0] = FALSE;
             fct_data->param[0] = patch_data->vd;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 0; fct_data->bdry_inx[1] = 1;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
           if (*j_inx == 0)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 2;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 3;
             fct_data->int_bdry_inx[1] = 4;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->us;
            } 
           else if (*j_inx == num_u-2)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 3;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 1;
             fct_data->int_bdry_inx[1] = 2;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->ud;
            }
          }
        }
       else if (*i_inx == num_v-2)
        {
         if (*j_inx == 0)
          {
           fct_data->num_in_points = 1;
           fct_data->points_inx = 1;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
           fct_data->int_bdry_inx[2] = 3; fct_data->int_bdry_inx[3] = 4;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
           fct_data->param[0] = patch_data->vd;
           fct_data->param[1] = patch_data->us;
          } 
         else if (*j_inx == num_u-2)
          {
           fct_data->num_in_points = 1;
           fct_data->points_inx = 0;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 1; fct_data->int_bdry_inx[1] = 2;
           fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
           fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
           fct_data->param[0] = patch_data->ud;
           fct_data->param[1] = patch_data->vd;
          }
         else
          {
           fct_data->num_in_points = 2;
           fct_data->points_inx = 0;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vd;
          }
        }
       else if (*j_inx == 0)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 1;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 3; fct_data->int_bdry_inx[1] = 4;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->us;
        }
       else if (*j_inx == num_u-2)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 1; fct_data->int_bdry_inx[1] = 2;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->ud;
        }
       else *f_type = NOT_ON_FACET_BND;
       break;

 case  BND_V_ONE:

       if (*i_inx == num_v-2)
        {  
         if (num_v == 2)
          {
           if (*j_inx == 0)
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 3; fct_data->int_bdry_inx[1] = 4;
             fct_data->int_bdry_inx[2] = 0; fct_data->int_bdry_inx[3] = 1;
             fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
             fct_data->param[0] = patch_data->us;
             fct_data->param[1] = patch_data->vs;
            }
           else if (*j_inx == num_u-2)
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 2;
             fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
             fct_data->int_bdry_inx[2] = 1; fct_data->int_bdry_inx[3] = 2;
             fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
             fct_data->param[0] = patch_data->vs;
             fct_data->param[1] = patch_data->ud;
            }
           else
            {
             fct_data->num_bdrys = 1;
             fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
             fct_data->num_in_points = 0;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
             fct_data->u_dir[0] = FALSE;
             fct_data->param[0] = patch_data->vs;
            }
          }
         else
          {
           fct_data->num_bdrys = 1;
           fct_data->bdry_inx[0] = 2; fct_data->bdry_inx[1] = 3;
           fct_data->num_in_points = 2;
           fct_data->points_inx = 0;
           if (*j_inx == 0)
            {
             fct_data->num_in_points = 1;
             fct_data->points_inx = 1;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 3;
             fct_data->int_bdry_inx[1] = 4;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->us;
            } 
           else if (*j_inx == num_u-2)
            {
             fct_data->num_in_points = 1;
             fct_data->num_int_bdry = 1;
             fct_data->int_bdry_inx[0] = 1;
             fct_data->int_bdry_inx[1] = 2;
             fct_data->u_dir[0] = TRUE;
             fct_data->param[0] = patch_data->ud;
            }
          }
        }
       else if (*i_inx == 0)
        {
         if (*j_inx == 0)
          {
           fct_data->num_in_points = 1;
           fct_data->points_inx = 2;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 3; fct_data->int_bdry_inx[1] = 4;
           fct_data->int_bdry_inx[2] = 0; fct_data->int_bdry_inx[3] = 1;
           fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
           fct_data->param[0] = patch_data->us;
           fct_data->param[1] = patch_data->vs;
          } 
         else if (*j_inx == num_u-2)
          {
           fct_data->num_in_points = 1;
           fct_data->points_inx = 3;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 1; fct_data->int_bdry_inx[3] = 2;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->ud;
          }
         else
          {
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vs;
          }
        }
       else if (*j_inx == 0)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 1;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 3; fct_data->int_bdry_inx[1] = 4;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->us;
        }
       else if (*j_inx == num_u-2)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 1; fct_data->int_bdry_inx[1] = 2;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->ud;
        }
       else *f_type = NOT_ON_FACET_BND;
       break;

   default:

       if ((*i_inx == 0) && (*j_inx == 0)) 
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 0;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 3;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
           fct_data->int_bdry_inx[4] = 3; fct_data->int_bdry_inx[5] = 4;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = FALSE;
           fct_data->u_dir[2] = TRUE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->vd;
           fct_data->param[2] = patch_data->us;
          }
         else
          {
           fct_data->num_in_points = 1;
           fct_data->points_inx = 2;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 3; fct_data->int_bdry_inx[1] = 4;
           fct_data->int_bdry_inx[2] = 0; fct_data->int_bdry_inx[3] = 1;
           fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
           fct_data->param[0] = patch_data->us;
           fct_data->param[1] = patch_data->vs;
          }
        }
       else
       if ((*i_inx == 0) && (*j_inx == num_u-2)) 
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 0;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 3;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 1; fct_data->int_bdry_inx[3] = 2;
           fct_data->int_bdry_inx[4] = 2; fct_data->int_bdry_inx[5] = 3;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
           fct_data->u_dir[2] = FALSE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->ud;
           fct_data->param[2] = patch_data->vd;
          }
         else
          {
           fct_data->num_in_points = 1;
           fct_data->points_inx = 3;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 1; fct_data->int_bdry_inx[3] = 2;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->ud;
          }  
        }
       else
       if ((*i_inx == num_v-2) && (*j_inx == 0)) 
        {
         fct_data->num_in_points = 1;
         fct_data->points_inx = 1;
         fct_data->num_int_bdry = 2;
         fct_data->int_bdry_inx[0] = 2; fct_data->int_bdry_inx[1] = 3;
         fct_data->int_bdry_inx[2] = 3; fct_data->int_bdry_inx[3] = 4;
         fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = TRUE;
         fct_data->param[0] = patch_data->vd;
         fct_data->param[1] = patch_data->us;
        }
       else
       if ((*i_inx == num_v-2) && (*j_inx == num_u-2)) 
        {
         fct_data->num_in_points = 1;
         fct_data->points_inx = 0;
         fct_data->num_int_bdry = 2;
         fct_data->int_bdry_inx[0] = 1; fct_data->int_bdry_inx[1] = 2;
         fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
         fct_data->u_dir[0] = TRUE; fct_data->u_dir[1] = FALSE;
         fct_data->param[0] = patch_data->ud;
         fct_data->param[1] = patch_data->vd;
        }
       else
       if (*i_inx == 0)
        {
         if (num_v == 2)
          {
           fct_data->num_bdrys = 0;
           fct_data->num_in_points = 0;
           fct_data->num_int_bdry = 2;
           fct_data->int_bdry_inx[0] = 0; fct_data->int_bdry_inx[1] = 1;
           fct_data->int_bdry_inx[2] = 2; fct_data->int_bdry_inx[3] = 3;
           fct_data->u_dir[0] = FALSE; fct_data->u_dir[1] = FALSE;
           fct_data->param[0] = patch_data->vs;
           fct_data->param[1] = patch_data->vd;
          }
         else
          {
           fct_data->num_in_points = 2;
           fct_data->points_inx = 2;
           fct_data->num_int_bdry = 1;
           fct_data->int_bdry_inx[0] = 0;
           fct_data->int_bdry_inx[1] = 1;
           fct_data->u_dir[0] = FALSE;
           fct_data->param[0] = patch_data->vs;
          }
        }
       else
       if (*i_inx == num_v-2)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 0;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 2;
         fct_data->int_bdry_inx[1] = 3;
         fct_data->u_dir[0] = FALSE;
         fct_data->param[0] = patch_data->vd;
        }
       else
       if (*j_inx == 0)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 1;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 3;
         fct_data->int_bdry_inx[1] = 4;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->us;
        }
       else
       if (*j_inx == num_u-2)
        {
         fct_data->num_in_points = 2;
         fct_data->points_inx = 3;
         fct_data->num_int_bdry = 1;
         fct_data->int_bdry_inx[0] = 1;
         fct_data->int_bdry_inx[1] = 2;
         fct_data->u_dir[0] = TRUE;
         fct_data->param[0] = patch_data->ud;
        }
       else
         *f_type = NOT_ON_FACET_BND;

 } /* switch */
 
 return;
}
