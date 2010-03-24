class   implementation  OMSupGroup;

#include        <stdio.h>
#include        <string.h>

#include        "OMspecify.h"
#include        "OMsend.h"
#include        "OMerrordef.h"
#include        "OMmetaclass.h"
#include        "OMmacros.h"
#include        "OMcluster.h"
#include	"OMrelation.h"
#include        "OMintprims.h"

extern  int		OMSupGroup_get_group_oids();

extern  int             OMObjSpace_OPP_pass_method_index;
from OMGroup import my_name, pass;



/*
Revision History:

        May-26-1988  Initial release of this method.
*/

/*========================================================*/
/* This method is used to initialize new super-groups at  */
/* their time of construction.  			  */
/*========================================================*/

method init_OMSupGroup(char *name)
{
 OM_S_CHANSELECT cs_to, cs_fr;
 OMuint sts;
 OM_S_OBJID transoid=NULL_OBJID;
 int search=0, namelen;
 char   oidstring[11];			/* max # digits for objid is */
                                        /* 10 plus NULL; so 11       */
 

 if (name==NULL){    /* use default group name */
   namelen = strlen("supgrp_");
   sprintf(oidstring, "%u", my_id);
   namelen = namelen+strlen(oidstring)+1;
   if (!(1&(sts=om$vla_set_dimension(varray=ME.OMSupGroup->name, size=namelen))))
     return(sts);

   strcpy(ME.OMSupGroup->name, "supgrp_");
   strcat(ME.OMSupGroup->name, oidstring);
 }
 else{
   /*===========================================*/
   /* check for super group name already in use */
   /*===========================================*/

   cs_fr.type = OM_e_name;
   cs_fr.u_sel.name = "OMObjSpace.to_GrpDscs";
   sts=om$send(msg=message OMSupGroup.find(name, &transoid, search), senderid=OM_GO_current_OS_objid, p_chanselect=&cs_fr);
   if (!(1&sts) && sts != OM_W_UNKNOWN_MSG)
     return(sts);

   if (transoid != NULL_OBJID) return(OM_E_DUPGRPNAME);


   if (!(1&(sts=om$vla_set_dimension(varray=ME.OMSupGroup->name, size=strlen(name)+1))))
     return(sts);

   strcpy(ME.OMSupGroup->name, name);
 }

 /*=======================*/
 /* connect myself to OSO */
 /*=======================*/

 cs_fr.type = OM_e_addr;
 cs_to.type = OM_e_name;
 cs_fr.u_sel.addr = &(ME.OMSupGroup->to_OSO);
 cs_to.u_sel.name = "OMObjSpace.to_GrpDscs";
 if (!(1&(sts = om$send(msg=message Root.connect (
                       cs_to, 0, my_id, OM_Gw_current_OS,
                       cs_fr, 0),
                       targetid=OM_GO_current_OS_objid))))
   return(sts);


 return(OM_S_SUCCESS);
}



/*
Revision History:

        May-26-1988  Initial release of this method.
*/

/*============================================*/
/* To add one new member to this super-group. */
/*============================================*/

method add_member(OM_S_OBJID oid) 
{
 OM_S_CHANSELECT cs_to, cs_fr;
 OMuint sts, sts2;

 /*====================================*/
 /* if the given oid is equal to my_id */
 /*====================================*/
 if (IF_EQ_OBJID(oid, my_id))
   return(OM_E_CYCLEINSUPGROUP);

 /*===================================*/
 /* connect myself to the given child */
 /*===================================*/
 cs_fr.type = OM_e_addr;
 cs_fr.u_sel.addr = &(ME.OMSupGroup->to_child);
 cs_to.type = OM_e_name;

 /*===========================================================*/
 /* If the added child is a SupGroup, make sure that there is */
 /* no cycle in the resulting graph.                          */
 /*===========================================================*/

 sts=om$is_ancestry_valid(subclassid=OM_Gp_CurSpaceMap[oid].p_acld->w_classid, superclassid=OM_K_OMSUPGROUP_ACTCLASSID);
 if (!(1&sts)) return(sts);
 if (sts == OM_S_SUCCESS){
   cs_to.u_sel.name = "OMSupGroup.to_parent";
   if (!(1&(sts = om$send(msg=message Root.connect (cs_to, 0,
       my_id, OM_Gw_current_OS, cs_fr, 0), targetid=oid))))
     return(sts);

   cs_fr.u_sel.addr = &(ME.OMSupGroup->to_parent);
   sts=om$send(msg=message OMSupGroup.verGraph(oid), p_chanselect=&cs_fr);
   if (!(1&sts)){
     /*=================================================================*/
     /* To disconnect the new added child as an error returned from the */
     /* verification process                                            */
     /*=================================================================*/

     cs_fr.u_sel.addr = &(ME.OMSupGroup->to_child);
     if (!(1&(sts2 = om$send(msg=message Root.disconnect (
            cs_to, my_id, OM_Gw_current_OS, cs_fr), targetid=oid))))
       return(sts2);
     return(sts);
   }
 }
 else{
   /*======================================================*/
   /* The following send assumes that the new member is a  */
   /* Group object, it will get an error otherwise.        */
   /*======================================================*/

   cs_to.u_sel.name = "OMGroup.to_parent";
   if (!(1&(sts = om$send(msg=message Root.connect (cs_to, 0,
       my_id, OM_Gw_current_OS, cs_fr, 0), targetid=oid))))
     return(sts);
 }

 return(OM_S_SUCCESS);
}




/*
Revision History:

        May-26-1988  Initial release of this method.
*/

/*==================================*/
/* looking for a cycle in the graph */
/*==================================*/

method verGraph(OM_S_OBJID oid)
{
 OM_S_CHANSELECT cs_fr;
 OMuint sts;



 if ( IF_EQ_OBJID(oid,my_id) )
   return(OM_E_CYCLEINSUPGROUP);
 
 cs_fr.type = OM_e_addr;
 cs_fr.u_sel.addr = &(ME.OMSupGroup->to_parent);
 sts=om$send(msg=message OMSupGroup.verGraph(oid), p_chanselect=&cs_fr);
 if (!(1&sts)) return(sts);
 return(OM_S_SUCCESS);
}



/*
Revision History:

        May-26-1988  Initial release of this method.
*/

/*=======================================================*/
/* To remove a member from this super-group.             */
/* The return code OM_W_NOSUCHMEMBER could mean taht the */
/* target member is not in this SupGroup, or it's not a  */
/* class/suclass of Group/SupGroup.                      */
/*							 */
/* Note that this message can only be sent to the        */
/*      immediate parent of the member.			 */
/*=======================================================*/

method remove_member(OM_S_OBJID oid)
{
 OMuint sts;
 OM_S_CHANSELECT cs_fr, cs_to;
 OMuword childClassid;


 cs_fr.type = OM_e_addr;
 cs_fr.u_sel.addr = &(ME.OMSupGroup->to_child);
 cs_to.type = OM_e_name;

 if (!(1&(sts=om$get_classid(objid=oid, p_classid=&childClassid))))
   return(sts);

 sts=om$is_ancestry_valid(subclassid=childClassid, superclassid=OM_K_OMGROUP_ACTCLASSID);
 if (!(1&sts)) return(sts);
 if (sts == OM_S_SUCCESS)
   cs_to.u_sel.name = "OMGroup.to_parent";
 else{	/* i.e. The returned sts is OM_I_INVANCESTRY */
   sts=om$is_ancestry_valid(subclassid=childClassid, superclassid=OM_K_OMSUPGROUP_ACTCLASSID);
   if (!(1&sts)) return(sts);
   if (sts == OM_S_SUCCESS)
     cs_to.u_sel.name = "OMSupGroup.to_parent";
   else  /* i.e. The returned sts is OM_I_INVANCESTRY */
     return(OM_W_NOSUCHMEMBER);
 }

 sts = om$send(msg=message Root.disconnect (
        cs_to, my_id, OM_Gw_current_OS, cs_fr), targetid=oid);
 
 if (sts == OM_W_NOTONCHAN) return(OM_W_NOSUCHMEMBER);
 if (!(1&sts)) return(sts);
 
 return(OM_S_SUCCESS); 
}



/*
Revision History:

        May-26-1988  Initial release of this method.
*/

/*=======================================================*/
/* To find a member of this super-group.		 */
/*=======================================================*/

method find(char *name; OM_p_OBJID p_oid; int search)
{
 OM_p_OBJECT_LINKAGE objLinkages;
 OM_S_CHANSELECT myChanSel;
 OMuint sts, chanCnt;
 OMuword childClassid;
 unsigned int    i, objCnt;

 *p_oid = NULL_OBJID;
 if (!(strcmp(name, ME.OMSupGroup->name))){
   *p_oid = my_id;
   return(OM_I_STOP_SENDING);
 }

 if (!search) return(OM_S_SUCCESS);

 myChanSel.type = OM_e_addr;
 myChanSel.u_sel.addr = &(ME.OMSupGroup->to_child);
 if (!(1&(sts=om$get_channel_count(object=(OM_p_OBJECTHDR) me,
     p_chanselect=&myChanSel, count=&chanCnt))))
   return(sts);

 objLinkages = (OM_p_OBJECT_LINKAGE) om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE)*chanCnt);
 if (!objLinkages){
   return(OM_E_NODYNMEM);
 }
  
 if (!(1&(sts=om$get_channel_objects(object=(OM_p_OBJECTHDR) me,
      p_chanselect=&myChanSel,
     list=objLinkages, size=chanCnt, count=&objCnt))))
   return(sts);

 for (i=0; i<objCnt; i++){
   if (!(1&(sts=om$get_classid(objid=objLinkages[i].S_objid, p_classid=&childClassid))))
     return(sts);

   sts=om$is_ancestry_valid(subclassid=childClassid, superclassid=OM_K_OMSUPGROUP_ACTCLASSID);
   if (!(1&sts)) return(sts);
   if (sts == OM_S_SUCCESS){
     search = 1;
     sts=om$send(msg=message OMSupGroup.find(name, p_oid, search), targetid=objLinkages[i].S_objid);

     if (!(1&sts) || sts == OM_I_STOP_SENDING) return(sts);
   }
   else{
     sts=om$is_ancestry_valid(subclassid=childClassid, superclassid=OM_K_OMGROUP_ACTCLASSID);
     if (!(1&sts)) return(sts);
     sts=om$send(msg=message OMGroup.my_name(name, p_oid), targetid=objLinkages[i].S_objid);

     if (!(1&sts) || sts == OM_I_STOP_SENDING) return(sts);
   }
 }	/* for */

 om$dealloc(ptr=(char *) objLinkages);
 return(OM_S_SUCCESS);
}



/*
Revision History:

        May-26-1988  Initial release of this method.
	Dec-12-1988  Free groupOis[] before return.
*/

/*======================================================*/
/* This method sends all my objects the input message.  */
/* If classlist is not null, only objects of class type */
/* specified in classlist are sent the message.         */
/*======================================================*/

method pass(OM_p_MESSAGE msg; OM_p_CLASSLIST classlist; OM_E_WRT_FLAG flag)
{
 OM_p_OBJID groupOids;
 int i, maxGroupCnt, startCnt=0;
 OMuint sts;

 /*=================================================*/
 /* insure that the message to be passed is NOT the */
 /* SupGroup, Group  or an ObjSpace pass method     */
 /*=================================================*/

 if (((msg->select.DefClassid == OM_K_OMGROUP_ACTCLASSID) &&
     (msg->select.FuncIndex  == (OMuword) OMGroup_OPP_pass_method_index)) ||
     ((msg->select.DefClassid == OM_K_OMOBJSPACE_ACTCLASSID) &&
     (msg->select.FuncIndex  == (OMuword) OMObjSpace_OPP_pass_method_index)) ||
     ((msg->select.DefClassid == OM_K_OMSUPGROUP_ACTCLASSID) &&
     (msg->select.FuncIndex  == OMSupGroup_OPP_pass_method_index)))
   return(OM_E_NOPASSPASS);

  /* The total number of groups in the current OS */
  maxGroupCnt = OM_Gp_CurOSD->OSCO_list[OM_K_OMGROUP_ACTCLASSID]->i_refcnt;
  groupOids = (OM_p_OBJID) om$malloc(size=sizeof(OM_S_OBJID)*maxGroupCnt);
  if (!groupOids){
    return(OM_E_NODYNMEM);
  }

 /* call om$get_channel_objects to get a list of object linkages, 
    identify every object on the list, for every super-group object
    repeat the above operation until a group object is met, and store
    the oid of the group into groupOids list */

 if (!(1&(sts=OMSupGroup_get_group_oids(my_id, groupOids, &startCnt)))){
   om$dealloc(ptr=(char *) groupOids);
   return(sts);
 }

 for (i=0; i<startCnt; i++){
   sts = om$send(msg=message OMGroup.pass(msg, classlist, flag),
               targetid=groupOids[i]);

   if (!(1&sts) && sts != OM_W_UNKNOWN_MSG){
     om$dealloc(ptr=(char *) groupOids);
     return(sts);
   }
 }

 om$dealloc(ptr=(char *) groupOids);
 return(OM_S_SUCCESS);
}


int OMSupGroup_get_group_oids(parentOid, groupOids, keepCnt)

OM_S_OBJID parentOid;
OM_p_OBJID groupOids;
int        *keepCnt;
{
 OM_S_CHANSELECT parentCs, cs_fr;
 int search; 
 OMuint sts, chanCnt, objCnt, relIndex;
 int i, kk, duplicate;
 OM_p_OBJECT_LINKAGE objLinkages;
  
 parentCs.type = OM_e_name;
 parentCs.u_sel.name = "OMSupGroup.to_child";
 if (!(1&(sts=om$get_channel_count(objid=parentOid, p_chanselect=&parentCs, count=&chanCnt))))
   return(sts);

 objLinkages = (OM_p_OBJECT_LINKAGE) om$malloc(size=sizeof(OM_S_OBJECT_LINKAGE)*chanCnt);
 if (!objLinkages){
   return(OM_E_NODYNMEM);
 }
  
 if (!(1&(sts=om$get_channel_objects(objid=parentOid, p_chanselect=&parentCs,
     list=objLinkages, size=chanCnt, count=&objCnt)))){
   om$dealloc(ptr=(char *) objLinkages);
   return(sts);
 }

 for (i=0; i < (int) objCnt; i++){
   cs_fr.type = OM_e_num;
   cs_fr.u_sel.number = objLinkages[i].channum;
   if (!(1&(sts=om$get_index(objid_c=objLinkages[i].S_objid,
         p_chanselect=&cs_fr, objid=parentOid, indexaddr=&relIndex)))){
     om$dealloc(ptr=(char *) objLinkages);
     return(sts);
   }

   if (!relIndex) 
     search = 1;    
   else
     search = 0;

   sts=om$is_ancestry_valid(subclassid=OM_Gp_CurSpaceMap[objLinkages[i].S_objid].p_acld->w_classid, superclassid=OM_K_OMSUPGROUP_ACTCLASSID);
   if (!(1&sts)){
      om$dealloc(ptr=(char *) objLinkages);
      return(sts);
   }

   if (sts == OM_S_SUCCESS){
     if (!(1&(sts=OMSupGroup_get_group_oids(objLinkages[i].S_objid,
		  			groupOids, keepCnt)))){
       om$dealloc(ptr=(char *) objLinkages);
       return(sts);
     }
   }	/* if a SuperGroup */
   else{
     duplicate = 0;
     if (search){
       for (kk=0; kk<*keepCnt; kk++){
	 if (objLinkages[i].S_objid == groupOids[kk]){
           duplicate = 1;
           break;
         }
       }
     }
     if (!duplicate){
       groupOids[*keepCnt] = objLinkages[i].S_objid;
       (*keepCnt)++;
     }
   }	/* else for a Group */
 }	/* for */

 om$dealloc(ptr=(char *) objLinkages);
 return(OM_S_SUCCESS);
}

end implementation OMSupGroup;
