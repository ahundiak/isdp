/*
	Name:			OMlimits.h
	Author:			Chuck Puckett
	Creation Date:		jul-5-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	 This module contains compile time limits for OM. These typically
	 include array limits and character string length limits.

	Revision History:

cgp001	14-oct-1985	Reserve 32 metaclasses. Add some new limits for OS
			names.

cgp002	24-oct-1985	Add maximum channel send depth and collapse counts.

cgp003	11-nov-1985	Reserve 32 meta relations. Add OS name length.

gja001	18-mar-1986	Add parameters for mallox(3x) usage.

kek001  23-mar-1986     remove OM_K_MAXMINCHAN_NUMBER

geo001  07-may-1986	Remove mallox(3x) runtime parameters;
			Move to OMparameters.h
geo002  11-nov-1986	add max swap files names'length
geo003  18-feb-1987	add cache size used by channel send and group pass
geo004  23-jul-1987	remove max envfilename length
geo005	23-nov-1987	remove clustername size, add max clusternum
*/


#ifndef	OM_D_LIMITS
#define	OM_D_LIMITS	1

#define	OM_K_MAXMETH_LEN	32	/* Maximum method name length */
#define	OM_K_MAXARG_LEN		32	/* Maximum argument name length */
#define OM_K_MAXMETH_ARGS	8	/* no more than 8 arguments */
#define	OM_K_MAXCLASS_LEN	32	/* Maximum class name length */
#define OM_K_MAXPROD_LEN        16	/* Max length of a product name */
#define OM_K_NUM_META_CLASSES	64	/* number of predefined classes */
#define OM_K_MAXPARENTS		256	/* maximum number of ancestors */
#define OM_K_MAXCHANNEL_LEN	32	/* max. size of a channel name */
#define OM_K_MAXCHANNAME_LEN    65      /* max. size of channame string */
#define OM_K_MAXINTOSNAME_LEN	32	/* max size of internal OS name */
#define OM_K_MAXOSNAME_LEN 	128	/* max length of OS name */
#define OM_K_MAXGROUPNAME_LEN	128	/* max length of Group name */
#define	OM_K_MAXCLUSTER_NUM	0x7fff	/* max logical cluster number */
#define OM_K_MAXCHANSEND	65535	/* MAX CHANNEL send depth */
#define OM_K_MAXCHANCOLLAPSE	65535	/* max. chan. collapse count */
#define OM_K_MAXMAJCHAN_NUMBER	255	/* maximum major channel number */
#define OM_K_MAXOBJ_SIZE	0x7fffffff /* max object size */
#define OM_K_MINOBJS_COUNT	2       /* min number of objects in an os */
#define OM_K_MINOS_SIZE		1024    /* min size of an os	*/
#define OM_K_MAXOS_SIZE		0x7fffffff /* max object space size */
#define OM_K_MAXCONNAME_LEN     32      /* max symbolic connect name length */
#define OM_K_MAX_SWAP_PARTITION_LEN	132
				     /* max name length for swap partitions */
#define OM_K_CACHE_SIZE		32	/* size of channel send cache */
#define OM_K_CLASS_HASH_MAX     1021     /* max for classname hash */
#define OM_K_GLOBALDATA_BASEADDR 0xc0c00000 /* global shared mem base addr */
#define	OM_K_GLOBALDATA_SIZE	16*1024	/* estimated size of global data reg */
#define OM_K_SHM_MALLOC_SIZE	0x20000 /* malloc shared mem segment size */

#define MAXNAMSIZE		134	/* Used in sequential pass for Btree */
#define OM_K_BIGCHAN_LIMIT      65535   /* crossover limit for big chans */

#define MAXNUMAPPVER		128

#endif
