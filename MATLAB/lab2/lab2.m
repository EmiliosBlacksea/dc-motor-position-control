km = 220;
kt = 0.004;
kM = 0.027;
ko = 0.24;
Tm = 0.531;
syms s s1 s2; %idiotimes s1 s2
syms k1 k2
I = [1, 0;
     0, 1];
s1 = -7;
s2 = -7;

A = [0 kM*ko/kt; 
    0 -1/Tm];
B = [0; 
    km*kt/Tm];
C = [1,0];
K = [k1, k2];
% evresi K gia idiotimes s1 s2
pclosed = det(s * I - (A - B * K)); %to xaraktiristiko polionimo pou exoume
pdesired = (s - s1) * (s - s2);     %to xaraktiristiko polionimo pou thelo
c_pc = coeffs(pclosed, s);          %sidelestes tou s sto pclosed
c_pd = coeffs(pdesired, s);         %sidelestes tou s sto pdesired
eq = c_pc == c_pd;
sol = solve(eq, K);                 
K = [sol.k1, sol.k2];
%
kr = -1/(C*((A - B*K)^-1)*B);
