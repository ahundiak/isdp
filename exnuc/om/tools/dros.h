#include "OMmacros.h"
#include "OMOSfilehdr.h"

/* Values of mode flag (unsigned int) */

#define  MINIMUM              0x01
#define  EDIT                 0x02
#define  READONLY             0x04  /* Couldn't open design file for write */
#define  QUICK                0x08  /* Skip some unessential validation */
#define  LOGGING              0x40
#define  SOFTLOGGING          0x80

/* Values of stateOfOs flag (unsigned int) */

#define  MODIFIED             0x01  /* Has been changed since write */
#define  VALID                0x02  /* Has been verified & no errors found */
#define  HEADERVALID          0x04  /* The header is valid */
#define  OMVALID              0x08  /* OM meta-class objects are valid */
#define  FILEVALID            0x10  /* Hdr, objs & channels are valid */
#define  RTREEVALID           0x20  /* Rtree is valid */

#define  OMFILEHDRSIZE        sizeof(struct OM_sd_OS_filehdr_OM)
#define  GETOBJSIZE(size)     (((size) & 0xfffffff8) + 8)

#define  NULL_OBJID	      0xffffffff

struct ISO_data
{
   unsigned short w_flags;       /* status of entry - will be zero */
                                 /* if entry not in use */
   OM_S_CHANNUM   chan;          /* this os obj channel number */
   union
   {
      int         i_next;        /* index of next available entry */
      OM_S_OBJID  s_objid;       /* this os object */
   } iso_u;
};
struct OMISO_instance 
{
   unsigned int         oid;
   unsigned int         i_size;
   unsigned short int   osnum;
   unsigned short int   w_ISO_flags;
   unsigned short int   w_dcount;
   unsigned short int   w_dummy;
   unsigned long int    S_target_iso;
   int                  i_first;
   struct OM_sd_varlenarr_descr iso_d_descr;
};

struct OMGroup_instance 
{
   unsigned int         oid;
   unsigned int         i_size;
   unsigned long int groupid;
   char name[128];
   unsigned short int   clusternum;
   unsigned int         size;
   unsigned int         initial_size;
   unsigned int         extend_size;
   unsigned long int    next_avail;
   unsigned int         to_OSO;
   unsigned int         to_parent;
   struct OM_sd_varlenarr_descr extent_descr;
};

struct OMGroup_array
{
   struct OMGroup_instance *inst;
   int                     fp;
   unsigned short          classid;
};

struct OMCluster_instance 
{
   unsigned int         oid;
   unsigned int         i_size;
   struct OM_sd_varlenarr_descr i_filed_oid_list_descr;
   struct OM_sd_varlenarr_descr w_filed_classid_list_descr;
   unsigned int   i_my_file_ptr;
   unsigned int   i_fil_num_objects;
   unsigned int   i_fil_byte_size;
   unsigned int   to_OSO;
   struct OM_sd_CLUSTER_composite lcd;
};

struct OMObjSpace_instance
{
   char           CreTimeDate[16];
   char           TimeDate[16];
   struct OM_sd_OS_filehdr_OM *p_filehdr;
   struct OM_sd_OSD OSD;
   int            OS_HoleCount;
   struct OM_sd_varlenarr_descr OS_holes_descr;
   int            FirstISO;
   struct OM_sd_varlenarr_descr iso_d_descr;
   struct OM_sd_varlenarr_descr freeoids_descr;
   int            to_OSCOs;      /* Self-relative ptrs to channels */
   int            to_ClusDscs;
   int            to_GrpDscs;
   int            to_NamObjDir;
};

struct OShole
{
  unsigned int	FilePtr;	/* fileptr of start of hole */
  unsigned int	size;		/* byte size of hole */
};

struct sd_chan_info {
   unsigned short int type;
   unsigned short int offset;
};

struct OMOSCO_instance
{
   unsigned int         oid;
   unsigned int         i_size;
   struct OM_sd_OSCO OSCO;
   unsigned int to_OSO;
   struct OM_sd_varlenarr_descr component_list_descr;
   struct OM_sd_varlenarr_descr vla_list_descr;
   struct OM_sd_varlenarr_descr chan_info_descr;
   struct OM_sd_varlenarr_descr res_classname_descr;
   struct OM_sd_varlenarr_descr res_channum_descr;
   int                          component_size;
   unsigned short int           num_parents; 
};
  
/* .. this is the object space object.. */
union  Phantom9
{
   int            i_next;
   unsigned long  int s_objid;
};

struct ISOd_data
{
   char           s_int_os_name[OM_K_MAXINTOSNAME_LEN];
   union Phantom9 iso_u;
};

struct statsbyid
{
   unsigned short cluster_num;
   unsigned short classid;
   unsigned int   size;
   unsigned int   fp;
   unsigned int   index;         /* index into cluster's filed oid list */
   unsigned int   tag;
   unsigned int   version;
};

struct classstats
{
   unsigned int   count;
   unsigned int   size;
};

struct OMTag_instance
{
   unsigned int         oid;
   unsigned int         i_size;
   unsigned int   next_tag;
   unsigned int   num_tags;
   unsigned int   h_free;
   int            next_index;
   unsigned short flags;
   int            hash_block_size;
   struct OM_sd_varlenarr_descr tag_rec_descr;
   unsigned int   to_OSO;
};

struct OM_sd_tag_record          /* Format of entry in tag vla */
{
   unsigned int   tag;
   unsigned int   objid;
   unsigned short version;
};

struct tagNode                   /* Format of tag tree node */
{
   unsigned int   oid;
   unsigned int   index;
   unsigned int   entry;
   struct tagNode *left;
   struct tagNode *right;
   unsigned       bal : 2;	
} ;

#define CHAR_SORT    1
#define INT_SORT     2
#define STRING_SORT  3

struct sort_element
{
   unsigned int   *p_sort_struct;
   int            sort_integer;
   char           sort_char;
   char           sort_string[100];
};

struct OM_sd_connect_record
{
   unsigned int   objid;       /* Object id of object in this OS.  */
   unsigned int   tag;         /* Tag of object in other OS. */
   OM_S_CHANNUM   cnum;        /* Channel connected to in this OS. */
   OM_S_CHANNUM   other_cnum;  /* Channel connected to in the other OS. */
   unsigned short index;       /* Optional index on channel in this OS. */
   unsigned short other_index; /* Optional index on channel in the other OS. */

   unsigned short version;     /* Used to identify when the initial connection
                                  was made. */

   unsigned short flags;       /* Version mismatch or unresolved connection. */
   unsigned short next;        /* Index of next record or NULL. */
   unsigned short prev;        /* Index of previous record or NULL. */
};

struct OMTagCon_instance
{
   unsigned int   oid;
   unsigned int   i_size;
   unsigned short first_tag;   /* Start of tag list or OM_K_TAGEND  */
   unsigned short first_free;  /* Start of free list or OM_K_TAGEND */
   char    osname[OM_K_MAXINTOSNAME_LEN];  /* Internal OS name of the other
                                           object space which contains the
                                           tag records that correspond
                                           with my connect records. */
   unsigned int   count;       /* Number of active records in vla. */
   unsigned int   to_OSO;
   struct OM_sd_varlenarr_descr con_rec_descr;
};

struct component_list_struct
{
   unsigned short int   classid;
   unsigned short int   offset;
};
struct sd_vla_list
{
   unsigned short int   elt_size;
   unsigned short int   offset;
};

