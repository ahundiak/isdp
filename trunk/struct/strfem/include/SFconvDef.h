#ifndef  sf_convert_def

#define  sf_convert_def

/*
 * Name of the dir. and attribute names
 */

#define SFconvOptDir	":ConvOpt"

#define SF_TXT_PL_SURF  "PlateSurface"
#define SF_TXT_OFFSET   "Offset"
#define SF_TXT_BM_EXTR  "BeamExtract"
#define SF_TXT_ELEM_TYPE "ElemType"
#define SF_TXT_FEM_ELEMS "NbFemElem"
#define SF_TXT_CONV_ALL  "ConvAllEl"

/*
 * plate conversion options
 */ 
#define SF_TXT_TOP_SURF  "top surface"
#define SF_TXT_MID_SURF  "mid surface"
#define SF_TXT_BOT_SURF  "bot surface"
#define SF_TXT_KEYIN	 "keyin"

/*
 * beam and stiffener conversion options
 */ 

#define SF_TXT_MESHING	 	"meshing"
#define SF_TXT_TRACE_CURVES	"trace curves"
#define SF_TXT_EQUI_PLATES	"plates"
#define SF_DEFAULT_MESH_SIZE	4
#define SF_FEM_MESH_WEIGHT	1.0

/*
 * defines for conversion option
 */

#define  SF_TXT_ALL_ELEM    "All Elements"
#define  SF_TXT_UNCONV_ELEM "Unconverted Elements"

/*
 *  Name of the attribute added to plates ans stiffeners
 *  when they are converted
 */
#define  SF_TXT_FEM_CONVERTED "__FEMconverted"


#endif
