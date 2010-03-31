
class implementation EMconstr;

/*

Name
  EMconstri.I

Description
  This file has the method implemenation for the Assembly 
  Constraint Class.

Notes
 04/21/93 : Kapil Singh (KS): created
 08/11/93 : Krishna kumar (KK): added get_offset and set_offset 
 08/25/93 : Krishna kumar (KK): added get_feature_cntxts
 */


#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrdef.h"
#include "madef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "emsdef.h"
#include "emserr.h"
#include "AS_status.h"
#include "nddef.h"
#include "expression.h"
#include "expmacros.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "parametric.h"

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

from EMinstance import EMget_feature_context;
from GRcontext  import GRgetmodule_env;

extern OMuword OPP_expression_class_id;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMinit_constraint                                                |
 |                                                                           |
 | This message initiliazes the constraint instance.                         | 
 |                                                                           |
 | Input: struct GRid part_one    1st part to which the constr is attached   |
 |        struct GRid part_two    2nd part to which the constr is attached   |
 |        FEATURE_INFO feature_one 1st feature on which constraint applies    |
 |        FEATURE_INFO feature_two 2nd feature on which constraint applies    |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
 
method EMinit_constraint(IGRlong *msg;
                           struct GRid part_one;
                           struct GRid part_two; 
                           FEATURE_INFO feature_one;
                           FEATURE_INFO feature_two)
{
  IGRlong stat_OM, msg_loc;
  struct GRid null_grid, my_grid, feature_1_grid, feature_2_grid;
  struct GRid context_grid_1, context_grid_2;
  unsigned int constype;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;  

  stat_OM = OM_S_SUCCESS;
  *msg = EMS_S_Success;

  null_grid.objid = NULL_OBJID;

  stat_OM = om$send(msg = message NDnode.NDconnect(1, &my_grid, null_grid, ND_NEW),
                     targetid = part_two.objid,
                     targetos = part_two.osnum);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  EMgetconstrtype (my_grid, &constype);
  
  if (constype == GROUND)
  {
    me->feature_one.osname[0] = '\0';
    me->feature_two.osname[0] = '\0';
    me->feature_one.tag = 0;
    me->feature_two.tag = 0;
  }
  else
  {
    stat_OM = om$send(msg = message NDnode.NDconnect(1, &part_one, null_grid, ND_NEW),
                       targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
  
    stat_OM = om$os_number_to_internal_name(osnum = feature_one.grid.osnum,
                                            osname = me->feature_one.osname);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
  
    stat_OM = om$objid_to_tag(osnum = feature_one.grid.osnum,
                              objid = feature_one.grid.objid,
                              p_tag = &(me->feature_one.tag));
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
  
  
    stat_OM = om$os_number_to_internal_name(osnum = feature_two.grid.osnum,
                                            osname = me->feature_two.osname);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
  
    stat_OM = om$objid_to_tag(osnum = feature_two.grid.osnum,
                              objid = feature_two.grid.objid,
                              p_tag = &(me->feature_two.tag));
                              
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

    if( feature_one.grid.osnum != OM_Gw_current_OS )
    {  
    /*
     * Get the context that matches the locate matrix for feature_one
     */
    stat_OM = GRfindcontext(&msg_loc,
                           &(feature_one.lc_env.md_env.matrix_type),
                           feature_one.lc_env.md_env.matrix,
                           &(feature_one.grid.osnum),
                           &context_grid_1);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
    as$make_source ( go_grid = feature_one.grid, context_grid = context_grid_1, 
                                         as_grid = &feature_1_grid);
    }
    else
    {
    as$make_source ( go_grid = feature_one.grid, 
                                         as_grid = &feature_1_grid);
    }

    if( feature_two.grid.osnum != OM_Gw_current_OS )
    {  
    /*
     * Get the context that matches the locate matrix for feature_two
     */
    stat_OM = GRfindcontext(&msg_loc,
                           &(feature_two.lc_env.md_env.matrix_type),
                           feature_two.lc_env.md_env.matrix,
                           &(feature_two.grid.osnum),
                           &context_grid_2);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    as$make_source ( go_grid = feature_two.grid, context_grid = context_grid_2, 
                                         as_grid = &feature_2_grid);
    }
    else    
    {
    as$make_source ( go_grid = feature_two.grid, 
                                         as_grid = &feature_2_grid);
    }
  
    stat_OM = om$send(msg = message NDnode.NDconnect(1, &feature_1_grid, 
                                                     null_grid, ND_NEW),
                       targetid = part_one.objid,
                       targetos = part_one.osnum);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
  
  
    stat_OM = om$send(msg = message NDnode.NDconnect(1, &feature_2_grid, 
                                                     null_grid, ND_NEW),
                       targetid = part_two.objid,
                       targetos = part_two.osnum);
    EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);
  }   

ret_end:

  EMWRAPUP (*msg, stat_OM, "In EMconstr:EMinit_constraint error");
  return (stat_OM);
}

method EMget_offset ( IGRlong *rc; IGRdouble *offset; struct GRid *expid )
{
IGRlong   stat_OM;
GRclassid classid;
int       i, cnt;
struct    GRid *list;

  *rc = MSSUCC;

  stat_OM = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
			            NULL,0,&list,0,OM_K_MAXINT,&cnt),
		   targetid = my_id);

  EMerr_hndlr(!(1&stat_OM), *rc, EMS_E_OMerror, wrap_up);		   
  if ( cnt > 0 )
  {
        for( i = 0; i < cnt; i++ )
        {
            om$get_classid( objid = list[i].objid,
                            osnum = list[i].osnum,
                            p_classid = &classid );

            if (om$is_ancestry_valid (subclassid = classid,
                   superclassid = OPP_expression_class_id) == OM_S_SUCCESS)
            {
                if( !get_exp_val( &list[i], offset ) )
                {
                    stat_OM = OM_E_ABORT;
                    goto wrap_up;
                }
                if( expid ) /* Return the expression id also */
                    *expid = list[i];
                break;                
            }
        }
    }
wrap_up:
  EMWRAPUP (*rc, stat_OM, "In EMconstr:get_offset error");
  return (stat_OM);
}

get_exp_val( expid, value )
struct GRid *expid;
double *value;
{
struct 	  ret_struct retst;
struct    GRmd_env env;
long	  msg;
struct    GRid mdid;
int       om_msg;

    mdid.osnum = expid->osnum;
    ex$get_modid( mod_osnum = mdid.osnum, mod_id = &mdid.objid );
    env.md_id = mdid;
                
    om_msg = om$send( msg = message NDnode.NDgive_structure(
						 &msg, &retst, &env),
                             targetid = expid->objid,
                             senderid = expid->objid,
                             targetos = expid->osnum);

    if( !(om_msg & msg & 1 ))
    {
        verbose(printf("givestructure failed\n"));
        return(0);
    }
    *value = retst.var.root_pm_st.value;

    return( 1 );
}

method EMset_offset ( IGRlong *rc; IGRchar * offset )
{
IGRlong stat_OM;
GRclassid classid;
int       i, cnt;
struct    GRid *list;

  stat_OM = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
			            NULL,0,&list,0,OM_K_MAXINT,&cnt),
		   targetid = my_id);

  EMerr_hndlr(!(1&stat_OM), *rc, EMS_E_OMerror, wrap_up);		   
  if ( cnt > 0 )
  {
        for( i = 0; i < cnt; i++ )
        {
            om$get_classid( objid = list[i].objid,
                            osnum = list[i].osnum,
                            p_classid = &classid );

            if (om$is_ancestry_valid (subclassid = classid,
                   superclassid = OPP_expression_class_id) == OM_S_SUCCESS)
            {
                stat_OM = exp$modify( exp_id = list[i].objid,
                            osnum  = list[i].osnum,
                            exp_syntax = offset );

                EMerr_hndlr(!(1&stat_OM), *rc, EMS_E_OMerror, wrap_up);	
                break;                
            }
        }
    }
wrap_up:
  EMWRAPUP (*rc, stat_OM, "In EMconstr:set_offset error");
  return (stat_OM);

}

method EMget_ftrs_with_env( IGRlong *rc; struct GRid *fea_ids; 
                                    struct GRmd_env *env )
{
int  i, om_msg;
long msg;
struct GRid prt_grid, cntxt_ids[2];

    *rc = MSSUCC;
    /*
     * Get each of the instances/features on which the constraint is acting,
     * and then get the GRcontext for each combination.
     */
    for( i = 0; i < 2; i++ )
    {
        om_msg = om$send( msg = message EMconstr.EMgetpart(&msg,i,&prt_grid),
                            targetid = my_id );

        if( !(om_msg & msg & 1 ))
        {
            verbose(printf("get_feature_cntxts:EMgetpart failed\n"));
            return( OM_E_ABORT );
        }

        om_msg = om$send ( msg = message EMconstr.EMget_feature ( &msg, i,
                                                                &fea_ids[i] ),
                             targetid = my_id);

        if( !(om_msg & msg & 1 ))
        {
            verbose(printf("get_feature_cntxts:EMget_feature failed\n"));
            return( OM_E_ABORT );
        }

        om_msg = om$send( msg = message EMinstance.EMget_feature_context( &msg,
                                                    &fea_ids[i], &cntxt_ids[i]),
                              targetid = prt_grid.objid,
                              targetos = prt_grid.osnum );

        if( !(om_msg & msg & 1 ))
        {
            verbose(printf("get_feature_cntxts:EMget_feature_context failed\n"));
            return( OM_E_ABORT );
        }

        if (cntxt_ids[i].objid != NULL_OBJID)
        {
            om_msg = om$send( msg = message GRcontext.GRgetmodule_env( &msg,
                                                                &env[i] ),
                                targetid = cntxt_ids[i].objid,
                                targetos = cntxt_ids[i].osnum );
            if( !(om_msg & msg & 1 ))
            {
                verbose(printf("get_feature_cntxts:GRgetenv failed,grid=%d(%d)\n",
                                        cntxt_ids[i].objid,cntxt_ids[i].osnum));
                return( OM_E_ABORT );
            }
        }
        else
        {
            gr$get_module_env( buffer = &env[i] );
        }
    }

    return( OM_S_SUCCESS );
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_constraint_attrs                                            |
 |                                                                           |
 | This method returns the attributes of the constraint object.              |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |          IGRuint *     attrs       Attributes of object.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_constraint_attrs (IGRlong * msg; IGRuint * attrs)
{
    *msg = ASM_S_SUCCESS;
    *attrs = me->attr_flags;
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMset_constraint_attrs                                            |
 |                                                                           |
 | This method sets the attributes of the constraint object.                 |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code.                           |
 |                                                                           |
 | Input :  IGRuint       attrs       Attributes of object.                  |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_constraint_attrs (IGRlong * msg; IGRuint attrs)
{
    *msg = ASM_S_SUCCESS;
    me->attr_flags = attrs;
    return OM_S_SUCCESS;
}

end implementation EMconstr;
