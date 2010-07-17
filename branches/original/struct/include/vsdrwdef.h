/*
	I/STRUCT
*/
#ifndef vsdrwdef_include
#	define vsdrwdef_include

/*
 * Types of input elements which may be extracted to the drawing sheet:
 * - plate
 * - beam/stiffener
 * - joint (weld)
 * - construction (macro occurrence)
 */
#define	VS_m_inputPLATE	0x01
#define VS_m_inputBEAM	0x02
#define VS_m_inputSTFNR	(VS_m_inputBEAM | 0x04)
#define VS_m_inputJOINT	0x08
#define VS_m_inputCONST	0x10

/*
 * Default value for the angle of the view cone, this angle is used to determine
 * the type of the view the element is seen through :
 *
 *        /
 *       /\
 * eye <)  ) angle  -- view vector -->
 *       \/
 *        \
 *         view cone
 *
 * All vectors falling within this cone will be considered parallel to the
 * view vector.
 * This angle is specified in degrees.
 */
#define VS_K_VIEW_CONE_ANGLE	40.	/* degrees */

/*
 * Default style for hidden lines.
 */
#define VS_K_HIDDEN_STYLE	3

/*
 * Value stating that text justification has not been set by user in the
 * Drawing Configuration file.
 */
#define VS_K_DRW_JUST_NOT_SET	(-1)

/*
 *  Path relative to product of Drawing Configuration directory.
 */
#define VS_K_DRW_CONFIG_RELPATH	"config/drawing"

/*
 *  Path relative to product of Joints Configuration directory.
 */
#define VS_K_JNT_CONFIG_RELPATH	"config/joints"

/*
 * Path relative to product of Drawing Configuration file.
 */
#define VS_K_DRW_SETUP_RELPATH	"config/drawing/setup"

/*
 * Invalid color name of number (returned value from the function checking
 * the validity of colors specified by user in the Drawing Configuration file.
 */
#define VS_K_DRW_INV_CLR_NUM	(-1)
#define VS_K_DRW_INV_CLR_NAM	(-2)

/*
 * Name of default font.
 */
#define VS_K_DRW_DFLT_FONT	"default"

#endif
