class implementation SKconstraint;

#include "EMS.h"
#include <stdio.h>
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "gocmacros.h"
#include "nd.h" /* For NDcp_list */
#include "nddef.h" /* For ND_ADD */
#include "EMcp.h"
#include "parametric.h"
#include "EMSasnucdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "exmacros.h"

from SKvariable import SKintcopy;
from NDnode import NDconnect, NDgive_structure;
from SKexplicit import SKmanage_expression_vla;
from SKexplicit import SKstoreval,SKgetname;

extern OMuword OPP_SKimplicit_class_id,OPP_SKvariable_class_id;
extern OMuword OPP_NDnodein_class_id;
extern OMuword OPP_SKradial_class_id,
               OPP_SKrelang_class_id, OPP_SKfixang_class_id,
               OPP_SKptpt_class_id;

/*

Name
  SKintcopy

Abstract

Synopsis

Description
  SKintcopy
Return Value

Notes

Index

Keywords
  copy,profile

History
  ??/??/?? : ????? : created
  12/02/93 : G M K : TR # 119312042 : I will create dim. names for copied objects
                     only if the original objects have the dim. names. 
*/

method SKintcopy(
	IGRlong 	  *msg; 	
        IGRushort options;
	struct GRmd_env   *obj_mdenv;
	struct GRmd_env   *new_mdenv;
	GRobjid 	  *newobjid;
	struct EMcp_info  *copy_info)

		
{
   IGRboolean            cns_copy_exists;
   IGRshort              props, clear_bits;
   IGRlong               i, OM_stat;
   IGRlong               mthd_stat;
   GRobjid               ptid,dum_obj, handle_cp;
   OMuword               dum_classid,dumos, my_classid, clone_classid;
   struct GRid           cnscp_GRid, my_grid;
   IGRuint               count;
   IGRint                cpinx = 0;
   OM_S_CHANSELECT       to_variables, to_cmpnts_chan;
   struct NDcp_list      *nd_cp_ptr = NULL;
   IGRboolean            is_associative = TRUE;
   void                  EMcpsearch ();
   void                  EMget_clone_pos();

   /* ************************************************************** */

   *msg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   my_grid.objid = my_id;
   my_grid.osnum = OM_Gw_current_OS;

   /*
    * find out if I have been already copied or not.
    * If so, return my counter part's objid and I am all done
    */
	
   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
               &cns_copy_exists);
   EMerr_hndlr(!(1&mthd_stat), *msg, EMS_E_Fail, wrapup);
   if (cns_copy_exists) goto wrapup;

   OM_stat = om$make_chanselect (channame = "GRcmpowner.to_components",
                                 p_chanselect = &to_cmpnts_chan);
   EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

   OM_stat = om$get_classid (object = me,
                             p_classid = &my_classid);
   if (!(1&OM_stat)) goto wrapup;

   cnscp_GRid.objid = NULL_OBJID;
   cnscp_GRid.osnum = new_mdenv->md_id.osnum;
/*
 * The constraint is assumed to be a part of the associative graph if the
 * same has an (invisible handle/has a rigid component) and is a subclass of
 * NDnodein.
 */ 

   if (options & SK_OPT_COPY_ASSOCIATIVE)
   {
    if (me->props & SK_INVISIBLEHNDL)
    {
    }
    else
    {
     count = 0;
     om$get_channel_count (object = me, p_chanselect = &to_cmpnts_chan,
      count = &count);
     if (!count) is_associative = FALSE;
    }

    if (is_associative)
     {
      if (!(EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                        OPP_NDnodein_class_id, FALSE)))
       is_associative = FALSE;
     }
   }
   else
    is_associative = FALSE;

   if (is_associative)
   {
/*
 * Check to see if my clone exists with the list maintained by the graph
 * manager. This would happen when a copy takes place from a macro
 * definition or during copy/move.
 */

     EMget_clone_pos(&mthd_stat,NULL,&my_grid, copy_info, &cpinx, 
                     &cnscp_GRid.objid);
     EMerr_hndlr(!(1&mthd_stat), *msg, EMS_E_InvalidArg, wrapup);
/*
 * We cannot allow the clone id to be the same as my id. This usually
 * happens when the dimensional constraint is an external element of
 * a graph and the copy is taking place withing the same object space.
 * AG does this to reuse/conserve objects.
 */

     if ((cnscp_GRid.objid == my_id) && (OM_Gw_current_OS == 
          new_mdenv->md_id.osnum))
      cnscp_GRid.objid = NULL_OBJID;

     nd_cp_ptr = copy_info->graph_info.graph_array;
/*
 * If my clone already exists and it is not the same class as me, then
 * construct and copy me and connect the same to the clone on the parent
 * child channel and replace myself in the graph array maintained by
 * the associative subsystem.
 */
     
     if (cnscp_GRid.objid != NULL_OBJID)
     {
      OM_stat = om$get_classid (objid = cnscp_GRid.objid,
                                osnum = cnscp_GRid.osnum, 
                                p_classid = &clone_classid);
      if (!(1&OM_stat)) goto wrapup;

      if (clone_classid != my_classid)
      {
       IGRint cl_size;
       struct GRid old_clone_GRid;
       struct ret_struct info_struct;

       old_clone_GRid.objid = nd_cp_ptr[cpinx].clone;
       old_clone_GRid.osnum = new_mdenv->md_id.osnum;

       OM_stat = om$construct_and_copy(object = me, 
   	             osnum = new_mdenv->md_id.osnum, p_objid = newobjid);
       EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_Fail, wrapup);

       OM_stat = om$send (msg = message NDnode.NDconnect(1,&old_clone_GRid,
                                my_grid,ND_ADD),
                          targetid = *newobjid,
                          targetos = new_mdenv->md_id.osnum);
       EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_Fail, wrapup);

       if (EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                        OPP_SKexplicit_class_id, FALSE))
       {
        cl_size = 3;

        OM_stat = om$send (msg = message SKexplicit.SKmanage_expression_vla(
                                msg,0x1,&cl_size,"\\0"),
                          targetid = *newobjid,
                          targetos = new_mdenv->md_id.osnum);
        EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_Fail, wrapup);
       }
/*
 * If the completion code and the return status is good then
 * update the value in the copied instance data. If not just
 * continue. The latter scenario is more likely to occur when
 * the copy is taking place for the purposes of creating a
 * macro definition.
 */

       OM_stat = om$send (msg = message NDnode.NDgive_structure(msg,
                                &info_struct, new_mdenv),
                          targetid = old_clone_GRid.objid,
                          targetos = old_clone_GRid.osnum);
       if (1&OM_stat&*msg)
       {
        if (info_struct.type & parameter_generic)
        {
          OM_stat = om$send (msg = message SKexplicit.SKstoreval(msg,
                                 info_struct.var.root_pm_st.value),
                            targetid = *newobjid,
                          targetos = new_mdenv->md_id.osnum);
          EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_Fail, wrapup);
        }
       }
       else 
       {
        OM_stat = OM_S_SUCCESS;
        *msg = EMS_S_Success;
       }


        nd_cp_ptr[cpinx].clone = *newobjid;
        cnscp_GRid.objid = *newobjid;
        cnscp_GRid.osnum = new_mdenv->md_id.osnum;
      }
     }
   }

   if (cnscp_GRid.objid == NULL_OBJID)
   {
    OM_stat = om$construct_and_copy(object = me, 
	      osnum = new_mdenv->md_id.osnum, p_objid = newobjid);
    EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_Fail, wrapup);

    cnscp_GRid.objid = *newobjid;
    cnscp_GRid.osnum = new_mdenv->md_id.osnum;
/*
 * Update the list maintained by the associative graph system.
 */

    if (is_associative)
     nd_cp_ptr[cpinx].clone = *newobjid;
   }
   else
    *newobjid = cnscp_GRid.objid;

   /*
    * put my_id and my counter part's id in the copy_info
    */

    EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
               &cns_copy_exists);
    EMerr_hndlr(!(1&mthd_stat), *msg, EMS_E_Fail, wrapup);

    if (EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                        OPP_SKexplicit_class_id, FALSE))
    {
        IGRlong msg_loc;
        IGRint type;
        IGRchar newname[DI_PATH_MAX],myname[DI_PATH_MAX];

        if (EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                              OPP_SKradial_class_id, FALSE))
         type = EMSraddist;
        else if (EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                              OPP_SKrelang_class_id, FALSE) ||
                (EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                              OPP_SKfixang_class_id, FALSE)))
         type = EMSangle;
        else
         type = EMSdistance;
        
        /*
         * get dim name of my_id, If it is null, don't create dim name for
         * copied object.
         * TR # 119312042   GMK 12/02/93
         */ 
        myname[0] = NULL;   
        om$send (msg = message SKexplicit.SKgetname (&msg_loc, NULL,myname),
       	        targetid = my_id);
        if ( myname[0] != '\0' )
        {        
          EMdefnewname(newname, new_mdenv->md_id.osnum, type);

          if (newname[0] != '\0')
          {
            IGRlong l_msg;
            IGRchar temp_name[DI_PATH_MAX];
            struct GRid cur_mod;

/*
 * If the expression is being created in the master file then we try
 * to create the same in the current directory. Else if it is in a
 * different object space, then we try to create the same in the
 * default directory of that object space.
 */

            cur_mod.osnum = 0;
            ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);

            temp_name[0] = '\0';
            if (cur_mod.osnum != new_mdenv->md_id.osnum)
            {
              di$give_pathname(osnum = new_mdenv->md_id.osnum, 
                               pathname = temp_name);

              strcat(temp_name, ":");
              strcat(temp_name, newname);
            }
            else
             strcpy(temp_name, newname);

            om$send (msg = message GRgraphics.GRputname(&l_msg,
                          temp_name),
                  targetid = *newobjid,
                  targetos = new_mdenv->md_id.osnum);
          }
       }   
     }


    OM_stat = om$make_chanselect(channame = "SKconstraint.to_variables",
                                 p_chanselect = &to_variables);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*msg,EMS_E_Fail, wrapup);

    OM_stat = om$get_channel_count(object = me, 
                  p_chanselect = &to_variables, count = &count);
    EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

   for (i=0;i<count;i++)
   {
    OM_stat = om$get_objid_at_index(objid = my_id,
                                    p_chanselect = &to_variables,
                                    objidaddr = &dum_obj,
                                    osnumaddr = &dumos,
                                    index = i);
    EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

    OM_stat = om$get_classid (objid = dum_obj,
                          p_classid = &dum_classid);
    EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

    OM_stat = om$is_ancestry_valid(subclassid = dum_classid,
                               superclassid = OPP_SKvariable_class_id);
    if (OM_stat == OM_S_SUCCESS)
    {
     OM_stat = om$send(msg = message SKvariable.SKintcopy
                  (&mthd_stat, options, obj_mdenv, new_mdenv, 
                   &ptid, copy_info), 
                   targetid = dum_obj);
     EMerr_hndlr(!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);
    }
    else if (OM_stat == OM_I_INVANCESTRY)
    {
     OM_stat = om$send(msg = message SKconstraint.SKintcopy
                  (&mthd_stat, options, obj_mdenv, new_mdenv, 
                    &ptid, copy_info), 
                    targetid = dum_obj);
     EMerr_hndlr(!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);
    }
    EMerr_hndlr(!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

    OM_stat = om$send (msg = message SKconstraint.SKconnect_to_pt(&mthd_stat,
                          ptid,NULL,
                          OM_K_MAXINT,i),
                    targetid = cnscp_GRid.objid,
                    targetos = cnscp_GRid.osnum);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);
   }

 /*
  * Copy my graphic handles, if requested by the caller
  */


 if (!(options & SK_OPT_NO_COPY_HANDLE))
 {
   /*
    * For now, only the implicit handles are copied as copy process of the 
    * dimensions are not clear.
    */

   OM_stat = om$is_ancestry_valid (subclassid = my_classid,
                                   superclassid = OPP_SKimplicit_class_id);
   EMerr_hndlr (!(1&OM_stat), *msg, EMS_E_OMerror, wrapup);

   if (OM_stat == OM_S_SUCCESS)
   {
     IGRuint comp_count;

     OM_stat = om$get_channel_count(object = me,
                                    count = &comp_count,
                                    p_chanselect = &to_cmpnts_chan);
     EMerr_hndlr (!(1&OM_stat&mthd_stat), *msg, EMS_E_OMerror, wrapup);
 
     for (i=0;i<comp_count;i++) 
     {
      OM_stat = om$send (msg = message GRgraphics.GRcopy (&mthd_stat, obj_mdenv,
                               new_mdenv, &handle_cp),
		         from = (int) i, to = (int) i,
                         p_chanselect = &to_cmpnts_chan);
      EMerr_hndlr (!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);
/*
 * Made modification so that all the components get copied.
 * and get connected.
 * pp 01/03/92
 */ 
      if (OM_stat == OM_S_SUCCESS)
      {
       clear_bits = 0;
       props = GR_RIGID_RELATIONSHIP;
       OM_stat = om$send (msg = message GRvg.GRchgprops (&mthd_stat, 
                                &clear_bits, &props),
                          targetid = handle_cp, 
                          targetos = new_mdenv->md_id.osnum);
       EMerr_hndlr (!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);

       OM_stat = om$send (msg = message GRconnector.GRrigidconn (&mthd_stat,
                                &cnscp_GRid, &i),
                          targetid = handle_cp,
                          targetos = new_mdenv->md_id.osnum);
       EMerr_hndlr (!(1&OM_stat&mthd_stat), *msg, EMS_E_Fail, wrapup);
      }
    }
  } /* if (OM_stat == OM_S_SUCCESS) */
 } /* if (!(options & SK_OPT_NO_COPY_HANDLE)) */
  
  
wrapup:

     EMWRAPUP (*msg, OM_stat, "SKconstraint.EMintcopy");
     return(OM_stat);
}

end implementation SKconstraint;
