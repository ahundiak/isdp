class implementation ACrg_collect;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "ACrg_collect.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "msmacros.h"
#include "ASmsg.h"
#include "asbox.h"

#define	AS_DEBUG
#define	AC_ATTRIB_REF	0x8	/* define type for cs attribute */

extern	GRclassid	OPP_ACpretend_class_id;
from	ACpretend	import	ACgive_downscan;
from	ACpretend	import	ACpconnect;
from    ACpretendin	import  ACiconnect;

#include <alloca.h>

method NDmake_source(IGRlong *msg;
                        struct GRid *located_obj,*context;char *path;
                        GRspacenum as_osnum; struct GRid *as)
{
 char foot_name[DI_PATH_MAX];
 struct GRid my_grid,owner;
 OMuint index;
 int total_size,i_attr;
 long status;

 *msg = MSFAIL;
 status = OM_S_SUCCESS;
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

/*
   Is make source for the entire rg_collection or for one of the members
   Find the downscan to use
*/

if(located_obj->objid == my_id && 
   located_obj->osnum == OM_Gw_current_OS)
 {
  if(path[0] != '\0') strcpy(foot_name,path);
  else if(as_osnum != OM_Gw_current_OS) strcpy(foot_name,".");
  else foot_name[0] = '\0';
 }
else
 {
  /* find object created by ACreturn_foot  on the component channel */
 
  status = om$get_index(objid_c = my_id,
			p_chanselect = & AS_to_comp,
			indexaddr = &index,
			objid = located_obj->objid);
  as$status(action = RET_STATUS);

 total_size = om$dimension_of(varray = me->attr_def);

 for(i_attr=me->nb_attr;i_attr<total_size;i_attr++)
     if(me->attr_def[i_attr].index == index) break;

 if(index >= total_size) return OM_W_ABORT;
 if(path[0] != '\0')
      sprintf(foot_name,"%s:%s",path,me->attr_name+me->attr_def[i_attr].name);
 
 else strcpy (foot_name,me->attr_name+me->attr_def[i_attr].name);
 }

/* 
   create element to connect dependency or return myself or 
   pass up the message to my owner 
*/ 
ASget_as_owner( &my_grid, &owner);
if(!IF_NULL_OBJID(owner.objid))
 {
  /*| assoc owner */
   status = om$send(msg = message NDnode.NDmake_source
                                   (msg,&my_grid,context,foot_name,as_osnum,as),
                    targetid = owner.objid);
 }
else if(foot_name[0] == '\0')
 {
  /* return myself */
  *as = my_grid;
 }
else if (as_osnum == OM_Gw_current_OS)
 {
  /* return a pretend in my OS */
  as->objid = my_id;
  as->osnum = OM_Gw_current_OS;
    status = om$send(msg = message ACrg_collect.ACconnect_pretend
                                                ((int *) msg,foot_name,as ),
                     targetid = my_id);
 }

else 
 {
  /* return a pretendin in the other OS. Warning, won't work for 
     rg_collection since they don't have the notify channel */
    if(context->objid == NULL_OBJID) context->osnum = as_osnum;
    status = om$send(msg = message ACrg_collect.ACconnect_pretendin
                                         ((int *) msg,foot_name,as,context),
                     targetid = my_id);

 }

return status;
}

method  NDsleep(struct GRmd_env *md_env)
{
 long status;
 char *length,*strchr();
 

/* Delete members created by ACreturn_foot */

status = om$send(msg = message NDnode.NDdelete(md_env),
		 p_chanselect = &AS_to_comp);

/* reduce size of my instances if possible */

status = om$vla_set_dimension(varray = me->attr_def, size = me->nb_attr);

length	= 0;
if( me->nb_attr ){
	length = strchr(me->attr_name+me->attr_def[me->nb_attr-1].name,'\0');
	if(length)	length = (char *)(length - me->attr_name + 1);
}
status = om$vla_set_dimension(varray = me->attr_name,
			      size = (IGRuint)length ); 

return om$send(msg = message NDnodein.NDsleep(md_env),
	       mode = OM_e_wrt_message,
	       targetid = my_id);
}

method ACconnect_pretend( int *rc; char *foot_name; struct GRid *pret_GRid )
{
  int			nb_child, i, status;
  extern GRclassid 	OPP_ACpretend_class_id;
  struct GRid		*list_child, my_GRid;
  char			downscan[80];
  GRclassid 		obj_class;


  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  status = om$send(
		msg = message NDnode.NDget_objects(
				ND_CHILDREN | ND_IN_BUF,
				NULL, 0, &list_child,
				0, OM_K_MAXINT,
				&nb_child ),
		targetid = my_id );
  as$status( );
        
  for( i=0 ; i < nb_child ; i++ )
  {
    status = om$get_classid( 	osnum 		= list_child[i].osnum, 
      			       	objid 		= list_child[i].objid, 
				p_classid 	= &obj_class );
    as$status( );

    if( om$is_ancestry_valid( 	subclassid   = obj_class,
		        	superclassid = OPP_ACpretend_class_id )
	== OM_S_SUCCESS )
    {
      /*| it is a pretend */
      status = om$send(	msg = message ACpretend.ACgive_downscan( downscan ),
                  	targetid = list_child[i].objid, 
			targetos = list_child[i].osnum );
        
      if(!strcmp(downscan, foot_name))
      {
        /*| have found a allready there pretend */

        pret_GRid->objid = list_child[i].objid;
	pret_GRid->osnum = list_child[i].osnum;
	break;
      } 
    }
  }

  if(i==nb_child)
  {
    status = om$construct(	classid = OPP_ACpretend_class_id,
			  	osnum	= OM_Gw_current_OS,
			  	p_objid = &(pret_GRid->objid),
			  	msg 	= 
		message ACpretend.ACpconnect( 0, my_GRid, foot_name ));

    as$status( );
    pret_GRid->osnum = OM_Gw_current_OS;
  }

  /*" created pret %d %d \n", pret_GRid->objid, pret_GRid->osnum */

  *rc=1;
  return(OM_S_SUCCESS);
}

method ACconnect_pretendin( int *rc; char *foot_name;
			    struct GRid *pret_GRid,*context )
{
  int			status;
  extern GRclassid 	OPP_ACpretendin_class_id;
  struct GRid   	my_GRid;
  OM_S_OBJECT_LINKAGE   *child,child_context[2];
  char			downscan[80];
  GRclassid 		obj_class;
  OMuint index,count,count_context; 

  my_GRid.objid = my_id;
  my_GRid.osnum = OM_Gw_current_OS;

  /* Try to find a matching ACpretendin */

  /*
     Notify channel is not ordered. Thus we cannot use get_objid_at_index
     Thanks Chary for founding the bug ....
  */
     

  status = om$get_channel_count(objid = my_id,
				p_chanselect = &AS_notification,
				count = &count);

  index = 0;
  if(count > 0)
   {
    child =(OM_S_OBJECT_LINKAGE *) alloca(count * sizeof(OM_S_OBJECT_LINKAGE));
    if(!child) return OM_W_ABORT;
  
    status = om$get_channel_objects(objid = my_id,
				p_chanselect = &AS_notification,
				list = child,
				size = count,
				count = &count);
				

    for(index=0;index<count;index++)
    {
     status = om$get_classid( 	osnum 		= child[index].osnum, 
      			       	objid 		= child[index].S_objid, 
				p_classid 	= &obj_class );
     as$status( );

     if( om$is_ancestry_valid( 	subclassid   = obj_class,
		        	superclassid = OPP_ACpretendin_class_id )
	!= OM_S_SUCCESS ) continue;

     /*| it is a pretendin --> control downscan */

     status = om$send(	msg = message ACpretend.ACgive_downscan( downscan ),
                  	targetid = child[index].S_objid, 
			targetos = child[index].osnum );
        
     if(strcmp(downscan, foot_name)) continue;

     /*| downscan match --> control context */

    status = om$get_channel_objects(objid = child[index].S_objid,
				osnum = child[index].osnum,
				p_chanselect = &AS_listeners,
				list = child_context,
				size = count_context,
				count = &count_context);
     if(!(status&1) || (count_context != 2)) continue;

     if(  (  (context->objid == child_context[0].S_objid)
           &&(context->osnum == child_context[0].osnum))
        ||(  (context->objid == child_context[0].S_objid)
           &&(context->osnum == child_context[0].osnum)))
      {
        /*| matching pretendin found !!! */
        pret_GRid->objid = child[index].S_objid;
	pret_GRid->osnum = child[index].osnum;
	break;
      } 
    }
   }

  if(index >=count) 
  {
    status = om$construct(	classid = OPP_ACpretendin_class_id,
			  	osnum	= context->osnum,
			  	p_objid = &(pret_GRid->objid));
    as$status( );
    status = om$send( 		msg 	= 
	      message ACpretendin.ACiconnect( 0, my_GRid,*context, foot_name ),
		     targetid = pret_GRid->objid,
		     targetos = context->osnum);
    as$status( );

    pret_GRid->osnum = context->osnum;
  }

  /*" created pret %d %d \n", pret_GRid->objid, pret_GRid->osnum */

  *rc=1;
  return(OM_S_SUCCESS);
}
end implementation ACrg_collect;

