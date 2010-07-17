/*
	I/STRUCT
*/
#ifndef vsfmcpypaste_include
#	define vsfmcpypaste_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

extern void
VSf_storeCopyPasteInfo	__(( char *pForm, int gadgetLabel )) ;

extern void
VSf_resetCopyPasteInfo	__(( char *pForm )) ;

extern void
VSf_CopyFromForm	__(( char *pForm )) ;

extern void
VSf_PasteToForm		__(( char *pForm )) ;

#endif
