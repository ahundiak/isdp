/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bslink_include
# define bslink_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGR types */
# endif

# ifndef igr_include
#   include "igr.h" /* IGR types */
# endif

# ifndef bstypes_include
#   include "bstypes.h" /* BS types */
# endif

struct BSin_link
{
   IGRshort   chk_flag;     /* Flag indicating if points, parameters, or
                               both are to be criteria for linking:
                                 0) points
                                 1) parameters
                                 2) both   */
   IGRint     num_pairs;    /* Number of pairs of points or parameters */
   IGRpoint   *pts;         /* Array of start and end points to be linked.
                               The even-indexed pts should be the start points
                               and odd-indexed pts should be the end points.
                                 Example:
                                   pts[0] = start point of 1st pair
                                   pts[1] = end point of 1st pair

                                   pts[2] = start point of 2nd pair  
                                   pts[3] = end point of 2nd pair    
                          
                               Dimension of pts array should be 2*num_pairs.
                               If only parameters are to be checked, ALWAYS
                               set pts = NULL!   */

   IGRshort  sf_flag;      /* Flag indicating if parameters of 0, 1, or 2
                              surfaces are to be considered for linking.  
                                 0) if only points are input 
                                 1) parameters of 1 surface are input
                                 2) parameters of 2 surfaces are input
                              This flag should correlate to chk_flag
                              as follows:
                                  chk_flag            correlating sf_flag
                                  ========            ===================
                                     0                        0
                                     1                     1 or 2
                                     2                     1 or 2
                           */

   BSpair    *pars1;       /* Array of start and end uv parameters for 1st
                               surface.  If chk_flag = 1 or 2, this array
                               should ALWAYS be filled. If only points are
                               to be considered, ALWAYS set pars1 = NULL!
                               Dimension of pars1 array should be
                               4*num_pairs (uv for start and uv for end par) */

   BSpair    *pars2;       /* Array of start and end uv parameters for 2nd
                               surface if 2 surfaces are to be considered for
                               linking.  If only points are to be checked or
                               if only 1 surface is to be considered, ALWAYS
                               set pars2 = NULL!
                               Dimension of pars2 array should be
                               4*num_pairs (uv for start and uv for end par) */

   IGRshort   *lnk_flag;   /* Array of flags indicating if attempt to link
                               each point (or par) is desired. 
                               0: do not try to link this point with anything
                               1: try to link this point
                               Dimension of lnk_flag should be 2*num_pairs. */

   IGRdouble  par1_tol;    /* Parameter tolerance for surface 1.  Input
                               only if chk_flag = 1 or 2.  */
   IGRdouble  par2_tol;    /* Parameter tolerance for surface 2.  Input
                               only if chk_flag = 1 or 2 and 2 surfaces are
                               to be considered (i.e. pars2 != NULL).  */
   IGRdouble  dist_tol;    /* Distance tolerance.  Input only if chk_flag
                               = 0 or 2. */
   IGRdouble  u_stpar1;    /* Start u parameter of surface 1.  Input only
                               if chk_flag = 1 or 2. */
   IGRdouble  u_endpar1;   /* End u parameter of surface 1.  Input only
                               if chk_flag = 1 or 2. */
   IGRdouble  v_stpar1;    /* Start v parameter of surface 1.  Input only
                               if chk_flag = 1 or 2. */
   IGRdouble  v_endpar1;   /* End v parameter of surface 1.  Input only
                               if chk_flag = 1 or 2. */
   IGRdouble  u_stpar2;    /* Start u parameter of surface 2.  Input only
                               if chk_flag = 1 or 2 and 2 surfaces are to be
                               considered (i.e. pars2 != NULL). */
   IGRdouble  u_endpar2;   /* End u parameter of surface 2.  Input only
                               if chk_flag = 1 or 2 and 2 surfaces are to be 
                               considered (i.e. pars2 != NULL). */
   IGRdouble  v_stpar2;    /* Start v parameter of surface 2.  Input only
                               if chk_flag = 1 or 2 and 2 surfaces are to be
                               considered (i.e. pars2 != NULL). */
   IGRdouble  v_endpar2;   /* End v parameter of surface 2.  Input only
                               if chk_flag = 1 or 2 and 2 surfaces are to be 
                               considered (i.e. pars2 != NULL). */
};




struct BSout_link
{
   IGRint     num_grps;     /* Number of groups of points (pars) that can be
                               linked */
   IGRint     *num_per_grp; /* Array of number of pairs of points (pars) per 
                               link group.  The pairs of points are the start
                               and end points of "things" to be linked that 
                               correspond to the input points (pts) in
                               BSin_link structure */
   IGRint     *order_ind;   /* Array containing index of the input points 
                               (pars) sorted in order of linkage. Number of
                               elements = num_per_grp[0] + num_per_grp[1] + 
                               ... num_per_grp[num_grps-1] */
   IGRboolean *rev_ind;     /* Array of flags indicating if non-sorted start
                               and end input points (pars) need to be reversed.
                               Contains same number of elements as order_ind
                               array. */



   /* Example:

        input points:
          pts[2] = (1, 0, 0)  PAIR 0
          pts[3] = (2, 0, 0)

          pts[0] = (0, 0, 0)  PAIR 1
          pts[1] = (1, 0, 0)        

          pts[4] = (3, 0, 0)  PAIR 2
          pts[5] = (2, 0, 0)

          pts[6] = (4, 1, 0)  PAIR 3
          pts[7] = (4, 2, 0)

          pts[8] = (4, 3, 0)  PAIR 4
          pts[9] = (4, 2, 0)

          pts[10] = (4, 4, 0) PAIR 5
          pts[11] = (4, 3, 0)


        output with linking based on distance:
          num_grps = 2

          num_per_grp[0] = 3     
          num_per_grp[1] = 3 


                              GROUP 1
          order_ind[0] = 1                rev_ind[0] = 0
          order_ind[1] = 0                rev_ind[1] = 0
          order_ind[2] = 2                rev_ind[2] = 1

          order_ind[3] = 3    GROUP 2     rev_ind[3] = 0
          order_ind[4] = 4                rev_ind[4] = 1
          order_ind[5] = 5                rev_ind[5] = 1


          The input points can be linked into 2 groups with each group
          containing 3 "things" (probably curves ) defined by a start and
          end point (parameter).  
             GROUP 1 is defined as follows:
                PAIR 1 is 1st in linking order -- no reversing
                PAIR 0 is 2nd -- no reversing
                PAIR 2 is 3rd -- needs reversing 

             GROUP 2 is defined as follows:
                PAIR 3 is 1st in linking order -- no reversing
                PAIR 4 is 2nd -- needs reversing
                PAIR 5 is 3rd -- needs reversing 


                                                  . (4,4,0)\
                                                  |         \
                                                  |          \    PAIR 5
                                                  |          /
                                                  |         /
                                      GROUP 2     . (4,3,0)/\
                                                  |          \
                                                  |           \   PAIR 4
                                                  |           /
                                                  |          /
                                                  . (4,2,0) /\
                                                  |           \
                                                  |            \
                                                  |            /  PAIR 3
                                                  |           /
                                                  . (4,1,0)  /


                       GROUP 1

            ._________._________._________.      
          (0,0,0)  (1,0,0)  (2,0,0)   (3,0,0)
             |        |        |        |
             |        \        /        |
             |        |\      /|        |
             |        | \    / |        |
             |        |  \  /  |        |
             \        /   \/   \        /
              \      /  PAIR 0  \      /
               \    /            \    /
                \  /              \  /
                 \/                \/
               PAIR 1            PAIR 2

*/


};


# endif /* bslink_include */
