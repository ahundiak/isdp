
/* define use with symbol macro */


#define	CHG_PATH	"constructs_lib"
#define	NEW_PATH	"models_lib"

/* symbologie state */
#define AC_USE_HEAD_COLOR	0x1	/* bit 0 */
#define AC_USE_HEAD_WEIGHT	0x2	/* bit 1 */
#define AC_USE_HEAD_STYLE	0x4	/* bit 2 */
#define AC_USE_HEAD_LEVEL	0x8	/* bit 3 */
#define AC_USE_HEAD_DISP	0x7	/* bit 0 to 2 */
#define AC_USE_HEAD_SYMB	0xf	/* bit 0 to 3*/

#define MAX_NB_TF_FOOT	25
#define path_MAX_CHAR	160

/* structure to store true false feet */

struct	tf_foot
{

	struct	GRid	tf_id;
	struct	GRid	foot;
	IGRchar		tf_name[path_MAX_CHAR];

};


