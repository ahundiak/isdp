/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

# ifndef bsequat_include
# define bsequat_include

# ifndef igrtypedef_include
#   include "igrtypedef.h" /* IGR types */
# endif

struct BSequation_uv
{
  /*  local representation of the function E(u,v) for evaluation [-1,1] */
  IGRint         typeeq;   /* type of equation stored here 		*/
                           /* EQHOMO = homogeneous equation (canonical) */
                           /* EQCANO = canonical equation (ndegu,ndegv) */
  IGRint         *degrees; /* degree(s) defining the arrays of coeffic. */
                           /* if typeeq = EQHOMO degrees=(ndeg,nbrcoef) */
                           /* with ndeg    = homogeneous degree of equa */
                           /*      nbrcoef = (ndeg+1)*(ndeg+2)/2        */
                           /* if typeeq = EQCANO degrees=(ndegu,ndegv)  */
                           /* with ndegu = degree in u of equation E    */
                           /*      ndegv = degree in v of equation E    */
  IGRdouble      *coeffi ; /* if typeeq = EQHOMO			*/
                           /* coeffi = array[0:nbrcoef-1]		*/
                           /* if typeeq = EQCANO 			*/
                           /* coeffi = array[0:ndegv,0:ndegu]		*/

  /*  global representation of the function E(u,v) by polynomial [-1,1] */
  IGRint         tabdeg[6][2] ; 
                           /* [i][0] degree in u of i th polynom *eu*v* */
                           /* [i][1] degree iv u of i h polynom *eu*v* */
  IGRdouble      *eu0v0  ; /* polynomial representation on [-1,1]**2    */
  IGRdouble      *eu1v0  ; /* polynomial representation of E'u(u,v)     */
  IGRdouble      *eu0v1  ; /* polynomial representation of E'v(u,v)     */
  IGRdouble      *eu2v0  ; /* polynomial representation of E''uu(u,v)   */
  IGRdouble      *eu1v1  ; /* polynomial representation of E''uv(u,v)   */
  IGRdouble      *eu0v2  ; /* polynomial representation of E''vv(u,v)   */
                           /* if a pointer *eu*v* is NULL it means that */
                           /* the array is not available 		*/
  IGRint         typbase ; /* type of base for the polynomial           */
                           /* LEGEND , CANONI , BEZIER			*/
};
# define EQHOMO    700     /* homogeneous canonical equation	        */
# define EQCANO    720     /* polynomial equation in canonical basis    */

struct BSspars_mat
{
   IGRint    nbcol   ;   /* number of column 		of the system */
   IGRint    nbrow   ;   /* number of row    		of the system */
   IGRint    nbcoef  ;   /* number of non null elements in the system */
   IGRint    allocm  ;   /* number of elements we can store in arrays */
   IGRdouble *matrix ;   /* the non null elements of the matrix , row
                            by row (elements are listed in matrix[0:
                            nbcoef-1];space available is [0:allocm-1])*/
   IGRint    *indxcol;   /* column-index of each element in matrix
                            (index are listed in indxcol[0:nbcoef-1] ;
                             space available is indxcol[0:allocm-1])  */
   IGRint    *indxrow;   /* index to matrix and indxcol of the first 
                            element in a given row of matrix .
                            There is nbrow+1 index here , last one is 
                            nbcoef . indxrow[i+1]-indxrow[i] is the 
                            number of non null elements in row i      */
};

struct BSspars_mat2
{
   IGRint    nbcol   ;   /* number of column 		of the system */
   IGRint    nbrow   ;   /* number of row    		of the system */
   IGRint    nbcoef  ;   /* number of non null elements in the system */
   IGRint    allocm  ;   /* number of elements we can store in arrays */
   IGRdouble *matrix ;   /* the non null elements of the matrix , row
                            by row (elements are listed in matrix[0:
                            nbcoef-1];space available is [0:allocm-1])*/
   IGRint    *indxcol;   /* column-index of each element in matrix
                            (index are listed in indxcol[0:nbcoef-1] ;
                             space available is indxcol[0:allocm-1])  */
   IGRint    *indxrow;   /* [3*i]:index to matrix and indxcol of the 
                          1st element of row i in the matrix .
                          [3*i+1]:index+1 of the last non null element 
                          of row i . indxrow[3*i+1]-indxrow[3*i] is the 
                          number of non null elements in row i .
                          indxrow[3*i+2] is a limit index of storage :
                          current row cannot be expanded over this index
                          There is 3*nbrow+1 index here , last one is 
                          beginning of free space inside array matrix. */
};

# endif /* bsequat_include */
