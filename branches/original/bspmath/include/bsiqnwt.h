/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsiqnwt_include
# define bsiqnwt_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGR types */
# endif

# ifndef igr_include
#   include "igr.h" /* IGR structs */
# endif

struct BScostcosit_qnwt_struct
{
    IGRshort                  iso_opt1;
    IGRdouble                 iso_par1;
    struct IGRbsp_curve       *cv1;
    IGRshort                  iso_opt2;
    IGRdouble                 iso_par2;
    struct IGRbsp_curve       *cv2;
    struct BSgeom_bsp_surf    *sf1;
    struct BSgeom_bsp_surf    *sf2;
    IGRint                    n1_ind;
    IGRint                    n2_ind;
    IGRdouble                 rad;
    IGRdouble                 tpar;
    IGRdouble                 spar;
};

struct BScosftsfit_qnwt_struct
{
    IGRpoint              pt;
    IGRvector             vec;
    IGRint                ind;
    IGRdouble             rad;
    BSpair                uv;
    struct IGRbsp_surface *surf;
};

struct BSfillet_qnwt_struct
{
    struct IGRbsp_curve *curve1, *curve2;
    IGRdouble radius;
    IGRpoint point;
};

struct BSgncvfill_qnwt_struct
{
    struct IGRbsp_curve *curve1, *curve2;
    IGRdouble radius1;
    IGRdouble radius2;
    IGRshort  nor_flag1;
    IGRshort  nor_flag2;
    IGRpoint  point;
};

struct BSlnpttncv_qnwt_struct
{
    struct IGRbsp_curve *curve;
    IGRpoint point;
};

struct BSlntn2cvs_qnwt_struct
{
    struct IGRbsp_curve *curve1, *curve2;
};

struct BSlntncvncv_qnwt_struct
{
    struct IGRbsp_curve *curve1, *curve2;
};

struct BSlnn2cvs_qnwt_struct
{
    struct IGRbsp_curve *curve1, *curve2;
};

struct BSlnnorcvsf_qnwt_struct
{
    struct IGRbsp_curve *curve;
    struct IGRbsp_surface *surface;
};

struct BSlnnorsfsf_qnwt_struct
{
    struct IGRbsp_surface *surf1;
    struct IGRbsp_surface *surf2;
};

struct BSptperppch_qnwt_struct
{
    struct IGRbsp_surface *surf;
    IGRpoint point;
    IGRdouble dist_tol;
};

struct BSlnangptcv_qnwt_struct
{
    struct IGRbsp_curve *curve;
    IGRpoint point;     /* end point not on curve */
    IGRdouble angle;	/* radians, 0 <= angle < +/-2PI */
};

struct BSsfsf_int_qnwt_struct
{
    struct IGRbsp_surface *surf1;
    struct IGRbsp_surface *surf2;
    IGRint index;
    IGRdouble cpar;
};

struct BSsfnrpervc_qnwt_struct
{
    struct IGRbsp_surface *surf;
    IGRboolean            u_fix;
    IGRdouble             u,v;
    IGRpoint              pt;
    IGRvector             vec;
    IGRint                ind;
};

struct BScvnrcolvc_qnwt_struct
{
    struct IGRbsp_curve  *curve;
    IGRvector            vec;
};

struct BSsfnrcolvc_qnwt_struct
{
    struct IGRbsp_surface *surf;
    IGRvector             vec;
};

struct BSarcptrdcv_qnwt_struct
{
    struct IGRbsp_curve   *curve;
    IGRpoint              pt;
    IGRvector             nor;
    IGRdouble             par;
    IGRdouble             rad;
};

struct BSsfnrangvc_qnwt_struct
{
    struct IGRbsp_surface *surf;
    IGRboolean            u_fix;
    IGRdouble             u,v;
    IGRpoint              pt;
    IGRvector             vec;
    IGRdouble             ang;
    IGRint                ind;
};

struct BSofcvsfitr_qnwt_struct
{
    struct IGRbsp_surface *surf1, *surf2;
    IGRint                tconst;
    IGRdouble             urng1[2], vrng1[2], urng2[2], vrng2[2];
    IGRdouble             knot_tol1, knot_tol2;
    IGRdouble             dist1, dist2;
    IGRdouble             cpar;
};

struct BScsnrtcvit_qnwt_struct
{
    struct IGRbsp_surface *surf;
    IGRdouble uov;
    IGRboolean code;
    struct IGRbsp_curve *curve;
    IGRdouble dist_tol;
};

struct BSpjptimcnc_qnwt_struct
{
    IGRdouble A,B,C,D,E,F;
    IGRdouble Px,Py;
};

struct BStrpofsfit_qnwt_struct
{
    struct IGRbsp_surface *surf1, *surf2, *surf3;
    IGRdouble             urng1[2], vrng1[2], urng2[2], vrng2[2],
                          urng3[2], vrng3[2];
    IGRdouble             knot_tol1, knot_tol2, knot_tol3;
    IGRdouble             dist1, dist2, dist3;
};
struct BSfilsfedit_qnwt_struct
{
    struct IGRbsp_surface *surf1, *surf2, *surf3;
    IGRdouble             urng1[2], vrng1[2], urng2[2], vrng2[2],
                          urng3[2], vrng3[2];
    IGRdouble             knot_tol1, knot_tol2, knot_tol3;
    IGRdouble             r12, r13;
    IGRboolean            N13, N12, N2, N3;
    IGRint                type1, type2, type3;
    IGRvector             norm1, norm2, norm3;
};

union BSqnwt_union
{
    struct BScostcosit_qnwt_struct  *costcosit;
    struct BScosftsfit_qnwt_struct  *cosftsfit;
    struct BSgncvfill_qnwt_struct   *gncvfill;
    struct BSfillet_qnwt_struct     *fillet;
    struct BSlnpttncv_qnwt_struct   *lnpttncv;
    struct BSlntn2cvs_qnwt_struct   *lntn2cvs;
    struct BSlntncvncv_qnwt_struct  *lntncvncv;
    struct BSlnn2cvs_qnwt_struct    *lnn2cvs;
    struct BSlnnorcvsf_qnwt_struct  *lnnorcvsf;
    struct BSlnnorsfsf_qnwt_struct  *lnnorsfsf;
    struct BSptperppch_qnwt_struct  *ptperppch;
    struct BSlnangptcv_qnwt_struct  *lnangptcv;
    struct BSsfsf_int_qnwt_struct   *sfsf_int;
    struct BSsfnrpervc_qnwt_struct  *sfnrpervc; 
    struct BScvnrcolvc_qnwt_struct  *cvnrcolvc;
    struct BSsfnrcolvc_qnwt_struct  *sfnrcolvc;
    struct BSarcptrdcv_qnwt_struct  *arcptrdcv;
    struct BSsfnrangvc_qnwt_struct  *sfnrangvc;
    struct BSofcvsfitr_qnwt_struct  *ofcvsfitr;
    struct BScsnrtcvit_qnwt_struct  *csnrtcvit;
    struct BSpjptimcnc_qnwt_struct  *pjptimcnc;
    struct BStrpofsfit_qnwt_struct  *trpofsfit;
    struct BSfilsfedit_qnwt_struct  *filsfedit;
};                                             


struct BSqnwt_struct
{
/* input: */
    IGRdouble *bot, *top;
    IGRdouble epsilon, delta;
    IGRint n;
    IGRint max_it;
    IGRint full;
    IGRboolean *periodic;
    union BSqnwt_union qu;
    IGRdouble *i_par;

/* output: */
    IGRint num_it;
    IGRdouble *f_par;
    IGRdouble fvalue;
};

# endif /* bsiqnwt_include */
