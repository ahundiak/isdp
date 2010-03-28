




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                                < 1988 >

              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.


                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.


              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201

 */

/* cmd_struct.h */

/* ------- EMS plotting metafile command structures ------------------------- */

#ifndef CMD_STRUCT_DOT_H
#define CMD_STRUCT_DOT_H

/* ------- dependencies:*/
/*   ems_plot_typ.h	*/

/* ------- for surfaces: */
#include <igrtypedef.h>
#include <igr.h>


struct metafile_header
{
  char		file_type [2];	/* type identifier for I/EMS metafile */
  uint16	version;	/* metafile version number */
  double	world_to_meters;/* factor to convert from world to meters */
  char		master [81];	/* parent or master file name */
  char		comment [81];	/* file description */
};

/* ------- basic set-up commands */

struct set_line_style_table
{
  uint16	  num_entries;	/* number of entries in the line style table */
  uint16	* num_runs;	/* pointer to array of on/off sizes */
  double	* runs;		/* pointer to array of on/off runs */
};

struct create_a_font
{
  uint16	  font_num;	/* number used to specify the font */
  char		* typeface;	/* name of typeface file, null terminated */
  double	  height;	/* height of font */
  double	  aspect;	/* aspect ratio */
  double	  rotation;	/* counter-clockwise rotation angle, degrees */
  double	  slant;	/* counter-clockwise slant angle, degrees */
  uint16	  mapping;	/* character code mapping */
  uint8		  temp;		/* 0 = normal, 1 = from temp file */
};

struct read_a_font
{
  uint16	  font_num;	/* number used to specify the font */
  char		* filename;	/* name of font file, null terminated */
};

struct light_source
{
  double	coordinates [3];	/* coordinates of light source */
  uint8		intensity;		/* light source brightness:  0%-100% */
};

struct define_binary_fill_pattern
{
  uint16	  pattern_num;	/* number used to specify the fill pattern */
  uint16	  bits_per_row;	/* the number of bits per fill pattern row */
  uint16	  num_rows;	/* the number of rows in the fill pattern */
  uint8		* pattern;	/* pointer to array of pattern bits */
};

struct set_character_code_mapping
{
  uint16	  mapping;	/* mapping identifier */
  uint16	  missing_char;	/* char to use if a char is not known to map */
  uint16	  flags;	/* 16-bit, ... */
  uint16	  num_pairs;	/* number of pairs in map */
  uint16	* pairs;	/* input/output char pairs */
};

struct set_view_orientation_range
{
  double	matrix [16];	/* 4x4 view orientation matrix */
  double	range [6];	/* diagonal of viewport, (xyz0-xyz1) */
  uint8		view_number;	/* view identification number */
};

struct raster_orientation
{
  double	origin [3];		/* 3D origin */
  double	rotation;		/* rotation angle in degrees */
  double	x_scale;		/* x scale factor */
  double	y_scale;		/* y scale factor */
};

/* ------- 3d drawing primitive commands */
/* draw line_string or polygon -- points array */

/* draw_nurb_curve -- use struct IGRbsp_curve -- see igr.h */

struct draw_text_string
{
  double	  origin [3];	/* x,y,z of origin */
  double	  direction [3];/* dx,dy,dz of direction vector, if dependent */
  double	  up [3];	/* dx,dy,dz of up vector, if dependent */
  uint32	  num_chars;	/* number of characters in text string */
  char		* string;	/* pointer to array of characters, no null */
  uint8		  type;		/* type: dependent, abbreviated dep., indep. */
};

struct draw_planar_raster_image
{
  int		  raster_type;	/* type of raster from header */
  uint8		* block1;	/* pointer to header block 1 */
  uint8		* block2;	/* pointer to header block 2 */
  uint16	* color_table;	/* header color table in environ-v format */
  uint8		* raster_data;	/* the data */
  int		  rdata_size;	/* total size of raster data */
};

struct draw_nurb_surface
{
  struct IGRbsp_surface	  surface;	/* the surface definition */
  struct IGRbsp_curve	* bdry_curves;	/* ptr to boundaries as nurb curves */
  int			  curves_size;	/* size of boundary curves buffer */
};

struct draw_rectangular_element
{
  double	origin [3];	/* the origin (first diagonal point) */
  double	diagonal [3];	/* the other diagonal point */
  double	direction [3];	/* direction vector, relative to the origin */
  double	angle [2];	/* start, arc angles in degrees for arc/wedge */
};

struct draw_reference_file
{
  double	* matrix;	/* 4x4 transformation matrix [16] */
  double	* range;	/* diagonal of clipping box [6], (xyz0-xyz1) */
  char		* filename;	/* name of reference file, null terminated */
};

#endif
