/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  GRgraphics
     METHOD NAME:  GRdelete

     Abstract: 
	    	This method deletes the graphics object from
		the object space.
-----
%SC%    

    GRdelete(msg,md_env)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env	  GRmd_env	  structure containing context info
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
		GRgetrang
	      	GRmdremove
	      	GRmdaddwrng
-----
%RL%

     RELATIONS REFERENCED:	none.
-----
%NB%

     NOTES:
		If the object cannot be deleted for
		some reason, an indicator will be
		included in the method return status.
		Reference to the object will also
		remain in the R-tree.
-----
%CH%

     CHANGE HISTORY:
	
	KMO	04/08/86 : Creation date.
	MAS	08/12/86 : Revision date.
        PP      10/15/91 : Added code to notify the children of my delete
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	This method deletes a graphic object from the design
	space.  Entries in the R-tree and the directory system
	will also be removed.
----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "grerr.h"
#include "msdef.h"
#include "mapriv.h"
#include "OMmacros.h"
#include "godef.h"
#include "gocmacros.h"
#include "OMmacros.h"
#include "DEso.h"
#include "DEsomacros.h"


from GRcmpowner import GRcomponent_disconnecting;
from NDnode import NDparent_deleted;

method GRdelete(IGRlong *msg; struct GRmd_env *md_env)
{
    IGRboolean 		world;

    IGRlong 		OMmsg;		/* return status for method	*/

    struct GRid		oid;

    OM_S_CHANSELECT 	chan;

    GRrange		range;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    chan.type = OM_e_name;
    chan.u_sel.name = "GRconnector.to_owners";
		
    oid.objid = my_id;
    oid.osnum = OM_Gw_current_OS;

    /* test for NULL_OBJID as a test of whether the object is in the
     * Rtree.
     */
    
    if (! (  IF_NULL_OBJID(md_env->md_id.objid) ||
	    (me->properties & GRNOT_IN_RTREE) ) )
    {
  	/* get range for delete
 	 */
        
	world = FALSE;
        OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRgetrang(
			   msg,&md_env->md_env.matrix_type,
			   md_env->md_env.matrix,
			   &world,range),
                         senderid = my_id,
                         targetid = my_id);

        if (1 & OMmsg & *msg)
        {
	    OMmsg = GRownerrem(msg,md_env,&my_id,&OM_Gw_current_OS,range);

	    if (1 & OMmsg & *msg)
	    { 			     
		/* notify owner that you are disconnecting so the owner
		 * can delete himself if this is the last component on
	  	 * the channel.
		 */

		om$send(
		    msg = message GRcmpowner.GRcomponent_disconnecting
			(msg,md_env,&oid),
		    p_chanselect = &chan);

 	         			/*  delete the object 		*/
		OMmsg =  om$send(mode = OM_e_wrt_object,
			    msg = message Root.delete(NULL),
			    senderid = my_id,
                            targetid = my_id);
					/* delete failed		*/
                 if ( !(1 & OMmsg ))	/* add back to R-tree		*/
                 {			
	    	      OMmsg = GRowneradd(msg,md_env,&my_id,
				&OM_Gw_current_OS,range);
		 }
	     }
    	}
    }
    else				/* object not in R-tree		*/
    {
	/* notify owner that you are disconnecting so the owner
	 * can delete himself if this is the last component on
	 * the channel.
	 */

	om$send(
	    msg = message GRcmpowner.GRcomponent_disconnecting
		(msg,md_env,&oid),
	    p_chanselect = &chan);

    					/* delete the object		*/
					/* (i is a dummy argument)	*/
	OMmsg =  om$send(mode = OM_e_wrt_object,
		    msg = message Root.delete(NULL),
		    senderid = my_id,
                    targetid = my_id);
    }


    if (!(1 & OMmsg))
    {
	*msg = MSFAIL;
    }
    else
    {
	/* the object was successfully deleted. Remove it from
	 * the cache.
	 */

    	GRabsg_del_by_objid(&my_id,&md_env->md_id.osnum);

    }

    {
      /* clean up so (if any) */
      long  l_msg;
      OM_S_CHANSELECT  children;
      struct GRid src_grid;
/*
 * Send a move to root message to my children if I am getting deleted.
 * pp 10/15/91
 */

      if (me->properties & GRIS_ASSOCIATIVE)
      {
       om$make_chanselect(channame = "NDchildren.children",
                          p_chanselect = &children);

       om$send (msg = message NDnode.NDparent_deleted(&l_msg, 1, &oid,
                                                      &src_grid, md_env),
                p_chanselect = &children);
    
      }

      if (me->properties & DEHAS_OVERRIDE)
        de$delete_by_objid ( msg = &l_msg, objid = my_id );
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_DELETED);

    return(OMmsg);

}

end implementation GRgraphics;
