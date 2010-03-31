
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsanimate_include
#define hsanimate_include 1

#define TIMING                    0
#define DBUG                      0
#define ABS(x)                    (((x) < 0) ? -(x) : (x))

#define MAX_FILES                 200
#define HS_DSPLIMG_TILER_RESERVE  2097152   /* 2 Meg. */
#define GS                        0
#define GXGZ                      1


#define DEBUG_CTBL   0
#define EMS          0
#define TYPE_09      0x0908
#define TYPE_10      0x000a
#define TYPE_15      0x000f
#define TYPE_25      0x0019
#define TYPE_26      0x001a
#define TYPE_27      0x001b
#define TYPE_89      89<<8
#define DTM          8

/* Scanline orientation codes */
#define UPPER_LEFT_VERTICAL     0
#define UPPER_RIGHT_VERTICAL    1
#define LOWER_LEFT_VERTICAL     2
#define LOWER_RIGHT_VERTICAL    3
#define UPPER_LEFT_HORIZONTAL   4
#define UPPER_RIGHT_HORIZONTAL  5
#define LOWER_LEFT_HORIZONTAL   6
#define LOWER_RIGHT_HORIZONTAL  7

#define TWO_BLOCKS   1024   /* Length of type 25 header */

struct HEADER_BLOCK
{
   unsigned short        header_type_code;
   unsigned short        wds_to_follow;
   unsigned short        data_type_code;
   unsigned short        app_type_code;

   double                view_origin_x;
   double                view_origin_y;
   double                view_origin_z;

   double                view_extent_x;
   double                view_extent_y;
   double                view_extent_z;

   double                transformation[16];

   unsigned int          num_cols;
   unsigned int          num_rows;

   short                 device_resolution;

   unsigned char         scanline_orient;   /* bits 0-2   */
   unsigned char         scannable_flag;    /* bit 0   */

   unsigned int          rotation_angle[2]; /* double */
   unsigned int          skew_angle[2];     /* double */

   unsigned short        data_type_modifier;

   char                  design_filename[66];
   char                  dbase_filename[66];
   char                  parent_gridfile[66];
   char                  file_descript[80];

/*
   union
   {
         unsigned char   min1;
         unsigned short  min2;
         unsigned int    min4;
         float           minR;
         double          min8;
   }                     min_value;

   union
   {
         unsigned char   max1;
         unsigned short  max2;
         unsigned int    max4;
         float           maxR;
         double          max8;
   }                     max_value;
*/

   char                  min_value[8];
   char                  max_value[8];

   char                  reserved1[3];
   unsigned char         gridfile_version;   /* latest = 2   */


   unsigned char         gain;   /* start of block 2 */
   unsigned char         offset;
   unsigned char         vwfull_scr1;
   unsigned char         vwfull_scr2;
   unsigned char         view_number;

   unsigned char         reserved2;
   unsigned short        reserved3;

   double                aspect_ratio;

   unsigned int          concat_file_ptr;

   unsigned short        color_table_type;
   unsigned short        reserved4;

   unsigned int          num_ctbl_entries;
   unsigned int          app_packet_pointer;
   unsigned int          app_packet_length;

   unsigned short        reserved5[110]; /* reserved5[105] holds number of
                                            planes used for color on the
                                            machine that the file was saved on
                                          */
   unsigned char         ctbl[256][3];
} ;

struct TYPE_89_HEADER
{
   short   level_type;
   short   wtf;
   short   row;
   short   col;
};

struct RLE_RECORD
{
   short   color_shade;
   short  run_length;
};


struct raster_header
{
   unsigned short          element_type;
   unsigned short          wtf;
   unsigned short          data_type;
   unsigned short          app_type;
   unsigned short          hold[252];
   unsigned short          hold2[118];
   unsigned short          vlt_size;
   unsigned short          colors;
   unsigned short          shades;
   unsigned short          color_bits;
   unsigned short          len_bits;
   unsigned short          planes;
   unsigned short          height;
   unsigned short          width;
   unsigned short          x_off;
   unsigned short          y_off;
   char                    color_table[256];
};

struct rle_header
{
   unsigned short element_type;
   unsigned short wtf;
};

struct rle_info
{
   unsigned short column;
   unsigned short row;
   unsigned short color_n_len[1184];
};


struct frame
{
   short format;
   short mask;
   short planes;

   short x_min;      /* Upper left corner of display of recalled image */
   short y_min;

   short vlt_size;

   short num_rows;      /* Number of rows/columns of image in rle file */
   short num_cols;

   short x_max;      /* Lower right corner of display of recalled image */
   short y_max;

   short trans;
};

#endif
