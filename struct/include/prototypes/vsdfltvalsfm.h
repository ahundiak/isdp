/*
	I/STRUCT
*/

#ifndef vsdfltvalsfm_include
#	define vsdfltvalsfm_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef vscmd_include
#	include "vscmd.h"
#endif

#ifndef vsdefltvalue_include
#	include "vsdefltvalue.h"
#endif

/*
 * Gadget labels on form `VS_K_DFLTVALS_FORM'.
 */
#define VS_K_DFLFL_FLD	11	/* Fld: to enter file name		*/
#define VS_K_DFLTS_MCF	13	/* Mcf: names + values			*/
#define VS_K_DFLVL_FLD	16	/* Fld: possible values for one name	*/
#define VS_K_SRCHF_BTN	17	/* Btn: to invoke file-search form	*/
#define VS_K_VLCHC_TXT	18	/* Txt: title of choice for values	*/

/*
 * Column # in MCF 'VS_K_DFLTS_MCF'
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
	VSfileFormInfo	fileInfo ;
	VSdefaultValues	*defaultValues ;
} VSdfltValsInfo ;

extern void
VSdeleteDftlValsForm		__(( char *pForm )) ;

extern char
*VScreateDefaultValuesForm	__(( int x, int y, VSdfltValsInfo *info )) ;

extern void
VSexplainDefaultValuesForm __(( char *pForm, int label )) ;

#endif
