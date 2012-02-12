BEGIN{
# preparate the prime table up to 1,000
 primes[1]=2
 primes[2]=3
 c=3
 d1=2
 d2=4
 n=5
 while(n<999){
  flag=1
  for(i in primes){
   if(!(n%primes[i])){
    flag=0
    break
   }
  }
  if(flag){
   primes[c]=n
   c++
  }
  n+=d1
  tmp=d1
  d1=d2
  d2=tmp
 }

# output the prime table
 for(i=1;i in primes;i++)
  print primes[i]

# output primes up to 1,000,000
 for(i=1;i<1000;i++){
  h=i*1000
  for(j=1;j<1000;j+=2)
   s[j]=1
  for(k in primes)
   for(j in s)
    if(!((h+j)%primes[k]))
     delete s[j]
  for(j=1;j<1000;j+=2)
   if(j in s)
    print h+j
 }
}
