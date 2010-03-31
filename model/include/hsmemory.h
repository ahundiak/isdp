
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsmemory_include
#define hsmemory_include 1

/*
 *  This structure defines what we need for hsurf zbuffer
 *  memory management.  A 'z' is prefixed to malloc, realloc
 *  and free in case we later add support for other hsurf
 *  memory usages
 */


struct	chunk_info_struct
	{
	IGRint				num_bytes;
	HSzbuf				*address;
	struct HS_window_parms		*active_pipe;
	};


struct	memory_info_struct
	{
	IGRint				vs_no;
	IGRint				bytes_remaining;
	HSzbuf				*(*zmalloc)();
	HSzbuf				*(*zrealloc)();
	void				(*zfree)();

	HSzbuf				*last_buffer;
	IGRint				last_buffer_size;
	
	IGRint				num_chunks;
	struct chunk_info_struct	chunk_info[MAX_WINDOW];
	};

extern struct memory_info_struct	memory_info[8];

#endif
