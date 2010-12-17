/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Header: /usr2/pinnacle/division/nfmspc/nfm/mstninc/RCS/refernce.h 1.1 1995/10/17 23:24:04 pinnacle Exp $
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
| Copyright (C) 1985-90   Bentley Systems, Inc., All rights reserved.	|
|									|
| "MicroStation", "MDL", and "MicroCSL" are trademarks of Bentley	|
|  Systems, Inc. and/or Intergraph Corporation. 			|
|									|
|  This program may NOT be copied in part or in whole on any medium,	|
|  either electronic or printed, without the express written consent	|
|  of Bentley Systems, Inc.						|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   refernce.h --							|
|									|
+----------------------------------------------------------------------*/
#if !defined (__refernceH__)
#define __refernceH__

/* .h file dependencies */ 
#if !defined (__mstypesH__)
#   include    <mstypes.h>
#endif

/*----------------------------------------------------------------------+
|									|
|									|
|									|
+----------------------------------------------------------------------*/
typedef struct file_id_descr
    {
    char  dev_name[8];	    /* device name */
    short file_attr;	    /* file attributes */
    short file_chars;	    /* number of characters in file spec */
    char  file_spec[66];    /* file specification */
    long  cache_slot;	    /* corresponding slot in cache */
    char  pc_spec[MAXFILELENGTH]; /* Full specification for file */
    } File_id_desc;

typedef struct ref_display
    {
    short  file_num;	    /* file number */
    Fb_opts fb_opts;	    /* file builder options mask */
    Fd_opts fd_opts;	    /* file displayer options mask */
    short  trm_opts;	    /* terminal options mask */
    short disp_flags[8];    /* display flags */
    short  lev_flags[8][4]; /* level on/of flags */
    Point3d mast_org;
    Point3d ref_org;
    double scale;
    byte   tds_levs[8];	    /* levels currently in TDS */
    double trns_mtrx[9];
    } Ref_display;


typedef struct ref_attatch_desc
    {
    short log_chars;        /* characters in logical name */
    char  log_name[22];	    /* logical name */
    short desc_chars;	    /* characters in description */
    char  description[42];  /* description */
    } Ref_attach_desc;


typedef struct lev_symb_desc
    {
    short lev_sym_mask;	    /* level symbology enable mask */
    short lev_sym[63];	    /* level symbology descriptor */	
    } Lev_symb_desc;
    

typedef struct unit_desc
    {
    unsigned long master_units;	    /* master units per file */
    unsigned long sub_per_mast;	    /* sub-units per master unit */
    unsigned long uor_per_sub;	    /* units of resolution per sub-unit */
    char mu_name[2];		    /* master unit name */
    char su_name[2];		    /* sub unit name */
    } Unit_desc;


typedef struct clip_desc
    {
    long z_delta;		    /* Z-direction delta */
    short clip_vertices;    	    /* clipping vertices */
    Point2d *clipP;		    /* pointer to clipping points */
    } Clip_desc;
    
    
typedef struct referenceFile
    {
    File_id_desc    file_id;	    /* file identification */
    Ref_display     display;	    /* display information */
    Ref_attach_desc attach;	    /* attachment description */
    Lev_symb_desc   levsymb;	    /* level symbology description */
    Unit_desc	    units;	    /* units description */
    Clip_desc	    clip;	    /* clipping descriptor(points separate) */
    byte	    *colorMap[2];  /* element to screen color mappings */
    } ReferenceFile, Reference_file;

typedef struct tmp_referencefile
    {
    short handle;
    short slot;
    } Tmp_referencefile;
#endif
