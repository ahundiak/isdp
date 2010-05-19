/* $Id: VDCsupForm.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDCsupForm.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDCsupForm.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.3  1997/10/28  19:05:28  pinnacle
 * Added Headers
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR  DESCRIPTION
 *      10/28/97   ah      added header
 *      07/11/97   EJM     CR#179701494  Support curve enhancements
 *                         Added defines, VDSUP_FRM_B_SWAPUP,
 *                         VDSUP_FRM_B_SWAPDN, VDSUP_FRM_B_CLONE.
 ***************************************************************************/

#define VDSUP_FRM_MAIN  250

#define VDSUP_CMD_CRV_PL 0
#define VDSUP_CMD_OFF_PL 1
#define VDSUP_CMD_EQU_PL 2
#define VDSUP_CMD_CRV_MD 3
#define VDSUP_CMD_OFF_MD 4
#define VDSUP_CMD_EQU_MD 5

#define VDSUP_YES 10
#define VDSUP_NO  20

#define VDSUP_FRM_B_ACCEPT  1
#define VDSUP_FRM_B_EXECUTE 2
#define VDSUP_FRM_B_RESET   3
#define VDSUP_FRM_B_CANCEL  4
#define VDSUP_FRM_F_STATUS 10
#define VDSUP_FRM_B_SWAPUP 12
#define VDSUP_FRM_B_SWAPDN 13
#define VDSUP_FRM_T_TITLE  15

#define VDSUP_FRM_F_NAME 20

#define VDSUP_FRM_F_DIS1 21
#define VDSUP_FRM_F_DIS2 22

#define VDSUP_FRM_F_CUT1 23
#define VDSUP_FRM_F_CUT2 24

#define VDSUP_FRM_F_CNT  25
#define VDSUP_FRM_B_CNT  11

#define VDSUP_FRM_F_DIR  26
#define VDSUP_FRM_B_DIR  27

#define VDSUP_FRM_F_SEL  28
#define VDSUP_FRM_B_SEL  29

#define VDSUP_FRM_F_BASE_OBJ1 30
#define VDSUP_FRM_F_BASE_OBJ2 31
#define VDSUP_FRM_F_BASE_SURF 32

#define VDSUP_FRM_B_BASE_OBJ1 33
#define VDSUP_FRM_B_BASE_OBJ2 34
#define VDSUP_FRM_B_BASE_SURF 35

#define VDSUP_FRM_B_TRIM1 36
#define VDSUP_FRM_B_TRIM2 37
#define VDSUP_FRM_F_TRIM1 38
#define VDSUP_FRM_F_TRIM2 39

#define VDSUP_FRM_G_MET 40
#define VDSUP_FRM_G_LAW 41
#define VDSUP_FRM_G_INT 42

#define VDSUP_FRM_L_TRACE     43
#define VDSUP_FRM_B_TRACE_ADD 44
#define VDSUP_FRM_B_TRACE_DEL 45

#define VDSUP_FRM_B_DIS1 46
#define VDSUP_FRM_B_DIS2 47
#define VDSUP_FRM_B_CUT1 48
#define VDSUP_FRM_B_CUT2 49

#define VDSUP_FRM_B_CLEAR     50
#define VDSUP_FRM_B_CLONE     51

typedef struct {
  IGRlong fld;  /* Field label */
  IGRlong but;  /* Button Label */
  IGRlong ind;  /* Index */
  IGRlong exp;  /* Expression or geometry */
} VDCsupFBI;

IGRstat VDCsupGetFBI(VDCsupFBI *fbiList, IGRlong fld, IGRlong but, VDCsupFBI *fbi);
IGRstat	VDsupGetNextOccName(IGRchar *full_name, IGRchar *name);

