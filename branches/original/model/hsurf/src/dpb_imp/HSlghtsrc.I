
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation HSlghtsrc;

#define CHECK_RETURN_CODES	0

#include <stdio.h>
#include <string.h>
#include <alloca.h>
%safe
#include <math.h>
%endsafe

#include "OMerrordef.h"

#include "bstypes.h"
#include "bsconic.h"
#include "bsvalues.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "msmacros.h"
#include "fontdef.h"
#include "font.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "gotext.h"
#include "grownerdef.h"

#include "hsurferrpriv.h"
#include "hsmsg.h"
#include "hsdef.h"
#include "hsmacros.h"

#include "cotxmacros.h"
#include "fontmacros.h"

#include "OMminimum.h"
#include "igr.h"
#include "gr.h"
#include "hslight.h"
#include "hsurf.h"

%safe
#include "HSpr_dpb_imp.h"
%endsafe

#include "ma.h"
#include "matypemx.h"
#include "masubvc.h"
#include "mascalvc.h"
#include "mapytobc.h"
#include "maptsxfor.h"
#include "malenvc.h"
#include "mainvmx.h"
#include "macrossvc.h"
#include "maaddvc.h"
#include "bsprepcirc.h"
#include "bslngen.h"
#include "bscveval.h"
#include "DPgetggid.h"
#include "GRretfnt.h"

#define MAX_WINDOWS	256
#define MAX_ELEMENTS	10
#define GET_LENGTH(a,b)	(sqrt(((b)[0]-(a)[0])*((b)[0]-(a)[0])+((b)[1]-(a)[1])*((b)[1]-(a)[1])+((b)[2]-(a)[2])*((b)[2]-(a)[2])))

#define ESCAPE		27
#define NEWLINE		10

extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dcircle_class_id;
extern OMuword OPP_GR3dpoint_class_id;
extern OMuword OPP_GR3dpolygon_class_id;

extern IGRboolean HSlight_graphics_displayed;

from GRlinear import GRputpolyline;

%safe
/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HSlghtsrc.I */

extern IGRint GRdpb_get __((IGRint *msg, IGRint parameter, 
		IGRint *sizbuf, IGRchar *buffer, IGRint *nret));

extern int  GRchange_properties(
        struct GRid     *object_id,
        short   action,
        short   property_mask);

static HSdimensionBankText __((
     struct HS_light_source *light,
          IGRdouble *dimension));

static int HSgetLightNumber __((GRobjid my_id));

static void HScreateLightSourceText __((IGRpoint OriginPoint, 
				 struct GRmd_env *master_env, 
					 GRobjid *object_id, 
					 GRobjid my_id, 
				  unsigned short flags, 
				       IGRdouble dimension, 
				       IGRdouble vector[3], 
				      IGRboolean Displayable, 
			      struct GRsymbology light_symb));
			      
static int HScreateCone __((IGRpoint location, 
			    IGRpoint target, 
			   IGRdouble angle, 
			   IGRdouble radius, 
		     struct GRmd_env *master_env, 
			     GRobjid *object_id, 
			  IGRboolean Displayable, 
		  struct GRsymbology light_symb));
		  
static int HScreateCylinder __((IGRpoint location, 
			        IGRpoint target, 
			       IGRdouble radius, 
			 struct GRmd_env *master_env, 
				 GRobjid *object_id, 
			      IGRboolean Displayable, 
		      struct GRsymbology light_symb));
		      
static int HScreatePoint __((IGRpoint location, 
		      struct GRmd_env *master_env, 
			      GRobjid *object_id, 
				 char weight, 
			   IGRboolean Displayable, 
		   struct GRsymbology light_symb));
		   
static int HScreateSphere __((IGRpoint location, 
			     IGRdouble radius, 
		       struct GRmd_env *master_env, 
			       GRobjid *object_id, 
			    IGRboolean Displayable, 
		    struct GRsymbology light_symb));
		    
static int HScreateVector __((IGRpoint location, 
			      IGRpoint target, 
		       struct GRmd_env *master_env, 
			       GRobjid *object_id, 
			    IGRboolean Displayable, 
		    struct GRsymbology light_symb));

#if defined(__cplusplus)
}
#endif


#undef __

%endsafe

/*--- HSgetLightNumber --------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HSgetLightNumber( GRobjid my_id )
#else	
	static int HSgetLightNumber( my_id )
	GRobjid my_id;
#endif

/*
NAME
	HSgetLightNumber (static)

KEYWORD
	light_source

DESCRIPTION
	This function returns the index association with the light. It's in the range
	one through eight.

PARAMETERS
	my_id (IN) - object id of light to be looked for.

GLOBALS USED
	none.

RETURN VALUES
	0 : Light not found
	1-8 : Corresponding light index.

HISTORY
	08/22/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
	07/27/93 BSprototypes Sudha

*/
{
	IGRlong sts;
	OM_S_OBJID dpb_id, light_id;
	OMuword dpb_os, light_os;
	IGRint i, LightNumber = 0;

	HSget_dpb_super( &dpb_id, &dpb_os );

	/* First, check to see if there's room for another light source */
	for( i = 0; i < MAX_LIGHTS; i++ )
	{
		sts = HSget_light_objid_and_os( i, dpb_id, dpb_os, &light_id, &light_os );
		if( light_id == my_id && light_os == OM_Gw_current_OS )
		{
			LightNumber = i + 1;
			break;
		}
	}
	return( LightNumber );

} /* HSgetLightNumber */

/*--- HScreateLightSourceText -----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void HScreateLightSourceText( IGRpoint OriginPoint,
				      struct GRmd_env *master_env,
					      GRobjid *object_id,
					      GRobjid my_id,
				       unsigned short flags,
					    IGRdouble dimension,
					    IGRdouble vector[3],
					   IGRboolean Displayable,
				   struct GRsymbology light_symb )
#else
	static void HScreateLightSourceText( OriginPoint, master_env, object_id, my_id, flags, dimension, vector, Displayable, light_symb )
	IGRpoint OriginPoint;
	struct GRmd_env *master_env;
	GRobjid *object_id, my_id;
	unsigned short flags;
	IGRdouble dimension;
	IGRdouble vector[3];
	IGRboolean Displayable;
        struct GRsymbology light_symb;
#endif

/*
NAME
	HScreateLightSourceText (static)

KEYWORD
	light_source

DESCRIPTION
	This function creates the text for all types of light sources. It places the text
	at world coordinate 'OriginPoint' and returns the object id(s) of the text in the
	array 'object_id'.

PARAMETERS
	OriginPoint (IN) - Global position of the light source.
	target (IN) - Along with location, defines the vector and height of the cylinder.
	angle (IN) - In degrees; creates cone of influence for spotlight. (0 < angle < 180)
	radius (IN) - Radius of 100% intensity of light, outside which, brightness dies off.
	master_env (IN) - Module environment.
	object_id (OUT) - Array of object ids of the objects created.
	Displayable (IN) - Whether the light source objects are currently displayed.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of the last message sent (om$construct).

NOTES
	For view-aligned lights, two text objects are created. The additional one is an
	arrowhead character, which is given an 'ActiveAngle' (two-d) rotation and rep-
	resents the vector (as best it can). It looks the same in every view.

HISTORY
	08/22/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
	06/05/92 Added use of message subsystem to place text to screen. -
                  Bob Druzynski
*/
{
	IGRlong	 		msg;
	IGRint			nbytes_in_buffer, nbytes_returned;
	IGRint 			sts, i, LightNumber, NumWindows;
	IGRchar 		TextString[100], LightString[100];
	IGRchar			SwitchString[100];
	struct GRdpb_text_symb  TextSymb;
	IGRmatrix 		RotMatrix;
	IGRdouble 		ActiveAngle = 0.0, theta;
	struct IGRdisplay 	ActiveDisplay;
	IGRshort 		TextLength;
	unsigned short 		Properties;
	struct GRid 		TextGRid, WindowGRids[MAX_WINDOWS];
	GRobjid 		WindowObjids[MAX_WINDOWS];
	unsigned char 		RegularFont[4];
	IGRshort 		FontPosition;
	IGRdouble 		direction[3];
	int 			offset_length;

	ActiveDisplay.color  = DPGRID_COLOR;
	ActiveDisplay.style  = 0; /* Text is always solid */
	ActiveDisplay.weight = light_symb.display_attr.weight;
	sprintf( (char *)RegularFont, "102" );

	LightNumber = HSgetLightNumber( my_id );

	Properties = GRIS_VIEW_INDEP | GRIS_SCALE_INDEP;
	if( Displayable ) Properties |= GRIS_DISPLAYABLE;

	for (i = 1; i < 15; ++i )
	{
		RotMatrix[i] = 0;
	}

	RotMatrix[0] = 1;
	RotMatrix[5] = 1;
	RotMatrix[10] = 1;
	RotMatrix[15] = 1;

	nbytes_in_buffer = sizeof( &TextSymb );

	sts = gr$get_text_symb(	msg = (IGRint *) &msg,
				sizbuf = &nbytes_in_buffer,
				buffer = (IGRchar *) &TextSymb,
				nret = &nbytes_returned );

	switch( flags & HS_LIGHT_TYPE )
	{
	case HS_LIGHT_PARALLEL:
		if( flags & HS_LIGHT_DATABASE )
		{
			ex$message( msgnumb = HS_I_DirectLightDB, buff = LightString );
			offset_length = strlen( LightString )/2;

			if( flags & HS_LIGHT_ENABLED )
			{
				ex$message( msgnumb = HS_I_On, buff = SwitchString );
			}
			else
			{
				ex$message( msgnumb = HS_I_Off, buff = SwitchString );
			}

			sprintf( TextString, "%*s#%d\n%s\n%*s%s",
				 offset_length, "", LightNumber,  LightString,
				 offset_length, "",  SwitchString );
			TextLength = (IGRshort)strlen(TextString);
		}
		else
		{
			ex$message( msgnumb = HS_I_DirectLightVw, buff = LightString );
			offset_length = strlen( LightString )/2;

			if( flags & HS_LIGHT_ENABLED )
			{
				ex$message( msgnumb = HS_I_On, buff = SwitchString );
			}
			else
			{
				ex$message( msgnumb = HS_I_Off, buff = SwitchString );
			}
			sprintf( TextString, "%*s#%d\n%s\n%*s%s",
				 offset_length, "", LightNumber,  LightString,
				 offset_length, "",  SwitchString );

			TextLength = (IGRshort)strlen(TextString);

			/* Whatever 'dimension' was passed in by the caller */
			TextSymb.Active_width =	 dimension;
			TextSymb.Active_height = dimension;

			sts = co$place_text( msg = (IGRlong *) &msg, text_string = TextString, text_length = &TextLength,
				origin = OriginPoint, rot_matrix = RotMatrix, ActiveDisplay = &ActiveDisplay,
				Properties = &Properties, ModuleInfo = master_env, TextSymb = &TextSymb,
				ActiveAngle = ActiveAngle, flags = 0, buffer = &TextGRid );

			object_id[1] = TextGRid.objid;

			direction[0] = vector[0];
			direction[1] = -vector[1];
			direction[2] = -vector[2];

			if( direction[1] < 0.0 )
			{
				if( direction[0] > 0.0 )
				{
					ActiveAngle = 0;
				}
				else
				{
					ActiveAngle = M_PI;
				}
			}
			else
			{
				if( direction[0] > 0.0 )
				{
					ActiveAngle = 2 * M_PI;
				}
				else
				{
					ActiveAngle = M_PI;
				}
			}
			if( direction[0] != 0.0 )
			{
				theta = atan( (direction[1] / direction[0]) ) /* * 180 / M_PI */ ;
				TextString[0] = 67;
			}
			else if( direction[1] != 0.0 )
			{
				if( direction[1] > 0.0 ) theta = M_PI / 2.0;
				else theta = - M_PI / 2.0;
				TextString[0] = 67;
			}
			else
			{
				TextString[0] = '.';
				theta = 0.0;
			}
#if DEBUG
			fprintf( stderr, "ActiveAngle = %lf\n", ActiveAngle );
			fprintf( stderr, "theta = %lf(atan( %lf/%lf)\n", theta, vector[1], vector[0] );
#endif
			ActiveAngle += theta;
#if DEBUG
			fprintf( stderr, "ActiveAngle = %lf\n", ActiveAngle );
#endif
/*			for( i = 0; i < 9; i++ )
				TextString[i] = 94 + i;
*/
			TextLength = 1;
		}
		break;
	case HS_LIGHT_POINT:
		ex$message( msgnumb = HS_I_PointLight, buff = LightString );
		offset_length = strlen( LightString )/2;
		if( flags & HS_LIGHT_ENABLED )
		{
			ex$message( msgnumb = HS_I_On, buff = SwitchString );
		}
		else
		{
			ex$message( msgnumb = HS_I_Off, buff = SwitchString );
		}

		sprintf( TextString, "%*s#%d\n%s\n%*s%s",
			 offset_length, "", LightNumber,  LightString,
			 offset_length, "",  SwitchString );
		TextLength = (IGRshort)strlen(TextString);
		break;
	case HS_LIGHT_PENCIL:
		ex$message( msgnumb = HS_I_PenLight, buff = LightString );
		offset_length = strlen( LightString )/2;

		if( flags & HS_LIGHT_ENABLED )
		{
			ex$message( msgnumb = HS_I_On, buff = SwitchString );
		}
		else
		{
			ex$message( msgnumb = HS_I_Off, buff = SwitchString );
		}

		sprintf( TextString, "%*s#%d\n%s\n%*s%s",
			 offset_length, "", LightNumber,  LightString,
			 offset_length, "",  SwitchString );
		TextLength = (IGRshort)strlen(TextString);
		break;
	case HS_LIGHT_SPOT:
		ex$message( msgnumb = HS_I_SpotLight, buff = LightString );
		offset_length = strlen( LightString )/2;

		if( flags & HS_LIGHT_ENABLED )
		{
			ex$message( msgnumb = HS_I_On, buff = SwitchString );
		}
		else
		{
			ex$message( msgnumb = HS_I_Off, buff = SwitchString );
		}

		sprintf( TextString, "%*s#%d\n%s\n%*s%s",
			 offset_length, "", LightNumber,  LightString,
			 offset_length, "", SwitchString );

		TextLength = (IGRshort)strlen(TextString);
		break;

	case HS_LIGHT_BANK:	/* [TW] added this "case" */
	        ex$message( msgnumb = HS_I_BankLight, buff = LightString );
		offset_length = strlen( LightString )/2;

		if( flags & HS_LIGHT_ENABLED )
		{
			ex$message( msgnumb = HS_I_On, buff = SwitchString );
		}
		else
		{
			ex$message( msgnumb = HS_I_Off, buff = SwitchString );
		}

		sprintf( TextString, "%*s#%d\n%s\n%*s%s",
			 offset_length, "", LightNumber,  LightString,
			 offset_length, "", SwitchString );

		TextLength = (IGRshort)strlen(TextString);
		break;
	}

/*	if( !(flags & HS_LIGHT_ENABLED) && (flags & HS_LIGHT_DATABASE) )
	{
		TextLength += 1; ## OFF has an extra letter ##
	}
*/
	dp$get_gragad_id( msg = (IGRlong *) &msg, name = "*", array_size = MAX_WINDOWS, numberofids = &NumWindows,
		found_GRids = WindowGRids );
	for( i = 0; i < NumWindows; i++ )
	{
		WindowObjids[i] = WindowGRids[i].objid;
	}
	/* Whatever 'dimension' was passed in by the caller */
	TextSymb.Active_width =	 dimension;
	TextSymb.Active_height = dimension;

#if DEBUG
	fprintf( stderr, "TextString = %s\tlength = %d\tpoint = %f,%f,%f\tcsw = %d,%d,%d\n",
	TextString, TextLength, OriginPoint[0],OriginPoint[1],OriginPoint[2],ActiveDisplay.color,
	ActiveDisplay.style,ActiveDisplay.weight );
#endif

	sts = font$retrieve( msg = &msg, font = RegularFont, local_font_name = RegularFont,
		font_position = &FontPosition );
	if( !(flags & HS_LIGHT_DATABASE) )
	{
		TextSymb.Active_font = FontPosition;
	}

	sts = co$place_text( msg = &msg, text_string = TextString, text_length = &TextLength,
		origin = OriginPoint, rot_matrix = RotMatrix, ActiveDisplay = &ActiveDisplay,
		Properties = &Properties, ModuleInfo = master_env, TextSymb = &TextSymb,
		ActiveAngle = ActiveAngle, flags = 0, buffer = &TextGRid );
	object_id[0] = TextGRid.objid;

#if DEBUG
	fprintf( stderr, "sts = %d\tmsg = %d\tobjid = %d\tosnum = %d\n",
		sts, msg, TextGRid.objid, TextGRid.osnum );
#endif

} /* HScreateLightSourceText */

/*--- HScreateCone -------------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HScreateCone( IGRpoint location,
				 IGRpoint target,
				IGRdouble angle,
				IGRdouble radius,
			  struct GRmd_env *master_env,
				  GRobjid *object_id,
			       IGRboolean Displayable,
		       struct GRsymbology light_symb )
#else
	static int HScreateCone( location, target, angle, radius, master_env, object_id, Displayable, light_symb )
	IGRpoint location, target;
	IGRdouble angle, radius;
	struct GRmd_env *master_env;
	GRobjid *object_id;
	IGRboolean Displayable;
	struct GRsymbology light_symb;
#endif

/*
NAME
	HScreateCone (static)

KEYWORD
	light_source

DESCRIPTION
	This functions creates a cone with 4 lines, and two circles. The four lines go
	from the origin (define by 'location') and proceed at the given 'angle' from the
	direction given by a vector from 'location' to 'target', to points on the perimeter
	of two circles. One of these circles has its center a distance 'radius' from 'location',
	the other has its center at 'target'. The four lines end at the circle farther from
	the origin.

PARAMETERS
	location (IN) - origin of the light source.
	target (IN) - Along with location, defines the vector and height of the cylinder.
	angle (IN) - In degrees; creates cone of influence for spotlight. (0 < angle < 180)
	radius (IN) - Radius of 100% intensity of light, outside which, brightness dies off.
	master_env (IN) - Module environment.
	object_id (OUT) - Array of object ids of the objects created.
	Displayable (IN) - Whether the light source objects are currently displayed.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of the last message sent (om$construct).

HISTORY
	08/22/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	IGRlong cons_msg;
/*	IGRint size = 2, bytes; */
	IGRint sts, type;
/*	IGRshort level; */
	struct GRvg_construct cons_args;
	struct IGRdisplay attributes;
	struct IGRbsp_curve curve, curve2, *OuterCurve, line_geom;
	BSrc rc;
	IGRvector normal, unit_plane_normal;
	IGRpoint NewTarget, point;
	IGRdouble circle_radius, tangent;
	IGRdouble x, y, z, distance, EvalPoint=0.0;
	IGRint i;

	/* fill in part of the construct structure */
	cons_args.msg        = &cons_msg;
	cons_args.newflag    = FALSE;
	cons_args.properties = GRIS_LOCATABLE;
	if( Displayable ) cons_args.properties |= GRIS_DISPLAYABLE;
	cons_args.class_attr = NULL;
	cons_args.name       = NULL;

	/* We already have the current module environment */
	cons_args.env_info   = master_env;

	attributes.color  = DPGRID_COLOR;
	attributes.style  = light_symb.display_attr.style;
	attributes.weight = light_symb.display_attr.weight;
	cons_args.display = &attributes;

/*
	gr$get_active_level( msg = &msg, sizbuf = &size, buffer = &level, nret = &bytes );
	cons_args.level = level;
*/
	cons_args.level = light_symb.level;

	curve.poles = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_POLES_MAX * sizeof( IGRdouble ) );
	curve.knots = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_KNOTS_MAX * sizeof( IGRdouble ) );
	curve.weights = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_POLES_MAX * sizeof( IGRdouble ) );

	x = normal[0] = target[0] - location[0];
	y = normal[1] = target[1] - location[1];
	z = normal[2] = target[2] - location[2];
	distance = sqrt( (x * x + y * y + z * z) );

	tangent = tan( angle );
	circle_radius = distance * tangent;

	memcpy( point, target, 3 * sizeof( IGRdouble ) );
	BSprepcirc( &rc, point, &circle_radius, normal, &curve, unit_plane_normal, &type );
	cons_args.geometry   = (IGRchar *)&curve;

	/* Construct an object for the Light source circle */
	sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
        	            osnum   = master_env->md_id.osnum,
       	        	    classid = OPP_GR3dcircle_class_id,
 	        	    p_objid = &(object_id[0]) );

	unit_plane_normal[0] = normal[0] / distance;
	unit_plane_normal[1] = normal[1] / distance;
	unit_plane_normal[2] = normal[2] / distance;

	point[0] = location[0] + unit_plane_normal[0] * radius;
	point[1] = location[1] + unit_plane_normal[1] * radius;
	point[2] = location[2] + unit_plane_normal[2] * radius;

	curve2.poles = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_POLES_MAX * sizeof( IGRdouble ) );
	curve2.knots = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_KNOTS_MAX * sizeof( IGRdouble ) );
	curve2.weights = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_POLES_MAX * sizeof( IGRdouble ) );

	circle_radius = radius * tangent;
	BSprepcirc( &rc, point, &circle_radius, normal, &curve2, unit_plane_normal, &type );
	cons_args.geometry   = (IGRchar *)&curve2;

	/* Construct an object for the Light source circle */
/* 	
	attributes.weight = 1; * Make radius circle a bit thicker *
*/
	attributes.weight = light_symb.display_attr.weight + 1;
	sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
        	            osnum   = master_env->md_id.osnum,
       	        	    classid = OPP_GR3dcircle_class_id,
 	        	    p_objid = &(object_id[1]) );

	line_geom.poles = (IGRdouble *)alloca( 6 * sizeof( IGRdouble ) );
	line_geom.knots = (IGRdouble *)alloca( 4 * sizeof( IGRdouble ) );
	if( distance > radius ) OuterCurve = &curve;
	else OuterCurve = &curve2;
/* 
	attributes.weight = 0;   Make other components regular weight 
*/
	attributes.weight = light_symb.display_attr.weight;
	for( i = 0; i < 4; i++ )
	{
		switch( i )
		{
		case 0:	EvalPoint = 0.0;	break;
		case 1:	EvalPoint = 0.25;	break;
		case 2:	EvalPoint = 0.5;	break;
		case 3:	EvalPoint = 0.75;	break;
		}
		BScveval( OuterCurve, EvalPoint, 0, (IGRpoint *)NewTarget, &rc );

		BSlngen( &rc, location, NewTarget, &line_geom, &type );

		cons_args.geometry   = (IGRchar *)&line_geom;

		/* Construct an object for the Light source vector */
		sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	        	            osnum   = master_env->md_id.osnum,
		                    classid = OPP_GR3dlineseg_class_id,
		 	            p_objid = &(object_id[i+2]) );
	}
	return( sts );

} /* HScreateCone */

/*--- HScreateCylinder ------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HScreateCylinder( IGRpoint location,
				     IGRpoint target,
				    IGRdouble radius,
			      struct GRmd_env *master_env,
				      GRobjid *object_id,
				   IGRboolean Displayable,
			   struct GRsymbology light_symb )
#else
	static int HScreateCylinder( location, target, radius, master_env, object_id, Displayable, light_symb )
	IGRpoint location, target;
	IGRdouble radius;
	struct GRmd_env *master_env;
	GRobjid *object_id;
	IGRboolean Displayable;
	struct GRsymbology light_symb;
#endif

/*
NAME
	HScreateCylinder (static)

KEYWORD
	light_source

DESCRIPTION
	This function creates a cylinder with 4 lines and 2 circles. It uses the two
	3d points 'location' and 'target' and the radius to determine the height and
	diameter of the cylinder. It constructs four GR3dlineseg object and two
	GR3dcircle objects.

PARAMETERS
	location (IN) - origin of the light source.
	target (IN) - Along with location, defines the vector and height of the cylinder.
	radius (IN) - Radius of the circles and the "sphere" which are created.
	master_env (IN) - Module environment.
	object_id (OUT) - Array of object ids of the objects created.
	Displayable (IN) - Whether the light source objects are currently displayed.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of the last message sent (om$construct).

HISTORY
	08/22/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	IGRlong cons_msg;
/*	IGRint size = 2, bytes; */
	IGRint sts, type;
/*	IGRshort level; */
	struct GRvg_construct cons_args;
	struct IGRdisplay attributes;
	struct IGRbsp_curve curve, line_geom;
	BSrc rc;
	IGRvector normal, unit_plane_normal;
	IGRdouble *point, EvalPoint=0.0;
	IGRpoint NewLocation, NewTarget;
	IGRint i;

	/* fill in part of the construct structure */
	cons_args.msg        = &cons_msg;
	cons_args.newflag    = FALSE;
	cons_args.properties = GRIS_LOCATABLE;
	if( Displayable ) cons_args.properties |= GRIS_DISPLAYABLE;
	cons_args.class_attr = NULL;
	cons_args.name       = NULL;

	/* We already have the current module environment */
	cons_args.env_info   = master_env;

	attributes.color  = DPGRID_COLOR;
/*
	attributes.style  = 0;
	attributes.weight = 0;
*/
	attributes.style  = light_symb.display_attr.style;
	attributes.weight = light_symb.display_attr.weight;
	cons_args.display = &attributes;

/*
	gr$get_active_level( msg = &msg, sizbuf = &size, buffer = &level, nret = &bytes );
	cons_args.level = level;
*/
	cons_args.level = light_symb.level;
	curve.poles = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_POLES_MAX * sizeof( IGRdouble ) );
	curve.knots = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_KNOTS_MAX * sizeof( IGRdouble ) );
	curve.weights = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_POLES_MAX * sizeof( IGRdouble ) );

	for( i = 0; i < 3; i++ )
	{
		normal[i] = target[i] - location[i];
	}

	point = location;
	for( i = 0; i < 2; i++ )
	{
		BSprepcirc( &rc, point, &radius, normal, &curve, unit_plane_normal, &type );
		cons_args.geometry   = (IGRchar *)&curve;

		/* Construct an object for the Light source vector */
		sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	        	            osnum   = master_env->md_id.osnum,
        	        	    classid = OPP_GR3dcircle_class_id,
	 	        	    p_objid = &(object_id[i]) );
		point = target;
	}

	line_geom.poles = (IGRdouble *)alloca( 6 * sizeof( IGRdouble ) );
	line_geom.knots = (IGRdouble *)alloca( 4 * sizeof( IGRdouble ) );
	for( i = 0; i < 4; i++ )
	{
		switch( i )
		{
		case 0:	EvalPoint = 0.0;	break;
		case 1:	EvalPoint = 0.25;	break;
		case 2:	EvalPoint = 0.5;	break;
		case 3:	EvalPoint = 0.75;	break;
		}
		BScveval( &curve, EvalPoint, 0, (IGRpoint *)NewTarget, &rc );
		NewLocation[0] = NewTarget[0] - normal[0];
		NewLocation[1] = NewTarget[1] - normal[1];
		NewLocation[2] = NewTarget[2] - normal[2];

		BSlngen( &rc, NewLocation, NewTarget, &line_geom, &type );

		cons_args.geometry   = (IGRchar *)&line_geom;

		/* Construct an object for the Light source vector */
		sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	        	            osnum   = master_env->md_id.osnum,
		                    classid = OPP_GR3dlineseg_class_id,
		 	            p_objid = &(object_id[i+2]) );
	}
	return( sts );

} /* HScreateCylinder */

/*--- HScreatePoint1 --------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HScreatePoint( IGRpoint location,
			   struct GRmd_env *master_env,
				   GRobjid *object_id,
				      char weight,
				IGRboolean Displayable,
			struct GRsymbology light_symb )
#else
	static int HScreatePoint( location, master_env, object_id, weight, Displayable,
			light_symb )
	IGRpoint location;
	struct GRmd_env *master_env;
	GRobjid *object_id;
	char weight;
	IGRboolean Displayable;
	struct GRsymbology light_symb;
#endif

/*
NAME
	HScreatePoint (static)

KEYWORD
	light_source

DESCRIPTION
	This function creates the point for the point light sources (object of type:
	GR3dpoint) from the 3d coordinate 'location'.

PARAMETERS
	location (IN) - origin of the point light.
	master_env (IN) - Module environment.
	object_id (OUT) - Array of object ids of the GR3dcircle objects created.
	weight (IN) - Weight of the point to be created.
	Displayable (IN) - Whether the light source objects are currently displayed.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of the last message sent (om$construct).

HISTORY
	08/22/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	IGRlong cons_msg;
/*	IGRint size = 2, bytes; */
	IGRint sts;
/*	IGRshort level; */
	struct GRvg_construct cons_args;
	struct IGRdisplay attributes;
	struct IGRbsp_curve point_geom;
	IGRdouble poles[6];
	IGRdouble knots[4];
#if SECOND_METHOD
	struct GRpost_info post_info;
	struct IGRpolyline polyline;
	GRobjid new_objid;
#endif

/*
	attributes.color = DPGRID_COLOR;
	attributes.style = 0;
	attributes.weight = 0;
*/

	knots[0] = knots[1] = 0.0;
	knots[2] = knots[3] = 1.0;

	/* fill in part of the construct structure */
	cons_args.msg        = &cons_msg;
	cons_args.newflag    = FALSE;
	cons_args.properties = GRIS_LOCATABLE;
	if( Displayable ) cons_args.properties |= GRIS_DISPLAYABLE;
	cons_args.class_attr = NULL;
	cons_args.name       = NULL;

	cons_args.env_info   = master_env;

	attributes.color  = DPGRID_COLOR;
	attributes.style = light_symb.display_attr.style;
	attributes.weight = light_symb.display_attr.weight;
	cons_args.display = &attributes;

/*
	gr$get_active_level( msg = &msg, sizbuf = &size, buffer = &level, nret = &bytes );
	cons_args.level = level;
*/
	cons_args.level = light_symb.level;

	poles[3] = poles[0] = location[0];
	poles[4] = poles[1] = location[1];
	poles[5] = poles[2] = location[2];
	point_geom.num_poles = 2;
	point_geom.order = 2;
	point_geom.num_knots = 4;
	point_geom.poles = poles;
	point_geom.knots = knots;
	point_geom.weights = NULL;
	cons_args.geometry   = (IGRchar *)&point_geom;

	/* Construct an object for the Light source vector */
	sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	                    osnum   = master_env->md_id.osnum,
        	            classid = OPP_GR3dpoint_class_id,
 	        	    p_objid = object_id );
	return( sts );

} /* HScreatePoint */

/*--- HScreateSphere1 -------------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HScreateSphere( IGRpoint location,
				  IGRdouble radius,
			    struct GRmd_env *master_env,
				    GRobjid *object_id,
				 IGRboolean Displayable,
			 struct GRsymbology light_symb )
#else
	static int HScreateSphere( location, radius, master_env, object_id, 
			Displayable, light_symb )
	IGRpoint location;
	IGRdouble radius;
	struct GRmd_env *master_env;
	GRobjid *object_id;
	IGRboolean Displayable;
	struct GRsymbology light_symb;
#endif

/*
NAME
	HScreateSphere (static)

KEYWORD
	light_source

DESCRIPTION
	This function creates three circles (objects of type: GR3dcircle) from the 3d point
	'location' and the radius. The circle will have normals corresponding to the coord-
	inate axes.

PARAMETERS
	location (IN) - origin of the point light (center of sphere).
	radius (IN) - Radius of the circles and the "sphere" which are created.
	master_env (IN) - Module environment.
	object_id (OUT) - Array of object ids of the GR3dcircle objects created.
	Displayable (IN) - Whether the light source objects are currently displayed.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of the last message sent (om$construct).

HISTORY
	08/22/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	IGRlong cons_msg;
/*	IGRint size = 2, bytes; */
	IGRint sts=OM_S_SUCCESS, type;
/*	IGRshort level; */
	struct GRvg_construct cons_args;
	struct IGRdisplay attributes;
	struct IGRbsp_curve curve;
	BSrc rc;
	IGRdouble normal[3], unit_plane_normal[3];
	IGRint i, j;

	/* fill in part of the construct structure */
	cons_args.msg        = &cons_msg;
	cons_args.newflag    = FALSE;
	cons_args.properties = GRIS_LOCATABLE /* | GRNOT_IN_RTREE */;
	if( Displayable ) cons_args.properties |= GRIS_DISPLAYABLE;
	cons_args.class_attr = NULL;
	cons_args.name       = NULL;

	/* We have the current module environment */
	cons_args.env_info   = master_env;

	attributes.color  = DPGRID_COLOR;
/*
	attributes.style  = 0;
	attributes.weight = 0;
*/
	attributes.style  = light_symb.display_attr.style;
	attributes.weight = light_symb.display_attr.weight;
	cons_args.display = &attributes;

/*
	gr$get_active_level( msg = &msg, sizbuf = &size, buffer = &level, nret = &bytes );
	cons_args.level = level;
*/
	cons_args.level = light_symb.level;

	curve.poles = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_POLES_MAX * sizeof( IGRdouble ) );
	curve.knots = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_KNOTS_MAX * sizeof( IGRdouble ) );
	curve.weights = (IGRdouble *)alloca( 3 * BSCIRCLE_NUM_POLES_MAX * sizeof( IGRdouble ) );

	for( i = 0; i < 3; i++ )
	{
		/* This will create three circles, each perpendicular to a different coordinate axis */
		for( j = 0; j < 3; j++ )
		{
			if( i == j ) normal[j] = 1.0;
			else normal[j] = 0.0;
		}
		BSprepcirc( &rc, location, &radius, normal, &curve, unit_plane_normal, &type );
		cons_args.geometry   = (IGRchar *)&curve;

		/* Construct an object for the Light source vector */
		sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
		                    osnum   = master_env->md_id.osnum,
	        	            classid = OPP_GR3dcircle_class_id,
	 	        	    p_objid = &(object_id[i]) );
	}
	return( sts );

} /* HScreateSphere */

/*--- HScreateVector1 ---------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static int HScreateVector( IGRpoint location,
				   IGRpoint target,
			    struct GRmd_env *master_env,
				    GRobjid *object_id,
				 IGRboolean Displayable,
			 struct GRsymbology light_symb )
#else
	static int HScreateVector( location, target, master_env, object_id, 
			Displayable, light_symb )
	IGRpoint location, target;
	struct GRmd_env *master_env;
	GRobjid *object_id;
	IGRboolean Displayable;
	struct GRsymbology light_symb;
#endif

/*
NAME
	 HScreateVector (static)

KEYWORD
	light_source

DESCRIPTION
	This function creates a GR3dlineseg object from the two 3d points world coordinate
	points 'location' and 'target'.

PARAMETERS
	location (IN) - origin of the directional light vector.
	target (IN) - Along with location, defines the vector and the end of the GR3dlineseg.
	master_env (OUT) - Module environment.
	object_id (OUT) - Object id of the GR3dlineseg created.
	Displayable (IN) - Whether the light source objects are currently displayed.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of the last message sent.

HISTORY
	08/16/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	IGRlong cons_msg;
	IGRint msg;
/*	IGRint size = 2; */
	IGRint bytes, bytes_req, sts, type;
/*	IGRshort level; */
	struct GRvg_construct cons_args;
	struct IGRdisplay attributes;
	struct IGRbsp_curve line_geom;
	BSrc rc;

	/* fill in part of the construct structure */
	cons_args.msg        = &cons_msg;
	cons_args.newflag    = FALSE;
	cons_args.class_attr = NULL;
	cons_args.name       = NULL;

	cons_args.properties = GRIS_LOCATABLE;
	if( Displayable ) cons_args.properties |= GRIS_DISPLAYABLE;

	/* get the current module environment */
	bytes_req = sizeof( struct GRmd_env );
	gr$get_module_env( msg    = &msg,
	                   sizbuf = &bytes_req,
	                   buffer = (IGRchar *) master_env,
	                   nret   = &bytes );
	cons_args.env_info = master_env;

	attributes.color  = DPGRID_COLOR;
/*
	attributes.style  = 0;
	attributes.weight = 0;
*/
	attributes.style  = light_symb.display_attr.style; 
	attributes.weight = light_symb.display_attr.weight;
	cons_args.display = &attributes;

	line_geom.poles = (IGRdouble *)alloca( 6 * sizeof( IGRdouble ) );
	line_geom.knots = (IGRdouble *)alloca( 4 * sizeof( IGRdouble ) );
	BSlngen( &rc, location, target, &line_geom, &type );

	cons_args.geometry   = (IGRchar *)&line_geom;

/*
	gr$get_active_level( msg = &msg, sizbuf = &size, buffer = &level, nret = &bytes );
	cons_args.level = level;
*/
	cons_args.level = light_symb.level;

	/* Construct an object for the Light source vector */
	sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	                    osnum   = master_env->md_id.osnum,
	                    classid = OPP_GR3dlineseg_class_id,
	 	            p_objid = object_id );

	return( sts );

} /* HScreateVector */

/*--- HScreateBank -- This routine is written by [TW] ---------------------------------*/

/*-- Create Bank light graphics objects--*/

static int HScreateBank( location, target, direction,  master_env, object_ids, num_ids,
	Displayable, light_symb )
	IGRpoint location;
	IGRpoint target;
	IGRpoint direction; 
	struct GRmd_env *master_env;
	GRobjid *object_ids;
        IGRint  *num_ids;
	IGRboolean Displayable;
	struct GRsymbology light_symb;
/*
NAME
	 HScreateBank (static)

KEYWORD
	light_source

DESCRIPTION
	This function creates a rectangular polygon object and four
	short line objects to represent the graphics of the bank light.

PARAMETERS
	location (IN) - center of the bank light's rectangle (half length).
	target (IN) - vector for one side of the rectangle (half length).
	direction (IN) - vector for the other side of the rectangle.
	                 (target[] X direction[]) is the direction of light shooting.

	master_env (OUT) - Module environment.
	object_ids (OUT) - Object ids of the objects created.
	Displayable (IN) - Whether the light source objects are currently displayed.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of the last message sent.

HISTORY
        12/14/92 Created. -Tiesheng Wang
*/
{
	IGRlong cons_msg;
	IGRint msg;
	IGRint bytes, bytes_req, sts, type;
	struct GRvg_construct cons_args;
	struct IGRdisplay attributes;
	BSrc rc;

	struct IGRbsp_curve poly_geom;
        IGRpoint rect_points[5];
	struct IGRpolyline polyline;

	/* The meaning of location[], target[], and direction[] */
	IGRdouble *half_length_vector = target;
	IGRdouble *center_pt = location; 
	IGRdouble *half_width_vector = direction;

	IGRint    i;
	IGRpoint  tmp_pt;
	IGRvector diag_vec, dir_vec;

	/* fill in part of the construct structure */
	cons_args.msg        = &cons_msg;
	cons_args.newflag    = FALSE;
	cons_args.class_attr = NULL;
	cons_args.name       = NULL;

	cons_args.properties = GRIS_LOCATABLE;
	if( Displayable ) cons_args.properties |= GRIS_DISPLAYABLE;

	/* get the current module environment */
	bytes_req = sizeof( struct GRmd_env );
	gr$get_module_env( msg    = &msg,
	                   sizbuf = &bytes_req,
	                   buffer = (IGRchar *) master_env,
	                   nret   = &bytes );
	cons_args.env_info = master_env;

	attributes.color  = DPGRID_COLOR;
	attributes.style  = light_symb.display_attr.style;
	attributes.weight = light_symb.display_attr.weight;

	cons_args.display = &attributes;

	/* Calculate the rectangle vertics. Note, the sequence of these points
 	 are important for a polygon */

	MAaddvc(&rc,half_length_vector,half_width_vector,diag_vec);
	MAsubvc(&rc,center_pt,diag_vec,rect_points[0]);
	MAaddvc(&rc,center_pt,diag_vec,rect_points[2]);

	MAsubvc(&rc,half_length_vector,half_width_vector,diag_vec);
	MAaddvc(&rc,center_pt,diag_vec,rect_points[1]);
	MAsubvc(&rc,center_pt,diag_vec,rect_points[3]);

	memcpy(rect_points[4],rect_points[0],sizeof(IGRpoint)); /* closed polygon */

	/* Create the polygon object */
 
	polyline.points = (IGRdouble *)rect_points;
	polyline.num_points = 5;

	poly_geom.poles = (IGRdouble *)alloca( 100 * sizeof( IGRdouble ) ); /* enough */
	poly_geom.knots = (IGRdouble *)alloca( 100 * sizeof( IGRdouble ) );

	MApytobc( &rc, &polyline, &poly_geom);

	cons_args.geometry   = (IGRchar *)&poly_geom;

	cons_args.level = light_symb.level;

	/* Construct an object for the Light source rectangle */
	sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	                    osnum   = master_env->md_id.osnum,
	                    classid = OPP_GR3dpolygon_class_id,
	 	            p_objid = &object_ids[0] );
	if(! (sts&1) ) goto wrapup;

	*num_ids = 1;

	/* Construct 4 small arrows at the 4 vertics of the rectangle
	   to show the direction of the light shooting */

	MAcrossvc(&rc, half_length_vector, half_width_vector, dir_vec);	/* light direction */
	
	/* Determine the small arrow vector length. Make it equal to
	   MIN(longer_side/10, shorter_side/4) of the rectangle */
	{
	    double d1,d2,arrow_length;
	    MAlenvc(&rc, half_width_vector, &d1);
	    MAlenvc(&rc, half_length_vector, &d2);
	    if(d1 > d2) {
		d1 /= 5.0;
		d2 /= 2.0;
	    }
	    else {
		d1 /= 2.0;
		d2 /= 5.0;
	    }
	    arrow_length = (d1<d2)?d1:d2;

	    /* adjust dir_vec[] length to be arrow_length */
	    MAlenvc(&rc, dir_vec, &d1);
	    d1 = (arrow_length/d1);
	    MAscalvc(&rc, &d1, dir_vec, dir_vec);
	}

	/* Create 4 arrows */
	for(i=0;i<4;i++)
	{
	    MAaddvc(&rc, rect_points[i], dir_vec, tmp_pt);
	    HScreateVector(rect_points[i],tmp_pt,master_env,
			   &(object_ids[i+1]), Displayable, light_symb );
	}
	*num_ids += 4;

wrapup:
	return(sts);

} /* HScreateBank [TW] */

/*---------[TW] -----------------------------------*/
/* Calculate the dimension of the BANK light text */

static HSdimensionBankText(light,dimension)
     struct HS_light_source *light;
     IGRdouble *dimension;
{
    IGRlong rc;
    IGRdouble d1,d2;

    /* let dimension depends on the longer of the two sides */
    MAlenvc(&rc,light->target,&d1);
    MAlenvc(&rc,light->direction,&d2);
    *dimension = (d1>d2)?d1:d2;
    *dimension /= 2.0;
    return(TRUE);
}  /* HSdimensionBankText() */

#define DEBUG	0

/*--- HSlghtsrc.HSget_light -------------------------------------------------------*/

method HSget_light( IGRint *msg; struct HS_light_source *light )

/*
NAME
	 HSlghtsrc.HSget_light

KEYWORD
	light_source

DESCRIPTION
	This message returns a copy of the light source structure for the
	given HSlghtsrc object.

PARAMETERS
	msg (OUT) - returns a status.
	light (IN) - Light Source data which is passed back.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of the HSlghtsrc.HScreate_light_source_graphics message.

HISTORY
	08/09/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	memcpy( light, &(me->LightSource), sizeof( struct HS_light_source ) );
#if DEBUG
	fprintf( stderr, "Within HSget_light\n" );
	fprintf( stderr, "id, os = %d, %d\n", my_id, OM_Gw_current_OS );
	fprintf( stderr, "flags = %d\trgb = %d, %d, %d\n",
		light->flags, light->red, light->green, light->blue );
#endif

	return( OM_S_SUCCESS );
} /* HSget_light */

/*--- HSlghtsrc.HSput_light -------------------------------------------------------*/

method HSput_light( IGRint *msg; struct HS_light_source *light; 
	struct GRsymbology light_symb )
/*
NAME
	 HSlghtsrc.HSput_light

KEYWORD
	light_source

DESCRIPTION
	This message gets sent immediately after an HSlghtsrc object is created. It
	sends the message to create the light source text and graphics, then copies
	the light source data into the instance data of the object.

PARAMETERS
	msg (OUT) - returns a status.
	light (IN) - Light Source data which is passed in.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of the HSlghtsrc.HScreate_light_source_graphics message.

HISTORY
	08/09/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	IGRint sts, msg;

	sts = om$send( msg = message HSlghtsrc.HScreate_light_source_graphics( 
		&msg, light, light_symb ),
		targetid = my_id, targetos = OM_Gw_current_OS, senderid = my_id );

	memcpy( &(me->LightSource), light, sizeof( struct HS_light_source ) );
#if DEBUG
	fprintf( stderr, "Within HSput_light\n" );
	fprintf( stderr, "id, os = %d, %d\n", my_id, OM_Gw_current_OS );
	fprintf( stderr, "flags = %d\trgb = %d, %d, %d\n",
		light->flags, light->red, light->green, light->blue );
#endif
	return( sts );

} /* HSput_light */

/*--- HSlghtsrc.HScreate_light_source_graphics -------------------------------------*/

method HScreate_light_source_graphics( IGRint *msg; struct HS_light_source 
	*light; struct GRsymbology light_symb )
/*
NAME
	HSlghtsrc.HScreate_light_source_graphics

KEYWORD
	light_source

DESCRIPTION
	This message gets sent from HSput_light right after an HSlghtsrc object is
	created. It calls the functions which create the graphics and text objects
	that are "owned" by the HSlghtsrc object.

PARAMETERS
	msg (OUT) - returns a status.
	light (IN) - Light Source data which is passed in.

GLOBALS USED
	none.

RETURN VALUES
	Returns status of last message sent.

FUNCTIONS CALLED
	HScreatePoint
	HScreateVector
	HScreateSphere
	HScreateCylinder
	HScreateCone
	HScreateBank  [TW]
	HScreateLightSourceText

HISTORY
	08/09/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	struct GRmd_env master_env;
	IGRint i, num_objects, bytes_req, bytes, sts;
	struct GRobj_env objects[MAX_ELEMENTS];
	GRobjid object_ids[MAX_ELEMENTS];
	IGRdouble dimension;
	IGRuint display_flags;
	IGRboolean Displayable;
	unsigned char save_weight;

	/* get the current module environment */
	bytes_req = sizeof( struct GRmd_env );
	gr$get_module_env( msg    = msg,
	                   sizbuf = &bytes_req,
	                   buffer = (IGRchar *) &master_env,
	                   nret   = &bytes );

	hs$get_shading_flags( shading_flags = &display_flags);
	if( display_flags & HS_SHADING_LIGHT_SOURCE_UNDISPLAY )
		Displayable = FALSE;
	else
		Displayable = TRUE;

	dimension = GET_LENGTH( light->location, light->target ) / 2.0;
	if( light->flags & HS_LIGHT_PARALLEL )
	{
		if( light->flags & HS_LIGHT_DATABASE )
		{
			save_weight = light_symb.display_attr.weight;
			light_symb.display_attr.weight = save_weight + 2;
			(void)HScreatePoint( light->location, &master_env,
				&(objects[1].obj_id.objid),
				2, Displayable, light_symb );
			light_symb.display_attr.weight = save_weight;

			(void)HScreateVector( light->location, light->target,
				&master_env,
				&(objects[0].obj_id.objid),
				Displayable, light_symb );
			num_objects = 2;
		}
		else
		{
			save_weight = light_symb.display_attr.weight;
			light_symb.display_attr.weight = 5;
			(void)HScreatePoint( light->location, &master_env,
				&(objects[2].obj_id.objid),
				5, Displayable, light_symb );
			light_symb.display_attr.weight = save_weight;
			num_objects = 1;
		}
	}
	else if( light->flags & HS_LIGHT_POINT )
	{
		HScreateSphere( light->location, light->radius, &master_env,
				object_ids, Displayable, light_symb );

		for( i = 0; i < 3; i++ )
			objects[i].obj_id.objid = object_ids[i];

		save_weight = light_symb.display_attr.weight;
		light_symb.display_attr.weight = 3;
		HScreatePoint( light->location, &master_env, object_ids, 2,
				Displayable, light_symb );
		objects[3].obj_id.objid = object_ids[0];
		light_symb.display_attr.weight = save_weight;

		num_objects = 4;
		dimension = light->radius;
	}
	else if( light->flags & HS_LIGHT_PENCIL )
	{
		HScreatePoint( light->location, &master_env, object_ids, 3, 
			Displayable, light_symb );
		objects[6].obj_id.objid = object_ids[0];

		(void)HScreateCylinder( light->location, light->target, light->radius,
			&master_env, object_ids, Displayable, light_symb );
		num_objects = 7;
		for( i = 0; i < num_objects-1; i++ )
			objects[i].obj_id.objid = object_ids[i];
	}
	else if( light->flags & HS_LIGHT_SPOT )
	{
		HScreateCone( light->location, light->target, light->angle, light->radius,
			&master_env, object_ids, Displayable, light_symb );
		num_objects = 6;
		for( i = 0; i < num_objects; i++ )
			objects[i].obj_id.objid = object_ids[i];
	}
	else if( light->flags & HS_LIGHT_BANK )  /* [TW]: this else if{} */
	{
	    HScreateBank(light->location, light->target, light->direction,
			 &master_env, object_ids, &num_objects, Displayable, light_symb );

	    for( i=0; i<num_objects; i++ )
	      objects[i].obj_id.objid = object_ids[i];

	    /* dimension for Bank light */
	    HSdimensionBankText(light,&dimension);
	}
	else
	{
	    ex$message( msgnumb = HS_E_BadLightFlag );
	}

	if( light->flags & HS_LIGHT_DATABASE )
	{
		HScreateLightSourceText( light->location, &master_env,
			&(objects[num_objects++].obj_id.objid),
			my_id, light->flags, dimension/5.0, light->direction,
			Displayable, light_symb );
	}
	else
	{
		HScreateLightSourceText( light->location, &master_env,
			object_ids, my_id, light->flags, dimension/5.0,
			light->direction, Displayable, light_symb );
		objects[0].obj_id.objid = object_ids[0];
		objects[1].obj_id.objid = object_ids[1];
		num_objects = 3;
	}

	for( i = 0; i < num_objects; i++ )
	{
		/* All elements will have the same module environment and osnum */
		memcpy( &(objects[i].mod_env), &master_env, sizeof( struct GRmd_env ) );
		objects[i].obj_id.osnum = master_env.md_id.osnum;
	}
	sts = om$send( msg = message GRowner.GRadd_components( (IGRlong *)msg,
		&master_env, &num_objects, objects, NULL, NULL),
		targetid = my_id, targetos = OM_Gw_current_OS, senderid = my_id );
	OM_ERRCHK( sts, "store_light_sources:  GRowner.GRadd_components send failed" );

	return( sts );

} /* HScreate_light_source_graphics */

/*--- HSlghtsrc.GRgetobjinfo -----------------------------------------------------*/

method GRgetobjinfo( IGRlong *msg; struct GRobj_info *info )

/*
NAME
	HSlghtsrc.GRgetobjinfo

KEYWORD
	light_source

DESCRIPTION
	This method is an override of the class GRclhdr. The message gets sent soon
	after the object is created. It sends back the part of the eventual light
	source text which includes the light number and type.

PARAMETERS
	msg (OUT) - returns a status (always OM_S_SUCCESS).
	info (OUT) - returns 'Light Source <light_number> (<light_type>)'

GLOBALS USED
	none.

RETURN VALUES
	Always returns OM_S_SUCCESS.

NOTES
	For more info about parameters, see GRclhdr.GRgetobjinfo method.

HISTORY
	08/09/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	IGRint LightNumber;
	IGRchar Type[20];

	LightNumber = HSgetLightNumber( my_id );

	switch( me->LightSource.flags & HS_LIGHT_TYPE )
	{
	case HS_LIGHT_PARALLEL:	sprintf( Type, "Directional light" );	break;
	case HS_LIGHT_POINT:	sprintf( Type, "Point Light" );		break;
	case HS_LIGHT_PENCIL:	sprintf( Type, "Pen Light" );		break;
	case HS_LIGHT_SPOT:	sprintf( Type, "Spotlight" );		break;
	case HS_LIGHT_BANK:     sprintf(Type,"Bank Light");             break;  /* [TW] */
	}
	sprintf( info->type, "Light Source %d (%s)", LightNumber, Type );

	*msg = OM_S_SUCCESS;
	return( *msg );

} /* GRgetobjinfo */

static IGRboolean CanCopy;

/*--- HSlghtsrc.GRcptform ------------------------------------------------------------*/

method GRcptform(IGRlong *msg; struct GRmd_env *mod_env;
                 IGRmatrix matrix; struct GRmd_env *target_env;
                 GRobjid *newobjid)

/*
NAME
	HSlghtsrc.GRcptform

KEYWORD
	light_source

DESCRIPTION
	This method is an override of the class GRclhdr. The message gets sent when
	the HSlghtsrc object is being copied and transformed (which means an actual
	copy rather than a copy for dynamics is being done). Thus, an erase of the
	display of the original is done if CanCopy is FALSE.

PARAMETERS
	msg (OUT) - returns a status.
	mod_env (IN) - Module environment.
	matrix (IN) - Matrix by which to transform the copied object relative to the old position.
	target_env (IN) - Environment to which Light Source will be copied.
	new_objid (OUT) - ID of new object. (Passed back from GRclhdr.GRcopy)

GLOBALS USED
	CanCopy (static) - Is there room for another light source (A total of 8 may be created).

RETURN VALUES
	Returns status of last message sent.

NOTES
	For more info about parameters, see GRclhdr.GRcptform method.

HISTORY
	08/09/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
   IGRlong  om_msg;
   IGRshort matrix_type;
   GRobjid  move_id;
   struct GRid old_lite;
   IGRdouble *array_of_matrices;

   om_msg = om$send (
            msg = message GRgraphics.GRcopy (msg, mod_env, target_env,
            newobjid), targetid = my_id);

   if( CanCopy ) move_id = *newobjid;
   else
   {
      old_lite.objid = move_id = my_id;
      old_lite.osnum = mod_env->md_id.osnum;

      /*
       *  Erase the object from its original position.
       *  The object must be cleared from display.
       *  It is the responsiblity of any calling
       *  command to redisplay the new object.
       */

      array_of_matrices = mod_env->md_env.matrix;
      om_msg = dp$display (msg = msg,
               osnum = mod_env->md_id.osnum,
               objid = mod_env->md_id.objid,
               mode = GRbehe,
               oids = &old_lite,
               mtx_type = &mod_env->md_env.matrix_type,
               matrix = &array_of_matrices);
   }

   MAtypemx (msg, matrix, &matrix_type);

   om_msg = om$send (
            msg = message GRgraphics.GRxform (msg, target_env,
            &matrix_type, matrix, newobjid),
            targetos = target_env->md_id.osnum,
            targetid = move_id );

   return (om_msg);
}

/*--- HSlghtsrc.GRcopy ------------------------------------------------------------*/

method GRcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
       struct GRmd_env *new_dsenv; GRobjid *newobjid)

/*
NAME
	HSlghtsrc.GRcopy

KEYWORD
	light_source

DESCRIPTION
	This method is an override of the class GRclhdr. The message gets sent when
	the HSlghtsrc object is being copied. This happens within move when dynamics
	is turned on. If there's room for another light source, the method sends this
	message to the parent class which sends GRcopy messages to the graphics (and
	text) objects "owned" by the object. If the new object is not just a temporary
	one created for dynamics, the text component is then removed and recreated with
	the correct light source number in the text string and the object is connected
	to the dpb.

PARAMETERS
	msg (OUT) - returns a status.
	obj_dsenv (IN) - Object environment.
	new_dsenv (IN/OUT) - Environment of new object.
	new_objid (OUT) - ID of new object. (Passed back from GRclhdr.GRcopy)

GLOBALS USED
	CanCopy (static) - Is there room for another light source (A total of 8 may be created).

RETURN VALUES
	Returns status of last message sent.

NOTES
	For more info about parameters, see GRclhdr.GRcopy method.

HISTORY
	08/09/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	IGRlong sts = OM_S_SUCCESS;
	IGRint i, OpenSlot = -1, bytes_req, bytes;
	OM_S_OBJID dpb_id, light_id;
	OMuword dpb_os, light_os;
	OM_S_CHANSELECT to_lights, to_dpb;
	struct GRmd_env master_env;
	struct GRobj_env object_env[MAX_ELEMENTS];
	struct GRid objects[MAX_ELEMENTS];
	GRobjid object_ids[2];
	IGRint num_objects, num_remove_objects = 1;
	IGRdouble dimension;
	IGRuint display_flags;
	IGRboolean Displayable;
	struct GRsymbology light_symb;

	hs$get_shading_flags( shading_flags = &display_flags);
	if( display_flags & HS_SHADING_LIGHT_SOURCE_UNDISPLAY )
		Displayable = FALSE;
	else
		Displayable = TRUE;

	HSget_dpb_super( &dpb_id, &dpb_os );

	/* First, check to see if there's room for another light source */
	for( i = 0; i < MAX_LIGHTS; i++ )
	{
		sts = HSget_light_objid_and_os( i, dpb_id, dpb_os, &light_id, &light_os );
		if( sts != OM_S_SUCCESS )
		{
			OpenSlot = i;
			break;
		}
	}
	if( OpenSlot != -1 ) CanCopy = TRUE;
	else CanCopy = FALSE;

	if( CanCopy || new_dsenv->md_id.objid == NULL_OBJID /* We're in dynamics */ )
	{
		/* get the current module environment */
		bytes_req = sizeof( struct GRmd_env );
		gr$get_module_env( msg    = (IGRint *) msg,
		                   sizbuf = &bytes_req,
        		           buffer = (IGRchar *) &master_env,
                		   nret   = &bytes );

		/* Send the copy message to the parent */
		sts = om$send(mode = OM_e_wrt_message,
			msg = message GRowner.GRcopy( msg, &master_env, new_dsenv, newobjid ),
			targetid = my_id, targetos = master_env.md_id.osnum );
		OM_ERRCHK( sts, "read_light_sources:  GRowner.GRcopy send failed" );
	}
	else
	{
		/* Tell user that 8 light sources exist already */
		ex$message( msgnumb = HS_W_MvdNotCopied );
	}

	if( CanCopy && new_dsenv->md_id.objid != NULL_OBJID )
	{
		sts = om$send( msg = message GRowner.GRget_number_components( msg, &num_objects ),
			targetid = *newobjid, targetos = master_env.md_id.osnum, senderid = NULL_OBJID );

		sts = om$send( msg = message GRowner.GRget_components( msg, &master_env,
			objects, MAX_ELEMENTS, &num_objects, 0, (num_objects-1) ),
			targetid = *newobjid, targetos = master_env.md_id.osnum, senderid = NULL_OBJID );
		OM_ERRCHK( sts, "read_light_sources:  GRowner.GRget_components send failed" );

		for( i = 0; i < num_objects; i++ )
		{
			memcpy( &(object_env[i].mod_env), &master_env, sizeof( struct GRmd_env ) );
			object_env[i].obj_id.osnum = objects[i].osnum;
			object_env[i].obj_id.objid = objects[i].objid;
		}

		sts = om$send( msg = message GRowner.GRremove_components( msg, &master_env,
			&num_remove_objects, &(object_env[num_objects-1]) ),
			targetid = *newobjid, targetos = master_env.md_id.osnum, senderid = NULL_OBJID );
		OM_ERRCHK( sts, "read_light_sources:  GRowner.GRremove_components send failed" );
		num_objects -= 1;

		/* Get rid of text copied from original, and re-create it (to correct light number) */
		sts = om$send( msg = message GRgraphics.GRdelete( msg, &master_env ),
			targetid = object_env[num_objects].obj_id.objid,
			targetos = object_env[num_objects].obj_id.osnum, senderid = NULL_OBJID );
		OM_ERRCHK( sts, "store_light_sources:  GRgraphics.GRdelete send failed" );

		/********************************************************/
		/* Connect Light source to the next open channel of dpb */
		/********************************************************/
		/* Get the channel objects of the HSdpb2 object */
		sts = om$make_chanselect( channame = "HSdpb2.to_light_sources", p_chanselect = &to_lights );
		OM_ERRCHK( sts, "store_light_sources: om$make_chanselect failed" );

		sts = om$make_chanselect( channame = "HSlghtsrc.to_dpb", p_chanselect = &to_dpb );

		OM_ERRCHK( sts, "read_light_source: om$make_chanselect for HSdpb2 failed" );

		sts = om$send( msg      = message Root.connect( to_dpb, OpenSlot /* Channel slot */,
			dpb_id, dpb_os, to_lights, NULL ),
			senderid = NULL_OBJID, targetid = *newobjid, targetos = dpb_os );
		OM_ERRCHK( sts, "read_light_source:  Root.connect failed" );

		if( me->LightSource.flags & HS_LIGHT_POINT )
		{
			dimension = me->LightSource.radius;
		}
		else if (me->LightSource.flags & HS_LIGHT_BANK ) /* [TW] */
		{
		    /* dimension for Bank light */
		    HSdimensionBankText(&(me->LightSource),&dimension); 
		}
		else
		{
			dimension = GET_LENGTH( me->LightSource.location, 
				me->LightSource.target ) / 2.0;
		}

                sts = om$send( targetid = *newobjid, 
				targetos = master_env.md_id.osnum, 
                                senderid = NULL_OBJID,
                                msg = message GRvg.GRgetsymb(msg,&light_symb));

		if( me->LightSource.flags & HS_LIGHT_DATABASE )
		{
			HScreateLightSourceText( me->LightSource.location, 
				&master_env, 
				&(object_env[num_objects].obj_id.objid),
				*newobjid, me->LightSource.flags,
				dimension/5.0, me->LightSource.direction, 
				Displayable, light_symb );
		}
		else
		{
			HScreateLightSourceText( me->LightSource.location, 
				&master_env, object_ids, *newobjid, 
				me->LightSource.flags, dimension/20.0, 
				me->LightSource.direction, Displayable, 
				light_symb );
/*			object_env[num_objects-1].obj_id.objid = object_ids[0];
*/
			object_env[num_objects].obj_id.objid = object_ids[1];
		}

		sts = om$send( msg = message GRowner.GRadd_components( msg, &master_env,
			&num_objects, &(object_env[num_objects]), &num_objects, NULL ),
			targetid = *newobjid, targetos = master_env.md_id.osnum, senderid = NULL_OBJID );
		OM_ERRCHK( sts, "store_light_sources:  GRowner.GRadd_components send failed" );

		/* Tell user: "Placing Light Source # (whatever)" */
	}
	return( sts );

} /* GRcopy */

/*--- HSlghtsrc.GRxform_owner ------------------------------------------------------*/

method GRxform_owner(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *matrix_type; IGRmatrix matrix;
	OM_S_OBJID *newobjid; IGRint *cont)

/*
NAME
	HSlghtsrc.GRxform_owner

KEYWORD
	light_source

DESCRIPTION
	This method is an override of the class GRclhdr. The message gets sent when
	the HSlghtsrc object is being moved, rotate, copied, etc. It sends the same
	message to the parent class (except for attempted rotations of view-aligned
	directional lights) which sends GRxform messages to the graphics (and text)
	objects "owned" by the object. It then gets the light source text object if
	a rotation is done, and does an inverse rotation so that it's still aligned
	to the view.

PARAMETERS
	msg (OUT) - returns a status.
	md_env (IN) - Module environment. (Don't think it's changed. (??) )
	matrix_type (IN) - Self explanatory.
	matrix (IN) - The transformation to be done to the object.
	newobjid (IN/OUT) - Passed back when a new object is created.
	cont (IN) - Continue flag.

GLOBALS USED
	none.

RETURN VALUES
	Always returns OM_S_SUCCESS.

NOTES
	For more info about parameters, see GRclhdr.GRxform_owner.

HISTORY
	08/09/91 Created. -Trevor Mink
	01/17/92 Documented and corrected rotation of view-aligned text. -Trevor Mink
*/
{
	IGRlong sts = OM_S_SUCCESS, msg1, num_points = 2;
	IGRdouble points[12];	/* [TW] need 4 tmp points */

	IGRint num_objects;
	struct GRid objects[MAX_ELEMENTS];
	IGRint bytes_req, bytes;
	struct GRmd_env master_env;
	IGRmatrix inv_matrix;
	IGRshort mxsize = 4;
	IGRboolean IsRotation;

	/* If there is a rotation, text needs rotating back to view-aligned orientation */
	IsRotation = !(	matrix[0] == 1.0 && matrix[1] == 0.0 && matrix[2] == 0.0 &&
			matrix[4] == 0.0 && matrix[5] == 1.0 && matrix[6] == 0.0 &&
			matrix[8] == 0.0 && matrix[9] == 0.0 && matrix[10] == 1.0 );

	/* Do transformation for Database light or if no rotation is involved (move or copy) */
	if( (me->LightSource.flags & HS_LIGHT_DATABASE) || !IsRotation )
	{
		/* Send the xform_owner message to this object using the parent class' method */
		sts = om$send(mode = OM_e_wrt_message,
			msg = message GRclhdr.GRxform_owner( msg, md_env, matrix_type, matrix,
				newobjid, cont ),
			targetid = my_id, targetos = OM_Gw_current_OS );
	}
	else
	{
		ex$message( msgnumb = HS_W_CantRotViewLight );
	}

	if( IsRotation )
	{
		MAinvmx( &msg1, &mxsize, matrix, inv_matrix );

		/*
			Get the text component of the light source object and, if there was
		a rotation, transform the GR3dtext object back to its original spot. (If there
		was no rotation, it must have been a move, so don't move it back). This is done
		bacause the GRclhdr.GRxform_owner message will result in a GRxform message sent
		to the GR3dtext object and will change the abstract geometry (or the "local
		bounded system") of the text.
		*/

		/* get the current module environment */
		bytes_req = sizeof( struct GRmd_env );
		gr$get_module_env( msg    = (IGRint *) msg,
				   sizbuf = &bytes_req,
				   buffer = (IGRchar *) &master_env,
				   nret   = &bytes );

		/* Get the number of components */
		sts = om$send( msg = message GRowner.GRget_number_components( msg, &num_objects ),
			targetid = my_id, targetos = master_env.md_id.osnum, senderid = NULL_OBJID );

		/* Get the object id of the last component. (That's the text) */
		sts = om$send( msg = message GRowner.GRget_components( msg, &master_env,
			objects, MAX_ELEMENTS, &num_objects, 0, (num_objects-1) ),
			targetid = my_id, targetos = master_env.md_id.osnum, senderid = NULL_OBJID );
		OM_ERRCHK( sts, "read_light_sources:  GRowner.GRget_components send failed" );

		/* Got the text object(s) to "un"rotate */

		if( !( me->LightSource.flags & HS_LIGHT_DATABASE ) )
		{
			/* This is the point associated with the light source */
			/* Translate AND rotate the view-aligned light source back */
			sts = om$send( msg = message GRvg.GRxform( msg, md_env, matrix_type, inv_matrix,
					&(objects[num_objects-2].objid) ),
				targetid = objects[num_objects-2].objid,
				targetos = objects[num_objects-2].osnum, senderid = my_id );

			sts = om$send( msg = message GRvg.GRxform( msg, md_env, matrix_type, inv_matrix,
					&(objects[num_objects-3].objid) ),
				targetid = objects[num_objects-3].objid,
				targetos = objects[num_objects-3].osnum, senderid = my_id );
		}
		else
		{
			/* Don't translate back, but do rotate back! */
/*			inv_matrix[3] = inv_matrix[7] = inv_matrix[11] = 0.0;
*/
		}

		sts = om$send( msg = message GRvg.GRxform( msg, md_env, matrix_type, inv_matrix,
				&(objects[num_objects-1].objid) ),
			targetid = objects[num_objects-1].objid,
			targetos = objects[num_objects-1].osnum, senderid = my_id );
	}

	if( me->LightSource.flags & HS_LIGHT_DATABASE )
	{
	    if(me->LightSource.flags & HS_LIGHT_BANK)  /* [TW] */
	    {
		/* For bank light, "target" and "direction" represents length and width
		   vectors. So we need to make them vectors after transformation */

		memcpy( points, me->LightSource.location, 3 * sizeof( IGRdouble ) );
		memcpy( &(points[3]), me->LightSource.target, 3 * sizeof( IGRdouble ) );
		memcpy( &(points[6]), me->LightSource.direction, 3 * sizeof( IGRdouble ) );

		points[9] = 0.0; points[10] = 0.0; points[11] = 0.0;
		num_points = 4;
		MAptsxform( &msg1, &num_points, matrix, points, points );

		me->LightSource.location[0] = points[0];
		me->LightSource.location[1] = points[1];
		me->LightSource.location[2] = points[2];

		MAsubvc(&msg1, &points[3], &points[9], me->LightSource.target);
		MAsubvc(&msg1, &points[6], &points[9], me->LightSource.direction);
	    }
	    else
	    {
		memcpy( points, me->LightSource.location, 3 * sizeof( IGRdouble ) );
		memcpy( &(points[3]), me->LightSource.target, 3 * sizeof( IGRdouble ) );

		num_points = 2;
		MAptsxform( &msg1, &num_points, matrix, points, points );

		me->LightSource.location[0] = points[0];
		me->LightSource.location[1] = points[1];
		me->LightSource.location[2] = points[2];

		me->LightSource.target[0] = points[3];
		me->LightSource.target[1] = points[4];
		me->LightSource.target[2] = points[5];

		me->LightSource.direction[0] = me->LightSource.target[0] - me->LightSource.location[0];
		me->LightSource.direction[1] = me->LightSource.target[1] - me->LightSource.location[1];
		me->LightSource.direction[2] = me->LightSource.target[2] - me->LightSource.location[2];
	    }
	}
	return( sts );

} /* GRxform_owner */

/*--- HSlghtsrc.GRget_locate_properties -------------------------------------------- */

method GRget_locate_properties (IGRlong *msg; IGRint *properties)

/*
NAME
	HSlghtsrc.GRget_locate_properties

KEYWORD
	light_source

DESCRIPTION
	This is an override of the class GRclhdr which determines the characteristics
	of the locate filter upon this object.

PARAMETERS
	msg (OUT) - returns a status.
	properties (OUT) - Has the appropriate bits set.

GLOBALS USED
	none.

RETURN VALUES
	Returns the status of the last message that it sent.

HISTORY
	08/09/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
    *msg = MSSUCC;
    *properties = GR_LC_OWN_READ        |
                  GR_LC_OWN_WRITE       |
                  GR_LC_OWN_PRM_READ    |
                  GR_LC_OWN_PRM_WRITE   |
                  GR_LC_RIGID		|
		  GR_LC_NO_PRM_COMP;

    return (OM_S_SUCCESS);

} /* GRget_locate_properties */

/*--- HSlghtsrc.HStoggle_displayability -------------------------------------------------------*/

method HStoggle_displayability( IGRint *msg )

/*
NAME
	HSlghtsrc.HStoggle_displayability

KEYWORD
	light_source

DESCRIPTION
	Send this message to an HSlghtsrc object to set the GRIS_DISPLAYABLE bit
	of all graphics owned by this object to whatever value the Light Source
	display shading flag indicates.

PARAMETERS
	msg (OUT) - returns a status.

GLOBALS USED
	none.

RETURN VALUES
	Returns the status of the last message that it sent.

HISTORY
	08/09/91 Created. -Trevor Mink
	01/17/92 Documented. -Trevor Mink
*/
{
	IGRint i, sts=OM_S_SUCCESS, bytes_req=0, bytes=0;
	IGRint num_objects=0;
	IGRshort properties=0, act;
	struct GRid objects[MAX_ELEMENTS], lite;
	struct GRmd_env master_env;
	IGRuint display_flags;
	IGRboolean Displayable;
	IGRdouble *array_of_matrices;

	/* display_flags has already been toggled, so get its value and set lights accordingly */
	hs$get_shading_flags( shading_flags = &display_flags );
	Displayable = !(display_flags & HS_SHADING_LIGHT_SOURCE_UNDISPLAY);

	/* get the current module environment */
	bytes_req = sizeof( struct GRmd_env );
	gr$get_module_env( msg    = msg,
	                   sizbuf = &bytes_req,
       		           buffer = (IGRchar *) &master_env,
               		   nret   = &bytes );

	array_of_matrices = master_env.md_env.matrix;

	sts = om$send( msg = message GRowner.GRget_number_components( (IGRlong *)msg, &num_objects ),
		targetid = my_id, targetos = master_env.md_id.osnum );

	sts = om$send( msg = message GRowner.GRget_components( (IGRlong *)msg, &master_env,
		objects, MAX_ELEMENTS, &num_objects, 0, (num_objects-1) ),
		targetid = my_id, targetos = master_env.md_id.osnum );
	OM_ERRCHK( sts, "read_light_sources:  GRowner.GRget_components send failed" );

	if ( ! Displayable )
	{
		/* toggling between displayed and not displayed => erase */
		/* the graphics before clearing the displayable bit      */
	        lite.objid = my_id;
		lite.osnum = OM_Gw_current_OS;
		dp$display( msg = msg,
			osnum = master_env.md_id.osnum,
			objid = master_env.md_id.objid,
			mode = GRbe,
			oids = &lite,
			mtx_type = &(master_env.md_env.matrix_type),
			matrix = &array_of_matrices);
	}

	act = (Displayable) ? 1 : 0;  /* Set = 1, Clear = 0 */
	for( i = 0; i < num_objects; i++ )
	{
		properties = GRIS_DISPLAYABLE; /* Only need to clear (0) or set (1) this bit */
		gr$put_properties( object_id = &(objects[i]), action = act,
				   properties_mask = properties );
	}

	if ( Displayable )
	{
		/* toggling between not displayed and displayed => draw */
		/* the graphics after setting the displayable bit       */
	        lite.objid = my_id;
		lite.osnum = OM_Gw_current_OS;
		dp$display( msg = msg,
			    osnum = master_env.md_id.osnum,
	 		    objid = master_env.md_id.objid,
		   	    mode = GRbd,
			    oids = &lite,
			    mtx_type = &(master_env.md_env.matrix_type),
			    matrix = &array_of_matrices);
	}
	return( sts );

} /* HStoggle_displayability */

end implementation HSlghtsrc;
