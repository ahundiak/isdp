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

#define SURFACES_AND_EDGES_OR_CRVS_OR_SURFS 0
#define SURFACES_AND_SURFACE 1

IGRlong EFadd_draft(EMmsg,
                    num_drafts,
                    is_reversed,
                    draft_angle,
                    draft_angle_rev,
                    add_draft_type,
                    loc_info,
                    init_opts,
                    construct_list, 
                    cons_id,
                    gen_opts)

IGRlong 	*EMmsg;
IGRushort init_opts;
IGRint          num_drafts, add_draft_type;
IGRboolean      is_reversed;
struct  GRevent *draft_angle, *draft_angle_rev; 
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
	IGRlong EMgetparval_object();
	IGRint	recomp_type;
        struct EMSadd_draft *addraft_info;
        struct EMSvalue_info angle, angle_rev;
        struct EMSobject_info *list_ptr;
        extern OMuword OPP_EMSsladdraft_class_id;
         

     /* OM_S_CHANSELECT OM_S_OBJECT_LINKAGE OM_S_OBJID  */

	*EMmsg = EMS_S_Success;
	sts = OM_S_SUCCESS;

	constros = construct_list->env_info->md_id.osnum;

        if(add_draft_type == SURFACES_AND_EDGES_OR_CRVS_OR_SURFS)
          num_parents = num_drafts *2;
        else if(add_draft_type == SURFACES_AND_SURFACE)
          num_parents = num_drafts +1;

        num_parents++;   /** angle ***/
        num_parents++;   /** angle reverse ***/
        num_parents++;   /** active state parent ***/

	list_ptr = (struct EMSobject_info *) om$malloc(size = num_parents *
		sizeof(struct EMSobject_info));
	EMerr_hndlr(!list_ptr, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

	/* assign memory for recomputation */

	addraft_info = (struct EMSadd_draft *) om$malloc(size = sizeof 
			(struct EMSadd_draft));
	EMerr_hndlr(!addraft_info, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

        addraft_info->num_views = 0;

/*
        addraft_info->num_drafts = num_drafts;
        addraft_info->type = add_draft_type;
*/
        recomp_type = add_draft_type;

       /* STORE  PARENT INFORMATION **************************/

       index=0;

       /* surfaces to be drafted ********************************/
       /* ref edged or surfaces **********************************/

        if(add_draft_type == SURFACES_AND_EDGES_OR_CRVS_OR_SURFS)
          {
          for(ii=0; ii<(2*num_drafts); ii+=2)
           {
            list_ptr[index].grid = loc_info[ii].located_obj;
            list_ptr[index].env = loc_info[ii].module_info;
            index++;
            }
          for(ii=1; ii<(2*num_drafts); ii+=2)
            {
	    list_ptr[index].grid = loc_info[ii].located_obj;
	    list_ptr[index].env = loc_info[ii].module_info;
            index++;
            }
          }
        else
          {
          for(ii=1; ii<=num_drafts; ii++)
           {
            list_ptr[index].grid = loc_info[ii].located_obj;
            list_ptr[index].env = loc_info[ii].module_info;
            index++;
           }
	  list_ptr[index].grid = loc_info[0].located_obj;
	  list_ptr[index].env = loc_info[0].module_info;
          index++;
          }
          
       /* draft angle *******************************************/
	    angle.type = EMSdatainfo_event;
	    angle.valevent = draft_angle;
	    sts = EMgetparval_object(EMmsg, constros, NULL,
		&angle, &list_ptr[index]);
	    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
            index++;

       /* angle reverse flag *******************************************/
	    angle_rev.type = EMSdatainfo_event;
	    angle_rev.valevent = draft_angle_rev;
	    sts = EMgetparval_object(EMmsg, constros, NULL,
		&angle_rev, &list_ptr[index]);
	    EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg,EMS_E_Fail,wrapup);
            index++;
          

        if(add_draft_type == SURFACES_AND_EDGES_OR_CRVS_OR_SURFS)
          {
          sts = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                        &active_id, NULL),
                senderid = NULL_OBJID,
                targetid = loc_info[0].located_obj.objid,
                targetos = loc_info[0].located_obj.osnum);
          EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
          }
        else
          {
          sts = om$send(msg = message EMSsurface.EMgetactiveid(EMmsg,
                        &active_id, NULL),
                senderid = NULL_OBJID,
                targetid = loc_info[1].located_obj.objid,
                targetos = loc_info[1].located_obj.osnum);
          EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
          }

	  list_ptr[index].grid = active_id;
	  list_ptr[index].env = loc_info[0].module_info;
          index++;

	/* This function  constructs the associative feature add draft */

	sts = om$construct(classid = OPP_EMSsladdraft_class_id,
	              osnum = active_id.osnum, 
	    		p_objid = &cons_id->objid);
	EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);
        cons_id->osnum = loc_info[0].located_obj.osnum;

 	cons_id->osnum = active_id.osnum;
        {
          extern OM_S_OBJID current_creator;
	  current_creator = cons_id->objid;

          /* If the gen_opts is non-associative, don't auto dimension */
          if(gen_opts & EMSasconst_notassociative)
                init_opts |= EMSasconst_noautodimension;


  	  sts = om$send (msg = message EMSassoc.EMinit_associative(EMmsg,
	    			init_opts, 
				num_parents, 
				list_ptr, 
				recomp_type, 
				sizeof(struct EMSadd_draft),
				(IGRchar *) addraft_info,
				construct_list),
	    		senderid = NULL_OBJID,
	    		targetid = cons_id->objid,
	    		targetos = cons_id->osnum);
	  current_creator = NULL_OBJID;
        }
	EMerr_hndlr(!(1&sts&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

	/* If non-associative placement disconnect the parents */

        /* 
           Yet another Bimbo's act!  The same mistake of calling
           move_to_root wrt the active-id of the surface to be drafted.
           - Vadi - 22/7/94.
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

	EMWRAPUP(*EMmsg, sts, "EFadd_draft"); 
	return (sts);

}

end implementation EMSsfaddraft;

