BEGIN{
 seed[1]=12; seed[2]=120; seed[3]=180; seed[4]=360; seed[5]=840;
 seed[6]=2520; seed[7]=5040; seed[8]=55440; seed[9]=720720;
 seed[10]=1441440; seed[11]=24504480;
 for(j=1;j<=10;j++){
  e=_et(seed[j])
  print seed[j],e>>"et.tbl"
  print j,e >"/dev/stderr"
 }
}