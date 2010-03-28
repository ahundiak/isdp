/*
/*---------------------------------------------------------------------------
/*  ACmacro_hdr.S
/*  robert patience
/*  21_jul_86
/*
/*  ABSTRACT
/*---------------------------------------------------------------------------*/
class specification ACmacro_hdr (0:0) of ACcomplex,ACcpx;

#include "macro.h"

instance ACmacro_hdr 
{
};

/* send rebuild to hdr */
override 	ACdrop;

reject 		ACbuild_rtn_str;


end specification ACmacro_hdr;
