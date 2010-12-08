/************************************
 * rMRP  data structure definitions *
 ************************************/

#ifndef rMRPstr
#define rMRPstr 1

#include "dbadev.h"

struct PSUattr
  {
   char				*name;
   char				*syn;
   char				*datatype;
   int				width;
   int				flag;
  };

struct PSUrpt
  {
   struct dba_default_options	options;
   struct dba_default_list	*list;
   int				*justification;
   int				list_total;
   char				templatetype[2];
   int				process;
   char				*where;
   char				*templib;
  };

struct rMRPlexattr
  {
   int	col;
   int	len;
   char	*name;
   int	flag;
   char *value;
  };

struct  rMRParg
  {
   char		*command;
   char		*product;
   char		*tmplt_fname;
   char		*bom_fname;
   char		*assembly;
   char		*revision;
   char		*descrip;
   char		*ems_fname;
   char		*catalog;
   char		*dbg_fname;
  };

struct  rMRPcit_lev_val_struct
  {
   int		citemno;
   int		ccatalogno;
   int		citno;
   int		level;
   int		values_flag;
  };

struct rMRPindex_slot
  {
    char	*tablename;
    int		slot;
  };

struct rMRPstruct_list
   {
    char	*catalog;
    char	*itemname;
    char	*itemrev;
    char	*itemdesc;
    float	quantity;
    char	*usageid;
    char	*alttagno;
    char	incbom;
    char	explode;
    int		level;
    int		pdcno;
    int		tagno;
    short int	delete_flag;
    short int	child_flag;
    short int	tag_flag;
    short int	check_flag;
    int		itemno;
    int		catalogno;
   };

struct rMRPvar
   {
    struct rMRPstruct_list *struct_list;
    struct rMRPindex_slot *index_slot;
    struct rMRPcit_lev_val_struct *cit_lev_val_struct;
    struct rMRParg *rmrparg;
    int	header;
    int ident;
   };

#endif

