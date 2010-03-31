/*###################   APOGEE COMPILED   ################## */
class implementation EMSsfaddraft;

#include "EMSas.h"
#include "EMSasnucdef.h"
#include "EMSasfeatdef.h"

/*   
 *  This function creates the feature add draft. The feature can be placed as
 *  a associative or non-associative entity.
 *
 *  Nirmal 2/10/93 - Creation
 */

#define REPLACE_SURFACE   2

IGRlong EFreplace_sfs(EMmsg,
                    num_surfs,
                    loc_info,
                    init_opts,
                    construct_list, 
                    cons_id,
                    gen_opts)

IGRlong 	*EMmsg;
IGRushort init_opts;
IGRint          num_surfs; 
struct 		GRlc_info *loc_info; 
struct GRid  *cons_id;
struct 		GRvg_construct *construct_list; /* Construction information */
IGRushort gen_opts;
{
	IGRlong sts;
    	IGRlong   msg_loc;
	IGRint 	ii, inx,  num_parents, index = 0;
	struct 	GRid 	active_id;
	IGRshort 	mattyp;
	GRspacenum 	constros;
	IGRint	recomp_type;
        struct EMSadd_draft *replace_sfs_info;
        struct EMSobject_info *list_ptr;
        extern OMuword OPP_EMSsladdraft_class_id;
         

     /* OM_S_CHANSELECT OM_S_OBJECT_LINKAGE OM_S_OBJID  */

	*EMmsg = EMS_S_Success;
	sts = OM_S_SUCCESS;

	constros = construct_list->env_info->md_id.osnum;

        num_parents = num_surfs *2;
        num_parents++;
/*
        replace_sfs_info = (struct EMSadd_draft *) om$malloc(size = sizeof
                        (struct EMSadd_draft));
        EMerr_hndlr(!replace_sfs_info , *EMmsg, EMS_E_NoDynamicMemory, wrapup);

        replace_sfs_info->num_drafts = num_surfs;
        replace_sfs_info->type = REPLACE_SURFACE;
*/
        recomp_type =  REPLACE_SURFACE;

	list_ptr = (struct EMSobject_info *) om$malloc(size = num_parents *
		sizeof(struct EMSobject_info));
	EMerr_hndlr(!list_ptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

        
	/* assign memory for recomputation */

       /* STORE  PARENT INFORMATION **************************/

       index=0;

       /* surfaces to be replaced ********************************/
       /* ref edged or surfaces **********************************/
          for(ii=0; ii<(2*num_surfs); ii+=2)
           {
            list_ptr[index].grid = loc_info[ii].located_obj;
            list_ptr[index].env = loc_info[ii].module_info;
            index++;
            }
          for(ii=1; ii<(2*num_surfs); ii+=2)
            {
	    list_ptr[index].grid = loc_info[ii].located_obj;
	    list_ptr[index].env = loc_info[ii].module_info;
            index++;
            }
          
     
	sts = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
    			&active_id, NULL),
    		senderid = NULL_OBJID,
    		targetid = loc_info[0].located_obj.objid,
    		targetos = loc_info[0].located_obj.osnum);
	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

        list_ptr[index].grid = active_id;
        list_ptr[index].env = loc_info[ii].module_info;
        index++;


	/* This function  constructs the associative feature add draft */

	sts = om$construct(classid = OPP_EMSsladdraft_class_id,
	              osnum = active_id.osnum, 
	    		p_objid = &cons_id->objid);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

 	cons_id->osnum = active_id.osnum;

        {
          extern OM_S_OBJID current_creator;
          IGRushort temp_opts;
	  current_creator = cons_id->objid;

          temp_opts = EMSasconst_no_autodimension;
  	  sts = om$send (msg = message EMSassoc.EMinit_associative(EMmsg,
	    			temp_opts, 
				num_parents, 
				list_ptr, 
				recomp_type, 
                                0,
                                NULL,
				construct_list),
	    		senderid = NULL_OBJID,
	    		targetid = cons_id->objid,
	    		targetos = cons_id->osnum);
	  current_creator = NULL_OBJID;
        }
	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	/* If non-associative placement disconnect the parents */
   
        /* 
           Bimbo's act.  move_to_root was being called wrt the active id
           of the surface to be replaced - Vadi - 22/7/94
        */

	if(gen_opts & EMSasconst_notassociative) {
		sts = om$send(msg = message NDnode.NDmove_to_root(EMmsg, 
				cons_id, &loc_info[0].module_info),
			senderid = NULL_OBJID,
			targetid = cons_id->objid,
			targetos = cons_id->osnum);

		EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
          }
wrapup:

        if(list_ptr)
          om$dealloc(ptr = list_ptr);

	EMWRAPUP(*EMmsg, sts, "EFreplace_surface"); 
	return (sts);

}

end implementation EMSsfaddraft;

