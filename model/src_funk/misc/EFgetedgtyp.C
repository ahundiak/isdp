/* ###################   ANSI COMPILED     ################## */
/*
 DESCRIPTION

 This file contains functions that manipulate back and forth, edge-types
 and the corresponding GRcurve classids. Example: Given an object id of an
 object which is a subclass off of GRcurve this method returns a unique
 identifier which represents this class of objects.

 The edge-types can be found in "emsedgedef.h".

 RETURN VALUES

 sts		OM_S_SUCCESS - no problems
		OM_E_NOSUCHCLASS - I don't know about this class of objects

 type		One of the numbers in emsdef.h	

 HISTORY

 05/27/87 : rlw : creation date
 10/09/87 : SM  : Added the reverse function in this file, to get classid
		  from edge type.
 12/03/87 : PP  : Added the function to get the edge type of the clipped
                  edge
 04/10/89 : SS  : If the number of points changed inside a linear-element,
                  perhaps it's edge-type is now invalid. Added the function
                  that returns the correct edge-type for linear-elements
                  given the old edge-type and the new number of points.
 05/17/89 : SS  : Added support for the curve type EMcomposite_curve.
 09/13/89 : SM  : The function giving clipped edge type was not returning
		  anything. Fixed it.
 22-Sep-89: SM  : Added boolean function EFisEdgeTypeLinear().
 10/18/89 : SS  : Added support for the curve type EMintersection_curve.
 Nov 15,90:Inasu: Included Associativity classes.
 04/16/91 : jhw : Added SK geometry types to EFget_the_edge_type_for_an_object.
 08/30/93 : SY  : Added EFget_bscv_type_for_an_edge_type to return BSgeom
                  curve type of an edge.
 11/02/93 : Rajiv Agrawal  : Added SKbspline class for a valid freeform type.
 */

#include <string.h>
#include "EMS.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "emsedgedef.h"
#include "EMSmsgdef.h"
#include "bsgeom_cvsf.h"

extern OMuword OPP_GR3dcirarc_class_id;
extern OMuword OPP_GR3dcircle_class_id;
extern OMuword OPP_GR3dellarc_class_id;
extern OMuword OPP_GR3dellipse_class_id;
extern OMuword OPP_GR3dinfline_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GR3dorthlnst_class_id;
extern OMuword OPP_GR3dorthpoly_class_id;
extern OMuword OPP_GR3dpllnstr_class_id;
extern OMuword OPP_GR3dpoint_class_id;
extern OMuword OPP_GR3dpolygon_class_id;
extern OMuword OPP_GRbcsubbc_class_id;
extern OMuword OPP_GRcompcurve_class_id;
extern OMuword OPP_GRlinear_class_id;

extern OMuword OPP_GA3dcirarc_class_id;
extern OMuword OPP_GA3dcircle_class_id;
extern OMuword OPP_GA3dellarc_class_id;
extern OMuword OPP_GA3dellipse_class_id;
extern OMuword OPP_GA3dinfline_class_id;
extern OMuword OPP_GA3dlineseg_class_id;
extern OMuword OPP_GA3dlinestr_class_id;
extern OMuword OPP_GA3dorthlnst_class_id;
extern OMuword OPP_GA3dorthpoly_class_id;
extern OMuword OPP_GA3dpllnstr_class_id;
extern OMuword OPP_GA3dpoint_class_id;
extern OMuword OPP_GA3dpolygon_class_id;
extern OMuword OPP_GAbcsubbc_class_id;
extern OMuword OPP_GAcompcurve_class_id;
extern OMuword OPP_GAlinear_class_id;

/* Associative parametric classes */

extern OMuword OPP_ASby2ptsg_class_id;
extern OMuword OPP_ASlinedbt_class_id;
extern OMuword OPP_ASlineorth_class_id;
extern OMuword OPP_ASlinepara_class_id;
extern OMuword OPP_ASlineangl_class_id;
extern OMuword OPP_AScircnt_class_id;
extern OMuword OPP_ASarccntrd_class_id;
extern OMuword OPP_AScompcurve_class_id;

/* Variational geometry classes */

extern OMuword OPP_SKarc_class_id;
extern OMuword OPP_SKline_class_id;
extern OMuword OPP_SKcircle_class_id;
extern OMuword OPP_SKpoint_class_id;
extern OMuword OPP_SKdumpt_class_id;
extern OMuword OPP_SKbspline_class_id;


IGRlong EFget_the_edge_type_for_an_object(
 objid, 
 osnum,
 classid,
 type)

OM_S_OBJID		objid;
OMuword			osnum;
OMuword			classid;
IGRuchar	*type;

{
 IGRlong	sts;

 sts = OM_S_SUCCESS;

/*
 * Get the input object's classid
 */
if (!classid)
{
 sts = om$get_classid(
   osnum = osnum,
   objid = objid,
   p_classid = &classid);
  if (! (1 & sts)) return(sts);
}

/*
 * Case on the class id
 */
 if ((classid == OPP_GR3dcirarc_class_id) ||
     (classid == OPP_SKarc_class_id) ||
     (classid == OPP_GA3dcirarc_class_id))
  *type = EMcircular_arc;
 else if ((classid == OPP_GR3dcircle_class_id)  || 
          (classid == OPP_SKcircle_class_id) ||
          (classid == OPP_GA3dcircle_class_id))
  *type = EMcircle;
 else if ((classid == OPP_GR3dellarc_class_id) ||
         (classid == OPP_GA3dellarc_class_id))
  *type = EMelliptical_arc;
 else if ((classid == OPP_GR3dellipse_class_id) ||
         (classid == OPP_GA3dellipse_class_id))
  *type = EMellipse;
 else if ((classid == OPP_GR3dinfline_class_id) ||
          (classid == OPP_GA3dinfline_class_id))
  *type = EMinfinite_line;
 else if ((classid == OPP_GR3dlineseg_class_id) ||
          (classid == OPP_SKline_class_id) ||
          (classid == OPP_GA3dlineseg_class_id))
  *type = EMlinesegment;
 else if ((classid == OPP_GR3dlinestr_class_id) ||
          (classid == OPP_GA3dlinestr_class_id))
  *type = EMlinestring;
 else if ((classid == OPP_GR3dorthlnst_class_id) ||
          (classid == OPP_GA3dorthlnst_class_id))
  *type = EMorthogonal_linestring;
 else if ((classid == OPP_GR3dorthpoly_class_id) ||
          (classid == OPP_GA3dorthpoly_class_id))
  *type = EMorthogonal_polygon;
 else if ((classid == OPP_GR3dpllnstr_class_id) ||
          (classid == OPP_GA3dpllnstr_class_id))
  *type = EMplanar_linestring;
 else if ((classid == OPP_GR3dpoint_class_id) ||
          (classid == OPP_SKpoint_class_id) ||
          (classid == OPP_GA3dpoint_class_id))
  *type = EMpoint;
 else if ((classid == OPP_GR3dpolygon_class_id) ||
          (classid == OPP_GA3dpolygon_class_id))
  *type = EMpolygon;
 else if ((classid == OPP_GRbcsubbc_class_id) ||
          (classid == OPP_GAbcsubbc_class_id) ||
          (classid == OPP_SKbspline_class_id))
  *type = EMfreeform_curve;
 else if ((classid == OPP_GRcompcurve_class_id) ||
          (classid == OPP_GAcompcurve_class_id))
  *type = EMcomposite_curve;
 else if (classid == OPP_SKdumpt_class_id)
  *type = SKprofile_vertex;
 else    
         if(    ( classid == OPP_ASlinedbt_class_id  ) ||
 	        ( classid == OPP_ASlineorth_class_id ) ||
 	        ( classid == OPP_ASlinepara_class_id ) ||
 	        ( classid == OPP_ASlineangl_class_id ) ||
 	        ( classid == OPP_ASby2ptsg_class_id  )) 
				*type = EMlinesegment;
	 else if( classid ==  OPP_AScircnt_class_id )
  				*type = EMcircle;
         else if( classid ==  OPP_ASarccntrd_class_id )
  				*type = EMcircular_arc;
	 else if( classid ==  OPP_AScompcurve_class_id )
  				*type = EMcomposite_curve;
         else 
		sts = OM_E_NOSUCHCLASS;
/*
 * eof
 */
 return(sts);
}


IGRlong EFget_clipped_edge_type (EMmsg,parent_edge_type, clipped_edge_type)

IGRlong *EMmsg;
IGRuchar parent_edge_type;
IGRuchar *clipped_edge_type;

/*
  The following function returns the edge type of the clipped edge given
  the edge type of the parent edge
  Upon exit the completion code will be one of the following:
   EMS_S_Success : if all goes well
   EMS_E_InvalidArg : if the parent edge type does not resemble any known
                      edge type

 */
{
 IGRlong status;
 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
  
 switch (parent_edge_type)
 {
  case EMcircular_arc:
  case EMcircle:
   *clipped_edge_type = EMcircular_arc;
  break;
 
  case EMelliptical_arc:
  case EMellipse:
   *clipped_edge_type = EMelliptical_arc;
  break;

  case EMlinesegment:
  case EMinfinite_line:
   *clipped_edge_type = EMlinesegment;
  break;

  case EMlinestring:
   *clipped_edge_type = EMlinestring;
  break;

  case EMorthogonal_linestring:
   *clipped_edge_type = EMorthogonal_linestring;
  break;

  case EMorthogonal_polygon:
   *clipped_edge_type = EMorthogonal_linestring;
  break;

  case EMplanar_linestring:
   *clipped_edge_type = EMplanar_linestring;
  break;

  case EMpoint:
   *clipped_edge_type = EMpoint;
  break;

  case EMpolygon:
   *clipped_edge_type = EMlinestring;
  break;

  case EMfreeform_curve:
   *clipped_edge_type = EMfreeform_curve;
  break;

  case EMcomposite_curve:
   *clipped_edge_type = EMcomposite_curve;
  break;

  case SKprofile_vertex:
   *clipped_edge_type = SKprofile_vertex;

  default:
   *clipped_edge_type = EMfreeform_curve;
  break;

 }


  return(status);
}
/*
  The following function returns the classid correspoding to a particular
  edge type. It is the reverse of the above function.
*/

IGRlong EFget_classid_for_an_edge_type( classid,type)

OMuword			*classid;
IGRuchar	type;

{
 IGRlong	sts;

 sts = OM_S_SUCCESS;


/*
 * Case on the edge type
 */

 if(type == EMcircular_arc)
   *classid = OPP_GR3dcirarc_class_id;

 else if( type == EMcircle)
   *classid = OPP_GR3dcircle_class_id;

 else if( type == EMelliptical_arc)
   *classid = OPP_GR3dellarc_class_id;

 else if( type == EMellipse)
   *classid = OPP_GR3dellipse_class_id;

 else if( type == EMinfinite_line)
   *classid = OPP_GR3dinfline_class_id;

 else if( type == EMlinesegment)
   *classid = OPP_GR3dlineseg_class_id;

 else if( type == EMlinestring)
   *classid = OPP_GR3dlinestr_class_id;

 else if( type == EMorthogonal_linestring)
   *classid = OPP_GR3dorthlnst_class_id;

 else if( type == EMorthogonal_polygon)
   *classid = OPP_GR3dorthpoly_class_id;

 else if( type == EMplanar_linestring)
   *classid = OPP_GR3dpllnstr_class_id;

 else if( type == EMpoint)
   *classid = OPP_GR3dpoint_class_id;

 else if(type == EMpolygon)
   *classid = OPP_GR3dpolygon_class_id;

 else if( type == EMfreeform_curve)
  *classid = OPP_GRbcsubbc_class_id;

 else if( type == EMcomposite_curve)
  *classid = OPP_GRcompcurve_class_id;

 else if( type == SKprofile_vertex)
  *classid = OPP_SKdumpt_class_id;

 else
  *classid = OPP_GRbcsubbc_class_id;

/*
 * eof
 */
 return(sts);
}

/*
  The following function returns the associative classid correspoding to a
  particular edge type.
*/

IGRlong EFget_assoc_classid_for_an_edge_type(classid, type)

OMuword			*classid;
IGRuchar	type;

{
 IGRlong	sts;

 sts = OM_S_SUCCESS;


/*
 * Case on the edge type
 */

 if(type == EMcircular_arc)
   *classid = OPP_GA3dcirarc_class_id;

 else if( type == EMcircle)
   *classid = OPP_GA3dcircle_class_id;

 else if( type == EMelliptical_arc)
   *classid = OPP_GA3dellarc_class_id;

 else if( type == EMellipse)
   *classid = OPP_GA3dellipse_class_id;

 else if( type == EMinfinite_line)
   *classid = OPP_GA3dinfline_class_id;

 else if( type == EMlinesegment)
   *classid = OPP_GA3dlineseg_class_id;

 else if( type == EMlinestring)
   *classid = OPP_GA3dlinestr_class_id;

 else if( type == EMorthogonal_linestring)
   *classid = OPP_GA3dorthlnst_class_id;

 else if( type == EMorthogonal_polygon)
   *classid = OPP_GA3dorthpoly_class_id;

 else if( type == EMplanar_linestring)
   *classid = OPP_GA3dpllnstr_class_id;

 else if( type == EMpoint || type == SKprofile_vertex)
   *classid = OPP_GA3dpoint_class_id;

 else if(type == EMpolygon)
   *classid = OPP_GA3dpolygon_class_id;

 else if( type == EMfreeform_curve)
  *classid = OPP_GAbcsubbc_class_id;

 else if( type == EMcomposite_curve)
  *classid = OPP_GAcompcurve_class_id;

 else
  *classid = OPP_GAbcsubbc_class_id;

/*
 * eof
 */
 return(sts);
}


/* Following function returns a string equivalent for an edge type. It
   is used in the debug messages for different kinds of edges.
*/

void EFget_string_for_edge_type(type, string)
IGRuchar type;
IGRchar *string;
{
  if(type == EMfreeform_curve)
   strcpy(string, "Free form curve");
  else if(type == EMcircular_arc)
   strcpy(string, "Circular Arc");
  else if(type == EMcircle)
   strcpy(string, "Circle");
  else if(type == EMelliptical_arc)
   strcpy(string, "Elliptical Arc");
  else if(type == EMellipse)
   strcpy(string, "Ellipse");
  else if(type == EMinfinite_line)
   strcpy(string, "Infinite Line");
  else if(type == EMlinesegment)
   strcpy(string, "Line Segment");
  else if(type == EMlinestring)
   strcpy(string, "Line String");
  else if(type == EMorthogonal_linestring)
   strcpy(string, "Orthogonal Linestring");
  else if(type == EMorthogonal_polygon)
   strcpy(string, "Orthogonal Polygon");
  else if(type == EMplanar_linestring)
   strcpy(string, "Planar Linestring");
  else if(type == EMpoint)
   strcpy(string, "Point");
  else if(type == EMpolygon)
   strcpy(string, "Polygon");
  else if(type == EMintersection_curve)
   strcpy(string, "Intersection Curve");
  else if(type == EMcomposite_curve)
   strcpy(string, "Composite Curve");
  else if(type == SKprofile_vertex)
   strcpy(string, "Profile vertex");
  else
   strcpy(string, "Unknown");
}

/* Following function returns the edge type from a string equivalent.
*/

#define STRING_MATCH 0

void EFget_edge_type_for_string(string, type)
IGRchar *string;
IGRuchar *type;
{
  IGRchar str[80+1], *token, *subtoken;

  strcpy (str, string);
  token = strtok (str, " ");
  subtoken = strtok (NULL, " ");

  if(strcmp (token, "Free") == STRING_MATCH)
   *type = EMfreeform_curve;
  else if (strcmp (token, "Circular") == STRING_MATCH)
   *type = EMcircular_arc;
  else if (strcmp (token, "Circle") == STRING_MATCH)
   *type = EMcircle;
  else if (strcmp (token, "Elliptical") == STRING_MATCH)
   *type = EMelliptical_arc;
  else if (strcmp (token, "Ellipse") == STRING_MATCH)
   *type = EMellipse;
  else if (strcmp (token, "Infinite") == STRING_MATCH)
   *type = EMinfinite_line;
  else if (strcmp (token, "Line") == STRING_MATCH &&
           strcmp (subtoken, "Segment") == STRING_MATCH)
   *type = EMlinesegment;
  else if (strcmp (token, "Line") == STRING_MATCH &&
           strcmp (subtoken, "String") == STRING_MATCH)
   *type = EMlinestring;
  else if (strcmp (token, "Orthogonal") == STRING_MATCH &&
           strcmp (subtoken, "Linestring") == STRING_MATCH)
   *type = EMorthogonal_linestring;
  else if (strcmp (token, "Orthogonal") == STRING_MATCH &&
           strcmp (subtoken, "Polygon") == STRING_MATCH)
   *type = EMorthogonal_polygon;
  else if (strcmp (token, "Planar") == STRING_MATCH)
   *type = EMplanar_linestring;
  else if (strcmp (token, "Point") == STRING_MATCH)
   *type = EMpoint;
  else if (strcmp (token, "Polygon") == STRING_MATCH)
   *type = EMpolygon;
  else if (strcmp (token, "Intersection") == STRING_MATCH)
   *type = EMintersection_curve;
  else if (strcmp (token, "Composite") == STRING_MATCH)
   *type = EMcomposite_curve;
  else if (strcmp (token, "Profile") == STRING_MATCH)
   *type = SKprofile_vertex;
  else
   *type = EMfreeform_curve;

  return;
}


/*
 * This function is valid only for linear curve elements (linestring, 
 * linesegment, etc). If the number of points in the element changed then
 * the edge-type may be wrong. Given the old edge-type and the number
 * of points currently in the element, the following function returns
 * the correct edge-type. If the edge-type given is not of a linear-element,
 * a FALSE value is returned and the edge-type is returned as the old one.
 * Else the value is TRUE.
 *
 * NOTE: An infinite line is treated as non-linear type.
 */

IGRboolean EFget_new_linear_edge_type (oldtype, num_points, newtype)
IGRuchar oldtype, *newtype;
IGRint num_points;
{
  IGRboolean stat_func;

  stat_func = TRUE;
  *newtype = oldtype;

  switch (oldtype)
    {
    case EMlinesegment:
      if (num_points > 2)
        *newtype = EMlinestring;
      else if (num_points == 1)
        *newtype = EMpoint;
      break;

    case EMlinestring:
    case EMorthogonal_linestring:
    case EMorthogonal_polygon:
    case EMplanar_linestring:
    case EMpolygon:
      if (num_points == 2)
        *newtype = EMlinesegment;
      else if (num_points == 1)
        *newtype = EMpoint;
      break;

    default:
      stat_func = FALSE;
    }
  return (stat_func);
}


IGRboolean EFisEdgeTypeLinear(edtype)
IGRuchar edtype;
{
 OMuword	clid;
 IGRlong	sts;

 sts = EFget_classid_for_an_edge_type(&clid, edtype);
 if( (sts = om$is_ancestry_valid(subclassid = clid, 
		superclassid = OPP_GRlinear_class_id)) == OM_S_SUCCESS)
  return(TRUE);
 else return(FALSE);
}

/*
  The following function returns the BSgeom_cv types correspoding to a
  particular edge type.
*/

IGRlong EFget_bscv_type_for_an_edge_type( bscv_type, type)

IGRshort	*bscv_type;
IGRuchar	type;

{
 IGRlong	sts;

 sts = OM_S_SUCCESS;


/*
 * Case on the edge type
 */

 if( type == EMcircular_arc)
   *bscv_type = BSCIRC_ARC;

 else if( type == EMcircle)
   *bscv_type = BSCIRCLE;

 else if( type == EMelliptical_arc)
   *bscv_type = BSELLIP_ARC;

 else if( type == EMellipse)
   *bscv_type = BSELLIPSE;

 else if( type == EMinfinite_line)
   *bscv_type = BSINF_LINE;

 else if( type == EMlinesegment ||
	  type == EMlinestring ||
	  type == EMorthogonal_linestring ||
	  type == EMorthogonal_polygon ||
	  type == EMplanar_linestring ||
	  type == EMpolygon)
   *bscv_type = BS3DLINESTR;

 else if( type == EMpoint)
   *bscv_type = BSPOINT;

 else
   *bscv_type = BSGEN_BSP_CV;

/*
 * eof
 */
 return(sts);
}
