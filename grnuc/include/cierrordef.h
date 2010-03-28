/* -- Include file for "CI report error" module.
      File dependency: OMerrordef.h
   -- */
#ifndef cierrordef_include
#	define cierrordef_include

#ifndef	OM_D_ERRORDEF
#	omerror "OMerrordef.h must be included before this file."
#endif

/* -- Error output to ...
   -- */
#	define	CI_ERR_MSGSYS 0
#	define	CI_ERR_STDOUT 1
#	define	CI_ERR_STDERR 2

/* -- Error codes (same format as OM error codes).
   -- */
#define MKerrno( no, level ) ((OM_FACILITY_CODE<<16)+0X8000+((no)<< 3)+(level))

/*----------------------------------------------------------------------------*\
 | Command Interpreter error code.                                            |
 | All the above codes may be interpreted with the macro:                     |
 |                                                                            |
 |                            ci$report_error                                 |
 | defined in cierrmacros.h.                                                  |
\*----------------------------------------------------------------------------*/

/* -- Everything went fine.
   -- */
#ifndef CI_S_SUCCESS
#	define CI_S_SUCCESS	1
#endif

/* -- Attempt to set or get an unknown variable.
   -- */
#	define CI_W_NO_SUCH_VAR	MKerrno( 2, WARN )

/* -- File cannot be accessed (protected or does not exist).
   -- */
#	define CI_E_CANT_ACCESS	MKerrno( 3, ERRO )

/* -- Symbol file ci.X cannot be accessed (protected, does not exist, too old).
   -- */
#	define CI_E_NO_SYM_FILE	MKerrno( 4, ERRO )

/* -- Memory allocation failure.
   -- */
#	define CI_E_CANT_MALLOC	MKerrno( 5, ERRO )

/* -- Attempt to perform operations on a not-yet-loaded CI object.
   -- */
#	define CI_E_OBJCT_EMPTY MKerrno( 6, ERRO )

/* -- Attempt to execute an unknown function in a PPL file.
   -- */
#	define CI_W_NO_SUCH_FUN	MKerrno( 7, WARN )

/* -- Execution of command file has been interrupted, either with STOP window
      or because of execution errors.
   -- */
#	define CI_W_EXEC_ABORTD	MKerrno( 8, WARN )

/* -- Fatal error in operation.
   -- */
#	define CI_E_FATAL_ERROR	MKerrno( 9, ERRO )

/* -- File is not known of super_ci.
   -- */
#	define CI_E_NO_SUCHFILE	MKerrno( 10, ERRO )

/* -- Error in cloning file.
   -- */
#	define CI_E_CLON_FAILED	MKerrno( 11, ERRO )

/* -- Error in loading file.
   -- */
#	define CI_E_LOAD_FAILED	MKerrno( 12, ERRO )

/* -- No model found for clone.
   -- */
#	define CI_E_MODELNOTFND	MKerrno( 13, ERRO )

/* -- Object has been created, but cannot be registered in database.
   -- */
#	define CI_E_DB_OVERFLOW	MKerrno( 14, ERRO )

/* -- Invalid arguments specified in call.
   -- */
#	define CI_E_INVALIDARGS	MKerrno( 15, ERRO )

/* -- Cannot access compiled PPL file.
   -- */
#	define CI_E_ACCCOMPILED	MKerrno( 16, ERRO )

/* -- Unknown error code.
   -- */
#	define CI_E_UNK_ERRCODE	MKerrno( 17, ERRO )

/* -- Bag magic number: file is not a PPL executable.
   -- */
#	define CI_E_BADMAGICNB	MKerrno( 18, ERRO )

/* -- Version mismatch.
   -- */
#	define CI_E_VER_MISMTCH	MKerrno( 19, ERRO )

/* -- Design file about to be saved.
   -- */
#	define CI_W_WRITING_DGN MKerrno( 20, WARN )

/* -- Design file about to be closed.
   -- */
#	define CI_W_CLOSING_DGN MKerrno( 21, WARN )

/* -- Design file about to be opened.
   -- */
#	define CI_W_OPENING_DGN MKerrno( 22, WARN )

/* -- Form not found.
   -- */
#	define CI_E_FMNOTFOUND	MKerrno( 23, ERRO )

/* -- No window on screen(s).
   -- */
#	define CI_E_NOWINFOUND	MKerrno( 24, ERRO )

/* -- Requested window not found.
   -- */
#	define CI_W_WNNOTFOUND	MKerrno( 25, WARN )

/* -- Last message index.
   -- */
#	define CI_K_LAST_MSG_INDEX 25


#endif

