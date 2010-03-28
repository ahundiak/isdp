/*
 * Global variables and typedefs for CI compiler source files
 *
 */

#ifndef PCI_INCLUDE
#	define PCI_INCLUDE

#	include "pcidef.h"
#	include "cidef.h"
#	include <limits.h>
#	include <stdio.h>

typedef unsigned int	Uint	;
typedef unsigned short	Ushort	;
typedef unsigned char	Uchar	;

/* -- Operator associativity : Left to Right or Right to Left.
   -- */
typedef enum { LtoR = 0, RtoL = 1 } ASSOCIATIVITY ;

/* -- Operator instruction code, arity, associativity and name.
   -- */
typedef struct { Ushort icode;
		 Uint	arity:8,
			assoc:8	;
		 char	name[4] ;
} OPERATOR ;

/* -- Compiler options:
	noptrchk : do not check pointer copatibility
	noargchk : do not check actual/formal arg match in functions
	unusedfn : signal functions implemented but not used
	externfn : consider functions used but not implemented as extern
	prtxsyms : output external symbols encountered to .n file
	warnmsgs : output warning messages
	nomsgdel : do not refresh prompt/message areas when started
	noexinfo : supresses run-time info messages
	keepfile : do not remove file from memory after execution
   -- */
typedef struct {	unsigned 	noptrchk:1	,
					noargchk:1	,
					unusedfn:1	,
					externfn:1	,
					dumpinfo:1	,
					prtxsyms:1	,
					warnmsgs:1	,
					nomsgdel:1	,
					noexinfo:1	,
					keepfile:1	;
			FILE		*erlogstr	;
} PCIoptions ;

/* -- Element list, static or automatic ( array must be freed ).
   -- */
typedef struct { unsigned num	: 7 ;
		 unsigned free	: 1 ;
		 union {
		 	short Stat[LISTBUNCH]	;
		 	short *Auto 		;
		 } elt ;
} PCIlist ;

/* -- This typedef allows to avoid including lots of files.
   -- */
typedef unsigned long int OM_S_OBJID ;

/* -- Operator : its internal code and the instruction to which it belongs.
   -- */
typedef struct { int code, instr ; } PCIop ;

/* -- Buffer for identificators ( variables, functions, labels ).
   -- */
typedef char PCIident[MAXIDLEN] ;

/* -- Descriptor for string constants.
      - text	: pointer to text
      - length	: length of text, `length' is < 0 if `text' MUST NOT be freed.
   -- */
typedef struct { char *text ; short length ; } PCIstring ;

#define NULL_OBJID ( (OM_S_OBJID) -1 )

/* -- Maximum size for a file name ( including path ) on UNIX System V
   -- */
typedef char SysVfname[CI_PATH_MAX+1] ;

/* -- Type of a node in expression's syntactic tree.
   -- */
typedef enum { UNARY, BINARY, OPERAND, OFFSET } nodetype ;

/* -- Useful information about a union/structure field.
   -- */
typedef struct	{
			Ushort	size	, offset 	;
			Uint	align:7 , sign:1	;
} PCIfield ;


/* -- Type descriptor ( used for variables and typedef list )
      Dim : array dimension ( must be <= MAXDIM )
      Def : BASIC ( if char, short, int, or double )
            UNION if a union
            STRUC if a structure
            TYPDF if the type was defined by a "typedef"
      Ptr : 0 if not, 1: *<var>    , 2: **<var>   , etc. ( pointer to <type> )
      Fpt : FCNDCL : function declaration,
            FCNPTR : pointer to function ,
            FALSE  : ordinary variable.
      Rpt : if pointer to function ( Fpt == TRUE, Ptr != 0 ) :
            Ptr contains 1: (*<var>)(), 2: (**<var)(), etc., and Rpt contains
            the order of indirection of the returned value.
      Num : if BASIC contains CI_CHAR, CI_INT, CI_SHORT or CI_DOUBLE
               UNION or STRUC contains the struct index in the stucture list
               TYPDF contains the type index in the type list.
               
      E.g "int **(*f[10])()" has:
      		Def = BASIC, Num = CI_INT, Ptr = 1, Fpt = 1, Rpt = 2, Dim = 10

      WARNING: 1. Do not use bit fields in this structure
      	       2. Changing order or adding field implies to modify the
      	          initialization of a static arrays "ARG..." in cisysfcn.c.
      	        
   -- */
typedef struct _PCItype { 	Uchar  		Def, 
                                		Rpt,
                                		Ptr,
                                		Fpt ;
                                Ushort		Dim,
                                		Num ;
                                struct _PCItype *Spc ; } PCItype ;

/* -- Node.
   -- */
typedef struct {	Uchar type	;
			union {	Ushort		operand	;
				struct {
					PCIop		symbol  ;
					PCItype		result	;
				} operator ;
				PCIfield	field	;
			} info ;
} PCInode ;

/* -- Descriptor of context where a declaration takes place.
      - typ : type of declaration
      - loc : in a structure, global, in a typedef.
      - sto : extern or static.
      - use : as a normal variable or that associated with a function.
      - ref : operator argument is declared to be passed by reference.
      WARNING: do not use bit fields in this structure.
   -- */
typedef struct	{ PCItype	typ	;
		  Uchar		loc,
		  		sto,
		  		use,
		  		ref	;
		} PCIcontext ;

/* -- Descriptor for currently parsed structure/union variable.
      If "s.f1.f2.f3" is being parsed,
      - indx : index of `s' in the variable table
      - offs : offset of `f3' with respect to `s'
      - type : type of `f3'
      - oper : structure operator : "->" or "."
      - name : a name for the auxiliary variable generated ( "{s.f1.f2.f3" )
   -- */
typedef struct  { int		indx	;
                  unsigned	offs	;
                  char *	name	;
                  PCItype	type	;
                  PCIop		oper	;
		} PCIstrv ;

/* -- All purpose pointer type ( avoids messy castings ), pleases lint.
   -- */
typedef union { char		*Chr ;
		short		*Shr ;
		int		*Int ;
		double		*Dbl ;
		void		*Any ;
		char	       **Pch ;
		PCIstring	*Str ;
		OM_S_OBJID	*Obj ;
		int		 Val ; } PCIpointer ;

typedef char emsg[MAXEMSG] ;

typedef struct { Uint stat:2, func:8 ; } usage ;

/*		G	L	O	B	A	L	S             */
/*		-------------------------------------------------	      */

#	ifdef PCIGLOBALS
#		define VARSTAT
#	else
#		define VARSTAT extern
#	endif

/* -- Compiler option flag
   -- */
VARSTAT PCIoptions PCI_G_options ;

/* -- Currently scanned file ( takes the name of include files ).
   -- */
VARSTAT SysVfname PCI_G_curfile ;

/* -- Currently parsed line.
   -- */
VARSTAT Ushort PCI_G_curline ;

/* -- Currently parsed function.
   -- */
VARSTAT int PCI_G_curfunc ;

/* -- Allows to flag thet there was a syntax error but to continue parsing.
   -- */
VARSTAT char PCI_G_synerr ;

/* -- Flag enabling/disabling instruction generation.
   -- */
VARSTAT char PCI_G_genins ; 
  
/* -- Number of external references.
   -- */
VARSTAT int  PCI_G_externals ;

/* -- Remembers if a declared variable was used (0:not used/1:used/2:don't care)
   -- */
VARSTAT usage	PCI_G_used[MAXVAR] ;

/* -- Number of labels.
   -- */
VARSTAT int      PCI_G_nlabel ;

/* -- Type information about a variable.
   -- */
VARSTAT PCItype PCI_G_type[MAXVAR] ;

/* -- Pointer to compiled code structure
   -- */
VARSTAT struct instance_ci *PCI_G_p_code ;

/* -- Data and text segments addresses.
   -- */
VARSTAT struct { short		*text ;
                 char 		*data ; } PCI_G_segment ;

/* -- These allow to gain one indirection.
   -- */
VARSTAT char		**PCI_G_var ;
VARSTAT PCIpointer	 *PCI_G_adr ;
VARSTAT char		 *PCI_G_typ ;
VARSTAT short		 *PCI_G_dim ;
VARSTAT Uchar	 	 *PCI_G_sts ;

/* -- Index of dummy variable "~void".
   -- */
VARSTAT int		PCI_G_void ;

#endif

