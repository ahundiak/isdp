/*
Name
        GUotype5lv10

Description
        These routines write InterPlot Attribute Bundle elements.

History
        mrm     09/20/91    creation
*/

#include "exsysdep.h"
#include "OMminimum.h"
#include "OMprimitives.h"
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
#include "ex.h"
#include "msdef.h"
#include "dpdls.h"

#define ATTRIBUTE_BUNDLE_TYPE   5       /* IGDS element type */
#define MAX_ELE_SIZE    (768 * 2)       /* IGDS element limitation */
#define PIXEL_WIDTH     0.05            /* width of a pixel in centimeters */

/*
Name
        GUotype5lv10t2

Description
        This function writes the EMS User Defined Linestyle information
        to an IGDS plotting metafile as an InterPlot Attribute Bundle of
        Linestyle Patterns.

Notes
        The Linestyle Pattern element is defined by InterPlot as a
        plotting metafile extension.

		---------------------------------
		|U| Type = 5	|  Level = 10	|
		---------------------------------
		|	# Words To Follow	|
		---------------------------------
		|	Range (12 words)	|
                |       ....			|
                ---------------------------------
		|Bdl Type|    Bundle Index	|
                ---------------------------------
                | End Linestyle	| Beg Linestyle	|
                ---------------------------------
                |              	|# Trans Style 1|
                ---------------------------------
                |	Transition Length 1	|
                |	FP (cm)			|
                ---------------------------------
                |	...			|
                ---------------------------------
                |	Transition Length N	|
                |	FP (cm)			|
                ---------------------------------
                |		|# Trans Style 2|
                ---------------------------------
                |	Transition Length 1	|
                |	FP (cm)			|
                ---------------------------------
                |	...			|
                ---------------------------------
                |	Transition Length N	|
                |	FP (cm)			|
                ---------------------------------
*/

IGRint GUotype5lv10t2(msg, file_des, dgn_buf, ele_buf, ele_size)
IGRlong *msg;
IGRlong *file_des;
IGRchar *dgn_buf;
IGRchar *ele_buf;
IGRint  *ele_size;
{
    unsigned char *beg_style, *end_style;
    unsigned short style[MAX_STYLES], st, *p_ele, *wtf;
    IGRshort ntransitions, j;
    IGRshort type = ATTRIBUTE_BUNDLE_TYPE;
    IGRshort write_mode = GUWRITE;
    IGRint i, state, last_state, len, sts, style_index;
    IGRint byte_ptr, block_ptr;
    IGRlong *range;
    float lengths[16];
#ifdef BIG_ENDIAN
    IGRshort   swapped_short, temp;
    IGRint     swapped_int;
    float      temp_len[16];
#endif

    *msg = MSSUCC;

    for (j = BUILTIN_STYLES; j < MAX_STYLES; j++)
    {
        DPinq_style(j, &st);    /* get the line style pattern for this index */

        /*
           There is a difference in the way EMS and InterPlot define
           linestyle patterns.  EMS allows the linestyle to begin with
           empty space; InterPlot defines the first transition as solid.
           To partially alleviate this, the EMS pattern is shifted so
           that it always starts with a solid transition, and tacks any
           leading space onto the end of the pattern.  This is not
           exactly correct at the start of the line, but will at least
           display the correct pattern through the rest of the plot.

           Note that EMS demands that at least one pixel be turned on in a line
           style, so that is not a worry here.
        */
        while ((st & 0x8000) == 0)
            st = st << 1;

        style[j] = st;          /* store the pattern locally */
    }

    style_index = BUILTIN_STYLES;
    while (style_index < MAX_STYLES)
    {
        /* write the element type, level, words-to-follow, and range */
        p_ele = (unsigned short *)ele_buf;
#ifdef BIG_ENDIAN
        *p_ele++ = 0x0a05;
#else
        *p_ele++ = 0x050a;
#endif
        wtf = p_ele++;          /* fill this in later */
        range = (long *)(p_ele);
        range[0] = range[1] = range[2] = 0x00000000;
        range[3] = range[4] = range[5] = 0xffffffff;
        p_ele += sizeof(short) * 6;

        /* write the bundle type (2) and index (0?) */
#ifdef BIG_ENDIAN
        *p_ele++ = 0x0020;
#else
        *p_ele++ = 0x2000;
#endif

        /* write the beginning index, store a pointer to the end index to
           be filled in later */
        beg_style = (unsigned char *)p_ele++;
        end_style = beg_style + 1;
        *beg_style = (unsigned char)style_index;

        /* initialize the element size - sum of all the stuff written above */
        *ele_size = 32;

        /* write styles until the element is full or styles are exhausted */
        while ((*ele_size < MAX_ELE_SIZE) && (style_index < MAX_STYLES))
        {
            st = style[style_index];

            /* get the number of transitions and their lengths in this style */
            memset(lengths, 0, sizeof(float) * 16);
            for (i = 15, ntransitions = 0, last_state = 1; i >= 0; i--)
            {
                state = (st >> i) & 1;
                if (state != last_state)
                    ntransitions++;
                last_state = state;
                lengths[ntransitions] += PIXEL_WIDTH;
            }
            ntransitions++;

            /* check whether this transition will fit in this element */
            len = sizeof(short) + (ntransitions * sizeof(float));
            if ((*ele_size + len) < MAX_ELE_SIZE)
                *ele_size += len;
            else
                break;

            /* write the number of transitions for this style */
#ifdef BIG_ENDIAN
            GRconv_short(&ntransitions, &swapped_short);
            *p_ele++ = swapped_short;
#else
            *p_ele++ = ntransitions;
#endif

            /*
                Convert the transition lengths to VAX format. Don't try
                to put the output directly into ele, since it probably
                isn't properly aligned.  Note that GRF32ToFVax is
                expected to return the data in the proper IGDS word
                order, so that no further adustment is necessary.
            */
            GRF32ToFVax((int)ntransitions, lengths, lengths);

            /* write the transition lengths for this style */
            memcpy(p_ele, lengths, sizeof(float) * ntransitions);

            /* increment style index and element pointer */
            style_index++;
            p_ele += (ntransitions * 2);
        }

        /* fill in the ending linestyle index */

        *end_style = (unsigned char)style_index - 1;

        /* fill in the words to follow */
#ifdef BIG_ENDIAN
        temp = (unsigned short) (*ele_size / 2) - 2;
        GRconv_short(&temp, &swapped_short);
        *wtf = swapped_short;
#else
        *wtf = (unsigned short)(*ele_size / 2) - 2;
#endif

        /* write the element to the metafile */
        sts = GUwrite_element(msg, dgn_buf, ele_buf, &type, ele_size,
                              file_des, &write_mode, &block_ptr, &byte_ptr);
    }

    return(TRUE);
}
