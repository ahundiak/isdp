/*
 * Data type for the source files implementing ci.
 * File dependency: cidef.h  (automatically included)
 *		    stdio.h  (automatically included)
 *		    limits.h (automatically included)
 *		    setjmp.h (automatically included)
 *		    ex.h
 */
#ifndef CITYPES_INCLUDE
#	define CITYPES_INCLUDE

#	include "cidef.h"
#	include <stdio.h>
#	include <setjmp.h>
#	include <limits.h>

/* -- Record describing an instruction.
   -- */
struct ci_instruction {

/* The last parameter is the line number (NOT counted in `nbparam')	*/
				short *paramlist	;
/* Instruction number							*/
				char   type		;
/* Count of parameters in instruction					*/
				char   nbparam		;
} ;

/* -- Information about open files.
   -- */
struct CI_FILE_DES {

/* File name								*/
					char  	name[1+CI_PATH_MAX],
/* Read/write status
   ( see READ/WRITE_BIT in "cidef.h" )					*/
						state		;
/* Stream pointers for writing
   ( w_... ) and reading ( r_... )					*/
					FILE 	*w_strm,
	 					*r_strm		;
} ;

/* -- Function entry descriptor
   -- */
struct f_entry {

/* -- Function name
   -- */
				char	*name	;
/* -- Corresponding instruction number
   -- */
				unsigned short	no_instr;
} ;


/* -- All information related to run time (ci only)
   -- */
#	ifndef CCI
typedef struct {
		unsigned short	pc;		/* Program counter	*/
		unsigned short	stack[MAXSTACK];/* Stack		*/
		short		istack;		/* Stack index		*/
} CIprogseq ;

/* -- Record containing Command Object information for event responses for ci
      (Plus the object id of the current ci object).
      Memory for `response' and `response_data' provided by the Executive.
      `cmd' is provided for nested commands executed from a PPL file.
   -- */
typedef struct {
			int		*response	;
			char		*response_data	;
			int		pos		;
			struct EX_cmd	cmd		;
			OM_S_OBJID	ci_id		;
} CIco_resp ;

/* -- Exception handling.
   -- */
typedef struct {
#ifndef __DDP__
			void (*bus_error)() ;
			void (*flt_excep)() ;
			void (*mem_fault)() ;
			void (*ill_instr)() ;
			void (*bad_syscl)() ;
#else
			int (*bus_error)() ;
			int (*flt_excep)() ;
			int (*mem_fault)() ;
			int (*ill_instr)() ;
			int (*bad_syscl)() ;
#endif
			jmp_buf stack_env   ;
} CItraps ;

typedef struct {
/* -- Prompt and message buffers.
   -- */
			char	Prompt	[1+CI_MAX_SMGR_MSG_SIZE],
				Message	[1+CI_MAX_SMGR_MSG_SIZE],
/* -- Flags that the prompt area must be cleared.
   -- */
				clear_prompt ;
} CImsg ;

/* -- Runtime data one per PPL-loaded ci object ).
	- options	: execution options ( ORing of the following )
				- CI_QUIET_MODE
				- CI_NOMSG_MODE
				- CI_KEEP_MODE
 	- interrupt	: save buffer for C-stack and signals in case of
			  system interruption.
	- msgsys	: buffers for message and prompt.
	- EX_cmd_mode	: modes for the Executive when commands are performed
			  from a PPL file.
  -- */
typedef struct {
			int		options		,
					EX_cmd_mode	;
			CItraps		interrupt	;
			CImsg		msgsys		;
} CIruntime ;

/* -- Arguments passed to the "main" function of a PPL file when invoked via
   -- COci.
   -- */
typedef struct {
	char  ppl[1+CI_PATH_MAX]	; /* Name of PPL file: arg #0	*/
	char  str[1+CI_MAX_ARGSTRING]	; /* String of user arguments   */
	char *ptr[CI_MAX_ARGS]		; /* Pointers to user arguments */

/* -- For main's 3d argument: pointers to `environment'.
      NOTE: according to documentation on Command Table Builder, command names
      have 80 characters at most and command keys 10 at most.
   -- */
#ifndef __DDP__
   	void  		*env[5]		  ; /* Environment array          */
#else
   	int  		*env[5]		  ; /* Environment array          */
#endif
   	char  		cmd[81]		  ; /* Command name		  */
   	char  		key[11]		  ; /* Command key		  */
   	char  		dgn[1+CI_NAME_MAX]	  ; /* Current master file name	  */
   	struct GRmd_env mod		  ; /* Current active module	  */
} ci_ARGS ;

typedef struct {
/* -- Object id and Object Space number of object requesting CI transaction.
   -- */
				OM_S_OBJID	sender_id		;
				OMuword		sender_os		;
/* -- Save buffer for C-stack and signals in case of system interruption.
   -- */

/* -- Arguments to be passed to "main" in PPL file from COci.
   -- */
				ci_ARGS		args			;
/* -- Modes for the Executive when commands are performed from a PPL file.
   -- */

} ci_IGE ;
#	endif

typedef struct {
		int	size;			/* num bytes to copy */
#ifndef __DDP__
		void	*addr;			/* addr to copy from */
#else
		int	*addr;			/* addr to copy from */
#endif
} CIregsave;

/* -- All the data regarding an executing PPL file.
   -- */
struct instance_ci {
/* Name of the file containing the text to be executed			*/
 				char	ficcmd[1+CI_PATH_MAX] ;
 	
/* Code in a ci_instruction format obtained after parsing		*/
				struct ci_instruction *code ;
	
/* Number of generated instructions					*/
				unsigned short	nbinstr ;

/* Table of - variable names
            - pointers to variable values
            - types of variables
            - dimensions of variables	( default 0 )
            - storage classes of variables				*/
				char	**vartable		;
	
				char	**varvaltable		;

				char	*vartypetable		;

				unsigned short	*vardimtable	;

				unsigned char	*varflagtable	;

/* Count of variables							*/
				int	nbvar;

/* Table of functions and count of functions				*/
				struct f_entry	**f_entries ;
				short		nbf_entries ;

/* Pointer to data specific to either ci or cci				*/
				char		*info ;
/* add EB 23 Nov 87, for reentrant code
 * Count of ci running with the same code ( cf ci.delete )	*/
 				short		nb_clone;
/* add EB 23 Dec 87
 * getnotab is often called on cnst_list, speed up the process by keeping it
   in ci_data */
 				short		i_cnst_list;
/* add EB 09 Sept 88
 * Flag for quiet mode (no info messages from ci), no clearing of message
 * areas, etc.
 */
 				short		options;

				CIregsave	*save_regs_info;
#ifndef __DDP__
				void		*save_regs_buff;
#else
				int		*save_regs_buff;
#endif
} ;

#endif
