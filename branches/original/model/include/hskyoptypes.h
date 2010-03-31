
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hskyoptypes_include
#define hskyoptypes_include 1

/* definitions of options for commands without forms */

struct bs_tree {
	char		*option;
	unsigned int	idn;
	};
	
struct option_set {
	unsigned int	size;
	struct bs_tree	*bstree_ptr;
	};
#endif
