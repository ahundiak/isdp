
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:40 $
$Locker:  $
*/


#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <alloca.h>

#include "wl.h"
 
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"

#include "hslight.h"
#include "hsdisplay.h"
#include "HStl_global.h"
#include "hsanimate.h"
#include "hrstruct.h"
#include "HSrle.h"
#include "hrmipmap.h"
#include "hskyoptypes.h"
#include "HSsara.h"

#include "HSpr_render.h"

/*----------------------------
 *  for functions
 *    HSread_rasterfile_header
 *     HSread_type25_scanline
 *     HSread_type27
 *     HSread_type27_scanline
 */
 
#include "HSpr_co_func.h"

/*---------------------------*/


/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HRmipmap.c */
static void MMdisplay_texture_list __((void));

static void MMadd_texture_to_list __((struct HRtexture_list *surface_texture));

static char *MMremove_texture_from_list __((	int bytes_needed, 
						int *from_zbuffer));
						
static int MMcompute_texture_memory_limit __((void));

static void MMconstruct_next_layer __(( unsigned char *clayer, 
						  int cwidth, 
						  int cheight, 
					unsigned char *nlayer, 
						  int nwidth, 
						  int nheight));
						  
static void MMmake_mipmap __((			  int *infile, 
					      IGRchar *mipmap));
					
static void MMmake_mipmap_25 __((		  int *infile, 
					      IGRchar *mipmap));
					
static void MMmake_h_mipmap __((		  int *infile, 
					      IGRchar *mipmap));
					
static void MMcompute_memory_usage_and_allocate __((
				struct HRtexture_list *surface_texture, 
						  int height, 
						  int width));


#if defined(__cplusplus)
}
#endif


#undef __



#define	DEBUG		0
#define	DEBUGD		0
#define	DEBUG_DISPLAY	0

#define	MIN_BUF_SIZE	8388698
#define	z50Mb		52428800
#define z8_5Mb		8912896
#define	z16Mb		16777216
#define z1_85Mb		1939866
#define	z10Mb		10485760


extern int getmemsize();

#if DEBUGD
/*---MMdisplay_texture_list--------------------------------------------------*/

static void MMdisplay_texture_list()

	{
	struct MMinfo_list	*info_list;

	if( MMinfo_list_top == NULL )
		{
		fprintf( stderr, "\nTexture info list\n  empty\n\n" );
		}
	else
		{
		info_list = MMinfo_list_top;
		fprintf( stderr, "\nTexture info list\n" );
		while( info_list != NULL )
			{
			fprintf( stderr, "  %s\n", info_list->info->Fname );
			info_list = info_list->next;
			}

		fprintf( stderr, "\n" );
		}
	}
#endif

/*---MMadd_texture_to_list---------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static void MMadd_texture_to_list( struct HRtexture_list *surface_texture )
#else
	static void MMadd_texture_to_list( surface_texture )
	
	struct HRtexture_list	*surface_texture;
#endif

	{
	struct MMinfo_list	*info_list;

	info_list = (struct MMinfo_list *)malloc( sizeof( struct MMinfo_list ) );

	info_list->next = NULL;
	info_list->info = surface_texture;

	MMtexture_memory_used += surface_texture->mipmap_size;

	if( MMinfo_list_top == NULL )
		{
		MMinfo_list_top = MMinfo_list_bottom = info_list;
		}
	else
		{
		MMinfo_list_bottom->next = info_list;
		MMinfo_list_bottom = info_list;
		}
	}


/*---MMremove_texture_from_list----------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	static char *MMremove_texture_from_list( int bytes_needed,
						 int *from_zbuffer )
#else
	static char	*MMremove_texture_from_list( bytes_needed, from_zbuffer )

	int	bytes_needed;
	int	*from_zbuffer;
#endif

	{
	struct MMinfo_list	*curr;
	struct MMheader		*header;
	int			buf_size;

	/*
	 *  Start by removing the first texture from the top of the list
	 *  and saving its memory for the new texture.  Reset the MMinfo_list_top
	 *  pointer to the next node in the list.  Reduce the MMtexture_memory_used
	 *  value by the size of the mipmap being removed.
	 */

	curr = MMinfo_list_top;
	MMinfo_list_top = MMinfo_list_top->next;

	header = (struct MMheader *)curr->info->mipmap;

	MMtexture_memory_used -= curr->info->mipmap_size;

	/*
	 *  Set the mipmap pointer to NULL in the owner structure so it
	 *  will try and reload the next time its needed
	 */

	curr->info->mipmap = NULL;
	curr->info->mipmap_size = 0;

	/*
	 *  Free the mip map
	 */

	if ( header->from_zbuffer )
		(*tiling_parms.zfree)( 1, header );
	else
		free( header );

	/*
	 *  Free the MMinfo_list node that is being released
	 */

	free( curr );

	/*
	 *  If freeing the first node on the list, free nodes until enough
	 *  has been freed, or the list is exausted.
	 */
	 
	while( (bytes_needed + MMtexture_memory_used) > MMtexture_memory_limit )
		{
		
		/*
		 *  If there is no textures in the list, and we are still in excess of
		 *  the texture memory limit, return NULL so this surface will not get
		 *  a texture.
		 */
		 
		if( MMinfo_list_top == NULL ) return NULL;
		
		/*
		 *  Remove the first texture from the top of the list.
		 *  and delete its mipmap memory Reset the MMinfo_list_top
		 *  pointer to the next node in the list.  Reduce the MMtexture_memory_used
		 *  value by the size of the mipmap being removed.
		 */

		curr = MMinfo_list_top;
		MMinfo_list_top = MMinfo_list_top->next;

		MMtexture_memory_used -= curr->info->mipmap_size;

		/*
		 *  Free the mip map
		 */

		header = (struct MMheader *)curr->info->mipmap;
		if ( header->from_zbuffer )
			(*tiling_parms.zfree)( 1, header );
		else
			free( header );

		/*
		 *  Set the mipmap pointer to NULL in the owner structure so it
		 *  will try and reload the next time its needed
		 */

		curr->info->mipmap = NULL;
		curr->info->mipmap_size = 0;

		/*
		 *  Free the MMinfo_list node that is being released
		 */

		free( curr );	
		}

	header = (struct MMheader *) (*tiling_parms.zmalloc)( 1, bytes_needed, &buf_size, NULL );
	if ( header )
	   *from_zbuffer = TRUE;
	else	 	
	   {
	   header = (struct MMheader *) malloc( bytes_needed );
	   *from_zbuffer = FALSE;
	   }
		
	return( (char *) header );
	}


/*---MMcompute_texture_memory_limit----------------------------------*/

/*
 *  Determine how much main memory is available and allocate it for
 *  use as the texture cache.
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static int	MMcompute_texture_memory_limit(void)
#else
	static int	MMcompute_texture_memory_limit()
#endif

	{
	int	phys_mem;
	int	buf_mem;
	
	/*
	 *  Subtract the total physical memory available by the amount of used
	 *  physical memory and we get the amount of physical memory left for
	 *  buffers.
	 *
	 *  If this value is less than the MIN_BUF_SIZE then set it to that
	 *  and return it.
	 */
	 		
#ifdef	CLIX
	phys_mem = getmemsize();  /* total physical memory in bytes */
#else
	/* SUN PORT HACK - getmemsize() not availabel on SUN */
	/* S.P. Rogers  25 November 1991                     */
	phys_mem = z16Mb;
#endif	
	
	if ( phys_mem < z50Mb )
		buf_mem = phys_mem - (z8_5Mb + ((phys_mem - z16Mb) / z16Mb) * z1_85Mb);
 	else
		buf_mem = (phys_mem * 3) >> 2;
		
	/* 
	 *  Allow for zbuffer/ibuffer.  5 byte/pixel * 2Mpx
 	 */

	buf_mem = buf_mem - z10Mb;
		
	if ( buf_mem < MIN_BUF_SIZE ) buf_mem = MIN_BUF_SIZE;

	return( buf_mem );
	}

/*---MMinit_texture_memory-----------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void MMinit_texture_memory(void)
#else
	void MMinit_texture_memory()
#endif

	{
	if( MMtexture_memory_limit <= 0 )
		MMtexture_memory_limit = MMcompute_texture_memory_limit();
	}

/*---MMfree_texture_memory--------------------------------------------------------------*/
	
#if defined(__STDC__) || defined(__cplusplus)
	void MMfree_texture_memory(void)
#else
	void MMfree_texture_memory()
#endif

	{
	struct MMinfo_list	*next;
	struct MMinfo_list	*curr;
	struct MMheader		*header;

	curr = MMinfo_list_top;
	while( curr != NULL )
		{
		if( curr->info->mipmap != NULL )
			{
			next = curr->next;

			header = (struct MMheader *)curr->info->mipmap;
			if ( header->from_zbuffer )
				(*tiling_parms.zfree)( 1, header );
			else
				free( header );

			curr->info->mipmap = NULL;
			curr->info->mipmap_size = 0;
			free( curr );

			curr = next;
		}
	}

	MMinfo_list_top = NULL;
	MMinfo_list_bottom = NULL;
	MMtexture_memory_used = 0;
	}

#if DEBUG_DISPLAY
/*---MMdisplay_mipmap--------------------------------------------------------*/

void MMdisplay_mipmap( mipmap )

unsigned char	*mipmap;

	{
	int			wno;
	int			vs_no;
	int			no_planes, vlt_size;
	int			x_ext, y_ext;
	int			x_pix, y_pix;
	int			num_pixels;
	struct scr_info		info[MAX_SCREENS];
	unsigned short		*buffer, *buf;
	unsigned char		*r, *g, *b;
	int			xorg, yorg, xext;
	int			event_flag;
	int			i, j, l;
	int			index_rgb();
	double			w, h;

	struct MMlayer		*layer;
	struct MMheader		*header;

	/*
	 *  Initialize graphics
	 */
	 
	Enter_tools();
	Enable_events( KEYBOARD_EVENT );

	/*
	 *  create the display window
	 */
	 
	Inq_displayed_vs( &vs_no );
	Inq_vs_info( vs_no, &no_planes, &vlt_size );
	Inq_screen_info( info );

	x_ext = 800;
	y_ext = 800;
	
	wno = create_window_no_border( 0, 0, x_ext, y_ext );
	
	Set_message_mode( 1 );
	init_rgb( no_planes );
	
	/*
	 *  read the file and display
	 */
	 
	header = (struct MMheader *)mipmap;
	layer = (struct MMlayer *)(mipmap + sizeof( struct MMheader ));
	buffer = (unsigned short *)malloc( layer->xdits * 2 );

	for( l=0; l<header->total_layers; l++ )
		{
		xorg = xoffset[l];
		yorg = yoffset[l];
		xext = xorg + layer[l].xdits - 1;
		
		r = layer[l].adr;
		g = r + layer[l].xdits;
		b = g + layer[l].xdits;

		w = (double)layer[l].xdits;
		h = (double)layer[l].ydits;

		for( i=0; i<layer[l].ydits; i++ )
			{
			buf = buffer;
			
			for( j=0; j<layer[l].xdits; j++ )
				{
				*buf++ = index_rgb( j, i, (int)r[j], (int)g[j], (int)b[j] );
				}

			buffer[0] = 1;
				
			putline16(
				wno,
				0x1ff,
				i + yorg, xext, 
				i + yorg, xorg,
				buffer );
				
			r = b + layer[l].xdits;
			g = r + layer[l].xdits;
			b = g + layer[l].xdits;
			}
		}


	Display_message( 1, CENTER, "Press Any Key To Exit" );	
	Wait_for_events( KEYBOARD_EVENT, &event_flag );
	Exit_tools();
	}
#endif

/*--------------------------------------------------------------------------------------------------
 * MMconstruct_next_layer() creates the next mipmap layer from the previous one.
 *
 * History: 12/15/90    Created                        Mike Lanier
 *
 * Algorithm:
 *
 *        width       width       width         width     
 *    h +---+---+   h +---+   h +---+---+   h +---+
 *    e |0  |  1|   e |0  |   e |0  |  1|   e |0  |
 *    i |   |   |   i |   |   i |   |   |   i |   |
 *    g +--2x2--+   g +--1x2  g +--2x1--+   g +--1x1
 *    h |   |   |   h |   |   h             h
 *    t |2  |  3|   t |2  |   t             t
 *      +---+---+     +---+     
 *    
 */
 
#if defined(__STDC__) || defined(__cplusplus)
	static void MMconstruct_next_layer( unsigned char *clayer,
						      int cwidth,
						      int cheight,
					    unsigned char *nlayer,
						      int nwidth,
						      int nheight )
#else
	static void MMconstruct_next_layer(	clayer, cwidth, cheight,
					nlayer, nwidth, nheight )

	unsigned char	*clayer;
	unsigned char	*nlayer;
	int		cwidth, cheight;
	int		nwidth, nheight;
#endif

	{
	unsigned char		*r[5], *g[5], *b[5];
	unsigned char		*cl, *nl;
	int			x, y, c;

	cl = clayer;
	nl = nlayer;
	
	/*
	 *  process all but the last scanline.  If the height of the current
	 *  layer is not divisible by 2, then the last scanline will only be the
	 *  average of 2 pixels
	 */
	 	
	for( y=1; y<nheight; y++ )
		{
			
		/*
		 *  get the address of each pixel of the 2x2 to average for the
		 *  next layer
		 */
		 
		r[0] = cl;		r[1] = r[0] + 1;
		g[0] = r[0] + cwidth;	g[1] = g[0] + 1;
		b[0] = g[0] + cwidth;	b[1] = b[0] + 1;
		r[2] = b[0] + cwidth;	r[3] = r[2] + 1;
		g[2] = r[2] + cwidth;	g[3] = g[2] + 1;
		b[2] = g[2] + cwidth;	b[3] = b[2] + 1;
		cl   = b[2] + cwidth;
		
		r[4] = nl;
		g[4] = r[4] + nwidth;
		b[4] = g[4] + nwidth;
		nl   = b[4] + nwidth;
		
		/*
		 *  process all but the last pixel.  If the width of the current
		 *  layer is not divisible by 2, then the last pixel will only be
		 *  the average of 2 pixels
		 */
		 
		for( x=1; x<nwidth; x++ )
			{
				
			/*
			 *  sum the four pixels and divide by 4
			 */
			 
			c = (int)*r[0] + (int)*r[1] + (int)*r[2] + (int)*r[3];
			*r[4] = (unsigned char)(c >> 2);
			c = (int)*g[0] + (int)*g[1] + (int)*g[2] + (int)*g[3];
			*g[4] = (unsigned char)(c >> 2);
			c = (int)*b[0] + (int)*b[1] + (int)*b[2] + (int)*b[3];
			*b[4] = (unsigned char)(c >> 2);
			
			/*
			 *  Move over to the next 2x2
			 */
			 
			r[0]++;	r[1]++;	r[2]++;	r[3]++;	r[4]++;
			g[0]++;	g[1]++;	g[2]++;	g[3]++;	g[4]++;
			b[0]++;	b[1]++;	b[2]++;	b[3]++;	b[4]++;
			r[0]++;	r[1]++;	r[2]++;	r[3]++;
			g[0]++;	g[1]++;	g[2]++;	g[3]++;
			b[0]++;	b[1]++;	b[2]++;	b[3]++;
			}

		/*
		 *  if the width of the current layer is not dividible by 2, then
		 *  average only the 1x2, else average the 2x2
		 */
		 
		if( cwidth & 1 )
			{
			c = (int)*r[0] + (int)*r[2];
			*r[4] = (unsigned char)(c >> 1);
			c = (int)*g[0] + (int)*g[2];
			*g[4] = (unsigned char)(c >> 1);
			c = (int)*b[0] + (int)*b[2];
			*b[4] = (unsigned char)(c >> 1);
			}
		else
			{
			c = (int)*r[0] + (int)*r[1] + (int)*r[2] + (int)*r[3];
			*r[4] = (unsigned char)(c >> 2);
			c = (int)*g[0] + (int)*g[1] + (int)*g[2] + (int)*g[3];
			*g[4] = (unsigned char)(c >> 2);
			c = (int)*b[0] + (int)*b[1] + (int)*b[2] + (int)*b[3];
			*b[4] = (unsigned char)(c >> 2);
			}
		}

	/*
	 *  if the height of the current layer is not dividible by 2, then
	 *  average only the 2x1, else average the 2x2
	 */
		 
	if( cheight & 1 )
		{
		r[0] = cl;		r[1] = r[0] + 1;
		g[0] = r[0] + cwidth;	g[1] = g[0] + 1;
		b[0] = g[0] + cwidth;	b[1] = b[0] + 1;
		r[2] = b[0] + cwidth;	r[3] = r[2] + 1;
		g[2] = r[2] + cwidth;	g[3] = g[2] + 1;
		b[2] = g[2] + cwidth;	b[3] = b[2] + 1;
		cl   = b[2] + cwidth;
		
		r[4] = nl;
		g[4] = r[4] + nwidth;
		b[4] = g[4] + nwidth;
		nl   = b[4] + nwidth;
		
		for( x=1; x<nwidth; x++ )
			{
			c = (int)*r[0] + (int)*r[1];
			*r[4] = (unsigned char)(c >> 1);
			c = (int)*g[0] + (int)*g[1];
			*g[4] = (unsigned char)(c >> 1);
			c = (int)*b[0] + (int)*b[1];
			*b[4] = (unsigned char)(c >> 1);
			
			r[0]++;	r[1]++;	r[2]++;	r[3]++;	r[4]++;
			g[0]++;	g[1]++;	g[2]++;	g[3]++;	g[4]++;
			b[0]++;	b[1]++;	b[2]++;	b[3]++;	b[4]++;
			r[0]++;	r[1]++;	r[2]++;	r[3]++;
			g[0]++;	g[1]++;	g[2]++;	g[3]++;
			b[0]++;	b[1]++;	b[2]++;	b[3]++;
			}

		/*
		 *  if the width of the current layer is not dividible by 2, then
		 *  average only the 1x1, else average the 2x1
		 */
		 
		if( cwidth & 1 )
			{
			*r[4] = *r[0];
			*g[4] = *g[0];
			*b[4] = *b[0];
			}
		else
			{
			c = (int)*r[0] + (int)*r[1];
			*r[4] = (unsigned char)(c >> 1);
			c = (int)*g[0] + (int)*g[1];
			*g[4] = (unsigned char)(c >> 1);
			c = (int)*b[0] + (int)*b[1];
			*b[4] = (unsigned char)(c >> 1);
			}
		}
	else
		{
		r[0] = cl;		r[1] = r[0] + 1;
		g[0] = r[0] + cwidth;	g[1] = g[0] + 1;
		b[0] = g[0] + cwidth;	b[1] = b[0] + 1;
		r[2] = b[0] + cwidth;	r[3] = r[2] + 1;
		g[2] = r[2] + cwidth;	g[3] = g[2] + 1;
		b[2] = g[2] + cwidth;	b[3] = b[2] + 1;
		cl   = b[2] + cwidth;
		
		r[4] = nl;
		g[4] = r[4] + nwidth;
		b[4] = g[4] + nwidth;
		nl   = b[4] + nwidth;
		
		for( x=1; x<nwidth; x++ )
			{
			c = (int)*r[0] + (int)*r[1] + (int)*r[2] + (int)*r[3];
			*r[4] = (unsigned char)(c >> 2);
			c = (int)*g[0] + (int)*g[1] + (int)*g[2] + (int)*g[3];
			*g[4] = (unsigned char)(c >> 2);
			c = (int)*b[0] + (int)*b[1] + (int)*b[2] + (int)*b[3];
			*b[4] = (unsigned char)(c >> 2);
			
			r[0]++;	r[1]++;	r[2]++;	r[3]++;	r[4]++;
			g[0]++;	g[1]++;	g[2]++;	g[3]++;	g[4]++;
			b[0]++;	b[1]++;	b[2]++;	b[3]++;	b[4]++;
			r[0]++;	r[1]++;	r[2]++;	r[3]++;
			g[0]++;	g[1]++;	g[2]++;	g[3]++;
			b[0]++;	b[1]++;	b[2]++;	b[3]++;
			}

		if( cwidth & 1 )
			{
			c = (int)*r[0] + (int)*r[2];
			*r[4] = (unsigned char)(c >> 1);
			c = (int)*g[0] + (int)*g[2];
			*g[4] = (unsigned char)(c >> 1);
			c = (int)*b[0] + (int)*b[2];
			*b[4] = (unsigned char)(c >> 1);
			}
		else
			{
			c = (int)*r[0] + (int)*r[1] + (int)*r[2] + (int)*r[3];
			*r[4] = (unsigned char)(c >> 2);
			c = (int)*g[0] + (int)*g[1] + (int)*g[2] + (int)*g[3];
			*g[4] = (unsigned char)(c >> 2);
			c = (int)*b[0] + (int)*b[1] + (int)*b[2] + (int)*b[3];
			*b[4] = (unsigned char)(c >> 2);
			}
		}
	}
	
/*--------------------------------------------------------------------------------------------------
 * MMmake_mipmap() creates a pyramidal "mipmap" from a type 27 rle file (infile) and places this map
 * in memory
 *
 * PRE: 'infile' must be a unix file open for reading.
 *
 * HISTORY: 07/26/89	Created.			Trevor Mink
 *          12/15/90    Converted to place output in
 *                      main memory                     Mike Lanier
 */

#if defined(__STDC__) || defined(__cplusplus)
	static void MMmake_mipmap( int *infile,
			       IGRchar *mipmap )
#else
	static void MMmake_mipmap( infile, mipmap )

	int			*infile;
	unsigned char		*mipmap;
#endif

	{
	int			i;
	int			lineread;
	unsigned char		*r, *g, *b;	
	struct MMheader		*header;
	struct MMlayer		*layer;

	if( mipmap == NULL ) return;

	header = (struct MMheader *)mipmap;
	layer  = (struct MMlayer *)(mipmap + sizeof( struct MMheader ));

	/*
	 *  read the rgb data into the first layer of the 
	 *  mipmap
	 */

	lineread = 1;

	r = layer[0].adr;
	g = r + layer[0].xdits;
	b = g + layer[0].xdits;

	for( i=0; i<layer[0].ydits && lineread; i++ )
		{
		lineread = HSread_type27_scanline( infile, layer[0].xdits, (int)1, r, g, b );

		r = b + layer[0].xdits;
		g = r + layer[0].xdits;
		b = g + layer[0].xdits;
		}

	for( i=1; i<header->total_layers; i++ )
		{
		MMconstruct_next_layer( layer[i-1].adr, layer[i-1].xdits, layer[i-1].ydits,
					layer[  i].adr, layer[  i].xdits, layer[  i].ydits );
		}

	} /* MMmake_mipmap */

/*--------------------------------------------------------------------------------------------------
 * MMmake_mipmap_25() creates a pyramidal "mipmap" from a type 25 rle file (infile) and places this map
 * in memory
 *
 * PRE: 'infile' must be a unix file open for reading.
 *
 * HISTORY: 07/26/89	Created.			Trevor Mink
 *          12/15/90    Converted to place output in
 *                      main memory                     Mike Lanier
 */

#if defined(__STDC__) || defined(__cplusplus)
	static void MMmake_mipmap_25( int *infile,
				  IGRchar *mipmap )
#else
	static void MMmake_mipmap_25( infile, mipmap )

	int			*infile;
	unsigned char		*mipmap;
#endif

	{
	int			i;
	unsigned char		*r, *g, *b;	
	unsigned short		*file_buffer;
	struct MMheader		*header;
	struct MMlayer		*layer;

	if( mipmap == NULL ) return;

	header = (struct MMheader *)mipmap;
	layer  = (struct MMlayer *)(mipmap + sizeof( struct MMheader ));

	/*
	 *  read the rgb data into the first layer of the 
	 *  mipmap
	 */


	file_buffer = (unsigned short *)alloca( layer[0].xdits * 4 );

	r = layer[0].adr;
	g = r + layer[0].xdits;
	b = g + layer[0].xdits;

	for( i=0; i<layer[0].ydits; i++ )
		{
		HSread_type25_scanline( infile, file_buffer, layer[0].xdits, r, g, b );

		r = b + layer[0].xdits;
		g = r + layer[0].xdits;
		b = g + layer[0].xdits;
		}

	for( i=1; i<header->total_layers; i++ )
		{
		MMconstruct_next_layer( layer[i-1].adr, layer[i-1].xdits, layer[i-1].ydits,
					layer[  i].adr, layer[  i].xdits, layer[  i].ydits );
		}

	} /* MMmake_mipmap */

/*--------------------------------------------------------------------------------------------------
 * MMmake_h_mipmap() creates a pyramidal "mipmap" from a type 27 rle file (infile) and places this map
 * in memory
 *
 * PRE: 'infile' must be a unix file open for reading.
 *
 * HISTORY: 07/26/89	Created.			Trevor Mink
 *          12/15/90    Converted to place output in
 *                      main memory                     Mike Lanier
 */

#if defined(__STDC__) || defined(__cplusplus)
	static void MMmake_h_mipmap( int *infile,
				 IGRchar *mipmap )
#else
	static void MMmake_h_mipmap( infile, mipmap )

	int			*infile;
	unsigned char		*mipmap;
#endif

	{
	int			i;
	int			lineread;
	unsigned char		*r, *g, *b;	
	struct MMheader		*header;
	struct MMlayer		*layer;

	if( mipmap == NULL ) return;

	header = (struct MMheader *)mipmap;
	layer  = (struct MMlayer *)(mipmap + sizeof( struct MMheader ));

	/*
	 *  read the rgb data into the first layer of the 
	 *  mipmap
	 */

	lineread = 1;

	r = layer[0].adr + layer[0].xdits - 1;
	g = r + layer[0].xdits;
	b = g + layer[0].xdits;

	for( i=0; i<layer[0].xdits && lineread; i++ )
		{
		lineread = HSread_type27_scanline( infile, layer[0].ydits, (layer[0].xdits*3), r, g, b );

		r--;
		g--;
		b--;
		}

	for( i=1; i<header->total_layers; i++ )
		{
		MMconstruct_next_layer( layer[i-1].adr, layer[i-1].xdits, layer[i-1].ydits,
					layer[  i].adr, layer[  i].xdits, layer[  i].ydits );
		}

	} /* MMmake_mipmap */

/*---MMcompute_memory_usage_and_allocate--------------------------------------*/

/*
 *  The purpose of this function is to determine how much memory is needed
 *  for the mipmap and to allocate that from the mipmap cache.  An error
 *  will return if there is not enough memory
 */

#if defined(__STDC__) || defined(__cplusplus)
	static void MMcompute_memory_usage_and_allocate( struct HRtexture_list *surface_texture,
									   int height,
									   int width )
#else
	static void MMcompute_memory_usage_and_allocate( surface_texture, height, width )

	struct HRtexture_list	*surface_texture;
	int			height, width;
#endif

	{
	double			h, w;
	int			nlayers, i;
	int			total_bytes;
	struct MMlayer		*layer, layer_buffer[20];
	struct MMheader		*header;
	int			Width, Height;
	int			buf_size;
	int			from_zbuffer = FALSE;

	/*
	 *  first, lets determine how many layers we're going to have
	 *  and how much memory will be needed for each layer.
	 */

	h = (double)height;
	w = (double)width;
	nlayers = 0;
	total_bytes = 0;
	layer = layer_buffer;

	do
		{
		layer[nlayers].xdits = Width = (int)(w + 0.5);
		layer[nlayers].ydits = Height = (int)(h + 0.5);
		layer[nlayers].total_bytes = layer[nlayers].xdits * layer[nlayers].ydits * 3;
		layer[nlayers].d = 2.0 / (float)( Width + Height );
		total_bytes += layer[nlayers].total_bytes;
		nlayers++;

		w /= 2.0;
		h /= 2.0;
		}
	while( h > 0.5 && w > 0.5 );

	/*
	 *  allocate memory for the entire mipmap, this includes one header structure, "nlayer"
	 *  layer structures and memory for the mipmap
	 */
	 
#if DEBUGD
	MMdisplay_texture_list();
#endif

	surface_texture->mipmap_size = ( sizeof( struct MMheader ) + (sizeof( struct MMlayer ) * nlayers) + total_bytes );

	if( (surface_texture->mipmap_size + MMtexture_memory_used) > MMtexture_memory_limit )
		{
		surface_texture->mipmap = (char *)MMremove_texture_from_list( surface_texture->mipmap_size,
	                                                                      &from_zbuffer );
		}
	else
		{
	        surface_texture->mipmap = (char *)(*tiling_parms.zmalloc)( 1, surface_texture->mipmap_size,
		                                                           &buf_size, NULL );
		if ( surface_texture->mipmap )
			from_zbuffer = TRUE;
		else
			surface_texture->mipmap = (char *)malloc( surface_texture->mipmap_size );
		}

	/*
	 *  If unable to allocate memory for the texture map, set the filename to NULL so we won't
	 *  try this for every scanline
	 */

	if( surface_texture->mipmap == NULL )
		{
		surface_texture->Fname[0] = 0;
		return;
		}

	MMadd_texture_to_list( surface_texture );

	header = (struct MMheader *)surface_texture->mipmap;
	layer  = (struct MMlayer *)(surface_texture->mipmap + sizeof( struct MMheader ) );
		
	header->total_layers = nlayers;
	header->from_zbuffer = from_zbuffer;
	memcpy( layer, layer_buffer, (sizeof( struct MMlayer ) * nlayers) );
	
	layer[0].adr = (unsigned char *) surface_texture->mipmap + 
	                                 sizeof( struct MMheader ) +
	                                 (sizeof(struct MMlayer) * nlayers);

	for( i=1; i<nlayers; i++ )
		layer[i].adr = layer[i-1].adr + layer[i-1].total_bytes;

#	if DEBUG
	i = 0;
	
	fprintf( stderr, "\n" );
	fprintf( stderr, "number of layers: %1d\n", header->total_layers );
	fprintf( stderr, "bytes required:   %1d\n", total_bytes );
	fprintf( stderr, "mipmap adress:    %x\n\n", surface_texture->mipmap );
	
	fprintf( stderr, "layer xdits ydits  bytes    addr   d value\n" );
	fprintf( stderr, "----- ----- ----- ------- -------- -------\n" );
	for( i=0; i<nlayers; i++ )
		{
		fprintf( stderr, " %3d  %5d %5d %7d %x %f\n", i, layer[i].xdits, layer[i].ydits,
			layer[i].total_bytes, layer[i].adr, layer[i].d );
		}
	fprintf( stderr, "\n" );
#	endif
	}
	
/*--- HRopen_texture_file -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HRopen_texture_file( char *filename,
				   int *fp,
				  char *opened_name )
#else
	void HRopen_texture_file( filename, fp, opened_name )

	char	*filename;
	int	*fp;
	char	*opened_name;  /* NULL, if not desired */
#endif

/*
DESCRIPTION
	This function opens a texture file and returns a FILE pointer to
	it and optionally, the name of the file that was opened.  It first
	tries to open the file exactly as the path/name that was passed in.
	If that fails, it strips the name from the path/name that was passed
	in and tries to open the file in the model/config/textures directory.

HISTORY
	S.P. Rogers  09/10/91  Creation Date
*/

	{
	char	*last_slash;
	char	model_path[300], new_filename[300], name_only[300];

	*fp = -1;

	/* try to open file as keyed in by user */

	if( (*fp = open( filename, 0 )) != -1 )
		{
		if( opened_name )
			strcpy( opened_name, filename );
		}
	else
		{

		/* couldn't open file as keyed in by user => strip out file name from the */
		/* path and see if the file is in the model/config/textures directory     */
		
		if( last_slash = (char *)strrchr( filename, '/' ) )
			{
			if( last_slash == &filename[strlen(filename)-1] )
				return;  /* last character is a slash */

			strcpy( name_only, (last_slash + 1) );
			}
		else
			strcpy( name_only, filename );

		get_modtype_data( "Model",NULL,NULL,NULL,NULL, model_path );

		sprintf( new_filename, "%s/config/textures/%s", model_path, name_only );
		if( (*fp = open( new_filename, 0 )) != -1 )
			{
			if( opened_name )
				strcpy( opened_name, new_filename );
			}
		}

	}  /* HRopen_texture_file */

/*---MMload----------------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void MMload( struct HRtexture_list *surface_texture )
#else
	void MMload( surface_texture )

	struct HRtexture_list	*surface_texture;
#endif

	{
	int	infile;
	short	app_type_code;
	short	data_type_code;
	long	num_cols, num_rows;
	int	height, width;

	HRopen_texture_file( surface_texture->Fname, &infile, (char *)NULL );

	HSread_rasterfile_header(
			&infile,
			&data_type_code,
			&app_type_code,
			&num_rows,
			&num_cols,
			NULL, NULL );

	/*
	 *  Special case ModelView type 27 rasterfiles
	 */
	 
	if( data_type_code == 27 && app_type_code == 9 )
		{
		height = num_cols;
		width = num_rows;
		}
	else
		{
		height = num_rows;
		width = num_rows;
		}
		
	MMcompute_memory_usage_and_allocate( surface_texture, height, width );

	if( data_type_code == 25 )
		MMmake_mipmap_25( &infile, surface_texture->mipmap );
	else
		if( app_type_code == 9 )
			MMmake_h_mipmap( &infile, surface_texture->mipmap );
		else
			MMmake_mipmap( &infile, surface_texture->mipmap );

	close( infile );
	}
