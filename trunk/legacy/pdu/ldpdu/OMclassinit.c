
#line 15  "/usr/ip32/exnucdp/include/OMtypes.h"
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


 struct OM_sd_8_bits
 {
 char b0 : 1 ;
 char b1 : 1 ;
 char b2 : 1 ;
 char b3 : 1 ;
 char b4 : 1 ;
 char b5 : 1 ;
 char b6 : 1 ;
 char b7 : 1 ;
 } ;
 typedef struct OM_sd_8_bits OM_S_8_bits ;
 typedef struct OM_sd_8_bits * OM_p_8_bits ;
#line 79  "/usr/ip32/exnucdp/include/OMminimum.h"
 struct OM_sd_objecthdr
 {
  OM_S_OBJID   oid ;
#line 92  "/usr/ip32/exnucdp/include/OMminimum.h"
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
#line 217  "/usr/ip32/exnucdp/include/OMminimum.h"
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
#line 306  "/usr/ip32/exnucdp/include/OMminimum.h"
  union OM_sd_spamapent_state
  {
    OM_p_OBJECTHDR object ;

    struct
    {
      OMuword  dummy ;
      OMuword  clusterid ;

    } filed_obj ;

    struct
    {
      OM_p_PCD  p_pcd ;
    } swapped_obj ;

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
 typedef struct OM_sd_CLUSTER_swap_lumps * OM_p_LUMP ;
 typedef struct OM_sd_CSD  * OM_p_CSD ;

 struct OM_sd_PCD
 {
 OM_S_DLINK   pcdq ;

 OM_S_DLINK   lcfq ;
 OM_p_LCD     p_lcd ;
 OM_p_FCD     p_fcd ;
 OM_p_CSD     p_csd ;
 OM_p_LUMP    p_lump ;

 OMuint       i_totalfree ;
 OMuint       i_numfree_chunks ;
 OMuint       i_totalsize ;
 OMuint       i_cur_num_objects ;
 OMuint       i_cur_num_chunks ;
 OMuint       i_age ;
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

 struct OM_sd_RPB
 {
 char  name [ 132                        ] ;
 OMuword  partition_size ;
 OMuword  num_lumps_avail ;
 OM_p_8_bits lump_bitmap ;
 OMuword  flag ;


 } ;
 typedef struct OM_sd_RPB OM_S_RPB ;
 typedef struct OM_sd_RPB * OM_p_RPB ;






 struct OM_sd_CLUSTER_swap_lumps
 {
 OMuint  lump_index ;
 OM_p_RPB rpb ;
 OMuint  bytes_used ;
 OMuint  lumps_used ;
 OM_p_LUMP       next ;
 char  * p_addr ;


 } ;
 typedef struct OM_sd_CLUSTER_swap_lumps OM_S_LUMP ;




 typedef struct OM_sd_ccb * OM_p_CCB ;


 struct OM_sd_CSD
 {
 OM_S_DLINK lcq ;

 OM_p_PCD p_pcd ;


 OM_p_CCB p_ccb ;


 char          * p_addr ;


 int             key ;


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
#line 566  "/usr/ip32/exnucdp/include/OMminimum.h"
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
  struct OM_sd_create_class_args * p_create_args ;
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
  struct OM_sd_argdef * p_instance_def ;
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





 typedef struct {
                 int  active    : 1 ;

                 int  incontrol : 1 ;

                 int  nousrintr : 1 ;

                 int  step_msg  : 1 ;

                 int  step_func : 1 ;

                 int  go        : 1 ;

                 int  quit      : 1 ;

                 int  output    : 1 ;

                 int  journalin : 1 ;

                 int  journalout : 1 ;

                 int  stackon   : 1 ;

                 int  topon     : 1 ;

                 int  stackall  : 1 ;

   int  set_float : 1 ;

   int  bad_float : 1 ;

   int  dictionary : 1 ;


               } OD_S_STATWORD ;


 typedef struct {
 char * global_name ; char * global_address ; int global_size ; }
 OD_S_GLOBAL_DESCR ;


 extern OD_S_STATWORD            OD_GS_oden_status ;
 extern OD_S_GLOBAL_DESCR OD_global_var [ ] ;





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
 extern OMuword                  OM_Gw_spawn_depth ;
 extern OM_S_CSD                 * OM_GA_CSDarray ;
 extern OMuint   OM_Gf_errToStdout ;
 extern OMuint   OM_Gf_val_cluster ;
#line 8  "OMclassinit.C"
 int COpdu_OM_class_init ( ) ;
 int FC_OM_class_init ( ) ;
 int PDUstartup_OM_class_init ( ) ;

 OMuword OPP_COpdu_class_id = 65535 ;
 OMuword OPP_FC_class_id = 65535 ;
 OMuword OPP_PDUstartup_class_id = 65535 ;

 OMuword COpdu$store_answer_y_method_index ;
 OMuword FC$fill_four_col_table_method_index ;
 OMuword FC$gadget_to_mem_method_index ;
 OMuword COpdu$display_invalid_part_pointer_method_index ;
 OMuword COpdu$get_ref_filename_method_index ;
 OMuword GRvg$GRgenabsg_method_index ;
 OMuword ACcpx_defn$ACgive_temp_desc_method_index ;
 OMuword FC$button_form_input_method_index ;
 OMuword NDnode$NDget_objects_method_index ;
 OMuword COpdu$return_to_usage_default_method_index ;
 OMuword FC$define_form_insert_method_index ;
 OMuword FC$process_four_col_form_method_index ;
 OMuword FC$process_two_col_form_method_index ;
 OMuword super_cmd$form_input_method_index ;
 OMuword FC$process_login_form_method_index ;
 OMuword FIgadget$getattr_method_index ;
 OMuword FC$verify_two_col_data_method_index ;
 OMuword FC$four_col_form_input_method_index ;
 OMuword COpdu$extract_1stlevel_method_index ;
 OMuword FC$freeze_refresh_form_method_index ;
 OMuword COpdu$get_plpart_form_method_index ;
 OMuword GRcoords$GRget_oid_from_name_method_index ;
 OMuword FC$verify_four_col_data_method_index ;
 OMuword GRreffile$GRinquireref_method_index ;
 OMuword ACdb_info$ACget_db_info_method_index ;
 OMuword FC$add_a_null_three_col_row_method_index ;
 OMuword FC$security_form_input_method_index ;
 OMuword FC$update_define_form_method_index ;
 OMuword IGEgadget$add_gadget_method_index ;
 OMuword COpdu$delete_constructed_method_index ;
 OMuword COpdu$construct_ptr_method_index ;
 OMuword FIform$get_objid_for_label_method_index ;
 OMuword COpdu$disp_cmd_cancelled_method_index ;
 OMuword COpdu$mydebug_method_index ;
 OMuword FC$process_define_form_method_index ;
 OMuword FC$setup_form_2_method_index ;
 OMuword COpdu$delete_view_method_index ;
 OMuword COpdu$store_pt2_method_index ;
 OMuword GRgraphics$GRconstruct_method_index ;
 OMuword COpdu$check_attach_method_index ;
 OMuword COpdu$make_history_method_index ;
 OMuword FIform$init_form_method_index ;
 OMuword COpdu$disp_Y_or_N_msg_method_index ;
 OMuword FC$six_col_form_input_method_index ;
 OMuword FC$process_review_form_method_index ;
 OMuword FIform$unhighlight_gadgets_method_index ;
 OMuword COpdu$erase_located_method_index ;
 OMuword COpdu$delete_located_method_index ;
 OMuword FIform$display_form_method_index ;
 OMuword GRgraphics$GRchgprops_method_index ;
 OMuword FC$add_a_null_six_col_row_method_index ;
 OMuword FC$attr_form_input_method_index ;
 OMuword FC$setup_form_31_method_index ;
 OMuword COpdu$compute_nthlevel_method_index ;
 OMuword FIform$ro_gadgets_method_index ;
 OMuword COpdu$store_point_method_index ;
 OMuword FC$update_refresh_form_method_index ;
 OMuword COpdu$store_usage_method_index ;
 OMuword IGEgragad$DPinrot_method_index ;
 OMuword FC$define_form_delete_method_index ;
 OMuword FC$three_col_form_input_method_index ;
 OMuword COpdu$disconnect_located_method_index ;
 OMuword FC$update_review_screen_method_index ;
 OMuword ACcpx$find_macro_method_index ;
 OMuword COpdu$delete_local_file_method_index ;
 OMuword CEO_LOCATE$display_located_method_index ;
 OMuword COpdu$pdu_chg_wf_state_method_index ;
 OMuword FIgadget$putattr_method_index ;
 OMuword GRvg$GRpostabsg_method_index ;
 OMuword FC$adjust_scroll_buttons_method_index ;
 OMuword IGEgragad$gragad_cons_method_index ;
 OMuword FC$fill_three_col_table_method_index ;
 OMuword COpdu$continue_replace_method_index ;
 OMuword super_cmd$init_method_index ;
 OMuword FC$fill_free_header_method_index ;
 OMuword FC$process_security_form_method_index ;
 OMuword FC$verify_three_col_data_method_index ;
 OMuword FIform$erase_gadgets_method_index ;
 OMuword COpdu$bom_locate_method_index ;
 OMuword COpdu$pdu_validate_wf_method_index ;
 OMuword NDnode$NDgive_structure_method_index ;
 OMuword FIform$highlight_gadgets_method_index ;
 OMuword GRreffile$GRputdescription_method_index ;
 OMuword FC$test_expression_method_index ;
 OMuword super_cmd$execute_method_index ;
 OMuword FC$change_button_symbol_method_index ;
 OMuword COpdu$display_status_method_index ;
 OMuword FC$process_form_method_index ;
 OMuword FC$display_refresh_form_method_index ;
 OMuword FC$define_form_setup_delete_method_index ;
 OMuword COpdu$pdu_cleanup_method_index ;
 OMuword FC$login_form_input_method_index ;
 OMuword COpdu$attach_part_method_index ;
 OMuword FC$update_search_form_method_index ;
 OMuword COpdu$erase_constructed_method_index ;
 OMuword FC$process_three_col_form_method_index ;
 OMuword FC$add_a_null_two_col_row_method_index ;
 OMuword COpdu$get_algpart_form_method_index ;
 OMuword FC$process_print_form_method_index ;
 OMuword CEO_LOCATE$display_constructed_method_index ;
 OMuword FIform$rw_gadgets_method_index ;
 OMuword COpdu$delete_bom_local_files_method_index ;
 OMuword FIform$restore_gadgets_method_index ;
 OMuword COpdu$pdu_external_method_index ;
 OMuword GRtext$GRfield_inquire_method_index ;
 OMuword FC$verify_refresh_data_method_index ;
 OMuword COpdu$verify_command_method_index ;
 OMuword COpdu$store_quantity_method_index ;
 OMuword GRowner$GRadd_components_method_index ;
 OMuword COpdu$rotate_view_method_index ;
 OMuword FC$define_form_input_method_index ;
 OMuword FC$process_search_form_method_index ;
 OMuword FC$review_form_input_method_index ;
 OMuword GRreffile$GRchglevels_method_index ;
 OMuword FC$print_form_input_method_index ;
 OMuword FC$form_31_input_method_index ;
 OMuword GRvg$GRgetgeom_method_index ;
 OMuword FC$fill_six_col_table_method_index ;
 OMuword COpdu$store_status_method_index ;
 OMuword GRgraphics$GRdelete_method_index ;
 OMuword FC$save_row_method_index ;
 OMuword COpdu$get_reffile_desc_method_index ;
 OMuword FC$initialize_form_method_index ;
 OMuword COpdu$display_command_method_index ;
 OMuword FIform$erase_form_method_index ;
 OMuword NDmacro$ACgive_structure_method_index ;
 OMuword FIgadget$putcolor_method_index ;
 OMuword FIform$put_by_value_method_index ;
 OMuword COpdu$checkout_update_method_index ;
 OMuword COpdu$update_refresh_method_index ;
 OMuword FC$erase_refresh_form_method_index ;
 OMuword FC$add_a_null_four_col_row_method_index ;
 OMuword FC$process_button_form_method_index ;
 OMuword FC$search_form_input_method_index ;
 OMuword GRgencs$GRgetmatrix_method_index ;
 OMuword FC$fill_two_col_table_method_index ;
 OMuword FC$fill_free_table_method_index ;
 OMuword COpdu$pdu_internal_method_index ;
 OMuword FC$verify_six_col_data_method_index ;
 OMuword FIform$position_gadget_method_index ;
 OMuword FC$verify_row_method_index ;
 OMuword FC$two_col_form_input_method_index ;
 OMuword expression$give_formula_method_index ;
 OMuword COpdu$validate_string_method_index ;
 OMuword COpdu$close_invis_file_method_index ;
 OMuword FC$add_data_ptrs_method_index ;
 OMuword FC$refresh_form_input_method_index ;
 OMuword FIfield$setar_method_index ;
 OMuword COpdu$return_to_quantity_default_method_index ;
 OMuword ACcpx_defn$ACgive_name_method_index ;
 OMuword FC$process_attr_form_method_index ;
 OMuword FC$fill_security_table_method_index ;
 OMuword FC$define_form_replace_method_index ;
 OMuword GRgraphics$GRxform_method_index ;
 OMuword FC$define_form_cleanup_delete_method_index ;
 OMuword FC$update_define_screen_method_index ;
 OMuword FC$process_six_col_form_method_index ;
 OMuword COpdu$construct_info_method_index ;
 OMuword COpdu$store_filename_method_index ;
 OMuword FC$form_2_input_method_index ;
 OMuword GRreffile$GRgetdescription_method_index ;
 OMuword COpdu$store_answer_n_method_index ;
 OMuword COpdu$save_view_method_index ;
