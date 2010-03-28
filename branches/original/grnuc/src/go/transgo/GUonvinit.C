/* #######################    APOGEE COMPILED   ######################## */
#include "exsysdep.h"
#include "grimport.h"
#include "igrtypedef.h"

GUonvinit ( ele_ptr )

IGRshort	*ele_ptr;

{
    IGRint 	i;

    /*
     *  Set type/level word, words to follow.
     */

#ifdef BIG_ENDIAN
    *ele_ptr++ = 0x0305;
    *ele_ptr++ = 0x5900;
#else
    *ele_ptr++ = 0x0503;
    *ele_ptr++ = 0x0059;
#endif
    /*
     *  Set up low and high range.
     */

    for ( i = 0; i < 6; i++ )
    {
    	*ele_ptr++ = 0x0000;   
    }

    for ( i = 0; i < 6; i++ )
    {
    	*ele_ptr++ = 0xffff;   
    }

    /*
     *  Set up graphic group and index to ae's.
     */

    *ele_ptr++ = 0x0000;
#ifdef BIG_ENDIAN
    *ele_ptr++ = 0x4700;
#else
    *ele_ptr++ = 0x0047;
#endif
    /*
     *  Set up properties, number of views, view definition
     *  description, and view full indicators.
     */

#ifdef BIG_ENDIAN
    *ele_ptr++ = 0x014a;
#else
    *ele_ptr++ = 0x4a01;
#endif
    for ( i = 0; i < 11; i++ )
    {
    	*ele_ptr++ = 0x0000;
    }

    /*
     *  Set up view flags and level bit map.
     */

#ifdef BIG_ENDIAN
    *ele_ptr++ = 0xf9b1;
#else
    *ele_ptr++ = 0xb1f9;
#endif
    for ( i = 0; i < 4; i++ )
    {
    	*ele_ptr++ = 0xffff;
    }


    /*
     *  Set up attribute linkage which actually contains
     *  the named view's name.
     */

    ele_ptr += 54;
#ifdef BIG_ENDIAN
    *ele_ptr++ = 0x0310;
    *ele_ptr = 0x1600;
#else
    *ele_ptr++ = 0x1003;
    *ele_ptr = 0x0016;
#endif

}
