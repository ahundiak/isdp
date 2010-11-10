/* #######################    APOGEE COMPILED   ######################## */
/*
   GRIO_float_to_fraction - private

   This function takes a value (double), and a denominator (short) and
   return an ascii string (string) containing the ascii_equivalent of
   the fraction.  A flag ( reduce_flag ) determines if the resulting
   string represents the reduced form of the fraction or not.
   
   For example:

         reduce_flag = TRUE
	 value       = .75
	 demoninator = 8
         string      = "3/4"

         reduce_flag = FALSE
	 value       = .75
	 demoninator = 8
         string      = "6/8"

 */
typedef double IGRdouble;

int GRIO_float_to_frac(reduce_flag,
		       value,
		       denominator,
		       string)
short reduce_flag;
IGRdouble value;
short denominator;
char *string;
{
  return UOM_float_to_frac( reduce_flag, value, denominator, string );
}

/*
 *  greatest common denonimator function ( recursive )
 */
int GRIO_gcd( n, d )
int n, d;
{
  return UOM_gcd( n, d );
}
