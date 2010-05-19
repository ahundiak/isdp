#ifndef vd_report_error 
#define vd_report_error 


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
 
/*---------------------------------------
*  Report Error Modes 
*--------------------------------------*/
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
* VDS Report Error utility.
* KDD 10-97
*
*----------------------------
*  PARAMETERS:
*
* I: 	int	mode	- Specifies where and how to report the error.
*			  Default = 2; UI_status and Unix window;
*			  If mode < 0 (debug) prints filename and line also. 
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
*  Algorithm:
*  Prints "error" message text on output device specified by "mode". 
*  The caller can specify filename and line number. 
*  In case of debugging (mode < 0, or vdsDEBUG defined) it will print 
*  debug info (filename, line). Default are __FILE__ and __LINE__. 
*
*  NOTE: 
*	To activate the debug info you need to "#define vdsDEBUG 1", 
*	much like you do for __DBGpr_xxx (v_dbgmacros.h). 
*	Thus, in addition to the user message, you will get the file + line. 
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

