# functions for APR algorithm
# version: 1.1
# last modified: 1999-10-10

function zeta(pk,e, i,z){
 e=mod(e,pk)
 if(e==0 ||!e) e=pk
 z[e]="1"
 return z2str(z,pk)
}

function zadd(z1,z2, i,z,m,m1,m2,s,z1_a,z2_a,zr_a){
 m1=split(z1,z1_a)
 m2=split(z2,z2_a)
 if(m1==m2){
  m=m1
  for(i=1;i<=m;i++)
   zr_a[i]=add(z1_a[i],z2_a[i])
  delete z1_a
  delete z2_a
  return z2str(zr_a,m)
 }
 else{
  m=lcm(m1,m2)
  delete z1_a
  delete z2_a
  return zadd(promote(z1,m),promote(z2,m))
 }
}

function zmodpower(z,e,h,p, r){
 if(e==0)
  return 1
 z=zmodreduction(z,h,p)
 while(iseven(e)){
  e=quotient2(e)
  z=zmodsquare(z,h,p)
 }
 r=z
 e=quotient2(e)
 if(e){
  z=zmodsquare(z,h,p)
  for(;;){
   if(isodd(e))
    r=zmodmultiple(r,z,h,p)
   e=quotient2(e)
   if(!e) break;
   if(p!=2)
    z=zmodsquare(z,h,p)
   else
    z=zmodsquare2(z,h)
  }
 }
 return r
}

function zmultiple(z1,z2,p, i,k,m,m1,m2,z1_m,z2_m,zr_m){
 m1=split(z1,z1_m)
 m2=split(z2,z2_m)
 if(m1==1){
  delete z1_m[1]
  for(i=1;i<=m2;i++)
   zr_m[i]=multiple(z1,z2_m[i])
  delete z2_m
  return z2str(zr_m,m2)
 }
 else if(m2==m1){
  m=m1
  for(k=1;k<=m;k++){
   zr_m[k]="0"
#   for(i in z1_m){
#    if(i<k && z2_m[k-i])
#     zr_m[k]=add(multiple(z1_m[i],z2_m[k-i]),zr_m[k])
#    else if(i>=k && z2_m[m+k-i])
#     zr_m[k]=add(multiple(z1_m[i],z2_m[m+k-i]),zr_m[k])
#   }
   for(i=1;i<k;i++)
    if(z1_m[i] && z2_m[k-i])
     zr_m[k]=add(zr_m[k],multiple(z1_m[i],z2_m[k-i]))
   for(i=k;i<=m;i++)
    if(z1_m[i] && z2_m[m+k-i])
     zr_m[k]=add(zr_m[k],multiple(z1_m[i],z2_m[m+k-i]))
  }
  delete z1_m
  delete z2_m
  return z2str(zr_m,m)
 }
 else{
  m=lcm(m1,m2)
  delete z1_m
  delete z2_m
  return zmultiple(promote(z1,m),promote(z2,m),p)
 }
}

function zmodmultiple(z1,z2,h,p, i,k,m,m1,m2,z1_mm,z2_mm,zr_mm){
 m1=split(z1,z1_mm)
 m2=split(z2,z2_mm)
 if(m1==1){
  delete z1_mm[1]
  z1=mod(z1,h)
  for(i=1;i<=m2;i++)
   zr_mm[i]=mod_multiple(z1,z2_mm[i],h)
  delete z2_mm
  return z2str(zr_mm,m2)
 }
 else if(m2==m1){
  m=m1
  for(k=1;k<=m;k++){
   zr_mm[k]="0"
   for(i=1;i<k;i++)
    if(z1_mm[i] && z2_mm[k-i])
     zr_mm[k]=add(zr_mm[k],multiple(z1_mm[i],z2_mm[k-i]))
   for(i=k;i<=m;i++)
    if(z1_mm[i] && z2_mm[m+k-i])
     zr_mm[k]=add(zr_mm[k],multiple(z1_mm[i],z2_mm[m+k-i]))
   zr_mm[k]=mod(zr_mm[k],h)
  }
  delete z1_mm
  delete z2_mm
  return z2str(zr_mm,m)
 }
 else{
  m=lcm(m1,m2)
  delete z1_m
  delete z2_m
  return zmodmultiple(promote(z1,m),promote(z2,m),h,p)
 }
}

function zreduction(z,p, i,j,m,min,mp,z_red){
 m=split(z,z_red)
 mp=m/p
 if(p==2)
  for(i=1;i<=mp;i++)
   if(isbigger(z_red[i],z_red[i+mp])){
    z_red[i]=subtract(z_red[i],z_red[i+mp])
    z_red[i+mp]=0
   }
   else{
    z_red[i+mp]=subtract(z_red[i+mp],z_red[i])
    z_red[i]=0
   }
 else
  for(i=1;i<=mp;i++){
   min=z_red[i]
   for(j=mp+i;j<=m;j+=mp)
    if(isbigger(min,z_red[j]))
     min=z_red[j]
   if(min)
    for(j=i;j<=m;j+=mp)
     z_red[j]=subtract(z_red[j],min)
  }
 return z2str(z_red,m)
}

function zmodreduction(z,h,p, dif,h2,i,j,m,max,min,mp,neg,z_mr){
 m=split(z,z_mr)
 for(i=1;i<=m;i++)
  z_mr[i]=mod(z_mr[i],h)
 mp=m/p
 for(i=1;i<=mp;i++){
  max=min=z_mr[i]
  for(j=mp+i;j<=m;j+=mp){
   if(isbigger(z_mr[j],max))
    max=z_mr[j]
   else if(isbigger(min,z_mr[j]))
    min=z_mr[j]
  }
  neg=subtract(h,max)
  dif=subtract(max,min)
  if(isbigger(dif,neg)){
   for(j=i;j<=m;j+=mp){
    if(z_mr[j]!=max)
     z_mr[j]=add(z_mr[j],neg)
    else
     z_mr[j]=0
   }
  }
  else{
   if(min)
    for(j=i;j<=m;j+=mp)
     z_mr[j]=subtract(z_mr[j],min)
  }
 }
 return z2str(z_mr,m)
}

function zsquare(z,p, i,j,k,limit,m,m2,z_sq,zr_sq){
 z=zreduction(z,p)
 m=split(z,z_sq)
 m2=int(m/2)
 for(i=1;i<=m2;i++){
  if(!z_sq[i]) continue
  k=2*i
  zr_sq[k]=add(square(z_sq[i]),zr_sq[k])
  for(j=i+1;j<=m;j++){
   if(!z_sq[j]) continue
   k=i+j
   if(k>m) k-=m
   zr_sq[k]=add(double(multiple(z_sq[i],z_sq[j])),zr_sq[k])
  }
 }
 for(i=m2+1;i<=m;i++){
  if(!z_sq[i]) continue
  k=2*i-m
  zr_sq[k]=add(square(z_sq[i]),zr_sq[k])
  for(j=i+1;j<=m;j++){
   if(!z_sq[j]) continue
   k=i+j-m
   zr_sq[k]=add(double(multiple(z_sq[i],z_sq[j])),zr_sq[k])
  }
 }
 delete z_sq
 return z2str(zr_sq,m)
}

function zmodsquare(z,h,p, i,j,k,m,z_msq,zr_msq){
 z=zmodreduction(z,h,p)
 m=split(z,z_msq)
 m2=int(m/2)
 for(i=1;i<=m2;i++){
  if(!z_msq[i]) continue
  zr_msq[2*i]=add(square(z_msq[i]),zr_msq[2*i])
  for(j=i+1;j<=m;j++){
   if(!z_msq[j]) continue
   k=i+j
   if(k>m) k-=m
   zr_msq[k]=add(double(multiple(z_msq[i],z_msq[j])),zr_msq[k])
  }
 }
 for(i=m2+1;i<=m;i++){
  if(!z_msq[i]) continue
  k=2*i-m
  zr_msq[k]=add(square(z_msq[i]),zr_msq[k])
  for(j=i+1;j<=m;j++){
   if(!z_msq[j]) continue
   k=i+j-m
   zr_msq[k]=add(double(multiple(z_msq[i],z_msq[j])),zr_msq[k])
  }
 }
 for(i=1;i<=m;i++)
  zr_msq[i]=mod(zr_msq[i],h)
 delete z_msq
 return z2str(zr_msq,m)
}

function zmodsquare2(z,h, i,j,k,m,z_msq,zr_msq){
 m=split(z,z_msq)
 m2=quotient2(m)
 for(i=1;i<=m2;i++)
  z_msq[i]=mod(subtract(z_msq[i],z_msq[i+m2]),h)
 for(i=1;i<=m2;i++){
  if(!z_msq[i]) continue
  k=2*i
  zr_msq[k]=add(square(z_msq[i]),zr_msq[k])
  for(j=i+1;j<=m2;j++){
   if(!z_msq[j]) continue
   k=i+j
   zr_msq[k]=add(double(multiple(z_msq[i],z_msq[j])),zr_msq[k])
  }
 }
 for(i=1;i<=m;i++)
  zr_msq[i]=mod(zr_msq[i],h)
 delete z_msq
 return z2str(zr_msq,m)
}

function promote(z,pk, i,n,r,z_pr,zr_pr){
 n=split(z,z_pr)
 if(pk==n){
  delete z_pr
  return z
 }
 r=pk/n
 for(i=1;i<=n;i++)
  zr_pr[i*r]=z_pr[i]
 delete z_pr
 return z2str(zr_pr,pk)
}

function findt_APRCL(b, rb,l,s_APR){
 rb=suc(fsqrt(b))
 while(getline l<"et.tbl" >0){
  split(l,s_APR)
  if(isbigger(s_APR[2],rb)){
   delete s_APR
   close("et.tbl")
   return l
  }
 }
 delete s_APR
 close("et.tbl")
 print "Run et.awk for a while please." > "/dev/stderr"
 exit
}

function precomp_APRCL(et, c,i,l,q,t_pre){
 while(getline l<"jacobi.dat" >0){
  split(l,t_pre,"\t")
  J[t_pre[1]]=t_pre[2]
  delete t_pre
 }
 close("jacobi.dat")
 while(getline l<"jacobi2.dat" >0){
  split(l,t_pre,"\t")
  J2[t_pre[1]]=t_pre[2]
  delete t_pre
 }
 close("jacobi2.dat")
 while(getline l<"jacobi3.dat" >0){
  split(l,t_pre,"\t")
  J3[t_pre[1]]=t_pre[2]
  delete t_pre
 }
 close("jacobi3.dat")
 c=et
 while(iseven(c))
  c=quotient2(c)
 for(q=3;c!=1;q+=2){
  if(mod(c,q)) continue
  for(c=quotient(c,q);!mod(c,q);c=quotient(c,q));
  if(!((2,q) in J))
   Jacobi_sum(q)
 }
}

function makef_APRCL(q, g,i,j,qpred,g_mf){
 g=primitive_root(q)
 qpred=pred(q)
 g_mf[1]=g
 for(i=2;isbigger(qpred,i);i=suc(i))
  g_mf[i]=mod_multiple(g_mf[i-1],g,q)
 for(i=1;isbigger(qpred,i);i=suc(i)){
  if(i in f_APRCL) continue
  for(j=1;pred(add(g_mf[j],g_mf[i]))!=q;j=suc(j));
  f_APRCL[i]=j
  f_APRCL[j]=i
  f_APRCL[subtract(qpred,i)]=mod(add(subtract(j,i),quotient2(qpred)),qpred)
  f_APRCL[f_APRCL[subtract(qpred,i)]]=subtract(qpred,i)
  f_APRCL[subtract(qpred,j)]=mod(add(subtract(i,j),quotient2(qpred)),qpred)
  f_APRCL[f_APRCL[subtract(qpred,j)]]=subtract(qpred,j)
 }
 delete g_mf
}

function Jacobi_sum(q, j,k,qt,qpred,p,pk){
 makef_APRCL(q)
 qt=qpred=pred(q)
 p=2
 for(k=0;!(qt%2);k++)
  qt/=2
 if(k>=2){
  pk=power(2,k)
  if(!((2,q) in J)){ 
   J[2,q]=zeta(pk,suc(f_APRCL[1]))
   for(j=2;isbigger(qpred,j);j=suc(j))
    J[2,q]=zadd(J[2,q],zeta(pk,add(j,f_APRCL[j])))
   J[2,q]=zreduction(J[2,q],2)
  }
  if(k>=3){
   if(!(q in J3)){
    J3[q]=zeta(pk,add(2,f_APRCL[1]))
    for(j=2;isbigger(qpred,j);j=suc(j))
     J3[q]=zadd(J3[q],zeta(pk,add(double(j),f_APRCL[j])))
    J3[q]=zreduction(zmultiple(J[2,q],J3[q],2),2)
   }
   if(!(q in J2)){
    J2[q]=zeta(8,add(3,f_APRCL[1]))
    for(j=2;isbigger(qpred,j);j=suc(j))
     J2[q]=zadd(J2[q],zeta(8,add(multiple(j,3),f_APRCL[j])))
    J2[q]=zreduction(zsquare(J2[q],2),2)
   }
  }
 }
 else J[2,q]=1
 for(p=3;p<=qt;p+=2){
  if(qt%p) continue
  for(k=0;!(qt%p);k++)
   qt/=p
  pk=power(p,k)
  if(!((p,q) in J)){
   J[p,q]=zeta(pk,suc(f_APRCL[1]))
   for(j=2;isbigger(qpred,j);j=suc(j))
    J[p,q]=zadd(J[p,q],zeta(pk,add(j,f_APRCL[j])))
   J[p,q]=zreduction(J[p,q],p)
  }
 }
 delete f_APRCL
}

function isprime_APRCL(n, et,k,p,q,qpred,r,t,tt,v,w_APR){
 #Assume n is spsp for more than 20 bases.
 v=findt_APRCL(n)
 split(v,w_APR)
 t=w_APR[1]
 et=w_APR[2]
 delete w_APR
 if(gcd(multiple(t,et),n)!=1) return 0
 precomp_APRCL(et)
 tt=t
 if(iseven(tt)){
  L[2]=0
  for(tt=quotient2(tt);iseven(tt);tt=quotient2(tt));
 }
 for(p=3;isbigger(tt,1);p+=2){
  if(mod(tt,p)) continue
  if(mod_power(n,pred(p),square(p))!=1)
   L[p]=1
  else
   L[p]=0
  for(tt=quotient(tt,p);!mod(tt,p);tt=quotient(tt,p));
 }
 for(v in J){
  split(v,w_APR,SUBSEP)
  p=w_APR[1]
  q=w_APR[2]
  delete w_APR
  qpred=pred(q)
  if(mod(t,qpred)) continue
  if(p!=2){
   if(!sub4a(p,q,n)){
    free()
    return 0
   }
  }
  else{
   for(k=0;iseven(qpred);k++)
    qpred=quotient2(qpred)
   if(k==1){
    if(!sub4d(q,n)){
     free()
     return 0
    }
   }
   else if(k==2){
    if(!sub4c(q,n)){
     free()
     return 0
    }
   }
   else{
    if(!sub4b(q,k,n)){
     free()
     return 0
    }
   }
  }
 }
 for(p in L)
  if(!L[p]){
   r=sub5(p,n,et)
   if(!r){
    free()
    return 0
   }
   else if(r==-1){
    free()
    print "Failed." > "/dev/stderr"
    exit
   }
  }
 r=n
 for(i=1;i<t;i++){
  r=mod(multiple(r,n),et)
  if(!mod(n,r) && r!=1 && r!=n){
   printf("%s divide %s\n",r,n) > "/dev/stderr"
   free()
   return 0
  }
 }
 free()
 return 1
}

function sub4a(p,q,n, c,g,i,j,m,mp,s,sx,t,tx,x,j_z){
#debug
printf("a %s %s ->",p,q)>"/dev/stderr"
 m=split(J[p,q],j_z)
 s=J[p,q]
 for(x=2;x<m;x++){
  if(!mod(x,p)) continue
  sx=""
  for(i=x;i>0;i=(i+x)%m)
   sx=sprintf("%s %d",sx,j_z[i])
  sx=sprintf("%s %d",sx,j_z[m])
  sx=zmodpower(sx,x,n,p)
  s=zmodmultiple(s,sx,n,p)
 }
 s=zmodpower(s,quotient(n,m),n,p)
 r=mod(n,m)
 t=1
 for(x=1;x<m;x++){
  if(!mod(x,p)) continue
  c=int((r*x)/m)
  if(c){
   tx=""
   for(i=x;i>0;i=(i+x)%m)
    tx=sprintf("%s %d",tx,j_z[i])
   tx=sprintf("%s %d",tx,j_z[m])
   tx=zmodpower(tx,c,n,p)
   t=zmodmultiple(t,tx,n,p)
  }
 }
 delete j_z
 s=zmodreduction(zmultiple(t,s,p),n,p)
#debug
print s>"/dev/stderr"
 for(i=1;i<=m;i++){
  if(zeta(m,i)==s){
   if(gcd(m,i)==1)
    L[p]=1
   return 1
  }
 }
 return 0
}

function sub4b(q,k,n, c,i,j,m,r,s,step,x,j3_z,sx_z,z_4b){
#debug
printf("b %s ->",q)>"/dev/stderr"
 m=split(J3[q],j3_z) # m=2^k
 s=J3[q]
 step=2
 for(x=3;isbigger(m,x);x=add(x,step)){
  j=0
  for(i=x;isbigger(i,0);i=mod(add(i,x),m))
   z_4b[++j]=j3_z[i]
  z_4b[++j]=j3_z[m]
  sx_z[x]=z2str(z_4b,m)
  s=zmultiple(zmodpower(sx_z[x],x,n,2),s,2)
  step=subtract(8,step)
 }
 delete j3_z

 s=zmodpower(s,quotient(n,m),n,2)

 r=mod(n,m)
 step=2
 for(x=3;isbigger(m,x);x=add(x,step)){
  c=multiple(r,x)
  if(isbigger(c,m))
   s=zmultiple(zmodpower(sx_z[x],quotient(c,m),n,2),s,2)
  step=subtract(8,step)
 }
 r=mod(r,8)
 if(r==5 || r==7)
  s=zmultiple(promote(J2[q],m),s,2)
 s=zmodreduction(s,n,2)
 delete sx_z

#debug
printf("%s\n",s) >"/dev/stderr"

 for(i=1;!isbigger(i,m);i=suc(i)){
  if(zeta(m,i)==s){
   if(gcd(m,i)==1)
    if(mod_power(q,quotient2(pred(n)),n)==pred(n))
     L[2]=1
   return 1
  }
 }
 return 0
}

function sub4c(q,n, i,j,j2,s,z_4c){
#debug
printf("c %s ->",q)>"/dev/stderr"
 j2=zmodsquare2(J[2,q],n)
 s=zmodmultiple(q,j2,n,2)
 s=zmodpower(s,quotient(n,4),n,2)
 if(mod(n,4)==3)
  s=zmodmultiple(s,j2,n,2)
 s=zmodreduction(s,n,2)
#debug
print s>"/dev/stderr"
 for(i=1;i<=4;i++){
  if(zeta(4,i)==s){
   if((i==1 || i==3) && mod_power(q,quotient2(pred(n)),n)==pred(n))
    L[2]=1
   return 1
  }
 }
 return 0
}

function sub4d(q,n, s){
#debug
printf("d %s -> ",q) >"/dev/stderr"
 s=mod_power(subtract(n,q),quotient2(pred(n)),n)
#debug
print s >"/dev/stderr"
 if(s==pred(n)){
  if(mod(n,4)==1)
   L[2]=1
 }
 else if(s!=1)
  return 0
 return 1
}

function sub5(p,n,et, c,i,j,g,k,q,qpred,step){
 c=0
 step=(p==2?2:p*2)
 for(q=step+1;L[p]==0 && c<20;q+=step){
  if(!isprime(q) || !mod(et,q)) continue
  if(!mod(n,q))
   return 0
  if(!((2,q) in J))
   Jacobi_sum(q)
  if(p!=2){
   if(!sub4a(p,q,n))
    return 0
  }
  else{
   qpred=pred(q)
   for(k=0;iseven(qpred);k++)
    qpred=quotient2(qpred)
   if(k==1){
    if(mod(n,4)==1 && !sub4d(q,n))
     return 0
   }
   else if(k==2){
    if(!sub4c(q,n))
     return 0
   }
   else
    if(!sub4b(q,k,n))
     return 0
  }
  c++
 }
 return L[p]==1?1:-1
}

function free( i,o){
 o=OFS
 OFS="\t"
 for(i in J)
  print i,J[i] >"jacobi.dat"
 delete J
 close("jacobi.dat")
 for(i in J2)
  print i,J2[i] >"jacobi2.dat"
 delete J2
 close("jacobi2.dat")
 for(i in J3)
  print i,J3[i] >"jacobi3.dat"
 delete J3
 close("jacobi3.dat")
 delete L
 OFS=o
}

function z2str(z,pk, i,s){
 for(i=1;i<=pk+0;i++)
  s=sprintf("%s %s",s,z[i]?z[i]:"0")
 delete z
 return s
}

function _et(t, c,i,j,k,s,x,z,ET1,ET2,ET3){
 z=2
 s=t
 while(s!=1 && getline i <"prime.tbl" >0){
  if(mod(s,i)) continue
  for(ET1[i]=0;!mod(s,i);ET1[i]++)
   s=quotient(s,i)
 }
 close("prime.tbl")
 z=multiple(z,power(2,ET1[2]+1))
 for(i=1;i<=ET1[2];i++)
  ET2[i]=power(2,i)
 delete ET1[2]
 c=1
 for(i in ET1){
  for(j in ET2){
   if(split(j,ET3,SUBSEP)!=c) continue
   for(k=0;k<=ET1[i];k++)
    ET2[j,k]=multiple(ET2[j],power(i,k))
   delete ET2[j]
  }
  c++
  delete ET1[i]
 }
 delete ET3
 for(i in ET2){
  x=suc(ET2[i])
  if(isprime(x)){
   z=multiple(z,x)
   s=t
   for(k=0;!mod(s,x);k++)
    s=quotient(s,x)
   if(k) z=multiple(z,power(x,k))
  }
  delete ET2[i]
 }
 return z
}
