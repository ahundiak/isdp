#ifndef GLOBAL_H
#define GLOBAL_H

#if defined (XGL) || defined (IRIX)
typedef unsigned long  IBUF;
#else
typedef unsigned char  IBUF;
#endif

#if defined (CLIX)
#define	FALSE	0
#define TRUE	1
#endif

struct data_info
   {
   int		rle_type;
   int		xdits;
   int		ydits;
   };

struct	type2_colortable
   {
   unsigned short	index;
   unsigned short	red;
   unsigned short	green;
   unsigned short	blue;
   };

struct preview_info
   {
   struct WLinit_ret_val	init_ret;
   struct WLraster_data		image;
   struct data_info		data;
   struct type2_colortable	*ctbl2;

   WLuint16     screen_no;
   WLuint32     context_no;
   WLuint32	lwin_no;

   int          base_depth;
   int          hilite_used;
   int          separate_hilite;
   int		width, height;
   int		dfact;
   int		xpix, ypix;
   int		num_pixels;

   IBUF		*image_buffer;
  
   FILE		*fp;
   char         *filename;
   };

extern struct preview_info	preview;

#endif
