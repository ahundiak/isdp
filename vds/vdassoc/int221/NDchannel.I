/* $Id: NDchannel.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / NDchannel.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: NDchannel.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* 
   This file implement NDnode methods which access the NDfather NDchildren
   channel
   jla june 91
*/

class implementation NDnodein;


#include "AS_status.h"
#include "nddef.h"
#include "godef.h"
#include "ndmacros.h"
#define AS_DEBUG

method NDdisconnect(int nb_root; struct GRid *root)
{
 struct GRid my_grid,null_grid;
 OM_S_CHANSELECT *to_father,*to_children;
 IGRint status;
 IGRint i;
 
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;
 null_grid.objid = NULL_OBJID;

/* get channel to use */

 status = NDget_channel(&to_father,&to_children);

 if (nb_root == 0)
  {
   /*| full disconnect */
   om$send(msg = message NDnode.NDnotify_disconnect(my_grid),
 	   p_chanselect = to_father);
   status = om$send(msg = message Root.wild_disconnect(*to_father),
		    targetid = my_id);
   if(!(status &1))
    {char jlclass[80];
     status= om$get_classname(objid = my_id,
			      classname = jlclass);
     as$status();
     printf("wild_disconnect(to_father) fails on object %d %d class %s\n",
	     my_id,OM_Gw_current_OS,jlclass);
    }
   status = OM_S_SUCCESS;
  }
 else
   {
    for(i=0;i<nb_root;i++)
	{
    	 status = om$send(msg = message Root.disconnect
			(*to_father, root[i].objid, root[i].osnum,*to_children),
		     	targetid = my_id);
    	 as$status( action = RET_STATUS );
	}

    for(i=0;i<nb_root;i++)
	{
      	 om$send(msg = message NDnode.NDnotify_disconnect(null_grid),
  		 targetid = root[i].objid,
  		 targetos = root[i].osnum);
	}
		    

   }
 return(status);
}

method NDmove_to_tmp_clone(long *msg; struct GRid *clone)
{
 long status;
 OM_S_CHANSELECT *to_father,*to_children;
 int i,index;
 struct GRid child;

/* get channel to use */

 status = NDget_channel(&to_father,&to_children);

/* move children */

*msg = MSFAIL;
/* Does not work if the target channel is not empty */
/* status = om$send(msg = message Root.move_chan
/*                        (*to_children,my_id,OM_Gw_current_OS,*to_children),
/*                     targetid = clone->objid,
/*                     targetos = clone->osnum);
/****/

for(i=0;i<OM_K_MAXINT;i++)
{
   status = om$get_objid_at_index(objid = my_id,
				  p_chanselect = to_children,
				  index = 0,
				  objidaddr = &child.objid,
				  osnumaddr = &child.osnum);
   if(!(status&1)) break;

   status = om$get_index( objid_c = child.objid, osnum_c = child.osnum,
			  p_chanselect = to_father, 
			  objid = my_id, indexaddr = (OMuint *)&index); 
   as$status( action = RET_STATUS );

   status = om$send(msg = message Root.disconnect(*to_father,my_id,
						OM_Gw_current_OS,*to_children),
		     targetid = child.objid);
   as$status( action = RET_STATUS );
		    
   status = om$send(msg = message Root.connect (*to_father,OM_K_MAXINT,
						 clone->objid,
					 clone->osnum,*to_children,index),
		     targetid = child.objid);
   as$status(action = RET_STATUS);
   }


 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

end implementation NDnodein;
