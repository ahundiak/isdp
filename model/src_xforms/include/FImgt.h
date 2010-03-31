#ifndef FImgt_included
#define FImgt_included	1



struct slot
{
  unsigned char	  sym_width;
  unsigned char	  sym_height;
  unsigned char	  xoff;
  unsigned char	  yoff;
  unsigned char	  total_width;
  unsigned char	  total_height;
  char		* bitmap;
  Pixmap	  pixmap[8];   /* GMD 3/9/92  One for each possible screen */
};


struct _FI_sym_st
{
  char		* path;
  char		  symbol_file [15];
  struct slot	  sym_slot[256]; 
};


struct _FI_font_st
{
  char * fontname;
  int    bodysize;
  int	 font_type;
  Font   font_id;
};

#endif
