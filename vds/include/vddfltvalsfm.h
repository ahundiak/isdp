/*
   I/VDS

   History:
     MM/DD/YY   AUTHOR  DESCRIPTION
     07/28/97   EJM	CR# 179602470: Added "Copy Attributes" capability,
			VD_K_SELCT_BTN, VD_K_UNSEL_BTN
*/


#ifndef vddfltvalsfm_include
#	define vddfltvalsfm_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef v_cmd_include
#	include "v_cmd.h"
#endif

#ifndef vddefltvalue_include
#	include "vddefltvalue.h"
#endif

/*
 * Gadget labels on form `VD_K_DFLTVALS_FORM'.
 */
#define VD_K_RESET_BTN	 3	/* Btn: resets form        	        */
#define VD_K_DFLFL_FLD	11	/* Fld: to enter file name		*/
#define VD_K_DFLFL_TTL	12	/* Txt: field label for file name       */
#define VD_K_DFLTS_MCF	13	/* Mcf: names + values			*/
#define VD_K_DFLVL_FLD	16	/* Fld: choices of values for one name	*/
#define VD_K_SRCHF_BTN	17	/* Btn: to invoke file-search form	*/
#define VD_K_VLCHC_TXT	18	/* Txt: title of choice for values	*/
#define VD_K_DFL_TITLE	19	/* Txt: title of form             	*/
#define VD_K_SELCT_BTN  20	/* Btn: to select all copy attributes   */
#define VD_K_UNSEL_BTN  21	/* Btn: to unselect all copy attributes */

/*
 * Column # in MCF 'VD_K_DFLTS_MCF'
 */
#define NAMES_COLUMN	0
#define VALUES_COLUMN	1

typedef struct {
	char		*parentForm ;
	char		*fileForm ;
	int		maxNumDefaults ;
	int		numDefaults ;
	int		currentDefault ;
	int		numDefaultsWanted ;
	void		(*callBack) __(( char *dftlValsForm,
					 char *parentForm,
					 int  exitType )) ;
	VD_fileFormInfo	fileInfo ;
	VDdefaultValues	*defaultValues ;
} VDdfltValsInfo ;

extern void
VDdeleteDftlValsForm		__(( char *pForm )) ;

extern char
*VDcreateDefaultValuesForm	__(( int x, int y, VDdfltValsInfo *info, int gLabel )) ;

extern void
VDexplainDefaultValuesForm __(( char *pForm, int label )) ;

#endif
