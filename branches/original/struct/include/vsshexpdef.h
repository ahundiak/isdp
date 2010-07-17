/*
	I/STRUCT
*/
#ifndef vsshexpdef_include
#define vsshexpdef_include

/*
 * Name of input graphics for a shell expansion.
 */
#define VS_K_sxShell		"shell"
#define VS_K_sxBaselinePl	"baselinePlane"
#define VS_K_sxBeginPl		"beginPlane"
#define VS_K_sxEndPl		"endPlane"
#define VS_K_sxYTrans		"yTranslation"

/*
 * Name of output graphic for a shell expansion.
 */
#define VS_K_sxShellExpansion	"shellExpansion"

/*
 * Name of input graphics for a curve to expand.
 */
#define VS_K_sxCurve		"curve"

/*
 * Name of output graphic for a curve to expand.
 */
#define VS_K_sxExpandedCurve	"expandedCurve"

/*
 * Name of input graphics for a merged shell expansion.
 */
#define VS_K_sxFrShellExp	"fromShellExp"
#define VS_K_sxToShellExp	"toShellExp"

/*
 * Name of output graphic for a merged shell expansion.
 */
#define VS_K_sxMergedShellExp	"mergedShellExp"

/*
 * Flag attribute of shell expansion.
 */
#define VS_K_sxUseYTranslation	0x1

/*
 * Type of shell expansion.
 */
enum VSshell_type { VSoriginal, /* Original shell expansion ( not used in a   */
				/* merged shell expansion.		      */
		    VSfrom,	/* Used in a merged shell expansion as the    */
				/* "from" shell expansion.		      */
		    VSto } ;	/* Used in a merged shell expansion as the    */
				/* "to" shell expansion.		      */

#endif
