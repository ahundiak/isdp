/* $Id: VDct1Trace.h,v 1.2 2001/10/03 14:10:19 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDct1Trace.h
 *
 * Description: Custom tracing for vdct1
 *
 *
 * Revision History:
 *      $Log: VDct1Trace.h,v $
 *      Revision 1.2  2001/10/03 14:10:19  jdsauby
 *      JTSMP CR 5571
 *
 *      Revision 1.1  2001/01/09 22:17:57  art
 *      ah
 *
 * Revision 1.3  2000/11/16  20:18:22  pinnacle
 * pn
 *
 * Revision 1.2  2000/08/25  19:54:12  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/17  11:15:48  pinnacle
 * Created: vds/include/VDct1Trace.h by jdsauby for Service Pack
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/16/00  js      Created
 ***************************************************************************/

#ifndef VDct1Trace_include
#define VDct1Trace_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------
 * Choices for setting trace flags
 * VDCT1_TRACE     -> Traces ALL
 *
 * Command Object Tracing
 * VDCT1_CMD_TRACE  -> Traces Entire command object
 * VDCT1_ATTR_TRACE -> Attributes
 * VDCT1_LIB_TRACE  -> Library
 * VDCT1_MGR_TRACE  -> Manager
 * VDCT1_NODE_TRACE -> Node
 * VDCT1_PART_TRACE -> Parts
 * VDCT1_SET_TRACE  -> Sets
 * VDCT1_TREE_TRACE -> Tree
 * VDCT1_TREEF_TRACE-> TreeF
 * VDCT1_ROOT_TRACE -> Root
 *
 * if any of the above are set, then this one will be
 * set as well.  Or, you can just set this one
 * VDCT1_CTEST_TRACE-> Command Testing
 *
 * Tree Object Tracing.  If a trace is set for a tree,
 * then all trees below will be set.  IE, setting trace
 * for EngrTree, will set tracing on for all Trees
 * that are of the EngrTree Class.
 * VDCT1_BASE_TRACE  -> Gets them all
 * VDCT1_COM_TRACE   -> Command and down
 * VDCT1_PROD_TRACE  -> Production
 * VDCT1_XML_TRACE   -> XML
 * VDCT1_PLOT_TRACE  -> Plot
 * VDCT1_PAL_TRACE   -> pallet
 * VDCT1_ASSY_TRACE  -> Std Assy
 * VDCT1_PART_TRACE  -> Std parts (OPS)
 * VDCT1_ENGR_TRACE  -> Engineering
 * VDCT1_OFT_TRACE   -> outfit
 * VDCT1_CABLE_TRACE -> cable
 * VDCT1_WWAY_TRACE  -> wway
 * VDCT1_HVAC_TRACE  -> hvac
 * VDCT1_PIPE_TRACE  -> pipe
 *
 * if any of the above are set, then this one will be
 * set as well.  Or, you can just set this one
 * VDCT1_TTEST_TRACE -> Tree testing
 *
 * thats all
 */ 


/* ----------------------------------------------------
 * define traces
 */

  // command
#define VDCT1_TRACE_CMD_ATTR   "VDct1Attr"
#define VDCT1_TRACE_CMD_LIB    "VDct1Lib"
#define VDCT1_TRACE_CMD_MGR    "VDct1Mgr"
#define VDCT1_TRACE_CMD_NODE   "VDct1Node"
#define VDCT1_TRACE_CMD_PART   "VDct1Part"
#define VDCT1_TRACE_CMD_SET    "VDct1Set"
#define VDCT1_TRACE_CMD_TREE   "VDct1Tree"
#define VDCT1_TRACE_CMD_TREEF  "VDct1TreeF"
#define VDCT1_TRACE_CMD_ROOT   "VDct1Root"
#define VDCT1_TRACE_CMD_CTEST  "VDct1Test"
#define VDCT1_TRACE_CMD_FREE   "VDct1Free"

  // tree
#define VDCT1_TRACE_TREE_BASE  "VDct1Base"
#define VDCT1_TRACE_TREE_PROD  "VDct1Prod"
#define VDCT1_TRACE_TREE_COM   "VDct1Com"
#define VDCT1_TRACE_TREE_ENGR  "VDct1Engr"
#define VDCT1_TRACE_TREE_XML   "VDct1Xml"
#define VDCT1_TRACE_TREE_POST  "VDct1Post"
#define VDCT1_TRACE_TREE_OFT   "VDct1Oft"
#define VDCT1_TRACE_TREE_PAL   "VDct1Pal"
#define VDCT1_TRACE_TREE_ASSY  "VDct1Assy"
#define VDCT1_TRACE_TREE_PART  "VDct1Part"
#define VDCT1_TRACE_TREE_CABLE "VDct1Cable"
#define VDCT1_TRACE_TREE_WWAY  "VDct1WWay"
#define VDCT1_TRACE_TREE_PIPE  "VDct1Pipe"
#define VDCT1_TRACE_TREE_HVAC  "VDct1Hvac"
#define VDCT1_TRACE_TREE_TEST  "VDct1TTest"
#define VDCT1_TRACE_TREE_PLOT  "VDct1Plot"


  /* ---------------------------
   * defined in tree/VDct1Misc.C
   * **/

extern IGRstat VDct1TraceFlag  __((IGRchar *trace));


/* ----------------------------------------------
 * Used for COset_trace PPL
 * **/
#define VDCT1_TRACE_COMMAND   76
#define VDCT1_TRACE_TREE      78
#define VDCT1_TRACE_OTM_TREE  77

/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif


