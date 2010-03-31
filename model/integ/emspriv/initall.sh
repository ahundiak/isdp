rm *.prods
rm ws_emspriv.prods

#special processing for bspmath files
for file in obj_ot_c1.p obj_ot_c4.p obj_ot_sn.p obj_ot_sg.p 
do
  if [ -f bspmath/$file ]
   then 
     cp bspmath/$file mds/$file
     mv bspmath/$file ems/$file
  fi
done

for file in obj_em_c1.p obj_em_c4.p obj_em_sn.p obj_em_sg.p
do
  if [ -f bspmath/$file ]
   then
     mv bspmath/$file mds/$file
  fi
done

/usr/ip32/deltools/node/Initial bspmath bspmathdp exnuc exnucdp grnuc grnucdp grnucsrc model modeldp modelsrc libxc ems emscaf emscde emscff emspam emspcs emspfd emsppp dignuc mds mdsdp draft iems
cp ws_emspriv.prods ws_s.prods
