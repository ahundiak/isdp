/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;


#include "grimport.h"
#include "madef.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"

from GRsmhdr import GRget_components;

IGRlong GUprocess_symbol( msg, env, dgn_buf, bs_buf, ele_buf, ele_size,
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

    IGRlong		brc;		/* boolean return code		*/

    IGRboolean		local_flag;	/* just that			*/

    IGRint		count;		/* # of things on symbol chan	*/
    IGRint		i;		/* lcv				*/

    struct GRid		ref_def_header;	/* definition pointed to by ref	*/

    IGRint		number_objects=1; /* number of symbol definitions
					     on the symbol header	*/

    IGRint		from_obj;	/* base index			*/

    IGRint		to_obj;		/* high index			*/

    OM_S_CHANSELECT	chan_def;	/* channel selector		*/

    IGRdouble		scale_factor = 1.0;
                                       /* scale of EMS to IGDS working
                                          units		        	*/

    brc = GUsuccess;

    if ( *flag )
    {
        from_obj = 0;
        to_obj = OM_K_MAXINT;

	om$send ( msg = message GRsmhdr.GRget_components(
				msg, env, &ref_def_header,
				number_objects, &count, from_obj, 
				to_obj),
		  senderid = symbol->objid,
		  targetid = symbol->objid,
		  targetos = symbol->osnum );

	if ( ! (*msg & 1) )
	{
	    brc = 0;
	    goto wrap_up;
	}

	local_flag = 0;

/*	GUprocess_symbol( env, dgn_buf, bs_buf, ele_buf, ele_size,
			  file_des, &max_overflow, &ref_def_header,
			  &local_flag, msg );  */

        GUprocess_symbol( msg, env, dgn_buf, bs_buf, ele_buf, ele_size,
                          file_des, max_overflow, &ref_def_header,
                          &local_flag );

	goto wrap_up;

    }

    chan_def.type = OM_e_name;
    chan_def.u_sel.name = "to_components";

    om$get_channel_count ( osnum = symbol->osnum,
			   objid = symbol->objid,
			   p_chanselect = &chan_def,
			   count = (OMuint *) &count );

    for ( i = 0 ; i < count ; i++ )
    {
	om$send ( msg = message GRvg.GRformatele(
					msg , env, dgn_buf, bs_buf, ele_buf,
					ele_size, file_des, max_overflow,
					&scale_factor),
		  senderid = symbol->objid,
		  p_chanselect = &chan_def,
		  targetos = symbol->osnum,
		  from = i,
		  to = i );
    }

    wrap_up:
	return ( brc );

}

end implementation GRvg;
