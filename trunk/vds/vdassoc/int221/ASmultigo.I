/* $Id: ASmultigo.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ASmultigo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ASmultigo.I,v $
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

/* ###################   APOGEE COMPILED   ################## */
class implementation ASnode;

#define AS_DEBUG

#include "ASmacroi.h"
#include <limits.h>
#include "macro.h"
#include "grownerdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include <alloca.h>

from  ACpretend   import ACgive_downscan, ACpconnect;
from  ACpretendin import ACiconnect;

#define path_MAX_CHAR 160

/* ********************** MSG NDmake_source () ************************	*/

method NDmake_source(IGRlong *msg;struct GRid *located_obj,*context;char *path;
			     GRspacenum as_osnum; struct GRid *as )
{
 char foot_name[path_MAX_CHAR];
 IGRlong status;
 struct GRid owner;
 struct GRid		mygrid, go;
 int suc;

/* Increment path if necessary */

 if(!IF_EQ_OBJID(located_obj->objid,my_id))
   {
    status = om$send(msg = message ASnode.ACgive_path
                                                   (&suc,located_obj,foot_name),
    targetid = my_id);
    as$status(action = RET_STATUS);
   }
 else foot_name[0] = '\0';

 if(path[0]!='\0')
   {
    if(foot_name[0] != '\0') strcat(foot_name,":");
    strcat(foot_name,path);
   }

/* Find if there is some associative owner */ 

 mygrid.osnum = OM_Gw_current_OS;
 mygrid.objid = my_id;
 owner.objid=NULL_OBJID;
 ASget_as_owner( &mygrid, &owner );

 if(!IF_NULL_OBJID(owner.objid))
  {
  /*| assoc owner */
   status = om$send(msg = message NDnode.NDmake_source
				    (msg,&mygrid,context,foot_name,as_osnum,as),
		    targetid = owner.objid);
  
  }
 else
  {
   /*| No assoc owner --> can connect dependency */
   if(foot_name[0] == '\0' && 
      located_obj->osnum == as_osnum && context->objid == NULL_OBJID)
    {
     /*| return directly the assoc object */
     as->objid = my_id;
     as->osnum = OM_Gw_current_OS;
     status = OM_S_SUCCESS;
     *msg = MSSUCC;
    }

   else if(foot_name[0] == '\0')
    {
     /*| Return a sourcein or pretendin object connected by tag */
     status = om$send(msg = message NDmacro.ACreturn_foot(msg,"",&go,NULL,NULL),
		 	     	targetid = located_obj->objid,
		     	 	targetos = located_obj->osnum);
     if(!(status & *msg & 1)) go = *located_obj;
     /* make sure that os_num  is specified */ 
     if(context->objid == NULL_OBJID) context->osnum = as_osnum;
     status = om$send(msg = message ASnode.ACconnect_pretendin
					((int *) msg,"",as,context ),
		      targetid = go.objid,
		      targetos = go.osnum);
     if(!(status&1)) status=ASmake_source_from_go(msg,&go,context,as_osnum,as);
    }

   else if( located_obj->osnum == as_osnum && context->objid == NULL_OBJID)
   {
    /*| Return a pretend pointing to the edequate member */
    status = om$send(msg = message ASnode.ACconnect_pretend
						((int *) msg,foot_name,as ),
                     targetid = my_id);
   }
  else
   {
    /*| Return a pretendin connected by tag pointing to the edequate member */
    if(context->objid == NULL_OBJID) context->osnum = as_osnum;
    status = om$send(msg = message ASnode.ACconnect_pretendin
					((int *) msg,foot_name,as,context ),
          	     targetid = my_id);
   }
  as$status(action = RET_STATUS);
  if(!(*msg&1)) status = OM_W_ABORT;
 }

 /*" return %d %d\n",as->objid,as->osnum */
 return(status);
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
  if(!(status&1)) return OM_W_ABORT;
  

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
/* Modif CH 06 Apr 93, 
/* Pb found by AF,
/* Fixe given by AF.
/*				size = count_context,
/* */
				size = 2,
				count = &count_context);
     if(!(status&1)) continue;
     else if(count_context == 1 && context->objid == NULL_OBJID)
       {
        pret_GRid->objid = child[index].S_objid;
	pret_GRid->osnum = child[index].osnum;
	break;
       }

     else if(((context->objid == child_context[0].S_objid)
            &&(context->osnum == child_context[0].osnum))
        ||(   (context->objid == child_context[1].S_objid)
            &&(context->osnum == child_context[1].osnum)))
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


/* Return a path if there is more than 1 member connected to avoid creation  */
/* of useless pretend 							     */

method ACgive_path(int *suc;struct GRid *go_obj;char *footname)
{
 OMuint index;
 int status;
 OMuint count;

 *suc = 0;
 status= om$get_index(objid_c       = my_id,
                      osnum_c       = OM_Gw_current_OS,
                      p_chanselect  = &AS_to_comp,
                      objid         = go_obj->objid,
                      osnum2        = go_obj->osnum,
                      indexaddr     = &index);
 as$status(action = RET_STATUS);

 status = om$get_channel_count(object = me, p_chanselect = &AS_to_comp,
			       count = &count);

 if(count > 1) sprintf(footname,"$%d",index);
 else  footname[0] = '\0';
 
 *suc = 1;
 return OM_S_SUCCESS;
}

/* ********************* MSG ACreturn_foot () *************************	*/

method ACreturn_foot( IGRlong *msg; char *foot_name; 
		struct GRid *foot_GRid; IGRshort *mat_type;IGRdouble *matrix )
{
 int index;
 long status;
 char *chpos,*strchr();
 
 *msg = 0;
 foot_GRid->objid = NULL_OBJID;

 if(foot_name[0] == '.' || foot_name[0] == '\0')
   index = 0;

 else if(foot_name[0] == '$')
   sscanf(foot_name+1,"%d",&index);

 else return OM_S_SUCCESS;

 /*"index %d\n",index */
 status = om$get_objid_at_index( objid      = my_id,
                                  p_chanselect  = &AS_to_comp,
                                  index         = index,
                                  objidaddr     = &(foot_GRid->objid),
                                  osnumaddr     = &(foot_GRid->osnum) );
 as$status(  );
 if(!(status&1)) return OM_S_SUCCESS;

 /* Added by pp */

 if(chpos=strchr(foot_name,':'))
 {
  status = om$send(msg =  message ASnode.ACreturn_foot
                                      (msg,chpos+1,foot_GRid,mat_type,matrix),
                  targetid = foot_GRid->objid ,targetos = foot_GRid->osnum);
  if(!(status&1)) *msg = 0;
 }
 else
 {
  *msg = 1;
  if(mat_type) *mat_type = MAIDMX;
  if(matrix) MAidmx(&status,matrix);
 }
 return OM_S_SUCCESS;
}

end implementation ASnode;
