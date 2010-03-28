/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;

#include "grimport.h"
#include "transerr.h"

#argsused
IGRlong GUplot_symbol( msg, env, dgn_buf, bs_buf, ele_buf, ele_size,
			  file_des, max_overflow, symbol, flag )

    IGRlong		*msg;		/* pointer to message returned	*/
    struct GRmd_env	*env;		/* pointer to env structure	*/
    IGRchar		*dgn_buf;	/* IGDS i/o buffer		*/
    IGRchar		*bs_buf;	/* IGE structure buffer		*/
    IGRchar		*ele_buf;	/* IGDS element buffer		*/
    IGRint		*ele_size;	/* pointer to # bytes written	*/
    IGRint		*file_des;	/* pointer to file descriptor	*/
    IGRdouble		*max_overflow;	/* object key?			*/
    struct GRid		*symbol;	/* pointer to symbol object	*/
    IGRboolean		*flag;		/* 0 -> symbol,			*/
					/* 1 -> symbol reference	*/
{
    return ( GUsuccess );
}

end implementation GRvg;
