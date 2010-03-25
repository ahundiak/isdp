#ifndef _EMFONT
#define _EMFONT	0


/************************************************************************/
/*									*/
/*	Font Table Offsets						*/
/*									*/
/*	There are two offset types:  a font-table offset and a 		*/
/*	font-type offset.  The font-table offsets point to the		*/
/*	first entries of their respeceive tables.  The "normal" font    */
/*	tables (encompassing 7-bit ASCII codes) occupy the first six	*/
/*	entries of the font tables (indices 0 - 5), while the 		*/
/*	"graphics" font tables (encompassing the 8-bit ASCII codes)	*/
/*	occupy the last six entries (indices 6 - 11).			*/
/*									*/
/*	The font-type offsets point to entries relative to the 		*/
/*	font-table offsets.  The six font-type offsets correspond to    */
/*	the following font attributes:					*/
/*									*/
/*		single-high, single-wide characters			*/
/*		double-high, single-wide characters (top half)		*/
/*		double-high, single-wide characters (bottom half)	*/
/*		double-high, double-wide characters (top half)		*/
/*		double-high, double-wide characters (bottom half)	*/
/*		single-high, double-wide characters.			*/
/*									*/
/*	Thus, to find the index of a particular font in the table of	*/
/*	font names or id's, add the font-type offset to the font-table  */
/*	index.  For example, the index for a single-high, double-wide   */
/*	font is 11 (font-table offset = 6  +  font-type offset = 5).	*/
/*									*/
/************************************************************************/

/* Font-table offsets. */
/* NORMAL_OFFSET functions as both a font-type and a font-table offset. */
#define	NORMAL_OFFSET		0
#define	GRAPHICS_OFFSET 	6

/* Font-type offsets. */
#define	DHSWTOP_OFFSET		1
#define	DHSWBOT_OFFSET		2
#define	DHDWTOP_OFFSET		3
#define	DHDWBOT_OFFSET		4
#define	SHDW_OFFSET		5


/************************************************************************/
/*									*/
/*	Font Name Tables						*/
/*									*/
/************************************************************************/

extern	char	EMfont_name_80[12][64];
extern	char	EMfont_name_132[12][64];


#endif
