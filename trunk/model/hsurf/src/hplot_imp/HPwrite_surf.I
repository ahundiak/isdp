
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $

HISTORY

        Sudha   07/27/93        Modified for BSprototypes ansification

*/

class implementation Root;

#include <stdio.h>
#include <sys/types.h>
#include <sys/dirent.h>
#include <nlist.h>
#include <FI.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "msdef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"

#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"

#include "godef.h"
#include "gr.h"
#include "go.h"

#include "emsdattyp.h"
#include "emsinter.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSsfparms.h"
#include "EMSssprops.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsmacdef.h"
#include "hplot_imp.h"
#include "HSplot.h"
#include "HSplot_def.h"
#include "HStl_element.h"
#include "hsdef.h"

#include "bs.h"
#include "bsparameters.h"
#include "bsmergarrcv.h"
#include "bsfreecv.h"

#include "wl.h"

#include "HSpr_hplot.h"

/*----------------------------------
 *  for function
 *     HSget_surface_edges
 */

#include "HSe2_mesher.h"
#include "HSpr_driver.h"

/*----------------------------------*/


#define DEBUG			0
#define DEBUG_COUNT		1
#define CHECK_RETURN_CODES	1
#define INITIAL_SIZE 		10
#define	MAX_BOUNDS		1000

#define if_bad(status)	if(!((status)&1))

from EMSloopset import EMget_loops, EMget_props;
from EMSloop import EMrgpack;
from EMSboundary import EMget_edges;
from EMSedge import EMget_props, EMgetbcgeom;
from EMSsurface import EMget_params;
from EMSsubbs import EMget_props;

from GRvg import GRgetrang;
from GRvg import GRgetsymb;
from GRvg import GRgetprops;
from GRvg import GRgeomprops;
from GRvg import GRgetsize;
from GRvg import GRgetgeom;

%safe
static int scount = 0;
static int bcount = 0;

%endsafe

/*---HPget_range_from_surf----------------------------------------------------*/

/*
NAME
        HPget_range_from_surf: static
        
KEYWORDS
        shaded plotting
        static
        
DESCRIPTION
        Get the surface range from the poles
        
PARAMETERS
        surf	:(IN) : surface geometry
        range	:(OUT): range of the surfaces
        
HISTORY
        ??/??/??	M. Lanier
                Created
*/

#if defined(__STDC__) || defined(__cplusplus)
static IGRboolean HPget_range_from_surf (struct IGRbsp_surface * surf,
                                                    IGRdouble * range)
#else
static IGRboolean HPget_range_from_surf (surf, range)

   struct IGRbsp_surface *surf;
   IGRdouble *range;

#endif

   {
   int vi, ui;
   double x, y, z;

   /*
    * initialize the range to +/- maxint to begin the min/max test.
    */

   range[0] = (double) (0x7fffffff);
   range[1] = range[0];
   range[2] = range[0];
   range[3] = -range[0];
   range[4] = range[3];
   range[5] = range[3];

   /*
    * if the surface is rational, then each pole coordinate has to be divided
    * by the pole weight, else, extract the poles as is.
    */

   if (surf->rational != 0)
      {
      for (vi = 0; vi < surf->v_num_poles; vi++)
         {
         for (ui = 0; ui < surf->u_num_poles; ui++)
            {
            x = surf->poles[((vi * surf->u_num_poles) + ui) * 3] /
               surf->weights[(vi * surf->u_num_poles) + ui];
            y = surf->poles[((vi * surf->u_num_poles) + ui) * 3 + 1] /
               surf->weights[(vi * surf->u_num_poles) + ui];
            z = surf->poles[((vi * surf->u_num_poles) + ui) * 3 + 2] /
               surf->weights[(vi * surf->u_num_poles) + ui];

            if (x < range[0])
               range[0] = x;
            if (y < range[1])
               range[1] = y;
            if (z < range[2])
               range[2] = z;
            if (x > range[3])
               range[3] = x;
            if (y > range[4])
               range[4] = y;
            if (z > range[5])
               range[5] = z;
            }
         }
      }
   else
      {
      for (vi = 0; vi < surf->v_num_poles; vi++)
         {
         for (ui = 0; ui < surf->u_num_poles; ui++)
            {
            x = surf->poles[((vi * surf->u_num_poles) + ui) * 3];
            y = surf->poles[((vi * surf->u_num_poles) + ui) * 3 + 1];
            z = surf->poles[((vi * surf->u_num_poles) + ui) * 3 + 2];

            if (x < range[0])
               range[0] = x;
            if (y < range[1])
               range[1] = y;
            if (z < range[2])
               range[2] = z;
            if (x > range[3])
               range[3] = x;
            if (y > range[4])
               range[4] = y;
            if (z > range[5])
               range[5] = z;
            }
         }
      }

   return (TRUE);
   }

/*---HPwrite_surface----------------------------------------------------------*/

/*
NAME
        HPwrite_surface
        
KEYWORDS
        shaded plotting
        
DESCRIPTION
        Get the surface geometry and its parameters and write into
        the shaded plotfile
        
PARAMETERS
        elem		:(IN) : objid, osnum of the surface
        matrix_type	:(IN) : environment matrix type
        matrix		:(IN) : environment matrix
        object_env	:(IN) : object environment info
        complex		:(IN) : not referenced
        info		:(IN) : shaded plotting global information
        
HISTORY
        ??/??/??	M. Lanier
                Created
*/

#if defined(__STDC__) || defined(__cplusplus)
void HPwrite_surface (struct GRid * elem,
                           IGRshort * matrix_type,
                           IGRmatrix matrix,
                           struct GRmd_env * object_env,
                           IGRint complex,
                           struct HSplot_info * info)
#else
void HPwrite_surface (elem,
                           matrix_type,
                           matrix,
                           object_env,
                           complex,
                           info)

   struct GRid *elem;
   IGRshort *matrix_type;
   IGRmatrix matrix;
   struct GRmd_env *object_env;
   IGRint complex;
   struct HSplot_info *info;

#endif

   {
   IGRlong msg;
   unsigned char EMSprops;
   IGRlong status;

   static IGRint bs_ptr_size = 0;
   static struct IGRbsp_surface *bs_ptr = NULL;

   struct IGRbsp_surface *surf;
   OM_S_CHANSELECT sf_ls_chan;
   OM_S_OBJECT_LINKAGE loopset[1];
   OMuint chan_count;
   IGRushort ls_props;
   IGRint depth, buff_size, num_lps = 0;
   GRobjid *lp_ids = NULL;
   IGRint num_edges = 0;
   struct GRid *edge_ids = NULL;
   IGRint i, j;
   IGRboolean imposed_edge_found;
   IGRushort edge_prop;
   struct IGRbsp_curve *bdries[MAX_BOUNDS];
   IGRboolean higher_order;
   GRclassid classid;
   struct EMSpartolbasis ptol;
   struct EMSdataselect surf_data;
   IGRint size;
   IGRushort options;
   IGRshort surf_type;
   struct EMsurface_params surf_params;
   struct GRmd_env mod_env;
   IGRlong object_size;
   IGRboolean world = TRUE;
   GRrange range;
   BSrc rc;
   struct IGRbsp_bdry_pts *bdrys;
   IGRint num_bdrys;
   IGRboolean merge_ok;
   IGRboolean range_found = FALSE;
   IGRint shading_style;

   /*
    * Get the range of the object. determine if the object is displayable and
    * if the level is on before processing.
    */

#  if DEBUG_COUNT
   if (((++scount) % 1000) == 0)
      fprintf (stderr, "surface #%1d -- objid, osnum -- %1d %1d\n", scount,
               elem->objid, elem->osnum);
#  endif

   status = om$send (msg = message GRvg.GRgetrang (
                                                   &msg,
                                                   matrix_type,
                                                   matrix,
                                                   &world, range),
                     senderid = elem->objid,
                     targetid = elem->objid,
                     targetos = elem->osnum);

   OM_ERRCHK (status, "failed to GRgetrang\n");
   if_bad (status) goto error_exit;

   range_found = msg == MSSUCC;

   /*
    * mod color with num_colors
    */

   info->symbology->display_attr.color = ((info->symbology->display_attr.color - 1) % info->num_colors) + 1;

   if (!(info->properties & GRIS_DISPLAYABLE))
      {

      /*
       * the object is not displayable
       */

#		if DEBUG
      fprintf (stderr, "object is not displayable, objid=%d\n", elem->objid);
#		endif

      status = OM_S_SUCCESS;
      msg = MSSUCC;

      goto error_exit;
      }


   /*
    * get buffer size required by the b-spline object
    */

   status = om$send (msg = message GRvg.GRgetsize (
                                                   &msg,
                                                   matrix_type,
                                                   matrix,
                                                   &object_size),
                     senderid = elem->objid,
                     targetid = elem->objid,
                     targetos = elem->osnum);

   OM_ERRCHK (status, "failed to GRgetsize\n");
   if_bad (status & msg) goto error_exit;

#	if DEBUG
   fprintf (stderr, "object_size=%d\n", object_size);
#	endif

   /*
    * the object is a surface. check the EMS properties of the surface.  If
    * it is inactive, then ignore
    */

   status = om$send (msg = message EMSsubbs.EMget_props (
                                                         &msg,
                                                         &EMSprops),
                     senderid = elem->objid,
                     targetid = elem->objid,
                     targetos = elem->osnum);

   if (EMSprops & EMSIS_INACTIVE)
      goto normal_exit;

#	if DEBUG
   fprintf (stderr, "object is a EMSsubbs\n");
#	endif

   status = HPwrite_symbology ((IGRint *)&info->file_id, 
                                         &info->symbology->display_attr);
   if (status != OM_S_SUCCESS)
      goto error_exit;

   HPwrite_special_symbology( (IGRint *)&info->file_id, elem->objid, elem->osnum );

   /*
    * allocate space for geometry and retrieve it.
    */

   if (bs_ptr == NULL)
      {
      bs_ptr_size = (object_size + 256) & 0x7fffff00;
      bs_ptr = (struct IGRbsp_surface *) malloc (bs_ptr_size);
      }
   else
      {
      if (object_size > bs_ptr_size)
         {
         free (bs_ptr);
         bs_ptr_size = (object_size + 256) & 0x7fffff00;
         bs_ptr = (struct IGRbsp_surface *) malloc (bs_ptr_size);
         }
      }

   status = om$send (msg = message GRvg.GRgetgeom (
                                                   &msg,
                                                   matrix_type,
                                                   matrix,
                                                   (IGRchar *) bs_ptr),
                     senderid = elem->objid,
                     targetid = elem->objid,
                     targetos = elem->osnum);

   OM_ERRCHK (status, "failed to GRgetgeom\n");
   if_bad (status & msg) goto error_exit;


   /*
    * If the range was not obtained by the call to GRgetrange, then get the
    * range from the geometry
    */

   if (!range_found)
      range_found = HPget_range_from_surf (bs_ptr, range);


   /*
    * write rendering mode and translucency
    */

   status = HPwrite_rendering ((IGRint *) & info->file_id, elem->objid, elem->osnum, &shading_style);
   if (status != OM_S_SUCCESS)
      goto error_exit;


   status = HPwrite_object_info( (IGRint *)&info->file_id, 
                                 elem->objid,
                                 elem->osnum );
   if (status != OM_S_SUCCESS) goto error_exit;

   /*
    * write a draw with range command header.
    */

   if (range_found)
      status = HPwrite_draw_range (
                                   (IGRint *) & info->file_id,
                                   NURB_SURFACE_WITH_RANGE,
                                   info->symbology->level,
                                   range);
   else
      status = HPwrite_draw_range (
                                   (IGRint *) & info->file_id,
                                   NURB_SURFACE,
                                   info->symbology->level,
                                   NULL);

   if (status != OM_S_SUCCESS)
      goto error_exit;


   surf = bs_ptr;
   surf->num_boundaries = 0;

   status = om$make_chanselect (channame = "EMSsubbs.to_loopset",
                                p_chanselect = &sf_ls_chan);

   OM_ERRCHK (status, "failed to make_chanselet:EMSsubbs.to_loopset\n");
   if_bad (status) goto error_exit;


   status = om$get_channel_objects (osnum = elem->osnum,
                                    objid = elem->objid,
                                    p_chanselect = &sf_ls_chan,
                                    list = loopset,
                                    size = 1,
                                    count = &chan_count);

   if (chan_count != 0)
      {
      status = om$send (mode = OM_e_wrt_object,
                     msg = message EMSloopset.EMget_props (&msg, &ls_props),
                        targetid = loopset[0].S_objid,
                        targetos = loopset[0].osnum,
                        senderid = NULL_OBJID);

      if (!(ls_props & EMLS_NATURAL))
         {
         depth = MAXINT;
         buff_size = 0;
         num_lps = 0;
         lp_ids = NULL;

         status = om$send (msg = message EMSloopset.EMget_loops (
                                                                 &msg,
                                                                 EMS_OPT_ALL,
                                                                 &depth,
                                                                 &lp_ids,
                                                                 NULL,
                                                                 &buff_size,
                                                                 &num_lps),
                           senderid = elem->objid,
                           targetid = loopset[0].S_objid,
                           targetos = loopset[0].osnum);

         OM_ERRCHK (status, "failed to EMget_loops\n");
         if_bad (status & msg) num_lps = 0;


         /*
          * if not any imposed boundaries, then surf->on_off = true
          */

         surf->on_off = FALSE;

         for (i = 0; i < num_lps; i++)
            {

            /*
             * get bsp_curve for boundaries
             */

            num_edges = 0;
            buff_size = 0;
            edge_ids = NULL;

            status = om$send (msg = message EMSboundary.EMget_edges (
                                                                     &msg,
                                                                     1,
                                                                EMS_OPT_ALL,
                                                                  &edge_ids,
                                                                 &buff_size,
                                                                &num_edges),
                              senderid = NULL_OBJID,
                              targetid = lp_ids[i],
                              targetos = loopset[0].osnum);


            OM_ERRCHK (status, "failed to EMget_edges\n");
            if_bad (status & msg) goto error_exit;


#				if DEBUG
            fprintf (stderr, "loop_id[%d]=%d, num_edges=%d\n", i, lp_ids[i], num_edges);
#				endif


            j = imposed_edge_found = 0;

            while ((!imposed_edge_found) && j < num_edges)
               {
               status = om$send (msg = message EMSedge.EMget_props (
                                                                    &msg,
                                                                &edge_prop),
                                 senderid = NULL_OBJID,
                                 targetid = edge_ids[j].objid,
                                 targetos = edge_ids[j].osnum);

               OM_ERRCHK (status, "failed to EMget_props\n");
               if_bad (status & msg) goto error_exit;

               if (!(edge_prop & EMED_NATURAL))
                  imposed_edge_found = 1;
               j++;
               }

            if (!imposed_edge_found)
               surf->on_off = TRUE;

            if (imposed_edge_found)
               if (num_edges == 1)
                  {

                  /*
                   * only one imposed edge
                   */

                  struct IGRbsp_curve *curve;

                  curve = (struct IGRbsp_curve *) malloc (sizeof (struct IGRbsp_curve));
                  curve->poles = curve->knots = curve->weights = NULL;

                  status = om$send (msg = message EMSedge.EMgetbcgeom (
                                                                       &msg,
                                                                       0,
                                                                     MAXINT,
                                                                       FALSE,
                                                                       NULL,
                                                                       curve,
                                                                       NULL,
                                                                       NULL),
                                    senderid = NULL_OBJID,
                                    targetid = edge_ids[0].objid,
                                    targetos = edge_ids[0].osnum);

                  OM_ERRCHK (status, "failed to EMgetbcgeom\n");
                  if_bad (status & msg) goto error_exit;

                  bdries[surf->num_boundaries++] = curve;

#					if DEBUG
                  fprintf (stderr, "only one imposed boundary, edge id=%d\n", edge_ids[0].objid);
#					endif
                  }
               else
                  {

                  /*
                   * check order > 2?
                   */

                  j = higher_order = 0;
                  while (!higher_order && j < num_edges)
                     {
                     status = om$get_classid (osnum = edge_ids[j].osnum,
                                              objid = edge_ids[j].objid,
                                              p_classid = &classid);

                     status = om$is_ancestry_valid (subclassid = classid,
                                              superclassname = "EMSbsedge");

                     if (status == OM_S_SUCCESS)
                        higher_order = 1;
                     j++;
                     }

#					if DEBUG
                  fprintf (stderr, "higher_order=%d\n", higher_order);
#					endif

                  /*
                   * merge higher order
                   */

                  merge_ok = FALSE;
                  if (higher_order)
                     {
                     struct IGRbsp_curve *curves[MAX_BOUNDS];

                     for (j = 0; j < num_edges; j++)
                        {
                        curves[j] = (struct IGRbsp_curve *) malloc (sizeof (struct IGRbsp_curve));
                        curves[j]->poles = curves[j]->knots = curves[j]->weights = NULL;

                        status = om$send (msg = message EMSedge.EMgetbcgeom (
                                                                       &msg,
                                                                          0,
                                                                     MAXINT,
                                                                      FALSE,
                                                                       NULL,
                                                                  curves[j],
                                                                       NULL,
                                                                      NULL),
                                          senderid = NULL_OBJID,
                                          targetid = edge_ids[j].objid,
                                          targetos = edge_ids[j].osnum);

                        OM_ERRCHK (status, "failed to EMgetbcgeom\n");
                        if_bad (status & msg) goto error_exit;

#							if DEBUG
                        fprintf (stderr, "curve[%d]=%x, edges_id[%d]=%d\n", j, curves[j], j, edge_ids[j].objid);
#							endif
                        }

                     BSmergarrcv (
                                  num_edges,
                                  curves,
                                  &bdries[surf->num_boundaries],
                                  &status);

                     BS_ERRCHK (status, "failed to BSmergarrcv\n");

                     for (j = 0; j < num_edges; j++)
                        BSfreecv (&rc, curves[j]);

#						if DEBUG
                     fprintf (stderr, "pass BSmerge\n");
#						endif

                     if (status == BSSUCC)
                        {
                        surf->num_boundaries++;
                        merge_ok = TRUE;
                        }
                     }

                  if (!merge_ok)
                     {
#						if DEBUG
                     fprintf (stderr, "calling rgpack..., surf=%x\n", surf);
#						endif

                     status = EFsspbtol_by_geom (
                                                 &msg,
                                                 surf,
                                                 &ptol.tol);

                     if_bad (status & msg) goto error_exit;

                     ptol.in_world = ptol.is_valid = TRUE;
                     ptol.mattyp = (IGRshort *) matrix_type;
                     ptol.mat = (IGRdouble *) matrix;

                     surf_data.datatype = EMSdata_surface;
                     surf_data.data.surface = surf;

                     bdrys = (struct IGRbsp_bdry_pts *) malloc (INITIAL_SIZE * sizeof (struct IGRbsp_bdry_pts));

                     num_bdrys = 0;
                     size = INITIAL_SIZE;
                     options = NULL;

                     status = om$send (msg = message EMSloop.EMrgpack (
                                                                       &msg,
                                                              &surf->on_off,
                                                                 &num_bdrys,
                                                                     &bdrys,
                                                                       &size,
                                                                 &surf_data,
                                                                matrix_type,
                                                                     matrix,
                                                            options, &ptol),
                                       senderid = NULL_OBJID,
                                       targetid = lp_ids[i],
                                       targetos = elem->osnum);

                     OM_ERRCHK (status, "failed to EMrgpack\n");
                     if_bad (status & msg) goto error_exit;

#						if DEBUG
                     fprintf (stderr, "pass EMrgpack, before call HPconvert_curve, ptol.tol=%.10lf\n", ptol.tol);
#						endif

                     /*
                      * we need only bdry from the first loop
                      */

                     HPconvert_curve (&bdrys[0], &bdries[surf->num_boundaries]);
                     surf->num_boundaries++;

                     if (bdrys)
                        {
                        int ii;

                        for (ii = 0; ii < num_bdrys; ii++)
                           {
                           if (bdrys[ii].points != NULL)
                              free (bdrys[ii].points);
                           }
                        free (bdrys);
                        }

                     bdrys = NULL;

#						if DEBUG
                     fprintf (stderr, "pass HPconvert_curve, num_bdrys=%d\n\n", num_bdrys);
#						endif
                     }
                  }

            if (edge_ids != NULL)
               free (edge_ids);
            }

         if (lp_ids != NULL)
            free (lp_ids);
         }
      }

   /*
    * write the surface data.
    */

   status = om$send (mode = OM_e_wrt_object,
                     msg = message EMSsurface.EMget_params (
                                                            &msg,
                                                            surf,
                                                            &mod_env,
                                                  (IGRushort *) & surf_type,
                                                            NULL),
                     senderid = NULL_OBJID,
                     targetid = elem->objid,
                     targetos = elem->osnum);


   status = HPwrite_surface_info ((IGRint *) & info->file_id, surf, surf_type);
   if (status != OM_S_SUCCESS)
      goto error_exit;

   /*
    * write surface boundaries, if any
    */

#	if DEBUG
   fprintf (stderr, "surf->num_boundaries=%d\n", surf->num_boundaries);
#	endif

   for (j = 0; j < surf->num_boundaries; j++)
      {
#     if DEBUG_COUNT
      if (((++bcount) % 1000) == 0)
         fprintf (stderr, "boundary #%1d\n", bcount);
#     endif

      HPwrite_curve_info ((IGRint *) & info->file_id, bdries[j], 2, FALSE);
      BSfreecv (&rc, bdries[j]);
      }

   /*
    * If the output style is raster or filled raster, then write the edge
    * information now
    */

   if (shading_style == HS_STYLE_RASTER || shading_style == HS_STYLE_FILLED_RASTER)
      {
      IGRdouble trot[4][4];

      memcpy (trot, info->rotation, sizeof (IGRdouble) * 16);

      HSget_surface_edges (
                           (IGRint *) & info->file_id,
                           elem->objid,
                           elem->osnum,
                           surf,
                           &object_env->md_env,
                           0, 0, 0, 0, 0, 0.0, NULL,
                           trot,
                           HS_GET_EDGES_MODE_PLOTTING,
                           info->con_flags & HP_CONTROL_PERSPECTIVE,
                           info->eye_pt);
      }

normal_exit:
   info->con_flags |= HP_CONTROL_WRITTEN_TO_PLOTFILE;
   return;

error_exit:

   info->con_flags |= HP_CONTROL_WRITE_TO_PLOTFILE_ERROR;
   return;
   }

#if DEBUG
/*---dump_curve--------------------------------------------------------*/

/*
NAME
        dump_curve: static
        
KEYWORDS
        shaded plotting
        static
        debug
        
DESCRIPTION
        Print a curve's geometry
        
PARAMETERS
        curve	:(IN) : the curve geometry
        
HISTORY
        ??/??/??	M. Lanier
                Created
*/

static dump_curve (curve)

   struct IGRbsp_curve *curve;

   {
   IGRint ui, index;

   fprintf (stderr, "\n\nCurve Definition:\n");
   fprintf (stderr, "  order      = %d\n", curve->order);
   fprintf (stderr, "  num_poles  = %d\n", curve->num_poles);
   fprintf (stderr, "  num_knots  = %d\n", curve->num_knots);
   fprintf (stderr, "  rational   = %d\n\n", curve->rational);

   if (curve->rational != 0)
      {
      fprintf (stderr, "  Poles (u, x, y, z, w):\n");

      for (ui = 0; ui < curve->num_poles; ui++)
         fprintf (stderr, "%5d %13.5lf %13.5lf %13.5lf %13.5lf\n",
                  ui,
                  curve->poles[(ui) * 3] / curve->weights[ui],
                  curve->poles[(ui) * 3 + 1] / curve->weights[ui],
                  curve->poles[(ui) * 3 + 2] / curve->weights[ui],
                  curve->weights[ui]);
      }
   else
      {
      fprintf (stderr, "  Poles (u, x, y, z):\n");

      for (ui = 0; ui < curve->num_poles; ui++)
         fprintf (stderr, "%5d %13.5lf %13.5lf %13.5lf\n",
                  ui,
                  curve->poles[(ui) * 3],
                  curve->poles[(ui) * 3 + 1],
                  curve->poles[(ui) * 3 + 2]);
      }

   fprintf (stderr, "\n  knots:\n");

   for (index = 0; index < curve->num_knots; index++)
      fprintf (stderr, "%17.9lf\n", curve->knots[index]);
   }

#endif

end implementation Root;
