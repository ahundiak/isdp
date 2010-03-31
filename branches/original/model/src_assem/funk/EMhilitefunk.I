class implementation EMpart;

#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "exmacros.h"

#include "assemdef.h"
#include "assem.h"
#include "assemconstr.h"
#include "assemmacros.h"

from GRvg       import GRgetsymb, GRchgweight;
from GRgraphics import GRdisplay;

extern OMuword OPP_EMSplane_class_id;

EMHighlight_Cnstr( msg, grid, mode )
IGRlong *msg;
IGRint   mode;
struct GRid *grid;
{
IGRint om_msg, type, i;
enum   GRdpmode code;
struct GRid ft_id[2];
struct GRmd_env ft_env[2];
OMuword classid;

    code = ( enum GRdpmode ) mode;

    EMgetconstrtype( *grid, &type );
    if( type == GROUND ) 
    {
        /* No features to highlight */
        return 1;
    }

    /*
     * get the paired features of the constraint and highlight each one
     */    
    om_msg = asm$get_paired_features( msg = msg,
                                      cnstrid = grid,
                                      f1_id = &ft_id[0],
                                      f1_env = &ft_env[0],
                                      f2_id = &ft_id[1], 
                                      f2_env = &ft_env[1] );
    if( om_msg & *msg & 1 )
    {
        for( i = 0; i < 2; i++ )
        {
            /*
             * Check if the feature is an EMSplane.
             */
            om$get_classid( objid = ft_id[i].objid,
                            osnum = ft_id[i].osnum,
                            p_classid = &classid );

            if (om$is_ancestry_valid (subclassid = classid,
                   superclassid = OPP_EMSplane_class_id) == OM_S_SUCCESS)
            {
/*    	        EMhighlight_prtfeature( &ft_id[i], &ft_env[i], mode );*/
                EMhighlight_obj( &ft_id[i], &ft_env[i], mode );
            }
            else
            {
                EMhighlight_obj( &ft_id[i], &ft_env[i], mode );
            }
        }
    }
    return 1;
}

IGRint EMspl_highlight ( msg, select_args, usdata )
IGRlong *msg;
struct LC_select_args *select_args ;
IGRchar *usdata ;
{
IGRint  sts, mode ;
struct GRid pln_grid ;
struct GRmd_env mod_info ;
OMuword classid;

    usdata = NULL; /* silence compiler */
    /*
     * Check if the object located is a plane
     */
    pln_grid = select_args -> stack ->  entry[0].located_obj ; 
    mod_info = select_args -> stack  -> entry[0].module_info ;

    mode = GRhd;
    sts = EMhighlight_prtfeature( &pln_grid, &mod_info, mode );

    if( !(sts & 1))
        goto quit;

    /* Now invoke lc$select to do accept/reject */
    sts = lc$select(msg = msg, args = select_args );

    mode = GRhe;
    sts = EMhighlight_prtfeature( &pln_grid, &mod_info, mode );

quit:
    return(sts);
}

EMhighlight_prtfeature( pln_grid, modenv, mode )
struct GRid *pln_grid;
struct GRmd_env *modenv;
IGRint mode;
{
IGRlong msg, om_msg;
struct  GRid part;
enum GRdpmode code ;

    code = (enum GRdpmode)mode;

    om_msg = asm$get_feature_instance (msg = &msg,
                                       feature_loc_env = modenv,
                                       feature_id = pln_grid,
                                       instance_id = &part);
                
    if (om_msg & msg & 1)
    {
        /* half highlight part and change weight on plane and highlight */  
        if( code == GRhd )
        {
            EMset_weight_of_feature( pln_grid, 2 );
            EMhighlight_obj( pln_grid, modenv, GRhd );
            EMhighlight_obj( &part, NULL, GRhhd );
        }
        else
        {
            /* unhighlight objects */
            EMhighlight_obj( pln_grid, modenv, GRhe ); 
            EMset_weight_of_feature( pln_grid, -2 );
            EMhighlight_obj( &part, NULL, GRhe);
        }
    }
    else om_msg = OM_E_ABORT;

    return om_msg;
}

EMset_weight_of_feature( grid, wt )
struct GRid *grid ;
IGRint wt;
{
IGRint sts ;
IGRlong  msg   ;
struct GRsymbology symb ;
IGRuchar weight ;

   sts = om$send(msg = message GRvg.GRgetsymb(&msg,&symb),
                  targetid = grid -> objid,
                  targetos = grid -> osnum,
                  senderid = NULL_OBJID);

   weight = symb.display_attr.weight + wt ;

   sts = om$send(msg = message GRvg.GRchgweight(&msg,&weight),
                  targetid = grid -> objid,
                  targetos = grid -> osnum,
                  senderid = NULL_OBJID);
   return(1);
}

EMhighlight_obj( obj, gmdenv, mode )
IGRint mode;
struct GRid *obj;
struct GRmd_env *gmdenv ;
{
IGRint sts ;
IGRlong  msg_loc ;
enum GRdpmode code ;
struct GRid modid;
struct GRmd_env mod_env;
  
    code = (enum GRdpmode)mode ;
    if( gmdenv == NULL )
    {
        /*
         * Get the current module enviroment.
         */	
        gr$get_module_env( buffer = &mod_env );
    }
    else mod_env = *gmdenv;


    ex$get_cur_mod( id = &modid.objid, osnum = &modid.osnum );

    sts = om$send(msg = message GRgraphics.GRdisplay(&msg_loc,
					&(mod_env.md_env.matrix_type),
					mod_env.md_env.matrix,
					&code, &modid),
                    senderid = obj -> objid,
    	            targetid = obj -> objid,
                    targetos = obj -> osnum);

    return(1);
}

end implementation EMpart;
