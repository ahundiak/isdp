
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hslight_include
#define hslight_include 1

/*
 * hslight.h contains structure definitions for using light sources
 * All unsigned types don't use IGR types because ASAPII compilation
 * requires strict ANSI mode and "unsigned IGRint", etc. is not
 * allowed in ANSI mode.
 * 
 * For a detailed discription of the meaning of each variable in the 
 * struct HS_light_source, see the NOTES below. [TW]
 */

#define MAX_LIGHTS 8

/* generic light source structure */
struct	HS_light_source
	{
	IGRdouble      target[3];        /* light source target       */
	IGRdouble      location[3];      /* light source location     */
	IGRdouble      direction[3];     /* light source direction    */
	IGRdouble      radius;           /* light source radius       */
	IGRdouble      angle;            /* light source angle (spot) */
	unsigned short red, green, blue; /* light source RGB (0-255)  */
	unsigned short flags;            /* light source type         */
	};

/* bit use for light source flags word

	.... .... .... xxxx   - light source type
	.x.. .... .... ....   - light source alignment 0=window, 1=database
	x... .... .... ....   - light source enabled/disabled 0=disabled, 1=enabled
*/

#define HS_LIGHT_TYPE     0x001F  /* [TW] */
#define HS_LIGHT_AMBIENT  0x0000
#define HS_LIGHT_PARALLEL 0x0001
#define HS_LIGHT_POINT    0x0002
#define HS_LIGHT_PENCIL   0x0004
#define HS_LIGHT_SPOT     0x0008
#define HS_LIGHT_BANK     0x0010  /* [TW] */
#define HS_LIGHT_DATABASE 0x4000
#define HS_LIGHT_ENABLED  0x8000

/* [TW]
 NOTES:

 1) When flags == HS_LIGHT_BANK

    When the flags is HS_LIGHT_BANK, the loaction[] is the center point of the 
    bank light rectangle. The target[] and direction[] are vectors. The cross
    product (target[] X direction[]) is a vector representing the direction of
    the light shooting.  The lengthes target[] and direction[] are 1/2 of the
    two sides of the rectangle. All of these are in world coordinate system.

                                 direction[]
                  ------------------^--------------------
                  |                 |                   |
                  |                 |                   |
                  |                 |                   |
                  |                 *------------------>| target[]
                  |             location[]              |
                  |                                     |
                  |                                     |
                  ---------------------------------------

    The <red, green, blue> is the light color, as other light types.

    The usage of "radius" and "angle" is subject to applications. They are not
    used in determining the the bank light graphics. Light source management
    only helps to save and retrieve these values. (But whence their usage are
    defined, they should be commented here.) 

  2) When flags == ... other light type ...

*/

#endif
