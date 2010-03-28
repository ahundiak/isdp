/*
Name
        GUotype1214

Description
        This utility function formats an IGDS type 12 or type 14 element.

History
        ???     ??/??/??    creation
        mrm     02/08/92    handle user-defined line styles
        dhm     04/23/92    set the number of components here instead of
                            in GUcpxclose_string.
        jjm     10/08/92    took out byte-swapping code (BBIG_ENDIAN)
        dhm     04/09/93    TR 119304385 - took out jim's BBIG_ENDIAN code.
*/

class implementation GRvg;

#include "exsysdep.h"
#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "msdef.h"
#include "dpdls.h"

GUotype1214(msg, file_des, dgn_buf, cpxstring, igds_cpx_size,
	   class_name,  range, symbology, geometric_props,
	   properties, obj, env, bs_buf, has_name, name)

	IGRlong			*msg;
	IGRint			*file_des;
	IGRchar			*dgn_buf;
    	struct IGDS_complex	*cpxstring;
	IGRint			*igds_cpx_size;
	IGRchar			class_name[];
	GRrange			range;
	struct GRsymbology	*symbology;
	struct GRprops		*geometric_props;
	IGRshort		*properties;
	struct GRid		*obj;
	struct GRmd_env		*env;
	IGRchar			*bs_buf;
	IGRboolean		*has_name;
	IGRchar			*name;

{ /* begin GUotype1214 */

    IGRshort		i;			/* lcv			*/
    IGRint		number_components;	/* number of components	*/
    IGRshort		type = 12;		/* igds element type	*/
    IGRshort		write_mode;		/* mode for writing	*/

    IGRlong		brc = TRUE;		/* return status	*/
    IGRlong		status;			/* return status	*/

    IGRint		block_ptr;
    IGRint		byte_ptr;

    OM_S_CHANSELECT	chandef;		/* channel to get count	*/

    IGRint	    	previous_state,previous_offset;
    GRrange		local_range;
    IGRdouble		scale_factor=1;

extern IGRboolean       GUcheck_overflow();

    *msg = GUsuccess;

    chandef.type = OM_e_name;
    chandef.u_sel.name = "to_components";

    status = om$get_channel_count ( osnum = obj->osnum,
				    objid = obj->objid,
 				    p_chanselect = &chandef,
				    count = (OMuint *)&number_components );

    if ( ! (1 & status) )
    {
	goto wrap_up;
    }

	if ((geometric_props->phy_closed) && (geometric_props->planar))
	{
	    type = 14;
	}
	else
	{
	    type = 12;
	}

	/* If the complex string does not have a name, we have to pad
	 * it with dummy attributes.  This is a scanner requirement.
	 */

	if (*has_name)
	{
	    cpxstring->header.words_to_follow = 18;
	}
	else	    
	{
            cpxstring->header.words_to_follow = 22;
	}

	cpxstring->header.index_to_ae = 4;
	cpxstring->num_elements = number_components;
	cpxstring->dummy_linkage = 0;

	/*
	 *  call function to load header data.
	 */

	GUload_IGDSheader(msg, class_name, &type, symbology,
		properties, range, cpxstring);

	if ( 1 & *msg)
	{
            /* check whether a user-defined linestyle is present */
            if (symbology->display_attr.style >= BUILTIN_STYLES)
                GRaddStyleLinkage(msg, symbology->display_attr.style,
                                  cpxstring);

	    GRadd_name_to_buf(msg, has_name, name, cpxstring);
#ifdef BIG_ENDIAN
	    if (*has_name)
                GRswap_name_linkage(cpxstring);
#endif
	    cpxstring->wds_in_descript =  
		cpxstring->header.words_to_follow - 6;

	    *igds_cpx_size = (cpxstring->header.words_to_follow + 2) * 2;

	    GUcpxopen ( msg, dgn_buf, cpxstring, igds_cpx_size, file_des,
		&previous_state, &previous_offset );

	    /*
	     *  Write the complex shape header element to the file.
	     */

#ifdef BIG_ENDIAN
	    GRswap_type1214_ele(cpxstring);
#endif
	    write_mode = GUWRITE;
	    brc = GUwrite_element(  msg, dgn_buf, cpxstring, &type, 
			igds_cpx_size, file_des, &write_mode, &block_ptr,
  		    	&byte_ptr );
	}

    for ( i = 0 ; i < number_components ; i++ )
    {
	status = om$send ( msg = message
				GRgraphics.GRformatele
				  ( msg, env, dgn_buf, bs_buf,
				    (IGRchar *) cpxstring,
				    igds_cpx_size, file_des, local_range,
				    &scale_factor),
			    senderid = obj->objid,
			    p_chanselect = &chandef,
			    targetos = obj->osnum,
				from = i,
				to = i );

	if ( !(1 & status) )
	{
	    goto wrap_up;
	}
    }					/* end for i			*/

    GUcpxclose_string ( msg, dgn_buf, cpxstring, igds_cpx_size, 
		file_des,&type,&previous_state,&previous_offset);

wrap_up:

#ifdef DEBUG

    if (! status )
    {
	printf("GUotype1214  :  overflowed\n");
    }

#endif

    return(brc);

} /* end GUotype2 */

end implementation GRvg;
