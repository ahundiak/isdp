/***********************************
 * MRP  data structure definitions *
 ***********************************/

#ifndef MRPstr
#define MRPstr 1


struct MRPenv
  {
   char		nodename[30];
   char		username[30];
   char		pwd[30];
   char		schemname[30];
   char		schempwd[30];
   int		flag;
  };
 
struct MRPfilelist
   {
    char	*filename;
    int		flag;
   };

struct MRPpartlist
   {
    char	*partid;
    char	*catalog;
    char	*revision;
    char	*mrppart;
    char	*mrpbomuom;
    char	*effectdate;
    char	*invuom;
    char	*fieldupd;
    char	*mrpstruct;
    int		assem_flag;
    int		part_flag;
   };

struct MRPcatlist
   {
    char	*catalog;
    int		catalogno;
    int		flag;
   };

struct MRPtransattr
   {
    int		transcodeno;
    char	*attrname;
    char	*synonym;
    char	*description;
    char	*value;
    char	*datatype;
    int		startpos;
    int		width;
    int		flag;
    int		justification;
    char	*format;
   };

struct MRPtranscode
   {
    int		transcodeno;
    char	*codename;
    char	*description;
    char	*filename;
    int		flag;
   };

struct MRPitem
   {
    char	*partid;
    char	*pcatname;
    char	*revision;
    char	*attrname;
    char	*value;
    int		flag;
    double	quantity;
    int		seqno;
   };


struct MRPvar
	{
	char		*name;
	char		*passwd;
	int		pitemno;
	char		*bomname;
        int		catno;
	char		*catalog;
	char		*partid;
	char		*revision;
	char		*filename;
	char		*code;
	int		codeno;
	char		*code_desc;
	char		*attr;
	char		*attr_desc;
	char		*environment;
	int		width;
	int		command;
	int		list_position;
	long		status;

	struct MRPoptions	*options;
	struct MRPpartlist	*part_list;
	char			*bom_list;
	struct MRPcatlist	*cat_list;
        struct MRPtranscode     *code_list;
	struct MRPfilelist	*file_list;
	struct MRPtransattr	*attr_list;
	struct MRPenv		*env_list;
	char			*transcodes_buff;
	char			*transattr_buff;
	struct MRPitem		*item;
	struct MRPitem		*item2;
	int			*aux_ptr1;
 	};
  	
struct MRPoptions
       {
	char		*attr;
	char		*value;
       };

#endif
