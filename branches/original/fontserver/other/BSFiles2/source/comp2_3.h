
/*
 *  comp2_3.h:      Bitstream standard include file for accessing
 *                  compressed outline fonts, format version 2.3
 *
 *  19-NOV-85   Mike Yudis
 *  21-Dec-85   mby  Added 'layout_size' to cft_$font_hdr structure
 *  21-Jan-85   mby  Added wordspace value to cft_$font_hdr structure
 *  11-Nov-86   jsc  Added no curve simplification flag
 *   7-Jan-87   mby  Added customer number to cft_font_hdr structure --
 */                

#define CFT_FHSIZE  144     /* font header size in words, v2.4 */




typedef
struct
    {
    char    block_id[2];
    ufix16  nr_data_wds,            /* number of 16-bit words              */
            rec_size,               /* in 16-bit words                     */
            nr_recs;                /* number of records                   */
    }   cft_block_hdr;      /* precedes all data blocks in font */




typedef
struct
    {
    char    outl_fmt_nr[8];         /* "C2.3    " -- identifies comp font  */
    char    src_font_id[4];         /* Bitstream outline font ID           */
    fix15   src_font_vrsn;          /* source font outline version number  */
    char    src_font_name[70],      /* Bitstream outline name              */
            mfg_date[10],           /* manufacturing date                  */
            layout_name[70],        /* layout name (from layout file)      */
            cpyrt_notice[74];       /* Bitstream copyright notice          */
    ufix32  timestamp;              /* outline resolution units per em     */
    ufix16  resl_per_em;            /* outline resolution units per em     */
    ufix16  flag1,                  /* font flags, 32 bits worth in two    */
            flag2;                  /*  16-bit words                       */
    fix31   extent_x_min,           /* font-wide extents: min x            */
            extent_x_max,           /*                    max x            */
            extent_y_min,           /*                    min y            */
            extent_y_max;           /*                    max y            */
    ufix32  offs_kernprs,           /* offset to kern-pair data            */
            offs_kerntrks,          /* offset to kern-track data           */
            offs_chardir,           /* offset to character-directory data  */
            offs_outldata;          /* offset to outline data              */
    ufix16  layout_size;            /* as specified in layout file         */
    ufix16  wordspace_width;        /* width of wordspace in oru           */
    ufix16  cust_number;            /* Bitstream customer number           */
    ufix16  rev_number;             /* format version revision number      */
    }   cft_font_hdr;       /* general font information */

/* Font header flag word bits  */
#define F_REPCOD  0x1           /* flag1: bit 0 = 1 -> repeat coding set   */
#define F_X_EXTN  0x2           /*        bit 1 = 1 -> character x-extents */
#define F_Y_EXTN  0x4           /*        bit 2 = 1 -> character y-extents */
#define F_EXTPTS  0x8           /*     bit 3 = 1 -> extreme point addition */
#define F_KERNPR  0x10          /*        bit 4 = 1 -> kerning pair data   */
#define F_KTRCK1  0x20          /*        bit 5 = 1 -> kerning track 1     */
#define F_KTRCK2  0x40          /*        bit 6 = 1 -> kerning track 2     */
#define F_KTRCK3  0x80          /*        bit 7 = 1 -> kerning track 3     */
#define F_PLDATA  0x100         /*        bit 8 = 1 -> plaid data          */
#define F_HIERAR  0x200         /*        bit 9 = 1 -> hierarchy data      */
#define F_CHARID  0x400         /*        bit 10 = 1 -> char ID's          */
#define F_NCVSMP  0x800         /*   bit 11 = 1 -> no curve simplification */




typedef
struct
    {
    ufix16  char1,                  /* position in char directory (0-65535) */
            char2;                  /* position in char directory (0-65535) */
    fix15   adjustment;             /* in outline resolution units          */
    }   cft_kern_pair_rec;      /* kerning pair record */




typedef
struct
    {
    fix15   point_size,
            track_1_adj,            /* adjustment in + or -  1/100 of pts  */
            track_2_adj,            /* adjustment in + or -  1/100 of pts  */
            track_3_adj;            /* adjustment in + or -  1/100 of pts  */
    }   cft_trk_kern_rec;       /* kerning track record */




typedef
struct
    {
    fix15   set_width;              /* character set width in ORU's       */
    ufix32  outline_offs;           /* outline offset                     */
    ufix16  char_id;                /* 16-bit character ID                */
    }  cft_chardir_rec;     /* character directory record */




typedef struct
    {
    cft_block_hdr  finf_hd;         /* font info block header             */
    cft_font_hdr   fonthead;        /* general font information           */
    cft_block_hdr  knpr_hd;         /* kerning pair data block header     */
    cft_kern_pair_rec  *knpr_dat;   /* ptr to kern pair records           */
    cft_block_hdr  kntrk_hd;        /* track kerning data block header    */
    cft_trk_kern_rec  *kntrk_dat;   /* ptr to track kern records          */
    cft_block_hdr  chdir_hd;        /* character directories block hdr    */
    cft_chardir_rec   *chdir_dat;   /* ptr to character directory recs    */
    cft_block_hdr  outl_hd;         /* cmpr'd outline data block header   */
    ufix16 huge   *outl_dat;        /* ptr to compressed outline data     */
    }   cft_outl_str;      /* compressed outline font structure */



