/*
  FILE OVERVIEW

  This file contains the functions that manipulate matrices.
*/
#include <memory.h>
#include "PWminimum.h"
#include "PWapi/mx.h"

/*
  ABSTRACT

  This function takes in storage for a matrix and returns an identity
  matrix. The value of the function returned is the pointer to the
  input matrix. This way it can be used directly as an argument to a
  function requiring an identity matrix.
*/
  
double * pwIdMx
(
  PWmatrix mat
)
{
  memset (mat, 0, sizeof (PWmatrix));
  mat[0] = mat[5] = mat[10] = mat[15] = 1.0;
  return (mat);
}
