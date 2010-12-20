#define ARCHIVE 0
#define BACKUP  1
#define RESTORE 2
#define DELETE  3

struct NFMflag_node_st
  {
	char	catalog_name[20];
	char	catalog_no[20];
	char	item_no[20];
	char	ctype[2];
	struct	NFMflag_node_st *child;
	struct	NFMflag_node_st *sibling;
  };

char  A_CATNO[21];
char  A_CATNAME[21];
