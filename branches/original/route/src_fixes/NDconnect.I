/* 
 * 09/05/96 ah TR179424043
 * Add an unconsume routine to NDconnect
 * for certain vds macros
 *
 * Started by copying NDconnect from vdassoc/NDchannel.I
 * and added a call to the new NDconnect_unconsume
*/

class implementation NDnodein;

#include "AS_status.h"
#include "nddef.h"
#include "godef.h"
#include "ndmacros.h"

from ACcpx      import  find_macro ;
from ACcpx_defn import  ACgive_name ;
 
int NDconnect_unconsume(
  struct GRid *my_grid, 
  struct GRid *clone_grid,
  IGRint nb_root,
  struct GRid *root_grid
)
{
  IGRlong status,msg;

         GRclassid my_obj_class;
  extern GRclassid OPP_nci_macro_class_id;

  IGRint nb_old,i,j,found;
  struct GRid *old_grid = 0;
/*
  IGRlong consume;
*/
  struct GRid defn_grid;
  char   *mac_name;

  /* Only interested in nci_macros */
  status = om$get_classid(objid = my_grid->objid,
			  osnum = my_grid->osnum,
			  p_classid = &my_obj_class);

  if(om$is_ancestry_valid(
    subclassid   = my_obj_class,
    superclassid = OPP_nci_macro_class_id) != OM_S_SUCCESS) {
    return 1;
  }

  status = om$send(msg = message ACcpx.find_macro(&defn_grid),
                       senderid = NULL_OBJID,
                       targetid = my_grid->objid,
                       targetos = my_grid->osnum);

  status = om$send(msg = message ACcpx_defn.ACgive_name(&mac_name),
                       senderid = NULL_OBJID,
                       targetid = defn_grid.objid,
                       targetos = defn_grid.osnum);

  if ((strcmp(mac_name,"srf_comp")) &&
      (strcmp(mac_name,"srf_merge"))) {
    return 1;
  }
/*
  printf("Unconsuming Parents of %u,%s\n",my_grid->objid,mac_name);
  return 1;
*/

  /* Get list of old parents */
  old_grid = (struct GRid *) om$malloc (size = sizeof(struct GRid)*nb_root);
  if (!old_grid) goto wrapup;

  status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,
                             old_grid,OM_K_MAXINT,NULL,
                             0,OM_K_MAXINT,&nb_old),
                       senderid = NULL_OBJID,
                       targetid = clone_grid->objid,
                       targetos = clone_grid->osnum);

  if (!(status&1)) {
    printf("NDconnect_unconsume, problem with NDget_objects\n");
    goto wrapup;
  }

  if (nb_old != nb_root) {
/*
 * Don't think this should happen but does not
 * really hurt anything
 * NDget_objects reallocs old_grid if more room is needed
*/
/*
    printf("NDconnect_unconsume, Mismatch in number of parents\n");
    goto wrapup;
*/
  }

  /* See if parent is no longer used */
  for(i = 0; i < nb_old; i++) {
    found = 0;
    for(j = 0; (!found) && (j < nb_root); j++) {
      if(
        (old_grid[i].objid == root_grid[j].objid) &&
        (old_grid[i].osnum == root_grid[j].osnum)) {
        found = 1;
      }
    }
    if (!found) {
      status = om$send( msg = message NDmacro.ACunconsume(&msg,""),
                        senderid = NULL_OBJID,
                        targetid = old_grid[i].objid,
                        targetos = old_grid[i].osnum );

      if(!(status&msg&1)) {
        printf("Problem unconsuming parent\n");
        goto wrapup;
      }
    }
  }

#ifdef XXX

      /* See if it is consumed */
      consume = 0;
/*
 * Rejected method, NDnodein does not implement ACtest_consumed
 *
      status = om$send ( msg = message NDmacro.ACtest_consumed (&consume),

                          mode = OM_e_wrt_object,
                          senderid = my_grid->objid,
                          targetid = old_grid[i].objid,
                          targetos = old_grid[i].osnum );

      printf("Old         : %d,%d\n",old_grid[i].objid,consume);

as$status();

      if(!(status&1)) {
        printf("Problem testing for parent consumtion,%d\n",status);
        consume = 0;
      }
*/

      if (consume | 1) {
/*
        printf("Old Consumed: %u\n",old_grid[i].objid);
*/
        status = om$send( msg = message  NDmacro.ACunconsume(&msg,""),
                          senderid = NULL_OBJID,
                          targetid = old_grid[i].objid,
                          targetos = old_grid[i].osnum );

        if(!(status&msg&1)) {
          printf("Problem unconsuming parent\n");
          goto wrapup;
        }
      }
    }
  }
#endif

wrapup:

  if (old_grid) om$dealloc(ptr = old_grid);

  return 1;
}

method NDconnect(int nb_root; struct GRid *root; struct GRid original;
		    IGRint type)
{
 IGRint i;
 struct GRid my_grid,clone_grid;
 OM_S_CHANSELECT *to_father,*to_children;
 IGRint status,status1;
 
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

/* get channel to use */

 status = NDget_channel(&to_father,&to_children);

 switch(type)
  {
   case ND_FULL :

   /*  disconnect first previous connection 
       and tranfer them to a tmp clone object to be sure 
       support only element are not delete during change connect */

   status = om$construct(p_objid = &clone_grid.objid,
			 classid = OPP_NDnodein_class_id);
   as$status(action = RET_STATUS);
   clone_grid.osnum = OM_Gw_current_OS;

   status = om$send(msg = message Root.move_chan(*to_father,
                                my_id,OM_Gw_current_OS,*to_father),
                     targetid = clone_grid.objid);
   as$status(action = RET_STATUS);

	
   /* establish new connection */
   case ND_NEW  :

   /* add new connection and notify the root */
   case ND_ADD  :
       status = OM_S_SUCCESS;
       for(i=0;i<nb_root && status&1;i++)
	  {
           /*"connect to %d %d\n",root[i].objid,root[i].osnum */
	   status = om$send(msg = message Root.connect(*to_father,OM_K_MAXINT,
				  		    root[i].objid,root[i].osnum,
						    *to_children,OM_K_MAXINT),
			    targetid = my_id);
 	   as$status();
	  }

       for(i=0;i<nb_root;i++)
	  {
	   om$send(msg = message NDnode.NDnotify_connect(my_grid),
			    targetid = root[i].objid,
			    targetos = root[i].osnum);	
	  }

	/* In case of full reconnection notify old parents for disconnection
	   or restablish the connection if failure */

	if(type == ND_FULL)
	 {
	   if(status&1)
	    {
   	     status1=om$send(msg=message NDnode.NDnotify_disconnect(clone_grid),
		   senderid = clone_grid.objid, 
    	    	   p_chanselect = to_father);
	     as$status(sts = status1);
             /*
              * TR179424043 Unconsume Parents For Certain Objects
              */

             NDconnect_unconsume(&my_grid,&clone_grid,nb_root,root);

	    }

	   else
	    {
   	     status1 = om$send(msg = message Root.move_chan(*to_father,
                                clone_grid.objid,OM_Gw_current_OS,*to_father),
                      	      targetid = my_id);
	     as$status(sts = status1);
	    }
	   status1 = om$send(msg = message Root.delete(1),
			    targetid = clone_grid.objid);
	   as$status();
          }
       break;

    default :
       status = OM_W_ABORT;
       break;
   }

 return(status);
}

end implementation NDnodein;
