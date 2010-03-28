/* #######################    APOGEE COMPILED   ######################## */
#include "coimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "igrdef.h"
#include "dpmacros.h"

IGRint DYmsang3pt( header,
                    cursor_pt,
                    objects,
                    matrix,
                    num_objects,
                    buffer,
                    num_buffers,
                    in_dummy1,
                    in_dummy2,
                    in_dummy3,
                    out_dummy1,
                    out_dummy2,
                    out_dummy3 )

    struct DPele_header      *header;  /* points to an array of two polylines */
    struct   EX_button       *cursor_pt;
    struct   GRid           **objects;
    IGRdouble                *matrix; 
    IGRint                   *num_objects;
    struct DPele_header     **buffer;
    IGRint                   *num_buffers;
    IGRchar                 **in_dummy1;
    IGRchar                 **in_dummy2;
    IGRchar                 **in_dummy3;
    IGRchar                 **out_dummy1;
    IGRchar                 **out_dummy2;
    IGRchar                 **out_dummy3;

{

    *buffer = header;
    *num_buffers = 2;

    header++;

    header->geometry.polyline->points[3] = cursor_pt->x;
    header->geometry.polyline->points[4] = cursor_pt->y;
    header->geometry.polyline->points[5] = cursor_pt->z;

    return( MSSUCC);
}

/*-----------------------------------------------------------------------
 *
 *                Rubber band measure angle by 3 points
 *
 *-----------------------------------------------------------------------
 */ 

IGRlong DYrbmsang3pt( Events, dis_attr )

 struct GRevent             *Events[];
 struct IGRdisplay          *dis_attr;

{
    struct     DPele_header   header[2];
    struct     IGRpolyline    base;
    struct     IGRpolyline    sweep;
    IGRdouble                 base_buffer[6]; 
    IGRdouble                 sweep_buffer[6];

    base_buffer[0] = Events[0]->event.button.x;
    base_buffer[1] = Events[0]->event.button.y;
    base_buffer[2] = Events[0]->event.button.z;

    base_buffer[3] = Events[1]->event.button.x;
    base_buffer[4] = Events[1]->event.button.y;
    base_buffer[5] = Events[1]->event.button.z;

    sweep_buffer[0] = Events[1]->event.button.x;
    sweep_buffer[1] = Events[1]->event.button.y;
    sweep_buffer[2] = Events[1]->event.button.z;

    base.num_points = 2;
    base.points = base_buffer;

    sweep.num_points = 2;
    sweep.points = sweep_buffer;

    dp$build_dis_buffer( buffer      = &header[0],
                         type        =  IGRPY,     
                         display_att =  dis_attr,
	                 geometry    = (struct IGRpolyline *) &base  );

    dp$build_dis_buffer( buffer      = &header[1],
                         type        =  IGRPY,     
                         display_att =  dis_attr,
	                 geometry    = (struct IGRpolyline *) &sweep  );

    dp$dynamics( dyn_fun = DYmsang3pt, 
		 information = header );
 
    return ( TRUE );
}
