class implementation EMinstance;

#include <grimport.h>
#include <DIprims.h>
#include <grerr.h>
#include <gocmacros.h>
#include <assemdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include <godef.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <grownerdef.h>
#include <igrtypedef.h>
#include <OMerrordef.h>
#include <msdef.h>
#include <refdef.h>
#include <ref.h>
#include <nddef.h>
#include <ndmacros.h>

#ifdef DEBUG
#define verbose(x) x
#else
#define verbose(x)
#endif

extern int   GRget_to_comp_chansel ();
extern int   GRget_to_owner_chansel ();

#include <assemdef.h>
#include <assem.h>
#include <assempriv.h>
#include <assemconstr.h>

extern OMuword OPP_ASsource_class_id;
extern OMuword OPP_GRcontext_class_id;
extern OMuword OPP_EMlocalpart_class_id;

from GRcontext import GRgetosnum;
from GRreffile import GRgetenvironment;
from EMconstr  import EMgetpart;
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_part                                                        |
 |                                                                           |
 | This method returns the part definition object for this instance.         |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code, MSSUC or MSFAIL for now.    |
 |          struct GRid * part_id   Properties.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_part (IGRlong     *  msg; 
                   struct GRid * part_id )
{
    IGRlong         om_msg = OM_S_SUCCESS;
    IGRint          i, count = 0;
    IGRchar         name[DI_PATH_MAX], directory[DI_PATH_MAX];
    OM_S_OBJID      objid;
    OMuword         osnum, classid;
    
    *msg = ASM_S_SUCCESS;
    
    om_msg = di$start_untrans (ptr = &count,
                               objid = my_id,
                               osnum = OM_Gw_current_OS);
    
    if (!(om_msg & 1) || (om_msg == DIR_W_NAME_NOT_FOUND))
    {
        goto quit;
    }
    
    for (i=0; i<count; ++i)
    {
        om_msg = di$fetch_untrans (objname = name,
                                   index = i);
            
        if ((om_msg & 1) && (om_msg != DIR_W_NAME_NOT_FOUND))
        {
            di$split (pathname = name,
                      dirname = directory);
                
            if (di$translate (objname = directory,
                              p_objid = &objid,
                              p_osnum = &osnum) != DIR_S_SUCCESS)
            {
                continue;
            }
                
            om$get_classid (objid = objid,
                            osnum = osnum,
                            p_classid = &classid);
            
            if (om$is_ancestry_valid (superclassname = "EMpart",
                                      subclassid = classid) == OM_S_SUCCESS)
            {
                if (part_id)
                {
                    part_id->objid = objid;
                    part_id->osnum = osnum;
                }
                
                break;
            }
        }
    }

    if (i == count)
    {
        *msg = ASM_E_ABORT;
    }

 quit:

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: GRgetobjinfo                                                    |
 |                                                                           |
 | This method returns the object info.                                      |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
    *msg = MSSUCC;

    strcpy (info->type, "part occurrence");

    return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: unknown                                                         |
 |                                                                           |
 | This method redirects the unknown message to the appropriate owner/member.|
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  7/22/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method unknown ( OM_p_MESSAGE msg )
{
    IGRlong         om_msg = OM_W_UNKNOWN_MSG;
    OM_S_CHANSELECT chansel, owner_chansel;

    if (GRget_to_comp_chansel (&chansel) && 
        GRget_to_owner_chansel(&owner_chansel))
    {
        /*
         *  Is the unknown message from the graphics object?
         *  Assumes the chanselect is by number!
         */
        if (!memcmp ((char *)&chansel.u_sel.number, (char *)&in_channel,
                     sizeof ( OM_S_CHANNUM )))
        {
            if (me->to_owners)
            {
                /* 
                 *  Send the unknown message to my owners.
                 */
                om_msg = om$send (msg = msg, p_chanselect = &owner_chansel);
            }
        }
        else 
        {
            /*
             * Send the unknown message to the graphics object.
             */
            if (me->to_components)
            {
                om_msg = om$send (msg = msg, p_chanselect = &chansel);
            }
        }
    }

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: delete                                                          |
 |                                                                           |
 | This method redirects the delete message to the EMdescribe class.         |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  7/22/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method delete (int f_defer_flag)
{
    return (om$send (msg = message EMdescribe.delete (f_defer_flag),
                     mode = OM_e_wrt_message,
                     targetid = my_id));
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: debug                                                           |
 |                                                                           |
 | This method redirects the debug message to the EMdescribe class.          |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  7/22/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method debug ()
{
    IGRlong msg;
    struct GRid my_grid;
    
    my_grid.osnum = OM_Gw_current_OS;
    my_grid.objid = my_id;
    
    EMconstrdbg (&msg, my_grid);
    
    return (om$send (msg = message EMdescribe.debug (),
                     mode = OM_e_wrt_message,
                     targetid = my_id));
}

#include <assemmacros.h>

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Methode: EMpass                                                           |
 |                                                                           |
 | This method will call a function on itself and the propogate the pass     |
 | message to each describe object inside the receiving describe object. The |
 | user may also provide a selection function that further narrows the scope |
 | of the pass.                                                              |
 |                                                                           |
 | Input:   struct GRmd_env * mod_env           Module environment.          |
 |          IGRint            depth             Initial depth, 0.            |
 |          IGRlong           (*pass_func)()    Function to call.            |
 |          IGRchar         * pass_func_info    Function information.        |
 |          IGRboolean        (*pass_select)()  Function to select pass objs |
 |                                                                           |
 | Output:  IGRlong     * msg       Return code                              |
 |                                                                           |
 | Prototype: IGRlong      (*pass_func)(IGRlong         * msg,               |
 |                                      struct GRmd_env * mod_env,           |
 |                                      IGRint            depth,             |
 |                                      IGRchar         * pass_func_info,    |
 |                                      struct GRid     * desc_id)           |
 |                                                                           |
 |            IGRboolean   (*pass_select)(struct GRmd_env * mod_env,         |
 |                                        IGRint            depth,           |
 |                                        IGRchar         * pass_func_info,  |
 |                                        struct GRid * desc_id)             |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMpass (IGRlong         * msg;
               struct GRmd_env * mod_env;
               IGRint            depth;
               IGRlong           (*pass_func)();
               IGRchar         * pass_func_info;
               IGRboolean        (*pass_select)())
{
    IGRlong         om_msg = OM_S_SUCCESS;
    struct GRid     part_id, ref_id;
    struct GRmd_env ref_mod_env, env_path;
    
    /*
     * Call the EMpass on myself at the EMdescribe level, this
     * will take care of calling the function on myself and
     * propagating this message to any member describe objects.
     */
    om_msg = om$send (msg = message EMdescribe.EMpass (msg,
                                                       mod_env,
                                                       depth,
                                                       pass_func,
                                                       pass_func_info,
                                                       pass_select), 
                      mode = OM_e_wrt_message,
                      targetid = my_id);
    
    if ((om_msg == OM_I_STOP_SENDING) || !(om_msg & *msg & 1))
    {
        om_msg = OM_S_SUCCESS;
        *msg = ASM_S_SUCCESS;
	goto quit;
    }

    /*
     * If I'm a reference part instance ...
     */
    if (me->props & EM_REFERENCE_PART)  
    {
        EMmemb memb;
        
        /*
         * Get the my reference file.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_memb (msg, 
                                                               NULL,
                                                               EM_GRAPHIC,
                                                               0,
                                                               &memb),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        ref_id.objid = memb.id.objid;
        ref_id.osnum = memb.id.osnum;
        
        /*
         * Get the environment for this reference file.
         */
        om_msg = om$send (msg = message GRreffile.GRgetenvironment
                                               (msg, &env_path, &ref_mod_env),
                          targetid = ref_id.objid,
                          targetos = ref_id.osnum);
            
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        /*
         * Get the file part in the reference file object space.
         */
        om_msg = asm$get_file_part (msg = msg,
                                    mod_env = &ref_mod_env,
                                    part_id = &part_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }

        /*
         * Send the pass message if the file part passes selection.
         */
        if ((pass_select) ? (*pass_select)(&ref_mod_env,
                                           depth,
                                           pass_func_info,
                                           &part_id) : TRUE)
        {
            /*
             * Propagate the EMpass through the file part.
             */
            om_msg = om$send (msg = message EMdescribe.EMpass
                                                          (msg,
                                                           &ref_mod_env,
                                                           depth,
                                                           pass_func,
                                                           pass_func_info,
                                                           pass_select),
                              targetid = part_id.objid,
                              targetos = part_id.osnum);
        }
    }

 quit:

    return om_msg;
}


method EMget_feature_context( IGRlong *rc; struct GRid *feature_id; 
					struct GRid *cntxt_id )
{
int       om_msg, cnt, i, j;
GRclassid classid;
GRspacenum osnum;
OM_S_CHANSELECT to_listeners;
OM_S_OBJECT_LINKAGE *list = NULL;
unsigned int go_cnt;
struct GRid asgrid, *root_list;
IGRlong msg;

    *rc = MSSUCC;
    cntxt_id->objid = NULL_OBJID;
    /*
     * Get the source object on the parents' channel
     */
    om_msg = om$send( msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,NULL,
                                              0,&root_list,0,OM_K_MAXINT,&cnt),
                     targetid = my_id );
    if( !( om_msg & 1 ))
        return( OM_E_ABORT );

    for( i = 0; i < cnt; i++ )
    {
        om$get_classid (objid = root_list[i].objid, 
                        osnum = root_list[i].osnum,
                        p_classid = &classid);

        if (om$is_ancestry_valid (subclassid = classid,
                superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS)
        {
            asgrid = root_list[i];
            om$make_chanselect ( channame = "ASsource.listeners",
                             p_chanselect = &to_listeners );

            om$get_channel_count ( objid = asgrid.objid,
                                   p_chanselect = &to_listeners,
                                   count = &go_cnt );

            list = (OM_S_OBJECT_LINKAGE *)malloc( go_cnt * sizeof( OM_S_OBJECT_LINKAGE ) );
            om$get_channel_objects ( objid = asgrid.objid,
                                     p_chanselect = &to_listeners,
                                     list = list,
                                     size = go_cnt,
                                     count = &go_cnt);
            /*
             *  find the GRcontext and if it belongs to the input feature's 
	     *  osnum, return it.
             */
            for( j = 0; j < go_cnt; j++ )
            {
                om$get_classid (objid = list[j].S_objid, 
                                osnum = list[j].osnum,
                                p_classid = &classid);

                if (om$is_ancestry_valid (subclassid = classid,
                    superclassid = OPP_GRcontext_class_id) == OM_S_SUCCESS)
                {
		    /*
                     * Find the osnum of the located GRcontext
                     */
                    om_msg = om$send( msg = message GRcontext.GRgetosnum( &msg,
                                                                &osnum ),
                                    targetid = list[j].S_objid,
                                    targetos = list[j].osnum );
                    if( om_msg & msg & 1 )
                    {
                        if( osnum == feature_id->osnum )
                        {
                            cntxt_id->objid = list[j].S_objid;
                            cntxt_id->osnum = list[j].osnum;
                        }
                    }
                    else
                    {
                        free( list );
                        verbose(printf("GRgetosnum failed\n"));
                        return( OM_E_ABORT );
                    }
                }
            }
        }
    }
    if( cntxt_id->objid == NULL_OBJID )
    {
    struct GRmd_env md_env;

        if ( list )
            free( list );

        gr$get_module_env( buffer = &md_env );
        om_msg = EMget_localpart_frm_grid( &msg, feature_id, &md_env, &asgrid);
        if( !(om_msg & msg & 1 ))
        {
            verbose(printf("Could not locate the context GRid\n"));
            return( OM_E_ABORT );
        }
    }
    if( list )
        free( list );
    return( OM_S_SUCCESS );
}

method EMgivebasis( IGRlong *rc; IGRuint *basis )
{
    *rc = MSSUCC;

    *basis = me->basis;

    return( OM_S_SUCCESS );
}

method EMupdatebasis( IGRlong *rc )
{
int  om_msg, num_inc;
long msg;
struct GRid inc_constr[MAX_INCIDENT_CONSTR];
IGRuint basis, props1;

IGRshort action;
IGRshort props = GRIS_ASSOCIATIVE | GRHAS_EXTERNAL_CONSTRAINT;


    *rc = MSSUCC;
    om_msg = OM_S_SUCCESS;
    /*
     * Get the list of constraints incident on this part and depending on the
     * type of constraints and the rel ang between them, set the basis.
     */
    om_msg = om$send( msg = message EMinstance.EMget_incident_constr( &msg,
                                                            &num_inc,
                                                            inc_constr),
                        targetid = my_id );

    if( !(om_msg & msg & 1 ))
    {
        verbose(printf("Error: EMget_incident_constr\n"));
        goto quit;
    }
    if( num_inc == 0 )
    {
    struct GRid my_grid;

        action = 0;
        om_msg = om$send (msg = message GRgraphics.GRchgprops (&msg,
                                                              &action,
                                                              &props),
                                  targetid = my_id );

        if( !( om_msg & msg & 1 ))
        {
           verbose(printf("GRchgprops failed\n"));
        }

	me->basis = NULL_BASIS_ID;

	/* Also, set the state of the part to UN_EXPLODED */
        props1 = 0;
	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;
    	/* Reset the property of the part */
        asm$set_application_props( msg = &msg,
                                   id = &my_grid,
                                   props = props1 );

     	return( OM_S_SUCCESS );
    }
    else
    {
        action = 1; /* This means set the bits. */
        om_msg = om$send (msg = message GRgraphics.GRchgprops (&msg,
                                                              &action,
                                                              &props),
                                  targetid = my_id );

        if( !( om_msg & msg & 1 ))
        {
            verbose(printf("GRchgprops failed\n"));
        }
    }

    om_msg = om$send (msg = message EMinstance.EMcheckbasis
        (&msg, num_inc, inc_constr, &basis), targetid = my_id);
    if( !(om_msg & msg & 1 ))
    {
        verbose(printf("Error: EMupdatebasis\n"));
        goto quit;
    }

    me->basis = basis;

quit:
    return( om_msg );

}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMupdate                                                         |
 |                                                                           |
 | This method will cause the instance to update itself according to the     |
 | new part number and revision in it's cached part. The filename of the     |
 | cached part isn't considered in this update because the reference files   | 
 | attached to the instance determines the source for the cached part's      |
 | definition.                                                               |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code.                             |
 |                                                                           |
 | Return:  ASM_S_SUCCESS   Constructed sucessfully.                         |
 |          ASM_E_ABORT     Catostrophic error.                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMupdate (IGRlong *msg)
{
    IGRlong     om_msg;
    struct GRid instance_id, part_id;
    EMattr      number, revision;
    IGRchar     old_name[DI_PATH_MAX], new_name[DI_PATH_MAX], *p_unique;
    
    *msg = ASM_S_SUCCESS;
    
    instance_id.objid = my_id;
    instance_id.osnum = OM_Gw_current_OS;
    
    /*
     * Get my part.
     */
    om_msg = asm$get_instance_part (msg = msg,
                                    instance_id = &instance_id,
                                    part_id = &part_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*
     * Get my current name.
     */
    if (di$untranslate (objid = my_id,
                        objname = old_name) != DIR_S_SUCCESS)
    {   
        *msg = ASM_E_ABORT;
        goto quit;
    }
        
    /*
     * Get the part number and revision.
     */
    om_msg = asm$get_part_identity (msg = msg,
                                    part_id = &part_id,
                                    number = &number,
                                    revision = &revision);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }
    
    /*
     * Construct the proper name.
     */
    om_msg = di$give_pathname (osnum = OM_Gw_current_OS,
                               pathname = new_name);
    
    if (!(om_msg & 1) || (om_msg == DIR_W_NAME_NOT_FOUND))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
        
    /*
     * Use the same uniqueifier.
     */
    p_unique = strchr(old_name, '#');
    
    sprintf (&new_name[strlen(new_name)], ":%s:%s_%s:%s_%s%s", 
             "assembly",
             number.value.data.s, 
             revision.value.data.s,
             number.value.data.s, 
             revision.value.data.s,
             p_unique);
    
    if (strcmp(new_name, old_name))
    {
        sprintf (new_name, "%s_%s%s", 
                 number.value.data.s, 
                 revision.value.data.s,
                 p_unique);
        
        om_msg = EMrename_directory (msg, &instance_id, new_name);
                
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
    }
          
quit:

    return om_msg;
}

method NDmove_to_root (IGRlong *msg; struct GRid *src_grid;
			  struct GRmd_env *md_env )
{
IGRint om_msg = OM_S_SUCCESS, cnt = 0, flg, i, numprt, delcnt = 0;
struct GRid  *cnstr_list = NULL, *del_list = NULL, my_grid, fid[2];
struct GRid  *part_grid = NULL;
OM_S_CHANSELECT  chan;

    /*
     * Get all the constraints in/out of the part, because the affected
     * constraints can be either incident or outward.
     */
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    om_msg = asm$get_constraints_count( msg = msg,  
                                        part_id = &my_grid,
                                        in_out = 2,
                                        count = &cnt );
    if( !(om_msg & *msg & 1) || !(cnt) )
        goto quit;
    
    cnstr_list = (struct GRid *)malloc( cnt * sizeof(struct GRid));
    del_list = (struct GRid *)malloc( cnt * sizeof(struct GRid));
    part_grid = (struct GRid *)malloc(  cnt * sizeof(struct GRid));
    numprt = 0;
    delcnt = 0;

    for (i = 0; i < cnt; i++ ) 
    {
        om_msg = asm$get_constraint (msg = msg,
                           part_id = &my_grid,
                           index = i,
                           in_out = &flg,
                           cnstrid = &cnstr_list[i]);

        if( !(om_msg & *msg & 1))
            goto quit;
   
        /*
         * Get the features from each constraint
         */
        om_msg = asm$get_paired_features( msg = msg,
                                        cnstrid = &cnstr_list[i],
                                        f1_id = &fid[0],
                                        f2_id = &fid[1] );
        if ( !(om_msg & *msg & 1) )
        {
	    /*
             * Store the constraint grid in del_list 
             */
            del_list[delcnt++] = cnstr_list[i];
        }
    }
    /*
     * If either one of the features is not present, disconnect this
     * constraint and remember the incident part of that constraint,
     * because the basis of the incident part only needs to be updated.
     */

    for( i = 0 ; i < delcnt; i++ )
    {
            om_msg = om$send (msg = message EMconstr.EMgetpart (msg, TRUE, 
                                                           &part_grid[numprt]), 
                     targetid = del_list[i].objid,
                     targetos = del_list[i].osnum);

            if( !(om_msg & *msg & 1) )
                goto quit;

	    om$make_chanselect( channame = "NDfather.father",
                            p_chanselect = &chan );

            om_msg = om$send(msg = message  Root.wild_disconnect(chan),
                         targetid = del_list[i].objid,
                         targetos = del_list[i].osnum);

	    om$make_chanselect( channame = "NDchildren.children",
                            p_chanselect = &chan );

            om_msg = om$send(msg = message  Root.wild_disconnect(chan),
                         targetid = del_list[i].objid,
                         targetos = del_list[i].osnum);

            om_msg = om$send(msg = message  Root.delete(1),
                         targetid = del_list[i].objid,
                         targetos = del_list[i].osnum);

            if( !(om_msg & 1) )
                goto quit;

            numprt += 1;
    }

    for (i = 0; i < numprt; i++ )
    {
        /*
         * Update the basis of the parts that were affected.
         */
        om_msg = om$send (msg = message EMinstance.EMupdatebasis( msg ),
                     targetid = part_grid[i].objid,
                     targetos = part_grid[i].osnum);

        if( !(om_msg & *msg & 1 ))
            goto quit;
    }

quit:
    if( cnstr_list )
	free( cnstr_list );
    if( del_list )
	free( del_list );
    if( part_grid )
        free( part_grid );

    return( OM_S_SUCCESS );
}
end implementation EMinstance;






