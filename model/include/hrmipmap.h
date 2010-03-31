
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#include "HSfixedpt.h"

/*
 *  Stuff for the texture mipmaps
 *
 *  The MMinfo struct will be part of the attributes structure.  filename and mipmap will initially
 *  be initialized to NULL.  When an object is activated, its texture filename, (if there is one)
 *  will be loaded in filename (mipmap will rename NULL).
 *
 *  The MMinfo_list structure will represent a node in a link list of loaded texture maps.  The
 *  next field is the link to the next node in the list.  Since you will never remove a texture
 *  from the middle of the list, (always the top) there is no need for a previous link.  On Demand,
 *  memory is allocated for a texture mipmap, and stored in the mipmap field of the info struct,
 *  in the attribute structure.  The address of the MMinfo field of the attribute structure will be
 *  added to the MMinfo_list, link list.
 *
 *  Two global variables are defined, MMinfo_list_top and MMinfo_list_bottom.  MMinfo_list_top
 *  is used when removing an mipmap from the list, and when freeing the info structures at the
 *  end of a paint.  The MMinfo_list_bottom variable is used when adding a mipmap to the bottom
 *  of the list.
 */

/*
struct	MMinfo
	{
	int		count;
	int		orientation;
	int		mipmap_size;
	unsigned char	*filename;
	unsigned char	*mipmap;
	};
*/

struct	MMinfo_list
	{
	struct MMinfo_list	*next;
	struct HRtexture_list	*info;
	};

extern	struct MMinfo_list	*MMinfo_list_top;
extern	struct MMinfo_list	*MMinfo_list_bottom;
extern	int			MMtexture_memory_limit;
extern	int			MMtexture_memory_used;

struct	MMheader
	{
	int		total_layers;	
	int		from_zbuffer;
	};
	
struct  MMlayer
	{
	int		xdits, ydits;
	int		total_bytes;
	unsigned char	*adr;
	float		d;
	};
