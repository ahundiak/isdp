/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsplpchlgd_include
# define bsplpchlgd_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGR types */
# endif

struct BSequlgd12
{
    IGRdouble   *equlgd;         /* equlgd[ndegv,ndegu] */
    IGRdouble   *equlgdu;        /* equlgdu[ndegv,ndegu - 1] */
    IGRdouble   *equlgdv;        /* equlgdv[ndegv-1,ndegu] */
    IGRdouble   *equlgduu;       /* equlgduu[ndegv,ndegu - 2] */
    IGRdouble   *equlgduv;       /* equlgduv[ndegv-1,ndegu-1] */
    IGRdouble   *equlgdvv;       /* equlgdvv[ndegv-2,ndegu] */
};

struct BSboundary_sol
{
    BSpair      uminmax;
    BSpair      vminmax;
    IGRint      nsol[4];         /* [0]: nsolum1; [1]: nsolu1; */
                                 /* [2]: nsolvm1; [3]: nsolv1; */
    IGRdouble   *parum1;         /* parum1[ndegu] */
    IGRdouble   *paru1;          /* paru1[ndegu] */
    IGRdouble   *parvm1;         /* parvm1[ndegv] */
    IGRdouble   *parv1;          /* parv1[ndegv] */
    IGRint      ncorn[4];        /* 1, it is a corner, 0, it is not. */
};

struct BSmountain_sol
{
    IGRint      num_mount;
    IGRdouble   *uvmount;        /* uvmont[(ndegu + ndegv)**2,2] */ 
};

struct BStanghv_pts
{
    IGRint      num_horiz;
    IGRint      num_vert;
    IGRdouble   *uvhoriz;        /* uvhoriz[(ndegu + ndegv)**2,2] */
    IGRdouble   *uvvert;         /* uvvert[(ndegu + ndegv)**2,2] */
};

struct BSbox
{
    BSpair      uminmax;         /* uminmax[2] */
    BSpair      vminmax;         /* vminmax[2] */
};

struct BSlgd_curve
{
    IGRint          ncvmax;       /* Maximum number of curves allocated */
    IGRint          coefmax;      /* Maximum number of coefficients for */
                                  /* cvlgd allocated                    */
                                  /* = (MAXDEG + 1) * 4                 */
    IGRint          num_cvs;      /* number of curve found              */
    IGRint          *ndegtab;     /* degree of the Legendre curves      */
                                  /* dimenstion is ndegtab[0:num_cvs-1] */
    IGRint          *rattab;      /* rat = 0, non-rational              */
                                  /* rat = 1, rational in u             */
                                  /* rat = 2, rational in v             */
                                  /* rat = 3, ratoional in u and v      */
                                  /* dimenstion is rattab[0:num_cvs-1]  */
    IGRint          *genus;       /* genus of the curve                 */
    IGRdouble       **cvlgd;      /* cvlgd[num_cvs][dim*(ndeg[]+1)]     */
                                  /* dim = 2 if rat = 0                 */
                                  /* dim = 3 if rat = 1 or 2            */
                                  /* dim = 4 if rat = 3                 */
    BSpair          *uv_start;    /* starting u,v parameters of the     */
                                  /* curve, dimension [0:num_cvs-1]     */
    BSpair          *uv_end;      /* end u,v parameters of the curve    */
                                  /* dimension is [0:num_cvs-1]         */
};

struct BSbsp_curve
{
  IGRint     ncvmax;           /* maximum number of curves allocated    */
  IGRint     polmax;           /* maximum number of poles allocated     */
                               /* = MAX_POLES * maxdim                  */
  IGRint     knotmax;          /* maximum number of knots allocated     */
                               /* = (MAX_ORDER + MAX_POLES)    */
  IGRint     num_cvs;          /* number of curves installed            */
  IGRint     *ndegtab;         /* Degree of the B-spline curve          */
  IGRint     *npoltab;         /* Number of poles of the B-spline curve */
  IGRint     *rattab;          /* 1, rational. 0, non-rational          */
  IGRint     *dimtab;          /* Dimension of the poles                */
  IGRdouble  **poles;          /* poles allocated for all curves        */
                               /* poles[num_cvs][dim*npoltab[i]]        */
                               /* where dim = dimtab[i] + rattab[i]     */
  IGRdouble  **knots;          /* knotsallocated for all curves         */
                               /* knots[num_cvs][num_knots]             */
                               /* where num_knots =                     */
                               /* ndegtab[i] + 1 + npoletab[i]          */

};

struct BScmplgd_cv
{
    IGRint          numgrps;      /* number of group of curves found    */
    IGRint          *ncvs;        /* number of curves for each group    */
                                  /* dimension is ncvs[numgrps]         */
    IGRint          coefmax;      /* Maximum number of coefficients for */
                                  /* cvlgd allocated                    */
                                  /* = (MAXDEG + 1) * 4                 */
    IGRint          **ndegtab;    /* degree of the Legendre curves      */
                                  /* ndegtab[numgrps][ncvs[]]           */
    IGRint          **rattab;     /* rat = 0, non-rational              */
                                  /* rat = 1, rational in u             */
                                  /* rat = 2, rational in v             */
                                  /* rat = 3, ratoional in u and v      */
                                  /* rattab[numgrps][ncvs[]]            */
    IGRint          **genus;      /* genus of the curve                 */
                                  /* rattab[numgrps][ncvs[]]            */
    IGRdouble       ***cvlgd;     /* cvlgd[numgrps][ncvs[]]             */
                                  /* [dim*(ndeg[]+1)]                   */
                                  /* dim = 2 if rat = 0                 */
                                  /* dim = 3 if rat = 1 or 2            */
                                  /* dim = 4 if rat = 3                 */
    BSpair          **uv_start;   /* starting u,v parameters of the     */
                                  /* curve, uv_start[numgrs][ncvs[]]    */
    BSpair          **uv_end;     /* end u,v parameters of the curve    */
                                  /* uv_end[numgrps[ncvs[]]             */
    IGRint          **addrs;      /* array of address which points to   */
                                  /* the memory allocated for ndegtab,  */
                                  /* uv_start,cvlgd. It will be used to */
                                  /* free these memories.               */
};

# endif /* bsplpchlgd_include */
