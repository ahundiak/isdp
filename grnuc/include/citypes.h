/*
 * Data type for the source files implementing ci.
 * File dependency: cidef.h  (automatically included)
 *		    stdio.h  (automatically included)
 *		    limits.h (automatically included)
 *		    setjmp.h (automatically included)
 */
#ifndef CITYPES_INCLUDE
#	define CITYPES_INCLUDE

#	include "cidef.h"
#	include <stdio.h>
#	include <setjmp.h>


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
					char  	name[1+PATH_MAX],
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
				short	no_instr;
} ;


/* -- All information related to IGE (ci only)
   -- */
#	ifndef CCI
/* -- Exception handling
   -- */
typedef struct {
			void (*bus_error)() ;
			void (*flt_excep)() ;
			void (*mem_fault)() ;
			void (*ill_instr)() ;
			void (*bad_syscl)() ;
			jmp_buf stack_env   ;
			char executing	    ;
} ci_traps ;

/* -- Arguments passed to the "main" function of a PPL file when invoked via
   -- COci.
   -- */
typedef struct {
	char  ppl[1+PATH_MAX]		; /* Name of PPL file: arg #0	*/
	char  str[1+CI_MAX_ARGSTRING]	; /* String of user arguments   */
	char *ptr[CI_MAX_ARGS]		; /* Pointers to user arguments */

/* -- For main's 3d argument: pointers to `environment'.
      NOTE: according to documentation on Command Table Builder, command names
      have 80 characters at most and command keys 10 at most.
   -- */
   	void  		*env[5]		  ; /* Environment array          */
   	char  		cmd[81]		  ; /* Command name		  */
   	char  		key[11]		  ; /* Command key		  */
   	char  		dgn[1+NAME_MAX]	  ; /* Current master file name	  */
   	struct GRmd_env mod		  ; /* Current active module	  */
} ci_ARGS ;

typedef struct {

/* -- Prompt and message buffers.
   -- */
				char promptmess[1+CI_MAX_SMGR_MSG_SIZE]	;
				char messagemess[1+CI_MAX_SMGR_MSG_SIZE];
/* -- Flags that the prompt area must not be cleared.
   -- */
				char flagprompt				;
/* -- Object id and Object Space number of object requesting CI transaction.
   -- */
				OM_S_OBJID	sender_id		;
				OMuword		sender_os		;
/* -- Save buffer for C-stack and signals in case of system interruption.
   -- */
				ci_traps	interrupt		;
/* -- Arguments to be passed to "main" in PPL file from COci.
   -- */
				ci_ARGS		args			;
/* -- Modes for the Executive when commands are performed from a PPL file.
   -- */
				int		EX_cmd_mode		;

} ci_IGE ;
#	endif


/* -- All the data regarding an executing PPL file.
   -- */
struct instance_ci {
/* Name of the file containing the text to be executed			*/
 				char	ficcmd[1+PATH_MAX] ;
 	
/* Code in a ci_instruction format obtained after parsing		*/
				struct ci_instruction *code ;
	
/* Number of generated instructions					*/
				short nbinstr ;

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
} ;

#endif
