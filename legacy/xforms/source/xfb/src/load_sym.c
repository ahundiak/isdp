/***********************************

		 load_sym.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/


#include <stdio.h>

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


extern int SYM_dir_count;
extern char SYM_search_directory[200][256];

/* Defined by Intergraph symbol file format */

static struct FI_symbtabstruct
{
  int magic;
  int size;
  int bitmapoffset;
  unsigned char headind[255];
};

/* Defined by Intergraph symbol file format */

/* sml:05-11-92	typedef not needed */
/*typedef*/ struct FI_headerstruct
{
  unsigned short bitoff; /* offset of bitmap within bitmap table */
  unsigned char rw, rh; /* bitmap width and height */
  unsigned char xoff, yoff; /* offset of bitmap within symbol cell */
  unsigned char sw, sh; /* total cell height and width */
};


/********************************************************/
/* Load into memory a symbol so that it may be scaled. */
/********************************************************/
int load_sym_bitmap (char *symbol_file,
                     int sym_index,
                     char **bitmap,
                     int *width,
                     int *height)
{
  int bitmapsize;
  struct FI_headerstruct header;
  struct FI_symbtabstruct symbol_table;
  FILE *fp;
  int file_found, x;
  char full_path[2000];

  file_found = 0;

  if (fp = fopen (symbol_file, "r")) /* Check current directory first */
  {
    file_found = 1;
  }
  else
  {
    for (x = 0; x < SYM_dir_count; x++)
    {
      strcpy (full_path, &(SYM_search_directory[x][0]));
      strcat (full_path, "/");
      strcat (full_path, symbol_file);

      if (fp = fopen (full_path, "r"))
      {
        file_found = 1;
        x = 4000;
      }
    }
  }

  if (file_found == 0)
  {
    return 1;
  }

  /* read in the symbol file header */
  if (fread (&symbol_table, sizeof(struct FI_symbtabstruct), 1, fp) == 0)
  {
    fclose (fp);
    return 1;
  }

  /*** make sure the symbol index is valid ***/
  if (! symbol_table.headind[sym_index])
  {
    fclose (fp);
    return 1;
  }

  /* skip to the header for symbol_no */
  if (fseek (fp, symbol_table.headind[sym_index] * 8 + 260, 0))
  {
    fclose (fp);
    return 1;
  }

  /* read in the header for that symbol */
  if (fread (&header, sizeof(struct FI_headerstruct), 1, fp) == 0)
  {
    fclose (fp);
    return 1;
  }

  /* skip to the beginning of the bitmap for that symbol */
  if (fseek (fp, symbol_table.bitmapoffset + header.bitoff + 8, 0))
  {
    fclose (fp);
    return 1;
  }

  /* CHUNN don't load the bitmap in until needed */

  /* get some memory for the bitmap for the symbol */

  bitmapsize = ((int)(header.rw + 7) / 8) * header.rh;
  bitmapsize += bitmapsize & 1;

  *bitmap = NULL;
  *bitmap = (char *) calloc (1, bitmapsize + 1);

  if (! *bitmap)
  {
    fclose (fp);
    return 1;
  }
  /* read in the bit map for that symbol */

  if (fread (*bitmap, bitmapsize, 1, fp) == 0)
  {
    fclose (fp);
    return 1;
  }

  /*
symbol_ptr->total_width = header.sw;
symbol_ptr->total_height = header.sh;
symbol_ptr->sym_width = header.rw;
symbol_ptr->sym_height = header.rh;
symbol_ptr->xoff = header.xoff;
symbol_ptr->yoff = header.yoff;
*/
  *width = header.rw;
  *height = header.rh;

  fclose (fp);

  return (0); /* success */
}
