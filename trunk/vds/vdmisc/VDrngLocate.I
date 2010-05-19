/* $Id: VDrngLocate.I,v 1.2 2001/09/28 14:12:00 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        isdp/vds/vdmisc/VDrngLocate.I
 *
 * Description: Function to physically locate objects with in range.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrngLocate.I,v $
 *      Revision 1.2  2001/09/28 14:12:00  ramarao
 *      Added multiple arguments classids.
 *
 *      Revision 1.1  2001/09/27 15:54:20  ramarao
 *      Created VDrngLocate.I file.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      09/27/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "VDobj.h"
#include "VDgeom.h"
#include "VDmem.h"
#include "dpdef.h"
#include "lcmacros.h"
#include "comiscmac.h"
#include "grgsdef.h"
#include "v_dbgmacros.h"

struct VDqList 
{
       IGRint          	count;
       IGRint          	max;
       IGRint          	incre;
       struct GRobj_env *list;
};

static long VDaddElemQList( struct VDqList	*elemList,
			    struct GRid		*elemId,
			    struct GRmd_env	*elemEnv   )
{

    if( elemList->count == elemList->max )
    {
        elemList->max += elemList->incre;
        if( elemList->list )
              elemList->list = (struct GRobj_env *)realloc(
                                   elemList->list,
                                   elemList->max *
                                   sizeof(struct GRobj_env));
        else    elemList->list = (struct GRobj_env *)malloc(
                                   elemList->max *
                                   sizeof(struct GRobj_env));
        if( elemList->list == NULL )
        {
            printf(" ERROR : not enought memory to allocate list\n");
            return  FALSE;
        }
    }

    (elemList->list)[elemList->count].obj_id  = *elemId ;
    (elemList->list)[elemList->count].mod_env = *elemEnv ;
    (elemList->count)++ ;

    return  TRUE;
}

int VDlocate_LCAH( struct VDqList 	  *LCargs,
                   struct GRlc_info       *entry,
                   struct LC_action_args  *args,
                   enum   GRlocate_action *action )
{
IGRint  env_flag=0;

    switch( *action ) 
    {
        case add_all     :
        case add_inside  :
        case add_outside :
        case add_overlap :
             VDaddElemQList( LCargs, &entry->located_obj,
                             &entry->module_info );
        case add_nopost  :
             return LC_ACCEPT_ONE_ACTION;
        default          :
             return LCevaction ( (IGRchar *) LCargs,
                               entry, args, action, &env_flag );
    }
}

IGRlong   VDlocObjectsInCurrentFile( IGRlong		*msg,
				     struct GRmd_env	*loc_env,
				     GRrange		range,
				     IGRint		classidCount,
				     GRclassid		*classidList,
				     IGRint		*count,
				     struct GRobj_env	**list      )
{
IGRlong			sts, no_msg;
IGRint			i, layers[DP_NUM_OF_LEVELS/32 + 1];
IGRdouble		point[15];
OM_S_CLASSLIST          classList;
struct GRlc_classes     classL;
struct GRlc_rp_loc	rp_params;
struct VDqList		act_parms;
enum GRlocate_types  	loc_type=GR_rp_loc;

    *count = 0 ;
    *list  = NULL;

    classList.w_flags       = OM_CLST_subclass;
    classList.w_count       = classidCount;
    classList.p_classes     = classidList;
    classL.rtree_classes    = &classList;
    classL.eligible_classes = &classList;

    act_parms.count = 0;
    act_parms.max   = 0;
    act_parms.incre = 100;
    act_parms.list  = NULL ;

    rp_params.obj_attr.properties   = LC_LC_ONLY | LC_DP_ONLY | LC_RW;

    rp_params.obj_attr.owner_action =
                        LC_RIGID_OWNER | LC_FLEX_OWNER | LC_REF_OBJECTS;

    vdgeom$GetTolerance( cht = &rp_params.tolerance );

    co$build_button( msg    = msg,
                     button = &rp_params.datapoint ) ;

    MAidmx( msg, rp_params.rt_prism.matrix ) ;
    rp_params.rt_prism.matrix[11] = range[2] ;

    rp_params.rt_prism.polygon.num_points = 5 ;
    rp_params.rt_prism.polygon.points     = point ;

    for( i=0; i<5; i++ ) 
    {
        point[i*3]   = range[0];
        point[i*3+1] = range[1];
        point[i*3+2] = 0 ;
    }

    point[3] = point[6]  = range[3] ;
    point[7] = point[10] = range[4] ;

    rp_params.rt_prism.height = fabs( range[5] - range[2] ) ;

    memcpy( rp_params.upd_range, range, 6 * sizeof( double ) ) ;

    rp_params.is_ortho = TRUE ;
    rp_params.prism_attr = GO_INSIDE | GO_OVERLAP;

    for( i=0; i<DP_NUM_OF_LEVELS/32 + 1; i++ ) layers[i] = 0xffffffff ;

    sts = lc$query( rc              = msg,
                    mod             = loc_env,
                    locate_type     = &loc_type,
                    loc_parms       = (char *) &rp_params,
                    act_handler     = VDlocate_LCAH,
                    act_parms       = &act_parms,
                    classptr        = &classL,
                    levels          = layers );
    __CheckRC( sts, *msg, "lc$query", wrapup );

    *count = act_parms.count ;
    *list  = act_parms.list ;

wrapup:
    lc$check_id( rc   = &no_msg, mode = LC_DELETE );
    if( !(sts&1&(*msg)) ) { _FREE( (*list) );  *count = 0; }
    return sts;
}

end implementation VDSroot;
