/*
Name
        GUattr_link

Description
        This subroutine searches an IGDS element for linkages with the
        u-bit set, implying that they are user data linkages. The user
        type in the user data linkage is then used to determine if the
        user data is a type interpreted by EMS.  This currently
        includes a subset of the IGDS plotting metafile extensions
        defined by InterPlot, along with element name.  The extensions
        supported are symbology, the font typeface, and the character
        mapping. If the types that alter the symbology of the element
        are present, then symbology is altered. If the element name,
        fill, or font types are present then the arguments return the
        name, or font typeface and charmap to the calling function. The
        function returns an int, whose bits indicate which types were
        present. 

        I/VEC (user id 66) user data is also noted and passed to a
        function specified by the I/FRATEL product to allow some sort
        of "node" connection information to be maintained.

Notes
        The mechanism for passing I/VEC data to I/FRATEL is not
        particularly elegant.  It uses a static variable pointing into
        instance data to call a function which will be dynamically
        overwritten by I/FRATEL.  The mechanism is potentially
        dangerous and should be reworked, when time permits, by
        changing the argument list to this function.

History
        gfs     02/22/91    creation
        mrm     04/24/91    check for EMS user id
                04/29/91    added checks for I/VEC data
*/

#include "exsysdep.h"
#include "coimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "transmacros.h"
#include "transdef.h"
#include "translate.h"
#include "msdef.h"

/* structure to represent the IGDS plotting metafile extensions
   supported here */

struct EMSuserdata
{
    unsigned char wtf;
    unsigned char type;
    unsigned short data;
};

/* global variable for I/VEC data */

static unsigned short *ivec = NULL;

/* function to read attribute linkages */

IGRint GUattr_link(msg, element, name, symbology, typeface, charmap)
IGRlong *msg;                           /* < completion code */
struct GUcommon_header_info *element;   /* > IGDS element ptr */
IGRchar *name;                          /* < element name */
IGRshort *symbology;                    /* < element symbology */
IGRchar *typeface;                      /* < text typeface */
IGRchar *charmap;                       /* < text character mapping */
{
    IGRboolean fill_color = FALSE;
    IGRchar *c;
    IGRint has_link = 0;
    IGRint length;
    unsigned char props;            /* |i|r|m|u|linkage family class| */
    unsigned short *end_of_ele;     /* end of IGDS element */
    unsigned short *attr_data;      /* data packet within an EMS udp */
    unsigned short *end_of_data;    /* end of an EMS user data packet */
    unsigned short *linkage;        /* points to beginning of a linkage */
    unsigned short *data;           /* points to data */
    struct EMSuserdata *emsdata;    /* user data written by EMS */
    struct IGDS_linkage *userdata;  /* IGDS user data linkage structure */
#ifdef BIG_ENDIAN
    IGRshort	swapped_short;
#endif

    *msg = MSSUCC;
    linkage = (unsigned short *)&element->index_to_ae + element->index_to_ae + 1;
    end_of_ele = (unsigned short *)element + element->words_to_follow + 2;
    while (linkage < end_of_ele)
    {
#ifdef BIG_ENDIAN
        props = *linkage ; 
#else
        props = *linkage >> 8; 
#endif

      if (!(props & GU_LINKAGE_PROPS))
        {
            /* DMRS or other type of fixed-length attribute linkage */

            linkage += 4;
        }
        else
        {
            userdata = (struct IGDS_linkage *)linkage;
#ifdef BIG_ENDIAN
	    GRconv_short(&(userdata->user_id),&swapped_short);

            if ((swapped_short == GU_LINKAGE_ID) ||
                (swapped_short == GU_FILLPOLY_TYPE))
#else
            if ((userdata->user_id == GU_LINKAGE_ID) ||
                (userdata->user_id == GU_FILLPOLY_TYPE))
#endif
            {
                attr_data = linkage + 2;
                end_of_data = linkage + userdata->words_to_follow + 1;
                while (attr_data < end_of_data)
                {
                    emsdata = (struct EMSuserdata *)attr_data;
                    data = (unsigned short *)&emsdata->data;
                    switch (emsdata->type)
                    {
                      case GU_NAME_TYPE:
                        blkmv((emsdata->wtf * 2), data, name);
                        name[emsdata->wtf * 2] = '\0';
                        has_link |= HAS_NAME_TYPE;
                        break;

                      case GU_FILLCOLOR_TYPE:
#ifdef BIG_ENDIAN
			GRswap_poly_linkage(element);
#endif
                        /* check for IGDS VLT color flag */
                        if ((*data  & 0x00ff) == 1)
                        {
                            *symbology &= 0x00ff;
                            *symbology |= (*(data + 1) & 0x00ff) << 8;
                            fill_color = TRUE;
                            has_link |= HAS_FILLED_TYPE;
                        }
                        break;

                      case GU_ELECOLOR_TYPE:
                        /* check for IGDS VLT color flag */
                        if ((!fill_color) && ((*(data + 1) & 0x00ff) == 1))
                        {
                            *symbology &= 0x00ff;
                            *symbology |= (*(data + 2) & 0x00ff) << 8;
                        }
                        break;

                      case GU_STYLE_TYPE:
                        *symbology &= 0xfff8;
                        *symbology |= emsdata->data >> 8;
                        break;

                      case GU_AREAFILL_TYPE:
                        if (emsdata->data & 0x00ff)
                        {
                            has_link |= HAS_FILLED_TYPE;
                        }
                        break;

                      case GU_WEIGHT_TYPE:
                        *symbology &= 0xff07;
                        *symbology |= (emsdata->data & 0x001f) << 3;
                        break;

                      case GU_FONT_TYPE:
                        if ((typeface != NULL) & (charmap != NULL))
                        {
                            c = (IGRchar *)data + 10;
                            length = *c;
                            c++;
                            blkmv(length, c, typeface);
                            typeface[length] = '\0';
                            c += length;
                            length = *c;
                            c++;
                            blkmv(length, c, charmap);
                            charmap[length] = '\0';
                            has_link |= HAS_FONT_TYPE;
                        }
                        break;

                      default:
                        break;

                    } /* end switch emsdata->type */

                    /* increment to the next attribute type */

                    attr_data += emsdata->wtf + 1;

                } /* end while (attr_data < end_of_data) */

            }
            else if (userdata->user_id == GU_IVEC_USER_ID)
            {
                /* store the pointer to the I/VEC data for use later */

                ivec = linkage;
                has_link |= HAS_IVEC_TYPE;
	    }

            /* increment to the next user data linkage */

            linkage += userdata->words_to_follow + 1;
        }
    }
    return(has_link);
}

/*
Name
        FTConnectToNodes

Description
        This function will be dynamically overwritten by I/FRATEL.  It
        should be called from the conversion methods for types 4
        (polyline) and 6 (polygons).

History
        mrm     04/29/91    creation
*/

#argsused
IGRint FTConnectToNodes(objinfo, ivec_info)
struct GRid *objinfo;
unsigned short *ivec_info;
{
#ifdef DEBUG
    unsigned short i, *data;

    printf("FTConnectToNodes: ");
    printf("objinfo = %d, %d\n", objinfo->osnum, objinfo->objid);
    for (i = 0, data = ivec_info; i < 8; i++, data++)
        printf("%04x ", *data);
    printf("\n");
#endif
    return(TRUE);
}

/*
Name
        GRConnectToNodes

Description
        This function calls FTConnectToNodes, which will be dynamically
        overwritten by I/FRATEL.  This function is called from the
        conversion methods for types 4 (polyline) and 6 (polygons).  It
        should eventually be changed to pass the info around in
        argument lists, rather than static variables, when it is
        convenient to change the arglist to GUattr_link.

History
        mrm     04/29/91    creation
*/

/* definitions taken from I/VEC documentation */

#define CENTERLINED     1
#define UNCENTERLINED   6
#define PATTERNLINE     7

IGRint GRConnectToNodes(objinfo)
struct GRid *objinfo;
{
    unsigned short *p, type;

    p = ivec + 2;
    type = *p & 0x0f;
    if ((type == CENTERLINED) ||
        (type == UNCENTERLINED) ||
        (type == PATTERNLINE))
        FTConnectToNodes(objinfo, ivec);
    return(TRUE);
}
