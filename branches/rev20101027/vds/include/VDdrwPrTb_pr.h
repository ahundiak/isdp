/* $Id: VDdrwPrTb_pr.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */
/*************************************************************************
 * I/VDS
 *
 * File:        vds/vdtbl/VDdrwPrTb_pr.h
 *
 * Description:
 *      This code includes following functions which used for create a
 *      preview table.        
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwPrTb_pr.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.3  1995/06/23  18:50:44  pinnacle
 * Replaced: include/VDdrwPrTb_pr.h for:  by yzhu for vds.240
 *
 * Revision 1.2  1995/06/19  22:03:02  pinnacle
 * Replaced: include/VDdrwPrTb_pr.h for:  by hverstee for vds.240
 *
 * Revision 1.1  1995/04/20  14:57:18  pinnacle
 * Created: include/VDdrwPrTb_pr.h by yzhu r#
 * rno
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          YZ            include file to define draw
 *                                      preview table function  prototype 
 *************************************************************************/

#ifndef  VDdrwPreTbl_pr_h

#define  VDdrwPreTbl_pr_h

/* ------------------------------------------------------------------------ */

extern IGRlong VD_drwlo_preview( 
                          IGRlong     *msg,
                          struct GRid *window,
                          struct GRid tblLayoutId,
                          IGRint      dis_type,
                          IGRint      win_type,
                          IGRint      xmin,
                          IGRint      ymin,
                          IGRint      width,
                          IGRint      height,
                          IGRint      screen,
                          struct GRid *ownerId);
/* ---------------------------------------------------------------------
 Abstract
    When this function is called, a window is created and  a piece of table
    layout is displaied in the window.

 Arguments
    IGRlong             *msg;           O       return status
    struct GRid         *window;        O       window id
    struct GRid         *ownerId        O       graphic owner id
    struct GRid         tblLayoutId     I       table layout id
    IGRint              dis_type;       I       portion of table to display
    IGRint              win_type;       I       window boundary BORDER/NO_BORDER
    IGRint              xmin, ymin;     I       window upper left corner point
                                                         corner of window
    IGRint              width,height;   I       width and height of window
    IGRint              screen;         I       screen number window is on

  Example:

	IGRlong            msg;
  	struct GRid        window;
  	struct GRid        tblLayoutId;
  	struct GRid        csId;
  	struct GRid        ownerId;
  	IGRint             nbgraphId;
  	IGRint             dis_type;
  	IGRint             win_type;
  	IGRint             xmin;
  	IGRint             ymin;
  	IGRint             width;
  	IGRint             height;
  	IGRint             screen;


        **** from other method to get tblLayoutId *** 
        dis_type = VD_DRWLO_EN_ALL;
 	win_type = BORDER;
  	xmin     = 50;
  	ymin     = 50;
  	width    = 700;
  	height   = 400;
	screen   = 0;

  	status =
        VD_drwlo_preview( &msg, &window, tblLayoutId, dis_type, win_type, 
                          xmin, ymin, width, height, screen ,&owner);
        
  Status
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error

------------------------------------------------------------------------ */
extern IGRlong VD_drwtb_CrtPreTbl( struct GRid *window,
                            struct GRid tblLayoutId,
                            IGRint      dis_type,
                            struct GRid *ownerId,
                            struct GRmd_env *mod_env,
                            struct GRid *csId,
                            struct GRid **graphId0,
                            IGRint      *nbgraphId);

/* ----------------------------------------------------------------------------
  Internal Function: VD_drwtb_CrtPreTbl

  Abstract
     This function is used to create a preview table which may only include
     a header, or trailer or entire table.

  Arguments
     struct GRid        *window         I       window  id
     struct GRid        tblLayoutId     I       table layout id
     IGRint             dis_type;       I       display type : VDdrwlo.h
     struct GRid        **graphId0      O       graphic objects list
     IGRint             *nbgraphId      O       graphic objects list number

  Example:

  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/

extern  IGRlong VDcreate_window( 
                         GRspacenum   osnum,
                         struct GRid  *window,
                         IGRint       win_type,
                         struct GRid  *gragad,
                         IGRint       screen,
                         IGRint       xor,
                         IGRint       yor,
                         IGRint       width,
                         IGRint       height);
/* ----------------------------------------------------------------------------
  Public Function: VDcreate_window

  Abstract
     This function is used to create a window

  Arguments
     GRspacenum         osnum;          I       space number
     struct GRid        *window,        O       window id
                        *gragad;        O       gragad id
     IGRint             win_type;       I       window type BORDER/NO_BORDER
     IGRint             screen,         I       screen number
                        xor,yor,        I       window low left corner point
                        width,height;   I       window width and height

  Example:

  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/

extern IGRlong VDset_cs( struct GRid *CSobj);
/* ---------------------------------------------------------------------------
  Public Function: VDset_cs

  Abstract
     This function is used to create a coordinate system

  Arguments
     struct GRid        *CSobj          O       system coordinates

  Example:

  Status/Return Code
     status == OM_S_SUCCESS               if successful
     status == OM_E_ABORT                 if error
----------------------------------------------------------------------------*/


#endif
