


/********

Description

   Headers for blend surface dynamic interface
   

History :  created 09/20/94  - HOB                                  *****/

 
struct HDbd_srf
{   	
    IGRint      exicrv;       

    IGRboolean  t_auto;
    IGRboolean  t_screen;
    IGRboolean  t_copy;
    IGRboolean  t_keyin;
    IGRdouble   t_sensi;
    IGRdouble   ratio;
    IGRshort    partial;

    IGRboolean  crv_u;
    IGRboolean  crv_v;
    IGRboolean  crv_ruled;
    IGRboolean  crv_vec_s;
    IGRboolean  crv_vec_d;
    IGRboolean  crv_perp;

    IGRint      curv_c;
    IGRdouble   approx;
};


/*  Modify Form interface data structure  */
struct HDbd_form_sf_p
{    
    struct HDbd_srf  HDbd_srf1;
    struct HDbd_srf  HDbd_srf2;
    IGRint           HDbd_undo;
    IGRint           HDbd_undolm;
    IGRboolean       HDbd_accept;
    IGRint           HDbd_mode;
    IGRint           HDbd_diagnos;
    IGRint           HDbd_srf_twist;
    IGRdouble        HDbd_minrad;
    IGRint           HDbd_order;
    IGRint           HDbd_poles;
    IGRint           HDbd_symmetric;
};


