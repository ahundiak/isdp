/*
 * Contains the constant definition for the CI compiler source files
 */
#ifndef PCIDEF_INCLUDE
#	define PCIDEF_INCLUDE

#	include <limits.h>

/* -- Conditionnal including
   -- */
#	define CCI 1

/* -- Just in case ...
   -- */
#	ifndef TRUE
#		define TRUE 1
#	endif
#ifndef FALSE
#		define FALSE 0
#	endif

/* -- pci version number
   -- */
#	define PCI_VERSION 0

/* -- Option names:
	- do not check pointer/pointer type compatibility
	- do not check function argument types
	- warn about defined but unused user functions
	- consider all undefined functions as "extern int"
   -- */
#	define NOPTRCHK	"noptrchk"
#	define NOARGCHK "noargchk"
#	define UNUSEDFN "unusedfn"
#	define EXTERNFN "externfn"

/* -- Some big integer !
   -- */
#	define INFINITE INT_MAX

/* -- Array index corresponding to no element (either because it does not exist
      or it could not be created ...
   -- */
#	define EMPTY		(-1)

/* -- Maximum number of "-I" options.
   -- */
#	define MAXCPPOPTS	32

/* -- Maximum length of a string constant ( including trailing '\0' ).
   -- */
#	define MAXSTRING	1024

/* -- Maximum length of an identificator ( including trailing '\0' ).
   -- */
#	define MAXIDLEN		128

/* -- Maximum number of constants that will not be  redeclared when  they appear
   -- several times.
   -- */
#	define MAXCONST		1024

/* -- Quantum number of labels.
   -- */
#	define LABQUANTUM	128

/* -- Maximum number of elements in a list.
   -- */
#	define LISTBUNCH	9
#	define MAXELTS		( 16 * LISTBUNCH )

/* -- Quantum number of instructions.
   -- */
#	define INSQUANTUM	500

/* -- Maximum number of variables allowed.
   -- */
#	define MAXVAR		6400

/* -- Maximum number of nodes in the syntactic tree of an expression.
      Node numbers are stored in unsigned chars.
   -- */
#	define MAXNODE 		( CHAR_MAX - CHAR_MIN + 1 )

/* -- Maximum number of nested union/structures.
   -- */
#	define MAXSTRUCT	256

/* -- Size of the `switch' table.
   -- */
#	define MAXSWITCH	256

/* -- Maximum dimension for an array ( dimensions are unsigned shorts ).
   -- */
#	define MAXDIM		( SHRT_MAX - SHRT_MIN )

/* -- Maximum numbers of typedefs.
   -- */
#	define MAXTYPE	128

/* -- Default size for data segment.
   -- */
#	define MAXDATA	150000

/* -- Quantum size ( in shorts ) for text segment(roughly 3*INSQUANTUM).
   -- */
#	define TXTQUANTUM	1500

/* -- Maximum number of declared functions.
   -- */
#	define MAXFUNC		256

/* -- Maximum number of parents for "place" message lists.
   -- */
#	define MAXPARENTS	20

/* -- Size of an error message ( including trailing '\0' )
   -- */
#	define MAXEMSG		100

/* -- Indicates that the variable being created relates to
	- an ordinary variable
	- a structure
	- a function
	- an external
   -- */
#	define CREAT_NORMAL	0
#	define CREAT_FUNVAR	2

/* -- Where a variable declaration takes place.
   -- */
#	define IN_GLOBAL	1
#	define IN_STRUCT	2

/* -- That should come up to 255.
   -- */
#	define BYTEMASK	( ( 1 << CHAR_BIT ) - 1 )

/* -- Code of for `MKname' function of the name it should generate.
      Respectively:	auxilliary VARiable
      			ConStanT
      			INDdirection
      			ARRay
      			STruct Pointer
      			STruct Field
      			function ARGument
      			typeINIt
      			overloaded OPeRator
   -- */
#	define VAR 0x100
#	define CST 0x200
#	define IND 0x400
#	define ARR 0x800
#	define STP 0x1000
#	define STF 0x2000
#	define ARG 0x4000
#	define INI 0x8000
#	define OPR 0x10000

/* -- Values of "Def" field of type `PCItype' :
      BASIC : char, short, int, double
      TYPDF : defined through a `typedef'
      STRUC : a structure
      UNION : a union
      ENUMT : an enumerated data type
   -- */
#	define BASIC	0
#	define TYPDF	1
#	define STRUC	2
#	define UNION	3
#	define ENUMT	4

/* -- Values of "Fpt" field of type `PCItype' :
      FCNDCL: if variable corresponds to, say : "int f() ;"
      FCNPTR: if variable corresponds to, say : "int (*f)() ;"
      Both must not be #define to 0.
   -- */
#	define FCNDCL	1
#	define FCNPTR	2
 
/* -- Values of "loc", "sto" and "use" fields of type `PCIcontext'.
   -- */
#	define cxGLOBL	0
#	define cxTYPDF	1
#	define cxFIELD	2
#	define cxFNARG	3
#	define cxOPARG	4
#	define cxTIARG	5
#	define cxLOCAL	6

#	define cxEXTRN	0
#	define cxSTATC	1

#	define cxNORML	0
#	define cxFUNCT	1

/* -- Bit setting in PCIsts( ... ) for user-defined functions.
   -- */
#	define CI_USER	0x8

/* -- Additionnal types for arguments of operators and typeinits:
	CI_INTEGER : int compatible with char/short/int
	CI_NUMERIC : double compatible with char/short/int/double
	MUST fit in a char.
   -- */
#	define CI_INTEGER	100
#	define CI_NUMERIC	101
#	define CI_LONG		102
#	define CI_UNSIGNED	103
#	define CI_FLOAT		104

/* -- Encountered identifiers  instructions which may not have been declared are
      functions,  objects  targets  of  message  in "send" instruction.
   -- */
#	define iNORMAL	0
#	define iFUNCTN	1
#	define iTARGET	2

/* -- Symbol kind (must be between 0 and 255).
   -- */
#	define SYM_ENUM_TAG	1
#	define SYM_ENUM_MMB	2
#	define SYM_LABL_NAM	3
#	define SYM_UNST_TAG	4
#	define SYM_TYPE_NAM	5
#	define SYM_SYST_FCN	6
#	define SYM_GVAR_NAM	7
#	define SYM_LVAR_NAM	8

/* -- Label types
	Internal: WHile STaRt, WHile END, DO STaRt, DO CoNTinue, DO END,
	          FoR TeST, FoR END, FoR STaRt, FoR EXPression, IF ELSe, IF END,
	          SWitch TeST, SWitch CASe, SWitch DeFauLt, SWitch END
		  FunctioN LABel
	User    : User LABel
   -- */
#	define WH_STR	1
#	define WH_END	2
#	define DO_STR	3
#	define DO_CNT	4
#	define DO_END	5
#	define FR_TST	6
#	define FR_END	7
#	define FR_STR	8
#	define FR_EXP	9
#	define IF_ELS	10
#	define IF_END	11
#	define SW_TST	12
#	define SW_CAS	13
#	define SW_DFL	14
#	define SW_END	15
#	define FN_LAB	16
#	define US_LAB	17

/* -- Jumps: goto, user function call or conditionnal (in this case the value is
      the index  of the  variable upon which  the test must  be performed and is
      positive ).
   -- */
#	define jmpGOTO	(-1)
#	define jmpFUNC	(-2)

/* -- Variable used, not used or ignore if it was used or not.
   -- */
#	define VAR_NOT_USED	0
#	define VAR_USED		1
#	define VAR_IGNORE	2
#endif
