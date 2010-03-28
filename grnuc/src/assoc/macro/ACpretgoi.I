/*
  ACpretgoi.I
  robert patience
  12_dec_88
*/
class implementation ACpretgo;

#include "ASmacroi.h"

#include "macro.h"
#include "nddef.h"
#include "madef.h"

#define AS_DEBUG

from ACmacro_defn import ACfind_go;

/* ========================================================================= */
method ACset_def(struct GRid *def_id)
{
 me->def_id = *def_id;
 return OM_S_SUCCESS;
}
method  ACload_go_ptr()
{
int status,cnt;
OM_S_OBJID wobj;
OMuword 		osn;
GRclassid 		target_cl;

   cnt=0;
   while(1)
   {
    status = om$get_objid_at_index(objid = my_id,
                                  p_chanselect = &AS_to_owner,
                                  index = cnt,
                                  objidaddr = &wobj,
				  osnumaddr = &osn);
    as$status(action = RET_STATUS );
    om$get_classid(objid=wobj,p_classid = &target_cl);

    if(om$is_ancestry_valid(subclassid =target_cl ,
                      superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
      {
      break;
      }
    else cnt +=1;
    } 

    status = om$send(msg = message ACmacro_defn.ACfind_go(&(me->go_ptr)),
                        targetid = me->def_id.objid,
                        targetos = OM_Gw_current_OS);
    as$status( action = RET_STATUS );
      /*" found at %d ptr %d\n",i,me->go_ptr   */

return(1);
}
/* ========================================================================= */

method ACplace(int *index )
{
  me->index=*index;
  *index +=1;
  return(1);
}

method  ACgive_info(struct GRid *go)
{
int status;
GRclassid 		target_cl;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

   om$get_classid(osnum =me->go_ptr[me->index].osnum ,
   		objid=me->go_ptr[me->index].objid,p_classid =&target_cl );
   if(om$is_ancestry_valid(subclassid =target_cl ,
                      superclassid = OPP_ACpretgo_class_id) == OM_S_SUCCESS)
      {
      status = om$send(msg =message  ACpretgo.ACgive_info(go),  
	  targetid =me->go_ptr[me->index].objid,
	  targetos =me->go_ptr[me->index].osnum);
      
      }
   else 
     *go=me->go_ptr[me->index];

 /*"objid %d %d index %d ptr %d\n",go->objid,go->osnum,me->index,me->go_ptr */

 return(1);
}


method  ACstore_info(struct GRid go)
{
int status;
GRclassid 		target_cl;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

   om$get_classid(osnum =me->go_ptr[me->index].osnum ,
   		objid=me->go_ptr[me->index].objid,p_classid =&target_cl );
   if(om$is_ancestry_valid(subclassid =target_cl ,
                      superclassid = OPP_ACpretgo_class_id) == OM_S_SUCCESS)
      {
      status = om$send(msg =message  ACpretgo.ACstore_info(go),  
	  targetid =me->go_ptr[me->index].objid,
	  targetos =me->go_ptr[me->index].osnum);
      
      }
   else 
     me->go_ptr[me->index] = go;


 return(1);
}

/* ========================================================================= */

method unknown (OM_S_MESSAGE *msg)
{
  int  	status;

  /*^
  char classname1 [OM_K_MAXCLASS_LEN], classname2 [OM_K_MAXCLASS_LEN];
  IGRchar 	name [80];

  om$get_classname( classid = msg->select.ReqClassid, 
                    classname = classname2 );
  om$get_classname( classid = msg->select.DefClassid, 
                    classname = classname1 );
  status = om$get_message_name ( classid = msg->select.ReqClassid,
                                 method_index = msg->select.FuncIndex,
                                 msg_name = name );

  printf ( "Unknown Message from %s to %s,%s\n",classname1, classname2,
		name);
  printf("go_ptr %d\n",me->go_ptr);
  */
    
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

  /*" target %d %d\n",me->go_ptr[me->index ].objid,me->go_ptr[me->index].osnum*/

  status = om$send( mode = OM_e_wrt_object, 
	   targetid =me->go_ptr[me->index ].objid,
	   targetos =me->go_ptr[me->index].osnum,
	       msg = msg);
  as$status();
  return(status);

} /* end method unknown */

/* ========================================================================= */

method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
     	       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
int status;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

  status = om$send( mode = OM_e_wrt_object, 
	  targetid =me->go_ptr[me->index].objid,
	  targetos =me->go_ptr[me->index].osnum,
	       msg = OPPmargs);
  as$status();
  return(OM_S_SUCCESS);
}


method XYsleep ()
{
   me->go_ptr=0;
   return(1);
}


/*


method GRdelete( IGRlong *msg; struct GRmd_env *md_env)
{
 return(OM_S_SUCCESS);
}
*/

method GRxform( IGRlong *msg; struct GRmd_env *md_env;
	        IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
int status;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

  status = om$send( mode = OM_e_wrt_object, 
	  targetid =me->go_ptr[me->index].objid,
	  targetos =me->go_ptr[me->index].osnum,
	       msg = OPPmargs);
  as$status();
  return(status);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
int status;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

  status = om$send( mode = OM_e_wrt_object, 
	  targetid =me->go_ptr[me->index ].objid,
	  targetos =me->go_ptr[me->index].osnum,
	       msg = OPPmargs);
  as$status();
  return(status);
}

method GRgetprops(IGRlong *msg; IGRshort *props)
{
int status;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

  status = om$send( mode = OM_e_wrt_object, 
	  targetid =me->go_ptr[me->index ].objid,
	  targetos =me->go_ptr[me->index].osnum,
	       msg = OPPmargs);
  as$status();
  return(status);
}

method GRchgprops(IGRlong *msg; IGRshort *action; IGRshort *props)
{
int status;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

  status = om$send( mode = OM_e_wrt_object, 
	  targetid =me->go_ptr[me->index ].objid,
	  targetos =me->go_ptr[me->index].osnum,
	       msg = OPPmargs);
  as$status();
  return(status);
}

method GRgetrang(IGRlong *msg;IGRshort *matrix_type; IGRmatrix matrix; 
	IGRboolean *world; GRrange range)
{
int status;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

  status = om$send( mode = OM_e_wrt_object, 
	  targetid =me->go_ptr[me->index ].objid,
	  targetos =me->go_ptr[me->index].osnum,
	       msg = OPPmargs);
  as$status();
  return(status);
}

method GRptproject(IGRlong *msg; IGRshort *matrix_type;
	IGRmatrix matrix; IGRpoint point,proj_pt;
	struct GRparms *proj_parms)
{
int status;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

  status = om$send( mode = OM_e_wrt_object, 
	  targetid =me->go_ptr[me->index ].objid,
	  targetos =me->go_ptr[me->index].osnum,
	       msg = OPPmargs);
  as$status();
  return(status);
}
method GRlnproject(IGRlong *msg; IGRshort *matrix_type;
	IGRmatrix matrix; struct IGRline *line;
	IGRpoint ln_pt,proj_pt; IGRdouble *t;
	struct GRparms *proj_parms) 
{
int status;
  if(!me->go_ptr){
   status = om$send(msg = message ACpretgo.ACload_go_ptr(),targetid = my_id);
   as$status();}

  status = om$send( mode = OM_e_wrt_object, 
	  targetid =me->go_ptr[me->index ].objid,
	  targetos =me->go_ptr[me->index].osnum,
	       msg = OPPmargs);
  as$status();
  return(status);
}

end implementation ACpretgo;

