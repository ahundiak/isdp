/*\
Description
   This include file represents #defines used by the symbol package.

Notes
   The messages for symbols are defined in the grerr.h include file.
   These message have the package tag for GR messages. The following
   message where defined for symbols:

   GR_E_SDNOTUNIQUE -  Failure, symbol definition is not unique 
                       in the symbol library.
   GR_I_EXCEDBUF    -  Informational, exceeded supplied buffer.
   GR_I_CPXFLATTEN  -  Informational, grouping element was flattened 
                       as it was added.
   GR_I_NODISATTR   -  Informational, display attributes are not
                       defined for the symbol reference.
   GR_I_NOSL        -  Informational, symbol library not found.
\*/

#ifndef grsymdef_include
#define grsymdef_include

#define GRPERROR(msg)            !(msg & 1)

/*
 *  The defines for the setting and inquiry of symbol information.
 */

#  define   GR_SYMBOL_NAME          0
#  define   GR_SYMBOL_DESC          1
#  define   GR_TIME_STAMP           2

#  define MAX_SYMBOL_LIB_NAME       80
#  define MAX_SYMBOL_DEF_NAME       80
#  define MAX_SYMBOL_DEF_DESC       80
#  define MAX_SYMBOL_LIBS           1
#  define MAX_ACTIVE_SYMBOLS        2
#  define MAX_SYMBOL_DEF_INIT       10
#  define MAX_SYM_LIB_APP_STRING    5

#  define GR_SYM_LIB_APP_STRING     "cell"
#  define GR_SD_BTREE_NAME          "gr$sd_btree"
#  define GR_SYM_LIB_MGR            "gr$sym_lib_mgr"

/* 
 *  Defines for symbol parameter block.
 */

#  define  GR_MULTIPLE_SL_TYPE      0
#  define  GR_SINGLE_SL_TYPE        1

#  define  GR_ACTIVE_SYMBOL         0
#  define  GR_ACTIVE_POINT_CELL     1

/* 
 *  The following define signifies if the symbol display attributes 
 *  are used.
 */

#  define GR_SYM_DISPLAY_ATTR       0xe
#  define GR_SYM_COLOR              0x2
#  define GR_SYM_WEIGHT             0x4
#  define GR_SYM_STYLE              0x8

/* 
 *  The following define signifies if the cell geometry should be 
 *  recalulated.
 */

#  define GR_RECALCULATE_GEOM       0x2


/*
 *  The following defines are returned from the retrieve cell library.
 */

#define  GR_E_NO_FILE         2        /* File did not exist            */
#define  GR_E_NO_PREMISSION   4        /* No premission for operation   */
#define  GR_E_NOT_CELL_LIB    6        /* File was not a cell library   */

/*
 *  The following defines are set within the cell library manager.
 */

#define GR_SL_READ_ACCESS           0x1
#define GR_SL_WRITE_ACCESS          0x2
#define GR_SL_READ_WRITE_ACCESS     0x3

#endif
