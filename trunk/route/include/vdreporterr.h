
/* $Id: vdreporterr.h,v 1.1.1.1 2001/01/04 21:12:10 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        include/vdreporterr.h
 *
 * Description:
 *
 *
 * Dependencies:
 *
 * History:
 *      $Log: vdreporterr.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:10  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/11/28  22:36:40  pinnacle
 * Replaced: include/vdreporterr.h for:  by r250_int for route
 *
 * Revision 1.1  1997/11/28  22:35:08  pinnacle
 * Created: include/vdreporterr.h by r250_int for route
 *
 *
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      11/28/97   kddinov	Initial
 *
 *************************************************************************/

#ifndef v_report_error 
#define v_report_error 


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
 
#define VD_UNIX_WINDOW      		1
#define VD_UNIX_WINDOW_STATUS_FIELD	2


#if defined(__cplusplus)
extern "C" {
#endif

extern  int 	VDSreport_error __((
                                char			*text,
                                int                  	mode,
                                char			*filename,
                                int			line)); 

#if defined(__cplusplus)
}
#endif

/*------------------------------------------------------------------------------
* General VDS Report Error utility.
*
*----------------------------
*  PARAMETERS:
*
* I: 	int	mode	- Specifies where and how to report the error.
*			  Default = 2; UI_status and Unix window;
*			  If mode < 0 prints filename and line also. 
*			1 Unix window
*			2 Unix window + status field. 
*
* I:	char	*text	- error message to address to the user. 
*
* I:	char	*filename - filename where the error occurs. 
*			  Macro API uses __FILE__.
*
* I: 	int	line	- line number.  Macro API uses __LINE__.
*
*----------------------------
*   RETURN STATUS:
* 1 	- always.
*
------------------------------------------------------------------------------*/
#omdef vd$report_error ( error    	= NULL,
			 mode     	= 2, 
		         filename 	= NULL,
		         line     	= __LINE__) 
{\
#ifdef vdsDEBUG
#  if om$specified(filename) 
        ( (mode) < 0 ) ? \
	VDSreport_error( (error),  (mode), (filename), (line) ) : \
	VDSreport_error( (error), -(mode), (filename), (line) ) ; \
#  else
        ( (mode) < 0 ) ? \
	VDSreport_error( (error),  (mode), (__FILE__), (line) ) : \
	VDSreport_error( (error), -(mode), (__FILE__), (line) ) ; \
#  endif
#else
	VDSreport_error( (error),  (mode), (filename) , (line) ) ; \
#endif

}\

#endomdef

#endif

