km = 220;
kt = 0.004;
kM = 0.027;
ko = 0.24;
Tm = 0.531;
syms s s1 s2 p1 p2 P1 P2 kr x1hat x2hat theta x2(t) k1 k2 q1_ q2_ r;
x = [theta; x2];
xhat = [x1hat; x2hat];
q_= [q1_; q2_];
I = [1, 0;
     0, 1];

A = [0, kM*ko/kt
     0, -1/Tm   ];
B = [0 ;
     km*kt/Tm];
C = [1, 0];

W = [C;
     C*A];
w = rank(W); % = 2 sistima paratirisimo
%x = Ax + Bu
%xaraktiristiko polionimo A
%perr = det(s*I - (A - LC)); %= s^2 + p1 * s + p2
pA = det(s * I - A);% s^2 + a1 * s + a2
                    % = s^2 + (531/1000) * s
a1 = 1000/531;
a2 = 0;
Ww = [1,  0
      a1, 1]^(-1);
L = W^(-1) * Ww * [p1 - a1;
                   p2 - a2];

%o paratiritis mou einai tis morfis q' = Aq + Bu + L(y - Cq)
%ektimisi sfalmatos q' = (A-LC)q
perr = det(s*I - (A - L*C)); %= s^2 + p1 * s + p2
%evresi p1, p2 gia idiotimes/polous paratiriti P1, P2
P1 = -20;
P2 = -25;
perrd = (s - P1) * (s - P2);
P = coeffs(perrd,s);
p1 = P(1,2);
p2 = P(1,1);
%elenxos anadrasis exodou
K = [k1, k2];
%u = -K*x - kr*r
%adikatastasi x' = (A - BK) x
pU = det(s*I - A + B*K);
%evresi k1, k2, kr gia idiotimes/polous elenxti s1, s2
s1 = -7;
s2 = -7;
pUd = (s - s1)*(s - s2);
eq = coeffs(pU,s) == coeffs(pUd, s);
Q = solve(eq,K);
K = [Q.k1, Q.k2];
L = double(subs(L));
K = double(subs(K));
kr = K(1,1);

qq_ = A * xhat + B*(-K * xhat - kr*r ) + L*(C * x - C * xhat);


%q1_ =  (81*q2(t))/50 - (44469*q1(t))/1000 + (44469*x1(t))/1000
%dq1_ = (81*q2(t))/50 - (44469*q1(t))/1000 + (44469*x1(t))/1000
%q1 = q1 +d1q1 * dt
%
%

%q2_ =  (2586632113285787*x1(t))/8796093022208 - (71598285663157849*q1(t))/237494511599616 - (21796718509031423467*q2(t))/3113816929861632000 - (200*r)/27
%
%
%