#include <stdio.h>
#include <fcntl.h>

#include "FImin.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

extern int SYM_dir_count;
extern char SYM_search_directory[100][300];

/*************************************************************************/
/*                                                                       */
/*             _FI_symbol_is_defined()                                   */
/*                                                                       */
/* Determine whether a symbol file has a symbol defined at a particular  */
/* index.  The caller should insure that the symbol file character array */
/* is valid before making this call.                                     */
/*                                                                       */
/*************************************************************************/

int _FI_symbol_is_defined (unsigned char * symbol_data,
                           unsigned char symbol_index)
{
   int index;

   index = 12 + symbol_index;

   if ((symbol_data [index]) || (index == 0))
      return (1);
   else
      return (0);
}

/*************************************************************************/
/*                                                                       */
/*               _FI_get_symbol_info()                                   */
/*                                                                       */
/* This function examines the symbol file and extracts information on    */
/* a particular index.  The bitmap is not read in this function, because */
/* Form builder may need to query the size of a symbol, and not want to  */
/* load the bitmap at that time.                                         */
/* The caller should insure that the symbol character array is valid     */
/*  before making this call.                                             */
/*                                                                       */
/***************************************************************************/

_FI_get_symbol_info ( unsigned char * symbol_data,
                      unsigned char symbol_index,
                      int * bitmapoffset,
                      unsigned char * bitmap_width,
                      unsigned char * bitmap_height,
                      unsigned char * xoff,
                      unsigned char * yoff,
                      unsigned char * cell_width,
                      unsigned char * cell_height)
{
   int symbol_slot, symbol_slot_start;
   int bitmapstart;
   int temp_int;

   bitmapstart = symbol_data [8] + (symbol_data [9] * 256);
   
   symbol_slot = symbol_data [12 + symbol_index];
   if ((symbol_slot != 0) || (symbol_index == 0))
   {
      symbol_slot_start = 260 + (symbol_slot * 8);

      temp_int =  bitmapstart + symbol_data [symbol_slot_start] + 
                                    (symbol_data [symbol_slot_start + 1] * 256);
      *bitmapoffset = temp_int + 8;

      *bitmap_width =  symbol_data [symbol_slot_start + 2];
      *bitmap_height = symbol_data [symbol_slot_start + 3];
      *xoff =          symbol_data [symbol_slot_start + 4];
      *yoff =          symbol_data [symbol_slot_start + 5];
      *cell_width =    symbol_data [symbol_slot_start + 6];
      *cell_height =   symbol_data [symbol_slot_start + 7];
   }
   else
   {
      *bitmapoffset =  bitmapstart;
      *bitmap_width =  0;
      *bitmap_height = 0;
      *xoff =          0;
      *yoff =          0;
      *cell_width =    0;
      *cell_height =   0;
   }
}

/*************************************************************************/
/*                                                                       */
/* Create_symbol_bitmap()                                                */
/*                                                                       */
/* This function creates a bitmap in the symbol's original size.  May    */
/* want to add scaling capability later to this function.                */
/* The caller should insure that the symbol character array is valid     */
/* before making this call.                                              */
/*                                                                       */
/*************************************************************************/

_FI_create_symbol_bitmap (unsigned char * symbol_data,
                          int bitmapoffset,
                          unsigned char bitmap_width,
                          unsigned char bitmap_height,
                          unsigned char ** bitmap)
{
   int bitmapsize;

   bitmapsize = (int)(((double)bitmap_width + 7.0) / 8.0) * (bitmap_height);
   bitmapsize += bitmapsize & 1;

   *bitmap = (unsigned char *) calloc (1, bitmapsize + 1);

   memcpy (*bitmap, &(symbol_data [bitmapoffset]), bitmapsize);
}

/*--------------------------------------------------------------------------*/

/**********************************************************************/
/*                                                                    */
/*  This function loads in the entire symbol file, and parses out     */
/*  information about the size and bitmap of each of the defined      */
/*  symbols.  The Pixmaps are not generated at this time.  They will  */
/*  be created upon demand.                                           */
/*                                                                    */
/**********************************************************************/
   /* 0 = success */


int _FI_load_symbol_file (char               *path,
                          struct _FI_sym_st  *symbol_data)
{
char storage [100000];
FILE *fp;
int data_file;
int num_bytes_read;
int x;

  if (!(fp = fopen (path, "r")))
     return (-1);      /* Could not open file */
   
  /*********************************************************************/
  /*                                                                   */
  /* Verify that the magic number is correct before loading the whole  */
  /* thing in.  GMD 5/24/91                                            */
  /*                                                                   */
  /*********************************************************************/

  if ( fread ( storage, 4, 1, fp ) == 0)
  {
     fclose (fp);
     return (-1);
  }

  if ((storage[0] != 'F') ||
      (storage[1] != 'O') ||
      (storage[2] != 'N') ||
      (storage[3] != 'T'))
  {
     fclose (fp);
     return (-1);
  }

  fclose (fp);

  data_file = open (path, O_RDONLY);
  
  num_bytes_read = read (data_file, storage, 100000);

  close (data_file);

  /*********************************************************************/
  /*                                                                   */
  /* Examine each symbol location.  If a symbol exists at that slot,   */
  /* then store the information about the symbol's size and generate   */
  /* a bitmap for that symbol.                                         */
  /*                                                                   */
  /*********************************************************************/

  for (x = 0; x < 256; x++)
  {
     if (_FI_symbol_is_defined ((unsigned char *)storage, 
								 (unsigned char) x))
     {
        int bitmapoffset;
        unsigned char bitmap_width, bitmap_height;
        unsigned char xoff, yoff;
        unsigned char cell_width, cell_height;
        char * bitmap;

        _FI_get_symbol_info ((unsigned char *)storage, 
							 (unsigned char) x, &bitmapoffset,
                             &bitmap_width, &bitmap_height, &xoff, &yoff,
                             &cell_width, &cell_height);

        symbol_data->sym_slot[x].sym_width = bitmap_width;
        symbol_data->sym_slot[x].sym_height = bitmap_height;
        symbol_data->sym_slot[x].xoff = xoff;
        symbol_data->sym_slot[x].yoff = yoff;
        symbol_data->sym_slot[x].total_width = cell_width;
        symbol_data->sym_slot[x].total_height = cell_height;

        _FI_create_symbol_bitmap ((unsigned char *)storage, bitmapoffset, 
                                  bitmap_width, bitmap_height, (unsigned char **)&bitmap);
        symbol_data->sym_slot[x].bitmap = bitmap;
     }
  }

  return (0);
}

