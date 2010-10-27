/*

Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved.

Name
    BNsb_lop 

Abstract
    This is a subroutine of the facet package.
    This function calculates facet patches of bnd_loop.

Synopsis
     status = BNsb_lop(rc,nb,b_loop,org,us,ud,vs,vd,n1,
                       c_1,d_1,n2,c_2,d_2,n3,c_3,d_3,n4,
                       c_4,d_4,n_lop,b_lop)

Description
    Input:
     *nb	  IGRint	  number of boundaries
     *b_loop      struct BNb_loop
	          {
		    IGRboolean   p_loop;
                    IGRint       np;       - number of points
                    IGRdouble    *uv;
		    IGRdouble    range[4];
                  }
     us,ud        IGRdouble       U range
     vs,vd        IGRdouble       V range
     org	  IGRshort        TRUE: if original point is solid
     				  FALSE: original is void
     n1,n2        IGRint
     n3,n4
     *c_1,*c_3    IGRdouble       U range
     *c_2,*c_4    IGRdouble       V range
     *d_1,*d_2	  IGRint
     *d_3,*d_4	  IGRint

    Output:
     *n_lop	  IGRint
     **b_lop 	  struct Facetloop

Return Values
     *rc          IGRint         Completion code message
                                 - MSSUCC if successful
                                 - MSFAIL if another error occurred.
     status       IGRboolean     TRUE  - if successful
                                 FALSE - if an error occurred

Notes

Index
    fc

Keywords

History
	S.T. Wang    11/3/87  : Creation date.
        Vivian W.Ye  07/05/89 : Initialize cc_lop.
        Vivian W.Ye  08/29/89 : Set c_lop->np = nbp.
        Vivian W.Ye  10/27/89 : Change to new header.
        C.S. Kirby   11/10/90 : Initialize variables to avoid warnings.
        David Ratner 01/28/92 : Use BSmalloc, BSrealloc, BSdealloc.
        D. Breden    02/23/93 : Check status1 after calling BNsb_csn().
		Vivian Hsu   11/07/00 : Fixed a memory overwrite problem before reallocating.
    S.G. Catron  03/30/01 : TR   - memory overwriting.  It's not reallocing enough
                            memory. It leaves a buffer of 4 uvs, but this time
                            it needed 5 uvs- sb_fct.d17.
*/
#ifdef DONOTSPROTO
#include "ubspmp.h" 
#endif

#ifdef NT 
#include "ubspm.h" 
#else 
#include "bsdefs.h"
#include "bserr.h"
#include "bsmalloc.h"
#include "bnfacet.h"
#endif
#define ALLOCSIZE 1000

#include <math.h>

IGRboolean BNsb_lop(
BSrc                    *rc,
IGRint			*nb,
struct BNb_loop		*b_loop,
IGRshort		org,
IGRdouble               us,
IGRdouble               ud,
IGRdouble               vs,
IGRdouble               vd,
IGRint                  n1,
IGRdouble               *c_1,
IGRshort                *d_1,
IGRint                  n2,
IGRdouble               *c_2,
IGRshort                *d_2,
IGRint                  n3,
IGRdouble               *c_3,
IGRshort                *d_3,
IGRint                  n4,
IGRdouble               *c_4,
IGRshort                *d_4,
IGRint                  *n_lop,
struct Facetloop	**b_lop)

{
#ifndef DONOTSPROTO
#include "bsdbgrc.h"
#include "bnsb_crs.h"
#include "bnsb_csn.h"
#endif 

   IGRshort  or1,or2,or3,or4,*shdm1,*ptt = NULL,*ptt_ptr=NULL,status1;
   IGRboolean status,done,org_sv,done1,done2,done3,done4,add_b,
              from_b,*p_done1,*p_done2,*p_done3,*p_done4;
   IGRint i,j,k,nt,i1,i2,next,is_sv,is,inc,nbp = 0,
          b_id,p_id,n_cnt,nc,ncc,d_ck;
   IGRdouble uu,vv,u1,v1,*ptr = NULL,*ptr_ptr=NULL,*prr,xo,zo,tol,*shdm2,
             zz,ve1[2],vec[2],ssu = 0.0,ssv = 0.0,um = 0.0,vm,ui,vi;
   struct BNb_loop  *b_lp;
   struct Facetloop  *cc_lop,*c_lop = NULL;


   status = TRUE;
   status1 = 1;
   *rc = BSSUCC;
   tol = 0.00000001;
   ncc = ALLOCSIZE;
   n_cnt = *n_lop;
   p_done1 = 0;
   p_done2 = 0;
   p_done3 = 0;
   p_done4 = 0;
   is_sv = 0;
   
   nt = n1 + n2 + n3 + n4;
   if( *n_lop)
   {
      nt += *n_lop;
      cc_lop = (struct Facetloop *)BSrealloc((char *)*b_lop,
                           (unsigned)(nt * sizeof(struct Facetloop)));
   }
   else
   {
      cc_lop = (struct Facetloop *)BSmalloc((unsigned)
                                     (nt * sizeof(struct Facetloop)));
      cc_lop->p_loop = 0;
      cc_lop->np = 0;
      cc_lop->uv = NULL;
      cc_lop->xyz = NULL;
      cc_lop->b_bit = NULL;
   }

   if( n1 )
   {
      p_done1 = (IGRboolean *)BSmalloc((unsigned)(n1 * sizeof(IGRboolean)));
      if(! p_done1)
      {
         status = FALSE;
         goto wrapup;
      }
      for(i=0; i< n1; i++) p_done1[i] = FALSE;
   }
   if( n2 )
   {
      p_done2 = (IGRboolean *)BSmalloc((unsigned)(n2 * sizeof(IGRboolean)));
      if(! p_done2)
      {
         status = FALSE;
         goto wrapup;
      }
      for(i=0; i< n2; i++) p_done2[i] = FALSE;
   }
   if( n3 )
   {
      p_done3 = (IGRboolean *)BSmalloc((unsigned)(n3 * sizeof(IGRboolean)));
      if(! p_done3)
      {
         status = FALSE;
         goto wrapup;
      }
      for(i=0; i< n3; i++) p_done3[i] = FALSE;
   }
   if( n4 )
   {
      p_done4 = (IGRboolean *)BSmalloc((unsigned)(n4 * sizeof(IGRboolean)));
      if(! p_done4)
      {
         status = FALSE;
         goto wrapup;
      }
      for(i=0; i< n4; i++) p_done4[i] = FALSE;
   }
   done1 = FALSE;
   done2 = FALSE;
   done3 = FALSE;
   done4 = FALSE;
   from_b = FALSE;
   org_sv = FALSE;
/*
   first determine if or1 is solid
*/
   i1 = 1;
   i2 = 1;
   d_ck = 0;
   if( n1 )
   {
      done = FALSE;
      for(i=0; (i< n1) && (! done); i ++)
      {
         if(c_1[i] > us)                 /*** later need multi start  ***/
         {
            um = 0.5 * (us + c_1[i]);
            done = TRUE;
         }
         else
         {
            d_ck += 1;
         }
      }
      if(! done) um = 0.5 * (us + ud);
   }
   else
   {
      um = 0.5 * (us + ud);
   }
   vm = vs + tol;
   ui = 0.0;
   vi = 0.0;
   status = BNsb_crs(rc,nb,b_loop,ui,um,vi,vm,i1,i2,
                     &nc,&shdm1,&shdm2);
   if(! status) goto wrapup;
   i2 = nc - (nc / 2 * 2);
   or1 = org;
   if( i2 ) or1 += 1;
   if( or1 == 2) or1 = 0;
   if( d_ck )
   {
      i2 = d_ck - (d_ck / 2 * 2);
      if( i2 ) or1 += 1;
      if( or1 == 2) or1 = 0;
   }
   i2 = n1 - (n1 / 2 * 2);
   or2 = or1;
   if( i2 ) or2 += 1;
   if( or2 == 2) or2 = 0;
   i2 = n2 - (n2 / 2 * 2);
   or3 = or2;
   if( i2 ) or3 += 1;
   if( or3 == 2) or3 = 0;
   i2 = n3 - (n3 / 2 * 2);
   or4 = or3;
   if( i2 ) or4 += 1;
   if( or4 == 2) or4 = 0;


   if(or1)
   {
      ssu = us;
      ssv = vs;
      c_lop = &cc_lop[n_cnt];
      n_cnt += 1;
      ptr = (IGRdouble *)BSmalloc((unsigned)(ncc * 2 * sizeof(IGRdouble)));
      ptt = (IGRshort *)BSmalloc((unsigned)(ncc * sizeof(IGRshort)));

      if( (! ptr) || (! ptt) )
      {
         status = FALSE;
         goto wrapup;
      }
      ptr_ptr = ptr;
      ptt_ptr = ptt;
      c_lop->uv = ptr;
      c_lop->xyz = 0;
      c_lop->b_bit = ptt;
      
      c_lop->uv[nbp*2] = ssu;
      c_lop->uv[nbp*2+1] = ssv;
      *ptt++ = 1;
      nbp = 1;
      c_lop->np = 1;
      org_sv = TRUE;
   }

   for( ; (! done1) || (! done2) || (! done3) || (! done4); )
   {
      do_1:

      if( ! done1 )
      {
         if( n1 )
         {
            is = 0;
            if( from_b ) is = is_sv;
            for(i=is; i< n1; i ++)
            {
               if(! p_done1[i])
               {
                  p_done1[i] = TRUE;
                  if( org_sv )
                  {
                     c_lop->uv[nbp*2] = c_1[i];
                     c_lop->uv[nbp*2+1] = vs;
                     *ptt++ = 0;
                     nbp += 1;
                     c_lop->np += 1;
                     b_id = d_1[2*i];
                     p_id = d_1[2*i+1];
                     ve1[0] = 1.0;
                     ve1[1] = 0.0;
                     goto st_b;
                  }
                  else
                  {
                     ssu = c_1[i];
                     ssv = vs;
                     c_lop = &cc_lop[n_cnt];
                     n_cnt += 1;
                     ptr = (IGRdouble *)BSmalloc((unsigned)
                                           (ncc * 2 * sizeof(IGRdouble)));
                     ptt = (IGRshort *)BSmalloc((unsigned)
                                           (ncc * sizeof(IGRshort)));
                     if( (! ptr) || (! ptt) )
                     {
                        status = FALSE;
                        goto wrapup;
                     }
                     ptt_ptr = ptt;
                     ptr_ptr = ptr;
                     c_lop->uv = ptr;
                     c_lop->xyz = 0;
                     c_lop->b_bit = ptt;
                     c_lop->uv[nbp*2] = ssu;
                     c_lop->uv[nbp*2+1] = ssv;
                     *ptt++ = 0;
                     c_lop->np = 1;
                     nbp = 1;
                     org_sv = TRUE;
                  }
               }
            }
         }
         if( ! from_b ) done1 = TRUE;
         if( or2 )
         {
            if( org_sv )
            {
               c_lop->uv[nbp*2] = ud;
               c_lop->uv[nbp*2+1] = vs;
               *ptt++ = 1;
               c_lop->np += 1;
               nbp += 1;
            }
            else
            {
               if(! done1 )
               {
                  status1 = 0;
                  goto wrapup;
               }
            }
         }
         from_b = FALSE;
      }

      do_2:

      if( ! done2 )
      {
         if( n2 )
         {
            is = 0;
            if( from_b ) is = is_sv;
            for(i=is; i< n2; i++)
            {
               if(! p_done2[i])
               {
                  p_done2[i] = TRUE;
                  if( org_sv )
                  {
                     c_lop->uv[nbp*2] = ud;
                     c_lop->uv[nbp*2+1] = c_2[i];
                     *ptt++ = 0;
                     c_lop->np += 1;
                     nbp += 1;
                     b_id = d_2[2*i];
                     p_id = d_2[2*i+1];
                     ve1[0] = 0.0;
                     ve1[1] = 1.0;
                     goto st_b;
                  }
                  else
                  {
                     ssu = ud;
                     ssv = c_2[i];
                     c_lop = &cc_lop[n_cnt];
                     n_cnt += 1;
                     ptr = (IGRdouble *)BSmalloc((unsigned)
                                           (ncc * 2 * sizeof(IGRdouble)));
                     ptt = (IGRshort *)BSmalloc((unsigned)
                                           (ncc * sizeof(IGRshort)));
                     if( (! ptr) || (! ptt) )
                     {
                        status = FALSE;
                        goto wrapup;
                     }
                     ptt_ptr = ptt;
                     ptr_ptr = ptr;
                     c_lop->uv = ptr;
                     c_lop->xyz = 0;
                     c_lop->b_bit = ptt;
                     c_lop->uv[nbp*2] = ssu;
                     c_lop->uv[nbp*2+1] = ssv;
                     *ptt++ = 0;
                     c_lop->np = 1;
                     nbp = 1;
                     org_sv = TRUE;
                  }
               }
            }
         }
         if( ! from_b ) done2 = TRUE;
         if( or3 )
         {
            if( org_sv )
            {
               c_lop->uv[nbp*2] = ud;
               c_lop->uv[nbp*2+1] = vd;
               *ptt++ = 1;
               c_lop->np += 1;
               nbp += 1;
            }
            else
            {
               if( ! done2 )
               {
                  status1 = 0;
                  goto wrapup;
               }
            }
         }
         from_b = FALSE;
      }

      do_3:
      if( ! done3 )
      {
         if( n3 )
         {
            is = 0;
            if( from_b ) is = is_sv;
            for(i=is; i< n3; i++)
            {
               if(! p_done3[i])
               {
                  p_done3[i] = TRUE;
                  if( org_sv )
                  {
                     c_lop->uv[nbp*2] = c_3[i];
                     c_lop->uv[nbp*2+1] = vd;
                     *ptt++ = 0;
                     c_lop->np += 1;
                     nbp += 1;
                     b_id = d_3[2*i];
                     p_id = d_3[2*i+1];
                     ve1[0] = -1.0;
                     ve1[1] = 0.0;
                     goto st_b;
                  }
                  else
                  {
                     ssu = c_3[i];
                     ssv = vd;
                     c_lop = &cc_lop[n_cnt];
                     n_cnt += 1;
                     ptr = (IGRdouble *)BSmalloc((unsigned)
                                           (ncc * 2 * sizeof(IGRdouble)));
                     ptt = (IGRshort *)BSmalloc((unsigned)
                                           (ncc * sizeof(IGRshort)));
                     if( (! ptr) || (! ptt) )
                     {
                        status = FALSE;
                        goto wrapup;
                     }
                     ptt_ptr = ptt;
                     ptr_ptr = ptr;
                     c_lop->uv = ptr;
                     c_lop->xyz = 0;
                     c_lop->b_bit = ptt;
                     c_lop->uv[nbp*2] = ssu;
                     c_lop->uv[nbp*2+1] = ssv;
                     *ptt++ = 0;
                     c_lop->np = 1;
                     nbp = 1;
                     org_sv = TRUE;
                  }
               }
            }
         }
         if( ! from_b ) done3 = TRUE;
         if( or4 )
         {
            if( org_sv )
            {
               c_lop->uv[nbp*2] = us;
               c_lop->uv[nbp*2+1] = vd;
               *ptt++ = 1;
               c_lop->np += 1;
               nbp += 1;
            }
            else
            {
               if(! done3 )
               {
                  status1 = 0;
                  goto wrapup;
               }
            }
         }
         from_b = FALSE;
      }

      do_4:
      if( ! done4 )
      {
         if( n4 )
         {
            is = 0;
            if( from_b ) is = is_sv;
            for(i=is; i< n4; i++)
            {
               if(! p_done4[i])
               {
                  p_done4[i] = TRUE;
                  if( org_sv )
                  {
                     c_lop->uv[nbp*2] = us;
                     c_lop->uv[nbp*2+1] = c_4[i];
                     *ptt = 0;
ptt++;
                     c_lop->np += 1;
                     nbp += 1;
                     b_id = d_4[2*i];
                     p_id = d_4[2*i+1];
                     ve1[0] = 0.0;
                     ve1[1] = -1.0;
                     goto st_b;
                  }
                  else
                  {
                     ssu = us;
                     ssv = c_4[i];
                     c_lop = &cc_lop[n_cnt];
                     n_cnt += 1;
                     ptr = (IGRdouble *)BSmalloc((unsigned)
                                           (ncc * 2 * sizeof(IGRdouble)));
                     ptt = (IGRshort *)BSmalloc((unsigned)
                                           (ncc * sizeof(IGRshort)));
                     if( (! ptr) || (! ptt) )
                     {
                        status = FALSE;
                        goto wrapup;
                     }
                     ptt_ptr = ptt;
                     ptr_ptr = ptr;
                     c_lop->uv = ptr;
                     c_lop->xyz = 0;
                     c_lop->b_bit = ptt;
                     c_lop->uv[nbp*2] = ssu;
                     c_lop->uv[nbp*2+1] = ssv;
                     *ptt++ = 0;
                     c_lop->np = 1;
                     nbp = 1;
                     org_sv = TRUE;
                  }
               }
            }
         }
         if( ! from_b ) done4 = TRUE;
         if( or1 )
         {
            if( org_sv )
            {
               if( (us != ssu) || (vs != ssv))
               {
                  status1 = 0;
                  goto wrapup;
               }
               c_lop->uv[nbp*2] = us;
               c_lop->uv[nbp*2+1] = vs;
               *ptt++ = 1;
               c_lop->np += 1;
               nbp += 1;
               goto cls_lop;
            }
            else
            {
               if(! done4 )
               {
                  status1 = 0;
                  goto wrapup;
               }
            }
         }
         from_b = FALSE;
      }
      goto cnt5;

      st_b:
      u1 = c_lop->uv[(nbp-1)*2];
      v1 = c_lop->uv[(nbp-1)*2+1];
      b_lp = &b_loop[b_id];
      prr = b_lp->uv;
      j = p_id * 2;
      vec[0] = prr[j] - prr[j-2];
      vec[1] = prr[j+1] - prr[j-1];
      zz = ve1[0] * vec[1] - ve1[1] * vec[0];
      if( fabs(zz) < tol )
      {
         if((fabs(prr[j] - u1) < tol) && (fabs(prr[j+1] - v1) < tol))
         {
            inc = 1;
            is = p_id + 1;
         }
         else
         {
            inc = -1;
            is = p_id - 2;
         }
      }
      else if( zz < 0.0 )
      {
         inc = -1;
         is = p_id - 1;
      }
      else
      {
         inc = 1;
         is = p_id;
      }
      done = FALSE;  
      for(i=is; (! done); i+= inc)
      { 
         if(i < 0) i = b_lp->np - 2;
         if(i >= b_lp->np) i = 1;
         j = 2 * i;
         uu = prr[j];
         vv = prr[j+1];

         /*   if new point is same as previous point skip it   */
         if((fabs(uu - u1) < tol) && (fabs(vv - v1) < tol))
         goto cnx1;

         /*   if new point is on boundary   */
         add_b = TRUE;
         status1 = 2;
         if((fabs(vv - vs) < tol) && (uu <= ud) && (uu >= us))
         {
            xo = uu;
            zo = vs;
            goto cx1;
         }
         if((fabs(uu - ud) < tol) && (vv <= vd) && (vv >= vs))
         {
            xo = ud;
            zo = vv;
            goto cx2;
         }
         if((fabs(vv - vd) < tol) && (uu <= ud) && (uu >= us))
         {
            xo = uu;
            zo = vd;
            goto cx3;
         }
         if((fabs(uu - us) < tol) && (vv <= vd) && (vv >= vs))
         {
            xo = us;
            zo = vv;
            goto cx4;
         }

         /*   if new point is inside the region   */

         rebd:
         if(((uu <= ud) && (vv <= vd) && (uu >= us) && (vv >= vs)) ||
            ((fabs(uu - ssu) < tol) && (fabs(vv - ssv) < tol)) )
         {
            /* cludge, changed to ncc-8(from ncc-4), because sometimes 
               it needs more than 4 more- sb_fct.d17 */
            if( nbp >= (ncc - 8) )
            {
               ncc += ALLOCSIZE;
               c_lop->uv = (IGRdouble *)BSrealloc((char *)c_lop->uv,
                              (unsigned)((2* ncc) * sizeof(IGRdouble)));
               ptr = &c_lop->uv[nbp*2];
               c_lop->b_bit = (IGRboolean *)BSrealloc((char *)c_lop->b_bit,
                              (unsigned)(ncc * sizeof(IGRboolean)));
               if((! c_lop->uv) || (! c_lop->b_bit))
               {
                  status = FALSE;
                  goto wrapup;
               }
               ptt = &c_lop->b_bit[nbp];
            }

			/* Move these line after the realloc to avoid overwrite memory */

            c_lop->uv[nbp*2] = uu;
            c_lop->uv[nbp*2+1] = vv;
            *ptt++ = 0;
            c_lop->np += 1;
            nbp += 1;

            if((fabs(uu - ssu) < tol) && (fabs(vv - ssv) < tol) )
              goto cls_lop;
            goto cnx1;
         }


         add_b = TRUE;
         status1 = BNsb_csn(rc,u1,v1,uu,vv,us,vs,ud,vs,&xo,&zo);
         if(status1)
         {
            if((fabs(u1 - xo) < tol) && (fabs(v1 - zo) < tol))
               status1 = FALSE;
         }

         cx1:
         if( status1)
         {
            for(k=0; k< n1 ; k++)
            {
               if( fabs(xo - c_1[k]) < tol)
               {
                  is_sv = k;
                  p_done1[k] = TRUE;
                  next = 1;
                  goto cont45;
               }
            }
            if(status1 == 2)
            {
               if( (fabs(xo - ud) < tol) && (fabs(zo - vs) < tol) )
               goto cx2;
               goto rebd;
            }
         }

         status1 = BNsb_csn(rc,u1,v1,uu,vv,ud,vs,ud,vd,&xo,&zo);
         if((fabs(u1 - xo) < tol) && (fabs(v1 - zo) < tol))
            status1 = FALSE;

         cx2:
         if( status1)
         {
            for(k=0; k< n2; k++)
            {
               if( fabs(zo - c_2[k]) < tol)
               {
                  is_sv = k;
                  p_done2[k] = TRUE;
                  next = 2;
                  goto cont45;
               }
            }
            if(status1 == 2)
            {
               if( (fabs(xo - ud) < tol) && (fabs(zo - vd) < tol) )
               goto cx3;
               goto rebd;
            }
         }

         status1 = BNsb_csn(rc,u1,v1,uu,vv,ud,vd,us,vd,&xo,&zo);
         if((fabs(u1 - xo) < tol) && (fabs(v1 - zo) < tol))
            status1 = FALSE;

         cx3:
         if( status1)
         {
            for(k=0; k< n3; k++)
            {
               if( fabs(xo - c_3[k]) < tol)
               {
                  is_sv = k;
                  p_done3[k] = TRUE;
                  next = 3;
                  goto cont45;
               }
            }
            if(status1 == 2)
            {
               if( (fabs(xo - us) < tol) && (fabs(zo - vd) < tol) )
               goto cx4;
               goto rebd;
            }
         }

         status1 = BNsb_csn(rc,u1,v1,uu,vv,us,vd,us,vs,&xo,&zo);
         if((fabs(u1 - xo) < tol) && (fabs(v1 - zo) < tol))
            status1 = FALSE;

         cx4:
         if( status1)
         {
            for(k=0; k< n4; k++)
            {
               if( fabs(zo - c_4[k]) < tol)
               {
                  is_sv = k;
                  p_done4[k] = TRUE;
                  next = 4;
                  goto cont45;
               }
            }
            if(status1 == 2) goto rebd;
         }

         status1 = 0;
         goto wrapup;

         cont45:
         if( add_b )
         {
            c_lop->uv[nbp*2] = xo;
            c_lop->uv[nbp*2+1] = zo;
            *ptt = 0;
            ptt++;
            c_lop->np += 1;
            nbp += 1;
         }
         if( (fabs(xo - ssu) < tol) && (fabs(zo - ssv) < tol))
           goto cls_lop;
         from_b = TRUE;
         if(next == 1) goto do_1;
         if(next == 2) goto do_2;
         if(next == 3) goto do_3;
         if(next == 4) goto do_4;

         cnx1:
         u1 = uu;
         v1 = vv;
         continue;
      }
      

      cls_lop:
      org_sv = FALSE;
      from_b = FALSE;
      c_lop->np = nbp;
      c_lop->uv = (IGRdouble *)BSrealloc((char *)c_lop->uv,
                                (unsigned)((2* nbp) * sizeof(IGRdouble)));
      c_lop->b_bit = (IGRboolean *)BSrealloc((char *)c_lop->b_bit,
                                (unsigned)(nbp * sizeof(IGRboolean)));
      nbp = 0;
      ncc = ALLOCSIZE;
      cnt5:
      continue;
   }
   status1 = 1;

   wrapup:
   if( status1 == 0 )
   {
      if( n_cnt > 0 )
         n_cnt -= 1;
   }
   if( n_cnt != 0)
   {
      *b_lop = (struct Facetloop *)BSrealloc((char *)cc_lop,
                          (unsigned)(n_cnt * sizeof(struct Facetloop)));
      *n_lop = n_cnt;
   }
   else
   {
      if(cc_lop)
      {
         BSdealloc((char *)cc_lop);
         cc_lop = NULL;
      }
      *b_lop = NULL;
   }
   if( p_done1 )
   {
      BSdealloc((char *)p_done1);
      p_done1 = NULL;
   }
   if( p_done2 )
   {
      BSdealloc((char *)p_done2);
      p_done2 = NULL;
   }
   if( p_done3 )
   {
      BSdealloc((char *)p_done3);
      p_done3 = NULL;
   }
   if( p_done4 )
   {
      BSdealloc((char *)p_done4);
      p_done4 = NULL;
   }

   if(BSERROR(*rc))
       BSdbgrc(*rc,"BNsb_lop");
   return(status);
}
