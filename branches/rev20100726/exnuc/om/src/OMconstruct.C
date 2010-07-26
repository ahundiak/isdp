/*
---------------------------------------------------------------------------

	Name:			OMconstruct.c
	Author:			Chuck Puckett
	Creation Date:		24-aug-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	This file contains the construct routines. It was originally part
	of OMsupport.c

	Revision History:  

	cgp001	21-apr-1986	OM3.2 mods. Fix bug in construct object
				so that we detect and fixup any modified VLA
				that may have been modified in construct
				routine. Also,  make OM_delete_object
				ALWAYS succeed.

	plh001  21-apr-1986	OM3.2. Copy_me now works for objects with
				expanded VLAs.

	jkm001  24-jun-1986	Put all the construct stuff into OMconstruct.c 

        ems001  10-jul-1986     4.0 mods

        ems002  01-aug-1986     Changed construct to take a message as an
                                 argument instead of a construct function

	rme001	05-may-1987	Removed calls to vla collapse

	geo001  11-may-1987	Add restricted channel handling to
				cleanout_channels and construct_and_copy

        ems003  21-may-1987     Remove make_message calls.

        ems004  01-oct-1987     Remove cleanout channel code for 4.4.0

	geo002	03-dec-1987	Cluster changes for OM4.5
---------------------------------------------------------------------------
*/

#include        "OMobjectcomm.h"
#include        "OMspecify.h"
#include        "OMrelation.h"
#include        "OMintprims.h"
#include 	"OMmetaclass.h"
#include        "OMcluster.h"
#include 	"OMindex.h"
#include 	"OMDB.h"
#include 	"OMrtreedef.h"

extern OMuword  OMOSCO_OPP_initialize_method_index;
extern OMuword  OMGroup_OPP_get_oid_method_index;
extern OMuword  OMCluster_OPP_init_OMCluster_method_index;
extern OMuword  Root_OPP_delete_method_index;

int	OM_construct_validate_count=0;
int	OM_constructcopy_validate_count=0;


/*
------------- Function Description --------------------------------------------

  Function name:    som_construct_object (classname, classid, objid, p_object,
                                           obj_osnum, osnum, osname, p_objid,
                                           msg, neighbor, p_tag )

  Input arguments:
		    char           *classname Class of object to construct
                    OMuword        classid    Class id of object to be 
                                                constructed.
                    OM_S_OBJID     objid      Object id if constructing by
                                                objid.
                    OM_p_OBJECTHDR p_object   Pointer to object if constructing
                                                by object.
                    OMuword        obj_osnum  OS number of objid or p_object
                    OMuword        osnum      OS number to construct new
                                                object in.
                    char           *osname    OS name to construct new object 
                                                in.
                    OM_p_MESSAGE   msg        Initializer message to be sent
                                                to new object.  NULL_MESSAGE
                                                may be used.
                    OM_S_NEIGHBOR  neighbor   Neighbor structure to tell group
                                                and cluster to construct the
                                                new object in.          

                    OMuint         *p_tag     Pointer to store objects tag


  Output arguments: OM_p_OBJID     p_objid    Pointer to objid to put new
                                                object id in.

                    OMuint         *p_tag     Pointer to tag to store the
                                                object's tag.

    The function som_construct_object will allocate virtual memory for an
  object of a given class.  All internal initialization for the new object
  will be acomplished by this function.  In addition to the internal 
  initialization,  a user defined initializer message may also be specified
  to be automatically sent to the new object by this function.  After the
  object is constructed,  all channels are empty.

------------- Revision History ------------------------------------------------

cgp001	11-nov-1985	removed references to ACLD. Include OS number. Add 
			"neighbor" objid to call.

ems001  10-jul-1986     4.0 mods

ems002  01-aug-1986     Changed construct to take a message as an
                         argument instead of a construct function

rme001  6-april-1987    Added p_tag argument and call to add_tag.

ems003  20-apr-1987     Added code to check if the object is still valid
                         before calling om$delete_object if the init msg fails

ems004  28-apr-1987     Added fix to update the address of the OSCO after
                         constructing an OSCO

geo001	02-feb-1988	Changes for 4.5 cluster/swapping and data 
			 structures associated
-------------------------------------------------------------------------------
*/

int som_construct_object (
char               *classname,
OMuword            classid,
OM_S_OBJID         objid,
OM_p_OBJECTHDR     p_object,
OMuword            obj_osnum,
OMuword            osnum,
char               *osname,
OM_p_OBJID         p_objid,
OM_p_MESSAGE       msg,
OM_S_NEIGHBOR      neighbor,
OMuint             *p_tag)
{
   int             sts, sts2;
   OMuint          my_tag;
   OM_S_OBJID      group_oid;
   OM_p_CLASSDEF   p_ACLD;
   OM_p_OBJECTHDR  p_new_instance;
   OM_p_SPAMAPENT  p_spacemap;
   OM_S_OBJID      OSCO_objid;
   OM_S_MESSAGE    OSCO_init_msg;
   OM_S_MESSAGE    getoid_msg;
   OMuword	   sdi;
   int             tag_info=0;

   struct OM_sd_init_args {
                            OM_p_CLASSDEF p_acld;
                            int           init_cnt;
                          } init_args;

   struct OM_sd_getoid_args {
                              OM_p_OBJID    p_objid;
                              OM_p_NEIGHBOR p_neighbor;
                            } getoid_args;

   /*====================================================*/
   /*  if osname was specified then convert it to osnum  */
   /*====================================================*/

   if ( osname != NULL )
   {
      if (!(1&(sts=om$os_name_to_number(osname=osname, p_osnum=&osnum))))
      {
         return (sts);
      }
   }

   /*============================================*/
   /*  if classname was given then transform it  */
   /*============================================*/

   if ( classname != NULL )
   {
      if (!(1&(sts = om$get_class (classname=classname, p_classid=&classid,
                                   pp_cld=&p_ACLD))))
      {
         return (sts);
      }
   }
   else if ( classid != OM_K_NOTUSING_CLASSID )
   {
      if (NULL==(p_ACLD=OM_GA_active_classes[classid]))
      {
         return (OM_E_NOSUCHCLASS);
      }
   }
   else if ( objid != NULL_OBJID )
   {
      if (!(1&(sts = om$get_class(osnum=obj_osnum, objid=objid,
                                  p_classid=&classid, pp_cld=&p_ACLD))))
      {
         return (sts);
      }
   }
   else if ( p_object != NULL )
   {
      if (!(1&(sts = om$get_class(osnum=obj_osnum, object=p_object,
                                  p_classid=&classid, pp_cld=&p_ACLD))))
      {
         return (sts);
      }                                      
   }
   else
   {
      return (OM_E_INVARG);
   }

   /*===============================================================*/
   /*  do not let anyone construct an instance of Root or ObjSpace  */
   /*===============================================================*/

   if ((classid == OM_K_ROOT_ACTCLASSID) || 
       (classid == OM_K_OMOBJSPACE_ACTCLASSID) ||
       (OM_I_INVANCESTRY != om$is_ancestry_valid(subclassid=classid,
                                superclassid=OM_K_OMOBJSPACE_ACTCLASSID)))
   {
      return (OM_E_BADCLASSNAME);  
   }

#ifdef DEBUG
  printf ("CONSTRUCT - enter for class %s in osnum %d\n",p_ACLD->s_name,osnum);

  if ( classid == OM_K_OMOSCO_ACTCLASSID )
  {
    printf ("CONSTRUCT - constructing OSCO for class %s\n",
           ((OM_p_CLASSDEF)*(int *)msg->p_arglist)->s_name);
  }
#endif

   /*=========================*/
   /*  check for valid osnum  */
   /*=========================*/

   if ((OM_Gw_maxOS < osnum) || (NULL == OM_GA_OSDs[osnum]))
   {
      return (OM_E_NOSUCHOS);
   }

   /*=========================================================*/
   /*  determine if an OSCO exists for the class of object    */
   /*  note: on boot-up check if constructing the OSCO OSCO   */
   /*      or the Root OSCO and bypass the OSCO check if so.  */
   /*      This is because FiledOSi.I calls om$construct for  */
   /*      the MOSDOS OSCO and TransOSi.I calls om$construct  */
   /*      for the TransOS OSCO                               */
   /*=========================================================*/

   if ((classid != OM_K_OMOSCO_ACTCLASSID) ||
      ((((OM_p_CLASSDEF)*(int *)msg->p_arglist)->w_classid !=
                                             OM_K_ROOT_ACTCLASSID) &&
      (((OM_p_CLASSDEF)*(int *)msg->p_arglist)->w_classid != 
                                             OM_K_OMOSCO_ACTCLASSID)))
   {
      if ( OM_GA_OSDs[osnum]->OSCO_list[classid] == NULL )
      {
	OM_S_NEIGHBOR	neighbor;

         OSCO_init_msg.select.DefClassid = OM_K_OMOSCO_ACTCLASSID;
         OSCO_init_msg.select.ReqClassid = OM_K_OMOSCO_ACTCLASSID;
         OSCO_init_msg.select.FuncIndex  = OMOSCO_OPP_initialize_method_index;
         OSCO_init_msg.size              = sizeof(struct OM_sd_init_args);
         OSCO_init_msg.p_arglist         = (char *) &init_args;

         init_args.p_acld   = p_ACLD;
         init_args.init_cnt = 1;

#ifdef DEBUG
  printf ("CONSTRUCT - issuing OSCO construct for class %s\n",p_ACLD->s_name);
#endif

	 neighbor.clusterid = 0;
	 neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;
         if (!(1&(sts = om$construct (classid=OM_K_OMOSCO_ACTCLASSID,
				      neighbor=neighbor,
                                      osnum=osnum,
                                      p_objid=&OSCO_objid,
                                      msg=&OSCO_init_msg))))
         {
            return (sts);
         }
         OM_GA_OSDs[osnum]->OSCO_list[classid] = (OM_p_OSCO)
           ((int)OM_GA_OSDs[osnum]->Spacemap[OSCO_objid].state.object + 
           sizeof(OM_S_OBJECTHDR));
      }
      else
      {
         OM_GA_OSDs[osnum]->OSCO_list[classid]->i_refcnt++;
      }
   }
   
   /*=======================================================*/
   /*  if constructing an instance of OMGroup or OMCluster  */
   /*  then force it to be in Group zero, Cluster zero      */
   /*=======================================================*/

   if ( (classid == OM_K_OMGROUP_ACTCLASSID) ||
        (classid == OM_K_OMCLUSTER_ACTCLASSID) ||
        (om$is_ancestry_valid(subclassid=classid,
         superclassid=OM_K_OMGROUP_ACTCLASSID) != OM_I_INVANCESTRY) ||
        (om$is_ancestry_valid(subclassid=classid,
         superclassid=OM_K_OMCLUSTER_ACTCLASSID) != OM_I_INVANCESTRY))
   {
      neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;
      neighbor.clusterid = 0;
   }

   /*====================================*/
   /*  determine group to put object in  */
   /*====================================*/

   if ( IF_NULL_OBJID(neighbor.groupid) )
   {
      group_oid = OM_GA_OSDs[osnum]->Group0_Oid;
   }
   else
   {
      group_oid = neighbor.groupid;
   }

   /*================================================*/
   /*  send a "get_oid" message to the group object  */
   /*================================================*/

   getoid_msg.select.DefClassid = OM_K_OMGROUP_ACTCLASSID;
   getoid_msg.select.ReqClassid = OM_K_OMGROUP_ACTCLASSID;
   getoid_msg.select.FuncIndex  = OMGroup_OPP_get_oid_method_index;
   getoid_msg.size              = sizeof(struct OM_sd_getoid_args);
   getoid_msg.p_arglist         = (char *)&getoid_args;

   getoid_args.p_objid = p_objid;
   getoid_args.p_neighbor = &neighbor;

   if (!(1&(sts = om$send ( msg=&getoid_msg, senderid=group_oid, 
                            targetid=group_oid, targetos=osnum ))))
   {
      OM_GA_OSDs[osnum]->OSCO_list[classid]->i_refcnt--;
      return (sts);
   }

#ifdef DEBUG
  printf ("CONSTRUCT - oid for new object is %d size is %d\n", *p_objid,p_ACLD->initial_size);
#endif


   /*=======================*/
   /*  allocate the object  */
   /*=======================*/

   if (!(1&(sts = om$object_alloc (p_osd=OM_GA_OSDs[osnum], neighbor=neighbor,
			size=p_ACLD->initial_size, object= &p_new_instance,
			sdi=&sdi))))
   {
#ifdef DEBUG
  printf ("CONSTRUCT - error returned from object_alloc %x\n",sts);
  om$report_error(sts=sts);
#endif
      OM_FREE_OBJID ( *p_objid, osnum );
      OM_GA_OSDs[osnum]->OSCO_list[classid]->i_refcnt--;
      return (sts);
   }

#ifdef DEBUG
  printf ("CONSTRUCT - allocated space %d bytes at address %x\n",
		 p_ACLD->initial_size, p_new_instance);
#endif

   /*=============================================================*/
   /*  get pointer to spacemap based on objid and init the entry  */
   /*=============================================================*/

   p_spacemap = &OM_GA_OSDs[osnum]->Spacemap[(*p_objid)];

   p_spacemap->state.object = p_new_instance;
   p_spacemap->p_acld       = p_ACLD;
   p_spacemap->flags        = (OM_SM_in_use | OM_SM_in_mem);
   p_spacemap->sdi	    = sdi;

   /*======================*/
   /*  init object header  */
   /*======================*/

   p_new_instance->oid = *p_objid;

   /*=============================================================*/
   /*  When class has vlas: set bit in size field & init VLAs.    */
   /*  the lower 3 bits of objhdr size are assumed to be zero     */
   /*  since all objects must be of quad word size                */
   /*=============================================================*/

   if ( p_ACLD->w_num_varlenarrays != 0 )
   {
      if (!(1&(sts = om$vla_initialize_offsets (p_cld=p_ACLD, 
                                                object=p_new_instance))))
      {
         om$delete_object (osnum=osnum, object=p_new_instance,
                           objid=(*p_objid));
         return (sts);
      }
   }

   /*--------------------------------------------*/
   /*  Check to see if object should be tagged.  */
   /*--------------------------------------------*/

   if (OM_Gf_tagging_enabled && (p_ACLD->flags & OM_CLDf_TAGGABLE))
   {
      if (!(1&(sts = om$add_tag(osnum = osnum,
                                object = p_new_instance,
                                objid = (*p_objid),
                                p_tag = &my_tag ) )))
         return (sts);
      if ( p_tag ) *p_tag = my_tag;
   }
   else
   {
      if ( p_tag ) tag_info = 1;
   }

   /*=================================================*/
   /*  check if an initializer message was specified  */
   /*=================================================*/

   if ( msg != OM_Gp_NULL_MESSAGE  ||
       (msg->select.DefClassid != OM_Gp_NULL_MESSAGE->select.DefClassid) ||
       (msg->select.ReqClassid != OM_Gp_NULL_MESSAGE->select.ReqClassid) ||
       (msg->select.FuncIndex != OM_Gp_NULL_MESSAGE->select.FuncIndex) ||
       (msg->size != OM_Gp_NULL_MESSAGE->size) ||
       (msg->p_arglist != OM_Gp_NULL_MESSAGE->p_arglist))
   {

#ifdef DEBUG
  printf ("CONSTRUCT - sending initialize message to new objid %d\n",*p_objid);
#endif

      sts = om$send ( msg=msg, senderid=*p_objid, targetid=*p_objid, 
                      targetos=osnum );
      if (!(1&sts))
      {
         if (1&(sts2 = om$is_objid_valid(osnum=osnum, objid=(*p_objid))))
         {
            om$delete_object (osnum=osnum, object=p_new_instance,
                              objid=(*p_objid));
         }
      }
   }
   else
   {
      sts = OM_S_SUCCESS;
   }

#ifdef DEBUG
  printf ("CONSTRUCT - _exit for class %s in osnum %d\n",p_ACLD->s_name,osnum);
#endif

   if ((sts == OM_S_SUCCESS) && tag_info ) return (OM_I_OBJNOTTAGGED);

   return (sts);
}


/*
------------- Function Description --------------------------------------------

  Function name:    som_construct_and_copy (p_object, objid, obj_osnum, osnum,
                                             osname, neighbor, p_objid, p_tag )

  Input arguments:
                    OM_p_OBJECTHDR p_object  Pointer to object to copy.
		    OM_S_OBJID     objid     Object id of object to copy.
                    OMuword        obj_osnum OS number of objid or p_object.
                    OMuword        osnum     OS number to construct new copy in
                    char           *osname   OS name to construct new copy in.
                    OM_S_NEIGHBOR  neighbor  Neighbor to specify group and/or
                                               cluster to construct in.
                    OMuint         *p_tag    Pointer to store object's tag.

  Output arguments: OM_p_OBJID     p_objid   Pointer to objid to contain the
                                               newly constructed object id.

                    OMuint         *p_tag    Pointer to the object's tag

  The function takes as input either an (objid/obj_osnum) or an 
  (p_object/obj_osnum) pair and constructs a copy of that object in the
  specified object space.  All channels in the new copy will be cleaned 
  out.

------------- Revision History ------------------------------------------------

	rme001	05-may-1987	Removed call to vla collapse

-------------------------------------------------------------------------------
*/

int som_construct_and_copy (
OM_p_OBJECTHDR			p_object,
OM_S_OBJID                      objid,
OMuword                         obj_osnum,
OMuword				osnum,
char                            *osname,
OM_S_NEIGHBOR                   neighbor,
OM_p_OBJID			p_objid,
OMuint                          *p_tag)

{
   int                          sts;
   OMuint                       my_tag;
   OMuint                       new_size;
   OMuint                       fixed_size;
   OMuword                      classid;
   OM_p_CLASSDEF                p_ACLD;
   OM_S_RIP                     rip;
   OM_S_OBJID                   group_oid;
   OM_S_MESSAGE                 getoid_msg;
   OM_p_OBJECTHDR               p_new_instance;
   OM_p_SPAMAPENT               p_spacemap;
   OM_S_OBJID                   OSCO_objid;
   OM_S_MESSAGE                 OSCO_init_msg;
   int                          i, j;
   int                          collapse_needed;
   OMuword			sdi;
   OM_p_MSGMAP                  p_msgmap;
   int                         *p_chan_ptr;
   OM_p_CHANNEL_DEFN            p_chandef;
   OM_S_CONNECT_SIDE            side;

   struct OM_sd_init_args {
                            OM_p_CLASSDEF p_acld;
                            int           init_cnt;
                          } init_args;

   struct OM_sd_getoid_args {
                              OM_p_OBJID    p_objid;
                              OM_p_NEIGHBOR p_neighbor;
                            } getoid_args;

   /*============================================*/
   /*  determine if objid or instance was input  */
   /*============================================*/

   if ( p_object != NULL )
   {
      if (!(1&(sts = om$get_class (osnum=obj_osnum, object=p_object, 
                                   p_classid=&classid, pp_cld=&p_ACLD))))
      {
         return (sts);
      }
      objid = p_object->oid;
   }
   else if ( objid != NULL_OBJID )
   {
      if (!(1&(sts = om$get_class (osnum=obj_osnum, objid=objid,
                                   p_classid=&classid, pp_cld=&p_ACLD))))
      {
         return (sts);
      }

      if (!(1&(sts = om$get_any_instance (osnum=obj_osnum, objid=objid,
                                          p_rip=&rip))))
      {
         return (sts);
      }
      p_object = rip.p_object;
   }
   else
      return (OM_E_INVARG);

   /*=============================*/
   /*  check if osname was input  */
   /*=============================*/

   if ( osname )
      if (!(1&(sts = om$os_name_to_number(osname=osname, p_osnum=&osnum))))
         return (sts);

   /*======================================================*/
   /*  do not let anyone construct an OSCO object by copy  */
   /*======================================================*/

   if ((classid == OM_K_OMOSCO_ACTCLASSID) ||
       (om$is_ancestry_valid(subclassid=classid,
              superclassid=OM_K_OMOSCO_ACTCLASSID) != OM_I_INVANCESTRY))
      return (OM_E_BADCLASSNAME);

   /*===============================================================*/
   /*  do not let anyone construct an instance of Root or ObjSpace  */
   /*===============================================================*/

   if ((classid == OM_K_ROOT_ACTCLASSID) || 
       (classid == OM_K_OMOBJSPACE_ACTCLASSID) ||
       (OM_I_INVANCESTRY != om$is_ancestry_valid(subclassid=classid,
                                superclassid=OM_K_OMOBJSPACE_ACTCLASSID)))
      return (OM_E_BADCLASSNAME);  

   /*=========================*/
   /*  check for valid osnum  */
   /*=========================*/

   if ((OM_Gw_maxOS < osnum) || (0 == OM_GA_OSDs[osnum]))
      return (OM_E_NOSUCHOS);

   /*========================================*/
   /*  determine size of object to allocate  */
   /*========================================*/

   if ( OM_OBJ_HAS_VLA(p_object->i_size) )
   {
      if (!(1&(sts = om$vla_get_size_of_object(object=p_object, 
                                               p_cld=p_ACLD, 
                                               p_fixed_size=(int *) &fixed_size,
                                               p_total_size=(int *) &new_size))))
         return (sts);
   }
   else
   {
      new_size = OM_GETOBJSIZE(p_object->i_size);
      fixed_size = new_size;
   }

   /*=======================================================*/
   /*  determine if an OSCO exists for the class of object  */
   /*=======================================================*/

   if ( OM_GA_OSDs[osnum]->OSCO_list[classid] == NULL )
   {
      OM_S_NEIGHBOR	neighbor;

      OSCO_init_msg.select.DefClassid = OM_K_OMOSCO_ACTCLASSID;
      OSCO_init_msg.select.ReqClassid = OM_K_OMOSCO_ACTCLASSID;
      OSCO_init_msg.select.FuncIndex  = OMOSCO_OPP_initialize_method_index;
      OSCO_init_msg.size              = sizeof(struct OM_sd_init_args);
      OSCO_init_msg.p_arglist         = (char *) &init_args;

      init_args.p_acld   = p_ACLD;
      init_args.init_cnt = 1;

#ifdef DEBUG
  printf ("CONSTRUCT - issuing OSCO construct for class %s\n",p_ACLD->s_name);
#endif

      neighbor.clusterid = 0;
      neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;
      if (!(1&(sts = om$construct (classid=OM_K_OMOSCO_ACTCLASSID,
				   neighbor=neighbor,
                                   osnum=osnum,
                                   p_objid=&OSCO_objid,
                                   msg=&OSCO_init_msg))))
         return (sts);
      OM_GA_OSDs[osnum]->OSCO_list[classid] = (OM_p_OSCO)
           ((int)OM_GA_OSDs[osnum]->Spacemap[OSCO_objid].state.object + 
           sizeof(OM_S_OBJECTHDR));
   }
   else
   {
      OM_GA_OSDs[osnum]->OSCO_list[classid]->i_refcnt++;
   }
   
   /*=======================================================*/
   /*  if constructing an instance of OMGroup or OMCluster  */
   /*  then force it to be in Group zero, Cluster zero      */
   /*=======================================================*/

   if ( (classid == OM_K_OMGROUP_ACTCLASSID) ||
        (classid == OM_K_OMCLUSTER_ACTCLASSID) ||
        (om$is_ancestry_valid(subclassid=classid,
         superclassid=OM_K_OMGROUP_ACTCLASSID) != OM_I_INVANCESTRY) ||
        (om$is_ancestry_valid(subclassid=classid,
         superclassid=OM_K_OMCLUSTER_ACTCLASSID) != OM_I_INVANCESTRY))
   {
      neighbor.groupid = OM_GS_NULL_NEIGHBOR.groupid;
      neighbor.clusterid = 0;
   }

   /*====================================*/
   /*  determine group to put object in  */
   /*====================================*/

   if ( IF_NULL_OBJID(neighbor.groupid) )
   {
      group_oid = OM_GA_OSDs[osnum]->Group0_Oid;
   }
   else
   {
      group_oid = neighbor.groupid;
   }

   /*================================================*/
   /*  send a "get_oid" message to the group object  */
   /*================================================*/

   getoid_msg.select.DefClassid = OM_K_OMGROUP_ACTCLASSID;
   getoid_msg.select.ReqClassid = OM_K_OMGROUP_ACTCLASSID;
   getoid_msg.select.FuncIndex  = OMGroup_OPP_get_oid_method_index;
   getoid_msg.size              = sizeof(struct OM_sd_getoid_args);
   getoid_msg.p_arglist         = (char *)&getoid_args;

   getoid_args.p_objid = p_objid;
   getoid_args.p_neighbor = &neighbor;

   if (!(1&(sts = om$send ( msg=&getoid_msg, senderid=group_oid, 
                            targetid=group_oid, targetos=osnum ))))
   {
      OM_GA_OSDs[osnum]->OSCO_list[classid]->i_refcnt--;
      return (sts);
   }

   /*=======================*/
   /*  allocate the object  */
   /*=======================*/

   if (!(1&(sts = om$object_alloc ( p_osd=OM_GA_OSDs[osnum],neighbor=neighbor,
				size =  new_size, object = &p_new_instance,
				sdi = &sdi ))))
   {
      OM_FREE_OBJID ( *p_objid, osnum );
      OM_GA_OSDs[osnum]->OSCO_list[classid]->i_refcnt--;
      return (sts);
   }

   /*================================================*/
   /*  copy the fixed portion of object to new copy  */
   /*================================================*/

   new_size = OM_GETOBJSIZE(p_new_instance->i_size);

   /* Our original object may have moved in memory due to a compress
    * pcd during object alloc.  Get a fresh pointer to the object.
    */

   if (!(1&(sts = om$get_any_instance (osnum=obj_osnum, objid=objid,
                                       p_rip=&rip))))
   {
      return (sts);
   }
   p_object = rip.p_object;
   OM_BLOCK_MOVE ( (OMuint)p_object+sizeof(OM_S_OBJECTHDR), 
                   (OMuint)p_new_instance+sizeof(OM_S_OBJECTHDR), 
                   fixed_size-sizeof(OM_S_OBJECTHDR) );

   /*=============================================================*/
   /*  get pointer to spacemap based on objid and init the entry  */
   /*=============================================================*/

   p_spacemap = &OM_GA_OSDs[osnum]->Spacemap[(*p_objid)];

   p_spacemap->state.object  = p_new_instance;
   p_spacemap->p_acld        = p_ACLD;
   p_spacemap->flags         = (OM_SM_in_use | OM_SM_in_mem);
   p_spacemap->sdi	     = sdi;
   p_new_instance->i_size    = new_size;
   p_new_instance->oid       = *p_objid;

   /*==========================================================*/
   /*  copy the variable length portion of object to new copy  */
   /*==========================================================*/

   if ( OM_OBJ_HAS_VLA(p_object->i_size) )
   {
      OM_SET_OBJ_HAS_VLA(p_new_instance->i_size)
      collapse_needed = 0;

      if (!(1&(sts = om$vla_collapse_copy ( p_orig_object=p_object, 
                                            p_copy=p_new_instance, 
                                            p_spacemap=p_spacemap, 
                                            p_cld=p_ACLD ))))
      {
         om$delete_object ( osnum=osnum, object=p_new_instance,
                            objid=(*p_objid) );
         return (sts);
      }      

   }

   /*=================================================*/
   /*  zero out the channel pointers in the new copy  */
   /*=================================================*/

   /*============================*/
   /*  loop thru classmap array  */
   /*============================*/

   side.osnum = osnum;
   side.objid = *p_objid;
   side.p_cld = p_ACLD;
   
   p_msgmap = p_ACLD->MsgMap;
   for ( i=0; (OMuword) i<p_ACLD->NumMsgClasses; i++, p_msgmap++ )
   {
      /*======================================================*/
      /*  for each class - loop thru its channel definitions  */
      /*======================================================*/

      p_chandef = p_msgmap->ChanDefns;
      for ( j=0; (OMuword) j<p_msgmap->NumChan; j++, p_chandef++ )
      {
         p_chan_ptr = (int *)((char *)p_new_instance + p_msgmap->offset +
                                 p_chandef->i_offset);

         if ((p_chandef->p_type->w_flags & CD_restricted) &&
             (p_chandef->p_type->w_flags & (CD_1_1|CD_m_1))) {
            *p_chan_ptr = 0;
            continue;
         }

         if ( *p_chan_ptr )
         {
            side.chdef   = p_chandef;
            side.pp_chan = (OM_p_CHANNEL_HDR *) p_chan_ptr;
            sts = om$connect_chan_alloc ( side1 = &side, num_ents = 0 );
            if (!(1&sts))
            {
               om$delete_object ( osnum=osnum, object=p_new_instance,
                                  objid=(*p_objid) );
               return (sts);
            }
            *p_chan_ptr = 0;
         }
      }  
   }

   /*--------------------------------------------*/
   /*  Check to see if object should be tagged.  */
   /*--------------------------------------------*/

   if ( OM_Gf_tagging_enabled && (p_ACLD->flags & OM_CLDf_TAGGABLE))
   {
      if (!(1&(sts = om$add_tag(osnum = osnum,
                                object = p_new_instance,
                                objid = (*p_objid),
                                p_tag = &my_tag ) )))
         return (sts);
      if ( p_tag ) *p_tag = my_tag;
   }
   else
      if ( p_tag ) return (OM_I_OBJNOTTAGGED);

   return (OM_S_SUCCESS);
}
