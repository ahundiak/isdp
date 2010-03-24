#ifndef INFO_D_INCLUDED
#define INFO_D_INCLUDED 1

#include "ddp_defns.h"

struct class_info
{
   unsigned int		instance_size;
   unsigned short	major_version_num;
   unsigned short	minor_version_num;
   unsigned short	dynamic_flag;
   struct class_info	*next;
   char 		sequence_num[3];
};

struct chantype_info
{
   char 		type_name[MAX_SIZE];
   int			initial_size;
   int			increment_size;
   int			size;
   unsigned short	channel_flags;
};

struct channel_info
{
   char 		channel_name[MAX_SIZE];
   char			type_name[MAX_SIZE];
   unsigned short	channel_flags;
   int			initial_size;
   int			increment_size;
   int			offset;
   int			size;
};

struct field_info
{
   char 		field_name[MAX_SIZE];
   unsigned short	dynamic_flag;
   unsigned short	list_size;
   unsigned int		Ctype_list[MAX_SIZE];
   int			offset;
   int			size;
   char			type_name[MAX_SIZE];
};

struct type_info
{
   char			type_name[MAX_SIZE];
   int			size;
   unsigned short	type_code;
   unsigned short	alignment;
};

#endif
