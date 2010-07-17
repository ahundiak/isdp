class implementation VLconnect;

#include	"vlprototype.h"
#include	<string.h>
#include	"AS_status.h"
#include	"nddef.h"
#include	"grmacros.h"
#include	"bsparameters.h"
#include	"expression.h"
#include	"expmacros.h"
#include	"asmacros.h"
#include	"DIdef.h"

#include	"vlconnect.h"
#include	"vlmiscmacros.h"

/*	#define	TRACE	*/

/* ========================================================================== */
method ACconstruct_feet ( 		IGRlong		*msg;
			 		IGRint		cn_type;
			 		IGRint		count;
			 struct		GRid		list[];
			 struct		GRmd_env	*md_env;
					IGRint		*fcount;
			 struct		GRid		*feet_list )
{

		IGRint		sts;
	struct	GRid		source;
		IGRchar		nam[DI_PATH_MAX], str[DI_PATH_MAX];

#ifdef TRACE
printf("\t>>> Enter in VLconnecti.ACconstruct_feet\n");
#endif

	/* Initialize */
	*fcount = MACRO_VC_FEET;

	/* Retrieve source object */
	sts = vl$return_foot ( msg    = msg,
 			       objId  = &list[IDX_VCT_OBJ],
			       footId = &source );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot(OBJ)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "OBJECT : (%d|%d) --> (%d|%d)\n", 
	list[IDX_VCT_OBJ].osnum, list[IDX_VCT_OBJ].objid,
	source.osnum, source.objid );
#endif

	/* Retrieve source name */
	nam[0] = '\0';
	sts = om$send ( msg = message GRvg.GRgetname ( msg, nam),
                  	senderid = NULL_OBJID,
                  	targetid = source.objid,
                  	targetos = source.osnum );
        if (!(sts & 0x00000001 & (*msg))) {
		strcpy ( str, "Unamed");	*msg = MSSUCC;	}
        else	strcpy ( str, &strrchr(nam,':')[1] );
        if (str[0] == '\0') strcpy ( str, "Empty");
#ifdef TRACE
printf( "NAME returned is <%s> --> <%s>\n", nam, str);
#endif

	/* Create foot expression */
	sts = exp$create ( exp_syntax = str,
                           p_exp_id   = &feet_list[IDX_VCF_NAM].objid,
                           osnum      = md_env->md_id.osnum,
                           p_osnum    = &feet_list[IDX_VCF_NAM].osnum,
                           type_rq    = EXP_TEXT);
        as$status ( sts    = sts,
                    msg    = "exp$create(NAM)",
                    test   = (sts != EXP_S_SUCCESS),
                    action = GOTO_VALUE,
                    value  = wrapup );

#ifdef TRACE
printf("\t<<< Exit from VLconnecti.ACconstruct_feet\n");
#endif

wrapup:
	return (sts);
}

end implementation VLconnect;
