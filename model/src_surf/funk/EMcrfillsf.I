/*

 * DESCRIPTION
       
    This function returns the fillet(s) between the two surfaces specified.
    Within limits, its action can be tailored utlizing the 'options'
    argument [also see the headers of 'bscrfillsrf() and bsvrfilsfwl()'].

 * Inputs

    options		- EMS_RND_SF1_NATSIDE
			  EMS_RND_SF2_NATSIDE

				These determine the side of each surface
				on which the fillet will be generated.
 
			- EMS_RND_SINGLE_FILLET

				If set then the argument 'ref_pt' is used to
				filter out all but a single fillet (determined
				by evaluating the minimum distance from
				'ref_pt' to each of the fillets, and by
				chosing the fillet that has the smallest
				minimum distance).

			- EMS_RND_EXTEND_SURF

				If set, then the fillet(s) returned will be
				extended.  The amount of extension is twice
				the fillet radius.

			- EMS_RND_END_ROLLING_BALL

				If set, the extension at each of the ends of
				the fillet will be a surface produced by a
				rolling ball at each end (as opposed to twice
				the radius extension as in the preceeding).

			- EMS_RND_INT_ROLLING_BALL

				If set, the fillet surface at the interior
				corner of a cusp will correspond to a surface
				produced by a rolling ball at that corner. The
				default is to extend the two surfaces at the
				corner and produce two fillets.

			- EMS_RND_BOUND_SURF

				If set, the a natural loopset will be imposed
				on each of the fillet surfaces.

			- EMS_RND_ORIENTED

				If set, the fillet surface(s) will be oriented
				to be consistant with the 'first_srf_id'
				surface.

			- EMS_RND_PARTIAL_FILLET

				If set, the partial fillet surface bounded by
				its iso curves at 'closest_pt1 and
				closest_pt2' is returned.

                        - EMS_RND_CHECK_CURV_PROB

                                If set, check to see whether any of the
                                fillets have a curvature problem, and if
                                so, error out.  Else, ignore any curvature
                                problems on the fillets.

    construct_list	- The instance of GRvg_construct, carrying the
			  packet of information concerning the module,
			  active display parameters, etc.
    begin_radius	- Starting radius of the fillet.
    end_radius		- Ending radius of the fillet
			  NOTE: For constant radius fillets, pass identical
				radii for each of these.
    input_rho		- This value reflects the geometry of the fillet
			  surface.
			    full fillet: default
			    planar surface: 0.0 (chamfering)
			    conic section: 0.0 < input_rho < 1.0
    closest_pt1,
    closest_pt2		- Used in determining the partial fillet surface
			  (also see EMS_RND_PARTIAL_FILLET).

    dir_pt		- If the fillet is closed, this is used (together with
			  'closest_pt1 and closest_pt2') to determine the
			  partial fillet.

    ref_pt		- Used to filter out all but one of the fillets
			  (see comments on EMS_RND_SINGLE_FILLET).

    law_crv		- For variable radius rounding, the transition along
			  the fillet is specified by the this bsp curve.
			  Can be NULL.
			  If 'law_crv == NULL', then the transition along the
			  fillet will be linear.
    first_srf_id	- struct GRid of the first surface.
    second_srf_id	- struct GRid of the second surface,
    first_srf_geom	- The bspline geometry (IGRbsp_surface) of the first
			  surface.
			  Can be NULL
    second_surf_geom	- The bspilne geometry (IGRbsp_surface) of the second
			  surface.
			  Can be NULL
 * Outputs

    msg			- Return codes
				EMS_S_Success
				EMS_I_SurfaceError
					The fillets created had curvature
					problems.
    num_of_fillets	- Number of fillets returned.
			  Can be NULL (useful if EMS_RND_SINGLE_FILLET is set)

    For the following arrays, if the caller has not allocated memory, then
    *fillet_srf... must be set to NULL (and this function will allocated
    memory).  If memory is passed in, any existing values in that memory
    is not preserved.

    fillet_srf_objids	- Array of GRobjids of the fillets.  If EMS_RND_BOUND
			  _SURF is set, then this cannot be NULL.  Else it
			  may be NULL.

    fillet_srf_geoms	- An array of fillet surface geometries.
			  Can be NULL.
    fillet_srf_props	- An array of fillet surface properties.
			  Can be NULL.

 * HISTORY

    Inasu : Apr 9,91 : creation.
    DLB   : 02/11/92 : Comment out resetting of construct_list->msg ptr.
    SS    : 02/14/92 : u_0_onSurf initialized to TRUE (math always tries to
                       return u_0 on the first surface). 
    SS    : 03/18/92 : Re-wrote the function.
    Janaka: 11/02/92 : Added EMS_RND_CHECK_CURV_PROB as an option. This was
                       required since the place fillet surface command
                       requires ignoring any curvature problems on the
                       fillets, where as rounding needs to error out.
    WBC   : 01/11/93 : Replace the call to BSmdistptsf with a call
                       to BSprptarrsf.
    Janaka: 02/12/93 : Made the following addition to the fillet properties
                       returned by this function.
                       If the fillet surface as returned by math is a general
                       BSP surface, then assume that it is an inaccurate
                       surface (i.e. only within cht_tol to its defining
                       surfaces), and set EMSfillet_inaccurate_atstop and
                       EMSfillet_inaccurate_atstart.
    SY    : 06/07/93 : Remove static declaration from function
                       get_sf_type_for_filleting()'s prototype. 

    Sudha : 07/06/93 : Modified for BSprototypes ansification
    WBC   : 11/05/93 : Moved the initialization of some memory pointers to
                       the beginning of the function (TR#119311930).

*/

class implementation EMSsubbs;

#include "bserr.h"
#include "bsdefs.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "emsedgedef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSrnd.h"
#include "bsvrfilsfwl.h"
#include "bssfeval.h"
#include "bssfarrevn.h"
#include "bsprptarrsf.h"
#include "bspl_of_pts.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bsfreesf.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscrfillsrf.h"
#include "bschangepar.h"
#include "bsallocsf.h"

#define X 0
#define Y 1
#define Z 2

#define FIRST  0
#define SECOND 1

#define START_PAR 0.0
#define STOP_PAR  1.0

#define WBC_USE_NEW_MATH 1

%safe

static void get_min_dist( IGRlong *EMmsg, IGRdouble u, IGRdouble v,
                  struct IGRbsp_surface *uv_on_this_srf,
                  struct IGRbsp_surface *min_dist_to_this_srf,
                  IGRdouble *min_dist, IGRpoint *min_dist_pt_xyz,
                  IGRdouble *min_dist_pt_uv );

%endsafe

void	get_sf_type_for_filleting();

#argsused

IGRlong EMcrfilletsurf( EMmsg, options, construct_list, 
                        begin_radius, end_radius, input_rho,
			closest_pt1, closest_pt2, dir_pt,
		        ref_pt, law_curve,
			first_srf_GRid, second_srf_GRid,
			first_srf_geom, second_srf_geom, 
                        num_of_fillets,	fillet_srf_objids,
			fillet_srf_geoms, fillet_srf_props )

IGRlong				*EMmsg; 
IGRushort			options;
struct GRvg_construct		*construct_list;
IGRdouble			begin_radius,
				end_radius,
				input_rho;
IGRpoint			ref_pt,
				closest_pt1,
				closest_pt2,
				dir_pt;
struct IGRbsp_curve		*law_curve;
struct GRid			*first_srf_GRid,
				*second_srf_GRid;
struct IGRbsp_surface		*first_srf_geom,
				*second_srf_geom;
IGRint				*num_of_fillets;
GRobjid				**fillet_srf_objids;
struct IGRbsp_surface		***fillet_srf_geoms;
IGRushort			**fillet_srf_props;
{
  IGRboolean			rho_changed, reversed, sf1_fillet_nat_side,
				sf2_fillet_nat_side, *curvature_problems,
                                all_on_surf;
  IGRshort			*mattyp;
  IGRint			i,
				j,
				index,
				temp_num_of_fillets,
				*num_bcvs,
                                num_pts;
  IGRlong			om_stat,
				msg;
  IGRdouble			old_rho,
				cht_tol,
				dist,
				min_dist,
				u,
				v,
				*mat,
                                len_tol,
                                sf_uv[2];
  IGRvector			srf_normal, fillet_normal;
  IGRpoint			temp_point, dum_pt;
  GRclassid			classid;
  GRobjid			dumobjs[4];

  extern GRclassid		OPP_EMSptorus_class_id,
                                OPP_EMSgenbs_class_id;

  struct IGRbsp_surface         *srf, *sf1_encompassing_plane,
                                *sf2_encompassing_plane, *temp_first_srf_geom,
                                *temp_second_srf_geom;
  struct BSgeom_bsp_surf	first_srf_BSgeom, second_srf_BSgeom,
				**temp_srf_BSgeom;
  struct BSgeom_bsp_curve	**bcvs;
  struct GRmd_env		*md_env = NULL;

  void				getsftype();

  /*
   * Initialize and run some checks on function arguments.
   */
       *EMmsg = EMS_S_Success;
       om_stat = OM_S_SUCCESS;
       old_rho = 0.0;		/* Avoid optimizer warning */
       rho_changed = FALSE;
       num_pts = 1;
       BSEXTRACTPAR( &msg, BSTOLCHRDHT, cht_tol );
       BSEXTRACTPAR( &msg, BSTOLLENVEC, len_tol );
       first_srf_BSgeom.bspsf = NULL;
       second_srf_BSgeom.bspsf = NULL;
       temp_first_srf_geom =
       temp_second_srf_geom = NULL;
       temp_srf_BSgeom = NULL;
       curvature_problems = NULL;
       num_bcvs = NULL;
       bcvs = NULL;
       temp_num_of_fillets = 0;
       *num_of_fillets =0;

       /*
	* If a natural boundary is to be imposed on the fillets, then
	* 'fillet_srf_objids' cannot be NULL (if so, there is nothing
	* to attached the loopset too).
	*/
	   if( ( options & EMS_RND_BOUND_SURF ) && !fillet_srf_objids )
	   {
	      *EMmsg = EMS_E_InvalidArg;
	      goto wrapup;
	   }

       md_env = construct_list->env_info;
       mattyp = &md_env->md_env.matrix_type;
       mat = &md_env->md_env.matrix[0];

  /*
   * For the first input surface, construct the surface geometry in a form
   * suitable for math create fillet functions (i.e. construct an instance of
   * struct BSgeom_bsp_surf for the first surface).
   */
      /*
       * If the geometry was passed in, use it.  Otherwise generate it.
       */
          temp_first_srf_geom = first_srf_geom;
          if( !temp_first_srf_geom )
          {
             om_stat = EMgetvggeom( &msg,
	 	                    mattyp,
			            mat,
			            first_srf_GRid,
			            &temp_first_srf_geom,
			            NULL
			          );
	
	     EMerr_hndlr( !( msg & om_stat & 1 ), *EMmsg, msg, wrapup );
          }

      sf1_fillet_nat_side = options & EMS_RND_SF1_NATSIDE ? TRUE : FALSE;

      /*
       * Obtain the surface type.  If the type is BSRECT_PLANE, and
       * 'encompassing_plane' not NULL, then subtitute the encompassing plane
       * for the first surface, for the purpose of fillet creation.
       */
      sf1_encompassing_plane = NULL;
      get_sf_type_for_filleting( &msg, ( IGRushort ) 0,
                                 first_srf_GRid->objid,
		                 md_env->md_id.osnum,
                                 temp_first_srf_geom,
                  		 &first_srf_BSgeom.type,
                                 &sf1_encompassing_plane,
                                 &reversed );
      EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_SurfaceError, wrapup );

      if( first_srf_BSgeom.type == BSRECT_PLANE && sf1_encompassing_plane )
      {
         first_srf_BSgeom.bspsf = sf1_encompassing_plane;
         if( reversed == TRUE )
            sf1_fillet_nat_side = options & EMS_RND_SF1_NATSIDE
                                    ? FALSE : TRUE;
      }
      else
	 first_srf_BSgeom.bspsf = temp_first_srf_geom;

      first_srf_BSgeom.bounded = TRUE;
      first_srf_BSgeom.urange[ 0 ] = first_srf_BSgeom.vrange[ 0 ] = 0.0;
      first_srf_BSgeom.urange[ 1 ] = first_srf_BSgeom.vrange[ 1 ] = 1.0;
      first_srf_BSgeom.sfgen_cv = NULL;
      first_srf_BSgeom.geom_prop = FALSE;

  /*
   * Do the preceeding for the second input surface,
   */
       temp_second_srf_geom = second_srf_geom;
       if( !temp_second_srf_geom )
       {
          om_stat = EMgetvggeom( &msg,
	                         mattyp,
			         mat,
			         second_srf_GRid,
			         &temp_second_srf_geom,
			         NULL
			       );
	
          EMerr_hndlr( !( msg & om_stat & 1 ), *EMmsg, msg, wrapup );
        }

      sf2_fillet_nat_side = options & EMS_RND_SF2_NATSIDE ? TRUE : FALSE;

      sf2_encompassing_plane = NULL;
      get_sf_type_for_filleting( &msg, ( IGRushort ) 0,
                                 second_srf_GRid->objid,
		                 md_env->md_id.osnum,
                                 temp_second_srf_geom,
                  		 &second_srf_BSgeom.type,
                                 &sf2_encompassing_plane,
                                 &reversed );
      EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_SurfaceError, wrapup );

      if( second_srf_BSgeom.type == BSRECT_PLANE && sf2_encompassing_plane )
      {
         second_srf_BSgeom.bspsf = sf2_encompassing_plane;
         if( reversed == TRUE )
            sf2_fillet_nat_side = options & EMS_RND_SF2_NATSIDE
                                    ? FALSE : TRUE;
      }
      else
         second_srf_BSgeom.bspsf = temp_second_srf_geom;

      second_srf_BSgeom.bounded = TRUE;
      second_srf_BSgeom.urange[ 0 ] = second_srf_BSgeom.vrange[ 0 ] = 0.0;
      second_srf_BSgeom.urange[ 1 ] = second_srf_BSgeom.vrange[ 1 ] = 1.0;
      second_srf_BSgeom.sfgen_cv = NULL;
      second_srf_BSgeom.geom_prop = FALSE;


   /*
    * Save the existing RHO value (to be reset in wrapup), and enforce the
    * input 'input_rho'.
    */
     if (!(options & EMS_RND_DEFAULT_RHO))
     {
       BSEXTRACTPAR (&msg, BSRHO_VALUE, old_rho);
       BSchangepar (&msg, BSRHO_VALUE, input_rho );
       rho_changed = TRUE;
     }

   /*
    * Call the appropriate math function for generating either a constant
    * radius fillet, or a variable radius fillet (these should be the same
    * function, but currently they are not.  The constant radius filleting
    * function has evolved where as the variable radius function has not.
    * There is potential for the latter to produce undesirable surfaces.
    */
       {
         IGRint				ext_ind,
	       				cnv_ind,
					cnc_ind;
	 IGRboolean			end_cvs[2];

         if( fabs( begin_radius - end_radius ) <= len_tol )
         {
	    /*
	     * Constant radius fillets
	     */
	    ext_ind = options & EMS_RND_EXTEND_SURF 
				? 2
				: ( options & EMS_RND_END_ROLLING_BALL
					? 1 : 0 );

	    cnv_ind = cnc_ind = options & EMS_RND_INT_ROLLING_BALL
				? 1 : 2;

	    BScrfillsrf( &first_srf_BSgeom,
			 &second_srf_BSgeom,
			 begin_radius,
			 options & EMS_RND_SF1_NATSIDE ? TRUE : FALSE,
			 options & EMS_RND_SF2_NATSIDE ? TRUE : FALSE,
			 ext_ind,
			 cnv_ind,
			 cnc_ind,
			 &temp_num_of_fillets,
			 &temp_srf_BSgeom,
			 &curvature_problems,
			 &num_bcvs,
			 &bcvs,
			 &msg );

	    EMerr_hndlr( msg != BSSUCC || !( temp_num_of_fillets ), *EMmsg,
			 EMS_E_BSerror, wrapup );

	    /*
	     * Need to check for curvature problems here [see 'BScrfillsrf()']
	     */
         }
         else
         {
	    /*
	     * Variable radius case.
	     */
            temp_srf_BSgeom = (struct BSgeom_bsp_surf **) om$malloc (size = 
                   			sizeof (struct BSgeom_bsp_surf *));
            EMerr_hndlr( !temp_srf_BSgeom, *EMmsg, EMS_E_NoDynamicMemory,
			  wrapup );
            *temp_srf_BSgeom = (struct BSgeom_bsp_surf *) om$malloc (size =
                   			sizeof (struct BSgeom_bsp_surf));
     	    EMerr_hndlr( ! *temp_srf_BSgeom, *EMmsg, EMS_E_NoDynamicMemory,
			 wrapup );

            end_cvs[FIRST] = end_cvs[SECOND] = FALSE;
            BSvrfilsfwl( first_srf_BSgeom.bspsf,
			 second_srf_BSgeom.bspsf,
			 begin_radius,
			 end_radius,
          		 options & EMS_RND_SF1_NATSIDE ? TRUE : FALSE,
			 options & EMS_RND_SF2_NATSIDE ? TRUE : FALSE,
          		 options & EMS_RND_PARTIAL_FILLET ? TRUE : FALSE,
          		 closest_pt1,
			 closest_pt2,
			 dir_pt,
          		 law_curve ? FALSE : TRUE,
			 law_curve,
          		 START_PAR,
			 STOP_PAR,
         		 end_cvs, NULL, NULL, NULL, NULL,
          		 &temp_srf_BSgeom[ FIRST ]->bspsf,
			 &msg
		        );
             EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

     	     temp_num_of_fillets = 1;
             temp_srf_BSgeom[ FIRST ]->type = BSGEN_BSP_SF;
          }
       }

  /*
   * If the option is to return only a single fillet surface, then choose the
   * one which is closest to the 'ref_pt'.  Delete the remaining fillets. 
   */
      if( options & EMS_RND_SINGLE_FILLET && temp_num_of_fillets > 1 )
      {
	 if( !ref_pt )
	 {
	    *EMmsg = EMS_E_InvalidArg;
	    goto wrapup;
	 }

         min_dist = MAXDOUBLE;
	 index = FIRST;

	 for( i = 0; i < temp_num_of_fillets; i++ )
         {
#if WBC_USE_NEW_MATH
            BSprptarrsf(temp_srf_BSgeom[i], len_tol, 2, 2, &num_pts, ref_pt,
                        sf_uv, temp_point, &all_on_surf, NULL, &msg);
	    EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

            u = sf_uv[0];
            v = sf_uv[1];

            dist = BSdistptpt(&msg, ref_pt, temp_point);
	    EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
#else
	    BSmdistptsf( &msg,
			 temp_srf_BSgeom[i]->bspsf,
			 ref_pt,
			 &u,
			 &v,
			 temp_point,
			 &dist );
	    EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
#endif
	    if( dist < min_dist )
	    {
		min_dist = dist;
		index = i;
	    }
	 }

         for( i = 0; i < temp_num_of_fillets; i++ )
         {
	    /*
	     * Delete all fillets except the one that is closest to 'ref_pt'
	     */
	         if( i == index )
		    continue;

                 BSfreesf( &msg, temp_srf_BSgeom[i]->bspsf );
		 om$dealloc( ptr = temp_srf_BSgeom[i] );
		 temp_srf_BSgeom[i] = NULL;
	 }

	 if( index != FIRST )
	 {
	    temp_srf_BSgeom[ FIRST ] = temp_srf_BSgeom[ index ];
	    temp_srf_BSgeom[ index ] = NULL;
	    if( curvature_problems )
	       curvature_problems[ FIRST ] = curvature_problems[ index ];
	 }

	 temp_num_of_fillets = 1;
      }

  /*
   * Set the fillet's oriented normal.
   * Evaluate the normal at (0.0, 0.5).  On failure, repeat with (1.0, 0.5).
   * The assumption here is that atleast one of the points (0,0.5) or (1,0.5)
   * is likely to be on both, the fillet and the appropriate model
   * surface.  Although this assumption is valid in the majority, there are
   * instances when it would be violated, thus causing the surface orientation
   * to fail. In such cases, resort to an interval halving search on (0,v).
   */
       if( options & EMS_RND_ORIENTED )
       {
          IGRshort		num_iterations;
          IGRdouble		v1, v2, vmiddle, f_at_v1, f_at_v2,
                                f_at_vmiddle, min_bound, upper_bound,
                                srf_uv_at_min_dist[2];

	  for( i = 0; i < temp_num_of_fillets; i++ )
	  {
             min_bound = 0.0;
             upper_bound = 1.0;
             vmiddle = ( upper_bound - min_bound ) / 2.0;

             /* First, try both (0.0, 0.5) and (1.0, 0.5).  On failure, resort
              * to the search.
              */
                 srf = temp_second_srf_geom;
 
                 u = 1.0;
                 get_min_dist( &msg, u, vmiddle, temp_srf_BSgeom[i]->bspsf,
                               srf, &f_at_vmiddle, NULL,
                               srf_uv_at_min_dist );
                 EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );

                 if( f_at_vmiddle < cht_tol ) goto COMPUTE_NORMAL;

                 srf = temp_first_srf_geom;
                 u = 0.0;
                 get_min_dist( &msg, u, vmiddle, temp_srf_BSgeom[i]->bspsf,
                               srf, &f_at_vmiddle, NULL,
                               srf_uv_at_min_dist );
                 EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );

                 if( f_at_vmiddle < cht_tol ) goto COMPUTE_NORMAL;
             
             /* Simple method did not work.  Resort to the interval halving
              * search.  If this does not converge in 10 iterations, quit
              * with error (actually, for the cases observed for which the
              * preceding failed, this converges in about 2 iterations!!).
              */
                for( num_iterations = 0; TRUE; num_iterations++ )
                {
                   EMerr_hndlr( num_iterations > 9, *EMmsg, EMS_E_Fail,
                       wrapup );
                   v1 = min_bound + ( upper_bound - min_bound ) / 4.0;
                   v2 = upper_bound - ( upper_bound - min_bound ) / 4.0;
                   
                   get_min_dist( &msg, u, v1, temp_srf_BSgeom[i]->bspsf, srf,
                                 &f_at_v1, NULL, NULL );
                   EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
                   if( f_at_v1 < f_at_vmiddle )
                   {
                      upper_bound = vmiddle;
                      vmiddle = v1;
                   }
                   else
                   {
                      get_min_dist( &msg, u, v2, temp_srf_BSgeom[i]->bspsf,
                                    srf, &f_at_v2, NULL, NULL );
                      EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
                      if( f_at_v2 < f_at_vmiddle )
                      {
                         min_bound = vmiddle;
                         vmiddle = v2;
                      }
                      else
                      {
                         min_bound = v1;
                         upper_bound = v2;
                      }
                   }
                   get_min_dist( &msg, u, vmiddle, temp_srf_BSgeom[i]->bspsf,
                                 srf, &f_at_vmiddle, NULL,
                                 srf_uv_at_min_dist );
                   EMerr_hndlr( !( 1 & msg ), *EMmsg, EMS_E_Fail, wrapup );
                   if( f_at_vmiddle < cht_tol )
                      break;
                }

COMPUTE_NORMAL:

	     /*
	      * Evaluate the surface normal at (u, vmiddle) on the fillet,
              * and at ( srf_uv_at_min_dist_pt[0], srf_uv_at_min_dist_pt[1] ).
	      */
		 BSsfarrevn( &msg, temp_srf_BSgeom[i]->bspsf, 1, &u,
                      1, &vmiddle, dum_pt, fillet_normal );
		 EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
 
		 BSsfarrevn( &msg, srf, 1, &srf_uv_at_min_dist[0], 1,
                     &srf_uv_at_min_dist[1], dum_pt, srf_normal );
		 EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

                 if( srf->pos_orient == FALSE )
                    for( j = X; j <= Z; j++ )
		       srf_normal[ j ] = -srf_normal[ j ];
	     /*
	      * Now, set the oriented normal of the ith fillet surface.
	      */
	        {
		   IGRdouble dot_product;

		   dot_product = BSdotp( &msg, fillet_normal, srf_normal );
		   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror,
				wrapup );
		   if( dot_product < 0.0 )
		      temp_srf_BSgeom[i]->bspsf->pos_orient = FALSE;
		   else
		      temp_srf_BSgeom[i]->bspsf->pos_orient = TRUE;
		}
	  }
       }

  /*
   * Create objects for each of the fillets.
   * Determine fillet v0 and v1 degeneracy.
   * impose a natural boundary.
   * Assign output.
   */
      if( num_of_fillets )
	*num_of_fillets = temp_num_of_fillets;

      /*
       * Do the array of fillet objids and natural boundaries.
       */
	  if( fillet_srf_objids )
	  {
	     if( ! *fillet_srf_objids )
	     {
	        *fillet_srf_objids = ( GRobjid * ) om$malloc( size =
				( temp_num_of_fillets ) * sizeof( GRobjid ) );

                EMerr_hndlr( ! *fillet_srf_objids, *EMmsg,
			     EMS_E_NoDynamicMemory, wrapup );
	     }

             for( i = 0; i < temp_num_of_fillets; i++ )
             {
	        construct_list->geometry = ( IGRchar* ) temp_srf_BSgeom[i]
						->bspsf;
	        getsfclassid( temp_srf_BSgeom[i]->type, &classid );

                /* This modification needs to be removed, once Dieter
                 * provides a geometric surface extraction function
                 * that will handle partial torus properly.
                 */
                   if( classid == OPP_EMSptorus_class_id )
                    classid = OPP_EMSgenbs_class_id;

	        om_stat = om$construct(
				classid = classid,
				osnum = md_env->md_id.osnum,
				p_objid = &(*fillet_srf_objids)[i],
				msg = message GRgraphics.GRconstruct(
							construct_list )
				    );

	        EMerr_hndlr( !( om_stat & *construct_list->msg & 1 ), *EMmsg,
		 	     *construct_list->msg, wrapup );

	        /*
	         * if required, impose a natural boundary on the fillet
		 * surface (needed the fillet surface object before doing
		 * this).
		 */
	            if( options & EMS_RND_BOUND_SURF )
    	            {
    	               om_stat = om$send( 
			 	msg = message EMSsurface.EMmk_nat_bdry(
    						&msg,
    						&md_env->md_env,
    						dumobjs ),
    			        targetid = (*fillet_srf_objids)[ i ],
    			        senderid = NULL_OBJID,
				targetos = md_env->md_id.osnum
				        );
    
    	              EMerr_hndlr( !( om_stat & msg & 1 ), *EMmsg, msg,
    			           wrapup );
	            }
             }
	  }

      /*
       * Do the fillets properties.
       */
          if( fillet_srf_props )
	  {
	     if( ! *fillet_srf_props )
	     {
	        *fillet_srf_props = ( IGRushort * ) om$malloc( size =
			( temp_num_of_fillets ) * sizeof( IGRint ) );
	        EMerr_hndlr( ! *fillet_srf_props, *EMmsg,
			     EMS_E_NoDynamicMemory, wrapup );
	     }

	     for( i = 0; i < temp_num_of_fillets; i++ )
	     {
	        ( *fillet_srf_props )[i] = 0;
		srf = temp_srf_BSgeom[ i ]->bspsf;

	        /*
	         * Determine degeneracy of the ith fillet on v=0.
	         */
	            if( EFpts_degenerate( srf->u_num_poles,
				          srf->poles,
				          srf->weights,
				          3,
				          cht_tol ) )

	            ( *fillet_srf_props )[i] =
					EMSfillet_v0_is_degenerate;

               /* Determine the accuracy of the fillet. */
                  if( temp_srf_BSgeom[i]->type == BSGEN_BSP_SF )
                     ( *fillet_srf_props )[i] |= EMSfillet_inaccurate_atstart
                                | EMSfillet_inaccurate_atstop;
	       /*
                * Determine degeneracy of the ith fillet on V=1.
	        */
	           index = ( srf->v_num_poles - 1 ) * srf->u_num_poles;
	           if( EFpts_degenerate( srf->u_num_poles,
		    		    /*
				     * In the following, allow for the fact
				     * that each pole is a 3D entity in the
				     * XYZ space.
				     */
				        &srf->poles[ index * 3 ],

				    srf->weights ? &srf->weights[ index ]
						 : NULL,
				    3,
				    cht_tol ) )

		   ( *fillet_srf_props)[i] |=
					EMSfillet_v1_is_degenerate;
	     }
	  }

      /*
       * Do the fillets geometry.
       */
          if( fillet_srf_geoms )
	  {
	     if( ! *fillet_srf_geoms )
	     {
	        *fillet_srf_geoms = ( struct IGRbsp_surface ** ) om$malloc(
			size = ( temp_num_of_fillets ) * sizeof( 
					struct IGRbsp_surface * ) );
	        EMerr_hndlr( ! *fillet_srf_geoms, *EMmsg,
			     EMS_E_NoDynamicMemory, wrapup );
	     }

	     for( i = 0; i < temp_num_of_fillets; i++ )
	     {
	        ( *fillet_srf_geoms )[ i ] = temp_srf_BSgeom[ i ]->bspsf;
		temp_srf_BSgeom[ i ]->bspsf = NULL;
	     }
	  }

   if( options & EMS_RND_CHECK_CURV_PROB && curvature_problems )
         for( i = 0; i < temp_num_of_fillets; i++ )
	    if( curvature_problems[ i ] == TRUE )
            {
               for (i=0; i<temp_num_of_fillets; i++)
               {
                 if (fillet_srf_geoms)
                   BSfreesf (&msg, (*fillet_srf_geoms)[i]);
                 if (fillet_srf_objids)
                   om$send (msg = message GRgraphics.GRdelete (&msg, md_env),
                    targetid = (*fillet_srf_objids)[i], senderid = NULL_OBJID,
                    targetos = md_env->md_id.osnum);
               }

	       *EMmsg = EMS_E_SurfaceError;
	       goto wrapup;
	    }

wrapup:

  /*
   * If the rho value was changed, then reset it.
   */
       if( rho_changed )  
	  BSchangepar( &msg, BSRHO_VALUE, old_rho );

  /*
   * Remove all the fillets that were not utilized.
   */
       if( temp_srf_BSgeom )
       {
          for( i = 0; i < temp_num_of_fillets; i++ )
          {
             if( temp_srf_BSgeom[i] )
             {
                if( temp_srf_BSgeom[ i ]->bspsf )
                    BSfreesf( &msg, temp_srf_BSgeom[i]->bspsf );
                om$dealloc( ptr = temp_srf_BSgeom[i] );
             }
          }

          om$dealloc( ptr = temp_srf_BSgeom );
       }

  if( curvature_problems )
    om$dealloc( ptr = curvature_problems );


  if( num_bcvs )
     om$dealloc( ptr = num_bcvs );

  if( bcvs )
  {
     for( i = 0; i < temp_num_of_fillets; i++ )
	if( bcvs[ i ] )
	{
	   if( bcvs[i]->bspcv )
	      BSfreecv( &msg, bcvs[i]->bspcv );
	   om$dealloc( ptr = bcvs[i] );
	}

     om$dealloc( ptr = bcvs );
  }

  /*
   * If the first surface bspline geometry was constructed within this
   * function, then remove it.
   */
       if( !first_srf_geom  && first_srf_BSgeom.bspsf )
	  /*
	   * This memory was allocated as a single block.  So use the dealloc
	   * (NOT BSfreesf).
	   */
	     om$dealloc( ptr = first_srf_BSgeom.bspsf );

  /*
   * Do preceding for the second surface.
   */
       if( !second_srf_geom && second_srf_BSgeom.bspsf )
	  /*
	   * This memory was allocated as a single block.  So use the dealloc
	   * (NOT BSfreesf).
	   */
	     om$dealloc( ptr = second_srf_BSgeom.bspsf );

  EMWRAPUP( *EMmsg, om_stat, "EMcrfilletsurf" );
  return( om_stat );
}



/*
 * DESCRIPTION:
	This function attempts to determine the specialized surface type
	of 'sf_objid' (i.e. EMSplane, etc.), by examining the class of
        'sf_objid' (these types correspond to those defined within
        'bsgeom_cvsf.h).  On failing to determine the special surface type
        through its class, it attempts to determine whether 'sf_objid' is a
        plane (for example, a cindidate here would be a rule surface).  If
        so, it constructs an infinite plane that encompasses surface
        'sf_objid'.  The normal of the infinite plane corresponds to the
        natural normal of surface 'sf_objid'.

 * INPUT: options	unused.
          sf_objid	surface whose type is tp be determined.
          sf_osnum	Object space number of 'sf_objid'.
          sf_geom	Geometry of 'sf_objid'.

 * OUTPUT: EMmsg		Status of non OM functionality within this
                                function.
           type			Surface type of 'sf_objid'.  These types
                                correspond to those defined within
                                'bsgeom_cvsf.h' .
           pt_on_inf_plane	If the 'type' is BSINF_PLANE, then this
                                contains a point on that plane.
           inf_plane_normal	If the 'type' is BSINF_PLANE, then this
                                contains the normal of that plane such that
                                its direction is that of the natural normal of
                                'sf_objid'.
   None of the input or output is to be NULL.

 * HISTORY:
	Janaka : Dec 03, 92 : Original.
*/

#argsused

void get_sf_type_for_filleting( EMmsg, options, sf_objid, sf_osnum,
                         sf_geom, type, encompassing_plane, reversed )
IGRlong			*EMmsg;
IGRushort		options;
GRobjid			sf_objid;
GRspacenum		sf_osnum;
struct IGRbsp_surface	*sf_geom, **encompassing_plane;
IGRshort		*type;
IGRboolean		*reversed;
{
   IGRlong		msg;
   IGRdouble		params[2], dotp;
   IGRpoint		pt_on_sf;
   IGRvector		sf_normal, fitted_plane_normal;
   struct IGRbsp_surface	*fitted_plane;

extern void getsftype() ;

   *EMmsg = EMS_S_Success;
   fitted_plane = NULL;
   *encompassing_plane = NULL;

   getsftype( sf_objid, sf_osnum, type );

   if( *type == BSGEN_BSP_SF && sf_geom->planar == TRUE )
   {
      BSallocsf( ( IGRshort ) 2, ( IGRshort ) 2,
                 ( IGRlong ) 2, ( IGRlong ) 2,
                 FALSE, ( IGRshort ) 0,
                 encompassing_plane, &msg );
      if( msg != BSSUCC )
         goto wrapup;
      fitted_plane = *encompassing_plane;

      /*
       * Get the actual plane.
       */
          BSpl_of_pts( sf_geom->u_num_poles * sf_geom->v_num_poles,
                       sf_geom->poles,
                       sf_geom->weights,
                       *encompassing_plane,
                       &msg );

          if( msg != BSSUCC )
             goto wrapup;	/* Keep the general surface type */

      /*
       * Evaluate the surface point and normal at (0, 0).
       */
          params[0] = params[1] = 0.0;
          BSsfarrevn( &msg,
                      *encompassing_plane,
                      ( IGRint ) 1,
                      &params[0],
                      ( IGRint ) 1,
                      &params[1],
                      pt_on_sf,
                      fitted_plane_normal );
          if( msg != BSSUCC )
             goto wrapup; /* Keep the general surface type */

          BSsfarrevn( &msg,
                      sf_geom,
                      ( IGRint ) 1,
                      &params[0],
                      ( IGRint ) 1,
                      &params[1],
                      pt_on_sf,
                      sf_normal );
          if( msg != BSSUCC )
             goto wrapup; /* Keep the general surface type */
      /*
       * Determine the normal orientation of the fitted plane,
       * relative to the original surfce's normal.
       */
          dotp = BSdotp( &msg, fitted_plane_normal, sf_normal );
          *reversed = FALSE;
          if( ( dotp + 1.0 ) < 1.0 )
             *reversed = TRUE;

      *type = BSRECT_PLANE;
      fitted_plane = NULL;
   }

wrapup:; 

   if( fitted_plane )
   {
      *encompassing_plane = NULL;
      BSfreesf( &msg, fitted_plane );
   }
}



/* DESCRIPTION:
      Evaluate point (u,v) on 'uv_on_this_srf', and determine the minimum
      distance from that xyz point to 'min_dist_to_this_srf'.

 * OPTIONS: Any of the following, but not all, can be NULL.
       min_dist, min_dist_pt_xyz, min_dist_pt_uv.

 * INPUT:
       u, v		    : Point to be evaluated on 'uv_on_this_srf'.
       uv_on_this_srf
       min_dist_to_this_srf : The surface to which the minimum distance from
                              the above (u,v) is to be calculated.

 * OUTPUT:
       EMmsg
       All memory for the following must be allocated by the caller.
         min_dist
         min_dist_pt_xyz
         min_dist_pt_uv

 * ALGORITHM:
       Trivial.

 * HISTORY:
      Janaka : 04/22/93 : Original.
      Sudha  : 07/06/93 : Modified for BSprototypes ansification
 */

#argsused

static void get_min_dist( IGRlong *EMmsg, IGRdouble u, IGRdouble v,
                  struct IGRbsp_surface *uv_on_this_srf,
                  struct IGRbsp_surface *min_dist_to_this_srf,
                  IGRdouble *min_dist, IGRpoint *min_dist_pt_xyz,
                  IGRdouble *min_dist_pt_uv )
{
   IGRlong	msg;
   IGRdouble	loc_min_dist_pt_uv[2], loc_min_dist;
   IGRpoint	loc_min_dist_pt_xyz, xyz_pt_at_uv;


   *EMmsg = EMS_S_Success;
   BSsfeval( uv_on_this_srf, u, v, ( IGRint ) 0, (IGRpoint *)xyz_pt_at_uv, &msg );
   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );
   BSmdistptsf( &msg, min_dist_to_this_srf, xyz_pt_at_uv,
                &loc_min_dist_pt_uv[0], &loc_min_dist_pt_uv[1],
                loc_min_dist_pt_xyz, &loc_min_dist );
   EMerr_hndlr( msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup );

   if( min_dist_pt_xyz )
      OM_BLOCK_MOVE( loc_min_dist_pt_xyz, min_dist_pt_xyz,
                     sizeof( IGRpoint ) );
   if( min_dist_pt_uv )
      OM_BLOCK_MOVE( loc_min_dist_pt_uv, min_dist_pt_uv,
                     sizeof( IGRdouble ) * 2 );
   if( min_dist )
      *min_dist = loc_min_dist;

wrapup:

   return;
}
 
end implementation EMSsubbs;
