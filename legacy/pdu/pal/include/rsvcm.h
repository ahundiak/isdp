#ifndef rsvcm_include

#define rsvcm_include

#define RSVC_MAX_LAYERS 16
#define RSVC_MAX_NAME	32

/*
 *  Types.
 */

#define RSVC_RGB    0
#define RSVC_CMYK   1
#define RSVC_CUSTOM 2

/*
 *  Flags.
 */

/*
 * Trans flags
 */

#define C_TRANSPARENT   0x00000001
#define M_TRANSPARENT   0x00000002
#define Y_TRANSPARENT   0x00000004
#define K_TRANSPARENT   0x00000008


#define RSVC_OVERPRINT 0x01


struct RSvc_entry
{
	char     unsigned type;
	char     unsigned flags;
	short    unsigned rgb[3];
	short    unsigned c[4];
        char     unsigned spot[12];
        int               trans_flag;
        int               res1;
        int               res2;
	char              name[RSVC_MAX_NAME];
};

#endif
