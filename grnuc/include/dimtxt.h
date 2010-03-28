
#ifndef dimtxt_include

#define dimtxt_include

struct DMfield_def
{
	char field_no;
	char flag;
	short start_char;
	short end_char;
};

struct DMtxt_str
{
	unsigned char *str;
	int length;
	int size;
};

#endif


