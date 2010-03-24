/*
-------------------------------------------------------------------------------

	Name:			OMsend.h
	Creation Date:		11-feb-1987
	Operating System(s):	Unix SYSV, v2
	Abstract:

	 This file defines the major portion of the send logic.

	Revision History:

	rme001	05-may-1987	Remove calls to vla collapse
-------------------------------------------------------------------------------
*/

#ifndef	OM_D_SEND
#define	OM_D_SEND

extern OMuword  OMCluster_OPP_fault_method_index;

struct OM_sd_method_cache
{
   OMuword classid;
   int (*p_method)();
};
typedef struct OM_sd_method_cache OM_S_SEND_CACHE;
typedef struct OM_sd_method_cache *OM_p_SEND_CACHE;


#define OM_GET_FUNCTION_PTR(gfp_f,gfp_rip,gfp_p_acld,gfp_wrt_flag,gfp_msg,gfp_senderid,gfp_targetid,gfp_channum,gfp_sts,int_sts,num)\
								\
 {								\
   OM_p_CLASSDEF        p_tmp_ACLD=NULL;				\
   OMbyte               tndx;					\
   OM_S_MESSAGE         Rootunk_msg;				\
   OM_S_MESSAGE  fault_msg;					\
   int		 *fp=NULL;					\
   OM_S_OBJID    cluster_oid, target_oid;			\
   OM_p_ANCESTRY p_ancestry;					\
   OMuword	 target_osnum;					\
   OMuword       map_flags;					\
								\
/* put call to om$get_instance in-line for speed */ 		\
								\
   int_sts = gfp_sts = OM_S_SUCCESS;				\
   if ((IF_NULL_OBJID(gfp_targetid)) || (gfp_targetid >=OM_Gp_CurOSD->CurSpaceMapSize))\
   { 								\
      gfp_sts = (OM_E_NOSUCHOBJ);				\
      goto num##;						\
   } 								\
   gfp_rip.p_mapentry = &OM_Gp_CurSpaceMap[gfp_targetid];	\
   map_flags = gfp_rip.p_mapentry->flags & (OM_SM_in_use|       \
       OM_SM_in_mem|OM_SM_has_msgintrcpt|OM_SM_disable_intrcpt);\
								\
   /*==============================================*/		\
   /*  check if spacemap flag indicates more work  */		\
   /*  bits of flag that divert send from main path */    	\
   /*==============================================*/		\
								\
   if(map_flags != (OM_SM_in_use | OM_SM_in_mem))		\
   {								\
      if( map_flags & OM_SM_has_msgintrcpt) 			\
      {								\
        if ( map_flags & OM_SM_disable_intrcpt )                \
        { /* clear the disable flag */				\
          OM_Gp_CurOSD->Spacemap[gfp_targetid].flags &= ~(OMbyte)OM_SM_disable_intrcpt;\
        }							\
 	else							\
	{							\
  	  if(!(1&(gfp_sts=om$get_intercept(objid=gfp_targetid,	\
		osnum=OM_Gw_current_OS, p_target_objid=&target_oid,\
		p_target_osnum=&target_osnum))))		\
	  {  /* no intercept found so clear bit */		\
            OM_Gp_CurOSD->Spacemap[gfp_targetid].flags &= ~(OMbyte)OM_SM_has_msgintrcpt;\
	    goto num##;					\
	  }						\
	  if(target_osnum != OM_Gw_current_OS)		\
	  {						\
	    if(!(1&(gfp_sts=om$send(msg=gfp_msg,senderid=gfp_senderid,targetid=target_oid,targetos=target_osnum))))\
	    {						\
	      goto num##;				\
	    }						\
	    int_sts = OM_W_WARNING;			\
	    goto num##;  				\
	  }						\
	  gfp_targetid = target_oid;			\
          if ((IF_NULL_OBJID(gfp_targetid)) || 		\
	     (gfp_targetid >=OM_Gp_CurOSD->CurSpaceMapSize))\
          { 						\
            gfp_sts = (OM_E_NOSUCHOBJ);			\
            goto num##;					\
          } 						\
          gfp_rip.p_mapentry = &OM_Gp_CurSpaceMap[gfp_targetid];\
        }						\
        if (!(gfp_rip.p_mapentry->flags & OM_SM_in_use))\
	{						\
         {                                              \
            gfp_sts = OM_E_NOSUCHOBJ;			\
            goto num##;					\
         }                                              \
	}						\
        else	/* in use */				\
        {						\
         if (!(gfp_rip.p_mapentry->flags & OM_SM_in_mem))\
 	 {						\
          fault_msg.select.DefClassid = (OMuword) OM_K_OMCLUSTER_ACTCLASSID; \
          fault_msg.select.ReqClassid = (OMuword) OM_K_OMCLUSTER_ACTCLASSID; \
          fault_msg.select.FuncIndex = OMCluster_OPP_fault_method_index; \
          fault_msg.size = sizeof(int *); \
          fault_msg.p_arglist = (char *) &fp; \
          cluster_oid = OM_Gp_CurOSD->Clusters[gfp_rip.p_mapentry->state.filed_obj.clusterid]->oid;\
								\
								\
          gfp_sts = om$send(msg=&fault_msg,senderid=cluster_oid,targetid=cluster_oid);\
          if (!(gfp_sts&1)) goto num##;               \
         }                                              \
	}						\
      }							\
      /*===========================================*/	\
      /*  check if cluster needs to be faulted in  */	\
      /*===========================================*/	\
							\
      else if ( map_flags == OM_SM_in_use )		\
      {							\
          fault_msg.select.DefClassid = (OMuword) OM_K_OMCLUSTER_ACTCLASSID; \
          fault_msg.select.ReqClassid = (OMuword) OM_K_OMCLUSTER_ACTCLASSID; \
          fault_msg.select.FuncIndex = OMCluster_OPP_fault_method_index; \
          fault_msg.size = sizeof(int *); \
          fault_msg.p_arglist = (char *) &fp; \
          cluster_oid = OM_Gp_CurOSD->Clusters[gfp_rip.p_mapentry->state.filed_obj.clusterid]->oid;\
								\
								\
          gfp_sts = om$send(msg=&fault_msg,senderid=cluster_oid,targetid=cluster_oid);\
          if(!(gfp_sts&1)) goto num##;                          \
      }								\
      else 							\
      {								\
        gfp_sts = OM_E_NOSUCHOBJ;				\
        goto num##;						\
      }								\
   }								\
   gfp_rip.p_object = gfp_rip.p_mapentry->state.object;		\
								\
   /*==========================================*/		\
   /*  get pointer to Active Class Descriptor  */		\
   /*==========================================*/		\
								\
   if( (gfp_rip.p_mapentry->flags & OM_SM_unknown_obj )		\
		|| \
       (NULL == (gfp_p_acld = gfp_rip.p_mapentry->p_acld)) ) 	\
   {								\
      om$release_instance (rip=gfp_rip);			\
      gfp_sts = OM_E_NOSUCHCLASS;				\
      goto num##;						\
   }     							\
                                                                \
   /*================================================*/		\
   /*  check for special case of Root as DefClassid  */		\
   /*================================================*/		\
								\
   if ( gfp_msg->select.DefClassid == (OMuword) OM_K_ROOT_ACTCLASSID )	\
   {								\
      tndx = 0;							\
      switch ( gfp_wrt_flag )					\
      {								\
      case OM_e_wrt_object:					\
        p_tmp_ACLD = gfp_p_acld;				\
        break;							\
								\
      case OM_e_wrt_message:					\
        p_tmp_ACLD = OM_GA_active_classes[gfp_msg->select.ReqClassid];\
        break;							\
								\
      case OM_e_wrt_parent:					\
	p_tmp_ACLD = (OM_p_CLASSDEF) OM_GA_active_classes[gfp_msg->select.ReqClassid];\
	p_ancestry = (OM_p_ANCESTRY) p_tmp_ACLD->A_ancestor_list+(p_tmp_ACLD->w_numparents-1);\
	p_tmp_ACLD = (OM_p_CLASSDEF) OM_GA_active_classes[*(p_ancestry->p_classid)];\
								\
	break;							\
								\
      default:							\
        om$release_instance (rip=gfp_rip);			\
        gfp_sts = OM_E_INVARG;	  			        \
	goto num##;						\
    }								\
   }								\
   else								\
   {								\
      switch ( gfp_wrt_flag )					\
      {								\
      case OM_e_wrt_object:					\
        if ((gfp_msg->select.DefClassid > gfp_p_acld->w_maxclass) \
		||(gfp_msg->select.DefClassid < gfp_p_acld->w_baseclass))\
        {							\
           tndx = (OMbyte) OM_K_NULL_TRANS;				\
        }							\
        else							\
        {							\
           tndx = (OMbyte) gfp_p_acld->p_transmap[gfp_msg->select.DefClassid-gfp_p_acld->w_baseclass];\
           p_tmp_ACLD = gfp_p_acld;				\
        }							\
        break;							\
								\
      case OM_e_wrt_message:					\
        p_tmp_ACLD = OM_GA_active_classes[gfp_msg->select.ReqClassid];\
        if ((gfp_msg->select.DefClassid > p_tmp_ACLD->w_maxclass)  \
         || (gfp_msg->select.DefClassid < p_tmp_ACLD->w_baseclass) \
         || (gfp_msg->select.DefClassid > gfp_p_acld->w_maxclass)  \
         || (gfp_msg->select.DefClassid < gfp_p_acld->w_baseclass) \
         || (!gfp_p_acld->p_transmap[gfp_msg->select.DefClassid-gfp_p_acld->w_baseclass]))\
        {							\
           tndx = (OMbyte) OM_K_NULL_TRANS;				\
        }							\
        else							\
        {							\
           tndx = (OMbyte) p_tmp_ACLD->p_transmap[gfp_msg->select.DefClassid-p_tmp_ACLD->w_baseclass];\
        }							\
        break;							\
								\
      case OM_e_wrt_parent:					\
	p_tmp_ACLD = (OM_p_CLASSDEF) OM_GA_active_classes[gfp_msg->select.ReqClassid];\
	p_ancestry = (OM_p_ANCESTRY) p_tmp_ACLD->A_ancestor_list+(p_tmp_ACLD->w_numparents-1);\
	p_tmp_ACLD = (OM_p_CLASSDEF) OM_GA_active_classes[*(p_ancestry->p_classid)];\
        tndx = (OMbyte) p_tmp_ACLD->p_transmap[gfp_msg->select.DefClassid-p_tmp_ACLD->w_baseclass];\
	break;							\
								\
      default:							\
        om$release_instance (rip=gfp_rip);			\
        gfp_sts = OM_E_INVARG;				        \
        goto num##;						\
      }								\
								\
      /*=====================================*/			\
      /*  if message is not valid for class  */			\
      /*      send Root unknown message      */			\
      /*=====================================*/			\
								\
      if ( tndx == (OMbyte) OM_K_NULL_TRANS )				\
      {								\
         /*============================================*/	\
         /*  fabricate a Root.unknown message message  */	\
         /*============================================*/	\
								\
         Rootunk_msg.select.DefClassid = OM_K_ROOT_ACTCLASSID;	\
         Rootunk_msg.select.ReqClassid = OM_K_ROOT_ACTCLASSID;	\
         Rootunk_msg.select.FuncIndex  = Root_OPP_unknown_method_index;\
         Rootunk_msg.size = sizeof(OM_p_MESSAGE);		\
         Rootunk_msg.p_arglist = (char *)& gfp_msg;		\
								\
         /*===========================================================*/\
         /*  note: using internal macro here instead of public macro  */\
         /*        because the macro does not have channum as an arg  */\
         /*===========================================================*/\
									\
         if ( map_flags & OM_SM_disable_intrcpt )               \
         { /* reset disable flag before sending */		\
           OM_Gp_CurOSD->Spacemap[gfp_targetid].flags |= OM_SM_disable_intrcpt;\
         }							\
         gfp_sts=(om$send_obj_int(msg=&Rootunk_msg,senderid=gfp_senderid,targetid=gfp_targetid,channum=gfp_channum));\
	 int_sts = OM_W_UNKNOWN_MSG;		\
         goto num##;				\
      }								\
   }								\
								\
   /*==================================*/			\
   /*  get function pointer of method  */			\
   /*==================================*/			\
								\
   gfp_f = p_tmp_ACLD->MsgMap[tndx].MethTbl[gfp_msg->select.FuncIndex];	\
num##:	; /* the end of macro */				\
  }


#define OM_COMPLETE_SEND(cs_rip,cs_saved_senderOS,cs_targetid)\
 {								\
   OM_Gw_senders_OS = cs_saved_senderOS;			\
   cs_rip.p_mapentry = &OM_Gp_CurSpaceMap[cs_targetid];		\
   OM_GA_CSDarray[cs_rip.p_mapentry->sdi].PostSendDepth++;	\
 }

#define OM_COMPLETE_SEND_ROOTDEL(csr_rip,csr_p_acld,saved_senderOS,csr_senderid,csr_targetid,csr_channum,csr_sts)\
   {								\
   int                  sts2;					\
   OM_S_MESSAGE         Rootdel_msg;				\
   OM_p_FUNCPTR         f;					\
								\
   OM_COMPLETE_SEND(csr_rip,saved_senderOS,csr_targetid);	\
								\
   csr_rip.p_mapentry->flags &= ~OM_SM_send_depth;		\
								\
   /*=================================*/			\
   /*  check for Root.delete pending  */			\
   /*=================================*/			\
								\
   if ( csr_rip.p_mapentry->flags & OM_SM_Rootdel_pending )	\
   {								\
      int	dummy=0;                                        \
      f = Root_Root_delete_method;				\
								\
      /*===================================*/			\
      /*  fabricate a Root.delete message  */			\
      /*===================================*/			\
								\
      Rootdel_msg.select.DefClassid = (OMuword) OM_K_ROOT_ACTCLASSID;  	\
      Rootdel_msg.select.ReqClassid = (OMuword) OM_K_ROOT_ACTCLASSID;	\
      Rootdel_msg.select.FuncIndex  = Root_OPP_delete_method_index;	\
      Rootdel_msg.size = sizeof(int);				\
      Rootdel_msg.p_arglist = (char *) &dummy;			\
								\
      /*=============================*/				\
      /*  invoke Root.delete method  */				\
      /*=============================*/				\
								\
      sts2 = f ( &Rootdel_msg, OM_Gw_senders_OS, csr_senderid,csr_targetid,csr_rip.p_mapentry, csr_channum, csr_p_acld ); \
   }								\
   om$release_instance (rip=csr_rip);				\
  }


#define OM_PREP_SEND(ps_rip,ps_save_senderOS) \
{                                             \
    OM_GA_CSDarray[ps_rip.p_mapentry->sdi].PreSendDepth++;\
    ps_save_senderOS = OM_Gw_senders_OS;      \
    OM_Gw_senders_OS = OM_Gw_current_OS;      \
}


#define OM_CACHE_SEND(cs_senderid,cs_targetid,cs_rip,p_cache_entry,cs_cache,cs_p_acld,cs_wrt,cs_msg,cs_channum,cs_sts,int_sts,num) \
{                                                                   \
    OM_p_FUNCPTR     cs_f=NULL;                                          \
    OM_p_OBJECTHDR   p_inst;                                        \
    OMuword          act_classid;                                   \
    int_sts = OM_S_SUCCESS;					    \
    cs_sts = om$get_instance(objid=cs_targetid,p_rip=&cs_rip);      \
    if (1&cs_sts)                                                   \
    {                                                               \
      p_inst = cs_rip.p_object;                                     \
      if( (cs_rip.p_mapentry->flags & OM_SM_unknown_obj)	    \
	  || (cs_rip.p_mapentry->p_acld->w_classid == 0) )          \
	cs_sts = OM_E_NOSUCHCLASS;				    \
      else							    \
      {								    \
       act_classid = cs_rip.p_mapentry->p_acld->w_classid;          \
       p_cache_entry=act_classid % OM_K_CACHE_SIZE + cs_cache;      \
       if (p_cache_entry->classid != act_classid)                   \
       {                                                            \
          OM_GET_FUNCTION_PTR(cs_f,cs_rip,cs_p_acld,cs_wrt,cs_msg,cs_senderid,cs_targetid,cs_channum,cs_sts,int_sts,num);\
          if( (1&cs_sts) && (1&int_sts) )                           \
          {                                                         \
            p_cache_entry->p_method=cs_f;                           \
            p_cache_entry->classid=act_classid;                     \
          }                                                         \
       }                                                            \
       else                                                         \
       {                                                            \
          cs_p_acld=(OM_p_CLASSDEF) OM_GA_active_classes[act_classid];              \
       }                                                            \
    }                                                               \
  }								    \
}

#endif
