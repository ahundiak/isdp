/*
----------------------------------------------------------

  Name:                OMobjid.C
  Author:              Ed Sieja
  Date:                10-jul-1986
  Operating system:    Unix SYSV, v2.4

  Functions:           som_get_instance
                       som_get_any_instance
                       som_is_objid_valid
                       som_get_senddepth

----------------------------------------------------------
*/

#include   "OMobjectcomm.h"
#include   "OMspecify.h"
#include   "OMrelation.h"
#include   "OMintprims.h"
#include   "OMmetaclass.h"

extern  OMuword  OMCluster_OPP_fault_method_index;


/*
------------- Revision History ------------------------------------------------

ems001  21-may-1987  Removed make_message calls.

geo001	10-dec-1987  OM4.5 clustering changes.
-------------------------------------------------------------------------------

------------- Function Description --------------------------------------------

  Function name:    som_get_instance ( p_rip, objid )
 

  Input arguments:  OM_S_OBJID  objid     Object id to convert

  Output arguments: OM_p_RIP    p_rip     Pointer to rip structure to be
                                            filled in.

    Given an object id, assume it is in the current OS and fill in the 
  resultant instance pointer (RIP).  If the object is in a cluster that 
  has not been faulted into virtual memory,  then the entire cluster is
  faulted in.
-------------------------------------------------------------------------------
*/

int som_get_instance ( p_rip, objid )

OM_S_OBJID    objid;
OM_p_RIP      p_rip;
{
   int           sts;
   OM_S_MESSAGE  fault_msg;
   int		 *fp=NULL;
   OM_S_OBJID    cluster_oid;

#ifdef DEBUG
printf("get_instance called with objid %d and p_rip %X\n",objid,p_rip);
printf("dump of current osd: \n");
dump_osd(OM_Gp_CurOSD);
#endif

   if ((IF_NULL_OBJID(objid)) || (objid >= OM_Gp_CurOSD->CurSpaceMapSize)) 
   { 
      return (OM_E_NOSUCHOBJ);
   } 
   else 
   { 
      p_rip->p_mapentry = &OM_Gp_CurSpaceMap[objid];

#ifdef DEBUG 
printf("found spacemap entry as follows: \n");
dump_space(1,p_rip->p_mapentry);
#endif

      /*=====================================*/
      /*  check if spacemap entry is in use  */
      /*=====================================*/

      if ( !(OM_OBJ_INVALID(p_rip->p_mapentry->flags) ) )
      {
         /*===========================================*/
         /*  check if cluster needs to be faulted in  */
         /*===========================================*/

         if (OM_OBJ_IN_FILE(p_rip->p_mapentry->flags))
         {
            fault_msg.select.DefClassid = OM_K_OMCLUSTER_ACTCLASSID;
            fault_msg.select.ReqClassid = OM_K_OMCLUSTER_ACTCLASSID;
            fault_msg.select.FuncIndex  = OMCluster_OPP_fault_method_index;
            fault_msg.size              = sizeof(int *);
            fault_msg.p_arglist         = (char *) &fp;

            cluster_oid = OM_Gp_CurOSD->Clusters
              [p_rip->p_mapentry->state.filed_obj.clusterid]->oid;

#ifdef DEBUG
 printf ("GET_INSTANCE - sending fault msg to cluster oid = %d\n",cluster_oid);
#endif

            if (!(1&(sts = om$send ( msg=&fault_msg, senderid=cluster_oid,
                                     targetid=cluster_oid ))))
            {
               return (sts);
            }
         }

         p_rip->p_object = p_rip->p_mapentry->state.object;
#ifdef DEBUG
printf("Leaving get_instance. object found \n");
#endif

         return (OM_S_SUCCESS);
      }
#ifdef DEBUG
printf("Leaving get_instance. object not found \n");
#endif
      return (OM_E_NOSUCHOBJ);
     
   } 
}


/*
------------- Function Description --------------------------------------------

  Function name:    som_get_any_instance ( osnum, objid, p_rip )
 

  Input arguments:  OMuword     osnum     Object space number
                    OM_S_OBJID  objid     Object id to convert

  Output arguments: OM_p_RIP    p_rip     Pointer to rip structure to be
                                            filled in.

    Given an object id and an object space number,  fill in the 
  resultant instance pointer (RIP).  If the object is in a cluster that 
  has not been faulted into virtual memory,  then the entire cluster is
  faulted in.
-------------------------------------------------------------------------------
*/

int som_get_any_instance (
OMuword     OSnum,
OM_S_OBJID  objid,
OM_p_RIP    p_rip)
{
   int            sts;
   OM_p_OSD       p_OSD; 
   OM_S_MESSAGE   fault_msg;
   int		  *fp;
   OM_S_OBJID     cluster_oid;

   if ((OSnum >= OM_Gw_maxOS) || (NULL == (p_OSD = OM_GA_OSDs[OSnum]))) 
   { 
      return (OM_E_NOSUCHOS); 
   } 
   else if ((IF_NULL_OBJID(objid)) || (objid >= p_OSD->CurSpaceMapSize)) 
   { 
      return (OM_E_NOSUCHOBJ); 
   } 
   else 
   { 
      p_rip->p_mapentry = &p_OSD->Spacemap[objid];
      
      /*=====================================*/
      /*  check if spacemap entry is in use  */
      /*=====================================*/

      if ( !(OM_OBJ_INVALID(p_rip->p_mapentry->flags) ) )
      {
         /*===========================================*/
         /*  check if cluster needs to be faulted in  */
         /*===========================================*/

         if (OM_OBJ_IN_FILE(p_rip->p_mapentry->flags))
         {
            fault_msg.select.DefClassid = OM_K_OMCLUSTER_ACTCLASSID;
            fault_msg.select.ReqClassid = OM_K_OMCLUSTER_ACTCLASSID;
            fault_msg.select.FuncIndex  = OMCluster_OPP_fault_method_index;
            fault_msg.size              = sizeof(int *);
            fault_msg.p_arglist         = (char *) &fp;

            cluster_oid = p_OSD->Clusters
              [p_rip->p_mapentry->state.filed_obj.clusterid]->oid;

#ifdef DEBUG
 printf ("GET_ANY_INSTANCE - sending fault msg to cluster oid = %d in OS %d\n",
          cluster_oid, OSnum);
#endif

            if (!(1&(sts = om$send ( msg=&fault_msg, senderid=cluster_oid,
                                     targetid=cluster_oid, targetos=OSnum ))))
            {
               return (sts);
            }
         }

         p_rip->p_object = p_rip->p_mapentry->state.object;

         return (OM_S_SUCCESS);
      }
      return (OM_E_NOSUCHOBJ);
   } 
}



/*
------------- Revision History ------------------------------------------------

-------------------------------------------------------------------------------

------------- Function Description --------------------------------------------

  Function name:    som_is_objid_valid ( osnum, objid )


  Input arguments:  OMuword     osnum    Object space number of objid
                    OM_S_OBJID  objid    Object id to validate.

  Output arguments: None.

  Given an (osnum,objid) pair,  this function will determine whether or not
  the pair is valid.

-------------------------------------------------------------------------------
*/

int som_is_objid_valid ( OMuword OSnum, OM_S_OBJID objid )
{ 
   OM_p_SPAMAPENT  p_mapentry;	
   OM_p_OSD        p_OSD; 

   if ((OSnum >= OM_Gw_maxOS) || (NULL == (p_OSD = OM_GA_OSDs[OSnum]))) 
   { 
      return (OM_E_NOSUCHOS);
   } 
   else if ((IF_NULL_OBJID (objid)) || (objid >= p_OSD->CurSpaceMapSize)) 
   { 
      return (OM_E_NOSUCHOBJ); 
   } 
   else 
   { 
      p_mapentry = &p_OSD->Spacemap[objid]; 

      /*=====================================*/
      /*  check if spacemap entry is in use  */
      /*=====================================*/

      if ( !(OM_OBJ_INVALID(p_mapentry->flags) ) )
      {
         return (OM_S_SUCCESS);
      }
      return (OM_E_NOSUCHOBJ);
   } 
}




/*
------------- Function Description --------------------------------------------

  Function name:    som_get_senddepth ( osnum, objid, p_depth )


  Input arguments:  OMuword     osnum      Object space number of objid.
                    OM_S_OBJID  objid      Object id

  Output arguments: OMuword     *p_depth   Pointer to variable to hold depth.

  Given an (osnum,objid) pair the function will return the send depth
  of the object in the p_depth argument.

-------------------------------------------------------------------------------
*/

int som_get_senddepth ( OMuword osnum, OM_S_OBJID objid, OMuword *p_depth )
{
   int       sts;
   OM_S_RIP  rip;

   if (!(1&(sts = om$get_any_instance ( osnum=osnum, objid=objid,
                                        p_rip=&rip ))))
   {
      return (sts);
   }

   if( rip.p_mapentry->flags & OM_SM_send_depth )
   	*p_depth = TRUE;
   else
   	*p_depth = FALSE;

   om$release_any_instance ( osnum=osnum, rip=rip );

   return (OM_S_SUCCESS);
}
