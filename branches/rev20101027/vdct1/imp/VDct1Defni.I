/* $Id: VDct1Defni.I,v 1.1.1.1 2001/01/04 21:08:02 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/imp/VDct1Defni.I
 *
 * Description: Take control of macro definations
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1Defni.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:02  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/06/29  18:28:08  pinnacle
# ct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/28/99  ah      Creation
 ***************************************************************************/

class implementation VDct1Defn;

#include "macro.h"
#include "VDtypedef.h"

#define FMT_STR "VDct1Defn %d,%d %s\n"

/* -------------------------------------------
 * Some tracing capability
 */
static int traceFlag;

IGRstat VDct1DefnSetTraceFlag(IGRint flag)
{
  traceFlag = flag;
  return 1;
}

/* -------------------------------------------------
 * New custom methods 
 */
method VDctDefnSetData
(
  IGRchar *data
)
{
  return OM_W_ABORT;
}

method VDctDefnGetData
(
  IGRchar *data
)
{
  return OM_W_ABORT;
}

method VDctDefnSetName
(
  IGRchar *name
)
{
  if (name) strcpy(me->macro_name,name);
  return OM_S_SUCCESS;
}

method VDctDefnGetName
(
  IGRchar *name
)
{
  if (name) strcpy(name,me->macro_name);
  return OM_S_SUCCESS;
}

method VDctDefnGetOccID
(
  TGRid *occID
)
{
  if (occID) *occID = me->occID;
  return OM_S_SUCCESS;
}

method VDctDefnSetOccID
(
  TGRid *occID
)
{
  if (occID) me->occID = *occID;
  return OM_S_SUCCESS;
}

/* -------------------------------------------------
 * The existing methods
 * ACcpx_defn
 */
method ACgive_temp_desc
(
  int *temp_num; 
  struct stemp  **temp_defn 
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"ACcpx_defn.ACgive_temp_desc");
  }
  if (temp_num) *temp_num = 0;
  return OM_W_ABORT;
}
#if 0
method ACgive_feet_desc
(
  int *feet_num; 
  struct myfeet **myfeet
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"ACcpx_defn.ACgive_feet_desc");
  }
  if (feet_num) *feet_num = 0;
  return OM_W_ABORT;
}
#endif
method ACintpt_foot
(
  int  *suc;
  char *foot_name;
  int  *chan;
  int  *index;
  int  *type;
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"ACcpx_defn.ACintpt_foot");
  }
  *suc = 0;
  return OM_W_ABORT;
}

method ACintpt_foot_dir
(
  int  *suc;
  int  *direct_index;
  char *foot_name;
  int  *chan;
  int  *pos;
  int  *type;
  int  *index
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"ACcpx_defn.ACintpt_foot_dir");
  }
  *suc = 0;
  return OM_W_ABORT;
}

method ACmax_graph_ft
( 
  int *max
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"ACcpx_defn.ACmax_graph_ft");
  }
  if (max) *max = 0;
  return OM_S_SUCCESS;
}

method ACgive_name
(
  char **name
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"ACcpx_defn.ACgive_name");
  }
  if (name) *name = me->macro_name;
  return OM_S_SUCCESS;
}

method ACreturn_real_def
(
  struct GRid *real_def;
  char        *hcode
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"ACcpx_defn.ACreturn_real_def");
  }
  return OM_W_ABORT;
}

method ACreturn_symb_def
(
  struct GRid *symb_def;
  OMuword osnum
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"ACcpx_defn.ACreturn_symb_def");
  }
  return OM_W_ABORT;
}

/* -----------------------------------------------------------
 * Root
 */
method debug
(
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.debug");
  }
  return om$send(msg = message ACcpx_defn.
                 debug(),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method delete (int f_defer_flag)
{

  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.delete");
  }
  return om$send(msg = message ACcpx_defn.
                 delete(f_defer_flag),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method connect 
(
  OM_S_CHANSELECT to_sel;
  int             to_idx;
  OM_S_OBJID      fr_objid;
  OMuword         fr_os;
  OM_S_CHANSELECT fr_sel;
  int             fr_idx
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.connect");
  }
  return om$send(msg = message ACcpx_defn.
                 connect(to_sel,to_idx,fr_objid,fr_os,fr_sel,fr_idx),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method disconnect
(
  OM_S_CHANSELECT to_sel;
  OM_S_OBJID      fr_objid;
  OMuword         fr_os;
  OM_S_CHANSELECT fr_sel
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.disconnect");
  }
  return om$send(msg = message ACcpx_defn.
                 disconnect(to_sel,fr_objid,fr_os,fr_sel),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method wild_disconnect
(
  OM_S_CHANSELECT to_sel
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.wild_disconnect");
  }
  return om$send(msg = message ACcpx_defn.
                 wild_disconnect(to_sel),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

method move_chan
(
  OM_S_CHANSELECT to_sel;
  OM_S_OBJID      fr_objid;
  OMuword         fr_os;
  OM_S_CHANSELECT fr_sel
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.move_chan");
  }
  return om$send(msg = message ACcpx_defn.
                 move_chan(to_sel,fr_objid,fr_os,fr_sel),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method copy_chan
(
  OM_S_CHANSELECT to_sel;
  OM_S_OBJID      fr_objid;
  OMuword         fr_os;
  OM_S_CHANSELECT fr_sel
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.copy_chan");
  }
  return om$send(msg = message ACcpx_defn.
                 copy_chan(to_sel,fr_objid,fr_os,fr_sel),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method unknown
(
  OM_S_MESSAGE *msg
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.unknown");
  }
  return om$send(msg = message ACcpx_defn.
                 unknown(msg),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method  range_disconnect
(
  OM_S_CHANSELECT to_sel;
  int             low_idx;
  int             hi_idx
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.range_disconnect");
  }
  return om$send(msg = message ACcpx_defn.
                 range_disconnect(to_sel,low_idx,hi_idx),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method set_operation
(
  OM_S_CHANSELECT to_sel;
  OM_S_OBJID      op2_objid;
  OMuword         op2_os;
  OM_S_CHANSELECT op2_sel;
  OM_S_OBJID      op3_objid;
  OMuword         op3_os;
  OM_S_CHANSELECT op3_sel;
  char            operation;
  OMuword         preserve
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.set_operation");
  }
  return om$send(msg = message ACcpx_defn.
                 set_operation(to_sel,
                               op2_objid,op2_os,op2_sel,
                               op3_objid,op3_os,op3_sel,
                               operation,preserve),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method ARwrite
(
  int *return_code; 
  int  starting
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.ARwrite");
  }
  return om$send(msg = message ACcpx_defn.
                 ARwrite(return_code,starting),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}
method ARread
(
  int  *return_code; 
  char *keyword 
)
{
  if (traceFlag) {
    printf(FMT_STR,VDcurOS,my_id,"Root.ARread");
  }
  return om$send(msg = message ACcpx_defn.
                 ARread(return_code,keyword),
	         mode = OM_e_wrt_message,
	         targetid = my_id);
}

end implementation VDct1Defn;
