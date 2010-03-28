#ifndef report_include
#define report_include
/*
 *  report.h
 *
 *  This file contains the #defines and structures needed 
 *  by the report methods.
 *  There are different categories of #defines.  
 *  Each category is separated by a comment describing its purpose.
 */

/*
 * Data types
 */
#define GR_string           1        /* 0x00000001   .... .... .... ...1 */
#define GR_int              2        /* 0x00000002   .... .... .... ..1. */
#define GR_double           3        /* 0x00000003   .... .... .... ..11 */
#define GR_point            4        /* 0x00000004   .... .... .... .1.. */
#define GR_matrix           5        /* 0x00000005   .... .... .... .1.1 */

/*
 * Calculable fields to be handled by report function
 */
#define GR_coord_sys        6        /* 0x00000006   .... .... .... .11. */
#define GR_units            7        /* 0x00000007   .... .... .... .111 */
#define GR_coord1           8        /* 0x00000008   .... .... .... 1... */
#define GR_coord2           9        /* 0x00000009   .... .... .... 1..1 */
#define GR_coord3          10        /* 0x0000000A   .... .... .... 1.1. */
#define GR_labeled_double  11        /* 0x0000000B   .... .... .... 1.11 */
#define GR_labeled_point   12        /* 0x0000000C   .... .... .... 11.. */
#define GR_labeled_vector  13        /* 0x0000000D   .... .... .... 11.1 */

/*
 * Output formats
 */
#define GR_area            16        /* 0x00000010   .... .... ...1 .... */
#define GR_angle           32        /* 0x00000020   .... .... ..1. .... */
#define GR_state           48        /* 0x00000030   .... .... ..11 .... */
#define GR_distance        64        /* 0x00000040   .... .... .1.. .... */


/*
 * Additional information to calc
 */
#define GR_vertex         256        /* 0x00000100   .... ...1 .... .... */

/*
 * Output coordinate type
 */
#define GR_local         4096        /* 0x00001000   ...1 .... .... .... */
#define GR_world         8192        /* 0x00002000   ..1. .... .... .... */

/*
 * Properties: ( high order 4 bytes )
 *   GR_numbered: refers to the output of a sequence of labels
 *   such as "Edge 1", "Edge 2", ...
 */
#define GR_editable      65536       /* 0x00010000   .... .... .... ...1 */
#define GR_ele_name     131072       /* 0x00020000   .... .... .... ..1. */
#define GR_numbered     262144       /* 0x00040000   .... .... .... .1.. */

/*
 * Masks for extracting specific bits from report format mask.
 */
#define GR_data_type     0x0000000f  /* Data type mask         */
#define GR_formats       0x000000f0  /* Output format mask     */
#define GR_calc          0x00000f00  /* Additional calc mask   */
#define GR_conversion    0x0000f000  /* Output conversion mask */

/* column flag for GR_labeled_xxx items */
#define  GR_IGNORE_COL         (-1) 

/*
 * Structures used in report object information
 */

struct GRreport_item
{
   IGRint   desc;           /* Msg key for file output      */
   IGRint   label;          /* Report label                 */
   IGRint   row;            /* Row for field                */
   IGRint   col;            /* Column for multicolumn field */
   IGRint   format_mask;    /* Data format                  */
   union 
   {
      IGRint      ivalue;      /* GR_int    */
      IGRdouble   dvalue;      /* GR_double */
      IGRpoint    point;       /* GR_point  */
      IGRmatrix   matrix;      /* GR_matrix */
      IGRchar     string[256]; /* GR_string */
   } GRreport_data;
};

struct GRreport_processor
{
   IGRint  (* report_function)();
   IGRchar  * report_info;                /* Form pointer */
   IGRchar  * report_file;                /* File pointer */
};

/* types for z analyze element */
enum GRanalyze_types {GENERAL, DETAILED, OWNER_LOCATED};

#endif
