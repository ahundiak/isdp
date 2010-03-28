/*
 * History
 *      dhm   11/23/93   Added code to handle different versions of the dpb.
 */

#include "OMminimum.h"
#include "ex.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "OMport.h"

struct GRdpb_instance {
long layer[32];
struct OM_sd_varlenarr_descr data;
struct OM_sd_varlenarr_descr elclass;
struct OM_sd_varlenarr_descr classids;
};

#if defined(__STDC__) || defined(__cplusplus)
GRdpb_OMPORT_GRdpb(short classid, char *ME, struct GRdpb_instance *me)
#else
GRdpb$GRdpb(classid, ME, me)
short classid;
char *ME;
struct GRdpb_instance *me;
#endif
{

	int sts;
	char *dpb;
        char template[15];
	short version;
        struct GRdpbdata *dpbdata;

#if defined(__STDC__) || defined(__cplusplus)
	dpb = (char *)((unsigned int) (&me->data) +
		   OMPORT_INTEGER_VALUE (&me->data.i_offset) );
#else
	dpb = (char *)((unsigned int) (&me->data) +
		   om$integer_value (&me->data.i_offset) );
#endif

        /*
         * Get the version stamp of the dpb in order to see which template to
         * pass to the conversion routine.
         */

        dpbdata = (struct GRdpbdata *)dpb;
        version = dpbdata->version;

#if defined(__STDC__) || defined(__cplusplus)
        version = OMPORT_SHORT_VALUE(&version);
#else
        version = om$short_value(&version);
#endif

        /*
         * Need to handle all the different versions of the dpb. Find the 
         * correct conversion template and pass it to the conversion
         * routine. If new fields are added to the 'struct GRdpbdata',
         * then another case will have to be added to handle the 
         * older version. The default case can always be the current version
         * of the dpb. Add the template names to $GRNUC/dict/dpb_data.T and
         * change $GRNUC/include/grdpb.h to have a struct with the old dpb
         * data in it.
         */

        switch (version)
        {
          case 0:
            /* DPB_VERSION  0 */
            strcpy(template, "GRdpb_data0");
            break;

          case 1:
            /* DPB_VERSION  1 */
            strcpy(template, "GRdpb_data1");
            break;

          default:
            /* DPB_VERSION  2/3 */
            strcpy(template, "GRdpb_data");
            break;

        }

#if defined(__STDC__) || defined(__cplusplus)
        sts = OMPORT_CONV_BY_TEMPLATE_NAME(dpb, template, 1);
#else
        sts = om$conv_by_template_name(dpb, template, 1);
#endif

        if(!sts) return(0);

        return(1);

}
