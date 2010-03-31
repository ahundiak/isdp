/* -----------------
 * FOR EMS 4.0
 * Creation : Sanjay
 * -----------------
 */

/*
 *  Description
 *  -----------
 *    This function does the coincident surface processing between two solids.
 *  It takes in a list of coincident surfaces on the two operands, finds the 
 *  intersections between the coincident surfaces by mapping and orients them
 *  for the given boolean operation. As the general boolean algorithm presently
 *  doesn't handle coincident surfaces, if one happened to know that there are
 *  are coincident surfaces can call this function after finding out the inter-
 *  sections by calling "EMintersect_surfaces" routine. This function presently
 *  being used in "Add/Remove Mtl. Functionality" for processing coincident 
 *  surfaces which will come up in "From/To" option.
 *
 *  Synopsis
 *  --------
 *
 *  IGRlong          *EFmsg            Return code
 *  struct GRmd_env  *md_env           Module environment
 *  enum EMSbooltype bool_type         Type of Boolean operation ( union/diff/
 *                                                               intersection )
 *  struct EMSinters *inters_a         Intersection list on operand A
 *  struct EMSinters *inters_b         Intersection list on operand B
 *  IGRint           num_coinc_sfs     Number of coincident surfaces 
 *  struct GRid      *coinc_sf_grids[2]Coincident surface GRids
 *
 *
 *  Algorithm
 *  ---------
 *  for each pair of coincident surfaces 
 *  do
 *     if the volumes of operands A & B at these surfaces are opposite
 *     then
 *          a. Map only the "GLOBAL CONVEX" edges of A on B and push the
 *             intersection (mapped edge) on A onto common edge surface.
 *          b. Map all the edges of B on A and push the intersections 
 *             (mapped edges) on B onto respective common edge surfaces.
 *     else
 *          a. Map only the "GLOBAL CONVEX" edges of A on B.
 *     fi
 *  done
 *
 *  Return Values 
 *  -------------
 *    EMS_S_Success       ->   Every thing goes successfully.
 *    EMS_E_Fail          ->   Any error in maping.
 *    EMS_E_SurfaceError  ->   Any error in calculating the surface normals.
 *
 *  History
 *  -------
 *  
 *    Sanjay     :  05/02/94  :  Creation
 */

class implementation EMSsfboolean;

#include "OMmacros.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "EMSdef.h" /*for EMparms struct */
#include "EMSsfintsort.h"
#include "addrmopts.h"
#include "addprot.h"
#include "bs.h"
#include "bsdotp.h"

extern OMuword  OPP_EMSslboolean_class_id, OPP_EMSsfboolean_class_id;

IGRlong  EFmerge_coinc_inters( EFmsg, md_env, bool_type, inters_a, 
                               inters_b, num_coinc_sfs, coinc_sf_grids )
IGRlong             *EFmsg;
struct GRmd_env     *md_env;
enum  EMSbooltype  bool_type;
struct EMSinters    **inters_a, **inters_b;
IGRint              num_coinc_sfs;
struct GRid         *coinc_sf_grids[2];
{
    BSrc                   BSmsg;
    IGRint                 cnt;
    IGRlong                OMsts, OMmsg;
    IGRvector              sfnorm_a, sfnorm_b;
    IGRushort              options_a, options_b;
    IGRdouble              sfpt[3]; 
    struct GRid            sfgrid_a, sfgrid_b; 
    struct EMSinters       *sfinters_a, *sfinters_b; 
    struct EMSintobj       *intobj_loc, *EMdelintobj();
    struct IGRbsp_surface  *sfgeom_a, *sfgeom_b;
    void EMintobj_free(), EMintobj_data_free(), EMsfintedpar_free();

    OMsts = OM_S_SUCCESS;
    *EFmsg = EMS_S_Success;
    intobj_loc = NULL;
    options_a = options_b = NULL;
    sfgeom_a = sfgeom_b = NULL;
 
    /*
     * options for each surface should be set depending on the direction of
     * the normals of the each surface.
     */
    for( cnt=0; cnt<num_coinc_sfs; cnt++ )
    { 
        sfgrid_a = coinc_sf_grids[cnt][EMSoprnd_A];
        sfgrid_b = coinc_sf_grids[cnt][EMSoprnd_B];

        /*
         * obtain a point in area on the surface
         */
        OMsts = om$send( msg = message EMSsurface.EMget_point_on_surface( 
                                                  &OMmsg, md_env, 0, 1, 
                                                  sfpt, NULL),
                         senderid = NULL_OBJID,
                         targetid = sfgrid_a.objid,
                         targetos = sfgrid_a.osnum );  
        add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, 
            code = EMS_E_SurfaceError, 
            str = "EFmerge_coinc_inters : EMget_point_on_surface error",
            action = GOTO_VALUE, value = wrapup );

        /*
         * obtain the geometry of both the surfaces
         */
        EMgetvggeom( &OMmsg, &md_env->md_env.matrix_type, 
                     md_env->md_env.matrix, &sfgrid_a, 
                     (IGRchar **) &sfgeom_a, NULL);
        add$status( test = !(1&OMmsg), msg = *EFmsg, 
            code = EMS_E_SurfaceError, 
            str = "EFmerge_coinc_inters : EMgetvggeom (from/to surface) error",
            action = GOTO_VALUE, value = wrapup );
        
        EMgetvggeom( &OMmsg, &md_env->md_env.matrix_type, 
                     md_env->md_env.matrix, &sfgrid_b, 
                     (IGRchar **) &sfgeom_b, NULL);
        add$status( test = !(1&OMmsg), msg = *EFmsg, 
            code = EMS_E_SurfaceError, 
            str = "EFmerge_coinc_inters : EMgetvggeom (from/to surface) error",
            action = GOTO_VALUE, value = wrapup );

        /*
         * obtain the oriented normals of both the surface at the sfpt
         */
        EMgetsfnorm( &OMmsg, sfgeom_a, sfpt, NULL, NULL, sfnorm_a );
        add$status( test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail, 
            str = "EFmerge_coinc_inters : EMgetsfnorm (from/to surface) error",
            action = GOTO_VALUE, value = wrapup );
        
        EMgetsfnorm( &OMmsg, sfgeom_b, sfpt, NULL, NULL, sfnorm_b );
        add$status( test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail, 
            str = "EFmerge_coinc_inters : EMgetsfnorm (from/to surface) error",
            action = GOTO_VALUE, value = wrapup );
     
        /*
         * if the dot product of the normals of the surfaces is greater 
         * than zero, then both the surface normals are pointing in the 
         * same direction otherwise they are pointing in opposite dire-
         * ctions. if the normals are in the same direction then set the
         * following options for the surfaces : 
         * otherwise set the following options :
         */
        if( (BSdotp( &BSmsg, sfnorm_a, sfnorm_b)) > 0.0 )
        {
#ifdef DEBUG
       printf("Surface Normal (A) = ( %lf, %lf, %lf )\n",
               sfnorm_a[0], sfnorm_a[1], sfnorm_a[2] );  
       printf("Surface Normal (B) = ( %lf, %lf, %lf )\n",
               sfnorm_b[0], sfnorm_b[1], sfnorm_b[2] );  
       printf("A pos orient : %d\n",sfgeom_a->pos_orient);
       printf("B pos orient : %d\n",sfgeom_b->pos_orient);
       printf("Surface normals are pointing in the same direction \n" );
#endif
             options_a |= EMS_DONOT_MAP_CONCAVE_EDGES | 
                          EMS_DONOT_MAP_NEUTRAL_EDGES |
                          EMS_DONOT_MAP_SEAM_EDGES ;
             options_b |= EMS_DONOT_MAP_ANY_EDGE ;
        }
        else
        {
#ifdef DEBUG
       printf("Surface Normal (A) = ( %lf, %lf, %lf )\n",
               sfnorm_a[0], sfnorm_a[1], sfnorm_a[2] );
       printf("Surface Normal (B) = ( %lf, %lf, %lf )\n",
               sfnorm_b[0], sfnorm_b[1], sfnorm_b[2] );
       printf("Surface normals are pointing in the opposite direction \n" );
#endif
             options_a |= EMS_DONOT_MAP_CONCAVE_EDGES | 
                          EMS_DONOT_MAP_NEUTRAL_EDGES |
                          EMS_OPT_PUSH_TO_COMMON_EDGE |
                          EMS_DONOT_MAP_SEAM_EDGES ;
             options_b |= EMS_OPT_PUSH_TO_COMMON_EDGE |
                          EMS_DONOT_MAP_SEAM_EDGES ;
        }

        if( bool_type == EMSbool_difference )
            options_b |= EMS_OPT_REVERSE_MAPPED_EDGE ;
 
        /*
         * get the inters node corresponding to the given surface ids and 
         * delete all the intobjs corresponding to the each surface and 
         * set the cvs field to NULL and then call "EMgetmapped_inters" 
         * which will actually does the pushing and mapping operation
         * depending on the options set.
         */ 
        for( sfinters_a = *inters_a; 
             sfinters_a != NULL;    
             sfinters_a = sfinters_a->next )
        {
            if( IF_EQ_OBJID( sfinters_a->this_obj.objid, sfgrid_a.objid) )
                break;
        }
        
        for( sfinters_b = *inters_b; 
             sfinters_b != NULL;    
             sfinters_b = sfinters_b->next )
        {
            if( IF_EQ_OBJID( sfinters_b->this_obj.objid, sfgrid_b.objid) )
                break;
        }

        /* 
         * first free the data and then the int objs 
         */
        if( sfinters_a )
        {
            intobj_loc = sfinters_a->cvs;
            while( intobj_loc ) 
            {
               intobj_loc = EMdelintobj( &OMmsg, intobj_loc );
               add$status( test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
                   str = "EFmerge_coinc_inters : EMdelintobj error",
                   action = GOTO_VALUE, value = wrapup );
            } 
        }

        if( sfinters_b )
        { 
            intobj_loc = sfinters_b->cvs;
            while( intobj_loc )
            {
               intobj_loc = EMdelintobj( &OMmsg, intobj_loc );
               add$status( test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
                   str = "EFmerge_coinc_inters : EMdelintobj error",
                   action = GOTO_VALUE, value = wrapup );
            }
        }

        /*
         * compress inters lists
         */
        EMcmpinters( &OMmsg, inters_a );
        add$status( test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFmerge_coinc_inters : EMcmpinters error",
            action = GOTO_VALUE, value = wrapup );

        EMcmpinters( &OMmsg, inters_b );
        add$status( test = !(1&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFmerge_coinc_inters : EMcmpinters error",
            action = GOTO_VALUE, value = wrapup );

        /* 
         * set the fwd and bwd pointers to NULL, so that the trace doesn't
         * look at these and it will trace the intobjs on its own.
         */
        for( sfinters_a = *inters_a;
             sfinters_a != NULL;
             sfinters_a = sfinters_a->next )
        {
             intobj_loc = sfinters_a->cvs;
             while( intobj_loc )
             {
                 intobj_loc->fwd = (struct EMSintobj *) NULL;
                 intobj_loc->bwd = (struct EMSintobj *) NULL;
                 intobj_loc->props &= ~EMSintobj_marked;
                 intobj_loc = intobj_loc->next;
             } 
        }
 
        for( sfinters_b = *inters_b;
             sfinters_b != NULL;
             sfinters_b = sfinters_b->next )
        {
             intobj_loc = sfinters_b->cvs;
             while( intobj_loc )
             {
                 intobj_loc->fwd = (struct EMSintobj *) NULL;
                 intobj_loc->bwd = (struct EMSintobj *) NULL;
                 intobj_loc->props &= ~EMSintobj_marked;
                 intobj_loc = intobj_loc->next;
             }
        }

        /*
         * Then map the edges of the coincident surfaces according to the
         * options set
         */
        OMsts = EMgetmapped_inters( &OMmsg, md_env, 
                                    &sfgrid_a, options_a, &sfgrid_b, options_b,
                                    inters_a, inters_b);
        add$status( test = !(1&OMsts&OMmsg), msg = *EFmsg, code = EMS_E_Fail,
            str = "EFmerge_coinc_inters : EMgetmapped_inters error",
            action = GOTO_VALUE, value = wrapup );
    }

wrapup: 
    EMWRAPUP( *EFmsg, OMsts, "EFmerge_coinc_inters" ); return OMsts;
}

end implementation EMSsfboolean;
