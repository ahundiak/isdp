
#line 26  "/usr/include/sys/va_list.h"
 typedef void * __va_list ;
#line 21  "/usr/include/stdio_tag.h"
 typedef struct __FILE     __FILE ;
#line 22  "/usr/include/stdio_impl.h"
 typedef int ssize_t ;
#line 38  "/usr/include/stdio_impl.h"
 struct __FILE
 {




 ssize_t  _cnt ;
 unsigned char * _ptr ;

 unsigned char * _base ;
 unsigned char _flag ;
 unsigned char _file ;
 unsigned __orientation : 2 ;
 unsigned __ionolock : 1 ;
 unsigned __filler : 5 ;
 } ;
#line 75  "/usr/include/iso/stdio_iso.h"
 typedef __FILE FILE ;







 typedef unsigned int size_t ;




 typedef long  fpos_t ;
#line 147  "/usr/include/iso/stdio_iso.h"
 extern __FILE __iob [ 60    ] ;
#line 164  "/usr/include/iso/stdio_iso.h"
 extern int remove ( const char * ) ;
 extern int rename ( const char * , const char * ) ;
 extern FILE * tmpfile ( void ) ;
 extern char * tmpnam ( char * ) ;
 extern int fclose ( FILE * ) ;
 extern int fflush ( FILE * ) ;
 extern FILE * fopen ( const char * , const char * ) ;
 extern FILE * freopen ( const char * , const char * , FILE * ) ;
 extern void setbuf ( FILE * , char * ) ;
 extern int setvbuf ( FILE * , char * , int , size_t ) ;

 extern int fprintf ( FILE * , const char * , ... ) ;

 extern int fscanf ( FILE * , const char * , ... ) ;

 extern int printf ( const char * , ... ) ;

 extern int scanf ( const char * , ... ) ;

 extern int sprintf ( char * , const char * , ... ) ;

 extern int sscanf ( const char * , const char * , ... ) ;
 extern int vfprintf ( FILE * , const char * , __va_list ) ;
 extern int vprintf ( const char * , __va_list ) ;
 extern int vsprintf ( char * , const char * , __va_list ) ;
 extern int fgetc ( FILE * ) ;
 extern char * fgets ( char * , int , FILE * ) ;
 extern int fputc ( int , FILE * ) ;
 extern int fputs ( const char * , FILE * ) ;


 extern int getc ( FILE * ) ;
 extern int putc ( int , FILE * ) ;



 extern int getchar ( void ) ;
 extern int putchar ( int ) ;

 extern char * gets ( char * ) ;
 extern int puts ( const char * ) ;
 extern int ungetc ( int , FILE * ) ;
 extern size_t fread ( void * , size_t , size_t , FILE * ) ;
 extern size_t fwrite ( const void * , size_t , size_t , FILE * ) ;
 extern int fgetpos ( FILE * , fpos_t * ) ;
 extern int fseek ( FILE * , long , int ) ;
 extern int fsetpos ( FILE * , const fpos_t * ) ;
 extern long ftell ( FILE * ) ;
 extern void rewind ( FILE * ) ;


 extern void clearerr ( FILE * ) ;
 extern int feof ( FILE * ) ;
 extern int ferror ( FILE * ) ;

 extern void perror ( const char * ) ;


 extern int __filbuf ( FILE * ) ;
 extern int __flsbuf ( int , FILE * ) ;
#line 137  "/usr/include/stdio.h"
 extern unsigned char  _sibuf [ ] , _sobuf [ ] ;
#line 179  "/usr/include/stdio.h"
 extern unsigned char * _bufendtab [ ] ;
 extern FILE  * _lastbuf ;
#line 40  "/usr/include/iso/stdlib_iso.h"
 typedef struct {
 int quot ;
 int rem ;
 } div_t ;

 typedef struct {
 long quot ;
 long rem ;
 } ldiv_t ;
#line 76  "/usr/include/iso/stdlib_iso.h"
 typedef long wchar_t ;





 extern unsigned char __ctype [ ] ;


 extern void abort ( void ) ;
 extern int abs ( int ) ;
 extern int atexit ( void ( * ) ( void ) ) ;
 extern double atof ( const char * ) ;
 extern int atoi ( const char * ) ;
 extern long int atol ( const char * ) ;
 extern void * bsearch ( const void * , const void * , size_t , size_t ,
 int ( * ) ( const void * , const void * ) ) ;
 extern void * calloc ( size_t , size_t ) ;
 extern div_t div ( int , int ) ;
 extern void exit ( int ) ;
 extern void free ( void * ) ;
 extern char * getenv ( const char * ) ;
 extern long int labs ( long ) ;
 extern ldiv_t ldiv ( long , long ) ;
 extern void * malloc ( size_t ) ;
 extern int mblen ( const char * , size_t ) ;
 extern size_t mbstowcs ( wchar_t * , const char * , size_t ) ;
 extern int mbtowc ( wchar_t * , const char * , size_t ) ;
 extern void qsort ( void * , size_t , size_t ,
 int ( * ) ( const void * , const void * ) ) ;
 extern int rand ( void ) ;
 extern void * realloc ( void * , size_t ) ;
 extern void srand ( unsigned int ) ;
 extern double strtod ( const char * , char * * ) ;
 extern long int strtol ( const char * , char * * , int ) ;
 extern unsigned long int strtoul ( const char * , char * * , int ) ;
 extern int system ( const char * ) ;
 extern int wctomb ( char * , wchar_t ) ;
 extern size_t wcstombs ( char * , const wchar_t * , size_t ) ;
#line 79  "/usr/include/stdlib.h"
 typedef long uid_t ;
#line 112  "/usr/include/stdlib.h"
 extern void _exithandle ( void ) ;
#line 150  "/usr/include/stdlib.h"
 extern int mkstemp ( char * ) ;
#line 60  "/usr/include/iso/string_iso.h"
 extern int memcmp ( const void * , const void * , size_t ) ;
 extern void * memcpy ( void * , const void * , size_t ) ;
 extern void * memmove ( void * , const void * , size_t ) ;
 extern void * memset ( void * , int , size_t ) ;
 extern char * strcat ( char * , const char * ) ;
 extern int strcmp ( const char * , const char * ) ;
 extern char * strcpy ( char * , const char * ) ;
 extern int strcoll ( const char * , const char * ) ;
 extern size_t strcspn ( const char * , const char * ) ;
 extern char * strerror ( int ) ;
 extern size_t strlen ( const char * ) ;
 extern char * strncat ( char * , const char * , size_t ) ;
 extern int strncmp ( const char * , const char * , size_t ) ;
 extern char * strncpy ( char * , const char * , size_t ) ;
 extern size_t strspn ( const char * , const char * ) ;
 extern char * strtok ( char * , const char * ) ;
 extern size_t strxfrm ( char * , const char * , size_t ) ;
#line 112  "/usr/include/iso/string_iso.h"
 extern void * memchr ( const void * , int , size_t ) ;
 extern char * strchr ( const char * , int ) ;
 extern char * strpbrk ( const char * , const char * ) ;
 extern char * strrchr ( const char * , int ) ;
 extern char * strstr ( const char * , const char * ) ;
#line 20  "/usr/include/iso/math_iso.h"
 typedef union _h_val {
 unsigned long _i [ 2 ] ;
 double _d ;
 } _h_val ;


 extern const _h_val __huge_val ;
#line 37  "/usr/include/iso/math_iso.h"
 extern double acos ( double )            ;
 extern double asin ( double )            ;
 extern double atan ( double )            ;
 extern double atan2 ( double , double )                    ;
 extern double cos ( double )            ;
 extern double sin ( double )            ;
 extern double tan ( double )            ;

 extern double cosh ( double )            ;
 extern double sinh ( double )            ;
 extern double tanh ( double )            ;

 extern double exp ( double )            ;
 extern double frexp ( double , int * )                   ;
 extern double ldexp ( double , int )                 ;
 extern double log ( double )            ;
 extern double log10 ( double )            ;
 extern double modf ( double , double * )                      ;

 extern double pow ( double , double )                    ;
 extern double sqrt ( double )            ;

 extern double ceil ( double )            ;
 extern double fabs ( double )            ;
 extern double floor ( double )            ;
 extern double fmod ( double , double )                    ;
#line 15  "/opt/ingr/exnucdp/include/OMtypes.h"
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
#line 78  "/opt/ingr/exnucdp/include/OMminimum.h"
 struct OM_sd_objecthdr
 {
  OM_S_OBJID   oid ;
#line 91  "/opt/ingr/exnucdp/include/OMminimum.h"
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
#line 216  "/opt/ingr/exnucdp/include/OMminimum.h"
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
#line 305  "/opt/ingr/exnucdp/include/OMminimum.h"
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
#line 500  "/opt/ingr/exnucdp/include/OMminimum.h"
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
#line 84  "/opt/ingr/exnucdp/include/OMprimitives.h"
 extern char * som_calloc ( OMuint number , OMuint size )                               ;
 extern int som_cancel_intercept ( OMuword osnum , OM_S_OBJID objid )                                    ;
 extern int som_change_class ( OMuword osnum , OM_S_OBJID objid , char * classname , OMuint sd_override )
                                       ;
 extern int som_change_os_name ( OMuword OSnum , char * name , OM_e_OVRWRT_FLG overwrite )
                             ;
 extern int som_change_os_name_by_name ( char * curr_name , char * name , OM_e_OVRWRT_FLG overwrite )
                             ;
 extern int som_change_tag_version ( OMuword osnum , OM_S_OBJID objid , OMuword version , OMbyte flag )
                                ;
 extern int som_channel_preset ( OMuword os , OM_S_OBJID oid , OM_p_CHANSELECT p_chansel , OMuint size )
                                          ;
 extern int som_channel_unpreset ( OMuword os , OM_S_OBJID oid , OM_p_CHANSELECT p_chansel , int collapse_flag )
                                                ;
 extern int som_construct_and_copy ( OM_p_OBJECTHDR p_object , OM_S_OBJID objid , OMuword obj_osnum , OMuword osnum , char * osname , OM_S_NEIGHBOR neighbor , OM_p_OBJID p_objid , OMuint * p_tag )


                 ;
 extern int som_construct_object ( char * classname , OMuword classid , OM_S_OBJID objid , OM_p_OBJECTHDR p_object , OMuword obj_osnum , OMuword osnum , char * osname , OM_p_OBJID p_objid , OM_p_MESSAGE msg , OM_S_NEIGHBOR neighbor , OMuint * p_tag )


                                                           ;
 extern int som_construct_os ( OMuint classid , uword * osnum , char * osname , OM_p_OBJID p_objid , OMuint initcount , OMuint extcount , OMuint * resultcount , OMuint maxobjsize , OMuint loadmode , char sameosflag , char * di_logical )


                                     ;
 extern int som_construct_os_by_name ( char * classname , uword * osnum , char * osname , OM_p_OBJID p_objid , OMuint initcount , OMuint extcount , OMuint * resultcount , OMuint maxobjsize , OMuint loadmode , char sameosflag , char * di_logical )


                                                      ;
 extern int som_convert_internal_osname_to_number ( char * name , OMuword * OSnum )
                  ;
 extern int som_convert_number_to_internal_osname ( OMuword OSnum , char * name )
              ;
 extern int som_convert_os_name_to_number ( char * name , OMuword * OSnum )                               ;
 extern int som_convert_os_number_to_name ( OMuword OSnum , char * name )                              ;
 extern int som_create_big_object ( OMuword clusterid , OMuint size , OM_p_OSD p_osd , OM_p_OBJECTHDR * p_instance , OM_p_CSD * p_csd )
                                                               ;
 extern void som_dealloc ( void * ptr )              ;
 extern int som_disable_intercept ( OMuword osnum , OM_S_OBJID objid )                                    ;
 extern int som_dynamic_class ( char * p_parent_class [ ] , OMuword num_parents , OMuword maj_version , OMuword min_version , char * p_dynamic_class )

                         ;
 extern int som_dynamic_load ( char * object_file )                      ;
 extern int som_enough_disk_space ( OMuword input_osnum , char * osname , char * filename , int filesize )
                                ;
 extern int som_flagged_tag_connects ( OMuword osnum , OMuword tag_osnum , OMuint * p_count , OMuint size , OM_p_TAG_CON_INFO p_tag_info , OMuword mask )

                ;
 extern int som_getClusterFromObject ( OMuword * pClustNum , OMuint objid , OMuword osnum )
                 ;
 extern int som_get_all_parents ( OMuword classid , char * classname , OMuword parent_list [ ] , OMuint size , OMuint * count )
                                                     ;
 extern int som_get_channel_count ( OMuword osnum , OM_S_OBJID objid , OM_p_OBJECTHDR p_object , OM_p_CHANSELECT p_chanselect , OMuint * count )

                 ;
 extern int som_get_channel_name ( char * channame , OM_S_CHANNUM channum )                                         ;
 extern int som_get_channel_number ( char * channame , OM_p_CHANNUM p_channum )                                           ;
 extern int som_get_channel_objects ( OMuword osnum , OM_S_OBJID objid , OM_p_OBJECTHDR p_object , OM_p_CHANSELECT p_chanselect , OM_S_OBJECT_LINKAGE list [ ] , OMuint size , OMuint * count )

                                                          ;
 extern int som_get_classid ( OMuword OSnum , char * classname , OM_S_OBJID objid , OM_p_OBJECTHDR p_object , OMuword * p_classid )
                                                                 ;
 extern int som_get_classname ( OMuword OSnum , OMuword classid , OM_S_OBJID objid , OM_p_OBJECTHDR p_object , char * classname )
                                                              ;
 extern int som_get_index ( OMuword osnum_c , OM_S_OBJID objid_c , OM_p_OBJECTHDR p_object_c , OM_p_CHANSELECT p_chanselect , OM_S_OBJID objid , OMuword osnum2 , OMuint * index )

                                                   ;
 extern int som_get_intercept ( OMuword osnum , OM_S_OBJID objid , OMuword * p_target_osnum , OM_p_OBJID p_target_objid )
                                                      ;
 extern int som_get_mem_info ( int * avail_swap , int * total_swap , int * phys_mem , int * avail_om , int * total_om , int * total_free )
                                                                ;
 extern int som_get_message_name ( char * classname , OMuword classid , OMuword method_index , char * msg_name )
                                        ;
 extern int som_get_objid_at_index ( OMuword osnum_c , OM_S_OBJID objid_c , OM_p_OBJECTHDR p_object_c , OM_p_CHANSELECT p_chanselect , OMuint index , OM_S_OBJID * objid , OMuword * osnum2 )

                                                    ;
 extern int som_get_os_senddepth ( OMuword OSnum , OMuint * depth )                                 ;
 extern int som_get_parent_classid ( OMuword classid , char * classname , OMuword * parent_classid )
                           ;
 extern int som_get_parent_classname ( OMuword classid , char * classname , char * parent_classname )
                          ;
 extern int som_get_parent_count ( OMuword classid , char * classname , OMuword * parent_count )
                         ;
 extern int som_get_senddepth ( OMuword osnum , OM_S_OBJID objid , OMuword * p_depth )
                    ;
 extern int som_inquire_os ( OMuword osnum , OM_p_DUPINTOS * pp_dup )                                         ;
 extern int som_is_ancestry_valid ( OMuword sub_classid , OMuword super_classid , char * sub_classname , char * super_classname )

                         ;
 extern int som_is_objid_on_channel ( OMuword osnum_c , OM_S_OBJID objid_c , OM_p_OBJECTHDR p_object_c , OM_p_CHANSELECT p_chanselect , OM_S_OBJID objid , OMuword osnum2 )

                                    ;
 extern int som_is_objid_valid ( OMuword OSnum , OM_S_OBJID objid )                                    ;
 extern int som_make_chanselect ( char * channame , OM_S_CHANNUM channum , OM_p_CHANNEL_HDR * chanaddr , OM_p_CHANSELECT p_chanselect )
                                                            ;
 extern int som_make_message ( char * class_name , OMuword classid , char * meth_name , OMuword size , void * p_arglist , OM_p_MESSAGE p_msg )

                      ;
 extern int som_make_neighbor ( OMuword osnum , OM_S_OBJID objid , OM_p_NEIGHBOR p_neighbor )
                            ;
 extern char * som_malloc ( OMuint size )                ;
 extern int som_move_tag ( OMuword osnum , OM_S_OBJID old_objid , OM_S_OBJID new_objid )
                        ;
 extern int som_objid_to_tag ( OMuword osnum , OM_S_OBJID objid , OMuint * p_tag , OMuword * p_version , OMuint * p_index , void * tag_rec , OMuint * p_free , OMuword * * pp_version )

                                                       ;
 extern int som_osnum_to_oso_objid ( OMuword osnum , OM_p_OBJID p_objid )                                      ;
 extern int som_parse_channame ( char * channame , char * s_class , char * s_channel )
                   ;
 extern char * som_realloc ( char * ptr , OMuint size )                           ;
 extern int som_remove_object_tag ( OMuword osnum , OM_p_OBJECTHDR p_object , OM_S_OBJID objid )
                    ;
 extern int som_report_class_version ( OMuword classid , char * classname , OMuword * major , OMuword * minor )
                                  ;
 extern void som_report_error ( OMulong sts )                ;
 extern int som_report_version ( OMuword * major , OMuword * minor )                                   ;
 extern int som_runtime_init ( int paramc , char * param_list [ ] )                                   ;
 extern int som_send_channel ( OM_E_WRT_FLAG WRT_flag , OM_p_MESSAGE msg , OMuword osnum , OM_S_OBJID senderid , OM_p_CHANSELECT p_chansel , int frm , int to )

                   ;
 extern int som_send_foreign ( OM_E_WRT_FLAG WRT_flag , OM_p_MESSAGE msg , OM_S_OBJID senderid , OM_S_OBJID targetid , OMuword osnum , OM_S_CHANNUM in_channum )

                           ;
 extern int som_send_object ( OM_E_WRT_FLAG wrt_flag , OM_p_MESSAGE msg , OM_S_OBJID senderid , OM_S_OBJID targetid , OM_S_CHANNUM channum )

                        ;
 extern int som_set_dynamic_defaults ( int paramc , char * param_list [ ] )                                   ;
 extern int som_set_intercept ( OMuword osnum , OM_S_OBJID objid , OMuword target_osnum , OM_S_OBJID target_objid )
                                                 ;
 extern void som_set_os_type ( OMuword osnum , int * p_num , unsigned char flag )                                                  ;
 extern int som_set_tag_os ( OMuword * p_prev_osnum , OMuword osnum )                                         ;
 extern int som_sibling_send ( OM_E_WRT_FLAG WRT_flag , OM_p_MESSAGE msg , OM_S_OBJID senderid , OM_p_CHANSELECT p_chansel , OM_E_INC_FLAG inclusive )

                           ;
 extern char * som_sm_calloc ( unsigned nelem , unsigned elsize )                                    ;
 extern void som_sm_dealloc ( void * ptr )              ;
 extern char * som_sm_malloc ( unsigned request )                     ;
 extern char * som_sm_realloc ( char * ptr , unsigned nbytes )                               ;
 extern int som_tag_object ( OMuword osnum , OM_p_OBJECTHDR p_object , OM_S_OBJID objid , OMuint * p_tag )
                                   ;
 extern int som_tag_to_objid ( OMuword osnum , OMuint tag , OM_p_OBJID p_objid , OMuword * p_version )
                      ;
 extern int som_test_connection ( OMuword osnum , OM_S_OBJID objid , OM_p_CHANSELECT csel , OMuword tag_osnum , OM_S_OBJID tag_objid , OM_p_CHANSELECT tag_csel , OMuword * p_version , OMuword * p_tag_version , int force_flag )


                                          ;
 extern int som_vla_set_dimension ( int * p_offset , unsigned int * p_count , OMuint dim , OMuword osnum , OM_S_OBJID objid , OM_p_CLASSDEF p_acld , int move_data )

                                                     ;
 extern int OMpms_prnt ( char * format , ... )                      ;
 extern int OMpms_prntHdr ( char * format , ... )                      ;
#line 35  "/opt/ingr/exnucdp/include/OMcluster.h"
 extern OMuint OM_Gi_faultinTicks ;
 extern OMuint OM_Gi_faultinBytes ;
 extern OMuint OM_Gi_numFaults ;
#line 101  "/opt/ingr/exnucdp/include/OMcluster.h"
 struct OM_sd_FCDs_average
 {
  double find_avg ;
  double num_finds ;
 } ;
 typedef struct OM_sd_FCDs_average OM_S_FCDs_AVG ;
 typedef struct OM_sd_FCDs_average * OM_p_FCDs_AVG ;
#line 80  "/opt/ingr/exnucdp/include/OMmacros.h"
 extern int blkmv ( int n , char * s , char * d )                            ;
 extern int som_ISO_fetch ( OMuword OSnum1 , OMuword index , OM_S_OBJID iso_objid , OMuword * OSnum2 , OM_S_OBJID * objid , OM_p_CHANNUM chan , OMuword * flags )

                                     ;
 extern int som_vla_set_dimension ( int * p_offset , unsigned int * p_count , OMuint dim , OMuword osnum , OM_S_OBJID objid , OM_p_CLASSDEF p_acld , int move_data )

                                       ;
#line 59  "/opt/ingr/exnucdp/include/igetypedef.h"
   typedef  OM_S_OBJID GRobjid ;
   typedef  OM_S_OBJECT_LINKAGE GRobjlink ;
   typedef  uword GRspacenum ;
   typedef  uword GRclassid ;
   typedef  uword GRchannum ;
   typedef  OM_S_OBJECTHDR GRobjecthdr ;
#line 18  "/opt/ingr/bspmathdp/include/igrtypedef.h"
 typedef short IGRboolean ;
 typedef short  IGRshort ;
 typedef long   IGRlong ;
 typedef int    IGRint ;
 typedef double  IGRdouble ;
 typedef char IGRchar ;
 typedef unsigned char   IGRuchar ;
 typedef unsigned short IGRushort ;
 typedef unsigned int IGRuint ;
 typedef unsigned long IGRulong ;

 typedef  IGRdouble  IGRvector [ 3 ] ;

 typedef  IGRdouble  IGRmatrix [ 16 ] ;

 typedef  IGRdouble  IGRpoint [ 3 ] ;
#line 24  "/opt/ingr/bspmathdp/include/igr.h"
 struct IGRline
 {
 IGRdouble  * point1 ;
 IGRdouble  * point2 ;
 } ;

 struct IGRline_seg
 {
 IGRdouble * beg_point ;
 IGRdouble * end_point ;

 } ;

 struct IGRpolyline
 {
 IGRlong   num_points ;
 IGRdouble * points ;

 } ;

 struct IGRset_polyline
 {
 IGRlong num_comps ;
 struct IGRpolyline * comp_polys ;

 struct IGRpolyline polyline ;

 } ;

 struct IGRarc
 {
 IGRdouble prim_axis ;
 IGRdouble sec_axis ;
 IGRdouble origin [ 3 ] ;
 IGRdouble rot_matrix [ 16 ] ;

 IGRdouble start_angle ;


 IGRdouble sweep_angle ;
 } ;

 struct IGRellipse
 {
 IGRdouble prim_axis ;
 IGRdouble sec_axis ;
 IGRdouble origin [ 3 ] ;
 IGRdouble rot_matrix [ 16 ] ;

 } ;

 struct IGRcone
 {
 IGRdouble base_radius ;
 IGRdouble base_origin [ 3 ] ;
 IGRdouble top_radius ;
 IGRdouble top_origin [ 3 ] ;
 IGRdouble rot_matrix [ 16 ] ;

 } ;

 struct IGRptstring
 {
 struct IGRpolyline polyline ;
 double * matrix_array ;

 } ;

 struct IGRlbsys
 {
 IGRdouble matrix [ 16 ] ;


 IGRdouble diag_pt1 [ 3 ] ;
 IGRdouble diag_pt2 [ 3 ] ;
 } ;

 struct IGRsymboldef
 {
   IGRdouble   diag_pt1 [ 3 ] ;
   IGRdouble   diag_pt2 [ 3 ] ;
 } ;

 struct IGRsymbol
 {
   IGRdouble   matrix [ 16 ] ;


 } ;

 struct IGRbsp_curve
 {
 IGRshort   order ;
 IGRboolean periodic ;

 IGRboolean non_uniform ;

 IGRlong    num_poles ;
 IGRdouble  * poles ;
 IGRlong    num_knots ;
 IGRdouble  * knots ;
 IGRboolean rational ;

 IGRdouble  * weights ;

 IGRboolean planar ;
 IGRboolean phy_closed ;
 IGRshort   num_boundaries ;

 IGRdouble  * bdrys ;



 } ;

 struct IGRbc_bdrys
 {
 IGRshort   num_boundaries ;

 IGRdouble  * bdrys ;



 } ;

 struct IGRbsp_bdry_pts
 {
 IGRlong   num_points ;

 IGRdouble * points ;

 } ;

 struct IGRbsp_surface
 {
 IGRshort   u_order ;
 IGRshort   v_order ;
 IGRboolean u_periodic ;


 IGRboolean v_periodic ;


 IGRboolean u_non_uniform ;


 IGRboolean v_non_uniform ;


 IGRlong    u_num_poles ;

 IGRlong    v_num_poles ;

 IGRdouble  * poles ;

 IGRlong    u_num_knots ;
 IGRdouble  * u_knots ;
 IGRlong    v_num_knots ;
 IGRdouble  * v_knots ;
 IGRboolean rational ;

 IGRdouble  * weights ;

 IGRboolean planar ;
 IGRboolean u_phy_closed ;
 IGRboolean v_phy_closed ;
 IGRboolean pos_orient ;
 IGRboolean on_off ;




 IGRshort   num_boundaries ;

 struct IGRbsp_bdry_pts
       * bdrys ;
 } ;

 struct IGRrt_prism
 {
 IGRdouble matrix [ 16 ] ;


 struct IGRpolyline polygon ;



 IGRdouble height ;

 } ;

 struct IGRcv_prism
 {
 IGRdouble matrix [ 16 ] ;


 struct IGRbsp_curve curve ;



 IGRdouble height ;

 } ;

 struct IGRpolygon
 {
 IGRlong   num_points ;
 IGRdouble * points ;

 } ;

 struct IGRcurve
 {
 IGRlong   num_points ;
 IGRdouble * points ;

 } ;
#line 252  "/opt/ingr/bspmathdp/include/igr.h"
 struct IGRplane
 {
 IGRdouble  * point ;
 IGRdouble  * normal ;
 } ;

 struct IGRpointset
 {
 IGRlong    num_points ;
 IGRdouble  * points ;

 } ;
#line 58  "/opt/ingr/grnucdp/include/igrdp.h"
 struct IGRdisplay
 {
 short    unsigned  color ;
 IGRuchar           weight ;
 IGRuchar           style ;
 } ;

 struct IGRaltdisplay
 {
 IGRuint            * rgb_value ;
 short    unsigned  * color ;
 IGRuchar           * weight ;
 IGRuchar           * style ;
 } ;

 union IGRgeometries
 {
 IGRpoint point ;
 struct IGRline * line ;
 struct IGRline_seg * lineseg ;
 struct IGRpolyline * polyline ;
 struct IGRpolygon * polygon ;
 struct IGRarc * arc ;
 struct IGRellipse * ellipse ;
 struct IGRcone * cone ;
 struct IGRptstring * ptstring ;
 struct IGRlbsys * lbsys ;
 struct IGRcurve * curve ;
 struct IGRbsp_curve * bspcurve ;
 struct IGRbsp_surface * bspsurf ;
 struct IGRrt_prism * prism ;
 struct IGRcv_prism * cv_prism ;
 } ;







 struct IGRespy
 {
 IGRboolean is_closed ;
 } ;

 struct IGRescn
 {
 IGRboolean is_surface ;
 } ;

 struct IGResps
 {
 IGRboolean is_connected ;
 } ;

 struct IGResbc
 {
 IGRboolean is_polydis ;
 IGRboolean is_curvedis ;
 } ;

 struct IGResbs
 {
 IGRlong    u_rules ;

 IGRlong    v_rules ;

 IGRboolean is_polydis ;
 IGRboolean is_surfdis ;
 IGRboolean is_slowdis ;


 IGRshort   type ;
 } ;

 struct IGResqbs
 {
 IGRlong    u_rules ;

 IGRlong    v_rules ;

 IGRboolean is_polydis ;
 IGRboolean is_surfdis ;
 IGRboolean is_slowdis ;


 IGRshort   type ;
 IGRboolean rules_specified ;

 IGRdouble  * u_rule_values ;

 IGRdouble  * v_rule_values ;

 IGRint    * u_num_bound ;
 IGRint    * v_num_bound ;
 IGRdouble  * * u_bdrys ;







 IGRdouble  * * v_bdrys ;







 } ;

 struct IGRestx
 {
        IGRshort   font ;
        IGRshort   just ;

 IGRdouble  width ;
 IGRdouble  height ;
        IGRshort   flag ;
        IGRshort   num_char ;
        IGRdouble  line_spac ;

        IGRdouble  char_spac ;

        IGRshort   text_length ;

 } ;


 struct IGResintx
 {
 IGRshort   font_id ;

 IGRchar    just_moves [ 20 ] ;
 IGRint    flags ;
 IGRshort   prev_font ;

 struct IGRestx * estx ;

        IGRchar    * text_string ;

 } ;

 struct IGResrs

 {
 IGRshort index ;
 IGRboolean ( * function ) ( ) ;
 struct IGRfastrasdis
   * rasdis_ptr ;
 IGRboolean trans_display ;

 IGRchar * info ;
 IGRboolean ( * getln ) ( ) ;
 IGRint    ( * stopdraw ) ( ) ;
 unsigned short min_color ;
 unsigned long min_rgb ;
 unsigned short max_color ;
 unsigned long max_rgb ;
 unsigned long back_mask ;
 unsigned long hi_mask ;
 unsigned short dis_flags ;
 IGRshort num_bits ;
 IGRshort max_table_index ;
 IGRchar maptype ;
 IGRint mapdim ;
 IGRchar * primmap ;
 IGRchar * premap ;
 IGRchar * postmap ;
 IGRchar * greenrec ;
 IGRchar * premapg ;
 IGRchar * postmapg ;
 IGRchar * bluerec ;
 IGRchar * premapb ;
 IGRchar * postmapb ;
 IGRshort * abscolor ;
 IGRchar * res1 ;
 IGRchar * res2 ;
 } ;

 union IGRele_attr
 {
 struct IGRescn * cone ;
 struct IGResps * ptset ;
 struct IGResbc * bspcurve ;
 struct IGResbs * bspsurf ;
 struct IGResqbs * bsqsurf ;
 struct IGResintx * text ;
 struct IGResrs * raster ;
 char * null ;
 } ;
#line 20  "/opt/ingr/grnucdp/include/gr.h"
   struct GRid
   {
  GRspacenum osnum ;
 GRobjid    objid ;
   } ;


   struct GRmdenv_info
   {
 IGRshort matrix_type ;
 IGRmatrix matrix ;
   } ;

   struct GRmd_env
   {
       struct GRid     md_id ;
       struct GRmdenv_info   md_env ;
   } ;

   struct GRobjid_set
   {
       IGRint  num_ids ;
       GRobjid  * objids ;
   } ;
#line 19  "/opt/ingr/grnucdp/include/growner.h"
 struct GRobj_env
 {
   struct GRid       obj_id ;
   struct GRmd_env   mod_env ;
 } ;





 struct GRclip_args
 {
   IGRlong           * msg ;
   struct GRmd_env   * mod_env ;
   struct GRmd_env   * target_env ;
   IGRchar           * prism ;
   struct GRid       * inside_id ;
   struct GRid       * outside_id ;
   struct GRid       * overlap_id ;
   IGRlong           * clip_flag ;
 } ;
#line 28  "/opt/ingr/grnucdp/include/go.h"
 typedef double GRrange [ 6 ] ;
 typedef char   GRname [ 1023       ] ;

 enum GRdyn_flag { return_buf , free_buff , call_dynam } ;

 struct GRsymbology
 {
    struct IGRdisplay display_attr ;
    short             level ;
 } ;

 struct GRvg_construct
 {
  long    * msg ;
 struct GRmd_env   * env_info ;
  IGRboolean    newflag ;


 short            level ;
 unsigned short    properties ;
  char    * geometry ;
 struct IGRdisplay * display ;
 char    * class_attr ;
 char    * name ;
 } ;

 struct GRprops
 {
 short  type ;
 short     subtype ;

 IGRboolean closed ;

 IGRboolean phy_closed ;

 IGRboolean is_segmented ;
 IGRboolean planar ;

 } ;

 struct GRabsg_hdr
 {
 long  whole_size ;
 long   geometry_size ;
 struct GRid id ;
 short  matrix_type ;
 IGRmatrix matrix ;
 } ;

 struct GRparms
 {
 double     u ;
 double     v ;
 IGRboolean polygon_inx ;
#line 92  "/opt/ingr/grnucdp/include/go.h"
 struct GRid leaf_id ;
 } ;


 struct GRpost_info
 {
  IGRboolean construct_flag ;
 } ;


 struct GRobj_info
 {
 char type [ 512              ] ;
 } ;







 struct GRfunction_info
 {
    struct GRmd_env   * md_env ;
    IGRboolean       pass_to_other_spaces ;


    char       * info ;

 } ;
#line 40  "/opt/ingr/exnucdp/include/exfi.h"
 struct EXFI_subform_st
 {
    int label ;
    int x ;
    int y ;
    OM_S_OBJID objid ;
 } ;

 struct EXFI_mouse_st
 {
    int x ;
    int y ;
    short numb ;
    short click ;
    short down ;
 } ;

 struct EXFI_data_st
 {
    int label ;
    int type ;
    int index ;
    int max_index ;
    int select_flag ;




    int sts ;
    union
    {
 OM_S_OBJID objid ;
 char state ;
 int ivalue ;
 double dvalue ;
 char alpha [ 132        ] ;
 struct EXFI_subform_st subform ;
 struct EXFI_mouse_st btn ;
    } value ;
 } ;
#line 37  "/opt/ingr/exnucdp/include/ex.h"
 extern OM_S_OBJID EX_active_module ;
 extern OMuword EX_active_OS_num ;
 extern int active_module_num ;
 extern OMuword OM_Gw_max_modules ;
 extern OMuword OM_Gw_max_ref_files ;

 extern int EX_max_modules ;
 extern int EX_max_ref_files ;



 struct  EX_button
 {
    IGRdouble   x ;
    IGRdouble   y ;
    IGRdouble   z ;
    IGRlong     window ;
    OM_S_OBJID  objid ;
    uword       osnum ;
    IGRshort    numb ;
    IGRshort    clicks ;
    IGRshort    button_down ;
 } ;


 struct EX_mouse
 {
    int window ;
    short x ;
    short y ;
    int wflag ;
 } ;


 struct module_params
 {
  int visible_flag ;
  OM_S_OBJID module_id ;
  char CS_OS_name [ 128               ] ;
 } ;

 struct module_instance_data
 {
  int visible_flag ;
 } ;

 struct EX_visible_module
 {
  uword obj_space_num ;
  OM_S_OBJID module_my_id ;
  OM_S_OBJID filed_id ;
  int        permis_flag ;
  int        no_scn_menu ;

 } ;

 struct EX_invisible_module
 {
  uword obj_space_num ;
  OM_S_OBJID module_my_id ;
  OM_S_OBJID filed_id ;
  int permis_flag ;
  int numof_opens ;
  int ref_flag ;
 } ;

 struct EX_global
 {
    IGRchar   filename [ 128               ] ;



    IGRchar   working_dir [ 128               ] ;

    IGRchar   support_dir [ 128               ] ;

    IGRint    module_type ;
 } ;

 struct EX_var_list
 {
    IGRint    var ;
    IGRchar   * var_value ;
    IGRint    * num_bytes ;




 } ;


 struct EXlstcol
 {
 IGRint stat ;
 OM_S_OBJID oid ;
 IGRchar string [ 256 ] ;
 } ;


 struct EXlstfnt
 {
 IGRint     fontid ;
 IGRdouble   size ;
 IGRdouble   rotation ;
 IGRchar     typeface [ 64 ] ;
 IGRint     len ;
 } ;


 struct EX_form_data_st
 {
    char form_name [ 20 ] ;
    struct EXFI_data_st data ;
 } ;


 struct EX_cmd
 {
    IGRchar * msg_key_ptr ;
    IGRchar * command_name_ptr ;
    int command_nbytes ;
    IGRchar command_key [ 13 ] ;
    IGRchar class_name [ 13 ] ;
    IGRlong type ;
    IGRlong exec_flag ;
    IGRlong immediate_flag ;

    IGRchar * path ;
    IGRchar * input_string ;
    IGRlong invis_cmd ;

    IGRchar * dload_name_ptr ;
 } ;









 struct EX_echo_button
 {
   OM_S_OBJID   objid ;
   OMuword      osnum ;
   int              x ;
   int              y ;
   int          btype ;
   int          state ;
   int        timetag ;
 } ;
 struct EX_funnode
 {
    int isfun ;
    union {
      int  ( * fun ) ( ) ;
      char * cmdkey ;
    } entry ;
    struct EX_funnode * next ;
    struct EX_funnode * prev ;
 } ;
#line 28  "/usr/include/ia32/sys/machtypes.h"
 typedef unsigned char lock_t ;
#line 62  "/usr/include/sys/int_types.h"
 typedef char   int8_t ;





 typedef short   int16_t ;
 typedef int   int32_t ;








 typedef unsigned char  uint8_t ;
 typedef unsigned short  uint16_t ;
 typedef unsigned int  uint32_t ;
#line 97  "/usr/include/sys/int_types.h"
 typedef int32_t   intmax_t ;
 typedef uint32_t  uintmax_t ;
#line 110  "/usr/include/sys/int_types.h"
 typedef int   intptr_t ;
 typedef unsigned int  uintptr_t ;







 typedef char   int_least8_t ;





 typedef short   int_least16_t ;
 typedef int   int_least32_t ;








 typedef unsigned char  uint_least8_t ;
 typedef unsigned short  uint_least16_t ;
 typedef unsigned int  uint_least32_t ;
#line 57  "/usr/include/sys/types.h"
 typedef union {
 double _d ;
 int32_t _l [ 2 ] ;
 } longlong_t ;
 typedef union {
 double  _d ;
 uint32_t _l [ 2 ] ;
 } u_longlong_t ;
#line 76  "/usr/include/sys/types.h"
 typedef long  t_scalar_t ;
 typedef unsigned long t_uscalar_t ;





 typedef unsigned char uchar_t ;
 typedef unsigned short ushort_t ;
 typedef unsigned int uint_t ;
 typedef unsigned long ulong_t ;

 typedef char  * caddr_t ;
 typedef long  daddr_t ;
 typedef short  cnt_t ;


 typedef ulong_t  paddr_t ;









 typedef int ptrdiff_t ;






 typedef ulong_t  pfn_t ;
 typedef ulong_t  pgcnt_t ;
 typedef long  spgcnt_t ;

 typedef uchar_t  use_t ;
 typedef short  sysid_t ;
 typedef short  index_t ;
 typedef void  * timeout_id_t ;
 typedef void  * bufcall_id_t ;
#line 132  "/usr/include/sys/types.h"
 typedef long  off_t ;
#line 148  "/usr/include/sys/types.h"
 typedef ulong_t  ino_t ;
 typedef long  blkcnt_t ;
 typedef ulong_t  fsblkcnt_t ;
 typedef ulong_t  fsfilcnt_t ;
#line 176  "/usr/include/sys/types.h"
 typedef long  blksize_t ;



 typedef enum { _B_FALSE , _B_TRUE } boolean_t ;
#line 196  "/usr/include/sys/types.h"
 typedef union {
 double   _d ;
 int32_t  _l [ 2 ] ;
 } pad64_t ;
 typedef union {
 double   _d ;
 uint32_t _l [ 2 ] ;
 } upad64_t ;


 typedef longlong_t offset_t ;
 typedef u_longlong_t u_offset_t ;
 typedef u_longlong_t len_t ;
 typedef longlong_t diskaddr_t ;







 typedef union {
 offset_t _f ;
 struct {
  int32_t _l ;
  int32_t _u ;
 } _p ;
 } lloff_t ;
#line 237  "/usr/include/sys/types.h"
 typedef union {
 diskaddr_t _f ;
 struct {
  int32_t _l ;
  int32_t _u ;
 } _p ;
 } lldaddr_t ;
#line 256  "/usr/include/sys/types.h"
 typedef uint_t k_fltset_t ;
#line 270  "/usr/include/sys/types.h"
 typedef long  id_t ;






 typedef uint_t  useconds_t ;



 typedef long suseconds_t ;









 typedef ulong_t major_t ;
 typedef ulong_t minor_t ;





 typedef short pri_t ;
#line 311  "/usr/include/sys/types.h"
 typedef ushort_t o_mode_t ;
 typedef short o_dev_t ;
 typedef ushort_t o_uid_t ;
 typedef o_uid_t o_gid_t ;
 typedef short o_nlink_t ;
 typedef short o_pid_t ;
 typedef ushort_t o_ino_t ;





 typedef int key_t ;



 typedef ulong_t mode_t ;
#line 339  "/usr/include/sys/types.h"
 typedef uid_t gid_t ;

 typedef id_t    taskid_t ;
 typedef id_t    projid_t ;






 typedef uint_t pthread_t ;
 typedef uint_t pthread_key_t ;

 typedef struct _pthread_mutex {
 struct {
  uint16_t __pthread_mutex_flag1 ;
  uint8_t  __pthread_mutex_flag2 ;
  uint8_t  __pthread_mutex_ceiling ;
  uint16_t  __pthread_mutex_type ;
  uint16_t  __pthread_mutex_magic ;
 } __pthread_mutex_flags ;
 union {
  struct {
   uint8_t __pthread_mutex_pad [ 8 ] ;
  } __pthread_mutex_lock64 ;
  struct {
   uint32_t __pthread_ownerpid ;
   uint32_t __pthread_lockword ;
  } __pthread_mutex_lock32 ;
  upad64_t __pthread_mutex_owner64 ;
 } __pthread_mutex_lock ;
 upad64_t __pthread_mutex_data ;
 } pthread_mutex_t ;

 typedef struct _pthread_cond {
 struct {
  uint8_t  __pthread_cond_flag [ 4 ] ;
  uint16_t  __pthread_cond_type ;
  uint16_t  __pthread_cond_magic ;
 } __pthread_cond_flags ;
 upad64_t __pthread_cond_data ;
 } pthread_cond_t ;




 typedef struct _pthread_rwlock {
 int32_t  __pthread_rwlock_readers ;
 uint16_t __pthread_rwlock_type ;
 uint16_t __pthread_rwlock_magic ;
 upad64_t __pthread_rwlock_pad1 [ 3 ] ;
 upad64_t __pthread_rwlock_pad2 [ 2 ] ;
 upad64_t __pthread_rwlock_pad3 [ 2 ] ;
 } pthread_rwlock_t ;




 typedef struct {
 void * __pthread_attrp ;
 } pthread_attr_t ;




 typedef struct {
 void * __pthread_mutexattrp ;
 } pthread_mutexattr_t ;




 typedef struct {
 void * __pthread_condattrp ;
 } pthread_condattr_t ;




 typedef struct {
 upad64_t __pthread_once_pad [ 4 ] ;
 } pthread_once_t ;





 typedef struct {
 void * __pthread_rwlockattrp ;
 } pthread_rwlockattr_t ;

 typedef ulong_t dev_t ;





 typedef ulong_t nlink_t ;
 typedef long pid_t ;
#line 460  "/usr/include/sys/types.h"
 typedef long  time_t ;




 typedef long  clock_t ;




 typedef int clockid_t ;




 typedef int timer_t ;
#line 68  "/usr/include/X11/X.h"
 typedef unsigned long XID ;
 typedef unsigned long Mask ;
 typedef unsigned long Atom ;
 typedef unsigned long VisualID ;
 typedef unsigned long Time ;









 typedef XID Window ;
 typedef XID Drawable ;
 typedef XID Font ;
 typedef XID Pixmap ;
 typedef XID Cursor ;
 typedef XID Colormap ;
 typedef XID GContext ;
 typedef XID KeySym ;

 typedef unsigned char KeyCode ;
#line 70  "/usr/include/X11/Xlib.h"
 typedef char * XPointer ;
#line 142  "/usr/include/X11/Xlib.h"
 typedef struct _XExtData {
 int number ;
 struct _XExtData * next ;

 int ( * free_private ) ( struct _XExtData * ) ;



 XPointer private_data ;
 } XExtData ;




 typedef struct {
 int extension ;
 int major_opcode ;
 int first_event ;
 int first_error ;
 } XExtCodes ;





 typedef struct {
    int depth ;
    int bits_per_pixel ;
    int scanline_pad ;
 } XPixmapFormatValues ;





 typedef struct {
 int function ;
 unsigned long plane_mask ;
 unsigned long foreground ;
 unsigned long background ;
 int line_width ;
 int line_style ;
 int cap_style ;

 int join_style ;
 int fill_style ;

 int fill_rule ;
 int arc_mode ;
 Pixmap tile ;
 Pixmap stipple ;
 int ts_x_origin ;
 int ts_y_origin ;
        Font font ;
 int subwindow_mode ;
 int  graphics_exposures ;
 int clip_x_origin ;
 int clip_y_origin ;
 Pixmap clip_mask ;
 int dash_offset ;
 char dashes ;
 } XGCValues ;






 typedef struct _XGC







 * GC ;




 typedef struct {
 XExtData * ext_data ;
 VisualID visualid ;



 int class ;

 unsigned long red_mask , green_mask , blue_mask ;
 int bits_per_rgb ;
 int map_entries ;
 } Visual ;




 typedef struct {
 int depth ;
 int nvisuals ;
 Visual * visuals ;
 } Depth ;







 struct _XDisplay ;

 typedef struct {
 XExtData * ext_data ;
 struct _XDisplay * display ;
 Window root ;
 int width , height ;
 int mwidth , mheight ;
 int ndepths ;
 Depth * depths ;
 int root_depth ;
 Visual * root_visual ;
 GC default_gc ;
 Colormap cmap ;
 unsigned long white_pixel ;
 unsigned long black_pixel ;
 int max_maps , min_maps ;
 int backing_store ;
 int  save_unders ;
 long root_input_mask ;
 } Screen ;




 typedef struct {
 XExtData * ext_data ;
 int depth ;
 int bits_per_pixel ;
 int scanline_pad ;
 } ScreenFormat ;




 typedef struct {
    Pixmap background_pixmap ;
    unsigned long background_pixel ;
    Pixmap border_pixmap ;
    unsigned long border_pixel ;
    int bit_gravity ;
    int win_gravity ;
    int backing_store ;
    unsigned long backing_planes ;
    unsigned long backing_pixel ;
    int  save_under ;
    long event_mask ;
    long do_not_propagate_mask ;
    int  override_redirect ;
    Colormap colormap ;
    Cursor cursor ;
 } XSetWindowAttributes ;

 typedef struct {
    int x , y ;
    int width , height ;
    int border_width ;
    int depth ;
    Visual * visual ;
    Window root ;



    int class ;

    int bit_gravity ;
    int win_gravity ;
    int backing_store ;
    unsigned long backing_planes ;
    unsigned long backing_pixel ;
    int  save_under ;
    Colormap colormap ;
    int  map_installed ;
    int map_state ;
    long all_event_masks ;
    long your_event_mask ;
    long do_not_propagate_mask ;
    int  override_redirect ;
    Screen * screen ;
 } XWindowAttributes ;






 typedef struct {
 int family ;
 int length ;
 char * address ;
 } XHostAddress ;




 typedef struct _XImage {
    int width , height ;
    int xoffset ;
    int format ;
    char * data ;
    int byte_order ;
    int bitmap_unit ;
    int bitmap_bit_order ;
    int bitmap_pad ;
    int depth ;
    int bytes_per_line ;
    int bits_per_pixel ;
    unsigned long red_mask ;
    unsigned long green_mask ;
    unsigned long blue_mask ;
    XPointer obdata ;
    struct funcs {
 struct _XImage * ( * create_image ) (

     struct _XDisplay *                     ,
     Visual *                 ,
     unsigned int               ,
     int                     ,
     int                     ,
     char *                 ,
     unsigned int               ,
     unsigned int                ,
     int                         ,
     int

 ) ;

 int ( * destroy_image )        ( struct _XImage * ) ;
 unsigned long ( * get_pixel )  ( struct _XImage * , int , int ) ;
 int ( * put_pixel )            ( struct _XImage * , int , int , unsigned long ) ;
 struct _XImage * ( * sub_image ) ( struct _XImage * , int , int , unsigned int , unsigned int ) ;
 int ( * add_pixel )            ( struct _XImage * , long ) ;







 } f ;
 } XImage ;




 typedef struct {
    int x , y ;
    int width , height ;
    int border_width ;
    Window sibling ;
    int stack_mode ;
 } XWindowChanges ;




 typedef struct {
 unsigned long pixel ;
 unsigned short red , green , blue ;
 char flags ;
 char pad ;
 } XColor ;






 typedef struct {
    short x1 , y1 , x2 , y2 ;
 } XSegment ;

 typedef struct {
    short x , y ;
 } XPoint ;

 typedef struct {
    short x , y ;
    unsigned short width , height ;
 } XRectangle ;

 typedef struct {
    short x , y ;
    unsigned short width , height ;
    short angle1 , angle2 ;
 } XArc ;




 typedef struct {
        int key_click_percent ;
        int bell_percent ;
        int bell_pitch ;
        int bell_duration ;
        int led ;
        int led_mode ;
        int key ;
        int auto_repeat_mode ;
 } XKeyboardControl ;



 typedef struct {
        int key_click_percent ;
 int bell_percent ;
 unsigned int bell_pitch , bell_duration ;
 unsigned long led_mask ;
 int global_auto_repeat ;
 char auto_repeats [ 32 ] ;
 } XKeyboardState ;



 typedef struct {
        Time time ;
 short x , y ;
 } XTimeCoord ;



 typedef struct {
  int max_keypermod ;
  KeyCode * modifiermap ;
 } XModifierKeymap ;








 typedef struct _XDisplay Display ;


 struct _XPrivate ;
 struct _XrmHashBucketRec ;

 typedef struct



 {
 XExtData * ext_data ;
 struct _XPrivate * private1 ;
 int fd ;
 int private2 ;
 int proto_major_version ;
 int proto_minor_version ;
 char * vendor ;
        XID private3 ;
 XID private4 ;
 XID private5 ;
 int private6 ;

 XID ( * resource_alloc ) ( struct _XDisplay * ) ;



 int byte_order ;
 int bitmap_unit ;
 int bitmap_pad ;
 int bitmap_bit_order ;
 int nformats ;
 ScreenFormat * pixmap_format ;
 int private8 ;
 int release ;
 struct _XPrivate * private9 , * private10 ;
 int qlen ;
 unsigned long last_request_read ;
 unsigned long request ;
 XPointer private11 ;
 XPointer private12 ;
 XPointer private13 ;
 XPointer private14 ;
 unsigned max_request_size ;
 struct _XrmHashBucketRec * db ;
 int ( * private15 ) ( ) ;
 char * display_name ;
 int default_screen ;
 int nscreens ;
 Screen * screens ;
 unsigned long motion_buffer ;
 unsigned long private16 ;
 int min_keycode ;
 int max_keycode ;
 XPointer private17 ;
 XPointer private18 ;
 int private19 ;
 char * xdefaults ;

 }



 * _XPrivDisplay ;








 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 Window root ;
 Window subwindow ;
 Time time ;
 int x , y ;
 int x_root , y_root ;
 unsigned int state ;
 unsigned int keycode ;
 int  same_screen ;
 } XKeyEvent ;
 typedef XKeyEvent XKeyPressedEvent ;
 typedef XKeyEvent XKeyReleasedEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 Window root ;
 Window subwindow ;
 Time time ;
 int x , y ;
 int x_root , y_root ;
 unsigned int state ;
 unsigned int button ;
 int  same_screen ;
 } XButtonEvent ;
 typedef XButtonEvent XButtonPressedEvent ;
 typedef XButtonEvent XButtonReleasedEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 Window root ;
 Window subwindow ;
 Time time ;
 int x , y ;
 int x_root , y_root ;
 unsigned int state ;
 char is_hint ;
 int  same_screen ;
 } XMotionEvent ;
 typedef XMotionEvent XPointerMovedEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 Window root ;
 Window subwindow ;
 Time time ;
 int x , y ;
 int x_root , y_root ;
 int mode ;
 int detail ;




 int  same_screen ;
 int  focus ;
 unsigned int state ;
 } XCrossingEvent ;
 typedef XCrossingEvent XEnterWindowEvent ;
 typedef XCrossingEvent XLeaveWindowEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 int mode ;
 int detail ;





 } XFocusChangeEvent ;
 typedef XFocusChangeEvent XFocusInEvent ;
 typedef XFocusChangeEvent XFocusOutEvent ;


 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 char key_vector [ 32 ] ;
 } XKeymapEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 int x , y ;
 int width , height ;
 int count ;
 } XExposeEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Drawable drawable ;
 int x , y ;
 int width , height ;
 int count ;
 int major_code ;
 int minor_code ;
 } XGraphicsExposeEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Drawable drawable ;
 int major_code ;
 int minor_code ;
 } XNoExposeEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 int state ;
 } XVisibilityEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window parent ;
 Window window ;
 int x , y ;
 int width , height ;
 int border_width ;
 int  override_redirect ;
 } XCreateWindowEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window event ;
 Window window ;
 } XDestroyWindowEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window event ;
 Window window ;
 int  from_configure ;
 } XUnmapEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window event ;
 Window window ;
 int  override_redirect ;
 } XMapEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window parent ;
 Window window ;
 } XMapRequestEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window event ;
 Window window ;
 Window parent ;
 int x , y ;
 int  override_redirect ;
 } XReparentEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window event ;
 Window window ;
 int x , y ;
 int width , height ;
 int border_width ;
 Window above ;
 int  override_redirect ;
 } XConfigureEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window event ;
 Window window ;
 int x , y ;
 } XGravityEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 int width , height ;
 } XResizeRequestEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window parent ;
 Window window ;
 int x , y ;
 int width , height ;
 int border_width ;
 Window above ;
 int detail ;
 unsigned long value_mask ;
 } XConfigureRequestEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window event ;
 Window window ;
 int place ;
 } XCirculateEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window parent ;
 Window window ;
 int place ;
 } XCirculateRequestEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 Atom atom ;
 Time time ;
 int state ;
 } XPropertyEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 Atom selection ;
 Time time ;
 } XSelectionClearEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window owner ;
 Window requestor ;
 Atom selection ;
 Atom target ;
 Atom property ;
 Time time ;
 } XSelectionRequestEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window requestor ;
 Atom selection ;
 Atom target ;
 Atom property ;
 Time time ;
 } XSelectionEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 Colormap colormap ;



 int  new ;

 int state ;
 } XColormapEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 Atom message_type ;
 int format ;
 union {
  char b [ 20 ] ;
  short s [ 10 ] ;
  long l [ 5 ] ;
  } data ;
 } XClientMessageEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 int request ;

 int first_keycode ;
 int count ;
 } XMappingEvent ;

 typedef struct {
 int type ;
 Display * display ;
 XID resourceid ;
 unsigned long serial ;
 unsigned char error_code ;
 unsigned char request_code ;
 unsigned char minor_code ;
 } XErrorEvent ;

 typedef struct {
 int type ;
 unsigned long serial ;
 int  send_event ;
 Display * display ;
 Window window ;
 } XAnyEvent ;





 typedef union _XEvent {
        int type ;
 XAnyEvent xany ;
 XKeyEvent xkey ;
 XButtonEvent xbutton ;
 XMotionEvent xmotion ;
 XCrossingEvent xcrossing ;
 XFocusChangeEvent xfocus ;
 XExposeEvent xexpose ;
 XGraphicsExposeEvent xgraphicsexpose ;
 XNoExposeEvent xnoexpose ;
 XVisibilityEvent xvisibility ;
 XCreateWindowEvent xcreatewindow ;
 XDestroyWindowEvent xdestroywindow ;
 XUnmapEvent xunmap ;
 XMapEvent xmap ;
 XMapRequestEvent xmaprequest ;
 XReparentEvent xreparent ;
 XConfigureEvent xconfigure ;
 XGravityEvent xgravity ;
 XResizeRequestEvent xresizerequest ;
 XConfigureRequestEvent xconfigurerequest ;
 XCirculateEvent xcirculate ;
 XCirculateRequestEvent xcirculaterequest ;
 XPropertyEvent xproperty ;
 XSelectionClearEvent xselectionclear ;
 XSelectionRequestEvent xselectionrequest ;
 XSelectionEvent xselection ;
 XColormapEvent xcolormap ;
 XClientMessageEvent xclient ;
 XMappingEvent xmapping ;
 XErrorEvent xerror ;
 XKeymapEvent xkeymap ;
 long pad [ 24 ] ;
 } XEvent ;







 typedef struct {
    short lbearing ;
    short rbearing ;
    short width ;
    short ascent ;
    short descent ;
    unsigned short attributes ;
 } XCharStruct ;





 typedef struct {
    Atom name ;
    unsigned long card32 ;
 } XFontProp ;

 typedef struct {
    XExtData * ext_data ;
    Font        fid ;
    unsigned direction ;
    unsigned min_char_or_byte2 ;
    unsigned max_char_or_byte2 ;
    unsigned min_byte1 ;
    unsigned max_byte1 ;
    int  all_chars_exist ;
    unsigned default_char ;
    int         n_properties ;
    XFontProp * properties ;
    XCharStruct min_bounds ;
    XCharStruct max_bounds ;
    XCharStruct * per_char ;
    int  ascent ;
    int  descent ;
 } XFontStruct ;




 typedef struct {
    char * chars ;
    int nchars ;
    int delta ;
    Font font ;
 } XTextItem ;

 typedef struct {
    unsigned char byte1 ;
    unsigned char byte2 ;
 } XChar2b ;

 typedef struct {
    XChar2b * chars ;
    int nchars ;
    int delta ;
    Font font ;
 } XTextItem16 ;


 typedef union { Display * display ;
  GC gc ;
  Visual * visual ;
  Screen * screen ;
  ScreenFormat * pixmap_format ;
  XFontStruct * font ; } XEDataObject ;

 typedef struct {
    XRectangle      max_ink_extent ;
    XRectangle      max_logical_extent ;
 } XFontSetExtents ;

 typedef struct _XOM * XOM ;
 typedef struct _XOC * XOC , * XFontSet ;

 typedef void ( * XOMProc ) (

 XOC , XPointer , XPointer

 ) ;

 typedef struct {
    char           * chars ;
    int             nchars ;
    int             delta ;
    XFontSet        font_set ;
 } XmbTextItem ;

 typedef struct {
    wchar_t        * chars ;
    int             nchars ;
    int             delta ;
    XFontSet        font_set ;
 } XwcTextItem ;
#line 1092  "/usr/include/X11/Xlib.h"
 typedef struct {
    int charset_count ;
    char * * charset_list ;
 } XOMCharSetList ;

 typedef enum {
    XOMOrientation_LTR_TTB ,
    XOMOrientation_RTL_TTB ,
    XOMOrientation_TTB_LTR ,
    XOMOrientation_TTB_RTL ,
    XOMOrientation_Context
 } XOrientation ;

 typedef struct {
    int num_orientation ;
    XOrientation * orientation ;
 } XOMOrientation ;

 typedef struct {
    int num_font ;
    XFontStruct * * font_struct_list ;
    char * * font_name_list ;
 } XOMFontInfo ;


 typedef struct _XIM * XIM ;
 typedef struct _XIC * XIC ;

 typedef void ( * XIMProc ) (

 XIC , XPointer , XPointer

 ) ;

 typedef unsigned long XIMStyle ;

 typedef struct {
    unsigned short count_styles ;
    XIMStyle * supported_styles ;
 } XIMStyles ;
#line 1194  "/usr/include/X11/Xlib.h"
 typedef void * XVaNestedList ;




 typedef struct {
    XPointer client_data ;
    XIMProc callback ;
 } XIMCallback ;

 typedef unsigned long XIMFeedback ;
#line 1216  "/usr/include/X11/Xlib.h"
 typedef struct _XIMText {
    unsigned short length ;
    XIMFeedback * feedback ;
    int  encoding_is_wchar ;
    union {
 char * multi_byte ;
 wchar_t * wide_char ;
    } string ;
 } XIMText ;

 typedef unsigned long  XIMPreeditState ;





 typedef struct _XIMPreeditStateNotifyCallbackStruct {
    XIMPreeditState state ;
 } XIMPreeditStateNotifyCallbackStruct ;

 typedef unsigned long  XIMResetState ;




 typedef unsigned long XIMStringConversionFeedback ;








 typedef struct _XIMStringConversionText {
    unsigned short length ;
    XIMStringConversionFeedback * feedback ;
    int  encoding_is_wchar ;
    union {
 char * mbs ;
 wchar_t * wcs ;
    } string ;
 } XIMStringConversionText ;

 typedef unsigned short XIMStringConversionPosition ;

 typedef unsigned short XIMStringConversionType ;






 typedef unsigned short XIMStringConversionOperation ;









 typedef enum {
    XIMForwardChar , XIMBackwardChar ,
    XIMForwardWord , XIMBackwardWord ,
    XIMCaretUp , XIMCaretDown ,
    XIMNextLine , XIMPreviousLine ,
    XIMLineStart , XIMLineEnd ,
    XIMAbsolutePosition ,
    XIMDontChange
 } XIMCaretDirection ;

 typedef struct _XIMStringConversionCallbackStruct {
    XIMStringConversionPosition position ;
    XIMCaretDirection direction ;
    XIMStringConversionOperation operation ;
    unsigned short factor ;
    XIMStringConversionText * text ;
 } XIMStringConversionCallbackStruct ;

 typedef struct _XIMPreeditDrawCallbackStruct {
    int caret ;
    int chg_first ;
    int chg_length ;
    XIMText * text ;
 } XIMPreeditDrawCallbackStruct ;

 typedef enum {
    XIMIsInvisible ,
    XIMIsPrimary ,
    XIMIsSecondary
 } XIMCaretStyle ;

 typedef struct _XIMPreeditCaretCallbackStruct {
    int position ;
    XIMCaretDirection direction ;
    XIMCaretStyle style ;
 } XIMPreeditCaretCallbackStruct ;

 typedef enum {
    XIMTextType ,
    XIMBitmapType
 } XIMStatusDataType ;

 typedef struct _XIMStatusDrawCallbackStruct {
    XIMStatusDataType type ;
    union {
 XIMText * text ;
 Pixmap  bitmap ;
    } data ;
 } XIMStatusDrawCallbackStruct ;

 typedef struct _XIMHotKeyTrigger {
    KeySym  keysym ;
    int   modifier ;
    int   modifier_mask ;
 } XIMHotKeyTrigger ;

 typedef struct _XIMHotKeyTriggers {
    int    num_hot_key ;
    XIMHotKeyTrigger * key ;
 } XIMHotKeyTriggers ;

 typedef unsigned long  XIMHotKeyState ;




 typedef struct {
    unsigned short count_values ;
    char * * supported_values ;
 } XIMValuesList ;







 extern int _Xdebug ;

 extern XFontStruct * XLoadQueryFont (

    Display *               ,
    const   char *

 ) ;

 extern XFontStruct * XQueryFont (

    Display *               ,
    XID

 ) ;


 extern XTimeCoord * XGetMotionEvents (

    Display *               ,
    Window         ,
    Time             ,
    Time            ,
    int *

 ) ;

 extern XModifierKeymap * XDeleteModifiermapEntry (

    XModifierKeymap *             ,

    unsigned int                    ,



    int

 ) ;

 extern XModifierKeymap * XGetModifierMapping (

    Display *

 ) ;

 extern XModifierKeymap * XInsertModifiermapEntry (

    XModifierKeymap *             ,

    unsigned int                    ,



    int

 ) ;

 extern XModifierKeymap * XNewModifiermap (

    int

 ) ;

 extern XImage * XCreateImage (

    Display *               ,
    Visual *              ,
    unsigned int            ,
    int               ,
    int               ,
    char *            ,
    unsigned int            ,
    unsigned int             ,
    int                   ,
    int

 ) ;
 extern int    XInitImage (

    XImage *

 ) ;
 extern XImage * XGetImage (

    Display *               ,
    Drawable         ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int             ,
    unsigned long                 ,
    int

 ) ;
 extern XImage * XGetSubImage (

    Display *               ,
    Drawable         ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int             ,
    unsigned long                 ,
    int               ,
    XImage *                  ,
    int               ,
    int

 ) ;




 extern Display * XOpenDisplay (

    const   char *

 ) ;

 extern void XrmInitialize (

    void

 ) ;

 extern char * XFetchBytes (

    Display *               ,
    int *

 ) ;
 extern char * XFetchBuffer (

    Display *               ,
    int *                     ,
    int

 ) ;
 extern char * XGetAtomName (

    Display *               ,
    Atom

 ) ;
 extern int    XGetAtomNames (

    Display *           ,
    Atom *             ,
    int              ,
    char * *

 ) ;
 extern char * XGetDefault (

    Display *               ,
    const   char *              ,
    const   char *

 ) ;
 extern char * XDisplayName (

    const   char *

 ) ;
 extern char * XKeysymToString (

    KeySym

 ) ;

 extern int ( * XSynchronize (

    Display *               ,
    int
 ) ) ( void ) ;




 extern int ( * XSetAfterFunction (

    Display *               ,
    int ( * ) (

      Display *

            )
 ) ) ( void ) ;




 extern Atom XInternAtom (

    Display *               ,
    const   char *                ,
    int

 ) ;
 extern int    XInternAtoms (

    Display *           ,
    char * *             ,
    int              ,
    int                     ,
    Atom *

 ) ;
 extern Colormap XCopyColormapAndFree (

    Display *               ,
    Colormap

 ) ;
 extern Colormap XCreateColormap (

    Display *               ,
    Window         ,
    Visual *              ,
    int

 ) ;
 extern Cursor XCreatePixmapCursor (

    Display *               ,
    Pixmap              ,
    Pixmap            ,
    XColor *                        ,
    XColor *                        ,
    unsigned int        ,
    unsigned int

 ) ;
 extern Cursor XCreateGlyphCursor (

    Display *               ,
    Font                   ,
    Font                 ,
    unsigned int                  ,
    unsigned int                ,
    XColor *                        ,
    XColor *

 ) ;
 extern Cursor XCreateFontCursor (

    Display *               ,
    unsigned int

 ) ;
 extern Font XLoadFont (

    Display *               ,
    const   char *

 ) ;
 extern GC XCreateGC (

    Display *               ,
    Drawable         ,
    unsigned long                ,
    XGCValues *

 ) ;
 extern GContext XGContextFromGC (

    GC

 ) ;
 extern void XFlushGC (

    Display *               ,
    GC

 ) ;
 extern Pixmap XCreatePixmap (

    Display *               ,
    Drawable         ,
    unsigned int            ,
    unsigned int             ,
    unsigned int

 ) ;
 extern Pixmap XCreateBitmapFromData (

    Display *               ,
    Drawable         ,
    const   char *           ,
    unsigned int            ,
    unsigned int

 ) ;
 extern Pixmap XCreatePixmapFromBitmapData (

    Display *               ,
    Drawable         ,
    char *            ,
    unsigned int            ,
    unsigned int             ,
    unsigned long         ,
    unsigned long         ,
    unsigned int

 ) ;
 extern Window XCreateSimpleWindow (

    Display *               ,
    Window              ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int             ,
    unsigned int                   ,
    unsigned long             ,
    unsigned long

 ) ;
 extern Window XGetSelectionOwner (

    Display *               ,
    Atom

 ) ;
 extern Window XCreateWindow (

    Display *               ,
    Window              ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int             ,
    unsigned int                   ,
    int              ,
    unsigned int            ,
    Visual *              ,
    unsigned long                ,
    XSetWindowAttributes *

 ) ;
 extern Colormap * XListInstalledColormaps (

    Display *               ,
    Window         ,
    int *

 ) ;
 extern char * * XListFonts (

    Display *               ,
    const   char *              ,
    int                 ,
    int *

 ) ;
 extern char * * XListFontsWithInfo (

    Display *               ,
    const   char *              ,
    int                 ,
    int *                    ,
    XFontStruct * *

 ) ;
 extern char * * XGetFontPath (

    Display *               ,
    int *

 ) ;
 extern char * * XListExtensions (

    Display *               ,
    int *

 ) ;
 extern Atom * XListProperties (

    Display *               ,
    Window         ,
    int *

 ) ;
 extern XHostAddress * XListHosts (

    Display *               ,
    int *                     ,
    int *

 ) ;
 extern KeySym XKeycodeToKeysym (

    Display *               ,

    unsigned int              ,



    int

 ) ;
 extern KeySym XLookupKeysym (

    XKeyEvent *                 ,
    int

 ) ;
 extern KeySym * XGetKeyboardMapping (

    Display *               ,

    unsigned int                    ,



    int                      ,
    int *

 ) ;
 extern KeySym XStringToKeysym (

    const   char *

 ) ;
 extern long XMaxRequestSize (

    Display *

 ) ;
 extern long XExtendedMaxRequestSize (

    Display *

 ) ;
 extern char * XResourceManagerString (

    Display *

 ) ;
 extern char * XScreenResourceString (

 Screen *

 ) ;
 extern unsigned long XDisplayMotionBufferSize (

    Display *

 ) ;
 extern VisualID XVisualIDFromVisual (

    Visual *

 ) ;



 extern int    XInitThreads (

    void

 ) ;

 extern void XLockDisplay (

    Display *

 ) ;

 extern void XUnlockDisplay (

    Display *

 ) ;



 extern XExtCodes * XInitExtension (

    Display *               ,
    const   char *

 ) ;

 extern XExtCodes * XAddExtension (

    Display *

 ) ;
 extern XExtData * XFindOnExtensionList (

    XExtData * *                 ,
    int

 ) ;
 extern XExtData * * XEHeadOfExtensionList (

    XEDataObject

 ) ;


 extern Window XRootWindow (

    Display *               ,
    int

 ) ;
 extern Window XDefaultRootWindow (

    Display *

 ) ;
 extern Window XRootWindowOfScreen (

    Screen *

 ) ;
 extern Visual * XDefaultVisual (

    Display *               ,
    int

 ) ;
 extern Visual * XDefaultVisualOfScreen (

    Screen *

 ) ;
 extern GC XDefaultGC (

    Display *               ,
    int

 ) ;
 extern GC XDefaultGCOfScreen (

    Screen *

 ) ;
 extern unsigned long XBlackPixel (

    Display *               ,
    int

 ) ;
 extern unsigned long XWhitePixel (

    Display *               ,
    int

 ) ;
 extern unsigned long XAllPlanes (

    void

 ) ;
 extern unsigned long XBlackPixelOfScreen (

    Screen *

 ) ;
 extern unsigned long XWhitePixelOfScreen (

    Screen *

 ) ;
 extern unsigned long XNextRequest (

    Display *

 ) ;
 extern unsigned long XLastKnownRequestProcessed (

    Display *

 ) ;
 extern char * XServerVendor (

    Display *

 ) ;
 extern char * XDisplayString (

    Display *

 ) ;
 extern Colormap XDefaultColormap (

    Display *               ,
    int

 ) ;
 extern Colormap XDefaultColormapOfScreen (

    Screen *

 ) ;
 extern Display * XDisplayOfScreen (

    Screen *

 ) ;
 extern Screen * XScreenOfDisplay (

    Display *               ,
    int

 ) ;
 extern Screen * XDefaultScreenOfDisplay (

    Display *

 ) ;
 extern long XEventMaskOfScreen (

    Screen *

 ) ;

 extern int XScreenNumberOfScreen (

    Screen *

 ) ;

 typedef int ( * XErrorHandler ) (

    Display *               ,
    XErrorEvent *

 ) ;

 extern XErrorHandler XSetErrorHandler (

    XErrorHandler

 ) ;


 typedef int ( * XIOErrorHandler ) (

    Display *

 ) ;

 extern XIOErrorHandler XSetIOErrorHandler (

    XIOErrorHandler

 ) ;


 extern XPixmapFormatValues * XListPixmapFormats (

    Display *               ,
    int *

 ) ;
 extern int * XListDepths (

    Display *               ,
    int                      ,
    int *

 ) ;



 extern int    XReconfigureWMWindow (

    Display *               ,
    Window         ,
    int                      ,
    unsigned int           ,
    XWindowChanges *

 ) ;

 extern int    XGetWMProtocols (

    Display *               ,
    Window         ,
    Atom * *                        ,
    int *

 ) ;
 extern int    XSetWMProtocols (

    Display *               ,
    Window         ,
    Atom *                 ,
    int

 ) ;
 extern int    XIconifyWindow (

    Display *               ,
    Window         ,
    int

 ) ;
 extern int    XWithdrawWindow (

    Display *               ,
    Window         ,
    int

 ) ;
 extern int    XGetCommand (

    Display *               ,
    Window         ,
    char * * *                   ,
    int *

 ) ;
 extern int    XGetWMColormapWindows (

    Display *               ,
    Window         ,
    Window * *                      ,
    int *

 ) ;
 extern int    XSetWMColormapWindows (

    Display *               ,
    Window         ,
    Window *                        ,
    int

 ) ;
 extern void XFreeStringList (

    char * *

 ) ;
 extern int XSetTransientForHint (

    Display *               ,
    Window         ,
    Window

 ) ;



 extern int XActivateScreenSaver (

    Display *

 ) ;

 extern int XAddHost (

    Display *               ,
    XHostAddress *

 ) ;

 extern int XAddHosts (

    Display *               ,
    XHostAddress *            ,
    int

 ) ;

 extern int XAddToExtensionList (

    struct _XExtData * *                ,
    XExtData *

 ) ;

 extern int XAddToSaveSet (

    Display *               ,
    Window

 ) ;

 extern int    XAllocColor (

    Display *               ,
    Colormap                ,
    XColor *

 ) ;

 extern int    XAllocColorCells (

    Display *               ,
    Colormap                ,
    int                      ,
    unsigned long *                         ,
    unsigned int              ,
    unsigned long *                    ,
    unsigned int

 ) ;

 extern int    XAllocColorPlanes (

    Display *               ,
    Colormap                ,
    int               ,
    unsigned long *                    ,
    int                ,
    int              ,
    int                ,
    int               ,
    unsigned long *                   ,
    unsigned long *                   ,
    unsigned long *

 ) ;

 extern int    XAllocNamedColor (

    Display *               ,
    Colormap                ,
    const   char *                 ,
    XColor *                         ,
    XColor *

 ) ;

 extern int XAllowEvents (

    Display *               ,
    int                   ,
    Time

 ) ;

 extern int XAutoRepeatOff (

    Display *

 ) ;

 extern int XAutoRepeatOn (

    Display *

 ) ;

 extern int XBell (

    Display *               ,
    int

 ) ;

 extern int XBitmapBitOrder (

    Display *

 ) ;

 extern int XBitmapPad (

    Display *

 ) ;

 extern int XBitmapUnit (

    Display *

 ) ;

 extern int XCellsOfScreen (

    Screen *

 ) ;

 extern int XChangeActivePointerGrab (

    Display *               ,
    unsigned int                 ,
    Cursor              ,
    Time

 ) ;

 extern int XChangeGC (

    Display *               ,
    GC           ,
    unsigned long                ,
    XGCValues *

 ) ;

 extern int XChangeKeyboardControl (

    Display *               ,
    unsigned long                 ,
    XKeyboardControl *

 ) ;

 extern int XChangeKeyboardMapping (

    Display *               ,
    int                      ,
    int                            ,
    KeySym *               ,
    int

 ) ;

 extern int XChangePointerControl (

    Display *               ,
    int                 ,
    int                     ,
    int                        ,
    int                          ,
    int

 ) ;

 extern int XChangeProperty (

    Display *               ,
    Window         ,
    Atom                ,
    Atom            ,
    int               ,
    int             ,
    const   unsigned char *           ,
    int

 ) ;

 extern int XChangeSaveSet (

    Display *               ,
    Window         ,
    int

 ) ;

 extern int XChangeWindowAttributes (

    Display *               ,
    Window         ,
    unsigned long                ,
    XSetWindowAttributes *

 ) ;

 extern int  XCheckIfEvent (

    Display *               ,
    XEvent *                    ,
    int  ( * ) (

        Display *                ,
               XEvent *              ,
               XPointer

             )                 ,
    XPointer

 ) ;

 extern int  XCheckMaskEvent (

    Display *               ,
    long                  ,
    XEvent *

 ) ;

 extern int  XCheckTypedEvent (

    Display *               ,
    int                   ,
    XEvent *

 ) ;

 extern int  XCheckTypedWindowEvent (

    Display *               ,
    Window         ,
    int                   ,
    XEvent *

 ) ;

 extern int  XCheckWindowEvent (

    Display *               ,
    Window         ,
    long                  ,
    XEvent *

 ) ;

 extern int XCirculateSubwindows (

    Display *               ,
    Window         ,
    int

 ) ;

 extern int XCirculateSubwindowsDown (

    Display *               ,
    Window

 ) ;

 extern int XCirculateSubwindowsUp (

    Display *               ,
    Window

 ) ;

 extern int XClearArea (

    Display *               ,
    Window         ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int             ,
    int

 ) ;

 extern int XClearWindow (

    Display *               ,
    Window

 ) ;

 extern int XCloseDisplay (

    Display *

 ) ;

 extern int XConfigureWindow (

    Display *               ,
    Window         ,
    unsigned int                 ,
    XWindowChanges *

 ) ;

 extern int XConnectionNumber (

    Display *

 ) ;

 extern int XConvertSelection (

    Display *               ,
    Atom                 ,
    Atom               ,
    Atom                ,
    Window                 ,
    Time

 ) ;

 extern int XCopyArea (

    Display *               ,
    Drawable           ,
    Drawable            ,
    GC           ,
    int              ,
    int              ,
    unsigned int            ,
    unsigned int             ,
    int               ,
    int

 ) ;

 extern int XCopyGC (

    Display *               ,
    GC            ,
    unsigned long                ,
    GC

 ) ;

 extern int XCopyPlane (

    Display *               ,
    Drawable           ,
    Drawable            ,
    GC           ,
    int              ,
    int              ,
    unsigned int            ,
    unsigned int             ,
    int               ,
    int               ,
    unsigned long

 ) ;

 extern int XDefaultDepth (

    Display *               ,
    int

 ) ;

 extern int XDefaultDepthOfScreen (

    Screen *

 ) ;

 extern int XDefaultScreen (

    Display *

 ) ;

 extern int XDefineCursor (

    Display *               ,
    Window         ,
    Cursor

 ) ;

 extern int XDeleteProperty (

    Display *               ,
    Window         ,
    Atom

 ) ;

 extern int XDestroyWindow (

    Display *               ,
    Window

 ) ;

 extern int XDestroySubwindows (

    Display *               ,
    Window

 ) ;

 extern int XDoesBackingStore (

    Screen *

 ) ;

 extern int  XDoesSaveUnders (

    Screen *

 ) ;

 extern int XDisableAccessControl (

    Display *

 ) ;


 extern int XDisplayCells (

    Display *               ,
    int

 ) ;

 extern int XDisplayHeight (

    Display *               ,
    int

 ) ;

 extern int XDisplayHeightMM (

    Display *               ,
    int

 ) ;

 extern int XDisplayKeycodes (

    Display *               ,
    int *                           ,
    int *

 ) ;

 extern int XDisplayPlanes (

    Display *               ,
    int

 ) ;

 extern int XDisplayWidth (

    Display *               ,
    int

 ) ;

 extern int XDisplayWidthMM (

    Display *               ,
    int

 ) ;

 extern int XDrawArc (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int             ,
    int               ,
    int

 ) ;

 extern int XDrawArcs (

    Display *               ,
    Drawable         ,
    GC           ,
    XArc *            ,
    int

 ) ;

 extern int XDrawImageString (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    const   char *             ,
    int

 ) ;

 extern int XDrawImageString16 (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    const   XChar2b *             ,
    int

 ) ;

 extern int XDrawLine (

    Display *               ,
    Drawable         ,
    GC           ,
    int           ,
    int           ,
    int           ,
    int

 ) ;

 extern int XDrawLines (

    Display *               ,
    Drawable         ,
    GC           ,
    XPoint *              ,
    int                ,
    int

 ) ;

 extern int XDrawPoint (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int

 ) ;

 extern int XDrawPoints (

    Display *               ,
    Drawable         ,
    GC           ,
    XPoint *              ,
    int                ,
    int

 ) ;

 extern int XDrawRectangle (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int

 ) ;

 extern int XDrawRectangles (

    Display *               ,
    Drawable         ,
    GC           ,
    XRectangle *                  ,
    int

 ) ;

 extern int XDrawSegments (

    Display *               ,
    Drawable         ,
    GC           ,
    XSegment *                ,
    int

 ) ;

 extern int XDrawString (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    const   char *             ,
    int

 ) ;

 extern int XDrawString16 (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    const   XChar2b *             ,
    int

 ) ;

 extern int XDrawText (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    XTextItem *             ,
    int

 ) ;

 extern int XDrawText16 (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    XTextItem16 *            ,
    int

 ) ;

 extern int XEnableAccessControl (

    Display *

 ) ;

 extern int XEventsQueued (

    Display *               ,
    int

 ) ;

 extern int    XFetchName (

    Display *               ,
    Window         ,
    char * *

 ) ;

 extern int XFillArc (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int             ,
    int               ,
    int

 ) ;

 extern int XFillArcs (

    Display *               ,
    Drawable         ,
    GC           ,
    XArc *            ,
    int

 ) ;

 extern int XFillPolygon (

    Display *               ,
    Drawable         ,
    GC           ,
    XPoint *              ,
    int                ,
    int              ,
    int

 ) ;

 extern int XFillRectangle (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int

 ) ;

 extern int XFillRectangles (

    Display *               ,
    Drawable         ,
    GC           ,
    XRectangle *                  ,
    int

 ) ;

 extern int XFlush (

    Display *

 ) ;

 extern int XForceScreenSaver (

    Display *               ,
    int

 ) ;

 extern int XFree (

    void *

 ) ;

 extern int XFreeColormap (

    Display *               ,
    Colormap

 ) ;

 extern int XFreeColors (

    Display *               ,
    Colormap                ,
    unsigned long *             ,
    int                ,
    unsigned long

 ) ;

 extern int XFreeCursor (

    Display *               ,
    Cursor

 ) ;

 extern int XFreeExtensionList (

    char * *

 ) ;

 extern int XFreeFont (

    Display *               ,
    XFontStruct *

 ) ;

 extern int XFreeFontInfo (

    char * *             ,
    XFontStruct *                ,
    int

 ) ;

 extern int XFreeFontNames (

    char * *

 ) ;

 extern int XFreeFontPath (

    char * *

 ) ;

 extern int XFreeGC (

    Display *               ,
    GC

 ) ;

 extern int XFreeModifiermap (

    XModifierKeymap *

 ) ;

 extern int XFreePixmap (

    Display *               ,
    Pixmap

 ) ;

 extern int XGeometry (

    Display *               ,
    int               ,
    const   char *               ,
    const   char *                       ,
    unsigned int             ,
    unsigned int             ,
    unsigned int              ,
    int               ,
    int               ,
    int *                ,
    int *                ,
    int *                    ,
    int *

 ) ;

 extern int XGetErrorDatabaseText (

    Display *               ,
    const   char *           ,
    const   char *              ,
    const   char *                     ,
    char *                     ,
    int

 ) ;

 extern int XGetErrorText (

    Display *               ,
    int             ,
    char *                     ,
    int

 ) ;

 extern int  XGetFontProperty (

    XFontStruct *                  ,
    Atom            ,
    unsigned long *

 ) ;

 extern int    XGetGCValues (

    Display *               ,
    GC           ,
    unsigned long                ,
    XGCValues *

 ) ;

 extern int    XGetGeometry (

    Display *               ,
    Drawable         ,
    Window *                   ,
    int *                ,
    int *                ,
    unsigned int *                   ,
    unsigned int *                    ,
    unsigned int *                          ,
    unsigned int *

 ) ;

 extern int    XGetIconName (

    Display *               ,
    Window         ,
    char * *

 ) ;

 extern int XGetInputFocus (

    Display *               ,
    Window *                    ,
    int *

 ) ;

 extern int XGetKeyboardControl (

    Display *               ,
    XKeyboardState *

 ) ;

 extern int XGetPointerControl (

    Display *               ,
    int *                              ,
    int *                                ,
    int *

 ) ;

 extern int XGetPointerMapping (

    Display *               ,
    unsigned char *                 ,
    int

 ) ;

 extern int XGetScreenSaver (

    Display *               ,
    int *                      ,
    int *                       ,
    int *                              ,
    int *

 ) ;

 extern int    XGetTransientForHint (

    Display *               ,
    Window         ,
    Window *

 ) ;

 extern int XGetWindowProperty (

    Display *               ,
    Window         ,
    Atom                ,
    long                   ,
    long                   ,
    int               ,
    Atom                ,
    Atom *                          ,
    int *                            ,
    unsigned long *                    ,
    unsigned long *                         ,
    unsigned char * *

 ) ;

 extern int    XGetWindowAttributes (

    Display *               ,
    Window         ,
    XWindowAttributes *

 ) ;

 extern int XGrabButton (

    Display *               ,
    unsigned int             ,
    unsigned int                ,
    Window                   ,
    int                     ,
    unsigned int                 ,
    int                     ,
    int                      ,
    Window                  ,
    Cursor

 ) ;

 extern int XGrabKey (

    Display *               ,
    int                ,
    unsigned int                ,
    Window                   ,
    int                     ,
    int                     ,
    int

 ) ;

 extern int XGrabKeyboard (

    Display *               ,
    Window                   ,
    int                     ,
    int                     ,
    int                      ,
    Time

 ) ;

 extern int XGrabPointer (

    Display *               ,
    Window                   ,
    int                     ,
    unsigned int                 ,
    int                     ,
    int                      ,
    Window                  ,
    Cursor              ,
    Time

 ) ;

 extern int XGrabServer (

    Display *

 ) ;

 extern int XHeightMMOfScreen (

    Screen *

 ) ;

 extern int XHeightOfScreen (

    Screen *

 ) ;

 extern int XIfEvent (

    Display *               ,
    XEvent *                    ,
    int  ( * ) (

        Display *                ,
               XEvent *              ,
               XPointer

             )                 ,
    XPointer

 ) ;

 extern int XImageByteOrder (

    Display *

 ) ;

 extern int XInstallColormap (

    Display *               ,
    Colormap

 ) ;

 extern KeyCode XKeysymToKeycode (

    Display *               ,
    KeySym

 ) ;

 extern int XKillClient (

    Display *               ,
    XID

 ) ;

 extern unsigned long XLastKnownRequestProcessed (

    Display *

 ) ;

 extern int    XLookupColor (

    Display *               ,
    Colormap                ,
    const   char *                 ,
    XColor *                        ,
    XColor *

 ) ;

 extern int XLowerWindow (

    Display *               ,
    Window

 ) ;

 extern int XMapRaised (

    Display *               ,
    Window

 ) ;

 extern int XMapSubwindows (

    Display *               ,
    Window

 ) ;

 extern int XMapWindow (

    Display *               ,
    Window

 ) ;

 extern int XMaskEvent (

    Display *               ,
    long                  ,
    XEvent *

 ) ;

 extern int XMaxCmapsOfScreen (

    Screen *

 ) ;

 extern int XMinCmapsOfScreen (

    Screen *

 ) ;

 extern int XMoveResizeWindow (

    Display *               ,
    Window         ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int

 ) ;

 extern int XMoveWindow (

    Display *               ,
    Window         ,
    int          ,
    int

 ) ;

 extern int XNextEvent (

    Display *               ,
    XEvent *

 ) ;

 extern int XNoOp (

    Display *

 ) ;

 extern int    XParseColor (

    Display *               ,
    Colormap                ,
    const   char *           ,
    XColor *

 ) ;

 extern int XParseGeometry (

    const   char *                  ,
    int *                ,
    int *                ,
    unsigned int *                   ,
    unsigned int *

 ) ;

 extern int XPeekEvent (

    Display *               ,
    XEvent *

 ) ;

 extern int XPeekIfEvent (

    Display *               ,
    XEvent *                    ,
    int  ( * ) (

        Display *               ,
               XEvent *             ,
               XPointer

             )                 ,
    XPointer

 ) ;

 extern int XPending (

    Display *

 ) ;

 extern int XPlanesOfScreen (

    Screen *


 ) ;

 extern int XProtocolRevision (

    Display *

 ) ;

 extern int XProtocolVersion (

    Display *

 ) ;


 extern int XPutBackEvent (

    Display *               ,
    XEvent *

 ) ;

 extern int XPutImage (

    Display *               ,
    Drawable         ,
    GC           ,
    XImage *             ,
    int              ,
    int              ,
    int               ,
    int               ,
    unsigned int            ,
    unsigned int

 ) ;

 extern int XQLength (

    Display *

 ) ;

 extern int    XQueryBestCursor (

    Display *               ,
    Drawable         ,
    unsigned int                   ,
    unsigned int             ,
    unsigned int *                   ,
    unsigned int *

 ) ;

 extern int    XQueryBestSize (

    Display *               ,
    int              ,
    Drawable                    ,
    unsigned int            ,
    unsigned int             ,
    unsigned int *                   ,
    unsigned int *

 ) ;

 extern int    XQueryBestStipple (

    Display *               ,
    Drawable                    ,
    unsigned int            ,
    unsigned int             ,
    unsigned int *                   ,
    unsigned int *

 ) ;

 extern int    XQueryBestTile (

    Display *               ,
    Drawable                    ,
    unsigned int            ,
    unsigned int             ,
    unsigned int *                   ,
    unsigned int *

 ) ;

 extern int XQueryColor (

    Display *               ,
    Colormap                ,
    XColor *

 ) ;

 extern int XQueryColors (

    Display *               ,
    Colormap                ,
    XColor *                   ,
    int

 ) ;

 extern int  XQueryExtension (

    Display *               ,
    const   char *           ,
    int *                           ,
    int *                          ,
    int *

 ) ;

 extern int XQueryKeymap (

    Display *               ,
    char [ 32 ]

 ) ;

 extern int  XQueryPointer (

    Display *               ,
    Window         ,
    Window *                   ,
    Window *                    ,
    int *                     ,
    int *                     ,
    int *                    ,
    int *                    ,
    unsigned int *

 ) ;

 extern int XQueryTextExtents (

    Display *               ,
    XID                ,
    const   char *             ,
    int               ,
    int *                        ,
    int *                          ,
    int *                           ,
    XCharStruct *

 ) ;

 extern int XQueryTextExtents16 (

    Display *               ,
    XID                ,
    const   XChar2b *             ,
    int               ,
    int *                        ,
    int *                          ,
    int *                           ,
    XCharStruct *

 ) ;

 extern int    XQueryTree (

    Display *               ,
    Window         ,
    Window *                   ,
    Window *                     ,
    Window * *                       ,
    unsigned int *

 ) ;

 extern int XRaiseWindow (

    Display *               ,
    Window

 ) ;

 extern int XReadBitmapFile (

    Display *               ,
    Drawable          ,
    const   char *               ,
    unsigned int *                   ,
    unsigned int *                    ,
    Pixmap *                     ,
    int *                    ,
    int *

 ) ;

 extern int XReadBitmapFileData (

    const   char *               ,
    unsigned int *                   ,
    unsigned int *                    ,
    unsigned char * *                  ,
    int *                    ,
    int *

 ) ;

 extern int XRebindKeysym (

    Display *               ,
    KeySym              ,
    KeySym *            ,
    int                  ,
    const   unsigned char *             ,
    int

 ) ;

 extern int XRecolorCursor (

    Display *               ,
    Cursor              ,
    XColor *                        ,
    XColor *

 ) ;

 extern int XRefreshKeyboardMapping (

    XMappingEvent *

 ) ;

 extern int XRemoveFromSaveSet (

    Display *               ,
    Window

 ) ;

 extern int XRemoveHost (

    Display *               ,
    XHostAddress *

 ) ;

 extern int XRemoveHosts (

    Display *               ,
    XHostAddress *            ,
    int

 ) ;

 extern int XReparentWindow (

    Display *               ,
    Window         ,
    Window              ,
    int          ,
    int

 ) ;

 extern int XResetScreenSaver (

    Display *

 ) ;

 extern int XResizeWindow (

    Display *               ,
    Window         ,
    unsigned int            ,
    unsigned int

 ) ;

 extern int XRestackWindows (

    Display *               ,
    Window *               ,
    int

 ) ;

 extern int XRotateBuffers (

    Display *               ,
    int

 ) ;

 extern int XRotateWindowProperties (

    Display *               ,
    Window         ,
    Atom *                  ,
    int                 ,
    int

 ) ;

 extern int XScreenCount (

    Display *

 ) ;

 extern int XSelectInput (

    Display *               ,
    Window         ,
    long

 ) ;

 extern int    XSendEvent (

    Display *               ,
    Window         ,
    int                  ,
    long                  ,
    XEvent *

 ) ;

 extern int XSetAccessControl (

    Display *               ,
    int

 ) ;

 extern int XSetArcMode (

    Display *               ,
    GC           ,
    int

 ) ;

 extern int XSetBackground (

    Display *               ,
    GC           ,
    unsigned long

 ) ;

 extern int XSetClipMask (

    Display *               ,
    GC           ,
    Pixmap

 ) ;

 extern int XSetClipOrigin (

    Display *               ,
    GC           ,
    int                      ,
    int

 ) ;

 extern int XSetClipRectangles (

    Display *               ,
    GC           ,
    int                      ,
    int                      ,
    XRectangle *                  ,
    int          ,
    int

 ) ;

 extern int XSetCloseDownMode (

    Display *               ,
    int

 ) ;

 extern int XSetCommand (

    Display *               ,
    Window         ,
    char * *            ,
    int

 ) ;

 extern int XSetDashes (

    Display *               ,
    GC           ,
    int                    ,
    const   char *                ,
    int

 ) ;

 extern int XSetFillRule (

    Display *               ,
    GC           ,
    int

 ) ;

 extern int XSetFillStyle (

    Display *               ,
    GC           ,
    int

 ) ;

 extern int XSetFont (

    Display *               ,
    GC           ,
    Font

 ) ;

 extern int XSetFontPath (

    Display *               ,
    char * *                   ,
    int

 ) ;

 extern int XSetForeground (

    Display *               ,
    GC           ,
    unsigned long

 ) ;

 extern int XSetFunction (

    Display *               ,
    GC           ,
    int

 ) ;

 extern int XSetGraphicsExposures (

    Display *               ,
    GC           ,
    int

 ) ;

 extern int XSetIconName (

    Display *               ,
    Window         ,
    const   char *

 ) ;

 extern int XSetInputFocus (

    Display *               ,
    Window             ,
    int                  ,
    Time

 ) ;

 extern int XSetLineAttributes (

    Display *               ,
    GC           ,
    unsigned int                 ,
    int                   ,
    int                  ,
    int

 ) ;

 extern int XSetModifierMapping (

    Display *               ,
    XModifierKeymap *

 ) ;

 extern int XSetPlaneMask (

    Display *               ,
    GC           ,
    unsigned long

 ) ;

 extern int XSetPointerMapping (

    Display *               ,
    const   unsigned char *          ,
    int

 ) ;

 extern int XSetScreenSaver (

    Display *               ,
    int                ,
    int                 ,
    int                        ,
    int

 ) ;

 extern int XSetSelectionOwner (

    Display *               ,
    Atom                        ,
    Window             ,
    Time

 ) ;

 extern int XSetState (

    Display *               ,
    GC           ,
    unsigned long                  ,
    unsigned long                 ,
    int                 ,
    unsigned long

 ) ;

 extern int XSetStipple (

    Display *               ,
    GC           ,
    Pixmap

 ) ;

 extern int XSetSubwindowMode (

    Display *               ,
    GC           ,
    int

 ) ;

 extern int XSetTSOrigin (

    Display *               ,
    GC           ,
    int                    ,
    int

 ) ;

 extern int XSetTile (

    Display *               ,
    GC           ,
    Pixmap

 ) ;

 extern int XSetWindowBackground (

    Display *               ,
    Window         ,
    unsigned long

 ) ;

 extern int XSetWindowBackgroundPixmap (

    Display *               ,
    Window         ,
    Pixmap

 ) ;

 extern int XSetWindowBorder (

    Display *               ,
    Window         ,
    unsigned long

 ) ;

 extern int XSetWindowBorderPixmap (

    Display *               ,
    Window         ,
    Pixmap

 ) ;

 extern int XSetWindowBorderWidth (

    Display *               ,
    Window         ,
    unsigned int

 ) ;

 extern int XSetWindowColormap (

    Display *               ,
    Window         ,
    Colormap

 ) ;

 extern int XStoreBuffer (

    Display *               ,
    const   char *            ,
    int               ,
    int

 ) ;

 extern int XStoreBytes (

    Display *               ,
    const   char *            ,
    int

 ) ;

 extern int XStoreColor (

    Display *               ,
    Colormap                ,
    XColor *

 ) ;

 extern int XStoreColors (

    Display *               ,
    Colormap                ,
    XColor *             ,
    int

 ) ;

 extern int XStoreName (

    Display *               ,
    Window         ,
    const   char *

 ) ;

 extern int XStoreNamedColor (

    Display *               ,
    Colormap                ,
    const   char *            ,
    unsigned long            ,
    int

 ) ;

 extern int XSync (

    Display *               ,
    int

 ) ;

 extern int XTextExtents (

    XFontStruct *                  ,
    const   char *             ,
    int               ,
    int *                        ,
    int *                          ,
    int *                           ,
    XCharStruct *

 ) ;

 extern int XTextExtents16 (

    XFontStruct *                  ,
    const   XChar2b *             ,
    int               ,
    int *                        ,
    int *                          ,
    int *                           ,
    XCharStruct *

 ) ;

 extern int XTextWidth (

    XFontStruct *                  ,
    const   char *             ,
    int

 ) ;

 extern int XTextWidth16 (

    XFontStruct *                  ,
    const   XChar2b *             ,
    int

 ) ;

 extern int  XTranslateCoordinates (

    Display *               ,
    Window             ,
    Window              ,
    int              ,
    int              ,
    int *                     ,
    int *                     ,
    Window *

 ) ;

 extern int XUndefineCursor (

    Display *               ,
    Window

 ) ;

 extern int XUngrabButton (

    Display *               ,
    unsigned int             ,
    unsigned int                ,
    Window

 ) ;

 extern int XUngrabKey (

    Display *               ,
    int                ,
    unsigned int                ,
    Window

 ) ;

 extern int XUngrabKeyboard (

    Display *               ,
    Time

 ) ;

 extern int XUngrabPointer (

    Display *               ,
    Time

 ) ;

 extern int XUngrabServer (

    Display *

 ) ;

 extern int XUninstallColormap (

    Display *               ,
    Colormap

 ) ;

 extern int XUnloadFont (

    Display *               ,
    Font

 ) ;

 extern int XUnmapSubwindows (

    Display *               ,
    Window

 ) ;

 extern int XUnmapWindow (

    Display *               ,
    Window

 ) ;

 extern int XVendorRelease (

    Display *

 ) ;

 extern int XWarpPointer (

    Display *               ,
    Window             ,
    Window              ,
    int              ,
    int              ,
    unsigned int                ,
    unsigned int                 ,
    int               ,
    int

 ) ;

 extern int XWidthMMOfScreen (

    Screen *

 ) ;

 extern int XWidthOfScreen (

    Screen *

 ) ;

 extern int XWindowEvent (

    Display *               ,
    Window         ,
    long                  ,
    XEvent *

 ) ;

 extern int XWriteBitmapFile (

    Display *               ,
    const   char *               ,
    Pixmap              ,
    unsigned int            ,
    unsigned int             ,
    int              ,
    int

 ) ;

 extern int  XSupportsLocale (

    void

 ) ;

 extern char * XSetLocaleModifiers (

    const   char *

 ) ;

 extern XOM XOpenOM (

    Display *                ,
    struct _XrmHashBucketRec *          ,
    const   char *                ,
    const   char *

 ) ;

 extern int    XCloseOM (

    XOM

 ) ;

 extern char * XSetOMValues (

    XOM           ,
    ...

 ) ;

 extern char * XGetOMValues (

    XOM           ,
    ...

 ) ;

 extern Display * XDisplayOfOM (

    XOM

 ) ;

 extern char * XLocaleOfOM (

    XOM

 ) ;

 extern XOC XCreateOC (

    XOM           ,
    ...

 ) ;

 extern void XDestroyOC (

    XOC

 ) ;

 extern XOM XOMOfOC (

    XOC

 ) ;

 extern char * XSetOCValues (

    XOC           ,
    ...

 ) ;

 extern char * XGetOCValues (

    XOC           ,
    ...

 ) ;

 extern XFontSet XCreateFontSet (

    Display *               ,
    const   char *                          ,
    char * * *                            ,
    int *                             ,
    char * *

 ) ;

 extern void XFreeFontSet (

    Display *               ,
    XFontSet

 ) ;

 extern int XFontsOfFontSet (

    XFontSet                ,
    XFontStruct * * *                       ,
    char * * *

 ) ;

 extern char * XBaseFontNameListOfFontSet (

    XFontSet

 ) ;

 extern char * XLocaleOfFontSet (

    XFontSet

 ) ;

 extern int  XContextDependentDrawing (

    XFontSet

 ) ;

 extern int  XDirectionalDependentDrawing (

    XFontSet

 ) ;

 extern int  XContextualDrawing (

    XFontSet

 ) ;

 extern XFontSetExtents * XExtentsOfFontSet (

    XFontSet

 ) ;

 extern int XmbTextEscapement (

    XFontSet                ,
    const   char *           ,
    int

 ) ;

 extern int XwcTextEscapement (

    XFontSet                ,
    const   wchar_t *           ,
    int

 ) ;

 extern int XmbTextExtents (

    XFontSet                ,
    const   char *           ,
    int                   ,
    XRectangle *                          ,
    XRectangle *

 ) ;

 extern int XwcTextExtents (

    XFontSet                ,
    const   wchar_t *           ,
    int                   ,
    XRectangle *                          ,
    XRectangle *

 ) ;

 extern int    XmbTextPerCharExtents (

    XFontSet                ,
    const   char *           ,
    int                   ,
    XRectangle *                          ,
    XRectangle *                              ,
    int                    ,
    int *                 ,
    XRectangle *                          ,
    XRectangle *

 ) ;

 extern int    XwcTextPerCharExtents (

    XFontSet                ,
    const   wchar_t *           ,
    int                   ,
    XRectangle *                          ,
    XRectangle *                              ,
    int                    ,
    int *                 ,
    XRectangle *                          ,
    XRectangle *

 ) ;

 extern void XmbDrawText (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    XmbTextItem *                 ,
    int

 ) ;

 extern void XwcDrawText (

    Display *               ,
    Drawable         ,
    GC           ,
    int          ,
    int          ,
    XwcTextItem *                 ,
    int

 ) ;

 extern void XmbDrawString (

    Display *               ,
    Drawable         ,
    XFontSet                ,
    GC           ,
    int          ,
    int          ,
    const   char *           ,
    int

 ) ;

 extern void XwcDrawString (

    Display *               ,
    Drawable         ,
    XFontSet                ,
    GC           ,
    int          ,
    int          ,
    const   wchar_t *           ,
    int

 ) ;

 extern void XmbDrawImageString (

    Display *               ,
    Drawable         ,
    XFontSet                ,
    GC           ,
    int          ,
    int          ,
    const   char *           ,
    int

 ) ;

 extern void XwcDrawImageString (

    Display *               ,
    Drawable         ,
    XFontSet                ,
    GC           ,
    int          ,
    int          ,
    const   wchar_t *           ,
    int

 ) ;

 extern XIM XOpenIM (

    Display *            ,
    struct _XrmHashBucketRec *          ,
    char *                 ,
    char *

 ) ;

 extern int    XCloseIM (

    XIM

 ) ;

 extern char * XGetIMValues (

    XIM         , ...

 ) ;

 extern Display * XDisplayOfIM (

    XIM

 ) ;

 extern char * XLocaleOfIM (

    XIM

 ) ;

 extern XIC XCreateIC (

    XIM         , ...

 ) ;

 extern void XDestroyIC (

    XIC

 ) ;

 extern void XSetICFocus (

    XIC

 ) ;

 extern void XUnsetICFocus (

    XIC

 ) ;

 extern wchar_t * XwcResetIC (

    XIC

 ) ;

 extern char * XmbResetIC (

    XIC

 ) ;

 extern char * XSetICValues (

    XIC         , ...

 ) ;

 extern char * XGetICValues (

    XIC         , ...

 ) ;

 extern XIM XIMOfIC (

    XIC

 ) ;

 extern int  XFilterEvent (

    XEvent *            ,
    Window

 ) ;

 extern int XmbLookupString (

    XIC           ,
    XKeyPressedEvent *            ,
    char *                     ,
    int                     ,
    KeySym *                     ,
    int   *

 ) ;

 extern int XwcLookupString (

    XIC           ,
    XKeyPressedEvent *            ,
    wchar_t *                     ,
    int                      ,
    KeySym *                     ,
    int   *

 ) ;

 extern XVaNestedList XVaCreateNestedList (

    int           , ...

 ) ;



 extern int  XRegisterIMInstantiateCallback (

    Display *            ,
    struct _XrmHashBucketRec *          ,
    char *                 ,
    char *                  ,
    XIMProc                 ,
    XPointer *

 ) ;

 extern int  XUnregisterIMInstantiateCallback (

    Display *            ,
    struct _XrmHashBucketRec *          ,
    char *                 ,
    char *                  ,
    XIMProc                 ,
    XPointer *

 ) ;

 typedef void ( * XConnectionWatchProc ) (

    Display *            ,
    XPointer                    ,
    int            ,
    int                 ,
    XPointer *

 ) ;


 extern int    XInternalConnectionNumbers (

    Display *            ,
    int * *                  ,
    int *

 ) ;

 extern void XProcessInternalConnection (

    Display *            ,
    int

 ) ;

 extern int    XAddConnectionWatch (

    Display *            ,
    XConnectionWatchProc               ,
    XPointer

 ) ;

 extern void XRemoveConnectionWatch (

    Display *            ,
    XConnectionWatchProc               ,
    XPointer

 ) ;
#line 77  "/usr/include/X11/Xutil.h"
 typedef struct {
     long flags ;
 int x , y ;
 int width , height ;
 int min_width , min_height ;
 int max_width , max_height ;
     int width_inc , height_inc ;
 struct {
  int x ;
  int y ;
 } min_aspect , max_aspect ;
 int base_width , base_height ;
 int win_gravity ;
 } XSizeHints ;
#line 115  "/usr/include/X11/Xutil.h"
 typedef struct {
 long flags ;
 int  input ;

 int initial_state ;
 Pixmap icon_pixmap ;
 Window icon_window ;
 int icon_x , icon_y ;
 Pixmap icon_mask ;
 XID window_group ;

 } XWMHints ;
#line 159  "/usr/include/X11/Xutil.h"
 typedef struct {
    unsigned char * value ;
    Atom encoding ;
    int format ;
    unsigned long nitems ;
 } XTextProperty ;





 typedef enum {
    XStringStyle ,
    XCompoundTextStyle ,
    XTextStyle ,
    XStdICCTextStyle
 } XICCEncodingStyle ;

 typedef struct {
 int min_width , min_height ;
 int max_width , max_height ;
 int width_inc , height_inc ;
 } XIconSize ;

 typedef struct {
 char * res_name ;
 char * res_class ;
 } XClassHint ;
#line 206  "/usr/include/X11/Xutil.h"
 typedef struct _XComposeStatus {
    XPointer compose_ptr ;
    int chars_matched ;
 } XComposeStatus ;
#line 239  "/usr/include/X11/Xutil.h"
 typedef struct _XRegion * Region ;
#line 253  "/usr/include/X11/Xutil.h"
 typedef struct {
  Visual * visual ;
  VisualID visualid ;
  int screen ;
  int depth ;



  int class ;

  unsigned long red_mask ;
  unsigned long green_mask ;
  unsigned long blue_mask ;
  int colormap_size ;
  int bits_per_rgb ;
 } XVisualInfo ;
#line 286  "/usr/include/X11/Xutil.h"
 typedef struct {
 Colormap colormap ;
 unsigned long red_max ;
 unsigned long red_mult ;
 unsigned long green_max ;
 unsigned long green_mult ;
 unsigned long blue_max ;
 unsigned long blue_mult ;
 unsigned long base_pixel ;
 VisualID visualid ;
 XID killid ;
 } XStandardColormap ;
#line 323  "/usr/include/X11/Xutil.h"
 typedef int XContext ;








 extern XClassHint * XAllocClassHint (

    void

 ) ;

 extern XIconSize * XAllocIconSize (

    void

 ) ;

 extern XSizeHints * XAllocSizeHints (

    void

 ) ;

 extern XStandardColormap * XAllocStandardColormap (

    void

 ) ;

 extern XWMHints * XAllocWMHints (

    void

 ) ;

 extern int XClipBox (

    Region         ,
    XRectangle *

 ) ;

 extern Region XCreateRegion (

    void

 ) ;

 extern char * XDefaultString (

    void

 ) ;

 extern int XDeleteContext (

    Display *               ,
    XID            ,
    XContext

 ) ;

 extern int XDestroyRegion (

    Region

 ) ;

 extern int XEmptyRegion (

    Region

 ) ;

 extern int XEqualRegion (

    Region          ,
    Region

 ) ;

 extern int XFindContext (

    Display *               ,
    XID            ,
    XContext               ,
    XPointer *

 ) ;

 extern int    XGetClassHint (

    Display *               ,
    Window         ,
    XClassHint *

 ) ;

 extern int    XGetIconSizes (

    Display *               ,
    Window         ,
    XIconSize * *                        ,
    int *

 ) ;

 extern int    XGetNormalHints (

    Display *               ,
    Window         ,
    XSizeHints *

 ) ;

 extern int    XGetRGBColormaps (

    Display *               ,
    Window         ,
    XStandardColormap * *                     ,
    int *                    ,
    Atom

 ) ;

 extern int    XGetSizeHints (

    Display *               ,
    Window         ,
    XSizeHints *                    ,
    Atom

 ) ;

 extern int    XGetStandardColormap (

    Display *               ,
    Window         ,
    XStandardColormap *                      ,
    Atom

 ) ;

 extern int    XGetTextProperty (

    Display *               ,
    Window              ,
    XTextProperty *                       ,
    Atom

 ) ;

 extern XVisualInfo * XGetVisualInfo (

    Display *               ,
    long                  ,
    XVisualInfo *                     ,
    int *

 ) ;

 extern int    XGetWMClientMachine (

    Display *               ,
    Window         ,
    XTextProperty *

 ) ;

 extern XWMHints * XGetWMHints (

    Display *               ,
    Window

 ) ;

 extern int    XGetWMIconName (

    Display *               ,
    Window         ,
    XTextProperty *

 ) ;

 extern int    XGetWMName (

    Display *               ,
    Window         ,
    XTextProperty *

 ) ;

 extern int    XGetWMNormalHints (

    Display *               ,
    Window         ,
    XSizeHints *                    ,
    long *

 ) ;

 extern int    XGetWMSizeHints (

    Display *               ,
    Window         ,
    XSizeHints *                    ,
    long *                       ,
    Atom

 ) ;

 extern int    XGetZoomHints (

    Display *               ,
    Window         ,
    XSizeHints *

 ) ;

 extern int XIntersectRegion (

    Region           ,
    Region           ,
    Region

 ) ;

 extern void XConvertCase (

    KeySym           ,
    KeySym *             ,
    KeySym *

 ) ;

 extern int XLookupString (

    XKeyEvent *                    ,
    char *                     ,
    int                     ,
    KeySym *                     ,
    XComposeStatus *

 ) ;

 extern int    XMatchVisualInfo (

    Display *               ,
    int               ,
    int              ,
    int              ,
    XVisualInfo *

 ) ;

 extern int XOffsetRegion (

    Region         ,
    int           ,
    int

 ) ;

 extern int  XPointInRegion (

    Region         ,
    int          ,
    int

 ) ;

 extern Region XPolygonRegion (

    XPoint *              ,
    int          ,
    int

 ) ;

 extern int XRectInRegion (

    Region         ,
    int          ,
    int          ,
    unsigned int            ,
    unsigned int

 ) ;

 extern int XSaveContext (

    Display *               ,
    XID            ,
    XContext               ,
    const   char *

 ) ;

 extern int XSetClassHint (

    Display *               ,
    Window         ,
    XClassHint *

 ) ;

 extern int XSetIconSizes (

    Display *               ,
    Window         ,
    XIconSize *                 ,
    int

 ) ;

 extern int XSetNormalHints (

    Display *               ,
    Window         ,
    XSizeHints *

 ) ;

 extern void XSetRGBColormaps (

    Display *               ,
    Window         ,
    XStandardColormap *               ,
    int              ,
    Atom

 ) ;

 extern int XSetSizeHints (

    Display *               ,
    Window         ,
    XSizeHints *             ,
    Atom

 ) ;

 extern int XSetStandardProperties (

    Display *               ,
    Window         ,
    const   char *                  ,
    const   char *                ,
    Pixmap                   ,
    char * *            ,
    int             ,
    XSizeHints *

 ) ;

 extern void XSetTextProperty (

    Display *               ,
    Window         ,
    XTextProperty *                ,
    Atom

 ) ;

 extern void XSetWMClientMachine (

    Display *               ,
    Window         ,
    XTextProperty *

 ) ;

 extern int XSetWMHints (

    Display *               ,
    Window         ,
    XWMHints *

 ) ;

 extern void XSetWMIconName (

    Display *               ,
    Window         ,
    XTextProperty *

 ) ;

 extern void XSetWMName (

    Display *               ,
    Window         ,
    XTextProperty *

 ) ;

 extern void XSetWMNormalHints (

    Display *               ,
    Window         ,
    XSizeHints *

 ) ;

 extern void XSetWMProperties (

    Display *               ,
    Window         ,
    XTextProperty *                  ,
    XTextProperty *                ,
    char * *            ,
    int             ,
    XSizeHints *                    ,
    XWMHints *                ,
    XClassHint *

 ) ;

 extern void XmbSetWMProperties (

    Display *               ,
    Window         ,
    const   char *                  ,
    const   char *                ,
    char * *            ,
    int             ,
    XSizeHints *                    ,
    XWMHints *                ,
    XClassHint *

 ) ;

 extern void XSetWMSizeHints (

    Display *               ,
    Window         ,
    XSizeHints *             ,
    Atom

 ) ;

 extern int XSetRegion (

    Display *               ,
    GC           ,
    Region

 ) ;

 extern void XSetStandardColormap (

    Display *               ,
    Window         ,
    XStandardColormap *               ,
    Atom

 ) ;

 extern int XSetZoomHints (

    Display *               ,
    Window         ,
    XSizeHints *

 ) ;

 extern int XShrinkRegion (

    Region         ,
    int           ,
    int

 ) ;

 extern int    XStringListToTextProperty (

    char * *            ,
    int              ,
    XTextProperty *

 ) ;

 extern int XSubtractRegion (

    Region           ,
    Region           ,
    Region

 ) ;

 extern int XmbTextListToTextProperty (

    Display *               ,
    char * *            ,
    int              ,
    XICCEncodingStyle            ,
    XTextProperty *

 ) ;

 extern int XwcTextListToTextProperty (

    Display *               ,
    wchar_t * *            ,
    int              ,
    XICCEncodingStyle            ,
    XTextProperty *

 ) ;

 extern void XwcFreeStringList (

    wchar_t * *

 ) ;

 extern int    XTextPropertyToStringList (

    XTextProperty *                ,
    char * * *                   ,
    int *

 ) ;

 extern int XmbTextPropertyToTextList (

    Display *               ,
    XTextProperty *                ,
    char * * *                   ,
    int *

 ) ;

 extern int XwcTextPropertyToTextList (

    Display *               ,
    XTextProperty *                ,
    wchar_t * * *                   ,
    int *

 ) ;

 extern int XUnionRectWithRegion (

    XRectangle *                 ,
    Region                  ,
    Region

 ) ;

 extern int XUnionRegion (

    Region           ,
    Region           ,
    Region

 ) ;

 extern int XWMGeometry (

    Display *               ,
    int                      ,
    const   char *                    ,
    const   char *                       ,
    unsigned int                   ,
    XSizeHints *             ,
    int *                ,
    int *                ,
    int *                    ,
    int *                     ,
    int *

 ) ;

 extern int XXorRegion (

    Region           ,
    Region           ,
    Region

 ) ;
#line 78  "/usr/include/X11/Xresource.h"
 extern char * Xpermalloc (

    unsigned int

 ) ;







 typedef int     XrmQuark , * XrmQuarkList ;


 typedef char * XrmString ;



 extern XrmQuark XrmStringToQuark (

    const   char *

 ) ;

 extern XrmQuark XrmPermStringToQuark (

    const   char *

 ) ;


 extern XrmString XrmQuarkToString (

    XrmQuark

 ) ;

 extern XrmQuark XrmUniqueQuark (

    void

 ) ;
#line 131  "/usr/include/X11/Xresource.h"
 typedef enum { XrmBindTightly , XrmBindLoosely } XrmBinding , * XrmBindingList ;

 extern void XrmStringToQuarkList (

    const   char *             ,
    XrmQuarkList

 ) ;

 extern void XrmStringToBindingQuarkList (

    const   char *             ,
    XrmBindingList                      ,
    XrmQuarkList

 ) ;







 typedef XrmQuark     XrmName ;
 typedef XrmQuarkList XrmNameList ;




 typedef XrmQuark     XrmClass ;
 typedef XrmQuarkList XrmClassList ;
#line 174  "/usr/include/X11/Xresource.h"
 typedef XrmQuark     XrmRepresentation ;



 typedef struct {
    unsigned int    size ;
    XPointer     addr ;
 } XrmValue , * XrmValuePtr ;








 typedef struct _XrmHashBucketRec * XrmHashBucket ;
 typedef XrmHashBucket * XrmHashTable ;
 typedef XrmHashTable XrmSearchList [ ] ;
 typedef struct _XrmHashBucketRec * XrmDatabase ;


 extern void XrmDestroyDatabase (

    XrmDatabase

 ) ;

 extern void XrmQPutResource (

    XrmDatabase *               ,
    XrmBindingList               ,
    XrmQuarkList             ,
    XrmRepresentation           ,
    XrmValue *

 ) ;

 extern void XrmPutResource (

    XrmDatabase *               ,
    const   char *                ,
    const   char *           ,
    XrmValue *

 ) ;

 extern void XrmQPutStringResource (

    XrmDatabase *               ,
    XrmBindingList                    ,
    XrmQuarkList             ,
    const   char *

 ) ;

 extern void XrmPutStringResource (

    XrmDatabase *               ,
    const   char *                ,
    const   char *

 ) ;

 extern void XrmPutLineResource (

    XrmDatabase *               ,
    const   char *

 ) ;

 extern int  XrmQGetResource (

    XrmDatabase                ,
    XrmNameList                  ,
    XrmClassList                  ,
    XrmRepresentation *                        ,
    XrmValue *

 ) ;

 extern int  XrmGetResource (

    XrmDatabase                ,
    const   char *               ,
    const   char *                ,
    char * *                       ,
    XrmValue *

 ) ;

 extern int  XrmQGetSearchList (

    XrmDatabase                ,
    XrmNameList             ,
    XrmClassList              ,
    XrmSearchList                  ,
    int

 ) ;

 extern int  XrmQGetSearchResource (

    XrmSearchList           ,
    XrmName            ,
    XrmClass             ,
    XrmRepresentation *                  ,
    XrmValue *

 ) ;







 extern void XrmSetDatabase (

    Display *               ,
    XrmDatabase

 ) ;

 extern XrmDatabase XrmGetDatabase (

    Display *

 ) ;

 extern XrmDatabase XrmGetFileDatabase (

    const   char *

 ) ;

 extern int    XrmCombineFileDatabase (

    const   char *                ,
    XrmDatabase *             ,
    int

 ) ;

 extern XrmDatabase XrmGetStringDatabase (

    const   char *

 ) ;

 extern void XrmPutFileDatabase (

    XrmDatabase                ,
    const   char *

 ) ;

 extern void XrmMergeDatabases (

    XrmDatabase                 ,
    XrmDatabase *

 ) ;

 extern void XrmCombineDatabase (

    XrmDatabase                 ,
    XrmDatabase *                ,
    int

 ) ;




 extern int  XrmEnumerateDatabase (

    XrmDatabase          ,
    XrmNameList                   ,
    XrmClassList                   ,
    int             ,
    int  ( * ) (

      XrmDatabase *         ,
      XrmBindingList               ,
      XrmQuarkList             ,
      XrmRepresentation *           ,
      XrmValue *             ,
      XPointer

      )            ,
    XPointer

 ) ;

 extern char * XrmLocaleOfDatabase (

    XrmDatabase

 ) ;








 typedef enum {
    XrmoptionNoArg ,
    XrmoptionIsArg ,
    XrmoptionStickyArg ,
    XrmoptionSepArg ,
    XrmoptionResArg ,
    XrmoptionSkipArg ,
    XrmoptionSkipLine ,
    XrmoptionSkipNArgs

 } XrmOptionKind ;

 typedef struct {
    char     * option ;
    char     * specifier ;
    XrmOptionKind   argKind ;
    XPointer     value ;
 } XrmOptionDescRec , * XrmOptionDescList ;


 extern void XrmParseCommand (

    XrmDatabase *               ,
    XrmOptionDescList            ,
    int                    ,
    const   char *           ,
    int *                   ,
    char * *

 ) ;
#line 268  "/usr/include/X11/StringDefs.h"
 extern const     char XtStrings [ ] ;
 extern const     char XtR6Strings [ ] ;
#line 77  "/usr/include/X11/Intrinsic.h"
 typedef char * String ;
#line 124  "/usr/include/X11/Intrinsic.h"
 typedef struct _WidgetRec * Widget ;
 typedef Widget * WidgetList ;
 typedef struct _WidgetClassRec * WidgetClass ;
 typedef struct _CompositeRec * CompositeWidget ;
 typedef struct _XtActionsRec * XtActionList ;
 typedef struct _XtEventRec * XtEventTable ;

 typedef struct _XtAppStruct * XtAppContext ;
 typedef unsigned long XtValueMask ;
 typedef unsigned long XtIntervalId ;
 typedef unsigned long XtInputId ;
 typedef unsigned long XtWorkProcId ;
 typedef unsigned long XtSignalId ;
 typedef unsigned int XtGeometryMask ;
 typedef unsigned long XtGCMask ;
 typedef unsigned long Pixel ;
 typedef int  XtCacheType ;
#line 172  "/usr/include/X11/Intrinsic.h"
 typedef char  Boolean ;
 typedef long  XtArgVal ;
 typedef unsigned char XtEnum ;


 typedef unsigned int Cardinal ;
 typedef unsigned short Dimension ;
 typedef short  Position ;


 typedef void *  XtPointer ;






 typedef XtPointer Opaque ;
#line 57  "/usr/include/X11/Core.h"
 typedef struct _WidgetClassRec * CoreWidgetClass ;
 typedef struct _WidgetRec * CoreWidget ;
 extern      WidgetClass coreWidgetClass ;


 extern      WidgetClass widgetClass ;
#line 54  "/usr/include/X11/Composite.h"
 typedef struct _CompositeClassRec * CompositeWidgetClass ;

 typedef Cardinal ( * XtOrderProc ) (

    Widget

 ) ;



 extern void XtManageChildren (

    WidgetList                 ,
    Cardinal

 ) ;

 extern void XtManageChild (

    Widget

 ) ;

 extern void XtUnmanageChildren (

    WidgetList                 ,
    Cardinal

 ) ;

 extern void XtUnmanageChild (

    Widget

 ) ;

 typedef void ( * XtDoChangeProc ) (

    Widget                        ,
    WidgetList                         ,
    Cardinal *                             ,
    WidgetList                       ,
    Cardinal *                           ,
    XtPointer

 ) ;

 extern void XtChangeManagedSet (

    WidgetList                         ,
    Cardinal                             ,
    XtDoChangeProc                     ,
    XtPointer                   ,
    WidgetList                       ,
    Cardinal

 ) ;




 extern      WidgetClass compositeWidgetClass ;
#line 54  "/usr/include/X11/Constraint.h"
 typedef struct _ConstraintClassRec * ConstraintWidgetClass ;


 extern      WidgetClass constraintWidgetClass ;
#line 54  "/usr/include/X11/Object.h"
 typedef struct _ObjectRec * Object ;
 typedef struct _ObjectClassRec * ObjectClass ;


 extern      WidgetClass objectClass ;
#line 54  "/usr/include/X11/RectObj.h"
 typedef struct _RectObjRec * RectObj ;
 typedef struct _RectObjClassRec * RectObjClass ;


 extern      WidgetClass rectObjClass ;
#line 197  "/usr/include/X11/Intrinsic.h"
 typedef struct _TranslationData * XtTranslations ;
 typedef struct _TranslationData * XtAccelerators ;
 typedef unsigned int Modifiers ;

 typedef void ( * XtActionProc ) (

    Widget               ,
    XEvent *             ,
    String *              ,
    Cardinal *

 ) ;

 typedef XtActionProc * XtBoundActions ;

 typedef struct _XtActionsRec {
    String  string ;
    XtActionProc proc ;
 } XtActionsRec ;

 typedef enum {


    XtAddress ,
    XtBaseOffset ,
    XtImmediate ,
    XtResourceString ,
    XtResourceQuark ,
    XtWidgetBaseOffset ,
    XtProcedureArg
 } XtAddressMode ;

 typedef struct {
    XtAddressMode   address_mode ;
    XtPointer     address_id ;
    Cardinal     size ;
 } XtConvertArgRec , * XtConvertArgList ;

 typedef void ( * XtConvertArgProc ) (

    Widget               ,
    Cardinal *            ,
    XrmValue *

 ) ;

 typedef struct {
    XtGeometryMask request_mode ;
    Position x , y ;
    Dimension width , height , border_width ;
    Widget sibling ;
    int stack_mode ;
 } XtWidgetGeometry ;







 typedef void ( * XtConverter ) (

    XrmValue *            ,
    Cardinal *                ,
    XrmValue *            ,
    XrmValue *

 ) ;

 typedef Boolean ( * XtTypeConverter ) (

    Display *           ,
    XrmValue *            ,
    Cardinal *                ,
    XrmValue *            ,
    XrmValue *          ,
    XtPointer *

 ) ;

 typedef void ( * XtDestructor ) (

    XtAppContext          ,
    XrmValue *          ,
    XtPointer                       ,
    XrmValue *            ,
    Cardinal *

 ) ;

 typedef Opaque XtCacheRef ;

 typedef Opaque XtActionHookId ;

 typedef void ( * XtActionHookProc ) (

    Widget         ,
    XtPointer                   ,
    String                   ,
    XEvent *             ,
    String *              ,
    Cardinal *

 ) ;

 typedef unsigned long XtBlockHookId ;

 typedef void ( * XtBlockHookProc ) (

    XtPointer

 ) ;

 typedef void ( * XtKeyProc ) (

    Display *           ,
    unsigned int                       ,
    Modifiers                 ,
    Modifiers *                        ,
    KeySym *

 ) ;

 typedef void ( * XtCaseProc ) (

    Display *               ,
    KeySym              ,
    KeySym *                    ,
    KeySym *

 ) ;

 typedef void ( * XtEventHandler ) (

    Widget               ,
    XtPointer                ,
    XEvent *             ,
    Boolean *

 ) ;
 typedef unsigned long EventMask ;

 typedef enum { XtListHead , XtListTail } XtListPosition ;

 typedef unsigned long XtInputMask ;





 typedef void ( * XtTimerCallbackProc ) (

    XtPointer                ,
    XtIntervalId *

 ) ;

 typedef void ( * XtInputCallbackProc ) (

    XtPointer                ,
    int *              ,
    XtInputId *

 ) ;

 typedef void ( * XtSignalCallbackProc ) (

    XtPointer               ,
    XtSignalId *

 ) ;

 typedef struct {
    String name ;
    XtArgVal value ;
 } Arg , * ArgList ;

 typedef XtPointer XtVarArgsList ;

 typedef void ( * XtCallbackProc ) (

    Widget               ,
    XtPointer                ,
    XtPointer

 ) ;

 typedef struct _XtCallbackRec {
    XtCallbackProc  callback ;
    XtPointer     closure ;
 } XtCallbackRec , * XtCallbackList ;

 typedef enum {
 XtCallbackNoList ,
 XtCallbackHasNone ,
 XtCallbackHasSome
 } XtCallbackStatus ;

 typedef enum  {
    XtGeometryYes ,
    XtGeometryNo ,
    XtGeometryAlmost ,
    XtGeometryDone
 } XtGeometryResult ;

 typedef enum { XtGrabNone , XtGrabNonexclusive , XtGrabExclusive } XtGrabKind ;

 typedef struct {
    Widget  shell_widget ;
    Widget  enable_widget ;
 } XtPopdownIDRec , * XtPopdownID ;

 typedef struct _XtResource {
    String resource_name ;
    String resource_class ;
    String resource_type ;
    Cardinal resource_size ;
    Cardinal resource_offset ;
    String default_type ;
    XtPointer default_addr ;
 } XtResource , * XtResourceList ;

 typedef void ( * XtResourceDefaultProc ) (

    Widget             ,
    int              ,
    XrmValue *

 ) ;

 typedef String ( * XtLanguageProc ) (

    Display *          ,
    String          ,
    XtPointer

 ) ;

 typedef void ( * XtErrorMsgHandler ) (

    String             ,
    String            ,
    String             ,
    String               ,
    String *              ,
    Cardinal *

 ) ;

 typedef void ( * XtErrorHandler ) (

  String

 ) ;

 typedef void ( * XtCreatePopupChildProc ) (

    Widget

 ) ;

 typedef Boolean ( * XtWorkProc ) (

    XtPointer

 ) ;

 typedef struct {
    char match ;
    String substitution ;
 } SubstitutionRec , * Substitution ;

 typedef Boolean ( * XtFilePredicate ) (

   String

 ) ;

 typedef XtPointer XtRequestId ;

 typedef Boolean ( * XtConvertSelectionProc ) (

    Widget               ,
    Atom *                 ,
    Atom *              ,
    Atom *                   ,
    XtPointer *                    ,
    unsigned long *                    ,
    int *

 ) ;

 typedef void ( * XtLoseSelectionProc ) (

    Widget               ,
    Atom *

 ) ;

 typedef void ( * XtSelectionDoneProc ) (

    Widget               ,
    Atom *                 ,
    Atom *

 ) ;

 typedef void ( * XtSelectionCallbackProc ) (

    Widget               ,
    XtPointer                ,
    Atom *                 ,
    Atom *            ,
    XtPointer              ,
    unsigned long *             ,
    int *

 ) ;

 typedef void ( * XtLoseSelectionIncrProc ) (

    Widget               ,
    Atom *                 ,
    XtPointer

 ) ;

 typedef void ( * XtSelectionDoneIncrProc ) (

    Widget               ,
    Atom *                 ,
    Atom *              ,
    XtRequestId *                  ,
    XtPointer

 ) ;

 typedef Boolean ( * XtConvertSelectionIncrProc ) (

    Widget               ,
    Atom *                 ,
    Atom *              ,
    Atom *            ,
    XtPointer *             ,
    unsigned long *             ,
    int *              ,
    unsigned long *                 ,
    XtPointer                    ,
    XtRequestId *

 ) ;

 typedef void ( * XtCancelConvertSelectionProc ) (

    Widget               ,
    Atom *                 ,
    Atom *              ,
    XtRequestId *                  ,
    XtPointer

 ) ;

 typedef Boolean ( * XtEventDispatchProc ) (

    XEvent *

 ) ;

 typedef void ( * XtExtensionSelectProc ) (

    Widget              ,
    int *                   ,
    XtPointer *                   ,
    int              ,
    XtPointer

 ) ;









 extern Boolean XtConvertAndStore (

    Widget               ,
    const   char *                         ,
    XrmValue *            ,
    const   char *                       ,
    XrmValue *

 ) ;

 extern Boolean XtCallConverter (

    Display *           ,
    XtTypeConverter                 ,
    XrmValuePtr            ,
    Cardinal                 ,
    XrmValuePtr            ,
    XrmValue *                 ,
    XtCacheRef *

 ) ;

 extern Boolean XtDispatchEvent (

    XEvent *

 ) ;

 extern Boolean XtCallAcceptFocus (

    Widget               ,
    Time *

 ) ;

 extern Boolean XtPeekEvent (

    XEvent *

 ) ;

 extern Boolean XtAppPeekEvent (

    XtAppContext                   ,
    XEvent *

 ) ;

 extern Boolean XtIsSubclass (

    Widget               ,
    WidgetClass

 ) ;

 extern Boolean XtIsObject (

    Widget

 ) ;

 extern Boolean _XtCheckSubclassFlag (

    Widget              ,
    unsigned int

 ) ;

 extern Boolean _XtIsSubclassOf (

    Widget              ,
    WidgetClass                    ,
    WidgetClass                  ,
    unsigned int

 ) ;

 extern Boolean XtIsManaged (

    Widget

 ) ;

 extern Boolean XtIsRealized (

    Widget

 ) ;

 extern Boolean XtIsSensitive (

    Widget

 ) ;

 extern Boolean XtOwnSelection (

    Widget               ,
    Atom                  ,
    Time             ,
    XtConvertSelectionProc              ,
    XtLoseSelectionProc           ,
    XtSelectionDoneProc

 ) ;

 extern Boolean XtOwnSelectionIncremental (

    Widget               ,
    Atom                  ,
    Time             ,
    XtConvertSelectionIncrProc                       ,
    XtLoseSelectionIncrProc                    ,
    XtSelectionDoneIncrProc                    ,
    XtCancelConvertSelectionProc                      ,
    XtPointer

 ) ;

 extern XtGeometryResult XtMakeResizeRequest (

    Widget               ,
    unsigned int                     ,
    unsigned int                      ,
    Dimension *                    ,
    Dimension *

 ) ;

 extern void XtTranslateCoords (

    Widget               ,
    int                 ,
    int                 ,
    Position *                    ,
    Position *

 ) ;

 extern KeySym * XtGetKeysymTable (

    Display *           ,
    KeyCode *                          ,
    int *

 ) ;

 extern void XtKeysymToKeycodeList (

    Display *           ,
    KeySym               ,
    KeyCode * *                       ,
    Cardinal *

 ) ;

 extern void XtStringConversionWarning (

    const   char *                         ,
    const   char *

 ) ;

 extern void XtDisplayStringConversionWarning (

    Display *            ,
    const   char *                         ,
    const   char *

 ) ;


 extern      XtConvertArgRec const colorConvertArgs [ ] ;
 extern      XtConvertArgRec const screenConvertArg [ ] ;





 extern void XtAppAddConverter (

    XtAppContext                  ,
    const   char *                        ,
    const   char *                      ,
    XtConverter                 ,
    XtConvertArgList                   ,
    Cardinal

 ) ;

 extern void XtAddConverter (

    const   char *                        ,
    const   char *                       ,
    XtConverter                 ,
    XtConvertArgList                    ,
    Cardinal

 ) ;

 extern void XtSetTypeConverter (

    const   char *                         ,
    const   char *                       ,
    XtTypeConverter                 ,
    XtConvertArgList                    ,
    Cardinal                 ,
    XtCacheType                  ,
    XtDestructor

 ) ;

 extern void XtAppSetTypeConverter (

    XtAppContext                   ,
    const   char *                         ,
    const   char *                       ,
    XtTypeConverter                 ,
    XtConvertArgList                    ,
    Cardinal                 ,
    XtCacheType                  ,
    XtDestructor

 ) ;

 extern void XtConvert (

    Widget               ,
    const   char *                         ,
    XrmValue *            ,
    const   char *                       ,
    XrmValue *

 ) ;

 extern void XtDirectConvert (

    XtConverter                 ,
    XrmValuePtr            ,
    Cardinal                 ,
    XrmValuePtr            ,
    XrmValue *

 ) ;







 extern XtTranslations XtParseTranslationTable (

    const   char *

 ) ;

 extern XtAccelerators XtParseAcceleratorTable (

    const   char *

 ) ;

 extern void XtOverrideTranslations (

    Widget               ,
    XtTranslations

 ) ;

 extern void XtAugmentTranslations (

    Widget               ,
    XtTranslations

 ) ;

 extern void XtInstallAccelerators (

    Widget                    ,
    Widget

 ) ;

 extern void XtInstallAllAccelerators (

    Widget                    ,
    Widget

 ) ;

 extern void XtUninstallTranslations (

    Widget

 ) ;

 extern void XtAppAddActions (

    XtAppContext                   ,
    XtActionList               ,
    Cardinal

 ) ;

 extern void XtAddActions (

    XtActionList               ,
    Cardinal

 ) ;

 extern XtActionHookId XtAppAddActionHook (

    XtAppContext                   ,
    XtActionHookProc            ,
    XtPointer

 ) ;

 extern void XtRemoveActionHook (

    XtActionHookId

 ) ;

 extern void XtGetActionList (

    WidgetClass                    ,
    XtActionList *                     ,
    Cardinal *

 ) ;

 extern void XtCallActionProc (

    Widget              ,
    const   char *                     ,
    XEvent *             ,
    String *              ,
    Cardinal

 ) ;

 extern void XtRegisterGrabAction (

    XtActionProc                   ,
    int                            ,
    unsigned int                  ,
    int                     ,
    int

 ) ;

 extern void XtSetMultiClickTime (

    Display *           ,
    int

 ) ;

 extern int XtGetMultiClickTime (

    Display *

 ) ;

 extern KeySym XtGetActionKeysym (

    XEvent *             ,
    Modifiers *

 ) ;







 extern void XtTranslateKeycode (

    Display *           ,
    unsigned int                       ,
    Modifiers                  ,
    Modifiers *                        ,
    KeySym *

 ) ;

 extern void XtTranslateKey (

    Display *           ,
    unsigned int                      ,
    Modifiers                 ,
    Modifiers *                        ,
    KeySym *

 ) ;

 extern void XtSetKeyTranslator (

    Display *           ,
    XtKeyProc

 ) ;

 extern void XtRegisterCaseConverter (

    Display *           ,
    XtCaseProc             ,
    KeySym              ,
    KeySym

 ) ;

 extern void XtConvertCase (

    Display *           ,
    KeySym               ,
    KeySym *                    ,
    KeySym *

 ) ;
#line 1019  "/usr/include/X11/Intrinsic.h"
 extern void XtAddEventHandler (

    Widget               ,
    EventMask                   ,
    int                           ,
    XtEventHandler            ,
    XtPointer

 ) ;

 extern void XtRemoveEventHandler (

    Widget               ,
    EventMask                   ,
    int                           ,
    XtEventHandler            ,
    XtPointer

 ) ;

 extern void XtAddRawEventHandler (

    Widget               ,
    EventMask                   ,
    int                           ,
    XtEventHandler            ,
    XtPointer

 ) ;

 extern void XtRemoveRawEventHandler (

    Widget               ,
    EventMask                   ,
    int                           ,
    XtEventHandler            ,
    XtPointer

 ) ;

 extern void XtInsertEventHandler (

    Widget               ,
    EventMask                   ,
    int                           ,
    XtEventHandler            ,
    XtPointer                ,
    XtListPosition

 ) ;

 extern void XtInsertRawEventHandler (

    Widget               ,
    EventMask                   ,
    int                           ,
    XtEventHandler            ,
    XtPointer                ,
    XtListPosition

 ) ;

 extern XtEventDispatchProc XtSetEventDispatcher (

    Display *           ,
    int                   ,
    XtEventDispatchProc

 ) ;

 extern Boolean XtDispatchEventToWidget (

    Widget              ,
    XEvent *

 ) ;

 extern void XtInsertEventTypeHandler (

    Widget              ,
    int             ,
    XtPointer                   ,
    XtEventHandler           ,
    XtPointer               ,
    XtListPosition

 ) ;

 extern void XtRemoveEventTypeHandler (

    Widget              ,
    int             ,
    XtPointer                   ,
    XtEventHandler           ,
    XtPointer

 ) ;

 extern EventMask XtBuildEventMask (

    Widget

 ) ;

 extern void XtRegisterExtensionSelector (

    Display *           ,
    int                       ,
    int                       ,
    XtExtensionSelectProc           ,
    XtPointer

 ) ;

 extern void XtAddGrab (

    Widget               ,
    int                         ,
    int

 ) ;

 extern void XtRemoveGrab (

    Widget

 ) ;

 extern void XtProcessEvent (

    XtInputMask

 ) ;

 extern void XtAppProcessEvent (

    XtAppContext                    ,
    XtInputMask

 ) ;

 extern void XtMainLoop (

    void

 ) ;

 extern void XtAppMainLoop (

    XtAppContext

 ) ;

 extern void XtAddExposureToRegion (

    XEvent *             ,
    Region

 ) ;

 extern void XtSetKeyboardFocus (

    Widget               ,
    Widget

 ) ;

 extern Widget XtGetKeyboardFocusWidget (

    Widget

 ) ;

 extern XEvent * XtLastEventProcessed (

    Display *

 ) ;

 extern Time XtLastTimestampProcessed (

    Display *

 ) ;







 extern XtIntervalId XtAddTimeOut (

    unsigned long                ,
    XtTimerCallbackProc           ,
    XtPointer

 ) ;

 extern XtIntervalId XtAppAddTimeOut (

    XtAppContext                   ,
    unsigned long                ,
    XtTimerCallbackProc           ,
    XtPointer

 ) ;

 extern void XtRemoveTimeOut (

    XtIntervalId

 ) ;

 extern XtInputId XtAddInput (

    int               ,
    XtPointer                  ,
    XtInputCallbackProc           ,
    XtPointer

 ) ;

 extern XtInputId XtAppAddInput (

    XtAppContext                         ,
    int               ,
    XtPointer                  ,
    XtInputCallbackProc           ,
    XtPointer

 ) ;

 extern void XtRemoveInput (

    XtInputId

 ) ;

 extern XtInputId XtAppAddSignal (

    XtAppContext                         ,
    XtSignalCallbackProc           ,
    XtPointer

 ) ;

 extern void XtRemoveSignal (

    XtSignalId

 ) ;

 extern void XtNoticeSignal (

    XtSignalId

 ) ;

 extern void XtNextEvent (

    XEvent *

 ) ;

 extern void XtAppNextEvent (

    XtAppContext                   ,
    XEvent *

 ) ;







 extern XtInputMask XtPending (

    void

 ) ;

 extern XtInputMask XtAppPending (

    XtAppContext

 ) ;

 extern XtBlockHookId XtAppAddBlockHook (

    XtAppContext                   ,
    XtBlockHookProc            ,
    XtPointer

 ) ;

 extern void XtRemoveBlockHook (

    XtBlockHookId

 ) ;
#line 1352  "/usr/include/X11/Intrinsic.h"
 extern void XtRealizeWidget (

    Widget

 ) ;

 void XtUnrealizeWidget (

    Widget

 ) ;

 extern void XtDestroyWidget (

    Widget

 ) ;

 extern void XtSetSensitive (

    Widget               ,
    int

 ) ;

 extern void XtSetMappedWhenManaged (

    Widget               ,
    int

 ) ;

 extern Widget XtNameToWidget (

    Widget                  ,
    const   char *

 ) ;

 extern Widget XtWindowToWidget (

    Display *               ,
    Window

 ) ;

 extern XtPointer XtGetClassExtension (

    WidgetClass                    ,
    Cardinal                   ,
    XrmQuark            ,
    long               ,
    Cardinal

 ) ;
#line 1418  "/usr/include/X11/Intrinsic.h"
 extern ArgList XtMergeArgLists (

    ArgList              ,
    Cardinal                  ,
    ArgList              ,
    Cardinal

 ) ;
#line 1436  "/usr/include/X11/Intrinsic.h"
 extern XtVarArgsList XtVaCreateArgsList (

    XtPointer            , ...

 ) ;
#line 1452  "/usr/include/X11/Intrinsic.h"
 extern Display * XtDisplay (

    Widget

 ) ;

 extern Display * XtDisplayOfObject (

    Widget

 ) ;

 extern Screen * XtScreen (

    Widget

 ) ;

 extern Screen * XtScreenOfObject (

    Widget

 ) ;

 extern Window XtWindow (

    Widget

 ) ;

 extern Window XtWindowOfObject (

    Widget

 ) ;

 extern String XtName (

    Widget

 ) ;

 extern WidgetClass XtSuperclass (

    Widget

 ) ;

 extern WidgetClass XtClass (

    Widget

 ) ;

 extern Widget XtParent (

    Widget

 ) ;







 extern void XtAddCallback (

    Widget               ,
    const   char *                             ,
    XtCallbackProc                ,
    XtPointer

 ) ;

 extern void XtRemoveCallback (

    Widget               ,
    const   char *                             ,
    XtCallbackProc                ,
    XtPointer

 ) ;

 extern void XtAddCallbacks (

    Widget               ,
    const   char *                            ,
    XtCallbackList

 ) ;

 extern void XtRemoveCallbacks (

    Widget               ,
    const   char *                             ,
    XtCallbackList

 ) ;

 extern void XtRemoveAllCallbacks (

    Widget               ,
    const   char *

 ) ;


 extern void XtCallCallbacks (

    Widget               ,
    const   char *                             ,
    XtPointer

 ) ;

 extern void XtCallCallbackList (

    Widget              ,
    XtCallbackList                 ,
    XtPointer

 ) ;

 extern XtCallbackStatus XtHasCallbacks (

    Widget               ,
    const   char *

 ) ;








 extern XtGeometryResult XtMakeGeometryRequest (

    Widget               ,
    XtWidgetGeometry *              ,
    XtWidgetGeometry *

 ) ;

 extern XtGeometryResult XtQueryGeometry (

    Widget               ,
    XtWidgetGeometry *               ,
    XtWidgetGeometry *

 ) ;

 extern Widget XtCreatePopupShell (

    const   char *                   ,
    WidgetClass                   ,
    Widget               ,
    ArgList             ,
    Cardinal

 ) ;

 extern Widget XtVaCreatePopupShell (

    const   char *                   ,
    WidgetClass                   ,
    Widget              ,
    ...

 ) ;

 extern void XtPopup (

    Widget                    ,
    XtGrabKind

 ) ;

 extern void XtPopupSpringLoaded (

    Widget

 ) ;

 extern void XtCallbackNone (

    Widget               ,
    XtPointer                ,
    XtPointer

 ) ;

 extern void XtCallbackNonexclusive (

    Widget               ,
    XtPointer                ,
    XtPointer

 ) ;

 extern void XtCallbackExclusive (

    Widget               ,
    XtPointer                ,
    XtPointer

 ) ;

 extern void XtPopdown (

    Widget

 ) ;

 extern void XtCallbackPopdown (

    Widget               ,
    XtPointer                ,
    XtPointer

 ) ;

 extern void XtMenuPopupAction (

    Widget               ,
    XEvent *             ,
    String *              ,
    Cardinal *

 ) ;

 extern Widget XtCreateWidget (

    const   char *                    ,
    WidgetClass                    ,
    Widget               ,
    ArgList             ,
    Cardinal

 ) ;

 extern Widget XtCreateManagedWidget (

    const   char *                    ,
    WidgetClass                    ,
    Widget               ,
    ArgList             ,
    Cardinal

 ) ;

 extern Widget XtVaCreateWidget (

    const   char *                   ,
    WidgetClass              ,
    Widget              ,
    ...

 ) ;

 extern Widget XtVaCreateManagedWidget (

    const   char *                   ,
    WidgetClass                    ,
    Widget              ,
    ...

 ) ;

 extern Widget XtCreateApplicationShell (

    const   char *                    ,
    WidgetClass                    ,
    ArgList             ,
    Cardinal

 ) ;

 extern Widget XtAppCreateShell (

    const   char *                               ,
    const   char *                                ,
    WidgetClass                    ,
    Display *               ,
    ArgList             ,
    Cardinal

 ) ;

 extern Widget XtVaAppCreateShell (

    const   char *                               ,
    const   char *                                ,
    WidgetClass                    ,
    Display *               ,
    ...

 ) ;







 extern void XtToolkitInitialize (

    void

 ) ;

 extern XtLanguageProc XtSetLanguageProc (

    XtAppContext                  ,
    XtLanguageProc           ,
    XtPointer

 ) ;

 extern void XtDisplayInitialize (

    XtAppContext                   ,
    Display *           ,
    const   char *                               ,
    const   char *                                ,
    XrmOptionDescRec *               ,
    Cardinal                    ,
    int *            ,
    char * *

 ) ;

 extern Widget XtOpenApplication (

    XtAppContext *                         ,
    const   char *                                ,
    XrmOptionDescList               ,
    Cardinal                    ,
    int *                   ,
    String *                   ,
    String *                          ,
    WidgetClass                    ,
    ArgList             ,
    Cardinal

 ) ;

 extern Widget XtVaOpenApplication (

    XtAppContext *                         ,
    const   char *                                ,
    XrmOptionDescList              ,
    Cardinal                   ,
    int *                   ,
    String *                   ,
    String *                          ,
    WidgetClass                    ,
    ...

 ) ;

 extern Widget XtAppInitialize (

    XtAppContext *                         ,
    const   char *                                ,
    XrmOptionDescList               ,
    Cardinal                    ,
    int *                   ,
    String *                   ,
    String *                          ,
    ArgList             ,
    Cardinal

 ) ;

 extern Widget XtVaAppInitialize (

    XtAppContext *                         ,
    const   char *                                ,
    XrmOptionDescList              ,
    Cardinal                   ,
    int *                   ,
    String *                   ,
    String *                          ,
    ...

 ) ;

 extern Widget XtInitialize (

    const   char *                          ,
    const   char *                                 ,
    XrmOptionDescRec *               ,
    Cardinal                    ,
    int *            ,
    char * *

 ) ;

 extern Display * XtOpenDisplay (

    XtAppContext                   ,
    const   char *                             ,
    const   char *                               ,
    const   char *                                ,
    XrmOptionDescRec *              ,
    Cardinal                    ,
    int *            ,
    char * *

 ) ;

 extern XtAppContext XtCreateApplicationContext (

    void

 ) ;

 extern void XtAppSetFallbackResources (

    XtAppContext                   ,
    String *

 ) ;

 extern void XtDestroyApplicationContext (

    XtAppContext

 ) ;

 extern void XtInitializeWidgetClass (

    WidgetClass

 ) ;

 extern XtAppContext XtWidgetToApplicationContext (

    Widget

 ) ;

 extern XtAppContext XtDisplayToApplicationContext (

    Display *

 ) ;

 extern XrmDatabase XtDatabase (

    Display *

 ) ;

 extern XrmDatabase XtScreenDatabase (

    Screen *

 ) ;

 extern void XtCloseDisplay (

    Display *

 ) ;

 extern void XtGetApplicationResources (

    Widget               ,
    XtPointer             ,
    XtResourceList                 ,
    Cardinal                      ,
    ArgList             ,
    Cardinal

 ) ;

 extern void XtVaGetApplicationResources (

    Widget              ,
    XtPointer            ,
    XtResourceList                ,
    Cardinal                     ,
    ...

 ) ;

 extern void XtGetSubresources (

    Widget               ,
    XtPointer             ,
    const   char *                    ,
    const   char *                     ,
    XtResourceList                 ,
    Cardinal                      ,
    ArgList             ,
    Cardinal

 ) ;

 extern void XtVaGetSubresources (

    Widget              ,
    XtPointer            ,
    const   char *                   ,
    const   char *                    ,
    XtResourceList                ,
    Cardinal                     ,
    ...

 ) ;

 extern void XtSetValues (

    Widget               ,
    ArgList             ,
    Cardinal

 ) ;

 extern void XtVaSetValues (

    Widget              ,
    ...

 ) ;

 extern void XtGetValues (

    Widget               ,
    ArgList             ,
    Cardinal

 ) ;

 extern void XtVaGetValues (

    Widget              ,
    ...

 ) ;

 extern void XtSetSubvalues (

    XtPointer             ,
    XtResourceList                 ,
    Cardinal                      ,
    ArgList             ,
    Cardinal

 ) ;

 extern void XtVaSetSubvalues (

    XtPointer            ,
    XtResourceList                ,
    Cardinal                     ,
    ...

 ) ;

 extern void XtGetSubvalues (

    XtPointer             ,
    XtResourceList                 ,
    Cardinal                      ,
    ArgList             ,
    Cardinal

 ) ;

 extern void XtVaGetSubvalues (

    XtPointer            ,
    XtResourceList                ,
    Cardinal                     ,
    ...

 ) ;

 extern void XtGetResourceList (

    WidgetClass                    ,
    XtResourceList *                       ,
    Cardinal *

 ) ;

 extern void XtGetConstraintResourceList (

    WidgetClass                    ,
    XtResourceList *                       ,
    Cardinal *

 ) ;
#line 2080  "/usr/include/X11/Intrinsic.h"
 typedef struct _XtCheckpointTokenRec {
    int  save_type ;
    int  interact_style ;
    Boolean shutdown ;
    Boolean fast ;
    Boolean cancel_shutdown ;
    int  phase ;
    int  interact_dialog_type ;
    Boolean request_cancel ;
    Boolean request_next_phase ;
    Boolean save_success ;
    int  type ;
    Widget widget ;
 } XtCheckpointTokenRec , * XtCheckpointToken ;

 XtCheckpointToken XtSessionGetToken (

    Widget

 ) ;

 void XtSessionReturnToken (

    XtCheckpointToken

 ) ;







 extern XtErrorMsgHandler XtAppSetErrorMsgHandler (

    XtAppContext                   ,
    XtErrorMsgHandler

 ) ;

 extern void XtSetErrorMsgHandler (

    XtErrorMsgHandler

 ) ;

 extern XtErrorMsgHandler XtAppSetWarningMsgHandler (

    XtAppContext                   ,
    XtErrorMsgHandler

 ) ;

 extern void XtSetWarningMsgHandler (

    XtErrorMsgHandler

 ) ;

 extern void XtAppErrorMsg (

    XtAppContext                   ,
    const   char *                    ,
    const   char *                   ,
    const   char *                    ,
    const   char *                      ,
    String *              ,
    Cardinal *

 ) ;

 extern void XtErrorMsg (

    const   char *                    ,
    const   char *                   ,
    const   char *                    ,
    const   char *                      ,
    String *              ,
    Cardinal *

 ) ;

 extern void XtAppWarningMsg (

    XtAppContext                   ,
    const   char *                    ,
    const   char *                    ,
    const   char *                     ,
    const   char *                       ,
    String *              ,
    Cardinal *

 ) ;

 extern void XtWarningMsg (

    const   char *                   ,
    const   char *                   ,
    const   char *                    ,
    const   char *                      ,
    String *              ,
    Cardinal *

 ) ;

 extern XtErrorHandler XtAppSetErrorHandler (

    XtAppContext                   ,
    XtErrorHandler

 ) ;

 extern void XtSetErrorHandler (

    XtErrorHandler

 ) ;

 extern XtErrorHandler XtAppSetWarningHandler (

    XtAppContext                   ,
    XtErrorHandler

 ) ;

 extern void XtSetWarningHandler (

    XtErrorHandler

 ) ;

 extern void XtAppError (

    XtAppContext                   ,
    const   char *

 ) ;

 extern void XtError (

    const   char *

 ) ;

 extern void XtAppWarning (

    XtAppContext                   ,
    const   char *

 ) ;

 extern void XtWarning (

    const   char *

 ) ;

 extern XrmDatabase * XtAppGetErrorDatabase (

    XtAppContext

 ) ;

 extern XrmDatabase * XtGetErrorDatabase (

    void

 ) ;

 extern void XtAppGetErrorDatabaseText (

    XtAppContext                   ,
    const   char *                   ,
    const   char *                   ,
    const   char *                    ,
    const   char *                       ,
    String                      ,
    int               ,
    XrmDatabase

 ) ;

 extern void XtGetErrorDatabaseText (

    const   char *                   ,
    const   char *                   ,
    const   char *                    ,
    const   char *                       ,
    String                      ,
    int

 ) ;







 extern char * XtMalloc (

    Cardinal

 ) ;

 extern char * XtCalloc (

    Cardinal           ,
    Cardinal

 ) ;

 extern char * XtRealloc (

    char *            ,
    Cardinal

 ) ;

 extern void XtFree (

    char *

 ) ;
#line 2356  "/usr/include/X11/Intrinsic.h"
 extern XtWorkProcId XtAddWorkProc (

    XtWorkProc             ,
    XtPointer

 ) ;

 extern XtWorkProcId XtAppAddWorkProc (

    XtAppContext                   ,
    XtWorkProc             ,
    XtPointer

 ) ;

 extern void  XtRemoveWorkProc (

    XtWorkProcId

 ) ;







 extern GC XtGetGC (

    Widget               ,
    XtGCMask                  ,
    XGCValues *

 ) ;

 extern GC XtAllocateGC (

    Widget               ,
    Cardinal             ,
    XtGCMask                  ,
    XGCValues *               ,
    XtGCMask                   ,
    XtGCMask

 ) ;





 extern void XtDestroyGC (

    GC

 ) ;

 extern void XtReleaseGC (

    Widget               ,
    GC

 ) ;



 extern void XtAppReleaseCacheRefs (

    XtAppContext                  ,
    XtCacheRef *

 ) ;

 extern void XtCallbackReleaseCacheRef (

    Widget               ,
    XtPointer                ,
    XtPointer

 ) ;

 extern void XtCallbackReleaseCacheRefList (

    Widget               ,
    XtPointer                ,
    XtPointer

 ) ;

 extern void XtSetWMColormapWindows (

    Widget               ,
    Widget *            ,
    Cardinal

 ) ;

 extern String XtFindFile (

    const   char *                   ,
    Substitution                    ,
    Cardinal                          ,
    XtFilePredicate

 ) ;

 extern String XtResolvePathname (

    Display *           ,
    const   char *                   ,
    const   char *                       ,
    const   char *                     ,
    const   char *                   ,
    Substitution                    ,
    Cardinal                         ,
    XtFilePredicate

 ) ;









 extern void XtDisownSelection (

    Widget               ,
    Atom                  ,
    Time

 ) ;

 extern void XtGetSelectionValue (

    Widget               ,
    Atom                  ,
    Atom               ,
    XtSelectionCallbackProc               ,
    XtPointer                ,
    Time

 ) ;

 extern void XtGetSelectionValues (

    Widget               ,
    Atom                  ,
    Atom *               ,
    int              ,
    XtSelectionCallbackProc               ,
    XtPointer *                ,
    Time

 ) ;

 extern void XtAppSetSelectionTimeout (

    XtAppContext                   ,
    unsigned long

 ) ;

 extern void XtSetSelectionTimeout (

    unsigned long

 ) ;

 extern unsigned long XtAppGetSelectionTimeout (

    XtAppContext

 ) ;

 extern unsigned long XtGetSelectionTimeout (

    void

 ) ;

 extern XSelectionRequestEvent * XtGetSelectionRequest (

    Widget               ,
    Atom                  ,
    XtRequestId

 ) ;

 extern void XtGetSelectionValueIncremental (

    Widget               ,
    Atom                  ,
    Atom               ,
    XtSelectionCallbackProc                         ,
    XtPointer                    ,
    Time

 ) ;

 extern void XtGetSelectionValuesIncremental (

    Widget               ,
    Atom                  ,
    Atom *               ,
    int              ,
    XtSelectionCallbackProc               ,
    XtPointer *                   ,
    Time

 ) ;

 extern void XtSetSelectionParameters (

    Widget                 ,
    Atom                 ,
    Atom            ,
    XtPointer             ,
    unsigned long             ,
    int

 ) ;

 extern void XtGetSelectionParameters (

    Widget             ,
    Atom                 ,
    XtRequestId                  ,
    Atom *                   ,
    XtPointer *                    ,
    unsigned long *                    ,
    int *

 ) ;

 extern void XtCreateSelectionRequest (

    Widget                 ,
    Atom

 ) ;

 extern void XtSendSelectionRequest (

    Widget                 ,
    Atom                 ,
    Time

 ) ;

 extern void XtCancelSelectionRequest (

    Widget                 ,
    Atom

 ) ;

 extern Atom XtReservePropertyAtom (

    Widget

 ) ;

 extern void XtReleasePropertyAtom (

    Widget              ,
    Atom

 ) ;

 extern void XtGrabKey (

    Widget               ,
    unsigned int                       ,
    Modifiers                  ,
    int                            ,
    int                     ,
    int

 ) ;

 extern void XtUngrabKey (

    Widget               ,
    unsigned int                       ,
    Modifiers

 ) ;

 extern int XtGrabKeyboard (

    Widget               ,
    int                            ,
    int                     ,
    int                      ,
    Time

 ) ;

 extern void XtUngrabKeyboard (

    Widget               ,
    Time

 ) ;

 extern void XtGrabButton (

    Widget               ,
    int               ,
    Modifiers                  ,
    int                            ,
    unsigned int                 ,
    int                     ,
    int                      ,
    Window                   ,
    Cursor

 ) ;

 extern void XtUngrabButton (

    Widget               ,
    unsigned int             ,
    Modifiers

 ) ;

 extern int XtGrabPointer (

    Widget               ,
    int                            ,
    unsigned int                 ,
    int                     ,
    int                      ,
    Window                   ,
    Cursor               ,
    Time

 ) ;

 extern void XtUngrabPointer (

    Widget               ,
    Time

 ) ;

 extern void XtGetApplicationNameAndClass (

    Display *           ,
    String *                   ,
    String *

 ) ;

 extern void XtRegisterDrawable (

    Display *           ,
    Drawable                ,
    Widget

 ) ;

 extern void XtUnregisterDrawable (

    Display *           ,
    Drawable

 ) ;

 extern Widget XtHooksOfDisplay (

    Display *

 ) ;

 typedef struct {
    String type ;
    Widget widget ;
    ArgList args ;
    Cardinal num_args ;
 } XtCreateHookDataRec , * XtCreateHookData ;

 typedef struct {
    String type ;
    Widget widget ;
    XtPointer event_data ;
    Cardinal num_event_data ;
 } XtChangeHookDataRec , * XtChangeHookData ;

 typedef struct {
    Widget old , req ;
    ArgList args ;
    Cardinal num_args ;
 } XtChangeHookSetValuesDataRec , * XtChangeHookSetValuesData ;

 typedef struct {
    String type ;
    Widget widget ;
    XtGeometryMask changeMask ;
    XWindowChanges changes ;
 } XtConfigureHookDataRec , * XtConfigureHookData ;

 typedef struct {
    String type ;
    Widget widget ;
    XtWidgetGeometry * request ;
    XtWidgetGeometry * reply ;
    XtGeometryResult result ;
 } XtGeometryHookDataRec , * XtGeometryHookData ;

 typedef struct {
    String type ;
    Widget widget ;
 } XtDestroyHookDataRec , * XtDestroyHookData ;

 extern void XtGetDisplays (

    XtAppContext                  ,
    Display * * *                  ,
    Cardinal *

 ) ;

 extern Boolean XtToolkitThreadInitialize (

    void

 ) ;

 extern void XtAppSetExitFlag (

    XtAppContext

 ) ;

 extern Boolean XtAppGetExitFlag (

    XtAppContext

 ) ;

 extern void XtAppLock (

    XtAppContext

 ) ;

 extern void XtAppUnlock (

    XtAppContext

 ) ;








 extern Boolean XtCvtStringToAcceleratorTable (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToAtom (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToBool (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToBoolean (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToCommandArgArray (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToCursor (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToDimension (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToDirectoryString (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToDisplay (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToFile (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToFloat (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToFont (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToFontSet (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToFontStruct (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToGravity (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToInitialState (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToInt (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToPixel (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;



 extern Boolean XtCvtStringToRestartStyle (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToShort (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToTranslationTable (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToUnsignedChar (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtStringToVisual (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;



 extern Boolean XtCvtIntToBool (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtIntToBoolean (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtIntToColor (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;



 extern Boolean XtCvtIntToFloat (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtIntToFont (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtIntToPixel (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtIntToPixmap (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;



 extern Boolean XtCvtIntToShort (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;

 extern Boolean XtCvtIntToUnsignedChar (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;



 extern Boolean XtCvtColorToPixel (

    Display *          ,
    XrmValuePtr           ,
    Cardinal *                 ,
    XrmValuePtr              ,
    XrmValuePtr            ,
    XtPointer *

 ) ;
#line 61  "/usr/include/X11/IntrinsicP.h"
 typedef struct {
    long xrm_name ;
    long xrm_class ;
    long xrm_type ;
    Cardinal xrm_size ;
    int  xrm_offset ;
    long xrm_default_type ;
    XtPointer xrm_default_addr ;
 } XrmResource , * XrmResourceList ;

 typedef unsigned long XtVersionType ;








 typedef void ( * XtProc ) (

    void

 ) ;

 typedef void ( * XtWidgetClassProc ) (

    WidgetClass

 ) ;

 typedef void ( * XtWidgetProc ) (

    Widget

 ) ;

 typedef Boolean ( * XtAcceptFocusProc ) (

    Widget             ,
    Time *

 ) ;

 typedef void ( * XtArgsProc ) (

    Widget             ,
    ArgList           ,
    Cardinal *

 ) ;

 typedef void ( * XtInitProc ) (

    Widget              ,
    Widget          ,
    ArgList           ,
    Cardinal *

 ) ;

 typedef Boolean ( * XtSetValuesFunc ) (

    Widget           ,
    Widget               ,
    Widget           ,
    ArgList            ,
    Cardinal *

 ) ;

 typedef Boolean ( * XtArgsFunc ) (

    Widget             ,
    ArgList           ,
    Cardinal *

 ) ;

 typedef void ( * XtAlmostProc ) (

    Widget           ,
    Widget           ,
    XtWidgetGeometry *              ,
    XtWidgetGeometry *

 ) ;

 typedef void ( * XtExposeProc ) (

    Widget             ,
    XEvent *            ,
    Region

 ) ;
#line 169  "/usr/include/X11/IntrinsicP.h"
 typedef void ( * XtRealizeProc ) (

    Widget                 ,
    XtValueMask *              ,
    XSetWindowAttributes *

 ) ;

 typedef XtGeometryResult ( * XtGeometryHandler ) (

    Widget              ,
    XtWidgetGeometry *              ,
    XtWidgetGeometry *

 ) ;

 typedef void ( * XtStringProc ) (

    Widget             ,
    String

 ) ;

 typedef struct {
    String name ;
    String type ;
    XtArgVal value ;
    int  size ;
 } XtTypedArg , * XtTypedArgList ;

 typedef void ( * XtAllocateProc ) (

    WidgetClass                    ,
    Cardinal *                       ,
    Cardinal *                  ,
    ArgList            ,
    Cardinal *                ,
    XtTypedArgList                 ,
    Cardinal *                      ,
    Widget *                     ,
    XtPointer *

 ) ;

 typedef void ( * XtDeallocateProc ) (

    Widget              ,
    XtPointer

 ) ;

 struct _XtStateRec ;

 typedef struct _XtTMRec {
    XtTranslations  translations ;
    XtBoundActions  proc_table ;
    struct _XtStateRec * current_state ;
    unsigned long   lastEventTime ;
 } XtTMRec , * XtTM ;
#line 59  "/usr/include/X11/CoreP.h"
 extern      int _XtInheritTranslations ;
#line 76  "/usr/include/X11/CoreP.h"
 typedef struct _CorePart {
    Widget     self ;
    WidgetClass     widget_class ;
    Widget     parent ;
    XrmName         xrm_name ;
    Boolean         being_destroyed ;
    XtCallbackList  destroy_callbacks ;
    XtPointer       constraints ;
    Position        x , y ;
    Dimension       width , height ;
    Dimension       border_width ;
    Boolean         managed ;
    Boolean     sensitive ;
    Boolean         ancestor_sensitive ;
    XtEventTable    event_table ;
    XtTMRec     tm ;
    XtTranslations  accelerators ;
    Pixel     border_pixel ;
    Pixmap          border_pixmap ;
    WidgetList      popup_list ;
    Cardinal        num_popups ;
    String          name ;
    Screen     * screen ;
    Colormap        colormap ;
    Window     window ;
    Cardinal        depth ;
    Pixel     background_pixel ;
    Pixmap          background_pixmap ;
    Boolean         visible ;
    Boolean     mapped_when_managed ;
 } CorePart ;

 typedef struct _WidgetRec {
    CorePart    core ;
 } WidgetRec , CoreRec ;
#line 129  "/usr/include/X11/CoreP.h"
 typedef struct _CoreClassPart {
    WidgetClass     superclass ;
    String          class_name ;
    Cardinal        widget_size ;
    XtProc     class_initialize ;
    XtWidgetClassProc class_part_initialize ;
    XtEnum          class_inited ;
    XtInitProc      initialize ;
    XtArgsProc      initialize_hook ;
    XtRealizeProc   realize ;
    XtActionList    actions ;
    Cardinal     num_actions ;
    XtResourceList  resources ;
    Cardinal        num_resources ;
    XrmClass        xrm_class ;
    Boolean         compress_motion ;
    XtEnum          compress_exposure ;
    Boolean         compress_enterleave ;
    Boolean         visible_interest ;
    XtWidgetProc    destroy ;
    XtWidgetProc    resize ;
    XtExposeProc    expose ;
    XtSetValuesFunc set_values ;
    XtArgsFunc      set_values_hook ;
    XtAlmostProc    set_values_almost ;
    XtArgsProc      get_values_hook ;
    XtAcceptFocusProc accept_focus ;
    XtVersionType   version ;
    XtPointer       callback_private ;
    String          tm_table ;
    XtGeometryHandler query_geometry ;
    XtStringProc    display_accelerator ;
    XtPointer     extension ;
 } CoreClassPart ;

 typedef struct _WidgetClassRec {
    CoreClassPart core_class ;
 } WidgetClassRec , CoreClassRec ;

 extern      WidgetClassRec widgetClassRec ;
#line 62  "/usr/include/X11/CompositeP.h"
 typedef struct _CompositePart {
    WidgetList  children ;
    Cardinal    num_children ;
    Cardinal    num_slots ;
    XtOrderProc insert_position ;
 } CompositePart , * CompositePtr ;

 typedef struct _CompositeRec {
    CorePart      core ;
    CompositePart composite ;
 } CompositeRec ;







 typedef struct _CompositeClassPart {
    XtGeometryHandler geometry_manager ;
    XtWidgetProc      change_managed ;
    XtWidgetProc      insert_child ;
    XtWidgetProc      delete_child ;
    XtPointer       extension ;
 } CompositeClassPart , * CompositePartPtr ;

 typedef struct {
    XtPointer next_extension ;
    XrmQuark record_type ;
    long version ;
    Cardinal record_size ;
    Boolean accepts_objects ;
    Boolean allows_change_managed_set ;
 } CompositeClassExtensionRec , * CompositeClassExtension ;


 typedef struct _CompositeClassRec {
     CoreClassPart      core_class ;
     CompositeClassPart composite_class ;
 } CompositeClassRec ;

 extern      CompositeClassRec compositeClassRec ;
#line 56  "/usr/include/X11/ConstrainP.h"
 typedef struct _ConstraintPart {
    XtPointer   mumble ;
 } ConstraintPart ;

 typedef struct _ConstraintRec {
    CorePart     core ;
    CompositePart   composite ;
    ConstraintPart  constraint ;
 } ConstraintRec , * ConstraintWidget ;

 typedef struct _ConstraintClassPart {
    XtResourceList resources ;
    Cardinal   num_resources ;
    Cardinal   constraint_size ;
    XtInitProc initialize ;
    XtWidgetProc destroy ;
    XtSetValuesFunc set_values ;
    XtPointer     extension ;
 } ConstraintClassPart ;

 typedef struct {
    XtPointer next_extension ;
    XrmQuark record_type ;
    long version ;
    Cardinal record_size ;
    XtArgsProc get_values_hook ;
 } ConstraintClassExtensionRec , * ConstraintClassExtension ;

 typedef struct _ConstraintClassRec {
    CoreClassPart       core_class ;
    CompositeClassPart  composite_class ;
    ConstraintClassPart constraint_class ;
 } ConstraintClassRec ;

 extern      ConstraintClassRec constraintClassRec ;
#line 62  "/usr/include/X11/ObjectP.h"
 typedef struct _ObjectPart {
    Widget          self ;
    WidgetClass     widget_class ;
    Widget          parent ;
    XrmName         xrm_name ;
    Boolean         being_destroyed ;
    XtCallbackList  destroy_callbacks ;
    XtPointer       constraints ;
 } ObjectPart ;

 typedef struct _ObjectRec {
    ObjectPart  object ;
 } ObjectRec ;
#line 85  "/usr/include/X11/ObjectP.h"
 typedef struct _ObjectClassPart {

    WidgetClass     superclass ;
    String          class_name ;
    Cardinal        widget_size ;
    XtProc          class_initialize ;
    XtWidgetClassProc class_part_initialize ;
    XtEnum          class_inited ;
    XtInitProc      initialize ;
    XtArgsProc      initialize_hook ;
    XtProc          obj1 ;
    XtPointer       obj2 ;
    Cardinal        obj3 ;
    XtResourceList  resources ;
    Cardinal        num_resources ;
    XrmClass        xrm_class ;
    Boolean         obj4 ;
    XtEnum          obj5 ;
    Boolean         obj6 ;
    Boolean         obj7 ;
    XtWidgetProc    destroy ;
    XtProc          obj8 ;
    XtProc          obj9 ;
    XtSetValuesFunc set_values ;
    XtArgsFunc      set_values_hook ;
    XtProc          obj10 ;
    XtArgsProc      get_values_hook ;
    XtProc          obj11 ;
    XtVersionType   version ;
    XtPointer       callback_private ;
    String          obj12 ;
    XtProc          obj13 ;
    XtProc          obj14 ;
    XtPointer       extension ;
 } ObjectClassPart ;

 typedef struct {
    XtPointer next_extension ;
    XrmQuark record_type ;
    long version ;
    Cardinal record_size ;
    XtAllocateProc allocate ;
    XtDeallocateProc deallocate ;
 } ObjectClassExtensionRec , * ObjectClassExtension ;

 typedef struct _ObjectClassRec {
    ObjectClassPart object_class ;
 } ObjectClassRec ;

 extern      ObjectClassRec objectClassRec ;
#line 63  "/usr/include/X11/RectObjP.h"
 typedef struct _RectObjPart {
    Position        x , y ;
    Dimension       width , height ;
    Dimension       border_width ;
    Boolean         managed ;
    Boolean         sensitive ;
    Boolean         ancestor_sensitive ;
 } RectObjPart ;

 typedef struct _RectObjRec {
    ObjectPart object ;
    RectObjPart rectangle ;
 } RectObjRec ;
#line 88  "/usr/include/X11/RectObjP.h"
 typedef struct _RectObjClassPart {

    WidgetClass     superclass ;
    String          class_name ;
    Cardinal        widget_size ;
    XtProc          class_initialize ;
    XtWidgetClassProc class_part_initialize ;
    XtEnum          class_inited ;
    XtInitProc      initialize ;
    XtArgsProc      initialize_hook ;
    XtProc          rect1 ;
    XtPointer       rect2 ;
    Cardinal        rect3 ;
    XtResourceList  resources ;
    Cardinal        num_resources ;
    XrmClass        xrm_class ;
    Boolean         rect4 ;
    XtEnum          rect5 ;
    Boolean         rect6 ;
    Boolean         rect7 ;
    XtWidgetProc    destroy ;
    XtWidgetProc    resize ;
    XtExposeProc    expose ;
    XtSetValuesFunc set_values ;
    XtArgsFunc      set_values_hook ;
    XtAlmostProc    set_values_almost ;
    XtArgsProc      get_values_hook ;
    XtProc          rect9 ;
    XtVersionType   version ;
    XtPointer       callback_private ;
    String          rect10 ;
    XtGeometryHandler query_geometry ;
    XtProc          rect11 ;
    XtPointer       extension ;
 } RectObjClassPart ;

 typedef struct _RectObjClassRec {
    RectObjClassPart rect_class ;
 } RectObjClassRec ;

 extern      RectObjClassRec rectObjClassRec ;
#line 291  "/usr/include/X11/IntrinsicP.h"
 extern Widget _XtWindowedAncestor (

    Widget

 ) ;

 extern void _XtInherit (

    void

 ) ;

 extern void XtCreateWindow (

    Widget               ,
    unsigned int                    ,
    Visual *              ,
    XtValueMask                  ,
    XSetWindowAttributes *

 ) ;

 extern void XtResizeWidget (

    Widget               ,
    unsigned int                     ,
    unsigned int                      ,
    unsigned int

 ) ;

 extern void XtMoveWidget (

    Widget               ,
    int                 ,
    int

 ) ;

 extern void XtConfigureWidget (

    Widget               ,
    int                 ,
    int                 ,
    unsigned int                     ,
    unsigned int                      ,
    unsigned int

 ) ;

 extern void XtResizeWindow (

    Widget

 ) ;

 extern void XtProcessLock (

    void

 ) ;

 extern void XtProcessUnlock (

    void

 ) ;
#line 105  "/usr/include/X11/extensions/multibuf.h"
 typedef XID Multibuffer ;

 typedef struct {
    int type ;
    unsigned long serial ;
    int send_event ;
    Display * display ;
    Multibuffer buffer ;
    int state ;
 } XmbufClobberNotifyEvent ;

 typedef struct {
    int type ;
    unsigned long serial ;
    int send_event ;
    Display * display ;
    Multibuffer buffer ;
 } XmbufUpdateNotifyEvent ;





 typedef struct {
    int displayed_index ;
    int update_action ;
    int update_hint ;
    int window_mode ;
    int nbuffers ;
    Multibuffer * buffers ;
 } XmbufWindowAttributes ;




 typedef struct {
    int update_hint ;
 } XmbufSetWindowAttributes ;





 typedef struct {
    Window window ;
    unsigned long event_mask ;
    int buffer_index ;
    int side ;
 } XmbufBufferAttributes ;




 typedef struct {
    unsigned long event_mask ;
 } XmbufSetBufferAttributes ;





 typedef struct {
    VisualID visualid ;
    int max_buffers ;
    int depth ;
 } XmbufBufferInfo ;



 extern int  XmbufQueryExtension (

    Display *           ,
    int *                         ,
    int *

 ) ;

 extern int    XmbufGetVersion (

    Display *           ,
    int *                            ,
    int *

 ) ;

 extern int XmbufCreateBuffers (

    Display *           ,
    Window         ,
    int              ,
    int                      ,
    int                    ,
    Multibuffer *

 ) ;

 extern void XmbufDestroyBuffers (

    Display *           ,
    Window

 ) ;

 extern void XmbufDisplayBuffers (

    Display *           ,
    int              ,
    Multibuffer *              ,
    int                  ,
    int

 ) ;

 extern int    XmbufGetWindowAttributes (

    Display *            ,
    Window          ,
    XmbufWindowAttributes *

 ) ;

 extern void XmbufChangeWindowAttributes (

    Display *            ,
    Window          ,
    unsigned long                 ,
    XmbufSetWindowAttributes *

 ) ;

 extern int    XmbufGetBufferAttributes (

    Display *            ,
    Multibuffer          ,
    XmbufBufferAttributes *

 ) ;

 extern void XmbufChangeBufferAttributes (

    Display *            ,
    Multibuffer          ,
    unsigned long                 ,
    XmbufSetBufferAttributes *

 ) ;

 extern int    XmbufGetScreenInfo (

    Display *            ,
    Drawable          ,
    int *                     ,
    XmbufBufferInfo * *                        ,
    int *                       ,
    XmbufBufferInfo * *

 ) ;

 extern Window XmbufCreateStereoWindow (

    Display *            ,
    Window               ,
    int           ,
    int           ,
    unsigned int             ,
    unsigned int              ,
    unsigned int                    ,
    int               ,
    unsigned int             ,
    Visual *               ,
    unsigned long                 ,
    XSetWindowAttributes *           ,
    Multibuffer *             ,
    Multibuffer *

 ) ;

 extern void XmbufClearBufferArea (

    Display *            ,
    Multibuffer               ,
    int           ,
    int           ,
    unsigned int             ,
    unsigned int              ,
    int

 ) ;
#line 30  "/opt/ingr/exnucdp/include/wl.h"
 typedef void * GLXContext ;
#line 45  "/opt/ingr/exnucdp/include/wl.h"
 typedef unsigned int  WLuint32 ;
 typedef unsigned short  WLuint16 ;
 typedef unsigned char WLuint8 ;
 typedef int   WLint32 ;
 typedef short   WLint16 ;
 typedef char   WLint8 ;
 typedef WLuint32        WLcolorref ;



 typedef Window         WLhwin_no ;
 typedef void          * WLhandle ;
 typedef void          * WLwndproc ;
 typedef Cursor          WLcursor ;
 typedef Colormap        WLcolormap ;
 typedef XImage  * WLfast_buffer ;
 typedef Font            WLfont ;
#line 89  "/opt/ingr/exnucdp/include/wl.h"
 struct WLinit
 {
   char   * display_name ;
   int    batch_mode ;

   int    flags ;
   char   * shell_name ;
   char   * app_class ;
   XrmOptionDescRec  * options ;
   Cardinal  num_options ;
   Cardinal  * argc ;
   char      * * argv ;
 } ;

 struct WLinit_ret_val
 {
   Display * display ;
   Widget  widget ;

 } ;
#line 171  "/opt/ingr/exnucdp/include/wl.h"
 struct WLnative_info
 {
   Display       * display ;
   GC            gc ;
   GC            hl_gc ;
   WLhwin_no     base_win ;
   WLhwin_no     hl_win ;
   WLcolormap    colormap ;
   WLcolormap    hl_colormap ;
   Visual        * visual ;
   Visual        * hl_visual ;
   int           screen ;
   WLcursor      cursor ;
   int           flags ;
#line 204  "/opt/ingr/exnucdp/include/wl.h"
 } ;
#line 236  "/opt/ingr/exnucdp/include/wl.h"
 struct WLcontext_info
 {
   int           base_cmap_type ;
   int           base_depth ;
   int           hilite_used ;
   int           flags ;
 } ;

 struct WLcontext_interaction
 {
   WLuint32  context_no ;
   int   number ;
   int   num_of_coexists ;
 } ;

 struct WLbounds
 {
   int   x , y ;
   int   width ;
   int   height ;
 } ;

 struct WLcmap_entry
 {
   WLuint16  slot ;
   WLuint16  red , green , blue ;
   WLuint32  flags ;
 } ;









 struct WLraster_data
 {
   int          x , y ;
   WLuint32     width , height ;
   char         * buffer ;
   WLuint16 lras_no ;
 } ;



 struct WLpoint
 {
   short  x , y ;
 } ;
#line 299  "/opt/ingr/exnucdp/include/wl.h"
 struct WLrect
 {
   int   x , y ;
   int   width , height ;
 } ;
#line 460  "/opt/ingr/exnucdp/include/wl.h"
 extern int WLadd_hardware_window ( WLhwin_no hwin_no , WLuint32 context_no , struct WLnative_info * native_info , WLuint32 * lwin_no )



                      ;

 extern int WLset_num_wm_colors ( WLint32 num_wm_colors )
                           ;

 extern int WLset_num_ingr_colors ( WLint32 num_ingr_colors )
                             ;

 extern int WLchange_window_cmap ( WLuint16 lscreen_no , WLuint32 lwin_no , WLuint32 context_no )


                         ;

 extern int WLcreate_context ( WLuint16 lscreen_no , struct WLcontext_info * context , int ( * cmap_color_to_index ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * phy_index ) , int ( * cmap_color_to_rgb ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * out_red , WLuint32 * out_green , WLuint32 * out_blue ) , int ( * cmap_init ) ( WLuint32 context_no ) , WLuint32 * context_no )
#line 500  "/opt/ingr/exnucdp/include/wl.h"
                         ;

 extern int WLcreate_window ( WLuint16 lscreen_no , char * name , struct WLbounds * bounds , int border_width , WLuint32 context_no , WLuint32 * lwin_no )





                       ;

 extern int WLdelete_context ( WLuint16 lscreen_no , WLuint32 context_no )

                        ;

 extern int WLdelete_window ( WLuint32 lwin_no )
                      ;

 extern int WLinitialize ( struct WLinit * init_struct , struct WLinit_ret_val * init_ret )

                                     ;

 extern int WLflush ( WLuint32 lwin_no )
                      ;

 extern int WLfree ( void * ptr )
               ;

 extern int WLget_active_screen ( WLuint16 * lscreen_no , int * screen_type )

                      ;

 extern int WLget_context_depth ( WLuint32 context_no , int * depth )

                 ;

 extern int WLget_number_of_screens ( int * num_screens , WLuint16 * * list_of_screens )

                                ;

 extern int WLget_logical_screen_from_window ( WLhwin_no hwin_no , WLuint16 * lscreen_no )

                         ;

 extern int WLget_logical_screen_from_screen ( int screen_no , WLuint16 * lscreen_no )

                         ;

 extern int WLget_window_name ( WLuint32 lwin_no , char * * name )

                 ;

 extern int WLget_logical_window ( WLhwin_no hwin_no , WLuint32 * lwin_no )

                      ;

 extern int WLget_native_info ( WLuint32 lwin_no , WLuint32 context_no , struct WLnative_info * native_info )


                                      ;

 extern int WLget_screen_depth ( WLuint16 lscreen_no , int hilite_used , int * depth )


                ;

 extern int WLget_screen_size ( WLuint16 lscreen_no , int * width , int * height )


                 ;

 extern int WLget_window_screen ( WLuint32 lwin_no , WLuint16 * lscreen_no )

                          ;

 extern int WLbell ( WLuint32 lwin_no , int percent )

                 ;

 extern int WLget_user_data ( WLuint32 lwin_no , void * * exnuc_data , void * * data1 )


                 ;

 extern int WLget_collapse_parms ( WLuint32 lwin_no , int * x , int * y )


           ;

 extern int WLset_user_data ( WLuint32 lwin_no , void * * exnuc_data , void * * data1 )


                 ;

 extern int WLset_collapse_parms ( WLuint32 lwin_no , int x , int y , int collapse_state )



                        ;

 extern int WLpack_rgb_colorref ( WLuint32 red , WLuint32 green , WLuint32 blue , WLcolorref * color_ref , WLuint32 physical )




                      ;

 extern int WLpack_index_colorref ( WLuint32 color_index , WLcolorref * color_ref , WLuint32 physical )


                      ;

 extern int WLmap_colorref ( WLuint32 lwin_no , WLcolorref color_ref , WLuint32 * color_index , WLuint32 * red , WLuint32 * green , WLuint32 * blue , WLuint32 * color_flag )






                         ;

 extern int WLset_window_name ( WLuint32 lwin_no , char * new_name )

                    ;

 extern int WLset_active_symbology ( WLuint32 lwin_no , WLcolorref color_ref , int lstyle_no , WLuint16 blend , int weight , int change_mask )





                     ;

 extern int WLset_clip_box ( WLuint32 lwin_no , WLuint32 context_no , int xmin , int ymin , int width , int height )





               ;

 extern int WLread_cmap_entries ( WLuint32 context_no , int num_entries , struct WLcmap_entry * cmap_entries )


                                       ;

 extern int WLget_number_of_contexts_possible ( WLuint16 lscreen_no , WLuint32 context_no , int * num_possible )


                       ;

 extern int WLget_screen_contexts ( WLuint16 lscreen_no , int base_cmap_type , int hilite_used , int * num_contexts , struct WLcontext_info * * contexts )




                                      ;

 extern int WLset_window_bounds ( WLuint32 lwin_no , struct WLbounds * bounds )

                             ;

 extern int WLget_window_bounds ( WLuint32 lwin_no , struct WLbounds * bounds , struct WLbounds * area_bounds )


                                  ;

 extern int WLget_window_contexts ( WLuint32 lwin_no , int * num_contexts , WLuint32 * * context_no , struct WLcontext_info * * contexts )



                                      ;

 extern int WLget_context_info ( WLuint32 context_no , struct WLcontext_info * context_info )

                                        ;

 extern int WLload_cmap_entries ( WLuint32 context_no , int num_entries , struct WLcmap_entry * cmap_entries )


                                       ;

 extern int WLblock_move ( WLuint32 lwin_no , WLuint32 context_no , int src_x , int src_y , int width , int height , int dest_x , int dest_y )







               ;

 extern int WLclear_window ( WLuint32 lwin_no )
                      ;

 extern int WLdisplay_window ( WLuint32 lwin_no )
                      ;

 extern int WLdraw_2D_line_string ( WLuint32 lwin_no , int npoints , struct WLpoint * points )


                            ;

 extern int WLdraw_2D_point_string ( WLuint32 lwin_no , int npoints , struct WLpoint * points )


                            ;

 extern int WLdraw_polygon ( WLuint32 lwin_no , int num_points , struct WLpoint * points , WLuint32 fill )



                  ;

 extern int WLdraw_rectangle ( WLuint32 lwin_no , struct WLrect * rect , WLuint32 fill )


                  ;

 extern int WLget_defined_style ( int lstyle_no , WLuint16 * pattern )

                       ;

 extern int WLget_raster_data ( WLuint32 lwin_no , WLuint32 context_no , struct WLraster_data * image )


                                ;

 extern int WLhide_cursor ( WLuint32 lwin_no , WLuint32 flag )

                   ;

 extern int WLmouse_position ( WLuint32 lwin_no , int * x , int * y , int * in_window , int * key_buttons )




                                    ;

 extern int WLpop_window_to_top ( WLuint32 lwin_no )
                     ;

 extern int WLpop_window_to_bottom ( WLuint32 lwin_no )
                     ;

 extern int WLput_raster_data ( WLuint32 lwin_no , WLuint32 context_no , struct WLraster_data * image )


                                ;

 extern int WLshow_cursor ( WLuint32 lwin_no )
                      ;

 extern int WLdefine_style ( int lstyle_no , WLuint16 pattern )

                      ;



 extern int WLdefine_cursor ( WLuint32 lwin_no , char * data , char * mask , int length , int width , int lfgcolor , int lbgcolor , int x_hot , int y_hot )








              ;


 extern int WLcreate_raster_data ( WLuint32 win_no , WLuint32 context_no , struct WLraster_data * image , int x , int y , int width , int height , int bits_per_pixel , WLuint32 buffer_type , char * buffer )









                 ;

 extern int WLfree_raster_data ( struct WLraster_data * image )
                                ;

 extern int WLcreate_context_native_info ( WLuint16 lscreen_no , struct WLcontext_info * context , int ( * cmap_color_to_index ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * phy_index ) , int ( * cmap_color_to_rgb ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * out_red , WLuint32 * out_green , WLuint32 * out_blue ) , int ( * cmap_init ) ( WLuint32 context_no ) , struct WLnative_info * native_info , WLuint32 * context_no )
#line 809  "/opt/ingr/exnucdp/include/wl.h"
                         ;

 extern int WLenter_dynamics ( WLuint32 lwin_no )
                     ;

 extern int WLexit_dynamics ( WLuint32 lwin_no )
                     ;

 extern int WLset_event_mask ( WLuint32 lwin_no , WLuint32 event_mask )

                        ;

 extern int WLget_event_mask ( WLuint32 lwin_no , WLuint32 * event_mask )

                         ;

 extern int WLsync_buffers ( WLuint32 lwin_no )
                     ;

 extern int WLenter_db ( WLuint32 lwin_no )
                      ;

 extern int WLexit_db ( WLuint32 lwin_no )
                      ;

 extern int WLdraw_text ( WLuint32 lwin_no , int x , int y , char * text , int length )




                ;

 extern int WLdraw_bitmap ( WLuint32 lwin_no , int x_org , int y_org , int width , int height , unsigned char * bitmap )





                           ;

 extern int WLset_dynamics_drawing_mode ( WLuint32 lwin_no , int mode )

              ;

 extern int WLexit ( void )
          ;

 extern int WLactivate_symbology ( WLuint32 lwin_no , int fill_flag , int force_flag )


                    ;

 extern int WLget_window_base_context ( WLuint32 lwin_no , WLuint32 * base_context_no )

                               ;

 extern int WLchange_context_color_functions ( WLuint32 context_no , int ( * cmap_color_to_index ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * phy_index ) , int ( * cmap_color_to_rgb ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * out_red , WLuint32 * out_green , WLuint32 * out_blue ) , int ( * cmap_init ) ( WLuint32 context_no ) )
#line 886  "/opt/ingr/exnucdp/include/wl.h"
                              ;

 extern int WLclear_hilite ( WLuint32 lwin_no )
                     ;

 extern int WLget_context_color_functions ( WLuint32 context_no , int ( * * cmap_color_to_index ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * phy_index ) , int ( * * cmap_color_to_rgb ) ( WLuint32 context_no , WLuint32 index , WLuint32 red , WLuint32 green , WLuint32 blue , WLuint32 flag , WLuint32 * out_red , WLuint32 * out_green , WLuint32 * out_blue ) , int ( * * cmap_init ) ( WLuint32 context_no ) )
#line 912  "/opt/ingr/exnucdp/include/wl.h"
                              ;

 extern int WLget_context_interaction ( WLuint16 lscreen_no , WLuint32 context_no , struct WLcontext_interaction * * inter )


                                          ;

 extern int WLget_native_info_from_context ( WLuint16 lscreen_no , WLuint32 context_no , struct WLnative_info * native_info )


                                       ;

 extern int WLget_number_of_color_cells ( WLuint32 context_no , int * num_of_cells )

                       ;

 extern int WLget_wm_colors ( WLuint32 context_no , int * num_entries , struct WLcmap_entry * * cmap_entries , int * ingr_num_entries , struct WLcmap_entry * * ingr_entries )




                                        ;

 extern int WLinstall_cmap ( WLuint32 lwin_no , WLuint32 context_no )

                         ;

 extern int WLset_active_screen ( WLuint16 lscreen_no )
                         ;

 extern int WLset_background ( WLuint32 lwin_no , WLcolorref color_ref )

                          ;

 extern int WLset_blendarea ( WLuint32 lwin_no , WLuint8 area_pattern [ 8 ] , int opaque_flag )


                     ;

 extern int WLmouse_win_position ( WLuint32 * lwin_no , int * x , int * y , int * in_window )



                    ;

 extern int WLset_active_SR_window ( WLhwin_no hwin_no )
                            ;

 extern int WLchange_window_screen ( WLuint32 lwin_no , WLuint32 new_context_no , WLuint16 new_lscreen_no , WLuint32 * new_lwin_no )



                           ;

 extern int WLset_drawing_mode ( WLuint32 lwin_no , int mode )

              ;

 extern int WLget_background ( WLuint32 lwin_no , WLcolorref * color_ref )

                           ;

 extern int WLget_screen_type ( WLuint16 lscreen_no , int * screen_type )

                      ;


 extern int WLset_active_font ( WLuint32 lwin_no , WLfont font_id )

                    ;

 extern int WLload_font ( WLuint16 lscreen_no , char * font_name , WLfont * font_id )


                     ;

 extern int WLget_hardware_screen_number ( WLhwin_no hwin_no , int * screen_no )

                    ;

 extern int WLunload_font ( WLuint16 lscreen_no , WLfont font_id )

                    ;

 extern int WLget_hardware_screen_from_logical ( WLuint16 lscreen_no , int * screen_no )

                         ;

 extern int WLis_region_empty ( WLuint32 lwin_no , int x , int y , int pixels , int * region )




                      ;

 extern int WLwindow_bounds_changed ( WLuint32 lwin_no , struct WLbounds * bounds )

                             ;

 extern int WLinit_default_colormap ( WLuint16 lscreen_no )
                         ;

 extern int WLget_default_colormap_entries ( WLuint32 context_no , int start_slot , int num_entries , int * num_valid_entries , struct WLcmap_entry * default_entries )




                                          ;

 extern int WLset_line_style_factor ( int flag )
              ;
#line 40  "/opt/ingr/exnucdp/include/exproto.h"
 extern int EX_load_button ( long * msg , char * filename )                              ;


 extern int EX_fork ( int num_entry , char * argu [ ] , int wait_flag , int redir_io , int * childpid , int mask , char * np1 , char * np2 , int delete_flag )                                                                                                                             ;


 extern int close_visible ( int save_flag , OM_S_OBJID my_id )                                    ;
 extern int EX_execute_mod ( void )         ;
 extern int EX_start_cmdserver ( int init , int exec )                       ;
 extern int EX_save_backup_file ( char * file_name )                    ;
 extern int EX_stop_auto_backup ( void )         ;
 extern int EX_context_switch_to ( char * exec_name )                    ;
 extern int EX_context_switch_1 ( char * exec_name )                    ;
 extern int EX_set_logo ( char * logo )               ;
 extern int EX_get_mloc_file ( char * file_name , int * have_file )                                    ;
 extern int EX_exit_function ( int ( * function_to_execute ) ( ) , int ( * * function_previous ) ( ) )                                                                ;



 extern int EX_findmod ( OM_S_OBJID * objid , uword * osnum )                                    ;
 extern int EX_get_exec_id ( OM_S_OBJID * objid , uword * osnum )                                    ;
 extern int EX_conv_pnt ( int window , struct EX_button * pnt1 , int * response )                                                      ;
 extern int EX_get_win_class ( int hw_win_no , char * class_name )                                    ;




 extern int EX_trans_win ( unsigned int hw_win , WLuint32 * lwin , OMuword * win_os , OM_S_OBJID * win_oid )
                                                                 ;

 extern int EX_add_win ( int hw_win_no , OM_S_OBJID objid , OMuword osnum )                                                   ;
 extern int EX_set_abs_dig ( int fm )           ;
 extern int EX_clear_abs_dig ( void )         ;
 extern int EX_wait_for_input ( int * response , char * response_data , int mode , int * num_bytes )                                                                 ;
 extern int EX_attach_listener ( OM_S_OBJID objid , OMuword osnum )                                    ;
 extern int EX_detach_listener ( OM_S_OBJID objid , OMuword osnum )                                    ;
 extern int EX_attach_generator ( OM_S_OBJID objid , OMuword osnum )                                    ;
 extern int EX_detach_generator ( OM_S_OBJID objid , OMuword osnum )                                    ;
 extern int EX_get_NOD ( char * NODname , OM_S_OBJID * pobjid , int create , OM_S_OBJID modid , OMuword mosnum )                                                                                    ;
 extern int EX_get_oid_nodname ( char * NODname , char * objname , OM_S_OBJID * pobjid , OM_S_OBJID modid , OMuword mosnum , int errprint )                                                                                                     ;
 extern int EX_add_name_nodname ( char * NODname , char * objname , OM_S_OBJID objid , OMuword mosnum )                                                                   ;
 extern int EX_remove_name_nodname ( char * NODname , char * objname , OMuword mosnum )                                                 ;
 extern int EX_get_oid_nodid ( OM_S_OBJID NODobjid , char * objname , OM_S_OBJID * pobjid , OM_S_OBJID modid , OMuword mosnum )                                                                                             ;
 extern int EX_add_name_nodid ( OM_S_OBJID NODobjid , char * objname , OM_S_OBJID objid , OMuword mosnum )                                                                         ;
 extern int EX_remove_name_nodid ( OM_S_OBJID NODobjid , char * objname , OMuword mosnum )                                                       ;
 extern int EX_attach_super ( IGRchar * super_class , OM_S_OBJID * super_id , OM_S_OBJID module_id , OMuword module_os , int wakeup_flag )
                                                                        ;
 extern int EX_get_global ( IGRint mode , struct EX_var_list * var , IGRint * which_error )                                                              ;
 extern int EX_inq_global ( struct EX_var_list * var , IGRint * which_error )                                                 ;
 extern int EX_set_global ( struct EX_var_list * var , IGRint * which_error )                                                 ;
 extern int EX_file_status ( OM_S_OBJID modid , uword modos , int * mode )                                             ;
 extern int EX_get_invis_info_by_index ( int index , OMuword * mod_osnum , OM_S_OBJID * mod_id , OM_S_OBJID * filed_id , int * flag , int * num_open , int * mod_type )                                                                                                                     ;
 extern int EX_is_visible ( char * mod_name )                   ;
 extern int EX_is_invis ( OMuword mod_osnum , int * index )                                  ;
 extern int EX_is_driver_exist ( void )         ;
 extern void EX_set_mod_no_scn_menu ( OMuword mod_osnum )                      ;
 extern int EX_is_scn_menu_present ( void )         ;
 extern void EX_print_module_table ( void )         ;
 extern int EX_get_modid_given_osnum ( OMuword mod_osnum , OM_S_OBJID * mod_id )                                          ;
 extern int EX_get_super ( OM_S_OBJID mod_id , OMuword mod_osnum , char * super_name , int create , char * super_classname , OM_S_OBJID * super_id , OMuword * super_osnum , int wakeup_flag )


                                            ;
 extern int EX_mod_info ( OMuword mod_osnum , int mode , char * app , int applen )                                                       ;
 extern int EX_is_help_active ( void )         ;
 extern int EX_help_flag ( int mode , int * flag )                        ;
 extern int EX_help_on ( int * oldflag )                 ;
 extern int EX_help_off ( int * oldflag )                 ;
 extern int EX_disp_flag ( int mode , int * flag )                        ;
 extern int EX_disp_on ( int * oldflag )                 ;
 extern int EX_disp_off ( int * oldflag )                 ;
 extern int EX_is_file_open ( char * filename )                   ;
 extern int EX_get_file_path ( char * env , char * string , char * outfile , int * ftype , int size )                                                                 ;
 extern int EX_check_input ( void )         ;
 extern int EX_check_input ( void )         ;
 extern int EX_set_up_file ( char * filename , char * seedfile , char * firstcmd , int * create )                                                                ;
 extern int EX_get_file_default ( char * filename , char * seedfile , char * firstcmd , int * create )                                                                ;
 extern int EX_call_firstcmd ( void )         ;
 extern int EX_firstcmd_putque ( char * field , int type )                          ;
 extern int EX_build_classlist ( char * classnames [ ] , int size , OM_p_CLASSLIST p_clist )                                                         ;
 extern int EX_get_working_dir ( char * name , int * len )                         ;
 extern int EX_get_support_dir ( char * name , int * len )                         ;



 extern int EX_cmdgetptr ( char * instring , char * * outstring )                                     ;
 extern int EX_cmdfreeptr ( void )         ;


 extern void EX_interrupt_hup ( int signo )              ;
 extern void EX_interrupt_int ( int signo )              ;
 extern void EX_interrupt_quit ( int signo )              ;
 extern void EX_interrupt_iot ( int signo )              ;
 extern void EX_interrupt_emt ( int signo )              ;
 extern void EX_interrupt_fpe ( int signo )              ;
 extern void EX_interrupt_ill ( int signo )              ;
 extern void EX_interrupt_bus ( int signo )              ;
 extern void EX_interrupt_segv ( int signo )              ;
 extern void EX_interrupt_sys ( int signo )              ;
 extern void EX_interrupt_pipe ( int signo )              ;
 extern void EX_interrupt_term ( int signo )              ;


 extern int EX_init_rec_echo ( char * filename )                   ;
 extern int EX_init_record ( char * filename )                   ;
 extern int EX_init_echo ( char * filename )                   ;
 extern int EX_close_rec_echo ( int flag )             ;
 extern int EX_clear_jnl_on_save ( void )         ;
 extern int EX_store_window_on_save ( void )         ;
 extern int EX_clear_command_on_save ( void )         ;
 extern int EX_restart_journal ( void )         ;


 extern int EX_mem_exist ( void )         ;
 extern int EX_add_mem ( char * mem_name , unsigned long int mem_val )                                              ;
 extern int EX_get_mem ( char * mem_name , unsigned long int * mem_val )                                               ;
 extern int EX_del_mem ( char * mem_name )                   ;
 extern void EX_print_mem ( void )         ;
 extern void EX_free_mem ( void )         ;


 extern int EX_mv ( char * source , char * target )                               ;
 extern int EX_cp ( char * source , char * target )                               ;
 extern int EX_rm ( char * file1 )                ;


 extern void EX_add_fun ( struct EX_funnode * * phead , int isfunc , void * f )                                                    ;
 extern void EX_del_fun ( struct EX_funnode * * phead , int ( * f ) ( ) )                                          ;
 extern void EX_empty_fun ( struct EX_funnode * * phead )                              ;
 extern void EX_print_fun ( struct EX_funnode * * phead )                              ;
 extern int EX_add_function ( int ( * fun ) ( ) , int mode )                            ;
 extern int EX_del_function ( int ( * fun ) ( ) , int mode )                            ;
 extern int EX_call_start_func ( void )         ;
 extern int EX_call_end_func ( void )         ;
 extern int EX_add_cmdserver_function ( int ( * fun ) ( ) )                  ;
 extern int EX_del_cmdserver_function ( int ( * fun ) ( ) )                  ;
 extern int EX_call_cmdserver_func ( int mode )             ;
 extern char * EX_get_and_del_first_fun ( struct EX_funnode * * phead )                              ;





 extern int EX_record_new_window ( Window window )                  ;

 extern int EX_dyn_process_input_event ( int mask )             ;
 extern int EX_wait_for_next ( int mask , int * event )                         ;
 extern int EX_inq_events ( int * event )               ;
 extern int EX_inq_button_data ( int * window , int * x , int * y , int * btype , int * state , int * timetag )                                                                      ;
 extern int EX_get_button_data ( int * window , int * x , int * y , int * btype , int * state , int * timetag )                                                                      ;
 extern int EX_get_refresh_area_data ( int * window , int * vs_no , int * x , int * y , int * x2 , int * y2 , int * ax1 , int * ay1 , int * ax2 , int * ay2 , int * opmask )                                                                                                                   ;
 extern int EX_inq_refresh_area_data ( int * window , int * vs_no , int * x , int * y , int * x2 , int * y2 , int * ax1 , int * ay1 , int * ax2 , int * ay2 , int * opmask )                                                                                                                   ;
 extern int EX_get_collapse_data ( int * window , int * opmask )                             ;
 extern int EX_inq_collapse_data ( int * window , int * opmask )                             ;
 extern int EX_get_delete_data ( int * window )                ;
 extern int EX_inq_delete_data ( int * window )                ;
 extern int EX_set_keyboard_buffer ( char * buffer , int count )                            ;
 extern int EX_get_keyboard_data ( int * count )               ;
 extern int EX_inq_keyboard_data ( int * count )               ;
 extern int EX_dyn_process_input_event ( int mask )             ;


 extern int backup_filenames ( int mod_num , char * nfile , char * file )                                         ;
 extern int module_backup ( OM_S_OBJID my_id )                     ;
 extern int remove_backup ( char * file )               ;


 extern int file_exists ( char * fname , char * env , char * path_dir , char * ret_fname )                                                            ;
 extern int filetest ( void )         ;
 extern int EX_check_file ( char * filename , int print_flag )                                   ;
 extern int EX_is_reg_file ( char * filename )                   ;




 extern void IGEExit ( int status )               ;
 extern int IGE_startup ( int argc , char * argv [ ] , int mode )                                     ;

 extern int IGEEnter ( int argc , char * argv [ ] )                           ;



 extern void EX_set_sync ( void )         ;
 extern void EX_sync_on ( void )         ;
 extern void EX_sync_off ( void )         ;
 extern int EX_is_batch ( void )         ;
 extern int EX_is_interactive ( void )         ;
 extern void EX_clear_timing ( void )         ;
 extern void EX_start_timing ( void )         ;
 extern void EX_end_timing ( char * string )                 ;
 extern void EX_print_timing ( void )         ;







 extern int get_modtype_data  ( char * run_name , char * logo_ptr , char * module_class , char * srch_path , char * config_path , char * product_path )




                                                     ;
 extern int Retrieve_OS ( char * in_filename , int flags , int * file_no , int type , int * msg , char * mount_name )                                                                                     ;
 extern int Retrieve_new_OS ( char * in_filename , int flags , int mod_type , int * file_no , int type , int * msg , char * mount_name )                                                                                                   ;
 extern int Close_OS ( int mod_num , int flag )                          ;
 extern int Save_OS ( int mod_num )                ;
 extern int Save_As_OS ( int mod_num , char * filename )                                ;
 extern int EX_retrieve_os ( char * in_filename , int flag , int mod_type , int * file_no , int f_stat , int type , int * msg , char * mount_name )                                                                                                              ;
 extern int print_invis ( void )         ;
#line 303  "/opt/ingr/exnucdp/include/exproto.h"
 extern int JNL_init_journal ( char * filename , int excl_flag )                                  ;
 extern int JNL_init_playback ( char * filename , char * runname )                                  ;
 extern int JNL_XPending ( Display * display )                     ;
 extern int JNL_save_panel ( void )         ;
 extern int JNL_playback ( void )         ;
 extern int JNL_journal ( void )         ;
 extern int JNL_XCreateWindow ( Display * display , Window parent , int x , int y , unsigned int width , unsigned int height , unsigned int border_width , int depth , unsigned int class , Visual * visual , unsigned long valuemask , XSetWindowAttributes * attributes )                                                                                                                                                                                                                                ;
 extern int JNL_record_runtime_forms ( void )         ;
 extern int JNL_record_new_window ( Window window )                  ;
 extern int JNL_XWithdrawWindow ( Display * display , Window w , int screen_no )                                              ;
 extern int JNL_XUnmapWindow ( Display * display , Window w )                               ;
 extern int JNL_XMapWindow ( Display * display , Window w )                               ;
 extern int JNL_XMapRaised ( Display * display , Window w )                               ;
 extern int JNL_XNextEvent ( Display * display , XEvent * xevent )                                     ;



 extern void JNL_XtAppNextEvent ( )     ;

 extern int JNL_XGrabPointer ( Display * display , Window grab_window , int owner_events , unsigned int event_mask , int pointer_mode , int keyboard_mode , Window confine_to , Cursor cursor , Time time )                                                                                                                                                                       ;
 extern int JNL_XUngrabPointer ( Display * display , Time time )                                ;
 extern int JNL_XCheckTypedEvent ( Display * display , int event_type , XEvent * xevent )                                                     ;
 extern int JNL_XCheckTypedWindowEvent ( Display * display , Window w , int event_type , XEvent * xevent )                                                               ;
 extern int JNL_XCheckMaskEvent ( Display * display , long event_mask , XEvent * xevent )                                                      ;
 extern int JNL_XCheckWindowEvent ( Display * display , Window w , long event_mask , XEvent * xevent )                                                                ;
 extern int JNL_XWindowEvent ( Display * display , Window w , long event_mask , XEvent * xevent )                                                                ;
 extern int JNL_XMaskEvent ( Display * display , long event_mask , XEvent * xevent )                                                      ;
 extern int JNL_XCheckIfEvent ( Display * display , XEvent * xevent , int ( * predicate ) ( ) , char * arg )                                                                      ;
 extern int JNL_XPeekIfEvent ( Display * display , XEvent * xevent , int ( * predicate ) ( ) , char * arg )                                                                      ;
 extern int JNL_XIfEvent ( Display * display , XEvent * xevent , int ( * predicate ) ( ) , char * arg )                                                                      ;
 extern int JNL_clear_windows ( void )         ;
 extern int JNL_read_next_event ( XEvent * xevent )                   ;
 extern int JNL_record_next_event ( XEvent * xevent , int record_flag )                                    ;
 extern int JNL_XPeekEvent ( Display * display , XEvent * xevent )                                     ;
 extern int JNL_peek_next_event ( XEvent * xevent )                   ;
 extern int JNL_XPutBackEvent ( Display * display , XEvent * xevent )                                     ;
 extern int JNL_read_button_count ( int * count )               ;
 extern int JNL_record_info_event ( int type , int event_nbytes , char string [ ] )                                              ;
 extern int JNL_if_read_button_count ( int * count , XEvent * xevent )                               ;
 extern int JNL_close_jnl ( void )         ;
 extern int JNL_close_jnl_pbk ( void )         ;
 extern int JNL_close_echo ( void )         ;
 extern int JNL_record_input ( int nbytes , char * buffer )                             ;
 extern int JNL_echo_input ( int nbytes , char * buffer )                             ;
 extern int JNL_oldwindow_to_window ( XEvent * xevent )                   ;
 extern int JNL_process_slow_echo ( void )         ;



 extern int module_build_path ( char * path_name )                    ;
 extern int module_set_pathname ( char * string )                 ;
 extern int module_set_def_dir ( void )         ;
 extern int fix_directory ( char * string )                 ;
 extern int module_get_def_dir ( int argc , char * argv [ ] )                           ;
 extern int valid_filename ( char * str , char * path )                          ;
 extern int EX_check_stat ( char * path , int * ftype )                           ;
 extern int EX_use_default_dir ( void )         ;
 extern int EX_get_executable_path ( char * path )               ;
 extern int EX_get_user_srch_path ( char * path )               ;


 extern int EX_set_srch_path ( void )         ;
 extern int EX_get_srch_path1 ( char * runname , int flag , char * buff , int * size )                                                   ;
 extern int EX_getpath ( int index , char * path , int len , int type )                                             ;
 extern int EX_get_srch_path ( char * * path , int * num_entry )                                ;
 extern int EX_set_search_path ( char * path )               ;
 extern int EX_restore_search_path ( void )         ;


 extern int EX_is_cmd_stack_empty ( void )         ;
 extern int EX_set_cmdserver_debug ( void )         ;
 extern int EX_help_init ( void )         ;
 extern int EX_blank_msg ( void )         ;
 extern int EX_ci_test_start ( char * filename )                   ;
 extern int EX_ci_test_end ( void )         ;
 extern int EX_set_auto_jump ( void )         ;
 extern int EX_jump ( void )         ;
 extern int EX_is_auto_jump ( void )         ;
 extern int EX_is_auto_test ( void )         ;
 extern int EX_auto_test_print_err ( int signo )              ;
 extern int EX_cmdserver_save_last_cmd ( void )         ;


 extern int EX_print_cmd ( char * file_name )                    ;
 extern int EX_dload_setup ( char * dload_name_ptr , char * * * argv_ptr , int * argc_ptr )                                                          ;
 extern int EX_dload_free ( void )         ;



 extern IGRint EX_cmddetach ( IGRlong * msg , IGRlong module_type )                                      ;



 extern void EX_push_quiet ( int respon )               ;
 extern void EX_pop_quiet ( void )         ;
 extern void EX_swap_quiet ( void )         ;
 extern void EX_clear_quiet ( void )         ;
 extern void EX_print_quiet ( void )         ;


 extern int CSclear_cache ( void )         ;
 extern int CSadd_to_cache ( char * name , int indx )                         ;
 extern int CSget_from_cache ( char * name , int * p_indx )                            ;
 extern int CSdump_cache ( void )         ;



 extern int EX_cmdstrip ( unsigned char * keyin )                         ;


 extern int UI_error ( char * msg )              ;


 extern int EX_get_keyin ( int * response , char * response_data , int mode )                                                 ;
 extern int EX_keyin_no_cmd ( int * response , char * response_data , int mode )                                                 ;
 extern int EX_get_input ( int * response , char * response_data , int mode )                                                 ;



 extern void UI_message ( char * symstr )                 ;
 extern void UI_status ( char * symstr )                 ;
 extern void UI_prompt ( char * symstr )                 ;
 extern void UI_echo ( char * symstr )                 ;


 extern int special_keyin ( int * response , char * response_data )                                       ;


 extern IGRint EXgetq ( IGRlong * return_code , int * response , IGRint * bytes_returned , IGRchar * buffer )                                                                                 ;
 extern IGRint EXputq ( IGRlong * msg , IGRlong position , int * response , IGRlong * byte_count , IGRchar * buffer )                                                                                        ;
 extern IGRint EXputq2 ( IGRlong * msg , IGRlong position , int * response , IGRlong * byte_count , IGRchar * buffer , IGRint mode )                                                                                                     ;
 extern IGRint EXputq_back ( IGRlong * msg , int * response , IGRlong * byte_count , IGRchar * buffer )                                                                      ;
 extern IGRint EXputq_front ( IGRlong * msg , int * response , IGRlong * byte_count , IGRchar * buffer )                                                                      ;
 extern int print_queue ( void )         ;
 extern int EX_flush_event_queue ( void )         ;
 extern int EX_peek_event_queue ( int * resp )              ;


 extern void EX_start_copyright ( void )         ;
 extern int EX_end_copyright ( void )         ;





 extern int EXget_form_decoration ( int * xdecor , int * ydecor )                             ;
 extern int EXget_form_offset ( int * xoffset , int * yoffset )                               ;



 extern int EX_extract_string ( void )         ;
 extern int EX_clean_str ( char * x , int no_space , int lower )                                     ;


 extern void UI_message ( char * symstr )                 ;
 extern void UI_status ( char * symstr )                 ;
 extern void UI_prompt ( char * symstr )                 ;
 extern void UI_echo ( char * symstr )                 ;


 extern int EX_get_keyin ( int * response , char * response_data , int mode )                                                 ;
 extern int EX_keyin_no_cmd ( int * response , char * response_data , int mode )                                                 ;
 extern int EX_get_input ( int * response , char * response_data , int mode )                                                 ;


 extern int EX_init_keyboard ( void )         ;
 extern IGRint EX_load_funckey ( int type , IGRchar * file_name )                                 ;
 extern int EX_update_funcky ( IGRchar * keynam , IGRint response , IGRshort waitf , IGRchar * key_str )                                                                       ;
 extern int pad_escape ( char * buffer , char * outbuffer )                                  ;
 extern int strip_esc_key ( char * response_data )                        ;
 extern int EX_keybd_process_return ( char * response_data , int num_char )                                      ;
 extern int EX_clear_keyin ( void )         ;
 extern int EX_clear_keyin ( void )         ;
 extern int EX_is_logkbd_inactive ( void )         ;
 extern int EX_cut_calc_input ( void )         ;
 extern int EX_paste_calc_input ( void )         ;


 extern int EX_module_construct ( int * msg , uword os_num , OM_S_OBJID filed_id , int new_module , int read_only , int activate , OM_S_OBJID * mod_id )                                                                                                                 ;
 extern int EX_get_seed_file ( char * seedfile , char * temp_file )                                    ;
 extern int EX_retrieve_module ( int * msg , char * inputstring , char * seedfile , int create , int activate , int save , OMuword * osnum , OM_S_OBJID * modid )                                                                                                                       ;
 extern int EX_retrieve_function ( int ( * function_to_execute ) ( ) , int ( * * function_previous ) ( ) )                                                                ;


 extern int EXupdatable_exist ( void )         ;


 extern int EX_save_module ( int active_module_num , int flag )                                     ;


 extern int EX_is_temp_wakeup ( void )         ;
 extern void EX_init_session ( void )         ;


 extern int EX_close1 ( int * last , int flag )                        ;
 extern int EX_create_prompt ( int message_number , int left_prompt_number , int right_prompt_number , char * string , int * response , char * response_data )

                                     ;
 extern void EX_exit1 ( int save )             ;
 extern int EX_filename1 ( char * result , int len )                          ;
 extern int EX_get_cmd_info ( char * string , int mode , struct EX_cmd * cmdstr )                                                  ;
 extern int EX_save1 ( char * fname )                ;
 extern int EX_saveas1 ( char * string )                 ;
 extern int EXget_file ( char * title , char * startdir , char * in_file , char * pat , int file_type [ ] , char * returned_filename , char * seedfile , int form_type , int * response , char * response_data )


                                     ;
 extern int EX_get_prod_info ( char * product , int code , char * * pstring )                                            ;
 extern int EX_get_prod_flag ( char * logo , int code , int flag )                                   ;
 extern int EX_get_prod_data ( char * runnameIn , char * logoIn , char * runnameOut , char * logoOut , char * module , char * dependency , char * configPath , char * prodPath , int * flags )


                            ;
#line 19  "/opt/ingr/grnucdp/include/grio.h"
    typedef   IGRchar   GRIOalias_name [ ( 24 )                  ] ;




    struct GRIOalias_entry
    {
       GRIOalias_name alias ;
       IGRshort   index ;
    } ;

    struct GRIOgnunit_definition
    {
       IGRdouble  num_parent_units ;
       IGRdouble  working_units ;
       IGRshort   parent_index ;
    } ;

    struct GRIOvar_def
    {
   IGRshort type ;
   union
    {
     IGRdouble fvalue ;
     IGRint    ivalue ;
     IGRchar   string [ 40 ] ;
                IGRpoint  point ;
    } contents ;
    } ;

    struct GRIOreadout_spec
    {
     IGRshort   justification ;

     IGRshort   mode ;

        IGRshort   precision ;

        IGRshort   denominator ;

        IGRshort   case_type ;
     IGRboolean leading_zeros ;
     IGRboolean trailing_zeros ;
     IGRshort   decimal_char ;
     IGRshort   thousands_char ;

     IGRshort   intermeas_spacing ;




     IGRshort   intrameas_spacing ;




     IGRchar    left_fill_char ;
     IGRboolean alias_displayed ;
    } ;









    enum  GRlocate_action
    {   add_all ,
 add_inside ,
 add_outside ,
 add_overlap ,
        end_transition ,
 start_transition ,
 post_object ,
 check_object ,
 add_nopost
    } ;




    struct GRlc_info
    {
       struct  GRid             located_obj ;
       struct  GRmd_env         module_info ;
               IGRpoint         proj_pnt ;
       struct  GRparms          geom_parms ;
    } ;




    struct GRevent
    {
        IGRint response ;
        IGRint nbytes ;
        union
        {
            struct EX_button        button ;
                   IGRchar          keyin [ 100        ] ;
                   IGRdouble        value ;
        } event ;

        IGRint      subtype ;
        IGRshort    num_id ;
        IGRshort    num_val ;
        IGRdouble   values [ 2 ] ;
        struct GRlc_info        located_object [ 2 ] ;
    } ;

    struct GRspecified_obj
    {
       struct GRid          objid ;
       struct GRmd_env      md_env ;
       struct GRid          window_id ;
    } ;




    struct GR_vsd
    {
       IGRlong start ;
       IGRlong end_ptr ;
       IGRchar delimiter ;
       IGRchar field_delimiter ;
       IGRlong buffer_size ;
       IGRchar buffer [ ( 100 )           ] ;
    } ;

    struct GR_token
    {
       IGRlong type ;
       IGRchar data [ 80            ] ;
    } ;






    struct CO_soft_event
    {
       union
       {
          struct EX_button  button ;
                 IGRchar    keyin [ 100        ] ;
                 IGRdouble  value ;
       } event ;

       IGRint  subtype ;
    } ;
#line 31  "/opt/ingr/grnucdp/include/grdpb.h"
 struct GRunit_lock
 {
    IGRboolean on_off ;
    IGRdouble round_off ;
 } ;

 struct Patrn_area_deltas
 {
    IGRdouble x ;
    IGRdouble y ;
 } ;

 struct GRdpb_text_symb
 {
    IGRshort Active_font ;
    IGRshort Active_fraction_font ;
    IGRshort Active_symbol_font ;
    IGRshort    Active_ascii_font ;
    IGRshort Active_just ;
    IGRdouble Active_width ;
    IGRdouble Active_height ;
    IGRdouble Active_charspac ;
    IGRdouble Active_linespac ;
    IGRshort    Active_flags ;
 } ;

 struct GRdpb_scale
 {
    IGRdouble Active_xscale ;
    IGRdouble Active_yscale ;
    IGRdouble Active_zscale ;
 } ;

 struct GRrgdpb
 {
    IGRshort attr_num ;
    IGRboolean auto_def ;


    IGRboolean auto_init ;




    IGRshort rg_props ;
    IGRdouble row_scale ;

    IGRdouble column_scale ;

    IGRlong comprast_memory ;

    IGRint brush_type ;
    IGRshort fg ;
    IGRshort bg ;
    IGRboolean fill_mode ;
 } ;

 struct GRhesym
 {
    IGRushort color ;
    IGRuchar weight ;
    IGRuchar style ;
    IGRushort flags ;
 } ;

 struct GRdpbdata
 {
    IGRshort version ;
    IGRchar dbtype [ 3               ] ;
    IGRchar model_mode ;
    IGRchar proj_angle ;
    IGRchar cstype [ 24         ] ;
    IGRshort bflags ;
    IGRshort name_mode ;
    IGRshort layer ;
    IGRshort objprops ;
    IGRlong locate_layers [ 32 ] ;
    IGRlong hidsurfsym ;
    IGRlong locprops ;
    IGRdouble epdelta ;
    IGRdouble apdelta [ 2 ] ;
    IGRdouble angle ;
    IGRdouble dit_tol ;
    IGRdouble cht ;
    IGRdouble offset_tol ;
    IGRdouble arc_tol ;
    IGRdouble bastol ;
    IGRdouble maxstep ;
    IGRdouble xhatch_spacing ;
    IGRdouble xhatch_angle ;
    IGRdouble scale [ 3 ] ;
    struct GRdpb_text_symb textsym ;
    struct EX_button lastpoint ;
    struct GRmd_env module ;
    struct GRrgdpb raster ;
    struct GRunit_lock unit_lock ;
    struct IGRdisplay display ;
    struct GRhesym hesym ;
    struct GRhesym visible_edge_sym ;
    int SmartSketchOn ;
    int EligibleConstraints ;
 } ;
#line 143  "/opt/ingr/grnucdp/include/grdpb.h"
 struct GRdpbdata0
 {
    IGRshort version ;
    IGRchar dbtype [ 3               ] ;
    IGRchar model_mode ;
    IGRchar proj_angle ;
    IGRchar cstype [ 24         ] ;
    IGRshort bflags ;
    IGRshort name_mode ;
    IGRshort layer ;
    IGRshort objprops ;
    IGRlong locate_layers [ 32 ] ;
    IGRlong hidsurfsym ;
    IGRlong locprops ;
    IGRdouble epdelta ;
    IGRdouble apdelta [ 2 ] ;
    IGRdouble angle ;
    IGRdouble dit_tol ;
    IGRdouble cht ;
    IGRdouble offset_tol ;
    IGRdouble arc_tol ;
    IGRdouble bastol ;
    IGRdouble maxstep ;
    IGRdouble xhatch_spacing ;
    IGRdouble xhatch_angle ;
    IGRdouble scale [ 3 ] ;
    struct GRdpb_text_symb textsym ;
    struct EX_button lastpoint ;
    struct GRmd_env module ;
    struct GRrgdpb raster ;
    struct GRunit_lock unit_lock ;
    struct IGRdisplay display ;
    struct GRhesym hesym ;
 } ;

 struct GRdpbdata1
 {
    IGRshort version ;
    IGRchar dbtype [ 3               ] ;
    IGRchar model_mode ;
    IGRchar proj_angle ;
    IGRchar cstype [ 24         ] ;
    IGRshort bflags ;
    IGRshort name_mode ;
    IGRshort layer ;
    IGRshort objprops ;
    IGRlong locate_layers [ 32 ] ;
    IGRlong hidsurfsym ;
    IGRlong locprops ;
    IGRdouble epdelta ;
    IGRdouble apdelta [ 2 ] ;
    IGRdouble angle ;
    IGRdouble dit_tol ;
    IGRdouble cht ;
    IGRdouble offset_tol ;
    IGRdouble arc_tol ;
    IGRdouble bastol ;
    IGRdouble maxstep ;
    IGRdouble xhatch_spacing ;
    IGRdouble xhatch_angle ;
    IGRdouble scale [ 3 ] ;
    struct GRdpb_text_symb textsym ;
    struct EX_button lastpoint ;
    struct GRmd_env module ;
    struct GRrgdpb raster ;
    struct GRunit_lock unit_lock ;
    struct IGRdisplay display ;
    struct GRhesym hesym ;
    struct GRhesym visible_edge_sym ;
 } ;

 struct GRdpb_notify
 {
    IGRint parameter ;
    IGRchar * value ;
 } ;

 struct GRelclass
 {
    IGRchar ascii_key [ 16 ] ;
    IGRshort properties ;
    IGRshort depth ;
    IGRint index ;
    OM_S_CLASSLIST classlist ;
 } ;

 struct GRelclass_f


 {
    IGRchar ascii_key [ 16 ] ;
    IGRshort properties ;
    IGRshort depth ;
 } ;

 struct GRelclass_a
 {
    IGRchar * ascii_key ;
    IGRchar * owner_key ;
    IGRshort properties ;
    OM_S_CLASSLIST * classlist ;
 } ;
#line 52  "/opt/ingr/grnucdp/include/EMSdpb.h"
 struct EMdpbinfo
 {
  unsigned char       u_order ;
  unsigned char       v_order ;
  unsigned char       u_rules ;
  unsigned char       v_rules ;
  unsigned char       props ;
#line 76  "/opt/ingr/grnucdp/include/EMSdpb.h"
 } ;
#line 76  "/export/home/isdp/isdp263_08/vds/include/parametric.h"
 struct ref_data {
                 IGRmatrix t ;
   IGRint last_t ;
                } ;


 struct debug_data {
                    IGRint value , mark_id , state ;
                  } ;

 struct point_data {
                    IGRpoint pt ;
                  } ;

 struct circle_data {
                     IGRpoint cent_p ;
                     IGRdouble start_angle , sweep_angle ;
                     IGRdouble rad ;
                     IGRmatrix mat ;
                   } ;

 struct line_data {
                   IGRpoint p0 , p1 , v0 ;
                 } ;

 struct root_parameter_data {
                             IGRdouble  value ;
                           } ;


 struct macro_data {
                    char name [ 20 ] ;
                    int  hdr_type ;
                  } ;


 struct text_data {
    IGRchar text_string [ 80 ] ;
   } ;


 struct lbs_data {
   IGRdouble matrix [ 16 ] ;
   IGRdouble diag_pt1 [ 3 ] , diag_pt2 [ 3 ] ;
         } ;

 struct class_data {
     IGRchar name [ 80 ] ;
    } ;



 struct ret_struct {
                 IGRint type                            ;

                 union {
    int junk [ 44 ] ;
                         struct debug_data dbg_st ;
                         struct circle_data circle_st ;
                         struct line_data line_st ;
                         struct point_data point_st ;
                         struct root_parameter_data root_pm_st ;
                         struct ref_data ref_st ;
                         struct text_data text_st ;
    struct macro_data macro_st ;
    struct lbs_data lb_st ;
    struct class_data class_st ;
                       } var ;
               } ;




 struct GRas
 {
  OMuint num_parents ;
  struct GRid * parents ;
  struct GRid * context ;

  IGRchar * as_attr ;
  IGRchar * go_attr ;
  struct GRid go_objid ;
  struct GRid my_context ;
 } ;
#line 20  "/opt/ingr/grnucdp/include/ACrg_collect.h"
 struct att_value
 {

 IGRshort type ;
 union
 {

  IGRchar  att_txt [ 80       ] ;
  IGRdouble att_exp ;
 } value ;
 } ;


 struct ACrg_coll
 {

 IGRchar   name [ 80      ] ;
 struct att_value desc ;
 } ;
#line 10  "/opt/ingr/exnucdp/include/exms.h"
 struct MS_sd_msg
 {
    IGRint no_args ;
    IGRlong no_msg ;
    IGRchar     msgname [ 81 ] ;
    IGRchar u_type [ 81 ] ;
    IGRchar for_type [ 81 ] ;
    IGRchar  in_msg [ 512               ] ;
    IGRchar  variables [ 256 ] ;
    IGRchar out_msg [ 512               ] ;
 } ;
#line 22  "/opt/ingr/exnucdp/include/msmacros.h"
 extern void MS_format_message ( struct MS_sd_msg * MS_msg )                             ;

 extern int MS_init ( struct MS_sd_msg * MS_msg , IGRlong msgnumb , IGRchar * msgname , IGRchar * in_buff , IGRint field , IGRint justification )

                                                           ;
 extern int MSget_message ( long msgnumber , char * * buffer , int * nbytes )                                             ;
 extern int EX_create_prompt ( int message_number , int left_prompt_number , int right_prompt_number , char * string , int * response , char * response_data )

                       ;
 extern void MS_file_init ( IGRchar * message_file , IGRchar * msg_file )                                             ;
 extern void MS_fix_type ( struct MS_sd_msg * MS_msg , IGRchar * type )                                            ;
 extern void MS_function ( IGRint status , IGRint ( * function ) ( ) )                                         ;
 extern int MS_onoff ( IGRlong * msg , IGRshort * previous_state , IGRshort new_state , IGRint type )
                                   ;
 extern int MS_out_msg ( struct MS_sd_msg * MS_msg , IGRchar * buff , IGRint field , IGRint justification , IGRint delay_time , IGRint seconds , IGRint buffer_size )

                                     ;
 extern int MSmessage ( IGRint field , IGRlong msgnumb , IGRchar * msgname , IGRint justification , IGRchar * buff , IGRchar * type , IGRchar * var , IGRchar * in_buff , IGRint delay_time , IGRint seconds , IGRint buffer_size )


                                     ;

 extern int MS_return_sizeof_message ( IGRlong msgnumb , IGRchar * msgname , IGRint * nbytes )
                  ;



 extern int MS_retrieve_msg ( struct MS_sd_msg * MS_msg )                             ;


 extern int MS_display_message ( IGRint field , IGRint justification , IGRchar * string , struct MS_sd_msg * MS_msg , IGRint delay_time , int seconds )                                                                                                                  ;
 extern int MSgetfont ( void )         ;
 extern int MS_update_msg_strip ( int field_no , int just , char * string )                                         ;
 extern int MSerrbox ( IGRint field , IGRint justification , IGRchar * string , struct MS_sd_msg * MS_msg )
                                                                     ;
 extern int EX_error_box ( int screen_no , char * msg , char * title )                                          ;
 extern int MS_paint_area ( void )         ;
#line 18  "/opt/ingr/bspmathdp/include/bstypes.h"
 typedef IGRdouble BSpoly [ 16       ] [ 4 ] ;


 typedef IGRdouble  BSmatrix [ 9 ] ;
 typedef IGRdouble  BSmat [ 3 ] [ 3 ] ;
 typedef IGRdouble  BSmat2 [ 2 ] [ 3 ] [ 3 ] ;

 typedef long BSrc ;

 typedef char * BSaddr ;
 typedef IGRdouble BSpair [ 2 ] ;





 typedef void * ( * new_fn_type ) ( long ) ;
 typedef void ( * delete_fn_type ) ( void * , long ) ;
#line 191  "/export/home/isdp/isdp263_08/vds/include/VDtypedef.h"
 typedef struct GRid           TGRid ;
 typedef struct GRas           TGRas ;
 typedef struct GRmd_env       TGRmd_env ;
 typedef struct GRparms        TGRparms ;
 typedef struct GRlc_info      TGRlc_info ;
 typedef struct GRobj_env      TGRobj_env ;
 typedef struct GRsymbology    TGRsymbology ;
 typedef struct GRmdenv_info   TGRmdenv_info ;
 typedef struct GRvg_construct TGRvg_construct ;

 typedef struct IGRplane       TGRplane ;
 typedef struct IGRdisplay     TGRdisplay ;
 typedef struct IGRpolyline    TGRpolyline ;
 typedef struct IGRbsp_curve   TGRbsp_curve ;
 typedef struct IGRbsp_surface TGRbsp_surface ;

 typedef struct ret_struct     Tret_struct ;

 typedef struct ACrg_coll      TACrg_coll ;

 typedef IGRlong IGRstat ;
 typedef IGRlong IGRstar ;

 typedef OMuword    VDclassid ;
 typedef OMuword    VDosnum ;
 typedef OM_S_OBJID VDobjid ;

 typedef OMuword    TVDclassid ;
 typedef OMuword    TVDosnum ;
 typedef OM_S_OBJID TVDobjid ;
#line 231  "/export/home/isdp/isdp263_08/vds/include/VDtypedef.h"
 typedef struct { IGRdouble x , y , z ; } TGRpoint ;
#line 73  "/export/home/isdp/isdp263_08/vds/include/VDxml.h"
 typedef IGRchar TVDxmlTagType [ 40                ] ;
 typedef IGRchar TVDxmlAtrValue [ 128                ] ;

 typedef struct
 {
  IGRint type ;
  TVDxmlTagType  eleType ;
  TVDxmlTagType  atrType ;
  TVDxmlAtrValue atrValue ;
 } TVDxmlEleInfo ;

 typedef struct
 {
  IGRint type ;
  TVDxmlTagType  eleType ;
  TVDxmlTagType  atrType ;





  IGRchar       * atrValue ;

 } TVDxml2EleInfo ;

 typedef struct
 {

  IGRchar  fileName [ 256 ] ;
  IGRlong  filePos ;
  FILE    * file ;


  IGRchar * buf ;
  IGRint   bufMax ;
  IGRint   bufPos ;
  IGRint   bufInc ;
  IGRint   bufIndex ;

 } TVDxmlStreamInfo ;

 typedef struct
 {

  TVDxmlStreamInfo io ;


  IGRstat stopParser ;
  IGRstat retFlag ;


  TVDxmlTagType  eleTypes [ 64                 ] ;
  IGRint         eleIndex ;
  IGRint         eleMax ;


  struct TVDxmlParseInfoCallback * parseInfoCallback ;


  TVDxmlEleInfo eleInfo ;


  void * data ;

 } TVDxmlParseInfo ;

 typedef struct
 {

  TVDxmlStreamInfo io ;


  IGRstat stopParser ;
  IGRstat retFlag ;


  TVDxmlTagType  eleTypes [ 64                 ] ;
  IGRint         eleIndex ;
  IGRint         eleMax ;


  struct TVDxml2ParseInfoCallback * parseInfoCallback ;


  TVDxml2EleInfo eleInfo ;


  void * data ;

 } TVDxml2ParseInfo ;


 typedef struct
 {
  IGRstat  ( * parseCallback ) ( TVDxmlParseInfo * parseInfo ) ;
 } TVDxmlParseInfoCallback ;
 typedef struct
 {
  IGRstat  ( * parseCallback ) ( TVDxml2ParseInfo * parseInfo ) ;
 } TVDxml2ParseInfoCallback ;


 typedef struct {

  TVDxmlStreamInfo io ;

  IGRint   indent ;
  IGRint   closed ;

 } TVDxmlFileInfo ;

 typedef struct {
  int             cnt ;
  int             max ;
  TVDxmlFileInfo * info ;
 } TVDxmlFileInfos ;
#line 204  "/export/home/isdp/isdp263_08/vds/include/VDxml.h"
 extern IGRstat VDxmlParseFile
 ( TVDxmlParseInfo * info , IGRchar * fileName , IGRstat ( * callback ) ( TVDxmlParseInfo * info ) , void * user )


                           ;

 extern IGRstat VDxmlParseBuf
 ( TVDxmlParseInfo * info , IGRchar * bufName , IGRchar * bufData , IGRint bufMax , IGRstat ( * callback ) ( TVDxmlParseInfo * info ) , void * user )




                           ;

 extern IGRstat VDxmlParseGetParentEleType
 ( TVDxmlParseInfo * info , IGRint nth , TVDxmlTagType type )

                           ;

 extern IGRstat VDxml2ParseFile
 ( TVDxml2ParseInfo * info , IGRchar * fileName , IGRstat ( * callback ) ( TVDxml2ParseInfo * info ) , void * user )


                            ;

 extern IGRstat VDxml2ParseBuf
 ( TVDxml2ParseInfo * info , IGRchar * bufName , IGRchar * bufData , IGRint bufMax , IGRstat ( * callback ) ( TVDxml2ParseInfo * info ) , void * user )




                            ;

 extern IGRstat VDxml2ParseGetParentEleType
 ( TVDxml2ParseInfo * info , IGRint nth , TVDxmlTagType type )

                            ;




 extern void VDstrupr ( IGRchar * str )                 ;
 extern void VDstrlwr ( IGRchar * str )                 ;




 extern IGRstat VDxmlIsXMLFile
 ( IGRchar * fileName , IGRchar * docType , TVDxmlFileInfos * fileInfos )

                                ;

 extern IGRstat VDxmlFindXMLFilesInDir
 ( IGRchar * dirName , IGRchar * docType , TVDxmlFileInfos * fileInfos )

                                ;

 extern IGRstat VDxmlFindXMLFiles
 ( IGRint localFlag , IGRchar * configPath , IGRchar * docType , TVDxmlFileInfos * fileInfos )


                                ;

 extern IGRstat VDxmlGetNameValue
 ( IGRchar * buf , IGRchar * name , IGRchar * value )

                    ;

 extern IGRstat VDxmlLoadBufferFromFile
 ( IGRchar * fileName , IGRchar * buf )
                  ;

 extern IGRstat VDxmlSaveBufferToFile
 ( IGRchar * fileName , IGRchar * buf )
                  ;





 extern IGRstat VDxmlOpenOutputFile
 ( TVDxmlFileInfo * fileInfo , IGRchar * fileName , IGRchar * docType , IGRchar * dtdName )


                             ;

 extern IGRstat VDxmlOpenOutputBuf
 ( TVDxmlFileInfo * fileInfo , IGRchar * buf , IGRint bufMax , IGRint bufInc , IGRchar * docType , IGRchar * dtdName )




                             ;


 extern IGRstat VDxmlOpenOutputStream
 ( TVDxmlFileInfo * fileInfo , IGRchar * fileName , IGRchar * docType , IGRchar * dtdName , IGRchar * buf , IGRint bufMax , IGRint bufInc , IGRint stripColons , IGRdouble version , IGRint standAlone )








                                ;
#line 333  "/export/home/isdp/isdp263_08/vds/include/VDxml.h"
 extern IGRstat VDxmlCloseOutputFile
 ( TVDxmlFileInfo * fileInfo )                             ;

 extern IGRstat VDxmlCloseOutputStream
 ( TVDxmlFileInfo * fileInfo )                             ;








 extern IGRstat VDxmlGetTextFileName
 ( TVDxmlFileInfo * fileInfo , IGRchar * txtFileName )
                                 ;








 extern IGRstat VDxmlWriteObjBeg
 ( TVDxmlFileInfo * fileInfo , IGRchar * objType , IGRint attrFlag , IGRint returnFlag )


                                ;








 extern IGRstat VDxmlWriteObjEnd
 ( TVDxmlFileInfo * fileInfo , IGRchar * objType , IGRint indentFlag )

                                ;








 extern IGRstat VDxmlWriteAtrEnd
 ( TVDxmlFileInfo * fileInfo , IGRint indentFlag , IGRint returnFlag )

                                ;








 extern IGRstat VDxmlWriteAtrTxt
 ( TVDxmlFileInfo * file , IGRchar * atrName , IGRchar * atrValue , IGRint indentFlag , IGRint returnFlag )



                                ;








 extern IGRstat VDxmlWriteAtrDbl
 ( TVDxmlFileInfo * file , IGRchar * atrName , IGRdouble atrValue , IGRint indentFlag , IGRint returnFlag )



                                ;








 extern IGRstat VDxmlWriteAtrInt
 ( TVDxmlFileInfo * file , IGRchar * atrName , IGRint atrValue , IGRint indentFlag , IGRint returnFlag )



                                ;








 extern IGRstat VDxmlWriteIndent
 ( TVDxmlFileInfo * fileInfo )                             ;
#line 450  "/export/home/isdp/isdp263_08/vds/include/VDxml.h"
 extern IGRint VDxmlGetStreamChar    ( TVDxmlStreamInfo * io )                         ;
 extern IGRint VDxmlGetChar          ( TVDxmlParseInfo * info )                           ;
 extern IGRint VDxmlPushChar         ( TVDxmlParseInfo * info )                           ;
 extern IGRint VDxmlPeekChar         ( TVDxmlParseInfo * info )                           ;
 extern IGRint VDxmlGetToken         ( TVDxmlParseInfo * info , IGRchar * buf )                                         ;
 extern IGRint VDxmlIsCharWhiteSpace ( IGRint c )             ;
 extern IGRint VDxmlIsCharTag        ( IGRint c )             ;

 extern IGRint VDxml2GetStreamChar    ( TVDxmlStreamInfo * io )                         ;
 extern IGRint VDxml2GetChar          ( TVDxml2ParseInfo * info )                            ;
 extern IGRint VDxml2PushChar         ( TVDxml2ParseInfo * info )                            ;
 extern IGRint VDxml2PeekChar         ( TVDxml2ParseInfo * info )                            ;
 extern IGRint VDxml2GetToken         ( TVDxml2ParseInfo * info , IGRchar * buf )                                          ;
 extern IGRint VDxml2IsCharWhiteSpace ( IGRint c )             ;
 extern IGRint VDxml2IsCharTag        ( IGRint c )             ;
#line 42  "VDxmlDom.C"
 static int traceFlag ;
