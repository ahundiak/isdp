# mv bspmath files to ems and mds

echo "... copy ems files ..."
cd bspmath
cp obj_ot_*.p ../ems

echo "... move mds files ..."
mv obj_ot_*.p ../mds
mv obj_em_*.p ../mds
