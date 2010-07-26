




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

#ifndef codp_include

#define codp_include


/* Structures for View/Dbase axes and element lock command */

struct DPprojs_info
{
	IGRint		flag;
	OM_S_OBJID	winid;
	uword		osnum;
       	IGRdouble	origin[3];
        IGRdouble	Xproj;
        IGRdouble	Yproj;
        IGRdouble	Zproj;

struct 	DPele_header   *bufrs_ptr;
};

struct DPvwinfo
{

struct  DPprojs_info	vw_info; 
        IGRint		g_flags;

};


struct DPelem_proj
{
       	 OM_S_OBJID	winid;
         uword		osnum;
         IGRdouble	proj_mat[4][4];
         IGRdouble	Xproj;
         IGRdouble	Yproj;
         IGRdouble	Zproj;
  struct IGRline        *tng_ln;
  struct DPele_header	*bufrs_ptr;
};

#endif
