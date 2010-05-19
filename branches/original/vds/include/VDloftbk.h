/* $Id: VDloftbk.h,v 1.3 2001/12/18 17:34:02 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDloftbk.h
 *
 * Description: for Mold Loft Offsets functionality
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDloftbk.h,v $
 *      Revision 1.3  2001/12/18 17:34:02  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/26 22:56:19  ad
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/10 15:55:49  art
 *      sp merge
 *
 * Revision 1.2  2000/12/01  15:13:02  pinnacle
 * ylong
 *
 * Revision 1.1  2000/10/31  14:36:16  pinnacle
 * ylong
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/31/00  ylong   CR179900929 loft book
 * 01/10/01  ah      sp merge
 ***************************************************************************/

#ifndef VDloftbk_include
#define VDloftbk_include 1

// C stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/*
 * define constants
 */
#define	MTR		0.001	/* factor from mm to meter */

/*
 * Define form gadgets and text for VDloftbk.frm
 */
#define LOFTBK_COMMAND		"MOLD LOFT OFFSETS"
#define LOFTBK_FORM_NAME	"VDloftbk.frm"
#define LOFTBK_FORM_TITLE	12
#define LOFTBK_FORMAT_FLD	13
#define LOFTBK_FORMAT_LBL	14
#define LOFTBK_TITLE_FLD	35
#define LOFTBK_TITLE_LBL	11
#define LOFTBK_PREFIX_FLD	15
#define LOFTBK_PREFIX_LBL	16
#define LOFTBK_FILE_FLD		17
#define LOFTBK_FILE_LBL		18
#define	LOFTBK_START_FLD	19
#define	LOFTBK_START_LBL	20	
#define	LOFTBK_NROWS_FLD	21
#define	LOFTBK_NROWS_LBL	22
#define	LOFTBK_DATE_FLD		23
#define	LOFTBK_DATE_LBL		24
#define	LOFTBK_JOB_NO_FLD	25
#define	LOFTBK_JOB_NO_LBL	26
#define	LOFTBK_DWG_NO_FLD	27
#define	LOFTBK_DWG_NO_LBL	28
#define	LOFTBK_REV_FLD		29
#define	LOFTBK_REV_LBL		30
#define	LOFTBK_CLASS_NO_FLD	31
#define	LOFTBK_CLASS_NO_LBL	32
#define	LOFTBK_CLASS_FLD	33
#define	LOFTBK_CLASS_LBL	34
#define	LOFTBK_CAGE_FLD		39
#define	LOFTBK_CAGE_LBL		40
#define	LOFTBK_CAGE_SIZE_FLD	41
#define	LOFTBK_CAGE_SIZE_LBL	42
#define	LOFTBK_FRMFORMAT_FLD	43
#define	LOFTBK_FRMFORMAT_LBL	44
#define	LOFTBK_PROCESS_BTN	50

/*
 * if a curve is an AScompcurve, use cvOEs to hold its components
 */
typedef struct {
        TGRobj_env      cvOE;
	IGRchar		cvName[40];
	IGRint		*intCnt;
	TGRid		**intIDs;
} VDloftbkCv;


/*
 * loft book information
 */
typedef struct {
	// curve info
        VDloftbkCv	*cvList;	// curves
        IGRint          cvCnt;		// # of curves
        IGRint          *intMaxCnt;	// size frmIntCnt

	// frame system
	TGRobj_env	frmSysOE;
	IGRint		fmin;
	IGRint		fmax;
	IGRint		frmIntCnt;
	IGRint		*frmNum;
	IGRint		frmFlag; // report by number or distance

	// form
	Form		form;
	IGRint		gadget;
	IGRint		displayForm;

	// report header
	IGRchar		date_title_page[256];
	IGRchar		header[1024];

	// input info from user
	IGRchar		format[128];
	IGRchar		prefix[128];
	IGRchar		filename[128];
	IGRint		startPage;
	IGRint		rowCnt;
	
} VDloftbkInfo;

extern	IGRlong	VDloftbk_init	__((VDloftbkInfo *));
extern	IGRlong	VDloftbk_sleep	__((VDloftbkInfo *));
extern	IGRlong	VDloftbk_delete	__((VDloftbkInfo *));
extern	IGRlong	VDloftbk_wakeup	__((VDloftbkInfo *));
extern	IGRlong	VDloftbk_notifyForm	__((VDloftbkInfo *));
extern	IGRlong	VDloftbk_checkInput	__((VDloftbkInfo *));
extern	IGRlong	VDloftbk_process	__((VDloftbkInfo *));
extern	IGRlong	VDloftbk_getCvsByPrefix __((IGRchar *, VDloftbkCv **,IGRint *));
extern	IGRlong	VDloftbk_printFormat1	__((VDloftbkInfo *, FILE *));
extern	IGRlong	VDloftbk_printFormat2	__((VDloftbkInfo *, FILE *));
extern	IGRlong	VDloftbk_printFormat3	__((VDloftbkInfo *, FILE *));
extern	IGRlong	VDloftbk_printFormat4	__((VDloftbkInfo *, FILE *));
extern	IGRlong	VDloftbk_initForm	__((Form));
extern	void	VDloftbk_enableForm	__((Form));
extern	void	VDloftbk_disableForm	__((Form));

// Cleanup
#if defined(__cplusplus)
}
#endif

#endif

