#ifndef	  sf_convert_struct

/*
 File dependency :

 This include dependes on the following files :

   ACrg_collect.h
   go.h
*/

#define   sf_convert_struct

/*
 * structure used for converting all elements in file
 */

struct  SFConvOpt {
	struct GRmd_env	  	RefEnv;
	struct GRmd_env	  	MasterEnv;
	struct GRvg_construct	cst;
	char			PlateSurfOpt[ATTR_TXT];
	double			offset;
	IGRboolean		ExtractStiffs;
	char			BmExtractOpt[ATTR_TXT];
	int			ElemType;
	int			NbFemElem;
	int			ConvAllEl;
	char			reffile_writable;
};

#endif
