% Fun��o que aplica o m�todo de Newton-Raphson para a resolu��o do problema
% do fluxo de pot�ncia

function [stat, param] = newton_raphson(rede,param,inj)
                           
iter_max = 100; % Valor m�ximo de itera��es
stat.iter = 1; % Contador de itera��es
stat.Vbarra = rede.Barras(:,3); % Modulo inicial da tens�o
stat.ang = rede.Barras(:,4); % �ngulo inicial da tens�o
tipo_esp = inj.tipo; % Tipo pr�-especificado das barras
disp(' ');
disp('In�cio do m�todo iterativo de Newton-Raphson');

%**************************************************************************
% In�cio do processo iterativo
%**************************************************************************
while (stat.iter < iter_max)

%**************************************************************************
% Inje��es
%**************************************************************************
% C�lculo das inje��es de pot�ncia ativa e reativa
[Pcal, Qcal] = potencia_calculada(stat,param);

% Verifica��o de viola��o dos limites de gera��o de reativos nas barras PV
[inj, param, stat] = controle_PV(param,inj,stat,Qcal,tipo_esp,rede);

%**************************************************************************
% C�lculo do Mismatch
%**************************************************************************
dPa = inj.Pesp - Pcal; % Res�duo da pot�ncia ativa
dQa = inj.Qesp - Qcal; % Res�duo da pot�ncia reativa

k = 1;
j = 1;
stat.dP = zeros(param.nBarras - 1,1); % Mismatch de pot�ncia ativa
stat.dQ = zeros(param.nPQ,1); % Mismatch de pot�ncia reativa

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
% Verifica��o da toler�ncia
%**************************************************************************
% O erro do m�todo de Newton-Raphson � o valor m�ximo absoluto do vetor de 
% res�duos de pot�ncia
erro = max(abs(Mism));

% Se o erro for menor que o limite de toler�ncia, encerrar o algoritmo
fprintf('\n%d� Itera��o -> Erro = %f',stat.iter,erro);
if (erro <= 1e-5)
    break
end

%**************************************************************************      
% C�lculo da matriz Jacobiano e corre��o das vari�veis de estado
%**************************************************************************
% Fun��o que retorna matriz Jacobiano
[J] = jacobiano(param,inj,stat);

X = J\Mism; % Vetor de corre��o
dang = X(1:(param.nBarras - 1)); % Corre��o dos �ngulos da tens�o
dVbarra = X((param.nBarras):end); % Corre��o do m�dulo da tens�o
 
%**************************************************************************
% Atualiza��o das vari�veis de estado
%**************************************************************************
% �ngulo da tens�o
k = 1;
for i = 1:param.nBarras
    if inj.tipo(i) ~= 3
        stat.ang(i) = stat.ang(i) + dang(k);
        k = k + 1;
    end
end

% M�dulo da tens�o
h = 1;
for i = 1:param.nBarras
    if inj.tipo(i) == 1
        stat.Vbarra(i) = stat.Vbarra(i)*(1 + dVbarra(h));
        h = h + 1;
    end
end

% Verifica��o de viola��o dos limites de tens�o nas barras PQ
[inj, param, stat] = controle_PQ(param,inj,stat,tipo_esp,rede);

%**************************************************************************
% Fim do loop
%**************************************************************************
stat.iter = stat.iter + 1; % Atualiza��o da contagem de itera��es

end

%**************************************************************************
% Fim do processo iterativo
%**************************************************************************
% Se ao final das itera��es o erro for menor que o limite de toler�ncia, o
% algoritmo convergiu para uma solu��o aceit�vel. Caso contr�rio, ele �
% considerado divergente
if (erro <= 1e-05)
    fprintf('\n\nConverg�ncia ap�s %d itera��es\n',stat.iter);
else 
    error('\n\nDiverg�ncia ap�s %d itera��es\n',stat.iter);
end
