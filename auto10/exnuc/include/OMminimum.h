/*
---------------------------------------------------------------------------

File:                   OMminimum.h
Author:                 Chuck Puckett
Date:                   1985

Change History:

cgp001	31-jan-1985	Add "neighbor" struct,  used in constructing an
			object.

gja001	14-mar-1986	add overwrite flag (OM_e_ovrwrt_flg)

kek001  21-mar-1986	ISO changes.  Change minor channel to ISO index
			In channel_linkage remove CLf_arrayed, add
			CLf_to_rel and CLf_to_iso. 
			In relation_linkage remove RLf_arrayed, add
			RLf_to_iso and RLf_to_object.

gja002	18-apr-1986	Added global "OM_Gw_senders_OS"

cgp002	10-jun-1986	Massive 4.0 changes

plh001  3-jul-1986	Merged OMclassdef.h for OM 4.0.
			Some pointers changed to not use typedefs
			so OMspecify.h need not be included here.

jaj002  14-jul-1986	Added *ChanDefns to class definition structure.

geo001  10-nov-1986	Added cluster swap structure & structure made
			up of cluster composite pointer and cluster
			swap pointer & replacing ClustCmp Array in OSD
			with this structure of dual pointers.

glc001  16-feb-1987     Added definition for the ODEN status bit field

ems001  19-mar-1987     Removed include for primitives

rme001  06-apr-1987     Add object hdr flag for tagged object

rme002  23-apr-1987     Add externs for tag runtime parameters.

tlg	7-jun-1987	Move oden data structures to ODminimum.h.

geo002	17-nov-1987	Changes to objhdr, spamapent, all cluster structures
			and osd for om4.6 cluster/swap modifications
			and add dlink definition
			
saw001	18-nov-1987	Added Raw Partition Block definition.  Replaces
			old swap partition struction in OMparameters.h.

rme003  10-aug-1988	Moved struct OM_sd_ancestry from OMspecify.h to
			here.  Needed it here for folks to take advantage
			of send to self wrt_parent.

saw002  8-sep-1988      Add flags to LCD and CSD structures to support
                        no-write-on-swap-out for clusters that are stable
                        and not being modified.  Allows for a cluster to
                        reside both in a slot and on a partition lump at
                        the same time.  Swap out frees up the copy in
                        memory; swap in restores the copy in memory.
---------------------------------------------------------------------------
*/


#ifndef	OM_D_MINIMUM
#define OM_D_MINIMUM	1
#include	"OMlimits.h"
#include        "OMtypes.h"

#define OM_K_NOTUSING_CLASSID   	((OMuword) -1)
#define OM_K_NOT_AN_OS          	((OMuword) -1)
#define OM_K_change_class_sd_override 	((OMuint) 0x48654c70)

/* The ubiquitous object header... */

struct OM_sd_objecthdr
{
  OM_S_OBJID			oid;		/* object id */

#define	OM_OHf_outrigger	1               /* is an VLA outrigger hdr */
#define	OM_OHf_has_VLA		2               /* object contains VLA's  */
#define OM_OHf_is_tagged        4               /* is a tagged object */

	/* lower 3 bits of i_size are irrelevant since all objects
	   are quad aligned.  above flags are in lower 3 bits of i_size 
	   NOTE:  compress procedure will make use of OM_OHf_outrigger
	          bit during its processing                           */
	          
  OMuint	 		i_size;		/* byte size of object    */
};
typedef struct OM_sd_objecthdr 	OM_S_OBJECTHDR;
typedef struct OM_sd_objecthdr 	*OM_p_OBJECTHDR;

enum   OM_e_wrt_flag  {OM_e_wrt_object=25,
    		       OM_e_wrt_ancestor=26,
		       OM_e_wrt_message=26, 
		       OM_e_wrt_parent=27};
		       
/* with respect to group needs refinement: the message GOES to group, but is
   the messages wrt_object, wrt_ancestor, etc... */

/*		       OM_e_wrt_group};	*/

typedef enum  	OM_e_wrt_flag 	OM_E_WRT_FLAG;

enum	OM_e_inc_flag	{OM_e_inclusive=27, 
			 OM_e_exclusive};
typedef	enum	OM_e_inc_flag	OM_E_INC_FLAG;

enum	OM_e_ovrwrt_flg	{OM_e_overwrite=13,			/* gja001  */
			 OM_e_no_ovrwrt,
                         OM_e_overwrite_rrr };	
typedef	enum OM_e_ovrwrt_flg	OM_e_OVRWRT_FLG;

/* define a "neighbor" struct. This is used when constructing an object. For
   now, it contains the objid of a "neighbor" object, and a segment. A global
   variable (OM_GS_NULL_NEIGHBOR) contains  defaults for this struct */

struct OM_sd_neighbor
{
  OM_S_OBJID		groupid;
  OMuword		clusterid;
};
typedef	struct	OM_sd_neighbor	OM_S_NEIGHBOR;
typedef	struct	OM_sd_neighbor	*OM_p_NEIGHBOR;


/* define a method selector */
/* for 4.0, change so that we have "definer" classid, and "requested" classid;
   that is, Grafix defines rotate message, but Line.rotate (subclass of Grafix)
   was message that was invoked */


struct OM_sd_methselect
{
  OMuword		DefClassid;	/* classid who defined message */
  OMuword		ReqClassid;	/* invoked classid */
  OMuword		FuncIndex;	/* function index */
};
typedef struct OM_sd_methselect *OM_p_METHSELECT;
typedef struct OM_sd_methselect OM_S_METHSELECT;


/* define the message struct, which consists of the method selector, the byte
   size of the argument list, and a pointer to the arguments. */

struct OM_sd_message
{
  OM_S_METHSELECT	select;
  OMuword		size;
  char 			*p_arglist;
};
typedef struct OM_sd_message *OM_p_MESSAGE;
typedef struct OM_sd_message OM_S_MESSAGE;

/* variable length array place holder in an object */

struct OM_sd_varlenarr_descr
{
  int 		i_offset;	/* self-relative offset to the array */
  OMuint 	i_count;	/* max no. of elements array can hold */
};
typedef struct OM_sd_varlenarr_descr OM_S_VARLENARR_DESCR;
typedef struct OM_sd_varlenarr_descr *OM_p_VARLENARR_DESCR;

/* a new guy: channel number as structure. Holds classid and number in that
   class */

struct OM_sd_channum
{
  OMuword			classid;
  OMuword			number;
};
typedef	struct	OM_sd_channum	OM_S_CHANNUM;
typedef	struct	OM_sd_channum	*OM_p_CHANNUM;



/* the following structure is for users of OM_get_channel_objects */

struct OM_sd_object_linkage
{
  OMuword		osnum;
  OMuword		w_flags;
  OM_S_CHANNUM		channum;	/* target channel "number" */
  OM_S_OBJID		S_objid;
};
typedef struct  OM_sd_object_linkage     *OM_p_OBJECT_LINKAGE;  
typedef struct  OM_sd_object_linkage     OM_S_OBJECT_LINKAGE;  

struct OM_sd_channel_hdr
{

  OMuword	flags;

/* define channel flag bits */

#define		OM_CH_singleton		1	/* only one linkage for this channel */
#define		OM_CH_1_1		2	/* if set, channel is 1-1 */
#define 	OM_CH_m_1		4	/* many to one */
#define 	OM_CH_1_m		8
#define 	OM_CH_m_m		0x10
#define 	OM_CH_absordered	0x20
#define		OM_CH_relordered	0x40
#define	 	OM_CH_full		0x80	/* full - no more allowed */
#define         OM_CH_preset            0x200   /* preset number of links */
#define		OM_CH_restricted	0x400 
#define		OM_CH_in_use		0x800	/* send depth */
#define		OM_CH_tail_exists	0x1000  /* channel not full */
#define         OM_CH_collapse_count    0x2000  /* no tail but collapse count
                                                   is non zero */
#define		OM_CH_bigchan           0x4000  /* more than 65535 entries */

union
    {
    OMuword		count;
    OMuword		isoindex;
    } u1;

};
typedef	struct	OM_sd_channel_hdr	OM_S_CHANNEL_HDR;
typedef	struct	OM_sd_channel_hdr	*OM_p_CHANNEL_HDR;

struct OM_sd_channel_link
{

#define			OM_CL_to_object		0x100

  OM_S_CHANNEL_HDR	hdr;
  OM_S_CHANNUM		channum;	/* target channel "number" */
  OM_S_OBJID		objid;
};
typedef	struct	OM_sd_channel_link	OM_S_CHANNEL_LINK;
typedef	struct	OM_sd_channel_link	*OM_p_CHANNEL_LINK;

struct OM_sd_restricted_onechan
{
  OM_S_CHANNEL_HDR		hdr;
  OM_S_OBJID			objid;
};
typedef struct OM_sd_restricted_onechan	OM_S_RESTRICTED_ONECHAN;
typedef struct OM_sd_restricted_onechan	*OM_p_RESTRICTED_ONECHAN;

struct OM_sd_little_tail
{
  OMuword  collapse_count;
  OMuword  last_index;
};
typedef struct OM_sd_little_tail OM_S_LITTLE_TAIL;
typedef struct OM_sd_little_tail *OM_p_LITTLE_TAIL;

struct OM_sd_big_tail
{
  OMuint  collapse_count;
  OMuint  last_index;
  OMuint  size;
};
typedef struct OM_sd_big_tail OM_S_BIG_TAIL;
typedef struct OM_sd_big_tail *OM_p_BIG_TAIL;

/* channel selector */

struct OM_sd_chanselect
{
  enum			{OM_e_name, OM_e_num, OM_e_addr} type;
  union
  {
    char	        *name;
    OM_S_CHANNUM	number;
    OM_p_CHANNEL_HDR    *addr;
  } u_sel;
};
typedef	struct	OM_sd_chanselect	OM_S_CHANSELECT;
typedef	struct	OM_sd_chanselect	*OM_p_CHANSELECT;

typedef	struct OM_sd_classdef		*OM_p_CLASSDEF;
typedef struct OM_sd_PCD		*OM_p_PCD;


/* define the spacemap entries */

struct OM_sd_spamapent
{
  OM_p_CLASSDEF		p_acld;	   /* ptr to active class def  */
  OMuword		sdi;	   /* slot descriptor index when in mem */
  OMuword		flags;
  
#define OM_SM_array_mod		1  /* VLA has been modified          */
#define OM_SM_Rootdel_pending	2  /* Root delete msg pending        */
#define OM_SM_in_use		4  /* Objid currently used           */
#define OM_SM_in_mem		8  /* Objid currently in memory      */
				   /* 4 possible states of inuse & inmem bits */
				   /* 00 free spamapentry	     */
				   /* 01 inuse but in UNIX file      */
				   /* 10 impossible */
				   /* 11 inuse & inmem		     */
#define OM_SM_has_di_name      16  /* Object has IGRdir name         */
#define OM_SM_has_msgintrcpt   32  /* Object has msg intercept objid */
#define OM_SM_send_depth       64  /* Object has elevated send depth */
#define OM_SM_disable_intrcpt 128  /* Msg intercept has been disabled */
#define OM_SM_unknown_obj     256  /* Object is of unknown class     */

  union OM_sd_spamapent_state      /* use and memory state of this oid */
  {				   /* determines this fields contents  */
    OM_p_OBJECTHDR	object;	   /* ptr to object when object is in  */
				   /* memory                           */
    struct 
    {
      OMuword		dummy;     /* not current being used   */
      OMuword		clusterid; /* logical clusterid when in use and */
				   /* needs to be faulted in           */
    } filed_obj;		   /* object is in a file..	       */

    OM_S_OBJID		freeoid;   /* next free oid; free list link    */
  } state;
};
typedef	struct	OM_sd_spamapent		OM_S_SPAMAPENT;
typedef	struct	OM_sd_spamapent		*OM_p_SPAMAPENT;

/* define a "resultant instance pointer structure" */

struct	OM_sd_RIP
{
  OM_p_OBJECTHDR	p_object;	/* pointer to instance */
  OM_p_SPAMAPENT	p_mapentry;
};
typedef	struct	OM_sd_RIP	OM_S_RIP;
typedef	struct	OM_sd_RIP	*OM_p_RIP;

/* define a "hole" descriptor for filed OS. A reverse ordered list of these is
   kept in the OSO,  which is in turn in the OSO */

struct OM_sd_OShole
{
  OMuint		FilePtr;	/* fileptr of start of hole */
  OMuint		size;		/* byte size of hole */
};
typedef	struct	OM_sd_OShole	OM_S_OSHOLE;
typedef	struct	OM_sd_OShole	*OM_p_OSHOLE;

/*=================================*/
/***** Group Extent Definition *****/
/*=================================*/

struct OM_sd_GROUP_extent
{			      
 OM_S_OBJID	beg_oid;	/* 1st oid of extent's range of oids */
 OMuint		size;		/* size of extent's range of oids    */
};
typedef struct OM_sd_GROUP_extent	OM_S_GROUP_EXTENT;
typedef struct OM_sd_GROUP_extent	*OM_p_GROUP_EXTENT;


/*=================================*/
/******* CLUSTER DEFINITIONS *******/
/*=================================*/

typedef struct OM_sd_FREE_CHUNK_DESCR *OM_p_FCD;

struct OM_sd_CLUSTER_freehdr  /* This structure must remain of quad size!! */
{			      /*  in order to keep track of all unused  */
			      /*  pieces within a cluster.		*/
 OM_p_FCD       p_fcd;          /* ptr to free chunk descriptor */
 OMuint		size;		/* byte size of free chunk */
};

typedef struct OM_sd_CLUSTER_freehdr	OM_S_CLUSTFHDR;
typedef struct OM_sd_CLUSTER_freehdr	*OM_p_CLUSTFHDR;


struct OM_sd_FREE_CHUNK_DESCR
{
  OM_p_FCD        nextfcd;        /* Next descriptor in list */
  OM_p_CLUSTFHDR  freehdr;        /* Ptr to free hdr in the extent */
  OMuint          size;           /* Aligned size of the free chunk */
};

typedef struct OM_sd_FREE_CHUNK_DESCR   OM_S_FCD;
typedef struct OM_sd_CLUSTER_composite  *OM_p_LCD;
typedef struct OM_sd_CSD		*OM_p_CSD;

struct OM_sd_PCD	/* Physical Cluster Descriptor */
{
 OM_S_DLINK   pcdq;	/* queue element of PCDs in same LCD */
 		  	/* OR queue element of available PCDs */
 OM_S_DLINK   lcfq;     /* queue element of last cluster faulted queue */ 
 OM_p_LCD     p_lcd;    /* owning logical cluster descriptor     */
 OM_p_FCD     p_fcd;	/* pointer to 1st free chunk descr       */
 OM_p_CSD     p_csd;	/* pointer to associated cluster slot descr */
 OMuint	      i_totalfree;    /* byte amount of free space in phy cluster */
 OMuint	      i_numfree_chunks; /* number of free contiguous chunks of mem */
 OMuint	      i_totalsize;    /* byte size of phy cluster */
 OMuint	      i_cur_num_objects; /* number of objects in active cluster */
 OMuint	      i_cur_num_chunks; /* total number of chunks; objects or vla outriggers */
 OMuint	      i_totalWsheap;    /* byte size of phy cluster; including sheap */
};
typedef struct OM_sd_PCD	OM_S_PCD;

typedef	struct	OM_sd_OSD	*OM_p_OSD;

struct OM_sd_CLUSTER_composite	/* logical cluster descriptor (LCD) */
{
OM_S_DLINK	pcdq_lh;	/* listhead of queue of my phy clusters */
OM_p_PCD	p_pcd;		/* points to latest pcd where space was
				   available; i.e. where in queue to start
				   search next time  */
OM_p_OSD	p_osd;		/* what obj space cluster belongs to */
OMuint		i_file_ptr;	/* where the cluster lived on disk */
OM_S_OBJID	oid;		/* cluster object's objid */
OMuword		w_cluster_num;	/* my identifying number */
OMuword		flags;

#define	OM_FAULTED	   1	/* currently in storage */
#define OM_USERSPEC	   2	/* this is a user specified cluster */

OMuint		i_cur_bytes_allocated; /* total bytes allocated to
					this cluster */
};
typedef struct OM_sd_CLUSTER_composite	OM_S_LCD;

struct OM_sd_CSD	/* Physical Cluster Slot Descriptor */
{
OM_S_DLINK	lcq;	/* queue element of locked cluster queue (LCQ) */
			/* OR CSD avail queue */
OM_p_PCD	p_pcd;		/* associated pcd */
char         	*p_addr;	/* beg addr of virtual mem; pg aligned   */
OMuint		PreSendDepth;	/* physical cluster's pre send depth */
OMuint		PostSendDepth;	/* physical cluster's post send depth */
OMuword		flag;

#define	OM_CLUST0	2	/* a cluster0 slot */
#define	OM_BIG		4	/* a big object slot */
#define OM_INUSE	16	/* slot not empty or available */

OMuword		index;		/* CSD index of this slot */
};
typedef struct OM_sd_CSD	OM_S_CSD;


/*-------------------*/
/*  OSCO definition  */
/*-------------------*/

struct OM_sd_OSCO
{
   OMuword    w_classid;                  /*  filed class id                */
   OMuword    w_child_refcnt;             /*  # dependent child OSCO's      */
   char       s_name[OM_K_MAXCLASS_LEN];  /*  class name                    */
   OMuword    w_oppmaj_version;           /*  opp major version             */
   OMuword    w_oppmin_version;           /*  opp minor version             */
   OMuword    w_major_version;            /*  class major version           */
   OMuword    w_minor_version;            /*  class minor version           */
   OMuint     i_refcnt;                   /*  # objects in OS of this class */
   OM_S_OBJID OSCO_oid;                   /*  oid of OSCO                   */
};
typedef struct OM_sd_OSCO        OM_S_OSCO;
typedef struct OM_sd_OSCO       *OM_p_OSCO;


/* define the Object Space Descriptor. This structure is in the OSO, and is
   also made available via array of pointers in OM_GA_OSDs */


struct OM_sd_OSD
{
  OM_S_DLINK		lcfq_lh;		/* last cluster fault queue
						   listhead       */
  OM_S_OBJID    	OSO_Oid;	/* oid of the OSO (and cluster0)     */
  OM_S_OBJID		Group0_Oid;	/* oid of the OSO's Group0           */
  OMuword		OSnum;		/* the OS number of this OS          */
  char			name[OM_K_MAXOSNAME_LEN];	/* object space name */
  char			InternalName[OM_K_MAXINTOSNAME_LEN]; 
  OMbyte		type;

/* define three OS "types" */

#define 	OM_OSD_MOSDOS		1
#define 	OM_OSD_trans		2
#define 	OM_OSD_filed		3

  OMbyte		flags;

/* define flags bits */

#define 	OM_OSD_inuse		1
#define 	OM_OSD_nowrite		2
#define 	OM_OSD_compress_on_wrt	4
#define 	OM_OSD_modified		8	/* set if OS has been accessed
						   since last write          */
#define 	OM_OSD_ISOmodified	16	/* set if any ISO has been
						   modified since last write */
#define		OM_e_loados_ro		32	/* this os (filed) cannot be
						   written	 	     */
#define		OM_OSD_Rootdel_pending	64	/* when deleting the OSO,
						   this bit will tell Root
					           delete to delete OSO */

  OMuword		*ActToFil;	/* active to filed classid map   */
  OMuword		*FilToAct;	/* filed to active classid map   */
  OMuint		MaxOSSize;	/* max byte size for OS */
  OMuint		CurSpaceMapSize;/* number of space map entries   */
  OM_p_SPAMAPENT	Spacemap;	/* ptr to spacemap array         */
  OMuint		ClustersSize;	/* Number of clusters making up  */
					/*  Clusters array               */
  OM_p_LCD		*Clusters;	/* ptr to array of ptrs. to LCDs */
  OM_p_OSCO             *OSCO_list;     /* ptr to array of ptrs to OSCOs */
  OMuint		OidFreelist;	/* offset to my vla descr of free oids	 */
};
typedef	struct	OM_sd_OSD	OM_S_OSD;


/*  Define the structure that is used by the get_status message on OS  */

struct OM_sd_OSstatus
{
   OMbyte     stattype;  /*  Set by user to select returned info.  */
   
   /*  stattype values:  */

#define OM_OS_STATUS_MISC     0
#define OM_OS_STATUS_CLUSTERS 1
#define OM_OS_STATUS_GROUPS   2
#define OM_OS_STATUS_NODS     4

   union
   {
      /*  STATUS_MISC  */
      struct  
      {
         OMbyte     OStype;           /*  Type of OS, see OS descriptor (OSD)
                                          in OMminimum.h.  */
         OMbyte     OSflags;          /*  Flags byte from the OSD.  */
         OMuint     num_OMobjects;    /*  Count of OM objects in OS.  */
         OMuint     num_UserObjects;  /*  Count of user constructed objects. */
         char       CreTimeDate[16];  /*  Time and date of OS creation. */
         char       TimeDate[16];     /*  Time and date OS was last written. */

         /*  Time and date have format "mmddyyyyhhmm" plus NULL plus pad.  */
      } misc;

      /*  STATUS_CLUSTERS  */
      struct  
      {
         OMuint   total_num;     /*  Count of how many clusters.  */
         OMuint   num_faulted;   /*  Count of clusters currently in memory.  */
         OMuint   mem_allocated; /*  Total bytes of memory allocated for all 
                                     clusters.  */
         OMuint   num_chunks;    /*  No. of objects and outriggers allocated */
      } cluster;

      /*  STATUS_GROUPS  */
      struct  
      {
         OMuint   total_num;  /*  Total number of groups.  */
      } group;
   } stat;
};

typedef struct OM_sd_OSstatus   OM_S_OSSTATUS;
typedef struct OM_sd_OSstatus  *OM_p_OSSTATUS;


struct OM_sd_msgmap    /* one entry for this class and each ancestor class */
{
  OM_p_FUNCPTR		*MethTbl;
  OMuint		offset;		/* to instance data for this class */
  OMuword		classid;	/* for defining class              */
  OMuword		NumChan;        /* number of channels defined      */
  struct OM_sd_channel_defn	*ChanDefns;
};
typedef	struct	OM_sd_msgmap		OM_S_MSGMAP;
typedef	struct	OM_sd_msgmap		*OM_p_MSGMAP;


typedef	struct	OM_sd_ancestry	*OM_p_ANCESTRY;
struct OM_sd_ancestry
{
  OMuword		*p_classid;	/* ptr to classid of this parent */
  int			(*p_create_args)();/* allows creation of parent */
  OMuword		MajVer;		/* major version of this parent */
  OMuword		MinVer;		/* minor version of same */
  OM_p_ANCESTRY		p_sibling;	/* link for subclass list */
  OM_p_CLASSDEF		p_classdef;	/* ptr to classdef for THIS class */
};
typedef	struct	OM_sd_ancestry	OM_S_ANCESTRY;

/* classid for an undefined class is -1 */

#define OM_K_CLASS_NOT_DEFINED	(OMuword) -1			/* cgp004 */

struct	OM_sd_classdef
{
  OMuword		w_classid;        /* "active" class id              */
  OMuint		i_instance_size;  /* size in bytes of instance data */
  OMuint		NewInstanceSize;  /* size in bytes of new instance  */
  OMuword		w_major_version;  /* active class major version     */
  OMuword		w_minor_version;  /* active class minor version     */
  OMuword		w_oppmaj_version; /* version numbers of opp that    */
  OMuword		w_oppmin_version; /* created this class             */
  char			s_name[OM_K_MAXCLASS_LEN]; /* string name of class  */
  OMuint	        flags;            /* flag space */

#define     OM_CLDf_TAGGABLE    0x1

  struct OM_sd_varlenarr_defn	*p_varlenarr_defns;
  OMuword		w_num_varlenarrays;
  OMuword		w_numparents;	  /* number of immediate ancestors  */
  struct OM_sd_ancestry	*A_ancestor_list; /* list of immediate ancestors    */
  struct OM_sd_ancestry	 *p_subclass_list;/* list of class's subclasses     */
  struct OM_sd_channel_defn *ChanDefns;		/* jaj002 */
  OMuword		w_numchannels;	  /* count of known channels        */
  OMuword		w_nummethods;	  /* count of methods for this class*/
  struct OM_sd_methdefn	*p_methdefns;	  /* linked list  of meth defns     */
  struct OM_sd_Dclass	*p_instance_def;  /* instance definition from dictionary   */
  OMuint		initial_size;	  /* obj initial size including vlas */

  OMuint		NumRecClasses;      /* number of classes that
					       that are merely recognized
						by this class */
  OMuword		w_maxclass;	  /* maximum legal classid of       */
   					  /* messages class can receive     */
  OMuword		w_baseclass;	  /* bias of minimum classid for    */
					  /* messages this class can receive*/
  OMbyte		*p_transmap;	  /* ptr to translator map which    */
					  /* validates incoming messages    */
#define	OM_K_NULL_TRANS   0		/* null transmap entry not ancestor */

  OMuword		NumMsgClasses;    /* size of classmap array         */
  OM_p_MSGMAP		MsgMap;		  /* pointer to classmap array      */ 
 int  			*p_createclass_args; /* pointer to OM_S_CREATECLASS_ARGS */
};
typedef	struct	OM_sd_classdef		OM_S_CLASSDEF;

/*----------------------------------*/
/*  CLASSLIST used in pass methods  */
/*----------------------------------*/

struct OM_sd_classlist {
  OMuword	w_count;		/* size of array of classids      */
  OMuword       w_flags;                /* flag word                      */

#define         OM_CLST_subclass  1     /* pass to subclasses of classes  */
                                        /* in classlist also              */
#define         OM_CLST_negation  2     /* pass to all classes NOT in the */
                                        /* classlist                      */
#define         OM_CLST_internal  0x80  /* for internal OM use only       */

  OMuword	*p_classes;		/* array of classids              */
};
typedef struct OM_sd_classlist		OM_S_CLASSLIST;
typedef struct OM_sd_classlist		*OM_p_CLASSLIST;

/*------------------------------*/
/*  TAG CONNECT INFO STRUCTURE  */
/*------------------------------*/

struct OM_sd_tag_con_info
{
   OM_S_OBJID         objid;             /* Oid that is connected to tag */
   OM_S_CHANNUM       chan;              /* Oid's channel number         */
   OMuword            index;             /* Oid's index (if ordered)     */
   OMuint             tag;               /* Tag of object2               */
   OM_S_CHANNUM       tag_chan;          /* Tagged Oid's channel number  */
   OMuword            tag_index;         /* Tagged Oid's index           */
   OMuword            version;           /* Version identifier           */
};
typedef struct OM_sd_tag_con_info OM_S_TAG_CON_INFO;
typedef struct OM_sd_tag_con_info *OM_p_TAG_CON_INFO;


typedef struct OM_sd_class_hash_ent *OM_p_CLASS_HASH_ENT;
struct OM_sd_class_hash_ent 
{
   OM_p_CLASSDEF        p_acld;
   OM_p_CLASS_HASH_ENT  next;
};
typedef struct OM_sd_class_hash_ent  OM_S_CLASS_HASH_ENT;

/*--------------------------------------------------*/
/*  define structure for keeping original OS names  */
/*--------------------------------------------------*/

typedef struct OM_sd_orig_osname *OM_p_ORIGOSNAME;

struct OM_sd_orig_osname {
   OMuword osnum;
   char orig_name[OM_K_MAXOSNAME_LEN];
   OM_p_ORIGOSNAME  next;
};

typedef struct OM_sd_orig_osname OM_S_ORIGOSNAME;


typedef struct OM_sd_dup_intosname *OM_p_DUPINTOS;

struct OM_sd_dup_intosname {
   OMuword        osnum;                     /*  Object space number         */
   OMuword        num_dup;                   /*  Number of duplicates        */
   OMuword       *dup_osnum;                 /*  List of duplicate osnums    */
   char           orig_intname[OM_K_MAXINTOSNAME_LEN];
                                             /*  Original internal name      */
   OM_p_DUPINTOS  next;                      /*  Pointer (internal use only) */
   int           *more;                      /*  Pointer (for future use)    */
};
typedef struct OM_sd_dup_intosname OM_S_DUPINTOS;


/*-----------------*/
/*  external list  */
/*-----------------*/

extern	OMuword			OM_Gw_numclasses;
extern	OMuword			OM_Gw_next_class_index;
extern	OM_p_CLASSDEF		*OM_GA_active_classes;
extern	OMuword			*OM_GA_active_to_filed;
extern	OMuword			*OM_GA_filed_to_active;
extern  OMuword			*OM_GA_fa_mapsize;
extern	OMuint			OM_Gf_consistent;
extern	OMuint			OM_Gf_consistent_class;
extern	OMuint			OM_Gf_bugcheck_fatal;
extern	OMuint			OM_Gf_verbose_warning;
extern	OMuint			OM_Gf_verbose_error;
extern  OMuint                  OM_Gf_tagged_connects;
extern OMuword			OM_Gw_current_OS;
extern OMuword			OM_Gw_senders_OS;
extern OMuword                  OM_Gw_tagged_osnum;
extern OM_S_OBJID		OM_GO_current_OS_objid;
extern OM_S_OBJID               OM_GO_current_MOSD;
extern OM_S_OBJID		NULL_OBJID;
extern OM_S_CHANNUM     	NULL_CHANNUM;
extern OM_p_OSD			*OM_GA_OSDs;
extern OM_p_OSD			OM_Gp_CurOSD;
extern OM_p_SPAMAPENT		OM_Gp_CurSpaceMap;
extern OM_S_OBJID		OM_GO_TransOS_0;
extern OMuword			OM_Gw_TransOSnum_0;
extern OM_S_NEIGHBOR		OM_GS_NULL_NEIGHBOR;
extern OM_p_NEIGHBOR		OM_Gp_NULL_NEIGHBOR;
extern OM_S_MESSAGE             OM_GS_NULL_MESSAGE;
extern OM_p_MESSAGE             OM_Gp_NULL_MESSAGE;
extern OM_S_SPAMAPENT		OM_GS_NULL_SPAMAPENT;
extern OM_p_SPAMAPENT		OM_Gp_NULL_SPAMAPENT;
extern OMuword			OM_Gw_maxOS;
extern OMuword                  OM_Gw_RO_OS_count;
extern OM_p_OBJID               OM_GA_tag_oids;
extern struct OM_sd_tag_hash_entry **OM_GA_p_tag_hashtable;
extern OMuword                  OM_Gw_tagcon_inc;
extern struct OM_sd_tagcon_link **OM_GA_p_tagcon;
extern OMuword                  OM_Gw_tag_rec_extendsize;
extern OMuword                  OM_Gw_tag_hashtable_size;
extern OMuword                  OM_Gw_tag_hash_extendsize;
extern OMuint                   OM_Gf_tagging_enabled;
extern OM_S_CSD                 *OM_GA_CSDarray;
extern OMuint			OM_Gf_errToStdout;
extern OMuint			OM_Gf_val_cluster;

#endif
