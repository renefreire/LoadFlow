% Função que calcula a matriz jacobiana utilizada no método de
% Newton-Raphson

function [J] = jacobiano(param,inj,stat,estudo)

% Declaração de variáveis
Vbarra = stat.Vbarra;
ang = stat.ang;
G = param.G;
B = param.B;

% PQ -> Número de barras PQ
pq = find(inj.tipo == 1);

% PQ + PV -> Soma das barras PQ e PV
pq_pv = find(inj.tipo ~= 3);

% H - derivada parcial da injeção de potência ativa em relação ao
% ângulo da tensão
Hi = numel(pq_pv);
Hj = numel(pq_pv);
H = zeros(Hi,Hj);
for i = 1:Hi
    k = pq_pv(i);
    for j = 1:Hj
        m = pq_pv(j);
        if k == m % Hkk = dPk/dThk
            for m = 1:param.nBarras
                H(i,j) = H(i,j) - Vbarra(k)*Vbarra(m)*(G(k,m)*sin(ang(k)-ang(m)) - B(k,m)*cos(ang(k)-ang(m)));
            end
            H(i,j) = H(i,j) - (Vbarra(k)^2)*B(k,k);
        else % Hkm = dPk/dThm
            H(i,j) = Vbarra(k)*Vbarra(m)*(G(k,m)*sin(ang(k)-ang(m)) - B(k,m)*cos(ang(k)-ang(m)));
        end
    end
end

% N - derivada parcial da injeção de potência ativa em relação ao
% módulo da tensão, multiplicado pelo próprio módulo da tensão
Ni = numel(pq_pv);
Nj = numel(pq);
N = zeros(Ni,Nj);
if (estudo > 1)
    for i = 1:Ni
        k = pq_pv(i);
        for j = 1:Nj
            m = pq(j);
            if k == m % Nkk = Vk(dPk/dVk)
                for m = 1:param.nBarras
                    N(i,j) = N(i,j) + Vbarra(k)*Vbarra(m)*(G(k,m)*cos(ang(k)-ang(m)) + B(k,m)*sin(ang(k)-ang(m)));
                end
                N(i,j) = N(i,j) + (Vbarra(k)^2)*G(k,k);
            else % Nkm = Vm(dPk/dVm)
                N(i,j) = Vbarra(m)*Vbarra(k)*(G(k,m)*cos(ang(k)-ang(m)) + B(k,m)*sin(ang(k)-ang(m)));
            end
        end
    end
end

% M - derivada parcial da injeção de potência reativa em relação ao
% ângulo da tensão
Mi = numel(pq);
Mj = numel(pq_pv);
M = zeros(Mi,Mj);
if (estudo > 1)
    for i = 1:Mi
        k = pq(i);
        for j = 1:Mj
            m = pq_pv(j);
            if k == m % Mkk = dQk/dThk
                for m = 1:param.nBarras
                    M(i,j) = M(i,j) + Vbarra(k)*Vbarra(m)*(G(k,m)*cos(ang(k)-ang(m)) + B(k,m)*sin(ang(k)-ang(m)));
                end
                M(i,j) = M(i,j) - (Vbarra(k)^2)*G(k,k);
            else % Mkm = dQk/dThm
                M(i,j) = - Vbarra(k)*Vbarra(m)*(G(k,m)*cos(ang(k)-ang(m)) + B(k,m)*sin(ang(k)-ang(m)));
            end
        end
    end
end

% L - derivada parcial da injeção de potência reativa em relação ao
% módulo da tensão, multiplicado pelo próprio módulo da tensão
Li = numel(pq);
Lj = numel(pq);
L = zeros(Li,Lj);
for i = 1:Li
    k = pq(i);
    for j = 1:Lj
        m = pq(j);
        if k == m % Lkk = Vk(dQk/dVk)
            for m = 1:param.nBarras
                L(i,j) = L(i,j) + Vbarra(k)*Vbarra(m)*(G(k,m)*sin(ang(k)-ang(m)) - B(k,m)*cos(ang(k)-ang(m)));
            end
            L(i,j) = L(i,j) - (Vbarra(k)^2)*B(k,k);
        else % Lkm = Vm(dQk/dVm)
            L(i,j) = Vbarra(m)*Vbarra(k)*(G(k,m)*sin(ang(k)-ang(m)) - B(k,m)*cos(ang(k)-ang(m)));
        end
    end
end

J = [H N;  % Matriz Jacobiano
     M L];
 
J = sparse(J);