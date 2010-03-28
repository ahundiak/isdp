/*****************************************************************************
 *  Name:                 FFstructs.h                                        *
 *                                                                           *
 *  Author:               Stan Williams                                      *
 *                                                                           *
 *  Creation Date:        22-DEC-86                                          *
 *                                                                           *
 *  Operating system(s):  Unic Sysv                                          *
 *                                                                           *
 *  Abstract:             FF standard include file for accessing             *
 *                        compressed outline fonts, format version 1.0.      *
 *                        This file contains global structures that are      *
 *                        used by the UNIX Font Service.                     *
 *                                                                           *
 *                                                                           *
 *  REVISION HISTORY:                                                        *
 *****************************************************************************/

/*
$Log: FFstructs.h,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:52  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:08  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:06  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:23  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:39  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:42:36  tim
 * COMMENT : added Log variable
 *
*/

#ifndef FFstructs_include
#define FFstructs_include

#ifndef bstypes_include
#include <bstypes.h>
#endif

#ifndef igr_include
#include <igr.h>
#endif

#ifndef gpipe_include
#include <gpipe.h>
#define gpipe_include
#endif

/*
 *  comp2_3.h:      Bitstream standard include file for accessing
 *                  compressed outline fonts, format version 2.3
 *
 *  19-NOV-85   Mike Yudis
 *  21-Dec-85   mby  Added 'layout_size' to cft_$font_hdr structure
 *  21-Jan-85   mby  Added wordspace value to cft_$font_hdr structure
 *  11-Nov-86   jsc  Added no curve simplification flag
 *   7-Jan-87   mby  Added customer number to cft_font_hdr structure --
 *  18-sep-87   sew  replaced ufix16, fix15, ufix32, and fix31 
 */                

#define CFT_FHSIZE  256     /* font header size in words, v2.4 */

typedef struct {
	         char   block_id[2];
	unsigned short  nr_data_wds,  /* number of 16-bit words              */
	                rec_size,     /* in 16-bit words                     */
	                nr_recs;      /* number of records                   */
	}   cft_block_hdr;            /* precedes all data blocks in font    */




typedef struct {
	         char  outl_fmt_nr[8];    /* "C2.3    " -- identifies font   */
                 char  src_font_id[4];    /* Bitstream outline font ID       */
	         short src_font_vrsn;     /* source font outline version num */
	         char  src_font_name[70], /* Bitstream outline name          */
	               mfg_date[10],      /* manufacturing date              */
	               layout_name[70];   /* layout name (from layout file)  */
        unsigned short layoutNumber;      /* character layout number         */
	         char  cpyrt_notice[74];  /* Bitstream copyright notice      */
	unsigned int   timestamp;         /* outline resolution units per em */
        unsigned short resl_per_em;       /* outline resolution units per em */
	unsigned short flag1,             /* font flags, 32 bits worth in two*/
	               flag2;             /*  16-bit words                   */
	         int   extent_x_min,      /* font-wide extents: min x        */
	               extent_x_max,      /*                    max x        */
	               extent_y_min,      /*                    min y        */
	               extent_y_max;      /*                    max y        */
	unsigned int   offs_kernprs,      /* offset to kern-pair data        */
	               offs_kerntrks,     /* offset to kern-track data       */
	               offsLigTable,      /* offset to ligature table        */
	               offs_chardir,      /* offset to character-direct data */
	               offs_outldata;     /* offset to outline data          */
	unsigned short layout_size;       /* as specified in layout file     */
	unsigned short wordspace_width;   /* width of wordspace in oru       */
	unsigned short cust_number;       /* Bitstream customer number       */
	         char  custNotice[100];   /* Intergraph legal statement      */
	unsigned short rev_number;        /* format version revision number  */
        unsigned int   userId;            /* Intergraph user id              */
        unsigned int   userData;          /* Intergraph user data            */
	         char  reserved[110];     /* reserver for future use         */
	} cft_font_hdr;                   /* general font information        */



typedef struct {
	unsigned short  char1,      /* position in char directory (0-65535)  */
	                char2;      /* position in char directory (0-65535)  */
	         short  adjustment; /* in outline resolution units           */
	}   cft_kern_pair_rec;      /* kerning pair record                   */



typedef struct {
	short   pointSize,
                trackAdj[4];
	}   cft_trk_kern_rec;       /* kerning track record                  */




typedef struct {
	         short set_width;    /* character set width in ORU's         */
	unsigned int   outline_offs; /* outline offset                       */
	unsigned short char_id;      /* 16-bit character ID                  */
	}  cft_chardir_rec;          /* character directory record           */



typedef struct {
	cft_block_hdr      finf_hd;      /* font info block header           */
	cft_font_hdr       fonthead;     /* general font information         */
	cft_block_hdr      knpr_hd;      /* kerning pair data block header   */
	cft_kern_pair_rec *knpr_dat;     /* ptr to kern pair records         */
	cft_block_hdr      kntrk_hd;     /* track kerning data block header  */
	cft_trk_kern_rec  *kntrk_dat;    /* ptr to track kern records        */
	cft_block_hdr      chdir_hd;     /* character directories block hdr  */
	cft_chardir_rec   *chdir_dat;    /* ptr to character directory recs  */
	cft_block_hdr      outl_hd;      /* cmpr'd outline data block header */
	unsigned short    *outl_dat;     /* ptr to compressed outline data   */
        unsigned int       num_bytes_outl; /*length in words of the outl buff*/
	} FF_outl_str;      /* compressed outline font structure */


typedef short Typepath[256];


typedef struct {
 	unsigned short	rec_type;
                 int	px;
                 int	py;
                 int	pbeta;
        } FF_outl_recs;


typedef struct {
	unsigned short char_id;
	unsigned short bits_id;
        } BitsChar;


typedef struct {
	unsigned short  bits_id;
        unsigned short  char_id;
	         short *char_name;
        } CharMap;

typedef struct {
	unsigned short  bits_id;
        unsigned short  char_id;
	         char  *char_name;
        } AdobeMap;


typedef struct  {
	char char_id;        /* successor */
	char lig_name[6];    /* ligature  */
	} LigTbl;            /* ligature sequence */


typedef struct {
        unsigned short char_id; /* case 'C'                         */
	short   width_x;        /* case 'W': character width in x   */
	short   width_y;        /* case 'W': character width in y   */
	char    char_name[20];  /* case 'N': PostScript char name   */
	short   xmin;           /* case 'B': char bounding box: llx */
	short   ymin;           /* case 'B': char bounding box: lly */
	short   xmax;           /* case 'B': char bounding box: urx */
	short   ymax;           /* case 'B': char bounding box: ury */
	LigTbl *ligs;           /* case 'L': ligature sequence      */
	} AdobeMetrics;


typedef struct {
	unsigned short	char_id;
                 char   char_name[20];
	         short	set_width;
	} Metrics;


typedef struct {
              short		  num_chars;
              int                 fixed_pitch;
              short               fontwide_space;
              Metrics            *char_metrics;
              short               num_pairs;
              cft_kern_pair_rec  *knpr_dat;
       } Device_metrics;


typedef struct {
	unsigned short  options,
			char_id;
	         short  set_width,
			A_width,
			C_width,
			ascender,
			descender,
			justification;
	unsigned int 	num_outlines,
			num_line_strings,
			num_shapes,
			num_arcs,
       			num_recs,
                        num_words;
		 int	x_min, y_min,
 			x_max, y_max;
	FF_outl_recs   *vect_elements;
	} Conv_table;


typedef struct ffbscv {
               int           Disp_attributes;
	       double        Xlo, Ylo, Zlo, Xhi, Yhi, Zhi,
                            *Matrix, *Inv_Matrix;
        struct IGRbsp_curve  Curve;
        struct ffbscv       *prev_bscv, *next_bscv;
        } FFbscv;


typedef struct ffview {
               int      View_attributes;
               int      GPwin_id;
               int      GPbuff_id;
               int      W_id;
               int      Metrics[80];
	       double   Rotate;
	       double   V_matrix[16];
	       double   V_tol;
	       double   V_Xlo;
	       double   V_Ylo;
	       double   V_Zlo;
	       double   V_Xhi;
	       double   V_Yhi;
	       double   V_Zhi;
	       double   V_trans_x;
	       double   V_trans_y;
	       double   W_matrix[16];
	       double   W_xy_ext;
	       double   W_z_ext;
	       double   W_tol;
	       double   W_Xlo;
	       double   W_Ylo;
	       double   W_Zlo;
	       double   W_Xhi;
	       double   W_Yhi;
	       double   W_Zhi;
	       double   W_trans_x;
	       double   W_trans_y;
	       double   W_scale;
               FFbscv  *FFcurves;
        struct ffview  *prev_view, *next_view;
        } FFview;



#endif /* endif FFstructs_include */
