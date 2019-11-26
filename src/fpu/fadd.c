#include <stdio.h>
#include "default.h"

int main(){
    long long int a1,a2;
    scanf("%lld",&a1);
    scanf("%lld",&a2);
    wire x1 = init(32,a1);
    wire x2 = init(32,a2);
    // 1
    wire s1 = extract(x1,31,31);
    wire e1 = extract(x1,30,23);
    wire m1 = extract(x1,22,0);
    wire s2 = extract(x2,31,31);
    wire e2 = extract(x2,30,23);
    wire m2 = extract(x2,22,0);
    print_wire(s1);
    printf(" ");
    print_wire(e1);
    printf(" ");
    print_wire(m1);
    printf("\n");
    print_wire(s2);
    printf(" ");
    print_wire(e2);
    printf(" ");
    print_wire(m2);
    printf("\n");
    // 2
    wire m1a = eq(e1,init(8,0)) ? concat(init(2,0),m1) : concat(init(2,1),m1);
    wire m2a = eq(e2,init(8,0)) ? concat(init(2,0),m2) : concat(init(2,1),m2);
    // 3
    wire e1a = eq(e1,init(8,0)) ? init(8,1) : e1;
    wire e2a = eq(e2,init(8,0)) ? init(8,1) : e2;
    // 4
    wire e2ai = not(e2a);
    // 5
    wire te = add(e1a,e2ai,1);
    // 6
    wire ce = (extract(te,8,8)).val ? init(1,0) : init(1,1);
    wire te1 = add(te,init(9,1),0);
    wire te2 = not(te);
    wire tde = (extract(te,8,8)).val ? extract(te1,7,0) : extract(te2,7,0);
    // 7
    wire de = (bitor(extract(tde,7,5))) ? init(5,31) : extract(tde,4,0);
    // 8
    wire sel = gt(extract(de,4,0),init(5,0)) ? ce : gt(m1a,m2a) ? init(1,0) : init(1,1);
    // 9
    wire ms = (~sel.val) ? m1a : m2a;
    wire mi = (~sel.val) ? m2a : m1a;
    wire es = (~sel.val) ? e1a : e2a;
    wire ss = (~sel.val) ? s1 : s2;
    // 10
    wire mie = concat(mi,init(31,0));
    // 11
    wire mia = init(mie.len,mie.val >> de.val);
    // 12
    wire tstck = init(1,bitor(extract(mia,28,0)));
    // 13
    wire mye = eq(s1,s2) ? add(concat(ms,init(2,0)),extract(mia,55,29),0) : sub(concat(ms,init(2,0)),extract(mia,55,29),0);
    // 14
    wire esi = add(es,init(8,1),0);
    // 15
    wire eyd = ~((extract(mye,26,26)).val) ? es : eq(esi,init(8,255)) ? init(8,255) : esi;
    wire myd = ~((extract(mye,26,26)).val) ? mye : eq(esi,init(8,255)) ? concat(init(2,1),init(25,0)) : init(mye.len,mye.val >> 1);
    wire stck = ~((extract(mye,26,26)).val) ? tstck : eq(esi,init(8,255)) ? init(1,0) : init(1,tstck.val | extract(mye,0,0).val);
    // 16
    wire se = (extract(myd,25,25)).val ? init(5,0) :
              (extract(myd,24,24)).val ? init(5,1) :
              (extract(myd,23,23)).val ? init(5,2) :
              (extract(myd,22,22)).val ? init(5,3) :
              (extract(myd,21,21)).val ? init(5,4) :
              (extract(myd,20,20)).val ? init(5,5) :
              (extract(myd,19,19)).val ? init(5,6) :
              (extract(myd,18,18)).val ? init(5,7) :
              (extract(myd,17,17)).val ? init(5,8) :
              (extract(myd,16,16)).val ? init(5,9) :
              (extract(myd,15,15)).val ? init(5,10) :
              (extract(myd,14,14)).val ? init(5,11) :
              (extract(myd,13,13)).val ? init(5,12) :
              (extract(myd,12,12)).val ? init(5,13) :
              (extract(myd,11,11)).val ? init(5,14) :
              (extract(myd,10,10)).val ? init(5,15) :
              (extract(myd,9,9)).val ? init(5,16) :
              (extract(myd,8,8)).val ? init(5,17) :
              (extract(myd,7,7)).val ? init(5,18) :
              (extract(myd,6,6)).val ? init(5,19) :
              (extract(myd,5,5)).val ? init(5,20) :
              (extract(myd,4,4)).val ? init(5,21) :
              (extract(myd,3,3)).val ? init(5,22) :
              (extract(myd,2,2)).val ? init(5,23) :
              (extract(myd,1,1)).val ? init(5,24) :
              (extract(myd,0,0)).val ? init(5,25) : init(5,27);
    // 17
    wire eyf = sub(eyd,concat(init(3,0),se),1);
    // 18
    wire eyr = (~(extract(eyf,8,8).val) & gt(eyf,init(9,0))) ? extract(eyf,7,0) : init(8,0);
    wire myf = (~(extract(eyf,8,8).val) & gt(eyf,init(9,0))) ? init(myd.len,myd.val << se.val) : init(myd.len,myd.val << (extract(eyd,4,0).val - 1));
    print_wire(myf);
    // 19
    wire myr = ((extract(myf,1,1).val & ~(extract(myf,0,0).val) & ~(stck.val) & extract(myf,2,2).val) | (extract(myf,1,1).val & ~(extract(myf,0,0).val) & eq(s1,s2) & stck.val) | (extract(myf,1,1).val & extract(myf,0,0).val)) ? add(extract(myf,26,2),init(25,1),0) : extract(myf,26,2);
    // 20
    wire eyri = add(eyr,init(8,1),0);
    // 21
    wire ey = extract(myr,24,24).val ? eyri : ~bitor(extract(myr,23,0)) ? init(8,0) : eyr;
    wire my = extract(myr,24,24).val ? init(23,0) : ~bitor(extract(myr,23,0)) ? init(23,0) : extract(myr,22,0);
    print_wire(my);
    // 22
    wire sy = (~bitor(ey) & ~bitor(my)) ? init(1,s1.val & s2.val) : ss;
    // 23
    wire nzm1 = init(1,bitor(m1));
    wire nzm2 = init(1,bitor(m2));
    wire y = (bitand(e1) & ~bitand(e2)) ? concat(concat(s1,init(8,255)),concat(nzm1,extract(m1,21,0))) :
             (bitand(e2) & ~bitand(e1)) ? concat(concat(s2,init(8,255)),concat(nzm2,extract(m2,21,0))) :
             (bitand(e1) & bitand(e2) & nzm2.val) ? concat(concat(s2,init(8,255)),concat(init(1,1),extract(m2,21,0))) :
             (bitand(e1) & bitand(e2) & nzm1.val) ? concat(concat(s1,init(8,255)),concat(init(1,1),extract(m1,21,0))) :
             (bitand(e1) & bitand(e2) & eq(s1,s2)) ? concat(concat(s1,init(8,255)),init(23,0)) :
             (bitand(e1) & bitand(e2)) ? concat(concat(init(1,1),init(8,255)),concat(init(1,1),init(22,0))) : concat(concat(sy,ey),my);
    wire ovf = (lt(e1,init(8,255)) & lt(e2,init(8,255)) & ((extract(mye,26,26).val & bitand(esi)) || (extract(myr,24,24).val & bitand(eyri)))) ? init(1,1) : init(1,0);

    print_wire(y);
    printf("\n");
    // wire c = concat(x1,x2);
    // print_wire(c);
    // wire d = extract(c,8,2);
    // printf("%d\n",eq(c,d));
    // printf("%d\n",eq(c,c));
    // print_wire(d);
    return 0;
}