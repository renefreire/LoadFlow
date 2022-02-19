% Função que aplica o método de Newton-Raphson para a resolução do problema
% do fluxo de potência

function [stat, param] = newton_raphson(rede,param,inj)
                           
iter_max = 100; % Valor máximo de iterações
stat.iter = 1; % Contador de iterações
stat.Vbarra = rede.Barras(:,3); % Modulo inicial da tensão
stat.ang = rede.Barras(:,4); % Ângulo inicial da tensão
tipo_esp = inj.tipo; % Tipo pré-especificado das barras
disp(' ');
disp('Início do método iterativo de Newton-Raphson');

%**************************************************************************
% Início do processo iterativo
%**************************************************************************
while (stat.iter < iter_max)

%**************************************************************************
% Injeções
%**************************************************************************
% Cálculo das injeções de potência ativa e reativa
[Pcal, Qcal] = potencia_calculada(stat,param);

% Verificação de violação dos limites de geração de reativos nas barras PV
[inj, param, stat] = controle_PV(param,inj,stat,Qcal,tipo_esp,rede);

%**************************************************************************
% Cálculo do Mismatch
%**************************************************************************
dPa = inj.Pesp - Pcal; % Resíduo da potência ativa
dQa = inj.Qesp - Qcal; % Resíduo da potência reativa

k = 1;
j = 1;
stat.dP = zeros(param.nBarras - 1,1); % Mismatch de potência ativa
stat.dQ = zeros(param.nPQ,1); % Mismatch de potência reativa

for i = 1:param.nBarras
    if inj.tipo(i) == 1
        stat.dQ(k,1) = dQa(i);
        stat.dP(j,1) = dPa(i);
        k = k + 1;
        j = j + 1;
    elseif inj.tipo(i) == 2
        stat.dP(j,1) = dPa(i);
        j = j + 1;
    end
end

Mism = [stat.dP;
        stat.dQ];

%**************************************************************************
% Verificação da tolerância
%**************************************************************************
% O erro do método de Newton-Raphson é o valor máximo absoluto do vetor de 
% resíduos de potência
erro = max(abs(Mism));

% Se o erro for menor que o limite de tolerância, encerrar o algoritmo
fprintf('\n%dª Iteração -> Erro = %f',stat.iter,erro);
if (erro <= 1e-5)
    break
end

%**************************************************************************      
% Cálculo da matriz Jacobiano e correção das variáveis de estado
%**************************************************************************
% Função que retorna matriz Jacobiano
[J] = jacobiano(param,inj,stat);

X = J\Mism; % Vetor de correção
dang = X(1:(param.nBarras - 1)); % Correção dos ângulos da tensão
dVbarra = X((param.nBarras):end); % Correção do módulo da tensão
 
%**************************************************************************
% Atualização das variáveis de estado
%**************************************************************************
% Ângulo da tensão
k = 1;
for i = 1:param.nBarras
    if inj.tipo(i) ~= 3
        stat.ang(i) = stat.ang(i) + dang(k);
        k = k + 1;
    end
end

% Módulo da tensão
h = 1;
for i = 1:param.nBarras
    if inj.tipo(i) == 1
        stat.Vbarra(i) = stat.Vbarra(i)*(1 + dVbarra(h));
        h = h + 1;
    end
end

% Verificação de violação dos limites de tensão nas barras PQ
[inj, param, stat] = controle_PQ(param,inj,stat,tipo_esp,rede);

%**************************************************************************
% Fim do loop
%**************************************************************************
stat.iter = stat.iter + 1; % Atualização da contagem de iterações

end

%**************************************************************************
% Fim do processo iterativo
%**************************************************************************
% Se ao final das iterações o erro for menor que o limite de tolerância, o
% algoritmo convergiu para uma solução aceitável. Caso contrário, ele é
% considerado divergente
if (erro <= 1e-05)
    fprintf('\n\nConvergência após %d iterações\n',stat.iter);
else 
    error('\n\nDivergência após %d iterações\n',stat.iter);
end
