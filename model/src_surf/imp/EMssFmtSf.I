/* ###################   APOGEE COMPILED   ################## */
/*
Description

 This method translates an EMS surface into one or more IGDS surfaces.
 The surfaces are written into the input design file.

Return values

 Upon exit the completion code will always be MSSUCC and the
 function return code will be OM_S_SUCCESS.  Errors are not
 returned since this method is only used when sending in bulk
 through the R-tree.  That is, I should not stop other elements
 from being translated just because I have failed.

Notes

 Documentation is available through the nucleus graphic object document.

History

 sb/gfs 10/20/86 : Design date
 beth   06/02/87 : Reworked to support large surfaces and output
                   boundaries as linestrings if excessive
 rlw    08/31/87 : Rewritten to fix bugs and clean up.  Also attempts
                   to output boundaries even if windowing is performed
                   via loopset routines written by Sunit.
 SM     09/15/87 : Tested and made some fixes. 
 rlw    10/07/87 : Modified due to changes in EFremove_collapsed_edges()
 SM     11-Nov-87: Incorporated changes related to the new argument
                   'scale factor'. Earlier the scale factor was included
                   in the matrix passed in. Now it is done here.
 SM     24-May-88: Made modifications regarding element name.
 rlw	08/04/88 : Fixed a problem in my logic which determined when
                   excessive boundaries are present.
 AIC	12 Oct 88: Fixed arguments for EMSloopset.EMpack and
                   EMSsubbs.EMget_boundaries.
 rlw    01/17/89 : Modified not to translate if surface is inactive.
 SM     13-Feb-89: Multiply the current chord height tol by scale factor
                   and set the new cht. Reset upon exit. 
 rlw    02/16/89   DRAFT added an argument to the GUotype* functions.
 DLB    04/17/89   Added EMset_inactive send to handle pre 1.2.0 OS which
                   doesn't have the inactive bit set.
 rlw    05/03/89   Modified not to dump surfaces with a single boundary
                   which contains 3 points.
 RC     05/18/89   Modified the code such that if the surface has
                   overflowing boundaries, it is broken into patches
                   with boundaries not exceeding overflow limit.
 pp     13-Oct-89  Modified the code to support an alternative 
                   symbology and user specified level mapping should
                   they exist.
 SM	04-Dec-89  If log enabled print out surface number, osnum and
		   objid.
 SM	27-Dec-89  Pass synbology.level instead of me->level to GUcpxhandler.
 NP     25-Aug-92  Modified for ANSI compliance. Moved "rlw_dump_to_igds" to entire
		   file scope. Also missing keyword "static" added. Also, the
		   declaration for "GUget_symb_level" was in the wrong block. Changed
		   "unsigned IGRshort" to "IGRushort".
*/
class implementation EMSsubbs;

#include "EMS.h"
#define DEBUG 0
#if DEBUG
#include <stdio.h>
#endif
#include "bs.h"                 /* Has igr stuff plus bs codes and types */
#include "msdef.h"              /* Has MSFAIL */
#include "godef.h"              /* Has GRLN and GRCURVE */
#include "transdef.h"           /* Has GUBSBUF_SIZE */
#include "EMSsplitdef.h"        /* Has SPLIT_BOTH, SPLIT_U, SPLIT_V */
#include "EMSssprops.h"		/* Has inactive bit defined */
#include "bsparameters.h"
#include "bserr.h"
#include "EMSfmtsf.h"
#include "EMSprop.h"
#include "OMmacros.h"

/*
 * imports
 */
from EMSloopset  import EMwindow, EMpack, EMget_props;
from EMSboundary import EMget_objid;

static IGRlong rlw_dump_to_igds();

method GRformatele(
IGRlong         *msg;              /* Error return code */
struct          GRmd_env *md_env;  /* context information */
IGRchar         *dgn_buf;          /* buffer for output to IGDS dgn file*/
IGRchar         *bs_buf;           /* buffer to hold abstract geom */
IGRchar         *ele_buf;          /* buffer to hold an IGDS element */
IGRint          *ele_size;         /* number of bytes in IGDS element */
IGRint          *file_des;         /* pointer to IGDS design file */
IGRdouble       *max_overflow;     /* max. abs. value for int. overflow*/
IGRdouble	*scale_factor)		   /* Scale of EMS to IGDS working units*/

{
 struct  IGRbsp_surface *surface, **res_sfs_geom;
 struct  GRsymbology    symbology;
 struct  GRprops        geom_props;
 struct  IGResbs        attributes;
 IGRmatrix		        scale_matrix;
 struct GRmd_env	    new_env;
 GRname                 my_name;
 IGRlong                sts;
 IGRlong                i, j, rc;
 IGRint                 num_res_sfs;
 IGRshort		        num_rc = 4;
 IGRboolean		        status, has_name = FALSE, is_sf_split;
 extern  IGRboolean     MAmulmx(), MAtypemx();
 extern void            EFbreak_sf_to_avoid_IGDS_overflow ();
 extern IGRlong         GUget_symb_level();
 extern int 		pp_ems_igds_num_calls, pp_output_ems_igds_log, 
			pp_increment_ems_igds;

  
/*
 *  Initialization.
 */

 surface = NULL;
 res_sfs_geom = NULL;
 num_res_sfs = 0;
 *msg = MSSUCC;
 sts = OM_S_SUCCESS;
 
/* { */ /*Intentional block. -DLB*/
/*
   IGRlong dlb_loc_msg, OM_stat;
   IGRboolean did_set_inactive;
   OM_stat = om$send(msg = message EMSsubbs.EMset_inactive(
                           &dlb_loc_msg, &did_set_inactive),
                     targetid = my_id);
 }
*/

 if (me->ss_props & EMSIS_INACTIVE) goto wrapup; /* rlw 01/17/89 */

 ++pp_ems_igds_num_calls;

if (pp_output_ems_igds_log)
{
 if ((pp_ems_igds_num_calls == 1) ||
    (!(pp_ems_igds_num_calls % pp_increment_ems_igds)))
 fprintf (stderr,"Processing surface %d (%d . %d) \n", pp_ems_igds_num_calls, 
	  OM_Gw_current_OS, my_id);
}

 /* 
  * Generate new matrix with the scale factor
  */

 for(i=0; i<16; i++) scale_matrix[i] = 0.0;
 scale_matrix[0] = *scale_factor;
 scale_matrix[5] = *scale_factor;
 scale_matrix[10] = *scale_factor;
 scale_matrix[15] = 1.0;

 new_env = *md_env;

 status = MAmulmx(msg, &num_rc, &num_rc, &num_rc, scale_matrix, 
		   md_env->md_env.matrix, new_env.md_env.matrix);

 status = MAtypemx(msg, new_env.md_env.matrix, 
                   &new_env.md_env.matrix_type);

 /* 
  * Hereafter use new_env instead of md_env
  * Get the range of this surface
  */

 {
  GRrange       range;
  IGRlong       num_values = 6;
  IGRboolean    world = TRUE, no_overflow;
  extern  IGRboolean  GUcheck_overflow();

  sts = om$send(
    msg = message GRvg.GRgetrang(
     msg,
     &new_env.md_env.matrix_type,
     new_env.md_env.matrix,
     &world,
     range),
    targetid = my_id);
  if (! (1 & sts & *msg)) goto wrapup;

  /*
   * Check for IGDS overflow
   */

  no_overflow = GUcheck_overflow(
    msg,
    &num_values,
    range,
    max_overflow);
  if (!no_overflow || !(1 & *msg) ) goto wrapup;
 }

 /*
  * Get the symbology of this surface
  */

 sts = om$send(
   msg = message GRvg.GRgetsymb(
    msg,
    &symbology),
   targetid = my_id);
 if (! (1 & sts & *msg)) goto wrapup;

/*
 * Call to support alternative symbology/level mapping.
 * pp (10/12/89).
 */
   sts = GUget_symb_level(msg,&symbology);
   if (! (1 & sts)) goto wrapup;

 /*
  * Call the complex handler to determine whether to continue formatting
  * this object.
  */
 {
    struct GRid        my_GRid;
    IGRchar            IGDSclass = 0;
    IGRboolean         format, mark_as_cpx,
                       cpx_calling = FALSE;
    extern IGRboolean  GUcpxhandler();


    my_GRid.osnum = OM_Gw_current_OS;
    my_GRid.objid = my_id;

    if(! GUcpxhandler(msg, &cpx_calling, md_env, dgn_buf, bs_buf,
                      ele_buf, ele_size, file_des, max_overflow,
                      scale_factor, &IGDSclass, &me->properties,
                      &symbology.level, &my_GRid, &format, &mark_as_cpx))
      goto wrapup;

    if(! format) goto wrapup;
  }

  /*
   * Get the element specific attributes of this surface
   */
 
  sts = om$send(
   msg = message GRvg.GRgetattr(
    msg,
    (IGRchar *)&attributes),
   targetid = my_id);
  if (! (1 & sts & *msg)) goto wrapup;
  attributes.type = 0;

  /* 
   * Get the element name if any.
   */
  sts = om$send(msg = message GRvg.GRgetname (msg, my_name),
                    targetid = my_id);
  has_name = 1 & *msg;

  /*
   * Get the geometric properties of this surface
   */

  sts = om$send(
   msg = message GRvg.GRgeomprops(
    msg,
    &new_env.md_env.matrix_type,
    new_env.md_env.matrix,
    &geom_props),
   targetid = my_id);
  if (! (1 & sts & *msg)) goto wrapup;

  /*
   * Determine the number of bytes required to store the
   * geometry in a buffer
   */

 {
   IGRlong       object_size;

  sts = om$send(
    msg = message GRvg.GRgetsize(
     msg,
     &new_env.md_env.matrix_type,
     new_env.md_env.matrix,
     &object_size),
    targetid = my_id);
   if (! (1 & sts & *msg)) goto wrapup;

  if (object_size > GUBSBUF_SIZE)
   {    
    surface = (struct IGRbsp_surface *) malloc(object_size);
     if (!surface) goto wrapup;
   }
  else
   surface = (struct IGRbsp_surface *) bs_buf;
 }

/*
 * Get the geometry of the surface
 */

 sts = om$send(
   msg = message GRvg.GRgetgeom(
    msg,
    &new_env.md_env.matrix_type,
    new_env.md_env.matrix,
    (IGRchar *) surface),
   targetid = my_id);
  if (! (1 & sts & *msg)) goto wrapup;

  /*
   * Break the surface such that neither its geometry (poles) nor
   * nor its boundaries (num_pts_per_boundary or num_boundaries)
   * overflow IGDS limits.
   */

  EFbreak_sf_to_avoid_IGDS_overflow (msg, my_id, OM_Gw_current_OS, 
          &surface, &new_env, scale_factor, &is_sf_split, &num_res_sfs, 
          &res_sfs_geom);
  if (!(1 & *msg)) goto wrapup;

  /*
   * If the surface is split, modify the geometric properties
   */
  
  if (is_sf_split) geom_props.phy_closed = FALSE;
  

  /*
   * Finally, let's output the surfaces.  I am not checking the
   * error return code of this function on purpose.
   */

  {
   /* IGRlong rlw_dump_to_igds(); Moved to entire file scope. NP 08/25/92 */

   for (i = 0; i < num_res_sfs; i++)
   {
    if (res_sfs_geom[i])
    {
      sts = rlw_dump_to_igds(
          msg,
          file_des,
          dgn_buf,
          ele_buf,
          ele_size,
          &symbology,
          &geom_props,
          &attributes,
          &me->properties,
          &has_name,
          my_name,
          res_sfs_geom[i]);

     } /* if (res_sfs_geom[i]) */

  } /* for (i = 0; i < num_res_sfs; i++) */

} /* Output the surface */

wrapup:

if (surface)
{
   if (surface->bdrys) 
   {
     for (i = 0; i < surface->num_boundaries; i++)
     {
       if (surface->bdrys[i].points) free(surface->bdrys[i].points);
     }
     free(surface->bdrys);
   } 

   if (surface != (struct  IGRbsp_surface *)bs_buf) free(surface);

} /* if (surface) */

 if (is_sf_split)
 {
   if (res_sfs_geom)
   {
    for (i = 0; i < num_res_sfs; i++)
    {
      if (res_sfs_geom[i]) 
      {
       extern  IGRboolean  BSfreesf();
       IGRboolean       bsrc, status;

       if (res_sfs_geom[i]->num_boundaries)
       {
        for (j = 0; j < res_sfs_geom[i]->num_boundaries; j++)
          if (res_sfs_geom[i]->bdrys[j].points)
            free (res_sfs_geom[i]->bdrys[j].points);

        free (res_sfs_geom[i]->bdrys);
        res_sfs_geom[i]->num_boundaries = 0;
        res_sfs_geom[i]->bdrys = NULL;

       } /* if (res_sfs_geom[i]->num_boundaries) */

       status = BSfreesf(&bsrc, res_sfs_geom[i]);

      } /* if (res_sfs_geom[i]) */

    } /* for (i = 0; i < num_res_sfs; i++) */

    free (res_sfs_geom);

   } /* if (res_sfs_geom) */

 } /* if (is_sf_split) */

if (pp_output_ems_igds_log)
{
 if ((pp_ems_igds_num_calls == 1) ||
    (!(pp_ems_igds_num_calls % pp_increment_ems_igds)))
  {
   if(!(1 & *msg & sts))
    fprintf (stderr,"Surface %d (%d . %d) -- ** Problematic\n", 
	     pp_ems_igds_num_calls, OM_Gw_current_OS, my_id);
  }
}

/*
 * Always return success whether or not it is honest
 */

 *msg = MSSUCC;
 return (OM_S_SUCCESS);

}

/*
 * This static function will output the input surface into an
 * IGDS design file.  If the input surface has more boundaries
 * than IGDS can handle then this routine will transfer the
 * boundaries as linestrings.
 *
 * This routine will function properly if the surface is large but
 * has no boundaries.  If the surface is both large and has boundaries
 * then it will output corrupted data.
 *
 * This routine could have been written far more efficently by reusing
 * the memory for the model space data representing the boundaries.
 * I have merely malloc'ed everything.  I don't think that this will
 * be a major problem because I assume that this code will not be
 * visited that often.
 *
 * If a failure occurs the return code will be MSFAIL.
 *
 * 09/09/87 : rlw : creation date
 * 10/07/87 : rlw : Modified due to changes in EFremoved_collapsed_edges()
 * 08/04/88 : rlw : Fixed a problem in my logic which determines when
 *                  excessive boundaries are present.
 * 05/03/89 : rlw : Modified not to dump surfaces with a single boundary
 *                  which contains 3 points.
 * 05/18/89 : RC  : Modified the code such that it does not check for
 *                  boundaries overflow and conversion of overflowing
 *                  boundaries into linestrings. It is due to the fact
 *                  that the surface with overflowing boundaries are
 *                  already broken into patches with no patch having
 *                  overflowing boundaries.
 */
static IGRlong rlw_dump_to_igds(
 msg,
 file_des,
 dgn_buf,
 ele_buf,
 ele_size,
 symbology,
 geom_props,
 attributes,
 properties,
 has_name,
 name,
 surface)

IGRlong         *msg;
IGRint          *file_des;
IGRchar         *dgn_buf;
IGRchar         *ele_buf;
IGRint          *ele_size;
struct          GRsymbology *symbology;
struct          GRprops *geom_props;
struct          IGResbs *attributes;
IGRushort 	*properties;
IGRboolean      *has_name;
IGRchar         *name;
struct          IGRbsp_surface *surface;
{
 IGRboolean     delayed_error = FALSE;

/*
 * Change the number of rule lines that should
 * be displayed
 */
  attributes->u_rules = surface->v_num_poles;
  attributes->v_rules = surface->u_num_poles;
/*
 * Dump the surface into the design file
 */
 {
 extern  IGRboolean  BSbx2();
 IGRboolean    status;
 extern  IGRlong  GUotype24();
 IGRlong       sts, total_poles, bsrc;
 GRrange       range;

  if ((surface->num_boundaries == 1) &&	/* rlw 05/03/89 */
      (surface->bdrys[0].num_points == 3))
    goto wrapup;

  total_poles = surface->u_num_poles * surface->v_num_poles;
  status = BSbx2(
    &bsrc,
    &total_poles,
    surface->poles,
    (surface->rational ? surface->weights : NULL),
    &range[0],
    &range[3]);
   if (!status) 
    delayed_error = TRUE;
   else
    {
     sts = GUotype24(
       msg,
       file_des,
       dgn_buf,
       ele_buf,
       ele_size,
       "EMSsubbs",
       surface,
       range,
       symbology,
       geom_props,
       properties,
       attributes,
       has_name,
       name);
    }
 }

wrapup:

/*
 * eof
 */
 if (delayed_error || (! (1 & *msg)))
  {
   *msg = MSFAIL;
   return(FALSE);
  }
 else
  return(TRUE);
}

end implementation EMSsubbs;

