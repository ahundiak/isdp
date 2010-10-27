/* $Id: VDunwrap.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vds/include/VDunwrap.h
 *
 * Description:	data structures used by unwrap functions.
 *              Cloned from vlstructure.h
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDunwrap.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/10/26  17:55:28  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/19/99  ah	     Creation.
 *************************************************************************/
#ifndef VDunwrap_include
#define	VDunwrap_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


#if defined(__cplusplus)
extern "C" {
#endif

/* ********** Jean-Luc LOSCHUTZ (COC shipbuilding) 20-Oct-1992 ****************/
struct BendingLineInfo {

  IGRdouble       par1;           /* parameter on the first edge */
  IGRdouble       par2;
  IGRdouble       point1[3];
  IGRdouble       point2[3];
  IGRdouble       normal[3];
  IGRboolean      goodToDraw;
  IGRboolean      resolved;

};

typedef struct BendingLineInfo TVDunwBendingLineInfo;

struct my_bndry {
  struct IGRpolyline      *bndry;
  struct my_bndry         *succ;
  struct my_bndry         *son;
  IGRdouble               area;

};

typedef struct my_bndry TVDunwMyBndry;

struct my_bndry_tree {

  TVDunwMyBndry  *root;
  TGRpolyline    *bndries;
  IGRint          num_boundaries;
  
};

typedef struct my_bndry_tree TVDunwMyBndryTree;

struct mise_a_plat {

  TGRbsp_surface    *surface;       /* surface geometry */
  TGRobj_env         surf_id;       /* surface ID graphic Obj*/
  TGRid              res_id;        /* use as the AS resultat ID */
  IGRdouble          epaisseur;     /* ep de tole */
  IGRdouble          fib_ratio;     /* ratio to define where is
                                       the neutral fiber
                                       default = 0.5        */
  IGRdouble         *Param_u;       /* parametres direct. u */
  IGRdouble         *Param_v;       /* parametres direct. v */
  IGRint             Nb_u;          /* nb de param dans le sens u*/
  IGRint             Nb_v;          /* nb de param dans le sens v*/
  IGRint             type;          /* type d elements utilise */
  IGRdouble         *P;             /* points sur la tole */
  IGRdouble         *norm;          /* normale a la surface en P */
  IGRdouble         *M;             /* points a plat */
  IGRdouble         *def;           /* tenseur des deformations elem */
  IGRdouble         *fg;            /* effort applique a
                                                   chaque noeuds */
  IGRshort           developpable;  /* 0 a non developpable srf.
                                       1 a planar surface.
                                       2 developpable surface like cone ... */
  TGRbsp_surface    *devsrf;        /* surface geometry */
  TVDunwMyBndryTree *bdrys_a_plat;  /* Frontieres mises a plat */

  TGRpolyline       *edgeUVGeom;    /* Edges  */
  struct edgeAttrib *edgeAt;        /* Edges attributes */
  IGRint             numEdges;      /* as you see */
  IGRint            *ind;           /* this is an array of indexes
                                                   to store ratio */

  IGRint	     tesselation_option;
  TGRid              uvSrfId;               /* surface in uv space*/
  IGRint	     WantedLinesCode;
                                            /* this field indicates which
                                               lines are to be mapped on the
                                               unwrap */
  IGRint	     AllWaterLines;
  IGRint	     side_of_plate;
};
typedef struct mise_a_plat TVDunwDevSrfInfo;

/* ------------------------------------------------------
 * vdunwrap/VDunwTools.I
 */
extern void    VDunwInitCnst        __((TGRvg_construct  *usr_cnst));
extern IGRstat VDunwInitDevSrfInfo  __((TVDunwDevSrfInfo *dev));
extern IGRstat VDunwFreeDevSrfInfo  __((TVDunwDevSrfInfo *dev));
extern IGRstat VDunwPrintDevSrfInfo __((TVDunwDevSrfInfo *dev, IGRint debugFlag));

extern IGRstat VDunwCreateOrder2Srf __((
  IGRdouble	*poles,	  /*I the given poles */
  IGRint	 Nu,	  /*I the number of poles in u */
  IGRint	 Nv,	  /*I the number of poles in v */
  IGRdouble	*KtsU,    /*I the internal knots in u */
  IGRdouble	*KtsV,	  /*I the internal knots in v */
  IGRshort  	constOpt, /*I constOpt = 0 just the bs 
			      constOpt = 1 the structure + the object
			      constOpt = 2 just just object */

  TGRvg_construct *cst,	    /*I the construction list */
  IGRboolean	   display, /*I display option to send a display or not */
  TGRobj_env	  *ObjSrf,  /*O the resulting surface */
  TGRbsp_surface  **sf,     /*O depending to constOpt the BS structure */
  IGRlong	  *msg      /*O return code MSSUCC or MSFAIL */
  ));

/* ----------------------------------------------------------
 * VDunwFem.I
 */
extern IGRstat VDunwMaplatDevel  __((TVDunwDevSrfInfo *dev));
extern IGRstat VDunwMaplatNDevel __((TVDunwDevSrfInfo *dev));

extern IGRstat VDunwCreateUnfoldSrfStr __((TVDunwDevSrfInfo *dev));

/* ----------------------------------------------------------
 * VDunwTess.I
 */
extern IGRstat VDunwGetPtsNorms __((
  TVDunwDevSrfInfo  *dev,        /*I the structure containing everything */
  IGRint             opt,        /*I opt = 0 ---> iso parametric distribution
			             of the tessalation.
			             opt = 1 ---> tessalation using the four
			             sides of a plate. This new approach is
			             mainely used for shell plates
			          */
  IGRdouble	     MeshTol)); /*I approximate length in the case of opt = 1.
				    if The approximate length is <= 0 then
				    the function will evaluate the appropriated
				    length.
				 */

extern IGRstat VDunwTessOpt0 __((
  TVDunwDevSrfInfo *dev));

extern IGRstat VDunwTessOpt1 __((
  TVDunwDevSrfInfo *dev, 
  IGRdouble         MeshTol));

/* ---------------------------------------------------------------
 * VDunwSrf.I
 */
extern IGRstat VDunwUnwrapPlate __((TGRobj_env *plateOE));

#if 0
 struct unw_obj_plat {

        struct IGRbsp_surface   *surface;       /* surface geometry */
        struct GRobj_env        surf_id;        /* surface ID graphic Obj*/
        struct GRid             res_id;         /* use as the AS resultat ID */
	IGRint			nb_P;
        IGRdouble               *P;             /* points sur la tole */
	IGRint			nb_def;
        IGRdouble               *def;           /* tenseur des deformations
                                                   elem */
        IGRshort                developpable;   /* developpable = 0, we got
                                                     a non developpable srf.
                                                   developpable = 1, we got
                                                     a planar surface.
                                                   developpable = 2, we got
                                                     developpable surface like
                                                     cone ... */
        struct IGRbsp_surface   *devsrf;        /* surface geometry */
        int			tesselation_option;
        struct GRid             uvSrfId;        /* surface in uv space*/
        IGRdouble               *Param_u;       /* parametres direct. u */
        IGRdouble               *Param_v;       /* parametres direct. v */
        IGRint                  Nb_u;           /* nb de param dans le sens u*/
        IGRint                  Nb_v;           /* nb de param dans le sens v*/
        int			side_of_plate;
        };


struct my_rat_surface {

        IGRint                  vnum;
        IGRint                  unum; /* it was *unum */
        IGRdouble               *pts;
        IGRdouble               *weights;
        IGRdouble               *upars;
        IGRdouble               *vpars;
        IGRint                  *uspn;
        IGRint                  *vspn;
        IGRshort                uorder;
        IGRshort                vorder;
        IGRint                  unum_knots;
        IGRint                  vnum_knots;
        IGRdouble               *uknots;
        IGRdouble               *vknots;
        IGRboolean              uperiodic;
        IGRboolean              vperiodic;
        IGRint                  ucode;
        IGRint                  vcode;
        IGRint                  uendl;
        IGRint                  uendr;
        IGRint                  vendl;
        IGRint                  vendr;
        IGRdouble               *utanpoll;
        IGRdouble               *utanpolr;
        IGRdouble               *vtanpoll;
        IGRdouble               *vtanpolr;
        IGRdouble               *ucrvpoll;
        IGRdouble               *ucrvpolr;
        IGRdouble               *vcrvpoll;
        IGRdouble               *vcrvpolr;
        IGRdouble               *uewtl;
        IGRdouble               *uewtr;
        IGRdouble               *vewtl;
        IGRdouble               *vewtr;
        IGRdouble               *unewtl;
        IGRdouble               *unewtr;
        IGRdouble               *vnewtl;
        IGRdouble               *vnewtr;
        IGRshort                dirfit;
        IGRdouble               tolerance;
        IGRdouble               avgerr;
        IGRdouble               maxerr;
        IGRint                  maxind[2];
        IGRpoint                maxpt;
        BSrc                    rc;

        };

struct EdgeMatch {

        struct GRid EdgeId;
        struct GRid EdgeMac;

        };
/* ************************************************************************** */

/* ********** Ludovic LE CORVEC (COC shipbuilding) 01-Feb-1992 ****************/
struct VLctrlSurf{

        IGRdouble       area[3];
        struct  GRid    sf_3d;
};
/* ************************************************************************** */

/* ********** Marc FOURNIER (COC shipbuilding) 01-Feb-1992 ********************/
struct VLpinJig
{

        IGRint          idx;
        IGRint          col;
        IGRint          lin;
        IGRdouble       xpt;
        IGRdouble       ypt;
        IGRdouble       zpt;
        IGRdouble       hei;
        IGRdouble       ang;
	IGRboolean	flg;
	IGRchar		nam[80];

};

struct VLsortTpl
{

        IGRint          idx;
        IGRchar         name[80];
        IGRdouble       x;
        IGRdouble       y;
        IGRdouble       z;
        IGRint          num;

};

struct VLpinCorn
{

	IGRchar		cp[80];
	IGRdouble	dx;
	IGRdouble	dy;
	IGRchar		pn[80];

};

struct VLStrechVal
{
        int     v;	
        int	u;
        double  val[4]; 
        int     num_val;
};

/* Structure for queriable lines */
struct VL_s_queryLine
{
	IGRchar		dname[DI_PATH_MAX];
	GRclassid	claid;
        IGRboolean      plane;
        IGRboolean      query;
};
typedef	struct	VL_s_queryLine	VLquLine;

/* How to build the loftbook */
struct	VL_s_LoftHeader
{
	IGRint		chap;			/*	chapter index	*/
	IGRchar		staS[DI_PATH_MAX];	/*	start keyword	*/
	IGRchar		rptS[DI_PATH_MAX];	/*	report keyword	*/
	IGRchar		endS[DI_PATH_MAX];	/*	end keyword	*/
	IGRint		idxA;			/*	elem A index	*/
	IGRboolean	plnA;			/*	elem A planar ?	*/
	IGRboolean	looA;			/*	elem A loop ?	*/
	IGRint		idxB;			/*	elem B index	*/
	IGRboolean	plnB;			/*	elem B planar ?	*/
	IGRboolean	looB;			/*	elem B loop ?	*/
};
typedef struct  VL_s_LoftHeader   VLlbHead;

/* Data structure for loftbook elements */
struct  VL_s_LoftElement
{
        IGRchar         namA[80]; /*	element A name in reference	*/
        IGRchar         macA[80]; /*	element A pointer name in local	*/
        IGRdouble       pntA[3];  /*	element A geometric point	*/
        IGRdouble       nrmA[3];  /*	element A normal (if planar)	*/
        IGRchar		namB[80]; /*    element B name in reference     */
        IGRchar         macB[80]; /*    element B pointer name in local */
        IGRdouble       pntB[3];  /*    element B geometric point       */
        IGRdouble       nrmB[3];  /*    element B normal (if planar)    */
	IGRint		nint;	  /*	number of intersections (max 4)	*/
        IGRpoint	Pint[4];  /*	intersection points array	*/
	IGRint		next;	  /*	number of extremities (max 2)	*/
	IGRpoint	Pext[2];  /*	extremity points array		*/
};
typedef struct  VL_s_LoftElement   VLlbElem;

/* Data structure for loftbook reporting */
struct  VL_s_LoftData
{
	IGRint		numA;	/*	Number of elements A		*/
	IGRint		curA;	/*	Current element A index		*/
	IGRint		numB;	/*	Number of elements B		*/
	IGRint		curB;	/*	Current element B index		*/
	VLlbHead	head;	/*	Chapter header			*/
	VLlbElem	*elem;	/*	Elements A, B and intersections	*/
	IGRpoint	orig;	/*	Origin point [AP,BL,CL]		*/
};
typedef struct  VL_s_LoftData   VLlbData;

/* Data structure for multiple crossings */
struct  VL_s_LoftCrossing
{
	IGRint		idx;
	IGRdouble	val;
};
typedef struct  VL_s_LoftCrossing   VLlbCross;

/* Data structure for stiffener-templates */
struct  VL_s_StfnrTemplate
{
        IGRpoint        pnt;
        IGRdouble       len;
        IGRint          idx;
        IGRint          typ;
        IGRchar         nam[80];
        IGRchar         tag[80];
};
typedef struct  VL_s_StfnrTemplate      VLstfTpl;

/* Argument structure between plate-template manager and object */
struct	VL_s_PlateTemplateArgs
{
	IGRdouble	dst;
	IGRdouble	xt1;
	IGRdouble	xt2;
	IGRint		inv;
	IGRint		prj;
	IGRdouble	sca;
	IGRdouble	mid;
	IGRint		axe;
	IGRdouble	xpl;
	IGRdouble	ypl;
	IGRint		sta;
	IGRint		ful;
	IGRdouble	len;
	IGRdouble	rad;
	IGRdouble	wid;
	IGRdouble	upr;
	IGRdouble	vpr;
	IGRdouble	siz;
	IGRpoint	cnt;
	IGRvector	nrm;
}; 
typedef	struct	VL_s_PlateTemplateArgs	VLpltTplArg;

/* Data structure for plate-templates */
struct	VL_s_PlateTemplate
{
	IGRint		idx;
	IGRchar		nam[80];
	IGRdouble	hei;
	IGRdouble	cht;
	IGRdouble	ang;
        IGRchar         frm[80];
};
typedef	struct	VL_s_PlateTemplate	VLpltTpl;

/* Data structure for topological algorithm (external contour & control line) */
struct	VL_s_TopologicalAlgorithmNode
{
	IGRint		Idx;
	IGRpoint	Pnt;
	IGRint		Cnt;
};
typedef	struct	VL_s_TopologicalAlgorithmNode	VLalgoNode;
struct	VL_s_TopologicalAlgorithmEdge
{
	IGRint		Idx;
	struct	GRid	Obj;
	IGRint		Sta;
	IGRint		End;
	IGRboolean	Ext;
};
typedef	struct	VL_s_TopologicalAlgorithmEdge	VLalgoEdge;

/* ************************************************************************** */

#define N_ATT_TYPE "type_of_line"
#endif

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif
#endif
