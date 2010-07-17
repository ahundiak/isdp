/* $Id: VRlivlkup.h,v 1.1.1.1 2001/01/04 21:12:55 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrinclude / VRlivlkup.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/07/97   law          Created for Piping-livelookup CR179308634
 *      Feb 2000   Anand	Added for Rway live lookup (CR 179801143)
 *************************************************************************/


#ifndef VRlvlkup_include
#define VRlvlkup_include

#include "VRRDBdef.h" /* For const VRRDB_CHAR_CODE */

#define VR_R_LIVELOOKUP_LSTNUM	380

struct PipingLiveLookup
{
    /* Communication buffer */
    int not_proc_spec;
    int not_proc_fam_cl;
    int not_proc_fam_cd;
    int not_proc_cmp_cd;
    int not_proc_opt_cd;
    int not_proc_size;
    char spec_nam_txt[9];
    char spec_no_str[20];
    char loc_fam_class[9];
    char loc_fam_code[40];
    char loc_cmp_code[7];
    char list_nm_str[20];
    char loc_code_nm[20];
    char opt_code_des[80];
    char opt_code_num[8];
    char pdm_partnum[40];
    char comp_num_fld[80];
    double default_Rdia;
    double default_Gdia;
};

struct RwayLiveLookup
{
    IGRint	GadgProc;
    IGRshort	VendorNo;
    IGRshort	FamilyNo;
    IGRchar	CompCode[VRRDB_CHAR_CODE];
    IGRdouble	InlWidth;
    IGRdouble	InlDepth;
    IGRdouble	OutWidth;
    IGRdouble	OutDepth;
    IGRchar    *CompNumb;

    IGRchar	Macro[VRRDB_CHAR_FAM];
    IGRshort	CompTopo;
    IGRshort	ShapeCode;
    IGRshort	NbCpts;
    IGRchar	Sh_Code[VRRDB_CHAR_CODE];
};

union VRlivoutbuff
{
    struct PipingLiveLookup	piping;
    struct RwayLiveLookup	rway;
};

#ifndef DONT_EXTERN
extern int     VRPlvlkup	   __(( int first_entry, int *gad_label,
					Form fp, struct PipingLiveLookup *OB ));

extern IGRint  VRRacewayLiveLookUp __(( IGRlong *msg, Form fp,
	    				IGRint GadgetLabel,
					struct RwayLiveLookup *LivBuf,
					IGRboolean *Proc_LLU,
					IGRboolean *LLU_Form,
					char *FutureExpansion ));

extern IGRint  VRRwayTraySelector  __(( Form fp, IGRint Gadget,
	    				IGRint SketchMode,
					struct GRid *ParameterID ));
#endif

#endif
