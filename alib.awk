#
# Arithmetica H edition
# copyright Matsui Tetsushi 1995-1999
# last modified : 1999-10-10
# usage: igawk -f alib.awk [-f scripts] [data]
#

# include noapr.awk or apr.awk (exclusively)
#@include noapr.awk
@include apr.awk

# include nopfac.awk or pfac.awk (exclusively)
#@include nopfac.awk
@include pfac.awk

function _add(a,b, temp,retval,ax,bx,cx,l){
 if(length(a)<8 && length(b)<8)
  return a+b

 if(isbigger(b,a)){
  temp=a
  a=b
  b=temp
 }

 for(l=length(b);l>8;l=length(b)){
  bx=substr(b,l-7)
  b=substr(b,1,l-8)
  l=length(a)
  ax=substr(a,l-7)
  a=substr(a,1,l-8)
  cx=bx+ax
  if(length(cx)>8){
   cx-=100000000
   a=suc(a)
  }
  retval=sprintf("%08d%s",cx,retval)
 }
 if((l=length(a))>8){
  ax=substr(a,l-7)
  a=substr(a,1,l-8)
  cx=ax+b
  if(length(cx)>8){
   cx-=100000000
   retval=sprintf("%s%08d%s",suc(a),cx,retval)
  }
  else{
   retval=sprintf("%s%08d%s",a,cx,retval)
  }
 }
 else{
  cx=a+b
  retval=sprintf("%d%s",cx,retval)
 }
 sub(/^0*/,"",retval)
 return retval
}

function _multiple(a,b, retval,i,j,n,m,alen,blen,temp){
 if(!a || !b)return 0

 alen=length(a)
 for(n=0;alen>4;++n && alen-=4)
  ah[n]=substr(a,alen-3,4)
 ah[n]=substr(a,1,alen)
 blen=length(b)
 for(m=0;blen>4;++m && blen-=4)
  bh[m]=substr(b,blen-3,4)
 bh[m]=substr(b,1,blen)

 retval=0
 for(i=0;i<=(n+m);i++){
  temp=0
  for(j=(i>m?i-m:0);j<=(n<i?n:i);j++)
   temp=_add(temp,ah[j]*bh[i-j])
  for(j=0;j<i;j++)
   temp=temp "0000"
  retval=_add(retval,temp)
 }
 delete ah
 delete bh
 return retval
}

function _subtract(a,b, retval,ax,bx,cx,carry,flag,temp,alen,blen){
 if(isbigger(b,a)){
  temp=a
  a=b
  b=temp
  flag="-"
 }
 else
  flag=""
 while(b){
  alen=length(a)
  blen=length(b)
  if(blen>8){
   bx=substr(b,blen-7)
   b=substr(b,1,blen-8)
  }
  else{
   bx=b
   b=""
  }
  if(alen>8){
   ax=substr(a,alen-7)
   a=substr(a,1,alen-8)
  }
  else{
   ax=a
   a=""
  }
  cx=ax-bx-carry
  if(cx<0){
   cx+=100000000
   carry=1
  }
  else
   carry=0
  retval=sprintf("%08d%s",cx,retval)
 }
 if(carry)
  a=pred(a)
 retval=a retval
 sub(/^0*/,"",retval)
 if (!retval)
  return 0
 return(flag retval)
}

function add(a,b){
 if(a~/^-/){
  a=substr(a,2)
  if(b~/^-/){
   b=substr(b,2)
   return("-" _add(a,b))
  }
  else
   return _subtract(b,a)
 }
 else if(b~/^-/){
  b=substr(b,2)
  return _subtract(a,b)
 }
 return _add(a,b)
}

function dectobin(a, retval){
 while(a){
  retval=iseven(a)?"0":"1" retval
  a=quotient2(a)
 }
 return retval
}

function double(a, retval,ax,cx,carry,alen,flag){
 if(a~/^-/){
  a=substr(a,2)
  flag="-"
 }
 else
  flag=""
 
 if(!a) return 0
 
 carry=0
 while(a){
  alen=length(a)
  if(alen>8){
   ax=substr(a,alen-7,8)
   a=substr(a,1,alen-8)
  }
  else{
   ax=a
   a=""
  }
  cx=ax+ax+carry
  if(cx>99999999){
   carry=1
   cx-=100000000
  }
  else carry=0
  retval=sprintf("%08d%s",cx,retval)
 }
 if(carry)
  retval="1" retval
 else
  sub(/^0*/,"",retval)
 return(flag retval)
}

function factorial(a, retval,sz,seed,i){
 if(a~/^-/){
  print "Negative factorial base.(in function factorial)"
  return 0
 }
 sz=$0
 retval=1;seed=0
 while(getline<"fac.tbl" >0){
  if($1==a){
   retval=$2
   close("fac.tbl")
   $0=sz
   return retval
  }
  else{
   if($1+0>a+0)
    break
   seed=$1+0
   retval=$2
  }
 }
 close("fac.tbl")
 for(i=seed+1;i<=a;i++){
  retval=multiple(retval,i)
 }
 print a,retval >>"fac.tbl"
 $0=sz
 return retval
}

function fsqrt(a, b_old,b_new,temp){
 if(a~/^-/){
  print "Negative number is assigned.(in function fsqrt)"
  return 0
 }
 if(a==0 || a==1)
  return a
 b_old=a
 temp=length(a)
 if(temp<8)
  b_new=quotient2(a)
 else{
  if(temp%2){
   b_new=int(sqrt(substr(a,1,7)+0)+1)
   temp=int((temp-7)/2)
  }
  else{
   b_new=int(sqrt(substr(a,1,8)+0)+1)
   temp=int((temp-8)/2)
  }
  b_new=b_new zeros(temp)
 }
 while(isbigger(b_old,b_new)){
  b_old=b_new
  b_new=quotient2(_add(b_old,quotient(a,b_old)))
 }
 return b_old
}

function gcd(a,b, temp){
 if(!a && !b)
  return 0
 sub(/^-/,"",a)
 sub(/^-/,"",b)
 if(!a)
  return b
 if(!b)
  return a
 if(a==1 || b==1)
  return 1

 while(b){
  temp=mod(a,b)
  a=b
  b=temp
 }
 return a
}

function isbigger(a,b, alen,blen,ac,bc,i){
 if(a~/^-/)
  if(b~/^-/)
   return isbigger(substr(b,2),substr(a,2))
  else
   return 0
 else if(b~/^-/)
  return 1

 alen=length(a)
 blen=length(b)
 if(alen<blen)
  return 0
 if(alen>blen)
  return 1
 if(a "">b "")
  return 1
 return 0
}

function isprime(a, i,j1,j2,lga,limit,temp){
 if(isbigger("100000000",a))
  return isprime_trial_division(a)

 if(!spsp(a,2) || !spsp(a,3) || !spsp(a,5) || !spsp(a,7) || !spsp(a,11) || !spsp(a,13) || !spsp(a,17)) 
  return 0
 else if(isbigger("25000000000",a))
  return 1

 return isprime_APRCL(a)
}

function isprime_trial_division(a, i,j,k,r,temp){
 if(a~/^-/) a=substr(a,2)
 if(!a || a==1) return 0
 if(a==2 || a==3 || a==5) return 1
#2,5
 if(a~/[024685]$/) return 0
#3
 j=a;k=0
 gsub(/[0369]/,"",j)
 for(i=1;i<=length(j);i++)
  k=k+(substr(j,i,1)+0)
 if(!mod(k,3)) return 0
#less than 1000000
 r=fsqrt(a)
 while(getline i <"prime.tbl" >0){
  if(!mod(a,i)){
   close("prime.tbl")
   return 0
  }
  if(isbigger(i,r)){
   close("prime.tbl")
   return 1
  }
 }
 close("prime.tbl")
#more than 1000000
 j=2;k=4
 for(i=1000003;!isbigger(i,r);i=_add(i,j)){
  if(!mod(a,i)) return 0
  temp=j;j=k;k=temp
 }
 return 1
}

function isprime_wilson(a){
 if(a~/^-/) a=substr(a,2)
 if(!a) return 0
 return (_add(mod_factorial(pred(a),a),1)==a)
}

function issquare(a, i,r,q,q11,q63,q64,q65){
 for(i=0;i<32;i++)
  q64[i^2%64]=1
 if(!(mod(a,64) in q64)){
  delete q64
  return 0
 }
 delete q64
 
 r=mod(a,45045)
 for(i=0;i<32;i++)
  q63[i^2%63]=1
 if(!(r%63 in q63)){
  delete q63
  return 0
 }
 delete q63
  
 for(i=0;i<33;i++)
  q65[i^2%65]=1
 if(!(r%65 in q65)){
  delete q65
  return 0
 }
 delete q65

 for(i=0;i<6;i++)
  q11[i^2%11]=1
 if(!(r%11 in q11)){
  delete q11
  return 0
 }
 delete q11

 if(square(q=fsqrt(a))==a) return q
 else return 0
}

function lcm(a,b){
 return quotient(multiple(a,b),gcd(a,b))
}

function mod(a,b, ak,k,f){
 if(b~/^-/){
  print"Negative modulus.(in function mod)"
  return 0
 }
 if(!b){
  print"Division by zero.(in function mod)"
  return 0
 }
 if(b==2)
  return isodd(a)
 if(a~/^-/){
  a=substr(a,2)
  f=1
 }
 else
  f=0

 for(k=length(b);!isbigger(b,a);sub(/^0+/,"",a)){
  ak=substr(a,1,k)
  if(!isbigger(b,ak)){
   ak=_subtract(ak,b)
   while(!isbigger(b,ak))
    ak=_subtract(ak,b)
   sub(substr(a,1,k),ak,a)
  }
  else{
   ak=substr(a,1,k+1)
   ak=_subtract(ak,b)
   while(!isbigger(b,ak))
    ak=_subtract(ak,b)
   sub(substr(a,1,k+1),ak,a)
  }
 }
 if(f && a)
  return subtract(b,a)
 else
  return a
}

function mod_factorial(a,m, retval){
 if(a~/^-/){
  print "Negative factorial base.(in function mod_factorial)"
  return 0
 }
 if(!a)
  return(m==1?0:1)
 retval=1
 for(i=1;!isbigger(i,a);i=suc(i))
  retval=mod_multiple(retval,i,m)
 return retval
}

function mod_fsqrt(a,m, i,am,p,q,r,s,t,step){
 if(m~/^-/){
  print "Negative Modulus.(in function mod_fsqrt)"
  return 0
 }
 if(!m){
  print "Division by zero.(in mod_fsqrt)"
  return 0
 }
 if(m==1)
  return 0

 am=mod(a,m)
 if(!am || am==1)
  return am
 if(issquare(am))
  return fsqrt(am)

 if(isprime(m))
  return _modp_fsqrt(am,m)

 getline p < "prime.tbl" # ignore 2
 # easy check
 if(!mod(m,4))
  if(mod(am,4)==2 || mod(am,4)==3)
   return _mod_fsqrt_noroot(a,m)
  else{
   t=mod(am,4)
   step=4
  }
 else{
  t=0
  step=1
 }
 while(getline p < "prime.tbl" >0 && isbigger(m,p)){
  if(mod(m,p))
   continue
  if(!mod(am,p)){
   while(mod(t,p))
    t=add(t,step)
   step=multiple(step,p)
   continue
  }
  if(s=_modp_fsqrt(am,p)){
   while(mod(t,p)!=s)
    t=add(t,step)
   step=multiple(step,p)
  }
  else{
   close("prime.tbl")
   return _mod_fsqrt_noroot(am,m)
  }
 }
 close("prime.tbl")
 for(i=t;isbigger(m,i);i=add(i,step)){
  if(mod(square(i),m)==am)
   return i
 }
 close("prime.tbl")
 return _mod_fsqrt_noroot(a,m)
}

function _mod_fsqrt_noroot(a,m){
 print "There is no square root of",a,"mod",m
 return 0
}

function _modp_fsqrt(a,p, i,q,r,s,t,u,v,w,x,e,n,y,z,b,m){
 if(Legendre(a,p)==1){
  if(mod(p,4)==3)
   return mod_power(a,quotient(suc(p),4),p)
  else if(mod(p,8)==5)
   if(mod_power(a,quotient(pred(p),4),p)==1)
    return mod_power(a,quotient(add(p,3),8),p)
   else
    return mod(multiple(double(a),mod_power(multiple(4,a),quotient(subtract(p,5),8),p)),p)
  else{ #Algorithm1.5.1
   q=quotient(pred(p),8)
   for(r=3;iseven(q);r=suc(r))
    q=quotient2(q)
   for(n=2;Legendre(n,p)==1;n=suc(n));
   y=mod_power(n,q,p)
   x=mod_power(a,quotient2(pred(q)),p)
   b=mod_multiple(a,square(x),p)
   x=mod_multiple(a,x,p)
   while(b!=1){
    s=b
    for(m=0;s!=1;m=suc(m))
     s=mod_square(s,p)
    u=pred(subtract(r,m))
    for(i=0;isbigger(u,i);i=suc(i))
     y=mod_square(y,p)
    r=m
    x=mod_multiple(x,y,p)
    y=mod_square(y,p)
    b=mod_multiple(b,y,p)
   }
   return x
  }
 }
 else
  return _mod_fsqrt_noroot(a,p)
}

function mod_inverse(a,m, mt){
 if(!a){
  printf("%s is not invertible in modulo %s.\n",a,m)
  return 0
 }
 if(a==1)
  return 1
 mt=mod_inverse(mod(m,a),a)
 return mod(quotient(subtract(1,multiple(mt,m)),a),m)
}

function mod_multiple(a,b,m){
 return mod(multiple(mod(a,m),mod(b,m)),m)
}

function mod_power(a,b,m, retval,k){
 if(b~/^-/){
  b=substr(b,2)
  a=mod_inverse(a,m)
 }
 else
  a=mod(a,m)
 retval=1
 if(b) for(;;){
  if(isodd(b))
   retval=mod(multiple(retval,a),m)
  b=quotient2(b)
  if(!b) break;
  a=mod_square(a,m)
 }
 return retval
}

function mod_quotient(a,b,m){
 return mod(quotient(a,b),m)
}

function mod_square(a,m, retval){
 a=mod(a,m)
 if(isbigger(a,quotient2(m))) a=_subtract(m,a)
 return mod(square(a),m)
}

function multiple(a,b, f,t,alen,blen,au,al,bu,bl,p1,p2,p3,kt,l){
 f=0
 if(a~/^-/){
  a=substr(a,2)
  f++
 }
 if(b~/^-/){
  b=substr(b,2)
  f++
 }
 if(f==1)
  f="-"
 else
  f=""
 if(isbigger(b,a)){
  t=a;a=b;b=t
 }

 if(!b)
  return 0
 if(b==1)
  return(f a)
 alen=length(a)
 if(alen<=80)
  return(f _multiple(a,b))

 l=alen-int(alen/2)
 au=substr(a,1,alen-l)
 al=substr(a,alen-l+1)
 blen=length(b)
 if(blen<=l){
  bu=0
  bl=b
 }
 else{
  bu=substr(b,1,blen-l)
  bl=substr(b,blen-l+1)
 }
 sub(/^0+/,"",al); sub(/^0+/,"",bl)
 p1=multiple(au,bu)
 p2=multiple(_subtract(al,au),_subtract(bl,bu))
 p3=multiple(al,bl)
 kt=zeros(l)
 p2=subtract(_add(p1,p3),p2) kt
 p1=p1 kt kt
 return(f add(add(p1,p2),p3))
}

function normalize(a, flag){
 if(a~/^-/){
  a=substr(a,2);
  flag="-";
 }
 else flag=""
 sub(/^0+/,"",a)
 if(!a)
  return 0
 return(flag a)
}

function power(a,b, retval){
 if(b~/^-/)
  return 0
 retval=1
 if(b) for(;;){
  if(isodd(b))
   retval=multiple(retval,a)
  b=quotient2(b)
  if(!b) break;
  a=square(a)
 }
 return retval
}

function primitive_root(p, f,g,ppred,q){
 if(p==3 || p==5 || p==11)
  return 2
 if(p==7)
  return 3
 for(g=2;g<p;g++){
  if(Legendre(g,p)==1) continue
  ppred=pred(p)
  while(iseven(ppred))
   ppred=quotient2(ppred)
  f=2
  for(q=3;isbigger(ppred,1);q+=2){
   if(mod(ppred,q)) continue
   while(!mod(ppred,q))
    ppred=quotient(ppred,q)
   if(mod_power(g,quotient(pred(p),q),p)==1){
    f=1
    break
   }
  }
  if(f==1) continue
  return g
 }
}

function psp(n,a){
 a=mod(a,n)
 if(gcd(n,a)!=1) return 0
 if(mod_power(a,pred(n),n)==1) return 1
 else return 0
}

function quotient(a,b, retval,k,f,temp,ak,n,keta){
 if(!b){
  print "Division by zero.(in function quotient)"
  return 0
 }

 f=0
 if(a~/^-/){
  a=substr(a,2)
  f++
 }
 if(b~/^-/){
  b=substr(b,2)
  f++
 }
 if(f==1)
  f="-"
 else
  f=""
 
 retval=0
 k=length(b)
 keta=zeros(length(a)-k)
 while(!isbigger(b,a)){
  ak=substr(a,1,k)
  n=length(a)-k
  keta=substr(keta,1,n)
  for(temp=0;!isbigger(b,ak);temp++)
   ak=_subtract(ak,b)
  if(temp){
   temp=temp keta
   retval=_add(retval,temp)
   sub(substr(a,1,k),ak,a)
  }
  else{
   ak=substr(a,1,k+1)
   ak=_subtract(ak,b)
   temp="1" keta
   temp=substr(temp,1,n)
   retval=_add(retval,temp)
   sub(substr(a,1,k+1),ak,a)
  }
  sub(/^0+/,"",a)
 }
 return(f retval)
}

function quotient2(a, flag,retval,k1,k2){
 if(length(a)<8)
  return int(a/2)

 if(a~/^-/){
  a=substr(a,2)
  flag="-"
 }
 else
  flag=""

 k1=k2=a
 gsub(/1/,"0",k1)
 gsub(/[23]/,"1",k1)
 gsub(/[45]/,"2",k1)
 gsub(/[67]/,"3",k1)
 gsub(/[89]/,"4",k1)
 gsub(/[2468]/,"0",k2)
 gsub(/[1379]/,"5",k2)
 k2=substr(k2,1,length(k2)-1)
 retval=_add(k1,k2)
 return(flag retval)
}

function spsp(n,b,p, c,i,j,m,r){
 if(!b) b=2
 else{
  b=mod(b,n)
  if(b==0) return -1
  if(gcd(n,b)!=1) return 0
 }
 if(!p) p=2
 if(p==2){
  m=pred(n)
  for(c=0;iseven(m);c++)
   m=quotient2(m)
  b=mod_power(b,m,n)
  if(b==1) return 1
  for(i=0;i<c;i++){
   if(suc(b)==n) return 1
   b=mod(square(b),n)
  }
 }
 else{
  m=pred(n)
  for(c=0;!mod(m,p);c++)
   m=quotient(m,p)
  b=mod_power(b,m,n)
  if(b==1) return 1
  for(i=0;i<c;i++){
   r=suc(b)
   for(j=2;j<p;j++)
    r=suc(mod_multiple(b,r,n))
   if(r==n) return 1
   b=suc(mod(multiple(pred(b),r),n))
  }
 }
 return 0
}

function square(a, alen,temp,keta,a1,a2,retval){
 sub(/^-?0*/,"",a)
 alen=length(a)
 if(alen<=80)
  return _multiple(a,a)
 temp=int(alen/2)
 keta=zeros(alen-temp)
 a1=substr(a,1,temp)
 a2=substr(a,temp+1)
 retval=square(a1) keta keta
 retval=_add(retval,double(multiple(a1,a2)) keta)
 retval=_add(retval,square(a2))
 return retval
}

function subtract(a,b){
 if(a~/^-/){
  a=substr(a,2)
  if(b~/^-/){
   b=substr(b,2)
   return _subtract(b,a)
  }
  else
   return("-" _add(a,b))
 }
 else if(b~/^-/){
  b=substr(b,2)
  return _add(a,b)
 }
 return _subtract(a,b)
}

function suc(a, alen,b,blen){
 if((alen=length(a))<8)
  return a+1

 if(a~/^-/)
  return "-" pred(substr(a,2))
 b=a
 if(b~/^9+$/){
  b="1" b
  gsub(/9/,"0",b)
 }
 else{
  sub(/9*$/,"",b)
  sub(/.$/,substr(b,length(b),1)+1,b)
  b=b zeros(alen-length(b))
 }
 return b
}

function zeros(n, z,s){
 z="0"
 s=""
 while(n){
  if(n%2)
   s=s z
  z=z z
  n=int(n/2)
 }
 return s
}

function cubrt(a, b_new,b_old,flag){
 if(a~/^-/){
  a=substr(a,2)
  flag="-"
 }
 else
  flag=""
 if(a==0)
  return a
 if(isbigger(8,a))
  return(flag "1")

 b_old=a
 b_new=fsqrt(a)
 while(isbigger(b_old,b_new)){
  b_old=b_new
  b_new=quotient(_add(double(b_old),quotient(a,square(b_old))),3)
 }
 return(flag b_old)
}

function pred(a, alen,b,n,z){
 if((alen=length(a))<8)
  return a-1

 if(a~/^-/)
  return "-" suc(substr(a,2))
 b=a
 if(b~/^10+$/){
  b=substr(b,2)
  gsub(/0/,"9",b)
 }
 else{
  sub(/0*$/,"",b)
  sub(/.$/,substr(b,length(b))-1,b)
  z="9"
  n=alen-length(b)
  while(n){
   if(n%2)
    b=b z
   z=z z
   n=int(n/2)
  }
 }
 return b
}

function prev(a){
 return pred(a)
}

function Legendre(a,p, j,m,r,t){
 a=mod(a,p)
 j=1
 while(a){
  for(t=0;iseven(a);t++)
   a=quotient2(a)
  if(isodd(t)){
   m=mod(p,8)
   if(m==3 || m==5)
    if(j==1)
     j=-1
    else
     j=1
  }
  if(mod(a,4)==3 && mod(p,4)==3){
   if(j==1)
    j=-1
   else
    j=1
  }
  r=a
  a=mod(p,r)
  p=r
 }
 if(p==1)
  return j
 else
  return 0
}

function iseven(n){
 return(n~/[02468]$/)
}

function isodd(n){
 return(n~/[13579]$/)
}
