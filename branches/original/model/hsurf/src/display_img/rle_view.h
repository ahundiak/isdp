
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

#define	TRUE	1
#define FALSE	0

#define TYPE_09		0x0908
#define TYPE_10		0x000a
#define TYPE_15		0x000f
#define TYPE_25		0x0019
#define TYPE_26		0x001a
#define TYPE_27		0x001b
#define TYPE_29		0x001d
#define	TYPE_89		89<<8
#define DTM		8

#define TWO_BLOCKS	1024	/* Length of type 25 header */

struct image_info
	{
	int			rle_type;
	int			num_rows, num_cols;
	int			num_planes;
	int			vlt_size;
	int			data_type_modifier;
	short			scanable;
	unsigned char		*red, *green, *blue;
	long                    *index_buf;
	char			name[256];
	};
