km = 220;
kt = 0.004;
kM = 0.027;
ko = 0.24;
Tm = 0.531;
%syms km kt kM ko Tm;
I = [1, 0, 0;
     0, 1, 0;
     0, 0, 1];
%eigentvalues

%syms s1 s2 s3
s1 = -7; s2 = -7; s3 = -5; %times apo epithimets idiotimes
syms k1 k2 ki s;

A = [0, kM * ko / kt, 0;
     0, -1 / Tm     , 0;
     1, 0           , 0];

B = [0           ;
     km * kt / Tm;
     0            ];

K = [k1, k2, ki];

Ac = A - B*K;

%%%% sidelestes tis xaraktiristikis sinartisis kleistou vroxou
%%%% na einai oi epithimitoi
pclosed = det(s * I - Ac);
pdesired = (s - s1) * (s - s2) * (s - s3);
c_pc = coeffs(pclosed, s);
c_pd = coeffs(pdesired, s);
eq = c_pc == c_pd;
Q = solve(eq, K);
%%%%
K = [Q.k1, Q.k2];
