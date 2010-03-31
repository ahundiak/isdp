/*******    name   EFget_sf_rows

Description

   Math routine to extract rows from a B-spline surface as B-spline curves.

History :  created 05/01/94  - GEB

Parameter description
 bound                INPUT            indicates the boundary
                                       := 1 for v=min
                                          2     u=min
                                          3     v=max
                                          4     u=max
 dir_par                               :>=0 row as a B-spline curve shall be
                                            in parameter direction
                                       else in opposite direction
 num_row                               := n the n'th one, counted from bound
                                       0,1,2 ...
 *surface                              the-spline surface struct 
 *row                                  the row as a B-spline
 *rc                  OUTPUT           The return code.
                                       BSSUCC if success.
   
Notes
   The caller must allocate memory for row.

************************************************************************/

   #include  <stdio.h> 
   #include  <math.h>
   
   #include  "igrtypedef.h"

   #include  "bs.h"
   #include  "bserr.h"
   #include  "bstypes.h"
   #include  "bsdefs.h"
   #include  "bsparameters.h"


   #define   ONE 1.0


   IGRint EFget_sf_rows  ( IGRint                      bound,
                           IGRint                      dir_par,
                           IGRint                      num_row,
                           struct IGRbsp_surface       *surface,
                           struct IGRbsp_curve         *row,
                           BSrc                        *rc          )
   {


     IGRint  status;

     IGRlong  j, k, jj, jw, jp, jk;
     IGRlong  jj0, jw0;
     IGRlong  incrjj, incrjw;
     
     IGRlong u_num_pl, v_num_pl, num_poles;
     IGRlong u_num_kn, v_num_kn;
     IGRlong nrow;
     
     IGRint  u_order, v_order;


     

/*********     Start of executable code       *******************/

     *rc = BSSUCC;
     status = 1;
     if ( bound < 0 || bound > 4 )
        {
         *rc = BSINARG;
         goto wrapup; 
        }          

     row->rational = surface->rational;
     u_num_pl =  surface->u_num_poles; 
     v_num_pl =  surface->v_num_poles; 
     u_num_kn =  surface->u_num_knots; 
     v_num_kn =  surface->v_num_knots; 
     u_order  =  surface->u_order; 
     v_order  =  surface->v_order; 

     if ( bound == 2 || bound ==4 )
        {
         if ( num_row >= u_num_pl )
            {
             *rc = BSINARG;
             goto wrapup; 
            } 
         num_poles  = v_num_pl;         
         row->order = v_order;
         row->num_poles = v_num_pl;
         row->num_knots = v_num_kn;
         if ( bound == 2 )
            nrow = num_row;
         else
            nrow = u_num_pl - num_row - 1;

         if (dir_par >= 0)
            {
             jj0    = 3*nrow;
             jw0    = nrow;
             incrjj = 3*u_num_pl;
             incrjw = u_num_pl;
             for ( j = 0; j < v_num_kn; j++ )
                 row->knots[j] = surface->v_knots[j];
            }
         else
            {
             jj0    = 3*(nrow + u_num_pl*(v_num_pl - 1));
             jw0    = nrow + u_num_pl*(v_num_pl - 1);
             incrjj = -3*u_num_pl;
             incrjw = -u_num_pl;
             for ( j = 0, jk = v_num_kn - 1; j < v_num_kn; j++, jk-- )
                 row->knots[jk] = ONE - surface->v_knots[j];
            }
        }
       else
        {
         num_poles = u_num_pl;          
         row->order = u_order;
         row->num_poles = u_num_pl;
         row->num_knots = u_num_kn;
         if ( bound == 1 )
            nrow = num_row;
         else
            nrow = v_num_pl - num_row - 1;

         if (dir_par >= 0)
            {
             jj0    = 3*u_num_pl*nrow;
             jw0    = u_num_pl*nrow;
             incrjj = 3;
             incrjw = 1;
             for ( j = 0; j < u_num_kn; j++ )
                 row->knots[j] = surface->u_knots[j];
            }
         else
            {
             jj0    = 3*(u_num_pl*nrow + u_num_pl - 1);
             jw0    = u_num_pl*nrow + u_num_pl - 1;
             incrjj = -3;
             incrjw = -1;
             for ( j = 0, jk = u_num_kn - 1; j < u_num_kn; j++, jk-- )
                 row->knots[jk] = ONE - surface->u_knots[j];
            }
        }


     for ( j = 0, jp = 0, jj = jj0; j < num_poles; j++, jj = jj + incrjj )
          for ( k = 0; k < 3; k++, jp++)
              row->poles[jp] = surface->poles[jj + k];
     
     if ( row->rational )
         for ( j = 0, jw = jw0; j < num_poles; j++ ,jw = jw + incrjw )
              row->weights[j] = surface->weights[jw];


     status = 0;

     row->planar = FALSE;
     row->phy_closed = FALSE;
     row->periodic = FALSE;
     row->non_uniform = FALSE;
     row->num_boundaries = 0;


     wrapup: 
     return status; 

            
   } 
