/*
Name
        grdpb.h

Description
        This file contains structures used by the Default Parameter
        Block subsystem.

Dependencies
	ex.h
	igrtypedef.h
	igrdp.h
	gr.h
	grdpbdef.h

History
        pth     09/08/87    creation
        mrm     05/01/91    2.0.1 changes
        hgb     05/20/93    smart sketch change
*/

#ifndef grdpb_include
#define grdpb_include

#include "ex.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "grdpbdef.h"

struct GRunit_lock
{
    IGRboolean on_off;
    IGRdouble round_off;
};

struct Patrn_area_deltas
{
    IGRdouble x;
    IGRdouble y;
};

struct GRdpb_text_symb
{
    IGRshort	Active_font;
    IGRshort	Active_fraction_font;
    IGRshort	Active_symbol_font;
    IGRshort    Active_ascii_font;
    IGRshort	Active_just;
    IGRdouble	Active_width;
    IGRdouble	Active_height;
    IGRdouble	Active_charspac;
    IGRdouble	Active_linespac;
    IGRshort    Active_flags;  	/* # defines can be found in gotextdef.h */
};

struct GRdpb_scale
{
    IGRdouble Active_xscale;
    IGRdouble Active_yscale;
    IGRdouble Active_zscale;
};

struct GRrgdpb  /* user to store raster data */
{
    IGRshort attr_num;          /* active attribute number              */
    IGRboolean auto_def;        /* mode for determining whether newly   */
                                /* placed raster graphics are auto-     */
                                /* matically defined as "current"       */
    IGRboolean auto_init;       /* mode for determining whether file    */
                                /* raster objects are automatically     */
                                /* "initialized" (read in) on module    */
                                /* wakeup (or alternatively on first    */
                                /* reference of that object             */
    IGRshort rg_props;          /* default raster properties word       */
    IGRdouble row_scale;        /* number of dits/record in placement   */
                                /* window for raster row                */
    IGRdouble column_scale;     /* number of dits/record in placement   */
                                /* window for raster column             */
    IGRlong comprast_memory;    /* amount of memory a composite raster  */
                                /* object may occupy                    */
    IGRint brush_type;          /* raster brush type */
    IGRshort fg;                /* background */
    IGRshort bg;                /* foreground */
    IGRboolean fill_mode;
};

struct GRhesym  /* hidden edge symbology */
{
    IGRushort color;
    IGRuchar weight;
    IGRuchar style;
    IGRushort flags;
};

struct GRdpbdata    /* used to map GRdpb->data vla */
{
    IGRshort version;                   /* dpb version number */
    IGRchar dbtype[MAX_DB_TYPE_SIZE];   /* database type - "2d" or "3d" */
    IGRchar model_mode;                 /* modeling mode */
    IGRchar proj_angle;                 /* projection angle */
    IGRchar cstype[MAX_CS_TYPE];        /* coordinate system type */
    IGRshort bflags;                    /* boolean flags */
    IGRshort name_mode;                 /* name mode */
    IGRshort layer;                     /* layer */
    IGRshort objprops;                  /* graphic object properties */
    IGRlong locate_layers[32];          /* locate layers */
    IGRlong hidsurfsym;                 /* hidden surface symbology */
    IGRlong locprops;                   /* locate properties */
    IGRdouble epdelta;                  /* edge pattern delta */
    IGRdouble apdelta[2];               /* area pattern deltas */
    IGRdouble angle;                    /* angle in radians */
    IGRdouble dit_tol;                  /* dit tolerance for locate */
    IGRdouble cht;                      /* chord height tolerance */
    IGRdouble offset_tol;               /* offset tolerance */
    IGRdouble arc_tol;                  /* arclength tolerance */
    IGRdouble bastol;                   /* basis tolerance */
    IGRdouble maxstep;                  /* maximum step size */
    IGRdouble xhatch_spacing;           /* crosshatch spacing */
    IGRdouble xhatch_angle;             /* crosshatch angle */
    IGRdouble scale[3];                 /* x, y, and z scale */
    struct GRdpb_text_symb textsym;     /* text symbology */
    struct EX_button lastpoint;         /* last data point entered by user */
    struct GRmd_env module;             /* active module environment */
    struct GRrgdpb raster;              /* raster information */
    struct GRunit_lock unit_lock;       /* unit lock */
    struct IGRdisplay display;          /* display attributes */
    struct GRhesym hesym;               /* hidden edge symbology */
    struct GRhesym visible_edge_sym;    /* visible edge symbology */
    int SmartSketchOn;			/* Smart Sketch ins ON or OFF */
    int EligibleConstraints;		/* eligible constraints for Smart Sketch */
};

/*
 * Added this for transos conversion of pre-EMS3 object spaces. Old object
 * spaces will have an older version of the dpb in them. Whenever a new 
 * value is added to the 'struct GRdpbdata' you will have to copy the old one
 * and rename it. Then edit the $GRNUC/dict/dpb_data.T and 
 * $GRNUC/src/transos/GRdpb_sp.c to convert the correct version of the dpb.
 * TR 119313399 - Doree  11/23/93.
 */

struct GRdpbdata0
{
    IGRshort version;                   /* dpb version number */
    IGRchar dbtype[MAX_DB_TYPE_SIZE];   /* database type - "2d" or "3d" */
    IGRchar model_mode;                 /* modeling mode */
    IGRchar proj_angle;                 /* projection angle */
    IGRchar cstype[MAX_CS_TYPE];        /* coordinate system type */
    IGRshort bflags;                    /* boolean flags */
    IGRshort name_mode;                 /* name mode */
    IGRshort layer;                     /* layer */
    IGRshort objprops;                  /* graphic object properties */
    IGRlong locate_layers[32];          /* locate layers */
    IGRlong hidsurfsym;                 /* hidden surface symbology */
    IGRlong locprops;                   /* locate properties */
    IGRdouble epdelta;                  /* edge pattern delta */
    IGRdouble apdelta[2];               /* area pattern deltas */
    IGRdouble angle;                    /* angle in radians */
    IGRdouble dit_tol;                  /* dit tolerance for locate */
    IGRdouble cht;                      /* chord height tolerance */
    IGRdouble offset_tol;               /* offset tolerance */
    IGRdouble arc_tol;                  /* arclength tolerance */
    IGRdouble bastol;                   /* basis tolerance */
    IGRdouble maxstep;                  /* maximum step size */
    IGRdouble xhatch_spacing;           /* crosshatch spacing */
    IGRdouble xhatch_angle;             /* crosshatch angle */
    IGRdouble scale[3];                 /* x, y, and z scale */
    struct GRdpb_text_symb textsym;     /* text symbology */
    struct EX_button lastpoint;         /* last data point entered by user */
    struct GRmd_env module;             /* active module environment */
    struct GRrgdpb raster;              /* raster information */
    struct GRunit_lock unit_lock;       /* unit lock */
    struct IGRdisplay display;          /* display attributes */
    struct GRhesym hesym;               /* hidden edge symbology */
};

struct GRdpbdata1
{
    IGRshort version;                   /* dpb version number */
    IGRchar dbtype[MAX_DB_TYPE_SIZE];   /* database type - "2d" or "3d" */
    IGRchar model_mode;                 /* modeling mode */
    IGRchar proj_angle;                 /* projection angle */
    IGRchar cstype[MAX_CS_TYPE];        /* coordinate system type */
    IGRshort bflags;                    /* boolean flags */
    IGRshort name_mode;                 /* name mode */
    IGRshort layer;                     /* layer */
    IGRshort objprops;                  /* graphic object properties */
    IGRlong locate_layers[32];          /* locate layers */
    IGRlong hidsurfsym;                 /* hidden surface symbology */
    IGRlong locprops;                   /* locate properties */
    IGRdouble epdelta;                  /* edge pattern delta */
    IGRdouble apdelta[2];               /* area pattern deltas */
    IGRdouble angle;                    /* angle in radians */
    IGRdouble dit_tol;                  /* dit tolerance for locate */
    IGRdouble cht;                      /* chord height tolerance */
    IGRdouble offset_tol;               /* offset tolerance */
    IGRdouble arc_tol;                  /* arclength tolerance */
    IGRdouble bastol;                   /* basis tolerance */
    IGRdouble maxstep;                  /* maximum step size */
    IGRdouble xhatch_spacing;           /* crosshatch spacing */
    IGRdouble xhatch_angle;             /* crosshatch angle */
    IGRdouble scale[3];                 /* x, y, and z scale */
    struct GRdpb_text_symb textsym;     /* text symbology */
    struct EX_button lastpoint;         /* last data point entered by user */
    struct GRmd_env module;             /* active module environment */
    struct GRrgdpb raster;              /* raster information */
    struct GRunit_lock unit_lock;       /* unit lock */
    struct IGRdisplay display;          /* display attributes */
    struct GRhesym hesym;               /* hidden edge symbology */
    struct GRhesym visible_edge_sym;    /* visible edge symbology */
};

struct GRdpb_notify /* used to pass change notification info to dependents */
{
    IGRint parameter;
    IGRchar *value;
};

struct GRelclass    /* used to store class locate eligibility info */
{
    IGRchar ascii_key[16];      /* ASCII message key for [meta]class name */
    IGRshort properties;        /* locatable/nonlocatable */
    IGRshort depth;             /* degree of nesting on form */
    IGRint index;               /* into classids array */
    OM_S_CLASSLIST classlist;   /* classlist representing info */
};

struct GRelclass_f  /* subset of GRelclass, for cases when index and
                       classlist are unnecessary or meaningless, such as
                       when filling in the eligibility form */
{
    IGRchar ascii_key[16];
    IGRshort properties;
    IGRshort depth;
};

struct GRelclass_a  /* used in lc$add_class to add GRelclass structs to dpb */
{
    IGRchar *ascii_key;         /* ASCII message key for [meta]class name */
    IGRchar *owner_key;         /* ASCII message key for owner */
    IGRshort properties;        /* locatable/nonlocatable */
    OM_S_CLASSLIST *classlist;  /* classlist representing info */
};

#endif
