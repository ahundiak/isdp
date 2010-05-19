/*
	I/VDS	Copy
*/
#ifndef v_drwdef_include
#	define v_drwdef_include

/*
 * Types of input elements which may be extracted to the drawing sheet:
 * - plate
 * - beam/stiffener
 * - joint (weld)
 * - construction (macro occurrence)
 */
#define	VD_m_inputPLATE	0x01
#define VD_m_inputBEAM	0x02
#define VD_m_inputSTFNR	(VD_m_inputBEAM | 0x04)
#define VD_m_inputJOINT	0x08
#define VD_m_inputCONST	0x10

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
#define VD_K_VIEW_CONE_ANGLE	40.	/* degrees */

/*
 * Default style for hidden lines.
 */
#define VD_K_HIDDEN_STYLE     1
#define VD_K_LEVEL            1022


/*
 * Value stating that text justification has not been set by user in the
 * Drawing Configuration file.
 */
#define VD_K_DRW_JUST_NOT_SET	(-1)

/*
 *  Path relative to product of Drawing Configuration directory.
 */
#define VD_K_DRW_PROD_RELPATH	"config"

/*
 *  Path relative to product of Drawing Configuration directory.
 */
#define VD_K_DRW_CONFIG_RELPATH	"config/drawing"

/*
 * Path relative to product of Drawing Configuration file.
 */
#define VD_K_DRW_SETUP_RELPATH	"config/drawing/setup"

/*
 * Invalid color name of number (returned value from the function checking
 * the validity of colors specified by user in the Drawing Configuration file.
 */
#define VD_K_DRW_INV_CLR_NUM	(-1)
#define VD_K_DRW_INV_CLR_NAM	(-2)

/*
 * Name of default font.
 */
#define VD_K_DRW_DFLT_FONT	"default"

/*
 * visualization process types.
 */
#define	VD_K_DRW_EDGES_A	0x0001		/* visible edges only	*/
#define	VD_K_DRW_EDGES_B	0x0010		/* opaque edges		*/
#define	VD_K_DRW_EDGES_C	0x0100		/* hidden edges		*/	

#define	VD_K_ENV_PROCESS_TYPE	0x1000		/* envelope edges	*/

#define	VD_K_DRW_PROCESS_A	0x0001		/* visible edges only	*/
#define	VD_K_DRW_PROCESS_B	0x0011		/* opaque + visi edges	*/
#define	VD_K_DRW_PROCESS_C	0x0111		/* vis+opaque+hidden	*/	

#define	VD_K_ENV_PROCESS_A	0x1001		/* visible edges only	*/
#define	VD_K_ENV_PROCESS_B	0x1011		/* opaque + visi edges	*/
#define	VD_K_ENV_PROCESS_C	0x1111		/* vis+opaque+hidden	*/	

/*
 * unit drawing types.
 */
#define VD_K_drwLevel_1      0x0001 
#define VD_K_drwLevel_2      0x0002 
#define VD_K_drwLevel_3      0x0004 
#define VD_K_drwLevel_4      0x0008 
#define VD_K_drwLevel_5      0x0010 
#define VD_K_drwTrans	     0x1000

#define VD_K_drwUsrLevel_A    1 


#endif
