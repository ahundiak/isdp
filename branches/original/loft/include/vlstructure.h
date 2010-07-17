/* $Id: vlstructure.h,v 1.2 2001/01/16 18:15:48 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	VLinteg/include / vlstructure.h
 *
 * Description:	data structures used by Loft functions.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vlstructure.h,v $
 *	Revision 1.2  2001/01/16 18:15:48  ramarao
 *	*** empty log message ***
 *	
 * Revision 1.7  2000/11/26  18:51:28  pinnacle
 * Replaced: loft/include/vlstructure.h for:  by rchennup for Service Pack
 *
 * Revision 1.3  2000/06/19  13:37:04  pinnacle
 * Replaced: loft/include/vlstructure.h for:  by rchennup for Service Pack
 *
 * Revision 1.2  2000/02/18  13:11:14  pinnacle
 * mf
 *
 * Revision 1.1  1998/04/30  10:32:50  pinnacle
 * LOFT 2.5.1
 *
 * Revision 1.2  1997/10/28  20:18:48  pinnacle
 * Replaced: include/vlstructure.h for:  by rchennup for loft
 *
 * Revision 1.1  1997/05/08  14:05:56  pinnacle
 * Loft 250
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	04/07/97   mf		header creation.
 *	05/30/00   mf		data structure for SteelBand & KeyLines.
 *************************************************************************/
#ifndef vlstructure_include
#define	vlstructure_include

/* ************************************************************************** */
/* 	This include file groups all the structures of the I/LOFT product.    */
/*	With the prototyping of the functions, it's useful to do it	      */
/*									      */
/*		Marc FOURNIER (COC shipbuilding)	19-Nov-1993	      */
/* ************************************************************************** */

#include        "igetypedef.h"
#include        "igrtypedef.h"
#include        "OMminimum.h"
#include        "igrdef.h"
#include        "igr.h"
#include        "exdef.h"
#include        "ex.h"
#include        "igrdp.h"
#include        "gr.h"
#include        "growner.h"
#include        "go.h"
#include        "griodef.h"
#include        "grio.h"
#include        "bstypes.h"

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

struct my_bndry {

        struct IGRpolyline      *bndry;
        struct my_bndry         *succ;
        struct my_bndry         *son;
        IGRdouble               area;

        };

struct my_bndry_tree {

        struct my_bndry         *root;
        struct IGRpolyline      *bndries;
        IGRint                  num_boundaries;

        };

 struct mise_a_plat {

        struct IGRbsp_surface   *surface;       /* surface geometry */
        struct GRobj_env        surf_id;        /* surface ID graphic Obj*/
        struct GRid             res_id;         /* use as the AS resultat ID */
        IGRdouble               epaisseur;      /* ep de tole */
        IGRdouble               fib_ratio;      /* ratio to define where is
                                                   the neutral fiber
                                                   default = 0.5        */
        IGRdouble               *Param_u;       /* parametres direct. u */
        IGRdouble               *Param_v;       /* parametres direct. v */
        IGRint                  Nb_u;           /* nb de param dans le sens u*/
        IGRint                  Nb_v;           /* nb de param dans le sens v*/
        IGRint                  type;           /* type d elements utilise */
        IGRdouble               *P;             /* points sur la tole */
        IGRdouble               *norm;          /* normale a la surface en P */
        IGRdouble               *M;             /* points a plat */
        IGRdouble               *def;           /* tenseur des deformations
                                                   elem */
        IGRdouble               *fg;            /* effort applique a
                                                   chaque noeuds */
        IGRshort                developpable;   /* developpable = 0, we got
                                                     a non developpable srf.
                                                   developpable = 1, we got
                                                     a planar surface.
                                                   developpable = 2, we got
                                                     developpable surface like
                                                     cone ... */
        struct IGRbsp_surface   *devsrf;        /* surface geometry */
        struct my_bndry_tree    *bdrys_a_plat;  /* Frontieres mises a plat */

        struct IGRpolyline      *edgeUVGeom;    /* Edges  */
        struct edgeAttrib       *edgeAt;        /* Edges attributes */
        IGRint                  numEdges;       /* as you see */
        IGRint                  *ind;           /* this is an array of indexes
                                                   to store ratio */

        int			tesselation_option;
        struct GRid             uvSrfId;        /* surface in uv space*/
        int			WantedLinesCode;
                                               /* this field indicates which
                                                  lines are to be mapped on the
                                                  unwrap */
        int			AllWaterLines;
        int			side_of_plate;
        };

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

struct VL_s_pinjigCorner
{

	IGRchar		cp[80];
	IGRdouble	dx;
	IGRdouble	dy;
	IGRdouble	dz;
	IGRchar		pn[80];

};
typedef	struct	VL_s_pinjigCorner	VLpinCorn;

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
	IGRchar		lea[3];
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

/* Info structure for steel band */
struct	VL_s_SteelBandInfo
{
	IGRchar		band[80];
	IGRchar		unit[80];
	IGRchar		desc[80];
	IGRchar		jobN[80];
	IGRdouble	stock;
	IGRdouble	endstock;
	IGRint		numP;
};
typedef	struct	VL_s_SteelBandInfo	VLsteelBandInfo;

/* Data structure for steel band */
struct	VL_s_SteelBandData
{
	IGRint		idx;
	IGRchar		nam[80];
	IGRdouble	dst;
};
typedef	struct	VL_s_SteelBandData	VLsteelBandData;

/* Info structure for key line */
struct	VL_s_KeyLineInfo
{
	IGRchar		unit[80];
	IGRchar		jobN[80];
	IGRint		numT;		/* Transverse process */
	IGRint		numL;		/* Longitudinal process */
	IGRint		numD;		/* Diagonal process */
};
typedef	struct	VL_s_KeyLineInfo	VLkeyLineInfo;

/* Data structure for key line : transverse & longitudinal process */
struct	VL_s_KeyLineData
{
	IGRchar		pro[80];
	IGRchar		lin[80];	/* not used by diagonal process */
	IGRchar		nam[80];
	IGRdouble	dst;
};
typedef	struct	VL_s_KeyLineData	VLkeyLineData;

/* Sort structure for pin jigs panel corners */
struct VL_s_PinJigPanel
{
	IGRint		idx;
	IGRpoint	spt;
	IGRpoint	ept;
	IGRboolean	bad;
};
typedef	struct	VL_s_PinJigPanel	VLpinJigPanel;

/* Data structure for balancement base points */
struct VL_s_BalanceBasePoint
{
	IGRpoint	balance;
	IGRpoint	in_ship;
};
typedef	struct	VL_s_BalanceBasePoint	VLbalBasePt;
struct VL_s_BalanceBasePoints
{
	VLbalBasePt	corner[4];
};
typedef	struct	VL_s_BalanceBasePoints	VLbalBasePts;

/* ************************************************************************** */

#define N_ATT_TYPE "type_of_line"
#endif
