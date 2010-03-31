

/********

Description

   Header to define additional surface data 
   
History :  created 20/09/94  - HOB                                     *****/


struct HDbd_ext_inf
{
   struct GRlc_info     base_srf;        /*  base surface main inf  */
   struct GRlc_info     ib_crv;          /*  internal blend curve main inf  */
   struct GRlc_info     pb_point_s;      /*  partial blend startpoint main inf  */
   struct GRlc_info     pb_point_e;      /*  partial blend endpoint main inf  */
   IGRvector            dir_vec[2];      /*  collar direction vector  */  
   IGRint               col_dir;         /*  collar direction number  */

};



struct HDbd_wrk_par
{    
    IGRint              cv_flag;
    IGRint              cont;
    IGRint              tangent_flag;
    IGRdouble           ratio;
    IGRdouble           par_iso;
    IGRdouble           par_cv[2];
    IGRint              dir_flag;
    IGRvector           dir_vec[2];
    IGRint              approx_flag;
    IGRdouble           approx_fact;
};


#define                  MAX_BLEND_ORDER    7
#define                  MAX_BLEND_POLES    7
#define                  MAX_BLEND_KNOTS    14   

