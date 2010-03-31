#include <stdio.h>

static short	table_size = 0;
static short	buffer_size = 0;
static short	*table_data = NULL;

/*---copy_ctbl------------------------------------------------*/

int	copy_ctbl( infil, outfil, flag )

FILE	*infil, *outfil;
int	flag;

	{
	int		status;		/* return code from called functions */
	int		index;		/* table loop counter */
	short	*rgb_value;	/* pointer to current value being read */
	short	u16_table_size;

	/* 
	 * read color table size 
	 */
	 
	status = fread( (short *)&u16_table_size, sizeof( short ), 1, infil );
	
	if( flag == 0 )
	status = fwrite( (short *)&u16_table_size, sizeof( short ), 1, outfil );

	table_size = u16_table_size;
   
	/* 
	 * check for null table 
	 */
	 
	if( table_size == 0 ) return;

	/* 
	 * allocate data buffer if not big enough 
	 */
	 
	if( table_size * 3 > buffer_size )
		{
		if( table_data ) free( table_data );
		buffer_size = ( table_size * 3 & ~255 ) + 256;
		table_data = (short *)malloc( buffer_size * sizeof( short ) );
		}
		
	rgb_value = table_data;

	/* 
	 * for each table entry, read rgb values 
	 */
	 
	for( index=0; index<table_size; ++index )
		{
		status = fread( (short *)rgb_value, sizeof( short ), 3, infil );
		
		if( flag == 0 )
		status = fwrite( (short *)rgb_value, sizeof( short ), 3, outfil );
		rgb_value = &rgb_value[3];
		}
	}
