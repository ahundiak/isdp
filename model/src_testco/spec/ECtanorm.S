/* ###################   APOGEE COMPILED   ################## */
/*
ABSTRACT

This Command Object outputs the tangents and normals of an
element at a single or a set of points, specified or implied by
the user.

HISTORY
    
15 May 1989 jBk Removed wakeup override.

SS  10/04/86 : Design Date
*/

class specification ECtanorm (1:0) of ECelement;

instance ECtanorm
   {
   IGRboolean elem_planar;
   IGRboolean tangent, normal, natural;
   IGRpoint dirpt;
   IGRpoint start_pt;   
   IGRboolean moveon;
   IGRlong u_num_pts, v_num_pts;
   struct GRparms start_parms, mid_parms, end_parms;
   IGRdouble len;
   };

override execute;

end specification ECtanorm;
