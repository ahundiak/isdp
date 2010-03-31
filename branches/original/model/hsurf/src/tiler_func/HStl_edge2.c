
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:42 $
$Locker:  $
*/

#if defined( ENV5 )

#include <stdio.h>
#include <stdlib.h>

#include <EG.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "dp.h"
#include "dpstruct.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsdef.h"
#include "hsurf.h"
#include "hsmath.h"

#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*--------------------------
 *  for function
 *     HSdelete
 */
 
#include "HSpr_driver.h"

/*------------------------------*/


#define ADD_AMBIENT	0
#define ZERO_TOL    0.00001

#define EG_VERTS_SPACE 50

/*-----HSdelete_EG_shading_window------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSdelete_EG_shading_window(void)
#else
	void HSdelete_EG_shading_window()
#endif

/*
NAME
	HSdelete_EG_shading_window

DESCRIPTION
	HSdelete_EG_shading_window deletes the active window's
	viewing context.

PARAMETERS
	none

GLOBALS USED
	active_window

NOTES
	This function assumes that the active window pointer points
	to the window to be deleted.

HISTORY
	10/12/90    S.P. Rogers
	   Creation Date
	01/15/92    S.P. Rogers
	   Added prologue comment
*/

	{
        /* don't do anything here => because DL will */
        /* take care of deleting the viewing context */
	}  /* HSdelete_EG_shading_window */


/*-----HSsetup_EG_lights------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSsetup_EG_lights(	struct HS_light_source global_lights[MAX_LIGHTS], 
				struct HS_light_source *ambient_light )
#else
	void HSsetup_EG_lights(	global_lights, ambient_light )

	struct HS_light_source global_lights[MAX_LIGHTS];
	struct HS_light_source *ambient_light;
#endif

/*
NAME
	HSsetup_EG_lights

DESCRIPTION
	This function sets the necessary EG light structures.

PARAMETERS
	global_lights (IN) - the lights to be set up
	ambient_light (IN) - the ambient light to set up, if NULL then no ambient light

GLOBALS USED
	active_window

NOTES
	This function assumes that the active_window pointer is 
	pointing to the window whose lights are to be set up.

HISTORY
	07/18/89    C.M. Jablonski
	   Taken from HSsetup_window_lights
	01/15/92    S.P. Rogers
	   Added prologue comment
*/

{
IGRint               	ii, num_lights;
struct HS_light_source	aligned_lights[MAX_LIGHTS];
EGLightSrcRep		eg_light;

	/* Get the window lights into world coordinates */
	HSalign_view_lights_to_world( global_lights, aligned_lights );

	num_lights = 0;
	for (ii = 0; ii < MAX_LIGHTS; ii++)
		{
		if ( aligned_lights[ii].flags & HS_LIGHT_ENABLED )
			{
			num_lights++;
			switch (aligned_lights[ii].flags & HS_LIGHT_TYPE) {

				case HS_LIGHT_SPOT :
					eg_light.type = EG_LS_SPOT;

					eg_light.position.x = aligned_lights[ii].location[0];
					eg_light.position.y = aligned_lights[ii].location[1];
					eg_light.position.z = aligned_lights[ii].location[2];

			        	eg_light.direction.x = aligned_lights[ii].direction[0];
		        		eg_light.direction.y = aligned_lights[ii].direction[1];
		        		eg_light.direction.z = aligned_lights[ii].direction[2];

					/* The HALF angle is stored */
					eg_light.spreadAngle = aligned_lights[ii].angle * 2.0;
					eg_light.concenExp = 1.0;
					break;

				case HS_LIGHT_POINT :

					eg_light.type = EG_LS_POSITIONAL;
					eg_light.position.x = aligned_lights[ii].location[0];
					eg_light.position.y = aligned_lights[ii].location[1];
					eg_light.position.z = aligned_lights[ii].location[2];
					break;

				case HS_LIGHT_PARALLEL :
				case HS_LIGHT_PENCIL :

					eg_light.type = EG_LS_DIRECTIONAL;
			        	eg_light.direction.x = aligned_lights[ii].direction[0];
		        		eg_light.direction.y = aligned_lights[ii].direction[1];
		        		eg_light.direction.z = aligned_lights[ii].direction[2];

					break;
				}  /* end: switch */

			/* how to use light source radius ? */
			eg_light.attenCoeff[0] = 1;
			eg_light.attenCoeff[1] = 0.001;

			/* Take the average of the RGB intensities and get between 0 and 1 */
			eg_light.color.red = aligned_lights[ii].red / 255.0;
			eg_light.color.green = aligned_lights[ii].green / 255.0;
			eg_light.color.blue = aligned_lights[ii].blue / 255.0;

			EGSetLightSrcRep( active_window->EG_vc_no, ii, &eg_light );
			EGSetLightSrcState( active_window->EG_vc_no, ii, EG_ON );
			}  /* light is active */
		else
			{
			EGSetLightSrcState( active_window->EG_vc_no, ii, EG_OFF );
			}

		}  /* end: for */

	if (ambient_light)
		{
		eg_light.type = EG_LS_AMBIENT;
		eg_light.color.red = ambient_light->red / 255.0;
		eg_light.color.green = ambient_light->green / 255.0;
		eg_light.color.blue = ambient_light->blue / 255.0;
		EGSetLightSrcRep( active_window->EG_vc_no, MAX_LIGHTS, &eg_light );
		EGSetLightSrcState( active_window->EG_vc_no, MAX_LIGHTS, EG_ON );
		num_lights++;
		}

	if (num_lights)
		EGSetLightingMode( active_window->EG_vc_no, EG_ON );

}  /* HSsetup_EG_lights */


/*---HSsetup_EG_window--------------------------------------------------------*/

/*ARGSUSED*/
void HSsetup_EG_window(	IGRdouble wld_to_view[4][4], 
			IGRdouble vw_vol[6], 
			IGRdouble eye_pt[3], 
			IGRdouble vrp[3], 
			IGRdouble vpn[3], 
			IGRdouble vup[3], 
			   IGRint x_dits, 
			   IGRint y_dits, 
		       IGRboolean init_zbuffer )
/*
NAME
	HSsetup_EG_window

DESCRIPTION
	This function sets the EG window parameters that may change on a
	per-update basis.

PARAMETERS
	wld_to_view (IN) - the world to view matrix for the window
	vw_vol (IN) - the view volume of the window
	eye_pt (IN) - window eye point for perspective
	vrp (IN) - window view reference point for perspective
	vpn (IN) - window view plane normal for perspective
	vup (IN) - window view up vector
	x_dits (IN) - X size of window in dits
	y_dits (IN) - Y size of window in dits
	init_zbuffer (IN) - if TRUE, initialize the hardware Zbuffer

GLOBALS USED
	active_window

NOTES
	This function assumes that the active_window pointer is pointing
	to the window that should be set up.

HISTORY
	04/05/90    C.M. Jablonski
	   Taken from HSsetup_shading_window
	01/15/92    S.P. Rogers
	   added init_zbuffer parameter to support view independent elements
        07/14/93    S.P. Rogers
           Took out matrix setup because DL is now taking care of it
*/

{

   if ( init_zbuffer )
   {
      /* set the Z BUFFER MODE */
      EGSetZBufferMode( active_window->EG_vc_no, EG_ON );
      EGSetZBuffer( active_window->EG_vc_no, EG_MAX_Z_VALUE );
   }

}  /* HSsetup_EG_window */


/*--- HSsend_trimesh_to_EG --------------------------------------*/

int HSsend_trimesh_to_EG(
   int vc_no,
   struct HStri_mesh *tri_mesh )

{
   EGTriMeshData3Info EGmesh;

   /* convert the tri mesh to an EG structure */
   EGmesh.numVerts = tri_mesh->numVerts;
   EGmesh.verts = (EGPoint3 *) tri_mesh->verts;
   EGmesh.vertOffset = sizeof( EGPoint3 );
   EGmesh.vColors = (EGRGBColor *) tri_mesh->vColors;
   EGmesh.vColorOffset = tri_mesh->vColors ? sizeof( EGRGBColor ) : 0;
   EGmesh.vNorms = (EGVect3 *)tri_mesh->vNorms;
   EGmesh.vNormOffset = tri_mesh->vNorms ? sizeof( EGVect3 ) : 0;
   EGmesh.fColors = (EGRGBColor *) tri_mesh->fColors;
   EGmesh.fColorOffset = tri_mesh->fColors ? sizeof( EGRGBColor ) : 0;
   EGmesh.fNorms = (EGVect3 *) tri_mesh->fNorms;
   EGmesh.fNormOffset = (tri_mesh->numFacetNormals > 1) ? sizeof( EGPoint3 ) : 0;

   EGTriMeshData3( vc_no, &EGmesh );

}  /* HSsend_trimesh_to_EG */

/*---HSsend_polyline_to_EG-----------------------------------------------*/

void HSsend_polyline_to_EG(
   IGRint num_points, 
   IGRpoint *points )

/*
NAME
        HSsend_polyline_to_EG

DESCRIPTION
	This puts a polyline in the EDGEII format and calls
	EGPolyLine3() with it.

HISTORY
	S.P. Rogers  10/05/90  Creation Date
*/

{
IGRint          ii;
EGPolyLine3Info	polyLine;
EGPoint3	st_verts[EG_VERTS_SPACE];

	if ( tiling_parms.processing_mode & HS_PMODE_FEEDBACK )
	   HSsave_trimesh_polyline( num_points, points );
	else
        {
   	   polyLine.closed = EG_OFF;
	   polyLine.numVerts = num_points;
	   polyLine.vertOffset = sizeof(EGPoint3);
           if ( num_points > EG_VERTS_SPACE )
           {
	      polyLine.verts = (EGPoint3 *) malloc( num_points * sizeof( EGPoint3) );
           }
           else
           {
	      polyLine.verts = st_verts;
           }

	   if (!polyLine.verts)
	   	   {
		   HSset_status( HSSTAT_ALLOC_ERROR );
		   return;
	  	   }

	   for (ii = 0; ii < num_points; ii++)
	  	{
		polyLine.verts[ii].x = (float)points[ii][0];
		polyLine.verts[ii].y = (float)points[ii][1];
		polyLine.verts[ii].z = (float)points[ii][2];
		}

	   EGPolyLine3( active_window->EG_vc_no, &polyLine );

	   if ( (polyLine.verts) && (polyLine.verts != st_verts) )
		free( (char *) polyLine.verts );
        }

}  /* HSsend_polyline_to_EG */


/*---HSdraw_point_EG--------------------------------------------------------------*/

void HSdraw_point_EG(
   IGRpoint point )

{
    EGPoint3 Point[4];
    EGPolyLine3Info polyLine;

    Point[0].x = point[0] - ZERO_TOL;
    Point[0].y = point[1] - ZERO_TOL;
    Point[0].z = point[2];

    Point[1].x = point[0] + ZERO_TOL;
    Point[1].y = point[1] - ZERO_TOL;
    Point[1].z = point[2];

    Point[2].x = point[0] + ZERO_TOL;
    Point[2].y = point[1] + ZERO_TOL;
    Point[2].z = point[2];

    Point[3].x = point[0] - ZERO_TOL;
    Point[3].y = point[1] + ZERO_TOL;
    Point[3].z = point[2];

    polyLine.closed = EG_ON;
    polyLine.numVerts = 4;
    polyLine.verts = Point;
    polyLine.vertOffset = sizeof(EGPoint3);

    EGPolyLine3( active_window->EG_vc_no, &polyLine );

}  /* HSdraw_point_EG */

#endif

