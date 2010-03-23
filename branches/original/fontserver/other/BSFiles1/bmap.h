/* typedefs for Bitstream Standard Bitmap Format, version B1.0, July 1984  */
/* NOTE CHANGE:  1-16-85 added "layout" bytes to reserved data section     */
/* NOTE CHANGE:  This is now version B1.1 (length of bitmap is now fix31)  */
/* NOTE CHANGE:  4-16-85 changed "layout" bytes to be 4-character string   */

/* NOTE CHANGES: 5-17-85 CHANGES TO RESERVED AND UNUSED ELEMENTS:          */
/*                       changed name: layout[4] to layout_id[4]           */
/*                       restored fix15 layout as layout_seq               */
/*                       added bmap_rev, bmap_seq, time_stamp              */
/*                       added parent bitmap font to bmap name             */
/*                       (include parent name after null character)        */
/*                       GENERALLY CHANGED NAMES OF EVERYTHING IN HEADER   */

typedef
struct bmap_hdr_tag
     {
     chr8      fmt_versn[4];       /* (  1 -   4) tape format version */
     chr8      outl_id[4];         /* (  5 -   8) outline font id */
     chr8      outl_name[70];      /* (  9 -  78) outline font name */
     chr8      mfg_date[10];       /* ( 79 -  88) manufacturing date "dd mmm yy" */
     chr8      bmap_name[70];      /* ( 89 - 158) bitmap font name (including parent bitmap font name) */
     fix15     outl_rev;           /* (159 - 160) outline font revision number */
     fix31     start_gen_sec;      /* (161 - 164) offset to start of general font information, in bytes */
     fix15     bytes_gen_sec;      /* (165 - 166) length of general font information section, in bytes */
     fix31     start_kern_sec;     /* (167 - 170) offset to start of kerning pair section, in bytes */
     fix15     bytes_kern_rec;     /* (171 - 172) length of kerning pair records, in bytes */
     fix15     nbr_kern_rec;       /* (173 - 174) number of kerning pair records */
     fix31     start_dir_sec;      /* (175 - 178) offset to start of character directory, in bytes */
     fix15     bytes_dir_rec;      /* (179 - 180) length of directory records, in bytes */
     fix15     nbr_dir_rec;        /* (181 - 182) number of directory records */
     fix31     start_map_sec;      /* (183 - 186) offset to start of bitmap section, in bytes */
     fix31     bytes_map_sec;      /* (187 - 190) length of bitmap section, in bytes */
     chr8      layout_id[4];       /* (190 - 194) Bitstream reserved: font id whose layout is the same as this font */
     fix15     layout_seq;         /* (195 - 196) Bitstream reserved: 1 or 256 = Bitstream New Master Layout */
     fix15     bmap_rev;           /* (197 - 198) Bitstream reserved: bitmap revision number */
     fix15     bmap_seq;           /* (199 - 200) Bitstream reserved: bitmap sequence number */
     fix31     time_stamp;         /* (201 - 204) Bitstream reserved: apollo time stamp */
     chr8      empty1[18];         /* (205 - 222) Bitstream reserved: for future use */
     chr8      copyrt[34];         /* (223 - 256) copyright data */
     }
     bmap_hdr_type;




typedef     
struct bmap_gen_tag
     {
     fix15     em_res;        /* em_resolution: lines per em */
     fix15     below;         /* number of lines below baseline */
     fix15     blink_wid;     /* blinker width, screen cursor */
     fix15     blink_hgt;     /* blinker height,screen cursor */
     fix15     space_wid;     /* set width of space character */
     fix15     track[4];      /* overall kerning for tracks 1,2,3,4 */
     fix15     pt_size;       /* point size, in tenths of points */
     fix15     vert_res;      /* vertical resolution, in pixels/inch */
     fix15     horiz_res;     /* horizontal resolution, in pixels/inch */
     }
     bmap_gen_type;
     
typedef
struct bmap_pair_tag
     {
     fix15     c1,            /* bs_nbr for character 1 */
               c2,            /* bs_nbr for character 2 */
               kern;          /* kerning value  (+ = morespace, - = less space */
     }
     bmap_pair_type;

typedef
struct bmap_cdir_tag
     {
     fix15     bs_nbr,        /* Bitstream bitmap character number */
               alt,           /* alternate version level */
               h_off,         /* horizontal offset from origin of em-square */
               v_off,         /* vertical offset from origin of em-square */
               r_wid,         /* raster-width, in pixels, of bitmap */
               r_hgt,         /* raster-height, in pixels, of bitmap */
               set_wid;       /* set-width, in pixels, of character */
     fix31     s_map;         /* offset to start of bitmap, in bytes, from beginning of bitmap section */
     fix15     n_map,         /* number of bytes in character bitmap */
               flags;         /* flags, see below */
     }
     bmap_cdir_type;




typedef
struct xref_key_tag
     {
     fix15     bs_nbr;        /* Bitstream bitmap character number */
     fix15     bs_alt;        /* Bitstream bitmap alternate version level */
     fix15     key1;          /* Customer character set */
     fix15     key2;          /* Customer character number */
     }
     xref_key_type;

typedef
struct xref_link_tag
     {
     struct xref_key_tag      data;     /* note: actual data, not pointer */
     struct xref_link_tag     *next;
     }
     xref_link_type;



/* structures for dynamic management of font structures */

typedef
struct bmap_pair_node_tag
     {
     struct bmap_pair_tag          data;
     struct bmap_pair_node_tag     *next;
     }
     bmap_pair_node_type;

typedef bmap_pair_node_type *bmap_pair_desc_t; 

typedef
struct bmap_char_node_tag
     {
     struct bmap_cdir_tag          *data;
     bit8                          *bits;
     struct bmap_char_node_tag     *next;
     }
     bmap_char_node_type;

typedef bmap_char_node_type *bmap_char_desc_t; 

typedef
struct bmap_font_node_tag
     {
     bmap_hdr_type                 *hdr;
     bmap_gen_type                 *gen;
     bmap_pair_node_type           *head_pair;
     bmap_pair_node_type           *curr_pair;
     bmap_char_node_type           *head_ch;
     bmap_char_node_type           *curr_ch;
     }
     bmap_font_node_type; 

typedef bmap_font_node_type *bmap_font_desc_t; 



/*
     the flag: bit 0 (1): 0 = run-length encoded,  1 = map encoded
               bit 1 (2): 0 = unsigned 8-bit runs, 1 = signed 16-bit runs
               bit 2 (4): nothing yet....
*/    

#define REAL_BITMAP      0x1
#define RUNLENGTH_8      0x0
#define RUNLENGTH_16     0x2
#define USED_FLAG_BITS   0x3

/* 
bmap_parent_name can be included in bmap_name in the following way:

"bmap_name\0parent_bmap_name\0"

bmap_name is null-terminated, and takes far less than 70 characters,
in fact usually less than 35 characters, so there is room for two names.
bmap_parent_name can start immediately following the null character
of bmap_name, and can also be null terminated.
A "C" program using a printf statement to display the string at
hdr.bmap_name would display only the first name, and only a program
which was specifically looking for another name after the first one would
be able to display the parent name.
*/
