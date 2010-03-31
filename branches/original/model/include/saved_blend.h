

/********

Description

   Structure to define all parameters to rebuild an older blend surface 

 ********/

struct saved_blend
{

   struct GRlc_info    surface1;
   struct GRlc_info    curve1;
   IGRint              cv_flag1;
   IGRint              cont1;
   IGRint              approx_flag1;
   IGRdouble           approx_fact1;
   IGRint              tangent_flag1;
   IGRdouble           ratio1;
   IGRdouble           par_iso1;
   IGRdouble           par_cv1[2];
   IGRint              dir_flag1;
   IGRvector           dir_vec1[2];
   struct GRlc_info    p_point1s;
   struct GRlc_info    p_point1e;

   struct GRlc_info    surface2;
   struct GRlc_info    curve2;       
   IGRint              cv_flag2;
   IGRint              cont2;
   IGRint              approx_flag2;
   IGRdouble           approx_fact2;
   IGRint              tangent_flag2;
   IGRdouble           ratio2;
   IGRdouble           par_iso2;
   IGRdouble           par_cv2[2];
   IGRint              dir_flag2;
   IGRvector           dir_vec2[2];
   struct GRlc_info    p_point2s;       
   struct GRlc_info    p_point2e;       

   IGRint              blend_order;
   IGRint              blend_poles;
   IGRdouble           tolarr[3];
 
   IGRint              init_cv1_flag;
   IGRint              init_cv2_flag;

   IGRint              hd_index;        /*  hedgehog index  */
   IGRdouble           hd_cur_param;    /*  hedgehog param  */
};
