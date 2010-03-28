/*-------------------------------------------------------------------------
  !!!! NOTE !!!!!
 	All arrays in this header file MUST always be synchronized with
	the symbolic constants in TRprod_type.h
 -------------------------------------------------------------------------*/ 

#ifndef TRprod_name_include
#define TRprod_name_include	1

#include "TRprod_type.h"

/*
 * Flag that identifies whether a product was loaded already
 */
int    TRprod_load[NUM_TR_PROD] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};


/* 
 * Name of all formats a model can be saved in 
 */
char   *TRprod_name[NUM_TR_PROD] = 
			{	"EMS",
			 	"Iges",
			 	"Ciges",
			 	"Vdais",
			 	"Dxf",
			 	"Vdafs",
			 	"Fst",
			 	"Cgm",
				"Emstv",
				"Emsmstn",
				"Emscadds",
				"Emscatia",
				"Emsddn",
				"Emsstep"
		      };

/* 
 * Extension of corresponding file format 
 */
char   *TRprod_extension[NUM_TR_PROD] =
		       {	"ems",
				"igs",
				"igs",
				"igs",
				"dxf",
				"vda",
				"fst",
				"cgm",
				"",
				"dgn",
				"_pd",
				"cat",
				"ddn",
				"stp"
		       };


#endif 	/* TRprod_name.h	*/

