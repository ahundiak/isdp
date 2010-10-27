/* $Id: VDCmdBOM.S,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdbom/cmd / VDCmdBOM.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCmdBOM.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1994/12/12  20:47:42  pinnacle
# Replaced:  vdbom/cmd/*.[IS] r#
#
# Revision 1.2  1994/12/07  15:29:24  pinnacle
# Replaced:  vdbom/cmd r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *      12/07/94        R. Manem        OPE enhancements :
 *                                      - new instance data for balloon params,
 *                                        table name, assoc option, curren OS,
 *                                        and sorting parameters.
 *                                      - new messages : init_form,
 *                                        store_tblName, sort_objs
 *	12/12/94	R. Manem	- new instance data for leader line
 *					  support
 *
 * -------------------------------------------------------------------*/


class specification VDCmdBOM (1:0) of VDS_LOCATE;



/*+cmd
/* -------------------------------------------------------------------------

  Command Object Class VDCmdBOM

  Superclass
      VDS_LOCATE

  Abstract
        The Command Object provides a form interface for creating the
        Bill of Materials, based on the objects and their attributes
        selected
        
  Methods

      process_locate         Public     Processes the elements located by
                                        vds_locate filter

      wrap_up                Public     Wraps up the CO.

      operation              Public     Modifies the attributes of all
                                        located objects

  Overridden Methods

     mouse              Implemented to track the mouse position on the user 
                        attributes form, and display suitable messages in 
                        the message field on the form.
    
     form_notification  Notification routine for the VDBillOfMat form

  Forms

     User Attributes    VDBillOfMat     User interface for the CO


 -------------------------------------------------------------------------

-cmd*/

#include "igetypedef.h"
#include "vdandef.h"
#include "VDmsg.h"
#include "VDbom.h"

/*+v
 -------------------------------------------------------------------------
  Abstract

  Notes/Remarks

*/

instance VDCmdBOM
{
      GRspacenum                curOS;       	 /* Current osnum */
      IGRint                    nbLocObjs;       /* No. of located objects */
      IGRint                    curObjIndex;     /* Current object whose
                                                    attributes are displayed */
      IGRint                    assocOption;     /* associative BOM - 1;
                                                    non-assoc BOM   - 0 */
      IGRint                    blnType;         /* balloon type */
      IGRint                    blnSides;        /* No of sides for balloon */
      IGRdouble                 blnSize;         /* balloon size */
      IGRint			leaderFlag;      /* with/without leader line */
      struct VDan_ldrline	ldrLine;	 /* leader line structure */
      struct GRid               coll;            /* attributes and their
                                                    layout stored in an
                                                    rg_collector object */
      struct GRobj_env          csGrid;          /* Coordinate system :
                                                    origin of BOM table */
      variable IGRchar		tblName[1];	 /* name of the table */
      struct GRobj_env          bomGrid;         /* BOM table */
      struct EX_button          window;          /* Window structure needed for
                                                    placing item numbers */
      IGRchar                   sortOrderLst[SORT_LEVEL];
                                                 /* List of sorting orders :
                                                    '<' - ascending;
                                                    '>' - descending */
      IGRchar                   sortAttrLst[SORT_LEVEL][MAX_BUF_CHARS]; 
                                                 /* list of sort attributes */
      IGRint                    colSizeLst[SORT_LEVEL];
                                                 /* list of column widths for 
                                                    sort attributes */
      IGRchar                   formatLst[SORT_LEVEL][MAX_BUF_CHARS]; 
                                                 /* list of formats for the
                                                    sort attributes */
      };


message my_init ( long * sts );

message init_form ( long * sts );

message wrap_up ( long * sts );

message store_format ( long * sts );

message store_tblName ( long * sts );

message sort_objs ( long * sts );

message process_locate ( long * sts );

message dspAttrs ( int  elmNo );

message delFromList ( long *sts; 
                    int  elmNo );

override mouse;

override form_notification;

message check_item ( long * sts );

message store_cs ( long * sts );

message store_window ( long * sts );

message generate_bom ( long * sts );

message generate_item_nos ( long * sts );

message init_from_bom ( long * sts );

message store_bom ( long * sts );

message update_form ( long * sts );

end specification VDCmdBOM;
