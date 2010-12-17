#ifndef NFMqlu_h

#define NFMqlu_h

/*
	       File Format

	-------------------------
	|      File Header	|
	|-----------------------|
	|     Table Header 1	|
	|-----------------------|
	|        Table 1	|
	|-----------------------|
	|     Search Tree 1     |
	|-----------------------|
	.			.
	.			.
	.			.
	|-----------------------|
	|     Table Header N	|
	|-----------------------|
	|        Table N	|
	|-----------------------|
	|     Search Tree N     |
	|-----------------------|
	|      String Table 	|
	-------------------------

*/

#define NUM_OF_DTYPE( N, DTYPE_SIZE) \
	 ( ((N) + (DTYPE_SIZE) - 1)/(DTYPE_SIZE) )

#define ALIGN( N, ALIGN_SIZE ) \
	 ( NUM_OF_DTYPE( N, ALIGN_SIZE ) * (ALIGN_SIZE) )

#define ALIGN_INT(N) ALIGN( N, sizeof(int) )
#define ALIGN_DOUBLE(N) ALIGN( N, sizeof(double) )


typedef enum dataType {  NFMdouble, 
			 NFMreal, 
			 NFMinteger, 
			 NFMsmallint, 
			 NFMchar }   NFMqlu_dType;

typedef struct searchNode {
  unsigned short	left;
  unsigned short	right;

	/*  Assume that table is sorted on "key".  Count represents the 
	 *  number of consecutive rows with the same key.
	 */

  unsigned short	count;  

  union {
	double	d;
	float	f;
	int	i;
	short	s;
	int	ch;	/* Offset from start of table to string */
  } key;

} NFMqlu_node;


typedef struct fileHeader {

  char		magic[16];

#define	MAGIC	"!~NFMqlu~/\0"

  int		version;
  short		tableCnt;
  int		stringTabOff;	/* offset to beginning of string table */
  int		stringTabSize;  /* size of string table in integers.  Until */
				/*   written to the file, it will contain */
				/*   a ptr to the string table buffer */
} NFMqlu_fHdr;
  

typedef struct fileDescr {

  int		descr;
  NFMqlu_fHdr	*hdr;
  int		*stringTab;

} NFMqlu_fDescr;


typedef struct tableHeader {

  int			  nodeOff;	/* Offset to first node (relative to 
					   the file.  Will be the root node. */
  int			  nodeCnt;	/* Number of nodes in tree */
  NFMqlu_dType		  nodeType;	/* Data type represented in node */
  short			  levels;	/* # of levels within search tree */
  short			  nameOff;	/* relative to String Table */
  int			  tableOff;	/* Offset to table within file */
  int			  dataOff;	/* Offset to data within table */
  int			  rowCnt;	/* Number of rows in table */
  int			  rowSize;	/* Size  of rows in table */
  int			  colCnt;	/* Number of columns in each row */

} NFMqlu_tHdr;


typedef struct tableDescriptor {
  
  NFMqlu_fDescr *fdescr;	/* pointer to associated file descriptor */
  NFMqlu_tHdr	*hdr;
  NFMqlu_node	*nodeBuff;	/* first node is the root node */
  int		nextAvailNode;  /* next available node for allocation */
  char		*lastKey;	/* last key returned in walk through */
  int		*levelArray;	/* records last node encountered at each level*/
  MEMptr	memBuff;	/* ptr to NFM memory management structure */
  
} NFMqlu_tDescr;


#endif
