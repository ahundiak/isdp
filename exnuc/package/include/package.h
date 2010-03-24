#ifndef _PACKAGE_D_INCLUDED
#define _PACKAGE_D_INCLUDED	1

#define ERROR(ARGS)		(fprintf ARGS, exit(1))
#define GET_IMAGE_NAME()	((Image=strrchr(argv[0],'/'))?++Image:(Image = argv[0]))

#define MAX_ROW_LEN	256
#define MAX_NUM_COL	24

char	*Image;
void	print_usage();

#endif
