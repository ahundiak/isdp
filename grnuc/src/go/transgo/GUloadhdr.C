/*
Name
        GUload_IGDSheader

Description
        This utility function formats an IGDS header (first 18 words of an
        element) using the appropriate information from the EMS object.

History
        ???     ??/??/8?    creation
        mrm     02/08/92    fix to handle line styles > 7
        mrm     02/26/92    Removed check for GU_ATTR_PROP, since its
                            definition conflicted with DEHAS_OVERRIDE.  It is
                            now up to the caller to fill in the attribute
                            linkage bit when appropriate, since this function
                            doesn't have the necessary knowledge.
        mrm     11/03/92    added check to avoid setting complex elements
                            to construction class (TR119220278)
*/

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
#include "dpdls.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

void GUload_IGDSheader(msg, class_name, type, symbology, properties,
                       range, header)
IGRlong				*msg;
IGRchar				class_name[];
IGRshort			*type;
struct GRsymbology		*symbology;
IGRushort			*properties;
GRrange				range;
struct GUcommon_header_info	*header;

{
    IGRshort i;
    IGRushort weight, style;
    IGRlong temp_range;

    *msg = GUsuccess;
	
    /*
     *  load word 1 of the IGDS header
     *
     *  	delete bit
     *	        type
     *	        component bit
     *	        reserved bit
     *  	level
     */
	
    if (symbology->level > 63)
    {
        header->level = (symbology->level % 64) + 1;
    }
    else
    {
        header->level = symbology->level % 64;
    }

    if ((header->level % 64) == 0)
    {
        header->level = 1;
    }

    /********************************************************************/
    /*    commented out until symbols, symbol references, and graphic   */
    /*    groups are ready						*/
    /*	if (*properties & GRIS_COMPONENT)			        */
    /*	    header->level |= 0x80;				        */
    /********************************************************************/

    header->type = *type;

    /*
     *  skip words-to-follow word, it will be set in the calling routine
     */

    /*
     *  set range
     */

    for (i = 0; i < 6; ++i)
    {
        temp_range = GUnint(range[i]);
        GUswaprange_igeigds(&temp_range, &header->range[i]);
    }

    /* 
     *  set graphic group number
     */

    header->graphic_group = 0;	/* will need to change when  */
                                /* complexes work	     */

    /*
     *  set index to AE in calling routine after words-to-follow can be found
     */

    /*
     *  set proper bits in properties
     */

    header->properties = 0;

    /*
     *  A dummy attribute linkage is attached to all complex element
     *  headers ie; type 12 and type 14 elements, so the attributes 
     *  present bit is set for these types.
     */

    if ((*type == 12) ||(*type == 14))
        IGDSSetProperty(header->properties, IGDSAttributeData);

    if (!(strcmp(class_name,"GR3dinfline") &&
          strcmp(class_name,"GR3iinfline") &&
          strcmp(class_name,"GR2iinfline")))
        IGDSSetProperty(header->properties, IGDSInfiniteLine);

    if (!(*properties & GRIS_PLANAR))
        IGDSSetProperty(header->properties, IGDSPlanar);

    if (*properties & GRIS_NEW)
        IGDSSetProperty(header->properties, IGDSNew);

    /*
     * if an object is view rotation independent, set the bit that indicates it
     * is oriented relative to the screen(R bit)
     */

    if (*properties & GRIS_VIEW_INDEP)
        IGDSSetProperty(header->properties, IGDSRelative);

    /*
        Make nondisplayable and nonlocatable objects convert to construction
        class elements, unless the target element is a complex header.
        Complex headers result from composite curves, which don't maintain the
        displayable/locatable bits.
    */

    if (!(*properties & GRIS_DISPLAYABLE) && !(*properties & GRIS_LOCATABLE) &&
        (*type != 12) && (*type != 14))
        IGDSSetClass(header->properties, IGDSConstructionElement);

    /*
      set the display symbology word    ---------------------------------
                                        |     Color     | Weight  |Style|
                                        | | | | | | | | | | | | | | | | |
                                        ---------------------------------
    */

    /* color */
    if (symbology->display_attr.color == 0)
        header->symbology = 254;
    else
        header->symbology = symbology->display_attr.color - 1;
    header->symbology <<= 8;

    /* weight */
    weight = (IGRushort)symbology->display_attr.weight;
    weight <<= 3;

    /* style
       Make sure the EMS style, which can run to 256, doesn't bleed over into
       the other IGDS symbology fields.  An attribute linkage will assign
       correct style for plots.  Straight IGDS conversion needs to resolve this
       somehow.
    */
    style = (IGRushort)symbology->display_attr.style;
    if (style > 7)
        style = 6;      /* style suggested by JB */

    /* deposit the final value */
    header->symbology |= weight | style;
}
