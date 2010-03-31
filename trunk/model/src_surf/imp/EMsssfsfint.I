/*
  DESCRIPTION:

    This method computes the intersection between the surfaces of this
    object and the surface object that is input. The output is in the
    form of a linked-list, ordered such that all the intersection information 
    related to a given surface is available in sequence. The input surface
    object could be in the form of an OM-object, surface buffer or
    represented by an infinite plane.

    A useful side-effect of invoking this method with the options -
    output_world and output_param set to FALSE, is to get back a T/F result
    informing if any intersections exist between these two surface-objects.
  
    Various options are available for the output. These basically govern
    the form of output and/or further manipulations to be performed on
    it. These are specified via three bit-masks. Symbolically defined
    constants are available to prepare these masks. The various options
    that can be specified by these masks are described below:

  ARGUMENTS:

    mattyp, mat		- The matrix and matrix-type to be used for this
			  object.

    const_args		- The construction-list used to create objects

    other_data		- The other surface data with which this intersection
                          is to be performed. Can be a surface-object,
			  surface-buffer or an infinite plane definition.

    other_datenv        - The other surface data's environment information

    outworld_options	- Options mask used to specify:
			   Model-space output wanted or not
                           Output to be database objects (line-strings) or 
                            memory buffers.
                          Output to be oriented with respect to the other
                           intersection surface. The orientation is done
                           wrt to the oriented normal (pointing into volume)
                           of the surface.
                          If output to be oriented - should the other surface
                           be to the right or the left of a natural traversal.
    outparam_options	- Options mask used to specify:
			   Parametric-space output wanted or not
                           Output to be database objects (surface edges) or
                            memory buffers.
                           Output to be oriented with respect to the other
                            intersection surface. The orientation is done
                            wrt to the natural normal of the surface (direction
                            of the cross-product U X V).
                           If output to be oriented - should the other surface
                            be to the right or the left of a natural traversal.
                           N.B.: In case of inconsistency here with
			         outworld_options, outparam_options wins.
    trim_options	- Options mask used to specify:
			   Output to be trimmed with respect to the existing
                            surface boundaries.
                           The trimming to take place w.r.t boundaries
                            being treated as part of area.
                           Overlapping cases with the boundaries should be
                            output as separate intersections. This option
                            is relevant only when boundary is area.
                           The STOP-interrupt to be handled.
                           The trimming is to be done using an alternate
                            more careful (therefore more time-consuming)
                            algorithm.

    num_inters		- Total number of intersection curves output.
			  Includes all intersecting surfaces of either
                          of the objects.

    my_inters		- The output linked-list of struct EMSinters that
			  contains the intersections on this object.

    other_inters	- The output linked-list of struct EMSinters that
			  contains the intersections on this object.

   For the symbolically defined constants used to make the options masks,
    see the file emssfintdef.h

  NOTES

    Before invoking the intersection method (other than the recursive or
    iterative invocations made by the intersection methods themselves)
    "*num_inters, *my_inters and *other_inters" SHOULD be set to 0 or NULL.
    On the other hand, if "my_inters or other_inters" is NULL (by value) then
    this method assumes that that particular list is not required and is
    thus ignored.

    It should borne in mind that when output is requested in the world
    coordinates, the output-intersection-lists (my_inters and other_inters),
    will have pointers to the SAME world-coordinate data, be they OM-objects
    or memory bufers. There are two parts to the output from this method.
    One, the carrier linked list that holds and organizes the intersection
    data and the other, the intersection data itself. To free this carrier
    linked list EMinters_free SHOULD be used. This function does not free
    the actual intersection data. To free the intersection data the function
    EMinters_data_free may be used.

    18-April-88 - SM:

    Upon output the more_info field in the EMinters structure points to the
    geometry of the corresponding surface. This memory will also be freed 
    via the function 'EMinters_data_free' with rest of the data.
    When the other_obj is a surface buffer the output list node points to
    the copy of that buffer. In such a case where the other_obj is a surface
    buffer the method assumes that the 'other_inters' list is properly
    positioned. In other words with surface buffers, the other object is
    assumed to be a simple surface (not a complex) and hence its intersection
    output will contain only one EMSinters node.

    26-April-88 - RV:

    The method EMget_int_data returns the intersection data such that the
    datatype of the xyz_data is consistent with the datatype of the 
    corresponding uv_data. So, the following combinations are currently
    possible for each surface.
      uv_data		        xyz_data	from EMget_int_data at

      2d polyline -----------	3d polyline	EMSsubbs, EMSproject
      3d curve    -----------	3d curve	EMSproject

    This is required for the parametric correspondence between
    the two data that is assumed by EMmap_trim_point. If the xyz_data is
    the same on the two surfaces, only one common set of xyz_data is returned
    by EMget_int_data (at EMSsubbs). Also, if the other surface is an
    infinite plane, only xyz_data is returned/relevant for it.
    Also, it is assumed that the two uv_data are directionally consistent.
    The bits returned in 'intinfo' by EMget_int_data are interpreted as :
      EMSintdata_samexyzdat	: only one common set of xyz data is
				  returned.
      EMSintdata_matcheddat	: the two surfaces have polyline data
				  with matching (interpolatable) spans.
    

  RETURN VALUES

    Upon exit the completion code will be one of the following:

      Success codes:
      - EMS_S_Success 
          if succeeded
      - EMS_I_NoIntersect
          if no intersections were found
      - EMS_I_Interrupt
          the intersection processing was interrupted externally before
          completion. The OM-status is OM_I_STOP_SENDING. This interrupt is
          handled only if the option is set in "trim_options".

      Error codes:
      - EMS_E_InvalidArg 
          if the input surface data is neither a surface-object, surface buffer
          or an infinite plane.
      - EMS_E_NoDynamicMemory
          if dynamic memory allocation was tried but failure occurred.
      - EMS_E_BSfail
          Call to a BS-math function returned error.
      - EMS_E_Fail
          Call to some EMS-math function returned an error.
      - EMS_E_SurfaceError
          Invocation of a surface method failed.
      - EMS_E_OMerror
          Invocation of a method on the input data failed or,
          Call to an OM-primitive failed.

  ALGORITHM

    This method could be invoked on a surface that exists by itself
    or is a component of a rigid, topologically ordered grouping (like
    a composite or an extended surface). If the object with which it's
    intersection needs to be computed happens to be another surface that
    is not a sub-surface (could be a composite or an extended surface),
    the message is sent to this other object to be handled; "my_id's info" is 
    put in place of "other_objinfo" and the output intersection-lists are
    reversed in their position. A return from such a send would have the
    intersections in the right places and this method is then ready to
    return.

    A check is made to see, if this intersection can be trivially rejected
    with a simple box-check. If not, the surface intersection math is called.
    According to the various options, the output is further processed and
    formatted. 

    The output arguments are appended to with each generation of data. At the
    time of return, the output arguments contain all the intersection 
    information.

  HISTORY

    SS  :  11/01/87  :  Creation
    SS  :  05/07/87  :  Changed the argument for other surface object to
                        a EMSdataselect, so as to handle surface buffers
                        and infinite planes.
    SM  :  15-April-88: Modified to return the geometry pointer in the
			'EMSinters' structure. 'Getgeom' is done instead
			of 'getabsg' since the geometry buffer is to
			be maintained.
    RV  :  05/25/88  :  Changed the BS-math call to a method call that
                        returns the intersection output in EMSdataselect
                        format. 
    SS  :  05/25/88  :  reorganized post-intersection processing to
			support dataselects and model-space curve-types.
    SM  :  17-Oct-88 :	The parametric intersection objects were being
			constructed in the same object space (that specified
			in the const_args), even if the two surfaces were
			in different object spaces. Fixed this by forcing
			the module environment used for the intersection
			data to be same as the corresponding surface.
    SS  :  05/23/89  :  Modified the significance of the orientation option
                        when specified with the world-option.
    SS  :  06/07/89  :  Fixed a bug for processing when no inters output
			is required, except whether an intersection exists
			or not.
    SS  :  07/28/89  :  If the other element for intersection being passed
                        in is this object itself, return an informational
                        code (EMS_I_InvalidArg).
    SS  :  09/17/89  :  Added the option to interrupt processing based
                        on the IGEstop().
    SM  :  18-Dec-89 :  Commented the unconditional call to 
			EFget_clipped_edge_type. Clipped edge type was being 
			used even if the entire intersection is in area.
			The function EMmkpyintdata gets the clipped edge
			type if appropriate.
  Inasu: June 12, 90 :  Increased the knot tolerance by 20 times so that
                        the degenerate surfaces would have reasonable ranges
                        for surface-surface intersection. This change would
                        eliminate memory faulting of the math function.
    NP  :  05/25/92  :  Added function calls for timing the code.
    NP  :  08/25/92  :  Modified for ANSI compliance. Moved static function
			declarations to global scope. Added typecasts.
    SM  :  10/11/92  :  Instead of using a hardcoded factor of 20 (see Inasu's
                        comment above), use the ratio 100 * (cht/bastol) as per
                        Dieter's recommendation.
    AIC :  04/16/93  :  Initialize intinfo so that in the event that it
                        is not allocated, it will be set to NULL during
                        wrapup.
    NP  :  04/21/93  :  UV polyline (EMSdata_poly2d) data (my &/or other) was 
                        not being deallocated. Tracked with the help of 
                        "Jack the Purifier".
    NP  :  05/27/93  :  Updated macro "ems$makeintlist" to reflect the addition
                        of two new parameters "cvtype_a" and "cvtype_b".
                        (Func. "EMmkintlist" has been renamed "EMmakeintlist", 
                         due to addition of the two new curve type parameters).
    SM  :  06/09/93  :  If the intersection data is degenerate in xyz space, 
                        set the EMED_DEGENERATE property on the corresponding
                        edge objects, just before the call to EMmakeintlist.
    SCW :  09/18/96  :  Commented out EMWRAPUP in chg_xyz_data function
*/


class implementation EMSsubbs;

#include "EMS.h"

#include "OMmacros.h"

#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"

#include "madef.h"
#include "godef.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "gocmacros.h"

#include "emsdef.h"
#include "emserr.h"
#include "emsdattyp.h"
#include "emsmacros.h"
#include "emsedgedef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "timerdef.h"
#include "EMStpmacros.h"
#include "emsdebug.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "EMSpwapi.h"
#include "PWapi/sfgeom.h"
#include "PWapi/sfdatint.h"
#include "PWapi/cvtype.h"
#include "PWapi/eded.h"

#define U 0
#define V 1

#define X 0
#define Y 1
#define Z 2

#define MYXYZ 0
#define MYUV  1
#define OTXYZ 2
#define OTUV  3

#define UMIN 0
#define VMIN 1
#define UMAX 2
#define VMAX 3

#define MY    0
#define OTHER 1

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;


%safe
static void get_maxbuff_trim(), chg_xyz_data(), search_and_get_geom();
extern IGRboolean _new_sfsfint_math, _use_infinite_plane, _use_timers;
extern IGRboolean _pathway_trim, _pathway_orient;
%endsafe

extern void EFget_coincident_edge();
from EMSedge import EMset_props;

method EMsfsfint (IGRlong *msg; IGRshort *mattyp; IGRmatrix mat;
                  struct GRvg_construct *const_args; 
                  struct EMSdataselect *other_data; 
                  struct GRmdenv_info *other_datenv;
                  IGRushort outworld_options;
                  IGRushort outparam_options;
                  IGRushort trim_options;
                  IGRlong *num_inters;
                  struct EMSinters **my_inters; 
                  struct EMSinters **other_inters)
{
  IGRboolean reverse_mydata=FALSE, reverse_otherdata=FALSE;
  IGRboolean output_world=FALSE, output_param=FALSE;
  IGRboolean world_obj=FALSE, param_obj=FALSE;
  IGRboolean orient_output=FALSE, orient_right=FALSE, orient_wrtnat=FALSE;
  IGRboolean trim=FALSE, typedcv=FALSE, flip_surfs=FALSE, handle_stop=FALSE;
  IGRboolean in_world_system = TRUE, nonoriented=FALSE;
  IGRboolean free_my_geom, free_other_geom;
  IGRchar *trmdatbuff;
  IGRuchar curve_type;
  IGRushort bdrytrm_options=NULL, my_props, other_props;
  IGRushort intinfo_loc, intinfo = 0, intopts;
  IGRshort props_subtype;
  IGRint stat_OM, i, j, datinx, dumdum, numpoles;
  IGRint num_grp, *num_bdrys, num_totbdrys; 
  IGRlong msg_loc, coinc_info;
  IGRdouble *my_range, **correl_params;
  IGRdouble my_uvrange[4], other_uvrange[4];
  IGRdouble tol, cht, bastol, chtfactor, uvrngtol_factor, xyz_chttol;
  GRrange range, other_range;
  GRclassid classid;
  IGRint retval;
  struct GRid my_obj, other_obj;
  struct GRmdenv_info my_datenv;
  struct GRmd_env my_mdenv, other_mdenv;
  struct GRvg_construct my_constargs, other_constargs;
  struct IGRbsp_surface *my_srf, *other_srf;
  struct IGRbsp_curve *cv;
  struct IGRpolyline *py;
  struct EMSdataselect my_data, my_uvintobj, other_uvintobj, xyzintobj;
  struct EMSdataselect *datasel, *my_xyz_data, *my_uv_data;
  struct EMSdataselect *other_xyz_data, *other_uv_data;
  struct EMSpypoint *mybdry, **mybdrys, *otbdry, **otbdrys, *p_pypt;
  struct EMSsfintedpar *mybdryp, **mybdryps, *otbdryp, **otbdryps;
  struct EMSsfintedpar *mymore_info, *otmore_info=NULL, *p_edpar;
  struct EMSpartolbasis my_partolbasis, other_partolbasis;
  struct EMSintobj *my_intobj, *p_intobj;
  enum  EMSdatatype other_type, dattyp;
  extern void EMgetuvorient();
  extern void EMsfintedpar_free(), EFtoggle();
  extern IGRboolean BSbxint(), BSbx2(), IGEstop();
  extern IGRboolean EFplace_line_string(), EMfirst_surf_simpler();
  extern IGRlong EMmkintdata();
  extern IGRlong EFget_clipped_edge_type();
  extern struct EMSpypoint *EMpypoint_malloc();

  struct EMSinters *p_inters=NULL;

/*************/
  struct EMSinters *my_inters_ptr;
  static IGRint num_coinc_stat=0;
  static IGRint **coinc_list_stat;
  IGRint ij;
  IGRint *list1=NULL, *list2=NULL;
/*************/
  
  if (_use_timers)
    start_timer (T_EMSFSFINT);
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  BSEXTRACTPAR(&msg_loc, BSTOLLENVEC, bastol);
  BSEXTRACTPAR(&msg_loc, BSTOLCHRDHT, cht);
  chtfactor = cht / bastol;
  uvrngtol_factor = 100 * chtfactor;

  /*
   * Initialize local variables
   */

  my_srf = NULL;
  other_srf = NULL;
  num_bdrys = NULL;
  mybdrys = NULL;
  mybdryps = NULL;
  otbdrys = NULL;
  otbdryps = NULL;
  trmdatbuff = NULL;
  num_grp = 0;
  my_uv_data = NULL;
  other_uv_data = NULL;
  my_xyz_data = NULL;
  other_xyz_data = NULL;
  correl_params = NULL;
  free_my_geom = TRUE;
  free_other_geom = TRUE;

  other_type = other_data->datatype;
  if (other_type != EMSdata_object && other_type != EMSdata_surface &&
      other_type != EMSdata_plane)
    EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, ret_end);

  if (other_type == EMSdata_object)
    {
    other_obj = *other_data->data.object;
    EMerr_hndlr (IF_EQ_OBJID (other_obj.objid, my_id) && 
     other_obj.osnum == OM_Gw_current_OS, *msg, EMS_I_InvalidArg, ret_end);
    }
  else
    other_obj.objid = NULL_OBJID;
  
  if (other_type == EMSdata_plane)
    other_inters = NULL;

  /*
   * Check if the user has indicated to stop processing. If so, exit 
   * by setting the return codes to stop processing.
   */

  handle_stop = trim_options & EMSINT_TRIM_HANDLESTOP;
  if (handle_stop && IGEstop())
    {
    *msg = EMS_I_Interrupt;
    stat_OM = OM_I_STOP_SENDING;
    goto ret_end;
    }

  /*
   * If the other object is more complex than
   * myself, the message is redirected for the other
   * to further handle it. If the other object is also
   * a simple surface, then the intersection can be performed.
   */

  if (other_type == EMSdata_object)
    {
    om$get_classid (objid = other_obj.objid, osnum = other_obj.osnum,
     p_classid = &classid);
    if (om$is_ancestry_valid (subclassid = classid,
         superclassid = OPP_EMSsubbs_class_id) == OM_S_SUCCESS)
      props_subtype = GRSS; 
    else
      props_subtype = _NULL; 
    }
  else
    props_subtype = GRSS;

  my_obj.objid = my_id;
  my_obj.osnum = OM_Gw_current_OS;
  my_data.datatype = EMSdata_object;
  my_data.data.object = &my_obj;

  if (props_subtype != GRSS)
    {
    my_datenv.matrix_type = *mattyp;
    OM_BLOCK_MOVE (mat, my_datenv.matrix, sizeof (IGRmatrix));
    EFtoggle (EMSINT_TRIM_OPSWITCHED, &trim_options);
    stat_OM = om$send (msg = message EMSsurface.EMsfsfint (msg, 
               &other_datenv->matrix_type, other_datenv->matrix,
               const_args, &my_data, &my_datenv, outworld_options,
               outparam_options, trim_options,
               num_inters, other_inters, my_inters),
               targetid = other_obj.objid, targetos = other_obj.osnum);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (*msg), *msg, EMS_E_SurfaceError, ret_end);
    }
  else
    {
    /*
     * Check if the ranges intersect. If not then
     * simply exit. If they do, then proceed further.
     */

    if (_use_timers)
      start_timer (T12_GETRANGE);

    my_range = range;
    stat_OM = om$send (msg = message GRvg.GRgetrang (&msg_loc, 
               mattyp, mat, &in_world_system, my_range),
               targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

    if (other_type == EMSdata_object)
      {
      stat_OM = om$send (msg = message GRvg.GRgetrang (&msg_loc, 
                 &other_datenv->matrix_type, other_datenv->matrix, 
                 &in_world_system, other_range),
                 targetid = other_obj.objid, targetos = other_obj.osnum);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
      }
    else if (other_type == EMSdata_surface)
      {
      numpoles = other_data->data.surface->u_num_poles *
                  other_data->data.surface->v_num_poles;
      BSbx2 (&msg_loc, &numpoles, other_data->data.surface->poles,
             !other_data->data.surface->rational ? NULL :
             other_data->data.surface->weights, &other_range[0], 
             &other_range[3]);
      }
    else
      for (i=0; i<6; i++)
        other_range[i] = (i<3 ? -MAXDOUBLE : MAXDOUBLE);

    if (_use_timers)
      stop_timer (T12_GETRANGE, FALSE, "");

    if (!_use_infinite_plane &&
        !BSbxint (&msg_loc, &my_range[0], &my_range[3], &other_range[0],
                  &other_range[3]))
      goto ret_end;

    /*
     * Get the abstract geometries of both these surfaces. The abstract
     * geometry should be held in memory that can potentially be
     * tagged onto the EMSinters node (ie, independently deallocateable
     * memory).
     */

    if (other_type == EMSdata_object)
      {
      search_and_get_geom (&msg_loc, other_inters ? *other_inters : NULL, 
       &other_srf, other_obj, &other_datenv->matrix_type, 
       other_datenv->matrix, &free_other_geom);
      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
      }
    else if (other_type == EMSdata_surface)
      {
      free_other_geom = FALSE;
      if (!other_inters)
        other_srf = other_data->data.surface;
      else
        {
        if (*other_inters && (*other_inters)->more_info) 
          other_srf = (struct IGRbsp_surface *) (*other_inters)->more_info;
        else
          {
          EMsfalloc_copy (&msg_loc, other_data->data.surface, &other_srf);
          EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
          }
        }
      }

    search_and_get_geom (&msg_loc, my_inters ? *my_inters : NULL, 
     &my_srf, my_obj, mattyp, mat, &free_my_geom);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

    /*
     * Obtain the partolbasis for
     * the two surfaces. 
     */

    ems$sspbtol_by_geom (msg = &msg_loc, surface = my_srf,
     partolbasis = &my_partolbasis.tol);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
    my_partolbasis.is_valid = TRUE;

    if (other_srf)
      {
      ems$sspbtol_by_geom (msg = &msg_loc, surface = other_srf,
       partolbasis = &other_partolbasis.tol);  
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
      other_partolbasis.is_valid = TRUE;
      }
    else 
      {
      other_partolbasis.is_valid = FALSE;
      other_partolbasis.tol = 0.0;
      }

    /*
     * Obtain the ranges of the surfaces in uv-space to restrict the
     * search space for the intersection computation. If the other 
     * surface is a plane-definition, no uv-range is required for it.
     */

    stat_OM = om$send (msg = message EMSsubbs.EMgetuvrange (&msg_loc, 
               my_uvrange), targetid = my_id);
    EMomerr_exit (stat_OM, ret_end);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
    tol = uvrngtol_factor * my_partolbasis.tol;
    for (i=UMIN; i<=VMAX; i++)
      {
      if (i <= VMIN)
        {
        if (my_uvrange[i] - tol < 0.0)
          my_uvrange[i] = 0.0;
        else
          my_uvrange[i] -= tol;
        }
      else
        {
        if (my_uvrange[i] + tol > 1.0)
          my_uvrange[i] = 1.0;
        else
          my_uvrange[i] += tol;
        }
      }

    if (other_type == EMSdata_object)
      {
      stat_OM = om$send (msg = message EMSsubbs.EMgetuvrange (&msg_loc, 
                 other_uvrange), targetid = other_obj.objid,
                 targetos = other_obj.osnum);
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

      if (other_partolbasis.is_valid)
        {
        tol = uvrngtol_factor * other_partolbasis.tol;

        for (i=UMIN; i<=VMAX; i++)
          {
          if (i <= VMIN)
            {
            if (other_uvrange[i] - tol < 0.0)
              other_uvrange[i] = 0.0;
            else
              other_uvrange[i] -= tol;
            }
          else
            {
            if (other_uvrange[i] + tol > 1.0)
              other_uvrange[i] = 1.0;
            else
              other_uvrange[i] += tol;
            }
          }
        }
      }
    else
      {
      other_uvrange[UMIN] = 0.0;
      other_uvrange[VMIN] = 0.0;
      other_uvrange[UMAX] = 1.0;
      other_uvrange[VMAX] = 1.0;
      }

    /*
     * Get the intersection data. The message is sent to the more complex
     * object. If the input data to be intersected against is not an object,
     * this question does not arise.
     */

    if (!_pathway_trim)
    {
      if (other_data->datatype == EMSdata_object && !_new_sfsfint_math)
        flip_surfs = EMfirst_surf_simpler (my_srf, other_srf);
      else
        flip_surfs = FALSE;
    }

    if (trim_options & EMSINT_TRIM_MOREPRECISE)
      intopts = EMS_INTER_MOREPRECISE;
    else
      intopts = NULL;
    if (! (trim_options & EMSINT_TRIM_OUTPUT) &&
        ! (outparam_options & EMSINT_ORIENT_OUTPUT ||
           outworld_options & EMSINT_ORIENT_OUTPUT))
      intopts |= EMS_INTER_BSPCURVES;

    if (_use_timers)
      start_timer (T12_GET_INT_DATA);

    if (!_pathway_trim)
    {
      if (flip_surfs)
      {
        pwDebugLine (PW_K_DebugTrace, "EMsssfsfint: %d %d\n",
         my_id, other_obj.objid);
        stat_OM = om$send (msg = message EMSsubbs.EMget_int_data (&msg_loc, 
                   intopts, &my_data, other_srf, my_srf,
                   other_uvrange, my_uvrange,
                   &other_partolbasis, &my_partolbasis, &num_grp,
                   &other_xyz_data, &my_xyz_data, &other_uv_data, &my_uv_data,
                   &correl_params, (IGRchar *) &curve_type, &intinfo),
                   targetid = other_obj.objid, targetos = other_obj.osnum);
      }
      else
      {
        pwDebugLine (PW_K_DebugTrace, "EMsssfsfint: %d %d\n",
         my_id, other_obj.objid);
        stat_OM = om$send (msg = message EMSsubbs.EMget_int_data (&msg_loc, 
                   intopts, other_data, my_srf, other_srf,
                   my_uvrange, other_uvrange,
                   &my_partolbasis, &other_partolbasis, &num_grp, &my_xyz_data,
                   &other_xyz_data, &my_uv_data, &other_uv_data, 
                   &correl_params, (IGRchar *) &curve_type, &intinfo), 
                   targetid = my_id);
      }
      EMomerr_exit (stat_OM, ret_end);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
    }
    else
    {
      PWresult result;
      struct PWsfdata sf1, sf2;
      struct BSgeom_bsp_surf gmsf1, gmsf2;
      struct PWcvdata *xyzcvs1=NULL, *uvcvs1=NULL, *xyzcvs2=NULL, *uvcvs2=NULL;
      
      sf1.datatype = PWsfdata_gmbspsf;
      pwSfAsGeomBspline (my_id, OS, my_srf, &gmsf1);
      sf1.data.p_gmbspsf = &gmsf1;

      sf2.datatype = PWsfdata_gmbspsf;

   /******************
             modified by V.Srinivas
                other_obj.osnum is replaced for OS  *************/

      pwSfAsGeomBspline (other_obj.objid, other_obj.osnum, other_srf, &gmsf2);
      sf2.data.p_gmbspsf = &gmsf2;

      pwDebugLine (PW_K_DebugTrace, "EMsssfsfint: %d %d\n",
       my_id, other_obj.objid);
      result = pwSfdataIntersect (&sf1, &sf2, TRUE, FALSE, &num_grp, 
                &xyzcvs1, &uvcvs1, &xyzcvs2, &uvcvs2);
      OnErrorCode (result, loc_ret_end);
      if (num_grp)
      {
        /*
         * Obtain the 'intinfo' -- whether the uv-datas are matched, whether
         * the xyzdatas are the same.
         */

        intinfo = NULL;
        if (xyzcvs1 == xyzcvs2)
          intinfo |= EMSintdata_samexyzdat;
        if (uvcvs1[0].datatype == PWcvdata_py2d && 
            uvcvs2[0].datatype == PWcvdata_py2d)
          intinfo |= EMSintdata_matcheddat;

        /*
         * Obtain the 'curve_type'
         */

        if (xyzcvs1[0].datatype == PWcvdata_gmbspcv ||
            xyzcvs2[0].datatype == PWcvdata_gmbspcv)
        {
          short bscvtype;
          PWboolean homog;
          struct PWcvdata *p_cvs;

          p_cvs = xyzcvs1[0].datatype == PWcvdata_gmbspcv ? xyzcvs1 : xyzcvs2;
          bscvtype = p_cvs[0].data.p_gmbspcv->type;
          for (i=1, homog=TRUE; i<num_grp && homog; i++)
            if (p_cvs[i].data.p_gmbspcv->type != bscvtype)
              homog = FALSE;
          if (!homog)
            curve_type = EMfreeform_curve;
          else
            curve_type = pwEMSCvType (bscvtype);
        }
        else
        {
          if (xyzcvs1[0].data.py.num_pts == 2)
            curve_type = EMlinesegment;
          else
            curve_type = EMlinestring;
        }

        /*
         * Reformat into old EMS dataselects
         */

        my_xyz_data = (struct EMSdataselect *) malloc (num_grp *
                          sizeof (struct EMSdataselect));
        if (xyzcvs1 != xyzcvs2)
          other_xyz_data = (struct EMSdataselect *) malloc (num_grp *
                         sizeof (struct EMSdataselect));
        else
          other_xyz_data = my_xyz_data;
        my_uv_data = (struct EMSdataselect *) malloc (num_grp *
                      sizeof (struct EMSdataselect));
        other_uv_data = (struct EMSdataselect *) malloc (num_grp *
                         sizeof (struct EMSdataselect));
        OnErrorState (!my_xyz_data || !other_xyz_data || !my_uv_data || 
         !other_uv_data, result, SetError (PW_K_Pathway, PW_K_Memory), 
         loc_ret_end);

        for (i=0; i<num_grp; i++)
        {
          pwMoveCvdataEMS (&xyzcvs1[i], &my_xyz_data[i]);
          if (xyzcvs1 != xyzcvs2)
            pwMoveCvdataEMS (&xyzcvs2[i], &other_xyz_data[i]);
          pwMoveCvdataEMS (&uvcvs1[i], &my_uv_data[i]);
          pwMoveCvdataEMS (&uvcvs2[i], &other_uv_data[i]);
        }

        msg_loc = EMS_S_Success;
      }
      else if (GetCode (result) == PW_K_Coincident)
      {
        msg_loc = EMS_I_Coincident;
      }

      loc_ret_end:
      pwSfdataIntersectFree (num_grp, xyzcvs1, uvcvs1, xyzcvs2, uvcvs2);

      PW_WrapupIdId (result, "EMsfsfint: pwSfdataIntersect", 
       my_id, other_obj.objid);

      if (IsError (result))
      {
        *msg = EMS_E_Fail;
        goto ret_end;
      }
    }
    coinc_info = msg_loc;
   
/****   coinc surface boolean processing 05/31 Nirmal **********

Collection of coincident surface information info for later use :

 1. Here the coincident surfce  ids are collected in a two dim
    static array, until the inters list is created.
 2. Once the inters list is created, the memmory is allocated
    for the num_coincs, and coinc_info_list fields of the inters list.
 3. and the static 2-D list of surf ids are copied to the inters list's
    list.
 4. Then the static list coinc_list_stat is deallocated and forgotten.
 5. From then on only the Inters_list's list is used to store the data.
 
************************************************************/

    {
    IGRint *num_coinc_loc= NULL;
    IGRint **coinc_list= NULL;

     if (msg_loc == EMS_I_Coincident )
      {
      my_inters_ptr = my_inters ? *my_inters : NULL;

       num_coinc_loc = &num_coinc_stat;
       coinc_list = coinc_list_stat;

       if(my_inters_ptr != NULL)
         {
          if(my_inters_ptr->num_coincs != NULL &&
                my_inters_ptr->coinc_info_list != NULL)
             {
              num_coinc_loc = my_inters_ptr->num_coincs;
              coinc_list = my_inters_ptr->coinc_info_list;
              num_coinc_stat=0;
              coinc_list_stat = NULL;
             }
         }
       
       if(*num_coinc_loc == 0)
         {
         coinc_list_stat = (IGRint **) om$malloc(size = 2*sizeof(IGRint *) );

         list1 = (IGRint *)om$malloc (size = 20 *sizeof(IGRint));
         EMerr_hndlr (!list1, *msg, EMS_E_NoDynamicMemory, ret_end);
         list2 = (IGRint *)om$malloc (size = 20 *sizeof(IGRint));
         EMerr_hndlr (!list2, *msg, EMS_E_NoDynamicMemory, ret_end);
         coinc_list_stat[0] = list1;
         coinc_list_stat[1] = list2;

         coinc_list = coinc_list_stat;
         }
       else if(*num_coinc_loc >= 20)
         {
         coinc_list[0]=(IGRint *)om$realloc(ptr= (IGRchar *)coinc_list[0],
                                size = (*num_coinc_loc +1) * sizeof(IGRint *) );
         EMerr_hndlr (!coinc_list[0], *msg, EMS_E_NoDynamicMemory, ret_end);
         coinc_list[1] = (IGRint *) om$realloc(ptr= (IGRchar *)coinc_list[1],
                                size = (*num_coinc_loc +1) * sizeof(IGRint *) );
         EMerr_hndlr (!coinc_list[1], *msg, EMS_E_NoDynamicMemory, ret_end);
         }

       coinc_list[0][*num_coinc_loc] = my_id;
       coinc_list[1][*num_coinc_loc] = other_obj.objid;
       (*num_coinc_loc)++;
      }

    }
/****   coinc surface bool processing 05/31 Nirmal **********/

    if (_use_timers)
      stop_timer (T12_GET_INT_DATA, FALSE, "");

    /*
     * Further processing takes place if there were any intersections
     * returned at all.
     */

    if (num_grp)
      { 
      /* 
       * Obtain the various options into local variables.
       */

      if (output_world = outworld_options & EMSINT_OUTPUT_WORLD)
        {
        world_obj = outworld_options & EMSINT_WORLD_OBJECT;
        typedcv = !(outworld_options & EMSINT_WORLD_NOTYPEDCV);
        }
      if (output_param = outparam_options & EMSINT_OUTPUT_PARAM)
        param_obj = outparam_options & EMSINT_PARAM_OBJECT;
      if (orient_output = (outparam_options & EMSINT_ORIENT_OUTPUT ||
                           outworld_options & EMSINT_ORIENT_OUTPUT))
          {
          orient_right = (outparam_options & EMSINT_ORIENT_OUTPUT &&
                          outparam_options & EMSINT_ORIENT_RIGHT) ||
                         (outworld_options & EMSINT_ORIENT_OUTPUT &&
                          outworld_options & EMSINT_ORIENT_RIGHT);
          orient_wrtnat = outparam_options & EMSINT_ORIENT_OUTPUT;
          }
      if (trim = trim_options & EMSINT_TRIM_OUTPUT)
        {
        bdrytrm_options = EMS_INTER_USECHTTOL;
        bdrytrm_options |= (trim_options & EMSINT_TRIM_BDRYISAREA ?
                            EMS_INTER_BDRYISAREA : NULL);
        bdrytrm_options |= (trim_options & EMSINT_TRIM_MOREPRECISE ?
                            EMS_INTER_MOREPRECISE : NULL);
        bdrytrm_options |= (trim_options & EMSINT_TRIM_PROCOVERLAP ?
                            EMS_INTER_PROCOVERLAP : NULL);
        bdrytrm_options |= (handle_stop ? EMS_INTER_HANDLESTOP : NULL);
        }
      if (!my_inters && !other_inters)
        {
        output_world = FALSE;
        output_param = FALSE;
        }

      if (output_world || output_param || trim)
        {
        /*
         * The intersections are to be output and/or a trim
         * has to be performed. Some preliminary treatment
         * is done on various pieces going to make the output.
         */

        if (trim)
          {
           /* start timer for EMfulltrim. If uv-data is NOT needed on the OTHER
            * surface, then this measures the time for EMparttrim on THIS 
            * surface.
            */
           if (_use_timers)
             start_timer (T12_FULLTRIM);

          /*
           * If the trim option has been specified, the 
           * intersections returned by math would have to
           * be trimmed w.r.t. boundaries on both surfaces.
           * This is done by passing on the uv-data obtained
           * on either surfaces, for each surface to the "fulltrim"
           * method. 
           *
           * Each member of the group could potentially be broken up
           * into an indefinite number of sub-groups denoted by boundaries
           * (or bdrys). The "num_bdrys" array holds the number of bdrys
           * for each group. "mybdrys" and "otbdrys" arrays holds the pointer
           * to the linked list of EMSpypoint structures, whose elements taken
           * in pairs, constitute the boundaries on the polyline.
           * The "num_bdrys" for a certain group could be zero, which
           * would imply that the entire group is trimmed off. If
           * "num_bdrys" for all the groups happens to be zero, then no 
           * intersection is to be output. Hence this method may exit with
           * no further work.
           */

          num_bdrys = (IGRint *) om$malloc (size = num_grp * 
                       sizeof (IGRint));
          mybdrys = (struct EMSpypoint **) om$malloc (size = num_grp *
                     sizeof (struct EMSpypoint *));
          mybdryps = (struct EMSsfintedpar **) om$malloc (size = num_grp *
                      sizeof (struct EMSsfintedpar *));
          EMerr_hndlr (!num_bdrys || !mybdrys || !mybdryps, *msg,
           EMS_E_NoDynamicMemory, ret_end);

          if (other_uv_data)
            {
            otbdrys = (struct EMSpypoint **) om$malloc (size = num_grp *
                       sizeof (struct EMSpypoint *));
            otbdryps = (struct EMSsfintedpar **) om$malloc (size = num_grp *
                       sizeof (struct EMSsfintedpar *));
            EMerr_hndlr (!otbdrys || !otbdryps, *msg,
             EMS_E_NoDynamicMemory, ret_end);
            }
  
          for (i=0; i<num_grp; i++)
	    {
	    mybdrys[i] = NULL;
            mybdryps[i] = NULL;
            if (other_uv_data)
              {
              otbdrys[i] = NULL;
              otbdryps[i] = NULL;
              }
	    num_bdrys[i] = 0;
	    }

          if (other_uv_data)
            bdrytrm_options |= (intinfo & EMSintdata_matcheddat ? 
                                EMS_INTER_MATCHEDINTDAT : NULL);
          num_totbdrys = 0;
          for (i=0; i<num_grp; i++)
            {
            if (other_uv_data)
              {
              stat_OM = om$send (msg = message EMSsubbs.EMfulltrim
                         (&msg_loc, mattyp, mat, &my_uv_data[i],
			 &my_xyz_data[i], my_srf, &my_partolbasis,
                         other_data, other_datenv, 
			 &other_uv_data[i], &other_xyz_data[i], other_srf, 
			 &other_partolbasis, 
                         correl_params ? correl_params[i] : NULL,
                         bdrytrm_options, &num_bdrys[i], 
                         &mybdrys[i], &mybdryps[i], &otbdrys[i], &otbdryps[i]),
                         targetid = my_id);
              EMomerr_exit (stat_OM, ret_end);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError,
               ret_end);
              if (msg_loc == EMS_I_Interrupt)
                {
                *msg = msg_loc;
                stat_OM = OM_I_STOP_SENDING;
                goto ret_end;
                }
              }
            else
              {
              stat_OM = om$send (msg = message EMSsubbs.EMparttrim
                         (&msg_loc, mattyp, mat, &my_uv_data[i], 
			 bdrytrm_options, &num_bdrys[i], &mybdrys[i],
                         &mybdryps[i]), targetid = my_id);
              EMomerr_exit (stat_OM, ret_end);
              EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError,
               ret_end);
              if (msg_loc == EMS_I_Interrupt)
                {
                *msg = msg_loc;
                stat_OM = OM_I_STOP_SENDING;
                goto ret_end;
                }
              }

            num_totbdrys += num_bdrys[i];
            }
          if (!num_totbdrys)
            goto ret_end;
          else
            dumdum = num_totbdrys;
        
          
           /* stop timer for EMfulltrim */
           if (_use_timers)
             stop_timer (T12_FULLTRIM, FALSE, "");

          }
        else
          dumdum = num_grp;
        *num_inters += dumdum;

        if (output_world || output_param)
          {

          /* start timer for orient, mkintdata and mkintlist combined */
          if (_use_timers)
            start_timer(T12_ORIENT_AND_MKINTDATA);

          /*
           * Prepare the construction-list structures so that if objects
           * are desired, they are constructed in their respective
           * environments.
           */

          my_mdenv.md_env.matrix_type = *mattyp;
          OM_BLOCK_MOVE(mat, my_mdenv.md_env.matrix, sizeof(IGRmatrix));
          my_mdenv.md_id.objid = NULL_OBJID;
          my_mdenv.md_id.osnum = OM_Gw_current_OS;

          if (const_args)
            my_constargs = *const_args;
          my_constargs.env_info = &my_mdenv;

          if (other_datenv)
            other_mdenv.md_env = *other_datenv;
          else
            other_mdenv.md_env = my_mdenv.md_env;
          other_mdenv.md_id.objid = NULL_OBJID;
          if (other_type == EMSdata_object)
            other_mdenv.md_id.osnum = other_obj.osnum;
          else
            other_mdenv.md_id.osnum = OM_Gw_current_OS;

          if (const_args)
            other_constargs = *const_args;
          other_constargs.env_info = &other_mdenv;

          /*
           * Begin the processing for outputting
           * the results. All the code from this point
           * down to the comment line that signals
           * the end of output processing, is devoted
           * solely to this purpose.
           */

          if (trim && (world_obj || param_obj))
            {
            /*
             * Get the maximum number of points that would
             * be output in any of the trimmed curves.
             * Allocate space to hold this maximum.
             */

            if (world_obj)
              get_maxbuff_trim (&msg_loc, num_grp, my_xyz_data, 
               other_xyz_data, &trmdatbuff);
            else
              get_maxbuff_trim (&msg_loc, num_grp, my_uv_data, 
               other_uv_data, &trmdatbuff);
            EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
            }

          for (i=0; i<num_grp; i++)
            {
            /*
             * For every intersection curve that has
             * to be output, do the following.
             */

            reverse_mydata = FALSE;
            reverse_otherdata = FALSE;
            nonoriented = FALSE;

            /* 
             * If pathway orientation toggle is set, then don't orient the 
             * intersections now. This will be done towards the end of the
             * function by a call to pathway.
             */

            if (orient_output && (trim ? num_bdrys[i] : TRUE) &&
                !(_pathway_orient))
              {
              /*
               * Each piece of intersection data that is output
               * is correctly oriented. This orientation ensures that the
               * intersection curves, when traversed, will have the outward
               * normal of the "other_surface" either to the left or the 
               * right, depending on whether the option orient_right is TRUE
               * or FALSE. The right or left is determined wrt to a person
               * standing on the surface aligned either with the natural
               * normal or the oriented normal. EMgetuvorient obtains the 
               * intersection wrt the natural normal. So if the orientation
               * has to be done wrt the oriented normal, toggle the orientation
               * if "pos_orient" is off on a given surface.
               */


              if (other_srf && other_uv_data)
                {
                EMgetuvorient (&msg_loc, my_srf, other_srf, 
                 &my_uv_data[i], &other_uv_data[i], &my_xyz_data[i],
                 &other_xyz_data[i],
                 orient_right, &reverse_mydata, &reverse_otherdata);
                EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                if (msg_loc == EMS_I_IntersectOrient)
                  nonoriented = TRUE;
                else if (!orient_wrtnat)
                  {
                  if (!my_srf->pos_orient)
                    reverse_mydata = !reverse_mydata;
                  if (!other_srf->pos_orient)
                    reverse_otherdata = !reverse_otherdata;
                  }
                }
              }

            if (trim)
              {
              /*
               * For every group there might be num_bdrys[i] number
               * of trimmed curves to be output. Each of these trimmed
               * curves can be processed by the function EMmkintdata. The
               * curve-type is the clipped curve-type.
               * Caveat: If the intinfo indicates iso-edges and other-data
               * is present but neither one of them contains a BS-curve,
               * ignore the iso-information.
               */
  
              mybdry = mybdrys[i];
              mybdryp = mybdryps[i];
              if (other_uv_data)
                {
                otbdry = otbdrys[i];
                otbdryp = otbdryps[i];
                }
              else
                {
                otbdry = NULL;
                otbdryp = NULL;
                }

              for (j=0; j<num_bdrys[i]; j++)
                {
                my_props = nonoriented ? EMSintobj_nonoriented : NULL;
                other_props = nonoriented ? EMSintobj_nonoriented : NULL;

                intinfo_loc = NULL;
                if (intinfo & EMSintdata_isoedge &&
                    (my_uv_data[i].datatype == EMSdata_curve3d ||
                     (other_uv_data && 
                      other_uv_data[i].datatype == EMSdata_curve3d)))
                  intinfo_loc = EMSintdata_isoedge;

                if (output_param)
                  {
                  tol = chtfactor * my_partolbasis.tol;
                  stat_OM = EMmkintdata (&msg_loc, &my_uv_data[i],
                             curve_type, intinfo_loc, FALSE, mybdry,
                             &my_constargs, param_obj, &tol,
                             param_obj ? trmdatbuff : NULL, &my_uvintobj);
                  EMomerr_exit (stat_OM, ret_end);
                  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                  if (msg_loc == EMS_I_Degenerate)
                    my_props |= EMSintobj_uvdegenerate;

                  if (other_uv_data)
                    {
                    tol = chtfactor * other_partolbasis.tol;
                    stat_OM = EMmkintdata (&msg_loc, &other_uv_data[i], 
                               curve_type, intinfo_loc, FALSE, otbdry,
                               &other_constargs, param_obj, &tol,
                               param_obj ? trmdatbuff : NULL,
                               &other_uvintobj);
                    EMomerr_exit (stat_OM, ret_end);
                    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                    if (msg_loc == EMS_I_Degenerate)
                      other_props |= EMSintobj_uvdegenerate;
                    }
                  else
                    other_uvintobj.datatype = EMSdata_null;
                  }
                else
                  {
                  my_uvintobj.datatype = EMSdata_null;
                  other_uvintobj.datatype = EMSdata_null;
                  }

                if (output_world)
                  {
                  /*
                   * The model-space intersection curves on the two surfaces 
                   * have a one-to-one match with the respective uv-space
                   * curves. One of them has to be a polyline. The decision to
                   * output the model-curve from "my data" or "other data" is
                   * based on three things:
                   *   a) whether "other data" is present at all,
                   *   b) whether a "typed curve" (when available)
                   *      must be returned, and
                   *   c) what contains the "poly data".
                   * The trim points in this space are obtained from those
                   * boundary components that are the result of primary
                   * trimming (ie, actual trimming against a boundary as
                   * opposed to transfer of a trim point from one surface's
                   * data to another). Whether a trim point is a result of
                   * primary trimming or not is indicated in the props-field.
                   */


                  chg_xyz_data (&msg_loc, my_srf, mybdry, other_srf, otbdry,
                   &my_xyz_data[i], &other_xyz_data[i], 2);
                  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

                  dattyp = other_xyz_data[0].datatype;
                  if (other_xyz_data && 
                      (typedcv ? dattyp != EMSdata_poly3d :
                                 dattyp ==  EMSdata_poly3d))
                    {
                    stat_OM = EMmkintdata (&msg_loc, &other_xyz_data[i], 
                               curve_type, intinfo_loc, TRUE, otbdry,
                               const_args, world_obj, &cht, 
                               world_obj ? trmdatbuff : NULL, &xyzintobj);
                    EMomerr_exit (stat_OM, ret_end);
                    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                    }
                  else
                    {
                    stat_OM = EMmkintdata (&msg_loc, &my_xyz_data[i], 
                               curve_type, intinfo_loc, TRUE, mybdry,
                               const_args, world_obj, &cht, 
                               world_obj ? trmdatbuff : NULL, &xyzintobj);
		    EMomerr_exit (stat_OM, ret_end);
                    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                    }
                  if (msg_loc == EMS_I_Degenerate)
                    {
                    my_props |= EMSintobj_xyzdegenerate;
                    other_props |= EMSintobj_xyzdegenerate;
                    }


                  }
                else
                  xyzintobj.datatype = EMSdata_null;

                if (mybdry->props & EMS_PYPT_ENDMARKER)
                  my_props |= reverse_mydata ?
                   EMSintobj_fwd_noconnectuv : EMSintobj_bwd_noconnectuv;
                if (mybdry->next->props & EMS_PYPT_ENDMARKER)
                  my_props |= reverse_mydata ?
                   EMSintobj_bwd_noconnectuv : EMSintobj_fwd_noconnectuv;
                if (otbdry)
                  {
                  if (otbdry->props & EMS_PYPT_ENDMARKER)
                    other_props |= reverse_otherdata ?
                     EMSintobj_fwd_noconnectuv : EMSintobj_bwd_noconnectuv;
                  if (otbdry->next->props & EMS_PYPT_ENDMARKER)
                    other_props |= reverse_otherdata ?
                     EMSintobj_bwd_noconnectuv : EMSintobj_fwd_noconnectuv;
                  }

                mymore_info = mybdryp;
                mybdryp = mybdryp->next->next;
                mymore_info->next->next = NULL;
                if (otbdryp)
                  {
                  otmore_info = otbdryp;
                  otbdryp = otbdryp->next->next;
                  otmore_info->next->next = NULL;
                  }
                /* If the data is degenerate in xyz, make sure the 
                   corresponding edge object is marked as such.
                   SM 6/9/93.
                */
                if(my_props & EMSintobj_xyzdegenerate)
                 {
	          if(my_uvintobj.datatype == EMSdata_object)
	           (void)om$send(msg = message EMSedge.EMset_props(&msg_loc, 
	           EMED_DEGENERATE, EMS_O_ON), 
	           targetid = my_uvintobj.data.object->objid);
	
	          if(other_uvintobj.datatype == EMSdata_object)
	           (void)om$send(msg = message EMSedge.EMset_props(&msg_loc, 
	           EMED_DEGENERATE, EMS_O_ON), 
	           targetid = other_uvintobj.data.object->objid);
                 }

                my_intobj = ems$makeintlist (msg = &msg_loc,
                               inters_a = my_inters,
                               inters_b = other_inters,
                               object_a = &my_obj,
                               object_b = &other_obj,
                               inters_moreinfo_a = (IGRchar *)my_srf,
                               inters_moreinfo_b = (IGRchar *)other_srf,
                               xyzintobject = &xyzintobj,
                               uvintobject_a = &my_uvintobj,
                               uvintobject_b = &other_uvintobj,
                               reversed_a = reverse_mydata,
                               reversed_b = reverse_otherdata,
                               moreinfo_a = (IGRchar *)mymore_info,
                               moreinfo_b = (IGRchar *)otmore_info,
                               props_a = my_props,
                               props_b = other_props,
                               cvtype_a = &curve_type,
                               cvtype_b = &curve_type);
                EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

                if (_pathway_trim)
                {
                  int i;
                  double tol, midpt[3];

                  for (i=MY, p_pypt=mybdry, p_edpar=mymore_info,
                        p_intobj=my_intobj, tol = my_partolbasis.tol;
                       i<=OTHER;
                       i++, p_pypt=otbdry, p_edpar=otmore_info,
                        p_intobj=my_intobj->other_intobj_node,
                        tol = other_partolbasis.tol)
                  if( (p_pypt->props & EMS_PYPT_START_OVERLAP &&
                        p_pypt->next->props & EMS_PYPT_STOP_OVERLAP) ||
                       (p_pypt->props & EMS_PYPT_STOP_OVERLAP &&
                        p_pypt->next->props & EMS_PYPT_START_OVERLAP) )
                  {
                      EMinternalpt (&msg_loc, NULL, NULL, 
                       &p_intobj->this_uvintobj, EMScvint_middle, 1, midpt);
                      EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);

                      p_intobj->coinced = pwGetInterveningEdge (OS,
                                 p_edpar->edgeid, 
                                 pwPWCvint (p_edpar->intloc),
                                 p_edpar->next->edgeid, 
                                 pwPWCvint (p_edpar->next->intloc),
                                 midpt, tol);
                  }
                }

/*******
                if (_pathway_orient)
                {
                  if( trim_options & EMSINT_TRIM_OPSWITCHED)
                    my_intobj = my_intobj->other_intobj_node;

                  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyz_chttol);
                  retval = pwComputeIntRels( my_intobj, xyz_chttol );
                }
*******/

   		free_my_geom = FALSE;
		free_other_geom = FALSE;

                mybdry = mybdry->next->next;
                mybdryps[i] = NULL;
                if (otbdry)
                  {
                  otbdry = otbdry->next->next;
                  otbdryps[i] = NULL;
                  }
                }
              }
            else 
              {
              /*
               * Non-trimmed intersection data needs to be output.
               * Caveat: If the intinfo indicates iso-edges and other-data
               * is present but neither one of them contains a BS-curve,
               * ignore the iso-information.
               */

              my_props = nonoriented ? EMSintobj_nonoriented : NULL;
              other_props = nonoriented ? EMSintobj_nonoriented : NULL;

              intinfo_loc = NULL;
              if (intinfo & EMSintdata_isoedge &&
                  (my_uv_data[i].datatype == EMSdata_curve3d ||
                   (other_uv_data &&
                    other_uv_data[i].datatype == EMSdata_curve3d)))
                intinfo_loc = EMSintdata_isoedge;

              if (output_param)
                {
                tol = chtfactor * my_partolbasis.tol;
                stat_OM = EMmkintdata (&msg_loc, &my_uv_data[i], 
                           curve_type, intinfo_loc, FALSE, NULL,
                           &my_constargs, param_obj, &tol,
                           NULL, &my_uvintobj);
                EMomerr_exit (stat_OM, ret_end);
                EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                if (msg_loc == EMS_I_Degenerate)
                  my_props |= EMSintobj_uvdegenerate;

                if (other_uv_data)
                  {
                  tol = chtfactor * other_partolbasis.tol;
                  stat_OM = EMmkintdata (&msg_loc, &other_uv_data[i], 
                             curve_type, intinfo_loc, FALSE, NULL,
                             &other_constargs, param_obj, &tol,
                             NULL, &other_uvintobj);
		  EMomerr_exit (stat_OM, ret_end);
                  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                  if (msg_loc == EMS_I_Degenerate)
                    other_props |= EMSintobj_uvdegenerate;
                  }
                else
                  other_uvintobj.datatype = EMSdata_null;
                }
              else
                {
                my_uvintobj.datatype = EMSdata_null;
                other_uvintobj.datatype = EMSdata_null;
                }

              if (output_world)
                {
                dattyp = other_xyz_data[0].datatype;
                if (other_xyz_data && 
                    (typedcv ? dattyp != EMSdata_poly3d :
                               dattyp == EMSdata_poly3d))
                  {
                  stat_OM = EMmkintdata (&msg_loc, &other_xyz_data[i], 
                             curve_type, intinfo_loc, TRUE, NULL,
                             const_args, world_obj, &cht, NULL, 
                             &xyzintobj);
                  EMomerr_exit (stat_OM, ret_end);
                  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                  }
                else
                  {
                  stat_OM = EMmkintdata (&msg_loc, &my_xyz_data[i], 
                             curve_type, intinfo_loc, TRUE, NULL,
                             const_args, world_obj, &cht, NULL, &xyzintobj);
		  EMomerr_exit (stat_OM, ret_end);
                  EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
                  }
                if (msg_loc == EMS_I_Degenerate)
                  {
                  my_props |= EMSintobj_xyzdegenerate;
                  other_props |= EMSintobj_xyzdegenerate;
                  }
                }
              else
                xyzintobj.datatype = EMSdata_null;

              /* If the data is degenerate in xyz, make sure the corresponding
                 edge object is marked as such.
                 SM 6/9/93.
              */
              if(my_props & EMSintobj_xyzdegenerate)
               {
	        if(my_uvintobj.datatype == EMSdata_object)
	         (void)om$send(msg = message EMSedge.EMset_props(&msg_loc, 
	         EMED_DEGENERATE, EMS_O_ON), 
	         targetid = my_uvintobj.data.object->objid);
	
	        if(other_uvintobj.datatype == EMSdata_object)
	         (void)om$send(msg = message EMSedge.EMset_props(&msg_loc, 
	         EMED_DEGENERATE, EMS_O_ON), 
	         targetid = other_uvintobj.data.object->objid);
               }

             ems$makeintlist (msg = &msg_loc,
                             inters_a = my_inters,
                             inters_b = other_inters,
                             object_a = &my_obj,
                             object_b = &other_obj,
                             inters_moreinfo_a = (IGRchar *)my_srf,
                             inters_moreinfo_b = (IGRchar *)other_srf,
                             xyzintobject = &xyzintobj,
                             uvintobject_a = &my_uvintobj,
                             uvintobject_b = &other_uvintobj,
                             reversed_a = reverse_mydata,
                             reversed_b = reverse_otherdata,
                             props_a = my_props,
                             props_b = other_props,
                             cvtype_a = &curve_type,
                             cvtype_b = &curve_type);
              EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
	      free_my_geom = FALSE;
	      free_other_geom = FALSE;
              }
            }

          /* stop timer for orient, mkintdata and mkintlist combined */
          if (_use_timers)
            stop_timer(T12_ORIENT_AND_MKINTDATA, FALSE, "");

          /*
           * End processing for outputting
           * the results.
           */
          }
        else
          {
          /*
           * No output is desired. The num_inters output variable has
           * already been updated. Since atleast one intersection has been
           * detected, no more computations need be performed.
           */

          stat_OM = OM_I_STOP_SENDING;
          goto ret_end;
          }
        }
      else
        {
        /*
         * Update the num_inters output variable even if
         * no output of the real intersections is asked for.
         * Since atleast one intersection has been detected,
         * no more computations need be performed.
         */

        *num_inters += num_grp;
        stat_OM = OM_I_STOP_SENDING;
        goto ret_end;
        }
      }
    else if (msg_loc == EMS_I_Coincident && 
             (trim_options & EMSINT_TRIM_COPLANAR) &&
             other_type == EMSdata_object)
      {
        /*
         * For pathway, we want to switch off the coincident plane processing.
         * We believe that, the intersections which are needed are always gen-
         * erated by the adjacent surfaces, in which case coincident plane pr-
         * cessing is not of use.
         */
        if (!(_pathway_trim && _pathway_orient))
        {
          if (_use_timers)
            start_timer (T12_BDRYINT);
        
          stat_OM = om$send (msg = message EMSsubbs.EMbdryint (&msg_loc, mattyp,
                    mat, const_args, &other_obj, other_datenv, outworld_options,
                    outparam_options, trim_options, num_inters, my_inters, 
                    other_inters), targetid = my_id);
          EMomerr_exit (stat_OM, ret_end);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

          if (_use_timers)
            stop_timer (T12_BDRYINT, FALSE, "");
        }
      }

  /*
   * If pathway orientation toggle is set, then we need to orient the
   * intersections between these two surfaces now. This will be done 
   * in the following block.
   */
  if ( _pathway_orient) 
  {
    p_inters = my_inters ? *my_inters : NULL;
    for ( ; p_inters; p_inters = p_inters->next)
    {
      if (p_inters->this_obj.objid == my_id)
        break;
    }
    p_intobj = (p_inters) ? p_inters->cvs : NULL;

    BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, xyz_chttol);
  
    for ( ; p_intobj; p_intobj = p_intobj->next)
    {
      if (p_intobj->other_intobj_node->this_obj_node->this_obj.objid 
          != other_obj.objid) 
        continue;

      if( trim_options & EMSINT_TRIM_OPSWITCHED)
        my_intobj = p_intobj->other_intobj_node;
      else
        my_intobj = p_intobj;
  
/********
      Once the coincident plane processing is switched ON, we need to release
      this block of code. It is because, coincident plane processing does not
      populate the coinced field of the intobj structure. This block tries to 
      fill this field.

      if( (coinc_info == EMS_I_Coincident) || !_pathway_trim )
      {
        if( (IF_NULL_OBJID(
               (( struct EMSsfintedpar *)my_intobj->more_info)->edgeid)) ||
            (IF_NULL_OBJID(
                ((struct EMSsfintedpar *)((struct EMSsfintedpar *)(my_intobj->
                  more_info))->next)->edgeid)) )
        {
          EMgetincinfo(&msg_loc, my_obj.osnum, 
                       &(my_intobj->this_uvintobj),
                       FALSE, NULL, mattyp, mat,
                       my_obj.objid, xyz_chttol, my_partolbasis.tol,
                       ( struct EMSsfintedpar *)my_intobj->more_info);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

          EMgetincinfo(&msg_loc, my_obj.osnum,
                       &(my_intobj->this_uvintobj),
                       TRUE, NULL, mattyp, mat,
                       my_obj.objid, xyz_chttol, my_partolbasis.tol,
                       ( struct EMSsfintedpar *)my_intobj->more_info);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

        }
     
        if( (IF_NULL_OBJID(
               (( struct EMSsfintedpar *)(my_intobj->other_intobj_node->
                  more_info))->edgeid))
              ||
            (IF_NULL_OBJID(
               ((struct EMSsfintedpar *)(( struct EMSsfintedpar *)(my_intobj->
                 other_intobj_node->more_info))->next)->edgeid)) )
        {
          EMgetincinfo(&msg_loc, other_obj.osnum,
                       &(my_intobj->other_intobj_node->this_uvintobj),
                       FALSE, NULL, mattyp, mat,
                       other_obj.objid, xyz_chttol, other_partolbasis.tol,
                       ( struct EMSsfintedpar *)my_intobj->other_intobj_node
                                               ->more_info);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

          EMgetincinfo(&msg_loc, other_obj.osnum,
                       &(my_intobj->other_intobj_node->this_uvintobj),
                       TRUE, NULL, mattyp, mat,
                       other_obj.objid, xyz_chttol, other_partolbasis.tol,
                       ( struct EMSsfintedpar *)my_intobj->other_intobj_node->
                                               more_info);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);

        }


        if( !(IF_NULL_OBJID( 
               (( struct EMSsfintedpar *)(my_intobj->more_info))->edgeid)) &&
            !(IF_NULL_OBJID( 
                ((struct EMSsfintedpar *)((struct EMSsfintedpar *)my_intobj->
                 more_info)->next)->edgeid)) )
        {
          EFget_coincident_edge( &msg_loc, NULL, mattyp, mat, NULL, NULL,
                                 my_intobj, &(my_intobj->coinced) );
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
        }
        if( !(IF_NULL_OBJID( 
               (( struct EMSsfintedpar *)(my_intobj->other_intobj_node->
                  more_info))->edgeid)) 
              &&
            !(IF_NULL_OBJID( 
            ((struct EMSsfintedpar *)(( struct EMSsfintedpar *)my_intobj->
             other_intobj_node->more_info)->next)->edgeid)) )
        {
          EFget_coincident_edge( &msg_loc, NULL, mattyp, mat, NULL, NULL,
                                 my_intobj->other_intobj_node, 
                                 &(my_intobj->other_intobj_node->coinced) );
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
        }
      }
***********coinc***/

      retval = pwComputeIntRels( my_intobj, xyz_chttol );
      EMerr_hndlr (EMSerror (retval), *msg, EMS_E_Fail, ret_end);
    } 
  }

/************** coinc surf bool 05/31 Nirmal ***************
Check to see if the inters lists have been created,
If so been, then allocate memory for the num_coincs and
coinc_info_list fields, copy the data from the local static
list and deallolcate the local static list.
************************************************************/


    if(my_inters != NULL && num_coinc_stat != 0 && coinc_list_stat != NULL )
     if(*my_inters )
      {
      IGRint num;

       my_inters_ptr = *my_inters;
       my_inters_ptr->num_coincs = (IGRint *)om$malloc(size = sizeof(IGRint));
       *(my_inters_ptr->num_coincs) = num_coinc_stat;

       my_inters_ptr->coinc_info_list = (IGRint **) om$malloc
                                          ( size = 2*sizeof(IGRint *) );

       num = (num_coinc_stat > 20) ? num_coinc_stat : 20;
       list1 = (IGRint *)om$malloc (size = num *sizeof(IGRint));
       EMerr_hndlr (!list1, *msg, EMS_E_NoDynamicMemory, ret_end);
       my_inters_ptr->coinc_info_list[0] = list1;

       list2 = (IGRint *)om$malloc (size = num *sizeof(IGRint));
       EMerr_hndlr (!list2, *msg, EMS_E_NoDynamicMemory, ret_end);
       my_inters_ptr->coinc_info_list[1] = list2;

       for(ij=0;ij< num_coinc_stat;ij++)
           {
           my_inters_ptr->coinc_info_list[0][ij] = coinc_list_stat[0][ij];
           my_inters_ptr->coinc_info_list[1][ij] = coinc_list_stat[1][ij];
           }

      if(other_inters)
        if(*other_inters)
       {
       (*other_inters)->coinc_info_list = my_inters_ptr->coinc_info_list;
       (*other_inters)->num_coincs = my_inters_ptr->num_coincs;
       }

       om$dealloc (ptr= coinc_list_stat[0]);
       om$dealloc (ptr= coinc_list_stat[1]);
       num_coinc_stat=0;
       coinc_list_stat = NULL;
      }
/************** coinc surf bool 05/31 Nirmal ***************/

    }

ret_end:
  /*
   * Deallocate all space that has been malloced
   * temporarily, if it hasn't already been
   * freed and if it is not required in the output.
   */
   
  if (my_srf && free_my_geom)
    om$dealloc (ptr = my_srf);
  if (other_srf && other_type == EMSdata_object && free_other_geom)
    om$dealloc (ptr = other_srf);

  for (i=0; i<num_grp; i++)
    {
    for (datinx=MYXYZ; datinx<=OTUV; datinx++)
      {
      if (datinx == MYXYZ && my_xyz_data)
        datasel = &my_xyz_data[i];
      else if (datinx == MYUV && my_uv_data)
        datasel = &my_uv_data[i];
      else if (datinx == OTXYZ && other_xyz_data && 
               other_xyz_data != my_xyz_data)
        datasel = &other_xyz_data[i];
      else if (datinx == OTUV && other_uv_data)
        datasel = &other_uv_data[i];
      else
        continue;

      dattyp = datasel->datatype;
      if ((dattyp == EMSdata_poly2d) || (dattyp == EMSdata_poly3d))
        {
        py = datasel->data.poly;
        om$dealloc (ptr = py->points);
        om$dealloc (ptr = py);
        }
      else if (dattyp == EMSdata_curve3d)
        {
        cv = datasel->data.curve;
        BSfreecv (&msg_loc, cv);
        }
      }
    }

  if (intinfo & EMSintdata_samexyzdat && my_xyz_data) 
    om$dealloc (ptr = my_xyz_data);
  else if (my_xyz_data && other_xyz_data && my_xyz_data != other_xyz_data)
    {
    om$dealloc (ptr = my_xyz_data);
    om$dealloc (ptr = other_xyz_data);
    }
  if (my_uv_data)
    om$dealloc (ptr = my_uv_data);
  if (other_uv_data)
    om$dealloc (ptr = other_uv_data);

  if (correl_params)
    {
    for (i=0; i<num_grp; i++)
      om$dealloc (ptr = correl_params[i]);
    om$dealloc (ptr = correl_params);
    }

  if (num_bdrys)
    om$dealloc (ptr = num_bdrys);
  if (mybdrys) 
    {
    for (i=0; i<num_grp; i++)
      ems$pypoint_free (pypts = mybdrys[i]);
    om$dealloc (ptr = mybdrys);
    }
  if (mybdryps)
    {
    for (i=0; i<num_grp; i++)
      EMsfintedpar_free (mybdryps[i], NULL);
    om$dealloc (ptr = mybdryps);
    }
  if (otbdrys) 
    {
    for (i=0; i<num_grp; i++)
      ems$pypoint_free (pypts = otbdrys[i]);
    om$dealloc (ptr = otbdrys);
    }
  if (otbdryps)
    {
    for (i=0; i<num_grp; i++)
      EMsfintedpar_free (otbdryps[i], NULL);
    om$dealloc (ptr = otbdryps);
    }
  if (trmdatbuff)
    om$dealloc (ptr = trmdatbuff);

  /* stop timer for sfsfint method */
  if (_use_timers)
    stop_timer (T_EMSFSFINT, FALSE, "");

  EMWRAPUP (*msg, stat_OM, "EMSsubbs.EMsfsfint");
  return (stat_OM);
}




/*
 * The following are support functions used locally in this
 * file. These are not intended for public use.
 */

static void chg_xyz_data (msg, srf1, bdry1, srf2, bdry2, xyz1, xyz2, num)
IGRlong *msg;
struct IGRbsp_surface *srf1, *srf2;
struct EMSdataselect *xyz1, *xyz2;
struct EMSpypoint *bdry1, *bdry2;
IGRint num;
{
  IGRint ptinx, blksize;
  IGRlong stat_func, msg_loc;
  IGRdouble *xyzpts;
  struct IGRbsp_surface *srf;
  struct EMSpypoint *bdry, *otbdry;
  struct EMSdataselect *xyzdat;
  extern void BSsfeval();

  *msg = EMS_S_Success;

  xyzpts = NULL;
  if (bdry2 && bdry1->props & EMS_PYPT_POSUNKNOWN)
    {
    bdry = bdry2;
    xyzdat = xyz2;
    otbdry = bdry1;
    srf = srf2;
    if (xyzdat->datatype == EMSdata_poly3d)
      xyzpts = xyzdat->data.poly->points;
    }
  else
    {
    bdry = bdry1;
    xyzdat = xyz1;
    otbdry = bdry2;
    srf = srf1;
    if (xyzdat->datatype == EMSdata_poly3d)
      xyzpts = xyzdat->data.poly->points;
    }

  blksize = 3 * sizeof (IGRdouble);
  if (bdry->param != 0.0 && bdry->param != 1.0)
    {
    BSsfeval (srf, bdry->point[U], bdry->point[V], 0, bdry->point, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_Fail, ret_end);
    if (otbdry)
      OM_BLOCK_MOVE (bdry->point, otbdry->point, blksize);
    }
  else
    {
    if (xyzpts)
      {
      ptinx = (bdry->span_inx + (IGRint) bdry->param) * 3;
      OM_BLOCK_MOVE (&xyzpts[ptinx], bdry->point, blksize);
      }
    else
      {
      EMinternalpt (&msg_loc, NULL, NULL, xyzdat, 
       bdry->param == 0.0 ? EMScvint_lfend : EMScvint_rtend, 1, bdry->point);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      }
    if (otbdry)
      OM_BLOCK_MOVE (bdry->point, otbdry->point, blksize);
    }
  num--;

  if (num)
    chg_xyz_data (msg, srf1, bdry1->next, srf2, bdry2 ? bdry2->next : NULL, 
     xyz1, xyz2, num);

ret_end:
  stat_func = TRUE;
/*
 * KLUDGE to rid us of assembler error on x86 platform
  EMWRAPUP (*msg, stat_func, "chg_xyz_data");
*/
}


static void get_maxbuff_trim (msg, num, data1, data2, buff)
IGRlong *msg;
IGRint num;
struct EMSdataselect *data1, *data2;
IGRchar **buff;
{
  IGRshort i, j, dim;
  IGRint maxsize, size;
  struct EMSdataselect *data[2];
  struct IGRbsp_curve *cv;

  maxsize = 0;
  data[0] = data1;
  data[1] = data2;

  for (i=0; i<2; i++)
    {
    if (!data[i])
      continue;

    for (j=0; j<num; j++)
      {
      if (data[i][j].datatype == EMSdata_poly2d || 
          data[i][j].datatype == EMSdata_poly3d)
        {
        dim = data[i][j].datatype == EMSdata_poly2d ? 2 : 3;
        size = data[i][j].data.poly->num_points * dim * sizeof (IGRdouble);
        }
      else
        {
        cv = data[i][j].data.curve;
        GRbc_size (cv->order, cv->num_poles, cv->rational, 0, size);
        }

      if (size > maxsize)
        maxsize = size;
      }
    }

  *buff = (IGRchar *) om$malloc (size = maxsize);
  if (!*buff)
    *msg = EMS_E_NoDynamicMemory;
}



static void search_and_get_geom (msg, inters, geom, srfid, mattyp, mat, 
                                 malloced)
IGRlong	*msg;
struct EMSinters *inters;
struct IGRbsp_surface **geom;
struct GRid srfid;
IGRshort *mattyp;
IGRmatrix mat;
IGRboolean *malloced;
{
 IGRlong 	stat_OM, msg_loc;
 struct EMSinters *this_inters;
 IGRlong	srf_size;

 *msg = msg_loc = EMS_S_Success;
 *geom = NULL;
 this_inters = inters;
 if(malloced) *malloced = TRUE;

 while(this_inters)
 {
  if( IF_EQ_OBJID(this_inters->this_obj.objid, srfid.objid) &&
      (this_inters->this_obj.osnum == srfid.osnum) && this_inters->more_info)
   {
    *geom = (struct IGRbsp_surface *) this_inters->more_info;
    if(malloced) *malloced = FALSE;
    break;
   }
  this_inters = this_inters->next;
 }

if(!(*geom))
 {
  stat_OM = om$send (msg = message GRvg.GRgetsize (&msg_loc, mattyp, mat,
                        &srf_size), 
                 targetid = srfid.objid, 
                 targetos = srfid.osnum, 
		 senderid = srfid.objid);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
  
  *geom = (struct IGRbsp_surface *) om$malloc (size = srf_size);
  EMerr_hndlr (!(*geom), *msg, EMS_E_NoDynamicMemory, ret_end);
  
  stat_OM = om$send (msg = message GRvg.GRgetgeom (&msg_loc, mattyp, mat,
                 (IGRchar *) *geom), targetid = srfid.objid,
                 targetos = srfid.osnum, senderid = srfid.objid);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_SurfaceError, ret_end);
 }

ret_end:
  stat_OM = TRUE;
  EMWRAPUP (*msg, stat_OM, "EMsearch_and_get_geom");

}


end implementation EMSsubbs;
