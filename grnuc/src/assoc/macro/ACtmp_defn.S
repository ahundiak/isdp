/*---------------------------------------------------------------------------
/*  ACsymb_defn.S
/*---------------------------------------------------------------------------*/

class specification ACtmp_defn (0:0) of ACcpx_defn;

#include "igrtypedef.h"

instance ACtmp_defn 
 {
  variable char total_name[0];
 };

override ACcpx_defn;

override ACreturn_real_def,
         ACreturn_symb_def;
override 	unknown;

message ACset_mac_name(char *file_name,*macro_name);

/*---------------------------------------------------------------------------
/*
/* This message defines the file_name and the macro_name in this file
/* of the real construction that I pretend to be
/*
/*      Argument description :
/*      --------------------
/*   char *file_name  I : name of the file
/*   char *macro_name I : name of the construction
/*
/*---------------------------------------------------------------------------*/



message ACget_mac_name(char *file_name,*macro_name);

/*---------------------------------------------------------------------------
/*
/* This message returns the file_name and the macro_name in this file
/* of the real construction that I pretend to be
/*
/*      Argument description :
/*      --------------------
/*   char *file_name  O : name of the file
/*   char *macro_name O : name of the construction
/*
/*---------------------------------------------------------------------------*/

end specification ACtmp_defn;
