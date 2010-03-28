#ifndef UOM_included
#define UOM_included 1

/*
**	Struct defs for memory resident unit information.
**
**	File dependencies:
**
**		UOMdef.h
**		igrtypedef.h
**		griodef.h
*/

typedef char UOMtype_name[ UOM_K_MAX_TYPE ];
typedef char UOMdimensions[ UOM_K_MAX_DIMS ];

  /* allow alias to be fully qualified ie. "mm:distance" */
typedef char UOMalias_name[ UOM_K_MAX_ALIAS + UOM_K_MAX_TYPE + 1 ];

  /* non-qualified aliases are stored in super */
typedef char UOMsalias_name[ UOM_K_MAX_ALIAS ];

/*
 * UOM type/variant structures
 */
struct UOM_readout {
  int   mode;                      /* defaults to UOM_DECIMAL            */
  short precision;                 /* Number of places to the right of   */
                                   /* the decimal character in           */
                                   /* UOM_DECIMAL mode.                  */
                                   /* defaults to 4 (.0001)              */
  short denominator;               /* UOM_FRACTIONAL mode denominator.   */
                                   /* defaults to 16 (1/16)              */
  short intermeas_spacing;         /* # spaces between measurements      */
                                   /* ex. 2 spaces: 2 ft  1 in           */
                                   /* ex. 3 spaces: 2 ft   1 in          */
                                   /* defaults to 2 spaces               */
  short intrameas_spacing;         /* # spaces between number and alias  */
                                   /* ex 1 spaces: 1 ft  2 in            */
                                   /* ex 0 spaces: 1ft  2in              */
                                   /* defaults to 1 space                */
  char  justification;             /* defaults to UOM_LEFT_JUSTIFY       */
  char  case_type;                 /* defaults to UOM_DEFAULT_CASE       */
  char  decimal_char;              /* defaults to UOM_PERIOD             */
  char  thousands_char;            /* defaults to UOM_NONE, no character */
  char  left_fill_char;            /* defaults to a space                */
  char  alias_displayed;           /* defaults to TRUE                   */
  char  leading_zeros;             /* TRUE, FALSE: defaults to FALSE     */
  char  trailing_zeros;            /* TRUE, FALSE: defaults to FALSE     */
};
typedef struct UOM_readout UOM_READOUT;

  /* NOTE: circular list */
struct UOM_variant {
  struct UOM_variant  *next;       /* next in linked list                */
  struct UOM_variant  *prev;       /* previous in linked list            */
  short               flags;       /* UOM_UC_xxx & UOM_TS_xxx #defines   */
  double              scale;       /* to convert to data base units      */
  UOMsalias_name      scaleunits;
  double              shift;       /* to convert to data base units      */
  UOMsalias_name      shiftunits;
  char                **alias;     /* array of alias pointers            */
  struct UOM_type     *type;       /* Pointer to my unit type            */
};
typedef struct UOM_variant UOM_VARIANT;

  /* NOTE: circular list */
struct UOM_type {
  struct UOM_type     *next;       /* next in linked list                */
  struct UOM_type     *prev;       /* previous in linked list            */
  UOMtype_name        name;        /* the unit name                      */
  char                **defalias;  /* the default unit aliases           */
  struct UOM_variant  *variant;    /* list of variants                   */
  UOMdimensions       dims;        /* type dimensions                    */
  struct UOM_readout  primary;     /* primary readout specifications     */
  struct UOM_readout  secondary;   /* secondary readout specifications   */
  struct UOM_readout  tertiary;    /* tertiary readout specifications    */
  short               flags;       /* UOM_TS_xxx #defines                */
  char                *aliashashtab;
};
typedef struct UOM_type UOM_TYPE;

struct UOM_type_hash {
  UOMtype_name name;
  UOM_TYPE *type;
};
typedef struct UOM_type_hash UOM_TYPE_HASH;

struct UOM_dims_hash {
  UOMdimensions dims;
  UOM_TYPE *type;
};
typedef struct UOM_dims_hash UOM_DIMS_HASH;

struct UOM_alias_hash {
  UOMsalias_name name;
  UOM_VARIANT *variant;
};
typedef struct UOM_alias_hash UOM_ALIAS_HASH;

struct UOM_dimkeyword {
  char keyword[ UOM_K_MAX_KEYWORD ];
  int type;
};
typedef struct UOM_dimkeyword UOM_DIMKEYWORD;

/*
 * UOM super structures
 */
struct UOMS_type {
  UOMtype_name name;               /* name of unit type                     */
  UOMdimensions dims;              /* dimensions                            */
  UOMsalias_name defalias[ UOM_K_MAX_DEFS ];
                                   /* default aliases.  array is terminated */
                                   /* by null string.                       */
  struct UOM_readout primary;      /* primary readout specifications        */
  struct UOM_readout secondary;    /* secondary readout specifications      */
  struct UOM_readout tertiary;     /* tertiary readout specifications       */
};
typedef struct UOMS_type UOMS_TYPE;

struct UOMS_variant {
  int    pkey;                     /* index of aliases in pkey table        */
  int    type;                     /* index of unit type in type table      */
  double scale;                    /* scale factor to convert to dbu's      */
  double shift;                    /* shift factor to convert to dbu's      */
};
typedef struct UOMS_variant UOMS_VARIANT;

#endif          /* #ifndef UOM_included above */
