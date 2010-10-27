/* $Id: VDct1Plot.h,v 1.2 2001/01/14 16:11:38 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDct1Plot.h
 *
 * Description: Plot Tree Defination
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Plot.h,v $
 *      Revision 1.2  2001/01/14 16:11:38  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/09 22:17:57  art
 *      ah
 *
 * Revision 1.5  2000/12/01  14:21:24  pinnacle
 * js
 *
 * Revision 1.3  2000/11/30  15:30:50  pinnacle
 * js
 *
 * Revision 1.2  2000/09/20  21:09:44  pinnacle
 * js
 *
 * Revision 1.1  2000/07/11  21:18:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/11/00  ah      Creation
 * 01/12/01  ah      sp17, c friendly
 ***************************************************************************/
#ifndef VDct1Plot_include
#define VDct1Plot_include

/* -------------------------------------------------------------------
 * Usual BS
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* -----------------------------------------------
 * Node and attributes
 */
#define VDCT1_PLOT_NODE_TYPE_DRAWINGS "DRAWINGS"
#define VDCT1_PLOT_NODE_TYPE_DRAWING  "DRAWING"
#define VDCT1_PLOT_NODE_TYPE_SHEET    "SHEET"

// Drawing Node
#define VDCT1_PLOT_ATTR_NAME_CAGE_CODE             "cage_code"
#define VDCT1_PLOT_ATTR_NAME_DRAWING_NUMBER        "drawing_number"
#define VDCT1_PLOT_ATTR_NAME_DRAWING_REV           "drawing_rev"
#define VDCT1_PLOT_ATTR_NAME_NAVSEA_DRAWING_NUMBER "navsea_drawing_number"
#define VDCT1_PLOT_ATTR_NAME_DRAWING_TITLE         "drawing_title"
#define VDCT1_PLOT_ATTR_NAME_DRAWING_TYPE          "drawing_type"
#define VDCT1_PLOT_ATTR_NAME_DRAWING_DATE          "drawing_date"
#define VDCT1_PLOT_ATTR_NAME_SHEET_SIZE            "sheet_size"
#define VDCT1_PLOT_ATTR_NAME_TEAM                  "team"
#define VDCT1_PLOT_ATTR_NAME_POSTING_DATE          "posting_date"
#define VDCT1_PLOT_ATTR_NAME_OBID                  "obid"
#define VDCT1_PLOT_ATTR_NAME_AUTHORIZE_FOR         "authorize_for"
#define VDCT1_PLOT_ATTR_NAME_PREVIOUS_REV          "previous_rev"

// Sheet Node
#define VDCT1_PLOT_ATTR_NAME_SHEET_NUMBER        "sheet_number"
#define VDCT1_PLOT_ATTR_NAME_SHEET_NAME          "sheet_name"
#define VDCT1_PLOT_ATTR_NAME_SHEET_DESCRIPTION   "sheet_description"
#define VDCT1_PLOT_ATTR_NAME_REGISTRATION_STATUS "registration_status"
#define VDCT1_PLOT_ATTR_NAME_REGISTRATION_DATE   "registration_date"
#define VDCT1_PLOT_ATTR_NAME_WINDOW              "window"

/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif
#endif




