class implementation EMSsfdpr;

#include "EMS.h"
#include "ndmacros.h"
#include "nddef.h"
#include "asbox.h"

method NDconnect(IGRint nb_root; 
                 struct GRid *root; 
                 struct GRid original;
		 IGRint type)

/* **************************************************************

Description
 This method will connect the parents on my father channel. If a
 particular parent is on my components channel then the same is not
 connected on the parents channel. This is done to keep the
 associative and the ownership protocol seperate from each
 other.

Arguments
 nb_root : I : number of parents.
 root    : I : parents
 original: I : If connection is after a copoy, GRid of the original 
               object. NULL_GRid else.
 type    : I : type of the connection
	       ND_NEW       : first connection of the element 
	       ND_FULL      : full redefinition of connection 
	       ND_ADD       : add a parent to the existing ones
History
 Creation : PP : 05/02/91

  ************************************************************** */
{
 IGRboolean connect;
 IGRint i,comp_count;
 IGRlong status;
 IGRlong EMmsg;
 OM_S_OBJID *component_parents = NULL;
 struct GRid my_grid;
 OM_S_CHANSELECT father, children, to_components;
 
 status = OM_S_SUCCESS;
 EMmsg = EMS_S_Success;

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 status = om$make_chanselect(channame = "NDfather.father",
                             p_chanselect = &father);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect(channame = "NDchildren.children",
                             p_chanselect = &children);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 status = om$make_chanselect(channame = "GRcmpowner.to_components",
                             p_chanselect = &to_components);
 EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

 switch(type)
  {
   case ND_FULL :
   status = om$send (msg = message NDnode.NDnotify_disconnect(my_grid),
                     p_chanselect = &father);
   EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);

   status = om$send(msg = message Root.wild_disconnect(father),
		    targetid = my_id);
   EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
	
/*
 * Establish new connection.
 */

   case ND_NEW  :
   case ND_ADD  :
    {
     if (original.objid != NULL_OBJID)
     {
       comp_count = 0;
  
       /*
        * Get the component parent count of the original object. The 
        * component parent count of myself should exactly be the same
        * as that of the original object and the parents should be at
        * the end of the root list.
        */
       status = om$send (msg = message EMSsfdpr.EMget_component_parents(
                                &EMmsg, NULL, 0, &comp_count,
                                NULL),
                          targetid = original.objid,
                          targetos = original.osnum);
       EMerr_hndlr(!(1&status&EMmsg), EMmsg, EMS_E_Fail, wrapup);

       for (i=nb_root-comp_count;i<nb_root;i++)
       {
         status = om$send(msg = message GRconnector.GRrigidconn (&EMmsg,
	         	         &my_grid, (IGRlong *)&i),
                          targetid = root[i].objid,
                          targetos = root[i].osnum);
         EMerr_hndlr(!(1&status&EMmsg),EMmsg,EMS_E_Fail, wrapup);
       }
     }

     for(i=0;i<nb_root;i++)
     {
/*
 * Connect the same on my father channel only if it is not already on
 * my to components channel.
 */
       status = om$is_objid_on_channel (objid_c = my_id,
                                        p_chanselect = &to_components,
                                        objid = root[i].objid,
                                        osnum2 = root[i].osnum);
       if (status != OM_S_SUCCESS)
       {
        status = OM_S_SUCCESS;

         status = om$send(msg = message Root.connect (children,OM_K_MAXINT,
	             	      my_id, OM_Gw_current_OS,
                              father,OM_K_MAXINT),
			targetid = root[i].objid,
			targetos = root[i].osnum);	
         EMerr_hndlr (!(1&status), EMmsg, EMS_E_OMerror, wrapup);
       }
     }

     for(i=0;i<nb_root;i++)
      {
         status = om$send(msg = message NDnode.NDnotify_connect(my_grid),
         	 targetid = root[i].objid,
	         targetos = root[i].osnum);	
         EMerr_hndlr (!(1&status), EMmsg, EMS_E_ASerror, wrapup);
      }
    }
       break;

    default : 
    {
     EMmsg = EMS_E_InvalidArg;
     goto wrapup;
    }
   }

/* clear stored graph */

wrapup:
 if (component_parents) om$dealloc (ptr = component_parents);
 EMWRAPUP (EMmsg, status, "In EMSsfdpr: NDconnect error");
 return(status);
}
/*
        if (original != NULL_GRID)
        {
         IGRboolean found = FALSE;
         GRobjid found_id;
         for (j=0;j<comp_count;j++)
         {
           if (root[i].objid == component_parents[j])
           {
            found_id = component_parents[j];
            found = TRUE;
            break;
           }
         }
         if (found)
         {
          IGRint indx = MAXINT;
          connect = FALSE;
           
          status = om$send(msg = message GRconnector.GRrigidconn (&EMmsg,
			         &my_grid, &indx),
                           targetid = found_id);
          EMerr_hndlr(!(1&status&EMmsg),EMmsg,EMS_E_Fail, wrapup);
         }
        }
*/

/*
       for (j=0;j<comp_count;j++)
        {
          struct GRid old_grid,clone_grid;

          old_grid.objid = component_parents[j];
          old_grid.osnum = original.osnum;
          clone_grid.objid = NULL_OBJID;
          nd$get_clone(nb_obj = 1, p_original = &old_grid, 
                       p_clone = &clone_grid);
          component_parents[j] = clone_grid.objid;
        }
*/
end implementation EMSsfdpr;

