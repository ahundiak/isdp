/* _________________

   FOR EMS 4.0
   Creation : Sanjay
   _________________
*/

/*
 * Given n surfaces and a solid and save point associated with each surface
 * the solid will be intersected with the given surfaces and keeps the por-
 * tion of the solid depending on the save side point. One can also specify
 * the extend option, which will enable the surface to extend in case when
 * the surface doesn't fully intersect with the solid.
 */

class implementation Root;

%safe
#include "math.h"
%endsafe
#include "bsvalues.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "ex.h"
#include "dp.h"
#include "msdef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "emsdef.h"
#include "emsdattyp.h"
#include "EMSmsgdef.h"
#include "EMSlogic.h"
#include "OMmacros.h"
#include "emserr.h"
#include "bsparameters.h"
#include "bserr.h"
#include "emsinterdef.h"
#include "EMSprop.h"
#include "dpmacros.h"
#include "emscvexten.h"
#include "emsfeaopts.h"
#include "EMSasopts.h"
#include "EMSasnuc.h"
#include "EMSdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsinter.h"
#include "emssfint.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "addrmopts.h"

#include "madef.h"
#include "ma.h"
#include "matypemx.h"
#include "matrlmx.h"
#include "marptsxfo.h"
#include "maoptsxfo.h"
#include "bsconic.h"
#include "bsrgbxint.h"
#include "bsconstprcv.h"
#include "macubepy.h"
#include "bsbxint.h"
#include "bsgeom_cvsf.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsallocsf.h"
#include "bsfreesf.h"
#include "bsplptnorrg.h"
#include "bssfeval.h"
#include "bssnorkts.h"
#include "bsbx2.h"
#include "bsptlngen.h"
#include "bsnorvec.h"
#include "bsmvecsclr.h"
#include "bsmkvec.h"
#include "bsdistptpt.h"
#include "bscvarrevt.h"
#include "bsdotp.h"
#include "bsmdistptsf.h"
#include "bsproj1.h"
#include "bsproj0.h"
#include "bsorthovec.h"
#include "bsprepsphr.h"
#include "bstoraxctrd.h"
#include "bscvtstclsd.h"
#include "bssf_proj.h"
#include "bssf_rev.h"
#include "bsxlnpl.h"
#include "bsptlnplan.h"


#include "addprot.h"

#define  CONST_U                         1
#define  CONST_V                         2

#define  U_LEFT                          0
#define  U_RIGHT                         1
#define  V_LEFT                          2
#define  V_RIGHT                         3

#define  FIRST                           0
#define  SECOND                          1

#define  NO_EXTENSION                    0
#define  EXTEND_SURFACE                  1
#define  EXTEND_SOLID                   -1

#define  PROCESS_ALL_DIRECTIONS          0x1
#define  STOP_IF_FAILS_FOR_FIRSTTIME     0x2

#define  KEEP_ALL_GROUPS                 0x1
#define  KEEP_ONLY_ONE_GROUP             0x2

#define  MAXITER                         10

#define  U_CLOSED                        0x01
#define  V_CLOSED                        0x02

from GRvg          import  GRdetplane;
from GRowner       import  GRget_number_components, GRget_components;
from EMSedge       import  EMgetpygeom;
from EMSsurface    import  EMrevorient, EMputLsIfNotThere;
from EMSsurface    import  EMget_point_on_surface;
from GRgraphics    import  GRgetrang, GRconstruct, GRdelete, GRptproject;
from EMSsfboolean  import  EMboolean;


extern OMuword  OPP_EMSsubbs_class_id, OPP_EMSsolid_class_id,
                OPP_EMSslboolean_class_id, OPP_EMSsfboolean_class_id,
                OPP_EMSdatpln_class_id, OPP_EMSplane_class_id,
                OPP_EMSgenbs_class_id, OPP_EMScylindr_class_id,
                OPP_EMSpcylindr_class_id, OPP_EMSsphere_class_id,
                OPP_EMSpsphere_class_id, OPP_EMScone_class_id,
                OPP_EMSpcone_class_id, OPP_EMStorus_class_id,
                OPP_EMSptorus_class_id, OPP_EMSproject_class_id,
                OPP_EMSrevol_class_id;

/* Extern function declarations */
extern IGRlong  EMintersect_surfaces(),
                EMboolean_surfaces_w_intersection();
extern void     EMsfinttrace_free(), EMsfintedpar_free(),
                EMinters_data_free(), EMinters_free();


IGRlong EFplsolid_by_trimming_with_surfaces(
IGRlong                *EFmsg,
IGRushort              options,
struct GRvg_construct  *cons_list,
IGRint                 num_sfs,
IGRushort              *sfs_opts,
struct GRid            *sfs_grid,
IGRboolean             *ext_sfs,
IGRdouble              *svside_pts,
struct GRid            *sl_grid,
struct GRmd_env        *sl_env,
struct GRid            **int_sfs_grid,
IGRint                 *num_sfs_failed,
struct GRid            **failed_sfs_grid,
struct GRid            *new_solid_grid )
{
    BSrc                   BSmsg;
    IGRint                 cnt, count, extend_surface, num_dir, *ext_dir,
                           ncomps, nfail, size, i;
    IGRlong                OMsts, OMmsg, total_poles;
    OMuword                classid;
    GRrange                sfrange, slrange;
    IGRshort               sfmat_type, slmat_type;
    IGRdouble              *sfmat, *slmat, *ext_dst, chttol;
    IGRboolean             world, del_surface, surf_is_pln, surf_is_ref_pln,
                           surf_is_composite, in_range;
    struct GRid            surface_grid, solid_grid, ext_sfgrid, new_slgrid,
                           first_sfgrid, *fsfs_grid, del_sfgrid;
    struct IGRplane        pln_of_sf;
    struct IGRbsp_surface  *sfgeom, *newsfgeom, *pln_sf_geom;

    OMsts = OM_S_SUCCESS;
    OMmsg = EMS_S_Success;
    *EFmsg = EMS_S_Success;
    cnt = 0; world = TRUE;
    sfgeom = NULL;
    ext_dst = NULL;
    num_dir = 0;
    ext_dir = NULL;
    nfail = 0;
    fsfs_grid = NULL;

    /*
     * validate the incoming arguments
     */
    if( !EFmsg || !cons_list || (num_sfs <= 0) || !sfs_grid || !svside_pts ||
        !new_solid_grid || !sl_grid || !sl_env)
        add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
            str = "EFplsolid_by_trimming_with_surfaces : Invalid Arguments",
            action = GOTO_VALUE, value = wrapup );

    BSEXTRACTPAR( &OMmsg, BSTOLLENVEC, chttol );
    solid_grid = *sl_grid;
    slmat = sl_env->md_env.matrix;
    slmat_type = sl_env->md_env.matrix_type;
    sfmat = cons_list->env_info->md_env.matrix;
    sfmat_type = cons_list->env_info->md_env.matrix_type;


    /*
     * allocate the memory for the failed surface grids if asked for the same
     */
    if( failed_sfs_grid )
    {
        if( options & STOP_IF_FAILS_FOR_FIRSTTIME )
            size = 1;
        else
            size = num_sfs;
        size *= sizeof(struct GRid);

        fsfs_grid = (struct GRid *) om$malloc( size = size );
        add$status( test = !fsfs_grid, msg = *EFmsg,
            code = EMS_E_NoDynamicMemory,
            str = "EFplsolid_by_trimming_with_surfaces : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );
    }

    /*
     * if the user asks for the surface ids, which are actually participated
     * in intersecting the solid, then allocate memory for the same.
     */
    if( int_sfs_grid )
    {
        *int_sfs_grid = (struct GRid *) om$malloc(
                                    size = num_sfs * sizeof(struct GRid) );
        add$status( test = !(*int_sfs_grid), msg = *EFmsg,
            code = EMS_E_NoDynamicMemory,
            str = "EFplsolid_by_trimming_with_surfaces : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );
    }

    for( cnt=0; cnt<num_sfs; cnt++ )   /* for each surface do the following */
    {
        /*
         * initialize all the variables which will be used for each surface
         */
        sfgeom            = NULL;
        ext_dst           = NULL;
        ext_dir           = NULL;
        newsfgeom         = NULL;
        pln_sf_geom       = NULL;
        del_surface       = FALSE;
        surf_is_pln       = FALSE;
        surf_is_ref_pln   = FALSE;
        surf_is_composite = FALSE;
        pln_of_sf.point   = NULL;
        pln_of_sf.normal  = NULL;

        memset( slrange, 0, 6 * sizeof(IGRdouble) );
        memset( sfrange, 0, 6 * sizeof(IGRdouble) );

        /*
         * get the range box of the solid
         */
        OMsts = om$send( msg = message GRgraphics.GRgetrang( &OMmsg,
                                     &slmat_type,
                                     slmat,
                                     &world,
                                     slrange ),
                       senderid = NULL_OBJID,
                       targetid = solid_grid.objid,
                       targetos = solid_grid.osnum );
        add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFplsolid_by_trimming_with_surfaces : GRgetrang error",
            action = GOTO_VALUE, value = for_end );

        /*
         * get the class id of the surface and find out whether the surface
         * is a planar one or a reference plane.
         */
        OMsts = om$get_classid( objid = sfs_grid[cnt].objid,
                                osnum = sfs_grid[cnt].osnum,
                                p_classid = &classid );
        add$status( test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFplsolid_by_trimming_with_surfaces : om$get_classid error",
            action = GOTO_VALUE, value = for_end );

        if( om$is_ancestry_valid( subclassid = classid,
                  superclassid = OPP_EMSdatpln_class_id) == OM_S_SUCCESS )
        {
            surf_is_ref_pln = TRUE;
            surface_grid = sfs_grid[cnt];
        }
        else if( om$is_ancestry_valid( subclassid = classid,
                       superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS )
        {
            surf_is_pln = TRUE;
        }
        else if( om$is_ancestry_valid( subclassid = classid,
                    superclassid = OPP_EMScomposite_class_id) == OM_S_SUCCESS )
        {
            surf_is_composite = TRUE;
        }


        /*
         * it could be a associative surface also, in that case we have to
         * get the component connected on the component channel. If you get
         * more than one component then return failure becase for composite
         * this method is not applicable.
         */
        if( !surf_is_ref_pln ) /* if surface is not a ref. plane */
        {
           ncomps = 0;
           OMsts = om$send( msg = message GRowner.GRget_number_components(
                                          &OMmsg,
                                          &ncomps ),
                           senderid = NULL_OBJID,
                           targetid = sfs_grid[cnt].objid,
                           targetos = sfs_grid[cnt].osnum );
           if( !(OMsts & OMmsg & 1) && !ncomps ) /* if not success */
           {
               surface_grid = sfs_grid[cnt];
           }
           else if( ncomps == 1 ) /* if success */
           {
              /* get the 1st component object */
              OMsts = om$send( msg = message GRowner.GRget_components( &OMmsg,
                                            cons_list->env_info, &first_sfgrid,
                                            1, &count, 0, 0 ),
                               senderid = NULL_OBJID,
                               targetid = sfs_grid[cnt].objid,
                               targetos = sfs_grid[cnt].osnum );
              add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg,
                  code = EMS_E_Fail,
                  str = "EFplsolid_by_trimming_with_surfaces : GRget_components error",
                  action = GOTO_VALUE, value = for_end );
              surface_grid = first_sfgrid;
              surf_is_composite = FALSE;
           }

           if( !surf_is_composite )
           {
               OMsts = om$send( msg = message GRgraphics.GRgetrang( &OMmsg,
                                              &sfmat_type,
                                              sfmat,
                                              &world,
                                              sfrange ),
                                senderid = NULL_OBJID,
                                targetid = surface_grid.objid,
                                targetos = surface_grid.osnum );
               add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg,
                   code = EMS_E_Fail,
                   str = "EFplsolid_by_trimming_with_surfaces :GRgetrang error",
                   action = GOTO_VALUE, value = for_end );
           }
        }

        if( surf_is_composite ) /* composite surface, No extension is allowed */
            surface_grid = sfs_grid[cnt];

        if(!surf_is_composite && ((ext_sfs && ext_sfs[cnt])||surf_is_ref_pln) )
        {
            /* if the caller specified that the surface
               is to be extended OR if the incoming surface
               is a reference plane. */
            /*
             * first check whether the surface need to be extended or
             * not
             */
            if( surf_is_ref_pln || surf_is_pln )
            {
             /*
              * if the surface is a plane,
              *    then check for whether the surface need to be extended or
              *    not. if the surface need to be extended, instead of exte-
              *    nding the surface, just create a new surface which will be
              *    encompassing the solid limits. Then put off the ext_sfs bit
              * else ( This is the case of a ref. plane )
              *    Just create a new planar surface which will be encompassing
              *    the solid range and for this also put off the ext_sfs bit.
              */
/***********
             if( surf_is_pln )
                 extend_surface = EFchkext_required(sfrange, slrange, chttol);
             else
***********/
                 extend_surface = EXTEND_SURFACE;

             if( extend_surface == EXTEND_SURFACE )
             {
                 /*
                  * get the planar data associated with the surface
                  */
                 pln_of_sf.point = (IGRdouble *) om$malloc(
                                                   size = 3 * sizeof(double) );
                 pln_of_sf.normal = (IGRdouble *)om$malloc(
                                                   size = 3 * sizeof(double) );
                 add$status( test = !pln_of_sf.point || !pln_of_sf.normal,
                     msg = *EFmsg, code = EMS_E_NoDynamicMemory,
                     str = "EFplsolid_by_trimming_with_surfaces : Insufficient Memory",
                     action = GOTO_VALUE, value = for_end );

                 OMsts = om$send( msg = message GRvg.GRdetplane( &OMmsg,
                                                &sfmat_type,
                                                sfmat,
                                                &pln_of_sf ),
                                  senderid = NULL_OBJID,
                                  targetid = surface_grid.objid,
                                  targetos = surface_grid.osnum );
                 add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg,
                     code = EMS_E_Fail,
                     str = "EFplsolid_by_trimming_with_surfaces :GRdetplane error",
                     action = GOTO_VALUE, value = for_end );

                 /*
                  * In order to be on safer side increase the range box limits
                  * by 10% on either side
                  */
                 for(i=0; i<3; i++)
                    if( slrange[i] < 0 ) slrange[i] *= 1.1;
                    else slrange[i] *= 0.9;
                 for(i=3; i<6; i++)
                    if( slrange[i] < 0 ) slrange[i] *= 0.9;
                    else slrange[i] *= 1.1;

                 /*
                  * get the B-spline plane definition which encompasses the
                  * solid range
                  */
                 BSallocsf( 2, 2, 2, 2, 0, 0, &pln_sf_geom, &BSmsg);
                 add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                     code = EMS_E_BSerror,
                     str = "EFplsolid_by_trimming_with_surfaces : BSallocsf error",
                     action = GOTO_VALUE, value = for_end );

                 BSplptnorrg( slrange, &slrange[3], pln_of_sf.point,
                              pln_of_sf.normal, (IGRdouble)1.0, &in_range,
                              pln_sf_geom, &BSmsg );
                 add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                     code = EMS_E_BSerror,
                     str = "EFplsolid_by_trimming_with_surfaces : BSplptnorrg error",
                     action = GOTO_VALUE, value = for_end );

                 /*
                  * after construction of the planar surface again check
                  * whether the surface really intersects with the given
                  * solid or not, as it is quite possible that the plane
                  * selected is parallel to the solid in which case  the
                  * selected plane never intersects with the solid.
                  */
/**********
                 total_poles = pln_sf_geom->u_num_poles *
                               pln_sf_geom->v_num_poles ;
                 BSbx2( &BSmsg, &total_poles, (IGRpoint *)pln_sf_geom->poles,
                        (pln_sf_geom->rational) ? pln_sf_geom->weights : NULL,
                        sfrange, &sfrange[3] );
                 add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                     code = EMS_E_BSerror,
                     str = "EFplsolid_by_trimming_with_surfaces : BSbx2 error",
                     action = GOTO_VALUE, value = for_end );
***********/

                 /*
                  * If the above mentioned problem, i.e. even the infinite
                  * is also not intersecting the solid, occurs, then error
                  * out
                  */
/***********
                 extend_surface = EFchkext_required(sfrange, slrange, chttol);
                 add$status( test = (extend_surface != NO_EXTENSION),
                     msg = *EFmsg, code = EMS_E_Fail,
                     str = "EFplsolid_by_trimming_with_surfaces : EFchkext_required error",
                     action = GOTO_VALUE, value = for_end );
***********/
                 extend_surface = NO_EXTENSION;
                 cons_list->geometry = (IGRchar *) pln_sf_geom;
                 OMsts = om$construct( classid = OPP_EMSplane_class_id,
                                       p_objid = &surface_grid.objid,
                                       msg = message GRgraphics.GRconstruct(
                                                                cons_list ),
                                     );
                 add$status( test = !(1 & OMsts & OMmsg),
                     msg = *EFmsg, code = EMS_E_Fail,
                     str = "EFplsolid_by_trimming_with_surfaces : om$construct error",
                     action = GOTO_VALUE, value = for_end );

                 if( surf_is_pln )
                 {
                     del_surface = TRUE;
                     del_sfgrid = sfs_grid[cnt];
                 }
                 cons_list->geometry = NULL;
              }

            }
            else
               extend_surface = EXTEND_SURFACE;

            if( extend_surface == EXTEND_SURFACE )
            {
                /*
                 * Extract the geometry of the surface
                 */
                OMsts = EMgetvggeom( &OMmsg,
                                     &sfmat_type,
                                     sfmat,
                                     &surface_grid,
                                     &sfgeom,
                                     NULL );
                add$status( test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
                    str = "EFplsolid_by_trimming_with_surfaces : EMgetvggeom error",
                    action = GOTO_VALUE, value = for_end );

                OMsts = om$get_classid( objid = surface_grid.objid,
                                        osnum = surface_grid.osnum,
                                        p_classid = &classid );
                add$status( test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail,
                    str = "EFplsolid_by_trimming_with_surfaces : om$get_classid error",
                    action = GOTO_VALUE, value = for_end );

                /*
                 * Then find the distance and direction in which the
                 * surface need to be extended
                 */
                OMsts = EFfind_extension_directions( &OMmsg,
                                             NULL,
                                             NULL,
                                             sfgeom,
                                             NULL,
                                             slrange,
                                             4,
                                             NULL,
                                             &num_dir,
                                             &ext_dir,
                                             &ext_dst );
                add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg,
                    code = EMS_E_Fail,
                    str = "EFplsolid_by_trimming_with_surfaces : EFfind_extension_directions error",
                    action = GOTO_VALUE, value = for_end );

                if (!num_dir)
                {
                  ext_sfgrid.objid = surface_grid.objid;
                  ext_sfgrid.osnum = surface_grid.osnum;
                  extend_surface = NO_EXTENSION;
                  goto IntersectSolid;
                }

                /*
                 * Extend the surface in specified directions
                 */
                /*
                 * In order to be on safe side increase the range box limits
                 * by 10% on either side
                 */
                for(i=0; i<3; i++)
                   if( slrange[i] < 0 ) slrange[i] *= 1.1;
                   else slrange[i] *= 0.9;
                for(i=3; i<6; i++)
                   if( slrange[i] < 0 ) slrange[i] *= 0.9;
                   else slrange[i] *= 1.1;

                OMsts = EFextend_surface (&OMmsg, (sfs_opts ? sfs_opts[cnt] :
                          NULL), cons_list, num_dir, ext_dir, &solid_grid,
                          slrange, &surface_grid, sfgeom, &newsfgeom );
                add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg,
                    code = EMS_E_Fail,
                    str = "EFplsolid_by_trimming_with_surfaces : EFextend_surface error",
                    action = GOTO_VALUE, value = for_end );

                BSsnorkts(newsfgeom->u_order, newsfgeom->v_order,
                          newsfgeom->u_num_poles, newsfgeom->v_num_poles,
                          newsfgeom->u_knots, newsfgeom->v_knots, 2, &BSmsg );
                add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                    code = EMS_E_BSerror,
                    str = "EFplsolid_by_trimming_with_surfaces : BSsnorkts error",
                    action = GOTO_VALUE, value = for_end );

                /*
                 * construct a surface with new geometry and use it for
                 * the surface intersect save side, at the same time
                 * delete the old surface
                 */
/**************
                cons_list->geometry = (IGRchar *) newsfgeom;

                OMsts = om$construct( classid = classid,
                                      p_objid = &ext_sfgrid.objid,
                                      osnum   = surface_grid.osnum,
                            msg = message GRgraphics.GRconstruct(cons_list) );
                EMerr_hndlr( !(1 & OMsts ), *EFmsg, EMS_E_Fail,
                             for_end );
***************/

                OMsts = EFcreate_exact_surface( &OMmsg, cons_list, (OMuword) 0,
                                                newsfgeom, &ext_sfgrid );
                add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg,
                    code = EMS_E_Fail,
                    str = "EFplsolid_by_trimming_with_surfaces : EFcreate_exact_surface error",
                    action = GOTO_VALUE, value = for_end );

                ext_sfgrid.osnum = surface_grid.osnum;
                cons_list->geometry = NULL;
            }
            else if( extend_surface == EXTEND_SOLID )
            {
#ifdef DEBUG
                fprintf(stderr,"Need to extend the solid \n");
#endif
                *EFmsg = EMS_E_Fail;
                OMmsg = EMS_E_Fail;
                goto for_end;
            }
            else
            {
                ext_sfgrid.objid = surface_grid.objid;
                ext_sfgrid.osnum = surface_grid.osnum;
            }
        }
        else if( surf_is_composite )
        {
            extend_surface   = NO_EXTENSION;
            ext_sfgrid.objid = surface_grid.objid;
            ext_sfgrid.osnum = surface_grid.osnum;
        }
        else
        {
            extend_surface = EFchkext_required(sfrange, slrange, chttol);
            if( extend_surface != NO_EXTENSION )
            {
#ifdef DEBUG
		fprintf(stderr," extend_surface = %d\n",extend_surface );
#endif
		*EFmsg = EMS_E_InvalidArg;
                OMmsg  = EMS_E_InvalidArg;
                goto for_end;
            }
            ext_sfgrid.objid = surface_grid.objid;
            ext_sfgrid.osnum = surface_grid.osnum;
        }

IntersectSolid :

        /*
         * Now use the extended surface to do the surface intersect save side
         */
        if( int_sfs_grid )
            int_sfs_grid[0][cnt] = ext_sfgrid;
        OMsts = EFintsolid_surface_svsd( &OMmsg,
                                         (sfs_opts) ? sfs_opts[cnt] : NULL,
                                         &ext_sfgrid,
                                         cons_list->env_info,
                                         &solid_grid,
                                         cons_list,
                                         &svside_pts[cnt*3],
                                         &new_slgrid );
        if( extend_surface )
        {
            del_surface = TRUE;
            if( (1 & OMsts & OMmsg) )
                del_sfgrid = sfs_grid[cnt];
            else
                del_sfgrid = ext_sfgrid;
        }
        add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFplsolid_by_trimming_with_surfaces : EFintsolid_surface_svsd error",
            action = GOTO_VALUE, value = for_end );

        solid_grid.objid = new_slgrid.objid;

    for_end :
        /*
         * free the allocated memory, accordingly the way it is allocated.
         */
        if( sfgeom )       om$dealloc( ptr = sfgeom ); sfgeom = NULL;
        if( ext_dst )      om$dealloc( ptr = ext_dst ); ext_dst = NULL;
        if( ext_dir )      om$dealloc( ptr = ext_dir ); ext_dir = NULL;
        if( newsfgeom )    BSfreesf( &BSmsg, newsfgeom ); newsfgeom = NULL;
        if( pln_sf_geom )  BSfreesf( &BSmsg, pln_sf_geom ); pln_sf_geom = NULL;
        if( pln_of_sf.point) om$dealloc( ptr = pln_of_sf.point );
        if( pln_of_sf.normal ) om$dealloc( ptr = pln_of_sf.normal );

        /*
         * if U have created a new surface during the process of extension
         * then delete the old surface
         */
        if( del_surface )
        {
            IGRlong loc_sts, loc_msg;

            loc_sts = om$send( msg = message GRgraphics.GRdelete( &loc_msg,
                                           cons_list->env_info ),
                             senderid = NULL_OBJID,
                             targetid = del_sfgrid.objid,
                             targetos = del_sfgrid.osnum );
        }

        /*
         * if the operation is failed for some reason for this surface, then
         * increment the number of failures field and populate the failed sf
         * grid. if the user specified 'stop even if there is one failure'
         * option stop processing and quit out else continue
         */
        if( !(1 & OMsts & OMmsg) )
        {
            if( failed_sfs_grid ) fsfs_grid[nfail] = sfs_grid[cnt];
            nfail ++;
            if( options & STOP_IF_FAILS_FOR_FIRSTTIME ) goto wrapup;
        }
    }

    new_solid_grid->objid = solid_grid.objid;
    new_solid_grid->osnum = solid_grid.osnum;
    if( num_sfs_failed ) *num_sfs_failed = nfail;
    if( failed_sfs_grid )
    {
        if( options & PROCESS_ALL_DIRECTIONS )
        {
            size = nfail * sizeof( struct GRid );
            fsfs_grid = (struct GRid *) om$realloc( ptr = (IGRchar *)fsfs_grid,
                                                    size = size );
        }
        *failed_sfs_grid = fsfs_grid;
    }

wrapup :

    if( sfgeom ) om$dealloc( ptr = sfgeom );
    EMWRAPUP( *EFmsg, OMsts, "EFplsolid_by_trimming_with_surfaces");
    return OMsts;
}

/*
 * This function takes the range boxes of the solid and surface and checks,
 * whether surface/solid need to extended or not, it returns the following:
 *  1  : if surface need to be extended
 * -1  : if solid need to be extended
 *  0  : if no need of extension of either surface or solid
 *
 * History
 * -------
 *
 * Sanjay           30th March'94        Creation
 */
IGRint    EFchkext_required( sfrange, slrange, tol )
GRrange   sfrange; /* surface range box */
GRrange   slrange; /* solid range box */
IGRdouble tol;     /* tolerance */
{
    BSrc        BSmsg;
    IGRint      ext_req, go_ahead;
    IGRpoint    newmin, newmax;
    IGRdouble   xmin, ymin, zmin, xmax, ymax, zmax;
    IGRboolean  intersect;

    ext_req = 1;
    go_ahead = 0;
    /*
     * do the box-box intersection and get the intersection box limits
     */
    BSrgbxint( &sfrange[0],
                &sfrange[3],
                &slrange[0],
                &slrange[3],
                &intersect,
                newmin,
                newmax,
                &BSmsg );

    /* if the range boxes doesn't intersect then return TRUE */
    if( !intersect )
    {
      if (sfrange[0] < slrange[0] && sfrange[1] < slrange[1] &&
          sfrange[2] < slrange[2] && sfrange[3] > slrange[3] &&
          sfrange[4] > slrange[4] && sfrange[5] > slrange[5])
        return 0;
      else
        return 1;
    }

    /*
     * else do the following :
     * the algorithm is simple here. if the
     */
    xmin = fabs( slrange[0] - newmin[0] );
    ymin = fabs( slrange[1] - newmin[1] );
    zmin = fabs( slrange[2] - newmin[2] );

    xmax = fabs( slrange[3] - newmax[0] );
    ymax = fabs( slrange[4] - newmax[1] );
    zmax = fabs( slrange[5] - newmax[2] );

    if( (xmin >= ymin) && (xmin >= zmin) )
    {
      if( (ymin <= tol ) && (zmin <= tol) ) go_ahead = 1;
    }
    else if( (ymin >= xmin) && (ymin >= zmin) )
    {
      if( (zmin <= tol) && (xmin <= tol) ) go_ahead = 1;
    }
    else if( (zmin >= xmin) && (zmin >= ymin) )
    {
      if( (xmin <= tol) && (ymin <=tol) ) go_ahead = 1;
    }
    else
      go_ahead = -1;

    if( go_ahead == 1)
    {
      go_ahead = 0;
      if( (xmax >= ymax) && (xmax >= zmax) )
      {
           if( (ymax <= tol ) && (zmax <= tol) ) go_ahead = 1;
      }
      else if( (ymax >= xmax) && (ymax >= zmax) )
      {
           if( (zmax <= tol) && (xmin <= tol) ) go_ahead = 1;
      }
      else if( (zmax >= xmax) && (zmin >= ymax) )
      {
           if( (xmax <= tol) && (ymax <=tol) ) go_ahead = 1;
      }
      else go_ahead = -1;
    }

    if( go_ahead == 1 ) ext_req = NO_EXTENSION;
    else if( go_ahead == 0 ) ext_req = EXTEND_SURFACE;
    else ext_req = EXTEND_SOLID;

    return ext_req;
}

/*
 * This function accepts a surface, a solid and finds the in which directions
 * the surface need to extended to intersect with the solid.
 * extension directions :
 * --------------------
 * 0 - U_LEFT
 * 1 - U_RIGHT
 * 2 - V_LEFT
 * 3 - V_RIGHT
 *
 * Algorithm
 * ---------
 * Extract all the constant parametric curves. Take two constant parametric
 * curves i.e. either (u=0 and u=1) or (v=0 and v=1) and find the range box
 * of the curves. find out whether the range boxes of the const. parametric
 * curves intersects with the range box of the solid. Then,
 *
 * ndir = 0;
 * if only one curve range box (u=0) intersects with the solid range box
 * then
 *      ext_direction[ndir++] = U_LEFT;
 * else if both curve range boxes (u=0 & u=1) intersects with the solid range
 *         box
 *      then
 *            ext_direction[ndir++] = U_LEFT;
 *            ext_direction[ndir++] = U_RIGHT;
 *
 * same for const. v parametirc curves also.
 * This routine assumes that the check for the extension has been done before
 * hand.
 *
 * History
 * -------
 * Sanjay         03/30/94        Creation
 */

IGRlong        EFfind_extension_directions( EFmsg, surface, surface_mdenv,
                   surface_geom, solid, solid_range, check_ndir, check_dir,
                   ndir, ext_dir, ext_dist )
IGRlong        *EFmsg;
struct GRid    *surface, *solid;  /* optional :  surface and solid grids
                                     can be NULL also if surface geom
                                      and slrange is provided */
struct GRmd_env *surface_mdenv;   /* if solid id is specified you need to
                                     specify the module env. also otherwise
                                     it can be NULL */
IGRdouble      *solid_range;      /* solid range: if this is NULL then
                                     solid grid need to be provided */
struct IGRbsp_surface *surface_geom;
                                  /* surface geometry : if NULL then surface
                                     grid need to be provided */
IGRint         check_ndir, *check_dir;
IGRint         *ndir, **ext_dir;  /* number of directions to extend and
                                     the actual directions */
IGRdouble      **ext_dist;        /* optional : extension distance */
{
    BSrc                   BSmsg;
    IGRint                 *dir, cnt, size, nd, lcnt;
    IGRlong                sts, msg;
    GRrange                slrange;
    IGRpoint               min_u0, max_u0, min_u1, max_u1, min_v0, max_v0,
                           min_v1, max_v1, sftan[4];
    IGRshort               mat_type, opt;
    IGRdouble              *mat, uv, *dist, cvrange[6], u, v, tol;
    IGRboolean             BSsts, tst_plan, int_u0, int_u1, int_v0, int_v1,
                           world, check_u0, check_u1, check_v0, check_v1,
                           check_all ;
    struct IGRbsp_curve    *curve;
    struct IGRbsp_surface  *sfgeom;

    mat     = NULL;
    curve   = NULL;
    sfgeom  = NULL;
    sts     = OM_S_SUCCESS;
    *EFmsg  = EMS_S_Success;
    size    = 0;
    world   = TRUE; dist = NULL;
    int_u0  = int_u1 = int_v0 = int_v1 = FALSE; lcnt = 0;
    check_u0 = check_u1 = check_v0 = check_v1 = check_all = FALSE;

    if( (!solid_range && (!solid || !surface_mdenv) ) ||
        (!surface && !surface_geom) || !ndir || !ext_dir || !check_ndir )
        add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
            str = "EFfind_extension_directions : Invalid Arguments",
            action = GOTO_VALUE, value = wrapup );

    if( surface_geom ) /* if surface geometry is given */
    {
        sfgeom = surface_geom;
    }
    else
    {
        /*
         * get the geometry of the surface
         */
        mat_type = surface_mdenv->md_env.matrix_type;
        mat = surface_mdenv->md_env.matrix;

        EMgetvggeom( &msg, &mat_type, mat, surface, &sfgeom, NULL );
        add$status( test = !(1&msg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFfind_extension_directions : EMgetvggeom error",
            action = GOTO_VALUE, value = wrapup );
    }

    if( solid_range ) /* if the solid range is given */
    {
	OM_BLOCK_MOVE( solid_range, slrange, 6 * sizeof(IGRdouble) );
    }
    else
    {
        /*
         * get the range of the solid
         */
        sts = om$send( msg = message GRgraphics.GRgetrang( &msg,
                                     &mat_type,
                                     mat,
                                     &world,
                                     slrange ),
                       senderid = NULL_OBJID,
                       targetid = solid->objid,
                       targetos = solid->osnum );
        add$status( test = !(1&sts&msg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFfind_extension_directions : GRgetrang error",
            action = GOTO_VALUE, value = wrapup );
    }

    /*
     * populate all the check fields
     */
    if( check_ndir >= 4 || !check_dir )
    {
        check_u0 = check_u1 = check_v0 = check_v1 = check_all = TRUE;
        dist = (IGRdouble *) om$malloc( size = 4 * sizeof( IGRdouble ) );
        add$status( test = !dist, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFfind_extension_directions : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );
    }
    else
    {
        for(cnt=0; cnt<check_ndir; cnt++)
        {
            if(check_dir[cnt] == U_LEFT)  check_u0 = TRUE;
            if(check_dir[cnt] == U_RIGHT) check_u1 = TRUE;
            if(check_dir[cnt] == V_LEFT)  check_v0 = TRUE;
            if(check_dir[cnt] == V_RIGHT) check_v1 = TRUE;
        }

        dist = (IGRdouble *) om$malloc(
                                 size = check_ndir * sizeof( IGRdouble ) );
        add$status( test = !dist, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFfind_extension_directions : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );
    }

    if( ext_dist )  size = 3 * sizeof(IGRdouble);

    /*
     * Now extract the iso parametric curves and find the range boxes of
     * each of them.
     */
    nd = 1; /* no. of derivaties */
    tst_plan = FALSE;
    BSEXTRACTPAR( &BSmsg, BSTOLLENVEC, tol );

    /*
     * extract u=0 curve, find the range box of const-u0 curve and check
     * whether it intersects with the range box of the solid or not. if
     * so, it need to be extended in U_LEFT direction
     */

    /* sfgeom->u_phy_closed was added for TR # 119603853 - Sp.B */
    if( check_u0 && !sfgeom->u_phy_closed)
    {
        BSalloccv( sfgeom->v_order, sfgeom->v_num_poles, sfgeom->rational,
                   sfgeom->num_boundaries, &curve, &BSmsg );
        add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
            str = "EFfind_extension_directions : BSalloccv error",
            action = GOTO_VALUE, value = wrapup );

        uv = 0.0;
        opt = CONST_U;
        BSsts = BSconstprcv( &BSmsg,
                             sfgeom,
                             &opt,
                             &uv,
                             &tst_plan,
                             curve );
        add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFfind_extension_directions : BSconstprcv error",
            action = GOTO_VALUE, value = wrapup );

        BSsts = MAcubepy( &BSmsg, curve, min_u0, max_u0);
        add$status( test = !BSsts || (BSmsg != MSSUCC), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFfind_extension_directions : MAcubepy error",
            action = GOTO_VALUE, value = wrapup );

        int_u0 = BSbxint( &BSmsg, min_u0, max_u0, &slrange[0], &slrange[3] );

        if( int_u0 && ext_dist )
        {
            OM_BLOCK_MOVE( min_u0, cvrange, size);
            OM_BLOCK_MOVE( max_u0, &cvrange[3], size);

            u = tol;
            v = 0.0;
            BSsfeval( sfgeom, u, v, nd, sftan, &BSmsg );
            add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                code = EMS_E_BSerror,
                str = "EFfind_extension_directions : BSsfeval error",
                action = GOTO_VALUE, value = wrapup );

            for(cnt=0; cnt<3; cnt++) sftan[1][cnt] *= -1.0;

            dist[lcnt] = EFext_dist( slrange, cvrange, sftan[1] );
            lcnt ++;
        }
    }

    /*
     * extract u=1 curve, find the range box of const-u0 curve and check
     * whether it intersects with the range box of the solid or not. if
     * so, it need to be extended in U_RIGHT direction
     */
    if( check_u1 && !sfgeom->u_phy_closed )
    {
        if( !curve )
        {
            BSalloccv( sfgeom->v_order, sfgeom->v_num_poles, sfgeom->rational,
                       sfgeom->num_boundaries, &curve, &BSmsg );
            add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                code = EMS_E_BSerror,
                str = "EFfind_extension_directions : BSalloccv error",
                action = GOTO_VALUE, value = wrapup );
        }

        uv = 1.0;
        opt = CONST_U;
        BSsts = BSconstprcv( &BSmsg,
                             sfgeom,
                             &opt,
                             &uv,
                             &tst_plan,
                             curve );
        add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFfind_extension_directions : BSconstprcv error",
            action = GOTO_VALUE, value = wrapup );

        BSsts = MAcubepy( &BSmsg, curve, min_u1, max_u1);
        add$status( test = !BSsts || (BSmsg != MSSUCC), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFfind_extension_directions : MAcubepy error",
            action = GOTO_VALUE, value = wrapup );

        int_u1 = BSbxint( &BSmsg, min_u1, max_u1, &slrange[0], &slrange[3] );

        if( int_u1 && ext_dist )
        {
            OM_BLOCK_MOVE( min_u1, cvrange, size);
            OM_BLOCK_MOVE( max_u1, &cvrange[3], size);

            u = 1.0 - tol;
            v = 1.0;
            BSsfeval( sfgeom, u, v, nd, sftan, &BSmsg );
            add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                code = EMS_E_BSerror,
                str = "EFfind_extension_directions : BSsfeval error",
                action = GOTO_VALUE, value = wrapup );

            for(cnt=0; cnt<3; cnt++) sftan[1][cnt] *= -1.0;

            dist[lcnt] = EFext_dist( slrange, cvrange, sftan[1] );
            lcnt ++;
        }

    }

    /*
     * extract v=0 curve, find the range box of const-u0 curve and check
     * whether it intersects with the range box of the solid or not. if
     * so, it need to be extended in V_LEFT direction
     */
    if( check_v0  && !sfgeom->v_phy_closed)
    {
        if( curve )
        {
            BSfreecv( &BSmsg, curve ); curve = NULL;
        }
        BSalloccv( sfgeom->u_order, sfgeom->u_num_poles, sfgeom->rational,
                   sfgeom->num_boundaries, &curve, &BSmsg );
        add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
            str = "EFfind_extension_directions : BSalloccv error",
            action = GOTO_VALUE, value = wrapup );

        uv = 0.0;
        opt = CONST_V;
        BSsts = BSconstprcv( &BSmsg,
                             sfgeom,
                             &opt,
                             &uv,
                             &tst_plan,
                             curve );
        add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFfind_extension_directions : BSconstprcv error",
            action = GOTO_VALUE, value = wrapup );

        BSsts = MAcubepy( &BSmsg, curve, min_v0, max_v0);
        add$status( test = !BSsts || (BSmsg != MSSUCC), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFfind_extension_directions : MAcubepy error",
            action = GOTO_VALUE, value = wrapup );

        int_v0 = BSbxint( &BSmsg, min_v0, max_v0, &slrange[0], &slrange[3] );

        if( int_v0 && ext_dist )
        {
            OM_BLOCK_MOVE( min_v0, cvrange, size);
            OM_BLOCK_MOVE( max_v0, &cvrange[3], size);

            u = 0.0;
            v = 1.0;
            BSsfeval( sfgeom, u, v, nd, sftan, &BSmsg );
            add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                code = EMS_E_BSerror,
                str = "EFfind_extension_directions : BSsfeval error",
                action = GOTO_VALUE, value = wrapup );

            dist[lcnt] = EFext_dist( slrange, cvrange, sftan[2] );
            lcnt ++;
        }

    }

    /*
     * extract v=1 curve, find the range box of const-u0 curve and check
     * whether it intersects with the range box of the solid or not. if
     * so, it need to be extended in V_RIGHT direction
     */
    if( check_v1  && !sfgeom->v_phy_closed)
    {
        if( curve && !check_v0 )
        {
            BSfreecv( &BSmsg, curve ); curve = NULL;
        }

        if( !curve )
        {
            BSalloccv( sfgeom->u_order, sfgeom->u_num_poles, sfgeom->rational,
                       sfgeom->num_boundaries, &curve, &BSmsg );
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFfind_extension_directions : BSalloccv error",
                action = GOTO_VALUE, value = wrapup );
        }

        uv = 1.0;
        opt = CONST_V;
        BSsts = BSconstprcv( &BSmsg,
                             sfgeom,
                             &opt,
                             &uv,
                             &tst_plan,
                             curve );
        add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFfind_extension_directions : BSconstprcv error",
            action = GOTO_VALUE, value = wrapup );

        BSsts = MAcubepy( &BSmsg, curve, min_v1, max_v1);
        add$status( test = !BSsts || (BSmsg != MSSUCC), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFfind_extension_directions : MAcubepy error",
            action = GOTO_VALUE, value = wrapup );

        int_v1 = BSbxint( &BSmsg, min_v1, max_v1, &slrange[0], &slrange[3] );

        if( int_v1 && ext_dist )
        {
            OM_BLOCK_MOVE( min_v1, cvrange, size);
            OM_BLOCK_MOVE( max_v1, &cvrange[3], size);

            u = 1.0;
            v = 1.0 - tol;
            BSsfeval( sfgeom, u, v, nd, sftan, &BSmsg );
            add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                code = EMS_E_BSerror,
                str = "EFfind_extension_directions : BSsfeval error",
                action = GOTO_VALUE, value = wrapup );

            dist[lcnt] = EFext_dist( slrange, cvrange, sftan[2] );
            lcnt ++;
        }
    }

    *ndir = 0;
    dir = NULL;

    if( int_u0 && int_u1 )
    {
        *ndir += 2;
        dir = (IGRint *) om$malloc( size = (*ndir * sizeof(double)) );
        add$status( test = !dir, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFfind_extension_directions : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );
        dir[*ndir-2] = 0;
        dir[*ndir-1] = 1;
    }
    else if( int_u0 )
    {
        *ndir += 1;
        dir = (IGRint *) om$malloc( size = (*ndir * sizeof(double)) );
        add$status( test = !dir, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFfind_extension_directions : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );
        dir[*ndir-1] = 0;
    }
    else if( int_u1 )
    {
        *ndir += 1;
        dir = (IGRint *) om$malloc( size = (*ndir * sizeof(double)) );
        add$status( test = !dir, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFfind_extension_directions : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );

        dir[*ndir-1] = 1;
    }

    if( int_v0 && int_v1 )
    {
        *ndir += 2;
        if( !dir )
            dir = (IGRint *) om$malloc( size = (*ndir * sizeof(double)) );
        else
            dir = (IGRint *) om$realloc( ptr = (char *) dir,
                                         size = (*ndir * sizeof(double)) );
        add$status( test = !dir, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFfind_extension_directions : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );
        dir[*ndir-2] = 2;
        dir[*ndir-1] = 3;
    }
    else if( int_v0 )
    {
        *ndir += 1;
        if( !dir )
            dir = (IGRint *) om$malloc( size = (*ndir * sizeof(double)) );
        else
            dir = (IGRint *) om$realloc( ptr = (char *) dir,
                                         size = (*ndir * sizeof(double)) );
        add$status( test = !dir, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFfind_extension_directions : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );
        dir[*ndir-1] = 2;
    }
    else if( int_v1 )
    {
        *ndir += 1;
        if( !dir )
            dir = (IGRint *) om$malloc( size = (*ndir * sizeof(double)) );
        else
            dir = (IGRint *) om$realloc( ptr = (char *) dir,
                                         size = (*ndir * sizeof(double)) );
        add$status( test = !dir, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFfind_extension_directions : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );
        dir[*ndir-1] = 3;
    }

    /*
     * SCOPE FOR IMPROVEMENT
     * ---------------------
     * There is always a possibility that the surface is totally on one side
     * of the solid, in which case it is better to extend in all the four
     * directions.
     */
    if( !*ndir && check_all )
    {
        *ndir = 4;
	dir = (IGRint *) om$malloc( size = (*ndir * sizeof(double)) );
        dir[0] = U_LEFT;
        dir[1] = U_RIGHT;
        dir[2] = V_LEFT;
        dir[3] = V_RIGHT;
    }

    *ext_dir = dir;

    if( ext_dist )
    {
        /*
         * SCOPE FOR IMPROVEMENT
         * ---------------------
         * This portion of the block is yet to be implemented.
         * So, for the time being only the some approx. values
         * will be posted into this.
         */
        dist = NULL;
        dist = (IGRdouble *) om$malloc(size = *ndir * sizeof(IGRdouble));
        add$status( test = !dist, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
            str = "EFfind_extension_directions : Insufficient Memory",
            action = GOTO_VALUE, value = wrapup );

        for( cnt=0; cnt<*ndir; cnt++ )
        {
            dist[cnt] = 1.0;
        }
        *ext_dist = dist;
    }

wrapup :
    if( curve   ) BSfreecv(&BSmsg, curve);
    if( surface ) om$dealloc( ptr = sfgeom );
    EMWRAPUP(*EFmsg, sts, "EFfind_extension_directions" );
    return sts;
}

/*
 * intersect solid surface save side
 */
IGRlong  EFintsolid_surface_svsd(
IGRlong               *EFmsg,
IGRushort             options,
struct GRid           *sfgrid,
struct GRmd_env       *sfenv,
struct GRid           *slgrid,
struct GRvg_construct *cons_list,
IGRpoint              svsd_pt,
struct GRid           *new_slgrid )
{
  /* general variables declaration */
  BSrc                   BSmsg;
  IGRint                 ncomps, count;
  IGRlong                OMsts, OMmsg;
  OMuword                classid;
  IGRshort               mattype;
  IGRushort              bool_options;
  IGRdouble              *mat;
  IGRboolean             nat_side, rev_orient, is_solid, rev_oriented;
  struct GRid            first_sfgrid, *comps, surface;
  struct IGRbsp_surface  *sfgeom;

  /* variables for Intersection operation */
  IGRint                 num_inters, num_sortpts;
  IGRchar                status_str[54];
  IGRushort              inters_opt, outworld_opt, outparam_opt, trim_opt;
  IGRboolean             handle_stop;
  IGRboolean             output_intersection, output_aux, no_topology;
  IGRboolean             double_chk, op_switch, openint_valid, single_topology;
  enum EMSbooltype       bool_type;
  struct EMSinters       *sfinters[2], *inters;
  struct EMSdataselect   sfs2data;
  struct EMSsftracedata  sftrace[2], *trace_info;

  /* Projection and Sort point Information */
  IGRpoint               projpt;
  IGRushort              group_opts;
  struct GRparms         proj_parms;
  struct EMparms         sortpt;

  OMsts                = OM_S_SUCCESS;
  OMmsg                = EMS_S_Success;
  *EFmsg               = EMS_S_Success;
  comps                = NULL;
  sfgeom               = NULL;
  nat_side             = FALSE;
  is_solid             = FALSE;
  rev_orient           = FALSE;
  rev_oriented         = FALSE;

  /*
   * validate the incoming arguments
   */
  if( !sfgrid || !sfenv || !slgrid || !svsd_pt || !new_slgrid )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFintsolid_surface_svsd : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


  if( !options )
      options = KEEP_ALL_GROUPS;

  /*
   * Initialization of the local variables
   */
  mat     = sfenv->md_env.matrix;
  mattype = sfenv->md_env.matrix_type;
  strcpy (status_str, "Processing");
  for( count=FIRST; count<=SECOND; count++ )
  {
      sfinters[count]            = NULL;
      memset( &sftrace[count], 0, sizeof(struct EMSsftracedata) );
  }

  /*
   * Step 1: Orientation of the surface depending on the save side point
   * -------------------------------------------------------------------
   * As the surface could also be a composite one, get the components
   * connected to it, and consider the first component of the composite
   * surface to select which side of the solid to save
   */
  OMsts = om$send( msg = message GRowner.GRget_number_components( &OMmsg,
                                 &ncomps ),
                   senderid = NULL_OBJID,
                   targetid = sfgrid->objid,
                   targetos = sfgrid->osnum );
  if( !(OMsts & OMmsg & 1)) /* if not success */
  {
      first_sfgrid.objid = sfgrid->objid;
      first_sfgrid.osnum = sfgrid->osnum;
  }
  else /* if success */
  {
      /* get the 1st component object */
      comps = (struct GRid *) alloca( ncomps * sizeof(struct GRid) );
      add$status( test = !comps, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
          str = "EFintsolid_surface_svsd : Insufficient Memory",
          action = GOTO_VALUE, value = wrapup );

      OMsts = om$send( msg = message GRowner.GRget_components( &OMmsg,
                                     sfenv, comps, ncomps, &count, 0,
                                     MAXINT ),
                       senderid = NULL_OBJID,
                       targetid = sfgrid->objid,
                       targetos = sfgrid->osnum );
      add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFintsolid_surface_svsd : GRget_components error",
          action = GOTO_VALUE, value = wrapup );
      add$status( test = !count, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFintsolid_surface_svsd : GRget_components error",
          action = GOTO_VALUE, value = wrapup );

      first_sfgrid = comps[0];
  }

  // get the geometry of the surface

  OMsts = EMgetvggeom( &OMmsg, &mattype, mat, &first_sfgrid, &sfgeom, NULL);
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFintsolid_surface_svsd : EMgetvggeom error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * find whether the given save side point is along the natural normal
   * of the surface or not
   */
  (void) BSptonnsdsf( sfgeom, svsd_pt, &nat_side, &BSmsg );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFintsolid_surface_svsd : BSptonnsdsf error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * we have to reverse orient the surface if
   * a. if the given save side point is along the surface natural normal and
   *    the pos_orient bit of the surface is TRUE ( OR )
   * b. if the given save side point is not along the surface natural normal
   *    and the pos_orient bit of the surface is FALSE
   */
  rev_orient = !( nat_side ^ (sfgeom->pos_orient) );

  if( rev_orient )
  {
      rev_oriented = TRUE;
      OMsts = om$send( msg = message EMSsurface.EMrevorient( &OMmsg ),
                       senderid = NULL_OBJID,
                       targetid = sfgrid->objid,
                       targetos = sfgrid->osnum );
      add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFintsolid_surface_svsd : EMrevorient error",
          action = GOTO_VALUE, value = wrapup );
  }

  /*
   * get the class id and determine whether given slgrid belongs to
   * surface or solid class
   */
  OMsts = om$get_classid( objid = slgrid->objid,
                          osnum = slgrid->osnum,
                          p_classid = &classid );

  if( classid == OPP_EMSsolid_class_id ||
      (om$is_ancestry_valid( subclassid = classid,
      superclassid = OPP_EMSsolid_class_id) == OM_S_SUCCESS) )
      is_solid = TRUE;

  /*
   * create a natural loopset on the surface if there is not any
   */
  OMsts = om$send( msg = message EMSsurface.EMputLsIfNotThere( &OMmsg,
                                 &sfenv->md_env, NULL, NULL, NULL, NULL ),
                   senderid = NULL_OBJID,
                   targetid = sfgrid->objid,
                   targetos = sfgrid->osnum );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFintsolid_surface_svsd : EMputLsIfNotThere error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Step 2: Intersecting the solid with the save side surface
   * ---------------------------------------------------------
   * create an object sfbool or slbool depending on the slgrid type
   * and send the EMboolean message to it
   */
  bool_options = NULL;
  bool_type = EMSbool_saveside;
  if( !is_solid )
      bool_options |= EMSsfbool_opt_OpenIntPossible |
                      EMSsfbool_opt_SingleTopology  ;

  // Now initialize all the options

  op_switch           = bool_options & EMSsfbool_opt_OperandsSwitched;
  double_chk          = bool_options & EMSsfbool_opt_doublecheck;
  output_aux          = bool_options & EMSsfbool_opt_outaux;
  handle_stop         = bool_options & EMSsfbool_opt_HandleStop;
  openint_valid       = bool_options & EMSsfbool_opt_OpenIntPossible;
  single_topology     = bool_options & EMSsfbool_opt_SingleTopology;
  output_intersection = bool_options & EMSsfbool_opt_outinters;
  if( output_intersection || output_aux )
      no_topology = TRUE;
  else
      no_topology = FALSE;

  outworld_opt = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;
  outparam_opt = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT |
                 EMSINT_ORIENT_OUTPUT | (bool_type == EMSbool_intersect ?
                                         EMSINT_ORIENT_RIGHT : NULL);
  trim_opt     = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
                 EMSINT_TRIM_COPLANAR |
                 (double_chk ? EMSINT_TRIM_MOREPRECISE |
                               EMSINT_TRIM_PROCOVERLAP : NULL) |
                 (bool_type == EMSbool_intersect ? EMSINT_TRIM_ONLYCUTTING :
                               NULL);
  inters_opt   = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_MUSTORIENT |
                 EMS_SFINT_PUSHBADCOINC |
                 (bool_type == EMSbool_difference ||
                  bool_type == EMSbool_saveside ?
                  EMS_SFINT_REVERSESECONDINT : NULL) |
                 (double_chk ? NULL : EMS_SFINT_MUSTNOAMBIGUOUS) |
                 (openint_valid ? NULL : EMS_SFINT_MUSTCLOSE) |
                 (double_chk ? EMS_SFINT_DOUBLECHECK : NULL) |
                 (handle_stop ? EMS_SFINT_HANDLESTOP : NULL);

  num_inters = 0;
  sfs2data.datatype = EMSdata_object;
  sfs2data.data.object = sfgrid;

  /*
   * Get the Intersection and trace data of the surfaces
   */
  OMsts = EMintersect_surfaces( &OMmsg, slgrid, &cons_list->env_info->md_env,
                      1, &sfs2data, &sfenv->md_env, inters_opt, outworld_opt,
                      outparam_opt, trim_opt, cons_list, &num_inters,
                      &sfinters[FIRST], &sfinters[SECOND], &sftrace[FIRST],
                      &sftrace[SECOND], NULL, NULL, status_str );

   // for no interseciton
  add$status( test = !num_inters || (OMmsg == EMS_E_NoIntersection),
      msg = *EFmsg, code = EMS_E_Fail,
      str = "EFintsolid_surface_svsd : EMintersect_surfaces : Surface doesn't intersect with the solid",
      action = GOTO_VALUE, value = wrapup );

  // all other errors
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFintsolid_surface_svsd : EMintersect_surfaces error",
      action = GOTO_VALUE, value = wrapup );

  if( sftrace[FIRST].num_grps != 1 && (options & KEEP_ONLY_ONE_GROUP) )
  {
     /*
      * Step 3:  Generation of sort point to keep the right trace groups
      * ----------------------------------------------------------------
      *    For each surface participating in the inters list, project the
      *    save side point and see whether the projected point is on the
      *    same side of the logical normal of the surface intersecting it
      *    if it is on the same side then take this point as the sort pt
      *    and break the loop otherwise continue. It is assumed here that
      *    atleast one point will lie on the same side of the surface.
      */
     for( inters = sfinters[0]; inters; inters = inters->next )
     {
         surface = inters->this_obj;
         OMsts = om$send( msg = message GRgraphics.GRptproject( &OMmsg,
                                        &mattype, mat, svsd_pt, projpt,
                                        &proj_parms ),
                          senderid = NULL_OBJID,
                          targetid = surface.objid,
                          targetos = surface.osnum );
         add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
             str = "EFintsolid_surface_svsd : GRptproject error",
             action = GOTO_VALUE, value = wrapup );

         (void) BSptonnsdsf( sfgeom, projpt, &nat_side, &BSmsg );
         add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
             str = "EFintsolid_surface_svsd : BSptonnsdsf error",
             action = GOTO_VALUE, value = wrapup );

         rev_orient = !( nat_side ^ (sfgeom->pos_orient) );
         if( rev_orient == rev_oriented ) break;
     }

     sortpt.u        = proj_parms.u;
     sortpt.v        = proj_parms.v;
     sortpt.leaf_id  = proj_parms.leaf_id;
     group_opts      = KEEP_TRACE_GROUP | STOP_AFTER_PROCESSING_FIRST;

     /*
      * Step 4: Modify the trace groups to keep only the group which contains
      *         the given sort point
      * ---------------------------------------------------------------------
      */
     num_sortpts = 1;
     OMsts = EFaddrm_modify_trace_groups( &OMmsg, group_opts, cons_list,
                             sfenv, &sfinters[FIRST], &sfinters[SECOND],
                             &sftrace[FIRST], &sftrace[SECOND], &num_sortpts,
                             &sortpt, NULL, NULL, FALSE, NULL, NULL );
     add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = OMmsg,
         str = "EFintsolid_surface_svsd : EFaddrm_modify_trace_groups error",
         action = GOTO_VALUE, value = wrapup );
  }

  /*
   * Step 5: Boolean Stage
   * ---------------------
   *    Using the intersection datra and the trace information for this
   *    intersection data, invoke the boolean function to compelte the
   *    boolean operation.
   */
  OMsts = om$construct( classid = is_solid ? OPP_EMSslboolean_class_id :
                                             OPP_EMSsfboolean_class_id ,
                        osnum   = slgrid->osnum,
                        p_objid = &new_slgrid->objid );
  add$status( test = !(1&OMsts), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFintsolid_surface_svsd : om$construct error",
      action = GOTO_VALUE, value = wrapup );

  new_slgrid->osnum = slgrid->osnum;

  OMsts = EMboolean_surfaces_w_intersection( &OMmsg, new_slgrid, bool_type,
                          cons_list->env_info, slgrid->objid, (IGRint) 1,
                          &sfgrid->objid, sfinters[FIRST], sfinters[SECOND],
                          &sftrace[FIRST], &sftrace[SECOND], NULL, NULL,
                          bool_options, NULL, NULL, status_str );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFintsolid_surface_svsd : EMboolean_surfaces_w_intersection error",
      action = GOTO_VALUE, value = wrapup );

wrapup :

  /*
   * Free the trace Information
   */
  for( count=FIRST; count<=SECOND; count++ )
  {
      trace_info = &sftrace[count];
      EMsfinttrace_free( &OMmsg, trace_info->num_grps,
          trace_info->num_subgrps_grp, trace_info->num_elems_subgrp,
          trace_info->elems, trace_info->subgrp_rev, trace_info->elem_rev,
          trace_info->grp_closed, trace_info->subgrp_closed );
  }

  /*
   * Free intersection data
   */
  for( count=FIRST; count <= SECOND; count++ )
  {
      EMinters_data_free( &OMmsg, sfinters[count], MAXINT, NULL,
                          EMsfintedpar_free );
      EMinters_free( sfinters[count], MAXINT );
  }

  if( sfgeom ) om$dealloc( ptr = sfgeom );
  EMWRAPUP(*EFmsg, OMsts, "EFintsolid_surface_svsd" );
  return OMsts;
}

/*
 * find extension distance
 */

IGRdouble EFext_dist( slrange, cvrange, dir )
IGRdouble *slrange, *cvrange, *dir;
{
    IGRint    cnt;
    IGRdouble ext_dist, prev_dist, dist;

    prev_dist = 0;

    for( cnt=0; cnt<6; cnt++ )
    {
        if( cnt < 3 )
            dist = fabs( (slrange[cnt+3] - cvrange[cnt] ) / dir[cnt] );
        else
            dist = fabs( (cvrange[cnt] - slrange[cnt-3] ) / dir[cnt-3] );

        if( !cnt ) prev_dist = dist;
        else if( dist > prev_dist ) prev_dist = dist;
    }

    ext_dist = 1.5 * dist;

    return ext_dist;
}

IGRlong  EFextend_gensurface_in_uvdirections(
IGRlong                *EFmsg,
IGRushort              options,
struct IGRbsp_surface  *sfgeom,
IGRint                 ndir,
IGRint                 *ext_dir,
IGRdouble              *ext_dst,
struct IGRbsp_surface  **newsfgeom )
{
     BSrc                   BSmsg;
     IGRint                 cnt, nfail;
     IGRlong                om_sts;
     IGRdouble              newdst;
     struct IGRbsp_surface  *sfgeom1, *sfgeom2;

     om_sts = OM_S_SUCCESS;
     *EFmsg = EMS_S_Success;
     nfail  = 0;

     /* validate the incoming function call arguments */
     if( !sfgeom || !ndir || !ext_dir || !ext_dst || !newsfgeom )
         add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
             str = "EFextend_gensurface_in_uvdirections : Invalid Arguments",
             action = GOTO_VALUE, value = wrapup );

     BSmsg = BSSUCC;
     sfgeom1 = sfgeom2 = NULL;
     if( !options ) options = PROCESS_ALL_DIRECTIONS;

     BSallocsf( sfgeom->u_order, sfgeom->v_order, sfgeom->u_num_poles,
                sfgeom->v_num_poles, sfgeom->rational, sfgeom->num_boundaries,
                &sfgeom1, &BSmsg );
     add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
         str = "EFextend_gensurface_in_uvdirections : BSallocsf error",
         action = GOTO_VALUE, value = wrapup );

     BSsf_copy( &BSmsg, sfgeom, sfgeom1 );

     for( cnt=0; cnt<ndir; cnt++ )
     {
          BSsfxtdst0( sfgeom1,
                      ext_dst[cnt],
                      ext_dir[cnt],
                      &sfgeom2,
                      &newdst,
                      &BSmsg );
          if( BSERROR(BSmsg))
          {
              nfail ++;
              if( options & STOP_IF_FAILS_FOR_FIRSTTIME )
                  add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                      code = EMS_E_BSerror,
                      str = "EFextend_gensurface_in_uvdirections : BSsfxtdst0 error",
                      action = GOTO_VALUE, value = wrapup );
              /* else
              {
                  continue;
              } */
          }

          if(!sfgeom2) continue;

          /* copy the extended surface after freeing the old surface */
          BSfreesf( &BSmsg, sfgeom1 );
          sfgeom1 = NULL;
          if( cnt != ndir-1 )
          {
              BSallocsf( sfgeom2->u_order, sfgeom2->v_order,
                         sfgeom2->u_num_poles, sfgeom2->v_num_poles,
                         sfgeom2->rational, sfgeom2->num_boundaries,
                         &sfgeom1, &BSmsg );
              add$status( test = BSERROR(BSmsg), msg = *EFmsg,
                  code = EMS_E_BSerror,
                  str = "EFextend_gensurface_in_uvdirections : BSallocsf error",
                  action = GOTO_VALUE, value = wrapup );

              BSsf_copy( &BSmsg, sfgeom2, sfgeom1 );
              BSfreesf( &BSmsg, sfgeom2 );
              sfgeom2 = NULL;
          }
     }

     if( !nfail ) *newsfgeom = sfgeom2;

wrapup :
    if( sfgeom1 ) BSfreesf( &BSmsg, sfgeom1 );
    if( nfail )   om_sts = EMS_E_Fail;
    EMWRAPUP( *EFmsg, om_sts, "EFextend_gensurface_in_uvdirections");
    return ( om_sts );

}

IGRlong   EFcreate_full_cylinder(
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom )
{
  BSrc                   BSmsg;
  IGRint                 i, cvtype;
  IGRlong                OMsts, OMmsg;
  IGRpoint               minpt, maxpt, minpt1, maxpt1;
  IGRvector              axis, dummy_vec;
  IGRushort              loc_opts;
  IGRdouble              inf_line[2][3], chttol, dist;
  IGRboolean             BSsts, full = TRUE;
  struct IGRbsp_curve    *gencv;
  struct IGRbsp_surface  *sfgeom;

  OMsts   = OM_S_SUCCESS;
  OMmsg   = EMS_S_Success;
  *EFmsg  = EMS_S_Success;

  // Initialization

  gencv = NULL;
  sfgeom = NULL;
  loc_opts = options;

  // Validate incoming arguments

  if( !gmsf || !slrange || !newsfgeom )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFcreate_full_cylinder : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


  BSEXTRACTPAR( &BSmsg, BSTOLCHRDHT, chttol );

  //  Rotational axis

  for(i=0; i<3; i++) /* rotational axis */
      axis[i] = gmsf->pt2[i] - gmsf->pt1[i];
  BSnorvec( &BSmsg, axis );

  /*
   * construct an inf. line along the axis vector, with the base
   * start point as the one of the end point
   */
  OM_BLOCK_MOVE( gmsf->pt3, inf_line[0], sizeof(IGRpoint) );
  for(i=0; i<3; i++)
      inf_line[1][i] = inf_line[0][i] + axis[i] * 10;

  /*
   * project the min. and max. range box points of the solid on to
   * this infinite plane
   */
  BSproj0( &BSmsg, slrange, inf_line, minpt );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cylinder : BSproj0 error",
      action = GOTO_VALUE, value = wrapup );

  BSproj0( &BSmsg, &slrange[3], inf_line, maxpt );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cylinder : BSproj0 error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Add tolerance on both the ends
   */
  for(i=0; i<3; i++)
  {
      maxpt[i] = maxpt[i] + axis[i] * 2 * chttol;
      minpt[i] = minpt[i] - axis[i] * 2 * chttol;
  }

  dist = BSdistptpt( &BSmsg, minpt, maxpt );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cylinder : BSdistptpt error",
      action = GOTO_VALUE, value = wrapup );

  for( i=0; i<3; i++ )
  {
      maxpt1[i] = maxpt[i] - axis[i] * 2 * chttol;
      minpt1[i] = minpt[i] + axis[i] * 2 * chttol;
  }

  if( (BSdistptpt( &BSmsg, minpt1, maxpt1 )) > dist )
  {
      OM_BLOCK_MOVE( minpt1, minpt, sizeof(IGRpoint) );
      OM_BLOCK_MOVE( maxpt1, maxpt, sizeof(IGRpoint) );
  }

  /*
   * generate the equivalent B-Spline representation for this line
   */
  BSalloccv( (IGRshort) 2, (IGRlong) 2, (IGRshort) 0, (IGRshort) 0, &gencv,
             &BSmsg );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cylinder : BSalloccv error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * The line to be generated is from base  to top. To make sure of it find
   * the dot product of the vector1 (along the line to be revolved) and the
   * axis and if the product is greater than zero, then take the points as
   * they are otherwise reverse them.
   */
  for(i=0; i<3; i++) /* dummy vector along the line */
      dummy_vec[i] = maxpt[i] - minpt[i];
  BSnorvec( &BSmsg, dummy_vec );

  if( (BSdotp( &BSmsg, dummy_vec, axis)) > 0.0 )
  {
      BSptlngen( &BSmsg, minpt, maxpt, gencv, &cvtype );
  }
  else
  {
      BSptlngen( &BSmsg, maxpt, minpt, gencv, &cvtype );
  }
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cylinder : BSptlngen error",
      action = GOTO_VALUE, value = wrapup );

  OM_BLOCK_MOVE( gmsf->pt1, inf_line[0], sizeof(IGRpoint) );
  OM_BLOCK_MOVE( gmsf->pt2, inf_line[1], sizeof(IGRpoint) );

  /*
   * Now revolve the line around the axis to generate the full cylinder.
   */
  BSallocsf( gencv->order, BSCIRCLE_ORDER, gencv->num_poles,
             BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &sfgeom, &BSmsg );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cylinder : BSallocsf error",
      action = GOTO_VALUE, value = wrapup );

  BSsts = BSsf_rev( &BSmsg, inf_line[0], inf_line[1], gencv,  &full, NULL,
                    NULL, sfgeom );
  add$status( test = BSERROR(BSmsg)|| !BSsts,msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cylinder : BSsf_rev error",
      action = GOTO_VALUE, value = wrapup );

  *newsfgeom = sfgeom;

wrapup :

  if( gencv )  BSfreecv( &BSmsg, gencv );
  EMWRAPUP( OMsts, *EFmsg, "EFcreate_full_cylinder");
  return  OMsts;
}

IGRlong   EFcreate_full_cone(
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom )
{
  BSrc                    BSmsg;
  IGRint                  i, cvtype;
  IGRlong                 OMsts, OMmsg;
  IGRpoint                minpt, maxpt, axis_line[2], line[2];
  IGRpoint                intpt;
  IGRvector               axis, line_vec, temp_vec;
  IGRushort               loc_opts;
  IGRdouble               inf_line[2][3], chttol;
  IGRboolean              BSsts, full = TRUE;
  struct IGRbsp_curve     *gencv;
  struct IGRbsp_surface   *sfgeom;

  OMsts        = OM_S_SUCCESS;
  OMmsg        = EMS_S_Success;
  *EFmsg       = EMS_S_Success;
  gencv        = NULL;
  sfgeom       = NULL;
  loc_opts     = options;

  // Validate incoming arguments

  if( !gmsf || !slrange || !newsfgeom )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFcreate_full_cone : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


  BSEXTRACTPAR( &BSmsg, BSTOLCHRDHT, chttol );

  /*
   * Rotational axis
   */
  for(i=0; i<3; i++)
      axis[i] = gmsf->pt2[i] - gmsf->pt1[i];
  BSnorvec( &BSmsg, axis );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSnorvec error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * calculate vector along the line to be revovled.
   */
  memset( line_vec, 0, sizeof(IGRvector) );

  for(i=0; i<3; i++)
      line_vec[i] = gmsf->pt4[i] - gmsf->pt3[i];
  BSnorvec( &BSmsg, line_vec );

  OM_BLOCK_MOVE( gmsf->pt3, inf_line[0], sizeof(IGRpoint) );
  OM_BLOCK_MOVE( gmsf->pt4, inf_line[1], sizeof(IGRpoint) );

  /*
   * Project the min. and max. range box points on this infinite line
   */
  BSproj0( &BSmsg, slrange, inf_line, minpt );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSproj0 error",
      action = GOTO_VALUE, value = wrapup );

  BSproj0( &BSmsg, &slrange[3], inf_line, maxpt );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSproj0 error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * see whether the line generatd by these projected points intersects
   * the axis or not. If it intersects then it needs to we need to consider
   * the line from the intersecting point and using this line generate the
   * conical surface.
   */
  OM_BLOCK_MOVE( gmsf->pt1, inf_line[0], sizeof(IGRpoint) );
  for(i=0; i<3; i++)
      inf_line[1][i] = inf_line[0][i] + axis[i] * 10;

  BSproj0( &BSmsg, slrange, inf_line, axis_line[0]);
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSproj0 error",
      action = GOTO_VALUE, value = wrapup );

  BSproj0( &BSmsg, &slrange[3], inf_line, axis_line[1] );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSproj0 error",
      action = GOTO_VALUE, value = wrapup );

  BSsts = BSxln( &BSmsg, axis_line[0], axis_line[1], minpt, maxpt, intpt );
  add$status( test = !BSsts, msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSxln error",
      action = GOTO_VALUE, value = wrapup );

  /* find whether the intersection point is lieing on the bounded line
     or not */
  if( BSmsg == BSSUCC )
  {
      IGRdouble   dist;

      dist = BSdistptpt( &BSmsg, minpt, maxpt );
      if( (BSdistptpt( &BSmsg, intpt, minpt )) > dist )
      {
          BSmsg = BSNOINTERS;
      }
      else if( (BSdistptpt( &BSmsg, intpt, maxpt)) > dist )
      {
          BSmsg = BSNOINTERS;
      }
  }

  /* If an intersection point exists */
  if( BSmsg != BSNOINTERS && BSmsg != BSPARALLEL && BSmsg != BSCOINCIDENT )
  {
      /*
       * Line to be revolved and the axis are intersecting, so we need
       * to keep the portion of the line which is just greater which is
       * along the direction of the line_vec
       */
      for(i=0; i<3; i++)
          temp_vec[i] = intpt[i] - minpt[i];
      BSnorvec( &BSmsg, temp_vec );

      if( (BSdotp( &BSmsg, line_vec, temp_vec)) > 0.0 )
      {
          OM_BLOCK_MOVE( minpt, line[0], sizeof(IGRpoint) );
          OM_BLOCK_MOVE( intpt, line[1], sizeof(IGRpoint) );
          for(i=0; i<3; i++)
             line[0][i] = line[0][i] - line_vec[i] * 2 * chttol;
      }
      else
      {
          OM_BLOCK_MOVE( intpt, line[0], sizeof(IGRpoint) );
          OM_BLOCK_MOVE( maxpt, line[1], sizeof(IGRpoint) );
          for(i=0; i<3; i++)
              line[1][i] = line[1][i] + line_vec[i] * 2 * chttol;
      }
  }
  else
  {
      for(i=0; i<3; i++)
         temp_vec[i] = maxpt[i] - minpt[i];
      BSnorvec( &BSmsg, temp_vec );

      if( (BSdotp( &BSmsg, temp_vec, line_vec) ) > 0.0 )
      {
          for(i=0; i<3; i++)
          {
              minpt[i] -= line_vec[i] * 2 * chttol;
              maxpt[i] += line_vec[i] * 2 * chttol;
          }
          OM_BLOCK_MOVE( minpt, line[0], sizeof(IGRpoint) );
          OM_BLOCK_MOVE( maxpt, line[1], sizeof(IGRpoint) );
      }
      else
      {
          for(i=0; i<3; i++)
          {
              minpt[i] += line_vec[i] * 2 * chttol;
              maxpt[i] -= line_vec[i] * 2 * chttol;
          }
          OM_BLOCK_MOVE( maxpt, line[0], sizeof(IGRpoint) );
          OM_BLOCK_MOVE( minpt, line[1], sizeof(IGRpoint) );
      }
  }

  /*
   * generate the equivalent B-Spline representation for this line
   */
  BSalloccv( (IGRshort) 2, (IGRlong) 2, (IGRshort) 0, (IGRshort) 0, &gencv,
             &BSmsg );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSalloccv error",
      action = GOTO_VALUE, value = wrapup );

  BSptlngen( &BSmsg, line[0], line[1], gencv, &cvtype );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSptlngen error",
      action = GOTO_VALUE, value = wrapup );

  OM_BLOCK_MOVE( gmsf->pt1, inf_line[0], sizeof(IGRpoint) );
  OM_BLOCK_MOVE( gmsf->pt2, inf_line[1], sizeof(IGRpoint) );

  /*
   * Now revolve the line around the axis to generate the surface of
   * revolution ( conical surface ) by the specified sweep angle.
   */
  BSallocsf( gencv->order, BSCIRCLE_ORDER, gencv->num_poles,
             BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &sfgeom, &BSmsg );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSallocsf error",
      action = GOTO_VALUE, value = wrapup );

  BSsts = BSsf_rev( &BSmsg, inf_line[0], inf_line[1], gencv, &full, NULL,
                    NULL, sfgeom );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFcreate_full_cone : BSsf_rev error",
      action = GOTO_VALUE, value = wrapup );

  *newsfgeom = sfgeom;

wrapup :

  EMWRAPUP( OMsts, *EFmsg, "EFcreate_full_cone");
  if( gencv ) BSfreecv( &BSmsg, gencv );
  return OMsts;
}

IGRlong   EFcreate_full_sphere(
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom )
{
   BSrc                  BSmsg;
   IGRlong               OMsts, OMmsg;
   IGRpoint              sph_center;
   IGRdouble             sph_radius;
   IGRushort             loc_opts;
   IGRboolean            BSsts;
   struct IGRbsp_surface *sfgeom;

   OMsts  = OM_S_SUCCESS;
   OMmsg  = EMS_S_Success;
   *EFmsg = EMS_S_Success;
   sfgeom = NULL;
   loc_opts = options;

  // Validate incoming arguments

  if( !gmsf || !slrange || !newsfgeom )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFcreate_full_sphere : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


   /*
    * get the sphere center and radius
    */
   OM_BLOCK_MOVE( gmsf->pt1, sph_center, sizeof(IGRpoint) );
   sph_radius = gmsf->len1;

   /*
    * allocate the memory for full sphere and generate it by center and radius
    */
   BSallocsf( (IGRshort) BSCIRCLE_ORDER, (IGRshort) BSCIRCLE_ORDER,
              (IGRlong) BSCIRCLE_NUM_POLES_MAX, (IGRlong) 5, (IGRboolean) TRUE,
              (IGRshort) 0, &sfgeom, &BSmsg );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFcreate_full_sphere : BSallocsf error",
       action = GOTO_VALUE, value = wrapup );

   BSsts = BSprepsphr( &BSmsg, sph_center, &sph_radius, sfgeom );
   add$status( test = BSERROR(BSmsg)|| !BSsts,msg = *EFmsg,code = EMS_E_BSerror,
       str = "EFcreate_full_sphere : BSprepsphr error",
       action = GOTO_VALUE, value = wrapup );

   *newsfgeom = sfgeom;

wrapup :
  EMWRAPUP( OMsts, *EFmsg, "EFcreate_full_sphere");
  return OMsts;
}

IGRlong   EFcreate_full_torus(
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom )
{
   BSrc                  BSmsg;
   IGRint                i;
   IGRlong               OMsts, OMmsg;
   IGRpoint              axis_pt1, axis_pt2, base_center;
   IGRdouble             base_radius;
   IGRushort             loc_opts;
   struct IGRbsp_surface *sfgeom;

   OMsts  = OM_S_SUCCESS;
   OMmsg  = EMS_S_Success;
   *EFmsg = EMS_S_Success;
   sfgeom = NULL;
   loc_opts = options;

  // Validate incoming arguments

  if( !gmsf || !slrange || !newsfgeom )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFcreate_full_torus : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );



   /*
    * get the base circle radius and center , and the axis points
    */
   OM_BLOCK_MOVE( gmsf->pt1, axis_pt1, sizeof(IGRpoint) );
   for(i=0; i<3; i++)
      axis_pt2[i] = axis_pt1[i] + gmsf->vec1[i] * 10;

   OM_BLOCK_MOVE( gmsf->pt2, base_center, sizeof(IGRpoint) );
   base_radius = gmsf->len1;

   /*
    * allocate the memory for full torus and generate the full torus from the
    * above data
    */
   BSallocsf( (IGRshort) BSCIRCLE_ORDER, (IGRshort) BSCIRCLE_ORDER,
            (IGRlong) BSCIRCLE_NUM_POLES_MAX, (IGRlong) BSCIRCLE_NUM_POLES_MAX,
            (IGRboolean) TRUE, (IGRshort) 0, &sfgeom, &BSmsg );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFcreate_full_torus : BSallocsf error",
       action = GOTO_VALUE, value = wrapup );

   BStoraxctrd( base_radius, base_center, axis_pt1, axis_pt2, sfgeom, &BSmsg);
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFcreate_full_torus : BStoraxctrd error",
       action = GOTO_VALUE, value = wrapup );

   *newsfgeom = sfgeom;

wrapup :
  EMWRAPUP( OMsts, *EFmsg, "EFcreate_full_torus");
  return OMsts;
}

IGRlong   EFcreate_full_sfproj(
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRint                   ndir,
IGRint                   *ext_dir,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom )
{
   BSrc                    BSmsg;
   IGRint                  poly_ext, i;
   IGRlong                 OMsts, OMmsg;
   IGRshort                xform_mattyp = 0;
   IGRpoint                proj_pt1, proj_pt2, proj_pt3, proj_pt4;
   IGRpoint                start_pt, stop_pt, mid_pt, cv_end_point;
   IGRvector               proj_vec, vec;
   IGRdouble               proj_dst, proj_line[2][3], dist, dist1;
   IGRdouble               cv_min[3], cv_max[3];
   IGRushort               loc_opts;
   IGRboolean              cv_closed, poly_right, poly_left;
   IGRboolean              BSsts, u_left, u_right, v_left, v_right, lin_ext;
   struct IGRbsp_curve     *ext_cv, *ext_cv1;
   struct IGRbsp_surface   *sfgeom;
   IGRmatrix               xform_mat;

   OMsts         = OM_S_SUCCESS;
   OMmsg         = EMS_S_Success;
   *EFmsg        = EMS_S_Success;

   ext_cv        = NULL;
   ext_cv1       = NULL;
   sfgeom        = NULL;
   u_left        = FALSE;
   u_right       = FALSE;
   v_left        = FALSE;
   v_right       = FALSE;
   poly_ext      = -1;
   lin_ext       = FALSE;
   cv_closed     = FALSE;
   poly_right    = FALSE;
   poly_left     = FALSE;
   loc_opts      = options;

  // Validate incoming arguments
  if( !gmsf || !ndir || !ext_dir || !slrange || !newsfgeom )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFcreate_full_sfproj : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


   /*
    * get the projection vector
    */
   OM_BLOCK_MOVE( gmsf->vec1, proj_vec, sizeof(IGRpoint) );

   for(i=0; i<ndir; i++)
   {
      if( ext_dir[i] == U_LEFT )       u_left  = TRUE;
      else if( ext_dir[i] == U_RIGHT ) u_right = TRUE;
      else if( ext_dir[i] == V_LEFT )  v_left  = TRUE;
      else if( ext_dir[i] == V_RIGHT ) v_right = TRUE;
   }


   if( gmsf->gencv_ind == 0 )  /* generating curve is in U direciton */
   {
       if( u_left )
       {
           poly_left = TRUE;
           poly_ext = 1;
       }
       if( u_right )
       {
           poly_right = TRUE;
           poly_ext = 1;
       }
       if( v_left || v_right )
           lin_ext = TRUE;
   }
   else  /* generating curve is in V direction */
   {
       if( v_left )
       {
           poly_left = TRUE;
           poly_ext = 1;
       }
       if( v_right )
       {
           poly_right = TRUE;
           poly_ext = 1;
       }
       if( u_left || u_right )
           lin_ext = TRUE;
   }

   /*
    * if the surface is to be extended linearly i.e. along the projection
    * direciton, then project the range box limits of the solid on the
    * projection vector to get exact length of the surface.
    */
   if( lin_ext )
   {

       OM_BLOCK_MOVE( gmsf->pt1, proj_line[0], sizeof(IGRpoint) );
       for(i=0; i<3; i++)
          proj_line[1][i] = proj_line[0][i] + 10 * proj_vec[i];

       BSproj0( &BSmsg, slrange, proj_line, proj_pt1 );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : BSproj0 error",
           action = GOTO_VALUE, value = wrapup );

       BSproj0( &BSmsg, &slrange[3], proj_line, proj_pt2 );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : BSproj0 error",
           action = GOTO_VALUE, value = wrapup );

       BSsts = BSmkvec( &BSmsg, vec, proj_pt1, proj_pt2 );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : BSmkvec error",
           action = GOTO_VALUE, value = wrapup );

       BSnorvec( &BSmsg, vec );

       if( (BSdotp( &BSmsg, vec, proj_vec)) > 0.0 )
           OM_BLOCK_MOVE( proj_pt1, start_pt, sizeof(IGRpoint) );
       else
           OM_BLOCK_MOVE( proj_pt2, start_pt, sizeof(IGRpoint) );

       proj_dst = BSdistptpt( &BSmsg, proj_pt1, proj_pt2 );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : BSdistptpt error",
           action = GOTO_VALUE, value = wrapup );

       /*
        * curve need to be transformed to the statr point
        */
       BSsts = MAcubepy( &BSmsg, gmsf->sfgen_cv, cv_min, cv_max);
       add$status( test = !BSsts || (BSmsg != MSSUCC), msg = *EFmsg,
           code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : MAcubepy error",
           action = GOTO_VALUE, value = wrapup );

       BSproj0( &BSmsg, cv_min, proj_line, proj_pt3 );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : BSproj0 error",
           action = GOTO_VALUE, value = wrapup );

       BSproj0( &BSmsg, cv_max, proj_line, proj_pt4 );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : BSproj0 error",
           action = GOTO_VALUE, value = wrapup );

       BSsts = BSmkvec( &BSmsg, vec, proj_pt3, proj_pt4 );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : BSmkvec error",
           action = GOTO_VALUE, value = wrapup );

       BSnorvec( &BSmsg, vec );

       if( (BSdotp( &BSmsg, vec, proj_vec)) > 0.0 )
           OM_BLOCK_MOVE( proj_pt4, mid_pt, sizeof(IGRpoint) );
       else
           OM_BLOCK_MOVE( proj_pt3, mid_pt, sizeof(IGRpoint) );

       for(i=0; i<3; i++)
           vec[i] = start_pt[i] - mid_pt[i];

       // populate translation matrix

       BSsts = MAtrlmx( &BSmsg, vec, (IGRdouble *) xform_mat );
       add$status( test =!BSsts || !(1&BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : MAtrlmx error",
           action = GOTO_VALUE, value = wrapup );

       // type of the matrix

       BSsts = MAtypemx( &BSmsg, (IGRdouble *) xform_mat, &xform_mattyp );
       add$status( test =!BSsts || !(1&BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : MAtypemx error",
           action = GOTO_VALUE, value = wrapup );

       // recalculate the projection distance

       proj_dst += BSdistptpt( &BSmsg, proj_pt4, proj_pt3 );
   }
   else
   {
       (void) BScveval( gmsf->sfgen_cv, gmsf->sfgen_cv->knots[0],
                        (IGRint) 0, start_pt, &BSmsg );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : BScveval error",
           action = GOTO_VALUE, value = wrapup );

       proj_dst = gmsf->len1;
   }

   for( i=0; i<3; i++ )
        stop_pt[i] = start_pt[i] + proj_dst * proj_vec[i];

   if( xform_mattyp )
   {
       if( gmsf->sfgen_cv->rational )
       {
           BSsts = MArptsxform( &BSmsg, &(gmsf->sfgen_cv->num_poles),
                                &(gmsf->sfgen_cv->rational),
                                gmsf->sfgen_cv->weights,(IGRdouble *)xform_mat,
                                gmsf->sfgen_cv->poles, gmsf->sfgen_cv->poles );
       }
       else
       {
           BSsts = MAoptsxform( &BSmsg, &(gmsf->sfgen_cv->num_poles),
                                &xform_mattyp, (IGRdouble *)xform_mat,
                                gmsf->sfgen_cv->poles, gmsf->sfgen_cv->poles );
       }

       add$status( test = !BSsts || (BSmsg != MSSUCC), msg = *EFmsg,
           code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : MArptsxform/MAoptsxform error",
           action = GOTO_VALUE, value = wrapup );
   }

   if( poly_ext > 0 )
   {
       (void) BScvtstclsd( gmsf->sfgen_cv, &BSmsg );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfproj : BScvtstclsd error",
           action = GOTO_VALUE, value = wrapup );

       cv_closed = gmsf->sfgen_cv->phy_closed;
#ifdef DEBUG
       if(cv_closed)
          printf("generating curve is closed, cannot be extended\n");
#endif
   }

   /*
    * get range box limits of the generating curve. find the distance between
    * range box limits of the generating curve and the solid range box. get
    * the maximum of this distance and extend the curve in specified directions
    */
   if( poly_ext > 0  && !cv_closed )
   {
        BSsts = MAcubepy( &BSmsg, gmsf->sfgen_cv, cv_min, cv_max);
        add$status( test = !BSsts || (BSmsg != MSSUCC), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFcreate_full_sfproj : MAcubepy error",
            action = GOTO_VALUE, value = wrapup );

        dist = BSdistptpt( &BSmsg, cv_min, slrange );
        if( ( dist1 = BSdistptpt( &BSmsg, cv_min, &slrange[3] )) > dist )
            dist = dist1;

        if( ( dist1 = BSdistptpt( &BSmsg, cv_max, &slrange[0] )) > dist )
            dist = dist1;

        if( ( dist1 = BSdistptpt( &BSmsg, cv_max, &slrange[3] )) > dist )
            dist = dist1;

        if( poly_left )
        {
            (void) BScveval( gmsf->sfgen_cv, gmsf->sfgen_cv->knots[0],
                            (IGRint) 0, cv_end_point, &BSmsg );
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfproj : BScveval error",
                action = GOTO_VALUE, value = wrapup );

            BSalloccv( gmsf->sfgen_cv->order,
                       gmsf->sfgen_cv->num_poles + gmsf->sfgen_cv->order - 1,
                       gmsf->sfgen_cv->rational, (IGRshort) 0, &ext_cv,
                       &BSmsg);
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfproj : BSalloccv error",
                action = GOTO_VALUE, value = wrapup );

            BSpolyxtdst( gmsf->sfgen_cv, cv_end_point, dist, ext_cv, &BSmsg );
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfproj : BSpolyxtdst error",
                action = GOTO_VALUE, value = wrapup );
        }
        else
        {
            ext_cv = gmsf->sfgen_cv;
        }

        if( poly_right )
        {
            (void) BScveval( ext_cv, ext_cv->knots[ext_cv->num_knots - 1],
                             (IGRint) 0, cv_end_point, &BSmsg );
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfproj : BScveval error",
                action = GOTO_VALUE, value = wrapup );

            BSalloccv( ext_cv->order, ext_cv->num_poles + ext_cv->order - 1,
                       ext_cv->rational, (IGRshort) 0, &ext_cv1, &BSmsg);
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfproj : BSalloccv error",
                action = GOTO_VALUE, value = wrapup );

            BSpolyxtdst( ext_cv, cv_end_point, dist, ext_cv1, &BSmsg );
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfproj : BSpolyxtdst error",
                action = GOTO_VALUE, value = wrapup );
        }
        else
        {
            ext_cv1 = ext_cv;
        }
   }
   else
   {
      ext_cv1 = gmsf->sfgen_cv;
   }

   /*
    * Now generate the surface of projection using the extended curve
    */
   BSallocsf( ext_cv1->order, (IGRshort) 2, ext_cv1->num_poles, (IGRlong) 2,
              ext_cv1->rational, (IGRshort) 0, &sfgeom, &BSmsg );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFcreate_full_sfproj : BSallocsf error",
       action = GOTO_VALUE, value = wrapup );

   BSsts = BSsf_proj( &BSmsg, ext_cv1, start_pt, stop_pt, sfgeom );
   add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
       code = EMS_E_BSerror,
       str = "EFcreate_full_sfproj : BSsf_proj error",
       action = GOTO_VALUE, value = wrapup );

   *newsfgeom = sfgeom;

wrapup :

  if( ext_cv && ext_cv != gmsf->sfgen_cv )
      BSfreecv( &BSmsg, ext_cv );
  if( ext_cv1 && ext_cv1 != gmsf->sfgen_cv && ext_cv1 != ext_cv )
      BSfreecv( &BSmsg, ext_cv1 );

  EMWRAPUP( OMsts, *EFmsg, "EFcreate_full_sfproj");
  return OMsts;
}

IGRlong   EFcreate_full_sfrevol(
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRint                   ndir,
IGRint                   *ext_dir,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom )
{
   BSrc                    BSmsg;
   IGRint                  poly_ext, i;
   IGRlong                 OMsts, OMmsg;
   IGRpoint                cv_end_point, axis_line[2];
   IGRdouble               dist, dist1, stang, swang, cv_min[3], cv_max[3];
   IGRushort               loc_opts;
   IGRboolean              cv_closed, poly_right, poly_left, full;
   IGRboolean              BSsts, u_left, u_right, v_left, v_right, rad_ext;
   struct IGRbsp_curve     *gen_cv, *ext_cv, *ext_cv1;
   struct IGRbsp_surface   *sfgeom;


   OMsts  = OM_S_SUCCESS;
   OMmsg  = EMS_S_Success;
   *EFmsg = EMS_S_Success;

   ext_cv        = NULL;
   ext_cv1       = NULL;
   sfgeom        = NULL;
   u_left        = FALSE;
   u_right       = FALSE;
   v_left        = FALSE;
   v_right       = FALSE;
   poly_ext      = -1;
   rad_ext       = FALSE;
   cv_closed     = FALSE;
   full          = FALSE;
   stang         = 0;
   swang         = 0;
   poly_right    = FALSE;
   poly_left     = FALSE;
   gen_cv        = NULL;
   loc_opts      = options;

   // Validate incoming arguments
   if( !gmsf || !ndir || !ext_dir || !slrange || !newsfgeom )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFcreate_full_sfrev : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );




   for(i=0; i<ndir; i++)
   {
      if( ext_dir[i] == U_LEFT )       u_left  = TRUE;
      else if( ext_dir[i] == U_RIGHT ) u_right = TRUE;
      else if( ext_dir[i] == V_LEFT )  v_left  = TRUE;
      else if( ext_dir[i] == V_RIGHT ) v_right = TRUE;
   }

   if( gmsf->gencv_ind == 0 )  /* generating curve is in U direciton */
   {
       if( u_left )
       {
           poly_left = TRUE;
           poly_ext = 1;
       }
       if( u_right )
       {
           poly_right = TRUE;
           poly_ext = 1;
       }
       if( v_left || v_right )
           rad_ext = TRUE;
   }
   else  /* generating curve is in V direction */
   {
       if( v_left )
       {
           poly_left = TRUE;
           poly_ext = 1;
       }
       if( v_right )
       {
           poly_right = TRUE;
           poly_ext = 1;
       }
       if( u_left || u_right )
           rad_ext = TRUE;
   }

   if( rad_ext )
   {
       full = TRUE;
   }
   else
       swang = gmsf->len1;

   gen_cv = gmsf->sfgen_cv;

   /*
    * check whether the generating curve is closed or not. If closed, no
    * extension is possible.
    */
   if( poly_ext > 0 )
   {
       (void) BScvtstclsd( gen_cv, &BSmsg );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFcreate_full_sfrev : BScvtstclsd error",
           action = GOTO_VALUE, value = wrapup );

       cv_closed = gen_cv->phy_closed;
#ifdef DEBUG
       if(cv_closed)
          printf("generating curve is closed, cannot be extended\n");
#endif
   }

   /*
    * get range box limits of the generating curve. find the distance between
    * range box limits of the generating curve and the solid range box. get
    * the maximum of this distance and extend the curve in specified directions
    */
   if( poly_ext > 0  && !cv_closed )
   {
        BSsts = MAcubepy( &BSmsg, gen_cv, cv_min, cv_max);
        add$status( test = !BSsts || (BSmsg != MSSUCC), msg = *EFmsg,
            code = EMS_E_BSerror,
            str = "EFcreate_full_sfrev : MAcubepy error",
            action = GOTO_VALUE, value = wrapup );

        dist = BSdistptpt( &BSmsg, cv_min, slrange );
        if( ( dist1 = BSdistptpt( &BSmsg, cv_min, &slrange[3] )) > dist )
            dist = dist1;

        if( ( dist1 = BSdistptpt( &BSmsg, cv_max, &slrange[0] )) > dist )
            dist = dist1;

        if( ( dist1 = BSdistptpt( &BSmsg, cv_max, &slrange[3] )) > dist )
            dist = dist1;

        if( poly_left )
        {
            (void) BScveval( gen_cv, gen_cv->knots[0], (IGRint) 0,
                             cv_end_point, &BSmsg );
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfrev : BScveval error",
                action = GOTO_VALUE, value = wrapup );

            BSalloccv( gen_cv->order, gen_cv->num_poles + gen_cv->order - 1,
                       gen_cv->rational, (IGRshort) 0, &ext_cv, &BSmsg);
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfrev : BSalloccv error",
                action = GOTO_VALUE, value = wrapup );

            BSpolyxtdst( gen_cv, cv_end_point, dist, ext_cv, &BSmsg );
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfrev : BSpolyxtdst error",
                action = GOTO_VALUE, value = wrapup );
        }
        else
        {
            ext_cv = gen_cv;
        }

        if( poly_right )
        {
            (void) BScveval( ext_cv, ext_cv->knots[ext_cv->num_knots - 1],
                             (IGRint) 0, cv_end_point, &BSmsg );
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfrev : BScveval error",
                action = GOTO_VALUE, value = wrapup );

            BSalloccv( ext_cv->order, ext_cv->num_poles + ext_cv->order - 1,
                       ext_cv->rational, (IGRshort) 0, &ext_cv1, &BSmsg);
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfrev : BSalloccv error",
                action = GOTO_VALUE, value = wrapup );

            BSpolyxtdst( ext_cv, cv_end_point, dist, ext_cv1, &BSmsg );
            add$status( test = BSERROR(BSmsg),msg = *EFmsg,code = EMS_E_BSerror,
                str = "EFcreate_full_sfproj : BSpolyxtdst error",
                action = GOTO_VALUE, value = wrapup );
        }
        else
        {
            ext_cv1 = ext_cv;
        }
   }
   else
   {
      ext_cv1 = gen_cv;
   }

   /*
    * Now revolve the extended curve by the specified sweep angle to generate
    * the surface of revolution.
    */
   BSallocsf( ext_cv1->order, BSCIRCLE_ORDER, ext_cv1->num_poles,
              BSCIRCLE_NUM_POLES_MAX, TRUE, 0, &sfgeom, &BSmsg );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFcreate_full_sfrev : BSallocsf error",
       action = GOTO_VALUE, value = wrapup );

   OM_BLOCK_MOVE( gmsf->pt1, axis_line[0], sizeof(IGRpoint) );
   for( i=0; i<3; i++)
        axis_line[1][i] = axis_line[0][i] + 10 * gmsf->vec1[i];

   BSsts = BSsf_rev( &BSmsg, axis_line[0], axis_line[1], ext_cv1,  &full,
                     ((!full) ? &stang : NULL), ((!full) ? &swang : NULL),
                     sfgeom );
   add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
      code = EMS_E_BSerror,
      str = "EFcreate_full_sfrev : BSsf_rev error",
      action = GOTO_VALUE, value = wrapup );

   *newsfgeom = sfgeom;

wrapup :

  if( ext_cv && ext_cv != gen_cv )
      BSfreecv( &BSmsg, ext_cv );
  if( ext_cv1 && ext_cv1 != gen_cv && ext_cv1 != ext_cv )
      BSfreecv( &BSmsg, ext_cv1 );

  EMWRAPUP( OMsts, *EFmsg, "EFcreate_full_sfrevol");
  return OMsts;
}

IGRlong   EFcreate_full_gensf(
IGRlong                  *EFmsg,
IGRushort                options,
struct BSgeom_bsp_surf   *gmsf,
IGRint                   ndir,
IGRint                   *ext_dir,
IGRdouble                *slrange,
struct IGRbsp_surface    **newsfgeom )
{
   BSrc                    BSmsg;
   IGRint                  i;
   IGRlong                 OMsts, OMmsg, total_poles;
   IGRdouble               sfrange[6], dist, dist1, *ext_dst;
   IGRushort               loc_opts;
   IGRboolean              BSsts;

   OMsts   = OM_S_SUCCESS;
   OMmsg   = EMS_S_Success;
   *EFmsg  = EMS_S_Success;

   ext_dst = NULL;
   loc_opts = options;

   // Validate incoming arguments
   if( !gmsf || !ndir || !ext_dir || !slrange || !newsfgeom )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFcreate_full_gensf : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


   total_poles = gmsf->bspsf->u_num_poles * gmsf->bspsf->v_num_poles;

   BSsts = BSbx2( &BSmsg, &total_poles, (IGRpoint *) gmsf->bspsf->poles,
                  ((gmsf->bspsf->rational) ? gmsf->bspsf->weights : NULL),
                  &sfrange[0], &sfrange[3] );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFcreate_full_gensf : BSbx2 error",
       action = GOTO_VALUE, value = wrapup );

   dist = BSdistptpt( &BSmsg, &sfrange[0], &slrange[0] );

   if( (dist1 = BSdistptpt( &BSmsg, &sfrange[0], &slrange[3])) > dist )
       dist = dist1;

   if( (dist1 = BSdistptpt( &BSmsg, &sfrange[3], &slrange[0])) > dist )
       dist = dist1;

   if( (dist1 = BSdistptpt( &BSmsg, &sfrange[3], &slrange[3])) > dist )
       dist = dist1;

   ext_dst = (IGRdouble *) alloca( ndir * sizeof(IGRdouble) );
   add$status( test = !ext_dst, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
       str = "EFcreate_full_gensf : Insufficient Memory",
       action = GOTO_VALUE, value = wrapup );

   for( i=0; i<ndir; i++ )
        ext_dst[i] = dist;

   OMsts = EFextend_gensurface_in_uvdirections( &OMmsg, NULL, gmsf->bspsf,
                                                ndir, ext_dir, ext_dst,
                                                newsfgeom );
   add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
       str = "EFcreate_full_gensf : EFextend_gensurface_in_uvdirections error",
       action = GOTO_VALUE, value = wrapup );

wrapup :
  EMWRAPUP( OMsts, *EFmsg, "EFcreate_full_gensf");
  return OMsts;
}

IGRlong  EFextend_surface_from_rangebox_limits(
IGRlong                  *EFmsg,
IGRushort                options,
struct IGRbsp_surface    *sfgeom,
IGRint                   ndir,
IGRint                   *ext_dir,
IGRdouble                *slrange,
OMuword                  *sfclass,
struct IGRbsp_surface    **newsfgeom )
{
   BSrc                       BSmsg;
   IGRlong                    OMsts, OMmsg;
   struct BSgeom_bsp_surf     gmsf;

   OMsts  = OM_S_SUCCESS;
   OMmsg  = EMS_S_Success;
   *EFmsg = EMS_S_Success;

   // Validate incoming arguments
   if( !sfgeom || !ndir || !ext_dir || !slrange || !newsfgeom )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFextend_surface_from_rangebox_limits : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );



   /* Initialize the local variables */
   memset( &gmsf, 0, sizeof(struct BSgeom_bsp_surf) );

   /* find the type of the surface */
   gmsf.bspsf   = sfgeom;
   gmsf.bounded = TRUE;
   BSsftgeomsf( &gmsf, (IGRboolean) TRUE, (IGRint) 0, &BSmsg );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFextend_surface_from_rangebox_limits : BSsftgeomsf error",
       action = GOTO_VALUE, value = wrapup );

   switch( gmsf.type )
   {
     /* full/partial cylinder */
     case BSFULL_CYL   :
     case BSPART_CYL   :
          OMsts = EFcreate_full_cylinder( &OMmsg, options, &gmsf, slrange,
                                          newsfgeom );
          *sfclass = OPP_EMScylindr_class_id;
          break;

     /* full/partial cone */
     case BSFULL_CONE  :
     case BSPART_CONE  :
          OMsts = EFcreate_full_cone( &OMmsg, options, &gmsf, slrange,
                                      newsfgeom );
          *sfclass = OPP_EMScone_class_id;
          break;

     /* sphere */
     case BSSPHERE :
          *sfclass = OPP_EMSsphere_class_id;
          *newsfgeom = NULL;
          break;

     /* partial sphere */
     case BSPART_SPHERE:
          OMsts = EFcreate_full_sphere( &OMmsg, options, &gmsf, slrange,
                                        newsfgeom );
          *sfclass = OPP_EMSsphere_class_id;
          break;

     /* torus */
     case BSTORUS :
          *sfclass = OPP_EMStorus_class_id;
          *newsfgeom = NULL;
          break;

     /* partial torus */
     case BSPART_TORUS :
          OMsts = EFcreate_full_torus( &OMmsg, options, &gmsf, slrange,
                                        newsfgeom );
          *sfclass = OPP_EMStorus_class_id;
          break;

     /* surface of projection */
     case BSSF_OF_PROJ :
          OMsts = EFcreate_full_sfproj( &OMmsg, options, &gmsf, ndir, ext_dir,
                                        slrange, newsfgeom );
          *sfclass = OPP_EMSproject_class_id;
          break;

     /* surface of revolution */
     case BSSF_OF_REV  :
          OMsts = EFcreate_full_sfrevol( &OMmsg, options, &gmsf, ndir, ext_dir,
                                        slrange, newsfgeom );
          *sfclass = OPP_EMSrevol_class_id;
          break;

     /* general B-spline surface */
     case BSGEN_BSP_SF :
          OMsts = EFcreate_full_gensf( &OMmsg, options, &gmsf, ndir, ext_dir,
                                        slrange, newsfgeom );
          *sfclass = OPP_EMSgenbs_class_id;
          break;

     default :
          *EFmsg = EMS_E_InvalidArg;
          *newsfgeom = NULL;
          goto wrapup;
   }

   if( *newsfgeom )
       (*newsfgeom)->pos_orient = sfgeom->pos_orient;

wrapup :

   EMWRAPUP( *EFmsg, OMsts, "EFextend_surface_from_rangebox_limits");
   return OMsts;
}

IGRlong    EFextend_surface(
IGRlong                 *EFmsg,
IGRushort               options,
struct GRvg_construct   *cons_list,
IGRint                  ndir,
IGRint                  *ext_dir,
struct GRid             *slgrid,
IGRdouble               *slrange,
struct GRid             *sfgrid,
struct IGRbsp_surface   *sfgeom,
struct IGRbsp_surface   **newsfgeom )
{
  /* general variables */
  BSrc                      BSmsg;
  IGRint                    i, j, count, iter;
  IGRlong                   OMsts, OMmsg;
  GRrange                   loc_slrange;
  OMuword                   classid = 0;
  IGRshort                  mat_type;
  IGRdouble                 *mat, partol, UMIN, VMIN, UMAX, VMAX, loctol;
  IGRushort                 bool_options, grp_options;
  IGRboolean                is_solid, world = TRUE, BSsts, dont_free_geom;
  struct GRid               ext_sfgrid;
  struct IGRbsp_surface     *sfgeom1, *partsfgeom;

  /* variables for Intersection operation */
  IGRint                 num_inters;
  IGRchar                status_str[54];
  IGRushort              inters_opt, outworld_opt, outparam_opt, trim_opt;
  IGRboolean             handle_stop;
  IGRboolean             output_intersection, output_aux, no_topology;
  IGRboolean             double_chk, op_switch, openint_valid, single_topology;
  enum EMSbooltype       bool_type;
  struct EMSinters       *sfinters[2];
  struct EMSdataselect   sfs2data;
  struct EMSsftracedata  sftrace[2], *trace_info;

  /* variables required for extracting the part of the surface */
  IGRint                 num_closed_groups, grp_num;
  IGRdouble              umin, umax, vmin, vmax, lentol;
  IGRdouble              par1[2], par2[2], par3[2];
  IGRdouble              vint;
  IGRdouble              intu;

  IGRboolean             u_closed=FALSE, v_closed=FALSE;

  extern IGRlong         EFsspbtol_by_geom();

  /* Initialize the local variables */
  OMsts  = OM_S_SUCCESS;
  OMmsg  = EMS_S_Success;
  *EFmsg = EMS_S_Success;

  is_solid         = FALSE;
  ext_sfgrid.objid = NULL_OBJID;
  ext_sfgrid.osnum = slgrid->osnum;
  partsfgeom       = NULL;
  dont_free_geom   = FALSE;
  sfgeom1          = NULL;
  grp_options      = NULL;

  mat = cons_list->env_info->md_env.matrix;
  mat_type = cons_list->env_info->md_env.matrix_type;
  strcpy (status_str, "Processing");
  for( count=FIRST; count<=SECOND; count++ )
  {
      sfinters[count]            = NULL;
      memset( &sftrace[count], 0, sizeof(struct EMSsftracedata) );
  }

  num_closed_groups = 0;
  grp_num = -1;
  vint = -1.0;
  intu = -1.0;
  UMAX = UMIN = VMAX = VMIN = 0.0;
  umin = umax = vmin = vmax = 0.0;

  /* Validate the incoming arguments */
  if( !EFmsg || !cons_list || !slgrid || !sfgeom || !newsfgeom )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFextend_surface : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


  BSEXTRACTPAR( &BSmsg, BSTOLLENVEC, lentol );
  BSEXTRACTPAR( &BSmsg, BSTOLPARAM, partol );

  /*
   * get the solid range box
   */
  if( !slrange )
  {
      OMsts = om$send( msg = message GRvg.GRgetrang( &OMmsg, &mat_type, mat,
                                                     &world, loc_slrange ),
                       senderid = NULL_OBJID,
                       targetid = slgrid->objid,
                       targetos = slgrid->osnum );
      add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFextend_surface : GRgetrang error",
          action = GOTO_VALUE, value = wrapup );
  }
  else
  {
      OM_BLOCK_MOVE( slrange, loc_slrange, sizeof(GRrange) );
  }

  /*
   * create a surface from the solid range box limits
   */
  OMsts = EFextend_surface_from_rangebox_limits( &OMmsg, options, sfgeom,
                                                 ndir, ext_dir, loc_slrange,
                                                 &classid, &sfgeom1 );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFextend_surface : EFextend_surface_from_rangebox_limits error",
      action = GOTO_VALUE, value = wrapup );

  if( !sfgeom1 )
  {
      dont_free_geom = TRUE;
      sfgeom1 = sfgeom;
  }

  OMsts = EFcreate_exact_surface( &OMmsg, cons_list, classid, sfgeom1,
                                  &ext_sfgrid );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFextend_surface : EFcreate_exact_surface error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * get the class id and determine whether given slgrid belongs to
   * surface or solid class
   */
  OMsts = om$get_classid( objid = slgrid->objid,
                          osnum = slgrid->osnum,
                          p_classid = &classid );

  if( classid == OPP_EMSsolid_class_id ||
      (om$is_ancestry_valid( subclassid = classid,
      superclassid = OPP_EMSsolid_class_id) == OM_S_SUCCESS) )
      is_solid = TRUE;

  // Now initialize all the options

  bool_options = EMSsfbool_opt_OpenIntPossible;
  bool_type = EMSbool_saveside;
  if( !is_solid )
      bool_options |= EMSsfbool_opt_SingleTopology;

  op_switch           = bool_options & EMSsfbool_opt_OperandsSwitched;
  double_chk          = bool_options & EMSsfbool_opt_doublecheck;
  output_aux          = bool_options & EMSsfbool_opt_outaux;
  handle_stop         = bool_options & EMSsfbool_opt_HandleStop;
  openint_valid       = bool_options & EMSsfbool_opt_OpenIntPossible;
  single_topology     = bool_options & EMSsfbool_opt_SingleTopology;
  output_intersection = bool_options & EMSsfbool_opt_outinters;
  if( output_intersection || output_aux )
      no_topology = TRUE;
  else
      no_topology = FALSE;

  outworld_opt = EMSINT_OUTPUT_WORLD | EMSINT_WORLD_NOTYPEDCV;
  outparam_opt = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT |
                 EMSINT_ORIENT_OUTPUT | (bool_type == EMSbool_intersect ?
                                         EMSINT_ORIENT_RIGHT : NULL);
  trim_opt     = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_BDRYISAREA |
                 EMSINT_TRIM_COPLANAR |
                 (double_chk ? EMSINT_TRIM_MOREPRECISE |
                               EMSINT_TRIM_PROCOVERLAP : NULL) |
                 (bool_type == EMSbool_intersect ? EMSINT_TRIM_ONLYCUTTING :
                               NULL);
  inters_opt   = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_MUSTORIENT |
                 EMS_SFINT_PUSHBADCOINC |
                 (bool_type == EMSbool_difference ||
                  bool_type == EMSbool_saveside ?
                  EMS_SFINT_REVERSESECONDINT : NULL) |
                 (double_chk ? NULL : EMS_SFINT_MUSTNOAMBIGUOUS) |
                 (openint_valid ? NULL : EMS_SFINT_MUSTCLOSE) |
                 (double_chk ? EMS_SFINT_DOUBLECHECK : NULL) |
                 (handle_stop ? EMS_SFINT_HANDLESTOP : NULL);

  num_inters = 0;
  sfs2data.datatype = EMSdata_object;
  sfs2data.data.object = &ext_sfgrid;
  /*
   * Get the Intersection and trace data of the surfaces
   */
  OMsts = EMintersect_surfaces( &OMmsg, slgrid, &cons_list->env_info->md_env,
                      1, &sfs2data, &cons_list->env_info->md_env, inters_opt,
                      outworld_opt,
                      outparam_opt, trim_opt, cons_list, &num_inters,
                      &sfinters[FIRST], &sfinters[SECOND], &sftrace[FIRST],
                      &sftrace[SECOND], NULL, NULL, status_str );
#ifdef DEBUG
  if( OMmsg == EMS_E_NoIntersection )
      printf("No Intersection with the surface\n");
  else if( OMmsg == EMS_E_IntersectClosure )
      printf("Intersection curve is not closed\n");
  else if( OMmsg == EMS_E_IntersClosureOrient )
      printf("Can not orient the closed intersection \n");
  else if( OMmsg == EMS_E_IntersectOrient )
      printf("Can not orient the intersection \n");
  else if( OMmsg == EMS_E_Ambiguous )
      printf("Ambiguous\n");
#endif

  // for no interseciton
  add$status( test = !num_inters || (OMmsg == EMS_E_NoIntersection),
      msg = *EFmsg, code = EMS_E_Fail,
      str = "EFextend_surface : EMintersect_surfaces : Surface doesn't intersect with the solid",
      action = GOTO_VALUE, value = wrapup );

  // all other errors
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFextend_surface : EMintersect_surfaces error",
      action = GOTO_VALUE, value = wrapup );

  // get the number of closed groups. if there is not any then error out.

  num_closed_groups = 0;
  for( count=0; count<sftrace[SECOND].num_grps; count++ )
     if( sftrace[SECOND].grp_closed[count] )
         num_closed_groups ++;

  add$status( test = !num_closed_groups, msg = *EFmsg, code = EMS_E_Fail,
      str = "EFextend_surface : No closed groups at all",
      action = GOTO_VALUE, value = wrapup );

  if( sfgeom1->u_phy_closed )
      grp_options = U_CLOSED;
  if( sfgeom1->v_phy_closed )
      grp_options |= V_CLOSED;

  if (options & KEEP_ALL_GROUPS)
  {
      IGRint    knt=0;
      IGRdouble grp_range[4], int_range[2];

      for (count=0, knt=0; count<sftrace[SECOND].num_grps; count++)
      {
        if (sftrace[SECOND].grp_closed[count])
        {
          OMsts = EFget_group_range (&OMmsg, grp_options, count,
                                     &sftrace[SECOND], grp_range,
                                     (grp_options ? int_range : NULL) );
          add$status (test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
              str = "EFextend_surface : EFget_group_range error",
              action = GOTO_VALUE, value = wrapup);

          if (sfgeom1->u_phy_closed || sfgeom1->v_phy_closed)
          {
            intu = int_range[0];
            vint = int_range[1];
          }

          if (knt == 0)
          {
            umin = grp_range[0]; vmin = grp_range[1];
            umax = grp_range[2]; vmax = grp_range[3];
          }
          else
          {
            if (grp_range[0] < umin) umin = grp_range[0];
            if (grp_range[1] < vmin) vmin = grp_range[1];
            if (grp_range[2] > umax) umax = grp_range[2];
            if (grp_range[3] > vmax) vmax = grp_range[3];
          }

          knt ++;
        }
      }
  }
  else if( num_closed_groups == 1 )
  {
      IGRdouble    grp_range[4], int_range[2];

      for( count=0; count<sftrace[SECOND].num_grps; count++ )
         if( sftrace[SECOND].grp_closed[count] )
         {
             grp_num = count;
             break;
         }


      OMsts = EFget_group_range( &OMmsg, grp_options, grp_num,&sftrace[SECOND],
                                 grp_range, (grp_options ? int_range : NULL) );
      add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
          str = "EFextend_surface : EFget_group_range error",
          action = GOTO_VALUE, value = wrapup );

      umin = grp_range[0]; vmin = grp_range[1];
      umax = grp_range[2]; vmax = grp_range[3];
      if( sfgeom1->u_phy_closed || sfgeom1->v_phy_closed )
      {
          intu = int_range[0];
          vint = int_range[1];
      }
  }
  else
      /*
       * As the number of closed groups is more than one, we need to find out
       * which closed group is containing the actual surface. We need to ext-
       * ract only that part of the surface containing this closed group.
       */
  {
     IGRuint             attempt_no;
     IGRpoint            sfpt, base;
     IGRdouble           u, v, dist, *grp_ranges, *int_ranges;
     IGRboolean          found = FALSE;

     iter = 0;
     attempt_no = 100;
     grp_ranges = NULL;
     int_ranges = NULL;

     /*
      * allocate the ranges for each group uv range and intermediate points
      * of the range box if the surface is closed in one of the directions
      * which will help in extracting a part surface.
      */
     grp_ranges = (IGRdouble *) alloca( num_closed_groups * 4 *
                                        sizeof(IGRdouble));
     add$status( test = !grp_ranges, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
         str = "EFextend_surface : Insufficient Memory",
         action = GOTO_VALUE, value = wrapup );

     if( sfgeom1->u_phy_closed || sfgeom1->v_phy_closed )
     {
         int_ranges = (IGRdouble *) alloca( num_closed_groups * 2 *
                                        sizeof(IGRdouble));
         add$status( test = !int_ranges, msg = *EFmsg,
             code = EMS_E_NoDynamicMemory,
             str = "EFextend_surface : Insufficient Memory",
             action = GOTO_VALUE, value = wrapup );
     }

     do
     {
         /*
          * get an internal point in area on the original surface
          */
         OMsts = om$send( msg = message EMSsurface.EMget_point_on_surface(
                                        &OMmsg, cons_list->env_info, attempt_no,
                                        1, sfpt, NULL ),
                          senderid = NULL_OBJID,
                          targetid = sfgrid->objid,
                          targetos = sfgrid->osnum );
         add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
             str = "EFextend_surface : EMget_point_on_surface error",
             action = GOTO_VALUE, value = wrapup );

         /*
          * get the minimum distance point on the new surface ( with which
          * the intersection took place )
          */
         BSsts = BSmdistptsf( &BSmsg, sfgeom1, sfpt, &u, &v, base, &dist );
         add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
             code = EMS_E_BSerror,
             str = "EFextend_surface : BSmdistptsf error",
             action = GOTO_VALUE, value = wrapup );

         /*
          * if for the first time get the each groups range and find whether
          * the the above calculated point is with in the range box of group
          * or not.
          */
         for( i=0, j=0; i<sftrace[SECOND].num_grps; i++ )
         {
             if( sftrace[SECOND].grp_closed[i] )
             {
                if(!iter)
                 {
                    OMsts = EFget_group_range( &OMmsg, grp_options, i,
                                               &sftrace[SECOND],
                                               &grp_ranges[j*4], (int_ranges ?
                                               &int_ranges[j*2] : NULL) );
                    add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg,
                        code = EMS_E_Fail,
                        str = "EFextend_surface : EFget_group_range error",
                        action = GOTO_VALUE, value = wrapup );
                 }

                 /* if loop modified to solve from -to cylinders add material
                  * problem - add - rem enhancements - Sp.Balamurugan */

                 if( ((grp_options & U_CLOSED) ?
                        ((u <= grp_ranges[j*4] && u >= grp_ranges[j*4+2]) ||
                        (u >= grp_ranges[j*4] && u <= grp_ranges[j*4+2])):
                        (u >= grp_ranges[j*4] && u <= grp_ranges[j*4+2])) &&
                     ((grp_options & V_CLOSED) ?
                        ((v <= grp_ranges[j*4+1] && v >= grp_ranges[j*4+3]) ||
                        (v >= grp_ranges[j*4+1] && v <= grp_ranges[j*4+3])) :
                        (v >= grp_ranges[j*4+1] && v <= grp_ranges[j*4+3])) )
                 {
                    found = TRUE;
                    grp_num = i;
                    umin = grp_ranges[j*4];
                    vmin = grp_ranges[j*4 + 1];
                    umax = grp_ranges[j*4 + 2];
                    vmax = grp_ranges[j*4 + 3];
                    if( int_ranges )
                    {
                        intu = int_ranges[j*2];
                        vint = int_ranges[j*2 + 1];
                    }
                    break;
                 }

                 j++;
             }
         }

         if( found ) break;
         attempt_no += 10;

     } while( iter++ < MAXITER );

     if( !found )
     {
#ifdef DEBUG
  printf("Unable to find the right group, Selecting the first closed group\n");
#endif
         for( i=0, j=0; i<sftrace[SECOND].num_grps; i++ )
         {
             if( sftrace[SECOND].grp_closed[i] )
             {
                 grp_num = i;
                 umin = grp_ranges[j*4];
                 vmin = grp_ranges[j*4 + 1];
                 umax = grp_ranges[j*4 + 2];
                 vmax = grp_ranges[j*4 + 3];
                 if( int_ranges )
                 {
                     intu = int_ranges[j*2];
                     vint = int_ranges[j*2 + 1];
                 }
             }
         }
     }
  }

  if (sfgeom1->u_phy_closed && intu < 0)
  {
#ifdef DEBUG
      printf(" Intermediate u value is not calculated properly\n");
#endif
      intu = (umin + umax) / 2.0;
      if( intu > UMAX ) intu -= UMAX;
  }

  if (sfgeom1->v_phy_closed && vint < 0)
  {
#ifdef DEBUG
     printf(" Intermediate v value is not calculated properly\n");
#endif
      vint = (vmin + vmax) / 2.0;
      if( vint > VMAX ) vint -= VMAX;
  }


/*******
  OMsts = EFsspbtol_by_geom( &OMmsg, sfgeom1, &partol );
  EMerr_hndlr( !(1&OMsts&OMmsg), *EFmsg, EMS_E_SurfaceError, wrapup );
*******/

  UMIN = sfgeom1->u_knots[0]; VMIN = sfgeom1->v_knots[0];
  UMAX = sfgeom1->u_knots[sfgeom1->u_num_knots-1];
  VMAX = sfgeom1->v_knots[sfgeom1->v_num_knots-1];

  par1[0] = umin; par1[1] = vmin;
  par3[0] = umax; par3[1] = vmax;
  par2[0] = intu; par2[1] = vint;

  if (sfgeom1->u_phy_closed && fabs(intu - 0.0) < partol)
    u_closed = TRUE;

  if (sfgeom1->v_phy_closed && fabs(vint - 0.0) < partol)
    v_closed = TRUE;

  loctol = partol * 10e+6;
  iter = 0;

  if (!u_closed)
  {
     do
     {
        if( (umin - loctol) > UMIN )
        {
           par1[0] = (umin - loctol);
           break;
        }
        else loctol *= 0.5;
     } while( iter++ < MAXITER );
  }
  else
  {
     do
     {
        if( (umin + loctol) < UMAX )
        {
          par1[0] = umin + loctol;
          break;
        }
        else loctol *= 0.5;
     } while( iter++ < MAXITER );

  }

  loctol = partol * 10e+6;
  iter = 0;

  if (!v_closed)
  {
     do
     {
        if( (vmin - loctol) > VMIN )
        {
           par1[1] = (vmin - loctol);
           break;
        }
        else loctol *= 0.5;
     } while( iter++ < MAXITER );
  }
  else
  {
     do
     {
       if( (vmin + loctol) < VMAX )
       {
           par1[1] = vmin + loctol;
           break;
       }
       else loctol *= 0.5;
     } while( iter++ < MAXITER );

  }


  loctol = partol * 10e+6;
  iter = 0;

  if (!u_closed)
  {
     do
     {
        if( (umax + loctol) < UMAX )
        {
           par3[0] = (umax + loctol);
           break;
        }
        else loctol *= 0.5;
     } while( iter++ < MAXITER );
  }
  else
  {
     do
     {
       if( (umax - loctol) > UMIN )
       {
           par3[0] = umax - loctol;
           break;
        }
        else loctol *= 0.5;
     } while( iter++ < MAXITER );

  }


  loctol = partol * 10e+6;
  iter = 0;

  if (!v_closed)
  {
     do
     {
        if( (vmax + loctol) < VMAX )
        {
           par3[1] = (vmax + loctol);
           break;
        }
        else loctol *= 0.5;
     } while( iter++ < MAXITER );
  }
  else
  {
     do
     {
       if( (vmax - loctol) > VMIN )
       {
           par3[1] = vmax - loctol;
           break;
       }
       else loctol *= 0.5;
     } while( iter++ < MAXITER );
  }

  if (options & KEEP_ALL_GROUPS)
  {
    if (sfgeom1->u_phy_closed)
    {
      par1[0] = UMIN;  par3[0] = UMAX;
      par2[0] = (par1[0] + par3[0]) / 2.0;
    }

    if (sfgeom1->v_phy_closed)
    {
      par1[1] = VMIN;  par3[1] = VMAX;
      par2[1] = (par1[1] + par3[1]) / 2.0;
    }
  }

  /*
   * Now extract part of the surface using min and max range box limits.
   */
  // allocate memory for the partial surface
  BSallocsf( sfgeom1->u_order, sfgeom1->v_order,
             sfgeom1->u_num_poles + 2 * sfgeom1->u_order - 1,
             sfgeom1->v_num_poles + 2 * sfgeom1->v_order - 1,
             sfgeom1->rational, sfgeom1->num_boundaries, &partsfgeom, &BSmsg );
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFextend_surface : BSallocsf error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * Now extract part of the surface by using the above parameters.
   */
  BSpartofsf( sfgeom1, par1, par2, par3, (IGRint) 2, partsfgeom, &BSmsg);
  add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
      str = "EFextend_surface : BSpartofsf error",
      action = GOTO_VALUE, value = wrapup );

  partsfgeom->pos_orient = sfgeom1->pos_orient;

  *newsfgeom = partsfgeom;

wrapup :

  EMWRAPUP( *EFmsg, OMsts, "EFextend_surface");
  /*
   * Free the trace Information
   */
  for( count=FIRST; count<=SECOND; count++ )
  {
      trace_info = &sftrace[count];
      EMsfinttrace_free( &OMmsg, trace_info->num_grps,
          trace_info->num_subgrps_grp, trace_info->num_elems_subgrp,
          trace_info->elems, trace_info->subgrp_rev, trace_info->elem_rev,
          trace_info->grp_closed, trace_info->subgrp_closed );
  }

  /*
   * Free intersection data
   */
  for( count=FIRST; count <= SECOND; count++ )
  {
      EMinters_data_free( &OMmsg, sfinters[count], MAXINT, NULL,
                         EMsfintedpar_free );
      EMinters_free( sfinters[count], MAXINT );
  }

  /*
   * Delete the big extended surface created
   */
  if( ext_sfgrid.objid != NULL_OBJID )
  {
      OMsts = om$send( msg = message GRgraphics.GRdelete( &OMmsg,
                                           cons_list->env_info ),
                       senderid = NULL_OBJID,
                       targetid = ext_sfgrid.objid,
                       targetos = ext_sfgrid.osnum );
  }

  /*
   * Free the surface geometry created using range box limits of the solid
   */
  if( !dont_free_geom && sfgeom1 ) om$dealloc( ptr = sfgeom1 );

  return OMsts;
}

IGRlong EFcreate_exact_surface(
IGRlong                 *EFmsg,
struct GRvg_construct   *cons_list,
OMuword                 sfclass,
struct IGRbsp_surface   *sfgeom,
struct GRid             *sfgrid )
{
  BSrc                    BSmsg;
  IGRlong                 OMsts, OMmsg;
  OMuword                 classid = 0;
  struct BSgeom_bsp_surf  gmsf;


  OMsts   = OM_S_SUCCESS ;
  OMmsg   = EMS_S_Success;
  *EFmsg  = EMS_S_Success;

  if( !cons_list || !sfgeom || !sfgeom || !sfgrid )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFcreate_exact_surface : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


  if( !sfclass )
  {
      /* find the type of the surface */
      memset( &gmsf, 0, sizeof(struct BSgeom_bsp_surf) );
      gmsf.bspsf   = sfgeom;
      gmsf.bounded = TRUE;
      BSsftgeomsf( &gmsf, (IGRboolean) TRUE, (IGRint) 0, &BSmsg );
      add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
          str = "EFcreate_exact_surface : BSsftgeomsf error",
          action = GOTO_VALUE, value = wrapup );

      /*
       * Construct the surface of exact class from the given geometry.
       */
      switch( gmsf.type )
      {
         case BSFULL_CYL :
              classid = OPP_EMScylindr_class_id;
              break;

         case BSPART_CYL :
              classid = OPP_EMSpcylindr_class_id;
              break;

         case BSFULL_CONE :
              classid = OPP_EMScone_class_id;
              break;

         case BSPART_CONE :
              classid = OPP_EMSpcone_class_id;
              break;

         case BSTORUS :
              classid = OPP_EMStorus_class_id;
              break;

         case BSPART_TORUS :
              classid = OPP_EMSptorus_class_id;
              break;

         case BSSPHERE :
              classid = OPP_EMSsphere_class_id;
              break;

         case BSPART_SPHERE :
              classid = OPP_EMSpsphere_class_id;
              break;

         case BSSF_OF_PROJ :
              classid = OPP_EMSproject_class_id;
              break;

         case BSSF_OF_REV :
              classid = OPP_EMSrevol_class_id;
              break;

         case BSGEN_BSP_SF :
              classid = OPP_EMSgenbs_class_id;
              break;
      }
  }
  else
      classid = sfclass;

  *(cons_list->msg)   = EMS_S_Success;
  cons_list->geometry = (IGRchar *) sfgeom;

  sfgrid->osnum = cons_list->env_info->md_id.osnum;

  OMsts = om$construct( classid = classid,
                        p_objid = &sfgrid->objid,
                        msg     = message GRgraphics.GRconstruct( cons_list ),
                      );
  add$status( test = !(1&OMsts&*(cons_list->msg)), msg = *EFmsg,
      code = EMS_E_Fail,
      str = "EFcreate_exact_surface : om$construct error",
      action = GOTO_VALUE, value = wrapup );

  /*
   * create a natural loopset on the surface if there is not any
   */
  OMsts = om$send( msg = message EMSsurface.EMputLsIfNotThere( &OMmsg,
                                 &cons_list->env_info->md_env, NULL, NULL,
                                 NULL, NULL ),
                   senderid = NULL_OBJID,
                   targetid = sfgrid->objid,
                   targetos = sfgrid->osnum );
  add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
      str = "EFcreate_exact_surface : EMputLsIfNotThere error",
      action = GOTO_VALUE, value = wrapup );


wrapup :
   return OMsts;
}

IGRlong  EFget_group_range(
IGRlong                *EFmsg,
IGRushort              options,
IGRint                 grp_num,
struct EMSsftracedata  *sftrace,
IGRdouble              *range,
IGRdouble              *intpar )
{
  BSrc                 BSmsg;
  IGRint               i,j,count, num_pts;
  IGRlong              OMsts, OMmsg;
  IGRdouble            uvrange[4], umin, vmin, umax, vmax, intu, vint, lentol;
  IGRdouble            *pts;
  struct GRid          *edge;
  struct EMSintobj     *intobj;
  struct IGRpolyline   poly;

  // Initialize the return status
  OMsts   = OM_S_SUCCESS;
  OMmsg   = EMS_S_Success;
  *EFmsg  = EMS_S_Success;

  // Initialize the local variables
  intu = vint = -1.0;
  edge        = NULL;
  intobj      = NULL;
  poly.points = NULL;
  umin = umax = 0.0;
  vmin = vmax = 0.0;
  lentol = 0.0;
  num_pts = 0;
  pts     = NULL;

  // Validate the incoming arguments
  if( !sftrace || !range )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFget_group_range : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


  BSEXTRACTPAR( &BSmsg, BSTOLLENVEC, lentol );

  /*
   * get the maximum and minimum u and v parameters of the intobjs.
   */
  for( i=0; i<sftrace->num_subgrps_grp[grp_num]; i++ )
  {
       intobj = sftrace->elems[grp_num][i];
       for( j=0; j<sftrace->num_elems_subgrp[grp_num][i]; j++ )
       {
            /*
             * get uv range box of the intobj
             */
            if( intobj->this_uvintobj.datatype == EMSdata_object )
            {
                edge = intobj->this_uvintobj.data.object;
                poly.num_points = 0;
                poly.points     = NULL;
                OMsts = om$send( msg = message EMSedge.EMgetpygeom( &OMmsg,
                                               (IGRint) 0, (IGRint) MAXINT,
                                               FALSE, NULL, &poly, NULL, NULL),
                                 senderid = NULL_OBJID,
                                 targetid = edge->objid,
                                 targetos = edge->osnum );
                add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg,
                    code = EMS_E_Fail,
                    str = "EFget_group_range : EMgetpygeom error",
                    action = GOTO_VALUE, value = wrapup );

            }
            else if( intobj->this_uvintobj.datatype == EMSdata_poly2d ||
                     intobj->this_uvintobj.datatype == EMSdata_poly3d )
            {
                poly = *(intobj->this_uvintobj.data.poly);
            }
            else
            {
                add$status( test = TRUE, msg = *EFmsg, code = EMS_E_Fail,
                    str = "EFget_group_range : Invalid Intobj data type",
                    action = GOTO_VALUE, value = wrapup );
            }

            if( options )
            {
                num_pts += poly.num_points;
                if( !pts )
                {
                    pts = (IGRdouble *) om$malloc( size  = num_pts * 2 *
                                                           sizeof(IGRdouble) );
                }
                else
                {
                    pts = (IGRdouble *) om$realloc( ptr  = (char *) pts,
                                                    size = num_pts * 2 *
                                                           sizeof(IGRdouble) );
                }
                add$status( test = !pts, msg = *EFmsg,
                    code = EMS_E_NoDynamicMemory,
                    str = "EFget_group_range : Insufficient Memory",
                    action = GOTO_VALUE, value = wrapup );

                OM_BLOCK_MOVE( poly.points,
                               &pts[2 * (num_pts - poly.num_points)],
                               poly.num_points * 2 * sizeof(IGRdouble) );

            }
            else
            {
                EM2dbx( poly.num_points, poly.points, uvrange );

            /*
             * update the min and maximum u v params
             */
            if( i==0 && j==0 )
            {
                umin = uvrange[0];
                vmin = uvrange[1];
                umax = uvrange[2];
                vmax = uvrange[3];

                /*
                 * intermediate u and v parameters
                 */
                if( intpar )
                {
                   for( count=0; count<poly.num_points; count ++ )
                   {
                      if( ((fabs(poly.points[count*2] - umin)) > lentol) &&
                          ((fabs(poly.points[count*2] - umax)) > lentol) )
                      {
                          intu = poly.points[count*2];
                          break;
                      }
                   }
                }

                if( intpar )
                {
                   for( count=0; count<poly.num_points; count ++ )
                   {
                      if( ((fabs(poly.points[count*2+1] - vmin)) > lentol) &&
                          ((fabs(poly.points[count*2+1] - vmax)) > lentol) )
                      {
                          vint = poly.points[count*2+1];
                          break;
                      }
                   }
                }
            }
            else
            {
                if( uvrange[0] < umin ) umin = uvrange[0];
                if( uvrange[1] < vmin ) vmin = uvrange[1];
                if( uvrange[2] > umax ) umax = uvrange[2];
                if( uvrange[3] > vmax ) vmax = uvrange[3];

                if( intpar && intu < 0 )
                {
                   for( count=0; count<poly.num_points; count ++ )
                   {
                      if( ((fabs(poly.points[count*2] - umin)) > lentol) &&
                          ((fabs(poly.points[count*2] - umax)) > lentol) )
                      {
                          intu = poly.points[count*2];
                          break;
                      }
                   }
                }

                if( intpar && vint < 0 )
                {
                   for( count=0; count<poly.num_points; count ++ )
                   {
                      if( ((fabs(poly.points[count*2+1] - vmin)) > lentol) &&
                          ((fabs(poly.points[count*2+1] - vmax)) > lentol) )
                      {
                          vint = poly.points[count*2+1];
                          break;
                      }
                   }
               }
           }

           }

           /*
            * Free the poly2d points if they are extracted by using EMgetpygeom
            * method.
            */
           if( intobj->this_uvintobj.datatype == EMSdata_object )
           {
               if( poly.points) om$dealloc( ptr = (poly.points) );
               poly.points = NULL;
           }

           intobj = intobj->next;
       }
   }

   if( options )
   {
       EFget_closed_group_range( &OMmsg, num_pts, pts, options, uvrange,
                                 intpar );
       add$status( test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
           str = "EFget_group_range : EFget_closed_group_range error",
           action = GOTO_VALUE, value = wrapup );

       umin = uvrange[0]; vmin = uvrange[1];
       umax = uvrange[2]; vmax = uvrange[3];
       intu = intpar[0] ; vint = intpar[1] ;
   }

   if( intpar && intu < 0 )
   {
#ifdef DEBUG
       printf(" Intermediate u value is not calculated properly\n");
#endif
       intu = (umin + umax) / 2.0;
   }

   if( intpar && vint < 0 )
   {
#ifdef DEBUG
       printf(" Intermediate u value is not calculated properly\n");
#endif
       vint = (vmin + vmax) / 2.0;
   }

   range[0] = umin; range[1] = vmin;
   range[2] = umax; range[3] = vmax;

   if( intpar )
   {
       intpar[0] = intu;
       intpar[1] = vint;
   }

wrapup :

   EMWRAPUP( OMsts, *EFmsg, "EFget_group_range");
   return OMsts;
}

void EFget_bounded_plane_from_rangebox(
IGRlong               *EFmsg,
IGRdouble             *range,
struct IGRplane       *plane,
struct IGRbsp_surface *BSplane )
{
    BSrc             BSmsg;
    IGRint           i;
    IGRboolean       BSsts, sts;
    IGRdouble        line[2][3];
    IGRpoint         pt1, pt2, pt3;
    IGRvector        vec;

    if( !range || !plane || !BSplane )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFget_bounded_plane_from_rangebox : Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );


    sts     = TRUE;
    BSsts   = TRUE;
    *EFmsg  = EMS_S_Success;

    BSsts = BSproj1( &BSmsg, range, plane->normal, plane->point, pt1 );
    add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
        code = EMS_E_BSerror, str = "EFget_bounded_plane_from_range_box : BSproj1 error",
        action = GOTO_VALUE, value = wrapup );

    BSsts = BSproj1( &BSmsg, &range[3], plane->normal, plane->point, pt2 );
    add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
        code = EMS_E_BSerror, str = "EFget_bounded_plane_from_range_box : BSproj1 error",
        action = GOTO_VALUE, value = wrapup );

    BSsts = BSorthovec( &BSmsg, plane->normal, vec );
    add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
        code = EMS_E_BSerror, str = "EFget_bounded_plane_from_range_box : BSorthovec error",
        action = GOTO_VALUE, value = wrapup );

    OM_BLOCK_MOVE( pt1, line[0], sizeof(IGRpoint) );
    for(i=0; i<3; i++)
       line[1][i] = line[0][i] + 10 * vec[i];

    BSsts = BSproj0( &BSmsg, pt2, line, pt3 );
    add$status( test = !BSsts || BSERROR(BSmsg), msg = *EFmsg,
        code = EMS_E_BSerror, str = "EFget_bounded_plane_from_range_box : BSproj0 error",
        action = GOTO_VALUE, value = wrapup );

    BSsts = BSplane3pt( &BSmsg, pt1, pt3, pt2, BSplane );
    add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
        str = "EFget_bounded_plane_from_range_box : BSplane3pt error",
        action = GOTO_VALUE, value = wrapup );

wrapup :
  return;
}

void  EFget_closed_group_range(
IGRlong        *EFmsg,
IGRint         npts,
IGRdouble      *pts,
IGRushort      options,
IGRdouble      *range,
IGRdouble      *intpar )
{
    BSrc            BSmsg;
    IGRint          i, index;
    IGRlong         u_npts, v_npts;
    IGRdouble       min, max, *upts, *vpts, diff, max_jump;
    IGRdouble       cht_tol, len_tol, par_tol;
    IGRboolean      u_closed=FALSE, v_closed=FALSE;

    upts = NULL;
    vpts = NULL;
    *EFmsg = EMS_S_Success;
    BSEXTRACTPAR( &BSmsg, BSTOLCHRDHT, cht_tol );
    BSEXTRACTPAR( &BSmsg, BSTOLLENVEC, len_tol );
    BSEXTRACTPAR( &BSmsg, BSTOLPARAM, par_tol );

    if( npts <= 2 )
      add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
          str = "EFget_closed_group_range : (number of points are less than two) Invalid Arguments",
          action = GOTO_VALUE, value = wrapup );

    /* get the range */
    EM2dbx( npts, pts, range );

    if ((options & U_CLOSED) && fabs((range[2] - range[0] - 1.0)) < par_tol)
    {
      u_closed = TRUE;
    }

    if ((options & V_CLOSED) && fabs((range[3] - range[1] - 1.0)) < par_tol)
    {
      v_closed = TRUE;
    }

    if(u_closed)
    {
       // get all the u parameter values

       upts = (IGRdouble *) om$malloc( size = npts * sizeof(IGRdouble) );
       add$status( test = !upts, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
           str = "EFget_closed_group_range : Insufficient Memory",
           action = GOTO_VALUE, value = wrapup );

       for( i=0; i<npts; i++ )
            upts[i] = pts[i*2];
       u_npts = npts;

       // sort them in the ascending order

       (void) BSmergesort( upts, u_npts, &BSmsg );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFget_closed_group_range : BSmergesort error",
           action = GOTO_VALUE, value = wrapup );

       // calculate the index at which the maximum jump in u parameter values
       // takes place

       index = 1;
       max_jump = upts[1] - upts[0];

       for( i=2; i<u_npts; i++)
       {
          diff = upts[i] - upts[i-1];
          if( diff > max_jump )
          {
              max_jump = diff;
              index = i;
          }
       }

       // The maximum jump indicates the actual limits of extraction in this
       // direction. So extract them.

       min = upts[index - 1];
       max = upts[index];
       if (intpar)
       {
         intpar[0] = 0.0;
       }
    }
    else
    {
       min = range[0]; max = range[2];
       intpar[0] = min +  (max - min)/2.0;
    }

    range[0] = min; range[2] = max;

    if (v_closed)
    {
       // get all the u parameter values

       vpts = (IGRdouble *) om$malloc( size = npts * sizeof(IGRdouble) );
       add$status( test = !vpts, msg = *EFmsg, code = EMS_E_NoDynamicMemory,
           str = "EFget_closed_group_range : Insufficient Memory",
           action = GOTO_VALUE, value = wrapup );

       for( i=0; i<npts; i++ )
            vpts[i] = pts[i*2 + 1];
       v_npts = npts;

       // sort them in the ascending order

       (void) BSmergesort( vpts, v_npts, &BSmsg );
       add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
           str = "EFget_closed_group_range : BSmergesort error",
           action = GOTO_VALUE, value = wrapup );

       // calculate the index at which the maximum jump in u parameter values
       // takes place

       index = 1;
       max_jump = vpts[1] - vpts[0];

       for( i=2; i<v_npts; i++)
       {
          diff = vpts[i] - vpts[i-1];
          if( diff > max_jump )
          {
              max_jump = diff;
              index = i;
          }
       }

       // if the maximum jump is not greater than the chord height tolerance
       // then we need to calculate the range in the normal way.
       // The maximum jump indicates the actual limits of extraction in this
       // direction. So extract them.

       min = vpts[index - 1];
       max = vpts[index];
       if (intpar)
       {
         intpar[1] = 0.0;
       }
    }
    else
    {
       min = range[1]; max = range[3];
       intpar[1] = min + (max - min) / 2.0;
    }

    range[1] = min; range[3] = max;

wrapup :
   return;
}

/*
 * Description :
 * -------------
 *   This routine gets a line enclosing a given rangebox
 *
 * Algorithm :
 * -----------
 *   Bounding box contains six faces. Create 6 planes and find the intersection
 * of the infinite line (the vector given) with all these six planes. Take the
 * points between which the distance is maximum.
 */
void  EFget_line_bounding_rangebox(
IGRlong         *EFmsg,
IGRpoint        pt1,
IGRpoint        pt2,
IGRpoint        min,
IGRpoint        max,
struct IGRline  *line )
{
   BSrc         BSmsg;
   IGRint       code=0, count=0;
   IGRpoint     intx, intpt[2], plpts[3];
   IGRdouble    dist1, dist2,dist3;
   IGRvector    plnormal;

   if( !pt1 || !pt2 || !min || !max )
       add$status( test = TRUE, msg = *EFmsg, code = EMS_E_InvalidArg,
           str = "EFget_line_bounding_rangebox : Invalid Arguments",
           action = GOTO_VALUE, value = wrapup );

   line->point1 = NULL;
   line->point2 = NULL;

   /*
    * Plane with "Z" constant
    *   a. generate planes with "Z" cosntant. i.e. there will be two.
    *   b. intersect the infinite line with the planes.
    *   c. if there is an intersection store the intersecting points.
    */
   OM_BLOCK_MOVE( min, plpts[0], sizeof(IGRpoint) );
   OM_BLOCK_MOVE( min, plpts[1], sizeof(IGRpoint) );
   OM_BLOCK_MOVE( max, plpts[2], sizeof(IGRpoint) );
   plpts[1][0] = max[0];
   plpts[2][2] = min[2];

   (void) BSptlnplan( (IGRint) 3, (IGRboolean) FALSE, plpts, (IGRdouble *)NULL,
                      &code, plnormal, &BSmsg );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFget_line_bounding_rangebox : BSptlnplan error",
       action = GOTO_VALUE, value = wrapup );
   add$status( test = (code != 3), msg = *EFmsg, code = EMS_E_Fail,
       str = "EFget_line_bounding_rangebox : Non-Planar points",
       action = GOTO_VALUE, value = wrapup );

   (void) BSxlnpl( &BSmsg, plnormal, plpts[0], pt1, pt2, intx );
   if( BSmsg == BSSUCC ) // if there is an intersection point
   {
       OM_BLOCK_MOVE( intx, intpt[count], sizeof(IGRpoint) );
       count ++;
   }

   plpts[0][2] = max[2];
   (void) BSxlnpl( &BSmsg, plnormal, plpts[0], pt1, pt2, intx );
   if( BSmsg == BSSUCC ) // if there is an intersection point
   {
       OM_BLOCK_MOVE( intx, intpt[count], sizeof(IGRpoint) );
       count ++;
   }

   /*
    * Plane with "Y" constant
    *   a. generate planes with "Y" cosntant. i.e. there will be two.
    *   b. intersect the infinite line with the planes.
    *   c. if there is an intersection store the extreme intersection points.
    */
   OM_BLOCK_MOVE( max, plpts[0], sizeof(IGRpoint) );
   OM_BLOCK_MOVE( max, plpts[1], sizeof(IGRpoint) );
   OM_BLOCK_MOVE( max, plpts[2], sizeof(IGRpoint) );
   plpts[0][2] = min[2];
   plpts[2][0] = min[0];

   (void) BSptlnplan( (IGRint) 3, (IGRboolean) FALSE, plpts, (IGRdouble *)NULL,
                      &code, plnormal, &BSmsg );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFget_line_bounding_rangebox : BSptlnplan error",
       action = GOTO_VALUE, value = wrapup );
   add$status( test = (code != 3), msg = *EFmsg, code = EMS_E_Fail,
       str = "EFget_line_bounding_rangebox : Non-Planar points",
       action = GOTO_VALUE, value = wrapup );

   (void) BSxlnpl( &BSmsg, plnormal, plpts[0], pt1, pt2, intx );
   if( BSmsg == BSSUCC ) // if there is an intersection point
   {
       if( count == 2 )
       {
           dist1 = BSdistptpt( &BSmsg, intpt[0], intpt[1] );
           dist2 = BSdistptpt( &BSmsg, intpt[0], intx );
           dist3 = BSdistptpt( &BSmsg, intpt[1], intx );

           if( dist2 > dist1 && dist2 > dist3 )
               OM_BLOCK_MOVE( intx, intpt[1], sizeof(IGRpoint) );
           else if( (dist3 > dist1) && (dist3 > dist2) )
               OM_BLOCK_MOVE( intx, intpt[0], sizeof(IGRpoint) );
       }
       else
       {
           OM_BLOCK_MOVE( intx, intpt[count], sizeof(IGRpoint) );
           count ++;
       }
   }

   plpts[0][1] = min[1];

   (void) BSxlnpl( &BSmsg, plnormal, plpts[0], pt1, pt2, intx );
   if( BSmsg == BSSUCC ) // if there is an intersection point
   {
       if( count == 2 )
       {
           dist1 = BSdistptpt( &BSmsg, intpt[0], intpt[1] );
           dist2 = BSdistptpt( &BSmsg, intpt[0], intx );
           dist3 = BSdistptpt( &BSmsg, intpt[1], intx );

           if( dist2 > dist1 && dist2 > dist3 )
               OM_BLOCK_MOVE( intx, intpt[1], sizeof(IGRpoint) );
           else if( (dist3 > dist1) && (dist3 > dist2) )
               OM_BLOCK_MOVE( intx, intpt[0], sizeof(IGRpoint) );
       }
       else
       {
           OM_BLOCK_MOVE( intx, intpt[count], sizeof(IGRpoint) );
           count ++;
       }
   }

   /*
    * Plane with "X" constant
    *   a. generate planes with "X" cosntant. i.e. there will be two.
    *   b. intersect the infinite line with the planes.
    *   c. if there is an intersection store the extreme intersection points.
    */
   OM_BLOCK_MOVE( min, plpts[0], sizeof(IGRpoint) );
   OM_BLOCK_MOVE( min, plpts[1], sizeof(IGRpoint) );
   OM_BLOCK_MOVE( max, plpts[2], sizeof(IGRpoint) );
   plpts[1][2] = max[2];
   plpts[0][0] = min[0];

   (void) BSptlnplan( (IGRint) 3, (IGRboolean) FALSE, plpts, (IGRdouble *)NULL,
                      &code, plnormal, &BSmsg );
   add$status( test = BSERROR(BSmsg), msg = *EFmsg, code = EMS_E_BSerror,
       str = "EFget_line_bounding_rangebox : BSptlnplan error",
       action = GOTO_VALUE, value = wrapup );
   add$status( test = (code != 3), msg = *EFmsg, code = EMS_E_Fail,
       str = "EFget_line_bounding_rangebox : Non-Planar points",
       action = GOTO_VALUE, value = wrapup );

   (void) BSxlnpl( &BSmsg, plnormal, plpts[0], pt1, pt2, intx );
   if( BSmsg == BSSUCC ) // if there is an intersection point
   {
       if( count == 2 )
       {
           dist1 = BSdistptpt( &BSmsg, intpt[0], intpt[1] );
           dist2 = BSdistptpt( &BSmsg, intpt[0], intx );
           dist3 = BSdistptpt( &BSmsg, intpt[1], intx );

           if( dist2 > dist1 && dist2 > dist3 )
               OM_BLOCK_MOVE( intx, intpt[1], sizeof(IGRpoint) );
           else if( (dist3 > dist1) && (dist3 > dist2) )
               OM_BLOCK_MOVE( intx, intpt[0], sizeof(IGRpoint) );
       }
       else
       {
           OM_BLOCK_MOVE( intx, intpt[count], sizeof(IGRpoint) );
           count ++;
       }
   }

   plpts[0][0] = max[0];

   (void) BSxlnpl( &BSmsg, plnormal, plpts[0], pt1, pt2, intx );
   if( BSmsg == BSSUCC ) // if there is an intersection point
   {
       if( count == 2 )
       {
           dist1 = BSdistptpt( &BSmsg, intpt[0], intpt[1] );
           dist2 = BSdistptpt( &BSmsg, intpt[0], intx );
           dist3 = BSdistptpt( &BSmsg, intpt[1], intx );

           if( dist2 > dist1 && dist2 > dist3 )
               OM_BLOCK_MOVE( intx, intpt[1], sizeof(IGRpoint) );
           else if( (dist3 > dist1) && (dist3 > dist2) )
               OM_BLOCK_MOVE( intx, intpt[0], sizeof(IGRpoint) );
       }
       else
       {
           OM_BLOCK_MOVE( intx, intpt[count], sizeof(IGRpoint) );
           count ++;
       }
   }

   add$status( test = count != 2, msg = *EFmsg, code = EMS_E_Fail,
       str = "EFget_line_bounding_rangebox : Infinite line does not intersect with atleast two facees of range box",
       action = GOTO_VALUE, value = wrapup );

   line->point1 = intpt[0];
   line->point2 = intpt[1];

wrapup :

    return;
}


end implementation Root;
