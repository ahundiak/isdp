#ifndef ASSEM_H
#define ASSEM_H

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: Member Info Structure                                            |
 |                                                                           |
 | The following typdef defines a structure that is used to set and get      |
 | member info.                                                              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct EMmemb_st
{
    IGRint      type;           /* Member's type, defined in assemdef.h. */
    IGRchar     name[MAX_NAME]; /* Member's name. */
    IGRchar     desc[MAX_DESC]; /* Description of the member. */
    IGRint      index;          /* Index of the member in the directory. */
    struct GRid id;             /* Member's id. */
} EMmemb;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: Attribute Value Structure                                        |
 |                                                                           |
 | The following typdef defines a structure that is used to set and get      |
 | attribute value.                                                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct EMvalue_st
{
    IGRint    type;               /* EM_INTEGER, EM_DOUBLE, EM_STRING */
    IGRchar   syntax[MAX_VALUE];
    union
    {
        IGRchar   s[MAX_VALUE];
        IGRint    i;
        IGRdouble d;
    } data;
} EMvalue;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: Attribute Structure                                              |
 |                                                                           |
 | The following typdef defines a structure that is used to set and get      |
 | attributes.                                                               |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct EMattr_st
{
    EMmemb    info;
    EMvalue   value;
} EMattr;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: EMdescribe EMconstruct Structure                                 |
 |                                                                           |
 | The following typdef defines a structure which is used to construct a     |
 | EMdescribe object. This will be used by the GRconstruct method on         |
 | EMdescribe.                                                               |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct EMdescribe_class_attr_st
{
    IGRuint       props;               /* Properties. */
    IGRchar     * directory;           /* Directory in which to create. */
    IGRchar     * name;                /* Name of describe object. */
    struct GRid * feature_id;          /* Object to describe. */
    IGRchar     * feature_name;        /* Locate name for feature. */
    IGRint        num_attributes;      /* Number of attributes. */
    EMattr      * attributes;          /* Attributes which describe graphic. */
} EMdescribe_class_attr;


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: EMlocalpart EMconstruct Structure                                |
 |                                                                           |
 | The following typdef defines a structure which is used to construct a     |
 | EMlocalpart object. This will be used by the EMconstruct method on        |
 | EMlocalpart.                                                              |
 |                                                                           |
 | File Part Arguments:                                                      |
 |      IGRuint   props                                                      |
 |      IGRchar * number        Number and revision will be used to find the |
 |      IGRchar * revision      filename in the directory system.            |
 |                                                                           |
 | Local Part Arguments:                                                     |
 |      IGRuint   props                                                      |
 |      IGRchar * number        Number and revision will be used to find the |
 |      IGRchar * revision      filename in the directory system.            |
 |      IGRchar * layers_string Layers assigned to part, "1-4,5,10", etc..   |
 |  or  IGRlong * layers        Layers bit mask. 32 IGRlongs.                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct EMlocalpart_class_attr_st
{
    IGRuint   props;            /* Properties */
    IGRchar * number;           /* Part number */
    IGRchar * revision;         /* Part revision */
    IGRint    num_attrs;        /* Number of additional attributes to add. */
    EMattr  * attrs;            /* Attributes to add. */
    IGRlong * layers;           /* Assigned layers. */
} EMlocalpart_class_attr;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: EMcachepart EMconstruct Structure                                |
 |                                                                           |
 | The following typdef defines a structure which is used to construct a     |
 | EMcachepart object. This will be used by the EMconstruct method on        |
 | EMcachepart.                                                              |
 |                                                                           |
 | Different sets of structure members are used in defining the part         |
 | depending on the type of part being created. The type of the part         |
 | is determined by and'ing the props with EM_PART_TYPES.                    |
 |                                                                           |
 | Graphic, Non Graphic and File Parts:                                      |
 |      IGRuint   props                                                      |
 |      IGRchar * number                                                     |
 |      IGRchar * revision                                                   |
 |      IGRint  * num_attrs                                                  |
 |      EMattr  * attrs                                                      |
 |                                                                           |
 | Reference Part Arguments:                                                 |
 |      IGRuint   props                                                      |
 |      IGRchar * filename    Model filename where part is defined.          |
 |   or                                                                      |
 |      IGRchar * number      Number and revision will be used to find the   |
 |      IGRchar * revision    filename in the directory system.              |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct EMcachepart_class_attr_st
{
    IGRuint   props;      /* Properties */
    IGRchar * database;   /* Database for retrieve. Not used yet. */
    IGRchar * catalog;    /* Catalog where parts are stored.. Not used yet.*/
    IGRchar * number;     /* Part number */
    IGRchar * revision;   /* Part revision */
    IGRchar * filename;   /* Filename part is stored in. Optional. */
    IGRchar * view;       /* Default saved view to use for attachment. */
    IGRchar * entry;      /* Macro or cell entry in filename. Not used yet. */
    IGRint    num_attrs;  /* Number of additional attributes to add. */
    EMattr  * attrs;      /* Attributes to add. */
    struct GRid * ref_id; /* Temporary reffile output. */
} EMcachepart_class_attr;


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Typedef: EMinstance GRconstruct Structure                                 |
 |                                                                           |
 | The following typdef defines a structure which is used to construct a     |
 | EMinstance object. This will be used by the GRconstruct method on         |
 | EMinstance.                                                               |
 |                                                                           |
 | Different sets of structure members are used in creating the instance     |
 | depending on the type of part being used to create the instance. The type |
 | of the part is determined by sending the EMget_props message to the part. |
 |                                                                           |
 | Graphic Parts:                                                            |
 |      IGRuint       props                                                  |
 |      struct GRid * part_id                                                |
 |      struct GRid * graphic_id                                             |
 |      IGRint        quantity                                               |
 |   or                                                                      |
 |      IGRuint       props                                                  |
 |      IGRchar     * number      Lookup up existing part id, create it if   |
 |      IGRchar     * revision    it doesn't exist.                          |
 |      struct GRid * graphic_id                                             |
 |      IGRint        quantity                                               |
 |                                                                           |
 | Non Graphic Parts:                                                        |
 |      IGRuint       props                                                  |
 |      struct GRid * part_id                                                |
 |      IGRint        quantity                                               |
 |   or                                                                      |
 |      IGRuint       props                                                  |
 |      IGRchar     * number      Lookup up existing part id, create it if   |
 |      IGRchar     * revision    doesn't exist.                             |
 |      IGRint        quantity                                               |
 |                                                                           |
 | Reference Part Arguments:                                                 |
 |      IGRuint       props                                                  |
 |      IGRchar     * filename    Model filename where part is defined.      |
 |      IGRchar     * view        Saved view to use for attachement. Opt.    |
 |      IGRdouble   * origin                                                 |
 |      IGRdouble   * matrix                                                 |
 |      IGRint        quantity                                               |
 |   or                                                                      |
 |      IGRuint       props                                                  |
 |      IGRchar     * number      Number and revision will be used to find   |
 |      IGRchar     * revision    the filename in the directory system.      |
 |      IGRchar     * view        Saved view to use for attachement. Opt.    |
 |      IGRdouble   * origin                                                 |
 |      IGRdouble   * matrix                                                 |
 |      IGRint        quantity                                               |
 |   or                                                                      |
 |      IGRuint       props                                                  |
 |      struct GRid * part_id     Id of the part to create instance from.    |
 |      IGRchar     * view        Saved view to use for attachement. Opt.    |
 |      IGRdouble   * origin                                                 |
 |      IGRdouble   * matrix                                                 |
 |      IGRint        quantity                                               |
 |                                                                           |
 | Macro Part Arguments:      NOT IMPLEMENTED YET.                           |
 |                                                                           |
 | Cell Part Arguments:       NOT IMPLEMENTED YET.                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct EMinstance_class_attr_st
{
    IGRuint         props;          /* Properties */
    struct GRid   * part_id;        /* Part definition object. */
    IGRchar       * filename;       /* Model filename part definition is in. */
    IGRchar       * view;           /* Saved view to use for attachment. */
    IGRchar       * number;         /* Part number. */
    IGRchar       * revision;       /* Part revision. */
    IGRint          num_graphics;   /* Number of graphic objects. */
    struct GRid   * graphic_ids;    /* Instance graphic object ids. */
    IGRdouble     * origin;         /* Placement origin */
    IGRdouble     * matrix;         /* Rotation matrix. */
    IGRint          quantity;       /* Number of instances to represent. */
    IGRint          num_attributes; /* Number of additional user attributes. */
    EMattr        * attributes;     /* User attributes. */
} EMinstance_class_attr;



/*
 * The following data structure provides info about the located
 * feature.
 * KS 7/29
 */


typedef struct feature_information
{
  struct GRid grid;                   /* feature grid */
  struct GRmd_env lc_env;     /* feature locate env */
} FEATURE_INFO;


/*---------------------------------------------------------------------------+
 |                                                                           |
 |  Typedef : Assembly Tree Structure                                        |
 |                                                                           |
 |  The following typedef defines a structure which is used to construct an  |
 |  assembly tree.                                                           |
 |                                                                           |
 +---------------------------------------------------------------------------*/
typedef struct _ASMtree
{
  struct _ASMtree  *parent;   /* assembly in which this part is placed */
  struct _ASMtree  *next;     /* next part in the Bill of Material */
  struct _ASMtree  *child;    /* part placed in this assembly */
  struct _ASMtree  *sibling;  /* next part placed in the parent assembly */
                              /* of this part */
  struct GRid      part_id;   /* GRid of the part */
  struct GRid      cntxt_id;  /* master file context of the part */
  IGRuint          props;     /* part properties */
  IGRint           depth;                   /* part depth */
  IGRchar          filename[DI_PATH_MAX];   /* filename of the filepart */
  IGRshort         old_state;               /* old_state and new_state are */
  IGRshort         new_state;               /* for manage assembly interfcae */
} ASM_tree;

typedef struct _EMPartInfo
{
  IGRchar number[MAX_VALUE];
  IGRchar revision[MAX_VALUE];
  IGRchar description[MAX_VALUE];
  IGRchar filename[DI_PATH_MAX];
} EMPartInfo;

#endif
