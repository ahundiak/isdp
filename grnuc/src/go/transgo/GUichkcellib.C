/* #######################    APOGEE COMPILED   ######################## */
/*
 *  This function checks the contents (reads the type 9)
 *  of a given file to make sure it is a valid IGDS
 *  design file
 */

#include "exsysdep.h"
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"

struct GUcheckcellib
{
    IGRuchar 		level;
    IGRuchar 		type;
    IGRshort		words_to_follow;
};


IGRint GUicheck_cellib ( msg, file_des )

IGRint		*msg;
IGRint		*file_des;

{
#ifdef BIG_ENDIAN
    IGRshort                    swapped_short;
#endif
    IGRlong			status;
    struct GUcheckcellib	check_buf;

    *msg = TRUE;

    /*
     *  Read the first element in the file and
     *  make sure it is a type nine element.
     */

    if ( (status = read ( *file_des, &check_buf, 4 )) == 4 )
    {
#ifdef BIG_ENDIAN
        GRconv_short(&check_buf.words_to_follow,&swapped_short);
	if ( check_buf.type != 5  ||  swapped_short != 23 )
#else
	if ( check_buf.type != 5  ||  check_buf.words_to_follow != 23 )
#endif
	{
	    status = FALSE;
	    close ( *file_des );
	}
	else
	{
	    /*
	     *  Reset the file pointers to prepare
	     *  for translation of the file.
	     */

	    status = TRUE;
	    lseek ( *file_des, 0, 0 );

	}
    }    
    else
    {
	status = FALSE;
	close ( *file_des );
    }


    return ( status );

}
