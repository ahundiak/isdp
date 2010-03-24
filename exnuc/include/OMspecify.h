/*
			OMspecify.h
			Chuck Puckett & Paul Hammond.

The file that contains the things opp, odin, and OM all interface via... 

It is assumed that OMminimum.h has already been included.  The include
should not be added here because that would mess up opp (which is weak-
minded on such matters).

8/3/87 plh. Removed chksum from ancestry and create_class_args.
	    Words moved to end of create_class_args.
	    Argdef and all related structure removed from file.
	    Added pointer to class_id to create_class_args and
	    pointer to create_class_args to ancestry.

8/9/88 rme. Added flags word to create class args. 

*/
#ifndef	OM_D_SPECIFY
#define OM_D_SPECIFY	1

#ifndef	OM_D_LIMITS
#include	"OMlimits.h"
#endif


/*
	The order of these numbers is important, it allows for easy
	recognition of the category of the declarator.
*/
					/* basic types */
#define	OM_int			0
#define	OM_long_int		1
#define	OM_short_int		2
#define	OM_unsigned_int		3
#define	OM_unsigned_long_int	4
#define	OM_unsigned_short_int	5
#define	OM_float		6
#define	OM_double		7	
#define	OM_char			8	
#define	OM_basic		10
					/* non_terminal types */
#define	OM_id			11	/* reserved for future OPP things */
#define	OM_pointer		12
#define	OM_array		13
#define	OM_varray		14
#define	OM_bitfield		15
#define	OM_function		16
					/* composite types */
#define	OM_enum			20
#define	OM_struct		21
#define	OM_union		22
					/* used internally by Odin */
#define OM_Odin_symbols		30
#define	OM_object_id	 	31
#define	OM_string	 	32



/* macros used by Odin  ? */

#define dcltr_is_basic(d)		((d)->b_type < OM_basic )
#define dcltr_is_non_terminal(d)	((d)->b_type < OM_enum  &&\
					 (d)->b_type > OM_basic )
#define dcltr_is_composite(d)		((d)->b_type >= OM_enum &&\
					 (d)->b_type < OM_Odin_symbols)

/*---------------------------------------------------------------------------*/

/* now, argument, method, instance, etc definitions */

typedef struct 	OM_sd_methdefn 	*OM_p_METHDEFN;

struct OM_sd_methdefn
{
  struct OM_sd_methdefn 	*next;
  unsigned short int 		w_methidx;
  unsigned short int 		w_sizeargs;
  char 				b_numargs;
  char 				*s_name;
};
typedef struct 	OM_sd_methdefn 	OM_S_METHDEFN;


struct OM_sd_channel_type_defn
{
  unsigned short int 		w_flags;

/* define channel definition flags */

#define		CD_1_1		2
#define 	CD_m_1		4
#define 	CD_1_m		8
#define 	CD_m_m		16
#define 	CD_absordered	32
#define 	CD_relordered	64
#define		CD_restricted  0x400

  char 				*s_name;
  int				InitCount;
  int				ExtCount;
  OMuint			ClassCount;

  OMuword		**classids; /* if restricted channel,
			               this is a ptr to channel name */

  OM_S_CHANNUM		channum; /* filled in by runtime_init from
				    channel name; only used for
				    restricted channels */
};
typedef struct OM_sd_channel_type_defn *OM_p_CHANNEL_TYPE_DEFN;
typedef struct OM_sd_channel_type_defn OM_S_CHANNEL_TYPE_DEFN;

struct OM_sd_channel_defn
{
  OM_p_CHANNEL_TYPE_DEFN	p_type;
  unsigned int 			i_offset;
  char 				*s_name;
};
typedef struct OM_sd_channel_defn *OM_p_CHANNEL_DEFN;
typedef struct OM_sd_channel_defn OM_S_CHANNEL_DEFN;

struct OM_sd_varlenarr_defn
{
  OMuint	 		w_offset;
  OMuint	 		w_count;
  OMuint	 		w_per_elt_size;
  OMbyte                        type;
};
typedef struct OM_sd_varlenarr_defn OM_S_VARLENARR_DEFN;
typedef struct OM_sd_varlenarr_defn *OM_p_VARLENARR_DEFN;

enum   OM_e_classinit
  {
    OM_e_export_init,
    OM_e_import_init
  };

/* new (OM 4.3) inherit structure "from class inherit ..." */

struct OM_sd_inherit
 {
  OMuword	*p_index;
  OMuword	*p_classid;
 };
typedef struct OM_sd_inherit *OM_p_INHERIT;
typedef struct OM_sd_inherit OM_S_INHERIT;

struct OM_sd_override
{
  OMuword 		*p_index;
  int 			(*p_method)();
};
typedef struct OM_sd_override *OM_p_OVERRIDE;
typedef struct OM_sd_override OM_S_OVERRIDE;

/* new (OM 4.0) create class argument list. Support unions and new component
   class structures */
/* define new auxiliary structures... */
/* 1st, define a descriptor for an immediate ancestor */

/* Moved to OMminimum.h 8/10/88 struct OM_sd_ancestry */

/* now, a descriptor for an component class */
/* Aug 20, 1987 plh.  Inherits added here (not in CMS) */
struct OM_sd_CompClassDef
{
  OMuword		NumOverRides;	/* count of overrides in array */
  OMuword		NumInherits;	/* count of "inherits" in array */
  OM_p_OVERRIDE		OverRides;	/* ptr to array of overrides */
  OM_p_INHERIT		Inherits;	/* ptr to array */ 
  OMuword		*p_classid;	/* ptr to classid of this component */
  OMuint		offset;		/* offset in instance for this
					   component */
};
typedef	struct	OM_sd_CompClassDef	OM_S_COMPCLASSDEF;
typedef	struct	OM_sd_CompClassDef	*OM_p_COMPCLASSDEF;


/* now, the create class arguments themselves... */

struct OM_sd_createclass_args
{
/* 1st, a validation area... */

  OMuword 		oppMajVer;	/* Version of opp that opp'd it */
  OMuword 		oppMinVer;
  OMuword 		MajVer;		/* class version numbers */
  OMuword 		MinVer;
  char 			s_name[OM_K_MAXCLASS_LEN];

/* things that go into the new ACLD... */

  OMuint 		InstanceSize;	/* total instance size (less VLAs) */
  OMuint		NewInstanceSize; /* size THIS candidate class defined
					    */
  OM_p_CHANNEL_DEFN 	p_ChannelDefns;	/* New channel defns */
  OM_p_VARLENARR_DEFN 	p_VLAdefns;	/* their descriptions */
  OM_p_METHDEFN 	p_MethDefns;	/* list of method defintions */

/* now, define ancestry information */

  OM_p_ANCESTRY		ancestors;	/* ptr to array of ancestors */

/* and now, component classes */

  OM_p_COMPCLASSDEF	components;	/* ptr to array of them */

/* finally, new candidate dispatch table data */

  OM_p_FUNCPTR		*ClassDispTbl;	/* ptr to opp-generated table of new
					   methods (count is NumMethods) */

/* pointer to class_id variable to be initialized by create_class */
  OMuword		*p_class_id;

/* 8/4/87 plh. Words moved to end for better packing, smaller struct. */
  OMuword 		NumChannels;	/* Number of new channels defined */
  OMuword 		NumVLAs;	/* total numberof VLA's */
  OMuword 		NumMethods;	/* number of new methods */
  OMuword 		NumParents;	/* number of immediate ancestors */
  OMuword		NumComponents;	/* number of them */

  OMuword		oppFlags;	/* ... */
#define OM_CCAf_TAGGABLE	0x1	/* Class is taggable. */

};
typedef struct OM_sd_createclass_args OM_S_CREATECLASS_ARGS;
typedef struct OM_sd_createclass_args *OM_p_CREATECLASS_ARGS;

#endif
