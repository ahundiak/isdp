
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#include <stdio.h>
#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "HStl_global.h"
#include "hslight.h"
#include "hsdisplay.h"
#include "hrstruct.h"
#include "hrmipmap.h"

#include "HSpr_render.h"



#define TEXTURE_TEST	0
#define NEW_DEBUG	0
#define NEWER_DEBUG	0
#define DEBUG		0
#define DEBUG_MIPMAP	0
#define	MAX_MIPMAPS	9

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

/* HRtexturize.c */
static void HRpoint_sample __((		  unsigned int *Red, 
					  unsigned int *Green, 
					  unsigned int *Blue, 
						double u, 
						double v, 
					 unsigned char *MipMap, 
						   int Width, 
						   int Height));
						   
static void HRget_level_RGB __((	  unsigned int *Red, 
					  unsigned int *Green, 
					  unsigned int *Blue, 
					        double u, double v, 
					 unsigned char *MipMap, 
						   int Width, 
						   int Height));

#if defined(__cplusplus)
}
#endif


#undef __



#if defined(__STDC__) || defined(__cplusplus)
	static void HRpoint_sample( unsigned int *Red,
				    unsigned int *Green,
				    unsigned int *Blue,
					  double u,
					  double v,
				   unsigned char *MipMap,
					     int Width,
					     int Height )
#else
	static void HRpoint_sample( Red, Green, Blue, u, v, MipMap, Width, Height )
	unsigned int *Red, *Green, *Blue;
	double u, v;
	unsigned char *MipMap;
	int Width, Height;
#endif

{
	int ulo, vlo;
	int RedIndex, GreenIndex, BlueIndex;

	ulo = (int)u;
	if( ulo == Width ) ulo -= 1;

	vlo = (int)v;
	if( vlo == Height ) vlo -= 1;

	RedIndex = Width * vlo * 3 + ulo;
	GreenIndex = RedIndex + Width;
	BlueIndex = GreenIndex + Width;

	*Red = (unsigned int)MipMap[RedIndex];
	*Green = (unsigned int)MipMap[GreenIndex];
	*Blue = (unsigned int)MipMap[BlueIndex];

} /* HRpoint_sample */

/*
 * HRget_level_RGB() returns in 'Red', 'Green', and 'Blue' an RGB value from the level of width 'Width'
 * which represents an interpolated average for the square area whose center is at 'u','v' and whose
 * sides are 'du x dv' in length.
 *
 * HISTORY: 11/01/90	Created.
 *								Trevor Mink
 */

#if defined(__STDC__) || defined(__cplusplus)
	static void HRget_level_RGB( unsigned int *Red,
				     unsigned int *Green,
				     unsigned int *Blue,
					   double u,
					   double v,
				    unsigned char *MipMap,
					      int Width,
					      int Height )
#else
	static void HRget_level_RGB( Red, Green, Blue, u, v, MipMap, Width, Height )
	unsigned int *Red, *Green, *Blue;
	double u, v;
	unsigned char *MipMap;
	int Width, Height;
#endif

{
	int 	ulo, vlo;
	int 	RedIndex, GreenIndex, BlueIndex;
	double 	du, dv;
	int 	R[4], G[4], B[4];
	double 	Temp;
	double 	Temp2; /* This one can be negative */

#if TEXTURE_TEST
	fprintf( stderr, "Entering HRget_levelRGB\n" );
	fprintf( stderr, "u, v, Width, Height = %lf, %lf, %d, %d\n",u, v, Width, Height );
#endif
	/* Determine Range box of RGB's to interpolate */
	ulo = (int)u;
	vlo = (int)v;
#if DEBUG
	fprintf( stderr, "ulo = %d\n", ulo );
	fprintf( stderr, "vlo = %d\n", vlo );
#endif
	du = u - (double)ulo;
	dv = v - (double)vlo;

#if NEW_DEBUG
	fprintf( stderr, "u, du = %lf, %lf\n", u, du );
	fprintf( stderr, "v, dv = %lf, %lf\n", v, dv );
#endif
	if( u <= 0.5 )
	{
		du = 0.0;
		ulo = 0;
	}
	else if( u >= (Width - 0.5) )
	{
		du = 0.0;
		ulo = Width - 1;
	}
	else
	{
		if( ulo == (int)(u + 0.5) ) ulo -= 1;
		if( du < 0.5 ) du += 0.5;
		else du -= 0.5;
	}

	if( v <= 0.5 )
	{
		vlo = 0;
		dv = 0.0;
	}
	else if( v >= (Height - 0.5) )
	{
		vlo = Height - 1;
		dv = 0.0;
	}
	else
	{
		if( vlo == (int)(v + 0.5) ) vlo -= 1;
		if( dv < 0.5 ) dv += 0.5;
		else dv -= 0.5;
	}

	RedIndex = Width * vlo * 3 + ulo;
	GreenIndex = RedIndex + Width;
	BlueIndex = GreenIndex + Width;
#if DEBUG
	fprintf( stderr, "MipMap = %x\tRGB Indices = %x, %x, %x\n",
		MipMap, MipMap+RedIndex, MipMap+GreenIndex, MipMap+BlueIndex );
	fprintf( stderr, "Width = %d\tHeight = %d\n", Width, Height );
#endif

	R[0] = MipMap[RedIndex];
	G[0] = MipMap[GreenIndex];
	B[0] = MipMap[BlueIndex];

	if( dv == 0 )
	{
		R[1] = MipMap[RedIndex];
		G[1] = MipMap[GreenIndex];
		B[1] = MipMap[BlueIndex];
	}
	else
	{
		R[1] = MipMap[RedIndex+1];
		G[1] = MipMap[GreenIndex+1];
		B[1] = MipMap[BlueIndex+1];
	}

#if NEW_DEBUG
	fprintf( stderr, "R0, G0, B0 = %d, %d, %d\n", R[0], G[0], B[0] );
	fprintf( stderr, "R1, G1, B1 = %d, %d, %d\n", R[1], G[1], B[1] );
#endif

	if( du != 0 )
	{
		RedIndex += Width * 3;
		GreenIndex += Width * 3;
		BlueIndex += Width * 3;
	}

	R[2] = MipMap[RedIndex];
	G[2] = MipMap[GreenIndex];
	B[2] = MipMap[BlueIndex];

	if( dv == 0 )
	{
		R[3] = MipMap[RedIndex];
		G[3] = MipMap[GreenIndex];
		B[3] = MipMap[BlueIndex];
	}
	else
	{
		R[3] = MipMap[RedIndex+1];
		G[3] = MipMap[GreenIndex+1];
		B[3] = MipMap[BlueIndex+1];
	}

#if NEW_DEBUG
	fprintf( stderr, "R2, G2, B2 = %d, %d, %d\tR3, G3, B3 = %d, %d, %d\n",
		R[2], G[2], B[2], R[3], G[3], B[3] );
#endif
	Temp = du * (double)(R[1] - R[0]) + (double)(R[0]);
	Temp2 = du * (double)(R[3] - R[2]) + (double)(R[2]) - Temp;
	*Red = (unsigned int)( dv * Temp2 + Temp );
#if NEWER_DEBUG
	fprintf( stderr, "Temp for *Red = %lf\n", Temp );
	fprintf( stderr, "Temp2 for *Red = %lf\n", Temp2 );
	fprintf( stderr, "*Red = %d\n", *Red );
#endif
	Temp = du * (double)(G[1] - G[0]) + (double)(G[0]);
	Temp2 = du * (double)(G[3] - G[2]) + (double)(G[2]) - Temp;
	*Green = (unsigned int)( dv * Temp2 + Temp );
#if NEWER_DEBUG
	fprintf( stderr, "Temp for *Green = %lf\n", Temp );
	fprintf( stderr, "Temp2 for *Green = %lf\n", Temp2 );
	fprintf( stderr, "*Green = %d\n", *Green );
#endif
	Temp = du * (double)(B[1] - B[0]) + (double)(B[0]);
	Temp2 = du * (double)(B[3] - B[2]) + (double)(B[2]) - Temp;
	*Blue = (unsigned int)( dv * Temp2 + Temp );
#if NEWER_DEBUG
	fprintf( stderr, "Temp for *Blue = %lf\n", Temp );
	fprintf( stderr, "Temp2 for *Blue = %lf\n", Temp2 );
	fprintf( stderr, "*Blue = %d\n", *Blue );
#endif

#if TEXTURE_TEST
	fprintf( stderr, "Layer RGB = %d, %d, %d\n", *Red, *Green, *Blue );
#endif

} /* HSget_level_RGB */

/*----------------------------------------------------------------------------------------------------
 * HSget_RGB() takes the u,v values of the four corners of a pixel, and the d value (u,v average width
 * of the pixel), and uses tri-linear interpolation on the pyramidal mipmap in memory to determine RGB
 * values for the current pixel.
 *
 * HISTORY: 10/30/90	Created.
 *								Trevor Mink
 */

#if defined(__STDC__) || defined(__cplusplus)
	int HRget_RGB(	       HRuv u,
			       HRuv v,
			      float d,
		       unsigned int *Red,
		       unsigned int *Green,
		       unsigned int *Blue,
	      struct HRtexture_list *surface_texture )
#else
	int HRget_RGB( u, v, d, Red, Green, Blue, surface_texture )

	HRuv			u, v;
	float d;
	unsigned int		*Red, *Green, *Blue;
	struct HRtexture_list	*surface_texture;
#endif

	{

	int i;
	float d_diff, delta_d;
	int delta_Red, delta_Green, delta_Blue;
	unsigned char	*mipmap;
	struct MMlayer	*layer;
	struct MMheader	*header;
	double x, y;
	unsigned int r, g, b;

	if( surface_texture == NULL || surface_texture->Fname[0] == 0 )
	{
		return(FALSE);
	}
        else
	{
		if( surface_texture->mipmap == NULL )
		{
			MMload( surface_texture );
			if( surface_texture->mipmap == NULL ) return( FALSE );
		}
	}

        mipmap = (unsigned char *)surface_texture->mipmap;
	header = (struct MMheader *)mipmap;
	layer = (struct MMlayer *)(mipmap + sizeof( struct MMheader ) );

	/* First, find the layer to use or layers to interpolate between */
	for( i = 0; d > (double)layer[i].d && i < header->total_layers; i++ );

	if( i == 0 ) d = layer[i].d;

	if( d != layer[i].d ) i--;

#if TEXTURE_TEST
	fprintf( stderr, "d = %f\ti = %d\tlayer_d = %f\tlayer_d+1 = %f\n", d, i,
		layer[i].d, layer[i+1].d );
#endif
	x = u * (HRuv)(layer[i].xdits);
	y = v * (HRuv)(layer[i].ydits);

	if( d != layer[i].d && i+1 < header->total_layers )
	{
		HRget_level_RGB( Red, Green, Blue, x, y, layer[i].adr, layer[i].xdits, layer[i].ydits );

		x = u * (HRuv)(layer[i+1].xdits);
		y = v * (HRuv)(layer[i+1].ydits);
		HRpoint_sample( &r, &g, &b, x, y, layer[i+1].adr, layer[i+1].xdits, layer[i+1].ydits );

		d_diff = d - layer[i].d;
		delta_d = layer[i+1].d - layer[i].d;
		delta_Red = r - *Red;
		delta_Green = g - *Green;
		delta_Blue = b - *Blue;
#if TEXTURE_TEST
		fprintf( stderr, "d_diff, delta_d, delta_Red, delta_Green, delta_Blue = " );
		fprintf( stderr, "%f, %f, %d, %d, %d\n", d_diff, delta_d,
			delta_Red, delta_Green, delta_Blue );
#endif
		*Red += (unsigned int)( (float)delta_Red * d_diff / delta_d + 0.5 );
		*Green += (unsigned int)( (float)delta_Green * d_diff / delta_d + 0.5 );
		*Blue += (unsigned int)( (float)delta_Blue * d_diff / delta_d + 0.5 );
#if TEXTURE_TEST
		fprintf( stderr, "Interpolated result rgb = %d, %d, %d\n", *Red, *Green, *Blue);
#endif
	}
	else
		HRpoint_sample( Red, Green, Blue, x, y, layer[i].adr, layer[i].xdits, layer[i].ydits );

	return( TRUE );
}
