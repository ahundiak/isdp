#ifndef	UMSpriv_include
#define	UMSpriv_include


/***************************/
/** Initialization Macros **/
/***************************/

#define	UMS_INDEX_BIT	0x1
#define	UMS_KEY_BIT	0x2
#define	UMS_MSG_BIT	0x4
#define	UMS_KEY2_BIT	0x8


/*******************/
/** Memory Macros **/
/*******************/

#define	UMS_MEM_COMP_LEN	10
#define	UMS_MEM_EXT_LEN		33
#define	UMS_MEM_KEY2_LEN	33


/***********************/
/** Memory Structures **/
/***********************/

typedef	struct
{
	long	msgNum;
	long	textPtr;
} UMSNumIndex;

typedef	struct
{
	short		baseNo;
	char		comp[UMS_MEM_COMP_LEN];
	long		numMsg;
	long		textBufLen;
	long		extBufLen;
	long		key2BufLen;
	UMSNumIndex	*nidx;
	long		*kidx;
	char		*text;
	char		*k1ext;
	char		*k2lst;
	char		*next;
	char		msgFile[1];
} UMSHeader;


/*****************/
/** Global Data **/
/*****************/

extern	UMSHeader	*UMSFileList;


#endif
