
#ifndef db_info_def
#define db_info_def

struct db_info
{
 int    	quantity;
 int    	serial_no;
 short  	s_catalog;	/* catalog's length */
 short		s_part_num;
 short		s_revision;
 short		s_usage;
};


struct ACdb_info
{
 int    quantity;
 int    serial_no;
 char  	catalog[15];	
 char	part_num[/*15*/64];
 char	revision[/*15*/64];
 char	usage[26];
};

struct ACobj_info
{ 
 struct GRid obj;
 int    serial_no;
};

struct ACobj_info_1
{ 
 struct GRid obj;
 int    serial_no;
 int    quantity;
};

#endif

