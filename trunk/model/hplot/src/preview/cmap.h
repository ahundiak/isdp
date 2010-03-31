#ifndef CMAP_H
#define CMAP_H

#define BLACK		0
#define	GREEN		1
#define	RED		2
#define	BLUE		3
#define	YELLOW		4
#define	CYAN		5
#define	MAGENTA		6
#define	WHITE		7
#define GRAY		8
#define	LIGHTGREEN	9
#define	LIGHTRED	10
#define	LIGHTBLUE	11
#define	LIGHTYELLOW	12
#define	LIGHTCYAN	13
#define	LIGHTMAGENTA	14
#define	LIGHTGRAY	15

/*---IGEcmap_color_to_index------------------------------*/

extern int IGEcmap_color_to_index (WLuint32 context_no,
                                   WLuint32 index,
                                   WLuint32 red,
                                   WLuint32 green,
                                   WLuint32 blue,
                                   WLuint32 flag,
                                   WLuint32 *phy_index);

/*---IGEcmap_color_to_rgb------------------------------*/

extern int IGEcmap_color_to_rgb( WLuint32 context_no, 
                                 WLuint32 index, 
                                 WLuint32 red, 
                                 WLuint32 green, 
                                 WLuint32 blue, 
                                 WLuint32 flag, 
                                 WLuint32 *out_red, 
                                 WLuint32 *out_green, 
                                 WLuint32 *out_blue );

/*---IGEcmap_init------------------------------*/

extern int IGEcmap_init( WLuint32 context_no );

#endif
