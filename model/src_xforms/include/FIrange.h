#ifndef FIrange_included
#define FIrange_included	1


struct FIrange_instance
{
  float		increment;   
  float		slot_width;

  double	low_value;        
  double	high_value;

  int		(*cont_routine)();
    
  char		display_mask;

  char		field_width;             
  char		decimal_accuracy;
};


#endif
