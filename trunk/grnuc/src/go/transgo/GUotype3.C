/*
Name
        GUotype3

Description
        This utility function formats an IGDS type 3 line element
        according to the defining geometry, symbology, and properties.

History
        ???     ??/??/??    creation
        mrm     02/08/92    handle user-defined line styles
*/

#include "exsysdep.h"
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "msdef.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "dpdls.h"

struct type3_element
{
    struct GUcommon_header_info header;
    IGRlong points[6];
};

#argsused
IGRlong GUotype3(msg, file_des, dgn_buf, igds, igds_size, class_name, geometry,
                 range, symbology, geometric_props, properties, has_name, name)
IGRlong *msg;
IGRint *file_des;
IGRchar *dgn_buf;
struct type3_element *igds;
IGRint *igds_size;
IGRchar class_name[];
struct IGRbsp_curve *geometry;
GRrange range;
struct GRsymbology *symbology;
IGRshort *properties;
IGRboolean *has_name;
IGRchar *name;
{
    IGRshort i;			   /* lcv */
    IGRshort num_coordinates;	   /* for 2-D or 3-D */
    IGRshort type = 3;		   /* igds element type */
    IGRshort write_mode;	   /* mode for writing */
    IGRint block_ptr;
    IGRint byte_ptr;
    IGRlong brc = TRUE;		   /* return status */
    IGRlong lmsg;		   /* add ele name  */
    IGRdouble *dbl_ptr;		   /* array index */
    IGRshort   ndices;

    *msg = GUsuccess;

    /* call function to load header data */

    /* 12/9/86 found out infinite length lines use 4 poles and we should
       take the middle two. */

    if (!(strcmp(class_name, "GR3dinfline") &&
	  strcmp(class_name, "GR3iinfline") &&
	  strcmp(class_name, "GR2iinfline")))
    {
	dbl_ptr = &geometry->poles[3];

	for (i = 0; i < 6; i++)
	{
	    range[i] = (range[i] < -2147483647.0) ? -2147483647 : range[i];
	    range[i] = (range[i] > 2147483647.0) ? 2147483647 : range[i];
	}

    }
    else
    {
	dbl_ptr = geometry->poles;
    }

    GUload_IGDSheader(msg, class_name, &type, symbology, properties,
		      range, igds);

    if (*msg != GUsuccess)
    {
	brc = FALSE;
	goto wrap_up;
    }

    /* load integer points */

    if (!strncmp(class_name, "GR2", 3))
    {
	igds->header.words_to_follow = 24;
	*igds_size = 52;
	igds->header.index_to_ae = 10;

	num_coordinates = 4;

	igds->points[0] = GUnint(*dbl_ptr);
	dbl_ptr++;
	igds->points[1] = GUnint(*dbl_ptr);

	dbl_ptr += 2;
	igds->points[2] = GUnint(*dbl_ptr);
	dbl_ptr++;
	igds->points[3] = GUnint(*dbl_ptr);

	for (i = 0; i < 4; i++)
	{
	    GUswapint(&igds->points[i], &igds->points[i]);
	}
	ndices = 4;
    }
    else
    {
	igds->header.words_to_follow = 28;
	*igds_size = 60;
	igds->header.index_to_ae = 14;

	num_coordinates = 6;

	for (i = 0; i < 6; i++)
	{
	    igds->points[i] = GUnint(*dbl_ptr);
	    GUswapint(&igds->points[i], &igds->points[i]);
	    dbl_ptr++;
	}
	ndices = 6;
    }

    /* check whether a user-defined linestyle is present */
    if (symbology->display_attr.style >= BUILTIN_STYLES)
        GRaddStyleLinkage(&lmsg, symbology->display_attr.style, igds);

    /* If an element name is present, it will be added to the translated
       element's user data linkage in the igds design file. */
    GRadd_name_to_buf(&lmsg, has_name, name, igds);
#ifdef BIG_ENDIAN
    if (*has_name)
        GRswap_name_linkage(igds);
#endif

    *igds_size = (igds->header.words_to_follow + 2) * 2;
#ifdef BIG_ENDIAN
    GRswap_type3_ele(igds,ndices);
#endif
    write_mode = GUWRITE;
    brc = GUwrite_element(msg, dgn_buf, igds, &type, igds_size,
			  file_des, &write_mode, &block_ptr, &byte_ptr);

wrap_up:

    return (brc);
}
