/* $Id: NDchannel.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/NDchannel.I
 *
 * Description:
 *		GRNUC assoc correction to return properly when objects 
 *		are found to the inquired object.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: NDchannel.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  20:10:38  pinnacle
# Fixed Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/05/15  19:33:52  pinnacle
# Replaced: vdassoc/NDchannel.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation date
 *	10/30/97	ah		UnInit Ref to int_list
 ***************************************************************************/

class implementation NDnodein;

#include "AS_status.h"
#include "nddef.h"
#include "godef.h"
#include "ndmacros.h"
#define AS_DEBUG

#ifdef	NOT_NEEDED

%safe
static IGRint NDchannel = 0;
static OM_S_CHANSELECT NDfather_channel, NDchildren_channel;
%endsafe

NDget_channel(father,children)
OM_S_CHANSELECT **father,**children;
{
 IGRint status;

if(!NDchannel)
   {
    /*| get channel number */
    status = om$make_chanselect(channame     ="NDfather.father",
                                p_chanselect = &NDfather_channel);
    as$status(action = RET_STATUS);
    status = om$make_chanselect(channame     ="NDchildren.children",
                                p_chanselect = &NDchildren_channel);
    as$status(action = RET_STATUS);
    NDchannel = 1;
   }

  *children = &NDchildren_channel;
  *father   = &NDfather_channel;

 return(OM_S_SUCCESS);
}

/*
   Return roots or children of the elements
*/

%safe
struct GRid *NDnode_get_obj_buf = NULL;
int   NDnode_get_obj_size = 0;
%endsafe
/*
   Function to access or modify the node buffer 
   for people who wants to override NDget_objects
*/

/* alloc or realloc if necessary the get_object buffer */

struct GRid *NDrealloc_object_buffer(size)
int size;
/*.NDrealloc_object_buffer*/
{
/*"size %d NDnode_obj_size %d\n",size,NDnode_get_obj_size */
 if(size <= NDnode_get_obj_size) return NDnode_get_obj_buf;


 if(NDnode_get_obj_size == 0 || NDnode_get_obj_buf == NULL)
  {
   /*"alloc %d\n",size */
   NDnode_get_obj_buf=(struct GRid *)om$malloc(size = size*sizeof(struct GRid));
  }
 else
  {
   /*"realloc %d\n",size */
   NDnode_get_obj_buf=(struct GRid *)om$realloc(ptr = (IGRchar *)NDnode_get_obj_buf,
                                               size = size*sizeof(struct GRid));
  }

 if(NDnode_get_obj_buf != NULL) NDnode_get_obj_size = size;
 else 			        NDnode_get_obj_size = NULL;
 return NDnode_get_obj_buf;
}

/* Return the size of the get_object buffer */

NDget_obj_size()
{
return NDnode_get_obj_size;
}

#endif

extern	struct GRid	*NDnode_get_obj_buf ;
extern	int		NDnode_get_obj_size ;


method NDget_objects(int type;struct GRid *list;int size; struct GRid **buffer;
		     int ifrom,ito,*count)
{
#define MAX_OBJ 20
 OM_S_OBJECT_LINKAGE prov[MAX_OBJ],*lin_c;
 struct GRid *int_list;
 IGRint new_size;
 OM_S_CHANSELECT *to_father,*to_children;
 OM_S_CHANSELECT *chan;
 IGRchar *ptr;
 IGRint ii,i,ideb,iend;
 IGRint status;
 IGRint link_size;
 OMuint count_tmp;

 extern struct GRid *NDnode_get_obj_buf ;
 extern int   NDnode_get_obj_size ;


  int_list = NULL; // Get rid of warning

/* initialization of array to receive elements */

/*" type %d  size %d \n",type,size */
/*" ifrom %d ito %d\n",ifrom,ito */


/* get channel to use */

   NDget_channel(&to_father,&to_children);


/* father or  children channel */

     if( type & ND_ROOT) chan = to_father;
     else	         chan = to_children;


/* get the objects on the channel */

   lin_c = prov;
   ptr = NULL;
   link_size =  MAX_OBJ ;
   *count=0; /* fix for TR# 119423478 --vidya */

   status = om$get_channel_objects(object = me, p_chanselect = chan, 
				   list = lin_c,
				   size = link_size,
				   count = (OMuint *) count);

   if( !( *count ) ) {
     if(type & ND_IN_BUF){
	if( buffer ) *buffer = NULL ;
     }
     status = OM_S_SUCCESS ;
     goto wrapup;
   }

   if(status == OM_I_LISTOVFLOW)
     {
      /*"get channel does not return total number of object %d\n",*count */
      status = om$get_channel_count(object = me, p_chanselect = chan, 
				    count = (OMuint *) count);

      if(ito > link_size-1)
	{ 
	 /*| redo get_channel_objects with allocated array */

         link_size = (ito > ito+1) ? ito : ito+1 ; /*avoid pb with OM_K_MAXINT*/
         link_size = (*count < link_size) ? *count : link_size;

         /*| alloc the array */
         ptr = om$malloc(size = link_size*sizeof(OM_S_OBJECT_LINKAGE));
         if(ptr == NULL) 
            {printf("NDnode.NDgive_objects can't allocate space\n");
             *count = 0;
             return(OM_W_ABORT);
            }
         lin_c = (OM_S_OBJECT_LINKAGE *) ptr;

   	 status = om$get_channel_objects(object = me, p_chanselect = chan, 
				   	list = lin_c,
				   	size = link_size,
				   	count = &count_tmp);
	}
     }

  /*"*count %d ito %d link_size %d\n",*count,ito,link_size */


  /* Now put the elements in the return array */
  /* and allocate if necessary this  buffer   */
  
     ideb = ifrom > 0 ? ifrom : 0;
     iend = ito   < *count ? ito : *count-1; 

     if(type & ND_IN_BUF)
	{ 
	 new_size = iend-ideb+1;
	 if(new_size>NDnode_get_obj_size)
	   {
	    if(NDnode_get_obj_buf != NULL) om$dealloc(ptr = NDnode_get_obj_buf);
	    NDnode_get_obj_buf = NULL;
	    NDnode_get_obj_size = 0;
	    NDnode_get_obj_buf = (struct GRid *) om$malloc(size = new_size*sizeof(struct GRid));
	    if(NDnode_get_obj_buf == NULL)
	 	{printf("NDnode.NDgive_objects can't allocate space\n");
	  	 *count = 0;
	  	 return(OM_W_ABORT);
	 	}
	    NDnode_get_obj_size = new_size;
	    /*"alloc de buffer %d\n",NDnode_get_obj_size */
	    }
	 /*"new_size %d NDnode_get_obj_size %d\n", new_size,NDnode_get_obj_size */
	*buffer = NDnode_get_obj_buf;
	int_list = (struct GRid*) NDnode_get_obj_buf;
	    
	}
   

   /* store the objects in the provided array or in buffer */
   /*" ideb %d iend %d\n",ideb,iend */

   for(i=ideb,ii=0;i<=iend;i++,ii++)
      {
       if(type & ND_IN_BUF)
	  {
           int_list[ii].objid = lin_c[i].S_objid;
           int_list[ii].osnum = lin_c[i].osnum;
     /*" obj %d %d\n",int_list[ii].objid,int_list[ii].osnum */
	  }
       else
          {
	   if(ii >= size) break;
           list[ii].objid = lin_c[i].S_objid;
           list[ii].osnum = lin_c[i].osnum;
     /*" obj %d %d\n",list[ii].objid,list[ii].osnum */
	  }
      }

 wrapup : if(ptr != NULL) 
            {
	     /*| deallocate array */
 	     om$dealloc(ptr = ptr);
	    }
 /*" count %d\n",*count */
 return(status);
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
method NDdisconnect(int nb_root; struct GRid *root)
{
 struct GRid my_grid,null_grid;
 OM_S_CHANSELECT *to_father,*to_children;
 IGRint status;
 IGRint i;
 
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;
 null_grid.objid = NULL_OBJID;
 null_grid.osnum = OM_Gw_current_OS;

/* get channel to use */

 status = NDget_channel(&to_father,&to_children);

 if (nb_root == 0)
  {
   /*| full disconnect */
   om$send(msg = message NDnode.NDnotify_disconnect(my_grid),
 	   p_chanselect = to_father);
   status = om$send(msg = message Root.wild_disconnect(*to_father),
		    targetid = my_id);
   as$status(action = RET_STATUS);
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

method NDchange_connect(int nb_change; struct GRid *old,*new)
{
 IGRint i,index;
 struct GRid my_grid,null_grid;
 IGRint status;
 OM_S_CHANSELECT *to_father,*to_children;


 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;
 null_grid.objid = NULL_OBJID;
 null_grid.osnum = OM_Gw_current_OS;

/* get channel to use */

 status = NDget_channel(&to_father,&to_children);

 for(i=0;i<nb_change;i++)
   {
    status = om$get_index( object_c = me, p_chanselect = to_father, 
			  objid = old[i].objid, indexaddr = (OMuint *)&index); 

   /*"%d index of the old root: %d\n",index,old[i].objid */
    as$status( action = RET_STATUS );

    status = om$send(msg = message Root.disconnect(*to_father,old[i].objid,
						old[i].osnum,*to_children),
		     targetid = my_id);
    as$status( action = RET_STATUS );
		    
    status = om$send(msg = message Root.connect (*to_father,OM_K_MAXINT,
						 new[i].objid,
					 new[i].osnum,*to_children,index),
		     targetid = my_id);
    as$status(action = RET_STATUS);

    om$send(msg = message NDnode.NDnotify_disconnect(null_grid),
           targetid = old[i].objid,
	   targetos = old[i].osnum);

    om$send(msg = message NDnode.NDnotify_connect(my_grid),
			    targetid = new[i].objid,
			    targetos = new[i].osnum);	
   }

return(OM_S_SUCCESS);
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
/* jla jan 93 */
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
