#if defined( ENV5 )
#include <stdio.h>
#include <tools.h>

#define	DEBUG		0
#define	DEBUG_SET	0

#if DEBUG
static int		HSdebug_XOR_init = -1;
static int		HSdebug_XOR = -1;
#endif

static int		FATweight = 1;
static int		FATcolor = 1;
static unsigned short	FATstyle = 0xffff;
static int		FATmode = ALUcopy;

static int	err, errMaj, errBoth;
static int	lineStyleCount = 0;
static int	count;

static int		bsize1 = 0;
static unsigned char	*b1 = NULL;

static int		bsize2 = 0;
static int		*b2 = NULL;

static unsigned short	Styles[8] = { 0xffff, 0x7777, 0x1863, 0x0303, 
				      0x0770, 0x3333, 0x7077, 0x0630 };
				      

extern void	ALUlinestring();

/*---ALLOCBUFFER1-------------------------------------------------------*/

#define	ALLOCBUFFER1( bytes )						\
									\
	{								\
	if( b1 == NULL )						\
		{							\
		bsize1 = ((bytes) < 1000) ? 1000 : (bytes);		\
		b1 = (unsigned char *)malloc( bsize1 );			\
		}							\
	else								\
		if( (bytes) > bsize1 )					\
			{						\
			while( (bytes) > bsize1 ) bsize1 *= 100;	\
			free( b1 );					\
			b1 = (unsigned char *)malloc( bsize1 );		\
			}						\
	}

/*---ALLOCBUFFER2-------------------------------------------------------*/

#define	ALLOCBUFFER2( bytes )						\
									\
	{								\
	if( b2 == NULL )						\
		{							\
		bsize2 = ((bytes) < 1000) ? 1000 : (bytes);		\
		b2 = (int *)malloc( bsize2 );				\
		}							\
	else								\
		if( (bytes) > bsize2 )					\
			{						\
			while( (bytes) > bsize2 ) bsize2 *= 100;	\
			free( b2 );					\
			b2 = (int *)malloc( bsize2 );			\
			}						\
	}

/*---WLIxor_draw_line-------------------------------------------------------*/
	
/*ARGSUSED*/
void	WLIxor_draw_line( int wno, int mode, int *verts, int nvert, int type )

	{
	int		bsize, bytes;
	unsigned char	*buffer, *b;
	int		dx, dy, d2;
	int		styleLowBit;
	int		*v;
	int		x0, y0, x1, y1;

	v = verts;
	
	while( --nvert )
		{
		x0 = *v++;
		y0 = *v++;
		x1 = *v;
		y1 = *(v+1);
		
		dx = x1 - x0;
		dy = y1 - y0;
		if( dx < 0 ) dx = -dx;
		if( dy < 0 ) dy = -dy;
		
		bsize = (dx > dy) ? dx : dy;

		if( dx > dy )
			{
			d2 = dy << 1;
			err = d2 - dx;
			errMaj = d2;
			errBoth = d2 - (dx<<1);
			count = dx + 1;
			}
		else
			{
			d2 = dx << 1;
			err = d2 - dy;
			errMaj = d2;
			errBoth = d2 - (dy<<1);
			count = dy + 1;
			}

		bytes = bsize << 1;
		ALLOCBUFFER1( bytes )
		buffer = b1;
			
		getline( wno, 0xff, x0, y0, x1, y1, buffer );

		/*
		 *  Init i to 1, rather than 0, to skip the first pixel, to avoid 
		 *  overlaps
		 */
 
		b = buffer;
		while( bsize-- )
			{
			
			/*
			 *  If the high bit of the style pattern  is set, then update
			 *  the image buffer
			 */
			 
			if( FATstyle & 0x8000 )
				{
				styleLowBit = 1;
				*b++ ^= FATcolor;
				}
			else
				{
				styleLowBit = 0;
				b++;
				}
			
			/*
			 *  Circular rotate the style pattern
			 */
			 
			if( lineStyleCount < 0 )
				{
				FATstyle = (FATstyle << 1) | styleLowBit;
				lineStyleCount += 4;
				}

			if( err < 0 )
				{
				err += errMaj;
				lineStyleCount -= 2;
				}
			else
				{
				err += errBoth;
				lineStyleCount -= 3;
				}

			}
	
		putline( wno, 0xff, x0, y0, x1, y1, buffer );
		}
	}

/*---WLIxor_set_weight----------------------------------------*/

void	WLIxor_set_weight( int wno, int wght )

	{
	if( wght < 1 ) wght = 1;
	
	FATweight = wght;
	weight( wno, wght-1 );
	
#	if DEBUG_SET
	fprintf( stderr, "WLIxor_set_weight: %d %d\n", wno, wght );
#	endif
	}
	
/*---WLIxor_set_color-----------------------------------------*/

void	WLIxor_set_color( int wno, int color )

	{
	FATcolor = color;
	fgcolor( wno, FATcolor );
	bgcolor( wno, 0/*FATcolor*/ );
	
#	if DEBUG_SET
	fprintf( stderr, "WLIxor_set_color: %d %d\n", wno, color );
#	endif
	}
	
/*---WLIxor_set_mode-----------------------------------------*/

void	WLIxor_set_mode( int mode )

	{
	FATmode = mode;
	
#	if DEBUG_SET
	fprintf( stderr, "WLIxor_set_mode: %d\n", mode );
#	endif
	}
	
/*---WLIxor_set_style------------------------------------------*/

void	WLIxor_set_style( int wno, int style )

	{
	if( style > 7 ) style = 0;
	FATstyle = Styles[style];
	linestyle( wno, FATstyle );
	lineStyleCount = 0;

#	if DEBUG_SET
	fprintf( stderr, "WLIxor_set_style: %d %d %x\n", wno, style, FATstyle );
#	endif
	}

/*---WLIxor_draw_with_weight----------------------------------------*/

void	WLIxor_draw_with_weight( int wno,
			int mode,
			int *vert,
			int nvert,
			int type,
			int major )
			
	{
	int		w, x, y, dx, dy;
	int		*v, *v1;
	int		i, j, bytes;
	unsigned short	style;
	int		lsc;
	
	void	(*Drawer)();
	
	if( FATstyle == 0xffff )
		Drawer = ALUlinestring;
	else
		Drawer = WLIxor_draw_line;

	bytes = (nvert<<1) * sizeof( int );	
	ALLOCBUFFER2( bytes );
	v = b2;
	
	w = (FATweight-1) >> 1;
	if( major == 0 )
		{
		x = 0;
		y = w;
		}
	else
		{
		x = w;
		y = 0;
		}
		
	v1 = vert;
	v[0] = *v1++ - x;
	v[1] = *v1++ - y;
	j = 2;
	while( --nvert )
		{
		v[j  ] = *v1++ - x;
		v[j+1] = *v1++ - y;

		dx = v[j  ] - v[j-2];
		dy = v[j+1] - v[j-1];
		if( dx < 0 ) dx = -dx;
		if( dy < 0 ) dy = -dy;
		
		if( dx > 1 || dy > 1 ) 	j += 2;
		}

	nvert = j>>1;
	style = FATstyle;
	lsc = lineStyleCount;

	j = FATweight;
	
	if( x != 0 )
		{
		while( --j )
			{
			FATstyle = style;
			lineStyleCount = lsc;

			(*Drawer)( wno, mode, v, nvert, type );

			i = nvert;
			v1 = v;
			while( i-- )
				{
				(*v1)++;
				v1 += 2;
				}
			}
		}
	else
		{
		while( --j )
			{
			FATstyle = style;
			lineStyleCount = lsc;

			(*Drawer)( wno, mode, v, nvert, type );

			i = nvert;
			v1 = v + 1;
			while( i-- )
				{
				(*v1)++;
				v1 += 2;
				}
			}
		}
		
	FATstyle = style;
	lineStyleCount = lsc;
	
	(*Drawer)( wno, mode, v, nvert, type );
	}
	

static int	pm = 0;

/*---WLIxor_get_major------------------------------------*/

static int	WLIxor_get_major( int *v )

	{
	int	dx, dy;


	/*if( wgt <= 1 ) return( 0 );*/
	
	/*
	 *  return 0 if x is major axis, 1 if y
	 */
	 
	dx = v[0] - v[2];
	dy = v[1] - v[3];
	if( dx < 0 ) dx = -dx;
	if( dy < 0 ) dy = -dy;
	
	/*
	 *  if the deltas are equal, return the previous major (init to 0)
	 */
	 
	if( dx > dy )
		pm = 0; else

	if( dx < dy )
		pm = 1;

	return( pm );
	}
	
/*---WLIxor_alu_with_weight---------------------------------*/

void	WLIxor_alu_with_weight( int wno, 
			       int mode, 
			       int *vert, 
			       int nvert,
			       int type )

	{
	int	i, nv, m1, m2;
	int	*v, *v1;
	
	v = v1 = vert;
	m1 = WLIxor_get_major( v1 );
	
	for( nv=0, i=0; i<nvert; i++, v1+=2, nv++ )
		{
		if( m1 != (m2=WLIxor_get_major( v1 )) )
			{
			WLIxor_draw_with_weight( wno, mode, v, nv+1, type, m1 );

			v = v1;
			nv = 0;
			
			m1 = m2;
			}
		}

	if( nv > 1 )
		WLIxor_draw_with_weight( wno, mode, v, nv, type, m1 );
	}


/*---WLIxor_linestring---------------------------------*/

void	WLIxor_linestring( int wno, 
			int mode, 
			int *vert, 
			int nvert,
			int type )

	{
	int	i;

#	if DEBUG
	if( HSdebug_XOR_init < 0 )
		{
		char	*expr, *getenv();
	
		HSdebug_XOR_init = 0;
		expr = getenv( "HSdebug_XOR" );
		if( expr != NULL ) sscanf( expr, "%d", &HSdebug_XOR_init );
		HSdebug_XOR = HSdebug_XOR_init = 1000000;
		}
		
	if( HSdebug_XOR > 0 )
		fprintf( stderr, "WLIxor_linestring: Enter: weight, style: %d %x\n", FATweight, FATstyle );
#	endif

	if( mode == ALUxor )
		{
		if( FATweight <= 1 && FATstyle == 0xffff )
			{
			ALUlinestring( wno, mode, vert, nvert, type );
			}
		else
			{
			WLIxor_alu_with_weight( wno, mode, vert, nvert, type );
			}
		}
	else
		{
		weight( wno, FATweight-1 );
		linestyle( wno, FATstyle );

#		if DEBUG_SET
		fprintf( stderr, "FatWeight: %d %d\n", wno, FATweight );
		fprintf( stderr, "FatStyle : %d %x\n", wno, FATstyle );
#		endif

		move( wno, vert[0], vert[1] );
		for( i=1; i<nvert; i++ )
			draw( wno, vert[(i<<1)], vert[(i<<1)+1] );
		
		flushbuffer( wno );
		}

#	if DEBUG
	if( HSdebug_XOR-- > 0 )
		fprintf( stderr, "WLIxor_linestring: Exit\n" );
#	endif
	}

static int	*xlimits = NULL;
static int	xlimits_size = 0;

/*---WLIxor_polygon-----------------------------------------------------------*/

void	WLIxor_polygon( wno, ylo, yhi, x1_lo, x2_lo, x1_hi, x2_hi )

int	wno;
int	yhi, ylo;
double	x1_hi, x1_lo, x2_hi, x2_lo;

	{
	double	x1, x2, dx1, dx2;
	int	y, dy;
	int	*x;
		
	dy = yhi - ylo;

	if( (dy+1) > xlimits_size )
		{
		if( xlimits != NULL ) free( xlimits );
		xlimits_size = dy + 1;
		xlimits = (int *)malloc( sizeof( int ) * xlimits_size );
		}
		
	x1 = x1_lo;
	x2 = x2_lo;

	x = xlimits;	
	*x++ = (int)x1;
	*x++ = (int)(x2 + 0.5);
	
	if( dy <= 0 )
		{
		dx1 = 0.0;
		dx2 = 0.0;
		}
	else
		{
		dx1 = (x1_hi - x1_lo) / (double)dy;
		dx2 = (x2_hi - x2_lo) / (double)dy;
		}

	y = dy;
	while( y-- )
		{
		x1 += dx1;
		x2 += dx2;
		*x++ = (int)x1;
		*x++ = (int)(x2 + 0.5);
		}

	ALUdrawspans( wno, FATmode, dy+1, ylo, xlimits );
	}

#endif
