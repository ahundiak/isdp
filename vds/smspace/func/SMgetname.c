/* $Id: SMgetname.c,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/func / SMgetname.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMgetname.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef OPP_component_offset
#define OPP_component_offset(CLS,PTR,TYPE)    {    register int cls=(CLS);    cls += (int)map;    cls = *(char *)cls;    cls *= sizeof(struct OM_sd_msgmap);    cls += mmap;    cls = (int)&((struct OM_sd_msgmap *)cls)->offset;    cls = *((int *)cls);    cls += (int) me;    (PTR) = (struct TYPE *) cls;   }
#endif
#ifndef OPP_W_UNKNOWN_MSG
#   define OPP_W_UNKNOWN_MSG (0x2508010)
#endif
typedef struct OM_sd_dlink *OM_p_DLINK;
 struct OM_sd_dlink
  {
   OM_p_DLINK next;
   OM_p_DLINK prev;
  } ;
typedef unsigned long int OM_S_OBJID;
typedef unsigned int OMuint;
 struct OM_sd_objecthdr
  {
   OM_S_OBJID oid;
   OMuint i_size;
  } ;
 enum   OM_e_wrt_flag
  {
   OM_e_wrt_object= 25,
   OM_e_wrt_ancestor,
   OM_e_wrt_message= 26,
   OM_e_wrt_parent
  } ;
 enum   OM_e_inc_flag
  {
   OM_e_inclusive= 27,
   OM_e_exclusive
  } ;
 enum   OM_e_ovrwrt_flg
  {
   OM_e_overwrite= 13,
   OM_e_no_ovrwrt,
   OM_e_overwrite_rrr
  } ;
typedef unsigned short int OMuword;
 struct OM_sd_neighbor
  {
   OM_S_OBJID groupid;
   OMuword clusterid;
  } ;
 struct OM_sd_methselect
  {
   OMuword DefClassid;
   OMuword ReqClassid;
   OMuword FuncIndex;
  } ;
typedef struct OM_sd_methselect OM_S_METHSELECT;
 struct OM_sd_message
  {
   OM_S_METHSELECT select;
   OMuword size;
   char *p_arglist;
  } ;
 struct OM_sd_varlenarr_descr
  {
   int i_offset;
   OMuint i_count;
  } ;
 struct OM_sd_channum
  {
   OMuword classid;
   OMuword number;
  } ;
typedef struct OM_sd_channum OM_S_CHANNUM;
 struct OM_sd_object_linkage
  {
   OMuword osnum;
   OMuword w_flags;
   OM_S_CHANNUM channum;
   OM_S_OBJID S_objid;
  } ;
 struct OM_sd_channel_hdr
  {
   OMuword flags;
    union  
  {
   OMuword count;
   OMuword isoindex;
  } u1;
  } ;
typedef struct OM_sd_channel_hdr OM_S_CHANNEL_HDR;
 struct OM_sd_channel_link
  {
   OM_S_CHANNEL_HDR hdr;
   OM_S_CHANNUM channum;
   OM_S_OBJID objid;
  } ;
 struct OM_sd_restricted_onechan
  {
   OM_S_CHANNEL_HDR hdr;
   OM_S_OBJID objid;
  } ;
 struct OM_sd_little_tail
  {
   OMuword collapse_count;
   OMuword last_index;
  } ;
 struct OM_sd_big_tail
  {
   OMuint collapse_count;
   OMuint last_index;
   OMuint size;
  } ;
typedef struct OM_sd_channel_hdr *OM_p_CHANNEL_HDR;
 struct OM_sd_chanselect
  {
    enum   
  {
   OM_e_name,
   OM_e_num,
   OM_e_addr
  } type;
    union  
  {
   char *name;
   OM_S_CHANNUM number;
   OM_p_CHANNEL_HDR *addr;
  } u_sel;
  } ;
typedef unsigned char OMbyte;
typedef struct OM_sd_msgmap *OM_p_MSGMAP;
 struct OM_sd_classdef
  {
   OMuword w_classid;
   OMuint i_instance_size;
   OMuint NewInstanceSize;
   OMuword w_major_version;
   OMuword w_minor_version;
   OMuword w_oppmaj_version;
   OMuword w_oppmin_version;
   char s_name[32];
   OMuint flags;
   struct OM_sd_varlenarr_defn *p_varlenarr_defns;
   OMuword w_num_varlenarrays;
   OMuword w_numparents;
   struct OM_sd_ancestry *A_ancestor_list;
   struct OM_sd_ancestry *p_subclass_list;
   struct OM_sd_channel_defn *ChanDefns;
   OMuword w_numchannels;
   OMuword w_nummethods;
   struct OM_sd_methdefn *p_methdefns;
   struct OM_sd_Dclass *p_instance_def;
   OMuint initial_size;
   OMuint NumRecClasses;
   OMuword w_maxclass;
   OMuword w_baseclass;
   OMbyte *p_transmap;
   OMuword NumMsgClasses;
   OM_p_MSGMAP MsgMap;
   int *p_createclass_args;
  } ;
typedef struct OM_sd_dlink OM_S_DLINK;
typedef struct OM_sd_CLUSTER_composite *OM_p_LCD;
typedef struct OM_sd_FREE_CHUNK_DESCR *OM_p_FCD;
typedef struct OM_sd_CSD *OM_p_CSD;
 struct OM_sd_PCD
  {
   OM_S_DLINK pcdq;
   OM_S_DLINK lcfq;
   OM_p_LCD p_lcd;
   OM_p_FCD p_fcd;
   OM_p_CSD p_csd;
   OMuint i_totalfree;
   OMuint i_numfree_chunks;
   OMuint i_totalsize;
   OMuint i_cur_num_objects;
   OMuint i_cur_num_chunks;
   OMuint i_totalWsheap;
  } ;
typedef struct OM_sd_classdef *OM_p_CLASSDEF;
typedef struct OM_sd_objecthdr *OM_p_OBJECTHDR;
 union  OM_sd_spamapent_state
  {
   OM_p_OBJECTHDR object;
    struct 
  {
   OMuword dummy;
   OMuword clusterid;
  } filed_obj;
   OM_S_OBJID freeoid;
  } ;
 struct OM_sd_spamapent
  {
   OM_p_CLASSDEF p_acld;
   OMuword sdi;
   OMuword flags;
   union  OM_sd_spamapent_state state;
  } ;
typedef struct OM_sd_spamapent *OM_p_SPAMAPENT;
 struct OM_sd_RIP
  {
   OM_p_OBJECTHDR p_object;
   OM_p_SPAMAPENT p_mapentry;
  } ;
 struct OM_sd_OShole
  {
   OMuint FilePtr;
   OMuint size;
  } ;
 struct OM_sd_GROUP_extent
  {
   OM_S_OBJID beg_oid;
   OMuint size;
  } ;
typedef struct OM_sd_CLUSTER_freehdr *OM_p_CLUSTFHDR;
 struct OM_sd_FREE_CHUNK_DESCR
  {
   OM_p_FCD nextfcd;
   OM_p_CLUSTFHDR freehdr;
   OMuint size;
  } ;
 struct OM_sd_CLUSTER_freehdr
  {
   OM_p_FCD p_fcd;
   OMuint size;
  } ;
typedef struct OM_sd_PCD *OM_p_PCD;
typedef struct OM_sd_OSD *OM_p_OSD;
 struct OM_sd_CLUSTER_composite
  {
   OM_S_DLINK pcdq_lh;
   OM_p_PCD p_pcd;
   OM_p_OSD p_osd;
   OMuint i_file_ptr;
   OM_S_OBJID oid;
   OMuword w_cluster_num;
   OMuword flags;
   OMuint i_cur_bytes_allocated;
  } ;
 struct OM_sd_CSD
  {
   OM_S_DLINK lcq;
   OM_p_PCD p_pcd;
   char *p_addr;
   OMuint PreSendDepth;
   OMuint PostSendDepth;
   OMuword flag;
   OMuword index;
  } ;
typedef struct OM_sd_OSCO *OM_p_OSCO;
 struct OM_sd_OSD
  {
   OM_S_DLINK lcfq_lh;
   OM_S_OBJID OSO_Oid;
   OM_S_OBJID Group0_Oid;
   OMuword OSnum;
   char name[128];
   char InternalName[32];
   OMbyte type;
   OMbyte flags;
   OMuword *ActToFil;
   OMuword *FilToAct;
   OMuint MaxOSSize;
   OMuint CurSpaceMapSize;
   OM_p_SPAMAPENT Spacemap;
   OMuint ClustersSize;
   OM_p_LCD *Clusters;
   OM_p_OSCO *OSCO_list;
   OMuint OidFreelist;
  } ;
 struct OM_sd_OSCO
  {
   OMuword w_classid;
   OMuword w_child_refcnt;
   char s_name[32];
   OMuword w_oppmaj_version;
   OMuword w_oppmin_version;
   OMuword w_major_version;
   OMuword w_minor_version;
   OMuint i_refcnt;
   OM_S_OBJID OSCO_oid;
  } ;
 struct OM_sd_OSstatus
  {
   OMbyte stattype;
    union  
  {
    struct 
  {
   OMbyte OStype;
   OMbyte OSflags;
   OMuint num_OMobjects;
   OMuint num_UserObjects;
   char CreTimeDate[16];
   char TimeDate[16];
  } misc;
    struct 
  {
   OMuint total_num;
   OMuint num_faulted;
   OMuint mem_allocated;
   OMuint num_chunks;
  } cluster;
    struct 
  {
   OMuint total_num;
  } group;
  } stat;
  } ;
typedef int (*OM_p_FUNCPTR)();
 struct OM_sd_msgmap
  {
   OM_p_FUNCPTR *MethTbl;
   OMuint offset;
   OMuword classid;
   OMuword NumChan;
   struct OM_sd_channel_defn *ChanDefns;
  } ;
typedef struct OM_sd_ancestry *OM_p_ANCESTRY;
 struct OM_sd_ancestry
  {
   OMuword *p_classid;
   int (*p_create_args)();
   OMuword MajVer;
   OMuword MinVer;
   OM_p_ANCESTRY p_sibling;
   OM_p_CLASSDEF p_classdef;
  } ;
 struct OM_sd_classlist
  {
   OMuword w_count;
   OMuword w_flags;
   OMuword *p_classes;
  } ;
 struct OM_sd_tag_con_info
  {
   OM_S_OBJID objid;
   OM_S_CHANNUM chan;
   OMuword index;
   OMuint tag;
   OM_S_CHANNUM tag_chan;
   OMuword tag_index;
   OMuword version;
  } ;
typedef struct OM_sd_class_hash_ent *OM_p_CLASS_HASH_ENT;
 struct OM_sd_class_hash_ent
  {
   OM_p_CLASSDEF p_acld;
   OM_p_CLASS_HASH_ENT next;
  } ;
typedef struct OM_sd_orig_osname *OM_p_ORIGOSNAME;
 struct OM_sd_orig_osname
  {
   OMuword osnum;
   char orig_name[128];
   OM_p_ORIGOSNAME next;
  } ;
typedef struct OM_sd_dup_intosname *OM_p_DUPINTOS;
 struct OM_sd_dup_intosname
  {
   OMuword osnum;
   OMuword num_dup;
   OMuword *dup_osnum;
   char orig_intname[32];
   OM_p_DUPINTOS next;
   int *more;
  } ;
typedef int ptrdiff_t;
typedef unsigned int size_t;
typedef char wchar_t;
typedef unsigned long int OMulong;
typedef short int OMword;
typedef unsigned short int uword;
typedef unsigned long int *OM_p_OBJID;
typedef struct OM_sd_objecthdr OM_S_OBJECTHDR;
typedef enum   OM_e_wrt_flag OM_E_WRT_FLAG;
typedef enum   OM_e_inc_flag OM_E_INC_FLAG;
typedef enum   OM_e_ovrwrt_flg OM_e_OVRWRT_FLG;
typedef struct OM_sd_neighbor OM_S_NEIGHBOR;
typedef struct OM_sd_neighbor *OM_p_NEIGHBOR;
typedef struct OM_sd_methselect *OM_p_METHSELECT;
typedef struct OM_sd_message *OM_p_MESSAGE;
typedef struct OM_sd_message OM_S_MESSAGE;
typedef struct OM_sd_varlenarr_descr OM_S_VARLENARR_DESCR;
typedef struct OM_sd_varlenarr_descr *OM_p_VARLENARR_DESCR;
typedef struct OM_sd_channum *OM_p_CHANNUM;
typedef struct OM_sd_object_linkage *OM_p_OBJECT_LINKAGE;
typedef struct OM_sd_object_linkage OM_S_OBJECT_LINKAGE;
typedef struct OM_sd_channel_link OM_S_CHANNEL_LINK;
typedef struct OM_sd_channel_link *OM_p_CHANNEL_LINK;
typedef struct OM_sd_restricted_onechan OM_S_RESTRICTED_ONECHAN;
typedef struct OM_sd_restricted_onechan *OM_p_RESTRICTED_ONECHAN;
typedef struct OM_sd_little_tail OM_S_LITTLE_TAIL;
typedef struct OM_sd_little_tail *OM_p_LITTLE_TAIL;
typedef struct OM_sd_big_tail OM_S_BIG_TAIL;
typedef struct OM_sd_big_tail *OM_p_BIG_TAIL;
typedef struct OM_sd_chanselect OM_S_CHANSELECT;
typedef struct OM_sd_chanselect *OM_p_CHANSELECT;
typedef struct OM_sd_spamapent OM_S_SPAMAPENT;
typedef struct OM_sd_RIP OM_S_RIP;
typedef struct OM_sd_RIP *OM_p_RIP;
typedef struct OM_sd_OShole OM_S_OSHOLE;
typedef struct OM_sd_OShole *OM_p_OSHOLE;
typedef struct OM_sd_GROUP_extent OM_S_GROUP_EXTENT;
typedef struct OM_sd_GROUP_extent *OM_p_GROUP_EXTENT;
typedef struct OM_sd_CLUSTER_freehdr OM_S_CLUSTFHDR;
typedef struct OM_sd_FREE_CHUNK_DESCR OM_S_FCD;
typedef struct OM_sd_PCD OM_S_PCD;
typedef struct OM_sd_CLUSTER_composite OM_S_LCD;
typedef struct OM_sd_CSD OM_S_CSD;
typedef struct OM_sd_OSCO OM_S_OSCO;
typedef struct OM_sd_OSD OM_S_OSD;
typedef struct OM_sd_OSstatus OM_S_OSSTATUS;
typedef struct OM_sd_OSstatus *OM_p_OSSTATUS;
typedef struct OM_sd_msgmap OM_S_MSGMAP;
typedef struct OM_sd_ancestry OM_S_ANCESTRY;
typedef struct OM_sd_classdef OM_S_CLASSDEF;
typedef struct OM_sd_classlist OM_S_CLASSLIST;
typedef struct OM_sd_classlist *OM_p_CLASSLIST;
typedef struct OM_sd_tag_con_info OM_S_TAG_CON_INFO;
typedef struct OM_sd_tag_con_info *OM_p_TAG_CON_INFO;
typedef struct OM_sd_class_hash_ent OM_S_CLASS_HASH_ENT;
typedef struct OM_sd_orig_osname OM_S_ORIGOSNAME;
typedef struct OM_sd_dup_intosname OM_S_DUPINTOS;
extern OMuword OM_Gw_numclasses;
extern OMuword OM_Gw_next_class_index;
extern OM_p_CLASSDEF *OM_GA_active_classes;
extern OMuword *OM_GA_active_to_filed;
extern OMuword *OM_GA_filed_to_active;
extern OMuword *OM_GA_fa_mapsize;
extern OMuint OM_Gf_consistent;
extern OMuint OM_Gf_consistent_class;
extern OMuint OM_Gf_bugcheck_fatal;
extern OMuint OM_Gf_verbose_warning;
extern OMuint OM_Gf_verbose_error;
extern OMuint OM_Gf_tagged_connects;
extern OMuword OM_Gw_current_OS;
extern OMuword OM_Gw_senders_OS;
extern OMuword OM_Gw_tagged_osnum;
extern OM_S_OBJID OM_GO_current_OS_objid;
extern OM_S_OBJID OM_GO_current_MOSD;
extern OM_S_OBJID NULL_OBJID;
extern OM_S_CHANNUM NULL_CHANNUM;
extern OM_p_OSD *OM_GA_OSDs;
extern OM_p_OSD OM_Gp_CurOSD;
extern OM_p_SPAMAPENT OM_Gp_CurSpaceMap;
extern OM_S_OBJID OM_GO_TransOS_0;
extern OMuword OM_Gw_TransOSnum_0;
extern OM_S_NEIGHBOR OM_GS_NULL_NEIGHBOR;
extern OM_p_NEIGHBOR OM_Gp_NULL_NEIGHBOR;
extern OM_S_MESSAGE OM_GS_NULL_MESSAGE;
extern OM_p_MESSAGE OM_Gp_NULL_MESSAGE;
extern OM_S_SPAMAPENT OM_GS_NULL_SPAMAPENT;
extern OM_p_SPAMAPENT OM_Gp_NULL_SPAMAPENT;
extern OMuword OM_Gw_maxOS;
extern OMuword OM_Gw_RO_OS_count;
extern OM_p_OBJID OM_GA_tag_oids;
extern struct OM_sd_tag_hash_entry **OM_GA_p_tag_hashtable;
extern OMuword OM_Gw_tagcon_inc;
extern struct OM_sd_tagcon_link **OM_GA_p_tagcon;
extern OMuword OM_Gw_tag_rec_extendsize;
extern OMuword OM_Gw_tag_hashtable_size;
extern OMuword OM_Gw_tag_hash_extendsize;
extern OMuint OM_Gf_tagging_enabled;
extern OM_S_CSD *OM_GA_CSDarray;
extern OMuint OM_Gf_errToStdout;
extern OMuint OM_Gf_val_cluster;
extern char *som_calloc(OMuint number,OMuint size);
extern int som_cancel_intercept(OMuword osnum,OM_S_OBJID objid);
extern int som_change_class(OMuword osnum,OM_S_OBJID objid,char *classname,OMuint sd_override);
extern int som_change_os_name(OMuword OSnum,char *name,OM_e_OVRWRT_FLG overwrite);
extern int som_change_os_name_by_name(char *curr_name,char *name,OM_e_OVRWRT_FLG overwrite);
extern int som_change_tag_version(OMuword osnum,OM_S_OBJID objid,OMuword version,OMbyte flag);
extern int som_channel_preset(OMuword os,OM_S_OBJID oid,OM_p_CHANSELECT p_chansel,OMuint size);
extern int som_channel_unpreset(OMuword os,OM_S_OBJID oid,OM_p_CHANSELECT p_chansel,int collapse_flag);
extern int som_construct_and_copy(OM_p_OBJECTHDR p_object,OM_S_OBJID objid,OMuword obj_osnum,OMuword osnum,char *osname,OM_S_NEIGHBOR neighbor,OM_p_OBJID p_objid,OMuint *p_tag);
extern int som_construct_object(char *classname,OMuword classid,OM_S_OBJID objid,OM_p_OBJECTHDR p_object,OMuword obj_osnum,OMuword osnum,char *osname,OM_p_OBJID p_objid,OM_p_MESSAGE msg,OM_S_NEIGHBOR neighbor,OMuint *p_tag);
extern int som_construct_os(OMuint classid,uword *osnum,char *osname,OM_p_OBJID p_objid,OMuint initcount,OMuint extcount,OMuint *resultcount,OMuint maxobjsize,OMuint loadmode,char sameosflag,char *di_logical);
extern int som_construct_os_by_name(char *classname,uword *osnum,char *osname,OM_p_OBJID p_objid,OMuint initcount,OMuint extcount,OMuint *resultcount,OMuint maxobjsize,OMuint loadmode,char sameosflag,char *di_logical);
extern int som_convert_internal_osname_to_number(char *name,OMuword *OSnum);
extern int som_convert_number_to_internal_osname(OMuword OSnum,char *name);
extern int som_convert_os_name_to_number(char *name,OMuword *OSnum);
extern int som_convert_os_number_to_name(OMuword OSnum,char *name);
extern void som_dealloc(void *ptr);
extern int som_disable_intercept(OMuword osnum,OM_S_OBJID objid);
extern int som_dynamic_class(char *p_parent_class[],OMuword num_parents,OMuword maj_version,OMuword min_version,char *p_dynamic_class);
extern int som_dynamic_load(char *object_file);
extern int som_enough_disk_space(OMuword input_osnum,char *osname,char *filename,int filesize);
extern int som_flagged_tag_connects(OMuword osnum,OMuword tag_osnum,OMuint *p_count,OMuint size,OM_p_TAG_CON_INFO p_tag_info,OMuword mask);
extern int som_getClusterFromObject(OMuword *pClustNum,OMuint objid,OMuword osnum);
extern int som_get_all_parents(OMuword classid,char *classname,OMuword parent_list[],OMuint size,OMuint *count);
extern int som_get_channel_count(OMuword osnum,OM_S_OBJID objid,OM_p_OBJECTHDR p_object,OM_p_CHANSELECT p_chanselect,OMuint *count);
extern int som_get_channel_name(char *channame,OM_S_CHANNUM channum);
extern int som_get_channel_number(char *channame,OM_p_CHANNUM p_channum);
extern int som_get_channel_objects(OMuword osnum,OM_S_OBJID objid,OM_p_OBJECTHDR p_object,OM_p_CHANSELECT p_chanselect,OM_S_OBJECT_LINKAGE list[],OMuint size,OMuint *count);
extern int som_get_classid(OMuword OSnum,char *classname,OM_S_OBJID objid,OM_p_OBJECTHDR p_object,OMuword *p_classid);
extern int som_get_classname(OMuword OSnum,OMuword classid,OM_S_OBJID objid,OM_p_OBJECTHDR p_object,char *classname);
extern int som_get_index(OMuword osnum_c,OM_S_OBJID objid_c,OM_p_OBJECTHDR p_object_c,OM_p_CHANSELECT p_chanselect,OM_S_OBJID objid,OMuword osnum2,OMuint *index);
extern int som_get_intercept(OMuword osnum,OM_S_OBJID objid,OMuword *p_target_osnum,OM_p_OBJID p_target_objid);
extern int som_get_mem_info(int *avail_swap,int *total_swap,int *phys_mem,int *avail_om,int *total_om,int *total_free);
extern int som_get_message_name(char *classname,OMuword classid,OMuword method_index,char *msg_name);
extern int som_get_objid_at_index(OMuword osnum_c,OM_S_OBJID objid_c,OM_p_OBJECTHDR p_object_c,OM_p_CHANSELECT p_chanselect,OMuint index,OM_S_OBJID *objid,OMuword *osnum2);
extern int som_get_os_senddepth(OMuword OSnum,OMuint *depth);
extern int som_get_parent_classid(OMuword classid,char *classname,OMuword *parent_classid);
extern int som_get_parent_classname(OMuword classid,char *classname,char *parent_classname);
extern int som_get_parent_count(OMuword classid,char *classname,OMuword *parent_count);
extern int som_get_senddepth(OMuword osnum,OM_S_OBJID objid,OMuword *p_depth);
extern int som_inquire_os(OMuword osnum,OM_p_DUPINTOS *pp_dup);
extern int som_is_ancestry_valid(OMuword sub_classid,OMuword super_classid,char *sub_classname,char *super_classname);
extern int som_is_objid_on_channel(OMuword osnum_c,OM_S_OBJID objid_c,OM_p_OBJECTHDR p_object_c,OM_p_CHANSELECT p_chanselect,OM_S_OBJID objid,OMuword osnum2);
extern int som_is_objid_valid(OMuword OSnum,OM_S_OBJID objid);
extern int som_make_chanselect(char *channame,OM_S_CHANNUM channum,OM_p_CHANNEL_HDR *chanaddr,OM_p_CHANSELECT p_chanselect);
extern int som_make_message(char *class_name,OMuword classid,char *meth_name,OMuword size,void *p_arglist,OM_p_MESSAGE p_msg);
extern int som_make_neighbor(OMuword osnum,OM_S_OBJID objid,OM_p_NEIGHBOR p_neighbor);
extern char *som_malloc(OMuint size);
extern int som_move_tag(OMuword osnum,OM_S_OBJID old_objid,OM_S_OBJID new_objid);
extern int som_objid_to_tag(OMuword osnum,OM_S_OBJID objid,OMuint *p_tag,OMuword *p_version,OMuint *p_index,void *tag_rec,OMuint *p_free,OMuword **pp_version);
extern int som_osnum_to_oso_objid(OMuword osnum,OM_p_OBJID p_objid);
extern int som_parse_channame(char *channame,char *s_class,char *s_channel);
extern char *som_realloc(char *ptr,OMuint size);
extern int som_remove_object_tag(OMuword osnum,OM_p_OBJECTHDR p_object,OM_S_OBJID objid);
extern int som_report_class_version(OMuword classid,char *classname,OMuword *major,OMuword *minor);
extern void som_report_error(OMulong sts);
extern int som_report_version(OMuword *major,OMuword *minor);
extern int som_runtime_init(int paramc,char *param_list[]);
extern int som_send_channel(OM_E_WRT_FLAG WRT_flag,OM_p_MESSAGE msg,OMuword osnum,OM_S_OBJID senderid,OM_p_CHANSELECT p_chansel,int frm,int to);
extern int som_send_foreign(OM_E_WRT_FLAG WRT_flag,OM_p_MESSAGE msg,OM_S_OBJID senderid,OM_S_OBJID targetid,OMuword osnum,OM_S_CHANNUM in_channum);
extern int som_send_object(OM_E_WRT_FLAG wrt_flag,OM_p_MESSAGE msg,OM_S_OBJID senderid,OM_S_OBJID targetid,OM_S_CHANNUM channum);
extern int som_set_dynamic_defaults(int paramc,char *param_list[]);
extern int som_set_intercept(OMuword osnum,OM_S_OBJID objid,OMuword target_osnum,OM_S_OBJID target_objid);
extern void som_set_os_type(OMuword osnum,int *p_num,unsigned char flag);
extern int som_set_tag_os(OMuword *p_prev_osnum,OMuword osnum);
extern int som_sibling_send(OM_E_WRT_FLAG WRT_flag,OM_p_MESSAGE msg,OM_S_OBJID senderid,OM_p_CHANSELECT p_chansel,OM_E_INC_FLAG inclusive);
extern char *som_sm_calloc(unsigned nelem,unsigned elsize);
extern void som_sm_dealloc(void *ptr);
extern char *som_sm_malloc(unsigned request);
extern char *som_sm_realloc(char *ptr,unsigned nbytes);
extern int som_tag_object(OMuword osnum,OM_p_OBJECTHDR p_object,OM_S_OBJID objid,OMuint *p_tag);
extern int som_tag_to_objid(OMuword osnum,OMuint tag,OM_p_OBJID p_objid,OMuword *p_version);
extern int som_test_connection(OMuword osnum,OM_S_OBJID objid,OM_p_CHANSELECT csel,OMuword tag_osnum,OM_S_OBJID tag_objid,OM_p_CHANSELECT tag_csel,OMuword *p_version,OMuword *p_tag_version,int force_flag);
extern int som_vla_set_dimension(int *p_offset,unsigned int *p_count,OMuint dim,OMuword osnum,OM_S_OBJID objid,OM_p_CLASSDEF p_acld,int move_data);
extern unsigned short OPP_Root_class_id ;
 struct Root_instance 
  {
   OM_S_OBJECTHDR OPPobjecthdr;
  };
struct Root_total_instance
 {
  struct Root_instance Root;
 };
extern OMuword Root_OPP_debug_method_index;
extern OMuword Root_OPP_delete_method_index;
 struct Root_delete_Msg
  {
   int f_defer_flag;
  };
extern OMuword Root_OPP_connect_method_index;
 struct Root_connect_Msg
  {
   OM_S_CHANSELECT to_sel;
   int to_idx;
   OM_S_OBJID fr_objid;
   OMuword fr_os;
   OM_S_CHANSELECT fr_sel;
   int fr_idx;
  };
extern OMuword Root_OPP_disconnect_method_index;
 struct Root_disconnect_Msg
  {
   OM_S_CHANSELECT to_sel;
   OM_S_OBJID fr_objid;
   OMuword fr_os;
   OM_S_CHANSELECT fr_sel;
  };
extern OMuword Root_OPP_wild_disconnect_method_index;
 struct Root_wild_disconnect_Msg
  {
   OM_S_CHANSELECT to_sel;
  };
extern OMuword Root_OPP_move_chan_method_index;
 struct Root_move_chan_Msg
  {
   OM_S_CHANSELECT to_sel;
   OM_S_OBJID fr_objid;
   OMuword fr_os;
   OM_S_CHANSELECT fr_sel;
  };
extern OMuword Root_OPP_copy_chan_method_index;
 struct Root_copy_chan_Msg
  {
   OM_S_CHANSELECT to_sel;
   OM_S_OBJID fr_objid;
   OMuword fr_os;
   OM_S_CHANSELECT fr_sel;
  };
extern OMuword Root_OPP_unknown_method_index;
 struct Root_unknown_Msg
  {
   OM_S_MESSAGE *msg;
  };
extern OMuword Root_OPP_range_disconnect_method_index;
 struct Root_range_disconnect_Msg
  {
   OM_S_CHANSELECT to_sel;
   int low_idx;
   int hi_idx;
  };
extern OMuword Root_OPP_set_operation_method_index;
 struct Root_set_operation_Msg
  {
   OM_S_CHANSELECT to_sel;
   OM_S_OBJID op2_objid;
   OMuword op2_os;
   OM_S_CHANSELECT op2_sel;
   OM_S_OBJID op3_objid;
   OMuword op3_os;
   OM_S_CHANSELECT op3_sel;
   char operation;
   OMuword preserve;
  };
extern OMuword Root_OPP_ARwrite_method_index;
 struct Root_ARwrite_Msg
  {
   int *return_code;
   int starting;
  };
extern OMuword Root_OPP_ARread_method_index;
 struct Root_ARread_Msg
  {
   int *return_code;
   char *keyword;
  };
typedef int fpos_t;
typedef  struct 
  {
   int _cnt;
   unsigned char *_ptr;
   unsigned char *_base;
   unsigned char _flag;
   unsigned char _file;
   char _cflag;
  } FILE;
extern FILE _iob[128];
extern unsigned char *_bufendtab[];
extern FILE *fopen(const char *,const char *);
extern FILE *freopen(const char *,const char *,FILE *);
extern FILE *tmpfile(void );
extern char *fgets(char *,int ,FILE *);
extern char *gets(char *);
extern char *tmpnam(char *);
extern int fclose(FILE *);
extern int feof(FILE *);
extern int ferror(FILE *);
extern int fflush(FILE *);
extern int fgetc(FILE *);
extern int fgetpos(FILE *,fpos_t *);
extern int fprintf(FILE *,const char *,...);
extern int fputc(int ,FILE *);
extern int fputs(const char *,FILE *);
extern int fscanf(FILE *,const char *,...);
extern int fseek(FILE *,long int ,int );
extern int fsetpos(FILE *,const fpos_t *);
extern int getc(FILE *);
extern int getchar(void );
extern int printf(const char *,...);
extern int putc(int ,FILE *);
extern int putchar(int );
extern int puts(const char *);
extern int remove(const char *);
extern int rename(const char *,const char *);
extern int scanf(const char *,...);
extern int setvbuf(FILE *,char *,int ,size_t );
extern int sprintf(char *,const char *,...);
extern int sscanf(const char *,const char *,...);
extern int ungetc(int ,FILE *);
typedef  struct 
  {
   char *adr[5];
   int arg;
  } __va_list;
extern int vfprintf(FILE *,const char *,__va_list );
extern int vprintf(const char *,__va_list );
extern int vsprintf(char *,const char *,__va_list );
extern long ftell(FILE *);
extern size_t fread(void *,size_t ,size_t ,FILE *);
extern size_t fwrite(const void *,size_t ,size_t ,FILE *);
extern void clearerr(FILE *);
extern void perror(const char *);
extern void rewind(FILE *);
extern void setbuf(FILE *,char *);
extern FILE *fdopen(int ,const char *);
extern char *ctermid(char *);
extern int fileno(FILE *);
typedef short IGRboolean;
typedef short IGRshort;
typedef long IGRlong;
typedef int IGRint;
typedef double IGRdouble;
typedef char IGRchar;
typedef unsigned char IGRuchar;
typedef unsigned short IGRushort;
typedef unsigned int IGRuint;
typedef unsigned long IGRulong;
typedef IGRdouble IGRvector[3];
typedef IGRdouble IGRmatrix[16];
typedef IGRdouble IGRpoint[3];
typedef OM_S_OBJID GRobjid;
typedef OM_S_OBJECT_LINKAGE GRobjlink;
typedef uword GRspacenum;
typedef uword GRclassid;
typedef uword GRchannum;
typedef OM_S_OBJECTHDR GRobjecthdr;
typedef double GRrange[6];
typedef char GRname[1023];
 enum   GRdyn_flag
  {
   return_buf,
   free_buff,
   call_dynam
  } ;
 struct GRsymbology
  {
   struct IGRdisplay display_attr;
   short level;
  } ;
 struct GRvg_construct
  {
   long *msg;
   struct GRmd_env *env_info;
   IGRboolean newflag;
   short level;
   unsigned short properties;
   char *geometry;
   struct IGRdisplay *display;
   char *class_attr;
   char *name;
  } ;
 struct GRprops
  {
   short type;
   short subtype;
   IGRboolean closed;
   IGRboolean phy_closed;
   IGRboolean is_segmented;
   IGRboolean planar;
  } ;
 struct GRabsg_hdr
  {
   long whole_size;
   long geometry_size;
   struct GRid id;
   short matrix_type;
   IGRmatrix matrix;
  } ;
 struct GRparms
  {
   double u;
   double v;
   IGRboolean polygon_inx;
   struct GRid leaf_id;
  } ;
 struct GRpost_info
  {
   IGRboolean construct_flag;
  } ;
 struct GRobj_info
  {
   char type[30];
  } ;
 struct GRfunction_info
  {
   struct GRmd_env *md_env;
   IGRboolean pass_to_other_spaces;
   char *info;
  } ;
extern unsigned short OPP_Root_class_id;
extern unsigned short OPP_GRgraphics_class_id;
extern unsigned short OPP_GRconnector_class_id;
extern unsigned short OPP_GRnotify_class_id;
extern unsigned short OPP_GRvg_class_id;
extern OMuword GRgraphics_OPP_GRgetname_method_index;
 struct GRgraphics_GRgetname_Msg
  {
   IGRlong *msg;
   IGRchar *name;
  };
extern unsigned short OPP_Root_class_id;
extern unsigned short OPP_NDchildren_class_id;
extern unsigned short OPP_NDfather_class_id;
extern unsigned short OPP_NDmacro_class_id;
extern unsigned short OPP_NDnode_class_id;
extern unsigned short OPP_NDnodein_class_id;
extern unsigned short OPP_ACpretend_class_id;
extern OMuword ACpretend_OPP_ACgive_downscan_method_index;
 struct ACpretend_ACgive_downscan_Msg
  {
   char *downscan;
  };
 struct GRid
  {
   GRspacenum osnum;
   GRobjid objid;
  } ;
extern OMuword ACpretend_OPP_ACfind_parent_method_index;
 struct ACpretend_ACfind_parent_Msg
  {
   struct GRid *father;
   IGRshort *mat_type;
   IGRdouble *matrix;
  };
int SMget_name(txt,obj_grid)
  char *txt;
  struct GRid *obj_grid;
 {

  union
   {
    struct
    {
      struct ACpretend_ACgive_downscan_Msg m0;
      OM_S_MESSAGE     M0;
    } m2;
    struct
    {
      struct ACpretend_ACfind_parent_Msg m0;
      OM_S_MESSAGE     M0;
    } m1;
    struct
    {
      struct GRgraphics_GRgetname_Msg m0;
      OM_S_MESSAGE     M0;
    } m0;
   } OPPsendbuffer;
#define OPPmsg3 OPPsendbuffer.m0.M0
#define OPPmsg2 OPPsendbuffer.m0.M0
#define OPPmsg1 OPPsendbuffer.m1.M0
#define OPPmsg0 OPPsendbuffer.m2.M0
#define OPPsb3 OPPsendbuffer.m0.m0
#define OPPsb2 OPPsendbuffer.m0.m0
#define OPPsb1 OPPsendbuffer.m1.m0
#define OPPsb0 OPPsendbuffer.m2.m0

#line 39 "SMgetname.I"
struct GRid mac ; 
IGRlong status , msg ; 
char txt2 [ 1023 ] , name [ 1023 ] , * pt_name , * strrchr ( ) ; 


txt [ 0 ] = '\0' ; 

status = som_send_foreign ( ( OM_e_wrt_object ) , ( (
#line 841 "SMgetname.c"
 OPPsb0.downscan = 
#line 46 "SMgetname.I"
name 
#line 845 "SMgetname.c"
,
 OPPmsg0.size = sizeof(struct ACpretend_ACgive_downscan_Msg),
 OPPmsg0.p_arglist = (char *) &OPPsb0,
 OPPmsg0.select.FuncIndex=ACpretend_OPP_ACgive_downscan_method_index ,
 OPPmsg0.select.DefClassid=OPPmsg0.select.ReqClassid = OPP_ACpretend_class_id ,
 &OPPmsg0)

#line 46 "SMgetname.I"
) , ( NULL_OBJID ) , ( obj_grid -> objid ) , ( obj_grid -> osnum ) , ( NULL_CHANNUM ) ) 


; 
if ( status & 1 ) 
{ 


status = som_send_foreign ( ( OM_e_wrt_object ) , ( (
#line 863 "SMgetname.c"
 OPPsb1.father = 
#line 54 "SMgetname.I"
& mac 
#line 867 "SMgetname.c"
,
 OPPsb1.mat_type = 
#line 54 "SMgetname.I"
0 
#line 872 "SMgetname.c"
,
 OPPsb1.matrix = 
#line 54 "SMgetname.I"
0 
#line 877 "SMgetname.c"
,
 OPPmsg1.size = sizeof(struct ACpretend_ACfind_parent_Msg),
 OPPmsg1.p_arglist = (char *) &OPPsb1,
 OPPmsg1.select.FuncIndex=ACpretend_OPP_ACfind_parent_method_index ,
 OPPmsg1.select.DefClassid=OPPmsg1.select.ReqClassid = OPP_ACpretend_class_id ,
 &OPPmsg1)

#line 54 "SMgetname.I"
) , ( NULL_OBJID ) , ( obj_grid -> objid ) , ( obj_grid -> osnum ) , ( NULL_CHANNUM ) ) 


; 
if ( status & 1 ) 
{ 
status = som_send_foreign ( ( OM_e_wrt_object ) , ( (
#line 893 "SMgetname.c"
 OPPsb2.msg = 
#line 60 "SMgetname.I"
& msg 
#line 897 "SMgetname.c"
,
 OPPsb2.name = 
#line 60 "SMgetname.I"
txt2 
#line 902 "SMgetname.c"
,
 OPPmsg2.size = sizeof(struct GRgraphics_GRgetname_Msg),
 OPPmsg2.p_arglist = (char *) &OPPsb2,
 OPPmsg2.select.FuncIndex=GRgraphics_OPP_GRgetname_method_index ,
 OPPmsg2.select.DefClassid=OPP_GRgraphics_class_id ,
 OPPmsg2.select.ReqClassid=OPP_GRvg_class_id ,
 &OPPmsg2)

#line 60 "SMgetname.I"
) , ( NULL_OBJID ) , ( mac . objid ) , ( mac . osnum ) , ( NULL_CHANNUM ) ) 


; 
if ( status & msg & 1 ) 
{ 
pt_name = strrchr ( txt2 , ':' ) ; 
if ( pt_name == 0 ) strcpy ( txt , pt_name ) ; 
else 
{ 

strcat ( & pt_name [ 1 ] , ":" ) ; 
strcat ( & pt_name [ 1 ] , name ) ; 
strcpy ( txt , & pt_name [ 1 ] ) ; 

} 
} 
else txt [ 0 ] = '\0' ; 
} 
} 
else 
{ 

status = som_send_foreign ( ( OM_e_wrt_object ) , ( (
#line 936 "SMgetname.c"
 OPPsb3.msg = 
#line 83 "SMgetname.I"
& msg 
#line 940 "SMgetname.c"
,
 OPPsb3.name = 
#line 83 "SMgetname.I"
name 
#line 945 "SMgetname.c"
,
 OPPmsg3.size = sizeof(struct GRgraphics_GRgetname_Msg),
 OPPmsg3.p_arglist = (char *) &OPPsb3,
 OPPmsg3.select.FuncIndex=GRgraphics_OPP_GRgetname_method_index ,
 OPPmsg3.select.DefClassid=OPP_GRgraphics_class_id ,
 OPPmsg3.select.ReqClassid=OPP_GRvg_class_id ,
 &OPPmsg3)

#line 83 "SMgetname.I"
) , ( NULL_OBJID ) , ( obj_grid -> objid ) , ( obj_grid -> osnum ) , ( NULL_CHANNUM ) ) 


; 
if ( status & msg & 1 ) 
{ 

pt_name = strrchr ( name , ':' ) ; 
if ( pt_name == 0 ) strcpy ( txt , pt_name ) ; 
else 
{ 

strcpy ( txt , & pt_name [ 1 ] ) ; 

} 
} 
else txt [ 0 ] = '\0' ; 
} 
return ( 1 ) ; 

} 
#undef OPPmsg3
#undef OPPmsg2
#undef OPPmsg1
#undef OPPmsg0
#undef OPPsb3
#undef OPPsb2
#undef OPPsb1
#undef OPPsb0
