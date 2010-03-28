/**************************************************************************
 * !!!! NOTE !!!!!
 *	NUM_TR_PROD and the index of each product MUST always be 
 *	synchronized with the character arrays contained in TRprod_name.h
 **************************************************************************/ 

#ifndef TRprod_type_include
#define TRprod_type_include	1

#define NUM_TR_PROD 14		/* Total number of supported translators */

#define EMS     0		/* Identifier (index) for EMS product */
#define IGES    1		/* Identifier (index) for IGES product */
#define CIGES   2		/* Identifier (index) for CIGES product */
#define VDAIS   3		/* Identifier (index) for VDAIS product */
#define DXF     4		/* Identifier (index) for DXF product */
#define VDAFS   5		/* Identifier (index) for VDAFS product */
#define FST     6		/* Identifier (index) for FST product */
#define CGM     7		/* Identifier (index) for CGM product */
#define TV	8		/* Identifier (index) for TV product */
#define EMSMSTN	9		/* Identifier (index) for EMSMSTN product */
#define CADDS   10              /* Identifier (index) for EMSCADDS product */
#define CATIA   11              /* Identifier (index) for EMSCATIA product */
#define EMSDDN  12              /* Identifier (index) for EMSDDN product */
#define EMSSTEP 13              /* Identifier (index) for EMSSTEP product */

/*
 * Switches used by PRODUCTdummy functions. They allow an interface
 * with the subforms of the translators.
 */

#define	DUMMY_MAIN		1 /* Execute main function in translator */
#define DUMMY_IN_OPTIONS	2 /* Execute "Retrieve" subform setup routine*/
#define DUMMY_IN_GETOPT_STRING	3 /* Retrieves options in "Retrieve" subform */
#define DUMMY_OUT_OPTIONS	4 /* Execute "Save As" subform setup routine*/
#define DUMMY_OUT_GETOPT_STRING	5 /* Retrieves options in "Save As" subform */
#define	DUMMY_FILTER		6 /* Run filter part (Ciges and Vdais only) */
#define DUMMY_IN_IS_CALMA	7 /* Recognize if process is IGES Calma translation*/
#define DUMMY_IN_GET_CALMA_OPT	8 /* Retrieves options for Calma translation */


#endif 	/* TRprod_type.h	*/
