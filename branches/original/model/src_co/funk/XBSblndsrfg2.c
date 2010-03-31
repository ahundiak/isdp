
/***************************************************************************

Copyright 1995, Intergraph Corporation. All rights reserved.

Name  

   BSblndsrfg2

Abstract
   Math routine to produce a B-spline surface, which blends two surfaces at
   there natural boundaries. The Blend is along iso-parametric curves G1
   or G2 continous. The Blend surface is one-segmented in the blend direction.

Synopsis
   void   BSblndsrfg2 ( *sf1, *sf2, boundary_flag, blend_pt_par, pariso, 
                        direction, tangent_flag, tangent_value, curvature_flag,
                        approx_fact, blend_order, tolarr[3], **surf_blnd, *rc ) 

   struct IGRbsp_surface               *sf1
   struct IGRbsp_surface               *sf2
   IGRint                              boundary_flag[2]
   IGRdouble                           blend_pt_par[2][2]
   IGRdouble                           pariso[2] 
   IGRint                              direction[2]
   IGRint                              tangent_flag[2]
   IGRdouble                           tangent_value[2]
   IGRint                              curvature_flag[2]
   IGRdouble                           approx_fact[2]
   IGRint                              blend_order
   IGRdouble                           tolarr[3]
   struct IGRbsp_surface               **surf_blnd
   IGRint                              *inform
   BSrc                                *rc


Input

   struct IGRbsp_surface  *sf1         The 1.surface on which the blending
                                       end condition exists.
   struct IGRbsp_surface  *sf2         The 2.surface on which the blending
                                       end condition exists.

   IGRint            boundary_flag     1: v=vmin boundary
                                       2: u=umin 
                                       3: v=vmax
                                       4: u=umax
                                       [0]  1.surface
                                       [1]  2.surface
 

   IGRdouble       blend_pt_par[2]     Start and end parameter of the 1.
                                       boundary (may be iso parametric
                                       curve of the surface).
                                       [0]  1.surface
                                       [1]  2.surface

   IGRdouble                pariso     The iso-parameter if
                                       boundary_flag == 1,2,3,4 
                                       may differ from 0.0 or 1.0 :
                                       blend at iso-curves not beeing 
                                       boundaries.
                                       [0]  1.surface
                                       [1]  2.surface

   IGRint               direction      >=0: direction pointing away from
                                            surface edge indicated by
                                            boundary_flag (used also for
                                            blends at inner iso-parametric
                                            curves)
                                       else opposite direction
                                       [0]  1.surface
                                       [1]  2.surface 

   IGRint         tangent_flag[2]      Tangent values 
                                       [0]  1.surface
                                       [1]  2.surface 
                                            
                                        <=0: No tangent value specified.
                                          1: Value relative to the surface
                                               derivative at *curve where blend
                                               starts (in blend direction). 
                                          2: Value is a factor, by which
                                               the length determined by the
                                               program is multiplied.
                                          -n: output cases 
                                              the value is related to the
                                              surface derivative, it is
                                              constant if approx_flag == 0
                                              a mean value otherwise

   IGRdouble     tangent_value[2]      Tangent value as specified by
                                       'tangent_flag'.

   IGRint       curvature_flag[2]      0: No curvature condition.    
                                       1: Curvature condition. 
                                       2: Curvature condition, factor
                                          for additional term specified
                                          (DDG = (tangent_value**2)*DDF
                                                  + curvature_value*DF) 
                                       [0]  1.surface
                                       [1]  2.surface
 
   IGRint          approx_flag[2]      0: exact (G1,G2)
                                       1: approximative 
                                       [0]  1.surface
                                       [1]  2.surface
 

   IGRdouble       approx_fact[2]      if (approx_flag > 0)
                                       a factor > 0
                                       0.0 corresponds to the exact  
                                       1.0             to fully approximative 
                                      >1.0 additional smoothing cross to 
                                           blend direction 
                                       [0]  1.surface
                                       [1]  2.surface
 

   blend_order                         order of blend surface in blend direction
                                       >2 and (>3 for curvature)
                                       <= cont1 + cont2 + 2

   tolarr[3]                           [0]  same point tolerance
                                       [1]  same angle tolerance
                                       [2]  degeneracy of derivatives

Output
   tangent_value
   **surf_blnd                         The blend surface.
   *inform                             Additional information for failing 
                                       0 if blend was generated.
                                       -1 ... -10  may be realized if
                                                   approx_flag is set
                                       -11 ... fatal, no allocation, ect.
   *rc                                 The return code.
                                       BSSUCC if blend was generated.
                                       BSFAIL else
   
Return Values
   NA

Index
   em

Keywords
   blend surface, geometrical continuety, G1, G2-continuety, B-spline surface,
   parameter blend

History :
         created                 Jan.12,1994 - G.Bollmann
         cosmetics for checkin
         and improvements        Sep.27,1994 - G.Bollmann
         final version           Jun.20,1995 - G.Bollmann
         especially with new rational blend
         dissolved struct        Jun.28,1995 - G.Bollmann
         and added parameter *inform

************************************************************************/
   
/* include - begin */

 #include  <stdio.h> 
 #include  <math.h>   
 #include  "maerr.h"  


 #include  "igrtypedef.h"

 #include  "bs.h"
 #include  "bserr.h"
 #include  "bstypes.h"
 #include  "bsdefs.h"
 #include  "bsparameters.h"
 #include  "bsstk.h"


 #include  "bsfreecv.h"   
 #include  "bsfreesf.h"   
 #include  "bscveval.h"       
 #include  "bsnodevals.h"
 #include  "bspartofcv.h"
 #include  "bspartofsf.h"
 #include  "bsmkcvscp.h"
 #include  "bsalloccv.h"
 #include  "bsallocsf.h"

 #include  "bsretrrow.h"
 #include  "bscrosseval.h" 
 #include  "bsblndctan.h"                 
 #include  "bslsqweccv.h"         
 
/* include - end */

/***************************************************************************
*
*                    BSblndsrf2 Routine
*
***************************************************************************/



 static void r_shBSblndsrfg2 ( IGRint cont,
                               IGRshort iord,
                               struct IGRbsp_curve *row[3],
                               IGRdouble mesh[3], 
                               IGRdouble tmesh[3],
                               IGRdouble sign,
                               IGRdouble beta1,
                               IGRdouble beta2,
                               IGRdouble *alfa0,
                               IGRdouble *alfa1,
                               IGRdouble *alfa2 );



 static void v_shBSblndsrfg2 ( IGRint cont,
                               IGRshort iord,
                               IGRdouble wg0,
                               IGRdouble wg1,
                               IGRdouble wg2,
                               IGRdouble mesh[3],
                               IGRdouble tmesh[3],
                               IGRdouble sign,
                               IGRdouble beta1,
                               IGRdouble beta2,
                               IGRdouble alfa0,
                               IGRdouble *alfa1,
                               IGRdouble *alfa2 );


 static void cpr3dvBSblndsrfg2 ( IGRboolean            rat,
                                 IGRint                cont,
                                 IGRshort              order,
                                 IGRdouble             mesh[3],
                                 IGRdouble             sign,
                                 IGRdouble             cp0[3],
                                 IGRdouble             cp1[3],
                                 IGRdouble             cp2[3],
                                 IGRdouble             wg0,
                                 IGRdouble             wg1,
                                 IGRdouble             wg2,
                                 IGRdouble             pt[3],
                                 IGRdouble             dpt[3],
                                 IGRdouble             ddpt[3]     );
 
  

 static void cptodvBSblndsrfg2 ( IGRint                dim,
                                 IGRint                cont,
                                 IGRshort              order,
                                 IGRdouble             mesh[3],
                                 IGRdouble             sign,
                                 IGRdouble             cp0[3],
                                 IGRdouble             cp1[3],
                                 IGRdouble             cp2[3],
                                 IGRdouble             pt[3],
                                 IGRdouble             dpt[3],
                                 IGRdouble             ddpt[3]     );
  


 static void dvtocpBSblndsrfg2 ( IGRint                dim,
                                 IGRint                cont,
                                 IGRdouble             mesh[3],
                                 IGRdouble             sign,
                                 IGRdouble             pt[3],
                                 IGRdouble             dpt[3],
                                 IGRdouble             ddpt[3], 
                                 IGRdouble             cp0[3],
                                 IGRdouble             cp1[3],
                                 IGRdouble             cp2[3]    );


 static void gccondBSblndsrfg2 ( IGRboolean            rat,
                                 IGRint                cont,
                                 IGRdouble             pt[4],
                                 IGRdouble             dpt[4],
                                 IGRdouble             ddpt[4],
                                 IGRdouble             beta[2],
                                 IGRdouble             alfa[3],
                                 IGRdouble             qt[4],
                                 IGRdouble             dqt[4],
                                 IGRdouble             ddqt[4]  );


 static void betadvBSblndsrfg2 ( IGRint                cont,
                                 IGRdouble             dpt[3],
                                 IGRdouble             ddpt[3],     
                                 IGRdouble             dqt[3],
                                 IGRdouble             ddqt[3],
                                 IGRdouble             *beta1,
                                 IGRdouble             *beta2    );
  


 static void pttoliBSblndsrfg2 ( IGRint                insw,
                                 IGRdouble             pt[3],
                                 IGRdouble             pt0[3],     
                                 IGRdouble             dpt[3],
                                 IGRdouble             qt[3]     );
  

 static void end_weigts_BSblndsrfg( IGRdouble wg_start,
                                    IGRdouble wg_end,
                                    IGRdouble wg_tol,
                                    struct IGRbsp_curve *curve   );


 

  void XBSblndsrfg2   ( struct IGRbsp_surface           *sf1,
                        struct IGRbsp_surface           *sf2,
                        IGRint                          boundary_flag[2],
                        IGRdouble                       blend_pt_par[2][2],
                        IGRdouble                       pariso[2], 
                        IGRint                          direction[2],
                        IGRint                          tangent_flag[2],
                        IGRdouble                       tangent_value[2],
                        IGRint                          curvature_flag[2],
                        IGRint                          approx_flag[2],
                        IGRdouble                       approx_fact[2],
                        IGRint                          blend_order,
                        IGRdouble                       tolarr[3],
                        struct IGRbsp_surface           **surf_blnd,
                        IGRint                          *inform,
                        BSrc                            *rc           )
 {

/* declaration - begin */

 
 #define   G1              1
 #define   G2              2
 #define   IZRO            0
 #define   IONE            1
 #define   ITWO            2
 #define   INCRWJ          1
 #define   INCRJJ          3
 #define   NON_RAT         FALSE

 #define   ZERO          0.0
 #define   ONE           1.0
 #define   NONE         -1.0
 #define   TWO           2.0
 #define   HALF          0.5

 #define   WEIGT_TOL     1e-10
 #define   SMOOTH_DEF    0.01
 #define   DST_POL_FAC   20.0

 #define   FAC_RED_WG    0.2

 #define   SQ(a)         (a*a)
 #define   ABS(x)        ((x) < 0 ? -(x) : (x))


 #define   INSW_TG_CR      2

 #define   DEG_TGA        -1
 #define   DEG_TGB        -2
 #define   DEG_TGAB       -3
 #define   DEG_DPT        -4
 #define   DEG_POLA       -5
 #define   DEG_POLB       -6
 #define   NO_MK_COMP     -11
 #define   NO_NODES       -12
 #define   NO_CROSS       -13
 #define   NO_PART        -14
 #define   NO_RETR        -15

 #define   NO_ALLOC       -21
 
 #define   SMOOTH_MIN      4
 #define   MAX_KNOTS_BL    12
 #define   MAX_NOD_DEF     100

  IGRint      side;
  IGRshort    nsmooth, calc_cross_curves;
  IGRdouble   smooth, smooth_rel_a, smooth_rel_b;

  IGRdouble   xl_edge_a, xl_edge_b; 
  IGRpoint    pta_old, ptb_old;
  IGRdouble   sig_tga, sig_tgb, sig_tg;
  IGRdouble   ratio1_min, ratio2_min;
  IGRdouble   ratio1_max, ratio2_max;
  IGRdouble   ratio1_rel, ratio2_rel;
  IGRdouble   tg_facta, tg_factb, cr_facta, cr_factb;
  IGRdouble   approx_facta, approx_factb;
  IGRdouble   approx_meana, approx_meanb;
  IGRdouble   dist_pt12, dist_sf12;
  IGRdouble   my1, my2;
  IGRdouble   lda1[MAX_NOD_DEF], ldb1[MAX_NOD_DEF];
  IGRdouble   mya1[MAX_NOD_DEF], myb1[MAX_NOD_DEF];
  IGRdouble   nodarr1[MAX_NOD_DEF];
  IGRpoint    cross_points1[6*MAX_NOD_DEF];
  IGRdouble   cross_wgs1[MAX_NOD_DEF];
  IGRdouble   *lda, *ldb,  *ldab, *mya, *myb, *myab, *nodarr;
  IGRpoint    *cross_points;
  IGRdouble   *cross_wgs;
  IGRshort    pfix[4], pder1[2];
  IGRshort    dim3 = 3, iord, i_row;
  IGRshort    num_fix = 0, num_der1 = 0, opt_der2 = 0, num_wgts = 0;
  IGRshort    opt_end = 0, opt_sm, pwgts[1];
  IGRdouble   deriv1[6], deriv2[6];
  IGRdouble   wgts[2], smfac;
  IGRdouble   wg0, wg1, wg2, wgab, wg_a, wg_b;
  IGRdouble   dpta_s[3], dpta_e[3], dptb_s[3], dptb_e[3];
  IGRpoint    pt_contr[6], pt_contr_s[6], pt_contr_e[6];
  IGRint      nod_insert, num_nod, num_poles_e;
  IGRlong     num_pt_lsq;
  IGRdouble   cr_mesh_sf1[3], cr_mesh_sf2[3];
  IGRdouble   cr_mesh_sfb1[3], cr_mesh_sfb2[3];
  IGRdouble   *cr_mesh_f, cr_mesh_b[3];
  IGRint      cont, cont1, cont2;
  IGRint      cv1_dir, cv2_dir;
  IGRshort    config;
  IGRshort    out_contr_pt;
  IGRdouble   par_cv1[2], par_cv2[2];
  IGRdouble   par1_trm_sf[2], par2_trm_sf[2], par3_trm_sf[2];
  IGRdouble   par_tr_cv1[3], par_tr_cv2[3];
  IGRdouble   par;
  IGRpoint    pta, ptb;   

  IGRvector   dpta, dptb, ddpta, ddptb;

  IGRdouble   dist_pole;
  IGRshort    pole_dega[2], pole_degb[2];
  IGRpoint    eval[2];

  IGRshort    edge_sf1_ord, edge_sf2_ord;
  IGRshort    tr_order, cr_order;
  IGRlong     edge_sf1_nump, edge_sf2_nump;
  IGRlong     tr_num_poles;
 
  IGRlong     blend_nump, cr_nump, blend_numk, cr_numk;
  IGRdouble   step_k, *cr_knots;

  IGRshort    blnd_u_order, blnd_v_order;
  IGRshort    dir_sf1_ord, dir_sf2_ord; 
  IGRshort    dir_tg_cv1, dir_tg_cv2;
  IGRshort    dir_rev_cv1, dir_rev_cv2; 
  IGRshort    tgflag1, tgflag2;
  IGRint      inswa_tg_fact, inswb_tg_fact;
  IGRint      inswa_tg_rel, inswb_tg_rel;
  IGRshort    u_order, v_order;
  IGRlong     u_num_poles, v_num_poles;
  IGRshort    num_bound;
  IGRlong     blnd_u_num_knots, blnd_v_num_knots;
  IGRdouble   blend_knots[MAX_KNOTS_BL];
  IGRlong     numk;
  IGRboolean  blnd_rat;
  IGRshort    blnd_num_bound = 0;
  IGRshort    row_num_bound = 0, row_rational;

  IGRint      bound1, bound2, split;
  IGRint      num_row;
  IGRint      iso1, iso2;

  IGRshort    i, j, k, l, i1 ,i2, i3;     
  IGRshort    jpol, l0, incr1, incr2;
  IGRdouble   qqsm[3], rrsm[3], ttsm[3]; 
  IGRdouble   *wp0, *wq0, *p0, *q0, *qq, *rr, *p_dummy; 
  IGRdouble   *wp1, *wq1, *p1, *q1; 
  IGRdouble   *wp2, *wq2, *p2, *q2; 
  IGRdouble   betarr[2], alfarr[3];
  IGRdouble   pdrv0[4], pdrv1[4], pdrv2[4];
  IGRdouble   qdrv0[4], qdrv1[4], qdrv2[4];
  IGRdouble   row_wgts[6], row_wgte[6];

  IGRboolean  dealloc;
  IGRdouble   *workarea;
  IGRint      size;   
  IGRint      s_nodes, s_lda, s_ldb, s_mya, s_myb, s_cross_pts, s_cross_wgs; 


  IGRdouble   beta1c_a, beta1c_b, beta2c_a, beta2c_b;
  IGRdouble   alfa0c_a, alfa0c_b;
  IGRdouble   alfa1c_a, alfa1c_b, alfa2c_a, alfa2c_b;
  IGRdouble   beta1, beta2;
  
  struct IGRbsp_curve *row[6];        /* contol point rows */  
  struct IGRbsp_curve *row_cp[6];     /* after making rows compatible */  
  struct IGRbsp_curve *row_tr[6];     /* after trimming rows */  
  struct IGRbsp_curve *row_sm[2];     /* for cross-smoothing */  

  struct IGRbsp_surface *blndsrf; 
  struct IGRbsp_surface *sf1_trm, *sf2_trm;  

  BSrc   rc_c;
/* declaration - end */


/*****************************************************************************
*
*                       Start of executable code
*
*****************************************************************************/ 


/*  make compiler happy  */
  lda = ldb = mya = myb = NULL;
  wg0 = wg1 = wg2 = wgab = ONE;
  wp0 = &wg0; wp1 = &wg1; wp2 = &wg2;
  p2 = NULL; 
  p_dummy = NULL;
  rr = NULL;
  beta1c_a = beta1c_b = beta2c_a = beta2c_b = NULL;
  q2 = NULL;
  wq0 = wq1 = wq2 = NULL;
  *rc = BSFAIL;
  *inform = DEG_DPT; 
  cross_points = NULL;
  cross_wgs = NULL;
  workarea = NULL;

  dealloc = FALSE;

  sf1_trm = sf2_trm = NULL;
  for ( i=0; i<6; i++) { row[i] = row_cp[i] = row_tr[i] = NULL; }
  row_sm[0] = row_sm[1] = NULL;
  blndsrf = NULL;

  dir_rev_cv1 = dir_rev_cv2 = 1;
  ratio1_min = ratio1_max = ratio2_min = ratio2_max = ONE;
  approx_meana = approx_meanb = ZERO;
  smooth_rel_a = smooth_rel_b = ONE; 
  nod_insert = 0;

  i3 = 0;
  iord = 0;
  dist_pt12 = dist_sf12 = ZERO;


  for ( j = 0; j < 3; j++ )
      { cr_mesh_sf1[j] = ONE; cr_mesh_sf2[j] = ONE; } 

  if ( curvature_flag[0] == 0)   cont1 = 1;
  else                               cont1 = 2;
  if ( curvature_flag[1] == 0)    cont2 = 1;
  else                               cont2 = 2;

  blend_nump = cont1 + cont2 + 2;
  blend_numk = blend_order + blend_nump;
  step_k = blend_nump - blend_order + 1;

  for ( j = 0; j < blend_numk; j++ )
  { 
      if      (j < blend_order) blend_knots[j] = ZERO;
      else if (j >= blend_nump) blend_knots[j] = ONE;
      else                      blend_knots[j] = (j - blend_order +1)/step_k;
  }

  cr_mesh_sfb1[0] = cr_mesh_sfb2[0] = 
            (blend_knots[blend_order] - blend_knots[1])/(blend_order-1);

  cr_mesh_sfb1[1] = cr_mesh_sfb2[1] = 
            (blend_knots[blend_order+1] - blend_knots[2])/(blend_order-1);

  cr_mesh_sfb1[2] = cr_mesh_sfb2[2] = 
            (blend_knots[blend_order+1] - blend_knots[1])/(blend_order-2);


  if (approx_flag[0] == 0)  approx_facta = ZERO;
  else
     { 
      approx_facta = approx_fact[0];
      if (approx_facta < ZERO) approx_facta = ZERO;
      if (approx_facta > ONE)
         {
          smooth_rel_a = approx_facta; 
          approx_facta = ONE;
         }
     }

  if (approx_flag[1] == 0)  approx_factb = ZERO;
  else
     { 
      approx_factb = approx_fact[1];
      if (approx_factb < ZERO) approx_factb = ZERO;
      if (approx_factb > ONE)
         {
          smooth_rel_b = approx_factb; 
          approx_factb = ONE;
         }
     }


  /*******************************************************

          trim surfaces if blend is at iso-curves
 
  *******************************************************/

  split = 0;
  if ( boundary_flag[0] < 5 )  bound1 = boundary_flag[0];
  else 
     {
      if (boundary_flag[0] == 6 || boundary_flag[0] == 8) iso1 = 1;
      else                                                iso1 = 2;
      if ( ( (boundary_flag[0] <= 6)  &&  (pariso[0]  > HALF) )   ||
           ( (boundary_flag[0] >  6)  &&  (pariso[1] <= HALF) )      )
         dir_rev_cv1 = -1;   

      if (iso1 == 1)
         {
          if ( pariso[0] <= HALF )
             { 
              bound1 = 2;
              par1_trm_sf[0] = pariso[0];  
              par1_trm_sf[1] = ZERO;
              par3_trm_sf[0] = ONE; 
              par3_trm_sf[1] = ONE;
             }
          else
             {
              bound1 = 4;
              par1_trm_sf[0] = ZERO;
              par1_trm_sf[1] = ZERO;
              par3_trm_sf[0] = pariso[0];
              par3_trm_sf[1] = ONE;  
             }
         }
      else
         {
          split = 1;
          if ( pariso[0] <= HALF )
             { 
              bound1 = 1;
              par1_trm_sf[1] = pariso[0];  
              par1_trm_sf[0] = ZERO;
              par3_trm_sf[1] = ONE; 
              par3_trm_sf[0] = ONE;
             }
          else
             {
              bound1 = 3;
              par1_trm_sf[1] = ZERO;
              par1_trm_sf[0] = ZERO;
              par3_trm_sf[1] = pariso[0];
              par3_trm_sf[0] = ONE;  
             }
         }
      par2_trm_sf[0] = HALF*(par1_trm_sf[0] + par3_trm_sf[0]);         
      par2_trm_sf[1] = HALF*(par1_trm_sf[1] + par3_trm_sf[1]);     
      num_bound = 0;
      u_order = sf1->u_order;
      v_order = sf1->v_order;
      if ( split == 0)
         {
          u_num_poles =  sf1->u_num_poles + 2*u_order -1; 
          v_num_poles =  sf1->v_num_poles;
         }
      else
         {
          v_num_poles =  sf1->v_num_poles + 2*v_order -1; 
          u_num_poles =  sf1->u_num_poles;
         }

      BSallocsf (u_order, v_order, u_num_poles, v_num_poles,
                 sf1->rational, num_bound, &sf1_trm, rc );
      if ( *rc != BSSUCC ) { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; }

      BSpartofsf ( sf1, par1_trm_sf, par2_trm_sf, par3_trm_sf, split,
                   sf1_trm, rc); 
      if ( *rc != BSSUCC ) { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; } 

      sf1 = sf1_trm;
     }


  split = 0;
  if ( boundary_flag[1] < 5 ) bound2 = boundary_flag[1];
  else 
     {
      if ( boundary_flag[1] == 6 || boundary_flag[1] == 8 ) iso2 = 1;
      else                                                        iso2 = 2;
      if ( ( (boundary_flag[1] <= 6)  &&  (pariso[1]  > HALF) )   ||
           ( (boundary_flag[1] >  6)  &&  (pariso[1] <= HALF) )      )
         dir_rev_cv2 = -1;   

      if (iso2 == 1)
         {
          if ( pariso[1] <= HALF )
             { 
              bound2 = 2;
              par1_trm_sf[0] = pariso[1];  
              par1_trm_sf[1] = ZERO;
              par3_trm_sf[0] = ONE; 
              par3_trm_sf[1] = ONE;
             }
          else
             {
              bound2 = 4;
              par1_trm_sf[0] = ZERO;
              par1_trm_sf[1] = ZERO;
              par3_trm_sf[0] = pariso[1];
              par3_trm_sf[1] = ONE;  
             }
         }
      else
         {
          split = 1;
          if ( pariso[1] <= HALF )
             { 
              bound2 = 1;
              par1_trm_sf[1] = pariso[1];  
              par1_trm_sf[0] = ZERO;
              par3_trm_sf[1] = ONE; 
              par3_trm_sf[0] = ONE;
             }
          else
             {
              bound2 = 3;
              par1_trm_sf[1] = ZERO;
              par1_trm_sf[0] = ZERO;
              par3_trm_sf[1] = pariso[1];
              par3_trm_sf[0] = ONE;  
             }
         }
      par2_trm_sf[0] = HALF*(par1_trm_sf[0] + par3_trm_sf[0]);         
      par2_trm_sf[1] = HALF*(par1_trm_sf[1] + par3_trm_sf[1]);     

      num_bound = 0;
      u_order = sf2->u_order;
      v_order = sf2->v_order;
      if ( split == 0)
         {
          u_num_poles =  sf2->u_num_poles + 2*u_order -1; 
          v_num_poles =  sf2->v_num_poles;
         }
      else
         {
          v_num_poles =  sf2->v_num_poles + 2*v_order -1; 
          u_num_poles =  sf2->u_num_poles;
         }
 
      BSallocsf (u_order, v_order, u_num_poles, v_num_poles,
                 sf2->rational, num_bound, &sf2_trm, rc );
      if ( *rc != BSSUCC )  { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; }

      BSpartofsf ( sf2, par1_trm_sf, par2_trm_sf, par3_trm_sf, split,
                   sf2_trm, rc);
      if ( *rc != BSSUCC )  { *rc = BSFAIL; *inform = NO_PART; goto wrapup; } 

      sf2 = sf2_trm;
     }



  /********************************************************

       get data from constraint structures at start/end

  ********************************************************/


  if ( curvature_flag[0] == 0)   cont1 = 1;
  else                           cont1 = 2;
  if ( curvature_flag[1] == 0)   cont2 = 1;
  else                           cont2 = 2;

  out_contr_pt = cont1 + cont2 + 2;

  if ( (bound1 == 1) || (bound1 == 3) )
     {
      edge_sf1_ord = sf1->u_order;
      dir_sf1_ord =  sf1->v_order;
      edge_sf1_nump = sf1->u_num_poles;
      numk = sf1->v_num_knots;
      if ( bound1 == 1)
         {
          cr_mesh_sf1[0] = (   sf1->v_knots[dir_sf1_ord]
                             - sf1 ->v_knots[1] )/(dir_sf1_ord -1);
          if ( (cont1 == 2) && (dir_sf1_ord > 2) )
             {
              cr_mesh_sf1[1] = (   sf1->v_knots[dir_sf1_ord + 1]
                                 - sf1->v_knots[2] )/(dir_sf1_ord -1);
              cr_mesh_sf1[2] = (   sf1->v_knots[dir_sf1_ord + 2]
                                 - sf1->v_knots[2] )/(dir_sf1_ord -2);
             }
         }
      else
         {
          cr_mesh_sf1[0] = (   sf1->v_knots[numk - 2]
                             - sf1->v_knots[numk - dir_sf1_ord -1] 
                           ) / (dir_sf1_ord -1);
          if ( (cont1 == 2) && (dir_sf1_ord > 2) )
             {
              cr_mesh_sf1[1] = (   sf1->v_knots[numk - 3]
                                 - sf1->v_knots[numk - dir_sf1_ord -2] 
                                ) / (dir_sf1_ord -1);
              cr_mesh_sf1[2] = (   sf1->v_knots[numk - 3]
                                 - sf1->v_knots[numk - dir_sf1_ord -3] 
                                ) / (dir_sf1_ord -2);
             }
         }
     }
  else
     {
      edge_sf1_ord = sf1->v_order;
      dir_sf1_ord = sf1->u_order;
      edge_sf1_nump = sf1->v_num_poles;
      numk = sf1->u_num_knots;
      if ( bound1 == 2)
         {
          cr_mesh_sf1[0] = (   sf1->u_knots[dir_sf1_ord]
                             - sf1->u_knots[1] )/(dir_sf1_ord -1);
          if ( (cont1 == 2) && (dir_sf1_ord > 2) )
             {
              cr_mesh_sf1[1] = (   sf1->u_knots[dir_sf1_ord + 1]
                                 - sf1->u_knots[2] )/(dir_sf1_ord -1);
              cr_mesh_sf1[2] = (   sf1->u_knots[dir_sf1_ord + 2]
                                 - sf1->u_knots[2] )/(dir_sf1_ord -2);
             }
         }
      else
         {
          cr_mesh_sf1[0] = (   sf1->u_knots[numk - 2]
                             - sf1->u_knots[numk - dir_sf1_ord -1] 
                           ) / (dir_sf1_ord -1);
          if ( (cont1 == 2) && (dir_sf1_ord > 2) )
             {
              cr_mesh_sf1[1] = (   sf1->u_knots[numk - 3]
                                 - sf1->u_knots[numk - dir_sf1_ord -2] 
                                ) / (dir_sf1_ord -1);
              cr_mesh_sf1[2] = (   sf1->u_knots[numk - 3]
                                 - sf1->u_knots[numk - dir_sf1_ord -3] 
                                ) / (dir_sf1_ord -2);
             }
         }


     }
  if ( (bound2 == 1) || (bound2 == 3) )
     {
      edge_sf2_ord = sf2->u_order;
      dir_sf2_ord = sf2->v_order;
      edge_sf2_nump = sf2->u_num_poles;
      numk = sf2->v_num_knots;
      if ( bound1 == 1)
         {
          cr_mesh_sf2[0] = (   sf2->v_knots[dir_sf2_ord]
                             - sf2->v_knots[1] )/(dir_sf2_ord -1);
          if ( (cont2 == 2) && (dir_sf2_ord > 2) )
             {
              cr_mesh_sf2[1] = (   sf2->v_knots[dir_sf2_ord + 1]
                                 - sf2->v_knots[2] )/(dir_sf2_ord -1);
              cr_mesh_sf2[2] = (   sf2->v_knots[dir_sf2_ord + 2]
                                 - sf2->v_knots[2] )/(dir_sf2_ord -2);
             }
         }
      else
         {
          cr_mesh_sf2[0] = (   sf2->v_knots[numk - 2]
                             - sf2->v_knots[numk - dir_sf2_ord -1] 
                           ) / (dir_sf2_ord -1);
          if ( (cont2 == 2) && (dir_sf2_ord > 2) )
             {
              cr_mesh_sf2[1] = (   sf2->v_knots[numk - 3]
                                 - sf2->v_knots[numk - dir_sf2_ord -2] 
                                ) / (dir_sf2_ord -1);
              cr_mesh_sf2[2] = (   sf2->v_knots[numk - 3]
                                 - sf2->v_knots[numk - dir_sf2_ord -3] 
                                ) / (dir_sf2_ord -2);
             }
         }
     }
  else
     {
      edge_sf2_ord = sf2->v_order;
      dir_sf2_ord = sf2->u_order;
      edge_sf2_nump = sf2->v_num_poles;
      numk = sf2->u_num_knots;
      if ( bound1 == 1)
         {
          cr_mesh_sf2[0] = (   sf2->u_knots[dir_sf2_ord]
                             - sf2->u_knots[1] )/(dir_sf2_ord -1);
          if ( (cont2 == 2) && (dir_sf2_ord > 2) )
             {
              cr_mesh_sf2[1] = (   sf2->u_knots[dir_sf2_ord + 1]
                                 - sf2->u_knots[2] )/(dir_sf2_ord -1);
              cr_mesh_sf2[2] = (   sf2->u_knots[dir_sf2_ord + 2]
                                 - sf2->u_knots[2] )/(dir_sf2_ord -2);
             }
         }
      else
         {
          cr_mesh_sf2[0] = (   sf2->u_knots[numk - 2]
                             - sf2->u_knots[numk - dir_sf2_ord -1] 
                           ) / (dir_sf2_ord -1);
          if ( (cont2 == 2) && (dir_sf2_ord > 2) )
             {
              cr_mesh_sf2[1] = (   sf2->u_knots[numk - 3]
                                 - sf2->u_knots[numk - dir_sf2_ord -2] 
                                ) / (dir_sf2_ord -1);
              cr_mesh_sf2[2] = (   sf2->u_knots[numk - 3]
                                 - sf2->u_knots[numk - dir_sf2_ord -3] 
                                ) / (dir_sf2_ord -2);
             }
         }
     }


  par_cv1[0] = blend_pt_par[0][0]; 
  par_cv1[1] = blend_pt_par[0][1]; 
  par_cv2[0] = blend_pt_par[1][0]; 
  par_cv2[1] = blend_pt_par[1][1]; 

  if ( tangent_flag[0] <= 0 )  tgflag1 = 0;
  else                            tgflag1 = tangent_flag[0];

  if (tgflag1 == 2) { inswa_tg_rel = 1; ratio1_rel = tangent_value[0]; }
  else              { inswa_tg_rel = 0; ratio1_rel = ONE;  }

  if ( tangent_flag[1] <= 0 )   tgflag2 = 0;
  else                             tgflag2 = tangent_flag[1];

  if (tgflag2 == 2) { inswb_tg_rel = 1; ratio2_rel = tangent_value[1]; }
  else              { inswb_tg_rel = 0; ratio2_rel = ONE;  } 

     
  dir_tg_cv1 = direction[0]*dir_rev_cv1;
  if (dir_tg_cv1 > 0)                sig_tga = ONE;
  else                               sig_tga = NONE;

  dir_tg_cv2 = direction[1]*dir_rev_cv2;
  if (dir_tg_cv2 > 0)                sig_tgb = ONE;
  else                               sig_tgb = NONE;


  if ( par_cv1[0] <= par_cv1[1] )
     {
      cv1_dir = 1;
      par_tr_cv1[0] = par_cv1[0]; 
      par_tr_cv1[2] = par_cv1[1]; 
      par_tr_cv1[1] = (par_cv1[0] + par_cv1[1])/TWO; 
     }
 else 
     { 
      cv1_dir = -1;
      par_tr_cv1[0] = ONE - par_cv1[0]; 
      par_tr_cv1[2] = ONE - par_cv1[1]; 
      par_tr_cv1[1] = (par_tr_cv1[0] + par_tr_cv1[2])/TWO; 
     }

  if ( par_cv2[0] <= par_cv2[1] )
     {
      cv2_dir = 1;
      par_tr_cv2[0] = par_cv2[0]; 
      par_tr_cv2[2] = par_cv2[1]; 
      par_tr_cv2[1] = (par_cv2[0] + par_cv2[1])/TWO; 
     }
 else 
     { 
      cv2_dir = -1;
      par_tr_cv2[0] = ONE - par_cv2[0]; 
      par_tr_cv2[2] = ONE - par_cv2[1]; 
      par_tr_cv2[1] = (par_tr_cv2[0] + par_tr_cv2[2])/TWO; 
     }

 /***********************************

    get the rows as B-spline curves

 ***********************************/

 row_rational =  sf1->rational;
 for ( num_row = 0;  num_row <= cont1;  num_row++)
     { 
      BSalloccv ( edge_sf1_ord, edge_sf1_nump, row_rational, row_num_bound,
                  &(row[num_row]), rc );
      if ( *rc != BSSUCC )  { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; }

      if ( (num_row == 2) && (dir_sf1_ord == 2) )
         {
          BSretrrow ( bound1, cv1_dir, IONE, sf1, row[2], rc );
          for ( j = 0; j < 3*edge_sf1_nump; j++)  row[2]->poles[j] =
               row[2]->poles[j] + (row[1]->poles[j] - row[0]->poles[j]);  
         }
      else
         BSretrrow ( bound1, cv1_dir, num_row, sf1, row[num_row], rc );

      if ( *rc != BSSUCC )  { *rc = BSFAIL; *inform = NO_RETR; goto wrapup; }
     }
 


 row_rational =  sf2->rational;
 for ( num_row = 0;  num_row <= cont2;  num_row++)
     { 
      BSalloccv ( edge_sf2_ord, edge_sf2_nump, row_rational, row_num_bound,
                  &(row[cont1 + num_row + 1]), rc );
      if ( *rc != BSSUCC )  { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; }

      if ( (num_row == 2) && (dir_sf2_ord == 2) )
         {
          BSretrrow ( bound2, cv2_dir, IONE, sf2, row[cont1 + 3], rc );
          for ( j = 0; j < 3*edge_sf2_nump; j++)
              row[cont1 + 3]->poles[j] = row[cont1 + 3]->poles[j] + 
              (row[cont1 + 2]->poles[j] - row[cont1 + 1]->poles[j]);  
         }
      else
         BSretrrow ( bound2, cv2_dir, num_row, sf2, 
                      row[cont1 + num_row + 1], rc );
      if ( *rc != BSSUCC )  { *rc = BSFAIL; *inform = NO_RETR; goto wrapup; }
     }


  /************************************************************

            trim rows if necessary ( partial blend)

  ************************************************************/

  row_rational = row[0]->rational;

  if ( (par_tr_cv1[0] > ZERO)  ||   (par_tr_cv1[2] < ONE) )
     {
      tr_order = row[0]->order;
      tr_num_poles = row[0]->num_poles + 2*tr_order - 1;
      for ( num_row = 0;  num_row <= cont1;  num_row++)
          {
           BSalloccv ( tr_order, tr_num_poles, row_rational,
                       row_num_bound, &(row_tr[num_row]), rc );
           if ( *rc != BSSUCC )
              { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; }


           BSpartofcv ( rc, row[num_row], 
                        par_tr_cv1[0], par_tr_cv1[1], par_tr_cv1[2], 
                        row_tr[num_row]);
           if ( *rc != BSSUCC ) 
              { *rc = BSFAIL; *inform = NO_PART; goto wrapup; }


           if (row[num_row])  BSfreecv(rc, row[num_row]);
           row[num_row] = row_tr[num_row];
           row_tr[num_row] = NULL;
          }
     }     


  if ( (par_tr_cv2[0] > ZERO)  ||   (par_tr_cv2[2] < ONE) )
     {
      tr_order = row[cont1+1]->order;
      tr_num_poles = row[cont1+1]->num_poles + 2*tr_order - 1;
      for ( num_row = cont1 +1;  num_row <= cont1 + cont2 + 1;  num_row++)
          {
           BSalloccv ( tr_order, tr_num_poles, row_rational,
                       row_num_bound, &(row_tr[num_row]), rc );
           if ( *rc != BSSUCC )
              { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; }


           BSpartofcv ( rc, row[num_row], 
                             par_tr_cv2[0], par_tr_cv2[1], par_tr_cv2[2], 
                             row_tr[num_row]);
           if ( *rc != BSSUCC )
              { *rc = BSFAIL; *inform = NO_PART; goto wrapup; }


           if (row[num_row])    BSfreecv(rc, row[num_row]); 

           row[num_row] = row_tr[num_row];
           row_tr[num_row] = NULL;
          }
     }


     /********************************
    
       make curves (row) compatible

     ********************************/


  if ( (row[0])->rational || (row[cont1 + 1])->rational )     

/************  save old weights at ends        ************/

      for ( i = 0; i < cont1 + cont2 + 2; i++ )
          {
           if ( (row[i])->rational ) 
              { 
               k =  row[i]->num_poles - 1;   
               row_wgts[i] = row[i]->weights[0];
               row_wgte[i] = row[i]->weights[k];
              }
           else
              {  row_wgts[i] = row_wgts[i] = ONE; }
          }

  BSmkcvscp ( cont1 + cont2 + 2, row, row_cp, rc );
  if ( *rc != BSSUCC ) { *rc = BSFAIL; *inform = NO_MK_COMP; goto wrapup; }


  if ( (row_cp[0])->rational )     
/********      regenerate old weights    **********/

     for ( i = 0; i < cont1 + cont2 + 2; i++ )
         end_weigts_BSblndsrfg( row_wgts[i],row_wgte[i],WEIGT_TOL,row_cp[i] );
  


/***************************************************************************
*
*        check rows for singularities (coincident poles)
*
***************************************************************************/

  num_poles_e = row_cp[0]->num_poles;
  pole_dega[0] = pole_dega[1] = pole_degb[0] = pole_degb[1] = 0;
  for ( i = 0; i < num_poles_e; i++ )
      { 
       if (row_cp[0]->rational)
                       {wg0=row_cp[0]->weights[i]; wg1=row_cp[1]->weights[i];}
       else            { wg0 = ONE; wg1 = ONE; } 
       dist_pole = ABS(row_cp[1]->poles[3*i]  /wg1 - row_cp[0]->poles[3*i]/wg0) 
                 + ABS(row_cp[1]->poles[3*i+1]/wg1 - row_cp[0]->poles[3*i+1]/wg0)
                 + ABS(row_cp[1]->poles[3*i+2]/wg1 - row_cp[0]->poles[3*i+2]/wg0);

       if ( dist_pole < DST_POL_FAC * tolarr[2] )
          {
           if (approx_flag[0] == 0 || (i != 0  && i !=  num_poles_e -1))
              { *rc = BSFAIL; *inform = DEG_POLA; goto wrapup; }

           if ( i == 0 )                pole_dega[0] = 1;
           if ( i == num_poles_e - 1)   pole_dega[1] = 1;
          }

       k = cont1 + 1;
       if (row_cp[k]->rational)
                   {wg0=row_cp[k]->weights[i]; wg1=row_cp[k+1]->weights[i];}
       else        { wg0 = ONE; wg1 = ONE; } 
       dist_pole = ABS(row_cp[k+1]->poles[3*i]  /wg1 - row_cp[k]->poles[3*i]/wg0) 
                 + ABS(row_cp[k+1]->poles[3*i+1]/wg1 - row_cp[k]->poles[3*i+1]/wg0)
                 + ABS(row_cp[k+1]->poles[3*i+2]/wg1 - row_cp[k]->poles[3*i+2]/wg0);

       if ( dist_pole < DST_POL_FAC * tolarr[2] )
          {
           if ( approx_flag[1] == 0 || (i != 0  && i !=  num_poles_e -1) )
              { *rc = BSFAIL; *inform = DEG_POLB; goto wrapup; }

           if ( i == 0 )              pole_degb[0] = 1;
           if ( i == num_poles_e -1)  pole_degb[1] = 1;
          }
       }



    if ( num_poles_e == 2 && (pole_dega[0] != 0 && pole_dega[1] != 0) )
       { *rc = BSFAIL; *inform = DEG_POLA; goto wrapup; }
    if ( num_poles_e == 2 && (pole_degb[0] != 0 && pole_degb[1] != 0) )
       { *rc = BSFAIL; *inform = DEG_POLB; goto wrapup; }
   
    if ( approx_flag[0] == 0 && (pole_dega[0] != 0 || pole_dega[1] != 0) )
       { *rc = BSFAIL; *inform = DEG_POLA; goto wrapup; }
    if ( approx_flag[1] == 0 && (pole_degb[0] != 0 || pole_degb[1] != 0) )
       { *rc = BSFAIL; *inform = DEG_POLB; goto wrapup; }


     /*************************************************

         determine scaling for tangency and curvature

     *************************************************/



  if ( tgflag1 != 0 && inswa_tg_rel == 0 )
     { inswa_tg_fact = 1; tg_facta = tangent_value[0]; }
   else
      inswa_tg_fact = 0;

  if ( tgflag2 != 0 && inswb_tg_rel == 0 )
     { inswb_tg_fact = 1; tg_factb = tangent_value[1]; }
  else
      inswb_tg_fact = 0;

  my1 = my2 = ZERO;

  xl_edge_a = xl_edge_b = ZERO;
  if ( approx_flag[0]   >  0  ||  approx_flag[1] > 0 ) 
     calc_cross_curves = 1;
  else
     calc_cross_curves = 0;

/*********    set some pointer for better reading the code   ***********/
  cr_knots = row_cp[0]->knots;
  cr_order = row_cp[0]->order; 
  cr_numk  = row_cp[0]->num_knots;
  cr_nump  = row_cp[0]->num_poles;
  blnd_rat = row_cp[0]->rational;
/*******************************************/

  if ( tgflag1 == 0  ||  cont1 == 2 ||
       inswa_tg_rel  == 1  ||  inswa_tg_rel  == 1  ||
       tgflag2 == 0  ||  cont2 == 2 ||
       approx_flag[0]   >  0  ||  approx_flag[1] > 0 ) 
     {

     if ( cr_nump < MAX_NOD_DEF )
        { lda = lda1; ldb = ldb1; mya = mya1; myb = myb1;
          nodarr = nodarr1; cross_points = cross_points1;
          cross_wgs = cross_wgs1;
        }
     else

        /***************************************

                 allocate memory

        ***************************************/

        {
         s_nodes        = cr_nump*sizeof(IGRdouble);
         s_lda          = cr_nump*sizeof(IGRdouble);
         s_ldb          = cr_nump*sizeof(IGRdouble);
         s_mya          = cr_nump*sizeof(IGRdouble);
         s_myb          = cr_nump*sizeof(IGRdouble);
         s_cross_pts    = 6*cr_nump*sizeof(IGRpoint);
         s_cross_wgs    = cr_nump*sizeof(IGRdouble);

         size = s_nodes
              + s_lda
              + s_ldb;

         if ( cont1 == 2 ) size = size + s_mya; 
         if ( cont2 == 2 ) size = size + s_myb; 

         if ( approx_flag[0]   >  0  ||  approx_flag[1] > 0 ) 
            size = size + s_cross_pts + s_cross_wgs;

         workarea = (IGRdouble *) BSstackalloc ((unsigned)size);
         if (!workarea) goto wrapup;

         dealloc  = TRUE;
  
         nodarr = workarea;
         lda    = nodarr + cr_nump;
         ldb    = lda    + cr_nump;
         if ( cont1 == 2 )  mya = ldb + cr_nump; 
         else               mya = ldb;
         if ( cont2 == 2 )  myb = mya + cr_nump; 
         else               myb = mya;
         if ( approx_flag[0]   >  0  ||  approx_flag[1] > 0 )
            { 
             cross_points = (IGRpoint *) (myb + cr_nump);
             cross_wgs    = (IGRdouble *) cross_points + cr_nump;
            } 
        }

      /***************************
         determine the nodes
      ***************************/

      BSnodevals(cr_order, cr_numk,cr_knots, nod_insert, &num_nod, nodarr, rc);
      if ( *rc != BSSUCC )
         { *rc = BSFAIL; *inform = NO_NODES; goto wrapup; }


      /*******************************************************************
       *
       *       calculate blend curves between corresponding nodes
       *
      *******************************************************************/


      for ( j = 0;  j < num_nod; j++)
          {

           par = nodarr[j];
           BScrosseval ( par, cont1, dir_sf1_ord, cr_mesh_sf1,
                         row_cp, blnd_rat, &wg_a, pta, dpta, ddpta, rc);
           if ( *rc != BSSUCC )
              { *rc = BSFAIL; *inform = NO_CROSS; goto wrapup; }

           if ( j == 0 )  for ( k = 0; k < 3; k++ ) pta_old[k] = pta[k];
           else
              for ( k = 0; k < 3; k++ )
                  {
                   xl_edge_a = xl_edge_a + ABS( pta[k] - pta_old[k] );
                   pta_old[k] = pta[k];
                  }
           if ( j == 0  &&  pole_dega[0] != 0 )
              {
              /****   poles coincide, derivative must be calculated
                      by other means                                 ****/
                
               BScveval(*row_cp, par, IONE, eval, rc);
               if ( *rc != BSSUCC ) 
                  { *rc = BSFAIL; *inform = DEG_POLA; goto wrapup; }
               else
                  for ( k = 0; k < 3; k++ ) dpta[k] = (*(*(eval + 1) + k));
               BScveval(*(row_cp + 1), par, IONE, eval, rc);
               if ( *rc != BSSUCC )
                  { *rc = BSFAIL; *inform = DEG_POLA; goto wrapup; }
               else
                  for ( k = 0; k < 3; k++ )
                      {  
                       dpta[k] = -dpta[k] + (*(*(eval + 1) + k));
                       ddpta[k] = ZERO;
                      }
              }

           if ( j ==  num_nod - 1  &&  pole_dega[1] != 0 )
              {
               BScveval(*row_cp, par, IONE, eval, rc);
               if ( *rc != BSSUCC )
                  { *rc = BSFAIL; *inform = DEG_POLA; goto wrapup; }
               else
                  for ( k = 0; k < 3; k++ ) dpta[k] = (*(*(eval + 1) + k));
               BScveval(*(row_cp + 1), par, IONE, eval, rc);
               if ( *rc != BSSUCC )
                  { *rc = BSFAIL; *inform = DEG_POLA; goto wrapup; }
               else
                  for ( k = 0; k < 3; k++ )
                      { 
                       dpta[k] = dpta[k] - (*(*(eval + 1) + k));
                       ddpta[k] = ZERO;
                      }
              }


           /***********************

             direct tangent to point away from surface

           ***********************/

           if ( sig_tga < ZERO ) for ( k = 0; k < 3; k++ ) dpta[k] = -dpta[k];


           BScrosseval ( par, cont2, dir_sf2_ord, cr_mesh_sf2,
                         row_cp + cont1 + 1, blnd_rat,
                         &wg_b, ptb, dptb, ddptb, rc);
           if ( *rc != BSSUCC )
              { *rc = BSFAIL; *inform = NO_CROSS ; goto wrapup; }
           if ( j == 0 )
              for ( k = 0; k < 3; k++ ) ptb_old[k] = ptb[k];
           else
              for ( k = 0; k < 3; k++ )
                  {
                   xl_edge_b = xl_edge_b + ABS( ptb[k] - ptb_old[k] );
                   ptb_old[k] = ptb[k];
                  }

           if ( j == 0  &&  pole_degb[0] != 0 )
              {
              /****   poles coincide derivative must be calculated
                      by other means                                 ****/
                
                BScveval(*(row_cp + cont1 + 1), par, IONE, eval, rc);
                if ( *rc != BSSUCC )
                   { *rc = BSFAIL; *inform = DEG_POLB; goto wrapup; }
                else
                   for ( k = 0; k < 3; k++ ) dptb[k] = (*(*(eval + 1) + k));
                BScveval(*(row_cp + cont1 + 2), par, IONE, eval, rc);
                if ( *rc != BSSUCC )
                   { *rc = BSFAIL; *inform = DEG_POLB; goto wrapup; }
                else
                   for ( k = 0; k < 3; k++ )
                       {  
                        dptb[k] = -dptb[k] + (*(*(eval + 1) + k));
                        ddptb[k] = ZERO;
                       }
               }

           if ( j ==  num_nod - 1  &&  pole_degb[1] != 0 )
              {
               BScveval(*(row_cp + cont1 + 1), par, IONE, eval, rc);
               if ( *rc != BSSUCC )
                  { *rc = BSFAIL; *inform = DEG_POLB; goto wrapup; }
               else
                  for ( k = 0; k < 3; k++ ) dptb[k] = (*(*(eval + 1) + k));
               BScveval(*(row_cp + cont1 + 2), par, IONE, eval, rc);
               if ( *rc != BSSUCC )
                  { *rc = BSFAIL; *inform = DEG_POLB; goto wrapup; }
               else
                  for ( k = 0; k < 3; k++ )
                      { 
                       dptb[k] =  dptb[k] - (*(*(eval + 1) + k));
                       ddptb[k] = ZERO;
                      }
              }

   
        /***************************************************

               direct tangent to point away from surface

           ***************************************************/

           if ( sig_tgb < ZERO ) for ( k = 0; k < 3; k++ ) dptb[k] = -dptb[k];

           if ( ABS(dpta[0]) + ABS(dpta[1]) + ABS(dpta[2]) < TWO*tolarr[2] )
              { *rc = BSFAIL; *inform = DEG_POLA; goto wrapup; }
           if ( ABS(dptb[0]) + ABS(dptb[1]) + ABS(dptb[2]) < TWO*tolarr[2] )
              { *rc = BSFAIL; *inform = DEG_POLB; goto wrapup; }

           BSblndctan   (cont1,
                         INSW_TG_CR,
                         pta,
                         dpta,
                         ddpta,
                         inswa_tg_fact,
                         &tg_facta,
                         &cr_facta,
                         cont2,
                         INSW_TG_CR,
                         ptb,
                         dptb,
                         ddptb,
                         inswb_tg_fact,
                         &tg_factb,
                         &cr_factb,
                         tolarr,
                         out_contr_pt,
                         pt_contr,
                         &config,
                         rc            );

           if (*rc != BSSUCC)
              {
               if (*inform != DEG_DPT)
               { 
                 *rc = BSFAIL;
                 goto wrapup; 
               }
               if ( approx_flag[0] <= 0 || approx_flag[1] <= 0) 
               {
                 goto wrapup;
               }
               *rc = BSSUCC;
              }

           if ( inswa_tg_rel == 1  ||  inswb_tg_rel == 1 ) 
              {
               /*****
                multiply resulting tangent factor with relative factor 
                and recalculate
                *****/

               if ( inswa_tg_rel == 1  )
                  { inswa_tg_fact = 1; tg_facta = tg_facta*ratio1_rel; } 
               if ( inswb_tg_rel == 1  )
                  { inswb_tg_fact = 1; tg_factb = tg_factb*ratio2_rel; } 
  
 
               BSblndctan   ( cont1,
                              INSW_TG_CR,
                              pta,
                              dpta,
                              ddpta,
                              inswa_tg_fact,
                              &tg_facta,
                              &cr_facta,
                              cont2,
                              INSW_TG_CR,
                              ptb,
                              dptb,
                              ddptb,
                              inswb_tg_fact,
                              &tg_factb,
                              &cr_factb,
                              tolarr,
                              out_contr_pt,
                              pt_contr,
                              &config,
                              rc            );


               if ( inswa_tg_rel == 1  ) inswa_tg_fact = 0;
               if ( inswb_tg_rel == 1  ) inswb_tg_fact = 0;
              }

           if (j == 0) for (k=0; k<3; k++)
               { dpta_s[k] = dpta[k]; dptb_s[k] = dptb[k]; }
           if (j == num_nod - 1) for (k=0; k<3; k++)
               { dpta_e[k] = dpta[k]; dptb_e[k] = dptb[k]; }
            
           if ( calc_cross_curves != 0 )
         
              for ( l0 = j, l = 0; l < cont1 + cont2 + 2; l++ )
                  {
                   if (blnd_rat)
                      {
                       if ( l > cont1 ) wgab = wg_b;
                       else             wgab = wg_a;
                       for ( k = 0; k < 3; k++ )
                           pt_contr[l][k] = wgab*pt_contr[l][k];
                      }

                   for (k=0; k<3; k++) cross_points[l0][k] = pt_contr[l][k];

                   if ( j == 0 )
                      for (k=0; k<3; k++) pt_contr_s[l][k] = pt_contr[l][k];
                   if ( j == num_nod - 1 )
                      for (k=0; k<3; k++) pt_contr_e[l][k] = pt_contr[l][k];

                   l0 = l0 + num_nod;
                  }



           lda[j] = tg_facta;  if (cont1 == 2) mya[j] = cr_facta;
           ldb[j] = tg_factb;  if (cont2 == 2) myb[j] = cr_factb;

           if (blnd_rat) cross_wgs[j] = wgab; 

           if ((j == 0 && pole_dega[0] == 0) || (j == 1 && pole_dega[0] != 0))
              {
               if (cont1 == 2) my1 = cr_facta;
               ratio1_min = tg_facta;
               ratio1_max = tg_facta;
              }
           else
              {
               if ( j > 0 && (j != num_nod - 1  ||  pole_dega[1] == 0 ) ) 
                  {
                   if (tg_facta < ratio1_min)
                      {ratio1_min = tg_facta; if (cont1 == 2) my1 = cr_facta;}
                   else if (tg_facta > ratio1_max)  ratio1_max = tg_facta;
                  }
              }

           if ((j == 0 && pole_degb[0] == 0) || (j == 1 && pole_degb[0] != 0))
              {
               if (cont2 == 2) my2 = cr_factb;
               ratio2_min = tg_factb;
               ratio2_max = tg_factb;
              }
           else
              {
               if ( j > 0 && (j != num_nod - 1  ||  pole_degb[1] == 0 ) )  
                  { 
                   if (tg_factb < ratio2_min)
                      {ratio2_min = tg_factb; if (cont2 == 2) my2 = cr_factb;}
                   else if (tg_factb > ratio2_max)  ratio2_max = tg_factb;
                  }
              }
          }

      beta1c_a = ratio1_min; beta1c_b = ratio2_min;
      if (cont1 == 2) beta2c_a = my1; 
      if (cont2 == 2) beta2c_b = my2; 
      alfa0c_a = alfa0c_b = ONE;
      alfa1c_a = alfa1c_b = alfa2c_a = alfa2c_b = ZERO;


      if ( calc_cross_curves == 1  &&  num_nod >= SMOOTH_MIN )
         {
          /***********************************************

            approximate the cross rows by B-spline curves

           **********************************************/


          num_fix = 2; pfix[0] = 1; pfix[1] = num_nod;

          BSalloccv ( cr_order, num_nod, FALSE, row_num_bound,
                      &(row_sm[0]), rc);
          if ( *rc != BSSUCC ) 
             { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; }
          if (cont1 == 2 || cont2 == 2)
             {
              BSalloccv ( cr_order, num_nod, FALSE, row_num_bound,
                          &(row_sm[1]), rc);
              if ( *rc != BSSUCC )
                 { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; }
             }
 
          nsmooth =  cont1 + cont2 + 1;
         }  
      else   
          nsmooth =  0; 


      for ( side = 0; side < 2; side++ )
          {
           if (nsmooth == 0) break;
           if (side == 0) 
              { smooth = smooth_rel_a*SMOOTH_DEF; sig_tg = sig_tga;
                i1 = 0; if (cont1 == 2) i2 = 1; else i2 = 0;
                iord = dir_sf1_ord; cr_mesh_f = cr_mesh_sf1;
                i_row = 0; cont = cont1;
                ldab = lda; myab = mya;
                incr1 = num_nod; incr2 = incr1 + num_nod;
              }
           else 
              { smooth = smooth_rel_b*SMOOTH_DEF; sig_tg = sig_tgb; 
                i1 = cont1 + 1; if (cont2 == 2) i2 = i1 + 1; else i2 = 0;
                iord = dir_sf2_ord; cr_mesh_f = cr_mesh_sf2;
                i_row = cont1 + 1; cont = cont2;
                ldab = ldb; myab = myb;
                incr1 = (blend_nump - 2)*num_nod; incr2 = incr1 - num_nod;
              }


           smfac = smooth*HALF*( xl_edge_a + xl_edge_b );
           cr_mesh_b[0] = cr_mesh_b[1] = ONE/(blend_nump - 1); 
           cr_mesh_b[2] = ONE/(blend_nump - 2); 


           if (blnd_rat)  opt_sm = 0;
           else           opt_sm = 1; 
           num_pt_lsq = num_nod;

           BSlsqweccv (num_pt_lsq, dim3, cross_points[incr1], cr_order,
                       num_pt_lsq, cr_knots, nodarr, num_fix, pfix, num_der1,
                       pder1, deriv1, opt_der2, deriv2, num_wgts, pwgts, wgts,
                       opt_end, opt_sm, smfac, row_sm[0], rc);

           if (i2 != 0)
              BSlsqweccv (num_pt_lsq, dim3, cross_points[incr2], cr_order,
                          num_pt_lsq, cr_knots, nodarr, num_fix, pfix, num_der1,
                          pder1, deriv1, opt_der2, deriv2, num_wgts, pwgts,
                          wgts, opt_end, opt_sm, smfac, row_sm[1], rc);


       /*****   recalculate tangent lengths   *******/

           p0 = row_cp[i_row]->poles + INCRJJ;
           p1 = row_cp[i_row + 1]->poles + INCRJJ;
           if (cont == 2) p2 = row_cp[i_row + 2]->poles + INCRJJ;
           qq = row_sm[0]->poles + INCRJJ;
           if (cont == 2) rr = row_sm[1]->poles + INCRJJ;
           if (blnd_rat)
              {
               wp0 = row_cp[i_row]->weights + 1;
               wp1 = row_cp[i_row + 1]->weights + 1;
               if (cont == 2) wp2 = row_cp[i_row + 2]->weights + 1;
              }

            
           for ( jpol = 1; jpol < cr_nump - 1; jpol++, p0 += INCRJJ,
                                                       p1 += INCRJJ,
                                                       qq += INCRJJ )
               {
                /**** calculate quasi-derivative  ****/

                cpr3dvBSblndsrfg2 ( blnd_rat, cont, iord, cr_mesh_f,
                                    sig_tg, p0, p1, p2, *wp0, *wp1, *wp2,
                                    pdrv0, pdrv1, pdrv2 );

                /**** drop smoothed pole qq to tangent line ****/


                if (blnd_rat)
                   for ( k = 0; k < 3; k++ ) qq[k] = qq[k]/(*wp0); 

                pttoliBSblndsrfg2 ( IZRO, qq, pdrv0, pdrv1, qqsm );

                /**** calculate corresponding derivative ****/

                cptodvBSblndsrfg2 ( 3, IONE, (IGRshort)blend_nump, cr_mesh_b, ONE,
                                    pdrv0, qqsm, p_dummy, qdrv0, qdrv1, qdrv2);

                /**** determine beta parameter ****/

                betadvBSblndsrfg2 ( IONE, pdrv1, pdrv2, qdrv1, qdrv2,
                                    &beta1, &beta2 );
                ldab[jpol] = beta1;

                if (cont == 1)
                   { if (blnd_rat) {wp0++; wp1++;}
                     continue;
                   }

/**********************************************************

                    curvature

**********************************************************/


                /**** drop smoothed pole rr to curvature line ****/

                if (blnd_rat)
                   for ( k = 0; k < 3; k++ ) rr[k] = rr[k]/(*wp0);  

                if (iord == 2) 
                    pttoliBSblndsrfg2 ( IZRO, rr, pdrv0, pdrv1, rrsm );
                else
                   {
                    for ( k = 0; k < 3; k++ )
                        ttsm[k] = pdrv0[k]
                                + SQ(beta1)*cr_mesh_b[1]*cr_mesh_b[2]*pdrv2[k];
                    pttoliBSblndsrfg2 ( IZRO, rr, ttsm, pdrv1, rrsm );
                   }


                /**** calculate corresponding derivative ****/

                cptodvBSblndsrfg2 ( 3, ITWO, (IGRshort)blend_nump, cr_mesh_b, ONE,
                                    pdrv0, qqsm, rrsm, qdrv0, qdrv1, qdrv2);

                /**** determine beta parameter ****/


                betadvBSblndsrfg2 ( ITWO, pdrv1, pdrv2, qdrv1, qdrv2,
                                    &beta1, &beta2 );
                myab[jpol] = beta2;


                p2 += INCRJJ; rr += INCRJJ; 
                if (blnd_rat) { wp0++; wp1++; wp2++; }

               }     /****   switch - ende  und jpol-schleife  ***/
          }          /****   side-schleife - ende              ***/
     }               /****   lamda, my berechnung - ende    ***/


  if ( approx_flag[0] <= 0 )
     {
      if (tgflag1 <= 0)
         {
          if (tangent_flag[0] == -1) 
                                       tangent_value[0] = beta1c_a;
          if (tangent_flag[0] == -2)  
                                       tangent_value[0] = ONE; 
         }
      else
         if (tgflag1 == 1) beta1c_a = tangent_value[0];
     }
  else
     {
      approx_meana = ZERO;
      for ( j = 0; j < cr_nump; j++ )
          approx_meana = approx_meana + lda[j];

          approx_meana = approx_meana / cr_nump;
          if (tangent_flag[0] == -1) tangent_value[0] = approx_meana; 
          if (tangent_flag[0] == -2) tangent_value[0] = ONE; 
     }

  if ( approx_flag[1] <= 0 )
     {

      if (tgflag2 <= 0)
         {
          if (tangent_flag[1] == -1) tangent_value[1] = beta1c_b;
          if (tangent_flag[1] == -2) tangent_value[1] = ONE; 
         }
      else
         {
          if (tgflag2 == 1)  beta1c_b = tangent_value[1];
         }
     }
  else
     {

      approx_meanb = ZERO;
      for ( j = 0; j < num_nod; j++ )
          approx_meanb = approx_meanb + ldb[j];    

          approx_meanb = approx_meanb / cr_nump;
          if (tangent_flag[1] == -1) tangent_value[1] = approx_meanb;
          if (tangent_flag[1] == -2) tangent_value[1] = ONE; 
     }


 /***********   define the blend surface     ************
 ************   with v=vmin as start edge    ***********/


  blnd_u_order = cr_order;
  blnd_u_num_knots = cr_numk;
  blnd_v_order = blend_order;
  blnd_v_num_knots = blnd_v_order + blend_nump;

  blnd_rat = sf1->rational || sf2->rational;
  blnd_num_bound = 0;



  BSallocsf (blnd_u_order, blnd_v_order, cr_nump, blend_nump,
             blnd_rat, blnd_num_bound, &blndsrf, rc );
  if ( *rc != BSSUCC ) { *rc = BSFAIL; *inform = NO_ALLOC; goto wrapup; }

  blndsrf->u_order = blnd_u_order;
  blndsrf->v_order = blnd_v_order;
  blndsrf->u_num_poles = cr_nump;
  blndsrf->v_num_poles = blend_nump;
  blndsrf->u_num_knots = cr_numk;
  blndsrf->v_num_knots = blnd_v_num_knots;
  blndsrf->rational = blnd_rat; 
  blndsrf->num_boundaries = blnd_num_bound;
  blndsrf->u_non_uniform = TRUE;
  blndsrf->v_non_uniform = FALSE;
  blndsrf->u_periodic = FALSE;
  blndsrf->v_periodic = FALSE;
  blndsrf->planar = FALSE;
  blndsrf->u_phy_closed = FALSE;
  blndsrf->v_phy_closed = FALSE;





  if (blnd_rat)
     {
      r_shBSblndsrfg2 ( cont1, dir_sf1_ord, row_cp, cr_mesh_sf1,
                        cr_mesh_sfb1, sig_tga, beta1c_a, beta2c_a,
                        &alfa0c_a, &alfa1c_a, &alfa2c_a );

      r_shBSblndsrfg2 ( cont2, dir_sf2_ord, row_cp+cont1+1, cr_mesh_sf2,
                        cr_mesh_sfb2, sig_tgb, beta1c_b, beta2c_b,
                        &alfa0c_b, &alfa1c_b, &alfa2c_b );
     }




   /*****************************

             knots

   *****************************/






   for ( j = 0; j < blend_numk; j++ ) blndsrf->v_knots[j] = blend_knots[j];
   for ( j = 0; j < cr_numk; j++ )    blndsrf->u_knots[j] = cr_knots[j];


    /*****************************

           first side (at sf1)         +++++++++++++

    *****************************/


    q0 = blndsrf->poles;  p0 = row_cp[0]->poles; 
    q1 = blndsrf->poles + 3*cr_nump;  p1 = row_cp[1]->poles;
    if (cont1 == 2) {q2 = blndsrf->poles + 6*cr_nump; p2 = row_cp[2]->poles;}
    if ( blnd_rat )
       {
        wq0 = blndsrf->weights; wp0 = row_cp[0]->weights;
        wq1 = blndsrf->weights + cr_nump; wp1 = row_cp[1]->weights;
        if (cont1 == 2)
           { wq2 = blndsrf->weights + 2*cr_nump;  wp2 = row_cp[2]->weights; }
       } 

     for (jpol = 0; jpol < cr_nump; jpol++, q0 += INCRJJ, p0 += INCRJJ,
                                            q1 += INCRJJ, p1 += INCRJJ)
        {
         if ( blnd_rat )
            { wg0 = *wp0; wg1 = *wp1; if (cont1 == 2) wg2 = *wp2; }
         if ( approx_flag[0] <= 0 )
            {
             betarr[0] = beta1c_a; if (cont1 == 2) betarr[1] = beta2c_a; 
             if ( blnd_rat )
                {
                 alfarr[0] = alfa0c_a; alfarr[1] = alfa1c_a;
                 if (cont1 == 2)  alfarr[2] = alfa2c_a;
                }
            }
         else
            {
             betarr[0] =                  (ONE - approx_facta) * beta1c_a
                                               + approx_facta  * lda[jpol];


 
             if (cont1 == 2)  betarr[1] = (ONE - approx_facta) * beta2c_a
                                               + approx_facta  * mya[jpol];
             if ( blnd_rat )
                { 
                 alfarr[0] = alfa0c_a;

                 v_shBSblndsrfg2 ( cont1, dir_sf1_ord, wg0, wg1, wg2,
                                   cr_mesh_sf1, cr_mesh_sfb1,
                                   sig_tga, betarr[0], betarr[1], alfarr[0],
                                   &(alfarr[1]), &(alfarr[2]) );

                 alfarr[1] = (ONE - approx_facta) * alfa1c_a
                           + approx_facta  * alfarr[1];

                 if (cont1 == 2) 
                    alfarr[2] = (ONE - approx_facta) * alfa2c_a
                              + approx_facta  * alfarr[2];

                }
            }

         cptodvBSblndsrfg2 ( 3, cont1, dir_sf1_ord, cr_mesh_sf1, sig_tga,
                            p0, p1, p2, pdrv0, pdrv1, pdrv2 );
         if ( blnd_rat )
            cptodvBSblndsrfg2 ( 1, cont1, dir_sf1_ord, cr_mesh_sf1, sig_tga,
                           wp0, wp1, wp2, &pdrv0[3], &pdrv1[3], &pdrv2[3] );

/******    handle singular case    *******/

         if ( jpol == 0 && pole_dega[0] != 0 )
            for (k=0; k<3; k++) {pdrv1[k] = dpta_s[k]; pdrv2[k] = ZERO;}

         if ( jpol == cr_nump - 1 && pole_dega[1] != 0 )
            for (k=0; k<3; k++) {pdrv1[k] = dpta_e[k]; pdrv2[k] = ZERO;}
 
         gccondBSblndsrfg2 ( blnd_rat, cont1, pdrv0, pdrv1, pdrv2,
                             betarr, alfarr,  qdrv0, qdrv1, qdrv2 );

         dvtocpBSblndsrfg2 ( 3, cont1, cr_mesh_sfb1, ONE,
                             qdrv0, qdrv1, qdrv2, q0, q1, q2  );
         if ( blnd_rat )
            dvtocpBSblndsrfg2 ( 1, cont1, cr_mesh_sfb1, ONE, 
                          &qdrv0[3], &qdrv1[3], &qdrv2[3], wq0, wq1, wq2 );


         if ( blnd_rat )  { wq0++; wp0++; wq1++; wp1++; }
         if (cont1 == 2)  { q2 += INCRJJ; p2 += INCRJJ;
                            if (blnd_rat) { wq2++; wp2++; } }
        }
       





    /*****************************

           second side (at sf2)         +++++++++++++

    *****************************/




    num_row = cont1 + 1;
    q0 = blndsrf->poles + 3*cr_nump*(blend_nump - 1);
    p0 = row_cp[num_row]->poles; 
    q1 = blndsrf->poles + 3*cr_nump*(blend_nump - 2);
    p1 = row_cp[num_row + 1]->poles;
    if (cont2 == 2) { q2 = blndsrf->poles + 3*cr_nump*(blend_nump - 3);
                      p2 = row_cp[num_row + 2]->poles; }

 
    if ( blnd_rat )
       {
        wq0 = blndsrf->weights + cr_nump*(blend_nump - 1);
        wp0 = row_cp[num_row]->weights;
        wq1 = blndsrf->weights + cr_nump*(blend_nump - 2);
        wp1 = row_cp[num_row + 1]->weights;
        if (cont2 == 2)
           {
            wq2 = blndsrf->weights + cr_nump*(blend_nump - 3);
            wp2 = row_cp[num_row + 2]->weights;
           }
       } 

    for (jpol = 0; jpol < cr_nump; jpol++, q0 += INCRJJ, p0 += INCRJJ,
                                           q1 += INCRJJ, p1 += INCRJJ)
        {
         if ( blnd_rat )
            { wg0 = *wp0; wg1 = *wp1; if (cont2 == 2) wg2 = *wp2; }
         if ( approx_flag[1] <= 0 )
            {
             betarr[0] = beta1c_b; if (cont2 == 2) betarr[1] = beta2c_b; 
             if ( blnd_rat )
                {
                 alfarr[0] = alfa0c_b; alfarr[1] = alfa1c_b;
                 if (cont2 == 2)  alfarr[2] = alfa2c_b;
                }
            }
         else
            {
             betarr[0] =                  (ONE - approx_factb) * beta1c_b
                                               + approx_factb  * ldb[jpol];
             if (cont2 == 2)  betarr[1] = (ONE - approx_factb) * beta2c_b
                                               + approx_factb  * myb[jpol];
             if ( blnd_rat )
                {
                 alfarr[0] = alfa0c_b;

                 v_shBSblndsrfg2 ( cont2, dir_sf2_ord, wg0, wg1, wg2,
                                   cr_mesh_sf2, cr_mesh_sfb2,
                                   sig_tgb, betarr[0], betarr[1], alfarr[0],
                                   &(alfarr[1]), &(alfarr[2]) );

                 alfarr[1] = (ONE - approx_factb) * alfa1c_b
                           + approx_factb  * alfarr[1];

                 if (cont1 == 2) alfarr[2] = (ONE - approx_factb) * alfa2c_b
                                           + approx_factb  * alfarr[2];
                }
            }

         cptodvBSblndsrfg2 ( 3, cont2, dir_sf2_ord, cr_mesh_sf2, sig_tgb,
                            p0, p1, p2, pdrv0, pdrv1, pdrv2 );
         if ( blnd_rat )
            cptodvBSblndsrfg2 ( 1, cont2, dir_sf2_ord, cr_mesh_sf2, sig_tgb,
                           wp0, wp1, wp2, &pdrv0[3], &pdrv1[3], &pdrv2[3] );


/******    handle singular case    *******/



         if ( jpol == 0 && pole_degb[0] != 0 )
            for (k=0; k<3; k++) {pdrv1[k] = dptb_s[k]; pdrv2[k] = ZERO;}

         if ( jpol == cr_nump - 1 && pole_degb[1] != 0 )
            for (k=0; k<3; k++) {pdrv1[k] = dptb_e[k]; pdrv2[k] = ZERO;}


         gccondBSblndsrfg2 ( blnd_rat, cont2, pdrv0, pdrv1, pdrv2,
                             betarr, alfarr,  qdrv0, qdrv1, qdrv2 );


         dvtocpBSblndsrfg2 ( 3, cont2, cr_mesh_sfb2, ONE,
                             qdrv0, qdrv1, qdrv2, q0, q1, q2  );
         if ( blnd_rat )
            dvtocpBSblndsrfg2 ( 1, cont2, cr_mesh_sfb2, ONE, 
                         &qdrv0[3], &qdrv1[3], &qdrv2[3], wq0, wq1, wq2 );



         if ( blnd_rat )  { wq0++; wp0++; wq1++; wp1++; }
         if (cont2 == 2)  { q2 += INCRJJ; p2 += INCRJJ;
                            if (blnd_rat) { wq2++; wp2++; } }   
        }

     if (row_sm[0]) BSfreecv(rc, row_sm[0]);
     row_sm[0] = NULL;
     if (row_sm[1]) BSfreecv(rc, row_sm[1]);
     row_sm[1] = NULL;
     if (sf1_trm)   BSfreesf(rc, sf1_trm);
     sf1_trm = NULL;
     if (sf2_trm)   BSfreesf(rc, sf2_trm);
     sf2_trm = NULL;

     for ( i=0; i<6; i++)
         {
          if (row[i])    BSfreecv(rc, row[i]);
          row[i] = NULL;
          if (row_cp[i]) BSfreecv(rc, row_cp[i]);
          row_cp[i] = NULL;
          if (row_tr[i]) BSfreecv(rc, row_tr[i]);
          row_tr[i] = NULL;
         }

     if ( dealloc ) if (workarea)  BSstackdealloc ( (char*) workarea );

     *rc = BSSUCC; *inform = 0;
     *surf_blnd = blndsrf;    

     return;


wrapup:
     *rc = BSFAIL; *inform = -1;

     if (blndsrf)   BSfreesf(&rc_c, blndsrf);
     blndsrf = NULL;


     if (row_sm[0]) BSfreecv(&rc_c, row_sm[0]);
     row_sm[0] = NULL;
     if (row_sm[1]) BSfreecv(&rc_c, row_sm[1]);
     row_sm[1] = NULL;
     if (sf1_trm)   BSfreesf(&rc_c, sf1_trm);
     sf1_trm = NULL;
     if (sf2_trm)   BSfreesf(&rc_c, sf2_trm);
     sf2_trm = NULL;

     for ( i=0; i<6; i++)
         {

          if (row[i])    BSfreecv(&rc_c, row[i]);
          row[i] = NULL;
          if (row_cp[i]) BSfreecv(&rc_c, row_cp[i]);
          row_cp[i] = NULL;
          if (row_tr[i]) BSfreecv(&rc_c, row_tr[i]);
          row_tr[i] = NULL;
         }


     if ( dealloc )
       if ( workarea )BSstackdealloc ( (char*) workarea );

     return;
                 
   } 


 static void r_shBSblndsrfg2 (IGRint cont, IGRshort iord,
                              struct IGRbsp_curve *row[3],
                              IGRdouble mesh[3], IGRdouble tmesh[3],
                              IGRdouble sign, 
                              IGRdouble beta1, IGRdouble beta2,
                              IGRdouble *alfa0, IGRdouble *alfa1,
                              IGRdouble *alfa2                          )

{

/********       determine shape factor for rational blend     ************/



#include  "bsdefs.h" 

 #define  ZERO         0.0
 #define  ONE          1.0
 #define  TWO          2.0 
 #define  HALF         0.5 
 #define  FAC_RED_WG   0.2 

 #define  SQ(a)        (a*a)

 IGRint n, j;
 IGRdouble a0_msh, a0_tmsh, a1_msh, a1_tmsh, a2_msh, a2_tmsh; 
 IGRdouble alfa, alf0, alfn, alf_min;
 IGRdouble g10, g20;


/***********    calculate form factors for rational case   ***********/

 /*  make compiler happy  */
 alfn = ZERO;
 a2_msh = a2_tmsh = ONE;

 n = row[0]->num_poles - 1;

 a0_msh = ONE/mesh[0]; a0_tmsh = ONE/tmesh[0];
 *alfa0 = TWO/(row[0]->weights[0] + row[0]->weights[n]); 

 g10 = row[1]->weights[0]/row[0]->weights[0];
 alf0 = sign*beta1*(ONE - g10); 
 alfa = alf0; 

 for ( j = 1; j <= n; j++ )
     {
      g10 = row[1]->weights[j]/row[0]->weights[j];
      alfn = sign*beta1*(ONE - g10); 
      if (alfn > alfa) alfa = alfn;
     }
 alf_min = alfa * (*alfa0) * (a0_msh/a0_tmsh) + (FAC_RED_WG - ONE)*(*alfa0);
 alf0 = alf0 * (*alfa0) * (a0_msh/a0_tmsh);
 alfn = alfn * (*alfa0) * (a0_msh/a0_tmsh);

 *alfa1 = MAX ( alf_min , HALF*(alf0 + alfn) ) * a0_tmsh;

 if (cont == 2)
     {
      a1_msh = ONE/mesh[1]; a1_tmsh = ONE/tmesh[1];

      g10  = row[1]->weights[0]/row[0]->weights[0];
      alf0 = (TWO*(*alfa1)*beta1 + (*alfa0)*beta2)*a0_msh*sign*(ONE - g10);
 
      if ( iord > 2 )
         {
          a2_msh = ONE/mesh[2]; a2_tmsh = ONE/tmesh[2];
          g20 = row[2]->weights[0]/row[0]->weights[0];

          alf0 = alf0 + (*alfa0)*SQ(beta1)*a2_msh* ( a1_msh*(ONE - g20)
                        - (a0_msh + a1_msh)*(ONE - g10) ); 
         }

      alfa = alf0; 
      for ( j = 1; j <= n; j++ )
          {
           g10 = row[1]->weights[j]/row[0]->weights[j];
           alfn = (TWO*(*alfa1)*beta1 + (*alfa0)*beta2)*a0_msh*sign*(ONE - g10);
           if ( iord > 2 )
              {
               g20 = row[2]->weights[j]/row[0]->weights[j];
               alfn = alfn + (*alfa0)*SQ(beta1)*a2_msh
                    * ( a1_msh*(ONE - g20) + (a0_msh + a1_msh)*(ONE - g10) ); 
              }
           if (alfn > alfa) alfa = alfn;
          }
      alf_min = alfa + (*alfa0) * a1_tmsh *a2_tmsh * (FAC_RED_WG - ONE)
               - (*alfa0) * a0_tmsh*a1_tmsh;

      *alfa2 = MAX ( alf_min , HALF*(alf0 + alfn) );
     }
     

  return;
 }



 static void v_shBSblndsrfg2 (IGRint cont, IGRshort iord, IGRdouble wg0,
                              IGRdouble wg1, IGRdouble wg2,
                              IGRdouble mesh[3], IGRdouble tmesh[3],
                              IGRdouble sign,
                              IGRdouble beta1, IGRdouble beta2,
                              IGRdouble alfa0, IGRdouble *alfa1,
                              IGRdouble *alfa2                          )

{

/********       determine variable shape parameter for rational blend 
                requiring weights to be constant            ************/




 #define  ONE          1.0
 #define  TWO          2.0 

 #define   SQ(a)         (a*a)

 IGRdouble a0_msh, a0_tmsh, a1_msh, a1_tmsh, a2_msh, a2_tmsh; 
 IGRdouble g10, g20;


/***********    calculate form factors for rational case   ***********/


 a0_msh = ONE/mesh[0]; a0_tmsh = ONE/tmesh[0];
 g10    = wg1/wg0;
 *alfa1 = alfa0 * a0_msh * beta1 * sign* (ONE - g10);


 if (cont == 2)
     {
      a1_msh = ONE/mesh[1]; a1_tmsh = ONE/tmesh[1];

      *alfa2 = (TWO*(*alfa1)*beta1 + alfa0*beta2)*a0_msh*sign*(ONE - g10);
 
      if ( iord > 2 )
         {
          a2_msh = ONE/mesh[2]; a2_tmsh = ONE/tmesh[2];
          g20 = wg2/wg0;

          *alfa2 = *alfa2 + alfa0*SQ(beta1) *a2_msh* ( a1_msh*(ONE - g20)
                          - (a0_msh + a1_msh)*(ONE - g10) ); 
         }
     }
     

  return;
 }



 static void cpr3dvBSblndsrfg2 ( IGRboolean            rat,
                                 IGRint                cont,
                                 IGRshort              order,
                                 IGRdouble             mesh[3],
                                 IGRdouble             sign,
                                 IGRdouble             cp0[3],
                                 IGRdouble             cp1[3],
                                 IGRdouble             cp2[3],
                                 IGRdouble             wg0,
                                 IGRdouble             wg1,
                                 IGRdouble             wg2,
                                 IGRdouble             pt[3],
                                 IGRdouble             dpt[3],
                                 IGRdouble             ddpt[3]     )
  
  {

/********   calculate R3-derivatives from poles and weights  ***********/

/*   declaration - begin   */


   #define   ZERO          0.0
   #define   TWO           2.0
   #define   SQ(a)        (a*a)

   IGRint     k;
   IGRdouble  wg, dwg, ddwg, qt[3], dqt[3], ddqt[3]; 

/*   declaration - end     */




/********************************************************************    
*
*               Start of executable code    
*  
********************************************************************/

     /*  make compiler happy  */
     dwg = ddwg = ZERO;

     for ( k = 0; k < 3; k++ )
         {
          pt[k] = qt[k] = cp0[k];
          if (cont > 0)   dpt[k] = dqt[k] = sign*(cp1[k] - cp0[k])/mesh[0]; 
          if (cont > 1)
             { 
              if (order == 2) ddpt[k] = ddqt[k] = ZERO; 
              else            ddpt[k] = ddqt[k] = ( (cp2[k] - cp1[k])/mesh[1]
                                      -   (cp1[k] - cp0[k])/mesh[0] )/mesh[2];
             }
         }  

     if (rat)
        {
         wg = wg0;
         if (cont > 0)   dwg = sign*(wg1 - wg0)/mesh[0]; 
         if (cont > 1) 
            {
             if (order == 2) ddwg = ZERO; 
             else            ddwg = ( (wg2 - wg1)/mesh[1]
                                  -   (wg1 - wg0)/mesh[0] )/mesh[2];
            }
  
         for ( k = 0; k < 3; k++ )
             {
              pt[k]  = qt[k]/wg;
              if (cont > 0)   dpt[k] = (wg*dqt[k] - dwg*qt[k])/SQ(wg); 
              if (cont > 1)
                 ddpt[k] = -(TWO*dwg/wg)*dpt[k]
                         + (wg*ddqt[k] - ddwg*qt[k])/SQ(wg);
             } 
         }  




/*************************************************************************
*
*              Wrapup and return
*
*************************************************************************/

    return;     

   } 




 static void cptodvBSblndsrfg2 ( IGRint                dim,
                                 IGRint                cont,
                                 IGRshort              order,
                                 IGRdouble             mesh[3],
                                 IGRdouble             sign,
                                 IGRdouble             cp0[3],
                                 IGRdouble             cp1[3],
                                 IGRdouble             cp2[3],
                                 IGRdouble             pt[3],
                                 IGRdouble             dpt[3],
                                 IGRdouble             ddpt[3]     )
  
  {

/***********    calculate derivatives from poles     *************/

/*   declaration - begin   */


   #define   ZERO          0.0

   IGRint k;

/*   declaration - end     */




/********************************************************************    
*
*               Start of executable code    
*  
********************************************************************/


     for ( k = 0; k < dim; k++ )
         {
          pt[k]  = cp0[k];
          if (cont > 0)   dpt[k] = sign*(cp1[k] - cp0[k])/mesh[0]; 
          if (cont > 1) 
             {
              if (order == 2) ddpt[k] = ZERO; 
              else  ddpt[k] = (  ( cp2[k] - cp1[k] )/mesh[1]
                                -( cp1[k] - cp0[k] )/mesh[0] )/mesh[2];
             }
         }  


/*************************************************************************
*
*              Wrapup and return
*
*************************************************************************/


    return;     

   } 

 static void dvtocpBSblndsrfg2 ( IGRint                dim,
                                 IGRint                cont,
                                 IGRdouble             mesh[3],
                                 IGRdouble             sign,
                                 IGRdouble             pt[3],
                                 IGRdouble             dpt[3],
                                 IGRdouble             ddpt[3], 
                                 IGRdouble             cp0[3],
                                 IGRdouble             cp1[3],
                                 IGRdouble             cp2[3]    )

  
  {

/***********    calculate poles from derivatives    *************/


/*   declaration - begin   */


   #define   ZERO          0.0

   IGRint k;

/*   declaration - end     */





/********************************************************************    
*
*               Start of executable code    
*  
********************************************************************/


     for ( k = 0; k < dim; k++ )
         {
          cp0[k] = pt[k];
          if (cont > 0)   cp1[k] = cp0[k] + sign*mesh[0]*dpt[k];
          if (cont > 1) 
             cp2[k] = cp1[k] + mesh[1]*sign*dpt[k] + mesh[1]*mesh[2]*ddpt[k];
         }  


/*************************************************************************
*
*              Wrapup and return
*
*************************************************************************/


    return;     

   } 


 static void gccondBSblndsrfg2 ( IGRboolean            rat,
                                 IGRint                cont,
                                 IGRdouble             pt[4],
                                 IGRdouble             dpt[4],
                                 IGRdouble             ddpt[4],
                                 IGRdouble             beta[2],
                                 IGRdouble             alfa[3],
                                 IGRdouble             qt[4],
                                 IGRdouble             dqt[4],
                                 IGRdouble             ddqt[4]  )
  {

/********       GC-conditions :
                transforms derivatives from one side to the other one
                                                             ****************/ 

/*   declaration - begin   */


   #define   TWO          2.0

   IGRint k;

/*   declaration - end     */




/********************************************************************    
*
*               Start of executable code    
*  
********************************************************************/

   if (!rat)
     for ( k = 0; k < 3; k++ )
         {
          qt[k] = pt[k];
          if (cont > 0) dqt[k]  = beta[0]*dpt[k];
          if (cont > 1) ddqt[k] = beta[0]*beta[0]*ddpt[k] + beta[1]*dpt[k];
         }
   else 
     for ( k = 0; k < 4; k++ )
         {
          qt[k] = alfa[0]*pt[k];
          if (cont > 0) dqt[k]  = alfa[1]*pt[k] + alfa[0]*beta[0]*dpt[k];
          if (cont > 1)
             {
              ddqt[k] = alfa[2]*pt[k] 
                      + ( TWO* alfa[1]*beta[0] + alfa[0]*beta[1] )*dpt[k] 
                      + alfa[0]*beta[0]*beta[0]*ddpt[k];
             }
         } 


/*************************************************************************
*
*              Wrapup and return
*
*************************************************************************/


    return;     

   } 



 static void betadvBSblndsrfg2 ( IGRint                cont,
                                 IGRdouble             dpt[3],
                                 IGRdouble             ddpt[3],     
                                 IGRdouble             dqt[3],
                                 IGRdouble             ddqt[3],
                                 IGRdouble             *beta1,
                                 IGRdouble             *beta2   )
  
  {

/********   determine beta-parameter for GC-conditions form derivatives :
                       dqt  = beta1*dpt
                       ddqt = (beta1**2)*ddpt + beta2*dpt         ********/

/*   declaration - begin   */


   IGRdouble scal1, scal2, sq_dv1;

/*   declaration - end     */




/********************************************************************    
*
*               Start of executable code    
*  
********************************************************************/

     sq_dv1 = dpt[0]*dpt[0] + dpt[1]*dpt[1] + dpt[2]*dpt[2]; 
     scal1  = dpt[0]*dqt[0] + dpt[1]*dqt[1] + dpt[2]*dqt[2];
     *beta1 = scal1/sq_dv1; 

     if (cont > 1)
        {
         scal1  = dpt[0]*ddpt[0] + dpt[1]*ddpt[1] + dpt[2]*ddpt[2];
         scal2  = dpt[0]*ddqt[0] + dpt[1]*ddqt[1] + dpt[2]*ddqt[2];
         *beta2 = (scal2 - (*beta1)*(*beta1)*scal1)/sq_dv1;
        }



/*************************************************************************
*
*              Wrapup and return
*
*************************************************************************/


    return;     

   } 



 static void pttoliBSblndsrfg2 ( IGRint                insw,
                                 IGRdouble             pt[3],
                                 IGRdouble             pt0[3],     
                                 IGRdouble             dpt[3],
                                 IGRdouble             qt[3]   )
  
  {

/********      drop pt point to line : pt0 , dpt        ********/

/*   declaration - begin   */

   IGRdouble scal, sq_dv1;

/*   declaration - end     */




/********************************************************************    
*
*               Start of executable code    
*  
********************************************************************/


     scal = (pt[0] - pt0[0])*dpt[0] + (pt[1] - pt0[1])*dpt[1]
                                    + (pt[2] - pt0[2])*dpt[2];
     if (insw != 1) 
        {  
         sq_dv1 = dpt[0]*dpt[0] + dpt[1]*dpt[1] + dpt[2]*dpt[2];
         scal  = scal/sq_dv1;
        }
 
     qt[0]  = pt0[0] + scal*dpt[0]; 
     qt[1]  = pt0[1] + scal*dpt[1]; 
     qt[2]  = pt0[2] + scal*dpt[2]; 


/*************************************************************************
*
*              Wrapup and return
*
*************************************************************************/


    return;     

   } 



 static void end_weigts_BSblndsrfg( IGRdouble wg_start,
                                    IGRdouble wg_end,
                                    IGRdouble wg_tol,
                                    struct IGRbsp_curve *curve   )


  
  {

/********    The purpose of this routine is just to undo weight-
             changing done by routine *bsmkcvspc*.
             The weights at the curve ends are therefore assumed
             to be one.                                           ********/

/*   declaration - begin   */

#include <math.h>

   #define   ONE          1.0
   #define   HALF         0.5
   IGRint    i, k, n, np;
   IGRdouble facs, facs0, face, face0, expo;
   IGRdouble *wg, *pole;


/*   declaration - end     */



/********************************************************************    
*
*               Start of executable code    
*  
********************************************************************/


   if ( (fabs(wg_start - ONE) < wg_tol)  && (fabs(wg_end - ONE) < wg_tol) )
      goto wrapup;

   wg   = curve->weights;
   pole = curve->poles;

   n    = curve->order - 1;
   np   = curve->num_poles - 1;    

   if ( fabs(wg_end - wg_start) < wg_tol ) 
      {
       facs = HALF*(wg_end + wg_start);
       for ( i = 0; i <= np; i++ )
           { *(wg++) *= facs; for ( k = 0; k < 3; k++ ) *(pole++) *= facs; }
       wg = curve->weights; *wg = wg_start; *(wg + np) = wg_end;
       goto wrapup; 
      }            

   wg = wg + n - 1; pole = pole + 3*(n - 1) + 2;
   expo = ONE/n;
   facs = facs0 = pow (wg_start, expo);  

   for ( i = 0; i < n; i++ )
       {
        *wg *= facs;
         for ( k = 0; k < 3; k++ ) { *pole *= facs; pole--; }
         wg--; facs *= facs0;
       }
  
   wg   = curve->weights + np - n + 1;
   pole = curve->poles   + 3*(np - n + 1);
   face = face0 = pow (wg_end, expo);   

   for ( i = 0; i < n; i++ )
       { *wg *= face; 
         for ( k = 0; k < 3; k++ ) { *pole *= face; pole++; }
         wg++; face *= face0;
       }


   wg = curve->weights; *wg = wg_start; *(wg + np) = wg_end; 





/*************************************************************************
*
*              Wrapup and return
*
*************************************************************************/
 
wrapup:
    return;     

   } 


