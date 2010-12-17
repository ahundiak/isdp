#define FILE_LEN	128

struct xref_st
{
	char	name[FILE_LEN];
};

/* Function prototypes */
long GetXrefs(char infile[], long *num_xrefs, struct xref_st **xrefs );


