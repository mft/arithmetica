#
# pfac.awk ver.0.1
#

function factorize(a, j,m,n){
 PRIME=1
 COMPOSITE=0
 if(a~/^-/){
  a=substr(a,2)
  kome(PRIME,-1,1)
 }
 if(isprime(a)){
  kome(PRIME,a,1)
  return 1
 }
 if(length(a)<8)
  return trial_division(a)
 else{
  j=trial_division(a,1,1000)
  while(n=nuki(cfactor)){
   m=cpower[n]
   j=SQUFOF(n,m)
   delete cpower[n]
  }
  return j
 }
}

function trial_division(a, b,pmax, i,j,m,n,s,temp,c3,c5,c7){
 if(!b)
  b=1
 if(!pmax)
  pmax=fsqrt(a)

#2
 if(isbigger(2,pmax))
  return _end_division(a)
 if(!mod(a,2)){
  a=quotient2(a)
  for(j=1;!mod(a,2);a=quotient2(a))
   j++
  kome(PRIME,2,j)
  if(isbigger(pmax,(temp=fsqrt(a))))
   pmax=temp
 }

#3
 if(isbigger(3,pmax))
  return _end_division(a)
 j=0
 temp=a
 for(;;){
  s=0
  for(i=1;i<=length(temp);i++)
   s+=substr(temp,i,1)+0
  if(!(s%3)){
   temp=a=quotient(a,3)
   j++
  }
  else break
 }
 if(isbigger(pmax,(temp=fsqrt(a)))) pmax=temp
 if(j)
  kome(PRIME,3,j)

#5
 if(isbigger(5,pmax))
  return _end_division(a)
 if(a~/5$/){
  a=quotient(a,5)
  for(j=1;a~/5$/;a=quotient(a,5))
   j++
  kome(PRIME,5,j)
  if(isbigger(pmax,(temp=fsqrt(a)))) pmax=temp
 }

#more than 7
 getline i <"prime.tbl" #2
 getline i <"prime.tbl" #3
 getline i <"prime.tbl" #5
 while(!isbigger(i,pmax)){
  if(!(mod(a,i))){
   a=quotient(a,i)
   for(j=1;!(mod(a,i));a=quotient(a,i))
    j++
   kome(PRIME,i,j)
   if(isbigger(pmax,(temp=fsqrt(a)))) pmax=temp
  }
  if(!(getline i <"prime.tbl"))
   break
  printf("%d\r", i) > "/dev/stderr"
 }
 close("prime.tbl")
 i=1000003
 c3=2;c5=4;c7=2
 while(!isbigger(i,pmax)){
  if(c3!=3){
   if(c5!=5){
    if(c7!=7)
     if(!(mod(a,i))){
      a=quotient(a,i)
      for(j=1;!(mod(a,i));a=quotient(a,i))
       j++
      kome(PRIME,i,j)
      if(isbigger(pmax,(temp=fsqrt(a)))) pmax=temp
     }
    else c7=0
   }
   else{
    c5=0
    if(c7==7) c7=0
   }
  }
  else{
   c3=0
   if(c5==5) c5=0
   if(c7==7) c7=0
  }
  i=_add(i,2)
  c3++;c5++;c7++
 }
 return _end_division(a,1)
}

function _end_division(n, i){
 if(!i)
  i=1
 if(isprime(n))
  kome(PRIME,n,i)
 else
  kome(COMPOSITE,n,i)
 return list_len(pfactor)
}

function kome(type,item,sup){
 if(type==PRIME){
  pfactor[item]=item
  ppower[item]+=sup
 }
 else{
  cfactor[item]=item
  cpower[item]+=sup
 }
}

function nuki(list, item,sup){
 for(sup in list){
  item=list[sup]
  delete list[sup]
  return item
 }
 return 0
}

function list_len(list, i,j){
 j=0
 for(i in list)
  ++j
 return j
}

@include SQUFOF.awk
