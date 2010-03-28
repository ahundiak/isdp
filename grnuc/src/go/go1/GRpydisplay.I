/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;

#include "grimport.h"
#include  "igrdef.h"
#include  "msdef.h"
#include  "gocmacros.h"
#include  "godef.h"
#include  "dpmacros.h"
#include  "dpdef.h"

extern    IGRboolean    MApytobc();
extern    IGRboolean    MApyextents();

IGRlong GRpydisplay(msg,polyline,display_attr,mode,display_info)

IGRlong *msg;
struct  IGRpolyline *polyline;
struct  IGRdisplay  *display_attr;
enum    GRdpmode    *mode;
struct  GRid        *display_info;
					/* must be a module object	*/

{

    IGRlong    OMmsg;			/* OM return value		*/

    GRrange    range;			/* range of element		*/

    struct     DPele_header ele_header;	/* display element header	*/

    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    dp$build_dis_buffer(buffer = &ele_header,
		    type = IGRPY,
		    range = range,		
		    level = NULL,	/* level already checked	*/
		    display_att = display_attr, 
		    ele_spec_att = NULL,/* none for polyline stroker	*/
		    geometry = polyline);
	
    MApyextents(msg,polyline,ele_header.range,&ele_header.range[3]);

    if ( 1 & *msg)
    {
    	OMmsg = dp$display (msg = msg,
		objid = display_info->objid,
		osnum = display_info->osnum,
		mode = *mode,
		buffer = &ele_header,
		num_elem = 1);
    }
    else
    {
	OMmsg = OM_E_ABORT;
    }


    return (OMmsg);
}

end implementation GRvg;
