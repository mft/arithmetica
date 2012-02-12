#
# functions for combinatorics
# copyright Matsui Tetsushi 1995-1999
# last modified : 1998-08-18
#

function Fibonacci(n ,i,f0,f1,f2){
# n-th Fibonacci Number
 if(n==0 || n==1)
  return 1
 f0=1;f1=1
 for(i=2;i<=n;i++){
  f2=add(f1,f0)
  f0=f1
  f1=f2
 }
 return f1
}

function binomial(n,m){
# binomial coefficient
 return quotient(quotient(factorial(n),factorial(m)),factorial(subtract(n,m)))
}

function Stirling1(n,m){
# 1st Stirling Number
 if(n==m)
  return 1
 if(n==0 || m==0)
  return 0
 if(n~/^-/)
  if(m~/^-/)
   return Stirling2(substr(m,2),substr(n,2))
  else
   return 0
 if(m~/^-/ || isbigger(m,n))
  return 0
 if(m==1)
  return pred(power(2,pred(n)))

 return add(Stirling1(pred(n),pred(m)),multiple(pred(n),Stirling1(pred(n),m)))
}

function Stirling2(n,m){
# 2nd Stirling Number
 if(n==m)
  return 1
 if(n==0 || m==0)
  return 0
 if(n~/^-/)
  if(m~/^-/)
   return Stirling1(substr(m,2),substr(n,2))
  else
   return 0
 if(m~/^-/ || isbigger(m,n))
  return 0
 if(m==1)
  return 1

 return add(Stirling2(pred(n),pred(m)),multiple(m,Stirling2(pred(n),m)))
}

function npBernoulli(n,k, i,retval,temp){
# negative index poly Bernoulli Number
# B_{n}^{-k}
 if(n~/^-/){
  print "There is no definition for minus-sign-number-th Bernoulli number."
  return -1
 }
 if(n~/^-?0$/ || k~/^-?0$/)
  return 1
 if(k!~/^-/){
  print "Be sure that this is a function for the negative index."
  return -1
 }
 k=substr(k,2)
 if(isbigger(n,k)){
  temp=k
  k=n
  n=temp
 }
 if(n==1)
  return power(2,k)
 while(getline l< "Bern.dat" >0){
  split(l,nkb)
  if(nkb[1]==n && nkb[2]==k || nkb[1]==k && nkb[2]==n){
   close("Bern.dat")
   return nkb[3]
  }
 }
 close("Bern.dat")
 retval=multiple(suc(n),npBernoulli(n,"-" pred(k)))
 for(i=1;i<n;i++)
  retval=add(retval,multiple(binomial(n,pred(i)),npBernoulli(i,"-" pred(k))))
 print n,k,retval >> "Bern.dat"
 return retval
}
