/*
 *  HSbldphyctbl.c --- Build Physical Colortable
 *
 *	Given a physical table, build shades off the base colors.
 *
 *
 *
 *  Function Call:
 *
 *	build_phys_tbl( num_colors, num_shades, colortable, dac_size );
 *
 *  Arguments:
 *
 *	int	num_colors ------------- The number of base colors
 *	int	num_shades ------------- The numver of shades to build off the
 *			                 base color
 *	struct vlt_slot	colortable[] --- The colortable array containing
 *					 the base colors, and where this
 *					 function will stroke the shades.
 *	int	dac_size --------------- The dac size of the display device.
 *					 IP32C has 4 bit dacs.  This is used
 *					 to guarentee that steps between shades
 *					 remain uniform after the data is
 *					 truncated.
 *
 *
 *  Assumptions:
 *
 *	In the colortable array, it is assumed that entry 0, colortable[0],
 *	is the first base colors.
 *
 *	In the colortable array, it is assumed that each base color is
 *	positioned 'num_shades' apart from each other.  IE.  if we have
 *	a case where there are 3 colors and 4 shades, then the base colors
 *	will be at:
 *
 *		colortable[0] --- base color 1
 *		colortable[4] --- base color 2
 *		colortable[8] --- base color 3
 *
 */
 
#include <stdio.h>
#include <sdl.h>
#include <tools.h>

#define	ROUND(x) x>0 ? (x + 0.5):(x - 0.5)

#define	MAX2( x, y )	x > y ? x : y
#define MAX( x, y, z )	MAX2( MAX2( x, y ), z )

#define DEBUG		0

/*---build_phys_tbl-------------------------------------------------------------*/

void	build_phys_tbl( num_colors, num_shades, colortable, dac_size )

int		num_colors;
int		num_shades;
struct vlt_slot	colortable[];
int		dac_size;

	{
	int		color, 	c, dac_shifter;
	int		x, y;
	double		red, green, blue;
	int		red_step, green_step, blue_step;
	int		bot_col, num_shades_less_one;	
	
	dac_shifter = 16 - dac_size;
   		
	for( c=1, color=0; c<=num_colors; c++, color += num_shades )
		{
#		if DEBUG
			printf( "%d %4x %4x %4x\n", color,
				 colortable[color].v_red,
				 colortable[color].v_green,
				 colortable[color].v_blue );
#		endif
				 
	 	red =   (double)(colortable[color].v_red   >> dac_shifter);
		green = (double)(colortable[color].v_green >> dac_shifter);
		blue =  (double)(colortable[color].v_blue  >> dac_shifter);
			
		red_step = ROUND((red/((double)num_shades - 0.5)));
		green_step = ROUND((green/((double)num_shades - 0.5)));
		blue_step = ROUND((blue/((double)num_shades - 0.5)));
	
		bot_col = red - (red_step*(num_shades_less_one = num_shades-1));
		while (bot_col < 0)
			{ 
			red_step = red_step - 1;
			bot_col = red - (red_step*(num_shades_less_one));
			}
		bot_col = green - (green_step*(num_shades_less_one));
		while (bot_col < 0)
			{
			green_step = green_step - 1;
			bot_col = green - (green_step*(num_shades_less_one));	
			}
	
		bot_col = blue - (blue_step*(num_shades_less_one));
		while (bot_col < 0)
			{
			blue_step = blue_step - 1;
			bot_col = blue - (blue_step*(num_shades_less_one));
			}	 

		red_step <<= dac_shifter;
		green_step <<= dac_shifter;
		blue_step <<= dac_shifter;
		
		for ( x=1, y=color; x<num_shades; x++, y++ )
			{
			colortable[y+1].v_red   = colortable[y].v_red   - red_step;
			colortable[y+1].v_green = colortable[y].v_green - green_step;
			colortable[y+1].v_blue  = colortable[y].v_blue  - blue_step;
			}
		}
	}
