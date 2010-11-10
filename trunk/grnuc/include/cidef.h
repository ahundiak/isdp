#ifndef _CIDEF_H
#define _CIDEF_H 1

/*
 * File of #defined constants for ci.
 */
// The pulls in MAXPATHLEN of 1024
#include <sys/param.h>

/* ============================================================
 * The posix stuff is nonsense, just hard code for now
 */
#ifndef _POSIX_NAME_MAX
#define _POSIX_NAME_MAX 14
#endif

#define CI_PATH_MAX  MAXPATHLEN
#define CI_NAME_MAX  _POSIX_NAME_MAX

#ifndef CIDEF_INCLUDE
#	define CIDEF_INCLUDE 

/* -- Conditionnal compilation flags.
   -- */
#	define CIASSOC		1
#	define CIREADRTREE	1
#	define CI_NO_SIG_TRAP	1

/* -- Self explanatory.
   -- */
#	define CI_VERSION_NUMBER "1.2"

/* -- CI object		- IS loaded with a PPL file.
			- IS executing
			- IS stacked ( in the Command Object sense )
      The following masks must fit in a short int.
   -- */
#	define CI_LOADED_WITH_PPL	0x8
#	define CI_EXECUTING_PPL		0x1
#	define CI_STACKED_AS_A_CO	0x2

/* -- Directory where to look for files in product's paths.
   -- */
#	define CI_SYS_SRC_DIR	"ppl/bin"

/* -- Name of ASCII file containing the external symbols for dynamic linking.
   -- */
#	define CI_EXT_SYM_FIL	"ci.X"

/* -- Maximum number of characters which may be displayed by the screen manager
      in the message, prompt and status fields.
   -- */
#	define CI_MAX_SMGR_MSG_SIZE	54

/* -- Maximum size of argument string ( not including ending '\0' ).
   -- */
#	define CI_MAX_ARGSTRING		CI_MAX_SMGR_MSG_SIZE

/* -- Maximum number of arguments.
   -- */
#	define CI_MAX_ARGS		(CI_MAX_ARGSTRING/2)

/* -- Maximum length of a version string 
   -- */
#	define CI_MAX_VERSION	80

/* -- Maximum number of parameters in an instruction
   -- */
#	define MAXPARAM		32

/* -- Maximum number of simultaneously open files
   -- */
#	define MAX_FILE		40

/* -- Maximum size of PPL function stack
   -- */
#	define MAXSTACK		40

/* -- Maximum length of PPL file tag (including ending '\0' )
   -- */
#	define CI_MAXTAG	256

/* -- Options included in ".e" file tag.
   -- */
#	define CI_QUIET_STRING	"<q>"
#	define CI_NOMSG_STRING	"<m>"
#	define CI_KEEP_STRING	"<k>"
#	define CI_TAGOPT_SIZE	3

/* -- The following bit masks apply to a short int.
   -- */
#	define CI_QUIET_MODE	0x01
#	define CI_NOMSG_MODE	0x02
#	define CI_KEEP_MODE	0x04

/* -- Actions for cidocmd() implementing PPL's begincmd(), begincmd_key(),
      endcmd(), docmd, dokey.
   -- */
#	define CI_DOCMD_STR	0	/* Begin command string	*/
#	define CI_DOCMD_KEY	3	/* Begin command key	*/
#	define CI_DOCMD_RESET	2	/* Reset function	*/
#	define CI_DOCMD_END	1	/* End command		*/

/* -- Values returned by function CIexecute().
   -- */
#	define CI_EXEC_FINISHED	0	/* PPL file execution complete	*/
#	define CI_EXEC_SUSPNDED 1	/* Execution interrupted	*/
#	define CI_EXEC_CLEAREVQ	2	/* Clear event queue		*/

/* -- Flags for I/O files or pipes ( P_... )
   -- */
#	define READ_BIT		1	
#	define WRITE_BIT	2
#	define P_READ_BIT	4
#	define P_WRITE_BIT	8

/* -- Maximum size of buffer to read in the rtree
   -- */
#	define SZ_RTREE_FIFO	20

/* -- Instruction statuses
	- instruction failed
	- instruction completed successfully
	- go back to cmdserver for stacking
	- flush event queue
   -- */
#	define IFAILED		0
#	define ISUCCESS		1
#	define ISTACK		(-1)
#	define IFLUSH		(-2)

/* -- Flags variable as a pointer
   -- */
#	define PTR		0x40

/* -- Basic instructions for ci generated code
   -- */
#	define FCALL		1	/* function call		*/

#	define IASSIGNTI	2	/* int	  = int			*/
#	define DASSIGNTD	3	/* double = double		*/
#	define ASSIGNT		4	/* All the rest			*/
#	define ASSIGNTADDR	6	

#	define BRANCH		7	
#	define IBRANCHCOND	8	/* conditionnal branch on int	*/
#	define BRANCHFUNC	9	/* branch to function		*/
#	define ASSIGNTCAST	10
#	define BRANCHXTRN	11

#	define IADDI		12	/* arithmetical operations	*/
#	define DADDD 		13	/* int    OP int   		*/
#	define IADD		14	/* double OP double		*/ 
#	define DADD		15	/* num    OP num, int result	*/
#	define IMINI		16	/* num    OP num, double result	*/
#	define DMIND		17
#	define IMIN		18
#	define DMIN		19
#	define IMULI		20
#	define DMULD		21
#	define IMUL 		22
#	define DMUL 		23
#	define IDIVI		24
#	define DDIVD		25
#	define IDIV 		26
#	define DDIV 		27
#	define IMODI		28

#	define PPLUS	  	30	/* pointer arithmetics		*/
#	define PMINUS	  	31	/* ptr+int, ptr-int, ptr-ptr	*/
#	define PDELTA	  	32

#	define OPPOS		33	/* unary operators		*/
#	define INEGBOOL		73	/* ! int			*/
#	define NEGBOOL		34	/* ! all the rest		*/

#	define IEQ		35	/* relational operators		*/
#	define DEQ		36
#	define EQ 		37
#	define INE		39
#	define DNE		40
#	define NE 		41
#	define IGT		43
#	define DGT		44
#	define GT 		45
#	define IGE		47
#	define DGE		48
#	define GE 		49
#	define ILT		51
#	define DLT		52
#	define LT 		53
#	define ILE		55
#	define DLE		56
#	define LE 		57

#	define CALCINDEX	59	/* for arrays			*/

#	define IAND		72	/* logical operators		*/
#	define AND		60
#	define IOR		75 
#	define OR		61

#	define BITAND		62	/* bitwise operator		*/
#	define BITOR		63
#	define BITEOR		64	/* exclusive or			*/

#	define BREAK		65
#	define CONTINUE		66
#	define EXIT_FILE	67
#	define RETURN		68
#	define BITNEG		69
#	define STRUCTFIELD	70
#	define STRUCTPTR  	71
#	define IMOD		74

#	define MEMEQU		76
#	define MEMDIF		77
#	define MEMCPY		78

#	define PUSHVAL		79
#	define PULLVAL		80
#	define PUSHADR		81
#	define PULLADR		82

#	define BRANCHSW		83	/* switch			*/
#	define DBRANCHCOND	84	/* conditionnal branch on double*/

#	define LSHIFT		85	/* left shift operation		*/
#	define RSHIFT		86	/* right shift operation	*/

/* -- C-style variable types
   -- */
#	define CI_VOID		0	
#	define CI_CHAR		1	
#	define CI_SHORT		2
#	define CI_INT		3
#	define CI_DOUBLE	4
#	define CI_GROBJ		8
#	define CI_STRING	7
#	define CI_STRUCT	5

/* -- Flags  a variable as
	- a function
	- an external reference
   -- */
#	define CI_FUNC		0x1
#	define CI_XTRN		0x2
#	define CI_FNPT		0x4

#endif

#endif
