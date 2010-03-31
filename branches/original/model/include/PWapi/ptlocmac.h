#ifndef ptlocmac_include
#define ptlocmac_include 1


#define PW_2dbxinc(bx, tol) \
{ \
   (bx)[0][0] -= (tol); \
   (bx)[0][1] -= (tol); \
   (bx)[1][0] += (tol); \
   (bx)[1][1] += (tol); \
}

#define PW_2dbxpt(uvpt, tol, bx) \
{ \
   (bx)[0][0] = (uvpt)[0] - (tol); \
   (bx)[0][1] = (uvpt)[1] - (tol); \
   (bx)[1][0] = (uvpt)[0] + (tol); \
   (bx)[1][1] = (uvpt)[1] + (tol); \
}

#define PW_3dbxpt(xyzpt, tol, bx) \
{ \
   (bx)[0][0] = (xyzpt)[0] - (tol); \
   (bx)[0][1] = (xyzpt)[1] - (tol); \
   (bx)[0][2] = (xyzpt)[2] - (tol); \
   (bx)[1][0] = (xyzpt)[0] + (tol); \
   (bx)[1][1] = (xyzpt)[1] + (tol); \
   (bx)[1][2] = (xyzpt)[2] + (tol); \
}

#define PW_2dptinbx(box, pt) \
       ( ((pt)[0]>=(box)[0][0])&&((pt)[1]>=(box)[0][1])&& \
((pt)[0]<=(box)[1][0])&& ((pt)[1]<=(box)[1][1])) ? TRUE : FALSE

#endif
