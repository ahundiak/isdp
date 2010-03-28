/*\
Description
   This include file represents strutures and typedefs that are used by
   the symbol package.

Files
   igrtypedef.h
   igetypedef.h
   gr.h
   lc.h
   grsymdef.h
\*/

#ifndef grsym_include
#define grsym_include

/*
 *  Structure per attached symbol library.
 */

struct GRsymbol_lib_file
{
   IGRchar file_name[MAX_SYMBOL_LIB_NAME];   
   IGRint  file_no;
   IGRint  file_access;
};

/*
 *  Structure for the active symbol definition.  This structure is
 *  used when retrieving the active symbol.
 */

struct GRactive_symbol_def
{
   IGRchar           name[MAX_SYMBOL_DEF_NAME];
                                 /* active symbol definition name  */
   struct GRmd_env   symbol_env; /* active symbol module env       */
   GRobjid           objid;      /* active symbol definition objid */
};

/*
 *  Structure for the active symbol definition in the DPB.
 */

struct GRasd
{
   IGRlong  time_stamp;                /* The time stamp of the cell    */
   IGRchar  name[MAX_SYMBOL_DEF_NAME]; /* Active symbol definition name */
   IGRint   attachment_num;            /* Index into the array of files */
};

/*
 *  Structures for the DPB symbol libraries and active symbol definition.
 */

struct GRsymbol_info
{
   struct GRsymbol_lib_file  symbol_lib_array[MAX_SYMBOL_LIBS];
   struct GRasd              active_symbols[MAX_ACTIVE_SYMBOLS];
};

/*
 *  Structure defining the class specific attributes of the 
 *  symbol definition header.
 */

struct GRnamdesc
{
   IGRchar  name_symbol[MAX_SYMBOL_DEF_NAME];   /* Symbol name          */
   IGRchar  desc_symbol[MAX_SYMBOL_DEF_DESC];   /* Symbol descripition  */
};

/*
 *  Structure defining the class specific attributes of the 
 *  cell header.
 */

struct GRcell_class_attr
{
   IGRchar  name_symbol[MAX_SYMBOL_DEF_NAME];   /* Symbol name          */
   IGRchar  desc_symbol[MAX_SYMBOL_DEF_DESC];   /* Symbol descripition  */
   IGRlong  time_stamp;
   IGRshort properties;
};

/*
 *  Structures used to define the arguments to the locate action handler 
 */

struct GR_class_locate_action_args
{
   struct GRlc_stack  *stack;
   IGRchar            *classes;
};

struct GR_gg_member_action_args
{
   struct GRlc_stack  *stack;
   struct GRid         gg_id;
};

#endif
