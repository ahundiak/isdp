
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:02 $
$Locker:  $
*/


class implementation Root;

#define CHECK_RETURN_CODES 1

#define CURVE_OBJECT      0
#define POINT_OBJECT      1

#include <stdio.h>
#include <string.h>
#include <math.h>

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "msdef.h"

#include "igr.h"
#include "gr.h"
#include "igrdp.h"

#include "grdpbdef.h"
#include "godef.h"
#include "go.h"

#include "dpstruct.h"

#include "bs.h"
#include "bsparameters.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

#include "DEso.h"

#include "EMSprop.h"
#include "EMSlcdef.h"

#include "VEsodef.h"

/* prototype files */
#include "VEpr_hiding.h" 
#include "VEpr_utilimp.h"
#include "VEpr_utilfnc.h"
#include "VEpr_marking.h"

#include "bsactivsplt.h"
#include "bscveval.h"
#include "bschgdeppar.h"
#include "bschangepar.h"
#include "bsmdstptcv.h"
#include "bsunwght_p.h"
#include "bststcvfln.h"
#include "bsxtractpar.h"
#include "bscvkttol2.h"

/* Extern Global Variables */
extern struct VEexecution_status VEexec_status;
extern struct VEexecution_parms  VEexec_parms;
extern struct VEtolerance_info   VEtolerances;
extern struct GRmd_env           VEmaster_env;
extern struct VEresults_info     VEoutput_data;
extern struct VEwindow_info      VEwin_info;
extern IGRboolean                VEcolor_classification;

/* class id's used for object construction */
extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_GR3dpoint_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dlineseg_class_id;

%safe
static IGRboolean VEcreating_hidden_edges = FALSE;

/* static space to hold an order 2, 2 pole curve */
static IGRdouble VEline_poles[6];
static IGRdouble VEline_knots[4] = { 0.0, 0.0, 1.0, 1.0 };

static struct IGRbsp_curve VEline = { 2,               /* order                 */
	                              FALSE, FALSE,    /* periodic, non-uniform */
	                              2, VEline_poles, /* num_poles, poles      */
	                              4, VEline_knots, /* num_knots, knots      */
	                              FALSE, NULL,     /* rational, weights     */
	                              FALSE, FALSE,    /* planar, phy_closed    */
	                              0, NULL };       /* num_boundaries, bdrys */

static IGRboolean      VEcommon_edge_chan_defined = FALSE;
static OM_S_CHANSELECT VEcommon_edge_chan;
%endsafe


from GRvg import GRconstruct;
from GRvg import GRgetsymb;
from GRvg import GRgetprops;
from DEso import DEget;
from EMSboundary import EMgetxyzobj;
from EMSedge     import EMget_props;


/*--- VEget_element_base_attr --------------------------------------------*/

#if defined(__STDC__)
void VEget_element_base_attr( OM_S_OBJID        objid,
			      OMuword           osnum,
			      struct GRhesym    *ref_symb,
			      struct IGRdisplay *base_attr )
#else
void VEget_element_base_attr( objid, osnum, ref_symb, base_attr )

	OM_S_OBJID        objid;
	OMuword           osnum;
	struct GRhesym    *ref_symb;
	struct IGRdisplay *base_attr;
#endif

/*
NAME
	VEget_element_base_attr

DESCRIPTION
	This function gets the base display attribues of an element (i.e., the
	symbology that will be used for its edges if the USE_ORIGINAL
	mode is set.  The base symbology is the symbology of the element
	with possible reference file symbology overrides.

PARAMETERS
	objid (IN) - the object id of the element
	osnum (IN) - the object space number of the element
	ref_symb (IN) - the refernce file symbology override for the element
	base_attr (OUT) - the base display attributes of the element

GLOBALS USED
	none

HISTORY
	07/13/90    S.P. Rogers
	   Creation Date (extracted from VEestablish_curves)
*/

	{
	IGRlong            sts;
	IGRlong            msg;
	struct GRsymbology element_symb;

	/* Get the symbology of the element */
	sts = om$send( msg      = message GRvg.GRgetsymb( &msg, &element_symb ),
	               senderid = NULL_OBJID,
	               targetid = objid,
	               targetos = osnum );

	   OM_ERRCHK( sts, "VEget_element_base_attr:  GRgetsymb send failed" );
	   MSG_ERRCHK( msg, "VEget_element_base_attr:  GRgetsymb failed" );

	*base_attr = element_symb.display_attr;

	/* Override element symbology with that of the enviroment (ref. file) */
	/* it is in if an overriding symbology is in effect for the environment */
	if ( ! (ref_symb->flags & DPB_USE_ORIG_COLOR) )
	   base_attr->color = ref_symb->color;

	if ( ! (ref_symb->flags & DPB_USE_ORIG_STYLE) )
	   base_attr->style = ref_symb->style;

	if ( ! (ref_symb->flags & DPB_USE_ORIG_WEIGHT) )
	   base_attr->weight = ref_symb->weight;

	}  /* VEget_element_base_attr */


/*--- VEget_visible_display_attr ---------------------------------------------*/

static void VEget_visible_display_attr( vis_attr, orig_attr )

	struct IGRdisplay *vis_attr;
	struct IGRdisplay *orig_attr;

/*
NAME
	VEget_visible_display_attr (static)

DESCRIPTION
	Get the visible display attributes by reconciling the original
	attributes with the attributes defined in the DPB.

PARAMETERS
	vis_attr (OUT) - the visible display attributes
	orig_attr (IN) - the original display attributes

GLOBALS USED
	VEoutput_data.visible_symb - DPB visible display attributes

HISTORY
	11/13/91    S.P. Rogers
	   Creation Date
*/

	{
	/* Hidden attributes */
	vis_attr->color  = VEoutput_data.visible_symb.color;
	vis_attr->style  = VEoutput_data.visible_symb.style;
	vis_attr->weight = VEoutput_data.visible_symb.weight;

	if ( VEoutput_data.visible_symb.flags & DPB_USE_ORIG_COLOR )
	   vis_attr->color = orig_attr->color;

	if ( VEoutput_data.visible_symb.flags & DPB_USE_ORIG_STYLE )
	   vis_attr->style = orig_attr->style;

	if ( VEoutput_data.visible_symb.flags & DPB_USE_ORIG_WEIGHT )
	   vis_attr->weight = orig_attr->weight;

	}  /* VEget_visible_display_attr */


/*--- VEget_hidden_display_attr ---------------------------------------------*/

static void VEget_hidden_display_attr( hid_attr, orig_attr )

	struct IGRdisplay *hid_attr;
	struct IGRdisplay *orig_attr;

/*
NAME
	VEget_hidden_display_attr (static)

DESCRIPTION
	Get the hidden display attributes by reconciling the original
	attributes with the attributes defined in the DPB.

PARAMETERS
	hid_attr (OUT) - the hidden display attributes
	orig_attr (IN) - the original display attributes

GLOBALS USED
	VEoutput_data.hidden_symb - DPB hidden display attributes

HISTORY
	10/09/87    S.P. Rogers
	   Creation Date
*/

	{
	/* Hidden attributes */
	hid_attr->color  = VEoutput_data.hidden_symb.color;
	hid_attr->style  = VEoutput_data.hidden_symb.style;
	hid_attr->weight = VEoutput_data.hidden_symb.weight;

	if ( VEoutput_data.hidden_symb.flags & DPB_USE_ORIG_COLOR )
	   hid_attr->color = orig_attr->color;

	if ( VEoutput_data.hidden_symb.flags & DPB_USE_ORIG_STYLE )
	   hid_attr->style = orig_attr->style;

	if ( VEoutput_data.hidden_symb.flags & DPB_USE_ORIG_WEIGHT )
	   hid_attr->weight = orig_attr->weight;

	}  /* VEget_hidden_display_attr */


/*---- VEoutput_span --------------------------------------------------------*/

static void VEoutput_span( type, visib, orig_attr, hid_attr, curve, temp_curve, cons_args,
	                   span_start, span_end, manual_soo_span, manual_soo_type )

	IGRshort              type;
	IGRshort              visib;
	struct IGRdisplay     *orig_attr;
	struct IGRdisplay     *hid_attr;
	struct IGRbsp_curve   *curve;
	struct IGRbsp_curve   *temp_curve;
        struct GRvg_construct *cons_args;
	IGRdouble             span_start;
	IGRdouble             span_end;
	IGRboolean            manual_soo_span;
	IGRshort              manual_soo_type;

/*
NAME
	VEoutput_span

DESCRIPTION
	This function creates the required graphic objects to represent a
	visible/hidden span of an edge.

	The objects that can be created are:

		GR3dpoint   - point object
	        GR3dlinestr - line string object
		GRbcsubbc   - general curve object

PARAMETERS
	type (IN) - the type of the object (CURVE_OBJECT or POINT_OBJECT)
	visib (IN) - the visibility of the span
	orig_attr (IN) - the original display attributes of the span
	hid_attr (IN) - the hidden display attributes of the span
	curve (IN) - the curve geometry for the span
	temp_curve (IN) - temporary curve used for splitting (must be at least
	                  as large as curve)
	cons_args (IN) - the construct arguments for the object to be created
	span_start (IN) - the U value of the span start
	span_end (IN) - the U value of the span edn
	manual_soo_span (IN) - flag indicating whether span is covered by
	                       a manual SO
	manual_soo_type (IN) - the type of the manual SO if span is covered
	                       by one

GLOBALS USED
	VEexec_parms.VEhiding - to determine if running CVE or CPE
	VEoutput_data.visible_level,
	VEoutput_data.hidden_level - to determine output layers
	VEoutput_data.output_2d - to determine if creating 2D or 3D output
	VEmaster_env - module environment for master file
	VEtolerances.system_cht,
	VEtolerances.system_base_tol - system tolerances in design space

HISTORY
	10/09/87    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             sts;
	IGRlong             rc1;
	IGRlong             rc2;
	IGRboolean          tst_planar = FALSE;
	IGRboolean          old_rational;
	IGRshort            is_line;
	IGRdouble           current_base_tol;
	IGRdouble           current_cht;
	struct IGRbsp_curve *tcurve;
	OMuword             object_class_id;
	OM_S_OBJID          new_object;


	if ( manual_soo_span )
	   {
	   /* this is a span that is covered by a manual SO => use the SO's */
	   /* symbology and determine level based on the SO's type          */
	   cons_args->display = orig_attr;
	   if ( manual_soo_type & DE_INVIS )
	      return;
	   else if ( manual_soo_type & DE_HIDDEN )
	      {
	      if ( ! VEexec_parms.VEhiding )
	         cons_args->level = VEoutput_data.visible_level;  /* running projected edges */
	      else if ( VEcreating_hidden_edges )
	         cons_args->level = VEoutput_data.hidden_level;
	      else
	         return;
	      }
	   else  /* visible or specified span */
	      cons_args->level = VEoutput_data.visible_level;
	   }
	else if ( visib == VISIBLE )
	   {
	   /* visible attributes are always 'original' */
	   cons_args->display = orig_attr;
	   cons_args->level = VEoutput_data.visible_level;
	   }
	else if ( (visib == HIDDEN) && (VEcreating_hidden_edges) )
	   {
	   cons_args->display = hid_attr;
	   cons_args->level = VEoutput_data.hidden_level;
	   }
	else
	   {
	   return;
	   }

	switch ( type )
	   {
	   case POINT_OBJECT :

	      /* transform the point back to world coordinates */
	      VEtrans_to_world( (IGRchar *)curve, CURVE );

	      cons_args->geometry = (IGRchar *) curve;
	      break;

	   case CURVE_OBJECT :

	      /* split out span into temporary curve */
	      BSactivsplt( &rc1, curve, &span_start, &span_end,
	                   temp_curve, &tst_planar );

	         BS_ERRCHK( rc1, "VEoutput_span: BSactivsplt failed" );

	      if ( rc1 != BSSUCC ) return;

	      /* transform split piece to world coordinates */
	      VEtrans_to_world( (IGRchar *)temp_curve, CURVE );

	      if ( VEoutput_data.output_2d )
	         {
	         /* save the current CHT and base_tol */
	         BSxtractpar( &rc2, BSTOLCHRDHT, &current_cht );
	         BSxtractpar( &rc2, BSTOLBASIS, &current_base_tol );
	
	         /* reset the CHT and base_tol to the values used for dealing */
	         /* with model space elements => this will ensure that        */
	         /* BStstcvfln will work properly because we are giving it a  */
	         /* curve in model space.                                     */
	         BSchangepar( &rc2, BSTOLCHRDHT, VEtolerances.VEsystem_cht );
	         BSchgdeppar( VEtolerances.VEsystem_base_tol, &rc2 );

	         /* see if the curve can be represented as a 2 point linestring */
	         BStstcvfln( temp_curve,
	                     &is_line, &(VEline.poles[0]), &(VEline.poles[3]), &rc1 );

	            BS_ERRCHK( rc1, "VEoutput_span: BStstcvfln failed" );

	         /* restore the CHT and base_tol */
	         BSchangepar( &rc2, BSTOLCHRDHT, current_cht );
	         BSchgdeppar( current_base_tol, &rc2 );

	         if ( rc1 == BSSUCC )
	            {
	            if ( is_line == 2 )
	               {
	               /* curve degenerated to a point => don't output anything */
	               return;
	               }
	            else if ( is_line )
	               {
	               /* curve degenerated to a line => output it as a 2 point linestring */
	               cons_args->geometry = (IGRchar *) &VEline;
	               }
	            else
	               {
	               /* curve isn't a line => output it as is */
	               temp_curve->planar = TRUE;
	               cons_args->geometry = (IGRchar *) temp_curve;
	               }
	            }  /* end: if ( rc == BSSUCC ) */
	         else
	            {
	            /* math routine failed => output curve as is */
	            temp_curve->planar = TRUE;
	            cons_args->geometry = (IGRchar *) temp_curve;
	            }
	         }
	      else
	         {
	         /* 3d output */
	         cons_args->geometry = (IGRchar *) temp_curve;
	         }

	      break;

	   }  /* end: switch */

	/* determine the type of object to construct */
	tcurve = (struct IGRbsp_curve *) cons_args->geometry;
	old_rational = tcurve->rational;

	if ( type == POINT_OBJECT )
	   object_class_id = OPP_GR3dpoint_class_id;
	else if ( tcurve->order == 2 )
	   {
	   object_class_id = (tcurve->num_poles == 2) ?
	                        OPP_GR3dlineseg_class_id : OPP_GR3dlinestr_class_id;
	   if ( tcurve->rational )
	      {
	      /* Rational linestring => unweight the poles so */
	      /* the geometry will be posted correctly.       */
	      BSunwght_p( &rc1, tcurve->poles, tcurve->weights,
	                  &tcurve->num_poles, tcurve->poles );

	         BS_ERRCHK( rc1, "VEoutput_span: BSunwght_p failed" );

	      tcurve->rational = FALSE;
	      }  /* end: if ( tcurve->rational ) */
	   }
	else
	   object_class_id = OPP_GRbcsubbc_class_id;

	/* construct object for this span */
	sts = om$construct( msg     = message GRvg.GRconstruct( cons_args ),
	                    osnum   = VEmaster_env.md_id.osnum,
	                    classid = object_class_id,
	 	            p_objid = &new_object );

	   OM_ERRCHK( sts, "VEoutput_span: om$construct failed" );

	/* restore rational flag for tcurve */
	tcurve->rational = old_rational;

	}   /* VEoutput_span */


/*--- VElookup_shared_edge -----------------------------------------------*/

static OM_S_OBJID VElookup_shared_edge( edge_id, osnum )

	IGRint  edge_id;
	OMuword osnum;

/*
NAME
	VElookup_shared_edge (static)

DESCRIPTION
	Given an edge object id and object space number, this function returns
	the object id of the edge's shared edge.

PARAMETERS
	edge_id (IN) - the edge whose shared edge is to be found
	osnum (IN) - the object space number of the edge

GLOBALS USED
	VEcommon_edge_chan_defined (static) - for optimized use of
	                                      channel selectors
	VEcommon_edge_chan (static) - for optimized use of channel selectors

RETURN VALUES
	The object id of the shared edge associated with 'edge_id'

HISTORY
	07/04/91    S.P. Rogers
	   Creation Date
*/

	{
	OMuint              common_edge_count;
	OM_S_OBJECT_LINKAGE common_edge_linkage[1];

	if ( ! VEcommon_edge_chan_defined )
	   {
	   om$make_chanselect( channame     = "EMSedge.to_common_edge",
	                       p_chanselect = &VEcommon_edge_chan );

	   VEcommon_edge_chan_defined = TRUE;
	   }

	om$get_channel_objects( osnum        = osnum,
	                        objid        = edge_id,
	                        p_chanselect = &VEcommon_edge_chan,
	                        list         = common_edge_linkage,
	                        size         = 1,
	                        count        = &common_edge_count );

	return( common_edge_linkage[0].S_objid );
	}  /* VElookup_shared_edge */


/*--- VEmap_span_from_curve_to_curve ----------------------------------------*/

static void VEmap_span_from_curve_to_curve( from_curve, from_start, from_end,
	                                    to_curve, to_start, to_end )

	struct IGRbsp_curve *from_curve;
	IGRdouble           from_start, from_end;
	struct IGRbsp_curve *to_curve;
	IGRdouble           *to_start, *to_end;

/*
NAME
	VEmap_span_from_curve_to_curve (static)

DESCRIPTION
	This function maps a parametric span on one curve to parametric values
	on another curve.  The two curves are assumed to be within tolerance
	of each other at all points.

PARAMETERS
	from_curve (IN) - the curve to map from
	from_start (IN) - U value of start of span to map
	from_end (IN) - U value of end of span to map
	to_curve (IN) - the curve to map to
	to_start (OUT) - mapped U value of 'from_start'
	to_end (OUT) - mapped U value of 'from_end'

GLOBALS USED
	none

HISTORY
	07/04/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRpoint              point, base_pt;
	BSrc                  rc;
	IGRdouble             dist, temp;
	IGRdouble             to_parm_start, to_parm_end, to_test_u[2];

	to_parm_start = to_curve->knots[to_curve->order - 1];
	to_parm_end = to_curve->knots[to_curve->num_knots - to_curve->order];

        if ( (from_start == 0.0) && (from_end == 1.0) )
           {
           /* whole curve */
           *to_start = to_parm_start;
           *to_end = to_parm_end;
           return;
           }

	BScveval( from_curve, from_start, 0, (IGRpoint *)point, &rc );
	BSmdstptcv( to_curve, point, to_start, base_pt, &dist, &rc );
	   BS_ERRCHK( rc, "VEmap_span_from_curve_to_curve: BSmdstptcv (1) failed" );

	BScveval( from_curve, from_end, 0, (IGRpoint *)point, &rc );
	BSmdstptcv( to_curve, point, to_end, base_pt, &dist, &rc );
	   BS_ERRCHK( rc, "VEmap_span_from_curve_to_curve: BSmdstptcv (2) failed" );

	if ( to_curve->phy_closed )
	   {
	   /* the to_curve is closed so we must check that the mapping was o.k. because   */
	   /* a point that should really map to the end point of the curve will be mapped */
	   /* to the start point                                                          */

	   /* map two points between from_start and from_end to the to_curve */
	   temp = from_start + ((from_end - from_start) / 3.0);
	   BScveval( from_curve, temp, 0, (IGRpoint *)point, &rc );
	   BSmdstptcv( to_curve, point, &(to_test_u[0]), base_pt, &dist, &rc );
	      BS_ERRCHK( rc, "VEmap_span_from_curve_to_curve: BSmdstptcv (3) failed" );

	   temp = from_start + 2.0 * ((from_end - from_start) / 3.0);
	   BScveval( from_curve, temp, 0, (IGRpoint *)point, &rc );
	   BSmdstptcv( to_curve, point, &(to_test_u[1]), base_pt, &dist, &rc );
	      BS_ERRCHK( rc, "VEmap_span_from_curve_to_curve: BSmdstptcv (4) failed" );

	   if ( to_test_u[0] < to_test_u[1] )
	      {
	      /* The test points ARE ordered the same way they started so the to_curve  */
	      /* from_curve are not reversed in parameterization.   If the mappings of  */
	      /* from_start and from_end ARE reversed, then we know that the mapping of */
	      /* from_end must really be the end point of the to_curve                  */
	      if ( *to_end <= *to_start )
	         *to_end = to_parm_end;
	      }
	   else
	      {
	      /* The test points are NOT ordered the same way they started so the   */
	      /* to_curve and from_curve are reversed in parameterization.  If the  */
	      /* mappings of from_start and from_end are NOT reversed, then we know */
	      /* that the mapping of from_start must really be the end point of the */
	      /* to_curve.                                                          */
	      if ( *to_start <= *to_end )
	         *to_start = to_parm_end;
	      }
	   }

	}  /* VEmap_span_from_curve_to_curve */


/*--- VEmap_soos --------------------------------------------------------*/

static void VEmap_soos( map_surf, map_id, env, dest_edge_surf, dest_edge_id, num_soos, soo_parms )

	struct IGRbsp_surface *map_surf;
	OM_S_OBJID            map_id;
	struct VEenv_info     *env;
	struct IGRbsp_surface *dest_edge_surf;
	OM_S_OBJID            dest_edge_id;
	IGRint                num_soos;
	IGRdouble             *soo_parms;

/*
NAME
	VEmap_soos (static)

DESCRIPTION
	This function maps the u parameters for SOs from the model space
	counterpart curve to the curve that VE is using for output.  It is
	designed to be used when reconciling user-defined SOs with the curves
	being output by VE.

PARAMETERS
	map_surf (IN) - the surface to which the edge that has the SOs belongs
	map_id (IN) - the object id of the edge that has the SOs
	env (IN) - the environment of 'map_surf'
	dest_edge_surf (IN) - the surface to which the destination curve belongs
	dest_edge_id (IN) - the object id of the edge that represents the
	                    destination curve
	num_soos (IN) - the number of SOs to map
	soo_parms (IN/OUT) - the SO parameters to map

GLOBALS USED
	none

HISTORY
	07/04/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRint                  ii;
	IGRdouble               u1, u2;
	struct BSgeom_bsp_curve *dest_gmcurve;
	struct BSgeom_bsp_curve *source_gmcurve;

	if ( num_soos > 0 )
	   {
	   dest_gmcurve = VEget_edge_geometry( dest_edge_surf, dest_edge_id, env, TRUE );
	   source_gmcurve = VEget_edge_geometry( map_surf, map_id, env, FALSE );

	   for ( ii = 0; ii < (num_soos * 2); ii += 2 )
	      {
	      VEmap_span_from_curve_to_curve( source_gmcurve->bspcv, soo_parms[ii], soo_parms[ii+1],
	                                      dest_gmcurve->bspcv, &u1, &u2 );

	      /* keep the soo span sorted */
	      if ( u1 < u2 )
	         {
	         soo_parms[ii] = u1;
	         soo_parms[ii+1] = u2;
	         }
	      else
	         {
	         soo_parms[ii] = u2;
	         soo_parms[ii+1] = u1;
	         }

	      }  /* end: for */

	   VEfree_geom_curve( dest_gmcurve );
	   VEfree_geom_curve( source_gmcurve );

	   }  /* end: if ( num_soos ) */

	}  /* VEmap_soos */


/*--- VEsort_soos ------------------------------------------------------*/

static void VEsort_soos( num_soos, soo_parms, soo_attr, soo_types )

	IGRint            num_soos;
	IGRdouble         *soo_parms;
	struct IGRdisplay *soo_attr;
	IGRint            *soo_types;

/*
NAME
	VEsort_soos (static)

DESCRIPTION
	This function sorts an array of SOs so that the spans are in
	increasing order.  The companion arrays of display attributes and
	SO types are also modified to maintain correspondence with the
	correct SO span

PARAMETERS
	num_soos (IN) - the number of SOs to sort
	soo_parms (IN/OUT) - the array of SO parameters
	soo_attr (IN/OUT) - the array of SO attributes
	soo_types (IN/OUT) - the array of soo types

GLOBALS USED
	none

HISTORY
	07/03/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRboolean        swap = TRUE;
	struct IGRdisplay t_attr;
	IGRdouble         t_parms[2];
	IGRint            t_type;
	IGRint            ii, jj;

	/* sort the soos */
	if ( num_soos > 1 )
	   {
	   while( swap )
	      {
	      swap = FALSE;
	      for ( ii = 0, jj = 0; ii < (num_soos-1); ii++, jj += 2 )
	         {
	         if( soo_parms[jj] > soo_parms[jj+2] )
	            {
	            t_parms[0] = soo_parms[jj];
	            t_parms[1] = soo_parms[jj+1];
	            memcpy( &t_attr, &soo_attr[ii], sizeof( struct IGRdisplay ) );
	            t_type = soo_types[ii];
	            
	            soo_parms[jj]   = soo_parms[jj+2];
	            soo_parms[jj+1] = soo_parms[jj+3];
	            memcpy( &soo_attr[ii], &soo_attr[ii+1], sizeof( struct IGRdisplay ) );
	            soo_types[ii] = soo_types[ii+1];
	            	            
	            soo_parms[jj+2] = t_parms[0];
	            soo_parms[jj+3] = t_parms[1];
	            memcpy( &soo_attr[ii+1], &t_attr, sizeof( struct IGRdisplay ) );
	            soo_types[ii+1] = t_type;
				
	            swap = TRUE;
	            }

	         }  /* end: for */

	      }  /* end: while */

	   }  /* end: if ( num_soos > 1 ) */

	}  /* VEsort_soos */


/*--- VEget_model_space_counterpart -----------------------------------------------*/

static void VEget_model_space_counterpart( elem, edge, create, msc_id, map_id, map_surf )

	struct VEelement_header *elem;
	struct VEedge_header    *edge;
	IGRboolean              create;
	GRobjid                 *msc_id;
	GRobjid                 *map_id;
	struct IGRbsp_surface   **map_surf;

/*
NAME
	VEget_model_space_counterpart (static)

DESCRIPTION
	This function gets the model space counterpart for an edge.  It
	also returns indicators of whether a mapping will have to made from
	the curve that VE maintains to the curve of the model space counterpart.
	A mapping will have to be done if 'map_id' is not NULL_OBJID.

PARAMETERS
	elem (IN) - the element to which the edge belongs
	edge (IN) - the edge for which to get the model space counterpart
	create (IN) - flag indicating whether to create the model space
	              counterpart if not present
	msc_id (OUT) - the object id of the model space counterpart
	map_id (OUT) - the object id of the edge that has the model space
	               counterpart; will be NULL_OBJID if no mapping needs
	               to be done
	map_surf (OUT) - the surface to which the edge indicated by 'map_id'
	                 belongs, if available

GLOBALS USED
	none

NOTES
	An assumption is made with regard to an edge, its model space
	counterpart, and whether mapping will have to be performed between the
	geometry that VE uses and the model space counterpart geometry.  The
	assumption is that the model space counterpart and the edge with which
	is associated have the same XYZ (i.e., bspline curve in model space)
	geometry.

HISTORY
	07/04/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong    sts, msg;
	OM_S_OBJID temp_id;
	IGRshort   options;
	IGRushort  edge_prop_word;

	*msc_id = *map_id = NULL_OBJID;
	*map_surf = NULL;

	if ( (edge->type == STANDALONE) ||
	     (edge->type == SINGLE_POINT) ||
	     (edge->type == WIREFRAME_CROSS_HATCH) ||
	     (edge->type == HORIZON_CURVE) )
	   {
	   /* edge is from a wireframe entity => it is its own model space counterpart */
	   *msc_id = edge->edge_id;
	   *map_id = NULL_OBJID;
	   *map_surf = NULL;
	   }
	else
	   {
	   /* edge is from a surface => get its model space counterpart */
	   if ( edge->status & REAL_SHARED_EDGE )
	      {
	      /* get the properties word for the edge */
	      sts = om$send( msg      = message EMSedge.EMget_props( &msg, &edge_prop_word ),
	                     senderid = NULL_OBJID,
	                     targetid = edge->edge_id,
	                     targetos = elem->env->osnum );

	         OM_ERRCHK( sts, "VEget_model_space_counterpart:  EMgetprops send failed" );
	         MSG_ERRCHK( msg, "VEget_model_space_counterpart:  EMgetprops failed" );

	      if (edge_prop_word & EMED_SUBORDINATE)
	         {
	         /* dummy edge is dominant => it will have the model space counterpart */
	         if ( edge->shared_edge )
	            {
	            /* get shared edge info from dummy edge */
	            temp_id = edge->shared_edge->edge_id;
	            }
	         else
	            {
	            /* dummy edge is gone => we must look up the common edge id again */
	            temp_id = VElookup_shared_edge( edge->edge_id, elem->env->osnum );
	            }

	         if ( (!(edge->status & USING_DUMMY_GEOMETRY)) || (edge->gm_curve3d->bspcv->order == 2) )
	            {
	            /* mapping from VE curve to model space counterpart will have to be done */
	            /* because we are not using the dummy geometry or the dummy geometry is  */
	            /* order 2 and may have been re-parameterized.                           */
	            *map_id = temp_id;
	            if ( edge->shared_edge)
	               *map_surf = edge->shared_elem->geom.gmsurf->bspsf;
	            }

	         }  /* end: if */
	      else
	         {
	         /* real edge is dominant => it will have the model space counterpart */
	         temp_id = edge->edge_id;

	         if ( (edge->status & USING_DUMMY_GEOMETRY) || (edge->gm_curve3d->bspcv->order == 2) )
	            {
	            /* mapping from VE curve to model space counterpart will have to be done  */
	            /* because we are using the dummy geometry or the dummy geometry is order */
	            /* 2 and may have been re-parameterized.                                  */
	            *map_id = temp_id;
	            *map_surf = elem->geom.gmsurf->bspsf;
	            }
	         }
	      }
	   else
	      {
	      /* edge isn't a shared edge */
	      temp_id = edge->edge_id;

	      if ( edge->gm_curve3d->bspcv->order == 2 )
	         {
	         /* mapping from VE curve to model space counterpart will have to be done */
	         /* because the VE curve is order 2 and may have been re-parameterized    */
	         *map_surf = elem->geom.gmsurf->bspsf;
	         *map_id = edge->edge_id;
	         }
	      }

	   options = (create) ? 0 : EMSlcopt_existingmsc;

	   sts = om$send( msg = message EMSboundary.EMgetxyzobj( &msg, options,
	                                                         &elem->env->md_env.md_env,
	                                                         NULL, NULL, NULL, NULL,
	                                                         elem->env->osnum, msc_id ),
	                  senderid = NULL_OBJID,
	                  targetid = temp_id,
	                  targetos = elem->env->osnum );

	      OM_ERRCHK( sts, "VEget_model_space_counterpart:  EMgetxyzobj send failed" );
	      MSG_ERRCHK( msg, "VEget_model_space_counterpart:  EMgetxyzobj failed" );

	   if ( ! (1 & sts & msg) )
	      *msc_id = NULL_OBJID;

	   }  /* end: else (edge from a surface) */

	}  /* VEget_model_space_counterpart */

	
/*--- VEdelete_soos_from_edges -------------------------------------------------*/

void VEdelete_soos_from_edges( element )

	struct VEelement_header *element;

/*
NAME
	VEdelete_soos_from_edges

DESCRIPTION
	Given an element, this function deletes all the existing automatic SOs
	from the edges.

PARAMETERS
	element (IN) - the element whose existing SOs are to be deleted

GLOBALS USED
	none

HISTORY
	10/03/91    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header    *this_edge;
	OM_S_OBJID              msc_id;
	OM_S_OBJID              map_id;
	struct IGRbsp_surface   *map_surf;
	IGRdouble               span_start;
	IGRdouble               span_end;
	struct VEvisib_node     *cur_node;
	struct BSgeom_bsp_curve *msc_gmcurve = NULL;
	IGRdouble               u_parms[2], temp;
	OMuword                 msc_os;

	this_edge = element->edges;
	while ( this_edge )
	   {
	   if ( (this_edge->gm_curve3d) && (!(this_edge->status & WAS_A_DUMMY)) )
	      {
	      VEget_model_space_counterpart( element, this_edge, FALSE, &msc_id, &map_id, &map_surf );

	      if ( msc_id != NULL_OBJID )
	         {
	         /* horizon curves may not be in the same object space as their surface */
	         msc_os = (this_edge->type == HORIZON_CURVE) ?
	                        VEmaster_env.md_id.osnum : element->env->osnum;
	         if( map_id != NULL_OBJID )
	            {
	            /* the parameters must be mapped from the VE curve to the model space   */
	            /* counterpart curve => get the geometry of the model space counterpart */
	            msc_gmcurve = VEget_edge_geometry( map_surf, map_id, element->env, FALSE );
	            }

	         /* get start and end parameters for this edge */
	         cur_node = this_edge->visib_list;
	         span_start = cur_node->u;
	         while ( cur_node->next )
	            cur_node = cur_node->next;
	         span_end = cur_node->u;

	         if ( map_id != NULL_OBJID )
	            {
	            /* map parameters from VE curve to the curve representing */
	            /* the model space counterpart                            */
	            VEmap_span_from_curve_to_curve( this_edge->gm_curve3d->bspcv, span_start, span_end,
	                                            msc_gmcurve->bspcv, &(u_parms[0]), &(u_parms[1]) );
	            }
	         else
	            {
	            u_parms[0] = span_start;
	            u_parms[1] = span_end;
	            }

	         if( u_parms[1] < u_parms[0] )
	            {
	            temp = u_parms[0];
	            u_parms[0] = u_parms[1];
	            u_parms[1] = temp;
	            }

	         HSremove_VEso_on_edge( msc_id, msc_os,
	                                VEwin_info.VEwin_grid.objid, VEwin_info.VEwin_grid.osnum,
	                                &element->env->md_env, &VEmaster_env,
	                                u_parms[0], u_parms[1], VEoutput_data.delete_overrides,
					FALSE );

	         }  /* end: if ( msc_id != NULL_OBJID ) */

	      }  /* end: if ( edge isn't a dummy */

	   this_edge = this_edge->next;
	   }  /* end: while */

	}  /* VEdelete_soos_from_edges */


/*--- VEget_user_defined_input_soos --------------------------------------------*/

static void VEget_user_defined_input_soos( element, edge, orig_attr, num_soos, soo_types, soo_parms, soo_attr )

	struct VEelement_header *element;
	struct VEedge_header    *edge;
	struct IGRdisplay       *orig_attr;
	IGRint                  *num_soos;
	IGRint                  **soo_types;
	IGRdouble               **soo_parms;
	struct IGRdisplay       **soo_attr;

/*
NAME
	VEget_user_define_input_soos (static)

DESCRIPTION
	Given an edge, this function determines if it has user-defined SOs
	and if it does, returns them in three arrays: the types of the SO
	spans, the parameters defining the SO spans, and the display
	attributes for each span.  The parameters defining the SO spans are
	mapped to the geometry associated with the input edge and the spans
	are also sorted into increasing order.

PARAMETERS
	element (IN) - the element to which the edge belongs
	edge (IN) - the edge for which to get the SOs
	orig_attr (IN) - the original display attributes for the edge
	num_soos (OUT) - the number of user SOs on the edge
	soo_types (OUT) - the array of SO types; this array comes from memory
	                  managed by the SO routines and should not be freed
	soo_parms (OUT) - the array of SO parameters; this array comes from
	                  memory managed by the SO routines and should not be
	                  freed
	soo_attr (OUT) - the array of SO display attributes; this array comes
	                 from memory managed by the SO routines and should not
	                 be freed

GLOBALS USED
	none

HISTORY
	07/03/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong               msg, sts;
	IGRshort              properties;
	struct IGRbsp_surface *map_surf, *edge_surf;
	OM_S_OBJID            map_id, edge_id;
	GRobjid               msc_id;
	OMuword               msc_os;

	
	*num_soos = 0;
	*soo_types = NULL;
	*soo_parms = NULL;
	*soo_attr = NULL;

	VEget_model_space_counterpart( element, edge, FALSE, &msc_id, &map_id, &map_surf );

	/* horizon curves may not be in the same object space as their surface */
	msc_os = (edge->type == HORIZON_CURVE) ?
	              VEmaster_env.md_id.osnum : element->env->osnum;

	if ( msc_id == NULL_OBJID )
	   return;  /* couldn't get model space counterpart id */

	sts = om$send( msg = message GRvg.GRgetprops( &msg, &properties ),
	               senderid = NULL_OBJID,
	               targetid = msc_id,
	               targetos = msc_os );

	   OM_ERRCHK( sts, "VEget_user_defined_input_soos: GRvg.GRgetprops send failed" );
	   MSG_ERRCHK( msg, "VEget_user_defined_input_soos: GRvg.GRgetprops failed" );
	
	if ( (properties & DEHAS_OVERRIDE) && (DEsos) )
	   {
	   sts = om$send( msg = message DEso.DEget( &msg,
	                                            soo_types,  /* don't free this array */
	                                            soo_parms,  /* don't free this array */
	                                            num_soos,
	                                            soo_attr,   /* don't free this array */
	                                            orig_attr,
	                                            msc_id,
	                                            (GRobjid)VEwin_info.VEwin_grid.objid,
	                                            &element->env->matrix_type,
	                                            element->env->matrix,
						    2, TRUE ),  /* manual SOs only */
	                  senderid = NULL_OBJID,
	                  targetid = DEsos[msc_os],
	                  targetos = VEmaster_env.md_id.osnum );
			     
	      OM_ERRCHK( sts, "VEget_user_defined_input_soos: DEso.DEget send failed" );
              /* don't do MSG_ERRCHK here because DEget returns MSFAIL when there are */
              /* no SOs which could happen a lot                                      */

           if ( !(1 & sts & msg) )
              {
              *num_soos = 0;
              }

	   /* map soos from model space counterpart to the curve that VE is using */
	   if ( map_id != NULL_OBJID )
	      {
	      if ( edge->status & USING_DUMMY_GEOMETRY )
	         {
	         /* using dummy geometry => get dummy edge information */
	         if ( edge->shared_edge )
	            {
	            edge_surf = edge->shared_elem->geom.gmsurf->bspsf;
	            edge_id = edge->shared_edge->edge_id;
	            }
	         else
	            {
	            /* dummy edge is gone */
	            edge_surf = NULL;
	            edge_id = VElookup_shared_edge( edge->edge_id, element->env->osnum );
	            }
	         }
	      else
	         {
	         edge_surf = element->geom.gmsurf->bspsf;
	         edge_id = edge->edge_id;
	         }

	      VEmap_soos( map_surf, map_id, element->env, edge_surf, edge_id, *num_soos, *soo_parms );
	      }

	   VEsort_soos( *num_soos, *soo_parms, *soo_attr, *soo_types );
	   }

	}  /* VEget_user_defined_input_soos */


/*--- VEdoes_soo_intersect ------------------------------------------------*/

static IGRboolean VEdoes_soo_intersect_span( u_start, u_end, soo_parms )

	IGRdouble u_start;
	IGRdouble u_end;
	IGRdouble *soo_parms;

/*
NAME
	VEdoes_soo_intersect_span (static)

DESCRIPTION
	This function determines if the span defined from [u_start, u_end] and
	the SO span from [soo_parms[0], soo_parms[1]] intersect.

PARAMETERS
	u_start (IN) - start of span
	u_end (IN) - end of span
	soo_parms (IN) - SO span parameters

GLOBALS USED
	none

RETURN VALUES
	TRUE - if SO intersects the span
	FALSE - otherwise

HISTORY
	07/03/91    S.P. Rogers
	   Creation Date
*/

	{

	if ( ( (u_start >= soo_parms[0]) && (u_start <= soo_parms[1]) ) ||
	     ( (u_end >= soo_parms[0]) && (u_end <= soo_parms[1]) ) ||
	     ( (u_start < soo_parms[0]) && (u_end > soo_parms[1]) ) )
	  return( TRUE );
	else
	   return( FALSE );

	}  /* VEdoes_soo_intersect_span */


/*---- VEprocess_span_for_soos --------------------------------------------------------*/

static void VEprocess_span_for_soos( type, visib, orig_attr, hid_attr, curve, temp_curve, cons_args,
	                             span_start, span_end, num_soos, soo_types, soo_parms, soo_attr )

	IGRshort              type;
	IGRshort              visib;
	struct IGRdisplay     *orig_attr;
	struct IGRdisplay     *hid_attr;
	struct IGRbsp_curve   *curve;
	struct IGRbsp_curve   *temp_curve;
        struct GRvg_construct *cons_args;
	IGRdouble             span_start;
	IGRdouble             span_end;
	IGRint                num_soos;
	IGRint                *soo_types;
	IGRdouble             *soo_parms;
	struct IGRdisplay     *soo_attr;

/*
NAME
	VEprocess_span_for_soos (static)

DESCRIPTION
	This function takes a VISIBLE/HIDDEN span of an edge, consolidates
	user defined symbology overrides with it, and outputs the consolidated
	spans as curves.

PARAMETERS
	type (IN) - the type of the edge (CURVE_OBJECT, POINT_OBJECT)
	visib (IN) - the visiblity of the span
	orig_attr (IN) - the original display attributes of the edge
	hid_attr (IN) - the hidden display attributes of the edge
	curve (IN) - the curve geometry for the edge
	temp_curve (IN) - temporary curve used for splitting (must be at
	                  least as large as curve)
	cons_args (IN) - the construct arguments for the object to be created
	span_start (IN) - the U value of the span start
	span_end (IN) - the U value of the span edn
	num_soos (IN) - the number of user SOs on the edge
	soo_types (IN) - the types of the user SOs
	soo_parms (IN) - the parameters of the user SOs
	soo_attr (IN) - the display attributes of the user SOs

GLOBALS USED
	none

HISTORY
	07/03/91    S.P Rogers
	   Creation Date
*/

	{
	IGRint    parm_index, attr_index;
	IGRdouble u;

	if ( num_soos )
	   {
	   parm_index = 0;
	   attr_index = 0;

	   /* find the first soo that intersects this span */
	   while ( ! VEdoes_soo_intersect_span( span_start, span_end, &soo_parms[parm_index] ) )
	      {
	      attr_index++;
	      parm_index += 2;
	      if ( attr_index >= num_soos )
	         break;
	      }  /* end: while */

	   /* loop over all the soos that intersect this span */
	   u = span_start;
	   while ( (attr_index < num_soos) &&
                   (VEdoes_soo_intersect_span( span_start, span_end, &soo_parms[parm_index] )) )
	      {
	      if ( soo_parms[parm_index] <= u )
	         {
	         if ( soo_parms[parm_index+1] >= span_end )
	            {
	            /* entire span contained within this soo */
	            VEoutput_span( type, visib, &soo_attr[attr_index], hid_attr, curve, temp_curve,
	                           cons_args, u, span_end, TRUE, soo_types[attr_index] );
	            u = span_end;
	            break;
	            }
	         else
	            {
	            /* left part of span contained within soo */
	            VEoutput_span( type, visib, &soo_attr[attr_index], hid_attr, curve, temp_curve,
	                           cons_args, u, soo_parms[parm_index+1], TRUE, soo_types[attr_index] );
	            u = soo_parms[parm_index+1];
	            }
	         }
	      else
	         {
	         VEoutput_span( type, visib, orig_attr, hid_attr, curve, temp_curve,
	                        cons_args, u, soo_parms[parm_index], FALSE, 0 );

	         u = soo_parms[parm_index];

	         if ( soo_parms[parm_index+1] > span_end )
	            {
	            /* rest of span on right contained within soo */
	            VEoutput_span( type, visib, &soo_attr[attr_index], hid_attr, curve, temp_curve,
	                           cons_args, soo_parms[parm_index], span_end, TRUE, soo_types[attr_index] );
	            u = span_end;
	            break;
	            }
	         else
	            {
	            /* part of the span on right contained within soo */
	            VEoutput_span( type, visib, &soo_attr[attr_index], hid_attr, curve, temp_curve,
	                           cons_args, soo_parms[parm_index], soo_parms[parm_index+1],
	                           TRUE, soo_types[attr_index] );
	            u = soo_parms[parm_index+1];
	            }

	         }  /* end: else */

	      attr_index++;
	      parm_index += 2;

	      }  /* end: while */

	   if ( u < span_end )
	      {
	      /* ouput what remains of the curve outside the range of the soos */
	      VEoutput_span( type, visib, orig_attr, hid_attr, curve, temp_curve, cons_args, u, span_end, FALSE, 0 );
	      }

	   }
	else
	   {
	   VEoutput_span( type, visib, orig_attr, hid_attr, curve, temp_curve,
	                  cons_args, span_start, span_end, FALSE, 0 );
	   }

	}  /* VEprocess_span_for_soos */


/*--- VEcreate_soos_for_edge ----------------------------------------------*/

static void VEcreate_soos_for_edge( element, edge )

	struct VEelement_header *element;
	struct VEedge_header    *edge;

/*
NAME
	VEcreate_soos_for_edge (static)

DESCRIPTION
	This function creates SOs to represent the HIDDEN/OVERLAPPED
	spans of an edge.  Gapping is also applied at the visibility
	transitions if requested by the user.

PARAMETERS
	element (IN) - the element to which the edge belongs
	edge (IN) - the edges that is to have SOs created for it

GLOBALS USED
	VEexec_parms.VEgapping - to decide if gapping should be done

HISTORY
	07/03/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRdouble               span_start;
	IGRdouble               span_end;
	struct VEvisib_node     *cur_node;
	struct IGRbsp_curve     *cur_curve, curve_def;
	GRobjid                 msc_id = NULL_OBJID;
	OM_S_OBJID              map_id;
	struct IGRbsp_surface   *map_surf;
	struct BSgeom_bsp_curve *msc_gmcurve = NULL;
	IGRshort                span_type;
	IGRdouble               u_parms[2], temp;
	struct GRmd_env         *edge_env;


	if ( (edge->gm_curve3d) && (!(edge->status & WAS_A_DUMMY)) )
	   {
	   /* horizon curves may not be in the same object space as their surface */
	   edge_env = (edge->type == HORIZON_CURVE) ?
	                   &VEmaster_env : &element->env->md_env;

	   /* edge is not a dummy shared edge */
	   cur_curve = edge->gm_curve3d->bspcv;

	   /* get temporary storage for the parts of the curve that are split out */
	   VEget_temp_curve_storage( &curve_def,
	                             cur_curve->num_poles,
	                             cur_curve->num_knots,
	                             cur_curve->rational );

	   /* make sure curve_def has valid data in its header */
	   curve_def.rational       = edge->gm_curve3d->bspcv->rational;
	   curve_def.num_boundaries = 0;

	   /* flag all the degenerate visibility spans */
	   VEmark_degenerate_spans( cur_curve, edge->visib_list, &curve_def );

	   /* apply gaps to the visibility transitions */
	   if ( VEexec_parms.VEgapping )
	      VEgap_edge( edge, TRUE );

  	   /* loop through all of the spans of this edge */
	   cur_node = edge->visib_list;
	   while ( cur_node->next )
	      {
	      /* skip over degenerate spans */
	      while ( (cur_node->next) && (cur_node->visib == DEGENERATE_SPAN) )
	         cur_node = cur_node->next;

	      if (! cur_node->next)
	         break;

	      if ( (cur_node->visib == HIDDEN) || (cur_node->visib == OVERLAPPED) )
	         {
	         span_start = cur_node->u;
	         span_end   = cur_node->next->u;

	         if ( msc_id == NULL_OBJID )
	            {
	            /* get model space counterpart because we haven't got it yet */
	            VEget_model_space_counterpart( element, edge, TRUE, &msc_id, &map_id, &map_surf );

	            if ( msc_id == NULL_OBJID )
	               return;

	            if( map_id != NULL_OBJID )
	               msc_gmcurve = VEget_edge_geometry( map_surf, map_id, element->env, FALSE );
	            }

	         if ( map_id != NULL_OBJID )
	            {
	            VEmap_span_from_curve_to_curve( cur_curve, span_start, span_end,
	                                            msc_gmcurve->bspcv, &(u_parms[0]), &(u_parms[1]) );
	            }
	         else
	            {
	            u_parms[0] = span_start;
	            u_parms[1] = span_end;
	            }

	         if( u_parms[1] < u_parms[0] )
	            {
	            temp = u_parms[0];
	            u_parms[0] = u_parms[1];
	            u_parms[1] = temp;
	            }
	
	         if ( cur_node->visib == OVERLAPPED )
	            {
	            span_type = HE_INVISIBLE_SPAN;
	            VEplace_multiple_soos( 1, u_parms, &span_type, FALSE, msc_id, edge_env );
	            }
	         else if ( cur_node->visib == HIDDEN )
	            {
	            span_type = HE_HIDDEN_SPAN;
   	            VEplace_multiple_soos( 1, u_parms, &span_type, FALSE, msc_id, edge_env );
	            }

	         }  /* span is HIDDEN or OVERLAPPED */

	      cur_node = cur_node->next;
	      }  /* end: while */

	   VEfree_geom_curve( msc_gmcurve );
	   }  /* end: if ( edge is not a dummy ) */

	}  /* VEcreate_soos_for_edge */


/*--- VEcreate_overlapped_soos_for_edge ----------------------------------------------*/

void VEcreate_overlapped_soos_for_edge( element, edge )

	struct VEelement_header *element;
	struct VEedge_header    *edge;

/*
NAME
	VEcreate_overlapped_soos_for_edge

DESCRIPTION
	This function creates SOs to represent the OVERLAPPED
	spans of an edge.  This function is designed to be called
	after the self-intersection phase of the self-hiding process
	where the OVERLAPPED regions are indicated on the temp-list
	of the edge.

PARAMETERS
	element (IN) - the element to which the edge belongs
	edge (IN) - the edge which is to have SOs representing its OVERLAPPED
	            spans created

GLOBALS USED
	VEoutput_data.output_curves - to decide if curve or SOs are being output

HISTORY
	10/10/91    S.P. Rogers
	   Creation Date
*/

	{
	IGRdouble               span_start;
	IGRdouble               span_end;
	struct VEtemp_node      *cur_node;
	struct IGRbsp_curve     *cur_curve;
	GRobjid                 msc_id = NULL_OBJID;
	OM_S_OBJID              map_id;
	struct IGRbsp_surface   *map_surf;
	struct BSgeom_bsp_curve *msc_gmcurve = NULL;
	IGRshort                span_type;
	IGRdouble               u_parms[2], temp;
	struct GRmd_env         *edge_env;


	if ( VEoutput_data.output_curves )
	   return;

	if ( (edge->gm_curve3d) && (!(edge->status & WAS_A_DUMMY)) )
	   {
	   /* horizon curves may not be in the same object space as their surface */
	   edge_env = (edge->type == HORIZON_CURVE) ?
	                    &VEmaster_env : &element->env->md_env;

	   /* edge is not a dummy shared edge */
	   cur_curve = edge->gm_curve3d->bspcv;

	   /* loop through all of the spans of this edge */
	   cur_node = edge->temp_list;
	   while ( cur_node->next )
	      {
	      if ( cur_node->next_visib == OVERLAPPED )
	         {
	         if ( msc_id == NULL_OBJID )
	            {
	            /* get model space counterpart because we haven't got it yet */
	            VEget_model_space_counterpart( element, edge, TRUE, &msc_id, &map_id, &map_surf );

	            if ( msc_id == NULL_OBJID )
	               return;

	            if ( map_id != NULL_OBJID )
	               msc_gmcurve = VEget_edge_geometry( map_surf, map_id, element->env, FALSE );
	            }

	         span_start = cur_node->u;
	         span_end   = cur_node->next->u;

	         if ( map_id != NULL_OBJID )
	            {
	            VEmap_span_from_curve_to_curve( cur_curve, span_start, span_end,
	                                            msc_gmcurve->bspcv, &(u_parms[0]), &(u_parms[1]) );
	            }
	         else
	            {
	            u_parms[0] = span_start;
	            u_parms[1] = span_end;
	            }

	         if( u_parms[1] < u_parms[0] )
	            {
	            temp = u_parms[0];
	            u_parms[0] = u_parms[1];
	            u_parms[1] = temp;
	            }

	         span_type = HE_INVISIBLE_SPAN;
	         VEplace_multiple_soos( 1, u_parms, &span_type, FALSE, msc_id, edge_env );
	         } /* end: if */

	      cur_node = cur_node->next;
	      }  /* end: while */

	   VEfree_geom_curve( msc_gmcurve );

	   }  /* end: if ( edge is not a dummy ) */

	}  /* VEcreate_overlapped_soos_for_edge */


/*--- VEcreate_curves_for_edge ----------------------------------------------*/

void VEcreate_curves_for_edge( element, edge, orig_attr )

	struct VEelement_header *element;
	struct VEedge_header    *edge;
	struct IGRdisplay       *orig_attr;

/*
NAME
	VEcreate_curves_for_edge

DESCRIPTION
	This function creates curves for an edge that represent the visibility
	transitions in the master file object space or applies SOs to the edge
	to represent the visibility transitions.  Gapping is also applied at
	the visibility transitions if requested by the user.

PARAMETERS
	element (IN) - the element to which the edge belongs
	edge (IN) - the edge whose visibility transitions should be output
	orig_attr (IN) - the original attributes of the edge

GLOBALS USED
	VEoutput_data.VEoutput_curves - to decide of curves or SOs should
	                                be output
	VEoutput_data.VEhidden_level - to decide if hidden curves should
	                               be output
	VEexec_parms.VEgapping - to decide if gapping should be performed
	VEcolor_classification - to decide if the curves should be output with
	                         a debugging color classification

HISTORY
	07/13/90    S.P. Rogers
	   Creation Date (extracted from VEestablish_curves)
*/

	{
	IGRlong               sts;
	IGRlong               msg;
	IGRlong               cons_msg;
	IGRint                num_soos;
	IGRint                *soo_types;
	IGRshort              cons_type;
	IGRdouble             span_start;
	IGRdouble             span_end;
	IGRdouble             *soo_parms;
	struct IGRdisplay     *soo_attr;
	struct IGRdisplay     my_orig_attr, vis_attr, hid_attr;
	struct GRvg_construct cons_args;
	struct GRsymbology    element_symb;
	struct VEvisib_node   *cur_node;
	struct IGRbsp_curve   *cur_curve, curve_def;

	if ( ! VEoutput_data.output_curves )
	   {
	   VEcreate_soos_for_edge( element, edge );
	   return;
	   }

	if ( (edge->gm_curve3d) && ((edge->status & TOTALLY_OVERLAPPED) == 0) )
	   {
	   /* edge is not a dummy shared edge and not totally overlapped */
	   VEcreating_hidden_edges =
	       ( ((unsigned short) VEoutput_data.hidden_level) != NO_HIDDEN_OUTPUT );

	   memcpy( &my_orig_attr, orig_attr, sizeof( struct IGRdisplay ) );

	   VEget_user_defined_input_soos( element, edge, orig_attr, &num_soos, &soo_types, &soo_parms, &soo_attr );

	   /* fill in part of the construct structure */
	   cons_args.msg        = &cons_msg;
	   cons_args.env_info   = &VEmaster_env;
	   cons_args.newflag    = FALSE;
	   cons_args.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_VE_CURVE;
	   cons_args.class_attr = NULL;
	   cons_args.name       = NULL;

	   if ( edge->type == WIREFRAME_CROSS_HATCH )
	      {
	      /* this edge is a wireframe cross hatch edge => we must get */
	      /* its symbology because it is a separate graphic object    */
	      sts = om$send( msg      = message GRvg.GRgetsymb( &msg, &element_symb ),
	                     senderid = NULL_OBJID,
	                     targetid = edge->edge_id,
	                     targetos = element->env->osnum );

	        OM_ERRCHK( sts, "VEcreate_curves_for_edge:  GRgetsymb send failed" );
	        MSG_ERRCHK( msg, "VEcreate_curves_for_edge:  GRgetsymb failed" );

	      /* Set the current attributes to be that of the wireframe     */
	      /* cross-hatching element.  NOTE:  The symbology of wireframe */
	      /* cross-hatching is not controlled by anything on the form.  */
	      /* All wireframe cross-hatching will be output in the same    */
	      /* symbology that it has in the design file.                  */
	      my_orig_attr = element_symb.display_attr;
	      }  /* end: if ( edge->type ... ) */

	   if ( VEcolor_classification )
	      {
	      /* debug mode where edge color represents classification */
	      switch ( edge->status & EDGE_CLASSIFICATION )
	         {
	         case VISIBLE_PROFILE :
	            my_orig_attr.color = 1;
	            break;
	         case VISIBLE_NON_PROFILE :
	            my_orig_attr.color = 2;
	            break;
	         case HIDDEN_NON_PROFILE :
	            my_orig_attr.color = 5;
	            break;
	         case HIDDEN_NORMAL_FLIP :
	            my_orig_attr.color = 4;
	            break;
	         }
	      }

	   /* get the visible & hidden display attributes */
	   VEget_visible_display_attr( &vis_attr, &my_orig_attr );
	   VEget_hidden_display_attr( &hid_attr, &my_orig_attr );

	   /* get temporary storage for the parts of the curve that are split out */
	   VEget_temp_curve_storage( &curve_def,
	                             edge->gm_curve3d->bspcv->num_poles,
	                             edge->gm_curve3d->bspcv->num_knots,
	                             edge->gm_curve3d->bspcv->rational );

	   /* make sure curve_def has valid data in its header */
	   curve_def.rational       = edge->gm_curve3d->bspcv->rational;
	   curve_def.num_boundaries = 0;

	   cur_curve = edge->gm_curve3d->bspcv;

	   /* flag all the degenerate visibility spans */
	   VEmark_degenerate_spans( cur_curve, edge->visib_list, &curve_def );

	   /* apply gaps to the visibility transitions */
	   if ( VEexec_parms.VEgapping )
	      VEgap_edge( edge, VEcreating_hidden_edges );

	   cons_type = (edge->type == SINGLE_POINT) ? POINT_OBJECT : CURVE_OBJECT;

	   cur_node = edge->visib_list;

  	   /* loop through all of the spans of this edge */
	   while ( cur_node->next )
	      {
	      /* skip over degenerate spans */
	      while ( (cur_node->next) && (cur_node->visib == DEGENERATE_SPAN) )
	         cur_node = cur_node->next;

	      if ( ! cur_node->next )
	         break;

	      if ( (cur_node->visib == VISIBLE) || (cur_node->visib == HIDDEN) )
	         {
	         span_start = cur_node->u;
	         span_end   = cur_node->next->u;

	         VEprocess_span_for_soos( cons_type, cur_node->visib, &vis_attr, &hid_attr,
	                                  cur_curve, &curve_def, &cons_args, span_start, span_end,
	                                  num_soos, soo_types, soo_parms, soo_attr );
	         }

    	      cur_node = cur_node->next;
	      }  /* end: while */

	   }  /* end: if ( (edge->gm_curve3d) && (edge not totally overlapped ) */

	}  /* VEcreate_curves_for_edge */


/*---- VEestablish_curves ---------------------------------------------------*/

void VEestablish_curves( element )

	struct VEelement_header *element;

/*
NAME
	VEestablish_curves

DESCRIPTION
	Establish the curves/SOs necessary to display the output of
	the Visible Edges process for an element.  Edges are gapped
	at visibility transitions at the request of the user.

PARAMETERS
	element (IN/OUT) - The element whose edges visibility transitions
	                   should be output.  The element and all its edges
	                   are returned to the appropriate free pools by this
	                   function, so pointers to them are not valid after
	                   this function returns.

GLOBALS USED
	VEexec_status.VEsave_int_denied - use to decide if the saved
	                                  intersection list needs to be
	                                  cleaned up

HISTORY
	04/30/87    S.P. Rogers
	   Creation Date
	08/24/89    S.P. Rogers
	   Added gapping
*/

	{
	struct IGRdisplay     orig_attr;
	struct VEedge_header  *cur_edge;
	struct VEedge_header  *next_edge;

	VEupdate_num_finished();

	VEget_element_base_attr( (OM_S_OBJID)element->objid, element->env->osnum, &element->env->ref_symb, &orig_attr );

	cur_edge = element->edges;
	while ( cur_edge )
	   {
	   next_edge = cur_edge->next;
	 
	   if ( cur_edge->gm_curve3d )
	      {
	      VEcreate_curves_for_edge( element, cur_edge, &orig_attr );

	      if ( (VEexec_status.VEint_save_denied) && (cur_edge->status & REAL_SHARED_EDGE) )
	         {
	         /* cur_edge is a real shared edge and at least one save of curve/curve */
	         /* intersection data was denied => remove references to this edge from */
	         /* the saved intersection list                                         */
	         VEremove_intersection_info( TRUE, cur_edge, NULL );
	         }

	      if ( cur_edge->shared_edge )
	         {
	         /* cur_edge is a real shared edge and dummy edge exists => move */
	         /* curve definition to dummy shared edge and break links to it  */
	         cur_edge->shared_edge->gm_curve3d = cur_edge->gm_curve3d;
	         cur_edge->gm_curve3d = NULL;
	         cur_edge->shared_edge->shared_edge = NULL;
	         }
 	      }
	   else
	      {
	      /* edge is a dummy shared edge => break links between   */
	      /* shared edge and dummy shared edge. NOTE: the real    */
	      /* shared edge won't be there if we are only projecting */
	      /* and copying edges                                    */
	      if ( cur_edge->shared_edge )
	         cur_edge->shared_edge->shared_edge = NULL;

	      }

	   /* free this edge's entire visibility list */
	   VEfree_visib_node_list( cur_edge->visib_list );
	   VEfree_edge_header( cur_edge );

	   cur_edge = next_edge;

	   }  /* end: while ( cur_edge ) */

	VEfree_element_header( element );

	}  /* VEestablish_curves */


/*--- VEoutput_hidden_edges --------------------------------------------------*/

void VEoutput_hidden_edges( elem )

	struct VEelement_header *elem;

/*
NAME
	VEoutput_hidden_edges

DESCRIPTION
	Given an element, this function creates curves for those edges
	that were classified as hidden.  The hidden edges are removed
	from the element's edge list.

PARAMETERS
	elem (IN/OUT) - the element whose hidden edges should be output

GLOBALS USED
	none

HISTORY
	07/17/90    S.P. Rogers
	   Creation Date
*/

	{
	struct VEedge_header *this_edge, *next_edge, *head, *tail;
	struct IGRdisplay    orig_attr;

	VEget_element_base_attr( (OM_S_OBJID) elem->objid, elem->env->osnum, &elem->env->ref_symb, &orig_attr );

	head = tail = NULL;
	next_edge = elem->edges;
	while ( next_edge )
	   {
	   this_edge = next_edge;
	   next_edge = this_edge->next;
	   this_edge->next = NULL;

	   if ( this_edge->status & CLASSIFIED_AS_HIDDEN )
	      {
	      this_edge->visib_list->visib = HIDDEN;
	      VEcreate_curves_for_edge( elem, this_edge, &orig_attr );

	      /* remove dummy edge for this edge */
	      if ( this_edge->shared_edge )
	         VEcreate_dummies_for_split_pieces( elem, NULL, this_edge->shared_edge, this_edge->shared_elem );

	      VEfree_visib_node_list( this_edge->visib_list );
	      VEfree_edge_header( this_edge );
	      }
	   else
	      VEadd_edges_to_list( this_edge, &head, &tail );
	   }  /* end: while */

	elem->edges = head;
	}  /* VEoutput_hidden_edges */

end implementation Root;
