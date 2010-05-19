/* $Id: VDbspXml.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDbspXml.h
 *
 * Description:	BSP XML Interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbspXml.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  2000/03/24  15:23:36  pinnacle
 * bsp
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/19/00  ah      Creation
 ***************************************************************************/
#ifndef VDbspXml_include
#define VDbspXml_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDxml_include
#include "VDxml.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------------------
 * Expose the xml routines to external parsers
 */
extern IGRstat VDxmlWriteBspCurve __((TVDxmlFileInfo *xml, TGRbsp_curve *crv));

typedef struct {

  TGRbsp_curve  crvd;
  TGRbsp_curve *crvp;
  IGRint        flag;
  
} TVDxmlBspParseInfo;

extern IGRstat VDxmlFilterBspAttribute  __((TVDxmlBspParseInfo *info,
					    TVDxmlParseInfo *parseInfo));

extern IGRstat VDxmlFilterBspBegElement __((TVDxmlBspParseInfo *info,
					    TVDxmlParseInfo *parseInfo));

extern IGRstat VDxmlFilterBspEndElement __((TVDxmlBspParseInfo *info,
					    TVDxmlParseInfo *parseInfo));

extern IGRstat VDxmlFilterBspEndElementAttrs __((TVDxmlBspParseInfo *info,
						 TVDxmlParseInfo *parseInfo));

// When EndElement returns this, then a curve is loaded
#define XML_BSP_CRV_LOADED 3

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif


/* BSP curve */
#define XML_BSP_CRV              "bsp:crv"
#define XML_BSP_CRV_ORDER        "order"
#define XML_BSP_CRV_PROPS        "props"

#define XML_BSP_CRV_PROP_PERIODIC    0
#define XML_BSP_CRV_PROP_NON_UNIFORM 1
#define XML_BSP_CRV_PROP_RATIONAL    2
#define XML_BSP_CRV_PROP_PLANAR      3
#define XML_BSP_CRV_PROP_PHY_CLOSED  4
#define XML_BSP_CRV_PROP_END         5

#define XML_BSP_CRV_PERIODIC     "periodic"
#define XML_BSP_CRV_NON_UNIFORM  "non_uniform"

#define XML_BSP_CRV_RATIONAL     "rational"
#define XML_BSP_CRV_PLANAR       "planar"
#define XML_BSP_CRV_PHY_CLOSED   "phy_closed"

#define XML_BSP_CRV_NUM_POLES    "num_poles"
#define XML_BSP_CRV_NUM_KNOTS    "num_knots"
#define XML_BSP_CRV_NUM_BNDYS    "num_bndys"

// Store knots,poles,weights and boundaries in one structure???
#define XML_BSP_CRV_KPWBS       "bsp:crv_kpwbs"
#define XML_BSP_CRV_KPWB        "bsp:crv_kpwb"
#define XML_BSP_CRV_KPWB_K      "k"
#define XML_BSP_CRV_KPWB_X      "x"
#define XML_BSP_CRV_KPWB_Y      "y"
#define XML_BSP_CRV_KPWB_Z      "z"
#define XML_BSP_CRV_KPWB_W      "w"
#define XML_BSP_CRV_KPWB_B1     "b1"
#define XML_BSP_CRV_KPWB_B2     "b2"

// No longer used for curves, maybe for surfaces?
#define XML_BSP_POLES       "bsp:poles"
#define XML_BSP_POLE        "bsp:pole"
#define XML_BSP_POLE_X      "x"
#define XML_BSP_POLE_Y      "y"
#define XML_BSP_POLE_Z      "z"
#define XML_BSP_POLE_W      "w"

#define XML_BSP_KNOTS       "bsp:knots"
#define XML_BSP_KNOT        "bsp:knot"
#define XML_BSP_KNOT_P      "p"

#if 0
struct IGRbsp_curve			/* B-spline curve geometry	*/
{
	IGRshort   order;		/* order of the curve		*/
	IGRboolean periodic;		/* periodic (TRUE) / non-	*/
					/* periodic (FALSE) indicator	*/
	IGRboolean non_uniform;		/* non-uniform (TRUE) / uniform	*/
					/* (FALSE) knot vector 		*/
	IGRlong    num_poles;		/* number of poles		*/
	IGRdouble  *poles;		/* pointer to array of poles	*/
	IGRlong	   num_knots;		/* number of knots		*/
	IGRdouble  *knots;		/* pointer to array of knots	*/
	IGRboolean rational;		/* rational (TRUE) / 		*/
					/* nonrational (FALSE)		*/
	IGRdouble  *weights;		/* pointer to array of weights	*/
					/* (if rational)		*/
	IGRboolean planar;		/* planarity indicator		*/
	IGRboolean phy_closed;		/* physically closed indicator	*/
	IGRshort   num_boundaries;	/* number of boundaries imposed */
					/* on the curve			*/
	IGRdouble  *bdrys;		/* pointer to array of boundary	*/
					/* parameter values (total 	*/
					/* number of values is twice	*/
					/* the number of boundaries)	*/
};
#endif

/* BSP surface */
#define XML_BSP_SRF                "bsp:surface"

#define XML_BSP_SRF_ORDER_U        "u_order"
#define XML_BSP_SRF_ORDER_V        "v_order"

#define XML_BSP_SRF_PERIODIC_U     "u_periodic"
#define XML_BSP_SRF_PERIODIC_V     "v_periodic"

#define XML_BSP_SRF_NON_UNIFORM_U  "u_non_uniform"
#define XML_BSP_SRF_NON_UNIFORM_V  "v_non_uniform"

#define XML_BSP_SRF_NUM_POLES_U    "u_num_poles"
#define XML_BSP_SRF_NUM_POLES_V    "v_num_poles"

#define XML_BSP_SRF_POLES          "poles"

#define XML_BSP_SRF_NUM_KNOTS_U    "u_num_knots"
#define XML_BSP_SRF_NUM_KNOTS_V    "v_num_knots"

#define XML_BSP_SRF_KNOTS_U        "u_knots"
#define XML_BSP_SRF_KNOTS_V        "v_knots"

// Or have a bsp:knots with a uv type
#define XML_BSP_KNOT             "bsp:knot"
#define XML_BSP_KNOT_U           "bsp:u_knot"
#define XML_BSP_KNOT_V           "bsp:v_knot"
#define XML_BSP_KNOT_P           "p"
#define XML_BSP_KNOT_UV_TYPE     "uv_type"
#define XML_BSP_KNOT_UV_TYPE_U   "u"  // Default
#define XML_BSP_KNOT_UV_TYPE_V   "v"

// Same as curve exceot weights will be matrix
#define XML_BSP_SRF_RATIONAL       "rational"
#define XML_BSP_SRF_WEIGHTS        "weights"
#define XML_BSP_SRF_PLANAR         "planar"


#define XML_BSP_SRF_PHY_CLOSED_U   "u_phy_closed"
#define XML_BSP_SRF_PHY_CLOSED_V   "v_phy_closed"

#define XML_BSP_SRF_POS_ORIEN      "pos_orien"
#define XML_BSP_SRF_ON_OFF         "on_off"

#define XML_BSP_SRF_NUM_BOUNDARIES "num_boundaries"

#define XML_BSP_SRF_BOUNDARIES     "boundaries"

#define XML_BSP_SRF_BOUNDARY            "bsp:srf_boundary"
#define XML_BSP_SRF_BOUNDARY_NUM_POINTS "num_points"

#define XML_BSP_SRF_BOUNDARY_POINT      "bsp:srf_boundary_point"
// Not sure about this format
#define XML_BSP_CRV_BOUNDARY_POINT_X    "x"

#if 0
struct IGRbsp_bdry_pts			/* boundary points structure	*/
{
	IGRlong	  num_points;		/* number of points in the 	*/
					/* boundary			*/
	IGRdouble *points;		/* pointer to array of 		*/
					/* contiguous (u,v) points	*/
};
struct IGRbsp_surface			/* B-spline surface geometry	*/
{
	IGRshort   u_order;		/* order in the u direction	*/
	IGRshort   v_order;		/* order in the v direction	*/
	IGRboolean u_periodic;		/* periodic (TRUE) / non-	*/
					/* periodic (FALSE) in the u	*/
					/* direction indicator		*/
	IGRboolean v_periodic;		/* periodic (TRUE) / non-	*/
					/* periodic (FALSE) in the v	*/
					/* direction indicator		*/
	IGRboolean u_non_uniform;	/* non-uniform (TRUE) / uniform	*/
					/* (FALSE) u direction knot	*/
					/* vector			*/
	IGRboolean v_non_uniform;	/* non-uniform (TRUE) / uniform	*/
					/* (FALSE) v direction knot	*/
					/* vector			*/
	IGRlong    u_num_poles;		/* # poles in u direction	*/
					/* (# rows in pole matrix)	*/
	IGRlong    v_num_poles;		/* # poles in v direction	*/
					/* (# columns in pole matrix)	*/
	IGRdouble  *poles;		/* pointer to matrix of poles	*/
					/* (column major form)		*/
	IGRlong	   u_num_knots;		/* number of knots in u 	*/
	IGRdouble  *u_knots;		/* pointer to u direction knots	*/
	IGRlong	   v_num_knots;		/* number of knots in v 	*/
	IGRdouble  *v_knots;		/* pointer to v direction knots	*/
	IGRboolean rational;		/* rational (TRUE) / non-	*/
					/* rational (FALSE) indicator	*/
	IGRdouble  *weights;		/* pointer to matrix of weights	*/
					/* (if rational)		*/
	IGRboolean planar;		/* planarity indicator		*/
	IGRboolean u_phy_closed;	/* physically closed indicator	*/
	IGRboolean v_phy_closed;	/* physically closed indicator	*/
	IGRboolean pos_orient;		/* orientation indicator	*/
	IGRboolean on_off;		/* indicator of whether the 	*/
					/* point (u,v) = (0,0) is on 	*/
					/* (TRUE) or off (FALSE) the	*/
					/* surface (only valid if number*/
					/* of boundaries is non-zero)	*/
	IGRshort   num_boundaries;	/* number of boundaries imposed */
					/* on the surface		*/
	struct IGRbsp_bdry_pts		/* pointer to array of boundary */
	  	   *bdrys;		/* point structures		*/
};
#endif

/* ----------------------------------------------- 
 * Difference between curve and surface is that curve is u only,
 * surface has both u and v, define three different attributes
 * u_order,v_order, order or 
 * u_order,v_order  or make a u and v info object
 *
 * <bsp:info type="u" order=,num_poles=,num_knots etc.
 *
 * Doing this allows the possibility of going beyond just u and v
 */
#define XML_BSP_UV_INFO               "bsp:info"
#define XML_BSP_UV_INFO_TYPE          "uv_type"
#define XML_BSP_UV_INFO_TYPE_U        "u"
#define XML_BSP_UV_INFO_TYPE_V        "v"

#define XML_BSP_UV_INFO_ORDER         "order"
#define XML_BSP_UV_INFO_PERIODIC      "periodic"
#define XML_BSP_UV_INFO_NON_UNIFORM   "non_uniform"
#define XML_BSP_UV_INFO_PHY_CLOSED    "phy_closed"

#define XML_BSP_UV_INFO_NUM_POLES     "num_poles"
#define XML_BSP_UV_INFO_NUM_KNOTS     "num_knots"

/* -----------------------------------------------
 * This object signals that all non-array data
 * has been loaded, data structures could be initied
 * based on receiving this object
 */
#define XML_BSP_INIT "bsp:init"

/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif








