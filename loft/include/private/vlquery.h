#ifndef vlquery_include
#define vlquery_include

/* Store list for range locate */
struct VLqList {
        	IGRint          count;
        	IGRint          max;
        	IGRint          incre;
        struct 	GRobj_env	*list;
};

/* Accumulated list for query in Struct history	*/
struct	VLlistElmtId
{ 
	int *pCount; 
	struct GRid **pList; 
};

#endif
