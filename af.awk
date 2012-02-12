#
# Arithmetica Hadamard edition
# copyright Matsui Tetsushi 1995-1999
# last modified : 1998-07-30
# usage: igawk -f af.awk [-f scripts] [data]
#

@include alib.awk

BEGIN{
 IGNORECASE=1
 buf_size=25 #size of ring buffer
 st=systime()
}
/quit/{ exit}
/^ *#/{ next}
/hist/{
 for(i=((h=NR-buf_size)<1?1:h);i<NR;i++){
  print "output[" i "]= " preval[i]
 }
 next
}
/=/{
 sub(/^ *-/,"0-")
 gsub(/[-()^+=*/%!\\,]/," & ")
 if($2=="="){
  var_array[$1]=expression(3,NF)
  print $1 " = " var_array[$1]
 }
 else
  print "Wrong substitution"
 next
}
{
 print
 sub(/^ *-/,"0-")
 gsub(/[-()^+*/%!\\,]/," & ")
 val=expression(1,NF)
 if(!val)
  val=0
 print "output[" NR "] = " val
 preval[NR%buf_size]=val
 for(i in pfactor){
  delete pfactor[i]
  delete ppower[i]
 }
}
END{
 print systime()-st "sec"
 print"Thank you!"
}

function expression (fp,lp, i,a,b,retval,lfp,flp,pc){
 for(i=lp;i>=fp;i--){
  if($i==")") pc++
  if($i=="(") pc--
  if(pc==0 && ($i=="+" || $i=="-")){
   lfp=i+1
   flp=i-1
   break
  }
 }
 if(flp>=fp){
  a=expression(fp,flp)
  b=term(lfp,lp)
  if($i=="+")
   retval=add(a,b)
  else
   retval=subtract(a,b)
 }
 else
  retval=term(fp,lp)
 return retval
}

function term (fp,lp, i,a,b,retval,lfp,flp,pc){
 for(i=lp;i>=fp;i--){
  if($i==")") pc++
  if($i=="(") pc--
  if(pc==0 && ($i=="*" || $i=="/" || $i=="\\")){
   lfp=i+1
   flp=i-1
   break
  }
 }
 if(flp>=fp){
  if($i=="\\")
   retval=mod_expression(fp,lp,flp,lfp)
  else{
   a=term(fp,flp)
   b=factor(lfp,lp)
   if($i=="*")
    retval=multiple(a,b)
   else
    retval=quotient(a,b)
  }
 }
 else
  retval=factor(fp,lp)
 return retval
}

function factor (fp,lp, i,a,b,retval,lfp,flp,pc){
 for(i=fp;i<=lp;i++){
  if($i=="(") pc++
  if($i==")") pc--
  if(pc==0 && $i=="^"){
   lfp=i+1
   flp=i-1
   break
  }
 }
 if(flp>=fp){
  a=base(fp,flp)
  b=factor(lfp,lp)
  retval=power(a,b)
 }
 else
  retval=base(fp,lp)
 return retval
}
 
function base(fp,lp, retval,pc,i,j){
 if($fp=="(" && $lp==")")
  return normalize(expression(fp+1,lp-1))
 if($lp=="!")
  return normalize(factorial(base(fp,lp-1)))
 if($fp~/sqrt/)
  return normalize(fsqrt(base(fp+1,lp)))
 if($fp=="-")
  return normalize(multiple(base(fp+1,lp),-1))
 if($fp=="%"){
  if(fp==lp)
   return normalize(preval[(NR-1)%buf_size])
  if(lp==fp+1 && $lp~/^[0-9]+$/)
   return normalize(preval[($lp+0)%buf_size])
 }
 if($(fp+1)=="(" && $lp==")"){
  for(i=fp+2;i<=lp;i++){
   if($i=="(")pc++
   if($i==")")pc--
# one variable functions
   if(pc==-1 && i==lp){
    if($fp=="sqrt")
     return fsqrt(expression(fp+2,lp-1))
    if($fp=="isprime")
     return isprime(expression(fp+2,lp-1))
    if($fp=="isprimew")
     return isprime_wilson(expression(fp+2,lp-1))
    if($fp=="factor"){
     factorize(expression(fp+2,lp-1))
     for(i in pfactor)
      if (pfactor[i]) printf("%s^%s ",pfactor[i],ppower[i])
     printf("\n")
     return 1
    }
    print "Undefined function name"
    reurn 0
   }
# two variable functions
   if(pc==0 && $i==","){
    if($fp=="gcd")
     return gcd(expression(fp+2,i-1),expression(i+1,lp-1))
    if($fp=="lcm")
     return lcm(expression(fp+2,i-1),expression(i+1,lp-1))
    if($fp=="psp")
     return psp(expression(fp+2,i-1),expression(i+1,lp-1))
    if($fp=="Legendre")
     return Legendre(expression(fp+2,i-1),expression(i+1,lp-1))
# three variable functions
    for(j=i+1;j<=lp;j++){
     if($i=="(") pc++
     if($i==")") pc--
     if(pc==0 && $j==","){
      if($fp=="spsp")
       return spsp(expression(fp+2,i-1),expression(i+1,j-1),expression(j+1,lp-1))
     }
    }
    print "Undefined function name"
    return 0
   }
  }
  print "Wrong parenthesis match or missing/extra \",\" in",$fp,"context."
  return 0
 }
 if(fp!=lp){
  print "Wrong parenthesis match or missing operator"
  return 0
 }
 if($fp!~/^[0-9]+$/)
  return normalize(var_array[$fp])
 else
  return normalize($fp)
}

function mod_expression(fp,lp,flp,lfp, retval,m){
 m=factor(lfp,lp)
 retval=mod_term(fp,flp,m)
 return retval
}

function mod_term(fp,lp,m, retval,i,pc,lfp,flp,a,b){
 for(i=lp;i>=fp;i--){
  if($i==")") pc++
  if($i=="(") pc--
  if(pc==0 && ($i=="*" || $i=="/" || $i=="\\")){
   lfp=i+1
   flp=i-1
   break
  }
 }
 if(flp>=fp){
  if($i=="\\")
   retval=mod_expression(fp,lp,flp,lfp)
  else{
   a=mod_term(fp,flp,m)
   b=mod_factor(lfp,lp,m)
   if($i=="*")
    retval=mod_multiple(a,b,m)
   else
    retval=mod_quotient(a,b,m)
  }
 }
 else
  retval=mod_factor(fp,lp,m)
 return retval
}

function mod_factor(fp,lp,m, retval,i,pc,lfp,flp,a,b){
 for(i=fp;i<=lp;i++){
  if($i=="(") pc++
  if($i==")") pc--
  if(pc==0 && $i=="^"){
   lfp=i+1
   flp=i-1
   break
  }
 }
 if(flp>=fp){
  a=mod_base(fp,flp,m)
  b=factor(lfp,lp)
  retval=mod_power(a,b,m)
 }
 else
  retval=mod_base(fp,lp,m)
 return retval
}

function mod_base(fp,lp,m ,retval){
 if($fp=="(" && $lp==")")
  retval=expression(fp+1,lp-1)
 else if($lp=="!")
  retval=mod_factorial(base(fp,lp-1),m)
 else if($fp~/sqrt/)
  retval=mod_fsqrt(base(fp+1,lp),m)
 else if($fp=="-")
  retval=mod_multiple(base(fp+1,lp),-1,m)
 else if($fp=="%"){
  if(fp==lp)
   retval=mod(preval[(NR-1)%buf_size],m)
  else if(lp==fp+1 && $lp~/^[0-9]+$/)
   retval=mod(preval[($lp+0)%buf_size],m)
 }
 else if(fp!=lp){
  print "Wrong parenthesis match or missing operator"
  return 0
 }
 else if($fp~/^[0-9]+$/){
  retval=mod($fp,m)
 }
 else
  retval=mod(var_array[$fp],m)
 normalize(retval)
 return retval
}
