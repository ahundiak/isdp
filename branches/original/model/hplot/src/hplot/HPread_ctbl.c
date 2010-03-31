#include <stdio.h>
#include <stdlib.h>

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "exsysdep.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hplot.h"
#include "HPglobal.h"
#include "HPdef.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot.h"
#include "hpmsg.h"

/*------------------------------
 *  for function
 *     HSconv_short
 */
 
#include "HSrle.h"
#include "hsanimate.h" 
#include "HSpr_rle_uti.h"

/*------------------------------*/

/*---HPread_color_table------------------------------------------------*/

/*
NAME
	HPread_color_table
	
KEYWORDS
	HSplot
	colortable
	question coding
	
DESCRIPTION
	read colortable from the shaded plotfile
	
PARAMETERS
	file_ptr	:(IN)    : File pointer for the shaded plotfile
	table_data	:(IN/OUT): Buffer in which to put the colortable
	buffer_size	:(IN/OUT): Size of the buffer
	table_size	:(OUT)   : Size of the colortable

FUNCTIONS CALLED
	fread
	HPmessage
	HSconv_short (Sun only)
	free
	malloc
		
NOTES
	QUESTION: Since HSplot will read only one colortable, it is not
	nesecary to have a floating buffer
	
HISTORY
	??/??/??	M. Lanier
		Created
	
*/

#if defined(__STDC__) || defined(__cplusplus)
	int HPread_color_table (FILE *file_ptr, 
			    IGRshort **table_data, 
				 int *buffer_size, 
				 int *table_size)
#else
	int	HPread_color_table( file_ptr, table_data, buffer_size, table_size )

	FILE		*file_ptr;	/* file descriptor to read from */
	IGRshort	**table_data;	/* address of pointer to table data buffer */
	int		*buffer_size;	/* size of table data buffer */
	int		*table_size;	/* color table size */
#endif

	{
	IGRint		status;		/* return code from called functions */
	IGRint		index;		/* table loop counter */
	IGRshort	*rgb_value;	/* pointer to current value being read */
	IGRshort	u16_table_size;

	/* 
	 * read color table size 
	 */
	 
	status = fread( (IGRshort *)&u16_table_size, sizeof( IGRshort ), 1, file_ptr );
	if( status <= 0 )
		{
		HPmessage( HP_F_RdCtblSz, NULL, 
                           HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
		return HSplot_error;
		}

#	ifdef BIG_ENDIAN
	HSconv_short( &u16_table_size, 1 );
#	endif

	*table_size = u16_table_size;
   
	/* 
	 * check for null table 
	 */
	 
	if( *table_size == 0 ) return HSplot_success;

	/* 
	 * allocate data buffer if not big enough 
	 */
	 
	if( *table_size * 3 > *buffer_size )
		{
		if( *table_data ) free( *table_data );
		*buffer_size = ( *table_size * 3 & ~255 ) + 256;
		*table_data = (IGRshort *)malloc( *buffer_size * sizeof( IGRshort ) );
		}
		
	rgb_value = * table_data;

	/* 
	 * for each table entry, read rgb values 
	 */
	 
	for( index=0; index<*table_size; ++index )
		{
		status = fread( (IGRshort *)rgb_value, sizeof( IGRshort ), 3, file_ptr );
		if( status <= 0 ) 
			{
			HPmessage( HP_F_RdCtblRGB, NULL, 
                                   HPmessage_PREFIX_PRODNAME | HPmessage_CONSOLE_WRITE );
			return HSplot_error;
			}

#		ifdef BIG_ENDIAN
		HSconv_short( rgb_value, 3 );
#		endif
		
		rgb_value = &rgb_value[3];
		}
   
	return HSplot_success;
	} /* read_color_table_rgb_values */
