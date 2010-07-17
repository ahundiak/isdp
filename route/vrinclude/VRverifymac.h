/* $Id: VRverifymac.h,v 1.1.1.1 2001/01/04 21:12:55 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrinclude / VRverifymac.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRverifymac.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:55  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.2  1996/09/05  16:46:04  pinnacle
 * TR179600629 ah
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.3  1996/01/17  23:42:34  pinnacle
 * Replaced: vrinclude/VRverifymac.h for:  by r240_int for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *      09/05/96   ah           TR179600629, Moved error report over to
 *                              the left for narrower report
 *	01/15/96   tlb		Add header, prototype macro defs
 *
 *************************************************************************/

#ifndef vr_verify__mac_include
#define vr_verify_mac_include

/***************************************************************************/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VRPrintVerify __(( IGRboolean            Test,
			      IGRchar               *ErrorBuf,
			      IGRchar               *OKBuf,
			      IGRboolean            Verbose,
			      struct     GRid       *ErrObj,
			      GRobjid               object,
			      GRspacenum            OSnum,
			      IGRdouble             *OrigCoor,
			      IGRint                *ErrorCnt,
			      struct    VRvfy_file  *FileData ));


extern int VRPrintErrHead __(( struct VRvfy_file *FileData,
			       IGRchar           *date  ));

extern int VRPrintVerHead __(( struct VRvfy_file *FileData,
			       IGRchar           *date ));

extern int VRPrintVerObj __(( struct VRvfy_file *FileData,
			      struct GRid       *object,
			      IGRchar           *Type,
			      IGRshort          Product));
#if defined(__cplusplus)
}
#endif

/***************************************************************************/
#omdef VR$PrintVerify( Test,
		       ErrorBuf  = NULL,
		       OKBuf     = NULL,
		       Verbose   = FALSE,
		       ErrObj    = NULL,
		       object,
		       OSnum     = OM_Gw_current_OS,
		       OrigCoor,
		       ErrorCnt    = NULL,
		       FileData)

VRPrintVerify( Test, ErrorBuf, OKBuf, Verbose, ErrObj, object, OSnum,
	      OrigCoor, ErrorCnt, FileData);

#endomdef

/************************************************************************/
#omdef VR$PrintVerObj(FileData,
		      object,
		      Type = "Component",
		      Product = VR_PIPING)
VRPrintVerObj ( FileData, object, Type, Product );
#endomdef

/************************************************************************/
#omdef VR$PrintVerType( FileData,
		        Type = "")
if ( FileData[VERBOSE_NUM].File_ptr )\
{\
fprintf(FileData[VERBOSE_NUM].File_ptr, "%*c%s:\n",2, ' ',Type);\
FileData[VERBOSE_NUM].LineCnt += 1;\
}\
#endomdef

/************************************************************************/
#omdef VR$PrintErrHead( FileData,
		       date = NULL )
 VRPrintErrHead ( FileData, date );
#endomdef

/************************************************************************/
#omdef VR$PrintVerHead( FileData, date )
 VRPrintVerHead ( FileData, date );
#endomdef

/************************************************************************/
#omdef VR$PrintNoError( FileData )
if ( FileData[VERBOSE_NUM].File_ptr )\
{\
fprintf(FileData[VERBOSE_NUM].File_ptr, "\n%*c%s\n",8, ' ',"*** Object Validated: No Errors Found ***");\
FileData[VERBOSE_NUM].LineCnt += 2;\
}\
#endomdef


/************************************************************************/
/*
 * TR179600629, changed from 45 to 20 to fit on page better
 */

#omdef VR$PrintErrorSummary( FileData, ErrorCnt )
if ( FileData[ERROR_NUM].File_ptr )\
  fprintf(FileData[ERROR_NUM].File_ptr, "\n\n%*c Total number of errors found: %d\n",20, ' ', *ErrorCnt);
#endomdef
#endif
