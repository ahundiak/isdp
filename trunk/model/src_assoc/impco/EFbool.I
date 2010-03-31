/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsfboolean;

/*
 * This function creates the associative boolean object.
 *
 *  
 SM     10/31/92    KLUDGE KLUDGE KLUDGE -
                    Multiple booleans are now done one at a time with a macro
                    object being at the top. This causes multiple displays
                    and a light show on the screen. The way to avoid it is
                    by supressing redraw in EMboolean and doing it at the
                    end. Since there is no suitable argument to get
                    back the display ids, the character pointers 'geometry'
                    and 'class_attr' in the structure GRvg_construct are
                    being used to return 'display_ids'
                    and 'display_count'. ALL THIS APPLIES ONLY DURING INITIAL
                    CONSTRUCTION. Please see src_assoc/imp/EAsfbcons.I for
                    related changes.
 *  DLB     7/02/91     Was passing wrong ptr to move_to_root.
 *  DLB     7/02/91     Issue a transform_to_assoc to those incoming elements
 *                      which are not associative.
 *  DLB     5/18/91     Use different opt than no_const_assoc for non-assoc.
 *  DLB     3/19/91     Creation.
 */
#include "EMSas.h"
#include "bserr.h"
#include "bsparameters.h"
#include "OMmacros.h"
#include "dp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

extern OM_S_OBJID current_creator;
extern OMuword OPP_EMSslmacro_class_id, OPP_EMSsfmacro_class_id;

from EMSsfmacro import EMcreate_yourself;

IGRlong EFboolean(EMmsg, options, num_opnds, opnd_info, bool_type,
                  construct_list, res_id)                     
IGRlong               *EMmsg;
IGRushort     options;         /* Ubiquitous options field */
IGRint                num_opnds;       /* Number of operands*/
GRobjid               *opnd_info;      /* operands*/
enum EMSbooltype      bool_type;       /* Obvious isn't it?*/
struct GRvg_construct *construct_list; /* Construction information */
struct GRid           *res_id;         /* Resultant id */
{
 IGRlong               OM_stat=OM_S_SUCCESS;
 IGRint                ii, num_states = 0;
 struct EMSobject_info *list_ptr=NULL;
 IGRboolean            all_solids=TRUE, EFisAncestryValid(), is_assoc;
 extern OMuword        OPP_EMSsfboolean_class_id, OPP_EMSslboolean_class_id,
                       OPP_EMSsolid_class_id;
 IGRboolean            action = TRUE;
 IGRushort              mask = EMS_MACRO_STATE;
 IGRushort              mask1 = EMS_POST310_OBJECT;
 OM_S_OBJID            macro_id;
 GRobjid               *display_ids = NULL;
 IGRint                display_count = 0;

 *EMmsg = EMS_S_Success;

 res_id->osnum = construct_list->env_info->md_id.osnum;

 list_ptr = (struct EMSobject_info *) stackalloc
            (sizeof(struct EMSobject_info) * num_opnds);
 if (!list_ptr) {*EMmsg = EMS_E_NoStackMemory; goto wrapup;}

   OM_BLOCK_MOVE(construct_list->env_info,
                 &list_ptr[0].env, sizeof(struct GRmd_env));

   list_ptr[0].grid.objid = opnd_info[0];
   list_ptr[0].grid.osnum = res_id->osnum;

 num_states = num_opnds - 1; 

 if(num_states > 1)
  {
   construct_list->geometry = (IGRchar *) &display_ids;
   construct_list->class_attr = (IGRchar *) &display_count;
  }

 for(ii=0; ii<num_opnds; ii++)
 {
 if (!EFisAncestryValid(EMmsg, opnd_info[ii], res_id->osnum,
                         OPP_EMSsolid_class_id, FALSE)) 
                {
                all_solids = FALSE;
                break;
                }
 }

 for(ii=1; ii<num_opnds; ii++)
 {
   OM_BLOCK_MOVE(construct_list->env_info,
                 &list_ptr[1].env, sizeof(struct GRmd_env));

   list_ptr[1].grid.objid = opnd_info[ii];
   list_ptr[1].grid.osnum = res_id->osnum;

   OM_stat = om$send(msg = message EMSsurface.EMis_associative(EMmsg,
                           &is_assoc),
                     senderid = NULL_OBJID,
                     targetid = opnd_info[ii],
                     targetos = res_id->osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   if (!is_assoc)
   {
     OM_stat = om$send(msg = message EMSsurface.EMtransform_to_associative
                             (EMmsg, &opnd_info[ii]),
                       senderid = NULL_OBJID,
                       targetid = opnd_info[ii],
                       targetos = res_id->osnum);
     if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }

 OM_stat = om$construct(classid = all_solids ? OPP_EMSslboolean_class_id:
                                               OPP_EMSsfboolean_class_id,
                        osnum = res_id->osnum,
                        p_objid = &res_id->objid);
 if (!(1 & OM_stat)) goto wrapup;

 current_creator = res_id->objid;

 /*This function initializes and constructs the associative boolean object*/
 OM_stat = om$send(msg = message EMSassoc.EMinit_associative(EMmsg,
                         NULL,
                         2,
                         list_ptr,
                         (IGRint) bool_type,
                         0, 
                         (IGRchar *) NULL,
                         construct_list),
                   senderid = NULL_OBJID,
                   targetid = res_id->objid,
                   targetos = res_id->osnum);
 current_creator = NULL_OBJID;
 if (!(1 & OM_stat & *EMmsg)) goto wrapup;

   list_ptr[0].grid.objid = res_id->objid;
   list_ptr[0].grid.osnum = res_id->osnum;

  /*
   * Mark the object as a post 310 object
   */
  OM_stat = om$send (msg = message EMSdpr.EMsetprops (EMmsg,
                               &action, &mask1),
                        senderid = NULL_OBJID,
                        targetid = res_id->objid,
                        targetos = res_id->osnum);
  if (!(1&OM_stat&*EMmsg)) goto wrapup;

  if(num_states > 1)
   {
    OM_stat = om$send(msg = message EMSdpr.EMsetprops(EMmsg,
				&action, &mask),
		 	senderid = NULL_OBJID,
			targetid = res_id->objid,
			targetos = res_id->osnum);
    if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }

  if (options & EFfunc_PLACE_NON_ASSOC)
  {
   IGRlong loc_sts=OM_S_SUCCESS;
   loc_sts = om$send(msg = message NDnode.NDmove_to_root(EMmsg, res_id,
                           construct_list->env_info),
                     senderid = NULL_OBJID,
                     targetid = res_id->objid,
                     targetos = res_id->osnum);
   if (!(1 & OM_stat & *EMmsg)) goto wrapup;
   }
 }/*** BIG LOOP END **/



     if(num_states > 1)
      {
       OM_stat = om$construct (classid = all_solids ? OPP_EMSslmacro_class_id
                                                    : OPP_EMSsfmacro_class_id, 
		      msg = message EMSsfmacro.EMcreate_yourself(
			EMmsg, res_id->objid, num_states, 
                        construct_list->env_info),
                      p_objid = &macro_id,
                      osnum = construct_list->env_info->md_id.osnum);
       if (!(1 & OM_stat & *EMmsg)) goto wrapup;
        res_id->objid = macro_id;

       /*
        * Mark the object as post 310 object
        */
       OM_stat = om$send (msg = message EMSdpr.EMsetprops (EMmsg, &action, 
                                     &mask1),
                        senderid = NULL_OBJID,
                        targetid = res_id->objid,
                        targetos = res_id->osnum);
       if (!(1&OM_stat&*EMmsg)) goto wrapup;

       /** SM 10/31/92 Redraw the affected surfaces.
       ****/
       if(display_ids && display_count)
        {
	 IGRint i;
	 enum GRdpmode dismode = GRbd;
         IGRint env_size=sizeof(struct GRmd_env), nret;	
         struct GRmd_env display_env;

         gr$get_display_env(msg = EMmsg,
                         sizbuf = &env_size,
                         buffer = &display_env,
                         nret = &nret);
         if (!(1 & *EMmsg)) goto wrapup;
	 for(i=0; i<display_count; i++)
	   OM_stat = om$send(msg = message GRgraphics.GRdisplay(EMmsg, 
	             &display_env.md_env.matrix_type, 
	             display_env.md_env.matrix, &dismode, &display_env.md_id), 
                     targetid = display_ids[i], 
	             targetos = res_id->osnum, senderid = NULL_OBJID);
        }
      }
        
wrapup:
 if(num_states > 1)
  {
   construct_list->geometry = NULL;
   construct_list->class_attr = NULL;
   if(display_ids) om$dealloc(ptr = display_ids);
  }

 current_creator = NULL_OBJID;
 if (list_ptr) stackfree (list_ptr); /*FREE FIRST ONLY!!!!*/
 EMWRAPUP(*EMmsg, OM_stat, "EFboolean")
 return (OM_stat);
}
end implementation EMSsfboolean;

