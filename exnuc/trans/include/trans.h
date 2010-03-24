/*
**     dros header file for ddp structures
*/

#define DROS_K_CLASSNAME_MAX    32
#define DROS_K_CHANNAME_MAX     32
#define DROS_K_FIELDNAME_MAX    32
#define DROS_K_ATTRNAME_MAX     32
#define DROS_K_CTYPENAME_MAX    32
#define DROS_K_CHTYPENAME_MAX   32


/* generic node types */

#define DROS_ATTR_TYPE           1
#define DROS_CHAN_TYPE           2


/* types */

#define DROS_ENDBLOCK_CODE		-1
#define DROS_NULL_CODE			0
#define DROS_CHAR_CODE			1
#define DROS_UCHAR_CODE			2
#define DROS_SHORT_CODE			3
#define DROS_USHORT_CODE		4
#define DROS_INT_CODE			5
#define DROS_UINT_CODE			6
#define DROS_LONG_CODE			7
#define DROS_ULONG_CODE			8
#define DROS_FLOAT_CODE			9
#define DROS_DOUBLE_CODE		10
#define DROS_STRING_CODE		11
#define DROS_CHANNEL_CODE		12
#define DROS_POINTER_CODE		13
#define DROS_ARRAY_CODE			14
#define DROS_VARARRAY_CODE		15
#define DROS_BITFIELD_CODE		16
#define DROS_FUNCTION_CODE		17
#define DROS_STRUCT_CODE		18
#define DROS_UNION_CODE			19
#define DROS_ENUMERATION_CODE		20
#define DROS_ENUM_FIELD_CODE		21
#define DROS_CLASS_CODE 		22
#define DROS_NUM_CODES			23


/*  channel types (from OMminimum.h)  */

#define         DROS_sing		0x1
#define		DROS_1_1		0x2
#define 	DROS_m_1		0x4
#define 	DROS_1_m		0x8
#define 	DROS_m_m		0x10
#define 	DROS_abs		0x20
#define 	DROS_rel		0x40
#define		DROS_ful		0x80
#define		DROS_toobj		0x100
#define		DROS_pre		0x200
#define		DROS_res 		0x400
#define		DROS_inuse		0x800
#define		DROS_tail		0x1000
#define		DROS_coll		0x2000
#define		DROS_big		0x4000

struct dros_row_info {
   unsigned short  type;
   unsigned short  row;
   int            *p_info;
};

enum dros_struct_type {
	character,
	integer,
	namenode_struct,
	parent_struct,
	reject_struct,
	channel_struct,
	rest_struct,
	chtype_struct,
	ctype_struct,
	field_struct,
	attr_struct
};

/*  structure defs for instance data definition  */

typedef struct dros_sd_parent  *DROS_p_PARENT;
typedef struct dros_sd_reject  *DROS_p_REJECT;
typedef struct dros_sd_channel *DROS_p_CHANNEL;
typedef struct dros_sd_rest    *DROS_p_REST;
typedef struct dros_sd_chtype  *DROS_p_CHTYPE;
typedef struct dros_sd_ctype   *DROS_p_CTYPE;
typedef struct dros_sd_field   *DROS_p_FIELD;
typedef struct dros_sd_attr    *DROS_p_ATTR;

struct dros_sd_parent {
   unsigned short major;                        /* major version           */
   unsigned short minor;                        /* minor version           */
   DROS_p_PARENT  p_next;                       /* ptr to next parent      */
   char           *class;                     /* change to classid later */
};
typedef struct dros_sd_parent DROS_S_PARENT;

struct dros_sd_reject {
   unsigned short major;                        /* major version           */
   unsigned short minor;                        /* minor version           */
   DROS_p_REJECT  p_next;                       /* ptr to next parent      */
   char           *class;                     /* change to classid later */
};
typedef struct dros_sd_reject DROS_S_REJECT;

struct dros_sd_rest {
   char        *class;				/* change to classid later */
   char        *chan;       			/* channel name            */
   DROS_p_REST p_next;                          /* ptr to next restriction */
};
typedef struct dros_sd_rest DROS_S_REST;

struct dros_sd_field {
   int            offset;                       /* offset                  */
   int            size;                         /* size (bytes)            */
   DROS_p_CTYPE   p_ctype;                      /* ptr to major ctype      */
   unsigned int  *p_list;                       /* ptr to ctype list       */
   DROS_p_FIELD   p_next;                       /* ptr to next field       */
   unsigned short list_size;                    /* ctype list size         */
   char           *name;                      /* field name              */
};
typedef struct dros_sd_field DROS_S_FIELD;

struct dros_sd_ctype {
   int            size;                         /* size (bytes)            */
   DROS_p_FIELD   p_field;                      /* ptr to typefields       */
   DROS_p_CTYPE   p_next;                       /* ptr to next ctype       */
   unsigned short code;                         /* typefield code          */
   char           *name;                      /* ctype name              */
};
typedef struct dros_sd_ctype DROS_S_CTYPE;

struct dros_sd_attr {
   short          node_type;                    /* generic node id         */
   unsigned short list_size;                    /* ctype list size         */
   int            offset;                       /* offset                  */
   int            size;                         /* size (bytes)            */
   DROS_p_CTYPE   p_ctype;                      /* ptr to major ctype      */
   unsigned int  *p_list;                       /* ptr to ctype list       */
   short         *p_next;                       /* ptr to next generic     */
   char          *name;                      /* attribute name          */
};
typedef struct dros_sd_attr DROS_S_ATTR;

struct dros_sd_chtype {
   int            init;                         /* initial size            */
   int            incr;                         /* extend size             */
   DROS_p_REST    p_rest;                       /* ptr to restrictions     */
   DROS_p_CHTYPE  p_next;                       /* ptr to next chtype      */
   unsigned short type;                         /* actual channel type     */
   char           *name;                      /* channel type name       */
};
typedef struct dros_sd_chtype DROS_S_CHTYPE;

struct dros_sd_channel {
   short          node_type;                    /* generic node id         */
   int            offset;                       /* offset (bytes)          */
   DROS_p_CHTYPE  p_chtype;                     /* ptr to channel type     */
   short         *p_next;                       /* ptr to next generic     */
   char          *name;                      /* channel name            */
};
typedef struct dros_sd_channel DROS_S_CHANNEL;

struct dros_sd_class {
   char           *class;			/* change to classid later */
   int            size;                         /* size of instance        */
   unsigned short major;                        /* major version           */
   unsigned short minor;                        /* minor version           */
   short         *p_node;                       /* ptr to generic node     */
   DROS_p_CTYPE   p_ctype;                      /* ptr to ctypes           */
   DROS_p_CHTYPE  p_chtype;                     /* ptr to channel types    */
   DROS_p_PARENT  p_parent;                     /* ptr to parents          */
   DROS_p_REJECT  p_reject;                     /* ptr to rejected inst    */
   int		  flag;
};
typedef struct dros_sd_class DROS_S_CLASS;
typedef struct dros_sd_class *DROS_p_CLASS;


/*  macros  */

#define GETSIZ(typ,str,siz) siz=sizeof(typ)+strlen(str)

#define check_status(sts) \
	if (!sts) { \
		fprintf(stderr, "\nError at line %d in file %s\n", \
			__LINE__,__FILE__); \
		return(sts); \
	}
