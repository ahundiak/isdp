
#line 15  "/usr4/ip32/exnucdp/include/OMtypes.h"
 typedef int    ( * OM_p_FUNCPTR ) ( ) ;
 typedef unsigned int   OMuint ;
 typedef unsigned long int  OMulong ;
 typedef unsigned short int  OMuword ;
 typedef short int   OMword ;
 typedef unsigned char   OMbyte ;

 typedef unsigned short int  uword ;


 typedef unsigned long int OM_S_OBJID ;
 typedef unsigned long int * OM_p_OBJID ;






 typedef struct OM_sd_dlink * OM_p_DLINK ;

 struct OM_sd_dlink
 {
  OM_p_DLINK next ;
  OM_p_DLINK prev ;
 } ;
 typedef struct OM_sd_dlink OM_S_DLINK ;
#line 78  "/usr4/ip32/exnucdp/include/OMminimum.h"
 struct OM_sd_objecthdr
 {
  OM_S_OBJID   oid ;
#line 91  "/usr4/ip32/exnucdp/include/OMminimum.h"
  OMuint    i_size ;
 } ;
 typedef struct OM_sd_objecthdr  OM_S_OBJECTHDR ;
 typedef struct OM_sd_objecthdr  * OM_p_OBJECTHDR ;

 enum   OM_e_wrt_flag  { OM_e_wrt_object = 25 ,
             OM_e_wrt_ancestor = 26 ,
         OM_e_wrt_message = 26 ,
         OM_e_wrt_parent = 27 } ;






 typedef enum   OM_e_wrt_flag  OM_E_WRT_FLAG ;

 enum OM_e_inc_flag { OM_e_inclusive = 27 ,
    OM_e_exclusive } ;
 typedef enum OM_e_inc_flag OM_E_INC_FLAG ;

 enum OM_e_ovrwrt_flg { OM_e_overwrite = 13 ,
    OM_e_no_ovrwrt ,
                         OM_e_overwrite_rrr } ;
 typedef enum OM_e_ovrwrt_flg OM_e_OVRWRT_FLG ;





 struct OM_sd_neighbor
 {
  OM_S_OBJID  groupid ;
  OMuword  clusterid ;
 } ;
 typedef struct OM_sd_neighbor OM_S_NEIGHBOR ;
 typedef struct OM_sd_neighbor * OM_p_NEIGHBOR ;








 struct OM_sd_methselect
 {
  OMuword  DefClassid ;
  OMuword  ReqClassid ;
  OMuword  FuncIndex ;
 } ;
 typedef struct OM_sd_methselect * OM_p_METHSELECT ;
 typedef struct OM_sd_methselect OM_S_METHSELECT ;





 struct OM_sd_message
 {
  OM_S_METHSELECT select ;
  OMuword  size ;
  char    * p_arglist ;
 } ;
 typedef struct OM_sd_message * OM_p_MESSAGE ;
 typedef struct OM_sd_message OM_S_MESSAGE ;



 struct OM_sd_varlenarr_descr
 {
  int   i_offset ;
  OMuint  i_count ;
 } ;
 typedef struct OM_sd_varlenarr_descr OM_S_VARLENARR_DESCR ;
 typedef struct OM_sd_varlenarr_descr * OM_p_VARLENARR_DESCR ;




 struct OM_sd_channum
 {
  OMuword   classid ;
  OMuword   number ;
 } ;
 typedef struct OM_sd_channum OM_S_CHANNUM ;
 typedef struct OM_sd_channum * OM_p_CHANNUM ;





 struct OM_sd_object_linkage
 {
  OMuword  osnum ;
  OMuword  w_flags ;
  OM_S_CHANNUM  channum ;
  OM_S_OBJID  S_objid ;
 } ;
 typedef struct  OM_sd_object_linkage     * OM_p_OBJECT_LINKAGE ;
 typedef struct  OM_sd_object_linkage     OM_S_OBJECT_LINKAGE ;

 struct OM_sd_channel_hdr
 {

  OMuword flags ;
#line 216  "/usr4/ip32/exnucdp/include/OMminimum.h"
 union
    {
    OMuword  count ;
    OMuword  isoindex ;
    } u1 ;

 } ;
 typedef struct OM_sd_channel_hdr OM_S_CHANNEL_HDR ;
 typedef struct OM_sd_channel_hdr * OM_p_CHANNEL_HDR ;

 struct OM_sd_channel_link
 {



  OM_S_CHANNEL_HDR hdr ;
  OM_S_CHANNUM  channum ;
  OM_S_OBJID  objid ;
 } ;
 typedef struct OM_sd_channel_link OM_S_CHANNEL_LINK ;
 typedef struct OM_sd_channel_link * OM_p_CHANNEL_LINK ;

 struct OM_sd_restricted_onechan
 {
  OM_S_CHANNEL_HDR  hdr ;
  OM_S_OBJID   objid ;
 } ;
 typedef struct OM_sd_restricted_onechan OM_S_RESTRICTED_ONECHAN ;
 typedef struct OM_sd_restricted_onechan * OM_p_RESTRICTED_ONECHAN ;

 struct OM_sd_little_tail
 {
  OMuword  collapse_count ;
  OMuword  last_index ;
 } ;
 typedef struct OM_sd_little_tail OM_S_LITTLE_TAIL ;
 typedef struct OM_sd_little_tail * OM_p_LITTLE_TAIL ;

 struct OM_sd_big_tail
 {
  OMuint  collapse_count ;
  OMuint  last_index ;
  OMuint  size ;
 } ;
 typedef struct OM_sd_big_tail OM_S_BIG_TAIL ;
 typedef struct OM_sd_big_tail * OM_p_BIG_TAIL ;



 struct OM_sd_chanselect
 {
  enum   { OM_e_name , OM_e_num , OM_e_addr } type ;
  union
  {
    char         * name ;
    OM_S_CHANNUM number ;
    OM_p_CHANNEL_HDR    * addr ;
  } u_sel ;
 } ;
 typedef struct OM_sd_chanselect OM_S_CHANSELECT ;
 typedef struct OM_sd_chanselect * OM_p_CHANSELECT ;

 typedef struct OM_sd_classdef  * OM_p_CLASSDEF ;
 typedef struct OM_sd_PCD  * OM_p_PCD ;




 struct OM_sd_spamapent
 {
  OM_p_CLASSDEF  p_acld ;
  OMuword  sdi ;
  OMuword  flags ;
#line 305  "/usr4/ip32/exnucdp/include/OMminimum.h"
  union OM_sd_spamapent_state
  {
    OM_p_OBJECTHDR object ;

    struct
    {
      OMuword  dummy ;
      OMuword  clusterid ;

    } filed_obj ;

    OM_S_OBJID  freeoid ;
  } state ;
 } ;
 typedef struct OM_sd_spamapent  OM_S_SPAMAPENT ;
 typedef struct OM_sd_spamapent  * OM_p_SPAMAPENT ;



 struct OM_sd_RIP
 {
  OM_p_OBJECTHDR p_object ;
  OM_p_SPAMAPENT p_mapentry ;
 } ;
 typedef struct OM_sd_RIP OM_S_RIP ;
 typedef struct OM_sd_RIP * OM_p_RIP ;




 struct OM_sd_OShole
 {
  OMuint  FilePtr ;
  OMuint  size ;
 } ;
 typedef struct OM_sd_OShole OM_S_OSHOLE ;
 typedef struct OM_sd_OShole * OM_p_OSHOLE ;





 struct OM_sd_GROUP_extent
 {
 OM_S_OBJID beg_oid ;
 OMuint  size ;
 } ;
 typedef struct OM_sd_GROUP_extent OM_S_GROUP_EXTENT ;
 typedef struct OM_sd_GROUP_extent * OM_p_GROUP_EXTENT ;






 typedef struct OM_sd_FREE_CHUNK_DESCR * OM_p_FCD ;

 struct OM_sd_CLUSTER_freehdr
 {

 OM_p_FCD       p_fcd ;
 OMuint  size ;
 } ;

 typedef struct OM_sd_CLUSTER_freehdr OM_S_CLUSTFHDR ;
 typedef struct OM_sd_CLUSTER_freehdr * OM_p_CLUSTFHDR ;


 struct OM_sd_FREE_CHUNK_DESCR
 {
  OM_p_FCD        nextfcd ;
  OM_p_CLUSTFHDR  freehdr ;
  OMuint          size ;
 } ;

 typedef struct OM_sd_FREE_CHUNK_DESCR   OM_S_FCD ;
 typedef struct OM_sd_CLUSTER_composite  * OM_p_LCD ;
 typedef struct OM_sd_CSD  * OM_p_CSD ;

 struct OM_sd_PCD
 {
 OM_S_DLINK   pcdq ;

 OM_S_DLINK   lcfq ;
 OM_p_LCD     p_lcd ;
 OM_p_FCD     p_fcd ;
 OM_p_CSD     p_csd ;
 OMuint       i_totalfree ;
 OMuint       i_numfree_chunks ;
 OMuint       i_totalsize ;
 OMuint       i_cur_num_objects ;
 OMuint       i_cur_num_chunks ;
 OMuint       i_totalWsheap ;
 } ;
 typedef struct OM_sd_PCD OM_S_PCD ;

 typedef struct OM_sd_OSD * OM_p_OSD ;

 struct OM_sd_CLUSTER_composite
 {
 OM_S_DLINK pcdq_lh ;
 OM_p_PCD p_pcd ;


 OM_p_OSD p_osd ;
 OMuint  i_file_ptr ;
 OM_S_OBJID oid ;
 OMuword  w_cluster_num ;
 OMuword  flags ;




 OMuint  i_cur_bytes_allocated ;

 } ;
 typedef struct OM_sd_CLUSTER_composite OM_S_LCD ;

 struct OM_sd_CSD
 {
 OM_S_DLINK lcq ;

 OM_p_PCD p_pcd ;
 char          * p_addr ;
 OMuint  PreSendDepth ;
 OMuint  PostSendDepth ;
 OMuword  flag ;





 OMuword  index ;
 } ;
 typedef struct OM_sd_CSD OM_S_CSD ;






 struct OM_sd_OSCO
 {
   OMuword    w_classid ;
   OMuword    w_child_refcnt ;
   char       s_name [ 32               ] ;
   OMuword    w_oppmaj_version ;
   OMuword    w_oppmin_version ;
   OMuword    w_major_version ;
   OMuword    w_minor_version ;
   OMuint     i_refcnt ;
   OM_S_OBJID OSCO_oid ;
 } ;
 typedef struct OM_sd_OSCO        OM_S_OSCO ;
 typedef struct OM_sd_OSCO       * OM_p_OSCO ;






 struct OM_sd_OSD
 {
  OM_S_DLINK  lcfq_lh ;

  OM_S_OBJID     OSO_Oid ;
  OM_S_OBJID  Group0_Oid ;
  OMuword  OSnum ;
  char   name [ 128               ] ;
  char   InternalName [ 32                   ] ;
  OMbyte  type ;







  OMbyte  flags ;
#line 500  "/usr4/ip32/exnucdp/include/OMminimum.h"
  OMuword  * ActToFil ;
  OMuword  * FilToAct ;
  OMuint  MaxOSSize ;
  OMuint  CurSpaceMapSize ;
  OM_p_SPAMAPENT Spacemap ;
  OMuint  ClustersSize ;

  OM_p_LCD  * Clusters ;
  OM_p_OSCO             * OSCO_list ;
  OMuint  OidFreelist ;
 } ;
 typedef struct OM_sd_OSD OM_S_OSD ;




 struct OM_sd_OSstatus
 {
   OMbyte     stattype ;








   union
   {

      struct
      {
         OMbyte     OStype ;

         OMbyte     OSflags ;
         OMuint     num_OMobjects ;
         OMuint     num_UserObjects ;
         char       CreTimeDate [ 16 ] ;
         char       TimeDate [ 16 ] ;


      } misc ;


      struct
      {
         OMuint   total_num ;
         OMuint   num_faulted ;
         OMuint   mem_allocated ;

         OMuint   num_chunks ;
      } cluster ;


      struct
      {
         OMuint   total_num ;
      } group ;
   } stat ;
 } ;

 typedef struct OM_sd_OSstatus   OM_S_OSSTATUS ;
 typedef struct OM_sd_OSstatus  * OM_p_OSSTATUS ;


 struct OM_sd_msgmap
 {
  OM_p_FUNCPTR  * MethTbl ;
  OMuint  offset ;
  OMuword  classid ;
  OMuword  NumChan ;
  struct OM_sd_channel_defn * ChanDefns ;
 } ;
 typedef struct OM_sd_msgmap  OM_S_MSGMAP ;
 typedef struct OM_sd_msgmap  * OM_p_MSGMAP ;


 typedef struct OM_sd_ancestry * OM_p_ANCESTRY ;
 struct OM_sd_ancestry
 {
  OMuword  * p_classid ;
  int   ( * p_create_args ) ( ) ;
  OMuword  MajVer ;
  OMuword  MinVer ;
  OM_p_ANCESTRY  p_sibling ;
  OM_p_CLASSDEF  p_classdef ;
 } ;
 typedef struct OM_sd_ancestry OM_S_ANCESTRY ;





 struct OM_sd_classdef
 {
  OMuword  w_classid ;
  OMuint  i_instance_size ;
  OMuint  NewInstanceSize ;
  OMuword  w_major_version ;
  OMuword  w_minor_version ;
  OMuword  w_oppmaj_version ;
  OMuword  w_oppmin_version ;
  char   s_name [ 32               ] ;
  OMuint         flags ;



  struct OM_sd_varlenarr_defn * p_varlenarr_defns ;
  OMuword  w_num_varlenarrays ;
  OMuword  w_numparents ;
  struct OM_sd_ancestry * A_ancestor_list ;
  struct OM_sd_ancestry  * p_subclass_list ;
  struct OM_sd_channel_defn * ChanDefns ;
  OMuword  w_numchannels ;
  OMuword  w_nummethods ;
  struct OM_sd_methdefn * p_methdefns ;
  struct OM_sd_Dclass * p_instance_def ;
  OMuint  initial_size ;

  OMuint  NumRecClasses ;


  OMuword  w_maxclass ;

  OMuword  w_baseclass ;

  OMbyte  * p_transmap ;



  OMuword  NumMsgClasses ;
  OM_p_MSGMAP  MsgMap ;
 int     * p_createclass_args ;
 } ;
 typedef struct OM_sd_classdef  OM_S_CLASSDEF ;





 struct OM_sd_classlist {
  OMuword w_count ;
  OMuword       w_flags ;







  OMuword * p_classes ;
 } ;
 typedef struct OM_sd_classlist  OM_S_CLASSLIST ;
 typedef struct OM_sd_classlist  * OM_p_CLASSLIST ;





 struct OM_sd_tag_con_info
 {
   OM_S_OBJID         objid ;
   OM_S_CHANNUM       chan ;
   OMuword            index ;
   OMuint             tag ;
   OM_S_CHANNUM       tag_chan ;
   OMuword            tag_index ;
   OMuword            version ;
 } ;
 typedef struct OM_sd_tag_con_info OM_S_TAG_CON_INFO ;
 typedef struct OM_sd_tag_con_info * OM_p_TAG_CON_INFO ;


 typedef struct OM_sd_class_hash_ent * OM_p_CLASS_HASH_ENT ;
 struct OM_sd_class_hash_ent
 {
   OM_p_CLASSDEF        p_acld ;
   OM_p_CLASS_HASH_ENT  next ;
 } ;
 typedef struct OM_sd_class_hash_ent  OM_S_CLASS_HASH_ENT ;





 typedef struct OM_sd_orig_osname * OM_p_ORIGOSNAME ;

 struct OM_sd_orig_osname {
   OMuword osnum ;
   char orig_name [ 128               ] ;
   OM_p_ORIGOSNAME  next ;
 } ;

 typedef struct OM_sd_orig_osname OM_S_ORIGOSNAME ;


 typedef struct OM_sd_dup_intosname * OM_p_DUPINTOS ;

 struct OM_sd_dup_intosname {
   OMuword        osnum ;
   OMuword        num_dup ;
   OMuword       * dup_osnum ;
   char           orig_intname [ 32                   ] ;

   OM_p_DUPINTOS  next ;
   int           * more ;
 } ;
 typedef struct OM_sd_dup_intosname OM_S_DUPINTOS ;






 extern OMuword   OM_Gw_numclasses ;
 extern OMuword   OM_Gw_next_class_index ;
 extern OM_p_CLASSDEF  * OM_GA_active_classes ;
 extern OMuword   * OM_GA_active_to_filed ;
 extern OMuword   * OM_GA_filed_to_active ;
 extern  OMuword   * OM_GA_fa_mapsize ;
 extern OMuint   OM_Gf_consistent ;
 extern OMuint   OM_Gf_consistent_class ;
 extern OMuint   OM_Gf_bugcheck_fatal ;
 extern OMuint   OM_Gf_verbose_warning ;
 extern OMuint   OM_Gf_verbose_error ;
 extern  OMuint                  OM_Gf_tagged_connects ;
 extern OMuword   OM_Gw_current_OS ;
 extern OMuword   OM_Gw_senders_OS ;
 extern OMuword                  OM_Gw_tagged_osnum ;
 extern OM_S_OBJID  OM_GO_current_OS_objid ;
 extern OM_S_OBJID               OM_GO_current_MOSD ;
 extern OM_S_OBJID  NULL_OBJID ;
 extern OM_S_CHANNUM      NULL_CHANNUM ;
 extern OM_p_OSD   * OM_GA_OSDs ;
 extern OM_p_OSD   OM_Gp_CurOSD ;
 extern OM_p_SPAMAPENT  OM_Gp_CurSpaceMap ;
 extern OM_S_OBJID  OM_GO_TransOS_0 ;
 extern OMuword   OM_Gw_TransOSnum_0 ;
 extern OM_S_NEIGHBOR  OM_GS_NULL_NEIGHBOR ;
 extern OM_p_NEIGHBOR  OM_Gp_NULL_NEIGHBOR ;
 extern OM_S_MESSAGE             OM_GS_NULL_MESSAGE ;
 extern OM_p_MESSAGE             OM_Gp_NULL_MESSAGE ;
 extern OM_S_SPAMAPENT  OM_GS_NULL_SPAMAPENT ;
 extern OM_p_SPAMAPENT  OM_Gp_NULL_SPAMAPENT ;
 extern OMuword   OM_Gw_maxOS ;
 extern OMuword                  OM_Gw_RO_OS_count ;
 extern OM_p_OBJID               OM_GA_tag_oids ;
 extern struct OM_sd_tag_hash_entry * * OM_GA_p_tag_hashtable ;
 extern OMuword                  OM_Gw_tagcon_inc ;
 extern struct OM_sd_tagcon_link * * OM_GA_p_tagcon ;
 extern OMuword                  OM_Gw_tag_rec_extendsize ;
 extern OMuword                  OM_Gw_tag_hashtable_size ;
 extern OMuword                  OM_Gw_tag_hash_extendsize ;
 extern OMuint                   OM_Gf_tagging_enabled ;
 extern OM_S_CSD                 * OM_GA_CSDarray ;
 extern OMuint   OM_Gf_errToStdout ;
 extern OMuint   OM_Gf_val_cluster ;
#line 27  "/usr/include/version.h"
 struct INGR_sd_product_def {
   char * curr_version ;
   int  ( * version_check_func ) ( ) ;
   char * product_id ;
   char * appl_specifics ;

 } ;

 typedef struct INGR_sd_product_def  INGR_S_PRODUCT_DEF ;
 typedef struct INGR_sd_product_def * INGR_p_PRODUCT_DEF ;
#line 12  "OMprodinit.C"
 INGR_p_PRODUCT_DEF Pdu_appl_version [ ] =
 {
  0
 } ;

 int COpdu_OM_class_init ( ) ;
 int global_class_OM_class_init ( ) ;
 int PDUstartup_OM_class_init ( ) ;
 int PDUasmmgr_OM_class_init ( ) ;

 OM_p_FUNCPTR Pdu_class_definitions [ ] =
 {
  COpdu_OM_class_init ,
  global_class_OM_class_init ,
  PDUstartup_OM_class_init ,
  PDUasmmgr_OM_class_init ,
   0
 } ;

 OMuword OPP_COpdu_class_id = 65535 ;
 OMuword OPP_PDUstartup_class_id = 65535 ;
 OMuword OPP_global_class_class_id ;
 OMuword OPP_CEO_LOCATE_class_id ;
 OMuword OPP_PDUasmmgr_class_id ;
 OMuword OPP_super_cmd_class_id ;


 OMuword COpdu_OPP_get_message_type_method_index ;
 OMuword COpdu_OPP_display_status_method_index ;
 OMuword global_class_OPP_wake_up_method_index ;
 OMuword global_class_OPP_sleep_method_index ;
 OMuword COpdu_OPP_save_default_view_method_index ;
 OMuword COpdu_OPP_display_status_message_method_index ;
 OMuword COpdu_OPP_store_origin_id_method_index ;
 OMuword COpdu_OPP_default_view_method_index ;
 OMuword COpdu_OPP_pdu_cleanup_method_index ;
 OMuword COpdu_OPP_check_default_view_method_index ;
 OMuword COpdu_OPP_pdu_chg_wf_state_method_index ;
 OMuword COpdu_OPP_get_prompt_type_method_index ;
 OMuword COpdu_OPP_list_parts_method_index ;
 OMuword COpdu_OPP_pdu_internal_method_index ;
 OMuword COpdu_OPP_disconnect_located_method_index ;
 OMuword COpdu_OPP_save_point_method_index ;
 OMuword COpdu_OPP_store_GRpart_id_method_index ;
 OMuword COpdu_OPP_store_view_method_index ;
 OMuword COpdu_OPP_display_command_method_index ;
 OMuword COpdu_OPP_pdu_external_method_index ;
 OMuword COpdu_OPP_mydebug_method_index = 65535 ;
 OMuword COpdu_OPP_close_invis_file_method_index = 65535 ;
 OMuword COpdu_OPP_disp_cmd_cancelled_method_index = 65535 ;
 OMuword COpdu_OPP_pdu_validate_wf_method_index = 65535 ;
 OMuword COpdu_OPP_verify_command_method_index = 65535 ;
 OMuword COpdu_OPP_check_origins_method_index = 65535 ;
 OMuword COpdu_OPP_list_origins_method_index = 65535 ;
 OMuword COpdu_OPP_display_design_form_method_index = 65535 ;
