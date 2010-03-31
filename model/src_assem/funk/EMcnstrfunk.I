class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include "dpdef.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griodef.h"
#include "grio.h"
#include "nddef.h"
#include "ndmacros.h"
#include "assemdef.h"
#include "assem.h"
#include "assemconstr.h"
#include "assemmacros.h"


from EMconstr import EMprocess_constr_addition, EMget_constraint_attrs;
from EMconstr import EMset_constraint_attrs, EMgetpart, EMget_ftrs_with_env;
from EMconstr import EMset_offset;
from EMlocalpart import EMget_layers;

IGRlong EMget_localpart_frm_grid( IGRlong *msg, 
                                  struct GRid *gr_id, 
                                  struct GRmd_env *gr_env,
                                  struct GRid  *prt_id )
{
    IGRlong om_msg;
    struct GRsymbology symb;
    IGRshort  gr_layer;    
    IGRlong   layers[32];
    IGRint    i, prt_count;
    struct GRid pid;


    if(prt_id)
      prt_id->objid = NULL_OBJID;

    /*
     * Get the layer of this object.
     */
    om_msg = om$send (msg = message GRvg.GRgetsymb (msg, &symb),
                      senderid = NULL_OBJID,
                      targetid = gr_id->objid,
                      targetos = gr_id->osnum);
        
    if (!(om_msg & *msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
    gr_layer = symb.level;

    /*
     * Get all the local parts and check to which of the localparts' layers
     * the layer of the id'ed graphic belongs
     */
    om_msg = asm$part_count (msg = msg,
                             mod_env = gr_env,
                             type = EM_LOCAL_PART,
                             count = &prt_count);
        
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    for (i=0; i<prt_count; i = i+1)
    {
        om_msg = asm$get_part (msg = msg,
                               mod_env = gr_env,
                               type = EM_LOCAL_PART,
                               index = i,
                               part_id = &pid);
    
        om_msg = om$send( msg = message EMlocalpart.EMget_layers( msg,
                                                                  layers,
                                                                  NULL,
                                                                  NULL ),
                         senderid = NULL_OBJID,        
                         targetid = pid.objid,
                         targetos = pid.osnum);

        if( EMlayer_in_layers (gr_layer, layers) )
        {
            if(prt_id)
             *prt_id = pid;
            break;
        }
    }

    if( i == prt_count )
        om_msg = OM_E_ABORT;
quit:

    return( om_msg );
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMis_feature_instance                                             |
 |                                                                           |
 | This function determine whether the input object is the graphic definition|
 | of an instance.                                                           |
 |                                                                           |
 | Input:  IGRlong          * msg           Return, MSSUCC or MSFAIL.        |
 |         struct GRid      * id            Object's id.                     |
 |                                                                           |
 | Output: struct GRid      * instance_id   Instance's id.                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/1/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRboolean EMis_feature_instance (IGRlong     * msg,
                                  struct GRid * id,
                                  struct GRid * instance_id)
{
    IGRlong         om_msg = OM_S_SUCCESS;
    struct GRid     owner_id, listener_id;
    OM_S_CHANSELECT chansel;
    OMuword         classid, instance_classid;
    IGRint          i;
    OMuint          count;
    IGRboolean      is_graphic = FALSE;

    /*
     * Check arguments.
     */
    if (!id || !msg)
    {
        goto quit;
    }
    
    *msg = MSSUCC;
    
    /*
     * Get the classid for EMinstance.
     */
    om$get_classid (osnum = id->osnum,
                    classname = "EMinstance",
                    p_classid = &instance_classid);
    
    /*
     * First check to see if the object is directly owned by
     * the instance, EM_REFERNCE_PART or EM_GRAPHIC_PART.
     */
    GRget_to_owner_info (&chansel, id->osnum, id->objid, &count);

    for (i=0; i<count; ++i)
    {
        om_msg = om$get_objid_at_index (objid = id->objid,
                                        osnum = id->osnum,
                                        index = i,
                                        p_chanselect = &chansel,
                                        objidaddr = &owner_id.objid,
                                        osnumaddr = &owner_id.osnum);

        if (!(om_msg & 1))
        {
            goto quit;
        }

        om$get_classid (objid = owner_id.objid,
                        osnum = owner_id.osnum,
                        p_classid = &classid);
        
        if (om$is_ancestry_valid (superclassid = instance_classid,
                                  subclassid = classid) == OM_S_SUCCESS)
        {
            if (instance_id)
            {
                instance_id->objid = owner_id.objid;
                instance_id->osnum = owner_id.osnum;
            }
            is_graphic = TRUE;
            break;
        }
    }
    
    /*
     * If the object isn't directly owned by the instance
     * check for the instance on the listener channel.
     */
    if (!is_graphic)
    {

        om$make_chanselect (channame = "GRnotify.notification",
                            p_chanselect = &chansel);

        om$get_channel_count (objid = id->objid,
                              osnum = id->osnum,
                              p_chanselect = &chansel,
                              count = &count);
        
        for (i=0; i<count; ++i)
        {
            om_msg = om$get_objid_at_index (objid = id->objid,
                                            osnum = id->osnum,
					    index = i,
                                            p_chanselect = &chansel,
                                            objidaddr = &listener_id.objid,
                                            osnumaddr = &listener_id.osnum);

            if (!(om_msg & 1))
            {
                goto quit;
            }

            om$get_classid (objid = listener_id.objid,
                            osnum = listener_id.osnum,
                            p_classid = &classid);
        
            if (om$is_ancestry_valid (superclassid = instance_classid,
                                      subclassid = classid) == OM_S_SUCCESS)
            {
                if (instance_id)
                {
                    instance_id->objid = listener_id.objid;
                    instance_id->osnum = listener_id.osnum;
                }
                is_graphic = TRUE;
                break;
            }
        }
    }
    
 quit:
    
    return is_graphic;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_feature_instance                                            |
 |                                                                           |
 | This function will attempt to find the instance that specified object     |
 | belongs to.                                                               |
 |                                                                           |
 | Input:  IGRlong          * msg           Return, MSSUCC or MSFAIL.        |
 |         struct GRmd_env  * mod_env       Located object's module environ. |
 |         struct GRid      * id            Object's id.                     |
 |                                                                           |
 | Output: struc  GRid      * instance_id   Instance's id.                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/1/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_feature_instance (IGRlong          * msg,
                                struct GRmd_env  * mod_env,
                                struct GRid      * id,
                                struct GRid      * instance_id)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct GRmd_env     cur_mod_env;
    struct GRid         context_id, ref_id, owner_id;
    OM_S_CHANSELECT     chansel;
    IGRint              i, count;
    IGRuint             nret;
    OM_S_OBJECT_LINKAGE object_linkage;

    /*
     * Check arguments.
     */
    if (!id || !msg)
    {
        om_msg = OM_E_ABORT;
        goto quit;
    }
    
    /*
     * Get the current module environment.
     */
    gr$get_module_env (buffer = &cur_mod_env);

    if (mod_env)
    {
        /*
         * See if the object is a reference file object.
         */
        GRcheckref (msg,
                    &(mod_env->md_env.matrix_type),
                    mod_env->md_env.matrix,
                    &(cur_mod_env.md_id.osnum),
                    &(id->osnum));

        /*
         * If the object is in a reference file ...
         */
        if (*msg == MSSUCC)
        {
            /*
             * Get the context that matches the locate matrix.
             */
            om_msg = GRfindcontext(msg,
                                   &(mod_env->md_env.matrix_type),
                                   mod_env->md_env.matrix,
                                   &(id->osnum),
                                   &context_id);
            
            if (!(om_msg & *msg & 1))
            {
                goto quit;
            }
            
            /*
             * Determine which reference file it came from.
             */
            om$make_chanselect(channame = "GRcontext.to_reffile",
                               p_chanselect = &chansel);

            om_msg = om$get_channel_objects (objid = context_id.objid,
                                             osnum = context_id.osnum,
                                             p_chanselect = &chansel,
                                             list = &object_linkage,
                                             size = 1,
                                             count = &nret);
            
            if (!(om_msg & *msg & 1) || (nret == 0))
            {
                if (nret == 0)
                {
                    *msg = MSFAIL;
                }
                
                goto quit;
            }

            ref_id.objid = object_linkage.S_objid;
            ref_id.osnum = object_linkage.osnum;
            
            id = &ref_id;
        }
        else if (id->osnum != cur_mod_env.md_id.osnum)
        {
            goto quit;
        }
        
        EMget_feature_instance (msg, NULL, id, instance_id);
    }
    else if (id->osnum != cur_mod_env.md_id.osnum)
    {
        *msg = MSFAIL;
        goto quit;
    }

    /*
     * If the object isn't defined as a instance.
     */
    if (!EMis_feature_instance (msg, id, instance_id))
    {
        *msg = MSFAIL;
        
        /*
         * Walk up the owner channel and find a object that is defined
         * as a part instance.
         */
        GRget_to_owner_info (&chansel, id->osnum, id->objid, &count);

        for (i=0; i<count; ++i)
        {
            om_msg = om$get_objid_at_index (objid = id->objid,
                                            osnum = id->osnum,
					    index = i,
                                            p_chanselect = &chansel,
                                            objidaddr = &owner_id.objid,
                                            osnumaddr = &owner_id.osnum);

            if (!(om_msg & 1))
            {
                goto quit;
            }
            
            om_msg = EMget_feature_instance (msg, 
                                             NULL, 
                                             &owner_id, 
                                             instance_id);
            
            if (om_msg & *msg & 1)
            {
                break;
            }
        }
	/*
	 * No EMinstance found.
	 */
	if(i == count) 
	{
	    om_msg = EMget_localpart_frm_grid (msg, id, &cur_mod_env, instance_id);
        }
    }

 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMadd_assembly_constraint                                       |
 |                                                                           |
 | This function adds a constraint between two instances.                    |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMadd_assembly_constraint (IGRlong       * msg,
                                   IGRint          type,
                                   struct GRid   * instance1_id,
                                   struct GRid   * instance2_id,
                                   FEATURE_INFO  * feature_1,
                                   FEATURE_INFO  * feature_2,
                                   IGRchar       * offset,
                                   struct GRid   * constraint_id,
                                   IGRint        * num_ids,
                                   struct GRid   ** ids)
{
IGRlong      om_msg = OM_S_SUCCESS;
IGRint       constr_type, tmpidcnt;
struct       GRid tmpgrid, *tmpids;
FEATURE_INFO tmpinfo1, tmpinfo2;

    *msg = ASM_S_SUCCESS;

    switch (type)
    {
        case EM_MATE:
        case EM_ALIGN:
            /*
             * Make sure both instances and features are specified.
             */
            if (!feature_1  || !feature_2 ||
       	        !instance1_id || !instance2_id)
            {
       	        *msg = ASM_E_INVARGS;
                goto quit;
            }
       
            /*  
       	     * If the instances are the same error out.
             */
       	    if ((instance1_id->objid == instance2_id->objid) &&
                (instance1_id->osnum == instance2_id->osnum))
       	    {
                *msg = ASM_E_INVARGS;
           	    goto quit;
            }

            /*
             * KLUDGE: Set the constraint type to the internally defined
             * #define in the assemcnstr.h. Eventually the internal 
             * definition for the assembly constraint type will be the
             * same as that used by the macros. Also these #defines will
             * be found in assemdef.h.
             */

    	    constr_type = ( type == EM_MATE ) ? MATE : ALIGN;
            om_msg = EMput_constr (msg,
                                        constr_type,
                                        *instance1_id,
                                        *instance2_id,
                                        *feature_1,
                                        *feature_2,
                                        offset,
                                        constraint_id);
	    break;

        case EM_GROUND:
            om_msg = EMput_constr (msg,
                               GROUND,
                               tmpgrid,
                               *instance2_id,
                               tmpinfo1,
                               tmpinfo2,
                               offset,
                               constraint_id);
    	    break;

        case EM_INSERT:
        case EM_TANGENCY:
            *msg = ASM_E_NOTSUPPORTED;
            break;

        default:
            *msg = ASM_E_INVARGS;
            break;
    }
    if (!(om_msg & *msg & 1))
         goto quit;

    if(!ids)
        ids = &tmpids;
    if(!num_ids)
        num_ids = &tmpidcnt;

    om_msg = om$send (msg = message EMconstr.EMprocess_constr_addition
                                                (msg, num_ids, ids),
                         targetid = (*constraint_id).objid,
                         targetos = (*constraint_id).osnum,
                         senderid = NULL_OBJID);
quit:
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_constraint_attrs                                          |
 |                                                                           |
 | This function returns the constraint attributes of the constraint object. |
 |                                                                           |
 | History:  krishna kumar 12/27/93     Creation                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_constraint_attrs (IGRlong     * msg,             /* OUTPUT */
                                struct GRid * id,              /* INPUT  */
                                IGRuint     * attrs)           /* OUTPUT */
{
    IGRlong om_msg;
    
    *msg = ASM_S_SUCCESS;

    /* 
     * Get the constraint attributes from the instance data. 
     */
    om_msg = om$send (msg = message EMconstr.EMget_constraint_attrs
                                                            (msg, attrs),
                      senderid = NULL_OBJID,
                      targetid = id->objid,
                      targetos = id->osnum);
    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMset_constraint_attrs                                          |
 |                                                                           |
 | This function sets the constraint attributes of the constraint object.    |
 |                                                                           |
 | History:  krishna kumar 12/27/93     Creation                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMset_constraint_attrs (IGRlong     * msg,             /* OUTPUT */
                                struct GRid * id,              /* INPUT  */
                                IGRuint     attrs)             /* INPUT  */
{
    IGRlong om_msg;
    
    *msg = ASM_S_SUCCESS;

    /* 
     * Set the constraint attributes from the instance data. 
     */
    om_msg = om$send (msg = message EMconstr.EMset_constraint_attrs
                                                            (msg, attrs),
                      senderid = NULL_OBJID,
                      targetid = id->objid,
                      targetos = id->osnum);
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_paired_parts                                              |
 |                                                                           |
 | This function gets the parts between which the constraint is acting.      |
 | The direction is p1 --> C --> p2. ie., p2 is incident part.               | 
 |                                                                           |
 | History:  krishna kumar 02/02/94     Creation                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/

IGRint EMget_paired_parts( IGRlong *msg,
			struct GRid *cnstr_id,
			struct GRid *p1_id,
			struct GRid *p2_id )
{
IGRint om_msg = OM_S_SUCCESS;

    *msg = MSSUCC;

    if( p1_id )
    {
        om_msg = om$send( msg = message EMconstr.EMgetpart( msg,
                                                            FALSE,
                                                            p1_id),
                            senderid = NULL_OBJID,
                            targetid = cnstr_id->objid,
                            targetos = cnstr_id->osnum );

    }

    if( p2_id )
    {
        om_msg = om$send( msg = message EMconstr.EMgetpart( msg,
                                                            TRUE,
                                                            p2_id),
                            senderid = NULL_OBJID,
                            targetid = cnstr_id->objid,
                            targetos = cnstr_id->osnum );
    }

    return( om_msg );
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_paired_features                                           |
 |                                                                           |
 | This function gets the features and their enviroments between which the   |
 | constraint is acting.                                                     |
 | The direction is p1 --> C --> p2. ie., p2 is incident part.               |
 |                                                                           |
 | History:  krishna kumar 02/02/94     Creation                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/

IGRint EMget_paired_features( IGRlong *msg,
			      struct GRid *cnstr_id,
			      struct GRid *f1_id,
                              struct GRmd_env *f1_env,
			      struct GRid *f2_id,
                              struct GRmd_env *f2_env )
{
IGRint om_msg = OM_S_SUCCESS;
struct GRid fea_ids[2];
struct GRmd_env envs[2];

    *msg = MSSUCC;

    om_msg = om$send( msg = message EMconstr.EMget_ftrs_with_env( msg, 
                                                                  fea_ids,
                                                                  envs ),
                                        senderid = NULL_OBJID,
                                        targetid = cnstr_id->objid,
                                        targetos = cnstr_id->osnum );

    if( !(om_msg & *msg & 1) )
        goto quit;

    if( f1_id )
    {
        *f1_id = fea_ids[0];
        if( f1_env )
            *f1_env = envs[0];
    }

    if( f2_id )
    {
        *f2_id = fea_ids[1];
        if( f2_env )
            *f2_env = envs[1];
    }

quit:
    return( om_msg );
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_constraints_count                                         |
 |                                                                           |
 | This function gets the count of constraints INTO or OUT of the given part |
 | Input:                                                                    |
 |        struct GRid     * partid          part id                          |
 |        IGRint            types           0 - IN constraints only          |
 |                                          1 - OUT constraints only         |
 |                                          2 - both IN/OUT constraints      |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * num             Number of constraints            |
 |                                                                           |
 | History:  krishna kumar 15/02/94     Creation                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/

IGRint EMget_constraints_count( IGRlong * msg,
				struct GRid * partid,
				IGRint types,
				IGRint * num )
{
IGRint om_msg = OM_S_SUCCESS, i;
IGRint loc_count = 0;
struct  GRid *list;
OMuword classid;

    *msg = MSSUCC;
    *num = 0;

    if( types != 1 )        
    {
        om_msg = om$send( msg = message NDnode.NDget_objects( ND_ROOT | ND_IN_BUF, NULL,
                                                              0, &list, 
                                                              0, OM_K_MAXINT,
                                                              &loc_count),
			     senderid = NULL_OBJID,
                             targetid = partid->objid,
                             targetos = partid->osnum);

        if (om_msg & 1)
        {
            for (i = 0; i < loc_count; i++)
            {
                om$get_classid (objid = list[i].objid, 
                                osnum = list[i].osnum,
                                p_classid = &classid);
                if (om$is_ancestry_valid (subclassid = classid,
                    superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
                {
                    (*num)++;
                }
            }
        }                    
    }
    loc_count = 0;
    if( types != 0 ) 
    {
        om_msg = om$send( msg = message NDnode.NDget_objects( ND_CHILDREN | ND_IN_BUF, NULL,
                                                              0, &list, 
                                                              0, OM_K_MAXINT,
                                                              &loc_count),
			     senderid = NULL_OBJID,
                             targetid = partid->objid,
                             targetos = partid->osnum);

        if (om_msg & 1)
        {
            for (i = 0; i < loc_count; i++)
            {
                om$get_classid (objid = list[i].objid, 
                                osnum = list[i].osnum,
                                p_classid = &classid);
                if (om$is_ancestry_valid (subclassid = classid,
                    superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
                {
                    (*num)++;
                }
            }
        }                    
    }
    return( om_msg );
}				

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_constraint_at_index                                       |
 |                                                                           |
 | This function gets the constraint at the given index of the given part    |
 | and also returns whether the constraint is INTO or OUT of the given part  |
 | Note: The index is counted starting from the first IN constraint to the   |
 |       last OUT constraint.                                                |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * part_id         part id                          |
 |        IGRint            index           constraint index                 |
 |                                                                           |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * in_out          IN or OUT of the given part      | 
 |        IGRint          * type            type of constraint               | 
 |        struct GRid     * cnstr_id        constraint id                    |
 |                                                                           |
 | History:  krishna kumar 15/02/94     Creation                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/

IGRint EMget_constraint_at_index( IGRlong * msg,
				struct GRid * partid,
				IGRint index,
                	        IGRint * in_out,
				IGRint * type,
				struct GRid *cnstrid )
{
IGRint om_msg = OM_S_SUCCESS, i;
IGRint loc_count, cnt = 0;
struct GRid *list;
OMuword classid;

    *msg = MSSUCC;
    *in_out = -1;
    if( type )
        *type = -1;

    om_msg = om$send( msg = message NDnode.NDget_objects( ND_ROOT | ND_IN_BUF,
							  NULL,
                                                          NULL, &list, 
                                                          0, OM_K_MAXINT,
                                                          &loc_count),
			     senderid = NULL_OBJID,
                             targetid = partid->objid,
                             targetos = partid->osnum);
    if( om_msg & 1 )
    {
        for (i = 0; i < loc_count; i++)
        {
            om$get_classid (objid = list[i].objid, 
                            osnum = list[i].osnum,
                            p_classid = &classid);
            if (om$is_ancestry_valid (subclassid = classid,
                    superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
            {
                if( index == cnt )
                {
                    *cnstrid = list[i];
                    *in_out = 0;
            	    if( type != NULL )
            	        EMgetconstrtype( *cnstrid, type );
                    goto wrapup;
                }
                cnt++;
            }
        }
    }
    else
        goto wrapup;

    om_msg = om$send( msg = message NDnode.NDget_objects( ND_CHILDREN | ND_IN_BUF,
							  NULL,
                                                          NULL, &list, 
                                                          0, OM_K_MAXINT,
                                                          &loc_count),
			     senderid = NULL_OBJID,
                             targetid = partid->objid,
                             targetos = partid->osnum);
    if( om_msg & 1 )
    {
        for (i = 0; i < loc_count; i++)
        {
            om$get_classid (objid = list[i].objid, 
                            osnum = list[i].osnum,
                            p_classid = &classid);

            if (om$is_ancestry_valid (subclassid = classid,
                    superclassid = OPP_EMconstr_class_id) == OM_S_SUCCESS)
            {
                if( index == cnt )
                {
                    *cnstrid = list[i];
                    *in_out = 1;
            	    if( type != NULL )
            	        EMgetconstrtype( *cnstrid, type );
                    goto wrapup;
                }
                cnt++;
            }
        }
    }

wrapup:
    return( om_msg );
}				

/*---------------------------------------------------------------------------+
 |                                                                           |
 | This function sets the constraint expression value  (syntax)              |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * cnstrid         constraint id.                   |
 |        IGRchar         * exp_syntax      expression syntax                |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |                                                                           |
 | History:  krishna kumar 15/02/94     Creation                             |
 +---------------------------------------------------------------------------*/

IGRint  EMset_constraint_value ( IGRlong * msg,
		      	         struct  GRid *cnstrid,
                                 IGRchar * exp_syntax)
{
IGRint om_msg = OM_S_SUCCESS;

    *msg = MSSUCC;
    om_msg = om$send( msg = message EMconstr.EMset_offset ( msg, exp_syntax ),
                                    senderid = NULL_OBJID,
                                    targetid = cnstrid->objid,
                                    targetos = cnstrid->osnum );
    return( om_msg );
}				

/*---------------------------------------------------------------------------+
 |                                                                           |
 | This function gets the remaining dof of the given part                    |
 |                                                                           |
 | Input:                                                                    |
 |        struct GRid     * partid          part id.                         |
 | Output:                                                                   |
 |        IGRlong         * msg             Return code, MSSUCC or MSFAIL.   |
 |        IGRint          * dof             Remaining dof                    |
 |        IGRchar         * dof_str         descriptive dof string           | 
 |                                                                           |
 | History:  krishna kumar 15/02/94     Creation                             |
 +---------------------------------------------------------------------------*/
IGRint EMget_remaining_dof ( IGRlong * msg,
		      	     struct GRid * partid,
                             IGRint * dof,
                             IGRchar * dof_str )
{
IGRint om_msg = OM_S_SUCCESS;
IGRint loc_count;
IGRuint basis;

    /*
     * Get the number of incident constraints
     */
    loc_count = 0;
    *msg = MSSUCC;
    om_msg = asm$get_constraints_count( msg = msg,
                                        part_id = partid,
                                        in_out = 0,
                                        count = &loc_count );
    if( loc_count == 0 )
    {
        *dof = 6;
        if( dof_str )
            strcpy( dof_str, "ALL" );

        return( OM_S_SUCCESS );            
    }
        
    om_msg = om$send( msg = message EMinstance.EMgivebasis( msg, &basis ),
                            senderid = partid->objid,
                            targetid = partid->objid,
                            targetos = partid->osnum );
    if( !(om_msg & *msg & 1 ) )
    {
        goto wrapup;
    }
    switch( basis )
    {
        case NULL_BASIS_ID:
            *dof = 6;
            if( dof_str )
                strcpy( dof_str, "ALL" );
            break;
            
        case MATE_ONE_CONSTR: /* 2 ortho trans, 1 paral rot */
            *dof = 3;
            if( dof_str )
                strcpy( dof_str, "2 Tra, 1 Rot" );
            break;
                
        case ALIGN_ONE_CONSTR:/* 1 paral trans, 1 paral rot */
            *dof = 2;
            if( dof_str )
                strcpy( dof_str, "1 Tra, 1 Rot" );
            break;

        case MATE_MATE_PERP:  /* 1 ortho trans to both */
        case MATE_MATE_ANG:   /* 1 ortho trans to both */        
            *dof = 1;
            if( dof_str )
                strcpy( dof_str, "1 Tra" );
            break;
            
        case MATE_ALIGN_PERP: /* 1 paral trans along Align */
            *dof = 1;
            if( dof_str )
                strcpy( dof_str, "1 Tra" );
            break;
        
        case MATE_ALIGN_PAR:  /* 1 paral rot on Align */
            *dof = 1;
            if( dof_str )
                strcpy( dof_str, "1 Rot" );
            break;

        case ALIGN_ALIGN_PAR: /* 1 paral trans to both */
            *dof = 1;
            if( dof_str )
                strcpy( dof_str, "1 Tra" );
            break;

        case GROUND_ONE_CONSTR:
        case ALIGN_ALIGN_PERP:
        case MATE_ALIGN_ANG:	
        case ALIGN_ALIGN_ANG:	
        case MATE_MATE_MATE_PERP_PERP_PERP:
        case MATE_MATE_MATE_PERP_PERP_ANG:
        case MATE_MATE_MATE_PERP_ANG_ANG:
        case MATE_MATE_MATE_ANG_ANG_ANG:
        case MATE_MATE_ALIGN_PERP_PERP_PAR:
        case MATE_ALIGN_ALIGN_PAR_PAR_PAR:
            *dof = 0;
            if( dof_str )
                strcpy( dof_str, "NONE" );
            break;
    }
                                        
wrapup:
    return( om_msg );
}				



end implementation EMinstance;

