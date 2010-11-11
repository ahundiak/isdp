/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsdefs_include
# define bsdefs_include

# if defined(HP) || defined(NT)
# define SIGBUS 10
# endif

# define BS2DMETHOD 2
# define BS3DMETHOD 3

# define BSINSIDE   1
# define BSON       0
# define BSOUTSIDE  -1

#define BSBASECANONIQUE 0
#define BSBASELEGENDRE 1
#define BSBASETCHEBYCHEV 2
#define BSBASEBEZIER 3
#define BSBASEBERNSTEIN 3

# ifndef NULL
# define NULL 0
# endif

# define ABS(x)     ((x) < 0 ? -(x) : (x))
# define MAX(x,y)   (((x) < (y))? (y):(x))
# define MIN(x,y)   (((x) < (y))? (x):(y))

# define RNGNUM 20

# ifndef bstypes_include
#   include "bstypes.h"
# endif

#define swap_pts(x,y)                            \
{IGRpoint     temp;                              \
 IGRint       ii = 2;                            \
              do                                 \
              {                                  \
                temp[ii] = x[ii];                \
                x[ii] = y[ii];                   \
                y[ii] = temp[ii];                \
              }while (ii--);                     \
}


struct BSlsfamily_elt
{
    IGRpoint          point;
    IGRdouble         knot, u, v, c1, c2;
    IGRvector         unormal;
    IGRvector         tangent;
    struct BSlsfamily_elt *next;
};

struct BSlsfamily
{
    struct BSlsfamily_elt *first;
    IGRint        members;
    struct BSlsfamily     *next;
};

struct BSintersection
{
    IGRpoint point;
    IGRdouble u,v;
    struct BSintersection *next;
};

struct BSpar_slis       /* singly linked list of parameter values */
{
    IGRdouble value;
    struct BSpar_slis *next;
};

struct BSpt_slis        /* singly linked list of points */
{
    IGRpoint value;
    struct BSpt_slis *next;
};

struct BSpt_dlis        /* doubly linked list of points */
{
    IGRpoint qpt;
    struct BSpt_dlis *flink;
    struct BSpt_dlis *blink;
};

struct BSintpt_slis     /* singly linked list of intersection points */
{
    IGRpoint int_pts;
    IGRdouble par0, par1;
    struct BSintpt_slis *next;
};

struct BScurve_slis
{
    struct IGRbsp_curve *c_pt;
    struct BScurve_slis *next;
};

struct BScv_slis
{
    struct IGRbsp_curve cv;
    struct BScv_slis *next;
    IGRint depth;
    BSaddr name;
};

struct BSmem_slis
{
    BSaddr mem;
    struct BSmem_slis *next;
};

struct BSpt_par_elem
{
    IGRpoint pt;
    IGRdouble par[2];
};

struct BSpt_par_ptr_elem
{
    IGRdouble *pt;
    IGRdouble *par[2];
};

struct BSmin_max_box
{
    IGRpoint min, max;
    IGRboolean valid;
    IGRboolean degenerate;
};

struct BScv_endpts
{
  IGRpoint              endpts[2];
  struct IGRbsp_curve   *curve;
};

struct BSvda_cv_seg
{
  IGRshort    order;
  IGRboolean  rational;
  IGRdouble   *xcoef;
  IGRdouble   *ycoef;
  IGRdouble   *zcoef;
  IGRdouble   *wcoef;
};

struct BSvda_sf_pch
{
  IGRshort    u_order;
  IGRshort    v_order;
  IGRboolean  rational;
  IGRdouble   *xcoef;
  IGRdouble   *ycoef;
  IGRdouble   *zcoef;
  IGRdouble   *wcoef;
};

struct BSstf_surface        /* output - standard format surface */
{  
  IGRint      sftype;            /* surface type :               */
                                 /*    1 = ruled surface         */
                                 /*    2 = proportion surface    */
                                 /*    3 = chord height blend    */
  IGRint      numprimbnd;        /* # of primary boundaries      */
  IGRint      numscndbnd;        /* # of secondary boundaries    */
  IGRint      blendtype;         /* type of blend :              */
                                 /*    1 = linear                */
                                 /*    2 = cubic                 */
  IGRboolean  normaldir;         /* direction of normal :        */
                                 /*    0 = as defined            */
                                 /*    1 = reversed              */
  IGRboolean  primclsd;          /* primary closed (TRUE)        */
  IGRboolean  scndclsd;          /* secondary closed (TRUE)      */
  IGRint      triang;            /* indicates if surface patches */
                                 /* are triangular (1) or        */
                                 /* quadratic (2)                */
  IGRint      numptsprim;        /* # of points on primary       */
                                 /* boundaries                   */
  IGRint      numptsscnd;        /* # of points on secondary     */
                                 /* boundaries                   */
  IGRdouble   *ptsprim;          /* points on primary boundary   */
  IGRdouble   *ptsscnd;          /* points on secondary boundary */
  IGRint      numDptsprim;       /* # of D points on primary     */
  IGRint      numDptsscnd;       /* # of D points on secondary   */
  IGRint      *indDprim;         /* indeces of D points on       */
                                 /* primary                      */
  IGRint      *indDscnd;         /* indeces of D points on       */
                                 /* secondary                    */
};

struct BSpolylgd
{
  IGRint                deg;
  IGRdouble             *coeff;
  BSpair                intval;
};

struct BSlgd_srs_prp
{
    IGRint ndeg;
    IGRdouble *polycan;
    IGRdouble pi1;
    IGRdouble *divpoly;
    IGRdouble umin,umax;
    IGRdouble tlim[2];
};

struct BSpolcv
{
  IGRint      type  ;  /* kind of polynomial basis used:                */
                       /*        LEGEND = legendre			*/
                       /*        BEZIER = bezier			*/
                       /*        CANONI = canonical			*/
                       /*           ... = ...				*/
  IGRint      ndim  ;  /* number of geometrical dimension		*/
                       /* of the curve (1,2,3 usually)  		*/
  IGRint      ndeg  ;  /* maximum degree of the polynomial		*/
                       /* defining the components of the curve.		*/
                       /*(the array curve may contain some 0.0 at	*/
                       /*  the end of each series of coefficients)	*/
  IGRint      irat  ;  /* say if curve is rationnal or not :		*/
                       /*  RAT0   = no rationnal component	 iof= 0	*/
                       /*  RAT1   = first component is rationn   iof= 1 */
                       /*  RAT2   = second component is ration.  iof= 1	*/
                       /*  RAT12  = first and second are ration. iof= 2	*/
                       /*  RAT3   = third component is rationnal iof= 1	*/
                       /*  RAT13  = first+third component ratio. iof= 2	*/
                       /*  RAT23  = second+third component rati. iof= 2	*/
                       /*  RAT123 = 3 components are rationnal   iof= 3	*/
                       /*  RATALL =all components have same deno iof= 1	*/
                       /* iof is the artificial increase of dimension of*/
                       /* the curve to get dimension of array of coeffi.*/
   		       /* so  : iof = BStypcvdim1(irat)                 */
  IGRdouble   *coef ;  /* array[0:ndim-1+iof,0:ndeg] of coefficients    */
                       /* of the curve 					*/
};

# define RAT0     0
# define RAT1     1
# define RAT2     2
# define RAT12    3
# define RAT3     4
# define RAT13    5
# define RAT23    6
# define RAT123   7
# define RATALL   8

     /* type of lowest structure (BSbspcv,BSpolcv,BSpcscv...)	*/
# define LEGEND     100     /* legendre basis 				*/
# define BEZIER     200     /* bezier basis 				*/
# define CANONI     300     /* canonical basis				*/ 
# define BSPLIN     400     /* bezier basis for spline			*/
     /* the type of BSpcscv can be CVPOLY if we don't want to say what
        the type of each span of the global curve may be (legendre or
        bezier or canonical or a merge of this			*/

     /* type of highest structure (BScurve,BSsurfa...)		*/
# define CVSPLI    500      /* spline curve  (bezier,...)		*/
# define CVPOLY    600      /* polynomial cv (legendre,bezier,canoni...)*/
# define CVPIECES  650      /* pieces wise curve (set of existing curve)*/
# define SFSPLI    800      /* spline surface (bezier,...)		*/
# define SFPOLY    900      /* polynomial sf (legendre,bezier,canoni...)*/

struct BSpolsf
{
  IGRint      type  ;  /* kind of polynomial basis used:            	*/
                       /*        LEGEND = legendre			*/
                       /*        BEZIER = bezier			*/
                       /*        CANONI = canonical			*/
                       /*           ... = ...				*/
  IGRint      ndim  ;  /* number of geometrical dimension		*/
                       /* of the surface (1,2,3 usually)  		*/
  IGRint      ndegu ;  /* maximum degree in u of the polynomial		*/
                       /* defining the components of the surface.	*/
                       /* (the array surface may contain some 0.0 at	*/	
                       /*  the end of each series of coefficients in u)	*/
  IGRint      ndegv ;  /* maximum degree in v of the polynomial		*/
                       /* defining the components of the surface.	*/
                       /* (the array surface may contain some 0.0 at	*/	
                       /*  the end of each series of coefficients in v)	*/
  IGRint      irat  ;  /* say if surface is rationnal or not :		*/
                       /*  RAT0   = no rationnal component	 iof= 0	*/
                       /*  RAT1   = first component is rationn   iof= 1 */
                       /*  RAT2   = second component is ration.  iof= 1	*/
                       /*  RAT12  = first and second are ration. iof= 2	*/
                       /*  RAT3   = third component is rationnal iof= 1	*/
                       /*  RAT13  = first+third component ratio. iof= 2	*/
                       /*  RAT23  = second+third component rati. iof= 2	*/
                       /*  RAT123 = 3 components are rationnal   iof= 3	*/
                       /*  RATALL =all components have same deno iof= 1	*/
                       /* iof is the artificial increase of dimension of*/
                       /* the surfa to get dimension of array of coeffi.*/
   		       /* so  : iof = BStypcvdim1(irat)                 */
  IGRdouble   *coef ;  /* array[0:ndim-1+iof,0:ndegv,0:ndegu] of 		*/
                       /* coefficient of the surface			*/
};

struct BSwrkcv
{
  IGRint      type     ; /* kind of working area:			*/
                 /* CVPOLY : wrkg area of polynomial curve (rat. or not)*/
                 /* CVSPLI : wrkg area of bspline curve (rat. or not)   */
  IGRint      cvmx     ; /* maximum number of curve storable	 	*/
  IGRint      nbcv     ; /* current number of curve already stored	*/
  IGRint      ndimmx   ; /* maximum spatial dimension for the curve	*/
  IGRint      ordrmx   ; /* maximum order (bezier) or degree+1 (polyn)	*/
  IGRint      npolmx   ; /* maximum number of poles for one bspline cv  */
                         /* must be = ordermx / case of a wkg of CVPOLY */
  IGRint      sizeot   ; /* number of doubles to store in "others" part */
                         /* of the structure BScurve (non null pointer) */

  struct BScurve *adr1 ; /* allocated adress of the array of pointeurs  */
                         /* to the general structures of curves         */
  IGRchar     *adr2    ; /* allocated adress of the array of structures */	
  IGRchar     *adr2c   ; /* current address available in array of struc */
  IGRchar     *adr2end ; /* first address forbidden in array of struc   */	

  IGRdouble   *adr3    ; /* allocated adress of the array of coeffici.  */	
  IGRdouble   *adr3c   ; /* current address available in array of coef  */	
  IGRdouble   *adr3end ; /* first address forbidden in array of coef    */	
};

struct BSwrksf
{
  IGRint      type     ; /* kind of working area:			*/
                 /* SFPOLY : wrkg area of polynomial surf. (rat. or not)*/
                 /* SFSPLI : wrkg area of bspline surf. (rat. or not)   */
  IGRint      sfmx     ; /* maximum number of surfaces storable	 	*/
  IGRint      nbsf     ; /* current number of surfaces already stored	*/
  IGRint      ndimmx   ; /* maximum spatial dimension for the curve	*/
  IGRint      xordmx   ; /* maximum orderu*orderv (bspline or polyn.)	*/
  IGRint      xpolmx   ; /* maximum total number of poles for 1 bspline */
                         /* must be = xordmx / case of a wkg of CVPOLY  */
   
  struct BSsurfa *adr1 ; /* allocated adress of the array of pointeurs  */
                         /* to the array of structure of surfaces       */
  IGRchar     *adr2    ; /* allocated adress of the array of structures */	
  IGRchar     *adr2c   ; /* current address available in array of struc */
  IGRchar     *adr2end ; /* first address forbidden in array of struc   */	

  IGRdouble   *adr3    ; /* allocated adress of the array of coeffici.  */	
  IGRdouble   *adr3c   ; /* current address available in array of coef  */	
  IGRdouble   *adr3end ; /* first address forbidden in array of coef    */	
};

struct BSbspcv
{
  IGRint     type     ;  /* type of the entity :	            	*/
                         /*        BSPLIN = b-spline			*/
  IGRint     ndim     ;  /* number of geometrical dimension		*/
                         /* of the curve (1,2,3 usually)  		*/
  IGRint     order    ;  /* order of the curve	 			*/
  IGRlong    nbpol    ;	 /* number of poles				*/
                         /* number of knots is (num_poles + order)	*/
  IGRint      irat  ;  /* say if and how curve is rationnal or not :    */
                       /*  RAT0   = no rationnal component	 iof= 0	*/
                       /*  RAT1   = first component is rationn   iof= 1 */
                       /*  RAT2   = second component is ration.  iof= 1	*/
                       /*  RAT12  = first and second are ration. iof= 2	*/
                       /*  RAT3   = third component is rationnal iof= 1	*/
                       /*  RAT13  = first+third component ratio. iof= 2	*/
                       /*  RAT23  = second+third component rati. iof= 2	*/
                       /*  RAT123 = 3 components are rationnal   iof= 3	*/
                       /*  RATALL =all components have same deno iof= 1	*/
                       /* iof is the artificial increase of dimension of*/
                       /* the curve to get dimension of array of coeffi.*/
   		       /* so  : iof = BStypcvdim1(irat)                 */
  IGRboolean unifo    ;	 /* uniform(TRUE) /non-uniform(FALSE) knot vect.*/

  IGRdouble  *poles   ;	 /* pointer to array[0:ndim-1+iof,0:num_poles-1]*/
                         /* of poles (and eventually weights) . If 	*/
                         /* curve is rational the weights are stored as */
                         /* a (ndim+1) th component       		*/


  IGRdouble  *knots   ;	 /* pointer to array of knots [0:num_knots-1]	*/
};

struct BSbspsf
{
  IGRint     type     ;  /* type of the entity :	            	*/
                         /*        BSPLIN = b-spline			*/
  IGRint     ndim     ;  /* number of geometrical dimension		*/
                         /* of the curve (1,2,3 usually)  		*/
  IGRint     orderu   ;  /* order in u of the surface 			*/
  IGRint     orderv   ;  /* order in v of the surface 			*/
  IGRlong    nbpolu   ;	 /* number of poles in u 			*/
                         /* number of knots in u is (nbpolu + orderu)	*/
  IGRlong    nbpolv   ;	 /* number of poles in v 			*/
                         /* number of knots in v is (nbpolv + orderv)	*/
  IGRint     irat     ;	 /*  RAT0 (iof=0) ... RATALL(iof=1)             */
  IGRboolean unifo_u  ;	 /* uniform(TRUE) /non-uniform(FALSE) in u	*/
  IGRboolean unifo_v  ;	 /* uniform(TRUE) /non-uniform(FALSE) in v	*/

  IGRdouble  *poles   ;	 /* pointer to array of poles (and weight)	*/
                         /*  [0:ndim-1+iof,0:nbpolv-1,0:nbpolu-1]       */
                         /* if surf is rational the weights are stored  */
                         /* as a (ndim+1) th component       		*/

  IGRdouble  *uknots  ;	 /* pointer to array of knots [0:u_nb_knots-1]	*/
  IGRdouble  *vknots  ;	 /* pointer to array of knots [0:v_nb_knots-1]	*/
};

struct BSpcscv
{
  IGRint      type  ;  /* kind of piecewise curve used:                 */
                       /*  POLYNOMIAL = each span is a polynomial curve	*/
                       /*         ... = ...				*/
  IGRint      nbrpcs;  /* number of pieces composing the global curve	*/
                       /* the number of knots is num_knots = nbrpcs + 1 */
                       
  IGRint      *pieces; /* array[0:nbrpcs-1] of index (0..n) of BScurve  */
                       /* IN THE CURRENT WORKING AREA OF CURVE .	*/ 
                       /* (we should have BScurve **pieces instead , but*/
                       /*  as the BScurve pointer may be changed today  */
                       /*  by the automatic reallocation of wrk area ,  */
                       /*  we store the indexes which are stable)	*/
                       /* the pieces are assumed to be ordered in a     */
                       /* natural sens of moving along the global curve */
                       /* and to be well oriented along the global curve*/
                       /* as (-1)..-t->..(1) x (-1)..-t->..(1) x (-1).. */
                       /*     T0 ..--T-->....T1....--T-->....T2.....    */
                       /* we assume a continuous global curve.		*/
                       
  IGRdouble   *knotpcs;/* array[0:nbrpcs] of parameters (T) at starting */
                       /* point , connecting point and last point 	*/
                       /* the parameter is not assumed to move from -1  */
                       /* or 0 to 1 . It must be strictly monotonous ,  */
                       /* can be increasing or decreasing               */
};

union BStype_curve
{
    struct BSpolcv  *poly;  /* polynomial structure of curve	*/
    struct BSbspcv  *bspl;  /* bspline structure of curve	*/
    struct BSpcscv  *pces;  /* structure of pieceswise  curve   */
};                                             

union BStype_surfa
{
    struct BSpolsf  *poly;  /* polynomial structure of surface	*/
    struct BSbspsf  *bspl;  /* bspline structure of surface	*/
};                                             

struct BScurve
{
    IGRint               typecv ; /* type of cv CVPOLY,CVSPLI,CVPIECES..*/
    union BStype_curve   defini ; /* explicit representation of curve   */

    IGRint               dimecv ; /* dimension of the curve (1,2,3...)	*/

    IGRint               genus  ; /* type of others repres...(genus...) */
    IGRchar              *others; /* other representation (implicit...) */
};                                             

struct BSsurfa
{
    IGRint               typesf ; /* type of curve SFPOLY,SFSPLI ...	*/
    union BStype_surfa   defini ; /* explicit representation of surface */

    IGRint               dimesf ; /* dimension of the surface (1,2,3...)*/

    IGRint               typoth ; /* type of others (implicit repres...)*/
    IGRchar              *others; /* other representation (implicit...) */
};                                             

struct BSres_cv
{
    IGRint          ncvmax;
    IGRint          coefmax;
    IGRint          num_cvs;
    IGRint          *ndegtab;
    IGRint          *rattab;
    IGRint          *genus;
    IGRdouble       *cvlgd;
    BSpair          *uv_start;
    BSpair          *uv_end;
};

struct BScirc_arc
{
    IGRpoint        center;
    IGRpoint        stpt;
    IGRdouble       radius;
};

# endif /* bsdefs_include */
