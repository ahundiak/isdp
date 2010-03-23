#define		MAGIC	0x544e4f46	/*Magic number that driver looks for*/
#define		NUM_CODES	256	/*max no. of codes/symbols per file*/


	 	  /*SYMBOL FILE FORMAT*/
/*\

	        15_____________________0
		|_  kernal's magic #  _|
		|______________________|
		|_  size of ROP data  _|
		|______________________|
		|_    bitmap offset   _|
		|______________________|
		|		       | \
		|	   .	       |  \
		|	   .	       |   \_____  256 char codes(256 bytes)
		|	   .           |   /
		|	  	       |  /
		|______________________| /
		|		       | \
		|	   .           |  \
		|          .           |   \_____  n char headers (n <= 256)
		|	   .	       |   /
		|	  	       |  /
		|______________________| /
		|		       | \
		|          .           |  \
		|          .	       |   \_____  m bitmaps (m <= n)
		|          .           |   /
		|	  	       |  /
		|______________________| /
		|		       |
		|		       |
		|	   .	       |
		|	   .	       |   <----  attribute structure(below)
		|	   .	       |
		|		       |
		|______________________|

\*/


struct	sym_fixed_hdr		/*fixed size portion of symbol file*/
{
	long	magic_no;		/*used by kernal for identification*/
	long	ROPsize;		/*size in bytes of ROP data following*/
	long	bmap_offset;		/*added to this addr to get to bmaps*/
};


struct	fixed_hdr	/*total fixed portion of symbol file*/
{
	struct	sym_fixed_hdr  fixed;
	char		  codes[256];
};

struct	char_hdr	/*format of a character header entry*/
{
	unsigned short	bmap_offset;	/*offset from start of bmaps*/
	unsigned char	rasterwidth;	/*bit map width in dits*/
	unsigned char	rasterheight;	/*bit map height in dits*/	
	char 	xoffset;	        /*offsets into bitmap def'n area*/
	char	yoffset;		/*for char bitmap origin*/
	unsigned char	charwidth;	/*char cell width */
	unsigned char	charheight;	/*char cel height */
};

