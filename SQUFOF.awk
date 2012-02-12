#
# SQUFOF.awk ver.0.3
#

function SQUFOF(a,b, C,i,j,m,parity,r,t,
                 d1,D1,F1,L1,queue1,absF1,
                 d2,D2,F2,L2,queue2,absF2){
# assume the number is an odd composite
 if(r=issquare(a))
  if(isprime(r)){
   kome(PRIME,r,2*b)
   return list_len(pfactor)
  }
  else{
   kome(COMPOSITE,r,2*b)
   return 0
  }

 print "starting SQUFOF" > "/dev/stderr"

 if(mod(a,4)==1)
  m=split("1 5 13 17 29 37",C)
 else # if(mod(a,4)==3)
  m=split("3 4 7 11 19 23",C)
 for(i=1;i<=m;i+=2){
  D1=multiple(C[i],a)
  D2=multiple(C[i+1],a)
  d1=fsqrt(D1)
  d2=fsqrt(D2)
  L1=fsqrt(d1)
  L2=fsqrt(d2)
  F1[1]=F2[1]=1
  F1[2]=suc(double(quotient2(pred(d1))))
  if(i==1 && D2~/[02468]$/)
   F2[2]=double(quotient2(d2))
  else
   F2[2]=suc(double(quotient2(pred(d2))))
  F1[3]=quotient(subtract(square(F1[2]),D1),4)
  F2[3]=quotient(subtract(square(F2[2]),D2),4)
  delete queue1
  delete queue2
  t=2 # to escape first check
  for(parity=1;t!=1;parity=!parity){
   rho(F1,D1)
   rho(F2,D2)
   absF1=F1[1]~/^-/?substr(F1[1],2):F1[1]
   absF2=F2[1]~/^-/?substr(F2[1],2):F2[1]
   if(parity){
    if(!isbigger(absF1,L1))
     queue1[absF1]=1
    if(!isbigger(absF2,L2))
     queue2[absF2]=1
    continue
   }
   if(!isbigger(absF1,L1))
    queue1[absF1]=1
   else{
    if((t=issquare(F1[1])) && !(t in queue1))
     if(j=back_cycle(t,F1[2],F1[3],D1,a,b))
      return j
     else
      queue1[absF1]=1
    if(t==1)
     break
   }
   if(!isbigger(absF2,L2))
    queue2[absF2]=1
   else{
    if((t=issquare(F2[1])) && !(t in queue2))
     if(j=back_cycle(t,F2[2],F2[3],D2,a,b))
      return j
     else
      queue2[absF2]=1
   }
  }
  printf("OK, go on..\n")  > "/dev/stderr"
 }
 return 0
}

function rho(form,D, a,b,w,r,d){
 d=fsqrt(D)
 a=form[3]~/^-/?substr(form[3],2):form[3]
 b=form[2]~/^-/?substr(form[2],2):("-" form[2])
 w=double(a)
 if(isbigger(a,d)){
  r=mod(b,w)
  if(isbigger(r,a))
   r=subtract(r,w)
 }
 else
  r=subtract(d,mod(subtract(d,b),w))
 form[1]=form[3]
 form[2]=r
 form[3]=quotient(subtract(square(r),D),multiple(form[3],4))
 return
}

function isreducedQFp(form,D, a,r){
 r=fsqrt(D)
 if(isbigger(form[2],r))
  return 0
 a=double(form[1]~/^-/?substr(form[1],2):form[1])
 r=isbigger(r,a)?subtract(r,a):subtract(a,r)
 if(!isbigger(form[2],r))
  return 0
 return 1
}

function back_cycle(a,b,c,D,N,m, G,g,i,j,s,t){
 if(isbigger((s=gcd(a,b)),1) && isbigger((s=gcd(s,D)),1)){
  if(isprime(s))
   kome(PRIME,s,2*m)
  else
   kome(COMPOSITE,s,2*m)
  return _end_division(quotient(N,square(s)))
 }
 G[1]=a
 G[2]=b~/^-/?substr(b,2):("-" b)
 G[3]=multiple(a,c)
 printf("(%s,%s,%s)\n",G[1],G[2],G[3])  > "/dev/stderr"

 while(!isreducedQFp(G,D))
  rho(G,D)
 do{
  t=G[2]
  rho(G,D)
 }while(t!=G[2])
 printf("(%s,%s,%s)\n",G[1],G[2],G[3])  > "/dev/stderr"

 if(G[1]~/^-/)
  G[1]=substr(G[1],2)
 if(G[1]~/[02468]$/)
  G[1]=quotient2(G[1])
 if((g=gcd(G[1],quotient(D,N)))!=1)
  G[1]=quotient(G[1],g)

 if(G[1]!=1){
  if(isprime(G[1]))
   kome(PRIME,G[1],m)
  else
   kome(COMPOSITE,G[1],m)
  return _end_division(quotient(N,G[1]),m)
 }
 return 0
}
