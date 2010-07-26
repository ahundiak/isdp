/* -- Include file for CI setup modules.
      Most everything is private to ci.
      File dependency: cidef.h
   -- */

#ifndef CISETUP_INCLUDE
#	define CISETUP_INCLUDE

#ifndef CISETUP_MODULE
#	define CIsu_EXTERN extern
#else
#	define CIsu_EXTERN
#endif

/* -- Relative path name of default pre-processor (omcpp).
   -- */
#	define OMCPP_REL_PATH	"bin/omcpp"

/* -- Relative path name of compiler for Command Interpreter (cci).
   -- */
#	define CCI_REL_PATH	"bin/cci"

/* -- Relative path name of system PPL include files directory.
   -- */
#	define PPL_INC_REL_PATH	"ppl/include"

/* -- Name of CI set-up file.
   -- */
#	define CISETUP		".cisetup"

/* -- Max length of search path ( not including '\0' ).
   -- */
#define CIPATHLEN	1023

/* -- Max number of include directories which may be specified in CISETUP.
   -- */
#define MAXINCDIRS	10

/* -- Default system values for some gadgets.
   -- */
#define DYNAMICSdef	TRUE
#define GDISPLAYdef	TRUE
#define MESSAGESdef	TRUE
#define STOP_CHKdef	20
#define EROUTPUTdef	1	/* 0: UNIX window, 1: form */
#define TRAPSIGSdef	FALSE

typedef char	UNIXpath[1+CI_PATH_MAX] ;

/* -- Path to cci executable, paths to PPL source files.
   -- */
CIsu_EXTERN	UNIXpath		CIcci_path,
/* -- Paths to executable and ci.X.
   -- */
					CIext_path[2],
/* -- Last-invoked PPL file.
   -- */
					CIprevious,
/* -- Pathname of pre-processor.
   -- */
					CIprepronm; 
/* -- Paths to PPL source files.
   -- */
CIsu_EXTERN	char			CIsrc_path[CIPATHLEN+1],
/* -- Arguments of last-invoked PPL file.
   -- */
					CIprevargs[1+CI_MAX_ARGSTRING],
/* -- Paths to include files.
   -- */
					CIincludes[(CI_PATH_MAX+3)*MAXINCDIRS+1],
/* -- Count of include directories.
   -- */
					CIninclude,
/* -- Argument list for cci.
   -- */
		 			*CIcciargs[20],

/* -- Catch or do not catch system signals during execution.
   -- */
   					CItrapsigs,

/* -- Runtime dynamics and graphic display toggle
     ( predefined in the form: default 0 and 1 resp. ).
   -- */
					CIdynamics,
					CIgdisplay,

/* -- Runtime message area toggle, error display ( 0 = form, 1 = UNIX window ).
      ( predefined in the form: default 0 and 1 resp. )
   -- */
					CImessages,
					CIeroutput ;

/* -- Count of instructions before checking stop window ( 0-999, 0 = no check )
      ( defaulted in form at 20 ).
   -- */
CIsu_EXTERN	short			CIstop_chk ;


/***********************************************************/
/*****  C FORMS CONVERSION  *****  C FORMS CONVERSION  *****/

/* values came from old OM-forms include files ('X_' added to distinguish) */


#define FI_X_STRLEN 	      	132
#define FI_X_LINE_LEN 		132

#define FI_X_STATE	1
#define FI_X_INT	2
#define FI_X_DOUBLE	3
#define FI_X_ALPHA	4

#define FI_X_EDIT_NOSELECT	0	/* must supply new string */

struct FI_X_data_st
{
    int label;
    int type;
    int index;        /* line number - in multi-line gadgets */
    int max_index;    /* max number of lines - in multi-line gadgets */
    int select_flag;  /* See #defines in fidef.h - i.e. FI_SELECTED .
			 in get_by_value - return if selected, not selected
			 doesn't matter.  In put_by_value - data is
			 selected or not selected -  used with checklist
			 and field with popup list */
    int sts;	     /* sts iff applicaple e.g invalid range */
    union
    {
	OM_S_OBJID objid;
	char state;	/* TRUE or FALSE */
	int ivalue;
	double dvalue;
	char alpha [FI_X_STRLEN];
    } value;
};

#endif /* CISETUP_INCLUDE */
