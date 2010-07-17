#ifndef	vlcntrline_include
#define	vlcntrline_include

#define MAX_CHA_TEMP 20
#define plug_generic    0x00100000

/* Macro <CntrLine> generic data */
#define	MACRO_CntrLine	"CntrLine"
#define	MACRO_CL_FTEMP	1	
#define	MACRO_CL_VTEMP	100
#define	MACRO_CL_FFEET	3

/* Macro <CntrLine> templates name */
#define NAM_CL_BOX	"box"
#define	NAM_CL_VART	"plates"

/* Macro <CntrLine> templates index */
#define	IDX_CL_BOX	 0
#define	IDX_CL_PLATES	 1

/* Macro <CntrLine> feet name */
#define	NAM_CL_CV	"comp_curve"
#define	NAM_CL_VECT	"vector"

/* Macro <CntrLine> feet index */
#define	IDX_CL_CV	0
#define	IDX_CL_VECT	1
#define	IDX_CL_CONT	2

/* definition name */
#define MACRO_CL_LINE  "CntrLine"

/* --- Name of optional attributs store in attribute box --- */
#define N_ATT_VECT     	 "vector"
#define N_ATT_ONE_OR_ALL "flag"
#define N_ATT_PLATE_SIDE "name"
#define N_ATT_X_NORMAL   "xnorm"	/* add by MF	*/
#define N_ATT_Y_NORMAL   "ynorm"	/* add by MF	*/
#define N_ATT_Z_NORMAL   "znorm"	/* add by MF	*/
#define V_ATT_SINGLE     0
#define V_ATT_MULTIPLE   1
#define V_ATT_BOTTOM     0
#define V_ATT_TOP        1

#endif
